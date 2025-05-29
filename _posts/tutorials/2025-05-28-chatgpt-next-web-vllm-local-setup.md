---
title: "ChatGPT Next Web + vLLM 로컬 환경 구축 가이드 - HyperCLOVA X SEED 0.5B로 경량 한국어 AI"
date: 2025-05-28
categories: 
  - tutorials
  - ai
  - local-ai
tags: 
  - ChatGPT
  - vLLM
  - 로컬AI
  - 맥북
  - 자체호스팅
  - LLM
  - Next.js
  - HyperCLOVA
  - 한국어AI
author_profile: true
toc: true
toc_label: "목차"
excerpt: "ChatGPT Next Web과 vLLM을 맥북에서 연결하여 네이버 클로바의 HyperCLOVA X SEED 0.5B 모델로 경량 한국어 AI 환경을 구축하는 실전 가이드. Python 3.12와 Yarn을 활용한 최신 개발 환경 설정법을 포함합니다."
---

## 개요

이 가이드는 ChatGPT Next Web과 vLLM을 맥북에서 연결하여 네이버 클로바의 HyperCLOVA X SEED 0.5B 모델로 경량 한국어 AI 환경을 구축하는 방법을 다룹니다. OpenAI API 없이도 로컬에서 강력한 LLM 모델을 활용할 수 있는 자체 호스팅 솔루션입니다.

### 왜 로컬 환경인가?

- **프라이버시**: 모든 데이터가 로컬에서 처리
- **비용 절약**: API 사용료 없음
- **커스터마이징**: 모델과 설정을 자유롭게 조정
- **오프라인 사용**: 인터넷 연결 없이도 AI 활용 가능
- **실험 환경**: 다양한 모델과 설정을 안전하게 테스트

### 시스템 요구사항

#### 최소 요구사항
- **macOS**: 12.0 (Monterey) 이상
- **메모리**: 8GB RAM (0.5B 모델 기준)
- **저장공간**: 20GB 이상 여유 공간
- **프로세서**: Apple Silicon (M1/M2/M3) 또는 Intel x86_64

#### 권장 요구사항
- **메모리**: 16GB RAM 이상
- **저장공간**: 50GB 이상 SSD
- **프로세서**: Apple Silicon M1 이상

## 1단계: 개발 환경 준비

### Python 환경 설정

```bash
# Homebrew 설치 (없는 경우)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Python 3.12 설치
brew install python@3.12

# pyenv 설치 (Python 버전 관리)
brew install pyenv
echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init -)"' >> ~/.zshrc
source ~/.zshrc

# Python 3.12 설치 및 설정
pyenv install 3.12.8
pyenv global 3.12.8
```

### Node.js 환경 설정

```bash
# Node.js 22+ 설치
brew install node@22

# Yarn 설치
npm install -g yarn

# 버전 확인
node --version  # v22.0.0+
yarn --version  # 1.22.0+
```

### Git 설정 확인

```bash
# Git 설치 확인
git --version

# Git 설정 (필요한 경우)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

## 2단계: vLLM 서버 설치 및 설정

### vLLM 설치

#### 방법 1: pip 설치 (간단한 방법)

```bash
# 가상환경 생성
python -m venv vllm-env
source vllm-env/bin/activate

# vLLM 설치 (Apple Silicon 최적화)
pip install vllm

# 추가 의존성 설치
pip install torch torchvision torchaudio
pip install transformers accelerate
pip install fastapi uvicorn
```

#### 방법 2: 소스 빌드 (macOS Apple Silicon 권장)

macOS Apple Silicon에서 최적의 성능을 위해서는 소스에서 빌드하는 것을 권장합니다.

```bash
# 가상환경 생성 및 활성화
python -m venv vllm-env
source vllm-env/bin/activate

# 종속 패키지 설치
brew install llvm cmake coreutils wget

# Clang 18+ 설정 (Apple Silicon 최적화)
export CC=/opt/homebrew/opt/llvm/bin/clang
export CXX=/opt/homebrew/opt/llvm/bin/clang++

# CPU 빌드 강제 설정 (Apple Silicon에서 안정성 향상)
export FORCE_CPU=1

# vLLM 소스 클론 및 빌드
git clone https://github.com/vllm-project/vllm.git
cd vllm

# CPU 전용 요구사항 설치
pip install -r requirements/cpu.txt
# 소스에서 빌드
pip install -e . 

echo "✅ vLLM 소스 빌드 완료"
```

#### Build image from source¶

```bash
# vLLM 설치 확인
$ docker build -f docker/Dockerfile.cpu --tag vllm-cpu-env --target vllm-openai .

# Launching OpenAI server 
$ docker run --rm \
             --privileged=true \
             --shm-size=4g \
             -p 8000:8000 \
             -e VLLM_CPU_KVCACHE_SPACE=<KV cache space> \
             -e VLLM_CPU_OMP_THREADS_BIND=<CPU cores for inference> \
             vllm-cpu-env \
             --model=meta-llama/Llama-3.2-1B-Instruct \
             --dtype=bfloat16 \
             other vLLM OpenAI server arguments
```

#### 빌드 확인

```bash
# vLLM 설치 확인
python -c "import vllm; print(f'vLLM 버전: {vllm.__version__}')"

# CPU 모드 확인
python -c "import vllm; print('vLLM CPU 모드 설치 완료')"
```

### 모델 다운로드 및 설정

#### 추천 모델 목록

```bash
# 1. HyperCLOVA X SEED 0.5B (경량 한국어 모델)
# 모델 크기: ~1GB
MODEL_NAME="naver-hyperclovax/HyperCLOVAX-SEED-Text-Instruct-0.5B"

MODEL_NAME="Mungert/HyperCLOVAX-SEED-Text-Instruct-0.5B-GGUF"
# 2. CodeLlama 7B (코딩 특화)
# 모델 크기: ~13GB  
MODEL_NAME="codellama/CodeLlama-7b-Instruct-hf"

# 3. Mistral 7B (성능 우수)
# 모델 크기: ~13GB
MODEL_NAME="mistralai/Mistral-7B-Instruct-v0.1"

# 4. Qwen 7B (다국어 지원)
# 모델 크기: ~13GB
MODEL_NAME="Qwen/Qwen-7B-Chat"

# 5. 한국어 특화 모델
MODEL_NAME="beomi/KoAlpaca-Polyglot-12.8B"
```

#### 모델 사전 다운로드

```bash
# Hugging Face CLI 설치
pip install huggingface_hub

# 모델 다운로드 (예: HyperCLOVA X SEED 0.5B)
huggingface-cli download naver-hyperclovax/HyperCLOVAX-SEED-Text-Instruct-0.5B \
  --local-dir ./models/HyperCLOVAX-SEED-Text-Instruct-0.5Bb \
  --local-dir-use-symlinks False

huggingface-cli download Mungert/HyperCLOVAX-SEED-Text-Instruct-0.5B-GGUF \
  --local-dir ./models/HyperCLOVAX-SEED-Text-Instruct-0.5B-GGUF \
  --local-dir-use-symlinks False

python - <<EOF
from huggingface_hub import hf_hub_download

print(
    hf_hub_download(
        repo_id="Mungert/HyperCLOVAX-SEED-Text-Instruct-0.5B-GGUF",
        filename="HyperCLOVAX-SEED-Text-Instruct-0.5B-f16.gguf"
    )
)
EOF
```

### vLLM 서버 실행 스크립트 작성

```bash
# vllm-server.py 파일 생성
cat > vllm-server.py << 'EOF'
#!/usr/bin/env python3
"""
vLLM 서버 실행 스크립트
ChatGPT Next Web과 호환되는 OpenAI API 형식으로 서비스 제공
"""

import argparse
import asyncio
from vllm import AsyncLLMEngine, AsyncEngineArgs
from vllm.sampling_params import SamplingParams
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
import uvicorn
import time
import uuid

app = FastAPI(title="vLLM OpenAI Compatible Server")

# CORS 설정 (ChatGPT Next Web 연결용)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 전역 변수
engine = None
model_name = None

# OpenAI API 호환 모델 정의
class ChatMessage(BaseModel):
    role: str
    content: str

class ChatCompletionRequest(BaseModel):
    model: str
    messages: List[ChatMessage]
    temperature: Optional[float] = 0.7
    max_tokens: Optional[int] = 2048
    stream: Optional[bool] = False
    top_p: Optional[float] = 0.9
    frequency_penalty: Optional[float] = 0.0
    presence_penalty: Optional[float] = 0.0

class ChatCompletionResponse(BaseModel):
    id: str
    object: str = "chat.completion"
    created: int
    model: str
    choices: List[Dict[str, Any]]
    usage: Dict[str, int]

@app.get("/v1/models")
async def list_models():
    """사용 가능한 모델 목록 반환"""
    return {
        "object": "list",
        "data": [
            {
                "id": model_name,
                "object": "model",
                "created": int(time.time()),
                "owned_by": "vllm",
                "permission": [],
                "root": model_name,
                "parent": None,
            }
        ]
    }

@app.post("/v1/chat/completions")
async def create_chat_completion(request: ChatCompletionRequest):
    """채팅 완성 API (OpenAI 호환)"""
    if engine is None:
        raise HTTPException(status_code=503, detail="Model not loaded")
    
    # 메시지를 프롬프트로 변환
    prompt = format_messages_to_prompt(request.messages)
    
    # 샘플링 파라미터 설정
    sampling_params = SamplingParams(
        temperature=request.temperature,
        max_tokens=request.max_tokens,
        top_p=request.top_p,
        frequency_penalty=request.frequency_penalty,
        presence_penalty=request.presence_penalty,
    )
    
    # 추론 실행
    request_id = str(uuid.uuid4())
    results = engine.generate(prompt, sampling_params, request_id)
    
    # 결과를 비동기적으로 수집
    final_output = None
    async for request_output in results:
        final_output = request_output
    
    if final_output is None:
        raise HTTPException(status_code=500, detail="Generation failed")
    
    # OpenAI API 형식으로 응답 구성
    response = ChatCompletionResponse(
        id=f"chatcmpl-{request_id}",
        created=int(time.time()),
        model=request.model,
        choices=[
            {
                "index": 0,
                "message": {
                    "role": "assistant",
                    "content": final_output.outputs[0].text.strip()
                },
                "finish_reason": "stop"
            }
        ],
        usage={
            "prompt_tokens": len(final_output.prompt_token_ids),
            "completion_tokens": len(final_output.outputs[0].token_ids),
            "total_tokens": len(final_output.prompt_token_ids) + len(final_output.outputs[0].token_ids)
        }
    )
    
    return response

def format_messages_to_prompt(messages: List[ChatMessage]) -> str:
    """메시지 목록을 모델에 맞는 프롬프트로 변환"""
    prompt_parts = []
    
    for message in messages:
        if message.role == "system":
            prompt_parts.append(f"System: {message.content}")
        elif message.role == "user":
            prompt_parts.append(f"Human: {message.content}")
        elif message.role == "assistant":
            prompt_parts.append(f"Assistant: {message.content}")
    
    prompt_parts.append("Assistant:")
    return "\n\n".join(prompt_parts)

async def init_engine(model_path: str, tensor_parallel_size: int = 1):
    """vLLM 엔진 초기화"""
    global engine, model_name
    
    engine_args = AsyncEngineArgs(
        model=model_path,
        tensor_parallel_size=tensor_parallel_size,
        dtype="auto",
        trust_remote_code=True,
        max_model_len=4096,  # 메모리에 따라 조정
        gpu_memory_utilization=0.8,  # GPU 메모리 사용률
    )
    
    engine = AsyncLLMEngine.from_engine_args(engine_args)
    model_name = model_path.split("/")[-1]
    print(f"✅ 모델 로드 완료: {model_name}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--model", type=str, required=True, help="모델 경로")
    parser.add_argument("--host", type=str, default="127.0.0.1", help="서버 호스트")
    parser.add_argument("--port", type=int, default=8000, help="서버 포트")
    parser.add_argument("--tensor-parallel-size", type=int, default=1, help="텐서 병렬 크기")
    
    args = parser.parse_args()
    
    # 엔진 초기화
    asyncio.run(init_engine(args.model, args.tensor_parallel_size))
    
    # 서버 실행
    print(f"🚀 vLLM 서버 시작: http://{args.host}:{args.port}")
    uvicorn.run(app, host=args.host, port=args.port)
EOF

chmod +x vllm-server.py
```

### vLLM 서버 실행

#### 방법 1: 커스텀 Python 스크립트 사용

```bash
# 가상환경 활성화
source vllm-env/bin/activate

# 서버 실행 (HyperCLOVA X SEED 0.5B 예시)
python vllm-server.py \
  --model naver-hyperclovax/HyperCLOVAX-SEED-Text-Instruct-0.5B \
  --host 127.0.0.1 \
  --port 8000

# 또는 로컬 다운로드된 모델 사용
python vllm-server.py \
  --model ./models/HyperCLOVAX-SEED-Text-Instruct-0.5B \
  --host 127.0.0.1 \
  --port 8000

python vllm-server.py \
  --model ./models/hyperclovax-f16 \
  --host 127.0.0.1 \
  --port 8000
```

#### 방법 2: vLLM CLI 직접 사용 (Apple Silicon CPU 모드)

```bash
# 가상환경 활성화
source vllm-env/bin/activate

# CPU 모드로 서버 실행 (Apple Silicon 최적화)
vllm serve naver-hyperclovax/HyperCLOVAX-SEED-Text-Instruct-0.5B \
  --device cpu \
  --max-num-seqs 4 \
  --host 127.0.0.1 \
  --port 8000

# 또는 로컬 모델 경로 사용
vllm serve ./models/HyperCLOVAX-SEED-Text-Instruct-0.5B \
  --device cpu \
  --max-num-seqs 4 \
  --host 127.0.0.1 \
  --port 8000

vllm serve ./models/hyperclovax-f16 \
  --device cpu \
  --max-num-seqs 4 \
  --host 127.0.0.1 \
  --port 8000

```

#### CPU 모드 최적화 옵션

```bash
# 메모리 제한 환경에서의 최적화 실행
vllm serve naver-hyperclovax/HyperCLOVAX-SEED-Text-Instruct-0.5B\
  --device cpu \
  --max-num-seqs 2 \
  --max-model-len 1024 \
  --host 127.0.0.1 \
  --port 8000 \
  --disable-log-requests
```

### 서버 상태 확인

```bash
# 새 터미널에서 실행
# 모델 목록 확인
curl http://localhost:8000/v1/models

# 간단한 채팅 테스트
curl -X POST http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "naver-hyperclovax/HyperCLOVAX-SEED-Text-Instruct-0.5B",
    "messages": [
      {"role": "user", "content": "안녕하세요! 자기소개를 해주세요."}
    ],
    "temperature": 0.7,
    "max_tokens": 100
  }'

```

## 3단계: ChatGPT Next Web 설치 및 설정

### 프로젝트 클론 및 설정

```bash
# 새 터미널 열기
# ChatGPT Next Web 클론
git clone https://github.com/ChatGPTNextWeb/NextChat.git
cd NextChat

# 의존성 설치 (yarn 사용)
yarn install
```

### 환경 변수 설정

```bash
# .env.local 파일 생성
cat > .env.local << 'EOF'
# vLLM 서버 설정
OPENAI_API_KEY=sk-dummy-key-for-local-vllm
BASE_URL=http://localhost:8000/v1

# 접근 제어 (선택사항)
CODE=1234

# 기능 설정
HIDE_USER_API_KEY=1
DISABLE_GPT4=0
CUSTOM_MODELS=hyperclova-x-seed-0.5b

# 개발 환경 설정
NEXT_PUBLIC_BUILD_MODE=development
NEXT_PUBLIC_COMMIT_ID=local-vllm
EOF
```

### 커스텀 모델 설정

```typescript
// app/constant.ts 파일 수정
// 또는 새로운 설정 파일 생성: app/config/local-models.ts

export const LOCAL_MODELS = [
  {
    name: "hyperclova-x-seed-0.5b",
    displayName: "HyperCLOVA X SEED 0.5B",
    provider: "vLLM",
    maxTokens: 2048,
    description: "네이버 클로바의 경량 한국어 특화 모델"
  },
  {
    name: "codellama-7b-instruct", 
    displayName: "CodeLlama 7B",
    provider: "vLLM",
    maxTokens: 4096,
    description: "코딩 특화 로컬 모델"
  }
];
```

### ChatGPT Next Web 실행

```bash
# 개발 서버 시작
yarn dev

# 또는 프로덕션 빌드
yarn build && yarn start
```

## 4단계: 연결 테스트 및 최적화

### 연결 확인

1. **브라우저에서 접속**: `http://localhost:3000`
2. **설정 페이지 이동**: 우측 상단 설정 아이콘 클릭
3. **API 설정 확인**:
   - API Host: `http://localhost:8000/v1`
   - API Key: `sk-dummy-key-for-local-vllm`
   - 모델: `hyperclova-x-seed-0.5b`

### 성능 최적화

#### vLLM 서버 최적화

```bash
# 메모리 최적화 실행 (0.5B 모델은 메모리 사용량이 적음)
python vllm-server.py \
  --model naver-clova-ix/HyperCLOVA-X-SEED-0.5B \
  --host 127.0.0.1 \
  --port 8000 \
  --max-model-len 2048 \
  --gpu-memory-utilization 0.3 \
  --swap-space 2
```

#### 시스템 리소스 모니터링

```bash
# 메모리 사용량 확인
top -pid $(pgrep -f vllm-server)

# GPU 사용량 확인 (Apple Silicon)
sudo powermetrics --samplers gpu_power -n 1

# 네트워크 연결 확인
lsof -i :8000
lsof -i :3000
```

## 5단계: 고급 설정 및 커스터마이징

### 다중 모델 서버 설정

```bash
# 모델별 포트 분리 실행 스크립트
cat > start-multi-models.sh << 'EOF'
#!/bin/bash

# HyperCLOVA X SEED 0.5B (포트 8000)
python vllm-server.py \
  --model naver-clova-ix/HyperCLOVA-X-SEED-0.5B \
  --port 8000 &

# CodeLlama 7B (포트 8001)  
python vllm-server.py \
  --model codellama/CodeLlama-7b-Instruct-hf \
  --port 8001 &

# 한국어 모델 (포트 8002)
python vllm-server.py \
  --model beomi/KoAlpaca-Polyglot-12.8B \
  --port 8002 &

echo "모든 모델 서버가 시작되었습니다."
echo "HyperCLOVA X SEED: http://localhost:8000"
echo "CodeLlama: http://localhost:8001" 
echo "KoAlpaca: http://localhost:8002"
EOF

chmod +x start-multi-models.sh
```

### 로드 밸런서 설정

```nginx
# nginx.conf (Homebrew nginx 사용)
upstream vllm_backend {
    server 127.0.0.1:8000 weight=3;
    server 127.0.0.1:8001 weight=2;
    server 127.0.0.1:8002 weight=1;
}

server {
    listen 9000;
    server_name localhost;
    
    location /v1/ {
        proxy_pass http://vllm_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_connect_timeout 300s;
        proxy_send_timeout 300s;
        proxy_read_timeout 300s;
    }
}
```

### 자동 시작 스크립트

```bash
# auto-start.sh 생성
cat > auto-start.sh << 'EOF'
#!/bin/bash

echo "🚀 로컬 AI 환경 시작 중..."

# vLLM 가상환경 활성화 및 서버 시작
echo "📦 vLLM 서버 시작..."
source vllm-env/bin/activate

# 방법 1: 커스텀 Python 스크립트 사용
python vllm-server.py \
  --model naver-clova-ix/HyperCLOVA-X-SEED-0.5B \
  --host 127.0.0.1 \
  --port 8000 &

# 방법 2: vLLM CLI 직접 사용 (Apple Silicon CPU 모드)
# vllm serve naver-clova-ix/HyperCLOVA-X-SEED-0.5B \
#   --device cpu \
#   --max-num-seqs 4 \
#   --host 127.0.0.1 \
#   --port 8000 &

VLLM_PID=$!
echo "vLLM 서버 PID: $VLLM_PID"

# 서버 시작 대기
sleep 10

# ChatGPT Next Web 시작
echo "🌐 ChatGPT Next Web 시작..."
cd NextChat
yarn dev &

NEXTJS_PID=$!
echo "Next.js 서버 PID: $NEXTJS_PID"

echo "✅ 모든 서비스가 시작되었습니다!"
echo "📱 ChatGPT Next Web: http://localhost:3000"
echo "🤖 vLLM API: http://localhost:8000"

# 종료 시 모든 프로세스 정리
trap "echo '🛑 서비스 종료 중...'; kill $VLLM_PID $NEXTJS_PID; exit" INT TERM

# 백그라운드 프로세스 대기
wait
EOF

chmod +x auto-start.sh
```

## 6단계: 문제 해결 및 디버깅

### 일반적인 문제들

#### 1. 메모리 부족 오류

```bash
# 증상: OOM (Out of Memory) 에러
# 해결방법: (0.5B 모델은 메모리 사용량이 적어 문제가 적음)
python vllm-server.py \
  --model naver-clova-ix/HyperCLOVA-X-SEED-0.5B \
  --max-model-len 1024 \
  --gpu-memory-utilization 0.2 \
  --swap-space 1
```

#### 2. 모델 로딩 실패

```bash
# 모델 캐시 정리
rm -rf ~/.cache/huggingface/transformers/

# 모델 재다운로드
huggingface-cli download naver-clova-ix/HyperCLOVA-X-SEED-0.5B \
  --local-dir ./models/hyperclova-x-seed-0.5b \
  --local-dir-use-symlinks False \
  --resume-download
```

#### 3. API 연결 오류

```bash
# 포트 충돌 확인
lsof -i :8000
lsof -i :3000

# 방화벽 설정 확인 (macOS)
sudo pfctl -sr | grep 8000

# 네트워크 연결 테스트
curl -v http://localhost:8000/v1/models
```

#### 4. 성능 저하 문제

```bash
# CPU 사용률 확인
top -o cpu

# 메모리 압박 확인
vm_stat

# 디스크 I/O 확인
iostat -d 1
```

### 로그 분석

```bash
# vLLM 서버 로그 확인
tail -f vllm-server.log

# Next.js 로그 확인
tail -f .next/trace

# 시스템 로그 확인
log show --predicate 'process == "python"' --last 1h
```

### 성능 벤치마크

```python
# benchmark.py
import time
import requests
import json
import statistics

def benchmark_api(url, messages, num_requests=10):
    """API 성능 벤치마크"""
    response_times = []
    
    for i in range(num_requests):
        start_time = time.time()
        
        response = requests.post(f"{url}/v1/chat/completions", 
            headers={"Content-Type": "application/json"},
            json={
                "model": "hyperclova-x-seed-0.5b",
                "messages": messages,
                "max_tokens": 100
            }
        )
        
        end_time = time.time()
        response_times.append(end_time - start_time)
        
        print(f"요청 {i+1}: {response_times[-1]:.2f}초")
    
    print(f"\n📊 성능 통계:")
    print(f"평균 응답시간: {statistics.mean(response_times):.2f}초")
    print(f"최소 응답시간: {min(response_times):.2f}초")
    print(f"최대 응답시간: {max(response_times):.2f}초")
    print(f"표준편차: {statistics.stdev(response_times):.2f}초")

if __name__ == "__main__":
    messages = [{"role": "user", "content": "안녕하세요! 간단한 인사말을 해주세요."}]
    benchmark_api("http://localhost:8000", messages)
```

## 7단계: 보안 및 운영

### 보안 설정

```bash
# 방화벽 규칙 설정 (로컬 접근만 허용)
sudo pfctl -f /etc/pf.conf

# SSL 인증서 생성 (HTTPS 사용 시)
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes
```

### 모니터링 설정

```python
# monitoring.py
import psutil
import time
import json
from datetime import datetime

def monitor_system():
    """시스템 리소스 모니터링"""
    while True:
        stats = {
            "timestamp": datetime.now().isoformat(),
            "cpu_percent": psutil.cpu_percent(interval=1),
            "memory_percent": psutil.virtual_memory().percent,
            "disk_usage": psutil.disk_usage('/').percent,
            "network_io": psutil.net_io_counters()._asdict()
        }
        
        print(json.dumps(stats, indent=2))
        time.sleep(60)  # 1분마다 체크

if __name__ == "__main__":
    monitor_system()
```

### 백업 및 복구

```bash
# 설정 백업
tar -czf chatgpt-nextjs-backup-$(date +%Y%m%d).tar.gz \
  NextChat/.env.local \
  NextChat/app/config/ \
  vllm-server.py \
  auto-start.sh

# 모델 백업 (심볼릭 링크 제외)
rsync -av --exclude='*.git*' ./models/ ./models-backup/
```

## 마무리

### 완성된 환경 확인

1. **vLLM 서버**: `http://localhost:8000` - API 서버
2. **ChatGPT Next Web**: `http://localhost:3000` - 웹 인터페이스
3. **모델 관리**: Hugging Face Hub 연동
4. **모니터링**: 시스템 리소스 추적

### 다음 단계

1. **모델 실험**: 다양한 오픈소스 모델 테스트
2. **파인튜닝**: 특정 도메인에 맞는 모델 커스터마이징
3. **스케일링**: 다중 GPU 또는 분산 처리 환경 구축
4. **프로덕션**: Docker 컨테이너화 및 배포 자동화

### 추가 리소스

- **vLLM 공식 문서**: [https://docs.vllm.ai](https://docs.vllm.ai)
- **ChatGPT Next Web**: [https://github.com/ChatGPTNextWeb/NextChat](https://github.com/ChatGPTNextWeb/NextChat)
- **Hugging Face 모델 허브**: [https://huggingface.co/models](https://huggingface.co/models)
- **Apple Silicon 최적화**: [https://developer.apple.com/metal/](https://developer.apple.com/metal/)

이 가이드를 통해 완전한 로컬 AI 환경을 구축하여 프라이버시를 보장하면서도 강력한 AI 기능을 활용할 수 있습니다. 🚀 