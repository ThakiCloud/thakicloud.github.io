---
title: "The Throughput Your Defaults Are Eating: Measuring the Configuration Tax in Serverless LLM Inference"
seo_title: "Measuring Throughput Loss From Default Serverless LLM Inference Settings - Thaki Cloud"
seo_description: "We present measured results showing that disabled compilation and a low max_num_seqs default on vLLM serverless endpoints quietly cut throughput by 18.8x in the single-stream regime and by at least 17.9x at saturation, along with a five-step audit procedure."
excerpt: "On the same checkpoint and the same GPU, changing only two serving settings widened throughput by up to 18.8x. The problem was not the model. It was a platform default nobody had looked at."
date: 2026-08-24
last_modified_at: 2026-08-24
tags:
  - llm-inference
  - vllm
  - serving-optimization
  - torch-compile
  - max-num-seqs
  - b200-gpu
  - throughput
  - token-factory
  - inference-cost
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
reading_time: true
categories:
  - research
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/research/default-configuration-tax/"
---

If you self-host LLM serving, or if you're a cloud or AI infrastructure engineer who has to optimize the per-token cost of a serverless inference endpoint, this paper is worth your attention. The headline finding: before you ever tune the serving engine itself, two settings a platform ships as defaults can swing throughput by more than 18x. You don't need to change the model. You don't need more GPUs. Rereading the configuration on the endpoint you already have running is enough to recover this much performance.

## Why This Needed a Second Look

For the past few years, inference systems research has mostly assumed a "well-tuned system" as its starting point. Continuous batching, paged KV cache, chunked prefill, prefill/decode disaggregation, speculative decoding: all of these techniques report how much faster they are than some configured baseline. But nobody has measured how much loss that "configured baseline" itself starts out carrying.

On managed and serverless platforms, engine settings get baked into a Helm chart or a template once, and after that an operator almost never looks at them again. This paper calls the throughput lost to that neglected default the "configuration tax" and measures its size in a real production environment. The setup was simple: hold the same checkpoint, the same GPU, and the same engine version fixed, and compare three configurations (arms) that differ only in serving settings. The result was an 18.8x gap in the single-stream regime and at least a 17.9x gap at the top of the concurrency ladder.

## What Was Measured, and How

The measurement ran on a single NVIDIA B200. It kept vLLM 0.24.0 and the NVFP4-quantized `RadixArk/Qwen3.8-27B-NVFP4` checkpoint fixed and changed only the serving settings. A fixed workload of 2,048 input tokens and 256 output tokens was swept across a concurrency ladder of 1, 8, 32, and 128 (up to 256 for the tuned arm). Each step used a different prompt each time to rule out prefix-caching effects, was repeated 3 times, and reported the median.

The key is the third arm. The default arm has compilation and CUDA graphs turned off, with the concurrency cap (`max_num_seqs`) pinned at 32. The tuned arm turns compilation on and raises the cap to 256. Comparing only those two would change both knobs at once, so there would be no way to tell how much each one contributed. That's why a middle compile-on arm was added: compilation turned on, the cap left at 32. Only with this middle arm can you separate "how much from compilation" from "how much from the cap."

![The default-tax audit: five steps at endpoint creation](/assets/images/posts/research/default-configuration-tax/fig1.webp)
*A five-step audit procedure any operator can follow at endpoint creation time. Confirm the actual engine settings from the logs. Measure baselines at both ends of the ladder. Flip one knob at a time to isolate the two components. (Illustrative diagram)*

At a single stream (concurrency 1), the default arm measured 7.4 tokens per second and the compile-on arm measured 138.9. That's an 18.8x difference. At the top of the ladder, the tuned arm hit 4,150.7 tokens per second at concurrency 256, while the default arm had flattened out at 231.6. The gap there is 17.9x, but that number should be read as a lower bound: the tuned arm was still climbing 7.9% over its previous step even at the end of the ladder, meaning it had not yet reached saturation.

## The Two Knobs Don't Work the Same Way

The most practical finding in this paper is that the two knobs play different roles.

The compilation component (Component A) is the compile-on arm divided by the default arm: 18.8x at concurrency 1, 16.5x at 8, 10.2x at 32, and still 10.0x at 128. It holds a double-digit gain across the entire ladder. When compilation is off, the host has to launch a small GPU kernel for every decode step, and that launch wait time becomes the bottleneck. The default arm's per-stream throughput sits nearly flat at 7.4, 6.96, and 7.12 across concurrency 1, 8, and 32, which is exactly what you'd expect from that bottleneck: launch overhead doesn't shrink no matter how large the batch gets. The compile-on arm's per-stream throughput, by contrast, falls as batches grow: 138.9, 115.2, 72.7. That's normal batching efficiency at work.

The concurrency-cap component (Component B) behaves the opposite way, like a threshold. When offered concurrency is at or below the cap (32), it's exactly 1.00x: no effect at all. It only kicks in once concurrency crosses that cap, delivering 1.66x at concurrency 128 and at least 1.79x measured at each arm's top data point. Raising the cap isn't a second, independent source of gain. It's a gate that only opens once traffic crosses that threshold.

![Isolated component sizes by traffic regime](/assets/images/posts/research/default-configuration-tax/fig2.webp)
*Component sizes, isolated by flipping one knob at a time, broken out by traffic regime. The compile/launch component is the larger of the two in both regimes. The concurrency-cap component sits at exactly 1.00x, inactive, whenever offered concurrency is at or below the cap, and only activates once concurrency crosses it. (Measured: isolated component values from Table 1)*

The practical conclusion here is clear. What the regime (whether single-request latency matters most, as in conversational and agentic workloads, or throughput matters most, as in batch workloads) determines isn't the ranking of the two knobs by size. It determines whether the second knob actually does anything. Compilation is the knob to flip first regardless of regime. The concurrency cap is only worth raising once offered traffic actually crosses that threshold. Raising the cap without turning on compilation leaves the larger loss component untouched in either regime. Turning on compilation while leaving the cap alone is enough for latency-focused traffic, but it costs roughly 1.8x or more in throughput-focused traffic.

![Measured throughput of all three arms across the concurrency ladder](/assets/images/posts/research/default-configuration-tax/fig3.webp)
*Measured throughput for all three arms across the full concurrency ladder. The gap between the default curve and the compile-on curve is the compilation component. The gap between the compile-on curve and the tuned curve is the cap component. The two curves overlap until offered concurrency crosses the cap of 32. The default and compile-on arms were not measured at concurrency 256. The tuned curve was still climbing 7.9% over its previous step even at its last point, so 4,150.7 should be read as where the ladder ended, not where saturation was reached. (Measured: Table 1 values)*

The paper adds one more principle on top of this: provenance. A setting only counts as "applied" if the engine actually recorded it in its startup log, not if it's merely what you requested. A policy layer can clamp or silently ignore a requested value, so what an operator believes they configured and what the engine actually runs can diverge. Building on that principle, the paper lays out a five-step default-tax audit: (1) read the engine's actual settings from the logs, (2) measure the full tax, (3) turn on compilation alone to isolate the launch component, (4) raise the cap alone to isolate the cap component, and (5) report both components together with the threshold point and the startup cost. This procedure can run on an existing endpoint exactly as is, with no new hardware needed.

## What This Means for the Company, the Industry, and the Science

From ThakiCloud's perspective, this result leads directly to the question of tenant default serving settings on Metis (AI Inference / Token Factory). In fact, this measurement came from our own demo cluster. On that basis, we now have grounds to change policy so that Metis serverless endpoints default to `TORCH_COMPILE_DISABLE=0` and `max_num_seqs=256`. The cost is only about a 79-second increase in endpoint startup time, and this paper's practical conclusion is exactly that this cost isn't worth trading against an 18.8x gain. More broadly, since the work-automation workflows Paxis runs ultimately consume tokens on top of Metis, the throughput quietly burned by serving defaults is a cost that feeds directly into the execution economics of agent automation.

For the industry as a whole, the message is simpler. What often determines a company's token costs isn't which model it picked, but an unmeasured platform default. This audit procedure needs no new GPU purchase, and anyone running self-hosted inference can apply it to their own endpoint right now.

Scientifically, the weight is different. Most existing serving-optimization literature measures already-tuned systems. This paper goes the other direction: it's the first case to use a controlled measurement to isolate how much loss a platform default creates, broken down by knob (compilation mode, concurrency cap, KV budget) and by traffic regime. The methodology itself, reading the engine's actual settings back out of pod logs to verify them, stands as a reusable contribution.

## What Are the Limits

The authors draw clear lines around their own claims. This paper is a single controlled measurement, from one GPU generation (B200), one engine version (vLLM 0.24.0), one precision (NVFP4), and one checkpoint. It does not claim to be an empirical study spanning multiple models and multiple accelerators. It is explicit that this is only an analytical model calibrated by these measurements. The decomposition structure itself, two knobs combining multiplicatively with one of them behaving like a threshold, is expected to generalize to other environments, but that generalization remains unverified and is left as future work.

The paper is also honest about limits in the measurement itself. The tuned arm was still climbing even at the end of the ladder, so the 17.9x figure and the 1.79x cap component are both lower bounds; the real values could be larger. The node used for measurement wasn't a fully isolated environment either: another GPU on the same node was handling real traffic for the same model, so host CPU and power budget were partially shared. That's a factor that could somewhat overestimate the compilation component or make absolute throughput look lower than it actually is. Finally, the assumption that decode steps are launch-bound with compilation off was observed on this specific model-and-engine combination. On a different architecture or attention backend, the size of the compilation component, and even which of the two knobs takes priority, could change.

You can find the original dataset and the paper detail page below.

[HF Daily Paper: The Default Configuration Tax](https://huggingface.co/datasets/thaki-AI/daily-paper-2026-08-24-default-configuration-tax)
