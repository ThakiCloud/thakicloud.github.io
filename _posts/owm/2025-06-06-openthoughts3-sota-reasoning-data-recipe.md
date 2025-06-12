---
title: "OpenThoughts3: 추론 모델의 새로운 SOTA 데이터 레시피"
date: 2025-06-06
categories: 
  - owm
  - ai
tags: 
  - openthoughts3
  - reasoning
  - dataset
  - llm
  - sota
  - supervised-finetuning
author_profile: true
toc: true
toc_label: "목차"
---

수학, 코딩, 과학 분야의 추론 능력에서 새로운 기준을 제시하는 [OpenThoughts3](https://www.openthoughts.ai/blog/ot3)이 공개되었습니다. OpenThinker3-7B 모델은 해당 규모에서 SOTA 오픈 데이터 추론 모델로, 강화학습 없이 순수 지도학습만으로 놀라운 성능을 달성했습니다.

## 🚀 OpenThinker3-7B 성능 개요

OpenThinker3-7B는 다양한 추론 벤치마크에서 기존 모델들을 크게 앞서는 성능을 보여줍니다:

- **AIME 2025**: 53% (DeepSeek-R1-Distill 대비 +15.3%p)
- **LiveCodeBench 06/24-01/25**: 51.7% (+17.2%p)
- **GPQA Diamond**: 53.7% (+20.5%p)

### 상세 벤치마크 비교

| 모델 | HMMT | AIME25 | LCB 06/24-01/25 | CodeForces | GPQA-D | JEEBench |
|------|------|--------|-----------------|-----------|--------|----------|
| **OpenThinker3-7B** | **42.7** | **53.3** | **51.7** | **32.2** | **53.7** | **72.4** |
| DS-R1-Distill-7B | 25.0 | 38.0 | 34.5 | 21.1 | 33.2 | 50.4 |
| OpenR1-Distill-7B | 26.7 | 48.0 | 50.9 | **32.9** | **52.9** | 70.7 |
| Nemotron-Nano | 33.3 | **50.7** | 44.3 | 30.9 | **52.9** | 64.3 |
| AceReason | 32.7 | 47.3 | 43.8 | 32.5 | 50.2 | 55.3 |
| Qwen2.5-7B-Instruct | 2.0 | 8.0 | 16.3 | 10.2 | 24.6 | 33.9 |

*굵은 값은 최고 성능 모델의 2 표준편차 내에 있는 값들입니다.*

## 🧠 핵심 혁신: OpenThoughts3-1.2M 데이터셋

OpenThinker3-7B의 뛰어난 성능은 **OpenThoughts3-1.2M** 데이터셋에 기반합니다:

### 데이터셋 구성
- **총 120만 개** 질문-답변 쌍
- **수학**: 85만 개 (70.8%)
- **코딩**: 25만 개 (20.8%)
- **과학**: 10만 개 (8.3%)
- **추론 trace**: QwQ-32B로 생성된 추론 과정 포함

### 학습 방식
- **순수 지도학습(SFT)**: 강화학습 없이 supervised fine-tuning만 사용
- **QwQ-32B 교사 모델**: 추론 trace 생성을 위한 강력한 교사 모델
- **1000+ 실험**: 데이터 생성 파이프라인의 각 단계별 엄격한 실험

## 🔬 데이터 파이프라인 최적화

OpenThoughts3는 다음 6단계의 데이터 생성 파이프라인을 체계적으로 최적화했습니다:

### 1. 질문 소싱 (Question Sourcing)
고품질 문제 데이터셋에서 다양한 난이도의 질문 수집

### 2. 질문 믹싱 (Question Mixing)
수학, 코딩, 과학 도메인 간 균형 잡힌 조합

### 3. 질문 필터링 (Question Filtering)
LLM 기반 난이도 평가 및 품질 검증

### 4. 다중 답변 생성 (Multiple Answers Generation)
질문당 여러 개의 답변을 교사 모델에서 샘플링

### 5. 답변 필터링 (Answer Filtering)
생성된 답변의 품질 평가 및 선별

### 6. 교사 모델 선택 (Teacher Model Selection)
최적의 교사 모델 실험적 검증

## 💡 핵심 발견 사항

1000+ 실험을 통해 도출된 중요한 인사이트들:

### 1. 다중 샘플링의 효과
- **질문당 여러 답변 샘플링**이 데이터 크기를 **최소 16배** 증가시키는 효과적 기법
- 단순 데이터 증강을 넘어서는 품질 향상 효과

### 2. 교사 모델 선택의 중요성
- **QwQ-32B**가 DeepSeek-R1보다 더 강력한 교사 모델
- 벤치마크 점수가 높다고 항상 좋은 교사는 아님
- JEEBench 등 타겟 추론 벤치마크에서 DeepSeek-R1이 더 높은 점수에도 불구

### 3. 검증 방법의 한계
- 다양한 검증 및 답변 필터링 방법 실험
- **대부분의 필터링 방법이 유의미한 성능 향상을 주지 않음**
- 단순한 품질 기준이 오히려 효과적

### 4. 소수 정예 vs 다양성
- **소수(1-2개)의 고품질 소스** 선택이 효과적
- 다양성 추구(8-16개 소스)보다 품질 집중이 우수
- 데이터 큐레이션에서 품질 > 다양성

### 5. 효과적인 필터링 기준
- **LLM 라벨링된 난이도** 기반 필터링
- **LLM 응답 길이** 기반 필터링
- 임베딩이나 fastText 같은 전통적 전처리 필터보다 우수

## 📈 스케일링의 힘

OpenThoughts 시리즈의 진화 과정에서 스케일링의 중요성이 입증되었습니다:

### 데이터셋 진화
1. **Bespoke-Stratos**: 17K 샘플
2. **OpenThoughts**: 114K 샘플  
3. **OpenThoughts2**: 1M 샘플
4. **OpenThoughts3**: 1.2M 샘플

### 스케일링 효과
- 데이터셋 크기 증가에 따른 **지속적인 성능 향상**
- "More-is-More" 패러다임의 추론 분야 적용
- 기존 SOTA 오픈 추론 데이터셋(AM, Nemotron Nano) 대비 우수한 성능

## 🛠️ 활용 방법

### 모델 및 데이터 접근

**Hugging Face 리소스**
- [OpenThinker3-7B 모델](https://huggingface.co/open-thoughts/OpenThinker3-7B)
- [OpenThoughts3-1.2M 데이터셋](https://huggingface.co/datasets/open-thoughts/OpenThoughts3-1.2M)

**연구 자료**
- ArXiv 논문: 상세한 방법론 및 실험 결과
- OpenThoughts 저장소: 데이터 처리 코드
- Evalchemy 저장소: 평가 코드

### 실제 적용 예시

```python
from transformers import AutoTokenizer, AutoModelForCausalLM

# OpenThinker3-7B 모델 로드
tokenizer = AutoTokenizer.from_pretrained("open-thoughts/OpenThinker3-7B")
model = AutoModelForCausalLM.from_pretrained("open-thoughts/OpenThinker3-7B")

# 추론 문제 해결
problem = "A triangle has sides of length 3, 4, and 5. What is its area?"
inputs = tokenizer(problem, return_tensors="pt")
outputs = model.generate(**inputs, max_new_tokens=512, do_sample=False)
solution = tokenizer.decode(outputs[0], skip_special_tokens=True)
```

## 🔮 향후 계획

### 확장 로드맵
- **32B 모델 개발**: OpenThinker3-7B의 32B 버전 계획
- **파이프라인 스케일링**: 더 큰 규모의 데이터셋 구축
- **도메인 확장**: 추가 전문 분야로의 확장

### 커뮤니티 기여
- **완전 오픈소스**: 모든 연구 산출물 공개
- **재현 가능성**: 실험 코드 및 데이터 제공
- **협업 연구**: 커뮤니티와 함께하는 발전

## 🌟 OpenThoughts3의 의의

### 1. **순수 지도학습의 가능성**
- 강화학습 없이도 SOTA 성능 달성
- 훨씬 간단하고 안정적인 학습 파이프라인
- 계산 비용 및 복잡성 대폭 감소

### 2. **체계적 실험의 중요성**
- 1000+ 실험을 통한 과학적 접근
- 각 단계별 정량적 검증
- 직관에 반하는 발견들의 가치

### 3. **오픈 연구 생태계 기여**
- 완전한 투명성과 재현성
- 커뮤니티 기반 발전 모델
- 연구 접근성 대폭 향상

### 4. **실용적 성능 향상**
- 기존 모델 대비 15-20%p 성능 향상
- 다양한 추론 도메인에서 일관된 우수성
- 실제 활용 가능한 수준의 모델

## 🚀 마무리

OpenThoughts3는 추론 모델 개발에 새로운 패러다임을 제시합니다. 복잡한 강화학습 대신 **체계적인 데이터 큐레이션**과 **대규모 지도학습**으로 SOTA 성능을 달성했다는 점에서 매우 의미 있는 성과입니다.

특히 QwQ-32B라는 강력한 교사 모델을 활용하여 고품질 추론 trace를 대량 생성하고, 1000회 이상의 엄격한 실험을 통해 최적의 데이터 파이프라인을 구축한 것은 앞으로의 추론 모델 연구에 중요한 참고점이 될 것입니다.

모든 연구 산출물이 오픈소스로 공개되어 있어, 연구 커뮤니티의 추가 발전을 기대할 수 있습니다. 32B 버전의 후속 모델 개발도 계획되어 있어, 추론 모델 분야의 지속적인 발전이 예상됩니다.

### 참고 자료

- [OpenThoughts3 공식 블로그](https://www.openthoughts.ai/blog/ot3)
- [OpenThinker3-7B 모델](https://huggingface.co/open-thoughts/OpenThinker3-7B)
- [OpenThoughts3-1.2M 데이터셋](https://huggingface.co/datasets/open-thoughts/OpenThoughts3-1.2M)
- ArXiv 논문: "OpenThoughts: Data Recipes for Reasoning Models" 