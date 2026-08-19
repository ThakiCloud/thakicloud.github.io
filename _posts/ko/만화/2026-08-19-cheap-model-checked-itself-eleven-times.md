---
title: "싼 놈이 열한 번 세서 이겼다"
excerpt: "머리 좋은 놈 한 방보다 싼 놈 열한 번이 이겼습니다. 문제는 그 열한 번이 전부 남의 미터기 위에서 돌았다는 거죠."
date: 2026-08-19
categories:
  - 만화
tags:
  - self-verification
  - inference-cost
  - on-prem
  - agent-loop
  - benchmark
author_profile: true
toc: false
image: /assets/images/posts/만화/cheap-model-checked-itself-eleven-times/strip.webp
video: /assets/videos/posts/만화/cheap-model-checked-itself-eleven-times/comic.mp4
audiobook: /assets/audio/posts/cheap-model-checked-itself-eleven-times/audiobook-ko.mp3
audiobook_note: "만화 캐릭터 목소리로 듣는 오디오북 (Qwen3-TTS 로컬)"
---

값싼 모델 하나가 터미널 작업 벤치마크에서 훨씬 비싼 모델을 앞질렀습니다. 비결은 더 똑똑해진 게 아니라 자기 검증을 늘린 것이었습니다. 한 번 답하고 끝내는 대신, 같은 문제를 여러 번 풀어 서로 대조하고 스스로 채점해서 살아남은 답만 내놓는 방식이죠. 실행 비용이 11분의 1이니 같은 예산으로 열 번 넘게 더 굴릴 수 있고, 그 횟수가 곧 정확도가 됐습니다. 그래서 질문은 '어느 모델이 똑똑한가'에서 '검산 한 번에 얼마가 찍히는가'로 옮겨갑니다.

![싼 놈이 열한 번 세서 이겼다](/assets/images/posts/만화/cheap-model-checked-itself-eleven-times/strip.webp)

> 원 뉴스: [RT @jackyk02: Scaling self-verification with DeepSeek V4 Flash beats Claude Fable 5 on Terminal-Bench 2.1, while being 1](https://x.com/hjguyhan/status/2089676955188892058) · twitter

**▶ 만화 영상판 — 캐릭터들이 직접 말합니다**

<video controls playsinline preload="metadata" poster="/assets/images/posts/만화/cheap-model-checked-itself-eleven-times/strip.webp" style="width:100%;border-radius:8px;">
  <source src="/assets/videos/posts/만화/cheap-model-checked-itself-eleven-times/comic.mp4" type="video/mp4">
  <track kind="subtitles" srclang="ko" label="한국어" src="/assets/videos/posts/만화/cheap-model-checked-itself-eleven-times/comic.ko.vtt" default>
</video>

[영상 다운로드](/assets/videos/posts/만화/cheap-model-checked-itself-eleven-times/comic.mp4)

## ThakiCloud 제품 적용 시사점

이 결과가 좋은 이유는 단순합니다. 검증을 늘리는 전략은 검증이 쌀 때만 성립하거든요. 호출당 요금이 붙는 구조에서는 열한 번 검산이 곧 열한 배 청구서라, 정확도를 사는 순간 원가가 따라옵니다. 파시스가 에이전트를 여러 갈래로 풀고 결과를 서로 반박시켜 살아남은 것만 채택하는 이유도 같습니다. 다만 그 반복이 우리 GPU 위에서 돌 때에야 횟수를 늘리는 선택이 자유로워집니다. 메티스가 모델 서빙 원가를 눌러 두는 일과 온프렘으로 인프라를 우리 통제 아래 두는 일이 여기서 만납니다. 똑똑한 모델을 빌리는 대신, 싼 모델을 마음껏 여러 번 굴릴 수 있는 마당을 갖는 쪽이 결국 남습니다.

---

*이 만화는 업계 뉴스를 바탕으로 자동 생성된 초안입니다.*
