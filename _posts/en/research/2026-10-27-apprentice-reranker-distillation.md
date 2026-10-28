---
title: "The Apprentice Reranker: Distilling the Router's Most Expensive LLM Rerank Stage from a 27B Teacher to an 8B Apprentice; We Measured a Cost-Quality Frontier Where the Token Bill Rises 7.1% but Wall Time Shrinks About 14.6x"
seo_title: "The Apprentice Reranker: Introducing the Measurement Paper on the Skill Router's LLM Rerank Stage Cost-Quality Frontier, 27B Teacher vs 8B DPO-Distilled Apprentice (rerank distillation, DPO, teacher-student, tokenizer divergence, wall-time frontier, break-even escalation, SRA holdout, self-hosted H200) - ThakiCloud"
seo_description: "In ThakiCloud's router series, 71.6% of the router's own bill sat on the LLM side, and every measurement so far had pinned the rerank model at a 27B teacher. The measurement paper The Apprentice Reranker distills this LLM rerank stage into an 8B DPO student and measures the cost-quality frontier on a frozen 63-decision holdout over the 2,295-entry production registry, with window quality held fixed. The token bill is not the line item that shrinks: the student pays 7.1% more per decision (1,445.3 vs 1,350.1 tokens), and the cause is tokenizer divergence within the family, not model size. The real lever is wall time: median time per decision falls from 10.63s to 0.73s, about 14.6x faster, and roughly 59s disappears per session. The aggregate judgment pass rate is identical at 91.5% and the safety-critical kinds survive fully, but the synthesis axis drops from 100% to 66-69% and becomes the binding constraint. Style gate violations tighten to 30.2%, strictly better than the teacher's 53.5%. The paper formalizes the frontier and derives the break-even escalation condition (about 0.016 dollars per second), recommending student-first rerank with synthesis-conditional teacher escalation."
excerpt: "Distilling the LLM rerank stage from a 27B teacher to an 8B apprentice raises the token bill 7.1%. What shrinks by 14.6x is the time per decision. ThakiCloud's measurement paper held window quality fixed to measure the cost-quality frontier, and the binding constraint sits on the synthesis axis."
date: 2026-10-27
tags:
  - skill-routing
  - llm-reranking
  - model-distillation
  - dpo
  - teacher-student
  - cost-quality-frontier
  - agent-harness
  - sra-bench
  - h200-serving
  - unattended-automation
categories: [research]
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/en/research/apprentice-reranker-distillation/"
---

A company that runs an unattended agent harness with over 2,000 skills hands the router's final judgment, which skill takes a task, to the most expensive big model. Move that final judgment to a small model and the bill rises, but the time per judgment falls sharply. ThakiCloud measured this on its own server. If you own routing cost or run an unattended agent harness, this measurement is your basis for judgment. This post introduces that one measurement paper, numbers and limits included. By the end you know how far a small model can stand in for a big model's judgment, and what it costs.

This is the picture ThakiCloud's new paper, The Apprentice Reranker, shows. It measures the distillation of moving the router's most expensive segment, the LLM rerank stage, from a big model to a small one. We held the candidate list quality fixed and watched how cost and quality change. The conclusion up front: the token bill rises 7.1%. What shrinks by about 14.6x is the time per judgment.

![Illustration of the core idea of The Apprentice Reranker: Distilling the Router's Most Expensive LLM Rerank Stage from a 27B Teacher to an 8B Apprentice; We Measured a Cost-Quality Frontier Where the Token Bill Rises 7.1% but Wall Time Shrinks About 14.6x](/assets/images/apprentice-reranker-distillation-hero.webp)
*A visual metaphor for the article's key idea.*

## In plain terms

Think of a taxi dispatch center. A call comes in and one driver must be assigned. A fast search first narrows the field to eight nearby drivers. Picking exactly one from those eight is the router's rerank stage. Today that pick goes to a 27-year veteran dispatcher. Accurate, but it takes time per case and costs more.

The 10-23 series measurement, The Router's Toll, found the full routing path spends 1,440.3 tokens per judgment, and 71.6% of that bill sits on this last judgment, the LLM side. Yet every series measurement pinned this pick at a 27-year veteran. The two levers the series already measured, embedding quantization and the precondition gate, decided which computation runs. Distillation decides which model runs it.

If you teach an 8-year apprentice the veteran's dispatch records, can the apprentice take that pick? This paper's measurement answers that question. The apprentice trains with preference-pair learning, DPO, on preference pairs built from the veteran's dispatch.

The result compresses to three points. First, the apprentice's dispatch quality is nearly identical to the veteran's. Second, time per case falls to about a fifteenth. Third, the invoice is actually slightly pricier. The two dispatchers' invoice paper has different grid markings, so the same work fills more boxes. The one order type the apprentice fumbles is exactly one: the hardest orders that must combine two things. So the operating mode is the apprentice assigns first and calls the veteran only for those orders.

## What we tried

The serving environment is a self-hosted H200. The teacher, playing the veteran, is a Qwen3.8-27B family model served with NVFP4 quantization. The student, playing the apprentice, is a Qwen3-8B family model. Training version v21 passed both pre-registered non-inferiority gates.

The comparison runs on a frozen 63-decision holdout over the 2,295-entry production skill registry. 45 decisions must pick a skill, 10 have no suitable skill, and 8 must avoid a superficially similar skill. The rerank stage answers with one JSON under a 64-token cap.

Quality is fixed at the candidate-list level, ahead of rerank. Recall at 5 is 77.8%, top-of-list accuracy is 48.9%, no-skill fabrication is 0.0%, and similar-skill avoidance is 37.5%. These belong to the keyword search, BM25, stage alone, so they are identical across the two models. The condition "window quality held fixed" comes from here.

The cost axis is computed exactly, not sampled. The rerank bill is a deterministic function of the prompt text, the serving family's tokenizer, and the declared output cap. The declared self-hosted rate is 1.50 dollars per million input tokens and 0.60 dollars per million output tokens, flat across tiers. So the paper computes the bill for all 63 decisions exactly with both models' real tokenizers.

The quality axis was audited with frozen per-case artifacts served on the H200 evaluation cluster on September 4 and 5. The kind holdout has 342 rows and the synthesis holdout 144 rows. The style side-effect axis was measured with a deterministic gate that runs without a judge, applied to both models' frozen prose pools.

![Hybrid skill-routing chain with the distilled LLM-rerank stage](/assets/images/posts/research/apprentice-reranker-distillation/fig_chain.webp)
*The hybrid skill routing chain over the 2,295-entry production registry. The LLM side (rerank and gate-fail reroute) accounts for 71.6% of the router's total bill, and this paper distills that segment from a 27B NVFP4 teacher to an 8B DPO student. The dashed line below is the deterministic precondition gate that can skip the LLM side entirely on safe decisions. This figure is a conceptual diagram of the routing chain, not measured values.*

## Results

### The bill did not go down

At the declared flat rate, the apprentice pays 7.1% more per judgment. That is 1,445.3 versus 1,350.1 tokens per judgment, about a tenth of a cent in money.

The cause is not model size. It is that the two tokenizers in the same family split the same text differently. The Qwen3 family 8B tokenizer compresses the identical rerank prompt 53.9 tokens less.

The paper formalizes this as a proposition. At a flat rate, the bill difference is set by the tokenizer pair alone. An apprentice sharing the vocabulary has a bill difference of exactly 0.

In plain terms, the veteran and the apprentice do the same work, but the apprentice's invoice paper has finer markings, so the same work fills more boxes and the invoice comes out a little pricier.

### The real lever is time

Against the frozen H200 serving latency, the median composite time per judgment falls from 10.6 seconds to 0.7 seconds, about 14.6x faster. The keyword search stage, 26.5ms, is negligible in both models.

At 6 routing judgments per session, about 59 seconds of router real time disappears per session. In an overnight loop, that is the difference between routing fitting inside the session and routing swallowing it.

In plain terms, if the veteran's one dispatch takes several minutes, the apprentice's one takes seconds.

### Judgment spreads. Only one axis drops.

The overall pass rate on the kind frozen set is 91.5% for both the veteran and the apprentice (n=342). The judgment survival rate, the apprentice pass rate divided by the veteran pass rate, shows the difference by kind.

The four safety-critical kinds (identity, language, tool restraint, no-PII) survive fully at 98% or above. The execution kinds (recitation, step order, action policy) fall 9.7 to 12.9 points, while tool action choice rises 17.3 points.

The synthesis axis falls from the veteran's 100% to 66 to 69%. It is the only axis that breaks the safety margin, and the binding constraint of deployment. The sign test on paired rows is 11 to 1, the direction where the apprentice does not significantly lose.

An overall 91.5% = 91.5% hides exactly this variance. So the paper writes the frontier at the kind level, not as a scalar.

In plain terms, the apprentice assigns everyday orders nearly perfectly, and fumbles only the orders that must combine two things.

### As a bonus, even style got stricter.

The apprentice's frozen prose pool has 30.2% gate violations per text, lower than the veteran's 53.5%. The two S1 severity patterns that decide the veteran's corpus verdict (ironic contrast, conclusion transition markers) do not appear in the apprentice pool.

DPO distillation into a smaller base model strips off the veteran's characteristic "AI essay" surface markers.

In plain terms, the apprentice is a lever on time, not tokens, and it strips off even the master's stylistic habits as a bonus.

![Per-kind judgment survival: teacher vs student pass rates](/assets/images/posts/research/apprentice-reranker-distillation/fig_survival.webp)
*Per-kind pass rates on the frozen 342-row kind holdout, teacher versus student. The safety-critical kinds are preserved, the execution kinds spread, and act_tool rises 17.3 points. The binding degradation sits on the synthesis axis. The sign test on paired rows is 11 to 1 (p=0.0063), and the median composite time per decision falls from 10.63s to 0.73s. The Qwen3-8B tokenizer compresses the identical rerank prompt 53.9 tokens less. This figure is a drawing by an analysis model, not measured values.*

## So what should change

The paper formalizes the deployment frontier over three policies: always the veteran, always the apprentice, and apprentice-first that escalates to the veteran only on a specific decision class. Each policy is a mixture of the two branches' distributions.

Escalating to the veteran on class C raises the bill difference in proportion to C's share, and returns the veteran's judgment difference on C by that same amount. On the declared card of 50 cents per avoided miss, escalating to the veteran on the synthesis class is a break-even excess. It holds as long as the implicit per-second value of router real time stays below about 1.6 cents. That threshold sits far above any reasonable cost of one second of router real time.

The recommended deployment is apprentice-first rerank with synthesis-conditional veteran escalation. Each escalated decision costs an extra 9.9 seconds of real time and a tenth of a cent of bill difference. In return it buys back the veteran's 32-point judgment difference on the binding axis. The knee of the frontier is a policy, not a model.

This lever composes with the other two levers the series already measured. The precondition gate decides whether the LLM side runs at all. Embedding quantization decides how cheaply the candidate list is recovered. Distillation decides how fast the judgment is made. The current binding constraint is not any LLM branch but the candidate list itself, the 37.5% similar-skill avoidance rate. So the series' next compression target is recovery. The apprentice's value is time and style at fixed accuracy.

For the company, it is moving the LLM rerank stage from the 27B veteran tier to the 8B distilled tier, holding the candidate list quality fixed. On every unattended task on the self-hosted platform, about 9.9 seconds of router real time disappears per judgment. Overnight loops process more judgments per GPU hour. Routing stops eating the session.

For society, it leaves a reproducible recipe for accurate, cheap, self-hosted skill routing with a small distilled model. Deterministic billing, frozen-artifact quality audits, and a judge-free style gate are its components. For organizations whose per-token frontier-model cloud bill is the barrier to running an agentic skill ecosystem, this recipe lowers that barrier.

For science, it is the first measurement of how much the judgment signal transfers from veteran to apprentice in the final rerank stage of skill routing. The FrugalGPT and RouteLLM lineage of LLM cascade routing literature routes only between models, holding the router's own size fixed. This paper measures how much of a big model's routing judgment survives in an 8B apprentice under DPO, and what the frontier cost looks like. At a flat rate the explicit token bill is nearly neutral, and real time dominates. It is a result to be read alongside the series' bandit and quantization lines.

![Rerank-stage cost-quality frontier: wall time vs binding synthesis quality](/assets/images/posts/research/apprentice-reranker-distillation/fig_frontier.webp)
*The rerank-stage frontier on the two axes that distinguish the arms: median composite wall time per decision (log scale) and synthesis axis pass rate. The student point carries an explicit token bill increase of 7.1%, and the per-decision bill difference is 0.00014 dollars. On the declared card of 0.50 dollars per avoided miss, the break-even threshold for escalating to the synthesis class is about 0.016 dollars per second. The segment between the two points is the set of mixed escalation policies, and the knee at the student end is the recommended deployment. This figure is a drawing by an analysis model, not measured values.*

## What we cannot trust

The limits are five. First, the veteran's frozen latency leans on an 11-case labeled subsample. So the 14.6x composite ratio is a scale estimate until the live protocol measures both branches under identical serving conditions.

Second, the style pools differ in size and case mix (419 versus 341 interpretable). So the 53.5% versus 30.2% comparison is directional, not paired. Third, the synthesis holdout mix differs by branch (veteran n=54, apprentice n=85). The pass rate on that axis is not paired.

Fourth, this study does not re-serve the two models on the 63 SRA decisions. The live final top-1 and no-pick of the rerank stage are pre-registered under the same protocol, and the frozen artifacts give only indirect evidence on that one axis. Fifth, the rate and cap are declared protocol constants, not per-token observations. Under a tiered differential pricing scheme the bill story changes, and the bill proposition holds only at a flat rate.

The router series has now priced all three levers: toll, compression, and distillation. The remaining binding constraint is upstream, the candidate list itself.

---

The paper's detail page and accompanying materials are here: [The Apprentice Reranker](https://huggingface.co/datasets/thaki-AI/daily-paper-2026-10-27-apprentice-reranker-distillation)

*Body numbers are rounded for readability, and the exact values are kept in the figure captions. The bill proposition holds only at a flat rate.*
