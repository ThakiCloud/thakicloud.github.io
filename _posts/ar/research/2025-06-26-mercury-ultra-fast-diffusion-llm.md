---
title: "Mercury: الابتكار في نماذج اللغة التوليدية فائقة السرعة القائمة على الانتشار"
excerpt: "Mercury، المطوَّر من Inception Labs، نموذج لغوي كبير يعتمد على الانتشار يحقق سرعات استدلال تصل إلى 10 أضعاف النماذج التوليدية التقليدية ويرسم حدوداً جديدة للسرعة والجودة في ذكاء الترميز."
date: 2025-06-26
categories:
  - research
  - llmops
tags:
  - Mercury
  - diffusion-models
  - language-models
  - coding-ai
  - parallel-generation
author_profile: true
toc: true
toc_label: "تحليل بحث Mercury"
lang: ar
canonical_url: "https://thakicloud.github.io/ar/research/mercury-ultra-fast-diffusion-llm/"
published: false
---

⏱️ **وقت القراءة المقدر**: 8 دقائق

Mercury، الذي أعلنت عنه Inception Labs، نموذج لغوي كبير مبتكر يعتمد على الانتشار يتجاوز قيود النماذج التوليدية التقليدية لتقديم أداء استدلال فائق السرعة.

## كيف تُحوّل نماذج الانتشار توليد اللغة

### قيود نماذج اللغة الحالية

تحمل نماذج اللغة التوليدية التقليدية القيود الجوهرية التالية:

- **التوليد المتسلسل**: لا يمكن توليد سوى رمز واحد في كل مرة
- **تزايد وقت الاستجابة**: تتراكم أوقات الانتظار عند توليد نص طويل
- **استغلال غير فعّال لوحدة GPU**: تُستثمر إمكانات المعالجة المتوازية بشكل ضعيف
- **قيود التطبيقات الفورية**: تدهور تجربة المستخدم في الإكمال التلقائي للكود وسير عمل الوكلاء وما شابهها

### نهج الانتشار في Mercury

يعالج Mercury هذه المشكلات عبر **التوليد المتوازي للرموز**:

```python
# الأسلوب التوليدي التقليدي
for i in range(sequence_length):
    token = model.generate_next_token(context)
    context.append(token)  # توليد متسلسل

# أسلوب الانتشار في Mercury
noisy_tokens = initialize_random_noise(sequence_length)
for step in range(diffusion_steps):
    # تحسين جميع الرموز في وقت واحد
    noisy_tokens = model.denoise_all_tokens(noisy_tokens)
```

## عائلة نماذج Mercury Coder

### تشكيلة النماذج

**Mercury Coder Mini**
- **مُحسَّن للسرعة**: 1,109 رمزاً في الثانية (على GPU H100)
- **حالة الاستخدام**: الإكمال التلقائي الفوري للكود، النماذج الأولية السريعة
- **الجودة**: يتفوق على نماذج المصدر المفتوح المحسَّنة للسرعة

**Mercury Coder Small**
- **أداء متوازن**: 737 رمزاً في الثانية
- **الجودة**: يُضاهي النماذج التجارية المحسَّنة للسرعة
- **التنوع**: يدعم مهام الترميز المعقدة وأعباء الاستدلال

### البنية التقنية

#### عملية تدريب الانتشار

يتكون تدريب Mercury من **عملية أمامية** و**عملية عكسية**:

**العملية الأمامية (إضافة ضوضاء)**:
```
نص نظيف x -> z1 مضوَّشة -> z2 -> ... -> zT مضوَّشة كلياً
```

**العملية العكسية (إزالة الضوضاء)**:
```
zT مضوَّشة كلياً -> zT-1 -> ... -> z1 -> النص المستعاد x
```

هدف التدريب:
```
L(x) = -E_t[gamma(t) * E_{z_t~q} log p_theta(x|z_t)]
```

#### البنية القائمة على Transformer

يعتمد Mercury بنية Transformer، مما يمنحه المزايا التالية:

- **التوافق**: متوافق تماماً مع تقنيات التحسين الحالية
- **قابلية التوسع**: بنية مناسبة للتدريب على نطاق واسع
- **الكفاءة**: يستطيع الاستفادة من تحسينات العمليات منخفضة المستوى

## نتائج التقييم

### أداء معيار الترميز

| النموذج | HumanEval | MBPP | MultiPL-E | السرعة (رمز/ث) |
|---|---|---|---|---|
| **Mercury Coder Mini** | **88.0** | **77.1** | **74.1** | **1,109** |
| **Mercury Coder Small** | **90.0** | **76.6** | **76.2** | **737** |
| GPT-4o Mini | 88.0 | 74.6 | 72.0 | 59 |
| Claude 3.5 Haiku | 86.0 | 78.0 | 72.3 | 61 |
| Gemini 2.0 Flash Lite | 90.0 | 75.0 | 79.5 | 201 |

### توليد الكود متعدد اللغات

**نتائج معيار MultiPL-E** (الدقة %):

| النموذج | C++ | Java | JavaScript | PHP | Bash | TypeScript | المتوسط |
|---|---|---|---|---|---|---|---|
| Mercury Coder Mini | 78.9 | 74.5 | 78.9 | 72.7 | 56.5 | 83.2 | **74.1** |
| Mercury Coder Small | 82.0 | 80.1 | 83.9 | 78.3 | 50.1 | 82.6 | **76.2** |
| Codestral 2501 | 80.1 | 72.7 | 83.2 | 73.9 | 47.2 | 83.2 | 73.4 |

### أداء Fill-in-the-Middle (FIM)

الأداء في سيناريوهات الإكمال التلقائي للكود:

| النموذج | سطر واحد | نطاق عشوائي | المتوسط |
|---|---|---|---|
| **Mercury Coder Mini** | **92.9** | **71.5** | **82.2** |
| **Mercury Coder Small** | **93.1** | **76.5** | **84.8** |
| Codestral 2501 | 93.0 | 72.0 | 82.5 |
| GPT-4o Mini | 74.8 | 47.0 | 60.9 |

## تقييم المستخدمين الفعليين: Copilot Arena

### تصنيفات الأداء

| النموذج | وقت الاستجابة (ث) | ترتيب الاستجابة | درجة Elo | ترتيب الجودة |
|---|---|---|---|---|
| DeepSeek V2.5 (FIM) | 2.07 | 11 | 1025 | 1 |
| Claude 3.5 Sonnet | 1.46 | 8 | 1003 | 1 |
| **Mercury Coder Mini** | **0.25** | **1** | **993** | **2** |
| Codestral | 0.31 | 2 | 992 | 2 |
| GPT-4o | 0.76 | 5 | 980 | 3 |

**الملاحظة الرئيسية**: حقق Mercury Coder Mini **المرتبة الثانية في الجودة** مع تسجيل **أسرع وقت استجابة** في الوقت ذاته.

## الابتكارات التقنية الجوهرية

### تحسين الاستدلال المتوازي

تنبع مكاسب سرعة Mercury من التحسينات التالية على مستوى النظام:

**الدُفعات الديناميكية**:
```python
class MercuryInferenceEngine:
    def __init__(self):
        self.dynamic_batcher = DynamicBatcher()
        self.custom_kernels = ParallelInferenceKernels()

    def generate(self, prompts, quality_speed_tradeoff=0.5):
        # الضبط التلقائي للمقايضة بين الجودة والسرعة
        batch = self.dynamic_batcher.optimize_batch(prompts)
        return self.parallel_diffusion_sample(batch)
```

**نوى CUDA المخصصة**:
- الاستخدام الأقصى لحيّز ذاكرة GPU
- عمليات إزالة ضوضاء متوازية مُحسَّنة
- ضبط ديناميكي لحجم الدُفعة

### التوافق المضمون

يوفر Mercury توافقاً كاملاً مع الأنظمة البيئية الحالية:

**متوافق مع OpenAI API**:
```python
# يمكن استخدام كود OpenAI API الحالي كما هو
response = openai.ChatCompletion.create(
    model="mercury-coder-mini",  # يتغير اسم النموذج فقط
    messages=[{"role": "user", "content": "اكتب دالة Python"}],
    max_tokens=500
)
```

**دعم الضبط الدقيق**:
- RLHF (التعلم المعزز من التغذية الراجعة البشرية)
- DPO (تحسين التفضيل المباشر)
- منهجيات ضبط التعليمات التقليدية قابلة للتطبيق

## حالات الاستخدام العملي

### نظام الإكمال التلقائي للكود

```python
class MercuryCodeCompletion:
    def __init__(self):
        self.model = MercuryCoder("mini")
        self.cache = CompletionCache()

    async def complete_code(self, context, cursor_position):
        # إكمال فوري بمتوسط وقت استجابة 25 مللي ثانية
        start_time = time.time()
        completion = await self.model.fill_in_middle(
            prefix=context[:cursor_position],
            suffix=context[cursor_position:],
            max_tokens=100
        )
        latency = time.time() - start_time

        # يحقق عادةً أقل من 25 مللي ثانية
        assert latency < 0.1, f"تجاوز وقت الاستجابة: {latency}s"
        return completion
```

### سير عمل الوكلاء

يتعامل **الاستدلال السريع** مع المهام متعددة الخطوات المعقدة بكفاءة:

```python
class CodeReviewAgent:
    def __init__(self):
        self.mercury = MercuryCoder("small")

    async def review_pr(self, code_diff):
        # تشغيل تحليلات متعددة بالتوازي
        tasks = [
            self.mercury.analyze_security(code_diff),
            self.mercury.check_performance(code_diff),
            self.mercury.suggest_improvements(code_diff),
            self.mercury.generate_tests(code_diff)
        ]

        # يكتمل التحليل بأكمله في غضون ثوانٍ قليلة
        results = await asyncio.gather(*tasks)
        return self.consolidate_review(results)
```

## قابلية التوسع والآفاق المستقبلية

### خصائص التوسع

تُظهر نماذج Mercury **تحسينات أداء متسقة مع زيادة الحجم**:

- يتفوق Mercury Coder Small باستمرار على Mini في جميع المعايير
- يُرسّخ قوانين التوسع لنماذج اللغة التوليدية القائمة على الانتشار
- يُشير إلى إمكانات قوية لمزيد من المكاسب مع نماذج أكبر

### توسيع نطاق التطبيق

**الحالي**: نموذج متخصص في الترميز
**المخطط**:
- نموذج لتوليد النصوص العامة
- نموذج متعدد الوسائط (كود + صور)
- نماذج متخصصة في مجالات بعينها (علوم، رياضيات، قانون، إلخ)

### الأثر على الصناعة

**كفاءة التكلفة**:
- تكاليف استدلال مخفضة بشكل ملحوظ
- نشر خدمات الوقت الفعلي يصبح مجدياً
- بيئات الحوسبة الطرفية تصبح قابلة للتطبيق

**ابتكار تجربة المستخدم**:
- تفاعل طبيعي عبر تقليص زمن الاستجابة
- المعالجة الفورية لمهام الاستدلال المعقدة
- إمكانات جديدة لأدوات الترميز التفاعلية

## التحديات التقنية وحلولها

### التحديات المتأصلة في نماذج الانتشار

**التعامل مع البيانات المنفصلة**:
- اللغة تتكون من رموز منفصلة على عكس الصور المستمرة
- تعقيد عمليتي إضافة الضوضاء وإزالتها
- **الحل**: تطوير خوارزميات ضوضاء وإزالة ضوضاء جديدة

**تقليل خطوات الاستدلال**:
- الحاجة إلى تقليل خطوات الانتشار مع الحفاظ على الجودة
- **الحل**: خوارزميات أخذ عينات تكيفية وجداول زمنية مخصصة

### تحسين النظام

**كفاءة الذاكرة**:
```python
class MemoryEfficientDiffusion:
    def __init__(self):
        self.gradient_checkpointing = True
        self.mixed_precision = True
        self.dynamic_batching = True

    def optimize_memory_usage(self, batch_size, sequence_length):
        # الضبط الديناميكي لاستخدام الذاكرة
        optimal_config = self.calculate_optimal_config(
            available_memory=torch.cuda.get_device_properties(0).total_memory,
            batch_size=batch_size,
            sequence_length=sequence_length
        )
        return optimal_config
```

## الخاتمة

حقق Mercury الابتكارات التالية من خلال النموذج الجديد لـ**نماذج اللغة القائمة على الانتشار**:

### الإنجازات الجوهرية

1. **ثورة السرعة**: سرعة استدلال تصل إلى 10 أضعاف النماذج الحالية
2. **الحفاظ على الجودة**: جودة توليد الكود مكافئة للنماذج التجارية
3. **العملية التطبيقية**: أداء موثّق في بيئات المطورين الفعلية
4. **قابلية التوسع**: إمكانات موثّقة للتوسع نحو نماذج أكبر

### الأثر على الصناعة

**الأثر الفوري**:
- تجربة مستخدم محوّلة لأدوات الإكمال التلقائي للكود
- نشر مساعد ترميز ذكاء اصطناعي فوري يصبح مجدياً
- تفعيل سير عمل التطوير القائمة على الوكلاء

**النظرة المستقبلية**:
- تحوّل جوهري في هيكل تكاليف استدلال الذكاء الاصطناعي
- ظهور أشكال جديدة من خدمات الذكاء الاصطناعي التفاعلية
- استخدام نماذج اللغة الكبيرة عالية الأداء في بيئات الحوسبة الطرفية

يتجاوز Mercury مجرد تحسين الأداء: إنه يُشير إلى **تحول نموذجي لنماذج اللغة في الذكاء الاصطناعي**. يُثبت هذا البحث أن النهج القائم على الانتشار يمكنه تقديم نتائج ثورية في توليد اللغة كما حقق في توليد الصور، مما يرسم مسار تطوير أنظمة ذكاء اصطناعي أسرع وأكثر كفاءة.

**الورقة البحثية الأصلية**: [Mercury: Ultra-Fast Language Models Based on Diffusion](https://arxiv.org/abs/2506.17298)
**واجهة برمجية وبيئة تجريبية**: [platform.inceptionlabs.ai](https://platform.inceptionlabs.ai) | [chat.inceptionlabs.ai](https://chat.inceptionlabs.ai)
