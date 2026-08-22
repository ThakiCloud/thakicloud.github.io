---
title: "The Completion-Rate Gap in Unattended Agent Loops: What Actually Closes It"
seo_title: "Verification Gates vs Checkpoint Rollback vs Stall Escalation, Measured"
seo_description: "We introduce ThakiCloud research that measures, through a controlled experiment, how far three mechanisms, verification gates, checkpoint rollback, and stall escalation, can close the gap between the number of tasks an unattended overnight agent loop reports as complete and the number actually finished."
excerpt: "We took apart, through measurement, the common belief that adding a verification gate to an unattended agent loop makes it safe, and found a trap: the gate alone actually causes a sharp spike in iteration-exhaustion rate."
date: 2026-07-23
tags: [autonomous-agents, agentic-loops, verification, checkpoint-rollback, reliability-engineering, llm-ops]
categories: [research]
author_profile: true
toc: true
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/research/autonomous-loop-completion-gap/"
audiobook: "https://drive.google.com/file/d/1HLqqLIhOJAqGVGMu45NHAzt-3AhRcfq0/view"
audiobook_label: "▶ Listen: 5-minute briefing"
audiobook_note: "NotebookLM audio overview (AI-generated)"
published: false
---

If you operate or design agent pipelines that run overnight without a human watching, this piece is worth reading. The conclusion up front: of the three mechanisms, verification gates, checkpoint rollback, and stall detection, one contributes overwhelmingly more than the other two toward closing the gap between the number of tasks a loop reports as "complete" on its own and the number actually verified through to the end, while the other two mechanisms merely support it from behind. However, turning on that one dominant mechanism alone creates a trap: tasks end up failing in a different way instead. That is the real point of this research.

![Illustration of the core idea of The Completion-Rate Gap in Unattended Agent Loops: What Actually Closes It](/assets/images/autonomous-loop-completion-gap-hero.webp)
*A visual metaphor for the article's key idea.*

## The Completion-Rate Gap Problem

Unattended agent loops, automation that runs on a schedule overnight or without a human watching every step, can only be trusted when the number of tasks attempted matches the number of tasks actually finished. In practice, a large gap often opens up between the two. This happens when an agent declares work complete before it is actually done, silently reverts prior progress, or repeats the same action without making any forward progress at all. This paper calls the difference between the number of tasks attempted and the number of verified successful tasks the completion-rate gap, and takes as its central question how much any given harness mechanism actually closes that gap.

The field of loop engineering has already offered a few standard answers. There are three: verification gates, which refuse to accept self-reported completion without independent verification; checkpoint rollback, which detects silent regression and reverts to the last known-good state; and stall escalation, which detects a state stuck in the same place without progress and switches strategy. The problem is that the value of these mechanisms is usually presented only as a claim rooted in design intent. Beyond the slogan-level "close the loop," they are rarely actually measured. Adding all three mechanisms at once and observing that the loop improved tells you nothing, from the outcome alone, about whether all three contributed, whether one mechanism drove the result, or whether two of them interacted. This research takes the harness ThakiCloud actually operates, the verification gate in `verify_gate.py`, the rollback in `hermes-checkpoint-rollback`, and the stall definition in `loop-trigger-gate`, exactly as they are, and answers this question with a controlled experiment.

## Method: A Controlled Simulation, Not a Live Measurement

Rerunning real LLM-based production loops (`pge-loop`, and `daemon_tick` in Goal Mode) thousands of times across eight mechanism combinations to obtain statistically stable estimates is not affordable. So this research instead built and ran a CPU-only discrete-event simulation that encodes the decision logic of the actual production code as-is. The three faults the simulation injects are exactly the failure modes each mechanism was designed to prevent in the first place: silent regression, prematurely hallucinated self-reported completion, and stalling without progress.

There is a point worth stating honestly here. This experiment does not rerun a production loop with a real LLM running inside it; it is a synthetic fault-injection simulation that faithfully carries over the harness's code semantics. Instead of preserving the probabilistic behavior of a real LLM and the semantics of real tasks, we chose to reduce variance across the eight configurations using the CRN (common random numbers) technique, in order to obtain statistically stable estimates. We used 30 seeds and 300 tasks per seed, streaming the same random numbers through all eight on/off combinations of the three switches, verification (V), rollback (R), and stall escalation (S), so that any difference in results between configurations comes purely from the mechanism logic. Each task is assigned a true difficulty between 5 and 20, meaning the number of progress increments genuinely required to finish, and on every iteration the outcome splits into a 55% chance of progress, a 15% chance of regression, and a 30% chance of stalling. After three consecutive stalls, if escalation is turned on, the loop switches into a boosted state where the progress probability rises to 85%. When the verification gate is off, a 5% chance per iteration mixes in a hallucination that prematurely self-reports completion; when the gate is on, this premature claim is deterministically rejected.

## The Overwhelming Effect of the Verification Gate, and Its Trap

Across all eight configurations, the true success rate of the baseline with all three mechanisms off is only 26.22 percent. With all three mechanisms on, it rises to 97.59 percent, closing a completion-rate gap of 71.37 percentage points.

![True-Success Rate by Mechanism Configuration](/assets/images/posts/research/autonomous-loop-completion-gap/fig1_true_success_by_config.webp)
*True success rate by mechanism combination, for all eight configurations. Only the configuration with all three mechanisms on reaches the 90-percent range, and configurations with the verification gate off never exceed the 30-percent range even with rollback and escalation added. Measured with a CRN simulation of 30 seeds and 300 tasks per seed, as a CPU-only job on the ThakiCloud AI Platform Demo cluster.*

Breaking down each mechanism's contribution with a two-point Shapley approximation, the verification gate accounts for 55.3 percentage points, checkpoint rollback for 15.2 percentage points, and stall escalation for 0.64 percentage points. The verification gate is also the only mechanism that drives the false-success rate to exactly zero in every configuration where it is on. Because it structurally rejects premature completion claims, a hallucinated "complete" state never occurs at all.

But this overwhelming effect comes at a cost. In the configuration where only the verification gate is on and rollback and escalation are both off, the average iteration count nearly doubles, from 13.4 to 23.7, and the rate of tasks that exhaust their iteration limit without reaching any conclusion spikes from 3.2 percent to 24.1 percent. Tasks that would previously have been (wrongly) declared complete and finished are now forced to keep iterating, and with no way to recover, roughly a quarter of them simply hit the iteration limit and remain unfinished. A team that adds only verification and stops there might feel reassured that false success has disappeared, but in reality only the shape of the failure has changed.

## Checkpoint Rollback's Synergy and Surprisingly Weak Stall Detection

The effect of turning checkpoint rollback on by itself is only 10.1 percentage points, but the drop that occurs when you remove rollback alone from the full configuration is 20.3 percentage points, nearly double. This means the two mechanisms are not independent of each other but are strongly coupled. This synergy shows up most clearly in the iteration-limit exhaustion rate. Once the verification gate closes off the false-completion escape hatch, tasks pile up against the iteration limit (24.1 percent exhausted with the gate on alone), and checkpoint rollback is exactly what recovers those piled-up tasks. Turning on verification and rollback together drops the exhaustion rate to 3.0 percent. Rollback effectively converts the iteration-exhaustion cost the gate creates on its own back into completed tasks, at a cost of only about 3.4 rolled-back iterations per task.

![Shapley-Style Marginal Contribution per Mechanism](/assets/images/posts/research/autonomous-loop-completion-gap/fig2_marginal_contribution.webp)
*Of the 71.4 percentage-point gap closed by the three mechanisms, the verification gate accounts for 55.3, checkpoint rollback for 15.2, and stall escalation for 0.6 percentage points. The fact that the loss from removing rollback when the other mechanisms are present (20.3) is twice as large as rollback's standalone effect (10.1) demonstrates a superadditive synergy. This is an analytical model based on a two-point Shapley approximation, not a direct measurement.*

![Mean Wasted Iterations per Task by Configuration](/assets/images/posts/research/autonomous-loop-completion-gap/fig3_wasted_iterations.webp)
*Without the verification gate, rollback reverts about 1.9 iterations per task on average, but with the gate on, it reverts about 3.3 to 3.4 iterations. This means rollback is recovering that much more of the iteration-exhaustion cost the gate creates. Configurations with the gate on are measured values; some configurations with rollback off are analytical model values.*

Stall escalation's contribution, by contrast, was only 0.64 percentage points. This is the result in the paper that most contradicts conventional wisdom. Stall and infinite-loop detection is a topic the loop-engineering community has taken seriously for a long time, but in the fault combination this experiment constructed, the dominant failure causes were hallucinated completion and silent regression, not literal infinite stalling, so escalation had almost no effect. This should not be read as a general claim that stall detection is useless. In a different fault distribution with a much higher rate of chronic stalling, escalation could become far more important, and this experimental methodology is precisely designed to answer that kind of question. In other words, this result is a scope-limited conclusion for this specific fault combination.

## What This Means for the Company, Society, and Science

For ThakiCloud, this result is a measurement-based ranking that shows where to strengthen harness investment first on our own Kubernetes and agent platform. We now have a concrete instruction, grounded in measurement rather than belief: strengthen the verification gate first, checkpoint rollback next, and prioritize stall escalation only when the fault distribution is actually stall-dominated. This is used directly to decide where to work on the `jarvis` and `pge-loop` harnesses next.

More broadly, the more clearly we can identify which mechanism actually stops an unattended loop from silently stalling or drifting into hallucination, the less wasted GPU and compute resources and human oversight burden there is. That makes deploying unattended automation at scale that much safer. Scientifically, the methodological contribution of this research is replacing position-paper claims like "close the loop with verification" with falsifiable evidence obtained by isolating each mechanism's individual contribution and interaction contribution through controlled ablation.

## Limitations

The most important limitation is that this experiment does not rerun a production loop live with a real LLM inside it; it is a synthetic fault-injection simulation faithful to that loop's code semantics. The mechanisms' decision logic is faithful to the actual production code, but the results are values drawn from a parameterized probability distribution, not the outcome of a language model actually performing real tasks.

In addition, the probabilities for progress, regression, stalling, and hallucination are hand-set values, not values fitted to real execution traces. As already stated, the conclusion that stall escalation is weak is dependent on this specific fault distribution, so fitting these probabilities from real execution logs could change the quantitative attribution, especially stall escalation's near-zero contribution. Fitting these probabilities from real `pge-loop` and `daemon_tick` execution logs is the key direction for future research.

The three mechanisms carry over the decision logic of ThakiCloud's own harness (`verify_gate.py`, `hermes-checkpoint-rollback`, `loop-trigger-gate`) as-is, so for a different harness that uses a probabilistic gate instead of a deterministic one, or implements rollback through branching instead of reverting, the methodology carries over but the specific numbers would need to be measured again. Finally, this research measured only completion status, false success, exhaustion, iteration count, and wasted iterations, and did not address actual wall-clock time, token cost, or graded differences in task quality beyond binary completion.

The paper's detail page can be found on the [Hugging Face dataset](https://huggingface.co/datasets/thaki-AI/daily-paper-2026-07-23-autonomous-loop-completion-gap).

