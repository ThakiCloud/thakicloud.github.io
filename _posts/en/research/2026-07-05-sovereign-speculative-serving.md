---
title: "The Moment Speculative Decoding Turns Into a Loss on On-Prem Multi-Tenant GPU Clusters"
excerpt: "Every speculative decoding milestone that has topped 1,000 TPS, JetSpec included, assumes a single-tenant cluster with abundant spare compute on B200-class hardware. On an on-prem cluster where Kueue and Kubernetes co-batch multiple tenants, the same policy can actually increase latency. We introduce a paper in which the ThakiCloud research team models this gap as a function of acceptance rate, spare-compute headroom, and batching interference, and proposes SovereignSpec, a scheduler-driven policy for making that call directly."
seo_title: "Research on Scheduling Speculative Decoding for On-Prem Multi-Tenant Clusters - Thaki Cloud"
seo_description: "We introduce the SovereignSpec paper from ThakiCloud AI Research. It models the real-world speedup of speculative decoding as a function of acceptance rate, spare-compute headroom, and batching interference, and presents a scheduling policy that performs acceptance decisions, heterogeneous placement, and sovereignty-preserving co-batching on top of a Kueue plus Kubernetes stack."
date: 2026-07-05
last_modified_at: 2026-07-05
lang: en
tags:
  - research
  - llm-serving
  - speculative-decoding
  - kubernetes
  - kueue
  - gpu-scheduling
  - multi-tenancy
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "flask"
canonical_url: "https://thakicloud.com/tech-blog/en/research/sovereign-speculative-serving/"
categories:
  - research
published: false
---

## Who should read this

This piece is written for engineers who operate LLM inference serving themselves, inside or outside the company, and especially for those dealing with multi-tenant environments where several customers or models share a single GPU cluster. It assumes you already know what speculative decoding is and need to answer a practical question: will it actually pay off once we apply it to our own cluster. The short answer is that it depends on how empty your hardware really is, and that call needs to be made by the scheduler, not by the draft model.


![Concept diagram]({{ '/assets/images/sovereign-speculative-serving-diagram.svg' | relative_url }})

*Concept diagram*

## The problem: the conditions behind the success stories are not our conditions

Speculative decoding is currently the most basic tool for cutting LLM serving latency. A small, cheap draft model proposes several candidate next tokens in advance, and the target model verifies them all in a single forward pass. At the batch sizes typical of interactive workloads, the decode step is usually memory-bandwidth bound, leaving compute units idle much of the time, and verification work fills exactly that idle capacity, so accepted tokens end up far cheaper to generate than sequential generation would be. Recent progress has moved from linear drafting to tree drafting and now to parallel tree drafting, continually raising the yield of accepted tokens. JetSpec, the prior work this paper directly targets, reported throughput exceeding 1,000 tokens per second using parallel tree drafting.

The problem is that all of these speedups rest on a single assumption: that spare compute exists to absorb verification for free. A shared cluster is precisely what removes that slack. ThakiCloud operates data-sovereign on-prem clusters for regulated industries and resource-constrained organizations that cannot let prompts leave their premises. These clusters carry two characteristics at once. One is multi-tenancy, packing multiple models and customers together to make the most of expensive accelerators. The other is heterogeneity, a mix of A100s, H100s, and consumer-grade GPUs purchased at different points in time. Once a GPU is already saturated by other tenants' requests, compute units are no longer idle. In that case, the extra tokens a speculator sends to the target model for verification are not free; they are real compute, and they lengthen the forward-pass time for every request sharing that batch. A speedup observed under a single tenant can flip into added latency under multiple tenants, and worse, that added latency is an externality imposed on neighboring tenants who never asked for speculation in the first place.

## Core contribution: turning speedup into a value the scheduler can compute

The paper's first contribution is an explicit expression of the realized speedup $S_{real}$ as a function of three variables the scheduler can directly observe and control: per-token acceptance rate, spare-compute headroom, and batching interference. Modeling verification cost through these variables naturally yields the condition under which speculation stops paying off as spare-compute headroom approaches zero. Because accepted-token yield saturates past a certain point as draft length grows, while the verification cost in the denominator keeps growing in proportion to draft length, there always exists a draft length beyond which speculation turns into a loss on a saturated GPU. The optimal draft budget this derivation produces shrinks as spare-compute headroom shrinks, a value that draft-centric systems to date have never exposed to the scheduler.

Second, the model formalizes batching interference as an externality. When the verification tokens from a speculating request enlarge the batch size, the inter-token latency for other tenants sharing that same batch grows as well. In other words, this is a Pareto problem that has to weigh the gain captured by one request against the cost borne by several neighbors, not something you can solve by looking at a single request in isolation. Building on this observation, the paper lays out a two-part admission condition for deciding which requests get routed through speculation and when. First, speculation must benefit the requesting party itself. Second, the resulting externality must not exceed the service-level objective (SLO) slack of the other tenants sharing the batch.

The third contribution is SovereignSpec, an implementation of this model as a deployable policy. It consists of three cooperating policies layered on top of Kueue and Kubernetes. The first is acceptance-aware admission, which reads the real-time spare-compute headroom of candidate GPUs at every scheduling tick, applies the admission condition above, and, if the condition is not met, falls back to ordinary decoding without speculation instead of rejecting the request outright. The second is heterogeneous placement, which routes high-acceptance, latency-sensitive requests to GPUs with ample spare compute, while sending low-acceptance or throughput-oriented requests to already-saturated cards for ordinary decoding. The third is sovereignty-preserving co-batching. On-prem tenants often carry data-residency constraints that forbid sharing specific nodes or jurisdictions with other tenants, and SovereignSpec treats these constraints as hard constraints checked before speedup is even computed, so that no matter how large the projected speedup, a placement crossing a trust boundary is excluded from consideration from the start.

The regime analysis the paper presents is worth noting as well. Under idle conditions, the familiar speedup of over 2x appears, but as co-batching eats into spare-compute headroom the speedup declines monotonically, and once the system reaches saturation with a weak or excessively long draft, it drops below 1, that is, into a net loss. In this regime, an existing approach that runs speculation unconditionally pays a decode tax exceeding 20 percent while believing it is accelerating itself. The paper also shows that simply adjusting the draft budget to spare-compute headroom, without any better drafter, recovers relative gains in the 20 percent range purely from scheduling decisions, and it demonstrates numerically that, absent the externality condition, situations do arise in which accelerating one request violates the SLOs of several neighbors.

## What it means for the company, for society, and for science

For ThakiCloud, this research is a practical lever we can put directly on top of the Kueue- and Kubernetes-based serving stack we already operate. Organizations that cannot let prompts leave their premises are otherwise left with only two options: over-purchase accelerators, or break their data-residency principles and route through an external API. If speculative decoding can be kept net-positive under multi-tenant load, as SovereignSpec aims to do, the same GPUs can serve more tenants while lowering energy cost per token, giving us a concrete way to improve the economics of on-prem serving without touching the trust boundary.

Socially, this kind of scheduling improvement lets regulated industries and resource-constrained organizations serve LLMs at an affordable cost while preserving data sovereignty, without depending on large hyperscale APIs. It pushes back against the assumption that there must always be a tradeoff between data sovereignty and serving efficiency.

Scientifically, the entry point is different. Several prior measurement studies have already reported a large gap between the theory and the actual measured performance of speculative decoding. This paper names spare-compute headroom, the key variable driving that gap, as something the scheduler can act on, and redefines whether to speculate as a scheduler decision rather than a drafter decision. It fills precisely the space left open by prior work that assumed only single-tenant, homogeneous-GPU environments.

## Limitations and next steps

The paper does not hide its own limitations. This is a conceptual and analytical contribution, and no results have yet been measured on a physical cluster. Every number presented is a model prediction derived from parameters set with reference to verified acceptance rates and disaggregation measurements, not a measured value. Core parameters such as the verification-cost weight and spare-compute headroom need to be profiled per model and per GPU type, and misestimating them risks approving speculation that is actually a net loss. The batching-interference formula is also a first-order approximation that assumes a saturation regime, so the intermediate transition zone with moderate spare-compute headroom will require empirical calibration. To close this gap, the research team lays out a concrete evaluation plan: profiling parameters on A100, H100, and consumer-grade GPUs, implementing the algorithm in practice through a Kueue admission-check plugin and vLLM or SGLang scheduler hooks, and then measuring realized speedup along with P99 latency, fairness, and per-token energy consumption.

The full paper and data are available on Hugging Face. [https://huggingface.co/datasets/thaki-AI/thaki-daily-papers/tree/main/papers/2026-07-05-sovereign-speculative-serving](https://huggingface.co/datasets/thaki-AI/thaki-daily-papers/tree/main/papers/2026-07-05-sovereign-speculative-serving)

The arXiv submission pipeline has already prepared the tar package automatically, but actual upload only proceeds after human review, so the current status is submission-ready (pending approval).
