---
title: "تقييم أكثر من 100 نموذج لغوي كبير باستدعاءات API فقط باستخدام Evalchemy: دليل شامل للمعايير بدون تثبيت"
excerpt: "تعلم كيفية تقييم أكثر من 100 نموذج API بما في ذلك GPT-4o وClaude-3 وGemini بدون تثبيت باستخدام مجموعة Evalchemy + Curator + LiteLLM"
seo_title: "تقييم Evalchemy API للنماذج اللغوية الكبيرة - دليل المعايير بدون تثبيت"
seo_description: "دليل شامل لتقييم أكثر من 100 نموذج لغوي كبير عبر استدعاءات API باستخدام Evalchemy وCurator وLiteLLM. لا حاجة للتثبيت لتقييم GPT-4o وClaude-3 وGemini"
date: 2025-06-13
categories: 
  - llmops
tags: 
  - Evalchemy
  - تقييم-النماذج-اللغوية-الكبيرة
  - Curator
  - LiteLLM
  - المعايير
  - تقييم-API
  - MLOps
  - اختبار-النماذج
author_profile: true
toc: true
toc_label: "جدول المحتويات"
lang: ar
permalink: /ar/llmops/evalchemy-api-llm-evaluation-guide/
canonical_url: "https://thakicloud.github.io/ar/llmops/evalchemy-api-llm-evaluation-guide/"
---

⏱️ **الوقت المقدر للقراءة**: 12 دقيقة

## الملخص التنفيذي

**Evalchemy** يركز أصلاً على طرق التثبيت المحلي للنماذج (HuggingFace وvLLM وغيرها)، لكن بفضل **محولات نماذج Curator** (تكامل LiteLLM) و**خلفيات OpenAI / Anthropic / API أخرى في LM-Eval-Harness**، يمكنك تنفيذ معايير متطابقة باستخدام **استدعاءات REST API فقط**.

مجرد تغيير علامات CLI مثل `--model curator` أو `--model openai` يمكّن تقييم **أكثر من 100 نموذج API** بما في ذلك GPT-4o وClaude-3 وGemini-2 وخوادم vLLM المخصصة بدون تثبيت.

يغطي هذا الدليل كل شيء من إعداد البيئة إلى ثلاثة أنماط تمثيلية: OpenAI الرسمي ونقاط نهاية vLLM الداخلية المتوافقة مع OpenAI وGoogle Gemini.

## فهم خط أنابيب Evalchemy / LM-Eval-Harness

LM-Eval-Harness (يُشار إليه بـ *Harness*) يؤدي التقييم باستخدام هيكل **"جولتين، ثلاث مراحل"**:

**تحميل البيانات وتوليد التقسيم** → **توليد النموذج (الاستنتاج)** → **التسجيل (المقاييس)**

في التكوين القياسي، يتم معالجة تقسيمات *train* و*eval* بشكل متسلسل، مع ظهور سجلات "Generating..." مرة واحدة لكل منهما. علامات CLI مثل `--predict_only` و`--skip_train` و`--skip_eval` تحدد **أي مراحل/جولات يتم تخطيها** بدلاً من تقليل مجموعة البيانات نفسها.

### المرحلة 1: تحميل البيانات وتوليد التقسيم

#### تفسير YAML للمهام وCLI

يقرأ Harness `--tasks` (قائمة مفصولة بفواصل) أو `--config YAML` لتحديد المهام المراد تنفيذها. يحتوي YAML على `task_name` و`batch_size` و`num_examples` و`subsample` وغيرها.

#### تحليل مجموعة البيانات

يحتوي `__init__.py` لكل حزمة مهام على ثابت `DATASET_PATH` يشير إلى مواقع JSON/JSONL الأصلية.

#### استراتيجية التقسيم

**تقسيم Train**: يُستخدم لبناء المطالبات قليلة الأمثلة وأمثلة "توليد النموذج"
**تقسيم Eval**: يولد استجابات باستخدام نفس البيانات (أو مجموعة التحقق)، ثم يقارن مع الحقيقة الأساسية للمقاييس
- `--skip_eval` → تخطي تقسيم eval بالكامل
- `--skip_train` → تخطي تقسيم train وأداء eval فقط

### المرحلة 2: جولات توليد النموذج

#### Curator → LiteLLM → الخلفية

يمرر Evalchemy جميع المطالبات إلى **Curator LLM API** من خلال `curator_lm.py`. يكتب Curator JSONL للطلبات في ذاكرة التخزين المؤقت ويستدعي **LiteLLM**، الذي يرسل طلبات REST POST إلى مقدمي الخدمة المحددين (OpenAI/Anthropic/vLLM/LM Studio).

#### التجميع المستمر

يجمع Curator الطلبات ضمن حدود الرموز وRPM للإرسال، مع حدوث تجميع ديناميكي إضافي على جانب vLLM/LM Studio.

#### جمع الاستجابات والتخزين المؤقت

استجابات الوحدة الصندوقية هي `CuratorResponse`؛ يتم استخراج النص عبر `response_obj.dataset[i]["response"]`. جميع الاستجابات والمطالبات الأصلية مخزنة بشكل دائم في `$HOME/.cache/curator/<run-id>/responses_*.jsonl`.

### المرحلة 3: مرحلة التسجيل

#### حساب المقاييس

يتم استدعاء دوال مقاييس مختلفة (Exact Match وBLEU وF1 وCode-Elo) وفقاً لتعريفات المهام. يتم تنفيذ التسجيل بعد اكتمال توليد **تقسيم eval**. `--predict_only` يتخطى دوال المقاييس ويحفظ المخرجات المولدة فقط.

#### تجميع النتائج والإخراج

يجمع Curator الرموز والوقت والتكاليف لإخراج جدول وحدة التحكم. يسجل Harness القاموس النهائي إلى `--output_path` (JSON) بالهيكل:

```jsonc
{ "results": {"AIME24": {"exact_match":0.83, …}},
  "configs": {...}, "versions": {...} }
```

### مصفوفة التنفيذ حسب العلامات

مجموعات علامات مختلفة تتحكم في أي مراحل يتم تنفيذها:

**افتراضي**: كلا من تقسيمات train وeval مع التسجيل - معيار كامل
**`--predict_only`**: كلا التقسيمين بدون تسجيل - جمع استجابات النموذج فقط
**`--skip_eval`**: تقسيم train فقط - اختبار استنتاج سريع
**`--skip_train`**: تقسيم eval فقط مع التسجيل - استخدام ذاكرة التخزين المؤقت قليلة الأمثلة الموجودة

### نقاط تحسين وقت التشغيل

**تقليل عدد العينات**: `--limit N` (عدد المهام) + مجموعة فرعية JSON أو مفتاح `subsample:`
**تحديد رموز الاستجابة**: `--gen_kwargs "max_new_tokens=256"` إلخ.
**تخطي الجولات**: مجموعات `--skip_eval` / `--skip_train`
**تمكين ذاكرة التخزين المؤقت**: `--use_cache DIR` → تجنب إعادة استدعاء المطالبات المتطابقة

فهم نمط **"تقسيمين (توليد-تسجيل)"** كتصميم أساسي لـ LM-Eval-Harness يمكّن من التحكم الفعال في تنفيذ المعايير من خلال علامات `--predict_only` و`--skip_*`. هيكل طبقة Curator → LiteLLM → مقدم الخدمة وذاكرة التخزين المؤقت للاستجابات (`$HOME/.cache/curator/<run-id>/responses_*.jsonl`) لا تقدر بثمن لإعادة إنتاج التجارب وتحليل التكلفة.

## المتطلبات المسبقة

### تثبيت التبعيات

```bash
# إنشاء بيئة Conda (موصى به)
conda create -n evalchemy python=3.10
conda activate evalchemy

# تثبيت Evalchemy + Curator + LiteLLM
pip install -e "git+https://github.com/mlfoundations/Evalchemy.git#egg=evalchemy[eval]" 
pip install bespokelabs-curator litellm  # للاتصال Curator-LiteLLM
```

**Evalchemy** يلف LM-Eval-Harness، ويثبت تلقائياً حزم إضافية.

### إعداد بيانات اعتماد API

```bash
export OPENAI_API_KEY="<your-openai-key>"
export ANTHROPIC_API_KEY="<your-anthropic-key>"
export GEMINI_API_KEY="<your-gcp-vertex-ai-key>"
# للخوادم vLLM المخصصة، لا حاجة لمفتاح أو استخدام قيم وهمية
```

يقرأ LiteLLM متغيرات البيئة مباشرة ويمررها إلى مقدمي API المعنيين.

## فهم تنسيق CLI

الحجج الرئيسية ومعانيها:

**`--model`**: نوع الخلفية (`curator` و`openai` و`anthropic` وغيرها)
**`--model_name`**: تدوين `provider/model` (قواعد LiteLLM) - مثل `openai/gpt-4o-mini`
**`--model_args`**: عنوان URL الأساسي لـ API وخيارات الترميز وغيرها بتنسيق `key=value` مفصول بفواصل
**`--tasks`**: قائمة المعايير (مفصولة بفواصل) - مثل `MTBench,LiveCodeBench`

تتضمن الخيارات الإضافية `--batch_size` و`--apply_chat_template` و`--output_path` وغيرها. الخيارات المفصلة متاحة في README وأمثلة YAML في مجلد `configs/`.

## أوامر السيناريوهات التمثيلية

### تقييم OpenAI GPT-4o

```bash
python -m eval.eval \
  --model curator \
  --tasks MTBench,LiveCodeBench \
  --model_name "openai/gpt-4o-mini" \
  --model_args "api_base=https://api.openai.com/v1" \
  --batch_size 8 \
  --output_path logs/gpt4o.json
```

يتم توجيه الطلبات إلى نقطة نهاية OpenAI ChatCompletion عبر Curator → LiteLLM.

### تقييم خادم vLLM الداخلي (متوافق مع OpenAI)

```bash
python -m eval.eval \
  --model curator \
  --tasks AIME24,MATH500 \
  --model_name "openai/hf-mistral-7b-instruct" \
  --model_args "api_base=http://vllm.company.local:8000/v1,api_key=dummy" \
  --apply_chat_template True \
  --output_path logs/mistral_vllm.json
```

قاعدة **LiteLLM** "`openai/` prefix" وعلامة `api_base` تمكّن استدعاء أي خادم متوافق مع OpenAI.

### تقييم Google Gemini-2 (Vertex AI)

```bash
python -m eval.eval \
  --model curator \
  --tasks AIME24,GPQADiamond \
  --model_name "gemini/gemini-2.0-flash-thinking-exp-01-21" \
  --model_args "project_id=my-gcp-project" \
  --apply_chat_template False \
  --output_path logs/gemini.json
```

يوفر Curator مُغلفات خاصة بـ **Gemini** تعمل بدون تثبيت منفصل.

## نصائح الاستخدام المتقدم

### تكوين YAML للمهام المتكررة

عرّف `tasks` و`batch_size` وغيرها في ملفات أمثلة مثل `configs/light_gpt4omini0718.yaml`:

```bash
python -m eval.eval \
  --model curator \
  --model_name openai/gpt-4o-mini \
  --config configs/light_gpt4omini0718.yaml
```

هذا النهج يبسط أوامر CLI.

### تحسين المعالجة غير المتزامنة والمجمعة

LM-Eval-Harness v0.4+ يدعم علامات `batch_size` و`--parallelism` لاستدعاءات API بنمط OpenAI، مما يقلل بشكل كبير من تكاليف الرموز:

```bash
python -m eval.eval \
  --model curator \
  --model_name "openai/gpt-4o-mini" \
  --batch_size 16 \
  --tasks MTBench \
  --parallelism 4
```

### تفسير النتائج

```bash
jq '.results' logs/gpt4o.json             # المقاييس حسب المعيار
jq '.config'  logs/gpt4o.json             # خيارات CLI المسجلة أثناء التنفيذ
```

هيكل JSON يتبع معايير LM-Eval-Harness للتكامل المباشر مع خطوط الأنابيب الموجودة.

## الأسئلة الشائعة لاستكشاف الأخطاء وإصلاحها

المشاكل الشائعة والحلول:

**`401 Unauthorized`**: متغير بيئة مفتاح API مفقود → تحقق من `echo $OPENAI_API_KEY`
**`Not Found /v1`**: `/v1` مفقود في `api_base` → استخدم تنسيق `http://host:port/v1`
**`ValueError: must set tokenized_requests`**: مطلوب لبعض النماذج (مثل Gemini) → أضف `--model_args 'tokenized_requests=False'`
**بطيء جداً**: اضبط `batch_size`، يُوصى بـ **stream=False** في وكيل LiteLLM

### نصائح تصحيح إضافية

**ضبط مستوى السجل**

```bash
export LOGLEVEL=DEBUG
python -m eval.eval --model curator --model_name "openai/gpt-4o-mini" --tasks MTBench
```

**اختبار اتصال الشبكة**

```bash
curl -H "Authorization: Bearer $OPENAI_API_KEY" \
     -H "Content-Type: application/json" \
     -d '{"model":"gpt-4o-mini","messages":[{"role":"user","content":"Hello"}]}' \
     https://api.openai.com/v1/chat/completions
```

## حالات الاستخدام في العالم الحقيقي

### سير عمل فحص النماذج

```bash
#!/bin/bash
# نص لتقييم نماذج متعددة بشكل متزامن

models=(
  "openai/gpt-4o-mini"
  "anthropic/claude-3-haiku-20240307"
  "gemini/gemini-1.5-flash"
)

for model in "${models[@]}"; do
  echo "Evaluating $model..."
  python -m eval.eval \
    --model curator \
    --model_name "$model" \
    --tasks MTBench,MATH500 \
    --batch_size 8 \
    --output_path "logs/$(echo $model | tr '/' '_').json" &
done

wait
echo "All evaluations completed!"
```

### تكامل خط أنابيب CI/CD

```yaml
# .github/workflows/model-evaluation.yml
name: Model Evaluation

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  evaluate:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Set up Python
      uses: actions/setup-python@v3
      with:
        python-version: '3.10'
    
    - name: Install dependencies
      run: |
        pip install -e "git+https://github.com/mlfoundations/Evalchemy.git#egg=evalchemy[eval]"
        pip install bespokelabs-curator litellm
    
    - name: Run evaluation
      env:
        OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
      run: |
        python -m eval.eval \
          --model curator \
          --model_name "openai/gpt-4o-mini" \
          --tasks MTBench \
          --output_path results.json
    
    - name: Upload results
      uses: actions/upload-artifact@v3
      with:
        name: evaluation-results
        path: results.json
```

## استراتيجيات تحسين التكلفة

### مراقبة استخدام الرموز

```python
import json
import tiktoken

def estimate_cost(log_file, model_name="gpt-4o-mini"):
    """تقدير استخدام الرموز والتكلفة من نتائج التقييم"""
    with open(log_file, 'r') as f:
        results = json.load(f)
    
    # حساب عدد رموز الإدخال (مثال)
    encoder = tiktoken.encoding_for_model("gpt-4o-mini")
    total_tokens = 0
    
    for task_result in results.get('results', {}).values():
        if 'samples' in task_result:
            for sample in task_result['samples']:
                if 'prompt' in sample:
                    total_tokens += len(encoder.encode(sample['prompt']))
    
    # تسعير OpenAI (معدلات 2024)
    cost_per_1k_tokens = 0.00015  # معدل رمز إدخال gpt-4o-mini
    estimated_cost = (total_tokens / 1000) * cost_per_1k_tokens
    
    print(f"Total tokens: {total_tokens:,}")
    print(f"Estimated cost: ${estimated_cost:.4f}")

# مثال على الاستخدام
estimate_cost("logs/gpt4o.json")
```

### تحسين حجم الدفعة

```bash
# ابدأ بدفعات صغيرة وزد تدريجياً
for batch_size in 1 4 8 16; do
  echo "Testing batch_size=$batch_size"
  time python -m eval.eval \
    --model curator \
    --model_name "openai/gpt-4o-mini" \
    --tasks MTBench \
    --batch_size $batch_size \
    --output_path "logs/batch_${batch_size}.json"
done
```

## اعتبارات النشر الإنتاجي

### القابلية للتوسع والأداء

يتطلب النشر واسع النطاق اعتباراً دقيقاً لمتطلبات البنية التحتية واستراتيجيات توزيع الأحمال وأنظمة المراقبة وبروتوكولات الصيانة. يتضمن التنفيذ إعداد مجموعات تقييم موزعة وتكوين آليات التوسع التلقائي وإنشاء لوحات مراقبة شاملة.

### بروتوكولات ضمان الجودة

الحفاظ على جودة التقييم يتطلب تنفيذ بروتوكولات ضمان الجودة الشاملة بما في ذلك الاختبار التلقائي واكتشاف انحدار الأداء والمراقبة المستمرة لدقة واتساق التقييم.

### التكامل مع خطوط أنابيب MLOps

التكامل الناجح مع سير عمل MLOps الحالية يتضمن إنشاء بروتوكولات تقييم موحدة وتنفيذ أنظمة تقارير تلقائية وإنشاء حلقات تغذية راجعة للتحسين المستمر للنماذج.

## الخلاصة

**المزايا الرئيسية**

**استدعاءات REST API فقط** بدلاً من التثبيت لإعادة إنتاج المعايير بسهولة
**مقدمو خدمة النماذج اللغوية الكبيرة المختلفون** (OpenAI وAnthropic وGoogle) قابلون للاختبار من خلال CLI واحد
**ميزات تكوين YAML والدفعات غير المتزامنة** لتوفير كبير في التكلفة والوقت

**سيناريوهات حالات الاستخدام**

فحص النماذج السريع قبل الحصول على موارد GPU
تحليل مقارنة الأداء بين مقدمي API متعددين
تقييم النماذج التلقائي في خطوط أنابيب CI/CD
تنفيذ المعايير واسعة النطاق بفعالية من حيث التكلفة

دمج مجموعة Evalchemy + Curator + LiteLLM في خطوط أنابيب MLOps الداخلية يمكّن من **فحص النماذج السريع واختبار الانحدار حتى قبل الحصول على موارد GPU**.

أصبح التقييم القائم على API ضرورياً للحفاظ على القدرة التنافسية في نظام النماذج اللغوية الكبيرة سريع التطور، مما يسمح بالتحقق الفوري من نماذج متطورة مختلفة بدون تكاليف إعداد بيئة GPU المحلية.

---

**المراجع:**

* [مستودع Evalchemy GitHub](https://github.com/mlfoundations/Evalchemy)
* [وثائق Bespoke Curator](https://docs.bespokelabs.ai/bespoke-curator/getting-started)
* [الوثائق الرسمية لـ LiteLLM](https://docs.litellm.ai/docs/providers)
* [LM-Eval-Harness](https://github.com/EleutherAI/lm-evaluation-harness)
* [وثائق OpenAI API](https://platform.openai.com/docs/models)
