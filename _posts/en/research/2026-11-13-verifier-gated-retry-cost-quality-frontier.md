---
title: "The Verifier's Dividend: A Paper That Prices in Closed Form, on a Self-Hosted H200, the Third Lever That Fixes Unattended Agent Tool-Call Failures: What Accuracy a Zero-Token Deterministic Verifier-Gated Retry Buys Against Blind Resampling and a 27B Tier Upgrade, and Where It Breaks Even at B*=2"
seo_title: "The Verifier's Dividend paper: closed-form pricing of the cost-quality frontier for the two paid levers that fix unattended agent tool-call failures (blind resampling/majority voting, model tier upgrade) and a third zero-token lever (a gated retry where a deterministic AST verifier catches failures on the CPU and feeds the error message into the retry prompt), on a self-hosted H200. Under deterministic decoding the blind gated retry buys a zero accuracy gain (blind flatness), while feeding verifier information into the retry prompt climbs to the static ceiling 1-p_s and dominates at 0.0969, below the majority-voting crossover (0.1071). In the worked parameterization, B*=2 buys the teacher's quality edge (0.90) at 47% of the teacher one-shot bill (1.18 c_S, Q=0.9681). The blended policy (escalating only the residual 1.19% to the teacher) lands at 0.9788 for 1.21 c_S. A preregistered 7-arm 40-task protocol performs the confirmation for at most $1.10 (expected bill about $0.60). An explicit upgrade of Self-Consistency and Validator's Dividend, Qwen3-4B BF16, 27B NVFP4, BFCL-style judge-free evaluation, unattended automation - ThakiCloud"
seo_description: "When an unattended agent's tool call fails, the usual move is to resample the same prompt or route to a bigger model. This paper price-compares a third lever: a zero-token deterministic verifier-gated retry that puts the verification error message into the retry prompt. Under deterministic decoding, blind retries buy zero accuracy gain; in the worked parameterization the feedback retry exceeds the 27B teacher's one-shot quality of 0.90 at 0.9681 for 47% of the teacher bill at B*=2, and a preregistered 7-arm 40-task protocol performs the confirmation for at most $1.10 (about $0.60 expected)."
excerpt: "A blind retry buys exactly 0 points of accuracy under deterministic decoding while still billing 1.18 c_S. The same 1.18 c_S that puts the verifier's error message into the retry prompt buys 16.8 points. This paper prices that gap in closed form and shows where break-even lands against sending the same money to a 27B teacher: at B*=2, with the teacher's quality edge sold at 47% of the teacher one-shot bill. The confirmation run is a preregistered 7-arm protocol capped at $1.10."
date: 2026-11-13
tags:
  - deterministic-verification
  - verifier-gated-retry
  - agentic-tool-calling
  - majority-voting
  - model-tier-upgrade
  - cost-quality-frontier
  - bfcl
  - verification-feedback
  - h200-serving
  - unattended-automation
canonical_url: "https://thakicloud.com/tech-blog/en/research/verifier-gated-retry-cost-quality-frontier/"
categories: [research]
author_profile: true
toc: true
---

If you run unattended agents on a self-hosted H200 and have to set the cost policy for fixing the agent's tool-call failures, this paper is for you. Today there are two corrective levers for fixing failures, and both are paid in tokens: resampling the same prompt and taking a majority vote, and tier upgrades that send that budget to a bigger model. This paper price-compares a third lever, a deterministic verifier-gated retry that catches verification errors on the CPU at zero tokens and attaches the error message to the retry prompt. It prices, in closed form, how much accuracy that lever buys and when its budget breaks even against sending the same budget to a 27B teacher. For anyone running the ThakiCloud token factory's unattended agent loop, it becomes a per-task billing rule for the execution stage.

One thing to know before reading: this is an analytical paper and it reports no new execution-stage measurements. Every frontier value is a model estimate derived under stated hypotheses and declared self-hosted rates. The structural results, the flatness of blind retries, the shape of the feedback frontier, and the existence conditions for break-even, hold without depending on the assumptions. The job of confirming the numbers belongs to the preregistered 7-arm 40-task protocol at the end of the paper, and that run costs at most $1.10 at declared rates, about $0.60 in expected billing.

## In Plain Terms

Take an expense office. An accountant writes up an expense report, and a machine with fixed rules checks the format. The machine runs on the CPU without spending tokens and emits error messages that tell you how to fix the problem, like "the date field is not in ISO format." Rewrite after reading that message and almost all structural errors (recovery rate s1 ≈ 1) get fixed. The other options are two: ignore the machine's message and just rewrite (a blind retry), or hand it to a senior accountant (the teacher, at 2.5x the rate, a tier upgrade).

The question in this paper: when does machine + rewrite beat the senior? Under deterministic decoding, rewriting verbatim resamples the same string, so the accuracy gain is 0. What the machine buys is a single detection, and that detection is what makes feedback repair and the escalation trigger possible. In the worked parameterization, the answer is this: the senior's quality edge (0.90) is bought at 47% of the senior one-shot bill (1.18 c_S). Break-even arrives at one retry, B* = 2, and the full dividend up to the static ceiling (1-p_s) fits inside a single senior one-shot bill. The verifier is, in effect, a pure option: it is exercised only on flagged mass and carries no false-positive penalty.

## The Problem: An Unpriced Lever in the Execution-Stage Correction Loop

The ThakiCloud cost-quality series has priced the unattended agent loop stage by stage on a self-hosted H200. Model tier x quantization (Precision Ladder), load (Concurrency Tax), and the router's final stage (Apprentice Reranker, Menu Width) all carry prices. One lever is left unpriced, and it is the correction loop of the execution stage. When a tool call fails the check, the harness has four options: resample the same prompt, resample several times and take a majority vote, attach the verifier's error message to the retry prompt, or send the same budget to a bigger model.

Two questions follow. Which option buys the most accuracy per dollar? And at what budget does the small model's retry break even with the teacher? The intuitive answer is a tier upgrade: a bigger model is more accurate. But under this series' platform premise, self-hosted fixed hourly-rate billing, sending to a bigger model is nothing more than routing to a serving stack with 2.5x the token rate (ρ = c_T/c_S = 2.5, the declared rate card). The story changes when the same money is spent on retries of the small model. The moment the verifier catches the error and puts its message into the retry prompt, the retry stops being a resample and becomes a correction.

The weakness of blind retries is already bound by external evidence. Retry-aware model routing research reports that same-prompt retries after a failure succeed at only 17~53% of the rate of the first attempt. Resampling alone does not wash the failure away, and the paper's sticky-failure assumption (s_blind ≤ q0) is set inside that range. By contrast, conditioning on the verification error can escape that ceiling, because for structural errors the message prescribes the fix. This paper writes that difference as a price.

It is also an explicit upgrade of two past results. Where Self-Consistency proposed majority voting over free-form answers, this paper lifts majority voting to structured agentic tool calls. The unit of the vote is an exact-match tool-call string graded by code, and the judge is a zero-token deterministic verifier. The earlier paper, Validator's Dividend, priced gating versus consensus on a free verifier, but its retry policy was blind (a flag only discards the sample and tells the model nothing), and the escalation arm (spending the same budget on a 27B teacher) was open. This paper prices the feedback arm and closes the escalation arm at break-even B*.

## Design: Two Tiers, Three Task Families, Seven Arms

The platform uses the series premise as-is: on a self-hosted H200, one GPU serves one (model, precision) point at a fixed hourly rate. The small tier is Qwen3-4B (BF16, seed-fixed greedy decoding) and the teacher tier is the 27B NVFP4 production checkpoint. The teacher is the checkpoint that anchored at 89.6% on this series' 800-case BFCL-style suite, rounded to q_T = 0.90 in the model. Evaluation is judge-free: deterministic BFCL-style checks certify the policy only at the deployment gate g = 0.85.

Tasks are single-shot deterministic tool calls with exact ground truth, and all three families are verifiable for free. F1 is arithmetic that respects an AST whitelist, F2 is strict ISO date scheduling, and F3 is list filtering with exact output. Each family has a two-layer error taxonomy. Structural errors are caught by the static check together with an actionable message, and the message prescribes the fix. Semantic errors, a wrong operator or order, an off-by-one date, a malformed literal, are only partly caught.

The verifier V has two layers. V_static is schema + AST + syntax checking, zero-token and CPU-side; it detects structural errors informatively and, via range and parse checks, catches some semantic errors too. V_oracle is a ground-truth-aware mechanism, a ceiling device, and it is not deployed.

Under the outcome decomposition (A1), the small model's sample goes three ways: correct at q0, wrong but detectable at p_d, and quietly wrong at p_s. δ = p_d/(1-q0) is the static detection rate. In the error taxonomy (A2), a σ share of the detectable mass p_d is structural/informative with recovery rate s1 ≈ 1, and the remaining 1-σ is semantic with recovery rate s2 = q0 + φ. φ is the feedback headroom: only the part that exceeds the base success rate when conditioning on the observed error. Class stability (A3) gives each task a fixed latent class, and repair samples within a class are conditionally independent given the feedback history.

Billing (A4, A5) is also a series premise. Under deterministic decoding, resampling the same prompt yields the same string, so s_blind = 0. The feedback arm's retry prompt is a correction, i.e., the verifier message is added, so its sample is fresh. Per-sample billing is c_S for the small model and c_T for the teacher, with ρ = 2.5 on the declared rate card. There are seven arms at a fixed per-task budget: A0 one-shot (small), A1 majority over k stochastic samples, A2 gated blind retry (deterministic, flatness control), A2s gated blind retry (stochastic), A3 gated feedback retry, A4 teacher one-shot, and A5 teacher-gated (sensitivity arm).

## The Blind Gated Retry Buys Exactly 0 Points of Accuracy

P1 (blind flatness) is the sharpest result in this paper. Under deterministic decoding, the blind gated retry adds exactly 0 accuracy over one-shot at any budget B ≥ 1. Resampling the same prompt produces the same string, and the gate only discards flagged samples. What is discarded was wrong to begin with, so discarding raises nothing. The gate's only contribution is zero-token detection, and that is what enables A3's repair and the escalation trigger. Splitting selection from solving, A2 is pure selection and A3 is selection + solving.

In the worked parameterization, A2 and A3 bill the same 1.18 c_S at B = 2. A3 buys 16.8 points of quality; A2 buys nothing. That is P1's flatness written in dollars. The sticky-failure ceiling matches the 17~53% retry success rates in the literature, and only feedback can exceed that ceiling, because in the informative share σ structural errors become corrections rather than resamples.

## The Feedback Frontier: The Majority-Voting Crossover Moves Down

The feedback frontier (T1) is in closed form. Q_B^A3 = q0 + p_d R_{B-1}, where R_{B-1} is the probability that at least one of B-1 repair samples is correct, weighted by s1 and s2 across the σ and 1-σ shares. Q_1 = q0, it increases in B, and its limit is the static ceiling 1-p_s. It sits above the blind arm's silent floor 1-p_s/(1-p_d) by p_s p_d/(1-p_d), which is 0.44 points in the parameterization. The reason: the gate's information does not merely select among i.i.d. samples; it repairs the detected mass. The remaining silence p_s is caught by no static verifier; only the oracle tier lifts the ceiling (90% flag assumption on the silent mass).

![Quality per Draw Budget: Blind Gate Flat, Feedback Repair Climbs to the Static Ceiling](/assets/images/posts/research/verifier-gated-retry-cost-quality-frontier/fig2.png)
*In the worked parameterization, the blind gated arm stays flat at the one-shot level, majority voting climbs slowly, and the feedback gated retry crosses teacher one-shot quality near B = 2 and approaches the static ceiling 1-p_s. These are analytical model estimates, not measurements.*

The comparison with majority voting (P2) runs at the same budget. A3 beats A1 at B = k when p_d ≥ p_d^{*,fb}(k) = (Q_k^{A1} - q0)/R_{k-1}, and the feedback crossover lands below the blind crossover of the earlier work. In the parameterization, p_d^{*,fb}(3) = 0.0969 versus the blind crossover at 0.1071. If φ > 0 or σ > 0, A3 weakly dominates A1 at every budget and strictly dominates it on the detectable mass. The difference is not only in quality. The confidently wrong consensus mass of majority voting at k = 3 is about 3.6 points, while A3's known-wrong emission is only about 0.16 points. A 22-fold contrast. Accuracy per dollar: A3 at 0.1425~0.1508, A1 at 0.0284~0.0320, A4 at 0.0400.

The static verifier is zero-token (c_V = 0), so if φ > 0 or σ > 0, A3 strictly dominates A2 at B ≥ 2 (a corollary). The verifier is, in effect, a pure option: it exercises a zero-cost repair claim only on the detected mass p_d and never on the correct mass q0. There is no false-positive penalty: the silent mass is missed, not falsely flagged. On the energy ledger as well, each retry sample costs real device time, and the burst of up to B samples per task moves the load axis. At B* = 2, though, the burst adds at most one sample on the p_d mass, so the load correction at break-even is second-order (light-load regime).

## Break-Even B*: Buying the Teacher's Quality Edge at 47% of the Teacher Bill

Spend-parity break-even (T2) is the system-level result of this paper. B* is the smallest budget at which the small model's feedback-gated quality reaches the teacher's q_T while the bill does not exceed a teacher one-shot (c_T). In the worked parameterization, the teacher's quality edge D = q_T - q0 = 0.10 and the structural mass p_d σ = 0.108. Since D ≤ p_d σ, B_q = 2; and since D ≤ D_c = 0.1116 (the first repair dividend), the case is in regime (i). The crossing arrives at the first feedback retry, and the dividend is feedback-attributed (the verifier message), not resampling luck.

Q_2 = 0.9681 exceeds the teacher one-shot's 0.90, and the bill is 1.18 c_S, which is 47% of the teacher one-shot bill (2.50 c_S). The full dividend up to the static ceiling 1-p_s also fits inside a single teacher one-shot bill (E_∞ = 1.194 < ρ = 2.5). Sensitivity runs in three branches. As the crossing shifts to the log branch and before the ceiling is reached, B* moves from 2 to 3, 4 (with σ = 0.40, D_c falls to 0.0774 and the first-retry attribution breaks, yet B* = 2; with D = 0.17, B* = 3). A cheaper teacher (ρ = 1.5) does not resurrect the gate: in the shared regime, ρ enters only the feasibility condition. And when D ≥ p_d, i.e., when the teacher's edge exceeds the entire detectable mass, q_T ≥ 1-p_s and the static ceiling binds, so no small-model policy reaches the teacher. Then sending the money to the teacher is the right call (the apprentice's escalation condition dominates), and the case is regime (iii).

![Spend-Parity Contrast: Quality and Bill per Arm](/assets/images/posts/research/verifier-gated-retry-cost-quality-frontier/fig3.png)
*The blind gated arm bills above one-shot with zero quality gain, while the feedback gated retry and the blended policy exceed teacher one-shot on quality for a fraction of the teacher bill. These are analytical model estimates, not measurements.*

The A5 arm, which gates the teacher with the same free verifier, is also a sensitivity arm. At B_T = 2 it delivers 0.9720 for 2.70 c_S, dominated in cost by A3@B* and dominated in both dimensions at B = 5.

## Deployment Rule: Execution-Stage Cost Policy

The per-task policy is four lines at gate g = 0.85 and B* = 2. Sample d1 on the small tier and check it with V_static. If it passes, emit d1. If it is flagged (the p_d mass), attach the error message to the prompt, sample d2, and check again. If it passes, emit d2. If it is flagged again, the residual is m_{B*} = 1.19% and you escalate to the teacher: one sample, gated by the same free verifier.

The billing identity is bill* = c_S E_{B*} + m_{B*} c_T, which is 1.21 c_S in the parameterization. Quality is Q* = 0.9788. Compared with teacher-only at 0.90 for 2.50 c_S and one-shot at 0.80 for 1.00 c_S, quality beats the teacher and the bill is less than half the teacher's. The deployment rule is this: gate at g = 0.85, feedback retry up to B*, escalation only on the residual.

This lever composes with the series' priced axes: (model x precision), load, router stage, and B from this paper. The escalation trigger is a rare route, 1.19% of tasks, and the shadow-prefill pattern serves it without a cold-start penalty.

## Preregistered Protocol: Confirmation for at Most $1.10

The protocol is a fixed-seed 40-task deterministic suite: 14 arithmetic, 13 date, 13 filtering. Exact ground truth, judge-free BFCL-style code checks, deployment gate g = 0.85. Models are Qwen3-4B (BF16, seeded greedy) against 27B NVFP4, running the seven arms at the declared rate card (ρ = 2.5).

Falsifying P1 is the job of the A2s arm. Since deterministic A2 has s_blind = 0 by construction, the falsification test for blind flatness runs on the same-prompt resamples of stochastic A2s. The estimand is the sticky-failure ratio s_blind/q0: if Q_B^{A2s} fails to track the exchangeable blind form inside the item-flip noise floor as B grows, P1 breaks and the samples are negatively correlated. A1 is pinned to a single k = 5 per task; the k = 3 row in the table is an analytic matched-budget reference, not a protocol arm.

There are seven estimands: static versus oracle detection rate (δ, η_ox), the informative share σ, feedback headroom φ, the sticky-failure ratio of A2s resamples, the false-positive rate (assumed 0 because a deterministic checker cannot flag correct samples; the protocol certifies this), the measured break-even B*, and the burst load correction H. Falsification rules P1~P6 (blind flatness, feedback headroom, spend parity, detection-rate drift, feedback accumulation collapse, burst penalty) and robustness checks R1~R4 (three fixed seeds, family composition, small-tier quantization BF16 vs NVFP4, serving load) are written down alongside them.

The cost is a declared upper bound. The worst case is 27.5 c_S per task (20 small-model samples + 3 teacher samples converted at ρ = 2.5), and with declared c_S ≤ 1 mUSD/sample, the full 40 tasks cost at most $1.10. That works out to about $0.60 at the expected bill of 15.33 c_S per task. The protocol is preregistered in this paper and was not executed in it.

## Where It Touches: Company, Society, Science

What the company gets is an execution-stage cost policy for the ThakiCloud token factory. The per-task bill drops from teacher-only 2.50 c_S to the blended policy's 1.21 c_S, while quality at 0.9788 exceeds teacher one-shot (0.90). Because break-even B* is in closed form, whenever the detection rate δ, the informative share σ, or the headroom φ changes, B* is recomputed. It is a concrete cost rule that lowers the per-task cost of the unattended agent loop at fixed quality.

What society gets is an accuracy lever that is almost free. Replacing LLM judge calls with local deterministic verification pays for the accuracy gains with zero-token CPU checks. The cost and energy floor of trustworthy unattended automation moves down, so small self-hosted deployments that cannot afford judges can also get below that floor.

What remains for science is the first formal characterization of verifier-gated retry on structured agentic tool calls, up to where free verification dominates majority voting and tier upgrades at fixed budget, given the static detection rate and feedback headroom. It is an explicit upgrade: Self-Consistency lifted to structured tool calls under a free deterministic verifier, Validator's Dividend's blind retry replaced by a feedback arm, and its open escalation arm closed at B*. It also includes the separation between gating as selection and feedback as solving, and an offline dual that distills verification feedback into weights (moving σ and φ into the checkpoint re-solves B*).

## Limits: What Has Not Been Measured Yet

The limits are stated explicitly.

First, this paper is analytical. Every frontier value is either a closed-form derivation under A1~A5 or a number coming from stated assumptions (the table's parameterization), declared rates, or cited sources. The values of δ, σ, φ, and B* are the job of the preregistered protocol to confirm.

Second, retries may not be i.i.d. Accumulated feedback can shift the error type across retries (reported in the literature), and in that case the class-stability form overstates the frontier. The fallback is the fresh re-partitioning form: the two forms agree at B = 1 and at infinity, and in the parameterization the gap is 0.08 points at B = 3 and converges to 0. P5 catches the collapse.

Third, the verifier has blind spots. The σ split is the tool-call twin of the structure-versus-semantics gap. The static verifier is strong on structure and weak on semantics, and the silent floor 1-p_s is the price of that gap. Only the oracle tier (η_ox = 0.90 assumed) lifts it.

Fourth, load interactions are beyond first order. The billing identity is linear in the headroom price H, and the burst penalty near the safety ceiling is not second-order. P6 and R4 bound that regime.

Fifth, the majority-voting benchmark is not the last word. The literature has conditions under which majority voting harms small models, and budget-aware refusal; A1 is the i.i.d. benchmark both refine. The P2 crossover is the decision rule for when A3 replaces A1.

Sixth, the task families are single-shot. In multi-turn function calls, state and verifier messages extend across turns, and the spend-parity identity is re-solved per-turn with p_d.

The paper's full text and companion materials are on the Hugging Face paper detail page. https://huggingface.co/datasets/thaki-AI/daily-paper-2026-11-13-verifier-gated-retry-cost-quality-frontier

*The cost numbers in this body are closed-form derivations under the declared self-hosted billing model (expected number of samples x declared nominal rate) or measurements attributed to earlier series research. q_T = 0.90 is the rounded value of the series' 89.6% anchor, and the 17~53% sticky-failure range is a value from the cited literature. The frontier values in the two figures are model estimates under stated assumptions, not measurements. The 7-arm 40-task protocol is preregistered in the paper and was not executed in it; the measured values of δ, σ, φ, and B* will be reported at the time the run completes.*
