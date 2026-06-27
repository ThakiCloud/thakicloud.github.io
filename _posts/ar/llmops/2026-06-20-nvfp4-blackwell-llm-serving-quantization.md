---
title: "خفض تكاليف خدمة LLM إلى النصف على GPU Blackwell بـ NVFP4"
excerpt: "ما الذي يُقدمه NVFP4، صيغة الفاصلة العائمة الأصيلة رباعية البتات على NVIDIA Blackwell، مقارنةً بـ FP8 على H100، وكيفية تطبيقه فعلياً على منظومتي vLLM و TensorRT-LLM."
seo_title: "دليل تكميم LLM بـ NVFP4 على Blackwell لخدمة النماذج - Thaki Cloud"
seo_description: "استراتيجية عملية لرفع إنتاجية خدمة LLM وتقليص تكاليف ذاكرة GPU باستخدام NVFP4 على GPU NVIDIA Blackwell. يشمل طرق التطبيق على vLLM و TensorRT-LLM."
date: 2026-06-20
last_modified_at: 2026-06-20
categories:
  - llmops
tags:
  - nvfp4
  - quantization
  - blackwell
  - vllm
  - tensorrt-llm
  - gpu-memory
  - llm-serving
  - inference-cost
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/ar/llmops/nvfp4-blackwell-llm-serving-quantization/"
reading_time: true
lang: ar
---

⏱️ **وقت القراءة المقدر**: 8 دقائق

من أكثر الطرق مباشرةً لخفض تكاليف كتلة GPU استخراج إنتاجية أعلى من نفس الأجهزة. التكميم هو الأداة لذلك، وتوليفة GPU NVIDIA Blackwell مع NVFP4 باتت خياراً عملياً في منظومات خدمة LLM لعام 2026.

## خلفية الانتقال من FP8 إلى NVFP4

كان معيار التكميم في حقبة H100 (Hopper) هو FP8. حافظ على نطاق ديناميكي أوسع مقارنةً بـ INT8 مع رفع كثافة العمليات الحسابية، وأضافت معظم أطر التقديم دعم FP8 خلال 2024-2025.

على Blackwell خطت NVIDIA خطوة إضافية بإدخال NVFP4 كصيغة أصيلة للنواة الحسابية. NVFP4 فاصلة عائمة رباعية البتات بأس مشترك، تحافظ على دلالات الفاصلة العائمة خلافاً لـ INT4 البسيطة، مع تقليص حجم الذاكرة إلى نصف FP8.

وفقاً للبيانات المنشورة من Nota AI و Microsoft Azure AI Foundry، يبلغ أداء العمليات الكثيفة NVFP4 على GPU Blackwell (B200) خمسة أضعاف FP8: 10 PFLOPS كثيف NVFP4 مقابل 2 PFLOPS كثيف FP8. هذا الفارق ناجم عن إنتاجية العمليات الحسابية لا عرض نطاق الذاكرة.

## ما يعنيه NVFP4 فعلياً

الأرقام توضح الصورة بجلاء.

بأخذ Llama-3.1-70B مرجعاً: يحتاج BF16 نحو 140GB، وFP8 نحو 70GB، وNVFP4 نحو 35GB. حمل نموذج FP8 بحجم 70B على H100 ذي 80GB يترك مساحة شبه معدومة لـ KV cache. مع NVFP4 على نفس GPU يُحمَّل النموذج مع هامش كافٍ لـ KV cache، مما يُتيح معالجة سياقات أطول أو زيادة حجم الدفعة لرفع الإنتاجية.

NVFP4 حصري لـ Blackwell، أما H100/A100 فلا تزال FP8 الخيار الأمثل لها.

![مخطط بصمة ذاكرة Llama-3.1-70B حسب الدقة وتوجيه التكميم لكل تجمّع عُقد في Kueue](/assets/images/nvfp4-blackwell-llm-serving-quantization-diagram.svg)

## حالة دعم أطر العمل (يونيو 2026)

**TensorRT-LLM**: الدعم الأكثر نضجاً لـ NVFP4 على Blackwell. الإصدار 0.17 فأحدث يدعم NVFP4 أصلياً على B200 وغيرها من GPU Blackwell. موصى به لبيئات الإنتاج ذات الأولوية القصوى للإنتاجية.

**vLLM**: استقر دعم Blackwell عبر FP8، ودعم NVFP4 في طور التوسع. وصفة Blackwell لـ Llama 4 Scout منشورة في التوثيق الرسمي. مسار تنفيذ NVFP4 يجمع ModelOpt و FlashInfer.

**SGLang**: يُضاف دعم Blackwell لكن نضج NVFP4 يقل عن TensorRT-LLM.

## إعداد تكميم FP8 الفعلي في vLLM

للبيئات التي لا تمتلك Blackwell بعد، الانطلاق بـ FP8 على H100 هو الخطوة الأولى. إعداد FP8 في vLLM بسيط نسبياً:

```bash
# خدمة FP8 على H100
vllm serve meta-llama/Llama-3.1-70B-Instruct \
  --quantization fp8 \
  --kv-cache-dtype fp8 \
  --gpu-memory-utilization 0.90 \
  --max-model-len 32768
```

`--kv-cache-dtype fp8` يُخزّن KV cache بصيغة FP8 أيضاً لتحسين إضافي في كفاءة الذاكرة. بما أن KV cache يستنزف الذاكرة بسرعة في السياقات الطويلة، هذا الخيار يستحق التفعيل في أغلب الأحيان.

## تطبيق NVFP4 في بيئة Blackwell

في كتلة B200 أو GB200 باستخدام TensorRT-LLM، يجري تكميم النموذج أولاً بـ ModelOpt:

```bash
# تكميم NVFP4 بـ ModelOpt
python -m modelopt.torch.quantization.calib \
  --model meta-llama/Llama-3.1-70B-Instruct \
  --quantization nvfp4 \
  --calib-dataset cnn_dailymail \
  --output-dir ./llama-70b-nvfp4

# بناء محرك TensorRT-LLM
trtllm-build \
  --checkpoint-dir ./llama-70b-nvfp4 \
  --output-dir ./llama-70b-nvfp4-engine \
  --gemm-plugin nvfp4 \
  --max-batch-size 64 \
  --max-input-len 8192 \
  --max-output-len 2048
```

اختيار مجموعة بيانات المعايرة يؤثر على الجودة. كلما اقترب توزيع بيانات المعايرة من توزيع حركة التقديم الفعلية، قلّت الخسارة في الدقة.

## استراتيجية دمج منظومة خدمة K8s

في بيئات تُدار فيها أعباء GPU بـ ArgoCD و Kueue كما في ThakiCloud، ثمة اعتبارات عند تبني NVFP4:

**تفريع الإعدادات حسب نوع GPU**: فصل Kueue ClusterQueue إلى pool عقد Hopper وpool عقد Blackwell، مع إعدادات تكميم مختلفة لكل منهما. NVFP4 لنشر Blackwell، وFP8 لـ Hopper.

```yaml
# Helm values: تفريع الإعدادات حسب نوع GPU
serving:
  gpuType: "blackwell"  # or "hopper"
  quantization:
    blackwell: "nvfp4"
    hopper: "fp8"
  kvCacheDtype:
    blackwell: "fp8"   # KV cache يبقى FP8 (NVFP4 KV cache تجريبي بعد)
    hopper: "fp8"
```

**اختبار انحدار الدقة**: قبل استبدال النموذج بعد التكميم، تُجرى اختبارات انحدار الجودة. قياس فارق الدقة عن baseline BF16 باستخدام MMLU أو HumanEval أو معايير داخلية، وتحديد عتبة مقبولة (عادةً 0.5 إلى 1 نقطة مئوية) كبوابة في خط أنابيب نشر ArgoCD.

## حساب التكلفة: التوفير الفعلي

في كتلة 100 GPU، إن أتاح استبدال FP8 بـ NVFP4 مضاعفة السياق المعالَج أو خفض عدد GPU إلى النصف، يبلغ التوفير السنوي عشرات الآلاف من الدولارات بسعر 3 دولارات لكل GPU في الساعة. الوفورات الفعلية تتوقف على حجم النموذج وطول السياق وهيكل الدفعة.

إن بدأ الوصول إلى أجهزة Blackwell، لا يوجد مبرر لتأجيل تقييم الانتقال إلى NVFP4. مسار التطبيق عبر TensorRT-LLM الإصدار 0.17 فأعلى ناضج بما يكفي للإنتاج.

## المصادر

- [Introducing NVFP4 for Efficient and Accurate Low-Precision Inference (NVIDIA Technical Blog)](https://developer.nvidia.com/blog/introducing-nvfp4-for-efficient-and-accurate-low-precision-inference/)
- [NVIDIA TensorRT Model Optimizer (ModelOpt, GitHub)](https://github.com/NVIDIA/TensorRT-Model-Optimizer)
- [TensorRT-LLM - وثائق التكميم](https://nvidia.github.io/TensorRT-LLM/latest/features/quantization.html)
- [وثائق vLLM الرسمية](https://docs.vllm.ai/)
- [Kueue - طوابير مهام Kubernetes](https://kueue.sigs.k8s.io/)
