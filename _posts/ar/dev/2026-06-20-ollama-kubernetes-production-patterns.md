---
title: "تشغيل Ollama على Kubernetes في بيئة الإنتاج"
excerpt: "أنماط عملية لرفع Ollama من أداة تجريب محلية إلى طبقة تقديم نماذج LLM على كتلة K8s."
seo_title: "أنماط نشر Ollama على Kubernetes في الإنتاج GPU PVC HPA - Thaki Cloud"
seo_description: "شرح إعداد عقد GPU عند نشر Ollama على Kubernetes، تصميم PVC لتخزين النماذج، التوسع التلقائي HPA، مراقبة Prometheus، وأنماط إعداد Modelfile."
date: 2026-06-20
last_modified_at: 2026-06-20
categories:
  - dev
tags: [ollama, kubernetes, llm-serving, gpu, self-hosting, modelfile, prometheus, hpa]
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/ar/dev/ollama-kubernetes-production-patterns/"
reading_time: true
lang: ar
---

⏱️ **وقت القراءة المقدر**: 9 دقائق

سجّلت Ollama 52 مليون تنزيل شهرياً في الربع الأول من 2026. تخطّى استخدامها حدود التجريب لتصبح بنية تحتية على مستوى الفريق في حالات كثيرة. التشغيل المحلي بأمر `ollama run` على Mac يختلف اختلافاً جوهرياً في التصميم عن تشغيلها طبقة تقديم للفريق بأكمله على كتلة Kubernetes. هذا المقال يتناول الحالة الثانية.

## لماذا Ollama: الفرق بينها وبين vLLM

تركز vLLM على تحسين الإنتاجية: PagedAttention، continuous batching، استدلال FP8 لأقصى استغلال لموارد GPU. في المقابل، تتميز Ollama بسهولة التثبيت وإدارة النماذج. أمر واحد `ollama pull llama3:70b` يُنزّل النموذج ويُشغّل خادم API متوافق مع OpenAI تلقائياً.

الأداتان ليستا متنافستين بل في طبقتين مختلفتين. نقاط الاستدلال العامة ذات الإنتاجية العالية تحتاج vLLM، بينما أدوات مساعدة الكود للفرق الداخلية أو روبوتات الدردشة الخاصة الصغيرة تستفيد من بساطة تشغيل Ollama.

## النشر الأساسي على Kubernetes

### مساحة الأسماء وRBAC

```bash
kubectl create namespace ollama
kubectl label namespace ollama kueue.x-k8s.io/team=internal-tools
```

### PersistentVolumeClaim للـ GPU

ملفات النماذج تتراوح بين عشرات وئات الجيجابايت. بدون PVC يُعاد تنزيل النموذج في كل إعادة تشغيل للـ Pod، وهو كارثة تشغيلية.

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ollama-models
  namespace: ollama
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: nfs-retain    # استخدام StorageClass المناسب للكتلة
  resources:
    requests:
      storage: 500Gi
```

إن احتاج عدة Pods مشاركة نفس وحدة تخزين النماذج، يلزم StorageClass يدعم `ReadWriteMany` كـ NFS أو CephFS أو Azure Files. مع `ReadWriteOnce` لا يمكن ربط الوحدة إلا بـ Pod واحد.

### Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ollama
  namespace: ollama
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ollama
  template:
    metadata:
      labels:
        app: ollama
    spec:
      tolerations:
      - key: nvidia.com/gpu
        operator: Equal
        value: present
        effect: NoSchedule
      containers:
      - name: ollama
        image: ollama/ollama:latest
        ports:
        - containerPort: 11434
        env:
        - name: OLLAMA_MODELS
          value: "/models"
        - name: OLLAMA_NUM_PARALLEL
          value: "4"         # عدد الطلبات المعالجة في آن واحد
        - name: OLLAMA_MAX_LOADED_MODELS
          value: "2"         # الحد الأقصى للنماذج في الذاكرة
        volumeMounts:
        - name: models
          mountPath: /models
        resources:
          limits:
            nvidia.com/gpu: "1"
            memory: "32Gi"
          requests:
            nvidia.com/gpu: "1"
            memory: "16Gi"
      volumes:
      - name: models
        persistentVolumeClaim:
          claimName: ollama-models
```

`OLLAMA_NUM_PARALLEL` يُحدد عدد الطلبات المعالجة في وقت واحد. ذاكرة GPU غير الكافية تحول دون المعالجة المتزامنة. إبقاء القيمة الافتراضية (1) يعني معالجة الطلبات بالتسلسل ويُطيل أوقات الاستجابة.

### Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: ollama
  namespace: ollama
spec:
  selector:
    app: ollama
  ports:
  - port: 11434
    targetPort: 11434
  type: ClusterIP
```

للوصول من خارج الكتلة أضف Ingress أو غيّر النوع إلى LoadBalancer. بما أن Ollama تفتقر إلى طبقة مصادقة، يجب وضع بروكسي مصادقة أمامها عند الكشف الخارجي.

## إعداد نماذج مخصصة بـ Modelfile

Modelfile في Ollama أداة لإنشاء نماذج مخصصة من نموذج أساسي بتثبيت system prompt وضبط المعاملات وطول السياق.

```dockerfile
FROM llama3:8b

SYSTEM """
أنت مساعد مراجعة الكود الداخلي لـ ThakiCloud.
متخصص في كود Go و Kubernetes YAML و Python.
تراجع بالترتيب: الثغرات الأمنية، مشاكل الأداء، أسلوب الكود.
"""

PARAMETER temperature 0.1      # temperature منخفض أفضل لمراجعة الكود
PARAMETER num_ctx 8192          # سياق كافٍ لمعالجة الملفات الطويلة
PARAMETER num_predict 2048
```

طريقتان لبناء Modelfile ونشره:

**الطريقة الأولى: تحميل مسبق للنموذج عبر InitContainer**

```yaml
initContainers:
- name: model-puller
  image: ollama/ollama:latest
  command:
  - sh
  - -c
  - |
    ollama serve &
    sleep 5
    ollama pull llama3:8b
    # تثبيت Modelfile من ConfigMap ثم البناء
    ollama create code-reviewer -f /modelfiles/Modelfile
    kill %1
  volumeMounts:
  - name: models
    mountPath: /models
  - name: modelfiles
    mountPath: /modelfiles
```

**الطريقة الثانية: تشغيل Job منفصل**

تشغيل Job منفصل لسحب النموذج وبناء Modelfile بعد تشغيل Pod. يكفي تشغيله مرة واحدة أثناء النشر الأولي.

## المخرجات المنظمة (Structured Output)

تتيح Ollama إجبار مخرجات JSON عبر معامل `format`:

```bash
curl http://ollama:11434/api/generate -d '{
  "model": "llama3:8b",
  "prompt": "ابحث عن ثغرات أمنية في الكود التالي وأعدها بصيغة JSON:",
  "format": "json",
  "stream": false
}'
```

يمكن أيضاً تثبيت تنسيق المخرجات عبر system prompt في Modelfile:

```dockerfile
SYSTEM """
أعد دائماً الردود بصيغة JSON التالية:
{"issues": [{"severity": "high|medium|low", "line": number, "description": string}]}
لا تُضمّن أي نص خارج هيكل JSON.
"""
```

في العمل الفعلي، قد لا يلتزم النموذج بالمخطط التام حتى مع تفعيل `format: "json"`، لذا تلزم طبقة تحقق من الـ schema بعد تحليل الاستجابة.

## مراقبة Prometheus

تكشف Ollama مقاييس Prometheus عبر نقطة `/metrics`:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: ollama
  namespace: ollama
spec:
  selector:
    matchLabels:
      app: ollama
  endpoints:
  - port: http
    path: /metrics
    interval: 30s
```

المقاييس الرئيسية:

```promql
# عدد الطلبات قيد المعالجة
ollama_request_duration_seconds_count

# متوسط وقت المعالجة
rate(ollama_request_duration_seconds_sum[5m])
/ rate(ollama_request_duration_seconds_count[5m])

# عدد النماذج المحملة
ollama_loaded_model_count
```

## التوسع التلقائي HPA

يعتمد HPA القائم على GPU على مقاييس معدل استخدام GPU. جمع معدل استخدام GPU عبر Prometheus من خلال DCGM Exporter من NVIDIA يُتيح استخدامه كمقياس مخصص في HPA.

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: ollama
  namespace: ollama
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ollama
  minReplicas: 1
  maxReplicas: 4
  metrics:
  - type: Pods
    pods:
      metric:
        name: ollama_queue_depth    # عدد الطلبات المنتظرة (مقياس مخصص)
      target:
        type: AverageValue
        averageValue: "10"
```

إن نقصت عقد GPU، يحاول HPA التوسع لكن Pod تبقى في حالة Pending. يلزم الجمع مع Cluster Autoscaler أو Karpenter للتوسع على مستوى العقدة.

## نمط بروكسي المصادقة

تفتقر Ollama إلى ميزة مصادقة ذاتية. حتى للخدمات الداخلية، الكشف بدون مصادقة يتيح للجميع استخدام النماذج. OAuth2 Proxy أو التحقق من مفتاح API عبر Nginx حل مناسب.

```yaml
# مثال على ConfigMap لـ Nginx
nginx.conf: |
  location / {
    if ($http_x_api_key != "your-team-key") {
      return 401;
    }
    proxy_pass http://ollama:11434;
  }
```

التكامل مع موفر هوية كـ Keycloak يُتيح إدارة صلاحيات الوصول على مستوى الفريق.

## نصائح تشغيلية

**جدولة تحديثات النماذج عبر Job منفصل.** يمكن تشغيل `ollama pull` مع Pod قيد التشغيل، لكن نقص المساحة أثناء التحديث قد يُعيد تشغيل الـ Pod. الجدولة عبر Job في وقت الصيانة أكثر أماناً.

**ضبط `OLLAMA_MAX_LOADED_MODELS` وفق ذاكرة GPU.** تحميل نموذجين بحجم 70B في وقت واحد يستنزف VRAM. احسب حجم النماذج مقارنةً بـ VRAM الفعلية وضع القيمة وفقاً لذلك.

**تقليل مستوى السجلات.** بالإعدادات الافتراضية تُسجّل Ollama تفاصيل لكل طلب. `OLLAMA_DEBUG=false` يُخفف سجلات الإنتاج.

## خلاصة

التشغيل السليم لـ Ollama على Kubernetes يتطلب أربعة عناصر: PVC للنماذج، toleration لـ GPU، بروكسي مصادقة، والمراقبة. Modelfile يُتيح إنشاء نماذج خاصة بالفريق مع إدارة إصدارات لـ system prompt والمعاملات. حيث تكون بساطة التشغيل أهم من الإنتاجية، Ollama خيار فعّال لتقديم الأدوات الداخلية بتكلفة إعداد معقولة.
