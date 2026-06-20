---
title: "Unsloth+TRL 한국어 LLM 학습 자동화 - 2편: 쿠버네티스 파이프라인 구축"
excerpt: "쿠버네티스로 Unsloth+TRL 기반 한국어 LLM 학습 파이프라인을 완전 자동화하는 실무 가이드"
date: 2025-06-17
categories:
  - llmops
tags:
  - Kubernetes
  - Unsloth
  - Korean LLM
  - MLOps
  - Automation
  - Pipeline
  - GPU Scheduling
  - Distributed Training
author_profile: true
toc: true
toc_label: "목차"
published: false
---

## 개요

본 가이드는 [Unsloth+TRL 한국어 LLM 학습 가이드 - 1편](#)의 연장선으로, 쿠버네티스를 활용하여 한국어 특화 LLM 학습 과정을 완전 자동화하는 방법을 다룹니다.

**학습 목표**:

- 🚀 **자동화된 학습 파이프라인**: CPT → SFT → RLHF 자동 실행
- 🎯 **GPU 리소스 최적화**: 동적 스케줄링 및 효율적 활용
- 📊 **모니터링 및 로깅**: 실시간 학습 상태 추적
- ⚡ **확장성**: 다중 모델 동시 학습 지원

---

## 1. 쿠버네티스 클러스터 준비

### 1.1 GPU 노드 구성

```yaml
# gpu-node-pool.yaml
apiVersion: v1
kind: Node
metadata:
  name: gpu-node-1
  labels:
    node-type: gpu-training
    gpu-type: h100
    gpu-count: "8"
spec:
  capacity:
    nvidia.com/gpu: "8"
    memory: 1000Gi
    cpu: "128"
  allocatable:
    nvidia.com/gpu: "8"
    memory: 900Gi
    cpu: "120"
```

### 1.2 필수 컴포넌트 설치

```bash
# NVIDIA GPU Operator 설치
kubectl create namespace gpu-operator
helm repo add nvidia https://helm.ngc.nvidia.com/nvidia
helm install --wait gpu-operator nvidia/gpu-operator \
  --namespace gpu-operator \
  --set driver.enabled=true

# Kubeflow Training Operator 설치
kubectl apply -k "github.com/kubeflow/training-operator/manifests/overlays/standalone"

# Argo Workflows 설치
kubectl create namespace argo
kubectl apply -n argo -f https://github.com/argoproj/argo-workflows/releases/download/v3.5.0/install.yaml
```

### 1.3 스토리지 구성

```yaml
# nfs-storage.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: llm-training-data
spec:
  capacity:
    storage: 10Ti
  accessModes:
    - ReadWriteMany
  nfs:
    server: nfs-server.example.com
    path: /data/llm-training
  storageClassName: nfs-storage

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: llm-training-data-pvc
  namespace: llm-training
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 10Ti
  storageClassName: nfs-storage
```

---

## 2. 컨테이너 이미지 준비

### 2.1 베이스 이미지 구성

```dockerfile
# Dockerfile.unsloth-korean
FROM nvidia/cuda:11.8-devel-ubuntu20.04

# 기본 패키지 설치
RUN apt-get update && apt-get install -y \
    python3 python3-pip git wget curl \
    && rm -rf /var/lib/apt/lists/*

# Python 환경 설정
RUN pip3 install --upgrade pip

# Unsloth 및 의존성 설치
RUN pip3 install "unsloth[colab-new] @ git+https://github.com/unslothai/unsloth.git"
RUN pip3 install --no-deps xformers trl peft accelerate bitsandbytes
RUN pip3 install datasets transformers tokenizers sentencepiece
RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# 한국어 처리 라이브러리
RUN pip3 install konlpy kss soynlp

# 모니터링 도구
RUN pip3 install wandb tensorboard prometheus_client

# 학습 스크립트 복사
COPY scripts/ /app/scripts/
COPY configs/ /app/configs/

WORKDIR /app
CMD ["python3", "-u", "scripts/train.py"]
```

### 2.2 이미지 빌드 및 푸시

```bash
# 이미지 빌드
docker build -t your-registry/unsloth-korean:latest -f Dockerfile.unsloth-korean .

# 레지스트리에 푸시
docker push your-registry/unsloth-korean:latest
```

---

## 3. 학습 파이프라인 구성

### 3.1 CPT (지속적 사전학습) Job

```yaml
# cpt-job.yaml
apiVersion: kubeflow.org/v1
kind: PyTorchJob
metadata:
  name: korean-llm-cpt
  namespace: llm-training
spec:
  pytorchReplicaSpecs:
    Master:
      replicas: 1
      restartPolicy: OnFailure
      template:
        spec:
          containers:
          - name: pytorch
            image: your-registry/unsloth-korean:latest
            command: ["python3", "-u", "scripts/cpt_train.py"]
            env:
            - name: STAGE
              value: "CPT"
            - name: MODEL_SIZE
              value: "7B"
            - name: WANDB_PROJECT
              value: "korean-llm-cpt"
            resources:
              requests:
                nvidia.com/gpu: 4
                memory: 200Gi
                cpu: 32
              limits:
                nvidia.com/gpu: 4
                memory: 200Gi
                cpu: 32
            volumeMounts:
            - name: training-data
              mountPath: /data
            - name: model-output
              mountPath: /output
          volumes:
          - name: training-data
            persistentVolumeClaim:
              claimName: llm-training-data-pvc
          - name: model-output
            persistentVolumeClaim:
              claimName: model-output-pvc
          nodeSelector:
            node-type: gpu-training
          tolerations:
          - key: nvidia.com/gpu
            operator: Exists
            effect: NoSchedule
```

### 3.2 SFT (지도 미세조정) Job

```yaml
# sft-job.yaml
apiVersion: kubeflow.org/v1
kind: PyTorchJob
metadata:
  name: korean-llm-sft
  namespace: llm-training
spec:
  pytorchReplicaSpecs:
    Master:
      replicas: 1
      restartPolicy: OnFailure
      template:
        spec:
          containers:
          - name: pytorch
            image: your-registry/unsloth-korean:latest
            command: ["python3", "-u", "scripts/sft_train.py"]
            env:
            - name: STAGE
              value: "SFT"
            - name: BASE_MODEL_PATH
              value: "/output/cpt_model"
            - name: WANDB_PROJECT
              value: "korean-llm-sft"
            resources:
              requests:
                nvidia.com/gpu: 2
                memory: 100Gi
                cpu: 16
              limits:
                nvidia.com/gpu: 2
                memory: 100Gi
                cpu: 16
            volumeMounts:
            - name: training-data
              mountPath: /data
            - name: model-output
              mountPath: /output
          volumes:
          - name: training-data
            persistentVolumeClaim:
              claimName: llm-training-data-pvc
          - name: model-output
            persistentVolumeClaim:
              claimName: model-output-pvc
          nodeSelector:
            node-type: gpu-training
```

### 3.3 RLHF (강화학습) Job

```yaml
# rlhf-job.yaml
apiVersion: kubeflow.org/v1
kind: PyTorchJob
metadata:
  name: korean-llm-rlhf
  namespace: llm-training
spec:
  pytorchReplicaSpecs:
    Master:
      replicas: 1
      restartPolicy: OnFailure
      template:
        spec:
          containers:
          - name: pytorch
            image: your-registry/unsloth-korean:latest
            command: ["python3", "-u", "scripts/rlhf_train.py"]
            env:
            - name: STAGE
              value: "RLHF"
            - name: BASE_MODEL_PATH
              value: "/output/sft_model"
            - name: WANDB_PROJECT
              value: "korean-llm-rlhf"
            resources:
              requests:
                nvidia.com/gpu: 2
                memory: 100Gi
                cpu: 16
              limits:
                nvidia.com/gpu: 2
                memory: 100Gi
                cpu: 16
            volumeMounts:
            - name: training-data
              mountPath: /data
            - name: model-output
              mountPath: /output
          volumes:
          - name: training-data
            persistentVolumeClaim:
              claimName: llm-training-data-pvc
          - name: model-output
            persistentVolumeClaim:
              claimName: model-output-pvc
          nodeSelector:
            node-type: gpu-training
```

---

## 4. Argo Workflows 파이프라인

### 4.1 전체 학습 워크플로우

```yaml
# korean-llm-pipeline.yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: korean-llm-training-
  namespace: llm-training
spec:
  entrypoint: korean-llm-pipeline
  
  templates:
  - name: korean-llm-pipeline
    dag:
      tasks:
      - name: data-preprocessing
        template: preprocess-data
      - name: cpt-training
        template: cpt-stage
        dependencies: [data-preprocessing]
      - name: sft-training
        template: sft-stage
        dependencies: [cpt-training]
      - name: rlhf-training
        template: rlhf-stage
        dependencies: [sft-training]
      - name: model-evaluation
        template: evaluate-model
        dependencies: [rlhf-training]
      - name: model-deployment
        template: deploy-model
        dependencies: [model-evaluation]

  - name: preprocess-data
    container:
      image: your-registry/unsloth-korean:latest
      command: ["python3", "-u", "scripts/preprocess.py"]
      volumeMounts:
      - name: training-data
        mountPath: /data
      resources:
        requests:
          memory: 32Gi
          cpu: 8

  - name: cpt-stage
    resource:
      action: create
      successCondition: status.conditions.0.type == Succeeded
      failureCondition: status.conditions.0.type == Failed
      manifest: |
        apiVersion: kubeflow.org/v1
        kind: PyTorchJob
        metadata:
          generateName: cpt-job-
          namespace: llm-training
        spec:
          pytorchReplicaSpecs:
            Master:
              replicas: 1
              restartPolicy: OnFailure
              template:
                spec:
                  containers:
                  - name: pytorch
                    image: your-registry/unsloth-korean:latest
                    command: ["python3", "-u", "scripts/cpt_train.py"]
                    env:
                    - name: STAGE
                      value: "CPT"
                    resources:
                      requests:
                        nvidia.com/gpu: 4
                        memory: 200Gi
                        cpu: 32
                    volumeMounts:
                    - name: training-data
                      mountPath: /data
                    - name: model-output
                      mountPath: /output
                  volumes:
                  - name: training-data
                    persistentVolumeClaim:
                      claimName: llm-training-data-pvc
                  - name: model-output
                    persistentVolumeClaim:
                      claimName: model-output-pvc
                  nodeSelector:
                    node-type: gpu-training

  - name: sft-stage
    resource:
      action: create
      successCondition: status.conditions.0.type == Succeeded
      failureCondition: status.conditions.0.type == Failed
      manifest: |
        apiVersion: kubeflow.org/v1
        kind: PyTorchJob
        metadata:
          generateName: sft-job-
          namespace: llm-training
        spec:
          pytorchReplicaSpecs:
            Master:
              replicas: 1
              restartPolicy: OnFailure
              template:
                spec:
                  containers:
                  - name: pytorch
                    image: your-registry/unsloth-korean:latest
                    command: ["python3", "-u", "scripts/sft_train.py"]
                    env:
                    - name: STAGE
                      value: "SFT"
                    - name: BASE_MODEL_PATH
                      value: "/output/cpt_model"
                    resources:
                      requests:
                        nvidia.com/gpu: 2
                        memory: 100Gi
                        cpu: 16
                    volumeMounts:
                    - name: training-data
                      mountPath: /data
                    - name: model-output
                      mountPath: /output
                  volumes:
                  - name: training-data
                    persistentVolumeClaim:
                      claimName: llm-training-data-pvc
                  - name: model-output
                    persistentVolumeClaim:
                      claimName: model-output-pvc
                  nodeSelector:
                    node-type: gpu-training

  - name: rlhf-stage
    resource:
      action: create
      successCondition: status.conditions.0.type == Succeeded
      failureCondition: status.conditions.0.type == Failed
      manifest: |
        apiVersion: kubeflow.org/v1
        kind: PyTorchJob
        metadata:
          generateName: rlhf-job-
          namespace: llm-training
        spec:
          pytorchReplicaSpecs:
            Master:
              replicas: 1
              restartPolicy: OnFailure
              template:
                spec:
                  containers:
                  - name: pytorch
                    image: your-registry/unsloth-korean:latest
                    command: ["python3", "-u", "scripts/rlhf_train.py"]
                    env:
                    - name: STAGE
                      value: "RLHF"
                    - name: BASE_MODEL_PATH
                      value: "/output/sft_model"
                    resources:
                      requests:
                        nvidia.com/gpu: 2
                        memory: 100Gi
                        cpu: 16
                    volumeMounts:
                    - name: training-data
                      mountPath: /data
                    - name: model-output
                      mountPath: /output
                  volumes:
                  - name: training-data
                    persistentVolumeClaim:
                      claimName: llm-training-data-pvc
                  - name: model-output
                    persistentVolumeClaim:
                      claimName: model-output-pvc
                  nodeSelector:
                    node-type: gpu-training

  - name: evaluate-model
    container:
      image: your-registry/unsloth-korean:latest
      command: ["python3", "-u", "scripts/evaluate.py"]
      env:
      - name: MODEL_PATH
        value: "/output/rlhf_model"
      volumeMounts:
      - name: model-output
        mountPath: /output
      resources:
        requests:
          nvidia.com/gpu: 1
          memory: 50Gi
          cpu: 8

  - name: deploy-model
    container:
      image: your-registry/unsloth-korean:latest
      command: ["python3", "-u", "scripts/deploy.py"]
      env:
      - name: MODEL_PATH
        value: "/output/rlhf_model"
      - name: DEPLOYMENT_TARGET
        value: "production"
      volumeMounts:
      - name: model-output
        mountPath: /output

  volumeClaimTemplates:
  - metadata:
      name: training-data
    spec:
      accessModes: ["ReadWriteMany"]
      resources:
        requests:
          storage: 10Ti
      storageClassName: nfs-storage
  - metadata:
      name: model-output
    spec:
      accessModes: ["ReadWriteMany"]
      resources:
        requests:
          storage: 2Ti
      storageClassName: nfs-storage
```

---

## 5. 학습 스크립트 구성

### 5.1 CPT 학습 스크립트

```python
# scripts/cpt_train.py
import os
import torch
from unsloth import FastLanguageModel
from datasets import load_dataset
from transformers import TrainingArguments
from trl import SFTTrainer
import wandb

def main():
    # 환경 변수 설정
    stage = os.getenv("STAGE", "CPT")
    model_size = os.getenv("MODEL_SIZE", "7B")
    
    # Wandb 초기화
    wandb.init(
        project=os.getenv("WANDB_PROJECT", "korean-llm-cpt"),
        name=f"cpt-{model_size}-{wandb.util.generate_id()}"
    )
    
    # 모델 로딩
    model_name = f"unsloth/Qwen2.5-{model_size}-bnb-4bit"
    model, tokenizer = FastLanguageModel.from_pretrained(
        model_name=model_name,
        max_seq_length=131072,
        dtype=None,
        load_in_4bit=True,
    )
    
    # LoRA 설정
    model = FastLanguageModel.get_peft_model(
        model,
        r=64,
        target_modules=["q_proj", "k_proj", "v_proj", "o_proj",
                       "gate_proj", "up_proj", "down_proj"],
        lora_alpha=16,
        lora_dropout=0.1,
        bias="none",
        use_gradient_checkpointing="unsloth",
        random_state=3407,
    )
    
    # 데이터셋 로딩
    dataset = load_dataset("json", data_files="/data/korean_corpus.jsonl", split="train")
    
    def tokenize_function(examples):
        return tokenizer(
            examples["text"],
            truncation=True,
            padding=False,
            max_length=4096,
            return_overflowing_tokens=True,
        )
    
    tokenized_dataset = dataset.map(
        tokenize_function,
        batched=True,
        batch_size=1000,
        num_proc=4,
        remove_columns=dataset.column_names,
    )
    
    # 학습 설정
    training_args = TrainingArguments(
        output_dir="/output/cpt_model",
        overwrite_output_dir=True,
        num_train_epochs=2,
        per_device_train_batch_size=2,
        gradient_accumulation_steps=32,
        learning_rate=1e-5,
        weight_decay=0.01,
        logging_steps=100,
        save_steps=2000,
        save_total_limit=3,
        warmup_steps=1000,
        fp16=True,
        gradient_checkpointing=True,
        dataloader_pin_memory=False,
        remove_unused_columns=False,
        report_to="wandb",
    )
    
    # 트레이너 초기화
    trainer = SFTTrainer(
        model=model,
        tokenizer=tokenizer,
        args=training_args,
        train_dataset=tokenized_dataset,
        dataset_text_field="text",
        max_seq_length=4096,
        packing=True,
    )
    
    # 학습 실행
    trainer.train()
    
    # 모델 저장
    trainer.save_model("/output/cpt_model")
    
    # Wandb 종료
    wandb.finish()

if __name__ == "__main__":
    main()
```

### 5.2 모니터링 및 알림

```python
{% raw %}
# scripts/monitor.py
import os
import time
import requests
from kubernetes import client, config
from prometheus_client.parser import text_string_to_metric_families

class TrainingMonitor:
    def __init__(self):
        config.load_incluster_config()
        self.v1 = client.CoreV1Api()
        self.batch_v1 = client.BatchV1Api()
        
    def check_job_status(self, job_name, namespace="llm-training"):
        """Job 상태 확인"""
        try:
            job = self.batch_v1.read_namespaced_job(job_name, namespace)
            return job.status
        except Exception as e:
            print(f"Error checking job status: {e}")
            return None
    
    def get_gpu_utilization(self, pod_name, namespace="llm-training"):
        """GPU 사용률 확인"""
        try:
            # Prometheus에서 GPU 메트릭 수집
            response = requests.get(
                f"http://prometheus:9090/api/v1/query",
                params={
                    "query": f'nvidia_gpu_utilization{{pod="{pod_name}"}}'
                }
            )
            data = response.json()
            return data["data"]["result"]
        except Exception as e:
            print(f"Error getting GPU utilization: {e}")
            return None
    
    def send_slack_notification(self, message):
        """Slack 알림 전송"""
        webhook_url = os.getenv("SLACK_WEBHOOK_URL")
        if webhook_url:
            payload = {"text": message}
            requests.post(webhook_url, json=payload)
    
    def monitor_training(self):
        """학습 모니터링 메인 루프"""
        while True:
            # 현재 실행 중인 Job 확인
            jobs = self.batch_v1.list_namespaced_job("llm-training")
            
            for job in jobs.items:
                job_name = job.metadata.name
                status = job.status
                
                if status.failed:
                    message = f"🚨 Training job {job_name} failed!"
                    self.send_slack_notification(message)
                elif status.succeeded:
                    message = f"✅ Training job {job_name} completed successfully!"
                    self.send_slack_notification(message)
                
                # GPU 사용률 확인
                if status.active:
                    gpu_util = self.get_gpu_utilization(job_name)
                    if gpu_util and gpu_util[0]["value"][1] < "50":
                        message = f"⚠️ Low GPU utilization in {job_name}: {gpu_util[0]['value'][1]}%"
                        self.send_slack_notification(message)
            
            time.sleep(300)  # 5분마다 확인

if __name__ == "__main__":
    monitor = TrainingMonitor()
    monitor.monitor_training()
{% endraw %}
```

---

## 6. 모니터링 및 로깅

### 6.1 Prometheus 메트릭 수집

```yaml
# monitoring/prometheus-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: monitoring
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
    
    scrape_configs:
    - job_name: 'kubernetes-pods'
      kubernetes_sd_configs:
      - role: pod
      relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)
    
    - job_name: 'nvidia-dcgm'
      static_configs:
      - targets: ['nvidia-dcgm-exporter:9400']
```

### 6.2 Grafana 대시보드

```json
{
  "dashboard": {
    "title": "Korean LLM Training Dashboard",
    "panels": [
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
        "title": "Memory Usage",
        "type": "graph", 
        "targets": [
          {
            "expr": "nvidia_gpu_memory_used_bytes / nvidia_gpu_memory_total_bytes * 100",
            "legendFormat": "GPU Memory {{gpu}}"
          }
        ]
      },
      {
        "title": "Training Loss",
        "type": "graph",
        "targets": [
          {
            "expr": "training_loss",
            "legendFormat": "Loss"
          }
        ]
      }
    ]
  }
}
```

---

## 7. 자동 스케일링 및 리소스 관리

### 7.1 HPA (Horizontal Pod Autoscaler)

```yaml
# hpa-config.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: llm-training-hpa
  namespace: llm-training
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: llm-inference-server
  minReplicas: 1
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

### 7.2 GPU 스케줄러 설정

```yaml
# gpu-scheduler.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: gpu-scheduler-config
  namespace: kube-system
data:
  config.yaml: |
    apiVersion: kubescheduler.config.k8s.io/v1beta3
    kind: KubeSchedulerConfiguration
    profiles:
    - schedulerName: gpu-scheduler
      plugins:
        score:
          enabled:
          - name: NodeResourcesFit
          - name: NodeAffinity
        filter:
          enabled:
          - name: NodeResourcesFit
          - name: NodeAffinity
      pluginConfig:
      - name: NodeResourcesFit
        args:
          scoringStrategy:
            type: LeastAllocated
            resources:
            - name: nvidia.com/gpu
              weight: 100
```

---

## 8. 파이프라인 실행 및 관리

### 8.1 워크플로우 실행

```bash
# 네임스페이스 생성
kubectl create namespace llm-training

# 시크릿 설정 (Wandb API Key)
kubectl create secret generic wandb-secret \
  --from-literal=api-key=YOUR_WANDB_API_KEY \
  -n llm-training

# 워크플로우 실행
argo submit korean-llm-pipeline.yaml -n llm-training

# 실행 상태 확인
argo list -n llm-training
argo get korean-llm-training-xxxxx -n llm-training

# 로그 확인
argo logs korean-llm-training-xxxxx -n llm-training
```

### 8.2 파이프라인 관리 스크립트

```python
# scripts/pipeline_manager.py
import subprocess
import json
import time
from kubernetes import client, config

class PipelineManager:
    def __init__(self):
        config.load_incluster_config()
        self.custom_api = client.CustomObjectsApi()
    
    def submit_workflow(self, workflow_file, parameters=None):
        """워크플로우 제출"""
        cmd = ["argo", "submit", workflow_file, "-n", "llm-training"]
        
        if parameters:
            for key, value in parameters.items():
                cmd.extend(["-p", f"{key}={value}"])
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        return result.stdout.strip()
    
    def get_workflow_status(self, workflow_name):
        """워크플로우 상태 확인"""
        try:
            workflow = self.custom_api.get_namespaced_custom_object(
                group="argoproj.io",
                version="v1alpha1",
                namespace="llm-training",
                plural="workflows",
                name=workflow_name
            )
            return workflow["status"]["phase"]
        except Exception as e:
            print(f"Error getting workflow status: {e}")
            return None
    
    def wait_for_completion(self, workflow_name, timeout=86400):
        """워크플로우 완료 대기"""
        start_time = time.time()
        
        while time.time() - start_time < timeout:
            status = self.get_workflow_status(workflow_name)
            
            if status in ["Succeeded", "Failed", "Error"]:
                return status
            
            time.sleep(60)
        
        return "Timeout"
    
    def cleanup_completed_workflows(self, days=7):
        """완료된 워크플로우 정리"""
        cmd = [
            "argo", "delete", "-n", "llm-training",
            "--completed", f"--older={days}d"
        ]
        
        subprocess.run(cmd)

# 사용 예시
if __name__ == "__main__":
    manager = PipelineManager()
    
    # 워크플로우 실행
    workflow_name = manager.submit_workflow(
        "korean-llm-pipeline.yaml",
        parameters={
            "model-size": "7B",
            "learning-rate": "2e-5"
        }
    )
    
    print(f"Submitted workflow: {workflow_name}")
    
    # 완료 대기
    status = manager.wait_for_completion(workflow_name)
    print(f"Workflow completed with status: {status}")
    
    # 정리
    manager.cleanup_completed_workflows()
```

---

## 9. 고급 기능

### 9.1 다중 모델 동시 학습

```yaml
# multi-model-pipeline.yaml
apiVersion: argoproj.io/v1alpha1
kind: WorkflowTemplate
metadata:
  name: multi-model-training
  namespace: llm-training
spec:
  entrypoint: multi-model-pipeline
  
  templates:
  - name: multi-model-pipeline
    steps:
    - - name: train-7b-model
        template: single-model-training
        arguments:
          parameters:
          - name: model-size
            value: "7B"
          - name: gpu-count
            value: "4"
      - name: train-72b-model
        template: single-model-training
        arguments:
          parameters:
          - name: model-size
            value: "72B"
          - name: gpu-count
            value: "8"
  
  - name: single-model-training
    inputs:
      parameters:
      - name: model-size
      - name: gpu-count
    dag:
      tasks:
      - name: cpt
        template: cpt-training
        arguments:
          parameters:
          - name: model-size
            value: "{{inputs.parameters.model-size}}"
          - name: gpu-count
            value: "{{inputs.parameters.gpu-count}}"
      - name: sft
        template: sft-training
        dependencies: [cpt]
        arguments:
          parameters:
          - name: model-size
            value: "{{inputs.parameters.model-size}}"
      - name: rlhf
        template: rlhf-training
        dependencies: [sft]
        arguments:
          parameters:
          - name: model-size
            value: "{{inputs.parameters.model-size}}"
```

### 9.2 실험 추적 및 버전 관리

```python
# scripts/experiment_tracker.py
import mlflow
import wandb
from datetime import datetime

class ExperimentTracker:
    def __init__(self):
        # MLflow 설정
        mlflow.set_tracking_uri("http://mlflow-server:5000")
        mlflow.set_experiment("korean-llm-training")
        
        # Wandb 설정
        wandb.login(key=os.getenv("WANDB_API_KEY"))
    
    def start_experiment(self, config):
        """실험 시작"""
        # MLflow 실행 시작
        self.mlflow_run = mlflow.start_run(
            run_name=f"korean-llm-{datetime.now().strftime('%Y%m%d-%H%M%S')}"
        )
        
        # Wandb 실행 시작
        wandb.init(
            project="korean-llm-training",
            config=config,
            name=self.mlflow_run.info.run_name
        )
        
        # 파라미터 로깅
        mlflow.log_params(config)
    
    def log_metrics(self, metrics, step=None):
        """메트릭 로깅"""
        mlflow.log_metrics(metrics, step)
        wandb.log(metrics, step=step)
    
    def log_model(self, model_path, model_name):
        """모델 로깅"""
        mlflow.log_artifacts(model_path, model_name)
        wandb.save(f"{model_path}/*")
    
    def end_experiment(self):
        """실험 종료"""
        mlflow.end_run()
        wandb.finish()
```

---

## 결론

본 가이드를 통해 쿠버네티스 기반의 완전 자동화된 한국어 LLM 학습 파이프라인을 구축했습니다.

**주요 성과**:

- 🚀 **완전 자동화**: CPT → SFT → RLHF 순차 실행
- 📊 **실시간 모니터링**: GPU 사용률, 학습 진행도 추적
- ⚡ **효율적 리소스 관리**: 동적 스케줄링 및 자동 스케일링
- 🔄 **재현 가능성**: 버전 관리 및 실험 추적

**실무적 가치**:

- **운영 효율성**: 수동 개입 최소화로 24/7 학습 가능
- **비용 최적화**: 리소스 사용량 최적화로 클라우드 비용 절감
- **확장성**: 다중 모델 동시 학습 지원
- **안정성**: 장애 복구 및 모니터링 시스템 구축

이 시리즈의 다른 글 보기:

- [1편: Unsloth를 활용한 한국어 특화 LLM 학습 완전 가이드](#)
- 2편: Unsloth 한국어 LLM 학습 자동화 - 쿠버네티스 파이프라인 구축 (현재 글)

이러한 자동화 시스템을 통해 한국어 특화 LLM 개발의 생산성과 품질을 크게 향상시킬 수 있습니다.
