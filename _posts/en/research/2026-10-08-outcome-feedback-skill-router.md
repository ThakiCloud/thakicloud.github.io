---
title: "Learning Skill Selection from Outcomes: the Cost-Quality Frontier of a 2,000-Skill Unattended Harness"
seo_title: "Outcome Router paper introduction. In the ~2,200-skill unattended agent harness (sra_bench), it bandit-learns a selection policy over the K+1 arm of 'retrieved pool (K=5) + native non-injection' with the graded task outcome R = Q − λ·C (Q ∈ {1, 0.15, 0}, C is the injected description tokens). It is the last lever left after the stoker, fusion weights, skill text, and model tier have all been learned, and an explicit upgrade of the gatekeeper study (the lever moves from the scoring stage to the selection stage). The learner starts as an exact clone of the frozen policy π_0 (clone-then-deviate) and deploys under the freeze rule (deviation only with t_min=4 or more verified episodes), giving an in-sample regret O(Δ_r·√(|S|K ln K/T)) and the fixed-quality frontier containment c_L(q_0) ≤ c_0 + ρ_λ/μ_λ + o(1). It is not more expensive at frozen quality, and savings decompose into three terms: de-injection (W_0·c̄_inj), intra-gold substitution (ρ_eq·Δc̄_+), and quality surplus; without near-duplicate families, the first-order saving is 'not injecting the wrong skill.' On the generalization frontier, the realized fraction Φ of the holdout hindsight-oracle gain is bounded by Φ ≤ P(S)·G*_S/G*_ho + o(1) ≤ P(S)+o(1), P(S) ≤ (1+κ)·T_rec/t_min + o(1), and this bound is computed from the replay density of the training stream alone before the holdout is run. On a one-shot stream (T_rec=0), the router remains the frozen clone, so there is nothing to overfit; the train-holdout divergence |G_ho−G_tr| ≤ κ·P_tr(S)·G*_S + O(ρ_t)(P_tr(S)+P(S)) is the policy-level version of Goodhart shift. In the churn regime (persistent core + periphery that flows every night), skill-level global weights turn class-specific mass into transferable skill knowledge; in the disjoint regime they do not. The once-applied promotion gate (G1 retention γ=0.4, G2 fixed-quality savings δ=10%, G3 anti-hacking concentration ρ=0.3) structurally rejects when (1+κ)·T_rec/t_min < γ, and a pre-check is possible from R1 alone. The D1-D7 design rules and the R1/R2 (registry split in half, harder keyword mix) two-regime protocol are pre-registered. This paper is an analytical frontier; all values are model estimates under assumptions A1-A3', A4, and it reports no new measurements. - ThakiCloud"
seo_description: "The last lever of the skill router, the choice of 'which skill to inject,' bandit-learned with the graded outcome R = Q − λ·C. It is not more expensive at frozen quality (c_L(q_0) ≤ c_0 + ρ_λ/μ_λ + o(1)); savings decompose into de-injection, intra-gold substitution, and quality surplus, and the holdout realization fraction Φ is bounded by the replay density (1+κ)·T_rec/t_min. This is an analytical study and reports no new measurements."
excerpt: "The stoker was compressed, fusion was corrected, skill text was held up to the holdout, and prices were put on model tiers, but 'which skill to inject from the pool' was never learned. This paper bandit-learns that choice from graded outcomes and answers with bounds on fixed-quality cost and the holdout generalization frontier. There is no downside to learning, and overfitting is a property of the stream regime."
date: 2026-10-08
tags:
  - skill-routing
  - outcome-feedback-learning
  - contextual-bandit
  - frozen-retrieval-baseline
  - train-holdout-generalization
  - unattended-agent-harness
  - cost-quality-frontier
  - sra-bench
  - skill-ecosystem
  - self-improving-router
categories:
  - research
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/en/research/outcome-feedback-skill-router/"
---

If you run an unattended agent harness with a skill registry, or own a retrieval-augmented system that injects a skill description into the model context at every step, this article is for you. ThakiCloud Research's latest paper, **"The Outcome Router: A Cost-Quality and Generalization Frontier for Skill Selection Learned from Graded Task Outcomes in a 2,000-Skill Unattended Agent Harness"**, is an analytical paper that promotes the one lever that stayed frozen until the very end of the routing path to a learning target. We compressed the stoker's scores, corrected the fusion weights online, held skill text up to the holdout, and put a price on model tiers. But the policy that decides "which skill to inject from the retrieved pool, or none at all (native)" was never learned. This paper sets up a structure that bandit-learns that choice from graded task outcomes, the success score minus λ times the injection cost. And it answers with frontier bounds two questions: how much more expensive the learned router is than the frozen router at fixed quality, and what fraction of that apparent gain actually transfers to the holdout.

## The Problem: On the Routing Path, the Choice Itself Was Never Learned

In the sra_bench harness, the routing path works like this. A hybrid retriever, the fusion of the BM25 lexical lane and the dense embedding lane, ranks the roughly 2,200 skills in the registry into the context at every step and keeps the top K=5 as the pool. If the fused score of the top-1 skill exceeds the pre-registered threshold τ=6.0, that skill's description is injected; if not, the system goes native, that is, the model alone with no injection. This fixed rule, "inject the top-1 when the score exceeds the threshold," was the entire router until now.

When this router is wrong, it pays two costs at once. The description of a mismatched skill contaminates the context and quality drops, and the length of the injected description becomes token cost as-is. Because the harness is unattended, no one reads those traces. While the mistakes accumulate, no one sees them.

Earlier studies touched one lever at a time on this path. The gatekeeper study quantized the stoker's embedding model, the bandit-calibration study put the 3×3 grid of fusion weights and thresholds onto the bandit as arms, and the goodhart-shift study will measure the drift between train and holdout for the skill text that gets edited every night. The zero-token study priced the fixed-quality cost of routing between skills and model tiers, and the thinking-router study split the reasoning token budget between selection and execution. But in all of these studies, the way the stoker's output was consumed remained a fixed rule, or at most a coarse grid. There was no policy that learned from outcomes which arm, that is, which skill in the pool, to inject.

The experience of the bandit-calibration study matters here. With the arms on the (τ, w) grid and a binary success reward, the top-1 rate of the preferred arm was only 0.581, against a default of 0.558, and native-query hallucination jumped from 0.0 to 0.4. When the grid is narrow and the reward is discrete, learning leaves a null. That is exactly why this paper moves the arm from the (τ, w) grid to K+1 skill choices and changes the reward to graded outcomes.

This gap holds outside the family as well. The contextual bandit and budget-constrained router family chooses between model tiers but not between retrieved skills. This paper explicitly upgrades the gatekeeper study: the stoker is kept frozen as-is, and a selection policy is learned on top of it. Since the lever moves from the scoring stage to the selection stage, the comparison is valid under the same harness, the same registry, and the same frozen stoker.

![Outcome Router architecture: from frozen retrieval to outcome-updated selection](/assets/images/posts/research/outcome-feedback-skill-router/fig1.webp)
*The frozen hybrid retriever supplies the arm pool, the selection policy is learned from graded task outcomes, and deployment happens only after passing a once-applied holdout gate. (This is an analytical model, not a measurement.)*

## Core Contribution 1: The clone-then-deviate Bandit and the "Not More Expensive at Frozen Quality" Frontier

Written as a bandit, the allowable arms of the selection policy at each step are Ω_t = {1, …, K} ∪ {⊥}. That is K+1: the 5 skills in the retrieved pool plus the native non-injection arm. The reward is R_t = Q_t − λ·c(A_t). Q_t is a graded outcome that takes {1, α, 0} for success, neutral, and failure (α is pre-registered as 0.15). c(A_t) is the length of the injected skill description, that is, the token count, and the native arm has cost 0. λ is fixed within a run, and the sweep over the six values {0, 0.005, 0.01, 0.02, 0.05, 0.1} is each a separate experiment.

The learning rule is multiplicative weights (Hedge) plus optimistic imputation. The reward of the chosen arm uses the observed value R_t, and the unchosen arms are imputed by their own past running max. Initialization is **clone-then-deviate**: with all arm weights set to 1, argmax under the frozen-order tie-break matches the frozen policy π_0 exactly, so the learner starts as a precise clone of the frozen router.

What decides the deployment policy is the **freeze rule**. For any context class with fewer than t_min=4 verified plays, it remains exactly the frozen clone at all times; only classes confirmed 4 or more times may switch to the argmax arm. Every deviation is attributable to verified outcomes, and no matter how much the learner moves on unverified mass, it cannot affect deployment. Exploration ε_t = K/(t+K) only serves weight estimation. When registry churn occurs, the weight of the affected skill decays by ρ_w=0.97, and the learner forgets on the same schedule as the registry changes.

What this structure guarantees in-sample is the Proposition regret and the Corollary frontier. The expected reward of the learned router is at least the hindsight-optimal reward minus O(Δ_r·√(|S|·K·ln K/T)) regret, where Δ_r = 1 + λ·C_max, |S| is the number of seen classes, and the global variant is O(Δ_r·√(K·ln N/T)). Since the frozen policy π_0 is a fixed member of the policy space, the same lower bound, hindsight optimum minus the same regret, also exceeds the frozen reward. Translating this reward advantage into fixed quality gives frontier containment:

c_L(q_0) ≤ c_0 + ρ_λ/μ_λ + o(1)

μ_λ = (q_0 − q_lo)/c_0 is the slope margin of the frozen family. The first-order term of this inequality is the first claim of the paper: at the frozen quality q_0, the learned router is not more expensive than the frozen router. The saving is second order, and the Corollary cost decomposes that second-order term into three parts. (a) De-injection: removing the injection of misrouted skills themselves (W_0·c̄_inj). (b) Intra-gold substitution: switching to a shorter gold skill inside the pool during gold plays (ρ_eq·Δc̄_+). (c) Quality surplus: using the quality margin left by the learned policy to remove even more gold injections ((q_L − q_0)·c̄_gold). If there is no near-duplicate skill family and the surplus is small, (a) will dominate. The economics of fixed quality thus reduces to "not injecting the wrong skill." W_0, the frozen misroute mass, is determined by the recall and top-1 miss structure of the frozen retriever, which grows as the registry grows.

![Cost-quality frontier of the learned selection policy and the frozen family](/assets/images/posts/research/outcome-feedback-skill-router/fig2.webp)
*Schematic: near the operating point the reachable region of the learned policy sits weakly above the frozen family, so at the frozen operating quality the cost of the learned router does not exceed that of the frozen router. (Analytical model, not a measurement.)*

## Core Contribution 2: The Fraction That Reaches the Holdout Is Set by the Replay Density of the Stream

The in-sample bound only tells us "learning loses nothing." In an unattended environment, the question that really matters is what fraction of that apparent gain actually transfers to the holdout, that is, to unseen contexts. The paper's answer comes as a bound chaining two steps.

Φ = G_ho / G*(λ; D_ho) ≤ P(S)·G*_S/G*_ho + o(1) ≤ P(S) + o(1)

Φ is the fraction of the holdout hindsight-oracle gain, the gain if every arm had been chosen optimally in hindsight, that the final policy realizes. P(S) is the mass the holdout law places on "context classes seen t_min or more times in training," and G*_S/G*_ho is the per-unit gap ratio. Because the registered default is the assumption that the per-unit gap of unseen classes does not exceed that of seen classes (G*_U ≤ G*_S), the ratio simplifies to 1. And P(S) itself is bounded by a statistic of the training stream.

P(S) ≤ (1+κ)·T_rec / t_min + o(1)

T_rec is the training play mass of classes repeated two or more times, and κ is the regime constant (A3': within the seen set, p_ho(x) ≤ (1+κ)·p_tr(x)). The point of this bound is that it is computed from the class-level play counts of the training stream alone, before the holdout has ever been run.

The extreme case where the two bounds meet is the one-shot stream. If every class is played only once, T_rec = 0 and S = ∅, and thanks to the freeze rule the deployed policy is identical to the frozen clone on both streams. There is no apparent gain, no overfit gain, nothing to promote, and the gate structurally rejects this case. There is simply nothing to overfit in the first place.

The train-holdout divergence closes by the same logic: |G_ho − G_tr| ≤ κ·P_tr(S)·G*_S + O(ρ_t)·(P_tr(S) + P(S)). What this inequality says is that the size of overfitting is not a property of the learner but of the regime constant κ and the seen-mass oracle gain. If the goodhart-shift study turned the train vs holdout drift of skill-text edits into a law, this paper extends that split to the routing-policy level: it reduces the verdict "what was learned is overfitting" to the replay structure of the stream.

There is one more transfer regime to add. The local (per-context weights) and global (per-skill weights) variants are complementary. Under the skill-separability assumption (A4), in the churn regime (a persistent skill core and a periphery that flows every night), global weights convert class-specific mass into transferable skill knowledge. In the disjoint regime, where the registry content is split in half, the skill overlap mass P_ov ≈ 0, which means the advantage of global shrinks into slack. Since neither variant is uniformly superior, design rule D5 learns both and sends both to the gate.

![Certified attainment fraction of the holdout oracle gain by stream regime](/assets/images/posts/research/outcome-feedback-skill-router/fig3.webp)
*Schematic of how much of the holdout hindsight-oracle gain the learned router can realize: the certified fraction rises with the replay density (1+κ)·T_rec/t_min of the training stream and becomes 0 on the one-shot stream, where the router stays exactly the frozen clone. (Analytical model, not a measurement.)*

## The Gate That Closes Only Once: Reject Can Be Decided Before the Holdout Is Opened

The moment the learned policy replaces the frozen policy happens exactly once. The gate requires three conditions at the same time. G1 retention: the gain realized on the holdout must be at least γ = 0.4 times the estimated holdout oracle gain. G2 fixed-quality savings: the cost at the fixed quality q_0 on the holdout must be no more than (1 − δ) of the frozen cost, with δ = 10%. G3 anti-concentration: no single context class may contribute more than ρ = 30% of the total holdout gain.

The feature of this gate is calibration. Under A1-A3' and the estimated concentration, for G1 to pass with high probability, P(S) ≥ γ − o(1) is needed, and combining the replay density bound, when (1+κ)·T_rec/t_min < γ the gate fails G1 with probability 1 − o(1). After R1, the training stream, is finished and before touching R2, the holdout, you can decide that "the possibility of promotion is structurally zero." So that the gate itself cannot be Goodharted, all hyperparameters up to the λ·η·ε schedule, t_min, ρ_w, γ, δ, ρ are pre-registered, and relearning, readjustment, or a second look at the holdout after the gate is applied is forbidden (D6).

The threat model is stated together. A false promote requires both (i) sufficient seen holdout mass, P(S) ≥ γ, and (ii) an adversarial shift inside seen classes, such as grade manipulation or grader hacking. Since the earlier bound blocks (i) on one-shot or low-replay streams, the remaining risk is (ii), and the concentration cap of G3 limits that residual risk. This is a selection-stage defense against a poisoning attack in which a few skills, intoxicated by success experiences, capture the learned weights with high-grade plays.

The design rules D1-D7 that the frontier extracts are registered together. Clone-then-deviate with certified deviation against a strong baseline (D1), the arm as the learning unit (D2), graded reward (D3), pre-registration of the policy-level split (D4), parallel evaluation of local and global (D5), freeze after the one-shot gate (D6), and decay under churn (D7).

## ThakiCloud, Small Teams, and What Remains for Science

What this paper gives the ThakiCloud AI platform is a concrete path for cost optimization. In a registry of 2,000 or more skills, if the routing policy self-evolves through feedback on task outcomes, success and cost, token cost can be reduced relative to the frozen router. The guarantee of "not more expensive" at fixed quality and the three-term decomposition of the savings form that structure, and on top of the repository infrastructure with the sra_bench harness and the frozen-holdout gate, this can be measured and promotion decided immediately. R1 is 250 synthetic keyword-rich tasks + 50 real labeled tasks on the first half of the registry; R2 is an intentional distribution shift with a harder keyword mix on the second half + 50 holdout tasks. The protocol is pre-registered up to the M1-M6 metrics: fixed-quality cost, train-holdout divergence, seen mass and replay density, realized Φ, learning dynamics, and gate decisions.

A self-improving router design that embeds generalization-validation criteria is open to small teams as well. The token cost of unattended automation, and the energy cost behind it, become platform costs as scale grows, and sharing "an evaluation methodology that can track whether a router learning from outcome feedback overfits" becomes the infra for the spread of trustworthy autonomous agents.

Scientifically, in the cost-quality frontier measurement of the frozen router (the Zero-Token Routing family), this is the first case to bound the learning axis and the train-holdout divergence axis simultaneously. It provides new knowledge quantifying the generalization limits and the size of overfitting in routing-policy learning under streaming task environments, and its core sentence is "the certifiable upper bound of the apparent gain is the replay density of the stream."

## Limitations: Model Estimates on Top of the Inequalities, and Validity Threats Before Execution

All frontier values in this paper are model estimates under the stated assumptions: A1 per-context reward independence, A2 fixed λ, A3' seen-set domination, A4 skill separability. This paper reports no new measurements. A3' is written to hold only on the seen set and has not been checked on unseen mass; the freeze rule, which deploys the frozen clone on all unverified mass, is that safeguard. The gate thresholds γ, δ, ρ are also a priori set values, and the R1/R2 protocol is registered but was not executed within this paper.

Threats to validity at the execution stage are registered together. Quality grades come from an LLM judge, so grader noise is inherited by the gate decisions (M6). P(S) is sensitive to the context-class discretization, so the protocol registers two discretizations and the bound must be read from both (M3). There is also the critique that the cost model ignores context composition effects and that single-gold annotation underestimates the tool retriever's ability, so the M2 divergence is read on that premise.

Still, the direction is clear: run the protocol from the boundary set by the inequalities (learning loses nothing, overfit is a property of the regime, and the gate can decide reject before opening the holdout) and confirm where that bound lands on real streams. This paper is the blueprint and pre-registration for that execution.

The paper and its accompanying materials are available on Hugging Face.

https://huggingface.co/datasets/thaki-AI/daily-paper-2026-10-08-outcome-feedback-skill-router
