---
title: "Vibe-Coding-Instruct: 110만 샘플로 경량 코드 에이전트를 SFT하는 방법"
excerpt: "lazarus19가 공개한 Vibe-Coding-Instruct는 Apache-2.0, 110만 개 코딩 instruction-response 쌍 데이터셋이다. 이미 7개 Gemma/Qwen 파생 모델을 훈련한 실적이 있으며, 커스텀 코드 에이전트 SFT 파이프라인 구축에 바로 쓸 수 있다."
date: 2026-06-20
categories:
  - datasets
tags:
  - sft
  - instruction-tuning
  - coding-agent
  - vibe-coding
  - apache-2.0
  - qwen
  - gemma
  - code-generation
  - fine-tuning
author_profile: true
toc: true
toc_label: "Vibe-Coding-Instruct 가이드"
reading_time: true
canonical_url: https://thakicloud.github.io/datasets/vibe-coding-instruct-sft/
---

![Vibe Coding Instruct SFT 개념도](/assets/images/vibe-coding-instruct-sft-hero.png)

## 데이터셋 개요

**Vibe-Coding-Instruct**는 lazarus19가 HuggingFace에 공개한 코딩 instruction-response 쌍 데이터셋이다. 훈련 스플릿 기준 110만 개 샘플, Apache-2.0 라이선스, 전체 용량 459 MB다. 이미 이 데이터셋으로 훈련된 모델이 7개 공개되어 있으며, 주로 Gemma와 Qwen 아키텍처 기반의 RavenX-OpenFable-Coder 시리즈가 해당된다.

"vibe coding"이라는 이름은 LLM이 코드 전체를 생성하고 인간은 방향만 잡는 개발 방식을 가리킨다. 이 데이터셋은 그 방식을 지원하는 모델을 파인튜닝하기 위한 instruction 데이터로 설계되었다.

## 구성과 스키마

### 규모

- 훈련 스플릿: 1,100,000개 샘플
- 전체 파일 크기: 459 MB
- 언어: 영어
- 파일 형식: JSON(소스), Parquet(HuggingFace 자동 변환)

### 스키마

각 레코드는 네 개 필드로 구성된다.

| 필드 | 타입 | 값 범위 |
|------|------|---------|
| `instruction` | string | 35~89자 |
| `input` | string | 전체 데이터셋에서 단일 값 |
| `output` | string | 14개 고유값 |
| `prompt` | string | 170~337자 |

`instruction` 필드가 코딩 과제 지시문을, `prompt` 필드가 모델에 실제로 전달되는 포맷 처리된 입력을 담는다. `output`의 고유값이 14개라는 점은 데이터셋의 instruction 유형이 특정 범주로 군집화되어 있음을 의미한다.

### instruction 유형

공개된 샘플에서 확인되는 instruction 범주는 다음과 같다.

- 코딩 어시스턴트 및 AI 애플리케이션 생성
- MERN 스택, AI 앱, 컨테이너 환경 배포
- React 무한 리렌더링, API 500 에러 디버깅
- 챗봇 플랫폼, 확장 가능한 SaaS, AI 프로젝트 매니저 시스템 설계
- Ollama, llama.cpp를 활용한 로컬 LLM 통합

## 라이선스

Apache-2.0이다. 상업적 사용, 수정, 재배포, 특허 사용이 모두 허용된다. 소스 공개 의무가 없어 기업 내부 파인튜닝 파이프라인에 제약 없이 사용할 수 있다.

Apache-2.0 데이터셋으로 훈련한 모델의 라이선스는 훈련에 사용한 베이스 모델의 라이선스를 따르므로, Qwen이나 Gemma 베이스 모델의 라이선스 조건을 별도로 확인해야 한다.

## SFT 파이프라인 관점에서 본 데이터셋 특성

### 110만 샘플의 실용성

110만 개는 소형 코드 모델(1B~7B)의 instruction tuning에 일반적으로 충분한 규모다. 데이터가 너무 많으면 오히려 특정 instruction 유형에 과적합되거나 훈련 시간이 지나치게 늘어난다. Alpaca, FLAN 계열의 초기 instruction 데이터셋이 50K~100K 규모였던 것과 비교하면 10배 이상이다.

459 MB의 실제 파일 크기는 단일 A100 80GB 노드 또는 A10G 24GB 두 대로 에포크당 처리 가능한 범위 안에 있다.

### `output` 고유값 14개의 의미

`output` 필드의 고유값이 14개에 불과한 점은 이 데이터셋의 한계이기도 하다. 출력이 다양한 코드 스니펫이 아니라 정해진 범주의 응답 패턴으로 구성되어 있다면, 이 데이터만으로 훈련한 모델이 폭넓은 코딩 과제를 유연하게 처리하기 어려울 수 있다. 다른 코드 생성 데이터셋과 혼합해 사용하거나, 특정 도메인의 커스텀 데이터를 추가하는 전략이 필요한 이유다.

### 이미 검증된 모델 파생 경로

데이터셋 페이지에 따르면 이 데이터셋을 사용해 훈련된 모델이 이미 7개 있다. RavenX-OpenFable-Coder 시리즈가 Gemma와 Qwen 아키텍처로 각각 공개되어 있어, 동일한 파이프라인을 따라 재현하거나 수정할 수 있는 구조가 이미 존재한다는 뜻이다.

## 커스텀 코드 에이전트 SFT 파이프라인 구축

### 기본 훈련 구성

HuggingFace datasets 라이브러리로 데이터를 불러오면 바로 사용 가능하다.

```python
from datasets import load_dataset

dataset = load_dataset("lazarus19/Vibe-Coding-Instruct")
train_data = dataset["train"]
```

SFT 훈련에는 `prompt` 필드를 모델 입력으로, `output` 필드를 타깃 레이블로 사용한다. TRL(Transformer Reinforcement Learning) 라이브러리의 `SFTTrainer`를 쓰면 설정이 간단하다.

### 도메인 특화 데이터 혼합 전략

Vibe-Coding-Instruct 110만 샘플 전체를 그대로 사용하기보다는 ThakiCloud 플랫폼 특화 instruction을 추가로 만들어 혼합하는 방식이 현실적으로 더 효과적이다. 예를 들어 Kubernetes 매니페스트 생성, ArgoCD 구성 작성, Go 백엔드 API 코드 생성 같은 내부 패턴을 담은 instruction 데이터 수천 개를 만들어 혼합하면 범용 코드 능력 위에 도메인 특화 능력이 올라간다.

이 방식은 Fable-5-traces와 결합할 때도 유효하다. Vibe-Coding-Instruct로 기본 코드 생성 능력을 갖추고, Fable-5-traces로 도구 호출 정책을 추가로 훈련하는 2단계 SFT 구성이 가능하다.

### 베이스 모델 선택

데이터셋 페이지에 나타난 파생 모델 경로를 보면 Qwen2.5-Coder와 Gemma3 시리즈가 주로 쓰였다. ThakiCloud 환경에서 온프레미스로 호스팅할 경우 Qwen2.5-Coder-7B-Instruct를 베이스 모델로 쓰고 이 데이터셋으로 SFT하면 외부 API 의존 없이 사내 코드 에이전트를 구성할 수 있다.

## ThakiCloud 활용 각도

이 데이터셋의 ThakiCloud 플랫폼 활용은 다음 방향으로 정리된다.

**자가호스팅 코드 에이전트 기반 데이터**: Apache-2.0 라이선스로 제약 없이 내부 파인튜닝 파이프라인에 통합할 수 있다. Vibe-Coding-Instruct 110만 샘플을 Kueue 배치 잡으로 처리하면 ThakiCloud 인프라 위에서 전체 훈련 사이클을 완결할 수 있다.

**베이스라인 코드 능력 확보**: 특정 도메인 데이터가 적을 때 Vibe-Coding-Instruct를 범용 코드 기반 능력 확보용으로 먼저 쓰고, 이후 내부 도메인 데이터를 점진적으로 추가하는 전략이 현실적이다.

**RavenX 파생 모델 참조**: 이미 공개된 7개 파생 모델의 훈련 구성을 참조해 최소한의 실험 비용으로 출발점을 설정할 수 있다.

고려해야 할 점도 있다. `output` 고유값 14개라는 제한된 다양성은 이 데이터만으로 훈련한 모델이 새로운 유형의 코딩 과제 앞에서 일반화 실패를 보일 가능성을 시사한다. 보조 데이터셋이나 내부 데이터와 혼합해서 쓰는 전략이 권장된다.

## 정리

Vibe-Coding-Instruct는 110만 개 샘플, Apache-2.0, 459 MB 크기의 코딩 instruction 데이터셋이다. 이미 7개 모델을 생산한 실적이 있고 Qwen, Gemma 기반 파인튜닝 경로가 검증되어 있다. 커스텀 코드 에이전트 SFT 실험의 출발점으로 사용하기에 진입 장벽이 낮은 데이터셋이다. `output` 다양성 한계를 인식하고 도메인 특화 데이터와 혼합해 쓰는 전략을 짜면 실용적인 온프레미스 코드 에이전트를 만들 수 있다.

HuggingFace: [lazarus19/Vibe-Coding-Instruct](https://huggingface.co/datasets/lazarus19/Vibe-Coding-Instruct)
