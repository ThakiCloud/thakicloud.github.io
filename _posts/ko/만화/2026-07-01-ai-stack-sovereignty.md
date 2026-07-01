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

어느 날 보니 모델도 추론 엔진도 벡터 DB도 전부 남의 나라 회사 것이었다. 잘 돌아가긴 한다. 문제는 스택의 어느 층도 내가 못 건드린다는 거다. 약관이 바뀌거나 수출 규제가 걸리면 그날로 끝이다. 파시스와 메티스가 이 상황을 어떻게 받아치는지 여섯 컷에 담았다.

![내 AI 스택이 다 중국산이 됐다](/assets/images/posts/만화/ai-stack-sovereignty/strip.png)

> 원 뉴스: [My entire AI stack is now Chinese](https://x.com/hjguyhan/status/2071779159391793563) · twitter

## ThakiCloud 제품 적용 시사점

웃자고 그린 만화지만 실제로 흔한 일이다. 편해서 올린 스택인데 데이터와 통제권이 조용히 밖으로 나가 있다. ThakiCloud는 이 지점을 정면으로 본다. 오픈 모델을 우리 GPU 클러스터에서 직접 훈련하고(Kubeflow), 직접 서빙하고(vLLM), 데이터는 방화벽 밖으로 안 나간다. 파시스로 에이전트를 만들고 메티스로 플랫폼을 돌리면 스택의 모든 층이 내 손에 남는다. 남의 약관에 내 서비스를 걸어두기 싫다면, 온프렘 주권형 AI가 그 답이다.

---

*이 만화는 업계 뉴스를 바탕으로 자동 생성된 초안입니다.*
