---
title: "Thaki Cloud Life & 커리어 가이드"
excerpt: "Thaki Cloud의 기업 문화, 복지, 개발자들의 이야기, 채용 정보 등을 공유합니다."
date: 2025-05-21
last_modified_at: 2026-06-20
categories:
  - careers
tags:
  - Company Culture
  - Careers
  - Recruitment
  - Developer Story
  - Team
author_profile: true
published: false
---

## Thaki Cloud에서 일한다는 것

ThakiCloud는 GPU부터 SaaS까지 수직 통합된 AI 인프라 플랫폼을 만드는 곳입니다. Kubernetes-Native 환경 위에서 xPU as a Service를 운영하고, LLM Ops와 Agentic AI 서비스를 실제 고객 트래픽과 함께 개발합니다. 실험실 수준이 아닙니다. 지금 이 순간 실제로 돌아가는 클러스터 위에서 일합니다.

그게 여기서 일하는 이유입니다.

---

## AI 엔지니어 A님의 이야기

작년 초 A님은 LLM 서비스를 개발하던 중 한 가지 문제에 걸렸습니다. 모델은 준비됐는데, 실제 트래픽 규모에서 추론 지연이 기대를 벗어났습니다. GPU 스케줄링 문제였는데, 당시 소속팀에서는 이 수준의 인프라 문제를 직접 다룰 수 없었습니다.

ThakiCloud로 온 건 그 경험 때문이었습니다. 인프라부터 모델 서빙까지 직접 통제할 수 있는 환경이 필요했습니다.

"여기서는 GPU 스케줄러 설정을 직접 손댈 수 있어요. 커스텀 CUDA 커널을 짜서 추론 파이프라인에 넣어보기도 했고요. 그 실험이 실패하더라도 로그가 남고, 팀 지식이 됩니다. 실패도 자산이 되는 분위기가 있어야 실험을 두려워하지 않게 되더라고요."

지금 A님이 담당하는 건 멀티 테넌트 LLM 서빙 파이프라인입니다. 국내 NPU와 NVIDIA GPU를 혼합 배치하는 클러스터에서, 테넌트별 격리와 SLO를 동시에 잡는 게 지금 목표입니다. 쉽지 않지만, 그래서 재밌다고 합니다.

---

## 일하는 방식

스타트업이지만 코드 리뷰는 꼼꼼합니다. PR을 올리면 기술적인 이유가 붙은 피드백이 옵니다. "이렇게 하세요"보다 "이렇게 하면 이런 문제가 생깁니다"가 기본 톤입니다.

의사결정은 데이터와 근거를 가지고 토론합니다. 시니어가 말했다고 넘어가는 구조가 아닙니다. 신입도 근거가 있으면 반론할 수 있고, 실제로 그 반론이 의사결정에 반영됩니다.

오픈소스 기여는 권장하고, 컨퍼런스 발표는 지원합니다. KCD Seoul 2025에서 발표한 내용도 팀 전체의 작업을 기반으로 했습니다.

---

## 지금 함께할 포지션

| 팀 | 지금 풀고 있는 문제 |
|---|---|
| MLOps Platform | Feature Store 재설계, 스키마 검증 자동화 |
| LLMOps R&D | 로그 자동 분석, Self-Healing 서빙 |
| Cloud Infra | GPU/NPU 혼합 스케줄링, 멀티 리전 HA |
| Data Engineering | 실시간 CDC + Iceberg Lakehouse 구축 |

이력서, 포트폴리오, GitHub 링크를 **info@thakicloud.co.kr** 로 보내주세요. 형식은 자유입니다.
