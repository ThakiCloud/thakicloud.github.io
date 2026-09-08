---
title: "It Warned Every Time but Rarely Refused: Re-Measuring Suitability as Action"
excerpt: "A model that spoke every mandatory warning still kept selling on risky requests. The fix was not more training data but better data, and it lifted the suitability action pass rate from 8.0% to 81.8%."
categories: [research]
tags: [compliance, finetuning, suitability, korean-llm, financial-ai]
toc: true
canonical_url: "https://thakicloud.com/tech-blog/en/research/suitability-behavior-gap/"
---

If you already checked this model's disclosure compliance, here is one more fact worth knowing. Our earlier measurement only asked whether the model spoke the warning. It never asked whether the model actually stopped the sale.

![Illustration of the core idea of It Warned Every Time but Rarely Refused: Re-Measuring Suitability as Action](/assets/images/suitability-behavior-gap-hero.webp)
*A visual metaphor for the article's key idea.*

## Plain terms

Picture a bartender who keeps serving a customer who is already drunk. Reading the warning label on the bottle is one thing. Telling the customer no more drinks tonight is another. The bartender read the label almost every time. The pouring stopped once in ten. Showing three times more drunk-customer examples did not teach refusal. Showing fewer examples, each one actually ending in a refusal, did.

## It warned. It did not stop the sale.

Our earlier gate only checked whether a disclosure appeared in the answer. This time we added a second axis. When a customer asks for a product too risky for their profile, does the model refuse, offer an alternative, or route them to a human advisor? Sixty such risky requests went through the earlier model under this new axis. Only six of them ended in an actual stop. That is one in ten.

![Funnel diagram comparing 60 risky product requests: how many included the disclosure text versus how many actually stopped the sale, showing most included the warning but only 6 stopped the sale](/assets/images/suitability-behavior-gap-fig-01.webp)
*Saying the warning and stopping the sale are two different axes.*

The cause was not the amount of data. It was one missing sentence. The instruction given to the teacher model said to include the warning. It never said to stop the recommendation. The model learned exactly what it was told, no more.

## What came out

Our first attempt was to add more examples. We scaled up the training examples for unsuitable recommendations to 431, a 3.4x increase over the original. The action pass rate, measured across repeats, still landed at only 8.0%. When we opened those examples, only 5.8% of them actually ended in a refusal or an alternative. The rest just explained the risk and kept selling. We had taught the bad habit three times harder.

| | Training examples | Share that actually refused | Model action pass rate |
|---|---|---|---|
| First attempt | 431 (3.4x scale-up) | 5.8% | 8.0% |
| After the fix | 237 | 100% | 81.8% |

Instead of adding more, we cut the example count from 431 to 237 and rewrote every single one to end in an actual refusal, alternative, or handoff to a human. Quality came before quantity. Two more rounds of cleanup, a corrected training batch and a relabeled evaluation set, brought the final pass rate to 81.8%.

![Bar chart comparing training example count, action quality of those examples, and model pass rate for the first attempt (431 examples, 5.8% quality, 8.0% pass) versus the fix (237 examples, 100% quality, 81.8% pass)](/assets/images/suitability-behavior-gap-fig-02.webp)
*Fewer examples, higher quality, and the pass rate climbed.*

We confirmed this with a paired McNemar test on the same 33 questions, run three times, and every run came back significant. But only 33 questions were judgeable at all, so the three repeats swung by up to 21.2 percentage points. A single number like 81.8% could not settle it. The paired comparison could.

As a side effect, factual errors dropped from three to zero, and disclosure coverage rose from 88.5% to 90.5%. Over-refusal on legitimately suitable requests stayed at 4.4%, well under our 20% threshold. Bullet lists and bold formatting stayed at zero, same as before.

## The ThakiCloud view

We added this second axis because our on-premise customers do not ask whether the model included a warning. They ask whether it actually stops a risky order. Those two questions sound similar but have different answers. Cutting the training data while raising its quality is also a lesson we will carry into the next axis we test: check example quality before example count. Reviewing the judging gate side by side with the data-generation instructions is now part of our habit too.

## What not to trust yet

Only 33 questions were judgeable for suitability action, so three repeats alone swung the value widely. Do not cite 81.8% as an absolute number. Trust only the paired comparison. Reaching five-percentage-point precision on an absolute value would need roughly 380 questions. The relabeling used an LLM judge, so a rerun could land on a slightly different number.

Over-refusal rose sixfold, from 0.8% to 4.4%. That is well under our 20% ceiling, but the direction is worth watching. Factual errors sit at zero or one per 200 cases, so even a "zero" verdict rests on a small sample. And weights alone only reach 90.5% disclosure coverage. Reaching 100% requires shipping the judging gate alongside the weights, always.

## Source

The public repository is ThakiCloud/Qwen3.8-27B-Human-KO-Finance, released under Apache-2.0. Do not take the weights alone; use the repository form that ships with the judging gate. This measurement builds on [the post that first measured the disclosure text](/tech-blog/en/research/style-tuning-hurts-compliance/) and [the live demo](/tech-blog/en/research/disclosure-gate-live-demo/), adding a new axis for whether the model actually stopped the sale.

- [Korea Financial Investment Association standard sales guidelines](https://law.kofia.or.kr/service/law/lawFullScreenContent.do?seq=149&historySeq=428)
