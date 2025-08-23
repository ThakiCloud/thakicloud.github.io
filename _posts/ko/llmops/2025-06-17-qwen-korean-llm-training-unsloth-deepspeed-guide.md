---
title: "Qwen 2.5 기반 한국어 LLM 학습 완벽 가이드: Unsloth vs DeepSpeed 비교"
excerpt: "Qwen 2.5-72B 모델을 한국어 데이터로 CPT-SFT-RLHF 파이프라인으로 학습하는 두 가지 방법을 상세히 비교 분석합니다."
date: 2025-06-17
categories: 
  - llmops
  - tutorials
tags: 
  - qwen
  - korean-llm
  - unsloth
  - deepspeed
  - fine-tuning
  - rlhf
  - korean-nlp
author_profile: true
toc: true
toc_label: "학습 가이드 목차"
---

대형 언어 모델(LLM)을 한국어 특화로 학습시키는 것은 많은 기업과 연구진이 관심을 갖는 주제입니다. 이 글에서는 **Qwen 2.5-72B(또는 7B) 기반 모델에 한국어 데이터를 집중 투입하여 CPT → SFT → RLHF 학습 스택**을 구현하는 두 가지 방법을 비교 분석합니다.

첫 번째는 **Unsloth**를 활용한 효율적인 학습 방법이고, 두 번째는 **DeepSpeed**를 사용한 대규모 분산 학습 방법입니다. 각각의 장단점과 적용 시나리오를 상세히 살펴보겠습니다.

## 두 방법론 비교 개요

| 특징 | Unsloth | DeepSpeed |
|------|---------|-----------|
| **메모리 효율성** | Flash-Attention 2 + QLoRA | ZeRO-3 + CPU Offload |
| **학습 속도** | 최적화된 Triton 커널 | 분산 병렬 처리 |
| **설정 복잡도** | 간단한 API | 상세한 JSON 설정 |
| **확장성** | 단일 노드 최적화 | 다중 노드 확장 |
| **적합한 환경** | 프로토타입, 중소 규모 | 대규모 운영 환경 |

## 공통 준비 작업

### 한국어 데이터셋 구축

두 방법 모두 동일한 데이터 전처리 과정을 거칩니다.

| 단계 | 설명 | 팁 |
|------|------|-----|
| **수집** | 웹 크롤·전자책·뉴스·정부문서·위키·도메인별 PDF 등 고품질 소스 확보 | **한국어 42% ± 5% / 영어 50% / 기타+코드 8%** 정도로 언어 균형 |
| **클렌징** | HTML 태그 제거 → 중복 제거 → 욕설/PII 필터링 | **exact-dup & near-dup**(SimHash) 권장 |
| **샘플링** | 분류기·키워드로 주제별 stratified sampling | 제조·코딩·금융 등 기업 도메인 강조 |
| **포맷** | ① Raw Text(CPT), ② Instruction JSON(SFT), ③ `{"chosen": …, "rejected": …}`(RLHF) 세 가지 규격으로 나눔 | 각 프레임워크별 포맷 가이드 참조 |

### 한국어 특화 토크나이저 적용

```bash
# SentencePiece 학습
spm_train --input=ko_corpus.txt --model_prefix=ko_sp --vocab_size=64000 \
          --character_coverage=0.9995 --model_type=bpe
```

```python
from transformers import AutoTokenizer, AutoModelForCausalLM

base = "Qwen/Qwen2.5-72B"
model = AutoModelForCausalLM.from_pretrained(base, device_map="auto", trust_remote_code=True)
tok = AutoTokenizer.from_pretrained("ko_sp.model", trust_remote_code=True)

# embedding 크기 확장
model.resize_token_embeddings(len(tok))
```

## 방법 1: Unsloth를 활용한 효율적 학습

### 환경 설정

```bash
conda create -n korean_llm_unsloth python=3.11 -y
conda activate korean_llm_unsloth
pip install "unsloth[flash]" transformers>=4.40 accelerate bitsandbytes sentencepiece datasets
```

`unsloth[flash]`는 Triton 커널과 Flash-Attention 2를 자동 활성화해 VRAM·속도를 최적화합니다.

### Continued Pre-Training (CPT)

```python
from unsloth import UnslothTrainer, LoraConfig
from datasets import load_dataset

dataset = load_dataset("json", data_files="cpt_raw.jsonl", streaming=True)

config = LoraConfig(target_modules="all-linear", r=64, lora_alpha=32, lora_dropout=0.05)
trainer = UnslothTrainer(
    model=model,
    tokenizer=tok,
    train_dataset=dataset,
    epochs=2,                         # 200B 토큰 ≒ 2 epoch
    max_seq_length=4096,
    learning_rate=1e-5,
    batch_size=2,
    gradient_accumulation=64,
    lora_config=config,
    optim="adamw_8bit",
)
trainer.train()
```

### Supervised Fine-Tuning (SFT)

```python
inst_ds = load_dataset("json", data_files="sft_inst.jsonl")

def format_func(example):
    return tok.apply_chat_template(
        [ {"role":"user", "content":example["instruction"]},
          {"role":"assistant", "content":example["output"]} ],
        tokenize=False, add_generation_prompt=False)

inst_ds = inst_ds.map(format_func, remove_columns=inst_ds.column_names)

trainer.update_dataset(inst_ds)
trainer.train(epochs=3, lr=2e-5, lora_dropout=0.1)
```

### RLHF (DPO)

```python
from unsloth import RLEngine, RLConfig

pref_ds = load_dataset("json", data_files="rlhf_pairs.jsonl")

rl = RLEngine(
    model=model,
    tokenizer=tok,
    rl_config=RLConfig(method="dpo", beta=0.1, reference_model="Qwen/Qwen2.5-72B"),
)
rl.train(pref_ds, epochs=1, batch_size=4, lr=1e-6)
```

### 모델 저장 및 배포

```python
# LoRA만 배포
model.save_pretrained_merged("korean_model_lora", tok, save_method="lora")

# 16-bit 병합 → vLLM
model.save_pretrained_merged("korean_model_full", tok, save_method="merged_16bit")
```

## 방법 2: DeepSpeed를 활용한 대규모 분산 학습

### 환경 설정

```bash
conda create -n korean_llm_deepspeed python=3.11 -y
conda activate korean_llm_deepspeed
pip install deepspeed==0.14.2 transformers>=4.40 accelerate datasets sentencepiece bitsandbytes trl
```

### DeepSpeed 구성 (ZeRO-3 + Offload)

`ds_zero3.json`:

```json
{
  "fp16": { "enabled": true },
  "zero_optimization": {
    "stage": 3,
    "offload_param": { "device": "cpu", "pin_memory": true },
    "offload_optimizer": { "device": "cpu", "pin_memory": true },
    "overlap_comm": true,
    "contiguous_gradients": true
  },
  "train_batch_size": 256,
  "train_micro_batch_size_per_gpu": 2,
  "gradient_accumulation_steps": 64,
  "gradient_checkpointing": true,
  "wall_clock_breakdown": false
}
```

### Continued Pre-Training (CPT)

```python
from datasets import load_dataset
from transformers import Trainer, TrainingArguments

raw_ds = load_dataset("json", data_files="cpt_raw.jsonl")

args = TrainingArguments(
    output_dir="korean_cpt",
    per_device_train_batch_size=2,
    gradient_accumulation_steps=64,
    learning_rate=1e-5,
    num_train_epochs=2,
    fp16=True,
    deepspeed="ds_zero3.json",
    logging_steps=10,
    save_strategy="epoch"
)

trainer = Trainer(model=model, args=args, train_dataset=raw_ds)
trainer.train()
```

### Supervised Fine-Tuning (SFT)

```python
inst_ds = load_dataset("json", data_files="sft_inst.jsonl")

def preprocess(ex):
    return tok.apply_chat_template(
        [{"role":"user","content":ex["instruction"]},
         {"role":"assistant","content":ex["output"]}],
        tokenize=False)

inst_ds = inst_ds.map(preprocess, remove_columns=inst_ds.column_names)

args = args.replace(
    output_dir="korean_sft",
    learning_rate=2e-5,
    num_train_epochs=3
)
trainer.train_dataset = inst_ds
trainer.train()
```

### RLHF - DPO

```python
from trl import DPOTrainer, DPOConfig

pref_ds = load_dataset("json", data_files="rlhf_pairs.jsonl")

dpo_args = DPOConfig(
    output_dir="korean_dpo",
    per_device_train_batch_size=4,
    learning_rate=1e-6,
    num_train_epochs=1,
    deepspeed="ds_zero3.json"
)

trainer = DPOTrainer(
    model=model, 
    args=dpo_args,
    tokenizer=tok, 
    train_dataset=pref_ds,
    beta=0.1, 
    reference_model="Qwen/Qwen2.5-72B"
)
trainer.train()
```

### 실행 방법

```bash
# 단일 노드
accelerate launch train_script.py

# 다중 노드 (사전에 accelerate config 설정 필요)
accelerate launch --config_file multi_node.yaml train_script.py
```

## 성능 검증 및 벤치마크

### 평가 기준

| 벤치마크 | 스크립트 예시 | 목표 |
|----------|---------------|------|
| **KMMLU** | `lm_eval --model hf --model_args pretrained=korean_model --tasks kmmlu --device cuda` | ≥ 78 |
| **CLIcK** | 공개 repo `click_eval` 사용 | ≥ 83 |
| **Ko-IFEval** | 사내 prompt-suite 실행 | ≥ 78 |

### 성능 최적화 방법

성능이 목표치 미달인 경우 다음 순서로 조정합니다:

1. **데이터 샘플 재균형**
2. **SFT epoch 추가**
3. **LoRA r/α 조정** (Unsloth)
4. **RL β 값 재탐색**

## 방법별 장단점 분석

### Unsloth의 장점

- **간단한 설정**: 복잡한 분산 설정 없이 바로 시작 가능
- **메모리 효율성**: Flash-Attention 2와 QLoRA로 메모리 사용량 최소화
- **빠른 프로토타이핑**: 실험과 검증을 빠르게 진행 가능
- **통합 API**: CPT, SFT, RLHF를 동일한 인터페이스로 처리

### Unsloth의 단점

- **확장성 제한**: 단일 노드 환경에 최적화
- **커스터마이징 제약**: 내부 최적화로 인한 세밀한 제어 어려움

### DeepSpeed의 장점

- **뛰어난 확장성**: 다중 노드, 다중 GPU 환경에서 선형 확장
- **메모리 최적화**: ZeRO 단계별 메모리 분산으로 대용량 모델 학습 가능
- **유연한 설정**: JSON 설정을 통한 세밀한 튜닝 가능
- **생태계 호환성**: HuggingFace 생태계와 완벽 호환

### DeepSpeed의 단점

- **설정 복잡성**: 초기 설정과 디버깅이 복잡
- **학습 곡선**: 최적 성능을 위해서는 깊은 이해 필요

## 선택 가이드

### Unsloth를 선택해야 하는 경우

- **빠른 프로토타이핑**이 필요한 경우
- **단일 노드 환경**에서 작업하는 경우
- **간단한 설정**을 선호하는 경우
- **중소 규모 데이터셋**으로 실험하는 경우

### DeepSpeed를 선택해야 하는 경우

- **대규모 운영 환경**에서 학습하는 경우
- **다중 노드 확장**이 필요한 경우
- **세밀한 메모리 제어**가 필요한 경우
- **기존 HuggingFace 파이프라인**과 통합하는 경우

## 전체 워크플로 요약

### 공통 단계

1. **데이터 확보·정제 → 3단계 포맷 분리**
2. **한국어 SentencePiece 64K 학습 → 토크나이저 적용**

### 학습 단계

3. **CPT** (2 epoch, 4K context, 1e-5 learning rate)
4. **SFT** (3 epoch, 4K context, 2e-5 learning rate)
5. **RLHF** (DPO β 0.1, 1 epoch)

### 검증 및 배포

6. **모델 저장** (LoRA 또는 16-bit 병합)
7. **벤치마크 검증 & 하이퍼파라미터 튜닝**
8. **vLLM 서빙 배포**

## 결론

Qwen 2.5 기반 한국어 LLM 학습을 위한 두 가지 방법을 살펴보았습니다. **Unsloth**는 빠른 실험과 프로토타이핑에 적합하고, **DeepSpeed**는 대규모 운영 환경에서의 안정적인 학습에 적합합니다.

두 방법 모두 **한국어 토큰 효율성과 기업용 보안 요건**을 충족하는 고품질 모델을 만들 수 있습니다. 프로젝트의 규모와 요구사항에 따라 적절한 방법을 선택하시기 바랍니다.

필요에 따라 각 단계의 스크립트와 YAML 설정을 더 세분화하여 CI/CD 및 MLflow 파이프라인에 통합할 수 있습니다.
