---
title: "The Description Budget: How Much Text a Skill Description Needs, and How the Precision-Per-Prompt-Token Frontier Moves with Registry Size"
seo_title: "The Description Budget paper introduction. In a retrieval-based agent harness, each skill's description is a dual-role artifact: the same text is the index signal for the router's BM25+embedding fusion and the payload injected into the per-request prompt. This paper formalizes that role as a description-budget problem and derives the first-order structure by KKT analysis under four assumptions (A1 coverage concavity, A2 linear collision load, A3 mean-field Plackett-Luce, A4 sublinear cluster saturation). The closed-form budget rule (Proposition 2) gives each skill's optimal length as the log of the ratio of traffic-weighted discrimination value to cache-adjusted payload price, L_i*(N) = (1/θ_i) ln(α_i θ_i (1+ζ m_i(N))/c_eff). Theorem 1 eliminates surface mass (boilerplate) at the optimum, L_s* = 0, and a corollary bounds the allocation inefficiency of a uniform budget by the variance of traffic weights. As the registry grows from 500 to 2,200 skills, the sign of the frontier shift is a priori uncertain: A4 gives a rising log-N law, while A4' (dense cluster) gives a non-monotone frontier with a measurable peak, so the confusion-pressure index separates the regimes (pre-registered P1). Cache-aware rewrite payback (Proposition 4) shows a payback cliff at the prefix-cache threshold (around 3,500 tokens, plateau ρ ≈ 0.83): a depth just below the threshold is strictly dominated by a depth just above it (P3). Proposition 5 composes corpus-side, retriever-side, and compute-side levers additively in log space to first order and orders their application by amortization. The measurement protocol, with a ladder rewrite (about 5/12/20/30/40 tokens) and a registry sweep (N ∈ {500, 1,100, 2,200}), along with falsification conditions P1-P3, is pre-registered; this paper is an analytical paper and reports no new measurements. - ThakiCloud"
seo_description: "In a retrieval-based agent harness, a skill description is a dual-role artifact that serves as both an index signal and a prompt payload. This paper formalizes that role as a description-budget problem and gives, in closed form, the result that each skill's optimal length is the log of the ratio of traffic-weighted discrimination value to cache-adjusted payload price. Surface mass is eliminated at the optimum, a uniform budget is dominated, and rewrite payback shows a cliff at the prefix-cache threshold. This is an analytical paper, and the measurement protocol is pre-registered."
excerpt: "The same text that makes a skill retrievable is what makes it expensive. This paper prices both roles of the description at once and gives each skill's optimal length as a closed-form log law. The sign of the frontier shift as the registry grows from 500 to 2,200 skills is the test that separates the regimes."
date: 2026-10-10
tags:
  - skill-description-verbosity
  - retrieval-precision
  - prompt-inflation
  - cost-quality-frontier
  - registry-scaling
  - bm25-embedding-fusion
  - agent-harness
  - skill-ecosystem
  - sra-bench
  - token-cost-optimization
categories:
  - research
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/en/research/description-budget-skill-verbosity/"
---
If you run a retrieval-based agent harness with a skill registry, or you own a system that injects skill descriptions into the per-request prompt, this article is for you. In that architecture, the description is the point where retrieval precision and per-request token cost are traded at the same time. This paper amounts to a closed-form answer to that trade. ThakiCloud's latest paper, **"The Description Budget: Measuring the Retrieval-Precision versus Prompt-Inflation Frontier of Skill-Description Verbosity Across Registry Sizes in a 2,200-Skill Agent Harness"**, formalizes the dual role of a skill description, index signal and prompt payload, as a description-budget problem. It answers two questions: how much description text each skill needs, and how the precision-per-prompt-token frontier moves as the registry grows from about 500 to 2,200 skills. It is an analytical paper: it derives the frontier in closed form and pre-registers a measurement protocol that tests it.

## The Problem: The Same Description Is Both an Index Signal and a Prompt Payload

In the unattended agent harness at the center of the paper, every user turn passes through a hybrid retrieval step. For each skill description, a lexical BM25 score and a dense embedding similarity are fused. That fusion is computed on the hot path of every request. The registry has grown from 1,600 skills, serving mixed Korean-English queries, to 2,200. Indexing and injection are both handled by one free-text block: the skill description.

The same text that makes a skill retrievable is what makes it expensive. Every token of the injected description is paid again on every incoming request, after the prefix-cache discount is subtracted. The more verbose and boilerplate-heavy it is, the stronger the distractor it becomes for neighboring queries, because each word that goes into the index adds collision opportunities for off-target queries. Verbosity trades retrieval precision against per-request cost in opposite directions at the same moment.

![Dual-role structure of a skill description](/assets/images/posts/research/description-budget-skill-verbosity/dual-role.webp)
*The same text d_i serves as the retrieval index signal (coverage gain and collision loss) and as the injected prompt payload (cost and reader degradation), forming the three channels of the description-budget objective function. (Conceptual example: a structure diagram of the three value/cost channels, coverage, collision, and payload, and their signs.)*

The lineage of this question starts with Gorilla. Gorilla in 2023 connected a fine-tuned LLaMA model to a huge API corpus through a document retriever, and it also showed that retrieval substantially mitigates hallucinated API use and adapts to document changes at test time. But it took the corpus text as given. It never asked how much text each API entry needs, and the per-request cost of injecting retrieved text into the prompt was not a modeling target. The 2026 wave of skill-ecosystem research attacks the same problem from the selection side, the rewriting side, the compression side, the compute side, and the security side. None of it models the dual-role budget frontier across registry sizes. This paper defines exactly that target, and it deliberately upgrades Gorilla's architecture.

## The Budget Rule: Optimal Length Is the Log of Discrimination Value over the Cache-Adjusted Payload Price

The paper splits the L_i tokens of a skill description into capability content L_c and surface mass L_s. Capability content carries what the skill executes, when, and on which targets; surface mass carries boilerplate and repetitive phrasing. Under a fixed structural template of name, one-line capability, and boundary sentence, the capability share is constant across length levels, so a move along the ladder is a pure length move.

The expected value per request, V_i, is written in four terms. The first is traffic-weighted coverage: capability tokens cover the skill's executable region at a Poisson rate, and in a crowded cluster the coverage is amplified by (1+ζ m_i). The more crowded the cluster, the more work each capability token does. The second is collision: each surface token imposes confusion on m_i(N) confusing neighbors at rate β. In the BM25 half, the more indexed words there are, the more opportunities off-target queries have to collide; in the dense half, boilerplate drags the embedding toward the generic cluster direction. The third is the cache-adjusted payload price, c_eff L_i. The fourth is the reader degradation term Q_reader, which is negative or zero. The tension of the dual role lives in this single equation, because crowding raises the value of capability and the price of surface at the same time.

Under the assumptions A1 (coverage concavity) through A4 (sublinear cluster saturation), the KKT analysis gives three results. The first is Theorem 1. V_i is jointly concave in (L_c, L_s), a unique global maximizer exists, and at the optimum the surface mass is eliminated. L_s* = 0. Boilerplate does not shrink; it disappears entirely. The robustness assumption A5 sharpens this: once the confusion pressure m_i exceeds the threshold c_eff/β, the optimal description is pure capability content. The second is Proposition 2, the closed-form budget rule.

L_i*(N) = (1/θ_i) ln(α_i θ_i (1 + ζ m_i(N)) / c_eff)

Each skill's optimal length is the log of the ratio of traffic-weighted discrimination value to cache-adjusted payload price. The comparative statics read off directly: the higher the traffic weight α_i, the longer; the more crowded the neighborhood m_i, the longer; the more expensive the token price c_eff, the shorter. The third is the corollary. A uniform budget is dominated. Giving every skill the same length under the same total budget loses up to (1/2) Σ c_eff θ_i (L_i* - B/N)², and the variance of the traffic weights becomes a measurable upper bound on the allocation inefficiency of the "everyone gets the same length" authoring practice.

## The Frontier Shift from 500 to 2,200: The Sign of the Shift Decides Which Regime Is True

The paper does not give a single answer for how the frontier moves as the registry grows from 500 to 2,200 skills. The sign of the shift is uncertain a priori.

Under A4 (sublinear cluster saturation), the confusion mass grows on a log scale, m_i(N) = m_0 + Δm ln(N/N_0), and the frontier rises monotonically as a log-N law. A more crowded registry makes capability content more valuable, so the optimal length grows. Under the alternative regime A4' (dense cluster), the confusion mass enters the price linearly, m_i ∝ N, while the discrimination value saturates, so only the collision plus payload price keeps growing. The frontier then becomes non-monotone and peaks at an interior N†. In the paper's schematic, the peak is near 750 skills and the crossing with the A4 frontier is near 1,560. The parameters are example values.

The paper does not argue for one of the two regimes. Both are functional forms of the unknown function m_i(N). The content of the paper is that the two forms give differently shaped frontier shifts, and that a measurable object, the confusion-pressure index m̄(N), separates them. That is the pre-registered falsification condition P1. If L*(2,200) - L*(500) exceeds 10 percent of the 500-skill length and m̄(N) is sublinear in N, the data picks A4 and the log law is confirmed. A non-monotone frontier with a measurable peak picks A4'. A frontier that is flat within the confidence interval falsifies the dual-role tension itself.

![Optimal description length across registry size: two competing regimes](/assets/images/posts/research/description-budget-skill-verbosity/frontier.webp)
*The A4 sublinear-cluster frontier rises as a monotone log-N law and the A4' dense-cluster frontier takes a non-monotone form with an interior peak; the sign of the frontier shift between 500 and 2,200 identifies the regime. (An analytical model, not a measurement.)*

## The Rewrite Payback Cliff: Cross the Cache Threshold, or Stay Close to It

Proposition 4 prices a registry-wide rewrite, since the one-shot cost is R×N, the sum of the rewrite and the index rebuild. The per-request saving S can also depend on whether the rewrite crosses the prefix-cache threshold. The production cache measurements the paper cites are two-tier: below a sharp threshold of about 3,500 tokens the hit rate plateaus at ρ ≈ 0.83, and the discount above it is different.

![Rewrite payback across the prefix-cache threshold](/assets/images/posts/research/description-budget-skill-verbosity/payback-cliff.webp)
*A registry-wide rewrite that stops just below the cache threshold saves strictly less per request than a rewrite that crosses it, because the moment the threshold is crossed the entire surviving prefix is repriced at the higher plateau discount. (An analytical model, not a measurement.)*

If the rewrite depth ΔP stops just below the threshold, only the tail tokens are removed, and they are priced at the above-threshold discount. Cross the threshold, and the entire surviving prefix is repriced at the new discount, and the saving can jump by p_in (ρ_b - ρ_a) P_t. A depth just below the threshold is strictly dominated by a depth just above it. The optimal depth is either the full budget target or the crossing depth; there is no point extremely close to, but not reaching, the threshold. That is pre-registered P3. A single-slope payback with no jump falsifies the two-tier repricing mechanism.

On top of that, Proposition 5 composes the three levers. The corpus-side budget b = L*, the retriever-side quantization distortion ε and fusion weight w, and the compute-side router thinking allocation t. In the local regime, end-to-end task quality decomposes as Q = Q̄ (1+η_c)(1+η_s)(1+η_r), and the levers compose additively in log space to first order. The shape of the frontier is preserved and only its position moves. The economically correct order of application is amortization. b comes first, because its one-shot cost RN is repaid across all future requests. Then ε, which is applied offline at each retriever rebuild. Then t, the lever that costs per task. The description budget is the most heavily amortized lever, and it adds a corpus-side axis to the retriever-side and compute-side results of the earlier reports.

## What This Leaves for the Company, Society, and Science

The first thing it leaves is for ThakiCloud. The autonomous repair loop of the unattended agent loop rewrites skill descriptions every night, and there was no length policy. On 2026-10-03, the collateral routing drift caused by unbounded rewriting was measured. The budget rule is a standing constraint that gives the repair loop a measurable length ceiling, per skill and per registry size. It stabilizes SRA routing and lowers the structural token cost of the unattended loop.

For society, the scope widens. Self-hosted agent platform teams operating large skill/MCP ecosystems pay for description tokens on every request. An ecosystem-level survey of the Model Context Protocol counted 368,754 server listings across 17 marketplaces, and 98.5 percent of tools have at least one functional alternative. That is exactly where the confusion mass m_i(N) is large. Description length is a registry-level externality: the collision term β m_i L_s pushes the precision loss of neighboring skills onto each skill's author. A per-skill length budget internalizes part of that externality. The budget itself is a price. A published description-budget recipe gives teams a way to audit and remove this waste without quality loss.

For science, this is the first study to separate the two roles of skill description text, the retrieval index signal and the prompt context, under controlled experimentation. The registry-size-dependent Pareto frontier and the description-budget scaling law are an axis that does not overlap with the existing router-scaling results, which varied only the registry size. If Gorilla connected the LLM to a huge API corpus through a retriever, this paper prices the corpus itself.

## Limitations: Every Number Is a Model Estimate on Top of Stated Assumptions

Every number in the paper is a model estimate derived under explicitly stated assumptions. A1-A5 are the hypotheses the measurement protocol fixes. The A4 versus A4' labels remain an open empirical question. This paper is an analytical paper and reports no new measurements.

The scorer is a single hybrid family: one embedding model and a fixed fusion weight w. Adaptive fusion would change the price terms. The injection is static and there is no packer; packing would change what the reader retains. The reader degradation term Q_reader is a placeholder, and no position-dependent form was modeled. The cache parameters beyond the cited 3,500-token threshold are deployment-specific and are set by the C1-C2 conditions.

To close this gap, the paper pre-registers a measurement protocol. A ladder rewrite of about 5, 12, 20, 30, and 40 tokens per skill; a registry sweep over N ∈ {500, 1,100, 2,200} that preserves the functional cluster composition; and per-cell records of recall@5, top-1 accuracy, retrieval-level hallucination rate, per-request prompt token inflation, downstream task success, and the confusion-pressure index. Per-cell bootstrap confidence intervals, a frozen audit set stratified by cluster and traffic quartile, and code and registry snapshot fixed before execution. The analysis rules are fixed before the measurement, so they cannot be changed to fit the data.

The paper and its accompanying materials are available on Hugging Face.

https://huggingface.co/datasets/thaki-AI/daily-paper-2026-10-10-description-budget-skill-verbosity
