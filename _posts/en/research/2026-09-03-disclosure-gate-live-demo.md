---
title: "A Consultation Demo With a Disclosure Gate: Yesterday's Numbers, On Screen Today"
excerpt: "One day after publishing measurements of a model with disclosures baked into its weights, we turned the numbers into an interactive demo. Watch the same question get one of five required disclosures from the raw model, and all five from the weights model, with zero instructions."
categories: [research, product]
permalink: /en/research/disclosure-gate-live-demo/
tags: [compliance, demo, finetuning, disclosure-gate, korean-llm]
toc: true
---

If you review the compliance of a securities assistant, this post gives you screens instead of tables. Yesterday we published [measurements](/tech-blog/en/research/style-tuning-hurts-compliance/) showing that mandatory disclosures can live in a model's weights rather than its prompt. Today that result is an interactive demo where a gate judges every answer on the spot.

## Plain terms

Picture a supervisor sitting next to a call-center agent. Every time the agent finishes an answer, the supervisor holds up a checklist and marks, right there, whether the five required notices made it in. In this demo the supervisor is code, and the checklist is five phrase families confirmed verbatim in the current Korea Financial Investment Association standard sales guidelines.

## Same question, two models, one screen

Here is the demo's core scene. The same question, "I am a conservative investor but I want to buy a leveraged ETF," goes to both models.

![Two answers to the same question with gate verdicts — raw model above (1 of 5), weights model below (5 of 5)](/assets/images/finance-demo-03-fin1-hits.webp)
*The upper turn is the raw 27B; the lower turn is the disclosure-weights model. The chips flipping from red to green are the whole project.*

The raw model's answer ran 1,235 characters with 21 formatting elements and carried one of five required disclosures. The weights model answered in 227 characters, zero formatting elements, and all five disclosures. Not a single line of instructions was given. This single on-screen turn also matches the repeated measurements: in the ledger from three days ago, the weights model's pair-level compliance was 95.4% against 13.8% for the same base before training.

Shorter answers bring speed with them. In the captured turns, the raw model finished in 23.3 seconds and the weights model in 1.2 seconds. Add text-to-speech for phone consultations, and a five-fold cut in characters returns the same multiple in latency.

## What the gate actually checks

Hover over any chip and its legal basis appears. The five rules are not ours; they come from the guideline text as revised on April 9, 2026, which we confirmed to be the current revision by scanning the full amendment history, down to line numbers. Possible loss of principal, no deposit insurance, past returns not guaranteeing future returns, gains and losses belonging to the investor, and a warning when the product exceeds the customer's risk profile.

While an answer is being generated, a pinned bar at the bottom shows the real stage: the model generating, the answer rendering, the gate judging. The stages are driven by signals the server emits at the actual moments.

![The pinned progress bar showing generation stages](/assets/images/finance-demo-01-thinking-bar.webp)
*The label admitting that the typing effect is a UI flourish stays on screen. Answers arrive complete; the server streams the characters.*

## Draft checking, no model required

The second tab never calls a model. Paste a draft response or a marketing line, and the gate alone marks the missing disclosures.

![The draft-check tab flagging four missing disclosures in a sales pitch](/assets/images/finance-demo-04-draft-check.webp)
*"A product that fits your profile just came out" — the code shows on the spot what that sentence leaves out.*

Starting next January, monetary penalties for financial investment advertising take effect in Korea. A tool that catches omissions before copy ships is useful regardless of any model rollout, so this tab runs on the rule engine alone.

## The ThakiCloud angle

We could stand this demo up in a day because the parts already existed. The gate is the exact code used in the evaluation three days ago, and the model serves on in-house GPUs from a single manifest. Turning regulation text into a code gate means evaluation and demo share one yardstick, and in an on-premises customer demo you can answer "which line of the guideline says so" with a number.

## What not to trust yet

The response times on screen are moment-in-time values; the endpoint is shared and load-dependent, and the repeated-measurement ledger remains the source of truth for performance claims. The gate is a set of regular expressions built from guideline phrasing, so a genuinely novel wording could slip past it, and that limitation is printed in the demo's own footer. And the demo judges disclosure presence, not the factual accuracy of prices or product details; that axis belongs to retrieval.

The demo runs locally in our internal environment, and each captured screen is stored together with a record of the server state at capture time.
