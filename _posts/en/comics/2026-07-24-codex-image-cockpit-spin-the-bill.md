---
title: "Rendered Every Angle Except the Price"
excerpt: "A cockpit that renders your character from every side, and bills you frame by frame."
date: 2026-07-24
categories:
  - comics
tags:
  - codex
  - image-generation
  - inference-cost
  - on-prem
  - animation
  - sovereignty
author_profile: true
toc: false
image: /assets/images/posts/comics/codex-image-cockpit-spin-the-bill/strip.png
video: /assets/videos/posts/만화/codex-image-cockpit-spin-the-bill/comic.en.mp4
audiobook: /assets/audio/posts/codex-image-cockpit-spin-the-bill/audiobook-en.mp3
audiobook_note: "만화 캐릭터 목소리로 듣는 오디오북 (Qwen3-TTS 로컬)"
canonical_url: "https://thakicloud.com/tech-blog/en/comics/codex-image-cockpit-spin-the-bill/"
published: false
---

A tidy image cockpit for Codex workflows just shipped. Pick a direction, front, three-quarter, side, three-quarter back, back, and it animates your character turning that way, now with experimental 16- and 20-frame takes. Handy. The catch hides in the word render: every frame is one image inference, which is to say one metered call. More angles, more frames, a smoother sprite, and a meter that spins right along with it. And the whole cockpit only flies on someone else's engine.

![Rendered Every Angle Except the Price](/assets/images/posts/comics/codex-image-cockpit-spin-the-bill/strip.png)

> Source: [RT @dreiachse: Image Cockpit for Codex Workflows v0.1.7 を公開しました！](https://x.com/hjguyhan/status/2080249200890237270) · twitter

**▶ Animated edition, the characters speak for themselves (Korean audio, English subtitles)**

<video controls playsinline preload="metadata" poster="/assets/images/posts/comics/codex-image-cockpit-spin-the-bill/strip.png" style="width:100%;border-radius:8px;">
  <source src="/assets/videos/posts/만화/codex-image-cockpit-spin-the-bill/comic.en.mp4" type="video/mp4">
</video>

## What this means for ThakiCloud

The fun of the cockpit hides its real cost in that phrase, per-frame inference. Five directions at twenty frames is a hundred-plus metered calls to turn one character once, all of it printing on somebody else's cloud. ThakiCloud pulls that math back inside your own walls, which is what on-prem means: the models run in racks you own. Metis serves the image and animation models on-prem, Paxis splits the directions and frames across worker agents, and however many frames you stack, what spins is your GPU, not a meter. Enjoy the cockpit. Just bolt the engine to your own rack.

---

*An auto-generated comic riffing on this week's industry news.*
