---
title: "التحكم في استباق أعباء GPU مع Kueue: تصميم ClusterQueue وأنماط الأولوية"
excerpt: "شرح آليات الاستباق (Preemption) في Kueue ومبادئ تصميم ClusterQueue من منظور تشغيل منصات AI/ML الفعلية."
seo_title: "أنماط جدولة GPU باستباق Kueue وتصميم ClusterQueue - Thaki Cloud"
seo_description: "شرح تصميم ClusterQueue في Kueue، أولويات أعباء العمل، سياسات استباق GPU، quota borrowing، وأنماط النشر متعدد الكتل مع MultiKueue بأمثلة تطبيقية."
date: 2026-06-20
last_modified_at: 2026-06-20
categories:
  - dev
tags: [kueue, kubernetes, gpu-scheduling, preemption, clusterqueue, ai-platform, kueue-v1beta1, mlops]
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/ar/dev/kueue-gpu-scheduling-preemption-patterns/"
reading_time: true
lang: ar
---

⏱️ **وقت القراءة المقدر**: 8 دقائق

حين تتشارك فرق متعددة كتلة GPU واحدة، تبرز مشكلتان شائعتان: الأولى أنه لا توجد طريقة لمهمة عالية الأولوية لاسترداد وحدات GPU محتلة من مهمة ذات أولوية أدنى، والثانية أن وحدات GPU تبقى خاملة حين لا تُشغّل إحدى الفرق. تعالج Kueue هاتين المشكلتين عبر الاستباق (Preemption) واستعارة الحصص (Quota Borrowing).

## الفرق بين Kueue وجدول Kubernetes الافتراضي

لا يتدخل جدول Kubernetes الافتراضي في Pod بمجرد انتقاله إلى حالة Running. يمكن استخدام PriorityClass لترتيب Pods المعلقة، لكن لا توجد آلية لإزاحة Job ذي أولوية أدنى أثناء تنفيذه.

تضيف Kueue طبقة تجريد تُسمى Workload فوق الـ Pod. تعمل دور مدير طابور أعباء العمل لا جدولاً. يُحدد ClusterQueue الحصص، وتقرر Kueue أي Workload تقبل ومتى، وهل تُوقف Workload آخر.

```
وصول الطلب -> LocalQueue -> ClusterQueue -> قبول أو انتظار
                                              |
                                         تجاوز الحصة
                                         البحث عن هدف للاستباق
                                         -> استباق ذي الأولوية الأدنى
```

## أساسيات تصميم ClusterQueue

ClusterQueue كيان يُحدد الحصص على مستوى الفريق أو المشروع، ويُخصص GPU و CPU والذاكرة لكل نكهة من نكهات الموارد.

```yaml
apiVersion: kueue.x-k8s.io/v1beta1
kind: ClusterQueue
metadata:
  name: inference-team
spec:
  namespaceSelector:
    matchLabels:
      kueue.x-k8s.io/team: inference
  resourceGroups:
  - coveredResources: ["cpu", "memory", "nvidia.com/gpu"]
    flavors:
    - name: h100-flavor
      resources:
      - name: nvidia.com/gpu
        nominalQuota: "8"
        borrowingLimit: "4"    # يمكن استعارة 4 وحدات كحد أقصى من حصة فريق آخر
      - name: cpu
        nominalQuota: "64"
      - name: memory
        nominalQuota: "256Gi"
  preemption:
    reclaimWithinCohort: LowerPriority   # استباق الأولوية الأدنى عند استرداد الحصة المستعارة
    borrowWithinCohort:
      policy: LowerPriority
      maxPriorityThreshold: 100
    withinClusterQueue: LowerPriority    # استباق الأولوية الأدنى داخل نفس الطابور
```

Cohort هو مجموعة من ClusterQueues تتشارك الحصص. الطوابير المضمومة إلى نفس Cohort يمكنها استعارة الحصص من بعضها.

## أنماط تصميم الأولوية

الطبقات العملية للأولوية في كتلة GPU عادةً ثلاث:

### الطبقة الأولى: استدلال الإنتاج (أعلى أولوية)

نقاط خدمة التقديم يعني توقفها عطلاً مباشراً. تحتاج سياسة `PreemptLowerPriority` وقدرة استرداد Pods التدريب ذات الأولوية الأدنى فوراً عند ارتفاع حركة المرور.

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: inference-prod
value: 1000
preemptionPolicy: PreemptLowerPriority
globalDefault: false
```

### الطبقة الثانية: التجارب التفاعلية (أولوية متوسطة)

أعباء عمل الباحثين كجلسات Jupyter والتجارب القصيرة. أهمية وقت الاستجابة أعلى من التدريب لكنها تظل أدنى من التقديم.

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: interactive-experiment
value: 500
preemptionPolicy: PreemptLowerPriority
```

### الطبقة الثالثة: التدريب الدُفعي (أولوية منخفضة)

مهام التدريب الطويلة هي أول أهداف الاستباق. تقصير فترة حفظ نقاط التفتيش يُقلص الخسائر الناجمة عن الاستباق.

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: batch-training
value: 100
preemptionPolicy: Never    # هذا المستوى لا يستبق غيره
```

## الاستخدام الفعلي لاستعارة الحصص

الاستعارة آلية لتأمين سعة اندفاع دون هدر الحصص. إن كان inference-team يمتلك 8 وحدات GPU ويستخدم 4 فقط، يمكن لـ training-team استعارة الأربعة الأخرى.

```yaml
# training-team ClusterQueue
spec:
  resourceGroups:
  - flavors:
    - name: h100-flavor
      resources:
      - name: nvidia.com/gpu
        nominalQuota: "4"
        borrowingLimit: "8"   # الاستعارة حتى 8 وحدات (nominalQuota + مستعار = 12 كحد أقصى)
  cohort: shared-gpu-pool    # نفس Cohort مع inference-team
```

حين يُقدم inference-team مهمة جديدة، تسترد Kueue وحدات GPU المستعارة من training-team. بسياسة `reclaimWithinCohort: LowerPriority` يبدأ الاستباق من المهام ذات الأولوية الأدنى.

يجب الانتباه إلى التفاعل مع PodDisruptionBudget الذي قد يُفضي إلى سلوك غير متوقع. وينبغي أيضاً مراعاة وقت الإنهاء (terminationGracePeriodSeconds)؛ إن كان أقصر من الوقت اللازم لحفظ نقطة التفتيش فقد تضيع.

## حماية عقد GPU

منع جدولة أعباء CPU على عقد GPU عبر إضافة taint للعقد وتطبيق toleration على أعباء GPU فقط:

```bash
# إضافة taint لعقدة GPU
kubectl taint nodes <gpu-node> nvidia.com/gpu=present:NoSchedule
```

```yaml
# toleration في Kueue Workload
spec:
  podSets:
  - name: main
    template:
      spec:
        tolerations:
        - key: nvidia.com/gpu
          operator: Equal
          value: present
          effect: NoSchedule
```

بدون هذا التركيب يحتل عفاريت DaemonSet كمجمّعات السجلات والوكلاء والمراقبة موارد عقدة GPU.

## MultiKueue: توزيع المهام على كتل متعددة

MultiKueue، المدرجة كميزة رئيسية في خارطة طريق Kueue لعام 2026، متاحة حالياً في حالة بيتا وهي مُفعَّلة بشكل افتراضي. تتلقى كتلة الإدارة (manager) المهام وتوزعها على كتل العمال.

```
[manager cluster]
  MultiKueue ClusterQueue
       |
  -----+-----
  |         |
[worker-1] [worker-2]
(A100 x 8) (H100 x 4)
```

لتسجيل كتلة عامل:

```yaml
apiVersion: kueue.x-k8s.io/v1beta1
kind: MultiKueueCluster
metadata:
  name: worker-cluster-a100
spec:
  kubeConfig:
    locationType: Secret
    location: worker-a100-kubeconfig
```

يمكن تخصيص خوارزمية التوزيع عبر MultiKueue Dispatcher بإضافة موزع مخصص كمكوّن إضافي.

## الاستباق التعاوني (Cooperative Preemption) ونقاط التفتيش

الاستباق التعاوني ميزة لافتة في خارطة طريق Kueue لعام 2026. أعباء العمل التي تُنفذ نقاط التفتيش لن تنتهي فوراً عند تلقي إشارة الاستباق، بل ستحفظ حالتها أولاً.

في المرحلة الحالية، يُحقق تمديد `terminationGracePeriodSeconds` بما يكفي وإضافة معالج SIGTERM في كود التدريب لحفظ نقطة التفتيش تأثيراً مشابهاً.

```python
import signal
import sys

def checkpoint_and_exit(signum, frame):
    save_checkpoint(model, optimizer, current_epoch)
    sys.exit(0)

signal.signal(signal.SIGTERM, checkpoint_and_exit)
```

عند توفر الدعم الرسمي للاستباق التعاوني، ستتحقق Kueue من اكتمال نقطة التفتيش قبل قبول عبء العمل الجديد.

## الأخطاء الشائعة في العمل الفعلي

**الخطأ الأول: عدم التحقق من سياسة الاستباق قبل الطرح في الإنتاج.** يجب تشغيل سيناريو استباق فعلي على الكتلة التطويرية والتأكد من أن التفاعل بين PDB ووقت الإنهاء ووقت حفظ نقطة التفتيش يعمل كما هو متوقع.

**الخطأ الثاني: إعداد borrowingLimit بدون Cohort.** ClusterQueue الغير منضمة إلى Cohort لا تجد من تستعير منه حتى لو أُعدّ borrowingLimit.

**الخطأ الثالث: الخلط بين LocalQueue و ClusterQueue.** LocalQueue محدود النطاق بمساحة الأسماء، ClusterQueue محدود بالكتلة. عزل الفريق على مستوى مساحة الأسماء يُنفَّذ بالجمع بين LocalQueue وnamespaceSelector.

## خلاصة

Kueue من أندر الأدوات الجاهزة للإنتاج لإدارة حصص GPU على Kubernetes. تمكّن مجموعة ClusterQueue-Cohort-Preemption من التعبير برمجياً عن توزيع GPU العادل بين الفرق. يجب التحقق من سياسات الاستباق بأعباء عمل فعلية، وملاءمة وقت حفظ نقطة التفتيش مع terminationGracePeriodSeconds لضمان استباق بلا خسائر.
