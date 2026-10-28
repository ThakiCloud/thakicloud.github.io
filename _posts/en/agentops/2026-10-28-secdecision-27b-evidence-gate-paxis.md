---
title: "When May a Security Agent Say It's Certain? SecDecision-27B V2"
excerpt: "No log entry is not the same as proof that nothing happened. SecDecision-27B V2 judges whether security evidence can support or refute a claim. We cover its held-out test, the failed V1 design, and a proposed role in Paxis."
seo_title: "SecDecision-27B V2: Evidence Sufficiency for Paxis Security Agents - ThakiCloud"
seo_description: "Thaki-SecDecision-27B V2 is a 27B LoRA-plus-head model for evidence sufficiency. On 4,002 test cases it made one false-ENOUGH decision and reached 97.23% ENOUGH recall. We explain Rule B, evaluation limits, and a proposed Paxis workflow."
date: 2026-10-28
lang: en
published: false
author_profile: true
toc: true
toc_label: "Contents"
tags:
  - secdecision
  - paxis
  - security-agent
  - evidence-sufficiency
  - claim-verification
  - qwen
  - lora
  - agentops
categories:
  - agentops
canonical_url: "https://thakicloud.com/tech-blog/en/agentops/secdecision-27b-evidence-gate-paxis/"
---

Your security agent sees no suspicious command in the collected logs. Can it conclude that the command never ran? Collection may have stopped for five minutes, or the query may have targeted the wrong host. A search hit can be relevant without supporting a conclusion.

That gap is why we built Thaki-SecDecision-27B V2. Rather than retrieve more documents or write a persuasive incident summary, it judges **whether the evidence already in hand is sufficient to conclude a particular security claim**. The model passed all pre-specified G0–G7 gates on a held-out test of 4,002 cases in October 2026. This post explains its role, why V1 failed, and where it might fit within a Paxis agent.

**Release status:** Training and held-out evaluation are complete. The Hugging Face release package is still being verified. SecDecision V2 has **not** been deployed to Paxis or Autonomous SOC production.

## Judge the evidence for a conclusion, not the search result

SecDecision takes more than a question and some retrieved documents. Its inputs describe a claim, facts required to establish it, and evidence carrying stable IDs.

Consider the claim, “PowerShell executed on host A at 14:12.”

| Evidence | What the model must distinguish |
|---|---|
| Process-execution record from host A at that time | May directly support the claim |
| PowerShell execution on another host | Related, but insufficient for this claim |
| An ATT&CK description of PowerShell abuse | A technique description, not proof of this incident |
| No PowerShell entry in a partial log window | Absence of a record is not proof of non-occurrence |
| Verified collection coverage and explicit absence within that scope | May support a refutation if all conditions are met |

The task is not a relevance score. The model must judge what each passage establishes and whether the required facts are all covered.

The four principal results are **SUPPORTED, REFUTED, INSUFFICIENT, and CONFLICTED**. The first two indicate that the claim can be supported or refuted by the evidence; they do not authorize a security action. INSUFFICIENT means the necessary evidence is missing. CONFLICTED means incompatible evidence remains unresolved.

## V1 improved F1 and became less safe

The first failure was in the training objective, not model size. V1 increased evidence-relation Macro-F1 from **0.6273 to 0.7310**, while **False-ENOUGH rose from 1.79% to 3.19%**. The model became better at a classification metric but worse at the error a security agent must avoid: declaring evidence sufficient when it is not.

The label ontology was also too coarse. Evidence about a different technique in the same ATT&CK family is not necessarily a contradiction of the claim under investigation. Treating related-but-wrong evidence as a refutation confuses two different relationships.

V2 separates a **Relation Head**, which judges individual evidence, from a **Sufficiency Head**, which judges the complete evidence set. We trained LoRA and those decision heads on a Qwen3.8-27B backbone for 3,334 steps, using about 8.8 GPU-hours.

During training, ENOUGH recall stalled near 0.48. The problem turned out not to be failure to recognize supporting evidence. The original inference rule required “zero unmet facts” for **both supporting and refuting conclusions**. It systematically blocked valid refutations. On the calibration split, support-direction recall was 0.970 while refutation-direction recall was only 0.003.

**Rule B** corrected that mismatch. A supported conclusion still requires the supporting facts to be satisfied. A refutation instead requires explicit counterevidence or verified complete-coverage evidence. Unresolved conflicts still block conclusions. We documented the rule amendment **before opening TEST** and kept the weights, checkpoint, and threshold fixed.

## What the 4,002-case TEST established

The selected configuration is **ckpt-02200 + Rule B + a frozen threshold**. We opened the 4,002-case TEST once after fixing the evaluation contract; all G0–G7 gates passed.

| Metric | SecDecision V2 | Frozen zero-shot Stock |
|---|---:|---:|
| False-ENOUGH | **1/2,668 (0.04%)** | 202/2,668 (7.57%) |
| ENOUGH recall | **1,297/1,334 (97.23%)** | 390/1,334 (29.24%) |
| FULL recall | **94.60%** | 5.55% |
| REFUTE_COVERAGE recall | **99.85%** | 52.92% |
| ADJACENT False-ENOUGH | **0%** | 7.2% |
| Evidence-relation Macro-F1 | **0.9634** | No matched head metric |
| Pairwise accuracy | **0.9975** | No matched head metric |

V2's only false-ENOUGH decision occurred in the PARTIAL variant. There were none in ADJACENT, ABSENT, or CONFLICT, and the model returned no evidence IDs absent from its inputs. A separate split holding out claim families and log formats reported zero false-ENOUGH decisions and 95.67% ENOUGH recall.

**The Stock comparison needs a prominent qualification.** Stock had **3,370 parse errors in 4,002 cases (83.96%)**. Some outputs were empty; others exhausted the 64-token budget on reasoning text before emitting JSON. These are the results of a **fixed zero-shot evaluation contract**, not evidence that V2 would beat a carefully configured Stock model by the reported margin. V2's own false-ENOUGH and recall results, and its pass on the frozen gates, are separate observations.

Nor is this a live SOC evaluation. Held-out splits do not cover every customer log schema, telemetry gap, or adversarial evidence injection. SecDecision is neither a standalone intrusion detector nor an automated containment system.

## Where SecDecision could fit in Paxis

A future Paxis integration need not replace the agent's general LLM. It could place a **claim-evidence sufficiency check** after retrieval and tool execution, just before an answer is finalized.

~~~mermaid
flowchart TD
  A["Paxis security investigation"] --> B["Read-only retrieval and tools<br/>logs, documents, code evidence"]
  B --> C["Build claim + evidence IDs"]
  C --> D["SecDecision-27B V2<br/>evidence relations and sufficiency"]
  D -->|"SUPPORTED / REFUTED"| E["Draft a cited assessment"]
  D -->|"INSUFFICIENT"| F["Retrieve more or ask for review"]
  D -->|"CONFLICTED"| G["Mark conflict and escalate"]
  E --> H["Paxis policy and audit trail"]
  F --> H
  G --> H
  H --> I["Separate approval for any mutation"]
~~~

*This is an integration proposal, not a completed Paxis deployment or measured Paxis performance.*

The distinction also matters in code security review. [SecProof](https://thakicloud.com/tech-blog/en/agentops/secproof-2b-paxis-security-agent/) can identify a possible tenant-isolation or tool-approval flaw and point to a code location. SecDecision could then assess whether the code excerpts and reproduction results **actually justify that finding**. Sandbox tests and approval policies remain outside both models.

For example, a SecProof finding may be plausible but lack the request-path code or the reproducing test needed to confirm it. An INSUFFICIENT decision can tell the agent to collect those artifacts rather than declare a confirmed vulnerability. A SUPPORTED decision still does not grant permission to patch code or execute an external action.

The same separation applies to document RAG. Retrieval and models such as [CiteRank](https://thakicloud.com/tech-blog/en/agentops/citerank-4b-paxis/) help choose **which documents to inspect first**. SecDecision asks **whether those documents, taken together, justify the particular claim**. Ranking and sufficiency are different tasks.

## The boundary worth keeping

An evidence decision should remain auditable. A future Paxis workflow should retain the original evidence IDs, claim, model and rule versions, threshold, and final status, making a withheld answer explainable later.

Refutation deserves particular care. “Not found in the logs” must not silently become “did not happen.” Collection scope and completeness need independent evidence. A high model score is not an operational guarantee, and a threshold frozen for this TEST does not promise the same risk on new customer data.

We did not build SecDecision V2 to make security agents sound more confident. We built it to give them a separate place to decide **when the evidence is not good enough to conclude**. Real Paxis integration remains future work; releasing the model with its measured limits comes first.

*Model: Thaki-SecDecision-27B V2. A verified Hugging Face model-card link will be added after the release is publicly accessible.*
