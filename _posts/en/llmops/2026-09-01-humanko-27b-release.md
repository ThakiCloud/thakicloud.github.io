---
title: "Open Weights for a Korean 27B That Doesn't Sound Like an AI"
excerpt: "A 27B that used to bury every answer under bullet lists now defaults to short, flowing Korean prose. It wins 94.9% of pairwise judgments against its own base model, with no detectable capability regression. A small team got there on a few in-house GPUs — that part matters as much as the numbers."
seo_title: "Qwen3.8-27B-Human-KO Released: De-AI-fied Korean Open Weights"
seo_description: "We release a 27B with the AI tells (bullet walls, thousand-character answers, machine cadence) removed at the weight level. 94.9% pairwise wins, 0.33% CJK contamination, no detectable capability regression. Built by a small team on in-house infrastructure."
date: 2026-09-01
published: true
categories:
  - llmops
tags:
  - korean
  - open-weights
  - style-alignment
  - qwen
  - human-ko
author_profile: true
toc: true
toc_label: "Table of Contents"
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/humanko-27b-release/"
---

![Concept image for the Human-KO 27B open-weights release](/assets/images/humanko-27b-release-hero.webp)

Ask a modern model something in Korean and you usually get the same shape back: a heading, eight bullets, an opening of "here is the following," and a thousand characters of it. The content is fine. It just does not read like a person wrote it. Today we are releasing a 27B whose habits were changed at the weight level. You can download it and use it as is.

## Plain terms

If you want to fix a student's answering habits, there are two ways: correct every answer with a red pen, or change the textbook. We changed the textbook. We rewrote what the model learns from into the kind of writing we wanted, so this model speaks that way **natively** — no output filter, no post-processing. This textbook picture carries through the rest of the article.

## What changed

No system prompt, no instructions — 200 questions, free generation.

| | Base Qwen3.8-27B | Human-KO |
|---|---|---|
| Answers formatted as bullet lists | 97.5% | **2.0%** |
| Median answer length | 1,326 chars | **220 chars** |
| Human-likeness pairwise (n=175) | 1.1% wins | **94.9% wins** (ties 4.0%) |
| Han characters leaking into Korean (n=3,369) | 2.55% | **0.33%** |
| Coding accuracy (HumanEval) | 93.9% | no difference (+3.0pp) |
| Instruction following | 81% | statistically equivalent |

The model is here: [ThakiCloud/Qwen3.8-27B-Human-KO](https://huggingface.co/ThakiCloud/Qwen3.8-27B-Human-KO)

The human-likeness verdicts come from an LLM judge comparing anonymized pairs. Swapping the answer order and asking again produced 96% consistent verdicts, so the win rate is not an artifact of position. The judge is still not a human, and we say so plainly — a human evaluation panel is the next step.

The Han-character axis reflects the vocabulary surgery covered in [our previous article](https://thakicloud.com/tech-blog/en/llmops/humanko-cjk-vocab-prune/). Style and hygiene live in a single set of weights.

## What it took to get here

The details of the process are our asset, so this article does not spell them out. Instead, here are the two moments where the direction changed. For a team doing similar work, these matter more than any recipe.

**First, we inspected the textbook before blaming the model.** Our first training run appeared to do nothing. The cause was neither the model nor the method: the textbook we had built was nearly identical to what the base model already wrote. A textbook that reads like the student's current answers teaches nothing. When we redesigned it from a blank page, the same model, same method, and same data volume produced the table above. Data is the ceiling; the model goes exactly as far as its textbook.

**Second, when comparisons kept coming back tied, we suspected the scale, not the model.** For a while, nothing we trained could be distinguished from the base. It turned out our serving engine had been silently ignoring the training artifacts — no errors — and we had been comparing the base model to itself. Only after finding that defect did any number above mean anything. If your A/B keeps landing on a tie, check the scale before you check the model.

## A small team can do this

This was not built by a large lab. A small team finished it on a few in-house GPUs, without buying a single piece of external data. The training corpus is fully synthetic, so there is no license exposure, and benchmark datasets were used for evaluation only. The final training run took less than an hour.

Most of the cost was not GPU time. It was the experiments and the measurement discipline needed to decide what to build: the failed runs, the voided measurements, the textbook redesign. Put the other way around — for a team with its measurement in order, the barrier to this kind of work is lower than it looks. It is a different species of work from pretraining a foundation model.

The infrastructure underneath was our own product stack: training and merging ran through Maxis, teacher generation and evaluation serving ran on Metis. This article doubles as a field report for both.

## Where it fits

It fits anywhere short, natural Korean should be the default: customer support, internal chatbots, messenger-style products — places where answers go out in a human register. If your workload is long reports and structured documents, specify length and format in the prompt, because this model's default is short prose.

The more interesting fit is **teams that need a model with their own voice**. What we validated is not one particular style, but that putting a chosen style into the weights is feasible at small-team scale. The same pipeline with a different textbook produces a different company's model.

## What not to trust yet

Plainly: the human-likeness judge is still an LLM. We re-measured Korean knowledge on item-paired sets — 2,000 KMMLU and 500 HAE-RAE questions, identical items for both models — and neither axis showed a statistically distinguishable difference. Even at that sample size, a 1pp-level regression sits below the detection floor, so the honest reading is still "not detected," not "no regression." The floor for Han-character leakage is structurally above zero. Every comparison in the table above is against base Qwen3.8-27B alone; a head-to-head against another Korean model, on identical items under identical conditions, is covered in [a separate article](https://thakicloud.com/tech-blog/en/llmops/humanko-27b-vs-exaone/).

The weights are up. The most accurate judgment is the one you form by running it yourself.

## References

- Model: <https://huggingface.co/ThakiCloud/Qwen3.8-27B-Human-KO>
- Han-character contamination article: <https://thakicloud.com/tech-blog/en/llmops/humanko-cjk-vocab-prune/>
