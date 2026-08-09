---
title: "The Real Cost in a Video Pipeline Wasn't Generation. It Was Swapping Stages."
excerpt: "We re-loaded Wan2.2 on a single H200 and measured 152 seconds to generate a 5 second video, then 195 seconds to unload that same model from VRAM and load it back in. Here is the measured case for why choosing between a single omni model and a multi-model pipeline is a resident-slot problem, not a quality problem."
seo_title: "Omni Model vs Multi-Model Pipeline: What H200 Measurements Say About Swap Cost"
seo_description: "We measured cold load, per-frame generation latency, VRAM occupancy, and stage-swap cost for Wan2.2-T2V-A14B on an NVIDIA H200. See where swap cost overtakes generation cost, and how it compares to the omni model's throughput tax."
date: 2026-08-09
last_modified_at: 2026-08-09
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "book"
tags:
  - video-generation
  - inference-serving
  - vram
  - model-swapping
  - wan22
  - omni-model
  - benchmark
  - llmops
categories:
  - llmops
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/omni-vs-pipeline-videogen/"
---

This is for platform engineers and architects deciding whether to bring video generation in house. By the end, you should understand why choosing between a single omni model and a pipeline of specialist models is not a question of output quality but of GPU resident slots, and which numbers actually settle that question.

Here is the conclusion up front. On a single H200, generating one 5 second video took 152 seconds. Unloading that same model from VRAM and loading it back in took 195 seconds. Swapping a stage once costs more than making a video. Whether a pipeline architecture makes sense has less to do with how good each individual model is and everything to do with whether you can keep every stage resident in memory at once.

![An illustration evoking the memory footprint of a multi-model pipeline versus a single model](/assets/images/omni-vs-pipeline-videogen-hero.png)
*The more stages you chain, the less this is a compute problem and the more it is a real-estate problem.*

## What we measured and why

Video generation is currently splitting into two camps. One is the omni direction, where a single model takes text, images, video, and audio in and puts all of them back out. The other is the pipeline direction, where a text-to-video model, an audio model, and an upscaling model each stay separate and get chained together.

We already had the cost of the omni side on file. In a single-B200 measurement from our engineering whitepaper 1.3, the vision-language specialist Qwen3-VL-8B hit 13,831 tok/s at a concurrency of 128, while the any-to-any model from the same stack, Qwen3-Omni-30B-A3B, ran 1.5 times slower at 9,062 tok/s. In exchange, it scored higher on accuracy: 59.9 versus 54.0 on MMMU-val, and 80.0 versus 74.7 on ChartQA. Folding several modalities into one model buys you accuracy and costs you some throughput.

The pipeline side of that ledger was empty. The same whitepaper had left serving optimization for video generation in the queue for a future measurement and made no throughput claims for today. This post fills that gap.

The model under test is Wan 2.2 T2V A14B. We did not pick it for topping leaderboards. We picked it because it ships under Apache 2.0, which means we can pull the weights and run them domestically without a licensing question hanging over us. That choice connects directly to a piece we published alongside this one: the leading omni video model is off limits to us because its licensed territory excludes Korea, so we could not run it ourselves. That is why the omni axis of this post rests on understanding-layer numbers, while the generation layer is measured directly, and only on the pipeline side. We are leaving that asymmetry visible rather than papering over it.

The environment was a single NVIDIA H200 NVL, 139.8 GiB of VRAM, torch 2.11.0, and diffusers 0.39.0. The model came from our internal registry, not Hugging Face.

## 391 seconds to download the model, 185 seconds to load it into VRAM

The first number already broke our expectations. A single-stream probe pulling 256 MiB from the registry measured 916 MiB/s. But the actual pull, 117.53 GiB split across 49 objects on 16 threads, took 390.7 seconds, averaging 308 MiB/s. That is a 3x gap.

A single-stream probe overestimates a real multi-file pull by that much. When you are not pulling a few large files but dozens of files of wildly different sizes, connection setup and small-object overhead eat into the effective bandwidth. If you use the probe number for capacity planning, you will be wrong, and this is a trap we fell into ourselves while writing our own preflight checks.

Moving the model from disk into VRAM took another 185.31 seconds, and once resident it occupied 64.57 GiB. Inside the pipeline, only vae sits in float32; text_encoder, transformer, and transformer_2 are all bfloat16. A14B carries two expert copies, one as transformer and one as transformer_2, so despite the "14B" name, what actually stays resident is roughly double that, plus the encoder and the vae on top.

Something is already decided at this point. A single stage uses 46 percent of a 139.8 GiB card. Two stages barely fit. Three do not.

## The longer the clip, the worse the per-second cost gets

We fixed resolution at 480x832 and step count at 20, and varied only frame count. For each setting we discarded one warmup run and measured two.

| Frames | Clip length | Generation time | Per video second | Peak VRAM |
|---|---|---|---|---|
| 33 | 2.06s | 49.2s | 23.9s | 66.13GiB |
| 49 | 3.06s | 79.6s | 26.0s | 66.80GiB |
| 81 | 5.06s | 152.3s | 30.1s | 68.14GiB |

Frame count went up 2.5x, and time went up 3.1x. The cost of one second of video climbs from 23.9 seconds to 30.1 seconds, a 26 percent increase. Attention scales quadratically with frame count, so longer clips get worse per-second economics. Generating one 15 second clip in a single pass does not cost the same as generating three 5 second clips and stitching them, and the arithmetic favors the latter.

Reproducibility was striking. Two runs of the same setting stayed within 0.09 seconds of each other, and even the warmup run we intended to throw away landed almost identical to the real one: 49.206 seconds versus 49.225 seconds. Diffusion runs a fixed number of steps to completion every time, so there is little room for a run to wander. That is a different character entirely from language model serving, where latency swings with token count, and it makes capacity planning for video considerably easier.

## Unloading is free. Loading is everything.

The core measurement came last. We fully released the model from VRAM and loaded it back in, to time the cost of swapping out a single stage.

Release took 0.26 seconds, effectively free. Reload took 195.01 seconds. Combined, 195.28 seconds, over three minutes to put one stage back the way it was.

Set that next to the table above and the picture is clear. Generating one 5 second video takes 152.3 seconds. Swapping a stage once takes 195.28 seconds. The act of moving models in and out of memory costs more than the actual work.

![A chart comparing per-stage pipeline timing against the whitepaper's omni-versus-specialist measurements, with Korean labels](/assets/images/omni-vs-pipeline-videogen-results.png)
*The chart labels are in Korean, so here is what the two panels show. The left panel breaks down the pipeline stage timings we measured on H200: download, VRAM load, per-frame-count generation time, and the unload/reload swap cost. The right panel reproduces the whitepaper's single-B200 omni-versus-specialist comparison: throughput in tokens per second and accuracy on MMMU-val and ChartQA. The two panels come from different hardware and different layers of the stack, and we deliberately did not combine them into one figure.*

We had planned to chain in the audio stage and measure whether the two models could coexist in memory, but the container image lacked librosa, so the speech synthesis model never loaded. That means we did not get to measure the actual co-residency footprint of two models running together. The swap cost we measured was unloading and reloading the same model, so a transition between two genuinely different models costs at least this much, and typically more. Both of those are next on our measurement queue.

## So, omni or pipeline

We can now weigh both options on the same terms. Omni gives up 1.5x throughput permanently in exchange for having no stage boundary at all. A pipeline runs each stage at the full speed of its specialist model, but pays 195 seconds every time it crosses a boundary.

That narrows the decision to a single question: can you keep every stage resident in VRAM at the same time?

If you can, the pipeline wins. The boundary cost drops to zero, and each stage runs the model best suited to its job. If you cannot, the picture flips. In a setup where every incoming request means swapping models for three minutes, the omni model's permanent 1.5x tax is far cheaper. The earlier number, that a single card fits only two stages at 64.6 GiB each, is what decides this in practice.

Seen this way, the real value of an omni model is not the quality or naturalness people usually credit it for. It is that it conserves resident slots. Folding modalities into one model means occupying exactly one spot on the GPU, and in an environment where spots are scarce, that difference matters far more than a few benchmark points.

The reverse holds too. When space is not scarce, the case for omni weakens. Given multiple cards and a deployment that can keep each stage resident on its own, the pipeline is faster and easier to swap piece by piece. When one model goes stale, you only replace that one.

## What the serving layer needs to know

The operational lesson we took from this measurement is about the unit of scheduling.

In a serving layer like Metis, the batch unit has mostly been a single model. Video workloads arrive not as one model but as a bundle of stages, and whether that bundle can sit together on one card changes response time by units of minutes, not milliseconds. That means the scheduler needs to know the resident footprint of the bundle, not the size of any one model in it. Co-locating stages that belong to the same pipeline on the same card stops being an optimization and becomes closer to a correctness requirement.

The same logic applies to the orchestration layer. When Paxis runs a workflow that chains several models together, the order in which it sequences those steps determines how many swaps happen. Batching work that shares a stage cuts swaps; bouncing between stages task by task multiplies them. The throughput gap between a scheduler that knows about the 195 second number and one that does not is larger than anything you would gain by swapping the underlying model.

## Where this leaves us

The most expensive part of a video generation pipeline was not generation. On a single H200, one 5 second video costs 152 seconds, and swapping a single stage costs 195 seconds. Because one stage already consumes 46 percent of the card, the number of stages you can keep resident tops out at two.

So the choice between omni and pipeline is not a matter of taste or quality. It is arithmetic. Add up the stage count and each stage's resident requirement, compare that against card capacity, and the answer falls out. If it fits, pipeline. If it does not, omni.

The pipeline figures in this post were measured directly on a single NVIDIA H200 NVL on August 9, 2026. The omni-versus-specialist figures were measured on a single B200 on August 7, 2026, and appear in engineering whitepaper 1.3. The two measurements come from different hardware and different layers of the stack, and we did not combine them into a single ratio. The measurement scripts and raw results remain in our internal repository.
