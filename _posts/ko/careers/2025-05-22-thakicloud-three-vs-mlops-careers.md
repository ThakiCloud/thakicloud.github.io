---
title: "Three Vs-Driven MLOps at ThakiCloud: Why You'll Want to Join Us"
excerpt: "ThakiCloud의 Three Vs(속도, 검증, 버전관리) 기반 MLOps 문화와 실전 사례, 그리고 함께할 동료를 찾는 채용 안내를 담았습니다."
date: 2025-05-22
last_modified_at: 2026-06-20
categories:
  - careers
tags:
  - MLOps
  - ThreeVs
  - Cloud
  - Recruitment
  - Thaki Cloud
author_profile: true
---

Velocity, Validation, Versioning. 이 세 단어가 심박수를 올린다면, ThakiCloud가 맞는 자리일 수 있습니다.

GPU/NPU 인프라부터 SaaS까지 수직 통합된 환경에서 실전 트래픽과 함께 풀스택 MLOps를 경험할 수 있습니다. 실험실 수준이 아니라, 실제 서비스가 돌아가는 클러스터 위에서요.

---

## ThakiCloud MLOps, 구체적으로 어떻게 다른가

### 1. Velocity: 아이디어가 프로덕션이 되기까지, 커피가 식기 전에

IaaS-PaaS-SaaS를 수직 통합했기 때문에 가능한 일이 있습니다. Kubernetes NodePool에 GPU와 NPU를 혼합 배치했고, 실험에서 서빙으로 전환할 때 재스케줄링 비용이 거의 없습니다.

브랜치를 푸시하면 Helm Chart가 staging 클러스터에 즉시 배포됩니다. Feature Store 기반 실험 UI에서는 데이터와 피처 버전을 조합해 15분 안에 새 실험을 띄울 수 있습니다.

### 2. Validation: 실패는 빠르게, 지표는 제품 언어로

실시간 트래픽의 10%를 복사해 사용자 노출 없이 새 모델을 평가합니다. Shadow Traffic 퍼널입니다. 동시에 Prometheus와 Grafana 대시보드에서 비즈니스 KPI와 ML 지표를 같은 화면에 올려놓고 봅니다.

confidence 임계값 미만의 예측은 자동으로 필터링해서 사용자 경험을 보호하는 Safety Layer도 운영합니다.

### 3. Versioning: 도커 태그 한 줄로 시간 여행

모델, 피처, 메타데이터를 OCI 이미지 태그로 관리합니다. SHA만 지정하면 즉시 롤백됩니다. 데이터 drift가 감지되면 Airflow DAG가 재훈련, 검증, 프로모션을 자동으로 처리합니다. SLO 위반이 생기면 라이트 모델이 1초 내로 투입됩니다.

---

## 우리가 해결했거나 해결 중인 것들

| 문제 | 현재 상태 | 다음 목표 |
| --- | --- | --- |
| Dev와 Prod 불일치 | 단일 Helm Release로 통합 | 멀티 리전 배포 표준화 |
| 알람 폭주 | Alert 튜너봇으로 노이즈 감소 | 로그 레벨 root-cause 자동 분석 |
| Long-tail 버그 | Feature Slicing 디버거로 재현 | 데이터 합성 기반 완전 재현 자동화 |
| 느린 배포 | Canary + Progressive Delivery로 30일에서 5일로 단축 | 모델, 옵스, 비즈팀 OKR 연동 강화 |

---

## 실제 팀원 이야기

MLOps Platform 팀의 B님은 이렇게 말합니다.

"새벽 3시에 실험 모델이 터졌는데 5분 만에 롤백했어요. 실패도 자산이 되는 문화 덕분에, 실험 자체가 두렵지 않습니다. 폐기한 실험 로그도 팀 지식으로 남기고, 오픈소스에 올린 PR이 실전 트래픽을 만나는 경험은 ThakiCloud에서만 했어요."

Cloud Infra 팀의 C님은 다른 각도에서 봅니다.

"사우디 사막에서 GPU가 돌아가는 장면을 보고, 이게 진짜 글로벌 스케일이구나 싶었어요. 직접 설계하고 운영하는 경험, 동료들과 기술적인 결정을 함께 내리는 과정이 매일 성장의 원동력입니다."

---

## 모집 포지션

| 팀 | 지금 풀고 있는 문제 |
| --- | --- |
| MLOps Platform | Feature Store 재설계, Pydantic 스키마 검증 자동화 |
| LLMOps R&D | 로그 자동 분석, Self-Healing 서빙 |
| Cloud Infra | GPU/NPU 혼합 스케줄링, 멀티 리전 HA |
| Data Engineering | 실시간 CDC + Iceberg Lakehouse 구축 |

---

## 지원하는 법

1. **GitHub 또는 기술 블로그 링크**: 커밋이 곧 자기소개서입니다.
2. **프로젝트 파일**: Jupyter Notebook, Dockerfile, Helm 차트 모두 환영합니다.
3. **Three Vs 경험 한 줄**: "새벽 3시 모델 터졌는데 5분 만에 롤백"처럼요.

---

Velocity, Validation, Versioning. 이 세 단어에 심박수가 올라간다면, `git push origin thakicloud` 에서 만납시다.
