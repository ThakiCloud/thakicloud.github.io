---
title: "دليل شامل لـ xpander.ai: منصة Backend-as-a-Service لوكلاء الذكاء الاصطناعي"
excerpt: "دليل شامل لبناء وكلاء ذكاء اصطناعي جاهزة للإنتاج باستخدام منصة xpander.ai، يشمل التثبيت والنشر والتعاون متعدد الوكلاء وتكامل أدوات MCP."
seo_title: "دروس xpander.ai: بناء وكلاء الذكاء الاصطناعي بمنصة Backend-as-a-Service"
seo_description: "تعلم كيفية بناء ونشر وتوسيع وكلاء الذكاء الاصطناعي باستخدام منصة xpander.ai Backend-as-a-Service. دليل شامل مع أمثلة كود وأفضل الممارسات."
date: 2025-09-02
categories:
  - tutorials
tags:
  - ai-agents
  - backend-as-a-service
  - llm
  - python
  - nodejs
  - deployment
  - automation
author_profile: true
toc: true
toc_label: "فهرس المحتويات"
lang: ar
permalink: /ar/tutorials/xpander-ai-complete-guide/
canonical_url: "https://thakicloud.github.io/ar/tutorials/xpander-ai-complete-guide/"
---

⏱️ **وقت القراءة المتوقع**: 12 دقيقة

## مقدمة عن xpander.ai

بناء وكلاء ذكاء اصطناعي جاهزة للإنتاج يتطلب التعامل مع تحديات البنية التحتية المعقدة وإدارة الذاكرة وتكامل الأدوات والنشر. تبرز **xpander.ai** كمنصة شاملة من نوع Backend-as-a-Service (BaaS) مصممة خصيصاً لوكلاء الذكاء الاصطناعي، حيث تجرد التعقيد التشغيلي مع توفير قدرات على مستوى المؤسسات.

على عكس منصات الحوسبة السحابية التقليدية، تقدم xpander.ai ميزات أصلية للذكاء الاصطناعي تشمل طبقات ذاكرة PostgreSQL المُدارة، ومكتبات وظائف منسقة تحتوي على أكثر من 2000 أداة، وتوافق مع بروتوكول MCP (Model Context Protocol)، وأنظمة معالجة أحداث ذكية. تدعم المنصة أي إطار عمل للوكلاء بما في ذلك OpenAI SDK وAgno وCrewAI وLangChain، مما يجعلها مستقلة عن إطار العمل وودودة للمطورين.

## الميزات الأساسية والهيكلة

### قدرات المنصة الأساسية

**مرونة إطار العمل**: تقدم xpander.ai دعماً أصلياً لأطر العمل الشائعة مع الحفاظ على التوافق مع التطبيقات المخصصة. يمكنك ترحيل الوكلاء الحاليين بأقل تعديل في الكود أو البدء من جديد بقوالبهم المحسنة.

**تكامل شامل للأدوات**: تشمل المنصة مكتبة منسقة من أكثر من 2000 أداة متوافقة مع MCP تغطي واجهات برمجة التطبيقات وقواعد البيانات وأنظمة الملفات وكشط الويب والتكاملات مع أطراف ثالثة. هذا يلغي الحاجة لبناء موصلات مخصصة للعمليات الشائعة.

**بنية تحتية قابلة للتوسع**: مبنية على هيكل سحابي حديث أصيل، تتعامل xpander.ai مع التوسع تلقائياً. يمكن لوكلائك معالجة آلاف الطلبات المتزامنة دون عبء إدارة البنية التحتية.

**إدارة الحالة**: اختر بين الحالة المحلية الخاصة بإطار العمل للاستخدامات البسيطة أو إدارة الحالة الموزعة للأنظمة متعددة الوكلاء المعقدة التي تتطلب ذاكرة مشتركة وتنسيق.

**معالجة الأحداث في الوقت الفعلي**: نظام التشغيل الأصلي للذكاء الاصطناعي في المنصة يعالج المدخلات من مصادر متعددة (MCP، التواصل بين الوكلاء، واجهات برمجة التطبيقات، الـ webhooks) ويسلم رسائل موحدة لوكلائك.

**حواجز الحماية لواجهة برمجة التطبيقات**: تنفيذ حواجز حماية قوية باستخدام نظام Agent-Graph-System لتعريف التبعيات بين إجراءات واجهة برمجة التطبيقات، مما يضمن استخدام آمن ومسيطر عليه للأدوات.

### نظرة عامة على الهيكلة

تتبع xpander.ai هيكلة الخدمات المصغرة حيث يعمل كل وكيل في حاويات منعزلة مع وصول مشترك للخدمات المُدارة:

- **بيئة تشغيل الوكيل**: بيئة تنفيذ محتواة لكود الوكيل
- **طبقة الذاكرة**: PostgreSQL مُدارة مع قدرات البحث المتجه
- **سجل الأدوات**: مكتبة وظائف مركزية متوافقة مع MCP
- **وسيط الأحداث**: معالجة وتوجيه الرسائل في الوقت الفعلي
- **بوابة واجهة برمجة التطبيقات**: نقاط وصول آمنة للتكاملات الخارجية
- **المراقبة**: أنظمة مراقبة وتسجيل مدمجة

## المتطلبات المسبقة والإعداد

### متطلبات النظام

قبل البدء، تأكد من وجود:

- **Python 3.8+** أو **Node.js 16+** للتطوير المحلي
- **Docker** مثبت للحاويات
- **Git** لإدارة الإصدارات
- **حساب xpander.ai** (طبقة مجانية متاحة)

### إعداد البيئة

أولاً، دعنا ننشئ بيئة التطوير:

```bash
# إنشاء دليل المشروع
mkdir xpander-ai-tutorial
cd xpander-ai-tutorial

# إعداد البيئة الافتراضية لـ Python
python3 -m venv .venv
source .venv/bin/activate

# تثبيت xpander CLI عالمياً
npm install -g xpander-cli
```

### إعداد الحساب والمصادقة

```bash
# تسجيل الدخول لمنصة xpander.ai
xpander login

# ستفتح نافذة متصفح للمصادقة
# اتبع التعليمات لإكمال التسجيل
```

ستقوم أداة سطر الأوامر بحفظ رموز المصادقة محلياً وتكوين الوصول لخدمات المنصة.

## إنشاء أول وكيل لك

### تهيئة المشروع

استخدم أداة xpander CLI لإنشاء مشروع وكيل جديد:

```bash
# إنشاء وكيل جديد من القالب
xpander agent new

# اتبع التعليمات التفاعلية:
# - اسم الوكيل: tutorial-agent
# - إطار العمل: agno (موصى به للمبتدئين)
# - القالب: simple-hello-world
# - اللغة: Python

cd tutorial-agent
```

هذا ينشئ هيكل مشروع كامل:

```
tutorial-agent/
├── xpander_handler.py      # نقطة دخول الوكيل الرئيسية
├── requirements.txt        # تبعيات Python
├── Dockerfile             # تكوين الحاوية
├── .xpander/              # تكوين المنصة
│   ├── config.yaml
│   └── tools.yaml
└── README.md
```

### فهم المعالج

ملف `xpander_handler.py` هو نقطة الدخول الرئيسية لوكيلك:

```python
from xpander_sdk import Task, Backend, on_task
from agno.agent import Agent

@on_task
async def handle_task(task: Task):
    """
    المعالج الرئيسي للمهام الواردة
    
    Args:
        task: كائن مهمة موحد يحتوي على مدخلات المستخدم
              والسياق والبيانات الوصفية من مصادر مختلفة
    """
    # تهيئة خدمات الخلفية
    backend = Backend()  # يوفر قاعدة البيانات وأدوات MCP ونص النظام
    
    # تكوين الوكيل بمعاملات الخلفية
    agent = Agent(**await backend.aget_args())
    
    # معالجة المهمة بتنسيق رسالة موحد
    result = await agent.arun(message=task.to_message())
    
    # إرجاع النتيجة للمنصة
    task.result = result.content
    return task
```

### التطوير والاختبار المحلي

قم بتثبيت التبعيات وابدأ التطوير المحلي:

```bash
# تثبيت تبعيات Python
pip install -r requirements.txt

# بدء خادم التطوير المحلي
xpander dev
```

يوفر خادم التطوير:
- **إعادة التحميل الساخن** لتغييرات الكود
- **التصحيح المحلي** مع تتبع كامل للمكدس
- **خدمات خلفية محاكاة** للاختبار
- **واجهة ويب** لإرسال رسائل اختبار

زر `http://localhost:3000` للتفاعل مع وكيلك من خلال واجهة الويب.

## التكوين المتقدم

### إدارة الذاكرة والحالة

تكوين ذاكرة دائمة لوكيلك:

```python
# xpander_handler.py
from xpander_sdk import Task, Backend, Memory, on_task

@on_task
async def handle_task(task: Task):
    backend = Backend()
    memory = Memory(namespace="tutorial-agent")
    
    # حفظ تاريخ المحادثة
    await memory.store({
        "user_id": task.user_id,
        "message": task.message,
        "timestamp": task.timestamp
    })
    
    # استرداد السياق من التفاعلات السابقة
    context = await memory.search(
        query=task.message,
        limit=5,
        filter={"user_id": task.user_id}
    )
    
    # تكوين الوكيل بالسياق
    agent_args = await backend.aget_args()
    agent_args["context"] = context
    
    agent = Agent(**agent_args)
    result = await agent.arun(message=task.to_message())
    
    # حفظ الاستجابة للسياق المستقبلي
    await memory.store({
        "user_id": task.user_id,
        "response": result.content,
        "timestamp": task.timestamp
    })
    
    task.result = result.content
    return task
```

### تكامل الأدوات ودعم MCP

إضافة أدوات خارجية لوكيلك:

```yaml
# .xpander/tools.yaml
tools:
  - name: web_search
    provider: mcp
    config:
      endpoint: "serpapi://search"
      api_key: "${SERPAPI_KEY}"
  
  - name: file_operations
    provider: builtin
    config:
      allowed_paths: ["/tmp", "/workspace"]
  
  - name: database_query
    provider: custom
    config:
      connection_string: "${DATABASE_URL}"
```

استخدام الأدوات في كود الوكيل:

```python
from xpander_sdk import Task, Backend, Tools, on_task

@on_task
async def handle_task(task: Task):
    backend = Backend()
    tools = Tools()
    
    # الوصول للأدوات المكونة
    search_tool = await tools.get("web_search")
    file_tool = await tools.get("file_operations")
    
    # استخدام الأدوات في الوكيل
    agent = Agent(
        **await backend.aget_args(),
        tools=[search_tool, file_tool]
    )
    
    result = await agent.arun(message=task.to_message())
    task.result = result.content
    return task
```

### التعاون متعدد الوكلاء

تنفيذ التواصل بين الوكلاء:

```python
from xpander_sdk import Task, Backend, AgentClient, on_task

@on_task
async def handle_task(task: Task):
    backend = Backend()
    
    # تهيئة وكلاء آخرين
    research_agent = AgentClient("research-agent")
    writing_agent = AgentClient("writing-agent")
    
    if "research" in task.message.lower():
        # تفويض لوكيل البحث
        research_result = await research_agent.send(task.message)
        
        # معالجة البحث بوكيل الكتابة
        writing_task = f"كتابة ملخص بناءً على: {research_result}"
        final_result = await writing_agent.send(writing_task)
        
        task.result = final_result
    else:
        # معالجة مباشرة
        agent = Agent(**await backend.aget_args())
        result = await agent.arun(message=task.to_message())
        task.result = result.content
    
    return task
```

## النشر والإنتاج

### النشر السحابي

نشر وكيلك على البنية التحتية المُدارة لـ xpander.ai:

```bash
# النشر على السحابة
xpander deploy

# مراقبة حالة النشر
xpander status

# بث السجلات المباشر
xpander logs --follow
```

عملية النشر:
1. **بناء** حاوية Docker بكودك
2. **رفع** لسجل xpander.ai
3. **نشر** على مجموعة Kubernetes المُدارة
4. **تكوين** التوسع التلقائي وتوزيع الأحمال
5. **كشف** نقاط واجهة برمجة التطبيقات والـ webhooks

### تكوين البيئة

تعيين متغيرات بيئة الإنتاج:

```bash
# تعيين الأسرار بأمان
xpander secrets set SERPAPI_KEY "your-api-key"
xpander secrets set DATABASE_URL "postgresql://..."

# تكوين معاملات التوسع
xpander config set min_replicas 2
xpander config set max_replicas 10
xpander config set cpu_limit "1000m"
xpander config set memory_limit "2Gi"
```

### المراقبة والملاحظة

الوصول لأدوات المراقبة المدمجة:

```bash
# عرض لوحة مقاييس الأداء
xpander dashboard

# فحص حالة الصحة
xpander health

# تصدير السجلات للتحليل
xpander logs --export --format json > agent-logs.json
```

## أمثلة التكامل

### تكامل بوت Slack

ربط وكيلك بـ Slack:

```python
# إضافة مشغل Slack في .xpander/config.yaml
triggers:
  - type: slack
    config:
      bot_token: "${SLACK_BOT_TOKEN}"
      channels: ["#ai-assistant"]
      events: ["message", "mention"]

# معالجة أحداث Slack في وكيلك
@on_task
async def handle_task(task: Task):
    backend = Backend()
    
    # فحص ما إذا كانت المهمة من Slack
    if task.source == "slack":
        # الوصول لبيانات Slack المحددة
        channel = task.metadata.get("channel")
        user = task.metadata.get("user")
        
        # الاستجابة بتنسيق Slack
        response = f"مرحباً <@{user}>، أقوم بمعالجة طلبك..."
        
        # المعالجة بالوكيل
        agent = Agent(**await backend.aget_args())
        result = await agent.arun(message=task.message)
        
        task.result = f"{response}\n\n{result.content}"
    
    return task
```

### تكامل Webhook

إعداد نقاط webhook:

```python
# تكوين webhook في .xpander/config.yaml
triggers:
  - type: webhook
    config:
      path: "/api/process"
      methods: ["POST"]
      auth: "bearer"

# معالجة طلبات webhook
@on_task
async def handle_task(task: Task):
    if task.source == "webhook":
        # الوصول لبيانات الطلب
        payload = task.metadata.get("payload", {})
        headers = task.metadata.get("headers", {})
        
        # المعالجة بناءً على بيانات webhook
        if payload.get("type") == "github_pr":
            # معالجة webhook من GitHub PR
            pr_number = payload.get("pull_request", {}).get("number")
            task.message = f"مراجعة PR #{pr_number}"
        
        # الاستمرار بمعالجة الوكيل
        backend = Backend()
        agent = Agent(**await backend.aget_args())
        result = await agent.arun(message=task.message)
        
        task.result = result.content
    
    return task
```

## أفضل الممارسات والتحسين

### تحسين الأداء

**إدارة الذاكرة**: استخدم تجميع الاتصالات وقم بتخزين البيانات المتكررة مؤقتاً:

```python
from xpander_sdk import Cache

@on_task
async def handle_task(task: Task):
    cache = Cache(ttl=300)  # ذاكرة تخزين مؤقت 5 دقائق
    
    # فحص الذاكرة المؤقتة أولاً
    cached_result = await cache.get(f"response:{task.message}")
    if cached_result:
        task.result = cached_result
        return task
    
    # المعالجة وتخزين النتيجة مؤقتاً
    backend = Backend()
    agent = Agent(**await backend.aget_args())
    result = await agent.arun(message=task.to_message())
    
    await cache.set(f"response:{task.message}", result.content)
    task.result = result.content
    return task
```

**معالجة الأخطاء**: تنفيذ معالجة أخطاء قوية:

```python
import logging
from xpander_sdk import Task, Backend, on_task

logger = logging.getLogger(__name__)

@on_task
async def handle_task(task: Task):
    try:
        backend = Backend()
        agent = Agent(**await backend.aget_args())
        result = await agent.arun(message=task.to_message())
        task.result = result.content
        
    except Exception as e:
        logger.error(f"فشل في معالجة الوكيل: {e}")
        task.result = "أعتذر، واجهت خطأ أثناء معالجة طلبك."
        task.error = str(e)
    
    return task
```

### اعتبارات الأمان

**التحقق من الإدخال**: تنظيف مدخلات المستخدم:

```python
import re
from xpander_sdk import Task, Backend, on_task

def sanitize_input(message: str) -> str:
    # إزالة المحتوى الضار المحتمل
    cleaned = re.sub(r'[<>{}]', '', message)
    return cleaned.strip()[:1000]  # تحديد الطول

@on_task
async def handle_task(task: Task):
    # تنظيف الإدخال
    task.message = sanitize_input(task.message)
    
    backend = Backend()
    agent = Agent(**await backend.aget_args())
    result = await agent.arun(message=task.to_message())
    
    task.result = result.content
    return task
```

**تحديد المعدل**: تنفيذ تحديد المعدل بناءً على المستخدم:

```python
from xpander_sdk import RateLimit

@on_task
async def handle_task(task: Task):
    rate_limit = RateLimit()
    
    # فحص تحديد المعدل
    if not await rate_limit.check(task.user_id, limit=10, window=60):
        task.result = "تم تجاوز حد المعدل. يرجى المحاولة لاحقاً."
        return task
    
    # معالجة الطلب
    backend = Backend()
    agent = Agent(**await backend.aget_args())
    result = await agent.arun(message=task.to_message())
    
    task.result = result.content
    return task
```

## استكشاف المشاكل الشائعة وإصلاحها

### فشل النشر

**مشاكل الذاكرة**: إذا نفدت ذاكرة وكيلك:

```bash
# زيادة حد الذاكرة
xpander config set memory_limit "4Gi"

# فحص استخدام الموارد الحالي
xpander metrics --resource memory
```

**تضارب التبعيات**: في حالة تضارب الحزم:

```bash
# استخدم إصدارات محددة في requirements.txt
xpander-sdk==1.2.0
agno==0.5.1

# إعادة البناء وإعادة النشر
xpander deploy --force-rebuild
```

### مشاكل الأداء

**أوقات استجابة بطيئة**: المراقبة والتحسين:

```bash
# فحص مقاييس الأداء
xpander metrics --latency

# تفعيل التسجيل المفصل
xpander config set log_level DEBUG
```

**تأخير تحميل الأدوات**: تحسين تهيئة الأدوات:

```python
# تخزين الأدوات عالمياً مؤقتاً
from functools import lru_cache

@lru_cache(maxsize=32)
async def get_cached_tools():
    tools = Tools()
    return await tools.load_all()

@on_task
async def handle_task(task: Task):
    tools = await get_cached_tools()
    # استخدام الأدوات المخزنة مؤقتاً
```

## الخلاصة والخطوات التالية

تقدم xpander.ai منصة شاملة لبناء وكلاء ذكاء اصطناعي جاهزة للإنتاج دون تعقيد البنية التحتية. ميزات المنصة الأصلية للذكاء الاصطناعي، بما في ذلك تكامل أدوات MCP وطبقات الذاكرة المُدارة ومعالجة الأحداث في الوقت الفعلي، تمكن من التطوير السريع والتوسع السلس.

تشمل المزايا الرئيسية مرونة إطار العمل ومكتبات أدوات واسعة والتوسع التلقائي والمراقبة المدمجة. تجرد المنصة الاهتمامات التشغيلية مع توفير موثوقية وأمان على مستوى المؤسسات.

**الخطوات التالية**:

1. **استكشاف الميزات المتقدمة**: البحث في سير عمل متعددة الوكلاء وتطوير أدوات مخصصة وأنماط ذاكرة متقدمة
2. **نشر الإنتاج**: نشر وكلائك للتعامل مع أحمال العمل الحقيقية مع المراقبة والتنبيهات
3. **المشاركة المجتمعية**: انضم لمجتمع xpander.ai Discord للحصول على الدعم ومشاركة أفضل الممارسات
4. **التكاملات المخصصة**: تطوير أدوات MCP مخصصة وموصلات لمتطلبات الأعمال المحددة

**موارد إضافية**:
- [وثائق xpander.ai](https://docs.xpander.ai)
- [مستودع GitHub](https://github.com/xpander-ai/xpander.ai)
- [مجتمع Discord](https://discord.gg/xpander-ai)
- [مرجع واجهة برمجة التطبيقات](https://api.xpander.ai/docs)

تستمر المنصة في التطور مع ميزات وتكاملات جديدة، مما يجعلها خياراً ممتازاً لتطوير وكلاء الذكاء الاصطناعي في 2025 وما بعدها.
