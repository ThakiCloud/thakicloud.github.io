---
title: "We Paid Extra to Look Worse"
excerpt: "Thirty seconds of 480p cost $4.12, and a good chunk of that went into making it look grainier."
date: 2026-08-14
categories:
  - comics
tags:
  - ai-video
  - generation-cost
  - gpu
  - on-prem
  - metis
author_profile: true
toc: false
image: /assets/images/posts/comics/paid-extra-to-look-worse/strip.webp
video: /assets/videos/posts/만화/paid-extra-to-look-worse/comic.mp4
audiobook: /assets/audio/posts/paid-extra-to-look-worse/audiobook-en.mp3
audiobook_note: "만화 캐릭터 목소리로 듣는 오디오북 (Qwen3-TTS 로컬)"
---

A thirty-second gym vlog made with a text-to-video model went around the timeline this week. It runs at 480p, looks like a nineties tape camcorder, and shakes like someone is holding it. The full prompt was published, camera notes and all, so anyone can copy it.
The interesting part is the receipt. Those thirty seconds cost $4.12. A full minute runs past eight dollars, and every retake bills again. Dropping the resolution does not drop the compute, so the grain is a taste choice rather than a saving. Prompts get shared for free. Render bills do not.

![We Paid Extra to Look Worse](/assets/images/posts/comics/paid-extra-to-look-worse/strip.webp)

> Source: [RT @EvoLinkAi: Seedance 2.5 Korean Girl gym Vlog](https://x.com/hjguyhan/status/2087843518584951236) · twitter

**▶ Animated edition — the characters speak for themselves (Korean audio)**

<video controls playsinline preload="metadata" poster="/assets/images/posts/comics/paid-extra-to-look-worse/strip.webp" style="width:100%;border-radius:8px;">
  <source src="/assets/videos/posts/만화/paid-extra-to-look-worse/comic.mp4" type="video/mp4">
  <track kind="subtitles" srclang="en" label="English" src="/assets/videos/posts/만화/paid-extra-to-look-worse/comic.en.vtt" default>
</video>

[Download video](/assets/videos/posts/만화/paid-extra-to-look-worse/comic.mp4)

## What this means for ThakiCloud

Video generation is inference. Every frame is compute, and whose card runs that compute sets the unit price. Rent an API and each frame lands on an invoice. Serve the same model through Metis on hardware you own and the frame turns into electricity plus depreciation, which is why twenty retakes stop being scary.
Telox and Velox are the layers that actually supply those cards, so exploratory work can sit on spare capacity while scheduled renders get dedicated resources. The cost curve then tracks what you own rather than what you used. Paxis handles the rest as agents: prompt design, render, retry on failure, subtitles. This comic and its video come off that pipeline. Keep the grain if you like the grain. The meter is the part worth owning.

---

*An auto-generated comic riffing on this week's industry news.*
