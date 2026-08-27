---
title: "We Quadrupled the Chunk Size and TTFT Moved 0.4%"
seo_title: "Your serving benchmark's p99 TTFT is set by the load generator - burst vs Poisson arrivals measured on B200 | ThakiCloud"
seo_description: "A benchmark firing 128 requests at once reported a p99 TTFT of 5.38 seconds. The same endpoint under Poisson arrivals carrying 91% of that throughput reported 0.477 seconds. Here is why quadrupling the chunk size changed nothing, and why the binding constraint moving from TTFT to TPOT changes which knob you should reach for."
excerpt: "We raised the chunk size from 8,192 to 32,768 and p99 TTFT went from 5.380 seconds to 5.401. The knob was not broken. It was never the knob's problem. It was our load generator."
date: 2026-08-27
tags:
  - vLLM
  - serving benchmark
  - TTFT
  - TPOT
  - chunked prefill
  - Poisson arrivals
  - queueing
  - B200
  - NVFP4
  - LLMOps
  - performance measurement
categories: [llmops]
author_profile: true
toc: true
toc_label: "Contents"
toc_sticky: true
reading_time: true
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/serving-benchmark-load-generator-artifact/"
---

If you run vLLM benchmarks and report a p99 TTFT, that number is more likely measuring your **load generator** than your model. On a single B200 we found that changing only how requests arrive moved the tail by a factor of eleven. The more awkward part came next: the identity of the bottleneck changed, and with it the knob worth reaching for.

## The experiment where nothing happened

It started as an ordinary optimization. At concurrency 128 the p99 TTFT came in at 5.38 seconds against a 1.5-second target, far over. Inter-token latency, meanwhile, sat at 25.6 milliseconds with budget to spare. Only the first token was late; everything after it was fine.

There is a textbook prescription for that. Raise the chunk size for chunked prefill. Pushing prefill through in larger pieces gets the first token out sooner. The cost lands on decode, which waits behind those larger pieces. With room in the inter-token budget, trading some of it for TTFT looked like a clean deal.

We brought up a second endpoint with the same model and the same tuning, changing only the chunk size from 8,192 to 32,768, and confirmed in the engine log that the knob had actually taken effect.

| Chunk | Throughput | p99 TTFT | Energy per token |
|---|---|---|---|
| 8,192 | 3,434 tok/s | 5.380 s | 0.283 J |
| 32,768 | 3,366 tok/s | 5.401 s | 0.286 J |

**It got 0.4% worse.** A fourfold increase moved the number only below the decimal point.

## Why it did not move

The knob was not broken. The amount it could touch was fixed before it ever got a turn.

Our benchmark fires 128 requests **simultaneously**. With 2,048 input tokens each, 260,000 tokens of prefill pile up the instant they land. That total is independent of chunk size. Chunking decides **how the work is sliced**, not **how much of it there is**.

And p99 TTFT is when the request **at the back of that line** receives its first token. The one at the back waits for every prefill ahead of it. Change the slicing and the total ahead of it stays the same, so its wait stays the same.

Chunk size is a knob for **how finely you interleave**. It is not a knob for shortening the line. We had a long-line problem and reached for an interleaving knob.

## We formed that line ourselves

Which turns the question around. Why did 128 requests arrive at the same instant?

Because in a real service they do not. Users send requests on their own schedule, and the gaps between them are usually close to exponential. A hundred and twenty-eight people pressing a button in the same millisecond is a situation a load-testing tool creates, not one traffic creates.

So we changed the arrival process and nothing else. The request itself was untouched: same prompt, same output length, same endpoint, now fed at exponentially distributed intervals.

| Arrival | Throughput | p99 TTFT | p99 TPOT |
|---|---|---|---|
| 128 at once | 3,434 tok/s | **5.380 s** | n/a |
| Poisson, 12/s | 3,113 tok/s | **0.477 s** | 71.7 ms |

**Eleven times better tail latency while carrying 91% of the throughput.**

Not because the load was lighter. By Little's law the Poisson side was in fact holding more requests in flight on average. The queue was not shallower; the line simply never formed all at once. When arrivals spread out, prefill spreads out with them, and the notion of a request stuck at the back blurs.

## The genuinely awkward part

More important than the better number is what changed underneath it: **the metric that binds is a different metric.**

Under simultaneous arrival, TTFT broke the SLO and inter-token latency had room. Under Poisson it is the reverse. At 12 arrivals per second TTFT sits comfortably at 0.477 seconds while TPOT reaches 71.7 milliseconds and blows the budget. The first token arrives quickly and the ones after it stutter.

When the bottleneck changes identity, the prescription changes with it.

If TTFT binds, the problem is prefill capacity. You separate prefill from decode onto different replicas, or you shape admission. If TPOT binds, the problem is on the decode side. You look at batch composition, scheduling, and execution-speed axes such as GPU clock. Those are entirely different pieces of work, and entirely different weeks.

Had we planned a roadmap from the simultaneous-arrival measurement alone, we would have spent weeks separating prefill to relieve a bottleneck that does not exist in production traffic, and discovered the absence only after shipping it.

## We knew, and got it wrong anyway

Let me drop one excuse here. The objection that simultaneous arrival is a worst-case corner and that this is textbook queueing theory is correct.

Our own product requirements document says to use **constant, Poisson, and burst traffic alike.** We wrote that sentence. And we still measured only the worst-case corner and drew a product conclusion on top of it: that this operating point sits outside the SLO.

That we read it and got it wrong anyway is, I think, evidence that it is not self-evident in practice. Most benchmark tools default to firing a fixed concurrency of N. It is convenient, and the numbers come back reproducible. Reproducible numbers and meaningful numbers are not the same thing.

## What to do instead

Three suggestions.

**First, report the arrival process alongside the result.** "p99 TTFT of 5.4 seconds" is half a sentence. "p99 TTFT of 5.4 seconds under a 128-request simultaneous burst" is a whole one. We have decided not to cite a latency or a savings rate at all unless the load model and the SLO threshold travel with it.

**Second, re-establish the identity of the bottleneck every time.** That TTFT was the constraint last time does not make it the constraint now. Change the shape of the load and the identity changes. Before choosing a knob, find out what exhausts its budget first.

**Third, measure near saturation separately.** Our capacity was 13.4 requests per second, and at an arrival rate of 13.5 the median TTFT jumped from 0.25 seconds to 2.07. Everything up to 12 is perfectly calm. Measure only the calm region and you will set your operating headroom standing right at the edge of a cliff.

## How this lands in Metis

We folded this measurement into the operating rules for Metis, our inference serving platform. When we promise a tenant throughput and latency, the load model those numbers came from travels with them, and capacity planning now leaves headroom before the saturation knee. In on-premise or sovereign deployments, where you cannot paper over a problem by buying more GPUs, that difference converts directly into cost. Few misunderstandings are as expensive as adding GPUs to relieve a bottleneck that is not there.

## Boundaries

Some honesty is owed. This is **one B200, one model, one workload shape**. Each arrival rate was measured once, so the individual percentages are not citation-grade, and this article deliberately omits the savings figures. An elevenfold gap is not a size that repeat variance overturns, so we report the direction only. Repeated measurement is the next task.

During the runs, other GPUs on the same node were also busy. GPU power is isolated per device, but CPU and PCIe are shared, so the latency figures carry less confidence than the power ones.

The setup was a single B200 with a Qwen3.8-27B NVFP4 checkpoint on vLLM 0.24, fixed at 2,048 input and 256 output tokens. The raw measurement records live in our whitepaper repository's measurement ledger with sha256 alongside. The decision criteria were fixed in a document before the measurement and were not revised afterwards.

## References

- [vLLM Metrics](https://docs.vllm.ai/en/latest/design/metrics/). the TTFT and TPOT quantiles in this article come from the histograms vLLM exposes directly. Start here to read the same values off your own stack.
- [vLLM Optimization and Tuning](https://docs.vllm.ai/en/latest/configuration/optimization.html). the official account of what chunked prefill and `max_num_batched_tokens` actually control.
- [vLLM Disaggregated Prefilling](https://docs.vllm.ai/en/latest/features/disagg_prefill/). the prefill/decode split you reach for when TTFT genuinely is the bottleneck.
- [Little's law](https://en.wikipedia.org/wiki/Little%27s_law). the basis for saying the Poisson side carried the heavier load. Mean requests in flight is arrival rate times residence time.

