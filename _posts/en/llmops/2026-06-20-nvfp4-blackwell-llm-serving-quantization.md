---
title: "Cutting LLM Serving Costs in Half on Blackwell GPUs with NVFP4"
excerpt: "What advantages NVIDIA Blackwell's native 4-bit floating-point format NVFP4 offers over H100 FP8, and how to apply it in the vLLM/TensorRT-LLM stack."
seo_title: "NVFP4 Blackwell LLM Serving Quantization Guide - Thaki Cloud"
seo_description: "Practical strategy for increasing LLM serving throughput and reducing GPU memory costs using NVIDIA Blackwell GPU NVFP4 quantization. Includes vLLM and TensorRT-LLM application methods."
date: 2026-06-20
last_modified_at: 2026-06-20
categories:
  - llmops
tags:
  - nvfp4
  - quantization
  - blackwell
  - vllm
  - tensorrt-llm
  - gpu-memory
  - llm-serving
  - inference-cost
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/en/llmops/nvfp4-blackwell-llm-serving-quantization/"
reading_time: true
lang: en
---

⏱️ **Estimated reading time**: 8 min

One of the most direct ways to reduce GPU cluster costs is to extract more throughput from the same GPU. Quantization is the mechanism, and the combination of NVIDIA Blackwell GPUs with NVFP4 became a practical option for LLM serving stacks in 2026.

## The Shift from FP8 to NVFP4

FP8 was the quantization standard in the H100 (Hopper) era. It maintained a wider dynamic range than INT8 while increasing compute density, and most serving frameworks added FP8 support in 2024-2025.

With Blackwell, NVIDIA stepped down one more level and introduced NVFP4 as a native tensor core format. NVFP4 is a 4-bit floating-point format with a shared exponent. Unlike simple INT4, it preserves floating-point semantics while halving the memory footprint compared to FP8.

According to data published by Nota AI and Microsoft Azure AI Foundry, dense compute performance on Blackwell GPUs (B200) in NVFP4 is 5x that of FP8: 10 PFLOPS dense NVFP4 versus 2 PFLOPS dense FP8 per GPU. The difference comes from compute throughput, not memory bandwidth.

## What NVFP4 Actually Means

Model size numbers make this concrete.

For Llama-3.1-70B: BF16 is roughly 140 GB, FP8 is roughly 70 GB, and NVFP4 is roughly 35 GB. Loading an FP8 70B model onto a single H100 80 GB leaves almost no room for KV cache. With NVFP4 on the same GPU, the model fits comfortably and significant KV cache capacity remains. That translates to handling longer contexts or running larger batches for higher throughput.

NVFP4 is Blackwell-only. FP8 remains the right choice for H100 and A100 environments.

## Framework Support Status (as of June 2026)

**TensorRT-LLM**: The most mature NVFP4 support. v0.17 and later provide native NVFP4 quantization for B200 and other Blackwell GPUs. Recommended for throughput-first production environments.

**vLLM**: Blackwell support via FP8 is stable, and NVFP4 support is expanding. Official documentation includes a Blackwell recipe for Llama 4 Scout. The NVFP4 execution path uses ModelOpt and FlashInfer.

**SGLang**: Adding Blackwell support, but NVFP4 support maturity lags TensorRT-LLM.

## FP8 Quantization in vLLM: Practical Setup

If you do not yet have Blackwell, start with FP8 on H100. The vLLM FP8 configuration is straightforward:

```bash
# FP8 serving on H100
vllm serve meta-llama/Llama-3.1-70B-Instruct \
  --quantization fp8 \
  --kv-cache-dtype fp8 \
  --gpu-memory-utilization 0.90 \
  --max-model-len 32768
```

`--kv-cache-dtype fp8` stores the KV cache in FP8 as well, providing additional memory efficiency. KV cache consumes memory rapidly at long context lengths, so this option is almost always worth enabling.

## Applying NVFP4 on Blackwell

For B200 or GB200 clusters using TensorRT-LLM, quantize the model first with ModelOpt:

```bash
# quantize to NVFP4 with ModelOpt
python -m modelopt.torch.quantization.calib \
  --model meta-llama/Llama-3.1-70B-Instruct \
  --quantization nvfp4 \
  --calib-dataset cnn_dailymail \
  --output-dir ./llama-70b-nvfp4

# build TensorRT-LLM engine
trtllm-build \
  --checkpoint-dir ./llama-70b-nvfp4 \
  --output-dir ./llama-70b-nvfp4-engine \
  --gemm-plugin nvfp4 \
  --max-batch-size 64 \
  --max-input-len 8192 \
  --max-output-len 2048
```

Calibration dataset choice affects quality. Calibrating on data that resembles the actual serving traffic distribution reduces accuracy loss.

## K8s Serving Stack Integration Strategy

In environments like ThakiCloud that use ArgoCD and Kueue to manage GPU workloads, NVFP4 adoption requires attention to the following:

**Branch by GPU type**: Separate Kueue ClusterQueues into Hopper and Blackwell node pools, and apply different quantization settings for each. Use NVFP4 for Blackwell pool deployments and FP8 for Hopper pool deployments.

```yaml
# Helm values: per-GPU-type configuration
serving:
  gpuType: "blackwell"  # or "hopper"
  quantization:
    blackwell: "nvfp4"
    hopper: "fp8"
  kvCacheDtype:
    blackwell: "fp8"   # keep KV cache at FP8 (NVFP4 KV cache is still experimental)
    hopper: "fp8"
```

**Accuracy regression validation**: Always run quality regression tests before replacing a model after quantization. Measure accuracy delta against the BF16 baseline using MMLU, HumanEval, or your own benchmark. Define an acceptable threshold (typically 0.5-1 percentage point) and wire it as a gate in the ArgoCD deployment pipeline.

## Cost Calculation: Real Savings

On a 100-GPU cluster, if using NVFP4 instead of FP8 allows processing twice the context on the same GPU, or reduces the required GPU count by half, annual savings at $3 per GPU-hour run into the hundreds of thousands of dollars. Actual savings depend on model size, context length, and batch configuration.

If you are starting to get access to Blackwell hardware, there is no reason to delay evaluating NVFP4. TensorRT-LLM v0.17 and later provide a sufficiently mature path to adoption.
