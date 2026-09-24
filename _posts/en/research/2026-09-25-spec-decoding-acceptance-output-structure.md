---
title: "The Draft Law: Agentic Output Structure Sets the Speculative-Decoding Acceptance Rate and Net Per-Token Cost"
seo_title: "The Draft Law paper analysis - the structural law for self-hosted H200 agent serving that the variable deciding speculative-decoding acceptance rate and net per-token cost is output structure, not the workload. An agent turn decomposes into position classes of schema-constrained tool calls (S), extended reasoning (R), and free-form prose (F); the per-class normalized predictability ρ_c=e^(-H_c) and the draft alignment constant κ give the mixture mismatch ε̄=κ(1-ρ̄). The mean structural predictability ρ̄=w_Sρ_S+w_Rρ_R+w_Fρ_F fixes the geometric series of the expected accepted prefix length τ(γ) in closed form, and τ and the net saving fraction s increase strictly with the schema fraction w_S. The net per-token cost c_net(γ,τ)=c_T(1+γ(δ+d))/(τ+1) carries the draft overhead d=(1/8)η, and the first-order break-even ε*=2(1-δ-d)/(γ+1) and the unique break-even schema fraction w_S*=(ρ*-ρ_n)/(ρ_S-ρ_n) follow. At the schema ceiling the net speedup u saturates at (γ+1)/(1+γ(δ+d)), and at the entropy floor s is a net loss of -γ(δ+d). The decode-axis speculation lever composes orthogonally with the prefix-reuse and validation-gate levers into C_total=ν[(1-h+hc_hit)C_pre+(c_net/c_1)C_dec]. It declares a single H200 (141GB) vLLM platform with a 32B BF16 target-4B BF16 draft, pre-registers the four-arm A-D protocol with falsification criteria R1-R4, and promotes Medusa's workload-agnostic throughput gain to the structure-versus-net-cost axis for agent traffic. All numbers are closed-form interpretation-model predictions, not measurements - ThakiCloud"
seo_description: "The variable that sets the speculative-decoding acceptance rate is not the workload name but the structure of the agent output. Grammar pruning at schema-constrained tool-call positions lowers the next-token entropy, and that structural predictability fixes the expected accepted prefix length in closed form (the Draft Law). The break-even schema fraction w_S* comes out of the net per-token cost with the draft model's own serving cost removed. Turn it on where the schema fraction exceeds that value, and off where free-form prose dominates the traffic: that is the operator rule. All numbers are interpretation-model predictions under stated assumptions, and the pre-registered four-arm protocol with falsification criteria R1-R4 is the path to measurement."
excerpt: "Whether to turn speculative decoding on is decided by how tightly the output is bound to a schema. This paper derives in closed form the structural law that sets the acceptance rate in agent traffic, the Draft Law, and gives the net saving fraction with the draft model's cost removed and the break-even schema fraction. The operator rule: turn it on where the schema fraction crosses the threshold, and off where prose dominates."
date: 2026-09-25
tags:
  - speculative-decoding
  - draft-model
  - acceptance-rate
  - agentic-workload
  - tool-calling
  - output-structure
  - h200-serving
  - inference-cost-optimization
  - token-factory
  - self-hosted-inference
categories:
  - research
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/en/research/spec-decoding-acceptance-output-structure/"
audiobook: "https://drive.google.com/file/d/14SIhX0DhCOIXX4ons-Xk4li0GAItaZC_/view"
audiobook_label: "▶ Listen: 5-minute briefing"
audiobook_note: "NotebookLM audio overview (AI-generated)"
---

If you serve agent workloads on self-hosted GPUs, or you are the engineer who answers for that serving bill, this post is today's work. This paper is a law about what decides whether to turn speculative decoding on and, once on, how much the net per-token cost drops: it is output structure, not the workload name, that decides. The larger the fraction of schema-bound tool calls, the higher the acceptance rate, and the net saving fraction with the draft model's own cost removed and the break-even point both come out in closed form. This is an analytical paper, and every number is a model prediction derived under stated assumptions. The four-arm protocol and the falsification criteria that lead to measurement are written down alongside.

![Illustration of the core idea of The Draft Law: Agentic Output Structure Sets the Speculative-Decoding Acceptance Rate and Net Per-Token Cost](/assets/images/spec-decoding-acceptance-output-structure-hero.webp)
*A visual metaphor for the article's key idea.*

## Two Open Questions: Why Agent Traffic

Agent inference is the dominant regime of LLM serving today. A tool call is drawn on a JSON grammar built over known tool names, keys, enumerated values, and formatted argument values, which makes it different from free-form prose. This grammar pruning concentrates the next-token distribution at schema positions and lowers the mean next-token entropy. There is already direct evidence that the structure is predictable. The SPORK study reports that a detector forked at the start of generation predicts the next tool name at 74.6 to 99.6 percent accuracy across five benchmarks.

Speculative decoding is the standard lossless decode-side lever. A small draft model proposes candidate tokens ahead, and the large target model verifies them in a single parallel pass. The modified rejection procedure preserves the target distribution, so output quality is unchanged. Medusa removed the separate draft model with parallel decoding heads and tree attention, reporting lossless throughput gains of over 2.2x, and 2.3 to 3.6x with joint fine-tuning. But those numbers were measured on general workloads, and they are gross throughput that does not subtract the draft-side overhead. They also leave acceptance rate by output structure unsolved.

It is precisely in agent traffic, where speculation should pay off the most, that two questions remain open. First, does the output structure of a request measurably determine the speculative-decoding acceptance rate? Second, once the draft model's own serving cost is included, how large is the net per-token saving at the same quality as a comparison BF16 baseline? This paper answers both in closed form.

<!-- nlm-visual -->
![Key-concept summary infographic 1](/assets/images/posts/news/spec-decoding-acceptance-output-structure/en/nlm-infographic-1.webp)
*Infographic generated by NotebookLM from the sources.*

## The Draft Law: The Variable That Sets Acceptance Rate Is Output Structure

The output of an agent turn is decomposed into three position classes. S is the schema-constrained tool-call positions, R the extended-reasoning positions, and F the free-form prose positions. The class mass fractions w_S, w_R, and w_F sum to 1. Each class is assigned a normalized predictability ρ_c. This is the exponential of the class-mean next-token entropy H_c (in nats), ρ_c=e^(-H_c), giving 1 for a deterministic position and 1/V for a uniform one. Grammar pruning shrinks the set of allowed tokens, so predictability orders as ρ_S≫ρ_R≥ρ_F.

Introduce a draft alignment constant κ and set the per-position mismatch probability to ε_i=κ(1-ρ_i). In the class-mixture mean mismatch ε̄=κ(1-ρ̄), ρ̄=w_Sρ_S+w_Rρ_R+w_Fρ_F is the mean structural predictability. The Draft Law connects the two. The expected accepted prefix length τ(γ) is the sum of the geometric series Σ_{i=1}^{γ}(1-ε̄)^i, and if ρ_S>ρ̄ then both τ and the net saving fraction s increase strictly with the schema fraction w_S.

Two limits shape the law. At the schema ceiling, w_S goes to 1 and ρ_S goes to 1, τ reaches γ, and the net speedup saturates at (γ+1)/(1+γ(δ+d)). At the entropy floor, with w_S=0 and the draft completely misaligned, τ falls to 0 and s turns negative at -γ(δ+d). In that region speculation itself is a net loss. In between, a marginal value for schema positions comes out. Moving mass dw from prose into schema raises τ by roughly γ(γ+1)/2·κ(ρ_S-ρ_F)dw, which is the closed-form marginal acceptance value of schema positions.

A prediction P1 about the ordering of the three classes also comes out. Since grammar pruning concentrates the distribution at schema positions, the expected accepted prefix length is predicted to order as tool-call, reasoning, then prose positions, with τ_S/τ_F exceeding 1.5.

![Predicted accepted-prefix length by output position class (P1 ordering)](/assets/images/posts/research/spec-decoding-acceptance-output-structure/fig2-class-ordering.webp)
*Expected accepted prefix length by class, as predicted. Grammar pruning concentrates the next-token distribution at schema positions, so the length is predicted to order as tool-call, reasoning, then prose positions (P1). An interpretation-model prediction, not a measurement.*

In plain terms, what sets the acceptance rate is how tightly the output is bound into a predictable structure: the schema fraction. The task name is not the variable. And the schema fraction is a lever the operator can hold directly, through task design, schema density, and tool granularity.

## Net Per-Token Cost and Break-Even

The net cost must include the draft's share. One target decode pass c_T is memory-bandwidth bound, and the cost of verifying γ+1 candidate tokens in one pass is c_T(1+δγ), where δ is the verification overhead per extra token (δ≪1). One draft forward pass is d·c_T per token, with d the parameter ratio (1/8) times the draft bandwidth utilization η. Each speculation round emits τ+1 tokens.

The net per-token cost is c_net(γ,τ)=c_T(1+γ(δ+d))/(τ+1), and the saving fraction s is 1-(1+γ(δ+d))/(τ+1). In the small-ε̄ regime the condition for s to be positive simplifies to ε̄<ε*=2(1-δ-d)/(γ+1). Inverting, the unique break-even schema fraction is w_S*=(ρ*-ρ_n)/(ρ_S-ρ_n), where ρ*=1-ε*/κ, and if w_S is below w_S* speculation is a net loss.

Compressed into an operator rule, it is two lines. Turn speculation on where the schema fraction exceeds w_S*, and off where free-form prose dominates the traffic. The decision rests not on the gross throughput number but on the net profit with the draft cost subtracted, together with the guarantee that quality is preserved.

![Net per-token saving fraction versus schema-constrained fraction (draft-law shape)](/assets/images/posts/research/spec-decoding-acceptance-output-structure/fig1-draft-law-shape.webp)
*Net saving fraction versus the schema-constrained fraction. Below the break-even schema fraction it is a net loss; it crosses 0 at the unique break-even point and saturates as it approaches the schema ceiling. An interpretation-model curve, not a measurement.*

This lever does not overlap the other levers of the serving stack. The cost of an agent turn accrues as the sum of a prefix cost C_pre and a decode cost C_dec; prefix-cache reuse acts multiplicatively on C_pre only, and speculation on C_dec only. Validation-gate resampling puts an expected number of draws ν on accepted turns along the retry axis. The three compose multiplicatively on distinct cost components, and the quality-regression budget is additive. Speculation's quality contribution is 0, that is, exact target verification. C_total=ν[(1-h+h·c_hit)C_pre+(c_net/c_1)C_dec] is that composition.

## What It Leaves for ThakiCloud, Society, and Science

For ThakiCloud, a new cost lever is born for the token factory. The structure-wise determination of acceptance rate and the net per-token cost compose multiplicatively with the existing axes measured through prefix reuse and the validation gate, at zero quality regression. The operator makes cost decisions that preserve quality, not gross-throughput numbers.

For society, it lowers the energy and monetary cost of inference at fixed quality. The cost barrier for a small team running unattended agent automation goes down by the same amount.

Scientifically, it is a new empirical law connecting output structure to the speculative-decoding acceptance rate. The relation in which schema constraint and next-token entropy set the acceptance rate is an axis invisible in Medusa's general throughput measurements. It is an explicit upgrade over Medusa on two axes: output structure is the determining variable of the acceptance rate, and the net cost with the draft cost removed carries a break-even condition.

The path to measurement is already set. The platform is declared before measuring: a single H200 (141GB HBM3e) running vLLM with a 32B BF16 target and a same-family 4B BF16 draft. Arm A is the free-form prose control arm, calibrating the alignment constant κ and the overheads δ, d, and the baseline c_1. Arm B is BFCL-style schema-constrained tool calls (temperature 0), arm C long chain reasoning, and arm D mixed traffic from unattended agent loop replay. Depths are γ=4, 8, 16, and batches b=1 (latency) and b=8 (throughput).

Falsification criteria R1 through R4 are also pre-registered. If τ_S≤τ_F the Draft Law is rejected; if s<0 at w_S≥0.6 the break-even model is rejected. If the composition residual exceeds 15 percent the orthogonal-composition claim is rejected, and a single bit mismatch at temperature 0 rejects the lossless claim. It is designed so that hitting a criterion collapses the conclusion with it.

<!-- nlm-visual -->
![Key-concept summary infographic 2](/assets/images/posts/news/spec-decoding-acceptance-output-structure/en/nlm-infographic-2.webp)
*Infographic generated by NotebookLM from the sources.*

## What Not to Believe

This is an analytical study and it reports no measurements at all. Every number is a closed-form value derived from declared parameters.

First, the independent-draw assumption within a class. Acceptance at positions inside a class is treated as i.i.d., but long structured spans carry predictability autocorrelation, so the geometric chain is an approximation. On the error side, the actual τ on such spans is not smaller than the i.i.d. value, so the model sits on the conservative side for structured spans.

Second, the alignment constant κ. κ depends on the draft-target pair and the workload. A narrowly trained draft model collapses in acceptance under workload shift, and acceptance-length-aware learning changes it directly. It is the quantity most in need of direct measurement on the declared platform.

Third, the precision axis is out of scope. Precision is fixed at BF16, and the precision axis is handled by prior work on draft-target precision mismatch. The union of the two orthogonal axes is the joint frontier. Fourth, the decode cost model assumes the memory-bandwidth bound of small batches. The effect of the batch axis enters the protocol only in the b=8 regime. For a mixture-of-experts (MoE) target, expert transfer through the number of verification tokens changes d.

Cases where it should not be turned on are also explicit: free-form-heavy traffic with w_S below w_S*, quantized MoE targets with precision mismatch, and edge-cloud split. For the split, it means only co-resident speculation pays, and a distributed split pays almost nothing.

The paper detail page is available here: [The Draft Law: Measuring How Agentic Output Structure Sets Speculative-Decoding Acceptance and Net Per-Token Cost on Self-Hosted H200](https://huggingface.co/datasets/thaki-AI/daily-paper-2026-09-25-spec-decoding-acceptance-output-structure)

*Both figures in this post are interpretation-model curves and contain no measurements.*
