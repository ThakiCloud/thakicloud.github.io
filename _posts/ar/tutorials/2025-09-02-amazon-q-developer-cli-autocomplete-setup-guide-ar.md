---
title: "Amazon Q Developer CLI: دليل شامل لإعداد واستخدام الإكمال التلقائي في Terminal"
excerpt: "تعلم كيفية تثبيت وإعداد Amazon Q Developer CLI (المعروف سابقاً باسم Fig) للحصول على إكمال تلقائي ذكي مع مئات أدوات CLI بما في ذلك git و npm و docker و aws."
seo_title: "دليل إعداد Amazon Q Developer CLI - تعليمي للإكمال التلقائي في Terminal"
seo_description: "دليل شامل لتثبيت Amazon Q Developer CLI للإكمال التلقائي الذكي في Terminal. تعليمي خطوة بخطوة مع أمثلة لأوامر git و npm و docker."
date: 2025-09-02
categories:
  - tutorials
tags:
  - amazon-q
  - terminal
  - autocomplete
  - cli-tools
  - macos
  - developer-tools
author_profile: true
toc: true
toc_label: "جدول المحتويات"
lang: ar
permalink: /ar/tutorials/amazon-q-developer-cli-setup-guide/
canonical_url: "https://thakicloud.github.io/ar/tutorials/amazon-q-developer-cli-setup-guide/"
---

⏱️ **وقت القراءة المتوقع**: 8 دقائق

## مقدمة

يقوم Amazon Q Developer CLI (المعروف سابقاً باسم Fig) بثورة في تجربة سطر الأوامر من خلال توفير إكمال تلقائي بنمط IDE لمئات أدوات CLI الشائعة. بدلاً من حفظ الأوامر والخيارات المعقدة، يمكنك ببساطة البدء في الكتابة والحصول على اقتراحات سياقية ذات صلة للأوامر الفرعية والخيارات والمعاملات.

سيرشدك هذا الدليل الشامل خلال تثبيت وإعداد واستخدام Amazon Q Developer CLI لتعزيز إنتاجية Terminal الخاص بك.

## ما هو Amazon Q Developer CLI؟

Amazon Q Developer CLI هو أداة إكمال تلقائي ذكية للطرفية تحول واجهة سطر الأوامر إلى بيئة أكثر سهولة وإنتاجية. يوفر:

- **إكمال تلقائي ذكي**: اقتراحات واعية للسياق لأكثر من 400 أداة CLI
- **مساعدة فورية**: وصول فوري إلى وثائق الأوامر
- **واجهة بصرية**: نوافذ إكمال نظيفة بنمط IDE
- **مفتوح المصدر**: مواصفات إكمال مدفوعة من المجتمع

### أدوات CLI المدعومة

يدعم Amazon Q مئات الأدوات الشائعة بما في ذلك:
- **إدارة الإصدارات**: `git`، `gh`، `svn`
- **مديري الحزم**: `npm`، `yarn`، `pip`، `brew`
- **خدمات السحابة**: `aws`، `gcloud`، `azure`
- **الحاويات**: `docker`، `kubectl`، `helm`
- **التطوير**: `node`، `python`، `java`، `go`

## متطلبات النظام

### المنصات المدعومة
- **macOS**: المنصة الأساسية مع دعم كامل للميزات
- **Linux**: قيد التطوير (إصدار تجريبي للمجتمع متاح)
- **Windows**: قيد التطوير (إصدار تجريبي للمجتمع متاح)

### الطرفيات المدعومة
- macOS Terminal
- iTerm2
- Tabby
- Hyper
- Kitty
- WezTerm
- Alacritty
- VSCode Integrated Terminal
- JetBrains IDEs
- Android Studio
- Nova

### المتطلبات المسبقة
- **macOS**: 10.14 أو أحدث
- **Shell**: bash أو zsh أو fish
- **Node.js**: مطلوب للتطوير (اختياري للاستخدام)

## دليل التثبيت

### الطريقة 1: Homebrew (موصى بها)

أسهل طريقة لتثبيت Amazon Q Developer CLI على macOS:

```bash
# تثبيت Amazon Q عبر Homebrew
brew install amazon-q
```

### الطريقة 2: التنزيل المباشر

1. زيارة [aws.amazon.com](https://aws.amazon.com)
2. تنزيل ملف DMG
3. فتح الملف المنزل
4. سحب Amazon Q إلى مجلد Applications
5. تشغيل التطبيق

### الطريقة 3: سكريبت التثبيت اليدوي

للمستخدمين المتقدمين الذين يفضلون التثبيت اليدوي:

```bash
#!/bin/bash
# تنزيل وتثبيت Amazon Q Developer CLI

# إنشاء دليل مؤقت
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# تنزيل أحدث إصدار
curl -L -o amazon-q.dmg "https://aws.amazon.com/q/developer/cli/download"

# تثبيت وتركيب
hdiutil mount amazon-q.dmg
cp -R "/Volumes/Amazon Q/Amazon Q.app" /Applications/
hdiutil unmount "/Volumes/Amazon Q"

# تنظيف
cd ~
rm -rf "$TEMP_DIR"

echo "تم تثبيت Amazon Q Developer CLI بنجاح!"
echo "يرجى تشغيل التطبيق لإكمال الإعداد."
```

## الإعداد الأولي والتكوين

### الخطوة 1: تشغيل Amazon Q

بعد التثبيت، قم بتشغيل Amazon Q من مجلد Applications أو Launchpad:

```bash
# تشغيل عبر سطر الأوامر
open -a "Amazon Q"
```

### الخطوة 2: منح الأذونات

يتطلب Amazon Q أذونات معينة للعمل بشكل صحيح:

1. **إذن إمكانية الوصول**:
   - تفضيلات النظام ← الأمان والخصوصية ← الخصوصية ← إمكانية الوصول
   - إضافة Amazon Q وتمكينه

2. **إذن مراقبة الإدخال**:
   - تفضيلات النظام ← الأمان والخصوصية ← الخصوصية ← مراقبة الإدخال
   - إضافة Amazon Q وتمكينه

### الخطوة 3: تكامل Shell

يتكامل Amazon Q تلقائياً مع shell عند التشغيل الأول. في حالة الحاجة للتكوين اليدوي:

#### لـ Zsh (افتراضي على macOS)
```bash
# إضافة إلى ~/.zshrc
echo 'eval "$(q init zsh)"' >> ~/.zshrc
source ~/.zshrc
```

#### لـ Bash
```bash
# إضافة إلى ~/.bashrc أو ~/.bash_profile
echo 'eval "$(q init bash)"' >> ~/.bash_profile
source ~/.bash_profile
```

#### لـ Fish
```bash
# إضافة إلى ~/.config/fish/config.fish
echo 'q init fish | source' >> ~/.config/fish/config.fish
```

### الخطوة 4: التحقق من التثبيت

اختبر أن Amazon Q يعمل بشكل صحيح:

```bash
# اختبار مع أمر git
git <اضغط-tab>

# اختبار مع أمر npm
npm <اضغط-tab>

# اختبار مع أمر docker
docker <اضغط-tab>
```

يجب أن تظهر اقتراحات إكمال تلقائي ذكية.

## أمثلة الاستخدام الأساسية

### أوامر Git

يجعل Amazon Q عمليات git أكثر سهولة:

```bash
# عمليات git الأساسية
git add <tab>          # يظهر الملفات غير المرحلة
git commit -<tab>      # يظهر خيارات الالتزام
git branch <tab>       # يظهر الفروع المتاحة
git checkout <tab>     # يظهر الفروع والملفات
git push origin <tab>  # يظهر الفروع البعيدة

# سير عمل git متقدم
git rebase -<tab>      # خيارات rebase التفاعلية
git log --<tab>        # خيارات تنسيق السجل
git merge <tab>        # يظهر الفروع القابلة للدمج
```

### NPM وإدارة الحزم

تبسيط سير عمل إدارة الحزم:

```bash
# أوامر NPM
npm install <tab>      # يقترح حزم من السجل
npm run <tab>          # يظهر السكريبتات المتاحة
npm update <tab>       # يظهر الحزم القديمة

# أوامر Yarn
yarn add <tab>         # اقتراحات الحزم
yarn remove <tab>      # يظهر الحزم المثبتة
yarn workspace <tab>   # يظهر أسماء مساحات العمل
```

### عمليات Docker

تبسيط إدارة الحاويات:

```bash
# أوامر Docker
docker run <tab>       # اقتراحات الصور والخيارات
docker exec <tab>      # أسماء الحاويات قيد التشغيل
docker ps <tab>        # خيارات تنسيق الحاويات
docker build <tab>     # خيارات البناء والسياقات

# Docker Compose
docker-compose up <tab>    # أسماء الخدمات
docker-compose logs <tab>  # اختيار الخدمة
```

### تكامل AWS CLI

عمليات سحابية محسنة:

```bash
# أوامر AWS
aws s3 <tab>           # عمليات خدمة S3
aws ec2 <tab>          # عمليات خدمة EC2
aws configure <tab>    # خيارات التكوين

# اقتراحات خاصة بالموارد
aws s3 cp <tab>        # أسماء Buckets والكائنات
aws ec2 describe-instances <tab>  # خيارات التصفية
```

## التكوين المتقدم

### تخصيص المظهر

تكوين مظهر Amazon Q ليتناسب مع موضوع terminal الخاص بك:

```bash
# فتح التكوين
q config

# الموضوعات المتاحة
q config set theme dark
q config set theme light
q config set theme auto

# تخصيص الألوان
q config set color.suggestion "#a8a8a8"
q config set color.description "#666666"
```

### تحسين الأداء

تحسين Amazon Q للحصول على أداء أفضل:

```bash
# ضبط تأخير الاقتراح (بالميلي ثانية)
q config set suggestion-delay 100

# تحديد عدد الاقتراحات
q config set max-suggestions 10

# إدارة التخزين المؤقت
q cache clear
q cache rebuild
```

### اختصارات المفاتيح المخصصة

تخصيص اختصارات لوحة المفاتيح:

```bash
# تكوين مفتاح القبول
q config set key.accept tab

# تكوين مفتاح الرفض
q config set key.dismiss escape

# تكوين مفاتيح التنقل
q config set key.up "ctrl+p"
q config set key.down "ctrl+n"
```

## المساهمة في مواصفات الإكمال

تأتي قوة Amazon Q من مواصفات الإكمال المدفوعة من المجتمع. يمكنك المساهمة بمواصفات جديدة أو تحسين الموجودة.

### إعداد بيئة التطوير

```bash
# استنساخ المستودع
git clone https://github.com/withfig/autocomplete.git
cd autocomplete

# تثبيت التبعيات
pnpm install

# إنشاء مواصفة جديدة
pnpm create-spec your-cli-tool

# تمكين وضع التطوير
pnpm dev
```

### إنشاء مواصفة إكمال بسيطة

مثال على بنية مواصفة إكمال أساسية:

```typescript
// src/your-tool.ts
const completionSpec: Fig.Spec = {% raw %}{
  name: "your-tool",
  description: "وصف أداة CLI الخاصة بك",
  subcommands: [
    {
      name: "start",
      description: "بدء الخدمة",
      options: [
        {
          name: "--port",
          description: "تحديد رقم المنفذ",
          args: {
            name: "port",
            description: "رقم المنفذ (1-65535)"
          }
        }
      ]
    }
  ],
  options: [
    {
      name: "--help",
      description: "إظهار معلومات المساعدة"
    }
  ]
}{% endraw %};

export default completionSpec;
```

### اختبار مساهماتك

```bash
# بناء المواصفات
pnpm build

# اختبار مواصفتك
your-tool <tab>

# تشغيل فحص الأنواع
pnpm test

# lint وإصلاح المشاكل
pnpm lint:fix
```

## استكشاف الأخطاء وإصلاحها

### مشاكل التثبيت

**المشكلة**: Amazon Q لا يظهر في Terminal
```bash
# الحل: إعادة تشغيل التهيئة
q init zsh --force
source ~/.zshrc
```

**المشكلة**: أخطاء رفض الإذن
```bash
# الحل: فحص ومنح الأذونات
q doctor
```

### مشاكل الأداء

**المشكلة**: اقتراحات الإكمال التلقائي بطيئة
```bash
# الحل: مسح التخزين المؤقت والتحسين
q cache clear
q config set suggestion-delay 50
```

**المشكلة**: استخدام عالي لوحدة المعالجة المركزية
```bash
# الحل: تقليل عدد الاقتراحات
q config set max-suggestions 5
q config set cache-size 1000
```

### مشاكل التكامل

**المشكلة**: لا يعمل مع terminal معين
```bash
# الحل: فحص التوافق
q doctor

# التكامل اليدوي
q init bash --force  # أو zsh، fish
```

## أفضل الممارسات ونصائح الخبراء

### 1. تحسين سير العمل

- **تعلم الأنماط الشائعة**: تعرف على أنماط الأوامر المستخدمة بكثرة
- **استخدام المطابقة الضبابية**: يدعم Amazon Q المطابقة الضبابية للتنقل السريع
- **التخصيص حسب احتياجاتك**: اضبط الإعدادات حسب سير عملك المحدد

### 2. اختصارات الإنتاجية

```bash
# اختصارات التنقل السريع
cd <tab>               # اقتراحات الدلائل
cd ../../../<tab>      # تنقل الدليل الأصلي

# عمليات الملفات
cp <tab>               # إكمال مسار الملف
mv <tab>               # اقتراحات المصدر والوجهة

# إدارة العمليات
kill <tab>             # اقتراحات العمليات قيد التشغيل
ps aux | grep <tab>    # إكمال اسم العملية
```

### 3. تعاون الفريق

- **مشاركة المواصفات**: ساهم بمواصفات إكمال مفيدة لأدوات فريقك
- **توثيق سير العمل**: أنشئ وثائق داخلية لتسلسلات الأوامر المعقدة
- **توحيد الإعداد**: استخدم تكوينات Amazon Q متسقة عبر فريقك

## اعتبارات الأمان

### خصوصية البيانات

يعمل Amazon Q محلياً على جهازك:
- **لا توجد معالجة سحابية**: يتم إنشاء الاقتراحات محلياً
- **لا يوجد جمع بيانات**: تبقى أوامرك وملفاتك على جهازك
- **مفتوح المصدر**: كود شفاف متاح للمراجعة

### إدارة الأذونات

كن حذراً من الأذونات التي تمنحها:
- **إمكانية الوصول**: مطلوب لوضع نافذة الاقتراح
- **مراقبة الإدخال**: مطلوب لقراءة الأوامر المكتوبة
- **نطاق أدنى**: يصل Amazon Q فقط إلى ما هو ضروري للإكمال التلقائي

## خاتمة

يحول Amazon Q Developer CLI تجربة Terminal من واجهة تركز على الحفظ إلى بيئة مرشدة وبديهية. من خلال توفير إكمال تلقائي ذكي لمئات أدوات CLI، فإنه يقلل بشكل كبير من منحنى التعلم للأدوات الجديدة ويحسن إنتاجية المطورين ذوي الخبرة.

الفوائد الرئيسية تشمل:
- **تقليل الحمل المعرفي**: لا حاجة لحفظ بناء الأوامر المعقدة
- **إدخال أوامر أسرع**: الاقتراحات الواعية للسياق تسرع الكتابة
- **مسرع التعلم**: اكتشف ميزات وخيارات جديدة بشكل طبيعي
- **تجربة متسقة**: واجهة موحدة عبر أدوات CLI مختلفة

ابدأ بالتثبيت الأساسي واستكشف تدريجياً الميزات المتقدمة كلما أصبحت أكثر راحة مع الأداة. الطبيعة المدفوعة من المجتمع لـ Amazon Q تعني أنه يستمر في التحسن مع مساهمات من المطورين حول العالم.

سواء كنت مبتدئاً تتطلع لتعلم أدوات سطر الأوامر أو مطوراً ذا خبرة يسعى لتحسين سير العمل، يقدم Amazon Q Developer CLI قيمة كبيرة في جعل Terminal أكثر سهولة وإنتاجية.

---

## موارد إضافية

- **الوثائق الرسمية**: [وثائق Amazon Q Developer CLI](https://aws.amazon.com/q/developer/cli/)
- **مستودع GitHub**: [withfig/autocomplete](https://github.com/withfig/autocomplete)
- **مناقشات المجتمع**: [مناقشات AWS Q CLI](https://github.com/aws/q-command-line-discussions)
- **دليل المساهمة**: [كيفية المساهمة](https://github.com/withfig/autocomplete/blob/master/CONTRIBUTING.md)
