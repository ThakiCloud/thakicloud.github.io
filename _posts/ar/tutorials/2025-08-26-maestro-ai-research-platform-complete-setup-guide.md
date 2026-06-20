---
title: "MAESTRO: دليل شامل لإعداد واستخدام منصة البحث المدعومة بالذكاء الاصطناعي"
excerpt: "دليل شامل من التثبيت إلى الاستخدام المتقدم لـ MAESTRO، منصة أتمتة البحث القائمة على وكلاء الذكاء الاصطناعي"
seo_title: "دليل إعداد منصة MAESTRO للبحث بالذكاء الاصطناعي - Docker، GPU، تكامل LLM المحلي - Thaki Cloud"
seo_description: "درس تطبيقي شامل لمنصة MAESTRO مفتوحة المصدر للبحث بالذكاء الاصطناعي: التثبيت، تحسين GPU، تكامل محرك البحث SearXNG، وإعدادات LLM المحلية"
date: 2025-08-26
categories:
  - tutorials
tags:
  - maestro
  - ai-research
  - docker
  - fastapi
  - react
  - postgresql
  - pgvector
  - searxng
  - local-llm
  - gpu
author_profile: true
toc: true
toc_label: "جدول المحتويات"
canonical_url: "https://thakicloud.github.io/ar/tutorials/maestro-ai-research-platform-complete-setup-guide/"
lang: ar
permalink: /ar/tutorials/maestro-ai-research-platform-complete-setup-guide/
published: false
---

⏱️ **وقت القراءة المقدر**: 25 دقيقة

## 1. مقدمة عن MAESTRO

### ما هو MAESTRO؟

MAESTRO هو منصة أتمتة البحث المدعومة بالذكاء الاصطناعي والمصممة للتعامل بكفاءة مع مهام البحث المعقدة. هذا التطبيق مفتوح المصدر يؤتمت سير عمل البحث الكامل من جمع الوثائق إلى التحليل وإنتاج التقارير باستخدام وكلاء الذكاء الاصطناعي.

### الميزات الرئيسية

- **البحث القائم على وكلاء الذكاء الاصطناعي**: خط أنابيب البحث الآلي مدعوم بنماذج اللغة الكبيرة
- **RAG (التوليد المعزز بالاسترجاع)**: معالجة الوثائق القائمة على البحث الشعاعي
- **اتصال WebSocket في الوقت الفعلي**: مراقبة مباشرة لتقدم المهام
- **استضافة ذاتية كاملة**: تشغيل مستقل تام في البيئات المحلية
- **دعم متعدد لنماذج اللغة**: OpenAI، نماذج محلية، نماذج متوافقة مع API
- **تكامل SearXNG**: اتصال بمحرك البحث الخاص

### المكدس التقني

- **الواجهة الخلفية**: FastAPI، SQLAlchemy، PostgreSQL، pgvector
- **الواجهة الأمامية**: React، TypeScript، Vite، Tailwind CSS
- **البنية التحتية**: Docker Compose، WebSocket
- **الذكاء الاصطناعي/التعلم الآلي**: تضمين الشعاعات، تكامل API لنماذج اللغة

## 2. متطلبات النظام

### المواصفات الدنيا للأجهزة

```bash
# وضع المعالج (الحد الأدنى)
- المعالج: 4+ أنوية
- الذاكرة: 8 جيجابايت+
- التخزين: 10 جيجابايت+
- نظام التشغيل: Linux، macOS، Windows (WSL2)

# وضع كرت الرسومات (مُوصى به)
- كرت الرسومات: NVIDIA GPU (CUDA 11.0+)
- ذاكرة كرت الرسومات: 8 جيجابايت+
- الذاكرة: 16 جيجابايت+
- التخزين: 20 جيجابايت+
```

### البرامج المطلوبة

```bash
# المتطلبات العامة
- Docker Desktop (الإصدار الأحدث)
- Docker Compose v2
- Git

# إضافية لاستخدام كرت الرسومات (Linux)
- nvidia-container-toolkit
- تعريفات NVIDIA (الأحدث)

# مستخدمو Windows
- WSL2 (Ubuntu 20.04+)
- Windows Terminal (مُوصى به)
```

## 3. التثبيت والإعداد الأولي

### 3.1 استنساخ المستودع والإعداد الأساسي

```bash
# 1. استنساخ مستودع MAESTRO
git clone https://github.com/murtaza-nasir/maestro.git
cd maestro

# 2. منح أذونات التنفيذ (Linux/macOS)
chmod +x start.sh stop.sh detect_gpu.sh maestro-cli.sh

# 3. إنشاء ملف إعدادات البيئة
cp .env.example .env
```

### 3.2 إعداد متغيرات البيئة

قم بتحرير ملف `.env` لإعداد الإعدادات الأساسية:

```bash
# الإعدادات الرئيسية لملف .env
# ===============================

# إعدادات قاعدة البيانات
POSTGRES_DB=maestro_db
POSTGRES_USER=maestro_user
POSTGRES_PASSWORD=your_secure_password_here

# إعدادات أمان JWT
JWT_SECRET_KEY=your_jwt_secret_key_here
JWT_ALGORITHM=HS256
JWT_ACCESS_TOKEN_EXPIRE_MINUTES=30

# إعدادات API لنماذج اللغة (لـ OpenAI)
OPENAI_API_KEY=your_openai_api_key_here
LLM_MODEL=gpt-4

# إعدادات النماذج المحلية (لـ Ollama)
LOCAL_LLM_BASE_URL=http://localhost:11434/v1
LOCAL_LLM_MODEL=llama3.1:8b
USE_LOCAL_LLM=true

# إعداد محرك البحث
SEARCH_ENGINE=searxng
SEARXNG_BASE_URL=http://searxng:8080

# إعداد كرت الرسومات
GPU_AVAILABLE=true
BACKEND_GPU_DEVICE=0
DOC_PROCESSOR_GPU_DEVICE=0

# وضع المعالج فقط (للبيئات بدون كرت رسومات)
FORCE_CPU_MODE=false
```

### 3.3 التحقق من دعم كرت الرسومات

فحص توفر دعم كرت الرسومات وتطبيق الإعدادات المثلى:

```bash
# تشغيل سكريبت اكتشاف كرت الرسومات
./detect_gpu.sh

# مثال على الإخراج:
# =========== نتائج اكتشاف كرت الرسومات ===========
# المنصة: Linux
# دعم كرت الرسومات: متوفر
# تعريف NVIDIA: 525.147.05
# إصدار CUDA: 12.0
# الإعداد الموصى به: مُفعل بكرت الرسومات
# =============================================
```

## 4. دليل التثبيت حسب المنصة

### 4.1 Linux (Ubuntu/Debian) - دعم كرت الرسومات

```bash
# 1. تثبيت NVIDIA Container Toolkit
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

# 2. إعادة تشغيل Docker
sudo systemctl restart docker

# 3. اختبار كرت الرسومات
docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi

# 4. بدء MAESTRO
./start.sh
```

### 4.2 macOS (Apple Silicon/Intel)

```bash
# 1. التحقق من تثبيت Docker Desktop
docker --version
docker-compose --version

# 2. البدء في وضع محسن للمعالج
docker-compose -f docker-compose.cpu.yml up -d

# أو تعيين متغير البيئة والبدء عادياً
echo "FORCE_CPU_MODE=true" >> .env
./start.sh
```

### 4.3 Windows (WSL2)

تشغيل PowerShell كمدير:

```powershell
# 1. التحقق من تثبيت WSL2 و Ubuntu
wsl --list --verbose

# 2. التحقق من تشغيل Docker Desktop Windows
docker --version

# 3. استنساخ المستودع (داخل WSL2)
wsl
cd /mnt/c/
git clone https://github.com/murtaza-nasir/maestro.git
cd maestro

# 4. تعيين الأذونات والبدء
chmod +x *.sh
./start.sh

# أو استخدام سكريبت PowerShell
# .\start.ps1
```

## 5. إعداد الخدمات والبدء

### 5.1 بدء الخدمات الأساسية

```bash
# البدء مع اكتشاف تلقائي للمنصة
./start.sh

# أو تشغيل Docker Compose يدوياً
docker-compose up -d

# وضع المعالج فقط
docker-compose -f docker-compose.cpu.yml up -d
```

### 5.2 فحص حالة الخدمات

```bash
# فحص حالة الحاويات
docker-compose ps

# فحص السجلات
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f postgres
docker-compose logs -f searxng

# فحص جميع السجلات
docker-compose logs -f
```

### 5.3 تهيئة قاعدة البيانات

```bash
# فحص حالة قاعدة البيانات
./maestro-cli.sh reset-db --check

# استعلام إحصائيات قاعدة البيانات
./maestro-cli.sh reset-db --stats

# إعادة تعيين قاعدة البيانات مع النسخ الاحتياطي (عند الحاجة)
./maestro-cli.sh reset-db --backup
```

## 6. الوصول إلى الواجهة الويب والإعداد الأولي

### 6.1 الوصول الأول وإنشاء الحساب

```bash
# الوصول عبر المتصفح
http://localhost:3000

# أو إنشاء حساب مدير عبر CLI
./maestro-cli.sh create-user admin securepassword123 --admin
```

### 6.2 الإعداد الأساسي

انتقل إلى قائمة `الإعدادات` في واجهة الويب وقم بالإعداد:

```yaml
# إعدادات نماذج اللغة
مقدم النموذج: OpenAI / نموذج محلي
مفتاح API: [YOUR_API_KEY]
اسم النموذج: gpt-4 / llama3.1:8b
درجة الحرارة: 0.7
أقصى عدد رموز: 4000

# إعدادات البحث
محرك البحث: SearXNG
الفئات: 
  - عام
  - علوم
  - تكنولوجيا المعلومات
  - أخبار
النتائج لكل استعلام: 10

# معايير البحث
سياق التخطيط: 200000
أقصى عدد وثائق: 50
حجم القطعة: 1000
التداخل: 200
```

## 7. تكامل نماذج اللغة المحلية (Ollama)

### 7.1 تثبيت وإعداد Ollama

```bash
# تثبيت Ollama (Linux/macOS)
curl -fsSL https://ollama.ai/install.sh | sh

# Windows (PowerShell)
# Invoke-WebRequest -Uri https://ollama.ai/install.ps1 -OutFile install.ps1; .\install.ps1

# تحميل النماذج
ollama pull llama3.1:8b
ollama pull codellama:7b
ollama pull mistral:7b

# بدء خدمة Ollama
ollama serve
```

### 7.2 تكامل MAESTRO مع Ollama

قم بتعديل ملف `.env` كما يلي:

```bash
# إعدادات النموذج المحلي
USE_LOCAL_LLM=true
LOCAL_LLM_BASE_URL=http://host.docker.internal:11434/v1
LOCAL_LLM_MODEL=llama3.1:8b
LOCAL_LLM_API_KEY=ollama

# استخدام نقطة نهاية متوافقة مع OpenAI
LLM_PROVIDER=local
```

### 7.3 اختبار التكامل

```bash
# اختبار النموذج عبر CLI
./maestro-cli.sh test-llm

# أو الاختبار مباشرة بسكريبت Python
python << EOF
import requests

response = requests.post('http://localhost:11434/v1/chat/completions', 
    json={
        'model': 'llama3.1:8b',
        'messages': [{'role': 'user', 'content': 'مرحباً، MAESTRO!'}],
        'max_tokens': 100
    }
)
print(response.json())
EOF
```

## 8. إعداد محرك البحث SearXNG

### 8.1 فحص إعداد حاوية SearXNG

```bash
# فحص حالة حاوية SearXNG
docker-compose logs searxng

# فحص ملف الإعداد
docker-compose exec searxng cat /etc/searxng/settings.yml
```

### 8.2 إعداد فئات البحث

قم بتخصيص ملف `settings.yml` الخاص بـ SearXNG:

```yaml
# searxng/settings.yml
search:
  safe_search: 0
  autocomplete: duckduckgo
  default_lang: ""
  formats:
    - html
    - json  # مطلوب لتكامل MAESTRO

categories:
  general:
    - google
    - bing
    - duckduckgo
  science:
    - arxiv
    - pubmed
    - semantic scholar
  it:
    - github
    - stackoverflow
    - documentation
  news:
    - google news
    - reuters
    - bbc
```

### 8.3 اختبار البحث الخاص

```bash
# اختبار API الخاص بـ SearXNG
curl "http://localhost:8080/search?q=artificial+intelligence&format=json&category=science"

# اختبار البحث في MAESTRO
# واجهة الويب > الإعدادات > البحث > زر اختبار البحث
```

## 9. سيناريوهات الاستخدام العملي

### 9.1 جمع وتحليل الوثائق

```bash
# رفع الوثائق بالجملة عبر CLI
./maestro-cli.sh ingest username ./research_documents

# الصيغ المدعومة
# - PDF، DOCX، TXT، MD
# - روابط الويب، أوراق arXiv
# - بيانات JSON، CSV

# مراقبة تقدم الرفع
./maestro-cli.sh status username
```

### 9.2 إنشاء مشروع بحث

إنشاء مشروع بحث جديد في واجهة الويب:

```yaml
# مثال على إعداد البحث
اسم المشروع: "تحليل هياكل وكلاء الذكاء الاصطناعي"
سؤال البحث: "ما هي أحدث الاتجاهات في هياكل وكلاء الذكاء الاصطناعي؟"
النطاق: 
  - الأوراق الأكاديمية (2023-2024)
  - تقارير الصناعة
  - الوثائق التقنية
صيغة الإخراج: "تقرير شامل مع المراجع"
```

### 9.3 تنفيذ سير عمل وكلاء الذكاء الاصطناعي

```bash
# 1. مرحلة التخطيط
وكيل البحث -> تحليل سياق التخطيط
             -> إنتاج الخطوط العريضة
             -> تحديد الموارد

# 2. مرحلة جمع البيانات  
وكيل البحث -> البحث على الويب (SearXNG)
             -> استرجاع الوثائق
             -> استخراج المحتوى

# 3. مرحلة التحليل
وكيل التحليل -> التحليل القائم على RAG
               -> التحقق من المراجع المتقاطعة
               -> توليد الرؤى

# 4. مرحلة إنتاج التقرير
وكيل التقرير -> تركيب المحتوى
              -> إدارة الاستشهادات
              -> تنسيق الإخراج
```

## 10. الإعداد المتقدم والتحسين

### 10.1 تحسين ذاكرة كرت الرسومات

```bash
# مراقبة ذاكرة كرت الرسومات
nvidia-smi -l 1

# إعدادات تحسين استخدام الذاكرة
# إضافة إلى ملف .env
MAX_GPU_MEMORY=8192  # بالميجابايت
BATCH_SIZE=32
CHUNK_OVERLAP=100
```

### 10.2 إعداد متعدد لكروت الرسومات

```bash
# تخصيص كرت رسومات لكل خدمة
BACKEND_GPU_DEVICE=0
DOC_PROCESSOR_GPU_DEVICE=1
CLI_GPU_DEVICE=0

# فحص توزيع الأحمال على كروت الرسومات
nvidia-smi topo -m
```

### 10.3 ضبط الأداء

```bash
# ضبط PostgreSQL
# في إعدادات خدمة postgres في docker-compose.yml
environment:
  - POSTGRES_SHARED_PRELOAD_LIBRARIES=pg_stat_statements,auto_explain
  - POSTGRES_LOG_STATEMENT=all
  - POSTGRES_EFFECTIVE_CACHE_SIZE=4GB
  - POSTGRES_SHARED_BUFFERS=1GB

# تحسين فهرس pgvector
docker-compose exec postgres psql -U maestro_user -d maestro_db
CREATE INDEX CONCURRENTLY idx_embeddings_cosine ON documents 
USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
```

## 11. دليل استكشاف الأخطاء وإصلاحها

### 11.1 الأخطاء الشائعة والحلول

```bash
# 1. خطأ تعارض المنافذ
خطأ: المنفذ 3000 قيد الاستخدام بالفعل
الحل: sudo lsof -i :3000; kill -9 <PID>

# 2. نقص ذاكرة كرت الرسومات
CUDA out of memory
الحل: تعيين FORCE_CPU_MODE=true أو تعديل حجم الدفعة

# 3. خطأ اتصال قاعدة البيانات
رفض الاتصال بـ PostgreSQL
الحل: docker-compose restart postgres

# 4. فشل اتصال Ollama
فشل اتصال النموذج المحلي
الحل: استخدام IP الفعلي بدلاً من host.docker.internal
```

### 11.2 استخدام أدوات التشخيص

```bash
# تفعيل السجلات التفصيلية
export MAESTRO_LOG_LEVEL=DEBUG
docker-compose up -d

# الوصول إلى داخل الحاويات
docker-compose exec backend bash
docker-compose exec postgres psql -U maestro_user -d maestro_db

# فحوصات الصحة
curl http://localhost:8000/health
curl http://localhost:3000/health
```

### 11.3 النسخ الاحتياطي واستعادة البيانات

```bash
# نسخ احتياطي لقاعدة البيانات
docker-compose exec postgres pg_dump -U maestro_user maestro_db > backup.sql

# نسخ احتياطي للبيانات الشعاعية (تتضمن إضافة pgvector)
docker-compose exec postgres pg_dump -U maestro_user -Fc maestro_db > backup.dump

# الاستعادة
docker-compose exec -T postgres psql -U maestro_user -d maestro_db < backup.sql
```

## 12. اعتبارات الأمان

### 12.1 إدارة المصادقة والتخويل

```bash
# إنتاج مفتاح JWT قوي
openssl rand -hex 32

# إعدادات أذونات المستخدمين
./maestro-cli.sh create-user researcher pass123 --role user
./maestro-cli.sh create-user admin admin123 --role admin

# دوران مفاتيح API
./maestro-cli.sh rotate-keys
```

### 12.2 أمان الشبكة

```bash
# إعداد جدار الحماية (Ubuntu/Debian)
sudo ufw allow from 192.168.1.0/24 to any port 3000
sudo ufw allow from 192.168.1.0/24 to any port 8000

# إعداد Reverse Proxy (Nginx)
# nginx/maestro.conf
server {
    listen 443 ssl;
    server_name maestro.yourdomain.com;
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_websocket_upgrade on;
    }
    
    location /api {
        proxy_pass http://localhost:8000;
    }
}
```

## 13. المراقبة والصيانة

### 13.1 مراقبة النظام

```bash
# مراقبة استخدام الموارد
docker stats maestro_backend maestro_frontend maestro_postgres

# إعداد دوران السجلات
# إضافة إلى docker-compose.yml
logging:
  driver: json-file
  options:
    max-size: "100m"
    max-file: "3"

# فحوصات الصحة التلقائية
# healthcheck.sh
#!/bin/bash
curl -f http://localhost:8000/health || exit 1
curl -f http://localhost:3000/ || exit 1
```

### 13.2 الصيانة الدورية

```bash
# سكريبت الصيانة الأسبوعية
#!/bin/bash
# weekly_maintenance.sh

# 1. تحديث الحاويات
docker-compose pull
docker-compose up -d

# 2. تنظيف قاعدة البيانات
./maestro-cli.sh cleanup-orphaned-docs

# 3. ضغط السجلات
find /var/log/maestro -name "*.log" -mtime +7 -exec gzip {} \;

# 4. تقرير حالة النظام
./maestro-cli.sh system-report > /var/log/maestro/weekly_report_$(date +%Y%m%d).txt
```

## 14. التوسيع والتخصيص

### 14.1 تطوير وكلاء ذكاء اصطناعي مخصصة

```python
# maestro_backend/agents/custom_agent.py
from maestro_backend.core.agent_base import BaseAgent

class CustomResearchAgent(BaseAgent):
    def __init__(self, config):
        super().__init__(config)
        self.specialty = "domain_specific_research"
    
    async def process_request(self, request):
        """تنفيذ منطق البحث المخصص"""
        results = await self.search_documents(request.query)
        analysis = await self.analyze_with_llm(results)
        return await self.generate_report(analysis)
    
    async def search_documents(self, query):
        """منطق البحث الخاص بالنطاق"""
        # منطق التنفيذ
        pass
```

### 14.2 توسيع API

```python
# maestro_backend/api/custom_endpoints.py
from fastapi import APIRouter, Depends
from maestro_backend.core.auth import get_current_user

router = APIRouter(prefix="/api/custom", tags=["custom"])

@router.post("/domain-research")
async def domain_research(
    request: DomainResearchRequest,
    current_user: User = Depends(get_current_user)
):
    """نقطة نهاية البحث المخصص للنطاق"""
    agent = CustomResearchAgent(config)
    results = await agent.process_request(request)
    return {"results": results, "status": "completed"}
```

## 15. قائمة فحص استكشاف الأخطاء

### 15.1 قائمة فحص ما بعد التثبيت

- [ ] جميع حاويات Docker تعمل (`docker-compose ps`)
- [ ] المنافذ 3000، 8000، 5432، 8080 قابلة للوصول
- [ ] اتصال قاعدة البيانات طبيعي (`./maestro-cli.sh reset-db --check`)
- [ ] اجتياز اختبار اتصال API لنماذج اللغة
- [ ] واجهة الويب متاحة لتسجيل الدخول
- [ ] وظيفة البحث تعمل بشكل طبيعي

### 15.2 قائمة فحص تحسين الأداء

- [ ] مراقبة استخدام ذاكرة كرت الرسومات
- [ ] تحسين فهارس PostgreSQL
- [ ] التحقق من سرعة استجابة SearXNG
- [ ] تعديل حجم دفعة معالجة الوثائق
- [ ] التحقق من إعدادات التخزين المؤقت

## 16. الخلاصة

MAESTRO يقدم منصة قوية تطرح نموذجاً جديداً لأتمتة البحث المدعومة بالذكاء الاصطناعي. من خلال هذا الدرس التطبيقي، يمكنك إتقان كل شيء من التثبيت الأساسي إلى الإعداد المتقدم بشكل كامل.

### الإنجازات الرئيسية

✅ **إعداد بيئة استضافة ذاتية كاملة**  
✅ **تنفيذ سير عمل البحث القائم على وكلاء الذكاء الاصطناعي**  
✅ **تكامل نماذج اللغة المحلية ومحرك البحث الخاص**  
✅ **فهم الهيكل القابل للتوسع**  

### الخطوات التالية

1. **تطوير وكلاء ذكاء اصطناعي متقدمة**: تنفيذ وكلاء بحث خاصة بالنطاق
2. **نشر البيئة المؤسسية**: النظر في نشر مجموعة Kubernetes
3. **تكامل API**: توسيع التكامل مع أدوات البحث الحالية
4. **مساهمة المجتمع**: المشاركة في مشروع MAESTRO مفتوح المصدر

اختبر تحسينات الإنتاجية البحثية الثورية مع MAESTRO واستكشف الإمكانيات اللانهائية لوكلاء الذكاء الاصطناعي! 🚀

---

**المراجع**
- [مستودع MAESTRO على GitHub](https://github.com/murtaza-nasir/maestro)
- [وثائق Docker Compose الرسمية](https://docs.docker.com/compose/)
- [دليل PostgreSQL + pgvector](https://github.com/pgvector/pgvector)
- [دليل إعداد SearXNG](https://docs.searxng.org/)
