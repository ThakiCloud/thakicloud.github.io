---
title: "A Public Korean TTS Built From a Speaker Designed With One Sentence: Thaki-SyntheticVoice-KO-2B-v0.1"
excerpt: "We designed a synthetic speaker, F1, by giving VoxCPM2 Voice Design nothing but a text description, synthesized 80.8 minutes in that voice, trained a LoRA on it, merged it and released it on Hugging Face. With the bundled reference it matches Base+Ref; without a reference it clearly beats the base model, but speaker locking is still partial. The whole process took 2.1 GPU-hours. Here is what self-distillation can and cannot do."
seo_title: "Thaki-SyntheticVoice-KO-2B-v0.1 Release: Designed Synthetic Speaker and LoRA Self-Distillation | ThakiCloud"
seo_description: "ThakiCloud's second public speech model, Thaki-SyntheticVoice-KO-2B-v0.1. A synthetic speaker F1 designed with VoxCPM2 Voice Design, a 1,200-sentence in-house script, 934 synthesized utterances (80.8 min), LoRA and merge in 2.1 GPU-hours. Reference-free generation: CER 3.6% to 1.8%, UTMOS 2.22 to 3.23, anchor cosine 0.59 to 0.79, with the minimum cosine of 0.40 reported as is."
date: 2026-10-24
last_modified_at: 2026-10-24
permalink: /en/llmops/thaki-syntheticvoice-ko-v01-release/
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "microphone"
tags:
  - tts
  - voxcpm2
  - voice-design
  - synthetic-speaker
  - lora
  - self-distillation
  - evaluation-gates
  - huggingface
  - korean-speech
  - llmops
categories:
  - llmops
  - product
header:
  teaser: /assets/images/thaki-syntheticvoice-ko-v01-release-hero.webp
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/thaki-syntheticvoice-ko-v01-release/"
lang: en
---

We have published ThakiCloud's second public speech model, [Thaki-SyntheticVoice-KO-2B-v0.1](https://huggingface.co/ThakiCloud/Thaki-SyntheticVoice-KO-2B-v0.1), on Hugging Face. It is a Korean TTS model built without recording a single human voice. We gave the Voice Design feature of [VoxCPM2](https://huggingface.co/openbmb/VoxCPM2) one text description, "a calm, low-pitched Korean woman in her thirties, corporate-assistant tone", to design a synthetic speaker we call F1, synthesized 80.8 minutes of speech in that voice, trained a LoRA on it and merged it into the base weights. From speaker design to evaluation it took about 2.1 GPU-hours on one H100. With the bundled reference clip the model performs the same as VoxCPM2 Base given the same reference, and without a reference it is clearly better than Base, but it does not produce the same voice every time. This post records the process and the limits, numbers as they are.

![Abstract image of a single voice waveform rising in warm light over a blue background](/assets/images/thaki-syntheticvoice-ko-v01-release-hero.webp)
*Turning one line of description into one voice took 2.1 GPU-hours.*

## With a reference and without one

There were two evaluation questions. Given a reference clip, is the model no worse than Base+Ref? And without any reference, does the designed speaker's voice come out? The first question was judged by gates T1 to T5 registered before training; the second was measured separately from the gates. Why they were kept apart is explained further down.

![Bar chart comparing Base and this model on CER, UTMOS and anchor cosine, with and without a reference](/assets/images/thaki-syntheticvoice-ko-v01-release-results-en.webp)
*Values read from the evaluation ledger. With a reference the two models overlap; without one all three metrics separate.*

| Condition | Metric | VoxCPM2 Base | This model |
|---|---|---|---|
| With reference, 200 sentences | CER | 3.13% | 3.03% |
| With reference, 200 sentences | Pairwise speaker cosine | 0.980 | 0.981 |
| With reference, 200 sentences | UTMOS | 3.49 | 3.49 |
| With reference, 60 sentences | RTF (merged checkpoint) | 0.135 | 0.147 |
| No reference, 60 sentences | CER | 3.6% | 1.8% |
| No reference, 60 sentences | UTMOS | 2.22 | 3.23 |
| No reference, 60 sentences | Cosine to the F1 anchor, mean | 0.59 | 0.79 |
| No reference, 60 sentences | Cosine to the F1 anchor, minimum | 0.21 | 0.40 |
| No reference, 60 sentences | Same sentence, different seed, cosine | 0.70 | 0.81 |

Every value is our own measurement of both models on the same GPU, the same decoding (cfg 2.0, 10 steps) and the same scorers, reported as the median over seeds 0, 1 and 2. CER compares whisper-large-v3-turbo back-transcription with the spoken-form script, speaker cosine is WavLM-SV and naturalness is UTMOS22. Runaway and silent outputs were 0 for both models.

With a reference the two models are effectively identical: CER 3.13% versus 3.03%, UTMOS tied at 3.49, speaker cosine 0.980 versus 0.981. Without a reference the base model picks a different voice on every generation and naturalness drops to 2.22, whereas this model halves CER to 1.8%, brings UTMOS up to 3.23, close to the with-reference level, and raises the mean cosine to the F1 anchor from 0.59 to 0.79. The minimum, however, is 0.40. Against the 0.98 you get with a reference, that means some utterances come out in a noticeably different voice. That is why the first sentence of the model card reads "better than Base in reference-free generation, but speaker consistency is still limited".

## Why a synthetic speaker instead of a real voice actor

In the [previous post](/tech-blog/en/llmops/speech-finetuning-pre-registered-gates/) we wrote that two brand-voice LoRAs trained on professional voice actors from a public dataset had passed the same gates. On quality they were releasable, but those weights reproduce the timbre of one specific person. Permission to use the data and consent to "let third parties download a model that speaks in that person's voice" are questions of different scope, so we decided not to publish them until the rights are confirmed.

This model was built to avoid that problem from the start. The design description names no celebrity, voice actor or character, and no recording of a real person was used as a reference at any stage. All 934 training utterances were synthesized by VoxCPM2 itself from the F1 reference, and the description, the generation seed and the hash of the reference file are kept in the ledger so the origin of the voice can be checked again later. This is a factual statement about the process, not a legal opinion that no third-party right can be affected. The card says so in the same words.

## From eight descriptions to F1

Voice Design creates a voice from a text description alone, with no reference audio. We wrote eight descriptions covering gender, age range, pitch, tone and pace to produce four female and four male candidates, and for each one synthesized an 8.3-second anchor sentence plus ten test sentences, scoring naturalness, speaker consistency against the anchor and content accuracy.

| Candidate | Intended use | UTMOS | Anchor cosine, mean / min | CER |
|---|---|---|---|---|
| F1 | Corporate AI assistant | 3.46 | 0.988 / 0.976 | 7.3% |
| F2 | Customer guidance | 2.24 | 0.970 / 0.949 | 14.9% |
| F3 | Conversational agent | 3.00 | 0.980 / 0.949 | 11.9% |
| F4 | Report narration | 2.47 | 0.971 / 0.949 | 8.9% |
| M1 | Corporate AI assistant | 3.17 | 0.977 / 0.932 | 5.6% |
| M2 | Conversational agent | 3.02 | 0.973 / 0.957 | 11.9% |
| M3 | Technical explanation | 3.14 | 0.974 / 0.921 | 4.6% |
| M4 | Customer service | 2.96 | 0.973 / 0.917 | 13.4% |

F1 ranked first on both naturalness and speaker consistency. Its CER of 7.3% was higher than M3's 4.6%, but reading the sentences one by one showed that most of the gap was whisper writing numbers as Arabic numerals, and the real content errors were one or two in ten sentences. We chose F1 for consistency and naturalness.

Regenerating the same description with only the seed changed scattered the cosine to the anchor between 0.65 and 0.95. A description plus a seed cannot reproduce the same voice, so we sealed one F1 anchor file as the fixed reference and used only that file for every synthesis and evaluation afterwards. That file is the reference clip bundled in the model repository.

## A 1,200-sentence script and rules for reading numbers

The training script was written in house rather than taken from a public corpus. It has 1,200 sentences in seven categories: general, enterprise and technology, numbers, money and dates, alphanumerics and product names, long sentences, customer-service dialogue and hard pronunciation. It mixes sentences filled from 52 templates with 337 handwritten ones, and the splits were made so that no template appears in both training and evaluation. Every sentence has a display form and a spoken form. "3:30 PM" is the display form and "three thirty in the afternoon" written out in Korean is the spoken form. The model was trained on spoken forms, so to feed it numbers you write them in Korean words as they are read.

Synthesis gave VoxCPM2 Base the F1 reference and had it read the 1,000 sentences of the training split. Each utterance passed four filters: whisper back-transcription matches the spoken form (CER at most 8%), cosine to the anchor at least 0.95, UTMOS at least 2.9, and no runaway or silence. The cutoffs sit a little below the bottom 10% of a 15-minute pilot, cosine 0.975 and UTMOS 3.13, so they remove only outliers from the distribution.

Opening the 30 pilot utterances that failed the CER filter showed that 22 of them were a scorer problem, not a TTS problem. The script says "three hundred twenty-five million won" in Korean words; whisper writes "325,000,000 won" in digits and transliterates product names. The content was right, the characters differed, and CER was inflated to 10% to 30%. So we added a comparator that tries three variants, Arabic numerals expanded into Sino-Korean and native Korean numerals, and both sides stripped of digits and Latin tokens, and keeps the lowest CER, while flagging sentences that pass only in the stripped variant as needing a human listen. After that correction the pilot acceptance rate rose from 85% to 90%.

In the full run, 934 of 1,000 sentences passed, giving 80.8 minutes. Of the 66 rejections, 64 were CER and 38 of those were in the alphanumeric category. The target had been 120 minutes, but the training pool was exhausted and we did not fill the gap with utterances below the bar. So we trained on 80.8 minutes.

## Loss goes down, but you cannot beat the teacher

The LoRA recipe is the one that passed in the previous post: rank 32, alpha 32, learning rate 1e-4, batch 4 with 4 accumulation steps, 2 epochs of 112 steps, with a same-speaker reference clip attached to 40% of rows. Validation loss fell from 0.689 to 0.586, a 15% drop, smaller than when we trained on real voice-actor data, because the training audio is VoxCPM2's own output and there is no new distribution for the model to learn.

This is the heart of self-distillation. When the model that produced the training data is the model being trained, no amount of loss reduction can make it better than the teacher; all it can do is bias the model toward one voice. So "is it better than Base+Ref when given a reference" was a question with a known answer. Gates T1 to T4 serve to confirm non-inferiority, and the model's value was measured by the separate question "does that voice come out without a reference".

The one gate that failed at first was T5, the real-time factor (RTF, synthesis time divided by audio length). Measured through a model object with the LoRA attached, RTF went from 0.145 to 0.176, 22% slower, and all three seeds failed. It is the same effect we saw in the previous post: the slowdown comes not from the adapter arithmetic but from the inference path of a model object built with a LoRA configuration. Merging the 192 LoRA modules into the base and loading them into a plain base object gave RTF 0.147, 1.09 times the base and inside the 1.1 limit. The released checkpoint is these merged weights.

We also report the numbers the averages hide. Among reference-free generations, the minimum cosine to the F1 anchor was 0.40 as the median across seeds and went as low as 0.38 on the worst seed. For the same sentence generated with different seeds, the lowest cosine was 0.31. Means of 0.79 and 0.81 do not mean every utterance is in the F1 voice.

## Where ThakiCloud uses this model

This is the first public checkpoint of the in-house brand voice for Paxis voice agents. The first problem you hit when adding speech to a service is not the model but whose voice to use. A real speaker means confirming the scope of consent, and shipping a reference clip with every request adds one more operational path. Baking a designed speaker into the weights reduces both problems at once. The recommended configuration in this version is still with the bundled reference, and the reference-free mode is labeled as a brand-like voice and not yet used where a fixed brand voice is required.

Training and evaluation ran as queued jobs on our internal GPU cluster: 0.13 hours for speaker design, 0.44 for synthesis, 0.36 for the LoRA and 1.1 for evaluation, about 2.1 GPU-hours in total. The checkpoint has the same architecture and parameter count as the base, so it can be served on Metis with the same settings as VoxCPM2.

## Next

The task for v0.2 is not more data but reference-free speaker consistency. In self-distillation, synthesizing more data only grows the set inside the teacher's distribution. We plan to open up the low-cosine utterances by sentence category and length, and to compare, under the same gates, adding explicit speaker conditioning to the training input against restructuring the data. The goal is a brand voice in Paxis Voice that comes out stably without shipping a reference wav. The principle that weights trained on real voice actors stay unpublished until the rights are confirmed is unchanged.

## Sources

- Released model: [ThakiCloud/Thaki-SyntheticVoice-KO-2B-v0.1](https://huggingface.co/ThakiCloud/Thaki-SyntheticVoice-KO-2B-v0.1)
- Base model: [openbmb/VoxCPM2](https://huggingface.co/openbmb/VoxCPM2), [VoxCPM GitHub](https://github.com/OpenBMB/VoxCPM)
- Scorers: [whisper-large-v3-turbo](https://huggingface.co/openai/whisper-large-v3-turbo), [WavLM-base-plus-sv](https://huggingface.co/microsoft/wavlm-base-plus-sv), [UTMOS22](https://arxiv.org/abs/2204.02152)
- Previous posts: [Our First Public ASR Model Cuts Korean Dialect CER by 20%: Thaki-ASR-KO-Dialects-v1](/tech-blog/en/llmops/thaki-asr-ko-dialects-v1-release/), [What We Learned from Failing 7 of 9 Speech Model Fine-Tuning Gates](/tech-blog/en/llmops/speech-finetuning-pre-registered-gates/)
