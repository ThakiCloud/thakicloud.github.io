---
title: "DocuSeal: دليل شامل لمنصة توقيع المستندات مفتوحة المصدر"
excerpt: "تعلم كيفية إعداد واستخدام DocuSeal، البديل مفتوح المصدر لـ DocuSign. يغطي هذا الدليل الشامل تثبيت Docker وإنشاء نماذج PDF وسير عمل التوقيع الرقمي."
seo_title: "دليل DocuSeal: منصة توقيع المستندات مفتوحة المصدر - Thaki Cloud"
seo_description: "دليل DocuSeal الشامل يغطي التثبيت والإعداد والاستخدام. تعلم إنشاء نماذج PDF وإدارة التوقيعات الرقمية وتكامل هذا البديل مفتوح المصدر لـ DocuSign."
date: 2025-09-28
categories:
  - tutorials
tags:
  - docuseal
  - مفتوح-المصدر
  - توقيع-المستندات
  - pdf
  - docker
  - التوقيع-الرقمي
  - التوقيع-الإلكتروني
author_profile: true
toc: true
toc_label: "جدول المحتويات"
lang: ar
permalink: /ar/tutorials/docuseal-open-source-document-signing-tutorial/
canonical_url: "https://thakicloud.github.io/ar/tutorials/docuseal-open-source-document-signing-tutorial/"
---

⏱️ **وقت القراءة المقدر**: 8 دقائق

## مقدمة

في عالمنا الرقمي اليوم، أصبح توقيع ومعالجة المستندات أمراً أساسياً للشركات والأفراد على حد سواء. بينما تحظى الحلول التجارية مثل DocuSign بشعبية كبيرة، إلا أنها قد تكون مكلفة وقد لا توفر المرونة التي تحتاجها المؤسسات. هنا يأتي دور [DocuSeal](https://github.com/docusealco/docuseal)، البديل مفتوح المصدر الذي يوفر إمكانيات توقيع المستندات الرقمية بشكل آمن وفعال.

DocuSeal هو منصة شاملة تتيح لك إنشاء نماذج PDF وجمع التوقيعات وإدارة سير عمل المستندات - كل ذلك مع الحفاظ على السيطرة الكاملة على بياناتك وبنيتك التحتية. مع أكثر من 10,000 نجمة على GitHub، أثبت أنه حل موثوق للمؤسسات التي تبحث عن إدارة مستندات فعالة من حيث التكلفة.

## ما هو DocuSeal؟

DocuSeal هو منصة توقيع مستندات مفتوحة المصدر توفر:

- **منشئ نماذج PDF**: محرر WYSIWYG لإنشاء نماذج PDF تفاعلية
- **أنواع حقول متعددة**: دعم لـ 12 نوع حقل مختلف بما في ذلك التوقيعات والتواريخ والملفات ومربعات الاختيار
- **دعم متعدد المرسلين**: التعامل مع المستندات التي تتطلب توقيعات متعددة
- **إشعارات بريد إلكتروني تلقائية**: تكامل SMTP مدمج لأتمتة سير العمل
- **تخزين مرن**: دعم للقرص المحلي وAWS S3 وGoogle Storage وAzure Cloud
- **تحسين للهاتف المحمول**: تصميم متجاوب يعمل بسلاسة على جميع الأجهزة
- **دعم متعدد اللغات**: متاح بـ 6 لغات واجهة مع دعم التوقيع بـ 14 لغة
- **تكامل API**: واجهة برمجة تطبيقات RESTful وwebhooks لتكامل الأنظمة

## المتطلبات المسبقة

قبل أن نبدأ، تأكد من تثبيت ما يلي على نظامك:

- **Docker**: الإصدار 20.10 أو أحدث
- **Docker Compose**: الإصدار 2.0 أو أحدث (اختياري ولكن موصى به)
- **متصفح ويب**: متصفح حديث مع تفعيل JavaScript
- **خادم بريد إلكتروني**: خادم SMTP لإشعارات البريد الإلكتروني (اختياري)

## طرق التثبيت

يوفر DocuSeal خيارات نشر متعددة. سنركز على التثبيتات المبنية على Docker، والتي تعتبر الأكثر وضوحاً وقابلية للنقل.

### الطريقة 1: إعداد Docker السريع

أسرع طريقة لتشغيل DocuSeal هي باستخدام أمر Docker واحد:

```bash
docker run --name docuseal -p 3000:3000 -v $(pwd)/docuseal-data:/data docuseal/docuseal
```

هذا الأمر:
- ينشئ حاوية باسم `docuseal`
- يربط المنفذ 3000 من الحاوية بجهازك المحلي
- ينشئ مجلد لحفظ البيانات بشكل دائم في دليل `docuseal-data`
- يستخدم SQLite كقاعدة بيانات افتراضية

### الطريقة 2: Docker Compose (موصى به)

لبيئات الإنتاج أو عندما تحتاج مزيد من التحكم، استخدم Docker Compose:

```bash
# تحميل ملف docker-compose.yml
curl https://raw.githubusercontent.com/docusealco/docuseal/master/docker-compose.yml > docker-compose.yml

# بدء التطبيق
docker compose up -d
```

للنشر على نطاق مخصص مع SSL تلقائي:

```bash
sudo HOST=your-domain-name.com docker compose up
```

### الطريقة 3: تكوين قاعدة البيانات

للاستخدام في الإنتاج، قد ترغب في استخدام PostgreSQL أو MySQL بدلاً من SQLite:

```bash
# مثال PostgreSQL
docker run --name docuseal \
  -p 3000:3000 \
  -v $(pwd)/docuseal-data:/data \
  -e DATABASE_URL="postgresql://username:password@host:5432/docuseal" \
  docuseal/docuseal

# مثال MySQL
docker run --name docuseal \
  -p 3000:3000 \
  -v $(pwd)/docuseal-data:/data \
  -e DATABASE_URL="mysql2://username:password@host:3306/docuseal" \
  docuseal/docuseal
```

## الإعداد والتكوين الأولي

### 1. الوصول الأول

بمجرد تشغيل DocuSeal، افتح متصفح الويب وانتقل إلى:

```
http://localhost:3000
```

ستظهر لك معالج إعداد DocuSeal.

### 2. إنشاء حساب المدير

أنشئ حساب المدير الخاص بك من خلال توفير:
- **الاسم الكامل**: اسمك المعروض
- **عنوان البريد الإلكتروني**: سيُستخدم لتسجيل الدخول والإشعارات
- **كلمة المرور**: اختر كلمة مرور قوية
- **اسم المؤسسة**: اسم شركتك أو مؤسستك

### 3. تكوين SMTP (اختياري)

لتفعيل إشعارات البريد الإلكتروني، قم بتكوين إعدادات SMTP:

```yaml
# متغيرات البيئة لـ SMTP
SMTP_ADDRESS: smtp.gmail.com
SMTP_PORT: 587
SMTP_USERNAME: your-email@gmail.com
SMTP_PASSWORD: your-app-password
SMTP_DOMAIN: gmail.com
SMTP_AUTHENTICATION: plain
SMTP_ENABLE_STARTTLS_AUTO: true
```

## إنشاء قالب المستند الأول

### الخطوة 1: رفع مستند PDF

1. انقر على **"قالب جديد"** من لوحة التحكم
2. ارفع مستند PDF الخاص بك أو أنشئ واحداً جديداً
3. أعط قالبك اسماً وصفياً
4. أضف أي وصف أو تعليمات ضرورية

### الخطوة 2: إضافة حقول النموذج

يوفر DocuSeal واجهة سحب وإفلات لإضافة الحقول:

#### أنواع الحقول المتاحة:

- **التوقيع**: لجمع التوقيعات الرقمية
- **الأحرف الأولى**: لجمع الأحرف الأولى
- **النص**: إدخال نص من سطر واحد
- **التاريخ**: حقل منتقي التاريخ
- **الرقم**: إدخال رقمي مع التحقق
- **اختيار**: قائمة منسدلة للاختيار
- **مربع اختيار**: مربع اختيار منطقي
- **راديو**: اختيار متعدد
- **ملف**: إمكانية رفع الملفات
- **صورة**: إدراج الصور
- **هاتف**: رقم هاتف مع التنسيق
- **بريد إلكتروني**: عنوان بريد إلكتروني مع التحقق

#### إضافة الحقول:

1. اختر نوع الحقل من شريط الأدوات
2. انقر واسحب لوضع الحقل على المستند
3. قم بتغيير حجم الحقل حسب الحاجة
4. قم بتكوين خصائص الحقل:
   - **مطلوب**: جعل الحقل إلزامياً
   - **القيمة الافتراضية**: ملء مسبق بنص افتراضي
   - **التحقق**: إضافة قواعد تحقق مخصصة
   - **المنطق الشرطي**: إظهار/إخفاء بناءً على حقول أخرى

### الخطوة 3: تكوين المرسلين

حدد من يحتاج لتوقيع أو ملء المستند:

1. انقر على **"إضافة مرسل"**
2. حدد تفاصيل المرسل:
   - **الاسم**: الاسم المعروض للمرسل
   - **البريد الإلكتروني**: عنوان البريد الإلكتروني للإشعارات
   - **الدور**: حدد دورهم (موقع، مراجع، إلخ)
3. قم بتعيين الحقول لمرسلين محددين بالترميز اللوني

## إدارة سير عمل المستندات

### إرسال المستندات للتوقيع

1. **اختيار القالب**: اختر القالب المُعد مسبقاً
2. **إضافة المستلمين**: أدخل معلومات المستلمين
3. **تخصيص الرسالة**: أضف رسالة شخصية
4. **تعيين ترتيب التوقيع**: حدد التسلسل إذا كان هناك موقعون متعددون
5. **إرسال**: DocuSeal يرسل دعوات البريد الإلكتروني تلقائياً

### تتبع التقدم

توفر لوحة التحكم تتبعاً في الوقت الفعلي:

- **معلق**: مستندات تنتظر إجراءً
- **قيد التقدم**: يتم توقيعها حالياً
- **مكتملة**: مستندات منفذة بالكامل
- **مرفوضة**: مستندات مرفوضة

### التذكيرات التلقائية

قم بتكوين تذكيرات تلقائية للتوقيعات المعلقة:

```yaml
# إعدادات التذكير
REMINDER_INTERVAL: 3 # أيام
MAX_REMINDERS: 3
REMINDER_MESSAGE: "يرجى إكمال توقيع المستند"
```

## الميزات المتقدمة

### تكامل API

يوفر DocuSeal واجهة برمجة تطبيقات REST شاملة للتكامل:

```bash
# إنشاء إرسال جديد
curl -X POST https://your-docuseal-instance.com/api/submissions \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "template_id": 123,
    "submitters": [
      {
        "name": "أحمد محمد",
        "email": "ahmed@example.com"
      }
    ]
  }'
```

### تكوين Webhook

إعداد webhooks لتلقي إشعارات في الوقت الفعلي:

```json
{
  "webhook_url": "https://your-app.com/webhooks/docuseal",
  "events": [
    "submission.created",
    "submission.completed",
    "submission.declined"
  ]
}
```

### إنشاء القوالب عبر API

إنشاء القوالب برمجياً:

```bash
# رفع وإنشاء قالب
curl -X POST https://your-docuseal-instance.com/api/templates \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -F "file=@document.pdf" \
  -F "name=قالب العقد"
```

## الأمان والامتثال

### التحقق من توقيع PDF

يضيف DocuSeal تلقائياً توقيعات مشفرة إلى ملفات PDF:

- **الشهادات الرقمية**: يستخدم شهادات X.509
- **سلطة الطوابع الزمنية**: يضيف طوابع زمنية موثوقة
- **التحقق من التوقيع**: أدوات تحقق مدمجة
- **مسار المراجعة**: تاريخ توقيع كامل

### حماية البيانات

- **التشفير**: جميع البيانات مشفرة أثناء الراحة والنقل
- **التحكم في الوصول**: أذونات قائمة على الأدوار
- **تسجيل المراجعة**: سجلات نشاط شاملة
- **امتثال GDPR**: ميزات حماية البيانات

## استكشاف الأخطاء وإصلاحها

### حاوية Docker لا تبدأ

```bash
# فحص سجلات الحاوية
docker logs docuseal

# حلول شائعة
docker system prune  # تنظيف موارد Docker
docker pull docuseal/docuseal:latest  # التحديث لأحدث إصدار
```

### مشاكل اتصال قاعدة البيانات

```bash
# اختبار اتصال قاعدة البيانات
docker exec -it docuseal rails db:migrate:status

# إعادة تعيين قاعدة البيانات إذا لزم الأمر
docker exec -it docuseal rails db:reset
```

### مشاكل تسليم البريد الإلكتروني

1. تحقق من بيانات اعتماد SMTP
2. فحص إعدادات جدار الحماية
3. اختبار مع مزود SMTP مختلف
4. مراجعة سجلات البريد الإلكتروني في التطبيق

### تحسين الأداء

للاستخدام عالي الحجم:

```yaml
# تحسين Docker Compose
services:
  docuseal:
    environment:
      - RAILS_MAX_THREADS=10
      - WEB_CONCURRENCY=3
      - RAILS_ENV=production
    deploy:
      resources:
        limits:
          memory: 2G
        reservations:
          memory: 1G
```

## اعتبارات النشر في الإنتاج

### تكوين SSL/TLS

استخدم دائماً HTTPS في الإنتاج:

```nginx
# مثال تكوين Nginx
server {
    listen 443 ssl;
    server_name your-domain.com;
    
    ssl_certificate /path/to/certificate.crt;
    ssl_certificate_key /path/to/private.key;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### استراتيجية النسخ الاحتياطي

النسخ الاحتياطية المنتظمة ضرورية:

```bash
# نسخة احتياطية لقاعدة البيانات
docker exec docuseal pg_dump -U postgres docuseal > backup.sql

# نسخة احتياطية لتخزين الملفات
rsync -av ./docuseal-data/ ./backups/$(date +%Y%m%d)/
```

### المراقبة والتسجيل

إعداد المراقبة للإنتاج:

```yaml
# Docker Compose مع التسجيل
services:
  docuseal:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

## أمثلة التكامل

### تكامل React

```jsx
import React, { useEffect } from 'react';

const DocuSealEmbed = ({ submissionId }) => {
  useEffect(() => {
    const script = document.createElement('script');
    script.src = 'https://your-docuseal-instance.com/embed.js';
    script.onload = () => {
      window.DocuSeal.embed({
        src: `https://your-docuseal-instance.com/s/${submissionId}`,
        email: 'user@example.com'
      });
    };
    document.body.appendChild(script);
  }, [submissionId]);

  return <div id="docuseal-form"></div>;
};
```

### تكامل Node.js API

```javascript
const axios = require('axios');

class DocuSealClient {
  constructor(apiToken, baseUrl) {
    this.client = axios.create({
      baseURL: baseUrl,
      headers: {
        'Authorization': `Bearer ${apiToken}`,
        'Content-Type': 'application/json'
      }
    });
  }

  async createSubmission(templateId, submitters) {
    try {
      const response = await this.client.post('/api/submissions', {
        template_id: templateId,
        submitters: submitters
      });
      return response.data;
    } catch (error) {
      console.error('خطأ في إنشاء الإرسال:', error);
      throw error;
    }
  }
}
```

## الخلاصة

يوفر DocuSeal بديلاً قوياً مفتوح المصدر لمنصات توقيع المستندات التجارية. مرونته ومجموعة ميزاته الشاملة ومجتمع التطوير النشط يجعله خياراً ممتازاً للمؤسسات من جميع الأحجام.

الفوائد الرئيسية لاستخدام DocuSeal:

- **فعال من حيث التكلفة**: لا توجد رسوم لكل توقيع أو حدود للمستخدمين
- **ملكية البيانات**: تحكم كامل في مستنداتك وبياناتك
- **التخصيص**: مفتوح المصدر يسمح بالتعديلات المخصصة
- **التكامل**: واجهة برمجة تطبيقات شاملة للتكامل السلس
- **الأمان**: ميزات أمان على مستوى المؤسسة
- **قابلية التوسع**: يتعامل مع كل شيء من الفرق الصغيرة إلى المؤسسات الكبيرة

سواء كنت شركة صغيرة تتطلع لرقمنة سير عمل المستندات أو مؤسسة كبيرة تحتاج حل توقيع قابل للتخصيص، يوفر DocuSeal الأدوات والمرونة لتلبية احتياجاتك.

للتكوينات المتقدمة وميزات المؤسسة، فكر في استكشاف ميزات DocuSeal Pro أو المساهمة في المشروع مفتوح المصدر على [GitHub](https://github.com/docusealco/docuseal).

## موارد إضافية

- **الوثائق الرسمية**: [مستندات DocuSeal](https://www.docuseal.com/docs)
- **مستودع GitHub**: [https://github.com/docusealco/docuseal](https://github.com/docusealco/docuseal)
- **دعم المجتمع**: [مناقشات GitHub](https://github.com/docusealco/docuseal/discussions)
- **مرجع API**: [وثائق API](https://www.docuseal.com/api)
- **عرض توضيحي مباشر**: [جرب DocuSeal](https://demo.docuseal.com)

---

*هل لديك أسئلة حول DocuSeal أو تحتاج مساعدة في التنفيذ؟ لا تتردد في التواصل من خلال التعليقات أدناه أو انضم إلى مناقشات المجتمع على GitHub.*
