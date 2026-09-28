---
title: "The Fickle Router: The Price of Skill Instability When the Same Intent Becomes a Different Sentence"
seo_title: "Introducing the Fickle Router paper - In an unattended agent loop, the skill router picks one skill out of a registry of thousands, and the routing decision happens only once. Rewrite the same intent as a meaning-preserving paraphrase and the top-1 can flip to a different skill. This paper measures that decision instability in units of cost. The instability mass metric prices each flip by its downstream cost, and a 3-class flip taxonomy (benign equivalent, costly re-execution, harmful misdelivery) separates the wobble by severity. The margin-conditional flip boundary shows that a flip can only happen when the margin is inside the perturbation ball radius ρ_eff, and upper-bounds the flip rate by the lower tail mass of the margin distribution. The downstream cost identity writes the expected total cost of an unattended loop as number of tasks × (base cost + reliability tax), and the first-order condition of the optimal stability gate places the recheck budget where the flip cost and the recheck cost meet. The boundary combines additively with the quantization radius from the earlier 'Quantizing the Gatekeeper'. It specifies a paraphrase stability audit protocol on the sra_bench/route_bench local harness, with 5 falsifiable hypotheses. All figures are interpretive models, not real measurements - ThakiCloud"
seo_description: "The bill of an unattended agent loop cracks in places no one is watching. Write the same task as a different sentence and the skill that runs can change. This paper puts a price on that decision instability. It provides the boundary (flips happen only where margins are thin) and an optimal gate for spending the recheck budget. All figures are interpretive models, and the protocol is specified with 5 falsifiable hypotheses."
excerpt: "The task stays the same, but when only the sentence changes, the skill that executes can be different. This paper prices that wobble and shows when it happens."
date: 2026-09-29
tags:
  - skill-routing
  - decision-instability
  - paraphrase-robustness
  - semantic-equivalence
  - retrieval-stability
  - top-1-flip-rate
  - agent-harness
  - unattended-automation
  - sra-bench
  - routing-reliability
categories:
  - research
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/en/research/fickle-router-paraphrase-instability/"
---

An unattended agent loop leaves the choice of which tool to run to a router. This post is for the cloud or AI engineer who runs such a loop or is accountable for its bill. The task can stay the same while only the wording shifts a little, and the tool that executes can become something different. That wobble gets billed quietly inside the unattended loop. ThakiCloud's paper of the day writes a price tag on that wobble. The router picks one skill out of a registry of thousands of skills. The decision happens only once, and there is no one to catch the mistake. This paper calls a router whose choices wobble like this a fickle router.

![Illustration of the core idea of The Fickle Router: The Price of Skill Instability When the Same Intent Becomes a Different Sentence](/assets/images/fickle-router-paraphrase-instability-hero.webp)
*A visual metaphor for the article's key idea.*

## In Plain Terms: An Order Ticket Sent to the Wrong Kitchen

Imagine a restaurant with more than 1,600 kitchens. A dedicated order taker reads each order ticket and delivers it to the right kitchen. If you order the same dish in different words, the ticket can go to a different kitchen. The order is the same, but the chef receiving it is different. The paper's fickle router is exactly this order taker.

The paper asks whether the same dish still reaches the same kitchen even when the sentence changes. In plain terms, the question of this paper is how much one order ticket sent to the wrong kitchen costs.

## The Problem: Accuracy That Cannot See Wobble

Router performance is usually reported as a single number: the accuracy of picking the best skill in one shot on a fixed query. That number looks at each query frozen, one at a time. Wobble is the difference between two queries with the same intent. So it does not show up in per-query accuracy.

Wobble enters the unattended loop from three directions. The user rewrites the request, an upstream stage rewrites it, and a translation preserves the intent. All of these are intent-preserving paraphrases. The moment the top-1 flips, the wrong tool runs. If the intent was archive but it gets read as delete, no one notices. The wrong tool runs and its cost is billed. Wobble is the quiet bill of the unattended loop.

The earlier paper 'Quantizing the Gatekeeper' looked at the model side of the same hybrid score: how far the score can move when the embedding model is quantized. This paper moves the axis to the input side. It asks how stable the decision is when the query is rewritten as a meaning-preserving paraphrase. The score used is the same: a hybrid score, a weighted sum of the keyword match score (BM25) and the semantic similarity score (embedding cosine).

## The Core Contribution: Putting a Price on Wobble

The first contribution is measuring wobble in units of cost, not in number of occurrences. Not every change of the top-1 skill is the same. There is a benign equivalent skill that does the same job, a skill that forces a restart after you have already begun, and an entirely different skill. The paper calls these changes flips and splits them into three categories.

![Downstream costs by flip class](/assets/images/posts/research/fickle-router-paraphrase-instability/fig2-flip-taxonomy.webp)
*The three flip classes drawn side by side by downstream cost. The benign equivalent class has a cost of 0, the costly re-execution class sits in the middle, and the harmful misdelivery class is the largest. (Interpretive model, not real measurements)*

The metric that averages each flip weighted by this cost is called instability mass. It asks, on average, how much a single paraphrase family costs the router. Multiply the average flip rate by the average cost per flip and you get the reliability tax: the price the unattended loop pays for wobble.

The second contribution is the cost identity of the unattended loop. Run N tasks and the expected total cost becomes the number of tasks times (base cost plus reliability tax). In an unattended state, that bill is neither visible nor anyone's responsibility. The cost of misdelivery grows the deeper execution goes on top of the wrong skill.

## When Wobble Happens: Only Where Margins Are Thin

The heart of the paper is the geometry of when a flip happens. The difference between the top-1 skill's score and the second-place skill's score is called the margin. The paper's boundary shows that a flip can only happen when the margin is inside the range a paraphrase can move the score.

![top-1 vs top-2 hybrid score over a paraphrase family](/assets/images/posts/research/fickle-router-paraphrase-instability/fig1-margin-geometry.webp)
*As the sentence moves away from the original, the top-1 skill's score falls and the second-place skill's score rises. Where the two lines cross, the second-place skill overtakes the top-1. A flip is possible only when the margin is inside the wobble radius. (Interpretive model, not real measurements)*

In plain terms, if the gap between two kitchens is narrow, a sentence can change where the order ticket is headed. If the gap is wide, no rewriting changes the destination. Wobble concentrates where near-tie pairs pile up.

On top of this sits the paper's optimal stability gate. When the margin is thick, route immediately. When it is thin, an LLM rechecks and re-derives the action. The optimal threshold is the point where the flip cost saved by rechecking equals the cost of rechecking. It answers how much you should keep watching.

If the input wobbles and the model wobbles too, the boundaries combine. The two wobble radii are added together, and the safety margin must be sized for that sum. A single knob cannot absorb the two sources of wobble separately.

## So What Needs to Change

For a company, it becomes a new axis of the overnight self-evolution loop. The loop reads the margin at routing time and spends recheck budget only where it saves more than it costs. The reliability tax becomes a number you can drive down on the local route evaluation harness (sra_bench/route_bench).

For society, it becomes a reliability signal for fully autonomous workflows. When decisions can wobble with the wording, that wobble shows up on the bill as unexpected cost overruns and execution of the wrong skill. Measuring it turns the wobble into something operators can manage.

For science, it is the separation of a new axis. Calibration deals with how trustworthy predicted probabilities are on a fixed query, and accuracy deals with how often you get it right in one shot. The wobble that comes from doing the same thing in a different sentence is a different axis from both. The paper provides this axis with a metric, a boundary, a cost identity, and a gate.

## What Cannot Be Trusted

This is an interpretive paper. It defines metrics and proves theorems, and the audit protocol remains a specification. Every figure in the paper is an interpretive model, not a real measurement.

The audit is specified as the third contribution. The measurement protocol writes down 5 falsifiable hypotheses in advance. Examples include whether wobble concentrates where margins are thin, whether the tax is driven by the harmful minority, and whether the optimal gate threshold lies inside the wobble radius.

The two wobble radii of the theory are assumptions. Whether they hold for a given embedding model and BM25 is left to validation. With 8 paraphrase variants per case, rare phrasings may be caught less.

The cost model is first-order. It cannot include interactions where multiple wobbles happen within a single task. The results come from a specific regime, a Korean-English registry of 1,600 skills, and they may not transfer as-is.

The filter that picks intent-preserving paraphrases is not perfect either. It may include variants whose meaning has drifted slightly, and it may drop valid paraphrases. That introduces bias into instability mass and reliability tax. The direction of the bias is not determined.

Even so, the conclusion is solid. Wobble can only happen where margins are thin, and the bill of the unattended loop can now be read in units of cost.

Paper and data: https://huggingface.co/datasets/thaki-AI/daily-paper-2026-09-29-fickle-router-paraphrase-instability
