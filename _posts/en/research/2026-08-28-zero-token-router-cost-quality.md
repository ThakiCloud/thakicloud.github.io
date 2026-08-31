---
title: "Check the Answer Key Before You Call the Teacher: What a Zero-Cost Router Saves"
seo_title: "Zero-Token Skill Routing: Costing Out Savings Without Losing Quality - Thaki Cloud"
seo_description: "We worked out where an agent should send its small, repeated decisions among an answer key, a small model, and an expensive frontier model. The post walks through how far the answer key needs to grow before the expensive model is never needed, and how much that saves, plus how to check the numbers for real."
excerpt: "Solving a problem means choosing between the answer key, a classmate, or a call to the tutor. Agents make the same choice for their routine decisions. As the answer key covers more, the point where the call to the tutor disappears arrives, and savings jump right there."
date: 2026-08-28
last_modified_at: 2026-08-31
tags:
  - skill-routing
  - model-tier-selection
  - cost-quality-tradeoff
  - zero-token-routing
  - deterministic-skill
  - token-cost-optimization
  - agent-harness
  - unattended-automation
  - router-evaluation
  - paxis
categories:
  - research
author_profile: true
toc: true
toc_label: "Contents"
lang: en
permalink: /en/research/zero-token-router-cost-quality/
canonical_url: "https://thakicloud.com/tech-blog/en/research/zero-token-router-cost-quality/"
audiobook: "https://drive.google.com/file/d/1MciQ-qVIEYVUb0OHBmB__rufUWgikbun/view"
audiobook_label: "▶ Listen: 5-minute briefing"
audiobook_note: "NotebookLM audio overview (AI-generated)"
---

Sending an agent's small, repeated decisions to a free method, whenever the answer is already known, can cut costs by a lot. Once the share of already-solved cases crosses a line, a point appears where you never need to call the expensive AI at all, and savings jump right there. This is worth your time if you run unattended agents or own their cost.

This post introduces a paper our research team wrote autonomously. It is called Zero-Token Routing, and it solves in advance, by formula, where to send small repeated decisions so cost and accuracy both hold. Every number in this post is not yet a real measurement. It is a value computed under a few assumed conditions, and we want to say that up front.

![A visual metaphor for check the answer key before you call the teacher](/assets/images/zero-token-router-cost-quality-hero.webp)
*A visual metaphor for the article's key idea.*

## In plain terms

Think about homework. When you get stuck on a problem, you have three options. Look up the answer key at the back of the book, ask the classmate next to you, or call your tutor.

The answer key is free and instant, but it only covers problems printed in that book. A classmate is easy to ask but sometimes wrong. A tutor is almost always right, but every call costs money.

An agent works the same way. A predefined, deterministic method the company built in advance is the answer key. A small model the company runs itself is the classmate. A big, expensive model out in the world is the tutor. Until now, even the smallest decision has gone straight to a call with the tutor.

The paper asks one question. As the answer key covers more problems, how much can we cut calls to the tutor, and how much money can we save without letting accuracy drop?

## What we did

We put the answer key, the classmate, and the tutor into a single accounting. We set a rule for which one handles each problem, then solved by formula how total cost and total accuracy move as that rule changes. The answer key's real name here is a skill. The classmate is a small model the company runs itself, and the tutor is a large, expensive model out in the world.

Every cost-cutting method so far has only adjusted how the tutor gets called. Ask several candidates in sequence, ask several at once and vote, or learn which one to ask first. All of them still place a call to someone, every time.

![Diagram of a three-way routing structure that splits tasks among the answer key, the classmate, and the tutor](/assets/images/posts/research/zero-token-router-cost-quality/fig3_three_arm_routing.webp)
*A conceptual diagram. Every task passes the check first. Tasks the answer key covers go to the answer key, and the rest split between the classmate and the tutor. Once the answer key's coverage crosses a line, the tutor's share disappears entirely.*

What this paper adds is a check. It looks only at whether a problem's ID appears in the answer key, matching words and numbers without calling any model. If it is there, the answer key handles it on the spot; if not, the task goes to the classmate or the tutor. Because that check never calls a model, its cost sits close to zero.

The order of the three methods is fixed. Cost rises from the answer key to the classmate to the tutor, and accuracy is lowest for the classmate, middling for the answer key, and highest for the tutor. The answer key beats the classmate on the problems it covers, but it is not as general as the tutor.

The check itself is not new; we had already verified it. We had confirmed that compressing this check barely hurts accuracy, and this paper computes, on top of that, how much dollar value the answer-key method it protects can create.

The example numbers we plugged in were these: tutor accuracy 90 percent, answer-key accuracy 85 percent, and classmate accuracy 70 percent. The check cost sat near zero, and the tolerance was 10 percent.

## What came out

### When the tutor becomes unnecessary

The cheapest way to solve any problem, the math showed, is always to let the answer key handle every problem it covers. Handing a covered problem to the classmate or the tutor only raises cost and lowers accuracy, so there was never a reason to do it.

The real question is how far the answer key has to grow before the tutor becomes unnecessary. Under the example numbers above, once the answer key covered a bit more than seven problems in ten, the tutor's share dropped to zero.

We also computed the savings along the way. At half coverage, savings were already around 80 percent, and once coverage passed the point where the tutor drops out, savings rose to nearly 99 percent.

In plain terms, filling even half the answer key already saves a lot of money, and filling the rest of it makes the call to the tutor disappear entirely.

![Savings rate against answer-key coverage, with the kink marked](/assets/images/posts/research/zero-token-router-cost-quality/fig1_savings_kink.webp)
*A schematic of the closed-form computation, not a measurement. Savings rates are drawn against coverage at classmate-to-tutor cost ratios of 2%, 5%, and 10%. At 50% coverage the rates are 81.9%, 80.9%, and 79.3%; at a 5% cost ratio, savings reach 98.7% right at the 73.3% threshold. At 10% coverage, 52.8% of uncovered problems still went to the tutor; at 70% coverage, only 8.3% did.*

Loosen the tolerance and the point where the tutor drops out moves lower. Tighten it and that point moves higher. Tighten it enough, and the answer key alone can no longer meet the accuracy bar at any coverage.

Checking the answer key is not entirely free either. But even pricing that check as generously as a call to the tutor, it still comes to under 1 percent of the total savings.

### What it is worth to add one more answer

Adding one more problem to the answer key also has a price. While the tutor is still needed, one newly added problem is worth close to a full call to the tutor. Once the tutor is no longer needed, a new problem only replaces the classmate, so its value drops sharply.

![Marginal value of one added point of answer-key coverage](/assets/images/posts/research/zero-token-router-cost-quality/fig2_marginal_value.webp)
*A schematic of the closed-form computation, not a measurement. The marginal value of one added point of coverage is drawn. Below the 73.3% threshold, a new answer is worth close to one tutor call and decays as the threshold nears. Above it, the value flattens at the classmate's lower cost.*

The rule that follows is simple. Write new answers first for the problems the current setup still sends to the tutor. Writing one is worth it only when its cost is lower than the value it will earn back.

The answer key is not a one-time fill, though; it is upkeep. A nightly repair loop turns failed routing into new entries and grows coverage, while stale entries and worse search drag it back down. Even a version we split by hand, as carefully as we could, reached only 63.6 percent coverage on a real production harness. That harness held over 1,600 skills and a mix of Korean and English requests.

## What to change

First, write new answers for the repeated decisions that currently go to the tutor. Which ones those are shows up directly in today's routing logs.

Second, verify this math with real measurements instead of trusting it as is. Confirm the answer-key method really never calls a model by counting actual calls, and price the classmate and the tutor both ways: self-hosted cost and public list price.

Third, treat answer-key upkeep as ongoing work, not a one-time project. The nightly repair loop grows coverage while stale entries keep eating into it, so maintaining coverage has to continue even after the tutor drops out.

Fourth, this structure comes with a bonus. The share handled by the answer key runs on our own hardware with no outside AI call. It keeps working even if the tutor's service slows down or goes offline. A small team that moves most of its routine decisions this way can run an unattended fleet on a fraction of the cost.

## What not to trust

First, the tolerance has a floor. Tighten it past the accuracy gap between the answer key and the tutor, about 5.6 percent at the example values, and no coverage level can meet the accuracy bar.

Second, this model splits tasks into only two buckets, covered and uncovered, and boils accuracy down to one number. Latency, service-level promises, accuracy drift over time, and errors compounding across turns are not in this math.

Third, every number here is a computed value under assumed conditions. Until the measurement protocol actually runs, trust the structural conclusions, such as filling the answer key first, and treat the numbers as rough order of magnitude.

Fourth, coverage does not sit still. The nightly repair loop grows it, but stale entries and worse search shrink it back, so keeping coverage up has to continue even after the threshold is crossed.

Fifth, the cost of writing a new answer enters the math through one break-even rule only. A full cost model for authoring answer-key entries is still open.

Sixth, the whole computation assumes the classmate never gets nearly as cheap as the tutor per point of accuracy. If the classmate becomes cheap enough to break that assumption, filling the answer key to the max may no longer be the best policy.

---

The full paper is here: [https://huggingface.co/datasets/thaki-AI/daily-paper-2026-08-28-zero-token-router-cost-quality](https://huggingface.co/datasets/thaki-AI/daily-paper-2026-08-28-zero-token-router-cost-quality)

*Every number in this post is a computed value under conditions the paper explicitly assumes. They are not replaced by real measurements until the paper's protocol runs.*
