---
title: "Zero-Token Routing: How Far a Router Cuts LLM Spend Without Losing Quality"
seo_title: "Zero-Token Skill Routing Cost-Quality Economics, Thaki Cloud"
seo_description: "We solve three-arm routing (skills, small models, frontier API) in closed form under a quality-pinning constraint. The optimal policy saturates the skill arm, frontier spend vanishes at a coverage threshold kappa*, and at the example parameters a 10% quality tolerance yields 98.7% savings. Skill-writing ROI rules and a measurement protocol included."
excerpt: "If an agent fleet's routine routing decisions move to a zero-token skill path, how far does LLM spend drop while overall quality holds at the frontier-alone level? Solving three-arm routing in closed form under a quality-pinning constraint, the skill arm saturates first, frontier spend disappears at a coverage threshold, and the savings curve kinks there."
date: 2026-08-28
last_modified_at: 2026-08-28
tags:
  - skill-routing
  - model-tier-selection
  - cost-quality-tradeoff
  - zero-token-routing
  - deterministic-skill
  - token-cost-optimization
  - agent-harness
  - unattended-automation
  - router-evaluation
  - paxis
categories:
  - research
author_profile: true
toc: true
toc_label: "Contents"
lang: en
permalink: /en/research/zero-token-router-cost-quality/
canonical_url: "https://thakicloud.com/tech-blog/en/research/zero-token-router-cost-quality/"
audiobook: "https://drive.google.com/file/d/1MciQ-qVIEYVUb0OHBmB__rufUWgikbun/view"
audiobook_label: "▶ Listen: 5-minute briefing"
audiobook_note: "NotebookLM audio overview (AI-generated)"
---

Engineers who run unattended agent fleets, or who own the LLM inference cost of an agent harness, should read this post. A fleet's day is a sequence of routing decisions. Whether a registered skill fires, and which execution strategy to take: small decisions repeated every hour. Handling each of them with the frontier API keeps paying frontier prices for work that can be solved deterministically. This post introduces the autonomous research paper "Zero-Token Routing" from ThakiCloud AI Research. The paper asks two questions. If routine decisions are routed to a zero-token skill path, how much does LLM spend drop while overall task quality stays at the $(1-\varepsilon)$ level of frontier-alone operation? And how far is that drop structurally guaranteed? We computed closed-form answers to both. Every number in the paper is an evaluation at explicitly assumed parameter values, not a measurement. Where the model breaks, and how to replace it with measurements, is in the same paper.

![Illustration of the core idea of Zero-Token Routing: How Far a Router Cuts LLM Spend Without Losing Quality](/assets/images/zero-token-router-cost-quality-hero.webp)
*A visual metaphor for the article's key idea.*

## The structure that pays frontier price for routine decisions

ThakiCloud's unattended agent fleet runs on Paxis, the production execution layer. The routing decisions the fleet makes come in two families: skill-routing and strategy. The core of the former is whether a registered skill fires; the latter picks which execution strategy to take. The skill registry holds 2,234 entries as of 2026-08-28.

The routing literature has answered this problem with knobs inside the model. FrugalGPT's cascade, Tryage's real-time triage, RouteLLM's learned router, WISERouter's workload budget constraint, Conformal Cascade's distribution-free accuracy guarantee, bandit-based adaptive routing. Every method in that line adjusts which tier to call, at what budget, with how many votes, by what mechanism, within the LLM menu. But every knob in that menu consumes generation tokens per task as well. No matter how far you turn the knobs inside the menu, the token-spend axis itself stays untouched.

The lever the paper opens is outside the menu: a zero-token arm that executes a deterministic skill after a non-generative gate that judges on vocabulary scores and quantized embeddings only. The moment that arm exists in the decision space, the real economic question surfaces. With overall quality pinned at $(1-\varepsilon)$ relative to frontier alone, how much spend can be saved by routing part of the tasks to this arm? And at what skill coverage does this arm come to dominate the rest of the LLM stack?

## The three-arm routing model: skill, small model, frontier

The model serves a task stream through three arms. The S arm executes curated deterministic skills. Generation tokens are structurally 0, and the per-task cost $\delta$ covers only the non-generative gate. Quality is $q_S$, and outside coverage the skill arm deterministically backs off, with the gate detecting the non-firing. The M arm is a self-hosted small model with cost $\rho_M$ and quality $q_M$. The F arm is the frontier API with cost $\rho_F$ and quality $q_F$.

The order of the two axes is the same. Cost is $0 \le \delta < \rho_M < \rho_F$, quality is $q_M < q_S < q_F$. A skill is better than the small model on the tasks it covers, but not as general as frontier. The task stream splits into two classes: C1 inside registry coverage (fraction $\kappa$, S available) and C2 outside it (fraction $1-\kappa$, S unavailable). A policy assigns arms conditioned on the gate's confidence information. The policy class is a single arm plus the confidence-threshold ladder $P_\theta$: if the gate's top-candidate confidence crosses threshold $\theta$, $P_\theta$ sends the task to S, otherwise to M. If M calls keep failing, the task goes to the F leg. The baseline for every savings calculation is the frontier-alone policy $P_F$.

![Three-arm routing policy structure](/assets/images/posts/research/zero-token-router-cost-quality/fig3_three_arm_routing.webp)
*Conceptual example diagram. Every task passes the non-generative gate first; tasks inside registry coverage ($\kappa$) are handled by the zero-token skill arm, tasks outside by the small model and frontier mix. The frontier leg fraction $t(\kappa)$ is positive only below the threshold $\kappa^\star$ and vanishes above it. From the cost order $\delta < \rho_M < \rho_F$ and the quality order $q_M < q_S < q_F$, the structure in which the optimal policy saturates the deterministic arm from the start is shown.*

We can trace this model's lineage too. Earlier work on the same gate priced how much the gate's compression eats into accuracy: int8 quantization error reaches the fused score only through the dense term, and the fusion weight attenuates that risk linearly. This paper writes the next sentence of that answer. Given a cheap gate, a gate that is robust to compression, how much dollar value does the deterministic arm that gate protects create under a quality-pinning condition?

## Where frontier spend disappears: the threshold κ*

The closed form's core comes from one assumption, A1. An efficiency order: the skill arm's cost per unit of quality above the small model is lower than the per-unit quality cost of the line from small model to frontier. The small model is the cheaper side per quality point, so this assumption holds in the parameter regime of interest.

Under A1, the structure of the optimal policy is Proposition 1. A cost-minimizing feasible policy saturates the S arm on every supported task. The exchange argument is simple. Swapping M for S on a C1 task lowers cost and raises quality. Swapping F for S lowers cost by $\rho_F - \delta$, and because that quality loss is cheaper to recover at the small model's price on C2 than at frontier's, S saturation wins on both cost and quality.

Proposition 2 gives the threshold and the savings curve. (a) Pointwise dominance: if $\kappa > 0$, the skill-first policy strictly dominates the small-model-alone policy at pinned quality at any coverage. Quality is $\kappa(q_S - q_M)$ higher and cost is $\kappa(\rho_M - \delta)$ lower. (b) The frontier leg is needed exactly when $\kappa < \kappa^\star$. (c) The savings rate $s(\kappa) = 1 - C(\kappa)/\rho_F$ is strictly increasing in $\kappa$, kinks at $\kappa^\star$, and converges to $1 - \delta/\rho_F$ as $\kappa \to 1$. If $\delta$ is 0, that limit is 100%.

The accompanying conservative anchor lemma is also practically important. If frontier quality is pinned at a declared value (for example success 1.0) rather than a measured one, the declared $\kappa^\star$ becomes an upper bound on the true threshold, and predicted savings become a lower bound. The direction in which quality overconfidence does not turn into savings overclaiming is structurally guaranteed.

The numbers are closed-form evaluations at explicitly assumed parameters ($q_F = 0.90$, $q_M = 0.70$, $q_S = 0.85$, $\delta = 0$, $\varepsilon = 0.10$, i.e. $\kappa^\star \approx 0.733$). Sweeping the cost ratio $r = \rho_M/\rho_F$ at 0.02, 0.05, 0.10, the savings rate at 50% coverage is 81.9%, 80.9%, and 79.3% respectively, and at r = 0.05 it reaches 98.7% at the threshold. The frontier leg fraction $t(\kappa)$ drops to 0.528 at $\kappa = 0.1$, 0.083 at $\kappa = 0.7$, and 0 at $\kappa^\star$, independent of r. Even at intermediate coverage, the mix on unsupported tasks still leans heavily on frontier. Loosening the tolerance $\varepsilon$ to 0.20 lowers the threshold to 0.133; tightening it to 0.10 raises it to 0.733. The moment $\varepsilon$ goes below $1 - q_S/q_F = 0.0556$, the skill arm alone cannot satisfy the quality condition, and the problem becomes infeasible even at coverage 1.

![Per-task savings rate and the kink, by coverage](/assets/images/posts/research/zero-token-router-cost-quality/fig1_savings_kink.webp)
*A schematic of the closed-form evaluation, not a measurement. The per-task savings rate $s(\kappa)$ against coverage $\kappa$ is drawn at small-model-to-frontier cost ratios r = 0.02, 0.05, 0.10. Left of the threshold $\kappa^\star$, the optimal policy still carries the frontier leg and the curve rises steeply; at $\kappa^\star$ frontier spend disappears and the slope kinks. Beyond that, it approaches the 100% savings limit ($\delta = 0$) as $\kappa \to 1$. The cheaper the small model is relative to frontier, the higher the savings at every coverage level.*

The gate's residual cost is closed as well. The residual of charging the gate at frontier token prices conservatively onto the savings limit that assumed $\delta = 0$ is under 0.8% for a 128-token gate against a 16,000-token frontier decision task.

## Where skills become worth using

Proposition 3 puts a price on skill authoring. The marginal value of one added task that grows coverage from the current $\kappa$ by $d\kappa$ is $v(\kappa)$. In the $\kappa < \kappa^\star$ regime, a newly written skill replaces the frontier-leaning mix, so it is worth up to $\rho_F - \delta$ per task, and this value kinks as the threshold is approached. In the $\kappa \ge \kappa^\star$ regime it replaces only the small model, so $v = \rho_M - \delta$ and flattens. The ROI rule gives two things. Priority: write skills first for the tasks the current policy sends to the frontier leg. Break-even: the marginal line on authoring cost, $A^\star = v(\kappa)\, d\kappa\, \lambda\, T$. Multiply by task rate $\lambda$ and operating lifetime $T$, and you get the ceiling of authoring cost one skill can justify.

![Marginal value of one added point of coverage](/assets/images/posts/research/zero-token-router-cost-quality/fig2_marginal_value.webp)
*A schematic of the closed-form evaluation, not a measurement. The marginal value $v(\kappa)$ of one added point of registry coverage is drawn. Below the threshold $\kappa^\star$, a new skill replaces the frontier-leaning mix and is worth close to one frontier call, decaying as the threshold is approached. Above $\kappa^\star$ it replaces only the small model, so it flattens at a lower level. The ROI rule prioritizes skill authoring from the tasks routed to frontier because of this kink.*

Where this rule lands is the nature of coverage. Coverage is a maintained asset that grows and shrinks while the fleet runs. The nightly autonomous repair loop turns failed routings into registry repairs, growing $\kappa$, but registry staleness and retrieval drift also shrink $\kappa$. In earlier work, an ORACLE decomposed fully by hand still reached only 63.6% step coverage on the production harness (1,600+ skills, mixed Korean and English queries). The bottleneck was the cross-lingual vocabulary bridge that co-binds authoring and retrieval. So retrieval improvement is also a $\kappa$-investment priced by $v(\kappa)$. Because $\kappa$ grows while the fleet runs, static analysis underestimates long-run savings. The actual value is the integral of $v(\kappa(t))$ along the repair loop's trajectory. If the crystallization literature, which promotes exploration into cheap workflows, reaches the same artifact, $v(\kappa)$ answers by price where that promotion should start. It starts from the tasks routed to frontier.

## The protocol for turning numbers into measurements

The paper's final section is a protocol. What this section touches is not the numbers already out but the procedure that replaces them with measurements. The labeled task suite comes from the fleet's own task families: skill-routing positive (cases where the gold skill should fire), native (cases where no skill fits at all), negative (cases where a specific skill must not fire; measuring non-firing and false firing), strategy (cases with a gold execution strategy). Success judgment is decided in one shot at the case level.

Arms go out instrumented. The S arm keeps an LLM call counter planted in the serving path, and to be credited as a zero-token arm that counter must read 0. This is a procedure that verifies, rather than assumes, that the generation tokens of $\delta$ are 0. The M arm reports both accounting conventions: self-hosted cash cost (energy and maintenance stated separately), and public API price conversion for comparability with F. The F leg computes the prompt tokens of the identical prompt times the public rate times an explicit output cap, and success is treated only against an explicit reference anchor. Because nothing is assumed quietly, the conservative anchor lemma pins the error direction on the safe side.

Estimands are pre-announced before the run. Per-policy success, costs under both accounting conventions, the savings rate against $P_F$, the dominance point (the minimum $\theta$ that reaches the anchor within tolerance while satisfying at or below the M-alone policy cost), and the plug-in estimate of $\kappa^\star$ obtained by inserting measured $\kappa, q_S, q_M, \delta$ into the closed form. Every estimand gets a bootstrap confidence interval. Picking after the fact the family that looked best and claiming its savings is not done without a valid interval. The discipline that potential savings are credited as measured savings only after passing a selection-validity diagnosis is the protocol's backbone. Proposition 2(b) predicts frontier spend disappears exactly at the measured $\kappa^\star$, Proposition 2(c) predicts $s(\kappa)$ has slope $r + A(1-r)$ below the kink and slope $r$ above it, and Proposition 1 predicts that no policy with an unsaturated skill arm can be cost-minimal. If observation deviates here, the location of model failure becomes visible: A1 broken, or skill quality below the assumed $q_S$.

## What this result leaves for the company, society, and science

For the company, this result becomes a concrete cost knob on the Paxis execution layer. It quantifies how much of the nightly fleet's token spend is routable to the zero-token skill path, and gives an ROI metric to skill-authoring investment. Which skill to write first for value is priced by $v(\kappa)$. The experiment infrastructure is fully self-owned route_bench/sra_bench (route=local), structured so the Pareto curve can be measured again with our own registry and zero frontier calls.

For society, it lowers the dollar floor and the energy floor of agent automation at the same time. If the largest share of routine work is routed to deterministic execution or a small local model, small teams can run unattended fleets on a fraction of frontier API cost. Covered work runs on our own hardware with no per-call API dependency. So even if the frontier API slows down, gets rate-limited, or goes down, the deterministic arm does not degrade. Availability and latency robustness are structural bonuses attached to the savings.

For science, the routing question widens one dimension, from "which model" to "which mechanism." All existing router research (effort routing, precision-tier routing, ensemble voting) turned knobs inside the LLM, and a non-LLM arm did not exist in the decision space. If the earlier fan-out work established that the most expensive tier inside the LLM tiers is never optimal, this paper extends the same Pareto argument outside the LLM. When the menu becomes a set of mechanisms, the cheapest mechanism per unit of quality, i.e. deterministic execution, saturates first.

## Limits

First, the quality tolerance's lower bound marks the infeasible region honestly. If the tolerance is tighter than the quality gap between skill and frontier ($\varepsilon < 0.0556$ at the assumed values), no coverage satisfies the quality condition. The pinned quality constraint is an honest statement about the skill arm's quality floor.

Second, the two-class scalar quality model abstracts away latency/SLO structure, reliability drift, and multi-turn compounding. Task-level accounting (making the unit of quality and cost the task) mitigates this abstraction but does not remove it.

Third, the numbers. Every example number is a closed-form evaluation at assumed parameter values, and until the protocol runs, reading the propositions as structural results and the numbers as order-of-magnitude reference is the honest reading. The protocol's purpose is itself to replace those numbers with measurements.

Fourth, the endogeneity of $\kappa$ is two-sided. The repair loop grows $\kappa$, but registry staleness and retrieval drift also shrink $\kappa$. So $\kappa^\star$ is a standing requirement, and coverage maintenance is its enforcement mechanism.

Fifth, authoring cost $A$ enters the model through the single break-even rule. A full cost model of skill authoring is open.

Sixth, A1 is an assumption. If the small model becomes so cheap that it nearly meets frontier on price per quality unit, A1 breaks, and the optimal policy may stop saturating S. The protocol's dominance-point estimand is designed to detect exactly this case.

---

The paper detail page is on Hugging Face: [https://huggingface.co/datasets/thaki-AI/daily-paper-2026-08-28-zero-token-router-cost-quality](https://huggingface.co/datasets/thaki-AI/daily-paper-2026-08-28-zero-token-router-cost-quality)

*Every number in this post is a closed-form evaluation at parameter values the paper explicitly assumes. They are not replaced by measurements until the paper's measurement protocol runs.*
