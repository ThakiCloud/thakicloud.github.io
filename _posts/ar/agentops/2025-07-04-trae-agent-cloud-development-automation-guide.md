---
title: "TRAE Agent: دليل شامل لأتمتة التطوير السحابي - هندسة البرمجيات بالذكاء الاصطناعي"
excerpt: "دليل شامل لـ TRAE Agent من ByteDance، وكيل هندسة البرمجيات المدعوم بالذكاء الاصطناعي. تغطية معمّقة لتخطيط المهام وإدارة الملفات وعمليات الشل والتنفيذ الآلي."
seo_title: "دليل TRAE Agent الشامل - وكيل هندسة البرمجيات من ByteDance - Thaki Cloud"
seo_description: "دليل تقني شامل لـ TRAE Agent من ByteDance. وكيل AI لأتمتة تطوير البرمجيات، تخطيط المهام، تكامل الأدوات المتعددة، وأتمتة سير عمل التطوير مع تسجيل المسارات."
date: 2025-07-04
last_modified_at: 2025-07-04
categories:
  - agentops
tags:
  - trae-agent
  - ByteDance
  - ai-software-engineering
  - development-automation
  - llm-agents
  - trajectory-recording
  - cli-tools
  - code-automation
  - software-engineering
  - agentic-ai
author_profile: true
toc: true
toc_label: "جدول المحتويات"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/ar/agentops/trae-agent-cloud-development-automation-guide/"
lang: ar
---

⏱️ **وقت القراءة المقدر**: 12 دقائق

## مقدمة

**TRAE Agent** هو وكيل هندسة برمجيات مدعوم بالذكاء الاصطناعي طوّرته ByteDance. يُؤتمت العملية الكاملة لبناء التطبيقات وتعديلها وتوسيعها من خلال قدرات التخطيط المتقدم واستخدام الأدوات المتعددة وتسجيل المسارات.

يقوم TRAE Agent على فلسفة تتجاوز مجرد توليد الكود: فهو يعمل كوكيل ذكي يفهم مهام التطوير بعمق، ويخطط بشكل منهجي، وينفّذ من البداية إلى النهاية.

![مخطط مفاهيمي](/assets/images/trae-agent-cloud-development-automation-guide-diagram.svg)

*مخطط مفاهيمي*

## المعمارية الجوهرية

يتمحور TRAE Agent حول ثلاثة مكونات رئيسية:

### 1. مخطط المهام

```python
from trae import TaskPlanner

planner = TaskPlanner(model="claude-3-7-sonnet-latest")

plan = planner.plan(
    task="بناء REST API لمصادقة المستخدمين باستخدام رموز JWT",
    codebase_context="/path/to/project"
)

for step in plan.steps:
    print(f"الخطوة {step.index}: {step.description}")
    print(f"  الأدوات: {step.required_tools}")
    print(f"  الملفات: {step.affected_files}")
```

### 2. منفذ الأدوات

```python
from trae.tools import (
    FileManager,
    ShellExecutor,
    CodeSearcher,
    WebFetcher
)

# عمليات الملفات
fm = FileManager(working_dir="/project")
content = fm.read("src/main.py")
fm.write("src/auth.py", new_content)
fm.patch("src/main.py", diff_patch)

# عمليات الشل
shell = ShellExecutor()
result = shell.run("pytest tests/ -v")
print(result.stdout)

# بحث الكود
searcher = CodeSearcher(codebase="/project")
matches = searcher.find_usages("authenticate_user")
```

### 3. مُسجِّل المسارات

كل إجراء يُسجَّل لإمكانية الإعادة والتصحيح:

```json
{
  "trajectory_id": "traj_2025_07_04_001",
  "task": "إضافة تحديد المعدل لنقاط نهاية المصادقة",
  "steps": [
    {
      "step": 1,
      "tool": "read_file",
      "input": "src/auth/router.py",
      "timestamp": "2025-07-04T09:00:01Z"
    },
    {
      "step": 2,
      "tool": "web_search",
      "input": "أفضل ممارسات تحديد المعدل في fastapi 2025",
      "timestamp": "2025-07-04T09:00:03Z"
    },
    {
      "step": 3,
      "tool": "write_file",
      "input": {
        "path": "src/auth/rate_limit.py",
        "content": "..."
      },
      "timestamp": "2025-07-04T09:00:10Z"
    }
  ]
}
```

## التثبيت والإعداد

```bash
# تثبيت trae-cli
pip install trae-cli

# أو من المصدر
git clone https://github.com/bytedance/trae-agent.git
cd trae-agent
pip install -e .

# تكوين مفاتيح API
trae config set --provider anthropic --api-key $ANTHROPIC_API_KEY
trae config set --provider openai --api-key $OPENAI_API_KEY

# التحقق من التثبيت
trae --version
```

### ملف التكوين

```json
{
  "default_provider": "anthropic",
  "default_model": "claude-3-7-sonnet-latest",
  "trajectory": {
    "enabled": true,
    "output_dir": "~/.trae/trajectories"
  },
  "tools": {
    "shell": {
      "allowed_commands": ["git", "npm", "pip", "pytest", "make"],
      "timeout_seconds": 60
    },
    "web": {
      "enabled": true,
      "max_results": 10
    }
  }
}
```

## الاستخدام الأساسي

### واجهة سطر الأوامر

```bash
# مهمة بسيطة
trae run "إضافة التحقق من صحة المدخلات لنقطة نهاية تسجيل المستخدمين"

# مع سياق المشروع
trae run "إعادة هيكلة تجميع اتصالات قاعدة البيانات" --project /path/to/project

# الوضع التفاعلي
trae chat

# تشغيل جاف (تخطيط فقط، بدون تنفيذ)
trae run "إضافة طبقة تخزين مؤقت" --dry-run
```

### Python API

```python
from trae import TraeAgent

agent = TraeAgent(
    model="claude-3-7-sonnet-latest",
    project_path="/path/to/project",
    record_trajectory=True
)

result = agent.run(
    task="تطبيق الترقيم الصفحي لنقطة نهاية API للمنتجات",
    context="نستخدم FastAPI مع SQLAlchemy وPostgreSQL"
)

print("الحالة:", result.status)
print("الملفات المُعدَّلة:", result.modified_files)
print("مسار المسار:", result.trajectory_path)
```

## الميزات المتقدمة

### تكامل الأدوات المخصصة

```python
from trae.tools import BaseTool
from typing import Any

class DatabaseInspector(BaseTool):
    name = "database_inspector"
    description = "فحص مخطط قاعدة البيانات وخطط تنفيذ الاستعلامات"
    
    def __init__(self, connection_string: str):
        self.connection_string = connection_string
    
    def get_schema(self, table: str) -> dict:
        """إرجاع تعريفات الأعمدة لجدول."""
        ...
    
    def explain_query(self, sql: str) -> str:
        """تشغيل EXPLAIN ANALYZE على استعلام."""
        ...
    
    def execute(self, action: str, **kwargs: Any) -> Any:
        if action == "get_schema":
            return self.get_schema(kwargs["table"])
        elif action == "explain":
            return self.explain_query(kwargs["sql"])
        raise ValueError(f"إجراء غير معروف: {action}")

agent = TraeAgent(model="claude-3-7-sonnet-latest")
agent.register_tool(DatabaseInspector("postgresql://localhost/mydb"))
```

## التكامل مع سير عمل التطوير

### التكامل مع GitHub Actions

```yaml
# .github/workflows/trae-review.yml
name: مراجعة كود TRAE

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  ai-review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: إعداد Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'

      - name: تثبيت TRAE
        run: pip install trae-cli

      - name: تشغيل مراجعة AI
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          git diff origin/main...HEAD --name-only > changed_files.txt
          
          trae run "راجع تغييرات الكود في هذه الملفات للأخطاء ومشكلات الأمان وانتهاكات أفضل الممارسات" \
            --context-files changed_files.txt \
            --output review.md

      - name: نشر تعليق المراجعة
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const review = fs.readFileSync('review.md', 'utf8');
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `## مراجعة كود AI\n\n${review}`
            });
```

## النشر على Kubernetes للاستخدام الجماعي

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: trae-server
  namespace: dev-tools
spec:
  replicas: 2
  selector:
    matchLabels:
      app: trae-server
  template:
    metadata:
      labels:
        app: trae-server
    spec:
      containers:
      - name: trae-server
        image: your-registry/trae-server:latest
        ports:
        - containerPort: 8080
        env:
        - name: ANTHROPIC_API_KEY
          valueFrom:
            secretKeyRef:
              name: ai-secrets
              key: anthropic-key
        - name: TRAE_TRAJECTORY_DIR
          value: "/data/trajectories"
        resources:
          requests:
            memory: "1Gi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "1000m"
        volumeMounts:
        - name: trajectory-storage
          mountPath: /data/trajectories
      volumes:
      - name: trajectory-storage
        persistentVolumeClaim:
          claimName: trae-trajectories-pvc
```

## الأمان

### التنفيذ في بيئة معزولة

```python
from trae import TraeAgent
from trae.sandbox import DockerSandbox

sandbox = DockerSandbox(
    image="python:3.12-slim",
    memory_limit="2g",
    cpu_limit=1.0,
    network="none",
    readonly_paths=["/project/src"],
    writable_paths=["/project/tests", "/tmp"]
)

agent = TraeAgent(
    model="claude-3-7-sonnet-latest",
    sandbox=sandbox
)
```

### قائمة الأوامر المسموح بها

```python
from trae.security import ShellPolicy

policy = ShellPolicy(
    allowed_commands=["pytest", "python", "pip", "git status", "git diff"],
    blocked_patterns=["rm -rf", "sudo", "curl", "wget", "ssh"],
    require_confirmation=["git commit", "git push"]
)

agent = TraeAgent(
    model="claude-3-7-sonnet-latest",
    shell_policy=policy
)
```

## مثال عملي: بناء ميزة من البداية إلى النهاية

```bash
trae run \
  "إضافة نظام معالجة مهام في الخلفية باستخدام Celery وRedis.
   المتطلبات:
   - قائمة انتظار مهام لإرسال البريد الإلكتروني وإنشاء التقارير
   - نقطة نهاية لتتبع حالة المهام
   - منطق إعادة المحاولة مع التراجع الأسي
   - قائمة انتظار الحروف الميتة للمهام الفاشلة
   - نقطة نهاية لوحة مراقبة" \
  --project /path/to/fastapi-app \
  --model claude-3-7-sonnet-latest \
  --record-trajectory
```

## الخلاصة

يمثل TRAE Agent خطوة ملموسة للأمام في هندسة البرمجيات بمساعدة الذكاء الاصطناعي. يجمع بين تخطيط المهام المنهجي والوصول الثري للأدوات وتسجيل المسارات، مما يجعله أداة عملية لأتمتة سير عمل التطوير الحقيقي.

المزايا الرئيسية:
- **أتمتة شاملة**: يخطط وينفذ الميزات الكاملة
- **تسجيل المسارات**: كل إجراء مُسجَّل للمراجعة وإمكانية الإعادة
- **تكامل مرن للأدوات**: التوسع بأدوات مخصصة لأي قاعدة كود
- **صديق للفريق**: وضع الخادم وتكاملات CI/CD للتعاون الجماعي
- **واعٍ للأمان**: بيئات معزولة وقوائم أوامر مسموح بها للتنفيذ الآمن

---

**المراجع**:
- [TRAE Agent على GitHub](https://github.com/bytedance/trae-agent)
- [أبحاث ByteDance AI](https://ai.bytedance.com)
