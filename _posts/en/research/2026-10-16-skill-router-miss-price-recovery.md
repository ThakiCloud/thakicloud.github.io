---
title: "The Miss Price: What One Miss Costs When the Skill Router Is Wrong. Break-Even Accuracy and the Recovery Lever in Unattended Loops"
seo_title: "The Miss Price paper introduction - Skill routers have been judged only on whether a route was right or wrong, and this paper prices the downstream loop cost of a single routing miss. It presents the miss multiplier m, the post-miss recovery rate ρ and the 4-mode recovery taxonomy S·F·E·N, a forced-miss intervention protocol (gold hidden, frozen degraded top-1 swap, abstention control) with preregistered falsification criteria R1-R5, and a closed-form break-even routing accuracy α* = 1-(c_R1-c_R2)/Δ. Under the declared nominal rate card (c_E=$1/task, c_R1=0.01c_E, c_R2=0.002c_E, m1=1.8, m2=2.2, ρ1=0.6, ρ2=0.5), hybrid→quantized needs α*=0.984, frontier→hybrid 0.92, and router removal 0.99: routing must be near perfect for the savings to offset the misses. The recovery lever ∂α*/∂ρ2 < 0 shows that post-miss recovery engineering buys downgrade headroom directly - ThakiCloud"
seo_description: "Prices a single skill-router miss in an unattended loop. Miss multiplier m, 4-mode recovery taxonomy S·F·E·N, recovery rate ρ, closed-form break-even routing accuracy α*. On the declared nominal rate card, a downgrade to a cheaper router tier is a net plus only at accuracy above 92-99%, and recovery engineering is the cheapest accuracy lever."
excerpt: "Earlier research priced what the router computes; this paper prices what the router gets wrong. recall@k and top-1 report a miss rate, not a miss price. We lay out the three objects that turn a single routing miss into a price and the 92-99% wall a router downgrade must clear."
date: 2026-10-16
last_modified_at: 2026-10-16
tags:
  - skill-router
  - miss-price
  - agent-recovery-rate
  - forced-miss-intervention
  - break-even-routing-accuracy
  - unattended-automation
  - token-cost-attribution
  - sra-bench
  - h200-serving
categories:
  - research
author_profile: true
toc: true
toc_label: "Contents"
canonical_url: "https://thakicloud.com/tech-blog/en/research/skill-router-miss-price-recovery/"
---

Because one wrong choice costs far more than the choice to make it. This post introduces the ThakiCloud paper that prices the cost that lands after a skill router picks the wrong skill. If you are a Korean cloud or AI engineer choosing the router tier of an LLM agent loop, or managing its token spend, read this before you swap routers. The core is one line: switching to a cheaper router is not cheaper. The savings offset the mistakes only when routing is near perfect. On the declared rate card, a downgrade pays off only above 92-99% accuracy.

The paper is titled The Miss Price: Measuring the Downstream Cost of Skill-Router Misses and the Agent's Recovery Rate in Unattended Loops on Self-Hosted H200. Why is that? Because a cheaper router makes more mistakes and more expensive ones. And because this is an analytic paper. There is not a single new measurement. Every number is a closed-form prediction on the declared nominal rate card, or a result from cited literature.

![Illustration of the core idea of The Miss Price: What One Miss Costs When the Skill Router Is Wrong. Break-Even Accuracy and the Recovery Lever in Unattended Loops](/assets/images/skill-router-miss-price-recovery-hero.webp)
*A visual metaphor for the article's key idea.*

## In plain terms

Think of the dispatch desk at a delivery company. Dispatch assigns orders (tasks) to couriers (skills). Dispatch gets 95 out of 100 right. But the 5 misassignments are not free. The courier gets lost in front of the wrong address. The route is replanned and a redelivery follows. If one misassignment eats several times the dispatch operating cost, that accuracy is an expensive number.

Dispatch evaluations have only ever reported the misassignment rate, and recall@k and top-1 in retrieval metrics do the same. A rate speaks. A price does not. This paper asks about the gap in between: what does one misassignment actually cost?

The paper introduces three things. The first is the price of one misassignment, the miss multiplier. The second is the rate at which a courier finds the right address again on their own after a miss, the post-miss recovery rate. The third is the accuracy wall above which a cheap dispatch finally pays off, α*.

Lures are worth a second look. A near lure is a similar building in the same alley, and it keeps a courier wandering longer. A far lure is in a different district, and the courier notices the mistake quickly. A cheap dispatch's candidate pool pulls in more confusing addresses, so the same miss can cost more. That combination: m2 > m1.

## What we did

The three objects become formulas. The miss multiplier m is how many times the total cost of a missed task is relative to the total cost of a hit task. m ≥ 1. Decompose m as 1 + (m-1), and (m-1) is the extra cost of rework, retries, and replanning. Quality loss is not put into m. The quality drop is carried separately by the quality function Q(α), so m stays a pure quantity of tokens and time. m depends on the triple (router tier, task, candidate pool), because a cheaper tier's pool systematically assembles worse lures. So the cheap tier's miss multiplier m2 is larger than the standard tier's m1, and recovery is weaker (ρ2 ≤ ρ1). This is the paper's core assumption.

Recovery is an execution-stage capability. A miss is not the end of the task. The loop can recover before escalation. There are four recovery outcomes. S is substitute rerouting, routing a second, different skill. F is free-form completion, the model finishing the task with no additional skill call. E is escalation. N is silence, quietly continuing. The post-miss recovery rate ρ is defined as the sum of the probabilities that an S- or F-family record meets the acceptance criterion, ρ = P(accepted | miss). E is outside ρ, because it is accepted only through a human. N is never accepted. The declared nominal ρ1 and ρ2 per tier make recovery a first-order lever.

Expected cost is computed with a hit/miss split. The expected cost per task is:

C(α) = c_R + c_E + (1-α)·[(m-1)c_E + (1-ρ)c_def + c_rec]

Here c_R, c_E, c_rec, c_def are the routing-stage cost, the hit-baseline execution cost, the expected recovery-action cost, and the defect cost of an unrecovered miss, respectively. Quality Q(α) is strictly increasing in α within a tier, so tier comparisons are done at a common hit rate α. At a common α the hit branch is identical across tiers. What separates the tiers is only c_R and the miss price (1-α)Δ. The miss price Δ, a per-miss cost penalty, composes the lure difference and the recovery difference.

Δ = (m2-m1)c_E + (ρ1-ρ2)c_def

The path to fill in the measurements is registered alongside, because the paper preregisters a forced-miss intervention protocol. It forces misses by design on gold tasks, instead of waiting for the misses that arise endogenously. The four experimental arms differ from the hit baseline only in the candidate pool, the top-1 injection, and the forced abstention. The model and the prompts, the seeds, are frozen.

A0 is the hit baseline. The correct skill is present. Natural misses are excluded to a separate ledger. A1 forces a miss by removing the correct skill from the candidate pool before routing. A2 swaps the top-1 with a fixed degraded skill from the preregistered lure set. The miss rate is the same as in arm 1; only lure quality is controlled. It is arm 2 that separates the miss price Δ from the miss rate. A3 is the control that forces the router to abstain.

![Forced-miss intervention arms on gold tasks](/assets/images/posts/research/skill-router-miss-price-recovery/fig_forced_miss_arms.webp)
*The four forced-miss intervention arms on gold tasks. Each arm differs from the hit baseline only in the candidate pool (A1, gold skill hidden), the top-1 injection from the preregistered lure set (A2, frozen degraded swap), and the forced abstention (A3). So the per-task ledger prices the miss branch directly. (Conceptual example, not a measurement)*

Per-arm, per-task accounting records the routing/execution/recovery tokens, the elapsed time, and the deterministic score g against the acceptance criterion θ = 0.75. The miss multiplier estimate is m̂ = A1/A0. Quality differences are reported separately and never mixed into m̂. The recovery rate estimate ρ̂ is the share of the S·F-family records that meet the acceptance criterion, after classifying the recovery records of A1 and A2 into {S, F, E, N}. The miss price estimate Δ̂ is read at the two preregistered lure levels in A2, near and far.

There are five falsification criteria, R1-R5. R1: the token-based m̂ must fall in the [1.2, 3.0] band. R2: ρ̂ ≥ 0.5. The declared value is 0.6. If ρ̂ < 0.3, the recovery lever is invalidated. R3 is the lure-combination criterion. Within a tier, the near-lure m̂ must exceed the far-lure m̂ by at least 20%. Across tiers, the cheap tier's m̂ must be at least 1.2 times the standard tier's, and its recovery rate no higher. R4: the measured α* must be within ±3 points of the closed-form prediction. R5: A3's per-task cost must be within ±25% of the closed-form abstention-escalation cost.

Why force it? Natural misses are endogenous. The router misses exactly where its own signal is weakest. Miss rate and task difficulty get mixed, and the (m-1)c_E increment becomes a product of the two. Forcing, that is, A1's pool removal and A2's top-1 injection, pins the miss rate by construction. Then only the lure level remains in the price change.

## What came out

The paper plugs in the declared nominal rate card of an H200-based self-hosted environment. The execution cost c_E is $1.00 per task. The standard tier's routing cost is 1% of execution, the cheap tier's is 0.2%. The frontier LLM-judge router is 5%. In human terms, routing looks like a cost of less than a pinch.

The miss multiplier is 1.8 for standard, 2.2 for cheap, 2.6 for router-omitted.

The recovery rate is 0.6 for standard, 0.5 for cheap, 0.4 for router-omitted. The escalation cost is $2.50 per case. Daily load, 500.

There are four closed-form consequences. First, swapping the standard (hybrid) tier for the quantized cheap tier. The per-case penalty Δ is 0.5, and the routing savings are 0.8% of execution cost. The wall is 98.4%.

The declared cheap-tier accuracy is 95%, 3.4 points below the wall. In human terms, the cheap dispatch that gets 95 out of 100 right has not yet cleared the wall. On the declared values, this downgrade does not pay off.

Second, moving from the frontier LLM-judge router to the standard tier. With the same Δ = 0.5 and 4% savings, the wall is 92%. The declared standard-tier accuracy of 97% clears the wall by 5 points. The same Δ blocks the first downgrade and allows the second. Downgrades are not binary; tiers are what divide them.

Third, removing the router. The router-omitted policy has Δ0 = 1.0, and the wall is 99%. At the declared accuracy of 90%, dropping the router saves $5 a day in routing-compute cost. The added miss spend is $50 a day. One number apart, the direction flips.

Fourth, the daily miss budget. The per-case miss cost at the standard tier is 1.4, that is, $1.40. The daily execution budget is $500. At 90% accuracy, $70 a day, 14%, goes out as routing errors. At 95%, $35, 7%. At 99%, $7, 1.4%. In human terms, most router-related spend is mistakes.

![Break-even versus declared accuracy by downgrade decision](/assets/images/posts/research/skill-router-miss-price-recovery/fig_breakeven_vs_declared.webp)
*The break-even accuracy against the per-case penalty Δ: α* = 1 - savings/Δ. Curve A is hybrid→quantized (savings 0.008 c_E, wall 0.984); curve B is frontier→hybrid (savings 0.04 c_E, wall 0.92). The router-removal wall is 0.99, and the three dashed lines are the declared tier accuracies 0.97, 0.95, 0.90. On the declared values, only B (frontier→hybrid) clears the wall. A and router removal fall short. (Analytic model, not a measurement)*

The wall sits between 92 and 99%. Declared routing costs are on the order of 1 to 5% of execution. At every declared accuracy, the dominant item in router-related spend is routing-error spend, not routing-compute spend. So a router downgrade is an economic decision read off the proposition with a declared or falsification-tested rate card plugged in.

The wall moves. Raise the cheap tier's recovery rate ρ2 and the wall comes down. dα*/dρ2 < 0. Improve cheap-tier recovery and you buy downgrade headroom without touching the router. Conversely, if the cheap tier's misses get more expensive, the wall goes up. dα*/dm2 > 0.

Raise ρ2 from 0.5 to 0.8, and the wall falls from 98.4% to 96%. At ρ2 = 0.6 it is around 98%, at 0.7 around 97%. The declared operating point of 95% becomes permissible at ρ2 = 0.84. In human terms, the more the courier can find the address again on their own, the sloppier the dispatch can be.

Recovery is the most elastic lever. The strength of the lever, |dα*/dρ2|, grows as ρ2 grows. The order of investment comes out too. Lure hygiene is first. Recovery (ρ2) is second, buying accuracy directly with the router budget is third, and escalation is last. Written in symbols, the order is m2 > ρ2 > α > c_H. The recovery lever costs only 0.2 per recovered miss (in execution-cost units). It is paid out only over the miss-quality part.

![The recovery lever: break-even accuracy falls as cheap-tier recovery rises](/assets/images/posts/research/skill-router-miss-price-recovery/fig_recovery_lever.webp)
*Raise the cheap tier's post-miss recovery rate ρ2, and its break-even routing accuracy falls. α*(ρ2) = 1 - 0.008/(1-ρ2). At ρ2 = 0.5 it is 0.984; at 0.8, 0.960. The declared operating point of 0.95 becomes permissible exactly when ρ2 = 0.84. (Analytic model, not a measurement)*

Once misses are priced, each of the three branches of routing gets its own declared price. A hit costs execution, a miss costs the miss price, and escalation after abstention costs the escalation price. The escalation-dominance condition c_H ≤ (m-1)c_E + (1-ρ)c_def + c_rec does not hold on the declared rate card. $2.50 > $1.40. For the average miss class, an automatic miss comes cheaper than escalation. Abstention is reserved only for high-impact tasks where the recovery probability is low and the defect is expensive, with a conditional miss penalty above 2.5 (in execution-cost units).

## What to change

For the company, that is, the ThakiCloud platform, it reads like this. The miss multiplier and the break-even accuracy tell you when to switch to the cheap tier, when to abstain, and when to hand off to a human. They also separate out the share of routing-error spend in the token factory's bill.

At the declared 95%, routing-error spend is $35 a day, 7% of the execution budget. The entire routing-compute spend at the same place is $5. The error-to-compute ratio is 7:1. In the dispatch analogy, it is a world where redelivery costs more than the dispatch rent. If the earlier paper priced what the router computes, this one prices what it gets wrong. The two have to be combined for the router budget to close.

For society, that is, small teams, the accuracy wall comes down. What unattended automation needs is a router that clears its own rate card's wall (α*). If the agent recovers cheaply, imperfect routing survives. The accuracy bar for unattended job automation, 24/7 operations, on-call, and back-office, drops. The cost floor of below-frontier router tiers drops too. On self-hosted hardware, it becomes the basis for running automation at the level of a team budget with mixed AI-human spend. The place where the human on-call line comes in as c_H is exactly that boundary.

For science, it is the first framework to causally price the downstream cost distribution of a single skill-router miss and the post-miss recovery behavior in an unattended agent loop. The miss-multiplier metric closes the gap between offline retrieval metrics and online loop costs. With a price on each of hit, miss, and abstention, the three branches of the routing decision are complete. The expected mis-routing penalty left unpriced in the reasoning-router literature is identified by this paper's miss-cost term.

## What not to trust

First, the numbers in this paper are not measured. Every value is a closed-form prediction on the declared nominal rate card, or a result from cited literature. The forced-miss protocol and the five falsification criteria are the designated path to measurement. If a future run falls outside the declared bands, the predictions are subject to re-review. The bands that would be broken are three: m̂ outside [1.2, 3.0], ρ̂ below 0.3, and α* deviating by 3 points or more.

Second, the model is linear by construction. Expected cost and quality are straight lines in α, so the wall comes out in closed form. Sequential misses in multi-step tasks and a full day of miss cascades are still unpriced territory.

Third, the tier combination is a declaration, not a theorem. Two assumptions: m2 > m1 and ρ2 ≤ ρ1. If the cheap tier's candidate pool turns out to be better constructed after deduplication or index refreshes, Δ goes negative. Then the cheap tier wins at every accuracy.

Fourth, the rate card is nominal for an H200-based self-hosted environment. API price anchoring can move c_R and c_H in magnitude but not in shape. α* depends on a single ratio, (c_R1 - c_R2)/Δ. So a common rescaling preserves every threshold.

*The three chapters of this post and all its numbers are an analytic model or a conceptual example. They are closed-form predictions on the declared nominal rate card, not measurements.*

The paper itself and its accompanying materials are available on Hugging Face.

https://huggingface.co/datasets/thaki-AI/daily-paper-2026-10-16-skill-router-miss-price-recovery
