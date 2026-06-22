---
layout: single
title: "استخدام code-server في JupyterLab 4: الدليل الشامل لبيئة التطوير من MacBook إلى خوادم GPU"
excerpt: "دليل شامل يغطي جميع سيناريوهات التطوير من استخدام VS Code في المتصفح عبر JupyterLab 4 إلى حاويات Docker وبيئات خوادم GPU"
seo_title: "الدليل الشامل لـ JupyterLab 4 وcode-server - من MacBook إلى خوادم GPU - Thaki Cloud"
seo_description: "كيفية استخدام VS Code في المتصفح عبر jupyter-codeserver-proxy في JupyterLab 4، وإعداد بيئة Docker، وبيئات تطوير خوادم GPU"
date: 2025-06-27
categories: [dev, tutorials]
tags: [jupyterlab, code-server, vscode, docker, gpu-server, 개발환경, jupyter-codeserver-proxy]
lang: ar
canonical_url: "https://thakicloud.github.io/ar/dev/jupyterlab-code-server-complete-guide/"
toc: true
toc_sticky: true
toc_label: "دليل بيئة التطوير"
published: false
---

هل تريد استخدام VS Code في المتصفح من خلال JupyterLab 4؟ يُتيح لك امتداد `jupyter-codeserver-proxy` تشغيل VS Code كاملًا (عبر code-server) مباشرةً داخل بيئة JupyterLab، مما يوفر تجربة تطوير موحدة عبر المتصفح دون الحاجة إلى تثبيت برامج إضافية محليًا.

---

## لماذا jupyter-codeserver-proxy؟

يُقدّم هذا الامتداد مزايا جوهرية:

**المصادقة الموحدة**: يعمل من خلال نظام مصادقة JupyterLab، لذا لا حاجة لإعداد مصادقة منفصلة.

**التشغيل بنقرة واحدة**: يظهر code-server كخيار في قائمة مشغّل JupyterLab.

**وكيل آمن**: يمر الاتصال عبر خادم Jupyter بدلًا من فتح منافذ إضافية.

**دعم بيئات متعددة**: يعمل بشكل مثالي على الجهاز المحلي وDocker وخوادم GPU وKubernetes.

---

## الفرق بين JupyterLab 4 وJupyterLab 3

| الجانب | JupyterLab 3 | JupyterLab 4 |
|--------|--------------|--------------|
| نظام الامتدادات | تثبيت npm مطلوب | امتدادات مُجمَّعة مسبقًا |
| `jupyter-codeserver-proxy` | يحتاج بناء من المصدر | يعمل فور التثبيت عبر pip |
| الأداء | أبطأ | أسرع بشكل ملحوظ |
| واجهة المستخدم | كلاسيكية | محسّنة وعصرية |

JupyterLab 4 يُبسّط التثبيت بشكل كبير.

---

## التثبيت المحلي على macOS

### المتطلبات الأساسية

```bash
# Python 3.9 أو أحدث
python3 --version

# Node.js (لـ code-server)
node --version
```

### التثبيت عبر pip

```bash
# إنشاء بيئة افتراضية (موصى به)
python3 -m venv venv-jupyterlab
source venv-jupyterlab/bin/activate

# تثبيت JupyterLab 4
pip install "jupyterlab>=4.0"

# تثبيت jupyter-codeserver-proxy
pip install jupyter-codeserver-proxy

# تثبيت jupyter-server-proxy (مطلوب)
pip install jupyter-server-proxy
```

### التثبيت عبر Homebrew (على macOS)

```bash
# تثبيت code-server عبر Homebrew
brew install code-server

# التحقق من التثبيت
code-server --version

# تثبيت حزم Python
pip install jupyterlab jupyter-codeserver-proxy jupyter-server-proxy
```

### التحقق من التثبيت

```bash
# تشغيل JupyterLab
jupyter lab

# التحقق من قائمة الامتدادات المثبتة
jupyter labextension list

# يجب أن تجد:
# jupyter-codeserver-proxy v1.x.x enabled OK
```

---

## بيئة Docker

### Dockerfile الأساسي

```dockerfile
# Dockerfile
# JupyterLab 4 مع code-server

FROM python:3.11-slim

# تثبيت التبعيات الأساسية
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# تثبيت code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# إنشاء مستخدم غير root للأمان
RUN useradd -m -s /bin/bash jupyter
USER jupyter
WORKDIR /home/jupyter

# تثبيت حزم Python
RUN pip install --no-cache-dir \
    "jupyterlab>=4.0" \
    jupyter-server-proxy \
    jupyter-codeserver-proxy \
    numpy \
    pandas \
    matplotlib \
    scikit-learn

# إعداد JupyterLab
RUN jupyter lab build

# نسخ ملف الإعداد
COPY --chown=jupyter:jupyter jupyter_server_config.py /home/jupyter/.jupyter/

EXPOSE 8888

CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser"]
```

### ملف إعداد Jupyter

```python
# jupyter_server_config.py
# إعداد خادم Jupyter

c.ServerApp.ip = '0.0.0.0'
c.ServerApp.port = 8888
c.ServerApp.open_browser = False

# تعطيل المصادقة للاستخدام المحلي (غيّر هذا في الإنتاج)
c.ServerApp.token = ''
c.ServerApp.password = ''

# السماح بالاتصال من أي مصدر (للاستخدام مع Docker)
c.ServerApp.allow_origin = '*'
```

### Docker Compose

```yaml
# docker-compose.yml
# بيئة JupyterLab مع code-server

version: '3.8'

services:
  jupyterlab:
    build: .
    container_name: jupyterlab-codeserver
    ports:
      - "8888:8888"
    volumes:
      # مجلد العمل الدائم
      - ./workspace:/home/jupyter/workspace
      # إعدادات VS Code
      - ~/.config/Code:/home/jupyter/.config/Code:ro
      # امتدادات code-server
      - code-server-extensions:/home/jupyter/.local/share/code-server
    environment:
      - JUPYTER_TOKEN=my-secure-token
    restart: unless-stopped

volumes:
  code-server-extensions:
```

### تشغيل Docker

```bash
# بناء وتشغيل الحاوية
docker-compose up -d

# عرض السجلات
docker-compose logs -f jupyterlab

# الوصول إلى JupyterLab
# افتح المتصفح على: http://localhost:8888
```

---

## بيئة خادم GPU

### Dockerfile مع NVIDIA CUDA

```dockerfile
# Dockerfile.gpu
# JupyterLab مع دعم CUDA و code-server

FROM nvidia/cuda:12.1.0-devel-ubuntu22.04

# تجنب التفاعل في التثبيت
ENV DEBIAN_FRONTEND=noninteractive

# تثبيت التبعيات الأساسية
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3.11-pip \
    python3.11-venv \
    curl \
    wget \
    git \
    nodejs \
    npm \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# إنشاء رابط python3
RUN ln -s /usr/bin/python3.11 /usr/bin/python3
RUN ln -s /usr/bin/pip3 /usr/bin/pip

# تثبيت code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# تثبيت حزم Python للتعلم الآلي
RUN pip install --no-cache-dir \
    "jupyterlab>=4.0" \
    jupyter-server-proxy \
    jupyter-codeserver-proxy \
    torch torchvision torchaudio \
    tensorflow \
    numpy pandas matplotlib seaborn \
    scikit-learn xgboost \
    transformers datasets \
    accelerate

# إنشاء مستخدم
RUN useradd -m jupyter
USER jupyter
WORKDIR /home/jupyter

EXPOSE 8888

CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]
```

### Docker Compose لخادم GPU

```yaml
# docker-compose.gpu.yml
# إعداد Docker Compose لبيئة GPU

version: '3.8'

services:
  jupyterlab-gpu:
    build:
      context: .
      dockerfile: Dockerfile.gpu
    container_name: jupyterlab-gpu
    ports:
      - "8888:8888"
    volumes:
      - ./workspace:/home/jupyter/workspace
      - ./data:/home/jupyter/data
      - model-cache:/home/jupyter/.cache
    environment:
      - JUPYTER_TOKEN=${JUPYTER_TOKEN:-secure-gpu-token}
      - NVIDIA_VISIBLE_DEVICES=all
      - CUDA_VISIBLE_DEVICES=0,1
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
    restart: unless-stopped

volumes:
  model-cache:
```

### نشر على Kubernetes

```yaml
# k8s-jupyterlab-gpu.yaml
# نشر JupyterLab على Kubernetes مع GPU

apiVersion: apps/v1
kind: Deployment
metadata:
  name: jupyterlab-gpu
  namespace: ml-workloads
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
          env:
            - name: JUPYTER_TOKEN
              valueFrom:
                secretKeyRef:
                  name: jupyter-secret
                  key: token
          resources:
            requests:
              memory: "8Gi"
              cpu: "2"
              nvidia.com/gpu: 1
            limits:
              memory: "32Gi"
              cpu: "8"
              nvidia.com/gpu: 1
          volumeMounts:
            - name: workspace
              mountPath: /home/jupyter/workspace
      volumes:
        - name: workspace
          persistentVolumeClaim:
            claimName: jupyter-workspace-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: jupyterlab-service
  namespace: ml-workloads
spec:
  selector:
    app: jupyterlab-gpu
  ports:
    - port: 8888
      targetPort: 8888
  type: ClusterIP
```

---

## التشغيل والاستخدام

### الوصول إلى code-server من JupyterLab

1. افتح JupyterLab في المتصفح (`http://localhost:8888`)
2. في لوحة المشغّل (Launcher)، ستجد قسمًا جديدًا
3. انقر على "VS Code" أو "Code Server"
4. سيفتح VS Code كاملًا في نافذة جانبية أو علامة تبويب جديدة

### الوصول عبر URL مباشر

```
# عنوان code-server مباشرةً
http://localhost:8888/codeserver/

# أو مع توكن المصادقة
http://localhost:8888/codeserver/?token=your-token
```

### تثبيت امتدادات VS Code

```bash
# داخل code-server، يمكنك تثبيت الامتدادات كالمعتاد
# من واجهة VS Code أو عبر سطر الأوامر:

code-server --install-extension ms-python.python
code-server --install-extension ms-python.vscode-pylance
code-server --install-extension github.copilot
code-server --install-extension eamodio.gitlens
```

---

## استكشاف الأخطاء وإصلاحها

### المشكلة 1: أيقونة code-server لا تظهر في المشغّل

```bash
# التحقق من تثبيت الامتداد
pip show jupyter-codeserver-proxy

# إعادة تثبيت مع التبعيات
pip uninstall jupyter-codeserver-proxy jupyter-server-proxy
pip install jupyter-server-proxy jupyter-codeserver-proxy

# إعادة بناء JupyterLab
jupyter lab build

# إعادة تشغيل JupyterLab
```

### المشكلة 2: خطأ 404 أو مشاكل التوكن

```bash
# التحقق من الإعدادات
jupyter server --show-config

# التحقق من صحة إعداد الوكيل
jupyter serverextension list

# مشاهدة السجلات لتشخيص المشكلة
jupyter lab --log-level=DEBUG 2>&1 | grep -i "code-server\|proxy"
```

### المشكلة 3: إغلاق المتصفح يقطع الجلسة

```bash
# استخدام tmux أو screen للجلسات الدائمة
tmux new-session -d -s jupyter 'jupyter lab'

# أو استخدام nohup
nohup jupyter lab &> jupyter.log &

# عرض معرف العملية
echo $! > jupyter.pid
```

### المشكلة 4: مشاكل ذاكرة GPU

```python
# داخل دفتر Jupyter للتحقق من حالة GPU
import torch

# التحقق من توفر GPU
print(f"GPU متاحة: {torch.cuda.is_available()}")
print(f"عدد GPU: {torch.cuda.device_count()}")

# مسح ذاكرة GPU
torch.cuda.empty_cache()

# مراقبة الذاكرة
for i in range(torch.cuda.device_count()):
    mem = torch.cuda.memory_stats(i)
    print(f"GPU {i}: ذاكرة محجوزة = {mem.get('reserved_bytes.all.current', 0) / 1e9:.2f} GB")
```

---

## الإعدادات المتقدمة

### تحسين الأداء

```python
# jupyter_server_config.py - إعدادات الأداء المتقدمة

# زيادة حجم الرسائل المسموح بها
c.ServerApp.max_buffer_size = 10 * 1024 * 1024 * 1024  # 10 GB

# ضبط المهلة الزمنية للاتصال
c.ServerApp.websocket_max_message_size = 10 * 1024 * 1024  # 10 MB

# إعداد وكيل الخادم لـ code-server
c.ServerProxy.servers = {
    'codeserver': {
        'command': ['code-server', '--auth', 'none', '--port', '{port}'],
        'timeout': 30,
        'launcher_entry': {
            'enabled': True,
            'title': 'VS Code',
            'icon_path': '/path/to/vscode-icon.svg'
        }
    }
}
```

### إعدادات الأمان للإنتاج

```python
# jupyter_server_config.py - إعدادات الأمان

import secrets

# توليد توكن آمن
c.ServerApp.token = secrets.token_hex(32)

# تفعيل HTTPS
c.ServerApp.certfile = '/path/to/ssl/cert.pem'
c.ServerApp.keyfile = '/path/to/ssl/key.pem'

# تقييد عناوين IP المسموح بها
c.ServerApp.ip = '0.0.0.0'  # أو عنوان IP محدد

# إضافة كلمة مرور
from jupyter_server.auth import passwd
c.ServerApp.password = passwd('your-secure-password')
```

---

## الحلول البديلة: مقارنة

| الحل | المزايا | العيوب |
|------|---------|--------|
| `jupyter-codeserver-proxy` | تكامل مثالي مع JupyterLab | يحتاج code-server مثبتًا |
| `jupyter-lsp` | خوادم لغة مدمجة | لا يُوفر VS Code كاملًا |
| `OpenVSCode Server` | vs code رسمي من Microsoft | لا يتكامل مع JupyterLab |
| VS Code محلي + Remote SSH | الأفضل للإنتاج | يحتاج VS Code مثبتًا محليًا |

---

## حالات الاستخدام العملية

### تطوير نماذج التعلم العميق

```python
# مثال: تطوير نموذج تعلم عميق مع code-server

# 1. كتابة الشيفرة في code-server (VS Code)
# 2. تشغيل التجارب في Jupyter Notebook
# 3. مراقبة GPU في نافذة منفصلة

import torch
import torch.nn as nn
from torch.utils.data import DataLoader

class SimpleModel(nn.Module):
    """نموذج بسيط للتوضيح"""
    def __init__(self, input_size: int, hidden_size: int, output_size: int):
        super().__init__()
        self.network = nn.Sequential(
            nn.Linear(input_size, hidden_size),
            nn.ReLU(),
            nn.Dropout(0.3),
            nn.Linear(hidden_size, output_size)
        )
    
    def forward(self, x):
        return self.network(x)

# استخدام GPU إذا كانت متاحة
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
model = SimpleModel(784, 256, 10).to(device)

print(f"النموذج يعمل على: {device}")
print(f"عدد المعاملات: {sum(p.numel() for p in model.parameters()):,}")
```

### تحليل البيانات الضخمة

```python
# مثال: تحليل بيانات كبيرة مع code-server + JupyterLab

import pandas as pd
import dask.dataframe as dd
from pathlib import Path

# قراءة ملفات CSV كبيرة باستخدام Dask
data_path = Path("/home/jupyter/data")

# قراءة متعددة الملفات في توازٍ
df = dd.read_csv(data_path / "*.csv", 
                 dtype_backend='pyarrow',
                 assume_missing=True)

print(f"حجم البيانات: {len(df)} صف")
print(f"الأعمدة: {list(df.columns)}")

# معالجة البيانات بكفاءة
result = (df
    .groupby('category')
    .agg({'value': ['mean', 'std', 'count']})
    .compute()  # تنفيذ الحساب الفعلي
)

print(result)
```

---

## الخلاصة والنقاط الأساسية

`jupyter-codeserver-proxy` هو الحل المثالي للجمع بين قوة JupyterLab وسهولة VS Code في بيئة موحدة:

**للمطور الفردي**: استخدمه محليًا لتجربة تطوير سلسة.

**لفرق البيانات**: نشره على Docker أو Kubernetes لبيئة مشتركة.

**لبحوث التعلم الآلي**: استخدمه مع خوادم GPU للحصول على أقصى أداء.

النقاط الأساسية:
- JupyterLab 4 يُبسّط التثبيت مقارنةً بالإصدار 3
- Docker يضمن بيئة متسقة عبر جميع المطورين
- إعدادات الأمان ضرورية في بيئات الإنتاج
- استخدم tmux/screen للجلسات الدائمة على الخوادم البعيدة
