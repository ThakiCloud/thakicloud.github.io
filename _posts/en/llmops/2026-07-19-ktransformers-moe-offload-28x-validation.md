---
title: "A $400K Rack on a 24GB Graphics Card? We Put ktransformers' '28x' to the Test"
excerpt: "ktransformers claims you can run a giant model on a single 24GB GPU by offloading MoE experts to CPU. We measured the viral '28x' and '$400K to 24GB' claims ourselves on RunPod. The trick turned out to be real: with the INT4 AMX kernel enabled, a 671B-class model decoded at roughly 16 tok/s."
date: 2026-07-19
tags:
  - ktransformers
  - MoE
  - LLM서빙
  - GPU
  - AMX
  - LLMOps
  - 벤치마크
  - 인프라
author_profile: true
toc: true
toc_label: "Anatomy of the 28x"
categories:
  - llmops
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/ktransformers-moe-offload-28x-validation/"
---

This post is for infrastructure engineers weighing whether they can self-serve a large MoE model on a single GPU. The short answer: ktransformers' offload trick is real, and with the INT4 AMX kernel properly enabled, a 671B-class model runs at roughly 16 tok/s — quasi-interactive speed.

![Conceptual illustration of running a 671B-class MoE model on a single 24GB GPU via expert offload](/assets/images/ktransformers-moe-offload-28x-validation-hero.png)
*Running a 671B-class MoE on a single 24GB GPU through expert offload.*

## Why it went viral

The idea behind ktransformers (kvcache-ai/ktransformers, Apache 2.0, 17k stars), released by Tsinghua's MADSYS lab, fits in one sentence: keep only the experts an MoE model is currently calling near the GPU, and park the experts that sit idle most of the time in CPU memory, pulling them back only when needed. That layout is what let the claim spread that DeepSeek-V3 and R1 can run on 24GB of VRAM with a 139K context, up to 28x faster than a standard setup. The trick was almost embarrassingly simple, which is exactly what made us wonder where the hidden cost was — so we rented GPUs on RunPod several times and pulled the numbers ourselves.

## Experiment design: isolating the mechanism with a smaller model

We first isolated the mechanism on commodity hardware. DeepSeek-V3 is 671B and won't fit on 24GB, so we used a proxy: Qwen3-30B-A3B (30B total, 3.3B active), a scaled-down member of the same family (MLA plus fine-grained MoE), quantized to Q4. On an RTX 4090 paired with an AMD Ryzen 9 7950X, loading the whole model onto the GPU delivered 261.5 tok/s; offloading experts to CPU dropped that to 12.0 tok/s, and running everything on CPU gave 7.4 tok/s. That comparison is the whole story in miniature: offload is 1.62x faster than pure CPU, but once a model actually fits in VRAM, full-GPU beats it by 22x. In other words, this trick isn't about speed — it's about keeping a model runnable at all once it overflows VRAM.

## The real multiplier behind the Intel AMX kernel

So where does the 28x actually come from? First, that number is a prefill throughput multiplier, not a decoding one — roughly 27.79x over llama.cpp, measured against V0.3. Prefill pushes the whole prompt through at once, a highly parallel stage where the gap widens dramatically, while decoding pulls tokens one at a time and is bottlenecked by CPU compute on the active parameters. When we measured the Intel AMX kernel in isolation — the piece most often credited for the 28x — on a Sapphire Rapids-generation Xeon Platinum 8470, it was 1.38x faster than AVX2 on the same BF16 weights. That's a real gain, but a single kernel doesn't produce a 28x multiplier on its own. The large number only appears when the leverage from moving attention and the KV cache onto the GPU, the AMX kernel's roughly 1.4x, INT4 quantization, and pipeline optimizations all multiply together under specific conditions — and only when the baseline being compared against is pure-CPU llama.cpp.

## The truth behind "a $400K rack on 24GB"

The phrase "a $400K rack down to a single 24GB card" also deserves scrutiny. It doesn't eliminate memory — it relocates it. Running DeepSeek-V3 at Q4 still requires roughly 380GB of DRAM on the CPU side. Expert weights don't disappear; they simply move from VRAM to system RAM, so the accurate description is "one 24GB GPU plus a high-memory RAM server." What's happening is that an expensive GPU gets swapped for cheap RAM — total memory footprint doesn't shrink. That said, the hardware claim itself holds up: offloading Qwen3-235B-A22B (Q4, roughly 130GB), a model that fits on neither a 24GB nor an 80GB card, brought GPU memory usage down to just 11GB. A 235B-parameter model running on a 12GB card is a real result.

## The INT4 kernel that decides decoding: real tok/s and real cost

Decoding speed varies by more than 4x depending on which CPU kernel is enabled. Numbers published by the original authors show DeepSeek-V3/R1 running at q4km (INT4) on an RTX 4090 24GB paired with dual Xeon Gold 6454S CPUs (382GB to 1TB of DRAM) decoding at up to roughly 14-16 tok/s. Paths that don't enable the kernel are far slower. The SOSP25 paper's pre-optimization baseline decodes at 4.68 tok/s with under 30% GPU utilization, and setups that only approximate expert placement — llama.cpp's `--n-cpu-moe` (with no AMX INT4, no MLA, no CUDA graph) or extrapolations from random BF16 weights — bottom out at 1.2-3.8 tok/s. We isolated exactly what accounts for that gap using a proper stack: a Xeon Platinum 8480+ (Sapphire Rapids, AMX-capable) with 2TB of RAM and an H100, running ktransformers' kt-kernel (0.6.3, built from source), and measured decoding on DeepSeek-V3's real architecture (hidden size 7168, MoE intermediate size 2048, 8 active experts, 58 MoE layers) while swapping only the kernel.

| Kernel (same shape, per decoded token) | MoE-only decoding |
|---|---|
| AMX INT4 (AMXInt4_MOE) | 12.4 tok/s |
| AMX INT8 (AMXInt8_MOE) | 6.0 tok/s |
| AMX BF16 (AMXBF16_MOE) | 3.2 tok/s |
| AVX2 BF16 (AVX2BF16_MOE) | 2.9 tok/s |

The INT4 kernel was 3.9x faster than BF16 and 4.2x faster than AVX2 on the same shape. The 1.2-3.8 tok/s floor mentioned earlier lines up exactly with the BF16 and AVX2 rows in that table, and measurements that report offload decoding in the low single digits are almost always cases where this INT4 kernel isn't enabled. The reason is straightforward: decoding is bandwidth-bound, reading the active experts' weights from RAM for every single token, and INT4 only needs to read a quarter of the bytes BF16 does. That 12.4 tok/s figure is CPU-only, MoE-layer-only, tuned to 60 threads (pushing it to 112 threads actually dropped throughput to 6.6 tok/s due to NUMA synchronization overhead); in real serving, with attention and the shared expert overlapping on the GPU, the number lands in the same band as the 14-16 tok/s the original authors published. That's not low single digits — it's low double digits, genuinely quasi-interactive.

The cost picture needs to be redrawn too. Fitting DeepSeek-V3-671B at Q4 requires roughly 380GB, which doesn't even fit on 2xA100 160GB, so a fair full-GPU baseline means an 8xH100/A100 node.

| Configuration | Hardware | Per hour | Decoding |
|---|---|---|---|
| Full-GPU (V3-671B) | 8xH100/A100 node | ~$16-24 | High |
| Offload (INT4 AMX) | 4090 24GB + dual Xeon | ~$3 | ~14-16 tok/s |

In other words, if you already operate a large Xeon server, dropping in a single $1,600 4090 lets you run a 671B-class model at quasi-interactive speed — overwhelmingly cheaper than buying or renting a fresh 8-GPU node.

## So should you adopt it

The adoption decision comes down to two questions. Do you already have a large AMX-capable server with abundant RAM, and is the model you want to run a large MoE (V3/R1-class) that genuinely overflows GPU VRAM? If both are true, ktransformers is the most realistic path to running that model without buying an expensive multi-GPU node. If the model fits entirely on the GPU, full-GPU is faster by tens of times, no contest, and if the goal is high-concurrency real-time serving at thousands of tok/s, multi-GPU is still the right call. Offload's niche is narrow and clear: running a large model that doesn't fit on a GPU, quasi-interactively, on a single card. So the real value of ktransformers isn't the 28x or cheap serving — it's accessibility. A team that can't afford multiple GPUs can now run a 671B-class MoE model at all, using a server it already owns plus a single GPU.

## Reproducibility

All experiments ran on RunPod, for a total GPU cost of about $18. The benchmark harness and raw result JSON are published in full at [github.com/sylvanus4/ktransformers-moe-offload-bench](https://github.com/sylvanus4/ktransformers-moe-offload-bench) (Apache-2.0) — clone it and rerun it if you want to reproduce or verify the numbers yourself. When benchmarking large MoE offload, one thing ultimately decides the multiplier you see: whether you're actually on the path the authors serve in production, and specifically, whether the INT4 AMX kernel is enabled.
