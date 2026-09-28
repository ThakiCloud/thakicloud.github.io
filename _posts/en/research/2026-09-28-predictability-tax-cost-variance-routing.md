---
title: "The Predictability Tax: The Price of Holding a p95 Cap in Unattended Agent Loops"
seo_title: "The Predictability Tax: Paper Introduction - A ThakiCloud paper that reads per-task LLM cost in unattended agent loops as the full distribution, not the expected value. It holds quality fixed and compares five routing policies (fixed tier, cheapest-tier-first cascade, quality-weighted learned router, variance-penalized router, budget-truncation loop) on a mean-variance frontier, isolating as the 'predictability tax' the extra average cost or quality loss that a tight p95 cap contract demands. It gives closed forms for the cascade variance decomposition (call noise and task heterogeneity, in different orders), the two payment modes (the insurance type paid in the average, the ceiling type paid in quality) and the escape bound q_esc, and for the heavy-tail phase transitions (the alpha=2 variance boundary, the alpha=1 mean boundary). On terrain A, quality up to 0.915 fits inside the contract of p95 about 5.4 with a 42% average saving, while the last 6.4 quality points make p95 jump 4.3x (from 5.38 to 22.92). A contract of p95 at most 10 is free at q*=0.90 and is paid in quality only above q_esc=0.953. An interpretive paper that lifts the FrugalGPT-style expected-cost cascade to a distribution-level target, specifying only a measurement protocol with pre-declared directional hypotheses - ThakiCloud"
seo_description: "The bill of an unattended agent loop is written in average tokens, but the budget breaks in the tail. This paper treats the per-task cost distribution as a first-class object and measures the price of a p95 cap contract as the 'predictability tax.' It gives closed forms for the two payment modes (the insurance type paid in the average, the ceiling type paid in quality) and for the alpha=2 and alpha=1 phase transitions, and shows that on terrain A the tax is a step, not a curve. All numbers come from an interpretive model; the measurement protocol is only specified."
excerpt: "Making cost predictable has a price. How much does the average cost have to rise to buy a p95 cap contract, and if even that cannot be bought, how much quality must be given up? This paper computes that price analytically."
date: 2026-09-28
tags:
  - cost-variance
  - routing-policy
  - mean-variance-frontier
  - llm-cascade
  - unattended-agent-loops
  - token-cost-predictability
  - budget-truncation
  - heavy-tailed-cost
  - agent-harness
  - cost-quality-tradeoff
categories:
  - research
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/en/research/predictability-tax-cost-variance-routing/"
---

The cost an unattended agent spends to finish a task does not break on the average. It breaks in the tail. If you run unattended agent loops, or if you are the cloud or AI engineer who owns that bill, that single line is already a design principle. ThakiCloud's paper of the day, the "predictability tax," measures that price. The question is simple. To hold a p95 cost cap, how much must the average cost rise, and if even that cannot be bought, how much quality must be given up? Those two questions are what the paper asks.

![Illustration of the core idea of The Predictability Tax: The Price of Holding a p95 Cap in Unattended Agent Loops](/assets/images/predictability-tax-cost-variance-routing-hero.webp)
*A visual metaphor for the article's key idea.*

## In Plain Terms: Earthquake Insurance

Anyone who has bought earthquake insurance knows. To keep one house standing, you pay a small premium every month. The premium is set by probability and expected value. The core of insurance design is how far up the largest earthquake you are willing to cover.

The bill of an unattended agent loop works the same way. It takes a task, picks a model, and calls it. If that fails, it retries or escalates to a higher tier. It pays for every token it touches. Since no human is in the loop, whoever owns the bill can only do the accounting in average tokens and average dollars. That is why the budget breaks in the tail. The retry storms, the errors that pile up over long horizons, the chains running from the cheapest tier to the most expensive one are exactly that tail.

The predictability tax this paper measures is the same substance as an insurance premium. It is the premium attached to the contract of a p95 cost cap, the promise that 95 percent of tasks finish inside that amount. In regions where that premium cannot be paid in money, quality must be given up instead. The coverage shrinks as the price.

## The Problem: The Bill Written in Averages

Today's accounting depends on a single expected value. Average tokens per task, average dollars, average cost per routing decision. That is all. But the place where the budget breaks is not the average. The average does not show the probability hiding in the tail.

The routing policies were designed on that same expected value. The cascade of FrugalGPT starts at the cheapest tier and escalates only when it fails. The learned router picks a tier from feature scores. The goal is to minimize expected cost. Both treat the distribution of per-task cost as a byproduct of the policy. If the average is everything, who owns the tail?

This paper promotes the entire distribution to a first-class citizen. It holds quality fixed and, for each policy, measures the average, the variance, and the character of the tail of per-task cost together, and draws the mean-variance frontier. And it isolates one object. To buy the tight cost contract of a p95 cap, how much more must be paid, and if even that cannot be bought, how much quality must be given up. That is the predictability tax.

## What It Did: The Distribution as a First-Class Citizen

The design space is filled with five policies. One axis is the fixed-tier policy that calls a single specific tier once, the cascade that climbs from the cheapest tier, and the learned router that picks a tier from a difficulty score. On top of these come a router that jointly optimizes cost and variance, and a policy that cuts the loop off at the budget cap.

The definition of the tax comes from a pair of contracts. The insurance-type tax is how much larger the cheapest average cost is, among the policies that meet a contract of quality at least q and per-task p95 at most B, compared with the average cost of the no-commitment policy. When no policy can buy it at that average cost, the tax can also be paid in quality. The gap between the maximum quality a policy whose p95 does not exceed B can reach and the target quality.

The variance of the cascade splits into two pieces. The noise of the calls themselves, and the task heterogeneity created by the different path each task takes. On terrain A, one of two tier terrains, the total variance is about 40 while the call-noise piece is under 1. What produces the tail is the difference in paths, hard tasks climbing up to the expensive tiers. In other words, it is the heterogeneity. In plain terms, the reason the bill wobbles is not the noise of the currency but the size of the earthquake.

![Standard deviation of per-task cost by routing policy (terrain A)](/assets/images/posts/research/predictability-tax-cost-variance-routing/fig1-policy-sd.png)
*The average cost of the cascade equals that of the fixed 2-tier policy (3.79). Its standard deviation is about 2.2x larger than the quality-matched fixed 3-tier policy (6.33 vs 2.86). That difference is the task-heterogeneity term H of the variance decomposition, not the call noise. (An interpretive model, not a measurement)*

The size of the tax comes out of the stop-loss identity. The average saving gained by imposing a cap is exactly equal to the integral over the tail portion. The tax is paid in two ways. When the share of tasks outside the cap is small, it is paid in average cost, the insurance type. When the share is large, it cannot be bought in average cost. It is the ceiling type, paid in quality. The criterion separating the two ways is the escape bound. A policy whose p95 does not exceed B must keep everything inside the cap except the most expensive 5 percent of tasks. The maximum quality such policies can hold is therefore the escape bound.

The behavior of the variance-penalized router is also settled. Looking at the hard tasks on terrain A, below the threshold the penalty does nothing. Past the threshold, it moves the hard tasks wholesale to the expensive tier. A half-hedge does not exist on the ceiling terrain.

## The Results: The Tax Is a Step, Not a Curve

On terrain A, hard tasks must climb all the way to the 3-tier to keep quality. On terrain B, the 2-tier is strong, so tasks barely escalate. In plain terms, terrain A is the neighborhood where earthquakes are frequent, and terrain B is the one where they are rare.

The headline for terrain A is a step. The tax is not given as a smooth curve. Up to quality 0.9, you are covered while saving 42% on the average, inside a contract of p95 about 5.4. In plain terms, in the loss band where the big insurance is not needed, the coverage was extended without paying the premium.

Covering what is above it, the price also becomes a step. The last 6.4 quality points are carried by 3-tier calls outside the cap. If all of them are given, p95 simply jumps 4.3x. The average rises sharply too. In plain terms, this is not a band where you pay one more cent of premium. It is the price of raising the entire coverage limit.

![Cap sweep of the cascade on terrain A: the average is smooth, p95 is a step](/assets/images/posts/research/predictability-tax-cost-variance-routing/fig2-cap-sweep-step.png)
*Up to quality 0.915, a contract inside p95 about 5.4 is met at an average of 2.19 (a 42% average saving against the uncapped cascade at 3.80). Giving the last 6.4 quality points in full pushes p95 from 5.38 to 22.92, a 4.3x jump, and the average from 2.19 to 3.80, up 73%. A contract of p95 at most 10 is free at the target quality of 0.90. Past the escape bound of 0.953, the tax is paid in quality only. At the ceiling boundary, the predictability tax is a step. (An interpretive model, not a measurement)*

The contract of p95 at most 10 is free at a target quality of 0.9. The capped cascade drops the average to almost one ninth of the fixed 3-tier at the same quality. In plain terms, the insurance is already in force.

Above that, it is different. Past the escape bound, about 0.95, the contract can no longer be bought in cost. Then the tax is paid in quality. To want the full ceiling of terrain A, 0.98, costs 2.6 points of quality. In plain terms, it is the value where the coverage limit ends here, and the insurer refuses when you ask for higher.

Terrain B is the other side. The 2-tier is strong, so tasks barely escalate. The share outside the cap is under 1%, so the predictability of p95 about 4.9 attaches to the cascade for free. In plain terms, in a neighborhood where earthquakes are rare, one cent of premium buys the whole coverage.

But if a tighter contract is wanted, the price is paid in quality. Raising the cap to p95 at most 1.2 makes the cascade fall back to a fixed cheap tier, and quality drops with it. On terrain A, 8.4% of tasks carry calls outside the cap. On terrain B, only 0.5%. In plain terms, the bucket in which the tax is paid, the average or the quality, is split by the terrain.

The tail exponent α sets one more cap. If α is at most 2, the variance is infinite. Then the mean-variance objective itself is undefined. The only well-defined predictability object at that point is a quantile contract such as p95. If α falls to at most 1, even the mean is infinite. Predictability cannot be bought at any finite price. It is the boundary of the retry storm. In plain terms, the frequency and the size of the earthquakes decide whether the object called an insurance premium exists at all.

![Cost of the tail cap against the Pareto tail exponent: the α = 2 boundary](/assets/images/posts/research/predictability-tax-cost-variance-routing/fig3-pareto-alpha-sweep.png)
*Under a unit-scale Pareto law, the relative stop-loss cost of the p95 cap starts at 0.692 for α = 1.1 and falls to 0.018 at α = 5. Between α = 1 and α = 2, the per-task cost variance is infinite, and the mean-variance objective is undefined. Then only the quantile contract is a well-defined predictability object. (An interpretive model, not a measurement)*

## So, What Changes

For the cloud engineer, a new axis appears on the token unit price. The predictability tax curve T(B) becomes a second price list. How much to surcharge a customer who wants to buy a tight p95 contract comes out as a computation. On top of the existing H200 and router stack, two plans can be separated: budget-cap routing and average-cost routing. It also composes with the zero-token skill router and the queue-aware tier fallback.

For small teams and nonprofits, it is how to turn unattended automation from invoice roulette into a budget. Once the extra price paid into the tail is quantified, the invoice roulette is gone. The electricity and dollars wasted by tail retry storms become values that can be accounted for.

Scientifically, the FrugalGPT-style expected-cost cascade is lifted to a distribution-level target. Quality is held fixed. The frontier that compares the average, the variance, and the character of the tail together is organized as the first computation. Cost variance is now a first-class metric of routing, not a byproduct of the policy.

## What Cannot Be Trusted

Every number in this paper is a value from an interpretive model. The tier price ratios are 1 to 3.75 to 18.75, and the success probabilities are declared values too. They are not telemetry.

The retries of the cascade happen independently once the task type is given. The call noise is held at the same value across all tiers. The finite tier depth is an assumption, and the two learned routers are likewise approximated by declared thresholds.

The measurement protocol is specified. It is built from hypotheses with their direction declared in advance, so that each theorem of this paper can be measured. Since p95 estimates can be coarse at pilot scale, the tail hypotheses need larger replications. Execution is future work.

Still, the conclusion is solid. A bill written in the average alone gives no warning until the budget breaks in the tail.

The full paper and the data: https://huggingface.co/datasets/thaki-AI/daily-paper-2026-09-28-predictability-tax-cost-variance-routing
