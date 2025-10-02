---
title: "MCPStore: الدليل الشامل لإدارة خدمات MCP لوكلاء الذكاء الاصطناعي"
excerpt: "تعلم كيفية استخدام MCPStore، أداة إدارة خدمات MCP مفتوحة المصدر الأنيقة التي تمكن وكلاء الذكاء الاصطناعي من دمج واستخدام أدوات متنوعة بسهولة مع دعم عزل الوكلاء المتعددين."
seo_title: "دروس MCPStore: إدارة خدمات MCP لوكلاء الذكاء الاصطناعي - Thaki Cloud"
seo_description: "دليل شامل حول MCPStore - أداة إدارة خدمات MCP مفتوحة المصدر مع تكامل LangChain وعزل الوكلاء المتعددين وواجهة برمجة تطبيقات RESTful لتطوير الذكاء الاصطناعي."
date: 2025-09-28
categories:
  - tutorials
tags:
  - MCP
  - وكلاء-الذكاء-الاصطناعي
  - Python
  - LangChain
  - API
  - مفتوح-المصدر
author_profile: true
toc: true
toc_label: "جدول المحتويات"
lang: ar
permalink: /ar/tutorials/mcpstore-mcp-service-management-tutorial/
canonical_url: "https://thakicloud.github.io/ar/tutorials/mcpstore-mcp-service-management-tutorial/"
---

⏱️ **وقت القراءة المتوقع**: 12 دقيقة

## المقدمة

MCPStore هي أداة مفتوحة المصدر ثورية تبسط إدارة خدمات MCP (بروتوكول سياق النموذج) لوكلاء الذكاء الاصطناعي. مع أكثر من 236 نجمة على GitHub وشعبية متزايدة، توفر MCPStore حلاً أنيقًا لإدارة خدمات MCP مع ميزات مثل عزل الوكلاء المتعددين وتكامل LangChain والواجهات الويب البديهية.

## ما هو MCPStore؟

MCPStore هي أداة إدارة خدمات MCP عالية الجودة ومفتوحة المصدر شاملة تجعل من السهل على وكلاء الذكاء الاصطناعي استخدام أدوات متنوعة. تقدم:

- **تصميم الاستدعاء المتسلسل**: عزل سياق واضح مع `store.for_store()` و `store.for_agent("agent_id")`
- **دعم الوكلاء المتعددين**: مجموعات أدوات مخصصة لوكلاء وظيفيين مختلفين
- **تكامل LangChain**: تكامل سلس مع أطر الذكاء الاصطناعي الشائعة
- **واجهة برمجة تطبيقات RESTful**: واجهة خدمة ويب كاملة
- **واجهة Vue الأمامية**: واجهة ويب بديهية لإدارة الخدمات

## التثبيت والإعداد

### التثبيت السريع

أبسط طريقة للبدء مع MCPStore هي من خلال pip:

```bash
pip install mcpstore
```

### التحقق من التثبيت

بعد التثبيت، يمكنك التحقق من أن MCPStore يعمل بشكل صحيح:

```python
from mcpstore import MCPStore

# تهيئة المتجر
store = MCPStore.setup_store()
print("تم تهيئة MCPStore بنجاح!")
```

## الاستخدام الأساسي

### إعداد خدمة MCP الأولى

لنبدأ بمثال أساسي لإضافة واستخدام خدمة MCP:

```python
from mcpstore import MCPStore

# تهيئة المتجر
store = MCPStore.setup_store()

# إضافة خدمة إلى المتجر العام
store.for_store().add_service({
    "name": "mcpstore-wiki",
    "url": "https://mcpstore.wiki/mcp"
})

# قائمة الأدوات المتاحة
tools = store.for_store().list_tools()
print(f"الأدوات المتاحة: {len(tools)}")

# استخدام أداة (مثال)
# result = store.for_store().use_tool(tools[0].name, {"query": "مرحبا!"})
```

### فهم تصميم الاستدعاء المتسلسل

يستخدم MCPStore تصميم استدعاء متسلسل يوفر عزل سياق واضح:

```python
# مساحة المتجر العامة - مشتركة عبر جميع الوكلاء
global_context = store.for_store()

# مساحة خاصة بالوكيل - معزولة لكل وكيل
agent_context = store.for_agent("my-agent-id")
```

## عزل الوكلاء المتعددين

إحدى أقوى ميزات MCPStore هي قدرتها على إنشاء بيئات معزولة لوكلاء ذكاء اصطناعي مختلفين.

### إنشاء بيئات وكيل معزولة

```python
from mcpstore import MCPStore

# تهيئة المتجر
store = MCPStore.setup_store()

# إنشاء وكيل إدارة المعرفة مع أدوات Wiki
agent_id1 = "knowledge-agent"
knowledge_agent = store.for_agent(agent_id1)
knowledge_agent.add_service({
    "name": "mcpstore-wiki",
    "url": "http://mcpstore.wiki/mcp"
})

# إنشاء وكيل دعم التطوير مع أدوات مختلفة
agent_id2 = "development-agent"
dev_agent = store.for_agent(agent_id2)
dev_agent.add_service({
    "name": "mcpstore-demo",
    "url": "http://mcpstore.wiki/mcp"
})

# كل وكيل لديه مجموعة أدوات معزولة تماماً
knowledge_tools = store.for_agent(agent_id1).list_tools()
dev_tools = store.for_agent(agent_id2).list_tools()

print(f"أدوات وكيل المعرفة: {len(knowledge_tools)}")
print(f"أدوات وكيل التطوير: {len(dev_tools)}")
```

### فوائد عزل الوكلاء المتعددين

- **الأمان**: كل وكيل يمكنه الوصول فقط إلى أدواته المخصصة
- **التنظيم**: فصل واضح للاهتمامات بين أدوار الوكلاء المختلفة
- **قابلية التوسع**: سهولة إضافة وكلاء جدد دون التأثير على الموجودين
- **التصحيح**: البيئات المعزولة تجعل استكشاف الأخطاء أسهل

## تكامل LangChain

يوفر MCPStore تكاملاً سلساً مع LangChain، مما يجعل من السهل دمج أدوات MCP في سير عمل الذكاء الاصطناعي الخاص بك.

### مثال LangChain كامل

```python
from langchain.agents import create_tool_calling_agent, AgentExecutor
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import ChatOpenAI
from mcpstore import MCPStore

# إعداد MCPStore
store = MCPStore.setup_store()
store.for_store().add_service({
    "name": "mcpstore-wiki",
    "url": "https://mcpstore.wiki/mcp"
})

# الحصول على أدوات لـ LangChain
tools = store.for_store().for_langchain().list_tools()

# تكوين LLM (استبدل بمفتاح API الخاص بك)
llm = ChatOpenAI(
    temperature=0,
    model="gpt-4",
    openai_api_key="your-api-key-here"
)

# إنشاء قالب المطالبة
prompt = ChatPromptTemplate.from_messages([
    ("system", "أنت مساعد مفيد لديك وصول إلى أدوات متنوعة."),
    ("human", "{input}"),
    ("placeholder", "{agent_scratchpad}"),
])

# إنشاء وتكوين الوكيل
agent = create_tool_calling_agent(llm, tools, prompt)
agent_executor = AgentExecutor(agent=agent, tools=tools, verbose=True)

# تنفيذ الاستعلام
query = "ما المعلومات التي يمكنك تقديمها حول MCPStore؟"
response = agent_executor.invoke({"input": query})
print(f"الاستجابة: {response['output']}")
```

### مقدمي LLM البديلين

يعمل MCPStore مع مقدمي LLM متنوعين. مثال مع DeepSeek:

```python
llm = ChatOpenAI(
    temperature=0,
    model="deepseek-chat",
    openai_api_key="your-deepseek-api-key",
    openai_api_base="https://api.deepseek.com"
)
```

## واجهة Web API

يوفر MCPStore واجهة برمجة تطبيقات RESTful كاملة للتطبيقات المستندة إلى الويب.

### بدء خادم API

```python
from mcpstore import MCPStore

# إعداد وبدء خادم API
prod_store = MCPStore.setup_store()
prod_store.start_api_server(host='0.0.0.0', port=18200)
```

أو باستخدام سطر الأوامر:

```bash
mcpstore run api
```

### نقاط النهاية الرئيسية لواجهة برمجة التطبيقات

#### إدارة الخدمات

```bash
# إضافة خدمة جديدة
curl -X POST http://localhost:18200/for_store/add_service \
  -H "Content-Type: application/json" \
  -d '{"name": "my-service", "url": "https://example.com/mcp"}'

# قائمة جميع الخدمات
curl -X GET http://localhost:18200/for_store/list_services

# حذف خدمة
curl -X POST http://localhost:18200/for_store/delete_service \
  -H "Content-Type: application/json" \
  -d '{"name": "my-service"}'
```

#### عمليات الأدوات

```bash
# قائمة الأدوات المتاحة
curl -X GET http://localhost:18200/for_store/list_tools

# تنفيذ أداة
curl -X POST http://localhost:18200/for_store/use_tool \
  -H "Content-Type: application/json" \
  -d '{"tool_name": "search", "parameters": {"query": "مرحبا"}}'
```

#### المراقبة والصحة

```bash
# الحصول على إحصائيات النظام
curl -X GET http://localhost:18200/for_store/get_stats

# فحص الصحة
curl -X GET http://localhost:18200/for_store/health
```

## واجهة Vue الأمامية

يتضمن MCPStore واجهة Vue.js أمامية جميلة لإدارة الخدمات البديهية.

### ميزات واجهة الويب

- **إدارة الخدمات**: إضافة وإزالة وتكوين خدمات MCP
- **تصور الأدوات**: عرض الأدوات المتاحة ومعاملاتها
- **المراقبة في الوقت الفعلي**: مراقبة صحة الخدمة وإحصائيات الاستخدام
- **دعم متعدد اللغات**: واجهة متاحة بلغات متعددة

### الوصول إلى واجهة الويب

بعد بدء خادم API، يمكنك الوصول إلى واجهة الويب على:

```
http://localhost:18200
```

توفر الواجهة:
- لوحة تحكم مع نظرة عامة على الخدمات
- مستكشف أدوات مع اختبار تفاعلي
- إدارة التكوين
- تحليلات الاستخدام

## التكوين المتقدم

### تكوين خدمة مخصصة

```python
# تكوين خدمة متقدم
service_config = {
    "name": "custom-service",
    "url": "https://your-mcp-service.com/mcp",
    "timeout": 30,
    "retry_attempts": 3,
    "headers": {
        "Authorization": "Bearer your-token",
        "Custom-Header": "value"
    }
}

store.for_store().add_service(service_config)
```

### إعداد خاص بالبيئة

```python
import os
from mcpstore import MCPStore

# إعداد الإنتاج
if os.getenv('ENVIRONMENT') == 'production':
    store = MCPStore.setup_store(
        config_path='/etc/mcpstore/config.json',
        log_level='INFO'
    )
else:
    # إعداد التطوير
    store = MCPStore.setup_store(log_level='DEBUG')
```

## أفضل الممارسات

### 1. تنظيم الخدمات

```python
# تنظيم الخدمات حسب الوظيفة
store.for_agent("web-scraper").add_service({
    "name": "web-scraping-tools",
    "url": "https://scraping-service.com/mcp"
})

store.for_agent("data-analyst").add_service({
    "name": "analytics-tools",
    "url": "https://analytics-service.com/mcp"
})
```

### 2. معالجة الأخطاء

```python
try:
    result = store.for_store().use_tool("search", {"query": "اختبار"})
    print(f"نجح: {result}")
except Exception as e:
    print(f"خطأ في استخدام الأداة: {e}")
```

### 3. إدارة الموارد

```python
# تنظيف الموارد عند الانتهاء
store.cleanup()
```

## استكشاف الأخطاء وإصلاحها

### المشاكل الشائعة والحلول

#### 1. مشاكل اتصال الخدمة

```python
# فحص صحة الخدمة
services = store.for_store().list_services()
for service in services:
    health = store.for_store().check_service_health(service.name)
    print(f"{service.name}: {health}")
```

#### 2. فشل تنفيذ الأداة

```python
# تصحيح تنفيذ الأداة
tools = store.for_store().list_tools()
for tool in tools:
    print(f"الأداة: {tool.name}")
    print(f"المعاملات: {tool.parameters}")
    print(f"الوصف: {tool.description}")
```

#### 3. مشاكل خادم API

```bash
# فحص ما إذا كان خادم API يعمل
curl -X GET http://localhost:18200/for_store/health

# فحص سجلات الخادم
mcpstore logs
```

## تحسين الأداء

### 1. تجميع الاتصالات

```python
# تكوين تجميع الاتصالات لأداء أفضل
store = MCPStore.setup_store(
    max_connections=10,
    connection_timeout=30
)
```

### 2. التخزين المؤقت

```python
# تمكين التخزين المؤقت للأدوات المستخدمة بكثرة
store.for_store().enable_caching(
    cache_size=100,
    cache_ttl=300  # 5 دقائق
)
```

## اعتبارات الأمان

### 1. مصادقة API

```python
# تكوين مصادقة API
store.start_api_server(
    host='0.0.0.0',
    port=18200,
    auth_token='your-secure-token'
)
```

### 2. التحقق من الخدمة

```python
# التحقق من الخدمات قبل الإضافة
def validate_service(service_config):
    required_fields = ['name', 'url']
    return all(field in service_config for field in required_fields)

if validate_service(service_config):
    store.for_store().add_service(service_config)
```

## أمثلة التكامل

### 1. تكامل FastAPI

```python
from fastapi import FastAPI
from mcpstore import MCPStore

app = FastAPI()
store = MCPStore.setup_store()

@app.post("/execute-tool")
async def execute_tool(tool_name: str, parameters: dict):
    result = store.for_store().use_tool(tool_name, parameters)
    return {"result": result}
```

### 2. تكامل Django

```python
# views.py
from django.http import JsonResponse
from mcpstore import MCPStore

store = MCPStore.setup_store()

def execute_tool(request):
    tool_name = request.POST.get('tool_name')
    parameters = request.POST.get('parameters', {})
    
    result = store.for_store().use_tool(tool_name, parameters)
    return JsonResponse({"result": result})
```

## المجتمع والمساهمة

MCPStore هو مشروع مفتوح المصدر نشط يرحب بمساهمات المجتمع:

- **مستودع GitHub**: [https://github.com/whillhill/mcpstore](https://github.com/whillhill/mcpstore)
- **الوثائق**: [doc.mcpstore.wiki](http://doc.mcpstore.wiki/)
- **المشاكل**: الإبلاغ عن الأخطاء وطلب الميزات على GitHub
- **طلبات السحب**: المساهمة في تحسينات الكود

### طرق المساهمة

1. ⭐ إعطاء نجمة للمشروع على GitHub
2. 🐛 الإبلاغ عن الأخطاء والمشاكل
3. 🔧 تقديم طلبات السحب
4. 💬 مشاركة تجارب الاستخدام
5. 📖 تحسين الوثائق

## الخلاصة

يمثل MCPStore تقدماً مهماً في إدارة خدمات MCP لتطبيقات الذكاء الاصطناعي. تصميمه الأنيق وقدرات عزل الوكلاء المتعددين وخيارات التكامل الشاملة تجعله أداة أساسية للمطورين الذين يعملون مع وكلاء الذكاء الاصطناعي.

النقاط الرئيسية:

- **إعداد سهل**: تثبيت pip بسيط وواجهة برمجة تطبيقات بديهية
- **دعم الوكلاء المتعددين**: بيئات معزولة لأدوار وكيل مختلفة
- **تكامل الإطار**: دعم سلس لـ LangChain وأطر أخرى
- **واجهة الويب**: واجهة Vue.js أمامية جميلة للإدارة المرئية
- **جاهز للإنتاج**: واجهة برمجة تطبيقات RESTful وهندسة معمارية قوية

سواء كنت تبني وكيل ذكاء اصطناعي واحد أو تدير نظام وكلاء متعددين معقد، يوفر MCPStore الأدوات والمرونة التي تحتاجها للنجاح.

## الخطوات التالية

1. قم بتثبيت MCPStore وجرب الأمثلة الأساسية
2. استكشف واجهة الويب ونقاط نهاية API
3. ادمج مع سير عمل الذكاء الاصطناعي الحالي
4. انضم إلى المجتمع وساهم في المشروع

ابدأ رحلة MCPStore اليوم واختبر مستقبل إدارة خدمات MCP!

---

*لمزيد من الدروس وموارد تطوير الذكاء الاصطناعي، قم بزيارة [Thaki Cloud](https://thakicloud.github.io).*


