---
title: "vLLM + Prometheus + Kueue: تصميم عملي لمراقبة خدمة LLM على K8s"
excerpt: "كيف تبني منظومة رصد لخدمة LLM على Kubernetes متعددة المستأجرين تُغطي معدل استخدام GPU، ضغط KV cache، وإنتاجية الرموز."
seo_title: "دليل مراقبة خدمة LLM بـ vLLM Prometheus Kueue - Thaki Cloud"
seo_description: "تصميم منظومة مراقبة خدمة LLM على K8s بربط نقطة /metrics في vLLM مع DCGM Exporter ومقاييس Kueue. رصد معدل استخدام GPU وتكاليف الاستدلال في الوقت الفعلي."
date: 2026-06-20
last_modified_at: 2026-06-20
categories:
  - llmops
tags:
  - observability
  - prometheus
  - vllm
  - kueue
  - gpu-utilization
  - inference-cost
  - grafana
  - kubernetes
  - dcgm
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/ar/llmops/llm-inference-observability-prometheus-kueue/"
reading_time: true
lang: ar
---

⏱️ **وقت القراءة المقدر**: 10 دقائق

أكثر المشكلات حضوراً عند تشغيل كتل خدمة LLM هي أن GPU مكلف ولا توجد رؤية واضحة لمدى استخدامه الفعلي. تُشير الدراسات الصناعية إلى أن أكثر من 75% من المؤسسات تستخدم GPU بأقل من 70% حتى في أوقات الذروة، ولا تتجاوز نسبة 85% سوى 7% من المنظمات. رفع معدل الاستخدام 10% في كتلة تضم 100 وحدة GPU يعني توفيراً سنوياً بمئات الملايين من الوون.

المشكلة أن أساليب مراقبة خدمات REST الاعتيادية لا تنطبق مباشرةً على خدمة LLM. فهم خدمة LLM يستلزم مقاييس مختلفة: الرموز لا عدد طلبات HTTP، الدُفع المستمرة، استغلال KV cache، ومعدلات قبول المسودة.

## طبقات مراقبة خدمة LLM الثلاث

يبسّط تقسيم منظومة الرصد إلى ثلاث طبقات التصميم.

**الطبقة الأولى: مقاييس أجهزة GPU**
يجمع DCGM (Data Center GPU Manager) معدل استخدام GPU والذاكرة ودرجة الحرارة وعرض نطاق NVLink. نشر `dcgm-exporter` كـ DaemonSet يُتيح جمع مقاييس GPU لكل عقدة عبر Prometheus.

**الطبقة الثانية: مقاييس إطار التقديم**
مقاييس البادئة `vllm:` التي تكشفها vLLM عبر نقطة `/metrics` تقع هنا: عمق الطابور، معدل استخدام KV cache، عدد الرموز المولّدة، وزمن الاستجابة لكل طلب.

**الطبقة الثالثة: مقاييس جدولة أعباء العمل**
حالة أعباء العمل لكل طابور من Kueue، معدل استنفاد حصة الموارد، وأحداث الاستباق تُستخدم لتحليل العدالة في البيئات متعددة المستأجرين.

## مقاييس vLLM بالتفصيل: ما الذي يستحق المتابعة

المقاييس الرئيسية في vLLM v0.22:

```
# الإنتاجية وزمن الاستجابة
vllm:generation_tokens_total          # إجمالي الرموز المولّدة التراكمية
vllm:prompt_tokens_total              # إجمالي رموز الطلب التراكمية
vllm:e2e_request_latency_seconds      # توزيع زمن الاستجابة الكلي للطلب
vllm:time_to_first_token_seconds      # توزيع TTFT
vllm:time_per_output_token_seconds    # TPOT (مقلوب الإنتاجية)

# حالة النظام
vllm:num_requests_running             # الطلبات قيد التنفيذ حالياً
vllm:num_requests_waiting             # الطلبات في انتظار الطابور
vllm:gpu_cache_usage_perc             # معدل استخدام KV cache (0 إلى 1)
vllm:cpu_cache_usage_perc             # معدل استخدام ذاكرة التفريغ CPU

# الفك التخميني (عند التفعيل)
vllm:spec_decode_accepted_tokens_total
vllm:spec_decode_draft_tokens_total
```

`vllm:gpu_cache_usage_perc` بقيمة تتجاوز 0.9 يرفع خطر نفاد الذاكرة. الاستمرار في هذه المستويات العالية يستوجب زيادة تخصيص KV cache أو تقليص حد طول السياق أو إضافة GPU.

`vllm:num_requests_waiting` بقيمة أكبر من صفر باستمرار يعني أن الإنتاجية لا تواكب معدل الطلبات. يستلزم ضبط حجم الدفعة أو التوسع الأفقي للـ GPU.

## إعداد Prometheus الفعلي

إضافة تعليقات توضيحية لـ Pod الـ vLLM تُتيح لـ Prometheus Operator جمع المقاييس تلقائياً:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vllm-llama-70b
spec:
  template:
    metadata:
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8000"
        prometheus.io/path: "/metrics"
    spec:
      containers:
      - name: vllm
        image: vllm/vllm-openai:v0.22.0
        args:
        - "--model"
        - "meta-llama/Llama-3.1-70B-Instruct"
        - "--served-model-name"
        - "llama-70b"
        - "--host"
        - "0.0.0.0"
        - "--port"
        - "8000"
        ports:
        - containerPort: 8000
          name: http
```

إنشاء ServiceMonitor منفصل خيار بديل، لكن أسلوب التعليقات التوضيحية أريح عند إدارة نسخ نشر متعددة.

## نشر DCGM Exporter

```bash
helm repo add gpu-helm-charts https://nvidia.github.io/dcgm-exporter/helm-charts
helm install dcgm-exporter gpu-helm-charts/dcgm-exporter \
  --namespace monitoring \
  --set serviceMonitor.enabled=true \
  --set serviceMonitor.namespace=monitoring
```

أهم مقياسين من DCGM في سياق خدمة LLM:

```
DCGM_FI_DEV_GPU_UTIL     # معدل استخدام GPU الحسابي (%)
DCGM_FI_DEV_MEM_COPY_UTIL # معدل استخدام عرض نطاق ذاكرة GPU (%)
```

انخفاض القيمتين معاً يعني أن العملية تصطدم بعنق زجاجة في CPU أو لا توجد طلبات. ارتفاع `DCGM_FI_DEV_MEM_COPY_UTIL` مع انخفاض `DCGM_FI_DEV_GPU_UTIL` يُشير إلى حالة محدودية عرض نطاق الذاكرة وهو مؤشر على صغر النموذج أو الدفعة بشكل مفرط.

## دمج مقاييس Kueue

تكشف Kueue مقاييس Prometheus بشكل افتراضي:

```
kueue_pending_workloads           # أعباء العمل في انتظار الطابور (لكل ClusterQueue)
kueue_admitted_workloads_total    # إجمالي أعباء العمل المقبولة التراكمي
kueue_evicted_workloads_total     # إجمالي أعباء العمل المُستبقة التراكمي
kueue_quota_reserved_resources    # الموارد المحجوزة (عدد GPU إلخ)
```

في البيئات متعددة المستأجرين، تجميع `kueue_quota_reserved_resources` بتسمية `ClusterQueue` يُتيح استخراج استخدام GPU مفصّلاً لكل فريق لأغراض الفوترة.

## اللوحات الرئيسية في Grafana

لوحة خدمة LLM العملية لا تحتاج تعقيداً. أكثر اللوحات نفعاً:

**اللوحة الأولى: إنتاجية الرموز لكل طلب**
```
rate(vllm:generation_tokens_total[5m]) / rate(vllm:num_requests_running[5m])
```
الرموز المولّدة في الثانية لكل طلب. أساس فهم الإنتاجية المرجعية لتوليفة النموذج والأجهزة.

**اللوحة الثانية: تشبع KV cache**
```
max by (pod) (vllm:gpu_cache_usage_perc)
```
الحد الأقصى لمعدل استخدام KV cache لكل Pod. قيمة 0.85 فأكثر تُعدّ مستوى إنذار.

**اللوحة الثالثة: معدل استخدام GPU مقابل الطلبات المنتظرة**
رسم DCGM GPU utilization و`vllm:num_requests_waiting` على نفس الرسم البياني. GPU منخفض مع غياب الطلبات المنتظرة يعني طاقة فائضة. GPU مرتفع مع طلبات منتظرة كثيرة يُشير إلى ضرورة التوسع.

**اللوحة الرابعة: TTFT عند الشريحة المئوية 95 (Time to First Token)**
```
histogram_quantile(0.95, rate(vllm:time_to_first_token_seconds_bucket[5m]))
```
المؤشر الرئيسي لزمن الاستجابة المُدرك من المستخدم. الارتفاع المفاجئ في p95 يُشير في الغالب إلى تشبع KV cache أو ارتفاع حاد في الطلبات.

## تصميم إسناد التكاليف

إعداد LocalQueue في Kueue لكل مساحة أسماء (فريق) يُتيح إسناد وقت GPU على مستوى الفريق. استعلام PromQL التالي يحسب استخدام GPU في الساعة لكل فريق:

```promql
sum by (namespace) (
  kueue_quota_reserved_resources{resource="nvidia.com/gpu"}
) * on(namespace) group_left(team) kube_namespace_labels{label_team!=""}
```

ضرب هذا المقياس في سعر GPU لكل ساعة يُنتج تكلفة خدمة LLM لكل فريق. الرؤية المالية الناتجة تدفع الفرق بنفسها إلى تصحيح أنماط طلب النماذج الأكبر من اللازم أو الاحتفاظ بالموارد لفترات طويلة دون مبرر.

بناء منظومة الرصد شرط مسبق لتحسين خدمة LLM. بدون بيانات حول ما هو بطيء وأين تُهدر GPU لا يمكن تحديد اتجاه التحسين. توليفة مقاييس vLLM مع DCGM و Kueue هي أكثر المسارات واقعية للحصول على هذه البيانات على منصة LLM قائمة على K8s.
