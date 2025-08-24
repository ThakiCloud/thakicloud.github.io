---
title: "OrbStack으로 MLflow 컨테이너 환경 구축하기 - Docker & Kubernetes 실험 가이드"
excerpt: "OrbStack을 활용하여 Docker와 Kubernetes 환경에서 MLflow를 설치하고 머신러닝 실험을 체계적으로 관리하는 방법을 알아봅니다."
date: 2025-06-25
categories: 
  - llmops
  - dev
tags: 
  - mlflow
  - orbstack
  - docker
  - kubernetes
  - experiment-tracking
  - containerization
  - mlops
author_profile: true
toc: true
toc_label: "목차"
---

## 개요

OrbStack은 macOS에서 Docker와 Kubernetes를 빠르고 효율적으로 실행할 수 있는 현대적인 가상화 플랫폼입니다. 기존의 Docker Desktop보다 가볍고 빠르며, 네이티브 macOS 성능을 제공합니다.

이 가이드에서는 OrbStack을 활용하여 MLflow를 컨테이너 환경에서 구축하고, Docker Compose와 Kubernetes에서 실험 추적 시스템을 운영하는 방법을 소개합니다.

## OrbStack 설치 및 설정

### 1. OrbStack 설치

```bash
# Homebrew를 통한 설치
brew install orbstack

# 또는 공식 웹사이트에서 다운로드
# https://orbstack.dev/
```

### 2. OrbStack 초기 설정

```bash
# OrbStack 실행
open -a OrbStack

# Docker 컨텍스트 확인
docker context ls

# OrbStack 컨텍스트 사용
docker context use orbstack

# Kubernetes 클러스터 활성화
orb create k8s
```

### 3. 환경 확인

```bash
# Docker 상태 확인
docker info

# Kubernetes 클러스터 확인
kubectl cluster-info

# 노드 상태 확인
kubectl get nodes
```

## Docker Compose로 MLflow 환경 구축

### 1. 프로젝트 구조 설정

```bash
# 프로젝트 디렉토리 생성
mkdir mlflow-orbstack
cd mlflow-orbstack

# 디렉토리 구조 생성
mkdir -p {docker,kubernetes,notebooks,data,models}
```

### 2. Docker Compose 파일 작성

```yaml
# docker-compose.yml
version: '3.8'

services:
  postgresql:
    image: postgres:15
    container_name: mlflow-postgres
    environment:
      POSTGRES_DB: mlflow
      POSTGRES_USER: mlflow
      POSTGRES_PASSWORD: mlflow123
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U mlflow"]
      interval: 30s
      timeout: 10s
      retries: 5

  minio:
    image: minio/minio:latest
    container_name: mlflow-minio
    environment:
      MINIO_ACCESS_KEY: minioadmin
      MINIO_SECRET_KEY: minioadmin123
    command: server /data --console-address ":9001"
    volumes:
      - minio_data:/data
    ports:
      - "9000:9000"
      - "9001:9001"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
      interval: 30s
      timeout: 20s
      retries: 3

  mlflow:
    build:
      context: ./docker
      dockerfile: Dockerfile.mlflow
    container_name: mlflow-server
    environment:
      - MLFLOW_BACKEND_STORE_URI=postgresql://mlflow:mlflow123@postgresql:5432/mlflow
      - MLFLOW_DEFAULT_ARTIFACT_ROOT=s3://mlflow-artifacts/
      - AWS_ACCESS_KEY_ID=minioadmin
      - AWS_SECRET_ACCESS_KEY=minioadmin123
      - MLFLOW_S3_ENDPOINT_URL=http://minio:9000
    ports:
      - "5000:5000"
    depends_on:
      postgresql:
        condition: service_healthy
      minio:
        condition: service_healthy
    command: >
      sh -c "
        mlflow db upgrade postgresql://mlflow:mlflow123@postgresql:5432/mlflow &&
        mlflow server 
          --backend-store-uri postgresql://mlflow:mlflow123@postgresql:5432/mlflow
          --default-artifact-root s3://mlflow-artifacts/
          --host 0.0.0.0
          --port 5000
      "

  jupyter:
    build:
      context: ./docker
      dockerfile: Dockerfile.jupyter
    container_name: mlflow-jupyter
    environment:
      - MLFLOW_TRACKING_URI=http://mlflow:5000
      - AWS_ACCESS_KEY_ID=minioadmin
      - AWS_SECRET_ACCESS_KEY=minioadmin123
      - MLFLOW_S3_ENDPOINT_URL=http://minio:9000
    volumes:
      - ./notebooks:/home/jovyan/notebooks
      - ./data:/home/jovyan/data
    ports:
      - "8888:8888"
    depends_on:
      - mlflow

volumes:
  postgres_data:
  minio_data:
```

### 3. MLflow Dockerfile 작성

```dockerfile
# docker/Dockerfile.mlflow
FROM python:3.11-slim

WORKDIR /app

# 시스템 패키지 설치
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Python 패키지 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# MLflow 설정
RUN mkdir -p /mlflow/artifacts

EXPOSE 5000

CMD ["mlflow", "server", "--host", "0.0.0.0", "--port", "5000"]
```

### 4. Jupyter Dockerfile 작성

```dockerfile
# docker/Dockerfile.jupyter
FROM jupyter/scipy-notebook:latest

USER root

# 시스템 패키지 설치
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

USER $NB_UID

# Python 패키지 설치
COPY requirements-jupyter.txt /tmp/
RUN pip install --no-cache-dir -r /tmp/requirements-jupyter.txt

# Jupyter 설정
RUN jupyter lab --generate-config

EXPOSE 8888

CMD ["start-notebook.sh", "--NotebookApp.token=''", "--NotebookApp.password=''"]
```

### 5. Requirements 파일 작성

```txt
# docker/requirements.txt
mlflow==2.8.1
psycopg2-binary==2.9.9
boto3==1.34.0
pymongo==4.6.0
scikit-learn==1.3.2
pandas==2.1.4
numpy==1.24.4
matplotlib==3.8.2
seaborn==0.13.0
plotly==5.17.0
```

```txt
# docker/requirements-jupyter.txt
mlflow==2.8.1
psycopg2-binary==2.9.9
boto3==1.34.0
scikit-learn==1.3.2
pandas==2.1.4
numpy==1.24.4
matplotlib==3.8.2
seaborn==0.13.0
plotly==5.17.0
jupyterlab==4.0.9
ipywidgets==8.1.1
```

### 6. 컨테이너 실행

```bash
# 컨테이너 빌드 및 실행
docker compose up -d

# 서비스 상태 확인
docker compose ps

# 로그 확인
docker compose logs mlflow

# MinIO 버킷 생성
docker exec mlflow-minio mc mb minio/mlflow-artifacts
```

### 7. 접속 확인

```bash
# MLflow UI 접속
open http://localhost:5000

# Jupyter Lab 접속
open http://localhost:8888

# MinIO Console 접속
open http://localhost:9001
```

## Kubernetes에서 MLflow 배포

### 1. Namespace 생성

```yaml
# kubernetes/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: mlflow
  labels:
    name: mlflow
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: mlflow-config
  namespace: mlflow
data:
  MLFLOW_BACKEND_STORE_URI: "postgresql://mlflow:mlflow123@postgresql:5432/mlflow"
  MLFLOW_DEFAULT_ARTIFACT_ROOT: "s3://mlflow-artifacts/"
  AWS_ACCESS_KEY_ID: "minioadmin"
  AWS_SECRET_ACCESS_KEY: "minioadmin123"
  MLFLOW_S3_ENDPOINT_URL: "http://minio:9000"
```

### 2. PostgreSQL 배포

```yaml
# kubernetes/postgresql.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
  namespace: mlflow
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgresql
  namespace: mlflow
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
        livenessProbe:
          exec:
            command:
            - pg_isready
            - -U
            - mlflow
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          exec:
            command:
            - pg_isready
            - -U
            - mlflow
          initialDelaySeconds: 5
          periodSeconds: 5
      volumes:
      - name: postgres-storage
        persistentVolumeClaim:
          claimName: postgres-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: postgresql
  namespace: mlflow
spec:
  selector:
    app: postgresql
  ports:
  - port: 5432
    targetPort: 5432
  type: ClusterIP
```

### 3. MinIO 배포

```yaml
# kubernetes/minio.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: minio-pvc
  namespace: mlflow
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
  name: minio
  namespace: mlflow
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
        - name: MINIO_ACCESS_KEY
          value: "minioadmin"
        - name: MINIO_SECRET_KEY
          value: "minioadmin123"
        ports:
        - containerPort: 9000
        - containerPort: 9001
        volumeMounts:
        - name: minio-storage
          mountPath: /data
        livenessProbe:
          httpGet:
            path: /minio/health/live
            port: 9000
          initialDelaySeconds: 120
          periodSeconds: 20
        readinessProbe:
          httpGet:
            path: /minio/health/ready
            port: 9000
          initialDelaySeconds: 120
          periodSeconds: 20
      volumes:
      - name: minio-storage
        persistentVolumeClaim:
          claimName: minio-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: minio
  namespace: mlflow
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

### 4. MLflow 서버 배포

```yaml
# kubernetes/mlflow.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mlflow
  namespace: mlflow
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
          mlflow server --backend-store-uri postgresql://mlflow:mlflow123@postgresql:5432/mlflow --default-artifact-root s3://mlflow-artifacts/ --host 0.0.0.0 --port 5000
        envFrom:
        - configMapRef:
            name: mlflow-config
        ports:
        - containerPort: 5000
        livenessProbe:
          httpGet:
            path: /health
            port: 5000
          initialDelaySeconds: 60
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /health
            port: 5000
          initialDelaySeconds: 30
          periodSeconds: 10
      restartPolicy: Always
---
apiVersion: v1
kind: Service
metadata:
  name: mlflow
  namespace: mlflow
spec:
  selector:
    app: mlflow
  ports:
  - port: 5000
    targetPort: 5000
  type: LoadBalancer
```

### 5. Kubernetes 배포 실행

```bash
# Namespace 및 ConfigMap 생성
kubectl apply -f kubernetes/namespace.yaml

# PostgreSQL 배포
kubectl apply -f kubernetes/postgresql.yaml

# MinIO 배포
kubectl apply -f kubernetes/minio.yaml

# MLflow 배포
kubectl apply -f kubernetes/mlflow.yaml

# 배포 상태 확인
kubectl get all -n mlflow

# 서비스 엔드포인트 확인
kubectl get svc -n mlflow

# 로그 확인
kubectl logs -f deployment/mlflow -n mlflow
```

### 6. 포트 포워딩 설정

```bash
# MLflow UI 포트 포워딩
kubectl port-forward svc/mlflow 5000:5000 -n mlflow &

# MinIO Console 포트 포워딩
kubectl port-forward svc/minio 9001:9001 -n mlflow &

# 접속 확인
open http://localhost:5000
open http://localhost:9001
```

## 실험 예제: 컨테이너 환경에서 MLflow 사용

### 1. Jupyter Notebook에서 실험 실행

```python
# notebooks/mlflow_experiment.ipynb
import mlflow
import mlflow.sklearn
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error, r2_score
import matplotlib.pyplot as plt
import os

# MLflow 설정
mlflow.set_tracking_uri("http://mlflow:5000")
mlflow.set_experiment("housing_price_container")

# 환경 변수 설정
os.environ['AWS_ACCESS_KEY_ID'] = 'minioadmin'
os.environ['AWS_SECRET_ACCESS_KEY'] = 'minioadmin123'
os.environ['MLFLOW_S3_ENDPOINT_URL'] = 'http://minio:9000'

def create_sample_data():
    """샘플 데이터 생성"""
    np.random.seed(42)
    n_samples = 1000
    
    data = {
        'area': np.random.normal(1500, 500, n_samples),
        'bedrooms': np.random.randint(1, 6, n_samples),
        'bathrooms': np.random.randint(1, 4, n_samples),
        'age': np.random.randint(0, 50, n_samples),
        'distance_to_city': np.random.normal(10, 5, n_samples)
    }
    
    df = pd.DataFrame(data)
    df['price'] = (df['area'] * 100 + 
                   df['bedrooms'] * 50000 + 
                   df['bathrooms'] * 30000 - 
                   df['age'] * 2000 - 
                   df['distance_to_city'] * 5000 + 
                   np.random.normal(0, 50000, n_samples))
    
    return df

def run_container_experiment(n_estimators, max_depth, min_samples_split):
    """컨테이너 환경에서 실험 실행"""
    
    # 데이터 생성
    df = create_sample_data()
    X = df.drop('price', axis=1)
    y = df['price']
    
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )
    
    with mlflow.start_run():
        # 환경 정보 태그
        mlflow.set_tag("environment", "container")
        mlflow.set_tag("platform", "orbstack")
        mlflow.set_tag("deployment", "docker-compose")
        
        # 하이퍼파라미터 로깅
        mlflow.log_param("n_estimators", n_estimators)
        mlflow.log_param("max_depth", max_depth)
        mlflow.log_param("min_samples_split", min_samples_split)
        
        # 모델 훈련
        model = RandomForestRegressor(
            n_estimators=n_estimators,
            max_depth=max_depth,
            min_samples_split=min_samples_split,
            random_state=42
        )
        
        model.fit(X_train, y_train)
        y_pred = model.predict(X_test)
        
        # 메트릭 계산
        mse = mean_squared_error(y_test, y_pred)
        r2 = r2_score(y_test, y_pred)
        rmse = np.sqrt(mse)
        
        # 메트릭 로깅
        mlflow.log_metric("mse", mse)
        mlflow.log_metric("r2_score", r2)
        mlflow.log_metric("rmse", rmse)
        
        # 모델 저장
        mlflow.sklearn.log_model(model, "model")
        
        # 시각화 생성
        plt.figure(figsize=(10, 6))
        plt.scatter(y_test, y_pred, alpha=0.5)
        plt.plot([y_test.min(), y_test.max()], [y_test.min(), y_test.max()], 'r--', lw=2)
        plt.xlabel('Actual Price')
        plt.ylabel('Predicted Price')
        plt.title('Container Environment - Predicted vs Actual')
        plt.savefig('/tmp/prediction_plot.png')
        mlflow.log_artifact('/tmp/prediction_plot.png')
        plt.close()
        
        print(f"Container experiment - R²: {r2:.4f}, RMSE: {rmse:.2f}")
        
        return model, r2, rmse

# 실험 실행
experiments = [
    (100, 10, 2),
    (200, 15, 5),
    (150, 12, 3)
]

for n_est, max_dep, min_split in experiments:
    run_container_experiment(n_est, max_dep, min_split)

print("모든 컨테이너 실험이 완료되었습니다!")
```

### 2. 배치 실험 스크립트

```python
# notebooks/batch_experiment.py
import mlflow
import mlflow.sklearn
import pandas as pd
import numpy as np
from sklearn.model_selection import GridSearchCV
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error, r2_score
import logging
import os

# 로깅 설정
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# MLflow 설정
mlflow.set_tracking_uri("http://mlflow:5000")
mlflow.set_experiment("batch_experiments_container")

# 환경 변수 설정
os.environ['AWS_ACCESS_KEY_ID'] = 'minioadmin'
os.environ['AWS_SECRET_ACCESS_KEY'] = 'minioadmin123'
os.environ['MLFLOW_S3_ENDPOINT_URL'] = 'http://minio:9000'

def run_batch_experiments():
    """배치 실험 실행"""
    
    # 데이터 로드
    logger.info("데이터 생성 중...")
    df = create_sample_data()
    X = df.drop('price', axis=1)
    y = df['price']
    
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )
    
    # 하이퍼파라미터 그리드
    param_grid = {
        'n_estimators': [50, 100, 200],
        'max_depth': [10, 15, 20],
        'min_samples_split': [2, 5, 10]
    }
    
    with mlflow.start_run(run_name="batch_grid_search"):
        # 환경 태그
        mlflow.set_tag("environment", "container")
        mlflow.set_tag("experiment_type", "batch")
        mlflow.set_tag("method", "grid_search")
        
        # GridSearchCV 실행
        logger.info("GridSearchCV 실행 중...")
        grid_search = GridSearchCV(
            estimator=RandomForestRegressor(random_state=42),
            param_grid=param_grid,
            cv=3,
            scoring='r2',
            n_jobs=-1,
            verbose=1
        )
        
        grid_search.fit(X_train, y_train)
        
        # 최고 성능 모델
        best_model = grid_search.best_estimator_
        y_pred = best_model.predict(X_test)
        
        # 성능 평가
        r2 = r2_score(y_test, y_pred)
        rmse = np.sqrt(mean_squared_error(y_test, y_pred))
        
        # 결과 로깅
        mlflow.log_params(grid_search.best_params_)
        mlflow.log_metric("best_r2_score", r2)
        mlflow.log_metric("best_rmse", rmse)
        mlflow.log_metric("cv_score", grid_search.best_score_)
        
        # 모델 저장
        mlflow.sklearn.log_model(best_model, "best_model")
        
        # 그리드 서치 결과 저장
        results_df = pd.DataFrame(grid_search.cv_results_)
        results_df.to_csv('/tmp/grid_search_results.csv', index=False)
        mlflow.log_artifact('/tmp/grid_search_results.csv')
        
        logger.info(f"배치 실험 완료 - 최고 R²: {r2:.4f}")
        
        return best_model, grid_search.best_params_

if __name__ == "__main__":
    run_batch_experiments()
```

## 고급 설정 및 최적화

### 1. MLflow 서버 고가용성 설정

```yaml
# kubernetes/mlflow-ha.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mlflow-ha
  namespace: mlflow
spec:
  replicas: 3
  selector:
    matchLabels:
      app: mlflow-ha
  template:
    metadata:
      labels:
        app: mlflow-ha
    spec:
      containers:
      - name: mlflow
        image: your-registry/mlflow:latest
        command:
        - sh
        - -c
        - |
          mlflow server \
            --backend-store-uri postgresql://mlflow:mlflow123@postgresql:5432/mlflow \
            --default-artifact-root s3://mlflow-artifacts/ \
            --host 0.0.0.0 \
            --port 5000 \
            --workers 4
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
        livenessProbe:
          httpGet:
            path: /health
            port: 5000
          initialDelaySeconds: 60
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /health
            port: 5000
          initialDelaySeconds: 30
          periodSeconds: 10
---
apiVersion: v1
kind: Service
metadata:
  name: mlflow-ha
  namespace: mlflow
spec:
  selector:
    app: mlflow-ha
  ports:
  - port: 5000
    targetPort: 5000
  type: LoadBalancer
  sessionAffinity: ClientIP
```

### 2. 모니터링 및 로깅 설정

```yaml
# kubernetes/monitoring.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: mlflow
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
    scrape_configs:
    - job_name: 'mlflow'
      static_configs:
      - targets: ['mlflow:5000']
      metrics_path: '/metrics'
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
  namespace: mlflow
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      containers:
      - name: prometheus
        image: prom/prometheus:latest
        ports:
        - containerPort: 9090
        volumeMounts:
        - name: config
          mountPath: /etc/prometheus
      volumes:
      - name: config
        configMap:
          name: prometheus-config
---
apiVersion: v1
kind: Service
metadata:
  name: prometheus
  namespace: mlflow
spec:
  selector:
    app: prometheus
  ports:
  - port: 9090
    targetPort: 9090
  type: LoadBalancer
```

### 3. 자동 백업 설정

```bash
#!/bin/bash
# scripts/backup.sh

# 환경 변수
BACKUP_DIR="/backups/$(date +%Y%m%d_%H%M%S)"
NAMESPACE="mlflow"

# 백업 디렉토리 생성
mkdir -p $BACKUP_DIR

# PostgreSQL 백업
echo "PostgreSQL 백업 중..."
kubectl exec -n $NAMESPACE deployment/postgresql -- pg_dump -U mlflow mlflow > $BACKUP_DIR/mlflow_db.sql

# MinIO 백업
echo "MinIO 아티팩트 백업 중..."
kubectl exec -n $NAMESPACE deployment/minio -- mc mirror /data/mlflow-artifacts /tmp/backup-artifacts
kubectl cp $NAMESPACE/minio-pod:/tmp/backup-artifacts $BACKUP_DIR/artifacts

# Kubernetes 리소스 백업
echo "Kubernetes 리소스 백업 중..."
kubectl get all -n $NAMESPACE -o yaml > $BACKUP_DIR/k8s-resources.yaml

# 백업 압축
tar -czf $BACKUP_DIR.tar.gz -C $BACKUP_DIR .
rm -rf $BACKUP_DIR

echo "백업 완료: $BACKUP_DIR.tar.gz"
```

### 4. 성능 최적화 설정

```yaml
# kubernetes/optimization.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mlflow-optimization
  namespace: mlflow
data:
  nginx.conf: |
    upstream mlflow_backend {
        least_conn;
        server mlflow:5000 max_fails=3 fail_timeout=30s;
    }
    
    server {
        listen 80;
        client_max_body_size 100M;
        
        location / {
            proxy_pass http://mlflow_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_connect_timeout 60s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
        }
        
        location /static/ {
            alias /static/;
            expires 30d;
            add_header Cache-Control "public, immutable";
        }
    }
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-proxy
  namespace: mlflow
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-proxy
  template:
    metadata:
      labels:
        app: nginx-proxy
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: config
          mountPath: /etc/nginx/conf.d
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
      volumes:
      - name: config
        configMap:
          name: mlflow-optimization
```

## 문제 해결 및 디버깅

### 1. 일반적인 문제 해결

```bash
# 컨테이너 상태 확인
docker compose ps
docker compose logs mlflow

# Kubernetes 문제 해결
kubectl get pods -n mlflow
kubectl describe pod <pod-name> -n mlflow
kubectl logs <pod-name> -n mlflow

# 네트워크 연결 테스트
kubectl exec -it <pod-name> -n mlflow -- nc -zv postgresql 5432
kubectl exec -it <pod-name> -n mlflow -- nc -zv minio 9000

# 리소스 사용량 확인
kubectl top pods -n mlflow
kubectl top nodes
```

### 2. 성능 모니터링

```python
# notebooks/performance_monitoring.py
import psutil
import time
import mlflow
import logging
from datetime import datetime

def monitor_system_performance():
    """시스템 성능 모니터링"""
    
    mlflow.set_tracking_uri("http://mlflow:5000")
    
    with mlflow.start_run(run_name=f"system_monitoring_{datetime.now().strftime('%Y%m%d_%H%M%S')}"):
        # CPU 사용률
        cpu_percent = psutil.cpu_percent(interval=1)
        mlflow.log_metric("cpu_usage_percent", cpu_percent)
        
        # 메모리 사용률
        memory = psutil.virtual_memory()
        mlflow.log_metric("memory_usage_percent", memory.percent)
        mlflow.log_metric("memory_available_gb", memory.available / (1024**3))
        
        # 디스크 사용률
        disk = psutil.disk_usage('/')
        mlflow.log_metric("disk_usage_percent", (disk.used / disk.total) * 100)
        mlflow.log_metric("disk_free_gb", disk.free / (1024**3))
        
        # 네트워크 통계
        network = psutil.net_io_counters()
        mlflow.log_metric("network_bytes_sent", network.bytes_sent)
        mlflow.log_metric("network_bytes_recv", network.bytes_recv)
        
        # 환경 정보
        mlflow.set_tag("platform", "container")
        mlflow.set_tag("monitoring_time", datetime.now().isoformat())
        
        logging.info(f"시스템 모니터링 완료 - CPU: {cpu_percent}%, Memory: {memory.percent}%")

if __name__ == "__main__":
    monitor_system_performance()
```

## 운영 가이드

### 1. 일일 운영 체크리스트

```bash
#!/bin/bash
# scripts/daily_check.sh

echo "=== MLflow 일일 운영 체크 ==="
echo "체크 시간: $(date)"

# 서비스 상태 확인
echo "1. 서비스 상태 확인"
kubectl get pods -n mlflow
kubectl get svc -n mlflow

# 디스크 사용량 확인
echo "2. 디스크 사용량 확인"
kubectl exec -n mlflow deployment/postgresql -- df -h /var/lib/postgresql/data
kubectl exec -n mlflow deployment/minio -- df -h /data

# 데이터베이스 연결 확인
echo "3. 데이터베이스 연결 확인"
kubectl exec -n mlflow deployment/postgresql -- psql -U mlflow -d mlflow -c "SELECT count(*) FROM experiments;"

# MLflow 서비스 health check
echo "4. MLflow 서비스 확인"
kubectl exec -n mlflow deployment/mlflow -- curl -f http://localhost:5000/health

# 최근 실험 확인
echo "5. 최근 실험 확인"
kubectl exec -n mlflow deployment/mlflow -- python -c "
import mlflow
mlflow.set_tracking_uri('http://localhost:5000')
runs = mlflow.search_runs(max_results=5)
print(f'최근 5개 실험: {len(runs)}개')
"

echo "=== 체크 완료 ==="
```

### 2. 정기 메인터넌스

```bash
#!/bin/bash
# scripts/maintenance.sh

echo "=== MLflow 정기 메인터넌스 ==="

# 오래된 실험 정리 (30일 이전)
echo "1. 오래된 실험 정리"
kubectl exec -n mlflow deployment/mlflow -- python -c "
import mlflow
from datetime import datetime, timedelta

mlflow.set_tracking_uri('http://localhost:5000')
cutoff_date = datetime.now() - timedelta(days=30)

experiments = mlflow.search_experiments()
for exp in experiments:
    runs = mlflow.search_runs(experiment_ids=[exp.experiment_id])
    old_runs = runs[runs['start_time'] < cutoff_date.isoformat()]
    
    for _, run in old_runs.iterrows():
        mlflow.delete_run(run['run_id'])
        print(f'삭제된 실험: {run[\"run_id\"]}')
"

# 아티팩트 정리
echo "2. 아티팩트 정리"
kubectl exec -n mlflow deployment/minio -- mc rm --recursive --force minio/mlflow-artifacts/$(date -d '30 days ago' +%Y/%m/%d)/

# 데이터베이스 VACUUM
echo "3. 데이터베이스 최적화"
kubectl exec -n mlflow deployment/postgresql -- psql -U mlflow -d mlflow -c "VACUUM ANALYZE;"

echo "=== 메인터넌스 완료 ==="
```

## 결론

OrbStack을 활용한 MLflow 컨테이너 환경은 다음과 같은 장점을 제공합니다:

- **성능**: OrbStack의 네이티브 macOS 성능으로 빠른 실행
- **확장성**: Kubernetes를 통한 수평 확장 가능
- **격리**: 컨테이너 기반 격리된 실험 환경
- **재현성**: 동일한 환경에서 실험 재현 보장
- **유연성**: Docker Compose와 Kubernetes 모두 지원

이 가이드를 통해 로컬 개발부터 프로덕션 배포까지 MLflow를 효과적으로 활용할 수 있습니다.

## 참고 자료

- [OrbStack 공식 문서](https://docs.orbstack.dev/)
- [MLflow 공식 문서](https://mlflow.org/docs/latest/index.html)
- [Docker Compose 문서](https://docs.docker.com/compose/)
- [Kubernetes 공식 문서](https://kubernetes.io/docs/)
- [MinIO 공식 문서](https://min.io/docs/minio/kubernetes/upstream/) 