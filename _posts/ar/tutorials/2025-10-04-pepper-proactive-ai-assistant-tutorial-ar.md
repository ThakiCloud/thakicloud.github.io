---
title: "Pepper: بناء مساعد AI استباقي مع بنية الأحداث في الوقت الفعلي"
excerpt: "دليل شامل لإعداد واستخدام Pepper، مساعد AI شخصي مفتوح المصدر يدير Gmail بشكل استباقي، يلخص رسائل البريد الإلكتروني المهمة، ويتعامل مع المهام تلقائيًا في الخلفية باستخدام بنية الأحداث."
seo_title: "دروس Pepper AI Assistant: مساعد شخصي استباقي في الوقت الفعلي - Thaki Cloud"
seo_description: "تعلم كيفية إعداد Pepper، المساعد AI الاستباقي من Berkeley Sky Computing Lab. دليل كامل يغطي التثبيت، تكامل Gmail، والبنية المبنية على الأحداث مع Feeds وScheduler وWorkers."
date: 2025-10-04
categories:
  - tutorials
tags:
  - مساعد-AI
  - بنية-الأحداث
  - تكامل-Gmail
  - أنظمة-Agentic
  - OpenAI
  - Python
author_profile: true
toc: true
toc_label: "جدول المحتويات"
lang: ar
permalink: /ar/tutorials/pepper-proactive-ai-assistant-tutorial/
canonical_url: "https://thakicloud.github.io/ar/tutorials/pepper-proactive-ai-assistant-tutorial/"
---

![مخطط مفاهيمي](/assets/images/pepper-proactive-ai-assistant-tutorial-hero.png)

⏱️ **وقت القراءة المتوقع**: 12 دقيقة

## المقدمة

**Pepper** يُحدث ثورة في طريقة تفاعلنا مع مساعدي الذكاء الاصطناعي. على عكس روبوتات الدردشة التقليدية التي تنتظر أوامرك بشكل سلبي، فإن Pepper **يعمل لك بشكل استباقي** في الخلفية، يراقب Gmail باستمرار، يلخص رسائل البريد الإلكتروني المهمة، يبرز التحديثات الحيوية، ويتعامل بشكل مستقل مع المهام المعقدة من خلال مجموعة من العمال المتخصصين.

طوره **فريق Agentica** في **Berkeley Sky Computing Lab**، ويمثل Pepper تحولًا جذريًا من الأنظمة التفاعلية المبنية على الطلبات إلى البنى المبنية على الأحداث في الوقت الفعلي. سيرشدك هذا الدرس خلال إعداد مثيل Pepper الخاص بك وفهم بنيته القوية.

### ما الذي يجعل Pepper مختلفًا؟

**روبوتات الدردشة التقليدية:**
- تنتظر أوامر المستخدم
- ثابتة وتفاعلية
- تنتهي المحادثة عندما تتوقف عن السؤال

**Pepper (المساعد الاستباقي من الجيل التالي):**
- يعمل باستمرار في الخلفية
- ديناميكي واستباقي
- يستمر في العمل حتى عندما لا تكون منخرطًا بنشاط
- يتعامل مع المهام المتوازية بشكل مستقل
- يوفر السياق قبل أن تسأل حتى

### الميزات الرئيسية

✅ **تكامل Gmail**: يراقب ويلخص رسائل البريد الإلكتروني تلقائيًا  
✅ **إشعارات استباقية**: يبرز التحديثات الحيوية التي تحتاج إلى الانتباه  
✅ **تفويض المهام**: يخصص المهام المعقدة لوكلاء العمال المتخصصين  
✅ **بنية الأحداث**: حلقة Sense-Think-Act مستمرة  
✅ **سياق في الوقت الفعلي**: يحافظ على سجل المحادثة وذاكرة المستخدم  
✅ **تصميم غير محظور**: يستجيب فورًا أثناء المعالجة في الخلفية


![مخطط مفاهيمي](/assets/images/pepper-proactive-ai-assistant-tutorial-diagram.svg)

*مخطط مفاهيمي*

## المتطلبات الأساسية

قبل البدء، تأكد من توفر:

- **نظام التشغيل**: macOS أو Linux أو Windows مع WSL
- **Python**: الإصدار 3.12 أو أعلى
- **Conda**: تثبيت Anaconda أو Miniconda
- **حساب Gmail**: للتكامل مع البريد الإلكتروني
- **مفاتيح API**:
  - مفتاح OpenAI API (مطلوب)
  - مفتاح Composio API (مطلوب لتكاملات الأدوات)

## دليل التثبيت

### الخطوة 1: استنساخ المستودع

أولاً، استنسخ مستودع Pepper مع الوحدات الفرعية:

```bash
git clone --recurse-submodules https://github.com/agentica-org/pepper
cd pepper
```

### الخطوة 2: إعداد بيئة Python

أنشئ وفعّل بيئة Conda مخصصة:

```bash
# إنشاء بيئة جديدة مع Python 3.12
conda create -n pepper python=3.12 pip -y
conda activate pepper
```

### الخطوة 3: تثبيت Episodic Context Store

يعتمد Pepper على **Episodic**، مخزن السياق الذي يعمل كعمود فقري للبيانات في الوقت الفعلي:

```bash
# تثبيت Episodic SDK مع دعم البحث الدلالي
cd episodic-sdk
pip install -e .[semantic]
```

### الخطوة 4: تثبيت تبعيات Pepper

انتقل إلى دليل Pepper وقم بتثبيت المتطلبات:

```bash
cd ../pepper
pip install -r requirements.txt
```

### الخطوة 5: تشغيل Context Store

قم بتشغيل خادم مخزن سياق Episodic:

```bash
episodic serve --port 8000
```

**مهم**: احتفظ بهذه العملية قيد التشغيل في الطرفية. افتح نافذة طرفية جديدة للخطوات التالية.

## التكوين

### الخطوة 1: إعداد متغيرات البيئة

انسخ ملف البيئة المثالي:

```bash
cd pepper
cp env_var.example.sh env_var.sh
```

### الخطوة 2: تكوين مفاتيح API

قم بتحرير `env_var.sh` باستخدام محرر النصوص المفضل لديك:

```bash
# مطلوب: مفتاح OpenAI API
export OPENAI_API_KEY="sk-your-openai-api-key-here"

# مطلوب: مفتاح Composio API (لـ Gmail وتكاملات الأدوات)
export COMPOSIO_API_KEY="your-composio-api-key-here"

# اختياري: تكوينات إضافية
export EPISODIC_HOST="http://localhost:8000"
```

**الحصول على مفاتيح API:**

1. **مفتاح OpenAI API**:
   - قم بزيارة [platform.openai.com](https://platform.openai.com)
   - انتقل إلى قسم API Keys
   - أنشئ مفتاحًا سريًا جديدًا

2. **مفتاح Composio API**:
   - سجل الدخول على [composio.dev](https://composio.dev)
   - أنشئ مشروعًا جديدًا
   - قم بإنشاء مفتاح API

### الخطوة 3: تحميل متغيرات البيئة

```bash
source env_var.sh
```

### الخطوة 4: تفويض الوصول إلى Gmail

قم بتشغيل إعداد خدمة البريد الإلكتروني (مرة واحدة فقط في المرة الأولى):

```bash
python -m pepper.services.email_service
```

**ما يمكن توقعه:**
1. سترى: `"Please authorize Gmail by visiting: [URL]"`
2. افتح الرابط في متصفحك
3. امنح أذونات الوصول إلى Gmail
4. انتظر: `"✅ Trigger subscribed successfully."`
5. اضغط `Ctrl+C` لإيقاف العملية

## تشغيل Pepper

### تشغيل Pepper

ابدأ Pepper بأمر واحد:

```bash
python -m pepper.launch_pepper
```

**ملاحظة الإعداد الأول**: يستغرق التشغيل الأول حوالي دقيقة واحدة لبناء ملف تعريف المستخدم.

### الوصول إلى واجهة الويب

بمجرد تشغيل Pepper، افتح متصفحك وانتقل إلى:

```
http://localhost:5050/pepper/ui.html
```

**مستخدمو الخادم البعيد**: يجب أن يقوم VS Code تلقائيًا بإعادة توجيه المنفذ إلى جهازك المحلي.

### إيقاف Pepper

لإيقاف جميع خدمات Pepper:

```bash
# اضغط Ctrl+C في الطرفية
```

## فهم بنية Pepper

تأتي قوة Pepper من **البنية المبنية على الأحداث في الوقت الفعلي** المبنية حول حلقة **Sense-Think-Act** المستمرة.

### المكونات الأساسية

#### 1. **Feeds (الاستشعار)**

**الغرض**: طبقة الإدخال الحسي للنظام

Feeds هي أنابيب ذكية تقوم بـ:
- مراقبة المصادر الخارجية (رسائل البريد الإلكتروني، الرسائل، التقويمات)
- تصفية الضوضاء
- تحويل البيانات الخام إلى إشارات نصية قابلة للتنفيذ
- الحفاظ على نسبة عالية من الإشارة إلى الضوضاء

**مثال**: عندما تصل رسالة بريد إلكتروني جديدة، يقوم Email Feed بـ:
1. التحقق من الكلمات الرئيسية وأهمية المرسل
2. تحديد مستوى الأولوية
3. تلخيص البريد الإلكتروني إلى إشارة موجزة:

```json
{
  "id": "evt_a1b2c3d4-e5f6-a7b8-c9d0-e1f2a3b4c5d6",
  "content": "طلب إجراء من Alice بشأن 'Project Phoenix'، الموعد النهائي غدًا.",
  "created_at": "2025-10-04T16:46:15Z"
}
```

#### 2. **Scheduler (التفكير)**

**الغرض**: الدماغ المركزي والمنسق

يقوم Scheduler بـ:
- الحفاظ على قائمة انتظار أحداث FIFO ذات أولوية
- استهلاك الإشارات من Feeds
- إثراء الأحداث بالسياق (سجل المحادثة، ذاكرة المستخدم)
- تحديد الإجراءات التي يجب اتخاذها
- العمل في وضع غير محظور للاستجابة الفورية

**الابتكار الرئيسي: استدعاءات الأدوات غير المتزامنة**

تفرض واجهات برمجة تطبيقات LLM التقليدية استدعاءات أدوات متزامنة، يجب أن تتوقف المحادثة حتى تعود الأداة. يحل Pepper هذه المشكلة من خلال:
- إلحاق استدعاءات الأدوات بسجل المحادثة
- الاستمرار في معالجة الأحداث الجديدة فورًا
- معالجة نتائج الأدوات بشكل غير متزامن عند وصولها

**قبل (متزامن - محظور):**
```javascript
{% raw %}
{
  "role": "assistant",
  "content": "بدء التحليل...",
  "tool_calls": [{"id": "tool_1", "function": "run_analysis"}]
},
// يجب الانتظار لنتيجة الأداة قبل قبول إدخال مستخدم جديد
{
  "role": "user",
  "content": "هل يمكنك إضافة فلتر?"  // غير قانوني بدون نتيجة الأداة
}
{% endraw %}
```

**بعد (غير متزامن - مستمر):**
```xml
<tool_call>
  id: tool_call_1
  function: run_analysis
</tool_call>

<user_msg>هل يمكنك إضافة فلتر للربع الأخير؟</user_msg>

<assistant_msg>بالتأكيد. سأضيف هذا الفلتر إلى التحليل.</assistant_msg>

<tool_result>
  id: tool_call_1
  result: {% raw %}{{ "initial_analysis_complete": true }}{% endraw %}
</tool_result>
```

#### 3. **Workers (الفعل)**

**الغرض**: وكلاء التنفيذ المتخصصون

Workers مجهزون بأدوات عبر MCP (Model Context Protocol) من أجل:
- إرسال رسائل البريد الإلكتروني
- إدارة أحداث التقويم
- البحث عن المعلومات
- تعيين التذكيرات
- تنفيذ المهام المعقدة طويلة الأمد

**نوعان من Workers:**

**Stateful Workers**: للمهام طويلة الأمد
- الحفاظ على الذاكرة عبر التفاعلات
- مثالي لإدارة سلاسل البريد الإلكتروني أو قوائم المهام
- الحالة مستمرة في Context Store

**Stateless Workers**: للوظائف لمرة واحدة
- مؤقت وفعال
- مثالي للاستعلامات السريعة أو المهام لمرة واحدة
- يعيد الإجابة النهائية وينتهي

#### 4. **Context Store**

**الغرض**: طبقة تقديم البيانات في الوقت الفعلي

Context Store هو العمود الفقري لـ Pepper، مشابه لمخازن الميزات في أنظمة ML ولكن مصمم لتنسيق الوكلاء المتعددين:

- **إدارة الحالة**: يحافظ الوكلاء على الحالة ويشاركونها
- **التقديم في الوقت الفعلي**: وصول فوري إلى البيانات الحديثة
- **تنسيق الأحداث**: تشغل التحديثات الإجراءات في المراحل اللاحقة

**واجهة API الأساسية:**
- `store()`: حفظ الأحداث في مساحات الأسماء
- `retrieve()`: الاستعلام عن السياقات المخزنة
- `subscribe()`: الاستماع للتحديثات

## مثال تدفق النظام

دعونا نمر بكيفية معالجة Pepper لبريد إلكتروني مهم:

### الخطوة 1: وصول البريد الإلكتروني (Feed - الاستشعار)

```python
# تشغيل webhook لـ Gmail
@app.on_event("new_email")
async def ingest_raw_event(data: dict):
    await context_store.store(
        context_id=data.get("id", None) or uuid.uuid(),
        data=data,
        namespace="raw.email"
    )
```

### الخطوة 2: Feed يعالج الإشارة

```python
# Email Feed يشترك في رسائل البريد الإلكتروني الخام
@subscriber.on_context_update(namespaces=["raw.email"])
async def email_feed(update: ContextUpdate):
    # البحث عن السياق ذي الصلة باستخدام البحث الدلالي
    related_docs = await context_store.search(text=update.context.text)
    processed_signal = process_email_signal(update.context, related_docs)
    
    # نشر الإشارة المعالجة
    await context_store.store(
        context_id="processed_" + update.context.context_id,
        data=processed_signal,
        namespace="signals.processed"
    )
```

### الخطوة 3: Scheduler يتفاعل (Scheduler - التفكير)

```python
# Scheduler يضيف الإشارة إلى قائمة انتظار الأولوية
@subscriber.on_context_update(namespaces=["signals.*"])
async def add_to_queue(self, update: ContextUpdate):
    priority = determine_priority(update.context.data)
    await self.priority_queue.put((priority, update))

# Scheduler يعالج القائمة بشكل مستمر
async def scheduler_step(self):
    events = await self.get_batch_events()
    self.state_tracker.add_events(events)
    
    messages = [
        {"role": "system", "content": SCHEDULER_SYSTEM_PROMPT},
        {"role": "user", "content": self.state_tracker.get_user_prompt()},
    ]
    
    response = await create_completion(messages, self.tools)
    self.state_tracker.add_event(response)
    
    # جدولة استدعاءات الأدوات للتنفيذ في الخلفية
    if response.tool_calls:
        for tool_call in response.tool_calls:
            self.tool_call_engine.schedule(tool_call)
```

### الخطوة 4: Worker ينفذ الإجراء (Worker - الفعل)

```python
# Worker يرسل إشعارًا للمستخدم
await worker.execute_tool("send_notification", {
    "message": "بريد إلكتروني عاجل من Alice حول Project Phoenix - الموعد النهائي غدًا",
    "priority": "high"
})
```

## حالات الاستخدام العملية

### 1. إدارة البريد الإلكتروني

**السيناريو**: تتلقى أكثر من 50 بريدًا إلكترونيًا يوميًا، معظمها غير مهم.

**كيف يساعد Pepper**:
- مراقبة Gmail بشكل مستمر
- تصفية على أساس أهمية المرسل والكلمات الرئيسية
- تلخيص رسائل البريد الإلكتروني الحرجة فقط
- إبراز عناصر الإجراءات مع المواعيد النهائية
- إشعارك بشكل استباقي

### 2. الاستعداد للاجتماعات

**السيناريو**: لديك اجتماع بعد ساعتين.

**كيف يساعد Pepper**:
- كشف الاجتماع من التقويم
- البحث عن رسائل البريد الإلكتروني والمستندات ذات الصلة
- إعداد وثيقة الإحاطة
- إبراز نقاط المناقشة الرئيسية
- تنبيهك قبل 30 دقيقة

### 3. تفويض المهام

**السيناريو**: تحتاج إلى تحليل مجموعة بيانات كبيرة.

**كيف يساعد Pepper**:
- قبول وصف المهمة
- التفويض إلى Data Worker المتخصص
- Worker يقوم بتشغيل التحليل في الخلفية
- يمكنك الاستمرار في المحادثات الأخرى
- تلقي تحديث استباقي عند الاكتمال

### 4. إدارة المتابعة

**السيناريو**: تنتظر ردودًا من عدة أشخاص.

**كيف يساعد Pepper**:
- تتبع المتابعات المعلقة
- مراقبة رسائل البريد الإلكتروني الواردة
- مطابقة الردود مع الطلبات الأصلية
- إشعارك عند استلام جميع الردود
- تلخيص النتائج

## التكوين المتقدم

### تخصيص Feeds

إنشاء خلاصات مخصصة لمصادر بيانات مختلفة:

```python
# مثال على Slack Feed مخصص
@subscriber.on_context_update(namespaces=["raw.slack"])
async def slack_feed(update: ContextUpdate):
    message = update.context.data
    
    # تصفية للإشارات العاجلة
    if "@urgent" in message["text"] or message["user"] in IMPORTANT_USERS:
        processed_signal = {
            "content": f"رسالة Slack عاجلة من {message['user']}: {message['text']}",
            "priority": "high",
            "source": "slack"
        }
        
        await context_store.store(
            data=processed_signal,
            namespace="signals.processed"
        )
```

### ضبط أولوية Scheduler

تعديل أولويات الأحداث في Scheduler:

```python
def determine_priority(event_data):
    """منطق الأولوية المخصص"""
    if "urgent" in event_data.get("content", "").lower():
        return 1  # أعلى أولوية
    elif event_data.get("source") == "email":
        return 2
    elif event_data.get("source") == "calendar":
        return 3
    else:
        return 4  # أدنى أولوية
```

### إنشاء Workers مخصصة

بناء عمال متخصصين لمهام محددة:

```python
class DataAnalysisWorker(StatefulWorker):
    """Worker متخصص في مهام تحليل البيانات"""
    
    def __init__(self):
        super().__init__()
        self.tools = [
            "run_sql_query",
            "generate_visualization",
            "calculate_statistics"
        ]
    
    async def execute_task(self, task_description):
        # تحميل الحالة السابقة إذا كانت موجودة
        state = await self.load_state()
        
        # تنفيذ التحليل
        result = await self.run_analysis(task_description)
        
        # حفظ الحالة
        await self.save_state(result)
        
        # العودة إلى المجدول
        return result
```

## استكشاف الأخطاء وإصلاحها

### المشاكل الشائعة

#### 1. فشل تفويض Gmail

**المشكلة**: لا يمكن تفويض الوصول إلى Gmail

**الحل**:
```bash
# حذف بيانات الاعتماد الموجودة
rm -rf ~/.credentials/pepper/

# إعادة تشغيل التفويض
python -m pepper.services.email_service
```

#### 2. خادم Episodic لا يعمل

**المشكلة**: `Connection refused to localhost:8000`

**الحل**:
```bash
# التحقق من تشغيل episodic
ps aux | grep episodic

# إذا لم يكن قيد التشغيل، ابدأه
conda activate pepper
episodic serve --port 8000
```

#### 3. مفاتيح API مفقودة

**المشكلة**: أخطاء `API key not found`

**الحل**:
```bash
# التحقق من تحميل متغيرات البيئة
echo $OPENAI_API_KEY
echo $COMPOSIO_API_KEY

# إذا كانت فارغة، أعد تحميل البيئة
source env_var.sh
```

#### 4. التشغيل الأول يستغرق وقتًا طويلاً

**المشكلة**: بناء الملف الشخصي الأولي يتجاوز دقيقتين

**الحل**:
- هذا طبيعي للإعداد الأول
- تحقق من موارد النظام (CPU، الذاكرة)
- تأكد من اتصال إنترنت مستقر
- انتظر بصبر، التشغيلات اللاحقة أسرع

## أفضل الممارسات

### 1. إدارة البريد الإلكتروني

- **تكوين الفلاتر**: قم بإعداد فلاتر البريد الإلكتروني في Gmail لتقليل الضوضاء
- **جهات الاتصال المهمة**: قم بوضع علامة على المرسلين المهمين كـ VIP
- **مراجعة الملخصات**: تحقق من ملخصات Pepper يوميًا
- **ضبط الأولويات**: ضبط دقيق لما يُعتبر "مهمًا"

### 2. إدارة السياق

- **التنظيف المنتظم**: قم بتنظيف بيانات السياق القديمة بشكل دوري
- **تنظيم مساحة الأسماء**: استخدم اصطلاحات واضحة لمساحة الأسماء
- **إصدار الحالة**: إصدار حالات الوكيل لقدرة الاستعادة

### 3. تحسين Worker

- **تفصيل المهام**: قسّم المهام الكبيرة إلى أجزاء أصغر
- **إعدادات المهلة**: قم بتعيين مهل معقولة للمهام طويلة الأمد
- **معالجة الأخطاء**: نفذ استرداد خطأ قوي في العمال

### 4. الأمان

- **تدوير مفاتيح API**: قم بتدوير مفاتيح API بانتظام
- **التحكم في الوصول**: قصر نطاق Gmail على القراءة فقط عندما يكون ذلك ممكنًا
- **سجلات التدقيق**: راقب إجراءات Pepper بانتظام
- **خصوصية البيانات**: كن حذرًا من المعلومات الحساسة في رسائل البريد الإلكتروني

## تحسين الأداء

### 1. ضبط Scheduler

```python
# ضبط حجم الدفعة لمعالجة الأحداث
SCHEDULER_BATCH_SIZE = 5  # معالجة 5 أحداث لكل دورة

# تعيين الحد الأقصى لحجم القائمة
MAX_QUEUE_SIZE = 100  # منع مشاكل الذاكرة
```

### 2. تحسين Context Store

```bash
# تفعيل التخزين المؤقت للبحث الدلالي
export EPISODIC_CACHE_ENABLED=true
export EPISODIC_CACHE_TTL=3600  # ساعة واحدة
```

### 3. إدارة مجمع Worker

```python
# تكوين حجم مجمع Worker
MAX_CONCURRENT_WORKERS = 10
WORKER_TIMEOUT = 300  # 5 دقائق
```

## المقارنة مع المساعدين التقليديين

| الميزة | روبوت الدردشة التقليدي | Pepper |
|--------|----------------------|--------|
| **نموذج التفاعل** | تفاعلي (انتظار الأمر) | استباقي (مراقبة مستمرة) |
| **معالجة المهام** | تسلسلي | متوازي |
| **الوعي بالسياق** | محدود للمحادثة | السياق الكامل من مصادر متعددة |
| **وقت الاستجابة** | فوري لكن محدود | معالجة خلفية + إشعارات فورية |
| **تنفيذ الأدوات** | متزامن (محظور) | غير متزامن (غير محظور) |
| **الذاكرة** | على أساس الجلسة | مستمر عبر الجلسات |
| **قابلية التوسع** | محادثة واحدة | مهام متوازية متعددة |

## التحسينات المستقبلية

تمكّن بنية Pepper من قدرات مستقبلية مثيرة:

### 1. Feeds التنبؤية

Feeds تتوقع الاحتياجات قبل حدوث الأحداث:
- جدولة إعداد الاجتماع _قبل_ قبول دعوة التقويم
- إعداد مستندات السفر فور حجز الرحلة
- صياغة ردود على أنماط البريد الإلكتروني الشائعة

### 2. التنسيق متعدد المستخدمين

الفرق تعمل مع مثيلات Pepper المشتركة:
- إدارة المهام التعاونية
- قاعدة معرفة وسياق مشتركة
- إشعارات وملخصات على مستوى الفريق

### 3. التعلم المتقدم

Pepper يتعلم من سلوكك:
- إعدادات أولوية شخصية
- قواعد أتمتة مخصصة
- التعرف على أنماط السلوك

## الموارد

### الروابط الرسمية

- **مستودع GitHub**: [github.com/agentica-org/pepper](https://github.com/agentica-org/pepper)
- **مقالة المدونة**: [التحليل العميق لبنية Pepper](https://agentica-project.com/post.html?post=pepper.md)
- **مشروع Agentica**: [agentica-project.com](https://agentica-project.com)
- **Berkeley Sky Computing Lab**: المختبر البحثي الداعم للمشروع

### التقنيات ذات الصلة

- **Episodic SDK**: [github.com/agentica-org/episodic-sdk](https://github.com/agentica-org/episodic-sdk)
- **Composio**: [composio.dev](https://composio.dev)
- **OpenAI API**: [platform.openai.com](https://platform.openai.com)

### قراءات إضافية

1. [بنية الأحداث في الأنظمة الموزعة](https://miladezzat.medium.com/event-driven-architecture-how-to-implement-in-distributed-systems-29bd82b02ace)
2. [ChatGPT Pulse: الذكاء الاصطناعي الاستباقي من الجيل التالي](https://openai.com/index/introducing-chatgpt-pulse/)
3. [منصة Michelangelo ML من Uber](https://www.uber.com/blog/michelangelo-machine-learning-platform/)

## الخاتمة

يمثل Pepper تحولًا نموذجيًا في تكنولوجيا المساعد AI، من المستجيبين السلبيين إلى الشركاء الاستباقيين. من خلال الاستفادة من البنية المبنية على الأحداث مع حلقة Sense-Think-Act، يعمل Pepper بشكل مستمر من أجلك، ويتعامل مع المهام المعقدة في الخلفية بينما يبقيك على اطلاع بما يهم حقًا.

تجعل الطبيعة مفتوحة المصدر لـ Pepper، جنبًا إلى جنب مع بنيته المعيارية، منصة مثالية للتجربة مع أنظمة agentic من الجيل التالي. سواء كنت تبحث عن أتمتة إدارة البريد الإلكتروني، أو بناء سير عمل مخصص، أو استكشاف تنسيق AI في الوقت الفعلي، يوفر Pepper أساسًا صلبًا.

**النقاط الرئيسية:**

✅ Pepper يحول مساعدة AI من تفاعلية إلى استباقية  
✅ البنية المبنية على الأحداث تمكن من تنفيذ المهام المتوازية غير المحظورة  
✅ التصميم المعياري (Feeds، Scheduler، Workers، Context Store) يسمح بالتخصيص السهل  
✅ تكامل Gmail يوفر قيمة عملية فورية  
✅ مفتوح المصدر ومطور بنشاط من قبل فريق Agentica في Berkeley

## الشكر والتقدير

تم تطوير Pepper بواسطة **فريق Agentica** كجزء من **Berkeley Sky Computing Lab**، بدعم من **Laude Institute** مع منح حوسبة من **AWS** و **Hyperbolic**.

---

**هل لديك أسئلة أو ملاحظات؟** لا تتردد في المساهمة في المشروع على GitHub أو الانضمام إلى مناقشات المجتمع!

🔗 **GitHub**: [github.com/agentica-org/pepper](https://github.com/agentica-org/pepper)  
📧 **اتصال**: تحقق من المستودع لقنوات المجتمع

**الخطوات التالية:**
- قم بإعداد مثيل Pepper الخاص بك باتباع هذا الدليل
- استكشف قاعدة الكود وخصص الخلاصات
- قم ببناء العمال الخاصة بك لمهام محددة
- شارك تجربتك مع المجتمع!

برمجة سعيدة! 🚀


