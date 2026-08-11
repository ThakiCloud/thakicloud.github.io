---
title: "한 바퀴 돌렸더니 청구서도 한 바퀴"
excerpt: "앞·옆·뒤 다 뽑는 조종석, 근데 프레임마다 미터가 돈다"
date: 2026-07-24
categories:
  - 만화
tags:
  - codex
  - image-generation
  - inference-cost
  - on-prem
  - animation
  - sovereignty
author_profile: true
toc: false
image: /assets/images/posts/만화/codex-image-cockpit-spin-the-bill/strip.png
video: /assets/videos/posts/만화/codex-image-cockpit-spin-the-bill/comic.ko.mp4
audiobook: /assets/audio/posts/codex-image-cockpit-spin-the-bill/audiobook-ko.mp3
audiobook_note: "만화 캐릭터 목소리로 듣는 오디오북 (Qwen3-TTS 로컬)"
published: false
---

코덱스 워크플로에 붙는 이미지 조종석 하나가 공개됐습니다. 캐릭터를 앞, 비스듬앞, 옆, 비스듬뒤, 뒤 이렇게 다섯 방향으로 돌려가며 애니메이션으로 뽑아 주고, 이번 버전은 16프레임과 20프레임까지 실험적으로 늘렸습니다. 손은 편해집니다. 문제는 프레임 하나가 결국 이미지 추론 한 번, 그러니까 돈 나가는 호출 한 번이라는 점입니다. 방향을 늘리고 프레임을 늘릴수록 그림은 부드러워지지만 미터도 같이 돌아갑니다. 게다가 이 조종석은 남의 코딩 엔진 위에서만 날아요.

![한 바퀴 돌렸더니 청구서도 한 바퀴](/assets/images/posts/만화/codex-image-cockpit-spin-the-bill/strip.png)

> 원 뉴스: [RT @dreiachse: Image Cockpit for Codex Workflows v0.1.7 を公開しました！](https://x.com/hjguyhan/status/2080249200890237270) · twitter

**▶ 만화 영상판, 캐릭터들이 직접 말합니다 (한국어 자막 포함)**

<video controls playsinline preload="metadata" poster="/assets/images/posts/만화/codex-image-cockpit-spin-the-bill/strip.png" style="width:100%;border-radius:8px;">
  <source src="/assets/videos/posts/만화/codex-image-cockpit-spin-the-bill/comic.ko.mp4" type="video/mp4">
</video>

## ThakiCloud 제품 적용 시사점

재미난 조종석의 진짜 비용은 '프레임당 추론'이라는 말 속에 숨어 있습니다. 방향 다섯 개에 20프레임이면 캐릭터 한 번 돌리는 데 백 번 넘는 호출이고, 그게 전부 남의 클라우드 미터에 찍힙니다. ThakiCloud는 이 계산을 자기 시설 안으로 들여옵니다. 온프렘이란 이렇게 모델을 내 랙 안에서 돌리는 방식이죠. 메티스가 이미지와 애니메이션 모델을 온프렘에서 서빙하고, 파시스가 방향과 프레임을 나눠 맡을 에이전트로 쪼개 돌리면, 프레임을 아무리 늘려도 도는 건 미터가 아니라 내 GPU입니다. 조종석은 실컷 즐기세요. 엔진만 내 랙에 꽂아 두면 됩니다.

---

*이 만화는 업계 뉴스를 바탕으로 자동 생성된 초안입니다.*
