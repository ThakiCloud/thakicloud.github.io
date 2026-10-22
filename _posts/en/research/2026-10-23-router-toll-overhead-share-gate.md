---
title: "The Router's Toll: Measuring the Token Toll the skill-router Pipeline Pays Itself, and Skipping 71.6% of That Bill with a Deterministic Precondition Gate"
seo_title: "The Router's Toll: Measuring the Own Token Overhead Share of a Hybrid skill-router Pipeline and the Precondition Gate Skip Study (routing overhead share, cost-quality frontier, BM25, LLM reranking, duty-cycle, token metering, self-hosted H200) - ThakiCloud"
seo_description: "The routing literature has only priced how much a router saves, and has never measured what share of the agent loop's tokens the router pipeline itself consumes. This measurement paper meters the off/lite/full/gated 4 arms on a 2,293-entry production skill registry and a frozen 63-decision holdout, and shows that the full pipeline pays 1,440.3 tokens per decision (0.45574%), with 71.6% of that bill being LLM calls. The break-even accuracy lift is 0.30% while the cited lift is 8.9pp. In the pre-registered 30-config sweep, exactly 6 configs are zero-degradation-safe, and the best family skips 100% of the holdout at production scale and cuts the bill by 71.6% with zero measured accuracy loss."
excerpt: "The routing literature has only priced what the router saves. No one has measured what share of the agent loop's tokens the router pipeline itself uses. This paper closes that accounting gap with measurements on a 2,293-skill production registry and shows that a deterministic precondition gate skips 71.6% of the bill with zero measured accuracy loss."
date: 2026-10-23
tags:
  - routing-overhead-share
  - cost-quality-frontier
  - skill-router
  - hybrid-retrieval
  - llm-reranking
  - precondition-gate
  - token-metering
  - agent-harness
  - overnight-automation
  - h200-serving
categories: [research]
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/en/research/router-toll-overhead-share-gate/"
---

This post is for Korean cloud/AI engineers who run agent harnesses with over 2,000 skills on a self-hosted H200, or who have attached a skill-router to that harness's overnight loop. In unattended loops, every incoming task passes through a router pipeline. But the routing literature has not answered how many percent of the agent loop's tokens the pipeline itself consumes, or whether the toll it pays itself can exceed what the router saves. ThakiCloud's measurement paper The Router's Toll closes this accounting gap. On a 2,293-entry production skill registry and a frozen 63-decision holdout, it meters the router pipeline's own token bill per arm and finds a deterministic precondition gate that skips most of that bill with zero measured accuracy loss. Read to the end, and you will be able to decide, on evidence, when the router should be turned on in your own harness.

![Illustration of the core idea of The Router's Toll: Measuring the Token Toll the skill-router Pipeline Pays Itself, and Skipping 71.6% of That Bill with a Deterministic Precondition Gate](/assets/images/router-toll-overhead-share-gate-hero.webp)
*A visual metaphor for the article's key idea.*

## The Problem: The Router Has Been Treated as a "Free Classifier"

In production agent harnesses, every task passes through a hybrid skill-router pipeline before execution. It fuses BM25 lexical scores with dense embedding scores, passes the top-8 candidate window to an LLM rerank prompt, sends a gate-fail reroute prompt when the fused top-1 falls below the production threshold of 6.0, and prefills the execution context with k=8 skill manifests. This router has conventionally been treated as a free classifier. The harness's own cost audit prices execution turns, and the routing literature prices what routing saves, namely cheaper models, reduced escalations, and better skill hits. The pipeline's own token bill has been treated as an assumption.

Yet every routing decision pays tokens for the router itself. The rerank prompt over the top-8 window is sent on every decision. Every time the 6.0 gate rejects the top-1, a gate-fail reroute prompt is sent. The injection manifest prefill rewrites skill names and descriptions, up to eight of them, into the execution context. This cost is paid per decision, per session, through the night, whether or not the routing decision was useful that night. This paper calls this always-on bill the router's toll and introduces a new measurement axis to hold it in check: the routing overhead share, t/(t+B), where t is the router pipeline tokens and B is the task-side baseline.

The paper asks three things. What percentage of end-to-end loop tokens the pipeline consumes, by stage, per decision, and per session (RQ1). At what level of per-decision overhead routing stops being a net saving and becomes a net cost, and how much break-even accuracy lift that requires under the declared miss-price rate card (RQ2). And whether a cheap deterministic precondition gate built from the score statistics of retrieval itself, namely a BM25 top-1 threshold and a top1-top2 margin, can skip the expensive pipeline on some measured decisions while holding degradation to 0 over the frozen holdout (RQ3). If the answer to the third question is yes, routing stops being an always-on cost and becomes a duty-cycled, metered one.

## Design: Four Arms, a Frozen Holdout, and a Deterministic Token Bill

The measurement target is the production skill index. Under analyzer v5 it has 2,293 entries, of which 2,193 are of skill-kind, and the 2,200-skill figure in the title refers to these. The remaining entries are filled by skill-global 27, skill-agents 22, plugin-skill 187, rule 90, and fin-agent 10. The self-hosted H200 in the title refers to the production serving fleet. Because billing is a hardware-independent deterministic token count, the actual measurements are run on a CPU development node.

Every bill is computed with the Qwen3-0.6B tokenizer, which is this harness's declared serving family. We count on the exact prompts the harness actually sends at each stage: the LLM rerank prompt (top-8 candidate window, instruction, task text, and the names and descriptions of the 8 candidates), the gate-fail reroute prompt sent only when the 6.0 gate rejects the top-1, and the k=8 injection manifest prefill, which is the names and description tokens of the entries actually injected. The LLM output cap is declared as 64 tokens for the rerank answer and 64 tokens for the reroute answer.

Four arms define the bills. off pays no routing tokens. lite pays only BM25 retrieval and the k=8 injection prefill, with no LLM calls. full adds the LLM rerank prompt and the reroute prompt on gate failure to lite. gated applies a deterministic precondition gate to each decision: if the top-1 BM25 score at candidate pool scale R is below the 6.0 production gate, or the top-1 is at least τ and the top1-top2 margin is at least the margin parameter, it skips the LLM pipeline and pays only the lite bill. Otherwise it pays the full bill. The gate itself consumes nothing beyond the BM25 retrieval that the lite path has already performed.

The frozen holdout is 63 routing decisions: 45 positive (cases where a skill should be retrieved), 10 native (no suitable skill exists and the harness must answer without one), and 8 negative (cases where a skill must not be used). The holdout is frozen before any sweep runs, and no configuration is tuned to it. The task-side baseline is measured on the 46 main sessions of a single production day (2026-10-22): median turn 314,604 tokens, median session 1,811,354 tokens, and 6 routing decisions per session.

Pricing is a declared convention. Self-hosted serving is $1.50 per million input tokens and $0.60 per million output tokens, and the miss-price rate card is $0.50 per avoided routing miss. It is the same card the harness's internal bench embeds. The paper labels every quantity as measured, declared, or cited. Measured covers all token bills, overhead shares, skip shares, skip-set accuracies, and BM25 latencies. Declared covers the serving rates, the miss-price card, and the LLM output cap. Cited covers the hybrid-versus-BM25 accuracy lift measured on 2026-08-14. The protocol, the pre-registration criteria, and these labels are fixed before the sweep runs.

## The Toll, Measured: The Full Pipeline Pays 1,440.3 Tokens per Decision, 71.6% on the LLM Side

At production registry scale (R=2,293, n=63 frozen holdout), the per-decision bills for the three paying arms are as follows. off pays nothing by construction. lite pays an average of 409.6 tokens per decision (median 451, max 810), which is $0.000614357 at declared rates, equivalent to 0.13002% of the median turn and 0.13548% per session. full pays an average of 1,440.3 tokens per decision (median 1,443, max 2,314), which is $0.002090124, 0.45574% of the median turn, and 0.47484% per session. The full pipeline pays 3.52 times the average bill of the lite path, an extra 1,030.7 tokens per decision, of which 952.6 are input and 78.2 are declared output.

![Per-Decision Token Bill by Routing Arm at Production Registry Scale (R=2,293)](/assets/images/posts/research/router-toll-overhead-share-gate/fig-arm-bills.webp)
*Average per-decision token bill for the off, lite, and full arms (R=2,293, n=63 frozen holdout). The full hybrid pipeline pays 3.52 times the BM25-only lite path (1,440.3 versus 409.6 tokens). Measured values from a CPU-only container.*

Decomposing the full arm's bill by stage shows where the router's toll is paid. The rerank prompt (top-8 window) is the single largest stage: an average of 776.2 tokens (median 759, max 1,206). The gate-fail reroute prompt fires on 14 of the 63 decisions (22.2%), averaging 176.3 tokens with a median of 0 because the other 49 decisions never send it. When it fires, it reaches a max of 1,112. The k=8 injection manifest prefill is identical to the lite arm by construction: an average of 409.6 tokens (median 451, max 810). The declared LLM output is billed at the cap of 64 tokens for the rerank answer and 64 tokens for the reroute answer, and the reroute cap applies only on the 14 gate-fail decisions. So the output stage averages 78.2 tokens (median 64, max 128). The LLM side of the pipeline, namely the rerank and reroute prompts plus the output, accounts for 1,030.7 tokens of the full arm's average 1,440.3-token bill, 71.6%. The router's toll is mostly paid in LLM calls.

![Stage Decomposition of the Full Pipeline's Per-Decision Bill](/assets/images/posts/research/router-toll-overhead-share-gate/fig-stage-decomposition.webp)
*Average tokens by stage for the full arm. The LLM side (rerank prompt, gate-fail reroute prompt, declared output) accounts for 1,030.7 tokens of the 1,440.3-token bill, 71.6%. Measured values from a CPU-only container.*

This toll is under 0.5% per decision: 0.45574% for the full arm and 0.13002% for lite. But it is an always-on levy. It is paid on all 63 decisions, about 6 per session, every overnight session, whether or not the routing decision was useful that night. In dollars at declared rates, the gap between arms is $0.00209 versus $0.00061 per decision. The deterministic part of the pipeline is light in wall-clock time as well. The BM25 retrieval that every arm except off depends on averages 18.466 ms on the development node, with a max of 98.696 ms.

## Break-even: The Minimum Accuracy Lift That Justifies the Toll Is 0.30%

RQ2 asks for the net-cost threshold. The incremental bill of full minus lite is $0.001475767 per decision at declared rates. Against the declared miss-price rate card of $0.50 per avoided miss, routing pays for itself with the full pipeline only if the accuracy lift is worth at least 0.001475767/0.50 per decision, that is 0.295%, roughly 0.30%.

The cited hybrid-over-BM25 lift measured on 2026-08-14 is 8.9 percentage points on both Recall@5 (from 40.0 to 48.9) and top-1 (from 17.8 to 26.7). With the 6.0 gate applied, the cited gated Recall@5 moves from 66.7 to 77.8. The cited lift is about 30 times the break-even threshold. In measured bills against a declared card, the toll is justified when the LLM side actually earns the cited lift. And the measured zero-loss fallback for when it does not is exactly the gate in the next section.

A sensitivity analysis comes with it. The full arm becomes a net cost on this workload if the true lift falls below 0.30% per decision, or below 0.59% under the assumption that declared rates double. The cited 8.9pp lift clears both thresholds by a wide margin.

## Precondition Gate: Six Zero-loss Configs in the 30-config Sweep, 71.6% Skipped at Production Scale

The gate is a deterministic precondition on the score statistics of retrieval itself. It sends no tokens of its own and consumes nothing beyond the BM25 retrieval the lite path has already performed (an average of 18.466 ms on the development node). The gate's only decision is which pipeline pays. If the top-1 score is below the 6.0 production gate, or the top-1 is at least τ and the top1-top2 margin is at least the margin parameter, it skips the LLM pipeline and pays only the lite bill. Otherwise it pays the full bill.

The sweep is a pre-registered 30-config factorial: registry scale R (128, 256, 512, 1,024, 2,293, with the production index subsampled to R entries under a fixed seed) crossed with top-1 threshold τ (6.0, 8.0, 10.0) and top1-top2 margin (0.0, 2.0). For a config to be declared zero-degradation-safe, the lite accuracy metrics of the skip-set (Recall@5, gated Recall@5, top-1) must not exceed the corpus-wide lite baseline in the positive direction on the frozen holdout, and the skip set must not introduce new native hallucinations above the corpus rate. Deliberately conservative: on 63 cases, such a pattern is not a guarantee. Among the safe configs, the largest skip share wins. This criterion was pre-registered.

![Precondition-Gate Skip Share by Threshold and Margin at Production Scale (R=2,293)](/assets/images/posts/research/router-toll-overhead-share-gate/fig-gate-sweep-production.webp)
*Skip share by top-1 threshold (τ) and top1-top2 margin (R=2,293). The τ=6.0/margin-0.0 config skips 100% of the holdout with a 71.6% bill reduction and zero measured accuracy loss. Measured values from a CPU-only container.*

Two features stand out among the six configs at production scale (R=2,293). First, the margin parameter reduces the skip share in every config. At R=2,293, margin 2.0 cuts the skip share by 50.8, 39.7, and 19.1 percentage points at τ=6.0, 8.0, and 10.0 respectively: from 100.0% to 49.2%, from 88.9% to 49.2%, and from 65.1% to 46.0%. Across all 15 (τ, R) pairs, the margin-2.0 share is strictly below the margin-0.0 share (by 1.6 to 50.8 percentage points). Even the safe τ=8.0/margin-0.0 config skips 88.9%.

Second, look at the degradation triple: the skip set's lite accuracy minus the corpus-wide lite baseline (80.0, 73.3, 48.9 at R=2,293). It is exactly 0 on the τ=6.0/margin-0.0 row and at or below 0 (0.0, -0.8, -3.9) on the τ=8.0/margin-0.0 row. In contrast, all margin-2.0 rows and the τ=10.0/margin-0.0 row sit above the corpus in the positive direction, up to +17.8pp on top-1.

By the pre-registered criterion, exactly 6 of the 30 configs are zero-degradation-safe. Five are the τ=6.0/margin-0.0 family at R (128, 256, 512, 1,024, 2,293). Each skips 100% of the holdout, and the bill savings are 95.7%, 91.2%, 85.9%, 80.6%, and 71.6%. The per-decision overhead share lies between 0.01801% and 0.13002%. The skip set matches the corpus-wide lite baseline exactly, and all three degradation values are 0.0. The sixth is the R=2,293/τ=8.0/margin-0.0 row: 88.9% skipped, 64.5% saving, degradation (0.0, -0.8, -3.9). The skip set sits at or below the corpus on every metric, because the gate also skips empty-manifest decisions whose top-1 is below the 6.0 production gate.

Under the pre-registered rule (largest skip share), the best safe config is the τ=6.0/margin-0.0 family. All five members tie at 100% skipped, and the best reported in the sweep's ascending-R evaluation order is the R=128 arm. It is also the family ceiling: 95.7% saving, an average of 56.7 tokens per decision (median 0), and an overhead of 0.01801%. It shows the ceiling a scope-filtered deployment with an effective pool of 128 entries or fewer can reach. At production scale R=2,293, the same family skips 100% of the frozen holdout with a 71.6% bill reduction and zero measured accuracy loss.

The margin-2.0 and high-τ configs skip only the high-confidence subset, so their skip sets sit systematically above the corpus lite baseline. At R=2,293/τ=6.0/margin-2.0, skip-set top-1 is 66.7 against 48.9 for the corpus, +17.8pp. The conservative pre-registered rule excludes exactly this from the safe set: on a 63-case frozen holdout, a gate that skips only easy cases will inevitably look better than the corpus, and that pattern is selection, not guarantee. If production monitoring confirms the lift, these remain legitimate operating points. The distribution-free alternative is conformal deferral, and per-decision cost/accuracy logs are the natural monitoring substrate.

The gate's claims come with three boundaries. First, the gate is not a quality gate: it decides which pipeline pays, not which skill is correct. Second, the gate skips must-not-use decisions too. At τ=6.0/margin-0.0, all 8 negative cases are inside the skip set, and the rejection is handled by the 6.0 production gate on injection, not by the skip gate. Third, the measured claim is strictly limited to zero degradation relative to the lite baseline on the frozen holdout; it is corpus-level, not distribution-free. And the gate's entire cost is one BM25 retrieval.

## What Remains for the Company, for Society, and for Science

For the company, this paper measures for the first time the actual token burden of the router pipeline in harnesses with 2,200-plus skills and overnight loops. It makes conditional routing, that is a duty-cycle policy, decidable on evidence, and the result lands directly in the operating cost of the token factory. Routing is no longer an always-on line item; it becomes a metered one at 0.13002% per decision (production scale, zero measured loss). In unattended overnight operation with 6 decisions per session, the full arm spends about $0.0125 per session on routing, while under the safe gate it is about $0.0037. Small numbers, but they compound across the fleet and across nights.

For society, it turns routing into a measurable cost line item. Fully autonomous agent operation becomes realistic even on a limited self-hosted H200 budget, and the accessibility of LLM automation goes up. The router becomes a duty-cycled, metered cost instead of a permanent tax.

For science, it introduces a new measurement axis, the routing overhead share, and records the first cost accounting of a router pipeline together with the empirically safe boundary of precondition-gate skipping. Every router paper from the past month measured how much the router saves; none measured how many percent of the agent loop's total tokens the router pipeline itself consumes through retrieval, reranking, and rerouting calls. This paper fills that accounting gap. Where the earlier Thinking Router study answered, under the assumption that the router runs, how much it can cut thinking, this paper answers whether the router runs at all. The two results compose: the gate fixes the measure of the execution set, and the Thinking Router's flip condition and water level continue to apply inside the set that is not skipped.

## Limitations: What This Paper Does Not Claim

There are six limitations. First, the hybrid lift cites the 2026-08-14 measurement and was not re-measured in this study; the break-even verdict inherits that staleness. Second, the serving rates and the miss-price card are declared conventions, and the dollar results move with them. Third, the holdout is 63 decisions from a single production corpus; the gate's safety boundary is corpus-level, not distribution-free, and the safe set can shift under a different corpus. Fourth, the bills are deterministic token counts, hence hardware-independent, but the latency figures were measured on the development node, not the serving fleet. Fifth, the task-side baseline (median turn, session) is from a single production day (2026-10-22), so the overhead shares inherit day-selection variance. Sixth, the bills were counted with the declared Qwen3-family tokenizer and may differ from the serving model's actual tokenizer counts.

Four follow-up directions are open: a distribution-free gate guarantee in the spirit of conformal prediction, online calibration of τ and the margin from per-decision logs, per-session adaptive duty cycling, and a measured energy-cost twin of the gated duty cycle.

The token bills, overhead shares, and skip shares in the text are measured values from a CPU-only container. The serving rates and the miss-price card are declared conventions, and the hybrid-versus-BM25 lift cites the 2026-08-14 measurement.

The paper and its companion materials are available on Hugging Face.

https://huggingface.co/datasets/thaki-AI/daily-paper-2026-10-23-router-toll-overhead-share-gate
