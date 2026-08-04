---
title: "Running a Monster Model on Your Junk Drawer"
excerpt: "Couldn't afford one monster, so we ganged up all the little ones."
date: 2026-07-14
categories:
  - comics
tags:
  - mesh-llm
  - distributed-inference
  - on-prem
  - gpu
  - sovereignty
  - thakicloud
author_profile: true
toc: false
image: /assets/images/posts/comics/mesh-llm-no-80gb-gpu/strip.png
audiobook: /assets/audio/posts/mesh-llm-no-80gb-gpu/audiobook-en.mp3
audiobook_note: "만화 캐릭터 목소리로 듣는 오디오북 (Qwen3-TTS 로컬)"
canonical_url: "https://thakicloud.com/tech-blog/en/comics/mesh-llm-no-80gb-gpu/"
published: false
---

To run a 70B-plus model, the going wisdom says you need a single 80GB GPU that costs a fortune. Mesh LLM flips that assumption: slice the inference into pieces and spread them across the devices you already own. Instead of buying one monster, you gang up the small stuff and make it act like one. Paxis and Metis take the idea for a ThakiCloud-flavored spin.

![Running a Monster Model on Your Junk Drawer]({{ '/assets/images/posts/comics/mesh-llm-no-80gb-gpu/strip.png' | relative_url }})

> Source: [RT @DataChaz: Want to run a 70B+ model but don't have an 80GB GPU? Mesh LLM distributes inference across the devices you actually have.](https://x.com/hjguyhan/status/2076693609827754131) · twitter

## What this means for ThakiCloud

Metis was built to train and infer on the hardware you already have, instead of renting someone else's giant GPU by the month. The Mesh LLM lesson — wire the small pieces together to run the big thing — lands right in that lane. Paxis carves the distributed work into agents and orchestrates it, and on-prem means neither the data nor the model ever leaves the building. Before the GPU invoice unrolls to the floor, maybe start with what's already plugged in.

---

*An auto-generated comic riffing on this week's industry news.*
