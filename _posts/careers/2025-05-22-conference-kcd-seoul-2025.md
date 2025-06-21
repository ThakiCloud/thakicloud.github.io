---
title: "[Thaki Cloud Life & 커리어] KCD Seoul 2025"
excerpt: "KCD Seoul 2025에서 발표한 자료를 공유합니다. xPU as a Service 기반 Agentic AI 플랫폼Thaki Cloud에 대한 내용입니다"
date: 2025-05-22 # 실제 발행일로 변경하세요
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
author_profile: true # 회사 계정 또는 HR 담당자로 설정 가능
--- 

# 🎤 ThakiCloud @ KCD Seoul 2025 발표 정보

---

## 📅 일시

**2025년 5월 22일 (목)**

---

## 🔗 관련 링크

- **공식 홈페이지**: [KCD Seoul 2025](https://community.cncf.io/events/details/cncf-kcd-south-korea-presents-kcd-seoul-2025/)
- **LinkedIn 홍보 페이지**: [ThakiCloud - KCD Seoul 2025](https://www.linkedin.com/posts/thakicloud_kcdseoul2025-thakicloud-xpuasaservice-activity-7330146553937960961-yBcG?utm_source=share&utm_medium=member_desktop&rcm=ACoAAAAuzrMB15I-NYSyIEDIpkgrPxOMdfaqjcM)
- **발표 자료**: [슬라이드 보기](https://ihryedku.gensparkspace.com/)

---

## 📜 발표 스크립트

### 🎤 ThakiCloud 소개 및 xPU 기반 Agentic AI 인프라 플랫폼

---

### 1. 인트로 (Slide 1)

안녕하세요. ThakiCloud의 [이름]입니다.  
오늘은 AI 시대의 인프라 패러다임을 바꾸는 **Kubernetes-Native Agentic AI 플랫폼**, 그리고 저희가 제안하는 **xPU 기반 AI 인프라의 미래**에 대해 말씀드리겠습니다.

---

### 2. 회사 소개 & 미션 (Slide 2)

ThakiCloud는 퍼블릭 클라우드 수준의 유연성과 확장성을 **프라이빗 및 하이브리드 환경**에서도 실현하는 AI 인프라 플랫폼 기업입니다.

**미션**: 모든 기업이 AI First로 전환할 수 있도록 지원하는 것

**핵심 기술 영역**:

- LLM & Agentic AI 인프라스트럭처  
- 이기종 가속기 통합 관리(xPU 관리)  
- Kubernetes-Native 기반의 xPU 서비스화  

---

### 3. 왜 xPUaaS와 Agentic AI인가? (Slide 3)

**현재 문제**:

- GPU 중심의 비용(TCO) 상승과 공급망 불안정  
- 다양한 워크로드에 따른 하드웨어 최적화의 어려움  
- Agentic AI 특유의 복잡한 오케스트레이션  
- 데이터 주권 이슈  

**ThakiCloud의 해법**:

- 다양한 가속기를 서비스로 제공하는 **xPUaaS**  
- 개발자 경험 중심의 **Turnkey Agentic AI PaaS**  
- **Sovereign Cloud**를 통한 데이터 규제 대응  

---

### 4. AI 워크로드 최적화 흐름 (Slide 4)

다이어그램을 보시면, 저희 플랫폼은 AI 워크로드 유형에 따라 **가장 적합한 xPU를 자동 할당**합니다.

예:

- **대규모 학습** → NVIDIA GPU Cluster  
- **실시간 추론** → 고성능 GPU 또는 국내 NPU  
- **배치 추론** → 비용 최적화된 혼합 구조  

이러한 파이프라인은 **지속적인 모니터링과 피드백을 통해 자동 최적화**됩니다.

---

### 5. Cloud-Native AI 인프라 구성 (Slide 5~6)

저희의 xPUaaS는 **Kubernetes 확장 아키텍처** 기반으로 설계되어 있으며:

- 다양한 **디바이스 플러그인**  
- 통합 **추론 런타임**  
- **xPU SDK Wrapper**를 통한 직관적인 API  
- **Prometheus, Grafana, Loki** 기반의 모니터링 환경  

SDK, 웹, 모바일 등 다양한 클라이언트가 **API Gateway**를 통해 접근합니다.

---

### 🎤 슬라이드 6 상세 발표 스크립트

#### ✅ 전체 구성 흐름

ThakiCloud의 xPUaaS 아키텍처는 클라이언트 요청부터 추론 가속기까지의 **전체 흐름을 시각화**한 구조입니다.

#### 1. 클라이언트 계층

- 웹, 모바일, SDK 클라이언트가 API Gateway를 통해 AI 서비스에 접근  
- **xPUaaS API Gateway**가 요청을 중심적으로 라우팅

#### 2. 핵심 서비스 계층

- **Inference Service**: 실시간 추론 처리  
- **Model Management**: 모델 등록, 버전 관리  
- **xPU Resource Pools**: 가속기 풀 구성  
- **Autoscaling**: 수요에 따른 자동 스케일 조정

#### 3. Kubernetes 오케스트레이션 계층

- **Device Plugins**: 각 벤더별 가속기 등록 (NVIDIA, Rebellions, Furiosa 등)  
- **Custom Scheduler**: 최적화된 자원 배치  
- **Inference Runtime / SDK Wrapper**: 백엔드 통합  
- **Resource Isolation / Observability**: 격리 및 모니터링 체계 구축

#### 4. 하드웨어 계층

- NVIDIA GPU, FuriosaAI NPU, Rebellions NPU 등과 실시간 연동  
- 드라이버, 전력, 헬스 체크, 펌웨어 업데이트 관리 포함

#### 📌 요약 강조

- **단일 API 게이트웨이**  
- **Kubernetes 기반 자동화 인프라**  
- **유연한 xPU 연결성**  
- **강력한 모니터링 및 안정성 확보**

---

### 6. 유연한 클라우드 운영 전략 (Slide 8~9)

- **GitOps + Helm** 기반 선언적 배포  
- **멀티 클라우드 대응**: 온프레미스, AWS EKS, GCP GKE, Azure AKS  
- **서버리스 확장성**: ACA, Cloud Run과 연동  
- **퍼블릭 클라우드 수준의 자동화와 스케일링**을 프라이빗 환경에서도 실현

---

### 7. 함께 할 이유 (Slide 10)

ThakiCloud는:

- **AI 인프라 혁신을 선도**하며  
- **오픈소스 기여 중심의 엔지니어 문화**를 지향하고  
- **국산 NPU 생태계와 함께 성장**합니다.  

AI 인프라의 미래를 함께 설계할 파트너와 동료들을 기다리고 있습니다.

---

## 🔚 마무리

들어주셔서 감사합니다.  
발표 후 Q&A 시간에 더 많은 이야기를 나눌 수 있기를 기대합니다.
