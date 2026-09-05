---
title: "Same GPU, Same Model, Opposite Settings"
excerpt: "A serving endpoint's concurrency setting is not a constant. We measured the same model on the same card at two endpoints and the recommendations came out reversed. What decided it was request length, not hardware."
seo_title: "vLLM inference tuning measured: max_num_seqs is your KV pool divided by request length"
seo_description: "A 27B model quantized to 4-bit on one B200, measured from 1 to 256 concurrent requests. One kind of layer held 99.5 percent of the cache; halving its number format doubled capacity."
date: 2026-09-05
published: true
categories:
  - llmops
tags:
  - inference
  - serving
  - vllm
  - quantization
  - speculative-decoding
  - metis
author_profile: true
toc: true
toc_label: "Contents"
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/inference-tuning-is-measurement/"
---

We had to configure the same model, on one GPU, two different ways. If you run an inference server and have wondered what to set the concurrency limit to, this post has an answer. The short version is that the number is not a constant. Your request length decides it.

## Plain terms

Think of your server's memory as a parking lot. The space where the model keeps the conversation is the lot's area, and each request is a car. A separate setting decides how many cars you let in at once, and that setting is the subject of this post.

There is a trap here. Two lots of identical area hold very different numbers of cars if one gets compacts and the other gets coaches. Yet many teams set this value once and leave it, as if the vehicle mix did not matter.

In plain terms: do not copy a concurrency setting from someone else's deployment.

## What we did

We put a 27-billion-parameter model on a single NVIDIA B200, compressed to 4 bits. That compression is called quantization, and it is what makes the model fit on one card.

The model's layers are not alike. Of its 64 layers, only 16 need more memory as the conversation grows. The other 48 use a fixed amount regardless of length. That is why a one-million-token context fits on a single card. A conventional model where every layer grows would need 137 GB, which does not fit.

We also attached a drafter. A small model proposes several next tokens and the large model verifies them in one pass. In our measurements about three proposals in ten were accepted, and each pass produced 3.4 tokens on average.

Then we measured both endpoints from 1 to 256 concurrent requests. We changed one setting at a time, because otherwise you cannot say what caused what.

## What we found

**Raising the context limit cost no memory.** This was the surprise. The endpoint serving one million tokens used less working memory than the one serving 240 thousand, and it got a larger cache. Advertising a long context is free. The price shows up in time to first response, not in memory.

**Raising the concurrency limit cost no memory either.** We took the setting from 8 to 32, a factor of four, and the cache moved by 0.03 percent. This is not because the model reserves the space up front. It is because the part that varies with slot count is only half a percent of the cache to begin with.

**So the bottleneck differed by workload.** The endpoint serving short requests had cache to spare and was limited by slots, so raising them lifted throughput sharply. The endpoint serving long requests had the opposite problem: one request is a coach, and the lot filled first. Raising slots there made things worse.

**One kind of layer owns 99.5 percent of the lot.** We counted what actually occupies the cache. The 16 layers that grow with conversation length held 99.5 percent of it. The other 48 layers held 0.5 percent. That single line decides which knob is worth touching.

**Halving that one kind doubled the lot.** We switched the number format the cache is stored in to one half the width. It is the same as narrowing every parking bay to fit twice the cars in the same area. One endpoint went from 2.10 to 4.54 million tokens, the other from 1.46 to 2.72 million. Simultaneous one-million-token requests went from 2.1 to 4.5.

**The drafter came through intact.** We expected the narrower format to hurt how often draft tokens are accepted. After the change acceptance stayed between 30 and 37 percent, at 3.1 to 3.6 tokens per pass. That matches the figures from before.

**Spare memory is margin, not waste. We broke that rule once.** The engine offers to spend every remaining byte and prints the exact figure. After switching formats we used that figure as printed, and the server never came up. It crash-looped, one gigabyte short. The figure had been measured under the old format, and the new one needs slightly more elsewhere. We settled on a value that leaves 6 GB free.

In plain terms: pushing a setting to its maximum and tuning it correctly are different jobs.

## The numbers

Measured on one card after tuning, in output tokens per second, median of five runs per step. These figures come from the wider cache format. Throughput under the narrower one is not in yet.

| Concurrent | Total throughput | Per request | First response |
|---|---|---|---|
| 8 | ~1,500 tok/s | ~263 tok/s | 0.8 s |
| 32 | ~2,500 tok/s | ~120 tok/s | 5.1 s |
| 128 | ~2,870 tok/s | ~42 tok/s | 20.0 s |
| 256 | ~2,900 tok/s | ~30 tok/s | 30.1 s |

One card saturates near 2,900 tokens per second. If your bar is "every request gets at least 100 tokens per second", that holds to 32 concurrent users and collapses by 128.

In plain terms: this single card serves 32 people at once, each faster than they can read.

## What to change

The rule we ended up with is one line. **Your concurrency limit is the cache size divided by your typical request length.** Copy someone else's number, or leave the default, and you will be wrong in one direction or the other.

That means measuring your own vehicle mix first. Counting our real traffic, about seven requests in ten were under 200 thousand tokens and the remaining three fell between 200 and 500 thousand. Nothing exceeded 500 thousand. You cannot pick the setting without knowing this.

Set your bar on per-request speed rather than total throughput. Total throughput keeps climbing as you add concurrent users, while the experience of any individual user falls apart underneath it. The 128-user row above is exactly that state.

Count what occupies the cache before you touch any setting. It is layer count times the bytes one layer spends per token. Guess at the structure instead and you will reach for the wrong knob. That one multiplication tells you which knob doubles the lot.

One diagnostic to take away. If you raise concurrency and the time per token does not change, you are measuring overhead rather than computation. We saw that signature twice, and both times it was a configuration problem rather than a hardware limit. It is worth checking on your own engine.

## What we cannot claim

The request-length distribution comes from 693 requests over four hours. More samples may move it.

The low-concurrency measurements varied noticeably between repeats. The drafter's acceptance rate depends on the prompt, so this is expected; at 32 concurrent users and above the spread settles to between 1 and 8 percent. Quote individual figures from that range rather than the low end.

Quality after the format change was checked with five prompts. One answer matched byte for byte and the rest differed only in wording. Five prompts support "nothing broke" and nothing stronger. They are not evidence of no loss.

One thing we have not measured. The one-million-token context is opened by stretching the model's native 260 thousand, and we have not checked whether that stretch costs quality on ordinary-length answers. Since most of our traffic is short, this matters to us too. It is the next experiment.

## Where this sits in Metis

Metis is our inference serving layer. What this post demonstrates is not a benchmark score for one model but **a procedure for fitting settings to a workload**. The fact that the same card, the same model and the same engine produced opposite recommendations is the argument for having that procedure.

The tuning is not an end in itself. When Paxis automates a piece of work, how long one agent run takes and what it costs are settled in this layer. Lowering the price per token and protecting the speed a user feels meet here.

Every figure above is recorded in our measurement ledger, and each was checked by a gate that decides whether it is quotable before it appeared in this post.
