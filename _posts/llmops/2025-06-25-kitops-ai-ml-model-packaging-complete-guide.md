---
title: "KitOps 완전 가이드: AI/ML 모델 패키징과 버전 관리의 새로운 표준"
excerpt: "OCI 표준 기반 KitOps로 AI/ML 모델, 데이터셋, 코드를 통합 패키징하고 버전 관리하는 실전 가이드"
date: 2025-06-25
categories: 
  - llmops
  - tutorials
tags: 
  - kitops
  - modelkit
  - ai-ml-packaging
  - oci-artifacts
  - model-versioning
  - mlops-tools
  - kubernetes-deployment
author_profile: true
toc: true
toc_label: "KitOps 완전 가이드"
---

## 개요

[KitOps](https://github.com/kitops-ml/kitops)는 AI/ML 프로젝트를 위한 혁신적인 패키징, 버전 관리, 공유 시스템입니다. OCI(Open Container Initiative) 표준을 기반으로 하여 기존의 AI/ML, 개발, DevOps 도구들과 완벽하게 호환되며, 엔터프라이즈 컨테이너 레지스트리에 저장할 수 있습니다. 이 가이드에서는 KitOps의 핵심 개념부터 실제 프로덕션 배포까지 완전한 워크플로를 다룹니다.

## KitOps의 핵심 가치

### 🎁 **통합 패키징 (Unified Packaging)**
ModelKit 패키지는 모델, 데이터셋, 설정, 코드를 모두 포함합니다. 프로젝트에 필요한 만큼 추가하거나 제외할 수 있습니다.

### 🏭 **버전 관리 (Versioning)**
각 ModelKit은 태그가 지정되어 어떤 데이터셋과 모델이 함께 작동하는지 모든 팀원이 알 수 있습니다.

### 🔒 **변조 방지 (Tamper-proofing)**
각 ModelKit 패키지는 자체와 포함된 모든 아티팩트에 대한 SHA 다이제스트를 포함합니다.

### 🤩 **선택적 언패킹 (Selective Unpacking)**
`kit unpack --filter` 명령으로 ModelKit에서 필요한 부분만 언패킹할 수 있습니다.

## 설치 및 환경 설정

### macOS 설치

```bash
# Homebrew를 통한 설치
brew tap kitops-ml/kitops
brew install kitops

# 또는 직접 다운로드
curl -L https://github.com/kitops-ml/kitops/releases/latest/download/kitops-darwin-amd64.tar.gz | tar -xz
sudo mv kit /usr/local/bin/
```

### Linux 설치

```bash
# 최신 릴리스 다운로드
curl -L https://github.com/kitops-ml/kitops/releases/latest/download/kitops-linux-amd64.tar.gz | tar -xz
sudo mv kit /usr/local/bin/

# 설치 확인
kit version
```

### Docker 환경에서 사용

```dockerfile
FROM alpine:latest
RUN apk add --no-cache curl tar
RUN curl -L https://github.com/kitops-ml/kitops/releases/latest/download/kitops-linux-amd64.tar.gz | tar -xz
RUN mv kit /usr/local/bin/
```

## Kitfile 작성법

### 기본 Kitfile 구조

```yaml
# Kitfile
manifestVersion: v1alpha1
package:
  name: my-llm-model
  version: 1.0.0
  description: "Fine-tuned LLM for customer service"
  authors: ["Data Science Team"]

model:
  - name: customer-service-llm
    path: ./models/pytorch_model.bin
    description: "PyTorch fine-tuned model"
    framework: pytorch
    version: "2.1.0"

datasets:
  - name: training-data
    path: ./data/train.jsonl
    description: "Customer service training dataset"
  - name: validation-data
    path: ./data/val.jsonl
    description: "Validation dataset"

code:
  - name: inference-script
    path: ./src/inference.py
    description: "Model inference script"
  - name: preprocessing
    path: ./src/preprocess.py
    description: "Data preprocessing utilities"

docs:
  - name: model-card
    path: ./docs/model_card.md
    description: "Model documentation and metrics"
  - name: api-docs
    path: ./docs/api.md
    description: "API usage documentation"

configs:
  - name: training-config
    path: ./config/training.yaml
    description: "Training hyperparameters"
  - name: inference-config
    path: ./config/inference.json
    description: "Inference configuration"
```

### 고급 Kitfile 예시

```yaml
# Advanced Kitfile with model parts and metadata
manifestVersion: v1alpha1
package:
  name: multimodal-assistant
  version: 2.1.0
  description: "Multi-modal AI assistant with vision and text capabilities"
  authors: ["AI Research Team"]
  license: "MIT"
  repository: "https://github.com/company/multimodal-assistant"

# Base model reference
modelParts:
  - name: base-llm
    path: registry.company.com/models/llama-2-7b:latest
    description: "Base LLaMA 2 7B model"

model:
  - name: fine-tuned-multimodal
    path: ./models/adapter_model.safetensors
    description: "LoRA adapter for multimodal tasks"
    framework: transformers
    version: "4.35.0"
    size: "2.1GB"
    format: "safetensors"

datasets:
  - name: multimodal-training
    path: ./data/multimodal_train.parquet
    description: "Image-text paired training data"
    size: "15GB"
    samples: 500000
  - name: evaluation-suite
    path: ./data/eval/
    description: "Comprehensive evaluation datasets"

code:
  - name: training-pipeline
    path: ./src/train.py
    description: "Multi-modal training pipeline"
  - name: inference-api
    path: ./src/api/
    description: "FastAPI inference server"
  - name: evaluation-scripts
    path: ./src/eval/
    description: "Model evaluation utilities"

# Custom metadata
metadata:
  performance:
    bleu_score: 0.85
    rouge_l: 0.78
    accuracy: 0.92
  training:
    epochs: 10
    learning_rate: 2e-5
    batch_size: 16
    gpu_hours: 240
  deployment:
    min_memory: "8GB"
    recommended_gpu: "RTX 4090"
    inference_time: "150ms"
```

## ModelKit 생성 및 관리

### 1. ModelKit 패킹

```bash
# 기본 패킹
kit pack . -t my-registry.com/my-model:1.0.0

# 특정 레지스트리에 직접 푸시
kit pack . -t my-registry.com/my-model:1.0.0 --push

# 압축 옵션 지정
kit pack . -t my-model:1.0.0 --compression gzip

# 서명과 함께 패킹
kit pack . -t my-model:1.0.0 --sign --key ./private.key
```

### 2. ModelKit 언패킹

```bash
# 전체 ModelKit 언패킹
kit unpack my-registry.com/my-model:1.0.0 -d ./unpacked

# 모델만 언패킹
kit unpack my-registry.com/my-model:1.0.0 --model -d ./model-only

# 데이터셋과 코드만 언패킹
kit unpack my-registry.com/my-model:1.0.0 --datasets --code -d ./data-code

# 특정 아티팩트만 언패킹
kit unpack my-registry.com/my-model:1.0.0 --filter "*.py,*.yaml" -d ./filtered
```

### 3. ModelKit 정보 조회

```bash
# ModelKit 상세 정보
kit info my-registry.com/my-model:1.0.0

# 로컬 ModelKit 목록
kit list

# 원격 레지스트리의 ModelKit 목록
kit list my-registry.com/my-models

# ModelKit 히스토리
kit history my-registry.com/my-model
```

## 실전 워크플로 예시

### 시나리오 1: LLM Fine-tuning 프로젝트

#### 1단계: 프로젝트 구조 설정

```bash
# 프로젝트 디렉토리 생성
mkdir llm-finetuning-project
cd llm-finetuning-project

# 디렉토리 구조
mkdir -p {models,data,src,config,docs}

# 기본 파일 구조
tree .
```

```
llm-finetuning-project/
├── Kitfile
├── models/
│   ├── pytorch_model.bin
│   ├── config.json
│   └── tokenizer.json
├── data/
│   ├── train.jsonl
│   ├── val.jsonl
│   └── test.jsonl
├── src/
│   ├── train.py
│   ├── inference.py
│   └── utils.py
├── config/
│   ├── training.yaml
│   └── inference.json
└── docs/
    ├── model_card.md
    └── README.md
```

#### 2단계: Kitfile 작성

```yaml
manifestVersion: v1alpha1
package:
  name: customer-support-llm
  version: 1.0.0
  description: "Fine-tuned LLM for customer support automation"
  authors: ["AI Team <ai@company.com>"]

model:
  - name: finetuned-model
    path: ./models/
    description: "Fine-tuned customer support model"
    framework: "transformers"
    baseModel: "microsoft/DialoGPT-medium"

datasets:
  - name: support-conversations
    path: ./data/train.jsonl
    description: "Customer support conversation dataset"
    samples: 50000
  - name: validation-set
    path: ./data/val.jsonl
    description: "Validation dataset"

code:
  - name: training-script
    path: ./src/train.py
    description: "Model fine-tuning script"
  - name: inference-engine
    path: ./src/inference.py
    description: "Inference API server"

configs:
  - name: training-params
    path: ./config/training.yaml
    description: "Training hyperparameters"

docs:
  - name: documentation
    path: ./docs/
    description: "Model documentation and usage guide"

metadata:
  training:
    epochs: 5
    learning_rate: 5e-5
    batch_size: 8
    validation_loss: 0.45
  performance:
    perplexity: 12.3
    bleu_score: 0.72
  hardware:
    gpu_type: "RTX 4090"
    training_time: "6 hours"
```

#### 3단계: ModelKit 생성 및 버전 관리

```bash
# 개발 버전 생성
kit pack . -t company-registry.com/ai/customer-support-llm:dev

# 테스트 후 스테이징 버전
kit pack . -t company-registry.com/ai/customer-support-llm:1.0.0-staging

# 프로덕션 릴리스
kit pack . -t company-registry.com/ai/customer-support-llm:1.0.0 --push

# 태그 추가
kit tag company-registry.com/ai/customer-support-llm:1.0.0 latest
```

### 시나리오 2: RAG 파이프라인 구축

#### RAG 시스템 Kitfile

```yaml
manifestVersion: v1alpha1
package:
  name: rag-knowledge-assistant
  version: 2.0.0
  description: "RAG-based knowledge assistant with vector search"
  authors: ["Knowledge Team"]

modelParts:
  - name: embedding-model
    path: registry.com/models/sentence-transformers:latest
    description: "Sentence transformer for embeddings"
  - name: llm-base
    path: registry.com/models/llama-2-13b-chat:latest
    description: "Base LLM for generation"

model:
  - name: fine-tuned-retriever
    path: ./models/retriever/
    description: "Fine-tuned retrieval model"
  - name: generation-adapter
    path: ./models/generation/adapter_model.safetensors
    description: "LoRA adapter for domain-specific generation"

datasets:
  - name: knowledge-base
    path: ./data/knowledge_corpus.jsonl
    description: "Domain knowledge corpus"
    documents: 100000
  - name: qa-pairs
    path: ./data/qa_training.jsonl
    description: "Question-answer training pairs"
  - name: vector-index
    path: ./data/embeddings/
    description: "Pre-computed vector embeddings"

code:
  - name: rag-pipeline
    path: ./src/rag/
    description: "Complete RAG pipeline implementation"
  - name: vector-search
    path: ./src/search/
    description: "Vector similarity search engine"
  - name: api-server
    path: ./src/api/
    description: "FastAPI server with RAG endpoints"

configs:
  - name: rag-config
    path: ./config/rag_config.yaml
    description: "RAG pipeline configuration"
  - name: search-config
    path: ./config/search_params.json
    description: "Vector search parameters"

metadata:
  performance:
    retrieval_recall_at_5: 0.89
    generation_bleu: 0.81
    end_to_end_latency: "250ms"
  infrastructure:
    vector_db: "Pinecone"
    embedding_dim: 768
    index_size: "2GB"
```

## Kubernetes 배포

### 1. ModelKit에서 Kubernetes 매니페스트 생성

```bash
# Kubernetes 배포 설정 생성
kit deploy create kubernetes \
  --modelkit company-registry.com/ai/customer-support-llm:1.0.0 \
  --output ./k8s-deployment.yaml

# KServe 배포 설정 생성
kit deploy create kserve \
  --modelkit company-registry.com/ai/customer-support-llm:1.0.0 \
  --output ./kserve-deployment.yaml
```

### 2. 생성된 Kubernetes 매니페스트

```yaml
# k8s-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: customer-support-llm
  labels:
    app: customer-support-llm
    version: "1.0.0"
spec:
  replicas: 3
  selector:
    matchLabels:
      app: customer-support-llm
  template:
    metadata:
      labels:
        app: customer-support-llm
    spec:
      initContainers:
      - name: model-loader
        image: kitops/kit:latest
        command: ["kit", "unpack", "--model", "--code"]
        args: ["company-registry.com/ai/customer-support-llm:1.0.0"]
        volumeMounts:
        - name: model-storage
          mountPath: /models
      containers:
      - name: inference-server
        image: python:3.9-slim
        command: ["python", "/app/inference.py"]
        ports:
        - containerPort: 8000
        volumeMounts:
        - name: model-storage
          mountPath: /models
        env:
        - name: MODEL_PATH
          value: "/models"
        resources:
          requests:
            memory: "4Gi"
            cpu: "1000m"
          limits:
            memory: "8Gi"
            cpu: "2000m"
      volumes:
      - name: model-storage
        emptyDir: {}

---
apiVersion: v1
kind: Service
metadata:
  name: customer-support-llm-service
spec:
  selector:
    app: customer-support-llm
  ports:
  - port: 80
    targetPort: 8000
  type: LoadBalancer
```

### 3. KServe 배포

```yaml
# kserve-deployment.yaml
apiVersion: serving.kserve.io/v1beta1
kind: InferenceService
metadata:
  name: customer-support-llm
spec:
  predictor:
    model:
      modelFormat:
        name: pytorch
      storageUri: "kit://company-registry.com/ai/customer-support-llm:1.0.0"
      resources:
        requests:
          memory: 4Gi
          cpu: "2"
        limits:
          memory: 8Gi
          cpu: "4"
      env:
      - name: STORAGE_URI
        value: "kit://company-registry.com/ai/customer-support-llm:1.0.0"
```

### 4. 배포 실행

```bash
# Kubernetes 클러스터에 배포
kubectl apply -f k8s-deployment.yaml

# KServe 배포 (KServe가 설치된 클러스터)
kubectl apply -f kserve-deployment.yaml

# 배포 상태 확인
kubectl get pods -l app=customer-support-llm
kubectl get svc customer-support-llm-service

# 로그 확인
kubectl logs -l app=customer-support-llm -f
```

## 컨테이너 배포

### 1. ModelKit에서 컨테이너 생성

```bash
# 기본 컨테이너 생성
kit deploy create docker \
  --modelkit company-registry.com/ai/customer-support-llm:1.0.0 \
  --output ./Dockerfile

# 커스텀 베이스 이미지 사용
kit deploy create docker \
  --modelkit company-registry.com/ai/customer-support-llm:1.0.0 \
  --base-image python:3.9-slim \
  --output ./Dockerfile.custom
```

### 2. 생성된 Dockerfile

```dockerfile
# Dockerfile
FROM python:3.9-slim

# KitOps CLI 설치
RUN apt-get update && apt-get install -y curl && \
    curl -L https://github.com/kitops-ml/kitops/releases/latest/download/kitops-linux-amd64.tar.gz | tar -xz && \
    mv kit /usr/local/bin/ && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 작업 디렉토리 설정
WORKDIR /app

# ModelKit 언패킹
RUN kit unpack company-registry.com/ai/customer-support-llm:1.0.0 --code --model --configs -d /app

# 의존성 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 추가 Python 패키지 설치
RUN pip install torch transformers flask gunicorn

# 포트 노출
EXPOSE 8000

# 헬스체크
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

# 애플리케이션 실행
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "4", "inference:app"]
```

### 3. 컨테이너 빌드 및 실행

```bash
# 컨테이너 이미지 빌드
docker build -t customer-support-llm:1.0.0 .

# 컨테이너 실행
docker run -d \
  --name customer-support-api \
  -p 8000:8000 \
  --memory=8g \
  --cpus=2 \
  customer-support-llm:1.0.0

# 로그 확인
docker logs -f customer-support-api

# 헬스체크
curl http://localhost:8000/health
```

## 고급 기능 활용

### 1. 모델 서명 및 검증

```bash
# GPG 키 생성
gpg --full-generate-key

# 모델 서명하여 패킹
kit pack . -t signed-model:1.0.0 --sign --key ~/.gnupg/secring.gpg

# 서명 검증
kit verify signed-model:1.0.0 --key ~/.gnupg/pubring.gpg
```

### 2. 멀티 아키텍처 지원

```bash
# ARM64 아키텍처용 ModelKit
kit pack . -t my-model:1.0.0-arm64 --platform linux/arm64

# AMD64 아키텍처용 ModelKit
kit pack . -t my-model:1.0.0-amd64 --platform linux/amd64

# 매니페스트 리스트 생성
kit manifest create my-model:1.0.0 \
  my-model:1.0.0-arm64 \
  my-model:1.0.0-amd64
```

### 3. 개발 모드 활용

```bash
# 로컬 개발 서버 시작
kit dev start --modelkit my-model:latest --port 8080

# 모델과 상호작용
curl -X POST http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [{"role": "user", "content": "Hello, how can you help me?"}],
    "max_tokens": 100
  }'

# 개발 서버 중지
kit dev stop
```

## CI/CD 통합

### GitHub Actions 워크플로

```yaml
# .github/workflows/model-deployment.yml
name: Model Deployment Pipeline

on:
  push:
    branches: [main]
    paths: ['models/**', 'Kitfile']

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
    
    - name: Install KitOps
      run: |
        curl -L https://github.com/kitops-ml/kitops/releases/latest/download/kitops-linux-amd64.tar.gz | tar -xz
        sudo mv kit /usr/local/bin/
    
    - name: Login to registry
      run: |
        echo ${{ secrets.REGISTRY_PASSWORD }} | kit auth login ${{ secrets.REGISTRY_URL }} -u ${{ secrets.REGISTRY_USERNAME }} --password-stdin
    
    - name: Build ModelKit
      run: |
        VERSION=$(git rev-parse --short HEAD)
        kit pack . -t ${{ secrets.REGISTRY_URL }}/models/customer-support-llm:$VERSION
        kit pack . -t ${{ secrets.REGISTRY_URL }}/models/customer-support-llm:latest
    
    - name: Run tests
      run: |
        # ModelKit 테스트
        kit unpack ${{ secrets.REGISTRY_URL }}/models/customer-support-llm:latest --code -d ./test-env
        cd test-env && python -m pytest tests/
    
    - name: Push ModelKit
      run: |
        VERSION=$(git rev-parse --short HEAD)
        kit push ${{ secrets.REGISTRY_URL }}/models/customer-support-llm:$VERSION
        kit push ${{ secrets.REGISTRY_URL }}/models/customer-support-llm:latest
    
    - name: Deploy to staging
      if: github.ref == 'refs/heads/main'
      run: |
        kit deploy create kubernetes \
          --modelkit ${{ secrets.REGISTRY_URL }}/models/customer-support-llm:latest \
          --output k8s-staging.yaml
        kubectl apply -f k8s-staging.yaml --namespace=staging
    
    - name: Run integration tests
      run: |
        # 스테이징 환경 테스트
        sleep 60  # 배포 대기
        curl -f http://staging-api.company.com/health
    
    - name: Deploy to production
      if: github.ref == 'refs/heads/main'
      run: |
        kubectl apply -f k8s-staging.yaml --namespace=production
```

### Jenkins Pipeline

```groovy
// Jenkinsfile
pipeline {
    agent any
    
    environment {
        REGISTRY_URL = credentials('registry-url')
        REGISTRY_CREDS = credentials('registry-credentials')
        KUBECONFIG = credentials('kubeconfig')
    }
    
    stages {
        stage('Setup') {
            steps {
                script {
                    // KitOps 설치
                    sh '''
                        curl -L https://github.com/kitops-ml/kitops/releases/latest/download/kitops-linux-amd64.tar.gz | tar -xz
                        sudo mv kit /usr/local/bin/
                    '''
                }
            }
        }
        
        stage('Build ModelKit') {
            steps {
                script {
                    def version = env.BUILD_NUMBER
                    sh """
                        kit auth login ${REGISTRY_URL} -u ${REGISTRY_CREDS_USR} -p ${REGISTRY_CREDS_PSW}
                        kit pack . -t ${REGISTRY_URL}/models/customer-support-llm:${version}
                        kit pack . -t ${REGISTRY_URL}/models/customer-support-llm:latest
                    """
                }
            }
        }
        
        stage('Test') {
            steps {
                sh '''
                    kit unpack ${REGISTRY_URL}/models/customer-support-llm:latest --code -d ./test-env
                    cd test-env && python -m pytest tests/ --junitxml=test-results.xml
                '''
                junit 'test-env/test-results.xml'
            }
        }
        
        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                sh '''
                    kit push ${REGISTRY_URL}/models/customer-support-llm:${BUILD_NUMBER}
                    kit push ${REGISTRY_URL}/models/customer-support-llm:latest
                    
                    kit deploy create kubernetes \\
                        --modelkit ${REGISTRY_URL}/models/customer-support-llm:latest \\
                        --output k8s-deployment.yaml
                    
                    kubectl apply -f k8s-deployment.yaml
                '''
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            slackSend channel: '#ai-deployments', 
                     color: 'good', 
                     message: "✅ Model deployment successful: ${env.JOB_NAME} - ${env.BUILD_NUMBER}"
        }
        failure {
            slackSend channel: '#ai-deployments', 
                     color: 'danger', 
                     message: "❌ Model deployment failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}"
        }
    }
}
```

## 모니터링 및 관찰성

### 1. ModelKit 메트릭 수집

```python
# monitoring/metrics_collector.py
import time
import psutil
import GPUtil
from prometheus_client import Counter, Histogram, Gauge, start_http_server

# 메트릭 정의
MODEL_REQUESTS = Counter('model_requests_total', 'Total model requests', ['model_name', 'version'])
MODEL_LATENCY = Histogram('model_inference_duration_seconds', 'Model inference latency')
MODEL_MEMORY = Gauge('model_memory_usage_bytes', 'Model memory usage')
GPU_UTILIZATION = Gauge('gpu_utilization_percent', 'GPU utilization')

class ModelMonitor:
    def __init__(self, model_name, model_version):
        self.model_name = model_name
        self.model_version = model_version
        
    def record_request(self):
        MODEL_REQUESTS.labels(
            model_name=self.model_name, 
            version=self.model_version
        ).inc()
    
    def record_latency(self, duration):
        MODEL_LATENCY.observe(duration)
    
    def update_system_metrics(self):
        # 메모리 사용량
        memory = psutil.virtual_memory()
        MODEL_MEMORY.set(memory.used)
        
        # GPU 사용률
        try:
            gpus = GPUtil.getGPUs()
            if gpus:
                GPU_UTILIZATION.set(gpus[0].load * 100)
        except:
            pass

# 사용 예시
monitor = ModelMonitor("customer-support-llm", "1.0.0")

def inference_with_monitoring(input_text):
    start_time = time.time()
    monitor.record_request()
    
    try:
        # 실제 추론 로직
        result = model.generate(input_text)
        
        # 메트릭 기록
        duration = time.time() - start_time
        monitor.record_latency(duration)
        monitor.update_system_metrics()
        
        return result
    except Exception as e:
        # 에러 메트릭 기록
        ERROR_COUNTER.labels(error_type=type(e).__name__).inc()
        raise

# Prometheus 메트릭 서버 시작
start_http_server(8001)
```

### 2. Grafana 대시보드 설정

```json
{
  "dashboard": {
    "title": "KitOps Model Performance",
    "panels": [
      {
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(model_requests_total[5m])",
            "legendFormat": "{{model_name}} v{{version}}"
          }
        ]
      },
      {
        "title": "Inference Latency",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, model_inference_duration_seconds_bucket)",
            "legendFormat": "95th percentile"
          },
          {
            "expr": "histogram_quantile(0.50, model_inference_duration_seconds_bucket)",
            "legendFormat": "50th percentile"
          }
        ]
      },
      {
        "title": "Memory Usage",
        "type": "singlestat",
        "targets": [
          {
            "expr": "model_memory_usage_bytes / 1024 / 1024 / 1024",
            "legendFormat": "Memory (GB)"
          }
        ]
      },
      {
        "title": "GPU Utilization",
        "type": "singlestat",
        "targets": [
          {
            "expr": "gpu_utilization_percent",
            "legendFormat": "GPU %"
          }
        ]
      }
    ]
  }
}
```

## 보안 및 거버넌스

### 1. 모델 보안 정책

```yaml
# security-policy.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: kitops-security-policy
data:
  policy.yaml: |
    security:
      signing:
        required: true
        trusted_keys:
          - "ai-team@company.com"
          - "mlops-team@company.com"
      
      scanning:
        enabled: true
        vulnerability_threshold: "HIGH"
        scan_on_push: true
      
      access_control:
        registry_auth: true
        rbac_enabled: true
        allowed_registries:
          - "company-registry.com"
          - "staging-registry.com"
      
      audit:
        log_all_operations: true
        retention_days: 90
        compliance_mode: "SOC2"
```

### 2. 모델 거버넌스 워크플로

```python
# governance/model_approval.py
import yaml
from dataclasses import dataclass
from typing import List, Dict, Any
from enum import Enum

class ApprovalStatus(Enum):
    PENDING = "pending"
    APPROVED = "approved"
    REJECTED = "rejected"

@dataclass
class ModelApproval:
    model_name: str
    version: str
    requester: str
    approvers: List[str]
    status: ApprovalStatus
    performance_metrics: Dict[str, float]
    security_scan_results: Dict[str, Any]
    bias_evaluation: Dict[str, Any]

class ModelGovernance:
    def __init__(self, config_path: str):
        with open(config_path, 'r') as f:
            self.config = yaml.safe_load(f)
    
    def submit_for_approval(self, modelkit_ref: str) -> str:
        """모델 승인 요청 제출"""
        # ModelKit 정보 추출
        info = self.extract_modelkit_info(modelkit_ref)
        
        # 자동 검증 실행
        validation_results = self.run_automated_validation(modelkit_ref)
        
        # 승인 요청 생성
        approval = ModelApproval(
            model_name=info['name'],
            version=info['version'],
            requester=info['author'],
            approvers=self.get_required_approvers(info),
            status=ApprovalStatus.PENDING,
            performance_metrics=validation_results['performance'],
            security_scan_results=validation_results['security'],
            bias_evaluation=validation_results['bias']
        )
        
        # 승인 워크플로 시작
        return self.initiate_approval_workflow(approval)
    
    def run_automated_validation(self, modelkit_ref: str) -> Dict[str, Any]:
        """자동화된 모델 검증"""
        results = {}
        
        # 성능 검증
        results['performance'] = self.validate_performance(modelkit_ref)
        
        # 보안 스캔
        results['security'] = self.security_scan(modelkit_ref)
        
        # 편향성 평가
        results['bias'] = self.bias_evaluation(modelkit_ref)
        
        # 규정 준수 확인
        results['compliance'] = self.compliance_check(modelkit_ref)
        
        return results
    
    def validate_performance(self, modelkit_ref: str) -> Dict[str, float]:
        """성능 기준 검증"""
        # ModelKit 언패킹 및 모델 로드
        # 벤치마크 데이터셋으로 평가
        # 성능 임계값 확인
        return {
            "accuracy": 0.95,
            "latency_p95": 150.0,
            "memory_usage": 4.2
        }
    
    def security_scan(self, modelkit_ref: str) -> Dict[str, Any]:
        """보안 취약점 스캔"""
        return {
            "vulnerabilities": [],
            "signature_valid": True,
            "dependencies_secure": True
        }
    
    def bias_evaluation(self, modelkit_ref: str) -> Dict[str, Any]:
        """편향성 평가"""
        return {
            "demographic_parity": 0.85,
            "equalized_odds": 0.88,
            "fairness_score": 0.92
        }
```

## 트러블슈팅 가이드

### 1. 일반적인 문제와 해결책

**문제: ModelKit 패킹 실패**
```bash
# 해결책 1: 권한 확인
ls -la Kitfile
chmod 644 Kitfile

# 해결책 2: 디스크 공간 확인
df -h

# 해결책 3: 상세 로그 확인
kit pack . -t my-model:1.0.0 --verbose
```

**문제: 레지스트리 인증 실패**
```bash
# 해결책: 인증 정보 재설정
kit auth logout registry.company.com
kit auth login registry.company.com -u username

# 토큰 기반 인증
echo $REGISTRY_TOKEN | kit auth login registry.company.com -u username --password-stdin
```

**문제: Kubernetes 배포 실패**
```bash
# 해결책 1: 리소스 확인
kubectl describe pod -l app=customer-support-llm

# 해결책 2: 이미지 풀 시크릿 설정
kubectl create secret docker-registry regcred \
  --docker-server=registry.company.com \
  --docker-username=username \
  --docker-password=password

# 해결책 3: 노드 리소스 확인
kubectl top nodes
kubectl describe node
```

### 2. 디버깅 도구

```bash
# ModelKit 내용 검사
kit inspect my-model:1.0.0

# 레이어 분석
kit layers my-model:1.0.0

# 의존성 트리
kit deps my-model:1.0.0 --tree

# 무결성 검증
kit verify my-model:1.0.0 --checksum
```

## 결론

KitOps는 AI/ML 프로젝트의 복잡한 아티팩트 관리 문제를 OCI 표준 기반의 통합 솔루션으로 해결합니다. ModelKit을 통해 모델, 데이터, 코드, 설정을 하나의 불변 패키지로 관리할 수 있으며, 선택적 언패킹으로 필요한 부분만 효율적으로 사용할 수 있습니다.

### 🎯 **핵심 장점**

1. **표준화**: OCI 호환으로 기존 인프라와 완벽 통합
2. **보안**: 서명, 검증, 변조 방지 기능 제공
3. **효율성**: 선택적 언패킹으로 리소스 절약
4. **확장성**: Kubernetes, Docker 등 다양한 배포 환경 지원
5. **거버넌스**: 엔터프라이즈급 모델 관리 및 감사 기능

### 🚀 **다음 단계**

- [KitOps 공식 문서](https://kitops.ml) 참조
- [GitHub 리포지토리](https://github.com/kitops-ml/kitops)에서 최신 업데이트 확인
- [Discord 커뮤니티](https://discord.gg/kitops) 참여
- 실제 프로젝트에 KitOps 도입 검토

KitOps를 통해 AI/ML 프로젝트의 아티팩트 관리를 혁신하고, 팀 간 협업을 개선하며, 프로덕션 배포를 안전하고 효율적으로 수행하시기 바랍니다. 