---
title: "We Benchmarked Four Multilingual TTS Models on the Same GPU: A 12x Gap and Three Scorers That Lied"
excerpt: "If you are picking a speech synthesis endpoint that has to cover Korean and Japanese, look at RTF and idle power share before you look at the naturalness score on the model card. On the same B200, VoxCPM2 was 12x faster than Qwen3-TTS, and 86.7% of the power Qwen3-TTS drew had nothing to do with synthesis. Emotional expressiveness spread as wide as 17x between models."
seo_title: "Multilingual TTS Serving, Measured: RTF, Power, and Emotional Range Compared"
seo_description: "We measured Qwen3-TTS, VoxCPM2, Supertonic-3, and Kokoro-82M across Korean, English, Chinese, and Japanese on the same harness. A 12x RTF gap, 86.7% idle power, and three evaluators that reported success while scoring zero."
date: 2026-08-15
last_modified_at: 2026-08-15
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "book"
lang: en
permalink: /en/llmops/multilingual-tts-serving-measured/
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/multilingual-tts-serving-measured/"
tags:
  - text-to-speech
  - multilingual-tts
  - inference-serving
  - power-measurement
  - benchmarking
  - evaluation-harness
  - gpu-serving
categories:
  - llmops
---

If you are choosing a speech synthesis endpoint that has to serve Korean and Japanese alongside English, you are better off looking at RTF and idle power share than at the naturalness score printed on the model card. On a single B200, VoxCPM2 ran **12x faster** than Qwen3-TTS, and **86.7% of the power Qwen3-TTS drew was idle draw with no connection to synthesis at all**.

We ran four models through the same harness across Korean, English, Chinese, and Japanese. The text set was split into six categories, from plain prose to numbers, loanwords, jargon, questions, and compound sentences. The emotion set took an emotionally neutral sentence and synthesized it under six different emotions. We measured five axes: speed, power, intelligibility, naturalness, and emotional expressiveness.

## Speed is where they split

RTF is real-time factor, and lower is faster. An RTF of 1.0 means it takes exactly one second to produce one second of audio.

| Model | Hardware | Median RTF | Power per second of audio | GPU idle share |
|---|---|---|---|---|
| VoxCPM2 | B200 | 0.100 | 25.8 J | 43.4% |
| Kokoro-82M | 32-core CPU | 0.640 | 7.5 J | n/a |
| Qwen3-TTS-1.7B | B200 | 1.196 | 40.1 J | 86.7% |
| Supertonic-3 | 32-core CPU | 2.498 | 50.4 J | n/a |

**Qwen3-TTS is slower than real time.** That means a single B200 cannot even keep pace with one stream, so bolting it onto a live conversational service means the very first utterance already falls behind. VoxCPM2, on the same card, sits at 0.100 and can comfortably carry ten streams at once.

The more important number on the power side is idle share. When the Qwen3-TTS endpoint cannot keep its batch full, it simply burns 86.7% of its power doing nothing. On a serving setup where you are renting the whole GPU, that idle share is still money you are paying, so the cost math has to run on the absolute figure rather than the marginal one. VoxCPM2's 43.4%, by contrast, means the same card is working a good deal harder per watt.

Kokoro-82M drew the least at 7.5 J per second of audio on 32 CPU cores. If you only need English and Chinese and have latency to spare, there is a real option here that skips the GPU entirely.

## Intelligibility passed everywhere, just not by the same margin

We fed the synthesized audio back through Whisper-large-v3 and compared the transcript against the source text. All four models cleared the threshold on median scores. Korean and English were effectively error free.

Where they split is the top 10%. Qwen3-TTS's Japanese p90 came in at 0.413, and VoxCPM2's Japanese landed at 0.438, both a meaningful step down. Breaking it apart by category makes the cause plain. Plain prose, questions, and compound sentences run close to zero errors, and the failures cluster almost entirely in **numbers and jargon**. That is harmless if the endpoint is reading you an article, but if it has to read out a monetary amount, a date, or a product code, those are exactly the two categories where it breaks.

## Emotion did not travel with speed

We scored the emotion axis with a deterministic metric called EFI. Take the same sentence, synthesize it under six emotions, and measure how much nine prosodic features (F0, energy, pauses, and the rest) shift across those conditions, normalized to a 0 to 1 scale. Close to zero means the model's voice barely moves no matter what emotion you ask for.

Qwen3-TTS scored 0.408, Supertonic-3 scored 0.255, and Kokoro-82M scored 0.024.

That last number is what calibrates the other two. Kokoro-82M has no emotion control API at all. Its adapter accepts an emotion argument but never uses it, so all six conditions are effectively the same input, which means 0.024 is not the score of a model that fails to react to emotion. It is **what this metric reads out when the condition was never actually applied**, a floor produced purely by sampling nondeterminism.

Once you know the floor, the reading changes. Supertonic-3's English score of 0.157 looks low in absolute terms, but it sits at 6.5x the floor, so it is a shallow but real response. Qwen3-TTS's 0.408 sits at 17x the floor. Without the floor as a reference, 0.157 reads as "barely moves." With it, the accurate reading is "moves, but only shallowly."

VoxCPM2, dominant on speed, could not make it onto this table at all. It only accepts style direction paired with reference audio, so a text-only emotion prompt fails synthesis outright. Had we quietly substituted a neutral voice at that point, EFI would have read as "this model shows no emotional variation," which would have been the wrong story since the condition was never applied in the first place. We excluded it instead of papering over the gap.

Looking at pairwise separability, the two models blur different emotions. Qwen3-TTS struggles specifically with surprise: three of its four least-separable pairs involve surprise, meaning it has trouble distinguishing surprise from neutral or joy. Supertonic-3 blurs high-arousal emotions into each other, muddying fear against joy and anger against joy.

One more thing stood out on Supertonic-3: its English EFI of 0.157 was unusually low. The same model's Japanese scored 0.354, so it is not a globally weak model, it is specifically the English pathway where emotional direction takes weakly.

## But the scorer lied three times

That covers the results, and honestly the more expensive lesson lives here. During the run we found **three evaluators that reported success while actually scoring zero items**.

The first was the naturalness scorer. The UTMOS model sat on the GPU while its input tensor sat on the CPU, so all 120 items died silently, yet the ledger recorded zero failures. A deterministic fallback metric had quietly filled in the gap, so the result looked healthy from the outside.

The second was the emotion scorer. The code producing the validity flag from the feature extraction step wrote a key called `ok`, and the code reading it back checked for `_ok`. That single underscore invalidated all twelve groups, and even though 72 emotional utterances had been synthesized cleanly, the entire emotion axis quietly went to zero.

The third sat one layer above, in the smoke gate. Emotional synthesis had 60 failures against only 12 successes, and the gate still passed. Its pass condition was "fail only if zero emotion records succeeded," so the 12 successful neutral-condition items alone were enough to clear it.

The common thread in all three is that **partial success quietly slid into total success**. The danger ranks in this order: a missing gate is less dangerous than a gate that runs but looks at nothing, and more dangerous still is a gate that looks but scores with a pass condition that is too loose. That last case is worst because it comes back with numbers attached, which makes it look real.

The fix was the same in all three cases: **judge against expectation, not against a raw pass count**. If emotional utterances exist but the scored group count is zero, that is not a model with no emotion, it is a broken scorer, and it now fails explicitly with a nonzero exit code.

## When you measure the idle baseline changes the answer by 8x

We hit a similar trap on the power measurements. Same model, same node, same code, and the net incremental power came out as 61W in one run and 7.6W in another. The only variable was **when we captured the idle baseline**.

Measure idle cold, before the model is loaded, and it reads 190W. Measure it warm, right after warmup, and it reads 261W. Measuring on the warm side treats an already-heated state as the baseline, which erases almost all of the net increment. Our existing contamination flag only tripped above 5% GPU utilization, and this state sat at 4%, so it never fired.

We fixed three things. We now rest for 30 seconds before capturing the baseline to give the clock time to come down, we track a dedicated residual-heat flag separately from the contamination flag, and we **promoted the absolute figure to the primary metric**. The absolute number is insensitive to which baseline you pick, and it is also the correct question from a serving cost standpoint where you rent the whole GPU.

## What we have not measured yet

We are leaving this part honest. TTSDS2, the metric we planned to use as the primary naturalness score, **we did not measure**. It compares the distribution of synthesized speech against a distribution of real reference speech, and we could not secure a reference corpus for every language. As a result, every naturalness comment in this piece leans on UTMOS, a secondary metric, and UTMOS is a predictor trained on English, so its Korean, Chinese, and Japanese values are uncalibrated. It is fine for ranking models within a language and should not be used to compare across languages.

EFI measures how much the output changes, not whether it sounds like the emotion it was asked for, so we measured the second half separately with a speech emotion classifier. Agreement between the requested emotion and the classified one came out at 0.403 for Qwen3-TTS, 0.222 for Supertonic-3, and 0.167 for Kokoro-82M.

That last number is worth pausing on. Guessing uniformly among six emotions gives 0.167, and Kokoro landed exactly there. Two independent observations, prosodic variance and emotion classification, separately confirmed that the model has no emotion conditioning at all.

The absolute levels deserve a sober reading too. Even the best performer reaches only 0.403, so a requested emotion survives to the classifier less than half the time. Emotion conditioning in TTS is less a switch that turns an emotion on and more a dial that leans slightly in its direction.

Eight of the twelve models on our roster did not make it to the finish line. Two were dropped because we would not guess at an undocumented Python API contract, two hit install and version conflicts, and the rest were never started. Kokoro's Japanese pathway failed because its morphological analyzer would not initialize inside the pod environment, which is an environment constraint, not a limitation of the model itself, so we kept a separate record of "languages the roster claims to support" versus "languages we actually measured."

## Bottom line

If you are building a real-time conversational service, VoxCPM2's RTF of 0.100 is compelling, but you have to accept alongside it that emotional conditions cannot be applied without paired reference audio. If emotional expressiveness matters, Qwen3-TTS leads at an EFI of 0.408, but it is slower than real time and burns a large idle power share. If you only need English and Chinese and have latency to spare, putting Kokoro-82M on CPU is the cheapest option on power by a wide margin.

Whichever model you pick, check first that your scorer is actually scoring. We got fooled three times.

---

The measurement ledger and the harness live in our internal repository, and the synthesized audio is kept alongside it, ranging from 16MB to 44MB per model. Keeping the audio around means we can rescore after fixing the scoring logic without touching a GPU again. One model where we had not done that had to be resynthesized from scratch on GPU, all 120 utterances, after the bug was fixed.
