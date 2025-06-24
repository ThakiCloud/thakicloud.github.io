---
title: "Kotaemon RAG 시스템 완전 구축 가이드: vLLM + Kubernetes + Helm 배포"
excerpt: "오픈소스 RAG 도구 kotaemon을 Kubernetes 환경에서 vLLM과 연동하여 완전한 RAG 시스템을 구축하는 전체 가이드"
date: 2025-06-24
categories: 
  - tutorials
  - llmops
tags: 
  - kotaemon
  - vLLM
  - Kubernetes
  - Helm
  - RAG
  - Embeddings
  - OpenAI-API
  - LLM
author_profile: true
toc: true
toc_label: "목차"
---

## 개요

[kotaemon](https://github.com/Cinnamon/kotaemon)은 **오픈소스 RAG(Retrieval-Augmented Generation) 기반 문서 대화 도구**로, 문서를 업로드하고 자연어로 질의할 수 있는 웹 UI를 제공합니다. 본 가이드에서는 **vLLM + Kubernetes** 환경에서 kotaemon을 완전히 구축하여 **Embeddings**와 **Chat Completions** 기능을 모두 활용하는 전체 워크플로우를 정리했습니다.

핵심은 **vLLM의 OpenAI-호환 서버**가 이미 `/v1/embeddings` 및 `/v1/chat/completions` 엔드포인트를 내장하고 있으므로, kotaemon에서는 "OpenAI" 타입의 리소스로만 등록하면 된다는 점입니다.

## 아키텍처 구성

전체 시스템은 다음과 같은 구조로 구성됩니다:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   kotaemon UI   │───▶│  vLLM Chat API  │───▶│   Chat Model    │
│                 │    │  (port 8002)    │    │ (Llama-3-8B)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
        │
        │
        ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Document      │───▶│ vLLM Embed API  │───▶│ Embedding Model │
│   Processing    │    │  (port 8001)    │    │ (e5-mistral-7b) │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## vLLM의 Task 제한사항 이해

**중요한 점**은 vLLM이 한 번에 하나의 작업(`--task`)만 지원한다는 것입니다:

| `--task` 값 | 지원되는 API 엔드포인트 | 설명 |
|------------|----------------------|------|
| `generate` | `/v1/completions`, `/v1/chat/completions` | 텍스트 생성 및 채팅 |
| `embed`    | `/v1/embeddings` | 문서 임베딩 |

따라서 **임베딩과 채팅 기능을 동시에 사용하려면 각각 별도의 vLLM 인스턴스를 실행**해야 합니다.

## 1단계: vLLM Helm Chart 설치

### Helm 리포지토리 등록

```bash
helm repo add vllm https://vllm-project.github.io/production-stack
helm repo update
```

### Chat 모델용 values-chat.yaml 설정

```yaml
# values-chat.yaml
model:
  repository: NousResearch/Meta-Llama-3-8B-Instruct
  task: generate  # 채팅/텍스트 생성용
  dtype: auto
service:
  type: LoadBalancer
  port: 8002
resources:
  limits:
    nvidia.com/gpu: 1
  requests:
    nvidia.com/gpu: 1
nodeSelector:
  accelerator: nvidia-tesla-k80  # GPU 노드 선택
```

### Embedding 모델용 values-embed.yaml 설정

```yaml
# values-embed.yaml
model:
  repository: intfloat/e5-mistral-7b-instruct
  task: embed  # 임베딩 전용
  dtype: auto
service:
  type: LoadBalancer
  port: 8001
resources:
  limits:
    nvidia.com/gpu: 1
  requests:
    nvidia.com/gpu: 1
nodeSelector:
  accelerator: nvidia-tesla-k80  # GPU 노드 선택
```

### 두 개의 vLLM 인스턴스 배포

```bash
# 채팅용 vLLM 배포
helm install vllm-chat vllm/vllm-stack -f values-chat.yaml

# 임베딩용 vLLM 배포
helm install vllm-embed vllm/vllm-stack -f values-embed.yaml
```

### 배포 상태 확인

```bash
kubectl get pods -l app.kubernetes.io/name=vllm
kubectl get svc -l app.kubernetes.io/name=vllm
```

성공적으로 배포되면 다음과 같은 서비스들이 생성됩니다:
- `vllm-chat-service`: 채팅 API (포트 8002)
- `vllm-embed-service`: 임베딩 API (포트 8001)

## 2단계: vLLM API 검증

### Embeddings API 테스트

```bash
curl http://<EMBED_SERVICE_HOST>:8001/v1/embeddings \
     -H "Content-Type: application/json" \
     -d '{
       "model": "intfloat/e5-mistral-7b-instruct",
       "input": ["hello world"]
     }'
```

### Chat Completions API 테스트

```bash
curl http://<CHAT_SERVICE_HOST>:8002/v1/chat/completions \
     -H "Content-Type: application/json" \
     -d '{
       "model": "NousResearch/Meta-Llama-3-8B-Instruct",
       "messages": [{"role": "user", "content": "Hello!"}]
     }'
```

정상적으로 응답이 오면 다음 단계로 진행합니다.

## 3단계: kotaemon 설치 및 설정

### kotaemon 설치

```bash
git clone https://github.com/Cinnamon/kotaemon.git
cd kotaemon
pip install -e .
```

### 환경변수 설정

```bash
cp .env.example .env
```

`.env` 파일에 다음 내용을 추가:

```bash
# Chat LLM 설정
OPENAI_API_KEY=EMPTY
OPENAI_API_BASE=http://<CHAT_SERVICE_HOST>:8002/v1

# Embedding 설정  
OPENAI_EMBEDDING_API_KEY=EMPTY
OPENAI_EMBEDDING_API_BASE=http://<EMBED_SERVICE_HOST>:8001/v1
```

## 4단계: kotaemon Resources 설정

kotaemon 웹 UI에서 **Resources** 탭에 접속하여 다음과 같이 모델을 등록합니다:

### Embedding 모델 등록

| 필드 | 값 |
|------|-----|
| **Name** | `local-vllm-embed` |
| **Provider** | `OpenAI` |
| **API Key** | `EMPTY` |
| **Base URL** | `http://<EMBED_SERVICE_HOST>:8001/v1` |
| **Model** | `intfloat/e5-mistral-7b-instruct` |

### Chat 모델 등록

| 필드 | 값 |
|------|-----|
| **Name** | `local-vllm-chat` |
| **Provider** | `OpenAI` |
| **API Key** | `EMPTY` |
| **Base URL** | `http://<CHAT_SERVICE_HOST>:8002/v1` |
| **Model** | `NousResearch/Meta-Llama-3-8B-Instruct` |

### 기본 모델 설정

1. **Default LLM** → `local-vllm-chat`
2. **Default Embedding** → `local-vllm-embed`
3. **Retrieval Settings**에서 "LLM Scoring Model"도 `local-vllm-chat`로 지정

## 5단계: 전체 시스템 검증

### Python SDK로 API 테스트

```python
from openai import OpenAI

# Embedding 테스트
embed_client = OpenAI(
    base_url="http://<EMBED_SERVICE_HOST>:8001/v1", 
    api_key="EMPTY"
)

embedding_result = embed_client.embeddings.create(
    model="intfloat/e5-mistral-7b-instruct",
    input=["kotaemon works with vLLM!"]
)
print(f"Embedding 벡터 길이: {len(embedding_result.data[0].embedding)}")

# Chat 테스트  
chat_client = OpenAI(
    base_url="http://<CHAT_SERVICE_HOST>:8002/v1",
    api_key="EMPTY"
)

chat_result = chat_client.chat.completions.create(
    model="NousResearch/Meta-Llama-3-8B-Instruct",
    messages=[{"role": "user", "content": "안녕하세요!"}]
)
print(f"응답: {chat_result.choices[0].message.content}")
```

### kotaemon UI에서 RAG 테스트

1. kotaemon 웹 UI 접속
2. 문서 업로드 (PDF, TXT 등)
3. **Ask Docs** 기능으로 문서에 대한 질문
4. GPU vLLM 서버에서 임베딩과 텍스트 생성이 처리되는지 확인

## 문제 해결 가이드

### 일반적인 문제들

| 증상 | 원인 & 해결책 |
|------|--------------|
| `404 Not Found: /v1/embeddings` | 모델을 `task=embed`로 배포했는지 확인. Helm Values의 `task: embed` 설정 검토 |
| `404 Not Found: /v1/chat/completions` | 모델을 `task=generate`로 배포했는지 확인. Helm Values의 `task: generate` 설정 검토 |
| 벡터 차원이 예상과 다름 | 선택한 임베딩 모델의 차원 확인 (모델 카드나 Hugging Face 문서 참조) |
| 낮은 처리 속도 | `max-num-seqs`, `gpu-memory-utilization` 등 Helm 값 조정 |
| kotaemon에서 "Unauthorized" | `api_key` 필드가 비어있으면 오류 발생. 더미 값 `EMPTY` 입력 |

### 로그 확인 방법

```bash
# vLLM 파드 로그 확인
kubectl logs -l app.kubernetes.io/name=vllm-chat
kubectl logs -l app.kubernetes.io/name=vllm-embed

# 서비스 상태 확인
kubectl get endpoints
```

## 성능 최적화 팁

### GPU 메모리 최적화

```yaml
# values.yaml에 추가
extraArgs:
  - --gpu-memory-utilization=0.8
  - --max-num-seqs=256
  - --dtype=float16
```

### 스케일링 설정

```yaml
# HPA(Horizontal Pod Autoscaler) 설정
autoscaling:
  enabled: true
  minReplicas: 1
  maxReplicas: 3
  targetCPUUtilizationPercentage: 70
```

## 참고 자료

- [vLLM Embeddings API & CLI 가이드](https://docs.vllm.ai/en/latest/serving/openai_compatible_server.html)
- [vLLM Embedding 예제 코드](https://github.com/vllm-project/vllm/blob/main/examples/online_serving/openai_embedding_client.py)
- [vLLM Helm Chart 문서](https://docs.vllm.ai/en/latest/deployment/frameworks/helm.html)
- [kotaemon Local Model 설정 가이드](https://cinnamon.github.io/kotaemon/local_model/)
- [kotaemon Embeddings 레퍼런스](https://cinnamon.github.io/kotaemon/reference/embeddings/)

## 마무리

위 절차를 따라 설정하면 **kotaemon ↔ vLLM** 환경에서 Chat LLM과 Embedding LLM을 모두 GPU 기반으로 호출하는 완전한 RAG 시스템을 구축할 수 있습니다. 

핵심은 **vLLM의 task 제한사항을 이해하고 각 기능별로 별도 인스턴스를 배포**하는 것입니다. 이를 통해 대용량 문서 처리와 실시간 질의응답이 가능한 엔터프라이즈급 RAG 서비스를 안정적으로 운영할 수 있습니다. 