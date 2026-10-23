---
title: "Releasing SOC-IER-4B-v0.1, a 4B Model for SOC Evidence Reasoning"
excerpt: "A 4B model that reads a short window of host telemetry and answers whether it contains real evidence of an attack step, citing the event IDs it relies on. Here is what improved on a sealed benchmark built from an attack family it never saw in training, and what it still cannot do."
seo_title: "SOC-IER-4B-v0.1: A 4B Model for SOC Evidence Reasoning - ThakiCloud"
seo_description: "ThakiCloud released SOC-IER-4B-v0.1, a SOC evidence-reasoning model that fine-tunes Qwen3-4B-Instruct-2507 with LoRA SFT on 603 examples. Sealed-benchmark decision macro-F1 rose from 0.388 to 0.625. Covers the merged fp16 weights, the LoRA adapter and the limitations."
date: 2026-10-24
last_modified_at: 2026-10-24
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cube"
tags:
  - soc-ier
  - security
  - soc
  - incident-response
  - evidence-reasoning
  - telemetry
  - slm
  - qwen3
  - lora
  - open-weight
  - paxis
categories:
  - owm
canonical_url: "https://thakicloud.com/tech-blog/en/owm/soc-ier-4b-open/"
header:
  teaser: /assets/images/soc-ier-4b-open-chart-en.png
---

This post is for security operations analysts and the people who run detection systems. The small model we are releasing answers one question. Does the short stretch of records in front of you actually contain evidence of an attack?

The model receives a record of what happened on a server over a few dozen seconds, along with a numbered list. It returns a decision together with the numbers of the records it used as evidence. It was trained never to cite a number that is not on the list. ThakiCloud is releasing it for research. It is not a model for automatic blocking. It is a model that sits next to an analyst and points at the evidence.

## In plain terms

Think of going through a credit card statement to find fraudulent charges. Every line on the statement has a number. To report fraud to the card company, you point at lines by number: "this one and this one look wrong." You cannot report a charge that is not on the statement.

You also should not call fraud on a single ordinary line. One purchase at the corner store is just groceries. A run of overseas online purchases at 3 a.m., though, is exactly the evidence you need. And sometimes there are lines where you honestly cannot tell either way.

This model has practiced only this kind of statement reading. One statement is one telemetry window. A line number is an event ID. The model picks one of "evidence present", "ordinary activity" or "cannot tell", and writes down only the line numbers that support its answer.

## What the model is

The model is called SOC-IER-4B-v0.1. Its input is host events such as process executions, DNS, HTTP and network flows. Each event carries a number of the form `[ev_...]`. The output is a single JSON object holding an incident category, a list of supporting event numbers, a decision and a short rationale of at most 60 words.

There are three decisions: `SUPPORTED`, `INSUFFICIENT` and `UNKNOWN`. Incident categories are seven types, such as credential compromise, data exfiltration and container compromise, plus `none`. Take a window where a customer database is packed with tar, an unfamiliar domain is looked up, and curl uploads the bundle. The model learned to answer that those three lines are evidence of data exfiltration.

The base model is Qwen3-4B-Instruct-2507. We applied LoRA SFT with thinking mode disabled. The license is Apache-2.0. Prompts were trained and evaluated in English only.

## What it learned from

The training set has 603 examples. 483 come from an in-house cyber range, a test environment we built ourselves that contains no customer or production data. The remaining 120 are auxiliary windows rebuilt from the public dataset witfoo/precinct6-cybersecurity.

No human labeled the answers. The range's attack script knows what it did and when, so the decisions and evidence numbers come from that record. Each attack window is paired with an ordinary window from the same host. In statement terms, the model learned by looking at a month with fraud next to a normal month.

Training took about 14 minutes on one H100 NVL. The recipe follows the one published on the CyberSecQwen-4B model card, with epochs cut from 10 to 3 because the dataset is small.

## Sealed benchmark results

The evaluation set was opened only once, after model selection was finished. It holds 48 independent incident chains and 239 windows. The chains come from an attack family absent from training. Every model was measured with the same prompts, the same parser and the same decoding.

![Sealed benchmark decision macro-F1 comparison](/assets/images/soc-ier-4b-open-chart-en.png)
*Sealed-benchmark decision macro-F1 with 95% confidence intervals. Values are copied as-is from the model card.*

| Model | Setting | Decision macro-F1 [95% CI] | Evidence recall | Evidence precision | False-SUPPORTED | Incident miss |
|---|---|---|---|---|---|---|
| **SOC-IER-4B-v0.1** | LoRA SFT | **0.625** [0.604, 0.643] | 0.895 | 0.929 | 0.064 | 0.061 |
| Qwen3-4B-Instruct-2507 | base, zero-shot | 0.388 [0.345, 0.430] | 0.532 | 0.615 | 0.688 | 0.070 |
| Qwen3-8B + LoRA (not released) | same recipe | 0.554 [0.524, 0.580] | 0.706 | 0.743 | 0.088 | 0.219 |
| Qwen3-8B | base, zero-shot | 0.391 [0.355, 0.428] | 0.263 | 0.347 | 0.352 | 0.447 |
| CyberPal2.0-20B | base, zero-shot | 0.385 [0.341, 0.432] | 0.565 | 0.641 | 0.336 | 0.465 |

The biggest change is in false alarms. The base 4B model called 68.8% of ordinary windows attack evidence, and after training that fell to 6.4%. The ability to point at evidence improved as well. Recall rose from about 53% to 90%, and precision from about 62% to 93%. Not a single model invented a number that was missing from the list.

Decision macro-F1 averages the F1 of the three decisions. As explained below, no model ever got `UNKNOWN` right. That puts the practical ceiling of this metric near 2/3, and 0.63 should be read with that in mind.

It also stands out that the 4B beat the 8B trained with the same recipe. The 8B missed 21.9% of attack windows, while the 4B missed only 6.1%. This is the result of one experiment, though, and we did not analyse why.

## What this comparison does not say

CyberPal2.0-20B is a security-specialised 20B model. We ran it zero-shot, on our output format, over telemetry windows it was never trained for. The table does not say that CyberPal2.0-20B is a weak security model. In fact its false-alarm rate of 33.6% is about half that of the base Qwen models.

What the table says is narrower. With only 603 task examples, a 4B model moved out of the band shared by the untuned models (around 0.39), and the confidence intervals do not overlap. We want to be clear that the result holds for this task and this benchmark only.

## Why the merged weights can be trusted

Merging a LoRA into 16-bit weights can quietly change the model, because the change a LoRA adds is small relative to 16-bit resolution. So we compared the merged model with the original base plus adapter on the same 309 windows. The seven pass criteria were fixed before any result was seen.

The first merge, saved in bf16, failed. Its incident-category agreement was 94.8%, just short of the 95% threshold. That merge is not published. The second was merged in fp32 and cast to fp16 once before saving. It passed all seven criteria.

Under greedy decoding the fp16 merge matched the adapter's decision on all 309 windows. Incident-category agreement was 98.1% and evidence-set agreement 99.7%. Its sealed three-run majority result was identical to the adapter's. That is why the numbers measured with the adapter are reported as the merged model's numbers. Reading the fp16 weights as bf16 can bring back the loss seen in the first merge, so we recommend leaving `dtype="auto"`.

## Running it yourself

The model expects exactly the system prompt and input rendering used in training. The full system prompt and an input example are on the model card. If the format changes, the decision values and the number-citing rule can drift.

```python
from transformers import AutoModelForCausalLM, AutoTokenizer

repo = "ThakiCloud/SOC-IER-4B-v0.1"
tok = AutoTokenizer.from_pretrained(repo)
model = AutoModelForCausalLM.from_pretrained(repo, dtype="auto", device_map="auto")

messages = [{"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": USER_PROMPT}]
enc = tok.apply_chat_template(messages, add_generation_prompt=True,
                              return_tensors="pt", return_dict=True).to(model.device)
out = model.generate(**enc, max_new_tokens=320, do_sample=True,
                     temperature=0.3, top_p=0.95)
print(tok.decode(out[0][enc["input_ids"].shape[1]:], skip_special_tokens=True))
```

`inference_example.py` in the repository is the complete runnable example. It also checks that the answer follows the schema and cites only numbers from the candidate list.

Evaluation used vLLM structured output. The JSON schema pins the values of the decision and incident category, but deliberately leaves evidence numbers open. That is what makes it possible to measure whether the model invents numbers outside the list. Every number on the card comes from three samples at temperature 0.3, top_p 0.95 and at most 320 tokens, with a majority vote.

```python
llm = LLM(model="ThakiCloud/SOC-IER-4B-v0.1", dtype="auto", max_model_len=8192)
sp = SamplingParams(temperature=0.3, top_p=0.95, max_tokens=320,
                    structured_outputs=StructuredOutputsParams(json=SCHEMA))
print(llm.chat([messages], sp)[0].outputs[0].text)
```

To reproduce the results, use the LoRA adapter. Load it on revision `cdbee75f` of the base model with `PeftModel.from_pretrained(model, "ThakiCloud/SOC-IER-4B-v0.1-LoRA")`. The adapter repository also holds `train_report.json`, with the training configuration and loss curve, and file checksums.

## What it cannot do yet

It never got `UNKNOWN` right. The F1 for that decision was 0 for this model and for every model we compared. The training data had only 9 examples of it. In statement terms, even on a line where it should say "I don't know", it picks either fraud or normal. In v0.1, treat `UNKNOWN` as an unsupported decision.

A 6.4% false-alarm rate is not small either. Roughly one ordinary window in sixteen gets called attack evidence. In a real SOC that becomes a cost paid in analyst time. That is why it is one of the two targets for the next version.

Please also keep in mind that evaluation happened inside the same range. Attack families differ between training and evaluation, but sensors, hosts and benign background activity do not. Whether it works on other EDR or eBPF schemas, or on real production traffic, has not been checked. One evaluation window is 0.4% of the set, so differences of a few points are hard to interpret.

The fact that labels come from the attack script is a limitation too. An analyst might reasonably judge individual windows differently. Evaluation covered windows of at most 16 candidate events, about 2 to 3 thousand tokens. Longer windows were not tested.

## Where to use it

The first place is analyst assistance. If the model first points at which lines in an alerted window support the attack hypothesis, the analyst can check those lines first. The final call stays with a person.

The second is shadow evaluation. You attach it next to an existing detection pipeline and only record its decisions for comparison. How it behaves on production telemetry is not yet verified. We suggest doing that verification in exactly this setting.

We do not recommend uses such as automatic blocking or isolation that act on the model's output alone. Paxis, the work automation platform ThakiCloud builds, passes every execution step through policy gates and audit records. A model that points at evidence by number could become material for recording "why this action is being taken" in that kind of structure. At 4B it is also easy to run separately inside an air-gapped network. That said, this model is not part of any product yet. For another case of a small model taking on routine work, see the [KoToolAct-4B release post](/tech-blog/en/owm/kotoolact-4b-korean-tool-execution/).

## What we released

| Repository | Format | Purpose |
|---|---|---|
| [ThakiCloud/SOC-IER-4B-v0.1](https://huggingface.co/ThakiCloud/SOC-IER-4B-v0.1) | merged fp16 | Run directly, for Transformers and vLLM |
| [ThakiCloud/SOC-IER-4B-v0.1-LoRA](https://huggingface.co/ThakiCloud/SOC-IER-4B-v0.1-LoRA) | PEFT adapter | Reproduction, with training report and checksums |

The training and evaluation data are not released. The range telemetry contains host names, addresses and scenarios from our own test environment. The auxiliary windows derived from WitFoo can be rebuilt from the public source.

Reading the whole statement and naming the culprit is still the analyst's job. This model only goes as far as telling you, by number, which lines to look at first. Keeping those numbers from ever leaving the list is the promise we most wanted to keep with this release.

*Source: sealed-benchmark results published on the SOC-IER-4B-v0.1 model card, measured with vLLM 0.28.0 on the same inputs on one H100 NVL (the 20B comparison model on one H200 NVL).*
