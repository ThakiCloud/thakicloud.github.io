---
title: "MiniMax-M3: 428B MoE Multimodal, 1M Context and MSA Deliver 9x Faster Prefill Than M2.7"
excerpt: "MiniMaxAI's M3 is a 428B total / 23B active parameter MoE multimodal VLM. 1M context, MiniMax Sparse Attention, SGLang/vLLM support. License is minimax-community; verify the full text before commercial deployment."
seo_title: "MiniMax-M3 428B MoE Multimodal Model On-Premises Serving Guide - ThakiCloud"
seo_description: "MiniMax-M3 architecture (428B/23B MoE, 1M context, MSA), arXiv:2606.13392, SGLang/vLLM serving, Kueue deployment strategy, and license considerations."
date: 2026-06-20
last_modified_at: 2026-06-20
categories:
  - owm
tags:
  - minimax-m3
  - minimax
  - moe
  - multimodal
  - vlm
  - sparse-attention
  - vllm
  - sglang
  - self-hosting
  - long-context
lang: en
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/en/owm/minimax-m3-multimodal-moe/"
reading_time: true
---

⏱️ **Estimated reading time**: 8 min

![MiniMax-M3 architecture diagram](/assets/images/minimax-m3-multimodal-moe-hero.png)

## What Is New

MiniMaxAI has released `MiniMaxAI/MiniMax-M3`. It is the successor to M2.7, and the most notable change is speed. According to the developer's own reports, it is 9x faster at prefill and 15x faster at decode compared to M2, with per-token compute reduced to roughly 1/20 of the original. These figures are vendor claims without independent verification, so they need to be confirmed on your actual tasks, but the design intent is clear: process a 1M token context at practical speeds.

The model handles text, images, and video natively across three modalities. Unlike the previous generation, which was text-only, it accepts visual input for use in agent and coding tasks. The HuggingFace tags explicitly list `agent`, `coding`, and `video`.

## Architecture

Total parameters are approximately 428B, with approximately 23B active parameters. In the MoE structure, the number of experts actually participating in computation per token determines this 23B figure. Detailed MoE parameters such as expert count and layer count are not disclosed in the model card.

The core technology is **MiniMax Sparse Attention (MSA)**. The paper is available at arXiv:2606.13392. It addresses the O(n^2) complexity of standard full attention through attention sparsification to handle 1M contexts at realistic cost. Models supporting 1M context have appeared before, but applying both MoE and sparse attention together to also improve decode throughput is what distinguishes M3.

Three inference modes are available. `thinking=enabled` uses chain-of-thought style reasoning, `thinking=adaptive` switches automatically based on task complexity, and `thinking=disabled` gives direct responses. Recommended inference parameters are temperature 1.0, top_p 0.95, top_k 40.

Supported dtypes are BF16 and F32. FP8 was supported in M2.7 but is not mentioned in the M3 model card. Verify before actual deployment.

## Benchmarks

The official model card does not include specific benchmark numbers. The only figures provided are speed improvement numbers relative to M2. For external leaderboard or independent evaluation results, the arXiv:2606.13392 paper is the right place to look alongside the model card.

Supported languages are also not listed in the model card. Multilingual support should be verified through direct testing.

## Serving and Deployment

M3 officially supports SGLang, vLLM, Transformers, Ollama, llama.cpp, LM Studio, and Jan. In an on-premises K8s environment, deploying SGLang or vLLM as a Deployment and serving over HTTP is the realistic path.

Loading the 428B model in BF16 requires approximately 856 GB of VRAM. The theoretical requirement is 11 H100 80GB cards or 7 H200 141GB cards. Due to MoE characteristics, only 23B parameters are active per token, so actual throughput is much better than a dense 428B model, but the full parameter set still needs to reside in VRAM.

23 quantized variants have been released. Using 4-bit or 8-bit quantization cuts GPU requirements to less than half. The quality degradation for each quantized variant should be evaluated directly.

When serving M3 with vLLM, tensor parallelism configuration is required.

```bash
vllm serve MiniMaxAI/MiniMax-M3 \
  --tensor-parallel-size 8 \
  --dtype bfloat16 \
  --max-model-len 65536
```

To use the full 1M context, `max-model-len` must be adjusted to account for KV cache memory as well. Starting tests with short contexts and increasing incrementally is the safe approach.

For SGLang, expert parallelism optimized for MoE models is available.

```bash
python -m sglang.launch_server \
  --model-path MiniMaxAI/MiniMax-M3 \
  --tp 8 \
  --dtype bfloat16
```

## License

The license is `minimax-community`. This is not Apache-2.0 or MIT but a proprietary license. Conditions for commercial use, redistribution restrictions, and derivative model rules may differ from standard open-source licenses. The full LICENSE text must be reviewed before production deployment.

## ThakiCloud Perspective

**Kueue and MoE serving resource management.** A 428B MoE model has large GPU resource requirements and significant throughput variation depending on request patterns. On the ThakiCloud platform, isolating an M3-dedicated GPU pool using Kueue's ResourceFlavor and ClusterQueue, and separating batch inference from online serving with WorkloadPriorityClass, allows operation without resource contention.

**1M context and multimodal agent pipelines.** M3's 1M context and image/video input capabilities can be applied to document analysis, full codebase exploration, and building video understanding agents. Attaching an M3 serving endpoint to ThakiCloud's existing Kueue-based batch pipeline would create a structure for processing long-context tasks in batch mode. However, the resource cost is significant, so measuring how much context length each task type actually requires is a prerequisite.

If you have M2.7-based workloads already in place, upgrading to M3 requires separately reviewing the inference parameters (`thinking` mode) and multimodal input handling. This is not a drop-in replacement; interface changes are involved.
