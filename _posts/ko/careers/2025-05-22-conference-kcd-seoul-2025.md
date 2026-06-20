---
title: "[Thaki Cloud Life & 커리어] KCD Seoul 2025"
excerpt: "KCD Seoul 2025에서 발표한 자료를 공유합니다. xPU as a Service 기반 Agentic AI 플랫폼Thaki Cloud에 대한 내용입니다"
date: 2025-05-22
last_modified_at: 2026-06-20
categories:
  - careers
tags:
  - Thaki Cloud
  - Introduction
  - Company Culture
  - Careers
  - Recruitment
  - Developer Story
  - Team
author_profile: true
---

## ThakiCloud @ KCD Seoul 2025

**일시**: 2025년 5월 22일 (목)

**관련 링크**

- 공식 홈페이지: [KCD Seoul 2025](https://community.cncf.io/events/details/cncf-kcd-south-korea-presents-kcd-seoul-2025/)
- LinkedIn 게시물: [ThakiCloud - KCD Seoul 2025](https://www.linkedin.com/posts/thakicloud_kcdseoul2025-thakicloud-xpuasaservice-activity-7330146553937960961-yBcG?utm_source=share&utm_medium=member_desktop&rcm=ACoAAAAuzrMB15I-NYSyIEDIpkgrPxOMdfaqjcM)
- 발표 자료: [슬라이드 보기](https://ihryedku.gensparkspace.com/)

---

## 발표 스크립트

### ThakiCloud 소개 및 xPU 기반 Agentic AI 인프라 플랫폼

---

### 인트로

안녕하세요. ThakiCloud에서 왔습니다.

오늘은 AI 시대의 인프라 패러다임을 바꾸는 Kubernetes-Native Agentic AI 플랫폼, 그리고 저희가 제안하는 xPU 기반 AI 인프라에 대해 말씀드리겠습니다.

---

### 회사 소개와 미션

ThakiCloud는 퍼블릭 클라우드 수준의 유연성과 확장성을 프라이빗 및 하이브리드 환경에서도 실현하는 AI 인프라 플랫폼 기업입니다.

**미션**: 모든 기업이 AI First로 전환할 수 있도록 지원합니다.

핵심 기술 영역은 세 가지입니다. LLM 및 Agentic AI 인프라스트럭처, 이기종 가속기 통합 관리(xPU 관리), Kubernetes-Native 기반의 xPU 서비스화입니다.

---

### 왜 xPUaaS와 Agentic AI인가?

지금 시장에는 몇 가지 공통된 문제가 있습니다.

GPU 중심의 TCO가 빠르게 올라가고 있고, 공급망은 불안정합니다. 워크로드마다 하드웨어를 따로 최적화하기 어렵고, Agentic AI 특유의 복잡한 오케스트레이션 문제도 있습니다. 여기에 데이터 주권 이슈까지 더해집니다.

ThakiCloud의 답은 이렇습니다.

- **xPUaaS**: 다양한 가속기를 서비스로 제공합니다.
- **Turnkey Agentic AI PaaS**: 개발자 경험 중심의 플랫폼입니다.
- **Sovereign Cloud**: 데이터 규제를 직접 대응합니다.

---

### AI 워크로드 최적화 흐름

저희 플랫폼은 AI 워크로드 유형에 따라 가장 적합한 xPU를 자동 할당합니다.

대규모 학습에는 NVIDIA GPU Cluster를, 실시간 추론에는 고성능 GPU 또는 국내 NPU를, 배치 추론에는 비용 최적화된 혼합 구조를 씁니다. 이 파이프라인은 지속적인 모니터링과 피드백을 통해 자동으로 조정됩니다.

---

### Cloud-Native AI 인프라 구성

xPUaaS는 Kubernetes 확장 아키텍처를 기반으로 설계했습니다.

- 다양한 디바이스 플러그인
- 통합 추론 런타임
- xPU SDK Wrapper를 통한 직관적인 API
- Prometheus, Grafana, Loki 기반 모니터링 환경

SDK, 웹, 모바일 등 다양한 클라이언트는 API Gateway를 통해 접근합니다.

#### 전체 구성 흐름

**클라이언트 계층**: 웹, 모바일, SDK 클라이언트가 xPUaaS API Gateway를 통해 서비스에 접근합니다.

**핵심 서비스 계층**

- Inference Service: 실시간 추론 처리
- Model Management: 모델 등록, 버전 관리
- xPU Resource Pools: 가속기 풀 구성
- Autoscaling: 수요에 따른 자동 스케일 조정

**Kubernetes 오케스트레이션 계층**

- Device Plugins: NVIDIA, Rebellions, Furiosa 등 벤더별 가속기 등록
- Custom Scheduler: 최적화된 자원 배치
- Inference Runtime / SDK Wrapper: 백엔드 통합
- Resource Isolation / Observability: 격리와 모니터링

**하드웨어 계층**

NVIDIA GPU, FuriosaAI NPU, Rebellions NPU 등과 실시간 연동합니다. 드라이버, 전력, 헬스 체크, 펌웨어 업데이트까지 관리합니다.

핵심 정리: 단일 API 게이트웨이, Kubernetes 기반 자동화 인프라, 유연한 xPU 연결성, 강력한 모니터링 체계입니다.

---

### 유연한 클라우드 운영 전략

GitOps + Helm 기반 선언적 배포를 씁니다. 온프레미스, AWS EKS, GCP GKE, Azure AKS 등 멀티 클라우드를 지원하고, ACA, Cloud Run과의 서버리스 연동도 가능합니다. 퍼블릭 클라우드 수준의 자동화와 스케일링을 프라이빗 환경에서도 실현합니다.

---

### 함께할 이유

ThakiCloud는 AI 인프라 분야에서 실제로 문제를 풀고 있는 곳입니다. 오픈소스 기여를 중심에 두는 엔지니어 문화, 국산 NPU 생태계와의 협업도 이 일을 재밌게 만드는 이유 중 하나입니다.

AI 인프라의 다음 단계를 직접 설계하고 싶은 분들을 기다리고 있습니다.

---

들어주셔서 감사합니다. Q&A에서 더 깊은 이야기를 나눠요.
