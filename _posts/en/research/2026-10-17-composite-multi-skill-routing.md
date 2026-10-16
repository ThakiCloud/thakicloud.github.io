---
title: "The Composite Cost: One in Five Tasks Is Composite, but the top-1 Score Inflates by 25 Points. We Priced One-Shot Width and Iterative Re-routing on a 2,283-Skill Index"
seo_title: "The Composite Cost paper introduction - On the unattended agent harness over a 2,283-skill index (self-hosted H200, pure BM25 + 6.0 injection gate), we measure the true rate of composite (multi-skill) tasks and the price of routing strategies on a 75-task corpus (45 single, 12 composite, 10 no-skill, 8 forbidden). Labeled composite is 21.05%, while the gate-observed signal (two or more skills above 6.0 in one search) fires on 91.23% (41/45 single, 11/12 composite, 0/10 no-skill) and is not calibrated as a composite detector. On composite tasks, single-gold top-1 reports a 25% hit while set completion is 0% - a 25-point overcount on the same k=1 budget. One-shot top-k saturates at k=8 (SR 48.92→83.53%, chain completion 0→44.44%, single precision 52.38→85.71%, forbidden avoidance 87.5→25.0%), and k=10 adds 25% more injections for zero quality. Iterative route-execute-re-route (T=5) at 2.193 calls and 1.2105 injections per task yields SR 49.80% and 0% chain completion, strictly dominated by one-shot top-8. We present the set-level SRA metrics, the k=8 knee operating point, and the description-coverage investment order for the 16.5% of gold slots left outside the k=8 pool - ThakiCloud"
seo_description: "Grading the skill routing of an unattended agent loop only on 'pick one skill' inflates the score by 25 points on composite (multi-skill) tasks. We priced the true prevalence of composite tasks (21.05%) and the cost-quality frontier of one-shot width and iterative re-routing on a 2,283-skill index. The knee is k=8, and the loop spends 2.19 times the calls for top-1 quality."
excerpt: "The accuracy of picking a single skill looks fine. But one in five jobs completes only when two or more skills come in as a set, and on those tasks the top-1 grading records a 25% hit while set completion is 0%. We swept the one-shot width (k) from one to ten on a 2,283-skill index and ran the route-execute-re-route loop on a budget of 5: the knee is k=8, and the loop is 2.19 times the calls for top-1 quality."
date: 2026-10-17
last_modified_at: 2026-10-17
tags:
  - composite-task-detection
  - multi-skill-routing
  - skill-set-recall
  - iterative-rerouting
  - one-shot-top-k
  - skill-ecosystem
  - agent-harness
  - sra-bench
  - cost-quality-frontier
  - unattended-automation
  - bm25-lexical-routing
  - h200-serving
categories:
  - research
author_profile: true
toc: true
toc_label: "Contents"
canonical_url: "https://thakicloud.com/tech-blog/en/research/composite-multi-skill-routing/"
---

What if you graded the skill router you are running today not on whether the top-1 is right or wrong, but on 'did it bring the whole set of skills the task needs'? This post introduces The Composite Cost, the paper by the ThakiCloud research team that put numbers on that question on a production index of 2,283 skills. If you run an unattended agent loop on a skill registry of about 2,000 entries, or as a cloud or AI engineer you own the accuracy and the token spend of that routing stage, read this before you swap the router. The conclusion is two lines. Line one: composite tasks, the ones that need two or more skills as a set, are one in five of the gold tasks, and on those tasks the single-gold top-1 grading reports a 25% hit while set completion is 0%. That is a 25-point inflation on the same k=1 budget. Line two: 'how widely', not 'how many times', sets the quality. One-shot top-k makes its knee at k=8, while the routing→execution→re-routing loop carries 2.19 times the calls and stays at top-1 quality.

## Scoring Built on the "One Skill" Premise, and a Thinning Registry

In an unattended agent harness, routing is the hot path. When a request arrives, the system searches the entire skill index, each entry a name and a short description, injects only the skills that clear the score gate into the execution context, and what is injected is what runs. The skill corpus is larger than the context window, so a searcher has to sit on this path for every request, and in an unattended loop with no one to ask again, this routing decision is the entire quality gate.

The question is how that searcher has been graded. To date, ours included, every routing evaluation is a single-skill measurement: one task, one gold skill, one accuracy number. Our earlier measurements put single-skill top-1 search at 33-53% on this harness family and, in between, priced the model side of the router in turn (quantization, cross-tier voting, zero-token 3-arm economics). At the end of August, The Multi-Skill Gap reported that on the same index, chains of 2-4 skills almost never yield a plan that is right in order.

But the registry has been thinning in the meantime. As the automated curation sweep splits big skills into neighboring specialized ones, the share of jobs that truly need two or more skills is going up. The index grew from 2,275 to 2,283, and what changed is not the scale but the composition, while the grading criterion still stood at 'is the first gold skill ranked first'. Two things went unpriced. First, the prevalence of composite tasks: what percentage of the tasks actually routed require two or more skills. Second, the routing strategy itself: between one-shot skill-set routing, which searches broadly once, and the loop that repeats routing→execution→re-routing, which brings the full skill set more cheaply.

This paper prices those two as a one-step upgrade of The Multi-Skill Gap, on the same harness, the same registry family, and the same gate. The decision object shifts from 'which model assembles the chain' to 'how many, and how wide, router calls to bring the full set', and the metric shifts from order-sensitive chain accuracy to skill set recall.

## Composite Tasks Are One in Five, and the Router's Gate Signal Is Nine in Ten

The test board is 75 tasks built from the fleet's real workflows, in four experimental groups. 45 single-gold (one request, one gold skill), 12 composite-gold (one request, an ordered gold set of 2-5, averaging 2.92, 35 gold slots in total), 10 no-skill (the hallucination group where any injection is a false positive), and 8 forbidden skills (the avoidance group where a skill from the derivative pairs mixed into the descriptions is named as must-not-use). The composite gold is a deterministic answer by construction, verified against the index snapshot, so no human subjectivity enters the grading. Six of the 57 gold tasks reference names not in the index at snapshot time, so set metrics are computed separately on the 51 gold-available tasks (42 single, 9 composite).

The router is the ingest stage exactly as in production. Pure BM25 over the concatenated name-description field (weighted name field scoring, clamped IDF, Korean/CJK bigram discount, Korean→English synonym expansion, deduplication by name) with the 6.0 injection gate that the live loop applies to every request, and dense re-ranking deliberately off. The model axis was priced in earlier papers, so this comparison is LLM-free, deterministic, and environment-independent.

The first finding is prevalence. Two 'composite shares' coexist on the same corpus. By label (tasks whose gold is a set of two or more by construction), it is **21.05%** of the 57 gold tasks, 12/57, one in five. At the same moment, the router's own endogenous signal (two or more skills clearing the 6.0 gate in a single search) fires on **91.23%** (52/57). Unpacked: 41 of the 45 single-skill tasks, 11 of the 12 composite. Zero on the 10 no-skill tasks.

![Composite-task prevalence: labeled share vs the router's own gate signal](/assets/images/posts/research/composite-multi-skill-routing/fig-prevalence.webp)
*By label, only 21.05% of the 57 gold tasks are composite (two or more skills). In contrast, the gate-observed signal (two or more skills clearing the 6.0 injection gate in a single search) fires on 91.23% of the gold tasks (41/45 single, 11/12 composite) and on 0/10 of the no-skill tasks. The measurement shows the gate is a signal that separates 'no skill / skill present' perfectly but is not calibrated for compositeness. (Measured on the 2026-10-16 skill index snapshot, 75-task corpus, in a CPU-only container)*

The reason the signal inflates like this is the shared vocabulary of neighboring skills. If a patent family skill and its drafting sibling use the same words in their descriptions, then a drafting request sends both skills over the gate together. A detector built as 'composite if two or more candidates clear the gate' would flag 52 of the 57 tasks, and 41 of those are single-skill tasks. What the gate does well is hold the hallucination line (zero firings and zero injections on the 10 no-skill tasks), and that signal does not become prevalence as is. Prevalence is measured on the task-group side, by label, not on the gate side.

The second finding is the inflation that the grading itself creates. Grade the 12 composite tasks the old way (is the first element of the gold ranked first) and the router reports 25% (3/12). It is the first steps of three pairs, equity analysis→options strategy, incident first response→runbook execution, and RFP interpretation→proposal writing, that are the strongest lexical magnets. Grade by set on the same k=1 budget (does the entire gold set land inside the injection) and it is 0%, 0/9 (gold-available denominator). A 25-point difference on the same budget. The single-gold metric certifies a router that has never finished a composite task as 25% successful, and this is the 'multi-skill gap' that the earlier chain bench saw only from outside, now visible inside the standard SRA-Bench grading.

## Widening Is Cheaper Than Searching Again: The Knee That Stops at k=8

One arm of the strategy pricing is one-shot top-k skill-set routing. Search once and inject the top-k straight in rank order; a generalization of the production hook's k=1. The only free parameter is the width, and the cost is 1 call plus k injections per task. We swept k over 1, 2, 3, 4, 5, 8, and 10.

Skill set recall (SR), graded by set, rises from 48.92% (k=1) to **83.53% (k=8)** and stops there. k=10 is exactly identical to k=8 on all four quality axes. Is it a width that costs 25% more injection context for zero quality? The composite axis really moves. Chain completion (the share of composite tasks whose entire gold set is injected) rises from 0% to 44.44% (4/9), and its last step, k=5→k=8, makes 22.2 points. Single-skill precision saturates earlier, at 85.71% by k=5.

The price comes out of the other side. Forbidden skill avoidance falls in one direction only, from 87.50% (k=1, 7/8) to 25.00% (k=8/10, 2/8). Six of the eight forbidden skills land inside the top-8 pool, and one of them is ranked first on requests whose gold is its own derivative sibling. The width buys coverage and pays avoidance as the price.

The gate is weak as a width controller. A variant that injects only the 6.0-or-above candidates inside the top-10 window injects an average of 7.16 per task on the gold corpus, because 408 of the 570 top-10 slots clear the gate. On the hallucination group, though, it is a completely different object: zero candidates clear the gate on the 10 no-skill tasks, and zero are injected. What the gate does today in the fleet, holding the hallucination line, is preserved as is.

The measurement cost is small and deterministic. The full measurement (all groups × 75 tasks) took 9.88 seconds to search the entire 2,283-document index 215 times, about 46ms per call, 9.97 seconds end to end. The cost axes of the LLM-free ingest measurement (number of calls, number of injected skills, search wall clock) map linearly onto the token cost of an LLM router configuration, since every call is one LLM routing decision and every injected skill is one context block of the execution prompt. This skeleton is the skeleton of that price.

![One-shot top-k skill-set frontier saturates at k=8](/assets/images/posts/research/composite-multi-skill-routing/fig-frontier.webp)
*Skill set recall (SR) graded by set, single-skill precision, and chain completion on composite tasks rise with the one-shot width and stop at k=8. k=10 is identical to k=8 on every axis and only costs 25% more injection. On the other side, forbidden skill avoidance falls in one direction only, from 87.50% to 25.00%, a measurement that the width buys coverage and pays avoidance for it. (Measured on the 2026-10-16 skill index snapshot, 75-task corpus, in a CPU-only container)*

Put the knee at the operating point: at k=8, SR 83.53%, chain completion 44.44%, precision 85.71%, avoidance 25.00%. If the constrained resource is execution context rather than coverage, the measured point under the knee is k=5 (SR 80.43%, precision 85.71%, avoidance 37.5%).

## The Loop That Buys "One More" Carries 2.19 Times the Calls and Stays at top-1

The other arm of the strategy is iterative re-routing. The cycle is routing→execution→re-routing: search the top-10 from the current request, inject the rank-1 that clears the gate, 'execute', then re-search on the residual, going up to a budget of 5. Execution is the same LLM-free proxy as the earlier composite measurement: strip the surface vocabulary (name words, description tokens, synonym bridge forms) that just linked the routed skill to the request out of the request, and re-route the residual. No group uses the specific task labels, so the loop sees only the request text and the index.

The measured result is the price of this strategy. **2.193 calls and 1.2105 injections per task.** The quality is top-1 quality: SR 49.80% (+0.88 points over k=1's 48.92%), chain completion 0%, single precision 0.5238, avoidance 0.875, equal to top-1 on every axis. It collects at least one skill on 54 of the 57 tasks, but the 68 additional calls across the 53 tasks after the first search fish up only 15 new skills, just 22.1%. Termination is 'no residual candidate above the gate' on 56/57 and residual exhaustion on 1/57. No task reached the budget of 5.

![Iterative re-routing degenerates to one-shot top-1 quality](/assets/images/posts/research/composite-multi-skill-routing/fig-strategy.webp)
*The iterative route-execute-re-route group (2.193 router calls and 1.2105 skill injections per task) stays at SR 49.80% and 0% composite chain completion. Precision and avoidance match one-shot top-1 (1 call) on every axis, and the group is strictly dominated by k=8 (SR 83.53%, chain completion 44.44%) at 2.19 times the calls. (Measured on the 2026-10-16 skill index snapshot, 75-task corpus, in a CPU-only container)*

The way it dies is visible inside the group's dynamics. What the execution proxy strips is exactly the surface vocabulary that fired the first search, so the residual is structurally a sparse fragment that has lost its anchor. The fragment cannot build a score above the 6.0 gate. What dies is not the search primitive but the re-anchoring signal. It also meshes with external results: the stage-aware finding that splitting the query at search time dilutes the fragments' meaning and lowers performance instead, and the deterministic shape that 'if the marginal quality of the acquisition round is near 0, cost-aware stopping is at round 1'. The measured counterpart of those two is 56/57.

This is the tax paid on the very ledger the unattended loop's cost model wants to cut, router calls. +0.88 points of SR, zero composite gain, 2.19 times the calls. Iterative re-routing is not deployable until the re-anchoring signal is rebuilt.

## Five Operating Rules for the Unattended Fleet, and What the Company, the Industry, and Science Get

The operating rules read directly off the measurement are five.

First, move the grading of the nightly skill-evolution loop from single-gold top-1 to set metrics. SR, chain completion, and forbidden avoidance, over a mixed corpus of single, composite, no-skill, and forbidden. The metric that certified 25% was hiding 0%, so the number the loop sees has to change first. Build the composite task detector on the task-group side, not the gate side: labels by construction, or learning on top of gold sets. The gate stays as the hallucination-line keeper.

Second, run the one-shot width at the measured knee, k=8. k=10 is 25% more context for identical quality, and if context is the constrained resource, k=5 is the point under the knee.

Third, do not deploy iterative route-execute-re-route. Not until the residual carries the actual execution output and keeps the re-anchoring signal alive. Or the option of moving the decomposition from the search stage to the re-ranking stage.

Fourth, tie the width to description separation, in pairs. At k=8, 6/8 of the forbidden skills land inside the pool, and the failing family is entirely derivative pairs already recorded in the single-gold series. That means the measured remedy is to sharpen the descriptions of those pairs with pairwise separation, or to apply a verify-gated filter on top of the injection set.

Fifth, after pricing the strategy, invest in coverage. The 16.5% of gold slots left outside the k=8 pool is not a problem of router calls but of description vocabulary, that is, of the search side. Given the pool ceiling of the earlier chain bench (24.3% gold miss at k=20 on the 2,275-skill index) and the index growth (2,275→2,283), the search-side coverage ceiling reads as a property of the configuration, not a one-off artifact.

The company's share is a new axis in the nightly optimization of the unattended fleet. The composite task detector and the set-level SRA metrics enter the nightly skill-evolution loop and replace the single-gold top-1 that has been hiding multi-skill failure on a 2,200-skill registry.

The industry's share is price. Since the same cost skeleton maps linearly onto the token spend of LLM router configurations, running the width at the knee and switching the loop off alone reduces the token spend and the wall clock of unattended agent automation. On product hardware of a single self-hosted H200, unattended loops come down to affordable cost for small teams, not just big platform vendors.

Science's share is the evaluation axis. It measures, for the first time, composite task prevalence and skill set recall in a production-scale skill ecosystem, and presents the measured cost-quality frontier between iterative re-routing and one-shot multi-skill routing. A new axis beyond single-skill top-1 accuracy, and for skill 'set' acquisition the measured shape is a knee, not a plateau. The separation of prevalence (21.05%) and gate signal (91.23%) also stands as an empirical record against the practice of using the router's endogenous signal as a detector.

## What Not to Trust

First, the scope of the prevalence. 21.05% is a property of the labeled evaluation corpus (57 gold tasks from real workflow templates), not an estimate of production traffic. Production task logs were not in this measurement, and the number is a characterization of the configuration, not a population estimate.

Second, the execution proxy. The 'execution' of the iterative group is an LLM-free surface-strip proxy. A real execution could append the output to the residual and re-anchor the loop. What this paper says is not 'multi-round routing is impossible' but 'the loop with the measured proxy is not deployable'.

Third, the ingest-only router. dense re-ranking is deliberately off (the model axis was priced in earlier papers), and a hybrid router could move the k values. Still, since both arms use the same search primitive, the strategy dominance relationship is expected to be robust.

Fourth, scale and external validity. 75 tasks, one snapshot of the 2,283-skill index, one gate threshold of 6.0 (tuned on the single-gold axis). Six gold tasks reference names absent from the snapshot, so set metrics are computed on the 51 gold-available tasks (42 single, 9 composite). Unverified on other registries, other gates, other language mixes.

Fifth, the cost mapping. The measured cost is an LLM-free skeleton, and the dollar cost of an LLM router configuration is a linear mapping over declared unit prices, not a measurement. Both rescale linearly, but the dominance relationship does not rescale, and that is the valid part of this mapping.

Finally, a favorable ingest configuration. The surface phrasing of the composite tasks, by construction, calls the same artifacts and steps that the gold skill descriptions use. With harder surface forms, SR would be lower, and that direction strengthens rather than weakens the search-side finding.

All three figures are measured data on the 2026-10-16 skill index snapshot, the 75-task corpus, and a CPU-only container, not conceptual shapes. The captions say so as well.

The full paper and accompanying materials are on Hugging Face.

https://huggingface.co/datasets/thaki-AI/daily-paper-2026-10-17-composite-multi-skill-routing
