---
title: "Three Models for ATT&CK Technique Retrieval, Evidence Gating and Edge Skill Search, With the Gates We Did Not Pass"
excerpt: "A security embedding that retrieves MITRE ATT&CK documentation, an evidence gate that decides whether RAG should answer or stop, and a skill-search embedding that runs on CPU. Two of the three did not clear the bar we wrote down before training, and the cards say by how much."
seo_title: "Thaki-SecEmbed-8B, ECP-SB-27B and SKILLRET-Edge-305M released - ThakiCloud"
seo_description: "ThakiCloud released three models. Thaki-SecEmbed-8B, evaluated only on MITRE ATT&CK technique retrieval, showed no clear difference from its base model on the preregistered set and +0.1447 nDCG@10 over its base on a post-release independent-teacher benchmark that was not binding on release. ECP-SB-27B missed its 5% unsupported-answer target at 6.5%. SKILLRET-Edge-305M passed its gates and answers in 47.7ms on CPU."
date: 2026-10-25
last_modified_at: 2026-11-01
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cube"
tags:
  - security
  - mitre-attack
  - embedding
  - retrieval
  - rag
  - evidence-gate
  - abstention
  - skill-retrieval
  - onnx
  - cpu
  - open-weight
  - paxis
categories:
  - owm
canonical_url: "https://thakicloud.com/tech-blog/en/owm/preregistered-gates-three-models-open/"
header:
  teaser: /assets/images/secembed-two-verdicts-en.webp
---

This post is for teams that have to search MITRE ATT&CK technique documentation inside a closed network, stop a RAG system from answering without evidence, or pick an agent skill on a CPU box. The three models released here each take one of those jobs.

One thing first. Two of the three did not clear the bar we wrote down before training started. ThakiCloud did not delete that result. It sits at the top of each model card, and the model shipped anyway. Read the numbers below and decide for yourself whether to use them.

## The short version

A student's score depends on who writes the exam. Set the paper from the workbook used in class, and the students from that class do well. Have a teacher from another school write it, and the result is more honest.

Model evaluation works the same way. If the generator that produced the training queries also produces the test queries, a higher score is hard to read as a better model. So ThakiCloud writes the release bar down before training and does not move it after the results arrive. Of these three models, one cleared that bar and two did not.

## Where each model sits

```mermaid
flowchart TB
    Q["Analyst query<br/>Korean or English"] --> SE["Thaki-SecEmbed-8B<br/>ATT&CK technique retrieval<br/>(only corpus evaluated)"]
    SE --> G[ECP-SB-27B<br/>evidence gate<br/>answer · retrieve more · abstain]
    G --> A["Generated answer"]
    AG[Agent task request] --> SK[SKILLRET-Edge-305M<br/>skill retrieval on CPU]
    SK --> AG
```

The left branch is the path a security question travels. The embedding pulls the relevant ATT&CK technique documents, and the gate decides whether that evidence is enough to answer at all. ATT&CK technique documents are the only corpus SecEmbed was evaluated on. CTI reports, logs and telemetry, detection rules and vulnerability databases were not evaluated, so other documents in a real security pipeline need a retriever that was measured on them. The right branch is an agent choosing which of thousands of skills to run, and it needs no GPU.

## One adapter, two verdicts

Thaki-SecEmbed-8B-Preview is a LoRA adapter on Qwen3-Embedding-8B that retrieves MITRE ATT&CK technique documentation. Training used public MITRE ATT&CK STIX data only (Enterprise ATT&CK v19.2), with no internal or customer data. The card evaluates one task only: ranking ATT&CK technique documents for analyst-style queries in English and Korean. Nothing below is a measurement of general security retrieval.

![One adapter, two verdicts](/assets/images/secembed-two-verdicts-en.webp)

The release decision rests on the left pair. On a 583-query preregistered held-out set, nDCG@10 was 0.686 against the base model's 0.670, a difference of +0.016 with a 95% confidence interval of [-0.010, +0.043] that includes zero. On the same set, Recall@10 was 0.859, against 0.842 for the base and 0.427 for BM25. That set is narrow. It covers 17 parent techniques, and its queries come from the same generator and distribution as the training queries, so it measures in-distribution ATT&CK technique retrieval, not real analyst traffic. The verdict was no clear difference, and we claim no improvement. Three independently trained seeds landed between 0.676 and 0.705, a spread about as wide as the released adapter's distance from its base. That is why the claim was dropped. Two query styles an evidence-seeking agent relies on had negative point estimates against the base, analyst_search at -0.035 and evidence_request at -0.018. Neither is a significant regression.

The right pair was measured after release. Blind-B is a 2,025-query benchmark whose queries were written by teacher models other than the one used in training, and whose answers are decided in code by ATT&CK STIX relations. It covers 966 source anchors. There the gap was 0.694 against 0.550, a paired difference of +0.1447 with a 95% confidence interval of +0.129 to +0.161 (anchor-cluster bootstrap), and the direction was the same in English and Korean. Nemotron-3-Embed-8B scored 0.587 on Blind-B. The confidence intervals were computed against the base model only, so the card makes no claim of a clear advantage over Nemotron. The two readings are not a contradiction but two sides of one story. Questions written by the training generator did not separate the models. Questions written independently did. Since this run came after the release decision, it does not overturn the preregistered verdict. Blind-B is still ATT&CK technique retrieval, so it widens the evidence within that one task and says nothing about other security corpora.

There is a cost as well. General retrieval was checked on four public sets, each judged on its own.

| Set | Base nDCG@10 | SecEmbed nDCG@10 | Δ [95% CI] | Relative |
|---|---|---|---|---|
| SciFact | 0.784 | 0.797 | +0.013 [+0.001, +0.026] | +1.7% |
| NFCorpus | 0.409 | 0.417 | +0.008 [+0.001, +0.015] | +2.0% |
| FiQA-2018 | 0.650 | 0.610 | -0.040 [-0.052, -0.029] | -6.2% |
| MIRACL (ko) | 0.667 | 0.674 | +0.006 [-0.008, +0.023] | +1.0% |

FiQA-2018, a financial question-answering set, is the one that moved the wrong way. The drop is short of the 10% catastrophic threshold we preregistered, but it is statistically clear. For financial documents, prefer the base model. Korean retrieval on MIRACL showed no clear change. Passing four sets is not evidence that general capability is preserved.

## We wrote down that the gate is not a safety control

ECP-SB-27B-Research is a package that loads Qwen3.8-27B once on a single H200 and serves two APIs from it. One is ordinary generation. The other is an evidence gate that decides, after retrieval and before generation, whether to answer, retrieve more, or abstain. The base weights are not copied here. The repository holds four seeds of LoRA weights, the action and sufficiency heads, and each seed's sealed threshold.

The deployment check passed. Measured against unmodified vLLM serving the same base model under identical flags, generation-only traffic stayed inside the bound, and 256 gate decisions under mixed traffic matched the offline reference exactly. The p99 logprob criterion, though, passed by a margin of 0.00000286. A pass is a pass, but there was no room in it, which is why the card does not claim that generation under mixed traffic is identical to the base model. Six of 64 prompts differed, and the cause was not attributed.

The bar that was missed is a different one. The pooled unsupported-answer rate was 6.5% where the target was 5%, and it ranged from 0.047 to 0.093 across seeds. So the card says not to use this gate as a safety control. It is a research deployment, not a production certification.

| Check | Result |
|---|---|
| Base weights loaded once, single GPU process | Pass |
| Generation API and gate API both answer | Pass |
| Gate decisions under mixed traffic, 256 items | Pass, 0 changed |
| Generation under mixed traffic identical to base | Not shown, 6 of 64 differ |
| Production safety | Not certified, 6.5% against a 5% target |

## The one that passed runs on CPU

SKILLRET-Edge-Arctic-305M is a 305M embedding model that retrieves agent skills. It is distilled from an 8B teacher and runs on CPU as ONNX FP32. The preregistered gate asked it to hold English quality while raising Korean, and it cleared both. On the public test split, English nDCG@10 was 1.07 points above the 0.6B reference, and Korean was 11.99 points above the low-bit comparator.

What decides where you can put it is latency and memory rather than quality.

| Host | Threads | This model, ORT FP32 p50 | Peak RSS | 0.6B Q4_1 on llama-server p50 | Peak RSS |
|---|---|---|---|---|---|
| AMD EPYC 9355 | 1 | 133.8 ms | 2.0 GB | 1,973 ms | 3.58 GB |
| AMD EPYC 9355 | 4 | 47.7 ms | 2.1 GB | 582 ms | 3.58 GB |
| Apple M4 Pro | 1 | 36.0 ms | 3.0 GB | 2,073 ms | 3.58 GB |

This table compares two serving configurations, not two sets of weights. The right-hand side is an HTTP server holding 16 slots, so most of that memory is KV and compute buffers. It does not show that the quantization method is slow. Also, there is no INT8 build. Dynamic INT8 and static QDQ INT8 both failed the quality gate, so only FP32 ships. The ONNX file is 1.23 GB, which makes this a fast CPU retrieval model rather than a phone-sized one.

## What to know before serving

SecEmbed is an adapter, so it loads alongside the base model: Qwen/Qwen3-Embedding-8B at revision `1d8ad4ca9b3dd8059ad90a75d4983776a23d44af`. From tag `v0.0.1`, `adapter_config.json` names that base and revision, so PEFT auto-loading works. On `v0.0.0` the config points at a local training path, so load the base explicitly. The primary dimension is 4096. Truncated dimensions (1024, 512, 256) were not trained with MRL. The card reports them only as diagnostics in its [Dimensions table](https://huggingface.co/ThakiCloud/Thaki-SecEmbed-8B-Preview#dimensions). The model was trained on Enterprise ATT&CK v19.2, so techniques added, renamed or deprecated later are not reflected, and an ATT&CK upgrade means rebuilding the index and checking retrieval again. ECP-SB was verified on vLLM 0.28.0 only. The 0.31 port is planned and unverified, and the gate branch runs for every scheduled token, so it is not free. SKILLRET-Edge is the simplest of the three. Prefix queries with `query: `, call it through ONNX Runtime, and read the output, which the graph has already L2-normalized.

The SecEmbed card's usage, condensed. Only the query gets an instruction, documents are embedded as raw text, and pooling is the last token with left padding followed by L2 normalization.

```python
import torch
import torch.nn.functional as F
from peft import PeftModel
from transformers import AutoModel, AutoTokenizer

INSTRUCTION = ("Given a security analyst query, retrieve documentation of the adversary "
               "technique or tactic it describes.")

BASE, REV = "Qwen/Qwen3-Embedding-8B", "1d8ad4ca9b3dd8059ad90a75d4983776a23d44af"
tok = AutoTokenizer.from_pretrained(BASE, revision=REV, padding_side="left")
base = AutoModel.from_pretrained(BASE, revision=REV, torch_dtype=torch.bfloat16)
model = PeftModel.from_pretrained(base, "ThakiCloud/Thaki-SecEmbed-8B-Preview").eval()

def embed(texts, max_len):
    enc = tok(texts, padding=True, truncation=True, max_length=max_len, return_tensors="pt")
    with torch.no_grad():
        h = model(**enc).last_hidden_state[:, -1]          # last token (left padding)
    return F.normalize(h.float(), p=2, dim=-1)

q = embed([f"Instruct: {INSTRUCTION}\nQuery: {x}" for x in ["Can malware download files from the C2?"]], 512)
d = embed(["<ATT&CK technique document text>"], 2048)     # documents: raw text, no instruction
scores = q @ d.T
```

All three models are Apache-2.0. Training data terms differ by model. SecEmbed's training data is derived from MITRE ATT&CK, which is used under the [ATT&CK Terms of Use](https://attack.mitre.org/resources/legal-and-branding/terms-of-use/). Those terms are not an open-source license, and the SecEmbed repository does not redistribute ATT&CK content. Check the other two models' data terms in their own cards. The weight license is what lets the models go into a closed network as they are, and the ATT&CK Terms of Use still apply to the ATT&CK content you index.

## Why publish the misses

The first question security and finance customers ask is not how good the number is but who measured it and how. Publishing only the passes leaves that question unanswered. Writing the bar first and refusing to move it afterwards buys fewer bragging lines, and the numbers last longer.

Paxis, ThakiCloud's enterprise agent platform, runs every agent action through a policy gate and an audit log. A judgment that stops when evidence is thin belongs at the front of that structure, and a skill retriever belongs where thousands of skills are narrowed to the one to run now. None of these three models ships inside a product yet. For SecEmbed specifically, nothing is integrated into Paxis or Metis, ThakiCloud's inference and serving layer, and no serving latency or throughput has been published. A possible later setup, not built or measured, would serve it as its own embedding endpoint next to the generator, pinned to the base revision above and to the adapter's sha256 (`e49c221ae93b931b93d4616aedd8808dc95e9ee4271d63f55e79b104656f5933`), so an audit record can name the exact retriever that chose the evidence. The third one answering in 47.7ms on CPU matters most for on-premises and air-gapped deployments, where the skill-selection step can run without a single GPU.

## What gets measured next

For ECP-SB, the vLLM 0.31 port comes with reusing the forward pass so a shared prefix is not computed twice. The unsupported-answer rate will be measured again in a separate independent evaluation. A missed target gets a newer measurement, not an edited old one.

For SKILLRET-Edge, the next steps are multilingual coverage and smaller students. A 22M student compressed to 22.7MB in INT8 is the current target, and a post-training quantization comparison across four embedder families is being written up as a paper.

SecEmbed stays a Preview. Blind-B has now been used once, so it serves as a regression benchmark rather than a blind set. The next verdict needs a new blind set, and reducing the FiQA regression is the homework before that.

## What was released

| Repository | Format | Status |
|---|---|---|
| [ThakiCloud/Thaki-SecEmbed-8B-Preview](https://huggingface.co/ThakiCloud/Thaki-SecEmbed-8B-Preview) | LoRA adapter | Preview, ATT&CK technique retrieval only, preregistered verdict is no clear difference; FiQA-2018 -0.040 |
| [ThakiCloud/ECP-SB-27B-Research](https://huggingface.co/ThakiCloud/ECP-SB-27B-Research) | Seed weights and manifest | Research deployment, not production certified |
| [ThakiCloud/SKILLRET-Edge-Arctic-305M](https://huggingface.co/ThakiCloud/SKILLRET-Edge-Arctic-305M) | ONNX FP32 and PyTorch | Passed its preregistered gates |

Write the evaluation down first and read the result second, and good news and bad news end up weighing the same. What this release was meant to protect is that order, not the three scores.

SecEmbed's Korean model card is at [MODEL_CARD.ko.md](https://huggingface.co/ThakiCloud/Thaki-SecEmbed-8B-Preview/blob/main/MODEL_CARD.ko.md).

*Measurement sources: the evaluation tables published in each model's Hugging Face card. The ECP-SB deployment check ran on one H200-NVL with vLLM 0.28.0, and the SKILLRET-Edge CPU numbers were measured on an AMD EPYC 9355 and an Apple M4 Pro.*

*MITRE ATT&CK® is a registered trademark of The MITRE Corporation. Thaki-SecEmbed-8B is not affiliated with, sponsored by, or endorsed by The MITRE Corporation.*

## Update log

**2026-11-01, corrections concerning Thaki-SecEmbed-8B-Preview only.** The ECP-SB-27B and SKILLRET-Edge sections are unchanged.

- Data terms: the post said every external training dataset carries a public licence. SecEmbed's data is MITRE ATT&CK, used under the ATT&CK Terms of Use, which is not an open-source license, and the repository does not redistribute ATT&CK content. The MITRE ATT&CK® trademark notice was added.
- Base model: added the pinned base revision `1d8ad4ca9b3dd8059ad90a75d4983776a23d44af` and the `v0.0.0` / `v0.0.1` loading difference.
- Evaluation scope: the title, opening, diagram and text now say SecEmbed was evaluated on ATT&CK technique retrieval only. CTI reports, logs and telemetry, detection rules and vulnerability databases were not evaluated.
- Numbers added from the card: the held-out confidence interval and Recall@10 (0.859, measured on the 583-query ATT&CK held-out set), the narrow 17-technique scope, the Blind-B confidence interval and the Nemotron caveat, the negative point estimates for two query styles, and all four retention sets including MIRACL (ko).
- Added a short usage section from the card, and the ATT&CK v19.2 version note.
- Separated what is integrated today (nothing in Paxis or Metis) from a possible later serving setup.
- Added a link to the Korean model card.
