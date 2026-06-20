---
title: "신입 개발자를 위한 macOS Kubernetes vLLM 추론 서비스 개발 완벽 가이드"
date: 2025-06-01
categories: 
  - dev
tags: 
  - kubernetes
  - vllm
  - llm-inference
  - macos
  - docker
  - ai-deployment
  - microservices
  - beginner-guide
author_profile: true
toc: true
toc_label: "목차"
published: false
---

AI 모델 추론 서비스를 Kubernetes 환경에서 운영하는 것은 현대 AI 개발의 핵심 스킬입니다. 특히 vLLM은 대규모 언어 모델의 고성능 추론을 위한 최고의 도구 중 하나입니다. 이번 포스트에서는 macOS 환경에서 Kubernetes 클러스터를 구축하고, vLLM을 사용한 추론 서비스를 개발하는 전 과정을 신입 개발자 관점에서 상세히 안내해드리겠습니다.

## 개요 및 아키텍처

### vLLM이란?

**vLLM**은 UC Berkeley에서 개발한 고성능 LLM 추론 엔진입니다:

- **PagedAttention**: 메모리 효율적인 어텐션 메커니즘
- **연속 배치**: 동적 배치 처리로 처리량 극대화
- **OpenAI 호환 API**: 기존 OpenAI API와 호환되는 인터페이스
- **다양한 모델 지원**: Llama, Mistral, Qwen 등 주요 오픈소스 모델

### 전체 아키텍처

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Client App    │───▶│  Load Balancer  │───▶│   vLLM Pod 1    │
└─────────────────┘    │   (Ingress)     │    ├─────────────────┤
                       └─────────────────┘    │   vLLM Pod 2    │
                                ▲             ├─────────────────┤
                                │             │   vLLM Pod N    │
                       ┌─────────────────┐    └─────────────────┘
                       │  Kubernetes     │
                       │   Cluster       │
                       └─────────────────┘
```

## 개발 환경 설정

### 1. 필수 도구 설치

#### Homebrew 설치 (미설치 시)

```bash
# Homebrew 설치
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### Docker Desktop 설치

```bash
# Docker Desktop 설치
brew install --cask docker

# Docker Desktop 실행 후 Kubernetes 활성화
# Docker Desktop > Settings > Kubernetes > Enable Kubernetes
```

#### kubectl 설치

```bash
# kubectl 설치
brew install kubectl

# 설치 확인
kubectl version --client
```

#### Helm 설치

```bash
# Helm 설치 (패키지 관리자)
brew install helm

# 설치 확인
helm version
```

#### 기타 유용한 도구들

```bash
# k9s (Kubernetes 클러스터 모니터링)
brew install k9s

# kubectx (컨텍스트 전환)
brew install kubectx

# stern (로그 스트리밍)
brew install stern
```

### 2. 로컬 Kubernetes 클러스터 설정

#### Docker Desktop Kubernetes 확인

```bash
# 클러스터 상태 확인
kubectl cluster-info

# 노드 확인
kubectl get nodes

# 컨텍스트 확인
kubectl config current-context
```

#### 네임스페이스 생성

```bash
# vLLM 전용 네임스페이스 생성
kubectl create namespace vllm-inference

# 기본 네임스페이스 설정
kubectl config set-context --current --namespace=vllm-inference
```

## vLLM Docker 이미지 준비 (macOS CPU 버전)

### 1. macOS용 CPU 전용 vLLM 이미지 테스트

macOS에서는 GPU 버전이 아닌 CPU 전용 vLLM을 사용해야 합니다:

```bash
# CPU 전용 vLLM 이미지 다운로드 및 테스트
docker run --rm -it \
  -p 8000:8000 \
  --platform linux/amd64 \
  --memory=8g \
  --cpus=4 \
  vllm/vllm-openai:latest \
  --model bartowski/deepseek-ai_DeepSeek-R1-0528-Qwen3-8B-GGUF \
  --revision main \
  --host 0.0.0.0 \
  --port 8000 \
  --dtype auto \
  --enforce-eager \
  --disable-log-requests
```

### 2. macOS 최적화 커스텀 vLLM 이미지 생성

프로젝트 디렉토리를 생성하고 macOS에 최적화된 커스텀 이미지를 만들어보겠습니다:

```bash
# 프로젝트 디렉토리 생성
mkdir -p ~/vllm-k8s-project
cd ~/vllm-k8s-project
```

#### Dockerfile 작성 (macOS CPU 최적화)

```dockerfile
# Dockerfile - macOS CPU 최적화 버전
FROM --platform=linux/amd64 python:3.11-slim

# 시스템 업데이트 및 필수 패키지 설치
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 작업 디렉토리 설정
WORKDIR /app

# vLLM CPU 버전 설치
RUN pip install --no-cache-dir \
    vllm[cpu] \
    torch \
    transformers \
    huggingface-hub \
    prometheus-client \
    structlog \
    uvicorn[standard] \
    requests

# 헬스체크 스크립트 추가
COPY healthcheck.py /app/
COPY entrypoint.sh /app/

# 실행 권한 부여
RUN chmod +x /app/entrypoint.sh

# 포트 노출
EXPOSE 8000

# 환경변수 설정
ENV PYTHONUNBUFFERED=1
ENV VLLM_CPU_ONLY=1
ENV OMP_NUM_THREADS=4

# 엔트리포인트 설정
ENTRYPOINT ["/app/entrypoint.sh"]
```

#### 헬스체크 스크립트 작성

```python
# healthcheck.py
#!/usr/bin/env python3
"""vLLM 서비스 헬스체크 스크립트 - macOS CPU 버전"""

import requests
import sys
import json
import time
from typing import Dict, Any

def check_health() -> bool:
    """vLLM 서비스 상태 확인"""
    try:
        # 헬스체크 엔드포인트 호출
        response = requests.get(
            "http://localhost:8000/health",
            timeout=10
        )
        
        if response.status_code == 200:
            print("✅ vLLM CPU 서비스가 정상 작동 중입니다.")
            return True
        else:
            print(f"❌ 헬스체크 실패: HTTP {response.status_code}")
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"❌ 헬스체크 요청 실패: {e}")
        return False

def check_model_ready() -> bool:
    """모델 로딩 상태 확인"""
    try:
        # 모델 정보 엔드포인트 호출
        response = requests.get(
            "http://localhost:8000/v1/models",
            timeout=30
        )
        
        if response.status_code == 200:
            models = response.json()
            if models.get("data"):
                print(f"✅ DeepSeek 모델 로딩 완료: {len(models['data'])}개 모델 사용 가능")
                for model in models.get('data', []):
                    print(f"  - {model.get('id', 'Unknown')}")
                return True
            else:
                print("❌ 로딩된 모델이 없습니다.")
                return False
        else:
            print(f"❌ 모델 상태 확인 실패: HTTP {response.status_code}")
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"❌ 모델 상태 확인 요청 실패: {e}")
        return False

def test_inference() -> bool:
    """간단한 추론 테스트"""
    try:
        payload = {
            "model": "bartowski/deepseek-ai_DeepSeek-R1-0528-Qwen3-8B-GGUF",
            "prompt": "Hello, how are you?",
            "max_tokens": 50,
            "temperature": 0.7
        }
        
        response = requests.post(
            "http://localhost:8000/v1/completions",
            json=payload,
            timeout=60
        )
        
        if response.status_code == 200:
            result = response.json()
            print("✅ 추론 테스트 성공")
            print(f"  응답: {result['choices'][0]['text'][:100]}...")
            return True
        else:
            print(f"❌ 추론 테스트 실패: HTTP {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ 추론 테스트 오류: {e}")
        return False

if __name__ == "__main__":
    print("🔍 vLLM CPU 서비스 상태 확인 시작...")
    
    # 서비스 시작 대기
    print("⏳ 서비스 시작 대기 중...")
    time.sleep(10)
    
    health_ok = check_health()
    model_ok = check_model_ready()
    inference_ok = test_inference() if health_ok and model_ok else False
    
    if health_ok and model_ok and inference_ok:
        print("🎉 모든 상태 확인 완료! CPU 기반 vLLM 서비스가 정상 작동합니다.")
        sys.exit(0)
    else:
        print("💥 상태 확인 실패!")
        sys.exit(1)
```

#### 엔트리포인트 스크립트 작성 (macOS CPU 최적화)

```bash
# entrypoint.sh - macOS CPU 최적화 버전
#!/bin/bash
set -e

echo "🚀 macOS CPU 최적화 vLLM 서비스를 시작합니다..."

# 환경변수 기본값 설정 (DeepSeek 모델 사용)
MODEL_NAME=${MODEL_NAME:-"bartowski/deepseek-ai_DeepSeek-R1-0528-Qwen3-8B-GGUF"}
MODEL_FILE=${MODEL_FILE:-"deepseek-ai_DeepSeek-R1-0528-Qwen3-8B-Q4_0.gguf"}
HOST=${HOST:-"0.0.0.0"}
PORT=${PORT:-"8000"}
MAX_MODEL_LEN=${MAX_MODEL_LEN:-"4096"}
MAX_TOKENS=${MAX_TOKENS:-"1024"}

echo "📋 macOS CPU 최적화 설정 정보:"
echo "  - 모델: $MODEL_NAME"
echo "  - 모델 파일: $MODEL_FILE"
echo "  - 호스트: $HOST"
echo "  - 포트: $PORT"
echo "  - 최대 모델 길이: $MAX_MODEL_LEN"
echo "  - CPU 전용 모드: 활성화"

# CPU 최적화 환경변수 설정
export VLLM_CPU_ONLY=1
export OMP_NUM_THREADS=4
export MKL_NUM_THREADS=4
export NUMEXPR_NUM_THREADS=4

# vLLM CPU 서버 시작
exec python -m vllm.entrypoints.openai.api_server \
    --model "$MODEL_NAME" \
    --revision main \
    --host "$HOST" \
    --port "$PORT" \
    --max-model-len "$MAX_MODEL_LEN" \
    --max-num-seqs 8 \
    --dtype auto \
    --enforce-eager \
    --disable-log-requests \
    --cpu-only \
    "$@"
```

#### 이미지 빌드

```bash
# macOS CPU 최적화 Docker 이미지 빌드
docker build --platform linux/amd64 -t vllm-cpu-custom:latest .

# 빌드된 이미지 확인
docker images | grep vllm-cpu-custom

# 로컬에서 테스트 실행
docker run --rm -it \
  --platform linux/amd64 \
  -p 8000:8000 \
  --memory=8g \
  --cpus=4 \
  vllm-cpu-custom:latest
```

## Kubernetes 매니페스트 작성

### 1. ConfigMap 생성

```yaml
# k8s/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: vllm-config
  namespace: vllm-inference
data:
  MODEL_NAME: "bartowski/deepseek-ai_DeepSeek-R1-0528-Qwen3-8B-GGUF"
  MODEL_FILE: "deepseek-ai_DeepSeek-R1-0528-Qwen3-8B-Q4_0.gguf"
  HOST: "0.0.0.0"
  PORT: "8000"
  MAX_MODEL_LEN: "4096"
  MAX_TOKENS: "1024"
  LOG_LEVEL: "INFO"
  # CPU 전용 설정
  VLLM_CPU_ONLY: "1"
  OMP_NUM_THREADS: "4"
  MKL_NUM_THREADS: "4"
  NUMEXPR_NUM_THREADS: "4"
```

### 2. Deployment 생성

```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vllm-inference
  namespace: vllm-inference
  labels:
    app: vllm-inference
spec:
  replicas: 2
  selector:
    matchLabels:
      app: vllm-inference
  template:
    metadata:
      labels:
        app: vllm-inference
    spec:
      containers:
      - name: vllm
        image: vllm-cpu-custom:latest
        imagePullPolicy: Never  # 로컬 이미지 사용
        ports:
        - containerPort: 8000
          name: http
        envFrom:
        - configMapRef:
            name: vllm-config
        env:
        - name: VLLM_CPU_ONLY
          value: "1"
        - name: OMP_NUM_THREADS
          value: "4"
        - name: PYTHONUNBUFFERED
          value: "1"
        resources:
          requests:
            memory: "6Gi"
            cpu: "2000m"
          limits:
            memory: "12Gi"
            cpu: "4000m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 120
          periodSeconds: 30
          timeoutSeconds: 15
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 60
          periodSeconds: 10
          timeoutSeconds: 10
          failureThreshold: 5
        lifecycle:
          preStop:
            exec:
              command: ["/bin/sh", "-c", "sleep 30"]
      terminationGracePeriodSeconds: 60
      # macOS 환경에서의 안정성을 위한 설정
      nodeSelector:
        kubernetes.io/arch: amd64
```

### 3. Service 생성

```yaml
# k8s/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: vllm-service
  namespace: vllm-inference
  labels:
    app: vllm-inference
spec:
  type: ClusterIP
  ports:
  - port: 8000
    targetPort: 8000
    protocol: TCP
    name: http
  selector:
    app: vllm-inference
```

### 4. Ingress 생성

```yaml
# k8s/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: vllm-ingress
  namespace: vllm-inference
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/proxy-read-timeout: "300"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "300"
spec:
  rules:
  - host: vllm.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: vllm-service
            port:
              number: 8000
```

### 5. HorizontalPodAutoscaler 생성

```yaml
# k8s/hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: vllm-hpa
  namespace: vllm-inference
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: vllm-inference
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

## 배포 및 테스트

### 1. Kubernetes 리소스 배포

```bash
# k8s 디렉토리 생성
mkdir -p k8s

# 모든 매니페스트 파일을 k8s/ 디렉토리에 저장 후 배포
kubectl apply -f k8s/

# 배포 상태 확인
kubectl get all -n vllm-inference
```

### 2. 배포 상태 모니터링

```bash
# Pod 상태 실시간 모니터링
kubectl get pods -n vllm-inference -w

# 로그 확인
kubectl logs -f deployment/vllm-inference -n vllm-inference

# 여러 Pod 로그 동시 확인 (stern 사용)
stern vllm-inference -n vllm-inference
```

### 3. 서비스 테스트

#### 포트 포워딩으로 로컬 테스트

```bash
# 포트 포워딩 설정
kubectl port-forward service/vllm-service 8000:8000 -n vllm-inference
```

#### API 테스트 스크립트 작성

```python
# test_vllm_api.py
#!/usr/bin/env python3
"""vLLM API 테스트 스크립트"""

import requests
import json
import time
from typing import Dict, Any

class VLLMTester:
    def __init__(self, base_url: str = "http://localhost:8000"):
        self.base_url = base_url
        
    def test_health(self) -> bool:
        """헬스체크 테스트"""
        try:
            response = requests.get(f"{self.base_url}/health")
            print(f"✅ 헬스체크: {response.status_code}")
            return response.status_code == 200
        except Exception as e:
            print(f"❌ 헬스체크 실패: {e}")
            return False
    
    def test_models(self) -> bool:
        """모델 목록 조회 테스트"""
        try:
            response = requests.get(f"{self.base_url}/v1/models")
            if response.status_code == 200:
                models = response.json()
                print(f"✅ 사용 가능한 모델: {len(models.get('data', []))}개")
                for model in models.get('data', []):
                    print(f"  - {model.get('id', 'Unknown')}")
                return True
            else:
                print(f"❌ 모델 조회 실패: {response.status_code}")
                return False
        except Exception as e:
            print(f"❌ 모델 조회 오류: {e}")
            return False
    
    def test_completion(self) -> bool:
        """텍스트 완성 테스트"""
        try:
            payload = {
                "model": "bartowski/deepseek-ai_DeepSeek-R1-0528-Qwen3-8B-GGUF",
                "prompt": "Hello, how are you?",
                "max_tokens": 50,
                "temperature": 0.7
            }
            
            response = requests.post(
                f"{self.base_url}/v1/completions",
                json=payload,
                headers={"Content-Type": "application/json"},
                timeout=60  # DeepSeek 모델은 더 긴 시간이 필요할 수 있음
            )
            
            if response.status_code == 200:
                result = response.json()
                print("✅ 텍스트 완성 성공:")
                print(f"  입력: {payload['prompt']}")
                print(f"  출력: {result['choices'][0]['text']}")
                return True
            else:
                print(f"❌ 텍스트 완성 실패: {response.status_code}")
                print(f"  응답: {response.text}")
                return False
        except Exception as e:
            print(f"❌ 텍스트 완성 오류: {e}")
            return False
    
    def test_chat_completion(self) -> bool:
        """채팅 완성 테스트"""
        try:
            payload = {
                "model": "bartowski/deepseek-ai_DeepSeek-R1-0528-Qwen3-8B-GGUF",
                "messages": [
                    {"role": "user", "content": "안녕하세요! 간단한 Python 코드 예제를 보여주세요."}
                ],
                "max_tokens": 150,
                "temperature": 0.7
            }
            
            response = requests.post(
                f"{self.base_url}/v1/chat/completions",
                json=payload,
                headers={"Content-Type": "application/json"},
                timeout=90  # DeepSeek 모델은 더 긴 시간이 필요할 수 있음
            )
            
            if response.status_code == 200:
                result = response.json()
                print("✅ 채팅 완성 성공:")
                print(f"  사용자: {payload['messages'][0]['content']}")
                print(f"  AI: {result['choices'][0]['message']['content']}")
                return True
            else:
                print(f"❌ 채팅 완성 실패: {response.status_code}")
                print(f"  응답: {response.text}")
                return False
        except Exception as e:
            print(f"❌ 채팅 완성 오류: {e}")
            return False
    
    def run_all_tests(self):
        """모든 테스트 실행"""
        print("🧪 vLLM API 테스트를 시작합니다...\n")
        
        tests = [
            ("헬스체크", self.test_health),
            ("모델 목록", self.test_models),
            ("텍스트 완성", self.test_completion),
            ("채팅 완성", self.test_chat_completion)
        ]
        
        results = []
        for test_name, test_func in tests:
            print(f"🔍 {test_name} 테스트 중...")
            result = test_func()
            results.append((test_name, result))
            print()
            time.sleep(1)
        
        print("📊 테스트 결과 요약:")
        for test_name, result in results:
            status = "✅ 성공" if result else "❌ 실패"
            print(f"  {test_name}: {status}")
        
        success_count = sum(1 for _, result in results if result)
        print(f"\n🎯 총 {len(results)}개 테스트 중 {success_count}개 성공")

if __name__ == "__main__":
    tester = VLLMTester()
    tester.run_all_tests()
```

#### 테스트 실행

```bash
# 테스트 스크립트 실행
python test_vllm_api.py
```

## 모니터링 및 로깅

### 1. Prometheus 메트릭 수집

```yaml
# k8s/servicemonitor.yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: vllm-metrics
  namespace: vllm-inference
spec:
  selector:
    matchLabels:
      app: vllm-inference
  endpoints:
  - port: http
    path: /metrics
    interval: 30s
```

### 2. 로그 수집 설정

```yaml
# k8s/fluentd-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluentd-vllm-config
  namespace: vllm-inference
data:
  fluent.conf: |
    <source>
      @type tail
      path /var/log/containers/vllm-inference-*.log
      pos_file /var/log/fluentd-vllm.log.pos
      tag kubernetes.vllm
      format json
    </source>
    
    <match kubernetes.vllm>
      @type elasticsearch
      host elasticsearch.logging.svc.cluster.local
      port 9200
      index_name vllm-logs
    </match>
```

### 3. 대시보드 설정

```yaml
# k8s/grafana-dashboard.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: vllm-dashboard
  namespace: vllm-inference
data:
  dashboard.json: |
    {
      "dashboard": {
        "title": "vLLM Inference Metrics",
        "panels": [
          {
            "title": "Request Rate",
            "type": "graph",
            "targets": [
              {
                "expr": "rate(vllm_requests_total[5m])"
              }
            ]
          },
          {
            "title": "Response Time",
            "type": "graph", 
            "targets": [
              {
                "expr": "histogram_quantile(0.95, rate(vllm_request_duration_seconds_bucket[5m]))"
              }
            ]
          }
        ]
      }
    }
```

## 성능 최적화

### 1. macOS CPU 리소스 튜닝

```yaml
# k8s/deployment-optimized.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vllm-inference-optimized
spec:
  template:
    spec:
      containers:
      - name: vllm
        resources:
          requests:
            memory: "8Gi"
            cpu: "3000m"
          limits:
            memory: "16Gi"
            cpu: "6000m"
        env:
        - name: VLLM_CPU_ONLY
          value: "1"
        - name: OMP_NUM_THREADS
          value: "6"
        - name: MKL_NUM_THREADS
          value: "6"
        - name: NUMEXPR_NUM_THREADS
          value: "6"
        - name: VLLM_WORKER_MULTIPROC_METHOD
          value: "spawn"
        - name: VLLM_ENGINE_ITERATION_TIMEOUT_S
          value: "120"
        # macOS Docker 환경 최적화
        - name: MAX_MODEL_LEN
          value: "4096"
        - name: MAX_NUM_SEQS
          value: "8"
```

### 2. CPU 최적화 캐싱 전략

```python
# cache_manager.py
"""CPU 기반 모델 캐싱 관리자"""

import redis
import json
import hashlib
import threading
from typing import Optional, Dict, Any
from functools import lru_cache

class CPUModelCacheManager:
    def __init__(self, redis_host: str = "redis.vllm-inference.svc.cluster.local"):
        self.redis_client = redis.Redis(host=redis_host, port=6379, db=0)
        self.cache_ttl = 7200  # 2시간 (CPU 처리 시간 고려)
        self.local_cache = {}
        self.lock = threading.RLock()
    
    def _generate_cache_key(self, prompt: str, model: str, params: Dict[str, Any]) -> str:
        """캐시 키 생성"""
        cache_data = {
            "prompt": prompt[:500],  # 긴 프롬프트 제한
            "model": model,
            "params": {k: v for k, v in params.items() if k in ['temperature', 'max_tokens']}
        }
        cache_string = json.dumps(cache_data, sort_keys=True)
        return f"cpu_vllm:{hashlib.md5(cache_string.encode()).hexdigest()}"
    
    @lru_cache(maxsize=100)
    def get_cached_response(self, prompt: str, model: str, params: Dict[str, Any]) -> Optional[str]:
        """캐시된 응답 조회 (로컬 캐시 + Redis)"""
        cache_key = self._generate_cache_key(prompt, model, params)
        
        # 로컬 캐시 먼저 확인
        with self.lock:
            if cache_key in self.local_cache:
                return self.local_cache[cache_key]
        
        # Redis 캐시 확인
        cached_response = self.redis_client.get(cache_key)
        if cached_response:
            response = json.loads(cached_response.decode())
            # 로컬 캐시에도 저장
            with self.lock:
                self.local_cache[cache_key] = response
            return response
        
        return None
    
    def cache_response(self, prompt: str, model: str, params: Dict[str, Any], response: str):
        """응답 캐싱 (로컬 + Redis)"""
        cache_key = self._generate_cache_key(prompt, model, params)
        
        # 로컬 캐시에 저장
        with self.lock:
            self.local_cache[cache_key] = response
            # 로컬 캐시 크기 제한
            if len(self.local_cache) > 50:
                # 가장 오래된 항목 제거
                oldest_key = next(iter(self.local_cache))
                del self.local_cache[oldest_key]
        
        # Redis에 저장
        self.redis_client.setex(
            cache_key,
            self.cache_ttl,
            json.dumps(response)
        )
```

### 3. macOS Docker 환경 최적화

```bash
# Docker Desktop 리소스 설정 스크립트
#!/bin/bash
# optimize_docker.sh

echo "🔧 macOS Docker 환경 최적화 중..."

# Docker Desktop 메모리 할당 확인
docker system info | grep -E "Total Memory|CPUs"

# 컨테이너 리소스 제한 설정
docker update \
  --memory=12g \
  --cpus=4 \
  --memory-swap=16g \
  $(docker ps -q --filter "ancestor=vllm-cpu-custom:latest")

# 불필요한 이미지 정리
docker image prune -f

# 시스템 리소스 정리
docker system prune -f

echo "✅ Docker 환경 최적화 완료"
```

## 문제 해결 가이드

### 자주 발생하는 문제들

#### 1. Pod가 시작되지 않는 경우

```bash
# Pod 상태 확인
kubectl describe pod -l app=vllm-inference -n vllm-inference

# 이벤트 확인
kubectl get events -n vllm-inference --sort-by='.lastTimestamp'

# 리소스 부족 확인
kubectl top nodes
kubectl top pods -n vllm-inference
```

#### 2. CPU 리소스 부족 오류 (macOS 특화)

```bash
# CPU 사용량 확인
kubectl top pods -n vllm-inference

# macOS Docker Desktop CPU 할당 확인
docker system info | grep CPUs

# 리소스 제한 조정
kubectl patch deployment vllm-inference -n vllm-inference -p '
{
  "spec": {
    "template": {
      "spec": {
        "containers": [
          {
            "name": "vllm",
            "resources": {
              "limits": {
                "cpu": "4000m",
                "memory": "10Gi"
              },
              "requests": {
                "cpu": "2000m",
                "memory": "6Gi"
              }
            }
          }
        ]
      }
    }
  }
}'
```

#### 3. DeepSeek 모델 로딩 실패

```bash
# 상세 로그 확인
kubectl logs -f deployment/vllm-inference -n vllm-inference

# 모델 다운로드 진행상황 확인
kubectl exec -it deployment/vllm-inference -n vllm-inference -- \
  ls -la /root/.cache/huggingface/hub/

# 모델 파일 크기 확인 (DeepSeek 모델은 큼)
kubectl exec -it deployment/vllm-inference -n vllm-inference -- \
  du -h /root/.cache/huggingface/

# 네트워크 연결 확인
kubectl exec -it deployment/vllm-inference -n vllm-inference -- \
  curl -I https://huggingface.co/bartowski/deepseek-ai_DeepSeek-R1-0528-Qwen3-8B-GGUF
```

#### 4. macOS Docker 플랫폼 관련 문제

```bash
# 플랫폼 호환성 확인
docker run --rm --platform linux/amd64 vllm-cpu-custom:latest --help

# Apple Silicon에서 AMD64 에뮬레이션 성능 확인
docker run --rm --platform linux/amd64 ubuntu:20.04 uname -a

# Docker Desktop 재시작 (문제 해결의 기본)
osascript -e 'quit app "Docker Desktop"'
sleep 5
open -a "Docker Desktop"
```

#### 5. GGUF 모델 형식 관련 문제

```bash
# GGUF 모델 지원 확인
kubectl exec -it deployment/vllm-inference -n vllm-inference -- \
  python -c "import vllm; print('vLLM version:', vllm.__version__)"

# 지원되는 모델 형식 확인
kubectl exec -it deployment/vllm-inference -n vllm-inference -- \
  python -c "from vllm import LLM; print('GGUF support available')"

# 모델 파일 무결성 검사
kubectl exec -it deployment/vllm-inference -n vllm-inference -- \
  python -c "
from huggingface_hub import hf_hub_download
import os
file_path = hf_hub_download(
    repo_id='bartowski/deepseek-ai_DeepSeek-R1-0528-Qwen3-8B-GGUF',
    filename='deepseek-ai_DeepSeek-R1-0528-Qwen3-8B-Q4_0.gguf'
)
print(f'File size: {os.path.getsize(file_path)} bytes')
"
```

## 프로덕션 배포 고려사항

### 1. 보안 설정

```yaml
# k8s/security.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: vllm-service-account
  namespace: vllm-inference
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: vllm-role
  namespace: vllm-inference
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: vllm-rolebinding
  namespace: vllm-inference
subjects:
- kind: ServiceAccount
  name: vllm-service-account
  namespace: vllm-inference
roleRef:
  kind: Role
  name: vllm-role
  apiGroup: rbac.authorization.k8s.io
---
# macOS 환경을 위한 네트워크 정책
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: vllm-network-policy
  namespace: vllm-inference
spec:
  podSelector:
    matchLabels:
      app: vllm-inference
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector: {}
    ports:
    - protocol: TCP
      port: 8000
  egress:
  - to: []
    ports:
    - protocol: TCP
      port: 443  # HTTPS for model downloads
    - protocol: TCP
      port: 80   # HTTP for health checks
```

### 2. 백업 및 복구

```bash
# 설정 백업
kubectl get all -n vllm-inference -o yaml > vllm-backup.yaml

# DeepSeek 모델 캐시 백업 (큰 파일 주의)
kubectl exec deployment/vllm-inference -n vllm-inference -- \
  tar -czf /tmp/deepseek-model-cache.tar.gz /root/.cache/huggingface/

# 백업 파일 다운로드
kubectl cp vllm-inference/$(kubectl get pods -n vllm-inference -l app=vllm-inference -o jsonpath='{.items[0].metadata.name}'):/tmp/deepseek-model-cache.tar.gz ./deepseek-model-cache.tar.gz
```

### 3. CI/CD 파이프라인 (macOS 대응)

```yaml
# .github/workflows/deploy-macos.yml
name: Deploy vLLM CPU to Kubernetes (macOS)

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: Build macOS compatible Docker image
      run: |
        docker buildx build \
          --platform linux/amd64 \
          -t vllm-cpu-custom:$`github.sha` \
          --load .
        
    - name: Test DeepSeek model compatibility
      run: |
        docker run --rm --platform linux/amd64 \
          vllm-cpu-custom:$`github.sha` \
          --model bartowski/deepseek-ai_DeepSeek-R1-0528-Qwen3-8B-GGUF \
          --dry-run
        
    - name: Deploy to Kubernetes
      run: |
        kubectl set image deployment/vllm-inference \
          vllm=vllm-cpu-custom:$`github.sha` \
          -n vllm-inference
```

## 결론

이 가이드를 통해 macOS 환경에서 CPU 기반 Kubernetes 위에 vLLM DeepSeek 추론 서비스를 성공적으로 구축할 수 있습니다.

### 핵심 포인트 요약

1. **macOS CPU 최적화**: GPU 대신 CPU 전용 vLLM 사용
2. **DeepSeek GGUF 모델**: 고성능 양자화 모델 활용
3. **Docker 플랫폼 호환성**: linux/amd64 플랫폼으로 안정성 확보
4. **리소스 최적화**: macOS Docker Desktop 환경에 맞는 메모리/CPU 설정
5. **모니터링**: CPU 사용률과 메모리 효율성 중심 모니터링

### macOS 특화 장점

- **개발 환경 일관성**: 맥북에서 개발부터 배포까지 통합 환경
- **리소스 효율성**: GPU 없이도 충분한 추론 성능
- **Docker 최적화**: Apple Silicon과 Intel Mac 모두 지원
- **모델 호환성**: GGUF 형식으로 빠른 로딩과 적은 메모리 사용

### 다음 단계

- **모델 업그레이드**: 더 큰 DeepSeek 모델 (16B, 32B) 활용
- **멀티 모델 서빙**: 여러 GGUF 모델 동시 운영
- **성능 튜닝**: CPU 코어 수에 따른 동적 스케일링
- **클라우드 배포**: AWS/GCP의 CPU 인스턴스로 확장

macOS의 뛰어난 개발 환경과 CPU 기반 vLLM의 효율성을 결합하여 실용적이고 비용 효율적인 AI 추론 서비스를 구축해보세요!

---

*이 가이드는 vLLM 0.4.x (CPU 지원) 및 Kubernetes 1.28+ 버전, macOS 14+ 환경을 기준으로 작성되었습니다.*

### 디버깅 도구 활용

```bash
# k9s로 클러스터 모니터링
k9s -n vllm-inference

# 실시간 로그 스트리밍
stern vllm-inference -n vllm-inference

# 네트워크 연결 테스트
kubectl run debug-pod --image=nicolaka/netshoot -it --rm -n vllm-inference

# macOS 특화 디버깅
# Docker Desktop 상태 확인
docker system df
docker system events

# CPU 사용률 실시간 모니터링
kubectl exec -it deployment/vllm-inference -n vllm-inference -- \
  top -n 1 -b | head -20
```

## 프로덕션 배포 고려사항

### 1. macOS 환경 보안 설정

```yaml
# k8s/security.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: vllm-service-account
  namespace: vllm-inference
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: vllm-role
  namespace: vllm-inference
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: vllm-rolebinding
  namespace: vllm-inference
subjects:
- kind: ServiceAccount
  name: vllm-service-account
  namespace: vllm-inference
roleRef:
  kind: Role
  name: vllm-role
  apiGroup: rbac.authorization.k8s.io
---
# macOS 환경을 위한 네트워크 정책
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: vllm-network-policy
  namespace: vllm-inference
spec:
  podSelector:
    matchLabels:
      app: vllm-inference
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector: {}
    ports:
    - protocol: TCP
      port: 8000
  egress:
  - to: []
    ports:
    - protocol: TCP
      port: 443  # HTTPS for model downloads
    - protocol: TCP
      port: 80   # HTTP for health checks
```

### 2. 백업 및 복구

```bash
# 설정 백업
kubectl get all -n vllm-inference -o yaml > vllm-backup.yaml

# DeepSeek 모델 캐시 백업 (큰 파일 주의)
kubectl exec deployment/vllm-inference -n vllm-inference -- \
  tar -czf /tmp/deepseek-model-cache.tar.gz /root/.cache/huggingface/

# 백업 파일 다운로드
kubectl cp vllm-inference/$(kubectl get pods -n vllm-inference -l app=vllm-inference -o jsonpath='{.items[0].metadata.name}'):/tmp/deepseek-model-cache.tar.gz ./deepseek-model-cache.tar.gz
```

### 3. CI/CD 파이프라인 (macOS 대응)

```yaml
# .github/workflows/deploy-macos.yml
name: Deploy vLLM CPU to Kubernetes (macOS)

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: Build macOS compatible Docker image
      run: |
        docker buildx build \
          --platform linux/amd64 \
          -t vllm-cpu-custom:$`github.sha` \
          --load .
        
    - name: Test DeepSeek model compatibility
      run: |
        docker run --rm --platform linux/amd64 \
          vllm-cpu-custom:$`github.sha` \
          --model bartowski/deepseek-ai_DeepSeek-R1-0528-Qwen3-8B-GGUF \
          --dry-run
        
    - name: Deploy to Kubernetes
      run: |
        kubectl set image deployment/vllm-inference \
          vllm=vllm-cpu-custom:$`github.sha` \
          -n vllm-inference
```

## 결론

이 가이드를 통해 macOS 환경에서 CPU 기반 Kubernetes 위에 vLLM DeepSeek 추론 서비스를 성공적으로 구축할 수 있습니다.

### 핵심 포인트 요약

1. **macOS CPU 최적화**: GPU 대신 CPU 전용 vLLM 사용
2. **DeepSeek GGUF 모델**: 고성능 양자화 모델 활용
3. **Docker 플랫폼 호환성**: linux/amd64 플랫폼으로 안정성 확보
4. **리소스 최적화**: macOS Docker Desktop 환경에 맞는 메모리/CPU 설정
5. **모니터링**: CPU 사용률과 메모리 효율성 중심 모니터링

### macOS 특화 장점

- **개발 환경 일관성**: 맥북에서 개발부터 배포까지 통합 환경
- **리소스 효율성**: GPU 없이도 충분한 추론 성능
- **Docker 최적화**: Apple Silicon과 Intel Mac 모두 지원
- **모델 호환성**: GGUF 형식으로 빠른 로딩과 적은 메모리 사용

### 다음 단계

- **모델 업그레이드**: 더 큰 DeepSeek 모델 (16B, 32B) 활용
- **멀티 모델 서빙**: 여러 GGUF 모델 동시 운영
- **성능 튜닝**: CPU 코어 수에 따른 동적 스케일링
- **클라우드 배포**: AWS/GCP의 CPU 인스턴스로 확장

macOS의 뛰어난 개발 환경과 CPU 기반 vLLM의 효율성을 결합하여 실용적이고 비용 효율적인 AI 추론 서비스를 구축해보세요!

---

*이 가이드는 vLLM 0.4.x (CPU 지원) 및 Kubernetes 1.28+ 버전, macOS 14+ 환경을 기준으로 작성되었습니다.*
