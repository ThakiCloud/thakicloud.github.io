---
title: "내 AI 스택이 다 중국산이 됐다"
excerpt: "스택이 통째로 남의 손에 넘어간 날, 파시스와 메티스의 대처법."
date: 2026-07-01
categories:
  - 만화
tags:
  - 만화
  - comic
  - 온프렘
  - sovereignty
  - AI
author_profile: true
toc: false
image: /assets/images/posts/만화/ai-stack-sovereignty/strip.png
---

어느 날 정신을 차려 보니 모델도, 추론 엔진도, 벡터 DB도 전부 남의 나라 회사 것이었습니다. 잘 돌아가긴 합니다. 문제는 스택의 어느 층도 제가 직접 통제하지 못한다는 점입니다. 약관이 바뀌거나 수출 규제가 걸리면 그날로 서비스가 멈출 수 있습니다. 여기서 '주권(sovereignty)'이란 모델과 데이터, 인프라를 남의 손이 아니라 내 통제 아래 두는 것을 뜻합니다. 파시스와 메티스가 이 상황을 어떻게 받아치는지 여섯 컷에 담았습니다.

![내 AI 스택이 다 중국산이 됐다](/assets/images/posts/만화/ai-stack-sovereignty/strip.png)

> 원 뉴스: [My entire AI stack is now Chinese](https://x.com/hjguyhan/status/2071779159391793563) · twitter

## ThakiCloud 제품 적용 시사점

웃자고 그린 만화지만 실제로 많은 팀이 겪는 일입니다. 편해서 올린 스택인데, 데이터와 통제권이 조용히 밖으로 나가 있는 것이죠. ThakiCloud는 이 지점을 정면으로 봅니다. 오픈 모델을 우리 GPU 클러스터에서 직접 훈련하고(Kubeflow), 직접 서빙하며(vLLM), 데이터는 방화벽 밖으로 나가지 않습니다. 온프렘(on-prem)은 이렇게 클라우드가 아니라 우리 시설 안에서 시스템을 돌리는 방식을 뜻합니다. 파시스로 에이전트를 만들고 메티스로 플랫폼을 운영하면, 스택의 모든 층이 내 손 안에 남습니다. 남의 약관에 내 서비스를 걸어 두고 싶지 않다면, 온프렘 주권형 AI가 그 답입니다.

---

*이 만화는 업계 뉴스를 바탕으로 자동 생성된 초안입니다.*
