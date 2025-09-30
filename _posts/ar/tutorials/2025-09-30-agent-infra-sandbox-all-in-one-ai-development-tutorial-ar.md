---
title: "AIO Sandbox: الدليل الشامل لبيئة تطوير الذكاء الاصطناعي الموحدة"
excerpt: "تعلم كيفية إعداد واستخدام agent-infra/sandbox، بيئة التطوير الشاملة المبنية على Docker التي تجمع أتمتة المتصفح والوصول للطرفية وعمليات الملفات وخادم VSCode وتكامل MCP في حاوية واحدة."
seo_title: "دروس AIO Sandbox: بيئة تطوير الذكاء الاصطناعي الموحدة - Thaki Cloud"
seo_description: "دليل شامل لـ agent-infra/sandbox - حاوية Docker مع أتمتة المتصفح وخادم VSCode وJupyter وتكامل MCP لتطوير وكلاء الذكاء الاصطناعي. دليل الإعداد خطوة بخطوة."
date: 2025-09-30
categories:
  - tutorials
tags:
  - ai-agents
  - docker
  - sandbox
  - mcp
  - browser-automation
  - vscode
  - jupyter
author_profile: true
toc: true
toc_label: "جدول المحتويات"
canonical_url: "https://thakicloud.github.io/ar/tutorials/agent-infra-sandbox-all-in-one-ai-development-tutorial/"
lang: ar
permalink: /ar/tutorials/agent-infra-sandbox-all-in-one-ai-development-tutorial/
---

⏱️ **وقت القراءة المتوقع**: 12 دقيقة

## مقدمة

في عالم تطوير وكلاء الذكاء الاصطناعي سريع التطور، يعد امتلاك بيئة تطوير موحدة وشاملة أمراً بالغ الأهمية للإنتاجية وسير العمل السلس. يوفر **AIO Sandbox** (All-in-One Sandbox) من agent-infra بالضبط ذلك - حاوية Docker واحدة تجمع أتمتة المتصفح والوصول للطرفية وعمليات الملفات وخادم VSCode ودفاتر Jupyter وتكامل بروتوكول السياق النموذجي (MCP).

سيرشدك هذا الدرس خلال إعداد واستخدام AIO Sandbox لتطوير وكلاء الذكاء الاصطناعي، من التثبيت الأساسي إلى أنماط التكامل المتقدمة مع أطر الذكاء الاصطناعي الشائعة.

## ما هو AIO Sandbox؟

AIO Sandbox هو بيئة تطوير مبنية على Docker تدمج أدوات وخدمات متعددة في حاوية واحدة:

- **🌐 أتمتة المتصفح**: تحكم كامل في المتصفح عبر VNC وبروتوكول أدوات تطوير Chrome (CDP) وMCP
- **💻 أدوات التطوير**: خادم VSCode ودفتر Jupyter وطرفية مبنية على WebSocket
- **📁 عمليات الملفات**: وصول كامل لنظام الملفات ومعالجته
- **🤖 تكامل MCP**: خوادم بروتوكول السياق النموذجي مُعدة مسبقاً
- **🚀 معاينات ذكية**: إعادة توجيه المنافذ وقدرات معاينة تطبيقات الويب

جميع المكونات تتشارك نفس نظام الملفات، مما يتيح سير عمل سلس بين الأدوات والواجهات المختلفة.

## المتطلبات المسبقة

قبل البدء، تأكد من توفر:

- Docker مثبت على نظامك
- معرفة أساسية بأوامر Docker
- خبرة في برمجة Python (للأمثلة)
- فهم مفاهيم وكلاء الذكاء الاصطناعي

## تثبيت البداية السريعة

### الطريقة الأولى: تشغيل Docker الأساسي

أسرع طريقة للبدء هي باستخدام أمر Docker بسيط:

```bash
# تشغيل AIO Sandbox على المنفذ 8080
docker run --rm -it -p 8080:8080 ghcr.io/agent-infra/sandbox:latest
```

للمستخدمين في البر الرئيسي للصين، استخدم السجل البديل:

```bash
docker run --rm -it -p 8080:8080 enterprise-public-cn-beijing.cr.volces.com/vefaas-public/all-in-one-sandbox:latest
```

### الطريقة الثانية: استخدام إصدار محدد

لاستخدام إصدار محدد (موصى به للإنتاج):

```bash
# مثال: استخدام الإصدار 1.0.0.125
docker run --rm -it -p 8080:8080 ghcr.io/agent-infra/sandbox:1.0.0.125
```

### الطريقة الثالثة: إعداد Docker Compose

للتكوينات المتقدمة، أنشئ ملف `docker-compose.yaml`:

```yaml
version: '3.8'
services:
  sandbox:
    container_name: aio-sandbox
    image: ghcr.io/agent-infra/sandbox:latest
    volumes:
      - ./workspace:/home/gem/workspace
    security_opt:
      - seccomp:unconfined
    extra_hosts:
      - "host.docker.internal:host-gateway"
    restart: "unless-stopped"
    shm_size: "2gb"
    ports:
      - "8080:8080"
    environment:
      WORKSPACE: "/home/gem"
      TZ: "Asia/Riyadh"
      HOMEPAGE: ""
      BROWSER_EXTRA_ARGS: ""
```

ثم قم بالتشغيل:

```bash
docker-compose up -d
```

## الوصول إلى Sandbox

بمجرد تشغيل الحاوية، يمكنك الوصول إلى واجهات مختلفة:

- **لوحة التحكم الرئيسية**: http://localhost:8080
- **خادم VSCode**: http://localhost:8080/vscode
- **دفتر Jupyter**: http://localhost:8080/jupyter
- **متصفح VNC**: http://localhost:8080/vnc
- **الطرفية**: http://localhost:8080/terminal

## نظرة عامة على المكونات الأساسية

### 1. أتمتة المتصفح

يوفر AIO Sandbox ثلاث طرق للتفاعل مع المتصفحات:

#### واجهة VNC
تفاعل بصري مع المتصفح عبر سطح المكتب البعيد:
- تجربة متصفح GUI كاملة
- تفاعل الماوس ولوحة المفاتيح
- قدرات لقطة الشاشة

#### بروتوكول أدوات تطوير Chrome (CDP)
تحكم برمجي في المتصفح:
- تنقل آلي
- تفاعل العناصر
- مراقبة الأداء
- اعتراض الشبكة

#### أدوات متصفح MCP
أتمتة متصفح عالية المستوى عبر بروتوكول السياق النموذجي:
- API مبسط للمهام الشائعة
- واجهة صديقة للذكاء الاصطناعي
- متكاملة مع خدمات MCP الأخرى

### 2. بيئة التطوير

#### خادم VSCode
تجربة IDE كاملة في متصفحك:
- تمييز الصيغة وIntelliSense
- طرفية متكاملة
- دعم الإضافات
- تكامل Git

#### دفتر Jupyter
تطوير Python تفاعلي:
- تنفيذ الكود في الخلايا
- عرض مخرجات غنية
- تصور البيانات
- توثيق Markdown

### 3. عمليات نظام الملفات

وصول كامل لنظام الملفات من خلال:
- مدير ملفات مبني على الويب
- نقاط نهاية API للوصول البرمجي
- عمليات ملفات الطرفية
- مستكشف ملفات VSCode

## تثبيت واستخدام Python SDK

### تثبيت SDK

```bash
pip install agent-sandbox
```

### الاستخدام الأساسي لـ SDK

إليك مثال شامل يوضح الميزات الرئيسية:

```python
import asyncio
import base64
from playwright.async_api import async_playwright
from agent_sandbox import Sandbox

async def comprehensive_sandbox_demo():
    # تهيئة عميل Sandbox
    client = Sandbox(base_url="http://localhost:8080")
    
    # الحصول على معلومات سياق Sandbox
    context = client.sandbox.get_sandbox_context()
    home_dir = context.home_dir
    print(f"دليل Sandbox الرئيسي: {home_dir}")
    
    # 1. عمليات الملفات
    print("\n=== عمليات الملفات ===")
    
    # إنشاء ملف نموذجي
    sample_content = "مرحباً من AIO Sandbox!\nهذا ملف اختبار."
    client.file.write_file(file=f"{home_dir}/sample.txt", content=sample_content)
    
    # قراءة الملف مرة أخرى
    file_content = client.file.read_file(file=f"{home_dir}/sample.txt")
    print(f"محتوى الملف: {file_content.data.content}")
    
    # سرد الملفات في الدليل
    files = client.file.list_files(directory=home_dir)
    print(f"الملفات في الدليل الرئيسي: {[f.name for f in files.data.files]}")
    
    # 2. عمليات الشل
    print("\n=== عمليات الشل ===")
    
    # تنفيذ أوامر الشل
    result = client.shell.exec_command(command="ls -la")
    print(f"مخرجات الشل: {result.data.output}")
    
    # إنشاء وتنفيذ سكريبت Python
    python_script = """
import datetime
import json

data = {
    'timestamp': datetime.datetime.now().isoformat(),
    'message': 'تم إنشاؤه من AIO Sandbox',
    'numbers': [1, 2, 3, 4, 5]
}

print(json.dumps(data, indent=2, ensure_ascii=False))
"""
    
    client.file.write_file(file=f"{home_dir}/script.py", content=python_script)
    script_result = client.shell.exec_command(command=f"cd {home_dir} && python script.py")
    print(f"مخرجات سكريبت Python: {script_result.data.output}")
    
    # 3. عمليات Jupyter
    print("\n=== عمليات Jupyter ===")
    
    # تنفيذ كود Python في Jupyter
    jupyter_code = f"""
import matplotlib.pyplot as plt
import numpy as np

# إنشاء بيانات نموذجية
x = np.linspace(0, 10, 100)
y = np.sin(x)

# إنشاء الرسم البياني
plt.figure(figsize=(10, 6))
plt.plot(x, y, 'b-', linewidth=2, label='sin(x)')
plt.xlabel('x')
plt.ylabel('y')
plt.title('موجة جيبية تم إنشاؤها في AIO Sandbox')
plt.legend()
plt.grid(True)
plt.savefig('{home_dir}/sine_wave.png', dpi=150, bbox_inches='tight')
plt.show()

print("تم حفظ الرسم البياني بنجاح!")
"""
    
    jupyter_result = client.jupyter.execute_jupyter_code(code=jupyter_code)
    print(f"نتيجة تنفيذ Jupyter: {jupyter_result.data}")
    
    # 4. أتمتة المتصفح
    print("\n=== أتمتة المتصفح ===")
    
    # الحصول على معلومات المتصفح
    browser_info = client.browser.get_browser_info()
    print(f"رابط CDP للمتصفح: {browser_info.data.cdp_url}")
    
    # استخدام Playwright مع متصفح sandbox
    async with async_playwright() as p:
        browser = await p.chromium.connect_over_cdp(browser_info.data.cdp_url)
        page = await browser.new_page()
        
        # التنقل إلى موقع ويب
        await page.goto("https://httpbin.org/json", wait_until="networkidle")
        
        # الحصول على محتوى الصفحة
        content = await page.content()
        print(f"عنوان الصفحة: {await page.title()}")
        
        # أخذ لقطة شاشة
        screenshot_bytes = await page.screenshot()
        screenshot_b64 = base64.b64encode(screenshot_bytes).decode('utf-8')
        
        # حفظ معلومات لقطة الشاشة
        client.file.write_file(
            file=f"{home_dir}/screenshot_info.txt", 
            content=f"تم أخذ لقطة الشاشة في: {asyncio.get_event_loop().time()}\nالحجم: {len(screenshot_bytes)} بايت"
        )
        
        await browser.close()
    
    print("تمت أتمتة المتصفح بنجاح!")
    
    # 5. عمليات الملفات المتقدمة
    print("\n=== عمليات الملفات المتقدمة ===")
    
    # البحث عن الملفات
    search_result = client.file.search_files(directory=home_dir, pattern="*.py")
    print(f"ملفات Python الموجودة: {[f.path for f in search_result.data.files]}")
    
    # إنشاء تقرير شامل
    report_content = f"""
# تقرير عرض AIO Sandbox

تم الإنشاء في: {asyncio.get_event_loop().time()}

## الملفات المُنشأة:
- sample.txt: ملف نصي أساسي
- script.py: سكريبت Python مع مخرجات JSON
- sine_wave.png: تصور Matplotlib
- screenshot_info.txt: بيانات وصفية للقطة شاشة المتصفح

## العمليات المنفذة:
1. عمليات قراءة/كتابة الملفات
2. تنفيذ أوامر الشل
3. تنفيذ كود Jupyter مع التصور
4. أتمتة المتصفح باستخدام Playwright
5. البحث في الملفات وسرد الأدلة

## بيئة Sandbox:
- الدليل الرئيسي: {home_dir}
- CDP المتصفح متاح: نعم
- نواة Jupyter: نشطة
- وصول الشل: متاح

يوضح هذا التقرير القدرات الشاملة لـ AIO Sandbox
لتطوير وكلاء الذكاء الاصطناعي ومهام الأتمتة.
"""
    
    client.file.write_file(file=f"{home_dir}/demo_report.md", content=report_content)
    print("اكتمل العرض الشامل! تحقق من demo_report.md للملخص.")

if __name__ == "__main__":
    asyncio.run(comprehensive_sandbox_demo())
```

## أمثلة التكامل المتقدمة

### التكامل مع LangChain

```python
from langchain.tools import BaseTool
from agent_sandbox import Sandbox
from typing import Optional

class SandboxExecutionTool(BaseTool):
    name = "sandbox_execute"
    description = """تنفيذ الأوامر في بيئة AIO Sandbox. 
    مفيد لتشغيل الكود وعمليات الملفات وأتمتة المتصفح."""
    
    def __init__(self, sandbox_url: str = "http://localhost:8080"):
        super().__init__()
        self.client = Sandbox(base_url=sandbox_url)
    
    def _run(self, command: str, operation_type: str = "shell") -> str:
        """تنفيذ الأمر في sandbox بناءً على نوع العملية."""
        try:
            if operation_type == "shell":
                result = self.client.shell.exec_command(command=command)
                return result.data.output
            elif operation_type == "jupyter":
                result = self.client.jupyter.execute_jupyter_code(code=command)
                return str(result.data)
            elif operation_type == "file_read":
                result = self.client.file.read_file(file=command)
                return result.data.content
            else:
                return f"نوع عملية غير مدعوم: {operation_type}"
        except Exception as e:
            return f"خطأ في تنفيذ الأمر: {str(e)}"

# مثال الاستخدام
sandbox_tool = SandboxExecutionTool()

# تنفيذ كود Python
python_result = sandbox_tool._run(
    command="print('مرحباً من LangChain + AIO Sandbox!')", 
    operation_type="jupyter"
)
print(python_result)
```

### التكامل مع OpenAI Assistant

```python
import json
from openai import OpenAI
from agent_sandbox import Sandbox

class OpenAISandboxIntegration:
    def __init__(self, openai_api_key: str, sandbox_url: str = "http://localhost:8080"):
        self.openai_client = OpenAI(api_key=openai_api_key)
        self.sandbox = Sandbox(base_url=sandbox_url)
    
    def run_code(self, code: str, language: str = "python") -> dict:
        """تنفيذ الكود في sandbox وإرجاع النتائج."""
        try:
            if language == "python":
                result = self.sandbox.jupyter.execute_jupyter_code(code=code)
                return {"success": True, "output": result.data}
            elif language == "shell":
                result = self.sandbox.shell.exec_command(command=code)
                return {"success": True, "output": result.data.output}
            else:
                return {"success": False, "error": f"لغة غير مدعومة: {language}"}
        except Exception as e:
            return {"success": False, "error": str(e)}
    
    def chat_with_code_execution(self, user_message: str) -> str:
        """المحادثة مع OpenAI وتنفيذ الكود عند الحاجة."""
        tools = [{
            "type": "function",
            "function": {
                "name": "run_code",
                "description": "تنفيذ كود Python أو shell في بيئة sandbox",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "code": {"type": "string", "description": "الكود المراد تنفيذه"},
                        "language": {"type": "string", "enum": ["python", "shell"], "default": "python"}
                    },
                    "required": ["code"]
                }
            }
        }]
        
        response = self.openai_client.chat.completions.create(
            model="gpt-4",
            messages=[{"role": "user", "content": user_message}],
            tools=tools
        )
        
        message = response.choices[0].message
        
        if message.tool_calls:
            # تنفيذ الكود
            tool_call = message.tool_calls[0]
            args = json.loads(tool_call.function.arguments)
            result = self.run_code(**args)
            
            if result["success"]:
                return f"تم تنفيذ الكود بنجاح:\n{result['output']}"
            else:
                return f"فشل تنفيذ الكود: {result['error']}"
        else:
            return message.content

# مثال الاستخدام
integration = OpenAISandboxIntegration(openai_api_key="your_api_key")
response = integration.chat_with_code_execution("احسب مضروب العدد 10 وأنشئ رسماً بيانياً بسيطاً")
print(response)
```

## تكامل MCP (بروتوكول السياق النموذجي)

يأتي AIO Sandbox مع خوادم MCP مُعدة مسبقاً توفر واجهات صديقة للذكاء الاصطناعي:

### خوادم MCP المتاحة

1. **Browser MCP**: أتمتة الويب والكشط
2. **File MCP**: عمليات نظام الملفات
3. **Shell MCP**: تنفيذ الأوامر
4. **Markitdown MCP**: معالجة المستندات
5. **Arxiv MCP**: الوصول للأوراق البحثية

### استخدام أدوات MCP

```python
from agent_sandbox import Sandbox

def demonstrate_mcp_tools():
    client = Sandbox(base_url="http://localhost:8080")
    
    # مثال: استخدام browser MCP لكشط الويب
    # يُستخدم عادة من خلال عميل MCP
    # يوفر sandbox نقاط نهاية الخادم
    
    # الحصول على معلومات خادم MCP
    context = client.sandbox.get_sandbox_context()
    print(f"خوادم MCP متاحة في: {context.home_dir}")
    
    # مثال على دمج أدوات متعددة
    # 1. استخدام المتصفح لجلب المحتوى
    browser_info = client.browser.get_browser_info()
    
    # 2. استخدام عمليات الملفات لحفظ النتائج
    client.file.write_file(
        file=f"{context.home_dir}/mcp_demo.txt",
        content="اكتمل عرض تكامل MCP"
    )
    
    # 3. استخدام shell لمعالجة النتائج
    result = client.shell.exec_command(
        command=f"wc -l {context.home_dir}/mcp_demo.txt"
    )
    
    print(f"نتيجة معالجة الملف: {result.data.output}")

demonstrate_mcp_tools()
```

## النشر في الإنتاج

### نشر Kubernetes

لبيئات الإنتاج، يمكنك نشر AIO Sandbox على Kubernetes:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: aio-sandbox
  namespace: ai-agents
spec:
  replicas: 2
  selector:
    matchLabels:
      app: aio-sandbox
  template:
    metadata:
      labels:
        app: aio-sandbox
    spec:
      containers:
      - name: aio-sandbox
        image: ghcr.io/agent-infra/sandbox:latest
        ports:
        - containerPort: 8080
        resources:
          limits:
            memory: "4Gi"
            cpu: "2000m"
          requests:
            memory: "2Gi"
            cpu: "1000m"
        env:
        - name: WORKSPACE
          value: "/home/gem"
        - name: TZ
          value: "Asia/Riyadh"
        volumeMounts:
        - name: workspace-volume
          mountPath: /home/gem/workspace
      volumes:
      - name: workspace-volume
        persistentVolumeClaim:
          claimName: sandbox-workspace-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: aio-sandbox-service
  namespace: ai-agents
spec:
  selector:
    app: aio-sandbox
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
  type: LoadBalancer
```

### تكوين البيئة

متغيرات البيئة الرئيسية للإنتاج:

```bash
# الأمان
JWT_PUBLIC_KEY=your_jwt_public_key
PROXY_SERVER=your_proxy_server

# مساحة العمل
WORKSPACE=/home/gem
HOMEPAGE=https://your-homepage.com

# المتصفح
BROWSER_EXTRA_ARGS=--no-sandbox --disable-dev-shm-usage

# الشبكة
DNS_OVER_HTTPS_TEMPLATES=https://cloudflare-dns.com/dns-query
WAIT_PORTS=3000,8000,9000

# المنطقة الزمنية
TZ=Asia/Riyadh
```

## أفضل الممارسات والنصائح

### 1. إدارة الموارد

- **الذاكرة**: خصص على الأقل 2GB RAM للتشغيل السلس
- **المعالج**: 1-2 نواة موصى بها للتطوير، أكثر للإنتاج
- **التخزين**: استخدم أحجام دائمة للبيانات المهمة

### 2. اعتبارات الأمان

- تشغيل بسياقات أمان مناسبة في الإنتاج
- استخدام مصادقة JWT للوصول للAPI
- تنفيذ سياسات الشبكة في Kubernetes
- تحديثات أمان منتظمة لصورة الحاوية

### 3. تحسين الأداء

- استخدام علامات إصدار محددة بدلاً من `latest`
- تكوين حدود موارد مناسبة
- استخدام أحجام محلية لأداء I/O أفضل
- مراقبة مقاييس الحاوية

### 4. سير عمل التطوير

- استخدام تركيب الأحجام للتطوير المستمر
- الاستفادة من VSCode المتكامل لتحرير الكود
- استخدام Jupyter للتطوير والاختبار التفاعلي
- دمج أتمتة المتصفح مع عمليات الملفات لسير عمل شامل

## استكشاف الأخطاء وإصلاحها

### المشاكل الشائعة والحلول

#### الحاوية لا تبدأ
```bash
# فحص سجلات Docker
docker logs <container_id>

# التأكد من الموارد الكافية
docker stats

# فحص توفر المنفذ
netstat -tulpn | grep 8080
```

#### مشاكل أتمتة المتصفح
```bash
# التحقق من تشغيل المتصفح
curl http://localhost:8080/v1/browser/info

# فحص وصول VNC
# انتقل إلى http://localhost:8080/vnc
```

#### مشاكل صلاحيات الملفات
```bash
# إصلاح الملكية في الحاوية
docker exec -it <container_id> chown -R gem:gem /home/gem
```

#### مشاكل اتصال خادم MCP
```bash
# فحص حالة خادم MCP
docker exec -it <container_id> ps aux | grep mcp

# إعادة تشغيل خوادم MCP عند الحاجة
docker restart <container_id>
```

## الخلاصة

يوفر AIO Sandbox بيئة شاملة وموحدة لتطوير وكلاء الذكاء الاصطناعي مما يبسط سير عمل التطوير بشكل كبير. من خلال دمج أتمتة المتصفح وأدوات التطوير وعمليات الملفات وتكامل MCP في حاوية واحدة، فإنه يزيل تعقيد إدارة خدمات منفصلة متعددة.

الفوائد الرئيسية:

- **بيئة موحدة**: جميع الأدوات تتشارك نفس نظام الملفات والشبكة
- **إعداد سهل**: أمر Docker واحد للبدء
- **APIs شاملة**: Python SDK وREST APIs لجميع الوظائف
- **جاهز للإنتاج**: دعم نشر Kubernetes وميزات الأمان
- **قابل للتوسيع**: تكامل MCP لتطوير أدوات مخصصة

سواء كنت تبني سكريبتات أتمتة بسيطة أو أنظمة وكلاء ذكاء اصطناعي معقدة، يوفر AIO Sandbox الأساس الذي تحتاجه للتطوير والنشر الفعال.

## الخطوات التالية

1. **التجريب**: جرب الأمثلة في هذا الدرس
2. **التكامل**: اربط AIO Sandbox مع إطار الذكاء الاصطناعي المفضل لديك
3. **التوسيع**: طور أدوات MCP مخصصة لاحتياجاتك المحددة
4. **النشر**: انتقل للإنتاج باستخدام Kubernetes أو Docker Compose
5. **المساهمة**: انضم للمجتمع وساهم في المشروع

لمزيد من المعلومات، قم بزيارة [المستودع الرسمي](https://github.com/agent-infra/sandbox) و[الوثائق](https://sandbox.agent-infra.com).

---

*يوفر هذا الدرس مقدمة شاملة لـ AIO Sandbox. للحصول على أحدث التحديثات والميزات المتقدمة، ارجع دائماً إلى الوثائق الرسمية.*
