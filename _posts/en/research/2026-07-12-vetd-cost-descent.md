---
title: "Validate Expensive, Then Descend: Cutting a Skill Fleet's Model Cost with Code Gates"
excerpt: "When a company's recurring work is defined as skills, each skill can tell you, through measurement rather than intuition, exactly how far down the model tier it can go. The most expensive model isn't for doing the work, it's for judging whether a cheaper one can. This is a real operating record of a 16-skill fleet where 10 skills were pushed down to a mid tier."
seo_title: "VETD - Cutting LLM Costs by Validating Expensive, Then Descending to Cheaper Tiers - Thaki Cloud"
seo_description: "An operating method for defining company work as skills, judging quality with opus, and letting a code gate decide whether to descend to sonnet. We share real fleet-wide descent and hold decisions across 16 skills, including the failures."
lang: en
date: 2026-07-12
last_modified_at: 2026-07-12
canonical_url: "https://thakicloud.github.io/en/research/vetd-cost-descent/"
reading_time: true
tags:
  - LLM-cost-optimization
  - model-routing
  - model-cascade
  - LLM-as-judge
  - agent-skills
  - format-determinism
  - LLMOps
  - cost-engineering
author_profile: true
toc: true
categories:
  - research
---

## The problem isn't the model, it's the assignment

Automate enough work with LLMs and you keep running into the same dilemma. The smartest model is the safe default for accuracy, but it costs five to twenty times more than its smaller siblings. Most of the work you've automated doesn't actually need that much capability.

Take a one-person automation fleet as an example: a research paper writer that runs every night, a morning standup digest, a sales CRM briefing, a market monitor, a blog improver, a deployment pipeline, each wired up as a single skill. As the number of skills grows, the monthly model bill grows with it, and that bill is dominated by a handful of workflows pinned to the most expensive tier.

The naive solution is to run everything on the frontier model. That's what our fleet did at first, and it didn't scale. At one point a single sales workflow, running both orchestration and content writing on the frontier tier, accounted for roughly 94% of monthly model spend on its own. Run everything on the cheapest model instead, and the outputs that genuinely need capability quietly get worse. That degradation stays invisible until a person notices it weeks later.

The real question differs skill by skill, and it can only be answered by measurement, never by intuition. **For this skill, under this prompt and this scaffolding, what is the cheapest tier whose output doesn't meaningfully degrade from the frontier model's?** Answer that question by gut feeling and you'll get it wrong. Answer it once and it won't hold, because prompts, skills, and models all keep changing.

Here's the method we use across our fleet. We call it **VETD, Validate-Expensive-Then-Descend**: validate with the expensive model first, then descend only as far as the code allows.

## Four commitments

VETD rests on four core commitments.

First, validate with the expensive model first. The frontier tier's output is the quality baseline. We never assume a cheaper tier is good enough; we actually measure the gap against the best output available.

Second, descend only under a gate the code owns. Whether to accept a cheaper tier is decided by deterministic code applying an explicit rubric, never by a model claiming its own output "looks fine." Models are used only to generate content and score it along defined dimensions; the arithmetic of pass and fail belongs entirely to code.

Third, hold quality with code rather than tier wherever possible. Many skills keep their quality after descending because format, count, and validation are owned by a deterministic post-processor. Wherever a descent is safe, it's usually those guardrails doing the work, not the model.

Fourth, route capability that can't be descended, don't fake it. When the gate refuses a descent because of a genuine capability gap, that skill stays pinned to the expensive tier. We don't pretend a cheaper model is sufficient when the evidence says otherwise.

## What the loop looks like

The full flow has five stages.

![VETD loop]({{ '/assets/images/vetd-cost-descent-loop.png' | relative_url }})

First there's the skill fleet, which is the unit of optimization. A single skill is a directory holding a prompt contract, scripts and templates, and a scheduled runner. A central policy registry records, per skill, the current tier, whether it's pinned, the consecutive failure count, and a human-readable reason for that tier.

Next comes the tier sweep. Given a target skill and a fixed set of input fixtures, it runs headless, once per tier, and collects the outputs. The frontier output becomes the baseline.

Then comes judging. A judge running on the frontier model scores each tier's output against rubric dimensions on a scale of one to five, and produces a structured gap object for the cheapest candidate under test. That gap splits into an overall headline_gap, a fixable gap recoverable through prompt edits, and a reasoning gap where the cheaper tier is structurally short. Critically, the judge only produces these labels and scores. It never decides whether to descend.

Finally there's the deterministic gate. Code approves a descent only when three conditions all hold: headline_gap is at or below the threshold, the reasoning gap is zero, and the fixable gap is zero. There are three possible outcomes. If all three hold, it descends. If headline_gap is fine but a fixable gap remains, the skill gets fixed and re-measured. If there's a reasoning gap, or headline_gap exceeds the threshold, the skill is held or pinned.

## Why quality survives the descent

For a descent to be safe, the cheaper tier's content has to be good enough, and format has to be caught somewhere else. Our fleet's flagship descent survived on exactly this principle. It was a skill that posts a timeline digest five times a day, pinned to the frontier tier and eating a large chunk of quota.

Before descending, we refactored the skill first. Per-item workers now emit content only, and a deterministic validator computes the quality gate in code. Minimum body length, minimum source count, web-search evidence count, and an AI-writing-tell gate are all recalculated by code, and any item that fails gets redispatched. Headers, formatting, and deduplication belong to a separate poster. Only after format was owned by code did we move this skill from opus down to sonnet. The reason logged in the policy is unambiguous: quality is preserved by format-determinism guardrails, not by model tier.

## How the fleet split

![Fleet composition and the descent gate after applying VETD]({{ '/assets/images/vetd-cost-descent-fleet-gate.png' | relative_url }})

After applying VETD, 10 of 16 skills run on the mid tier. The 6 that remain on the frontier tier are, precisely, the ones where content itself is the deliverable rather than format: humor, editorial judgment, research prose, creative angles. That's the pattern VETD surfaces: orchestration and format-centric work descends, while irreducible content-quality work stays put.

The sales CRM skill wasn't descended wholesale; it was split instead. The main conductor, responsible for orchestration, was moved down to the mid tier, while the subagent that writes customer- and deal-facing content stayed on the frontier tier. The bulk of the cost, coordination, descends, while the thin, high-value slice of prose stays where it is.

## When the gate says no

Not every skill descends. We re-measured two skills live tonight. A report-validation skill came back with a headline_gap of 1.4 and two reasoning gaps. A standup digest skill came back with a headline_gap of 2.4 and two reasoning gaps, in factual grounding and analytical depth. Both were held by the gate, and the code's recommendation in both cases was the same: move the format gaps into code first, then re-measure.

Earlier, a Korean AI-writing-tell remover skill came in at a headline_gap of 2.0, well over the threshold, carrying three fixable gaps alongside one reasoning gap. That, too, was held. In this case the correct VETD output isn't a descent, it's a work order: close the three fixable gaps through skill edits and measure again.

This part matters. A system that only ever descends is broken. The gate has to be able to say no. Systems under pressure to cut cost drift toward descending everything, and tonight's two live measurements, plus the humanizer skill's hold, are exactly the gate holding its ground against that pressure.

## The failure that actually hurt

The lesson that stuck came not from a descent but from a promotion. In early July, several skills auto-promoted to the frontier tier because they'd logged repeated "bad runs." But those bad runs were actually weekly quota exhaustion, not quality failures. The runs themselves finished cleanly; a limit marker in the log got miscounted as a failure.

The fix was to make the failure classifier treat quota and auth exhaustion as neutral. Since it isn't a capability failure, it no longer increments the consecutive-failure count. The lesson generalizes: **the signals that drive promotion and descent must distinguish capability failure from availability failure.** Fail to make that distinction, and the loop ends up optimizing against noise.

## Honest limits

This method has clear boundaries.

We only measure skills that have fixtures. In practice, "the whole company" really means "the subset with fixtures," and that subset grows only as fast as we add fixtures. Skills without fixtures get only half the loop, the promotion half that reacts to failures, not the descent half. To be candid, this is a methodology and a partial rollout, not proof that every workflow is cost-optimized.

Measurement isn't free, since the judge runs on the frontier tier. So we don't run it on every production call; we run it per skill, only when the skill or the model changes, to spread the cost. A single fixture also can't represent the full input distribution. A skill that's safe to descend today could still degrade on inputs the fixtures never captured.

Prompts, skills, and model versions all drift. A descent valid today can become invalid after an upstream model swap. The registry records the reason and a promotion loop catches regressions, but this needs continual re-validation, not a one-time pass.

## In one sentence

VETD treats model-cost reduction as a measurement and gating problem, not a modeling problem. Validate with the expensive tier first, confine the expensive model to judging rather than doing the work, and let deterministic code own both the pass gate and, wherever possible, the output format. Do that and one person can push most of a 16-skill fleet down to a mid tier while keeping the few skills that genuinely need capability on the frontier tier. And the loop caught the one time it mistook a quota outage for a quality failure.

The portable takeaway compresses to a single line: **spend your best model finding the places it's no longer needed.**

---

*The methods and figures in this post are drawn from ThakiCloud's actual automation fleet operations. A written-up paper draft is also available as a [PDF]({{ '/assets/papers/vetd-cost-descent-2026-07-12.pdf' | relative_url }}).*
