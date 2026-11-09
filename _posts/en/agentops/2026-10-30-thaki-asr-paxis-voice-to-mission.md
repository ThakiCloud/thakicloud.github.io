---
title: "From AI That Understands Speech to AI That Completes Work"
seo_title: "Thaki Korean ASR and the Paxis Agent Platform - From Speech Recognition to Verified Work Execution | ThakiCloud"
seo_description: "We fine-tuned Qwen3-ASR-1.7B for Korean customer-service speech and numbers, and verified it with an independent evaluation that passed all five pre-registered release gates. We look at the call-center gains, how the 2026-11-04 release audit narrowed the interpretation of the general-speech and numeric results, and the Voice-to-Mission architecture that connects this model to the Perception layer of Paxis."
excerpt: "Once speech becomes text, what happens next is the real question. We fine-tuned and verified a Korean ASR model, and introduce the architecture Paxis uses to turn its output into work execution with an evidence trail."
date: 2026-10-30
last_modified_at: 2026-11-09
tags:
  - paxis
  - asr
  - korean-speech-recognition
  - agents
  - customer-support
  - soc
  - evidence-ledger
  - qwen
  - agentops
permalink: /en/agentops/thaki-asr-paxis-voice-to-mission/
categories: [agentops, product]
author_profile: true
toc: true
toc_label: "Contents"
reading_time: true
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/agentops/thaki-asr-paxis-voice-to-mission/"
---

![Title card: from AI that understands speech to AI that gets work done. Call-center CER (TEST-D) 6.07%, base 6.88%](/assets/images/thaki-asr-paxis-voice-to-mission-fig-title-en.webp)

A customer asks to cancel a payment during a call. Logging that sentence does not finish the job. The system has to understand the request, look up the order, review the refund policy, get the necessary approval, and then process it in the actual system. If "refund three hundred thousand won" is heard as "thirty thousand won", every step after it does the wrong thing. The moment speech becomes text, the next step is the real question.

So we started by building the first link in that chain, Korean speech recognition, ourselves. A [Korean ASR model](https://huggingface.co/ThakiCloud/Thaki-ASR-KO-1.7B) fine-tuned on top of Qwen3-ASR-1.7B for call-center speech and numbers passed all five pre-registered release gates in an independent evaluation. Call-center CER fell from 6.88% to 6.07%. This model is not just a transcription tool. It is the starting point of a Voice-to-Mission architecture that connects it to the Perception layer which kicks off Paxis work execution.

This post is for engineers and leaders who want voice AI to be part of work automation in their enterprise. We first show the performance and development process of the Korean ASR we actually trained, then walk through application cases that connect it to the Paxis autonomous agent architecture.

## Transcription is not the finish line: five capabilities have to connect

Turning one spoken request into finished work takes several different AI capabilities in sequence.

- **Perception:** recognize speech accurately.
- **Understanding:** understand the intent and key information in the utterance.
- **Decision:** decide the next action based on work policy and evidence.
- **Action:** execute the enterprise system's APIs and tools.
- **Verification:** confirm the execution result and record the evidence.

![The same customer utterance passing through ASR, extraction, and a Paxis Mission](/assets/images/thaki-asr-paxis-voice-to-mission-fig-io-en.webp)
*The same customer utterance turns into a transcript, structured fields, and an execution plan as it passes each layer. The utterance is the made-up scenario from the post; values show the format only.*

The Paxis Agent Platform aims to be an agent execution environment that connects these five capabilities. We started by building and validating the first link, Korean speech recognition, ourselves.

## One digit changes the job, so we trained the ASR ourselves

Better general-purpose ASR does not guarantee the same quality in every enterprise voice environment. In a Korean customer-service setting, beyond raw sentence accuracy, the model must correctly handle numbers, amounts, dates, product names, and colloquial expressions. "Refund three hundred thousand won" and "Refund thirty thousand won" look like a one-character difference in Korean, but in a business context they mean completely different things. CER (character error rate, the share of reference characters the model gets wrong) can be low and still hide a misheard amount, and then the result cannot be passed as-is to a finance or customer-support agent.

To solve this, we trained a model specialized for Korean call-center and general conversation on top of Qwen3-ASR-1.7B. Three things were central.

First, we tuned the training distribution to match real enterprise conversation. Rather than leaning on generic speech data, we balanced call-center speech, everyday conversation, and general Korean utterances.

Second, we preserved numeric meaning. "Three hundred thousand won" and "300,000 won" are different expressions of the same value, while "300,000 won" and "30,000 won" are entirely different values. To evaluate this, we built a separate numeric evaluator that compares values for Arabic digits, the Korean man/cheon/eok units, and digit-by-digit readings (such as "gong-il-gong") instead of relying on string equality. It does not read place-value Hangul numerals such as "osibi-man won" as numbers; the correction below covers this limit.

Third, we preserved existing general recognition. A model that improves on call-center speech but degrades on general conversation is hard to use as an enterprise model. So we checked that there is no regression against the original model on a general-conversation set as well. A later audit found that this set shares sentences with the training data (see the correction below).

## Call-center speech improved; read numbers and general speech narrowly

> **Correction (2026-11-05).** Kwan-u Choi, the author of kocer, shared an independent re-evaluation in [Hugging Face Discussion #1](https://huggingface.co/ThakiCloud/Thaki-ASR-KO-1.7B/discussions/1), which prompted a release audit. We correct two interpretations. (1) 454 of the 456 sentences in the general-conversation set (TEST-C, the Zeroth-Korean test split) also appear in the training data (Zeroth-Korean train). TEST-C should therefore be read only as a no-regression check, and we withdraw the "43.6% improvement on general conversation" claim. (2) The numeric metric is **numeric reference coverage with a notation bias**, not numeric recognition accuracy; much of the gain reflects the model writing Arabic digits more often. The pre-registered GO verdict stands; only the scope of what it means has been narrowed.

For the final evaluation, we compared the original Qwen3-ASR-1.7B against the Korean-specialized checkpoint `ckpt-1200`. We composed three new test sets, TEST-C/D/E, that were not used in earlier evaluations, and applied the same decoding conditions to both models. The sets were new, but as noted above, TEST-C's sentences overlap the training data.

The released model is available on [Hugging Face](https://huggingface.co/ThakiCloud/Thaki-ASR-KO-1.7B). The evaluation code and reproduction scripts are published on [GitHub](https://github.com/ThakiCloud/thaki-asr-ko-1.7b).

![Call-center CER: TEST-D 6.88% to 6.07%, TEST-E 6.83% to 6.35%](/assets/images/thaki-asr-paxis-voice-to-mission-fig-bars-en.webp)
*Call-center CER (TEST-D, 900 items) fell from 6.88% to 6.07%, and CER on number-bearing call-center speech (TEST-E, 250 items) from 6.83% to 6.35%.*

![Thaki Korean-specialized ASR independent evaluation results](/assets/images/thaki-asr-paxis-voice-to-mission-results-en.webp)
*Independent evaluation results for the original model and the Korean-specialized model. All figures were measured on the sealed TEST-C/D/E sets. Read the general-speech and numeric figures in the image as qualified by the table and correction below.*

| Evaluation item | Original model | Thaki Korean-specialized model | Change |
|---|---:|---:|---|
| General conversation CER (TEST-C, 456 items) | 3.46% | **1.95%** | No-regression check only (sentences overlap training data; improvement claim withdrawn) |
| Call-center CER (TEST-D, 900 items) | 6.88% | **6.07%** | ~11.6% relative improvement |
| Number-bearing call-center CER (TEST-E, 250 items) | 6.83% | **6.35%** | ~7.1% relative improvement |
| Numeric reference coverage (C1, 327 utterances × 3 reps = 981) | 66.36% | **88.69%** | +22.33%p (includes notation effects; not numeric accuracy) |
| Plausible-but-wrong numbers | 12 | **6** | 50% reduction |
| Runaway detections | 0 | **0** | Criterion met |

*Numeric reference coverage (C1) scores 327 number-bearing utterances three times each with greedy decoding, for 981 results. An output passes when every number in the reference appears in it, even if it contains extra numbers. If the reference writes the amount in digits as "52-man won" and the model spells it out in Hangul numerals ("osibi-man won"), it counts as a failure even though the content is right.*

![Numeric reference coverage C1: base 66.36%, Thaki 88.69%, notation effect included](/assets/images/thaki-asr-paxis-voice-to-mission-fig-bars-numbers-en.webp)
*Numeric reference coverage rose from 66.36% to 88.69%, but much of that comes from the model writing Arabic numerals more often. Per the 2026-11-05 correction, do not read it as number recognition accuracy.*

Re-scoring the same outputs with [kocer](https://pypi.org/project/kocer/), which normalizes notation differences, the call-center gain remains: on TEST-D the kocer difference is −0.99 pp (95% CI −1.25 to −0.74). Kwan-u Choi's separate 1,936-utterance telephone set also showed a significant −1.14 pp.

Its 408 number-bearing utterances, however, showed no significant difference. The size of the numeric gain is therefore domain-dependent. Full figures are in the release-audit section of the [model card](https://huggingface.co/ThakiCloud/Thaki-ASR-KO-1.7B).

All five pre-registered release gates passed. The verdict jointly checks call-center recognition, general-speech regression, numeric coverage, wrong-number generation, and inference stability. As corrected above, the general-speech and numeric items should be read narrowly: as a regression check and as a notation-biased metric, respectively.

### Evaluation data is part of product quality

The development was not smooth from the start. An early evaluation showed degraded numeric recognition. Looking at the errors, the problem was the evaluator: Korean numeral and digit notations were not being compared correctly. We then fixed the evaluator to compare numeric values. In another evaluation, trailing conversation that actually exists in the audio was missing from the reference transcript, so sentences the model recognized normally were misjudged as over-generation.

The key lesson here: **you must distinguish whether the model is wrong, whether the reference data is wrong, or whether the metric is wrong.** Instead of retroactively changing past failure verdicts, we recorded the cause and re-ran a separate independent evaluation. The same verification approach applies to ASR and to evaluating judgment models and autonomous agents alike.

## Paxis uses the ASR as the Perception layer of work execution

An ASR model alone cannot handle a customer's request. When combined with Paxis, the important point is using the speech-recognition model not as a mere input API but as a **Perception layer that starts work execution**.

![Typical chatbot Voice-to-Text-to-Answer path compared with the Paxis Voice-to-Mission path](/assets/images/thaki-asr-paxis-voice-to-mission-fig-arch-en.webp)
*A typical chatbot attaches an answer to the transcript and stops. Paxis turns the transcript into a work goal and ties tool execution, approval, and evidence into one flow.*

The diagram below lays out the reference architecture for that combination step by step.

```mermaid
flowchart TB
  A["Customer / employee voice"] --> B["Audio preprocessing: VAD, segmentation, diarization (optional)"]
  B --> C["Thaki Korean ASR: conversation, numbers / amounts, domain terms"]
  C --> D["Semantic extraction: intent, entities, numeric integrity"]
  D --> E["Paxis Mission: planning, agent selection, policy decision"]
  E --> F["Specialized agents: customer support, security / SOC, enterprise operations"]
  F --> G["MCP / enterprise APIs"]
  G --> H["Execution verification: Evidence Ledger"]
  H --> I["User confirmation, final response"]
```

In this architecture, a single general-purpose LLM does not have to do everything. The ASR handles speech recognition, specialized models or a policy engine handle work-specific decisions, and Paxis agents with MCP tools perform the actual execution. MCP (Model Context Protocol) is a connection standard that lets agents call external tools and data sources in the same way. Each component can be evaluated and improved independently.

Equally central is **separating the model's language understanding from its authority to act on work**. A payment cancellation, account change, or security-policy modification must never be executed on the basis of a speech-recognition result alone. Such actions separately require authentication, policy validation, user confirmation, and verification of the execution result.

## Refunds, security investigations, meetings: three scenes where speech becomes work

### Customer support: handling a refund request with evidence

A customer says, "I cancelled the 350,000-won service I paid for last week, but the refund still hasn't come through. Could you check on it?" A general chatbot would explain the refund policy or offer to connect the customer to a human agent. A Paxis-based agent processes the request step by step.

The ASR transcribes the utterance and extracts the key information: `350,000 won`, `last week`, `payment cancelled`, `refund status check`. The amount is treated as numeric information that must be verified semantically. Paxis then structures the request as a work mission: confirm the customer's authentication status, look up recent payment and cancellation records, check refund progress, judge whether the delay is policy-compliant, and report the result.

The payment-lookup agent calls the enterprise payment API, and the policy-decision agent compares the transaction details against the refund rules. If the evidence is insufficient, it does not draw an arbitrary conclusion and requests additional confirmation. Finally, the transaction ID, API result, applied policy, and processing time returned by the system are recorded in the Evidence Ledger, the record that ties inputs, decisions, tool executions, and verification results together. The customer is told only the verified result, and state-changing actions like executing the refund go through separate authority checks and approval.

Where the traditional flow is Voice-to-Text-to-Answer, the Paxis goal is **Voice-to-Mission-to-Verified-Action**.

### Security operations: a SOC investigation that starts by voice

A security analyst can say, "Show me the three high-severity authentication anomalies detected today, and check the correlation between the related IPs and accounts." Paxis decomposes this request into a multi-stage investigation.

Through MCP, it gathers related events from the SIEM, logs, and event stores, and binds detection rules, IPs, accounts, and timestamps into an evidence set. A security-domain decision model assesses the sufficiency of the evidence and the likelihood of an attack. Unlike a plain LLM summary, it is designed so that each judgment can be traced back to the evidence it is based on.

For high-severity cases with sufficient evidence, it proposes account lockdown, IP blocking, or additional investigation, and actual blocking or permission changes are performed only after passing policy and approval procedures. The original events, analysis, evidence, approval history, and execution results are linked in the Evidence Ledger.

In this structure, the analyst starts the investigation by voice, but the AI is not allowed to execute security actions without evidence. Autonomy is raised, while the basis for decisions and execution authority remain controlled.

### Meetings: turning agreements into actual work

Meeting automation usually stops at transcription, summarization, and action-item extraction. Combined with Paxis, content agreed on in a meeting can be carried into the actual work flow. Take the case where someone says in a meeting, "Finish the GPU cost analysis by next Wednesday and summarize the savings compared to the existing inference server."

The system transcribes the utterance, optionally separates speakers with a diarization model, and extracts the schedule and work directive. Paxis composes a cost-analysis Mission, queries infrastructure cost and inference performance data, writes the report, and reflects it in the work system after the owner confirms.

One caveat: the single-utterance evaluation results of the current Korean ASR do not guarantee performance over entire multi-speaker meetings. Long-audio segmentation, overlapping speech, and speaker identification require separate development and validation. Even so, the direction is clear: the system can move from summarizing what was said in a meeting to executing what was agreed on and confirming the results.

## Why modular specialist models fit enterprises better than one big model

A general-purpose multimodal model could handle speech understanding, work judgment, tool calling, and result generation all by itself. In enterprise settings, however, a modular specialized-model architecture is often the better fit.

![One general multimodal model compared with modular specialist models](/assets/images/thaki-asr-paxis-voice-to-mission-fig-arch-modular-en.webp)
*Hand everything to one general model and every fix means re-checking the whole thing, with only a final reply left behind. Go modular and ASR, decisions, and execution are evaluated and fixed separately, with each step's evidence linked in the Evidence Ledger.*

| Property | One general model | Modular specialist models |
|---|---|---|
| Improving one part | ⚠️ any fix means re-validating everything | ✅ retrain only the ASR |
| Model choice by risk | ⚠️ the same model for every request | ✅ small model for FAQ, specialist for policy |
| Data sovereignty | ⚠️ raw data often goes to an external AI | ✅ can run on customer-controlled infrastructure |
| Evidence trail | ⚠️ only the final reply remains | ✅ each step linked in the Ledger |

**Independent performance improvement** comes first. Raising the recognition rate of the Korean call-center ASR does not require retraining the security decision model or the work-execution agents. If only numeric meaning is the problem, the evaluation and processing layer for numbers can be fixed in isolation.

**Model selection by work risk** is also possible. Simple FAQ traffic goes to a relatively small model, while policy judgment or complex case analysis goes to a specialized model. Model routing considers accuracy together with cost, latency, and risk.

**Data sovereignty and deployment flexibility** is another axis. In finance, government, and security, passing raw voice and work data to an external AI is often not an option. Placing the ASR, specialized models, and agent execution environment on infrastructure the customer controls makes data movement and access control easier to design. Self-hosting alone does not complete data sovereignty, though: tenant isolation, storage policy, access auditing, and de-identification have to come with it.

**Automation that leaves a trail** is the last piece. A single final answer from a general-purpose model makes it hard to judge whether the work was done correctly. The Paxis Evidence Ledger approach aims to connect inputs, decisions, tool executions, and verification results, so you can confirm not just the final answer but what the decision was based on and what was executed.

## After CER, measure the work completion rate

A better ASR CER does not lift the whole agent's work success rate by the same proportion. ASR standalone performance and work quality after wiring into Paxis must be evaluated separately.

| Evaluation layer | Key metrics |
|---|---|
| ASR | CER, numeric-semantic accuracy, omission / hallucination, RTF |
| Semantic understanding | Intent accuracy, entity-extraction accuracy |
| Decision model | Policy compliance rate, evidence sufficiency, wrong-judgment rate |
| Agent execution | Mission success rate, tool-call accuracy |
| Operational safety | Unauthorized-execution count, tenant isolation, auditability |
| User experience | End-to-end completion time, re-confirmation request rate |

Information that is costly to misrecognize, such as amounts, account numbers, phone numbers, and dates, is handled more strictly than ordinary CER, with optional original-audio re-verification or a user-confirmation step. In future Paxis integration validation, we plan to measure not transcription performance but **the rate at which a voice request leads to completed work, and the safety of that process**.

## We will put domain models on Paxis one at a time

What this development showed is not just that fine-tuning lowers error rates. More important is that we can build a model fitted to a specific domain, pass it through trustworthy evaluation, and use that model as part of a real work-execution system.

The development flow we are aiming for is **Domain Data, Model Training, Independent Evaluation, Model Registry, Paxis Agent Integration, Verified Execution**. Specialized models trained per domain become independent AI capabilities that Paxis agents use. The Korean ASR handles voice input, the security-specialized model analyzes cases and evidence, and the work-decision model reviews policy and execution conditions. Paxis connects these as Missions and manages tool execution and result verification.

One distinction to make clearly: what has completed public validation is the ASR model. The Paxis application architecture and the customer-support, SOC, and meeting scenarios described here are technical application examples, not measured results of an integrated product. A real service needs its own end-to-end validation.

## Closing

The next step of speech recognition is not text, it is work. A Korean ASR fine-tuned for call-center speech and numeric recognition passed all five gates in an independent evaluation, and the Voice-to-Mission architecture that connects that model to the Paxis Perception layer is the reference design that closes the chain. Securing a specialized model for each domain, confirming trust through independent evaluation, and connecting it to safely complete real work while leaving an evidence trail is the direction we see for AI platforms.

The first experiment you can run today is simple. Pull the model from [Hugging Face](https://huggingface.co/ThakiCloud/Thaki-ASR-KO-1.7B), run a few of your own call recordings that contain amounts and dates, and instead of stopping at one CER number, count separately whether the numeric values came out right. What we are building goes beyond an AI that hears well, toward an AI that understands a user's request and safely completes the enterprise's work.

---

*ThakiCloud AI Engineering, Korean ASR & Agentic AI*

*Source of ASR performance: ASR-NG-R2 Step 5b independent evaluation, October 29, 2026. The model weights are published on [Hugging Face](https://huggingface.co/ThakiCloud/Thaki-ASR-KO-1.7B). The release status of the Paxis-integrated service must be confirmed separately.*
