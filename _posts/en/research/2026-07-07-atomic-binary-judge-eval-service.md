---
title: "An Evaluation That Trusts No Single Number: Building a Sovereign LLM-Judge Service on Binary Decomposition and Deterministic Gates"
excerpt: "Using an LLM as a grader, the practice known as LLM-as-a-judge, is now the default in model development, but the evidence that piled up through 2026 shows that a scalar judge producing a single score is fragile to prompt wording and answer position, drifts toward the middle of the scale, and collapses to coin-flip reliability against adversarial inputs. On-prem multi-tenant clusters in hospitals, banks, and government agencies, where data can never leave the facility, add cost caps, latency caps, and auditability on top of that fragility. ThakiCloud AI Research introduces ABJ-Gate, an architecture that decomposes evaluation criteria into atomic binary questions and hands aggregation, verification, and scheduling entirely to code."
seo_title: "Binary-Decomposed LLM Judges and Sovereign Eval-as-a-Service Research - Thaki Cloud"
seo_description: "An introduction to the ABJ-Gate paper published by ThakiCloud AI Research. It covers how to decompose evaluation criteria into atomic binary questions, let deterministic code own aggregation, calibration, and audit logging, and combine adversarial verification votes, conformal risk control, and Kueue-based per-tenant cost and latency cap scheduling to build a reproducible, auditable LLM evaluation service on on-prem multi-tenant clusters."
date: 2026-07-07
last_modified_at: 2026-07-07
tags:
  - research
  - llm-as-a-judge
  - eval-as-a-service
  - model-evaluation
  - conformal-prediction
  - multi-tenancy
  - kueue
  - on-prem-llm
author_profile: true
toc: true
toc_label: "Table of Contents"
toc_icon: "flask"
categories:
  - research
lang: en
canonical_url: "https://thakicloud.github.io/en/research/atomic-binary-judge-eval-service/"
---

## Who should read this

This post is for engineers who run automated pipelines that grade LLM outputs, or who want to offer model evaluation as a service on a GPU cluster shared by multiple internal teams. It covers how fragile the approach of "asking an LLM to give a score from 1 to 10" really is, and what must be left to the model versus taken over by code to remove that fragility. It is especially relevant for organizations in regulated industries or government agencies that cannot send data outside their walls and therefore cannot rely on a frontier API judge.

## The problem: measuring quality with a single number is already breaking down

As the pace of model development and safety review has outstripped the pace at which humans can grade outputs by hand, LLM-as-a-judge, where an LLM evaluates the output of another LLM, has become essentially standard practice. But this practice rests on the assumption that a scalar value produced by one frozen model tracks the score a human would assign, and research accumulated through 2026 has dismantled that assumption piece by piece. Judge models flip their verdicts based on superficial cues such as prompt wording or where an answer sits in the input, they compress toward the middle of the grading scale and squash exactly the extreme cases that should be caught, and they are overconfident in their own verdicts while that confidence remains uncalibrated. When a red team perturbs the input even slightly, the verdict becomes no better than a coin flip. Automated bias detection tools and diagnostics based on item response theory confirm this instability at scale and in quantitative terms.

The research community's response to this problem falls broadly into two camps. One camp asks the model interpretable yes-or-no questions instead of a score; work such as BINEVAL decomposes evaluation criteria into binary questions and matches or exceeds the performance of scalar or pairwise-comparison judges, while also revealing exactly which sub-criterion failed. The other camp adds structure around the judge itself, deploying juries of multiple judges, debate, and verification units to increase the "compute the judge spends" and thereby raise robustness, or using selective evaluation cascades that route only uncertain cases forward to guarantee human-level agreement.

The trouble is that both camps are almost always validated only on offline benchmarks run on a single machine. The reality faced by organizations for which data sovereignty matters, such as hospitals, banks, and government research institutes, differs on three points. Because data cannot leave the facility, evaluation must run on a shared GPU cluster the organization owns rather than on a frontier API; because multiple teams compete for the same accelerators, the evaluation service must respect per-tenant cost and tail-latency budgets; and because compliance officers ask not "what is the score" but "why is it that score," an opaque single scalar cannot answer that question.

## Core contribution: the four disciplines ABJ-Gate binds together

Building on these three real-world constraints, ThakiCloud AI Research proposes **ABJ-Gate**, an architecture that binds the two research streams into one. Its core idea is that each evaluation criterion is broken down into an atomic binary question that a small on-prem worker model answers, while aggregating those answers, normalizing their format, calibrating them, and keeping an audit log is left entirely to deterministic code rather than to a model. Any item that falls on a contested boundary or triggers a suspicion signal is always sent to an odd number of independent skeptic workers instructed to "try to refute this" and put to a vote; the verdict survives only when the majority fails to refute it. And the budget for every one of these LLM calls is allocated by a Kueue/GPU-based scheduler within per-tenant cost and tail-latency caps.

![Sampling rate versus relative cost under the analytical cost model (Eq. 8)](/assets/images/posts/research/atomic-binary-judge-eval-service/fig1_cost_frontier.png)
*A computed result from the analytical model assuming 5 binary criteria, a 10% flag rate, and 3 skeptics. Running every item through full binary judgment (k=1) pushes cost to roughly 5.3x that of a scalar judge, but conformal calibration that reduces escalations and lowers the sampling rate k to 0.2 brings cost down to roughly 1.06x the scalar judge's cost while preserving interpretability and calibration. This is a computation from Eq. 8, not a measured benchmark.*

This design is also the promotion, into a formal product surface shared by multiple tenants, of two disciplines the company already enforces at all times in its internal harness: the principle that "code owns format, the model owns content," and the principle that fanned-out verification results must always be closed with an adversarial vote. No matter how plausibly a worker model self-reports its own answer length, count, or an "overall score out of however many points," that value is discarded and recomputed by code, so minor wobbles on the worker side cannot contaminate the final result.

The promises this architecture actually has to keep are formalized and proven as three properties. First, reproducibility: given the same set of binary answers, the aggregate score always produces the same value regardless of random seed or request order. Second, a risk-control guarantee: calibrating how often the cheap first-stage judgment and the expensive second-stage verification disagree, using conformal risk control, bounds that disagreement rate below a target level distribution-free, no matter what distribution the items are drawn from. Third, a property whereby, if an admission policy keeps each tenant's utilization below a certain threshold, queueing theory bounds that tenant's evaluation latency to a finite value.

![Conceptual diagram of tenant utilization versus expected queueing delay (Prop. 3)](/assets/images/posts/research/atomic-binary-judge-eval-service/fig2_latency_bound.png)
*An illustrative conceptual curve showing how delay spikes as utilization approaches 1 in an M/G/c queueing model. It visualizes the argument of Proposition 3, that admission control can manage tail latency by tuning the sampling rate to keep utilization under a target threshold, and is not measured latency data.*

The paper also spells out quantitatively when binary decomposition actually helps. When each criterion can be answered by a human more reliably than a scalar score and the criteria are weakly correlated so that they carry independent information from one another, binary decomposition combined with majority-vote verification is shown to produce strictly lower variance than a scalar judge. Conversely, the paper is equally clear that if the criteria are entangled with one another, or the binary questions themselves are easy to game, decomposition does not help and can even add bias.

![Conditions under which criterion decomposition reduces variance](/assets/images/posts/research/atomic-binary-judge-eval-service/fig3_variance_reduction.png)
*A conceptual diagram visualizing the analytical argument in Section 4.4 of the paper. The variance of the aggregate score decreases roughly in proportion to the per-criterion error variance divided by the number of effectively independent criteria, shown as a relative reduction trend against a baseline of the scalar judge at 1x. These are not experimentally measured figures.*

## What it leaves for the company, society, and science

From the company's perspective, this paper consolidates a binary-decomposed judge running on the company's own GPU scheduling infrastructure, a deterministic aggregation gate, and a sampling scheduler that satisfies per-tenant cost and latency caps into one complete design. It elevates an internal discipline that was already in operation into a product surface shared across multiple tenants. Socially, it opens a path for organizations in regulated industries, who could not use frontier API evaluation services because their data cannot leave the premises, to run pre-deployment safety and quality verification on their own hardware continuously, reproducibly, and auditably. That lowers the barrier to entry for trustworthy AI deployment. Scientifically, it establishes a framework for quantifying the relationship between judge reliability and cost when the idea of binary decomposition is combined with calibration, adversarial verification votes, deterministic aggregation, and cost-bounded sampling, and it presents, alongside that framework, a pre-registered protocol for validating that relationship empirically against literature from the past six months.

## Limitations

The paper is explicit about its own limitations. This work presents only the architecture, three theoretical proofs, an analytical cost model, and a pre-registered protocol for validating that frontier against human labels; it does not contain measured accuracy figures. The authors state plainly that reporting numbers without having actually run the protocol would itself be fabrication, and they have deliberately left the figures blank. Beyond that, the paper explicitly names as limitations the fact that the wording of the binary questions themselves can be gamed, that the calibration function can drift under new model families or evolving adversarial attacks, that a heuristic that only checks whether a link is alive misses more sophisticated failures such as soft 404s, and that the variance-reduction argument itself breaks down when criteria are entangled with one another. It also acknowledges that on-prem small worker models inherently perform below frontier-grade judges, so that in exchange for gaining interpretability, calibration, reproducibility, and cost bounds, the system gives up some accuracy as a standalone judge.

Full paper details are available on Hugging Face: [https://huggingface.co/datasets/thaki-AI/daily-paper-2026-07-07-atomic-binary-judge-eval-service](https://huggingface.co/datasets/thaki-AI/daily-paper-2026-07-07-atomic-binary-judge-eval-service)
