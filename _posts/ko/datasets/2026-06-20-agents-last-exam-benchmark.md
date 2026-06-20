---
title: "Agents Last Exam: 컴퓨터 사용 에이전트 평가 기준이 왜 153개 장기 과제로 진화했는가"
excerpt: "agents-last-exam은 153개 장기 과제로 컴퓨터 사용 에이전트를 평가하는 벤치마크 데이터셋이다. Business, Computing, Engineering, Legal 등 5개 도메인, CC-BY-4.0 라이선스. 자체 모델 벤치마킹 파이프라인 구축 가이드."
date: 2026-06-20
categories:
  - datasets
tags:
  - benchmark
  - computer-use
  - agent-evaluation
  - long-horizon
  - multi-step
  - cc-by-4.0
  - coding-agent
  - enterprise-software
author_profile: true
toc: true
toc_label: "Agents Last Exam 가이드"
reading_time: true
canonical_url: https://thakicloud.github.io/datasets/agents-last-exam-benchmark/
---

![Agents Last Exam 에이전트 평가 개념도](/assets/images/agents-last-exam-benchmark-hero.png)

## 데이터셋 개요

**agents-last-exam**은 컴퓨터 사용(computer-use) 에이전트를 장기 과제(long-horizon task) 기준으로 평가하기 위한 벤치마크 데이터셋이다. 총 153개 과제로 구성되며 Business, Computing, Mathematics, Engineering, Legal 등 여러 전문 도메인을 가로질러 에이전트가 실제 업무 워크플로를 수행할 수 있는지 측정한다.

기존 벤치마크 대부분이 단일 전환 질의응답이나 단순 코드 완성에 집중해온 데 반해, 이 데이터셋은 에이전트가 여러 도구를 순서대로 사용하고 중간 결과물을 파일로 저장하며 최종 출력물을 제출하는 "일의 완결" 능력을 측정한다는 점이 다르다.

## 구성과 스키마

### 규모

- 전체 153개 과제(v1.0 단일 스플릿)
- 과제당 `task_prompt` 길이 502~5,840자
- 과제당 `agent_must_do` 필수 행동 0~9개
- 과제당 첨부 입력 파일 0~14개

### 도메인 분포

| 도메인 | 과제 수(추정) |
|--------|--------------|
| Computing and Mathematics | 약 70개 |
| Business and Finance | 약 60개 |
| Education and Information | 약 10개 |
| Engineering | 약 10개 |
| Legal | 약 3개 |

### 스키마

각 레코드는 다음 필드로 구성된다.

| 필드 | 설명 |
|------|------|
| `task_id` | 과제 식별자 |
| `title` | 과제 제목 |
| `summary` | 과제 요약 |
| `category` | 상위 도메인 |
| `subdomain` | 세부 분야 |
| `task_prompt` | 에이전트에게 주어지는 실제 지시문 |
| `agent_must_do` | 평가자가 확인하는 필수 수행 행동 목록 |
| `software` | 사용해야 하는 소프트웨어/도구 |
| `input_files` | 과제 수행에 필요한 입력 파일 목록 |
| `taxonomy` | 도메인/서브도메인 메타데이터 |
| `source_repo_path` | 검증 가능한 소스 경로 |

### 파일 형식

Parquet(소스에서 자동 변환). 언어는 영어.

### 과제 유형 예시

- 회계 및 재무: 세금 양식 처리, 재무제표 파싱, 주식 리서치
- 공급망: Odoo ERP 워크플로 자동화
- 계량 금융: 옵션 가격 산출, 팩터 모델 재현
- 사이버보안: 악성코드 분석, 패킷 포렌식
- 인프라: Kubernetes 최적화, AWS 비용 절감
- 데이터 엔지니어링: ETL 파이프라인, 추천 시스템

## 라이선스

CC-BY-4.0이다. 출처를 표기하면 상업적 용도를 포함해 자유롭게 사용, 수정, 재배포할 수 있다. 벤치마크 데이터셋에서 가장 개방적인 라이선스 범주에 속한다.

## 에이전트 평가 기준의 진화

이 데이터셋이 왜 주목받는지 이해하려면 에이전트 평가 기준이 어떻게 변해왔는지를 먼저 봐야 한다.

초기 LLM 벤치마크는 MMLU, HellaSwag처럼 객관식 문제를 얼마나 정확히 맞히는지를 봤다. 모델이 충분히 스케일되자 이 벤치마크들이 포화됐고, HumanEval, MBPP 같은 코드 생성 벤치마크로 이동했다. 에이전트 시대가 되면서 SWE-Bench처럼 실제 GitHub 이슈를 코드로 해결하는 벤치마크가 등장했다.

agents-last-exam은 그 연장선에 있다. 단순히 코드를 짜는 것이 아니라, 에이전트가 브라우저를 켜고, ERP 시스템에서 데이터를 가져오고, 스프레드시트를 수정하고, 리포트 파일을 제출하는 전 과정을 완수할 수 있는지 측정한다.

### 평가 방법론

평가는 결정론적 출력 계약(deterministic output contract)에 기반한다. 에이전트가 JSON, XLSX, 코드 파일, 리포트를 명시된 형식으로 제출하면 그 내용을 도메인별 기준으로 검증한다.

- 금융 정확성: 수치 계산 결과가 기준값과 일치하는가
- 보안 엄밀성: 악성코드 분석이 올바른 결론을 냈는가
- 데이터 스키마 준수: ETL 결과물이 명시된 스키마를 따르는가
- 실행 가능성: 생성된 코드가 실제로 돌아가는가

`agent_must_do` 필드에 열거된 필수 행동들은 가중치 점수(weighted scoring)로 평가되며 과제별로 검증 루브릭이 다르다.

### 사용하는 소프트웨어 범주

153개 과제에서 에이전트가 조작해야 하는 소프트웨어 범주는 다음과 같다.

브라우저 자동화, PDF 파싱, GeoPackage 워크플로, Python/C++/SQL/셸 스크립팅, Odoo, Metabase, Flowable BPMN, LibreOffice, Rhino 8, Docker, Kubernetes, Linux 권한 관리가 포함된다. 단일 에이전트가 이 모든 영역을 잘 처리하기를 요구하는 것이 아니라, 특정 도메인에서 에이전트의 실제 역량이 어느 수준인지 세분화해서 측정하는 구조다.

## 자체 모델 측정 파이프라인 구축

이 데이터셋의 실용적 가치는 자체 에이전트 모델을 측정하는 기준점으로 쓸 수 있다는 데 있다. 데이터셋 자체에 baseline 성능 수치가 제공되지 않기 때문에, 사용 기관이 직접 기준을 만들어야 한다. 이를 역으로 활용하면 외부 공개 성능 없이 내부 비교 기준을 독자적으로 설정할 수 있다.

평가 파이프라인 구성 단계는 다음과 같다.

1. 도메인별 과제 필터링: `category`와 `subdomain`으로 평가 대상 범위를 정한다.
2. 도구 환경 구성: `software` 필드에 명시된 도구를 과제별로 컨테이너 환경에 준비한다.
3. 에이전트 실행: 각 과제의 `task_prompt`를 입력으로 에이전트를 실행한다.
4. 출력물 수집: 에이전트가 생성한 파일이나 응답을 과제별 출력 디렉터리에 저장한다.
5. 검증 실행: `agent_must_do` 필드의 행동 목록을 기준으로 완수 여부를 자동 채점한다.

## ThakiCloud 활용 각도

ThakiCloud 플랫폼에서 이 데이터셋의 활용 방향은 주로 두 가지다.

**자체 에이전트 역량 측정**: Kueue에서 실행 중인 AI 에이전트 모델이 실제 업무 과제를 얼마나 완수하는지 agents-last-exam 153개 과제로 정기 측정한다. 특히 K8s 관련 과제나 데이터 엔지니어링 과제에서 자체 인프라 모델의 강점과 약점을 정량화할 수 있다.

**에이전트 개발 회귀 테스트**: 에이전트 모델이나 도구 정책을 업데이트할 때마다 관련 도메인 과제 부분집합을 실행해 성능 저하 여부를 확인하는 자동화 회귀 테스트로 사용할 수 있다. CC-BY-4.0 라이선스로 내부 파이프라인에 제약 없이 통합할 수 있다.

ArgoCD GitOps 구조를 따르면 과제별 평가 잡을 코드로 관리하고 에이전트 버전이 바뀔 때마다 자동으로 벤치마크를 돌리는 워크플로를 구성할 수 있다.

## 정리

agents-last-exam은 에이전트 평가 기준이 단문 응답에서 장기 업무 완수로 이동하는 흐름을 보여주는 데이터셋이다. 153개 과제, 5개 도메인, CC-BY-4.0 라이선스 조합은 자체 에이전트 모델의 현실적인 역량을 측정하고 싶은 팀에게 출발점이 될 수 있다. 공개된 baseline이 없다는 점은 불편하지만, 외부 비교 없이 내부 진전을 측정하는 용도로는 오히려 자유도가 높다.

HuggingFace: [agents-last-exam/agents-last-exam](https://huggingface.co/datasets/agents-last-exam/agents-last-exam)
