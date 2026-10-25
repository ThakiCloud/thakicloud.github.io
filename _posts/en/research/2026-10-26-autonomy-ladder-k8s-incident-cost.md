---
title: "The Autonomy Ladder: When Kubernetes incidents are stratified by remediation complexity from L1 to L3, the boundary where unattended remediation is safe and cheap reaches L2 in the nominal scenario, and that boundary and the per-incident cost can be computed before any permission is granted"
seo_title: "The Autonomy Ladder: A complexity-stratification model that derives in closed form how far unattended Kubernetes incident remediation by LLM agents can go, the per-incident cost, and the human-in-the-loop boundary (autonomy frontier k*, fault injection benchmark, R2Act upgrade) - ThakiCloud"
seo_description: "ThakiCloud's analytic paper The Autonomy Ladder stratifies Kubernetes incidents by remediation complexity into L1 (single-resource restart), L2 (configuration/state change), and L3 (multi-resource cascade), and scores them as a closed loop from diagnosis through planning, execution, and verification. In the per-stage outcome algebra and the per-incident cost model, the autonomy frontier k* where unattended operation is justified emerges in closed form. Under the stated nominal assumptions, k*=2, and the L3 boundary is set by the cost condition at lambda=1 (the safety cap also binds when u3>0.04). The paper lifts R2Act's diagnosis-to-action evaluation into a scored closed loop over execution and verification, and pre-registers a fault injection protocol and falsification zones F1-F5. It is analytic and contains no new measurements."
excerpt: "How far can an LLM agent carry a Kubernetes incident without human intervention, what does it cost per incident, and from where must a human stay in the loop? ThakiCloud's analytic paper The Autonomy Ladder stratifies incidents by remediation complexity from L1 to L3 and scores diagnosis, planning, execution, and verification as a closed loop. The per-stage outcome algebra and the per-incident cost derive the autonomy frontier k* in closed form, and under the stated nominal assumptions k*=2. The restart and configuration-change tiers can run unattended, while the multi-resource cascade tier keeps a human in place. The ladder property theorem guarantees this boundary has no holes, and the pre-registered fault injection protocol and falsification zones F1-F5 mark where declared numbers get replaced by measurements."
date: 2026-10-26
last_modified_at: 2026-10-26
tags:
  - autonomous-k8s-operations
  - incident-remediation
  - fault-injection
  - complexity-stratification
  - human-in-the-loop-boundary
  - cost-per-incident
  - root-cause-analysis
  - unattended-automation
  - llm-agent-sre
categories:
  - research
author_profile: true
toc: true
toc_label: "Table of Contents"
canonical_url: "https://thakicloud.com/tech-blog/en/research/autonomy-ladder-k8s-incident-cost/"
---

An agent that fixes faults around the house on its own should only be trusted to a certain depth. That depth, together with the conditions that set cost and the conditions that set safety, can be computed before any permission is granted. This post is for cloud and AI engineers who own cluster on-call, and for teams that must settle, in numbers, how far to hand over remediation authority.

It introduces ThakiCloud's analytic paper, the autonomy ladder. The paper binds into one model how far an agent can carry a fault without human intervention, what that costs per incident, and from where a human must stay in the loop. To be clear first: this paper contains no new measurements. Every number in the body is a closed-form evaluation of the stated nominal assumptions, or a value from a cited reference.

What the paper fixes is the model, the boundary conditions, and the pre-registered measurement protocol. Field measurements on a self-hosted cluster will be reported in follow-up work.

![Illustration of the core idea of The Autonomy Ladder: When Kubernetes incidents are stratified by remediation complexity from L1 to L3, the boundary where unattended remediation is safe and cheap reaches L2 in the nominal scenario, and that boundary and the per-incident cost can be computed before any permission is granted](/assets/images/autonomy-ladder-k8s-incident-cost-hero.webp)
*A visual metaphor for the article's key idea.*

## In plain terms

Let me explain it with a child who is learning to fix small faults around the house. The parent is the on-call engineer, and the child is the agent. The depth of a fault comes in three tiers. One appliance has stopped. Several have stopped because a setting went wrong. A fault has spread to several places, and the order of fixing them matters.

The first tier is restarting a single resource. The second is changing a setting and restarting the dependents in order. The third is an ordered fix across several resources, with a rollback plan ready. The deeper the tier, the more places a fix touches, and the bigger the damage when it goes wrong.

There are two ways to handle a fault. In unattended mode, the child diagnoses, plans, executes, and verifies everything alone. In attended mode, the child only diagnoses and reports, and the parent approves and executes. Even in attended mode, an accurate report saves the parent's search work. That saving is called the diagnostic dividend.

The parent's line has two conditions. First, cost: the time the parent saves by letting the child act alone must not be less than the cost of keeping watch. Second, safety: the chance that the child makes a mistake and leaves damage must stay within tolerance. The deepest tier that passes both is the autonomy frontier k*.

In the paper's stated nominal scenario, the line reaches the second tier. Restarting one appliance and fixing a setting can be left to the child alone, safely and cheaply. When a fault has spread to several places, the parent has to stay.

The order of permission never skips a tier. A higher tier is not allowed while a lower tier still fails. In the child metaphor, the parent does not hand over the far errand while the near errand is still failing. This property, the ladder property, keeps the line from developing holes.

When faults are rare, the cost of keeping watch grows, and the line can move up one tier. But the safety line never loosens no matter how often faults occur. Only the accident rate moves the safety line.

In other words: the child may fix faults at home alone up to the second rung of the ladder, and the parent stays once they spread across places. The line is a value you compute before granting permission, not a guess.

## What we did

### The question prior work stopped short of

Connecting an agent to the cluster API for on-call already works in places. The multi-agent reliability stack STRATUS performs diagnosis and action on live workloads, and recent surveys of agentic AIOps and NetOps architectures tie the level of autonomy to the allowed tool surface and the required evidence.

So the remaining question is one. Not whether an agent can diagnose, but how far it can carry a fault alone. Up to which depth of remediation, at what cost per incident, and from where does the human boundary begin? On-call economics says this is at once a capability problem and a budget problem.

Existing evaluations stop short of this question. Diagnosis benchmarks score root-cause identification. Cloud-OpsBench uses 754 runtime-verified cases, AIOpsBench scores per step with Localization, Identification, and Reason, and ARGUS evaluates diagnosis through the MCP tool interface of a live cluster.

STAR attributes remediation failures to the steps of an RCA trace, and CloudIR-Bench extends RCA from incident reports to mitigation-action prediction. ReliabilityBench probes agent reliability under production-grade stress. All of these evaluations end at in-system execution. They score what the agent said, not what the system actually did afterward.

![Coverage of the five closed-loop elements across evaluation classes](/assets/images/posts/research/autonomy-ladder-k8s-incident-cost/fig3_landscape_coverage.webp)
*Conceptual comparison of how many of the five closed-loop elements each prior research cluster provides (in-system execution, harness-verified outcomes, complexity stratification, per-incident cost, and the policy-objectification of the HITL boundary). R2Act's only element is a validity-gated live replay, which executes predicted remediation actions and checks post-remediation service health, but it neither scores the closed loop nor prices it nor stratifies it nor sets a boundary.*

The closest prior work is R2Act. R2Act scores the decision to move from diagnosis to action. Its auxiliary validity-gated live replay executes predicted remediation actions on a live cluster and checks service health after remediation. The reported figures are 146 of 302 predictions remediated in live execution, a 48.3% validity-gate replay rate.

But that replay is only a confirmation gated by action validity. It is not scored as a closed loop of per-stage outcomes, and it has neither a per-incident price nor a complexity stratification. R2Act's action-validity gate enters as a precondition of this ladder's verification stage. The paper's explicit upgrade lifts the evaluations that stop at diagnosis and the remediation-action decision into a design that adds closed-loop per-stage scores, a per-incident price, a complexity stratification, and a closed-form attended boundary.

End-to-end response systems such as STAIR, PASE, and STRATUS, and field studies of Kubernetes misconfiguration, are systems that actually act. But they report capability, not the boundary.

### The three rungs and two policies

The Autonomy Ladder is the model that fills this empty cell. The axis of this ladder is depth: how far must a fix reach? Where ThakiCloud's prior on-call automation research stratified by fault class, that is, by what is wrong, these two axes are orthogonal and compose. The paper fills four gaps: it stratifies incidents by remediation complexity, scores execution and verification as a closed loop of per-stage outcomes, prices each incident, and derives the human-in-the-loop (HITL) boundary as a closed-form policy object.

Each rung of the ladder is defined only by the depth of the remediation, with the fault class held fixed. L1 is single-resource restart. One pod or container is in an abnormal state, and the fix is a restart or a rescale. L2 is configuration and state change. A value in a ConfigMap or Secret is corrupted and dependent workloads are broken, so the fix corrects the object and restarts its dependents in order. The blast radius is limited.

L3 is a multi-resource cascade. A root-cause misconfiguration is coupled with a second degradation, for example a dependent whose scale has dropped to zero, and the fix is an ordered multi-resource change with a rollback plan. The blast radius crosses the whole service. Each higher rung touches more resources than the one below and includes their reasoning. This is the monotone-complexity assumption.

Each tier is described by parameters that are monotone in the rung k: diagnostic accuracy d_k, the safe-remediation probability r_k conditional on a correct diagnosis, and the probability u_k of leaving collateral damage. In the child metaphor, the deeper the rung, the lower the accuracy and the bigger the damage.

Two policies are contrasted per tier. The unattended policy has the agent perform diagnosis, planning, execution, and verification all by itself. The attended policy has the agent diagnose and review only, while a human approves and executes. The outcome specification has four cases. SR is safe resolution, IE is information-based escalation, U is unsafe action with collateral damage, and NE is a no-effect outcome.

An IE, where the agent withdraws its own action after a correct diagnosis, is a judgment success. A U, where it acts on a wrong diagnosis and leaves damage, is a failure. This asymmetry underpins the ladder's outcome algebra.

![The incident loop and where the human stays](/assets/images/posts/research/autonomy-ladder-k8s-incident-cost/fig1_incident_loop.webp)
*The closed-loop incident process the paper analyzes. The agent performs everything from detection to planning at each stage. Execution is done by the agent alone only below the autonomy frontier, and by a human above it. A harness verifies the cluster state after the agent exits, maps the outcome to SR/IE/U/NE, and prices each incident. It is a conceptual sketch, not a measurement.*

### The cost model and the two conditions

The cost model is entirely per-incident. The agent inference cost c_a,k is b0 + b1·k, because the context grows with the depth of the tier. The human cost c_h,k is t0 + t1·k. The collateral-damage loss L_k is non-decreasing in k.

The diagnostic dividend ψ_k is the fraction of downstream human discrimination work that the agent's correct diagnosis eliminates. The attended noise rate ω_k is how much of the agent's dangerous action modes the agent's review and human execution catch together. A fixed cost F for always-on monitoring, an incident frequency λ, and a damage tolerance ρ also enter.

The per-incident cost of the unattended policy, C^u_k, is c_a,k plus (IE_k + NE_k)·c_h,k plus U_k·L_k. The agent pays its cost in every case. In IE and NE, a human is called in for the full discrimination cost, and in U, the loss becomes real. The cost of the attended policy, C^a_k, is c_a,k plus (1-ψ_k)·c_h,k plus U_k·(1-ω_k)·L_k.

Because the human executes a reviewed plan, the agent's remediation failure modes do not apply to execution. The discrimination cost is paid only at (1-ψ_k), and the remaining damage comes from dangerous action modes that slipped past the joint review.

In the difference between the two policies, Δ_k = C^a_k - C^u_k, the c_a,k cancels out. That means the boundary cannot be set by token cost alone. Unattended operation at tier k is justified under two conditions. C1, cost, requires that Δ_k not fall below -F/λ. C2, safety, requires that U_k not exceed ρ.

The autonomy frontier k* is the highest tier that passes both conditions. If no tier passes, k*=0 and everything is attended. In the child metaphor, it is the deepest errand the parent allows, computed with the two lines, cost and safety.

### The pre-registered fault-injection protocol

The paper pre-registers a fault-injection protocol and falsification zones F1 through F5. The protocol is a complexity-stratified incident benchmark: it measures an LLM agent's diagnosis and remediation end-to-end on a live cluster, down to success rate and cost. The target is a self-hosted Kubernetes cluster. Each tier injects one fault class, and because the injector knows the fault state, the ground-truth state is structurally guaranteed.

L1 is a pod CrashLoopBackOff from a transient OOM, L2 is a corrupted ConfigMap value, and L3 is the coupling of a root-cause misconfiguration with a scale-0 dependent. Training uses a visible split; evaluation uses a sealed same-class holdout and a sealed unknown-class holdout.

The agent operates inside a ReAct-style tool loop, a 12-turn limit, a per-turn token limit, and a real-time limit. The agent cannot score itself; a harness verifies the cluster state after the agent exits and maps the outcome to SR/IE/U/NE.

Falsification zone F1 is monotone capability, d_1 ≥ d_2 ≥ d_3 and r_1 ≥ r_2 ≥ r_3. F2 is linear agent cost. F3 is the existence of a boundary: at least one tier fails C1 or C2, and in the nominal it is L3. F4 is a positive diagnostic dividend, ψ_k > 0, measured by A/B discrimination time. F5 is the order of the binding regime.

Every parameter is mapped to a measurable quantity, and the follow-up field study replaces the declared numbers with measurements.

## What came out

### The frontier has no holes

The ladder property theorem guarantees the shape of the boundary. Under P1 through P7, U_k is non-decreasing in k and Δ_k is non-increasing in k. Those are the per-parameter monotone-complexity assumptions, plus a weak strengthening in which the attended net gain is dominated by depth.

Then the set of tiers that pass both conditions at once is an initial segment, {1, ..., k*}. No hole forms in the frontier where a lower tier fails while a higher tier passes. In the child metaphor, the parent does not allow the far errand while the near errand still fails.

### The four corollaries

Four corollaries describe how the frontier moves. The first is the critical loss. L*_k = S_k/(U_k·(1-ω_k)) is the maximum collateral loss fully absorbed by the attended net gain S_k.

It is monotonically decreasing in k, and it touches exactly 0 where attended operation no longer saves any human time. In tiers above that point, C1 fails no matter how small the loss L_k is. That is the cost-limited region. In tiers below it, at realistic loss levels, only the safety cap C2 binds. The boundary is set by cost at the very top and by the safety cap in the middle.

The second is the frequency floor. At frequency λ, the cost condition holds when L_k ≤ L*_k(λ) = (S_k + F/λ)/(ω_k·U_k). This cap is strictly decreasing in λ. When incidents are rare, the monitoring cost F/λ grows and the cost cap rises.

Then, among the tiers that were blocked purely by cost, those that satisfy the condition are additionally exonerated. In the low-frequency region of the nominal scenario, exactly one tier, L3, is exonerated. But only where the safety cap has already been passed. C2 is independent of λ, and no change in incident frequency can raise the safety cap.

The third is the diagnostic dividend. If the agent can perform no remediation at all, r_k → 0, and never takes a dangerous action, u_k → 0, then attended-with-agent can still be cheaper than attended-without-agent. The condition is ψ_k·c_h,k > c_a,k. In the child metaphor, a child who cannot fix the fault but reports it accurately still saves the parent time in every tier. The agent is cost-positive even as a pure diagnostician.

The fourth is crystallization. A tier where the safe-resolution rate μ_k of a deterministic playbook is measured on a sealed holdout can be promoted from agent execution to deterministic execution. Two conditions keep the promoted tier on the frontier: u_det,k ≤ ρ, and c_det,k < c_a,k - (u_k - u_det,k)·L_k. A promoted tier is re-audited against the falsification zones at each regression point.

### The nominal scenario: k* = 2, and L3 is where the human stays

Every number in this section is a closed-form evaluation of the stated nominal parameterization. Not a measurement. The assumptions are in the table below. Accuracy and the safe-remediation probability fall as the tier rises, and the dangerous-action rate and the loss rise. It is exactly the shape the monotone-complexity assumption predicts.

| Parameter | L1 | L2 | L3 |
|---|---|---|---|
| d_k diagnostic accuracy | 0.95 | 0.88 | 0.75 |
| r_k safe-remediation probability | 0.80 | 0.55 | 0.30 |
| u_k dangerous-action rate | 0.02 | 0.08 | 0.10 |
| h_k information-based hand-off | 0.03 | 0.10 | 0.25 |
| η_k self-uncertainty detection of a wrong diagnosis | 0.40 | 0.35 | 0.30 |
| ζ_k acting despite a wrong diagnosis | 0.10 | 0.20 | 0.40 |
| c_a,k agent cost | 1.0 | 1.5 | 2.0 |
| c_h,k human cost | 3 | 4 | 5 |
| L_k collateral-damage loss | 1 | 2 | 3 |
| ψ_k diagnostic dividend | 0.5 | 0.5 | 0.5 |
| ω_k attended noise rate | 0.8 | 0.8 | 0.8 |

*The stated nominal parameterization (Table 1 of the paper). Cost is in units of normalized human discrimination time and makes no claim of currency. c_a,k is 0.5 + 0.5k and c_h,k is 2 + k. The scalar parameters are ρ = 0.10, F = 0.5, and λ = 1.*

Substituting these assumptions into the outcome algebra and the cost model yields the table below.

| Tier | SR | IE | U | NE | C^u | C^a | Δ | L* | C1 / C2 |
|---|---|---|---|---|---|---|---|---|---|
| L1 | 0.760 | 0.049 | 0.022 | 0.169 | 1.676 | 2.504 | +0.828 | 192.3 | pass / pass |
| L2 | 0.484 | 0.130 | 0.086 | 0.300 | 3.392 | 3.534 | +0.142 | 16.3 | pass / pass |
| L3 | 0.225 | 0.263 | 0.145 | 0.367 | 5.585 | 4.587 | -0.998 | -22.4 | fail / fail |

*Per-tier outcome algebra and cost per incident. A closed-form evaluation of the nominal assumptions, not a measurement. C2 passing means U_k ≤ ρ = 0.10, and C1 passing means Δ_k ≥ -F/λ = -0.5. The frontier is k* = 2.*

At L1, both conditions pass with comfortable margins. At L2, both still pass, but the cost margin narrows sharply. At L3, both conditions fail at once. The safety cap U_3 exceeds the tolerance ρ, and Δ_3 is below -0.5.

In other words: the child may restart one appliance and fix a setting alone, safely and cheaply, but a fault that has spread across places requires the parent to approve and execute. The boundary of the nominal scenario is k* = 2.

The boundary does not move even when L3's dangerous-action rate u_3 and loss L_3 are perturbed. Lowering u_3 to 0.02 and 0.04 passes the safety cap, but the cost condition still fails. If u_3 is 0.10 or above, both conditions fail at once and the safety cap binds first.

Across the entire grid of u_3 and L_3, the frontier stays at k* = 2. L3's boundary is set by the cost condition at λ = 1. The safety cap binds additionally only when u_3 > 0.04.

Frequency and noise rate give the same picture. With u_3 = 0.02 and L_3 = 1.0, the safety cap already passes L3. At λ = 0.1, the monitoring cost F/λ = 5 lifts the cost cap, additionally exonerating L3 alone, so k* becomes 3.

If λ is 1 or above, the frontier returns to k* = 2. When incidents are rare, monitoring is costly per incident, so cost admits more tiers. Safety admits none. Raising the attended noise rate ω from 0.50 to 0.95 deepens the cost deficit, but k* stays unchanged. Cost and safety point in the same direction.

![The autonomy ladder: rung-by-rung gate verdicts](/assets/images/posts/research/autonomy-ladder-k8s-incident-cost/fig2_ladder_rungs.webp)
*In the stated nominal scenario, L1 and L2 pass both conditions, C1 (cost) and C2 (safety), so unattended operation is possible, while L3 fails both, so a human must stay in the loop. By the ladder property theorem the frontier has no holes. An output of the analytic model, not a measurement.*

## What to change

The operational reading of these results is a per-tier autonomy rule. L1 (restart) is unattended, with after-the-fact audit. L2 (configuration and state change) is run unattended only when the measured u_2 ≤ ρ and L_2 ≤ L*_2. Otherwise, the agent diagnoses and proposes, and a human executes.

L3 (cascade) is attended across the entire nominal scenario when λ ≥ 1. Re-evaluate when the incident frequency drops, or when improvements in d_3 and r_3 move U_3 and Δ_3.

The boundary is a moving object, not a status quo. As the child grows and the fault frequency changes, the line moves, and re-estimation is the standing cost of re-checking it. For ThakiCloud's Kubernetes platform, the paper supplies the budget criterion for how much to invest in on-call automation and how deep to hand over execution authority. In the nominal scenario, the answer is up to L2, with L3 attended.

That answer is a value to be updated by the protocol's measurements, and because it is updatable, it is usable in the budget. Quantifying the HITL boundary reduces the on-call burden while containing the blast radius of autonomous failure. In particular, the safety cap is independent of frequency. No matter how much the incident volume grows, tiers that exceed ρ are not exonerated, and only a change in the measured u_k moves the cap. The pace of 24/7 infrastructure automation cannot nullify the safety standard.

## What not to trust

First, this is an analytic paper and a stance paper. It has no new measurements at all, and every number is a closed-form evaluation of the stated nominal assumptions or a cited value. The nominal parameterization is a scenario, not an estimate, and every conclusion in this post is conditional on those assumptions.

Second, the independence assumption across the diagnosis, planning, execution, and verification stages is the strongest idealization. In the child metaphor, it assumes that one mistake does not also break the child's judgment and self-check at the same time. Reality may not be so kind. A single wrong hypothesis can produce both an incorrect action and a self-detection failure, raising U_k while lowering SR_k.

The structure of the boundary as a hole-free initial segment is directionally robust under monotone variation, but the level of k* under correlation has to come from measurement.

Third, the tiers are representative but not exhaustive. The algebra generalizes as-is to K > 3 tiers, but there is no claim that the three tiers cover the real incident distribution. Fourth, the scope is a single platform, Kubernetes. For other orchestrators there is only the claim that they map to the same tiers by the depth of resource coupling, and that mapping is not verified here.

Fifth, the cost normalization, human discrimination time, obscures currency and caching effects. The attended policy assumes that human execution of a reviewed plan is reliable, and its failure mode enters only as the residual U_k·(1-ω_k).

These limitations are themselves the questions of the follow-up work. The pre-registered protocol and the falsification zones F1 through F5 serve as the adjudicator that turns declarations into measurements. The first result will be the level of k* and the condition that binds.

---

The paper and its accompanying materials are available here: [The Autonomy Ladder dataset](https://huggingface.co/datasets/thaki-AI/daily-paper-2026-10-26-autonomy-ladder-k8s-incident-cost)

*Every number in the body is a closed-form evaluation of the stated nominal assumptions, not a measurement. The three figures are likewise outputs of the same model and are conceptual sketches.*
