---
title: "Speculative Decoding Wasn't Slow. The Lookup Just Didn't Fit: 11.9x on the Same Model"
seo_title: "Speculative decoding re-measured: lookup vs learned drafter, B200 measured | ThakiCloud"
seo_description: "We overturned our own conclusion that speculative decoding was a net loss on free-form generation. Lookup drafting finds candidates inside the prompt, so it is powerless when writing new sentences, but a learned drafter predicts from hidden states. From 15.0 to 178.8 tok/s on a 234k-token prompt, 11.9x, all 34 quality metrics lossless, and the boundary past 245k where the server dies, measured on a single B200."
excerpt: "If you tried speculative decoding once while serving long contexts and shelved it, it is worth checking which method you actually measured. Lookup and a learned drafter produce completely different results under the same name."
date: 2026-08-23
tags:
  - speculative-decoding
  - vllm
  - dflash2
  - long-context
  - nvfp4
  - inference-optimization
  - serving
  - b200
  - llmops
  - benchmark
categories: [llmops]
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/speculative-decoding-lookup-vs-drafter/"
---

If you serve long contexts and tried speculative decoding once, only to shelve it with "it does not fit our workload", it is worth checking which method you measured. We did exactly that, and when we reopened the question, the problem was not speculative decoding but **the choice of method**. On the same model and the same GPU, 15.0 tokens per second became 178.8.

![The two candidate sources of speculative decoding, lookup and drafter, in an abstract form](/assets/images/speculative-decoding-lookup-vs-drafter-hero.png)
*Two different candidate sources under the same name, "speculative decoding": lookup searches inside the prompt, while the drafter predicts from hidden states.*

## The first conclusion was only half right

We serve a 27B model quantized to NVFP4 for long contexts. We layered speculative decoding on top and confirmed that on free-form writing tasks it was slower than the baseline. Acceptance length collapsed from 5.4~7.9 on copy-type tasks to 1.2~2.3, leaving only the verification cost of rejected drafts. So we concluded that "quantization has already removed the memory bandwidth bottleneck, so there is no room for speculative decoding to bite".

That explanation was plausible, and half right.

What we measured was the lookup family, two variants (suffix and n-gram). This family finds candidate tokens for the next position **inside the prompt**. On tasks that restate a document, the answer is right there, so it matches well; on tasks like summarization or reasoning, where you must write sentences that are not in the prompt, there is nothing to find. The collapse in acceptance length was not the model's fault nor quantization's fault. It was a question of **where the candidates come from**.

A learned drafter works differently. A small model predicts the next token by looking at the target's hidden states, so it can hit tokens that have never appeared in the prompt. So we put a DFlash2 drafter under the same conditions and measured.

<div class="mermaid">
flowchart TB
    A["Target model<br/>hidden states"] --> B["Drafter (small model)<br/>predicts the next K tokens"]
    B --> C["Target model<br/>verifies all K at once"]
    C -->|all match| D["Accept all K at once"]
    C -->|first mismatch| E["Keep the matching prefix<br/>regenerate from the mismatch"]
    D --> A
    E --> A
</div>

The core of speculative decoding is that the drafter writes K draft tokens and the target model verifies them together in a single forward pass. The lookup family simply puts a "search candidates in the prompt" rule into the drafter's slot, while a learned drafter puts a small model that reads hidden states into that slot. Same slot, different candidate source, and that is where the 11.9x difference comes from.

## 11.9x

A 234,063-token prompt, 3 warmups followed by 5 repeats, a single B200, an endpoint-to-endpoint comparison.

| Configuration | Output throughput | Re-run scatter |
|---|---|---|
| Current production (vLLM v0.24.0, no drafter) | 15.0 tok/s | 1.00x |
| Nightly engine + DFlash2 (K=7) | **178.8 tok/s** | 1.02x |

The re-run scatter is 1.00~1.02x on both sides. These are not values measured with several jobs running at the same time. They are direct comparisons between serving endpoints, so there is no contention.

This 11.9x is the result of two levers compounding. Swapping the engine from v0.24.0 to nightly alone gives 5.43x (15.0 to 81.4 tok/s), and the drafter adds roughly 2.2x on top of that. The 81.4 figure was measured with only one warmup, so the **internal breakdown is provisional**. What is confirmed is the 11.9x versus the current configuration.

## Quality is unchanged

Speculative decoding has a structure in which the target model verifies draft tokens and discards them if they are wrong. So the output distribution must be identical to the target model alone, and in theory it is lossless. But that is a property of the algorithm, not of a specific implementation, so we checked directly.

In an A/B test with the image, checkpoint, and tasks fixed and only the drafter toggled on and off, none of the 34 metrics showed a significant difference.

| Metric | Drafter OFF | ON | Diff | p |
|---|---|---|---|---|
| GSM8K strict | 0.5100 | 0.5017 | −0.83pp | 0.774 |
| HAERAE | 0.7617 | 0.7626 | +0.09pp | 0.971 |
| KoBEST | 0.6700 | 0.6715 | +0.15pp | 0.956 |
| belebele-ko | 0.9000 | 0.8983 | −0.17pp | 0.922 |
| IFEval prompt-strict | 0.3087 | 0.3068 | −0.19pp | 0.946 |

The smallest p-value is 0.774. The signs split roughly half and half, and on six metrics the values were identical to the decimal. But this shows "indistinguishable", not "identical". With 600 items per metric, we cannot catch small differences on the order of 4pp.

## Past 245k, the server dies

Read this before you enable it. We sent requests of increasing length to an endpoint whose context window was opened to 1M tokens.

| Prompt | Result | Acceptance length |
|---|---|---|
| 8,410 | normal | 1.46 |
| 66,968 | normal | 1.42 |
| 148,503 | normal | 1.45 |
| 244,689 | normal | 1.47 |
| ~300,000 | **HTTP 500, engine process died** | not measurable |

The log recorded `CUDA error: cudaErrorIllegalAddress`. The pod restarts, but the fact that a single request took down the entire endpoint remains. Three quarters of the advertised 1M-token window was a minefield.

The prescription is to match the advertisement to reality. We lowered `max_model_len` to 245,760 and checked again: 240,503 tokens are handled normally, and larger requests get a **clean HTTP 400** instead of killing the process. The exact boundary between 244,689 and 300,000 has not been narrowed yet, and we placed the cap just above the verified point.

## The cost is capacity, not latency

Attaching a drafter shrinks the KV cache. Under the same configuration, the pool went from 1,808,112 tokens to 1,354,786, a 25% reduction. For 1M-token requests, the number that can be handled concurrently drops from 1.81 to 1.35.

If you serve long contexts, start the calculation here. The drafter takes space, not time.

## Things that will trip you up when you reproduce this

We tripped three times while measuring. All three changed the result numbers substantially.

**One warmup is not enough.** The drafter captures CUDA graphs at the first real generation. So the first run takes 15.3 seconds and from the second run 1.3 seconds, a scatter of up to 11.64x. With 3 warmups, five repeats stabilized between 176.8 and 180.5. Without that adjustment we would have reported a value 12x too low.

**Do not mix speed measurement and quality measurement on one node.** Quality evaluation takes hours but returns the same accuracy; speed is time by definition and is contaminated by anything else that lands on the node. We ran three quality benches in the middle of a speed measurement and filled the node; one cell's scatter blew up to 6.28x. Re-measuring on a quiet node brought it back to 1.02~1.09x.

**Scatter that does not shrink with more repeats is not noise.** The concurrency-16 cell of the copy-type task went from 1.52x over 5 repeats to 1.55x over 15 repeats. If tripling the samples leaves it unchanged, the distribution is genuinely bimodal, and that is an operational fact, not a measurement problem. Free-form writing at the same concurrency was stable at 1.05x, so what wobbles is the workload side, not the concurrency.

## ThakiCloud perspective

This changes how we set the serving defaults of Metis (the inference platform). What we learned is not the binary of turning speculative decoding on or off, but **in which range to turn it on**. The drafter gives lossless multipliers on short and mid-length requests, eats capacity on the long path, and takes the server down past the boundary. Routing by length is safer than a blanket enable.

The same discipline applies to Paxis (the agent platform). Agents do not fill a batch; they wait one stream at a time, so response speed in this range dominates the perceived experience more than total throughput. But this measurement also concludes that the gain cannot be promised across the whole advertised context window.

These numbers are decode speed with the prefix cache filled. If a completely new 234k prompt arrives every time, the prefill cost comes back. Our real traffic has a fixed system context, close to the cache-friendly side, but in environments where that premise does not hold, the multiplier shrinks.

## References

- [Fast Inference from Transformers via Speculative Decoding (arXiv:2211.17192)](https://arxiv.org/abs/2211.17192)
- [EAGLE: Speculative Sampling Requires Rethinking Feature Uncertainty (arXiv:2401.15077)](https://arxiv.org/abs/2401.15077)
- [vLLM docs: Speculative Decoding](https://docs.vllm.ai/en/latest/features/speculative_decoding/)

The method classification in this post (the lookup family that finds candidates inside the prompt, versus the learned drafter that reads hidden states) was confirmed against the vLLM docs' method list and the two papers above. All links were verified with real calls on August 24, 2026.