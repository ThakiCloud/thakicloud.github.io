---
title: "ConvertX: محول الملفات المستضاف ذاتياً - دليل الإعداد والاستخدام الشامل"
excerpt: "تعلم كيفية نشر واستخدام ConvertX، محول الملفات القوي المستضاف ذاتياً الذي يدعم أكثر من 1000 تنسيق باستخدام Docker. مثالي للمستخدمين والمؤسسات التي تهتم بالخصوصية."
seo_title: "دروس محول الملفات ConvertX المستضاف ذاتياً - دليل شامل - Thaki Cloud"
seo_description: "دليل خطوة بخطوة لنشر ConvertX مع Docker. محول ملفات مستضاف ذاتياً يدعم أكثر من 1000 تنسيق بما في ذلك الصور والفيديو والمستندات والأصول ثلاثية الأبعاد."
date: 2025-09-25
categories:
  - tutorials
tags:
  - docker
  - file-converter
  - self-hosted
  - typescript
  - privacy
author_profile: true
toc: true
toc_label: "جدول المحتويات"
lang: ar
permalink: /ar/tutorials/convertx-self-hosted-file-converter-complete-guide/
canonical_url: "https://thakicloud.github.io/ar/tutorials/convertx-self-hosted-file-converter-complete-guide/"
---

⏱️ **وقت القراءة المتوقع**: 8 دقائق

## مقدمة

في عالمنا الرقمي اليوم، تحويل تنسيقات الملفات ضرورة شائعة. سواء كنت تتعامل مع الصور أو الفيديوهات أو المستندات أو الأصول ثلاثية الأبعاد، فإن وجود محول موثوق أمر ضروري. بينما توجد حلول قائمة على السحابة، فإنها غالباً ما تثير مخاوف الخصوصية وقد تحتوي على قيود على أحجام الملفات أو حصص الاستخدام.

[ConvertX](https://github.com/C4illin/ConvertX) يقدم حلاً أنيقاً: محول ملفات مستضاف ذاتياً يدعم أكثر من 1000 تنسيق مختلف. مبني بـ TypeScript و Bun و Elysia، يمنحك ConvertX السيطرة الكاملة على بياناتك مع توفير قدرات تحويل بمستوى المؤسسة.

## ما هو ConvertX؟

ConvertX هو منصة تحويل ملفات مستضافة ذاتياً ومفتوحة المصدر تعمل بالكامل على البنية التحتية الخاصة بك. مع دعم تنسيقات ملفات متعددة عبر فئات مختلفة، فهو مصمم ليكون قوياً ويركز على الخصوصية.

### الميزات الرئيسية

- **دعم واسع للتنسيقات**: أكثر من 1000 تنسيق ملف مختلف
- **المعالجة المجمعة**: تحويل ملفات متعددة في وقت واحد
- **حماية الخصوصية**: حماية بكلمة مرور ومصادقة المستخدم
- **دعم متعدد المستخدمين**: حسابات متعددة مع عزل مناسب
- **معمارية حديثة**: مبني بـ TypeScript وتقنيات الويب الحديثة
- **جاهز لـ Docker**: نشر سهل مع Docker و Docker Compose

### المحولات المدعومة

يدمج ConvertX محولات متخصصة متعددة للتعامل مع أنواع ملفات مختلفة:

| المحول | حالة الاستخدام | تنسيقات الإدخال | تنسيقات الإخراج |
|---------|---------------|-------------------|-------------------|
| **FFmpeg** | فيديو/صوت | ~472 | ~199 |
| **ImageMagick** | صور | 245 | 183 |
| **GraphicsMagick** | صور | 167 | 130 |
| **Assimp** | أصول ثلاثية الأبعاد | 77 | 23 |
| **Pandoc** | مستندات | 43 | 65 |
| **Vips** | صور | 45 | 23 |
| **Calibre** | كتب إلكترونية | 26 | 19 |
| **Inkscape** | رسوميات متجهة | 7 | 17 |
| **libjxl** | JPEG XL | 11 | 11 |
| **Potrace** | نقطية إلى متجهة | 4 | 11 |

## المتطلبات المسبقة

قبل نشر ConvertX، تأكد من توفر:

- **Docker** (الإصدار 20.10 أو أحدث)
- **Docker Compose** (الإصدار 2.0 أو أحدث)
- **خادم بموارد كافية**:
  - الحد الأدنى: 2GB RAM، نواة معالج واحدة
  - مستحسن: 4GB RAM، نواتان أو أكثر
  - التخزين: 10GB على الأقل من المساحة الحرة للملفات والحاويات

## التثبيت والإعداد

### الطريقة الأولى: Docker Compose (مستحسن)

إنشاء دليل المشروع وإعداد التكوين:

```bash
# إنشاء دليل المشروع
mkdir convertx-app
cd convertx-app

# إنشاء ملف Docker Compose
cat > docker-compose.yml << 'EOF'
services:
  convertx:
    image: ghcr.io/c4illin/convertx
    container_name: convertx
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      - JWT_SECRET=aLongAndSecretStringUsedToSignTheJSONWebToken1234567890
      - ACCOUNT_REGISTRATION=false
      - AUTO_DELETE_EVERY_N_HOURS=24
      - LANGUAGE=ar
      # إلغاء التعليق في حالة الوصول عبر HTTP (غير مستحسن للإنتاج)
      # - HTTP_ALLOWED=true
    volumes:
      - ./data:/app/data
    labels:
      - "com.docker.compose.project=convertx"
EOF

# إنشاء دليل البيانات بالأذونات المناسبة
mkdir -p data
sudo chown -R $USER:$USER data
```

### الطريقة الثانية: Docker Run

للبدء السريع بدون Docker Compose:

```bash
# إنشاء دليل البيانات
mkdir -p ~/convertx-data

# تشغيل حاوية ConvertX
docker run -d \
  --name convertx \
  --restart unless-stopped \
  -p 3000:3000 \
  -v ~/convertx-data:/app/data \
  -e JWT_SECRET=aLongAndSecretStringUsedToSignTheJSONWebToken1234567890 \
  -e ACCOUNT_REGISTRATION=false \
  -e AUTO_DELETE_EVERY_N_HOURS=24 \
  -e LANGUAGE=ar \
  ghcr.io/c4illin/convertx
```

### النشر

نشر التطبيق:

```bash
# استخدام Docker Compose
docker-compose up -d

# التحقق من تشغيل الحاوية
docker-compose ps

# فحص السجلات
docker-compose logs -f convertx
```

## التكوين الأولي

### 1. الوصول إلى التطبيق

افتح متصفح الويب وانتقل إلى:
- **الوصول المحلي**: `http://localhost:3000`
- **الوصول البعيد**: `https://your-domain.com:3000` (HTTPS مستحسن)

### 2. إنشاء حساب المدير

1. في الوصول الأول، ستظهر صفحة التسجيل
2. أنشئ حساب المدير بكلمة مرور قوية
3. **مهم**: قم بتعطيل التسجيل بعد إنشاء حسابك بتعيين `ACCOUNT_REGISTRATION=false`

### 3. تكوين إعدادات الأمان

للنشر في الإنتاج، فكر في هذه التحسينات الأمنية:

```yaml
# docker-compose.yml محسن
services:
  convertx:
    image: ghcr.io/c4illin/convertx
    container_name: convertx
    restart: unless-stopped
    ports:
      - "127.0.0.1:3000:3000"  # ربط بـ localhost فقط
    environment:
      - JWT_SECRET=${JWT_SECRET}  # استخدام متغير البيئة
      - ACCOUNT_REGISTRATION=false
      - HTTP_ALLOWED=false  # إجبار HTTPS
      - AUTO_DELETE_EVERY_N_HOURS=12  # تنظيف الملفات بشكل أكثر تكراراً
      - HIDE_HISTORY=false
      - LANGUAGE=ar
    volumes:
      - ./data:/app/data
      - /etc/localtime:/etc/localtime:ro  # مزامنة المنطقة الزمنية
    networks:
      - convertx-network

networks:
  convertx-network:
    driver: bridge
```

## دليل الاستخدام

### تحويل الملفات الأساسي

1. **رفع الملفات**:
   - انقر على "اختر الملفات" أو السحب والإفلات
   - اختر ملف واحد أو ملفات متعددة
   - يتم الكشف عن التنسيقات المدعومة تلقائياً

2. **اختيار تنسيق الإخراج**:
   - اختر التنسيق المطلوب من القائمة المنسدلة
   - التنسيقات مصنفة حسب النوع (صورة، فيديو، مستند، إلخ)

3. **تكوين الإعدادات** (إن أمكن):
   - إعدادات الجودة للصور/الفيديوهات
   - خيارات الضغط
   - إعدادات الدقة

4. **بدء التحويل**:
   - انقر على "تحويل" لبدء المعالجة
   - راقب التقدم في الوقت الفعلي
   - قم بتنزيل النتائج عند الانتهاء

### الميزات المتقدمة

#### المعالجة المجمعة

يتفوق ConvertX في معالجة ملفات متعددة:

```bash
# مثال: تحويل صور متعددة
# رفع: image1.png, image2.jpg, image3.bmp
# تنسيق الإخراج: WebP
# النتيجة: جميع الصور محولة إلى تنسيق WebP
```

#### حماية كلمة المرور

حماية الملفات الحساسة أثناء التحويل:

1. تفعيل حماية كلمة المرور في الإعدادات
2. تعيين كلمة مرور التحويل
3. مشاركة كلمة المرور بأمان مع المستخدمين المخولين

#### وسائط FFmpeg المخصصة

للمعالجة المتقدمة للفيديو، يمكنك تكوين وسائط FFmpeg مخصصة:

```yaml
environment:
  - FFMPEG_ARGS=-preset veryfast -crf 23
```

### حالات الاستخدام العملية

#### 1. تحسين الصور للويب

```bash
# تحويل وتحسين الصور للاستخدام على الويب
الإدخال: high-resolution.jpg (5MB)
الإخراج: optimized.webp (500KB)
الإعدادات: تنسيق WebP، جودة 80%
```

#### 2. ترحيل تنسيق المستندات

```bash
# تحويل المستندات القديمة
الإدخال: old-document.doc
الإخراج: modern-document.pdf
المحول: Pandoc
```

#### 3. ضغط الفيديو

```bash
# ضغط ملفات الفيديو
الإدخال: large-video.mov (1GB)
الإخراج: compressed-video.mp4 (200MB)
المحول: FFmpeg مع كودك H.264
```

#### 4. معالجة الأصول ثلاثية الأبعاد

```bash
# تحويل النماذج ثلاثية الأبعاد بين التنسيقات
الإدخال: model.fbx
الإخراج: model.glb
المحول: Assimp
```

## مرجع متغيرات البيئة

خصص سلوك ConvertX بهذه متغيرات البيئة:

| المتغير | الافتراضي | الوصف |
|---------|------------|-------|
| `JWT_SECRET` | Random UUID | مفتاح سري لتوقيع رمز JWT |
| `ACCOUNT_REGISTRATION` | `false` | السماح بتسجيل مستخدم جديد |
| `HTTP_ALLOWED` | `false` | السماح بالاتصالات HTTP (للاستخدام محلياً فقط) |
| `ALLOW_UNAUTHENTICATED` | `false` | السماح بالاستخدام المجهول |
| `AUTO_DELETE_EVERY_N_HOURS` | `24` | فترة تنظيف الملفات التلقائي |
| `WEBROOT` | `/` | مسار جذر تطبيق الويب |
| `FFMPEG_ARGS` | لا شيء | وسائط FFmpeg مخصصة |
| `HIDE_HISTORY` | `false` | إخفاء تاريخ التحويل |
| `LANGUAGE` | `en` | لغة الواجهة (تنسيق BCP 47) |
| `UNAUTHENTICATED_USER_SHARING` | `false` | مشاركة التاريخ بين المستخدمين المجهولين |

## المراقبة والصيانة

### فحوصات الحالة

راقب حالة ConvertX:

```bash
# فحص حالة الحاوية
docker-compose ps

# عرض السجلات في الوقت الفعلي
docker-compose logs -f convertx

# فحص استخدام الموارد
docker stats convertx
```

### استراتيجية النسخ الاحتياطي

احم بياناتك بالنسخ الاحتياطي المنتظم:

```bash
#!/bin/bash
# backup-convertx.sh

BACKUP_DIR="/backup/convertx"
DATA_DIR="./data"
DATE=$(date +%Y%m%d_%H%M%S)

# إنشاء دليل النسخ الاحتياطي
mkdir -p "$BACKUP_DIR"

# نسخ احتياطي لدليل البيانات
tar -czf "$BACKUP_DIR/convertx_data_$DATE.tar.gz" -C "$DATA_DIR" .

# الاحتفاظ بآخر 7 نسخ احتياطية فقط
find "$BACKUP_DIR" -name "convertx_data_*.tar.gz" -mtime +7 -delete

echo "اكتمل النسخ الاحتياطي: convertx_data_$DATE.tar.gz"
```

### التحديثات

حافظ على ConvertX محدثاً:

```bash
# التحديث إلى أحدث إصدار
docker-compose pull
docker-compose up -d

# فحص الإصدار
docker exec convertx cat /app/package.json | grep version
```

## استكشاف الأخطاء وإصلاحها

### المشاكل الشائعة

#### 1. أخطاء الأذونات

```bash
# إصلاح أذونات دليل البيانات
sudo chown -R $USER:$USER ./data
chmod -R 755 ./data
```

#### 2. مشاكل تسجيل الدخول

إذا كنت لا تستطيع تسجيل الدخول:
- تأكد من الوصول عبر HTTPS أو localhost
- تعيين `HTTP_ALLOWED=true` للوصول HTTP (غير مستحسن للإنتاج)

#### 3. فشل التحويل

فحص السجلات لرسائل خطأ محددة:

```bash
# عرض السجلات التفصيلية
docker-compose logs --tail=50 convertx

# فحص موارد الحاوية
docker stats convertx
```

#### 4. حدود رفع الملفات

قد تفشل رفع الملفات الكبيرة. فحص:
- مساحة القرص المتاحة
- حدود ذاكرة الحاوية
- إعدادات انتهاء مهلة الشبكة

### تحسين الأداء

#### تخصيص الموارد

للاستخدام المكثف، اضبط حدود موارد Docker:

```yaml
services:
  convertx:
    # ... تكوين آخر
    deploy:
      resources:
        limits:
          memory: 4G
          cpus: '2'
        reservations:
          memory: 2G
          cpus: '1'
```

#### تحسين التخزين

تكوين التنظيف التلقائي:

```yaml
environment:
  - AUTO_DELETE_EVERY_N_HOURS=6  # تنظيف كل 6 ساعات
```

## أفضل ممارسات الأمان

### 1. أمان الشبكة

استخدم بروكسي عكسي للإنتاج:

```nginx
# مثال تكوين Nginx
server {
    listen 443 ssl http2;
    server_name convert.yourdomain.com;
    
    ssl_certificate /path/to/certificate.crt;
    ssl_certificate_key /path/to/private.key;
    
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # حد حجم رفع الملفات
        client_max_body_size 100M;
    }
}
```

### 2. التحكم في الوصول

تنفيذ طبقات أمان إضافية:

```yaml
# استخدام تسميات Traefik للمصادقة
labels:
  - "traefik.http.middlewares.convertx-auth.basicauth.users=admin:$$2y$$10$$..."
  - "traefik.http.routers.convertx.middlewares=convertx-auth"
```

### 3. تحديثات الأمان المنتظمة

```bash
# تحديث ConvertX بانتظام
docker-compose pull && docker-compose up -d

# تحديث النظام الأساسي
sudo apt update && sudo apt upgrade -y
```

## الخلاصة

يوفر ConvertX حلاً قوياً ومستضافاً ذاتياً لاحتياجات تحويل الملفات. مع دعمه الواسع للتنسيقات وتصميمه المركز على الخصوصية ونشر Docker السهل، فهو خيار ممتاز للاستخدام الشخصي والمؤسسي على حد سواء.

تكمن قوة المنصة في مزيجها من قدرات التحويل القوية والتحكم المستخدم. من خلال استضافتها بنفسك، تحافظ على الخصوصية الكاملة لملفاتك بينما تستفيد من أدوات التحويل ذات المستوى المهني.

سواء كنت تعالج صوراً لموقع ويب، أو تحول مستندات للأرشفة، أو تتعامل مع محتوى متعدد الوسائط، يقدم ConvertX المرونة والموثوقية المطلوبة لتدفقات عمل تحويل الملفات الحديثة.

## موارد إضافية

- **المستودع الرسمي**: [https://github.com/C4illin/ConvertX](https://github.com/C4illin/ConvertX)
- **Docker Hub**: [https://hub.docker.com/r/c4illin/convertx](https://hub.docker.com/r/c4illin/convertx)
- **سجل حاويات GitHub**: [https://ghcr.io/c4illin/convertx](https://ghcr.io/c4illin/convertx)
- **متتبع المشاكل**: [https://github.com/C4illin/ConvertX/issues](https://github.com/C4illin/ConvertX/issues)

---

*يغطي هذا الدليل الجوانب الأساسية لنشر واستخدام ConvertX. لحالات استخدام محددة أو تكوينات متقدمة، راجع الوثائق الرسمية أو مناقشات المجتمع.*
