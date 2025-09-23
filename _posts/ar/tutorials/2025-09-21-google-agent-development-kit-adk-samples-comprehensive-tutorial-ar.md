---
title: "نماذج Google Agent Development Kit (ADK): دليل شامل لتطبيقات الوكلاء المتعددة"
excerpt: "تعلم كيفية بناء أنظمة وكلاء ذكية متعددة باستخدام ADK من Google مع أمثلة عملية من مستودع النماذج الرسمي."
seo_title: "دليل نماذج Google ADK: بناء تطبيقات الوكلاء المتعددة - Thaki Cloud"
seo_description: "إتقان Google Agent Development Kit (ADK) مع دليلنا الشامل الذي يغطي التثبيت ونماذج الوكلاء وأمثلة التنفيذ العملي لأنظمة الوكلاء المتعددة."
date: 2025-09-21
categories:
  - tutorials
tags:
  - google-adk
  - أنظمة-الوكلاء-المتعددة
  - وكلاء-الذكاء-الاصطناعي
  - python
  - java
  - إطار-عمل-الوكلاء
author_profile: true
toc: true
toc_label: "جدول المحتويات"
lang: ar
permalink: /ar/tutorials/google-adk-samples-tutorial/
canonical_url: "https://thakicloud.github.io/ar/tutorials/google-adk-samples-tutorial/"
---

⏱️ **وقت القراءة المتوقع**: 15 دقيقة

## مقدمة حول Google Agent Development Kit (ADK)

إن Google Agent Development Kit (ADK) هو إطار عمل مفتوح المصدر مصمم لبناء أنظمة وكلاء ذكية ومستقلة متعددة. يمكّن ADK المطورين من إنشاء تطبيقات وكلاء جاهزة للإنتاج يمكنها التفاعل مع الأدوات والتواصل مع بعضها البعض وأداء مهام معقدة عبر نماذج وبيئات نشر مختلفة.

يوفر مستودع [google/adk-samples](https://github.com/google/adk-samples) مجموعة شاملة من نماذج الوكلاء المبنية على ADK، تتراوح من روبوتات المحادثة البسيطة إلى سير عمل الوكلاء المتعددة المتطورة. تعمل هذه النماذج كأمثلة عملية ونقاط انطلاق للمطورين الذين يتطلعون إلى الاستفادة من قدرات ADK.

## الميزات الرئيسية لـ ADK

### 1. هندسة الوكلاء المتعددة
يدعم ADK إنشاء وكلاء متعددين يمكنهم العمل معاً، كل منهم له أدوار وقدرات متخصصة. تمكّن هذه الهندسة من حل المشاكل المعقدة من خلال التعاون بين الوكلاء.

### 2. تكامل الأدوات
يمكن للوكلاء المبنيين بـ ADK التفاعل مع الأدوات الخارجية وواجهات برمجة التطبيقات، مما يوسع قدراتهم إلى ما بعد استجابات نماذج اللغة لأداء إجراءات في العالم الحقيقي.

### 3. النشر المرن
يدعم ADK بيئات نشر مختلفة، من التطوير المحلي إلى أنظمة الإنتاج القائمة على السحابة، مما يجعله مناسباً لمقاييس مختلفة من التطبيقات.

### 4. دعم اللغات المتعددة
يوفر الإطار مجموعات تطوير برمجيات لكل من Python و Java، مما يسمح للمطورين بالعمل بلغة البرمجة المفضلة لديهم.

## نظرة عامة على بنية المستودع

ينظم مستودع نماذج ADK في قسمين رئيسيين:

```
adk-samples/
├── java/
│   ├── agents/
│   │   ├── software-bug-assistant/
│   │   └── time-series-forecasting/
│   └── README.md
└── python/
    ├── agents/
    │   ├── academic-research/
    │   ├── blog-writer/
    │   ├── customer-service/
    │   ├── data-science/
    │   ├── financial-advisor/
    │   ├── RAG/
    │   └── [أكثر من 20 نموذج إضافي]
    └── README.md
```

## التثبيت وإعداد البيئة

### المتطلبات المسبقة

قبل العمل مع نماذج ADK، تأكد من تثبيت ما يلي:

- **Python 3.8+** أو **Java 11+** (حسب اللغة المختارة)
- **Git** لاستنساخ المستودع
- **مشروع Google Cloud** مع تفعيل واجهات برمجة التطبيقات الضرورية

### الخطوة 1: استنساخ المستودع

```bash
# استنساخ مستودع نماذج ADK
git clone https://github.com/google/adk-samples.git
cd adk-samples
```

### الخطوة 2: تثبيت ADK

اتبع دليل التثبيت الرسمي لـ ADK للغة التي اخترتها:

**بالنسبة لـ Python:**
```bash
pip install google-adk
```

**بالنسبة لـ Java:**
```bash
# إضافة تبعية ADK إلى مشروع Maven أو Gradle
# تعليمات مفصلة في README الخاص بـ Java
```

### الخطوة 3: تكوين البيئة

أنشئ ملف `.env` في دليل مشروعك وقم بتكوين متغيرات البيئة الضرورية:

```bash
# تكوين Google Cloud
GOOGLE_APPLICATION_CREDENTIALS=/path/to/your/service-account-key.json
GOOGLE_CLOUD_PROJECT=your-project-id

# مفاتيح API (إذا كانت مطلوبة من قبل وكلاء محددين)
OPENAI_API_KEY=your-openai-key
ANTHROPIC_API_KEY=your-anthropic-key
```

## استكشاف نماذج الوكلاء

### تحليل عميق لنماذج Python

تغطي نماذج Python مجموعة واسعة من حالات الاستخدام. دعونا نستكشف بعض الأمثلة البارزة:

#### 1. وكيل خدمة العملاء

يوضح وكيل خدمة العملاء كيفية بناء ذكاء اصطناعي تفاعلي يمكنه التعامل مع استفسارات العملاء والوصول إلى قواعد المعرفة وتصعيد القضايا المعقدة.

**الميزات الرئيسية:**
- فهم اللغة الطبيعية
- تكامل قاعدة المعرفة
- سير عمل التصعيد
- محادثات متعددة الأدوار

#### 2. وكيل علوم البيانات

يعرض هذا الوكيل قدرات تحليل البيانات المدعومة بالذكاء الاصطناعي، بما في ذلك معالجة البيانات المسبقة والتصور والتحليل الإحصائي.

**القدرات:**
- تنظيف البيانات الآلي
- التحليل الإحصائي
- إنشاء الرسوم البيانية
- إنشاء التقارير

#### 3. وكيل RAG (الجيل المعزز بالاستخراج)

يوضح وكيل RAG كيفية دمج آليات الاستخراج مع قدرات الجيل للمهام كثيفة المعرفة.

**المكونات:**
- فهرسة الوثائق
- البحث الدلالي
- الجيل الواعي للسياق
- عزو المصدر

### نظرة عامة على نماذج Java

تركز نماذج Java على التطبيقات على مستوى المؤسسة:

#### 1. مساعد أخطاء البرمجيات

وكيل متخصص لفرق تطوير البرمجيات يمكنه تحليل تقارير الأخطاء واقتراح الحلول وتتبع حل المشاكل.

#### 2. توقع السلاسل الزمنية

وكيل يؤدي تحليل السلاسل الزمنية المتقدم والتنبؤ باستخدام نماذج التعلم الآلي.

## دليل التنفيذ العملي

### تشغيل وكيلك الأول

دعونا نتنقل عبر تشغيل وكيل خدمة العملاء كمثال:

#### الخطوة 1: الانتقال إلى دليل الوكيل

```bash
cd python/agents/customer-service
```

#### الخطوة 2: تثبيت التبعيات

```bash
# تثبيت الحزم المطلوبة
pip install -r requirements.txt
```

#### الخطوة 3: تكوين الوكيل

عدّل ملف التكوين ليتناسب مع بيئتك:

```python
# config.py
AGENT_CONFIG = {
    "model": "gemini-pro",
    "temperature": 0.7,
    "max_tokens": 1000,
    "knowledge_base": "customer_kb.json"
}
```

#### الخطوة 4: تشغيل الوكيل

```bash
python main.py
```

#### الخطوة 5: التفاعل مع الوكيل

بمجرد التشغيل، يمكنك التفاعل مع الوكيل من خلال الواجهة المقدمة:

```
Customer Service Agent: مرحباً! كيف يمكنني مساعدتك اليوم؟
المستخدم: أواجه مشكلة مع طلبي
Customer Service Agent: سأكون سعيداً لمساعدتك مع طلبك. هل يمكنك تقديم رقم الطلب؟
```

## التكوين المتقدم والتخصيص

### تخصيص سلوك الوكيل

يمكنك تخصيص سلوك الوكيل بتعديل معايير التكوين:

```python
from google.adk import Agent, AgentConfig

config = AgentConfig(
    name="custom-agent",
    model="gemini-pro",
    system_prompt="أنت مساعد مفيد متخصص في...",
    tools=["web_search", "calculator", "email_sender"],
    memory_type="conversation",
    max_conversation_length=100
)

agent = Agent(config)
```

### تكامل الأدوات

يسمح لك ADK بدمج أدوات مخصصة مع وكلائك:

```python
from google.adk.tools import Tool

class CustomTool(Tool):
    def __init__(self):
        super().__init__(
            name="custom_tool",
            description="يؤدي منطق أعمال مخصص"
        )
    
    def execute(self, parameters):
        # منطقك المخصص هنا
        return {"result": "تم تنفيذ الأداة المخصصة بنجاح"}

# تسجيل الأداة مع وكيلك
agent.add_tool(CustomTool())
```

### تنسيق الوكلاء المتعددين

للسير المعقدة، يمكنك إنشاء وكلاء متعددين يعملون معاً:

```python
from google.adk import MultiAgentSystem

# إنشاء وكلاء متخصصين
research_agent = Agent(research_config)
writing_agent = Agent(writing_config)
review_agent = Agent(review_config)

# إنشاء نظام وكلاء متعددين
system = MultiAgentSystem([research_agent, writing_agent, review_agent])

# تعريف سير العمل
workflow = {
    "research": research_agent,
    "write": writing_agent,
    "review": review_agent
}

# تنفيذ سير العمل
result = system.execute_workflow(workflow, initial_input="اكتب مقال مدونة عن الذكاء الاصطناعي")
```

## أفضل الممارسات والتحسين

### 1. هندسة المطالبات

الهندسة الفعالة للمطالبات أمر بالغ الأهمية لأداء الوكيل:

```python
SYSTEM_PROMPT = """
أنت مساعد خبير في {domain} مع القدرات التالية:
- {capability_1}
- {capability_2}
- {capability_3}

الإرشادات:
1. قدم دائماً معلومات دقيقة ومفيدة
2. اطرح أسئلة توضيحية عند الحاجة
3. اذكر المصادر عند تقديم ادعاءات واقعية
4. صعّد القضايا المعقدة إلى خبراء بشريين

تنسيق الاستجابة:
- كن مختصراً لكن شاملاً
- استخدم النقاط للقوائم
- اشمل أمثلة ذات صلة
"""
```

### 2. معالجة الأخطاء والمرونة

نفّذ معالجة أخطاء قوية للنشر في الإنتاج:

```python
from google.adk.exceptions import ADKException

try:
    response = agent.process(user_input)
except ADKException as e:
    logger.error(f"خطأ في معالجة الوكيل: {e}")
    response = "أعتذر، لكنني أواجه صعوبات تقنية. يرجى المحاولة مرة أخرى لاحقاً."
```

### 3. مراقبة الأداء

راقب أداء الوكيل وأنماط الاستخدام:

```python
from google.adk.monitoring import AgentMetrics

metrics = AgentMetrics(agent)
metrics.track_response_time()
metrics.track_success_rate()
metrics.track_user_satisfaction()
```

## استراتيجيات النشر

### التطوير المحلي

للتطوير والاختبار:

```bash
# تشغيل بوضع التصحيح
python main.py --debug --port 8000
```

### النشر السحابي

لنشر الإنتاج على Google Cloud:

```yaml
# app.yaml لـ Google App Engine
runtime: python39

env_variables:
  GOOGLE_CLOUD_PROJECT: your-project-id
  
automatic_scaling:
  min_instances: 1
  max_instances: 10
```

### نشر الحاويات

استخدام Docker للنشر المحتوى:

```dockerfile
FROM python:3.9-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
EXPOSE 8080

CMD ["python", "main.py", "--port", "8080"]
```

## استكشاف الأخطاء وإصلاحها الشائعة

### 1. أخطاء المصادقة

تأكد من تكوين بيانات اعتماد Google Cloud بشكل صحيح:

```bash
# إعداد بيانات الاعتماد الافتراضية للتطبيق
gcloud auth application-default login

# أو تصدير مفتاح حساب الخدمة
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json
```

### 2. تعارضات التبعيات

استخدم البيئات الافتراضية لتجنب تعارضات الحزم:

```bash
python -m venv adk-env
source adk-env/bin/activate  # على Windows: adk-env\Scripts\activate
pip install -r requirements.txt
```

### 3. مشاكل الذاكرة

للوكلاء كثيفي الذاكرة، قم بتكوين حدود مناسبة:

```python
config = AgentConfig(
    max_memory_usage="2GB",
    cleanup_interval=300,  # ثوان
    conversation_history_limit=50
)
```

## الاعتبارات الأمنية

### 1. إدارة مفاتيح API

لا تكتب مفاتيح API مباشرة في الكود المصدري:

```python
import os
from google.cloud import secretmanager

def get_api_key(secret_name):
    client = secretmanager.SecretManagerServiceClient()
    name = f"projects/{PROJECT_ID}/secrets/{secret_name}/versions/latest"
    response = client.access_secret_version(request={"name": name})
    return response.payload.data.decode("UTF-8")
```

### 2. التحقق من صحة المدخلات

تحقق من صحة مدخلات المستخدم وقم بتنظيفها:

```python
import re

def validate_user_input(input_text):
    # إزالة المحتوى المحتمل ضرره
    cleaned_input = re.sub(r'[<>"\']', '', input_text)
    
    # تحديد طول المدخل
    if len(cleaned_input) > 1000:
        cleaned_input = cleaned_input[:1000]
    
    return cleaned_input
```

### 3. تحديد المعدل

نفّذ تحديد المعدل لمنع الإساءة:

```python
from functools import wraps
import time

def rate_limit(max_calls_per_minute=60):
    def decorator(func):
        last_called = {}
        
        @wraps(func)
        def wrapper(*args, **kwargs):
            user_id = kwargs.get('user_id', 'anonymous')
            now = time.time()
            
            if user_id in last_called:
                if now - last_called[user_id] < 60 / max_calls_per_minute:
                    raise Exception("تم تجاوز حد المعدل")
            
            last_called[user_id] = now
            return func(*args, **kwargs)
        
        return wrapper
    return decorator
```

## حالات الاستخدام المتقدمة

### 1. خط معالجة الوثائق

إنشاء خط وكلاء متعددين لمعالجة الوثائق:

```python
# وكيل تحليل الوثائق
analyzer_agent = Agent(analyzer_config)

# وكيل استخراج المعلومات
extractor_agent = Agent(extractor_config)

# وكيل إنشاء الملخصات
summarizer_agent = Agent(summarizer_config)

# تنفيذ خط المعالجة
def process_document(document_path):
    # الخطوة 1: تحليل بنية الوثيقة
    analysis = analyzer_agent.process(f"تحليل الوثيقة: {document_path}")
    
    # الخطوة 2: استخراج المعلومات الرئيسية
    extraction = extractor_agent.process(f"استخراج البيانات من: {analysis}")
    
    # الخطوة 3: إنشاء الملخص
    summary = summarizer_agent.process(f"تلخيص: {extraction}")
    
    return {
        "analysis": analysis,
        "extracted_data": extraction,
        "summary": summary
    }
```

### 2. نظام دعم العملاء الذكي

بناء نظام دعم عملاء شامل:

```python
class CustomerSupportSystem:
    def __init__(self):
        self.routing_agent = Agent(routing_config)
        self.technical_agent = Agent(technical_config)
        self.billing_agent = Agent(billing_config)
        self.escalation_agent = Agent(escalation_config)
    
    def handle_inquiry(self, customer_inquiry):
        # توجيه الاستفسار إلى الوكيل المناسب
        routing_decision = self.routing_agent.process(customer_inquiry)
        
        if routing_decision.category == "technical":
            return self.technical_agent.process(customer_inquiry)
        elif routing_decision.category == "billing":
            return self.billing_agent.process(customer_inquiry)
        elif routing_decision.escalate:
            return self.escalation_agent.process(customer_inquiry)
        else:
            return self.routing_agent.process(customer_inquiry)
```

## تحسين الأداء

### 1. استراتيجيات التخزين المؤقت

نفّذ التخزين المؤقت لتحسين أوقات الاستجابة:

```python
from functools import lru_cache
import hashlib

class CachedAgent:
    def __init__(self, agent):
        self.agent = agent
        self.response_cache = {}
    
    def process(self, input_text):
        # إنشاء مفتاح التخزين المؤقت
        cache_key = hashlib.md5(input_text.encode()).hexdigest()
        
        if cache_key in self.response_cache:
            return self.response_cache[cache_key]
        
        # المعالجة وتخزين النتيجة مؤقتاً
        response = self.agent.process(input_text)
        self.response_cache[cache_key] = response
        
        return response
```

### 2. المعالجة غير المتزامنة

استخدم المعالجة غير المتزامنة لأداء أفضل:

```python
import asyncio
from google.adk import AsyncAgent

async def process_multiple_requests(requests):
    agent = AsyncAgent(config)
    
    # معالجة الطلبات بشكل متزامن
    tasks = [agent.process_async(request) for request in requests]
    responses = await asyncio.gather(*tasks)
    
    return responses
```

## الاختبار وضمان الجودة

### 1. اختبار الوحدة

أنشئ اختبارات شاملة لوكلائك:

```python
import unittest
from unittest.mock import Mock, patch

class TestCustomerServiceAgent(unittest.TestCase):
    def setUp(self):
        self.agent = CustomerServiceAgent(test_config)
    
    def test_greeting_response(self):
        response = self.agent.process("مرحباً")
        self.assertIn("مرحبا", response)
        self.assertIn("مساعدة", response.lower())
    
    def test_order_inquiry(self):
        response = self.agent.process("أحتاج مساعدة مع الطلب #12345")
        self.assertIn("طلب", response.lower())
    
    @patch('google.adk.llm.generate')
    def test_api_error_handling(self, mock_generate):
        mock_generate.side_effect = Exception("خطأ API")
        response = self.agent.process("مدخل اختبار")
        self.assertIn("صعوبات تقنية", response.lower())
```

### 2. اختبار التكامل

اختبر تفاعلات الوكلاء وسير العمل:

```python
def test_multi_agent_workflow():
    system = MultiAgentSystem([agent1, agent2, agent3])
    
    test_input = "معالجة هذا الطلب المعقد"
    result = system.execute_workflow(workflow, test_input)
    
    assert result.success == True
    assert len(result.steps) == 3
    assert result.final_output is not None
```

## المراقبة والتحليلات

### 1. مقاييس الأداء

تتبع مؤشرات الأداء الرئيسية:

```python
from google.adk.analytics import AgentAnalytics

analytics = AgentAnalytics()

# تتبع أوقات الاستجابة
analytics.track_metric("response_time", response_time)

# تتبع معدلات النجاح
analytics.track_metric("success_rate", success_count / total_count)

# تتبع رضا المستخدم
analytics.track_metric("user_satisfaction", satisfaction_score)
```

### 2. التسجيل وإزالة الأخطاء

نفّذ تسجيلاً شاملاً:

```python
import logging

# تكوين التسجيل
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('agent.log'),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)

class LoggedAgent(Agent):
    def process(self, input_text):
        logger.info(f"معالجة المدخل: {input_text[:100]}...")
        
        try:
            response = super().process(input_text)
            logger.info(f"تم إنشاء الاستجابة: {response[:100]}...")
            return response
        except Exception as e:
            logger.error(f"خطأ في المعالجة: {e}")
            raise
```

## التحسينات المستقبلية وخارطة الطريق

### 1. الميزات القادمة

تستمر Google في تحسين ADK بميزات جديدة:

- **الدعم متعدد الوسائط**: تكامل معالجة الرؤية والصوت
- **النظام البيئي للأدوات المحسن**: مكتبة موسعة من الأدوات المبنية مسبقاً
- **التنسيق المحسن**: آليات تنسيق أفضل للوكلاء المتعددين
- **تحسينات الأداء**: استنتاج أسرع وتقليل زمن الاستجابة

### 2. مساهمات المجتمع

يرحب مستودع نماذج ADK بمساهمات المجتمع:

- **نماذج وكلاء جديدة**: ساهم بأمثلة خاصة بالمجال
- **تكاملات الأدوات**: أضف تنفيذات أدوات جديدة
- **التوثيق**: حسّن الأدلة والدروس
- **إصلاح الأخطاء**: بلّغ عن المشاكل وأصلحها

## الخلاصة

يوفر Google Agent Development Kit (ADK) أساساً قوياً لبناء أنظمة وكلاء ذكية متعددة. يوفر مستودع النماذج الشامل أمثلة عملية ونقاط انطلاق لحالات استخدام مختلفة، من الوكلاء التفاعليين البسيطة إلى سير عمل الوكلاء المتعددة المعقدة.

الاستنتاجات الرئيسية من هذا الدليل:

1. **ابدأ بساطة**: ابدأ بالنماذج الأساسية واستكشف تدريجياً أمثلة أكثر تعقيداً
2. **التخصيص المدروس**: اضبط التكوينات والمطالبات لحالة الاستخدام المحددة
3. **الاختبار الشامل**: نفّذ استراتيجيات اختبار شاملة لاستعداد الإنتاج
4. **المراقبة المستمرة**: تتبع مقاييس الأداء ورضا المستخدم
5. **الأمان بالتصميم**: نفّذ إجراءات أمنية مناسبة من البداية

يستمر النظام البيئي لـ ADK في التطور، والبقاء منخرطاً مع المجتمع من خلال مستودع النماذج سيساعدك على الاستفادة من أحدث القدرات وأفضل الممارسات.

## مصادر إضافية

- **التوثيق الرسمي**: [توثيق ADK](https://google.github.io/adk-docs/)
- **مستودع GitHub**: [google/adk-samples](https://github.com/google/adk-samples)
- **مدونة المطورين**: [مدونة مطوري Google - ADK](https://developers.googleblog.com)
- **منتديات المجتمع**: [مناقشات ADK](https://github.com/google/adk-samples/discussions)
- **مرجع API**: [توثيق ADK API](https://google.github.io/adk-docs/api/)

---

*يوفر هذا الدليل مقدمة شاملة لنماذج Google Agent Development Kit. مع استمرار تطور الإطار، تأكد من مراجعة التوثيق الرسمي للحصول على أحدث التحديثات والميزات.*
