---
title: "OPD Post-Training: How GLM-5.2 Merged 10+ Expert Models in Two Days"
excerpt: "Building GLM-5.2, Z.ai open-sourced its entire RL post-training infrastructure. We analyze OPD post-training, which merged more than ten expert models in about two days, and what an open RL stack means for on-premise training from a ThakiCloud K8s perspective."
seo_title: "GLM-5.2 OPD Post-Training and Open-Source RL Infrastructure - Thaki Cloud"
seo_description: "GLM-5.2 parallel OPD post-training, merging 10+ expert models, slime open-source RL infrastructure, and K8s-based on-premise RL training analysis"
date: 2026-06-22
last_modified_at: 2026-06-22
lang: en
categories:
  - llmops
tags:
  - glm
  - opd
  - post-training
  - reinforcement-learning
  - model-merging
  - open-source
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/en/llmops/glm-5-2-opd-post-training-open-rl-infra/"
reading_time: true
---

A frontier-grade lab releasing only model weights is no longer unusual. Z.ai (THUDM) went one step further with GLM-5.2: alongside the weights, it open-sourced the entire reinforcement-learning (RL) post-training infrastructure used to build the model. The most striking part is the post-training method itself. Z.ai reports that it merged more than ten expert models into the final GLM-5.2 in about two days. It calls this parallel merging process OPD.

At ThakiCloud, we run training workloads and GPU orchestration on a K8s-based AI/ML SaaS platform. A case where the full "how the frontier model was trained" is published is a rare reference for anyone designing on-premise training infrastructure. This post examines what OPD post-training is, and what changes when the whole RL stack becomes open.

> A general overview of the slime RL post-training framework itself is covered in a separate post, [RL Post-Training as Infrastructure: the slime Open-Source Framework and RL Scaling](https://thakicloud.github.io/llmops/slime-rl-post-training-infrastructure/). This post focuses on the OPD post-training and expert-model merging that run on top of it.

## Slide Summary: OPD Post-Training and the Open RL Stack

The slides below were generated automatically from the source with NotebookLM (`strategic_blue` style). They are the original slides rendered by NotebookLM, not GPT image regenerations.

![GLM-5.2 OPD post-training slide 1](/assets/images/tw-2068253789589741847-slide-01.png)

![GLM-5.2 OPD post-training slide 2](/assets/images/tw-2068253789589741847-slide-02.png)

![GLM-5.2 OPD post-training slide 3](/assets/images/tw-2068253789589741847-slide-03.png)

![GLM-5.2 OPD post-training slide 4](/assets/images/tw-2068253789589741847-slide-04.png)

![GLM-5.2 OPD post-training slide 5](/assets/images/tw-2068253789589741847-slide-05.png)

![GLM-5.2 OPD post-training slide 6](/assets/images/tw-2068253789589741847-slide-06.png)

![GLM-5.2 OPD post-training slide 7](/assets/images/tw-2068253789589741847-slide-07.png)

![GLM-5.2 OPD post-training slide 8](/assets/images/tw-2068253789589741847-slide-08.png)

![GLM-5.2 OPD post-training slide 9](/assets/images/tw-2068253789589741847-slide-09.png)

![GLM-5.2 OPD post-training slide 10](/assets/images/tw-2068253789589741847-slide-10.png)

![GLM-5.2 OPD post-training slide 11](/assets/images/tw-2068253789589741847-slide-11.png)

![GLM-5.2 OPD post-training slide 12](/assets/images/tw-2068253789589741847-slide-12.png)

_(Showing 12 of 17 slides. See the deck file for the rest.)_

## What kind of model is GLM-5.2

First, the target model. GLM-5.2 is a 753B open-weight model. It targets long-horizon tasks and supports a 1M-token context. Z.ai states that a technique called IndexShare cuts per-token FLOPs by 2.9x at a 1M context length. In other words, the design aims to handle long contexts while keeping inference cost in check.

The benchmark numbers show where it sits. On Terminal-Bench 2.1, which evaluates coding tasks, it scored 81.0, chasing Claude Opus 4.8's 85.0. On SWE-bench Pro it reached 62.1, up from the previous GLM-5.1's 58.4. On FrontierSWE, which measures long-horizon work, the gap to Opus 4.8 narrowed to about 1%. The key point is an open-weight model that has closed the gap with closed frontier models to single digits. The license is MIT, and it is available on HuggingFace and ModelScope.

The weight of this case is that "how a model of this caliber was trained" has been made public.

## What is OPD post-training

OPD is the parallel training and merging method used in the GLM-5.2 post-training stage. The idea is simple but demanding on infrastructure. Instead of training one giant model on every capability at once with RL, you separately RL-train several expert models per capability and then merge them into one final model.

According to Z.ai's report, the GLM-5.2 post-training used slime to run parallel OPD training, merged more than ten expert models into the final model, and the entire OPD process took about two days. Two numbers stand out here. More than ten expert models means capabilities such as coding, agentic behavior, and reasoning were separated and each raised with RL. And about two days means that training and merging that many experts ran in a workable, not impractically long, time. (The exact expansion of the OPD acronym is not explicitly confirmed in the official material, so we do not assert it here. The verified facts are the behavior of "parallel expert training followed by merging" and the numbers above.)

The practical advantages of this approach are clear.

- **Parallelism**: Training per-capability experts independently distributes the work. You can spread across a GPU pool more widely than RL-training one giant model serially over every domain.
- **Isolated reward design**: Coding and reasoning have different reward signals. Separating experts lets you give each domain its own reward and verifier, and contains the blast radius of reward hacking within one expert.
- **Iteration speed**: When you fix one domain's data or reward, you do not have to rerun everything. You retrain only that expert and refresh the merge step.

The difficulties come along with it. When several experts are merged into one, capabilities can interfere or cancel each other out. If the merge is not a simple weight average but includes a separate training process, then the merge itself becomes another post-training stage. The reason Z.ai phrased it as "parallel OPD training" is likely that merging goes beyond plain arithmetic averaging.

## slime: the open-source RL infrastructure behind OPD

The foundation that made OPD possible is slime. slime is an LLM post-training framework for RL Scaling, released under Apache-2.0. Its structure splits into three parts.

- **Training (Megatron)**: Handles the policy training loop, reading from the data buffer.
- **Rollout (SGLang + router)**: Generates new data and stores it back to the buffer.
- **Data Buffer**: Manages prompt initialization and custom data generation workflows.

The design principle slime emphasizes is being asynchronous and decoupled. Megatron training, SGLang rollout, custom data generation, reward computation, verifier feedback, and environment interaction all flow through the same training and rollout path. RL post-training is hard at the infrastructure level precisely because inference (rollout) and training (update) alternate in one loop. slime separates the two so each can be scheduled to fit its own resource profile.

The supported model range is broad. It supports the Qwen series (Qwen3.6, Qwen3.5, Qwen3Next, Qwen3MoE, Qwen3, Qwen2.5), the DeepSeek V3 series (V3, V3.1, R1), and Llama 3. Having been used in actual frontier model training from GLM 4.5 through 5.2 lends trust that this is battle-tested code.

Installation follows standard Python packaging. The repository includes `requirements.txt`, `setup.py`, and `pyproject.toml`, and provides a containerized environment via the `/docker` directory. That said, running real RL post-training requires many GPUs, so this post does not reproduce the training directly and instead focuses on analyzing the published facts and structure. Fabricating numbers on a single workstation would be a distortion, so we did not.

## What it means for the entire RL stack to be open

Releasing weights and releasing training infrastructure carry different weight. With weights alone you can run inference, but the path to RL-post-train that model for your own domain stays closed. Conversely, when the training infrastructure opens up too, the following become possible.

- **Reproducibility**: You can follow the reported post-training procedure at the code level. What you get is an executable pipeline, not a figure in a paper.
- **Domain adaptation**: On top of the open RL stack, you can train and merge experts with your own data and your own rewards. OPD-style per-capability separation becomes applicable to your own domain.
- **Cost control**: You can run post-training on-premise rather than handing training to an external API. Since data does not leave, it also helps with regulatory compliance.

The core point is that "how frontier models are made" is no longer closed know-how but published engineering. This sharply lowers the barrier to entry for organizations that want to refine models with their own infrastructure.

## Applying this on the ThakiCloud K8s AI/ML SaaS platform

The picture OPD and slime paint overlaps precisely with the training-infrastructure problems we handle on K8s.

The first is GPU orchestration. To train more than ten experts in parallel like OPD, you have to schedule many training jobs at once and, within each job, place workloads of different character, rollout (inference) and policy update (training), onto the same GPU pool. ThakiCloud manages GPU job queuing and quotas with Kueue, so a structure of spinning up each expert's training as an independent job with assigned priority and resource caps fits naturally. slime's asynchronous, decoupled design maps well onto a K8s pattern of scaling rollout pods and training pods separately.

The second is multi-tenant post-training. Our platform runs workloads across many customer environments. OPD's separated expert training resembles a workflow of training experts per tenant and per domain and then merging them. We can consider designs that isolate expert training so customer data does not mix, and perform only the merge step in a controlled environment.

The third is on-premise economics. If the post-training stack is open source and the target model is MIT-licensed, a path opens to refine domain-specialized models on-premise without an external training service. For customers who cannot export data, who must control cost, and who have strong in-house security requirements, this becomes a product advantage. It sits on the same line as the self-hosting and cost-efficiency direction we have emphasized.

Reproducing the full OPD right away is a heavy task that needs many GPUs. Still, spinning up a small-scale slime-based RL post-training as a Kueue job to validate the pipeline, then gradually expanding the operating patterns learned there, is a realistic roadmap.

## Limitations and counterarguments

For balance, the weaknesses too.

The biggest constraint is the limit of verification. The figures of ten-plus experts and about two days are Z.ai's own report, not results independently reproduced by outsiders. The exact definition of the OPD acronym and the details of the merge algorithm are not fully revealed by public material alone. So this analysis is an interpretation grounded in published behavior and numbers, and we have avoided asserting the internal mechanism.

The wall of scale is also clear. Open infrastructure does not mean anyone can post-train a 753B model. Parallel expert training and merging require substantial GPUs, data, and reward-design expertise. Open source lowers the entry barrier but does not remove the resource barrier.

The merge itself carries risk. When per-capability experts are combined, one capability can erode another, and benchmark scores can diverge from real usability. A model merged from several experts may show hard-to-predict behavior in certain combinations.

Even so, the direction is clear. The trend of frontier model training procedures being published in executable form genuinely widens the options for organizations that want to run models on their own infrastructure. For a platform like ours that handles training and serving together on K8s, that is especially true.

## Sources

- [GLM-5.2: Built for Long-Horizon Tasks (Z.ai blog)](https://huggingface.co/blog/zai-org/glm-52-blog)
- [THUDM/slime: RL post-training framework (GitHub)](https://github.com/THUDM/slime)
- [zai-org/GLM-5 (HuggingFace)](https://huggingface.co/zai-org/GLM-5)
- [z.ai's open source GLM-5 and the slime RL technique (VentureBeat)](https://venturebeat.com/technology/z-ais-open-source-glm-5-achieves-record-low-hallucination-rate-and-leverages)
- Related post: [RL Post-Training as Infrastructure: the slime Open-Source Framework and RL Scaling](https://thakicloud.github.io/llmops/slime-rl-post-training-infrastructure/)
