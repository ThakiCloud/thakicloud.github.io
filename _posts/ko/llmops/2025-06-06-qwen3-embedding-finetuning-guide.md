---
title: "Qwen3-Embedding 파인튜닝 완전 가이드"
date: 2025-06-06
categories: 
  - llmops
  - machine-learning
tags: 
  - qwen3
  - embedding
  - finetuning
  - deepspeed
  - lora
author_profile: true
toc: true
toc_label: "목차"
---

이 포스트에서는 Qwen3-Embedding 모델을 사용자 정의 검색 및 추천 작업에 맞게 파인튜닝하는 방법을 자세히 알아보겠습니다. DeepSpeed와 LoRA 기법을 활용한 효율적인 미세 조정 과정을 단계별로 설명드리겠습니다.

## Qwen3-Embedding 파인튜닝 개요

Qwen3-Embedding은 Alibaba에서 개발한 강력한 임베딩 모델입니다. 이 모델을 내 도메인에 특화된 검색 및 추천 시스템에 맞게 커스터마이징하는 것이 이번 가이드의 목표입니다.

### 핵심 기술 스택

- **DeepSpeed**: 멀티 GPU 환경에서 학습 속도를 높여주는 프레임워크
- **Tevatron**: 문서 검색용 임베딩 모델 학습·평가 라이브러리
- **LoRA(Low-Rank Adapter)**: 기존 모델 파라미터를 거의 건드리지 않고 가볍게 미세 조정하는 기법
- **SciFact 데이터셋**: 과학 주장과 관련 논문을 매칭한 공개 검색 데이터셋

## 파인튜닝 명령어 전체

```bash
deepspeed --include localhost:0,1,2,3 --master_port 60000 --module tevatron.retriever.driver.train \
  --deepspeed deepspeed/ds_zero3_config.json \
  --output_dir retriever-qwen3-emb-ft \
  --model_name_or_path Qwen/Qwen3-Embedding-4B \
  --lora \
  --lora_target_modules q_proj,k_proj,v_proj,o_proj,down_proj,up_proj,gate_proj \
  --save_steps 50 \
  --dataset_name Tevatron/scifact \
  --query_prefix "Find a relevant scientific paper abstract to support or reject the claim. Query: " \
  --passage_prefix "" \
  --bf16 \
  --pooling eos \
  --append_eos_token \
  --normalize \
  --temperature 0.01 \
  --per_device_train_batch_size 8 \
  --gradient_checkpointing \
  --train_group_size 16 \
  --learning_rate 1e-4 \
  --query_max_len 32 \
  --passage_max_len 512 \
  --num_train_epochs 10 \
  --logging_steps 10 \
  --overwrite_output_dir \
  --gradient_accumulation_steps 1
```

## 파라미터 상세 분석

### 인프라 설정

| 파라미터 | 설명 |
|---------|------|
| `deepspeed --include localhost:0,1,2,3 --master_port 60000` | 로컬 GPU 4장을 사용한 분산 학습 설정 |
| `--module tevatron.retriever.driver.train` | Tevatron의 학습 모듈 실행 |
| `--deepspeed deepspeed/ds_zero3_config.json` | ZeRO-3 메모리 효율 기법 적용 |

### 모델 및 LoRA 설정

| 파라미터 | 설명 |
|---------|------|
| `--model_name_or_path Qwen/Qwen3-Embedding-4B` | 40억 파라미터 Qwen3 임베딩 모델 사용 |
| `--lora` | LoRA 미세 조정 활성화 |
| `--lora_target_modules q_proj,k_proj,v_proj,o_proj,down_proj,up_proj,gate_proj` | Attention 및 MLP 레이어에 LoRA 어댑터 적용 |
| `--output_dir retriever-qwen3-emb-ft` | 학습된 모델 저장 디렉토리 |

### 데이터 및 전처리 설정

| 파라미터 | 설명 |
|---------|------|
| `--dataset_name Tevatron/scifact` | SciFact 데이터셋 사용 |
| `--query_prefix "Find a relevant scientific paper abstract..."` | 검색 쿼리 프롬프트 설정 |
| `--passage_prefix ""` | 문서 프리픽스 없음 |
| `--query_max_len 32` | 쿼리 최대 토큰 길이 |
| `--passage_max_len 512` | 문서 최대 토큰 길이 |

### 학습 하이퍼파라미터

| 파라미터 | 설명 |
|---------|------|
| `--learning_rate 1e-4` | LoRA에 적합한 학습률 |
| `--num_train_epochs 10` | 총 학습 에폭 수 |
| `--per_device_train_batch_size 8` | GPU당 배치 크기 |
| `--gradient_accumulation_steps 1` | 기울기 누적 없이 즉시 업데이트 |

### 임베딩 및 최적화 설정

| 파라미터 | 설명 |
|---------|------|
| `--pooling eos --append_eos_token` | EOS 토큰 기반 문장 임베딩 추출 |
| `--normalize` | L2 정규화 적용 |
| `--temperature 0.01` | 대조학습 온도 (낮을수록 구분이 명확) |
| `--bf16` | 16-bit 부동소수점으로 메모리 절약 |
| `--gradient_checkpointing` | 메모리 효율을 위한 체크포인팅 |

## 커스터마이징 옵션

### 모델 크기 선택

```bash
# 경량 모델 (메모리 부족 시)
--model_name_or_path Qwen/Qwen3-Embedding-0.6B

# 표준 모델 (권장)
--model_name_or_path Qwen/Qwen3-Embedding-4B

# 대용량 모델 (최고 성능)
--model_name_or_path Qwen/Qwen3-Embedding-8B
```

### 도메인별 데이터셋 변경

```bash
# 법률 도메인 예시
--dataset_name my-org/legal-qa-dataset
--query_prefix "Find relevant legal precedent for the case: "

# 의료 도메인 예시
--dataset_name my-org/medical-papers
--query_prefix "Find medical research paper related to: "
```

### LoRA 타깃 모듈 조절

```bash
# 최소한의 어댑터 (빠른 학습)
--lora_target_modules q_proj,v_proj

# 전체 어댑터 (최고 성능)
--lora_target_modules q_proj,k_proj,v_proj,o_proj,down_proj,up_proj,gate_proj,embed_tokens
```

## 학습 결과 활용

학습이 완료되면 `retriever-qwen3-emb-ft` 디렉토리에 LoRA 어댑터 가중치가 저장됩니다.

### 추론 시 모델 로드

```python
from transformers import AutoModel, AutoTokenizer

# 기본 모델과 어댑터 함께 로드
model = AutoModel.from_pretrained(
    "Qwen/Qwen3-Embedding-4B",
    adapter_name_or_path="retriever-qwen3-emb-ft",
    trust_remote_code=True
)
tokenizer = AutoTokenizer.from_pretrained("Qwen/Qwen3-Embedding-4B")

# 임베딩 추출 예시
def get_embeddings(texts):
    inputs = tokenizer(texts, padding=True, truncation=True, return_tensors="pt")
    with torch.no_grad():
        outputs = model(**inputs)
        embeddings = outputs.last_hidden_state[:, -1, :]  # EOS 토큰 임베딩
        return F.normalize(embeddings, p=2, dim=1)  # L2 정규화

# 사용 예시
query_embedding = get_embeddings(["Find papers about machine learning"])
doc_embeddings = get_embeddings(["This paper discusses neural networks..."])
```

## 성능 모니터링

학습 과정에서 주요 메트릭을 모니터링하세요:

- **Loss**: 점진적으로 감소해야 함
- **Learning Rate**: LoRA의 경우 1e-4 ~ 1e-3 범위 권장
- **GPU 메모리 사용량**: ZeRO-3로 효율적 관리
- **처리 속도**: DeepSpeed로 가속화

## 마무리

Qwen3-Embedding 파인튜닝을 통해 도메인 특화된 검색 시스템을 구축할 수 있습니다. LoRA와 DeepSpeed를 활용하면 제한된 자원으로도 효과적인 미세 조정이 가능합니다.

여러분의 특정 사용 사례에 맞게 데이터셋과 하이퍼파라미터를 조정하여 최적의 성능을 달성해보세요.
