---
title: "استنتاج LLM للسياق الكبير مع oLLM: معالجة 100 ألف رمز على GPU بسعة 8 جيجا"
excerpt: "تعلم كيفية تشغيل نماذج LLM للسياق الكبير بكفاءة باستخدام مكتبة oLLM على GPU بسعة 8 جيجا. دليل شامل لمعالجة سياقات 100 ألف رمز مع أمثلة عملية ونصائح التحسين."
seo_title: "دليل استنتاج LLM للسياق الكبير مع oLLM - تحسين GPU بسعة 8 جيجا"
seo_description: "دليل شامل لاستخدام مكتبة oLLM لمعالجة سياقات 100 ألف رمز على GPU بسعة 8 جيجا. يتضمن تحليل العقود ومعالجة السجلات الطبية وتحليل السجلات مع أمثلة من العالم الحقيقي."
date: 2025-09-29
categories:
  - tutorials
tags:
  - oLLM
  - LLM
  - سياق-كبير
  - تحسين-GPU
  - HuggingFace
author_profile: true
toc: true
toc_label: "جدول المحتويات"
canonical_url: "https://thakicloud.github.io/ar/tutorials/ollm-large-context-llm-inference-guide/"
lang: ar
permalink: /ar/tutorials/ollm-large-context-llm-inference-guide/
---

⏱️ **الوقت المقدر للقراءة**: 15 دقيقة

# استنتاج LLM للسياق الكبير مع oLLM

أحد أكبر القيود عند العمل مع نماذج اللغة الكبيرة (LLM) هو **قيود طول السياق**. مع ذاكرة GPU النموذجية، من الصعب معالجة المستندات الطويلة أو سجلات المحادثات في تمريرة واحدة.

**oLLM** هي مكتبة مبتكرة تحل هذه المشكلة. تتيح معالجة سياقات 100 ألف رمز حتى مع GPU بسعة 8 جيجا فقط.

## ما هو oLLM؟

oLLM هي مكتبة Python خفيفة الوزن مبنية على HuggingFace Transformers و PyTorch. تتميز بـ:

- **معالجة السياق الكبير**: التعامل مع ما يصل إلى 100 ألف رمز
- **استخدام GPU منخفض التكلفة**: تشغيل النماذج الكبيرة مع 8 جيجا VRAM فقط
- **بدون تكميم**: يحافظ على دقة fp16/bf16
- **تفريغ SSD**: تفريغ KV cache وأوزان الطبقات إلى SSD

## النماذج المدعومة والأداء

### استخدام الذاكرة على Nvidia 3060 Ti بسعة 8 جيجا

| النموذج | الأوزان | طول السياق | KV Cache | VRAM الأساسي | oLLM GPU VRAM | oLLM القرص |
|---------|---------|-------------|----------|---------------|---------------|-------------|
| qwen3-next-80B | 160 جيجا (bf16) | 50k | 20 جيجا | ~190 جيجا | ~7.5 جيجا | 180 جيجا |
| gpt-oss-20B | 13 جيجا (packed bf16) | 10k | 1.4 جيجا | ~40 جيجا | ~7.3 جيجا | 15 جيجا |
| llama3-1B-chat | 2 جيجا (fp16) | 100k | 12.6 جيجا | ~16 جيجا | ~5 جيجا | 15 جيجا |
| llama3-3B-chat | 7 جيجا (fp16) | 100k | 34.1 جيجا | ~42 جيجا | ~5.3 جيجا | 42 جيجا |
| llama3-8B-chat | 16 جيجا (fp16) | 100k | 52.4 جيجا | ~71 جيجا | ~6.6 جيجا | 69 جيجا |

## التثبيت والإعداد

### 1. إنشاء البيئة الافتراضية

```bash
# إنشاء البيئة الافتراضية
python3 -m venv ollm_env
source ollm_env/bin/activate  # Linux/Mac
# أو
ollm_env\Scripts\activate  # Windows
```

### 2. تثبيت oLLM

```bash
# التثبيت عبر pip
pip install ollm

# أو التثبيت من المصدر
git clone https://github.com/Mega4alik/ollm.git
cd ollm
pip install -e .
```

### 3. تثبيت التبعيات الإضافية

```bash
# تثبيت kvikio لإصدار CUDA الخاص بك
pip install kvikio-cu12  # لـ CUDA 12.x
# أو
pip install kvikio-cu11  # لـ CUDA 11.x
```

### 4. التثبيت الإضافي لنموذج qwen3-next

```bash
# نموذج qwen3-next يتطلب إصدار transformers خاص
pip install git+https://github.com/huggingface/transformers.git
```

## الاستخدام الأساسي

### 1. مثال الاستنتاج الأساسي

```python
from ollm import Inference, file_get_contents, TextStreamer

# تهيئة النموذج
o = Inference("llama3-1B-chat", device="cuda:0", logging=True)
o.ini_model(models_dir="./models/", force_download=False)

# اختياري: تفريغ بعض الطبقات إلى CPU لتعزيز السرعة
o.offload_layers_to_cpu(layers_num=2)

# إعداد KV cache (اضبط على None إذا كان السياق صغير)
past_key_values = o.DiskCache(cache_dir="./kv_cache/")

# إعداد مُدفق النص
text_streamer = TextStreamer(o.tokenizer, skip_prompt=True, skip_special_tokens=False)

# تكوين الرسائل
messages = [
    {"role": "system", "content": "أنت مساعد ذكي مفيد."},
    {"role": "user", "content": "اذكر الكواكب."}
]

# الترميز والتوليد
input_ids = o.tokenizer.apply_chat_template(
    messages, 
    reasoning_effort="minimal", 
    tokenize=True, 
    add_generation_prompt=True, 
    return_tensors="pt"
).to(o.device)

outputs = o.model.generate(
    input_ids=input_ids,
    past_key_values=past_key_values,
    max_new_tokens=500,
    streamer=text_streamer
).cpu()

# فك تشفير النتيجة
answer = o.tokenizer.decode(outputs[0][input_ids.shape[-1]:], skip_special_tokens=False)
print(answer)
```

### 2. أمر التشغيل

```bash
# التشغيل مع تحسين تخصيص ذاكرة CUDA
PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True python example.py
```

## الاستخدام المتقدم

### 1. تحليل المستندات الكبيرة

```python
def analyze_large_document(document_path, model_name="llama3-8B-chat"):
    """دالة لتحليل المستندات الكبيرة"""
    
    # تهيئة النموذج
    o = Inference(model_name, device="cuda:0", logging=True)
    o.ini_model(models_dir="./models/", force_download=False)
    
    # إعداد KV cache للسياق الكبير
    past_key_values = o.DiskCache(cache_dir="./kv_cache/")
    
    # قراءة المستند
    document_content = file_get_contents(document_path)
    
    # مطالبة التحليل
    messages = [
        {
            "role": "system", 
            "content": "أنت خبير في تحليل المستندات. حلل المستند المعطى واختصر المحتوى الرئيسي مع استخراج النقاط المهمة."
        },
        {
            "role": "user", 
            "content": f"يرجى تحليل المستند التالي:\n\n{document_content}"
        }
    ]
    
    # الترميز
    input_ids = o.tokenizer.apply_chat_template(
        messages, 
        tokenize=True, 
        add_generation_prompt=True, 
        return_tensors="pt"
    ).to(o.device)
    
    # التوليد
    outputs = o.model.generate(
        input_ids=input_ids,
        past_key_values=past_key_values,
        max_new_tokens=1000,
        temperature=0.7,
        do_sample=True
    )
    
    # إرجاع النتيجة
    result = o.tokenizer.decode(outputs[0][input_ids.shape[-1]:], skip_special_tokens=True)
    return result
```

### 2. معالجة الاستجابة المتدفقة

```python
def stream_response(model_name, messages, max_tokens=500):
    """دالة للتعامل مع الاستجابات المتدفقة"""
    
    o = Inference(model_name, device="cuda:0", logging=True)
    o.ini_model(models_dir="./models/", force_download=False)
    
    # إعداد مُدفق النص
    text_streamer = TextStreamer(
        o.tokenizer, 
        skip_prompt=True, 
        skip_special_tokens=False
    )
    
    # الترميز
    input_ids = o.tokenizer.apply_chat_template(
        messages, 
        tokenize=True, 
        add_generation_prompt=True, 
        return_tensors="pt"
    ).to(o.device)
    
    # التوليد مع التدفق
    outputs = o.model.generate(
        input_ids=input_ids,
        max_new_tokens=max_tokens,
        streamer=text_streamer,
        temperature=0.7,
        do_sample=True
    )
    
    return outputs
```

## حالات الاستخدام في العالم الحقيقي

### 1. تحليل العقود والوثائق التنظيمية

```python
def analyze_contract(contract_path):
    """تحليل العقود"""
    messages = [
        {
            "role": "system",
            "content": "أنت خبير في تحليل الوثائق القانونية. حلل البنود الرئيسية للعقد وعوامل المخاطر والحقوق والالتزامات بوضوح."
        },
        {
            "role": "user", 
            "content": f"يرجى تحليل العقد التالي: {file_get_contents(contract_path)}"
        }
    ]
    return stream_response("llama3-8B-chat", messages, max_tokens=1000)
```

### 2. تحليل السجلات الطبية

```python
def analyze_medical_records(records_path):
    """تحليل السجلات الطبية"""
    messages = [
        {
            "role": "system",
            "content": "أنت خبير في تحليل البيانات الطبية. حلل سجلات المرضى واختصر التشخيصات الرئيسية وعمليات العلاج والاحتياطات."
        },
        {
            "role": "user",
            "content": f"يرجى تحليل السجلات الطبية التالية: {file_get_contents(records_path)}"
        }
    ]
    return stream_response("llama3-8B-chat", messages, max_tokens=1500)
```

### 3. تحليل ملفات السجل الكبيرة

```python
def analyze_logs(log_path):
    """تحليل ملفات السجل"""
    messages = [
        {
            "role": "system",
            "content": "أنت خبير في تحليل سجلات النظام. حلل السجلات لتحديد أنماط الأخطاء ومشاكل الأداء والتهديدات الأمنية."
        },
        {
            "role": "user",
            "content": f"يرجى تحليل ملف السجل التالي: {file_get_contents(log_path)}"
        }
    ]
    return stream_response("llama3-8B-chat", messages, max_tokens=2000)
```

## نصائح تحسين الأداء

### 1. تحسين الذاكرة

```python
# توفير ذاكرة GPU عن طريق تفريغ الطبقات
o.offload_layers_to_cpu(layers_num=4)  # تفريغ المزيد من الطبقات إلى CPU

# تفريغ القرص لـ KV cache
past_key_values = o.DiskCache(cache_dir="./kv_cache/")
```

### 2. تحسين السرعة

```python
# تحسين تخصيص ذاكرة CUDA
import os
os.environ['PYTORCH_CUDA_ALLOC_CONF'] = 'expandable_segments:True'

# ضبط حجم الدفعة
batch_size = 1  # اضبط حسب الذاكرة
```

### 3. دليل اختيار النموذج

- **للاستجابات السريعة**: llama3-1B-chat
- **للأداء المتوازن**: llama3-8B-chat  
- **لأعلى جودة**: qwen3-next-80B (يتطلب مساحة قرص أكبر)

## استكشاف الأخطاء وإصلاحها

### 1. خطأ نفاد الذاكرة

```python
# الحل 1: تفريغ المزيد من الطبقات إلى CPU
o.offload_layers_to_cpu(layers_num=6)

# الحل 2: استخدام نموذج أصغر
o = Inference("llama3-1B-chat", device="cuda:0")
```

### 2. مساحة القرص غير كافية

```python
# تعطيل KV cache (للسياقات الصغيرة)
past_key_values = None

# أو استخدام نموذج أصغر
o = Inference("llama3-1B-chat", device="cuda:0")
```

### 3. الأداء البطيء

```python
# تحسين ذاكرة CUDA
os.environ['PYTORCH_CUDA_ALLOC_CONF'] = 'expandable_segments:True'

# ضبط تفريغ الطبقات
o.offload_layers_to_cpu(layers_num=2)  # تفريغ عدد أقل من الطبقات
```

## الخلاصة

oLLM هي أداة مبتكرة تديمقرط استنتاج LLM للسياق الكبير. مع القدرة على معالجة سياقات 100 ألف رمز باستخدام GPU بسعة 8 جيجا فقط، يمكن للمطورين الأفراد والفرق الصغيرة الآن إجراء تحليل المستندات الكبيرة.

المزايا الرئيسية:
- **كفاءة التكلفة**: تشغيل النماذج الكبيرة بدون GPU باهظة الثمن
- **المرونة**: دعم نماذج مختلفة وأطوال سياق متنوعة
- **العملية**: أدوات يمكن تطبيقها فوراً على العمل الحقيقي

استخدم oLLM لأداء مهام معالجة النصوص الكبيرة بكفاءة مثل تحليل العقود ومعالجة السجلات الطبية وتحليل السجلات!

## المراجع

- [مستودع oLLM على GitHub](https://github.com/Mega4alik/ollm)
- [HuggingFace Transformers](https://huggingface.co/docs/transformers/)
- [دليل تحسين PyTorch CUDA](https://pytorch.org/docs/stable/notes/cuda.html)
