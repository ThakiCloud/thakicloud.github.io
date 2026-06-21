---
title: "GLM-5.2 and the Open-Source RL Stack slime: Post-Training a Flagship Model in Two Days"
excerpt: "Z.ai open-sourced slime, the reinforcement-learning post-training framework it used for GLM-5.2. The entire OPD post-training of GLM-5.2 ran on slime in about two days. GLM-5.2 ships under an MIT license with a MoE+DSA architecture and a 1M-token context."
seo_title: "GLM-5.2 + slime RL Post-Training Framework On-Prem Guide - ThakiCloud"
seo_description: "GLM-5.2 architecture (MoE+DSA, 1M context, IndexShare), benchmarks, MIT license, the slime RL post-training stack (Apache-2.0), vLLM/SGLang serving, and a Kueue deployment perspective."
date: 2026-06-21
last_modified_at: 2026-06-21
categories:
  - owm
tags:
  - glm-5-2
  - zai
  - slime
  - reinforcement-learning
  - post-training
  - moe
  - long-context
  - vllm
  - sglang
  - self-hosting
lang: en
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/en/owm/glm-5-2-slime-rl-posttraining/"
reading_time: true
published: false
---

⏱️ **Estimated reading time**: 8 min

## What Is New

When we work with open-weight models, we usually only see the weights. The training stack that produced them stays inside the company. This time it is the opposite. Z.ai open-sourced `slime`, the reinforcement-learning stack it used to post-train its flagship model GLM-5.2.

Two facts matter here. First, the entire OPD (on-policy distillation) post-training of GLM-5.2 finished on this slime platform in roughly two days. Second, the code that ran that training is now on GitHub for anyone to take and use. The model and the pipeline that built it were opened together, and that pairing is the point of this release.

- slime repo: [github.com/THUDM/slime](https://github.com/THUDM/slime) (Apache-2.0, ~6,555 stars)
- GLM-5.2 model: [huggingface.co/zai-org/GLM-5.2](https://huggingface.co/zai-org/GLM-5.2) (MIT)

## slime: An RL Post-Training Framework

slime is, in its own words, an "LLM post-training framework for RL Scaling." RL-based post-training is infrastructure-heavy: large-scale distributed training, rollout generation, reward processing, and policy updates all have to mesh. That is why companies tend to build their own stack and keep it locked away.

slime opened that stack under Apache-2.0. The license matters. Apache-2.0 places almost no restriction on commercial use, modification, and redistribution, so you can drop it directly into an in-house pipeline. Because it is the infrastructure that trained a real flagship model in GLM-5.2, this is production-validated code rather than a tidied-up demo.

The "two days for OPD post-training" figure is a self-reported number from Z.ai on Twitter. There is no published spec for the hardware or data scale, so rather than treating it as an absolute speed metric, read it as a direction: with well-designed infrastructure, post-training a large model in a matter of days is realistic.

## GLM-5.2: Model Card Facts

GLM-5.2 is Z.ai's latest flagship, designed for long-horizon tasks. The key points from the model card:

- **License**: MIT. Stated as fully open with no regional limits. Unlike the bespoke community licenses common in the owm category, MIT keeps commercial deployment terms simple.
- **Languages**: English and Chinese.
- **Context**: 1M tokens. The card calls it a "solid 1M context" that stably sustains long-horizon work, not merely a supported maximum.
- **Architecture tag**: `glm_moe_dsa`. It combines a Mixture-of-Experts design with a DSA-style sparse attention.

The notable architectural piece is **IndexShare**, published as arXiv:2603.12201. It reuses the same indexer across every four sparse attention layers, which the card says cuts per-token FLOPs by 2.9x at a 1M context length. The biggest cost of long context is the attention computation, so reusing the indexer trims exactly that cost. On top of this, the MTP layer for speculative decoding was improved to raise the acceptance length by up to 20%. The GLM-5 technical report is at arXiv:2602.15763.

## Benchmarks

A selection of GLM-5.2's self-reported benchmarks from the model card, alongside GLM-5.1 and major closed models for reference.

| Benchmark | GLM-5.2 | GLM-5.1 | Claude Opus 4.8 | GPT-5.5 | Gemini 3.1 Pro |
|---|---|---|---|---|---|
| AIME 2026 | 99.2 | 95.3 | 95.7 | 98.3 | 98.2 |
| GPQA-Diamond | 91.2 | 86.2 | 93.6 | 93.6 | 94.3 |
| HLE | 40.5 | 31 | 49.8 | 41.4 | 45 |
| SWE-bench Pro | 62.1 | 58.4 | 69.2 | 58.6 | 54.2 |
| Terminal Bench 2.1 | 81.0 | 63.5 | 85 | 84 | 74 |

These are all vendor self-reported figures, so they are not independent evaluations. Still, the improvement over GLM-5.1 is clear. Terminal Bench 2.1 rising from 63.5 to 81.0 and SWE-bench Pro from 58.4 to 62.1 point to a focus on coding and agent tasks. Before any adoption, you should measure on your own tasks directly.

## Serving and Deployment

GLM-5.2 officially supports the major inference frameworks. From the model card:

- **SGLang** v0.5.13.post1+
- **vLLM** v0.23.0+
- **Transformers** v0.5.12+
- **KTransformers**, **Unsloth**
- Ascend NPU via vLLM-Ascend, xLLM, SGLang

For on-prem K8s, the realistic path is to run vLLM or SGLang as a Deployment and serve over HTTP. Because it is MoE, active parameters per token are smaller than the total, but you still have to fit all the weights in VRAM. To actually use the 1M context, you must factor in KV cache memory when tuning `max-model-len`. Start with a short context and grow it gradually.

## The ThakiCloud Perspective

**Isolating RL post-training with Kueue.** RL post-training like slime occupies GPUs for long, heavy stretches. If it contends with online serving GPUs, both slow down. On the ThakiCloud platform, we separate a dedicated GPU pool for post-training using Kueue's ResourceFlavor and ClusterQueue, and split training versus serving priority with WorkloadPriorityClass. Submit slime's distributed jobs as Kueue jobs and queuing and preemption are managed automatically within resource limits.

**Open infrastructure plus an open model equals reproducible domain specialization.** The combination of GLM-5.2 being MIT and slime being Apache-2.0 is significant. You are not limited to downloading weights and running inference; you can re-run post-training on the same infrastructure with customer-domain data. For a platform like ThakiCloud that operates agents across diverse customer environments, post-training tuned to a customer's domain becomes a competitive edge over a generic model. slime provides the foundation to reproduce that post-training step in-house.

**MIT license and on-prem requirements.** In environments where data cannot leave the premises, such as public sector and finance, a model's redistribution and derivative terms decide whether adoption is even possible. GLM-5.2's MIT license gives wide latitude here. You can serve it on on-prem K8s with vLLM/SGLang and, if needed, complete domain post-training with slime entirely inside a closed network. That said, the 1M context is resource-intensive, so the right order is to measure how much context each task actually needs before setting serving parameters.
