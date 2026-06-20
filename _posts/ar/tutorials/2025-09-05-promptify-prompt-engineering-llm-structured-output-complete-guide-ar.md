---
title: "Promptify: دليل شامل للحصول على مخرجات منظمة من نماذج اللغة الكبيرة"
excerpt: "اتقن هندسة الأوامر واحصل على مخرجات منظمة من GPT وPaLM ونماذج اللغة الكبيرة الأخرى باستخدام Promptify - مكتبة Python قوية لمهام معالجة اللغة الطبيعية بدون بيانات تدريب."
seo_title: "دورة Promptify: هندسة الأوامر للحصول على مخرجات منظمة من نماذج اللغة الكبيرة"
seo_description: "تعلم كيفية استخدام Promptify لهندسة الأوامر مع GPT ونماذج اللغة الكبيرة الأخرى. احصل على مخرجات منظمة لـ NER والتصنيف والأسئلة والأجوبة ومهام معالجة اللغة الطبيعية الأخرى بدون بيانات تدريب."
date: 2025-09-05
categories:
  - tutorials
tags:
  - هندسة-الأوامر
  - نماذج-اللغة-الكبيرة
  - معالجة-اللغة-الطبيعية
  - GPT
  - OpenAI
  - تعلم-الآلة
  - بايثون
author_profile: true
toc: true
toc_label: "المحتويات"
lang: ar
permalink: /ar/tutorials/promptify-prompt-engineering-guide/
canonical_url: "https://thakicloud.github.io/ar/tutorials/promptify-prompt-engineering-guide/"
published: false
---

⏱️ **وقت القراءة المتوقع**: 15 دقيقة

هل سئمت من الحصول على مخرجات غير منظمة وغير متسقة من نماذج اللغة الكبيرة (LLMs) مثل GPT-3 و GPT-4 أو PaLM؟ هل تريد تنفيذ مهام معالجة اللغة الطبيعية المعقدة بدون بيانات تدريب أو ضبط دقيق للنماذج؟ **Promptify** هنا لحل هذه المشاكل!

في هذا الدليل الشامل، سنستكشف كيفية استخدام [Promptify](https://github.com/promptslab/Promptify)، وهي مكتبة Python قوية تمكن من إنتاج مخرجات منظمة من نماذج اللغة الكبيرة من خلال هندسة الأوامر الذكية.

## ما هو Promptify؟

Promptify هي مكتبة Python مفتوحة المصدر مصممة لجعل هندسة الأوامر أكثر منهجية وموثوقية. تتناول واحدة من أكبر التحديات عند العمل مع نماذج اللغة الكبيرة: **الحصول على مخرجات متسقة ومنظمة** يمكن تحليلها واستخدامها بسهولة في التطبيقات.

### المشاكل الرئيسية التي يحلها Promptify

1. **مخرجات نماذج اللغة الكبيرة غير المنظمة**: الاستجابات الخام من نماذج اللغة الكبيرة غالباً ما تكون غير متسقة وصعبة التحليل
2. **عدم الحاجة لبيانات التدريب**: تنفيذ مهام معالجة اللغة الطبيعية بدون مجموعات بيانات مُسماة
3. **اتساق الأوامر**: قوالب موحدة لمهام معالجة اللغة الطبيعية المختلفة
4. **التحقق من المخرجات**: التعامل مع التنبؤات التي تتجاوز الحدود المتوقعة من نماذج اللغة الكبيرة

### الميزات الرئيسية

- 🎯 **مهام معالجة اللغة الطبيعية بدون أمثلة** في سطرين فقط من الكود
- 📝 **استراتيجيات أوامر متعددة**: دعم الأمثلة الواحدة والقليلة
- 🔧 **مخرجات منظمة**: تعيد دائماً كائنات Python (قوائم، قواميس)
- 🤗 **دعم نماذج متعددة**: OpenAI GPT، نماذج Hugging Face، Azure، PaLM
- 💰 **تحسين التكلفة**: أوامر محسنة لتقليل استخدام الرموز
- 🛡️ **التعامل مع الأخطاء**: التحقق القوي من تنبؤات نماذج اللغة الكبيرة

## التثبيت والإعداد

### تثبيت Promptify

أولاً، دعنا نثبت Promptify باستخدام pip:

```bash
# التثبيت من PyPI
pip install promptify

# أو التثبيت من GitHub (النسخة الأحدث)
pip install git+https://github.com/promptslab/Promptify.git
```

### إعداد واجهة OpenAI البرمجية

ستحتاج إلى مفتاح واجهة OpenAI البرمجية لاستخدام نماذج GPT:

```python
import os
from promptify import Prompter, OpenAI, Pipeline

# تعيين مفتاح واجهة OpenAI البرمجية
api_key = "your-openai-api-key-here"
# أو استخدام متغير البيئة
# os.environ["OPENAI_API_KEY"] = "your-api-key"
```

### إعداد النماذج البديلة

يدعم Promptify مقدمي نماذج اللغة الكبيرة المتعددين:

```python
# لنماذج Hugging Face
from promptify import HubModel
model = HubModel()

# لـ Azure OpenAI
from promptify import Azure
model = Azure(api_key="your-azure-key")
```

## الاستخدام الأساسي: واجهة Pipeline البرمجية

واجهة Pipeline البرمجية هي أسهل طريقة للبدء مع Promptify. دعونا نرى كيفية تنفيذ التعرف على الكيانات المسماة (NER) على النص الطبي:

```python
from promptify import Prompter, OpenAI, Pipeline

# نص طبي نموذجي
sentence = """المريضة امرأة تبلغ من العمر 93 عامًا لديها تاريخ طبي  
             من آلام الورك الأيمن المزمنة، هشاشة العظام،
             ارتفاع ضغط الدم، الاكتئاب، والرجفان الأذيني المزمن
             تم إدخالها لتقييم وإدارة الغثيان والقيء الشديد
             والتهاب المسالك البولية"""

# تهيئة المكونات
model = OpenAI(api_key)              # نموذج اللغة الكبيرة
prompter = Prompter('ner.jinja')     # قالب NER
pipe = Pipeline(prompter, model)      # خط أنابيب كامل

# تنفيذ مهمة NER
result = pipe.fit(sentence, domain="medical", labels=None)
print(result)
```

### المخرجات المتوقعة

```json
[
    {"E": "93 عامًا", "T": "العمر"},
    {"E": "آلام الورك الأيمن المزمنة", "T": "حالة طبية"},
    {"E": "هشاشة العظام", "T": "حالة طبية"},
    {"E": "ارتفاع ضغط الدم", "T": "حالة طبية"},
    {"E": "الاكتئاب", "T": "حالة طبية"},
    {"E": "الرجفان الأذيني المزمن", "T": "حالة طبية"},
    {"E": "الغثيان والقيء الشديد", "T": "أعراض"},
    {"E": "التهاب المسالك البولية", "T": "حالة طبية"},
    {"Branch": "الطب الباطني", "Group": "طب المسنين"}
]
```

## مهام معالجة اللغة الطبيعية المتقدمة مع Promptify

### 1. تصنيف النص

يتفوق Promptify في تصنيف النص بدون أمثلة:

```python
# تحليل المشاعر متعدد الفئات
from promptify import Prompter, OpenAI, Pipeline

text = "أحب هذا الهاتف الذكي الجديد حقًا! جودة الكاميرا مذهلة والبطارية تدوم طوال اليوم."

model = OpenAI(api_key)
prompter = Prompter('classification.jinja')
pipe = Pipeline(prompter, model)

result = pipe.fit(
    text, 
    labels=["إيجابي", "سلبي", "محايد"],
    task="تحليل_المشاعر"
)
print(result)
# المخرجات: {"label": "إيجابي", "confidence": 0.95}
```

### 2. الأسئلة والأجوبة

بناء نظام أسئلة وأجوبة بدون تدريب:

```python
# إعداد الأسئلة والأجوبة
context = """Promptify هي مكتبة Python لهندسة الأوامر. 
           تساعد المطورين في الحصول على مخرجات منظمة من نماذج اللغة الكبيرة 
           مثل GPT-3 و GPT-4 و PaLM. تدعم المكتبة مهام معالجة اللغة الطبيعية المختلفة
           بما في ذلك التعرف على الكيانات المسماة وتصنيف النص والتلخيص."""

question = "ما هي مهام معالجة اللغة الطبيعية التي يدعمها Promptify؟"

model = OpenAI(api_key)
prompter = Prompter('qa.jinja')
pipe = Pipeline(prompter, model)

result = pipe.fit(context, question=question)
print(result)
# المخرجات: {"answer": "التعرف على الكيانات المسماة وتصنيف النص والتلخيص"}
```

### 3. استخراج العلاقات

استخراج العلاقات بين الكيانات:

```python
# استخراج العلاقات
text = """تيم كوك هو الرئيس التنفيذي لشركة أبل المحدودة. أسست شركة أبل من قبل ستيف جوبز في عام 1976. 
         الشركة يقع مقرها الرئيسي في كوبرتينو، كاليفورنيا."""

model = OpenAI(api_key)
prompter = Prompter('relation_extraction.jinja')
pipe = Pipeline(prompter, model)

result = pipe.fit(text, domain="أعمال")
print(result)
# المخرجات: [
#   {"subject": "تيم كوك", "relation": "الرئيس_التنفيذي_لـ", "object": "شركة أبل المحدودة"},
#   {"subject": "أبل", "relation": "أسسها", "object": "ستيف جوبز"},
#   {"subject": "أبل", "relation": "تأسست_في", "object": "1976"},
#   {"subject": "أبل", "relation": "مقرها_في", "object": "كوبرتينو، كاليفورنيا"}
# ]
```

### 4. تلخيص النص

إنتاج ملخصات مختصرة:

```python
# تلخيص النص
long_text = """
نماذج اللغة الكبيرة (LLMs) ثورت معالجة اللغة الطبيعية. 
هذه النماذج، المدربة على كميات هائلة من البيانات النصية، يمكنها تنفيذ مجموعة واسعة 
من المهام بما في ذلك الترجمة والتلخيص والأسئلة والأجوبة والكتابة الإبداعية. 
ومع ذلك، الحصول على مخرجات منظمة ومتسقة من نماذج اللغة الكبيرة يبقى تحدياً. 
يتناول Promptify هذا من خلال توفير إطار عمل لهندسة الأوامر المنهجية، 
مما يمكن المطورين من الحصول على مخرجات موثوقة ومنظمة لمهام معالجة اللغة الطبيعية المختلفة دون 
الحاجة لبيانات التدريب أو الضبط الدقيق للنموذج.
"""

model = OpenAI(api_key)
prompter = Prompter('summarization.jinja')
pipe = Pipeline(prompter, model)

result = pipe.fit(long_text, max_length=50)
print(result)
# المخرجات: {"summary": "نماذج اللغة الكبيرة متفوقة في مهام معالجة اللغة الطبيعية لكنها تفتقر للمخرجات المنظمة. Promptify يحل هذا من خلال هندسة الأوامر المنهجية."}
```

## الميزات المتقدمة والتخصيص

### قوالب الأوامر المخصصة

إنشاء قوالب الأوامر الخاصة بك لحالات الاستخدام المحددة:

```python
# قالب مخصص لمراجعة الكود
custom_template = """
أنت مراجع كود خبير. حلل الكود التالي وقدم ملاحظات منظمة.

الكود:
{{ code }}

يرجى تقديم الملاحظات بتنسيق JSON التالي:
{
    "issues": [قائمة المشاكل الموجودة],
    "suggestions": [قائمة اقتراحات التحسين],
    "severity": "منخفض|متوسط|عالي",
    "score": (1-10)
}
"""

# استخدام القالب المخصص
from promptify import Prompter, OpenAI, Pipeline

code_snippet = """
def calculate_average(numbers):
    return sum(numbers) / len(numbers)
"""

model = OpenAI(api_key)
prompter = Prompter(custom_template)
pipe = Pipeline(prompter, model)

result = pipe.fit(code=code_snippet)
```

### التعلم بالأمثلة القليلة

إضافة أمثلة لتحسين أداء النموذج:

```python
# التعلم بالأمثلة القليلة لدقة أفضل
examples = [
    {
        "text": "الطقس مشمس ودافئ اليوم.",
        "entities": [{"E": "مشمس", "T": "الطقس"}, {"E": "دافئ", "T": "درجة الحرارة"}]
    },
    {
        "text": "يعمل أحمد في مايكروسوفت في سياتل.",
        "entities": [{"E": "أحمد", "T": "شخص"}, {"E": "مايكروسوفت", "T": "منظمة"}, {"E": "سياتل", "T": "موقع"}]
    }
]

model = OpenAI(api_key)
prompter = Prompter('ner.jinja')
pipe = Pipeline(prompter, model)

result = pipe.fit(
    "تدرس فاطمة في جامعة ستانفورد في كاليفورنيا.",
    examples=examples,
    domain="عام"
)
```

### المعالجة بالدفعات

معالجة نصوص متعددة بكفاءة:

```python
# معالجة دفعية لوثائق متعددة
texts = [
    "أعلنت شركة أبل المحدودة عن أرباح ربعية قوية.",
    "أعلنت جوجل عن اختراق جديد في الذكاء الاصطناعي.",
    "توسعت خدمات مايكروسوفت أزور السحابية إلى مناطق جديدة."
]

model = OpenAI(api_key)
prompter = Prompter('classification.jinja')
pipe = Pipeline(prompter, model)

results = []
for text in texts:
    result = pipe.fit(
        text, 
        labels=["تكنولوجيا", "مالية", "صحة", "رياضة"],
        task="تصنيف_الموضوع"
    )
    results.append(result)

print(results)
```

## التطبيقات العملية

### 1. نظام اعتدال المحتوى

```python
def moderate_content(text):
    """اعتدال المحتوى الآلي باستخدام Promptify"""
    
    model = OpenAI(api_key)
    prompter = Prompter('classification.jinja')
    pipe = Pipeline(prompter, model)
    
    # فحص المحتوى غير المناسب
    result = pipe.fit(
        text,
        labels=["آمن", "سام", "رسائل عشوائية", "خطاب كراهية"],
        task="اعتدال_المحتوى"
    )
    
    return result["label"], result.get("confidence", 0.0)

# الاستخدام
comment = "هذا مقال رائع، مفيد جداً!"
label, confidence = moderate_content(comment)
print(f"تصنيف المحتوى: {label} (الثقة: {confidence})")
```

### 2. خط أنابيب تحليل الوثائق

```python
def analyze_document(document_text):
    """تحليل شامل للوثائق"""
    
    model = OpenAI(api_key)
    results = {}
    
    # استخراج الكيانات
    ner_prompter = Prompter('ner.jinja')
    ner_pipe = Pipeline(ner_prompter, model)
    results['entities'] = ner_pipe.fit(document_text)
    
    # تصنيف الوثيقة
    class_prompter = Prompter('classification.jinja')
    class_pipe = Pipeline(class_prompter, model)
    results['category'] = class_pipe.fit(
        document_text,
        labels=["قانوني", "تقني", "تسويقي", "مالي"]
    )
    
    # إنتاج الملخص
    summary_prompter = Prompter('summarization.jinja')
    summary_pipe = Pipeline(summary_prompter, model)
    results['summary'] = summary_pipe.fit(document_text, max_length=100)
    
    return results

# الاستخدام
document = "نص الوثيقة هنا..."
analysis = analyze_document(document)
```

### 3. أتمتة دعم العملاء

```python
def process_support_ticket(ticket_text):
    """معالجة تذاكر الدعم الآلية"""
    
    model = OpenAI(api_key)
    
    # تصنيف الإلحاح
    urgency_prompter = Prompter('classification.jinja')
    urgency_pipe = Pipeline(urgency_prompter, model)
    urgency = urgency_pipe.fit(
        ticket_text,
        labels=["منخفض", "متوسط", "عالي", "حرج"],
        task="تصنيف_الإلحاح"
    )
    
    # استخراج نوع المشكلة
    issue_prompter = Prompter('classification.jinja')
    issue_pipe = Pipeline(issue_prompter, model)
    issue_type = issue_pipe.fit(
        ticket_text,
        labels=["فوترة", "تقني", "حساب", "طلب_ميزة"],
        task="تصنيف_المشكلة"
    )
    
    # استخراج المعلومات الرئيسية
    info_prompter = Prompter('ner.jinja')
    info_pipe = Pipeline(info_prompter, model)
    entities = info_pipe.fit(ticket_text, domain="دعم_العملاء")
    
    return {
        "urgency": urgency["label"],
        "issue_type": issue_type["label"],
        "entities": entities,
        "routing": determine_routing(urgency["label"], issue_type["label"])
    }

def determine_routing(urgency, issue_type):
    """توجيه التذاكر بناءً على التصنيف"""
    if urgency == "حرج":
        return "المستوى_الثالث_فوري"
    elif issue_type == "فوترة":
        return "قسم_الفوترة"
    elif issue_type == "تقني":
        return "الدعم_التقني"
    else:
        return "الدعم_العام"
```

## أفضل الممارسات والنصائح

### 1. تحسين الأوامر

```python
# جيد: تعليمات محددة وواضحة
good_prompt = """
استخرج الكيانات المسماة من النص أدناه. أعد الكيانات فقط بتنسيق JSON:
{"entities": [{"text": "كيان", "label": "النوع"}]}

النص: {{ text }}
"""

# سيئ: تعليمات غامضة
bad_prompt = """
ابحث عن أشياء في هذا النص: {{ text }}
"""
```

### 2. التعامل مع الأخطاء

```python
def safe_nlp_processing(text, task="ner"):
    """معالجة معالجة اللغة الطبيعية القوية مع التعامل مع الأخطاء"""
    
    try:
        model = OpenAI(api_key)
        prompter = Prompter(f'{task}.jinja')
        pipe = Pipeline(prompter, model)
        
        result = pipe.fit(text)
        return {"success": True, "data": result}
        
    except Exception as e:
        return {
            "success": False, 
            "error": str(e),
            "fallback": "المعالجة اليدوية مطلوبة"
        }

# الاستخدام مع التعامل مع الأخطاء
result = safe_nlp_processing("النص هنا", "classification")
if result["success"]:
    print("المعالجة نجحت:", result["data"])
else:
    print("حدث خطأ:", result["error"])
```

### 3. تحسين الأداء

```python
# تخزين الأوامر المستخدمة بكثرة مؤقتاً
import functools

@functools.lru_cache(maxsize=128)
def get_cached_prompt(template_name):
    return Prompter(template_name)

# معالجة دفعية للطلبات المتشابهة
def batch_classify_texts(texts, labels):
    """تصنيف دفعي فعال"""
    
    model = OpenAI(api_key)
    prompter = get_cached_prompt('classification.jinja')
    pipe = Pipeline(prompter, model)
    
    # معالجة دفعية لتحسين استدعاءات واجهة برمجة التطبيقات
    batch_size = 10
    results = []
    
    for i in range(0, len(texts), batch_size):
        batch = texts[i:i + batch_size]
        batch_results = []
        
        for text in batch:
            result = pipe.fit(text, labels=labels)
            batch_results.append(result)
            
        results.extend(batch_results)
    
    return results
```

## الاختبار والتحقق

دعونا ننشئ نص اختبار شامل للتحقق من إعداد Promptify:

```python
#!/usr/bin/env python3
"""
نص اختبار دليل Promptify
يختبر جميع الوظائف الرئيسية المغطاة في الدليل
"""

import os
import sys
from promptify import Prompter, OpenAI, Pipeline

def test_basic_setup():
    """اختبار إعداد Promptify الأساسي"""
    print("🔧 اختبار الإعداد الأساسي...")
    
    # فحص توفر مفتاح واجهة برمجة التطبيقات
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        print("❌ مفتاح واجهة OpenAI البرمجية غير موجود. قم بتعيين متغير البيئة OPENAI_API_KEY.")
        return False
    
    try:
        model = OpenAI(api_key)
        print("✅ تم تهيئة نموذج OpenAI بنجاح")
        return True
    except Exception as e:
        print(f"❌ فشل في تهيئة نموذج OpenAI: {e}")
        return False

def test_ner():
    """اختبار التعرف على الكيانات المسماة"""
    print("\n🔍 اختبار التعرف على الكيانات المسماة...")
    
    try:
        sentence = "يعمل أحمد محمد في شركة أبل في الرياض، السعودية."
        
        model = OpenAI(os.getenv("OPENAI_API_KEY"))
        prompter = Prompter('ner.jinja')
        pipe = Pipeline(prompter, model)
        
        result = pipe.fit(sentence, domain="عام")
        print(f"✅ نجح NER: تم العثور على {len(result) if isinstance(result, list) else 1} كيان")
        return True
        
    except Exception as e:
        print(f"❌ فشل اختبار NER: {e}")
        return False

def test_classification():
    """اختبار تصنيف النص"""
    print("\n📊 اختبار تصنيف النص...")
    
    try:
        text = "أحب هذا الهاتف الذكي الجديد! الكاميرا والبطارية ممتازان."
        
        model = OpenAI(os.getenv("OPENAI_API_KEY"))
        prompter = Prompter('classification.jinja')
        pipe = Pipeline(prompter, model)
        
        result = pipe.fit(
            text,
            labels=["إيجابي", "سلبي", "محايد"],
            task="تحليل_المشاعر"
        )
        print(f"✅ نجح التصنيف: {result}")
        return True
        
    except Exception as e:
        print(f"❌ فشل اختبار التصنيف: {e}")
        return False

def test_summarization():
    """اختبار تلخيص النص"""
    print("\n📝 اختبار التلخيص...")
    
    try:
        text = """
        أحرز الذكاء الاصطناعي تقدماً ملحوظاً في السنوات الأخيرة. 
        خوارزميات التعلم الآلي يمكنها الآن تنفيذ مهام معقدة مثل التعرف على الصور، 
        معالجة اللغة الطبيعية، ولعب الألعاب الاستراتيجية. التعلم العميق، 
        وهو فرع من التعلم الآلي، نجح بشكل خاص في تحقيق 
        أداء على مستوى الإنسان في العديد من المجالات.
        """
        
        model = OpenAI(os.getenv("OPENAI_API_KEY"))
        prompter = Prompter('summarization.jinja')
        pipe = Pipeline(prompter, model)
        
        result = pipe.fit(text, max_length=50)
        print(f"✅ نجح التلخيص: تم إنتاج الملخص")
        return True
        
    except Exception as e:
        print(f"❌ فشل اختبار التلخيص: {e}")
        return False

def main():
    """تشغيل جميع الاختبارات"""
    print("🚀 بدء اختبارات دليل Promptify\n")
    
    tests = [
        test_basic_setup,
        test_ner,
        test_classification,
        test_summarization
    ]
    
    passed = 0
    total = len(tests)
    
    for test in tests:
        if test():
            passed += 1
    
    print(f"\n📊 نتائج الاختبار: {passed}/{total} اختبار نجح")
    
    if passed == total:
        print("🎉 نجحت جميع الاختبارات! Promptify يعمل بشكل صحيح.")
    else:
        print("⚠️  فشلت بعض الاختبارات. تحقق من إعدادك ومفتاح واجهة برمجة التطبيقات.")
        sys.exit(1)

if __name__ == "__main__":
    main()
```

## استكشاف المشاكل الشائعة وحلها

### المشكلة 1: مفتاح واجهة برمجة التطبيقات لا يعمل

```bash
# تعيين متغير البيئة
export OPENAI_API_KEY="your-api-key-here"

# أو في Python
import os
os.environ["OPENAI_API_KEY"] = "your-api-key-here"
```

### المشكلة 2: مشاكل التثبيت

```bash
# ترقية pip أولاً
pip install --upgrade pip

# التثبيت بإصدار محدد
pip install promptify==1.0.0

# إعادة التثبيت بالقوة
pip install --force-reinstall promptify
```

### المشكلة 3: لم يتم العثور على القالب

```python
# قائمة القوالب المتاحة
from promptify import Prompter
prompter = Prompter()
print(prompter.list_templates())

# استخدام مسار قالب مخصص
prompter = Prompter('/path/to/your/template.jinja')
```

## الخطوات التالية والمواضيع المتقدمة

### 1. تكامل النماذج المخصصة

استكشاف تكامل نماذجك المضبوطة بدقة:

```python
# غلاف النموذج المخصص
class CustomModel:
    def __init__(self, model_path):
        self.model = load_your_model(model_path)
    
    def generate(self, prompt, **kwargs):
        return self.model.predict(prompt)

# الاستخدام مع Promptify
custom_model = CustomModel("path/to/model")
prompter = Prompter('ner.jinja')
pipe = Pipeline(prompter, custom_model)
```

### 2. تطوير قوالب الأوامر

تعلم إنشاء قوالب أوامر متطورة:

```jinja2
{% raw %}
{# قالب NER متقدم مع أمثلة قليلة #}
أنت خبير في التعرف على الكيانات المسماة. استخرج الكيانات من النص.

أمثلة:
{% for example in examples %}
النص: {{ example.text }}
الكيانات: {{ example.entities | tojson }}
{% endfor %}

الآن استخرج الكيانات من:
النص: {{ text }}
المجال: {{ domain }}

أعد JSON صالح فقط:
{% endraw %}
```

### 3. النشر في الإنتاج

اعتبارات للاستخدام في الإنتاج:

- **تحديد المعدل**: تنفيذ تحديد معدل واجهة برمجة التطبيقات المناسب
- **التخزين المؤقت**: تخزين أزواج الأوامر والاستجابات المتكررة مؤقتاً
- **المراقبة**: تسجيل استخدام واجهة برمجة التطبيقات وأداء النموذج
- **البدائل**: امتلاك نماذج احتياطية للتوفر العالي

## الخلاصة

يمثل Promptify خطوة مهمة إلى الأمام في جعل نماذج اللغة الكبيرة أكثر عملية للتطبيقات الحقيقية. من خلال توفير مخرجات منظمة وقوالب موحدة والتعامل القوي مع الأخطاء، فإنه يسد الفجوة بين قدرات نماذج اللغة الكبيرة الخام وأنظمة معالجة اللغة الطبيعية الجاهزة للإنتاج.

### النقاط الرئيسية

1. **القدرة بدون أمثلة**: تنفيذ مهام معالجة اللغة الطبيعية المعقدة دون بيانات تدريب
2. **مخرجات منظمة**: الحصول على نتائج متسقة وقابلة للتحليل في كل مرة
3. **نماذج متعددة**: دعم OpenAI و Hugging Face ومقدمين آخرين
4. **جاهز للإنتاج**: التعامل مع الأخطاء والتحقق المدمج
5. **قابل للتوسع**: قوالب مخصصة وتكامل النماذج

### ما التالي؟

- استكشف [الوثائق الرسمية](https://promptify.readthedocs.io/)
- انضم إلى [مجتمع Promptify Discord](https://discord.gg/m88xfYMbK6)
- ساهم في [مستودع GitHub](https://github.com/promptslab/Promptify)
- جرب بناء تطبيقات معالجة اللغة الطبيعية الخاصة بك مع Promptify

مع Promptify، قوة نماذج اللغة الكبيرة أصبحت الآن أكثر إتاحة وموثوقية من أي وقت مضى. ابدأ في بناء تطبيقات معالجة اللغة الطبيعية المذهلة اليوم!

---

*هل وجدت هذا الدليل مفيداً؟ شارك مشاريعك وتجاربك مع Promptify في التعليقات أدناه!*
