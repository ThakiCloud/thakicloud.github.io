---
title: "الدليل الشامل لـ OpenLLMetry: قابلية الملاحظة للنماذج اللغوية الكبيرة باستخدام OpenTelemetry"
excerpt: "تعلم كيفية تنفيذ قابلية الملاحظة الشاملة لتطبيقات الذكاء الاصطناعي باستخدام OpenLLMetry، الحل مفتوح المصدر لمراقبة تطبيقات الذكاء الاصطناعي."
seo_title: "دليل OpenLLMetry: قابلية الملاحظة ومراقبة النماذج اللغوية - Thaki Cloud"
seo_description: "دليل شامل حول OpenLLMetry لقابلية ملاحظة النماذج اللغوية الكبيرة. تعلم التثبيت والتكوين ومراقبة تطبيقات الذكاء الاصطناعي مع أمثلة عملية."
date: 2025-09-09
categories:
  - tutorials
tags:
  - openllmetry
  - llm-observability
  - opentelemetry
  - ai-monitoring
  - machine-learning
  - python
author_profile: true
toc: true
toc_label: "جدول المحتويات"
lang: ar
permalink: /ar/tutorials/openllmetry-complete-guide-llm-observability/
canonical_url: "https://thakicloud.github.io/ar/tutorials/openllmetry-complete-guide-llm-observability/"
---

⏱️ **وقت القراءة المقدر**: 15 دقيقة

## مقدمة

مع تزايد تعقيد تطبيقات النماذج اللغوية الكبيرة (LLM) وجاهزيتها للإنتاج، أصبحت المراقبة وقابلية الملاحظة متطلبات أساسية. يظهر [OpenLLMetry](https://github.com/traceloop/openllmetry) كحل شامل يجلب قابلية الملاحظة على مستوى المؤسسات إلى تطبيقات النماذج اللغوية الكبيرة من خلال معايير OpenTelemetry.

OpenLLMetry هو منصة قابلية ملاحظة مفتوحة المصدر مصممة خصيصاً لتطبيقات النماذج اللغوية الكبيرة. مبني على OpenTelemetry، يوفر رؤية كاملة لأداء تطبيق الذكاء الاصطناعي والتكاليف والسلوك مع الحفاظ على التوافق مع البنية التحتية الحالية لقابلية الملاحظة.

### لماذا OpenLLMetry مهم

أدوات المراقبة التقليدية تقصر عندما يتعلق الأمر بتطبيقات النماذج اللغوية الكبيرة. يعالج OpenLLMetry التحديات الفريدة مثل:

- **تتبع استخدام الرموز المميزة**: مراقبة رموز الإدخال/الإخراج والتكاليف المرتبطة
- **تحليل زمن الاستجابة**: تتبع أوقات الاستجابة عبر مزودي النماذج المختلفين
- **مراقبة الأخطاء**: التقاط وتحليل الأخطاء والإخفاقات الخاصة بالنماذج اللغوية الكبيرة
- **تحسين الأداء**: تحديد عقد الازدحام في سير عمل الذكاء الاصطناعي
- **إدارة التكاليف**: مراقبة الإنفاق عبر مزودي النماذج اللغوية المتعددة

## المتطلبات الأساسية

قبل الغوص في OpenLLMetry، تأكد من وجود:

- **Python 3.8+** مثبت على نظامك
- **فهم أساسي** لمفاهيم OpenTelemetry
- **تطبيق نماذج لغوية كبيرة** (OpenAI، Anthropic، إلخ) للمراقبة
- **خلفية قابلية الملاحظة** (اختيارية، للإعدادات المتقدمة)

## الجزء الأول: البدء مع OpenLLMetry

### التثبيت والإعداد الأساسي

لنبدأ بأبسط إعداد ممكن. يوفر OpenLLMetry SDK مريح يجعل البدء سهلاً للغاية.

#### الخطوة الأولى: تثبيت OpenLLMetry SDK

```bash
# تثبيت SDK الأساسي
pip install traceloop-sdk

# للتكاملات المحددة، ثبت الحزم الإضافية
pip install openai anthropic  # مثال على مزودي النماذج اللغوية
```

#### الخطوة الثانية: التهيئة الأساسية

أبسط طريقة لبدء مراقبة تطبيق النماذج اللغوية الكبيرة هي بسطر واحد من الكود:

```python
from traceloop.sdk import Traceloop

# تهيئة OpenLLMetry بالإعدادات الافتراضية
Traceloop.init()
```

للتطوير المحلي، قد تريد رؤية التتبعات فوراً:

```python
# تعطيل الإرسال المجمع للرؤية الفورية للتتبع
Traceloop.init(disable_batch=True)
```

#### الخطوة الثالثة: أول استدعاء مراقب للنماذج اللغوية

إليك مثال كامل يوضح المراقبة الأساسية:

```python
import openai
from traceloop.sdk import Traceloop

# تهيئة OpenLLMetry
Traceloop.init(disable_batch=True)

# تكوين عميل OpenAI
client = openai.OpenAI(api_key="your-api-key")

# استدعاء مراقب للنماذج اللغوية
def generate_response(prompt):
    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "user", "content": prompt}
        ],
        max_tokens=100
    )
    return response.choices[0].message.content

# اختبار الدالة المراقبة
if __name__ == "__main__":
    result = generate_response("اشرح الحوسبة الكمية بمصطلحات بسيطة")
    print(result)
```

عند تشغيل هذا الكود، يقوم OpenLLMetry تلقائياً بـ:
- التقاط الطلب والاستجابة
- تسجيل استخدام الرموز والتكاليف
- قياس زمن استجابة
- تتبع أي أخطاء تحدث

## الجزء الثاني: التكوين المتقدم

### التتبع المخصص باستخدام المزخرفات

يوفر OpenLLMetry مزخرفات للتتبع المخصص لمنطق التطبيق:

```python
from traceloop.sdk import Traceloop
from traceloop.sdk.decorators import task, workflow

# تهيئة OpenLLMetry
Traceloop.init()

@workflow(name="document_analysis_pipeline")
def analyze_document(document_text):
    """سير العمل الرئيسي لتحليل الوثائق"""
    summary = summarize_text(document_text)
    sentiment = analyze_sentiment(document_text)
    keywords = extract_keywords(document_text)
    
    return {
        "summary": summary,
        "sentiment": sentiment,
        "keywords": keywords
    }

@task(name="text_summarization")
def summarize_text(text):
    """تلخيص النص المدخل"""
    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "system", "content": "لخص النص التالي بإيجاز."},
            {"role": "user", "content": text}
        ],
        max_tokens=150
    )
    return response.choices[0].message.content

@task(name="sentiment_analysis")
def analyze_sentiment(text):
    """تحليل مشاعر النص"""
    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "system", "content": "حلل مشاعر هذا النص. أجب بـ: إيجابي، سلبي، أو محايد."},
            {"role": "user", "content": text}
        ],
        max_tokens=10
    )
    return response.choices[0].message.content

@task(name="keyword_extraction")
def extract_keywords(text):
    """استخراج المصطلحات الرئيسية من النص"""
    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "system", "content": "استخرج 5 مصطلحات رئيسية من هذا النص. أعدها كقائمة مفصولة بفواصل."},
            {"role": "user", "content": text}
        ],
        max_tokens=50
    )
    return response.choices[0].message.content
```

### التكوين القائم على البيئة

للنشر في الإنتاج، قم بتكوين OpenLLMetry من خلال متغيرات البيئة:

```bash
# تعيين متغيرات البيئة
export TRACELOOP_API_KEY="your-traceloop-api-key"
export TRACELOOP_BATCH_EXPORT="true"
export TRACELOOP_TELEMETRY="false"  # تعطيل التيليمتري إذا لزم الأمر
```

```python
import os
from traceloop.sdk import Traceloop

# تكوين الإنتاج
Traceloop.init(
    api_key=os.getenv("TRACELOOP_API_KEY"),
    disable_batch=os.getenv("TRACELOOP_BATCH_EXPORT", "true").lower() == "false",
    telemetry_enabled=os.getenv("TRACELOOP_TELEMETRY", "true").lower() == "true"
)
```

## الجزء الثالث: التكامل مع أطر النماذج اللغوية الشائعة

### تكامل LangChain

يتكامل OpenLLMetry بسلاسة مع تطبيقات LangChain:

```python
from langchain.llms import OpenAI
from langchain.chains import LLMChain
from langchain.prompts import PromptTemplate
from traceloop.sdk import Traceloop

# تهيئة OpenLLMetry
Traceloop.init()

# إنشاء مكونات LangChain
llm = OpenAI(temperature=0.7)
prompt = PromptTemplate(
    input_variables=["topic"],
    template="اكتب شرحاً موجزاً عن {topic}"
)

# إنشاء وتشغيل السلسلة
chain = LLMChain(llm=llm, prompt=prompt)

# سيتم تتبع هذا تلقائياً
result = chain.run(topic="التعلم الآلي")
print(result)
```

### تكامل LlamaIndex

لتطبيقات LlamaIndex:

```python
from llama_index import VectorStoreIndex, SimpleDirectoryReader
from llama_index.llms import OpenAI
from traceloop.sdk import Traceloop

# تهيئة OpenLLMetry
Traceloop.init()

# تكوين LlamaIndex
llm = OpenAI(model="gpt-3.5-turbo")

# تحميل الوثائق وإنشاء الفهرس
documents = SimpleDirectoryReader("data").load_data()
index = VectorStoreIndex.from_documents(documents)

# إنشاء محرك الاستعلام
query_engine = index.as_query_engine(llm=llm)

# الاستعلام مع التتبع التلقائي
response = query_engine.query("ما هي المواضيع الرئيسية في هذه الوثائق؟")
print(response)
```

## الجزء الرابع: مراقبة قاعدة البيانات الشعاعية

OpenLLMetry يراقب أيضاً عمليات قاعدة البيانات الشعاعية:

### تكامل Pinecone

```python
import pinecone
from traceloop.sdk import Traceloop

# تهيئة OpenLLMetry
Traceloop.init()

# تهيئة Pinecone
pinecone.init(
    api_key="your-pinecone-api-key",
    environment="your-environment"
)

# إنشاء مرجع الفهرس
index = pinecone.Index("your-index-name")

# عمليات شعاعية مراقبة
def search_similar_documents(query_vector, top_k=5):
    """البحث عن وثائق مشابهة باستخدام التشابه الشعاعي"""
    results = index.query(
        vector=query_vector,
        top_k=top_k,
        include_metadata=True
    )
    return results

# عملية إدراج مراقبة
def store_document_embedding(doc_id, embedding, metadata):
    """تخزين تضمين الوثيقة في Pinecone"""
    index.upsert([
        (doc_id, embedding, metadata)
    ])
```

### تكامل Chroma

```python
import chromadb
from traceloop.sdk import Traceloop

# تهيئة OpenLLMetry
Traceloop.init()

# تهيئة عميل Chroma
client = chromadb.Client()

# الحصول على أو إنشاء مجموعة
collection = client.get_or_create_collection("documents")

# العمليات المراقبة
def add_documents(documents, embeddings, ids, metadatas):
    """إضافة وثائق إلى مجموعة Chroma"""
    collection.add(
        documents=documents,
        embeddings=embeddings,
        ids=ids,
        metadatas=metadatas
    )

def query_documents(query_text, n_results=5):
    """استعلام الوثائق المشابهة من Chroma"""
    results = collection.query(
        query_texts=[query_text],
        n_results=n_results
    )
    return results
```

## الجزء الخامس: تكامل خلفية قابلية الملاحظة

### تكامل Datadog

ربط OpenLLMetry بـ Datadog للمراقبة على مستوى المؤسسة:

```python
from opentelemetry import trace
from opentelemetry.exporter.datadog import DatadogExporter, DatadogSpanProcessor
from opentelemetry.sdk.trace import TracerProvider
from traceloop.sdk import Traceloop

# تكوين مصدر Datadog
tracer_provider = TracerProvider()
datadog_exporter = DatadogExporter(
    agent_url="http://localhost:8126",  # رابط وكيل Datadog
    service="llm-application"
)

# إضافة معالج مدى Datadog
tracer_provider.add_span_processor(
    DatadogSpanProcessor(datadog_exporter)
)

# تعيين موفر المتتبع
trace.set_tracer_provider(tracer_provider)

# تهيئة OpenLLMetry مع متتبع مخصص
Traceloop.init()
```

### تكامل Honeycomb

لقابلية ملاحظة Honeycomb:

```python
import os
from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from traceloop.sdk import Traceloop

# تكوين مصدر Honeycomb
tracer_provider = TracerProvider()

otlp_exporter = OTLPSpanExporter(
    endpoint="https://api.honeycomb.io/v1/traces",
    headers={
        "x-honeycomb-team": os.getenv("HONEYCOMB_API_KEY"),
        "x-honeycomb-dataset": "llm-traces"
    }
)

# إضافة معالج مدى دفعي
tracer_provider.add_span_processor(
    BatchSpanProcessor(otlp_exporter)
)

# تعيين موفر المتتبع
trace.set_tracer_provider(tracer_provider)

# تهيئة OpenLLMetry
Traceloop.init()
```

## الجزء السادس: المقاييس والخصائص المخصصة

### إضافة الخصائص المخصصة

تحسين التتبعات مع منطق الأعمال المخصص:

```python
from traceloop.sdk import Traceloop
from traceloop.sdk.decorators import task
from opentelemetry import trace

# تهيئة OpenLLMetry
Traceloop.init()

@task(name="customer_support_response")
def handle_customer_query(query, customer_id, priority="normal"):
    """التعامل مع استعلام دعم العملاء مع الخصائص المخصصة"""
    
    # الحصول على المدى الحالي
    current_span = trace.get_current_span()
    
    # إضافة خصائص مخصصة
    current_span.set_attribute("customer.id", customer_id)
    current_span.set_attribute("query.priority", priority)
    current_span.set_attribute("query.length", len(query))
    
    # تحديد النموذج بناءً على الأولوية
    model = "gpt-4" if priority == "high" else "gpt-3.5-turbo"
    current_span.set_attribute("llm.model", model)
    
    # توليد الاستجابة
    response = client.chat.completions.create(
        model=model,
        messages=[
            {"role": "system", "content": "أنت وكيل دعم عملاء مفيد."},
            {"role": "user", "content": query}
        ]
    )
    
    # إضافة خصائص الاستجابة
    response_text = response.choices[0].message.content
    current_span.set_attribute("response.length", len(response_text))
    current_span.set_attribute("response.satisfactory", "unknown")  # يمكن تحديدها بواسطة نموذج ML
    
    return response_text
```

### جمع المقاييس المخصصة

إنشاء مقاييس مخصصة لمؤشرات الأداء الرئيسية للأعمال:

```python
from opentelemetry import metrics
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.metrics.export import ConsoleMetricExporter, PeriodicExportingMetricReader
import time

# تكوين المقاييس
metric_reader = PeriodicExportingMetricReader(
    ConsoleMetricExporter(), 
    export_interval_millis=5000
)
metrics.set_meter_provider(MeterProvider(metric_readers=[metric_reader]))

# إنشاء عدادات مخصصة
meter = metrics.get_meter("llm_application")

# إنشاء مقاييس مخصصة
request_counter = meter.create_counter(
    "llm_requests_total",
    description="العدد الإجمالي لطلبات النماذج اللغوية"
)

response_time_histogram = meter.create_histogram(
    "llm_response_time",
    description="وقت استجابة النماذج اللغوية بالثواني"
)

token_usage_counter = meter.create_counter(
    "llm_tokens_used",
    description="إجمالي الرموز المستهلكة"
)

def monitored_llm_call(prompt, model="gpt-3.5-turbo"):
    """استدعاء النماذج اللغوية مع المقاييس المخصصة"""
    start_time = time.time()
    
    try:
        # زيادة عداد الطلبات
        request_counter.add(1, {"model": model})
        
        # استدعاء النماذج اللغوية
        response = client.chat.completions.create(
            model=model,
            messages=[{"role": "user", "content": prompt}]
        )
        
        # تسجيل وقت الاستجابة
        response_time = time.time() - start_time
        response_time_histogram.record(response_time, {"model": model})
        
        # تسجيل استخدام الرموز
        usage = response.usage
        token_usage_counter.add(usage.total_tokens, {
            "model": model,
            "type": "total"
        })
        token_usage_counter.add(usage.prompt_tokens, {
            "model": model,
            "type": "prompt"
        })
        token_usage_counter.add(usage.completion_tokens, {
            "model": model,
            "type": "completion"
        })
        
        return response.choices[0].message.content
        
    except Exception as e:
        request_counter.add(1, {"model": model, "status": "error"})
        raise
```

## الجزء السابع: أفضل الممارسات للإنتاج

### معالجة الأخطاء والمرونة

تنفيذ معالجة قوية للأخطاء لبيئات الإنتاج:

```python
from traceloop.sdk import Traceloop
from opentelemetry import trace
import logging
import sys

# تكوين التسجيل
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# تهيئة OpenLLMetry مع معالجة الأخطاء
try:
    Traceloop.init(
        disable_batch=False,  # تمكين التجميع للإنتاج
        telemetry_enabled=False  # تعطيل التيليمتري للخصوصية
    )
    logger.info("تم تهيئة OpenLLMetry بنجاح")
except Exception as e:
    logger.error(f"فشل في تهيئة OpenLLMetry: {e}")
    # المتابعة بدون تتبع بدلاً من فشل التطبيق
    pass

def safe_llm_call(prompt, max_retries=3, backoff_factor=2):
    """استدعاء النماذج اللغوية مع منطق إعادة المحاولة ومعالجة شاملة للأخطاء"""
    
    span = trace.get_current_span()
    
    for attempt in range(max_retries):
        try:
            span.set_attribute("retry.attempt", attempt + 1)
            
            response = client.chat.completions.create(
                model="gpt-3.5-turbo",
                messages=[{"role": "user", "content": prompt}],
                timeout=30  # تعيين مهلة زمنية للإنتاج
            )
            
            span.set_attribute("request.successful", True)
            return response.choices[0].message.content
            
        except openai.RateLimitError as e:
            span.set_attribute("error.type", "rate_limit")
            span.set_attribute("error.message", str(e))
            
            if attempt < max_retries - 1:
                wait_time = backoff_factor ** attempt
                logger.warning(f"تم الوصول لحد المعدل، انتظار {wait_time} ثانية قبل إعادة المحاولة")
                time.sleep(wait_time)
            else:
                span.set_attribute("request.successful", False)
                raise
                
        except openai.APIError as e:
            span.set_attribute("error.type", "api_error")
            span.set_attribute("error.message", str(e))
            span.set_attribute("request.successful", False)
            
            logger.error(f"خطأ في API OpenAI: {e}")
            raise
            
        except Exception as e:
            span.set_attribute("error.type", "unknown")
            span.set_attribute("error.message", str(e))
            span.set_attribute("request.successful", False)
            
            logger.error(f"خطأ غير متوقع: {e}")
            raise
```

### تحسين الأداء

تحسين OpenLLMetry للتطبيقات عالية الإنتاجية:

```python
from traceloop.sdk import Traceloop
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.sdk.trace import TracerProvider
import os

# تكوين عالي الأداء
tracer_provider = TracerProvider()

# تكوين معالج دفعي للإنتاجية العالية
batch_processor = BatchSpanProcessor(
    span_exporter=your_exporter,  # المصدر المختار
    max_queue_size=2048,  # زيادة حجم الطابور
    export_timeout_millis=30000,  # مهلة زمنية 30 ثانية
    max_export_batch_size=512,  # أحجام دفعات أكبر
    schedule_delay_millis=500  # صادرات أكثر تكراراً
)

tracer_provider.add_span_processor(batch_processor)

# التهيئة مع تحسينات الأداء
Traceloop.init(
    disable_batch=False,
    resource_attributes={
        "service.name": "llm-application",
        "service.version": "1.0.0",
        "deployment.environment": os.getenv("ENVIRONMENT", "production")
    }
)
```

### اعتبارات الأمان والخصوصية

تنفيذ أفضل ممارسات الأمان:

```python
from traceloop.sdk import Traceloop
from opentelemetry import trace
import hashlib
import re

# التهيئة مع تكوين يركز على الخصوصية
Traceloop.init(
    telemetry_enabled=False,  # تعطيل التيليمتري
    api_key=os.getenv("TRACELOOP_API_KEY")  # استخدام متغيرات البيئة
)

def sanitize_prompt(prompt):
    """إزالة المعلومات الحساسة من المطالبات قبل التتبع"""
    
    # إزالة عناوين البريد الإلكتروني
    prompt = re.sub(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b', '[EMAIL]', prompt)
    
    # إزالة أرقام الهاتف
    prompt = re.sub(r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b', '[PHONE]', prompt)
    
    # إزالة أرقام بطاقات الائتمان
    prompt = re.sub(r'\b\d{4}[-\s]?\d{4}[-\s]?\d{4}[-\s]?\d{4}\b', '[CREDIT_CARD]', prompt)
    
    return prompt

def secure_llm_call(prompt, include_prompt_in_trace=False):
    """استدعاء النماذج اللغوية مع حماية الخصوصية"""
    
    span = trace.get_current_span()
    
    # تشفير المطالبة الأصلية للتتبع دون كشف المحتوى
    prompt_hash = hashlib.sha256(prompt.encode()).hexdigest()[:16]
    span.set_attribute("prompt.hash", prompt_hash)
    span.set_attribute("prompt.length", len(prompt))
    
    # تضمين المطالبة المنظفة اختيارياً
    if include_prompt_in_trace:
        sanitized_prompt = sanitize_prompt(prompt)
        span.set_attribute("prompt.sanitized", sanitized_prompt)
    
    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[{"role": "user", "content": prompt}]
    )
    
    # عدم تضمين محتوى الاستجابة في التتبعات للخصوصية
    response_text = response.choices[0].message.content
    span.set_attribute("response.length", len(response_text))
    span.set_attribute("response.hash", hashlib.sha256(response_text.encode()).hexdigest()[:16])
    
    return response_text
```

## الجزء الثامن: المراقبة والتنبيه

### إعداد التنبيهات

تكوين التنبيهات لمشاكل تطبيقات النماذج اللغوية الشائعة:

```python
from traceloop.sdk import Traceloop
from opentelemetry import trace
import time

# تهيئة OpenLLMetry
Traceloop.init()

class LLMMonitor:
    def __init__(self):
        self.error_count = 0
        self.total_requests = 0
        self.total_cost = 0.0
        self.response_times = []
    
    def track_request(self, success=True, cost=0.0, response_time=0.0):
        """تتبع مقاييس الطلب للتنبيه"""
        self.total_requests += 1
        self.total_cost += cost
        self.response_times.append(response_time)
        
        if not success:
            self.error_count += 1
        
        # الاحتفاظ بآخر 100 وقت استجابة فقط للمتوسط المتحرك
        if len(self.response_times) > 100:
            self.response_times.pop(0)
        
        # فحص شروط التنبيه
        self.check_alerts()
    
    def check_alerts(self):
        """فحص شروط التنبيه"""
        
        # تنبيه معدل خطأ عالي
        if self.total_requests > 10:
            error_rate = self.error_count / self.total_requests
            if error_rate > 0.1:  # معدل خطأ 10%
                self.send_alert(f"معدل خطأ عالي: {error_rate:.2%}")
        
        # تنبيه وقت استجابة عالي
        if len(self.response_times) > 10:
            avg_response_time = sum(self.response_times[-10:]) / 10
            if avg_response_time > 5.0:  # متوسط 5 ثوان
                self.send_alert(f"وقت استجابة عالي: {avg_response_time:.2f} ثانية")
        
        # تنبيه التكلفة
        if self.total_cost > 100.0:  # عتبة 100 دولار
            self.send_alert(f"تكلفة عالية: ${self.total_cost:.2f}")
    
    def send_alert(self, message):
        """إرسال تنبيه (تنفيذ طريقة التنبيه المفضلة لديك)"""
        print(f"تنبيه: {message}")
        # تنفيذ Slack أو البريد الإلكتروني أو تنبيهات أخرى هنا

# مثيل مراقب عام
monitor = LLMMonitor()

def monitored_llm_call_with_alerting(prompt):
    """استدعاء النماذج اللغوية مع المراقبة والتنبيه"""
    start_time = time.time()
    span = trace.get_current_span()
    
    try:
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[{"role": "user", "content": prompt}]
        )
        
        # حساب المقاييس
        response_time = time.time() - start_time
        cost = estimate_cost(response.usage)  # تنفيذ حساب التكلفة
        
        # تتبع الطلب الناجح
        monitor.track_request(success=True, cost=cost, response_time=response_time)
        
        # إضافة المقاييس للمدى
        span.set_attribute("request.cost", cost)
        span.set_attribute("request.response_time", response_time)
        
        return response.choices[0].message.content
        
    except Exception as e:
        response_time = time.time() - start_time
        
        # تتبع الطلب الفاشل
        monitor.track_request(success=False, response_time=response_time)
        
        # إضافة معلومات الخطأ للمدى
        span.set_attribute("request.failed", True)
        span.set_attribute("error.message", str(e))
        
        raise

def estimate_cost(usage, model="gpt-3.5-turbo"):
    """تقدير تكلفة الطلب بناءً على استخدام الرموز"""
    # حساب تكلفة مبسط (تحديث بالأسعار الحالية)
    pricing = {
        "gpt-3.5-turbo": {"input": 0.001, "output": 0.002}  # لكل 1000 رمز
    }
    
    if model in pricing:
        input_cost = (usage.prompt_tokens / 1000) * pricing[model]["input"]
        output_cost = (usage.completion_tokens / 1000) * pricing[model]["output"]
        return input_cost + output_cost
    
    return 0.0
```

## الاختبار والتحقق

لننشئ سكريبت اختبار شامل للتحقق من إعداد OpenLLMetry:

```python
#!/usr/bin/env python3
"""
سكريبت اختبار OpenLLMetry
قم بتشغيل هذا للتحقق من تثبيت وتكوين OpenLLMetry.
"""

import os
import sys
import time
from traceloop.sdk import Traceloop
from traceloop.sdk.decorators import task, workflow

def test_basic_initialization():
    """اختبار التهيئة الأساسية لـ OpenLLMetry"""
    print("اختبار التهيئة الأساسية...")
    
    try:
        Traceloop.init(disable_batch=True)
        print("✅ تم تهيئة OpenLLMetry بنجاح")
        return True
    except Exception as e:
        print(f"❌ فشل التهيئة: {e}")
        return False

@task(name="test_task")
def test_custom_tracing():
    """اختبار مزخرفات التتبع المخصصة"""
    print("اختبار التتبع المخصص...")
    time.sleep(0.1)  # محاكاة العمل
    return "تم إنجاز المهمة"

@workflow(name="test_workflow")
def test_workflow_tracing():
    """اختبار تتبع مستوى سير العمل"""
    print("اختبار تتبع سير العمل...")
    result = test_custom_tracing()
    return f"نتيجة سير العمل: {result}"

def test_environment_configuration():
    """اختبار التكوين القائم على البيئة"""
    print("اختبار تكوين البيئة...")
    
    # فحص متغيرات البيئة
    required_vars = ["TRACELOOP_API_KEY"]
    optional_vars = ["TRACELOOP_BATCH_EXPORT", "TRACELOOP_TELEMETRY"]
    
    for var in required_vars:
        if not os.getenv(var):
            print(f"⚠️  تحذير: {var} غير محدد")
    
    for var in optional_vars:
        value = os.getenv(var, "غير محدد")
        print(f"ℹ️  {var}: {value}")

def run_tests():
    """تشغيل جميع الاختبارات"""
    print("🚀 تشغيل اختبارات OpenLLMetry")
    print("=" * 40)
    
    tests = [
        test_basic_initialization,
        test_environment_configuration,
        test_workflow_tracing
    ]
    
    results = []
    for test in tests:
        try:
            result = test()
            results.append(result)
            print()
        except Exception as e:
            print(f"❌ الاختبار {test.__name__} فشل: {e}")
            results.append(False)
            print()
    
    # الملخص
    passed = sum(1 for r in results if r)
    total = len(results)
    
    print("=" * 40)
    print(f"نتائج الاختبار: {passed}/{total} نجح")
    
    if passed == total:
        print("🎉 نجحت جميع الاختبارات! OpenLLMetry جاهز للاستخدام.")
    else:
        print("⚠️  فشلت بعض الاختبارات. تحقق من التكوين والتبعيات.")

if __name__ == "__main__":
    run_tests()
```

## الخلاصة

يوفر OpenLLMetry حلاً شاملاً لقابلية ملاحظة تطبيقات النماذج اللغوية الكبيرة، مع تقديم تكامل سلس مع البنية التحتية الحالية لـ OpenTelemetry بينما يعالج احتياجات المراقبة الفريدة لتطبيقات الذكاء الاصطناعي.

### النقاط الرئيسية

1. **إعداد بسيط**: ابدأ ببضعة أسطر من الكود
2. **تكامل الأطر**: يعمل بسلاسة مع LangChain وLlamaIndex وأطر أخرى شائعة
3. **جاهز للإنتاج**: يتضمن معالجة قوية للأخطاء وتحسين الأداء وميزات الأمان
4. **قابل للتوسع**: يدعم المقاييس والخصائص المخصصة وتكاملات الخلفية
5. **فعال من ناحية التكلفة**: مفتوح المصدر مع دعم عدة خلفيات قابلية ملاحظة

### الخطوات التالية

1. **ابدأ صغيراً**: ابدأ بالمراقبة الأساسية في بيئة التطوير
2. **أضف مقاييس مخصصة**: نفذ التتبع الخاص بالأعمال لحالة الاستخدام الخاصة بك
3. **نشر الإنتاج**: اكفِّ معالجة قوية للأخطاء والتنبيه
4. **تكامل الفريق**: اتصل بالبنية التحتية الحالية لقابلية الملاحظة
5. **التحسين المستمر**: استخدم الرؤى لتحسين الأداء والتكاليف

يحول OpenLLMetry مراقبة تطبيقات النماذج اللغوية الكبيرة من فكرة لاحقة إلى قدرة من الدرجة الأولى، مما يمكنك من بناء تطبيقات ذكاء اصطناعي أكثر موثوقية وأداءً وفعالية من ناحية التكلفة.

لمزيد من المعلومات، قم بزيارة [مستودع OpenLLMetry GitHub](https://github.com/traceloop/openllmetry) أو تحقق من [الوثائق الرسمية](https://www.traceloop.com/openllmetry).

---

*مراقبة سعيدة! 🚀*
