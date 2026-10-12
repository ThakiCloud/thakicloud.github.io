---
title: "Same Weights, Different Decision Probabilities: The Hidden Reproducibility Problem in LLM Decision Heads"
seo_title: "Reproducibility of LLM Decision Heads: Batch Padding, flash-linear-attention and CUDA Builds - ThakiCloud"
seo_description: "With the same 27B model and the same adapter weights, decision probabilities moved by up to 14.4 points depending on batch padding, a kernel library and the CUDA build. Why reproducing accuracy and reproducing probabilities are different requirements, and how we pinned the release."
excerpt: "Right before release, the public loader failed to reproduce the reference results. The weights and code were right. What differed was how many inputs were batched together and which kernel library was installed."
date: 2026-10-12
last_modified_at: 2026-10-12
tags:
  - reproducibility
  - decision-adapter
  - batch-padding
  - flash-linear-attention
  - cuda
  - model-release
  - huggingface
  - metis
  - paxis
categories:
  - research
author_profile: true
toc: true
toc_label: "Contents"
canonical_url: "https://thakicloud.com/tech-blog/en/research/decision-head-reproducibility/"
audiobook: "https://drive.google.com/file/d/1HILj9RBpACyClcGwUmMbIn73ctlYmq3Q/view"
audiobook_label: "▶ Listen: 5-minute briefing"
audiobook_note: "NotebookLM audio overview (AI-generated)"
---

When releasing a research model, shipping the weights with a dependency list usually feels like enough. We thought so too. Then, in verification right before release, the public loader failed to reproduce the reference results. The weights and code were right, but the decision probabilities were not.

This is for anyone who audits model decisions, or runs a service where the same input must get the same decision. Reproducing accuracy and reproducing probabilities bit for bit turned out to be different requirements.

## In plain terms

Say you bake bread with the same recipe and the same dough. You can put one tray in the oven, or several at once. With several trays, the heat circulates a little differently, and the crust color shifts slightly. A different oven brand, at the same setting, shifts it again.

Most people tasting the bread would never notice. But if a test passes or fails each loaf by crust color, loaves near the line can pass in one oven and fail in another.

Our decision adapter is that test. The dough is the input and the recipe is the weights. The oven is the runtime. How many trays go in at once is batching and padding, and the oven brand is the CUDA build and the kernel libraries.

<!-- nlm-visual -->
## What we did

### What happened in pre-release verification

Before releasing the decision adapter from [our earlier post](/tech-blog/en/research/shared-decision-adapter-27b/), we checked that the public loader reproduces the reference results. The reference was computed by the training-time evaluation code, eight inputs at a time. The public loader computes one input at a time, with no padding.

With the same weights, the probabilities did not match. The largest gap per seed was 2.6 to 4.5 points. On one seed, one decision out of 64 changed.

### Separating the causes one by one

We suspected the loader first. But running the same loader in batches of eight, like the reference, gave zero difference. Running one at a time twice also gave zero difference. The loader, weights and prompt were all correct. The gap came from the computation path itself.

Next we checked the most worrying possibility: whether other inputs in the same batch affect a decision. If so, one user's decision would change with a neighboring user's input, and the release would have to stop. With batch size and padding length fixed, we changed only the neighbors' content. All 16 items showed zero difference.

Then we changed only the shape.

| what changed | largest probability gap | first layer that differs | flipped decisions |
|---|---|---|---|
| neighbor content only, same shape | 0 | none | 0 |
| padding added to one input | 6.6 points | layer 1 | 0 |
| batch size 1 → 8 | 3.9 points | layer 1 | 0 |
| padding length 1,024 → 1,536 at batch 8 | 0.9 points | layers 45–46 | 0 |

*A diagnostic on 16 items and one seed.*

The moment padding is added, numbers differ from the first layer on. No neighbor influence showed up in this sample. Whether a kernel or the masking is to blame, we have not pinned down.

### Computing the full evaluation one input at a time

We decided to define the published numbers by the way the loader actually runs. We recomputed all 9,724 development items, one at a time, on all four seeds.

| seed | accuracy, batches of 8 | accuracy, one at a time | decision agreement |
|---|---|---|---|
| 1 | .9307 | .9295 | .9944 |
| 2 | .9300 | .9301 | .9948 |
| 3 | .9425 | .9422 | .9971 |
| 4 | .9074 | .9061 | .9934 |

Mean accuracy went from 92.8% to 92.7%, a 0.07-point gap with a 95% interval from −0.15 to +0.01 that includes zero. Decision agreement, however, was 99.3% to 99.7%. Accuracy was nearly identical, yet dozens of individual decisions really changed.

In other words, the report card showed the same score, but a few answer sheets had different answers.

### Running it in a clean environment

Finally, we installed only the public files in a clean virtual environment. Again it did not match. To separate the causes, we ran three times in the same pod, changing only the environment.

| runtime | largest gap from reference | flipped decisions |
|---|---|---|
| torch for CUDA 12.8, no kernel library | 14.4 points | 0 / 64 |
| torch for CUDA 12.8, with kernel library | 9.4 points | 0 / 64 |
| torch for CUDA 13.0, with kernel library | 0 (bit-identical) | 0 / 64 |

*64 items per seed. The kernel library is flash-linear-attention 0.5.2.*

One cause showed up directly in the code. The reference environment had the kernel library installed, so the core computation of some layers ran on its kernels. That held even though the log warned that the fast path was unavailable and the default implementation would be used. The warning only meant one other helper library was missing; most of the computation was in fact running on the fast kernels. The clean environment lacked the library, so the same layers ran on the default implementation.

## What came out

Three things became clear.

First, the runtime really changes decision probabilities, even with identical weights. A gap of 14.4 points is not rounding noise. No decision flipped in this sample, but that does not guarantee the same for inputs near the decision boundary.

Second, no interference from neighboring inputs was observed. The gap came from the shape in which inputs are batched.

Third, exact reproduction is possible. With the same CUDA build and the same kernel library, a freshly built environment matched the probabilities bit for bit.

So we pinned the release. The dependency list names the CUDA build of torch and the kernel library version. The loader checks the runtime at start and warns when it differs from the verified one. Official support is limited to one input at a time, without padding. The model card states, with numbers, that probabilities differ in other runtimes.

## What to change

If you release or run a decision model, it helps to check reproducibility at three levels: whether accuracy reproduces, whether individual decisions reproduce, and whether probabilities reproduce bit for bit. As here, a model can pass the first and fail the second.

Package names and versions alone were not enough. The same torch version gave different results with a different CUDA build. Some optional libraries change the computation path just by being installed, and unless they are written down they silently go missing.

It also pays not to take log warnings at face value. This warning read as if no fast path was used at all, when most of it was. Which kernels actually run had to be checked in the code.

For ThakiCloud this ties directly into serving on Metis. A serving engine batches requests for throughput, and if batching changes decisions, the same question could get different decisions at different times of day. When agent decisions are audited in Paxis, the record can only be trusted if the same input gives the same result. A decision layer should pass these reproducibility checks before it goes on shared serving.

The public package and the pinned runtime are on [Hugging Face as ECP-Q7-27B-Research](https://huggingface.co/ThakiCloud/ECP-Q7-27B-Research).

<!-- nlm-visual -->
## What not to trust

First, the diagnostics are small. The shape diagnostic used one seed and 16 items, and the runtime comparison 64 items per seed. That no decision flipped in this range cannot be extended to the full data.

Second, we have not found the cause of the padding gap. We know it starts at the first layer, but not whether a specific kernel or the masking is responsible.

Third, the hardware range is narrow. Bit-identical reproduction was confirmed only on the GPU and runtime combination we verified. We cannot yet say it holds on other GPU generations.

Fourth, batched inference is not supported. The path that batches requests, as real serving does, is outside this release.

*These numbers were measured on our own H200 GPUs, and only results recorded in our research ledger are cited.*
