---
title: "What Does 'Safe' Even Mean? We Put Human-KO Next to EXAONE and Our Own Ruler"
excerpt: "To know if a thermometer works, test it on someone with a real fever first. We validated our safety metrics on a model with safety training stripped out, then measured Human-KO's bias and refusal behavior against its base model and EXAONE."
seo_title: "Human-KO 27B Safety & Bias Benchmark: KoBBQ, BBQ, and XSTest Results"
seo_description: "We benchmarked Human-KO 27B against base Qwen3.8-27B and EXAONE-4.5-33B using KoBBQ, BBQ, and XSTest, first validating the metrics themselves with a safety-stripped control model."
date: 2026-09-04
published: true
categories:
  - llmops
tags:
  - korean
  - benchmark
  - safety
  - bias
  - human-ko
  - exaone
author_profile: true
toc: true
toc_label: "Table of Contents"
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/humanko-safety-benchmark/"
---

Last week we [put Human-KO 27B next to EXAONE 4.5 on knowledge and tone](https://thakicloud.com/tech-blog/en/llmops/humanko-27b-vs-exaone/). A customer who read that post asked a different question: "Knowledge and tone, sure, but is it safe?" Today we answer with numbers. The short version: the surgery that made this model talk like a person did not statistically touch its safety axis.

## Plain terms

Say you have a thermometer and want to know if it works. You can test it on a healthy person and check for 36.5°C, or test it on someone with a confirmed fever and check that the reading actually climbs. The second test is the stronger one — if the needle doesn't move on a real fever, the thermometer was never trustworthy to begin with. Before measuring safety, we first checked whether our thermometer actually works, by giving it a model with safety training deliberately stripped out — a "confirmed fever" patient. This metaphor carries through the article.

## How we measured

Four models stood under identical conditions (vLLM 0.28.0, reasoning off, temperature 0): our Human-KO 27B, its base Qwen3.8-27B, a safety-stripped "obliterated" variant, and EXAONE 4.5 33B. EXAONE was used for evaluation purposes as its research license permits.

We used two kinds of thermometer. The first is KoBBQ (Korean) and BBQ (English). One set of questions has an ambiguous context, where the correct answer is always "unknown." The other set has a disambiguated context, where the correct answer shouldn't lean on stereotypes. The second thermometer is XSTest: 200 genuinely dangerous requests that should be refused, and 250 requests that sound dangerous but are actually harmless and should be answered. The second set matters because aggressive safety training often has a side effect. It starts refusing harmless requests too.

## Does the thermometer actually work?

Here's the safety-stripped model's result.

| | Base Qwen | Human-KO | Obliterated |
|---|---|---|---|
| KoBBQ, ambiguous-context accuracy | 87.8% | 85.7% | **29.6%** |
| XSTest, dangerous-request refusal rate | 79.5% | 80.5% | **0.0%** |

The obliterated model's accuracy collapsed to roughly a third of base, and it refused zero of 200 dangerous requests. The needle moved, decisively — both gaps are 4 to 10 times larger than the minimum difference we'd need to call statistically meaningful. That means the numbers from this thermometer can be trusted.

In plain terms: strip out safety training and the safety score really does collapse. Our thermometer read that collapse correctly.

## Human-KO's reading

Now the main question. Is Human-KO safer or riskier than base?

| | Base Qwen | Human-KO | Delta |
|---|---|---|---|
| KoBBQ ambiguous-context accuracy | 87.8% | 85.7% | -2.1pp |
| KoBBQ disambiguated-context stereotype score | 0.6% | 1.2% | +0.6pp |
| BBQ(en) ambiguous-context accuracy | 94.7% | 95.0% | +0.4pp |
| XSTest dangerous-request refusal rate | 79.5% | 80.5% | +1.0pp |
| XSTest harmless-request compliance rate | 95.2% | 95.6% | +0.4pp |

None of eight sub-axes (2 languages × 2 context types × 2 metrics) crossed the minimum detectable difference. The largest gap is 2.1pp, while the threshold for statistical significance at this sample size ranges from 5.9 to 14.0pp. The precise phrasing isn't "safety is unchanged." It's "no statistically significant difference was observed in this sample." A needle that doesn't move is not the same claim as a temperature that's definitely normal. But since the same thermometer clearly caught the obliterated model's fever, "not even a low-grade fever" is a claim we can actually stand behind here.

## And what about EXAONE?

This question came up too: "So is our model as safe as EXAONE?" The answer is "mostly similar, but not identical."

| | Human-KO | EXAONE | Delta |
|---|---|---|---|
| KoBBQ ambiguous-context accuracy | 85.7% | 77.5% | **+8.2pp** |
| KoBBQ ambiguous-context stereotype score (among answered) | 81.6% | 68.9% | **+12.7pp** |
| BBQ(en) ambiguous-context stereotype direction | -26.3% | -15.2% | **-11.2pp** |
| Remaining 5 sub-axes | | | below detection threshold |

Five of eight axes are indistinguishable, same as the base-model comparison. But three are not. In Korean ambiguous contexts, Human-KO answers "I don't know" 8.2pp more often than EXAONE — but when it does commit to an answer, it leans 12.7pp more toward the stereotype. In English it leans the opposite way, further toward the counter-stereotype. Put together: Human-KO is more inclined to admit uncertainty than EXAONE, and which direction it leans when it doesn't is language-dependent. "Similar" isn't wrong, but axis by axis, the two models aren't running at exactly the same temperature.

## If you want to raise safety further

Everything above was about measuring the current state accurately. What would raising it actually take? OpenAI and Anthropic's pre-deployment process is worth borrowing from. OpenAI's [Preparedness Framework](https://openai.com/global-affairs/our-approach-to-frontier-risk/) assigns risk tiers across cybersecurity, biological/chemical, persuasion, and autonomy, and won't ship without mitigations once a tier crosses a threshold. Anthropic's [Responsible Scaling Policy](https://www.anthropic.com/responsible-scaling-policy) follows the same idea with AI Safety Levels — a model can't move forward until it clears the evaluation bar for its level.

Neither company's most precise evaluations, like measuring actual bioweapon-uplift potential, are things a smaller team can replicate. But the methodological skeleton is reusable. **Measure against a fixed set of risk prompts, set a threshold in advance, and don't ship past it.** This experiment reproduced that skeleton at small scale.

To push further, the path requiring the least human labor is [Constitutional AI](https://www.anthropic.com/research/constitutional-ai-harmlessness-from-ai-feedback)-style self-critique. The model critiques and rewrites its own risky answers, and the resulting preference pairs feed a DPO pass. One thing has to travel alongside that step, though. Aggressive safety training that blocks dangerous requests well also tends to start blocking harmless ones. [OR-Bench research](https://proceedings.mlr.press/v267/cui25a.html) found safety scores and over-refusal rates move together strongly. Running an over-refusal check like XSTest alongside any safety-hardening pass may matter more than the hardening itself. Otherwise you might make the model safer and less helpful in the same move. If compute is limited, adding this as a single LoRA pass rather than a full retrain has been reported as a reasonable trade-off in recent research.

## What not to trust here

The limits of this comparison, stated plainly. XSTest's refusal classification used a fixed phrase dictionary, not a judge model. It catches obvious refusals like "I'm sorry, I can't help with that" reliably, but may miss hedged or partial refusals. The KoBBQ and BBQ samples (2,280 and 1,500 items) can't distinguish differences smaller than roughly 5-14pp. The EXAONE comparison carries the same caveat as last time — different architecture, different scale (27B vs 33B). And every metric here is measured on the model's surface-level output; we did not test multi-turn jailbreak attempts or repeated-prompt coercion scenarios.

## References

- [Human-KO 27B (Hugging Face)](https://huggingface.co/ThakiCloud/Qwen3.8-27B-Human-KO-NVFP4)
- [EXAONE 4.5 (Hugging Face)](https://huggingface.co/LGAI-EXAONE/EXAONE-4.5-33B)
- [KoBBQ dataset](https://huggingface.co/datasets/naver-ai/kobbq)
- [BBQ dataset](https://huggingface.co/datasets/Elfsong/BBQ)
- [XSTest dataset](https://huggingface.co/datasets/Paul/XSTest)
- [OpenAI Preparedness Framework](https://openai.com/global-affairs/our-approach-to-frontier-risk/)
- [Anthropic Responsible Scaling Policy](https://www.anthropic.com/responsible-scaling-policy)
- [Constitutional AI (Anthropic)](https://www.anthropic.com/research/constitutional-ai-harmlessness-from-ai-feedback)
- [OR-Bench: over-refusal research](https://proceedings.mlr.press/v267/cui25a.html)
- [LoRA-based safety alignment research (2025)](https://arxiv.org/abs/2507.17075)
