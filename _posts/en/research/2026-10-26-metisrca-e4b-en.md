---
title: "MetisRCA-E4B: A 4B-Class Root-Cause Model That Cites Evidence or Steps Back"
excerpt: "For teams attaching root-cause analysis to agents. MetisRCA-E4B, a LoRA on Nemotron 3.5 Bolt E4B, reaches 0.873 top-1 on a held-out set and cuts unsupported diagnoses to 0.3%. The limits are reported alongside."
seo_title: "MetisRCA-E4B Root-Cause Analysis Model - ThakiCloud"
seo_description: "For teams attaching root-cause analysis to agents. MetisRCA-E4B, a LoRA on Nemotron 3.5 Bolt E4B, reaches 0.873 top-1 on a held-out set and cuts unsupported diagnoses to 0.3%. The limits are reported alongside."
date: 2026-10-26
published: true
categories:
  - research
tags:
  - Nemotron
  - Bolt E4B
  - LoRA
  - RCA
  - Small Language Model
  - Paxis
author_profile: true
toc: true
toc_label: "Table of Contents"
lang: en
permalink: /en/research/metisrca-e4b/
canonical_url: "https://thakicloud.github.io/en/research/metisrca-e4b/"
---

This is for teams attaching root-cause analysis to agents. MetisRCA-E4B reaches 0.873 top-1 on a held-out set and cuts unsupported diagnoses to 0.3%. On failure mechanisms it has never seen it trails a same-size Qwen3.5-4B, and it abstains unnecessarily on about 15% of determinable cases.

## What Nemotron 3.5 Bolt E4B is

Bolt E4B is a small language model NVIDIA post-trained from Gemma-4-E4B-it. It has 8B total and 4B effective parameters and up to 64K tokens of input and output. NVIDIA strengthens multi-turn tool use, instruction following and input grounding, and trains with GRPO reinforcement learning. Low memory and low time-to-first-token are the design goals, which suits local assistants and edge devices. The license is OpenMDW-1.1, and a separate 4GB Q4_K_M build is published. The BF16 release is meant for customization, so we used it as our base.

## How it was built

![Pipeline from the BF16 base to GGUF](/assets/images/posts/research/bolt-specialists/pipeline-en.svg)
*Figure 1. The two yellow stages keep scores honest. Label generation and leakage checks belong to code, not to a model.*

We ran LoRA SFT on the BF16 weights: rank 16, alpha 32, adapters on 258 linear layers across the attention and MLP text path, learning rate 2e-4, 2 epochs. Gold labels come from code, and we ran leakage and lineage checks between train and evaluation sets. The model reads incident evidence and names a root cause. When evidence is insufficient it answers `INSUFFICIENT_EVIDENCE` and asks for the next tool, in a read-only role.

## Measured results

We compared three models with identical prompts and decoding. Each row pairs values measured on the same evaluation rows.

| Evaluation | MetisRCA-E4B | Qwen3.5-4B | Bolt base |
|---|---|---|---|
| Held-out set overall (1,566 cases), root cause top-1 | 0.873 | 0.694 | 0.619 |
| Never-seen mechanisms (783 rows), top-1 | 0.784 | 0.814 | - |
| Cloud-OpsBench, determinable never-seen mechanisms, top-1 | 0.783 | 0.831 | 0.764 |

On the overall held-out set, evidence F1 is 0.82 and unsupported diagnoses are 0.3%, against 7.3% for Qwen3.5-4B. The gap is larger in behavior than in accuracy. Stepping back when evidence is thin is what this adapter is for.

## Calibration: an abstain policy

The repo ships an inference-time abstain policy, `abstain_policy.py`, with the same weights. The threshold of 1.5 was chosen on validation only and applied once to the test set.

| Never-seen mechanisms (783 rows) | Greedy | Calibrated |
|---|---|---|
| Root cause top-1 (Qwen3.5-4B 0.814) | 0.784 | 0.824 |
| Over-abstain | 15.3% | 9.4% |
| Correct abstain | 78.7% | 73.6% |
| Unsupported diagnoses | 0.26% | 0.26% |

The pre-registered gate of over-abstain below 5% was not met. On the 360 determinable Cloud-OpsBench rows, compared like for like, greedy gets 282 right, calibrated 298 and Qwen3.5-4B 299, one row ahead. Top-1 on the whole held-out set rises from 0.873 to 0.897. Under llama.cpp the GGUF behaves like greedy v4, because calibration needs transformers. The Q4_K_M GGUF (5.34 GB) keeps top-1 0.9697 on the seen split, the same as BF16.

## Honest limits

On never-seen failure mechanisms Qwen3.5-4B scored higher under greedy decoding, and we do not claim the calibrated model finds new causes better. Its strength is evidence grounding and abstention. About 15% of determinable cases end in an abstention. The adapter tends to stop rather than invent a cause, which is the safer failure for an agent, but a new class of incident needs a path to a larger model or a person.

## How to use it in Paxis

Paxis is ThakiCloud's platform for automating enterprise work with AI agents. What follows is a design direction, not a shipped feature. MetisRCA-E4B sits as a read-only RCA step. It cites evidence ids for a cause, or abstains and requests the next tool it needs.

![Pre-check in front of agents and a read-only RCA step](/assets/images/posts/research/bolt-specialists/paxis-flow-en.svg)
*Figure 2. The model proposes and code holds permission. The RCA step is read-only, so an abstention leads to a request for the next tool.*

If an abstention leads to one more lookup by the agent, the roughly 15% over-abstention costs one extra tool call. Unfamiliar incident types go to a larger model or a person. Which remediation runs is decided by a permission check outside the model, not by this model.

## Get the model

- MetisRCA-E4B: https://huggingface.co/ThakiCloud/MetisRCA-E4B
- Collection: https://huggingface.co/collections/ThakiCloud/thakicloud-bolt-e4b-specialists-6ade97db98b0258cb49447a0
