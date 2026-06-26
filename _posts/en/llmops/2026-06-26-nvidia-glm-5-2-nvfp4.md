---
title: "NVIDIA GLM-5.2-NVFP4: Serving a 753B Frontier MoE in 4-bit"
excerpt: "NVIDIA quantized ZAI's 753B MoE reasoning model GLM-5.2 to NVFP4 (4-bit) and published it on Hugging Face. Instead of crushing every weight to 4-bit, only the linear operators of the routed MoE experts are quantized, while the shared expert and attention stay in BF16 — selective quantization that holds accuracy nearly flat against an FP8 baseline. We cover the quantization strategy, the published benchmarks, and the vLLM/SGLang deployment commands from ThakiCloud's K8s multi-tenant serving perspective."
seo_title: "NVIDIA GLM-5.2-NVFP4 753B MoE 4-bit Quantization vLLM SGLang Serving - Thaki Cloud"
seo_description: "Analysis of nvidia/GLM-5.2-NVFP4 (NVFP4 4-bit quantization): selective quantization strategy, accuracy parity vs FP8, vLLM/SGLang deployment commands, and Blackwell TP=8 requirements, framed for ThakiCloud's K8s multi-tenant serving platform."
date: 2026-06-26
last_modified_at: 2026-06-26
categories:
  - llmops
tags:
  - nvfp4
  - quantization
  - vllm
  - sglang
  - glm
  - moe
  - inference-optimization
  - model-optimizer
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "microchip"
toc_sticky: true
lang: en
canonical_url: "https://thakicloud.github.io/en/llmops/nvidia-glm-5-2-nvfp4/"
reading_time: true
---

![Abstract image of a 16-bit neural lattice condensing into a compact 4-bit core](/assets/images/nvidia-glm-5-2-nvfp4-hero.png)
*A visual concept of 16-bit weights condensing into 4-bit.*

For any team trying to serve a frontier-grade reasoning model on its own infrastructure, the first wall is GPU memory. Loading 753B parameters in 16-bit demands close to 1.5TB, which means multiple GPU nodes. Released on Hugging Face on June 25, 2026, `nvidia/GLM-5.2-NVFP4` quantizes ZAI's (zai-org) GLM-5.2 to 4-bit in an attempt to lower that wall.

This is not an introduction to GLM-5.2 itself. How the model's reasoning-token length reshapes the self-hosting cost math is covered in the [reasoning-token economics post](https://thakicloud.github.io/en/llmops/glm-5-2-reasoning-token-economics/), and 1-bit GGUF quantization for consumer hardware in the [Unsloth GGUF post](https://thakicloud.github.io/en/llmops/unsloth-glm-5-2-1bit-gguf/). This post looks at the data-center track: what structure NVIDIA's official NVFP4 quantization chose, on what hardware it serves, and what it means for an operator running multi-tenant serving.

Every accuracy figure here is an official measurement published in NVIDIA's model card. The 753B model is Blackwell-only and requires 8-way tensor parallelism, so we could not reproduce it in ThakiCloud's development environment. This post is therefore an analysis grounded in public material — we did not invent any reproduction numbers. Figures that vary across sources are marked `[est.]`.

## Overview

`nvidia/GLM-5.2-NVFP4` is a version of ZAI's `zai-org/GLM-5.2` quantized with NVIDIA Model Optimizer (ModelOpt). The base model is a Mixture-of-Experts (MoE) architecture for reasoning and coding, with 753B total parameters of which only 40B are activated per token. Its network architecture is `GlmMoeDsaForCausalLM`, using sparse attention with an IndexShare indexer to support context up to 1M tokens. The license is MIT, the same as the base model, allowing both commercial and non-commercial use.

The crux in one sentence: **MoE reduces compute, selective NVFP4 quantization reduces memory, and the accuracy-sensitive parts are deliberately left out of quantization.** Thanks to the MoE structure, even at 753B the per-token compute is limited to the 40B active experts. NVFP4 then drops the routed-expert weights — which make up the bulk of the memory footprint — from 16-bit to 4-bit, while leaving the shared expert un-quantized in BF16 to minimize accuracy loss.

The timing matters. A strong open-weight model shipping under MIT lines up with NVIDIA re-releasing that model, optimized for its own hardware, in a directly servable form. For organizations weighing model sovereignty, this is not an abstract policy issue but an immediate architecture choice: which GPU runs what, and how.

## What the model is

GLM-5.2 is a MoE reasoning-and-coding model from ZAI. Unlike a typical dense model, it places multiple expert networks inside each transformer block and activates only a subset per input token. GLM-5.2 holds 753B total parameters, but only 40B actually participate in generating a given token. Its "knowledge capacity" is in the 753B class, while its inference compute is closer to a 40B dense model.

On top of that, GLM-5.2 uses sparse attention with an IndexShare indexer. The design supports a 1M-token context while avoiding the cost of full attention that compares every token pair. The model card labels this architecture `glm_moe_dsa` and requires `transformers>=5.3.0` to run. These two layers of sparsity — MoE sparsity and attention sparsity — combine to deliver frontier-grade reasoning at relatively economical compute, which is GLM-5.2's starting point.

NVFP4 is a 4-bit floating-point data type defined by NVIDIA. The key is that it is floating point, not 4-bit integer. Concretely, it packs small floating-point (E2M1) values in blocks of 16 and attaches an FP8 (E4M3) scale per block — block-wise two-level scaling. Because each block tracks its own dynamic range, it preserves the tails of the distribution far better than plain integer quantization. NVIDIA states clearly in the model card that this is not a model it trained from scratch but a quantized version of a third-party model, produced with the open-source NVIDIA Model Optimizer.

## The key is "selective" quantization

![Diagram of the GLM-5.2-NVFP4 selective quantization strategy and serving path](/assets/images/nvidia-glm-5-2-nvfp4-diagram.png)
*Only the linear operators of the routed MoE experts are quantized to NVFP4; the shared expert and attention remain in BF16.*

The most important design decision in this model is "what was NOT quantized." Quoting the model card directly: "Only the weights and activations of the linear operators within transformer blocks in MoE experts are quantized. The shared expert is not quantized." In summary:

- **Quantized to NVFP4 (4-bit)**: the weights and activations of the routed MoE experts' linear operators. Since this is where most of the 753B parameters live, nearly all of the memory savings come from here.
- **Preserved in BF16 (16-bit)**: the shared expert and the IndexShare sparse-attention path. These are traversed by every token, so they have a large impact on accuracy.

The strategy is reasonable because of how MoE parameters are distributed. Routed experts are numerous and dominate the total parameter count, yet each token uses only a few of them. The shared expert and attention, by contrast, hold a smaller share of parameters but are traversed by every token. So "aggressively 4-bit where there is a lot that is sparsely used, precisely 16-bit where there is little but it is always used" is a sound trade-off that captures both memory and accuracy. The selective quantization is the root cause of the accuracy table staying nearly loss-free.

Calibration used NVIDIA's Nemotron-family datasets. The model card names Nemotron-SFT-Instruction-Following-Chat-v2, Nemotron-Science-v1, Nemotron-Competitive-Programming-v1, Nemotron-SFT-Agentic-v2, Nemotron-Math-v2, Nemotron-SFT-SWE-v2, and Nemotron-SFT-Multilingual-v1 as calibration data. The mix spans reasoning, science, coding, agentic, math, and multilingual, aligned with the nature of the evaluation benchmarks.

## Published benchmarks: accuracy vs FP8

![Bar chart comparing the FP8 baseline and NVFP4 benchmark scores](/assets/images/nvidia-glm-5-2-nvfp4-results.png)
*Public measurements from the nvidia/GLM-5.2-NVFP4 model card. The baseline is GLM-5.2-FP8.*

The accuracy comparison NVIDIA published in the model card is below. Notably, the baseline is not BF16 but the already-compressed `GLM-5.2-FP8`. In other words, this is the harder question of "how much does 4-bit lose relative to a model already reduced to 8-bit," rather than "relative to the uncompressed original."

| Benchmark | baseline (FP8) | NVFP4 |
|---|---|---|
| GPQA Diamond | 89.52 | 89.39 |
| SciCode | 49.85 | 49.04 |
| IFBench | 74.95 | 75.81 |
| AA-LCR | 69.38 | 70.13 |
| τ²-Bench Telecom | 97.9 | 98.25 |

Measurement settings were temperature 1.0, top_p 0.95, with max_new_tokens 100000 for GPQA Diamond and 64000 for the rest. AA-LCR was measured with SGLang; the others with vLLM. The five benchmarks evaluate graduate-level scientific reasoning (GPQA Diamond, 448 questions), scientific coding (SciCode), instruction following (IFBench), long-context recall (AA-LCR), and agentic tool use (τ²-Bench Telecom), respectively.

GPQA (−0.13) and SciCode (−0.81) dropped slightly, while IFBench (+0.86), AA-LCR (+0.75), and τ²-Bench Telecom (+0.35) were actually higher under NVFP4. 4-bit beating 8-bit may seem counterintuitive, but differences of this magnitude are safer read as sampling-variance noise than as quantization loss. The core message is that "compressing FP8 one more step to 4-bit keeps accuracy essentially flat," which is a direct result of the selective quantization strategy described above.

## Deployment: vLLM and SGLang

This checkpoint officially supports the SGLang and vLLM runtimes, requires NVIDIA Blackwell hardware, and runs on Linux. Because NVFP4 tensor cores exist only in the Blackwell generation, the inability to use this 4-bit path directly on earlier GPUs is an important constraint. The SGLang serving command the model card provides is:

```sh
pip install -U "transformers>=5.3.0" && \
python3 -m sglang.launch_server \
    --model nvidia/GLM-5.2-NVFP4 \
    --tensor-parallel-size 8 \
    --quantization modelopt_fp4 \
    --tool-call-parser glm47 \
    --reasoning-parser glm45 \
    --trust-remote-code \
    --chunked-prefill-size 131072 \
    --mem-fraction-static 0.80
```

A few signals to read here. `--tensor-parallel-size 8` means the model assumes a node of 8 GPUs, not a single one. `--quantization modelopt_fp4` tells the runtime to recognize the NVFP4 format that ModelOpt produced. `--chunked-prefill-size 131072` chunks the prefill when handling the 1M context to prevent memory spikes, a value that governs stability in long-context serving. `--tool-call-parser glm47` and `--reasoning-parser glm45` parse the GLM-family tool-call and reasoning-token formats, which connect directly to agentic workloads.

On memory, a rough estimate: serving 753B in BF16 needs about 1.5TB [est.]. Since routed experts dominate the parameter count and are dropped to 4-bit, the actual weight memory falls to roughly one-third, landing in a range loadable on a single 8-way tensor-parallel node (community NVFP4 mirrors report about 1.37TB → 459GB, roughly 3× [est.]). Because the model card does not state the exact GB before and after quantization, this memory figure carries an `[est.]` mark. What is unambiguous is that the `--tensor-parallel-size 8` command itself indicates that "8 Blackwell GPUs can serve a 753B reasoning model with a 1M context."

## Applying it to ThakiCloud's K8s AI/ML SaaS platform

ThakiCloud runs a multi-tenant platform that schedules GPUs with Kueue on K8s and serves models with vLLM. In this environment, a pre-quantized frontier checkpoint like `nvidia/GLM-5.2-NVFP4` matters in three ways.

First, **the pool of serving candidates widens.** A 753B-class reasoning model is usually dropped early from self-hosting consideration, but if 4-bit quantization fits the weights plus KV headroom onto a single 8-GPU Blackwell node, on-premise self-serving becomes a realistic option. Using Kueue's ResourceFlavor and ClusterQueue to carve out a Blackwell node pool dedicated to NVFP4 inference, the memory headroom won through quantization translates directly into the number of tenants served concurrently. For customers who cannot send data out to external APIs — especially public-sector and finance where self-hosting and data sovereignty are required — keeping frontier reasoning in-house is itself a competitive edge.

Second, **you don't have to run the quantization pipeline yourself.** Calibrating and quantizing 753B with ModelOpt demands significant GPU time and engineering. If we can take an NVIDIA-validated checkpoint and put it straight onto vLLM/SGLang, we can focus resources on multi-tenant routing, autoscaling, and cost observability rather than quantization validation. That said, ThakiCloud's skill system already has an in-house workflow that quantizes the Qwen3-MoE family to NVFP4, so the recipe NVIDIA applied to GLM-5.2 — "experts to 4-bit, shared expert and attention in BF16" — becomes a general pattern we can borrow directly when quantizing customer domain models ourselves.

Third, **selective quantization is worth folding into our model-adoption criteria.** The principle this model demonstrated — "aggressive where there is a lot that is sparse, conservative where it is always used" — applies as-is when we quantize other MoE models in-house. Rather than simply crushing the whole thing to 4-bit, whether the shared expert and attention are preserved can become a checklist item in our model-adoption gate. The Blackwell-only constraint, however, is tied directly to our GPU pool composition, so the adoption roadmap must state that using the NVFP4 path presupposes securing Blackwell nodes.

## Limitations and counterpoints

The biggest limitation is **hardware dependency.** The NVFP4 4-bit path presupposes Blackwell tensor cores, so environments with only earlier generations (Hopper H100/H200) cannot realize this checkpoint's benefits as-is. The narrative that "4-bit makes it cheap" holds only when Blackwell nodes are already secured or planned, and indeed presupposes new capital expenditure.

Second, **the scope of the benchmarks.** The model card's accuracy table is limited to five benchmarks, all close to English-language reasoning, coding, and agentic tasks. Real-world multilingual quality including Korean, and recall stability when the 1M context is filled to the brim, cannot be concluded from the public table alone. A separate evaluation on our own domain data — measuring regression against BF16/FP8 — is essential before adoption.

Third, **the uncertainty of the memory figures.** As noted, the model card does not publish exact memory GB before and after quantization. The memory estimate in this post is back-calculated from parameter counts and the quantization scope, so in actual deployment, adding the KV cache and 1M prefill buffers makes the effective per-node memory larger than the weights-only estimate. Operational planning must be based on peak memory, not weight memory.

Fourth, **the two sides of selective quantization.** Leaving the shared expert and attention in BF16 protected accuracy, but it also makes the memory saving smaller than "everything in 4-bit." That is, this model chose "compression that protects accuracy," not "maximum compression." For an extreme cost environment aiming to fit it on a single workstation GPU, a more aggressive 1-bit GGUF trade-off fits better (at lower quality).

In summary, `nvidia/GLM-5.2-NVFP4` is a case of pulling a frontier-grade 753B MoE reasoning model down to 4-bit with no accuracy loss, making self-serving on a Blackwell 8-GPU node a realistic option. From ThakiCloud's perspective, it adds one more card for offering frontier reasoning to customers with on-premise and data-sovereignty requirements, and an occasion to fold the general principle of "selective quantization" into our model-adoption criteria. That door, however, opens only with a Blackwell key.

## Sources

- [nvidia/GLM-5.2-NVFP4 · Hugging Face](https://huggingface.co/nvidia/GLM-5.2-NVFP4)
- [Base model GLM-5.2 (ZAI) · Hugging Face](https://huggingface.co/zai-org/GLM-5.2)
- [NVIDIA Model Optimizer · GitHub](https://github.com/NVIDIA/Model-Optimizer)
- [Inference-Optimized Checkpoints with Model Optimizer (collection) · Hugging Face](https://huggingface.co/collections/nvidia/inference-optimized-checkpoints-with-model-optimizer)
