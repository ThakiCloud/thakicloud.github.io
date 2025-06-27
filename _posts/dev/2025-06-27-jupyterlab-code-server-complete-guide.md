---
title: "JupyterLab 4에서 code-server 활용하기 - 맥북에서 GPU 서버까지 완전 개발 환경 가이드"
excerpt: "JupyterLab 4에서 VS Code를 브라우저로 사용하는 방법부터 도커 컨테이너, GPU 서버 환경까지 모든 개발 시나리오를 다루는 완전 가이드"
seo_title: "JupyterLab 4 code-server 완전 가이드 - 맥북부터 GPU 서버까지 - Thaki Cloud"
seo_description: "JupyterLab 4에서 jupyter-codeserver-proxy로 VS Code를 브라우저에서 사용하는 방법, 도커 환경 구성, GPU 서버 개발 환경까지 완전 정리"
date: 2025-06-27
categories: 
  - dev
  - tutorials
tags: 
  - jupyterlab
  - code-server
  - vscode
  - docker
  - gpu-server
  - 개발환경
  - jupyter-codeserver-proxy
author_profile: true
toc: true
toc_label: 개발 환경 가이드
canonical_url: "https://thakicloud.github.io/dev/jupyterlab-code-server-complete-guide/"
---

VS Code를 웹 브라우저에서 사용할 수 있다면 얼마나 편할까요? JupyterLab 4에서 `jupyter-codeserver-proxy`를 사용하면 클릭 한 번으로 VS Code Web을 띄울 수 있습니다. 이 글에서는 맥북 로컬 환경부터 도커 컨테이너, GPU 서버까지 모든 개발 시나리오를 다루겠습니다.

## 왜 jupyter-codeserver-proxy인가?

**code-server**는 VS Code를 서버 모드로 실행해 웹 브라우저에서 IDE를 제공합니다. **jupyter-codeserver-proxy**는 code-server 프로세스를 사용자의 노트북 서버 안에서 구동하고, `/codeserver/` 경로로 안전하게 프록시합니다.

모든 프록시는 **jupyter-server-proxy**가 담당하며, JupyterHub/JupyterLab 세션 인증을 그대로 재사용하므로 추가 로그인이 필요 없습니다.

### 주요 장점

- **통합된 인증**: JupyterLab 세션과 동일한 인증 사용
- **원클릭 실행**: 런처에서 바로 VS Code 실행
- **안전한 프록시**: 별도 포트 노출 없이 안전하게 접근
- **다양한 환경 지원**: 로컬부터 클러스터까지

## JupyterLab 4와 3의 차이점

**JupyterLab 4**에서는 "프리빌트(pre-built) 확장" 체계로 바뀌어 **JS 확장을 따로 설치할 필요가 없습니다**. JupyterLab 3 이하에서는 `jupyter labextension install @jupyterlab/server-proxy` 명령이 여전히 필요합니다.

이 글은 JupyterLab 4.x 기준으로 설명하며, Lab 3에서는 추가로 `labextension install`을 실행하면 됩니다.

## 맥북 로컬 환경 설치

### 기본 설치 과정

```bash
# ❶ 필수 파이썬 패키지
pip install -U jupyter-server-proxy jupyter-codeserver-proxy

# ❷ code-server 바이너리
curl -fsSL https://code-server.dev/install.sh | sh

# ❸ 최신 JupyterLab 설치
pip install -U jupyterlab

# ❹ JupyterLab 실행
jupyter lab
```

### Homebrew 사용자를 위한 설치

```bash
# code-server를 Homebrew로 설치
brew install code-server

# 나머지는 동일
pip install -U jupyter-server-proxy jupyter-codeserver-proxy jupyterlab
```

### 설치 확인

```bash
# 확장 프로그램 확인
jupyter server extension list | grep jupyter_server_proxy
jupyter labextension list | grep server-proxy

# code-server 경로 확인
which code-server
```

두 줄 모두 **enabled / OK**가 표시되면 정상입니다.

## 도커 환경에서 사용하기

### 기본 Dockerfile

```dockerfile
FROM jupyter/minimal-notebook:latest

USER root

# code-server 설치
RUN curl -fsSL https://code-server.dev/install.sh | sh

USER $NB_UID

# Python 패키지 설치
RUN pip install -U jupyter-server-proxy jupyter-codeserver-proxy

# JupyterLab 확장 설치 (선택사항)
RUN pip install jupyterlab-lsp 'python-lsp-server[all]'

# 환경변수 설정
ENV CODESERVER_ARGS="--auth none --disable-telemetry"
```

### Docker Compose 구성

```yaml
version: '3.8'
services:
  jupyterlab:
    build: .
    ports:
      - "8888:8888"
    volumes:
      - ./work:/home/jovyan/work
      - ./notebooks:/home/jovyan/notebooks
    environment:
      - JUPYTER_ENABLE_LAB=yes
      - CODESERVER_ARGS=--auth none --disable-telemetry
    command: start-notebook.sh --NotebookApp.token='' --NotebookApp.password=''
```

### 실행 및 접근

```bash
# 컨테이너 빌드 및 실행
docker-compose up -d

# 브라우저에서 접근
open http://localhost:8888
```

JupyterLab 런처에서 **code-server** 아이콘을 클릭하거나 직접 `http://localhost:8888/codeserver/`로 접근할 수 있습니다.

## GPU 서버 환경 구성

### NVIDIA GPU 지원 Dockerfile

```dockerfile
FROM nvidia/cuda:11.8-devel-ubuntu20.04

# 기본 패키지 설치
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    python3 \
    python3-pip \
    git \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Python 환경 설정
RUN python3 -m pip install --upgrade pip

# JupyterLab 및 확장 설치
RUN pip install jupyterlab \
    jupyter-server-proxy \
    jupyter-codeserver-proxy \
    torch \
    transformers \
    accelerate

# code-server 설치
RUN curl -fsSL https://code-server.dev/install.sh | sh

# 작업 디렉토리 설정
WORKDIR /workspace

# 포트 노출
EXPOSE 8888

# 실행 명령
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--NotebookApp.token=''"]
```

### GPU 서버 Docker Compose

```yaml
version: '3.8'
services:
  gpu-jupyter:
    build: .
    ports:
      - "8888:8888"
    volumes:
      - ./workspace:/workspace
      - ./models:/workspace/models
      - ./data:/workspace/data
    environment:
      - NVIDIA_VISIBLE_DEVICES=all
      - CODESERVER_ARGS=--auth none --disable-telemetry
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
```

### Kubernetes 환경에서의 배포

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jupyterlab-gpu
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jupyterlab-gpu
  template:
    metadata:
      labels:
        app: jupyterlab-gpu
    spec:
      containers:
      - name: jupyterlab
        image: your-registry/jupyterlab-gpu:latest
        ports:
        - containerPort: 8888
        resources:
          limits:
            nvidia.com/gpu: 1
            memory: "16Gi"
            cpu: "4"
          requests:
            memory: "8Gi"
            cpu: "2"
        env:
        - name: CODESERVER_ARGS
          value: "--auth none --disable-telemetry"
        volumeMounts:
        - name: workspace
          mountPath: /workspace
      volumes:
      - name: workspace
        persistentVolumeClaim:
          claimName: jupyterlab-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: jupyterlab-service
spec:
  selector:
    app: jupyterlab-gpu
  ports:
  - port: 8888
    targetPort: 8888
  type: LoadBalancer
```

## 실행 및 사용법

### 런처에서 실행

1. JupyterLab 왼쪽 상단 → "Launcher" 탭
2. 새 아이콘 **code-server** 확인 및 클릭
3. `/codeserver/` 경로로 VS Code Web이 열림

### 직접 URL 접근

```bash
# 로컬 환경
http://localhost:8888/codeserver/

# JupyterHub 환경
https://<hub>/user/<id>/codeserver/

# GPU 서버 환경
http://<gpu-server-ip>:8888/codeserver/
```

### VS Code 확장 설치

code-server에서도 VS Code 확장을 설치할 수 있습니다:

```bash
# 컨테이너 내부에서 확장 설치
code-server --install-extension ms-python.python
code-server --install-extension ms-toolsai.jupyter
code-server --install-extension GitHub.copilot
```

## 문제 해결 가이드

### 런처 아이콘이 보이지 않는 경우

```bash
# JupyterLab 완전 재시작
jupyter lab stop
jupyter lab clean
jupyter lab

# 확장 상태 확인
jupyter server extension list
jupyter labextension list
```

### 404 또는 토큰 에러

- URL 끝에 **슬래시(`/`)** 누락 여부 확인
- 세션 쿠키 만료 시 새로 로그인
- 환경변수 `CODESERVER_ARGS` 설정 확인

### 브라우저가 열리고 바로 닫히는 경우

```bash
# 환경변수로 인증 비활성화
export CODESERVER_ARGS="--auth none --disable-telemetry"

# 또는 OpenVSCode Server 사용
pip install jupyter-openvscodeserver-proxy
```

### GPU 메모리 부족 오류

```python
# GPU 메모리 사용량 확인
import torch
print(f"GPU 메모리: {torch.cuda.get_device_properties(0).total_memory / 1024**3:.1f}GB")
print(f"사용 중: {torch.cuda.memory_allocated(0) / 1024**3:.1f}GB")

# 메모리 정리
torch.cuda.empty_cache()
```

## 고급 설정 및 최적화

### 성능 최적화

```bash
# code-server 설정 파일 (~/.config/code-server/config.yaml)
bind-addr: 127.0.0.1:8080
auth: none
password: 
cert: false
disable-telemetry: true
disable-update-check: true

# JupyterLab 설정 최적화
export JUPYTER_CONFIG_DIR=$HOME/.jupyter
export JUPYTER_DATA_DIR=$HOME/.local/share/jupyter
```

### 보안 설정

JupyterHub 환경에서는 다음 보안 설정을 권장합니다:

```python
# jupyterhub_config.py
c.JupyterHub.tornado_settings = {
    'headers': {
        'Content-Security-Policy': "frame-ancestors 'self'"
    }
}

# 리소스 제한
c.KubeSpawner.cpu_limit = 4
c.KubeSpawner.mem_limit = '16G'
c.KubeSpawner.cpu_guarantee = 1
c.KubeSpawner.mem_guarantee = '4G'
```

### 사용자 정의 테마 및 설정

```json
// settings.json (code-server)
{
    "workbench.colorTheme": "Dark+ (default dark)",
    "editor.fontSize": 14,
    "editor.minimap.enabled": false,
    "python.defaultInterpreterPath": "/opt/conda/bin/python",
    "jupyter.askForKernelRestart": false
}
```

## 대안 솔루션 비교

### jupyter-lsp 비교

IDE UI가 필요 없고 자동완성과 정의 이동만 원한다면:

```bash
pip install jupyterlab-lsp 'python-lsp-server[all]'
```

JupyterLab 상태바에 `LSP: Python (pylsp)`가 보이면 완료입니다.

### OpenVSCode Server 비교

라이선스나 확장 스토어 제약이 걱정된다면:

```bash
pip install jupyter-openvscodeserver-proxy
```

MIT 라이선스의 **OpenVSCode-Server**를 사용할 수 있습니다.

## 실제 사용 사례

### 딥러닝 모델 개발

```python
# GPU 서버에서 모델 훈련
import torch
import torch.nn as nn
from transformers import AutoModel, AutoTokenizer

# GPU 사용 확인
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
print(f"사용 중인 디바이스: {device}")

# 모델 로드 및 훈련
model = AutoModel.from_pretrained('bert-base-uncased').to(device)
```

### 대용량 데이터 분석

```python
# 분산 처리를 위한 Dask 사용
import dask.dataframe as dd
import pandas as pd

# 큰 파일을 청크 단위로 처리
df = dd.read_csv('/workspace/data/large_dataset.csv')
result = df.groupby('category').value.mean().compute()
```

## 마무리

JupyterLab 4의 프리빌트 확장 덕분에 `labextension install` 없이도 VS Code Web을 곧바로 띄울 수 있습니다. JupyterHub 환경이라면 모든 인증을 재사용하므로 팀원에게도 손쉽게 IDE를 제공할 수 있습니다.

특히 GPU 서버 환경에서는 리소스를 효율적으로 활용하면서도 친숙한 VS Code 인터페이스로 개발할 수 있어 생산성이 크게 향상됩니다.

### 핵심 포인트 요약

- **JupyterLab 4**: JS 확장 설치 불필요
- **통합 인증**: 추가 로그인 없이 바로 사용
- **다양한 환경**: 로컬부터 GPU 클러스터까지
- **보안**: JupyterHub 프록시를 통한 안전한 접근

라이선스나 확장 스토어 제약이 걱정되면 `jupyter-openvscodeserver-proxy`와 **OpenVSCode-Server**(MIT) 조합을 고려해 보세요. 추가 질문이 있으면 언제든 댓글로 남겨 주세요! 