---
title: "The Skill Graveyard: Survivor Rate and the Economics of Use for a Self-Evolving Agent Loop That Repairs Itself Overnight"
seo_title: "ThakiCloud Autonomous Paper Analysis: The Skill Graveyard - a self-evolving agent loop that repairs its own harness overnight formalizes the lifecycle of newly generated skills in four stages (generation, frozen-gate acceptance, live use, retirement) and defines five quantities: survivor rate s, 7-day usage rate u_7, graveyard ratio, net capability, and graveyard tax. It derives five expected-level results: the net-gain ceiling, the corpus-growth identity, the visible-gate ceiling, the break-even survivor rate s* = c_g/(v·u_7·T_u), and the graveyard-tax ceiling, where the generation volume B drops out of the equations and the loop's true control variable is the survivor-rate budget. September 2026 production census: 2,287 registry entries, 1,789 live manifests, 2,351 historically added paths, and a single bulk purge of 1,285. A pre-registered protocol with falsification thresholds, plus gate-batching and retirement design - ThakiCloud"
seo_description: "Existing measurement of a self-evolving agent loop asks one thing only: is it not regressing? Nobody counts how many of the newly generated skills pass the frozen gate, are used within 7 days, and leave positive net capability. This paper formalizes the four-stage lifecycle of a skill and five quantities, and derives the break-even survivor rate and the graveyard-tax boundary. It is grounded in a census of a production harness with more than 2,000 skills. For cloud and AI engineers running loops that generate and retire skills."
excerpt: "The true artifact of an agent loop that repairs itself is not the live library, but the graveyard of skills that were generated, never used, and left sitting in the index. This paper measures that graveyard with five numbers and turns the loop's budget variable into the survivor rate."
date: 2026-09-22
last_modified_at: 2026-09-22
tags:
  - self-evolving-agent
  - skill-lifecycle
  - survivor-rate
  - agent-harness
  - overnight-automation
  - frozen-holdout-gate
  - skill-registry
  - capability-economics
  - research
categories:
  - research
author_profile: true
toc: true
toc_label: "Table of Contents"
canonical_url: "https://thakicloud.com/tech-blog/en/research/skill-graveyard-self-evolving-harness/"
---

If you run an agent loop that repairs its own harness overnight, or operate a production agent that has accumulated over 2,000 skills and wonder whether it actually grows capability, this post is for you.

Existing measurement asks one thing only: does the loop not regress? Nobody counts how many of the skills the loop forges fresh overnight pass the acceptance gate, how many are used within 7 days, and how much of their contribution survives as net capability after the counterfactual difference with the cohort removed.

This ThakiCloud paper fills that gap. It formalizes the lifecycle of agent-generated skills in four stages and defines five quantities: survivor rate, 7-day usage rate, graveyard ratio, net capability, and graveyard tax. The September 2026 production-harness census attaches real numbers to the model's parameters. The conclusion is one line: a skill library is not sustained by growth. It is sustained only when growth is budgeted.

![Illustration of the core idea of The Skill Graveyard: Survivor Rate and the Economics of Use for a Self-Evolving Agent Loop That Repairs Itself Overnight](/assets/images/skill-graveyard-self-evolving-harness-hero.webp)
*A visual metaphor for the article's key idea.*

## A Measurement Left With Only One Answer: "It Did Not Regress"

A self-evolving agent system repairs the scaffolding on which it runs itself. The editable surface splits in two: skill text, the procedural manifests loaded at routing time, and control parameters such as thresholds, routing weights, and schedules. Editing now happens overnight. A scheduled job runs while no one is at the console, and the artifacts never stay self-reported: the frozen gate either adopts or rejects them.

The measurement agenda is still one-sided: does the training set and holdout diverge, is the procedure kept under procedural pressure, do the control parameters tilt like a ratchet. All three are just other sentences for "does it not regress". Nobody counts the artifacts the loop stamps out fresh. Of the skills generated in a week, how many pass the frozen gate? Of those, how many are actually routed by live traffic within 7 days? How much of their contribution survives the counterfactual difference? How big is the graveyard: the pile of skills that were generated, died, and remain in the index, taxing every routing decision.

The anchor of this paper is Voyager. In that open-ended embodied agent, the curriculum was required to use generated skills, so the growth of the library itself was the story of capability. The premise that generated skills survive and get used holds structurally in a sandbox. Of course it does not hold in production. The dominant object of a skill-generation loop is not the library but the graveyard: skills that fell at the gate, skills that passed but were never routed, skills that were routed but gave no measurable benefit, dead mass left in the index that degrades the retriever for every other skill. Growth that is not counted is just cost.

## Four Stages, Five Numbers

The paper gives that object a formal lifecycle. Four stages: generation, frozen-gate acceptance, live use, retirement. Generation is the stage in which the loop produces candidate skills on a given night. The frozen gate is an acceptance suite sealed with 63 manually labeled routing cases. Scoring goes through the deterministic lexical (BM25) path, with the hybrid and dense stages off. The frozen gate accepts a proposal only if no sealed split regresses beyond a pre-registered epsilon. Live use is defined operationally: a skill counts as used if at least one live injection event names it. Retirement is the moment a skill leaves the live registry.

Five quantities are placed on the transitions between these stages. The survivor rate s is the fraction of generated skills that pass the frozen gate. The 7-day usage rate u_7 is the fraction of accepted skills that receive at least one live injection within 7 days of acceptance. The graveyard D_t is the set of skills that were generated but are not live, including gate rejections and retirees. The graveyard ratio is its share relative to generation. Net capability ΔH is the sealed-suite score with the cohort present minus the counterfactual score with the cohort removed. It is positive only when the cohort carries the score, not merely when it coexists with the score. The graveyard tax τ, when dead skills are left in the index, is the conservative lower bound on expected retriever performance loss per dead skill per routing event.

![Four-stage lifecycle of an agent-generated skill: from generation to the graveyard](/assets/images/posts/research/skill-graveyard-self-evolving-harness/fig-lifecycle.webp)
*Concept diagram of the four-stage lifecycle: generation, frozen-gate acceptance, live use, retirement. The quantities marked s, u_7, d, D_t in the figure are model definitions, not measurements. It is an interpretive model, not a measured value.*

## The Production-Harness Census: When Churn Already Rivals the Live Corpus

The paper pins the model's parameters with a census. September 2026, production harness. The registry holds 2,287 entries at the primary skill root, of which 1,789 are live SKILL.md manifests. The harness indexes three roots: primary, user-level, and mirror agent. The version history records 2,351 individual manifest paths added in the past and 1,322 manifest deletion events. The single largest event is a bulk purge on 2026-05-13, in which one commit deleted 1,285 manifests. Usage telemetry, from 2026-06-10 through 2026-09-22, about 3.4 months, records 14,749 routing decision events. Each event records the decision (injection, or rejection to native handling), the reason, and the scored candidates together.

The first thing these numbers say is that the graveyard is as large as the live corpus. The 2,351 historically added paths exceed the 1,789 live manifests by 31 percent. The single purge that deleted 1,285 manifests equals 72 percent of the live manifests and 97 percent of all 1,322 deletion events.

![System census: churn already rivals the live corpus (September 2026)](/assets/images/posts/research/skill-graveyard-self-evolving-harness/fig-census.webp)
*September 2026 production-harness census. The 2,351 individual manifest paths added in the past exceed the 1,789 live manifests by 31 percent. The single bulk purge on 2026-05-13 (1,285 items) equals 72 percent of the live manifests and 97 percent of all 1,322 deletion events. A technical system tally, not a protocol estimate.*

The census is honest about what it counts and what it does not. It counts lifecycle churn, that is events, not the current dead mass. The largest event was a mechanical reindexing purge, not a retirement by the loop, so it enters the identity below as an administrative deletion term. Gate rejections are not part of the census. The protocol's cohorts and counterfactual trial measure the current dead mass and its net effect separately.

## The Break-Even Point Is the Survivor Rate, Not the Generation Volume

The paper derives five results at the level of expectations.

The net-gain ceiling puts a ceiling on how much a single night can add. Let δ be the expected sealed-suite capability increment per used skill. A skill's contribution is nonzero only when it is injected, and there is no positive synergy between accepted skills. Under these two assumptions, the expected net gain of a night that generates B candidates is at most B·s·u_7·δ. The generation volume B is not capability. The factors multiplying B are s and u_7, and both are typically far below 1.

The corpus-growth identity writes down how corpus size moves. The registry is open and accepts external imports. In expectation, tomorrow's corpus size equals today's corpus plus new acceptances B·s and imports m, minus deletions d. In steady state, deletions must drain at the combined rate of acceptances and imports. Otherwise the corpus grows without bound. The census's 1,285-item purge enters here as the administrative deletion term.

The visible-gate ceiling puts a price on the gate the loop can see. If the loop can see even part of the gate cases, generated skills split into three: generalizers that pass both the visible and the sealed split, memorizers that pass only the visible one, and skills that pass only the sealed one. The visible pass rate minus the true survivor rate equals the number of memorizers minus the number of sealed-only, divided by the number generated. Because the loop cannot spend on sealed cases, it optimizes the visible cases directly, and the memorizers it produces accumulate in expectation. The visible pass rate is a ceiling, not a measurement. A gate the loop can see is a gate the loop can game, and this proposition quantifies what the gate gaming buys.

The break-even survivor rate collapses the loop's economics into a single number. Let c_g be the cost per generated skill (generation compute plus gate evaluation), v the expected value per unit time per used skill, and T_u the expected useful life. A night's cost is c_g·B, and a night's value is the number of used skills B·s·u_7 times the per-used-skill life value v·T_u. For the net to be positive, s must be at or above s* = c_g/(v·u_7·T_u). Here B drops out of the equation. Break-even is a claim about the quality of the survivor stream, not about generation volume. s* is the survivor-rate budget: a pre-registered lower bound below which the loop should stop generating and repair the proposer or the gate. Above s*, the loop can create net value beyond its cost.

![Break-even survivor rate: nightly net value is linear in the survivor rate (Proposition 4)](/assets/images/posts/research/skill-graveyard-self-evolving-harness/fig-breakeven.webp)
*Interpretive figure for the break-even survivor rate. The nightly net value is linear in the survivor rate s, starting from the negative intercept −c_g·B and crossing zero at s*. The axes are a normalized example (not measured values); the structure, namely linearity, the negative intercept, and the zero crossing, is the claim, not the tick values.*

The graveyard-tax ceiling puts a price on the dead mass. Leaving the dead mass D in the index costs at least τ·|D| in expected retriever performance per routing cycle. A skill that is dead but still in the index is never neutral; every routing event pays for it. The calibration anchor is the previous deactivation work on this harness lineage. While the corpus grew 21.6x (from 100 to 2,164), Top-1 collapsed by 42.2 points, and the guarded deactivation cut the corpus by 7.39 percent with 0 regression measured on the 63-case suite.

From these results one corollary follows. If the loop optimizes for the generation volume B, it is optimizing a cost linear in B against a revenue capped at B·s·u_7·δ. The economically meaningful control variables are s, u_7, and d. A generation budget is the wrong dial, and since u_7 is partially exogenous to the loop (traffic mix), the loop's own levers reduce to s, the retirement flow d, and the gate design.

## So How Do You Run the Loop

There are five design implications.

The loop's budget must be expressible in terms of the survivor rate s. Each cycle, s is pre-registered, and if the measured s falls below the break-even s*, generation stops until the proposer or the gate is repaired. The survivor-rate budget plays the role that a compute budget plays in training: a stated, auditable operating metric.

The gate thresholds and the sealed suite must be placed outside the loop's writable surface. Only then does the promotion gate become a ratchet proof. An edit-free control night catches the nights that have churn but no gain. The acceptor deserves the same design rigor as the proposer.

The graveyard must be drained at the combined rate of acceptance and import. Steady state requires deletions to leave at the acceptance rate plus the mean import rate. The mechanism is usage-based retirement with a grace period. The previous deactivation work shows that this is safe: it cut the corpus by 7.39 percent with 0 regression measured on the 63-case suite, and a recoverability constraint makes each retirement safely reversible.

Per-skill cost accounting turns s* into a computable number. Once c_g is a line item in the accounting, break-even is arithmetic, not opinion. A volume KPI, namely skills generated per night, is a wrong target. It rewards the numerator of a ratio the loop does not control.

Retirement must be designed as a safety channel, not just a hygiene dimension. A gate that looks only at capability can accept contaminated or mis-evolved skills, so adversarial probes must live inside the sealed suite. A skill that dies without being used cannot spread bad procedures. An emptied graveyard is a finite blast radius.

The paper also fixes a pre-registered measurement protocol. Cohorts are assembled in 14-day and 30-day windows keyed to generation date from the registry version history and the generator log. The gate trial reports the sealed pass rate s and the visible pass rate p_vis separately; the gap of Proposition 3 is the directly observable structure. The counterfactual trial scores two offline registry mirrors per cohort, the full registry and the registry with the cohort removed, on the same frozen scoring path, and never touches the live registry. The usage trial joins the date of birth to score-threshold-gated telemetry injection events and reports used@7d, used@30d, and ever-used by source. All tests use a 10,000-resample paired bootstrap.

There are three falsification thresholds. If the upper end of the 95 percent bootstrap confidence interval for the counterfactual ΔRecall@5 is at or below 0.02, the net-capability story is empty: the loop is stamping out skills that do not carry the score. If the visible-sealed pass-rate gap is within noise, Proposition 3 is practically empty: the gate is effectively sealed. If the upper end of the 95 percent confidence interval for the graveyard tax τ is below 0.001 per routing event per dead skill, Proposition 5 and the retirement-design implication collapse.

## What Remains for the Company, for Society, and for Science

For the company, what remains is the survivor-rate budget. In a harness with more than 2,000 skills, this budget quantifies how far the overnight self-evolution loop grows net capability beyond merely avoiding regressions. Measured across the full lifecycle, generation, holdout pass, real use, and retirement, it gives skill generation and retirement policy, and loop operation, explicit operating metrics and a cost basis.

For society, what remains is a safe pattern for running 24/7 unattended, dynamically self-modifying autonomous agents. Establishing the combination of a frozen holdout gate and a survivor-rate gate with reproducible measured data lowers the cost and risk of running self-evolving automation safely.

For science, what remains is a new measurement axis. Where existing self-evolution research measures only drift and overfitting, guardheart variance, and parameter self-tuning, this paper lifts that axis to the production-scale harness lifecycle economics of LLM-generated skills. Generation counts, holdout survivor rate, 7-day usage rate, retirement rate, net-capability curves. The story of Voyager's endlessly growing skill library moves from the embodied sandbox to production-scale skill economics.

## What You Should Not Believe

The model is at the level of expectations and is a single-harness story. s, u_7, δ, and T_u are regime parameters, not constants. They move with the workflow, the traffic mix, and the retriever state. Optimizer gains may not compound round by round, so a budget set from a single-window estimate needs re-validation.

The telemetry measures routing usage, not downstream task success. Usage is not value. A skill can be injected often and be worthless, or injected rarely and be hugely valuable. The model connects the two with δ, the per-used-skill increment. δ is exactly why the counterfactual experiment exists.

External validity stays within a single production harness with three indexed roots and mixed-language traffic. The 49 skills on a comparison shelf outside the index guard against top-stream duplication. Cross-ecosystem duplication is common, and duplication is exactly the case where the graveyard economics get worse. A dead skill with a live twin is a named routing trap.

The graveyard tax τ is a conservative assumption. The anchor for τ is the previous deactivation measurement, which caps the dead-mass term with whole-corpus growth without decomposing it into dead mass and live growth. Falsification threshold 3 exists precisely to test this.

Finally, a note on the numbers in this post. The census numbers are the measured state of the September 2026 production harness, and the five lifecycle quantities are model definitions waiting on the pre-registered protocol. This paper ends at model, census, and protocol; the protocol's measurements will be reported in a separate follow-up study.

The full text of the paper, the equations, and the census tables are on the Hugging Face dataset page: https://huggingface.co/datasets/thaki-AI/daily-paper-2026-09-22-skill-graveyard-self-evolving-harness
