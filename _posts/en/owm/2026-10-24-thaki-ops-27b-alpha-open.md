---
title: "Releasing Thaki-Ops-27B v0.1-alpha, an Experimental Model for Read-Only Kubernetes Incident Investigation"
excerpt: "Can an incident-investigation agent leave the cluster alone, stop repeating the same query, and say it does not know when it does not? We are releasing a LoRA adapter for Qwen3.8-27B as an experimental alpha. The checks it failed against our own release gate are written down here too."
seo_title: "Thaki-Ops-27B v0.1-alpha: A LoRA Adapter for Kubernetes Incident Diagnosis - ThakiCloud"
seo_description: "ThakiCloud released Thaki-Ops-27B v0.1-alpha, a LoRA adapter for Qwen3.8-27B that tunes tool-calling agents such as HolmesGPT to investigate Kubernetes incidents read-only. Covers what improved, what fell short of our release gate, intended use and limitations."
date: 2026-10-24
last_modified_at: 2026-10-24
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cube"
tags:
  - thaki-ops
  - kubernetes
  - sre
  - root-cause-analysis
  - holmesgpt
  - tool-calling
  - qwen3.8
  - lora
  - open-weight
  - experimental
categories:
  - owm
canonical_url: "https://thakicloud.com/tech-blog/en/owm/thaki-ops-27b-alpha-open/"
header:
  teaser: /assets/images/thaki-ops-27b-alpha-open-chart-en.webp
---

This post is for people who want to put an AI assistant on server incident investigation. Assistants like this tend to share a few bad habits. They repeat the same status query over and over. They open secrets they had no reason to look at. They name a root cause even when the evidence is missing.

The model we are releasing is an experimental adapter built to break those habits. Let us be clear up front: this version **did not pass** our own release gate. We are publishing it as an experimental alpha so people can try it and send feedback.

## In plain terms

Picture taking a car with a warning light on to a repair shop. A good mechanic first plugs in the diagnostic scanner and reads the codes. Taking parts off or swapping them waits until the owner says yes. The mechanic does not stare at the same gauge ten times. The owner's wallet sitting in the car stays closed. If the cause cannot be found, the mechanic says "not confirmed yet."

Those are the habits Thaki-Ops-27B is trying to learn. The scanner is a set of read-only Kubernetes tools. The owner's wallet is the value inside a Secret. Swapping parts is a write command that changes the cluster. This alpha picked up some of those habits but has not learned others yet.

## What the model is

Thaki-Ops-27B v0.1-alpha is a LoRA adapter for [Qwen/Qwen3.8-27B](https://huggingface.co/Qwen/Qwen3.8-27B). We publish the adapter only, not merged weights. It uses LoRA r=16, alpha=32. It is attached to the language model's attention, MLP and linear-attention projections, and the vision tower is untouched. The license is Apache-2.0, the same as the base model.

Training and evaluation both ran inside [HolmesGPT](https://github.com/robusta-dev/holmesgpt). The agent only had read-only tools: `kubernetes_jq_query`, `fetch_pod_logs`, and `bash` limited to read-only `kubectl`. That is why it works best inside a similar tool-calling agent loop.

There is one intended use. It is a read-only diagnosis assistant for Kubernetes, with a human reviewing the conclusion. Do not use it for automated remediation or for running write or privileged commands. It also does not fit any setting where a root-cause call is acted on without review.

## What improved and what fell short

All numbers come from our in-house HolmesGPT harness on KIND clusters. Each scenario ran 3 times, with English and Korean prompts. Every model used the same harness and serving settings, and only the weights changed. Comparisons are against the base model run in the same harness.

![No-op handling score. English prompts: base 0.636, alpha 0.909. Korean prompts: base 0.818, alpha 0.909.](/assets/images/thaki-ops-27b-alpha-open-chart-en.webp)
*This check asks whether the agent leaves things alone when nothing is wrong. Values are the ones published on the model card.*

The clearest gain is the case where nothing is broken. It is the ability not to swap parts on a car that runs fine. With English prompts the score rose from about 0.64 to 0.91. With Korean prompts it rose from about 0.82 to 0.91.

| Check | Result vs base model | Verdict |
|---|---|---|
| Behaviour score on development scenarios (14) | +0.143 mean, paired 95% CI [+0.042, +0.262], 5 better · 0 worse | Pass |
| Runs where the agent read Secret values | 0, same as base | Pass |
| Same call repeated 10+ times (sealed sets) | 0 runs, max 4 repeats | Pass |
| Root-cause accuracy on seen scenarios (43) | No regression | Pass |
| Independent held-out scenarios (12) | −0.021 mean, 1 better · 1 worse | Fail |
| Polling-loop scenarios (12) vs our earlier r4 adapter | 3 worse, gate allows 1 | Fail |

On the development scenarios it beat the base model. On the 12 independent scenarios it had never seen, there was effectively no difference. That means we cannot yet say the development gains carry over to new problems. This is the main reason it stays an alpha.

The independent set needs care when you read it. It has only 12 scenarios, so one scenario moves the mean by about 0.08. It has also been used to choose between several candidates, so it is not a clean hold-out. So a mean 0.02 lower should be read as neither "worse" nor "the same."

## Habits it has not learned yet

Here are a few concrete failures. The first is a scenario where the agent should keep going until the pod schedules. The real cause was a `schedulerName` field pointing at a scheduler that does not exist. It found that cause in 4 of 6 runs. The other 2 runs kept re-querying narrow status fields. That is like rechecking the gauge without ever opening the spec sheet.

The second is a Job that had already finished and been cleaned up. The Job had run and the resource was gone. Its run history can be confirmed from events. None of the 6 runs checked events. It does not yet have the habit of looking up the past of a resource that has disappeared.

The third is expressing uncertainty. When the cause is not observable, the right answer is "not determined." This model often states a plausible cause even when the evidence is thin. That is a mechanic saying "it's the battery" without reading the scanner.

The tendency is stronger without tools. We asked, as a plain chat question, about a Pending pod with no events and no node. The model confidently answered "insufficient resources." With no FailedScheduling events, that answer is unlikely. Always run it inside a tool-calling agent so it can look before it answers.

## How it was trained

The method is supervised fine-tuning of a LoRA adapter. It was trained for 1 epoch on 283 multi-turn trajectories that include tool calls. That took about 3.4 hours on 1 NVIDIA B200. Training continued from our earlier r4 adapter rather than starting from scratch.

The data is trajectories recorded in synthetic KIND scenarios written by our team. They were filtered by deterministic checks. Trajectories missing the answer anchors, reading a Secret, issuing a write command or repeating calls were all dropped. 260 were generated by the base model or our earlier adapter. 23 came from DeepSeek-V4-Pro through its API. DeepSeek's terms permit using outputs to train other models. No customer data or production logs were used. The training data is not released.

## Try it

The adapter was trained on the base model's multimodal class path. So load the base with `Qwen3_5ForConditionalGeneration` and attach the adapter with PEFT. Below is the example from the model card.

```python
import torch
from transformers import AutoTokenizer, Qwen3_5ForConditionalGeneration
from peft import PeftModel

base = "Qwen/Qwen3.8-27B"
adapter = "ThakiCloud/Thaki-Ops-27B-v0.1-alpha"

tok = AutoTokenizer.from_pretrained(adapter)
model = Qwen3_5ForConditionalGeneration.from_pretrained(base, dtype=torch.bfloat16, device_map="auto")
model = PeftModel.from_pretrained(model, adapter).eval()

msgs = [{"role": "user", "content": "A pod in namespace demo has been Pending for 20 minutes with no events and no node. What should I check first?"}]
ids = tok.apply_chat_template(msgs, add_generation_prompt=True, return_tensors="pt", return_dict=True, enable_thinking=False)["input_ids"].to(model.device)
out = model.generate(input_ids=ids, max_new_tokens=400, do_sample=False)
print(tok.decode(out[0, ids.shape[1]:], skip_special_tokens=True))
```

You need a `transformers` build with Qwen3.5-architecture support and `peft>=0.20`. In bf16 it takes about 60 GB of GPU memory. The base revision used for training is `1d4bf0f2ff6012fd82039f2fa52739d0dd7c60c0`.

A plain chat prompt like the one above is only a smoke test. For real use, give an agent such as HolmesGPT read-only tools and plug the model in there. As noted above, without tools this model guesses.

## Before you use it

These are Kubernetes-only results. VM and bare-Linux incidents were not measured. Only English and Korean were tested. There are three known failure modes. It narrows queries too early and misses the decisive spec field. It does not check event history for resources that disappeared. It sometimes asserts a cause when the evidence is incomplete.

The model does not enforce permissions. Scope the tools you give the agent to read-only. We also recommend blocking Secret access with RBAC. Act on a root cause the model proposes only after a human has reviewed it. The mechanic's diagnosis is only a reference. The owner decides on the repair. For how far an agent should be trusted to act on its own, see [our post on the boundary between autonomous remediation and calling a human]({{ '/en/research/safe-autonomy-k8s-remediation/' | relative_url }}).

## Why we are releasing it

ThakiCloud builds Paxis, a work automation platform that passes each work step through policy gates and audit records. Where operational logs cannot be sent to an external LLM, teams need a diagnosis model they can run in-house. Thaki-Ops-27B is an experiment to test that possibility. The adapter is not integrated into any product yet.

That is also why we are releasing a version that did not pass our gate. Our harness runs synthetic scenarios on KIND. People trying it on real clusters will see where it gets stuck better than we can. If you see it repeat the same query or assert a cause without evidence, please tell us in the Community tab of the model repository.

An earlier release that taught a small model routine tool calls is described in the [KoToolAct-4B release post]({{ '/en/owm/kotoolact-4b-korean-tool-execution/' | relative_url }}). That model handles fixed tasks precisely, while this one investigates causes.

## What we released

| Repository | Format | Use |
|---|---|---|
| [ThakiCloud/Thaki-Ops-27B-v0.1-alpha](https://huggingface.co/ThakiCloud/Thaki-Ops-27B-v0.1-alpha) | PEFT LoRA adapter | Experimental alpha for Qwen3.8-27B, with English and Korean model cards |

This alpha is not a finished SRE agent. It learned to leave things alone when nothing is wrong. It has not yet learned to chase evidence to the end on an incident it has never seen. Think of it as an apprentice mechanic who can read the scanner. The repairs still belong to people.

*Source: values published on the model card. Measured on our in-house HolmesGPT harness on KIND clusters, 3 runs per scenario, with English and Korean prompts.*
