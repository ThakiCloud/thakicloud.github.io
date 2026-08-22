---
title: "Same Model, Different Harness: We Cut Tokens 16x by Measuring RLM on H200"
seo_title: "RLM Recursive Harness on H200: Verified 16x Token Savings - Thaki Cloud"
seo_description: "We measured MIT's Recursive Language Models (RLM) paper claims on our own H200 cluster. We attached only a recursive harness to an untrained Qwen3-8B, ran a 3-arm comparison that cut long-document aggregation tokens 16x while lifting accuracy, then reproduced the paper's GRPO training with prime-rl and documented the 11 real things that broke."
excerpt: "If long-context cost is your bottleneck, swapping the harness may come before swapping the model. We share the numbers from measuring an RLM-style recursive harness on Qwen3-8B, and the points where reproducing the paper actually breaks."
date: 2026-07-23
tags:
  - rlm
  - recursive-language-models
  - long-context
  - qwen3
  - h200
  - grpo
  - prime-rl
  - vllm
  - harness
  - paxis
categories:
  - research
author_profile: true
toc: true
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/research/rlm-harness-h200-measurement/"
audiobook: "https://drive.google.com/file/d/1VM4_cxjs6lZ6gVHvf_XsF9ge-DLgWgOS/view"
audiobook_label: "▶ Listen: 5-minute briefing"
audiobook_note: "NotebookLM audio overview (AI-generated)"
published: false
---

If you run long-context workloads on H200, you can cut long-document processing tokens to one sixteenth without changing a single line of the model, just by changing the harness. We measured MIT's Recursive Language Models (RLM) paper claim directly on our own H200 cluster. This post covers how far those numbers hold up, where to stay cautious, and what actually breaks when you try to run a freshly published paper as-is.

![Illustration of the core idea of Same Model, Different Harness: We Cut Tokens 16x by Measuring RLM on H200](/assets/images/rlm-harness-h200-measurement-hero.webp)
*A visual metaphor for the article's key idea.*

## Why the harness matters

The idea behind RLM is simple. Instead of pushing an entire long document into the model's context, you keep the document as a variable in the execution environment and let the model pull out only the pieces it needs through programmatic access like grep or partial reads. The original authors go a step further. They argue that a harness designed this way makes structurally similar tasks nearly identical at the token level, so training on short tasks alone generalizes to tasks 8x to 32x longer. In other words, it is the harness, not the transformer, that carries the generalization.

Rather than take that claim on faith, we decided to check the numbers on our own cluster first. We split the measurement into two tracks: the gain from adding the harness alone with no training (E1), and reproducing the paper's RL training at a scaled-down two-H200 footprint (E2).


## E1: Same model, three harnesses

We served a single untrained Qwen3-8B on vLLM and had it answer the same questions three different ways: 1-pass, which puts the entire document in the prompt (with the context window extended to 131k via YaRN, same as the paper); flat map-reduce, which splits the document into chunks, queries each, and merges the results; and the RLM-style recursive harness. In the recursive harness, the model never sees the document directly. It assembles the answer using only grep, partial reads, and sub-call actions.

The task set is 24 synthetic long-document aggregation QA questions modeled on the OOLONG family. Given documents in the 32k, 64k, and 128k token range scattered with hundreds of ticket records, the questions ask you to count tickets matching a condition or find the most frequent product. Ground truth is computed by code and graded by exact match.

![Accuracy by harness]({{ '/assets/images/posts/research/rlm-harness/e1-accuracy.webp' | relative_url }})
*Accuracy by tier for the three harnesses. Only the recursive harness reaches 0.5 at 32k and 64k, while both control conditions stay flat at the same value.*

Overall accuracy was 41.7% (10/24) for the recursive harness, versus 16.7% (4/24) for both 1-pass and map-reduce. The 25 percentage point gap clears the pre-registered adoption threshold (+5pp). At a sample size of 24 questions, though, this difference falls short of statistical significance (McNemar test, p ~0.11), so the honest reading is that the accuracy gain is a directional signal, not a proven one.

Where the numbers split cleanly is cost.

![Token cost by harness]({{ '/assets/images/posts/research/rlm-harness/e1-tokens.webp' | relative_url }})
*Average tokens per question (log scale). The recursive harness stays around 4k tokens even as the document grows 4x longer.*

1-pass and map-reduce burned between 28k and 110k tokens per question, scaling with document length, while the recursive harness stayed around 4k tokens regardless of whether the document was 32k or 128k. Across all 24 questions, that is 1.5 million tokens versus 92k tokens. A 16x difference. This pattern lines up exactly with the paper's quotient set explanation: the harness decouples task length from the tokens the model actually reads.

This is exactly why the map-reduce control matters. If the gain came simply from splitting the document into chunks, map-reduce should have improved too. Instead, map-reduce matched 1-pass exactly on accuracy and used more tokens, if anything. That means the gain comes from the recursive structure and programmatic access, not from chunking. Breaking the results down further sharpens the picture. On single-condition counting questions, the recursive harness got all 6 questions right while both control conditions got all of them wrong, thanks to grep acting as a deterministic counter. On questions requiring two conditions combined, however, the recursive harness also went 0 for 0, because the untrained model could not compose a grep pattern that synthesized both conditions on its own. Our data confirms, from the opposite direction, the original paper's motivation that training needs to teach the strategy.

## E2: Training RLM on two H200s

Training in the paper runs on prime-rl with GRPO. The original authors trained Qwen3-30B-A3B on 8 GPUs, but we scaled down to Qwen3-8B, the size the paper itself trained first, with LoRA (rank 32) attached, on two H200s (one trainer, one vLLM inference server). Bottom line up front: 16 training steps ran to completion, at 1.5 to 8 minutes per step, with trainer peak memory at 18.5GiB, leaving plenty of headroom on a 141GB card. The finding itself, that the barrier to entry for RLM training is lower than expected, is a useful result on its own.

That said, the scientific conclusion needs to stay conservative. At 131k evaluation, 8x the training context (16k to 32k), the 16-step model's reward was zero, and re-measuring the untrained baseline was blocked because, of all times, a node's GPU fell into a state requiring a reset right before evaluation. So whether this zero means the model learned nothing, or the task itself floors out at this scale, remains undetermined. The original paper used 10x to 30x more steps than we did, so an absence of transfer signal at 16 steps is not a refutation of the paper. We were also unable to run a non-recursive control with the harness turned off at the same compute budget this time. So the accurate reading of E2 in this post is a confirmation of reproducibility and training stability, not proof of transfer.

## What actually breaks when you follow the paper as-is

Perhaps the densest lesson from this measurement was not the numbers but the reproduction process itself. Getting the environment set up took eleven iterations, and fixing one gate revealed exactly the next one. prime-rl has submodules pinned to SSH URLs, which breaks cloning on a pod with no keys; the rlm repo's example config already diverges from prime-rl's latest schema; flash-attn is an opt-in extra that has to be installed separately; and on H200 (SM90), automatic attention configuration picks FlashAttention 3, which requires a source build and kills the trainer instantly. Model downloads slowed because hf_transfer is deprecated, and turning on the Xet high-performance flag was needed to bring per-file download time down from 5 minutes to tens of seconds. On top of all that, we ran into overnight cluster egress instability, GPU contention, and, at the very end, an NVLink state error.

We are not listing this out to complain. For a paper stack published less than two months ago, even with code available, the schema and CLI are shifting week to week, so most of the reproduction cost comes from this kind of drift, not from the algorithm. Turning every failure into a log-harvesting point (one line merging the trainer log into the results file saved us) dramatically cuts diagnosis time per iteration.

## What to take away

If you operate a long-context pipeline, the recursive harness is worth trying today, even without training. Especially for workloads heavy on conditional search and aggregation over documents, you have a good chance of seeing token cost drop by an order of magnitude, as we did. We have started reviewing how to reflect this pattern in the trajectory compression design of the Paxis skill harness, and on the training side we plan to re-run with better instrumentation so that reward curves and baselines are captured as well.

Every number in the experiment was judged against pre-registered criteria, and three adversarial review agents caught arithmetic errors in the initial aggregation, so the figures in this post are the corrected version. This post's measurements are real measurements on the tkai-prod-compute-h200 cluster, not simulation.


## References

- Recursive Language Models paper: [arXiv 2512.24601](https://arxiv.org/abs/2512.24601)
- Harness compositional generalization blog (Alex L. Zhang): [Language model harnesses are compositional generalizers](https://alexzhang13.github.io/blog/2026/harness/)
- Official RLM implementation: [github.com/alexzhang13/rlm](https://github.com/alexzhang13/rlm)
- prime-rl: [github.com/PrimeIntellect-ai/prime-rl](https://github.com/PrimeIntellect-ai/prime-rl)
