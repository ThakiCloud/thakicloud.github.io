---
title: "Tiny Reasoning Language Model (TRLM-135M): 소형 모델의 추론 능력 혁신"
excerpt: "135M 파라미터로 구현된 TRLM-135M은 소형 모델의 단계별 추론 학습을 연구하는 혁신적인 모델입니다. 3단계 파이프라인을 통해 일반적인 대화부터 복잡한 추론까지 학습합니다."
seo_title: "TRLM-135M 소형 추론 언어 모델 가이드 - Thaki Cloud"
seo_description: "135M 파라미터 TRLM-135M 모델의 3단계 학습 파이프라인과 추론 능력 향상 방법을 알아보세요. 소형 모델의 추론 학습 연구 성과를 확인할 수 있습니다."
date: 2025-09-29
categories:
  - owm
tags:
  - TRLM
  - 소형모델
  - 추론학습
  - DPO
  - 단계별추론
author_profile: true
toc: true
toc_label: "목차"
canonical_url: "https://thakicloud.github.io/ko/owm/tiny-reasoning-language-model-trl-135m-guide/"
lang: ko
permalink: /ko/owm/tiny-reasoning-language-model-trl-135m-guide/
---

⏱️ **예상 읽기 시간**: 8분

## 소개

**Tiny Reasoning Language Model (TRLM-135M)**은 135M 파라미터를 가진 연구용 프로토타입으로, 소형 모델이 어떻게 단계별 추론을 학습할 수 있는지 연구하기 위해 개발되었습니다. 이 모델은 SmolLM2-135M-Instruct를 기반으로 하여 **3단계 파이프라인**을 통해 미세 조정되었습니다.

## TRLM-135M의 핵심 특징

### 모델 아키텍처
- **기반 모델**: SmolLM2-135M-Instruct (Llama 3 기반)
- **파라미터 수**: 약 135M
- **정밀도**: 혼합 정밀도 (bfloat16) 훈련
- **아키텍처**: 디코더 전용 트랜스포머

### 3단계 학습 파이프라인

#### 1단계: 일반 지시 튜닝 (SFT)
- **데이터**: 약 58,000개 샘플
- **내용**: 일상 대화 및 지시 따르기
- **목적**: 기본적인 대화 능력 확보

#### 2단계: 추론 추적 학습 (SFT)
- **데이터**: 약 78,000개 샘플
- **특징**: `<think>` 태그가 포함된 추론 과정
- **목적**: 단계별 사고 과정 학습

#### 3단계: 선호도 정렬 (DPO)
- **데이터**: 약 50,000개 선호도 쌍
- **내용**: 선택된 추론 vs 거부된 추론
- **목적**: 추론 스타일 정렬

## 성능 평가 결과

TRLM-135M은 다양한 벤치마크에서 기존 SmolLM2-135M-Instruct 대비 상당한 개선을 보였습니다:

| 벤치마크 | TRLM-135M | SmolLM2-135M-Instruct | 개선도 |
|---------|-----------|----------------------|--------|
| **ARC Challenge** | **40.61** | 37.3 | **+3.31** |
| **BBH** | **36.80** | 28.2 | **+8.6** |
| **BoolQ** | **62.17** | – | N/A |
| **GSM8K** | **2.59** | 1.4 | **+1.19** |
| **IFEval** | **35.49** | 29.9 | **+5.59** |
| **MMLU** | **34.95** | 29.3 | **+5.65** |
| **PIQA** | **64.91** | 66.3 | **-1.39** |

## 사용 방법

### 설치 및 설정

```bash
pip install -U transformers accelerate
```

### 기본 사용 예제

```python
from transformers import AutoModelForCausalLM, AutoTokenizer

model_name = "Shekswess/trlm-135m"
device = "cuda"  # 또는 "cpu"

# 토크나이저 및 모델 로드
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForCausalLM.from_pretrained(
    model_name,
).to(device)

# 예제 프롬프트
prompt = "중력에 대해 간단한 용어로 설명해주세요."
messages = [
    {"role": "user", "content": prompt}
]

# 채팅 템플릿 적용
text = tokenizer.apply_chat_template(
    messages,
    tokenize=False,
    add_generation_prompt=True,
)

inputs = tokenizer([text], return_tensors="pt").to(model.device)

# 생성
outputs = model.generate(**inputs, max_new_tokens=256)
print(tokenizer.decode(outputs[0], skip_special_tokens=True))
```

### 추론 중심 작업을 위한 설정

추론이 많이 필요한 작업의 경우 다음 파라미터를 권장합니다:
- `temperature=0.6`
- `top_p=0.95`

## 기술적 혁신점

### 1. 단계별 추론 학습
TRLM-135M은 `<think>` 태그를 활용하여 모델이 내부적으로 사고하는 과정을 학습합니다. 이는 단순한 패턴 매칭이 아닌 실제 추론 능력을 향상시킵니다.

### 2. DPO를 통한 추론 품질 향상
Direct Preference Optimization (DPO)를 통해 더 나은 추론 과정을 선호하도록 학습시켜, 추론의 정확성과 일관성을 높였습니다.

### 3. 소형 모델의 효율성
135M 파라미터로도 상당한 추론 능력을 보여주어, 리소스 제약이 있는 환경에서도 고품질 추론이 가능합니다.

## 연구적 의의

### 소형 모델의 가능성 확장
TRLM-135M은 소형 모델도 적절한 학습 방법을 통해 복잡한 추론 작업을 수행할 수 있음을 보여줍니다. 이는 에지 디바이스나 모바일 환경에서의 AI 활용 가능성을 넓혔습니다.

### 추론 학습 방법론
3단계 파이프라인은 추론 능력을 가진 소형 모델을 만드는 새로운 방법론을 제시합니다. 이는 향후 소형 모델 개발에 중요한 참고 자료가 될 것입니다.

## 한계점 및 주의사항

### 프로덕션 준비 상태
- **환각 현상**: 논리적 오류와 잘못된 정보 생성이 빈번함
- **소형 크기**: 제한된 일반 지식과 추론 깊이
- **영어 전용**: 다국어 능력은 탐구되지 않음

### 사용 시 고려사항
- 연구 및 실험 목적으로만 사용 권장
- 중요한 의사결정에는 사용하지 말 것
- 추가 검증 및 검토 필요

## 향후 발전 방향

### 1. 다국어 지원
현재 영어 전용인 모델을 다국어로 확장하여 글로벌 활용도를 높일 수 있습니다.

### 2. 도메인 특화
의료, 법률, 과학 등 특정 도메인에 특화된 추론 모델 개발이 가능합니다.

### 3. 효율성 개선
더 적은 파라미터로도 동일한 성능을 달성하는 방법 연구가 필요합니다.

## 결론

TRLM-135M은 소형 모델의 추론 능력 연구에 있어 중요한 이정표입니다. 135M 파라미터로도 상당한 추론 성능을 보여주며, 3단계 학습 파이프라인을 통해 소형 모델의 가능성을 확장했습니다.

특히 에지 컴퓨팅과 모바일 AI의 중요성이 커지는 현재, TRLM-135M과 같은 소형 추론 모델의 연구는 매우 의미가 있습니다. 향후 더욱 발전된 소형 추론 모델들이 등장할 것으로 기대됩니다.

## 참고 자료

- [TRLM-135M Hugging Face 모델 페이지](https://huggingface.co/Shekswess/trlm-135m)
- [SmolLM2-135M-Instruct 기반 모델](https://huggingface.co/HuggingFaceTB/SmolLM2-135M-Instruct)
- [TRL (Transformers Reinforcement Learning) 라이브러리](https://github.com/huggingface/trl)

---

**💡 팁**: TRLM-135M을 사용할 때는 추론 중심 작업에 `temperature=0.6`, `top_p=0.95` 설정을 권장합니다. 이를 통해 더 일관되고 논리적인 추론 결과를 얻을 수 있습니다.
