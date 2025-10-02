---
title: "دليل شامل لضبط نماذج اللغة الكبيرة باستخدام Unsloth Docker: من التثبيت إلى الإنتاج"
excerpt: "تعلم كيفية ضبط نماذج اللغة الكبيرة بكفاءة باستخدام حاوية Unsloth Docker. هذا الدليل الشامل يغطي التثبيت والتكوين والأمثلة العملية للتدريب المحلي لنماذج اللغة."
seo_title: "دليل Unsloth Docker لضبط نماذج اللغة - الدليل الكامل 2025"
seo_description: "أتقن ضبط نماذج اللغة الكبيرة باستخدام Unsloth Docker. دليل خطوة بخطوة يغطي التثبيت وإعداد GPU والوصول إلى Jupyter Lab وأمثلة التدريب العملية لتخصيص النماذج بكفاءة."
date: 2025-10-03
categories:
  - tutorials
tags:
  - unsloth
  - docker
  - llm
  - fine-tuning
  - machine-learning
  - gpu
  - jupyter
  - nvidia
author_profile: true
toc: true
toc_label: "جدول المحتويات"
lang: ar
permalink: /ar/tutorials/unsloth-docker-llm-training-tutorial/
canonical_url: "https://thakicloud.github.io/ar/tutorials/unsloth-docker-llm-training-tutorial/"
---

⏱️ **وقت القراءة المتوقع**: 12 دقيقة

## مقدمة

أصبح ضبط نماذج اللغة الكبيرة (LLMs) أمراً مهماً بشكل متزايد لإنشاء تطبيقات الذكاء الاصطناعي المتخصصة. ومع ذلك، يمكن أن يكون إعداد البيئة المناسبة لتدريب نماذج اللغة الكبيرة أمراً صعباً بسبب التبعيات المعقدة والتعارضات المحتملة. يحل حل Unsloth Docker هذه المشاكل من خلال توفير بيئة مستقرة ومُعدة مسبقاً لضبط نماذج اللغة الكبيرة بكفاءة.

في هذا الدليل الشامل، سنستكشف كيفية استخدام صورة Unsloth Docker لضبط نماذج اللغة الكبيرة محلياً، مغطين كل شيء من الإعداد الأولي إلى أمثلة التدريب العملية.

## ما هو Unsloth؟

Unsloth هو إطار عمل قوي مصمم لتسريع ضبط نماذج اللغة الكبيرة مع تقليل استخدام الذاكرة. يوفر تحسينات كبيرة في الأداء مقارنة بطرق الضبط التقليدية، مما يجعل من الممكن تدريب نماذج أكبر على أجهزة المستهلكين.

### الفوائد الرئيسية لـ Unsloth Docker

- **إدارة التبعيات**: يلغي "جحيم التبعيات" ببيئة محتواة بالكامل
- **أمان النظام**: يعمل بدون صلاحيات الجذر، مما يحافظ على نظافة النظام
- **قابلية النقل**: يعمل بثبات عبر منصات وإعدادات مختلفة
- **بيئة مُعدة مسبقاً**: تتضمن جميع الأدوات والمكتبات الضرورية
- **تحديثات منتظمة**: يتم تحديثها بانتظام بأحدث التحسينات

## المتطلبات المسبقة

قبل البدء، تأكد من توفر:

- **NVIDIA GPU**: مطلوب للتدريب الفعال (يُنصح بـ RTX 3060 أو أفضل)
- **Docker**: مثبت ويعمل على نظامك
- **NVIDIA Container Toolkit**: للوصول إلى GPU داخل الحاويات
- **مساحة تخزين كافية**: على الأقل 50 جيجابايت مساحة فارغة للنماذج والبيانات
- **ذاكرة الوصول العشوائي**: يُنصح بـ 16 جيجابايت أو أكثر

## الخطوة 1: تثبيت Docker و NVIDIA Container Toolkit

### تثبيت Docker

لأنظمة Linux:
```bash
# تحديث فهرس الحزم
sudo apt-get update

# تثبيت Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# إضافة المستخدم إلى مجموعة docker
sudo usermod -aG docker $USER
newgrp docker
```

للأنظمة الأخرى، قم بزيارة [دليل تثبيت Docker الرسمي](https://docs.docker.com/get-docker/).

### تثبيت NVIDIA Container Toolkit

تمكن NVIDIA Container Toolkit الوصول إلى GPU داخل حاويات Docker:

```bash
# تعيين الإصدار (استخدم أحدث إصدار مستقر)
export NVIDIA_CONTAINER_TOOLKIT_VERSION=1.17.8-1

# تثبيت NVIDIA Container Toolkit
sudo apt-get update && sudo apt-get install -y \
  nvidia-container-toolkit=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
  nvidia-container-toolkit-base=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
  libnvidia-container-tools=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
  libnvidia-container1=${NVIDIA_CONTAINER_TOOLKIT_VERSION}

# إعادة تشغيل خدمة Docker
sudo systemctl restart docker
```

### التحقق من التثبيت

اختبر الوصول إلى GPU:
```bash
# اختبار تكامل NVIDIA Docker
docker run --rm --gpus all nvidia/cuda:11.8-base-ubuntu20.04 nvidia-smi
```

## الخطوة 2: تشغيل حاوية Unsloth Docker

### إعداد الحاوية الأساسي

أنشئ دليل عمل وشغل الحاوية:

```bash
# إنشاء دليل العمل
mkdir -p ~/unsloth-workspace
cd ~/unsloth-workspace

# تشغيل حاوية Unsloth بالتكوين الأساسي
docker run -d \
  --name unsloth-training \
  -e JUPYTER_PASSWORD="mypassword" \
  -p 8888:8888 \
  -p 2222:22 \
  -v $(pwd)/work:/workspace/work \
  --gpus all \
  unsloth/unsloth
```

### التكوين المتقدم

للاستخدام في الإنتاج، فكر في هذا الإعداد المحسن:

```bash
# إنشاء مفتاح SSH للوصول الآمن
ssh-keygen -t rsa -b 4096 -f ~/.ssh/unsloth_key

# تشغيل الحاوية بالإعدادات المتقدمة
docker run -d \
  --name unsloth-production \
  -e JUPYTER_PORT=8000 \
  -e JUPYTER_PASSWORD="secure_password_2024" \
  -e "SSH_KEY=$(cat ~/.ssh/unsloth_key.pub)" \
  -e USER_PASSWORD="unsloth2024" \
  -p 8000:8000 \
  -p 2222:22 \
  -v $(pwd)/work:/workspace/work \
  -v $(pwd)/models:/workspace/models \
  -v $(pwd)/datasets:/workspace/datasets \
  --gpus all \
  --restart unless-stopped \
  unsloth/unsloth
```

## الخطوة 3: الوصول إلى Jupyter Lab

### الوصول عبر واجهة الويب

1. افتح متصفحك وانتقل إلى `http://localhost:8888`
2. أدخل كلمة المرور التي حددتها (افتراضي: "unsloth")
3. ستشاهد واجهة Jupyter Lab مع دفاتر محملة مسبقاً

### الوصول عبر SSH (اختياري)

للوصول عبر سطر الأوامر:
```bash
# الاتصال عبر SSH
ssh -i ~/.ssh/unsloth_key -p 2222 unsloth@localhost
```

## الخطوة 4: فهم هيكل الحاوية

حاوية Unsloth منظمة كما يلي:

```
/workspace/
├── work/                    # دليل العمل المُركب
├── unsloth-notebooks/       # دفاتر أمثلة الضبط
├── models/                  # تخزين النماذج (إذا كان مُركباً)
└── datasets/               # تخزين مجموعات البيانات (إذا كان مُركباً)

/home/unsloth/              # دليل المستخدم الرئيسي
```

## الخطوة 5: مثال الضبط الأول

دعنا ننشئ مثالاً بسيطاً للضبط باستخدام Llama-3.

### إنشاء دفتر جديد

1. في Jupyter Lab، أنشئ دفتراً جديداً
2. أضف خلايا الكود التالية:

```python
# الخلية 1: تثبيت واستيراد التبعيات
from unsloth import FastLanguageModel
import torch

# الخلية 2: تحميل النموذج
model, tokenizer = FastLanguageModel.from_pretrained(
    model_name="unsloth/llama-3-8b-bnb-4bit",
    max_seq_length=2048,
    dtype=None,
    load_in_4bit=True,
)

# الخلية 3: تكوين LoRA
model = FastLanguageModel.get_peft_model(
    model,
    r=16,
    target_modules=["q_proj", "k_proj", "v_proj", "o_proj",
                    "gate_proj", "up_proj", "down_proj"],
    lora_alpha=16,
    lora_dropout=0,
    bias="none",
    use_gradient_checkpointing="unsloth",
    random_state=3407,
    use_rslora=False,
    loftq_config=None,
)

# الخلية 4: إعداد مجموعة البيانات
alpaca_prompt = """Below is an instruction that describes a task, paired with an input that provides further context. Write a response that appropriately completes the request.

### Instruction:
{}

### Input:
{}

### Response:
{}"""

def formatting_prompts_func(examples):
    instructions = examples["instruction"]
    inputs       = examples["input"]
    outputs      = examples["output"]
    texts = []
    for instruction, input, output in zip(instructions, inputs, outputs):
        text = alpaca_prompt.format(instruction, input, output) + tokenizer.eos_token
        texts.append(text)
    return { "text" : texts, }

# تحميل مجموعة البيانات
from datasets import load_dataset
dataset = load_dataset("yahma/alpaca-cleaned", split="train")
dataset = dataset.map(formatting_prompts_func, batched=True)

# الخلية 5: تكوين التدريب
from trl import SFTTrainer
from transformers import TrainingArguments

trainer = SFTTrainer(
    model=model,
    tokenizer=tokenizer,
    train_dataset=dataset,
    dataset_text_field="text",
    max_seq_length=2048,
    dataset_num_proc=2,
    packing=False,
    args=TrainingArguments(
        per_device_train_batch_size=2,
        gradient_accumulation_steps=4,
        warmup_steps=5,
        max_steps=60,
        learning_rate=2e-4,
        fp16=not torch.cuda.is_bf16_supported(),
        bf16=torch.cuda.is_bf16_supported(),
        logging_steps=1,
        optim="adamw_8bit",
        weight_decay=0.01,
        lr_scheduler_type="linear",
        seed=3407,
        output_dir="outputs",
    ),
)

# الخلية 6: بدء التدريب
trainer_stats = trainer.train()
```

### مراقبة تقدم التدريب

ستعرض عملية التدريب أشرطة التقدم ومقاييس الخسارة. راقب هذه لضمان أن التدريب يسير بشكل صحيح.

## الخطوة 6: حفظ واستخدام النموذج المضبوط

### الحفظ بتنسيقات مختلفة

```python
# الحفظ بتنسيق Hugging Face
model.save_pretrained("my_finetuned_model")
tokenizer.save_pretrained("my_finetuned_model")

# الحفظ بتنسيق GGUF لـ Ollama
model.save_pretrained_gguf("my_model", tokenizer, quantization_method="q4_k_m")

# الحفظ لـ VLLM
model.save_pretrained_merged("my_model_vllm", tokenizer, save_method="merged_16bit")
```

### اختبار النموذج

```python
# اختبار الاستنتاج
FastLanguageModel.for_inference(model)

inputs = tokenizer(
    [alpaca_prompt.format(
        "ما هي عاصمة فرنسا؟",
        "",
        ""
    )], return_tensors="pt").to("cuda")

outputs = model.generate(**inputs, max_new_tokens=64, use_cache=True)
print(tokenizer.batch_decode(outputs))
```

## خيارات التكوين المتقدمة

### متغيرات البيئة

| المتغير | الوصف | القيمة الافتراضية |
|---------|--------|------------------|
| `JUPYTER_PASSWORD` | كلمة مرور Jupyter Lab | `unsloth` |
| `JUPYTER_PORT` | منفذ Jupyter Lab | `8888` |
| `SSH_KEY` | المفتاح العام لـ SSH | `None` |
| `USER_PASSWORD` | كلمة مرور المستخدم لـ sudo | `unsloth` |

### تحسين ذاكرة GPU

للأنظمة ذات ذاكرة GPU المحدودة:

```python
# استخدام أحجام دفعات أصغر
per_device_train_batch_size=1
gradient_accumulation_steps=8

# تفعيل نقاط تفتيش التدرج
use_gradient_checkpointing="unsloth"

# استخدام التكميم 4-بت
load_in_4bit=True
```

### التدريب متعدد GPU

للأنظمة ذات GPUs متعددة:

```bash
# تشغيل الحاوية مع جميع GPUs
docker run -d \
  --gpus all \
  # ... معاملات أخرى
  unsloth/unsloth

# في سكريبت التدريب، استخدم DataParallel
model = torch.nn.DataParallel(model)
```

## حل المشاكل الشائعة

### عدم اكتشاف GPU

```bash
# فحص توفر GPU
nvidia-smi

# التحقق من وصول Docker إلى GPU
docker run --rm --gpus all nvidia/cuda:11.8-base-ubuntu20.04 nvidia-smi
```

### مشاكل الذاكرة

- تقليل حجم الدفعة
- تفعيل نقاط تفتيش التدرج
- استخدام التكميم 4-بت
- مسح ذاكرة GPU: `torch.cuda.empty_cache()`

### مشاكل الوصول إلى الحاوية

```bash
# فحص حالة الحاوية
docker ps -a

# عرض سجلات الحاوية
docker logs unsloth-training

# إعادة تشغيل الحاوية
docker restart unsloth-training
```

## أفضل الممارسات

### 1. إدارة البيانات

- استخدام تركيب الأحجام للتخزين الدائم
- تنظيم مجموعات البيانات في أدلة مخصصة
- نسخ احتياطي منتظم للنماذج المهمة

### 2. مراقبة الموارد

```python
# مراقبة استخدام GPU
import GPUtil
GPUtil.showUtilization()

# مراقبة موارد النظام
import psutil
print(f"CPU: {psutil.cpu_percent()}%")
print(f"RAM: {psutil.virtual_memory().percent}%")
```

### 3. اعتبارات الأمان

- استخدام كلمات مرور قوية للوصول إلى Jupyter
- تنفيذ مصادقة مفتاح SSH
- تشغيل الحاويات كمستخدمين غير جذر
- تحديث صورة Unsloth بانتظام

### 4. تحسين الأداء

- استخدام أحجام دفعات مناسبة لـ GPU الخاص بك
- تفعيل تدريب الدقة المختلطة
- استخدام تراكم التدرج لأحجام دفعات أكبر فعالة
- مراقبة مقاييس التدريب لمنع الإفراط في التدريب

## النشر في الإنتاج

### إعداد Docker Compose

إنشاء `docker-compose.yml` لإدارة أسهل:

```yaml
version: '3.8'
services:
  unsloth:
    image: unsloth/unsloth
    container_name: unsloth-production
    environment:
      - JUPYTER_PASSWORD=secure_password
      - JUPYTER_PORT=8888
      - USER_PASSWORD=unsloth2024
    ports:
      - "8888:8888"
      - "2222:22"
    volumes:
      - ./work:/workspace/work
      - ./models:/workspace/models
      - ./datasets:/workspace/datasets
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
    restart: unless-stopped
```

### خط أنابيب التدريب الآلي

إنشاء سكريبت تدريب لسير العمل الآلي:

```python
#!/usr/bin/env python3
"""
خط أنابيب تدريب Unsloth الآلي
"""
import argparse
import json
from pathlib import Path
from unsloth import FastLanguageModel
from transformers import TrainingArguments
from trl import SFTTrainer

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--config", required=True, help="ملف JSON لتكوين التدريب")
    args = parser.parse_args()
    
    # تحميل التكوين
    with open(args.config) as f:
        config = json.load(f)
    
    # تهيئة النموذج
    model, tokenizer = FastLanguageModel.from_pretrained(
        model_name=config["model_name"],
        max_seq_length=config["max_seq_length"],
        load_in_4bit=config.get("load_in_4bit", True)
    )
    
    # تكوين LoRA
    model = FastLanguageModel.get_peft_model(
        model,
        r=config["lora_r"],
        target_modules=config["target_modules"],
        lora_alpha=config["lora_alpha"],
        lora_dropout=config["lora_dropout"],
        bias="none",
        use_gradient_checkpointing="unsloth"
    )
    
    # منطق التدريب...
    print("تم إكمال التدريب بنجاح!")

if __name__ == "__main__":
    main()
```

## الخلاصة

يوفر Unsloth Docker حلاً ممتازاً لضبط نماذج اللغة الكبيرة، مما يلغي تعقيد الإعداد مع الحفاظ على الأداء والمرونة. باتباع هذا الدليل، لديك الآن:

- بيئة Unsloth مكونة بالكامل
- فهم لخيارات التكوين الأساسية والمتقدمة
- خبرة عملية مع سير عمل الضبط
- معرفة بأفضل الممارسات وتقنيات حل المشاكل

يضمن النهج المحتوى نتائج قابلة للتكرار ويجعل من السهل توسيع عمليات الضبط عبر بيئات مختلفة.

### الخطوات التالية

1. **تجريب نماذج مختلفة**: جرب ضبط معماريات نماذج متنوعة
2. **استكشاف التقنيات المتقدمة**: ابحث في التعلم المعزز وتدريب DPO
3. **التحسين للإنتاج**: تنفيذ خطوط أنابيب التدريب الآلية
4. **مراقبة الأداء**: إعداد تسجيل ومراقبة شاملين

### موارد إضافية

- [وثائق Unsloth الرسمية](https://docs.unsloth.ai/)
- [مستودع Unsloth على GitHub](https://github.com/unslothai/unsloth)
- [أفضل ممارسات Docker](https://docs.docker.com/develop/best-practices/)
- [وثائق NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/)

تدريب سعيد! 🚀
