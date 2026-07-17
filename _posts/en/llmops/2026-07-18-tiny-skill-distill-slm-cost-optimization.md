---
title: "Distilling Skills into Tiny Models: 3.6× Cheaper, Measured On-Prem"
excerpt: "We moved the LLM-bound worker sub-tasks of our agent skills onto sub-1B, 4-bit fine-tuned models running fully on-premises. Real before/after across 6 tasks on Qwen3.5-0.8B and Gemma, plus joint multi-task, quantization degradation, LoRA vs full fine-tune, and the honest limits — with a public, reproducible repo."
date: 2026-07-18
tags:
  - SLM
  - LoRA
  - QLoRA
  - Quantization
  - OnDevice
  - Distillation
  - CostOptimization
  - OnPremises
  - Qwen
  - Gemma
author_profile: true
toc: true
toc_label: Skill Distillation
published: true
categories:
  - llmops
  - dev
---

## TL;DR

You don't need to run an entire agent skill on a frontier model. Build the skill with a large model, freeze the deterministic parts (formatting, routing, aggregation) as code, and for the narrow classification / tagging / matching workers that genuinely need a language model, **fine-tune a small model (≤1B params, 4-bit)** and wire it in. That worker then runs on-prem, and the large model is reserved for real judgment and creativity. This post verifies that claim with measurements, not predictions. All code and results are in the public repo: [tiny-skill-distill](https://github.com/sylvanus4/tiny-skill-distill).

The intended readers are engineers who want to know how to actually build and validate a tiny specialized model, and platform owners who want to cut frontier-API cost structurally.

## Why we ran this

When you operate agent skills, the same large model does two very different jobs. One is genuine judgment and writing. The other is repetitive, narrow adjudication: "is this request safe?", "which category is this news?", "what formality level is this sentence?" The second kind is high-volume and has a small answer space. Calling a frontier model for it every time is expensive, and it forces data to leave your environment.

So the question is simple. If we move that narrow worker onto a tiny model, how much cost can we save while keeping the quality? And can we do it ourselves, on on-prem GPUs?

## Setup

We compared three models under identical conditions: Qwen3.5-0.8B-Base (~753M), Gemma 3 270M, and Gemma 3 1B. All were fine-tuned with QLoRA — LoRA rank 16 on the q/k/v/o projections, over a 4-bit nf4 quantized base. The environment was a single NVIDIA A40 (48 GB), CUDA 12.4, PyTorch 2.6, with **no external API calls at any stage of training or inference**. That is the point: the whole pipeline runs inside one GPU, on your own hardware.

There are six tasks: four modeled on skill workers (Korean 5-level formality classification, a content safety gate with SAFE/WARNING/BLOCKED, IT/cloud news categorization into 6 classes, paper relevance as a binary filter) and two public benchmarks for external validity (NSMC sentiment, KLUE-YNAT news topic). The skill-worker training data comes from reproducible rule/template generators, with test sets held out from training.

## Result 1: Per-skill distillation

We first attached one adapter per skill and compared baseline (few-shot) to post-fine-tune. Each skill trained in 10–40 minutes, and the adapter was only about 5 MB.

On Korean formality, Qwen 0.8B rose from 38.6% to 99.1%, and Gemma 270M from 20% to 80%. On news categorization, Gemma 270M jumped from a near-random 1.7% few-shot to 70%, and Gemma 1B from 33% to 82.8%. On narrow, well-defined workers, tiny models leap.

But there is a result we must report honestly too. On NSMC sentiment, Qwen 0.8B already scored 75.5% few-shot, and a naive 1-epoch LoRA dropped it to 52.4%. Piling hasty fine-tuning onto a general task the big model already handles well can hurt. Distillation is not something you do everywhere — you pick the tasks. That single sentence is, in fact, the most important lesson here.

## Result 2: Does it actually follow the skill?

We went one step further. If you train on synthetic templates and evaluate on synthetic templates, good numbers are trivial. So we added a separate fidelity eval. We collected natural sentences (not templates), labeled their gold answers by having a large model apply the real skill rubric twice independently and keeping only the consensus, then measured how well the tiny model agreed with that gold — in accuracy and Cohen's κ.

The results split honestly. On Korean formality, Qwen 0.8B went from 27.5% to 65% on natural inputs, κ 0.56. On the safety gate, from 64% to 88%, κ 0.82. On paper relevance, both Qwen and Gemma 1B reached 90% with κ 0.8. The 99% seen on synthetic templates comes down to 42–90% on natural inputs. That gap is the honest reality: synthetic training does replicate much of the real skill's judgment, but not perfectly. We publish both numbers side by side.

## Result 3: Can one model do it all?

The most practical question was this: instead of a separate adapter per skill, if we train a single adapter on all skills combined, does per-skill performance hold? With LoRA you can swap adapters anyway, so it doesn't matter — but a full fine-tune cannot. So this experiment decides whether "one model runs the whole fleet."

Training one Qwen 0.8B adapter over all four skills, natural-input agreement was 62.5% formality, 76% safety, 100% news, 90% paper. Against the specialists' 65%, 88%, 89%, 90%, the degradation is negligible. One 0.8B model handles four workers at once. In contrast, merging Gemma 270M the same way showed clear interference. The smaller the capacity, the higher the tax for cramming multiple tasks into one model.

In short, LoRA keeps both options open: hot-swap N specialist adapters on one base, or merge into a single generalist. A full fine-tune forces the generalist, and N skills mean N full model copies. That flexibility is why we reach for LoRA first in on-prem operation.

## Result 4: Quantization and deployment

We evaluated the same fine-tuned model at fp16, int8, and int4(nf4). Accuracy was 98%, 97.8%, and 99.5% — effectively unchanged (the slight rise at the end we treat as noise) — while peak GPU memory fell from 1656 MB to 925 MB, nearly halved. INT4 loses almost no accuracy while sharply cutting memory, which is favorable for on-device deployment.

The comparison with full fine-tuning was decisive. On Korean formality, full fine-tuning trained all ~700M parameters to reach 96.9%, with a 1438 MB artifact in 63 minutes. LoRA trained 0.14% of that (1.08M params) to reach 99.1%, a 5 MB adapter in 37 minutes. LoRA matched full fine-tune quality with a 300× smaller artifact — and it hot-swaps.

## Result 5: Cost

Finally we measured money. We timed the on-prem 4-bit worker's classification throughput and generation speed, computed the cost per 1,000 calls at the A40 hourly rate, and compared it to a frontier-API estimate. On-prem was about $0.117 per 1,000 calls versus $0.423 estimated for the API — about 3.6× cheaper. This is single-stream; batching and continuous batching widen the on-prem advantage. Note that the API figure is a labeled estimate with stated assumptions, not a quote.

## What this sells

What the experiment proves is simple. Design the skill with a large model, then pick only the LLM-bound repetitive workers and distill them into tiny models — a few-MB adapter then does that job on commodity on-prem GPUs. The large model gets lighter and focuses on the judgment and creativity that actually matter. Cost goes down and data stays in.

We avoid the hype. We do not claim "270M beats 70B." Our claim is limited to narrow worker tasks, and the same data shows that choosing the wrong task makes fine-tuning harmful. So we publish the good numbers and the bad ones together.

The full code, data generators, teacher-labeled gold sets, and per-run result JSON are reproducible at [github.com/sylvanus4/tiny-skill-distill](https://github.com/sylvanus4/tiny-skill-distill).
