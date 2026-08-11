---
title: "저노력 리뷰가 다 이겼다"
excerpt: "노력 눈금 최대로 땡겼더니, 청구서만 최대치더라"
date: 2026-07-17
categories:
  - 만화
tags:
  - ai-coding
  - code-review
  - on-prem
  - sovereign-ai
  - thakicloud
  - compute-cost
author_profile: true
toc: false
image: /assets/images/posts/만화/code-review-effort-levels-low-effort-wins/strip.png
audiobook: /assets/audio/posts/code-review-effort-levels-low-effort-wins/audiobook-ko.mp3
audiobook_note: "만화 캐릭터 목소리로 듣는 오디오북 (Qwen3-TTS 로컬)"
published: false
---

클로드 코드의 /code-review에 '노력 레벨'이 생겼습니다. 리뷰를 대충 볼지 빡세게 볼지를 눈금으로 고를 수 있고, 레벨을 바꿀 때마다 리뷰 자체가 처음부터 다시 쓰인다는 이야기입니다. 여기서 재미있는 대목은 가장 낮은 노력으로 돌린 리뷰조차 다른 코드 리뷰 도구들을 이겼다는 점입니다. 그런데 노력을 올린다는 건 결국 추론을 더 돌린다는 뜻이고, 남의 클라우드 위에서는 그 추론 한 번이 그대로 계량기 숫자로 찍힙니다. 파시스와 메티스가 눈금을 끝까지 밀어 올려 봤습니다.

![저노력 리뷰가 다 이겼다]({{ '/assets/images/posts/만화/code-review-effort-levels-low-effort-wins/strip.png' | relative_url }})

> 원 뉴스: [Claude Code's /code-review now has effort levels, with the review rewritten at every one.](https://x.com/hjguyhan/status/2077894748183097710) · twitter

## ThakiCloud 제품 적용 시사점

노력을 마음껏 올릴 수 있느냐는 결국 컴퓨트를 누가 쥐고 있느냐의 문제입니다. 남의 클라우드에서는 리뷰 노력을 한 칸 올릴 때마다 청구서가 따라 오르니, 정작 필요한 순간에 눈금을 아끼게 됩니다. 다키클라우드가 미는 온프렘은 모델과 GPU를 자기 시설 안에 두는 방식이라, 노력을 끝까지 밀어도 계량기가 돌지 않습니다. 파시스는 리뷰 에이전트를 여러 노력 레벨로 병렬로 풀어 결과를 교차 검증하고, 메티스는 그 추론을 자기 랙 위에서 돌립니다. 저노력이 이미 남들을 이긴다면, 고노력을 공짜로 돌릴 수 있는 쪽이 결국 더 멀리 갑니다.

---

*이 만화는 업계 뉴스를 바탕으로 자동 생성된 초안입니다.*

## 관련 슬라이드

본문 내용을 NotebookLM(`blue_collage` 스타일)으로 요약한 슬라이드입니다.

![code-review-effort-levels-low-effort-wins 슬라이드 1](/assets/images/code-review-effort-levels-low-effort-wins-slide-01.png)

![code-review-effort-levels-low-effort-wins 슬라이드 2](/assets/images/code-review-effort-levels-low-effort-wins-slide-02.png)

![code-review-effort-levels-low-effort-wins 슬라이드 3](/assets/images/code-review-effort-levels-low-effort-wins-slide-03.png)

![code-review-effort-levels-low-effort-wins 슬라이드 4](/assets/images/code-review-effort-levels-low-effort-wins-slide-04.png)

