---
title: "The Prompt Rot: Rot and Revert Dividend of a Harness That Rewrites Its Own System Prompt Every Night"
seo_title: "The Prompt Rot paper analysis - the nightly self-evolution loop of a 2,200-skill unattended agent harness stacks self-edits into the system prompt (the highest-leverage text in the loop, retransmitted on every call), producing capability drift (prompt rot) and token cost expansion, and this post measures in closed form where the revert dividend of undoing the accumulated edits sits. APC re-prefill taxonomy for the append-only regime (Theorem 1), the revert dividend identity and a random-revert order independence test (Theorem 2), a two-prong drift decomposition into dilution vs semantic override (Theorem 3), a quality-gate revert policy with a closed-form rot budget (Theorem 4). Five nights of observed edits deterministically inflate the 224-token baseline to 669 tokens (+198.7%, cl100k_base). Pre-registered frozen-holdout mutation testing protocol (6 arms, 15 routing + 15 BFCL tasks, H200, falsification criteria F1-F5). All values are model predictions under declared nominal assumptions - ThakiCloud"
seo_description: "An unattended agent harness retransmits its own system prompt on every call, and the nightly self-evolution loop can edit that prompt. This paper puts a price on rotting the system prompt, the last editable text layer after skill descriptions and manifests. Append-only self-editing pays a minimum APC tax equal to its own size, reverts are cache-free, the revert dividend decomposes per edit, and path dependence is tested by random revert orders. Drift splits exactly into dilution and semantic override, and the revert policy is a quality gate, not a cache gate. Five nights of observed edits deterministically inflate the 224-token baseline to 669 tokens (+198.7%). The capability axis is what the pre-registered protocol measures, and every reported value is a closed-form prediction under declared nominal assumptions or a deterministic count of declared artifacts, not a measurement."
excerpt: "This post measures the rot of the system prompt, the highest-leverage text in the loop, under nightly self-editing. Under the append-only regime, rot is cache-cheap and reverts are cache-free, and the revert dividend D_K grows linearly in fleet call volume. Drift decomposes exactly into dilution and semantic override, and the revert policy trips on the quality gate. The five nights of edits inflating the 224-token baseline to 669 tokens (+198.7%) is a deterministic fact, and the capability axis is what the pre-registered protocol measures."
date: 2026-11-03
tags:
  - prompt-rot
  - capability-drift
  - revert-dividend
  - system-prompt-self-editing
  - self-evolving-agent-harness
  - apc-prefix-caching
  - frozen-holdout-evaluation
  - overnight-automation
  - sra-bench
  - h200-serving
permalink: /en/research/overnight-prompt-rot-revert-dividend/
categories: [research]
author_profile: true
toc: true
toc_label: "Contents"
toc_sticky: true
reading_time: true
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/research/overnight-prompt-rot-revert-dividend/"
---

If you run an unattended agent overnight on your own GPU fleet, and have let the dawn self-evolution loop rewrite not just skills but the agent's own system prompt, this post is for you. The system prompt is the text retransmitted at the head of every call across the fleet. It is also the highest-leverage text in the loop. This post measures how much the self-edits that accumulate night after night inflate this text, what capability drift they leave behind, and what reverting the accumulated edits costs and what it gets you. The paper calls this drift prompt rot and calls what you gain from reverting it the revert dividend.

![Illustration of the core idea of The Prompt Rot: Rot and Revert Dividend of a Harness That Rewrites Its Own System Prompt Every Night](/assets/images/overnight-prompt-rot-revert-dividend-hero.webp)
*A visual metaphor for the article's key idea.*

## The Last Editable Text Layer That Has Never Been Measured

A 2,200-skill unattended agent harness is served on a self-hosted H200 fleet. Each call sends a stream of the system prompt P at the head, the tool schema TS after it, and a task-specific suffix u. P is shared by the whole fleet and retransmitted from the start on every call.

In this loop, the text that can be rewritten every night sits in three layers: the skill descriptions (the SKILL.md manifest the router reads), the shared skill manifest prefix, and the harness's own system prompt. The first two layers have already been priced as rotting objects. What Silent Reroute priced was the incidental routing drift of description edits, and what Unstable Prefix priced was the KV cache amortization of manifest churn and the square-root freezing period k*. Of the three layers, the system prompt is the last one that has never been measured. It is at once the most expensive object (retransmitted to the entire fleet on every call) and the most influential one, because the protocol rules it contains (one tool call per turn, routing tie-breaks, giving up) are what all downstream capability measurements presuppose.

External literature shows that this layer is a real object, not a hypothetical one. One study found that instruction stacks measurably inherit across 1,886 releases of five commercial coding agents. Another found, in an audit of 150 servers, that surface text around the model (error messages, tool descriptions) changed tool-calling behavior. A third showed that agent markdown files are active injection targets. The unattended loop is now, by itself, editing the very text layer that vendors propagate release by release to steer tool calls in a re-measurable way and that attackers target.

In the real harness, things have already happened. Five nights of self-edits are observed from 2026-10-29 to 2026-11-02. Each edit is tagged with [Learned <date>] and appended below the baseline protocol.

| Edit | Date | Type | Tokens |
|---|---|---|---|
| e1 | 10-29 | Policy drift (batching preference) | +60 |
| e2 | 10-30 | Benign inflation (write tool guardrail) | +81 |
| e3 | 10-31 | Policy drift (short description tie-break) | +73 |
| e4 | 11-01 | Policy drift (restatement before call) | +57 |
| e5 | 11-02 | Benign inflation (always-on preference) | +174 |

*Table: the five observed nights of self-edits (deterministic cl100k_base token counts). The types are declared in the edit bodies. P_0 = 224-token baseline, P_5 = 669 tokens (+445 tokens).*

These five edits inflate the 224-token frozen baseline to 669 tokens, +445 tokens, 198.7%. The cost axis is already a fact on paper. Two questions remain: how does the capability axis move, and what does reverting buy?

![Cumulative system-prompt inflation from five observed nightly self-edits](/assets/images/posts/research/overnight-prompt-rot-revert-dividend/fig_token_inflation.png)
*The five declared append-only self-edits (2026-10-29 to 2026-11-02) deterministically inflate the 224-token frozen baseline prompt to 669 tokens (+445 tokens, +198.7%) under cl100k_base. Analytical model figure, not a measurement. Token counts are deterministic counts of declared artifacts.*

## Under the Append-Only Regime, Rot Is Cache-Cheap and Reverts Are Cache-Free

The serving engine's cache accounting is simple. Under exact-match automatic prefix caching (APC), a cached token costs the declared fraction β of the fresh token price, and an uncached token costs 1. The first call right after a version-change event recomputes the uncached suffix from the longest common prefix (LCP) length with the cache state, and the remaining N calls of that night retransmit the prefix at the β rate. β is a declared value of the self-hosted amortization regime, not a measured one.

Theorem 1 gives a closed form in which the position of the edit determines this tax. It compresses into three terms.

The tax of an append-only (suffix-additive) edit is (s_k + τ)(1-β), the edit's own size plus only the schema suffix: the minimum tax among all placements of the same edit, because the frozen baseline survives in the cache as the longest stable prefix. The tax of an in-place fix edit is (t_k - p' + τ)(1-β) from the fix position p' to the end, maximal at p' = 0. In that limit the entire stable prefix is re-prefilled, which is exactly where the churn regime and the square-root freezing period k* that Unstable Prefix priced come back to life. Last, the tax a revert event pays. Under the append-only regime the baseline P_0 is a prefix of every version, so a revert re-prefills only the schema suffix τ(1-β) while the LCP survives all the way to t_0. That is the tax every version-change event already pays, so the incremental cache cost of a revert is 0. The paper calls this an APC-free revert.

All of the observed nightly edits carry this append-only regime. Each edit in the table sits below the baseline protocol with a [Learned <date>] tag. Two consequences follow. First, rot under this regime is cache-cheap: each night pays its own edit size s_k(1-β) once, and the recurring cost is the share of the inflated prefix retransmitted at the β rate. Second, reverting the rot is cache-free: the baseline never leaves the cache, so a revert recomputes nothing beyond what the edit event already prefilled.

The cost-axis revert dividend comes out in closed form as a corollary. Reverting before the N calls of a night on which K edits have accumulated saves D_K = N·β·(t_K - t_0) + s_K·(1-β) per session. The first term is the recurring prefix dividend, the share of the inflated prefix that disappears across all N calls; the second is the re-prefill dividend, the share of never paying the fresh tax of the last edit. D_K grows linearly in fleet call volume N and is strictly positive for K >= 1 whenever β > 0.

![Placement taxonomy: APC re-prefill tax by nightly edit regime (Theorem 1)](/assets/images/posts/research/overnight-prompt-rot-revert-dividend/fig_placement_taxonomy.png)
*Under exact-match automatic prefix caching, an append-only self-edit pays the minimum tax (its own size plus the schema suffix), an in-place edit pays the maximum suffix tax, and a revert of the accumulated edits is APC-free because the frozen baseline is the longest common prefix of all versions. Analytical model (not a measurement).*

## How Much That Night's Edit Hurt, and How to Attribute the Harm

The capability axis is structured to be measured over a frozen holdout. The combination of a fixed task set, deterministic grading, and temperature 0 makes capability C(P) a function reproducible from the prompt P alone. In this structure, drift is a property of the edit sequence, not of the evaluator. It is a mutation testing regime for prompt space: each night's edit is treated as a mutation, and each arm as a regression run.

The drift of the night k edit is written as δ_k = C(V_{k-1}) - C(V_k) (positive when the edit hurt capability). The second theorem (Theorem 2, the revert-dividend identity) splits into three branches.

The first is telescoping. The total capability revert dividend R_K = C(V_0) - C(V_K) matches exactly the sum of the per-edit dividends measured on the time-ordered arms, R_K = Σ_k δ_k. The accumulated dividend is an identity that unravels into the sum of the per-edit dividends.

The second is attribution. On the solo arm U_k = P_0 || e_k, the arm with only edit k attached, the solo effect is written as μ_k = C(P_0) - C(U_k). Under the pairwise interaction regime, the time-ordered per-edit drift splits as δ_k = μ_k + Σ_{i<k} γ_ik. Edit k's attribution being context-independent (δ_k = μ_k) is exactly equivalent to all pairwise interactions γ_ik between edit k and the edits before it being 0.

The third is an order-sensitivity test. M random surgical revert paths ω, each undoing the edits one by one from V_K back to V_0, are drawn. Every path ends at the same total R_K, but the schedule of the step-by-step increments changes with the path. With a deterministic grader, a fixed holdout, and temperature 0, the spread of that schedule across the random paths becomes a noise-free indicator of path dependence (that is, of nonzero interaction terms).

This theorem separates two questions: how much did that night's edit hurt (δ_k, a pair of arms is enough), and can that harm be attributed to edit k (μ_k plus interaction tests, which require the solo arms and the random paths). What a revert policy actually needs is the latter. A rule that hurts capability only in the presence of other accumulated rules must not be attributed and reverted on the strength of solo measurements alone.

## Two Mechanisms of Rot: Dilution and Semantic Override

The total drift T_K = C(V_0) - C(V_K) splits exactly into two pieces by telescoping over three capability values. It is an identity with no model assumptions: T_K = D_K + S_K.

D_K = C(V_0) - C(F_K) is dilution, the part the filler arm F_k accounts for. F_k is the arm with neutral text of the same length as the added tokens appended, and it carries no operational content at all. It is the effect when the content is neutral and only the length grows. S_K = C(F_K) - C(V_K) is semantic override, the effect the actual content has at matched length.

Two contrasts come from the swap arm and the solo arm. The placement contrast Pos_K = C(V_K) - C(W_K) uses the swap arm W_k: the difference between the arm that places the same content above the baseline protocol as a prefix and the arm that places it below as a suffix. The content and the length are the same; only the position of the rule differs. This contrast isolates the positional authority of suffix placement. The interaction residual I_K = T_K - Σ_k μ_k is the pairwise interaction term left after summing the solo effects.

The dilution mechanism works like this. Added tokens change the evidence structure of the context even when their content is neutral, which lines up exactly with the existing result that long-context difficulty is not length itself but the fact that baseline protocol sentences, as they get pushed toward the middle of the prompt, are trusted less. The override mechanism is position. Learned rules sit between the baseline protocol and the task turns. As long as the position of an instruction exerts influence on behavior through the channel, a suffix tie-break or batching preference that looks harmless semantically can carry more authority than the protocol that precedes it. Interactions come from the tendency of failure-derived rules to overfit to the night that produced them. Composed behavior is not the sum of solo behaviors.

![Two-prong drift decomposition and the frozen-holdout arm families (Theorem 3)](/assets/images/posts/research/overnight-prompt-rot-revert-dividend/fig_drift_decomposition.png)
*The total capability drift over the frozen holdout splits exactly into dilution (added length of content-neutral text) and semantic override (added content at matched length), and placement and interaction are separated by dedicated filler, swap, and solo arms. Analytical model (not a measurement).*

## So How Does Operations Change: A Quality Gate, Not a Cache Gate

The fourth theorem (Theorem 4) gives the revert policy in closed form. The expected cost of keeping the accumulated stream on night k is K_k = c·[N·β·(t_k - t_0) + (1-β)·s_k] + m·q·max(0, δ_k). The first bracket prices the cost-axis dividend (the corollary) at the per-token rate c, and m·q·max(0, δ_k) corresponds to the quality loss when an edit hurts capability. m is the per-task miss rate inherited from the routing series, q is the expected number of tasks per night, and v_k is the declared option value of rule k, kept conservative because failure-derived rules cannot generalize.

The revert rule is this. If K_k > Σ_{j≤k} v_j, revert the accumulated stream to P_0. The rot budget B*(k) = (Σ_{j≤k} v_j - m·q·max(0, δ_k)) / (c·N·β) is the cap on accumulated inflation at which a forced revert fires regardless of the quality signal: once t_k - t_0 exceeds it, the revert is mandatory.

The key is the nature of the policy. Under the append-only regime, no cache-penalty term enters the revert decision. The one-time tax of a revert event is τ(1-β), identical to the tax any future edit event pays, so it cancels out in the comparison. The guardrail trips on the quality gate (δ_k exceeding the declared tolerance ε) or the inflation budget B*, never on the cache. Under an in-place fix regime the story changes: the revert pays a (t_0 - p'')(1-β) penalty and the cache does trip it, and Unstable Prefix's square-root freezing law re-emerges as a special case of the same policy.

There is one more recurrence guardrail. The revert policy is only as strong as the loop's behavior after the revert. If the loop later re-proposes a rule that was reverted, the realized dividend turns into a re-derivation cost. So a re-proposed edit must satisfy two conditions at once to be admitted: the solo arm U_{k'} passes the quality gate on its own (a net gain in solo), and the loop cites new evidence distinguishable from the original failure. It is the admission step left by the formalization of harness self-evolution, reflecting the try-before-you-evolve experimental regime and the attribution-before-edit curation.

Compressed to one line, the guardrail is this. Keep edits append-only but put them through the quality gate, keep a rot budget on inflation, and when the gate or the budget trips, allow the revert freely. If a rule wants back in, new evidence is required then.

For the company, this policy enters as the measured guardrail of the dawn self-evolution loop: the night-by-night capability drift numbers over the frozen holdout, the deterministic prompt-size cost inflation numbers, and the revert-dividend policy that decides when to roll back accumulated system-prompt edits. It adds a text-layer regression gate to the existing routing CI and becomes the third priced layer after the description layer (Silent Reroute) and the manifest layer (Unstable Prefix).

For society, as self-improving agent harnesses become more unattended, the premise is a public audit methodology that measures how prompt self-editing quietly erodes capability and how cheap it is to revert. The protocol is a mutation testing regime for prompt space: treat each night's edit as a mutation, re-measure over the frozen holdout, and price the revert.

For science, there is the first characterization of capability drift and reversibility in the system-prompt space of a self-evolving agent harness, with four theorems: the placement taxonomy of APC cost (Theorem 1), the revert-dividend identity and the path dependence test (Theorem 2), the two-prong drift decomposition with identification conditions (Theorem 3), and the quality-gate revert policy with a closed-form rot budget (Theorem 4).

## The Protocol That Turns Theorems Into Numbers, and What Not to Believe

The theorems become measurable by a pre-registered protocol without changing a single formula. The arms are six time-ordered cumulative arms, V_0 through V_5, five solo arms, U_1 through U_5, a filler arm F_5, and a swap arm W_5. Per-k filler and swap arms for the full decomposition schedule are optional. The holdout Φ is fixed at 15 real labeled routing tasks (sra_bench positive cases, gold skills retained, a Korean-English surface form matching the fleet query composition) and 15 BFCL-style tool-calling tasks over 6 real tool schemas (gold by construction). Grading is deterministic, on three axes: routing accuracy (the model's route_to_skill call matching the gold skill id), tool-call success (the correct function name), and argument success (the presence of all required arguments). Serving is self-hosted H200, a haiku-class model behind an Anthropic-compatible gateway, temperature 0, per-call usage metering. The declared nominal values are also stated. The tolerance ε has the granularity of one holdout task: with w_R = w_T = 1/2, one routing task or one tool-calling task is 1/30 of the weighted score C. The per-token rate c is the declared self-hosted haiku-class price, an assumption, not a measurement.

The falsification criteria are pre-registered as F1 through F5. F1 (cost-axis consistency) requires the gateway-metered input tokens to match the deterministic count (version prompt + task suffix + schema) within a declared band, falsifying any hidden prompt transformation between the artifact and the actual transmission (template expansion, schema re-injection). F2 (rot direction) rejects the net-rot hypothesis under this regime if every nightly edit improves the holdout (δ_k <= -ε for all k): the guardrail works, but it is not a rot story. F3 (order sensitivity) states that if the 95% bootstrap CI of the step-by-step dividend spread across M random revert paths excludes 0, attribution is path dependent and the pairwise interaction terms are nonzero. F4 (additivity) is the criterion that if |I_5| <= 0.1·max(T_5, ε), the approximately additive regime holds and per-edit attribution is sound, while exceeding it triggers the factorial experiment extension. F5 (APC-free revert) requires the re-prefill bytes of the revert event in the serving telemetry to match the neutral version-change baseline (schema-suffix scale) within a declared band.

This is an analytical paper. It claims no empirical capability drift. Every reported number is one of: a deterministic count of declared artifacts, a closed-form prediction under declared nominal assumptions, or a result from cited literature. Running the protocol turns each theorem into a single number, and not one formula changes in between.

The limits are listed explicitly.

First, holdout staleness. δ_k measures drift against the current task distribution, so updating the holdout during a study changes the reference point. Within a study it is frozen by construction; between studies it must be updated at a declared cadence; and drift numbers are comparable only across updates that are append-only to Φ itself.

Second, the edit corpus. The five observed edits are a small declared sample. Because the composition of 2 benign inflations and 3 policy drifts is not random, which edits drift is corpus-dependent. The theorems are distribution-free in this respect, because the placement taxonomy, the identity, the decomposition, and the policy hold for any append-only edit sequence. But in this corpus, the magnitude of T_K is a single observation waiting on the protocol.

Third, the APC model. It rests on exact-match prefix semantics, a declared β between the self-hosted amortization regime and API billing, a block-rounded cache with at most 16 tokens of residual per event, and it excludes the multi-tenant engine effects that a single-fleet regime rules out.

Fourth, the capability model. It measures at a single haiku-class tier at temperature 0, while some fleet calls route to larger tiers. Prompt rot may be tier-dependent. Since Transplant already measured capability retention under a model tier shift, the protocol declares one tier per arm and does not identify interactions beyond pairs. What F4 addresses is not higher-order term estimation but whether the approximately additive regime holds.

Fifth, the tokenizer proxy. The deterministic axis uses cl100k_base, a proxy for the serving tokenizer. F1 exists to keep that gap honest against the gateway-metering ground truth.

Sixth, the security surface. Self-editing in prompt space becomes an injection surface. Agent markdown files are a jailbreak propagation vector, and the night loop is another author of that text. The revert policy is also an isolation lever: a revert bounds the blast radius of a bad or malicious edit, but adversarial edits are out of scope.

Seventh, a single fleet. The measured object is our own harness. The locational claim is that the methodology, frozen-holdout mutation testing, placement-aware APC accounting, and a quality-gate revert budget, transfers to any self-editing agent harness. Commercial instruction stacks inherit across 1,886 vendor releases, so what is measured is universal even though this fleet is single.

---

The paper detail page and companion materials can be seen here: [The Prompt Rot: Measuring Capability Drift and the Revert Dividend of Overnight Self-Edits to the Agent Harness System Prompt in a 2,200-Skill Unattended Agent Harness on Self-Hosted H200](https://huggingface.co/datasets/thaki-AI/daily-paper-2026-11-03-overnight-prompt-rot-revert-dividend)

*This is an analytical paper. Every value in the body is a closed-form prediction under declared nominal assumptions or a deterministic count of declared artifacts, not a measurement. Every figure is an analytical model figure.*
