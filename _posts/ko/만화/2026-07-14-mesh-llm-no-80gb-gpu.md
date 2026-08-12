---
title: "80기가 GPU 없이 괴물 굴리기"
excerpt: "괴물 한 대를 못 사서, 갖고 있는 잡동사니를 다 엮어버림"
date: 2026-07-14
categories:
  - 만화
tags:
  - mesh-llm
  - distributed-inference
  - on-prem
  - gpu
  - sovereignty
  - thakicloud
author_profile: true
toc: false
image: /assets/images/posts/만화/mesh-llm-no-80gb-gpu/strip.webp
audiobook: /assets/audio/posts/mesh-llm-no-80gb-gpu/audiobook-ko.mp3
audiobook_note: "만화 캐릭터 목소리로 듣는 오디오북 (Qwen3-TTS 로컬)"
---

70B이 넘는 대형 모델을 돌리려면 보통 80GB짜리 값비싼 GPU 한 장이 있어야 한다고들 합니다. Mesh LLM은 그 전제를 뒤집습니다. 추론을 잘게 쪼갠 뒤, 이미 손에 있는 기기 여러 대에 나눠 얹는 방식이죠. 괴물 한 대를 사는 대신, 갖고 있는 것들을 엮어 괴물처럼 굴리는 셈입니다. 파시스와 메티스가 이 아이디어를 다키클라우드식으로 비틀어 봤습니다.

![80기가 GPU 없이 괴물 굴리기]({{ '/assets/images/posts/만화/mesh-llm-no-80gb-gpu/strip.webp' | relative_url }})

> 원 뉴스: [RT @DataChaz: Want to run a 70B+ model but don't have an 80GB GPU? Mesh LLM distributes inference across the devices you actually have.](https://x.com/hjguyhan/status/2076693609827754131) · twitter

## ThakiCloud 제품 적용 시사점

메티스는 남의 초대형 GPU를 월세로 빌리는 대신, 이미 가진 자원 위에서 학습과 추론을 돌리도록 설계된 플랫폼입니다. Mesh LLM이 보여준 '작은 것들을 엮어 큰 걸 돌린다'는 방향이 여기에 그대로 닿습니다. 파시스는 이 분산 작업을 에이전트로 쪼개 오케스트레이션하고, 온프렘 환경에서는 데이터도 모델도 바깥으로 새지 않습니다. GPU 청구서가 바닥까지 펼쳐지기 전에, 갖고 있는 것부터 엮어 보자는 이야기입니다.

---

*이 만화는 업계 뉴스를 바탕으로 자동 생성된 초안입니다.*

## 관련 슬라이드

본문 내용을 NotebookLM(`prismatic_tech` 스타일)으로 요약한 슬라이드입니다.

![mesh-llm-no-80gb-gpu 슬라이드 1](/assets/images/mesh-llm-no-80gb-gpu-slide-01.webp)

![mesh-llm-no-80gb-gpu 슬라이드 2](/assets/images/mesh-llm-no-80gb-gpu-slide-02.webp)

![mesh-llm-no-80gb-gpu 슬라이드 3](/assets/images/mesh-llm-no-80gb-gpu-slide-03.webp)

![mesh-llm-no-80gb-gpu 슬라이드 4](/assets/images/mesh-llm-no-80gb-gpu-slide-04.webp)

