---
title: "Shannon AI Agent Orchestrator: دليل شامل لإدارة وكلاء الذكاء الاصطناعي على مستوى المؤسسات"
excerpt: "تعلم كيفية إعداد واستخدام Shannon، منسق وكلاء الذكاء الاصطناعي مفتوح المصدر مع أمان على مستوى المؤسسات وضوابط التكلفة ومرونة البائعين. دليل شامل من التثبيت إلى سير العمل المتقدم متعدد الوكلاء."
seo_title: "دروس Shannon AI Agent Orchestrator - إدارة وكلاء الذكاء الاصطناعي للمؤسسات"
seo_description: "دروس شاملة لـ Shannon AI Agent Orchestrator: التثبيت والتكوين وسير العمل متعدد الوكلاء وميزات الأمان ودليل النشر للمؤسسات."
date: 2025-10-11
categories:
  - tutorials
tags:
  - AI-Agent
  - Orchestrator
  - Multi-Agent
  - Enterprise-AI
  - Shannon
  - Docker
  - Microservices
  - LLM
author_profile: true
toc: true
toc_label: "جدول المحتويات"
lang: ar
permalink: /ar/tutorials/shannon-ai-agent-orchestrator-tutorial/
canonical_url: "https://thakicloud.github.io/ar/tutorials/shannon-ai-agent-orchestrator-tutorial/"
---

⏱️ **وقت القراءة المقدر**: 15 دقيقة

## مقدمة

Shannon هو منسق وكلاء الذكاء الاصطناعي مفتوح المصدر يوفر أماناً على مستوى المؤسسات وضوابط التكلفة ومرونة البائعين. على عكس الحلول الاحتكارية مثل OpenAI AgentKit، يوفر Shannon تحكماً كاملاً في البنية التحتية للذكاء الاصطناعي مع الحفاظ على الموثوقية والقابلية للتوسع الجاهزة للإنتاج.

### ما يجعل Shannon مميزاً

يتميز Shannon في مجال تنسيق وكلاء الذكاء الاصطناعي بهندسته المعمارية الفريدة وميزاته:

- **هندسة متعددة اللغات**: منسق Go، نواة الوكيل Rust، خدمة LLM Python
- **أمان المؤسسات**: تطبيق سياسات OPA، صندوق الحماية WASI، التحكم الدقيق في الوصول
- **إدارة التكلفة**: إدارة ميزانية الرموز، أنماط قاطع الدائرة، الاسترداد التلقائي من الأعطال
- **مرونة البائع**: دعم متعدد الموردين LLM (OpenAI، Anthropic، Google، DeepSeek)
- **ذاكرة متقدمة**: ذاكرة متجهة مع Qdrant، ذاكرة هرمية، كشف التكرار
- **التواصل في الوقت الفعلي**: تدفق WebSocket و SSE مع تصفية الأحداث

## المتطلبات المسبقة

قبل بدء هذا البرنامج التعليمي، تأكد من وجود:

- Docker و Docker Compose مثبتان
- فهم أساسي للتطبيقات المحتواة
- الإلمام بـ REST APIs والخدمات المصغرة
- مفتاح API من موفر LLM واحد على الأقل (OpenAI، Anthropic، إلخ)

## التثبيت والإعداد

### 1. استنساخ المستودع

```bash
git clone https://github.com/Kocoro-lab/Shannon.git
cd Shannon
```

### 2. تكوين البيئة

إنشاء ملف تكوين البيئة:

```bash
cp .env.example .env
```

تحرير ملف `.env` مع التكوين الخاص بك:

```bash
# تكوين موفر LLM
OPENAI_API_KEY=your_openai_api_key_here
ANTHROPIC_API_KEY=your_anthropic_api_key_here

# تكوين قاعدة البيانات
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_DB=shannon
POSTGRES_USER=shannon
POSTGRES_PASSWORD=your_secure_password

# تكوين Redis
REDIS_HOST=redis
REDIS_PORT=6379

# قاعدة بيانات Qdrant المتجهة
QDRANT_HOST=qdrant
QDRANT_PORT=6333

# منافذ الخدمة
ORCHESTRATOR_PORT=8080
AGENT_CORE_PORT=8081
LLM_SERVICE_PORT=8082
```

### 3. بدء خدمات Shannon

يوفر Shannon ملف Makefile مريح لإدارة الخدمات:

```bash
# بدء جميع الخدمات
make up

# عرض حالة الخدمة
make ps

# عرض السجلات
make logs

# إيقاف الخدمات
make down
```

### 4. التحقق من التثبيت

تحقق من تشغيل جميع الخدمات:

```bash
# فحص صحة المنسق
curl http://localhost:8080/health

# فحص صحة نواة الوكيل
curl http://localhost:8081/health

# فحص صحة خدمة LLM
curl http://localhost:8082/health
```

## المفاهيم الأساسية

### نظرة عامة على الهندسة المعمارية

يتبع Shannon هندسة الخدمات المصغرة مع ثلاثة مكونات رئيسية:

1. **منسق Go**: يدير سير العمل والجلسات وتنسيق الوكلاء
2. **نواة الوكيل Rust**: يتعامل مع تنفيذ الوكيل وإدارة الذاكرة وتكامل الأدوات
3. **خدمة LLM Python**: توفر واجهة موحدة لموفري LLM متعددين

### أنماط الوكيل

يدعم Shannon أنماط تنسيق متعددة:

- **ReAct**: التفكير والعمل في نماذج اللغة
- **Tree-of-Thoughts**: استكشاف مسارات التفكير المتعددة
- **Chain-of-Thought**: خطوات التفكير المتسلسلة
- **Debate**: وكلاء متعددون يناقشون ويصلون إلى إجماع
- **Reflection**: التقييم الذاتي والتحسين

## دروس الاستخدام الأساسي

### 1. إنشاء وكيلك الأول

لننشئ وكيلاً بسيطاً يمكنه الإجابة على الأسئلة وأداء المهام الأساسية:

```bash
curl -X POST http://localhost:8080/api/v1/agents \
  -H "Content-Type: application/json" \
  -d '{
    "name": "research-assistant",
    "description": "مساعد بحث مفيد",
    "system_prompt": "أنت مساعد بحث مطلع. قدم إجابات دقيقة ومدروسة جيداً لأسئلة المستخدمين.",
    "model_provider": "openai",
    "model_name": "gpt-4",
    "max_tokens": 2000,
    "temperature": 0.7
  }'
```

### 2. بدء جلسة

إنشاء جلسة للتفاعل مع وكيلك:

```bash
curl -X POST http://localhost:8080/api/v1/sessions \
  -H "Content-Type: application/json" \
  -d '{
    "agent_id": "research-assistant",
    "session_config": {
      "max_turns": 50,
      "context_window": 10,
      "memory_enabled": true
    }
  }'
```

### 3. إرسال الرسائل

إرسال رسالة إلى وكيلك:

```bash
curl -X POST http://localhost:8080/api/v1/sessions/{session_id}/messages \
  -H "Content-Type: application/json" \
  -d '{
    "content": "ما هي الفوائد الرئيسية لهندسة الخدمات المصغرة؟",
    "message_type": "user"
  }'
```

### 4. الاستجابات المتدفقة

للاستجابات في الوقت الفعلي، استخدم نقطة النهاية المتدفقة:

```bash
curl -N http://localhost:8080/api/v1/sessions/{session_id}/stream \
  -H "Accept: text/event-stream"
```

## الميزات المتقدمة

### سير العمل متعدد الوكلاء

يتفوق Shannon في تنسيق وكلاء متعددين يعملون معاً. إليك كيفية إعداد سير عمل متعدد الوكلاء:

#### 1. تحديد أدوار الوكيل

```yaml
# workflow.yaml
name: "content-creation-pipeline"
description: "سير عمل إنشاء المحتوى متعدد الوكلاء"

agents:
  - name: "researcher"
    role: "research"
    system_prompt: "أنت باحث شامل. اجمع معلومات شاملة حول المواضيع المعطاة."
    model: "gpt-4"
    
  - name: "writer"
    role: "content-creation"
    system_prompt: "أنت كاتب ماهر. أنشئ محتوى جذاب بناءً على البحث."
    model: "claude-3-sonnet"
    
  - name: "editor"
    role: "review"
    system_prompt: "أنت محرر دقيق. راجع وحسن جودة المحتوى."
    model: "gpt-4"

workflow:
  pattern: "sequential"
  steps:
    - agent: "researcher"
      task: "ابحث في الموضوع المعطى بشمولية"
      output_to: ["writer"]
      
    - agent: "writer"
      task: "أنشئ محتوى بناءً على البحث"
      input_from: ["researcher"]
      output_to: ["editor"]
      
    - agent: "editor"
      task: "راجع وحسن المحتوى"
      input_from: ["writer"]
      final_output: true
```

#### 2. تنفيذ سير العمل متعدد الوكلاء

```bash
curl -X POST http://localhost:8080/api/v1/workflows \
  -H "Content-Type: application/json" \
  -d '{
    "workflow_file": "workflow.yaml",
    "input": {
      "topic": "مستقبل الذكاء الاصطناعي في الرعاية الصحية",
      "target_audience": "المهنيين الصحيين",
      "word_count": 1500
    }
  }'
```

### إدارة الذاكرة

يوفر Shannon قدرات إدارة ذاكرة متطورة:

#### تكوين الذاكرة المتجهة

```json
{
  "memory_config": {
    "vector_memory": {
      "enabled": true,
      "collection_name": "agent_memory",
      "embedding_model": "text-embedding-ada-002",
      "similarity_threshold": 0.8,
      "max_results": 10
    },
    "hierarchical_memory": {
      "enabled": true,
      "recent_messages": 20,
      "semantic_compression": true,
      "deduplication_threshold": 0.95
    }
  }
}
```

#### الاستعلام عن ذاكرة الوكيل

```bash
curl -X GET "http://localhost:8080/api/v1/sessions/{session_id}/memory?query=فوائد+الخدمات+المصغرة&limit=5" \
  -H "Accept: application/json"
```

### الأمان والتحكم في الوصول

يستخدم Shannon Open Policy Agent (OPA) للتحكم الدقيق في الوصول:

#### 1. تحديد سياسات الأمان

```rego
# policies/agent_access.rego
package shannon.agent_access

import future.keywords.if

# السماح بالوصول إذا كان لدى المستخدم الدور المطلوب
allow if {
    input.user.roles[_] == "agent_operator"
    input.action == "create_agent"
}

# تقييد الوصول للنموذج بناءً على مستوى المستخدم
allow if {
    input.user.tier == "premium"
    input.agent.model in ["gpt-4", "claude-3-opus"]
}

# تطبيق الميزانية
allow if {
    input.user.monthly_budget > input.estimated_cost
}
```

#### 2. تطبيق السياسات

```bash
curl -X POST http://localhost:8080/api/v1/policies \
  -H "Content-Type: application/json" \
  -d '{
    "name": "agent_access_policy",
    "policy_file": "policies/agent_access.rego",
    "enabled": true
  }'
```

### إدارة التكلفة

يوفر Shannon ميزات إدارة تكلفة شاملة:

#### 1. تعيين حدود الميزانية

```bash
curl -X POST http://localhost:8080/api/v1/budgets \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "user123",
    "monthly_limit": 100.00,
    "per_session_limit": 10.00,
    "alert_threshold": 0.8,
    "currency": "USD"
  }'
```

#### 2. مراقبة الاستخدام

```bash
curl -X GET http://localhost:8080/api/v1/usage/user123 \
  -H "Accept: application/json"
```

### تكامل الأدوات

يدعم Shannon طرق تكامل أدوات متعددة:

#### 1. أدوات MCP (Model Context Protocol)

```json
{
  "tools": [
    {
      "type": "mcp",
      "name": "file_operations",
      "server_url": "mcp://localhost:3000",
      "capabilities": ["read_file", "write_file", "list_directory"]
    }
  ]
}
```

#### 2. أدوات OpenAPI

```json
{
  "tools": [
    {
      "type": "openapi",
      "name": "weather_api",
      "spec_url": "https://api.weather.com/openapi.json",
      "auth": {
        "type": "api_key",
        "key": "your_weather_api_key"
      }
    }
  ]
}
```

## النشر الإنتاجي

### إعداد Docker Compose للإنتاج

للنشر الإنتاجي، استخدم التكوين الإنتاجي المقدم:

```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  orchestrator:
    image: shannon/orchestrator:latest
    environment:
      - ENV=production
      - LOG_LEVEL=info
    deploy:
      replicas: 3
      resources:
        limits:
          memory: 1G
          cpus: '0.5'
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  agent-core:
    image: shannon/agent-core:latest
    deploy:
      replicas: 2
      resources:
        limits:
          memory: 2G
          cpus: '1.0'

  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: shannon_prod
      POSTGRES_USER: shannon
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    deploy:
      resources:
        limits:
          memory: 2G

volumes:
  postgres_data:
```

### نشر Kubernetes

يوفر Shannon أيضاً بيانات Kubernetes للنشر السحابي:

```yaml
# k8s/orchestrator-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shannon-orchestrator
spec:
  replicas: 3
  selector:
    matchLabels:
      app: shannon-orchestrator
  template:
    metadata:
      labels:
        app: shannon-orchestrator
    spec:
      containers:
      - name: orchestrator
        image: shannon/orchestrator:latest
        ports:
        - containerPort: 8080
        env:
        - name: POSTGRES_HOST
          value: "postgres-service"
        - name: REDIS_HOST
          value: "redis-service"
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
```

## المراقبة والملاحظة

يتضمن Shannon قدرات مراقبة شاملة:

### 1. جمع المقاييس

يعرض Shannon مقاييس Prometheus:

```bash
# عرض المقاييس المتاحة
curl http://localhost:8080/metrics
```

### 2. لوحات معلومات Grafana

استيراد لوحة معلومات Grafana المقدمة:

```bash
# استيراد لوحة معلومات Shannon
curl -X POST http://grafana:3000/api/dashboards/db \
  -H "Content-Type: application/json" \
  -d @observability/grafana/shannon-dashboard.json
```

### 3. التتبع الموزع

تمكين التتبع الموزع مع Jaeger:

```yaml
# docker-compose.yml
services:
  jaeger:
    image: jaegertracing/all-in-one:latest
    ports:
      - "16686:16686"
      - "14268:14268"
    environment:
      - COLLECTOR_OTLP_ENABLED=true
```

## استكشاف الأخطاء وإصلاحها

### المشاكل الشائعة والحلول

#### 1. مشاكل اتصال الخدمة

```bash
# فحص سجلات الخدمة
make logs

# إعادة تشغيل خدمة محددة
docker-compose restart orchestrator

# فحص اتصال الشبكة
docker network ls
docker network inspect shannon_default
```

#### 2. مشاكل الذاكرة

```bash
# مراقبة استخدام الذاكرة
docker stats

# تعديل حدود الذاكرة في docker-compose.yml
services:
  agent-core:
    deploy:
      resources:
        limits:
          memory: 4G
```

#### 3. مشاكل اتصال قاعدة البيانات

```bash
# فحص سجلات PostgreSQL
docker-compose logs postgres

# اختبار اتصال قاعدة البيانات
docker-compose exec postgres psql -U shannon -d shannon -c "SELECT 1;"
```

### تحسين الأداء

#### 1. تجميع الاتصالات

تكوين تجميع الاتصالات لأداء أفضل:

```yaml
# config/database.yaml
database:
  max_connections: 100
  max_idle_connections: 10
  connection_max_lifetime: 3600
```

#### 2. تكوين التخزين المؤقت

تحسين تخزين Redis المؤقت:

```yaml
# config/redis.yaml
redis:
  max_connections: 50
  idle_timeout: 300
  cache_ttl: 3600
```

## أفضل الممارسات

### 1. تصميم الوكيل

- **المسؤولية الواحدة**: تصميم وكلاء بأدوار محددة ومعرفة جيداً
- **تعليمات النظام الواضحة**: تقديم تعليمات مفصلة وغير غامضة
- **اختيار النموذج المناسب**: اختيار النماذج بناءً على تعقيد المهمة ومتطلبات التكلفة

### 2. تصميم سير العمل

- **معالجة الأخطاء**: تنفيذ معالجة أخطاء قوية وآليات احتياطية
- **إدارة الموارد**: تعيين مهلات زمنية وحدود موارد مناسبة
- **المراقبة**: تضمين تسجيل ومراقبة شاملين

### 3. الأمان

- **إدارة مفاتيح API**: استخدام أنظمة إدارة أسرار آمنة
- **التحكم في الوصول**: تنفيذ سياسات تحكم وصول دقيقة
- **تسجيل المراجعة**: تمكين تسجيل مراجعة شامل للامتثال

### 4. تحسين التكلفة

- **مراقبة الميزانية**: إعداد تنبيهات لحدود الميزانية
- **اختيار النموذج**: استخدام نماذج فعالة من حيث التكلفة للمهام المناسبة
- **التخزين المؤقت**: تنفيذ تخزين مؤقت ذكي لتقليل استدعاءات API

## الخلاصة

يوفر Shannon AI Agent Orchestrator منصة قوية ومرنة لبناء ونشر أنظمة وكلاء الذكاء الاصطناعي على مستوى المؤسسات. مع هندسته المعمارية للخدمات المصغرة وميزات الأمان الشاملة وقدرات التنسيق المتقدمة، يمكن Shannon للمؤسسات من تسخير قوة وكلاء الذكاء الاصطناعي مع الحفاظ على التحكم والأمان وكفاءة التكلفة.

تضمن طبيعة المنصة مفتوحة المصدر الشفافية وقابلية التخصيص، بينما تجعل ميزاتها الجاهزة للإنتاج مناسبة للنشر المؤسسي. سواء كنت تبني روبوتات محادثة بسيطة أو سير عمل معقد متعدد الوكلاء، يوفر Shannon الأدوات والبنية التحتية اللازمة للنجاح.

### الخطوات التالية

1. **استكشاف الأنماط المتقدمة**: تجريب أنماط تنسيق مختلفة مثل Tree-of-Thoughts و Debate
2. **تطوير أدوات مخصصة**: إنشاء أدوات مخصصة باستخدام بروتوكول MCP
3. **النشر الإنتاجي**: نشر Shannon في بيئتك الإنتاجية
4. **المشاركة المجتمعية**: انضم إلى مجتمع Shannon على Discord وساهم في المشروع

### الموارد

- **مستودع GitHub**: [https://github.com/Kocoro-lab/Shannon](https://github.com/Kocoro-lab/Shannon)
- **التوثيق**: متاح في دليل `docs/`
- **مجتمع Discord**: انضم للدعم والمناقشات
- **دليل المساهمة**: راجع `CONTRIBUTING.md` لإرشادات المساهمة

يمثل Shannon مستقبل تنسيق وكلاء الذكاء الاصطناعي - مفتوح وآمن وجاهز للمؤسسات. ابدأ في بناء أنظمة وكلاء الذكاء الاصطناعي اليوم!
