---
title: "vLLM CLI: 명령줄에서 대화형 LLM 서버 구축 완전 가이드"
excerpt: "vLLM CLI를 활용한 LLM 서버 구축과 관리의 모든 것. 설치부터 고급 설정, 모니터링까지 단계별로 학습하세요."
seo_title: "vLLM CLI 튜토리얼 - LLM 서버 구축 완전 가이드 - Thaki Cloud"
seo_description: "vLLM CLI로 대화형 LLM 서버를 구축하는 완전 가이드. 설치, 설정, 모델 관리, 모니터링까지 macOS 실습 예제와 함께 제공"
date: 2025-08-18
last_modified_at: 2025-08-18
categories:
  - tutorials
  - llmops
tags:
  - vllm
  - llm
  - cli
  - python
  - gpu
  - ai-infrastructure
  - model-serving
  - huggingface
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/vllm-cli-comprehensive-tutorial-guide/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 15분

## 서론

대규모 언어 모델(LLM)을 로컬에서 효율적으로 서빙하고 싶으신가요? vLLM CLI는 명령줄 인터페이스를 통해 vLLM을 쉽게 관리할 수 있는 강력한 도구입니다. 복잡한 설정 파일 작성 없이도 직관적인 메뉴를 통해 모델을 서빙하고 모니터링할 수 있습니다.

이 튜토리얼에서는 vLLM CLI의 설치부터 고급 사용법까지 실제 실습과 함께 단계별로 알아보겠습니다.

### vLLM CLI란?

vLLM CLI는 vLLM(Very Large Language Model) 엔진을 위한 명령줄 인터페이스 도구입니다. 주요 특징은 다음과 같습니다:

- **대화형 모드**: 메뉴 기반의 직관적인 터미널 인터페이스
- **명령줄 모드**: 스크립트 자동화를 위한 직접 CLI 명령
- **모델 관리**: HuggingFace Hub과 로컬 모델 자동 검색
- **프로필 시스템**: 사전 정의된 최적화 설정
- **실시간 모니터링**: GPU 사용률과 서버 상태 추적
- **LoRA 지원**: 다양한 어댑터 모델 서빙

## 1. 환경 요구사항 및 준비

### 시스템 요구사항

```bash
# 필수 요구사항
- Python 3.11+
- CUDA 지원 GPU (권장)
- vLLM 패키지 설치
- Linux 또는 macOS
```

### GPU 요구사항 확인

먼저 시스템의 GPU 상태를 확인해보겠습니다:

```bash
# NVIDIA GPU 확인
nvidia-smi

# CUDA 버전 확인
nvcc --version

# PyTorch CUDA 지원 확인
python -c "import torch; print(f'CUDA 사용 가능: {torch.cuda.is_available()}')"
```

**💡 참고**: GPU가 없는 환경에서도 CPU 모드로 실행 가능하지만, 성능상 GPU 사용을 강력히 권장합니다.

## 2. vLLM CLI 설치

### 기본 설치 방법

```bash
# PyPI에서 설치
pip install vllm-cli

# 설치 확인
vllm-cli --version
```

### 개발 버전 설치 (최신 기능 사용)

```bash
# 레포지토리 클론
git clone https://github.com/Chen-zexi/vllm-cli.git
cd vllm-cli

# 가상환경 생성 (권장)
python -m venv vllm-cli-env
source vllm-cli-env/bin/activate  # Linux/macOS
# 또는 Windows: vllm-cli-env\Scripts\activate

# 의존성 설치
pip install -r requirements.txt
pip install hf-model-tool

# 개발 모드로 설치
pip install -e .
```

### 의존성 패키지 설치

```bash
# vLLM 및 필수 패키지 설치
pip install vllm torch transformers

# 선택사항: 추가 기능을 위한 패키지
pip install flash-attn  # Flash Attention 지원
pip install xformers   # 메모리 최적화
```

## 3. 기본 사용법

### 대화형 모드 시작

```bash
# vLLM CLI 대화형 모드 실행
vllm-cli
```

대화형 모드에서는 다음과 같은 메뉴가 표시됩니다:

```
┌─ vLLM CLI v0.2.3 ─┐
│                   │
│ 1. 모델 서빙      │
│ 2. 서버 상태      │
│ 3. 시스템 정보    │
│ 4. 설정 관리      │
│ 5. 로그 보기      │
│ 6. 종료           │
│                   │
└───────────────────┘
```

### 명령줄 모드 사용법

#### 기본 모델 서빙

```bash
# 기본 설정으로 모델 서빙
vllm-cli serve microsoft/DialoGPT-medium

# 특정 포트로 서빙
vllm-cli serve microsoft/DialoGPT-medium --port 8080

# 프로필 사용
vllm-cli serve microsoft/DialoGPT-medium --profile high_throughput
```

#### 모델 목록 조회

```bash
# 사용 가능한 모델 목록
vllm-cli models

# 로컬 모델만 표시
vllm-cli models --local-only

# HuggingFace Hub 모델 검색
vllm-cli models --search "llama"
```

#### 서버 상태 확인

```bash
# 활성 서버 목록
vllm-cli status

# 특정 포트 서버 정보
vllm-cli status --port 8000

# 서버 중지
vllm-cli stop --port 8000
```

## 4. 실제 실습: 로컬 환경에서 모델 서빙

### 테스트 환경 설정

먼저 테스트용 스크립트를 생성하겠습니다:

```bash
# 테스트 디렉토리 생성
mkdir -p ~/vllm-cli-test
cd ~/vllm-cli-test
```

#### 실제 macOS 테스트 결과

macOS 환경에서 테스트 스크립트를 실행한 결과입니다:

```bash
$ ./test-vllm-cli-setup.sh

🚀 vLLM CLI 테스트 시작
===========================
📍 현재 디렉토리: /Users/username/vllm-cli-test
🐍 Python 버전: Python 3.9.23
💻 시스템: Darwin arm64

1️⃣ vLLM CLI 설치 상태 확인
--------------------------------
❌ vLLM CLI가 설치되지 않았습니다.
💡 설치 방법:
   pip install vllm-cli
```

**테스트 스크립트 다운로드**:
- [test-vllm-cli-setup.sh](https://github.com/thakicloud/thakicloud.github.io/blob/main/tutorials/vllm-cli-test/test-vllm-cli-setup.sh)
- [setup-aliases.sh](https://github.com/thakicloud/thakicloud.github.io/blob/main/tutorials/vllm-cli-test/setup-aliases.sh)

### 실습 1: 작은 모델로 시작하기

CPU에서도 실행 가능한 작은 모델로 테스트해보겠습니다:

```bash
# 가벼운 모델 서빙 (CPU 모드)
vllm-cli serve microsoft/DialoGPT-small \
  --port 8000 \
  --max-model-len 512 \
  --gpu-memory-utilization 0.3
```

### 실습 2: 프로필 시스템 활용

vLLM CLI는 4가지 내장 프로필을 제공합니다:

#### 표준 프로필 (기본값)

```bash
# 표준 설정으로 서빙
vllm-cli serve microsoft/DialoGPT-medium --profile standard
```

#### 고성능 프로필

```bash
# 최대 처리량 최적화 설정
vllm-cli serve microsoft/DialoGPT-medium --profile high_throughput
```

```json
{
  "max_model_len": 8192,
  "gpu_memory_utilization": 0.95,
  "enable_chunked_prefill": true,
  "max_num_batched_tokens": 8192,
  "trust_remote_code": true,
  "enable_prefix_caching": true
}
```

#### 저메모리 프로필

```bash
# 메모리 제약 환경용 설정
vllm-cli serve microsoft/DialoGPT-medium --profile low_memory
```

```json
{
  "max_model_len": 4096,
  "gpu_memory_utilization": 0.70,
  "enable_chunked_prefill": false,
  "trust_remote_code": true,
  "quantization": "fp8"
}
```

#### MoE 최적화 프로필

```bash
# Mixture of Experts 모델용 설정
vllm-cli serve Qwen/Qwen2.5-72B-Instruct --profile moe_optimized
```

### 실습 3: 커스텀 설정으로 서빙

```bash
# 다중 GPU 환경에서 텐서 병렬화
vllm-cli serve meta-llama/Llama-2-7b-chat-hf \
  --tensor-parallel-size 2 \
  --quantization awq \
  --max-model-len 4096 \
  --gpu-memory-utilization 0.8
```

### 실습 4: API 테스트

서버가 실행되면 OpenAI 호환 API로 테스트할 수 있습니다:

```python
# test_api.py
import requests
import json

def test_vllm_api():
    url = "http://localhost:8000/v1/chat/completions"
    
    headers = {
        "Content-Type": "application/json"
    }
    
    data = {
        "model": "microsoft/DialoGPT-medium",
        "messages": [
            {"role": "user", "content": "안녕하세요! vLLM CLI 테스트입니다."}
        ],
        "max_tokens": 100,
        "temperature": 0.7
    }
    
    response = requests.post(url, headers=headers, data=json.dumps(data))
    
    if response.status_code == 200:
        result = response.json()
        print("✅ API 테스트 성공!")
        print(f"응답: {result['choices'][0]['message']['content']}")
    else:
        print(f"❌ API 테스트 실패: {response.status_code}")
        print(response.text)

if __name__ == "__main__":
    test_vllm_api()
```

```bash
# API 테스트 실행
python test_api.py
```

## 5. 고급 기능 활용

### LoRA 어댑터 서빙

vLLM CLI는 LoRA(Low-Rank Adaptation) 어댑터를 지원합니다:

```bash
# 베이스 모델과 LoRA 어댑터 함께 서빙
vllm-cli serve meta-llama/Llama-2-7b-hf \
  --enable-lora \
  --lora-modules chatbot=path/to/chatbot-lora \
  --max-lora-rank 64
```

### 모델 디렉토리 관리

커스텀 모델 디렉토리를 등록하여 자동 검색 기능을 활용할 수 있습니다:

```bash
# 커스텀 모델 디렉토리 추가
vllm-cli config add-model-dir /path/to/custom/models

# 모델 매니페스트 파일 생성
cat > models_manifest.json << EOF
{
  "custom-model-1": {
    "path": "/path/to/custom/model1",
    "description": "커스텀 모델 1"
  },
  "custom-model-2": {
    "path": "/path/to/custom/model2", 
    "description": "커스텀 모델 2"
  }
}
EOF
```

### 실시간 모니터링

대화형 모드에서 실시간 서버 모니터링을 사용할 수 있습니다:

```bash
# 대화형 모드 실행
vllm-cli

# 메뉴에서 "2. 서버 상태" 선택
# 실시간 GPU 사용률, 메모리 사용량, 요청 통계 확인
```

모니터링 화면 예시:
```
┌─ 서버 모니터링 ─┐
│ GPU 사용률: 75% │
│ GPU 메모리: 8.2/24GB │
│ 활성 요청: 3 │
│ 총 처리된 요청: 1,247 │
│ 평균 응답 시간: 245ms │
└─────────────────┘
```

## 6. 설정 파일 관리

### 사용자 설정 위치

vLLM CLI는 다음 위치에 설정을 저장합니다:

```bash
# 메인 설정 파일
~/.config/vllm-cli/config.yaml

# 사용자 프로필
~/.config/vllm-cli/user_profiles.json

# 캐시 파일
~/.config/vllm-cli/cache.json
```

### 커스텀 프로필 생성

```json
# ~/.config/vllm-cli/user_profiles.json
{
  "my_custom_profile": {
    "description": "나만의 최적화 설정",
    "config": {
      "max_model_len": 2048,
      "gpu_memory_utilization": 0.85,
      "temperature": 0.7,
      "top_p": 0.9,
      "trust_remote_code": true
    }
  }
}
```

### 환경 변수 설정

```bash
# ~/.zshrc 또는 ~/.bashrc에 추가

# ASCII 박스 문자 사용 (호환성)
export VLLM_CLI_ASCII_BOXES=true

# 로그 레벨 설정
export VLLM_CLI_LOG_LEVEL=INFO

# 별칭 설정
alias vllm="vllm-cli"
alias vllm-serve="vllm-cli serve"
alias vllm-status="vllm-cli status"
alias vllm-models="vllm-cli models"
```

## 7. 트러블슈팅 및 최적화

### 일반적인 문제 해결

#### 1. GPU 메모리 부족 오류

```bash
# 메모리 사용량 줄이기
vllm-cli serve MODEL_NAME \
  --gpu-memory-utilization 0.7 \
  --max-model-len 2048 \
  --quantization fp8
```

#### 2. 모델 로딩 실패

```bash
# 로그 확인
vllm-cli logs

# Trust remote code 활성화
vllm-cli serve MODEL_NAME --trust-remote-code
```

#### 3. 느린 추론 속도

```bash
# 고성능 프로필 사용
vllm-cli serve MODEL_NAME --profile high_throughput

# 또는 수동 최적화
vllm-cli serve MODEL_NAME \
  --enable-chunked-prefill \
  --enable-prefix-caching \
  --max-num-batched-tokens 8192
```

### 성능 최적화 팁

#### 1. 하드웨어 최적화

```bash
# 다중 GPU 활용
vllm-cli serve MODEL_NAME --tensor-parallel-size 4

# Flash Attention 활성화
vllm-cli serve MODEL_NAME --use-flash-attn
```

#### 2. 메모리 최적화

```bash
# 양자화 활용
vllm-cli serve MODEL_NAME --quantization awq

# KV 캐시 최적화
vllm-cli serve MODEL_NAME --kv-cache-dtype fp8
```

### 로그 분석

```bash
# 상세 로그 보기
vllm-cli logs --verbose

# 에러 로그만 필터링
vllm-cli logs --level ERROR

# 실시간 로그 스트리밍
vllm-cli logs --follow
```

## 8. 고급 사용 사례

### 프로덕션 환경 배포

#### Docker 컨테이너화

```dockerfile
# Dockerfile
FROM pytorch/pytorch:2.1.0-cuda12.1-devel

RUN pip install vllm-cli

EXPOSE 8000

CMD ["vllm-cli", "serve", "microsoft/DialoGPT-medium", "--host", "0.0.0.0"]
```

```bash
# 빌드 및 실행
docker build -t vllm-cli-server .
docker run -p 8000:8000 --gpus all vllm-cli-server
```

#### Kubernetes 배포

```yaml
# vllm-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vllm-cli-server
spec:
  replicas: 1
  selector:
    matchLabels:
      app: vllm-cli-server
  template:
    metadata:
      labels:
        app: vllm-cli-server
    spec:
      containers:
      - name: vllm-cli
        image: vllm-cli-server:latest
        ports:
        - containerPort: 8000
        resources:
          limits:
            nvidia.com/gpu: 1
```

### 멀티 모델 서빙

```bash
# 여러 모델을 다른 포트에서 동시 서빙
vllm-cli serve microsoft/DialoGPT-small --port 8000 &
vllm-cli serve microsoft/DialoGPT-medium --port 8001 &
vllm-cli serve microsoft/DialoGPT-large --port 8002 &

# 서버 상태 일괄 확인
vllm-cli status --all
```

### 자동화 스크립트

```bash
#!/bin/bash
# auto-serve.sh

MODEL_NAME=${1:-"microsoft/DialoGPT-medium"}
PORT=${2:-8000}

echo "🚀 Starting vLLM server with model: $MODEL_NAME"

# 기존 서버 확인 및 중지
if vllm-cli status --port $PORT > /dev/null 2>&1; then
    echo "⚠️  Server already running on port $PORT. Stopping..."
    vllm-cli stop --port $PORT
    sleep 5
fi

# 새 서버 시작
vllm-cli serve $MODEL_NAME \
    --port $PORT \
    --profile high_throughput \
    --trust-remote-code

echo "✅ Server started successfully on port $PORT"
```

## 9. 개발 환경 설정

### 개발자를 위한 설정

```bash
# 개발 의존성 설치
pip install -r requirements-dev.txt

# 사전 커밋 훅 설정
pre-commit install

# 테스트 실행
make test

# 코드 품질 검사
make lint
```

### 커스텀 확장

vLLM CLI는 플러그인 시스템을 통해 확장 가능합니다:

```python
# custom_plugin.py
from vllm_cli.plugins import Plugin

class CustomMonitoringPlugin(Plugin):
    def on_server_start(self, server_info):
        print(f"서버 시작됨: {server_info}")
    
    def on_request_processed(self, request_info):
        # 커스텀 메트릭 수집
        pass
```

### 성능 벤치마킹

```python
# benchmark.py
import time
import requests
import statistics

def benchmark_api(model_name, num_requests=100):
    url = "http://localhost:8000/v1/chat/completions"
    
    response_times = []
    
    for i in range(num_requests):
        start_time = time.time()
        
        response = requests.post(url, json={
            "model": model_name,
            "messages": [{"role": "user", "content": f"Test message {i}"}],
            "max_tokens": 50
        })
        
        end_time = time.time()
        response_times.append(end_time - start_time)
    
    print(f"평균 응답 시간: {statistics.mean(response_times):.3f}초")
    print(f"중간값: {statistics.median(response_times):.3f}초")
    print(f"최소/최대: {min(response_times):.3f}/{max(response_times):.3f}초")

if __name__ == "__main__":
    benchmark_api("microsoft/DialoGPT-medium")
```

## 10. 실제 테스트 및 검증

### macOS 환경에서의 실제 테스트

현재 macOS 환경에서 vLLM CLI를 테스트해보겠습니다:

```bash
# 현재 Python 환경 확인
python --version
which python

# vLLM CLI 설치 상태 확인
pip list | grep vllm
```

### 테스트 스크립트 생성

실제 동작하는 테스트 스크립트를 만들어 보겠습니다:

```bash
#!/bin/bash
# test-vllm-cli.sh

echo "🔍 vLLM CLI 테스트 시작"

# 1. 설치 확인
echo "1. 설치 상태 확인"
if command -v vllm-cli &> /dev/null; then
    echo "✅ vLLM CLI 설치됨"
    vllm-cli --version
else
    echo "❌ vLLM CLI 설치 필요"
    echo "pip install vllm-cli"
    exit 1
fi

# 2. 시스템 정보 확인
echo -e "\n2. 시스템 정보"
vllm-cli info

# 3. 사용 가능한 모델 목록
echo -e "\n3. 모델 목록 (처음 5개만)"
vllm-cli models | head -10

# 4. 현재 서버 상태
echo -e "\n4. 서버 상태"
vllm-cli status

echo -e "\n✅ 테스트 완료"
```

### 별칭 설정 가이드

개발 효율성을 위한 zsh 별칭을 설정해보겠습니다:

```bash
# ~/.zshrc에 추가할 별칭들

# vLLM CLI 관련 별칭
alias vllm="vllm-cli"
alias vserve="vllm-cli serve"
alias vstatus="vllm-cli status"
alias vmodels="vllm-cli models"
alias vinfo="vllm-cli info"
alias vlogs="vllm-cli logs"
alias vstop="vllm-cli stop"

# 자주 사용하는 명령어 조합
alias vquick="vllm-cli serve --profile standard"
alias vfast="vllm-cli serve --profile high_throughput" 
alias vmem="vllm-cli serve --profile low_memory"

# 테스트 관련
alias vtest="bash ~/scripts/test-vllm-cli.sh"

echo "✅ 별칭 설정이 ~/.zshrc에 추가되었습니다."
echo "다음 명령어로 적용하세요: source ~/.zshrc"
```

## 결론

vLLM CLI는 LLM 서빙과 관리를 위한 강력하고 사용자 친화적인 도구입니다. 이 튜토리얼에서 다룬 내용을 요약하면:

### 주요 학습 내용

1. **설치 및 기본 설정**: PyPI 설치부터 개발 환경 구성까지
2. **기본 사용법**: 대화형 모드와 명령줄 모드 활용
3. **실습 예제**: 실제 모델 서빙과 API 테스트
4. **고급 기능**: LoRA 어댑터, 커스텀 프로필, 모니터링
5. **프로덕션 배포**: Docker, Kubernetes 활용
6. **최적화 및 트러블슈팅**: 성능 튜닝과 문제 해결

### 다음 단계

- **실제 프로젝트 적용**: 학습한 내용을 바탕으로 실제 LLM 서비스 구축
- **커뮤니티 참여**: [GitHub 레포지토리](https://github.com/Chen-zexi/vllm-cli)에서 이슈 보고 및 기여
- **고급 주제 탐구**: 멀티 모달 모델, 분산 처리, 커스텀 플러그인 개발

vLLM CLI는 지속적으로 발전하고 있는 프로젝트입니다. 최신 기능과 업데이트 정보는 공식 문서와 GitHub 릴리즈 노트를 참고하시기 바랍니다.

### 추가 리소스

- **공식 문서**: [vLLM CLI GitHub](https://github.com/Chen-zexi/vllm-cli)
- **vLLM 엔진**: [vLLM 공식 문서](https://docs.vllm.ai/)
- **HuggingFace Hub**: [모델 라이브러리](https://huggingface.co/models)
- **커뮤니티**: GitHub Issues 및 Discussions

성공적인 LLM 서빙을 위해 이 가이드가 도움이 되기를 바랍니다! 🚀
