---
title: "دليل شامل لتدريب Qwen3-4B باستخدام GRPO - استخدام مجموعة بيانات الاستدلال الكورية وتحليل دفاتر Colab"
excerpt: "تحليل تفصيلي لعملية تدريب نموذج Qwen3-4B باستخدام GRPO (تحسين سياسة الاستدلال المستندة إلى التدرج)، مع دليل عملي للتدريب الفعّال باستخدام مجموعات بيانات الاستدلال الكورية."
seo_title: "دليل تدريب نموذج الاستدلال الكوري Qwen3-4B GRPO - Thaki Cloud"
seo_description: "تحليل شامل لعملية تدريب Qwen3-4B باستخدام GRPO. دليل مفصل للمختصين يغطي تشريح دفاتر Colab واستخدام مجموعات بيانات الاستدلال الكورية."
date: 2025-07-30
last_modified_at: 2025-07-30
categories:
  - llmops
  - tutorials
tags:
  - Qwen3-4B
  - GRPO
  - 한국어추론
  - 강화학습
  - Colab
  - Unsloth
  - 추론모델
  - 데이터셋
  - 알리바바
  - Korean-Reasoning
author_profile: true
toc: true
toc_label: "جدول المحتويات"
toc_icon: "brain"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/ar/llmops/qwen3-4b-grpo-korean-reasoning-training-guide/"
reading_time: true
lang: ar
published: false
---

> ⏱️ **وقت القراءة المقدر**: 8 دقائق

## تحليل دفاتر Colab ودليل استخدام مجموعات البيانات الكورية

يستعرض هذا المستند النتائج المستخلصة من تحليل دفتر Colab المقدَّم، موضحاً العناصر الرئيسية المستخدمة في تدريب النموذج، ويقدم دليلاً تطبيقياً لتدريب النماذج باستخدام مجموعات البيانات الكورية.

### 1. نتائج تحليل دفتر Colab

#### 1.1 مجموعات البيانات المستخدمة

- **التدريب المسبق (Pre-finetuning):** استُخدم جزء من مجموعة بيانات `unsloth/OpenMathReasoning-mini` لتدريب النموذج على التعامل مع تنسيق GRPO المخصص. تحتوي هذه المجموعة على عينات عالية الجودة مفلترة من مجموعة بيانات Open Math Reasoning، وتشمل سلاسل استدلال DeepSeek R1.
- **تدريب GRPO:** استُخدمت مجموعة البيانات `open-r1/DAPO-Math-17k-Processed` (النسخة الإنجليزية) لتعزيز قدرات الاستدلال لدى النموذج عبر تدريب GRPO. تضم هذه المجموعة مسائل رياضية متنوعة مع حلولها.

#### 1.2 الأطر والمكتبات المستخدمة

- **Unsloth:** الإطار الأساسي لتحسين سرعة تدريب نماذج LoRA.
- **Hugging Face Transformers:** يتولى العمليات الأساسية لمعالجة اللغة الطبيعية كتحميل النماذج والترميز.
- **trl:** يُستخدم لتطبيق تقنيات التدريب المتقدمة مثل SFT (الضبط الدقيق الخاضع للإشراف) وGRPO (تحسين سياسة الاستدلال المستندة إلى التدرج).
- **datasets:** يتيح التحميل والمعالجة المسبقة وإدارة مجموعات البيانات بكفاءة.
- **vllm:** يدعم الاستدلال السريع على النماذج المدربة.
- **torch:** إطار PyTorch للعمليات الحسابية في التعلم العميق.

#### 1.3 إعدادات التدريب

- **التدريب المسبق بـ SFT:**
  - **Epochs:** 2
  - **Learning Rate:** 2e-4
  - **Batch Size (per device):** 1
  - **Gradient Accumulation Steps:** 1
- **تدريب GRPO:**
  - **Max Steps:** 100 (يجب تعديل هذه القيمة لإكمال epoch واحد على مجموعة البيانات كاملة)
  - **Learning Rate:** 5e-6
  - **Batch Size (per device):** 4 (مضبوط ليساوي num\_generations)
  - **Gradient Accumulation Steps:** 1 (يمكن رفعها إلى 4 للحصول على تدريب أكثر سلاسة)
  - **num\_generations:** 4 (يمكن تخفيضها عند نقص الذاكرة)
  - **max\_prompt\_length:** 202 (النسبة المئوية التسعون لأطوال مجموعة البيانات + 1)
  - **max\_completion\_length:** 1846 (max\_seq\_length مطروحاً منه max\_prompt\_length)

#### 1.4 وقت التدريب ووحدة معالجة الرسوميات الموصى بها

- **وقت التدريب المسبق بـ SFT:** نحو 2.8 دقيقة (170.89 ثانية)
- **وقت تدريب GRPO:** نحو 2.95 ساعة (10607.69 ثانية)
- **وحدة معالجة الرسوميات الموصى بها:** **Tesla T4**، كما تأكد من بيئة تشغيل الدفتر ونتائج تهيئة Unsloth.

### 2. قائمة مجموعات البيانات الكورية للاستدلال

فيما يلي مجموعات البيانات المتاحة على Hugging Face Hub والقابلة للاستخدام في تدريب نماذج الاستدلال الكورية.

| Dataset Name | Description | Source |
|---|---|---|
| lemon-mint/korean\_reasoning\_v0.1 | No description available. | Hugging Face Hub |
| lemon-mint/korean\_reasoning\_v0.2 | No description available. | Hugging Face Hub |
| lemon-mint/korean\_reasoning\_v1.0 | No description available. | Hugging Face Hub |
| lemon-mint/korean-reasoning-v01-sample | No description available. | Hugging Face Hub |
| lemon-mint/korean-reasoning-v01-test | No description available. | Hugging Face Hub |
| lemon-mint/korean-reasoning-v01 | No description available. | Hugging Face Hub |
| lemon-mint/korean-reasoning-v02 | No description available. | Hugging Face Hub |
| lemon-mint/korean-realqa-reasoning-v01 | No description available. | Hugging Face Hub |
| lemon-mint/korean-reasoning-v02-raw | No description available. | Hugging Face Hub |
| lemon-mint/korean-reasoning-v02-raw-conversational | No description available. | Hugging Face Hub |
| lemon-mint/korean-reasoning-v01-raw | No description available. | Hugging Face Hub |
| lemon-mint/korean-reasoning-v01-raw-conversational | No description available. | Hugging Face Hub |
| lemon-mint/korean-realqa-reasoning-v01-raw | No description available. | Hugging Face Hub |
| lemon-mint/korean-realqa-reasoning-v01-raw-conversational | No description available. | Hugging Face Hub |
| lemon-mint/korean-realqa-reasoning-v01-preference | No description available. | Hugging Face Hub |
| exp-models/korean-reasoning-mixture-20250203-preference | No description available. | Hugging Face Hub |
| exp-models/korean-reasoning-mixture-20250203-plaintext | No description available. | Hugging Face Hub |
| koreankiwi99/mnlp\_stem\_reasoning | No description available. | Hugging Face Hub |

### 3. دليل التدريب باستخدام مجموعات البيانات الكورية

يستلزم تدريب النموذج على مجموعات البيانات الكورية إجراء بعض التعديلات على كود الدفتر الأصلي. فيما يلي أبرز التعديلات المطلوبة.

#### 3.1 تحميل مجموعة البيانات

استخدم الدالة `load_dataset` من مكتبة `datasets` لتحميل مجموعة البيانات الكورية المطلوبة.

```python
from datasets import load_dataset

# Example: loading the 'lemon-mint/korean_reasoning_v0.1' dataset
# Split names ('train', 'validation', 'test', etc.) may vary by dataset.
dataset = load_dataset("lemon-mint/korean_reasoning_v0.1", split="train")
```

#### 3.2 المعالجة المسبقة للبيانات وتنسيقها

يتطلب تدريب GRPO أن تتبع مجموعة البيانات تنسيق حوار محدداً (`system`، `user`، `assistant`) وتنسيق الاستدلال والحل (`<start_working_out>`، `<end_working_out>`، `<SOLUTION>`، `</SOLUTION>`). يجب تعديل دوال المعالجة المسبقة والتنسيق لتتناسب مع بنية مجموعة البيانات الكورية المحملة.

- **تعيين الأعمدة:** قد تختلف أسماء أعمدة المشكلة (prompt) والحل (solution) في مجموعة البيانات المحملة عن الدفتر الأصلي. تحقق من معلومات مجموعة البيانات وعدّل أسماء الأعمدة أو تعامل معها مباشرة في الكود.

```python
# Check dataset column names and rename if needed
# dataset = dataset.rename_columns({"original_prompt_col": "prompt", "original_solution_col": "solution"})
```

- **دالة التنسيق المخصصة (تعديل `format_dataset`):** تعمل الدالة `format_dataset` في الدفتر الأصلي على إزالة وسوم `<think>` و`</think>` من مجموعة البيانات الإنجليزية وإضافة وسوم GRPO الجديدة. بالنسبة لمجموعات البيانات الكورية، قد يتطلب الأمر إعادة كتابة هذه الدالة كلياً أو تعديلها وفقاً لطريقة بناء نصوص المشكلة والحل. الهدف هو تحويل كل عينة إلى قائمة رسائل حوارية بالشكل: `{% raw %}{"role": "system", "content": system_prompt}, {"role": "user", "content": problem}, {"role": "assistant", "content": "<start_working_out>reasoning<end_working_out><SOLUTION>answer</SOLUTION>"}{% endraw %}`. إن كانت مجموعة البيانات الكورية تتضمن سلاسل استدلال، فاستخرجها وضعها بين `<start_working_out>` و`<end_working_out>`، أما الحل النهائي فيوضع بين `<SOLUTION>` و`</SOLUTION>`.

```python
def format_korean_dataset(x):
    # Extract problem and solution according to the Korean dataset structure
    problem = x["prompt"]   # Example: assuming the 'prompt' column holds the problem
    solution = x["solution"] # Example: assuming the 'solution' column holds the answer

    # Separate the reasoning chain and final answer based on the dataset's answer format
    # Example: if the answer is in the form 'reasoning chain###final answer'
    # parts = solution.split("###")
    # thoughts = parts[0].strip() if len(parts) > 1 else ""
    # answer = parts[-1].strip()

    # If the Korean dataset only contains the final answer (no reasoning chain)
    thoughts = "This dataset does not include a reasoning chain." # or set another default value
    answer = solution.strip()

    final_prompt = \
        reasoning_start + thoughts + reasoning_end + \
        solution_start + answer + solution_end

    return [
        {"role": "system",    "content": system_prompt},
        {"role": "user",      "content": problem},
        {"role": "assistant", "content": final_prompt},
    ]

# Apply to the dataset
dataset["Messages"] = dataset.apply(format_korean_dataset, axis=1)
```

- **الترميز وتصفية الأطوال:** يمكن تطبيق عملية ترميز الرسائل المنسقة وتصفية الأطوال وفق `max_seq_length` بنفس الطريقة المستخدمة في الدفتر الأصلي. غير أنه ينبغي مراجعة نتائج حساب `maximum_length` نظراً لاحتمال اختلاف أطوال الترميز في اللغة الكورية.

#### 3.3 تعديل دوال المكافأة (Reward Functions)

قد تستوجب دوال المكافأة، التي تمثل جوهر تدريب GRPO، تعديلات لتتناسب مع خصائص مجموعة البيانات الكورية.

- **الدوال `match_format` والمتعلقة بها:** دوال `match_format_exactly` و`match_format_approximately` تستخدم وسوم GRPO المحددة (`reasoning_end`، `solution_start`، `solution_end`)، لذا لا تحتاج إلى تعديل ما لم تغير الوسوم ذاتها.
- **الدوال `check_answer` و`check_numbers`:** تقوم هذه الدوال باستخراج الحل النهائي من النص المولَّد والحكم على صحته. إن كانت إجابات مجموعة البيانات الكورية في غير صيغة أرقام (مثلاً جمل كورية)، فيجب تعديل التعبير النمطي `match_numbers` أو تغيير منطق مقارنة الإجابات. حتى في حالة الإجابات الرقمية، قد تستلزم طريقة كتابة الأرقام في اللغة الكورية معالجة مسبقة إضافية (مثل حذف الفواصل).

```python
import re

# Review whether the regex needs updating to handle Korean numerals and related symbols
# match_numbers = re.compile(...)

# Review the answer extraction and comparison logic inside check_answer and check_numbers
# Especially if handling non-numeric answers, the logic will need to change
```

#### 3.4 إعداد GRPO Trainer

عند ضبط `GRPO Trainer`، يجب إعادة حساب `max_prompt_length` و`max_completion_length` استناداً إلى أطوال الترميز الناتجة عن مجموعة البيانات الكورية وتطبيقها. أما بقية إعدادات GRPO (مثل `learning_rate` و`num_generations`) فيمكن ضبطها تجريبياً وفق خصائص النموذج ومجموعة البيانات.

### 4. الخلاصة

استعرض هذا المستند عملية تدريب نموذج Qwen3-4B باستخدام GRPO، وقدم على أساسها منهجية عملية لتدريب النماذج باستخدام مجموعات البيانات الكورية. يُعدّ التعديل المناسب لمرحلة المعالجة المسبقة للبيانات ودوال المكافأة وفق خصائص مجموعة البيانات الكورية أمراً محورياً لنجاح عملية التدريب. يمكن الاستفادة من الإرشادات الواردة في هذا المستند للمضي قدماً في تطوير نماذج الاستدلال الكورية.
