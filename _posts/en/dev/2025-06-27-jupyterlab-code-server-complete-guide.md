---
title: "Using code-server in JupyterLab 4: A Complete Development Environment Guide from MacBook to GPU Server"
excerpt: "A complete guide covering all development scenarios from running VS Code in a browser with JupyterLab 4, through Docker container setup, to GPU server environments"
seo_title: "JupyterLab 4 code-server Complete Guide - From MacBook to GPU Server - Thaki Cloud"
seo_description: "A complete guide to using VS Code in the browser via jupyter-codeserver-proxy in JupyterLab 4, Docker environment configuration, and GPU server development environments"
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
lang: en
author_profile: true
toc: true
toc_label: "Development Environment Guide"
canonical_url: "https://thakicloud.github.io/en/dev/jupyterlab-code-server-complete-guide/"
published: false
---

What if you could use VS Code right inside a web browser? With `jupyter-codeserver-proxy` in JupyterLab 4, you can launch VS Code Web with a single click. This guide covers every development scenario: local MacBook setup, Docker containers, and GPU servers.

## Why jupyter-codeserver-proxy?

**code-server** runs VS Code in server mode and serves it as a web IDE. **jupyter-codeserver-proxy** starts the code-server process inside the user's notebook server and proxies it safely under the `/codeserver/` path.

All proxying is handled by **jupyter-server-proxy**, which reuses the existing JupyterHub/JupyterLab session authentication, so no additional login is required.

### Key Benefits

- **Unified authentication**: Uses the same credentials as the JupyterLab session
- **One-click launch**: Open VS Code directly from the launcher
- **Secure proxy**: Access without exposing any additional ports
- **Wide environment support**: Works from local machines to clusters

## Differences Between JupyterLab 4 and 3

**JupyterLab 4** has moved to a "pre-built extension" system, so **there is no need to install JS extensions separately**. In JupyterLab 3 and earlier, the command `jupyter labextension install @jupyterlab/server-proxy` was still required.

This guide is written for JupyterLab 4.x. For Lab 3, additionally run `labextension install` after setup.

## Installation on macOS (Local)

### Basic Installation Steps

```bash
# Step 1: Required Python packages
pip install -U jupyter-server-proxy jupyter-codeserver-proxy

# Step 2: code-server binary
curl -fsSL https://code-server.dev/install.sh | sh

# Step 3: Install the latest JupyterLab
pip install -U jupyterlab

# Step 4: Launch JupyterLab
jupyter lab
```

### Installation via Homebrew

```bash
# Install code-server via Homebrew
brew install code-server

# The rest is the same
pip install -U jupyter-server-proxy jupyter-codeserver-proxy jupyterlab
```

### Verify the Installation

```bash
# Check extensions
jupyter server extension list | grep jupyter_server_proxy
jupyter labextension list | grep server-proxy

# Check code-server path
which code-server
```

Both lines should show **enabled / OK** for a successful installation.

## Using in a Docker Environment

### Basic Dockerfile

```dockerfile
FROM jupyter/minimal-notebook:latest

USER root

# Install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

USER $NB_UID

# Install Python packages
RUN pip install -U jupyter-server-proxy jupyter-codeserver-proxy

# Install JupyterLab extensions (optional)
RUN pip install jupyterlab-lsp 'python-lsp-server[all]'

# Set environment variables
ENV CODESERVER_ARGS="--auth none --disable-telemetry"
```

### Docker Compose Configuration

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

### Running and Accessing

```bash
# Build and start the container
docker-compose up -d

# Access in the browser
open http://localhost:8888
```

In the JupyterLab launcher, click the **code-server** icon, or navigate directly to `http://localhost:8888/codeserver/`.

## GPU Server Environment Setup

### NVIDIA GPU-Supported Dockerfile

```dockerfile
FROM nvidia/cuda:11.8-devel-ubuntu20.04

# Install base packages
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    python3 \
    python3-pip \
    git \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Set up Python environment
RUN python3 -m pip install --upgrade pip

# Install JupyterLab and extensions
RUN pip install jupyterlab \
    jupyter-server-proxy \
    jupyter-codeserver-proxy \
    torch \
    transformers \
    accelerate

# Install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Set working directory
WORKDIR /workspace

# Expose port
EXPOSE 8888

# Run command
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--NotebookApp.token=''"]
```

### GPU Server Docker Compose

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

### Deploying in a Kubernetes Environment

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

## How to Run and Use

### Launching from the Launcher

1. Go to "Launcher" tab in the upper-left of JupyterLab
2. Locate and click the new **code-server** icon
3. VS Code Web opens at the `/codeserver/` path

### Direct URL Access

```bash
# Local environment
http://localhost:8888/codeserver/

# JupyterHub environment
https://<hub>/user/<id>/codeserver/

# GPU server environment
http://<gpu-server-ip>:8888/codeserver/
```

### Installing VS Code Extensions

Extensions can also be installed in code-server:

```bash
# Install extensions from inside the container
code-server --install-extension ms-python.python
code-server --install-extension ms-toolsai.jupyter
code-server --install-extension GitHub.copilot
```

## Troubleshooting Guide

### Launcher Icon Not Visible

```bash
# Full JupyterLab restart
jupyter lab stop
jupyter lab clean
jupyter lab

# Check extension status
jupyter server extension list
jupyter labextension list
```

### 404 or Token Errors

- Check whether the trailing **slash (`/`)** is missing from the URL
- Re-login if the session cookie has expired
- Verify the `CODESERVER_ARGS` environment variable is set correctly

### Browser Opens and Immediately Closes

```bash
# Disable authentication via environment variable
export CODESERVER_ARGS="--auth none --disable-telemetry"

# Or use OpenVSCode Server
pip install jupyter-openvscodeserver-proxy
```

### GPU Out-of-Memory Error

```python
# Check GPU memory usage
import torch
print(f"GPU memory: {torch.cuda.get_device_properties(0).total_memory / 1024**3:.1f}GB")
print(f"In use: {torch.cuda.memory_allocated(0) / 1024**3:.1f}GB")

# Free memory
torch.cuda.empty_cache()
```

## Advanced Configuration and Optimization

### Performance Optimization

```bash
# code-server config file (~/.config/code-server/config.yaml)
bind-addr: 127.0.0.1:8080
auth: none
password: 
cert: false
disable-telemetry: true
disable-update-check: true

# JupyterLab config optimization
export JUPYTER_CONFIG_DIR=$HOME/.jupyter
export JUPYTER_DATA_DIR=$HOME/.local/share/jupyter
```

### Security Configuration

In JupyterHub environments, the following security settings are recommended:

```python
# jupyterhub_config.py
c.JupyterHub.tornado_settings = {
    'headers': {
        'Content-Security-Policy': "frame-ancestors 'self'"
    }
}

# Resource limits
c.KubeSpawner.cpu_limit = 4
c.KubeSpawner.mem_limit = '16G'
c.KubeSpawner.cpu_guarantee = 1
c.KubeSpawner.mem_guarantee = '4G'
```

### Custom Theme and Settings

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

## Comparing Alternative Solutions

### Compared to jupyter-lsp

If you do not need an IDE UI and only want autocomplete and go-to-definition:

```bash
pip install jupyterlab-lsp 'python-lsp-server[all]'
```

You are done when `LSP: Python (pylsp)` appears in the JupyterLab status bar.

### Compared to OpenVSCode Server

If you have concerns about licensing or extension store restrictions:

```bash
pip install jupyter-openvscodeserver-proxy
```

This uses **OpenVSCode-Server**, which is MIT-licensed.

## Real-World Use Cases

### Deep Learning Model Development

```python
# Model training on a GPU server
import torch
import torch.nn as nn
from transformers import AutoModel, AutoTokenizer

# Check GPU availability
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
print(f"Device in use: {device}")

# Load and train model
model = AutoModel.from_pretrained('bert-base-uncased').to(device)
```

### Large-Scale Data Analysis

```python
# Using Dask for distributed processing
import dask.dataframe as dd
import pandas as pd

# Process large files in chunks
df = dd.read_csv('/workspace/data/large_dataset.csv')
result = df.groupby('category').value.mean().compute()
```

## Conclusion

Thanks to JupyterLab 4's pre-built extension system, you can launch VS Code Web directly without running `labextension install`. In JupyterHub environments, all authentication is reused, making it easy to provide a full IDE to every team member.

This is especially powerful on GPU servers, where you can work with the familiar VS Code interface while efficiently utilizing hardware resources, leading to a significant productivity boost.

### Key Takeaways

- **JupyterLab 4**: No JS extension installation needed
- **Unified authentication**: Use immediately without an extra login
- **Wide environment support**: Works from local machines to GPU clusters
- **Security**: Safe access through the JupyterHub proxy

If you have concerns about licensing or extension store restrictions, consider the `jupyter-openvscodeserver-proxy` and **OpenVSCode-Server** (MIT) combination.
