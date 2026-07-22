---
title: "Two Frontier Open Weights in One Week: Kimi K3 (2.8T) and Thinking Machines Inkling (975B)"
excerpt: "In July 2026 the open-weight camp fired two shots in a single week. Moonshot AI unveiled Kimi K3, set to become the largest open-weight model ever at 2.8 trillion parameters, while Mira Murati's Thinking Machines Lab released its first open-weight model, Inkling (975B total, 41B active), under Apache 2.0. We lay out the facts, the architectures, and where each lands on benchmarks, then review honestly what an on-prem team can actually serve today."
seo_title: "Kimi K3 vs Thinking Machines Inkling - Open-Weight Frontier Compared and On-Prem Serving - Thaki Cloud"
seo_description: "A fact-based rundown of Kimi K3 (2.8T MoE, 1M context, Kimi Delta Attention, weights July 27) and Inkling (975B/41B active, 45T tokens, text/image/audio, Apache 2.0): architecture, benchmarks, NVFP4 serving, fine-tuning, and a ThakiCloud K8s on-prem perspective."
date: 2026-07-17
last_modified_at: 2026-07-17
tags:
  - kimi-k3
  - inkling
  - thinking-machines
  - moonshot
  - open-weight
  - mixture-of-experts
  - multimodal
  - nvfp4
  - vllm
  - on-premise
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/en/owm/kimi-k3-inkling-open-weight-frontier/"
lang: en
reading_time: true
categories:
  - owm
published: false
---

⏱️ **Estimated reading time**: 14 min

![Conceptual comparison of Kimi K3 and Thinking Machines Inkling open-weight models](/assets/images/kimi-k3-inkling-open-weight-frontier-hero.webp)

## Overview

In mid-July 2026 the open-weight camp fired two shots in the same week. One was **Kimi K3**, previewed by China's Moonshot AI on July 16. With 2.8 trillion total parameters, it becomes the largest open-weight model ever once its weights land on July 27. The other was **Inkling**, the first open-weight model from Mira Murati's U.S.-based Thinking Machines Lab, released on July 15 with a 975B-total MoE that activates only 41B, under Apache 2.0.

The two landing a day apart is coincidence, but their directions are opposite, which makes them easy to compare. Kimi K3 pushes toward "biggest, and longest-running autonomous coding," while Inkling targets "a right-sized base model that enterprises can fine-tune on their own data." One bets on scale and agentic execution, the other on customizability.

ThakiCloud runs a platform that manages GPU quotas with Kueue on Kubernetes and serves models multi-tenant with vLLM. So when a new open weight ships, our question is always the same: can we fit it on the GPUs we already own, how many cards does it take, and can we open fine-tuning to tenants? This article lays out the facts on both models, flags what is worth noting in each architecture, and then honestly weighs what is realistic on-prem today.

## Kimi K3: What the Largest-Ever Open Weight Is Aiming At

`Kimi K3` is an ultra-large MoE model from Moonshot AI. Combining the company's announcement with multiple reports, the core specs are as follows.

| Item | Value |
|---|---|
| Developer | Moonshot AI (backed by Alibaba) |
| Total parameters | 2.8 trillion (MoE) |
| Context | 1M tokens |
| Modality | Natively multimodal (text + image) |
| Key techniques | Kimi Delta Attention, Attention Residuals |
| License | Modified MIT (weights released 2026-07-27) |
| Available now | Kimi.com, Kimi Work, Kimi Code, Kimi API |
| API price | Per 1M input tokens: $0.30 (cache hit) / $3 (miss); output $15 |

The first thing to note is scale. 2.8 trillion parameters is the largest open weight released so far, and the July 27 weight drop makes that official. Because it is MoE, not all 2.8T fires per token, and Moonshot has not disclosed the active-parameter count yet.

Two architectural pieces stand out: **Kimi Delta Attention** and **Attention Residuals**. Kimi Delta Attention is an attention path designed to accelerate long-context decoding by up to 6.3x, the mechanism that keeps a 1M-token window running at practical speed. Attention Residuals, the company says, improve training efficiency by roughly 25% over the prior K2.6 generation while adding under 2% extra compute. Training cost rises sharply with model size, so this reads as an attempt to bend that curve.

What Moonshot emphasizes is not benchmark scores but **purpose**. Kimi K3's primary scenario is long-running autonomous software development. It is built to scan large codebases, coordinate multiple developer tools, and carry multi-step tasks toward an end goal. On top of that sits a visual feedback loop the company calls "vision-in-the-loop": it looks at a screen capture, edits code, then checks the resulting visible output and self-corrects. The claim is that this makes it especially useful where you have to "see the result," such as game development, UI design, and CAD. In public demos it built an entire 3D open-world game inside a browser with Three.js, WebGPU, and GPU Compute, simulated the launch and return of a Long March 10 rocket, and generated an Animal Crossing-style game to a playable state from a single prompt.

### Where It Lands on Benchmarks

Precision matters here, without inflation. Kimi K3 leads the top proprietary models in some areas, but sits just below them in aggregate rankings.

On the leading side: in Arena's Frontend Code category, Kimi K3 took first place with 1679 points, surpassing Claude Fable 5. Given that the prior K2.6 sat at 18th, that is a 17-place jump. It ranked first in six of the seven frontend subcategories (brand marketing, data analysis, consumer products, and others), losing only the gaming category to Fable 5 for second place.

In aggregate metrics the position differs. On GDPval-AA v2, a real-work evaluation, Kimi K3 scored 1687 for third place, behind Claude Fable 5 Max and GPT-5.6 Sol Max. Moonshot itself conceded in its blog that some areas still trail GPT-5.6 Sol and Claude Fable 5, while framing the gap as very small. Independent testing by Artificial Analysis likewise places it just behind the top proprietary models on both its Intelligence Index and real-work evaluations. Among the detailed scores Moonshot published, GPQA Diamond 93.5% and BrowseComp 91.2% are cited as open-weight highs at launch. Those figures come from differing harnesses and sources, though, so comparing them directly against another org's numbers under the same benchmark name warrants caution.

In short, the accurate read is "top-tier on specific coding and frontend workloads, just below the best proprietary models in aggregate." And the fact that an open weight took that position, at a far lower API price, is why the industry is calling it "another DeepSeek moment."

## Inkling: Murati's Lab's First Open Weight, Aimed at Customization

`Inkling` is Thinking Machines Lab's first open-weight model, trained from scratch. Its direction is the opposite of Kimi K3, making the contrast sharp. Rather than overwhelming with scale, it aims to be a "base model" that enterprises can fine-tune to their own domain.

| Item | Value |
|---|---|
| Developer | Thinking Machines Lab (Mira Murati) |
| Total / active parameters | 975B / 41B (MoE) |
| Layers | 66-layer decoder-only transformer |
| Experts | 256 routed + 2 shared; 6 routed active per token |
| Context | Up to 1M tokens |
| Pretraining | 45T tokens (text, image, audio, video) |
| Input / output | Text, image, audio / text |
| License | Apache 2.0 (released immediately) |
| Small variant | Inkling-Small 276B / 12B active (preview) |

The MoE design largely follows DeepSeek-V3. Each MoE layer holds 256 routed experts and 2 shared experts, activating 6 routed experts per token while both shared experts stay on. The router is sigmoid-based and uses an auxiliary-loss-free load-balancing bias. So far this is close to the standard grammar of recent large MoEs.

The differences show up in attention and multimodal handling. Inkling interleaves sliding-window and global layers at a 5:1 ratio with 8 KV heads. For position encoding it adopts a **relative positional embedding** instead of the widely used RoPE, which the lab says extrapolates better to longer sequences. It also adds **short convolutions** right after the key and value projections, and on the attention and MLP residual-branch outputs. A few low-compute tweaks bolted onto the standard transformer recipe, chosen to chase efficiency and long-context performance together.

Multimodal handling is especially practical. Inkling ingests modalities without a separate heavy encoder. Audio enters as dMel spectrograms, images become 40x40 pixel patches passed through a four-layer hMLP, and a lightweight embedding layer projects both so the decoder processes them alongside text tokens. No separate encoder means a correspondingly simpler serving stack.

Training is interesting too. Muon was used for large matrix weights and Adam for the rest, run on NVIDIA GB300 NVL72 systems. Post-training bootstrapped from SFT on synthetic data, some of it generated by Kimi K2.5. Most of the compute then went to asynchronous RL, scaled past 30M rollouts, and that run produced Inkling's core control surface: **controllable thinking effort**. Users can dial how much compute to spend on reasoning.

### Benchmarks and the Small Variant

The benchmarks Thinking Machines published were measured at thinking effort 0.99. By open-weight standards they are strong: GPQA Diamond 87.2%, AIME 2026 97.1%, SWEBench Verified 77.6%, and HLE with tools 46.0%. In the lab's own comparison table, though, the top slot mostly went to proprietary models, and Claude Fable 5 (max) posted the highest scores across many rows. In other words, Inkling's selling point is not "beat the best closed model on benchmarks" but "open-weight top-tier performance, under Apache 2.0, and in a fine-tunable form."

Released alongside it, **Inkling-Small** carries 276B total parameters with just 12B active, far lighter than Inkling's 41B. Yet on several benchmarks it matches or beats its larger sibling. GPQA Diamond, for instance, is 88.3%, above Inkling's 87.2%, and it also leads on chat instruction-following (IFBench) and some vision and audio items. The lab attributes this to improvements in the pretraining data and recipe tailored for the smaller model. For teams that want lower latency and cost while holding performance, this may in fact be the production choice.

## Placing the Two Side by Side

| Item | Kimi K3 | Inkling |
|---|---|---|
| Developer / nation | Moonshot AI / China | Thinking Machines Lab / U.S. |
| Total parameters | 2.8T | 975B |
| Active parameters | Undisclosed | 41B |
| Context | 1M tokens | 1M tokens |
| Input modality | Text + image (vision-in-the-loop) | Text + image + audio |
| Position encoding | Kimi Delta Attention | Relative positional embedding (RoPE replacement) |
| License | Modified MIT (weights 7/27) | Apache 2.0 (immediate) |
| Small variant | None | Inkling-Small 276B/12B |
| Axis targeted | Long-horizon agentic coding / execution | Fine-tuning / domain customization |

Landing the same week, the two answer different questions. Kimi K3 answers "can we build the strongest autonomous coding agent as an open weight?"; Inkling answers "can we give enterprises a strong base model they can make their own, as an open weight?" There is an interesting link, too: part of the synthetic data used in Inkling's post-training came from the Kimi line (K2.5), a small sign that the open-weight ecosystem runs on each other's outputs.

## ThakiCloud Serving Perspective: What Can We Actually Serve Today

Through our platform's lens, the two carry very different weight. The crux is "does it fit on the H100/H200/B300 we already own, today?"

**Start with Kimi K3.** Attractive, but for now a watch-and-wait item on-prem. Three reasons. First, the weights only drop on July 27, so until then it is API-only. Second, 2.8 trillion parameters, MoE or not, is an enormous weight footprint; whether BF16 or low-bit quantized, a single node cannot handle it and a multi-node setup is required, which is a heavy infra burden for most teams. Third, Moonshot has not disclosed active parameters, so serving memory and throughput cannot be precisely estimated yet. At this stage the sensible stance is "validate the agentic-coding workload via API, and judge on-prem portability after the weight drop, once active parameters and quantized checkpoints are known."

**Inkling is a different story.** This one is a candidate we can actually run on our hardware today. The requirements for the two published checkpoints are concrete enough to do the math.

| Checkpoint | Minimum VRAM | Example configuration |
|---|---|---|
| BF16 | ~2 TB | 8x B300 or 16x H200 |
| NVFP4 | ~600 GB | 4x B300 (W4A4) or 8x H200 (W4A16) |

The line that matters is the NVFP4 checkpoint running W4A16 on 8x H200. That means a 975B-class multimodal model fits on a single H200 node (8-GPU), and any team already running H200 can try it without new hardware. Serving runtimes include vLLM, SGLang, and Hugging Face `transformers`, and OpenAI-compatible serving comes up with a single line: `vllm serve thinkingmachines/Inkling --tensor-parallel-size 8`. Since our platform already treats vLLM multi-tenant serving as a standard path, this fits our grain.

The axis that matters more to us is **fine-tuning**. Inkling makes customization its headline differentiator and supports fine-tuning at 64K and 256K context. Given that ThakiCloud stitches kubeflow-based LLM training (SFT, CPT, DPO, GRPO, and more) to vLLM serving on one platform, the scenario of "fine-tune an open-weight base model on tenant data, then serve it on-prem" fits Inkling exactly. Inkling-Small (276B/12B), with lower latency and cost, is an especially good match for our cost model of packing more tenants per GPU in a multi-tenant setup.

To summarize honestly: Kimi K3 is, for now, a watch item to "confirm performance via API and re-evaluate on-prem viability after the weight drop." Inkling is today's practical candidate you can "put on a single H200 node via NVFP4 and open up to tenant fine-tuning." Kimi K3 took the scale headlines, but the one actually within reach for our platform this week is Inkling.

## Closing

Two frontier open weights in one week reconfirms two things. One is that open weights are no longer chasing from behind: on specific workloads they lead, and in aggregate they have closed to just below the best proprietary models. The other is that this race is starting to split along two different axes, scale (Kimi K3) and customizability (Inkling).

For a team running an on-prem platform, that split is welcome news. We look not at a benchmark first-place trophy but at "does it fit on our GPUs, can tenants make it their own?" By that measure, this week's answer is closer to Inkling, while Kimi K3 is an item to wait on after the July 27 weight drop. The fact that both were designed and shipped assuming NVFP4 low-bit serving is itself a signal that the center of gravity in the open-weight race is shifting from "training scale" to "cost to serve."

## References

- [Inkling: Our open-weights model | Thinking Machines Lab](https://thinkingmachines.ai/news/introducing-inkling/)
- [Inkling Model Card | Thinking Machines Lab](https://thinkingmachines.ai/model-card/inkling/)
- [Thinking Machines Lab Releases Inkling | MarkTechPost](https://www.marktechpost.com/2026/07/15/thinking-machines-lab-releases-inkling-a-975b-parameter-open-weights-multimodal-moe-with-41b-active-parameters-and-controllable-thinking-effort/)
- [China's Moonshot throws down the gauntlet with Kimi K3 | SiliconANGLE](https://siliconangle.com/2026/07/16/chinas-moonshot-throws-gauntlet-kimi-k3-worlds-largest-open-weights-model/)
- [China's Moonshot AI releases Kimi K3, the largest open-source model ever | VentureBeat](https://venturebeat.com/technology/chinas-moonshot-ai-releases-kimi-k3-the-largest-open-source-model-ever-rivaling-top-u-s-systems)
- [Kimi K3 launches with 2.8 trillion parameters, open weights July 27 | CryptoBriefing](https://cryptobriefing.com/kimi-k3-open-weights-july-27/)
