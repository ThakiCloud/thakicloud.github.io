---
title: "التشغيل الفعلي لـ Prefix Caching في vLLM: خفض تكاليف الاستدلال إلى النصف بإعادة استخدام KV Cache"
excerpt: "كيفية إعداد Automatic Prefix Caching في vLLM وقياس أثره في بيئة الإنتاج، مع التركيز على معدلات الإصابة الفعلية وأرقام توفير التكاليف."
seo_title: "دليل vLLM Prefix Caching KV Cache إعادة الاستخدام في الإنتاج - Thaki Cloud"
seo_description: "طريقة تفعيل Automatic Prefix Caching في vLLM، مبدأ تجزئة كتل KV في PagedAttention، شروط تحقيق معدل إصابة 60-85%، وأنماط التطبيق الفعلي في بيئات SaaS متعددة المستأجرين."
date: 2026-06-20
last_modified_at: 2026-06-20
categories:
  - dev
tags: [vllm, prefix-caching, kv-cache, llm-serving, gpu, inference, kubernetes, pagedattention]
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/ar/dev/vllm-prefix-caching-kv-reuse-production/"
reading_time: true
lang: ar
---

⏱️ **وقت القراءة المقدر**: 7 دقائق

إن أيسر تحسين يمكن الاستفادة منه في تكاليف استدلال النماذج اللغوية الكبيرة هو Prefix Caching. حين يتكرر system prompt أو سياق طويل مع كل طلب، يكفي إعادة استخدام KV Cache بدلاً من إعادة حسابه لتخفيض وقت GPU إلى أقل من النصف. تُضمّن vLLM هذه الميزة باسم Automatic Prefix Caching (APC).

## لماذا يُحقق Prefix Caching هذه الفاعلية

ينقسم استدلال النماذج اللغوية الكبيرة إلى مرحلتين رئيسيتين: prefill (معالجة المدخلات) و decode (توليد الرموز). يعمل Prefix Caching على مرحلة prefill وحدها. حين يتشارك طلبان نفس الجزء الأمامي (prefix)، يُجلب حالة KV (Key-Value) لذلك الجزء من الذاكرة المؤقتة بدلاً من إعادة حسابها.

تتضح الأهمية عند النظر في الأرقام الفعلية: تُفيد التقارير بتوفير 85-95% من التكلفة عند الإصابة بالذاكرة المؤقتة، فيما يُعدّ معدل إصابة 60-85% قابلاً للتحقيق في حلقات الوكلاء وبيئات SaaS متعددة المستأجرين. ولا توجد أي عقوبة عند الإخفاق، مما يجعل التفعيل الدائم استراتيجيةً مثلى.

غير أن Prefix Caching لا يؤثر على سرعة الـ decode. يتحسن "وقت الرمز الأول (TTFT)" لكن "عدد الرموز في الدقيقة (TPS)" يبقى كما هو؛ والخلط بين هذين الأمرين يفضي إلى توقعات خاطئة.

## مبدأ تجزئة كتل KV في vLLM

تدير vLLM الـ KV Cache في كتل ذات حجم ثابت استناداً إلى PagedAttention. يُعرّف Automatic Prefix Caching كل كتلة بتجزئة تشمل رموزها ورموز جميع الرموز السابقة لها في التسلسل.

```
hash_الكتلة = hash(hash_الكتل_السابقة || معرّفات_رموز_الكتلة_الحالية)
```

هذا يتيح التحقق بتعقيد O(1) من أي كتلة يمكن إعادة استخدامها بين طلبين يتشاركان نفس البادئة. عند وصول طلب جديد، تبحث vLLM في جدول الكتل عن تجزئات متطابقة وتعيد استخدامها، ثم تبدأ الـ prefill من أول كتلة غير متطابقة.

اعتباراً من عام 2026، أصبح PagedAttention معياراً فعلياً في منصات الاستدلال الإنتاجية، إذ تعتمده vLLM و SGLang و TensorRT-LLM بشكل افتراضي، مما أدى إلى تقليص هدر KV Cache إلى أقل من 4%، وهو مصدر تحسن الإنتاجية بمقدار 2 إلى 4 أضعاف.

## طريقة التفعيل

يكفي إضافة العلامة `--enable-prefix-caching` عند تشغيل خادم vLLM.

```bash
python -m vllm.entrypoints.openai.api_server \
  --model meta-llama/Llama-3-70b-instruct \
  --enable-prefix-caching \
  --max-model-len 32768 \
  --gpu-memory-utilization 0.90
```

في بيئة Kubernetes، تُضاف إلى قسم args في الـ Deployment:

```yaml
containers:
- name: vllm
  image: vllm/vllm-openai:latest
  args:
  - "--model"
  - "meta-llama/Llama-3-70b-instruct"
  - "--enable-prefix-caching"
  - "--max-model-len"
  - "32768"
  resources:
    limits:
      nvidia.com/gpu: "1"
```

## أنماط عملية لرفع معدل الإصابة

### تثبيت system prompt في المقدمة

معدل الإصابة يتناسب طرداً مع طول البادئة واستقرارها. حين يُلحق system prompt متطابق في بداية كل طلب، يُحسب KV Cache لذلك الجزء مرة واحدة فقط. كلما طال system prompt وقلّت تغييراته، زاد حجم التوفير.

```python
messages = [
    {"role": "system", "content": SYSTEM_PROMPT},  # ثابت دائماً
    {"role": "user", "content": user_query},         # يتغير مع كل طلب
]
```

### تراكم السياق في حلقات الوكلاء

تحافظ الوكلاء متعددة الخطوات على بادئة طويلة بتراكم سجل المحادثة. ابتداءً من الخطوة الثانية، يُعاد استخدام KV الخاص بالخطوة الأولى من الذاكرة المؤقتة.

### وضع وثائق RAG في المقدمة

في نماذج Retrieval-Augmented Generation، يُحقق وضع نتائج البحث في المقدمة والسؤال في الذيل إصابات في الذاكرة المؤقتة بين الطلبات التي تستشهد بنفس مجموعة الوثائق. معدل إصابة 60-80% رقم واقعي في أنماط كمراجعة قواعد الكود وتحليل الوثائق الطويلة.

## رصد معدل الإصابة

تكشف vLLM معدل إصابة الذاكرة المؤقتة عبر مقاييس Prometheus:

```promql
# معدل إصابة الذاكرة المؤقتة
rate(vllm:cache_hit_tokens_total[5m]) 
/ rate(vllm:prompt_tokens_total[5m])
```

ما يجب التحقق منه أولاً حين يكون معدل الإصابة منخفضاً:

- هل يحتوي system prompt على سلاسل نصية تتغير بين الطلبات (طوابع زمنية، معرّفات جلسات)?
- هل تُخلى الذاكرة المؤقتة بشكل متكرر بسبب نقص ذاكرة GPU?
- هل يتوافق حجم الكتلة مع طول البادئة?

## مقارنة مع LMCache

وفقاً لمعيار قياسي نشر مؤخراً قارن بين vLLM Prefix Caching و LMCache ([Level Up Coding، أبريل 2026](https://levelup.gitconnected.com/vllm-prefix-caching-vs-lmcache-benchmarking-kv-reuse-tradeoffs-944fbaf98b56))، فإن Automatic Prefix Caching المدمج في vLLM يُظهر أداءً كافياً على العقدة المفردة. أما حين يستلزم الأمر تقديم خدمة موزعة على عقد متعددة، فيُنظر في طبقة KV موزعة منفصلة كـ LMCache أو llm-d. على نطاق ThakiCloud، البداية بـ APC المدمج ثم إضافة التخزين الموزع عند توسع عقد التقديم هو المسار العملي.

## نقاط ينبغي الانتباه إليها

في البيئات متعددة المستأجرين، قد تُشكّل مشاركة KV Cache بين مستأجرين مختلفين مساراً محتملاً لتسرب المعلومات. تشارك vLLM الذاكرة المؤقتة بين المستأجرين بشكل افتراضي متى تطابقت رموز البادئة دون تمييز. التمايز الطبيعي يحدث حين يختلف system prompt بين المستأجرين، لكن بنية تستخدم system prompt مشتركاً وتُدرج بيانات المستأجرين في السياق تستوجب تصميماً مدروساً.

تفعيل `--enable-chunked-prefill` بالتزامن مع Prefix Caching يرفع الإنتاجية أكثر، إذ تتكامل الميزتان جيداً.

## خلاصة

vLLM Prefix Caching تحسين مجاني يُفعَّل بعلامة واحدة. في أعباء العمل التي تتجاوز نسبة إصابتها 60%، يمكن تخفيض تكاليف GPU إلى أقل من النصف. الأنماط الثلاثة لرفع معدل الإصابة هي: تثبيت system prompt، تراكم السياق في حلقات الوكلاء، ووضع وثائق RAG في المقدمة. لا يوجد مبرر لإبقائها معطلة.
