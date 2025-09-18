---
title: "FinePDFs: الدليل الشامل لمجموعة بيانات PDF الثورية من Hugging Face"
excerpt: "إتقان مجموعة بيانات FinePDFs التي تحتوي على 4.7 مليون وثيقة. تعلم الاستخراج والتصفية والتدريب بأمثلة شاملة وأفضل الممارسات."
seo_title: "شرح FinePDFs: الدليل الكامل لمعالجة مجموعة بيانات PDF - Thaki Cloud"
seo_description: "تعلم كيفية استخدام مجموعة بيانات FinePDFs بفعالية مع أمثلة عملية ونصائح تحسين وتطبيقات واقعية لتدريب الذكاء الاصطناعي والبحث."
date: 2025-09-09
categories:
  - tutorials
tags:
  - FinePDFs
  - HuggingFace
  - معالجة-PDF
  - مجموعة-بيانات
  - التعلم-الآلي
  - استخراج-النص
  - علوم-البيانات
author_profile: true
toc: true
toc_label: "المحتويات"
lang: ar
permalink: /ar/tutorials/finepdfs-comprehensive-tutorial-guide/
canonical_url: "https://thakicloud.github.io/ar/tutorials/finepdfs-comprehensive-tutorial-guide/"
---

⏱️ **وقت القراءة المقدر**: 12 دقيقة

## مقدمة

تمثل FinePDFs تقدماً ثورياً في مجال معالجة الوثائق واسعة النطاق، حيث تقدم 4.7 مليون وثيقة PDF مستخرجة بحجم إجمالي 67.9 جيجابايت من البيانات النصية عالية الجودة. سيرشدك هذا البرنامج التعليمي الشامل عبر جميع جوانب العمل مع مجموعة البيانات الثورية هذه.

### ما يجعل FinePDFs مميزة؟

تبرز [FinePDFs](https://huggingface.co/datasets/HuggingFaceFW/finepdfs) كإحدى أشمل مجموعات البيانات المستمدة من ملفات PDF المتاحة، حيث تتميز بـ:

- **نطاق ضخم**: 4.7 مليون وثيقة عبر 1,808 لغة
- **استخراج متقدم**: تستخدم تقنيات docling و RolmOCR المتطورة
- **غنية بالمجالات**: تغطية واسعة للمحتوى العلمي والقانوني والتقني
- **ترخيص مفتوح**: ترخيص ODC-By للاستخدام التجاري والبحثي
- **تركيز الجودة**: تصفية أدنى للحفاظ على تنوع المحتوى الأصيل

## المتطلبات المسبقة والإعداد

### متطلبات البيئة

```bash
# Python 3.8+ موصى به
python --version

# الحزم المطلوبة
pip install datasets transformers torch huggingface_hub
pip install pandas numpy matplotlib seaborn
pip install tqdm rich
```

### توصيات الأجهزة

- **ذاكرة الوصول العشوائي**: الحد الأدنى 16 جيجابايت، موصى به 32 جيجابايت+
- **التخزين**: مساحة حرة 100 جيجابايت+ لمجموعة البيانات الكاملة
- **الشبكة**: إنترنت مستقر للتحميل الأولي
- **GPU**: اختياري ولكن موصى به للمعالجة

## البدء مع FinePDFs

### تحميل مجموعة البيانات الأساسي

```python
from datasets import load_dataset
import pandas as pd
from collections import Counter
import matplotlib.pyplot as plt

# تحميل مجموعة البيانات (البدء بالمجموعة الفرعية الإنجليزية)
print("تحميل مجموعة بيانات FinePDFs...")
dataset = load_dataset("HuggingFaceFW/finepdfs", "eng_Latn")

print(f"حجم مجموعة البيانات: {len(dataset['train'])} وثيقة")
print(f"الأعمدة المتاحة: {dataset['train'].column_names}")

# فحص العينات الأولى
for i, sample in enumerate(dataset['train'].take(3)):
    print(f"\n--- العينة {i+1} ---")
    print(f"اللغة: {sample['language']}")
    print(f"طول النص: {len(sample['text'])} حرف")
    print(f"معاينة النص: {sample['text'][:200]}...")
```

### استكشاف اللغات المتاحة

```python
# تحميل البيانات الوصفية للغات
all_configs = ["eng_Latn", "arb_Arab", "spa_Latn", "fra_Latn", "deu_Latn", 
               "ita_Latn", "por_Latn", "rus_Cyrl", "jpn_Jpan", "kor_Hang"]

language_stats = {}

for config in all_configs[:5]:  # عينة من أول 5 لغات
    try:
        ds = load_dataset("HuggingFaceFW/finepdfs", config, split="train")
        language_stats[config] = len(ds)
        print(f"{config}: {len(ds):,} وثيقة")
    except Exception as e:
        print(f"فشل تحميل {config}: {e}")

# تصور توزيع اللغات
plt.figure(figsize=(12, 6))
languages = list(language_stats.keys())
counts = list(language_stats.values())

plt.bar(languages, counts)
plt.title("عدد الوثائق حسب اللغة")
plt.xlabel("رمز اللغة")
plt.ylabel("عدد الوثائق")
plt.xticks(rotation=45)
plt.tight_layout()
plt.savefig("finepdfs_language_distribution.png", dpi=300, bbox_inches='tight')
plt.show()
```

## عمليات مجموعة البيانات المتقدمة

### تحليل جودة النص

```python
import re
from textstat import flesch_reading_ease, flesch_kincaid_grade

def analyze_text_quality(sample_texts, sample_size=1000):
    """تحليل مقاييس جودة النص لعينات مجموعة البيانات"""
    
    metrics = {
        'avg_length': [],
        'word_count': [],
        'sentence_count': [],
        'reading_ease': [],
        'grade_level': [],
        'special_chars_ratio': []
    }
    
    for text in sample_texts[:sample_size]:
        # المقاييس الأساسية
        text_length = len(text)
        word_count = len(text.split())
        sentence_count = len(re.split(r'[.!?]+', text))
        
        # مقاييس القراءة (التعامل مع الأخطاء)
        try:
            reading_ease = flesch_reading_ease(text)
            grade_level = flesch_kincaid_grade(text)
        except:
            reading_ease = grade_level = 0
        
        # نسبة الأحرف الخاصة
        special_chars = len(re.findall(r'[^\w\s]', text))
        special_ratio = special_chars / max(text_length, 1)
        
        # حفظ المقاييس
        metrics['avg_length'].append(text_length)
        metrics['word_count'].append(word_count)
        metrics['sentence_count'].append(sentence_count)
        metrics['reading_ease'].append(reading_ease)
        metrics['grade_level'].append(grade_level)
        metrics['special_chars_ratio'].append(special_ratio)
    
    return metrics

# تحليل جودة مجموعة البيانات
print("تحليل جودة النص...")
sample_texts = [item['text'] for item in dataset['train'].take(1000)]
quality_metrics = analyze_text_quality(sample_texts)

# عرض النتائج
for metric, values in quality_metrics.items():
    avg_value = sum(values) / len(values)
    print(f"{metric}: {avg_value:.2f}")
```

### التصفية حسب المجال

```python
def filter_by_domain(dataset, domain_keywords, min_matches=2):
    """تصفية مجموعة البيانات بناءً على الكلمات المفتاحية للمجال"""
    
    def contains_domain_keywords(example):
        text_lower = example['text'].lower()
        matches = sum(1 for keyword in domain_keywords if keyword in text_lower)
        return matches >= min_matches
    
    filtered_dataset = dataset.filter(contains_domain_keywords)
    return filtered_dataset

# مثال: تصفية المحتوى العلمي
scientific_keywords = [
    'research', 'study', 'analysis', 'experiment', 'hypothesis',
    'methodology', 'results', 'conclusion', 'peer review',
    'journal', 'publication', 'citation', 'abstract'
]

print("تصفية المحتوى العلمي...")
scientific_subset = filter_by_domain(dataset['train'], scientific_keywords)
print(f"الوثائق العلمية: {len(scientific_subset)} / {len(dataset['train'])}")

# مثال: تصفية المحتوى القانوني
legal_keywords = [
    'court', 'judge', 'law', 'legal', 'statute', 'regulation',
    'contract', 'agreement', 'plaintiff', 'defendant',
    'jurisdiction', 'litigation', 'attorney'
]

legal_subset = filter_by_domain(dataset['train'], legal_keywords)
print(f"الوثائق القانونية: {len(legal_subset)} / {len(dataset['train'])}")
```

## التطبيقات العملية

### 1. تدريب نموذج لغوي

```python
from transformers import AutoTokenizer, AutoModelForCausalLM, TrainingArguments, Trainer
import torch

def prepare_training_data(dataset, tokenizer, max_length=512):
    """إعداد مجموعة البيانات لتدريب النموذج اللغوي"""
    
    def tokenize_function(examples):
        # تمييز النصوص
        tokenized = tokenizer(
            examples['text'],
            truncation=True,
            padding=True,
            max_length=max_length,
            return_tensors="pt"
        )
        # تعيين التسميات للنموذج السببي
        tokenized["labels"] = tokenized["input_ids"].clone()
        return tokenized
    
    tokenized_dataset = dataset.map(
        tokenize_function,
        batched=True,
        remove_columns=dataset.column_names
    )
    
    return tokenized_dataset

# تهيئة المرمز والنموذج
model_name = "distilgpt2"  # نموذج خفيف للعرض التوضيحي
tokenizer = AutoTokenizer.from_pretrained(model_name)
tokenizer.pad_token = tokenizer.eos_token

model = AutoModelForCausalLM.from_pretrained(model_name)

# إعداد بيانات التدريب (استخدام مجموعة فرعية صغيرة للعرض التوضيحي)
print("إعداد بيانات التدريب...")
train_subset = dataset['train'].select(range(1000))  # عينة صغيرة
tokenized_data = prepare_training_data(train_subset, tokenizer)

# إعدادات التدريب
training_args = TrainingArguments(
    output_dir="./finepdfs-model",
    num_train_epochs=1,
    per_device_train_batch_size=4,
    gradient_accumulation_steps=2,
    warmup_steps=100,
    logging_steps=50,
    save_steps=500,
    evaluation_strategy="no",
    save_total_limit=2,
    load_best_model_at_end=False,
)

# تهيئة المدرب
trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=tokenized_data,
    tokenizer=tokenizer,
)

print("بدء التدريب... (قد يستغرق وقتاً طويلاً)")
# trainer.train()  # إلغاء التعليق للتدريب الفعلي
print("إعداد التدريب جاهز!")
```

### 2. البحث عن تشابه الوثائق

```python
from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity
import numpy as np

def create_document_embeddings(texts, model_name="all-MiniLM-L6-v2"):
    """إنشاء التضمينات للبحث عن تشابه الوثائق"""
    
    model = SentenceTransformer(model_name)
    
    # المعالجة بدفعات لإدارة الذاكرة
    batch_size = 32
    embeddings = []
    
    for i in range(0, len(texts), batch_size):
        batch_texts = texts[i:i+batch_size]
        batch_embeddings = model.encode(batch_texts, show_progress_bar=True)
        embeddings.extend(batch_embeddings)
    
    return np.array(embeddings), model

def find_similar_documents(query, embeddings, texts, model, top_k=5):
    """العثور على الوثائق الأكثر تشابهاً مع الاستعلام"""
    
    # ترميز الاستعلام
    query_embedding = model.encode([query])
    
    # حساب أوجه التشابه
    similarities = cosine_similarity(query_embedding, embeddings)[0]
    
    # الحصول على أفضل k مؤشرات
    top_indices = np.argsort(similarities)[-top_k:][::-1]
    
    results = []
    for idx in top_indices:
        results.append({
            'index': idx,
            'similarity': similarities[idx],
            'text': texts[idx][:200] + "..."
        })
    
    return results

# مثال على الاستخدام
print("إنشاء تضمينات الوثائق...")
sample_texts = [item['text'] for item in dataset['train'].take(100)]
embeddings, model = create_document_embeddings(sample_texts)

# البحث عن وثائق متشابهة
query = "خوارزميات التعلم الآلي والذكاء الاصطناعي"
similar_docs = find_similar_documents(query, embeddings, sample_texts, model)

print(f"\nأفضل الوثائق المتشابهة لـ: '{query}'")
for i, doc in enumerate(similar_docs):
    print(f"\n{i+1}. التشابه: {doc['similarity']:.3f}")
    print(f"النص: {doc['text']}")
```

### 3. التحليل متعدد اللغات

```python
def analyze_multilingual_content(language_configs, sample_size=500):
    """تحليل المحتوى عبر عدة لغات"""
    
    results = {}
    
    for lang_config in language_configs:
        try:
            print(f"تحميل {lang_config}...")
            ds = load_dataset("HuggingFaceFW/finepdfs", lang_config, split="train")
            
            # أخذ عينة من الوثائق
            sample = ds.take(min(sample_size, len(ds)))
            texts = [item['text'] for item in sample]
            
            # حساب الإحصائيات
            avg_length = sum(len(text) for text in texts) / len(texts)
            avg_words = sum(len(text.split()) for text in texts) / len(texts)
            
            results[lang_config] = {
                'total_docs': len(ds),
                'avg_length': avg_length,
                'avg_words': avg_words,
                'sample_text': texts[0][:100] + "..." if texts else ""
            }
            
        except Exception as e:
            print(f"خطأ في تحميل {lang_config}: {e}")
            results[lang_config] = {'error': str(e)}
    
    return results

# تحليل عدة لغات
multilingual_configs = ["eng_Latn", "arb_Arab", "spa_Latn", "fra_Latn"]
multilingual_analysis = analyze_multilingual_content(multilingual_configs)

# عرض النتائج
for lang, stats in multilingual_analysis.items():
    print(f"\n--- {lang} ---")
    if 'error' in stats:
        print(f"خطأ: {stats['error']}")
    else:
        print(f"إجمالي الوثائق: {stats['total_docs']:,}")
        print(f"متوسط الطول: {stats['avg_length']:.0f} حرف")
        print(f"متوسط الكلمات: {stats['avg_words']:.0f}")
        print(f"عينة: {stats['sample_text']}")
```

## تحسين الأداء

### إدارة الذاكرة

```python
import gc
from datasets import Dataset

def process_large_dataset_in_chunks(dataset, chunk_size=1000, process_func=None):
    """معالجة مجموعات البيانات الكبيرة بطريقة فعالة للذاكرة"""
    
    total_size = len(dataset)
    results = []
    
    for i in range(0, total_size, chunk_size):
        print(f"معالجة الجزء {i//chunk_size + 1}/{(total_size-1)//chunk_size + 1}")
        
        # الحصول على الجزء
        chunk = dataset.select(range(i, min(i + chunk_size, total_size)))
        
        # معالجة الجزء
        if process_func:
            chunk_result = process_func(chunk)
            results.append(chunk_result)
        
        # فرض جمع القمامة
        gc.collect()
    
    return results

def chunk_text_analysis(chunk):
    """مثال على دالة المعالجة للأجزاء"""
    texts = [item['text'] for item in chunk]
    
    return {
        'chunk_size': len(texts),
        'avg_length': sum(len(text) for text in texts) / len(texts),
        'total_chars': sum(len(text) for text in texts)
    }

# مثال: معالجة مجموعة البيانات بأجزاء فعالة للذاكرة
print("معالجة مجموعة البيانات بأجزاء فعالة للذاكرة...")
chunk_results = process_large_dataset_in_chunks(
    dataset['train'].select(range(5000)),  # استخدام مجموعة فرعية للعرض التوضيحي
    chunk_size=1000,
    process_func=chunk_text_analysis
)

for i, result in enumerate(chunk_results):
    print(f"الجزء {i+1}: {result}")
```

### التدفق للمجموعات الكبيرة

```python
from datasets import load_dataset

def stream_process_dataset(dataset_name, config, process_func, max_items=None):
    """معالجة مجموعة البيانات بالتدفق دون تحميل في الذاكرة"""
    
    # تحميل كمجموعة بيانات تدفق
    dataset = load_dataset(dataset_name, config, streaming=True, split="train")
    
    processed_count = 0
    results = []
    
    for item in dataset:
        if max_items and processed_count >= max_items:
            break
        
        result = process_func(item)
        results.append(result)
        processed_count += 1
        
        if processed_count % 100 == 0:
            print(f"تمت معالجة {processed_count} عنصر...")
    
    return results

def extract_keywords(item):
    """مثال على دالة المعالجة"""
    text = item['text'].lower()
    # استخراج كلمات مفتاحية بسيط (يمكن استبداله بطرق أكثر تطوراً)
    keywords = []
    for word in ['ai', 'machine learning', 'neural network', 'algorithm']:
        if word in text:
            keywords.append(word)
    return {'keywords': keywords, 'text_length': len(text)}

# مثال: معالجة التدفق
print("معالجة مجموعة البيانات بالتدفق...")
stream_results = stream_process_dataset(
    "HuggingFaceFW/finepdfs", 
    "eng_Latn",
    extract_keywords,
    max_items=1000
)

print(f"تمت معالجة {len(stream_results)} عنصر عبر التدفق")
```

## حالات الاستخدام المتقدمة

### 1. بناء مجموعة نصوص خاصة بالمجال

```python
def build_domain_corpus(dataset, domain_rules, output_path=None):
    """بناء مجموعة نصوص متخصصة بناءً على قواعد المجال"""
    
    def evaluate_domain_match(text, rules):
        score = 0
        text_lower = text.lower()
        
        # الكلمات المفتاحية المطلوبة (يجب وجود واحدة على الأقل)
        required = rules.get('required', [])
        if required and any(keyword in text_lower for keyword in required):
            score += 2
        elif required:  # توجد كلمات مفتاحية مطلوبة لكن لم توجد
            return 0
        
        # كلمات مفتاحية مكافئة
        bonus = rules.get('bonus', [])
        for keyword in bonus:
            if keyword in text_lower:
                score += 1
        
        # كلمات مفتاحية جزائية
        penalty = rules.get('penalty', [])
        for keyword in penalty:
            if keyword in text_lower:
                score -= 2
        
        return max(0, score)
    
    # تعريف قواعد المجال
    scientific_rules = {
        'required': ['research', 'study', 'analysis', 'experiment'],
        'bonus': ['peer review', 'methodology', 'hypothesis', 'statistical'],
        'penalty': ['advertisement', 'promotional', 'buy now']
    }
    
    # تسجيل وتصفية الوثائق
    scored_docs = []
    for item in dataset:
        score = evaluate_domain_match(item['text'], scientific_rules)
        if score >= 3:  # حد أدنى للنقاط
            scored_docs.append({
                'text': item['text'],
                'language': item.get('language', 'unknown'),
                'domain_score': score
            })
    
    print(f"تم بناء مجموعة نصوص المجال مع {len(scored_docs)} وثيقة")
    
    if output_path:
        # حفظ المجموعة
        import json
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(scored_docs, f, ensure_ascii=False, indent=2)
        print(f"تم حفظ المجموعة في {output_path}")
    
    return scored_docs

# بناء مجموعة نصوص علمية
scientific_corpus = build_domain_corpus(
    dataset['train'].take(2000),  # استخدام مجموعة فرعية للعرض التوضيحي
    {},  # القواعد معرفة في الدالة
    "scientific_corpus.json"
)
```

### 2. خط أنابيب تقييم الجودة

```python
def assess_document_quality(text):
    """تقييم شامل لجودة الوثائق"""
    
    # المقاييس الأساسية
    char_count = len(text)
    word_count = len(text.split())
    sentence_count = len(re.split(r'[.!?]+', text))
    
    # مؤشرات الجودة
    quality_score = 0
    issues = []
    
    # فحوصات الطول
    if word_count < 50:
        issues.append("قصير جداً")
        quality_score -= 2
    elif word_count > 100:
        quality_score += 1
    
    # فحوصات التماسك
    avg_word_length = sum(len(word) for word in text.split()) / max(word_count, 1)
    if avg_word_length > 6:
        issues.append("مفردات معقدة بشكل مفرط")
        quality_score -= 1
    
    # تنوع المحتوى
    unique_words = len(set(text.lower().split()))
    diversity_ratio = unique_words / max(word_count, 1)
    if diversity_ratio > 0.7:
        quality_score += 2
    elif diversity_ratio < 0.3:
        issues.append("تنوع مفردات منخفض")
        quality_score -= 1
    
    # ضوضاء الأحرف الخاصة
    special_char_ratio = len(re.findall(r'[^\w\s]', text)) / max(char_count, 1)
    if special_char_ratio > 0.3:
        issues.append("ضوضاء عالية من الأحرف الخاصة")
        quality_score -= 2
    
    return {
        'quality_score': quality_score,
        'issues': issues,
        'metrics': {
            'char_count': char_count,
            'word_count': word_count,
            'sentence_count': sentence_count,
            'diversity_ratio': diversity_ratio,
            'special_char_ratio': special_char_ratio
        }
    }

# تقييم الجودة عبر عينة من مجموعة البيانات
print("تقييم جودة الوثائق...")
quality_results = []

for item in dataset['train'].take(500):
    quality = assess_document_quality(item['text'])
    quality_results.append(quality)

# تحليل توزيع الجودة
quality_scores = [result['quality_score'] for result in quality_results]
avg_quality = sum(quality_scores) / len(quality_scores)
high_quality_count = sum(1 for score in quality_scores if score >= 2)

print(f"متوسط نقاط الجودة: {avg_quality:.2f}")
print(f"وثائق عالية الجودة: {high_quality_count}/{len(quality_results)}")
print(f"توزيع الجودة: {Counter(quality_scores)}")
```

## الاختبار والتحقق

### نص اختبار شامل

```python
#!/usr/bin/env python3
"""
نص اختبار مجموعة بيانات FinePDFs
يتحقق من وظائف تحميل ومعالجة وتحليل مجموعة البيانات
"""

import sys
import time
import traceback
from datasets import load_dataset
import pandas as pd
import numpy as np

def test_basic_loading():
    """اختبار وظيفة تحميل مجموعة البيانات الأساسية"""
    print("اختبار تحميل مجموعة البيانات الأساسي...")
    try:
        dataset = load_dataset("HuggingFaceFW/finepdfs", "eng_Latn", split="train")
        print(f"✓ تم تحميل مجموعة البيانات بنجاح مع {len(dataset)} وثيقة")
        
        # اختبار الوصول للبيانات
        first_item = dataset[0]
        required_fields = ['text', 'language']
        for field in required_fields:
            if field not in first_item:
                raise ValueError(f"حقل مطلوب مفقود: {field}")
        
        print("✓ تم اجتياز التحقق من بنية مجموعة البيانات")
        return True
        
    except Exception as e:
        print(f"✗ فشل اختبار التحميل الأساسي: {e}")
        return False

def test_processing_functions():
    """اختبار دوال معالجة وتحليل البيانات"""
    print("\nاختبار دوال المعالجة...")
    try:
        # تحميل عينة صغيرة
        dataset = load_dataset("HuggingFaceFW/finepdfs", "eng_Latn", split="train")
        sample = dataset.take(10)
        
        # اختبار تحليل النص
        texts = [item['text'] for item in sample]
        avg_length = sum(len(text) for text in texts) / len(texts)
        
        if avg_length == 0:
            raise ValueError("نتائج تحليل النص غير صحيحة")
        
        print(f"✓ تحليل النص ناجح (متوسط الطول: {avg_length:.0f})")
        
        # اختبار التصفية
        filtered = [text for text in texts if len(text) > 100]
        print(f"✓ التصفية ناجحة ({len(filtered)}/{len(texts)} وثيقة)")
        
        return True
        
    except Exception as e:
        print(f"✗ فشل اختبار دوال المعالجة: {e}")
        return False

def test_memory_efficiency():
    """اختبار كفاءة الذاكرة"""
    print("\nاختبار كفاءة الذاكرة...")
    try:
        # اختبار معالجة التدفق
        dataset = load_dataset("HuggingFaceFW/finepdfs", "eng_Latn", 
                             streaming=True, split="train")
        
        count = 0
        for item in dataset:
            count += 1
            if count >= 5:  # اختبار أول 5 عناصر
                break
        
        if count != 5:
            raise ValueError("فشل معالجة التدفق")
        
        print("✓ معالجة التدفق ناجحة")
        return True
        
    except Exception as e:
        print(f"✗ فشل اختبار كفاءة الذاكرة: {e}")
        return False

def run_all_tests():
    """تشغيل مجموعة اختبارات شاملة"""
    print("=" * 50)
    print("مجموعة اختبارات مجموعة بيانات FinePDFs")
    print("=" * 50)
    
    tests = [
        test_basic_loading,
        test_processing_functions,
        test_memory_efficiency
    ]
    
    results = []
    start_time = time.time()
    
    for test in tests:
        try:
            result = test()
            results.append(result)
        except Exception as e:
            print(f"✗ اختبار {test.__name__} تعطل: {e}")
            traceback.print_exc()
            results.append(False)
    
    # الملخص
    print("\n" + "=" * 50)
    print("ملخص الاختبار")
    print("=" * 50)
    
    passed = sum(results)
    total = len(results)
    
    print(f"الاختبارات المجتازة: {passed}/{total}")
    print(f"معدل النجاح: {passed/total*100:.1f}%")
    print(f"إجمالي الوقت: {time.time() - start_time:.1f} ثانية")
    
    if passed == total:
        print("🎉 جميع الاختبارات اجتازت!")
        return True
    else:
        print("⚠️  بعض الاختبارات فشلت. تحقق من الإخراج أعلاه.")
        return False

if __name__ == "__main__":
    success = run_all_tests()
    sys.exit(0 if success else 1)
```

## أفضل الممارسات والنصائح

### 1. تحميل البيانات بكفاءة

```python
# أفضل ممارسة: استخدام المجموعات الفرعية المناسبة
def load_dataset_efficiently(language_code, max_size=None):
    """تحميل مجموعة البيانات بإعدادات مثلى"""
    
    try:
        if max_size and max_size < 10000:
            # مجموعة بيانات صغيرة: تحميل كامل
            dataset = load_dataset("HuggingFaceFW/finepdfs", language_code, 
                                 split=f"train[:{max_size}]")
        else:
            # مجموعة بيانات كبيرة: استخدام التدفق
            dataset = load_dataset("HuggingFaceFW/finepdfs", language_code, 
                                 streaming=True, split="train")
        
        return dataset
        
    except Exception as e:
        print(f"فشل تحميل {language_code}: {e}")
        return None

# مثال على الاستخدام
efficient_dataset = load_dataset_efficiently("eng_Latn", max_size=5000)
```

### 2. التعامل مع الأخطاء والمتانة

```python
def robust_text_processing(text, max_retries=3):
    """معالجة النص مع التعامل مع الأخطاء والمحاولات المتكررة"""
    
    for attempt in range(max_retries):
        try:
            # التحقق من الإدخال
            if not isinstance(text, str):
                raise TypeError("الإدخال يجب أن يكون نص")
            
            if len(text) == 0:
                return {"status": "empty", "result": None}
            
            # معالجة النص
            processed = {
                "length": len(text),
                "word_count": len(text.split()),
                "status": "success"
            }
            
            return processed
            
        except Exception as e:
            print(f"المحاولة {attempt + 1} فشلت: {e}")
            if attempt == max_retries - 1:
                return {"status": "failed", "error": str(e)}
            
            time.sleep(0.1)  # تأخير قصير قبل المحاولة مرة أخرى

# مثال على الاستخدام مع التعامل مع الأخطاء
def process_dataset_safely(dataset, max_items=1000):
    """معالجة مجموعة البيانات مع التعامل الشامل مع الأخطاء"""
    
    successful = 0
    failed = 0
    results = []
    
    for i, item in enumerate(dataset.take(max_items)):
        try:
            result = robust_text_processing(item['text'])
            if result['status'] == 'success':
                successful += 1
                results.append(result)
            else:
                failed += 1
                
        except Exception as e:
            print(f"فشل معالجة العنصر {i}: {e}")
            failed += 1
    
    print(f"اكتملت المعالجة: {successful} نجح، {failed} فشل")
    return results
```

## الخلاصة

تمثل FinePDFs تحولاً جذرياً في التعلم الآلي القائم على الوثائق، حيث تقدم وصولاً غير مسبوق إلى محتوى نصي عالي الجودة ومتنوع. غطى هذا البرنامج التعليمي:

### النقاط الرئيسية

1. **إتقان مجموعة البيانات**: فهم بنية ووظائف FinePDFs
2. **المعالجة الفعالة**: تقنيات واعية بالذاكرة للعمليات واسعة النطاق
3. **التطبيقات العملية**: حالات استخدام واقعية من التدريب إلى التحليل
4. **تقييم الجودة**: طرق لتقييم وتصفية المحتوى
5. **الدعم متعدد اللغات**: الاستفادة من التنوع اللغوي لمجموعة البيانات

### الخطوات التالية

- **التجريب**: جرب تكوينات لغات مختلفة ومرشحات المجال
- **التوسع**: طبق التقنيات على مجموعات فرعية أكبر حسب ما تسمح به البنية التحتية
- **التكامل**: ادمج FinePDFs في خطوط أنابيب التعلم الآلي الموجودة
- **المساهمة**: شارك التحسينات والاكتشافات مع المجتمع

### المصادر

- [صفحة مجموعة بيانات FinePDFs](https://huggingface.co/datasets/HuggingFaceFW/finepdfs)
- [وثائق Hugging Face Datasets](https://huggingface.co/docs/datasets/)
- [معالجة PDF باستخدام Docling](https://github.com/DS4SD/docling)

مستقبل الذكاء الاصطناعي القائم على الوثائق هنا مع FinePDFs. ابدأ البناء اليوم! 🚀

---

*هل لديك أسئلة أو تعليقات؟ انضم إلى النقاش في منتديات مجتمع Hugging Face أو ساهم في التطوير المستمر لمجموعة البيانات.*
