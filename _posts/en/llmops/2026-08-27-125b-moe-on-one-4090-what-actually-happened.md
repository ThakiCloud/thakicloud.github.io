---
title: "125B Didn't Fit in 24GB: How to Read the Single-4090 Record Correctly"
excerpt: "A record claiming Qwen3.8-Flash-Next ran at 21 tok/s with a 250K context on a single RTX 4090 has been making the rounds. The numbers are real, but the conclusion isn't. The VRAM wall didn't die. It moved to system RAM capacity and time-to-first-token."
seo_title: "125B MoE on One 4090: What Was Verified and What Wasn't"
seo_description: "An analysis of running Qwen3.8-Flash-Next 125B-A6B on a single RTX 4090 with a 250K context, cross-checked against the model card and the llama.cpp PR. What ultra-sparse MoE and linear attention actually bought, and where the 250K benchmark has a catch."
date: 2026-08-27
categories:
  - llmops
tags:
  - moe
  - cpu-offload
  - llama-cpp
  - long-context
  - consumer-gpu
  - inference-economics
author_profile: true
toc: true
toc_label: "Contents"
lang: en
canonical_url: https://thakicloud.com/tech-blog/en/llmops/125b-moe-on-one-4090-what-actually-happened/
---
If you've ever given up on running a large model locally because of VRAM, this post is going to make you redo that math. A record recently made the rounds claiming a 111GB model ran with a 250,000-token context on a single RTX 4090, and checking the numbers against the original source shows most of it holds up. But the conclusion attached to that record, "the VRAM wall is dead," doesn't.

Here's the accurate version. **Most of a 111GB quantized model sat in 110GB of system RAM, with only attention and the KV cache left on the GPU, running at roughly 21 tok/s for a single user.** The core move was treating 24GB of VRAM and 110GB of DDR4 as one tiered memory pool. The wall didn't disappear. It moved from the GPU to system RAM.

Even with that correction, the result still matters, because the model architecture that made this possible has direct implications for how we design serving going forward.

## What Actually Ran

The model is Qwen3.8-Flash-Next, and it's not a typical 125B dense model. The official model card describes it as "125B with 6B activated, plus 51B n-gram embedding and 4B MTP." The language model body is 125B, but only about 6B actually activates to produce a single token, and on top of that there's a separate 51B-scale n-gram embedding and a 4B MTP layer.

The file used was Unsloth's UD-Q4_K_XL GGUF in 4 shards, and checking the actual sizes gives 10.9MB, 49.9GB, 49.4GB, and 12.1GB, totaling about 111.4GB. That matches the 111GB in the original record.

The environment was Ubuntu 22, CUDA 13.0, PCIe 4.0 x16, and 110GB of DDR4, and it had to be built from an unmerged PR rather than mainline llama.cpp. This part needed verification, so I checked it directly: PR #27742 was opened on August 26, 2026, and is still open. In other words, this execution path isn't in master yet.

## Why 111GB Runs on a 24GB Card

Three structural features stack together to produce this result, and if any one of them were missing, it wouldn't work.

The first is ultra-sparse MoE. Each MoE layer in this model has 512 experts, but only 10 routed plus 1 shared expert are used per token. A dense 125B model would have to touch nearly all its parameters for every token, but here most expert weights sit idle. Idle weights can live in slow memory. That's where the split comes from: keep the always-used attention and shared layers on the GPU, and push the rest to system RAM.

The second is the attention structure. The 48 layers aren't uniform. Using the official card's notation, the pattern is 12 × (3 × (Gated DeltaNet → MoE) → 1 × (Qwen Sparse Attention → MoE)), which works out to 36 linear-attention layers and only 12 sparse-attention layers. This isn't a typical full-attention model that builds a KV cache proportional to context length at every layer. On top of that, QSA has only 24 Q heads against 2 KV heads, and its budget is capped at 2,048 tokens. Both of these are why the memory cost of long context stays low.

The third is the nature of the n-gram embedding. 51B sounds heavy on its own, but it's a lookup table that currently pulls only a handful of rows corresponding to bigrams and trigrams. The llama.cpp PR description also states that it fetches from a 97.7GiB n-gram hash table via `ggml_get_rows`, using host-side row indices. The actual transfer volume and compute involved are far smaller than the parameter count suggests.

## How to Read the Numbers

Here are the four configurations from the original record.

| Config | Context Reserved | Prefill | Decode | VRAM | RAM |
|---|---|---|---|---|---|
| `-ncmoe 40` | 80K | 383.85 tok/s | 22.52 tok/s | 23.85GB | 97GB |
| `-cmoe` | 80K | 355.72 tok/s | 20.84 tok/s | 11.66GB | 110GB |
| `-cmoe` | 180K | 357.75 tok/s | 20.98 tok/s | 15.6GB | 110GB |
| `-cmoe` | 250K | 364.29 tok/s | 20.97 tok/s | 18.3GB | 110GB |

The real surprise is in the gap between the first two rows. Pushing all experts to CPU dropped VRAM from 23.85GB to 11.66GB, less than half, while generation speed only dropped from 22.52 to 20.84, a 7.5 percent slowdown. This confirms in practice what was described earlier: expert weights sit idle.

The cost of extending context is also small. Going from 80K to 250K, an increase of 170K tokens in the reservation, only cost 6.64GB more VRAM. That's about 39KB per token, which makes sense given 36 linear-attention layers and 12 QSA layers with just 2 KV heads. And since 250K is within this model's native limit of 262,144, it's not a number inflated through YaRN.

There's one flag that gets commonly misread. The original record described `-ncmoe 40` as "offloading 40 expert layers to GPU," but the actual meaning is the opposite. It keeps 40 layers' worth of MoE experts on CPU, and only the remaining 8 layers' experts out of 48 go to GPU. `-cmoe` extends that to all layers. The phrase "512 expert layers" is also inaccurate. There are 48 layers, and each MoE layer has 512 experts.

## 250K Is Still a Reservation, Not Actual Usage

This is the part of the record that needs the most caution. The original record itself states that a 28K prompt was used consistently across every run. So what's actually verified is: "a server with a 250K context slot allocated processed a 28K prompt."

What remains unconfirmed is significant. Whether 364 tok/s holds when actually prefilling a full 250K tokens, whether needle retrieval still works at the 250K position, whether long-context reasoning accuracy holds up, and whether performance stays stable under repeated runs are all things this record simply doesn't tell us.

Plugging in the prefill speed shows why this matters. Reading a 28K prompt at 364 tok/s already takes about 77 seconds. Assuming the same speed holds, 80K would take about 3.7 minutes, 180K about 8.2 minutes, and 250K about 11.4 minutes. For a fresh 250K request with no cache reuse, that means waiting over 10 minutes just to get the first token.

The 21 tok/s decode number should be read differently. At about 48ms per token, a 1,000-token response takes roughly 48 seconds, which is plenty usable for chat or code generation. The real achievement in this record is generation speed, not time-to-first-response.

There's a note that neither MTP, dflash, nor KV cache quantization was used, and that's not modesty, it's actually a strong claim. It means this isn't a number inflated by predicting and accepting multiple tokens at once or by a draft model, but base autoregressive decode performance. For the same reason, this 21 tok/s shouldn't be placed side by side with the hundreds of tok/s figures you see from speculative decoding. They're measuring different things.

## The Wall Didn't Die, It Moved

What this setup actually requires is 18.3GB of VRAM, roughly 110GB of system RAM, and 111GB of model file on disk. Add it up and you get a workstation with 128GB or more of fast memory and storage. This did not run on 24GB alone.

The bottleneck moved this way: from GPU VRAM capacity to system RAM capacity, then to RAM bandwidth and CPU performance, and finally to long prefill and time-to-first-token. In particular, since the CPU model, number of memory channels, and DDR4 speed weren't disclosed, it's hard to assume 21 tok/s would reproduce as-is on an ordinary dual-channel desktop. Because expert weights are pulled from RAM, memory bandwidth is essentially generation speed.

The phrase "production-grade 125B serving" is also premature. Concurrent request handling and total throughput, p95 and p99 latency, stability under hours of continuous load, quality degradation from 4-bit quantization, and prompt caching effects are all undisclosed. At this stage, the accurate label is a pretty impressive single-user local inference demonstration.

## So Is It Better Than a 27B Dense Model?

It depends on the criteria. On official benchmarks, Flash-Next generally beats Qwen3.8-27B: DeepSWE 1.1 is 58.7 vs 42.2, SWE-bench Pro is 62.5 vs 61.7, SWE-bench Multilingual is 81.0 vs 73.8, and JobBench is 55.7 vs 33.4. But these are Qwen's own benchmarks, and they don't separately measure the quality of the UD-Q4_K_XL quantized version.

From a practical standpoint, it splits three ways. For typical local coding and chat, a 27B dense model is still easier to set up and faster. If you need higher quality than 27B, need to handle long documents in the 100K to 250K range, and have a workstation with plenty of RAM, Flash-Next is an interesting option. For multi-user production, both are better served by a vLLM or SGLang-based GPU server rather than single-node llama.cpp.

## The ThakiCloud View

What we should take away from this is that **we now have one more serving profile to consider.**

From a Metis inference standpoint, this configuration hints at a new tier. Serving design has so far asked a binary question, does the model fit in VRAM, but with ultra-sparse MoE, keeping attention and KV on the GPU while placing expert weights in CPU memory is now proven in practice. If the trade is giving up half your VRAM for a 7.5 percent hit in generation speed, that's a viable option for low-concurrency workloads where quality and context length matter more than latency. That said, this profile sacrifices time-to-first-token, so it doesn't fit conversational SLAs, but it fits batch analysis or reading a long document once and answering at length.

From an Aegis on-premises standpoint, the shape of entry cost changes. In a situation where a high-quality model needs to go into an air-gapped network but there's no budget for datacenter GPUs, a high-RAM workstation could become a realistic alternative. It should be stated clearly that this applies to a single user or a handful of users at most.

There's also something we clearly need to verify on our end. We don't know what CPU or how many memory channels produced that 21 tok/s, and we haven't measured 4-bit quantization quality against our own eval set. Before discussing adoption, the right next step is to measure both of these directly on our own hardware.

## To Reproduce

This architecture isn't in llama.cpp master yet. You need to build from the PR #27742 branch, and that PR was opened on August 26, 2026 and hasn't been merged. It's better not to put an experimental branch into a production path.

Among the flags, `-b 4096 -ub 4096` made the biggest difference. The original record noted that this setting more than doubled prompt processing speed, from about 150 to 364 tok/s. It works by increasing batch and micro-batch size to gain GPU parallelism, but memory usage grows along with it, so it may not reproduce exactly the same way across different GPU and CPU combinations.

To sum up, this record is far more important than "it just worked." Combining ultra-sparse MoE, linear attention, and RAM offload shows that a large model's single-user inference can substitute a meaningful chunk of expensive VRAM with cheap system RAM. But shrinking that down to "the VRAM wall is dead" erases what was bought and what was given up. What was bought was VRAM, and what was paid was RAM capacity and bandwidth, plus time to first token.

## References

- [Qwen3.8-Flash-Next official model card](https://huggingface.co/Qwen/Qwen3.8-Flash-Next)
- [Unsloth Qwen3.8-Flash-Next GGUF](https://huggingface.co/unsloth/Qwen3.8-Flash-Next-GGUF)
- [llama.cpp PR #27742: add Qwen3.8-Flash-Next](https://github.com/ggml-org/llama.cpp/pull/27742)
