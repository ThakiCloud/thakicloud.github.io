---
title: "PEFT: 대형 모델을 0.2%만 학습해도 전체 파인튜닝 성능을 내는 혁신 기술"
excerpt: "LoRA, AdaLoRA, IA3 등 최신 PEFT 기법으로 메모리는 80% 절약하면서 성능은 그대로. Llama, BERT, Stable Diffusion까지 모든 모델에 적용 가능"
date: 2025-05-30
categories:
  - llmops
tags:
  - PEFT
  - LoRA
  - AdaLoRA
  - IA3
  - PromptTuning
  - 파라미터효율학습
  - HuggingFace
  - 메모리최적화
  - 파인튜닝
author_profile: true
toc: true
toc_label: "PEFT 완전 가이드"
---

> **TL;DR** [PEFT (Parameter-Efficient Fine-Tuning)](https://github.com/huggingface/peft)는 🤗Hugging Face의 **파라미터 효율적 파인튜닝 라이브러리**다. LoRA, AdaLoRA, IA3 등을 통해 **전체 파라미터의 0.2%만 학습**해도 전체 파인튜닝과 **동등한 성능**을 달성한다. **1만 8천 개 이상의 GitHub 스타**를 받으며 메모리 부족 문제를 해결하는 업계 표준 솔루션이 되었다.

---

## PEFT란?

[PEFT (Parameter-Efficient Fine-Tuning)](https://github.com/huggingface/peft)는 대형 사전훈련 모델의 **극소수 파라미터만 학습**하여 다양한 하위 태스크에 효율적으로 적응시키는 혁신적인 기술이다. **1만 8천 개 이상의 GitHub 스타**를 받으며 현재 AI 업계에서 가장 주목받는 파인튜닝 방법론이다.

### 핵심 개념

- **극소수 파라미터 학습**: 전체 모델의 0.1-1%만 업데이트
- **성능 유지**: 전체 파인튜닝과 동등하거나 더 나은 성능
- **메모리 효율성**: GPU 메모리 사용량 80% 이상 절약
- **저장 공간 절약**: 체크포인트 크기를 GB에서 MB로 축소
- **다중 태스크 지원**: 하나의 모델로 여러 어댑터 관리

## 왜 PEFT를 써야 할까?

### 메모리 혁명

A100 80GB GPU 기준 실제 메모리 사용량 비교:

| 모델 | 전체 파인튜닝 | PEFT-LoRA | PEFT-LoRA + DeepSpeed |
|------|-------------|-----------|---------------------|
| T0-3B (3B) | 47.14GB GPU | 14.4GB GPU | 9.8GB GPU |
| MT0-XXL (12B) | **OOM** | 56GB GPU | 22GB GPU |
| BLOOMZ-7B (7B) | **OOM** | 32GB GPU | 18.1GB GPU |

### 성능 비교

Twitter 컴플레인 분류 태스크 결과:

| 방법 | 정확도 | 체크포인트 크기 |
|------|--------|---------------|
| 인간 기준선 | 0.897 | - |
| Flan-T5 (전체) | 0.892 | 11GB |
| **LoRA T0-3B** | **0.863** | **19MB** |

### 실제 도입 사례

**주요 기업들의 PEFT 활용:**

- **OpenAI**: GPT-4 맞춤 학습에 LoRA 변형 사용
- **Google**: PaLM, Gemini 모델의 도메인 적응
- **Meta**: Llama 2 시리즈의 instruction tuning
- **Microsoft**: Azure OpenAI의 커스텀 모델 서비스
- **Stability AI**: Stable Diffusion 커스터마이징

## 설치 및 빠른 시작

### 설치

```bash
pip install peft
```

### 30초 QuickStart

```python
from transformers import AutoModelForSeq2SeqLM
from peft import get_peft_config, get_peft_model, LoraConfig, TaskType

# 모델 로드
model = AutoModelForSeq2SeqLM.from_pretrained("bigscience/mt0-large")

# LoRA 설정 (0.19%만 학습!)
peft_config = LoraConfig(
    task_type=TaskType.SEQ_2_SEQ_LM,
    inference_mode=False,
    r=8,
    lora_alpha=32,
    lora_dropout=0.1
)

# PEFT 모델 생성
model = get_peft_model(model, peft_config)
model.print_trainable_parameters()
# "trainable params: 2,359,296 || all params: 1,231,940,608 || trainable%: 0.19%"
```

### 추론용 모델 로드

```python
from peft import AutoPeftModelForCausalLM
from transformers import AutoTokenizer

# 학습된 PEFT 모델 로드
model = AutoPeftModelForCausalLM.from_pretrained("ybelkada/opt-350m-lora")
tokenizer = AutoTokenizer.from_pretrained("facebook/opt-350m")

# 추론 실행
inputs = tokenizer("레시피: 오븐을 350도로 예열하고", return_tensors="pt")
outputs = model.generate(**inputs, max_new_tokens=50)
print(tokenizer.decode(outputs[0], skip_special_tokens=True))
```

## 주요 PEFT 방법론 상세 가이드

### LoRA (Low-Rank Adaptation)

**LoRA**는 가장 널리 사용되는 PEFT 방법으로, 기존 가중치를 고정하고 저차원 행렬을 추가한다.

#### 수학적 원리

기존 가중치 행렬 W에 대해:

```
W_new = W + BA
```

여기서:

- W: 원래 가중치 (고정)
- B: r×d 행렬
- A: k×r 행렬  
- r: 랭크 (보통 8-64)

#### 실습 예제

```python
from peft import LoraConfig, get_peft_model
from transformers import AutoModelForCausalLM

# 모델 로드
model = AutoModelForCausalLM.from_pretrained("microsoft/DialoGPT-medium")

# LoRA 설정
lora_config = LoraConfig(
    r=16,  # 랭크 설정
    lora_alpha=32,  # 스케일링 파라미터
    target_modules=["c_attn", "c_proj"],  # 타겟 모듈
    lora_dropout=0.1,
    bias="none",
    task_type="CAUSAL_LM"
)

# LoRA 적용
model = get_peft_model(model, lora_config)
print(f"학습 가능한 파라미터: {model.num_parameters(only_trainable=True):,}")
```

#### 하이퍼파라미터 가이드

```python
# 보수적 설정 (안정적, 메모리 절약)
conservative_config = LoraConfig(
    r=8,
    lora_alpha=16,
    lora_dropout=0.1
)

# 공격적 설정 (더 높은 성능, 더 많은 파라미터)
aggressive_config = LoraConfig(
    r=64,
    lora_alpha=128,
    lora_dropout=0.05
)
```

### AdaLoRA (Adaptive LoRA)

**AdaLoRA**는 중요도에 따라 랭크를 동적으로 조정하는 개선된 LoRA 방법이다.

#### 핵심 아이디어

- **적응적 랭크**: 각 어댑터 모듈마다 다른 랭크 사용
- **중요도 점수**: SVD 기반으로 중요도 계산
- **가지치기**: 덜 중요한 특이값 제거

#### 실습 예제

```python
from peft import AdaLoraConfig, get_peft_model

adalora_config = AdaLoraConfig(
    init_r=12,  # 초기 랭크
    target_r=8,  # 목표 랭크
    beta1=0.85,  # 지수 이동 평균 계수
    beta2=0.85,
    tinit=200,  # 워밍업 스텝
    tfinal=1000,  # 가지치기 완료 스텝
    deltaT=10,   # 업데이트 간격
    lora_alpha=32,
    lora_dropout=0.1,
    target_modules=["q_proj", "v_proj"],
    task_type="CAUSAL_LM"
)

model = get_peft_model(model, adalora_config)
```

### IA3 (Infused Adapter by Inhibiting and Amplifying Inner Activations)

**IA3**는 가중치를 추가하는 대신 기존 활성화를 스케일링하는 방법이다.

#### 핵심 특징

- **가중치 없음**: 새로운 가중치 행렬 추가 없음
- **활성화 스케일링**: 키, 값, 피드포워드 활성화를 스케일링
- **극소 파라미터**: LoRA보다도 적은 파라미터 사용

#### 실습 예제

```python
from peft import IA3Config, get_peft_model

ia3_config = IA3Config(
    target_modules=["k_proj", "v_proj", "down_proj"],
    feedforward_modules=["down_proj"],
    task_type="CAUSAL_LM"
)

model = get_peft_model(model, ia3_config)
print(f"학습 가능한 파라미터: {model.num_parameters(only_trainable=True):,}")
# LoRA보다 10배 적은 파라미터!
```

### Prompt Tuning

**Prompt Tuning**은 입력에 학습 가능한 소프트 프롬프트를 추가하는 방법이다.

#### 실습 예제

```python
from peft import PromptTuningConfig, get_peft_model

prompt_config = PromptTuningConfig(
    task_type="CAUSAL_LM",
    prompt_tuning_init="TEXT",  # 텍스트로 초기화
    num_virtual_tokens=20,  # 프롬프트 토큰 수
    prompt_tuning_init_text="다음은 고품질 응답입니다:",
    tokenizer_name_or_path="gpt2"
)

model = get_peft_model(model, prompt_config)
```

### P-Tuning v2

**P-Tuning v2**는 모든 레이어에 학습 가능한 프롬프트를 추가하는 방법이다.

```python
from peft import PromptEncoderConfig, get_peft_model

p_tuning_config = PromptEncoderConfig(
    task_type="CAUSAL_LM",
    num_virtual_tokens=20,
    encoder_hidden_size=128
)

model = get_peft_model(model, p_tuning_config)
```

## 실제 활용 사례 심화 분석

### 사례 1: ChatGPT 스타일 대화 모델

```python
from transformers import AutoModelForCausalLM, AutoTokenizer, TrainingArguments
from peft import LoraConfig, get_peft_model
from trl import SFTTrainer
from datasets import load_dataset

# Llama 2 7B 모델로 ChatGPT 스타일 학습
model_name = "meta-llama/Llama-2-7b-hf"
model = AutoModelForCausalLM.from_pretrained(
    model_name,
    load_in_4bit=True,  # 4비트 양자화로 메모리 절약
    device_map="auto"
)

# LoRA 설정
lora_config = LoraConfig(
    r=64,
    lora_alpha=16,
    target_modules=[
        "q_proj", "k_proj", "v_proj", "o_proj",
        "gate_proj", "up_proj", "down_proj"
    ],
    lora_dropout=0.1,
    bias="none",
    task_type="CAUSAL_LM"
)

model = get_peft_model(model, lora_config)

# 대화 데이터셋 로드
dataset = load_dataset("OpenAssistant/oasst1", split="train")

# 학습 설정
training_args = TrainingArguments(
    output_dir="./llama-chat-lora",
    num_train_epochs=3,
    per_device_train_batch_size=4,
    gradient_accumulation_steps=4,
    warmup_ratio=0.1,
    learning_rate=2e-4,
    logging_steps=25,
    save_steps=500,
    evaluation_strategy="steps",
    eval_steps=500
)

# SFT 트레이너로 학습
trainer = SFTTrainer(
    model=model,
    train_dataset=dataset,
    args=training_args,
    max_seq_length=2048,
    dataset_text_field="text"
)

trainer.train()
```

### 사례 2: Stable Diffusion 커스터마이징

```python
import torch
from diffusers import StableDiffusionPipeline
from peft import LoraConfig, get_peft_model

# Stable Diffusion 모델 로드
model_id = "runwayml/stable-diffusion-v1-5"
pipe = StableDiffusionPipeline.from_pretrained(model_id)

# UNet에 LoRA 적용
unet = pipe.unet
lora_config = LoraConfig(
    r=4,  # Diffusion 모델은 낮은 랭크 사용
    lora_alpha=32,
    target_modules=["to_k", "to_q", "to_v", "to_out.0"],
    lora_dropout=0.1
)

# LoRA 어댑터 적용
unet = get_peft_model(unet, lora_config)
print(f"학습 가능한 파라미터: {unet.num_parameters(only_trainable=True):,}")
# 원본 UNet: 860M → LoRA: 2.5M (0.3%만 학습!)
```

### 사례 3: 다국어 번역 모델

```python
from transformers import T5ForConditionalGeneration, T5Tokenizer
from peft import LoraConfig, get_peft_model

# T5 모델로 번역 태스크
model_name = "google/flan-t5-large"
model = T5ForConditionalGeneration.from_pretrained(model_name)
tokenizer = T5Tokenizer.from_pretrained(model_name)

# LoRA 설정 (T5 특화)
lora_config = LoraConfig(
    r=16,
    lora_alpha=32,
    target_modules=["q", "v", "wi_0", "wi_1", "wo"],
    lora_dropout=0.1,
    bias="none",
    task_type="SEQ_2_SEQ_LM"
)

model = get_peft_model(model, lora_config)

# 번역 예제
def translate(text, source_lang, target_lang):
    prompt = f"translate {source_lang} to {target_lang}: {text}"
    inputs = tokenizer(prompt, return_tensors="pt", max_length=512, truncation=True)
    
    with torch.no_grad():
        outputs = model.generate(
            **inputs,
            max_length=512,
            num_beams=4,
            do_sample=False
        )
    
    return tokenizer.decode(outputs[0], skip_special_tokens=True)

# 사용 예시
result = translate("안녕하세요", "Korean", "English")
print(result)  # "Hello"
```

## PEFT와 다른 기술의 통합

### TRL과의 통합

```python
from trl import DPOTrainer, DPOConfig
from peft import LoraConfig, get_peft_model

# DPO (Direct Preference Optimization)에 PEFT 적용
model = AutoModelForCausalLM.from_pretrained("meta-llama/Llama-2-7b-hf")

# LoRA 설정
lora_config = LoraConfig(
    r=16,
    lora_alpha=32,
    target_modules=["q_proj", "v_proj"],
    lora_dropout=0.1,
    bias="none",
    task_type="CAUSAL_LM"
)

model = get_peft_model(model, lora_config)

# DPO 학습
dpo_config = DPOConfig(
    output_dir="./llama-dpo-lora",
    num_train_epochs=1,
    per_device_train_batch_size=2,
    learning_rate=1e-6,
    beta=0.1
)

dpo_trainer = DPOTrainer(
    model=model,
    args=dpo_config,
    train_dataset=preference_dataset,
    tokenizer=tokenizer
)

dpo_trainer.train()
```

### Quantization과의 결합

```python
from transformers import BitsAndBytesConfig
import torch

# 4비트 양자화 설정
bnb_config = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_use_double_quant=True,
    bnb_4bit_quant_type="nf4",
    bnb_4bit_compute_dtype=torch.bfloat16
)

# 양자화된 모델 로드
model = AutoModelForCausalLM.from_pretrained(
    "microsoft/DialoGPT-large",
    quantization_config=bnb_config,
    device_map="auto"
)

# QLoRA 적용
lora_config = LoraConfig(
    r=8,
    lora_alpha=16,
    target_modules=["c_attn"],
    lora_dropout=0.1,
    bias="none",
    task_type="CAUSAL_LM"
)

model = get_peft_model(model, lora_config)
print(f"메모리 사용량: {model.get_memory_footprint() / 1e9:.2f} GB")
```

### Accelerate와의 통합

```python
from accelerate import Accelerator
from peft import LoraConfig, get_peft_model

# 분산 학습 설정
accelerator = Accelerator()

# 모델과 LoRA 설정
model = AutoModelForCausalLM.from_pretrained("gpt2-large")
lora_config = LoraConfig(r=16, target_modules=["c_attn"], task_type="CAUSAL_LM")
model = get_peft_model(model, lora_config)

# Accelerator로 준비
model, optimizer, dataloader = accelerator.prepare(model, optimizer, dataloader)

# 분산 학습 루프
for batch in dataloader:
    outputs = model(**batch)
    loss = outputs.loss
    accelerator.backward(loss)
    optimizer.step()
    optimizer.zero_grad()
```

## 고급 활용 팁

### 다중 어댑터 관리

```python
from peft import PeftModel

# 베이스 모델 로드
base_model = AutoModelForCausalLM.from_pretrained("gpt2")

# 여러 태스크용 어댑터 로드
model = PeftModel.from_pretrained(base_model, "path/to/sentiment-adapter")
model.load_adapter("path/to/translation-adapter", adapter_name="translation")
model.load_adapter("path/to/summarization-adapter", adapter_name="summarization")

# 어댑터 전환
model.set_adapter("translation")  # 번역 모드
outputs = model.generate(translation_input)

model.set_adapter("summarization")  # 요약 모드  
outputs = model.generate(summarization_input)

# 어댑터 가중 조합
model.add_weighted_adapter(
    adapters=["sentiment", "translation"],
    weights=[0.7, 0.3],
    adapter_name="mixed"
)
```

### 어댑터 융합

```python
# 학습된 LoRA 어댑터를 원본 모델에 병합
model = PeftModel.from_pretrained(base_model, "path/to/lora-adapter")
merged_model = model.merge_and_unload()

# 병합된 모델 저장
merged_model.save_pretrained("./merged-model")
```

### 점진적 랭크 증가

```python
# 작은 랭크로 시작
initial_config = LoraConfig(r=8, lora_alpha=16, target_modules=["c_attn"])
model = get_peft_model(base_model, initial_config)

# 첫 번째 단계 학습
trainer.train()

# 랭크 증가
expanded_config = LoraConfig(r=16, lora_alpha=32, target_modules=["c_attn"])
model = expand_lora_rank(model, expanded_config)  # 커스텀 함수

# 두 번째 단계 학습
trainer.train()
```

## 성능 최적화 가이드

### 메모리 최적화

```python
# 그래디언트 체크포인팅과 함께 사용
from transformers import TrainingArguments

training_args = TrainingArguments(
    gradient_checkpointing=True,  # 메모리 절약
    dataloader_pin_memory=False,
    per_device_train_batch_size=1,
    gradient_accumulation_steps=16,
    warmup_ratio=0.03,
    learning_rate=2e-4,
    bf16=True,  # BF16 사용
    logging_steps=10,
    optim="paged_adamw_32bit"  # 페이지드 옵티마이저
)
```

### 하이퍼파라미터 최적화

```python
# 태스크별 최적 설정
TASK_CONFIGS = {
    "text_classification": {
        "r": 8, "lora_alpha": 16, "lora_dropout": 0.1
    },
    "text_generation": {
        "r": 16, "lora_alpha": 32, "lora_dropout": 0.05
    },
    "translation": {
        "r": 32, "lora_alpha": 64, "lora_dropout": 0.1
    },
    "summarization": {
        "r": 16, "lora_alpha": 32, "lora_dropout": 0.1
    }
}

def get_optimal_config(task_type, model_size):
    base_config = TASK_CONFIGS[task_type]
    
    # 모델 크기에 따른 조정
    if model_size > 10e9:  # 10B+ 모델
        base_config["r"] *= 2
        base_config["lora_alpha"] *= 2
    
    return LoraConfig(**base_config, task_type="CAUSAL_LM")
```

## 문제 해결 가이드

### 일반적인 문제들

#### 1. 수렴하지 않는 문제

```python
# 해결책: 더 높은 랭크와 학습률 사용
problematic_config = LoraConfig(r=4, lora_alpha=8, learning_rate=1e-5)

# 개선된 설정
improved_config = LoraConfig(
    r=16,  # 랭크 증가
    lora_alpha=32,  # 알파 증가
    lora_dropout=0.05,  # 드롭아웃 감소
    learning_rate=2e-4  # 학습률 증가
)
```

#### 2. 과적합 문제

```python
# 해결책: 정규화 강화
anti_overfitting_config = LoraConfig(
    r=8,  # 랭크 감소
    lora_alpha=16,
    lora_dropout=0.2,  # 드롭아웃 증가
    weight_decay=0.01  # 가중치 감쇠 추가
)
```

#### 3. 메모리 부족

```python
# 해결책: 더 작은 배치 크기와 그래디언트 누적
memory_efficient_args = TrainingArguments(
    per_device_train_batch_size=1,  # 최소 배치
    gradient_accumulation_steps=32,  # 높은 누적
    gradient_checkpointing=True,
    dataloader_pin_memory=False,
    optim="adafactor"  # 메모리 효율적 옵티마이저
)
```

## 최신 동향 및 로드맵

### 2025년 주요 업데이트

- **QA-LoRA**: 양자화 인식 LoRA 학습
- **MoRA**: Mixture-of-Rank Adaptation
- **DoRA**: Weight-Decomposed Low-Rank Adaptation
- **Delta-LoRA**: 차분 기반 랭크 적응
- **Vera**: Vector-based Random Matrix Adaptation

### 차세대 PEFT 기술

```python
# DoRA (Weight-Decomposed LoRA) 예시
from peft import DoRAConfig

dora_config = DoRAConfig(
    r=8,
    lora_alpha=16,
    use_dora=True,  # DoRA 활성화
    target_modules=["q_proj", "v_proj"]
)
```

## 실전 프로젝트 예제

### 프로젝트 1: 코드 생성 모델

```python
# CodeLlama 모델로 Python 코드 생성기 구축
from transformers import CodeLlamaTokenizer, LlamaForCausalLM
from peft import LoraConfig, get_peft_model

model_name = "codellama/CodeLlama-7b-Python-hf"
model = LlamaForCausalLM.from_pretrained(model_name, load_in_4bit=True)
tokenizer = CodeLlamaTokenizer.from_pretrained(model_name)

# 코드 생성 특화 LoRA 설정
code_config = LoraConfig(
    r=32,  # 코드는 높은 랭크 필요
    lora_alpha=64,
    target_modules=["q_proj", "k_proj", "v_proj", "o_proj"],
    lora_dropout=0.05,
    bias="none",
    task_type="CAUSAL_LM"
)

model = get_peft_model(model, code_config)

# 코드 생성 함수
def generate_code(prompt, max_length=512):
    inputs = tokenizer(f"# {prompt}\n", return_tensors="pt")
    
    with torch.no_grad():
        outputs = model.generate(
            **inputs,
            max_length=max_length,
            temperature=0.2,
            do_sample=True,
            pad_token_id=tokenizer.eos_token_id
        )
    
    return tokenizer.decode(outputs[0], skip_special_tokens=True)

# 사용 예시
code = generate_code("파이썬에서 이진 검색 구현")
print(code)
```

### 프로젝트 2: 멀티모달 이미지 캡셔닝

```python
from transformers import BlipProcessor, BlipForConditionalGeneration
from peft import LoraConfig, get_peft_model

# BLIP 모델로 이미지 캡셔닝
model_name = "Salesforce/blip-image-captioning-large"
processor = BlipProcessor.from_pretrained(model_name)
model = BlipForConditionalGeneration.from_pretrained(model_name)

# 이미지 인코더는 고정, 텍스트 디코더만 LoRA 적용
lora_config = LoraConfig(
    r=16,
    lora_alpha=32,
    target_modules=["q_proj", "v_proj"],  # 텍스트 디코더만
    modules_to_save=["classifier"],  # 분류기 헤드 저장
    lora_dropout=0.1,
    bias="none",
    task_type="VISION_2_SEQ"
)

model = get_peft_model(model, lora_config)

# 커스텀 캡셔닝 함수
def generate_caption(image, style="detailed"):
    if style == "detailed":
        prompt = "a detailed description of"
    elif style == "artistic":
        prompt = "an artistic interpretation of"
    else:
        prompt = ""
    
    inputs = processor(image, prompt, return_tensors="pt")
    
    with torch.no_grad():
        outputs = model.generate(
            **inputs,
            max_length=50,
            num_beams=5,
            temperature=0.7
        )
    
    return processor.decode(outputs[0], skip_special_tokens=True)
```

## 커뮤니티와 자료

### 공식 자료

- **GitHub**: [https://github.com/huggingface/peft](https://github.com/huggingface/peft)
- **문서**: [https://huggingface.co/docs/peft](https://huggingface.co/docs/peft)
- **PEFT Organization**: [https://huggingface.co/peft](https://huggingface.co/peft)

### 실습 자료

- **공식 예제**: [PEFT Examples](https://github.com/huggingface/peft/tree/main/examples)
- **노트북 컬렉션**: 다양한 태스크별 실습 노트북
- **모델 컬렉션**: 사전 학습된 PEFT 어댑터들

### 연구 논문

- **LoRA**: "LoRA: Low-Rank Adaptation of Large Language Models"
- **AdaLoRA**: "Adaptive Budget Allocation for Parameter-Efficient Fine-Tuning"
- **IA3**: "Few-Shot Parameter-Efficient Fine-Tuning is Better and Cheaper than In-Context Learning"
- **Prompt Tuning**: "The Power of Scale for Parameter-Efficient Prompt Tuning"

## 마무리

PEFT는 현재 AI 업계에서 **가장 혁신적인 파인튜닝 기술**이다. **극소수 파라미터만 학습**해도 전체 파인튜닝과 동등한 성능을 달성하면서, **메모리와 저장 공간을 획기적으로 절약**한다.

특히 **GPU 자원이 제한된 환경**에서도 최신 대형 모델을 효과적으로 활용할 수 있게 해주어, **AI 민주화**에 크게 기여하고 있다. LoRA, AdaLoRA, IA3 등 다양한 방법론을 제공하여 각 상황에 최적화된 솔루션을 선택할 수 있다.

OpenAI, Google, Meta 등 주요 기업들이 이미 PEFT를 적극 도입하고 있으니, LLM 개발이나 연구에 관심이 있다면 **반드시 마스터해야 할 핵심 기술**이다.

---

*이 글이 도움이 되었다면, PEFT GitHub에 ⭐를 눌러주세요!*
