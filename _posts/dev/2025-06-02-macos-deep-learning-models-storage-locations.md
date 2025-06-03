---
title: "macOS 딥러닝 모델 저장 위치 완벽 가이드: 전문가가 정리한 로컬 캐시 관리법"
date: 2025-06-02
categories: 
  - dev
tags: 
  - macos
  - deep-learning
  - ai-models
  - storage-management
  - ollama
  - huggingface
  - pytorch
  - tensorflow
  - cache-management
author_profile: true
toc: true
toc_label: "목차"
---

macOS에서 딥러닝 개발을 하다 보면 다양한 플랫폼과 프레임워크에서 모델들이 로컬에 저장되는데, 이들이 어디에 저장되고 어떻게 관리되는지 파악하기 어려울 때가 있습니다. 특히 디스크 공간이 부족하거나 모델을 정리해야 할 때 각 시스템이 어떻게 캐시 및 모델 데이터를 관리하는지 알아야 효율적으로 관리할 수 있습니다. 이번 포스트에서는 **전문가 시각**에서 macOS의 주요 딥러닝 플랫폼별 모델 저장 위치를 체계적으로 정리해드리겠습니다.

## 주요 딥러닝 플랫폼별 모델 저장 위치

| 플랫폼 / 프레임워크 | 경로 | 설명 |
|-------------------|------|------|
| **Ollama** | `~/.ollama/models/` | Ollama 전용 모델 저장소. `blobs`에 모델 바이너리, `manifests`에 메타데이터 저장. |
| **LM Studio** | `~/.lmstudio/models/` | LM Studio에서 다운로드한 GGUF/MLX 기반 모델 저장 위치. 모델 이름 별로 폴더 관리. |
| **Hugging Face Transformers** | `~/.cache/huggingface/hub/` | `models--<org>--<model>` 구조로 저장되며, PyTorch, GGUF, Safetensors 등 다양한 포맷 지원. |
| **PyTorch Hub** | `~/.cache/torch/hub/` | `torch.hub.load()` 호출 시 사용됨. 레포지토리 clone 및 모델 weight 저장. |
| **Diffusers (Stable Diffusion)** | `~/.cache/huggingface/diffusers/` 또는 `huggingface/hub/` 내 | 텍스트-투-이미지 모델이나 LoRA, VAE 등이 저장됨. |
| **Transformers Datasets** | `~/.cache/huggingface/datasets/` | 모델이 아닌 학습/테스트용 데이터셋 저장 경로. |
| **TensorFlow / Keras** | `~/.keras/models/` 또는 `~/.keras/datasets/` | Keras의 `load_model` 및 `get_file()` 함수 사용 시 캐싱되는 모델/데이터 위치. |
| **MLX (Apple Metal용)** | `~/Library/Application Support/mlx/` 또는 LM Studio 내부 | MLX로 컴파일된 모델 캐시가 저장되는 경우가 있음 (환경설정에 따라 다름). |
| **DiffusionBee (GUI SD 앱)** | `~/Library/Application Support/DiffusionBee/` | Stable Diffusion GUI 앱인 DiffusionBee에서 모델, LoRA 등 저장하는 위치. |
| **Automatic1111 / WebUI** | 사용자 지정 경로 (예: `~/stable-diffusion-webui/models/`) | 사용자가 clone하거나 WebUI 설정에 따라 달라짐. Git 레포와 연결된 폴더 구조. |

## 실제 디렉토리 구조 예시

실제 사용자 시스템에서는 다음과 같은 구조로 모델들이 저장됩니다:

```bash
# Hugging Face 모델 예시
~/.cache/huggingface/hub/models--facebook--opt-1.3b/
~/.cache/huggingface/hub/models--microsoft--DialoGPT-medium/
~/.cache/huggingface/hub/models--runwayml--stable-diffusion-v1-5/

# LM Studio 모델 예시
~/.lmstudio/models/lmstudio-community/Meta-Llama-3-8B-Instruct-GGUF/
~/.lmstudio/models/microsoft/Phi-3-mini-4k-instruct-gguf/

# Ollama 모델 예시
~/.ollama/models/blobs/
~/.ollama/models/manifests/
```

이런 구조를 보면 다음과 같은 특징이 있습니다:

- **`huggingface/hub`**: 다양한 프레임워크가 통합적으로 사용하는 범용 캐시.
- **`ollama` / `lmstudio`**: 독립 앱 기반으로 자체 모델 경로 관리. 이름이나 구조가 고유함.
- **파일 크기**가 크므로 디스크 공간 관리에 유의해야 하며, 심볼릭 링크를 활용한 다른 드라이브로의 이동도 추천됩니다.

## 저장소별 파일 형식 상세 분석

### Hugging Face Hub (`~/.cache/huggingface/hub/`)

Hugging Face는 가장 다양한 파일 형식을 지원합니다:

```bash
models--facebook--opt-1.3b/
├── snapshots/
│   └── abc123def.../
│       ├── config.json              # 모델 설정 파일
│       ├── pytorch_model.bin        # PyTorch 바이너리 형식
│       ├── model.safetensors        # SafeTensors 형식 (권장)
│       ├── tokenizer.json           # 토크나이저 설정
│       ├── tokenizer_config.json    # 토크나이저 메타데이터
│       └── special_tokens_map.json  # 특수 토큰 매핑
```

**주요 파일 형식:**
- **`.safetensors`**: 메모리 안전한 텐서 직렬화 형식, 빠른 로딩 지원
- **`.bin` (PyTorch)**: 전통적인 PyTorch pickle 형식
- **`.h5` (TensorFlow/Keras)**: HDF5 기반 TensorFlow 형식
- **`.gguf`**: Quantized 모델용 GGML 후속 형식

### Ollama (`~/.ollama/models/`)

Ollama는 자체적인 모델 관리 시스템을 사용합니다:

```bash
~/.ollama/models/
├── blobs/
│   ├── sha256:abc123...    # 실제 모델 바이너리 (GGUF 기반)
│   ├── sha256:def456...    # 레이어별로 분할된 모델 조각들
│   └── sha256:ghi789...
└── manifests/
    └── registry.ollama.ai/
        └── library/
            └── llama2/
                └── 7b      # 모델 버전별 manifest
```

**특징:**
- **Content-addressable storage**: SHA256 해시 기반 중복 제거
- **GGUF 기반**: 양자화된 모델 형식으로 메모리 효율적
- **레이어 분할**: 큰 모델을 여러 조각으로 나누어 관리

### LM Studio (`~/.lmstudio/models/`)

LM Studio는 주로 GGUF 형식의 모델을 저장합니다:

```bash
~/.lmstudio/models/
└── microsoft/
    └── Phi-3-mini-4k-instruct-gguf/
        ├── Phi-3-mini-4k-instruct-f16.gguf      # FP16 정밀도
        ├── Phi-3-mini-4k-instruct-q4_k_m.gguf   # 4-bit 양자화
        ├── Phi-3-mini-4k-instruct-q8_0.gguf     # 8-bit 양자화
        └── README.md
```

**GGUF 양자화 레벨:**
- **`f16`**: 16-bit 부동소수점 (원본 품질)
- **`q8_0`**: 8-bit 양자화 (높은 품질)
- **`q4_k_m`**: 4-bit 양자화 (균형)
- **`q2_k`**: 2-bit 양자화 (최소 크기)

### PyTorch Hub (`~/.cache/torch/hub/`)

PyTorch Hub는 Git 레포지토리 기반으로 모델을 관리합니다:

```bash
~/.cache/torch/hub/
├── checkpoints/
│   ├── resnet50-19c8e357.pth        # 사전훈련된 가중치
│   ├── vgg16-397923af.pth
│   └── bert-base-uncased.tar.gz
└── facebookresearch_detr_main/      # Git clone된 레포지토리
    ├── models/
    ├── util/
    └── hubconf.py
```

**특징:**
- **`.pth`**: PyTorch 네이티브 체크포인트 형식
- **Git 기반**: 모델 코드와 가중치를 함께 관리
- **체크섬 검증**: 파일 무결성 자동 검증

### TensorFlow/Keras (`~/.keras/`)

Keras는 다양한 형식으로 모델을 저장합니다:

```bash
~/.keras/
├── models/
│   ├── vgg16_weights_tf_dim_ordering_tf_kernels.h5
│   ├── resnet50_weights_tf_dim_ordering_tf_kernels_notop.h5
│   └── bert_uncased_L-12_H-768_A-12.tar.gz
└── datasets/
    ├── mnist.npz
    ├── cifar-10-batches-py.tar.gz
    └── imdb.npz
```

**파일 형식:**
- **`.h5`**: HDF5 형식, 계층적 데이터 구조
- **`.pb`**: Protocol Buffer, TensorFlow SavedModel 형식
- **`.tflite`**: TensorFlow Lite, 모바일/엣지 최적화

## 고급 관리 팁

### 캐시 경로 변경

각 프레임워크의 캐시 경로는 환경변수로 변경할 수 있습니다:

```bash
# Hugging Face 캐시 경로 변경
export HF_HOME="/Volumes/ExternalDrive/huggingface"

# PyTorch 캐시 경로 변경  
export TORCH_HOME="/Volumes/ExternalDrive/torch"

# Ollama 모델 경로 변경
export OLLAMA_MODELS="/Volumes/ExternalDrive/ollama"

# TensorFlow 캐시 경로 변경
export TFHUB_CACHE_DIR="/Volumes/ExternalDrive/tensorflow"
```

### 용량 확인 및 관리

디스크 사용량을 확인하고 관리하는 명령어들입니다:

```bash
# 각 저장소별 용량 확인
du -sh ~/.ollama/models
du -sh ~/.cache/huggingface/hub
du -sh ~/.lmstudio/models
du -sh ~/.cache/torch/hub
du -sh ~/.keras/models

# 상위 10개 큰 파일 찾기
find ~/.cache/huggingface/hub -type f -exec du -sh {} + | sort -rh | head -10

# 30일 이상 사용하지 않은 모델 찾기
find ~/.cache/huggingface/hub -type f -atime +30 -name "*.bin" -o -name "*.safetensors"
```

### 심볼릭 링크를 이용한 외부 드라이브 활용

용량이 큰 모델들을 외부 드라이브로 이동하고 심볼릭 링크를 생성하는 방법입니다:

```bash
# 1. 외부 드라이브로 디렉토리 이동
sudo mv ~/.cache/huggingface /Volumes/ExternalDrive/

# 2. 심볼릭 링크 생성
ln -s /Volumes/ExternalDrive/huggingface ~/.cache/huggingface

# 3. 권한 확인
ls -la ~/.cache/huggingface
```

### 자동 정리 스크립트

정기적으로 사용하지 않는 모델을 정리하는 스크립트 예시입니다:

```bash
#!/bin/bash
# cleanup_models.sh

echo "🔍 모델 캐시 정리를 시작합니다..."

# 30일 이상 사용하지 않은 Hugging Face 모델 정리
echo "📁 Hugging Face 캐시 정리 중..."
find ~/.cache/huggingface/hub -type d -name "models--*" -atime +30 -exec rm -rf {} \;

# PyTorch Hub 임시 파일 정리
echo "🔥 PyTorch Hub 임시 파일 정리 중..."
find ~/.cache/torch/hub -name "*.tmp" -delete

# 정리 후 용량 확인
echo "💾 정리 후 용량 확인:"
du -sh ~/.cache/huggingface/hub
du -sh ~/.cache/torch/hub
du -sh ~/.ollama/models

echo "✅ 정리 완료!"
```

### 앱별 모델 삭제 방법

각 애플리케이션에서 제공하는 모델 삭제 기능을 활용하는 것이 안전합니다:

```bash
# Ollama 모델 삭제
ollama rm llama2:7b

# LM Studio는 GUI에서 모델 관리 탭 사용

# Hugging Face 캐시 정리 (Python)
python -c "from huggingface_hub import scan_cache_dir; scan_cache_dir().delete_revisions('unused').execute()"
```

## 모델 형식별 특징 요약

### 성능 비교

| 형식 | 로딩 속도 | 메모리 사용량 | 호환성 | 보안성 |
|------|----------|--------------|-------|-------|
| **SafeTensors** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **GGUF** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| **PyTorch (.pth)** | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ |
| **TensorFlow (.h5)** | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |

### 권장 사항

1. **새로운 프로젝트**: SafeTensors 형식 우선 사용
2. **메모리 제약 환경**: GGUF 양자화 모델 활용  
3. **프로덕션 환경**: 검증된 PyTorch/TensorFlow 형식 사용
4. **크로스 플랫폼**: Hugging Face Hub 통합 활용

macOS에서 딥러닝 모델을 효율적으로 관리하려면 각 플랫폼의 특성을 이해하고, 정기적인 정리와 모니터링이 필요합니다. 특히 디스크 공간이 제한적인 환경에서는 양자화된 모델이나 외부 저장소 활용을 적극 고려해보시기 바랍니다. 