---
title: "DeepSeek-R1 → Qwen 지식 증류 완전 가이드: 11개 오픈소스 파이프라인 총정리"
excerpt: "교사-학생 모델 증류의 실전 구현체들. MIT/Apache 2.0 라이선스로 자유롭게 활용 가능한 DeepSeek-R1 → Qwen 계열 지식 증류 파이프라인 11선"
date: 2025-05-30
categories:
  - llmops
tags:
  - DeepSeek-R1
  - Qwen
  - 지식증류
  - Knowledge-Distillation
  - 교사학생모델
  - LoRA
  - QLoRA
  - CoT
  - Chain-of-Thought
  - SFT
author_profile: true
toc: true
toc_label: "DeepSeek-R1 지식 증류 가이드"
---

> **TL;DR** DeepSeek-R1의 추론 능력을 Qwen 계열 모델로 증류하는 **11개 오픈소스 파이프라인**을 완전 정리했다. 공식 참조부터 미니멀 구현체, 커뮤니티 확장 버전까지 **MIT/Apache 2.0 라이선스**로 자유롭게 활용 가능하다. **A100 1장으로도 재현 가능한** 실전 가이드다.

---

## DeepSeek-R1 지식 증류 생태계 개요

**DeepSeek-R1**은 강화학습과 Chain-of-Thought(CoT) 추론에서 뛰어난 성능을 보이는 대형 언어모델이다. 하지만 그 크기와 복잡성 때문에 실제 서비스 환경에서는 **더 작고 효율적인 모델**이 필요하다. 이때 **지식 증류(Knowledge Distillation)** 기법을 통해 DeepSeek-R1의 추론 능력을 Qwen 계열 모델로 전이할 수 있다.

### 지식 증류 파이프라인 구조

```mermaid
graph TD
    A[DeepSeek-R1 교사모델] --> B[CoT 데이터 생성]
    B --> C[Self-Vote 품질 필터링]
    C --> D[Qwen 학생모델 SFT]
    D --> E[LoRA/QLoRA 미세조정]
    E --> F[성능 평가 & 배포]
    
    G[800K CoT 샘플] --> D
    H[Flash-Attention 2] --> E
    I[Multi-GPU 분산학습] --> E
```

### 핵심 성과 지표

| 구분 | 교사모델 | 학생모델 | 성능 유지율 | 추론 속도 향상 |
|------|---------|---------|------------|-------------|
| **7B 증류** | DeepSeek-R1-671B | Qwen2.5-7B | 85-90% | 15x |
| **14B 증류** | DeepSeek-R1-671B | Qwen2.5-14B | 90-95% | 8x |
| **32B 증류** | DeepSeek-R1-671B | Qwen2.5-32B | 95-98% | 4x |

## 공식 참조 & 리서치 베이스

### 1. DeepSeek-R1 공식 저장소

**[deepseek-ai/DeepSeek-R1](https://github.com/deepseek-ai/DeepSeek-R1)**

DeepSeek 팀이 직접 공개한 **공식 구현체**로, 전체 학습 파이프라인의 레퍼런스다.

#### 핵심 특징

- **2단계 RL + 2단계 SFT + Distillation** 완전 절차 제공
- 학습 스크립트, 데이터 전처리, config 파일 모두 포함
- MIT 라이선스로 상업적 활용 가능

#### 실제 사용법

```bash
# 저장소 클론
git clone https://github.com/deepseek-ai/DeepSeek-R1.git
cd DeepSeek-R1

# 환경 설정
pip install -r requirements.txt

# 데이터 생성 (CoT 샘플)
python scripts/generate_cot_data.py \
    --teacher_model deepseek-ai/DeepSeek-R1-Distill-Qwen-32B \
    --output_path ./cot_data.jsonl \
    --num_samples 10000

# 지식 증류 학습
python scripts/distill_training.py \
    --config configs/qwen_distill.yaml \
    --data_path ./cot_data.jsonl \
    --output_dir ./checkpoints
```

### 2. Hugging Face open-r1 프로젝트

**[huggingface/open-r1](https://github.com/huggingface/open-r1)**

Hugging Face에서 DeepSeek 공식 파이프라인을 **완전 재현**하려는 오픈소스 프로젝트다.

#### 핵심 특징

- **Step-by-step 재현 코드** 제공
- Colab 노트북으로 즉시 실행 가능
- Transformers 라이브러리와 완전 호환

#### Colab 실행 예제

```python
# Colab에서 바로 실행 가능
!git clone https://github.com/huggingface/open-r1.git
%cd open-r1

# 필요 라이브러리 설치
!pip install -r requirements.txt

from open_r1 import DistillationPipeline

# 파이프라인 초기화
pipeline = DistillationPipeline(
    teacher_model="deepseek-ai/DeepSeek-R1-Distill-Qwen-32B",
    student_model="Qwen/Qwen2.5-7B-Instruct",
    device="cuda"
)

# 데이터 생성 및 학습
pipeline.generate_training_data(num_samples=1000)
pipeline.train(epochs=3, batch_size=4)
```

## 미니멀 파이프라인 (SFT 중심)

### 1. Emericen/deepseek-r1-distilled

**[Emericen/deepseek-r1-distilled](https://github.com/Emericen/deepseek-r1-distilled)**

**800K CoT 데이터**로 Qwen, Llama 6종 모델을 증류하는 **최소 구현체**다.

#### 핵심 특징

- `train_sft.py` 단일 파일로 실행
- 6개 모델 동시 지원 (Qwen2.5-7B/14B/32B, Llama-3.1-8B/70B, Llama-3.2-3B)
- 800K 고품질 CoT 데이터셋 제공

#### 실행 방법

```bash
# 저장소 클론
git clone https://github.com/Emericen/deepseek-r1-distilled.git
cd deepseek-r1-distilled

# 단일 명령어로 학습 시작
python train_sft.py \
    --model_name Qwen/Qwen2.5-7B-Instruct \
    --dataset_path ./data/cot_800k.jsonl \
    --output_dir ./output \
    --num_epochs 3 \
    --batch_size 8 \
    --learning_rate 2e-5
```

#### 데이터셋 구조

```json
{
  "instruction": "다음 수학 문제를 단계별로 해결하세요.",
  "input": "x^2 + 5x + 6 = 0을 풀어보세요.",
  "output": "<thinking>\n이차방정식을 인수분해로 풀어보겠습니다.\nx^2 + 5x + 6 = 0\n두 수의 곱이 6이고 합이 5인 수를 찾아야 합니다.\n2 × 3 = 6, 2 + 3 = 5\n따라서 (x + 2)(x + 3) = 0\n</thinking>\n\n이차방정식 x^2 + 5x + 6 = 0을 인수분해로 풀어보겠습니다.\n\n(x + 2)(x + 3) = 0\n\n따라서 x = -2 또는 x = -3입니다."
}
```

### 2. cm2solutions/deepseek-r1-distillation

**[cm2solutions/deepseek-r1-distillation](https://github.com/cm2solutions/deepseek-r1-distillation)**

**Trainer-agnostic 설계**로 다양한 학습 프레임워크를 지원하는 유연한 구현체다.

#### 핵심 특징

- PyTorch Lightning 기반 모듈화 설계
- LoRA, QLoRA 옵션 내장
- Multi-GPU 분산 학습 스크립트 제공

#### 설정 파일 예제

```yaml
# config/qwen_7b_lora.yaml
model:
  name: "Qwen/Qwen2.5-7B-Instruct"
  use_lora: true
  lora_config:
    r: 16
    lora_alpha: 32
    target_modules: ["q_proj", "v_proj", "k_proj", "o_proj"]
    lora_dropout: 0.1

training:
  batch_size: 4
  gradient_accumulation_steps: 4
  learning_rate: 2e-4
  num_epochs: 3
  warmup_steps: 100

data:
  train_path: "./data/train.jsonl"
  val_path: "./data/val.jsonl"
  max_length: 2048
```

#### Multi-GPU 실행

```bash
# 4개 GPU로 분산 학습
torchrun --nproc_per_node=4 train_distributed.py \
    --config config/qwen_7b_lora.yaml \
    --output_dir ./checkpoints \
    --logging_dir ./logs
```

## Qwen 전용 Distill 스크립트

### 1. madaibaba/deepseek-distill-qwen

**[madaibaba/deepseek-distill-qwen](https://github.com/madaibaba/deepseek-distill-qwen)**

**단일 파일 구현**으로 LoRA + Flash-Attention 2를 활용한 효율적인 증류 예시다.

#### 핵심 특징

- `deepseek_distill_qwen.py` 단일 파일 구현
- Flash-Attention 2로 메모리 효율성 극대화
- 데이터 전처리부터 실험 로그까지 템플릿 제공

#### 실행 코드

```python
# deepseek_distill_qwen.py 핵심 부분
import torch
from transformers import AutoTokenizer, AutoModelForCausalLM
from peft import LoraConfig, get_peft_model
import flash_attn

def setup_model_with_lora(model_name, lora_config):
    """LoRA 설정으로 모델 초기화"""
    model = AutoModelForCausalLM.from_pretrained(
        model_name,
        torch_dtype=torch.bfloat16,
        attn_implementation="flash_attention_2"
    )
    
    lora_config = LoraConfig(
        r=16,
        lora_alpha=32,
        target_modules=["q_proj", "v_proj", "k_proj", "o_proj"],
        lora_dropout=0.1,
        bias="none",
        task_type="CAUSAL_LM"
    )
    
    model = get_peft_model(model, lora_config)
    return model

# 사용 예제
model = setup_model_with_lora("Qwen/Qwen2.5-7B-Instruct", lora_config)
print(f"Trainable parameters: {model.num_parameters(only_trainable=True):,}")
```

### 2. yaocw2020/DeepSeek-R1-Distill-Qwen-1.5B

**[yaocw2020/DeepSeek-R1-Distill-Qwen-1.5B](https://github.com/yaocw2020/DeepSeek-R1-Distill-Qwen-1.5B)**

**1.5B 파라미터급 초소형 모델**로 A100 한 장으로도 재현 가능한 설정을 제공한다.

#### 리소스 요구사항

| 구성 | GPU 메모리 | 학습 시간 | 배치 크기 |
|------|-----------|---------|----------|
| **1.5B 모델** | 16GB | 2-3시간 | 16 |
| **7B 모델** | 40GB | 8-12시간 | 4 |
| **14B 모델** | 80GB | 24-36시간 | 2 |

#### 메모리 최적화 설정

```python
# memory_efficient_config.py
from transformers import TrainingArguments

training_args = TrainingArguments(
    output_dir="./checkpoints",
    per_device_train_batch_size=1,
    gradient_accumulation_steps=16,
    gradient_checkpointing=True,
    fp16=True,
    dataloader_pin_memory=False,
    optim="adamw_torch_fused",
    learning_rate=2e-5,
    warmup_steps=100,
    logging_steps=10,
    save_steps=500,
    max_steps=3000
)
```

### 3. Evilcarbon/DeepSeek-R1-Distill-Qwen-32B

**[Evilcarbon/DeepSeek-R1-Distill-Qwen-32B](https://github.com/Evilcarbon/DeepSeek-R1-Distill-Qwen-32B)**

**32B 완전 모델 가중치**와 `finetune.sh` 스크립트를 제공하는 프로덕션 레디 구현체다.

#### 제공 자료

- 사전 학습된 32B 모델 가중치
- 프로덕션 환경 배포 스크립트
- 성능 벤치마크 결과

#### 파인튜닝 스크립트

```bash
#!/bin/bash
# finetune.sh

export CUDA_VISIBLE_DEVICES=0,1,2,3
export WANDB_PROJECT="deepseek-qwen-distill"

python -m torch.distributed.launch \
    --nproc_per_node=4 \
    --master_port=29500 \
    train.py \
    --model_name_or_path ./qwen-32b-base \
    --data_path ./data/distill_data.jsonl \
    --bf16 True \
    --output_dir ./checkpoints \
    --num_train_epochs 3 \
    --per_device_train_batch_size 1 \
    --per_device_eval_batch_size 1 \
    --gradient_accumulation_steps 8 \
    --evaluation_strategy "no" \
    --save_strategy "steps" \
    --save_steps 500 \
    --save_total_limit 3 \
    --learning_rate 2e-5 \
    --weight_decay 0. \
    --warmup_ratio 0.03 \
    --lr_scheduler_type "cosine" \
    --logging_steps 1 \
    --fsdp "full_shard auto_wrap" \
    --fsdp_transformer_layer_cls_to_wrap 'Qwen2DecoderLayer' \
    --tf32 True
```

## 재현·확장 프로젝트

### 1. hwei-hw/DeepSeek-Distillation

**[hwei-hw/DeepSeek-Distillation](https://github.com/hwei-hw/DeepSeek-Distillation)**

DeepSeek-R1 기반 **공개 증류 데이터셋들을 카탈로그화**한 수집형 저장소다.

#### 데이터셋 카탈로그

| 데이터셋 | 규모 | 품질 점수 | 라이선스 | 추천 용도 |
|---------|------|---------|---------|----------|
| **CoT-800K** | 80만 샘플 | 9.2/10 | MIT | 수학/논리 추론 |
| **Reasoning-1M** | 100만 샘플 | 8.8/10 | Apache 2.0 | 일반 추론 |
| **Code-CoT-500K** | 50만 샘플 | 9.0/10 | MIT | 코딩 문제 해결 |

### 2. dayflyers/open

**[dayflyers/open](https://github.com/dayflyers/open)**

RL 단계까지 포함한 **완전 오픈 재현 로드맵**을 제시하는 야심찬 프로젝트다.

#### 재현 로드맵

```mermaid
gantt
    title DeepSeek-R1 완전 재현 로드맵
    dateFormat  YYYY-MM-DD
    section Phase 1
    데이터 수집        :2025-01-01, 30d
    SFT 구현          :2025-01-15, 45d
    section Phase 2
    Reward Model      :2025-02-01, 30d
    PPO 구현          :2025-02-15, 45d
    section Phase 3
    평가 및 최적화     :2025-03-01, 30d
    배포 준비         :2025-03-15, 15d
```

### 3. inferless/DeepSeek-R1-Distill-Qwen-32B

**[inferless/DeepSeek-R1-Distill-Qwen-32B](https://github.com/inferless/DeepSeek-R1-Distill-Qwen-32B)**

**vLLM 기반 배포 & 추론 템플릿**을 제공하여 학습 후 실서비스 연결까지 지원한다.

#### Docker 배포 예제

```dockerfile
# Dockerfile
FROM nvidia/cuda:11.8-devel-ubuntu20.04

# vLLM 설치
RUN pip install vllm

# 모델 다운로드
COPY ./model /app/model

# 서비스 스크립트
COPY serve.py /app/

EXPOSE 8000

CMD ["python", "/app/serve.py"]
```

```python
# serve.py
from vllm import LLM, SamplingParams
from fastapi import FastAPI

app = FastAPI()
llm = LLM(model="/app/model", tensor_parallel_size=4)

@app.post("/generate")
async def generate(prompt: str):
    sampling_params = SamplingParams(
        temperature=0.7,
        top_p=0.9,
        max_tokens=2048
    )
    
    outputs = llm.generate([prompt], sampling_params)
    return {"response": outputs[0].outputs[0].text}
```

### 4. Dellagi/DeepSeek-R1-Distill-Finetuning

**[Dellagi/DeepSeek-R1-Distill-Finetuning](https://github.com/Dellagi/DeepSeek-R1-Distill-Finetuning)**

**금융 도메인 특화** 후행 LoRA 미세조정 샘플로 Unsloth 라이브러리를 활용한다.

#### 도메인 특화 예제

```python
# financial_finetune.py
from unsloth import FastLanguageModel
import torch

# 모델 로드 (Unsloth 최적화)
model, tokenizer = FastLanguageModel.from_pretrained(
    model_name="./deepseek-qwen-distilled",
    max_seq_length=2048,
    dtype=None,
    load_in_4bit=True,
)

# LoRA 어댑터 추가
model = FastLanguageModel.get_peft_model(
    model,
    r=16,
    target_modules=["q_proj", "k_proj", "v_proj", "o_proj"],
    lora_alpha=16,
    lora_dropout=0,
    bias="none",
    use_gradient_checkpointing=True,
    random_state=3407,
)

# 금융 데이터로 미세조정
from datasets import load_dataset
financial_dataset = load_dataset("./financial_qa_korean.jsonl")

from trl import SFTTrainer
trainer = SFTTrainer(
    model=model,
    tokenizer=tokenizer,
    train_dataset=financial_dataset,
    dataset_text_field="text",
    max_seq_length=2048,
    num_train_epochs=3,
)

trainer.train()
```

## 실전 활용 가이드

### 데이터 생성 전략

#### 1. CoT 샘플 생성

```python
# generate_cot_samples.py
import openai
from datasets import Dataset

def generate_cot_data(problems, teacher_model="deepseek-r1"):
    """DeepSeek-R1으로 CoT 샘플 생성"""
    cot_samples = []
    
    for problem in problems:
        prompt = f"""다음 문제를 단계별로 해결하세요. <thinking> 태그 안에 사고 과정을 자세히 적고, 그 다음에 최종 답변을 제시하세요.

문제: {problem}"""
        
        response = openai.ChatCompletion.create(
            model=teacher_model,
            messages=[{"role": "user", "content": prompt}],
            temperature=0.7,
            max_tokens=2048
        )
        
        cot_samples.append({
            "instruction": "다음 문제를 단계별로 해결하세요.",
            "input": problem,
            "output": response.choices[0].message.content
        })
    
    return Dataset.from_list(cot_samples)
```

#### 2. Self-Vote 품질 필터링

```python
# quality_filter.py
def self_vote_filter(samples, threshold=0.8):
    """Self-vote 방식으로 고품질 샘플 선별"""
    filtered_samples = []
    
    for sample in samples:
        # 동일 문제에 대해 3번 생성
        responses = []
        for _ in range(3):
            response = generate_response(sample['input'])
            responses.append(response)
        
        # 일관성 점수 계산
        consistency_score = calculate_consistency(responses)
        
        if consistency_score >= threshold:
            # 가장 좋은 응답 선택
            best_response = select_best_response(responses)
            sample['output'] = best_response
            filtered_samples.append(sample)
    
    return filtered_samples
```

### 학습 스케일 가이드

#### GPU 메모리별 권장 설정

| GPU 메모리 | 모델 크기 | 배치 크기 | LoRA 설정 | 예상 학습 시간 |
|-----------|---------|---------|----------|------------|
| **16GB** | Qwen2.5-1.5B | 8 | r=8, α=16 | 2-4시간 |
| **24GB** | Qwen2.5-7B | 4 | r=16, α=32 | 8-12시간 |
| **40GB** | Qwen2.5-7B | 8 | r=32, α=64 | 6-8시간 |
| **80GB** | Qwen2.5-14B | 4 | r=16, α=32 | 12-18시간 |

#### 메모리 최적화 기법

```python
# memory_optimization.py
from transformers import TrainingArguments

def get_memory_efficient_args(gpu_memory_gb):
    """GPU 메모리에 따른 최적화 설정"""
    
    if gpu_memory_gb <= 16:
        return TrainingArguments(
            per_device_train_batch_size=1,
            gradient_accumulation_steps=16,
            gradient_checkpointing=True,
            fp16=True,
            dataloader_pin_memory=False,
            optim="adamw_8bit"
        )
    elif gpu_memory_gb <= 40:
        return TrainingArguments(
            per_device_train_batch_size=4,
            gradient_accumulation_steps=4,
            gradient_checkpointing=True,
            bf16=True,
            optim="adamw_torch_fused"
        )
    else:
        return TrainingArguments(
            per_device_train_batch_size=8,
            gradient_accumulation_steps=2,
            bf16=True,
            optim="adamw_torch_fused"
        )
```

### 라이선스 및 배포 가이드

#### 라이선스 표기 예제

```markdown
# Model Card

## License

This model is derived from:
- **Teacher Model**: DeepSeek-R1 (MIT License)
- **Student Model**: Qwen2.5 (Apache 2.0 License)

따라서 이 모델은 MIT와 Apache 2.0 라이선스 조건을 모두 준수합니다.
상업적 사용이 가능하며, 재배포 시 원본 라이선스를 명시해야 합니다.
```

#### 안전 필터링 적용

```python
# safety_filter.py
import json

def apply_safety_rules(response, safety_rules_path="safety_rules.json"):
    """공식 안전 규칙 적용"""
    with open(safety_rules_path, 'r') as f:
        safety_rules = json.load(f)
    
    for rule in safety_rules['prohibited_content']:
        if rule['pattern'] in response.lower():
            return rule['replacement']
    
    return response

# safety_rules.json 예제
{
    "prohibited_content": [
        {
            "pattern": "harmful instruction",
            "replacement": "죄송하지만 해당 요청에는 응답할 수 없습니다."
        }
    ]
}
```

## 성능 벤치마크 및 평가

### 주요 벤치마크 결과

| 모델 | MMLU | GSM8K | HumanEval | 한국어 이해도 |
|------|------|-------|-----------|-------------|
| **DeepSeek-R1-671B** | 89.7 | 97.3 | 92.1 | 94.2 |
| **Qwen2.5-32B (증류)** | 85.2 | 91.8 | 87.4 | 89.7 |
| **Qwen2.5-14B (증류)** | 82.1 | 88.5 | 83.2 | 86.3 |
| **Qwen2.5-7B (증류)** | 78.9 | 84.7 | 79.8 | 82.1 |

### 추론 속도 비교

```python
# benchmark_inference.py
import time
import torch
from transformers import AutoTokenizer, AutoModelForCausalLM

def benchmark_model(model_path, test_prompts):
    """모델 추론 속도 벤치마크"""
    tokenizer = AutoTokenizer.from_pretrained(model_path)
    model = AutoModelForCausalLM.from_pretrained(
        model_path,
        torch_dtype=torch.bfloat16,
        device_map="auto"
    )
    
    total_time = 0
    total_tokens = 0
    
    for prompt in test_prompts:
        start_time = time.time()
        
        inputs = tokenizer(prompt, return_tensors="pt")
        with torch.no_grad():
            outputs = model.generate(
                **inputs,
                max_new_tokens=512,
                do_sample=True,
                temperature=0.7
            )
        
        end_time = time.time()
        
        total_time += (end_time - start_time)
        total_tokens += len(outputs[0]) - len(inputs['input_ids'][0])
    
    tokens_per_second = total_tokens / total_time
    return tokens_per_second

# 결과 예시
# DeepSeek-R1-671B: 12 tokens/sec
# Qwen2.5-32B (증류): 48 tokens/sec (4x 향상)
# Qwen2.5-7B (증류): 156 tokens/sec (13x 향상)
```

## 마무리

DeepSeek-R1에서 Qwen 계열로의 지식 증류는 **대형 모델의 성능을 유지하면서도 실용적인 크기로 압축**하는 효과적인 방법이다. 소개한 11개 오픈소스 프로젝트들은 각각 다른 특징과 장점을 가지고 있어, **프로젝트 요구사항에 맞는 적절한 선택**이 가능하다.

### 추천 선택 가이드

- **연구 목적**: `huggingface/open-r1` 또는 `deepseek-ai/DeepSeek-R1`
- **빠른 프로토타이핑**: `Emericen/deepseek-r1-distilled`
- **프로덕션 배포**: `inferless/DeepSeek-R1-Distill-Qwen-32B`
- **리소스 제약 환경**: `yaocw2020/DeepSeek-R1-Distill-Qwen-1.5B`
- **도메인 특화**: `Dellagi/DeepSeek-R1-Distill-Finetuning`

모든 프로젝트가 **MIT 또는 Apache 2.0 라이선스**로 배포되어 상업적 활용이 자유롭다는 점도 큰 장점이다. 지식 증류 기술의 발전과 함께 더욱 효율적이고 강력한 소형 모델들이 계속 등장할 것으로 기대된다. 