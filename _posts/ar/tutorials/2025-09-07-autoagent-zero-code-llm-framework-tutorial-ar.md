---
title: "AutoAgent: الدليل الشامل لإطار عمل LLM بدون كود"
excerpt: "تعلم كيفية بناء ونشر وكلاء LLM مؤتمتين بالكامل باستخدام AutoAgent - لا يتطلب أي برمجة. دليل تعليمي شامل من التثبيت إلى الميزات المتقدمة."
seo_title: "دليل AutoAgent: إطار عمل LLM بدون كود - Thaki Cloud"
seo_description: "إتقان إطار عمل AutoAgent لبناء وكلاء LLM مؤتمتين بدون برمجة. دليل تعليمي خطوة بخطوة يغطي التثبيت وإعداد Docker ونشر الوكلاء."
date: 2025-09-07
categories:
  - tutorials
tags:
  - AutoAgent
  - LLM
  - وكلاء-الذكاء-الاصطناعي
  - Docker
  - التعلم-الآلي
  - الأتمتة
author_profile: true
toc: true
toc_label: "المحتويات"
lang: ar
permalink: /ar/tutorials/autoagent-zero-code-llm-framework/
canonical_url: "https://thakicloud.github.io/ar/tutorials/autoagent-zero-code-llm-framework/"
published: false
---

⏱️ **وقت القراءة المتوقع**: 15 دقيقة

هل تعبت من متطلبات البرمجة المعقدة لبناء وكلاء LLM؟ تعرف على **AutoAgent** - إطار عمل ثوري مؤتمت بالكامل وبدون كود يتيح لك إنشاء وكلاء ذكاء اصطناعي متطورين دون كتابة سطر واحد من الكود! 🚀

## ما هو AutoAgent؟

[AutoAgent](https://github.com/HKUDS/AutoAgent) هو إطار عمل رائد طورته HKUDS يمكّن أي شخص من بناء ونشر وإدارة وكلاء LLM دون معرفة برمجية. مع أكثر من **6,000 نجمة** على GitHub، أصبح الحل المفضل لتطوير الوكلاء المؤتمتين.

### الميزات الرئيسية

- **🚫 لا يتطلب كود**: بناء الوكلاء من خلال واجهات بديهية
- **🔄 مؤتمت بالكامل**: تدفقات عمل وكلاء ذاتية الإدارة
- **🐳 تكامل Docker**: نشر مُحاوي للاتساق
- **🌐 دعم متعدد النماذج**: يعمل مع OpenAI و Anthropic و Google وغيرها
- **📊 تقييم مدمج**: دعم معايير GAIA و Agentic-RAG
- **🛠️ تكامل الأدوات**: اتصالات سلسة بأدوات الطرف الثالث

## المتطلبات المسبقة

قبل الغوص في AutoAgent، تأكد من توفر ما يلي:

### متطلبات النظام

```bash
# فحص نظامك
uname -a
python --version  # Python 3.8+ مطلوب
docker --version  # Docker مطلوب للنشر المُحاوي
```

### التبعيات المطلوبة

- **Python 3.8+**
- **Docker** (للوضع المُحاوي)
- **Git** (لاستنساخ المستودع)
- **مفاتيح API** لمزود LLM المفضل لديك

## دليل التثبيت

### الطريقة 1: استخدام pip (موصى بها)

```bash
# تثبيت AutoAgent من PyPI
pip install autoagent

# التحقق من التثبيت
auto --help
```

### الطريقة 2: من المصدر

```bash
# استنساخ المستودع
git clone https://github.com/HKUDS/AutoAgent.git
cd AutoAgent

# تثبيت التبعيات
pip install -e .

# إعداد البيئة
cp .env.template .env
```

## تكوين البيئة

### إعداد مفاتيح API

إنشاء وتكوين ملف `.env` الخاص بك مع مزود LLM المفضل لديك:

```bash
# لـ OpenAI
OPENAI_API_KEY=your_openai_api_key

# لـ Anthropic (Claude)
ANTHROPIC_API_KEY=your_anthropic_api_key

# لـ Google Gemini
GEMINI_API_KEY=your_gemini_api_key

# لـ Mistral
MISTRAL_API_KEY=your_mistral_api_key

# لـ Hugging Face
HUGGINGFACE_API_KEY=your_huggingface_api_key
```

### تكوين Docker

للنشر الإنتاجي، يستفيد AutoAgent من Docker للبيئات المتسقة:

```bash
# سحب أحدث صورة Docker لـ AutoAgent
docker pull autoagent/autoagent:latest

# التحقق من إعداد Docker
docker run --rm autoagent/autoagent:latest --help
```

## دليل البداية السريعة

### الخطوة 1: تشغيل AutoAgent

اختر طريقة النشر بناءً على احتياجاتك:

#### الخيار أ: التشغيل المباشر (للتطوير)

```bash
# البدء بالإعدادات الافتراضية (Claude-3.5-Sonnet)
auto main

# البدء بنموذج محدد
COMPLETION_MODEL=gpt-4o auto main
```

#### الخيار ب: تشغيل Docker (للإنتاج)

```bash
# تشغيل النسخة المُحاواة
auto main --container_name autoagent_prod --port 8080
```

### الخطوة 2: اختيار الوضع

يوفر AutoAgent أوضاع تشغيل متعددة:

1. **وضع المستخدم**: محادثات وكيل تفاعلية
2. **محرر الوكيل**: تصميم وكلاء مخصصين
3. **محرر سير العمل**: إنشاء تدفقات عمل معقدة
4. **البحث العميق**: خطوط أنابيب بحث مؤتمتة

### الخطوة 3: إنشاء وكيلك الأول

دعونا ننشئ مساعد بحث بسيط:

```bash
# تشغيل في وضع محرر الوكيل
auto main --mode agent_editor

# اتبع المطالبات التفاعلية لـ:
# 1. تحديد غرض الوكيل
# 2. اختيار الأدوات والقدرات
# 3. تكوين معاملات السلوك
# 4. الاختبار والنشر
```

## التكوين المتقدم

### إعداد متعدد النماذج

يدعم AutoAgent مزودي LLM المختلفين. إليك كيفية تكوين كل منهم:

#### تكوين OpenAI

```bash
# إعداد البيئة
export OPENAI_API_KEY=your_key
export COMPLETION_MODEL=gpt-4o

# التشغيل
auto main
```

#### تكوين Anthropic Claude

```bash
# إعداد البيئة
export ANTHROPIC_API_KEY=your_key
export COMPLETION_MODEL=claude-3-5-sonnet-20241022

# التشغيل
auto main
```

#### تكوين Google Gemini

```bash
# إعداد البيئة
export GEMINI_API_KEY=your_key
export COMPLETION_MODEL=gemini/gemini-2.0-flash

# التشغيل
auto main
```

### تكامل الأدوات المخصصة

يدعم AutoAgent أدوات الطرف الثالث من خلال منصات مختلفة:

#### تكامل RapidAPI

```bash
# معالجة وثائق الأدوات
python process_tool_docs.py

# أضف مفاتيح RapidAPI عندما يُطلب منك
# ستكون الأدوات متاحة تلقائياً في وكلائك
```

#### استيراد ملفات تعريف الارتباط للمتصفح

للوكلاء الذين يحتاجون إلى الوصول للويب:

```bash
# انتقل إلى مجلد ملفات تعريف الارتباط
cd cookies/

# اتبع التعليمات لاستيراد ملفات تعريف ارتباط المتصفح
# هذا يمكّن وصولاً أفضل للمواقع لوكلائك
```

## حالات الاستخدام والأمثلة

### 1. وكيل البحث المؤتمت

مثالي للبحث الأكاديمي وتحليل السوق:

```bash
# تشغيل وضع البحث العميق
auto deep-research

# تكوين معاملات البحث:
# - الموضوع: "أحدث اتجاهات الذكاء الاصطناعي في 2025"
# - المصادر: أوراق أكاديمية، أخبار، تقارير
# - تنسيق الإخراج: تقرير شامل
```

### 2. وكيل دعم العملاء

بناء حلول خدمة عملاء ذكية:

```bash
# إنشاء وكيل دعم مع:
# - تكامل قاعدة المعرفة
# - قدرات توجيه التذاكر
# - دعم متعدد اللغات
# - بروتوكولات التصعيد
```

### 3. وكيل إنشاء المحتوى

أتمتة تدفقات عمل إنتاج المحتوى:

```bash
# تكوين وكيل محتوى لـ:
# - إنتاج مقالات المدونة
# - محتوى وسائل التواصل الاجتماعي
# - الوثائق التقنية
# - تحسين SEO
```

## دليل استكشاف الأخطاء وإصلاحها

### المشاكل الشائعة والحلول

#### المشكلة 1: مشاكل اتصال Docker

```bash
# فحص حالة Docker
docker info

# إعادة تشغيل خدمة Docker
sudo systemctl restart docker

# اختبار الاتصال
docker run hello-world
```

#### المشكلة 2: مصادقة مفتاح API

```bash
# التحقق من متغيرات البيئة
echo $OPENAI_API_KEY
echo $ANTHROPIC_API_KEY

# اختبار اتصال API
curl -H "Authorization: Bearer $OPENAI_API_KEY" \
     https://api.openai.com/v1/models
```

#### المشكلة 3: مشاكل الذاكرة

```bash
# زيادة تخصيص ذاكرة Docker
docker run --memory=4g autoagent/autoagent:latest

# مراقبة استخدام الموارد
docker stats
```

### تحسين الأداء

#### إدارة الموارد

```bash
# التحسين للإنتاج
auto main --container_name production \
          --port 8080 \
          --memory 4GB \
          --cpus 2
```

#### تكوين التخزين المؤقت

```bash
# تفعيل تخزين الاستجابات مؤقتاً
export ENABLE_CACHE=true
export CACHE_TTL=3600

# تكوين Redis للتخزين المؤقت الموزع
export REDIS_URL=redis://localhost:6379
```

## أمثلة التكامل

### تكامل API

يوفر AutoAgent واجهات برمجة التطبيقات RESTful لتكامل النظام:

```python
import requests

# بدء خادم AutoAgent API
# auto main --api-mode --port 8080

# إنشاء وكيل عبر API
response = requests.post('http://localhost:8080/api/agents', 
    json={
        'name': 'مساعد البحث',
        'model': 'gpt-4o',
        'tools': ['web_search', 'document_analysis']
    }
)

agent_id = response.json()['agent_id']

# إرسال مهمة للوكيل
task_response = requests.post(f'http://localhost:8080/api/agents/{agent_id}/tasks',
    json={
        'task': 'ابحث عن أحدث التطورات في الحوسبة الكمية',
        'max_tokens': 2000
    }
)
```

### تكامل Webhook

إعداد webhooks لتدفقات العمل المدفوعة بالأحداث:

```bash
# تكوين نقاط نهاية webhook
export WEBHOOK_URL=https://your-app.com/webhook
export WEBHOOK_SECRET=your_secret_key

# سيرسل AutoAgent أحداثاً إلى نقطة النهاية الخاصة بك
# الأحداث: agent_created, task_completed, error_occurred
```

## أفضل الممارسات

### اعتبارات الأمان

1. **إدارة مفاتيح API**
   ```bash
   # استخدم متغيرات البيئة، لا تكتب مباشرة في الكود أبداً
   export OPENAI_API_KEY=$(cat ~/.secrets/openai_key)
   
   # تدوير المفاتيح بانتظام
   # مراقبة استخدام API والتكاليف
   ```

2. **أمان Docker**
   ```bash
   # التشغيل بصلاحيات محدودة
   docker run --user 1000:1000 autoagent/autoagent:latest
   
   # استخدام حاويات للقراءة فقط عند الإمكان
   docker run --read-only autoagent/autoagent:latest
   ```

### نصائح الأداء

1. **اختيار النموذج**
   - استخدم Claude-3.5-Sonnet للتفكير المعقد
   - استخدم GPT-4o للأداء المتوازن
   - استخدم Gemini-2.0-Flash للسرعة

2. **تحسين الموارد**
   - مراقبة استخدام الرموز المميزة
   - تنفيذ تخزين الاستجابات مؤقتاً
   - استخدام أحجام نماذج مناسبة

### المراقبة والتسجيل

```bash
# تفعيل التسجيل التفصيلي
export DEBUG=true
export LOG_LEVEL=INFO

# مراقبة أداء الوكيل
auto main --log-file /var/log/autoagent.log

# إعداد تدوير السجلات
logrotate /etc/logrotate.d/autoagent
```

## الميزات المتقدمة

### تطوير الوكلاء المخصصين

إنشاء وكلاء متخصصين باستخدام محرر الوكيل:

```bash
# تشغيل بيئة تطوير الوكيل
auto main --mode agent_editor --git_clone true

# هذا سوف:
# 1. يستنسخ مستودع AutoAgent محلياً
# 2. يمكّن تعديل واختبار الوكيل
# 3. يوفر التحكم في الإصدار لوكلائك
```

### أتمتة سير العمل

بناء تدفقات عمل متعددة الوكلاء معقدة:

```bash
# الوصول لمحرر سير العمل
auto main --mode workflow_editor

# تصميم تدفقات عمل مع:
# - تنسيق وكلاء متعددين
# - منطق شرطي
# - معالجة الأخطاء
# - مراقبة الأداء
```

### التقييم والمعايرة

اختبار وكلائك ضد معايير قياسية:

```bash
# تشغيل معيار GAIA
cd evaluation/gaia && sh scripts/run_infer.sh
python get_score.py

# تشغيل تقييم Agentic-RAG
cd evaluation/multihoprag && sh scripts/run_rag.sh
```

## المجتمع والدعم

### الحصول على المساعدة

- **الوثائق**: [وثائق AutoAgent](https://github.com/HKUDS/AutoAgent/docs)
- **مجتمع Slack**: انضم لمناقشات البحث
- **خادم Discord**: دعم المجتمع والأسئلة
- **قضايا GitHub**: تقارير الأخطاء وطلبات الميزات

### المساهمة

AutoAgent يرحب بالمساهمات:

```bash
# فرع المستودع
git clone https://github.com/yourusername/AutoAgent.git

# إنشاء فرع ميزة
git checkout -b feature/amazing-feature

# عمل التغييرات والاختبار
python -m pytest tests/

# إرسال طلب سحب
git push origin feature/amazing-feature
```

## الخلاصة

يمثل AutoAgent تحولاً نموذجياً في تطوير وكلاء الذكاء الاصطناعي، مما يجعل الأتمتة المتطورة في متناول الجميع. سواء كنت باحثاً أو مطوراً أو محترف أعمال، فإن نهج AutoAgent بدون كود يمكّن النشر السريع للوكلاء الذكيين.

### النقاط الرئيسية

- **إعداد سهل**: ابدأ في دقائق مع تثبيت بسيط
- **نشر مرن**: اختر بين النشر المباشر أو المُحاوي
- **دعم متعدد النماذج**: اعمل مع مزود LLM المفضل لديك
- **جاهز للإنتاج**: ميزات مراقبة وتسجيل وتوسع مدمجة

### الخطوات التالية

1. **ابدأ صغيراً**: أنشئ وكيل بحث أو دعم بسيط
2. **جرب**: اختبر نماذج وتكوينات مختلفة
3. **توسع**: انشر وكلاء متعددين لتدفقات عمل معقدة
4. **ساهم**: انضم للمجتمع وشارك ابتكاراتك

هل أنت مستعد لثورة في سير عملك بوكلاء الذكاء الاصطناعي المؤتمتين؟ ابدأ رحلة AutoAgent اليوم! 🚀

---

*هل وجدت هذا الدليل مفيداً؟ شارك إبداعاتك في AutoAgent وتواصل مع المجتمع على [GitHub](https://github.com/HKUDS/AutoAgent)!*
