---
title: "dots.ocr: تحليل شامل لنموذج تحليل المستندات متعدد اللغات بـ 1.7B معامل وأداء SOTA"
excerpt: "استعراض النموذج البصري اللغوي dots.ocr الذي أصدرته RedNote، وكيفية تنفيذ تحليل تخطيط المستندات متعدد اللغات والتعرف الضوئي على الحروف في نموذج واحد."
seo_title: "dots.ocr - تحليل شامل لنموذج تحليل المستندات متعدد اللغات - Thaki Cloud"
seo_description: "تحليل معمق لبنية dots.ocr الذي حقق أداء SOTA بـ 1.7B معامل، ونتائج الاختبارات المرجعية وطرق الاستخدام العملي."
date: 2025-08-06
last_modified_at: 2025-08-06
categories:
  - datasets
  - llmops
tags:
  - dots.ocr
  - document-parsing
  - multilingual-ocr
  - vision-language-model
  - document-ai
  - layout-detection
  - rednote
  - omnidocbench
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/ar/datasets/dots-ocr-multilingual-document-parsing-guide/"
reading_time: true
lang: ar
published: false
---

⏱️ **وقت القراءة المقدر**: 8 دقائق

## مقدمة

يشهد مجال تحليل المستندات تحولات جذرية. تقليديا، كانت عملية اكتشاف تخطيط المستند والتعرف على النصوص تتطلب تشغيل عدة نماذج مستقلة مرتبطة في شكل خط أنابيب متسلسل. غير أن **dots.ocr** الذي أصدره فريق بحث RedNote يدمج كل هذه المهام في نموذج بصري لغوي (VLM) واحد محققا أداء SOTA (State-of-the-Art) في الوقت ذاته.

والجدير بالملاحظة بشكل خاص أن الحجم الصغير نسبيا للنموذج البالغ 1.7B معامل يحقق أداء مماثلا للنماذج الكبيرة مثل Doubao-1.5 وGemini 2.5 Pro. يمثل هذا نموذجا ممتازا لتصميم أنظمة ذكاء اصطناعي عملية تسعى إلى الكفاءة والأداء معا.

## المزايا الجوهرية لـ dots.ocr

### 1. ابتكار البنية الموحدة

يكمن الابتكار الأبرز لـ dots.ocr في كونه **نموذجا بصريا لغويا واحدا** يؤدي المهام التالية في آن واحد:

- **اكتشاف التخطيط**: تحديد مناطق النص والجداول والصور والمعادلات وتصنيفها
- **التعرف على النصوص**: استخراج النصوص بدقة عبر OCR
- **ترتيب القراءة**: ترتيب العناصر وفق الترتيب الذي يقرأه الإنسان
- **تحويل الصيغة**: إخراج النتائج بصيغ ملائمة مثل Markdown وHTML وLaTeX

يمكن التبديل بين أوضاع المهام المختلفة لخطوط الأنابيب متعددة النماذج المعقدة بمجرد تغيير الموجه (prompt).

### 2. دعم ممتاز للغات متعددة

يُظهر dots.ocr تفوقا حاسما في تحليل المستندات متعددة اللغات بما فيها اللغات قليلة الموارد:

```text
지원 언어 예시:
- 영어 (English)
- 중국어 (Chinese)
- 티베트어 (Tibetan)
- 네덜란드어 (Dutch)
- 칸나다어 (Kannada)
- 러시아어 (Russian)
```

يعد هذا ميزة بالغة الأهمية للشركات التي تحتاج إلى معالجة مستندات مكتوبة بلغات متنوعة في بيئة الأعمال العالمية.

## تحليل أداء الاختبارات المرجعية

### نتائج OmniDocBench

حقق dots.ocr أداء SOTA التالي في OmniDocBench:

| مجال المهمة | أداء dots.ocr | الجهة المقارنة |
|------------|--------------|----------------|
| التعرف على النصوص | SOTA | نماذج OCR الحالية |
| التعرف على الجداول | SOTA | نماذج استخراج الجداول المتخصصة |
| ترتيب القراءة | SOTA | نماذج تحليل التخطيط |
| التعرف على المعادلات | مستوى Doubao-1.5/Gemini2.5-Pro | نماذج VLM الكبيرة |

### التفوق في الأداء متعدد اللغات

في الاختبار المرجعي الخاص **dots.ocr-bench**، أظهر النموذج تفوقا حاسما في كل من اكتشاف التخطيط والتعرف على المحتوى. وهذا يعني قدرة تعميم قوية على لغات متنوعة، خلافا للنماذج الحالية التي تُحسَّن في الغالب للغتي الإنجليزية والصينية.

## التطبيق العملي وطرق الاستخدام

### 1. إعداد البيئة

لنبدأ بإعداد البيئة لاستخدام dots.ocr:

```bash
# 모델 다운로드 및 등록
python3 tools/download_model.py
export hf_model_path=./weights/DotsOCR
export PYTHONPATH=$(dirname "$hf_model_path"):$PYTHONPATH

# vLLM 서버 설정 (주의: 디렉토리명에 점(.) 사용 금지)
sed -i '/^from vllm\.entrypoints\.cli\.main import main$/a\
from DotsOCR import modeling_dots_ocr_vllm' `which vllm`
```

### 2. تشغيل خادم vLLM

```bash
# GPU 메모리 최적화된 vLLM 서버 실행
CUDA_VISIBLE_DEVICES=0 vllm serve ${hf_model_path} \
  --tensor-parallel-size 1 \
  --gpu-memory-utilization 0.95 \
  --chat-template-content-format string \
  --served-model-name model \
  --trust-remote-code
```

### 3. استخدام أوضاع التحليل المتعددة

تكمن قوة dots.ocr في قدرته على أداء مهام متنوعة بنموذج واحد:

#### تحليل التخطيط الكامل والتعرف

```bash
# 이미지 파일 파싱
python3 dots_ocr/parser.py demo/demo_image1.jpg

# PDF 파일 파싱 (대용량 PDF의 경우 스레드 수 증가)
python3 dots_ocr/parser.py demo/demo_pdf1.pdf --num_thread 64
```

#### اكتشاف التخطيط فقط

```bash
python3 dots_ocr/parser.py demo/demo_image1.jpg --prompt prompt_layout_only_en
```

#### استخراج النص فقط (باستثناء الرأس والتذييل)

```bash
python3 dots_ocr/parser.py demo/demo_image1.jpg --prompt prompt_ocr
```

#### تحليل منطقة محددة

```bash
# 바운딩 박스 지정으로 특정 영역만 분석
python3 dots_ocr/parser.py demo/demo_image1.jpg \
  --prompt prompt_grounding_ocr \
  --bbox 163 241 1536 705
```

### 4. الاستخدام عبر HuggingFace Transformers

إذا كنت تفضل استخدام HuggingFace Transformers بدلا من vLLM:

```python
import torch
from transformers import AutoModelForCausalLM, AutoProcessor
from qwen_vl_utils import process_vision_info

# 모델 로드
model_path = "./weights/DotsOCR"
model = AutoModelForCausalLM.from_pretrained(
    model_path,
    attn_implementation="flash_attention_2",
    torch_dtype=torch.bfloat16,
    device_map="auto",
    trust_remote_code=True
)
processor = AutoProcessor.from_pretrained(model_path, trust_remote_code=True)

# 프롬프트 설정
prompt = """Please output the layout information from the PDF image, 
including each layout element's bbox, its category, and the corresponding 
text content within the bbox.

1. Bbox format: [x1, y1, x2, y2]
2. Layout Categories: ['Caption', 'Footnote', 'Formula', 'List-item', 
   'Page-footer', 'Page-header', 'Picture', 'Section-header', 'Table', 'Text', 'Title']
3. Text Extraction & Formatting Rules:
   - Picture: Text field omitted
   - Formula: LaTeX format
   - Table: HTML format
   - Others: Markdown format
4. Output: Single JSON object sorted by reading order
"""

# 메시지 구성 및 추론
messages = [{
    "role": "user",
    "content": [
        {"type": "image", "image": "demo/demo_image1.jpg"},
        {"type": "text", "text": prompt}
    ]
}]

# 추론 실행
text = processor.apply_chat_template(messages, tokenize=False, add_generation_prompt=True)
image_inputs, video_inputs = process_vision_info(messages)
inputs = processor(text=[text], images=image_inputs, videos=video_inputs, 
                  padding=True, return_tensors="pt").to("cuda")

generated_ids = model.generate(**inputs, max_new_tokens=24000)
output_text = processor.batch_decode(
    [out_ids[len(in_ids):] for in_ids, out_ids in zip(inputs.input_ids, generated_ids)],
    skip_special_tokens=True, clean_up_tokenization_spaces=False
)
```

## تحليل نتائج المخرجات

يوفر dots.ocr نتائج منظمة على النحو التالي:

### 1. بيانات JSON المنظمة

- **مربعات الإحاطة**: إحداثيات الموضع الدقيق لكل عنصر
- **الفئة**: تصنيف تلقائي ضمن 11 فئة من فئات التخطيط
- **محتوى النص**: النص المستخرج لكل عنصر

### 2. التحويل إلى Markdown

- ملف Markdown يربط نصوص جميع الخلايا المكتشفة
- إصدار يستثني الرأس والتذييل لضمان التوافق مع الاختبارات المرجعية

### 3. نتائج الإظهار المرئي

- تراكب مربعات إحاطة التخطيط المكتشفة على الصورة الأصلية

## تحسين الأداء والتنبيهات

### التوصيات لأفضل أداء

#### تحسين دقة الصورة

```bash
# PDF 파싱 시 DPI 설정 (권장: 200 DPI)
# 최적 해상도: 11,289,600 픽셀 이하
```

#### تحسين ذاكرة GPU

```bash
# vLLM 서버 실행 시 GPU 메모리 활용률 조정
--gpu-memory-utilization 0.95  # 필요에 따라 조정
```

### القيود المعروفة

#### 1. عناصر المستند المعقدة

- **الجداول عالية التعقيد**: غير مثالية حاليا
- **المعادلات**: دقة محدودة للصيغ الرياضية المعقدة
- **الصور**: الصور الموجودة داخل المستند لا تُحلَّل حاليا

#### 2. شروط فشل التحليل

- عندما تكون نسبة الحرف إلى البكسل مرتفعة بشكل مفرط
- حالات التكرار اللانهائي بسبب الأحرف الخاصة المتتالية (`...` أو `___`)

#### 3. استخدام موجهات بديلة

عند حدوث مشكلات، جرّب هذه الموجهات:

- `prompt_layout_only_en`: اكتشاف التخطيط فقط
- `prompt_ocr`: استخراج النص فقط
- `prompt_grounding_ocr`: تحليل منطقة محددة

## سيناريوهات الاستخدام العملي

### 1. إدارة المستندات المؤسسية متعددة اللغات

```python
# 다국어 계약서, 보고서 일괄 처리
for document in multilingual_documents:
    result = parse_document(document, language="auto")
    structured_data = extract_structured_info(result)
    store_to_database(structured_data)
```

### 2. بناء قاعدة بيانات الأوراق الأكاديمية

```python
# 수식과 표가 포함된 논문 자동 파싱
papers = load_academic_papers()
for paper in papers:
    layout_info = dots_ocr.parse(paper, mode="academic")
    formulas = extract_latex_formulas(layout_info)
    tables = extract_html_tables(layout_info)
    create_searchable_index(formulas, tables)
```

### 3. رقمنة المستندات القانونية

```python
# 복잡한 법률 문서의 구조화
legal_docs = load_legal_documents()
for doc in legal_docs:
    parsed = dots_ocr.parse(doc, preserve_reading_order=True)
    sections = identify_legal_sections(parsed)
    create_legal_knowledge_base(sections)
```

## التوجهات المستقبلية

يعتزم فريق بحث RedNote تحقيق التحسينات التالية:

### الأهداف قصيرة المدى

- **تحسين دقة تحليل الجداول والمعادلات**
- **تحسين أداء معالجة ملفات PDF الكبيرة**
- **إضافة ميزة تحليل الصور داخل المستند**

### الرؤية طويلة المدى

- **نموذج تعرف شامل**: دمج الاكتشاف العام وتعليق الصور وOCR
- **نماذج أكثر قوة وكفاءة**: تحسين الأداء والكفاءة في آن واحد
- **تعاون مجتمعي**: التطوير عبر المساهمات في المصدر المفتوح

## الخلاصة

يمثل dots.ocr نموذجا مبتكرا يكشف عن تحول جذري في مجال تحليل المستندات. بحجم صغير نسبيا يبلغ 1.7B معامل، يحقق أداء SOTA مع إثبات إمكانية نشر عملية في الوقت ذاته.

تشير نقاط القوة الثلاث الجوهرية، وهي **أداء مهام متنوعة بنموذج واحد** و**دعم ممتاز للغات متعددة** و**بنية فعالة**، إلى إمكانيات واسعة للتطبيق في البيئات العملية.

يُتوقع أن يؤدي استخدام dots.ocr في مجالات متنوعة كمعالجة المستندات متعددة اللغات ورقمنة المواد الأكاديمية وإدارة المستندات القانونية إلى تحسين كفاءة العمل بشكل ملحوظ. ومع وضوح توجهات التطوير المستقبلية، يُتوقع أن يتطور النموذج إلى أداة أكثر قوة من خلال التحسينات المستمرة.

---

**المراجع**
- [dots.ocr GitHub Repository](https://github.com/rednote-hilab/dots.ocr)
- [HuggingFace Model Hub](https://huggingface.co/models?search=dots.ocr)
- [OmniDocBench الوثائق الرسمية](https://omnidocbench.github.io/)
