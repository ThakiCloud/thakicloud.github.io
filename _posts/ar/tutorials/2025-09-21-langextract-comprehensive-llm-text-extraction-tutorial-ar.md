---
title: "LangExtract: دليل شامل لاستخراج النصوص المُهيكلة باستخدام النماذج اللغوية الكبيرة"
excerpt: "تعلم كيفية إتقان مكتبة LangExtract من Google لاستخراج المعلومات المُهيكلة من النصوص غير المُهيكلة باستخدام النماذج اللغوية المتقدمة مع تتبع دقيق للمصادر وإمكانيات التصور التفاعلي."
seo_title: "دروس LangExtract: دليل استخراج النصوص بالذكاء الاصطناعي - Thaki Cloud"
seo_description: "دليل شامل لمكتبة LangExtract من Google لاستخراج البيانات المُهيكلة من النصوص غير المُهيكلة باستخدام نماذج Gemini و OpenAI و Ollama مع أمثلة عملية."
date: 2025-09-21
categories:
  - tutorials
tags:
  - LangExtract
  - النماذج اللغوية
  - Google
  - Gemini
  - استخراج النصوص
  - البيانات المُهيكلة
  - معالجة اللغات الطبيعية
  - Python
author_profile: true
toc: true
toc_label: "جدول المحتويات"
lang: ar
permalink: /ar/tutorials/langextract-comprehensive-tutorial/
canonical_url: "https://thakicloud.github.io/ar/tutorials/langextract-comprehensive-tutorial/"
published: false
---

⏱️ **وقت القراءة المتوقع**: 12 دقيقة

## مقدمة

LangExtract هي مكتبة Python قوية طورتها Google والتي أحدثت ثورة في طريقة استخراج المعلومات المُهيكلة من النصوص غير المُهيكلة باستخدام النماذج اللغوية الكبيرة (LLMs). مع أكثر من 15,400 نجمة على GitHub، توفر هذه الأداة المتقدمة تتبعاً دقيقاً للمصادر وإمكانيات التصور التفاعلي، مما يجعلها أداة أساسية لسير العمل الحديث في استخراج البيانات.

## ما هو LangExtract؟

تم تصميم LangExtract لسد الفجوة بين بيانات النصوص غير المُهيكلة واستخراج المعلومات المُهيكلة. على عكس طرق التحليل التقليدية، يستفيد LangExtract من قوة النماذج اللغوية المتقدمة لفهم السياق والعلاقات والمعلومات الدقيقة داخل المستندات النصية.

### الميزات الرئيسية

- **دعم نماذج متعددة**: يعمل مع نماذج Gemini و OpenAI و Ollama المحلية
- **تتبع المصادر**: توفير إسناد دقيق للنص المصدر
- **التصور التفاعلي**: أدوات مدمجة لاستكشاف نتائج الاستخراج
- **قيود المخطط**: فرض تنسيقات إخراج مُهيكلة
- **المعالجة المتوازية**: التعامل مع المستندات الكبيرة بكفاءة
- **نظام الإضافات**: بنية قابلة للتوسع لمقدمي النماذج المخصصة

## التثبيت والإعداد

### التثبيت الأساسي

أبسط طريقة للبدء هي من خلال pip:

```bash
# إنشاء بيئة افتراضية
python -m venv langextract_env
source langextract_env/bin/activate  # على Windows: langextract_env\Scripts\activate

# تثبيت LangExtract
pip install langextract
```

### تثبيت التطوير

للعمل التطويري أو الوصول إلى أحدث الميزات:

```bash
git clone https://github.com/google/langextract.git
cd langextract

# التثبيت الأساسي
pip install -e .

# مع أدوات التطوير
pip install -e ".[dev]"

# مع تبعيات الاختبار
pip install -e ".[test]"
```

### إعداد Docker

للنشر المحتوي:

```bash
docker build -t langextract .
docker run --rm -e LANGEXTRACT_API_KEY="your-api-key" langextract python your_script.py
```

## تكوين مفتاح API

### إعداد النماذج السحابية

يدعم LangExtract عدة مقدمي خدمات سحابية. إليك كيفية تكوين مفاتيح API:

#### الخيار 1: متغيرات البيئة

```bash
export LANGEXTRACT_API_KEY="your-api-key-here"
```

#### الخيار 2: ملف .env (موصى به)

```bash
# إنشاء ملف .env
cat >> .env << 'EOF'
LANGEXTRACT_API_KEY=your-api-key-here
EOF

# تأمين مفتاح API الخاص بك
echo '.env' >> .gitignore
```

#### الخيار 3: مصادقة Vertex AI

للبيئات المؤسسية التي تستخدم Google Cloud:

```python
import langextract as lx

result = lx.extract(
    text_or_documents=input_text,
    prompt_description="استخراج المعلومات...",
    examples=[...],
    model_id="gemini-2.5-flash",
    language_model_params={
        "vertexai": True,
        "project": "your-project-id",
        "location": "global"
    }
)
```

### مصادر مفاتيح API

- **نماذج Gemini**: احصل على مفاتيح API من [AI Studio](https://aistudio.google.com/)
- **نماذج OpenAI**: الوصول إلى المفاتيح من [OpenAI Platform](https://platform.openai.com/)
- **Vertex AI**: للاستخدام المؤسسي مع حسابات الخدمة

## أمثلة الاستخدام الأساسي

### استخراج المعلومات البسيط

لنبدأ بمثال أساسي لاستخراج معلومات الاتصال:

```python
import langextract as lx

# نص عينة
text = """
الدكتورة سارة أحمد هي طبيبة قلب في مستشفى المدينة الطبية.
يمكن الوصول إليها على sara.ahmed@metro.com أو الاتصال على 966-11-123-4567.
مكتبها يقع في شارع الطب 123، جناح 456، الرياض، المملكة العربية السعودية.
"""

# تعريف موجه الاستخراج
prompt = "استخراج معلومات الاتصال بما في ذلك الاسم والمنصب والبريد الإلكتروني والهاتف والعنوان"

# الاستخراج الأساسي
result = lx.extract(
    text_or_documents=text,
    prompt_description=prompt,
    model_id="gemini-2.5-flash"
)

print(result)
```

### الاستخراج المُهيكل مع الأمثلة

للسيناريوهات الأكثر تعقيداً، قدم أمثلة لتوجيه الاستخراج:

```python
import langextract as lx

# نص طبي
medical_text = """
يشكو المريض من ألم في الصدر وضيق في التنفس وارتفاع في معدل ضربات القلب.
تم وصف ميتوبرولول 50 ملغ مرتين يومياً وليسينوبريل 10 ملغ مرة واحدة يومياً.
موعد المتابعة مجدول خلال أسبوعين.
"""

# تعريف الأمثلة
examples = [
    {
        "input": "المريض يتناول الأسبرين 81 ملغ يومياً للوقاية",
        "output": {
            "medications": [
                {
                    "name": "الأسبرين",
                    "dosage": "81 ملغ",
                    "frequency": "يومياً",
                    "purpose": "الوقاية"
                }
            ]
        }
    }
]

# الاستخراج مع الأمثلة
result = lx.extract(
    text_or_documents=medical_text,
    prompt_description="استخراج معلومات الأدوية بما في ذلك الاسم والجرعة والتكرار والغرض",
    examples=examples,
    model_id="gemini-2.5-flash"
)

print(result)
```

## العمل مع مقدمي النماذج المختلفة

### استخدام نماذج OpenAI

```python
import langextract as lx
import os

result = lx.extract(
    text_or_documents=input_text,
    prompt_description="استخراج المعلومات الرئيسية",
    examples=examples,
    model_id="gpt-4o",
    api_key=os.environ.get('OPENAI_API_KEY'),
    fence_output=True,
    use_schema_constraints=False  # مطلوب لـ OpenAI
)
```

### استخدام النماذج المحلية مع Ollama

للنشر المركز على الخصوصية أو المعالجة دون اتصال:

```bash
# تثبيت وإعداد Ollama
# زيارة ollama.com للحصول على تعليمات التثبيت
ollama pull gemma2:2b
ollama serve
```

```python
import langextract as lx

result = lx.extract(
    text_or_documents=input_text,
    prompt_description="استخراج المعلومات",
    examples=examples,
    model_id="gemma2:2b",
    model_url="http://localhost:11434",
    fence_output=False,
    use_schema_constraints=False
)
```

## الميزات المتقدمة

### معالجة المستندات الكبيرة

يتفوق LangExtract في معالجة المستندات الكبيرة مع المعالجة المتوازية:

```python
import langextract as lx
import requests

# تحميل مستند كبير (مثال روميو وجولييت)
url = "https://www.gutenberg.org/files/1513/1513-0.txt"
response = requests.get(url)
full_text = response.text

# استخراج معلومات الشخصيات
result = lx.extract(
    text_or_documents=full_text,
    prompt_description="استخراج أسماء الشخصيات والعلاقات والمشاهد الرئيسية",
    model_id="gemini-2.5-flash",
    max_parallel_calls=4  # المعالجة المتوازية
)
```

### الاستخراج المقيد بالمخطط

تحديد مخططات إخراج دقيقة للحصول على نتائج متسقة:

```python
from pydantic import BaseModel
from typing import List

class Medication(BaseModel):
    name: str
    dosage: str
    frequency: str
    route: str = "فموي"

class MedicalRecord(BaseModel):
    patient_id: str
    medications: List[Medication]
    symptoms: List[str]

# استخدام المخطط للاستخراج
result = lx.extract(
    text_or_documents=medical_text,
    prompt_description="استخراج المعلومات الطبية",
    schema=MedicalRecord,
    model_id="gemini-2.5-flash",
    use_schema_constraints=True
)
```

### التصور التفاعلي

يوفر LangExtract أدوات تصور مدمجة:

```python
# تفعيل التصور
result = lx.extract(
    text_or_documents=text,
    prompt_description="استخراج الكيانات",
    model_id="gemini-2.5-flash",
    visualize=True
)

# الوصول إلى بيانات التصور
print(result.visualization_data)
```

## حالات الاستخدام في العالم الحقيقي

### الرعاية الصحية: معالجة السجلات الطبية

```python
def extract_medical_info(clinical_notes):
    """استخراج المعلومات الطبية المُهيكلة من الملاحظات السريرية."""
    
    examples = [
        {
            "input": "يشكو المريض من صداع شديد، تم وصف إيبوبروفين 600 ملغ كل 6 ساعات",
            "output": {
                "symptoms": ["صداع شديد"],
                "medications": [
                    {
                        "name": "إيبوبروفين",
                        "dosage": "600 ملغ",
                        "frequency": "كل 6 ساعات"
                    }
                ]
            }
        }
    ]
    
    return lx.extract(
        text_or_documents=clinical_notes,
        prompt_description="استخراج الأعراض والأدوية وخطط العلاج",
        examples=examples,
        model_id="gemini-2.5-flash"
    )
```

### القانونية: تحليل العقود

```python
def extract_contract_terms(contract_text):
    """استخراج الشروط الرئيسية من العقود القانونية."""
    
    prompt = """
    استخراج معلومات العقد بما في ذلك:
    - الأطراف المعنية
    - مدة العقد
    - الالتزامات الرئيسية
    - شروط الدفع
    - بنود الإنهاء
    """
    
    return lx.extract(
        text_or_documents=contract_text,
        prompt_description=prompt,
        model_id="gemini-2.5-flash",
        temperature=0.1  # درجة حرارة منخفضة للدقة القانونية
    )
```

### الأكاديمية: تحليل الأوراق البحثية

```python
def extract_research_info(paper_text):
    """استخراج المعلومات المُهيكلة من الأوراق البحثية."""
    
    examples = [
        {
            "input": "تدرس هذه الدراسة 500 مشارك على مدى 12 شهراً...",
            "output": {
                "sample_size": 500,
                "study_duration": "12 شهراً",
                "methodology": "دراسة طولية"
            }
        }
    ]
    
    return lx.extract(
        text_or_documents=paper_text,
        prompt_description="استخراج منهجية البحث وحجم العينة والنتائج الرئيسية",
        examples=examples,
        model_id="gemini-2.5-flash"
    )
```

## مقدمو النماذج المخصصة

يتيح نظام الإضافات في LangExtract إضافة مقدمي نماذج مخصصة:

```python
from langextract.registry import registry

@registry.register(
    name="custom_provider",
    priority=10,
    model_ids=["custom-model-v1"]
)
class CustomProvider:
    def __init__(self, model_id, api_key=None, **kwargs):
        self.model_id = model_id
        self.api_key = api_key
    
    def generate(self, prompt, **kwargs):
        # تنفيذ منطق الإنتاج المخصص الخاص بك
        pass
    
    @staticmethod
    def get_schema_class():
        # اختياري: إرجاع فئة مخطط مخصصة
        return None
```

## تحسين الأداء

### أفضل الممارسات

1. **استخدم النماذج المناسبة**: اختر النموذج الصحيح لحالة الاستخدام الخاصة بك
   - Gemini 2.5 Flash: سريع وفعال من حيث التكلفة
   - GPT-4: دقة عالية للمهام المعقدة
   - النماذج المحلية: الخصوصية والمعالجة دون اتصال

2. **تحسين الموجهات**: الموجهات الواضحة والمحددة تحقق نتائج أفضل
3. **الاستفادة من الأمثلة**: قدم 2-3 أمثلة عالية الجودة
4. **المعالجة المجمعة**: معالجة مستندات متعددة بشكل متوازٍ
5. **قيود المخطط**: استخدم المخططات للحصول على تنسيق إخراج متسق

### معالجة الأخطاء

```python
import langextract as lx
from langextract.exceptions import LangExtractError

try:
    result = lx.extract(
        text_or_documents=text,
        prompt_description=prompt,
        model_id="gemini-2.5-flash",
        max_retries=3,
        timeout=30
    )
except LangExtractError as e:
    print(f"فشل الاستخراج: {e}")
    # تنفيذ منطق احتياطي
```

## الاختبار والتحقق

### اختبار الوحدة

```python
import unittest
import langextract as lx

class TestLangExtract(unittest.TestCase):
    def setUp(self):
        self.sample_text = "الدكتور أحمد علي يمكن الوصول إليه على john@example.com"
        
    def test_contact_extraction(self):
        result = lx.extract(
            text_or_documents=self.sample_text,
            prompt_description="استخراج عناوين البريد الإلكتروني",
            model_id="gemini-2.5-flash"
        )
        
        self.assertIn("john@example.com", str(result))

if __name__ == "__main__":
    unittest.main()
```

### اختبار التكامل

```bash
# تشغيل مجموعة الاختبارات الكاملة
pytest tests

# اختبار مقدم محدد
pytest tests/test_ollama.py

# التشغيل مع التغطية
pytest --cov=langextract tests
```

## استكشاف الأخطاء وإصلاحها

### المشاكل الشائعة

1. **أخطاء مفتاح API**
   - تحقق من أن مفتاح API مُعيّن بشكل صحيح
   - تحقق من أذونات المفتاح والحصص

2. **توفر النموذج**
   - تأكد من أن معرف النموذج صحيح
   - تحقق من توفر النموذج في منطقتك

3. **مشاكل الذاكرة مع المستندات الكبيرة**
   - استخدم معالجة القطع للنصوص الكبيرة جداً
   - فعّل المعالجة المتوازية

4. **تنسيق الإخراج غير المتسق**
   - استخدم قيود المخطط
   - قدم المزيد من الأمثلة
   - قلل درجة الحرارة للاتساق

### وضع التصحيح

```python
import logging
logging.basicConfig(level=logging.DEBUG)

result = lx.extract(
    text_or_documents=text,
    prompt_description=prompt,
    model_id="gemini-2.5-flash",
    debug=True
)
```

## اعتبارات الأمان

### خصوصية البيانات

- **المعالجة المحلية**: استخدم Ollama للبيانات الحساسة
- **أمان API**: قم بتدوير مفاتيح API بانتظام
- **الاحتفاظ بالبيانات**: فهم سياسات البيانات لدى المقدمين

### التحقق من الإدخال

```python
def safe_extract(text, max_length=10000):
    """استخراج آمن مع التحقق من الإدخال."""
    
    if len(text) > max_length:
        raise ValueError("النص المدخل طويل جداً")
    
    # تنظيف الإدخال
    text = text.strip()
    
    return lx.extract(
        text_or_documents=text,
        prompt_description="استخراج المعلومات",
        model_id="gemini-2.5-flash"
    )
```

## الخلاصة

يمثل LangExtract تقدماً مهماً في مجال استخراج المعلومات المُهيكلة من النصوص غير المُهيكلة. مزيجه من التكامل القوي مع النماذج اللغوية الكبيرة، وتتبع المصادر الدقيق، والبنية المرنة يجعله أداة لا تقدر بثمن لسير العمل الحديث في معالجة البيانات.

سواء كنت تعالج السجلات الطبية، أو تحلل المستندات القانونية، أو تستخرج الرؤى من الأوراق البحثية، يوفر LangExtract الأدوات والمرونة اللازمة لتحويل النصوص غير المُهيكلة إلى بيانات مُهيكلة قابلة للتنفيذ.

### الخطوات التالية

1. **استكشاف الأمثلة**: تحقق من [الأمثلة الرسمية](https://github.com/google/langextract/tree/main/examples)
2. **انضمام للمجتمع**: ساهم في [مقدمي المجتمع](https://github.com/google/langextract/blob/main/COMMUNITY_PROVIDERS.md)
3. **قراءة الوثائق**: زيارة [الوثائق الرسمية](https://github.com/google/langextract/tree/main/docs)
4. **تجربة العرض المباشر**: تجربة [عرض RadExtract](https://huggingface.co/spaces/google/radextract)

ابدأ رحلتك مع LangExtract اليوم وأحدث ثورة في طريقة عملك مع بيانات النصوص غير المُهيكلة!

---

**💡 نصيحة للمحترفين**: ابدأ بمهام الاستخراج البسيطة وزد التعقيد تدريجياً كلما أصبحت أكثر إلماماً بقدرات المكتبة. مفتاح النجاح مع LangExtract هو صياغة موجهات واضحة وتقديم أمثلة جيدة.
