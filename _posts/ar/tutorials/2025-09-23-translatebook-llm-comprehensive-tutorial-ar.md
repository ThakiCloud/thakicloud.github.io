---
title: "TranslateBook with LLM: دليل شامل لترجمة الكتب باستخدام الذكاء الاصطناعي"
excerpt: "تعلم كيفية ترجمة الكتب وملفات EPUB والترجمات باستخدام نماذج LLM المحلية مع Ollama أو واجهات برمجة التطبيقات السحابية مثل Gemini. دليل تعليمي شامل مع واجهة الويب وسطر الأوامر."
seo_title: "دليل TranslateBook LLM: أداة ترجمة الكتب بالذكاء الاصطناعي - Thaki Cloud"
seo_description: "دليل شامل لـ TranslateBookWithLLM - ترجمة الكتب وملفات EPUB وترجمات SRT باستخدام Ollama وGemini API مع واجهة الويب وسطر الأوامر. دليل إعداد خطوة بخطوة."
date: 2025-09-23
categories:
  - tutorials
tags:
  - llm
  - ترجمة
  - ollama
  - gemini-api
  - epub
  - python
  - أدوات-الذكاء-الاصطناعي
author_profile: true
toc: true
toc_label: "جدول المحتويات"
canonical_url: "https://thakicloud.github.io/ar/tutorials/translatebook-llm-comprehensive-tutorial/"
lang: ar
permalink: /ar/tutorials/translatebook-llm-comprehensive-tutorial/
published: false
---

⏱️ **وقت القراءة المتوقع**: 12 دقيقة

في عصر الأدوات المدعومة بالذكاء الاصطناعي، تطورت ترجمة المستندات بما يتجاوز التحويل البسيط كلمة بكلمة. **TranslateBookWithLLM** من [hydropix](https://github.com/hydropix/TranslateBookWithLLM) هو تطبيق Python متطور يستفيد من نماذج اللغة الكبيرة (LLM) لتوفير ترجمات عالية الجودة مع مراعاة السياق للكتب وملفات EPUB وحتى ترجمات SRT.

على عكس خدمات الترجمة التقليدية التي تعالج النص بشكل خطي، تحافظ هذه الأداة على السياق عبر الأجزاء، وتحافظ على التنسيق، وتوفر خيارات نماذج LLM المحلية (Ollama) والسحابية (Google Gemini). سواء كنت باحثًا أو منشئ محتوى أو متحمسًا للغات، فسيرشدك هذا الدليل الشامل خلال كل ما تحتاج لمعرفته.

## 🎯 ما الذي يجعل TranslateBookWithLLM مميزًا؟

### الميزات الرئيسية في لمحة

- **موفرو LLM متعددون**: يدعم نماذج Ollama المحلية وواجهة برمجة تطبيقات Google Gemini
- **الحفاظ على التنسيق**: يحافظ على التنسيق الأصلي لملفات EPUB وTXT وSRT
- **ترجمة مدركة للسياق**: يحافظ على المعنى عبر أجزاء النص مع الكشف الذكي عن الحدود
- **واجهة ويب**: واجهة مستخدم ودية مع تتبع التقدم في الوقت الفعلي
- **دعم CLI**: واجهة سطر الأوامر للأتمتة والنصوص البرمجية
- **المعالجة اللاحقة**: مرحلة تحسين اختيارية لجودة ترجمة محسنة
- **تعليمات مخصصة**: القدرة على توفير إرشادات ترجمة محددة
- **دعم Docker**: نشر محاوي للبيئات المتسقة

### تنسيقات الملفات المدعومة

| التنسيق | الوصف | حالات الاستخدام |
|--------|-------------|-----------|
| **TXT** | ملفات نصية عادية | كتب، مقالات، وثائق |
| **EPUB** | تنسيق الكتاب الإلكتروني | كتب رقمية، منشورات |
| **SRT** | ملفات الترجمة | ترجمات الفيديو، التسميات التوضيحية |

## 🚀 البدء: التثبيت والإعداد

### المتطلبات الأساسية

قبل البدء، تأكد من تثبيت ما يلي:

- **Python 3.8+**: يتطلب التطبيق Python 3.8 أو أحدث
- **Git**: لاستنساخ المستودع
- **Ollama** (لنماذج LLM المحلية): قم بالتنزيل من [ollama.ai](https://ollama.ai)
- **مفتاح واجهة برمجة تطبيقات Google Gemini** (اختياري): للترجمة السحابية

### الخطوة 1: الاستنساخ والإعداد

```bash
# استنساخ المستودع
git clone https://github.com/hydropix/TranslateBookWithLLM.git
cd TranslateBookWithLLM

# تثبيت التبعيات
pip install -r requirements.txt

# نسخ إعدادات البيئة
cp .env.example .env
```

### الخطوة 2: تكوين متغيرات البيئة

قم بتحرير ملف `.env` لتخصيص إعداداتك:

```bash
# إعدادات API
API_ENDPOINT=http://localhost:11434/api/generate
DEFAULT_MODEL=mistral-small:24b

# إعدادات الترجمة
MAIN_LINES_PER_CHUNK=25
REQUEST_TIMEOUT=60
MAX_ATTEMPTS=3

# واجهة الويب
PORT=5000
DEBUG=False

# Gemini API (اختياري)
GEMINI_API_KEY=your_api_key_here
```

### الخطوة 3: إعداد Ollama (خيار LLM المحلي)

إذا كنت تفضل استخدام النماذج المحلية للخصوصية وفعالية التكلفة:

```bash
# تثبيت Ollama (macOS/Linux)
curl -fsSL https://ollama.ai/install.sh | sh

# بدء خدمة Ollama
ollama serve

# تثبيت نماذج محسّنة للترجمة
ollama pull mistral-small:24b    # سريع وفعال
ollama pull llama3.1:8b         # أداء متوازن
ollama pull codellama:34b       # للمحتوى التقني

# التحقق من التثبيت
ollama list
```

## 🖥️ استخدام واجهة الويب

توفر واجهة الويب التجربة الأكثر سهولة للمستخدم لمهام الترجمة.

### بدء خادم الويب

```bash
# بدء واجهة الويب
python translation_api.py

# أو مع منفذ مخصص
PORT=8080 python translation_api.py
```

انتقل إلى `http://localhost:5000` في متصفحك.

### جولة في واجهة الويب

#### 1. **اختيار المزود**
اختر بين:
- **Ollama**: نماذج محلية (تركز على الخصوصية، لا يتطلب إنترنت)
- **Google Gemini**: نماذج سحابية (يتطلب مفتاح API، جودة أعلى عمومًا)

#### 2. **تكوين النموذج**
- **نماذج Ollama**: اختر من النماذج المحلية المثبتة
- **نماذج Gemini**: اختر من `gemini-2.0-flash` أو `gemini-1.5-pro` أو `gemini-1.5-flash`

#### 3. **إعدادات الترجمة**
تكوين الخيارات المتقدمة:

```yaml
حجم الجزء: 10-100 سطر لكل جزء
المهلة الزمنية: 30-600 ثانية
نافذة السياق: 1024-32768 رمز
المحاولات القصوى: 1-5 محاولة إعادة
```

#### 4. **رفع الملف والترجمة**
1. اختر ملف المصدر (TXT أو EPUB أو SRT)
2. اختر اللغات المصدر والهدف
3. اختياريًا أضف تعليمات مخصصة
4. فعّل المعالجة اللاحقة للجودة المحسنة
5. اضغط على "ترجمة" وراقب التقدم في الوقت الفعلي

### الميزات المتقدمة

#### التعليمات المخصصة
قدم إرشادات محددة لترجمتك:

```text
أمثلة:
- "حافظ على النبرة الرسمية طوال الترجمة"
- "احتفظ بالمصطلحات التقنية باللغة الإنجليزية"
- "استخدم اللهجة المغربية للعربية"
- "احفظ المراجع الثقافية مع ملاحظات توضيحية"
```

#### المعالجة اللاحقة
فعّل ميزة المعالجة اللاحقة لـ:
- تحسينات القواعد والطلاقة
- فحوصات اتساق المصطلحات
- تحسين تدفق اللغة الطبيعية
- التحقق من الملاءمة الثقافية

## 💻 واجهة سطر الأوامر (CLI)

للأتمتة أو البرمجة أو التكامل في سير العمل، توفر CLI خيارات قوية.

### أوامر الترجمة الأساسية

```bash
# ترجمة ملف نصي أساسي
python translate.py -i book.txt -o book_translated.txt \
    -sl English -tl Arabic

# ترجمة EPUB مع نموذج محدد
python translate.py -i novel.epub -o novel_arabic.epub \
    -m mistral-small:24b -sl English -tl Arabic

# ترجمة ترجمة SRT
python translate.py -i movie.srt -o movie_arabic.srt \
    -sl English -tl Arabic
```

### خيارات CLI المتقدمة

```bash
# استخدام واجهة برمجة تطبيقات Google Gemini
python translate.py -i document.txt -o document_arabic.txt \
    --provider gemini \
    --gemini_api_key YOUR_API_KEY \
    -m gemini-2.0-flash \
    -sl English -tl Arabic

# حجم جزء مخصص ومهلة زمنية
python translate.py -i large_book.txt -o large_book_arabic.txt \
    -sl English -tl Arabic \
    --chunk_size 50 \
    --timeout 120

# مع تعليمات مخصصة
python translate.py -i technical_manual.txt -o manual_arabic.txt \
    -sl English -tl Arabic \
    --custom_instructions "احتفظ بالمصطلحات التقنية بالإنجليزية، استخدم العربية الفصحى"
```

### مرجع معاملات CLI

| المعامل | الوصف | مثال |
|-----------|-------------|---------|
| `-i, --input` | مسار الملف المدخل | `book.txt` |
| `-o, --output` | مسار الملف المخرج | `book_arabic.txt` |
| `-sl, --source_language` | اللغة المصدر | `English` |
| `-tl, --target_language` | اللغة الهدف | `Arabic` |
| `-m, --model` | اسم نموذج LLM | `mistral-small:24b` |
| `--provider` | مزود LLM | `ollama` أو `gemini` |
| `--chunk_size` | أسطر لكل جزء | `25` |
| `--timeout` | مهلة الطلب | `60` |
| `--custom_instructions` | إرشادات الترجمة | نص مخصص |

## 🐳 نشر Docker

للبيئات المتسقة والنشر السهل، استخدم تكوين Docker المقدم.

### إعداد Docker سريع

```bash
# بناء صورة Docker
docker build -t translatebook .

# تشغيل مع ربط المجلد
docker run -p 5000:5000 \
    -v $(pwd)/translated_files:/app/translated_files \
    translatebook

# أو مع منفذ مخصص
docker run -p 8080:5000 \
    -e PORT=5000 \
    -v $(pwd)/translated_files:/app/translated_files \
    translatebook
```

### تكوين Docker Compose

إنشاء ملف `docker-compose.yml`:

```yaml
version: '3'
services:
  translatebook:
    build: .
    ports:
      - "5000:5000"
    volumes:
      - ./translated_files:/app/translated_files
      - ./input_files:/app/input_files
    environment:
      - PORT=5000
      - API_ENDPOINT=http://host.docker.internal:11434/api/generate
    networks:
      - translation_network

networks:
  translation_network:
    driver: bridge
```

تشغيل بـ: `docker-compose up`

## 🔧 التكوين المتقدم والتحسين

### تحسين جودة الترجمة

#### 1. **هندسة المطالبات**
يستخدم التطبيق مطالبات متطورة في `prompts.py`. خصصها لاحتياجاتك:

```python
structured_prompt = f"""
## [الدور] 
أنت مترجم محترف باللغة {target_language} متخصص في {domain}.

## [تعليمات الترجمة] 
+ ترجم بأسلوب ونبرة المؤلف الأصلية
+ احفظ الفروق الثقافية الدقيقة وتكيف بشكل مناسب
+ حافظ على الدقة التقنية للمحتوى المتخصص
+ استخدم {target_language} طبيعية وطليقة
+ احفظ التنسيق والهيكل

## [الإرشادات المحددة]
{custom_instructions}
"""
```

#### 2. **تحسين حجم الجزء**
العثور على التوازن الأمثل بين الحفاظ على السياق وكفاءة المعالجة:

```python
# التكوين في src/config.py
CHUNK_SIZES = {
    'technical': 15,    # وثائق تقنية
    'literary': 25,     # كتب وروايات
    'dialogue': 35,     # نصوص ومحادثات
    'academic': 20      # أوراق بحثية
}
```

#### 3. **إرشادات اختيار النموذج**

| نوع المحتوى | النموذج الموصى به | السبب |
|--------------|-------------------|---------|
| **الوثائق التقنية** | `codellama:34b` | دقة تقنية أفضل |
| **الأدب** | `llama3.1:8b` | توازن الإبداع والدقة |
| **الأوراق الأكاديمية** | `gemini-1.5-pro` | قدرات استنتاج فائقة |
| **المحتوى العام** | `mistral-small:24b` | سريع وفعال |

### ضبط الأداء

#### تحسين الذاكرة والمعالجة

```python
# في src/config.py
PERFORMANCE_SETTINGS = {
    'BATCH_SIZE': 5,              # مهام ترجمة متزامنة
    'MEMORY_LIMIT': '4GB',        # استخدام أقصى للذاكرة
    'CACHE_ENABLED': True,        # تمكين تخزين الترجمة المؤقت
    'ASYNC_WORKERS': 3            # خيوط العمل غير المتزامنة
}
```

#### إدارة نافذة السياق

```python
CONTEXT_SETTINGS = {
    'OVERLAP_LINES': 2,           # أسطر للتداخل بين الأجزاء
    'PRESERVE_PARAGRAPHS': True,  # الحفاظ على حدود الفقرة
    'SENTENCE_BOUNDARY': True     # احترام حدود الجملة
}
```

## 📊 المراقبة واستكشاف الأخطاء وإصلاحها

### المشاكل الشائعة والحلول

#### 1. **مشاكل اتصال Ollama**

```bash
# التحقق من تشغيل Ollama
curl http://localhost:11434/api/tags

# إعادة تشغيل خدمة Ollama
sudo systemctl restart ollama

# التحقق من إعدادات الجدار الناري
sudo ufw status
```

#### 2. **مشاكل الذاكرة مع الملفات الكبيرة**

```python
# تقليل حجم الجزء للملفات الكبيرة
python translate.py -i large_file.txt -o output.txt \
    --chunk_size 10 \
    --timeout 180
```

#### 3. **مشاكل جودة الترجمة**

جرب استراتيجيات التحسين التالية:

```bash
# استخدام المعالجة اللاحقة
python translate.py -i input.txt -o output.txt \
    --enable_postprocessing \
    --custom_instructions "ركز على تدفق اللغة الطبيعية"

# جرب نماذج مختلفة
python translate.py -i input.txt -o output.txt \
    -m llama3.1:8b  # بدلاً من mistral-small:24b
```

### التسجيل والتصحيح

تمكين التسجيل المفصل:

```python
# في ملف .env
DEBUG=True
LOG_LEVEL=DEBUG
VERBOSE_LOGGING=True
```

مراقبة تقدم الترجمة:

```bash
# مراقبة ملفات السجل
tail -f translation.log

# التحقق من استجابات API
curl -X POST http://localhost:5000/api/translate/status
```

## 🌟 حالات الاستخدام الواقعية والأمثلة

### حالة الاستخدام 1: ترجمة ورقة أكاديمية

```bash
# ترجمة ورقة بحثية بتركيز أكاديمي
python translate.py \
    -i "research_paper.pdf" \
    -o "research_paper_arabic.pdf" \
    -sl English -tl Arabic \
    --custom_instructions "حافظ على النبرة الأكاديمية، احفظ الاستشهادات، ترجم الملخصات بالكامل" \
    --chunk_size 20 \
    --enable_postprocessing
```

### حالة الاستخدام 2: خط أنابيب نشر الكتب الإلكترونية

```bash
#!/bin/bash
# خط أنابيب ترجمة الكتب الإلكترونية المؤتمت

LANGUAGES=("Arabic" "French" "Spanish" "German")
INPUT_BOOK="novel.epub"

for lang in "${LANGUAGES[@]}"; do
    python translate.py \
        -i "$INPUT_BOOK" \
        -o "novel_${lang,,}.epub" \
        -sl English -tl "$lang" \
        -m llama3.1:8b \
        --custom_instructions "احفظ هيكل الفصول، حافظ على تنسيق الحوار" \
        --enable_postprocessing
    
    echo "Translation to $lang completed"
done
```

### حالة الاستخدام 3: سير عمل الترجمة لمنشئي المحتوى

```bash
# ترجمة ترجمات مجمعة
python translate.py \
    -i "episode_01.srt" \
    -o "episode_01_arabic.srt" \
    -sl English -tl Arabic \
    --custom_instructions "حافظ على التوقيت بدقة، استخدم العربية المحكية العادية" \
    --chunk_size 35
```

## 🔮 الميزات المتقدمة والتكامل

### تكامل API

يوفر التطبيق نقاط نهاية REST API للتكامل:

```python
import requests

# إرسال مهمة ترجمة
response = requests.post('http://localhost:5000/api/translate', json={
    'file_content': 'نص للترجمة',
    'source_language': 'English',
    'target_language': 'Arabic',
    'model': 'mistral-small:24b',
    'custom_instructions': 'حافظ على النبرة الرسمية'
})

job_id = response.json()['job_id']

# التحقق من حالة الترجمة
status = requests.get(f'http://localhost:5000/api/translate/status/{job_id}')
print(status.json())
```

### تحديثات WebSocket في الوقت الفعلي

```javascript
// تقدم الترجمة في الوقت الفعلي
const socket = io('http://localhost:5000');

socket.on('translation_progress', (data) => {
    console.log(`التقدم: ${data.percentage}%`);
    console.log(`الجزء الحالي: ${data.current_chunk}/${data.total_chunks}`);
});

socket.on('translation_complete', (data) => {
    console.log('اكتملت الترجمة!');
    // تنزيل الملف المترجم
    window.location.href = data.download_url;
});
```

### تكامل مزود مخصص

توسيع التطبيق بمزودي LLM مخصصين:

```python
# في src/core/llm_providers.py
class CustomProvider(LLMProvider):
    def __init__(self, api_key, model_name):
        self.api_key = api_key
        self.model_name = model_name
    
    async def translate_chunk(self, text, source_lang, target_lang, custom_instructions=""):
        # تنفيذ استدعاء API LLM المخصص الخاص بك
        response = await self.custom_api_call(text, source_lang, target_lang)
        return response['translated_text']
```

## 🎓 أفضل الممارسات والنصائح

### إرشادات جودة الترجمة

1. **اختر النموذج المناسب**: طابق قدرات النموذج مع تعقيد المحتوى
2. **حسّن حجم الجزء**: وازن بين الحفاظ على السياق وكفاءة المعالجة
3. **استخدم التعليمات المخصصة**: قدم إرشادات محددة لمجالك
4. **فعّل المعالجة اللاحقة**: للمحتوى المهني أو المنشور
5. **راجع المخرجات**: راجع الترجمات دائمًا، خاصة للمحتوى الحرج

### أفضل ممارسات الأداء

1. **إدارة الموارد**: راقب استخدام الذاكرة للملفات الكبيرة
2. **المعالجة المتزامنة**: استخدم أحجام دفعات مناسبة لأجهزتك
3. **استراتيجية التخزين المؤقت**: فعّل التخزين المؤقت لمهام الترجمة المتكررة
4. **اختيار النموذج**: استخدم النماذج المحلية للخصوصية، النماذج السحابية للجودة

### اعتبارات الأمان

1. **إدارة مفاتيح API**: احفظ مفاتيح API بأمان، لا تضعها في التحكم بالإصدار أبدًا
2. **التحقق من الملفات**: يتضمن التطبيق التحقق المدمج من نوع الملف
3. **خصوصية البيانات**: استخدم النماذج المحلية للمحتوى الحساس
4. **أمان الشبكة**: تكوين الجدران النارية بشكل مناسب لواجهة الويب

## 🚀 الخلاصة والخطوات التالية

يمثل TranslateBookWithLLM تقدمًا مهمًا في أدوات الترجمة المدعومة بالذكاء الاصطناعي، حيث يوفر كلاً من خصوصية نماذج LLM المحلية وقوة النماذج السحابية. تجعل الهندسة المعمارية المتطورة وقدرات الحفاظ على التنسيق والواجهات سهلة الاستخدام منه أداة لا تقدر بثمن لأي شخص يعمل مع المحتوى متعدد اللغات.

### النقاط الرئيسية

- **حل متعدد الاستخدامات**: يدعم تنسيقات ملفات ومزودي LLM متعددة
- **التركيز على الجودة**: ترجمة مدركة للسياق مع خيارات المعالجة اللاحقة
- **سهولة الاستخدام**: واجهة ويب وCLI لحالات استخدام مختلفة
- **قابلية التوسع**: دعم Docker لنشر الإنتاج
- **قابلية التوسيع**: هندسة مفتوحة للتكامل المخصص

### ما التالي؟

1. **التجريب**: ابدأ بملفات صغيرة لفهم قدرات الأداة
2. **التخصيص**: تكييف المطالبات والإعدادات لحالات الاستخدام المحددة الخاصة بك
3. **التكامل**: ادمج في سير العمل الحالي عبر API
4. **المساهمة**: المشروع مفتوح المصدر - فكر في المساهمة بالتحسينات
5. **التوسع**: انشر باستخدام Docker لحالات استخدام الإنتاج

### موارد للتعلم الإضافي

- [مستودع GitHub](https://github.com/hydropix/TranslateBookWithLLM): الكود المصدري والوثائق
- [وثائق Ollama](https://ollama.ai/docs): إعداد وإدارة LLM المحلي
- [واجهة برمجة تطبيقات Google Gemini](https://ai.google.dev/): قدرات وأسعار LLM السحابي
- [وثائق Docker](https://docs.docker.com/): أفضل ممارسات الحاويات

مستقبل الترجمة هنا، وهو مدعوم بالذكاء الاصطناعي. مع TranslateBookWithLLM، لديك الأدوات لتجاوز الحواجز اللغوية مع الحفاظ على الفروق الدقيقة والسياق التي تجعل التواصل ذا معنى حقيقي.

---

*هل جربت TranslateBookWithLLM؟ شارك تجاربك وقصص نجاح الترجمة الخاصة بك في التعليقات أدناه!*
