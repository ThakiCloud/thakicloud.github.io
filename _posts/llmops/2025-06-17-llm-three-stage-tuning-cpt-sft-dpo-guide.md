---
title: "LLM 3단계 튜닝 완벽 가이드: CPT → SFT → DPO 파이프라인"
excerpt: "폭넓게 적응(CPT) → 정확히 가르치기(SFT) → 사람 취향 맞추기(DPO)의 3단계 순차 튜닝으로 똑똑하면서도 인간 친화적인 LLM을 만드는 검증된 전략을 알아봅니다."
date: 2025-06-17
categories:
  - llmops
  - tutorials
tags:
  - LLM
  - fine-tuning
  - CPT
  - SFT
  - DPO
  - machine-learning
  - AI
author_profile: true
toc: true
toc_label: "3단계 LLM 튜닝 가이드"
---

## 핵심 요약

**"폭넓게 적응(CPT) → 정확히 가르치기(SFT) → 사람 취향 맞추기(DPO)"**

현대 LLM 파인튜닝의 황금 공식은 다음과 같습니다:

1. **Continued Pre-Training (CPT)** 2 epoch(1e-5)으로 거대한 한국어 코퍼스를 '원서 통독'하듯 다시 읽혀 **도메인·언어 적응**을 시킵니다.
2. **Supervised Fine-Tuning (SFT)** 3 epoch(2e-5)으로 수만 건의 "질문-답변" 예시를 보고 **정확한 형식·내용**을 학습합니다.
3. **Direct Preference Optimization (DPO)** 1 epoch(β 0.1)으로 "좋은 답↔나쁜 답" 쌍을 비교해 **사람이 선호하는 스타일**로 미세 조정합니다.

이 **3-단계, 저→고 학습률 순서**가 모델의 **지식 보존·안정성·효율**을 동시에 만족시키는 현대 LLM 표준 파이프라인입니다.

## Continued Pre-Training (CPT) → "배경지식과 언어 감각 다지기"

### 왜 CPT를 1단계로 두나?

**도메인·언어 적응**: 원본 Qwen 2.5는 다국어 일반지식 위주지만, 한국어·기업 도메인 데이터를 추가로 돌려 **용어·표현 분포를 맞춤**합니다.

**지식 저수 확장**: CPT는 여전히 "다음 토큰 맞히기" 목적이어서 **모델 구조를 건드리지 않고** 새로운 패턴을 흡수합니다.

**망각 완화**: 선행 연구는 CPT가 뒤이은 튜닝 단계에서 **catastrophic forgetting을 줄여** 기반지식을 보존한다고 보고하고 있습니다.

### 2 epoch & 1e-5 학습률이 적절한 이유

| 결정 요소      | 설명                                                                              |
| ---------- | ------------------------------------------------------------------------------- |
| **데이터 규모** | 수십~수백 GB를 두 번만 도는 **2 epoch**가 통상 "지식 포화 vs. 비용" 균형점                          |
| **안정 학습률** | 1e-5는 거대 매개변수 모델에서 **발산 위험 없이** 가중치를 천천히 이동시키는 범용 값                        |

## Supervised Fine-Tuning (SFT) → "정답 예시로 형식과 논리를 가르치기"

### CPT 다음에 SFT를 붙이는 이유

**형식·문체 정렬**: CPT로 폭넓게 배운 뒤, 레이블이 달린 인스트럭션-응답 데이터로 **"질문엔 이렇게 답한다"** 규칙을 주입합니다.

**다중 과제 전이**: SFT가 모델의 **태스크-어웨어 능력**(요약·번역·코딩)을 한 번에 끌어올린다는 것이 InstructGPT 실험에서 확인되었습니다.

### 3 epoch & 2e-5는 왜 무난한가

- **데이터가 작다**: 수십만 샘플이라 **여러 번 반복**해야 충분히 수렴합니다.
- **조금 높은 학습률**: CPT로 안정화된 가중치 위에서 2e-5 정도는 **빠른 수렴**과 **과적합 방지** 사이의 경험적 sweet-spot입니다.

## Direct Preference Optimization (DPO) → "사람 취향에 맞춘 마지막 한 끗"

### SFT 후에 DPO를 넣는 까닭

**SFT 한계를 보완**: SFT는 "정답"만 보고 배워 **창의·안전성 균형**이 부족할 수 있습니다. DPO는 **좋은 vs. 나쁜** 응답을 비교해 인간 선호를 직접 최대화합니다.

**PPO보다 가볍다**: DPO는 KL-페널티 형태의 **단순 분류 손실**만 쓰므로 샘플링·튜닝 부담이 적습니다.

### 1 epoch & β = 0.1 하이퍼파라미터 근거

| 요소            | 해설                                                                                |
| ------------- | --------------------------------------------------------------------------------- |
| **데이터 중복 회피** | 페어 데이터는 상대적으로 적어 **1 epoch로도 수렴**하며, 더 돌리면 과적합 위험                              |
| **β = 0.1**   | β는 **선호 손실 ↔ 원래 분포(KL)** 가중치. 논문·HF 실험에서 0.05-0.2 범위가 안정적이며, 0.1이 **기본 추천값** |

## 순서가 중요하다 — 층층이 쌓는 "지식 → 규칙 → 가치" 피라미드

1. **지식·언어 감각(CPT)** 없이는 뒤 단계가 얕은 기반 위에 서게 됩니다.
2. **형식·문제 해결 능력(SFT)**을 먼저 확립해야, 선호 학습에서 **"좋은 답"의 기준**이 명확해집니다.
3. **선호 정렬(DPO)**은 가장 파괴적(hard constraint)이라 마지막에 살짝 조정해야 **성과 상승 + 과도한 변화 억제**를 동시에 달성합니다.

## 실무 적용 체크리스트

### 과적합 신호와 대응 방법

| 단계  | 과적합 신호                               | 대응                 |
| --- | ------------------------------------ | ------------------ |
| CPT | training-loss 급락·valid perplexity 반등 | epoch ↓ 또는 학습률↓    |
| SFT | 특정 템플릿 외 답변 길이 급변                    | 데이터 다변화, dropout↑  |
| DPO | 과감한 "죄송" 남발·안전 과최적화                  | β 조정(↑0.2), 페어 다양화 |

### 하이퍼파라미터 권장값

```python
# CPT 단계
cpt_config = {
    "epochs": 2,
    "learning_rate": 1e-5,
    "batch_size": 32,
    "gradient_accumulation_steps": 4
}

# SFT 단계
sft_config = {
    "epochs": 3,
    "learning_rate": 2e-5,
    "batch_size": 16,
    "gradient_accumulation_steps": 8
}

# DPO 단계
dpo_config = {
    "epochs": 1,
    "beta": 0.1,
    "learning_rate": 5e-7,
    "batch_size": 8
}
```

## 실제 파이프라인 구현 예시

### 1단계: CPT 구현

```python
from transformers import AutoModelForCausalLM, AutoTokenizer
from datasets import load_dataset

# 모델 로드
model = AutoModelForCausalLM.from_pretrained("Qwen/Qwen2.5-7B")
tokenizer = AutoTokenizer.from_pretrained("Qwen/Qwen2.5-7B")

# 한국어 도메인 데이터셋 준비
korean_corpus = load_dataset("your_korean_corpus")

# CPT 설정
training_args = TrainingArguments(
    output_dir="./cpt_checkpoints",
    num_train_epochs=2,
    learning_rate=1e-5,
    per_device_train_batch_size=32,
    gradient_accumulation_steps=4,
    warmup_steps=1000,
    logging_steps=100,
    save_steps=5000,
)
```

### 2단계: SFT 구현

```python
# 인스트럭션 데이터셋 준비
instruction_dataset = load_dataset("your_instruction_dataset")

# SFT 설정
sft_args = TrainingArguments(
    output_dir="./sft_checkpoints",
    num_train_epochs=3,
    learning_rate=2e-5,
    per_device_train_batch_size=16,
    gradient_accumulation_steps=8,
    warmup_steps=500,
    logging_steps=50,
    save_steps=2000,
)
```

### 3단계: DPO 구현

```python
from trl import DPOTrainer

# 선호 데이터셋 준비 (chosen/rejected 쌍)
preference_dataset = load_dataset("your_preference_dataset")

# DPO 설정
dpo_args = TrainingArguments(
    output_dir="./dpo_checkpoints",
    num_train_epochs=1,
    learning_rate=5e-7,
    per_device_train_batch_size=8,
    gradient_accumulation_steps=1,
    beta=0.1,
    logging_steps=25,
    save_steps=1000,
)

# DPO 트레이너 초기화
dpo_trainer = DPOTrainer(
    model=model,
    ref_model=ref_model,
    args=dpo_args,
    train_dataset=preference_dataset,
    tokenizer=tokenizer,
    beta=0.1
)
```

## 모니터링과 평가 지표

### 각 단계별 핵심 지표

**CPT 단계**:
- Perplexity 변화
- Loss curve 안정성
- 도메인 특화 벤치마크 성능

**SFT 단계**:
- Instruction following 정확도
- 다양한 태스크 성능 균형
- 응답 형식 일관성

**DPO 단계**:
- 인간 평가 선호도
- Helpfulness vs. Harmlessness 균형
- 과도한 거부 패턴 모니터링

## 요약

> **"지식(2 epoch·1e-5) → 규칙(3 epoch·2e-5) → 가치(1 epoch·β 0.1)" 순차 튜닝**이 LLM을 **똑똑하면서도 인간 친화적**으로 만드는 데 가장 검증된 계단식 전략입니다.

이 3단계 파이프라인은 단순히 기술적 프로세스가 아니라, 인간의 학습 과정을 모방한 체계적인 접근법입니다. 기초 지식을 탄탄히 다진 후, 구체적인 규칙을 학습하고, 마지막으로 가치 판단을 내재화하는 과정을 통해 진정으로 유용한 AI 모델을 만들 수 있습니다.

## 참고 자료

- [Fine-tuning large language models for domain adaptation](https://arxiv.org/abs/2409.03444)
- [Continuing Pre-Training on Raw Text](https://mccormickml.com/2025/01/18/continuing-pre-training-on-raw-text/)
- [DPO Trainer Documentation](https://huggingface.co/docs/trl/main/en/dpo_trainer)
- [Supervised Fine Tuning for Gemini](https://cloud.google.com/blog/products/ai-machine-learning/master-gemini-sft) 