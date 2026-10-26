---
title: "The 33B agent model built by a job platform, Nanbeige4.3-33B"
excerpt: "Nanbeige LLM Lab of BOSS Zhipin released Nanbeige4.3-33B, a 33B dense model, under Apache 2.0. We re-computed their self-reported table, leading 17 of 20 agentic benchmarks, from the config.json we received and verified it."
seo_title: "Nanbeige4.3-33B Released: A 30B-Class Open Agent Model and the Teacher-Distillation Strategy | ThakiCloud Tech Blog"
seo_description: "33B dense, 512K context, Apache 2.0. We verify the self-reported Terminal-Bench 2.1 score of 80.9 with independent config.json-based computation and analyze serving practicality and the teacher-distillation strategy."
date: 2026-10-26
last_modified_at: 2026-10-26
author_profile: true
toc: true
toc_label: "Table of Contents"
toc_icon: "robot"
tags:
  - nanbeige
  - open-weight-llm
  - agentic-coding
  - distillation
  - vllm
  - boss-zhipin
categories:
  - news
canonical_url: "https://thakicloud.com/tech-blog/en/news/nanbeige43-33b-open-agentic-teacher/"
---

![A visualization of Nanbeige4.3-33B, the 33B agent model built by a job platform](/assets/images/nanbeige43-33b-open-agentic-teacher-hero.webp)
*The poster of the model that put out the widest agentic benchmark table among 30B-class open models.*

## Why you should read this

An ML engineer choosing a 30B-class open model to run in their own agent workflow, and a platform team managing a serving catalog, should read this. To the conclusion first. Nanbeige4.3-33B, the 33B dense model released by the Nanbeige LLM Lab of BOSS Zhipin (a Chinese job platform), self-reports leading 17 of 20 agentic benchmarks among 30B-class open models, and we re-computed that table using the config.json we received directly and confirmed that all the structural numbers match. However, 3 of the 20 rows contradict the official model cards of competitors, which makes the strategy of "build the teacher model first, then distill" a more important signal than the numbers themselves.

## Overview

On October 24, two repositories appeared in the Nanbeige organization on Hugging Face. The Instruct version, Nanbeige4.3-33B, and Nanbeige4.3-33B-Base for custom post-training. The license is Apache 2.0, the languages are English and Chinese, and the input is text-only. The context length is 524,288 tokens (512K).

The maker, as the model name suggests, is the Nanbeige (南北阁) LLM Lab, a research team inside the job platform BOSS Zhipin. The model card's contact address, nanbeige@kanzhun.com (Zhipin's domain), is the evidence. The release clock is fast. The Instruct model card landed on Hugging Face on October 24 (UTC 02:49), and two days later, on the 25th, it already had more than 400 likes along with one community GGUF quantized version registered. According to the research team, the strategy of the Nanbeige4.3 series is to "build a high-capacity teacher agent first, then distill agent capabilities into smaller models." The 33B is the flagship teacher model of this series, and a small-model distillation pipeline such as Nanbeige4.3-3B is teased as the next step.

The interesting point is the organizational identity of a job platform. A job platform is one of the industries with the deepest accumulation of job-performance data (what people do, how they are evaluated, what tools they use). The fact that the organization behind occupation-specific agentic benchmarks like JobBench has exactly this structure means that the data and the benchmarks come from the same place.

This is not a first-time team. An earlier release from the same Nanbeige organization, Nanbeige4.2-3B, was a 3B-class endi model that collected more than 700 likes near the top of Hugging Face trending LLMs in mid-September. The series number moving from 4.2 to 4.3 means the team that first looped agent endi on a 3B-class model has now moved up to a 33B teacher. The order "validate with a small model, build the teacher, then distill into a small model again" is this organization's actual track record of motion.

## What is this model

The structure, as we received and checked the config.json directly, is a standard LlamaForCausalLM. Not MoE but dense, meaning the full 33B parameters are active on every token. The key specs read as follows.

- Hidden 7,168, 52 layers
- GQA: 56 query heads, 8 KV heads, head dim 128
- FFN intermediate 22,016, SiLU activation, no biases in attention or MLP
- Vocab 166,912, RoPE theta 120M
- lm_head not shared with the embedding (tie_word_embeddings=false)

The chat template has three switches. enable_thinking turns on reasoning (thinking block) generation and defaults to on, and preserve_thinking decides whether thinking from previous turns is retained. The research team recommends False for ordinary conversation and True for multi-turn tool use and code agent workflows. Tool calls are recommended in XML format, with JSON also supported. The noteworthy point is the serving recipe. Both the vLLM and SGLang examples use 4-way tensor parallelism (tp-size 4) with --reasoning-parser qwen3 --tool-call-parser qwen3_coder. The model has a Llama architecture, yet the parsers follow the Qwen3 family conventions.

Recommended inference settings are also published. Agentic and tool tasks get temperature 1.0, top_p 0.95, and max new tokens 65,536, while reasoning and chat get temperature 0.6, top_p 0.95, and max new tokens 262,144. Recommending temperature 1.0 for agent tasks is notable. It reflects the judgment that sampling diversity can contribute to evaluation scores in tool calling and exploratory agent behavior, which is a signal that agentic coding models should be served with a different inference profile from ordinary chat models.

The choice of dense itself is worth reading. With MoE architectures common at the 30B class, choosing a dense model that turns the full parameter set on every token is most plausibly aimed at predictability of inference cost. MoE has fewer active parameters and lower per-serving cost, but it must load the entire weight set into memory, with a large footprint for loading, networking, and caching. A dense 33B pins the serving requirement to a single number, 66GB of weights, and the 4-way tensor parallelism recommendation becomes the deployment plan as-is. Agent workloads are long-context and tool-call-heavy by default, so per-token cost stability matters as much as batch throughput. It is more reasonable to read this as choosing "the structure with the most predictable cost" rather than "the structure that looks the most expensive."

## Independent verification: recomputing from config.json

Rather than trusting the model card's numbers at face value, we independently recomputed the parameter count and memory figures from the config.json we received from HF. The verification script and output are kept in the repository alongside this post (outputs/blog-impl/nanbeige43-33b-open-agentic-teacher/).

The computed results are as follows.

- Attention per layer 117,440,512 + MLP 473,432,064 + norms 14,336 = 590,886,912 per layer
- 52-layer total 30,726,119,424
- Embedding 1,196,425,216, unshared lm_head 1,196,425,216
- Total 33,118,969,856 parameters, about 33.12B
- BF16 weights 66.2GB (61.7GiB)
- KV cache 212,992 bytes/token (208KiB, BF16)
- Full 512K context KV cache about 104GiB

The "33B dense" name matches the actual 33.12B. The 66GB weights estimated by secondary reporting (marktechpost), the 208KiB per-token KV cache, and the 112GB (in GB terms) full-context figure also match our computation. In other words, the structure-related numbers are reproducible from the published config alone.

What is practically readable from this computation is the KV cache. At 208KiB per token, opening the 512K context as-is puts the KV cache alone over 100GiB. Stacking that on top of 66GB of weights is only possible on a multi-GPU cluster, and in practice lowering maxModelLen or KV quantization becomes a precondition.

Translated into working context it goes like this. At 32K context per request, the KV cache is about 6.4GiB; at 128K, about 25.8GiB. Splitting BF16 weights across 4-way tensor parallelism brings weights per GPU down to the 16.5GB level, so with a combination of four 80GB-class GPUs (e.g., four H200/B200s) the arithmetic holds for 66GB of weights plus KV caches of dozens of concurrent requests. The name "512K context" is the upper bound of the positional information the model was trained on, not a statement that serving opens the full range. Setting maxModelLen to the actual context distribution of the agent workload is the core variable of a serving plan.

## Actual benchmark results

The model card's comparison table pits the model against three: Qwen3.8-27B, Muse-Glimmer-30B, and Gemma4-31B, declaring all of them evaluated at maximum thinking effort with identical inference hyperparameters and harness. The table below is part of those rows for agentic coding and co-working.

| Benchmark | Nanbeige4.3-33B | Qwen3.8-27B | Muse-Glimmer-30B | Gemma4-31B |
|---|---|---|---|---|
| Terminal-Bench 2.1 | 80.9 | 73.0 | 61.8 | 47.2 |
| Terminal-Bench 4.0 | 23.8 | 6.3 | 1.6 | 0.0 |
| DeepSWE | 65.5 | 42.5 | 4.4 | 2.7 |
| SWE-Bench Pro | 60.3 | 61.7 | 36.9 | 51.2 |
| Automation Bench | 54.2 | 38.3 | 15.2 | 9.7 |
| JobBench | 44.8 | 34.5 | 16.6 | 9.0 |
| GPQA Diamond | 89.5 | 89.2 | 83.5 | 91.3 |

![Agentic coding and co-working benchmark comparison of Nanbeige4.3-33B against three 30B-class open models](/assets/images/nanbeige43-33b-open-agentic-teacher-results.webp)
*A comparison chart drawn from the model card's self-reported numbers. Nanbeige4.3-33B leads 17 rows, but trails Qwen3.8-27B on SWE-Bench Pro and GDPval, and Gemma4-31B on GPQA Diamond.*

The model card claims it leads 17 of the full 20 rows. The three it trails are SWE-Bench Pro (60.3 vs 61.7), GDPval (84.8 vs 86.4), and GPQA Diamond (89.5 vs 91.3). The row carrying its own lowest score is Terminal-Bench 4.0 at 23.8, and since all competitors sit below 7, the relative advantage holds.

On YC-bench, it reports a simulated profit of $1,025,437, well ahead of Qwen3.8-27B ($641,290). It also claims to beat the baseline in most of JobBench's 35 occupations.

The model card footnotes go as far as publishing the evaluation harnesses. Terminal-Bench 2.1 was run with Terminus 2, Terminal-Bench 4.0 and DeepSWE with mini-swe-agent v2.4.6, and SWE-Atlas-QnA with GPT-6 Sol as judge against a rubric dedicated to its 1,304 tasks. NL2Repo and JobBench were run under the Claude Code harness (JobBench with a search tool included), Claw-Eval is pass^3 on a General subset of 157 single-turn tasks, and YC-bench keeps only the most recent 10 turns as prior context per model call. Having which benchmark was measured with which tool's harness written into the table footnotes means that even a self-report has a clear starting point for reproduction.

There is one comparison for the Base model as well. According to secondary reporting, Nanbeige4.3-33B-Base leads Gemma4-31B-Base on all 8 reported tasks, with MMLU-Pro at 66.9 vs 59.3 and GPQA at 62.0 vs 41.5. For organizations planning custom post-training, this Base is the practical starting point.

One more practical point. At the time of release, no Hugging Face Inference Provider hosts this model. That means no ready-to-call API; it is weights you must serve yourself. This ties into the model's positioning as "weights to distill and post-train." The model card explicitly invites "collaboration on domain-specific, industry-specific agents, joint work including data and training," and attaching this degree of open language to a 33B open-weight release reads as the research team treating these weights not as a finished product but as a platform for industry co-development.

We did not stop there, though; we checked. According to secondary reporting (marktechpost), some rows in this table disagree with the competitors' official model cards. On SWE-Bench Pro the values for Muse and Gemma are swapped (official: Muse 51.2, Gemma 36.9 / Nanbeige table: Muse 36.9, Gemma 51.2), and Gemma4-31B's GPQA Diamond rises to 91.3 against Google's official 84.3. The Muse value on Terminal-Bench 2.1 is also 61.8 versus the official 51.7. Some of this may be explained by harness differences, but the swapped SWE-Bench Pro pair is most likely a simple typo.

## Implications for ThakiCloud products

Read from the Metis (serving) perspective, it comes down to this. 66GB in BF16 with a 4-way tensor parallelism recommendation means this is not a single 80GB GPU placement; it is either bundling four GPUs or serving on one or two after quantization (FP8/INT4 class). If ThakiCloud's ai-platform puts this model into its multi-tenant serving catalog, serving the full 512K maxModelLen is unrealistic because of the 100GiB KV cache; limiting to working context (32K-128K) or assuming KV quantization is the sound move. The parser combination (qwen3 reasoning + qwen3_coder tool) aligns with the Qwen3-family parser conventions we use in Metis tuned-defaults, so it can be applied as-is to vllm_overrides at endpoint registration.

From the Paxis (Agent-Native Cloud) perspective, the "build the teacher first, distill into a small model" order matters more. Paxis's workflow execution unit price scales directly with model size. If 33B dense has reached a level that can carry agent workloads, the arithmetic holds for distilling that capability into 3B-7B class models and putting them into Paxis's low-price tier workers. This release, a 30B-class open model crossing the practical threshold in agent coding, is a signal that the starting point of that distillation pipeline actually exists. When Nanbeige4.3-3B arrives, comparing it against this 33B table is how to verify that signal.

## Limitations and counterarguments

First, all benchmark numbers are self-reported. There is no independent reproduction yet, and three competitor rows contradict the official cards.

From a quantization perspective, plugging in the parameter count we verified (33.12B) gives roughly 33.1GB for FP8 weights and 16.6GB for INT4. This is a weights-only computation excluding the KV cache, but it means that anything other than BF16 fits on a single 80GB GPU, and INT4 opens the range to 40-50GB class hardware. Of course, performance loss under quantization is unverified. Since the model card reports BF16 numbers only, the "33B agent model at cheaper serving" arithmetic has to remain an estimate ([estimate]) until independent benchmarks and quantization evaluations appear. Second, a dense 33B turns the full parameter set on every token, so at equal performance its serving cost is structurally higher than an MoE model's. "Performance leadership" and "serving efficiency" are separate claims, and this model makes only the first. Third, it is text-only. There is no multimodal input (the config's chat template includes wording that rejects multimodal input), so agent workflows that need vision are out of scope. Fourth, the "about 30B class" comparison group actually spans 27B to 31B, and the 33.12B we computed sits at the larger end of that range. Whether the convenience of the comparison flatters the model cannot be answered before independent runs.

## Conclusion

Nanbeige4.3-33B should be judged on two facts rather than on the number table. One is that an in-house research team at a job platform simultaneously released, under Apache 2.0, a 33.12B dense (re-verified by us from config.json) with a 512K context and the claim of leading 17 rows of agentic benchmarks. The other is that this model is the teacher of a distillation pipeline, and the real value is in the small model that comes next. The next action is simple. Hold purchase and serving decisions until independent reproduction (Terminal-Bench 2.1/4.0, SWE-Bench Pro) appears, and if serving is under consideration, reserve a trial endpoint in the Metis catalog premised on quantization plus maxModelLen limits. When Nanbeige4.3-3B is released, let's check it again alongside the 33B table.

---

## Sources

- [Nanbeige4.3-33B model card (Hugging Face)](https://huggingface.co/Nanbeige/Nanbeige4.3-33B)
- [Nanbeige4.3-33B-Base (Hugging Face)](https://huggingface.co/Nanbeige/Nanbeige4.3-33B-Base)
- [MarkTechPost: Nanbeige Releases Nanbeige4.3-33B, a 33B Open Agentic Coding Model](https://www.marktechpost.com/2026/10/25/nanbeige-releases-nanbeige4-3-33b-open-agentic-coding-model/)
- [Announcement tweet (@nanbeige)](https://x.com/nanbeige)

*Independent verification script and output: `outputs/blog-impl/nanbeige43-33b-open-agentic-teacher/verify_math.py` (run-1.log)*
