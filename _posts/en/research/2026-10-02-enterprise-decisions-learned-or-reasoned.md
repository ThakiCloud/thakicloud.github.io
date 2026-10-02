---
title: "When the Rulebook Changes, the Agent Has to Think Again"
seo_title: "Enterprise policy decisions: what to learn and what to reason - ThakiCloud"
seo_description: "We separated two things usually bundled together in an enterprise agent: generating the decision, and being allowed to reason before deciding. On familiar policies the generation step bought nothing. On unseen policies reasoning was decisive. We release the sealed 300-item benchmark, the proofs, and the weights."
excerpt: "A teller who has memorised the rulebook decides without thinking. Hand them a rulebook they have never seen and they have to read and reason. Our agent behaved the same way, and it memorised the boundaries we taught it while leaving the one we did not teach unchanged."
date: 2026-10-02
last_modified_at: 2026-10-02
tags:
  - enterprise-agent
  - policy-compliance
  - decision-model
  - test-time-reasoning
  - constrained-decoding
  - tool-use
  - benchmark-construction
  - preregistration
  - paxis
  - metis
categories:
  - research
author_profile: true
toc: true
toc_label: "Contents"
canonical_url: "https://thakicloud.com/tech-blog/en/research/enterprise-decisions-learned-or-reasoned/"
published: false   # 2026-10-02 중복으로 내림 — _data/retired_urls.json 에 리다이렉트 등록
---

What an enterprise agent needs is not the ability to produce sentences. It is time to think. On policies it already knows, it did not even need that. On policies it had never seen, turning thinking on was worth more than anything else we changed.

If you build agents that run on internal documents, or you pay for the latency they cost, this is for you. This post introduces a paper we wrote, along with the benchmark and the weights we released with it.

![Accuracy on unseen policies across configurations](/assets/images/pace-enterprise-ladder.webp)
*Every bar is the same checkpoint on the same sealed items. Only the bottom bar is allowed to reason.*

## In plain terms

Picture a bank teller. One who has worked there for years knows the rulebook by heart. The customer barely finishes speaking before the teller knows what to do: give the balance, ask for more identification, or hand it to a supervisor.

Now send that teller to a branch with a rulebook they have never seen. Same person, but now they have to read and work it out. Nothing was memorised, so thinking is all that is left.

Our agent behaved exactly the same way. Throughout this post, "thinking" means the model working the problem out internally before it commits to an action. It is the teller leafing through the rulebook.

## What we did

The agent reads a customer turn and picks one of seven actions: answer from the policy, ask for a missing fact, ask for confirmation, call one tool, call several tools, hand it to a human, or refuse. That choice has to be settled before a single word is said.

Current practice **generates** that choice. The model writes out a small document saying "the action is a tool call", character by character, and a downstream system reads it and executes. Writing characters takes time, and the same question does not always produce the same document.

We separated two things. The first is **how the answer comes out**: as a written document, or as one character pointing at one of seven options. The second is **whether thinking is on**. Teams usually switch both off together when cutting cost, and when quality drops they blame whichever one happened to be on their mind.

![Thinking on and thinking off, across two output formats](/assets/images/pace-enterprise-two-by-two.webp)
*The vertical gap is the effect of reasoning. The horizontal slope is the effect of the output format.*

### Nobody wrote the answers

We first built items on top of real statutes and had two commercial models label each one independently. They agreed poorly on both pools we tried. Both runs also abstained on roughly 30% of items and neither finished its checking stage, so read that as a method failing to converge rather than as a clean reliability number.

The clearer signal was what the judges picked. On the items meant to probe whether a tool is needed, they chose "call a tool" on **3 of 348** and "just answer" on 182. The boundary we intended had never made it into the text. It lived in our heads and in our selection criteria.

So we stopped writing items and started **computing** them. A hidden policy is a handful of switches: does this need live state, is a required fact missing, is there a side effect that needs confirmation. Give the switches and a program derives exactly one correct action, along with the reason it is correct.

In other words, **no one wrote the answers**. Set the switches and the answer follows.

The Korean text a reader sees was written by models outside the evaluated family, and those models never saw the answer. Only items that passed machine checks survived: no answer leaking into the text, counterfactual pairs differing in exactly one switch. We built 300 of them, hashed the contents, and sealed them before running any model.

## What came out

On familiar policies the two formats were effectively identical: 93.5% for the written document, 94.1% for the single character. What differed was stability. Restart the server and ask again, and the generated decisions changed for about 3 items in 100, while the single-character decisions changed for about 3 in 1,000. The latency difference nearly vanished.

In other words, on familiar policies the generation step **cost something and bought nothing**.

On unseen policies it reverses. Turning thinking on moved accuracy from 70.7% to 88.0%. Changing the output format was worth **0.0 points**. Everything that mattered was reasoning, and none of it was the format.

Here is where we nearly fell over. In our first comparison only the document-generating arm had thinking enabled. Read as-is, we would have published the **wrong cause**: that generating the document is what helps.

### Teaching works, but only where you taught

There are two reasons reasoning might be needed. The boundary may genuinely require working through, or the model may simply never have been taught it. If it is the second, data fixes it.

So we compared a model taught on the boundaries specifically against one given the **same number of tokens** of ordinary data. Matching the budget is what lets us say the kind of data mattered, not the amount. We also wrote down the decision rule and sealed it before looking.

![Per-boundary accuracy for the two arms](/assets/images/pace-enterprise-boundaries.webp)
*The two boundaries we taught open up. The untouched one at the bottom does not.*

The taught boundaries clearly improved: 17.5 points where answering meets calling a tool, 20.0 points where calling a tool meets asking for confirmation. Missed tool calls dropped noticeably.

The boundary we **deliberately did not teach** was different. Refusing versus escalating moved 4.4 points, with an interval that contains zero. That is not a size we can call an improvement.

In other words, **the boundaries we taught were learned and the one we did not stayed put**.

Overall accuracy reached 79.2%. The same model allowed to reason reaches 88.0%, so 8.8 points remain. You can see both what the data recovered and what it did not.

## What to change

If a feature runs on policies that are already familiar, do not generate the decision. When the options are fixed, pointing is enough, and it is faster and steadier. Running this configuration on **Metis**, our inference product, removes nearly all of the response time.

Where customer policies change, or new customers arrive, do not switch reasoning off. What you save there comes back as wrong decisions.

It also helps to accept that there are two budgets. Boundaries you can name in advance get a **data budget**. Boundaries that arrive with the next customer's rulebook get a **compute budget**. They are not interchangeable. In **Paxis**, our work-automation product, that distinction drops straight into operational design.

We also measured routing: reason only on low-confidence items. Reasoning on half of them reached 85.7%. It saves something, but less than you would hope, and the reason is clear. On unseen boundaries the model is **confidently wrong**, and confidence cannot filter that.

## What not to trust

One model, one language, one task family.

The benchmark is built from policies we invented. That is what lets us defend the answers, and also what limits it. A model can do well here and still struggle with a real company's documents.

The configuration that both generated text and reasoned was not reproducible: a rerun changed some decisions. Treat those cells as single runs.

The pair-based metric rests on only 30 pairs and varied across seeds, so we wrote it as "positive but not something we can assert".

Finally, publishing this benchmark means it can be **contaminated**. Put it in training data and its life as a test set ends. We published anyway because we have already used it to design our next method, which disqualifies it as our own test set whether or not we publish. Given that, we would rather let others recompute our numbers.

---

The benchmark and its proofs are at [EnterpriseOps-KO Blind-A](https://huggingface.co/datasets/ThakiCloud/EnterpriseOps-KO-Blind-A); the models are on the [ThakiCloud organisation page](https://huggingface.co/ThakiCloud). The training corpus is not released: it derives from internal and licensed sources.
