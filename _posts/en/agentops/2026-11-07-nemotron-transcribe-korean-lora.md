---
title: "Releasing a Korean LoRA for Nemotron 3.5 Transcribe: How We Fine-Tuned a 30B Speech Recognition Model"
seo_title: "Korean LoRA Fine-Tuning for Nemotron 3.5 Transcribe 30B with Guarded Decoding - Thaki-KSpeech Release | ThakiCloud"
seo_description: "We released a Korean LoRA adapter for NVIDIA Nemotron 3.5 Transcribe 30B-A4B. Why two training runs failed their release gates, how the guarded-dg-v1 decoding guard stops repetition loops, same-pipeline Korean evaluation, how to reproduce it, and its limits."
excerpt: "We trained and released a Korean LoRA for a 30B speech recognition model. What got it through the release gates was not only the training recipe but a decoding guard that stops the model when it cannot stop itself, and refuses to count those segments as transcribed."
date: 2026-11-07
last_modified_at: 2026-11-09
published: true
tags:
  - asr
  - korean-speech-recognition
  - nemotron
  - lora
  - fine-tuning
  - decoding
  - meeting-notes
  - agentops
permalink: /en/agentops/nemotron-transcribe-korean-lora/
categories: [agentops, product]
author_profile: true
toc: true
toc_label: "Contents"
reading_time: true
lang: en
header:
  teaser: /assets/images/nemotron-transcribe-korean-lora-hero.webp
canonical_url: "https://thakicloud.com/tech-blog/en/agentops/nemotron-transcribe-korean-lora/"
series: thaki-minutes
order: 1
---

![Title card for the Korean LoRA release of Nemotron 3.5 Transcribe 30B. test_gen CER 6.78%, base 9.99%](/assets/images/nemotron-transcribe-korean-lora-fig-title-en.webp)

We asked the model to transcribe a meeting recording, and a 9.35-second utterance whose reference is seven words came back as about 507 words. Short utterances and code-switched speech clearly improved, yet the general Korean benchmark score more than doubled in error. The same adapter on a different GPU produced a few different outputs. These are the scenes we actually ran into while adapting a large speech recognition model to Korean business speech.

ThakiCloud trained a Korean LoRA adapter for NVIDIA Nemotron 3.5 Transcribe 30B-A4B and released it on [Hugging Face](https://huggingface.co/ThakiCloud/Thaki-KSpeech-KO-30B-A4B-LoRA-v1). What passed the release gates is not an adapter file on its own. It is **the adapter combined with the guarded-dg-v1 decoding guard**. Both training runs, evaluated without the guard, were rejected. Under the same guard, CER on the report-only set test_gen drops from 9.99% to 6.78%.

This post walks through the training setup, the two rejections, why one 9.35-second utterance swung the metric, how the guard is built, the same-pipeline evaluation, and how to reproduce it.

## A LoRA r=32 on 47.8 hours of Korean speech

We trained on 32,000 Korean utterances (47.8 hours) from two AI Hub datasets.

| Source | Utterances | Duration |
|---|---|---|
| AI Hub (AI-Hub) · Meeting Speech (#132) | 24,000 | 36.43 h |
| AI Hub (AI-Hub) · Korean Speech (#123) | 8,000 | 11.37 h |
| Total | 32,000 | 47.8 h |

For dataset 132 we checked the license, recording-consent and training-consent fields on all 24,000 rows; for dataset 123, the license, commercial-use and rights-basis fields on all 8,000 rows. Evaluation sets (Zeroth-Korean, HiKE, FLEURS and the held-out dev/test splits) were excluded from training and checked for leakage by audio and sentence hashes.

We do not redistribute the AI Hub data; only the model weights are released. The public repository holds no audio or transcripts, and this post shows no examples from the data. Besides the trained adapter weights, the repository contains only the inference code.

LoRA freezes the original weights and trains only small low-rank matrices to change the model's behavior. Instead of retraining all 30B parameters, we moved 36.9M.

| Item | Value |
|---|---|
| Base model | `nvidia/NVIDIA-Nemotron-3.5-Transcribe-30B-A4B`, bf16 |
| Trained parameters | LoRA r=32 + `multi_modal_projector` (36.9M trainable) |
| Learning rate · effective batch | 2e-5 · 32 |
| Steps | 1,000 on one H200 |
| Checkpoint | step 800, chosen on dev_132 + dev_gen by a rule fixed before training |

The adapter is loaded with `PeftModel` and not merged. No merged checkpoint is provided.

## The first run fixed short utterances and broke the general benchmark

The first run (v1) improved short and code-switched speech a lot. On the 800-utterance dev set, CER on utterances under 2 seconds went from 27.8% to 17.8%, and CER on utterances mixing in English went from 26.5% to 16.3%. The three empty outputs the base model produced dropped to zero.

![Zeroth-Korean test CER: base 2.91%, v1 6.85%, v1 with number normalization 5.63%, final adapter 3.28%, gate ceiling 3.91%](/assets/images/nemotron-transcribe-korean-lora-fig-bars-zeroth-en.webp)
*v1 jumped from 2.91% to 6.85%, and was still 5.63% after number normalization. The final adapter with the guard sits at 3.28%, inside the 3.91% gate but 0.36 pp worse than the pre-fixed baseline.*

But CER on Zeroth-Korean, a general Korean benchmark, rose from 2.91% to 6.85%. The model wrote Arabic numerals in 149 of 457 utterances, while Zeroth references spell numbers out in Korean. Those 149 utterances account for 664 of the 760 added CER error characters. Even with an auxiliary normalization that converts digits to Sino-Korean numerals, CER stayed at 5.63%, so the regression was not only about number formatting.

The verdict was NO_RELEASE. Before training we had decided that a large drop on the general Korean benchmark blocks release, whatever else improves.

## The second run lost all five checkpoints at the meeting-speech gate

For the second run (v2) we changed the transcript formatting policy and rebuilt the data mix above. We also pre-registered the selection rule: a checkpoint whose meeting-speech dev (dev_132) WER is 0.5 pp or more worse than the base model cannot be selected.

All five checkpoints failed. WER on the general Korean dev (dev_gen) improved by 2.15 to 3.66 pp, but dev_132 WER got worse by 0.52 to 3.84 pp. The NO_RELEASE verdict for v2 without the guard still stands. The guarded results below come from a different inference configuration.

## One 9.35-second utterance produced about 507 words

When we broke dev_132 errors down by utterance, most of the added word errors came from a single utterance: 9.35 seconds long, seven words in the reference. After the first few tokens the adapter repeated the same token 503 times until it hit the 512-token generation cap. That one utterance produced about 507 words and about 500 errors.

![Token counts for the 9.35-second utterance: reference 17, guard cap 174, unguarded output 512](/assets/images/nemotron-transcribe-korean-lora-fig-bars-tokens-en.webp)
*The reference is 17 tokens. Unguarded decoding repeated one token 503 times and filled the 512-token cap; the guarded-dg-v1 cap formula allows 174 tokens for this clip.*

The dev evaluation path had no repetition detection and no official post-processing. If the model never emitted EOS (the special token that marks the end of output), it generated up to the cap. The problem was less that training did not work and more that one runaway generation could swing the whole meeting-speech metric.

## guarded-dg-v1 stops the loop and leaves unconfirmed segments empty

A decoding guard is a set of rules outside the model that decides when generation stops and how the stopped result is labeled. The model weights stay the same; only the generation path changes.

![Unguarded decoding path compared with the guarded-dg-v1 path](/assets/images/nemotron-transcribe-korean-lora-fig-arch-en.webp)
*Without a guard, an utterance that never emits EOS fills the 512-token generation cap and is scored as a transcript. guarded-dg-v1 stops on a length cap or a repeat rule and marks that segment unverified.*

The guard has three parts.

**Length cap.** Counting tokens per second over the 32,000 training transcripts gave a 99.9th percentile of 7.58. The cap is `min(8192, ceil(2.0 × (16 + 7.58 × seconds)))`. For the 9.35-second utterance that is 174 tokens; its reference is 17 tokens. No training transcript exceeds the cap.

**Repetition stop.** Generation stops when the last 40 or more tokens are one 1- to 64-token unit repeated at least 4 times. Run on reference transcripts, the rule fires on 1 of 32,000 training rows and 0 rows in both dev sets.

**Verdict.** Ending with EOS gives `ok` or `empty`; stopping on repetition or the length cap gives `unverified`.

![Example of the three statuses the guard returns: ok, empty, unverified](/assets/images/nemotron-transcribe-korean-lora-fig-io-en.webp)
*guarded-dg-v1 returns a status with every transcript. On unverified the text is emptied and sent to human review (input sentences are made-up examples).*

`unverified` is not a low-confidence label. It means no transcript could be confirmed, so the text comes back empty. We do not return what is left after cutting the loop, and evaluation scores it as an empty hypothesis. The guard stops loops; it does not recover the words in that segment.

## Under the same guard, CER drops on all three sets

Base and adapter (v2 step 800) were run with the same guard, prompt and pre-processing. test_gen was measured once, after the checkpoint was chosen, and is report-only.

![Korean CER under the same guard: dev_132 11.14% to 9.59%, dev_gen 10.32% to 7.24%, test_gen 9.99% to 6.78%](/assets/images/nemotron-transcribe-korean-lora-fig-bars-en.webp)
*Base and adapter use the same guard, prompt, and preprocessing. test_gen is a report-only set measured once after checkpoint selection.*

| Set (utterances) | Role | Base WER | Adapter WER | Base CER | Adapter CER | Unverified (base → adapter) |
|---|---|---|---|---|---|---|
| dev_132 (798) | selection | 28.08% | 25.78% | 11.14% | 9.59% | 0 → 2 |
| dev_gen (800) | selection | 24.47% | 20.95% | 10.32% | 7.24% | 0 → 0 |
| test_gen (800) | report only | 25.63% | 21.29% | 9.99% | 6.78% | 0 → 0 |

On dev_132 the base model has no `unverified` outputs but three empty outputs that ended with EOS. The adapter's two are segments the guard stopped, so they have no transcript.

### Read the regression gates separately

These are the pre-registered regression gates. The base numbers were **measured and fixed earlier, without the guard**, so this is not a same-condition comparison and should not be read as the size of an improvement.

| Set (utterances) | Metric | Base (no guard, fixed in advance) | Adapter (guarded) | Gate | Pass |
|---|---|---|---|---|---|
| Zeroth-Korean test (457) | CER | 2.91% | 3.28% | ≤ 3.91% | yes |
| Zeroth-Korean test (457) | WER | 21.01% | 18.99% | ≤ 22.01% | yes |
| HiKE test (1,121) | MER / PIER | 29.68 / 46.99 | 19.56 / 31.84 | ≤ 24.68 / ≤ 41.99 | yes |
| FLEURS en_us test (647) | WER | 5.27% | 5.31% | ≤ 5.57% | yes |

Zeroth CER is 0.36 pp worse than the pre-fixed baseline. It is within tolerance, but it is a regression. Three of the 1,121 HiKE utterances ended `unverified` (2 repetition, 1 length cap) and were scored as empty.

## Change the GPU and the output shifts slightly

You need one GPU with at least 80 GB, a `transformers` commit with Nemotron 3.5 Transcribe support, and `peft>=0.17`.

```bash
pip install "git+https://github.com/huggingface/transformers@66f51e76efd8542232b8bdd40ade7d1edbaac46f" "peft>=0.17" soundfile librosa accelerate
git clone https://huggingface.co/ThakiCloud/Thaki-KSpeech-KO-30B-A4B-LoRA-v1 && cd Thaki-KSpeech-KO-30B-A4B-LoRA-v1
python infer_guarded.py --adapter . sample.wav
```

The base-model revision, prompt, cap formula, repetition rule and guard-code sha256 are pinned in the repository's `pipeline.json`. Split long recordings into segments of 45 seconds or less. If `status` comes back `unverified`, send that segment to human review and do not use it as evidence.

Hardware matters too. Before release we rebuilt a clean environment from the repository files and re-decoded 122 inputs. On the H200 NVL used for the original evaluation, all 122 matched exactly. On a B200, 11 of 100 array inputs produced different output and CER on those 100 utterances moved from 6.69% to 6.97%; every utterance still ended with EOS and kept its status.

bf16 arithmetic differs slightly across GPU architectures and flips a few greedy choices. Greedy decoding picks the single most likely token at each step, so a tiny numeric difference can change which branch it takes. The model card therefore states that exact reproduction was verified on H200 only.

## Six things to know before you use it

| Item | Status | Why |
|---|---|---|
| Korean transcription (same guard) | ✅ | CER drops on all three sets |
| Pre-registered regression gates | ✅ | All pass, but Zeroth CER regresses by 0.36 pp |
| Speaker diarization | ⚠️ | Not included, must be added separately |
| Replacing the meeting-notes default ASR | ⚠️ | Comparison conditions differed, effect unknown |
| Serving engines (vLLM etc.) | ⚠️ | Only `transformers` + `peft` checked |
| Absolute error on conversational speech | ⚠️ | WER above 20% on all three sets |

- **It has no speaker diarization.** The adapter transcribes speech; it does not tell you who spoke when. Post-processing removes speaker tags, and evaluation was single-speaker utterance transcription. Meeting notes need a separate diarization component.
- **Thaki Minutes' default ASR did not change.** ThakiCloud's meeting-notes product still uses the unmodified NVIDIA base model with 45-second chunking by default. In an internal canary the adapter showed no better metric, and that comparison ran the base model on H200 and the adapter on B200, so weight effects and hardware effects could not be separated. We claim neither that the adapter improves meeting notes nor that it makes them worse.
- One training seed and one checkpoint; seed variance was not measured.
- Only the `transformers` + `peft` inference path was checked. Serving engines such as vLLM were not evaluated.
- Word timestamps, streaming and audio longer than 45 seconds per call were not part of the gates.
- Error rates on conversational Korean remain high in absolute terms: WER is above 20% on all three sets above.

## Closing

The unit of reproduction is not a weight file. With the same adapter, changing the generation cap and how repetition is handled moves meeting-speech WER across the gate. So we defined the release as a bundle: base-model revision, unmerged adapter, fixed prompt, guard code pinned by sha256, and post-processing applied only to `ok` outputs.

If you fine-tune a large speech recognition model, check the decoding path alongside the training recipe. The cheapest first experiment is to sort your current evaluation by per-utterance errors, largest first. If the top few are loops that filled the generation cap, the guard comes before more training. Stopping the cases where the model cannot stop, and not counting them as successful transcripts, can change the verdict on its own.

Next in this series: [WavLM vs. pyannote for Korean Meeting Diarization: An Evaluation Across 64 Real Meetings](https://thakicloud.com/tech-blog/en/agentops/korean-meeting-diarization-pyannote-vs-wavlm/)

## Sources

Every figure in this post comes from measurements recorded in our internal experiment ledgers. The ledgers themselves are not published.

---

*ThakiCloud AI Engineering · Korean Speech*

*Model: [ThakiCloud/Thaki-KSpeech-KO-30B-A4B-LoRA-v1](https://huggingface.co/ThakiCloud/Thaki-KSpeech-KO-30B-A4B-LoRA-v1) (revision `cf73497c`). Training data source: AI Hub (AI-Hub) · Meeting Speech (#132), AI Hub (AI-Hub) · Korean Speech (#123). The data is not redistributed; only the model weights are released.*
