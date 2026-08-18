---
title: "책 통째로 줬더니 읽은 척함"
excerpt: "300쪽을 통째로 던졌더니 안 읽은 데까지 아는 척하더라고요. 한 장씩 읽혔더니 이번엔 노트가 책보다 두꺼워졌습니다."
date: 2026-08-13
categories:
  - 만화
tags:
  - context-window
  - document-ai
  - agents
  - on-prem
  - cost
author_profile: true
toc: false
image: /assets/images/posts/만화/it-never-read-the-book/strip.webp
video: /assets/videos/posts/만화/it-never-read-the-book/comic.mp4
audiobook: /assets/audio/posts/it-never-read-the-book/audiobook-ko.mp3
audiobook_note: "만화 캐릭터 목소리로 듣는 오디오북 (Qwen3-TTS 로컬)"
---

두꺼운 문서를 통째로 넣고 요약을 시키면 결과가 이상하게 뭉뚱그려져 나옵니다. 모델이 한 번에 받아들일 수 있는 분량, 그러니까 컨텍스트 창이 정해져 있어서 거기 안 들어간 페이지는 눈에 닿지도 않거든요. 그런데도 모델은 그 부분까지 읽은 것처럼 태연하게 정리합니다. 요즘 화제가 된 방식은 반대로 갑니다. 한 장씩만 읽히고 그때마다 메모를 남겨 지식베이스를 쌓아 올리는 거죠. 확실히 정확해지는데, 300쪽이면 읽기도 300번입니다. 그 300번이 어디서 돌아가느냐가 다음 문제고요.

![책 통째로 줬더니 읽은 척함](/assets/images/posts/만화/it-never-read-the-book/strip.webp)

> 원 뉴스: [RT @Ryrenz: 📖 让 AI 逐页读完一本 PDF，边读边攒知识库](https://x.com/hjguyhan/status/2087297036848902232) · twitter

**▶ 만화 영상판, 캐릭터들이 직접 말합니다**

<video controls playsinline preload="metadata" poster="/assets/images/posts/만화/it-never-read-the-book/strip.webp" style="width:100%;border-radius:8px;">
  <source src="/assets/videos/posts/만화/it-never-read-the-book/comic.mp4" type="video/mp4">
  <track kind="subtitles" srclang="ko" label="한국어" src="/assets/videos/posts/만화/it-never-read-the-book/comic.ko.vtt" default>
</video>

[영상 다운로드](/assets/videos/posts/만화/it-never-read-the-book/comic.mp4)

## ThakiCloud 제품 적용 시사점

한 장씩 읽는 방식은 결국 에이전트를 수백 번 돌리는 일입니다. 파시스는 이런 반복을 페이지 단위로 쪼개 굴리도록 만들어져 있고, 메티스는 그 수백 번의 호출이 회사 안 GPU에서 끝나게 합니다. 온프렘, 그러니까 우리 시설 안에서 모델을 돌리는 방식이면 300번이든 3000번이든 늘어나는 건 전기요금 쪽이지 청구서 쪽이 아니죠. 사내 규정집이나 계약서처럼 밖으로 한 장도 내보내면 곤란한 문서일수록 이 차이가 커집니다. 읽는 쪽을 문서 옆으로 데려오는 게 문서를 남의 서버로 보내는 것보다 대체로 쌉니다.

---

*이 만화는 업계 뉴스를 바탕으로 자동 생성된 초안입니다.*
