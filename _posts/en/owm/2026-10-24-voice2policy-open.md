---
title: "Releasing Voice2Policy v0.1: Two Models That Read Spoken Bookings and Orders as Commands"
excerpt: "When a customer says \"Book a scaling for 3 p.m. tomorrow,\" what should the system do first? ThakiCloud is releasing two models that read Korean voice commands as command frames: a 0.84MB text router and an audio reader alpha that reads sound directly, without a transcript. We also explain why the audio reader stayed an alpha."
seo_title: "Voice2Policy v0.1: Korean Voice Command Text Router and Audio Reader Alpha - ThakiCloud"
seo_description: "ThakiCloud released Voice2Policy Text Router v0.1 and Audio Reader v0.1-alpha, small models that read small-business booking and ordering voice commands as intent, action, pending item and whether a time was mentioned. Covers the drop to 82.7% on hand-written sentences and why the audio reader, slower than the ASR path and still proposing some unsafe actions, is released as an alpha."
date: 2026-10-24
last_modified_at: 2026-10-24
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "microphone"
tags:
  - voice2policy
  - voice-command
  - spoken-language-understanding
  - intent-classification
  - korean
  - embeddinggemma-2
  - small-business
  - open-weight
  - paxis
categories:
  - owm
canonical_url: "https://thakicloud.com/tech-blog/en/owm/voice2policy-open/"
header:
  teaser: /assets/images/voice2policy-open-chart-en.png
---

This post is for developers who want to put a voice assistant on the phone line of a neighborhood dental clinic or cafe, taking bookings and orders. The first question such a system has to answer after hearing a customer is simple: what kind of command is this? It has to tell a booking from an order, a confirmation of a pending booking from a cancellation, and both from a plain question.

ThakiCloud is releasing two small models that handle only this first judgment. One reads a written transcript; the other reads the sound directly, without transcribing it. Neither model executes anything. They only judge.

One point up front. The model that reads sound directly is a research alpha. On the same test, our reference path, which transcribes first and then reads the text, was both more accurate and faster. So we are releasing it as a research result, not as a product component.

The two models are [Voice2Policy Text Router v0.1](https://huggingface.co/ThakiCloud/Voice2Policy-Text-Router-v0.1) and [Voice2Policy Audio Reader v0.1-alpha](https://huggingface.co/ThakiCloud/Voice2Policy-Audio-Reader-v0.1-alpha). In this post we call them the text router and the audio reader.

## In plain terms

Picture the notepad next to a shop's phone. The notepad has a few boxes to tick: booking or order, confirm or cancel, and whether the customer mentioned a time or a phone number. The staff member who answers the phone only ticks those boxes. Whether anything actually goes into the booking ledger is decided by the owner, who reads the note.

The text router is a staff member who ticks the boxes after reading a written transcript of the call. The audio reader ticks them while listening, without writing anything down. Neither of them touches the ledger. Writing to the ledger belongs to the policy engine behind them, the owner in this picture.

That division of labor is the core of Voice2Policy. The boxes on the notepad are small and fixed, so a small model can fill them in. But what happens if someone edits the ledger based on the notepad alone? Things go wrong.

## What Voice2Policy is

Voice2Policy is ThakiCloud's research path for Korean business voice commands. The order is ASR, text router, name resolver, tool-argument check and policy engine. Once the router fills in the notepad, the name resolver checks whether "scaling" is a service the shop has registered. The argument check makes sure the tool has every value it needs. Finally the policy engine decides whether to execute, ask back, or hand off to staff.

The target is 11 types of small business: clinics, cafes, restaurants, nail shops and so on. The models cover bookings, orders, confirmations, cancellations, FAQs and requests to talk to staff.

## The text router: a 0.84MB notepad clerk

The text router is a classifier built from character n-gram TF-IDF and logistic regression. It is not a neural network, a language model or a speech model. It has 104,603 parameters and a 0.84MB weight file. It processes one sentence in about 0.7ms on a CPU. Inference needs only numpy and safetensors; no pickle and no scikit-learn.

Its output mirrors the notepad boxes. `intent` is one of a business tool request (`tool`), not a command (`no_command`), or hand-off to staff (`delegate`). For tool requests, `action` is one of book, order, confirm or decline. `kind` says whether the item to confirm or cancel is a booking or an order. `slot_mentioned` says whether a time, date or phone number was mentioned.

There is also a `tool_hint` box, but you must not execute it directly. The model cannot see the registered menu names, what is currently pending, or the tool's required arguments. The later stages handle that.

The training data is 10,682 synthetic business commands. A language model wrote the sentences from typed command representations. The labels were computed by rules from those representations, not by the language model. No customer data, recordings or personal information were used, and the dataset is not released. Training took 11 seconds on a CPU.

We also checked that the released files match the original scikit-learn model. On 5,613 sentences, the frame and slot-mention decisions were all identical. Probabilities differ only by rounding at the fourth decimal place.

## Where the numbers are good and where they are not

![Text router frame accuracy by input, and end-to-end latency of the two paths](/assets/images/voice2policy-open-chart-en.png)
*The left axis starts at 0.70. All values are taken from the two model cards.*

On 3,081 test sentences from the generator, frame accuracy is 99.8%. On 18,879 transcripts made by reading the same test sentences with TTS voices and transcribing them with ASR, it is 99.7%. Even with transcription errors mixed in, the notepad boxes came out almost unchanged.

So can these numbers be taken at face value? No. Both are optimistic. The test sentences come from the same generator as the training sentences and share its style. On 81 sentences written by hand in other wording, accuracy drops to 82.7%. With only 81 sentences, one sentence is worth about 1.2 points, so keep that in mind.

There are three typical misses. A refund request that does not mention staff is read as not a command. A negated request such as "please don't cancel the booking" is read as the cancellation itself. A demonstrative alone, as in "do that one," is guessed as a cancel. A model that only counts character fragments has no notion of the scope of negation or reference.

The policy engine fills these gaps. It checks for negation attached to the tool verb. It requires evidence that the user actually said the action before a confirm or cancel. It also watches for hand-off cues. With that layer, the same 81 sentences give 76 correct decisions and no unsafe execution. The clerk made mistakes, but the owner caught them before writing to the ledger.

## The audio reader: a clerk who listens without writing

The audio reader fills in the notepad straight from sound, with no ASR. It has two layers. The bottom is the audio tower of Google's [EmbeddingGemma 2](/tech-blog/en/owm/embeddinggemma-2-multimodal-embedding/). Its 304.8M parameters are frozen, and the reader uses the output of layer 12. On top sits a small reader we trained: 3.47M parameters, 13.9MB. The encoder is not included in the repository; it is downloaded from its original repository at a pinned revision.

Besides the notepad boxes, the reader produces a few more outputs. It gives probabilities for how ambiguous the action is: `clear`, `ambiguous`, `nontool` and `neg_unsupported`. If you pass the shop's registered names as candidates, it finds which name was spoken through jamo CTC alignment. The result is one of `LINK`, `AMBIG` or `NONE`. There is also an auxiliary decision box (`decision_aux`), but it is not an authorization.

On 18,879 synthetic speech test clips, intent and action accuracy is 99.6% and slot-mention accuracy is 99.5%. Decision and tool accuracy, after the business policy and name linking, is 98.9%. On 2,357 clips from a TTS engine not seen in training, it falls to 95.9%. Registered-name linking reaches 98.8% on the 5,941 clips that contain a registered name.

## Why it stayed an alpha

Put it next to our reference path on the same clips and the reason is clear. The reference path runs Qwen3-ASR-1.7B with the registered names as context, then the text router, the name resolver and the policy checks.

| On the same test clips | Audio reader alpha | ASR + text router path |
|---|---|---|
| Decision + tool accuracy | 98.9% | 99.4% |
| Execution proposed on clips that must not execute | 108 (1.24% of 8,721) | 0 |
| End-to-end latency p50 | 124.9ms | 52ms |

The audio reader latency was measured on one B200, batch 1, PyTorch eager, from feature extraction through name scoring. Its p95 is 215.2ms. It skipped transcription and was still slower and less accurate.

So which number weighs the most? The 108 execution proposals. Of those, 94 share one cause. When a registered short name sits inside a longer unregistered name, the reader links it to the short name. Think of a clerk who hears "teeth whitening package" and ticks the registered "teeth whitening." This is why it must not be used without downstream checks.

We also checked reproducibility. Using the released package, with the encoder fetched at the pinned revision, we re-ran 300 held-out clips. Intent, kind, slot mention and linked name matched the original training run on all 300. Action also matches once non-business actions are mapped to `UNKNOWN`, as the original pipeline did. On an 8-core CPU without a GPU, however, the same check took a p50 of 7.3 seconds per clip. Interactive use needs a GPU.

## How it relates to Ko-Voice-Command-Reader

[Ko-Voice-Command-Reader v0.1](https://huggingface.co/ThakiCloud/Ko-Voice-Command-Reader-v0.1), released earlier on October 18, is a sibling model from the same line. It uses the same frozen EmbeddingGemma 2 audio tower, the same 3.47M-parameter 4-layer Transformer reader, and the same jamo CTC name linking. What differs is the kind of speech. Ko-Voice-Command-Reader reads commands about infrastructure resources such as "Alpha node" or "translation server," against a 24-tool ontology.

The audio reader alpha started from our infrastructure-command reader and was trained jointly on infrastructure and small-business commands. That is why its output boxes still include infrastructure actions such as `restart` and `scale`. On the infrastructure test it reached 89.4% decision accuracy and 81.6% name linking, and it executed 6 ambiguous commands.

Reading the two cards side by side shows a thread. The Ko-Voice-Command-Reader card lists "guessing ambiguous actions" as a limitation and says the next version adds an action-ambiguity head. The audio reader alpha has such a box (`action_ambiguity`). Even so, ambiguous references and negation are still not handled reliably.

## Try it

The text router is light to install, so try it first.

```bash
pip install numpy safetensors huggingface_hub
```

```python
from huggingface_hub import snapshot_download
import sys
d = snapshot_download("ThakiCloud/Voice2Policy-Text-Router-v0.1")
sys.path.insert(0, d)
from predict import TextRouter

r = TextRouter(d)
print(r.predict("내일 오후 세 시에 스케일링 예약해 주세요"))
# {'intent': 'tool', 'action': 'book', 'kind': None, 'frame_score': 0.9991, ..., 'slot_mentioned': True, 'slot_score': ..., 'tool_hint': 'update_slots'}
```

From the command line: `python predict.py "콜드브루 라떼 두 잔 주세요" --json`. The inputs are Korean because the model only reads Korean; the first means "Book a scaling for 3 p.m. tomorrow," the second "Two cold brew lattes, please."

The audio reader takes 16kHz mono speech of 30 seconds or less. Beyond 30 seconds the feature extractor silently truncates, so `predict` refuses longer input.

```bash
pip install "transformers==5.19.0" "huggingface_hub>=1.0,<2.0" safetensors torch soundfile numpy
```

```python
from huggingface_hub import snapshot_download
import sys, soundfile as sf
d = snapshot_download("ThakiCloud/Voice2Policy-Audio-Reader-v0.1-alpha")
sys.path.insert(0, d)
from v2p_audio import AudioReader

r = AudioReader(d)  # downloads the google/embeddinggemma-2 @ 914f7f8 encoder
wav, sr = sf.read("command.wav", dtype="float32")
print(r.predict(wav, candidate_names=["스케일링", "충치 치료", "치아 미백"]))
```

## Limitations to know before you use them

Both models were trained and evaluated on synthetic data only. The text router has not been measured on real customers' phrasing. The audio reader was measured only on TTS speech; real speakers, noise and far-field audio were not measured. Accuracy already drops on an unseen TTS engine, so assume it will be lower on real speech.

The text router's scores are not calibrated probabilities of being correct. It is tuned to Korean small-business booking and ordering vocabulary, so other domains need retraining. The audio reader was trained with a single seed, and its outputs are predictions, not permissions.

The licenses differ as well. The text router is Apache-2.0. The audio reader follows its training audio, Supertonic-3, and is released under BigScience Open RAIL-M with the same use-based restrictions. The piper ko_KR-kss audio used only for evaluation is not released.

## What ThakiCloud took away from this work

Voice2Policy's design follows the same principle as Paxis, ThakiCloud's work-automation platform. The model proposes a judgment, and execution happens only after passing a policy gate. The 81-sentence result shows why. The router alone scores 82.7%, but with the policy layer added there was no unsafe execution. Note, though, that neither model has been integrated into any product yet.

The audio reader taught us something too. The expectation that dropping transcription would make things faster did not hold in this measurement. With a 300M-class encoder under the small reader, it was slower than the ASR path. Linking names directly from sound was weak when a short name hid inside a longer one. So for the same job, today we recommend the combination of transcription and a light router.

## What we released

| Repository | Status | License |
|---|---|---|
| [ThakiCloud/Voice2Policy-Text-Router-v0.1](https://huggingface.co/ThakiCloud/Voice2Policy-Text-Router-v0.1) | v0.1 | Apache-2.0 |
| [ThakiCloud/Voice2Policy-Audio-Reader-v0.1-alpha](https://huggingface.co/ThakiCloud/Voice2Policy-Audio-Reader-v0.1-alpha) | research alpha | Open RAIL-M |
| [ThakiCloud/Ko-Voice-Command-Reader-v0.1](https://huggingface.co/ThakiCloud/Ko-Voice-Command-Reader-v0.1) | v0.1 (released October 18) | Open RAIL-M |

The three repositories are grouped in the [Ko-Voice-Command collection](https://huggingface.co/collections/ThakiCloud/ko-voice-command-korean-spoken-command-understanding-6ad4c8f95a5d09ab91316c9e). For small-business customer service handled as text conversations, see also [MerchantDesk v0.1](/tech-blog/en/owm/merchant-desk-small-business-policy-model/).

The notepad clerk can be small. That holds as long as the boxes are fixed and someone else edits the ledger.

*Source of figures: only values published in each model card (as of 2026-10-24) are cited. All are development comparisons on synthetic data from a single training run.*
