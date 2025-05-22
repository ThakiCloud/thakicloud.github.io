---
title: "MLOps 현장 속으로"
excerpt: "UC Berkeley 인터뷰 연구로 본 성공 전략, 난제, 그리고 미래"
date: 2025-05-22
categories:
  - llmops
tags:
  - MLOps
  - LLMOps 
  - ThreeVs
  - Cloud
  - Thaki Cloud
author_profile: true # 회사 계정 또는 HR 담당자로 설정 가능
---

## MLOps 현장 속으로 — UC Berkeley 인터뷰 연구로 본 성공 전략, 난제, 그리고 미래 🌐🚀

> Shreya Shankar et al., “Operationalizing Machine Learning: An Interview Study,” UC Berkeley, Oct 2022&#x20;

---

### 1. 배경 | “모델을 굴리는 방법”이 비즈니스 성패를 가른다

“모델을 만든다”와 “모델을 **살린다**” 사이에는 거대한 간극이 존재합니다. 18명의 실무 MLE를 대상으로 한 Berkeley 팀의 인터뷰는 그 간극을 메우는 실무 지점을 **Velocity, Validation, Versioning**(3Vs)이라는 프레임으로 정리했습니다. 이 글은 해당 연구에 필드 경험과 최신 사례를 덧붙여 **실행 가능한 가이드**로 재구성한 것입니다.

---

## 2. Three Vs 심층 해부

| V                         | 왜 중요한가                               | 실전 포인트                                                                          |
| ------------------------- | ------------------------------------ | ------------------------------------------------------------------------------- |
| **Velocity**<br>(속도)      | 시장·데이터·규제 변화에 **즉각 대응**해야 가치가 발생한다.  | - Notebook → 파이프라인 → 서빙까지 **단일 CLI**<br>- 작은 config 변경도 **즉시** staging 배포       |
| **Validation**<br>(검증)    | 버그·데이터 드리프트는 “초기에 잡느냐”가 피해 규모를 결정한다. | - Shadow → Canary → A/B 테스트 **다단계 벤치마크**<br>- **동적 검증셋**(sub-pop, 리얼 트래픽 샘플) 유지 |
| **Versioning**<br>(버전 관리) | 실패한 실험을 살려두면, 미래의 성공을 가속한다.          | - **데이터·모델·코드**를 원자적 스냅샷<br>- Fallback 모델 & 룰-기반 후처리로 **즉시 롤백**                 |

> 3Vs는 서로 **상호작용**합니다. 예컨대, 강력한 Versioning은 빠른 롤백을 가능케 해 Velocity를 높이고, 잘 설계된 Validation 파이프라인은 버전 변화를 **기록**해 Versioning 품질을 높입니다.&#x20;

---

## 3. 4단계 MLOps 워크플로우 - 세부 설계

### 3-1. 데이터 수집·라벨링

* 중앙 데이터 레이크 + **스키마 버전 관리**
* MTurk/Labelbox 연계 시 **라벨 품질 메타데이터**(annotator, 시간, confidence)까지 저장
* 라벨링 비용을 줄이기 위해 **Active Learning** 샘플링 전략 도입

### 3-2. 실험 & 피처 엔지니어링

* **데이터·피처 우선** 전략: 모델 신규 아키텍처는 “마지막 화살”
* **Feature Store**를 통해 온·오프라인 피처 불일치 제거
* 파라미터 & 환경(**conda.lock**, Docker SHA) 자동 스냅샷

### 3-3. 평가·배포

* Staging→Shadow(100% 트래픽, 0% 출력)→Canary(1-5%)→Full 롤아웃
* **A/B Test TTL** 명시: 실험이 오래 방치되면 자동 종료
* Latency·메모리 발자국 등 **시스템 지표**를 모델 지표와 동등 취급

### 3-4. 모니터링·대응

* **데이터 드리프트 탐지**: KS-Test, PSI, Embedding Distance
* On-call Playbook: “10분 내 triage, 30분 내 rollback”
* 장기적 품질 보존을 위한 **주기적 재학습**(cron + feature freshness 정책)

---

## 4. 조직·문화 Best Practice

### 실험-제일 문화

* 실패 → 학습 → 재시도 사이클 **< 24h**
* “Kill criteria”를 실험 티켓에 **선-명시**해 불필요한 GPU 소모 방지

### 평가 시스템 고도화

* **Slice-aware Dashboard**: 인구통계·지역·디바이스 별 스코어
* 오프라인 → 온라인 지표 벡터를 **시계열 DB**(Influx, Timescale)로 수집

### 배포 안정장치

* **Rule Guardrail**: 모델 confidence < τ ⇒ 룰-베이스드 fallback
* Blue-Green Infra로 배포 중단 없는 Rollback

---

## 5. Pain Points & Anti-Patterns—실제 목소리

| Pain Point   | 세부 증상                        | 해결 방향                                            |
| ------------ | ---------------------------- | ------------------------------------------------ |
| 개발-운영 환경 불일치 | Notebook 코드를 그대로 cron에 붙여 돌림 | **Docker + CI 템플릿** 의무화                          |
| 데이터 품질 알람 남발 | false positive로 인해 알람 무시     | 알람 Precision ≥ 0.9 보장, **예외 샘플 링크** 포함           |
| 롱테일 버그       | 재현 어려운 edge case             | **Feature Flag**로 문제 구간 격리 후 재현                  |
| 지연된 배포       | E2E 검증 수개월                   | “Spec → Code 생성 → 가상 트래픽” **Simulation Loop** 구축 |

> 인터뷰 참여자들은 “문서화되지 않은 트라이벌 지식이 결국 장애를 키웠다”고 증언했습니다. 이는 Velocity와 Versioning 사이 **긴장 관계**를 보여 줍니다.&#x20;

---

## 6. 실제 기업 사례로 본 3Vs

### Airbnb Bighead 플랫폼

* 중복 피처 제거, 실험 추적, A/B 자동화로 **Velocity ↑**
* 공유 Feature Store가 데이터·모델 **Versioning**의 단일 소스가 됨 ([slideshare.net][1])

### Netflix Metaflow

* Notebook → 프로덕션 코드 전환을 “@step” 데코레이터 한 줄로 처리
* DAG 수행 결과, 데이터 스냅샷을 S3에 버전-관리해 **Validation & Versioning** 동시에 해결 ([github.com][2])

> 이 두 사례 모두 “도구가 아니라 **경험 곡선**”을 가속화해 3Vs를 실현했다는 공통점이 있습니다.

---

## 7. 툴·플랫폼 설계자를 위한 체크리스트

| 체크 항목                  | 구현 힌트                                         |
| ---------------------- | --------------------------------------------- |
| **실험-to-서빙 단일 CLI**    | `ml exp run → ml deploy canary`               |
| **데이터·모델 통합 버저닝**      | Parquet + Delta Lake, lineage metadata        |
| **Shadow Test 자동화**    | 프록시 레이어에서 copy-query 실행                       |
| **Slice-wise 모니터링**    | KPI vector = `[CTR, Lat, Err, Drift]` × slice |
| **Self-Healing 파이프라인** | 드리프트 감지 → retrain job trigger                 |

---

## 8. 미래 전망 — “지속 가능 MLOps”로 가는 길

1. **Declarative MLOps**: GitOps + FeatureOps로 파이프라인을 코드화
2. **Self-Driving ML Platform**: 드리프트-aware Auto-Retraining, Policy-as-Code
3. **Responsible AI Ops**: Fairness & Explainability 모니터링이 1급 시민으로 편입

Berkeley 연구는 “MLOps는 공학적 난제가 아니라 *사회-기술적 시스템*”임을 재확인했습니다. 세 가지 질문으로 끝을 맺습니다.

1. **Velocity** — 내 파이프라인에서 가장 느린 고리는 어디인가?
2. **Validation** — 오늘 새벽 3시에 모델이 망가졌다면, 누가 10분 안에 알 수 있는가?
3. **Versioning** — 6개월 전 실험 결과를 **완전 재현**할 수 있는가?

이 질문에 자신 있게 “예”라고 답할 수 있을 때, 우리는 진정한 의미의 **Production-Grade MLOps**에 다가선 것입니다.

---

## 참고 문헌

*   Shankar, S., Garcia, R., Hellerstein, J. M., & Parameswaran, A. G. (2022). *Operationalizing Machine Learning: An Interview Study*. arXiv preprint arXiv:2209.09125. Available at: [https://arxiv.org/abs/2209.09125](https://arxiv.org/abs/2209.09125)

