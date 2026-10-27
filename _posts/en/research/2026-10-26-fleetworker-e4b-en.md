---
title: "FleetWorker-E4B: A 4B-Class Task-Board Classifier and a Recipe for Training on Your Own Board"
excerpt: "For teams that want to train a small model to sort task-board items by project. A reference model on Nemotron 3.5 Bolt E4B and the recipe for retraining on your own board."
seo_title: "FleetWorker-E4B Task-Board Classifier - ThakiCloud"
seo_description: "For teams that want to train a small model to sort task-board items by project. A reference model on Nemotron 3.5 Bolt E4B and the recipe for retraining on your own board."
date: 2026-10-26
published: true
categories:
  - research
tags:
  - Nemotron
  - Bolt E4B
  - LoRA
  - Task Triage
  - Small Language Model
  - Paxis
author_profile: true
toc: true
toc_label: "Table of Contents"
lang: en
permalink: /en/research/fleetworker-e4b/
canonical_url: "https://thakicloud.github.io/en/research/fleetworker-e4b/"
---

This is for teams that want to train a small model to sort task-board items by project. FleetWorker-E4B is a reference model and a recipe rather than a drop-in product. To keep internal names out of the released weights, we retrained on 25 descriptive, generic work-stream names (for example synthetic-data-pipeline and legal-decision-models).

## What Nemotron 3.5 Bolt E4B is

Bolt E4B is a small language model NVIDIA post-trained from Gemma-4-E4B-it. It has 8B total and 4B effective parameters and up to 64K tokens of input and output. NVIDIA strengthens multi-turn tool use, instruction following and input grounding, and trains with GRPO reinforcement learning. Low memory and low time-to-first-token are the design goals, which suits local assistants and edge devices. The license is OpenMDW-1.1, and a separate 4GB Q4_K_M build is published. The BF16 release is meant for customization, so we used it as our base.

## How it was built

![Pipeline from the BF16 base to GGUF](/assets/images/posts/research/bolt-specialists/pipeline-en.svg)
*Figure 1. The two yellow stages keep scores honest. Label generation and leakage checks belong to code, not to a model.*

We ran LoRA SFT on the BF16 weights: rank 16, alpha 32, adapters on 258 linear layers across the attention and MLP text path, learning rate 1e-4, 2 epochs. The input is a to-do item and the output is JSON with a project and a priority. Gold projects are the ones the board owner assigned, and only explicitly set priorities are used for training, so the model does not imitate the board default. Evaluation uses independent items the training run never saw.

## Measured results

The released weights contain no internal project names. A code check found 0 residual names, a leak probe found 0 of 130, and none of the 1,077 test outputs contained an internal name.

On an independent set of 206 items created after the training cut-off, project accuracy is shown below. How the labels are named drove the result. The model matches label names against item text, so replacing them with opaque ids (proj-NN) loses 16.5 points, and descriptive names recover 13 of them. On a larger 594-item test, project accuracy was 0.589.

| Model | Project accuracy (206 items) |
|---|---|
| Base model | 0.296 |
| v1 | 0.495 |
| Internal-name model (not released) | 0.563 |
| Opaque ids proj-NN (not released) | 0.398 |
| Released model (descriptive aliases) | 0.529 |

Priority only means something on items a person explicitly prioritised. On 55 such items it scores 0.600 against a majority baseline of 0.364, but on 243 items it is 0.543 against 0.527, barely different. On items that were never prioritised it answers P0 for 120 of 151, so use the project field only.

Quantized builds keep accuracy. GGUF Q4_K_M (5.34 GB), Q4_K_M-NV and Q8_0 all match BF16 exactly.

## Honest limits

Priority is a suggestion only. Scores that count the board default as truth cannot be compared, and when measured on human-set priorities alone the margin over the majority baseline varied widely between evaluation sets. A prior-correction trick at inference time also failed its pre-registered criterion. Use project classification, and do not apply priority automatically. Project labels differ from board to board, so these weights will not transfer as-is, which is why we recommend retraining on your own board.

## How to use it in Paxis

Paxis is ThakiCloud's platform for automating enterprise work with AI agents. What follows is a design direction, not a shipped feature. FleetWorker-E4B sits in a triage step that routes incoming board items to per-project queues. The project label is attached only as a suggestion that a person confirms, and it works well as a starting point for fine-tuning on your own board. Priority is neither shown nor applied automatically, and items the classifier is unsure about go to human review. The model is small enough to run on a machine where the board data never leaves.

![Pre-check flow in front of agents](/assets/images/posts/research/bolt-specialists/paxis-flow-en.svg)
*Figure 2. The model proposes and code holds permission. Classification output is also separate from execution rights.*

## Get the model

- FleetWorker-E4B: https://huggingface.co/ThakiCloud/FleetWorker-E4B
- Collection: https://huggingface.co/collections/ThakiCloud/thakicloud-bolt-e4b-specialists-6ade97db98b0258cb49447a0
