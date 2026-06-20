---
title: "حاويات MCP: دليل شامل لتكامل وكلاء الذكاء الاصطناعي مع Docker"
excerpt: "تعلم كيفية الاستفادة من حاويات MCP لتطوير وكلاء الذكاء الاصطناعي بسهولة باستخدام مئات خوادم بروتوكول سياق النموذج المبنية مسبقاً في حاويات Docker."
seo_title: "دورة حاويات MCP: دليل تطوير وكلاء الذكاء الاصطناعي بـ Docker"
seo_description: "دورة شاملة حول استخدام حاويات MCP لتطوير وكلاء الذكاء الاصطناعي. تعلم دمج مئات خوادم MCP مع Docker لبناء تدفقات عمل ذكية."
date: 2025-09-19
categories:
  - tutorials
tags:
  - mcp
  - docker
  - ai-agents
  - model-context-protocol
  - containerization
  - automation
author_profile: true
toc: true
toc_label: "فهرس المحتويات"
lang: ar
permalink: /ar/tutorials/mcp-containers-comprehensive-tutorial/
canonical_url: "https://thakicloud.github.io/ar/tutorials/mcp-containers-comprehensive-tutorial/"
published: false
---

⏱️ **وقت القراءة المتوقع**: 15 دقيقة

## مقدمة

لقد أحدث **بروتوكول سياق النموذج (MCP)** ثورة في كيفية تفاعل وكلاء الذكاء الاصطناعي مع الأنظمة الخارجية ومصادر البيانات. ومع ذلك، فإن إعداد خوادم MCP الفردية يمكن أن يكون معقداً ويستغرق وقتاً طويلاً. تحل **حاويات MCP** من Metorial هذا التحدي من خلال توفير إصدارات محاويّة من مئات خوادم MCP، مما يجعل دمج القدرات القوية للذكاء الاصطناعي في تطبيقاتك أمراً بسيطاً للغاية.

في هذا الدليل الشامل، سنستكشف كيفية استخدام حاويات MCP لبناء وكلاء ذكاء اصطناعي متطورين يمكنها التفاعل مع قواعد البيانات وواجهات برمجة التطبيقات وأنظمة الملفات وأكثر من ذلك بكثير - كل ذلك من خلال حاويات Docker.

## ما هو MCP وحاويات MCP؟

### فهم بروتوكول سياق النموذج

بروتوكول سياق النموذج (MCP) هو معيار مفتوح يمكّن نماذج الذكاء الاصطناعي من الاتصال بأمان بمصادر البيانات والأدوات الخارجية. يوفر طريقة موحدة لوكلاء الذكاء الاصطناعي للقيام بما يلي:

- الوصول إلى قواعد البيانات وواجهات برمجة التطبيقات
- التفاعل مع أنظمة الملفات
- تنفيذ الأوامر بأمان
- معالجة تنسيقات البيانات المختلفة
- التكامل مع خدمات الطرف الثالث

### التحدي مع إعداد MCP التقليدي

ينطوي إعداد خوادم MCP التقليدية على:
- إدارة معقدة للتبعيات
- تكوين البيئة
- اعتبارات الأمان
- مشاكل توافق الإصدارات
- عمليات إعداد تستغرق وقتاً طويلاً

### حل حاويات MCP

تعالج حاويات MCP هذه التحديات من خلال توفير:
- **🚀 إعداد بسيط**: فقط قم بتحميل صورة Docker
- **🛠️ دائماً محدث**: يتم التحديث تلقائياً يومياً
- **🔒 آمن**: تنفيذ منعزل للحاويات
- **📦 شامل**: مئات الخوادم المبنية مسبقاً

## المتطلبات الأساسية

قبل أن نبدأ، تأكد من توفر ما يلي:

- Docker مثبت وقيد التشغيل
- فهم أساسي لأوامر Docker
- إلمام بمفاهيم الذكاء الاصطناعي/LLM
- محرر نصوص أو IDE
- الوصول إلى الطرفية/سطر الأوامر

## البدء مع حاويات MCP

### الخطوة 1: الاستخدام الأساسي للحاوية

النمط الأساسي لاستخدام حاويات MCP بسيط:

```bash
# الصيغة الأساسية
docker run -it ghcr.io/metorial/mcp-containers:{اسم-الخادم}

# مثال: تشغيل خادم نظام الملفات
docker run -it -v $(pwd):/workspace ghcr.io/metorial/mcp-containers:filesystem
```

### الخطوة 2: فهم هندسة الحاوية

تتبع كل حاوية MCP هيكلاً متسقاً:

```yaml
هيكل الحاوية:
├── تطبيق خادم MCP
├── التبعيات المطلوبة
├── تكوين الأمان
├── واجهة الإدخال/الإخراج المعيارية
└── معالجة الأخطاء
```

## أمثلة عملية

### مثال 1: تكامل نظام الملفات

لنبدأ بمثال عملي باستخدام خادم MCP لنظام الملفات:

```bash
# إنشاء دليل عمل
mkdir mcp-demo
cd mcp-demo

# إنشاء ملفات عينة
echo "مرحباً بعالم MCP!" > sample.txt
echo "هذا ملف تجريبي." > test.txt

# تشغيل خادم MCP لنظام الملفات
docker run -it -v $(pwd):/workspace ghcr.io/metorial/mcp-containers:filesystem
```

**حالات الاستخدام:**
- تحليل محتوى الملفات
- معالجة المستندات الآلية
- مراجعة وتحليل الكود
- استخراج البيانات من المستندات

### مثال 2: تكامل قاعدة البيانات

لعمليات قاعدة البيانات، دعنا نستخدم خادم MCP لـ SQLite:

```bash
# إنشاء قاعدة بيانات SQLite عينة
sqlite3 demo.db "CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT, email TEXT);"
sqlite3 demo.db "INSERT INTO users (name, email) VALUES ('أحمد محمد', 'ahmed@example.com');"

# تشغيل خادم MCP لـ SQLite
docker run -it -v $(pwd):/workspace ghcr.io/metorial/mcp-containers:sqlite
```

**القدرات:**
- تنفيذ الاستعلامات
- تحليل البيانات
- إنتاج التقارير
- استكشاف مخطط قاعدة البيانات

### مثال 3: التكامل مع الويب باستخدام Brave Search

لقدرات البحث على الويب:

```bash
# تعيين متغير البيئة لمفتاح API
export BRAVE_API_KEY="your_brave_api_key_here"

# تشغيل خادم MCP لبحث Brave
docker run -it -e BRAVE_API_KEY=${BRAVE_API_KEY} ghcr.io/metorial/mcp-containers:brave-search
```

**الميزات:**
- البحث على الويب في الوقت الفعلي
- جمع المعلومات
- أتمتة البحث
- اكتشاف المحتوى

## التكوين المتقدم

### متغيرات البيئة والأسرار

تتطلب العديد من خوادم MCP تكويناً من خلال متغيرات البيئة:

```bash
# مثال مع متغيرات بيئة متعددة
docker run -it \
  -e API_KEY="your_api_key" \
  -e BASE_URL="https://api.example.com" \
  -e TIMEOUT="30" \
  ghcr.io/metorial/mcp-containers:your-server
```

### استراتيجيات تركيب الأحجام

استراتيجيات تركيب مختلفة لحالات استخدام متنوعة:

```bash
# الوصول للقراءة فقط
docker run -it -v $(pwd):/workspace:ro ghcr.io/metorial/mcp-containers:filesystem

# تركيب دليل محدد
docker run -it -v /path/to/data:/data ghcr.io/metorial/mcp-containers:server

# تركيب أحجام متعددة
docker run -it \
  -v $(pwd)/input:/input:ro \
  -v $(pwd)/output:/output \
  ghcr.io/metorial/mcp-containers:processor
```

### تكوين الشبكة

للخوادم التي تتطلب الوصول إلى الشبكة:

```bash
# شبكة مخصصة
docker network create mcp-network
docker run -it --network mcp-network ghcr.io/metorial/mcp-containers:server

# تعيين المنافذ (إذا لزم الأمر)
docker run -it -p 8080:8080 ghcr.io/metorial/mcp-containers:web-server
```

## خوادم MCP الشائعة وحالات الاستخدام

### التطوير والـ DevOps

1. **تكامل GitHub**
   ```bash
   docker run -it -e GITHUB_TOKEN="your_token" ghcr.io/metorial/mcp-containers:github
   ```
   - إدارة المستودعات
   - تتبع المشاكل
   - أتمتة طلبات السحب

2. **إدارة Kubernetes**
   ```bash
   docker run -it -v ~/.kube:/root/.kube:ro ghcr.io/metorial/mcp-containers:mcp-k8s-eye
   ```
   - مراقبة العنقود
   - تحليل أحمال العمل
   - إدارة الموارد

### معالجة البيانات

1. **عمليات Pandas**
   ```bash
   docker run -it -v $(pwd):/workspace ghcr.io/metorial/mcp-containers:pandas
   ```
   - تحليل البيانات
   - معالجة CSV
   - العمليات الإحصائية

2. **معالجة PDF**
   ```bash
   docker run -it -v $(pwd):/workspace ghcr.io/metorial/mcp-containers:mcp-pandoc
   ```
   - تحويل المستندات
   - استخراج النصوص
   - تحويل التنسيقات

### التواصل والإنتاجية

1. **تكامل Slack**
   ```bash
   docker run -it -e SLACK_BOT_TOKEN="your_token" ghcr.io/metorial/mcp-containers:slack
   ```
   - أتمتة الرسائل
   - إدارة القنوات
   - أنظمة الإشعارات

2. **Google Calendar**
   ```bash
   docker run -it -e GOOGLE_CREDENTIALS="path_to_creds" ghcr.io/metorial/mcp-containers:google-calendar
   ```
   - جدولة الأحداث
   - تنسيق الاجتماعات
   - تحليل التقويم

## بناء تدفقات عمل مخصصة

### إنشاء تكوينات Docker Compose

للتدفقات المعقدة التي تتضمن خوادم MCP متعددة:

```yaml
# docker-compose.yml
version: '3.8'

services:
  filesystem:
    image: ghcr.io/metorial/mcp-containers:filesystem
    volumes:
      - ./data:/workspace
    
  database:
    image: ghcr.io/metorial/mcp-containers:sqlite
    volumes:
      - ./db:/workspace
    
  web-search:
    image: ghcr.io/metorial/mcp-containers:brave-search
    environment:
      - BRAVE_API_KEY=${BRAVE_API_KEY}

networks:
  mcp-network:
    driver: bridge
```

### خط أنابيب المعالجة التسلسلية

إنشاء سكريبتات تربط عمليات MCP متعددة:

```bash
#!/bin/bash
# mcp-pipeline.sh

# الخطوة 1: جلب البيانات من الويب
docker run --rm -e API_KEY="$API_KEY" \
  -v $(pwd)/output:/output \
  ghcr.io/metorial/mcp-containers:web-scraper

# الخطوة 2: المعالجة باستخدام pandas
docker run --rm \
  -v $(pwd)/output:/workspace \
  ghcr.io/metorial/mcp-containers:pandas

# الخطوة 3: الحفظ في قاعدة البيانات
docker run --rm \
  -v $(pwd)/output:/workspace \
  -v $(pwd)/db:/db \
  ghcr.io/metorial/mcp-containers:sqlite
```

## أفضل الممارسات الأمنية

### أمان الحاوية

1. **التشغيل بأقل الصلاحيات**:
   ```bash
   docker run --user $(id -u):$(id -g) -it ghcr.io/metorial/mcp-containers:server
   ```

2. **استخدام أنظمة ملفات للقراءة فقط عند الإمكان**:
   ```bash
   docker run --read-only -it ghcr.io/metorial/mcp-containers:server
   ```

3. **تحديد استخدام الموارد**:
   ```bash
   docker run --memory=512m --cpus=1.0 -it ghcr.io/metorial/mcp-containers:server
   ```

### إدارة الأسرار

1. **استخدام ملفات البيئة**:
   ```bash
   # إنشاء ملف .env
   echo "API_KEY=your_secret_key" > .env
   
   # التشغيل مع ملف env
   docker run --env-file .env -it ghcr.io/metorial/mcp-containers:server
   ```

2. **أسرار Docker** (في وضع السرب):
   ```bash
   echo "secret_value" | docker secret create api_key -
   docker service create --secret api_key ghcr.io/metorial/mcp-containers:server
   ```

## استكشاف الأخطاء وإصلاحها

### مشاكل الاتصال

1. **اتصال الشبكة**:
   ```bash
   # اختبار الوصول للشبكة
   docker run --rm ghcr.io/metorial/mcp-containers:server ping google.com
   ```

2. **حل DNS**:
   ```bash
   # استخدام DNS مخصص
   docker run --dns 8.8.8.8 -it ghcr.io/metorial/mcp-containers:server
   ```

### مشاكل الصلاحيات

1. **مشاكل الوصول للملفات**:
   ```bash
   # فحص صلاحيات الملفات
   ls -la mounted_directory/
   
   # إصلاح الصلاحيات
   chmod 755 mounted_directory/
   sudo chown $(id -u):$(id -g) mounted_directory/
   ```

2. **تعيين مستخدم الحاوية**:
   ```bash
   # التشغيل كمستخدم حالي
   docker run --user $(id -u):$(id -g) -it ghcr.io/metorial/mcp-containers:server
   ```

### قيود الموارد

1. **مشاكل الذاكرة**:
   ```bash
   # زيادة حد الذاكرة
   docker run --memory=2g -it ghcr.io/metorial/mcp-containers:server
   ```

2. **مشاكل التخزين**:
   ```bash
   # تنظيف مساحة Docker
   docker system prune -a
   docker volume prune
   ```

## تحسين الأداء

### كفاءة الحاوية

1. **تحسين طبقات الصورة**:
   ```bash
   # تحميل أحدث إصدار
   docker pull ghcr.io/metorial/mcp-containers:server
   
   # إزالة الصور غير المستخدمة
   docker image prune
   ```

2. **تخصيص الموارد**:
   ```bash
   # تخصيص أمثل للموارد
   docker run \
     --cpus=2.0 \
     --memory=1g \
     --memory-swap=2g \
     -it ghcr.io/metorial/mcp-containers:server
   ```

### استراتيجيات التخزين المؤقت

1. **تخزين مؤقت للأحجام**:
   ```bash
   # إنشاء حجم مسمى للتخزين المؤقت
   docker volume create mcp-cache
   docker run -v mcp-cache:/cache -it ghcr.io/metorial/mcp-containers:server
   ```

2. **أحجام البيانات المشتركة**:
   ```bash
   # مشاركة البيانات بين الحاويات
   docker run -v shared-data:/data --name container1 ghcr.io/metorial/mcp-containers:server1
   docker run -v shared-data:/data --name container2 ghcr.io/metorial/mcp-containers:server2
   ```

## أنماط التكامل المتقدمة

### هندسة الخدمات المصغرة

هيكلة خوادم MCP كخدمات مصغرة:

```yaml
# docker-compose.microservices.yml
version: '3.8'

services:
  data-ingestion:
    image: ghcr.io/metorial/mcp-containers:web-scraper
    environment:
      - SERVICE_NAME=data-ingestion
    networks:
      - mcp-network
  
  data-processing:
    image: ghcr.io/metorial/mcp-containers:pandas
    depends_on:
      - data-ingestion
    networks:
      - mcp-network
  
  data-storage:
    image: ghcr.io/metorial/mcp-containers:sqlite
    depends_on:
      - data-processing
    volumes:
      - database:/db
    networks:
      - mcp-network

volumes:
  database:

networks:
  mcp-network:
    driver: bridge
```

### الهندسة المبنية على الأحداث

تنفيذ تدفقات عمل مبنية على الأحداث:

```bash
#!/bin/bash
# event-driven-mcp.sh

# مراقبة تغييرات الملفات وتشغيل المعالجة
inotifywait -m /watch/directory -e create -e modify |
while read path action file; do
    echo "الملف $file تم $action"
    
    # تشغيل معالجة MCP
    docker run --rm \
      -v "$path:/input" \
      -v ./output:/output \
      ghcr.io/metorial/mcp-containers:processor
done
```

## المراقبة والتسجيل

### مراقبة الحاوية

1. **مراقبة الموارد**:
   ```bash
   # مراقبة إحصائيات الحاوية
   docker stats $(docker ps --format "table {% raw %}{{.Names}}{% endraw %}" | grep mcp)
   ```

2. **فحوصات الصحة**:
   ```bash
   # إضافة فحص صحة
   docker run \
     --health-cmd="curl -f http://localhost:8080/health || exit 1" \
     --health-interval=30s \
     --health-timeout=10s \
     --health-retries=3 \
     -it ghcr.io/metorial/mcp-containers:server
   ```

### التسجيل المركزي

1. **تجميع السجلات**:
   ```yaml
   # docker-compose.logging.yml
   version: '3.8'
   
   services:
     mcp-server:
       image: ghcr.io/metorial/mcp-containers:server
       logging:
         driver: "json-file"
         options:
           max-size: "10m"
           max-file: "3"
   ```

2. **إدارة السجلات الخارجية**:
   ```bash
   # إرسال السجلات لنظام خارجي
   docker run \
     --log-driver=syslog \
     --log-opt syslog-address=tcp://log-server:514 \
     -it ghcr.io/metorial/mcp-containers:server
   ```

## حالات الاستخدام الواقعية

### دراسة حالة 1: خط أنابيب المحتوى الآلي

**السيناريو**: معالجة محتوى الويب تلقائياً وحفظ الرؤى في قاعدة البيانات

```bash
#!/bin/bash
# content-pipeline.sh

# الخطوة 1: استخراج محتوى الويب
docker run --rm \
  -e TARGET_URL="https://example.com" \
  -v $(pwd)/content:/output \
  ghcr.io/metorial/mcp-containers:web-scraper

# الخطوة 2: استخراج وتحليل النص
docker run --rm \
  -v $(pwd)/content:/input \
  -v $(pwd)/analysis:/output \
  ghcr.io/metorial/mcp-containers:text-analyzer

# الخطوة 3: حفظ النتائج في قاعدة البيانات
docker run --rm \
  -v $(pwd)/analysis:/data \
  -v $(pwd)/db:/database \
  ghcr.io/metorial/mcp-containers:sqlite
```

### دراسة حالة 2: أتمتة DevOps

**السيناريو**: مراقبة عناقيد Kubernetes وإنتاج التقارير تلقائياً

```yaml
# k8s-monitoring.yml
version: '3.8'

services:
  cluster-monitor:
    image: ghcr.io/metorial/mcp-containers:mcp-k8s-eye
    volumes:
      - ~/.kube:/root/.kube:ro
      - ./reports:/reports
    environment:
      - REPORT_INTERVAL=3600
    
  slack-notifier:
    image: ghcr.io/metorial/mcp-containers:slack
    environment:
      - SLACK_BOT_TOKEN=${SLACK_BOT_TOKEN}
      - CHANNEL=#devops-alerts
    depends_on:
      - cluster-monitor
```

### دراسة حالة 3: أتمتة البحث

**السيناريو**: خط أنابيب بحث آلي يجمع بين البحث على الويب ومعالجة PDF وتحليل البيانات

```bash
#!/bin/bash
# research-automation.sh

TOPIC="اتجاهات الذكاء الاصطناعي 2025"

# الخطوة 1: بحث مصادر الويب
docker run --rm \
  -e BRAVE_API_KEY="$BRAVE_API_KEY" \
  -e SEARCH_QUERY="$TOPIC" \
  -v $(pwd)/research:/output \
  ghcr.io/metorial/mcp-containers:brave-search

# الخطوة 2: معالجة مستندات PDF
docker run --rm \
  -v $(pwd)/pdfs:/input \
  -v $(pwd)/extracted:/output \
  ghcr.io/metorial/mcp-containers:mcp-pandoc

# الخطوة 3: التحليل والتلخيص
docker run --rm \
  -v $(pwd)/research:/research \
  -v $(pwd)/extracted:/extracted \
  -v $(pwd)/analysis:/output \
  ghcr.io/metorial/mcp-containers:pandas
```

## التطورات المستقبلية والنظام البيئي

### الاتجاهات الناشئة

1. **حاويات مخصصة للذكاء الاصطناعي**: حاويات محسنة لأحمال عمل الذكاء الاصطناعي
2. **التكامل متعدد المنصات**: دعم محسن للهندسات المختلفة
3. **الأمان المعزز**: ميزات العزل والأمان المتقدمة
4. **تحسين الأداء**: أوقات بدء أسرع واستخدام موارد أقل

### مساهمات المجتمع

يرحب مشروع حاويات MCP بمساهمات المجتمع:

- **تطبيقات خوادم جديدة**: إضافة دعم لخدمات إضافية
- **تحسينات الأداء**: تحسين الحاويات الموجودة
- **التوثيق**: تحسين الأدلة والأمثلة
- **تقارير الأخطاء**: مساعدة في تحديد وإصلاح المشاكل

## الخلاصة

تمثل حاويات MCP تقدماً مهماً في تطوير وكلاء الذكاء الاصطناعي، حيث توفر:

- **تكامل مبسط**: لا حاجة لإعداد معقد
- **تغطية شاملة**: مئات الخوادم المبنية مسبقاً
- **جاهزة للإنتاج**: آمنة ومراقبة ومصانة
- **هندسة قابلة للتطوير**: مناسبة لكل شيء من النماذج الأولية إلى أنظمة الإنتاج

من خلال الاستفادة من حاويات MCP، يمكن للمطورين التركيز على بناء تطبيقات ذكاء اصطناعي مبتكرة بدلاً من المصارعة مع تحديات البنية التحتية. النهج المحاوي يضمن الاتساق والأمان والموثوقية عبر البيئات المختلفة.

### الخطوات التالية

1. **التجريب**: جرب خوادم MCP مختلفة لحالات الاستخدام الخاصة بك
2. **البناء**: أنشئ تدفقات عمل مخصصة تجمع خوادم متعددة
3. **التوسع**: انشر في بيئات الإنتاج
4. **المساهمة**: شارك تجاربك وتحسيناتك مع المجتمع

مستقبل تطوير وكلاء الذكاء الاصطناعي هنا، وحاويات MCP تجعله أكثر سهولة من أي وقت مضى. ابدأ في بناء تطبيقك القادم المدعوم بالذكاء الاصطناعي اليوم!

---

*لمزيد من المعلومات والتحديثات، قم بزيارة [مستودع GitHub لحاويات MCP](https://github.com/metorial/mcp-containers) واستكشف الكتالوج الشامل للخوادم المتاحة.*
