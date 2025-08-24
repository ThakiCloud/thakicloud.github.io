# 🌍 مدونة ثاكي كلاود التقنية متعددة اللغات

> 🇰🇷 [한국어 README](README.md) | 🇺🇸 [English README](README-en.md)

مرحباً بكم في مستودع المدونة التقنية الرسمية متعددة اللغات لشركة ثاكي كلاود! تُقدم هذه المدونة بـ **الكورية والإنجليزية والعربية**، وهي منصة لمشاركة خبراتنا ورؤانا وابتكاراتنا في حلول الحوسبة السحابية الخاصة (IaaS, PaaS, SaaS) وعمليات نماذج اللغة الكبيرة وهندسة الذكاء الاصطناعي مع القراء حول العالم.

---

## ✨ الهدف

- **جذب المواهب العالمية**: جذب أفضل المواهب التقنية في العالم من خلال المحتوى متعدد اللغات.
- **مشاركة المعرفة**: مشاركة الرؤى والدروس التعليمية والأبحاث والأخبار بلغات متعددة للمساهمة في المجتمع التقني العالمي.
- **بناء العلامة التجارية**: ترسيخ ثاكي كلاود كرائد تقني دولي.
- **إمكانية الوصول الثقافي**: تمكين جميع المستخدمين من الوصول إلى المعرفة التقنية دون حواجز لغوية.

---

## 🛠️ المكدس التقني

- **مولد المواقع الثابتة**: [Jekyll](https://jekyllrb.com/)
- **القالب**: [Minimal Mistakes](https://mmistakes.github.io/minimal-mistakes/)
- **تنسيق المحتوى**: Markdown
- **الدعم متعدد اللغات**: الكورية والإنجليزية والعربية (كشف تلقائي للغة المتصفح)
- **الاستضافة**: GitHub Pages
- **CI/CD**: GitHub Actions (بناء متعدد اللغات تلقائي)
- **الاختبار المحلي**: act (تنفيذ GitHub Actions محلياً)

## 🌐 دليل الوصول للموقع

### الكشف التلقائي للغة
عند زيارة [**thakicloud.github.io**](https://thakicloud.github.io)، ستتم إعادة توجيهك تلقائياً إلى صفحة اللغة المناسبة بناءً على إعدادات لغة المتصفح:

- **متصفح كوري** → `/ko/` (المدونة الكورية)
- **متصفح إنجليزي** → `/en/` (المدونة الإنجليزية)  
- **متصفح عربي** → `/ar/` (المدونة العربية)

### اختيار اللغة المباشر
يمكنك أيضاً الوصول إلى اللغة المفضلة مباشرة:

- 🇰🇷 **한국어**: [thakicloud.github.io/ko/](https://thakicloud.github.io/ko/)
- 🇺🇸 **English**: [thakicloud.github.io/en/](https://thakicloud.github.io/en/)
- 🇸🇦 **العربية**: [thakicloud.github.io/ar/](https://thakicloud.github.io/ar/)

### تبديل اللغة
يمكنك تبديل اللغات بحرية باستخدام قائمة التنقل في أعلى كل صفحة. يتم حفظ اللغة المختارة في ملفات تعريف الارتباط وتذكرها للزيارات المستقبلية.

---

## ✍️ كيفية كتابة مشاركات المدونة متعددة اللغات

يشرح هذا الدليل كيفية المساهمة بالمحتوى في مدونة ثاكي كلاود التقنية متعددة اللغات. جميع المشاركات مكتوبة بـ **الكورية والإنجليزية والعربية**.

### 1. إنشاء المشاركات متعددة اللغات تلقائياً

استخدم سكريبت إنشاء المشاركات متعددة اللغات لإنشاء قوالب للغات الثلاث دفعة واحدة:

```bash
# الاستخدام: new-multilingual-post <title-slug> <category>
~/scripts/new-multilingual-post.sh "ai-tutorial-guide" "tutorials"
```

### 2. اختيار الفئة

الفئات المدعومة حالياً:

- `agentops` (تطوير وتشغيل وكلاء الذكاء الاصطناعي)
- `careers` (المهنة والنمو)
- `culture` (ثقافة فريق التطوير والمنهجية)
- `datasets` (تحليل ومعالجة البيانات)
- `dev` (نصائح البرمجة والتطوير)
- `devops` (عمليات التطوير والبنية التحتية)
- `llmops` (عمليات نماذج اللغة الكبيرة)
- `news` (أحدث الاتجاهات التقنية)
- `owm` (إدارة سير العمل المفتوح)
- `research` (البحث التقني ومراجعات الأوراق)
- `tutorials` (أدلة عملية)

كل لغة لها هيكل دليل منفصل:
- الكورية: `_posts/ko/<category>/`
- الإنجليزية: `_posts/en/<category>/`
- العربية: `_posts/ar/<category>/`

### 3. إنشاء المحتوى الخاص باللغة

بعد تشغيل السكريبت، سيتم إنشاء الملفات الثلاثة التالية:

```
_posts/ko/tutorials/2025-01-28-ai-tutorial-guide.md  (كوري)
_posts/en/tutorials/2025-01-28-ai-tutorial-guide.md  (إنجليزي)
_posts/ar/tutorials/2025-01-28-ai-tutorial-guide.md  (عربي)
```

اكتب أو ترجم كل ملف باللغة المعنية.

### 4. هيكل البيانات الوصفية

تتضمن القوالب المُنشأة بيانات وصفية محسّنة متعددة اللغات:

**مثال كوري:**
```yaml
---
title: "AI 튜토리얼 가이드"
excerpt: "AI 기술의 기초부터 고급까지 다루는 완전 가이드"
seo_title: "AI 튜토리얼 완전 가이드 - Thaki Cloud"
seo_description: "AI 기술을 처음부터 배우고 싶은 개발자를 위한 단계별 튜토리얼"
date: 2025-01-28
lang: ko
categories:
  - tutorials
tags:
  - ai
  - tutorial
  - guide
author_profile: true
toc: true
canonical_url: "https://thakicloud.github.io/ko/tutorials/ai-tutorial-guide/"
---
```

**مثال عربي:**
```yaml
---
title: "دليل تعليمي شامل للذكاء الاصطناعي"
excerpt: "دليل شامل يغطي تقنية الذكاء الاصطناعي من الأساسيات إلى المتقدم"
seo_title: "دليل تعليمي شامل للذكاء الاصطناعي - ثاكي كلاود"
seo_description: "دروس تدريجية للمطورين الذين يريدون تعلم تقنية الذكاء الاصطناعي من الصفر"
date: 2025-01-28
lang: ar
categories:
  - tutorials
tags:
  - ai
  - tutorial
  - guide
author_profile: true
toc: true
canonical_url: "https://thakicloud.github.io/ar/tutorials/ai-tutorial-guide/"
---
```

### 5. دليل كتابة المحتوى

اكتب المحتوى لكل لغة مع مراعاة الجمهور المعني:

**المحتوى العربي:**
```markdown
⏱️ **وقت القراءة المقدر**: 15 دقيقة

## المقدمة

مع التطور السريع لتقنية الذكاء الاصطناعي...

## المحتوى الرئيسي

### 1. المفاهيم الأساسية
- المبادئ الأساسية للتعلم الآلي
- الاختلافات عن التعلم العميق

### 2. أمثلة عملية
```python
import tensorflow as tf
# شروحات بالتعليقات العربية
```

## الخلاصة
```

### 6. إضافة الصور والوسائط

يمكن تنظيم الصور حسب اللغة:

```
assets/images/posts/
├── ko/ai-tutorial-guide/
│   ├── diagram-ko.png
│   └── screenshot-ko.png
├── en/ai-tutorial-guide/
│   ├── diagram-en.png
│   └── screenshot-en.png
└── ar/ai-tutorial-guide/
    ├── diagram-ar.png
    └── screenshot-ar.png
```

الربط في Markdown:
```markdown
![مخطط الذكاء الاصطناعي](/assets/images/posts/ar/ai-tutorial-guide/diagram-ar.png)
```

### 7. البناء والمعاينة متعددة اللغات

#### معاينة اللغة الفردية:
```bash
# الموقع الكوري (المنفذ 4000)
bundle exec jekyll serve --config _config.yml,_config-ko.yml --port 4000

# الموقع الإنجليزي (المنفذ 4001)  
bundle exec jekyll serve --config _config.yml,_config-en.yml --port 4001

# الموقع العربي (المنفذ 4002)
bundle exec jekyll serve --config _config.yml,_config-ar.yml --port 4002
```

#### البناء المتكامل متعدد اللغات:
```bash
# بناء الموقع الكامل متعدد اللغات
./scripts/build-multilingual.sh

# معاينة الموقع المبني
cd _site && python3 -m http.server 4000
```

عناوين الوصول:
- الكورية: http://localhost:4000/ko/
- الإنجليزية: http://localhost:4000/en/
- العربية: http://localhost:4000/ar/

### 8. نشر المشاركات

#### الاختبار المحلي:
```bash
# اختبار CI/CD (باستخدام act)
act -j build -W .github/workflows/multilingual-deploy.yml --container-architecture linux/amd64

# أو تشغيل سكريبت الاختبار
~/scripts/test-multilingual-ci.sh
```

#### النشر على GitHub:
```bash
# إرسال جميع ملفات اللغات
git add _posts/ko/ _posts/en/ _posts/ar/
git commit -m "feat: Add multilingual AI tutorial guide"
git push origin main
```

تقوم GitHub Actions تلقائياً ببناء ونشر الموقع متعدد اللغات:
1. بناء الكورية والإنجليزية والعربية منفصلة
2. إنشاء موقع متكامل
3. النشر على GitHub Pages

---

## 🎯 أوامر إدارة المدونة متعددة اللغات

أوامر مفيدة للراحة:

```bash
# فحص حالة المدونة
echo "📊 حالة المدونة متعددة اللغات:"
echo "🇰🇷 المشاركات الكورية: $(find _posts/ko -name '*.md' | wc -l)"
echo "🇺🇸 المشاركات الإنجليزية: $(find _posts/en -name '*.md' | wc -l)"  
echo "🇸🇦 المشاركات العربية: $(find _posts/ar -name '*.md' | wc -l)"

# التنقل إلى أدلة اللغات
cd _posts/ko/    # المشاركات الكورية
cd _posts/en/    # المشاركات الإنجليزية  
cd _posts/ar/    # المشاركات العربية
```

---

هذا كل شيء! نتطلع إلى مساهماتكم في مدونة ثاكي كلاود التقنية متعددة اللغات. إذا كانت لديكم أسئلة، يرجى الاتصال بمدير المشروع.

## 📝 دليل المساهمة والتطوير المحلي

يشغل هذا المستودع مدونة ووثائق ثاكي كلاود عبر Jekyll. فيما يلي دليل للكتابة والاختبار وتقديم التغييرات.

---

### 1. سير عمل التطوير المحلي

```bash
git checkout main
git pull origin main
git checkout -b docs/update-local-ci-guide
```

اكتب مشاركتك أو وثائقك في `_posts/` أو `_pages/` أو `docs/`.

```bash
git add docs/local-ci-check-guide.md
git commit -m "docs: Add local CI check guide"
git push origin docs/update-local-ci-guide
```

ثم افتح طلب سحب (PR) على GitHub واطلب المراجعة.

---

### 2. قائمة فحص ما قبل CI المحلي

> للتفاصيل الكاملة، راجع `docs/local-ci-check-guide.md`

#### البيئة المطلوبة

- Ruby 3.2+, Node.js 18+, Python3
- Bundler, npm, pip

#### الفحوصات المطلوب تشغيلها

1. تثبيت التبعيات:
   ```bash
   bundle install
   npm install
   pip install -r requirements.txt
   ```
2. فحوصات بناء Jekyll:
   ```bash
   bundle exec jekyll doctor
   JEKYLL_ENV=production bundle exec jekyll build --verbose --trace
   ```
3. فحص Markdown:
   ```bash
   markdownlint '_posts/**/*.md'
   ```
4. التحقق من HTML والروابط:
   ```bash
   html-validate .
   broken-link-checker http://localhost:4000
   ```
5. فحوصات الأمان:
   ```bash
   trivy fs .
   detect-secrets scan
   ```
6. الأداء (Lighthouse):
   ```bash
   lhci autorun
   ```

---

## ✅ قائمة فحص ما قبل النشر CI

- [ ] تأكيد إصدار Ruby وNode وPython
- [ ] تثبيت التبعيات
- [ ] تشغيل `jekyll build` بنجاح
- [ ] اجتياز فحوصات Markdown/HTML/الروابط
- [ ] عدم وجود مشاكل أمنية
- [ ] اجتياز تدقيق Lighthouse
- [ ] `_site/` يبدو جاهزاً للإنتاج

---

## 🧠 ملاحظات أخيرة

- قد تختلف بيئة CI قليلاً عن البيئة المحلية
- اضبط الأوامر إذا كنت تستخدم خط أنابيب CI/CD مخصص
- لمزيد من المعلومات، راجع `docs/local-ci-check-guide.md`
