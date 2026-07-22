---
title: "The Five Layers the Model Map Never Draws: 2026's AI Contest Is Decided Below the Stack"
seo_title: "Five Layers Beneath the AI Model Stack - Inference Silicon, Serving, Evals, Licensing, Harness - Thaki Cloud"
seo_description: "A map that lists which models exist cannot tell you who wins. We trace five layers beneath the model, inference silicon, serving economics, evaluation and observability, open-weight licensing, and agent harnesses, with mid-2026 data, and explain why three of them are exactly where ThakiCloud stands."
excerpt: "The question isn't whether GPT-5.6 is smarter. It's who serves those tokens cheaper and faster, because that's what decides the margin. We map the five stack layers the model-listing map skips: inference silicon, serving, evaluation, licensing, and harness, with real numbers."
date: 2026-07-14
tags:
  - inference-hardware
  - model-serving
  - llm-observability
  - open-weight-license
  - agent-harness
  - reinforcement-learning
categories:
  - news
author_profile: true
toc: true
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/news/stack-layers-model-map-misses/"
---

When we talk about the AI market, we usually line up the models. There's the frontier tier, then Chinese models at half the price, then absurdly cheap ultra-low-cost models, then in-house models built by service companies, and on-device models running on the hardware itself. This map is accurate. It shows clearly which models exist.

But this map cannot answer one question: who wins, and who captures the margin. The answer to that question isn't above the model, it's below it. What silicon it runs on, how it's served, what it's evaluated and observed with, what license it was released under, and what product harness wraps around it. These five layers are where the real contest happens. This piece maps the five layers a model-listing map skips, using real data from mid-2026, and points out that three of these five layers are exactly where our platform stands.

![The five stack layers beneath the model and the three where ThakiCloud stands](/assets/images/stack-layers-model-map-misses-diagram.svg)

*A model map only shows what exists. Of the five layers beneath it, inference silicon, serving economics, and evaluation and observability are the ones that decide margin and the contest, and that is precisely where ThakiCloud stands. Licensing and harness decide who builds a moat on top.*

## Layer One: Inference Silicon Has Become an Independent Battleground

Separate from model quality, "how fast, how cheap can you produce tokens" has become a competitive axis in its own right. Cerebras says it runs the trillion-parameter-class Kimi K2.6 at 981 tokens per second, and Cognition's Devin is an actual customer. At 981 tokens per second, an agent task that calls an LLM 200 times sees its wait time drop from five and a half hours to ten minutes. Windsurf's coding model also runs on Cerebras. Groq pushes small models at hundreds of tokens per second with its LPU, offering Llama 3.1 8B at a floor-level price of $0.05 per million tokens. SambaNova raised $1 billion at a $11 billion valuation on July 8th and has secured JPMorgan, Aramco, and SoftBank as customers.

An important geopolitical axis here is Huawei. DeepSeek V4 was designed from the ground up to train and serve on the Huawei Ascend 950 line. This isn't a port, it's co-design. It means a path has opened to run frontier-class models without Nvidia, which creates room to cut costs regardless of export controls or GPU supply. That said, the figures circulating here, "75 percent price cut, one-fiftieth of Anthropic's," are vendor claims relayed by Chinese media and unverified by a third party, so it's safer to read them as a direction rather than take them at face value.

Here's the core point: Cognition, JPMorgan, and SoftBank all choose silicon independent of which model runs on it. Whoever owns cheap, fast tokens captures the margin no matter which model wins. This layer is entirely invisible on any model leaderboard.

## Layer Two: Serving Economics, Where the Margin Actually Lives

How you serve a model determines its unit economics. As of mid-2026, in the open serving stack, vLLM is the default with the widest hardware support, SGLang has benchmarks showing it beats vLLM by about 29 percent on agent, multi-turn, and RAG workloads thanks to RadixAttention prefix caching, and TensorRT-LLM is the fastest once compiled but is Nvidia-only with a heavy setup cost.

A set of techniques has now become standard. Prefill/decode disaggregation (PD disaggregation) has landed in vLLM and Nvidia Dynamo via NIXL, LMCache eliminates cross-node recomputation with an external KV store, continuous batching is now a baseline assumption across every engine, and speculative decoding is maturing fast. To give a sense of scale: a heterogeneous setup mixing H100 prefill with H200 decode costs about 44 percent more per hour than co-location, but roughly doubles throughput, meaningfully lowering the cost per token. LMCache cuts time-to-first-token by 1.5 to 1.8x. There's no single settled end-to-end figure, but a good rule of thumb is that an optimized serving stack delivers roughly 1.5x to 2x or more in cost and throughput improvement over naive serving.

This layer never shows up on an IQ benchmark leaderboard. But the actual unit economics of an AI product are decided right here, not by model quality.

## Layer Three: Evaluation and Observability, the Floor That Makes Orchestration Possible

Talk of routing multiple models by task comes up constantly. But to actually run that in practice, you need an evaluation and observability layer. Deciding to send a request to DeepSeek, then switch to GLM, then route to Kimi, and knowing what basis to decide on and how to detect regressions, that's this layer's job. Without this layer, orchestration exists only in conversation.

The market has matured into LangSmith, Arize, and the $800 million-valuation Braintrust, with no single winner. On the standardization side, OpenTelemetry graduated from CNCF in May and has become the default baseline for general observability, and its GenAI semantic conventions are defining spans for agents, tools, and models. That said, the GenAI-specific spec is still in development and not yet finalized, so we won't overstate how settled the standard already is. The direction is clear, but it's still in progress. The point is that this evaluation and observability layer is solidifying into an independent market regardless of which model wins.

## Layer Four: Licensing Decides Who Gets to Build a Moat on Top

Behind the single word "open-weight" sit entirely different sets of rights. And that difference decides who is allowed to build a business on top of the model.

| Model | License | Practical constraint |
|---|---|---|
| DeepSeek V4 | MIT | None, fully permissive |
| GLM-5.2 | MIT | None, fully permissive |
| Kimi K2.6 | Modified MIT | UI-credit obligation only above 100M monthly MAU or $20M monthly revenue |
| Qwen (mid-tier) | Apache 2.0 | Permissive, but flagship models have closed off to API-only |
| Meta Llama | Community License | 700M MAU cap, no training competing models, EU multimodal restrictions |

Models released under pure MIT, like DeepSeek and GLM, effectively commoditize the base layer and hand the initiative to whoever fine-tunes or wraps on top of them. Llama's community license, by contrast, looks open but functions more like a control lever, carrying a 700 million MAU cap and a clause banning training of competing models. And licenses aren't fixed, either. In 2026, MiniMax rolled back its fully open MIT license to a Modified-MIT that requires written approval for commercial deployment, an event that showed open terms can be revoked at any time. Any company planning to build its own model should read these license clauses before it reads the performance benchmarks.

## Layer Five: The Moat Isn't the Weights, It's the Harness

The more frontier models converge in raw performance, the more the sustainable moat shifts away from model weights and toward the product harness wrapped around them. That IDE integration, tool orchestration, task loops, and review/PR flows have become the single biggest variable in agent quality is the common thread of 2026 discourse. Cursor's model was trained on trillions of tokens of user interaction that happened on real codebases, data that simply doesn't exist for an independent model lab that doesn't own a harness. Cognition says Devin's PR merge rate rose from 34 percent to 67 percent over a year, a figure that should be weighed with the caveat that it's self-reported and not independently verified.

Here's the mechanism: proprietary interaction logs, records of accepted and rejected edits, task completion status, human corrections, become the reward signal for continual reinforcement learning. Only the harness owner sees the full outcome-labeled interaction trajectories. A lab without a harness has to rely on synthetic or licensed data, which is structurally an inferior signal. So the real competitive map should be drawn not around this quarter's benchmark scores but around who owns the user interaction data and the harness. That said, no lab has published exactly how this flywheel compounds, so while the direction is persuasive, we should be clear that the underlying mechanism is analyst inference.

## The ThakiCloud View

Three of these five layers are exactly where our platform stands: inference silicon utilization in layer one, serving economics in layer two, and evaluation and observability in layer three. ThakiCloud schedules GPUs on Kubernetes, runs batch inference, and handles serving techniques like PD disaggregation and KV cache offloading. On the training side, we offer SFT, CPT, DPO, GRPO, and GKD, the full reinforcement learning family. What the layer-five harness-moat thesis describes, running reinforcement learning in-house using your own data as the reward signal and serving on infrastructure you own, is exactly the trajectory that enterprise customers looking to internalize AI will follow. The serving and training infrastructure that actually makes that trajectory work is what we provide.

Let us set out the strongest counter-argument, too. The claim that these stack layers are the real battleground has limits. If model quality gaps widen enough, serving optimization or silicon choice could become a secondary concern. The harness-moat thesis and the data flywheel mechanism are largely analyst narrative, not methodology that any lab has validated and published, and even the core figures, like Devin's merge rate, are self-reported. And if the price war in the ultra-low-cost tier makes APIs cheap enough, the incentive to take on your own serving and training could weaken on its own. In the end, the judgment differs by organization. What we're selling isn't a forced answer, it's the scaffolding that makes it possible when an enterprise decides to control these layers itself.

A map that lists models will always be needed. But that map alone can't tell you who wins. The contest happens in the five layers beneath the model, and we intend to redraw the changes in those layers every week.

## References

Each layer's techniques and license terms were confirmed against the primary sources below. Vendor self-reported figures, breaking-news funding rounds, and investment announcements were excluded from verification.

**Serving stack and inference techniques**

- [vLLM documentation](https://docs.vllm.ai/en/latest/): the default serving engine with PagedAttention and continuous batching
- [SGLang (GitHub)](https://github.com/sgl-project/sglang) · [RadixAttention paper (arXiv:2312.07104)](https://arxiv.org/abs/2312.07104): prefix caching that lifts multi-turn and RAG throughput
- [NVIDIA TensorRT-LLM (GitHub)](https://github.com/NVIDIA/TensorRT-LLM): compilation-based optimal inference, prefill/decode disaggregation, speculative decoding
- [NVIDIA Dynamo (GitHub)](https://github.com/ai-dynamo/dynamo): PD-disaggregation orchestration and NIXL-based KV transfer
- [LMCache (GitHub)](https://github.com/LMCache/LMCache): external KV cache offload that eliminates cross-node recomputation
- [Speculative Decoding (arXiv:2211.17192)](https://arxiv.org/abs/2211.17192): the speculative decoding technique reshaping serving economics

**Evaluation and observability**

- [OpenTelemetry GenAI semantic conventions](https://opentelemetry.io/docs/specs/semconv/gen-ai/): the standardization effort defining agent, tool, and model spans
- [LangSmith](https://docs.langchain.com/langsmith) · [Arize](https://arize.com/) · [Braintrust](https://www.braintrust.dev/): leading tools in the evaluation and observability layer

**Open-weight licensing**

- [Llama Community License](https://developer.meta.com/ai/llama3_1/license/): looks open but is a control-oriented license carrying an MAU cap and a ban on training competing models
- [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0) · [MIT License](https://opensource.org/license/mit): permissive licenses that effectively commoditize the base layer

---

*The model names, prices, licenses, and release timing in this article were verified against publicly available sources as of July 14, 2026. Vendor self-reported figures (inference speed, PR merge rate, Huawei cost-savings claims) and third-party-unverified items are flagged in the body text.*
