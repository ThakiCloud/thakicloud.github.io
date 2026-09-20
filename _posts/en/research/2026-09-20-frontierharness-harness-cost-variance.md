---
title: "Same Model, 17.5x Invoice: Why FrontierHarness Exposes the Hidden Variable in Coding Agents"
seo_title: "FrontierHarness Eval analysis - a coding-agent benchmark that fixes one model (Kimi K3) and varies 9 harnesses, showing pass rates of 50.0 to 66.7 percent and per-completed-task costs of $1.05 to $18.34, a spread of up to roughly 17.5x. The context of MiniMax Code CLI going MIT open source and self-reporting 76.7 percent on FrontierHarness. Implications for ThakiCloud Metis serving optimization and the Paxis harness layer - ThakiCloud"
seo_description: "When you evaluate a coding agent with one model held fixed, the only remaining variable is the harness. Runta's FrontierHarness Eval v1.0 holds Kimi K3 fixed and runs 9 harnesses, 12 configs, and 30 tasks (360 evals), showing pass rates of 50.0 to 66.7 percent and per-completed-task costs of $1.05 to $18.34, a spread of up to about 17.5x. Read why the hidden variable in coding agents is the harness, up to the boundary where MiniMax Code CLI's open source self-reports 76.7 percent, from a ThakiCloud perspective."
excerpt: "Hold one model fixed and the only variable left in a coding agent is the harness. FrontierHarness shows that on the same Kimi K3, pass rates of 50.0 to 66.7 percent and per-completed-task costs of $1.05 to $18.34, a spread of up to about 17.5x, come from the harness. And the boundary where MiniMax Code CLI's open source self-reports 76.7 percent on that same benchmark."
date: 2026-09-20
last_modified_at: 2026-09-20
tags:
  - frontierharness
  - coding-agent-harness
  - agent-eval
  - cost-variance
  - harness-engineering
  - minimax-code
  - benchmarking
  - research
  - metis
  - paxis
categories:
  - research
author_profile: true
toc: true
toc_label: "Contents"
canonical_url: "https://thakicloud.com/tech-blog/en/research/frontierharness-harness-cost-variance/"
---

This post is for platform engineers who run coding agents or who answer for their cost, and for teams deciding whether a coding agent is worth adopting. When you evaluate a coding agent with one model held fixed, the only remaining variable is the harness. But that one variable spreads pass rate by 17 percentage points and per-completed-task cost by up to about 17.5x on the same model. The reason you should set "how do we choose the harness" with the same weight as "which model do we choose" is what this post gives you.

The starting point is Runta's FrontierHarness Eval v1.0 (September 1, 2026). It holds one model (Kimi K3, Fireworks-served) fixed and varies only the harness across 9 kinds, and the headline is that quality, cost, and speed diverge sharply by harness choice. And MiniMax Code CLI went MIT open source the same week (around September 18, 2026), citing that benchmark. The week where a benchmark's finding and a product's self-report overlap is the frame for this post: read both together.

![Same Model, 17.5x Invoice: why FrontierHarness exposes the hidden variable in coding agents, abstracted](/assets/images/frontierharness-harness-cost-variance-hero.webp)
*An abstraction of the post's core concept.*

## In plain terms

Think of buying the same engine and fitting it to several chassis. The horsepower is identical. But one chassis tunes that engine for 200 km/h cruising, another for hard acceleration, and another for fuel economy. Measure the engine and they all read the same horsepower, yet "fuel per kilometer" differs by several times depending on the chassis. In a coding agent, the model is the engine and the harness is the chassis. It is easy to believe that the same model means similar quality, but what FrontierHarness measures is fuel economy, that is, the cost and time per completed task. And fuel economy is set by the chassis, not the engine.

## Overview

FrontierHarness Eval is a coding-agent benchmark built on the axis of "model fixed, harness varied." The design is simple. Fix a single model (Kimi K3) served by Fireworks, vary the coding-agent harness across 9 kinds, the configuration across 12, and the tasks across 30 (Terminal-Bench 2.1, 21, plus DeepSWE v1.1, 9), for 360 evals total. The model stays put; only the apparatus wrapping it changes, and the experiment measures which indicators move.

Why this axis matters is that coding-agent discussion tends to get stuck on "which model is stronger," when the variable that actually drives the invoice sits outside the model. To separate whether a vendor's SOTA is due to the model or to the harness that runs it, you must hold the model fixed and vary the harness. FrontierHarness is the experiment that sets up exactly that fork.

## Same model held fixed, invoice still 17.5x

Per Runta's v1.0 report, on the same Kimi K3, changing the harness spreads the indicators this way.

| Axis | Range | Note |
|---|---|---|
| pass rate | 50.0% to 66.7% | 17pp spread; quality roughly comparable across harnesses |
| cost per completed task | $1.05 to $18.34 | up to about a 17.5x spread |
| completion speed | median 5m41s (DSH Minimal), etc. | varies by harness |

Two things to read here. First, quality (pass rate) clusters in the 50 to 67 percent band, which suggests "the harness does not change quality much." But cost per completed task runs from $1.05 to $18.34, a 17.5x spread in the invoice for the same quality. The report's examples are the quality leader (Codex, 66.7%), the balanced pick (Pi, 60.0% at $2.43 per pass), the low-cost pick (Exo Harness, $1.05), and the fastest (DSH Minimal, median 5m41s); on the same model, "what you prioritize" brings a different harness to the front.

That is the real finding. The harness is not a variable of quality; it is a variable of the cost and speed of the same quality. While quality holds roughly steady, the harness choice moves the invoice by up to 17.5x. The reason "choosing the model" and "choosing the harness" cannot be read on the same cost axis is right here.

## MiniMax's 76.7%: the self-report, and its boundary

The same week, MiniMax Code CLI went MIT open source at v0.4.12. It is a coding-agent CLI with plan mode, sub-agents, plugins, and media/search tools; the repo is github.com/MiniMax-AI/minimax-code. MiniMax self-reports that on FrontierHarness, over 30 tasks (Kimi K3), it scores a 76.7% pass rate with a median success-run completion time of 4m33s, fastest average completion, and near-lowest token use.

Here the boundary must be clear. 76.7% is outside the 50.0 to 66.7% range Runta's v1.0 official report states. In other words, that number is MiniMax's self-report, not a value confirmed under the same conditions as the official report's public baselines. How the benchmark version, conditions, and serving setup differ is unverified. So this post treats 76.7% not as "SOTA fact" but as "a vendor's self-report citing the same benchmark."

Why the distinction matters is that this post's own subject is "the harness, not the model, is the variable." If MiniMax Code CLI scores 76.7% on FrontierHarness, much of that number is likely to come not from MiniMax's model but from the harness design wrapping it. The FrontierHarness finding that a 17.5x cost gap comes from the harness is the lens for checking MiniMax's self-report. The best control group for the claim "our harness is strong" is exactly this benchmark.

## The structure: where the harness becomes the variable

The diagram below shows this axis. The model is held to one (Kimi K3), and on top of it 9 harnesses move all three axes of pass rate, cost, and speed. The shape of FrontierHarness is that the quality axis moves narrowly while the cost and speed axes move widely.

```mermaid
flowchart TB
  M[(fixed model<br/>Kimi K3, Fireworks-served)] --> H[harness layer<br/>9 x 12 configs]
  H --> T1[pass rate<br/>50.0 to 66.7%]
  H --> T2[cost per completed task<br/>$1.05 to $18.34]
  H --> T3[completion speed<br/>median 5m41s, etc.]
  T1 -.narrow range.-> Q[quality roughly comparable]
  T2 -.wide range 17.5x.-> C[invoice set by the harness]
  T3 -.varies by harness.-> L[speed set by the harness]
```

What to watch in the diagram is the direction of the arrows. Quality, passing through the harness, moves narrowly; cost and speed, passing through it, move widely. On the same model, what decides "which agent is expensive and slow" is the harness layer, not the model. The reason ThakiCloud should move its agent-serving-cost optimization target from model selection to harness selection is written right into this diagram.

## ThakiCloud lens: Metis's serving optimization and Paxis's harness layer

ThakiCloud reads this finding at the intersection of two products.

Metis lens (primary). FrontierHarness' "same model, harness 17.5x" is the same problem as the serving-cost optimization Metis solves. What Metis serves is the model, and the execution apparatus wrapping it (context handling, tool calls, caching, batching) is the harness. When you serve the same model on Metis, how you build that execution apparatus sets the per-token unit cost and completion speed; that is the same direction as the 17.5x external validation. The ThakiCloud whitepaper has already measured that serving configuration (compilation, batch caps, KV cache) governs throughput and unit price, and FrontierHarness confirms, on the coding-agent axis, that this governance lives "outside the model." Metis's advantage in on-prem and sovereign environments, building that execution apparatus yourself, means replacing an external vendor's 17.5x harness variance with a cap on your own cluster.

Paxis lens (complement). Paxis' Skill Harness, isolated sandbox, policy gate, and audit log treat the harness layer itself as a first-class resource. If FrontierHarness measures that the harness is the variable of cost and speed, Paxis is on the side of "managing that variable as a first-class resource." A 17.5x gap arising from harness design means that, in enterprise agent operations, standardizing, measuring, and controlling the harness layer is invoice control. The reason Paxis should handle skill selection, execution isolation, and cost accounting on one plane is the direction this finding confirms externally.

## Limits and counterarguments

First, FrontierHarness is an experiment with a single model (Kimi K3) held fixed. If the model changes, the size of the "harness variance" can change too, and this 17.5x is a value measured on Kimi K3. On another model, the harness's cost governance may be stronger or weaker.

Second, 30 tasks and 360 evals is a size that cannot be claimed to represent the whole coding-agent distribution. It relies on the combination of the two benches, Terminal-Bench 2.1 and DeepSWE v1.1, and if the task difficulty distribution is skewed to a certain area, the cost range may be over-represented for that area.

Third, MiniMax's 76.7% is a self-report outside the official report's range. This post does not cite that number as fact; it uses it only as a lens for verification. Placing a vendor's self-report on the same weight as a benchmark's finding is exactly the error this post draws a boundary against.

Fourth, care is needed on whether pass rate and cost measure "the same quality." If the $1.05 harness is only "slightly" lower in quality than the $18.34 harness, comparing that fine quality gap on the same axis as a 17.5x cost is risky. FrontierHarness's rationale should be checked together for how it compensates that fine quality difference, and this post does not verify that correction in full.

## So what can you change

Three things you can apply right after reading.

One, do not set your coding-agent benchmark as "model comparison" only. Before adoption, run a minimal experiment that holds one model fixed and varies the harness across 2 to 3 kinds, measuring cost per completed task and completion speed. The 17.5x is visible only on a harness benchmark, not a model benchmark.

Two, widen the invoice-optimization target from model selection to harness selection once more. In ThakiCloud's Metis, treating serving configuration (context, cache, batch) as an optimization target, and in Paxis, treating execution isolation and cost accounting as one, is the direction FrontierHarness confirms with "outside the model is the variable."

Three, attach a control group to a vendor's SOTA self-report. If MiniMax's 76.7% is outside the official report's range, the control that asks "was it re-measured under the same conditions" comes first. A large win margin is not a celebration; it is a warning to check what the baseline actually is.

The hidden variable in coding agents is the harness, not the model. FrontierHarness confirmed that variable with a 17.5x invoice, and MiniMax leans on that benchmark to push its own harness forward. ThakiCloud's Paxis already sits on that same battlefield as a first-class resource of the harness layer.

## Sources

- [Introducing FrontierHarness Eval (Runta)](https://runta.com/blog/introducing-frontierharness-eval/)
- [FrontierHarness Eval repository (GitHub)](https://github.com/frontier-harness-eval/eval)
- [MiniMax Code (GitHub, MIT)](https://github.com/MiniMax-AI/minimax-code)
- [X - @RyanLeeMiniMax (hjguyhan RT)](https://x.com/hjguyhan/status/2101310154574893554)
