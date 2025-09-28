---
title: "nginx-ignition: دليل شامل لإدارة nginx عبر الويب"
excerpt: "تعلم كيفية إدارة خوادم nginx بسهولة باستخدام واجهة الويب البديهية لـ nginx-ignition. دليل شامل يغطي التثبيت والتكوين وشهادات SSL وتكامل Docker."
seo_title: "دليل nginx-ignition: واجهة ويب لإدارة خادم nginx - Thaki Cloud"
seo_description: "أتقن واجهة nginx-ignition الويب لإدارة خادم nginx. دليل خطوة بخطوة يغطي إعداد Docker وشهادات SSL والمضيفات الافتراضية وتكوين البروكسي."
date: 2025-09-28
categories:
  - tutorials
tags:
  - nginx
  - خادم-ويب
  - docker
  - ssl
  - بروكسي
  - devops
author_profile: true
toc: true
toc_label: "جدول المحتويات"
lang: ar
permalink: /ar/tutorials/nginx-ignition-web-ui-management-tutorial/
canonical_url: "https://thakicloud.github.io/ar/tutorials/nginx-ignition-web-ui-management-tutorial/"
---

⏱️ **وقت القراءة المقدر**: 12 دقيقة

## مقدمة

إدارة ملفات تكوين nginx يمكن أن تكون معقدة وعرضة للأخطاء، خاصة للمطورين الذين يفضلون الواجهات المرئية على تحرير سطر الأوامر. nginx-ignition يحل هذه المشكلة من خلال توفير واجهة مستخدم ويب بديهية لإدارة خادم nginx.

هذا الدليل الشامل سيرشدك خلال تثبيت وتكوين واستخدام nginx-ignition لإدارة خوادم nginx بكفاءة.

## ما هو nginx-ignition؟

nginx-ignition هو واجهة ويب مفتوحة المصدر لخادم nginx الويب، مصمم للمطورين والهواة الذين يريدون تجنب إدارة ملفات التكوين يدوياً. بينما لا يهدف إلى أن يكون مكتمل الميزات للحالات المتقدمة، فإنه يوفر إمكانيات تكوين nginx قوية وبديهية.

### الميزات الرئيسية

- **مضيفات افتراضية متعددة**: إدارة عدة مضيفات nginx افتراضية مع نطاقات وطرق وربط منافذ مخصصة
- **بروكسي التدفق**: دعم بروكسي حركة TCP وUDP ومقابس Unix مع توجيه قائم على SNI
- **توجيه مرن**: يمكن للطرق أن تعمل كبروكسي أو إعادة توجيه أو تنفيذ كود مخصص (JavaScript/Lua) أو ردود ثابتة أو خدمة ملفات
- **إدارة شهادات SSL**: دعم متكامل لـ Let's Encrypt والشهادات الموقعة ذاتياً والمخصصة مع التجديد التلقائي
- **التحكم في الوصول**: دعم متعدد المستخدمين مع التحكم في الوصول القائم على الخصائص (ABAC)
- **التكامل الأصلي**: دعم مدمج لـ Docker وTrueNAS Scale
- **تسجيل شامل**: سجلات وصول وخطأ الخادم والمضيف الافتراضي مع التدوير التلقائي
- **قوائم الوصول**: التحكم في الوصول باستخدام المصادقة الأساسية و/أو فحص عنوان IP المصدر

## المتطلبات المسبقة

قبل البدء، تأكد من وجود:

- Docker مثبت على نظامك
- فهم أساسي لمفاهيم nginx
- وصول إداري إلى خادمك
- المنافذ 8090 و80 متاحة (أو منافذ بديلة)

## طرق التثبيت

### الطريقة 1: Docker (موصى بها)

أسهل طريقة للبدء مع nginx-ignition هي استخدام Docker:

```bash
# التثبيت الأساسي
docker run -p 8090:8090 -p 80:80 dillmann/nginx-ignition

# مع تخزين البيانات المستمر
docker run -d \
  --name nginx-ignition \
  -p 8090:8090 \
  -p 80:80 \
  -p 443:443 \
  -v nginx-ignition-data:/app/data \
  dillmann/nginx-ignition
```

### الطريقة 2: Docker Compose

لنشر الإنتاج، استخدم Docker Compose:

```yaml
version: '3.8'

services:
  nginx-ignition:
    image: dillmann/nginx-ignition
    container_name: nginx-ignition
    ports:
      - "8090:8090"  # واجهة الويب
      - "80:80"      # HTTP
      - "443:443"    # HTTPS
    volumes:
      - nginx-ignition-data:/app/data
      - ./config:/app/config
    environment:
      - DATABASE_TYPE=sqlite
      - LOG_LEVEL=info
    restart: unless-stopped

volumes:
  nginx-ignition-data:
```

احفظ هذا كـ `docker-compose.yml` وشغله:

```bash
docker-compose up -d
```

### الطريقة 3: التثبيت الأصلي

لأنظمة Linux أو macOS:

1. قم بتنزيل ملف ZIP المناسب من [صفحة الإصدارات](https://github.com/lucasdillmann/nginx-ignition/releases)
2. استخرج الأرشيف
3. اتبع تعليمات التثبيت المضمنة في ملف ZIP

## الإعداد الأولي

### الوصول الأول

1. افتح متصفحك وانتقل إلى `http://localhost:8090`
2. nginx-ignition سيرشدك خلال إنشاء حساب المستخدم الأول
3. لا توجد بيانات اعتماد افتراضية مطلوبة - ستقوم بإعداد مستخدم المدير أثناء الوصول الأول

### التكوين الأساسي

بعد تسجيل الدخول، قم بتكوين هذه الإعدادات الأساسية:

#### تكوين الخادم

انتقل إلى **الإعدادات** > **تكوين الخادم**:

- **الحد الأقصى لحجم الجسم**: تعيين حدود الرفع (افتراضي: 1MB)
- **رموز الخادم**: تعطيل للأمان (موصى به)
- **المهلات الزمنية**: تكوين مهلات العميل والمنبع
- **مستوى السجل**: تعيين مستوى التسجيل المناسب (info/debug/error)

#### تكوين SSL

لإدارة شهادات SSL:

1. اذهب إلى قسم **الشهادات**
2. اختر نوع الشهادة:
   - **Let's Encrypt**: SSL تلقائي مع التحقق من النطاق
   - **موقعة ذاتياً**: للتطوير/الاختبار
   - **مخصصة**: رفع شهاداتك الخاصة

## إنشاء أول مضيف افتراضي

### الخطوة 1: إضافة مضيف جديد

1. انتقل إلى قسم **المضيفات**
2. انقر على **إضافة مضيف جديد**
3. تكوين الإعدادات الأساسية:
   - **الاسم**: اسم وصفي للمضيف
   - **النطاقات**: أضف أسماء النطاقات (مثل `example.com`، `www.example.com`)
   - **مفعل**: ضع علامة لتفعيل المضيف

### الخطوة 2: تكوين الطرق

الطرق تحدد كيف يتعامل nginx مع مسارات URL المختلفة:

#### مثال طريق البروكسي

```yaml
المسار: /api
النوع: بروكسي
الهدف: http://backend-service:3000
الرؤوس:
  - X-Real-IP: $remote_addr
  - X-Forwarded-For: $proxy_add_x_forwarded_for
```

#### مثال طريق الملفات الثابتة

```yaml
المسار: /static
النوع: ملفات ثابتة
الدليل الجذر: /var/www/static
قائمة الدليل: مفعل
ملفات الفهرس: index.html, index.htm
```

#### مثال طريق إعادة التوجيه

```yaml
المسار: /old-path
النوع: إعادة توجيه
الهدف: /new-path
رمز الحالة: 301 (دائم)
```

### الخطوة 3: تكوين الربط

الربط يحدد المنافذ والبروتوكولات التي يستمع إليها المضيف:

1. **ربط HTTP**:
   - المنفذ: 80
   - البروتوكول: HTTP
   - IP: 0.0.0.0 (جميع الواجهات)

2. **ربط HTTPS**:
   - المنفذ: 443
   - البروتوكول: HTTPS
   - الشهادة: اختر من الشهادات المتاحة
   - IP: 0.0.0.0

## الميزات المتقدمة

### تكامل Docker

nginx-ignition يمكنه اكتشاف حاويات Docker تلقائياً:

1. فعل تكامل Docker في الإعدادات
2. تصفح الحاويات المتاحة في قسم **Docker**
3. اختر الحاويات كأهداف بروكسي مع اكتشاف الخدمة التلقائي

### بروكسي التدفق

لحركة غير HTTP (TCP/UDP):

1. انتقل إلى قسم **التدفقات**
2. أنشئ تكوين تدفق جديد:
   - **الربط**: المنفذ والبروتوكول للاستماع
   - **المنبع**: الخوادم المستهدفة مع توزيع الحمولة
   - **توجيه SNI**: توجيه قائم على النطاق لحركة TLS

### قوائم الوصول

التحكم في الوصول إلى خدماتك:

1. اذهب إلى قسم **قوائم الوصول**
2. أنشئ قواعد الوصول:
   - **قائم على IP**: السماح/المنع لنطاقات IP محددة
   - **المصادقة**: مصادقة HTTP أساسية
   - **مدمج**: متطلبات IP والمصادقة معاً

### تنفيذ كود مخصص

تنفيذ منطق مخصص في الطرق:

#### مثال JavaScript

```javascript
// توليد استجابة مخصصة
function handleRequest(request) {
    return {
        status: 200,
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            message: 'مرحباً من nginx-ignition',
            timestamp: new Date().toISOString()
        })
    };
}
```

#### مثال Lua

```lua
-- معالجة طلب مخصص
local json = require "cjson"

local response = {
    message = "مرحباً من Lua",
    client_ip = ngx.var.remote_addr,
    user_agent = ngx.var.http_user_agent
}

ngx.header.content_type = "application/json"
ngx.say(json.encode(response))
```

## تكوين الإنتاج

### تكوين قاعدة البيانات

للاستخدام في الإنتاج، قم بتكوين PostgreSQL بدلاً من SQLite:

```yaml
environment:
  - DATABASE_TYPE=postgresql
  - DATABASE_HOST=postgres
  - DATABASE_PORT=5432
  - DATABASE_NAME=nginx_ignition
  - DATABASE_USER=nginx_user
  - DATABASE_PASSWORD=secure_password
```

### أفضل الممارسات الأمنية

1. **تغيير المنافذ الافتراضية**: استخدم منافذ غير قياسية لواجهة الويب
2. **تفعيل HTTPS**: استخدم دائماً SSL لواجهة الإدارة
3. **التحديثات المنتظمة**: حافظ على nginx-ignition محدث لأحدث إصدار
4. **التحكم في الوصول**: تنفيذ أدوار وأذونات المستخدم المناسبة
5. **قواعد الجدار الناري**: قيد الوصول إلى منافذ الإدارة

### استراتيجية النسخ الاحتياطي

النسخ الاحتياطية المنتظمة ضرورية:

```bash
# نسخ احتياطي للتكوين والشهادات
docker exec nginx-ignition tar -czf /tmp/backup.tar.gz /app/data

# نسخ النسخة الاحتياطية من الحاوية
docker cp nginx-ignition:/tmp/backup.tar.gz ./nginx-ignition-backup-$(date +%Y%m%d).tar.gz
```

## المراقبة واستكشاف الأخطاء

### إدارة السجلات

nginx-ignition يوفر تسجيلاً شاملاً:

1. **سجلات الوصول**: مراقبة الطلبات الواردة
2. **سجلات الخطأ**: تشخيص مشاكل التكوين
3. **سجلات التطبيق**: سجلات nginx-ignition الداخلية

### المشاكل الشائعة والحلول

#### فشل تجديد الشهادة

```bash
# فحص حالة الشهادة
docker exec nginx-ignition nginx-ignition cert status

# إجبار تجديد الشهادة
docker exec nginx-ignition nginx-ignition cert renew --force
```

#### التحقق من التكوين

```bash
# اختبار تكوين nginx
docker exec nginx-ignition nginx -t

# إعادة تحميل التكوين
docker exec nginx-ignition nginx -s reload
```

#### مراقبة الأداء

راقب المقاييس الرئيسية:
- معدل الطلبات وأوقات الاستجابة
- تواريخ انتهاء صلاحية شهادات SSL
- صحة خوادم المنبع
- استخدام الموارد (CPU، الذاكرة، القرص)

## الترحيل والترقيات

### ترقية nginx-ignition

1. **نسخ احتياطي للتكوين الحالي**:
   ```bash
   docker exec nginx-ignition tar -czf /tmp/backup.tar.gz /app/data
   docker cp nginx-ignition:/tmp/backup.tar.gz ./backup.tar.gz
   ```

2. **إيقاف الحاوية الحالية**:
   ```bash
   docker stop nginx-ignition
   docker rm nginx-ignition
   ```

3. **سحب أحدث صورة**:
   ```bash
   docker pull dillmann/nginx-ignition:latest
   ```

4. **بدء حاوية جديدة**:
   ```bash
   docker run -d \
     --name nginx-ignition \
     -p 8090:8090 -p 80:80 -p 443:443 \
     -v nginx-ignition-data:/app/data \
     dillmann/nginx-ignition:latest
   ```

### الترحيل من 1.x إلى 2.0.0

إذا كنت تقوم بالترقية من الإصدار 1.x، راجع [دليل الترحيل](https://github.com/lucasdillmann/nginx-ignition/blob/main/docs/migration.md) للتغييرات الجذرية وخطوات الترحيل.

## أفضل الممارسات

### إدارة التكوين

1. **استخدم التحكم في الإصدار**: احفظ النسخ الاحتياطية للتكوين في Git
2. **فصل البيئات**: فصل تكوينات التطوير والاختبار والإنتاج
3. **التوثيق**: وثق التكوينات المخصصة وقواعد العمل
4. **الاختبار**: اختبر تغييرات التكوين في بيئات غير الإنتاج

### تحسين الأداء

1. **تفعيل التخزين المؤقت**: تكوين رؤوس التخزين المؤقت المناسبة
2. **الضغط**: تفعيل ضغط gzip للمحتوى النصي
3. **تجميع الاتصالات**: تحسين اتصالات المنبع
4. **تحديد المعدل**: تنفيذ تحديد المعدل لنقاط النهاية API

### تعزيز الأمان

1. **التحديثات المنتظمة**: حافظ على جميع المكونات محدثة
2. **الأذونات الدنيا**: استخدم مبادئ الوصول بأقل امتياز
3. **تقسيم الشبكة**: عزل nginx-ignition في شرائح شبكة آمنة
4. **تسجيل المراجعة**: تفعيل تسجيل المراجعة الشامل

## الخلاصة

nginx-ignition يوفر طريقة قوية وسهلة الاستخدام لإدارة خوادم nginx دون الغوص في ملفات التكوين المعقدة. واجهته القائمة على الويب، مع ميزات مثل إدارة شهادات SSL وتكامل Docker والتحكم في الوصول، تجعله خياراً ممتازاً للمطورين ومديري الأنظمة.

الأداة تحقق توازناً بين البساطة والوظائف، مما يجعل إدارة nginx في متناول الجميع مع توفير المرونة المطلوبة لمعظم حالات الاستخدام. سواء كنت تدير خادم ويب بسيط أو بنية خدمات مصغرة معقدة، nginx-ignition يمكن أن يساعد في تبسيط سير عمل تكوين وإدارة nginx.

## موارد إضافية

- **المستودع الرسمي**: [nginx-ignition على GitHub](https://github.com/lucasdillmann/nginx-ignition)
- **التوثيق**: [دليل التكوين](https://github.com/lucasdillmann/nginx-ignition/blob/main/docs/configuration.md)
- **استكشاف الأخطاء**: [المشاكل الشائعة](https://github.com/lucasdillmann/nginx-ignition/blob/main/docs/troubleshooting.md)
- **المجتمع**: [مناقشات GitHub](https://github.com/lucasdillmann/nginx-ignition/discussions)

ابدأ رحلتك مع nginx-ignition اليوم واختبر سهولة الإدارة المرئية لـ nginx!
