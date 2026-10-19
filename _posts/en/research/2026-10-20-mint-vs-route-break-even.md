---
title: "The Mint Frontier: When a task departs from the registry distribution, the boundary between minting a new skill and routing to an existing one is priced by OOD distance"
seo_title: "The Mint Frontier: Introducing a cost-quality break-even paper on skill generation and routing in self-evolving agent harnesses (OOD distance, SLO-allowable cost argmin, verification coverage, action-Brier calibration, self-hosted H200) - ThakiCloud"
seo_description: "No prior study priced the boundary that decides whether to mint a new skill, route to an existing one, or abstain and escalate, as a function of out-of-distribution (OOD) distance. This analytical paper presents a piecewise closed-form effective mint frontier under the SLO-allowable cost argmin, a verification-side dominance identity set by verification coverage, a three-way calibrated decision rule scored by the action-Brier score, and a frozen factorial protocol with pre-registered falsification criteria F1-F5."
excerpt: "For a task at a given distance from the registry distribution, there is a point where minting a new skill costs less than routing to an existing one. The excess over the pure amortization break-even does not include generation cost. The boundary is drawn by the verifier, not the generator."
date: 2026-10-20
tags:
  - skill-generation
  - skill-routing
  - mint-vs-route-break-even
  - out-of-distribution-detection
  - cost-quality-frontier
  - self-evolving-harness
  - skill-ecosystem
  - calibration
  - h200-serving
  - unattended-automation
categories: [research]
author_profile: true
toc: true
toc_label: "Contents"
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/research/mint-vs-route-break-even/"
---

If you run an agent fleet on a self-hosted H200 or grow a registry of 2,000+ skills, you meet this three-way decision in the unattended loop. For every incoming task you must decide whether to route to the nearest existing skill, declare abstention and escalate to a human or a higher tier, or mint a new skill that is not in the registry. ThakiCloud's analytical paper, The Mint Frontier, puts a price on the boundary of that decision. This post introduces the boundary itself and how to calibrate it back into the loop.

First, let me clarify its character. This is an analytical paper. It reports no new measurements. Every number in this post is a closed-form prediction under the declared nominal assumptions. Both figures are outputs of the analytical model. The paper's name is itself the empty box: the boundary between minting and routing, that is, the frontier.

![Illustration of the core idea of The Mint Frontier: When a task departs from the registry distribution, the boundary between minting a new skill and routing to an existing one is priced by OOD distance](/assets/images/mint-vs-route-break-even-hero.webp)
*A visual metaphor for the article's key idea.*

## The problem: the routing side and the survival side are priced, but the boundary is empty

The basic pattern of a production agent harness is skill routing. The unattended loop alternates between reasoning and acting. For each incoming task it does not replan from scratch; it attaches the nearest existing skill. As the skill library keeps growing, this loop becomes a self-evolving system that must make two more decisions per task: when to mint a new skill the registry does not cover, and when to declare abstention and hand off to a higher tier or a human. The latter is not an option. A tool that cannot say no, absolutely, hides its omissions.

Three branches of the literature price the pieces of this decision. The routing side has been priced by the miss multiplier and the break-even routing accuracy. The economics of amortizing a verified trace into a reused routine stands apart. The survival side of minted skills has been priced by held-out generalization, capability-based benchmarking, and cross-harness retention. But no study has priced the boundaries between these actions.

This is the question the paper asks. As the out-of-distribution (OOD) distance d from the registry distribution grows, and as the future re-appearance count (recurrence) λ of the same task family increases, where does minting a new skill become the SLO-allowable cost argmin? When routing can keep the SLO, minting must be cheaper than routing; when it cannot, minting must be cheaper than declaring abstention. The OOD-distance coordinate that connects the three branches of the literature is precisely the empty box.

## Effective mint frontier: the three-way decision in the (d, λ) plane

The paper builds its cost model on two state coordinates. The OOD distance d (0 is in-distribution, 1 is maximum departure) and the family recurrence λ (the expected count of future instances of the same family within the horizon W). d is given by d = 1 - g_c from the calibrated router gate g_c.

At distance d, routing pays for injection, a single execution attempt, and a miss surcharge. The chance the attached skill is wrong is q(d). When it is wrong, (m(d) - 1) additional attempts are spent and only ρ(d) of them is recovered. Routing a known in-distribution skill is pinned to the SLO, so C_R(0) = C_S. Minting adds the fleet contamination cost η(d) incurred when accepting a skill minted at distance d to the expected draft and verification cost (C_draft + c_V) / p_gen(d). The task's induced cost is common to all arms and drops out of the comparison.

The break-even is simple. Over the family horizon, minting beats routing when λ ≥ λ*(d) = C_M(d) / (C_R(d) - C_S). Minting beats declaring abstention when λ ≥ λ_A*(d) = C_M(d) / (c_A - C_S). Two boundaries squeeze the decision space. The SLO floor d_S (the maximum distance at which routing quality 1 - q(d) can still hold the declared SLO) and the generation reach horizon d_max (the maximum distance at which the draft pass rate p_gen(d) can still hold the floor p_floor).

Below d_S, the contest is mint versus route. Because c_A ≥ C_R(1), declaring abstention costs more than routing; abstention never wins here. Above d_S, routing becomes SLO-inadmissible and the arena shifts to mint versus abstain. Beyond d_max, abstention is the only admissible arm. The two pieces joined together form the piecewise effective frontier λ_eff*(d). The decision rule is to mint when d ≤ d_max and λ ≥ λ_eff*(d).

One shape result is interesting. The sub-frontier λ*(d) is non-monotonic and unimodal. It diverges to infinity as d approaches 0, bends at the unique minimum d* inside the interval, and rises again. So the level set of λ is not a ray but a band [d_1, d_2]. If recurrence λ is below the minimum, minting never occurs at any distance. The larger the recurrence, the wider the band extends in both directions.

Under the declared nominal rate card (C_S = $1.02, c_A = $5.00, SLO = 0.90, verification coverage v = 0.80, W = 30 days), the frontier takes on concrete values. d_S ≈ 0.229, d_max ≈ 0.923, d* ≈ 0.806, the minimum of λ* ≈ 23.1, and λ_A*(d_max) ≈ 6.31. The last number means this: for any family with recurrence of 6.31 or more, minting wins across the entire (d_S, d_max] interval where routing is SLO-inadmissible. The left piece (mint versus route) first appears at λ ≈ 178 or above.

![Effective mint frontier: qualitative structure in (d, lambda) space](/assets/images/posts/research/mint-vs-route-break-even/fig1-mint-frontier.webp)
*The piecewise effective mint frontier λ_eff*(d) under the SLO-allowable cost argmin. Below the SLO floor d_S, the mint-versus-route break-even λ*(d); above it, the mint-versus-abstain break-even λ_A*(d). The thin dashed curve is the qualitative shape of the unimodal sub-frontier λ*(d). The colored regions are where route, mint, and abstain each win. An example from the analytical model, not a measurement.*

## Verification-side dominance: the boundary is drawn by the verifier, not the generator

The second result is that the position of the mint frontier is determined on the verification side. Subtracting the pure amortization break-even λ_0*(d) (the compiled-routine form with no contamination term) from the full mint threshold λ*(d) gives an identity. λ*(d) - λ_0*(d) = η(d) / (C_R(d) - C_S). This excess includes neither the generation cost C_draft nor the verification cost c_V. Generation cost only rescales the entire frontier by a multiplicative factor. The excess is set by the fleet contamination η(d). η(d) = η_0(1 - v)(1 + d), and its coordinates are set by the base contamination level η_0 and the verification coverage v.

This means that however much you improve the generator, the excess pinned to the frontier by contamination stays the same. The lever that sets the boundary level is verification coverage. A corollary is the hard cap. Once you declare the maximum premium π_cap that the fleet-insurance boundary permits, any acceptance with π(d) ≥ π_cap is forbidden, independent of recurrence λ. Because λ does not enter π, this ban holds at all recurrence levels. A continuously running self-evolving loop must cap acceptances by distance d.

At the declared nominal values, v = 0.80 and the relative premium π ranges from 0.24% to 1.68%. It is small no matter where d is. The magnitude is regime-dependent. This claim is an identity, not a level assertion. The robust part is the hard cap.

In operating-rule terms, it is a single line: invest in the verifier before the generator. A single-point increase in verification coverage v and a decrease in the base contamination level η_0 both lower λ*(d) and λ_A*(d).

![Verification-side dominance: coverage sets the excess, generation cost rescales the frontier](/assets/images/posts/research/mint-vs-route-break-even/fig3-verification-dominance.webp)
*An example comparing the pure amortization-based λ_0*(d) and the full mint threshold under high and low verification coverage. The excess λ* - λ_0* is set by coverage (η_0, v) and is independent of generation cost. Generation cost rescales the entire frontier by a multiplicative factor. An example from the analytical model, not a measurement.*

## Decision calibration: from the raw gate to action-Brier

The frontier is only as good as its inputs d̂ and λ̂. By ThakiCloud's earlier production metrics, the router's raw signal discriminates but is uncalibrated. On a production index of 2,283 entries, the router's own compositeness signal fired on 91.23% of gold tasks and on 0 of 10 no-skill tasks. It separates, but the scores carry no decision-grade meaning.

The paper's instrument is ladder calibration. The OOD ladder consists of variants made by applying surface mutations stepwise to 12 real workflow templates, plus a single genuinely novel family arm with no gold skill. On this ladder, the depth of the surface mutation determines the distance d. A monotone map from the raw gate g to d̂ = Φ(g) (a temperature or Platt-type transform, with isotonic regression to enforce monotonicity) is fit to minimize action-level risk. The ladder acts as the real distance axis against which calibration is checked.

The 3-way action is scored by the proper action-Brier score. The target y is a 0/1 variable indicating whether the SLO-allowable cost argmin at (d, λ) is mint. The model's mint probability ŷ is reported per (d, λ) stratum together with a reliability diagram. A well-calibrated rule chooses mint when d̂ ≤ d_max and λ̂ ≥ λ_eff*(d̂) + margin. margin is a free hyperparameter tuned by action-Brier. λ̂ is read directly from the harness logs as an exponential-family rate for future family instances, so it operates on the declared accounting alone, with no extra metering.

This is where selective prediction calibration extends from a 2-way answer-versus-abstain to 3-way action selection.

## What it delivers: the company, society, and science

For ThakiCloud's skill-ecosystem team, this paper hands the overnight self-evolving loop a measurable decision boundary. When to mint a new skill, when to route to an existing one, and when to escalate become coordinates on the frontier instead of gut feel. It reduces the token waste of minting skills for non-recurring families. It also blocks the quality regression that comes from forcing an OOD task into the wrong skill.

Across unattended autonomous agent systems as a whole, quantifying when to add capability and when to reuse makes self-evolution cheaper and safer. Even small teams that cannot afford to have a human stand behind every mint now get a rule that justifies, in cost terms, the moment a new skill is worth accepting.

The skill-routing literature gains an axis that had never been measured. Earlier work priced the routing arm (miss multiplier, break-even accuracy), amortization (recurrence break-even), and survival (held-out generalization, cross-harness retention) one by one. Pricing the boundary between actions as a function of OOD distance is new. The route/abstain/mint action space and the calibrated cost-quality break-even are one level up from abstention-only and survival-only studies.

The paper ships a frozen factorial measurement protocol alongside pre-registered falsification criteria F1-F5. This is a result, not a stated intent. What the protocol fixes is what the self-hosted H200 harness, with a 2,288-entry registry snapshot, must observe for each claim to hold. The criteria are: whether q(d) fails to decrease as d grows, whether p_gen(d) shrinks, whether the measured break-even matches the closed form within ×/÷1.5, whether the calibrated gate beats the raw gate on action-Brier, and whether the fleet-insurance boundary is respected.

## Limitations: what this paper does not claim

Every instantiated value is a declared nominal assumption. The protocol is a pre-registered instrument, not a record of work performed. The shape results (the inner sub-frontier band and the verification-side identity) are algebraic and invariant to the rate card. The threshold level and the band location [d_1, d_2], however, depend on the declared quadratic/linear working form. The divergence as d→0+, the excess identity, and the no-abstention-below-the-SLO-floor property are form-robust. The location is form-dependent.

The OOD distance is a constructed surface distance (paraphrase depth, number of tool substitutions). It is not true novelty. The genuinely novel arm separates surface distance from semantic novelty. Because skills change under maintenance and self-evolution, the frontier is a snapshot of a moving registry. It is exactly the condition under which the registry grows where drift creeps in.

The base contamination level η_0 is a rate-card value, not a measured one. F5 is the only fleet-side guard. If F5 is broken, the hard cap becomes binding. The frontier is described entirely in the self-hosted H200 serving regime. Cloud-API harnesses and other engine families are out of scope.

---

The paper and its accompanying materials are available here: [The Mint Frontier dataset](https://huggingface.co/datasets/thaki-AI/daily-paper-2026-10-20-mint-vs-route-break-even)

*Every number in this post is a prediction of the analytical model under the declared nominal assumptions, not a measurement. The two figures are qualitative shapes from the analytical model.*
