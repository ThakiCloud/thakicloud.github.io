---
title: "Chinese Characters Leaking Into Korean Output? Check Your Temperature First"
excerpt: "Qwen3.8-27B drops Han characters mid-sentence when answering in Korean. Chasing the cause, we found that a single generation setting accounts for a 5x swing, and pruning the output path cut real errors from 1.81% to 0.18% while keeping Korean Hanja notation alive."
seo_title: "Korean LLM Han Character Leakage: Temperature, DPO, Vocabulary Pruning"
seo_description: "We measured CJK contamination in Qwen3.8-27B Korean responses across 3,369 prompts. Temperature drives a 5x difference, and lm_head vocabulary pruning cuts real errors from 1.81% to 0.18% while preserving Korean Hanja notation."
date: 2026-09-01
published: true
categories:
  - llmops
tags:
  - korean
  - language-confusion
  - code-switching
  - vocabulary-pruning
  - qwen
  - dpo
  - measurement
author_profile: true
toc: true
toc_label: "Contents"
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/humanko-cjk-vocab-prune/"
---

If you run a multilingual LLM behind a Korean-facing service, you have probably seen output like this.

```
인기가极高的 해양 생물 테마파크
오후 6시前后的(경계) 시간대는
파일 버전号和 마지막 수정 시각을
```

All of it came from Qwen3.8-27B answering Korean prompts. The response does not switch to Chinese wholesale. Two or three characters slip into the middle of an otherwise Korean sentence. The most frequent intruders are `的`, `您`, and `贵` — Chinese particles and honorifics.

There are three things to take away. **First, check your generation temperature before you measure anything.** Temperature alone accounts for a 5x swing in the contamination rate. **Second, suspect your measuring tools.** We measured the effect of preference learning, and only later discovered the comparison itself had never taken place. **Third, you can block the output path in the weights** — but choosing what to cut decides whether Korean Hanja notation survives.

## Plain terms

The last step a model takes before emitting a character is like picking a key on a keyboard. What we did was remove the Chinese-word keys from that keyboard, while leaving the single-character Hanja keys in place — Korean writing puts Han characters in parentheses, as in 개항(開港), and we did not want to break that. This keyboard picture carries through the rest of the article.

## Temperature drives a 5x swing

For a while our numbers sat 40x above published figures. The SASFT paper, working on the same model family, reports a Korean code-switching ratio of 0.25% for Qwen3-8B. We were seeing more than 10%.

The gap was not the model. It was the generation setting. Same model, same 1,200 prompts, temperature the only variable.

| Temperature | Contamination | Real errors |
|---|---|---|
| 1.0 | 10.42% | 9.33% |
| 0.0 | 2.67% | 1.92% |

"Real errors" excludes legitimate Korean Hanja notation such as `개항(開港)`, where Korean writers deliberately gloss a word with its Chinese characters. A 5x difference came from temperature alone, and it explains most of our gap with the literature.

So any contamination figure has to carry its temperature. A number without one cannot be compared to anything. Every figure in this article uses `temperature=0.0` and `max_tokens=400`.

You also need a noise floor. Running the same model twice under identical settings gives 2.67% and 2.33%. **0.33 percentage points move on their own between runs.** Anything smaller than that should not be read as an effect. In fact, out of 2,000 prompts, 569 flipped contamination status when the same model was run against itself. This looks less like a property of the prompt and more like a property of sampling.

## DPO learned it; whether it transfers is still open

Preference learning was the first attempt. We built minimal pairs: take a response containing Han characters, replace only the Han spans with Korean, and use that as the preferred answer. The median similarity between the two is effectively 1 (two parts in a thousand short of it), so the only thing the model can learn is the presence or absence of Han characters.

Training converged cleanly. Held-out preference accuracy reached 97.4% and the loss went to zero.

The generation-side check, however, turned out to be void. A later audit showed that our serving engine was silently ignoring LoRA adapters for this model family: at temperature 0, adapter output was byte-identical to base output. The column we believed was "after DPO" was in fact the base model measured twice. An earlier version of this article carried a transfer-failure table built on that comparison; we have removed it, and we are re-measuring with the adapter merged directly into the weights.

The hypothesis stands, unverified. DPO adjusts the relative likelihood of **two complete responses**, while contamination is a **single-token event** that fires at an arbitrary position. The TLPO paper points at the same limitation of sequence-level fine-tuning and proposes token-level intervention. But this experiment did not test it.

Scale was also short. We used 346 pairs; SASFT, tackling the same symptom with SFT, used 110k to 210k samples. That said, more data does not dissolve a level mismatch.

## So we blocked the output path

`lm_head` is the matrix that turns hidden states into vocabulary-sized logits. Touch a token's row and you control how likely that token is to be selected.

One thing to watch. **Do not zero the row.** Qwen's `lm_head` has no bias, so the logit is `h · W_i`. Zeroing the row makes the logit 0, not negative infinity — and the moment every other candidate is negative, 0 becomes the maximum.

Instead we overwrote the rows with a large negative multiple of the mean hidden-state direction. In keyboard terms: rather than pulling the keys out, we locked them so they never register.

```
W_i := -alpha * mu_h / ||mu_h||^2     (alpha = 200)
```

`mu_h` is the mean final hidden state over Korean sentences, measured rather than assumed. Two independent measurements gave `||mu_h||²` of ~9,846 and 9,887, reproducing within 0.4%.

The tokenizer and the input embeddings are untouched. The model **cannot generate Han characters but can still read them.** Vocabulary size is unchanged, so it loads through the standard path.

### Choosing what to cut is the real problem

Cutting everything is simple and kills Korean Hanja notation with it. So we built three candidates and measured the curve.

By character, 72.3% of the contamination is traditional or shared Han that Korean also uses. Cutting only simplified forms catches a quarter of it. **By token, the picture changes.** Of 498 contaminated tokens, 355 looked like this:

```
您的(12)  贵公司(8)  具体时间(7)  为您(5)  本次会议(3)
```

Whole Chinese words as single tokens. Korean does not emit those as one unit. Korean Hanja notation, meanwhile, splits into single characters: `개항(開港)` is `開` plus `港`, and `채권(債權)` is `債` plus `權`.

That gives the rule. **Cut kana, simplified-only characters, and multi-character pure-Han tokens; keep single Han characters.** 54,902 tokens qualify.

## Results

3,369 prompts, paired on the same engine.

| | Contamination | Real errors |
|---|---|---|
| base | 2.55% | 1.81% |
| pruned | **0.68%** | **0.18%** |

An 82% reduction in real errors, 5.7x the 0.33pp noise floor, A McNemar test puts the odds of this being chance below one in ten thousand.

**Hanja notation survives.** On 12 prompts that explicitly demand Han characters, the pruned model produces them 12 out of 12, same as base. HumanEval coding accuracy is 92.19%, identical to base — though at n=64 the minimum detectable difference is 13.29pp, so that reads as "we could not detect a regression," not "there is none."

What about cutting everything? Contamination drops to 0.06%, but 12 Hanja prompts become 3, and those 3 produce **wrong characters**.

```
債權 → 倖         새옹지마 → 壺齋         大 → 尙
```

With the correct characters blocked, the model assembles different ones from byte fragments and states them confidently. That is worse than omitting Hanja entirely.

## Two limits

**First, zero is structurally out of reach.** Even under full masking, 2 of 3,369 responses leaked, and the culprits were `鄕` and `蕩`. The tokenizer explains it.

```
的 → 1 token [95726]          blocked
鄕 → 2 tokens [98248, 243]    not blocked
```

Rare Han characters have no standalone token and get assembled from byte fragments. Those byte tokens cannot be cut — removing them breaks arbitrary UTF-8 handling. Vocabulary pruning has a floor above zero.

**Second, overwriting rows is an approximation.** Applying the same method to a 0.8B model, a proxy measurement of 0.20% became 1.33% on the real weights. Of 20 leaks, 15 were a single character `・` that was **on the block list**, and every occurrence looked like this:

```
systemd-run・user     my・pod     request・user_id     ・perf
```

Not Korean context at all — code and CLI text, in positions where a hyphen belongs. A blocked token wins precisely there.

This exposed a hole in our verification. We measured the masked-logit margin across 200 contexts, and even the 0.8B came back safe with a worst-case margin of 103. But that probe only looks at the **final prompt token position**. Leaks happen mid-generation, where the hidden state is different. "Safe" meant safe where we measured, not safe everywhere.

The 27B showed zero contamination on the same class of context (code, CLI, YAML — hyphen- and underscore-heavy) and zero blocked-token leaks across 3,369 Korean prompts. That measurement, not the margin metric, is what supports the 27B.

**We do not know why the 0.8B breaks and the 27B does not.** Capacity is a tempting explanation with no evidence behind it. What is clear is that overwriting rows offers no guarantee, which is exactly why real vocabulary pruning **removes** rows. In a bias-free linear layer, the only way to be certain a token never appears is to delete it.

## In short

When you deal with Han characters leaking into Korean output, work in this order. **Check the temperature first** — that alone is a 5x factor. Before spending time on preference learning, look at the level of the problem; sequence-level signal does not reach a single-token event. If you touch the weights, what you cut decides the outcome, and keeping single characters is the practical choice for any domain that uses Korean Hanja.

The approach is not new. [`dnotitia/smoothie-qwen`](https://github.com/dnotitia/smoothie-qwen) already ships pre-adjusted Qwen checkpoints in the same direction. What we added is a curve built around preserving Korean Hanja, plus the two observations above.

One last thing to be clear about. **This is hygiene, not style.** A separate attempt in the same project to make the Korean prose sound human is still unjudged: the same serving defect voided its comparison, and we are re-measuring. What did hold up is that its training targets were nearly identical to the base model's own output. Removing Han characters does not make writing natural. That is a different problem and it needs different data.


## References

- SASFT: <https://arxiv.org/abs/2507.14894>
- TLPO: <https://arxiv.org/abs/2604.26553>
