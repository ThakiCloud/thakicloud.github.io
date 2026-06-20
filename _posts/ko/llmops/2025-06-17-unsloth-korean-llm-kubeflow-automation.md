---
title: "Unsloth+TRL 한국어 LLM 학습 자동화 - 3편: Kubeflow 및 MLOps 프레임워크 활용"
excerpt: "Kubeflow, MLflow, DVC를 활용한 엔터프라이즈급 한국어 LLM 학습 파이프라인 구축"
date: 2025-06-17
categories:
  - llmops
tags:
  - Kubeflow
  - MLflow
  - DVC
  - MLOps
  - Korean LLM
  - Unsloth
  - Pipeline Automation
  - Model Registry
author_profile: true
toc: true
toc_label: "목차"
published: false
---

## 개요

본 가이드는 [Unsloth+TRL 한국어 LLM 학습 시리즈](#)의 3편으로, Kubeflow, MLflow, DVC 등 엔터프라이즈급 MLOps 프레임워크를 활용하여 한국어 LLM 학습을 완전 자동화하는 방법을 다룹니다.

**학습 목표**:

- 🚀 **Kubeflow Pipelines**: 시각적 ML 워크플로우 구축
- 📊 **MLflow**: 실험 추적 및 모델 레지스트리 관리
- 🔄 **DVC**: 데이터 버전 관리 및 재현 가능한 파이프라인
- ⚡ **통합 MLOps**: 엔드투엔드 자동화 시스템

---

## 1. Kubeflow 설치 및 설정

### 1.1 Kubeflow 설치

```bash
# Kubeflow 1.8 설치
export PIPELINE_VERSION=1.8.5
kubectl apply -k "github.com/kubeflow/pipelines/manifests/kustomize/cluster-scoped-resources?ref=$PIPELINE_VERSION"
kubectl wait --for condition=established --timeout=60s crd/applications.app.k8s.io
kubectl apply -k "github.com/kubeflow/pipelines/manifests/kustomize/env/platform-agnostic-pns?ref=$PIPELINE_VERSION"

# Kubeflow Dashboard 접근
kubectl port-forward -n kubeflow svc/ml-pipeline-ui 8080:80
```

### 1.2 Kubeflow Notebooks 설정

```yaml
# kubeflow-notebook.yaml
apiVersion: kubeflow.org/v1
kind: Notebook
metadata:
  name: korean-llm-notebook
  namespace: kubeflow-user-example-com
spec:
  template:
    spec:
      containers:
      - name: notebook
        image: jupyter/tensorflow-notebook:latest
        resources:
          requests:
            nvidia.com/gpu: 1
            memory: 16Gi
            cpu: 4
          limits:
            nvidia.com/gpu: 1
            memory: 16Gi
            cpu: 4
        volumeMounts:
        - name: workspace-pvc
          mountPath: /home/jovyan/work
      volumes:
      - name: workspace-pvc
        persistentVolumeClaim:
          claimName: workspace-pvc
```

---

## 2. MLflow 통합

### 2.1 MLflow 서버 설정

```yaml
# mlflow-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mlflow-server
  namespace: mlops
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mlflow-server
  template:
    metadata:
      labels:
        app: mlflow-server
    spec:
      containers:
      - name: mlflow
        image: python:3.9-slim
        command:
        - /bin/bash
        - -c
        - |
          pip install mlflow==2.8.1 psycopg2-binary boto3
          mlflow server \
            --backend-store-uri postgresql://mlflow:password@postgres:5432/mlflow \
            --default-artifact-root s3://mlflow-artifacts/ \
            --host 0.0.0.0 \
            --port 5000
        ports:
        - containerPort: 5000
        env:
        - name: AWS_ACCESS_KEY_ID
          valueFrom:
            secretKeyRef:
              name: s3-credentials
              key: access-key
        - name: AWS_SECRET_ACCESS_KEY
          valueFrom:
            secretKeyRef:
              name: s3-credentials
              key: secret-key
        - name: MLFLOW_S3_ENDPOINT_URL
          value: "https://s3.amazonaws.com"
```

### 2.2 실험 추적 코드

```python
# mlflow_tracker.py
import mlflow
import mlflow.pytorch
from mlflow.tracking import MlflowClient
import torch
from datetime import datetime

class KoreanLLMTracker:
    def __init__(self, experiment_name="korean-llm-training"):
        self.client = MlflowClient()
        mlflow.set_tracking_uri("http://mlflow-server:5000")
        
        # 실험 생성 또는 가져오기
        try:
            experiment = self.client.get_experiment_by_name(experiment_name)
            self.experiment_id = experiment.experiment_id
        except:
            self.experiment_id = self.client.create_experiment(experiment_name)
    
    def start_run(self, run_name, stage="CPT"):
        """실험 실행 시작"""
        self.run = mlflow.start_run(
            experiment_id=self.experiment_id,
            run_name=f"{run_name}-{stage}-{datetime.now().strftime('%Y%m%d-%H%M%S')}"
        )
        return self.run
    
    def log_parameters(self, params):
        """하이퍼파라미터 로깅"""
        mlflow.log_params(params)
    
    def log_metrics(self, metrics, step=None):
        """메트릭 로깅"""
        mlflow.log_metrics(metrics, step=step)
    
    def log_model(self, model, model_name, signature=None):
        """모델 로깅"""
        mlflow.pytorch.log_model(
            pytorch_model=model,
            artifact_path=model_name,
            signature=signature
        )
    
    def register_model(self, model_name, stage="Staging"):
        """모델 레지스트리에 등록"""
        model_uri = f"runs:/{self.run.info.run_id}/{model_name}"
        mlflow.register_model(model_uri, model_name)
        
        # 모델 스테이지 설정
        client = MlflowClient()
        client.transition_model_version_stage(
            name=model_name,
            version=1,
            stage=stage
        )
    
    def end_run(self):
        """실험 종료"""
        mlflow.end_run()
```

---

## 3. DVC 데이터 버전 관리

### 3.1 DVC 설정

```bash
# DVC 초기화
dvc init --no-scm
dvc remote add -d myremote s3://korean-llm-data

# 데이터 추적
dvc add data/korean_corpus.jsonl
dvc add data/instruction_dataset.jsonl

# 파이프라인 정의
dvc stage add -n preprocess \
  -d data/raw_korean_text.txt \
  -o data/korean_corpus.jsonl \
  python scripts/preprocess.py

dvc stage add -n cpt_training \
  -d data/korean_corpus.jsonl \
  -d scripts/cpt_train.py \
  -o models/cpt_model \
  -M metrics/cpt_metrics.json \
  python scripts/cpt_train.py

dvc stage add -n sft_training \
  -d models/cpt_model \
  -d data/instruction_dataset.jsonl \
  -o models/sft_model \
  -M metrics/sft_metrics.json \
  python scripts/sft_train.py
```

### 3.2 DVC 파이프라인 정의

```yaml
# dvc.yaml
stages:
  preprocess:
    cmd: python scripts/preprocess.py
    deps:
    - data/raw_korean_text.txt
    - scripts/preprocess.py
    outs:
    - data/korean_corpus.jsonl
    
  cpt_training:
    cmd: python scripts/cpt_train.py
    deps:
    - data/korean_corpus.jsonl
    - scripts/cpt_train.py
    outs:
    - models/cpt_model
    metrics:
    - metrics/cpt_metrics.json
    
  sft_training:
    cmd: python scripts/sft_train.py
    deps:
    - models/cpt_model
    - data/instruction_dataset.jsonl
    - scripts/sft_train.py
    outs:
    - models/sft_model
    metrics:
    - metrics/sft_metrics.json
    
  evaluation:
    cmd: python scripts/evaluate.py
    deps:
    - models/sft_model
    - scripts/evaluate.py
    metrics:
    - metrics/evaluation_metrics.json
```

---

## 4. Kubeflow Pipelines 구성

### 4.1 파이프라인 컴포넌트 정의

```python
# kubeflow_components.py
from kfp import dsl, components
from kfp.components import InputPath, OutputPath
import kfp

def preprocess_data_op(
    raw_data_path: InputPath(str),
    processed_data_path: OutputPath(str)
):
    """데이터 전처리 컴포넌트"""
    import json
    import re
    from pathlib import Path
    
    def clean_korean_text(text):
        # 한국어 텍스트 정규화
        text = re.sub(r'\s+', ' ', text)
        text = text.replace('ㆍ', '·')
        return text.strip()
    
    # 원본 데이터 로드
    with open(raw_data_path, 'r', encoding='utf-8') as f:
        raw_text = f.read()
    
    # 전처리
    processed_text = clean_korean_text(raw_text)
    
    # 결과 저장
    processed_data = {
        "text": processed_text,
        "length": len(processed_text),
        "language": "korean"
    }
    
    with open(processed_data_path, 'w', encoding='utf-8') as f:
        json.dump(processed_data, f, ensure_ascii=False, indent=2)

def cpt_training_op(
    data_path: InputPath(str),
    model_output_path: OutputPath(str),
    metrics_path: OutputPath(str),
    model_size: str = "7B",
    learning_rate: float = 1e-5,
    num_epochs: int = 2
):
    """CPT 학습 컴포넌트"""
    import torch
    from unsloth import FastLanguageModel
    from datasets import load_dataset
    from transformers import TrainingArguments
    from trl import SFTTrainer
    import json
    import mlflow
    
    # MLflow 설정
    mlflow.set_tracking_uri("http://mlflow-server:5000")
    
    with mlflow.start_run():
        # 파라미터 로깅
        mlflow.log_params({
            "model_size": model_size,
            "learning_rate": learning_rate,
            "num_epochs": num_epochs,
            "stage": "CPT"
        })
        
        # 모델 로딩
        model_name = f"unsloth/Qwen2.5-{model_size}-bnb-4bit"
        model, tokenizer = FastLanguageModel.from_pretrained(
            model_name=model_name,
            max_seq_length=4096,
            dtype=None,
            load_in_4bit=True,
        )
        
        # LoRA 설정
        model = FastLanguageModel.get_peft_model(
            model,
            r=64,
            target_modules=["q_proj", "k_proj", "v_proj", "o_proj"],
            lora_alpha=16,
            lora_dropout=0.1,
            bias="none",
            use_gradient_checkpointing="unsloth",
        )
        
        # 데이터셋 로딩
        dataset = load_dataset("json", data_files=data_path, split="train")
        
        # 학습 설정
        training_args = TrainingArguments(
            output_dir=model_output_path,
            num_train_epochs=num_epochs,
            per_device_train_batch_size=2,
            learning_rate=learning_rate,
            logging_steps=100,
            save_steps=1000,
            fp16=True,
        )
        
        # 트레이너 초기화 및 학습
        trainer = SFTTrainer(
            model=model,
            tokenizer=tokenizer,
            args=training_args,
            train_dataset=dataset,
            dataset_text_field="text",
        )
        
        # 학습 실행
        trainer.train()
        
        # 모델 저장
        trainer.save_model(model_output_path)
        
        # 메트릭 저장
        metrics = {
            "final_loss": trainer.state.log_history[-1]["train_loss"],
            "total_steps": trainer.state.global_step,
            "model_size": model_size
        }
        
        with open(metrics_path, 'w') as f:
            json.dump(metrics, f, indent=2)
        
        # MLflow에 메트릭 로깅
        mlflow.log_metrics(metrics)
        mlflow.pytorch.log_model(model, "cpt_model")

def sft_training_op(
    base_model_path: InputPath(str),
    instruction_data_path: InputPath(str),
    model_output_path: OutputPath(str),
    metrics_path: OutputPath(str),
    learning_rate: float = 2e-5,
    num_epochs: int = 3
):
    """SFT 학습 컴포넌트"""
    import torch
    from unsloth import FastLanguageModel
    from datasets import load_dataset
    from transformers import TrainingArguments
    from trl import SFTTrainer
    import json
    import mlflow
    
    mlflow.set_tracking_uri("http://mlflow-server:5000")
    
    with mlflow.start_run():
        # 파라미터 로깅
        mlflow.log_params({
            "learning_rate": learning_rate,
            "num_epochs": num_epochs,
            "stage": "SFT"
        })
        
        # 베이스 모델 로딩
        model, tokenizer = FastLanguageModel.from_pretrained(
            model_name=base_model_path,
            max_seq_length=2048,
            dtype=None,
            load_in_4bit=True,
        )
        
        # Instruction 데이터셋 로딩
        dataset = load_dataset("json", data_files=instruction_data_path, split="train")
        
        # 학습 설정
        training_args = TrainingArguments(
            output_dir=model_output_path,
            num_train_epochs=num_epochs,
            per_device_train_batch_size=4,
            learning_rate=learning_rate,
            logging_steps=50,
            save_steps=500,
            fp16=True,
        )
        
        # 트레이너 초기화 및 학습
        trainer = SFTTrainer(
            model=model,
            tokenizer=tokenizer,
            args=training_args,
            train_dataset=dataset,
            dataset_text_field="text",
        )
        
        trainer.train()
        trainer.save_model(model_output_path)
        
        # 메트릭 저장
        metrics = {
            "final_loss": trainer.state.log_history[-1]["train_loss"],
            "total_steps": trainer.state.global_step,
            "stage": "SFT"
        }
        
        with open(metrics_path, 'w') as f:
            json.dump(metrics, f, indent=2)
        
        mlflow.log_metrics(metrics)
        mlflow.pytorch.log_model(model, "sft_model")

def evaluation_op(
    model_path: InputPath(str),
    evaluation_results_path: OutputPath(str),
    test_data_path: str = "/data/test_dataset.jsonl"
):
    """모델 평가 컴포넌트"""
    import torch
    from unsloth import FastLanguageModel
    from datasets import load_dataset
    import json
    import mlflow
    
    mlflow.set_tracking_uri("http://mlflow-server:5000")
    
    with mlflow.start_run():
        # 모델 로딩
        model, tokenizer = FastLanguageModel.from_pretrained(
            model_name=model_path,
            max_seq_length=2048,
            dtype=None,
            load_in_4bit=True,
        )
        
        # 추론 모드로 설정
        FastLanguageModel.for_inference(model)
        
        # 테스트 데이터 로딩
        test_dataset = load_dataset("json", data_files=test_data_path, split="train")
        
        # 평가 실행
        total_samples = len(test_dataset)
        correct_predictions = 0
        
        for sample in test_dataset[:100]:  # 샘플 100개로 제한
            prompt = sample["prompt"]
            expected = sample["expected"]
            
            inputs = tokenizer(prompt, return_tensors="pt")
            outputs = model.generate(**inputs, max_new_tokens=256)
            prediction = tokenizer.decode(outputs[0], skip_special_tokens=True)
            
            # 간단한 정확도 계산 (실제로는 더 정교한 메트릭 필요)
            if expected.lower() in prediction.lower():
                correct_predictions += 1
        
        accuracy = correct_predictions / min(100, total_samples)
        
        # 결과 저장
        results = {
            "accuracy": accuracy,
            "total_samples": min(100, total_samples),
            "correct_predictions": correct_predictions
        }
        
        with open(evaluation_results_path, 'w') as f:
            json.dump(results, f, indent=2)
        
        mlflow.log_metrics(results)

# 컴포넌트 생성
preprocess_data_component = components.create_component_from_func(
    preprocess_data_op,
    base_image="python:3.9-slim",
    packages_to_install=["datasets", "transformers"]
)

cpt_training_component = components.create_component_from_func(
    cpt_training_op,
    base_image="nvidia/cuda:11.8-devel-ubuntu20.04",
    packages_to_install=[
        "torch", "transformers", "datasets", 
        "unsloth @ git+https://github.com/unslothai/unsloth.git",
        "mlflow"
    ]
)

sft_training_component = components.create_component_from_func(
    sft_training_op,
    base_image="nvidia/cuda:11.8-devel-ubuntu20.04",
    packages_to_install=[
        "torch", "transformers", "datasets",
        "unsloth @ git+https://github.com/unslothai/unsloth.git",
        "mlflow"
    ]
)

evaluation_component = components.create_component_from_func(
    evaluation_op,
    base_image="nvidia/cuda:11.8-devel-ubuntu20.04",
    packages_to_install=[
        "torch", "transformers", "datasets",
        "unsloth @ git+https://github.com/unslothai/unsloth.git",
        "mlflow"
    ]
)
```

### 4.2 파이프라인 정의

```python
# korean_llm_pipeline.py
from kfp import dsl
from kubeflow_components import *

@dsl.pipeline(
    name="Korean LLM Training Pipeline",
    description="Complete pipeline for training Korean-specialized LLM using Unsloth"
)
def korean_llm_training_pipeline(
    raw_data_path: str = "/data/raw_korean_text.txt",
    instruction_data_path: str = "/data/instruction_dataset.jsonl",
    model_size: str = "7B",
    cpt_learning_rate: float = 1e-5,
    sft_learning_rate: float = 2e-5,
    cpt_epochs: int = 2,
    sft_epochs: int = 3
):
    """한국어 LLM 학습 파이프라인"""
    
    # 1. 데이터 전처리
    preprocess_task = preprocess_data_component(
        raw_data_path=raw_data_path
    )
    
    # 2. CPT 학습
    cpt_task = cpt_training_component(
        data_path=preprocess_task.outputs["processed_data_path"],
        model_size=model_size,
        learning_rate=cpt_learning_rate,
        num_epochs=cpt_epochs
    )
    
    # GPU 리소스 요청
    cpt_task.set_gpu_limit(4)
    cpt_task.set_memory_limit("200Gi")
    cpt_task.set_cpu_limit("32")
    
    # 3. SFT 학습
    sft_task = sft_training_component(
        base_model_path=cpt_task.outputs["model_output_path"],
        instruction_data_path=instruction_data_path,
        learning_rate=sft_learning_rate,
        num_epochs=sft_epochs
    )
    
    # GPU 리소스 요청
    sft_task.set_gpu_limit(2)
    sft_task.set_memory_limit("100Gi")
    sft_task.set_cpu_limit("16")
    
    # 4. 모델 평가
    evaluation_task = evaluation_component(
        model_path=sft_task.outputs["model_output_path"]
    )
    
    evaluation_task.set_gpu_limit(1)
    evaluation_task.set_memory_limit("50Gi")
    evaluation_task.set_cpu_limit("8")
    
    # 파이프라인 설정
    preprocess_task.set_retry(3)
    cpt_task.set_retry(2)
    sft_task.set_retry(2)
    evaluation_task.set_retry(3)

# 파이프라인 컴파일
if __name__ == "__main__":
    from kfp.compiler import Compiler
    
    Compiler().compile(
        pipeline_func=korean_llm_training_pipeline,
        package_path="korean_llm_pipeline.yaml"
    )
```

---

## 5. 통합 모니터링 대시보드

### 5.1 Grafana 대시보드 설정

```json
{
  "dashboard": {
    "title": "Korean LLM Training - MLOps Dashboard",
    "panels": [
      {
        "title": "Pipeline Execution Status",
        "type": "stat",
        "targets": [
          {
            "expr": "kubeflow_pipeline_runs_total",
            "legendFormat": "Total Runs"
          }
        ]
      },
      {
        "title": "Training Loss Over Time",
        "type": "graph",
        "targets": [
          {
            "expr": "mlflow_metric_train_loss",
            "legendFormat": "{{stage}} Loss"
          }
        ]
      },
      {
        "title": "GPU Utilization",
        "type": "graph",
        "targets": [
          {
            "expr": "nvidia_gpu_utilization",
            "legendFormat": "GPU {{gpu}}"
          }
        ]
      },
      {
        "title": "Model Performance Metrics",
        "type": "table",
        "targets": [
          {
            "expr": "mlflow_metric_accuracy",
            "legendFormat": "Accuracy"
          }
        ]
      }
    ]
  }
}
```

### 5.2 알림 설정

```yaml
# alerting-rules.yaml
groups:
- name: korean-llm-training
  rules:
  - alert: TrainingJobFailed
    expr: kubeflow_pipeline_run_status{status="Failed"} > 0
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "Korean LLM training job failed"
      description: "Pipeline {% raw %}{{ $labels.pipeline_name }}{% endraw %} failed"
  
  - alert: LowGPUUtilization
    expr: nvidia_gpu_utilization < 50
    for: 10m
    labels:
      severity: warning
    annotations:
      summary: "Low GPU utilization detected"
      description: "GPU utilization is below 50% for 10 minutes"
  
  - alert: HighTrainingLoss
    expr: increase(mlflow_metric_train_loss[1h]) > 0.1
    for: 30m
    labels:
      severity: warning
    annotations:
      summary: "Training loss is increasing"
      description: "Training loss increased by more than 0.1 in the last hour"
```

---

## 6. 자동화된 모델 배포

### 6.1 모델 레지스트리 연동

```python
# model_deployment.py
from mlflow.tracking import MlflowClient
import kubernetes
from kubernetes import client, config
import yaml

class ModelDeploymentManager:
    def __init__(self):
        self.mlflow_client = MlflowClient("http://mlflow-server:5000")
        config.load_incluster_config()
        self.k8s_apps_v1 = client.AppsV1Api()
        self.k8s_core_v1 = client.CoreV1Api()
    
    def get_latest_model(self, model_name, stage="Production"):
        """최신 프로덕션 모델 가져오기"""
        latest_version = self.mlflow_client.get_latest_versions(
            model_name, 
            stages=[stage]
        )[0]
        return latest_version
    
    def create_inference_deployment(self, model_version, namespace="inference"):
        """추론 서비스 배포"""
        deployment_yaml = f"""
apiVersion: apps/v1
kind: Deployment
metadata:
  name: korean-llm-inference
  namespace: {namespace}
spec:
  replicas: 2
  selector:
    matchLabels:
      app: korean-llm-inference
  template:
    metadata:
      labels:
        app: korean-llm-inference
    spec:
      containers:
      - name: inference-server
        image: your-registry/korean-llm-inference:latest
        env:
        - name: MODEL_URI
          value: "{model_version.source}"
        - name: MODEL_VERSION
          value: "{model_version.version}"
        ports:
        - containerPort: 8000
        resources:
          requests:
            nvidia.com/gpu: 1
            memory: 16Gi
            cpu: 4
          limits:
            nvidia.com/gpu: 1
            memory: 16Gi
            cpu: 4
---
apiVersion: v1
kind: Service
metadata:
  name: korean-llm-service
  namespace: {namespace}
spec:
  selector:
    app: korean-llm-inference
  ports:
  - port: 80
    targetPort: 8000
  type: LoadBalancer
"""
        
        # YAML 파싱 및 배포
        deployment_dict = yaml.safe_load(deployment_yaml)
        
        # Deployment 생성
        self.k8s_apps_v1.create_namespaced_deployment(
            namespace=namespace,
            body=deployment_dict
        )
    
    def auto_deploy_on_model_update(self, model_name):
        """모델 업데이트 시 자동 배포"""
        latest_model = self.get_latest_model(model_name)
        
        # 현재 배포된 모델 버전 확인
        current_deployment = self.k8s_apps_v1.read_namespaced_deployment(
            name="korean-llm-inference",
            namespace="inference"
        )
        
        current_version = None
        for env in current_deployment.spec.template.spec.containers[0].env:
            if env.name == "MODEL_VERSION":
                current_version = env.value
                break
        
        # 새 버전이 있으면 배포 업데이트
        if current_version != latest_model.version:
            print(f"Updating deployment from version {current_version} to {latest_model.version}")
            self.update_deployment(latest_model)
    
    def update_deployment(self, model_version):
        """배포 업데이트"""
        # 배포 업데이트 로직
        patch = {
            "spec": {
                "template": {
                    "spec": {
                        "containers": [{
                            "name": "inference-server",
                            "env": [
                                {"name": "MODEL_URI", "value": model_version.source},
                                {"name": "MODEL_VERSION", "value": model_version.version}
                            ]
                        }]
                    }
                }
            }
        }
        
        self.k8s_apps_v1.patch_namespaced_deployment(
            name="korean-llm-inference",
            namespace="inference",
            body=patch
        )
```

### 6.2 A/B 테스트 설정

```yaml
# ab-testing-setup.yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: korean-llm-rollout
  namespace: inference
spec:
  replicas: 4
  strategy:
    canary:
      steps:
      - setWeight: 25
      - pause: {duration: 10m}
      - setWeight: 50
      - pause: {duration: 10m}
      - setWeight: 75
      - pause: {duration: 10m}
      analysis:
        templates:
        - templateName: success-rate
        args:
        - name: service-name
          value: korean-llm-service
  selector:
    matchLabels:
      app: korean-llm-inference
  template:
    metadata:
      labels:
        app: korean-llm-inference
    spec:
      containers:
      - name: inference-server
        image: your-registry/korean-llm-inference:latest
        ports:
        - containerPort: 8000
        resources:
          requests:
            nvidia.com/gpu: 1
            memory: 16Gi
---
apiVersion: argoproj.io/v1alpha1
kind: AnalysisTemplate
metadata:
  name: success-rate
spec:
  args:
  - name: service-name
  metrics:
  - name: success-rate
    interval: 2m
    count: 5
    successCondition: result[0] >= 0.95
    provider:
      prometheus:
        address: http://prometheus:9090
        query: |
          sum(rate(http_requests_total{service="{{args.service-name}}",code=~"2.."}[2m])) /
          sum(rate(http_requests_total{service="{{args.service-name}}"}[2m]))
```

---

## 7. 실행 및 관리

### 7.1 파이프라인 실행

```python
# run_pipeline.py
import kfp
from kfp import dsl

# Kubeflow Pipelines 클라이언트 생성
client = kfp.Client(host="http://kubeflow-pipelines:8080")

# 파이프라인 업로드
pipeline_id = client.upload_pipeline(
    pipeline_package_path="korean_llm_pipeline.yaml",
    pipeline_name="Korean LLM Training Pipeline v1.0"
)

# 실험 생성
experiment = client.create_experiment(
    name="Korean LLM Training Experiment",
    description="Automated training of Korean-specialized LLM"
)

# 파이프라인 실행
run = client.run_pipeline(
    experiment_id=experiment.id,
    job_name="korean-llm-training-run-1",
    pipeline_id=pipeline_id,
    params={
        "model_size": "7B",
        "cpt_learning_rate": 1e-5,
        "sft_learning_rate": 2e-5,
        "cpt_epochs": 2,
        "sft_epochs": 3
    }
)

print(f"Pipeline run started: {run.id}")
```

### 7.2 자동화 스케줄링

```python
# scheduler.py
from kfp import dsl
import schedule
import time

class PipelineScheduler:
    def __init__(self, client):
        self.client = client
        self.pipeline_id = None
        self.experiment_id = None
    
    def setup_pipeline(self):
        """파이프라인 및 실험 설정"""
        # 파이프라인 업로드
        self.pipeline_id = self.client.upload_pipeline(
            pipeline_package_path="korean_llm_pipeline.yaml",
            pipeline_name="Korean LLM Scheduled Training"
        )
        
        # 실험 생성
        experiment = self.client.create_experiment(
            name="Scheduled Korean LLM Training"
        )
        self.experiment_id = experiment.id
    
    def run_training_pipeline(self):
        """학습 파이프라인 실행"""
        run = self.client.run_pipeline(
            experiment_id=self.experiment_id,
            job_name=f"scheduled-run-{int(time.time())}",
            pipeline_id=self.pipeline_id,
            params={
                "model_size": "7B",
                "cpt_learning_rate": 1e-5,
                "sft_learning_rate": 2e-5
            }
        )
        print(f"Scheduled pipeline run started: {run.id}")
    
    def start_scheduler(self):
        """스케줄러 시작"""
        # 매주 일요일 오전 2시에 실행
        schedule.every().sunday.at("02:00").do(self.run_training_pipeline)
        
        # 새로운 데이터가 추가될 때마다 실행 (예: 매일 체크)
        schedule.every().day.at("06:00").do(self.check_and_run_if_new_data)
        
        while True:
            schedule.run_pending()
            time.sleep(3600)  # 1시간마다 체크
    
    def check_and_run_if_new_data(self):
        """새로운 데이터가 있을 때만 실행"""
        # DVC를 사용하여 데이터 변경 확인
        import subprocess
        result = subprocess.run(["dvc", "status"], capture_output=True, text=True)
        
        if "changed" in result.stdout:
            print("New data detected, starting training pipeline...")
            self.run_training_pipeline()
        else:
            print("No new data, skipping training...")

# 사용 예시
if __name__ == "__main__":
    client = kfp.Client(host="http://kubeflow-pipelines:8080")
    scheduler = PipelineScheduler(client)
    scheduler.setup_pipeline()
    scheduler.start_scheduler()
```

---

## 결론

본 가이드를 통해 Kubeflow, MLflow, DVC를 활용한 엔터프라이즈급 한국어 LLM 학습 자동화 시스템을 구축했습니다.

**주요 성과**:

- 🚀 **완전 자동화**: 데이터 → 학습 → 평가 → 배포 전 과정
- 📊 **실험 관리**: MLflow를 통한 체계적 실험 추적
- 🔄 **데이터 버전 관리**: DVC로 재현 가능한 파이프라인
- ⚡ **확장성**: Kubeflow의 분산 처리 및 스케일링

**실무적 가치**:

- **운영 효율성**: GUI 기반 파이프라인 관리
- **품질 보증**: 자동화된 평가 및 배포 검증
- **비용 최적화**: 리소스 사용량 최적화
- **거버넌스**: 모델 레지스트리를 통한 모델 생명주기 관리

이 시리즈의 다른 글 보기:

- [1편: Unsloth를 활용한 한국어 특화 LLM 학습 완전 가이드](#)
- [2편: 쿠버네티스 파이프라인 구축](#)
- 3편: Kubeflow 및 MLOps 프레임워크 활용 (현재 글)

이러한 엔터프라이즈급 MLOps 시스템을 통해 한국어 특화 LLM 개발의 생산성과 품질을 극대화할 수 있습니다.
