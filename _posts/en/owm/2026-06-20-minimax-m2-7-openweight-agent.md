---
title: "MiniMax-M2.7: 229B Open-Weight Agent Model, 113 Quantization Variants, and License Considerations"
excerpt: "MiniMax's M2.7 offers 229B parameters, FP8 support, and 113 quantization variants, providing a wide range of on-premises deployment paths. It claims agent team collaboration and self-evolution, but the license is classified as 'other' and must be read before any commercial deployment."
seo_title: "MiniMax-M2.7 229B Open-Weight Agent Model Self-Hosting Guide - Thaki Cloud"
seo_description: "MiniMax-M2.7 architecture, benchmarks (MLE Bench Lite 66.6%, SWE-Pro 56.22%, GDPval-AA ELO 1495), SGLang/vLLM/NIM serving methods, and license considerations explained."
date: 2026-06-20
last_modified_at: 2026-06-20
categories:
  - owm
tags:
  - minimax-m2-7
  - minimax
  - openweight
  - fp8
  - agent-model
  - sglang
  - vllm
  - nvidia-nim
  - self-hosting
  - quantization
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/en/owm/minimax-m2-7-openweight-agent/"
lang: en
reading_time: true
---

⏱️ **Estimated reading time**: 7 min

![MiniMax-M2.7 self-evolving agent teams concept](/assets/images/minimax-m2-7-hero.png)

## MiniMax-M2.7 Overview

This is the model released by MiniMax as `MiniMaxAI/MiniMax-M2.7`. It has 229B total parameters and supports three dtypes: F32, BF16, and FP8 (F8_E4M3). Native FP8 support provides memory efficiency and throughput advantages on the latest NVIDIA GPUs (H100, H200, Blackwell family).

The license is classified as "other." If you intend to use or commercially deploy this model, you must read the full LICENSE text directly.

## Architecture

Detailed MoE structural parameters for M2.7 (number of experts, active experts, attention mechanism, context length) are not explicitly stated in the public model card. The main publicly available information is the 229B total parameter count and FP8 support.

Two characteristics are emphasized in the model card. First, agent team functionality: multiple agents with distinct role identities collaborate and make autonomous decisions. Second, a self-evolution claim that the internal version underwent over 100 autonomous optimization rounds. These figures come from the model developer and should be verified against actual tasks rather than taken at face value without independent confirmation.

Tool use is explicitly supported.

## Benchmarks

Numbers from the HF model card:

| Benchmark | MiniMax-M2.7 |
|---|---|
| MLE Bench Lite | 66.6% |
| SWE-Pro | 56.22% |
| SWE Multilingual | 76.5 |
| Multi SWE Bench | 52.7 |
| VIBE-Pro | 55.6% |
| Terminal Bench 2 | 57.0% |
| NL2Repo | 39.8% |
| GDPval-AA ELO | 1495 |
| Toolathon | 46.3% |
| MM Claw e2e | 62.7% |

The developer claims GDPval-AA ELO 1495 is the highest among open-weight models. GDPval-AA is a benchmark specialized for agent tasks; the actual meaning requires direct comparison with other publicly available models.

SWE-Pro 56.22% and SWE Multilingual 76.5 are solid numbers for code agent tasks. NL2Repo at 39.8%, which covers natural language based repository manipulation, is on the lower side.

MM Claw e2e at 62.7% reflects multimodal agent task performance and is a useful reference for pipelines that process image and text together.

## Serving and Deployment

### Supported Frameworks

- **SGLang** (recommended framework)
- **vLLM** (tensor parallelism)
- **Transformers** (HF)
- **NVIDIA NIM** (immediate deployment on DGX/HGX on-premises)
- **Docker Model Runner** (container-based)
- **OpenAI-compatible API** provided

### Quantization Variants

113 quantization variants are registered on HF Hub. This is the highest count among the four models reviewed here. Formats including GPTQ, GGUF, AWQ, EXL2, and FP8 are covered, making it possible to find a starting point for nearly any inference framework and hardware combination.

### Inference Parameters

Default parameters recommended in the model card are temperature 1.0, top_p 0.95, and top_k 40. For agent tasks, starting with these defaults before experimenting is recommended.

### Hardware Requirements

229B in BF16 requires approximately 458 GB of VRAM, which means 6 or more H100 80GB GPUs. Using FP8 cuts this roughly in half. The NVIDIA NIM path lets you bring the optimized serving stack directly to DGX systems, reducing initial setup overhead.

## ThakiCloud Perspective

Two things stand out as most practically useful with M2.7.

**113 quantization variants provide best-in-class on-premises path variety.** The number of variants covers almost every configuration from consumer-grade GPUs up to DGX-class systems. Regardless of what GPU inventory a team has, finding a starting point should not be difficult. Deploying via NIM to a DGX/HGX environment means no separate serving stack configuration is required. Testing lightly on a development machine using Ollama or llama.cpp variants is also straightforward.

**License "other" is a required check before commercial on-premises deployment.** The term "open-weight" does not mean free for commercial use. A license classified as "other" is a signal that conditions differ from standard classifications such as MIT, Apache, or Llama Community. If you plan to attach this model to a commercial service or deploy it internally at the enterprise level, the LICENSE text must be reviewed together with your legal team. Technical evaluation and license review should proceed in parallel, with the latter completed before deployment.

Agent team collaboration and self-evolution capabilities should be verified directly in actual use cases. Benchmarks and developer descriptions alone are not enough to understand how the model behaves in real workflows. A practical approach is to validate first with a small quantized version at the prototype stage, then estimate the hardware scale needed for production.
