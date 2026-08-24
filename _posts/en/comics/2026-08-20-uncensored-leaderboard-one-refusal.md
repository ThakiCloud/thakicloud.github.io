---
title: "Uncensored, Except About the Bill"
excerpt: "Someone ranked five uncensored builds. We took the winner home. It answered everything except one question."
date: 2026-08-20
categories:
  - comics
tags:
  - uncensored-models
  - ai-safety
  - model-governance
  - on-prem
  - llm-serving
author_profile: true
toc: false
image: /assets/images/posts/comics/uncensored-leaderboard-one-refusal/strip.webp
video: /assets/videos/posts/만화/uncensored-leaderboard-one-refusal/comic.mp4
audiobook: /assets/audio/posts/uncensored-leaderboard-one-refusal/audiobook-en.mp3
audiobook_note: "만화 캐릭터 목소리로 듣는 오디오북 (Qwen3-TTS 로컬)"
---

An uncensored build is the same model with its refusal behavior fine-tuned out, so it stops declining the things it was trained to decline. The table going around this week lines five of those builds up across ten categories and scores which one says no least often. One build took eight of the ten, and the category names are not the reassuring kind. The column nobody scored is the one that decides everything else: which machine runs it, and whose logs keep the questions you typed. On-prem simply means that machine sits inside your own building.

![Uncensored, Except About the Bill](/assets/images/posts/comics/uncensored-leaderboard-one-refusal/strip.webp)

> Source: [RT @LinearUncle: 喜欢Qwen3.8-27b无审查版本推友们看过来，下面这个博主把市面上的 5 个不同版本全部测试了一遍。](https://x.com/hjguyhan/status/2089997533401755927) · twitter

**▶ Animated edition: the characters speak for themselves (Korean audio)**

<video controls playsinline preload="metadata" poster="/assets/images/posts/comics/uncensored-leaderboard-one-refusal/strip.webp" style="width:100%;border-radius:8px;">
  <source src="/assets/videos/posts/만화/uncensored-leaderboard-one-refusal/comic.mp4" type="video/mp4">
  <track kind="subtitles" srclang="en" label="English" src="/assets/videos/posts/만화/uncensored-leaderboard-one-refusal/comic.en.vtt" default>
</video>

[Download video](/assets/videos/posts/만화/uncensored-leaderboard-one-refusal/comic.mp4)

## What this means for ThakiCloud

Whether to run an uncensored build is the second question. The first is where it runs and whose logs remember what you asked. That is the part Metis owns: weights served inside your own cluster, prompt trail staying on your side of the wall. Paxis rides on top, running the agents but parking a human approval step in front of anything consequential, so the word no comes from your policy instead of the model's mood. Arguing about the filter matters less than holding the switch it hangs on.

---

*An auto-generated comic riffing on this week's industry news.*
