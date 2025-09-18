---
title: "FlashRAG: دليل شامل للبحث الفعال في RAG"
excerpt: "دليل شامل لـ FlashRAG - مجموعة أدوات Python المعيارية لبحث الاسترجاع المدعم بالتوليد مع أمثلة عملية ونصائح التنفيذ."
seo_title: "FlashRAG Tutorial: دليل أدوات بحث RAG - Thaki Cloud"
seo_description: "تعلم كيفية استخدام FlashRAG للبحث الفعال في RAG. دليل شامل مع التثبيت والتكوين ومعالجة مجموعات البيانات والأمثلة العملية."
date: 2025-09-18
categories:
  - tutorials
tags:
  - FlashRAG
  - RAG
  - الاسترجاع-المدعم-بالتوليد
  - التعلم-الآلي
  - Python
  - LLM
author_profile: true
toc: true
toc_label: "جدول المحتويات"
canonical_url: "https://thakicloud.github.io/ar/tutorials/flashrag-tutorial/"
lang: ar
permalink: /ar/tutorials/flashrag-tutorial/
---

⏱️ **وقت القراءة المتوقع**: 12 دقيقة

## مقدمة عن FlashRAG

FlashRAG هي مجموعة أدوات Python قوية مصممة خصيصاً للبحث الفعال في مجال الاسترجاع المدعم بالتوليد (Retrieval-Augmented Generation, RAG). تم تطوير هذا الإطار المعياري من قبل RUC-NLPIR، ويوفر للباحثين والمطورين أدوات شاملة لتنفيذ وتقييم وتجريب مختلف منهجيات RAG.

### ما يميز FlashRAG

يبرز FlashRAG في مشهد بحث RAG لعدة أسباب رئيسية:

**هيكل معياري**: تتبع مجموعة الأدوات تصميماً قائماً على المكونات يسمح للباحثين بتبديل طرق الاسترجاع المختلفة ونماذج التوليد ومقاييس التقييم بسهولة دون إعادة هيكلة خط الأنابيب بالكامل.

**دعم شامل للطرق**: ينفذ FlashRAG العديد من تقنيات RAG المتطورة بما في ذلك self-RAG و RAPTOR و HyDE وغيرها الكثير، مما يجعله حلاً شاملاً لتجارب RAG.

**تكامل واسع مع مجموعات البيانات**: يأتي الإطار مع دعم مدمج لأكثر من 30 مجموعة بيانات شائعة بما في ذلك Natural Questions (NQ) و TriviaQA و HotpotQA و MS MARCO، مع بروتوكولات المعالجة المسبقة والتقييم المعيارية.

**تصميم موجه للبحث**: على عكس أطر RAG المركزة على الإنتاج، فإن FlashRAG مصمم خصيصاً للبحث الأكاديمي، حيث يوفر مقاييس تقييم مفصلة وإعدادات تجريبية قابلة للإعادة وقدرات معايرة شاملة.

## متطلبات النظام والتثبيت

### المتطلبات المسبقة

قبل تثبيت FlashRAG، تأكد من أن نظامك يلبي المتطلبات التالية:

- **Python**: الإصدار 3.8 أو أحدث
- **نظام التشغيل**: Linux أو macOS أو Windows
- **الذاكرة**: 8 جيجابايت على الأقل من ذاكرة الوصول العشوائي (16 جيجابايت موصى بها لمجموعات البيانات الكبيرة)
- **التخزين**: 50 جيجابايت+ مساحة فارغة لمجموعات البيانات والفهارس
- **GPU**: اختياري ولكن موصى به لاستنتاج النماذج الأسرع

### دليل التثبيت خطوة بخطوة

**الخطوة 1: إعداد البيئة**

أولاً، قم بإنشاء بيئة افتراضية لعزل تبعيات FlashRAG:

```bash
# إنشاء بيئة افتراضية
python -m venv flashrag_env

# تفعيل البيئة (Linux/macOS)
source flashrag_env/bin/activate

# تفعيل البيئة (Windows)
flashrag_env\Scripts\activate
```

**الخطوة 2: تثبيت FlashRAG**

قم بتثبيت FlashRAG باستخدام pip من المستودع الرسمي:

```bash
# التثبيت من PyPI (موصى به)
pip install flashrag

# البديل: التثبيت من المصدر
git clone https://github.com/RUC-NLPIR/FlashRAG.git
cd FlashRAG
pip install -e .
```

**الخطوة 3: تثبيت التبعيات الإضافية**

اعتماداً على حالة الاستخدام الخاصة بك، قد تحتاج إلى حزم إضافية:

```bash
# لنماذج الاسترجاع المتقدمة
pip install sentence-transformers faiss-cpu

# لتسريع GPU (إذا كان متاحاً)
pip install faiss-gpu torch

# لواجهة الويب
pip install gradio streamlit
```

**الخطوة 4: التحقق من التثبيت**

اختبر تثبيتك بنص تحقق بسيط:

```python
import flashrag
from flashrag.config import Config
from flashrag.utils import get_logger

print(f"إصدار FlashRAG: {flashrag.__version__}")
logger = get_logger(__name__)
logger.info("تم تثبيت FlashRAG بنجاح!")
```

## المكونات الأساسية والهيكل

يتكون الهيكل المعياري لـ FlashRAG من عدة مكونات رئيسية تعمل معاً لإنشاء بيئة بحث RAG مرنة.

### 1. مكونات المسترجع

يتعامل مكون المسترجع مع عملية استرجاع الوثائق. يدعم FlashRAG طرق استرجاع متعددة:

**المسترجعات الكثيفة**: تشمل النماذج المبنية على BERT و DPR (Dense Passage Retrieval) ونماذج التضمين الحديثة مثل E5 و BGE.

**المسترجعات المتناثرة**: الطرق التقليدية مثل BM25 و TF-IDF للمقارنات الأساسية والنهج المختلطة.

**المسترجعات المختلطة**: الجمع بين الطرق الكثيفة والمتناثرة لتحسين أداء الاسترجاع.

```python
from flashrag.retriever import DenseRetriever, BM25Retriever

# تهيئة المسترجع الكثيف
dense_retriever = DenseRetriever(
    model_name="facebook/dpr-question_encoder-single-nq-base",
    corpus_path="path/to/corpus.jsonl"
)

# تهيئة مسترجع BM25
bm25_retriever = BM25Retriever(
    corpus_path="path/to/corpus.jsonl"
)
```

### 2. مكونات المولد

يتعامل مكون المولد مع عملية توليد النص باستخدام الوثائق المسترجعة كسياق:

**نماذج اللغة**: دعم لمختلف LLMs بما في ذلك سلسلة GPT و LLaMA و T5 والنماذج الأخرى المبنية على المحولات.

**استراتيجيات التوليد**: طرق مختلفة لدمج المعلومات المسترجعة في عملية التوليد.

```python
from flashrag.generator import OpenAIGenerator, HuggingFaceGenerator

# مولد OpenAI
openai_gen = OpenAIGenerator(
    model_name="gpt-3.5-turbo",
    api_key="your-api-key"
)

# مولد HuggingFace
hf_gen = HuggingFaceGenerator(
    model_name="meta-llama/Llama-2-7b-chat-hf"
)
```

### 3. مدير مجموعة البيانات

يتعامل مدير مجموعة البيانات مع تحميل البيانات والمعالجة المسبقة والتوحيد المعياري:

```python
from flashrag.dataset import Dataset

# تحميل مجموعة بيانات معيارية
dataset = Dataset(
    config={
        'dataset_name': 'nq',
        'split': 'test',
        'sample_num': 1000
    }
)

# الوصول إلى عينات مجموعة البيانات
for sample in dataset:
    question = sample['question']
    golden_answers = sample['golden_answers']
    # معالجة العينة...
```

### 4. إطار التقييم

يوفر FlashRAG مقاييس تقييم شاملة لأنظمة RAG:

```python
from flashrag.evaluator import Evaluator

evaluator = Evaluator(
    config={
        'metric': ['em', 'f1', 'rouge_l', 'bleu'],
        'language': 'ar'
    }
)

# تقييم التنبؤات
results = evaluator.evaluate(
    pred_answers=predictions,
    golden_answers=ground_truth
)
```

## دليل البدء السريع

دعونا نمر عبر مثال كامل لإعداد وتشغيل نظام RAG أساسي مع FlashRAG.

### مثال 1: الإجابة على الأسئلة الأساسية

```python
from flashrag.config import Config
from flashrag.pipeline import SequentialPipeline
from flashrag.dataset import Dataset

# التكوين
config = Config(
    config_file_path="configs/basic_rag.yaml"
)

# تهيئة مجموعة البيانات
dataset = Dataset(config)

# إنشاء خط الأنابيب
pipeline = SequentialPipeline(config)

# تشغيل التقييم
results = pipeline.run(dataset)
print(f"نتيجة EM: {results['em']:.4f}")
print(f"نتيجة F1: {results['f1']:.4f}")
```

### مثال 2: خط أنابيب RAG مخصص

```python
from flashrag.retriever import DenseRetriever
from flashrag.generator import OpenAIGenerator
from flashrag.evaluator import Evaluator

# تهيئة المكونات
retriever = DenseRetriever(config)
generator = OpenAIGenerator(config)
evaluator = Evaluator(config)

# معالجة الاستعلامات
def process_query(question):
    # استرجاع الوثائق ذات الصلة
    docs = retriever.retrieve(question, top_k=5)
    
    # توليد الإجابة مع السياق
    context = "\n".join([doc['content'] for doc in docs])
    answer = generator.generate(
        prompt=f"السياق: {context}\nالسؤال: {question}\nالإجابة:"
    )
    
    return answer, docs

# مثال على الاستخدام
question = "ما هي عاصمة فرنسا؟"
answer, retrieved_docs = process_query(question)
print(f"الإجابة: {answer}")
```

## إدارة التكوين

يستخدم FlashRAG ملفات التكوين YAML لإدارة إعدادات التجارب. إليك مثال تكوين شامل:

```yaml
# basic_rag.yaml
experiment_name: "basic_rag_experiment"

# تكوين مجموعة البيانات
dataset_name: "nq"
split: "test"
sample_num: 1000

# تكوين المسترجع
retriever_method: "dense"
retriever_model: "facebook/dpr-question_encoder-single-nq-base"
corpus_path: "data/corpus/wiki.jsonl"
index_path: "data/index/wiki_dense_index"
top_k: 5

# تكوين المولد
generator_method: "openai"
generator_model: "gpt-3.5-turbo"
max_tokens: 150
temperature: 0.1

# تكوين التقييم
metrics: ["em", "f1", "rouge_l"]
save_results: true
output_path: "results/"

# تكوين الأجهزة
device: "cuda"
batch_size: 16
num_workers: 4
```

## العمل مع مجموعات البيانات

يوفر FlashRAG دعماً واسعاً لمجموعات البيانات مع معالجة مسبقة معيارية. دعونا نستكشف كيفية العمل مع أنواع مختلفة من مجموعات البيانات.

### تحميل مجموعات البيانات المعيارية

```python
from flashrag.dataset import Dataset

# تحميل مجموعة بيانات Natural Questions
nq_dataset = Dataset(config={
    'dataset_name': 'nq',
    'split': 'dev',
    'sample_num': 500
})

# تحميل مجموعة بيانات TriviaQA
trivia_dataset = Dataset(config={
    'dataset_name': 'triviaqa',
    'split': 'test'
})

# التكرار عبر العينات
for sample in nq_dataset:
    print(f"السؤال: {sample['question']}")
    print(f"الأجوبة: {sample['golden_answers']}")
    print(f"البيانات الوصفية: {sample['metadata']}")
    print("-" * 50)
```

### إنشاء مجموعات البيانات المخصصة

لبياناتك الخاصة، اتبع تنسيق JSONL المعياري:

```python
import json

# إنشاء مجموعة بيانات مخصصة
custom_data = [
    {
        "id": "custom_001",
        "question": "ما هو التعلم الآلي؟",
        "golden_answers": [
            "التعلم الآلي هو فرع من فروع الذكاء الاصطناعي"
        ],
        "metadata": {"domain": "AI", "difficulty": "أساسي"}
    },
    {
        "id": "custom_002", 
        "question": "اشرح الشبكات العصبية",
        "golden_answers": [
            "الشبكات العصبية هي أنظمة حاسوبية مستوحاة من الشبكات العصبية البيولوجية"
        ],
        "metadata": {"domain": "AI", "difficulty": "متوسط"}
    }
]

# حفظ بتنسيق JSONL
with open("custom_dataset.jsonl", "w", encoding='utf-8') as f:
    for item in custom_data:
        f.write(json.dumps(item, ensure_ascii=False) + "\n")

# تحميل مجموعة البيانات المخصصة
custom_dataset = Dataset(config={
    'dataset_path': 'custom_dataset.jsonl'
})
```

### معالجة وتحليل مجموعة البيانات

```python
# تحليل إحصائيات مجموعة البيانات
def analyze_dataset(dataset):
    questions = [sample['question'] for sample in dataset]
    answers = [sample['golden_answers'] for sample in dataset]
    
    # الإحصائيات الأساسية
    avg_question_length = sum(len(q.split()) for q in questions) / len(questions)
    avg_answer_count = sum(len(ans) for ans in answers) / len(answers)
    
    print(f"حجم مجموعة البيانات: {len(dataset)}")
    print(f"متوسط طول السؤال: {avg_question_length:.2f} كلمة")
    print(f"متوسط عدد الأجوبة: {avg_answer_count:.2f}")
    
    return {
        'size': len(dataset),
        'avg_question_length': avg_question_length,
        'avg_answer_count': avg_answer_count
    }

# تحليل مجموعة البيانات المحملة
stats = analyze_dataset(nq_dataset)
```

## بناء مجموعة الوثائق

مجموعة الوثائق عالية الجودة ضرورية لأنظمة RAG الفعالة. يدعم FlashRAG تنسيقات مجموعة متنوعة ويوفر أدوات لإعداد المجموعة.

### متطلبات تنسيق المجموعة

يتوقع FlashRAG مجموعات وثائق بتنسيق JSONL مع هيكل محدد:

```json
{"id": "doc_001", "contents": "عنوان الوثيقة\nمحتوى نص الوثيقة يظهر هنا..."}
{"id": "doc_002", "contents": "عنوان آخر\nمحتوى وثيقة أكثر..."}
```

### إنشاء مجموعة من ويكيبيديا

يوفر FlashRAG نصوص برمجية لمعالجة تفريغات ويكيبيديا:

```python
from flashrag.utils.corpus_utils import WikipediaProcessor

# معالجة تفريغ ويكيبيديا
processor = WikipediaProcessor(
    dump_path="arwiki-latest-pages-articles.xml.bz2",
    output_path="wiki_corpus.jsonl",
    min_length=100,
    max_length=5000
)

# معالجة وحفظ المجموعة
processor.process()
```

### إنشاء مجموعة مخصصة

```python
import json
from pathlib import Path

def create_corpus_from_texts(text_files_dir, output_path):
    """إنشاء مجموعة من دليل ملفات النص"""
    corpus = []
    
    for file_path in Path(text_files_dir).glob("*.txt"):
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read().strip()
            
        # إنشاء إدخال الوثيقة
        doc = {
            "id": file_path.stem,
            "contents": f"{file_path.stem}\n{content}"
        }
        corpus.append(doc)
    
    # حفظ المجموعة
    with open(output_path, 'w', encoding='utf-8') as f:
        for doc in corpus:
            f.write(json.dumps(doc, ensure_ascii=False) + '\n')
    
    print(f"تم إنشاء مجموعة مع {len(corpus)} وثيقة")

# الاستخدام
create_corpus_from_texts("documents/", "my_corpus.jsonl")
```

## طرق RAG المتقدمة

ينفذ FlashRAG العديد من تقنيات RAG المتقدمة. دعونا نستكشف بعض الطرق الأكثر تأثيراً.

### تنفيذ Self-RAG

يسمح Self-RAG للنماذج بالاسترجاع التكيفي والتفكير في عملية التوليد الخاصة بها:

```python
from flashrag.pipeline import SelfRAGPipeline

# تكوين Self-RAG
config = Config({
    'pipeline_name': 'self-rag',
    'generator_model': 'selfrag/selfrag_llama2_7b',
    'retriever_method': 'dense',
    'self_rag_threshold': 0.5,
    'reflection_tokens': True
})

# تهيئة خط الأنابيب
self_rag = SelfRAGPipeline(config)

# التشغيل مع الاسترجاع التكيفي
results = self_rag.run(dataset)
```

### تنفيذ RAPTOR

ينشئ RAPTOR تمثيلات هرمية للوثائق لتحسين الاسترجاع:

```python
from flashrag.pipeline import RAPTORPipeline

# تكوين RAPTOR
config = Config({
    'pipeline_name': 'raptor',
    'clustering_method': 'gmm',
    'summarization_model': 'gpt-3.5-turbo',
    'tree_depth': 3,
    'chunk_size': 512
})

# بناء شجرة RAPTOR
raptor = RAPTORPipeline(config)
raptor.build_tree(corpus_path="wiki_corpus.jsonl")

# الاستعلام مع الاسترجاع الهرمي
results = raptor.run(dataset)
```

### تنفيذ HyDE (تضمينات الوثائق الافتراضية)

ينتج HyDE وثائق افتراضية لتحسين صلة الاسترجاع:

```python
from flashrag.pipeline import HyDEPipeline

# تكوين HyDE
config = Config({
    'pipeline_name': 'hyde',
    'hypothesis_generator': 'gpt-3.5-turbo',
    'num_hypotheses': 3,
    'hypothesis_weight': 0.7
})

# تهيئة خط أنابيب HyDE
hyde = HyDEPipeline(config)

# توليد الوثائق الافتراضية والاسترجاع
results = hyde.run(dataset)
```

## التقييم والمقايسة

التقييم الشامل أمر بالغ الأهمية لبحث RAG. يوفر FlashRAG قدرات تقييم واسعة.

### المقاييس المعيارية

```python
from flashrag.evaluator import Evaluator

# تهيئة المقيم مع مقاييس متعددة
evaluator = Evaluator(config={
    'metrics': [
        'exact_match',      # مطابقة السلسلة الدقيقة
        'f1_score',         # F1 على مستوى الرمز
        'rouge_l',          # نتيجة ROUGE-L
        'bleu',             # نتيجة BLEU
        'bertscore',        # التشابه الدلالي
        'retrieval_recall'  # جودة الاسترجاع
    ]
})

# تقييم التنبؤات
evaluation_results = evaluator.evaluate(
    predictions=model_predictions,
    references=ground_truth_answers,
    retrieved_docs=retrieved_documents
)

# طباعة النتائج المفصلة
for metric, score in evaluation_results.items():
    print(f"{metric}: {score:.4f}")
```

### مقاييس التقييم المخصصة

```python
def domain_specific_metric(predictions, references, **kwargs):
    """مقياس تقييم مخصص للمهام الخاصة بالمجال"""
    scores = []
    
    for pred, ref in zip(predictions, references):
        # تنفيذ منطقك المخصص
        score = calculate_custom_score(pred, ref)
        scores.append(score)
    
    return {
        'domain_metric': sum(scores) / len(scores),
        'individual_scores': scores
    }

# تسجيل المقياس المخصص
evaluator.register_metric('domain_specific', domain_specific_metric)
```

### المقايسة الشاملة

```python
def run_comprehensive_benchmark(methods, datasets):
    """تشغيل مقايسة عبر طرق ومجموعات بيانات متعددة"""
    results = {}
    
    for method_name, method_config in methods.items():
        results[method_name] = {}
        
        for dataset_name, dataset_config in datasets.items():
            print(f"تقييم {method_name} على {dataset_name}")
            
            # تهيئة خط الأنابيب
            pipeline = create_pipeline(method_config)
            dataset = Dataset(dataset_config)
            
            # تشغيل التقييم
            eval_results = pipeline.run(dataset)
            results[method_name][dataset_name] = eval_results
    
    return results

# تحديد الطرق للمقارنة
methods = {
    'basic_rag': {'pipeline_name': 'sequential'},
    'self_rag': {'pipeline_name': 'self-rag'},
    'raptor': {'pipeline_name': 'raptor'}
}

# تحديد مجموعات البيانات للتقييم
datasets = {
    'nq': {'dataset_name': 'nq', 'split': 'test'},
    'triviaqa': {'dataset_name': 'triviaqa', 'split': 'test'}
}

# تشغيل المقايسة
benchmark_results = run_comprehensive_benchmark(methods, datasets)
```

## تحسين الأداء

يشمل تحسين أداء نظام RAG عدة استراتيجيات، من الفهرسة الفعالة إلى تحسين النموذج.

### تحسين الفهرس

```python
from flashrag.retriever import FaissRetriever

# تحسين فهرس FAISS لمقايضات السرعة مقابل الدقة
retriever = FaissRetriever(
    config={
        'index_type': 'IVF',          # فهرس الملف المقلوب
        'nlist': 4096,               # عدد العناقيد
        'nprobe': 128,               # عناقيد البحث
        'index_path': 'optimized_index'
    }
)

# بناء فهرس محسن
retriever.build_index(
    embeddings=document_embeddings,
    batch_size=10000
)
```

### معالجة الدفعات

```python
class BatchProcessor:
    def __init__(self, pipeline, batch_size=32):
        self.pipeline = pipeline
        self.batch_size = batch_size
    
    def process_batch(self, questions):
        """معالجة الأسئلة في دفعات للكفاءة"""
        results = []
        
        for i in range(0, len(questions), self.batch_size):
            batch = questions[i:i+self.batch_size]
            batch_results = self.pipeline.batch_run(batch)
            results.extend(batch_results)
        
        return results

# الاستخدام
processor = BatchProcessor(pipeline, batch_size=64)
all_results = processor.process_batch(test_questions)
```

### تحسين الذاكرة

```python
import gc
import torch

def optimize_memory_usage():
    """تحسين استخدام الذاكرة للتجارب واسعة النطاق"""
    
    # مسح ذاكرة التخزين المؤقت لـ PyTorch
    if torch.cuda.is_available():
        torch.cuda.empty_cache()
    
    # فرض جمع القمامة
    gc.collect()
    
    # تعيين إعدادات فعالة للذاكرة
    torch.backends.cudnn.benchmark = False
    torch.backends.cudnn.deterministic = True

# استخدام مدير السياق لإدارة الذاكرة
class MemoryOptimizedPipeline:
    def __enter__(self):
        optimize_memory_usage()
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        optimize_memory_usage()
```

## استكشاف الأخطاء وأفضل الممارسات

### المشاكل الشائعة والحلول

**المشكلة 1: أخطاء نفاد الذاكرة**

```python
# الحل: تقليل حجم الدفعة واستخدام نقاط تفتيش التدرج
config = Config({
    'batch_size': 8,              # تقليل من الافتراضي
    'gradient_checkpointing': True,
    'fp16': True                  # استخدام الدقة المختلطة
})
```

**المشكلة 2: أداء بطيء في الاسترجاع**

```python
# الحل: تحسين تكوين الفهرس
config = Config({
    'index_type': 'IVF',
    'nlist': min(4 * int(math.sqrt(corpus_size)), corpus_size // 39),
    'nprobe': min(nlist // 4, 128)
})
```

**المشكلة 3: جودة استرجاع ضعيفة**

```python
# الحل: تجريب نماذج تضمين مختلفة
embedders = [
    'sentence-transformers/all-MiniLM-L6-v2',
    'intfloat/e5-base-v2',
    'BAAI/bge-base-en-v1.5'
]

for embedder in embedders:
    retriever = DenseRetriever(model_name=embedder)
    # تقييم جودة الاسترجاع
    recall_score = evaluate_retrieval(retriever, eval_dataset)
    print(f"{embedder}: Recall@5 = {recall_score:.4f}")
```

### أفضل الممارسات

**1. تصميم التجربة**

- استخدم دائماً بذور عشوائية متسقة للقابلية للإعادة
- نفذ تقسيمات تدريب/تحقق/اختبار مناسبة
- استخدم التحقق المتقاطع للتقييم القوي
- وثق جميع خيارات المعاملات الفائقة

**2. جودة البيانات**

- تأكد من أن وثائق المجموعة منظفة ومنسقة بشكل صحيح
- أزل التكرارات والتكرارات القريبة من المجموعة
- تحقق من جودة مجموعة البيانات قبل التجريب
- راقب تسرب البيانات بين التقسيمات

**3. مراقبة الأداء**

```python
import time
import psutil
import logging

class PerformanceMonitor:
    def __init__(self):
        self.start_time = None
        self.logger = logging.getLogger(__name__)
    
    def __enter__(self):
        self.start_time = time.time()
        self.start_memory = psutil.virtual_memory().used
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        elapsed_time = time.time() - self.start_time
        end_memory = psutil.virtual_memory().used
        memory_diff = end_memory - self.start_memory
        
        self.logger.info(f"وقت التنفيذ: {elapsed_time:.2f} ثانية")
        self.logger.info(f"استخدام الذاكرة: {memory_diff / 1024 / 1024:.2f} ميجابايت")

# الاستخدام
with PerformanceMonitor():
    results = pipeline.run(dataset)
```

## الخلاصة والخطوات التالية

يمثل FlashRAG تقدماً مهماً في مجال أدوات بحث RAG، حيث يوفر للباحثين منصة شاملة ومعيارية وفعالة لتطوير وتقييم أنظمة الاسترجاع المدعم بالتوليد. من خلال هذا البرنامج التعليمي، غطينا الجوانب الأساسية لـ FlashRAG، من التثبيت الأساسي إلى تنفيذ الطرق المتقدمة.

### النقاط الرئيسية

**التصميم المعياري**: يتيح الهيكل القائم على المكونات في FlashRAG التجريب السهل مع استراتيجيات الاسترجاع والتوليد المختلفة، مما يجعله مثالياً لاستكشاف البحث.

**التغطية الشاملة**: مع دعم أكثر من 30 مجموعة بيانات والعديد من الطرق المتطورة، يوفر FlashRAG تغطية واسعة لمشهد بحث RAG.

**ميزات موجهة للبحث**: يجعل تركيز الأداة على القابلية للإعادة والتقييم المفصل وقدرات المعايرة مفيداً بشكل خاص للبحث الأكاديمي.

**القابلية للتوسع**: من النماذج الأولية البسيطة إلى التجارب واسعة النطاق، يوفر FlashRAG الأدوات والتحسينات اللازمة للبحث الفعال في أي مقياس.

### الاتجاهات المستقبلية

مع استمرار تطور مجال RAG بسرعة، يحافظ FlashRAG على التطوير النشط لدمج أحدث التطورات. قد تشمل التطورات المستقبلية:

- تكامل قدرات RAG متعددة الوسائط
- آليات التفكير والتخطيط المتقدمة
- تحسينات الكفاءة المحسنة للنشر واسع النطاق
- دعم محسن للتطبيقات الخاصة بالمجال

### المشاركة

FlashRAG هو مشروع مفتوح المصدر يرحب بمساهمات المجتمع. سواء كنت مهتماً بتنفيذ طرق جديدة أو إضافة دعم مجموعة البيانات أو تحسين التوثيق، هناك طرق عديدة للمساهمة في أداة البحث القيمة هذه.

لمزيد من المعلومات، قم بزيارة [مستودع FlashRAG على GitHub](https://github.com/RUC-NLPIR/FlashRAG) وانضم إلى المجتمع المتنامي من باحثي RAG الذين يعملون على تطوير المجال من خلال أدوات ومنهجيات أفضل.

تذكر أن البحث الفعال في RAG يتطلب اهتماماً دقيقاً بتصميم التجربة وجودة البيانات ومنهجية التقييم. يوفر FlashRAG الأدوات، لكن التطبيق المدروس لهذه الأدوات يبقى مفتاح المساهمات البحثية ذات المعنى.
