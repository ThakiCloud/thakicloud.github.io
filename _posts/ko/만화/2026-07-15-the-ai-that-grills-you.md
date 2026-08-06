---
title: "AI한테 취조당하는 면접"
excerpt: "후보를 갈구던 AI, 자기부터 갈궈봤더니"
date: 2026-07-15
categories:
  - 만화
tags:
  - grill-me
  - AI-interview
  - adversarial-verify
  - agents
  - paxis
  - metis
author_profile: true
toc: false
image: /assets/images/posts/만화/the-ai-that-grills-you/strip.png
audiobook: /assets/audio/posts/the-ai-that-grills-you/audiobook-ko.mp3
audiobook_note: "만화 캐릭터 목소리로 듣는 오디오북 (Qwen3-TTS 로컬)"
---

이번 화제는 '/grill-me'입니다. 답을 대신 써주는 도구가 아니라, 꼬리에 꼬리를 무는 되물음으로 상대가 정말 이해했는지 캐묻는 스킬이에요. 아는 척은 두세 번만 '왜요?'를 던지면 밑천이 드러납니다. 그런데 이걸 기술 면접에 가져다 쓰는 사람이 생겼습니다. 정답을 맞혔는지가 아니라 압박 속에서 후보가 어떻게 생각을 풀어가는지를 옆에서 구경하는 거죠. 파시스와 메티스가 이 취조기를 손에 넣었고, 결국 서로에게 겨눕니다.

![AI한테 취조당하는 면접]({{ '/assets/images/posts/만화/the-ai-that-grills-you/strip.png' | relative_url }})

> 원 뉴스: [RT @mattpocockuk: Someone DM'd me saying they're using /grill-me in technical interviews](https://x.com/hjguyhan/status/2077017688761938198) · twitter

## ThakiCloud 제품 적용 시사점

만화는 웃기려고 서로 갈구지만, 사실 이건 ThakiCloud가 매일 하는 일입니다. 파시스가 만든 에이전트 결과물을 곧장 내보내지 않고, 다른 에이전트가 '이 주장 근거가 뭐냐'며 반증을 시도하게 합니다. 통과한 것만 배포하고요. 메티스도 추론 결과를 스스로 채점하는 대신 검증 게이트에 통과시킵니다. 취조기를 남한테만 겨누면 자기 헛소리는 못 걸러냅니다. 그래서 우리 파이프라인은 배포 전에 자기들끼리 먼저 갈굽니다. 이 만화가 올라온 과정도 그 루프를 한 바퀴 돈 결과입니다.

---

*이 만화는 업계 뉴스를 바탕으로 자동 생성된 초안입니다.*

## 관련 슬라이드

본문 내용을 NotebookLM(`architectural_mono` 스타일)으로 요약한 슬라이드입니다.

![the-ai-that-grills-you 슬라이드 1](/assets/images/the-ai-that-grills-you-slide-01.png)

![the-ai-that-grills-you 슬라이드 2](/assets/images/the-ai-that-grills-you-slide-02.png)

![the-ai-that-grills-you 슬라이드 3](/assets/images/the-ai-that-grills-you-slide-03.png)

![the-ai-that-grills-you 슬라이드 4](/assets/images/the-ai-that-grills-you-slide-04.png)

