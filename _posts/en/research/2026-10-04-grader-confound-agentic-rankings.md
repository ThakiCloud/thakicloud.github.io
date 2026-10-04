---
title: "Grader Confound: Change the Grading Instrument, and the Measured Rankings Can Flip"
seo_title: "The Grader Confound: the grader is not a free observation but a measurement instrument with a price. This paper measures how far the measured cost-quality rankings of the agent tool-calling arms on our own H200 flip when the grader switches from deterministic AST matching to an LLM judge (plus a surface-pattern gate). Each task's result is decomposed into three cells, the correct answer, detected wrong answers, and silent wrong answers; the grader's effect is written as a cell-weighted confound on top of gold quality, and a closed form is given for the condition under which an arm pair flips. The free grader becomes a safe substitute for the paid judge when the instrument shift over the 100% overlap validation slice is smaller than the smaller of the gate distance and the minimum adjacent gap. The judge is priced as a grade tax, the ratio of judge tokens to generated tokens, and a judge policy that applies only to confounded pairs, with the proof that it preserves adjacent rankings, gets a closed form for its savings rate. Predictions P1 through P3 and falsification conditions R1 through R4 are pre-registered on 800 BFCL-style suites (400 simple, 200 multi, 200 parallel). At this stack's operator, an arm promotion decision was blocked by a saturated 55/55 language-quality holdout and then cleared by a free deterministic prose-pattern gate, and the 89.6% production AST anchor is a one-sided lower-bound estimate of gold quality. This is a step beyond LLM-as-a-judge agreement research: from human-preference validation to executable ground-truth validation, and from score-level bias to decision-level inversion - ThakiCloud"
seo_description: "The grader is not a free observation but a measurement instrument with a price. When the grader switches from deterministic AST to an LLM judge, the measured rankings of the agent tool-calling arms can flip. This paper gives the flip condition, the safe-substitution criterion, and the grade tax that prices the judge, and pre-registers a three-grader audit on 800 BFCL-style suites."
excerpt: "When you switch the grader from deterministic matching to an LLM judge, the measured rankings of the agent tool-calling arms can flip. This paper gives the flip condition, the safe-substitution criterion, and the grade tax that prices the judge."
date: 2026-10-04
tags:
  - llm-as-judge
  - deterministic-grading
  - ast-grading
  - grader-agreement
  - evaluation-validity
  - decision-inversion
  - tool-calling
  - bfcl
  - cost-quality-frontier
  - agent-harness
categories:
  - research
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/en/research/grader-confound-agentic-rankings/"
---

If you run a harness that evaluates agents which call tools on their own, or you are a Korean cloud/AI engineer responsible for the promotion and tier-routing decisions those evaluations make, this post is for you. The grader that decides wins and losses is not a free observation but a measurement instrument with a price. Change the instrument, and the rankings it measures can flip. This paper, from ThakiCloud's own H200 cluster, closes that flip into a law. The law answers, on the same 800 tool-calling tasks, how much the rankings move when you change the grading method, and what it costs in tokens.

## In plain terms: the scale that weighs body weight

Two people step on a scale and both read 150 kilograms. Are they the same weight? Not necessarily. If the scale's maximum display is 150 kilograms, then the two readings are the signature of the scale, not of the weight. This paper asks the same question about the grader that measures agent evaluation. The grader is the scale. The measured rankings are the scale's tick marks. Change the scale, and the tick marks move even though the true weight has not. What the paper does is tell you when it is safe to swap the free home scale for the paid laboratory scale, and what the price difference is. The home scale is deterministic grading. The laboratory scale is an LLM judge. The grader carries one more thing here: a price. This paper measures that price too.

## Problem framing: a saturated scale hides the ranking, and the deciding instrument was free

ThakiCloud's own H200 series measures agent tool-calling arms under grading that verifies by execution, without an LLM judge. An arm is a candidate setting of model, precision, and sampling configuration. In the series' 800 tool-calling benchmarks, every output is graded against the reference answer by code (AST) matching, with no judging model involved.

The production 27B checkpoint (NVFP4 quantization) records 717 of 800, that is 89.6%. That row is the anchor of the series. In the same stack, the arm promotion decision was tied up for a while in the language-quality validation set. Both the student candidate and the teacher candidate sat at 55/55. On a saturated scale, two candidates cannot be told apart. What cleared the promotion was a different, free, deterministic grader: the prose-pattern gate.

One loop, two lessons. A saturated scale hides the ranking. The grader that made the promotion decision was a free deterministic instrument. The question follows naturally. If the free deterministic grader was good enough to make the decision, then measure when it is safe to swap it for a paid LLM judge, and when the ranking flips.

Graders are known to be instruments with documented defects. LLM judges carry position, prose-length, and self-enhancement biases. Judges prefer the outputs of their own model family. Keyword-style deterministic harnesses give credit for tool calls the model never made. In a production audit run on a verifiable text-to-SQL workload, agreement between the judge and the author's reference answer came out near zero. On the slice where disagreements concentrate, Cohen's kappa is 0.04.

Under sparse pairwise overlap validation, the error rate, that is the fraction of wrong decisions, reaches 25%. The probability of picking a wrong best judge out of 10 candidates is 65%. The question is this: when is the free grader a safe substitute for the paid judge, and when does the ranking flip when the grading changes.

## What we tried: a three-cell decomposition and a closed-form flip condition

The paper's core instrument is to decompose each task's result into three cells. C is the correct answer. D is the detected wrong answer, the cell that is wrong but the validator can catch. S is the silent wrong answer, wrong but it slips past surface checks and is only caught by execution against the reference. Gold quality is the share of the C cell. The score each grader measures is a weighted sum of the pass rates of the three cells, α, β, γ. The grader effect is the gap between the measured value and gold, that is the cell-weighted confound. The instrument sets the weights. The candidate setting sets the cell shares.

The flip condition comes in closed form. For a pair of candidates, the gap the grader measures is the gold gap Δ with the grader differential D_g added on top. When D_g falls below the negative gold gap, that pair flips exactly. Three consequences follow. Candidate settings with identical three-cell shares cannot be separated by any grader of this form. A pure capability difference, one that lives only in the C cell, cannot be flipped by any grader. The grader only rescales the gap by α. The pairs sensitive to the grader are exactly those whose capability difference sits in the wrong-answer cells D and S.

The judge carries two extra terms that depend on the candidate setting. The surface shift σ_T from the prompt template, and self-preference μ, which is positive only on the judge's own model family outputs. The judge cannot execute, so γ_J is positive: it passes some detected wrong answers too. These two are defects unique to the judge.

![Qualitative cell-acceptance profile of the three graders](/assets/images/posts/research/grader-confound-agentic-rankings/fig-instrument-profile.webp)
*Qualitative schematic of the per-cell acceptance rates of the three graders. Rows are AST match, pattern gate, and LLM judge; columns are C (correct answer), D (detected wrong answer), and S (silent wrong answer). Only the relative ordering of assumptions A1 through A3 is matched; no numbers are implied. (An analytical model, not a measurement.)*

The qualitative profiles of the three graders are written down as assumptions A1 through A3. Each assumption rests on documented behavior. A1: AST matching is strict; its residual errors are strictness, concentrated on the multi and parallel categories where the correct answer is not unique. A2: the pattern gate gives credit for form; it passes near-miss wrong answers that parse and carry the required keywords. A3: the judge acknowledges semantically equivalent correct calls that AST matching missed; but because it cannot execute, it also passes some silent wrong answers.

## Saturation: a measured tie makes the order a pure instrument effect

The most important consequence is saturation. If two candidates tie under the grader in use, then under any other grader the order between them is determined solely by the difference in grader effects. Swap the grader on a saturated scale, and no capability difference emerges; you are swapping instrument signatures. For a tie-break on a second grader to be valid, it must be known that the grader's cell weights go along with the gold. It is not enough that it differs from the first grader.

This stack's 55/55 is exactly this regime. The prose-pattern gate that decided the promotion could not measure a capability difference. It swapped an instrument signature. That swap was valid because the gate's cell weights were inspectable by construction. In plain terms: when two people tie on a scale pinned at its maximum display, you swap in another scale with a known calibration and weigh again. The new reading is the signature of the scale, not the weight.

## Safe-substitution criterion: when the free grader stands in for the paid judge

The gold cells are latent variables. The paper operationalizes the criterion on a full overlap validation slice. Every task is graded once under both instruments for every candidate setting. On that slice, the per-candidate instrument shift η is directly observed. The per-task disagreement rate π becomes an upper bound on the instrument shift. Full 100% overlap is the design point. The 25% error rate of sparse overlap is why.

The safe criterion comes in two parts. Gate safety: if the maximum instrument shift is smaller than the gate-level distance to the nearest candidate, the two instruments place every candidate on the same side of the gate. The series' gate is 0.85. Adjacent-pair safety: if the gap between every adjacent pair in the free grader's ranking is larger than the sum of the two candidates' instrument shifts, the paid grader's ranking is identical. Promotions between adjacent candidates do not flip.

![Safe-substitution criterion on adjacent arm pairs](/assets/images/posts/research/grader-confound-agentic-rankings/fig-safe-substitution.webp)
*Conceptual schematic comparing the measured gap with the instrument-shift tolerance band, per adjacent candidate pair in the free grader's ranking. Pairs whose gap does not open beyond the tolerance band form the set of confounded pairs the judge has to resolve. (An analytical model, not a measurement.)*

In plain terms, this is the story of a scale with a guarantee: if the difference in readings between the home scale and the laboratory scale is smaller than the gap between people, the order does not change. The paper turns this intuition into a checkable inequality.

## Grade tax: the price of the judge

Next, the price. To grade K candidate settings on n tasks, the generation side spends n×K tokens. AST matching and the pattern gate run for free on local CPU, at 0 model tokens. A full judge sweep multiplies n×K by the per-judge-call tokens ℓ_J. The judge must reread the schema, the task, and the candidate output in full before it issues a verdict. ℓ_J is typically one order of magnitude above the generation tokens ℓ_gen, a single-digit multiple. This figure is stated explicitly as a modeling assumption of around 10x, not a measurement. This ratio, the symbol ρ, is the grade tax. Full judging levies a tax of ρ on the evaluation budget it certifies. It does not depend on K or n.

The paper's policy: use the judge only on confounded pairs. Compute the confound band b, the maximum of the adjacent pairs' instrument-shift sums over the overlap slice. Judge only the candidates belonging to adjacent pairs whose free-grader gap is smaller than b. The savings rate is 1-2|P|/K, where |P| is the number of confounded pairs. Pairs with a gap of b or more cannot flip under the observed shifts. The policy comes with a proof that it preserves every adjacent ranking it does not judge. The overlap audit that computes b is a one-time paid sweep; the savings rate applies to every evaluation cycle afterward. The certificate expires when the candidate set changes. It does not accrue over time.

![Grading cost structure: free default, judge on confounded pairs](/assets/images/posts/research/grader-confound-agentic-rankings/fig-grade-tax.webp)
*Conceptual schematic of the added judge tokens per evaluation in relative units. The deterministic grader is 0. A full judge sweep is a single-digit multiple of the generation budget, at the grade-tax level. The confounded-pairs-only policy sits in between. (An analytical model, not a measurement.)*

This policy is the tool-calling analog of cascade judgment: accept it when you are confident, send it up when you are not. The direction is reversed. The cheap instrument is the default; the expensive instrument appears only as an exception. A deterministic grader has no confidence score. The certificate is the overlap audit itself.

## Pre-registered three-grader audit protocol

The paper pre-registers this criterion on the 800 tool-calling suite. The composition is 400 simple, 200 multi, 200 parallel, and the temperature is 0. The candidate settings are two or more representative candidates: the production checkpoint and the nearest challenger adjacent to it in the structural-match ranking. Every task is graded once under all three graders. This is the 100% overlap. The budget is two free sweeps, one paid sweep (800×K judge calls), and one paid partial sweep against the surface-variant baseline (400×K calls). The paid sweep is the entirety of the protocol.

The pre-registered predictions are three. P1: AST matching and the judge agree at 95% or above on simple tasks. On the multi and parallel sum, the judge passes at least 2 points more than structural matching does. The main cause of disagreement is the strictness of structural matching. P2: the pattern gate passes at least 5% of the simple tasks that structural matching rejects. Its agreement with the judge is lower than structural matching's, in both error directions. P3: between two surface variants of the same template, a paraphrase and a tone shift, the judge's score moves by at least 1 point on at least one candidate setting.

The falsification conditions are four. R1: if a structural-match adjacent pair is within 5 points and flips under the judge, the confound is real. Arm promotion then runs conditionally on the judge until the overlap audit resolves it again. R2: if judge-structural-match disagreement is 60% or more and concentrates in the malformed-output cell, the judge is seeing form. It is demoted to a format check. R3: if a judge from the same model family as the candidate moves the candidate's measured quality by at least 1 point, against a judge from another family, on the same output, then self-preference is real. Same-family judges are excluded from the promotion path. R4: if the Kendall tau between the judge and structural matching on the K-candidate ranking is 0.9 or above on both surface variants, the confound is dormant. AST matching is certified as the safe substitute for the next evaluation cycle. The certificate's expiry is tied to a change in the candidate set.

The thresholds are fixed before the paid sweep runs. The protocol's outputs are three: a gate-safety certificate at gate level 0.85 under structural matching, a confounded-pair list for judge escalation, and an estimate of the grade tax ρ for the evaluation budget.

## So what changes: company, society, science

What stays at the company is the grader-audit protocol for the overnight research loop. It quantifies when a paid LLM verdict is strictly needed and when free deterministic grading preserves the rankings, cutting evaluation cost. Arm promotion and tier routing are decisions that reach production. This protocol removes the quiet error source in which rankings flip silently when the grader is swapped, out of those decisions.

What stays for society is that the phenomenon in which grader choice flips rankings is now surfaced in a measurable form. It raises the reproducibility and reliability of agent evaluation across the whole research community, without new hardware investment. Keeping cheap deterministic grading as the default and limiting the expensive judge to the confound band is the cheapest, lowest-energy way to keep agent evaluation trustworthy as the candidate population grows.

What stays for science is the first controlled measurement of the grader-choice effect on tool-calling ground truth that can be double-graded by code. It separates judge biases like leniency, form, and self-preference from true capability. The validation criterion is executable ground truth; the decision level is one step above the score: candidate rankings, gates, and routing. If LLM-as-a-judge agreement research stayed with human-criterion validation and score-level bias, this paper moves one step up to executable ground-truth validation and decision-level inversion. Beyond bias mitigation, it gives a priced substitution rule.

Within the series, the interpretation of existing rows changes too. Validator's Dividend prices one point of tool-calling accuracy under a free deterministic validator. But the detected share p_d itself is measured against the grader, so the dividend formula becomes grader-conditional. Precision Ladder's judge-free gate becomes an instrument under audit; it cannot be left as a free constant. Multi-Skill Gap's deterministic labels become one entry of the grader family this paper profiles. The 89.6% AST anchor is an estimate on the strict side; structural matching misses correct calls, so the production checkpoint's gold quality is above that row. A one-sided statement that does not claim new numbers. If strictness is larger on the multi and parallel categories, the routing table can underprice candidates with many semantically equivalent correct answers. P1 is exactly that audit.

## What not to trust: an interpretive paper with four limitations

First, this is an interpretive paper. It reports no new measurements. The model is conditioned on the series rows reported under a single grader. The protocol is pre-registered but not run in this paper. The pre-registration is what turns the next sweep into a test.

Second, the task set is a BFCL-style tool-calling benchmark. Transfer to other agent benchmarks is an open empirical question. The protocol is portable; only the task set and the candidate set change. Third, the cell arithmetic assumes pass/fail grading. If a partial-credit grader replaces the 0-1 pass rate with an expected score, the main propositions still hold by linearity. Fourth, the judge is a single fixed (model, template) pair. Falsification conditions R3 and R4 pin down the surface of family and template but do not exhaust it. Surface sensitivity of judge scores is already documented.

The grader is a scale. Before choosing the scale, you must measure how much its signature mixes into the reading. This paper gives that measurement law, and the price of the judge.

Paper and data: https://huggingface.co/datasets/thaki-AI/daily-paper-2026-10-04-grader-confound-agentic-rankings
