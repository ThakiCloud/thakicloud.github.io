---
title: "From a General Model to a Money-Transfer Model: Building Thaki-IntentAction-Finance-KO-7M"
seo_title: "Thaki-IntentAction-Finance-KO-7M - A 7M model that turns Korean transfer requests into payee, amount and currency proposals, and Paxis | ThakiCloud"
seo_description: "A Korean model with 7,402,003 parameters turns a money-transfer request into a proposal of payee, amount and currency, or refuses. The general command-extraction goal failed in ten sealed attempts; narrowing the same checkpoint to transfers alone gave zero proposal errors on synthetic sealed tests. We describe what failed, why we narrowed it, and where it fits in Paxis."
excerpt: "How a tiny model built to extract many actions failed its general goal, and why we released the same model narrowed to money transfers. This model never moves money."
date: 2026-11-02
tags:
  - paxis
  - metis
  - maxis
  - intentaction
  - trustedge
  - money-transfer
  - abstention
  - research-preview
  - agentops
permalink: /en/agentops/thaki-intentaction-finance-ko-7m-paxis/
categories: [agentops, product]
author_profile: true
toc: true
toc_label: "Contents"
reading_time: true
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/agentops/thaki-intentaction-finance-ko-7m-paxis/"
---

## Summary

"김하늘한테 5만원 보내줘" ("Send 50,000 won to Kim Haneul") is a simple request for a person. For a system to handle it, it has to answer several questions at once. Who is the payee? How much? Is this a request to send now, or a remark about yesterday's transfer, or an instruction not to send?

We released [Thaki-IntentAction-Finance-KO-7M](https://huggingface.co/ThakiCloud/Thaki-IntentAction-Finance-KO-7M), a Korean model that answers those questions, on Hugging Face. It has 7,402,003 parameters. It turns a transfer request into a proposal made of a payee, an amount and a currency, or refuses when it cannot be sure. It contains no payment or banking code, and `safe_to_actuate` in its output is always `false`.

This model was not meant to be transfer-only. We built it as a general model that would also extract purchases, reservations, deletions and lookups, and it failed at that goal. This post records what failed and why we released the same model narrowed to money transfers. Every number was measured on synthetic data. The status is research preview.

## The general goal failed in ten attempts

The original goal was a general action extractor for agents: one model that structures transfer, purchase, reservation, deletion and lookup requests. We fixed the pass criteria before the attempts. On every evaluation split, wrong proposals had to be at most 0.5%, executed negated commands at most 0.1%, and at least 70% of correct proposals actually had to be proposed.

Across ten attempts, R2 through S9, it never passed. Lowering risk pushed coverage below 0.70, and meeting coverage raised wrong proposals on unseen phrasings. When we broke down the 43 wrong proposals that got through in the S8 evaluation, 24 were operation errors and 19 were target (RESOURCE) errors. Payee, amount and currency errors: zero.

That distribution decided the next step. The weakness was concentrated in "what is the user asking to do" and "which item or file," while the three fields a transfer needs were already stable. So instead of growing the model or training longer, we kept only the range where it was already strong. This does not mean the general goal succeeded. We admitted the failure and split off only the verified part. Actions other than transfers were not fixed; they were switched off.

## The model picks, rules settle

The model does not generate text. Rules first cut candidates out of the input, such as payee spans and amount expressions, and the network picks one candidate or "none" for each field. So it cannot invent a name or a number that is not in the input.

```text
Korean request
  → rule candidates     : payee spans, amount expressions
  → model selection     : per-field candidate pick, action / negation / abstain scores
  → general verifier    : negation, condition, past, reported-speech markers, verb match, registries
  → Finance Profile v1  : send + registered payee + one amount expression + identical re-parse
  → PROPOSE or ABSTAIN
```

The Finance Profile is the last gate. It proposes only when the action is a transfer, the payee appears verbatim in the list the user supplies, the sentence contains exactly one amount expression, and re-parsing gives the same value. Everything else is refused. Expressions like "5만원 이하로" (up to 50,000 won), "월급 들어오면" (when my salary comes in), "보내지 마" (don't send) or "어제 보냈어" (I sent it yesterday) produce no proposal. This layer never repairs or re-selects a value. It never proposes a transfer to someone outside the list, and with no list at all it refuses every request.

The amount boundary is settled here too. In the [SlotGrounder post](/tech-blog/en/agentops/thaki-slotgrounder-ko-7m-paxis/) from the same series, we covered a case where the neural network missed a proposal that cut "5만원" down to "5." The Finance Profile passes an amount span only if it matches the entire amount expression in the sentence, so it rejects that proposal.

## Results after narrowing

For evaluation we used a synthetic family generated only for testing: no name or business overlaps with training, and the phrasings and endings are new. The payee list mixed the correct payees with 5,000 decoy names. The checkpoint, thresholds and policy were fixed before this evaluation. Below are the results on the sealed8 family, opened once for this release.

| Split | Transfer requests proposed | Field errors among proposals |
|---|---|---|
| template | 456/456 (100%) | 0 |
| ASR noise | 169/173 (97.7%) | 0 |
| paraphrase | 149/151 (98.7%) | 0 |

Every proposed transfer had the correct payee, amount and currency. On all three splits, there were zero transfer proposals for non-transfer requests or negated commands. On the sealed6 and sealed7 families, already seen during development, the same settings also gave zero proposal errors, with coverage from 95.0% to 100%.

Three cautions apply. First, transfer rows are a small part of each split, 456 of 5,992 rows in template, so on the ASR split a single case moves the rate by about 0.6 points. Second, the ASR-noise split is not real recognizer output but synthetic text with fillers and spacing changes. Third, these numbers must not be read as general performance. By the general criteria, transfer rows are at most 16% of correct proposals, so coverage is capped at 0.16 and the general gate cannot be passed by construction.

## Understanding and execution are separate layers

For a transfer, understanding the sentence correctly and approving the movement of money are different problems. A `PROPOSE` from this model carries a confirmation request. It holds a hash of the source text, the positions in the source where the payee, amount and currency came from, and the structured values, and the user must confirm each field on a trusted screen. If any confirmed value differs from the value shown, it is rejected.

Signing is done by TrustEdge's separate Ed25519 approval path, which is not part of this release. The model neither signs nor approves. This training work did not touch the approval path.

## Where it fits in Paxis, Metis and Maxis

What follows is an application design. The model is not integrated into any product today and has never been tested against a real financial system.

**Paxis.** Paxis is the platform where agents carry out work instructions given by voice or text. For hard-to-reverse instructions such as transfers, this model can own the step that turns an instruction into a structured proposal and puts it on a confirmation screen. For voice instructions it sits after the transcription step of our [Korean ASR and Voice-to-Mission design](/tech-blog/en/agentops/thaki-asr-paxis-voice-to-mission/). If speech recognition mishears an amount, the model extracts that wrong number as is. That is why showing the value back to the user on the confirmation screen cannot be skipped.

**Metis.** Interpreting one transfer request does not require a large LLM. A 7M-class dedicated model can run as a small endpoint and refuse out-of-scope requests, handing them to a higher-level agent. We have not yet measured latency or memory.

**Maxis.** The lesson that carries over is on the training side. When the general gate failed, breaking the failures down by field revealed the range the model already handled well. Before growing the model, the right move was to decompose the failure and narrow the product scope to the verified range.

## How to use it

```python
from intentaction_min import load_intentaction

m = load_intentaction(".")
payees = ["김하늘", "해맑은꽃집"]           # your address book, exact names
r = m.propose("김하늘한테 5만원 보내줘", payees)
r["decision"]               # "PROPOSE" | "ABSTAIN" | "NO_ACTION"
r["action"]                 # {"operation": "send", "payee": "김하늘", "amount_minor": 50000, "currency": "KRW", ...}
r["confirmation_request"]   # on PROPOSE: fields to confirm and their positions in the source
r["safe_to_actuate"]        # always False
```

The repository holds only weights, config and minimal inference code; it contains no training data or evaluation sentences.

## Limitations

All training and test sentences are synthetic. We have not tested real users, real speech recognizers, slang, typos, or input mixed with foreign languages. Payee matching is exact string matching, so a stale list or two people with the same name produce wrong proposals that the model cannot notice. It covers only Korean transfers with won-style amount expressions. Latency and memory on device hardware were not measured. Do not use this checkpoint for actions other than transfers.

## Takeaway

A tiny model does not have to understand every command. This release is a model that failed its general goal, narrowed on the basis of failure analysis. The model picks candidates from the input, rules settle the amount and the payee, the user confirms each field, and a separate path does the signing. For a small model to become a practical component, its scope has to be exact and everything else has to be refused.
