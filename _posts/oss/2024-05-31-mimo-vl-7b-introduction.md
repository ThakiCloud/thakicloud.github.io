---
title: "MiMo-VL-7B: 소형 고성능 비전-언어 모델의 새로운 기준"
date: 2024-05-31
categories: 
  - oss
  - ai
tags: 
  - vision-language-model
  - multimodal
  - quantization
  - macos
author_profile: true
toc: true
toc_label: "목차"
---

## 개요

MiMo-VL-7B는 Xiaomi에서 개발한 소형 고성능 비전-언어 모델로, 7B 파라미터로도 대형 모델에 버금가는 성능을 달성한 혁신적인 모델입니다. 고해상도 ViT 인코더와 효율적인 MLP projector, 그리고 추론에 특화된 MiMo-7B 언어모델을 결합하여 **Compact + Powerful VLM**을 구현했습니다.

## 모델 특징

### 핵심 아키텍처

MiMo-VL-7B는 다음과 같은 구조로 설계되었습니다:

- **고해상도 ViT 인코더**: 세밀한 시각 정보를 보존하여 이미지 이해 능력을 극대화
- **MLP projector**: 효율적인 크로스모달 정렬을 통해 시각과 언어 정보를 연결
- **MiMo-7B 언어모델**: 복잡한 추론 능력을 제공하는 베이스 언어모델

### 모델 라인업

| 모델명 | 설명 |
|--------|------|
| **MiMo-VL-7B-SFT** | 4단계 프리트레이닝과 SFT가 완료된 기본 모델 |
| **MiMo-VL-7B-RL** | SFT 모델에 MORL(Mixed On-policy RL)을 적용한 성능 향상판 |

## 학습 파이프라인

### 4단계 프리트레이닝

1. **Projector warm-up**: 비전-언어 연결 구조 초기화
2. **Vision-language alignment**: 시각과 언어 정보 정렬
3. **일반 멀티모달 프리트레이닝**: 다양한 멀티모달 태스크 학습
4. **롱컨텍스트 SFT**: 긴 문맥 이해 능력 향상

### Post-training with MORL

MORL(Mixed On-policy Reinforcement Learning)을 통해 다음 보상을 혼합하여 파인튜닝:

- 인지(Perception) 보상
- 그라운딩(Grounding) 보상  
- 추론(Reasoning) 보상
- 선호(Preference) 보상

## 성능 평가

### 주요 성과

- **일반 VL 이해**: 오픈소스 최고 수준 달성
- **멀티모달 추론**: 복잡한 시각-언어 추론 태스크에서 우수한 성능
- **GUI 이해**: 사용자 인터페이스 이해 능력 탁월
- **내부 GPT-4o 평가**: 7B~72B 전체 모델 중 Elo 경쟁 1위 달성

### 핵심 발견

고품질 추론 데이터를 프리트레이닝 후반부에 대량 투입하면 성능이 지속적으로 상승하며, 포화 지점이 관찰되지 않았습니다. 이는 소형 모델에서도 충분한 데이터와 적절한 학습 전략으로 대형 모델 수준의 성능을 달성할 수 있음을 시사합니다.

## 맥북에서 양자화하여 사용하기

### 환경 설정

먼저 필요한 라이브러리를 설치합니다:

```bash
# Python 가상환경 생성 (권장)
python -m venv mimo_env
source mimo_env/bin/activate

# 필수 라이브러리 설치
pip install torch torchvision transformers
pip install accelerate bitsandbytes
pip install pillow requests
```

### 모델 다운로드 및 양자화

```python
import torch
from transformers import AutoModelForCausalLM, AutoTokenizer, BitsAndBytesConfig
from PIL import Image
import requests

# 양자화 설정 (4-bit 양자화)
quantization_config = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_compute_dtype=torch.float16,
    bnb_4bit_use_double_quant=True,
    bnb_4bit_quant_type="nf4"
)

# 모델 및 토크나이저 로드
model_name = "XiaomiMiMo/MiMo-VL-7B-RL"
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForCausalLM.from_pretrained(
    model_name,
    quantization_config=quantization_config,
    device_map="auto",
    torch_dtype=torch.float16
)
```

### 기본 사용법

```python
def generate_response(image_path, prompt):
    # 이미지 로드
    if image_path.startswith('http'):
        image = Image.open(requests.get(image_path, stream=True).raw)
    else:
        image = Image.open(image_path)
    
    # 입력 준비
    inputs = tokenizer(prompt, return_tensors="pt")
    
    # 추론 실행
    with torch.no_grad():
        outputs = model.generate(
            **inputs,
            max_new_tokens=512,
            do_sample=True,
            temperature=0.7,
            top_p=0.9
        )
    
    # 결과 디코딩
    response = tokenizer.decode(outputs[0], skip_special_tokens=True)
    return response

# 사용 예시
image_path = "path/to/your/image.jpg"
prompt = "이 이미지에서 무엇을 볼 수 있나요?"
result = generate_response(image_path, prompt)
print(result)
```

### 메모리 최적화 팁

맥북에서 더 효율적으로 사용하기 위한 추가 설정:

```python
# 8-bit 양자화 (더 적은 메모리 사용)
quantization_config_8bit = BitsAndBytesConfig(
    load_in_8bit=True,
    llm_int8_threshold=6.0,
    llm_int8_has_fp16_weight=False
)

# CPU 오프로딩 활성화
model = AutoModelForCausalLM.from_pretrained(
    model_name,
    quantization_config=quantization_config_8bit,
    device_map="auto",
    offload_folder="./offload",
    torch_dtype=torch.float16
)
```

### 성능 모니터링

```python
import psutil
import time

def monitor_usage():
    """시스템 리소스 사용량 모니터링"""
    cpu_percent = psutil.cpu_percent(interval=1)
    memory = psutil.virtual_memory()
    
    print(f"CPU 사용률: {cpu_percent}%")
    print(f"메모리 사용률: {memory.percent}%")
    print(f"사용 가능한 메모리: {memory.available / (1024**3):.2f} GB")

# 추론 전후 리소스 사용량 확인
monitor_usage()
```

## 배포 및 호환성

MiMo-VL-7B는 **Qwen2_5_VLForConditionalGeneration** 아키텍처와 완전 호환되어, 기존 Qwen2.5 VL 파이프라인을 그대로 사용할 수 있습니다. 

### 주요 배포 플랫폼

- **HuggingFace**: [https://huggingface.co/XiaomiMiMo/MiMo-VL-7B-RL](https://huggingface.co/XiaomiMiMo/MiMo-VL-7B-RL)
- **ModelScope**: 중국 내 사용자를 위한 미러 제공

## 결론

MiMo-VL-7B는 소형 모델의 한계를 뛰어넘어 대형 모델 수준의 성능을 달성한 혁신적인 비전-언어 모델입니다. 특히 맥북과 같은 개인용 하드웨어에서도 양자화를 통해 실용적으로 사용할 수 있어, 연구자와 개발자들에게 새로운 가능성을 제시합니다.

4단계 프리트레이닝과 MORL을 통한 체계적인 학습 방법론은 향후 소형 고성능 모델 개발의 새로운 표준이 될 것으로 기대됩니다. 