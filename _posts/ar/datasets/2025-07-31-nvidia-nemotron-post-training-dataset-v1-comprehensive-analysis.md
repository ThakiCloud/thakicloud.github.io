---
title: "مجموعة بيانات NVIDIA Nemotron للتدريب البعدي v1: تحليل شامل لمجموعة بيانات اصطناعية ضخمة لتحسين نماذج اللغة"
excerpt: "مجموعة بيانات اصطناعية من 25.6 مليون عينة صممتها NVIDIA لتحسين قدرات الرياضيات والبرمجة والعلوم والاستدلال واستدعاء الأدوات في نماذج اللغة الكبيرة."
seo_title: "تحليل شامل لمجموعة بيانات NVIDIA Nemotron للتدريب البعدي v1 - Thaki Cloud"
seo_description: "تحليل تفصيلي لمجموعة بيانات NVIDIA Nemotron للتدريب البعدي v1: البنية وتوزيع البيانات لكل فئة ودليل الاستخدام وسير عمل الضبط الدقيق للمجموعة التي تضم 25.6 مليون عينة."
date: 2025-07-31
last_modified_at: 2025-07-31
categories:
  - datasets
  - llmops
tags:
  - NVIDIA
  - Nemotron
  - 데이터셋
  - 합성데이터
  - LLM훈련
  - 파인튜닝
  - HuggingFace
  - 머신러닝
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "database"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/ar/datasets/nvidia-nemotron-post-training-dataset-v1-comprehensive-analysis/"
reading_time: true
lang: ar
published: true
---

⏱️ **وقت القراءة المقدر**: 12 دقائق

## مقدمة

أصدرت NVIDIA مجموعة بيانات **Nemotron Post-Training Dataset v1** في الحادي والثلاثين من يوليو 2025. وهي مجموعة بيانات اصطناعية واسعة النطاق لتحسين أداء نماذج اللغة الكبيرة (LLM)، تضم ما مجموعه **25.66 مليون** عينة عالية الجودة. توفر هذه المجموعة بيانات تدريب تُحسّن بشكل ملحوظ قدرات الرياضيات والبرمجة والعلوم والاستدلال العام واستدعاء الأدوات.

استُخدمت هذه المجموعة في تدريب نموذج **Llama-3.3-Nemotron-Super-49B-v1.5**. ويُعدّ نشر بيانات التدريب الكاملة لضمان الشفافية الكاملة وإمكانية إعادة الإنتاج خطوة ذات قيمة في المجال.

## نظرة عامة على مجموعة البيانات والميزات الرئيسية

### المعلومات الأساسية

| العنصر | التفاصيل |
|------|---------|
| **اسم مجموعة البيانات** | NVIDIA Nemotron Post-Training Dataset v1 |
| **تاريخ الإصدار** | 31 يوليو 2025 |
| **إجمالي العينات** | 25,659,642 |
| **حجم الملف** | 203 GB (Parquet format) |
| **الرخصة** | CC BY 4.0 (مسموح بالاستخدام التجاري وغير التجاري) |
| **المنصة** | Hugging Face Datasets |

### طريقة توليد البيانات

أبرز ما يميز هذه المجموعة أنها **بيانات اصطناعية بنسبة 100%**:

- **المطالبات (Prompts)**: مستخرجة من مصادر عامة أو مولّدة اصطناعيًا
- **الاستجابات (Responses)**: مولّدة اصطناعيًا باستخدام نماذج ذكاء اصطناعي عالية الأداء
- **تصفية الجودة**: إزالة التناقضات والإجابات البسيطة والقواعد النحوية غير الصحيحة

## تحليل تفصيلي لكل فئة

### التوزيع الكلي للبيانات

| الفئة | العينات | النسبة | الاستخدام الأساسي |
|----------|---------|-------|-------------|
| **stem** | 20,662,167 | 80.5% | الاستدلال في العلوم والهندسة والرياضيات |
| **code** | 1,896,395 | 7.4% | تحسين مهارات البرمجة |
| **math** | 2,044,407 | 8.0% | الاستدلال الرياضي والحساب |
| **chat** | 746,622 | 2.9% | التفاعل الحواري |
| **tool_calling** | 310,051 | 1.2% | استدعاء الأدوات واستخدام API |
| **الإجمالي** | **25,659,642** | **100%** | - |

### 1. فئة STEM (20.7 مليون عينة)

الفئة الجوهرية التي تمثل **80.5%** من إجمالي البيانات.

#### المجالات المشمولة
- **العلوم**: الفيزياء والكيمياء والأحياء
- **الهندسة**: مختلف التخصصات الهندسية
- **الرياضيات**: مسائل رياضية متقدمة
- **العلوم الإنسانية**: مسائل الاستدلال العام

#### قالب المطالبة الموصى به
```text
Read the following problem carefully and provide a detailed, step-by-step answer.
{problem}
```

#### حالات الاستخدام
- تحسين قدرات الاستدلال العلمي
- تطوير مهارات حل المسائل المعقدة
- تعزيز مهارات الكتابة الأكاديمية

### 2. فئة الرياضيات - Math (2.0 مليون عينة)

بيانات لتدريب مكثف على قدرة **حل المسائل الرياضية خطوة بخطوة**.

#### الميزات
- تشمل مسائل رياضية معقدة
- تُقدّم عمليات الحل خطوة بخطوة
- تُحدَّد الإجابات النهائية بتنسيق `\boxed{% raw %}{}{% endraw %}`

#### قالب المطالبة الموصى به
```text
Solve the following math problem. Explain your reasoning and put the final answer in \boxed{% raw %}{}{% endraw %}.
{problem}
```

#### تأثيرات التدريب
- تحسين قدرة الاستدلال المنطقي
- تعزيز فهم الرموز الرياضية
- اكتساب منهجية منظمة لحل المسائل

### 3. فئة البرمجة - Code (1.9 مليون عينة)

بيانات توليد أكواد عالية الجودة لـ**تحسين مهارات البرمجة**.

#### تكوين البيانات
- تحديات برمجية
- مسائل خوارزميات
- شرح الأكواد وتحسينها
- دعم لغات برمجة متنوعة

#### قالب المطالبة الموصى به
```text
Write a solution for the following programming challenge. Provide a brief explanation of your approach, followed by the complete code.
{problem}
```

#### مصادر البيانات الخارجية
بعض المطالبات مصدرها مصادر خارجية مثل **OpenCodeReasoning**، وتلك البيانات يجب تنزيلها بشكل منفصل من المصدر الأصلي.

### 4. فئة المحادثة - Chat (747 ألف عينة)

بيانات لتحسين أداء **الذكاء الاصطناعي الحواري**.

#### الميزات
- تدفق حواري طبيعي
- موضوعات ومواقف متنوعة
- أسلوب مساعد ذكاء اصطناعي مفيد وودود

#### مطالبة النظام
```text
You are a helpful and friendly AI assistant.
```

#### تكامل البيانات الخارجية
بعض البيانات مصدرها مجموعة بيانات **lmsys-chat-1m**؛ إذا كان حقل `input` فارغًا، قم بالتنزيل من المصدر الأصلي.

### 5. فئة استدعاء الأدوات - Tool Calling (310 ألف عينة)

بيانات لتحسين قدرات **وكيل الذكاء الاصطناعي** و**تكامل الأدوات**.

#### السيناريوهات المدعومة
- **أحادي الدورة (Single-turn)**: استدعاء أداة واحدة
- **متعدد الدورات (Multi-turn)**: استدعاء أدوات عبر دورات محادثة متعددة
- **متعدد الخطوات (Multi-step)**: استدعاءات أدوات معقدة متعددة الخطوات

#### بنية البيانات الوصفية
- `tools`: تعريفات الأدوات المتاحة
- `tool_calls`: سجلات استدعاءات الأدوات من المساعد

## تحليل نماذج توليد البيانات

### النماذج المستخدمة

| النموذج | العينات المولّدة | النسبة | الميزات |
|-------|------------------|-------|---------|
| **DeepSeek-R1-0528** | 24,602,969 | 95.9% | نموذج التوليد الأساسي |
| **Qwen3-235B-A22B** | 1,056,673 | 4.1% | نموذج التوليد الثانوي |

### ضمان جودة التوليد

1. **التنوع**: استخدام نموذجين مختلفين
2. **تمييز وضع الاستدلال**: توليد الاستجابات مع تشغيل وضع الاستدلال وإيقافه
3. **تصفية الجودة**: التحقق من الاتساق وإزالة الأخطاء

## الاستخدام العملي

### تحميل البيانات عبر Hugging Face Datasets

```python
from datasets import load_dataset

# Load the full dataset
dataset = load_dataset("nvidia/Nemotron-Post-Training-Dataset-v1")

# Load specific categories
code_math_dataset = load_dataset(
    "nvidia/Nemotron-Post-Training-Dataset-v1", 
    split=["code", "math"]
)

# Load individual category
stem_data = load_dataset(
    "nvidia/Nemotron-Post-Training-Dataset-v1", 
    split="stem"
)
```

### فهم بنية البيانات

```python
# Check a data sample
sample = dataset['train'][0]
print("UUID:", sample['uuid'])
print("Category:", sample['category'])
print("License:", sample['license'])
print("Messages:", sample['messages'])
print("Metadata:", sample['metadata'])
```

### إعداد بيانات الضبط الدقيق

```python
def format_chat_sample(sample):
    """Format chat data"""
    messages = sample['messages']
    formatted = f"<s>[INST] {messages[0]['content']} [/INST] {messages[1]['content']}</s>"
    return {"text": formatted}

def format_math_sample(sample):
    """Format math problem"""
    problem = sample['messages'][0]['content']
    solution = sample['messages'][1]['content']
    formatted = f"Solve the following math problem. Explain your reasoning and put the final answer in \\boxed{% raw %}{{}}{% endraw %}.\n{problem}\n\n{solution}"
    return {"text": formatted}

# Apply data transformation
chat_formatted = dataset['chat'].map(format_chat_sample)
math_formatted = dataset['math'].map(format_math_sample)
```

## تقييم الجودة والمعايير المرجعية

### مقاييس جودة البيانات

1. **الاتساق**: الترابط المنطقي بين المطالبات والاستجابات
2. **الدقة**: صحة حلول مسائل الرياضيات والعلوم
3. **التعقيد**: الحفاظ على مستويات صعوبة مناسبة
4. **التنوع**: تنوع الموضوعات والتنسيقات

### نتائج تحسين أداء النموذج

يحقق نموذج **Llama-3.3-Nemotron-Super-49B-v1.5** المدرَّب على هذه المجموعة:
- استدلالًا أكثر كفاءة مقارنة بنموذج Llama-3.3-70B الأصلي
- دعم سياق بطول 128K
- توازن محسَّن بين الدقة والكفاءة

## الرخصة وقيود الاستخدام

### معلومات الرخصة

- **الرخصة**: Creative Commons Attribution 4.0 International (CC BY 4.0)
- **الاستخدام التجاري**: مسموح
- **إعادة التوزيع**: مسموح (مع الإسناد)
- **التعديل**: مسموح

### الاعتبارات الأخلاقية

1. **حماية الخصوصية**: لا تحتوي على بيانات شخصية قابلة للتعريف
2. **مراجعة حقوق الطبع والنشر**: اكتملت المراجعة القانونية
3. **تقليل التحيز**: انعكاس وجهات نظر متنوعة
4. **السلامة**: تصفية المحتوى الضار

### سحب البيانات

في حال اكتشاف مشكلات، يمكن التواصل عبر `ln-dataset@nvidia.com`.

## حالات الاستخدام العملي

### 1. تطوير ذكاء اصطناعي للتعليم الرياضي

```python
# Prepare data for training a math tutor AI
math_subset = load_dataset(
    "nvidia/Nemotron-Post-Training-Dataset-v1", 
    split="math"
)

def create_math_tutor_format(sample):
    problem = sample['messages'][0]['content']
    solution = sample['messages'][1]['content']
    
    return {
        "instruction": "Please solve the following math problem step by step.",
        "input": problem,
        "output": solution
    }

math_tutor_data = math_subset.map(create_math_tutor_format)
```

### 2. تطوير مساعد برمجة

```python
# Prepare data for training a coding assistant AI
code_subset = load_dataset(
    "nvidia/Nemotron-Post-Training-Dataset-v1", 
    split="code"
)

def create_coding_assistant_format(sample):
    problem = sample['messages'][0]['content']
    solution = sample['messages'][1]['content']
    
    return {
        "instruction": "Please solve and explain the following programming problem.",
        "input": problem,
        "output": solution
    }

coding_assistant_data = code_subset.map(create_coding_assistant_format)
```

### 3. تطوير مساعد البحث العلمي

```python
# Training data for a STEM field research assistant AI
stem_subset = load_dataset(
    "nvidia/Nemotron-Post-Training-Dataset-v1", 
    split="stem"
)

def create_research_assistant_format(sample):
    query = sample['messages'][0]['content']
    response = sample['messages'][1]['content']
    
    return {
        "instruction": "Please provide a detailed and accurate response to the scientific question.",
        "input": query,
        "output": response
    }

research_assistant_data = stem_subset.map(create_research_assistant_format)
```

## دليل التنفيذ التقني

### تحسين استخدام ذاكرة GPU

```python
from datasets import load_dataset
import torch

# Improve memory efficiency with batch processing
def process_in_batches(dataset, batch_size=1000):
    for i in range(0, len(dataset), batch_size):
        batch = dataset[i:i+batch_size]
        yield batch

# Streaming load for large datasets
dataset_stream = load_dataset(
    "nvidia/Nemotron-Post-Training-Dataset-v1",
    split="stem",
    streaming=True
)
```

### إعداد المعالجة الموزعة

```python
from datasets import load_dataset
from torch.utils.data import DataLoader
from torch.nn.parallel import DistributedDataParallel

def setup_distributed_data(rank, world_size):
    dataset = load_dataset(
        "nvidia/Nemotron-Post-Training-Dataset-v1",
        split="train"
    )
    
    shard_size = len(dataset) // world_size
    start_idx = rank * shard_size
    end_idx = start_idx + shard_size if rank < world_size - 1 else len(dataset)
    
    return dataset[start_idx:end_idx]
```

### إعداد خط أنابيب التدريب

```python
from transformers import AutoTokenizer, AutoModelForCausalLM, TrainingArguments, Trainer

def setup_training_pipeline():
    model_name = "meta-llama/Llama-3.3-70B-Instruct"
    tokenizer = AutoTokenizer.from_pretrained(model_name)
    model = AutoModelForCausalLM.from_pretrained(model_name)
    
    dataset = load_dataset("nvidia/Nemotron-Post-Training-Dataset-v1")
    
    def tokenize_function(examples):
        return tokenizer(
            examples['text'], 
            truncation=True, 
            padding=True, 
            max_length=2048
        )
    
    tokenized_dataset = dataset.map(tokenize_function, batched=True)
    
    training_args = TrainingArguments(
        output_dir="./nemotron-finetuned",
        num_train_epochs=3,
        per_device_train_batch_size=4,
        gradient_accumulation_steps=8,
        warmup_steps=500,
        weight_decay=0.01,
        logging_dir="./logs",
        logging_steps=100,
        save_steps=1000,
        eval_steps=500,
        evaluation_strategy="steps",
        save_total_limit=3,
        load_best_model_at_end=True,
        metric_for_best_model="eval_loss",
        greater_is_better=False,
        dataloader_num_workers=4,
        fp16=True,
    )
    
    return model, tokenizer, tokenized_dataset, training_args
```

## نصائح تحسين الأداء

### 1. المعالجة الموفرة للذاكرة

```python
def memory_efficient_data_loader(dataset_name, split, chunk_size=10000):
    dataset = load_dataset(dataset_name, split=split, streaming=True)
    
    chunk = []
    for sample in dataset:
        chunk.append(sample)
        if len(chunk) >= chunk_size:
            yield chunk
            chunk = []
    
    if chunk:
        yield chunk

for chunk in memory_efficient_data_loader(
    "nvidia/Nemotron-Post-Training-Dataset-v1", 
    "stem", 
    chunk_size=5000
):
    process_chunk(chunk)
```

### 2. تحسين عملية التحليل إلى رموز

```python
from transformers import AutoTokenizer
import multiprocessing as mp

def parallel_tokenization(dataset, tokenizer, num_processes=8):
    def tokenize_batch(batch):
        return tokenizer(
            batch['text'],
            truncation=True,
            padding=True,
            max_length=2048,
            return_tensors='pt'
        )
    
    with mp.Pool(num_processes) as pool:
        tokenized_batches = pool.map(tokenize_batch, dataset)
    
    return tokenized_batches
```

## التحقق من الجودة والمراقبة

### سكريبت فحص جودة مجموعة البيانات

```python
def validate_dataset_quality(dataset):
    """Validate dataset quality"""
    quality_metrics = {
        'total_samples': len(dataset),
        'avg_input_length': 0,
        'avg_output_length': 0,
        'empty_samples': 0,
        'malformed_samples': 0
    }
    
    input_lengths = []
    output_lengths = []
    
    for sample in dataset:
        try:
            messages = sample['messages']
            if len(messages) != 2:
                quality_metrics['malformed_samples'] += 1
                continue
                
            input_text = messages[0]['content']
            output_text = messages[1]['content']
            
            if not input_text or not output_text:
                quality_metrics['empty_samples'] += 1
                continue
                
            input_lengths.append(len(input_text))
            output_lengths.append(len(output_text))
            
        except Exception as e:
            quality_metrics['malformed_samples'] += 1
            continue
    
    quality_metrics['avg_input_length'] = sum(input_lengths) / len(input_lengths)
    quality_metrics['avg_output_length'] = sum(output_lengths) / len(output_lengths)
    
    return quality_metrics

dataset = load_dataset("nvidia/Nemotron-Post-Training-Dataset-v1", split="math")
metrics = validate_dataset_quality(dataset)
print("Dataset quality metrics:", metrics)
```

## الاستشهاد والمراجع

```bibtex
@misc{bercovich2025llamanemotronefficientreasoningmodels,
      title={Llama-Nemotron: Efficient Reasoning Models}, 
      author={Akhiad Bercovich and Itay Levy and Izik Golan and Mohammad Dabbah and Ran El-Yaniv and Omri Puny and Ido Galil and Zach Moshe and Tomer Ronen and Najeeb Nabwani and Ido Shahaf and Oren Tropp and Ehud Karpas and Ran Zilberstein and Jiaqi Zeng and Soumye Singhal and Alexander Bukharin and Yian Zhang and Tugrul Konuk and Gerald Shen and Ameya Sunil Mahabaleshwarkar and Bilal Kartal and Yoshi Suhara and Olivier Delalleau and Zijia Chen and Zhilin Wang and David Mosallanezhad and Adi Renduchintala and Haifeng Qian and Dima Rekesh and Fei Jia and Somshubra Majumdar and Vahid Noroozi and Wasi Uddin Ahmad and Sean Narenthiran and Aleksander Ficek and Mehrzad Samadi and Jocelyn Huang and Siddhartha Jain and Igor Gitman and Ivan Moshkov and Wei Du and Shubham Toshniwal and George Armstrong and Branislav Kisacanin and Matvei Novikov and Daria Gitman and Evelina Bakhturina and Jane Polak Scowcroft and John Kamalu and Dan Su and Kezhi Kong and Markus Kliegl and Rabeeh Karimi and Ying Lin and Sanjeev Satheesh and Jupinder Parmar and Pritam Gundecha and Brandon Norick and Joseph Jennings and Shrimai Prabhumoye and Syeda Nahida Akter and Mostofa Patwary and Abhinav Khattar and Deepak Narayanan and Roger Waleffe and Jimmy Zhang and Bor-Yiing Su and Guyue Huang and Terry Kong and Parth Chadha and Sahil Jain and Christine Harvey and Elad Segal and Jining Huang and Sergey Kashirsky and Robert McQueen and Izzy Putterman and George Lam and Arun Venkatesan and Sherry Wu and Vinh Nguyen and Manoj Kilaru and Andrew Wang and Anna Warno and Abhilash Somasamudramath and Sandip Bhaskar and Maka Dong and Nave Assaf and Shahar Mor and Omer Ullman Argov and Scot Junkin and Oleksandr Romanenko and Pedro Larroy and Monika Katariya and Marco Rovinelli and Viji Balas and Nicholas Edelman and Anahita Bhiwandiwalla and Muthu Subramaniam and Smita Ithape and Karthik Ramamoorthy and Yuting Wu and Suguna Varshini Velury and Omri Almog and Joyjit Daw and Denys Fridman and Erick Galinkin and Michael Evans and Katherine Luna and Leon Derczynski and Nikki Pope and Eileen Long and Seth Schneider and Guillermo Siman and Tomasz Grzegorzek and Pablo Ribalta and Monika Katariya and Joey Conway and Trisha Saar and Ann Guan and Krzysztof Pawelec and Shyamala Prayaga and Oleksii Kuchaiev and Boris Ginsburg and Oluwatobi Olabiyi and Kari Briski and Jonathan Cohen and Bryan Catanzaro and Jonah Alben and Yonatan Geifman and Eric Chung and Chris Alexiuk},
      year={2025},
      eprint={2505.00949},
      archivePrefix={arXiv},
      primaryClass={cs.CL},
      url={https://arxiv.org/abs/2505.00949}, 
}
```

## الخلاصة

تُعدّ مجموعة بيانات NVIDIA Nemotron Post-Training Dataset v1 مجموعة بيانات اصطناعية واسعة النطاق وعالية الجودة يمكن أن تمثل موردًا ذا قيمة لتحسين نماذج اللغة الكبيرة. أبرز نقاط القوة:

### المزايا الرئيسية

1. **الحجم**: 25.66 مليون عينة
2. **الجودة**: تصفية وتحقق صارمان
3. **التنوع**: خمس فئات رئيسية في تركيب متوازن
4. **الشفافية**: الإفصاح الكامل عن البيانات وعملية التوليد
5. **الاستخدام التجاري**: رخصة CC BY 4.0

### مجالات التطبيق

- **ذكاء اصطناعي للتعليم**: أنظمة تدريس الرياضيات والعلوم
- **مساعدو البرمجة**: ذكاء اصطناعي مساعد في البرمجة
- **أدوات البحث**: أنظمة دعم البحث العلمي
- **ذكاء اصطناعي للأغراض العامة**: نماذج ذات قدرات استدلال أقوى

### التوقعات

يمثل إصدار هذه المجموعة خطوة ذات مغزى نحو مزيد من الشفافية والتعاون في مجال الذكاء الاصطناعي. يمكن للمطورين استخدامها لبناء أنظمة ذكاء اصطناعي أكثر قدرة وموثوقية.

---

### روابط مرجعية

- [الصفحة الرسمية لمجموعة بيانات NVIDIA Nemotron](https://huggingface.co/datasets/nvidia/Nemotron-Post-Training-Dataset-v1)
- [ورقة ArXiv](https://arxiv.org/abs/2505.00949)
- [توثيق Hugging Face Datasets](https://huggingface.co/docs/datasets/)
- [رخصة CC BY 4.0](https://creativecommons.org/licenses/by/4.0/legalcode)
