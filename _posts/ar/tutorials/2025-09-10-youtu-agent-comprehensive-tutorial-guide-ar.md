---
title: "Youtu-Agent: دليل شامل لبناء وكلاء ذكاء اصطناعي قوية"
excerpt: "إتقان Youtu-Agent، إطار عمل الوكلاء مفتوح المصدر من تينسنت المبني على OpenAI-agents. تعلم التثبيت والتكوين وبناء تطبيقات ذكاء اصطناعي حقيقية مع البحث الويب وإنتاج SVG وقدرات التقييم."
seo_title: "دليل Youtu-Agent: بناء وكلاء الذكاء الاصطناعي بالنماذج مفتوحة المصدر - Thaki Cloud"
seo_description: "دليل شامل لإطار عمل Youtu-Agent: التثبيت والإعداد والأمثلة والمعايرة. بناء وكلاء ذكاء اصطناعي قوية مع البحث الويب والأتمتة ومعالجة غير متزامنة."
date: 2025-09-10
categories:
  - tutorials
tags:
  - youtu-agent
  - ai-agents
  - python
  - openai-agents
  - agent-framework
  - machine-learning
  - automation
author_profile: true
toc: true
toc_label: "جدول المحتويات"
lang: ar
permalink: /ar/tutorials/youtu-agent-comprehensive-tutorial-guide/
canonical_url: "https://thakicloud.github.io/ar/tutorials/youtu-agent-comprehensive-tutorial-guide/"
---

⏱️ **وقت القراءة المتوقع**: 15 دقيقة

## مقدمة

في المشهد المتطور بسرعة لتطوير الذكاء الاصطناعي، أصبح بناء أطر عمل وكلاء قوية وقابلة للتوسع أمرًا حاسمًا للباحثين والمطورين على حد سواء. [Youtu-Agent](https://github.com/TencentCloudADP/youtu-agent)، المطور من قبل مختبر تينسنت يوتو، يظهر كحل بسيط لكنه قوي يقدم أداءً استثنائيًا مع النماذج مفتوحة المصدر.

### ما هو Youtu-Agent؟

Youtu-Agent هو إطار عمل وكلاء مفتوح المصدر مصمم لتقديم قيمة كبيرة عبر مجموعات مستخدمين مختلفة - من باحثي الذكاء الاصطناعي ومدربي النماذج اللغوية الكبيرة إلى مطوري التطبيقات والهواة. مبني على أساس `openai-agents` SDK، يرث القدرات الأساسية مثل التدفق والتتبع ووظائف حلقة الوكيل مع الحفاظ على التوافق مع كل من `responses` و `chat.completions` APIs.

### الميزات الرئيسية

**🚀 الأداء والوصولية**
- **دعم النماذج مفتوحة المصدر وانخفاض التكلفة**: يعزز الوصولية وفعالية التكلفة لتطبيقات متنوعة
- **معالجة غير متزامنة بالكامل**: تمكن التنفيذ عالي الأداء والفعال، مفيد خاصة لتقييم المعايير
- **مبني على openai-agents**: يستفيد من أساس مثبت مع قدرات التدفق والتتبع وحلقة الوكيل

**🔧 الأتمتة والتكوين**
- **تكوين قائم على YAML**: تكوينات وكلاء منظمة وسهلة الإدارة
- **إنتاج وكلاء تلقائي**: يمكن إنتاج تكوينات الوكلاء تلقائيًا بناءً على متطلبات المستخدم
- **إنتاج الأدوات وتحسينها**: يدعم تقييم الأدوات والتحسين التلقائي

**📊 التحليل وإزالة الأخطاء**
- **نظام التتبع والتحليل**: ما وراء OTEL، نظام `DBTracingProcessor` يوفر تحليلًا عميقًا لاستدعاءات الأدوات ومسارات الوكلاء
- **إزالة الأخطاء البصرية**: مجموعة أدوات غنية وأدوات تتبع بصرية تجعل التطوير بديهيًا

### حالات الاستخدام

Youtu-Agent يتفوق في تطبيقات عملية متنوعة:
- **البحث العميق/الواسع**: مهام شاملة موجهة للبحث
- **إنتاج صفحات الويب**: إنشاء صفحات ويب بناءً على مدخلات محددة
- **جمع المسارات**: دعم جمع البيانات للتدريب والبحث
- **سير عمل الأتمتة**: أتمتة المهام المعقدة متعددة الخطوات

## متطلبات النظام

قبل أن نبدأ، تأكد من أن نظامك يلبي المتطلبات التالية:

### المتطلبات الأساسية

- **Python**: الإصدار 3.12 أو أعلى
- **نظام التشغيل**: macOS أو Linux أو Windows مع WSL
- **مدير الحزم**: `uv` (موصى به) أو `pip`
- **Git**: لاستنساخ المستودع

### مفاتيح API المطلوبة

للاستفادة الكاملة من قدرات Youtu-Agent، ستحتاج:
- **مفتاح LLM API**: API متوافق مع OpenAI (DeepSeek، OpenAI، إلخ)
- **مفتاح Search API**: Serper API لوظيفة البحث الويب
- **مفتاح Content API**: Jina AI لمعالجة المحتوى

## دليل التثبيت

### الخطوة 1: تثبيت Python و uv

أولاً، تأكد من تثبيت Python 3.12+:

```bash
# فحص إصدار Python
python --version

# تثبيت مدير الحزم uv (موصى به)
curl -LsSf https://astral.sh/uv/install.sh | sh

# أو التثبيت عبر pip
pip install uv
```

### الخطوة 2: استنساخ المستودع

```bash
# استنساخ مستودع Youtu-Agent
git clone https://github.com/TencentCloudADP/youtu-agent.git
cd youtu-agent

# التحقق من هيكل الدليل
ls -la
```

### الخطوة 3: إعداد التبعيات

```bash
# مزامنة التبعيات باستخدام uv
uv sync

# البديل: استخدام أمر make
make sync

# تفعيل البيئة الافتراضية
source ./.venv/bin/activate
```

### الخطوة 4: تكوين متغيرات البيئة

```bash
# نسخ قالب البيئة
cp .env.example .env

# تحرير ملف .env بمفاتيح API الخاصة بك
nano .env
```

قم بتكوين ملف `.env` الخاص بك بالإعدادات التالية:

```bash
# تكوين LLM (مثال DeepSeek)
UTU_LLM_TYPE=chat.completions
UTU_LLM_MODEL=deepseek-chat
UTU_LLM_BASE_URL=https://api.deepseek.com/v1
UTU_LLM_API_KEY=your-deepseek-api-key

# أدوات البحث الويب
SERPER_API_KEY=your-serper-api-key
JINA_API_KEY=your-jina-api-key

# LLM للتقييمات (اختياري)
JUDGE_LLM_TYPE=chat.completions
JUDGE_LLM_MODEL=deepseek-chat
JUDGE_LLM_BASE_URL=https://api.deepseek.com/v1
JUDGE_LLM_API_KEY=your-judge-api-key
```

## التكوين الأساسي

### فهم تكوين الوكيل

Youtu-Agent يستخدم ملفات YAML لتكوين الوكيل. دعونا نفحص التكوين الافتراضي:

```yaml
# configs/agents/default.yaml
defaults:
  - /model/base
  - /tools/search@toolkits.search
  - _self_

agent:
  name: simple-tool-agent
  instructions: "أنت مساعد مفيد يمكنه البحث في الويب."
```

### المكونات الأساسية

**1. Agent**: LLM مكون بتوجيهات وأدوات وبيئة محددة
**2. Toolkit**: مجموعة مغلفة من الأدوات التي يمكن للوكيل استخدامها
**3. Environment**: السياق التشغيلي (متصفح، shell، إلخ)
**4. ContextManager**: وحدة قابلة للتكوين لإدارة نافذة سياق الوكيل
**5. Benchmark**: سير عمل مغلف لمجموعات بيانات محددة

## البداية: الوكيل الأول

### تشغيل Chatbot CLI الأساسي

لنبدأ بمثال بسيط:

```bash
# تشغيل الوكيل الأساسي بدون أدوات البحث
python scripts/cli_chat.py --stream --config base
```

هذا يشغل chatbot CLI تفاعلي. جرب طرح أسئلة مثل:
- "مرحباً، كيف حالك؟"
- "بماذا يمكنك مساعدتي؟"
- "اشرح الحوسبة الكمية بمصطلحات بسيطة"

### تشغيل الوكيل مع البحث الويب

للقدرات المتقدمة، استخدم الوكيل المدعوم بالبحث:

```bash
# تشغيل الوكيل مع قدرات البحث الويب
python scripts/cli_chat.py --stream --config default
```

الآن يمكنك طرح أسئلة تتطلب معلومات حالية:
- "ما هي أحدث التطورات في الذكاء الاصطناعي؟"
- "أخبرني عن الأخبار التقنية الحديثة"
- "كيف الطقس في طوكيو اليوم؟"

## أمثلة عملية

### المثال 1: مولد SVG

واحدة من أكثر الميزات إثارة للإعجاب في Youtu-Agent هي قدرته على إنتاج تصورات SVG بناءً على مواضيع البحث.

#### إصدار سطر الأوامر

```bash
# إنتاج SVG حول ميزات DeepSeek V3.1
python examples/svg_generator/main.py
```

هذا الأمر سيقوم بـ:
1. البحث التلقائي عبر الإنترنت عن معلومات حول "ميزات DeepSeek V3.1 الجديدة"
2. تحليل وتوليف المعلومات المجمعة
3. إنتاج تصور SVG يمثل النتائج

#### إصدار واجهة الويب

لتجربة أكثر تفاعلاً، يمكنك استخدام واجهة الويب:

```bash
# تثبيت حزمة الواجهة الأمامية
curl -LO https://github.com/TencentCloudADP/youtu-agent/releases/download/frontend%2Fv0.1.6/utu_agent_ui-0.1.6-py3-none-any.whl
uv pip install utu_agent_ui-0.1.6-py3-none-any.whl

# تشغيل إصدار الويب
python examples/svg_generator/main_web.py
```

بعد البدء، ادخل إلى واجهة الويب على `http://127.0.0.1:8848/` وتفاعل مع الوكيل من خلال واجهة سهلة الاستخدام.

### المثال 2: مساعد البحث

إنشاء مساعد بحث مخصص للتحليل المعمق:

```python
# examples/research_assistant.py
import asyncio
from utu.core.agent import Agent
from utu.core.config import load_config

async def research_topic(topic: str):
    # تحميل التكوين
    config = load_config("configs/agents/research.yaml")
    
    # تهيئة الوكيل
    agent = Agent(config)
    
    # تنفيذ البحث
    response = await agent.chat(
        f"قم بإجراء بحث شامل حول: {topic}. "
        f"قدم تحليلاً مفصلاً مع المصادر."
    )
    
    return response

# الاستخدام
if __name__ == "__main__":
    topic = "أحدث التطورات في الحوسبة الكمية"
    result = asyncio.run(research_topic(topic))
    print(result)
```

## الميزات المتقدمة

### تطوير أدوات مخصصة

إنشاء أدواتك الخاصة لتوسيع قدرات الوكيل:

```python
# custom_tools/file_manager.py
from utu.core.tool import Tool
import os

class FileManagerTool(Tool):
    def __init__(self):
        super().__init__(
            name="file_manager",
            description="إدارة الملفات والمجلدات"
        )
    
    async def list_files(self, directory: str = ".") -> str:
        """قائمة الملفات في الدليل المحدد"""
        try:
            files = os.listdir(directory)
            return f"الملفات في {directory}: {', '.join(files)}"
        except Exception as e:
            return f"خطأ في سرد الملفات: {str(e)}"
    
    async def read_file(self, filepath: str) -> str:
        """قراءة محتويات ملف"""
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            return f"محتوى {filepath}:\n{content}"
        except Exception as e:
            return f"خطأ في قراءة الملف: {str(e)}"
```

### إدارة السياق

تحسين أداء الوكيل مع إدارة السياق المخصصة:

```yaml
# configs/context/large_context.yaml
context_manager:
  max_tokens: 32768
  strategy: "sliding_window"
  preserve_system: true
  compression_ratio: 0.7
```

### تكوين البيئة

إعداد بيئات متخصصة لمهام مختلفة:

```yaml
# configs/environments/web_browser.yaml
environment:
  type: "browser"
  settings:
    headless: false
    timeout: 30
    user_agent: "YoutuAgent/1.0"
```

## التقييم والمعايرة

### إعداد التقييمات

Youtu-Agent يوفر قدرات تقييم شاملة:

```bash
# تحضير مجموعة بيانات WebWalkerQA
python scripts/data/process_web_walker_qa.py

# تشغيل التقييم
python scripts/run_eval.py \
  --config_name ww \
  --exp_id my_experiment_001 \
  --dataset WebWalkerQA_15 \
  --concurrency 5
```

### إنشاء معايير مخصصة

إنشاء معاييرك الخاصة:

```python
# benchmarks/custom_benchmark.py
from utu.core.benchmark import Benchmark
from utu.core.dataset import Dataset

class CustomBenchmark(Benchmark):
    def __init__(self):
        super().__init__(name="custom_benchmark")
    
    async def preprocess(self, raw_data):
        """معالجة البيانات الخام للتقييم"""
        return processed_data
    
    async def judge(self, response, ground_truth):
        """تقييم استجابة الوكيل مقابل الحقيقة الأساسية"""
        return score
```

## نشر Docker

للنشر في الإنتاج، استخدم Docker:

```bash
# بناء صورة Docker
docker build -t youtu-agent .

# التشغيل مع متغيرات البيئة
docker run -it \
  -e UTU_LLM_API_KEY=your-api-key \
  -e SERPER_API_KEY=your-serper-key \
  -p 8848:8848 \
  youtu-agent
```

## الاختبار والتحقق

### نص اختبار macOS

إنشاء نص اختبار شامل لـ macOS:

```bash
#!/bin/bash
# test_youtu_agent_macos.sh

echo "🧪 اختبار Youtu-Agent على macOS"
echo "================================"

# الاختبار 1: فحص إصدار Python
echo "1. فحص إصدار Python..."
python_version=$(python --version 2>&1)
echo "إصدار Python: $python_version"

if [[ $python_version == *"3.12"* ]] || [[ $python_version == *"3.13"* ]]; then
    echo "✅ إصدار Python متوافق"
else
    echo "❌ Python 3.12+ مطلوب"
    exit 1
fi

# الاختبار 2: فحص تثبيت uv
echo -e "\n2. فحص تثبيت uv..."
if command -v uv &> /dev/null; then
    echo "✅ uv مثبت"
    uv --version
else
    echo "❌ uv غير موجود، يتم التثبيت..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# الاختبار 3: اختبار البيئة الافتراضية
echo -e "\n3. اختبار البيئة الافتراضية..."
if [ -d ".venv" ]; then
    echo "✅ البيئة الافتراضية موجودة"
    source ./.venv/bin/activate
    python -c "import utu; print('✅ تم استيراد Youtu-Agent بنجاح')" 2>/dev/null || echo "❌ فشل استيراد utu"
else
    echo "❌ البيئة الافتراضية غير موجودة"
    exit 1
fi

# الاختبار 4: فحص تكوين البيئة
echo -e "\n4. فحص تكوين البيئة..."
if [ -f ".env" ]; then
    echo "✅ ملف .env موجود"
    
    # فحص المفاتيح المطلوبة
    if grep -q "UTU_LLM_API_KEY" .env; then
        echo "✅ مفتاح LLM API مكون"
    else
        echo "⚠️  مفتاح LLM API غير مكون"
    fi
    
    if grep -q "SERPER_API_KEY" .env; then
        echo "✅ مفتاح Serper API مكون"
    else
        echo "⚠️  مفتاح Serper API غير مكون"
    fi
else
    echo "❌ ملف .env غير موجود"
    echo "تشغيل: cp .env.example .env"
fi

# الاختبار 5: اختبار وظيفة الوكيل الأساسية
echo -e "\n5. اختبار وظيفة الوكيل الأساسية..."
python -c "
import asyncio
from utu.core.config import load_config
try:
    config = load_config('configs/agents/base.yaml')
    print('✅ تم تحميل التكوين الأساسي بنجاح')
except Exception as e:
    print(f'❌ خطأ في التكوين: {e}')
" 2>/dev/null

echo -e "\n🎉 اختبار التوافق مع macOS مكتمل!"
```

### تشغيل الاختبارات

```bash
# منح صلاحية تنفيذ للنص
chmod +x test_youtu_agent_macos.sh

# تشغيل اختبار التوافق
./test_youtu_agent_macos.sh
```

## استكشاف الأخطاء وإصلاحها

### المشاكل الشائعة

**1. أخطاء الاستيراد**
```bash
# تأكد من تفعيل البيئة الافتراضية
source ./.venv/bin/activate

# إعادة تثبيت التبعيات
uv sync --force
```

**2. مشاكل اتصال API**
```bash
# اختبار اتصال API
python -c "
import os
from openai import OpenAI
client = OpenAI(
    api_key=os.getenv('UTU_LLM_API_KEY'),
    base_url=os.getenv('UTU_LLM_BASE_URL')
)
try:
    response = client.chat.completions.create(
        model=os.getenv('UTU_LLM_MODEL'),
        messages=[{'role': 'user', 'content': 'مرحباً'}],
        max_tokens=10
    )
    print('✅ اتصال API ناجح')
except Exception as e:
    print(f'❌ خطأ API: {e}')
"
```

**3. مشاكل الذاكرة**
```bash
# تقليل التزامن للتقييمات الكبيرة
python scripts/run_eval.py --concurrency 1

# استخدام نوافذ سياق أصغر
# تحرير configs/context/base.yaml
```

## تحسين الأداء

### المعالجة غير المتزامنة

تعظيم الأداء مع الاستخدام الصحيح للمعالجة غير المتزامنة:

```python
import asyncio
from utu.core.agent import Agent

async def process_multiple_queries(queries: list):
    agent = Agent.from_config("configs/agents/default.yaml")
    
    # معالجة الاستعلامات بشكل متزامن
    tasks = [agent.chat(query) for query in queries]
    results = await asyncio.gather(*tasks)
    
    return results

# الاستخدام
queries = [
    "ما هو التعلم الآلي؟",
    "اشرح الشبكات العصبية",
    "ما هي المحولات في الذكاء الاصطناعي؟"
]

results = asyncio.run(process_multiple_queries(queries))
```

### إدارة الذاكرة

```python
# تنفيذ ضغط السياق
from utu.core.context import ContextManager

context_manager = ContextManager(
    max_tokens=16384,
    compression_strategy="summarize",
    preserve_recent=True
)
```

## أفضل الممارسات

### 1. إدارة التكوين

- استخدم التحكم في الإصدار لملفات التكوين
- إنشاء تكوينات خاصة بالبيئة
- توثيق التكوينات المخصصة

### 2. معالجة الأخطاء

```python
async def robust_agent_call(agent, message):
    max_retries = 3
    for attempt in range(max_retries):
        try:
            response = await agent.chat(message)
            return response
        except Exception as e:
            if attempt == max_retries - 1:
                raise e
            await asyncio.sleep(2 ** attempt)  # التراجع الأسي
```

### 3. المراقبة والسجلات

```python
import logging
from utu.core.tracing import setup_tracing

# تكوين السجلات
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# إعداد التتبع
setup_tracing(
    service_name="my-agent-app",
    endpoint="http://localhost:4317"
)
```

## أمثلة التكامل

### تطبيق Flask الويب

```python
from flask import Flask, request, jsonify
from utu.core.agent import Agent
import asyncio

app = Flask(__name__)
agent = Agent.from_config("configs/agents/web_assistant.yaml")

@app.route('/chat', methods=['POST'])
def chat():
    data = request.json
    message = data.get('message', '')
    
    async def process():
        return await agent.chat(message)
    
    response = asyncio.run(process())
    return jsonify({'response': response})

if __name__ == '__main__':
    app.run(debug=True)
```

### تكامل FastAPI

```python
from fastapi import FastAPI
from pydantic import BaseModel
from utu.core.agent import Agent

app = FastAPI()
agent = Agent.from_config("configs/agents/api_assistant.yaml")

class ChatRequest(BaseModel):
    message: str

class ChatResponse(BaseModel):
    response: str

@app.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    response = await agent.chat(request.message)
    return ChatResponse(response=response)
```

## الخلاصة

Youtu-Agent يمثل تقدمًا مهمًا في تطوير إطار عمل الوكلاء، مقدمًا توازنًا مثاليًا بين البساطة والقوة. سواء كنت باحثًا تبحث عن خط أساس قوي للتجريب، أو مطورًا يبني تطبيقات إنتاج، أو هاويًا يستكشف قدرات الذكاء الاصطناعي، Youtu-Agent يوفر الأدوات والمرونة التي تحتاجها.

### النقاط الرئيسية

1. **إعداد سهل**: مع Python 3.12+ و uv، البداية تستغرق دقائق
2. **تكوين مرن**: التكوينات القائمة على YAML تجعل التخصيص مباشرًا
3. **جاهز للإنتاج**: معالجة غير متزامنة وأدوات تقييم شاملة
4. **قابل للتوسع**: يمكن دمج الأدوات والبيئات المخصصة بسهولة
5. **موثق جيدًا**: أمثلة شاملة ووثائق واضحة

### الخطوات التالية

- استكشف [الوثائق الرسمية](https://tencentcloudadp.github.io/youtu-agent/)
- انضم إلى مناقشات المجتمع على GitHub
- جرب تطوير أدوات مخصصة
- ساهم في نمو المشروع

### الموارد

- **مستودع GitHub**: [https://github.com/TencentCloudADP/youtu-agent](https://github.com/TencentCloudADP/youtu-agent)
- **الموقع الرسمي**: [https://tencentcloudadp.github.io/youtu-agent/](https://tencentcloudadp.github.io/youtu-agent/)
- **دليل إعداد Docker**: راجع `docker/README.md` في المستودع
- **مشاريع الأمثلة**: تحقق من دليل `/examples` للمزيد من حالات الاستخدام

برمجة سعيدة مع Youtu-Agent! 🚀
