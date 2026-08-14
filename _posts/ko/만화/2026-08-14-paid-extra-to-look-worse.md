---
title: "화질 깎는 데 5천 원"
excerpt: "30초짜리 480p 영상 한 편에 4달러 12센트, 그중 상당수가 화면을 일부러 거칠게 만드는 값이었습니다."
date: 2026-08-14
categories:
  - 만화
tags:
  - ai-video
  - generation-cost
  - gpu
  - on-prem
  - metis
author_profile: true
toc: false
image: /assets/images/posts/만화/paid-extra-to-look-worse/strip.webp
video: /assets/videos/posts/만화/paid-extra-to-look-worse/comic.mp4
audiobook: /assets/audio/posts/paid-extra-to-look-worse/audiobook-ko.mp3
audiobook_note: "만화 캐릭터 목소리로 듣는 오디오북 (Qwen3-TTS 로컬)"
---

글로 지시하면 영상이 나오는 텍스트투비디오 모델로 만든 30초짜리 헬스장 브이로그가 타임라인을 돌았습니다. 해상도는 480p, 화면은 90년대 테이프 캠코더처럼 거칠고 손으로 든 것처럼 흔들립니다. 프롬프트에 카메라 항목까지 적혀 있어서 누구나 따라 만들 수 있고요.
재미있는 건 가격입니다. 그 30초에 4달러 12센트가 붙었습니다. 1분이면 8달러가 넘고, 마음에 안 들어 다시 뽑을 때마다 같은 금액이 또 나갑니다. 해상도를 낮춘다고 계산량이 알아서 줄지도 않으니, 거친 질감은 절약이 아니라 취향에 가깝습니다. 프롬프트는 공짜로 공유되는데 렌더링 청구서는 각자 부담이라는 게 이 장르의 진짜 규칙이더군요.

![화질 깎는 데 5천 원](/assets/images/posts/만화/paid-extra-to-look-worse/strip.webp)

> 원 뉴스: [RT @EvoLinkAi: Seedance 2.5 Korean Girl gym Vlog](https://x.com/hjguyhan/status/2087843518584951236) · twitter

**▶ 만화 영상판, 캐릭터들이 직접 말합니다**

<video controls playsinline preload="metadata" poster="/assets/images/posts/만화/paid-extra-to-look-worse/strip.webp" style="width:100%;border-radius:8px;">
  <source src="/assets/videos/posts/만화/paid-extra-to-look-worse/comic.mp4" type="video/mp4">
  <track kind="subtitles" srclang="ko" label="한국어" src="/assets/videos/posts/만화/paid-extra-to-look-worse/comic.ko.vtt" default>
</video>

[영상 다운로드](/assets/videos/posts/만화/paid-extra-to-look-worse/comic.mp4)

## ThakiCloud 제품 적용 시사점

영상 생성은 결국 GPU 추론입니다. 프레임 하나가 곧 연산이고, 그 연산을 누구 카드에서 돌리느냐가 단가를 정합니다. 남의 API에 얹으면 프레임이 그대로 청구서가 되지만, Metis에서 우리 카드로 서빙하면 같은 프레임이 전기와 감가상각으로 바뀝니다. 컷을 스무 번 다시 뽑아도 겁나지 않는 이유가 여기 있어요.
그 카드를 실제로 대는 층이 Telox와 Velox입니다. 실험은 남는 GPU로 돌리고 정기 렌더는 전용 자원에 붙이는 식으로 나누면, 창작 실험의 비용 곡선이 사용량이 아니라 보유량을 따라갑니다. 프롬프트 설계와 렌더, 실패 재시도, 자막 붙이기까지 묶어 자동으로 굴리는 건 Paxis 몫이고요. 이 만화와 영상도 그 파이프라인에서 나옵니다. 감성은 취향껏 거칠게 가되, 미터기까지 남의 것일 필요는 없습니다.

---

*이 만화는 업계 뉴스를 바탕으로 자동 생성된 초안입니다.*

## 관련 슬라이드

본문 내용을 NotebookLM(`neo_constructivist` 스타일)으로 요약한 슬라이드입니다.

![paid-extra-to-look-worse 슬라이드 1](/assets/images/paid-extra-to-look-worse-slide-01.webp)

![paid-extra-to-look-worse 슬라이드 2](/assets/images/paid-extra-to-look-worse-slide-02.webp)

![paid-extra-to-look-worse 슬라이드 3](/assets/images/paid-extra-to-look-worse-slide-03.webp)

![paid-extra-to-look-worse 슬라이드 4](/assets/images/paid-extra-to-look-worse-slide-04.webp)

