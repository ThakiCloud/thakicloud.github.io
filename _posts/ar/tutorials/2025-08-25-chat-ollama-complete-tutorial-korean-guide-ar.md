---
title: "شات-أولاما: دليل شامل لمنصة روبوت المحادثة الذكية الخاصة"
excerpt: "دليل شامل لنظام macOS لـ شات-أولاما، من التثبيت إلى الميزات المتقدمة مثل تكامل MCP وقواعد المعرفة"
seo_title: "دليل شات-أولاما الكامل - دروس روبوت المحادثة الذكية الخاص - ثاكي كلاود"
seo_description: "دليل شات-أولاما التفصيلي يغطي التثبيت والتكوين وتكامل MCP وإعداد قواعد المعرفة. يشمل تكامل نماذج Ollama وOpenAI وAnthropic"
date: 2025-08-25
categories:
  - tutorials
tags:
  - chat-ollama
  - ollama
  - AI-chatbot
  - nuxt3
  - vue3
  - docker
  - MCP
  - RAG
  - vector-database
  - privacy
author_profile: true
toc: true
toc_label: "المحتويات"
canonical_url: "https://thakicloud.github.io/ar/tutorials/chat-ollama-complete-tutorial-korean-guide/"
published: false
---

⏱️ **وقت القراءة المقدر**: 15 دقيقة

## 1. ما هو شات-أولاما؟

[شات-أولاما](https://github.com/sugarforever/chat-ollama) هو منصة روبوت محادثة ذكية مفتوحة المصدر تعطي الأولوية لخصوصية البيانات والأمان مع توفير قدرات قوية من نماذج اللغة المتطورة. مع أكثر من 3.3 ألف نجمة على GitHub وتطوير نشط، يقدم هذا المشروع حلاً كاملاً للمحادثات الآمنة مع الذكاء الاصطناعي في البيئات المحلية.

### الميزات الأساسية

- **🔒 الخصوصية أولاً**: معالجة البيانات محلياً مع الحد الأدنى من الاعتماد على الخوادم الخارجية
- **🤖 دعم نماذج ذكاء اصطناعي متعددة**: Ollama وOpenAI وAnthropic وGoogle AI وGroq وغيرها
- **🔧 تكامل MCP**: اتصال الأدوات الخارجية عبر بروتوكول سياق النموذج
- **🎤 محادثة صوتية في الوقت الفعلي**: محادثات صوتية مع نموذج Gemini 2.0 Flash
- **📚 دعم RAG**: رفع المستندات ومحادثات قواعد المعرفة
- **🌐 دعم متعدد اللغات**: واجهة عالمية للمستخدمين الدوليين

## 2. المكدس التقني والهندسة المعمارية

### الواجهة الأمامية
- **Nuxt 3**: إطار عمل Vue.js الحديث
- **Vue 3**: واجهة مستخدم تفاعلية مبنية على Composition API
- **Tailwind CSS**: إطار عمل CSS يركز على الأدوات المساعدة
- **Nuxt UI**: نظام مكونات متسق

### الواجهة الخلفية
- **Nitro**: محرك خادم Nuxt
- **Prisma ORM**: وصول آمن للبيانات مع ضمان الأنواع
- **SQLite/PostgreSQL**: قواعد بيانات للتطوير/الإنتاج

### معالجة الذكاء الاصطناعي والمتجهات
- **LangChain**: طبقة تجريد نماذج الذكاء الاصطناعي
- **ChromaDB/Milvus**: قواعد بيانات المتجهات
- **موفرو ذكاء اصطناعي متعددون**: OpenAI وAnthropic وGoogle وOllama إلخ

## 3. إعداد بيئة macOS والتثبيت

### 3.1 المتطلبات الأساسية

```bash
# فحص تثبيت Node.js (يُنصح بالإصدار 18 أو أحدث)
node --version

# تثبيت pnpm
npm install -g pnpm

# فحص تثبيت Git
git --version

# تثبيت Docker (اختياري، للنشر السهل)
docker --version
docker-compose --version
```

### 3.2 استنساخ المشروع والإعداد الأولي

```bash
# استنساخ المشروع
git clone https://github.com/sugarforever/chat-ollama.git
cd chat-ollama

# تثبيت التبعيات
pnpm install

# إعداد متغيرات البيئة
cp .env.example .env
```

### 3.3 تكوين متغيرات البيئة

قم بتحرير ملف `.env` لإضافة التكوينات الضرورية:

```bash
# إعدادات قاعدة البيانات
DATABASE_URL="file:../../chatollama.sqlite"

# إعدادات الخادم
PORT=3000
HOST=

# إعدادات قاعدة البيانات المتجهة
VECTOR_STORE=chroma
CHROMADB_URL=http://localhost:8000

# مفاتيح API لنماذج الذكاء الاصطناعي (اختياري)
OPENAI_API_KEY=your_openai_key
ANTHROPIC_API_KEY=your_anthropic_key
GOOGLE_API_KEY=your_gemini_key
GROQ_API_KEY=your_groq_key

# أعلام الميزات
MCP_ENABLED=true
KNOWLEDGE_BASE_ENABLED=true
REALTIME_CHAT_ENABLED=true
MODELS_MANAGEMENT_ENABLED=true
```

### 3.4 تهيئة قاعدة البيانات

```bash
# إنتاج عميل Prisma
pnpm prisma-generate

# تشغيل ترحيلات قاعدة البيانات
pnpm prisma-migrate
```

### 3.5 إعداد ChromaDB (قاعدة البيانات المتجهة)

```bash
# تشغيل حاوية Docker لـ ChromaDB
docker run -d -p 8000:8000 --name chromadb chromadb/chroma

# التحقق من تشغيل الحاوية
curl http://localhost:8000/api/v1/version
```

### 3.6 تشغيل خادم التطوير

```bash
# بدء الخادم في وضع التطوير
pnpm dev

# الوصول إلى http://localhost:3000 في المتصفح
```

## 4. النشر السهل باستخدام Docker

يسمح Docker بتشغيل شات-أولاما دون تكوين معقد.

### 4.1 نشر Docker Compose

```bash
# التشغيل من دليل المشروع
docker-compose up -d

# فحص حالة الخدمة
docker-compose ps

# عرض السجلات
docker-compose logs chatollama
```

### 4.2 متغيرات بيئة Docker

قم بتكوين متغيرات البيئة في ملف `docker-compose.yml`:

```yaml
services:
  chatollama:
    environment:
      - NUXT_MCP_ENABLED=true
      - NUXT_KNOWLEDGE_BASE_ENABLED=true
      - NUXT_REALTIME_CHAT_ENABLED=true
      - NUXT_MODELS_MANAGEMENT_ENABLED=true
      - OPENAI_API_KEY=your_key_here
      - ANTHROPIC_API_KEY=your_key_here
```

### 4.3 استدامة البيانات

في نشر Docker، يتم تخزين البيانات كما يلي:

- **بيانات المتجهات**: مجلد Docker (`chromadb_volume`)
- **البيانات العلائقية**: ملف SQLite (`~/.chatollama/chatollama.sqlite`)
- **بيانات الجلسة**: حاوية Redis

## 5. إعداد نماذج Ollama

### 5.1 تثبيت وتكوين Ollama

```bash
# تثبيت Ollama على macOS
curl -fsSL https://ollama.com/install.sh | sh

# أو استخدام Homebrew
brew install ollama

# بدء خدمة Ollama
ollama serve
```

### 5.2 تنزيل وتشغيل النماذج

```bash
# تثبيت النماذج الشائعة
ollama pull llama3.1:8b
ollama pull codellama:13b
ollama pull mistral:7b
ollama pull qwen2.5:14b

# فحص النماذج المثبتة
ollama list

# اختبار نموذج
ollama run llama3.1:8b "مرحباً، يرجى الرد باللغة العربية"
```

### 5.3 تكوين النموذج في شات-أولاما

1. **الوصول إلى واجهة الويب**: http://localhost:3000
2. **انقر على قائمة الإعدادات**
3. **إضافة نموذج Ollama في تبويب النماذج**:
   - اسم النموذج: `llama3.1:8b`
   - رابط API الأساسي: `http://localhost:11434`
   - نوع النموذج: `Chat`

## 6. تكامل MCP (بروتوكول سياق النموذج)

MCP يُمكن نماذج الذكاء الاصطناعي من الوصول إلى الأدوات الخارجية ومصادر البيانات.

### 6.1 تكوين خادم MCP

انتقل إلى **الإعدادات ← MCP** في واجهة الويب لإضافة الخوادم:

#### إعداد أدوات نظام الملفات
```
الاسم: أدوات نظام الملفات
النقل: stdio
الأمر: uvx
المعطيات: mcp-server-filesystem
متغيرات البيئة:
  PATH: ${PATH}
```

#### إعداد أدوات Git
```
الاسم: أدوات Git
النقل: stdio
الأمر: uvx  
المعطيات: mcp-server-git
متغيرات البيئة:
  PATH: ${PATH}
```

### 6.2 خوادم MCP الشائعة

```bash
# معالجة نظام الملفات
uvx mcp-server-filesystem

# إدارة مستودع Git
uvx mcp-server-git

# استعلامات قاعدة بيانات SQLite
uvx mcp-server-sqlite

# البحث في الويب (Brave Search)
uvx mcp-server-brave-search
```

### 6.3 اختبار وظيفة MCP

بمجرد تفعيل MCP، يمكن لنماذج الذكاء الاصطناعي استخدام الأدوات تلقائياً أثناء المحادثات:

- "أظهر لي قائمة الملفات في المجلد الحالي" ← يستدعي أداة نظام الملفات
- "تحقق من تاريخ commits لـ Git في هذا المشروع" ← يستدعي أداة Git
- "ابحث عن آخر أخبار الذكاء الاصطناعي" ← يستدعي أداة البحث في الويب

## 7. تنفيذ قاعدة المعرفة وRAG

### 7.1 إنشاء قاعدة المعرفة

1. **انقر على قائمة قواعد المعرفة**
2. **انقر على زر "إنشاء قاعدة معرفة"**
3. **التكوين الأساسي**:
   - الاسم: `وثائق الشركة`
   - حجم القطعة: `1000`
   - تداخل القطعة: `200`

### 7.2 رفع المستندات

صيغ الملفات المدعومة:
- **PDF**: استخراج النص والمتجهات
- **DOCX**: مستندات Microsoft Word
- **TXT**: ملفات نصية عادية

```bash
# إنشاء مستند نموذجي (للاختبار)
echo "شات-أولاما هو منصة روبوت محادثة ذكية مفتوحة المصدر. 
مبني على Nuxt 3 و Vue 3، 
يدعم نماذج ذكاء اصطناعي متنوعة." > sample_doc.txt
```

عند رفع المستندات عبر واجهة الويب، يتم تلقائياً:
1. استخراج النص
2. التقسيم إلى قطع
3. إنتاج متجهات التضمين
4. التخزين في ChromaDB

### 7.3 المحادثات المبنية على RAG

بمجرد إنشاء قواعد المعرفة، تشير المحادثات إلى محتوى المستندات ذات الصلة:

```
المستخدم: يرجى شرح المكدس التقني لشات-أولاما.
الذكاء الاصطناعي: بناءً على المستندات المرفوعة، شات-أولاما مبني على Nuxt 3 و Vue 3... [إجابة مبنية على المستندات]
```

## 8. المحادثة الصوتية في الوقت الفعلي

### 8.1 تكوين Gemini API

```bash
# إضافة مفتاح Google API إلى ملف .env
GOOGLE_API_KEY=your_google_api_key_here
```

### 8.2 تفعيل المحادثة الصوتية

1. **تفعيل المحادثة في الوقت الفعلي في الإعدادات ← عام**
2. **التحقق من تكوين مفتاح Google API**
3. **الوصول إلى صفحة `/realtime`**
4. **السماح بأذونات الميكروفون**

### 8.3 ميزات المحادثة الصوتية

- **التعرف على الكلام في الوقت الفعلي**: تحويل الصوت إلى نص
- **الاستجابة الصوتية الطبيعية**: TTS عالي الجودة من Gemini 2.0 Flash
- **الإيقاف والاستئناف**: مقاطعة/استئناف المحادثة في أي وقت

## 9. التكوين المتقدم والتخصيص

### 9.1 تكوين البروكسي

للبيئات الشبكية المحددة التي تتطلب بروكسي:

```bash
# إعدادات البروكسي في ملف .env
NUXT_PUBLIC_MODEL_PROXY_ENABLED=true
NUXT_MODEL_PROXY_URL=http://127.0.0.1:1080
```

### 9.2 إعداد إعادة ترتيب Cohere

Cohere Rerank API لتحسين دقة نتائج البحث:

```bash
# إضافة مفتاح Cohere API إلى ملف .env
COHERE_API_KEY=your_cohere_key
```

### 9.3 تبديل الميزات

تفعيل ميزات محددة بشكل انتقائي:

```bash
# بيئة التطوير (.env)
MCP_ENABLED=true
KNOWLEDGE_BASE_ENABLED=true  
REALTIME_CHAT_ENABLED=false
MODELS_MANAGEMENT_ENABLED=true

# بيئة Docker (docker-compose.yml)
NUXT_MCP_ENABLED=true
NUXT_KNOWLEDGE_BASE_ENABLED=true
NUXT_REALTIME_CHAT_ENABLED=false
NUXT_MODELS_MANAGEMENT_ENABLED=true
```

## 10. دليل النشر للإنتاج

### 10.1 ترحيل PostgreSQL

يُنصح بـ PostgreSQL لبيئات الإنتاج:

```bash
# تثبيت PostgreSQL (macOS)
brew install postgresql
brew services start postgresql

# إنشاء قاعدة البيانات والمستخدم
psql postgres
CREATE DATABASE chatollama;
CREATE USER chatollama WITH PASSWORD 'secure_password';
GRANT ALL PRIVILEGES ON DATABASE chatollama TO chatollama;
\q

# تحديث ملف .env
DATABASE_URL="postgresql://chatollama:secure_password@localhost:5432/chatollama"

# تشغيل الترحيلات
pnpm prisma migrate deploy
```

### 10.2 ترحيل البيانات من SQLite إلى PostgreSQL

```bash
# نسخ احتياطي لبيانات SQLite الموجودة
cp chatollama.sqlite chatollama.sqlite.backup

# تشغيل الترحيل
pnpm migrate:sqlite-to-postgres
```

### 10.3 بناء الإنتاج

```bash
# البناء للإنتاج
pnpm build

# الاختبار في وضع المعاينة
pnpm preview
```

### 10.4 تسجيل خدمة النظام (macOS)

```bash
# إنشاء ملف plist لـ LaunchDaemon
sudo tee /Library/LaunchDaemons/com.chatollama.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.chatollama</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/node</string>
        <string>/path/to/chat-ollama/.output/server/index.mjs</string>
    </array>
    <key>WorkingDirectory</key>
    <string>/path/to/chat-ollama</string>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/var/log/chatollama.log</string>
    <key>StandardErrorPath</key>
    <string>/var/log/chatollama.error.log</string>
</dict>
</plist>
EOF

# تسجيل وبدء الخدمة
sudo launchctl load /Library/LaunchDaemons/com.chatollama.plist
sudo launchctl start com.chatollama
```

## 11. استكشاف الأخطاء وإصلاحها

### 11.1 المشاكل الشائعة

#### تعارض المنافذ
```bash
# فحص العمليات التي تستخدم المنفذ
lsof -i :3000

# التشغيل على منفذ مختلف
PORT=3001 pnpm dev
```

#### فشل الاتصال بـ ChromaDB
```bash
# فحص حالة حاوية ChromaDB
docker ps | grep chroma

# إعادة تشغيل الحاوية
docker restart chromadb

# تشغيل الحاوية يدوياً
docker run -d -p 8000:8000 --name chromadb chromadb/chroma
```

#### فشل ترحيل قاعدة البيانات
```bash
# إعادة تعيين قاعدة البيانات
rm chatollama.sqlite
pnpm prisma migrate reset

# إنشاء ترحيل جديد
pnpm prisma migrate dev --name init
```

### 11.2 تحسين الأداء

#### تحسين استخدام الذاكرة
```bash
# تعيين حد ذاكرة Node.js
NODE_OPTIONS="--max_old_space_size=4096" pnpm dev
```

#### ضبط أداء ChromaDB
```bash
# تشغيل ChromaDB مع إعدادات محسّنة
docker run -d -p 8000:8000 \
  -e CHROMA_SERVER_HOST=0.0.0.0 \
  -e CHROMA_SERVER_HTTP_PORT=8000 \
  -v chroma-data:/chroma/chroma \
  --name chromadb chromadb/chroma
```

## 12. اعتبارات الأمان

### 12.1 أمان مفاتيح API

```bash
# تعيين أذونات ملف .env
chmod 600 .env

# إدارة المعلومات الحساسة عبر متغيرات البيئة
export OPENAI_API_KEY="your-secret-key"
export ANTHROPIC_API_KEY="your-secret-key"
```

### 12.2 أمان الشبكة

```bash
# السماح بالوصول المحلي فقط
HOST=127.0.0.1 pnpm dev

# تكوين HTTPS (الإنتاج)
NUXT_PUBLIC_SITE_URL=https://your-domain.com
```

### 12.3 النسخ الاحتياطي للبيانات

```bash
# سكريبت النسخ الاحتياطي المنتظم
#!/bin/bash
BACKUP_DIR="/path/to/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# نسخ احتياطي لـ SQLite
cp chatollama.sqlite "$BACKUP_DIR/chatollama_$DATE.sqlite"

# نسخ احتياطي لمجلد ChromaDB
docker run --rm -v chromadb_volume:/data -v $BACKUP_DIR:/backup busybox tar czf /backup/chromadb_$DATE.tar.gz /data
```

## 13. المجتمع والدعم

### 13.1 الموارد الرسمية
- **GitHub**: [sugarforever/chat-ollama](https://github.com/sugarforever/chat-ollama)
- **الموقع الرسمي**: [chatollama.cloud](https://chatollama.cloud)
- **مجتمع Discord**: الدعم التقني والمناقشات

### 13.2 المساهمة
- **الإبلاغ عن المشاكل**: الإبلاغ عن الأخطاء عبر GitHub Issues
- **طلبات الميزات**: استخدام قالب طلب الميزة
- **المساهمات في الكود**: تقديم التحسينات عبر Pull Requests

## 14. الخلاصة

شات-أولاما يوفر حلاً كاملاً يعطي الأولوية للخصوصية مع تقديم قدرات ذكاء اصطناعي قوية. هذا الدليل غطى كل شيء من التثبيت إلى استخدام الميزات المتقدمة، مقدماً معلومات كافية للتخصيص وفقاً لبيئتك ومتطلباتك.

### ملخص المزايا الرئيسية
- **🔒 خصوصية بيانات كاملة**: جميع العمليات في البيئة المحلية
- **🤖 دعم نماذج متعددة**: التكامل مع Ollama وOpenAI وAnthropic إلخ
- **🔧 قابلية التوسع**: توسيع وظائف لا محدود عبر MCP
- **📚 قاعدة المعرفة**: البحث في المستندات والمحادثة المبنية على RAG
- **🎤 الدعم الصوتي**: قدرات المحادثة الصوتية في الوقت الفعلي

ابنِ مساعد ذكاء اصطناعي آمن وقوي باستخدام شات-أولاما. للأسئلة أو المشاكل، يرجى استخدام GitHub Issues أو مجتمع Discord.

---

**روابط مرجعية**:
- [مستودع شات-أولاما على GitHub](https://github.com/sugarforever/chat-ollama)
- [موقع Ollama الرسمي](https://ollama.com)
- [وثائق Nuxt 3](https://nuxt.com)
- [وثائق ChromaDB](https://docs.trychroma.com)
