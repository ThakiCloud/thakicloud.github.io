---
title: "Where a Model That Never Saw the Data Beat the One That Did"
seo_title: "Satoori-KO Korean dialect models - 92% synthetic recovery measured - ThakiCloud"
seo_description: "We measured how much licence-restricted Korean dialect supervision synthetic data can recover, and released two five-region dialect models on Hugging Face. Recovery split sharply by axis, and on sentences we wrote ourselves the ranking flipped."
excerpt: "Korean dialect data is not missing, it is unusable. We trained one model on the restricted corpus and one on zero characters of it, and found that recovery depends entirely on which ability you measure."
date: 2026-09-10
last_modified_at: 2026-09-10
tags:
  - korean-dialect
  - satoori
  - synthetic-data
  - benchmark
  - kodialectbench
  - open-model
  - huggingface
  - licensing
categories:
  - research
author_profile: true
toc: true
toc_label: "Contents"
canonical_url: "https://thakicloud.com/tech-blog/en/research/satoori-ko-synthetic-recovery/"
---

We have released two Korean regional dialect models on Hugging Face. One learned from real dialect recordings. The other learned without a single character of them. If you have ever been blocked from publishing a result because the data underneath it was licence-restricted, this post is for you.

The headline first. The synthetic model recovered roughly nine points out of ten of the real-data training gain. But that score split sharply depending on which ability we measured, and on sentences we wrote ourselves the ranking flipped.

## In plain terms

Picture two students learning a regional dialect. One travelled to the region and listened to older residents talking. The other never went, and received only a phrasebook compiled from those same recordings, which they practised by applying to sentences somebody else wrote.

We will call the first the **resident student** and the second the **phrasebook student** for the rest of this post. The experiment is simply putting both through the same exam.

## What we did

Dialect work is not short of data. It is short of usable data. Korean has five regional conversation corpora at the national AI Hub, but redistribution and export are restricted, so a model built from them is hard to publish alongside a paper.

We built the exam first. It holds 1,000 questions, 200 for each of five regions, and it scores three abilities separately. Turning dialect into standard Korean is **comprehension**. Naming which region a sentence comes from is **identification**. Turning standard Korean into dialect is **generation**.

The exam itself falls under the same licence. So instead of the question text we published a one-way transformation of each question number along with the scoring code. Anyone can reconstruct the same 1,000 questions from their own licensed copy and score against them.

Then we raised the two students from the same base model. The resident student learned from real paired sentences. The phrasebook student learned only from synthetic sentences, made by running a rule-based converter over standard Korean utterances our own model wrote.

## What came out

We call the recovered share the recovery rate. Take the resident student's gain as 100 and ask how much of it the phrasebook student reached.

The median came out at 92.3 percent. Broken down by ability the story changes completely. Generation reached 105.6 percent and went past. Identification reached 91.2 percent. Comprehension stopped at 52.7 percent.

Put simply, the ability to **produce** dialect transferred almost fully through a phrasebook, while the ability to **understand** it transferred only halfway.

One thing needs flagging here. A generation score above 100 does not mean the phrasebook student is better. The synthetic data made the regions more distinct from each other than they really are. Real dialects bleed into their neighbours, the synthetic ones did not reproduce that overlap, and the score read that gap as a gain.

### On our own sentences the ranking flipped

The exam questions came from the same source the resident student studied. That favours the resident student. So we measured what happens outside the exam.

We wrote six scenes ourselves, covering customer service, a public notice, a tourism description, drama dialogue, game dialogue, and everyday speech. We ran both models over all five regions for each. No source material was used.

The resident student produced genuinely different output per region about eight times in ten. The phrasebook student managed close to ten in ten. On the formal customer-service sentence in particular, the resident student returned **one identical sentence for all five regions**, ignoring the requested region completely.

Put simply, the resident student led inside the exam, and the phrasebook student held up better outside it.

The reason is not hard to guess. The phrasebook student practised on sentences our model wrote, which spanned a wide range of registers. The resident student heard relaxed conversation among older speakers, which contains almost no formal announcement register.

### What the output actually looks like

Here is the phrasebook student on one sentence, "it rained a lot yesterday so the road got soaked."

| Region | Output |
|---|---|
| Gangwon | 어재 비가 마이 와가주 길이 다 젖었더라 |
| Gyeongsang | 어제 비가 마이 와가꼬 길이 다 젖었더라 |
| Jeolla | 어제 비가 많이 와가꼬 길이 다 젖었더라 |
| Jeju | 어제 비가 하영 와가주 길이 다 젖었더라 |

The Jeju form "하영" means "a lot" and is specific to that island. The Gangwon "와가주" and Gyeongsang "와가꼬" genuinely diverge. But a Chungcheong request also produced "와가꼬", which belongs to Gyeongsang and Jeolla. The model separates the regions without always separating them correctly.

## What to change because of this

If dialect data is locked behind a licence, generation work can start on synthetic data. Rewriting register, writing lines with regional colour, and giving characters distinct voices all sit in that bucket.

Understanding, by contrast, is hard to fill in synthetically. Summarising a dialect support call into standard Korean needs the real thing. Of the two models we released, that use case wants the real-data one.

And if you are planning to build synthetic data, change your ordering. We refined the conversion rules three times and the score did not move. What moved it was **the register of the sentences being converted**. Switching the source from written prose to spoken utterances doubled the rate at which rules found somewhere to apply.

The next largest lever was not growing the source corpus but growing the training set. Quadrupling the source changed almost nothing, while tripling the training set lifted recovery clearly.

Both models are available here.

- Real-data model: [ThakiCloud/Qwen3.8-27B-Satoori-KO](https://huggingface.co/ThakiCloud/Qwen3.8-27B-Satoori-KO)
- Synthetic model: [ThakiCloud/Qwen3.8-27B-Satoori-KO-Synth](https://huggingface.co/ThakiCloud/Qwen3.8-27B-Satoori-KO-Synth)

## What not to trust

**These are not conversational models.** All training was single-turn transformation and classification. Holding a conversation in dialect was neither trained nor measured.

**Each arm was trained once.** A small score gap between the two is not yet distinguishable from ordinary training noise. A repeat run under identical settings is in progress.

**The out-of-exam measurement covers six scenes.** It is a demonstration, not a benchmark. Please do not rank the two models on those numbers.

**The dialectness score is a lower bound.** It counts only words that match a lexicon we mined. Dialect phenomena outside that lexicon, such as intonation and word order, are invisible to it.

**Neither model heard any audio.** Both learned from transcription alone, so they carry no pronunciation information.

The training data came from AI Hub's Korean dialect speech corpora and its corpora for middle-aged and elderly speakers. Neither repository contains the source data or any dialect-to-standard correspondence lexicon; we published weights only.
