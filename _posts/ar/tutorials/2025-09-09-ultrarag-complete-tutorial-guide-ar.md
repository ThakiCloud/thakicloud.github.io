---
title: "دليل UltraRAG الشامل: بناء أنظمة RAG المتقدمة باستخدام إطار العمل منخفض الأكواد"
excerpt: "تعلم كيفية بناء أنظمة RAG (الجيل المعزز بالاسترجاع) المتطورة باستخدام UltraRAG، إطار عمل منخفض الأكواد قائم على MCP يمكّن من النشر السريع والتجريب."
seo_title: "دليل UltraRAG: الدليل الشامل لإطار عمل RAG منخفض الأكواد - Thaki Cloud"
seo_description: "أتقن إطار عمل UltraRAG مع دليلنا الشامل. تعلم التثبيت والتكوين وتنفيذ أنظمة RAG المتقدمة مع أمثلة عملية."
date: 2025-09-09
categories:
  - tutorials
tags:
  - RAG
  - UltraRAG
  - LLM
  - MCP
  - منخفض الأكواد
  - الذكاء الاصطناعي
  - التعلم الآلي
  - دليل
author_profile: true
toc: true
toc_label: "المحتويات"
lang: ar
permalink: /ar/tutorials/ultrarag-complete-tutorial-guide/
canonical_url: "https://thakicloud.github.io/ar/tutorials/ultrarag-complete-tutorial-guide/"
---

⏱️ **وقت القراءة المتوقع**: 15 دقيقة

## مقدمة عن UltraRAG

UltraRAG 2.0 هو إطار عمل ثوري منخفض الأكواد قائم على MCP (بروتوكول سياق النموذج) طورته OpenBMB. بشعار **"أكواد أقل، حاجز أدنى، نشر أسرع"**، يمكّن UltraRAG الباحثين والمطورين من بناء خطوط أنابيب RAG معقدة بجهد برمجة أدنى.

### الخصائص الرئيسية

- **إطار عمل منخفض الأكواد**: بناء أنظمة RAG متطورة باستخدام ملفات تكوين YAML
- **تكامل MCP**: الاستفادة من بروتوكول سياق النموذج للتواصل السلس بين النماذج
- **دعم واسع لمجموعات البيانات**: دعم مدمج لأكثر من 17 مجموعة بيانات تقييم شائعة
- **طرق خط أساس متعددة**: تنفيذ مسبق لأحدث أساليب RAG
- **دعم Docker**: نشر سهل وبيئات حاويات
- **معمارية نمطية**: مكونات خط أنابيب مرنة للتخصيص

### طرق خط الأساس المدعومة

يأتي UltraRAG مع طرق RAG متقدمة مُنفّذة مسبقاً:

- **Vanilla RAG**: الجيل المعزز بالاسترجاع الأساسي
- **IRCoT**: تداخل الاسترجاع مع سلسلة الأفكار
- **IterRetGen**: الاسترجاع والجيل التكراري
- **RankCoT**: سلسلة الأفكار القائمة على التصنيف
- **R1-searcher**: منهجية بحث متقدمة
- **Search-o1**: خوارزمية بحث محسّنة
- **Search-r1**: منهج بحث مُحدّث
- **WebNote**: تكامل تدوين الملاحظات القائم على الويب

## المتطلبات المسبقة

قبل البدء، تأكد من أن نظامك يلبي هذه المتطلبات:

```bash
# متطلبات النظام
- Python 3.9+
- دعم CUDA (اختياري، لتسريع GPU)
- Docker (اختياري، للنشر المحوسب)
- Git لاستنساخ المستودع
```

## دليل التثبيت

### الطريقة 1: استخدام مدير الحزم UV (موصى)

يستخدم UltraRAG مدير الحزم الحديث `uv` لحل التبعيات والتثبيت بشكل أسرع.

#### الخطوة 1: تثبيت مدير الحزم UV

```bash
# تثبيت uv إذا لم يكن مثبتاً بالفعل
curl -LsSf https://astral.sh/uv/install.sh | sh

# إنعاش الشل أو تشغيل:
source ~/.bashrc  # أو ~/.zshrc لمستخدمي zsh
```

#### الخطوة 2: استنساخ المستودع

```bash
# استنساخ مستودع UltraRAG
git clone https://github.com/OpenBMB/UltraRAG.git
cd UltraRAG
```

#### الخطوة 3: تثبيت التبعيات

اختر خيار التثبيت الذي يناسب احتياجاتك:

```bash
# التثبيت الأساسي (تبعيات أدنى)
uv pip install -e .

# لدعم استضافة LLM (يتضمن vLLM)
uv pip install -e ".[vllm]"

# لقدرات تحليل المستندات
uv pip install -e ".[corpus]"

# التثبيت الكامل (جميع الميزات عدا FAISS)
uv pip install -e ".[all]"
```

#### الخطوة 4: التحقق من التثبيت

```bash
# اختبار التثبيت
ultrarag run examples/sayhello.yaml
```

**الإخراج المتوقع:**
```
Hello, UltraRAG 2.0!
مرحباً بك في إطار عمل RAG المتقدم!
```

### الطريقة 2: تثبيت Docker

للنشر المحوسب وإدارة البيئة الأسهل:

#### الخطوة 1: بناء صورة Docker

```bash
# استنساخ والانتقال إلى دليل UltraRAG
git clone https://github.com/OpenBMB/UltraRAG.git
cd UltraRAG

# بناء صورة Docker
docker build -t ultrarag:v2.0.0-beta .
```

#### الخطوة 2: تشغيل حاوية تفاعلية

```bash
# بدء حاوية Docker تفاعلية مع دعم GPU
docker run -it --rm --gpus all ultrarag:v2.0.0-beta bash

# داخل الحاوية، التحقق من التثبيت
ultrarag run examples/sayhello.yaml
```

## الاستخدام الأساسي: خط أنابيب RAG الأول

### فهم سير عمل UltraRAG

يتبع UltraRAG عملية بسيطة من ثلاث خطوات:

1. **تجميع خط الأنابيب**: توليد تكوين المعاملات من YAML
2. **تعديل المعاملات**: تخصيص الإعدادات حسب الحاجة
3. **تشغيل خط الأنابيب**: تنفيذ نظام RAG المكوّن

### المثال 1: RAG الأساسي

لنبدأ بتنفيذ vanilla RAG بسيط:

#### الخطوة 1: فحص التكوين

```bash
# عرض مثال RAG الأساسي
cat examples/rag.yaml
```

#### الخطوة 2: تجميع خط الأنابيب

```bash
# توليد معاملات التكوين
ultrarag compile examples/rag.yaml
```

ينشئ هذا ملف `rag_params.yaml` مع جميع المعاملات القابلة للتكوين.

#### الخطوة 3: تخصيص المعاملات (اختياري)

```bash
# تحرير ملف المعاملات المُولّد
nano rag_params.yaml

# المعاملات الرئيسية للتخصيص:
# - model_name: نموذج LLM للاستخدام
# - retriever_name: نموذج التضمين للاسترجاع
# - corpus_path: مسار مجموعة المستندات
# - dataset_path: موقع مجموعة بيانات التقييم
```

#### الخطوة 4: تشغيل خط الأنابيب

```bash
# تنفيذ خط أنابيب RAG
ultrarag run examples/rag.yaml
```

### المثال 2: RAG متقدم مع سلسلة الأفكار

لنطبق نظام RAG أكثر تطوراً باستخدام IRCoT (تداخل الاسترجاع مع سلسلة الأفكار):

```bash
# تجميع خط أنابيب IRCoT
ultrarag compile examples/IRCoT.yaml

# تشغيل نظام IRCoT RAG
ultrarag run examples/IRCoT.yaml
```

## العمل مع مجموعات البيانات والمجموعات النصية

### مجموعات بيانات التقييم المدعومة

يوفر UltraRAG دعماً مدمجاً لـ 17 مجموعة بيانات شائعة:

| نوع مجموعة البيانات | اسم مجموعة البيانات | الحجم الأصلي | عينة التقييم |
|-------------------|-------------------|-------------|-------------|
| سؤال وجواب | Natural Questions (NQ) | 3,610 | 1,000 |
| سؤال وجواب | TriviaQA | 11,313 | 1,000 |
| سؤال وجواب | PopQA | 14,267 | 1,000 |
| سؤال وجواب متعدد الخطوات | HotpotQA | 7,405 | 1,000 |
| سؤال وجواب متعدد الخطوات | 2WikiMultiHopQA | 12,576 | 1,000 |
| خيارات متعددة | ARC | 3,548 | 1,000 |
| خيارات متعددة | MMLU | 14,042 | 1,000 |
| سؤال وجواب طويل | ASQA | 948 | 948 |
| التحقق من الحقائق | FEVER | 13,332 | 1,000 |

### استخدام مجموعات بيانات مخصصة

لاستخدام مجموعة البيانات الخاصة بك، اتبع تنسيق بيانات UltraRAG:

```json
{
  "id": "معرف_السؤال_الفريد",
  "question": "نص السؤال",
  "answers": ["الإجابة1", "الإجابة2"],
  "context": "معلومات_السياق_الاختيارية"
}
```

### إعداد مجموعة المستندات

#### الخيار 1: استخدام مجموعة نصية مُعدّة مسبقاً

```bash
# تحميل مجموعة wiki-2018 (أكثر من 21 مليون مستند)
# اتبع تعليمات تحميل مجموعة البيانات في الوثائق
```

#### الخيار 2: إنشاء مجموعة نصية مخصصة

```bash
# إنشاء دليل مجموعة المستندات
mkdir -p data/my_corpus

# إضافة مستنداتك (ملفات نصية)
# UltraRAG يدعم تنسيقات متنوعة: .txt, .pdf, .docx
cp your_documents/* data/my_corpus/
```

## نشر أجهزة الاسترجاع ونماذج اللغة الكبيرة

### إعداد خادم الاسترجاع

يمكن لـ UltraRAG نشر خدمات الاسترجاع لفهرسة المجموعة النصية والبحث:

```bash
# بدء خادم الاسترجاع
ultrarag serve retriever \
  --model_name BAAI/bge-m3 \
  --corpus_path data/wiki-2018 \
  --port 8001
```

### نشر خدمات نماذج اللغة الكبيرة

نشر نماذج اللغة باستخدام خلفية vLLM:

```bash
# نشر خادم LLM متوافق مع OpenAI
ultrarag serve llm \
  --model_name Qwen/Qwen2.5-72B-Instruct \
  --port 8000 \
  --gpu_memory_utilization 0.8
```

### استخدام خدمات API خارجية

تكوين UltraRAG لاستخدام APIs خارجية:

```yaml
# في تكوين خط الأنابيب
llm:
  provider: "openai"
  api_key: "your_api_key"
  model: "gpt-4"
  base_url: "https://api.openai.com/v1"

retriever:
  provider: "custom"
  endpoint: "http://your-retriever-service:8001"
```

## أمثلة التكوين المتقدم

### المثال 3: التفكير متعدد الخطوات مع IterRetGen

```yaml
# examples/advanced_iterretgen.yaml
pipeline:
  name: "iterative_retrieval_generation"
  components:
    - retriever:
        model: "BAAI/bge-m3"
        top_k: 10
        iterations: 3
    - llm:
        model: "Qwen/Qwen2.5-72B-Instruct"
        temperature: 0.1
        max_tokens: 1024
    - reasoning:
        strategy: "iterative"
        max_iterations: 5
        convergence_threshold: 0.95

evaluation:
  dataset: "hotpotqa"
  metrics: ["exact_match", "f1_score", "retrieval_precision"]
```

### المثال 4: استراتيجية بحث مخصصة

```yaml
# examples/custom_search.yaml
pipeline:
  name: "custom_search_rag"
  components:
    - search:
        strategy: "search-o1"
        search_depth: 3
        query_expansion: true
        rerank_threshold: 0.7
    - retriever:
        model: "sentence-transformers/all-MiniLM-L6-v2"
        chunk_size: 512
        chunk_overlap: 50
    - generator:
        model: "microsoft/DialoGPT-large"
        response_length: "medium"
```

## تحسين الأداء

### إعداد تسريع GPU

```bash
# التحقق من توفر CUDA
python -c "import torch; print(f'CUDA متوفر: {torch.cuda.is_available()}')"

# تكوين إعدادات GPU في خط الأنابيب
gpu_config:
  enabled: true
  device_map: "auto"
  memory_fraction: 0.8
  mixed_precision: true
```

### تحسين الذاكرة

```yaml
# في تكوين خط الأنابيب
optimization:
  batch_size: 8
  gradient_checkpointing: true
  cpu_offload: true
  memory_efficient_attention: true
```

## التصحيح واستكشاف الأخطاء

### المشاكل الشائعة والحلول

#### المشكلة 1: نفاد ذاكرة CUDA

```bash
# الحل: تقليل حجم الدفعة أو استخدام إلغاء تحميل CPU
# في التكوين:
optimization:
  batch_size: 2
  cpu_offload: true
```

#### المشكلة 2: أداء استرجاع بطيء

```bash
# الحل: استخدام البحث التقريبي أو تقليل حجم المجموعة النصية
retriever:
  search_type: "approximate"
  index_type: "faiss"
  nprobe: 10
```

#### المشكلة 3: أخطاء تحميل النموذج

```bash
# الحل: التحقق من توفر النموذج والأذونات
# التحقق من تحميل النموذج:
huggingface-cli download Qwen/Qwen2.5-7B-Instruct
```

### وضع التصحيح

تفعيل التسجيل المفصل لاستكشاف الأخطاء:

```bash
# التشغيل مع إخراج التصحيح
ultrarag run examples/rag.yaml --debug --verbose

# فحص السجلات
tail -f logs/ultrarag.log
```

## التكامل مع أدوات أخرى

### تكامل Jupyter Notebook

```python
# في دفتر Jupyter
import ultrarag

# تحميل وتشغيل خط الأنابيب
pipeline = ultrarag.load_pipeline("examples/rag.yaml")
results = pipeline.run(question="ما هو التعلم الآلي؟")
print(results)
```

### تكامل API

```python
# استخدام RESTful API
import requests

response = requests.post(
    "http://localhost:8000/v1/chat/completions",
    json={
        "model": "ultrarag",
        "messages": [{"role": "user", "content": "اشرح الحوسبة الكمية"}],
        "rag_enabled": True
    }
)
```

## أفضل الممارسات

### 1. إدارة التكوين

- استخدم إدارة الإصدارات لتكوينات خط الأنابيب
- احتفظ بتكوينات منفصلة للتطوير والإنتاج
- وثّق المعاملات المخصصة وتأثيراتها

### 2. إعداد البيانات

- ضمان تنسيق مستندات متسق
- تنفيذ معالجة مسبقة مناسبة للنص
- استخدام أحجام قطع مناسبة لمجالك

### 3. استراتيجية التقييم

- وضع مقاييس خط أساس قبل التحسين
- استخدام مجموعات بيانات تقييم متعددة
- تطبيق اختبار A/B لتغييرات التكوين

### 4. إدارة الموارد

- مراقبة استخدام ذاكرة GPU
- تنفيذ استراتيجيات تخزين مؤقت مناسبة
- استخدام معالجة الدفعات للتقييم واسع النطاق

## النشر في الإنتاج

### إعداد Docker Compose

```yaml
# docker-compose.yml
version: '3.8'
services:
  ultrarag-api:
    image: ultrarag:v2.0.0-beta
    ports:
      - "8000:8000"
    environment:
      - CUDA_VISIBLE_DEVICES=0
    volumes:
      - ./data:/app/data
      - ./configs:/app/configs
    command: ultrarag serve api --config configs/production.yaml

  retriever:
    image: ultrarag:v2.0.0-beta
    ports:
      - "8001:8001"
    command: ultrarag serve retriever --port 8001
```

### نشر Kubernetes

```yaml
# k8s-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ultrarag-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: ultrarag
  template:
    metadata:
      labels:
        app: ultrarag
    spec:
      containers:
      - name: ultrarag
        image: ultrarag:v2.0.0-beta
        ports:
        - containerPort: 8000
        resources:
          requests:
            nvidia.com/gpu: 1
          limits:
            nvidia.com/gpu: 1
```

## الخلاصة

يمثل UltraRAG 2.0 تقدماً مهماً في جعل أنظمة RAG متاحة للباحثين والمطورين. بنهجه منخفض الأكواد ودعمه الواسع لخطوط الأساس ومعماريته المرنة، يمكنك إنشاء نماذج أولية بسرعة ونشر تطبيقات RAG متطورة.

### النقاط الرئيسية

- **إعداد سهل**: تثبيت سريع مع uv أو Docker
- **نظام بيئي غني**: أكثر من 17 مجموعة بيانات وطرق خط أساس متعددة
- **تكوين مرن**: تعريف خط أنابيب قائم على YAML
- **جاهز للإنتاج**: خيارات نشر Docker و Kubernetes
- **ودود للبحث**: أدوات تقييم وتصحيح مدمجة

### الخطوات التالية

1. تجربة طرق خط أساس مختلفة
2. اختبار على مجموعات بيانات خاصة بمجالك
3. تخصيص أجهزة الاسترجاع والمولدات لحالة الاستخدام الخاصة بك
4. النشر في الإنتاج مع المراقبة والتوسع

للميزات المتقدمة والتحديثات الأحدث، تفضل بزيارة [وثائق UltraRAG الرسمية](https://openbmb.github.io/UltraRAG/) و[مستودع GitHub](https://github.com/OpenBMB/UltraRAG).

---

*غطى هذا الدليل الجوانب الأساسية لـ UltraRAG 2.0. للتفاصيل التنفيذية المحددة والتكوينات المتقدمة، راجع الوثائق الرسمية ومستودعات الأمثلة.*
