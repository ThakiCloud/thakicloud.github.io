---
title: "Compressing a 30B MoE Model to 4-Bit Precision Within 32GiB of Host Memory"
seo_title: "Measured 30B MoE Pruning + W4A16 Quantization on a Memory-Constrained GPU"
seo_description: "ThakiCloud measured pruning and 4-bit quantization of the roughly 61-billion-parameter Qwen3-Coder-30B-A3B checkpoint via shard streaming on a single H200 GPU pod with only 32GiB of host RAM."
excerpt: "A measured paper that solves the problem of large MoE compression pipelines being bottlenecked by host RAM rather than GPU memory, using shard-level streaming pruning and layer-wise RTN W4A16 quantization."
date: 2026-07-30
tags: [MoE, 양자화, LLM압축, 전문가프루닝, Qwen3, H200, W4A16, 추론비용]
categories: [research]
author_profile: true
toc: true
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/research/moe-w4a16-pruned-30b-single-gpu/"
audiobook: "https://drive.google.com/file/d/13bsjA5BlajhqCJI8IXWXa_8RHEFb3ECd/view"
audiobook_label: "▶ Listen: 5-minute briefing"
audiobook_note: "NotebookLM audio overview (AI-generated)"
---

If you have ever run an infrastructure workload where the host RAM of the pod runs out before the GPU's high-bandwidth memory does, this paper is aimed directly at you. ThakiCloud AI Research measured what happens when you structurally prune and 4-bit quantize Qwen3-Coder-30B-A3B, a checkpoint with roughly 61 billion parameters, on a pod equipped with a single NVIDIA H200 GPU and only 32GiB of host RAM. If you have ever needed to compress a large Mixture-of-Experts (MoE) model to cut serving cost, only to have the compression job itself fail from lack of memory, this is the fix.

![Illustration of the core idea of Compressing a 30B MoE Model to 4-Bit Precision Within 32GiB of Host Memory](/assets/images/moe-w4a16-pruned-30b-single-gpu-hero.png)
*A visual metaphor for the article's key idea.*

## The problem: it is the compression pipeline, not the GPU, that runs out of memory

MoE architectures route each token to only a subset of expert subnetworks, which lets the total parameter count grow while keeping per-token compute low. But this structure creates a distinctive cost problem: per-token compute stays light, while checkpoint storage size and memory footprint scale with the full parameter count. Most efforts to run MoE models cheaply so far have targeted the GPU high-bandwidth memory bottleneck at serving time, either by quantizing weights to lower bit widths or by streaming and offloading expert weights so that not every expert has to sit resident on the GPU.

But a less-discussed constraint, just as tricky, sits one step earlier. The one-time compression pipeline that has to produce the pruned or quantized artifact conventionally loads the entire checkpoint into host RAM (CPU memory) before doing any work. For a 30B-class MoE checkpoint like Qwen3-Coder-30B-A3B, which is 61.0GB on disk, this "load then transform" approach demands host RAM at least that large, plus a working copy on top. On an ordinary single-GPU pod with a fixed 32GiB host RAM ceiling, the base model alone is already nearly twice that ceiling, so this design simply does not fit structurally.

The question this paper asks is direct: can you structurally prune and W4A16-quantize a 30B-class MoE model within a fixed, small host RAM budget, all the way through, without ever loading the entire model into CPU memory at once?

## Method: profiling, selection, shard streaming, and layer-wise quantization

The authors' answer is a four-stage pipeline.

The first stage, profiling, scores expert importance once using calibration data. Qwen3-Coder-30B-A3B has a total of 6,144 experts across its MoE layers, and this stage processes 3,194,880 profile rows in 1,017.7 seconds. Because this score is independent of the pruning ratio, it is computed only once and amortized across all four downstream variants.

The second stage, selection, decides how many experts to keep based on the profile scores. Rather than searching for a single optimal ratio, the authors swept four pruning intensities, from 10.16% to 37.50%.

The two most important stages are slicing and quantization. Instead of loading the full, unpruned checkpoint into host RAM and then removing experts, the slicing stage reads the checkpoint shard by shard, drops the unselected experts within that shard, and writes out the pruned shard immediately. At no point in this process does the full 61.0GB model, or any intermediate copy of it, ever get assembled whole in host RAM. The quantization stage applies the same discipline: it runs layer-wise RTN (round-to-nearest) W4A16 quantization with a group size of 128 directly on each streamed shard. The streaming invariant kept during slicing carries straight through to quantization. As a result, the design guarantees that the pipeline's peak host RAM usage is bound to the active shard size, not to the 61.0GB base model size.

![Pipeline Stage Wall-Clock Time by Variant](/assets/images/posts/research/moe-w4a16-pruned-30b-single-gpu/fig-pipeline.png)
*Measured slicing and quantization stage time on the H200 pod across the four pruning variants. Quantization time falls as pruning gets more aggressive, but slicing time does not scale simply with the number of experts retained.*

## Results: all four variants succeed, at compression ratios from 3.6x to 4.8x

Running the four pruning intensities on a single H200 GPU with a 32GiB host RAM pod, all four variants completed all the way through quantization without failure.

| Variant | Pruning ratio | Experts kept | Artifact size | Compression ratio | WikiText-2 PPL | Δ |
|---|---|---|---|---|---|---|
| keep115_lowmem | 10.16% | 5,520 | 16.9GB | 3.6x | 9.402 | +3.9% |
| keep102_lowmem | 20.31% | 4,896 | 15.4GB | 4.0x | 10.021 | +10.7% |
| keep90_lowmem | 29.69% | 4,320 | 13.9GB | 4.4x | 10.7757 | +19.0% |
| keep80_lowmem | 37.50% | 3,840 | 12.7GB | 4.8x | 11.8132 | +30.5% |

The base model's (bf16) perplexity on the WikiText-2 test set (296,815 tokens) is 9.0524. Artifact size scales precisely with pruning intensity, from 16.9GB down to 12.7GB, a 3.6x to 4.8x reduction against the 61.0GB base model. One interesting detail is that quantization time and slicing time move differently. Quantization time falls from 267.7 seconds to somewhere between 202 and 204 seconds as fewer experts are kept, which makes sense since there is simply less to quantize. Slicing time, on the other hand, comes in at 422.3, 613.2, 546.0, and 483.6 seconds, not scaling monotonically with pruning intensity at all. The authors cautiously suggest that shard I/O and calibration bookkeeping overhead may not scale linearly with the number of experts retained, while being upfront that they did not actually profile the root cause.

![W4A16 Artifact Size by Pruning Variant](/assets/images/posts/research/moe-w4a16-pruned-30b-single-gpu/fig-compression-size.png)
*All four Qwen3-Coder-30B-A3B-Instruct variants compress from a 61.0GB base model down to 12.7GB to 16.9GB, a 3.6x to 4.8x reduction (measured on an H200 pod).*

The real headline of this result is not the size or the timing but the systemic fact that host RAM never exceeded 32GiB. The paper argues analytically that a load-the-whole-model-first approach could never fit inside the 32GiB limit in the first place, since 61.0GB plus working-copy overhead is already well past it. They did not actually run this naive approach for comparison, so this is not a measured claim that it would have OOM'd, but the fact that the base model size alone is nearly twice the limit makes clear why shard streaming is necessary. The fact that all four variants completed successfully under the limit is itself the empirical evidence that the design works.

## The quality-compression tradeoff: 10 to 20 percent pruning is the defensible sweet spot

Compression ratio matters, but so does quality loss. The WikiText-2 perplexity of the four variants comes in at +3.9%, +10.7%, +19.0%, and +30.5% respectively, worsening monotonically with pruning intensity. What stands out is that the rate of worsening is not constant. Doubling the pruning ratio from 10.16% to 20.31% roughly doubles the relative loss as well (from +3.9% to +10.7%), and at the two most aggressive points (+19.0%, +30.5%), the loss actually accelerates. In other words, this is a superlinear degradation curve: the harder you push pruning, the more expensive the marginal quality cost gets.

The practical implication is clear. A quality-conscious user can remove 10 to 20 percent of experts, get an artifact 3.6x to 4.0x smaller, and accept only a +3.9% to +10.7% perplexity hit. A user under tighter storage or memory pressure can instead push to 29.69% or 37.50%, gaining 4.4x to 4.8x compression at the cost of a much larger +19.0% to +30.5% quality loss.

That said, this perplexity is strictly a language-modeling quality signal, not code-task accuracy. Even though the base model is a Coder model, downstream code benchmarks such as HumanEval or MBPP were not measured in this paper. Whether the 10-20% sweet spot holds equally well for code-generation accuracy cannot be determined from this paper alone, and the authors explicitly leave it as future work.

![WikiText-2 Perplexity vs. Compression Factor](/assets/images/posts/research/moe-w4a16-pruned-30b-single-gpu/fig-ppl-vs-compression.png)
*As the compression ratio grows, perplexity degradation grows superlinearly. The 10-20% pruning range is a defensible sweet spot with little to only moderate loss.*

## What this result leaves behind: company, society, and science

From a company standpoint, it matters that ThakiCloud confirmed a 30B-class MoE model (Qwen3-Coder-30B-A3B) can be compressed down to 12.7GB to 16.9GB using nothing more than an ordinary single H200, 32GiB host pod. This gives concrete grounds for actually cutting the memory and GPU resources needed for serving.

Socially, this pipeline combines DiEP/SHAPE-style expert importance scoring with standard RTN W4A16 quantization, using no proprietary tooling at all. It lowers the barrier to reproducing large MoE low-bit compression, and it is a recipe directly applicable to other teams that need to handle large models under similar constraints, namely limited host RAM and limited budget.

Scientifically, the most interesting point is that combining a shard-level streaming implementation with layer-wise RTN quantization shows that W4A16 compression of a large MoE model becomes possible within a fixed, small host RAM ceiling that a load-then-transform approach could never structurally satisfy. It is an empirical demonstration that expert streaming and paging concepts, previously discussed only at serving time, can be pulled forward and applied directly within the compression pipeline itself.

## Limits: code accuracy, router-preserving refinement, and uniform pruning are still unverified

The paper is upfront about its own limits. First, as noted, code-task accuracy was not measured at all. Given that the base model's actual intended use is code generation, this is the most important remaining gap. Second, the broader methodology includes a router-preserving refinement stage, but it has only been verified on a small synthetic Qwen3-MoE fixture, not at 30B scale. The 30B numbers reported in this paper are pure RTN W4A16 results without that refinement. How much loss the refinement could recover at 30B scale, particularly at the most lossy 29.69% and 37.50% points, remains an open question.

Third, a uniform pruning ratio was applied across all layers rather than allocating different ratios per layer. Fourth, the simplest possible RTN was used instead of calibration-based quantization methods such as GPTQ or AWQ. Both choices are deliberate simplifications, and the authors explicitly flag them as room for future improvement. Finally, the experiments cover only one accelerator (H200) and one base model family (Qwen3-Coder-30B-A3B), so generalization to other accelerators or other MoE families has not yet been confirmed.

The full paper and detailed data are available on Hugging Face.

[https://huggingface.co/datasets/thaki-AI/daily-paper-2026-07-30-moe-w4a16-pruned-30b-single-gpu](https://huggingface.co/datasets/thaki-AI/daily-paper-2026-07-30-moe-w4a16-pruned-30b-single-gpu)
