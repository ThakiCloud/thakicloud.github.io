---
title: "753B Open Weights on a Consumer GPU: GLM-5.2 and the Economics of On-Premise LLM Serving"
excerpt: "An analysis of running the 753B-scale SOTA open-weight model GLM-5.2 on an RTX 4090 consumer GPU. We cover the DSA sparse-attention kernel port and the economics of on-premise large-LLM serving from ThakiCloud's serving perspective."
seo_title: "GLM-5.2 753B on RTX 4090 On-Premise Serving Analysis - Thaki Cloud"
seo_description: "Running GLM-5.2 753B open weights on an RTX 4090, porting the DSA sparse-attention kernel, and the economics of on-premise large-LLM serving."
date: 2026-06-21
last_modified_at: 2026-06-21
categories:
  - llmops
tags:
  - glm
  - open-weight
  - sparse-attention
  - on-premise
  - llm-serving
  - consumer-gpu
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/en/llmops/glm-5-2-rtx4090-on-premise-serving/"
reading_time: true
lang: en
---

Running a 753B-parameter model on a single consumer GPU would have been hard to imagine a few years ago. A recently shared case reports running the SOTA open-weight model GLM-5.2 (753B, FP8) on an **RTX 4090** consumer GPU for the first time. It manages roughly 10 tok/s, but the point is not throughput. The point is that it runs at all.

At ThakiCloud we handle model serving on a K8s-based AI/ML SaaS platform. Let us look at what this case implies for the economics of on-premise large-LLM serving.

## What Made It Possible: Porting the Sparse-Attention Kernel

Squeezing a large model onto a small GPU combines two techniques.

- **FP8 quantization**: Representing weights in 8-bit floating point shrinks the memory footprint.
- **Porting the DSA sparse-attention kernel to the Ada architecture (sm_89)**: GLM-5.2's DSA (sparse attention) kernel was ported to the RTX 4090's Ada Lovelace architecture (compute capability sm_89). Sparse attention computes only the important token pairs instead of every pair, saving compute and memory on long contexts.

The roughly 10 tok/s throughput is slow for production serving, and since this figure comes from the author's single-environment measurement, treating it as an **[estimate]** is more accurate. What matters is that a path to running a 753B model without dedicated datacenter GPUs has opened up.

## What It Means from a Data Scientist/Engineer's Perspective

- **Kernel porting equals accessibility**: When a model uses a new attention mechanism, the work of porting that kernel to various GPU architectures determines accessibility. Even a SOTA model narrows the ecosystem if its kernel is locked to specific hardware.
- **Sparsity unlocks long context**: Sparse attention like DSA is a key technique for lowering the compute and memory cost of long-context serving. As context grows, dense attention cost rises quadratically, while sparse attention mitigates it.
- **Throughput is a trade-off**: 10 tok/s is the price of fitting a large model on small hardware. Real serving requires choosing the trade-off between model size, hardware, and throughput according to the workload.

## ThakiCloud's View: On-Premise Large-LLM Serving

The real reason this case matters is **data sovereignty and the expansion of serving options**. In sensitive domains there is clear demand to run 753B-class SOTA models in-house rather than sending data to an external API. 10 tok/s on a single consumer GPU is a demo, but scaling it across multiple GPUs with batch and tensor parallelism can reach practical throughput.

This is exactly the space we work in: serving large open-weight models sharded across multiple GPUs on K8s, allocating GPU resources with Kueue, and integrating per-model optimizations such as sparse-attention kernels into a standardized serving stack. Growing a single-machine demo into multi-tenant production serving is the core challenge.

## Closing

Running GLM-5.2 on an RTX 4090 is a signal that an on-premise serving path for large SOTA models has opened up. Kernel porting and sparse attention create accessibility, while quantization unlocks memory. For engineers interested in scaling this into organization-grade serving infrastructure, this kind of problem is the daily work.

## Sources

- GLM-5 model card (Zhipu AI / Z.ai, zai-org): <https://huggingface.co/zai-org/GLM-5>
- GLM-4.6 model card (prior generation reference): <https://huggingface.co/zai-org/GLM-4.6>
- GLM-4.5 / 4.6 / MoE architecture docs (Hugging Face Transformers): <https://huggingface.co/docs/transformers/model_doc/glm4_moe>

> The single RTX 4090 case and the ~10 tok/s throughput above are an **[estimate]** based on community reports, not an independently verified official benchmark. DSA (sparse attention) is confirmed in public materials as integrated into the GLM-5 family; details for the specific minor version (5.2) follow the official model cards.
