---
title: "udocker: دليل شامل لتشغيل حاويات Docker بدون صلاحيات الجذر"
excerpt: "تعلم كيفية تشغيل حاويات Docker بدون صلاحيات الجذر باستخدام udocker - مثالي لبيئات الحوسبة عالية الأداء والأنظمة المشتركة والتشغيل الآمن للحاويات."
seo_title: "دليل udocker: تشغيل حاويات Docker بدون صلاحيات الجذر - Thaki Cloud"
seo_description: "دليل شامل حول udocker لتشغيل حاويات Docker بدون صلاحيات الجذر. مثالي للحوسبة عالية الأداء وأنظمة المعالجة المجمعة والبيئات الآمنة."
date: 2025-10-11
categories:
  - tutorials
tags:
  - docker
  - containers
  - hpc
  - security
  - rootless
  - udocker
author_profile: true
toc: true
toc_label: "جدول المحتويات"
lang: ar
permalink: /ar/tutorials/udocker-rootless-container-execution-guide/
canonical_url: "https://thakicloud.github.io/ar/tutorials/udocker-rootless-container-execution-guide/"
---

⏱️ **وقت القراءة المقدر**: 12 دقيقة

## مقدمة

هل واجهت حاجة لتشغيل حاويات Docker على نظام لا تملك فيه صلاحيات الجذر؟ سواء كنت تعمل على مجموعة حوسبة عالية الأداء، أو بيئة حوسبة مشتركة، أو منظمة تهتم بالأمان، فإن **udocker** هو الحل المثالي لتشغيل حاويات Docker بدون الحاجة إلى وصول إداري.

udocker هو أداة أساسية للمستخدم تمكن من تشغيل حاويات Docker البسيطة في أنظمة المعالجة المجمعة أو التفاعلية بدون صلاحيات الجذر. تم تطويره من قبل مشروع INDIGO-DataCloud، ويوفر طريقة آمنة وعملية لتشغيل التطبيقات المحتواة في بيئات حيث Docker التقليدي غير متاح أو غير مسموح.

## ما هو udocker؟

udocker هو أداة مبنية على Python تسمح للمستخدمين بـ:
- تشغيل حاويات Docker بدون صلاحيات الجذر
- تحميل وإدارة صور Docker من السجلات
- تشغيل الحاويات في أوضاع تشغيل متنوعة (PRoot, Fakechroot, runC, crun, Singularity)
- توفير محاكاة الجذر للتطبيقات التي تتوقع التشغيل كجذر
- العمل في بيئات HPC وأنظمة المعالجة المجمعة والموارد الحاسوبية المشتركة

### الميزات الرئيسية

- **لا يتطلب صلاحيات الجذر**: يعمل بالكامل في مساحة المستخدم
- **محركات تشغيل متعددة**: يدعم PRoot, Fakechroot, runC, crun, و Singularity
- **توافق مع Docker**: يعمل مع صور وسجلات Docker القياسية
- **مركز على الأمان**: يوفر العزل دون المساس بأمان النظام
- **محسن للحوسبة عالية الأداء**: مصمم لبيئات الحوسبة عالية الأداء

## دليل التثبيت

### المتطلبات المسبقة

قبل تثبيت udocker، تأكد من وجود:
- Python 2.7 أو Python 3.x
- أدوات Linux الأساسية (tar, gzip, curl/wget)
- وصول إنترنت لتحميل الصور

### الطريقة 1: التحميل المباشر (موصى به)

```bash
# تحميل udocker
curl -L https://github.com/indigo-dc/udocker/releases/latest/download/udocker-1.3.17.tar.gz -o udocker.tar.gz

# استخراج وتثبيت
tar -xzf udocker.tar.gz
cd udocker-1.3.17

# جعل قابل للتنفيذ وإضافة إلى PATH
chmod +x udocker
export PATH=$PWD:$PATH

# التحقق من التثبيت
./udocker version
```

### الطريقة 2: استخدام pip

```bash
# التثبيت عبر pip
pip install udocker --user

# التحقق من التثبيت
udocker version
```

### الطريقة 3: من المصدر

```bash
# استنساخ المستودع
git clone https://github.com/indigo-dc/udocker.git
cd udocker

# تثبيت التبعيات
pip install -r requirements.txt --user

# جعل قابل للتنفيذ
chmod +x udocker

# إضافة إلى PATH
export PATH=$PWD:$PATH
```

## دليل الاستخدام الأساسي

### 1. الإعداد الأولي

عند تشغيل udocker لأول مرة، سيتم إنشاء دليل التكوين:

```bash
# تهيئة udocker
udocker install

# هذا ينشئ دليل ~/.udocker مع المكونات الضرورية
```

### 2. البحث عن الصور وسحبها

```bash
# البحث عن الصور
udocker search ubuntu

# سحب صورة من Docker Hub
udocker pull ubuntu:20.04

# قائمة الصور المحملة
udocker images
```

### 3. إنشاء وتشغيل الحاويات

```bash
# إنشاء حاوية من صورة
udocker create --name=my-ubuntu ubuntu:20.04

# قائمة الحاويات
udocker ps

# تشغيل أمر في الحاوية
udocker run my-ubuntu /bin/bash -c "echo 'مرحباً من udocker!'"

# جلسة تفاعلية
udocker run -it my-ubuntu /bin/bash
```

### 4. إدارة الحاويات

```bash
# قائمة جميع الحاويات
udocker ps -a

# حذف حاوية
udocker rm my-ubuntu

# حذف صورة
udocker rmi ubuntu:20.04
```

## التكوين المتقدم

### أوضاع التشغيل

udocker يدعم أوضاع تشغيل متعددة، كل منها له خصائص مختلفة:

#### وضع PRoot (افتراضي)
```bash
# تعيين وضع PRoot (P1 - مسرع، P2 - توافق)
udocker setup --execmode=P1 my-container
udocker setup --execmode=P2 my-container
```

#### وضع Fakechroot
```bash
# تعيين وضع Fakechroot (F1, F2, F3, F4)
udocker setup --execmode=F2 my-container
```

#### وضع runC/crun
```bash
# تعيين وضع runC (يتطلب مساحات أسماء المستخدم)
udocker setup --execmode=R1 my-container
udocker setup --execmode=R2 my-container  # crun
```

#### وضع Singularity
```bash
# تعيين وضع Singularity (يتطلب تثبيت Singularity)
udocker setup --execmode=S1 my-container
```

### تركيب الأحجام

```bash
# تركيب أدلة المضيف
udocker run -v /host/path:/container/path my-container

# تركيبات متعددة
udocker run -v /data:/data -v /home/user:/home/user my-container
```

### متغيرات البيئة

```bash
# تعيين متغيرات البيئة
udocker run -e VAR1=value1 -e VAR2=value2 my-container

# تمرير بيئة المضيف
udocker run --env-file=env.txt my-container
```

### تكوين الشبكة

```bash
# تفعيل وصول الشبكة (افتراضي في معظم الأوضاع)
udocker run --net=bridge my-container

# تعطيل الشبكة
udocker run --net=none my-container
```

## أمثلة عملية

### المثال 1: تشغيل تطبيق Python

```bash
# سحب صورة Python
udocker pull python:3.9-slim

# إنشاء حاوية
udocker create --name=python-app python:3.9-slim

# تركيب دليل الكود الخاص بك
udocker run -v $PWD:/app python-app python /app/my_script.py
```

### المثال 2: الحوسبة العلمية مع NumPy

```bash
# سحب صورة Python العلمية
udocker pull continuumio/anaconda3

# إنشاء حاوية
udocker create --name=science-env continuumio/anaconda3

# تشغيل دفتر Jupyter
udocker run -p 8888:8888 -v $PWD:/workspace science-env \
    jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root
```

### المثال 3: خط أنابيب المعلوماتية الحيوية

```bash
# سحب صورة المعلوماتية الحيوية
udocker pull biocontainers/blast:v2.2.31_cv2

# إنشاء حاوية
udocker create --name=blast-tool biocontainers/blast:v2.2.31_cv2

# تشغيل تحليل BLAST
udocker run -v /data:/data blast-tool \
    blastn -query /data/sequences.fasta -db /data/database -out /data/results.txt
```

### المثال 4: بيئة تطوير الويب

```bash
# سحب صورة Node.js
udocker pull node:16-alpine

# إنشاء حاوية
udocker create --name=node-dev node:16-alpine

# تشغيل خادم التطوير
udocker run -p 3000:3000 -v $PWD:/app node-dev \
    sh -c "cd /app && npm install && npm start"
```

## التكامل مع HPC وأنظمة المعالجة المجمعة

### تكامل SLURM

إنشاء نص مهمة SLURM لـ udocker:

```bash
#!/bin/bash
#SBATCH --job-name=udocker-job
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=01:00:00

# تحميل udocker
export PATH=/path/to/udocker:$PATH

# تشغيل التطبيق المحتوى
udocker run -v $PWD:/workspace my-container \
    python /workspace/compute_intensive_task.py
```

### تكامل PBS/Torque

```bash
#!/bin/bash
#PBS -N udocker-job
#PBS -l nodes=1:ppn=8
#PBS -l walltime=02:00:00

cd $PBS_O_WORKDIR

# تشغيل الحوسبة المتوازية
udocker run -v $PWD:/data my-container \
    mpirun -np 8 /usr/local/bin/my_parallel_app
```

## اعتبارات الأمان

### أفضل الممارسات

1. **ثقة محتوى الحاوية**: استخدم فقط صور الحاويات الموثوقة
2. **أذونات الملفات**: تأكد من الأذونات المناسبة للأدلة المركبة
3. **عزل الشبكة**: استخدم `--net=none` للحوسبات الحساسة
4. **حدود الموارد**: راقب استخدام الموارد في البيئات المشتركة

### ميزات الأمان

- **لا يتطلب صلاحيات الجذر**: udocker يعمل بالكامل في مساحة المستخدم
- **عزل نظام الملفات**: الحاويات معزولة عن نظام المضيف
- **دعم مساحة أسماء المستخدم**: عند استخدام أوضاع runC/crun
- **وصول محدود للنظام**: لا يمكن الوصول إلى الأجهزة أو المنافذ المحمية

## استكشاف الأخطاء وإصلاحها

### المشاكل الشائعة والحلول

#### 1. مشاكل وضع PRoot في النواة الحديثة

```bash
# إذا فشل وضع P1 في النواة الأحدث، استخدم P2
udocker setup --execmode=P2 my-container
```

#### 2. مشاكل مكتبة Fakechroot

```bash
# تثبيت مكتبات Fakechroot إضافية
udocker install

# فحص المكتبات المتاحة
ls ~/.udocker/lib/libfakechroot-*
```

#### 3. مشاكل مساحة أسماء المستخدم

```bash
# فحص تفعيل مساحات أسماء المستخدم
cat /proc/sys/user/max_user_namespaces

# إذا كان 0، مساحات أسماء المستخدم معطلة - استخدم أوضاع PRoot أو Fakechroot
```

#### 4. مشاكل اتصال الشبكة

```bash
# اختبار وصول الشبكة
udocker run my-container ping -c 3 google.com

# إذا فشل، فحص وضع التشغيل وتكوين شبكة المضيف
```

### تحسين الأداء

#### 1. اختيار وضع التشغيل المناسب

- **P1**: الأسرع، لكن قد يواجه مشاكل توافق
- **P2**: توافق جيد، أبطأ قليلاً
- **F2/F3**: جيد للتطبيقات كثيفة الإدخال/الإخراج
- **R1/R2**: أفضل عزل، يتطلب مساحات أسماء المستخدم

#### 2. تحسين تخزين الحاوية

```bash
# استخدام التخزين المحلي لأداء أفضل
export UDOCKER_DIR=/tmp/udocker-$USER

# تنظيف الحاويات والصور غير المستخدمة
udocker rm $(udocker ps -aq)
udocker rmi $(udocker images -q)
```

## حالات الاستخدام المتقدمة

### حوسبة GPU مع دعم NVIDIA

```bash
# إعداد دعم NVIDIA (يتطلب تعريفات NVIDIA للمضيف)
udocker setup --nvidia my-gpu-container

# تشغيل تطبيق مسرع بـ GPU
udocker run my-gpu-container nvidia-smi
```

### تدفقات عمل متعددة الحاويات

```bash
# إنشاء حاويات متعددة لخط أنابيب
udocker create --name=preprocess my-preprocessing-image
udocker create --name=compute my-computation-image
udocker create --name=postprocess my-postprocessing-image

# تشغيل خط الأنابيب
udocker run -v $PWD:/data preprocess /scripts/preprocess.sh
udocker run -v $PWD:/data compute /scripts/compute.sh
udocker run -v $PWD:/data postprocess /scripts/postprocess.sh
```

### تخصيص الحاوية

```bash
# تشغيل الحاوية وإجراء تغييرات
udocker run -it my-container /bin/bash

# داخل الحاوية: تثبيت البرامج، تعديل الملفات، إلخ
# الخروج من الحاوية

# إنشاء صورة جديدة من الحاوية المعدلة
udocker commit my-container my-custom-image
```

## مقارنة مع الأدوات الأخرى

| الميزة | udocker | Docker | Singularity | Podman |
|--------|---------|---------|-------------|---------|
| يتطلب صلاحيات الجذر | لا | نعم | لا | لا |
| متوافق مع OCI | نعم | نعم | نعم | نعم |
| محسن للحوسبة عالية الأداء | نعم | لا | نعم | لا |
| محركات متعددة | نعم | لا | لا | لا |
| مساحات أسماء المستخدم | اختياري | نعم | نعم | نعم |

## الخلاصة

udocker يوفر حلاً ممتازاً لتشغيل حاويات Docker في البيئات التي لا تتوفر فيها صلاحيات الجذر أو غير مرغوب فيها. أوضاع التشغيل المتعددة وميزات الأمان والتحسين للحوسبة عالية الأداء تجعله مثالياً لـ:

- الحوسبة الأكاديمية والبحثية
- بيئات الحوسبة المشتركة
- مجموعات الحوسبة عالية الأداء
- المنظمات التي تهتم بالأمان
- بيئات التطوير والاختبار

باتباع هذا الدليل، يجب أن تكون الآن قادراً على استخدام udocker بفعالية لتطبيقاتك المحتواة. مرونة الأداة وميزات الأمان تجعلها إضافة قيمة لأي تدفق عمل حاسوبي يتطلب الحاويات دون المساس بأمان النظام.

### الخطوات التالية

1. جرب أوضاع تشغيل مختلفة للعثور على أفضل أداء لحالة الاستخدام الخاصة بك
2. ادمج udocker في تدفقات عمل المهام المجمعة الموجودة
3. استكشف الميزات المتقدمة مثل دعم GPU وإنشاء الحاويات المخصصة
4. فكر في المساهمة في مشروع udocker على GitHub

لمزيد من المعلومات والتحديثات، قم بزيارة [وثائق udocker الرسمية](https://indigo-dc.github.io/udocker/) و [مستودع GitHub](https://github.com/indigo-dc/udocker).
