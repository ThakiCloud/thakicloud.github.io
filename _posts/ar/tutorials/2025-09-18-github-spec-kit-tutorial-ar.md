---
title: "دليل GitHub Spec Kit: من المواصفة إلى الخطة والتنفيذ"
excerpt: "دليل عملي خطوة بخطوة لتطوير قائم على المواصفات باستخدام Spec Kit: إنشاء مواصفة أولية، تحسينها، إنشاء خطة تقنية، التحقق، ثم الاستعداد للتنفيذ على macOS."
seo_title: "دليل Spec Kit للتطوير القائم على المواصفات - Thaki Cloud"
seo_description: "شرح عملي لاستخدام Spec Kit لإنشاء المواصفات، تكرار التحسين، توليد خطة تقنية، التحقق بالقوائم المرجعية، والتحضير للتنفيذ. يتضمن سكربتات macOS ونصائح حل المشكلات."
date: 2025-09-18
categories:
  - tutorials
tags:
  - spec-kit
  - spec-driven-development
  - github
  - planning
  - automation
author_profile: true
toc: true
toc_label: "جدول المحتويات"
lang: ar
permalink: /ar/tutorials/github-spec-kit-tutorial/
canonical_url: "https://thakicloud.github.io/ar/tutorials/github-spec-kit-tutorial/"
---

⏱️ الوقت المتوقع للقراءة: 12 دقيقة

### لماذا هذا الدليل؟
يساعد التطوير القائم على المواصفات الفرق على التركيز أولًا على سيناريوهات المنتج، ثم دفع التنفيذ انطلاقًا من تلك المواصفات. يوفر GitHub Spec Kit قوالبًا ونصوصًا وقوائم تحقق لتسريع هذه العملية. سيرشدك هذا الدليل عبر إنشاء مواصفة أولية، تحسينها، إنشاء خطة تقنية، التحقق منها، ثم التحضير للتنفيذ على macOS.

مرجع: [مستودع GitHub Spec Kit](https://github.com/github/spec-kit) [استشهاد: `http://github.com/github/spec-kit`]

---

## 1) المتطلبات المسبقة
- macOS 13+ (Apple Silicon أو Intel)
- Git 2.40+
- Node.js 18+ أو 20+ (اختياري)
- Python 3.10+ (يستخدمه المستودع، لكنه ليس إلزاميًا لاستهلاك القوالب)
- حساب GitHub ومفاتيح SSH (مستحسن)

فحوصات سريعة:
```bash
git --version
python3 --version
node -v  # اختياري
```

---

## 2) جلب قوالب Spec Kit محليًا
يمكنك استهلاك القوالب مباشرةً أو عمل fork/clone للتكرار بسرعة.
```bash
git clone https://github.com/github/spec-kit.git
cd spec-kit
ls -la templates/
ls -la docs/
```

---

## 3) إنشاء مساحة عمل للميزة
سننشئ مجلدًا محليًا يتماشى مع البنية الموصى بها.
```bash
FEATURE_SLUG=taskify
mkdir -p features/${FEATURE_SLUG}
cd features/${FEATURE_SLUG}
cp ../../spec-kit/templates/spec-template.md ./spec.md
cp ../../spec-kit/templates/plan-template.md ./plan.md
cp ../../spec-kit/templates/tasks-template.md ./tasks.md
```

البنية:
```bash
.
├── plan.md
├── spec.md
└── tasks.md
```

---

## 4) الخطوة 1 — توليد المواصفة الأولية
املأ `spec.md` بسيناريوهات المنتج وقصص المستخدم ومعايير القبول. ابدأ بوثيقة موجزة بأسلوب PRD.

موجه مقترح للمساعد:
```text
اكتب مواصفة أولية لميزة تطبيق صغير اسمه Taskify.
تضمّن الأهداف واللا أهداف، الشخصيات الأساسية، رحلات المستخدم، ومعايير القبول.
أضف قائمة "المراجعة والقبول" في النهاية بعناصر قابلة للتحقق.
احصر النطاق في حجم إصدار واحد.
```

عناصر الجودة:
- أهداف/لا أهداف واضحة
- رحلات مستخدم قليلة وعالية الصلة
- معايير قبول قابلة للاختبار
- قائمة مراجعة موضوعية

---

## 5) الخطوة 2 — تحسين المواصفة الوظيفية
اقرأ `spec.md` وحدّد الغامض وضيّق الحدود.
- أمثلة: 5–15 مهمة لكل مشروع تجريبي، مع وجود حالة واحدة على الأقل لكل حالة تقدم
- عرّف حالات الخطأ وحالات الفراغ
- ضع مقاييس وأهدافًا غير وظيفية واضحة

موجه مفيد:
```text
اقرأ قائمة المراجعة والقبول في spec.md، وضع علامة على البنود المستوفاة.
اترك ما لا يستوفي بدون علامة واشرح السبب في جملة واحدة لكل بند.
```

---

## 6) الخطوة 3 — إنشاء الخطة التقنية
أنشئ وكرر على `plan.md` حسب التقنية المختارة. مثال:
```text
سنستخدم .NET Aspire وPostgres. الواجهة: Blazor Server مع لوحات سحب وإفلات لحظية.
واجهات REST: Projects، Tasks، Notifications. أنشئ data-model.md وcontracts وquickstart.md.
```

اربط المهام بالتفاصيل ونسّقها على خطوات قابلة للتنفيذ.

---

## 7) الخطوة 4 — التحقق من الخطة
قبل التنفيذ، راجع:
- هل المهام الأساسية مرتبة وتشير إلى المواصفات/العقود؟
- هل المجهولات موثقة كمهام بحث؟
- هل المتطلبات غير الوظيفية قابلة للاختبار؟

موجه مفيد:
```text
دقق plan.md والوثائق المرتبطة بحثًا عن الفجوات. أنشئ تسلسلًا مرقمًا
للمهام مع المراجع. حدّد الأجزاء المفرطة الهندسة واقترح تبسيطات.
```

---

## 8) الخطوة 5 — التحضير للتنفيذ
- أنشئ فرع ميزة وافتح Pull Request كمسودة إلى main
- جهّز سكربتات الإنشاء (مجلدات، عقود وملفات بيانات أولية)
- ادفع مخرجات "قابلة للمراجعة مبكرًا"

سكربت بسيط مثالًا:
```bash
#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT=$(pwd)
mkdir -p src/api src/web docs contracts

echo "{}" > contracts/api-spec.json
cat > docs/quickstart.md <<'MD'
# Quickstart
1. تثبيت الاعتمادات
2. تشغيل الـ API والويب
3. افتح http://localhost:3000
MD

echo "Scaffold complete at ${PROJECT_ROOT}"
```

---

## 9) سكربت اختبار على macOS
يتحقق من البيئة والقوالب ويجهز مساحة الميزة. آمن للتكرار.
```bash
#!/usr/bin/env bash
# file: scripts/spec-kit-smoke-test.sh
set -euo pipefail

command -v git >/dev/null || { echo "git missing"; exit 1; }
command -v python3 >/dev/null || { echo "python3 missing"; exit 1; }

if [ ! -d "spec-kit/templates" ]; then
  echo "Spec Kit templates not found. Cloning..."
  rm -rf spec-kit
  git clone https://github.com/github/spec-kit.git
fi

FEATURE=${1:-taskify}
mkdir -p features/${FEATURE}
cp -f spec-kit/templates/spec-template.md features/${FEATURE}/spec.md
cp -f spec-kit/templates/plan-template.md features/${FEATURE}/plan.md
cp -f spec-kit/templates/tasks-template.md features/${FEATURE}/tasks.md

ls -la features/${FEATURE}
echo "OK: feature workspace ready"
```

مخرجات متوقعة (مختصرة):
```text
cloning into 'spec-kit'...
spec-template.md  plan-template.md  tasks-template.md
OK: feature workspace ready
```

---

## 10) ملاحظات استكشاف الأخطاء
من إرشادات المستودع:
- لا تتعامل مع المحاولة الأولى كمستند نهائي؛ كرّر التحسين.
- تحقّق من قائمة المراجعة والقبول قبل الانتقال.
- تجنّب الإفراط في الهندسة وفضّل البساطة.

في حال مشاكل اعتماد Git على Linux، راجع سكربت تثبيت Git Credential Manager المذكور في README. المصدر: [Spec Kit README](https://github.com/github/spec-kit) [استشهاد: `http://github.com/github/spec-kit`]

---

## 11) الخطوات التالية
- وسّع `tasks.md` إلى عناصر عمل دقيقة وقابلة للمراجعة
- افتح PR مسودة مبكرًا وأرفق المواصفات بنفس الفرع
- حدّث المواصفات باستمرار كلما ظهرت تفاصيل أثناء التنفيذ

---

## المراجع
- مستودع Spec Kit: [github/spec-kit](https://github.com/github/spec-kit) [استشهاد: `http://github.com/github/spec-kit`]
