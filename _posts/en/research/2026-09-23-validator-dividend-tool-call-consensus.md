---
title: "The Validator's Dividend: The Cheapest Lever for Buying One Point of Tool-Call Accuracy on Unattended Agents with a Free Validator in the Loop"
seo_title: "The Validator's Dividend paper analysis - the self-hosted sampling cost of 1pp of tool-call accuracy when a free deterministic validator (schema + AST checks) already sits in the path of an unattended agent loop. The validation-then-resample gate dividend Δ=q·p_d/(1-p_d), the silence floor 1-p_s/(1-p_d), the margin cost c/q, the gate-majority crossover p_d*(q)=1-1/(q(3-2q)), the diminishing marginal dividend of k-sample consensus, the model-tier crossover inequality (r-1)·d_k>2(q'-q), and the cheap-judge dominance bound β*≈96.9%. The 5-arm pre-registered BFCL protocol on H200 NVFP4 27B with falsification criteria R1-R4 - ThakiCloud"
seo_description: "An unattended agent loop on a quantized self-hosted checkpoint must trust every tool call, and the only correctness signal there is the free deterministic validator. This paper prices one point of tool-call accuracy in sampling cost when that validator already sits in the path. The validation-then-resample gate is the cheapest lever, with a margin cost of c/q per quality point, capped by a silence floor that no retry budget can cross. At the interpretation anchor q=0.9, p_d=0.07, the gate buys 6.8 points at an expected 1.07 samples, and a model tier upgrade at 2x cost over a 5pp gap costs more than the first consensus step. Every number is an interpretation-model prediction under stated assumptions, and the pre-registered BFCL protocol is the road to measurement."
excerpt: "A tool call from an unattended agent is an account number, not a memo field. One wrong digit stops the whole workflow, so what should one point of accuracy cost when a free deterministic validator already sits in the path? This paper's answer is the validation-then-resample gate. It is the cheapest lever, and its dividend ends at a silence floor that no retry budget can cross."
date: 2026-09-23
tags:
  - validation-gated-resampling
  - self-consistency
  - consensus-voting
  - tool-calling
  - structured-output
  - cost-quality-frontier
  - quality-per-dollar
  - llm-quantization
  - h200-serving
  - bfcl
categories:
  - research
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/en/research/validator-dividend-tool-call-consensus/"
audiobook: "https://drive.google.com/file/d/1hVBVl0r4WFp7RscUlGKTYm3xEWqh0rXP/view"
audiobook_label: "▶ Listen: 5-minute briefing"
audiobook_note: "NotebookLM audio overview (AI-generated)"
---

If you run unattended agent loops on quantized self-hosted checkpoints, or you are the engineer who answers for that serving bill, this post is today's work. The paper prices one point of tool-call accuracy in sampling cost. It answers which lever is cheapest among validation-then-resample, k-sample consensus, and a model tier upgrade, and even how many samples it takes before the marginal dividend of resampling drops below the price of a single tier upgrade. Every number is an interpretation-model prediction under stated assumptions, and the paper pre-registers the way to measurement.

![Illustration of the core idea of The Validator's Dividend: The Cheapest Lever for Buying One Point of Tool-Call Accuracy on Unattended Agents with a Free Validator in the Loop](/assets/images/validator-dividend-tool-call-consensus-hero.webp)
*A visual metaphor for the article's key idea.*

## The Only Correctness Signal in the Loop Is the Free Validator

An unattended agent loop must trust every tool call. Each planning instance produces a tool-call plan, an ordered list of function calls with named arguments, and serializes it as JSON or an AST. Downstream code consumes the function names, argument values, and call counts verbatim, so a single token out of place stops the whole workflow. A tool call is closer to an account number. One wrong digit in an account number voids the entire transfer, while a misspelled letter in a memo field is absorbed inside the sentence.

Yet at deployment time, this kind of loop has only one correctness signal: the free deterministic validator, schema and syntax checks plus AST-level structural inspection. It is the same structure the Berkeley Function-Calling Leaderboard (BFCL) harness uses for validation, and it costs almost nothing. Whether the loop uses the validator or not, it sits in the path. The paper's question is this: when a free validator already sits in the path, what does one point of tool-call accuracy cost in self-hosted sampling?

Four sampling levers compete for that budget, plus one exogenous lever. The first is validation-then-resample (VTR): when the validator rejects, draw again, and if every draw up to the budget fails, discard the result. The second is whole-plan majority (MAJ-k): take the plurality vote among k samples. The third is per-argument consensus (ARG-k): combine the skeleton and the arguments separately. The fourth is cheap-judge election (JUDGE-k): a cheap local model picks one of the k candidates. The fifth is a model tier upgrade, an exogenous lever that costs r times per sample (r>1). Self-consistency research measured what these extra samples buy on open-ended questions, but the economics of sampling policies for structured agent actions over a free deterministic validator was still a blank space.

<!-- nlm-visual -->
![Key-concept summary infographic 1](/assets/images/posts/news/validator-dividend-tool-call-consensus/en/nlm-infographic-1.webp)
*Infographic generated by NotebookLM from the sources.*

## The Gate's Dividend: What the Free Validator Buys

The model splits a single draw into three classes. C is the correct answer, passed by both the validator and the offline deterministic scorer G. D is a discoverable error, failed by both the validator and the scorer. S is a silent error, passed by the validator but failed by the scorer. The probabilities are q, p_d, and p_s, and the three sum to 1. Of the total error p=p_d+p_s, the fraction the validator can see is δ=p_d/p, and the limit where δ approaches 0 is called the validator blind spot: all the error mass is silent, so no gate can filter anything.

Mounting the VTR gate on top produces a dividend Δ=q·p_d/(1-p_d). Accepted draws are conditioned on passing the validator, so the conditional mass of an accepted plan is q/(q+p_s). The gate lifts accuracy from q to q/(1-p_d)=q+Δ, and the entire dividend is realized on the first accepted draw. The dividend has a ceiling: Δ never exceeds δ·p. A small discoverable fraction means a small dividend, and at the blind spot it is 0.

There is another ceiling on the gate's accuracy that no retry budget can cross. The upper bound on accuracy is 1-p_s/(1-p_d), which the paper calls the silence floor. The error that remains below the floor is only class S, the single error class the validator lets through, namely argument value errors. No amount of extra retries filters this class. The cost side is clean. The expected number of draws is (1-(1-a)^n_max)/a (a=1-p_d), and with n_max=2 it is exactly 1+p_d. If the discoverable error rate is 7%, the expected cost of one pass through the gate is 1.07 samples.

At the interpretation anchor q=0.9, p_d=0.07, p_s=0.03, the numbers come out like this. A dividend of 6.77 points, an accuracy ceiling of 96.8%, an expected 1.07 draws, and a margin cost MCD of c/q, i.e. 0.0111c per quality point. All of these are derived from closed-form expressions, not measured.

The gate's value is not only in accuracy. The loop ends on a single sample with probability 1-p_d, so the expected extra cost is just p_d. In other words, the gate is a lever that buys accuracy with the extra latency and GPU time proportional to the discoverable error fraction.

![Validation-Gated Sampling Policy Family](/assets/images/posts/research/validator-dividend-tool-call-consensus/fig_policy_family.webp)
*The sampling policy family. A conceptual diagram of how the serving-side sampling levers (VTR, MAJ-k, ARG-k, JUDGE-k) and the model tier lever compose around the free deterministic validator as the axis, on top of a quantized self-hosted checkpoint. A conceptual example; it contains no measured data.*

## Where Consensus and the Tier Upgrade Sit, and the Crossover

The second lever spends extra samples on consensus. Under whole-plan majority, the probability that the k (odd) majority plan is correct is a binomial tail, and at k=3 it is q²(3-2q). The marginal dividend d_k earned by moving from k to k+2 decreases as k grows whenever q is above 1/2. At the q=0.9 anchor, the first consensus step 1→3 buys 7.2 points at the cost of 2 samples, with an MCD of 27.8c. The second step 3→5 gets only 1.9 points for the same 2c, and the MCD is 103c. The marginal price steepens with every added sample, the same diminishing-returns shape the self-consistency efficiency literature has already shown. If per-draw accuracy is at or below 50%, majority voting does not beat a single draw, and the paper calls this regime the vote-dilution regime.

The point where the gate and majority cross also falls out of the same calculation. The gate ceiling Q*=q/(1-p_d) exceeds the accuracy of MAJ-3 exactly when p_d exceeds p_d*(q)=1-1/(q(3-2q)). At q=0.9, this threshold is 7.41 points. Just below the threshold, at p_d=7 points, MAJ-3 leads by 0.4 points in accuracy, but the MCDs differ by more than 20x: VTR's 1.11c against 27.8c. This is exactly where accuracy and margin price point to different levers.

The gate and MAJ-3 compose by multiplication. The gate first renormalizes (q,c) to (q/(1-p_d), c/(1-p_d)), and the consensus binomial applies to those values as-is. At the anchor, gate+MAJ-3 reaches 99.7% at an expected 3.23 samples.

The model tier upgrade lands on the same price axis. The upgraded model M' delivers accuracy q' at r times the per-sample cost. A resampling increment k→k+2 is cheaper than the tier upgrade exactly when (r-1)·d_k>2(q'-q) holds. At q=0.9, r=2, and a 5-point gap, MCD_tier is 20c, cheaper than the first consensus step's 27.8c. Since d_k decreases in k, there is no resampling budget cheaper than this tier at any odd k. Consensus is only competitive when the next tier is expensive (r is large) or when the accuracy gap is small (between adjacent quantization steps). The corollary is sharper still: when q is above 1/2 and r is at least 2, the gate lever is the cheapest of the three at every odd k.

The judge lever is dominated. Q_J(k)=β(1-(1-q)^k), and as long as β is at or below β*=q/(1-p_d)/(1-(1-q)^k), it never reaches VTR's c/q on a quality-per-dollar basis. At q=0.9, p_d=0.07, k=3, β* is 96.9%, a conditional accuracy a calibrated cheap judge cannot exceed. The judge only makes sense in a routing-decision regime without a deterministic validator.

![Cost-Quality Frontier of the Sampling Levers](/assets/images/posts/research/validator-dividend-tool-call-consensus/fig_cost_quality_frontier.webp)
*Quality and expected cost of the six arms (A0 k=1, VTR-2, tier r=2 q'=0.95, MAJ-3, gate+MAJ-3, MAJ-5). Values computed with the closed-form expressions of the q=0.9, p_d=0.07, p_s=0.03 interpretation model; not measured. The dashed line is the baseline quality-per-dollar q/c.*

## What It Leaves for the Company, Society, and Science

The analysis compresses the sampling policy for unattended agent loops into four rules. First, always gate with n_max=2. It is the cheapest lever, with a margin cost of c/q per quality unit, and it ends on a single sample with probability 1-p_d. Second, add consensus once you pass the gate ceiling. If the target exceeds q/(1-p_d), add MAJ-3; in the single-silent-argument regime, add ARG-3. Third, upgrade tiers only at the crossover, namely when (r-1)·d_k>2(q'-q) no longer holds: when the remaining silent mass passes the target, or when the consensus MCD exceeds the tier MCD. Fourth, do not use the judge lever while a deterministic validator exists. It is a dominated lever, reserved for validator-free regimes.

![Marginal Cost per Quality Point across Levers](/assets/images/posts/research/validator-dividend-tool-call-consensus/fig_mcd_comparison.webp)
*Margin cost per lever (per quality point). In the q=0.9 interpretation model, the validation-then-resample gate is the cheapest lever, well below the model tier upgrade and the first consensus increment. An interpretation model, not a measurement.*

For ThakiCloud, this becomes the standing decision basis of the token factory. As long as agent workloads run on quantized self-hosted models, it is quantified which lever to pull first when buying one point of tool-call accuracy and how far its dividend reaches. It is a basis usable immediately in sampling-policy decisions for serving and the agent loop, and a policy that can move straight to measurement through the pre-registered BFCL protocol. For society, it lowers the cost and energy barriers to trustworthy autonomous agent operation. Without large models, pairing the free deterministic validator with the right sampling policy on cheap quantized self-hosted inference yields large-model-grade tool-calling reliability, which reduces the cost of running unattended automation safely. For science, it lifts self-consistency from free-text answers to structured agent actions and establishes the quality-per-dollar frontier over sample count and the resampling-versus-tier-upgrade crossover.

There is one more connection. A previous study measured the accuracy tax τ_q that quantized checkpoints impose on tool calls, and NVFP4 was 89.6% over 800 cases. The gate dividend equals that tax's discoverable part multiplied by q/(1-p_d)≤1. In other words, the gate is a lever that recovers the quantization tax at a margin price of c/q, and the ceiling on what can be recovered is set by the silence floor. This is a falsifiable prediction that links back to the earlier study, and it becomes prediction P1, the first prediction of the pre-registered protocol.

<!-- nlm-visual -->
![Key-concept summary infographic 2](/assets/images/posts/news/validator-dividend-tool-call-consensus/en/nlm-infographic-2.webp)
*Infographic generated by NotebookLM from the sources.*

## What Not to Believe

This paper is an analytical study and reports no measurements at all. Every number is a closed-form value derived from the stated parameters.

First, the independent-draw assumption. Plans for a fixed task are approximated as i.i.d. draws at temperature T>0, but multi-step tool calls show measured irreproducibility even for identical calls. If failures are correlated, the realized dividend shrinks, and the pre-registered check R2 looks at exactly this. Second, the perfect-validator assumption. V is assumed to reject every D and pass every C and S, but a real validator has a nonzero false-pass rate on the silent class. The paper treats this as ε perturbation and points to token-level runtime control and rollback as deployment mechanisms that lower the false-pass rate. Third, the single-correct-plan assumption. If multiple valid plans exist, whole-plan majority is a conservative lower bound, and allowing several correct plans only raises the majority mass.

The evaluation structure is also tied to BFCL. The category structure and the scoring semantics are BFCL's, and p_d and p_s can move on other suites. The cost ratios r and j and the throughput multiplier are approximations that must be re-derived on the serving stack before deployment. The judge's β is a model parameter, not a measurement.

The road to measurement is already set. Self-hosted NVFP4 27B on H200, the BFCL simple, multiple, and parallel categories, k=1,2,3,5. Five arms are pre-registered: A0 (k=1), A1 (VTR n_max=2), A2 (MAJ-3), A3 (ARG-3), A4 (8B local judge JUDGE-5), each with predictions P1~P4 (dividend ceiling, silence floor, crossover, judge dominance) and falsification criteria R1~R4 (independence violation, common failure, quantization tax, judge information). It is designed so that if a criterion is hit, the conclusion falls with it.

The paper detail page is available here: [The Validator's Dividend: Measuring the Cost-Quality Frontier of Validation-Gated Resampling versus k-Sample Consensus for Agentic Tool-Call Output on Self-Hosted H200](https://huggingface.co/datasets/thaki-AI/daily-paper-2026-09-23-validator-dividend-tool-call-consensus)

*All three figures in this post are conceptual diagrams and interpretation-model curves, and contain no measured data. The k=1 baseline of 89.6% (800 cases) cited in the body is a measured value from the previous study.*
