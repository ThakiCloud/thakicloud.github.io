---
title: "Controlling Reasoning Effort - How LLMs Learn Low, Medium, and High Thinking Modes"
excerpt: "With GPT-5.6 shipping five or six reasoning effort settings per size, effort control has become table stakes for reasoning models. We dig into what training recipe sits behind the same labels, drawing on technical reports from six open-weight models to map the shared skeleton."
seo_title: "Controlling Reasoning Effort - How LLMs Learn Low/Medium/High Reasoning Modes - Thaki Cloud"
seo_description: "What is reasoning effort and how is it trained? From effort-conditioned SFT and RLVR length penalties to the training recipes and inference-time budget controls of six open-weight models (DeepSeek V4, Nemotron 3 Ultra, Kimi K2.5, GLM-5, Qwen3, Inkling), we summarize Sebastian Raschka's analysis from a cloud and inference serving perspective."
date: 2026-07-19
last_modified_at: 2026-07-19
canonical_url: "https://thakicloud.github.io/en/research/controlling-reasoning-effort-in-llms/"
lang: en
reading_time: true
tags:
  - reasoning-models
  - reasoning-effort
  - rlvr
  - test-time-compute
  - inference-cost
  - deepseek-v4
  - qwen3
  - glm-5
  - kimi-k2
  - nemotron
author_profile: true
toc: true
categories:
  - research
---

If you run inference serving directly, look at GPU budgets, or think about where to attach an expensive model in an agent harness, you have likely run into a setting called "reasoning effort" in recent model release notes more than once. Set it low and things are fast and cheap but the quality suffers; set it high and accuracy improves but tokens and latency balloon. This piece is based on Sebastian Raschka's July 2026 analysis, [Controlling Reasoning Effort in LLMs](https://magazine.sebastianraschka.com/p/controlling-reasoning-effort-in-llms), and unpacks what actually happens behind that setting, and what it takes to train a model to behave that way, from a cloud and inference serving perspective. The bottom line up front: even under the same low/medium/high labels, the training recipe differs from model to model, and there is no single method that can yet be called the correct answer.

## Reasoning models are now the standard, and now you choose the amount of effort

About two years have passed since OpenAI popularized LLM reasoning models with o1, and four months later DeepSeek-R1 opened up the training method itself by publishing a reinforcement learning recipe (RLVR) that uses verifiable rewards. In the time since, reasoning has gone from a special feature to a default building block of new model releases. The GPT-5.6 family released last week ships in three sizes, and each size comes with roughly five or six reasoning effort settings.

A key observation follows from this. Building a reasoning model and letting a user choose how long that model thinks are two separate problems. The former has already been covered extensively, but the latter, namely "how to make the amount of effort a controllable input," is comparatively less well mapped out. In practice, this control capability is a cost lever. If you route easy queries to low effort and reserve high effort only for hard queries, you can raise throughput and quality at the same time on the same GPUs.

## What is reasoning effort

Empirically, raising effort increases the number of tokens generated, and benchmark performance rises along with it. However, this relationship is not linear; the higher the effort tier, the smaller the performance gain per additional token becomes. Thinking Machines' presentation materials for Inkling show exactly this curve: tokens and performance rise together as the effort tier increases, but the gains flatten out in the upper tiers. From a serving standpoint, this means the highest effort setting is not always the best choice.

So how is effort specified at inference time? Surprisingly simply. It is usually controlled with a single line in the system prompt. Even the dropdown menu selection in the ChatGPT UI appears to map internally to a specific system prompt. The problem is that this approach does not work on just any model. The model needs to have been trained so that when it receives an instruction like "effort: low," it actually thinks more briefly while still maintaining quality. In other words, to get easy inference-time control, you have to pay for it by reworking the training pipeline.

## How it is trained: two axes

Whether it is GPT-5.6 or the open-source gpt-oss, the exact training details are not disclosed, but in general the effort label is included inside the prompt during the post-training stage. There are broadly two ways to implement this.

First, during RLVR, you can apply a different length penalty depending on the system prompt. When the setting is "effort: low," a strong length penalty is applied; when it is "effort: high," a weak or absent penalty is applied. This reinforces the model to adjust the length of its thinking on its own, in line with the instructed effort. Second, after RLVR is finished, you can fine-tune with SFT to follow different effort instructions. Here, the training data pairs prompts with target responses that contain the desired amount of reasoning, and those targets may be human-written, generated by another model, or generated and then filtered.

The big picture of both methods looks like this. Most real-world recipes are variations on this skeleton.

```mermaid
flowchart LR
    A["베이스 / RLVR 리즈닝 모델"] --> B["1. SFT + chat template<br/>노력 모드를 입력으로 도입"]
    B --> C["2. mode-conditioned RL<br/>노력별 context window·length penalty 차등"]
    C --> D["3. 하드 예산 강건성 학습<br/>truncated trace·강제 중단 후 재개·budget toggle"]
    D --> E["추론: system prompt로 노력 선택<br/>+ 선택적 토큰 예산"]
```

## A deep dive into six open-weight models

Rather than proof-of-concept research, Raschka picked the recipes of six recent open-weight models that have real-world evidence of working. The level of disclosure varies from report to report, but each shows off one useful variation.

### DeepSeek V4: separating effort into distinct experts

The DeepSeek V4 technical report describes three modes. Non-think answers directly with no reasoning trace, Think High is the classic R1-style approach that puts the reasoning trace between `<think>` and `</think>`, and Think Max adds a special system instruction on top of that. The instruction for Think Max begins with "Reasoning Effort: Absolute maximum with no shortcuts permitted." The key idea is to treat different effort levels almost like separate experts and refine them with mode-conditioned RL.

### Nemotron 3 Ultra: combining a trained mode with a hard budget

Nemotron 3 Ultra uses three settings: reasoning-off, regular, and medium-effort. Medium-effort is a cheaper inference mode than regular, and NVIDIA introduces it during the SFT stage using medium-effort outputs from GPT-OSS-120B, then further optimizes it with RLVR. About 2.5% of RLVR prompts correspond to medium-effort, and a length-based reward adjustment is applied there. On top of this, an inference-time token budget can be layered on as an external stop mechanism. It asks the model to finish reasoning near a client-specified limit, and if the model does not emit `</think>` on its own, the client forcibly closes it. So that the answer does not collapse even when cut off this way, the model is trained on randomly truncated traces to secure robustness.

### Kimi K2.5: a Toggle that alternates between budgeted and unconstrained

Kimi K2.5's method, Toggle, starts from the problem that if you only train with a fixed token budget, the model overfits to short solutions and loses the benefit of extra computation. So it alternates between two phases every set number of training iterations. In the budgeted phase, correct solutions are guided to stay within a per-problem token budget, and in the unconstrained phase, the maximum generation length is restored so the model keeps learning from long solutions as well. The budget is estimated from a specific percentile of correct RLVR rollout lengths, but the budget constraint is only turned on once the average accuracy for that problem has crossed a threshold. The goal is to sharply raise token efficiency while keeping overall benchmark performance about the same.

### GLM-5: turn-level, interleaved, and preserved thinking

GLM-5 extends GLM-4.5's binary on/off switch to multi-turn and tool-use scenarios. Its distinguishing feature is that it defines three related behaviors rather than three effort levels. Interleaved thinking places a reasoning block before every response and tool call, preserved thinking keeps prior reasoning blocks around and reusable across multiple turns, and turn-level thinking turns reasoning on and off per request within a conversation. The actual switch at inference time is turn-level. In the Z.ai API it is on by default and can be disabled on individual requests.

### Qwen3: mode fusion and inference-time truncation

Qwen3's post-training pipeline consists of four stages: long-CoT SFT, reasoning RL, Thinking Mode Fusion, and general RL. The core of the on/off effort switch is Thinking Mode Fusion, which performs SFT on a mix of thinking and non-thinking examples. `/think` examples contain a reasoning trace, while `/no_think` examples start with an empty `<think></think>` block followed by a short answer. The general RL that follows reinforces instruction and format adherence in both behaviors. Qwen3 also supports a hard thinking budget, stopping reasoning at a specified threshold, inserting a stop instruction, and then moving on to the final answer. Interestingly, the report notes that this partial-reasoning behavior was not explicitly trained for but emerged after Thinking Mode Fusion. It is simpler than DeepSeek V4 or Nemotron, but it delivers both a trained on/off switch and an inference-time budget together.

### Inkling: system-prompt effort with mode-conditioned RL

Inkling specifies effort via the system prompt, backed by mode-conditioned RL. As seen earlier, it shows the tendency where raising effort increases tokens and performance together but the gains flatten out at the upper tiers, which is a useful reference point for deciding where to cap effort in serving.

## A shared skeleton: same labels, one underlying frame

Lining up the six models side by side reveals a shared framework. First, SFT and the chat template introduce effort mode as an input. Qwen3 explicitly mixes thinking and non-thinking examples, and GLM-5 adds interleaved, preserved, and turn-level patterns on top. Second, in the mode-conditioned RL stage, the context window and length penalty are varied according to the requested effort. DeepSeek V4, Nemotron 3 Ultra, and Inkling use this approach. Third, robustness under an explicit budget is added. Nemotron trains on randomly truncated traces, Qwen3 can resume from a forcibly stopped reasoning point, and Kimi alternates between budgeted and unconstrained RL. These mechanisms preserve answer quality even when the available reasoning length changes or gets cut off mid-way.

The following table summarizes what is actually documented across the six reports.

| Model | Modes / settings | Training mechanism | Inference-time control |
|---|---|---|---|
| DeepSeek V4 | Non-think / Think High / Think Max | Separate effort experts + mode-conditioned RL | System prompt (Think Max adds an instruction) |
| Nemotron 3 Ultra | off / regular / medium | SFT with GPT-OSS-120B outputs + RLVR (about 2.5%) + truncated-trace training | Chat template + external token budget |
| Kimi K2.5 | budgeted / unconstrained | Toggle: alternating two RL phases | Per-problem token budget |
| GLM-5 | turn-level / interleaved / preserved | SFT extended for multi-turn and tool use | Turn-level on/off switch |
| Qwen3 | think / no_think | Thinking Mode Fusion (mixed SFT) + general RL | On/off + hard thinking budget (truncation) |
| Inkling | Multi-tier effort | Mode-conditioned RL | System prompt |

## Conclusion and the ThakiCloud perspective

What these six cases show is that similar labels can be backed by separate experts, mixed SFT data, mode-conditioned rewards, hard token budgets, or some combination of these. It is hard to declare any single method the best. Each model has a different base checkpoint, training data, post-training compute budget, benchmarks, and serving goals, and the reports omit the detail needed for a fair comparison. A method that fits a conversational assistant well could be a poor fit for a long-running coding agent.

The ultimate goal is, of course, automatic selection of effort. GPT-5's Auto mode once attempted exactly that direction, but it was closer to a failure than a success and eventually disappeared from the UI. In the near future, effort will likely remain an explicit model input, usually passed as a system prompt, while the agent harness or an internal router wrapping the LLM increasingly infers the appropriate mode and budget on its own from task state and remaining budget. Of course, a user override would still be kept around for cases that prioritize latency or cost, or that call for maximum performance.

This is exactly where it connects to our platform operations. If inference budget can be treated as a lever, GPU serving cost and latency can be allocated to match query difficulty. Routing easy requests to low effort and saving high effort only for hard requests, combined with Kueue-based GPU scheduling, opens up real room to raise both throughput and quality on the same cluster. In practice, when running an agent harness, it works out better in cost-to-quality terms to reserve expensive reasoning for a handful of steps like verification and synthesis, and to handle exploration and summarization at low effort. Effort control is not a model bragging point but rather a cost-quality lever that teams operating inference infrastructure pull every day, and it is more practical to read this trend from that angle.

The original piece is rich with links to each model's technical report and diagrams, so if you need the detailed recipe for a specific model, we recommend checking [Sebastian Raschka's original article](https://magazine.sebastianraschka.com/p/controlling-reasoning-effort-in-llms) and the corresponding report directly.
