---
title: "KO-VoicePersona-E4B: A Korean Voice Persona Model That Speaks Short and Checks Facts With Tools"
excerpt: "For teams building a Korean voice assistant or mascot. KO-VoicePersona-E4B, a LoRA on Nemotron 3.5 Bolt E4B, reaches 0.78 tool-call accuracy and 0.88 persona retention on a hand-written independent set of 58 dialogs. The limits are reported alongside."
seo_title: "KO-VoicePersona-E4B Korean Voice Persona Model - ThakiCloud"
seo_description: "For teams building a Korean voice assistant or mascot. KO-VoicePersona-E4B, a LoRA on Nemotron 3.5 Bolt E4B, reaches 0.78 tool-call accuracy and 0.88 persona retention on 58 independent dialogs."
date: 2026-10-27
published: true
categories:
  - research
tags:
  - Nemotron
  - Bolt E4B
  - LoRA
  - Voice Assistant
  - Persona
  - Small Language Model
  - Paxis
author_profile: true
toc: true
toc_label: "Table of Contents"
lang: en
permalink: /en/research/ko-voicepersona-e4b/
canonical_url: "https://thakicloud.com/tech-blog/en/research/ko-voicepersona-e4b-en/"
---

This is for teams building a Korean voice assistant or mascot. This post introduces a short-speaking Korean voice persona model. The model answers in speakable Korean of 90 characters or fewer, calls a tool instead of inventing unknown facts, and scored 0.78 tool-call accuracy and 0.88 persona retention on a hand-written independent set of 58 dialogs. It also keeps the rule of one or two sentences, spelling out numbers and English the way they sound. However, 36% of its replies repeat the same stock phrases, and the real speech recognition and synthesis loop has not been evaluated yet. The limits are reported alongside.

![Illustration of the core idea of KO-VoicePersona-E4B: A Korean Voice Persona Model That Speaks Short and Checks Facts With Tools](/assets/images/ko-voicepersona-e4b-en-hero.webp)
*A visual metaphor for the article's key idea.*

## In plain terms

Think of a radio show host. The host does not answer every question at length; it answers in one or two lines. A number or fact it does not know on air is not invented; the host checks with the studio producer and speaks only that answer. And it keeps the show's register from the first minute to the last.

This model is that host in software. The under-90-character answers are the show's register, tools like `lookup` are the producer, and the independent evaluation scores rate the hosting ability. In one line, the model is **a host who does not talk at length, checks what it does not know, and keeps its register**. It is named KO-VoicePersona-E4B: a thin adapter trained on top of the Nemotron 3.5 Bolt E4B base introduced below.

## What Nemotron 3.5 Bolt E4B is

Bolt E4B is a small language model NVIDIA post-trained from Gemma-4-E4B-it. It has 8B total and 4B effective parameters and up to 64K tokens of input and output. NVIDIA strengthens multi-turn tool use, instruction following and input grounding, and trains with GRPO reinforcement learning. Low memory and low time-to-first-token are the design goals, which suits local assistants and edge devices. The license is OpenMDW-1.1, and a separate 4GB Q4_K_M build is published. The BF16 release is meant for customization, so we used it as our base.

## What it does

In a voice conversation the answer reaches the ear, not the eye. This model speaks in one or two sentences of at most 90 characters, and it spells out numbers and English words the way they are pronounced so a TTS engine can read them. It holds the register set in the system prompt (polite haeyo-style or formal hapsyo-style) to the end. Expressions go through `emote`, movement through `move`, fact lookup through `lookup` and schedules through `calendar_lookup`. If a time or number is not in a tool result, it says it could not find it.

For example, asked "How is the weather today?", it does not pretend to know. It calls `lookup` first, and once the result returns it answers briefly from that content only.

## How it was built

![Pipeline from the BF16 base to GGUF](/assets/images/posts/research/bolt-specialists/pipeline-en.svg)
*Figure 1. The two yellow stages keep scores honest. Label generation and leakage checks belong to code, not to a model.*

The training dialogs were synthesized from code rules and an in-house teacher model, then filtered by code validators. A deterministic defect check found third-person self-reference and stilted recall phrasing. It hit 123 times in the training data, and removing 141 dialogs that contained it brought the count to 0.

Training restarted from the BF16 base. The earlier v2 was continued from a previous adapter and repeated stock replies more often, so v3.1 was trained fresh from the base instead.

## Measured results

We compared the base, v2 and v3.1 with identical prompts on a hand-written independent set of 58 dialogs. The last row is tool-call accuracy on the larger test set.

| Evaluation | Bolt base | v2 | v3.1 |
|---|---|---|---|
| Tool-call accuracy (independent, 58) | 0.34 | 0.71 | 0.78 |
| Register retention | 0.37 | 0.96 | 0.97 |
| Spoken form | 0.42 | 0.96 | 0.97 |
| Persona role retention | 0.13 | 0.63 | 0.88 |
| Tool-call accuracy (larger test set) | 0.35 | 0.73 | 0.93 |

The biggest change is persona role retention. The base scores 0.13 and nearly loses its setup as a conversation grows, while v3.1 reaches 0.88. The Q4_K_M GGUF is 5.34 GB and runs at about 188 tok/s on a single stream on one H100, using 3.8 GB of GPU memory. Accuracy matched BF16.

## Honest limits

- 36% of replies are repeated stock phrases. The reference was 28%.
- In 103 independent text turns, one turn fabricated a fact.
- The evaluation dialogs are written text, not real user speech.
- No real ASR and TTS loop was evaluated, so recognition errors and synthesis quality are not in these numbers.

A tool-call accuracy of 0.78 means that in roughly two or three of ten calls the tool name or arguments are off. In the radio metaphor, the host still sometimes hands the producer the wrong question, which is why a layer outside the model must check calls before they run.

## How to use it in Paxis

Paxis is ThakiCloud's platform for automating enterprise work with AI agents. What follows is a design direction, not a shipped feature. KO-VoicePersona-E4B sits as the spoken persona layer between ASR and TTS. It takes what the user said and returns a short reply or a tool call.

![Pre-check in front of agents and a read-only step](/assets/images/posts/research/bolt-specialists/paxis-flow-en.svg)
*Figure 2. The model proposes and code holds permission. A tool call runs only after it passes the Paxis policy check.*

Paxis policy checks each tool call the model emits, and only calls that pass are executed. Facts and times come only from tool results, and the model is kept from speaking values it filled in from memory. If repeated stock phrases bother your service, you can also filter sentences that overlap recent replies in code and regenerate.

## Get the model

- KO-VoicePersona-E4B: https://huggingface.co/ThakiCloud/KO-VoicePersona-E4B
- Collection: https://huggingface.co/collections/ThakiCloud/thakicloud-bolt-e4b-specialists-6ade97db98b0258cb49447a0
