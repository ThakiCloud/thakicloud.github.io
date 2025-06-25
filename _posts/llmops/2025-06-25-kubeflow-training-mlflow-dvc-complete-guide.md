---
title: "Kubeflow Training Operator로 분산 ML 학습하기 - MLflow, MinIO, DVC 통합 가이드"
excerpt: "OrbStack 환경에서 Kubeflow Training Operator와 MLflow, MinIO, DVC를 통합하여 완전한 MLOps 파이프라인을 구축하고 분산 모델 학습을 수행하는 방법을 알아봅니다."
date: 2025-06-25
categories: 
  - llmops
  - dev
tags: 
  - kubeflow
  - training-operator
  - mlflow
  - minio
  - dvc
  - distributed-training
  - mlops
  - kubernetes
  - orbstack
author_profile: true
toc: true
toc_label: "목차"
---

## 개요

현대적인 머신러닝 워크플로우는 데이터 버전 관리, 분산 학습, 실험 추적, 모델 배포까지 통합된 파이프라인을 필요로 합니다. 이 가이드에서는 OrbStack 환경에서 다음 도구들을 통합하여 완전한 MLOps 파이프라인을 구축합니다:

- **Kubeflow Training Operator**: Kubernetes 기반 분산 ML 학습
- **MLflow**: 실험 추적 및 모델 관리
- **MinIO**: S3 호환 객체 스토리지
- **DVC**: 데이터 버전 관리 및 파이프라인 관리

## 아키텍처 개요

```yaml
# 전체 시스템 아키텍처
┌─────────────────────────────────────────────────────────────┐
│                    OrbStack Kubernetes                      │
├─────────────────────────────────────────────────────────────┤
│  ┌───────────────┐  ┌──────────────┐  ┌─────────────────┐   │
│  │   MinIO       │  │   MLflow     │  │   PostgreSQL    │   │
│  │ (Artifacts &  │  │  (Tracking   │  │  (Metadata)     │   │
│  │  Data Store)  │  │   Server)    │  │                 │   │
│  └───────────────┘  └──────────────┘  └─────────────────┘   │
├─────────────────────────────────────────────────────────────┤
│  ┌───────────────┐  ┌──────────────┐  ┌─────────────────┐   │
│  │  Kubeflow     │  │    DVC       │  │   Jupyter       │   │
│  │  Training     │  │  Pipeline    │  │  Notebook       │   │
│  │  Operator     │  │  Runner      │  │                 │   │
│  └───────────────┘  └──────────────┘  └─────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## 1. 환경 준비

### 1.1. OrbStack 및 Kubernetes 설정

```bash
# OrbStack 설치 (이미 설치된 경우 생략)
brew install orbstack

# Kubernetes 클러스터 생성
orb create k8s kubeflow-cluster --cpu 4 --memory 8GB

# 컨텍스트 확인
kubectl config current-context
```

### 1.2. 필수 도구 설치

```bash
# Helm 설치
brew install helm

# Kustomize 설치
brew install kustomize

# DVC 설치
pip install dvc[s3]

# 프로젝트 디렉토리 생성
mkdir kubeflow-mlops-pipeline
cd kubeflow-mlops-pipeline
```

## 2. 기본 인프라 구축

### 2.1. Namespace 및 기본 설정

```yaml
# k8s/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: kubeflow-system
  labels:
    name: kubeflow-system
---
apiVersion: v1
kind: Namespace
metadata:
  name: mlops-pipeline
  labels:
    name: mlops-pipeline
```

### 2.2. MinIO 배포

```yaml
# k8s/minio.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: minio-pvc
  namespace: mlops-pipeline
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: minio
  namespace: mlops-pipeline
spec:
  replicas: 1
  selector:
    matchLabels:
      app: minio
  template:
    metadata:
      labels:
        app: minio
    spec:
      containers:
      - name: minio
        image: minio/minio:latest
        args:
        - server
        - /data
        - --console-address
        - ":9001"
        env:
        - name: MINIO_ROOT_USER
          value: "minioadmin"
        - name: MINIO_ROOT_PASSWORD
          value: "minioadmin123"
        ports:
        - containerPort: 9000
        - containerPort: 9001
        volumeMounts:
        - name: minio-storage
          mountPath: /data
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
      volumes:
      - name: minio-storage
        persistentVolumeClaim:
          claimName: minio-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: minio
  namespace: mlops-pipeline
spec:
  selector:
    app: minio
  ports:
  - name: api
    port: 9000
    targetPort: 9000
  - name: console
    port: 9001
    targetPort: 9001
  type: LoadBalancer
```

### 2.3. PostgreSQL 배포

```yaml
# k8s/postgresql.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
  namespace: mlops-pipeline
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgresql
  namespace: mlops-pipeline
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgresql
  template:
    metadata:
      labels:
        app: postgresql
    spec:
      containers:
      - name: postgresql
        image: postgres:15
        env:
        - name: POSTGRES_DB
          value: "mlflow"
        - name: POSTGRES_USER
          value: "mlflow"
        - name: POSTGRES_PASSWORD
          value: "mlflow123"
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
      volumes:
      - name: postgres-storage
        persistentVolumeClaim:
          claimName: postgres-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: postgresql
  namespace: mlops-pipeline
spec:
  selector:
    app: postgresql
  ports:
  - port: 5432
    targetPort: 5432
  type: ClusterIP
```

### 2.4. MLflow 서버 배포

```yaml
# k8s/mlflow.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mlflow-config
  namespace: mlops-pipeline
data:
  MLFLOW_BACKEND_STORE_URI: "postgresql://mlflow:mlflow123@postgresql:5432/mlflow"
  MLFLOW_DEFAULT_ARTIFACT_ROOT: "s3://mlflow-artifacts/"
  AWS_ACCESS_KEY_ID: "minioadmin"
  AWS_SECRET_ACCESS_KEY: "minioadmin123"
  MLFLOW_S3_ENDPOINT_URL: "http://minio:9000"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mlflow
  namespace: mlops-pipeline
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mlflow
  template:
    metadata:
      labels:
        app: mlflow
    spec:
      initContainers:
      - name: db-migration
        image: python:3.11-slim
        command:
        - sh
        - -c
        - |
          pip install mlflow psycopg2-binary &&
          mlflow db upgrade postgresql://mlflow:mlflow123@postgresql:5432/mlflow
        env:
        - name: MLFLOW_BACKEND_STORE_URI
          value: "postgresql://mlflow:mlflow123@postgresql:5432/mlflow"
      containers:
      - name: mlflow
        image: python:3.11-slim
        command:
        - sh
        - -c
        - |
          pip install mlflow psycopg2-binary boto3 &&
          mlflow server \
            --backend-store-uri postgresql://mlflow:mlflow123@postgresql:5432/mlflow \
            --default-artifact-root s3://mlflow-artifacts/ \
            --host 0.0.0.0 \
            --port 5000
        envFrom:
        - configMapRef:
            name: mlflow-config
        ports:
        - containerPort: 5000
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: mlflow
  namespace: mlops-pipeline
spec:
  selector:
    app: mlflow
  ports:
  - port: 5000
    targetPort: 5000
  type: LoadBalancer
```

## 3. Kubeflow Training Operator 설치

### 3.1. Training Operator 배포

```bash
# Training Operator 설치
kubectl apply -k "github.com/kubeflow/training-operator/manifests/overlays/standalone?ref=v1.7.0"

# 설치 확인
kubectl get pods -n kubeflow
kubectl get crd | grep kubeflow
```

### 3.2. RBAC 설정

```yaml
# k8s/rbac.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: training-operator
  namespace: mlops-pipeline
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: training-operator
rules:
- apiGroups: [""]
  resources: ["pods", "services", "endpoints", "persistentvolumeclaims", "events", "configmaps", "secrets"]
  verbs: ["*"]
- apiGroups: ["apps"]
  resources: ["deployments", "daemonsets", "replicasets", "statefulsets"]
  verbs: ["*"]
- apiGroups: ["kubeflow.org"]
  resources: ["*"]
  verbs: ["*"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: training-operator
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: training-operator
subjects:
- kind: ServiceAccount
  name: training-operator
  namespace: mlops-pipeline
```

## 4. DVC 파이프라인 설정

### 4.1. DVC 초기화 및 설정

```bash
# Git 및 DVC 초기화
git init
dvc init

# MinIO를 DVC 원격 스토리지로 설정
dvc remote add -d minio s3://dvc-data
dvc remote modify minio endpointurl http://localhost:9000
dvc remote modify minio access_key_id minioadmin
dvc remote modify minio secret_access_key minioadmin123

# .dvc/config 파일 확인
cat .dvc/config
```

### 4.2. 데이터 파이프라인 정의

```yaml
# dvc.yaml
stages:
  data_preparation:
    cmd: python src/data_preparation.py
    deps:
    - src/data_preparation.py
    - data/raw/
    outs:
    - data/processed/train.csv
    - data/processed/test.csv
    params:
    - data_preparation.test_size
    - data_preparation.random_state

  feature_engineering:
    cmd: python src/feature_engineering.py
    deps:
    - src/feature_engineering.py
    - data/processed/train.csv
    - data/processed/test.csv
    outs:
    - data/features/train_features.csv
    - data/features/test_features.csv
    params:
    - feature_engineering.n_components
    - feature_engineering.scaler_type

  model_training:
    cmd: python src/train_model.py
    deps:
    - src/train_model.py
    - data/features/train_features.csv
    outs:
    - models/model.joblib
    metrics:
    - metrics/train_metrics.json
    params:
    - model_training.algorithm
    - model_training.hyperparameters

  model_evaluation:
    cmd: python src/evaluate_model.py
    deps:
    - src/evaluate_model.py
    - models/model.joblib
    - data/features/test_features.csv
    metrics:
    - metrics/eval_metrics.json
```

### 4.3. 파라미터 설정

```yaml
# params.yaml
data_preparation:
  test_size: 0.2
  random_state: 42

feature_engineering:
  n_components: 10
  scaler_type: "standard"

model_training:
  algorithm: "random_forest"
  hyperparameters:
    n_estimators: 100
    max_depth: 10
    min_samples_split: 2
    random_state: 42
```

## 5. 컨테이너 이미지 빌드

### 5.1. 학습용 Docker 이미지

```dockerfile
# docker/Dockerfile.training
FROM python:3.11-slim

WORKDIR /app

# 시스템 패키지 설치
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Python 패키지 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 소스 코드 복사
COPY src/ ./src/
COPY params.yaml .
COPY dvc.yaml .

# DVC 설정
ENV DVC_CACHE_TYPE=symlink

CMD ["python", "-m", "src.train_distributed"]
```

### 5.2. Requirements 파일

```txt
# requirements.txt
torch==2.1.0
torchvision==0.16.0
scikit-learn==1.3.2
pandas==2.1.4
numpy==1.24.4
mlflow==2.8.1
dvc[s3]==3.26.0
boto3==1.34.0
psycopg2-binary==2.9.9
joblib==1.3.2
pyyaml==6.0.1
matplotlib==3.8.2
seaborn==0.13.0
```

### 5.3. 이미지 빌드 및 푸시

```bash
# 이미지 빌드
docker build -f docker/Dockerfile.training -t mlops-training:latest .

# OrbStack 레지스트리에 푸시 (로컬 테스트용)
# 또는 Docker Hub/ECR 등에 푸시
docker tag mlops-training:latest localhost:5000/mlops-training:latest
```

## 6. 분산 학습 구현

### 6.1. PyTorchJob 정의

```yaml
# k8s/pytorch-training-job.yaml
apiVersion: kubeflow.org/v1
kind: PyTorchJob
metadata:
  name: distributed-training
  namespace: mlops-pipeline
spec:
  pytorchReplicaSpecs:
    Master:
      replicas: 1
      restartPolicy: OnFailure
      template:
        metadata:
          annotations:
            sidecar.istio.io/inject: "false"
        spec:
          serviceAccountName: training-operator
          containers:
          - name: pytorch
            image: mlops-training:latest
            command:
            - python
            - -m
            - src.train_distributed
            args:
            - --backend=nccl
            - --epochs=50
            - --batch-size=32
            env:
            - name: MLFLOW_TRACKING_URI
              value: "http://mlflow:5000"
            - name: AWS_ACCESS_KEY_ID
              value: "minioadmin"
            - name: AWS_SECRET_ACCESS_KEY
              value: "minioadmin123"
            - name: MLFLOW_S3_ENDPOINT_URL
              value: "http://minio:9000"
            - name: DVC_REMOTE_URL
              value: "s3://dvc-data"
            - name: DVC_REMOTE_ACCESS_KEY_ID
              value: "minioadmin"
            - name: DVC_REMOTE_SECRET_ACCESS_KEY
              value: "minioadmin123"
            - name: DVC_REMOTE_ENDPOINT_URL
              value: "http://minio:9000"
            resources:
              requests:
                memory: "2Gi"
                cpu: "1"
              limits:
                memory: "4Gi"
                cpu: "2"
            volumeMounts:
            - name: dshm
              mountPath: /dev/shm
          volumes:
          - name: dshm
            emptyDir:
              medium: Memory
    Worker:
      replicas: 2
      restartPolicy: OnFailure
      template:
        metadata:
          annotations:
            sidecar.istio.io/inject: "false"
        spec:
          serviceAccountName: training-operator
          containers:
          - name: pytorch
            image: mlops-training:latest
            command:
            - python
            - -m
            - src.train_distributed
            args:
            - --backend=nccl
            - --epochs=50
            - --batch-size=32
            env:
            - name: MLFLOW_TRACKING_URI
              value: "http://mlflow:5000"
            - name: AWS_ACCESS_KEY_ID
              value: "minioadmin"
            - name: AWS_SECRET_ACCESS_KEY
              value: "minioadmin123"
            - name: MLFLOW_S3_ENDPOINT_URL
              value: "http://minio:9000"
            - name: DVC_REMOTE_URL
              value: "s3://dvc-data"
            - name: DVC_REMOTE_ACCESS_KEY_ID
              value: "minioadmin"
            - name: DVC_REMOTE_SECRET_ACCESS_KEY
              value: "minioadmin123"
            - name: DVC_REMOTE_ENDPOINT_URL
              value: "http://minio:9000"
            resources:
              requests:
                memory: "2Gi"
                cpu: "1"
              limits:
                memory: "4Gi"
                cpu: "2"
            volumeMounts:
            - name: dshm
              mountPath: /dev/shm
          volumes:
          - name: dshm
            emptyDir:
              medium: Memory
```

## 7. 분산 학습 코드 구현

### 7.1. 메인 학습 스크립트

```python
# src/train_distributed.py
import os
import argparse
import torch
import torch.nn as nn
import torch.distributed as dist
import torch.multiprocessing as mp
from torch.nn.parallel import DistributedDataParallel as DDP
from torch.utils.data.distributed import DistributedSampler
import mlflow
import mlflow.pytorch
from datetime import datetime
import json
import numpy as np
from pathlib import Path

def setup_distributed():
    """분산 학습 환경 설정"""
    # Kubeflow Training Operator 환경 변수
    rank = int(os.environ.get('RANK', 0))
    world_size = int(os.environ.get('WORLD_SIZE', 1))
    master_addr = os.environ.get('MASTER_ADDR', 'localhost')
    master_port = os.environ.get('MASTER_PORT', '12355')
    
    # 분산 초기화
    os.environ['MASTER_ADDR'] = master_addr
    os.environ['MASTER_PORT'] = master_port
    
    dist.init_process_group(
        backend='nccl' if torch.cuda.is_available() else 'gloo',
        init_method=f'tcp://{master_addr}:{master_port}',
        world_size=world_size,
        rank=rank
    )
    
    return rank, world_size

def setup_mlflow():
    """MLflow 설정"""
    mlflow.set_tracking_uri(os.environ.get('MLFLOW_TRACKING_URI', 'http://localhost:5000'))
    
    # 실험 설정
    experiment_name = f"distributed_training_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
    try:
        mlflow.create_experiment(experiment_name)
    except:
        pass
    
    mlflow.set_experiment(experiment_name)
    return experiment_name

class SimpleModel(nn.Module):
    """간단한 예제 모델"""
    def __init__(self, input_size=784, hidden_size=128, num_classes=10):
        super(SimpleModel, self).__init__()
        self.fc1 = nn.Linear(input_size, hidden_size)
        self.relu = nn.ReLU()
        self.fc2 = nn.Linear(hidden_size, num_classes)
        self.dropout = nn.Dropout(0.2)
    
    def forward(self, x):
        x = x.view(x.size(0), -1)
        x = self.fc1(x)
        x = self.relu(x)
        x = self.dropout(x)
        x = self.fc2(x)
        return x

def load_data():
    """데이터 로드 (DVC에서 관리되는 데이터)"""
    from torchvision import datasets, transforms
    
    transform = transforms.Compose([
        transforms.ToTensor(),
        transforms.Normalize((0.1307,), (0.3081,))
    ])
    
    # 실제 환경에서는 DVC로 관리되는 데이터를 로드
    train_dataset = datasets.MNIST('./data', train=True, download=True, transform=transform)
    test_dataset = datasets.MNIST('./data', train=False, transform=transform)
    
    return train_dataset, test_dataset

def train_epoch(model, train_loader, optimizer, criterion, device, rank):
    """한 에포크 학습"""
    model.train()
    total_loss = 0.0
    correct = 0
    total = 0
    
    for batch_idx, (data, target) in enumerate(train_loader):
        data, target = data.to(device), target.to(device)
        
        optimizer.zero_grad()
        output = model(data)
        loss = criterion(output, target)
        loss.backward()
        optimizer.step()
        
        total_loss += loss.item()
        _, predicted = output.max(1)
        total += target.size(0)
        correct += predicted.eq(target).sum().item()
        
        if batch_idx % 100 == 0 and rank == 0:
            print(f'Batch {batch_idx}, Loss: {loss.item():.6f}')
    
    accuracy = 100. * correct / total
    avg_loss = total_loss / len(train_loader)
    
    return avg_loss, accuracy

def validate_model(model, test_loader, criterion, device):
    """모델 검증"""
    model.eval()
    test_loss = 0
    correct = 0
    total = 0
    
    with torch.no_grad():
        for data, target in test_loader:
            data, target = data.to(device), target.to(device)
            output = model(data)
            test_loss += criterion(output, target).item()
            _, predicted = output.max(1)
            total += target.size(0)
            correct += predicted.eq(target).sum().item()
    
    accuracy = 100. * correct / total
    avg_loss = test_loss / len(test_loader)
    
    return avg_loss, accuracy

def main():
    parser = argparse.ArgumentParser(description='Distributed Training with MLflow')
    parser.add_argument('--backend', type=str, default='nccl', help='Distributed backend')
    parser.add_argument('--epochs', type=int, default=10, help='Number of epochs')
    parser.add_argument('--batch-size', type=int, default=64, help='Batch size')
    parser.add_argument('--lr', type=float, default=0.01, help='Learning rate')
    
    args = parser.parse_args()
    
    # 분산 학습 설정
    rank, world_size = setup_distributed()
    
    # 디바이스 설정
    device = torch.device(f'cuda:{rank}' if torch.cuda.is_available() else 'cpu')
    
    # MLflow 설정 (rank 0에서만)
    if rank == 0:
        experiment_name = setup_mlflow()
        mlflow_run = mlflow.start_run()
    
    try:
        # 데이터 로드
        train_dataset, test_dataset = load_data()
        
        # 분산 샘플러 설정
        train_sampler = DistributedSampler(train_dataset, num_replicas=world_size, rank=rank)
        test_sampler = DistributedSampler(test_dataset, num_replicas=world_size, rank=rank, shuffle=False)
        
        train_loader = torch.utils.data.DataLoader(
            train_dataset, batch_size=args.batch_size, sampler=train_sampler
        )
        test_loader = torch.utils.data.DataLoader(
            test_dataset, batch_size=args.batch_size, sampler=test_sampler
        )
        
        # 모델 초기화
        model = SimpleModel().to(device)
        model = DDP(model, device_ids=[rank] if torch.cuda.is_available() else None)
        
        # 옵티마이저 및 손실 함수
        optimizer = torch.optim.Adam(model.parameters(), lr=args.lr)
        criterion = nn.CrossEntropyLoss()
        
        # MLflow 로깅 (rank 0에서만)
        if rank == 0:
            mlflow.log_params({
                'epochs': args.epochs,
                'batch_size': args.batch_size,
                'learning_rate': args.lr,
                'world_size': world_size,
                'backend': args.backend
            })
            
            mlflow.set_tags({
                'model_type': 'SimpleModel',
                'training_type': 'distributed',
                'framework': 'pytorch'
            })
        
        # 학습 루프
        best_accuracy = 0.0
        metrics_history = []
        
        for epoch in range(args.epochs):
            train_sampler.set_epoch(epoch)
            
            # 학습
            train_loss, train_acc = train_epoch(
                model, train_loader, optimizer, criterion, device, rank
            )
            
            # 검증
            val_loss, val_acc = validate_model(model, test_loader, criterion, device)
            
            # 메트릭 수집 (모든 rank에서)
            metrics = {
                'epoch': epoch,
                'train_loss': train_loss,
                'train_accuracy': train_acc,
                'val_loss': val_loss,
                'val_accuracy': val_acc
            }
            metrics_history.append(metrics)
            
            # MLflow 로깅 (rank 0에서만)
            if rank == 0:
                mlflow.log_metrics({
                    'train_loss': train_loss,
                    'train_accuracy': train_acc,
                    'val_loss': val_loss,
                    'val_accuracy': val_acc
                }, step=epoch)
                
                print(f'Epoch {epoch+1}/{args.epochs}:')
                print(f'  Train Loss: {train_loss:.4f}, Train Acc: {train_acc:.2f}%')
                print(f'  Val Loss: {val_loss:.4f}, Val Acc: {val_acc:.2f}%')
                
                # 최고 성능 모델 저장
                if val_acc > best_accuracy:
                    best_accuracy = val_acc
                    
                    # 모델 저장
                    model_path = f"models/best_model_epoch_{epoch}.pth"
                    torch.save(model.module.state_dict(), model_path)
                    
                    # MLflow에 모델 로깅
                    mlflow.pytorch.log_model(
                        model.module,
                        "best_model",
                        registered_model_name="DistributedTrainingModel"
                    )
        
        # 최종 메트릭 저장 (rank 0에서만)
        if rank == 0:
            final_metrics = {
                'best_validation_accuracy': best_accuracy,
                'total_epochs': args.epochs,
                'final_train_loss': metrics_history[-1]['train_loss'],
                'final_val_loss': metrics_history[-1]['val_loss']
            }
            
            # 메트릭 파일 저장
            with open('metrics/final_metrics.json', 'w') as f:
                json.dump(final_metrics, f, indent=2)
            
            mlflow.log_artifact('metrics/final_metrics.json')
            
            print(f"\n학습 완료!")
            print(f"최고 검증 정확도: {best_accuracy:.2f}%")
    
    finally:
        if rank == 0:
            mlflow.end_run()
        
        # 분산 정리
        dist.destroy_process_group()

if __name__ == "__main__":
    main()
```

## 8. 배포 및 실행

### 8.1. 인프라 배포

```bash
# 네임스페이스 생성
kubectl apply -f k8s/namespace.yaml

# RBAC 설정
kubectl apply -f k8s/rbac.yaml

# MinIO 배포
kubectl apply -f k8s/minio.yaml

# PostgreSQL 배포
kubectl apply -f k8s/postgresql.yaml

# MLflow 배포
kubectl apply -f k8s/mlflow.yaml

# 서비스 상태 확인
kubectl get pods -n mlops-pipeline
kubectl get svc -n mlops-pipeline
```

### 8.2. MinIO 버킷 생성

```bash
# MinIO 포트 포워딩
kubectl port-forward svc/minio 9000:9000 9001:9001 -n mlops-pipeline &

# 버킷 생성 (브라우저에서 http://localhost:9001 접속)
# 또는 CLI로 생성
docker run --rm -it --network host minio/mc:latest sh -c "
  mc alias set minio http://localhost:9000 minioadmin minioadmin123 &&
  mc mb minio/mlflow-artifacts &&
  mc mb minio/dvc-data
"
```

### 8.3. 학습 작업 실행

```bash
# 분산 학습 작업 시작
kubectl apply -f k8s/pytorch-training-job.yaml

# 작업 상태 확인
kubectl get pytorchjobs -n mlops-pipeline
kubectl describe pytorchjob distributed-training -n mlops-pipeline

# 로그 확인
kubectl logs -f distributed-training-master-0 -n mlops-pipeline
```

## 결론

이 가이드를 통해 OrbStack 환경에서 Kubeflow Training Operator, MLflow, MinIO, DVC를 통합한 완전한 MLOps 파이프라인을 구축했습니다. 이 시스템은 다음과 같은 기능을 제공합니다:

- **분산 학습**: Kubeflow Training Operator를 통한 확장 가능한 분산 학습
- **실험 추적**: MLflow를 통한 체계적인 실험 관리
- **데이터 버전 관리**: DVC를 통한 데이터 및 모델 버전 관리
- **아티팩트 저장**: MinIO를 통한 확장 가능한 객체 스토리지

이러한 통합된 파이프라인을 통해 개발부터 프로덕션까지 일관된 MLOps 워크플로우를 구현할 수 있습니다.

## 참고 자료

- [Kubeflow Training Operator](https://www.kubeflow.org/docs/components/training/)
- [MLflow 공식 문서](https://mlflow.org/docs/latest/index.html)
- [DVC 공식 문서](https://dvc.org/doc)
- [MinIO Kubernetes 가이드](https://min.io/docs/minio/kubernetes/upstream/)
- [PyTorch 분산 학습](https://pytorch.org/tutorials/intermediate/ddp_tutorial.html) 