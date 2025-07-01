---
title: "KitOps - AI/ML 프로젝트 패키징의 새로운 표준"
date: 2025-06-11
categories: 
  - dev
tags: 
  - kitops
  - ai-ml-devops
  - container-registry
  - model-versioning
  - kubernetes
  - devops-tools
  - oci-artifacts
  - mlops-platform
author_profile: true
toc: true
toc_label: "KitOps 가이드"
---

AI/ML 프로젝트에서 **모델, 데이터셋, 코드, 설정을 어떻게 효율적으로 관리하고 배포할까요?** KitOps는 이 문제를 해결하는 혁신적인 오픈소스 DevOps 도구입니다. **OCI(Open Container Initiative) 표준을 활용**해 기존 컨테이너 레지스트리와 완벽하게 호환되면서, AI/ML 프로젝트의 전체 라이프사이클을 단순화합니다.

## KitOps란 무엇인가?

### 🎁 ModelKit 패키징 시스템

KitOps의 핵심은 **ModelKit**입니다. 이는 AI/ML 프로젝트의 모든 구성 요소를 하나의 불변(immutable) 패키지로 묶는 혁신적인 방법입니다:

```yaml
# Kitfile 예시
kitfile_version: 1.0
metadata:
  name: sentiment-analysis-model
  version: 1.2.0
  description: BERT 기반 감정 분석 모델

model:
  - name: bert-sentiment-model
    path: ./models/bert_sentiment.pkl
    description: 훈련된 BERT 감정 분석 모델

datasets:
  - name: training-data
    path: ./data/sentiment_train.csv
    description: 감정 분석 훈련 데이터
  - name: validation-data
    path: ./data/sentiment_val.csv
    description: 검증 데이터

code:
  - name: inference-script
    path: ./src/predict.py
    description: 추론 스크립트
  - name: preprocessing
    path: ./src/preprocess.py
    description: 데이터 전처리 코드

config:
  hyperparameters:
    learning_rate: 0.001
    batch_size: 32
    epochs: 10
  model_config:
    max_length: 512
    num_labels: 3
```

### 🏭 왜 KitOps가 필요한가?

**전통적인 AI/ML 개발의 문제점들:**

```python
# 기존 방식의 문제점들
traditional_problems = {
    'version_chaos': {
        'model_v1': '어떤 데이터로 훈련했지?',
        'dataset_v3': '어떤 전처리 코드를 사용했지?',
        'code_final_final_v2': '이 코드로 정말 이 모델을 만들었나?'
    },
    'reproducibility': {
        'issue': '6개월 후 같은 결과를 재현할 수 있을까?',
        'solution': 'ModelKit으로 완벽한 재현성 보장'
    },
    'collaboration': {
        'data_scientist': '모델만 공유하면 되지 않나?',
        'ml_engineer': '배포하려면 전처리 코드도 필요해!',
        'devops_engineer': '설정 파일은 어디에 있지?'
    }
}
```

**KitOps의 해결책:**

```python
# KitOps ModelKit의 장점
kitops_benefits = {
    'unified_packaging': {
        'what': '모델 + 데이터 + 코드 + 설정을 하나로',
        'benefit': '모든 팀원이 동일한 환경에서 작업'
    },
    'immutable_versioning': {
        'what': 'SHA 다이제스트로 변조 방지',
        'benefit': '완벽한 추적성과 보안성'
    },
    'selective_unpacking': {
        'what': '필요한 부분만 선택적 다운로드',
        'benefit': '저장 공간과 시간 절약'
    },
    'oci_standard': {
        'what': '기존 컨테이너 레지스트리 활용',
        'benefit': '추가 인프라 구축 불필요'
    }
}
```

## 실전 KitOps 사용법

### 🚀 설치 및 초기 설정

**1. Kit CLI 설치**

```bash
# macOS (Homebrew)
brew install kitops-ml/tap/kit

# Linux/Windows (직접 다운로드)
curl -s https://get.kitops.ml | bash

# 설치 확인
kit version
```

**2. 첫 번째 ModelKit 생성**

```bash
# 프로젝트 디렉토리 생성
mkdir my-ml-project && cd my-ml-project

# Kitfile 생성
kit init
```

### 📦 ModelKit 패키징 실습

**1. 프로젝트 구조 설정**

```bash
# 프로젝트 구조
my-ml-project/
├── Kitfile
├── models/
│   └── sentiment_model.pkl
├── data/
│   ├── train.csv
│   └── test.csv
├── src/
│   ├── train.py
│   ├── predict.py
│   └── preprocess.py
└── config/
    └── model_config.yaml
```

**2. Kitfile 작성**

```yaml
# Kitfile
kitfile_version: 1.0
metadata:
  name: sentiment-analysis-project
  version: 1.0.0
  authors: ["Your Name <your.email@company.com>"]
  description: "실시간 감정 분석 시스템"
  license: "MIT"

model:
  - name: sentiment-classifier
    path: ./models/sentiment_model.pkl
    description: "BERT 기반 감정 분류 모델"
    framework: "scikit-learn"
    size: "150MB"

datasets:
  - name: training-dataset
    path: ./data/train.csv
    description: "감정 라벨링된 훈련 데이터"
    rows: 50000
  - name: test-dataset
    path: ./data/test.csv
    description: "모델 평가용 테스트 데이터"
    rows: 10000

code:
  - name: inference-engine
    path: ./src/predict.py
    description: "실시간 추론 엔진"
    language: "python"
  - name: data-preprocessor
    path: ./src/preprocess.py
    description: "텍스트 전처리 파이프라인"
  - name: training-script
    path: ./src/train.py
    description: "모델 훈련 스크립트"

config:
  # 하이퍼파라미터
  hyperparameters:
    learning_rate: 0.001
    batch_size: 32
    max_length: 512
    dropout: 0.1
  
  # 모델 설정
  model_config:
    num_labels: 3
    hidden_size: 768
    num_attention_heads: 12
  
  # 추론 설정
  inference_config:
    max_batch_size: 16
    timeout: 30
    confidence_threshold: 0.8

  # MLOps 메타데이터
  experiment:
    mlflow_run_id: "abc123"
    wandb_project: "sentiment-analysis"
    accuracy: 0.94
    f1_score: 0.92
```

**3. ModelKit 빌드 및 태깅**

```bash
# ModelKit 생성
kit pack . -t localhost:5000/my-ml-project:1.0.0

# 태그 추가
kit tag localhost:5000/my-ml-project:1.0.0 localhost:5000/my-ml-project:latest

# ModelKit 정보 확인
kit inspect localhost:5000/my-ml-project:1.0.0
```

### 🔄 선택적 언패킹의 힘

KitOps의 가장 강력한 기능 중 하나는 **선택적 언패킹**입니다:

```bash
# 전체 ModelKit 언패킹
kit unpack localhost:5000/my-ml-project:1.0.0

# 모델만 필요한 경우 (추론 서버용)
kit unpack localhost:5000/my-ml-project:1.0.0 --model --config

# 데이터와 코드만 필요한 경우 (재훈련용)
kit unpack localhost:5000/my-ml-project:1.0.0 --datasets --code

# 특정 컴포넌트만 선택
kit unpack localhost:5000/my-ml-project:1.0.0 --filter "name:sentiment-classifier"
```

**실제 사용 시나리오:**

```python
# 팀별 필요 구성 요소
team_requirements = {
    'data_scientists': {
        'components': ['datasets', 'code', 'config'],
        'command': 'kit unpack model:1.0.0 --datasets --code --config',
        'use_case': '모델 개선 및 실험'
    },
    'ml_engineers': {
        'components': ['model', 'code', 'config'],
        'command': 'kit unpack model:1.0.0 --model --code --config',
        'use_case': '추론 서비스 구축'
    },
    'devops_engineers': {
        'components': ['model', 'config'],
        'command': 'kit unpack model:1.0.0 --model --config',
        'use_case': '프로덕션 배포'
    },
    'qa_engineers': {
        'components': ['datasets', 'model', 'config'],
        'command': 'kit unpack model:1.0.0 --datasets --model --config',
        'use_case': '모델 검증 및 테스트'
    }
}
```

## 고급 기능 활용하기

### 🐳 컨테이너 배포

**1. ModelKit에서 Docker 컨테이너 생성**

```bash
# 기본 컨테이너 생성
kit deploy create-container localhost:5000/my-ml-project:1.0.0 \
  --name sentiment-api

# 커스텀 베이스 이미지와 포트 설정
kit deploy create-container localhost:5000/my-ml-project:1.0.0 \
  --name sentiment-api \
  --base-image python:3.9-slim \
  --port 8080 \
  --env MODEL_PATH=/opt/model \
  --env API_KEY=your-api-key
```

**2. 생성된 Dockerfile 커스터마이징**

```dockerfile
# Kit이 생성한 Dockerfile을 기반으로 수정
FROM python:3.9-slim

# Kit이 자동으로 추가하는 ModelKit 구성 요소
COPY --from=kitops/unpack:latest /model /opt/model
COPY --from=kitops/unpack:latest /code /opt/code
COPY --from=kitops/unpack:latest /config /opt/config

# 추가 의존성 설치
RUN pip install fastapi uvicorn torch transformers

# 추론 서버 실행
WORKDIR /opt/code
EXPOSE 8080
CMD ["python", "predict.py", "--port", "8080"]
```

### ⚓ Kubernetes 배포

**1. KServe 배포 설정 생성**

```bash
# Kubernetes 배포 YAML 생성
kit deploy create-k8s localhost:5000/my-ml-project:1.0.0 \
  --output sentiment-deployment.yaml \
  --namespace ml-models \
  --replicas 3

# KServe InferenceService 생성
kit deploy create-kserve localhost:5000/my-ml-project:1.0.0 \
  --output sentiment-kserve.yaml \
  --predictor-type sklearn
```

**2. 생성된 Kubernetes 설정**

```yaml
# sentiment-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sentiment-analysis
  namespace: ml-models
spec:
  replicas: 3
  selector:
    matchLabels:
      app: sentiment-analysis
  template:
    metadata:
      labels:
        app: sentiment-analysis
    spec:
      containers:
      - name: sentiment-api
        image: localhost:5000/my-ml-project:1.0.0
        ports:
        - containerPort: 8080
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
        env:
        - name: MODEL_PATH
          value: "/opt/model"
---
apiVersion: v1
kind: Service
metadata:
  name: sentiment-service
  namespace: ml-models
spec:
  selector:
    app: sentiment-analysis
  ports:
  - port: 80
    targetPort: 8080
  type: ClusterIP
```

### 🔐 보안 및 서명

**1. ModelKit 서명**

```bash
# GPG 키로 ModelKit 서명
kit sign localhost:5000/my-ml-project:1.0.0 \
  --key-file ~/.gnupg/private-key.asc

# 서명 검증
kit verify localhost:5000/my-ml-project:1.0.0 \
  --key-file ~/.gnupg/public-key.asc
```

**2. Cosign을 활용한 고급 서명**

```bash
# Cosign으로 서명 (SLSA 준수)
cosign sign --key cosign.key localhost:5000/my-ml-project:1.0.0

# 서명 검증
cosign verify --key cosign.pub localhost:5000/my-ml-project:1.0.0
```

## 실전 워크플로우 예시

### 🔄 CI/CD 파이프라인 통합

**1. GitHub Actions 워크플로우**

```yaml
# .github/workflows/ml-pipeline.yml
name: ML Model Pipeline

on:
  push:
    branches: [main]
    paths: ['models/**', 'data/**', 'src/**']

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Install KitOps
      run: |
        curl -s https://get.kitops.ml | bash
        echo "$HOME/.local/bin" >> $GITHUB_PATH
    
    - name: Build ModelKit
      run: |
        kit pack . -t ${{ secrets.REGISTRY_URL }}/ml-models/$`github.repository`:$`github.sha`
        kit tag ${{ secrets.REGISTRY_URL }}/ml-models/$`github.repository`:$`github.sha` \
               ${{ secrets.REGISTRY_URL }}/ml-models/$`github.repository`:latest
    
    - name: Push to Registry
      run: |
        echo ${{ secrets.REGISTRY_PASSWORD }} | kit login ${{ secrets.REGISTRY_URL }} -u ${{ secrets.REGISTRY_USERNAME }} --password-stdin
        kit push ${{ secrets.REGISTRY_URL }}/ml-models/$`github.repository`:$`github.sha`
        kit push ${{ secrets.REGISTRY_URL }}/ml-models/$`github.repository`:latest
    
    - name: Deploy to Staging
      run: |
        kit deploy create-k8s ${{ secrets.REGISTRY_URL }}/ml-models/$`github.repository`:$`github.sha` \
          --output k8s-staging.yaml \
          --namespace ml-staging
        kubectl apply -f k8s-staging.yaml
    
    - name: Run Integration Tests
      run: |
        python tests/integration_test.py --endpoint http://ml-staging/predict
    
    - name: Deploy to Production
      if: success()
      run: |
        kit deploy create-k8s ${{ secrets.REGISTRY_URL }}/ml-models/$`github.repository`:latest \
          --output k8s-production.yaml \
          --namespace ml-production \
          --replicas 5
        kubectl apply -f k8s-production.yaml
```

**2. Dagger 파이프라인 통합**

```python
# dagger_pipeline.py
import dagger
from dagger import dag, function, object_type

@object_type
class MlPipeline:
    @function
    async def build_modelkit(self, source: dagger.Directory) -> str:
        """ModelKit 빌드 및 푸시"""
        return await (
            dag.container()
            .from_("kitops/kit:latest")
            .with_directory("/workspace", source)
            .with_workdir("/workspace")
            .with_exec(["kit", "pack", ".", "-t", "registry.company.com/ml-models/sentiment:latest"])
            .with_exec(["kit", "push", "registry.company.com/ml-models/sentiment:latest"])
            .stdout()
        )
    
    @function
    async def deploy_to_k8s(self, modelkit_tag: str) -> str:
        """Kubernetes에 배포"""
        return await (
            dag.container()
            .from_("kitops/kit:latest")
            .with_exec([
                "kit", "deploy", "create-k8s", modelkit_tag,
                "--output", "deployment.yaml",
                "--namespace", "production",
                "--replicas", "3"
            ])
            .with_exec(["kubectl", "apply", "-f", "deployment.yaml"])
            .stdout()
        )
```

### 🧪 개발 환경 설정

**1. 로컬 개발 모드**

```bash
# 개발 모드로 모델 실행
kit dev localhost:5000/my-ml-project:1.0.0

# 특정 포트와 설정으로 실행
kit dev localhost:5000/my-ml-project:1.0.0 \
  --port 8888 \
  --env DEBUG=true \
  --mount ./local-data:/data
```

**2. Jupyter Notebook 통합**

```python
# notebook_setup.py
import subprocess
import os

def setup_modelkit_env(modelkit_ref):
    """ModelKit을 Jupyter 환경에 설정"""
    
    # ModelKit 언패킹
    subprocess.run([
        "kit", "unpack", modelkit_ref,
        "--datasets", "--code", "--config",
        "--output", "./workspace"
    ])
    
    # 환경 변수 설정
    os.environ['MODEL_PATH'] = './workspace/model'
    os.environ['DATA_PATH'] = './workspace/datasets'
    os.environ['CONFIG_PATH'] = './workspace/config'
    
    print(f"✅ ModelKit {modelkit_ref} 환경 설정 완료")
    print(f"📁 작업 디렉토리: ./workspace")

# Jupyter에서 사용
setup_modelkit_env("localhost:5000/my-ml-project:1.0.0")
```

## 고급 활용 사례

### 🔄 LLM 파인튜닝 워크플로우

```yaml
# llm-finetune-kitfile
kitfile_version: 1.0
metadata:
  name: llama2-korean-chat
  version: 1.0.0
  description: "한국어 대화를 위해 파인튜닝된 Llama2 모델"

model:
  - name: base-model
    path: ./models/llama2-7b-base
    description: "기본 Llama2 7B 모델"
  - name: lora-adapters
    path: ./models/korean-chat-lora
    description: "한국어 대화 LoRA 어댑터"

datasets:
  - name: korean-conversation
    path: ./data/korean_chat_dataset.json
    description: "한국어 대화 데이터셋"
    rows: 100000

code:
  - name: finetune-script
    path: ./scripts/finetune_llama.py
    description: "파인튜닝 스크립트"
  - name: inference-server
    path: ./src/chat_server.py
    description: "채팅 서버"

config:
  training:
    learning_rate: 0.0001
    batch_size: 4
    gradient_accumulation_steps: 8
    lora_r: 16
    lora_alpha: 32
    lora_dropout: 0.1
  
  inference:
    max_new_tokens: 512
    temperature: 0.7
    top_p: 0.9
    repetition_penalty: 1.1
```

### 🎯 RAG 파이프라인 패키징

```yaml
# rag-pipeline-kitfile
kitfile_version: 1.0
metadata:
  name: company-docs-rag
  version: 2.1.0
  description: "회사 문서 기반 RAG 시스템"

model:
  - name: embedding-model
    path: ./models/sentence-transformer
    description: "한국어 임베딩 모델"
  - name: llm-model
    path: ./models/ko-llama-chat
    description: "한국어 생성 모델"

datasets:
  - name: company-documents
    path: ./data/company_docs_processed.jsonl
    description: "전처리된 회사 문서"
  - name: vector-index
    path: ./data/faiss_index.bin
    description: "FAISS 벡터 인덱스"

code:
  - name: rag-pipeline
    path: ./src/rag_engine.py
    description: "RAG 추론 파이프라인"
  - name: document-processor
    path: ./src/doc_processor.py
    description: "문서 전처리기"
  - name: api-server
    path: ./src/rag_api.py
    description: "REST API 서버"

config:
  retrieval:
    top_k: 5
    similarity_threshold: 0.7
    chunk_size: 512
    chunk_overlap: 50
  
  generation:
    max_tokens: 1024
    temperature: 0.3
    system_prompt: "당신은 회사 문서를 기반으로 정확한 정보를 제공하는 도우미입니다."
```

## EU AI Act 컴플라이언스

### 🇪🇺 규제 준수를 위한 ModelKit 활용

KitOps의 **불변성과 추적성**은 EU AI Act 컴플라이언스에 완벽합니다:

```yaml
# eu-compliant-kitfile
kitfile_version: 1.0
metadata:
  name: eu-compliant-credit-scoring
  version: 1.0.0
  description: "EU AI Act 준수 신용 평가 모델"
  
  # EU AI Act 메타데이터
  eu_ai_act:
    risk_category: "high_risk"
    ai_system_type: "credit_scoring"
    conformity_assessment: "completed"
    ce_marking: "yes"
    registration_id: "EU-AI-2025-001234"

model:
  - name: credit-model
    path: ./models/credit_scoring_v1.pkl
    description: "신용 평가 모델"
    # 모델 투명성 정보
    transparency:
      algorithm_type: "gradient_boosting"
      training_data_sources: ["public_credit_data", "synthetic_data"]
      bias_testing: "completed"
      fairness_metrics:
        demographic_parity: 0.92
        equal_opportunity: 0.88

datasets:
  - name: training-data
    path: ./data/training_anonymized.csv
    description: "익명화된 훈련 데이터"
    # 데이터 거버넌스
    governance:
      anonymization_method: "k_anonymity"
      consent_basis: "legitimate_interest"
      retention_period: "7_years"
      gdpr_compliant: true

config:
  # 위험 관리 시스템
  risk_management:
    risk_assessment_completed: true
    mitigation_measures: ["human_oversight", "bias_monitoring", "performance_monitoring"]
    testing_procedures: ["unit_tests", "integration_tests", "bias_tests", "performance_tests"]
  
  # 품질 관리 시스템
  quality_management:
    documentation_complete: true
    change_control: "version_controlled"
    validation_procedures: "cross_validation_kfold"
    
  # 인간 감독
  human_oversight:
    oversight_type: "human_in_the_loop"
    oversight_measures: ["decision_review", "appeal_process"]
    qualified_personnel: true
```

## 모니터링 및 운영

### 📊 ModelKit 생명주기 관리

```bash
# ModelKit 사용량 추적
kit usage localhost:5000/my-ml-project:1.0.0

# 취약점 스캔
kit security scan localhost:5000/my-ml-project:1.0.0

# 성능 메트릭 수집
kit metrics collect localhost:5000/my-ml-project:1.0.0 \
  --interval 5m \
  --output prometheus
```

**ModelKit 모니터링 대시보드:**

```python
# monitoring_dashboard.py
import prometheus_client
from prometheus_client import Counter, Histogram, Gauge
import time

# KitOps 메트릭
modelkit_downloads = Counter('modelkit_downloads_total', 'ModelKit 다운로드 수', ['name', 'version'])
modelkit_inference_duration = Histogram('modelkit_inference_duration_seconds', '추론 시간')
modelkit_active_deployments = Gauge('modelkit_active_deployments', '활성 배포 수')

class ModelKitMonitor:
    def __init__(self):
        self.start_time = time.time()
    
    def track_download(self, name, version):
        modelkit_downloads.labels(name=name, version=version).inc()
    
    def track_inference(self, duration):
        modelkit_inference_duration.observe(duration)
    
    def update_deployments(self, count):
        modelkit_active_deployments.set(count)
    
    def get_metrics(self):
        return {
            'uptime': time.time() - self.start_time,
            'total_downloads': sum(modelkit_downloads._value.values()),
            'avg_inference_time': modelkit_inference_duration._sum._value / modelkit_inference_duration._count._value
        }
```

## 문제 해결 가이드

### 🔧 일반적인 이슈들

**1. 큰 모델 파일 처리**

```bash
# 큰 파일을 위한 압축 설정
kit pack . -t localhost:5000/large-model:1.0.0 \
  --compression gzip \
  --chunk-size 100MB

# 스트리밍 언패킹
kit unpack localhost:5000/large-model:1.0.0 --stream
```

**2. 레지스트리 호환성 문제**

```bash
# OCI 1.1 호환성 확인
kit registry check localhost:5000

# 레거시 레지스트리 지원
kit push localhost:5000/model:1.0.0 --oci-version 1.0
```

**3. 성능 최적화**

```bash
# 병렬 업로드/다운로드
kit push localhost:5000/model:1.0.0 --parallel 4

# 캐시 활용
kit unpack localhost:5000/model:1.0.0 --cache-dir ~/.kit/cache
```

## 미래 전망과 로드맵

### 🚀 KitOps의 발전 방향

KitOps 커뮤니티가 공개한 로드맵에 따르면:

```python
kitops_roadmap = {
    '2025_q2': [
        'Enhanced Kubernetes integration',
        'Better support for multi-modal models',
        'Improved CLI performance',
        'Advanced caching mechanisms'
    ],
    '2025_q3': [
        'Native cloud provider integrations',
        'Advanced model lineage tracking',
        'Automated model validation',
        'Enhanced security features'
    ],
    '2025_q4': [
        'Federated ModelKit repositories',
        'AI-powered model recommendations',
        'Advanced analytics and insights',
        'Enterprise governance features'
    ]
}
```

### 🌍 생태계 통합

```markdown
## KitOps 생태계 확장

### 🤝 파트너십
- **Red Hat InstructLab**: OpenShift에서 네이티브 지원
- **Quay.io**: 엔터프라이즈 컨테이너 레지스트리 통합
- **Dagger**: CI/CD 파이프라인 모듈 제공
- **Jozu Hub**: 전용 ModelKit 레지스트리 서비스

### 🛠️ 도구 통합
- **MLflow**: 실험 추적과 ModelKit 연동
- **Kubeflow**: ML 파이프라인에서 ModelKit 활용
- **Weights & Biases**: 모델 메타데이터 자동 동기화
- **Neptune**: 모델 버전 관리 통합
```

## 결론

**KitOps는 AI/ML 프로젝트의 패키징과 배포를 혁신하는 게임 체인저입니다.** 전통적인 모델 관리의 복잡성을 해결하고, **Docker와 같은 표준을 AI/ML 세계에 도입**하여 개발자들에게 친숙하면서도 강력한 도구를 제공합니다.

### 🎯 핵심 가치 제안

- ✅ **통합 패키징**: 모델, 데이터, 코드, 설정을 하나로
- ✅ **완벽한 재현성**: SHA 다이제스트로 보장되는 불변성
- ✅ **선택적 활용**: 필요한 구성 요소만 다운로드
- ✅ **표준 호환**: OCI 표준으로 기존 인프라 활용
- ✅ **보안 강화**: 서명과 검증으로 공급망 보안
- ✅ **규제 준수**: EU AI Act 등 규제 요구사항 충족

### 🚀 시작해보세요

KitOps를 도입하면 **AI/ML 프로젝트의 협업과 배포가 Docker만큼 간단해집니다.** 데이터 사이언티스트, ML 엔지니어, DevOps 팀 간의 원활한 협업을 경험해보세요.

```bash
# 지금 바로 시작하기
curl -s https://get.kitops.ml | bash
kit init my-first-modelkit
```

**KitOps는 AI/ML의 미래를 만들어가는 오픈소스 프로젝트입니다.** 여러분의 프로젝트에 KitOps를 도입하고, 더 나은 AI/ML 개발 경험을 만들어보세요! 🎉

## 참고 자료

- **KitOps 공식 사이트**: [KitOps.org](https://kitops.org)
- **GitHub 저장소**: [kitops-ml/kitops](https://github.com/kitops-ml/kitops)
- **Discord 커뮤니티**: [KitOps Discord](https://discord.gg/kitops)
- **문서**: [KitOps Documentation](https://kitops.org/docs)
- **Jozu Hub**: [ModelKit Registry](https://jozu.ml)

---

*이 가이드는 2025년 6월 11일 기준으로 작성되었으며, KitOps의 최신 기능과 함께 지속적으로 업데이트될 예정입니다.*
