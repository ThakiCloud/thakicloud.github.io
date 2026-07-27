---
title: "Does a Reasoning-Effort Label Actually Cut Compute? What Qwen3-8B Showed Us"
excerpt: "We attached reasoning-effort control to Qwen3-8B and measured it. A soft length reward does not make the label gate compute (1.1x), but it did make the model globally more token-efficient. Here is why it fails and the hard-budget (LCPO) fix."
seo_title: "Reasoning-Effort Label and Token Control, Measured - Qwen3-8B GRPO - Thaki Cloud"
seo_description: "Effort-conditioned SFT+GRPO on Qwen3-8B: the label does not gate compute (1.08-1.28x vs 1.8x target), but yields a Pareto token-efficiency gain. The correctness-reward-dominance mechanism and the LCPO hard-budget fix."
date: 2026-07-27
last_modified_at: 2026-07-27
tags:
  - reasoning-effort
  - token-budget
  - grpo
  - lcpo
  - qwen3-8b
  - rlvr
  - inference-cost
  - reinforcement-learning
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
---

If you serve reasoning models and want to dial tokens per response, which is to say cost and latency, the practical question is whether a single "reasoning effort" label can gate compute. We wired this onto Qwen3-8B directly, and the common approach of a soft length reward barely moves the needle. What we did get was an unexpected payoff, and a clear reason for the failure.

## What we did

We put `Reasoning effort: low|medium|high` in the system prompt and trained the model to match reasoning length to that label. First supervised fine-tuning (SFT) on reasoning data balanced across length tiers, then GRPO reinforcement learning with a length-adherence reward on top. We evaluated on the hard math set MATH-500 and the easy arithmetic set GSM8K, sweeping a token budget from 256 to 4096 while recording both accuracy and the actual generated tokens.

Our bar for "control" was low versus high spending at least 1.8x more tokens, roughly the effort dial that the o1 and o3 families demonstrate.

## Result one: the label does not gate compute

| model / eval | low | med | high | separation | acc (low→high) |
|---|---|---|---|---|---|
| Base Qwen3-8B / MATH-500 | 2887 | 3132 | 3268 | 1.13x | 0.66 → 0.64 |
| Trained (SFT+GRPO) / MATH-500 | 2332 | 2463 | 2516 | 1.08x | 0.69 → 0.68 |
| Trained / GSM8K | 1173 | 1296 | 1502 | 1.28x | 0.95 → 0.92 |

Separation lands at 1.08x to 1.28x, well short of the 1.8x target. On MATH the trained model's separation (1.08x) is even below the untrained base (1.13x). A soft length reward only nudges the label; it does not turn it into a dial for compute.

## Result two: but the model got more efficient

The label-conditioned separation failed, yet the same training raised global token efficiency by accident. Accuracy per budget on MATH-500 looks like this.

| budget (tokens) | base acc | trained acc |
|---|---|---|
| 1024 | 0.31 | 0.41 |
| 2048 | 0.535 | 0.575 |
| 4096 | 0.63 (3118 tok) | 0.69 (2451 tok) |

At a 4096 budget the trained model is 6 points more accurate while spending about 670 fewer tokens. Every tier got shorter regardless of the effort label, with accuracy held or improved. The length training did not attach to the label; it made the whole model more concise instead. For serving that is a welcome side effect: you hit more at the same budget, or reach the same accuracy for less.

## Why it did not attach to the label

Reading the reward design gives the answer. The reward is 1.0 for a correct answer plus 0.5 when the length is near the target, and that length term only fires when the answer is correct. On a hard MATH problem, answering short usually means answering wrong, and a wrong answer scores 0, so the length term disappears. That is why the model keeps reasoning long even when you ask for "low". The dial only bites where the model can be both correct and short, which is exactly why GSM8K (1.28x) separates more than MATH (1.08x). On hard tasks the correctness reward overwhelms the length reward, and that single fact is the root reason a soft length reward cannot inject effort control.

## The fix: a hard budget, not a soft nudge

If the cause is correctness-reward dominance, the fix is clear. Stop making the length term contingent on correctness, and turn the effort label into a hard cap on compute. This is LCPO's hard-budget formulation. You set a budget per label (low 256, medium 1024, high 3072 tokens) and reward correctness only within that budget; overshoot decays the reward in proportion, reaching 0 at twice the budget. Now "low" only earns a score if the model finishes short, so it learns to answer fast and give up some accuracy at low effort, and to think only at high effort. That is precisely the lever the mechanism above predicts.

This is already implemented (`grpo_l1.py --lcpo`); the rerun to a converged separation number continues as GPU capacity frees up.

## Takeaway

A soft length reward does not turn a "reasoning effort" label into a compute dial. It does make the model globally more token-efficient, hitting more per budget and reaching the same accuracy for less. To make the label a real dial you have to change the reward from a nudge into a hard budget, and the justification is the observation that on hard problems correctness beats length.

These numbers are not simulated; they come from training Qwen3-8B on a real H200 and measuring on MATH-500 and GSM8K (seed 1234).
