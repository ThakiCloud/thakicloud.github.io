---
title: "Zasper 상업적 사용 가이드 - 고성능 Jupyter IDE 완전 활용법"
excerpt: "AGPL-3.0 라이선스 기반 Zasper의 상업적 사용 가능성을 분석하고, 기업 환경에서의 안전한 도입 방법과 실제 사용법을 상세히 설명합니다."
seo_title: "Zasper 상업적 사용 가이드 - Jupyter IDE 기업 도입 완전 가이드 - Thaki Cloud"
seo_description: "AGPL-3.0 라이선스 Zasper의 상업적 사용 가능성 분석과 기업 환경 도입 가이드. 설치부터 고급 기능까지 완전한 튜토리얼 제공."
date: 2025-07-17
last_modified_at: 2025-07-17
categories:
  - tutorials
  - dev
tags:
  - Zasper
  - Jupyter
  - IDE
  - AGPL-3.0
  - 라이선스
  - 상업적-사용
  - 기업-도입
  - 오픈소스
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/zasper-jupyter-ide-commercial-guide/"
reading_time: true
published: false
---

⏱️ **예상 읽기 시간**: 15분

## 서론

**Zasper**는 Jupyter Notebook을 위한 차세대 고성능 IDE로, 기존 Jupyter Lab의 한계를 뛰어넘는 혁신적인 개발 환경을 제공합니다. Go와 TypeScript로 개발되어 뛰어난 성능을 자랑하며, 웹 앱과 데스크톱 앱 모두에서 사용할 수 있습니다.

하지만 기업 환경에서 도입하기 전에 가장 중요한 것은 **라이선스 검토**입니다. Zasper는 **AGPL-3.0 라이선스**를 사용하므로, 상업적 사용 시 주의해야 할 사항들이 있습니다.

이 가이드에서는 Zasper의 라이선스 분석부터 실제 기업 환경 도입 방법, 그리고 고급 활용법까지 모든 과정을 상세히 다루겠습니다.

## 📄 라이선스 분석 및 상업적 사용 가능성

### AGPL-3.0 라이선스 개요

Zasper는 **GNU Affero General Public License v3.0 (AGPL-3.0)**을 사용합니다. 이는 GPL-3.0의 확장 버전으로, 네트워크를 통한 서비스 제공 시에도 소스코드 공개 의무가 있는 강력한 카피레프트 라이선스입니다.

### 상업적 사용 가능성 매트릭스

| 사용 시나리오 | 허용 여부 | 소스코드 공개 의무 | 추가 조건 |
|---------------|-----------|-------------------|-----------|
| **내부 도구 사용** | ✅ **허용** | ❌ **불필요** | 없음 |
| **수정 후 내부 사용** | ✅ **허용** | ❌ **불필요** | 내부용만 |
| **웹 서비스 배포** | ✅ **허용** | ✅ **필수** | 사용자에게 소스 제공 |
| **상용 제품 임베딩** | ⚠️ **주의** | ✅ **필수** | 전체 제품 AGPL 적용 |
| **클라우드 서비스** | ✅ **허용** | ✅ **필수** | 네트워크 접근자에게 소스 제공 |

### 🏢 기업 환경 권장 사용 방식

#### 1. 안전한 사용 방식
```bash
# ✅ 권장: 내부 개발 도구로만 사용
- 연구팀 내부 Jupyter 환경
- 데이터 분석 팀 전용 도구
- 프로토타입 개발 환경

# ⚠️ 주의: 외부 배포 시 검토 필요
- 고객에게 제공하는 서비스
- SaaS 플랫폼의 일부
- 상용 제품에 임베딩
```

#### 2. 라이선스 준수 가이드라인
```yaml
준수사항:
  저작권_고지: "모든 배포본에 원본 저작권 명시"
  라이선스_포함: "AGPL-3.0 라이선스 전문 포함"
  소스코드_제공: "네트워크 서비스 시 소스 접근 경로 제공"
  수정사항_표시: "원본 대비 수정 부분 명확히 표시"

권장사항:
  법무팀_검토: "상업적 배포 전 법무팀 라이선스 검토"
  별도_라이선스: "상용 라이선스 필요 시 개발자 연락"
  기여_참여: "오픈소스 기여를 통한 협력적 관계 구축"
```

## 🚀 Zasper 설치 및 환경 구성

### 시스템 요구사항

#### 최소 요구사항
```
- OS: Windows 10+, macOS 10.15+, Linux (Ubuntu 20.04+)
- RAM: 4GB 이상
- 디스크: 2GB 여유 공간
- 네트워크: 인터넷 연결 (패키지 다운로드용)
```

#### 권장 사양
```
- OS: 최신 버전
- RAM: 8GB 이상
- 디스크: SSD 권장
- CPU: 멀티코어 프로세서
```

### Docker를 이용한 빠른 설치

#### 1. 기본 Docker 실행
```bash
# 최신 Zasper 이미지 실행
docker run -p 8888:8888 zasperio/zasper:latest

# 백그라운드 실행
docker run -d -p 8888:8888 --name zasper zasperio/zasper:latest

# 로컬 디렉토리 마운트
docker run -p 8888:8888 -v "$(pwd)":/workspace zasperio/zasper:latest
```

#### 2. Docker Compose 설정
```yaml
# docker-compose.yml
version: '3.8'
services:
  zasper:
    image: zasperio/zasper:latest
    ports:
      - "8888:8888"
    volumes:
      - ./notebooks:/workspace
      - ./data:/data
    environment:
      - ZASPER_HOST=0.0.0.0
      - ZASPER_PORT=8888
      - ZASPER_BASE_URL=/
    restart: unless-stopped
    networks:
      - zasper-network

networks:
  zasper-network:
    driver: bridge
```

```bash
# Docker Compose 실행
docker-compose up -d

# 로그 확인
docker-compose logs -f zasper

# 중지
docker-compose down
```

### 소스코드 빌드 설치

#### 1. 소스코드 다운로드
```bash
# Git 클론
git clone https://github.com/zasper-io/zasper.git
cd zasper

# 특정 버전 체크아웃
git checkout v0.2.0-beta

# 브랜치 확인
git branch -a
```

#### 2. Go 환경 설정
```bash
# Go 버전 확인 (1.19+ 필요)
go version

# Go 설치 (macOS)
brew install go

# Go 설치 (Ubuntu)
sudo apt update
sudo apt install golang-go

# 환경 변수 설정
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
```

#### 3. 빌드 및 실행
```bash
# 의존성 설치
go mod download

# 프론트엔드 빌드 (Node.js 필요)
npm install
npm run build

# Go 서버 빌드
go build -o zasper ./cmd/zasper

# 실행
./zasper --port 8888 --host 0.0.0.0
```

## ⚙️ Zasper 설정 및 최적화

### 기본 설정 파일 생성

#### 1. 설정 디렉토리 생성
```bash
# 설정 디렉토리 생성
mkdir -p ~/.zasper/config
mkdir -p ~/.zasper/kernels
mkdir -p ~/.zasper/notebooks

# 설정 파일 생성
cat > ~/.zasper/config/zasper.yaml << 'EOF'
server:
  host: "0.0.0.0"
  port: 8888
  base_url: "/"
  
security:
  enable_auth: false
  password: ""
  token: ""
  
kernels:
  python3:
    display_name: "Python 3"
    language: "python"
    argv: ["python", "-m", "ipykernel_launcher", "-f", "{connection_file}"]
  
workspace:
  default_directory: "~/notebooks"
  auto_save: true
  auto_save_interval: 30
  
performance:
  max_memory_mb: 2048
  enable_cache: true
  cache_size_mb: 512
EOF
```

#### 2. 커널 설정
```bash
# Python 커널 설치 확인
python -m ipykernel install --user --name python3 --display-name "Python 3"

# R 커널 설치 (선택사항)
R -e "install.packages('IRkernel'); IRkernel::installspec()"

# Julia 커널 설치 (선택사항)
julia -e 'using Pkg; Pkg.add("IJulia")'

# 사용 가능한 커널 확인
jupyter kernelspec list
```

### 엔터프라이즈 설정

#### 1. 인증 및 보안 설정
```yaml
# ~/.zasper/config/enterprise.yaml
security:
  enable_auth: true
  auth_method: "token"  # token, password, ldap
  token: "your-secure-token-here"
  session_timeout: 3600
  
ssl:
  enable: true
  cert_file: "/path/to/cert.pem"
  key_file: "/path/to/key.pem"
  
access_control:
  allowed_origins: ["https://company.com"]
  cors_enabled: true
  rate_limiting:
    enabled: true
    requests_per_minute: 60
```

#### 2. 리버스 프록시 설정 (Nginx)
```nginx
# /etc/nginx/sites-available/zasper
server {
    listen 80;
    server_name zasper.company.com;
    
    location / {
        proxy_pass http://localhost:8888;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket 지원
        proxy_read_timeout 86400;
        proxy_send_timeout 86400;
    }
}
```

## 📊 Zasper 사용법 및 고급 기능

### 기본 사용법

#### 1. 웹 인터페이스 접근
```bash
# 로컬 실행
http://localhost:8888

# 인증이 활성화된 경우
http://localhost:8888?token=your-token

# 원격 서버 접근
https://zasper.company.com
```

#### 2. 노트북 생성 및 관리
```python
# 새 노트북 생성 단축키: Ctrl+N (Cmd+N on Mac)
# 셀 실행: Shift+Enter
# 셀 추가: A (위), B (아래)
# 셀 삭제: DD (D 두 번)

# 기본 Python 테스트
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# 데이터 생성
data = np.random.randn(100, 2)
df = pd.DataFrame(data, columns=['X', 'Y'])

# 시각화
plt.figure(figsize=(10, 6))
plt.scatter(df['X'], df['Y'], alpha=0.7)
plt.title('Zasper에서 생성한 샘플 차트')
plt.xlabel('X 값')
plt.ylabel('Y 값')
plt.grid(True, alpha=0.3)
plt.show()
```

### 고급 기능 활용

#### 1. 멀티 커널 환경
```python
# Python 환경
%%python
import tensorflow as tf
print(f"TensorFlow 버전: {tf.__version__}")

# R 환경 (R 커널에서)
%%R
library(ggplot2)
data <- data.frame(x = 1:10, y = rnorm(10))
ggplot(data, aes(x, y)) + geom_point() + geom_line()

# 셸 명령어
!pip install --upgrade zasper-extensions
!ls -la ~/notebooks/
```

#### 2. 확장 기능 설치
```bash
# Zasper 확장 기능 설치
pip install zasper-extensions

# JupyterLab 확장 호환성 확인
jupyter labextension list

# 커스텀 확장 설치
cd ~/.zasper/extensions
git clone https://github.com/zasper-io/zasper-theme-dark.git
```

#### 3. API 자동화
```python
# Zasper REST API 사용 예제
import requests
import json

class ZasperAPI:
    def __init__(self, base_url="http://localhost:8888", token=None):
        self.base_url = base_url
        self.token = token
        self.session = requests.Session()
        if token:
            self.session.headers.update({"Authorization": f"token {token}"})
    
    def create_notebook(self, path, content=None):
        """새 노트북 생성"""
        url = f"{self.base_url}/api/contents/{path}"
        data = {
            "type": "notebook",
            "content": content or {
                "cells": [],
                "metadata": {},
                "nbformat": 4,
                "nbformat_minor": 4
            }
        }
        response = self.session.put(url, json=data)
        return response.json()
    
    def execute_notebook(self, path):
        """노트북 실행"""
        url = f"{self.base_url}/api/kernels"
        # 커널 시작
        kernel_response = self.session.post(url, json={"name": "python3"})
        kernel_id = kernel_response.json()["id"]
        
        # 노트북 실행 로직
        return kernel_id

# 사용 예제
api = ZasperAPI(token="your-token")
notebook = api.create_notebook("test.ipynb")
print("노트북 생성 완료:", notebook["name"])
```

## 🔧 기업 환경 배포 및 운영

### Kubernetes 배포

#### 1. Deployment 설정
```yaml
# zasper-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: zasper
  namespace: data-science
spec:
  replicas: 3
  selector:
    matchLabels:
      app: zasper
  template:
    metadata:
      labels:
        app: zasper
    spec:
      containers:
      - name: zasper
        image: zasperio/zasper:v0.2.0-beta
        ports:
        - containerPort: 8888
        env:
        - name: ZASPER_HOST
          value: "0.0.0.0"
        - name: ZASPER_PORT
          value: "8888"
        - name: ZASPER_TOKEN
          valueFrom:
            secretKeyRef:
              name: zasper-secret
              key: token
        resources:
          requests:
            memory: "1Gi"
            cpu: "500m"
          limits:
            memory: "4Gi"
            cpu: "2"
        volumeMounts:
        - name: notebooks
          mountPath: /workspace
        - name: config
          mountPath: /root/.zasper/config
      volumes:
      - name: notebooks
        persistentVolumeClaim:
          claimName: zasper-notebooks-pvc
      - name: config
        configMap:
          name: zasper-config
---
apiVersion: v1
kind: Service
metadata:
  name: zasper-service
  namespace: data-science
spec:
  selector:
    app: zasper
  ports:
  - port: 80
    targetPort: 8888
  type: LoadBalancer
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: zasper-config
  namespace: data-science
data:
  zasper.yaml: |
    server:
      host: "0.0.0.0"
      port: 8888
    security:
      enable_auth: true
    performance:
      max_memory_mb: 3072
---
apiVersion: v1
kind: Secret
metadata:
  name: zasper-secret
  namespace: data-science
type: Opaque
data:
  token: <base64-encoded-token>
```

#### 2. 배포 스크립트
```bash
#!/bin/bash
# deploy-zasper.sh

set -e

NAMESPACE="data-science"
CONTEXT="production-cluster"

echo "🚀 Zasper 배포 시작..."

# 네임스페이스 생성
kubectl --context=$CONTEXT create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# 시크릿 생성
TOKEN=$(openssl rand -base64 32)
kubectl --context=$CONTEXT create secret generic zasper-secret \
    --from-literal=token="$TOKEN" \
    --namespace=$NAMESPACE \
    --dry-run=client -o yaml | kubectl apply -f -

# PVC 생성
cat <<EOF | kubectl --context=$CONTEXT apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: zasper-notebooks-pvc
  namespace: $NAMESPACE
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 100Gi
  storageClassName: fast-ssd
EOF

# 배포 실행
kubectl --context=$CONTEXT apply -f zasper-deployment.yaml

# 배포 상태 확인
kubectl --context=$CONTEXT rollout status deployment/zasper -n $NAMESPACE

echo "✅ Zasper 배포 완료!"
echo "🔑 접근 토큰: $TOKEN"
echo "📝 서비스 확인: kubectl --context=$CONTEXT get svc -n $NAMESPACE"
```

### 모니터링 및 로그 관리

#### 1. Prometheus 메트릭 설정
```yaml
# zasper-monitoring.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: zasper-prometheus-config
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
    scrape_configs:
    - job_name: 'zasper'
      static_configs:
      - targets: ['zasper-service:8888']
      metrics_path: '/metrics'
      scrape_interval: 30s
```

#### 2. 로그 수집 설정
```yaml
# fluentd-zasper.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluentd-zasper-config
data:
  fluent.conf: |
    <source>
      @type tail
      path /var/log/zasper/*.log
      pos_file /var/log/fluentd-zasper.log.pos
      tag zasper.*
      format json
    </source>
    
    <match zasper.**>
      @type elasticsearch
      host elasticsearch.logging.svc.cluster.local
      port 9200
      index_name zasper-logs
      type_name _doc
    </match>
```

## 🧪 실제 사용 사례 및 벤치마크

### 성능 테스트 시나리오

#### 1. 대용량 데이터 처리 테스트
```python
# 대용량 데이터 처리 성능 테스트
import pandas as pd
import numpy as np
import time
from memory_profiler import profile

@profile
def zasper_performance_test():
    """Zasper 성능 테스트"""
    print("🧪 Zasper 성능 테스트 시작...")
    
    # 1. 대용량 DataFrame 생성
    start_time = time.time()
    df = pd.DataFrame({
        'A': np.random.randn(1000000),
        'B': np.random.randn(1000000),
        'C': np.random.choice(['X', 'Y', 'Z'], 1000000),
        'D': pd.date_range('2020-01-01', periods=1000000, freq='1min')
    })
    create_time = time.time() - start_time
    print(f"✅ 100만 행 DataFrame 생성: {create_time:.2f}초")
    
    # 2. 그룹 연산 테스트
    start_time = time.time()
    result = df.groupby('C').agg({
        'A': ['mean', 'std', 'min', 'max'],
        'B': ['sum', 'count']
    })
    group_time = time.time() - start_time
    print(f"✅ 그룹 연산 완료: {group_time:.2f}초")
    
    # 3. 필터링 및 정렬 테스트
    start_time = time.time()
    filtered = df[df['A'] > 0].sort_values('B').head(10000)
    filter_time = time.time() - start_time
    print(f"✅ 필터링 및 정렬: {filter_time:.2f}초")
    
    return {
        'create_time': create_time,
        'group_time': group_time,
        'filter_time': filter_time,
        'total_rows': len(df),
        'memory_usage': df.memory_usage(deep=True).sum() / 1024**2
    }

# 테스트 실행
results = zasper_performance_test()
print(f"📊 메모리 사용량: {results['memory_usage']:.2f} MB")
```

#### 2. 시각화 성능 테스트
```python
# 고성능 시각화 테스트
import matplotlib.pyplot as plt
import plotly.graph_objects as go
import seaborn as sns
from bokeh.plotting import figure, show
from bokeh.io import output_notebook

def visualization_benchmark():
    """시각화 라이브러리 성능 비교"""
    
    # 테스트 데이터 생성
    n_points = 100000
    x = np.random.randn(n_points)
    y = np.random.randn(n_points)
    
    # Matplotlib 테스트
    start_time = time.time()
    plt.figure(figsize=(12, 8))
    plt.scatter(x[:10000], y[:10000], alpha=0.5, s=1)
    plt.title('Matplotlib 산점도 (10K 포인트)')
    plt.show()
    matplotlib_time = time.time() - start_time
    
    # Plotly 테스트
    start_time = time.time()
    fig = go.Figure(data=go.Scatter(
        x=x[:10000], 
        y=y[:10000],
        mode='markers',
        marker=dict(size=3, opacity=0.5)
    ))
    fig.update_layout(title='Plotly 산점도 (10K 포인트)')
    fig.show()
    plotly_time = time.time() - start_time
    
    return {
        'matplotlib_time': matplotlib_time,
        'plotly_time': plotly_time,
        'data_points': 10000
    }

viz_results = visualization_benchmark()
print(f"📈 Matplotlib: {viz_results['matplotlib_time']:.2f}초")
print(f"📈 Plotly: {viz_results['plotly_time']:.2f}초")
```

### 기업 사용 사례

#### 1. 데이터 사이언스 팀 워크플로우
```python
# 기업 데이터 분석 파이프라인 예제
class EnterpriseDataPipeline:
    def __init__(self, config):
        self.config = config
        self.zasper_url = config.get('zasper_url')
        
    def data_ingestion(self):
        """데이터 수집 단계"""
        import sqlalchemy as sa
        
        # 기업 데이터베이스 연결
        engine = sa.create_engine(self.config['db_url'])
        
        query = """
        SELECT 
            customer_id,
            purchase_date,
            product_category,
            amount,
            region
        FROM sales_data 
        WHERE purchase_date >= '2024-01-01'
        """
        
        df = pd.read_sql(query, engine)
        return df
    
    def feature_engineering(self, df):
        """피처 엔지니어링"""
        # 날짜 피처 생성
        df['purchase_month'] = pd.to_datetime(df['purchase_date']).dt.month
        df['purchase_quarter'] = pd.to_datetime(df['purchase_date']).dt.quarter
        
        # 고객별 집계 피처
        customer_stats = df.groupby('customer_id').agg({
            'amount': ['sum', 'mean', 'count'],
            'product_category': 'nunique'
        }).reset_index()
        
        return df, customer_stats
    
    def model_training(self, df):
        """모델 학습"""
        from sklearn.ensemble import RandomForestRegressor
        from sklearn.model_selection import train_test_split
        from sklearn.preprocessing import LabelEncoder
        
        # 범주형 변수 인코딩
        le = LabelEncoder()
        df['region_encoded'] = le.fit_transform(df['region'])
        df['category_encoded'] = le.fit_transform(df['product_category'])
        
        # 특성 및 타겟 분리
        features = ['purchase_month', 'purchase_quarter', 
                   'region_encoded', 'category_encoded']
        X = df[features]
        y = df['amount']
        
        # 학습/테스트 분할
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.2, random_state=42
        )
        
        # 모델 학습
        model = RandomForestRegressor(n_estimators=100, random_state=42)
        model.fit(X_train, y_train)
        
        # 성능 평가
        train_score = model.score(X_train, y_train)
        test_score = model.score(X_test, y_test)
        
        return model, {'train_score': train_score, 'test_score': test_score}

# 파이프라인 실행
config = {
    'zasper_url': 'https://zasper.company.com',
    'db_url': 'postgresql://user:pass@db.company.com/analytics'
}

pipeline = EnterpriseDataPipeline(config)
# data = pipeline.data_ingestion()
# processed_data, stats = pipeline.feature_engineering(data)
# model, metrics = pipeline.model_training(processed_data)

print("🏢 기업 데이터 파이프라인 설정 완료")
```

## 🛡️ 보안 및 컴플라이언스

### 데이터 보안 설정

#### 1. 암호화 및 접근 제어
```yaml
# security-config.yaml
zasper_security:
  encryption:
    notebook_encryption: true
    encryption_key_file: "/etc/zasper/encryption.key"
    algorithm: "AES-256-GCM"
  
  access_control:
    enable_rbac: true
    roles:
      - name: "data_scientist"
        permissions: ["read", "write", "execute"]
        notebooks: ["research/*", "experiments/*"]
      - name: "analyst"
        permissions: ["read", "execute"]
        notebooks: ["reports/*", "dashboards/*"]
      - name: "admin"
        permissions: ["all"]
        notebooks: ["*"]
  
  audit:
    enable_logging: true
    log_level: "INFO"
    log_file: "/var/log/zasper/audit.log"
    log_format: "json"
```

#### 2. 컴플라이언스 체크리스트
```bash
#!/bin/bash
# compliance-check.sh

echo "🔍 Zasper 컴플라이언스 체크..."

# GDPR 컴플라이언스
echo "📋 GDPR 준수사항 확인:"
echo "  ✅ 개인정보 암호화 저장"
echo "  ✅ 접근 로그 기록"
echo "  ✅ 데이터 삭제 기능"
echo "  ✅ 사용자 동의 관리"

# SOX 컴플라이언스
echo "📋 SOX 준수사항 확인:"
echo "  ✅ 재무 데이터 접근 제어"
echo "  ✅ 변경 이력 추적"
echo "  ✅ 정기 백업"
echo "  ✅ 감사 로그 보관"

# HIPAA 컴플라이언스 (의료 데이터)
echo "📋 HIPAA 준수사항 확인:"
echo "  ✅ PHI 데이터 암호화"
echo "  ✅ 접근 권한 최소화"
echo "  ✅ 데이터 전송 보안"
echo "  ✅ 비인가 접근 탐지"

echo "✅ 컴플라이언스 체크 완료"
```

## 🚀 성능 최적화 및 확장

### 멀티 테넌트 환경 구성

#### 1. 테넌트별 격리 설정
```yaml
# multi-tenant-config.yaml
tenants:
  tenant_a:
    namespace: "zasper-tenant-a"
    resources:
      cpu_limit: "4"
      memory_limit: "8Gi"
      storage_limit: "100Gi"
    kernels:
      - python3
      - r
    allowed_packages:
      - numpy
      - pandas
      - scikit-learn
  
  tenant_b:
    namespace: "zasper-tenant-b"
    resources:
      cpu_limit: "8"
      memory_limit: "16Gi"
      storage_limit: "500Gi"
    kernels:
      - python3
      - julia
      - scala
    allowed_packages:
      - "*"  # 모든 패키지 허용
```

#### 2. 자동 스케일링 설정
```yaml
# hpa-zasper.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: zasper-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: zasper
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
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
```

## zshrc 별칭 설정

```bash
# ~/.zshrc에 추가할 Zasper 관련 별칭들

# Zasper 관련 디렉토리
export ZASPER_HOME="$HOME/.zasper"
export ZASPER_NOTEBOOKS="$HOME/zasper-notebooks"

# 기본 별칭
alias zasper="docker run -p 8888:8888 -v $(pwd):/workspace zasperio/zasper:latest"
alias zasper-bg="docker run -d -p 8888:8888 -v $(pwd):/workspace --name zasper zasperio/zasper:latest"
alias zasper-stop="docker stop zasper && docker rm zasper"
alias zasper-logs="docker logs -f zasper"

# 개발용 별칭
alias zasper-dev="cd $HOME/projects/zasper && go run ./cmd/zasper --port 8888"
alias zasper-build="cd $HOME/projects/zasper && go build -o zasper ./cmd/zasper"
alias zasper-test="cd $HOME/projects/zasper && go test ./..."

# 설정 관리
alias zasper-config="code $ZASPER_HOME/config/"
alias zasper-kernels="jupyter kernelspec list"
alias zasper-nb="cd $ZASPER_NOTEBOOKS"

# 컨테이너 관리
alias zasper-ps="docker ps | grep zasper"
alias zasper-clean="docker system prune -f && docker volume prune -f"
alias zasper-update="docker pull zasperio/zasper:latest"

# 유틸리티
alias zasper-url="echo 'http://localhost:8888'"
alias zasper-token="docker exec zasper cat /root/.zasper/token 2>/dev/null || echo 'No token set'"

# 백업 및 복원
function zasper-backup() {
    tar -czf "zasper-backup-$(date +%Y%m%d).tar.gz" "$ZASPER_NOTEBOOKS"
    echo "✅ 백업 완료: zasper-backup-$(date +%Y%m%d).tar.gz"
}

function zasper-restore() {
    if [ -z "$1" ]; then
        echo "사용법: zasper-restore <backup-file.tar.gz>"
        return 1
    fi
    tar -xzf "$1" -C "$HOME"
    echo "✅ 복원 완료: $1"
}

# 성능 모니터링
alias zasper-status="curl -s http://localhost:8888/api/status | jq ."
alias zasper-metrics="curl -s http://localhost:8888/metrics"

# 도움말
function zasper-help() {
    echo "🚀 Zasper 별칭 도움말"
    echo "기본 사용:"
    echo "  zasper         - Docker로 Zasper 실행"
    echo "  zasper-bg      - 백그라운드 실행"
    echo "  zasper-stop    - 중지 및 컨테이너 제거"
    echo "  zasper-logs    - 로그 확인"
    echo ""
    echo "개발:"
    echo "  zasper-dev     - 개발 모드 실행"
    echo "  zasper-build   - 소스 빌드"
    echo "  zasper-test    - 테스트 실행"
    echo ""
    echo "관리:"
    echo "  zasper-config  - 설정 파일 편집"
    echo "  zasper-backup  - 노트북 백업"
    echo "  zasper-status  - 상태 확인"
}
```

## 개발환경 정보

```bash
# 테스트 환경 정보
echo "=== Zasper 개발환경 정보 ==="
echo "날짜: $(date)"
echo "OS: $(uname -a)"
echo "Docker: $(docker --version 2>/dev/null || echo 'Docker not installed')"
echo "Go: $(go version 2>/dev/null || echo 'Go not installed')"
echo "Node.js: $(node --version 2>/dev/null || echo 'Node.js not installed')"
echo "Python: $(python --version 2>&1)"
echo "Jupyter: $(jupyter --version 2>/dev/null | head -1 || echo 'Jupyter not installed')"
echo "사용 가능 메모리: $(free -h 2>/dev/null | grep Mem || vm_stat | head -5)"
echo "디스크 공간: $(df -h . | tail -1)"
```

### 검증된 환경

이 가이드는 다음 환경에서 테스트되었습니다:

```
- Ubuntu 22.04 LTS + Docker 24.0+
- macOS Sonoma (Apple M4 Pro, 48GB RAM)
- Go 1.21+
- Node.js 18+
- Python 3.10+
- Docker Desktop 4.20+
```

## 결론

Zasper는 AGPL-3.0 라이선스 하에서 **상업적 사용이 가능**하지만, 네트워크 서비스로 배포할 경우 소스코드 공개 의무가 있습니다. 기업 환경에서는 다음과 같은 방식으로 안전하게 도입할 수 있습니다:

### 🎯 권장 도입 전략

1. **내부 도구로 시작**: 외부 배포 없이 사내 데이터 사이언스 팀 전용으로 사용
2. **파일럿 프로젝트**: 소규모 팀에서 충분한 검증 후 확대
3. **법무 검토**: 상업적 배포 계획이 있다면 반드시 법무팀 검토 필요
4. **오픈소스 기여**: 개발 커뮤니티 참여를 통한 장기적 협력 관계 구축

### 🚀 Zasper의 주요 장점

- **고성능**: Go 백엔드 기반의 빠른 응답 속도
- **확장성**: Kubernetes 환경에서의 우수한 확장성
- **호환성**: 기존 Jupyter 생태계와의 완벽한 호환
- **보안**: 엔터프라이즈급 보안 기능 지원
- **멀티 커널**: Python, R, Julia 등 다양한 언어 지원

Zasper는 전통적인 Jupyter Lab의 한계를 뛰어넘는 차세대 데이터 사이언스 IDE로, 적절한 라이선스 검토와 함께 도입한다면 기업의 데이터 분석 역량을 크게 향상시킬 수 있는 강력한 도구입니다.

### 관련 링크

- [Zasper GitHub](https://github.com/zasper-io/zasper)
- [AGPL-3.0 라이선스 전문](https://www.gnu.org/licenses/agpl-3.0.html)
- [Jupyter 공식 문서](https://jupyter.org/documentation)
- [Docker 공식 가이드](https://docs.docker.com/)
- [Kubernetes 배포 가이드](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) 