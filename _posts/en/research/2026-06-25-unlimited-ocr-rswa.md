---
title: "Reading a Whole Book in One Pass: The Constant KV Cache Behind Baidu's Unlimited OCR"
excerpt: "Baidu's Unlimited OCR replaces decoder attention with Reference Sliding Window Attention to keep the KV cache constant. We unpack how it parses dozens of pages in a single forward pass and what it means for ThakiCloud's multi-tenant inference."
seo_title: "Unlimited OCR R-SWA Constant KV Cache Long-Document Parsing - Thaki Cloud"
seo_description: "Analysis of Baidu Unlimited OCR (arXiv 2606.23050) and its Reference Sliding Window Attention. Constant KV cache processes 32K context in one pass, 93.23% on OmniDocBench v1.5. ThakiCloud Kubernetes multi-tenant document inference perspective."
date: 2026-06-25
last_modified_at: 2026-06-25
categories:
  - research
tags:
  - unlimited-ocr
  - document-parsing
  - sliding-window-attention
  - kv-cache
  - long-context
  - on-premise
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "file-text"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/en/research/unlimited-ocr-rswa/"
reading_time: true
---

## Overview

Turning documents into a machine-readable structure has become central again in the era of RAG and agents. A single contract can run dozens of pages, and financial reports or papers carry tables, equations, and multi-column layouts that flow across page boundaries. These long documents need to be parsed in the correct reading order, all at once, before an LLM can use them well.

The problem is cost. When a vision-language model parses a document, the decoder generates output tokens one at a time autoregressively, and a standard transformer's full attention makes the KV cache grow linearly with sequence length. As pages pile up, memory swells, and a ceiling appears on how long a document you can process in one go. That is why most existing tools split documents page by page, process them separately, and stitch the results back together, breaking the continuity of tables and paragraphs that cross page boundaries.

Baidu's **Unlimited OCR** (arXiv 2606.23050) removes this ceiling differently. It replaces every attention layer in the decoder with Reference Sliding Window Attention (R-SWA), keeping the KV cache size constant throughout decoding. As a result, it can transcribe dozens of pages of a document in a single forward pass within a 32K context. The paper's phrase, "one-shot long-horizon parsing," is no exaggeration.

At ThakiCloud, we run multi-tenant inference and document-processing workloads directly on a Kubernetes-based AI/ML SaaS platform. In an environment where a large share of inference cost comes from KV cache memory, "constant memory regardless of length" is not academic curiosity but a topic that touches serving economics directly. This post explains what R-SWA is, why the KV cache stays constant, and where it fits from our platform's perspective.

## What Is Unlimited OCR

Unlimited OCR is not a from-scratch model but one that pushes DeepSeek-OCR one step further. It keeps DeepSeek-OCR's strong **DeepEncoder** as its encoder and swaps only the decoder's attention for R-SWA.

![Diagram of the Unlimited OCR DeepEncoder encoder and the R-SWA decoder](/assets/images/unlimited-ocr-rswa-diagram.png)
*A high-compression encoder shrinks a page into a handful of visual tokens, and the R-SWA decoder generates long output with a constant KV cache.*

**Encoder (DeepEncoder)**: SAM-ViT and CLIP-ViT are cascaded in series, applying 16x token compression. A single 1024x1024 PDF page compresses to just 256 visual tokens. Because the token count is already cut sharply on the input side, the amount of visual information the decoder must reference is small. This high-compression design works together with the constant KV cache discussed below to enable long-document processing.

**Decoder (an LLM with R-SWA)**: The decoder is a 3B-scale Mixture-of-Experts (MoE) model with roughly 500M activated parameters. Since only a subset of experts activate per token rather than the full 3B, compute per token is light relative to the parameter count. On top of this, replacing all attention layers with R-SWA is the model's core differentiator.

The full model is about three billion parameters, released with BF16 weights under the commercially permissive MIT license. Weights are available on Hugging Face at `baidu/Unlimited-OCR` and on ModelScope, published alongside the code on GitHub. At release it reportedly runs on a single mid-range NVIDIA GPU.

This model is from the same Baidu lineage as PaddleOCR-VL, which we covered earlier, but the approach differs. PaddleOCR-VL splits layout analysis and element recognition into two stages to secure stability with small models, whereas Unlimited OCR keeps a single end-to-end model but changes the attention mechanism to chase one-shot long-document processing. It is interesting to compare two design philosophies solving the same problem.

## The Core Mechanism: Reference Sliding Window Attention

To understand R-SWA, look first at the weaknesses of two existing approaches.

**Full attention** lets every output token see every preceding token. It is accurate, but the KV cache grows in proportion to sequence length. As pages increase, memory grows linearly and hits a ceiling.

**Plain sliding window attention (SWA)** sees only the most recent W tokens. The KV cache is fixed to the window size so memory becomes constant, but information pushed out of the window is forgotten. This works for general text generation, but for OCR, where you must "look at the source and transcribe it faithfully," it is fatal. Once the window moves past, you lose the evidence of which page you were transcribing.

R-SWA splits the difference. Its key idea comes from how humans transcribe a long document. A person writes while looking at both the last few sentences they wrote (short-term working memory) and the original document spread out in front of them (the reference). The "Reference" in R-SWA is exactly this original reference. It keeps the high-compression visual tokens produced by the encoder as an always-accessible anchor while applying a sliding window over the generated text tokens.

In other words, attention looks at two groups. One is the fixed-size visual reference tokens (encoder output), and the other is a sliding window over the recently generated text. Both groups are bounded in length, so however long the output grows, the total KV cache stays constant. It is an attention that mimics working memory in the literal sense: it never forgets the source, yet keeps memory steady.

The paper stresses that R-SWA is not an OCR-only trick but a general-purpose parsing attention. The same structure applies to tasks that read a long input and produce a long output, such as speech recognition (ASR) or translation. The pattern of fixing the input as an anchor reference and applying a sliding window to the output may generalize across sequence-to-sequence problems.

## Benchmark Results

Performance is reported on OmniDocBench, a document-parsing benchmark that comprehensively evaluates body text, tables, equations, and reading order.

- **OmniDocBench v1.5 overall score 93.23%**: a 6.22 percentage-point gain over the DeepSeek-OCR baseline.
- **OmniDocBench v1.6 overall score 93.92%**: reported as end-to-end SOTA.

What stands out is achieving accuracy gains and memory efficiency at the same time. Usually narrowing the window to save memory creates an accuracy trade-off, but R-SWA reaches a constant KV cache without accuracy loss by keeping the visual reference as a fixed anchor. Being able to stream a continuous document at once, without slicing pages and processing them separately, makes a big practical difference, because it preserves the continuity of tables, footnotes, and multi-column body text that break at page boundaries.

That said, all the figures above are values reported by the paper and the model card, not numbers we reproduced ourselves. Unlimited OCR is a 3B MoE model, so meaningful verification requires a GPU and a model download, and this post focuses on the design analysis. We plan to cover hands-on reproduction in a separate experiment.

## Applying It to ThakiCloud's K8s AI/ML SaaS Platform

From our platform's perspective, the reason this model is interesting is clear: the trickiest resource in multi-tenant inference serving is precisely KV cache memory.

**Serving economics**: In serving engines like vLLM, the number of concurrent requests, that is the batch size, depends on how much of GPU memory the KV cache occupies. A full-attention model lets a single long-document request eat a large KV cache, lowering concurrent throughput. A constant-KV-cache model, by contrast, has predictable per-request memory regardless of document length. Whether it is a one-page invoice or a 200-page contract, it is processed with the same memory footprint, so you can plan batch size stably without being shaken by the workload's length distribution. In a multi-tenant environment, per-tenant resource isolation and capacity planning become far simpler.

**On-premise and cost efficiency**: Open weights under the MIT license and operation on a single mid-range GPU are decisive for customers who cannot send data outside. In domains where the documents themselves are sensitive, such as finance, public sector, and healthcare, uploading a contract to a cloud OCR API can itself be a compliance violation. If the constant-memory design lets you stand up a long-document pipeline on-premise with a single reasonable GPU, it sits naturally on top of our stack, where we schedule GPUs with Kueue and serve with vLLM.

**Application roadmap**: On our platform, document-intelligence workloads enter as RAG indexing preprocessing and as document tools for agents. Constant-KV-cache OCR can serve as the first gate in both paths, parsing a long document accurately and in full before it is chunked. Especially for Korean public documents and financial documents with many cross-page tables and multi-column layouts, the ability to process continuously without page splitting directly improves downstream RAG quality. A realistic operating strategy is to deploy PaddleOCR-VL's split-stage stability and Unlimited OCR's one-shot long-document processing selectively, according to workload characteristics.

## Limitations and Counterarguments

An elegant design does not mean it fits every situation.

**Inherent limits of the sliding window**: Even though R-SWA keeps the visual reference as an anchor, the generated-text side is still a sliding window. Very long-range dependencies between output tokens, such as consistently expanding an abbreviation defined on page 1 across page 180, may not be guaranteed to the same degree as full attention even with the visual reference reinforcing them. This is a point to confirm through hands-on reproduction.

**Operational burden of MoE**: A 3B MoE is light in compute per token, but the full set of experts must sit in memory, so actual memory occupancy exceeds the active parameters (500M). MoE also has the property that throughput wobbles when expert routing across tokens in a batch becomes unbalanced, so performance depends on the serving engine's MoE maturity.

**The gap between benchmark and real use**: A high OmniDocBench score does not guarantee the same level on the demanding inputs of real operations, such as non-Latin scripts like Korean and Arabic, handwriting, low-quality scans, or public documents overlaid with stamps. Document OCR is an area where the gap between benchmark and field is especially large, and a separate evaluation on your own document distribution is essential before adoption.

**The need for verification**: Every figure in this post is a value reported by the paper and the model card. Whether the constant KV cache delivers the throughput gain it promises in real serving, and whether it fills 32K without accuracy loss, can only be confirmed by benchmarking it ourselves.

Even so, the idea of "fixing the reference and applying a sliding window to generation" is a clean move for handling the memory ceiling of long sequence-to-sequence tasks. If the claim that it generalizes beyond OCR to ASR and translation holds, it is well worth watching from the standpoint of operating a multi-tenant inference platform.

## Sources

- [Unlimited OCR Works: Welcome the Era of One-shot Long-horizon Parsing (arXiv 2606.23050)](https://arxiv.org/abs/2606.23050)
- [Hugging Face paper page](https://huggingface.co/papers/2606.23050)
- [baidu/Unlimited-OCR (Hugging Face model and weights)](https://huggingface.co/baidu/Unlimited-OCR)
- [baidu/Unlimited-OCR (GitHub code)](https://github.com/baidu/Unlimited-OCR)
