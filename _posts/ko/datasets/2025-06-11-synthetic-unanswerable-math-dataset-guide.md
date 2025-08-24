---
title: "Synthetic Unanswerable Math (SUM): LLM 신뢰성 향상을 위한 답변 불가능 수학 문제 데이터셋"
date: 2025-06-11
categories: 
  - datasets
  - research
  - machine-learning
tags: 
  - hugging-face
  - dataset
  - llm-evaluation
  - hallucination
  - reinforcement-learning
  - math-problems
  - model-safety
author_profile: true
toc: true
toc_label: "목차"
---

LLM(Large Language Model)의 신뢰성을 높이기 위한 혁신적인 접근법이 등장했습니다. USC의 연구팀이 개발한 **Synthetic Unanswerable Math (SUM)** 데이터셋은 AI 모델이 "모른다"고 말할 수 있는 능력을 기르는 데 특화된 고품질 수학 문제 모음입니다.

## 데이터셋 개요

**Synthetic Unanswerable Math (SUM)**는 대규모 언어 모델의 거부 행동(refusal behavior)을 조사하고 개선하기 위해 구성된 고품질의 암묵적으로 답변 불가능한 수학 문제 데이터셋입니다. 이 데이터셋의 핵심 목표는 모델이 불완전하거나 모호하거나 모순된 정보로 인해 문제를 해결할 수 없을 때 이를 식별하고 겸손한 태도로 응답하도록 가르치는 것입니다.

### 주요 특징

- **데이터 규모**: 36,764개의 문제 쌍
- **라이선스**: MIT 라이선스
- **형식**: Parquet 파일
- **모달리티**: 텍스트
- **크기**: 10K - 100K 범위

### 데이터 구조

각 데이터 항목은 다음과 같은 구조를 가집니다:

- `answerable_question`: DeepScaleR 데이터셋의 원본 해결 가능한 수학 문제
- `unanswerable_question`: 원본 문제를 의도적으로 해결 불가능하게 수정한 합성 버전
- `ground_truth`: 원본 문제의 정답

## 답변 불가능성 기준 5가지

연구진은 정보 저하의 5가지 유형에 따라 답변 불가능한 문제를 생성했습니다:

### 1. 핵심 정보 삭제 (Key Information Deletion)

문제에서 중요한 수치나 논리적 세부사항을 제거하여 답을 계산할 수 없게 만듭니다.

**예시:**

- 원본: "Doug constructs a square window using **8 equal-size panes** of glass..."
- 수정: "Doug constructs a square window using **equal-size panes** of glass..."

### 2. 모호한 핵심 정보 (Ambiguous Key Information)

문제 진술을 모호하거나 불명확한 세부사항으로 수정하여 정확한 추론을 방해합니다.

**예시:**

- 원본: "There are $11$ students in Mrs. Germain's class, $8$ students in Mr. Newton's class..."
- 수정: "In Mrs. Germain's class there are **more than ten but fewer than fifteen students**..."

### 3. 비현실적 조건 (Unrealistic Conditions)

불가능하거나 논리적으로 일관성이 없는 전제를 도입합니다.

### 4. 관련 없는 객체 (Unrelated Objects)

원래 맥락에서 소개되거나 정의되지 않은 개체를 참조하도록 문제를 수정합니다.

### 5. 질문 삭제 (Question Deletion)

배경 맥락은 유지하되 실제 질문 부분을 생략하여 답변 불가능하게 만듭니다.

## 데이터 생성 과정

연구팀은 다음과 같은 체계적인 과정을 통해 데이터를 생성했습니다:

1. **자동 생성**: `o3-mini` 모델을 사용하여 DeepScaleR 문제의 답변 불가능한 변형을 자동 생성
2. **프롬프트 엔지니어링**: 상세한 지침과 예시를 통해 문제를 답변 불가능하게 만드는 그럴듯한 편집 수행
3. **전문가 검토**: 생성된 문제들을 전문가 어노테이터가 검토하여 정확성과 자연스러움 보장

## 활용 목적 및 효과

SUM 데이터셋은 다음과 같은 다양한 목적으로 활용될 수 있습니다:

### 진단 (Diagnose)

강화학습 미세조정(RFT) 맥락에서 LLM의 환각 현상에 대한 취약성을 평가합니다.

### 훈련 (Train)

RFT 과정에서 SUM 데이터를 혼합하여 LLM의 신뢰성을 개선합니다.

### 교육 (Teach)

모델이 자신의 불확실성과 지식 경계에 대해 추론하고 적절한 때에 답변을 거부하는 일반화 가능한 능력을 개발하도록 돕습니다.

### 실증적 효과

연구 결과에 따르면, RFT 과정에서 **단 10%의 SUM 데이터만 포함**해도 다음과 같은 효과를 얻을 수 있습니다:

- 답변 불가능한 질의에 대한 거부율 대폭 증가
- 답변 가능한 수학 과제에서의 성능 유지
- 사실 기반 QA 등 다른 도메인으로의 일반화

## 연구 배경 및 의의

이 데이터셋은 **"The Hallucination Tax of Reinforcement Finetuning"** 논문의 핵심 구성 요소입니다. 연구진은 강화학습 미세조정이 가져오는 환각 현상의 "세금"을 정량화하고, 이를 완화하는 방법을 제시했습니다.

### 주요 기여점

1. **체계적 분류법**: 답변 불가능성의 5가지 유형을 명확히 정의
2. **실용적 솔루션**: 기존 훈련 파이프라인에 쉽게 통합 가능한 데이터셋 제공
3. **광범위한 적용성**: 수학 문제뿐만 아니라 다른 도메인으로도 일반화 가능

## 데이터셋 접근 및 사용법

### Hugging Face에서 로드하기

```python
from datasets import load_dataset

# 데이터셋 로드
dataset = load_dataset("lime-nlp/Synthetic_Unanswerable_Math")

# 훈련 세트 확인
train_data = dataset['train']
print(f"훈련 데이터 크기: {len(train_data)}")

# 샘플 데이터 확인
sample = train_data[0]
print("원본 문제:", sample['answerable_question'])
print("수정된 문제:", sample['unanswerable_question'])
print("정답:", sample['ground_truth'])
```

### 모델 훈련에 활용하기

```python
# SUM 데이터와 기존 데이터 혼합 (10% 비율 권장)
def mix_datasets(answerable_data, sum_data, ratio=0.1):
    sum_size = int(len(answerable_data) * ratio)
    mixed_data = answerable_data + sum_data[:sum_size]
    return mixed_data
```

## 향후 전망

SUM 데이터셋은 AI 안전성과 신뢰성 연구에 중요한 기여를 하고 있습니다. 특히 다음과 같은 영역에서 활용이 기대됩니다:

- **의료 AI**: 불확실한 진단 상황에서의 신중한 응답
- **금융 AI**: 불완전한 정보를 바탕으로 한 투자 조언 방지
- **교육 AI**: 학습자에게 잘못된 정보 제공 방지
- **일반 목적 AI**: 전반적인 신뢰성과 안전성 향상

## 결론

Synthetic Unanswerable Math 데이터셋은 AI 모델의 겸손함을 가르치는 혁신적인 접근법을 제시합니다. "모른다"고 말할 수 있는 AI야말로 진정으로 신뢰할 수 있는 AI라는 철학을 구현한 이 데이터셋은 앞으로의 AI 안전성 연구에 중요한 이정표가 될 것입니다.

## 참고 자료

- **데이터셋 페이지**: [Hugging Face - Synthetic_Unanswerable_Math](https://huggingface.co/datasets/lime-nlp/Synthetic_Unanswerable_Math)
- **논문**: "The Hallucination Tax of Reinforcement Finetuning" (arXiv:2505.13988)
- **연구팀**: USC Language, Intelligence, and Model Evaluation Lab
- **문의**: taiweish@usc.edu, linxinso@usc.edu

---

*이 포스트는 USC 연구팀의 공개 연구 자료를 바탕으로 작성되었습니다. 데이터셋 사용 시 적절한 인용을 부탁드립니다.*
