---
title: "دليل RAGLight الشامل: من RAG الأساسي إلى سير العمل الوكيل"
excerpt: "إتقان إطار RAGLight مع أمثلة عملية تغطي RAG، Agentic RAG، RAT pipelines، وتكامل MCP لبناء أنظمة توليد معززة بالاسترجاع قوية."
seo_title: "دروس RAGLight: دليل إطار RAG الكامل - Thaki Cloud"
seo_description: "تعلم إطار RAGLight مع أمثلة عملية. بناء RAG، Agentic RAG، و RAT pipelines على macOS باستخدام Ollama أو OpenAI أو Mistral لتطبيقات الذكاء الاصطناعي الواعية بالسياق."
date: 2025-10-14
tags:
  - raglight
  - rag
  - agentic-rag
  - ollama
  - python
  - llm
  - vector-database
  - mcp
  - huggingface
author_profile: true
toc: true
toc_label: "المحتويات"
lang: ar
permalink: /ar/tutorials/raglight-comprehensive-guide/
canonical_url: "https://thakicloud.github.io/ar/tutorials/raglight-comprehensive-guide/"
categories:
  - tutorials
---

⏱️ **وقت القراءة المقدر**: 15 دقيقة

## مقدمة

**RAGLight** هو إطار عمل Python خفيف الوزن ومعياري مصمم لتبسيط تنفيذ **التوليد المعزز بالاسترجاع (Retrieval-Augmented Generation - RAG)**. من خلال الجمع بين استرجاع المستندات ونماذج اللغة الكبيرة (Large Language Models - LLM)، يتيح لك RAGLight بناء أنظمة ذكاء اصطناعي واعية بالسياق يمكنها الإجابة على الأسئلة بناءً على مستنداتك وقواعد معرفتك الخاصة.

في هذا الدليل الشامل، ستتعلم كيفية:

- إعداد RAGLight مع مزودي LLM المختلفين (Ollama، OpenAI، Mistral)
- بناء خطوط RAG الأساسية للإجابة على الأسئلة القائمة على المستندات
- تنفيذ Agentic RAG لمهام الاستدلال متعددة الخطوات
- استخدام RAT (Retrieval-Augmented Thinking) للاستدلال المحسّن
- دمج الأدوات الخارجية باستخدام MCP (Model Context Protocol)

### ما الذي يجعل RAGLight مميزاً؟

يتميز RAGLight بما يلي:

- **البنية المعيارية**: سهولة تبديل LLMs والتضمينات ومخازن المتجهات
- **دعم موفرين متعددين**: Ollama، OpenAI، Mistral، LMStudio، vLLM، Google AI
- **خطوط أنابيب متقدمة**: RAG الأساسي، Agentic RAG، و RAT مع طبقات الاستدلال
- **تكامل MCP**: ربط الأدوات ومصادر البيانات الخارجية بسلاسة
- **تكوين مرن**: تخصيص كل جانب من جوانب خط RAG الخاص بك

## المتطلبات الأساسية

قبل البدء في هذا الدليل، تأكد من توفر:

### 1. بيئة Python

```bash
# تحقق من إصدار Python (مطلوب 3.8 أو أعلى)
python3 --version

# إنشاء بيئة افتراضية (موصى به)
python3 -m venv raglight-env
source raglight-env/bin/activate  # على macOS/Linux
# raglight-env\Scripts\activate  # على Windows
```

### 2. تثبيت Ollama (لـ LLM المحلي)

```bash
# macOS
brew install ollama

# أو التنزيل من https://ollama.ai/download

# بدء خدمة Ollama
ollama serve

# سحب نموذج (في terminal جديد)
ollama pull llama3.2:3b
```

**البديل**: استخدم OpenAI أو Mistral API إذا كنت تفضل LLMs المستندة إلى السحابة.

### 3. تثبيت RAGLight

```bash
pip install raglight
```

## التثبيت والإعداد

### تكوين البيئة

أنشئ ملف `.env` لتخزين مفاتيح API الخاصة بك (عند استخدام موفري السحابة):

```bash
# ملف .env
OPENAI_API_KEY=your_openai_key_here
MISTRAL_API_KEY=your_mistral_key_here
```

### هيكل المشروع

قم بإعداد دليل مشروعك:

```bash
mkdir raglight-tutorial
cd raglight-tutorial
mkdir data
mkdir knowledge_base
```

### إنشاء بيانات تجريبية

أنشئ بعض المستندات التجريبية للاختبار:

```bash
# data/document1.txt
cat > data/document1.txt << 'EOF'
RAGLight هو إطار عمل Python معياري للتوليد المعزز بالاسترجاع.
يدعم العديد من موفري LLM بما في ذلك Ollama و OpenAI و Mistral.
تشمل الميزات الرئيسية التكامل المرن لمخزن المتجهات مع ChromaDB و FAISS.
EOF

# data/document2.txt
cat > data/document2.txt << 'EOF'
يوسع Agentic RAG RAG التقليدي من خلال دمج الوكلاء المستقلين.
يمكن لهؤلاء الوكلاء أداء الاستدلال متعدد الخطوات واسترجاع المعلومات الديناميكي.
تشمل حالات الاستخدام الإجابة على الأسئلة المعقدة ومساعدي الأبحاث.
EOF

# data/document3.txt
cat > data/document3.txt << 'EOF'
يضيف RAT (Retrieval-Augmented Thinking) طبقة استدلال متخصصة.
يستخدم LLMs الاستدلالية لتعزيز جودة الاستجابة والعمق التحليلي.
RAT مثالي للمهام التي تتطلب تفكيراً عميقاً واستدلالاً متعدد القفزات.
EOF
```

## خط RAG الأساسي

### فهم بنية RAG

يتكون خط RAG الأساسي من ثلاثة مكونات رئيسية:

1. **استيعاب المستندات (Document Ingestion)**: يتم تقسيم مستنداتك إلى أجزاء وتحويلها إلى تضمينات
2. **التخزين المتجه (Vector Storage)**: يتم تخزين التضمينات في قاعدة بيانات متجهات (ChromaDB، FAISS، إلخ)
3. **الاسترجاع والتوليد (Retrieval & Generation)**: عند الاستعلام، يتم استرجاع المستندات ذات الصلة وتمريرها إلى LLM

### التنفيذ

إليك مثال كامل لخط RAG أساسي:

```python
#!/usr/bin/env python3
"""خط RAG أساسي باستخدام RAGLight"""

from raglight.rag.simple_rag_api import RAGPipeline
from raglight.config.rag_config import RAGConfig
from raglight.config.vector_store_config import VectorStoreConfig
from raglight.config.settings import Settings
from raglight.models.data_source_model import FolderSource
from dotenv import load_dotenv

# تحميل متغيرات البيئة
load_dotenv()

# إعداد التسجيل
Settings.setup_logging()

# تكوين مخزن المتجهات
vector_store_config = VectorStoreConfig(
    embedding_model=Settings.DEFAULT_EMBEDDINGS_MODEL,
    api_base=Settings.DEFAULT_OLLAMA_CLIENT,
    provider=Settings.HUGGINGFACE,
    database=Settings.CHROMA,
    persist_directory="./chroma_db",
    collection_name="my_knowledge_base"
)

# تكوين RAG
config = RAGConfig(
    llm="llama3.2:3b",  # نموذج Ollama
    k=5,  # عدد المستندات للاسترجاع
    provider=Settings.OLLAMA,
    system_prompt=Settings.DEFAULT_SYSTEM_PROMPT,
    knowledge_base=[FolderSource(path="./data")]
)

# تهيئة وبناء خط الأنابيب
print("تهيئة خط RAG...")
pipeline = RAGPipeline(config, vector_store_config)

print("بناء قاعدة المعرفة...")
pipeline.build()

# الاستعلام من خط الأنابيب
query = "ما هي الميزات الرئيسية لـ RAGLight؟"
print(f"\nالاستعلام: {query}")

response = pipeline.generate(query)
print(f"\nالاستجابة:\n{response}")
```

### خيارات التكوين الرئيسية

**خيارات مخزن المتجهات:**
- `database`: CHROMA أو FAISS أو QDRANT
- `provider`: HUGGINGFACE أو OLLAMA أو OPENAI للتضمينات
- `persist_directory`: مكان تخزين قاعدة بيانات المتجهات

**خيارات RAG:**
- `llm`: اسم النموذج (مثل "llama3.2:3b"، "gpt-4"، "mistral-large-2411")
- `k`: عدد المستندات ذات الصلة للاسترجاع
- `provider`: OLLAMA أو OPENAI أو MISTRAL أو LMSTUDIO أو GOOGLE

### استخدام موفري LLM المختلفين

**OpenAI:**
```python
config = RAGConfig(
    llm="gpt-4",
    k=5,
    provider=Settings.OPENAI,
    api_key=Settings.OPENAI_API_KEY,
    knowledge_base=[FolderSource(path="./data")]
)
```

**Mistral:**
```python
config = RAGConfig(
    llm="mistral-large-2411",
    k=5,
    provider=Settings.MISTRAL,
    api_key=Settings.MISTRAL_API_KEY,
    knowledge_base=[FolderSource(path="./data")]
)
```

## خط Agentic RAG

### ما هو Agentic RAG؟

يوسع Agentic RAG RAG التقليدي من خلال دمج وكيل مستقل يمكنه:

- أداء الاستدلال متعدد الخطوات
- تحديد متى يتم استرجاع معلومات إضافية
- التكرار خلال دورات استرجاع-توليد متعددة
- التعامل مع الأسئلة المعقدة التي تتطلب مصادر بيانات متعددة

### التنفيذ

```python
"""خط Agentic RAG باستخدام RAGLight"""

from raglight.rag.simple_agentic_rag_api import AgenticRAGPipeline
from raglight.config.agentic_rag_config import AgenticRAGConfig
from raglight.config.vector_store_config import VectorStoreConfig
from raglight.config.settings import Settings
from raglight.models.data_source_model import FolderSource
from dotenv import load_dotenv

load_dotenv()
Settings.setup_logging()

# تكوين مخزن المتجهات
vector_store_config = VectorStoreConfig(
    embedding_model=Settings.DEFAULT_EMBEDDINGS_MODEL,
    api_base=Settings.DEFAULT_OLLAMA_CLIENT,
    provider=Settings.HUGGINGFACE,
    database=Settings.CHROMA,
    persist_directory="./agentic_chroma_db",
    collection_name="agentic_knowledge_base"
)

# تكوين Agentic RAG
config = AgenticRAGConfig(
    provider=Settings.MISTRAL,
    model="mistral-large-2411",
    k=10,
    system_prompt=Settings.DEFAULT_AGENT_PROMPT,
    max_steps=4,  # الحد الأقصى لخطوات الاستدلال
    api_key=Settings.MISTRAL_API_KEY,
    knowledge_base=[FolderSource(path="./data")]
)

# التهيئة والبناء
print("تهيئة خط Agentic RAG...")
agentic_rag = AgenticRAGPipeline(config, vector_store_config)

print("بناء قاعدة المعرفة...")
agentic_rag.build()

# استعلام معقد يتطلب خطوات متعددة
query = """
قارن قدرات RAG الأساسي و Agentic RAG.
ما هي حالات الاستخدام المحددة التي سيكون فيها Agentic RAG أكثر فائدة؟
"""

print(f"\nالاستعلام: {query}")
response = agentic_rag.generate(query)
print(f"\nالاستجابة:\n{response}")
```

### الميزات الرئيسية لـ Agentic RAG

**max_steps**: يتحكم في عدد تكرارات الاستدلال التي يمكن للوكيل تنفيذها
```python
# استعلام بسيط: خطوات أقل مطلوبة
config = AgenticRAGConfig(max_steps=2, ...)

# تحليل معقد: خطوات أكثر مسموح بها
config = AgenticRAGConfig(max_steps=10, ...)
```

**موجه وكيل مخصص**: تخصيص سلوك الوكيل
```python
custom_agent_prompt = """
أنت مساعد بحث. عند الإجابة على الأسئلة:
1. قسّم الاستعلامات المعقدة إلى أسئلة فرعية
2. استرجع المعلومات ذات الصلة لكل سؤال فرعي
3. اجمع النتائج في إجابة شاملة
4. اذكر المصادر عند الإمكان
"""

config = AgenticRAGConfig(
    system_prompt=custom_agent_prompt,
    ...
)
```

## RAT (التفكير المعزز بالاسترجاع)

### فهم RAT

يضيف RAT طبقة استدلال متخصصة إلى خط RAG:

1. **الاسترجاع (Retrieval)**: جلب المستندات ذات الصلة
2. **الاستدلال (Reasoning)**: استخدام LLM استدلالي لتحليل المحتوى المسترجع
3. **التفكير (Thinking)**: توليد خطوات استدلال وسيطة
4. **التوليد (Generation)**: إنتاج الإجابة النهائية مع سياق محسّن

### التنفيذ

```python
"""خط RAT باستخدام RAGLight"""

from raglight.rat.simple_rat_api import RATPipeline
from raglight.config.rat_config import RATConfig
from raglight.config.vector_store_config import VectorStoreConfig
from raglight.config.settings import Settings
from raglight.models.data_source_model import FolderSource

Settings.setup_logging()

# تكوين مخزن المتجهات
vector_store_config = VectorStoreConfig(
    embedding_model=Settings.DEFAULT_EMBEDDINGS_MODEL,
    api_base=Settings.DEFAULT_OLLAMA_CLIENT,
    provider=Settings.HUGGINGFACE,
    database=Settings.CHROMA,
    persist_directory="./rat_chroma_db",
    collection_name="rat_knowledge_base"
)

# تكوين RAT
config = RATConfig(
    cross_encoder_model=Settings.DEFAULT_CROSS_ENCODER_MODEL,
    llm="llama3.2:3b",
    k=Settings.DEFAULT_K,
    provider=Settings.OLLAMA,
    system_prompt=Settings.DEFAULT_SYSTEM_PROMPT,
    reasoning_llm=Settings.DEFAULT_REASONING_LLM,
    reflection=3,  # عدد تكرارات الاستدلال
    knowledge_base=[FolderSource(path="./data")]
)

# التهيئة والبناء
print("تهيئة خط RAT...")
pipeline = RATPipeline(config, vector_store_config)

print("بناء قاعدة المعرفة...")
pipeline.build()

# استعلام يتطلب استدلالاً عميقاً
query = """
حلل الاختلافات المعمارية بين RAG و Agentic RAG و RAT.
ما هي المقايضات من حيث التعقيد والأداء وجودة الإخراج؟
"""

print(f"\nالاستعلام: {query}")
response = pipeline.generate(query)
print(f"\nالاستجابة:\n{response}")
```

### خيارات تكوين RAT

**reflection**: عدد تكرارات الاستدلال
```python
# استدلال سريع
config = RATConfig(reflection=1, ...)

# تفكير تحليلي عميق
config = RATConfig(reflection=5, ...)
```

**cross_encoder_model**: نموذج إعادة الترتيب لاسترجاع أفضل
```python
config = RATConfig(
    cross_encoder_model="cross-encoder/ms-marco-MiniLM-L-12-v2",
    ...
)
```

## تكامل MCP

### ما هو MCP؟

يسمح Model Context Protocol (MCP) لخط RAG الخاص بك بالتفاعل مع الأدوات والخدمات الخارجية. هذا يتيح:

- تكامل البحث على الويب
- استعلامات قاعدة البيانات
- استدعاءات API للخدمات الخارجية
- بيئات تنفيذ الكود
- تكامل الأدوات المخصصة

### إعداد خادم MCP

أولاً، قم بتكوين خادم MCP الخاص بك (مثال باستخدام MCPClient):

```python
"""تكوين خادم MCP"""

from raglight.rag.simple_agentic_rag_api import AgenticRAGPipeline
from raglight.config.agentic_rag_config import AgenticRAGConfig
from raglight.config.settings import Settings

# تكوين عنوان URL لخادم MCP
config = AgenticRAGConfig(
    provider=Settings.OPENAI,
    model="gpt-4o",
    k=10,
    mcp_config=[
        {% raw %}{"url": "http://127.0.0.1:8001/sse"}{% endraw %}  # عنوان URL لخادم MCP الخاص بك
    ],
    system_prompt=Settings.DEFAULT_AGENT_PROMPT,
    max_steps=4,
    api_key=Settings.OPENAI_API_KEY
)

# التهيئة مع MCP
pipeline = AgenticRAGPipeline(config, vector_store_config)
pipeline.build()

# يمكن للوكيل الآن استخدام الأدوات الخارجية
query = "ابحث في الويب عن التحديثات الأخيرة على أطر RAG ولخص النتائج"
response = pipeline.generate(query)
```

### حالات استخدام MCP

**تكامل البحث على الويب:**
```python
# يمكن للوكيل البحث ودمج نتائج الويب
query = "ما هي آخر التطورات في تقنية RAG في عام 2024؟"
```

**استعلامات قاعدة البيانات:**
```python
# يمكن للوكيل الاستعلام عن قواعد البيانات للحصول على بيانات في الوقت الفعلي
query = "استرجع إحصائيات المستخدم من قاعدة بياناتنا وحلل الاتجاهات"
```

**تكامل API:**
```python
# يمكن للوكيل استدعاء APIs الخارجية
query = "تحقق من API الطقس وأوصِ بالأنشطة بناءً على التوقعات"
```

## مقارنة الأداء

### خصائص خطوط الأنابيب

| نوع خط الأنابيب | التعقيد | وقت الاستجابة | حالة الاستخدام |
|----------------|---------|---------------|-----------------|
| **RAG الأساسي** | منخفض | سريع (< 5 ثواني) | Q&A بسيط، البحث عن المستندات |
| **Agentic RAG** | متوسط | معتدل (5-15 ثانية) | استدلال متعدد الخطوات، بحث |
| **RAT** | عالي | بطيء (15-30 ثانية) | تحليل عميق، استدلال معقد |
| **RAG + MCP** | متغير | يعتمد على الأدوات | تكامل الأدوات الخارجية |

### اختيار خط الأنابيب المناسب

**استخدم RAG الأساسي عندما:**
- تحتاج إلى استجابات سريعة
- الأسئلة مباشرة
- البحث عن مستند واحد كافٍ

**استخدم Agentic RAG عندما:**
- الأسئلة تتطلب خطوات متعددة
- تحتاج إلى استرجاع ديناميكي
- المهمة تتضمن بحثاً أو استكشافاً

**استخدم RAT عندما:**
- مطلوب تفكير تحليلي عميق
- الجودة أكثر أهمية من السرعة
- مطلوب استدلال معقد متعدد القفزات

**استخدم تكامل MCP عندما:**
- تحتاج إلى بيانات خارجية في الوقت الفعلي
- المهمة تتطلب استخدام أدوات
- المعلومات الديناميكية ضرورية

## أفضل الممارسات

### 1. إعداد المستندات

**تحسين حجم الجزء:**
```python
# للمستندات التقنية
chunk_size = 512

# للمحتوى السردي
chunk_size = 1024
```

**تنظيم المجلدات:**
```
knowledge_base/
├── technical_docs/
├── user_manuals/
├── api_reference/
└── faq/
```

### 2. إدارة مخزن المتجهات

**الاستمرارية:**
```python
# استخدم دائماً التخزين الدائم في الإنتاج
vector_store_config = VectorStoreConfig(
    persist_directory="./prod_vectordb",
    collection_name="production_kb"
)
```

**تنظيم المجموعات:**
```python
# مجموعات منفصلة للمجالات المختلفة
collections = {
    "technical": "tech_docs_collection",
    "business": "business_docs_collection",
    "general": "general_knowledge_collection"
}
```

### 3. اختيار LLM

**التطوير:**
```python
# استخدم النماذج المحلية للتطوير
config = RAGConfig(
    llm="llama3.2:3b",
    provider=Settings.OLLAMA
)
```

**الإنتاج:**
```python
# استخدم نماذج أقوى للإنتاج
config = RAGConfig(
    llm="gpt-4",
    provider=Settings.OPENAI
)
```

### 4. معالجة الأخطاء

```python
"""خط RAG قوي مع معالجة الأخطاء"""

try:
    pipeline = RAGPipeline(config, vector_store_config)
    pipeline.build()
    response = pipeline.generate(query)
except Exception as e:
    print(f"خطأ في خط الأنابيب: {e}")
    # الرجوع إلى LLM الأساسي بدون RAG
    response = fallback_generate(query)
```

### 5. تكوين المجلدات المتجاهلة

عند فهرسة مستودعات الكود، استبعد الدلائل غير الضرورية:

```python
# مجلدات مخصصة للتجاهل
custom_ignore_folders = [
    ".venv",
    "venv",
    "node_modules",
    "__pycache__",
    ".git",
    "build",
    "dist",
    "my_custom_folder_to_ignore"
]

config = AgenticRAGConfig(
    ignore_folders=custom_ignore_folders,
    ...
)
```

### 6. المراقبة والتسجيل

```python
"""تمكين التسجيل التفصيلي"""

import logging

# تكوين مستوى التسجيل
logging.basicConfig(level=logging.INFO)

# أو استخدم إعداد RAGLight
Settings.setup_logging()

# مراقبة الأداء
import time

start_time = time.time()
response = pipeline.generate(query)
elapsed_time = time.time() - start_time

print(f"تمت معالجة الاستعلام في {elapsed_time:.2f}ث")
```

## التخصيص المتقدم

### منشئ خط أنابيب مخصص

```python
"""خط RAG مخصص بنمط المنشئ"""

from raglight.rag.builder import Builder
from raglight.config.settings import Settings

# بناء خط أنابيب مخصص
rag = Builder() \
    .with_embeddings(
        Settings.HUGGINGFACE,
        model_name=Settings.DEFAULT_EMBEDDINGS_MODEL
    ) \
    .with_vector_store(
        Settings.CHROMA,
        persist_directory="./custom_db",
        collection_name="custom_collection"
    ) \
    .with_llm(
        Settings.OLLAMA,
        model_name="llama3.2:3b",
        system_prompt_file="./custom_prompt.txt",
        provider=Settings.OLLAMA
    ) \
    .build_rag(k=5)

# استيعاب المستندات
rag.vector_store.ingest(data_path='./data')

# الاستعلام
response = rag.generate("سؤالك هنا")
```

### فهرسة مستودع الكود

```python
"""فهرسة مستودعات الكود"""

# فهرسة الكود مع استخراج التوقيعات
rag.vector_store.ingest(repos_path=['./repo1', './repo2'])

# البحث عن الكود
code_results = rag.vector_store.similarity_search("منطق المصادقة")

# البحث عن توقيعات الصف
class_results = rag.vector_store.similarity_search_class("تعريف صف User")
```

### تكامل مستودع GitHub

```python
"""فهرسة مستودعات GitHub مباشرة"""

from raglight.models.data_source_model import GitHubSource

knowledge_base = [
    GitHubSource(url="https://github.com/Bessouat40/RAGLight"),
    GitHubSource(url="https://github.com/your-org/your-repo")
]

config = RAGConfig(
    knowledge_base=knowledge_base,
    ...
)
```

## نشر Docker

### مثال Dockerfile

```dockerfile
FROM python:3.10-slim

WORKDIR /app

# تثبيت التبعيات
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# نسخ التطبيق
COPY . .

# إضافة تعيين المضيف لـ Ollama/LMStudio
# التشغيل: docker run --add-host=host.docker.internal:host-gateway your-image

CMD ["python", "app.py"]
```

### البناء والتشغيل

```bash
# بناء الصورة
docker build -t raglight-app .

# التشغيل مع الوصول إلى شبكة المضيف (لـ Ollama)
docker run --add-host=host.docker.internal:host-gateway raglight-app
```

## استكشاف الأخطاء وإصلاحها

### المشاكل الشائعة

**1. خطأ اتصال Ollama:**
```python
# تحقق من تشغيل Ollama
# macOS/Linux:
ollama serve

# تحديث قاعدة API إذا لزم الأمر
vector_store_config = VectorStoreConfig(
    api_base="http://localhost:11434",  # عنوان URL الافتراضي لـ Ollama
    ...
)
```

**2. مشاكل الذاكرة:**
```python
# تقليل حجم الجزء وقيمة k
config = RAGConfig(
    k=3,  # استرجاع عدد أقل من المستندات
    ...
)
```

**3. الأداء البطيء:**
```python
# استخدام نماذج تضمين أصغر
vector_store_config = VectorStoreConfig(
    embedding_model="all-MiniLM-L6-v2",  # نموذج أصغر وأسرع
    ...
)
```

**4. أخطاء مخزن المتجهات:**
```bash
# المسح وإعادة البناء
rm -rf ./chroma_db
python rebuild_kb.py
```

## الخلاصة

يوفر RAGLight إطار عمل قوي ومرن لبناء أنظمة التوليد المعززة بالاسترجاع. سواء كنت بحاجة إلى Q&A بسيط للمستندات أو سير عمل وكيل معقدة مع تكامل الأدوات الخارجية، فإن البنية المعيارية لـ RAGLight تجعل من السهل البناء والتوسع.

### النقاط الرئيسية

- **ابدأ ببساطة**: ابدأ بـ RAG الأساسي وقم بالترقية إلى Agentic RAG أو RAT حسب الحاجة
- **اختر بحكمة**: اختر خط الأنابيب المناسب بناءً على حالة الاستخدام ومتطلبات الأداء
- **خصص بشكل واسع**: يتيح تصميم RAGLight المعياري التخصيص الكامل
- **قم بالتوسع تدريجياً**: ابدأ محلياً مع Ollama، ثم انتقل إلى موفري السحابة للإنتاج

### الخطوات التالية

1. **تجربة**: جرب موفري LLM ومخازن المتجهات المختلفة
2. **تحسين**: ضبط قيم k وأحجام الأجزاء واختيار النماذج
3. **دمج**: أضف خوادم MCP للوصول إلى الأدوات الخارجية
4. **نشر**: احتوي مع Docker للنشر في الإنتاج

### الموارد

- **RAGLight GitHub**: [https://github.com/Bessouat40/RAGLight](https://github.com/Bessouat40/RAGLight)
- **حزمة PyPI**: [https://pypi.org/project/raglight/](https://pypi.org/project/raglight/)
- **Ollama**: [https://ollama.ai](https://ollama.ai)
- **ChromaDB**: [https://www.trychroma.com](https://www.trychroma.com)
- **بروتوكول MCP**: ابحث عن "Model Context Protocol" للوثائق

بناءً سعيداً مع RAGLight! 🚀

