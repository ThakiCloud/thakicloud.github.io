---
title: "Unsloth Docker로 LLM 파인튜닝 완벽 가이드: 설치부터 실전까지"
excerpt: "Unsloth Docker 컨테이너를 사용하여 대규모 언어 모델을 효율적으로 파인튜닝하는 방법을 배워보세요. 설치, 설정, 실습 예제까지 포함한 종합 튜토리얼입니다."
seo_title: "Unsloth Docker LLM 파인튜닝 튜토리얼 - 완벽 가이드 2025"
seo_description: "Unsloth Docker로 LLM 파인튜닝을 마스터하세요. 설치, GPU 설정, Jupyter Lab 접근, 실전 훈련 예제를 포함한 단계별 튜토리얼로 효율적인 모델 커스터마이징을 배워보세요."
date: 2025-10-03
categories:
  - tutorials
tags:
  - unsloth
  - docker
  - llm
  - fine-tuning
  - machine-learning
  - gpu
  - jupyter
  - nvidia
author_profile: true
toc: true
toc_label: "목차"
lang: ko
permalink: /ko/tutorials/unsloth-docker-llm-training-tutorial/
canonical_url: "https://thakicloud.github.io/ko/tutorials/unsloth-docker-llm-training-tutorial/"
published: false
---

⏱️ **예상 읽기 시간**: 12분

## 소개

대규모 언어 모델(LLM) 파인튜닝은 특화된 AI 애플리케이션을 만드는 데 점점 더 중요해지고 있습니다. 하지만 LLM 훈련을 위한 적절한 환경을 설정하는 것은 복잡한 의존성과 잠재적 충돌로 인해 어려울 수 있습니다. Unsloth의 Docker 솔루션은 효율적인 LLM 파인튜닝을 위한 사전 구성된 안정적인 환경을 제공하여 이러한 문제를 해결합니다.

이 종합 튜토리얼에서는 Unsloth의 Docker 이미지를 사용하여 로컬에서 LLM을 파인튜닝하는 방법을 초기 설정부터 실전 훈련 예제까지 모든 것을 다루어 살펴보겠습니다.

## Unsloth란 무엇인가?

Unsloth는 메모리 사용량을 줄이면서 LLM 파인튜닝을 가속화하도록 설계된 강력한 프레임워크입니다. 기존 파인튜닝 방법보다 상당한 성능 향상을 제공하여 소비자용 하드웨어에서도 더 큰 모델을 훈련할 수 있게 해줍니다.

### Unsloth Docker의 주요 장점

- **의존성 관리**: 완전히 격리된 환경으로 "의존성 지옥" 제거
- **시스템 안전성**: 루트 권한 없이 실행되어 시스템을 깨끗하게 유지
- **이식성**: 다양한 플랫폼과 설정에서 일관되게 작동
- **사전 구성된 환경**: 필요한 모든 도구와 라이브러리 포함
- **정기 업데이트**: 최신 개선사항으로 자주 업데이트

## 사전 요구사항

시작하기 전에 다음 사항을 확인하세요:

- **NVIDIA GPU**: 효율적인 훈련을 위해 필요 (RTX 3060 이상 권장)
- **Docker**: 시스템에 설치되고 실행 중
- **NVIDIA Container Toolkit**: 컨테이너 내 GPU 접근을 위해 필요
- **충분한 저장공간**: 모델과 데이터를 위해 최소 50GB 여유 공간
- **RAM**: 16GB 이상 권장

## 1단계: Docker 및 NVIDIA Container Toolkit 설치

### Docker 설치

Linux 시스템의 경우:
```bash
# 패키지 인덱스 업데이트
sudo apt-get update

# Docker 설치
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 사용자를 docker 그룹에 추가
sudo usermod -aG docker $USER
newgrp docker
```

다른 시스템의 경우 [공식 Docker 설치 가이드](https://docs.docker.com/get-docker/)를 참조하세요.

### NVIDIA Container Toolkit 설치

NVIDIA Container Toolkit은 Docker 컨테이너 내에서 GPU 접근을 가능하게 합니다:

```bash
# 버전 설정 (최신 안정 버전 사용)
export NVIDIA_CONTAINER_TOOLKIT_VERSION=1.17.8-1

# NVIDIA Container Toolkit 설치
sudo apt-get update && sudo apt-get install -y \
  nvidia-container-toolkit=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
  nvidia-container-toolkit-base=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
  libnvidia-container-tools=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
  libnvidia-container1=${NVIDIA_CONTAINER_TOOLKIT_VERSION}

# Docker 데몬 재시작
sudo systemctl restart docker
```

### 설치 확인

GPU 접근을 테스트해보세요:
```bash
# NVIDIA Docker 통합 테스트
docker run --rm --gpus all nvidia/cuda:11.8-base-ubuntu20.04 nvidia-smi
```

## 2단계: Unsloth Docker 컨테이너 실행

### 기본 컨테이너 설정

작업 디렉토리를 만들고 컨테이너를 실행하세요:

```bash
# 작업 디렉토리 생성
mkdir -p ~/unsloth-workspace
cd ~/unsloth-workspace

# 기본 설정으로 Unsloth 컨테이너 실행
docker run -d \
  --name unsloth-training \
  -e JUPYTER_PASSWORD="mypassword" \
  -p 8888:8888 \
  -p 2222:22 \
  -v $(pwd)/work:/workspace/work \
  --gpus all \
  unsloth/unsloth
```

### 고급 설정

프로덕션 사용을 위한 향상된 설정:

```bash
# 보안 접근을 위한 SSH 키 생성
ssh-keygen -t rsa -b 4096 -f ~/.ssh/unsloth_key

# 고급 설정으로 컨테이너 실행
docker run -d \
  --name unsloth-production \
  -e JUPYTER_PORT=8000 \
  -e JUPYTER_PASSWORD="secure_password_2024" \
  -e "SSH_KEY=$(cat ~/.ssh/unsloth_key.pub)" \
  -e USER_PASSWORD="unsloth2024" \
  -p 8000:8000 \
  -p 2222:22 \
  -v $(pwd)/work:/workspace/work \
  -v $(pwd)/models:/workspace/models \
  -v $(pwd)/datasets:/workspace/datasets \
  --gpus all \
  --restart unless-stopped \
  unsloth/unsloth
```

## 3단계: Jupyter Lab 접근

### 웹 인터페이스 접근

1. 브라우저를 열고 `http://localhost:8888`로 이동
2. 설정한 비밀번호 입력 (기본값: "unsloth")
3. 사전 로드된 노트북이 있는 Jupyter Lab 인터페이스 확인

### SSH 접근 (선택사항)

명령줄 접근을 위해:
```bash
# SSH를 통한 연결
ssh -i ~/.ssh/unsloth_key -p 2222 unsloth@localhost
```

## 4단계: 컨테이너 구조 이해

Unsloth 컨테이너는 다음과 같이 구성되어 있습니다:

```
/workspace/
├── work/                    # 마운트된 작업 디렉토리
├── unsloth-notebooks/       # 파인튜닝 예제 노트북
├── models/                  # 모델 저장소 (마운트된 경우)
└── datasets/               # 데이터셋 저장소 (마운트된 경우)

/home/unsloth/              # 사용자 홈 디렉토리
```

## 5단계: 첫 번째 파인튜닝 예제

Llama-3를 사용한 간단한 파인튜닝 예제를 만들어보겠습니다.

### 새 노트북 생성

1. Jupyter Lab에서 새 노트북 생성
2. 다음 코드 셀들을 추가:

```python
# 셀 1: 의존성 설치 및 임포트
from unsloth import FastLanguageModel
import torch

# 셀 2: 모델 로드
model, tokenizer = FastLanguageModel.from_pretrained(
    model_name="unsloth/llama-3-8b-bnb-4bit",
    max_seq_length=2048,
    dtype=None,
    load_in_4bit=True,
)

# 셀 3: LoRA 설정
model = FastLanguageModel.get_peft_model(
    model,
    r=16,
    target_modules=["q_proj", "k_proj", "v_proj", "o_proj",
                    "gate_proj", "up_proj", "down_proj"],
    lora_alpha=16,
    lora_dropout=0,
    bias="none",
    use_gradient_checkpointing="unsloth",
    random_state=3407,
    use_rslora=False,
    loftq_config=None,
)

# 셀 4: 데이터셋 준비
alpaca_prompt = """Below is an instruction that describes a task, paired with an input that provides further context. Write a response that appropriately completes the request.

### Instruction:
{}

### Input:
{}

### Response:
{}"""

def formatting_prompts_func(examples):
    instructions = examples["instruction"]
    inputs       = examples["input"]
    outputs      = examples["output"]
    texts = []
    for instruction, input, output in zip(instructions, inputs, outputs):
        text = alpaca_prompt.format(instruction, input, output) + tokenizer.eos_token
        texts.append(text)
    return { "text" : texts, }

# 데이터셋 로드
from datasets import load_dataset
dataset = load_dataset("yahma/alpaca-cleaned", split="train")
dataset = dataset.map(formatting_prompts_func, batched=True)

# 셀 5: 훈련 설정
from trl import SFTTrainer
from transformers import TrainingArguments

trainer = SFTTrainer(
    model=model,
    tokenizer=tokenizer,
    train_dataset=dataset,
    dataset_text_field="text",
    max_seq_length=2048,
    dataset_num_proc=2,
    packing=False,
    args=TrainingArguments(
        per_device_train_batch_size=2,
        gradient_accumulation_steps=4,
        warmup_steps=5,
        max_steps=60,
        learning_rate=2e-4,
        fp16=not torch.cuda.is_bf16_supported(),
        bf16=torch.cuda.is_bf16_supported(),
        logging_steps=1,
        optim="adamw_8bit",
        weight_decay=0.01,
        lr_scheduler_type="linear",
        seed=3407,
        output_dir="outputs",
    ),
)

# 셀 6: 훈련 시작
trainer_stats = trainer.train()
```

### 훈련 진행 상황 모니터링

훈련 과정에서 진행률 표시줄과 손실 메트릭이 표시됩니다. 이를 모니터링하여 훈련이 올바르게 진행되고 있는지 확인하세요.

## 6단계: 파인튜닝된 모델 저장 및 사용

### 다양한 형식으로 저장

```python
# Hugging Face 형식으로 저장
model.save_pretrained("my_finetuned_model")
tokenizer.save_pretrained("my_finetuned_model")

# Ollama용 GGUF 형식으로 저장
model.save_pretrained_gguf("my_model", tokenizer, quantization_method="q4_k_m")

# VLLM용으로 저장
model.save_pretrained_merged("my_model_vllm", tokenizer, save_method="merged_16bit")
```

### 모델 테스트

```python
# 추론 테스트
FastLanguageModel.for_inference(model)

inputs = tokenizer(
    [alpaca_prompt.format(
        "프랑스의 수도는 어디인가요?",
        "",
        ""
    )], return_tensors="pt").to("cuda")

outputs = model.generate(**inputs, max_new_tokens=64, use_cache=True)
print(tokenizer.batch_decode(outputs))
```

## 고급 설정 옵션

### 환경 변수

| 변수 | 설명 | 기본값 |
|------|------|--------|
| `JUPYTER_PASSWORD` | Jupyter Lab 비밀번호 | `unsloth` |
| `JUPYTER_PORT` | Jupyter Lab 포트 | `8888` |
| `SSH_KEY` | SSH 공개 키 | `None` |
| `USER_PASSWORD` | sudo용 사용자 비밀번호 | `unsloth` |

### GPU 메모리 최적화

GPU 메모리가 제한된 시스템의 경우:

```python
# 더 작은 배치 크기 사용
per_device_train_batch_size=1
gradient_accumulation_steps=8

# 그래디언트 체크포인팅 활성화
use_gradient_checkpointing="unsloth"

# 4비트 양자화 사용
load_in_4bit=True
```

### 멀티 GPU 훈련

여러 GPU가 있는 시스템의 경우:

```bash
# 모든 GPU로 컨테이너 실행
docker run -d \
  --gpus all \
  # ... 기타 매개변수
  unsloth/unsloth

# 훈련 스크립트에서 DataParallel 사용
model = torch.nn.DataParallel(model)
```

## 일반적인 문제 해결

### GPU가 감지되지 않는 경우

```bash
# GPU 가용성 확인
nvidia-smi

# Docker GPU 접근 확인
docker run --rm --gpus all nvidia/cuda:11.8-base-ubuntu20.04 nvidia-smi
```

### 메모리 문제

- 배치 크기 줄이기
- 그래디언트 체크포인팅 활성화
- 4비트 양자화 사용
- GPU 캐시 정리: `torch.cuda.empty_cache()`

### 컨테이너 접근 문제

```bash
# 컨테이너 상태 확인
docker ps -a

# 컨테이너 로그 보기
docker logs unsloth-training

# 컨테이너 재시작
docker restart unsloth-training
```

## 모범 사례

### 1. 데이터 관리

- 영구 저장을 위해 볼륨 마운트 사용
- 전용 디렉토리에 데이터셋 정리
- 중요한 모델 정기적으로 백업

### 2. 리소스 모니터링

```python
# GPU 사용량 모니터링
import GPUtil
GPUtil.showUtilization()

# 시스템 리소스 모니터링
import psutil
print(f"CPU: {psutil.cpu_percent()}%")
print(f"RAM: {psutil.virtual_memory().percent}%")
```

### 3. 보안 고려사항

- Jupyter 접근을 위한 강력한 비밀번호 사용
- SSH 키 인증 구현
- 컨테이너를 비루트 사용자로 실행
- Unsloth 이미지 정기적으로 업데이트

### 4. 성능 최적화

- GPU에 적합한 배치 크기 사용
- 혼합 정밀도 훈련 활성화
- 효과적인 더 큰 배치 크기를 위해 그래디언트 누적 활용
- 과적합 방지를 위해 훈련 메트릭 모니터링

## 프로덕션 배포

### Docker Compose 설정

더 쉬운 관리를 위한 `docker-compose.yml` 생성:

```yaml
version: '3.8'
services:
  unsloth:
    image: unsloth/unsloth
    container_name: unsloth-production
    environment:
      - JUPYTER_PASSWORD=secure_password
      - JUPYTER_PORT=8888
      - USER_PASSWORD=unsloth2024
    ports:
      - "8888:8888"
      - "2222:22"
    volumes:
      - ./work:/workspace/work
      - ./models:/workspace/models
      - ./datasets:/workspace/datasets
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
    restart: unless-stopped
```

### 자동화된 훈련 파이프라인

자동화된 워크플로우를 위한 훈련 스크립트 생성:

```python
#!/usr/bin/env python3
"""
자동화된 Unsloth 훈련 파이프라인
"""
import argparse
import json
from pathlib import Path
from unsloth import FastLanguageModel
from transformers import TrainingArguments
from trl import SFTTrainer

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--config", required=True, help="훈련 설정 JSON 파일")
    args = parser.parse_args()
    
    # 설정 로드
    with open(args.config) as f:
        config = json.load(f)
    
    # 모델 초기화
    model, tokenizer = FastLanguageModel.from_pretrained(
        model_name=config["model_name"],
        max_seq_length=config["max_seq_length"],
        load_in_4bit=config.get("load_in_4bit", True)
    )
    
    # LoRA 설정
    model = FastLanguageModel.get_peft_model(
        model,
        r=config["lora_r"],
        target_modules=config["target_modules"],
        lora_alpha=config["lora_alpha"],
        lora_dropout=config["lora_dropout"],
        bias="none",
        use_gradient_checkpointing="unsloth"
    )
    
    # 훈련 로직...
    print("훈련이 성공적으로 완료되었습니다!")

if __name__ == "__main__":
    main()
```

## 결론

Unsloth Docker는 설정 복잡성을 제거하면서 성능과 유연성을 유지하는 LLM 파인튜닝을 위한 훌륭한 솔루션을 제공합니다. 이 튜토리얼을 따라하면 이제 다음을 갖추게 되었습니다:

- 완전히 구성된 Unsloth 환경
- 기본 및 고급 설정 옵션에 대한 이해
- 파인튜닝 워크플로우에 대한 실전 경험
- 모범 사례 및 문제 해결 기법에 대한 지식

컨테이너화된 접근 방식은 재현 가능한 결과를 보장하고 다양한 환경에서 파인튜닝 작업을 쉽게 확장할 수 있게 해줍니다.

### 다음 단계

1. **다양한 모델 실험**: 다양한 모델 아키텍처 파인튜닝 시도
2. **고급 기법 탐구**: 강화학습 및 DPO 훈련 조사
3. **프로덕션 최적화**: 자동화된 훈련 파이프라인 구현
4. **성능 모니터링**: 포괄적인 로깅 및 모니터링 설정

### 추가 리소스

- [Unsloth 공식 문서](https://docs.unsloth.ai/)
- [Unsloth GitHub 저장소](https://github.com/unslothai/unsloth)
- [Docker 모범 사례](https://docs.docker.com/develop/best-practices/)
- [NVIDIA Container Toolkit 문서](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/)

즐거운 파인튜닝 되세요! 🚀
