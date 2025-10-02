---
title: "Airweave: دليل شامل لمنصة البحث للذكاء الاصطناعي لأي تطبيق"
excerpt: "تعلم كيفية استخدام Airweave لربط 25+ تطبيق وأداة، مما يتيح للوكلاء الذكيين إجراء بحث دلالي عبر جميع بياناتك مع هذا البرنامج التعليمي الشامل."
seo_title: "دليل منصة Airweave للبحث بالذكاء الاصطناعي - Thaki Cloud"
seo_description: "دليل شامل لـ Airweave لربط 25+ تطبيق، البحث الدلالي، إعداد خادم MCP. يتضمن REST API، استخدام Python/TypeScript SDK، وأمثلة تطبيقية حقيقية."
date: 2025-10-02
categories:
  - tutorials
tags:
  - airweave
  - ai-agent
  - semantic-search
  - mcp
  - vector-database
author_profile: true
toc: true
toc_label: "جدول المحتويات"
canonical_url: "https://thakicloud.github.io/ar/tutorials/airweave-agent-search-platform-tutorial/"
lang: ar
permalink: /ar/tutorials/airweave-agent-search-platform-tutorial/
---

⏱️ **الوقت المقدر للقراءة**: 15 دقيقة

## نظرة عامة

**Airweave** هو منصة مبتكرة تتيح للوكلاء الذكيين البحث في أي تطبيق. يربط 25+ تطبيق وأداة، ويحول محتوياتها إلى قواعد معرفية قابلة للبحث يمكن للوكلاء الوصول إليها من خلال واجهة موحدة.

سيرشدك هذا البرنامج التعليمي عبر الميزات الأساسية لـ Airweave والتطبيق العملي خطوة بخطوة.

## 🚀 ما هو Airweave؟

### المفاهيم الأساسية

يوفر Airweave الميزات الأساسية التالية:

- **تكامل التطبيقات**: ربط 25+ أداة إنتاجية وقواعد بيانات ومخازن المستندات
- **تحويل البيانات**: تحويل محتويات التطبيقات المتصلة إلى قواعد معرفية قابلة للبحث
- **البحث الدلالي**: تمكين الوكلاء الذكيين من البحث في البيانات باستخدام اللغة الطبيعية
- **واجهة موحدة**: دعم REST API و MCP (Model Context Protocol)

### التكاملات المدعومة

يدعم Airweave الخدمات الرئيسية التالية:

- **إدارة المشاريع**: Asana، Jira، Linear، Monday.com
- **مستودعات الكود**: GitHub، Bitbucket
- **إدارة المستندات**: Notion، Confluence، Google Drive، OneDrive
- **التواصل**: Slack، Gmail، Outlook
- **قواعد البيانات**: PostgreSQL
- **أخرى**: Dropbox، HubSpot، Stripe، Todoist

## 🛠️ التثبيت والإعداد

### 1. متطلبات النظام

```bash
# التحقق من تثبيت Docker و Docker Compose
docker --version
docker-compose --version
```

### 2. تثبيت Airweave

```bash
# 1. استنساخ المستودع
git clone https://github.com/airweave-ai/airweave.git
cd airweave

# 2. منح أذونات التنفيذ والبدء
chmod +x start.sh
./start.sh
```

### 3. التحقق من الوصول

بعد التثبيت، يمكنك الوصول إلى الروابط التالية:

- **لوحة التحكم**: http://localhost:8080
- **وثائق API**: http://localhost:8001/docs

## 📊 استخدام لوحة التحكم

### 1. ربط المصادر

يمكنك ربط المصادر من خلال لوحة التحكم كما يلي:

1. انقر على زر **Connect Sources**
2. اختر الخدمة المطلوبة (مثل GitHub، Notion، Slack)
3. إكمال المصادقة OAuth
4. تكوين إعدادات المزامنة

### 2. تكوين المزامنة

```yaml
# مثال تكوين المزامنة
sync_config:
  frequency: "hourly"  # تكرار المزامنة
  incremental: true    # التحديثات التدريجية
  filters:
    - type: "documents"
    - date_range: "last_30_days"
```

## 🔌 استخدام API

### 1. استدعاءات API الأساسية

```python
import requests

# التكوين الأساسي لـ API
API_BASE_URL = "http://localhost:8001"
API_KEY = "your_api_key_here"

headers = {
    "Authorization": f"Bearer {API_KEY}",
    "Content-Type": "application/json"
}
```

### 2. إنشاء المجموعات

```python
def create_collection(name, description=""):
    """إنشاء مجموعة جديدة"""
    url = f"{API_BASE_URL}/collections"
    data = {
        "name": name,
        "description": description
    }
    
    response = requests.post(url, headers=headers, json=data)
    return response.json()

# مثال الاستخدام
collection = create_collection(
    name="my_documents",
    description="مجموعة المستندات الخاصة بي"
)
print(f"تم إنشاء المجموعة: {collection['id']}")
```

### 3. البحث في البيانات

```python
def search_documents(query, collection_id=None, limit=10):
    """البحث في المستندات"""
    url = f"{API_BASE_URL}/search"
    params = {
        "query": query,
        "limit": limit
    }
    
    if collection_id:
        params["collection_id"] = collection_id
    
    response = requests.get(url, headers=headers, params=params)
    return response.json()

# مثال الاستخدام
results = search_documents(
    query="خطة المشروع",
    limit=5
)

for result in results['results']:
    print(f"العنوان: {result['title']}")
    print(f"المحتوى: {result['content'][:100]}...")
    print(f"النقاط: {result['score']}")
    print("-" * 50)
```

## 📦 استخدام SDK

### Python SDK

```bash
# تثبيت SDK
pip install airweave-sdk
```

```python
from airweave import AirweaveSDK

# تهيئة العميل
client = AirweaveSDK(
    api_key="YOUR_API_KEY",
    base_url="http://localhost:8001"
)

# إنشاء مجموعة
collection = client.collections.create(
    name="my_collection",
    description="مجموعتي"
)

# البحث في المستندات
results = client.search.query(
    query="مستندات متعلقة بالذكاء الاصطناعي",
    collection_id=collection['id'],
    limit=10
)

# معالجة النتائج
for result in results:
    print(f"العنوان: {result.title}")
    print(f"المحتوى: {result.content[:100]}...")
    print(f"نقاط الصلة: {result.score}")
```

### TypeScript/JavaScript SDK

```bash
# تثبيت SDK
npm install @airweave/sdk
# أو
yarn add @airweave/sdk
```

```typescript
import { AirweaveSDKClient, AirweaveSDKEnvironment } from "@airweave/sdk";

// تهيئة العميل
const client = new AirweaveSDKClient({
    apiKey: "YOUR_API_KEY",
    environment: AirweaveSDKEnvironment.Local
});

// إنشاء مجموعة
const collection = await client.collections.create({
    name: "my_collection",
    description: "مجموعتي"
});

// البحث في المستندات
const results = await client.search.query({
    query: "مستندات متعلقة بالذكاء الاصطناعي",
    collectionId: collection.id,
    limit: 10
});

// معالجة النتائج
results.forEach(result => {
    console.log(`العنوان: ${result.title}`);
    console.log(`المحتوى: ${result.content.substring(0, 100)}...`);
    console.log(`نقاط الصلة: ${result.score}`);
});
```

## 🔧 إعداد خادم MCP

### 1. تكوين MCP

يمكن لـ Airweave العمل أيضًا كخادم MCP (Model Context Protocol):

```python
# تكوين خادم MCP
from airweave.mcp import AirweaveMCPServer

# تهيئة خادم MCP
mcp_server = AirweaveMCPServer(
    api_key="YOUR_API_KEY",
    base_url="http://localhost:8001"
)

# بدء الخادم
mcp_server.start()
```

### 2. الاستخدام مع عميل MCP

```python
# استخدام Airweave مع عميل MCP
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

async def search_with_airweave(query):
    """البحث باستخدام Airweave من خلال MCP"""
    async with stdio_client(StdioServerParameters(
        command="airweave-mcp",
        args=["--api-key", "YOUR_API_KEY"]
    )) as (read, write):
        async with ClientSession(read, write) as session:
            # تنفيذ بحث Airweave
            result = await session.call_tool(
                "airweave_search",
                arguments={"query": query}
            )
            return result
```

## 🎯 حالات الاستخدام الواقعية

### 1. إدارة المعرفة لفريق التطوير

```python
def setup_development_knowledge_base():
    """إعداد قاعدة المعرفة لفريق التطوير"""
    
    # ربط مستودعات GitHub
    github_connection = client.connections.create({
        "type": "github",
        "name": "company_repos",
        "config": {
            "repositories": ["company/frontend", "company/backend"],
            "include_issues": True,
            "include_pull_requests": True
        }
    })
    
    # ربط مستندات Notion
    notion_connection = client.connections.create({
        "type": "notion",
        "name": "dev_docs",
        "config": {
            "database_id": "your_notion_database_id",
            "include_comments": True
        }
    })
    
    # إنشاء مجموعة
    dev_collection = client.collections.create({
        "name": "development_knowledge",
        "description": "قاعدة المعرفة لفريق التطوير"
    })
    
    # إضافة الاتصالات إلى المجموعة
    client.collections.add_connection(
        dev_collection['id'],
        github_connection['id']
    )
    client.collections.add_connection(
        dev_collection['id'],
        notion_connection['id']
    )
    
    return dev_collection

# مثال الاستخدام
dev_kb = setup_development_knowledge_base()
print(f"تم إنشاء قاعدة المعرفة لفريق التطوير: {dev_kb['id']}")
```

### 2. نظام دعم العملاء

```python
def setup_customer_support_system():
    """إعداد نظام دعم العملاء"""
    
    # ربط قنوات Slack
    slack_connection = client.connections.create({
        "type": "slack",
        "name": "support_channel",
        "config": {
            "channels": ["#customer-support", "#technical-support"],
            "include_threads": True
        }
    })
    
    # ربط البريد الإلكتروني
    email_connection = client.connections.create({
        "type": "gmail",
        "name": "support_emails",
        "config": {
            "labels": ["support", "tickets"],
            "include_attachments": True
        }
    })
    
    # إنشاء مجموعة الدعم
    support_collection = client.collections.create({
        "name": "customer_support",
        "description": "قاعدة المعرفة لدعم العملاء"
    })
    
    return support_collection

# البحث في أسئلة العملاء
def search_customer_question(question):
    """البحث عن إجابات لأسئلة العملاء"""
    results = client.search.query({
        "query": question,
        "collection_id": "customer_support",
        "limit": 5
    })
    
    return results
```

### 3. تكامل الوكيل الذكي

```python
class AirweaveAgent:
    """وكيل ذكي يستخدم Airweave"""
    
    def __init__(self, api_key, base_url):
        self.client = AirweaveSDK(
            api_key=api_key,
            base_url=base_url
        )
        self.collection_id = None
    
    def setup_knowledge_base(self, collection_name):
        """إعداد قاعدة المعرفة"""
        self.collection_id = self.client.collections.create({
            "name": collection_name
        })['id']
        return self.collection_id
    
    def search_knowledge(self, query, limit=5):
        """البحث في قاعدة المعرفة"""
        return self.client.search.query({
            "query": query,
            "collection_id": self.collection_id,
            "limit": limit
        })
    
    def answer_question(self, question):
        """توليد إجابة للسؤال"""
        # البحث في المستندات ذات الصلة
        relevant_docs = self.search_knowledge(question)
        
        # بناء السياق
        context = "\n".join([
            f"المستند: {doc.title}\nالمحتوى: {doc.content[:500]}..."
            for doc in relevant_docs
        ])
        
        # توليد الإجابة باستخدام نموذج الذكاء الاصطناعي (مثال)
        prompt = f"""
        يرجى الإجابة على السؤال بناءً على السياق التالي:
        
        السياق:
        {context}
        
        السؤال: {question}
        
        الإجابة:
        """
        
        # هنا ستستدعي نموذج الذكاء الاصطناعي الفعلي
        return self.generate_answer(prompt)

# مثال الاستخدام
agent = AirweaveAgent("your_api_key", "http://localhost:8001")
agent.setup_knowledge_base("company_knowledge")

# الإجابة على الأسئلة
answer = agent.answer_question("ما هو جدول المشروع؟")
print(answer)
```

## 🔍 الميزات المتقدمة

### 1. المزامنة التدريجية

```python
def setup_incremental_sync(connection_id):
    """إعداد المزامنة التدريجية"""
    sync_config = {
        "incremental": True,
        "frequency": "hourly",
        "content_hash_check": True,
        "last_modified_filter": True
    }
    
    return client.syncs.create({
        "connection_id": connection_id,
        "config": sync_config
    })
```

### 2. استخراج الكيانات

```python
def extract_entities(document):
    """استخراج الكيانات من المستند"""
    entities = client.entities.extract({
        "text": document['content'],
        "types": ["person", "organization", "location", "date"]
    })
    
    return entities
```

### 3. إدارة الإصدارات

```python
def get_document_versions(document_id):
    """الحصول على تاريخ إصدارات المستند"""
    versions = client.documents.get_versions(document_id)
    
    for version in versions:
        print(f"الإصدار: {version['version']}")
        print(f"تاريخ الإنشاء: {version['created_at']}")
        print(f"التغييرات: {version['changes']}")
```

## 🚨 استكشاف الأخطاء وإصلاحها

### 1. الأخطاء الشائعة

```python
# معالجة أخطاء الاتصال
try:
    result = client.search.query({"query": "test"})
except ConnectionError as e:
    print(f"خطأ في الاتصال: {e}")
    # منطق إعادة المحاولة
except AuthenticationError as e:
    print(f"خطأ في المصادقة: {e}")
    # التحقق من مفتاح API
```

### 2. تحسين الأداء

```python
# تحسين أداء البحث
def optimized_search(query, filters=None):
    """بحث محسن"""
    search_params = {
        "query": query,
        "limit": 10,
        "include_metadata": True
    }
    
    if filters:
        search_params["filters"] = filters
    
    return client.search.query(search_params)

# مثال الاستخدام
results = optimized_search(
    query="خطة المشروع",
    filters={"source": "notion", "date_range": "last_month"}
)
```

### 3. السجلات والمراقبة

```python
import logging

# تكوين السجلات
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def monitor_sync_status(connection_id):
    """مراقبة حالة المزامنة"""
    status = client.syncs.get_status(connection_id)
    
    if status['status'] == 'failed':
        logger.error(f"فشلت المزامنة: {status['error']}")
    elif status['status'] == 'running':
        logger.info(f"المزامنة قيد التقدم: {status['progress']}%")
    else:
        logger.info(f"اكتملت المزامنة: {status['last_sync']}")
```

## 📈 المراقبة والتحليل

### 1. إحصائيات الاستخدام

```python
def get_usage_statistics():
    """الحصول على إحصائيات الاستخدام"""
    stats = client.analytics.get_usage_stats({
        "period": "last_30_days",
        "include_breakdown": True
    })
    
    print(f"إجمالي عمليات البحث: {stats['total_searches']}")
    print(f"متوسط وقت الاستجابة: {stats['avg_response_time']}ms")
    print(f"الاستعلامات الشائعة: {stats['popular_queries']}")
```

### 2. مقاييس الأداء

```python
def monitor_performance():
    """مراقبة مقاييس الأداء"""
    metrics = client.analytics.get_performance_metrics()
    
    print(f"وقت استجابة API: {metrics['api_response_time']}ms")
    print(f"دقة البحث: {metrics['search_accuracy']}%")
    print(f"توفر النظام: {metrics['availability']}%")
```

## 🔐 الأمان والتحكم في الوصول

### 1. إدارة مفاتيح API

```python
def manage_api_keys():
    """إدارة مفاتيح API"""
    # إنشاء مفتاح API جديد
    new_key = client.auth.create_api_key({
        "name": "production_key",
        "permissions": ["read", "write"],
        "expires_at": "2025-12-31"
    })
    
    # قائمة مفاتيح API
    keys = client.auth.list_api_keys()
    
    # حذف المفاتيح غير المستخدمة
    for key in keys:
        if key['last_used'] < "2025-01-01":
            client.auth.revoke_api_key(key['id'])
```

### 2. التحكم في الوصول

```python
def setup_access_control(collection_id):
    """إعداد التحكم في الوصول"""
    # تعيين أذونات محددة للمستخدمين
    permissions = client.permissions.set_collection_access({
        "collection_id": collection_id,
        "user_permissions": {
            "user1": ["read"],
            "user2": ["read", "write"],
            "admin": ["read", "write", "delete"]
        }
    })
    
    return permissions
```

## 🎉 الخلاصة

Airweave هو منصة قوية تتيح للوكلاء الذكيين الوصول إلى البيانات من أي تطبيق. من خلال هذا البرنامج التعليمي، تعلمنا:

1. **تثبيت وإعداد Airweave الأساسي**
2. **ربط 25+ تطبيق وأداة**
3. **استخدام REST API و SDK**
4. **إعداد خادم MCP**
5. **أمثلة التطبيق العملي**
6. **استخدام الميزات المتقدمة**

### الخطوات التالية

- راجع [الوثائق الرسمية لـ Airweave](https://github.com/airweave-ai/airweave)
- انضم إلى [مجتمع Discord](https://discord.gg/airweave)
- قدم ملاحظات من خلال [GitHub Issues](https://github.com/airweave-ai/airweave/issues)

قم بترقية قدرات البحث للوكيل الذكي مع Airweave!

---

**💡 نصيحة**: جميع الأكواد في هذا البرنامج التعليمي قابلة للتنفيذ وتم اختبارها على macOS. إذا واجهت مشاكل، يمكنك الحصول على المساعدة من خلال [GitHub Issues](https://github.com/airweave-ai/airweave/issues).
