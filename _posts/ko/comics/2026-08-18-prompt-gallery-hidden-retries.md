---
title: "프롬프트는 공개, 재시도 47번은 비공개"
excerpt: "남의 프롬프트를 통째로 볼 수 있게 됐는데, 정작 그 한 장이 나오기까지 말아먹은 횟수는 아무도 안 올려놨습니다."
date: 2026-08-18
categories:
  - comics
tags:
  - 프롬프트
  - 영상생성
  - 온프렘
  - GPU비용
  - AI실험
author_profile: true
toc: false
image: /assets/images/posts/만화/prompt-gallery-hidden-retries/strip.webp
video: /assets/videos/posts/만화/prompt-gallery-hidden-retries/comic.mp4
audiobook: /assets/audio/posts/prompt-gallery-hidden-retries/audiobook-ko.mp3
audiobook_note: "만화 캐릭터 목소리로 듣는 오디오북 (Qwen3-TTS 로컬)"
---

영상 생성 모델로 만든 결과물과 거기 쓰인 프롬프트를 나란히 모아 보여주는 갤러리가 화제입니다. 프롬프트는 모델에게 무엇을 어떻게 만들라고 적어 주는 지시문이고, 지금까지는 잘 만든 사람의 노하우라 잘 안 풀렸습니다. 그게 통째로 공개됐으니 복사해 붙여넣기만 하면 될 것 같지요. 그런데 같은 지시문을 넣어도 결과가 매번 갈립니다. 시드라고 부르는 난수값과 모델 버전이 조금만 달라져도 화면이 딴판으로 나오거든요. 그래서 갤러리에 걸린 한 장면은 대체로 여러 번 다시 돌린 끝에 살아남은 마지막 한 번이고, 그 앞의 실패는 아무도 업로드하지 않습니다.

![프롬프트는 공개, 재시도 47번은 비공개](/assets/images/posts/만화/prompt-gallery-hidden-retries/strip.webp)

> 원 뉴스: [RT @checheluna3: Seedance 2.5 쓰는 분들 이 사이트 혹시 알고 있나요? ](https://x.com/hjguyhan/status/2089321017521086865) · twitter

**▶ 만화 영상판, 캐릭터들이 직접 말합니다**

<video controls playsinline preload="metadata" poster="/assets/images/posts/만화/prompt-gallery-hidden-retries/strip.webp" style="width:100%;border-radius:8px;">
  <source src="/assets/videos/posts/만화/prompt-gallery-hidden-retries/comic.mp4" type="video/mp4">
  <track kind="subtitles" srclang="ko" label="한국어" src="/assets/videos/posts/만화/prompt-gallery-hidden-retries/comic.ko.vtt" default>
</video>

[영상 다운로드](/assets/videos/posts/만화/prompt-gallery-hidden-retries/comic.mp4)

## ThakiCloud 제품 적용 시사점

프롬프트가 공짜로 풀릴수록 값이 나가는 쪽은 재시도입니다. 마음에 드는 한 장면을 건지려면 스무 번, 서른 번을 다시 돌려야 하는데 그 횟수만큼 초 단위로 과금되는 구조라면 실험할수록 손해라는 이상한 계산이 나오죠. 저희가 온프렘을 고집하는 이유가 여기 있습니다. 온프렘은 모델과 GPU를 자기 시설 안에 두고 돌리는 방식이라, 스물세 번 말아먹어도 늘어나는 건 전기요금뿐입니다. 파시스는 프롬프트 하나를 여러 갈래로 변형해 한꺼번에 돌리고 결과를 코드로 채점해 살아남은 것만 남깁니다. 메티스는 그 반복을 사내 GPU 위에 얹어 재시도 비용을 변동비에서 고정비로 바꿔 놓고요. 지금 보고 계신 이 만화도 매일 그 파이프라인이 알아서 뽑아 놓는 것입니다.

---

*이 만화는 업계 뉴스를 바탕으로 자동 생성된 초안입니다.*

## 관련 슬라이드

본문 내용을 NotebookLM(`neo_constructivist` 스타일)으로 요약한 슬라이드입니다.

![prompt-gallery-hidden-retries 슬라이드 1](/assets/images/prompt-gallery-hidden-retries-slide-01.png)

![prompt-gallery-hidden-retries 슬라이드 2](/assets/images/prompt-gallery-hidden-retries-slide-02.png)

![prompt-gallery-hidden-retries 슬라이드 3](/assets/images/prompt-gallery-hidden-retries-slide-03.png)

![prompt-gallery-hidden-retries 슬라이드 4](/assets/images/prompt-gallery-hidden-retries-slide-04.png)

