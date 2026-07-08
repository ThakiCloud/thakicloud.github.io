---
title: "Binding GPU TEE Attestation to Model Signatures: Attested Confidential Inference for Sovereign Multi-Tenant AI"
excerpt: "Hospitals, banks, and government agencies running on-premises AI platforms must prove two things to regulators: that data never leaked outside the enclave, and that the model weights actually served are the exact file that was audited. Remote attestation for GPU confidential computing and model provenance have until now evolved as two separate technologies. ThakiCloud AI Research proposes ACI (Attested Confidential Inference), a protocol that cryptographically binds the two per request and enforces the binding at the Kubernetes scheduler admission stage."
seo_title: "Binding GPU TEE Remote Attestation to Model Provenance - The ACI Protocol - Thaki Cloud"
seo_description: "This article introduces the Attested Confidential Inference (ACI) paper published by ThakiCloud AI Research. It covers a design that cryptographically binds GPU TEE remote attestation with signed model provenance records on a per-request basis and enforces it at the Kueue admission gate, so that sovereign on-premises AI platforms can prove both data confidentiality and model integrity to regulators, along with its threat model and overhead analysis."
date: 2026-07-08
last_modified_at: 2026-07-08
tags:
  - research
  - confidential-computing
  - gpu-tee
  - remote-attestation
  - model-provenance
  - multi-tenant-isolation
  - sovereign-ai
  - kubernetes-inference
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "flask"
canonical_url: "https://thakicloud.github.io/en/research/attested-confidential-sovereign-inference/"
lang: en
categories:
  - research
---

## Who Should Read This

This article is written for engineers who operate LLM inference services in on-premises or air-gapped environments, or who design AI platforms for regulated-industry customers such as hospitals, banks, and government agencies that cannot let data leave their premises. It covers what GPU confidential computing and remote attestation do and do not guarantee, and how that guarantee must be connected to the question of "which model weights actually served this request" to produce evidence a regulator will accept. It is especially relevant to organizations operating multi-tenant GPU clusters on Kubernetes and Kueue.

## The Problem: "Trust Us" Does Not Work With Regulators

The reason hospitals, government agencies, and banks want to run LLMs on their own servers is simple: to keep data from leaving the premises. But the real purpose of on-premises deployment does not stop at excluding third parties. What is increasingly demanded is a guarantee that even the company operating the platform itself cannot peek into tenant data, and cannot secretly swap out the model. The problem is that the platform operator holds root access to the cluster, controls the scheduler, and deploys the model images directly. In front of a regulated workload, "trust us" cannot serve as compliance evidence. What regulators want is not a promise, but proof.

Concretely, a sovereign platform must be able to prove two things, after the fact, to a third party that does not trust the operator, for any given inference request. The first is the data confidentiality claim: that the tenant's input values, model activations, and outputs never left the GPU confidential computing enclave in plaintext. Neither a curious operator, nor another tenant sharing the same cluster, nor a network attacker should be able to see these values. The second is the model provenance claim: that the weights that produced the output were the exact artifact that passed the organization's audit and release gate, and that no backdoor was inserted, no covert fine-tuning occurred, and no substitution with a different version took place.

Each of these two problems has solid prior work behind it, but they have developed separately. GPU TEEs on the NVIDIA Hopper and Blackwell generations provide a hardware root of trust and remote attestation that can back the first claim, and research on model provenance and supply-chain attestation can bind training and release claims to model artifacts to back the second claim. Systems that implement confidential LLM serving on top of commercial TEEs already exist. But as far as we know, no system cryptographically binds the attestation evidence chain to a signed model provenance record and enforces that binding inside a multi-tenant GPU scheduler. Remote attestation tells you where the computation happened, and provenance tells you which code and weights were released, but neither tells a regulator that "the audited weights for this request ran inside the attested enclave." That seam is exactly what is missing.

## The Core Contribution: The ACI Protocol That Binds Attestation and Provenance Per Request

ThakiCloud AI Research proposes **ACI (Attested Confidential Inference)**, a protocol that binds RATS-style remote attestation evidence to signed model provenance records and enforces that binding at the Kubernetes job admission boundary. Breaking the core idea into five logical components, there is first the **Provenance Registrar**, which signs release claims such as the digest of audited weights, the training lineage, the build environment, and scan results at release time to produce a provenance record $P$. Next is the **Attestation Broker**, acting as a RATS Verifier, which issues a fresh nonce for every request, receives and verifies evidence from the GPU/CPU TEE, and produces an attestation result $A$ containing the enclave measurement.

The point where these two meet is the paper's core object, the **Binding Ledger**. It signs the hash of $A$, the hash of $P$, the tenant identifier, and the request ID together to produce a binding record $B$, and records it in an append-only ledger. This binding is the single signed proof that "the audited weights ran inside the attested enclave." This verification is enforced at the **Kueue admission gate** before a GPU job is actually scheduled, so that without a valid binding matching the tenant identity, the GPU job is not admitted. Finally, there is a read-only **Regulator Verification API** that lets a regulator look up the entire $\{A, P, B\}$ set using only the request ID and independently re-verify the signatures and enclave measurements without relying on the operator.

![ACI protocol sequence flow](/assets/images/posts/research/attested-confidential-sovereign-inference/aci-protocol-flow.png)
*A conceptual diagram of ACI's per-request binding process. The attestation result $A$ and the provenance-verified weight digest $P$ meet at the Kueue admission gate to produce a signed binding $B$. This is an illustration of the protocol design, not measured hardware.*

There is an honest point that needs to be made here. Comparing a running digest against a signed reference value is not, by itself, a new cryptographic technique. It is the same kind of pattern as already established measured-launch approaches such as measured boot, DICE, and TPM quote-versus-golden-value comparisons, and binding signed release claims to artifacts is also something prior work already does. The contribution this paper can honestly defend is not a new cryptographic technique, but **composition**. As far as we know, this is the first work to combine GPU TEE remote attestation with signed model provenance verification into a per-request, regulator-verifiable gate enforced at scheduler admission time inside a multi-tenant Kubernetes and Kueue system.

The paper does not hide one vulnerability, and addresses it directly. There is an irreducible TOCTOU (time-of-check-to-time-of-use) gap between the moment the evidence is generated (step 3) and the moment the weights are loaded and the request is actually served (steps 4 through 6). The paper narrows this window by ordering the load and digest check after attestation and binding the two together into a single binding $B$, but it states plainly that this does not eliminate the gap entirely. It also honestly acknowledges that this gate cannot stop an operator who holds root access. If an operator bypasses the gate to process a shadow request, no valid binding $B$ is generated, and the resulting absence of a ledger entry is itself evidence a regulator can later discover by cross-referencing billing logs or API gateway request counts against the ledger. In other words, this gate is designed not as prevention that stops a malicious operator in advance, but as a detection mechanism that leaves a verifiable gap behind when bypassed.

## How Much Overhead Is There: Software Cost Measured on a Real H200 Cluster

The most honest part of this paper was its original performance claims. Because the authors did not have access to hardware with GPU TEE (CC mode) turned on, they decomposed total latency into an additive model, $L_{\text{ACI}} = L_{\text{base}} + L_{\text{TEE}} + L_{\text{att}}/N + L_{\text{ledger}}$, and filled in each term's value using only ranges cited from prior work. We subsequently revisited this model on ThakiCloud's actual demo cluster, tkai-prod-compute-h200. This cluster has four NVIDIA H200-NVL GPUs (Hopper, driver 580.65.06, CUDA 13.0) and an AMD EPYC 9335 32-core CPU, but the CC status confirmed via `nvidia-smi conf-compute -f` is OFF, and no SEV- or TDX-based confidential VMs are configured. That means $L_{\text{TEE}}$, in other words the throughput penalty of GPU confidential computing itself, still cannot be measured on this cluster. However, the new software path that ACI adds, namely the signed ledger append, provenance verification, and attestation flow, could be measured on the actual vLLM serving pipeline regardless of CC mode status.

We measured the baseline first. Serving Qwen3.6-35B-A3B with vLLM on the same H200 cluster, the average end-to-end latency per request ($L_{\text{base}}$) was 4286 ms, and average throughput was 29.9 tokens per second.

![Measured ACI software overhead](/assets/images/posts/research/attested-confidential-sovereign-inference/fig-measured-overhead.png)
*Measured overhead that the ACI software binding path adds on top of the H200 vLLM baseline (about 4286 ms per request). Even summing the signed ledger append, provenance verification, and software attestation flow, the total is about 0.01 ms per request, roughly 0.0002 percent of the baseline.*

We measured each of the items ACI adds on top of this baseline separately. The cost of appending a binding record $B$ to the signed ledger ($L_{\text{ledger}}$) averaged 0.0037 ms across 3,000 repeated measurements, of which the signing itself accounted for 0.0014 ms. The provenance side splits into two stages. Computing the SHA-256 digest of an entire 512 MB shard yielded a throughput of 2.15 GB/s, but this is a one-time cost performed once when the model is loaded and amortized over the model's entire lifetime. The per-request verification cost, on the other hand, averaged only 0.00014 ms across 20,000 measurements. Finally, the entire software attestation handshake flow averaged 0.0062 ms per request, but when amortized over the same attestation session handling 128 requests, it dropped to about 0.00005 ms per request.

![Attestation amortization](/assets/images/posts/research/attested-confidential-sovereign-inference/fig-att-amortization.png)
*How the per-request attestation cost falls as the number of requests $N$ amortizing an attestation session increases. The cost of 0.0062 ms at $N$=1 drops to 0.00005 ms at $N$=128, and to 0.000012 ms at $N$=512.*

Summing all of these items gives a clear conclusion. The entire ACI software binding path, including the signed ledger append, per-request provenance verification, and software attestation flow, adds only about 0.01 ms per request, which is about 0.0002 percent of the 4286 ms baseline, well under 0.001 percent. In practice, this is a cost negligible enough to be effectively ignored.

![Cost split](/assets/images/posts/research/attested-confidential-sovereign-inference/fig-cost-split.png)
*How the roughly 0.01 ms per-request ACI software overhead splits across ledger append, provenance verification, and the attestation flow. Computing the 512 MB shard digest is excluded from this breakdown because it is a one-time cost amortized over the model's lifetime.*

Of course, this measurement does not fill in the entire picture. The throughput penalty of GPU confidential computing itself ($L_{\text{TEE}}$) still could not be measured on this cluster because CC mode is off, and it remains an unmeasured value cited from the 4 to 8 percent range reported by prior work (chrapek2025confidential, zhu2024hopperbenchmark). Generating the hardware attestation evidence itself also still cannot be measured, since that requires a CC-mode Hopper or Blackwell environment. In other words, what this measurement narrowed down is the new software cost ACI adds, and the one remaining unknown is now confined to the cost of the GPU TEE hardware itself.

The paper argues its case against five requirements (attestation freshness, provenance binding, non-repudiation, scheduler-level isolation, and acceptable overhead), mapping each against three types of adversary (a curious operator, a malicious co-tenant, and a network attacker).

![Security requirements versus adversary matrix](/assets/images/posts/research/attested-confidential-sovereign-inference/req-adversary-matrix.png)
*A matrix mapping each of the five ACI requirements to the adversary types it addresses. The scheduler isolation requirement (R4) covers both the co-tenant and operator adversary types. This is a threat-model analysis result, not a measurement.*

## Contribution to Company, Society, and Science

For ThakiCloud, the significance of this research is clear. The Keycloak-based tenant identity, Kueue GPU admission, and ArgoCD GitOps release we already run in production already function as isolation mechanisms. Rather than adding a new isolation layer on top of these existing assets, ACI adds a single cryptographic binding that turns the multi-tenant isolation we already have into evidence a regulator can verify. This connects directly to the security and self-hosting direction targeted by the second-half 2026 release, and to the network-separation and auditability requirements demanded in Korea's public sector and financial industry.

Socially, the value of this binding lies in lowering the trust barrier. If organizations for which privacy is absolute, such as hospitals, government agencies, and the financial sector, can only use LLMs by "trusting the platform operator," adoption is bound to be slow. The fact that the attestation holds without depending on the operator's honesty substantially lowers that barrier.

Scientifically, the fact that this paper does not claim a new cryptographic technique is itself the basis for an honest contribution. As far as we know, combining GPU TEE remote attestation with signed model provenance verification, enforced per request at multi-tenant scheduler admission time, is a position prior work has not addressed. Existing research has developed attestation and provenance separately, and Kubernetes governance research has operated only at the orchestration and telemetry layer, without being rooted in hardware attestation. ACI is the first to explicitly point to the seam between them.

## Limitations: What This Paper Acknowledges About Itself

This paper does not hide where its measurements end and where citations begin. The new software binding path ACI adds, namely the signed ledger append, per-request provenance verification, and software attestation flow, was measured on a real H200 cluster (tkai-prod-compute-h200), and confirmed at about 0.01 ms per request, negligible against the baseline. However, because this cluster has CC mode turned off, the throughput penalty of GPU confidential computing itself ($L_{\text{TEE}}$) and the generation of hardware attestation evidence still could not be measured. Directly measuring these two items on Hopper or Blackwell CC mode remains future work, and the paper states plainly that this is because CC mode cannot be turned on with the cluster currently available.

Beyond that, the paper points out several unresolved issues itself. In deployments spanning multiple clusters (MultiKueue), a single cluster's binding ledger alone cannot produce a consistent cross-cluster audit view. A policy of amortizing the attestation handshake across multiple requests conflicts with situations that require discarding an enclave mid-session, such as a vulnerability disclosure. And in RAG deployments, the confidentiality claim must be extended from model weights to the context retrieved at query time as well. In addition, ACI only proves that the served weights match a signed provenance record; whether that provenance record itself describes a trustworthy model, and whether the release signing key is stored safely, remain separate supply-chain problems.

More details about the paper are available on the [HuggingFace dataset page](https://huggingface.co/datasets/thaki-AI/daily-paper-2026-07-08-attested-confidential-sovereign-inference).
