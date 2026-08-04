---
title: "Low Effort Somehow Won the Code Review"
excerpt: "We cranked the effort dial to max. So did the invoice."
date: 2026-07-17
categories:
  - comics
tags:
  - ai-coding
  - code-review
  - on-prem
  - sovereign-ai
  - thakicloud
  - compute-cost
author_profile: true
toc: false
image: /assets/images/posts/comics/code-review-effort-levels-low-effort-wins/strip.png
audiobook: /assets/audio/posts/code-review-effort-levels-low-effort-wins/audiobook-en.mp3
audiobook_note: "만화 캐릭터 목소리로 듣는 오디오북 (Qwen3-TTS 로컬)"
---

Claude Code's /code-review just grew effort levels: a dial for how hard the review works, and the whole review gets rewritten from scratch at each setting. The funny part is that even the lowest effort setting reportedly beats other code reviewers. Cranking the dial, though, just means running more inference, and on someone else's cloud every turn of that dial ticks the meter. Naturally, Paxis and Metis pushed it to the top.

![Low Effort Somehow Won the Code Review]({{ '/assets/images/posts/comics/code-review-effort-levels-low-effort-wins/strip.png' | relative_url }})

> Source: [Claude Code's /code-review now has effort levels, with the review rewritten at every one.](https://x.com/hjguyhan/status/2077894748183097710) · twitter

## What this means for ThakiCloud

Whether you can crank the effort dial comes down to who owns the compute. On a rented cloud, every notch of review effort nudges the bill, so you end up rationing the dial exactly when you need it. ThakiCloud's on-prem approach keeps the models and GPUs inside your own facility, so you can push effort to the top without watching a meter spin. Paxis fans out review agents across effort levels and cross-checks them, while Metis runs that inference on your own rack. If low effort already wins, the side that runs high effort for free just goes further.

---

*An auto-generated comic riffing on this week's industry news.*
