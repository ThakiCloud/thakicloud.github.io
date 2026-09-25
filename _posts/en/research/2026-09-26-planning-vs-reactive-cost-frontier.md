---
title: "The Planner's Dividend: The Threshold at Which Planning Beats Reactive Execution"
seo_title: "The Planner's Dividend paper analysis - in an unattended multi-step agent loop, closed-form token cost and success rate as functions of step count H for plan-then-execute (PTE), reactive ReAct, and the no-plan sprint. The PTE-versus-ReAct per-attempt cost break-even is 13.8 under nominal assumptions; the frontier fold of the retry regime (Regime I) is 12.95, and the fold of the single-attempt 0.9 success-rate regime (Regime II) is 8.0. ReAct's success rate decays with the square of H while PTE's stays first-order, so the reliability ceiling at S*=0.9 opens to ReAct 7.26 versus PTE 35.12 (about 5x); at H=16 the marginal price of one point of reliability is ReAct 21,932 tokens versus PTE 6,003 tokens (3.7x). In the retry regime, ReAct is outside the frontier at H>=2, and the planner's dividend is non-negative after the fold, grows with H, and is unbounded. It specifies the operator flip condition (turn on the planning call once the expected step count crosses the threshold) and a 3-arm pre-registered protocol that toggles only the planning call under the same model, harness, and temperature, with falsification criteria R1-R4. An explicit upgrade that promotes the qualitative debate between ReAct and plan-then-execute to a cost-quality frontier. All numbers are interpretation-model predictions under stated nominal assumptions, not measurements - ThakiCloud"
seo_description: "In an unattended agent loop, whether to plan first or respond as you go is a token-pricing decision, not folklore. The paper writes the token cost and success rate of the three approaches in closed form as functions of step count, giving the cost break-even of 13.8 and the folds of the two operating modes (retry 13, single attempt 8). Past the fold, the benefit of plan-then-execute is non-negative and unbounded. All numbers are interpretation-model predictions under nominal assumptions, and the 3-arm pre-registered protocol with falsification criteria R1-R4 is the road to measurement."
excerpt: "When the number of steps an agent needs to finish a task crosses the threshold, planning the whole thing before starting beats responding as you go, on tokens. Under retry-allowed operation the threshold is 13, under single-attempt 0.9 operation it is 8, and past the fold the benefit of planning is unbounded."
date: 2026-09-26
tags:
  - planning-strategy
  - plan-then-execute
  - reactive-acting
  - react
  - cost-quality-frontier
  - unattended-agents
  - multi-step-task-automation
  - token-cost-optimization
  - h200-serving
  - agent-harness
categories:
  - research
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/en/research/planning-vs-reactive-cost-frontier/"
---

When the number of steps an agent needs to finish a task crosses a threshold, planning the whole thing before starting beats responding as you go, on tokens. If you run unattended agent loops on self-hosted GPUs, or you are the engineer who answers for that bill, this one line is a design principle. The reason is that the threshold comes out of computation, not argument. This post introduces ThakiCloud's paper, "The Planner's Dividend."

![Illustration of the core idea of The Planner's Dividend: The Threshold at Which Planning Beats Reactive Execution](/assets/images/planning-vs-reactive-cost-frontier-hero.webp)
*A visual metaphor for the article's key idea.*

## In Plain Terms: When to Turn on the Navigation

There are three ways to go a long distance. Drive the whole way in one go, on first instinct, with no map. Judge at each intersection by reading the sign. Or enter the whole course into the navigation before departure, and follow it thereafter. The first gets more and more lost as it goes. The second has to re-recall the road traveled at every intersection. The third pays only the upfront cost of entering the course. Then every intersection after that comes cheap.

When the course is long, the upfront cost of the third way pays for itself. For a short trip it is a waste. Over a long distance, navigation beats sign-driven driving. The paper's question is precisely this break-even point. In the agent's language, this distance becomes the number of steps to finish the task. Navigation maps to the planning call, sign-driven driving to step-by-step reaction, and a no-plan sprint to a single call.

## The Problem: The Planning Decision Is a Rule of Thumb

In an unattended agent loop, every task arrives carrying a fixed agent prefix. The system prompt, the skill manifest, and the tool schemas make up that prefix, and each model call is billed in prefill and decode tokens. The biggest lever on that bill is the planning policy: whether to process the task in one go without a plan, to react at each step, or to plan the whole thing before starting.

Reactive ReAct was the default and plan-then-execute was the alternative. Which to turn on was settled by each harness's own experience. The recent evidence is fragmentary on both sides. There is the claim that web agents should have plan-then-execute as the default, the claim that reactive is sufficient in a typed action space, and even a measurement that ran six paradigms 18,000 times and found that neither dominates.

What all of that discussion shares is that it stayed entirely with quality. Nobody answered how the price gap changes with the number of steps in the task, once cost is folded in. The choice between planning and reacting had no frontier, and no threshold was computed.

## What We Did: Token Price and Success Rate of the Three Approaches

The paper writes the token cost and the success rate of three configurations as closed-form functions of the step count H. The three configurations are the no-plan sprint, reactive ReAct, and plan-then-execute (PTE). The no-plan sprint writes the whole path in a single call. ReAct judges at each step across H calls, and PTE adds H execution calls on top of one planning call.

On success rate, the two decay at different speeds. ReAct's success rate falls off with the square of the step count, because each call re-reads the entire context before it and the accumulated context buries the task's signal. PTE's decay stays first-order, because the fixed plan remains in context and the plan reduces what each step has to do.

Per single attempt, the reverse holds: PTE is the most expensive, because the cost of the planning call itself comes in first. As the step count grows, the story flips. The plan trims the per-step deliberation and the accumulating context gets smaller, so PTE crosses to the cheaper side of ReAct. That crossing point is the cost break-even at 13.8.

![Token cost per single attempt: comparison of the three planning configurations](/assets/images/posts/research/planning-vs-reactive-cost-frontier/fig3.webp)
*Token cost per single attempt by planning configuration. Plan-then-execute is the most expensive at first because of the planning call. Near 13.8 steps it crosses to the cheaper side of reactive ReAct, and the gap keeps widening. The no-plan sprint is the cheapest per single attempt, but its success rate collapses with the step count, so it cannot hold the delivered-cost frontier. (Interpretation-model prediction, not a measurement.)*

## The Results: Two Operating Modes, Two Thresholds

The token bill should be read as the price per successfully delivered task. In an operating mode that allows retries but delivers only successes, the fold where the cheapest approach changes comes out near 13. For tasks shorter than 13, the no-plan sprint is the cheapest.

![Expected delivered cost per task: frontier of the retry-allowed operating mode](/assets/images/posts/research/planning-vs-reactive-cost-frontier/fig1.webp)
*Expected delivered cost per task by planning configuration. Values for the retry-allowed operating mode (Regime I). The arm where the no-plan sprint is cheapest holds up to the frontier hand-off point near step 13, the exact fold value of 12.95. After that, plan-then-execute becomes the frontier arm, and reactive ReAct is pushed outside the frontier from step 2 on. (Interpretation-model prediction, not a measurement.)*

For tasks longer than 13, PTE crosses to the cheapest side. And ReAct is never the cheapest from step 2 on. In the retry-allowed mode, that means ReAct falls outside the frontier of cost and quality combined: pushed out entirely at the fold.

In plain terms, sign-driven driving is only competitive over short distances. As the distance grows, navigation spends less money and loses less of the way.

In an operating mode that must guarantee a 0.9 success rate in a single attempt, the difference is more extreme. The fold where PTE beats ReAct moves up to step 8.

![Ceiling of the feasible step count: single-attempt success-rate target 0.9](/assets/images/posts/research/planning-vs-reactive-cost-frontier/fig2.webp)
*Ceiling of the feasible step count under a single-attempt success-rate target of 0.9. Because ReAct's success rate falls off with the square of the step count while plan-then-execute's stays first-order, plan-then-execute can hold a working band about 5 times wider than ReAct. Under nominal assumptions the exact ceiling values are ReAct 7.26 and plan-then-execute 35.12. (Interpretation-model prediction, not a measurement.)*

The reason is the success-rate decay curve. ReAct's success rate falls off in proportion to the square of the step count, while PTE's stays first-order.

So the longest step count at which ReAct can hold a 0.9 success rate is around 7. PTE goes to around 35. Nearly a 5-fold difference.

The marginal cost of securing one more point of success-rate target widens as well. Under the same nominal premises, at step 16:

ReAct spends 21,932 tokens, but PTE needs only 6,003. A 3.7-fold difference.

In plain terms, over a long distance, sign-driven driving is not only more expensive: it loses more of the way. Navigation is the side that pays only a bit more upfront to enter the course.

## So What Should You Change: Just Read the Step Count

The operator rule is one line. When to turn on the navigation is read from the course length, that is, the expected step count. Before sending out a task, read the expected step count from the metadata, and if it crosses the threshold, turn on the planning call. In the retry-allowed mode, from step 13; in the single-attempt 0.9 mode, from step 8.

The two mistakes are not symmetric. The mistake of turning on a plan that is not needed costs one planning call: a capped cost. The mistake of not turning it on when needed is different. The planner's dividend grows the longer the step count and has no ceiling, so the price of leaving it off keeps ballooning. In single-attempt operation, past the threshold the retries ReAct needs to hit the target success rate surge, making it effectively unoperable.

The paper even writes down how to check whether this calculation is wrong. It is an experiment that compares the three arms by toggling only the planning call, under the same model, the same harness, and the same temperature. If the break-even of 13.8 falls outside the predicted band, or ReAct comes out as the cheapest in two or more step ranges under the retry mode, the model is falsified.

## What the Company, Society, and Science Gain

For ThakiCloud, this is an operating rule. In a production unattended agent loop, turn on the planning call for tasks that exceed step 13. A criterion that cuts token spend while holding reliability: no longer a rule of thumb, but backed by computation.

For society, it is cheaper long-distance automation. Fewer tokens mean less electricity, and autonomous agent systems that take on long tasks can spread to more teams and services.

Scientifically, it creates the first cost-quality frontier on the axis of planning. The argument over whether to run reactive or planning-driven is priced by one variable: how many steps the task has. The paper ends as an explicit upgrade over ReAct, promoting its qualitative standing to a measurable frontier.

## What Not to Trust

This is an interpretive paper. Every number in this post is a closed-form prediction under stated nominal assumptions, not a measurement.

The most fragile point is how the error-accumulation rate of the no-plan sprint is set. Inside a single call there is no observational feedback, so inter-step errors compound at that rate. This parameter is the weakest anchored, and if its value is off, the position of the fold moves. The falsification criteria aim precisely at this point.

There are also benefits the frontier did not price in. In an environment exposed to prompt injection, a fixed plan becomes a boundary of the control flow and safety goes up. In such environments the benefit outweighs the cost, so the threshold should be pulled to shorter steps.

It is worth remembering that external research has found the advantage of a paradigm depends on the task. The variable that routes tasks in this model is the step count, but tasks with few observations and a predictable state get pushed toward the no-plan sprint side.

So, until the 3-arm experiment actually runs on real H200s, this calculation is only a prediction. But it is a prediction whose points of failure are already fixed, so we need only watch the outcome.

Paper and data: https://huggingface.co/datasets/thaki-AI/daily-paper-2026-09-26-planning-vs-reactive-cost-frontier
