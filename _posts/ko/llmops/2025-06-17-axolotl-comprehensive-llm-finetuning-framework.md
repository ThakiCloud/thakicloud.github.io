---
title: "Axolotl: 통합 LLM 파인튜닝 프레임워크 완전 가이드"
excerpt: "다양한 AI 모델의 포스트 트레이닝을 간소화하는 Axolotl 프레임워크의 기능, 설치, 사용법 및 실무 적용 가이드"
date: 2025-06-17
categories:
  - llmops
tags:
  - Axolotl
  - Fine-tuning
  - LoRA
  - QLoRA
  - DPO
  - Multi-GPU Training
  - LLM Training
  - Post-training
author_profile: true
toc: true
toc_label: "목차"
---

## 개요

Axolotl은 다양한 AI 모델의 포스트 트레이닝을 간소화하도록 설계된 통합 프레임워크입니다. LLaMA, Mistral, Mixtral, Pythia 등 다양한 모델을 지원하며, HuggingFace transformers의 causal language model과 호환됩니다.

**GitHub 통계**:

- ⭐ **9.6k stars**
- 🍴 **1k forks**
- 👥 **198+ contributors**
- 📦 **16 releases**

---

## 주요 기능

### 다양한 모델 지원

**지원 모델**:

- LLaMA (Llama 4 포함)
- Mistral (Magistral 포함)
- Mixtral
- Pythia
- HuggingFace transformers causal language models 전체

### 훈련 방법론

**파인튜닝 기법**:

- **Full Fine-tuning**: 전체 모델 파라미터 훈련
- **LoRA**: Low-Rank Adaptation
- **QLoRA**: Quantized LoRA
- **GPTQ**: Gradient-based Post-Training Quantization
- **QAT**: Quantization Aware Training

**고급 훈련 기법**:

- **Preference Tuning**: DPO, IPO, KTO, ORPO
- **Reinforcement Learning**: GRPO (Group Relative Policy Optimization)
- **Multimodal Training**: 멀티모달 모델 파인튜닝
- **Reward Modelling**: RM (Reward Modelling) / PRM (Process Reward Modelling)

### 성능 최적화

**메모리 및 속도 최적화**:

- **Multipacking**: 효율적인 배치 처리
- **Flash Attention**: 메모리 효율적인 어텐션
- **Xformers**: 최적화된 트랜스포머 연산
- **Flex Attention**: 유연한 어텐션 메커니즘
- **Liger Kernel**: 고성능 커널
- **Cut Cross Entropy**: 메모리 효율적인 손실 계산
- **Sequence Parallelism (SP)**: 시퀀스 병렬화

**분산 훈련**:

- **Multi-GPU Training**: FSDP1, FSDP2, DeepSpeed
- **Multi-node Training**: Torchrun, Ray
- **LoRA Optimizations**: 단일/다중 GPU 환경에서 LoRA 최적화

---

## 최신 업데이트 (2025년)

### 2025년 6월

**Magistral 지원 추가** - mistral-common tokenizer를 사용하는 Magistral 모델 훈련 지원

### 2025년 5월

**Quantization Aware Training (QAT)** - 양자화 인식 훈련 지원 추가

### 2025년 4월

**Llama 4 지원** - Axolotl의 linearized 버전으로 Llama 4 모델 훈련 지원

### 2025년 3월

**Sequence Parallelism (SP)** - 컨텍스트 길이 확장을 위한 시퀀스 병렬화 구현
**Multimodal Fine-tuning (Beta)** - 멀티모달 모델 파인튜닝 지원

### 2025년 2월

**LoRA 최적화** - 메모리 사용량 감소 및 훈련 속도 향상
**GRPO 지원** - Group Relative Policy Optimization 추가

### 2025년 1월

**Reward Modelling** - RM/PRM 파인튜닝 지원 추가

---

## 설치 및 설정

### 시스템 요구사항

**하드웨어**:

- NVIDIA GPU (Ampere 이상, `bf16` 및 Flash Attention용)
- AMD GPU 지원
- Python 3.11
- PyTorch ≥2.5.1

### 설치 방법

```bash
# 기본 패키지 설치
pip3 install -U packaging==23.2 setuptools==75.8.0 wheel ninja

# Axolotl 설치 (Flash Attention, DeepSpeed 포함)
pip3 install --no-build-isolation axolotl[flash-attn,deepspeed]

# 예제 설정 파일 다운로드
axolotl fetch examples
axolotl fetch deepspeed_configs  # 선택사항
```

### Docker 설치

```bash
# Docker 이미지 사용
docker pull axolotlai/axolotl:main-latest

# Docker Compose 실행
docker-compose up -d
```

---

## 빠른 시작 가이드

### 첫 번째 파인튜닝

```bash
# 예제 설정 파일 가져오기
axolotl fetch examples

# 또는 사용자 지정 경로 지정
axolotl fetch examples --dest path/to/folder

# LoRA를 사용한 모델 훈련
axolotl train examples/llama-3/lora-1b.yml
```

### 기본 설정 파일 예시

```yaml
# lora-config.yml
base_model: meta-llama/Llama-2-7b-hf
model_type: LlamaForCausalLM

# LoRA 설정
adapter: lora
lora_r: 16
lora_alpha: 32
lora_dropout: 0.1
lora_target_modules:
  - q_proj
  - v_proj
  - k_proj
  - o_proj

# 데이터셋 설정
datasets:
  - path: alpaca_data.json
    type: alpaca

# 훈련 설정
sequence_len: 2048
sample_packing: true
pad_to_sequence_len: true

# 훈련 하이퍼파라미터
learning_rate: 0.0002
train_on_inputs: false
group_by_length: false
bf16: auto
fp16: false
tf32: false

# 배치 크기 및 그래디언트 설정
micro_batch_size: 2
gradient_accumulation_steps: 1
num_epochs: 3
optimizer: adamw_bnb_8bit
lr_scheduler: cosine
cosine_eta_min: 0.0

# 저장 설정
output_dir: ./lora-out
save_strategy: epoch
save_steps: 1000

# 로깅
logging_steps: 1
```

---

## 고급 훈련 기법

### LoRA 파인튜닝

```yaml
# LoRA 최적화 설정
adapter: lora
lora_r: 64
lora_alpha: 128
lora_dropout: 0.05
lora_target_linear: true  # 모든 linear layer 대상

# LoRA 최적화 활성화
lora_optimizations: true
```

### QLoRA 설정

```yaml
# QLoRA 설정
adapter: qlora
load_in_4bit: true
load_in_8bit: false

# BitsAndBytes 설정
bnb_4bit_compute_dtype: bfloat16
bnb_4bit_use_double_quant: true
bnb_4bit_quant_type: nf4
```

### DPO (Direct Preference Optimization)

```yaml
# DPO 설정
rl: dpo
dpo_beta: 0.1

# 선호도 데이터셋
datasets:
  - path: Anthropic/hh-rlhf
    type: chatml.intel
    field_human: chosen
    field_assistant: rejected
```

### GRPO (Group Relative Policy Optimization)

```yaml
# GRPO 설정
rl: grpo
grpo_beta: 0.01
grpo_reference_free: true

# 보상 모델 설정
reward_model: OpenAssistant/reward-model-deberta-v3-large-v2
```

---

## 멀티모달 파인튜닝

### 비전-언어 모델 설정

```yaml
# 멀티모달 모델 설정
model_type: LlavaForCausalLM
base_model: llava-hf/llava-1.5-7b-hf

# 이미지 처리 설정
chat_template: llava
image_token: "<image>"
image_square_pad: true

# 멀티모달 데이터셋
datasets:
  - path: liuhaotian/LLaVA-Instruct-150K
    type: llava_instruct
```

---

## 분산 훈련 설정

### Multi-GPU 훈련 (FSDP)

```yaml
# FSDP 설정
fsdp:
  - full_shard
  - auto_wrap
fsdp_config:
  fsdp_limit_all_gathers: true
  fsdp_sync_module_states: true
  fsdp_offload_params: false
  fsdp_use_orig_params: false
  fsdp_cpu_ram_efficient_loading: true
  fsdp_auto_wrap_policy: TRANSFORMER_BASED_WRAP
  fsdp_transformer_layer_cls_to_wrap: LlamaDecoderLayer
  fsdp_state_dict_type: FULL_STATE_DICT
  fsdp_sharding_strategy: FULL_SHARD
```

### DeepSpeed 설정

```yaml
# DeepSpeed 설정
deepspeed: deepspeed_configs/zero2.json
```

```json
// deepspeed_configs/zero2.json
{
  "zero_optimization": {
    "stage": 2,
    "offload_optimizer": {
      "device": "cpu",
      "pin_memory": true
    },
    "offload_param": {
      "device": "cpu",
      "pin_memory": true
    },
    "allgather_partitions": true,
    "allgather_bucket_size": 2e8,
    "overlap_comm": true,
    "reduce_scatter": true,
    "reduce_bucket_size": 2e8,
    "contiguous_gradients": true
  },
  "fp16": {
    "enabled": "auto",
    "loss_scale": 0,
    "loss_scale_window": 1000,
    "initial_scale_power": 16,
    "hysteresis": 2,
    "min_loss_scale": 1
  },
  "optimizer": {
    "type": "AdamW",
    "params": {
      "lr": "auto",
      "betas": "auto",
      "eps": "auto",
      "weight_decay": "auto"
    }
  },
  "scheduler": {
    "type": "WarmupLR",
    "params": {
      "warmup_min_lr": "auto",
      "warmup_max_lr": "auto",
      "warmup_num_steps": "auto"
    }
  }
}
```

### Multi-node 훈련

```bash
# Torchrun을 사용한 multi-node 훈련
torchrun --nnodes=2 --nproc_per_node=8 --rdzv_id=100 --rdzv_backend=c10d --rdzv_endpoint=$MASTER_ADDR:29400 \
  -m axolotl.cli.train config.yml

# Ray를 사용한 분산 훈련
ray start --head
axolotl train config.yml --ray
```

---

## 데이터셋 처리

### 지원 데이터 소스

**로컬 및 클라우드**:

- 로컬 파일 시스템
- HuggingFace Datasets
- AWS S3
- Azure Blob Storage
- Google Cloud Storage
- Oracle Cloud Infrastructure (OCI)

### 데이터셋 형식

```yaml
# Alpaca 형식
datasets:
  - path: alpaca_data.json
    type: alpaca

# ShareGPT 형식
datasets:
  - path: ShareGPT_V3_unfiltered_cleaned_split.json
    type: sharegpt
    conversation_template: chatml

# 사용자 정의 형식
datasets:
  - path: custom_data.jsonl
    type: completion
    field: text
```

### 데이터 전처리

```python
# 사용자 정의 데이터 전처리
def custom_preprocess(example):
    """사용자 정의 전처리 함수"""
    instruction = example['instruction']
    input_text = example['input']
    output = example['output']
    
    if input_text:
        prompt = f"### Instruction:\n{instruction}\n\n### Input:\n{input_text}\n\n### Response:\n"
    else:
        prompt = f"### Instruction:\n{instruction}\n\n### Response:\n"
    
    return {
        'text': prompt + output + "<|endoftext|>"
    }

# 설정 파일에서 사용
datasets:
  - path: data.json
    type: completion
    preprocess_function: custom_preprocess
```

---

## 성능 최적화 가이드

### 메모리 최적화

```yaml
# Flash Attention 활성화
flash_attention: true

# Gradient Checkpointing
gradient_checkpointing: true

# Mixed Precision
bf16: auto
fp16: false
tf32: true

# Multipacking
sample_packing: true
pad_to_sequence_len: true
```

### 속도 최적화

```yaml
# Liger Kernel 사용
use_liger_kernel: true

# Cut Cross Entropy
use_cut_cross_entropy: true

# Optimized Scheduler
lr_scheduler: cosine_with_restarts
cosine_restarts: 2

# DataLoader 최적화
dataloader_num_workers: 4
dataloader_pin_memory: true
```

### Sequence Parallelism

```yaml
# SP 설정
sequence_parallel: true
sp_size: 2  # SP 그룹 크기

# 긴 컨텍스트 처리
sequence_len: 32768
max_packed_sequence_len: 32768
```

---

## 모니터링 및 로깅

### Weights & Biases 통합

```yaml
# W&B 설정
wandb_project: axolotl-finetuning
wandb_entity: your-team
wandb_watch: gradients
wandb_name: llama-7b-lora
wandb_log_model: checkpoint

# 로깅 설정
logging_steps: 10
eval_steps: 500
save_steps: 1000
```

### TensorBoard 사용

```yaml
# TensorBoard 로깅
use_tensorboard: true
tensorboard_log_dir: ./logs

# 메트릭 로깅
log_metrics: true
log_predictions: true
```

### 커스텀 콜백

```python
# 사용자 정의 콜백
from transformers import TrainerCallback

class CustomCallback(TrainerCallback):
    def on_log(self, args, state, control, model=None, logs=None, **kwargs):
        if logs:
            print(f"Step {state.global_step}: Loss = {logs.get('train_loss', 'N/A')}")
    
    def on_save(self, args, state, control, **kwargs):
        print(f"Model saved at step {state.global_step}")

# 설정에서 사용
callbacks:
  - CustomCallback
```

---

## 평가 및 추론

### 모델 평가

```yaml
# 평가 설정
eval_sample_packing: false
eval_table_size: 5
eval_max_new_tokens: 128
do_eval: true
eval_steps: 500

# 평가 데이터셋
eval_dataset:
  - path: eval_data.json
    type: alpaca
```

### 추론 실행

```python
# 훈련된 모델로 추론
from axolotl.utils.models import load_model, load_tokenizer

# 모델 및 토크나이저 로드
model, tokenizer = load_model(
    base_model="meta-llama/Llama-2-7b-hf",
    model_type="LlamaForCausalLM",
    tokenizer_type="LlamaTokenizer",
    cfg=cfg,
    adapter="lora",
    inference=True
)

# 추론 실행
def generate_response(prompt):
    inputs = tokenizer(prompt, return_tensors="pt")
    with torch.no_grad():
        outputs = model.generate(
            **inputs,
            max_new_tokens=256,
            do_sample=True,
            temperature=0.7,
            top_p=0.9,
            pad_token_id=tokenizer.eos_token_id
        )
    
    response = tokenizer.decode(outputs[0], skip_special_tokens=True)
    return response[len(prompt):]

# 사용 예시
prompt = "### Instruction:\nExplain quantum computing\n\n### Response:\n"
response = generate_response(prompt)
print(response)
```

---

## 실무 적용 사례

### 도메인 특화 모델 개발

```yaml
# 의료 도메인 특화 모델
base_model: microsoft/BioGPT-Large
datasets:
  - path: medical_qa_dataset.json
    type: alpaca
  - path: medical_literature.jsonl
    type: completion

# 도메인 특화 토크나이저
special_tokens:
  - "<medical_term>"
  - "<diagnosis>"
  - "<treatment>"
```

### 다국어 모델 파인튜닝

```yaml
# 다국어 설정
base_model: facebook/xglm-7.5B
datasets:
  - path: multilingual_data.json
    type: sharegpt
    
# 언어별 가중치
dataset_weights:
  - 0.4  # 영어
  - 0.3  # 한국어
  - 0.2  # 일본어
  - 0.1  # 중국어
```

### 코드 생성 모델

```yaml
# 코드 생성 특화
base_model: Salesforce/codegen-16B-multi
datasets:
  - path: code_alpaca.json
    type: alpaca
  - path: github_code.jsonl
    type: completion

# 코드 특화 설정
special_tokens:
  - "<code>"
  - "</code>"
  - "<comment>"
  - "</comment>"
```

---

## 트러블슈팅

### 일반적인 문제 해결

**메모리 부족 오류**:

```yaml
# 메모리 최적화 설정
micro_batch_size: 1
gradient_accumulation_steps: 8
gradient_checkpointing: true
load_in_8bit: true
```

**훈련 속도 개선**:

```yaml
# 속도 최적화
sample_packing: true
flash_attention: true
use_liger_kernel: true
dataloader_num_workers: 8
```

**수렴 문제**:

```yaml
# 학습률 조정
learning_rate: 1e-5
lr_scheduler: linear
warmup_steps: 100
weight_decay: 0.01
```

### 디버깅 도구

```bash
# 상세 로깅 활성화
export AXOLOTL_DEBUG=1
axolotl train config.yml --debug

# 프로파일링
axolotl train config.yml --profile

# 설정 검증
axolotl validate config.yml
```

---

## 커뮤니티 및 지원

### 공식 리소스

- **공식 문서**: [docs.axolotl.ai](https://docs.axolotl.ai)
- **GitHub**: [axolotl-ai-cloud/axolotl](https://github.com/axolotl-ai-cloud/axolotl)
- **Discord**: 커뮤니티 지원 채널
- **예제 디렉토리**: 다양한 사용 사례 예제

### 전문 지원

**기업 지원**: wing@axolotl.ai로 문의

### 스폰서

**Modal**: 클라우드 기반 Gen AI 모델 배포 및 대규모 언어 모델 파인튜닝 플랫폼

---

## 결론

Axolotl은 현대적인 LLM 파인튜닝의 모든 요구사항을 충족하는 포괄적인 프레임워크입니다. 주요 장점은 다음과 같습니다:

**기술적 우수성**:

- 최신 파인튜닝 기법 지원 (LoRA, QLoRA, DPO, GRPO 등)
- 고성능 최적화 (Flash Attention, Sequence Parallelism 등)
- 확장 가능한 분산 훈련 (Multi-GPU, Multi-node)

**사용 편의성**:

- 단일 YAML 설정 파일로 전체 파이프라인 관리
- 풍부한 예제와 문서
- 활발한 커뮤니티 지원

**실무 적용성**:

- 다양한 모델 아키텍처 지원
- 클라우드 및 온프레미스 환경 호환
- 도메인 특화 모델 개발 지원

Axolotl을 통해 연구자와 엔지니어는 복잡한 구현 세부사항에 얽매이지 않고 모델 개선과 혁신에 집중할 수 있습니다. 지속적인 업데이트와 커뮤니티 기여를 통해 LLM 파인튜닝의 표준 도구로 자리잡고 있습니다.

더 자세한 정보는 [Axolotl GitHub 저장소](https://github.com/axolotl-ai-cloud/axolotl)에서 확인할 수 있습니다.
