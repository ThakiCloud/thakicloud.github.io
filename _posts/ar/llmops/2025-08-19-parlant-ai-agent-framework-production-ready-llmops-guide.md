---
layout: post
title: "إطار عمل Parlant لوكلاء الذكاء الاصطناعي: الدليل الشامل لـ LLMOps في بيئات الإنتاج"
excerpt: "بناء وكلاء ذكاء اصطناعي يلتزمون بالتعليمات بنسبة 100%. تعرف على كيفية تشغيل تطبيقات LLM موثوقة وقابلة للتنبؤ باستخدام نظام التحكم القائم على الإرشادات في Parlant."
seo_title: "إطار عمل Parlant لوكلاء الذكاء الاصطناعي: الدليل الشامل لـ LLMOps في الإنتاج - Thaki Cloud"
seo_description: "دليل LLMOps للإنتاج لبناء وتشغيل وكلاء ذكاء اصطناعي موثوقين باستخدام Parlant. التحكم القائم على الإرشادات، والرحلات الحوارية، وتنفيذ الميزات على مستوى المؤسسات."
date: 2025-08-19
last_modified_at: 2025-08-19
lang: ar
dir: rtl
canonical_url: "https://thakicloud.github.io/ar/llmops/parlant-ai-agent-framework-production-ready-llmops-guide/"
categories: [llmops]
tags: [parlant, ai-agents, llm-framework, production-ai, guideline-control, conversation-analytics, agent-reliability, enterprise-ai, emcie]
toc: true
toc_label: "دليل Parlant لـ LLMOps"
reading_time: 15 min
---

⏱️ **وقت القراءة المقدر**: 15 دقائق

## مقدمة: المشكلة الجوهرية في وكلاء LLM

إذا سبق لك تطوير وكلاء ذكاء اصطناعي، فمن المرجح أنك واجهت هذه المواقف:

- ✅ يعمل بشكل مثالي في بيئة الاختبار
- ❌ يتجاهل موجه النظام في المحادثات الفعلية مع المستخدمين
- ❌ ظهور الهلوسة في اللحظات الحرجة
- ❌ ردود غير متسقة في الحالات الاستثنائية
- ❌ سلوك غير قابل للتنبؤ ينتج نتائج مختلفة في كل مرة

هذا هو **التحدي الأساسي في LLMOps**. يقدم [Parlant](https://github.com/emcie-co/parlant) حلاً مبتكراً لهذه المشكلة.

> 🌟 **عرض القيمة الأساسي لـ Parlant**: إطار عمل وكلاء الذكاء الاصطناعي الذي "يضمن اتباع التعليمات بدلاً من مجرد الأمل في ذلك."

## مشكلات LLMOps الأساسية التي يحلها Parlant

### 1. التحرر من الاعتماد على موجه النظام

**قيود النهج التقليدي:**
```python
# النهج التقليدي: يعتمد على موجه نظام يحتوي على 47 قاعدة
system_prompt = """
You are a helpful assistant. Please follow these rules:
1. Always check user authentication
2. Never reveal sensitive information
3. Respond in Korean
... (44 more rules)
"""
```

**حل Parlant:**
```python
# تحكم مضمون عبر قواعد قائمة على الإرشادات
await agent.create_guideline(
    condition="Customer asks about refunds", 
    action="Check order status first to see if eligible",
    tools=[check_order_status],
)
```

### 2. تحويل السلوك غير القابل للتنبؤ إلى قواعد متسقة

| وكيل LLM التقليدي | وكيل Parlant |
|---|---|
| موجهات نظام معقدة | إرشادات بلغة طبيعية |
| الأمل في اتباع LLM للقواعد | التزام **مضمون** بالقواعد |
| سلوك غير قابل للتنبؤ | استجابات متسقة وقابلة للتنبؤ |
| صعوبة التصحيح | إمكانية تفسير كاملة |
| هندسة موجهات يدوية | أتمتة من خلال التحسين التكراري |

## فهم البنية المعمارية الأساسية لـ Parlant

### 1. نظام التحكم القائم على الإرشادات

جوهر Parlant هو **نظام الإرشادات الشرطية**:

```python
import parlant.sdk as p

async def setup_customer_service_agent():
    agent = await server.create_agent(
        name="CustomerServiceBot",
        description="Enterprise customer service agent"
    )
    
    # إرشاد المصادقة
    await agent.create_guideline(
        condition="User mentions account issues",
        action="First verify identity using security questions",
        tools=[verify_identity]
    )
    
    # إرشاد سياسة الاسترداد
    await agent.create_guideline(
        condition="Customer requests refund",
        action="Check order date and return policy eligibility first",
        tools=[check_order_status, verify_return_policy]
    )
    
    # إرشاد التصعيد
    await agent.create_guideline(
        condition="Customer expresses frustration or asks for manager",
        action="Acknowledge feelings and transfer to human agent",
        tools=[transfer_to_human]
    )
```

### 2. الرحلات الحوارية

نظام يرشد المستخدمين خطوة بخطوة نحو هدفهم:

```python
# مثال على رحلة طلب قرض
async def setup_loan_application_journey():
    # الخطوة 1: فحص الأهلية الأولية
    await agent.create_guideline(
        condition="User inquires about loan",
        action="Collect basic eligibility information: income, employment, credit score range",
        tools=[collect_basic_info]
    )
    
    # الخطوة 2: توجيه إعداد المستندات
    await agent.create_guideline(
        condition="User qualifies for pre-approval",
        action="Guide through required documents: pay stubs, tax returns, bank statements",
        tools=[document_checklist]
    )
    
    # الخطوة 3: دعم إكمال الطلب
    await agent.create_guideline(
        condition="All documents ready",
        action="Assist with application form completion and submission",
        tools=[application_form_helper]
    )
```

### 3. المطابقة الديناميكية للإرشادات

يختار الإرشاد المناسب تلقائياً بناءً على السياق:

```python
# إرشادات واعية بالسياق
await agent.create_guideline(
    condition="VIP customer (tier >= gold) asks about upgrade",
    action="Offer complimentary upgrade options and priority support",
    tools=[vip_upgrade_options]
)

await agent.create_guideline(
    condition="Standard customer asks about upgrade", 
    action="Present standard upgrade options with pricing",
    tools=[standard_upgrade_options]
)
```

## تنفيذ LLMOps في بيئة الإنتاج

### 1. الإعداد على مستوى المؤسسات

```python
import parlant.sdk as p
import os
from datetime import datetime

async def production_setup():
    # إعداد خادم الإنتاج
    async with p.Server(
        host="0.0.0.0",
        port=8800,
        cors_allowed_origins=["https://yourapp.com"],
        log_level="INFO"
    ) as server:
        
        # إنشاء الوكيل
        agent = await server.create_agent(
            name="ProductionAgent",
            description="Production-ready customer service agent",
            model="gpt-4o-mini",  # أو claude-3-5-sonnet-20241022
        )
        
        # إرشادات الأمان
        await setup_security_guidelines(agent)
        
        # إرشادات منطق الأعمال
        await setup_business_guidelines(agent)
        
        # إعداد المراقبة
        await setup_monitoring(agent)
        
        return agent

async def setup_security_guidelines(agent):
    """تهيئة الإرشادات المتعلقة بالأمان"""
    
    # حماية البيانات الشخصية
    await agent.create_guideline(
        condition="User shares personal information like SSN or credit card",
        action="Immediately warn about not sharing sensitive data and clear the information",
        tools=[clear_sensitive_data]
    )
    
    # التحقق من الصلاحيات
    await agent.create_guideline(
        condition="User requests account modifications",
        action="Verify identity through multi-factor authentication",
        tools=[verify_mfa]
    )
```

### 2. نظام المراقبة والتحليل

```python
async def setup_monitoring(agent):
    """تهيئة تحليل المحادثة والمراقبة"""
    
    # جمع مقاييس الأداء
    await agent.create_guideline(
        condition="Conversation ends",
        action="Log satisfaction score and resolution status",
        tools=[log_conversation_metrics]
    )
    
    # تتبع الأخطاء
    await agent.create_guideline(
        condition="Tool execution fails",
        action="Log error details and provide fallback response",
        tools=[log_error, provide_fallback]
    )

@p.tool
async def log_conversation_metrics(context: p.ToolContext, 
                                 satisfaction_score: int,
                                 resolution_status: str) -> p.ToolResult:
    """تسجيل مقاييس المحادثة"""
    
    metrics = {
        "timestamp": datetime.now().isoformat(),
        "agent_id": context.agent_id,
        "session_id": context.session_id,
        "satisfaction_score": satisfaction_score,
        "resolution_status": resolution_status,
        "turn_count": len(context.conversation_history)
    }
    
    # حفظ المقاييس (مثلاً DataDog أو CloudWatch)
    await save_metrics(metrics)
    
    return p.ToolResult("Metrics logged successfully")
```

### 3. التوسع وإدارة الأحمال

```python
# إعداد متعدد الوكلاء
async def setup_multi_agent_system():
    """نظام متعدد الوكلاء لتوزيع الأحمال"""
    
    agents = {}
    
    # وكلاء حسب التخصص
    agents['sales'] = await create_sales_agent()
    agents['support'] = await create_support_agent() 
    agents['technical'] = await create_technical_agent()
    
    # وكيل التوجيه
    router = await server.create_agent(
        name="RouterAgent",
        description="Routes conversations to appropriate specialist agents"
    )
    
    await router.create_guideline(
        condition="User asks about pricing or purchasing",
        action="Transfer to sales agent",
        tools=[transfer_to_sales]
    )
    
    return agents, router

@p.tool 
async def transfer_to_sales(context: p.ToolContext) -> p.ToolResult:
    """التحويل إلى وكيل المبيعات"""
    
    # التحويل مع الحفاظ على السياق
    transfer_data = {
        "conversation_history": context.conversation_history,
        "user_context": context.user_data,
        "transfer_reason": "sales_inquiry"
    }
    
    await initiate_agent_transfer("sales", transfer_data)
    
    return p.ToolResult("Transferring to sales specialist...")
```

## أنماط تكامل الأدوات في الإنتاج

### 1. تكامل قواعد البيانات

```python
@p.tool
async def check_order_status(context: p.ToolContext, 
                           order_id: str) -> p.ToolResult:
    """أداة للتحقق من حالة الطلب"""
    
    try:
        # استعلام قاعدة البيانات
        async with get_db_connection() as conn:
            query = "SELECT status, items, total FROM orders WHERE id = $1"
            result = await conn.fetchrow(query, order_id)
            
        if not result:
            return p.ToolResult("Order not found", error=True)
            
        order_info = {
            "order_id": order_id,
            "status": result['status'],
            "items": result['items'],
            "total": result['total']
        }
        
        return p.ToolResult(f"Order {order_id}: {result['status']}", 
                          data=order_info)
                          
    except Exception as e:
        # معالجة الأخطاء والتسجيل
        await log_tool_error("check_order_status", str(e), context)
        return p.ToolResult("Unable to check order status. Please try again.", 
                          error=True)

@p.tool
async def update_customer_profile(context: p.ToolContext,
                                customer_id: str,
                                updates: dict) -> p.ToolResult:
    """تحديث ملف تعريف العميل"""
    
    # التحقق من الصلاحيات
    if not await verify_agent_permissions(context, "customer_update"):
        return p.ToolResult("Insufficient permissions", error=True)
    
    try:
        async with get_db_connection() as conn:
            # تحديث آمن (قائم على القائمة البيضاء)
            allowed_fields = ['phone', 'email', 'preferences']
            filtered_updates = {k: v for k, v in updates.items() 
                             if k in allowed_fields}
            
            if not filtered_updates:
                return p.ToolResult("No valid fields to update", error=True)
                
            # تنفيذ التحديث
            await conn.execute(
                "UPDATE customers SET updated_at = NOW(), " + 
                ", ".join(f"{k} = ${i+2}" for i, k in enumerate(filtered_updates.keys())) +
                " WHERE id = $1",
                customer_id, *filtered_updates.values()
            )
            
        return p.ToolResult("Profile updated successfully")
        
    except Exception as e:
        await log_tool_error("update_customer_profile", str(e), context)
        return p.ToolResult("Failed to update profile", error=True)
```

### 2. تكامل واجهات API الخارجية

```python
@p.tool
async def get_shipping_info(context: p.ToolContext, 
                          tracking_number: str) -> p.ToolResult:
    """استرداد معلومات الشحن"""
    
    try:
        # استدعاء API شركة الشحن الخارجية
        async with aiohttp.ClientSession() as session:
            headers = {
                "Authorization": f"Bearer {os.getenv('SHIPPING_API_KEY')}",
                "Content-Type": "application/json"
            }
            
            async with session.get(
                f"https://api.shipping.com/track/{tracking_number}",
                headers=headers,
                timeout=aiohttp.ClientTimeout(total=10)
            ) as response:
                
                if response.status == 404:
                    return p.ToolResult("Tracking number not found", error=True)
                    
                if response.status != 200:
                    return p.ToolResult("Shipping service temporarily unavailable", 
                                      error=True)
                    
                data = await response.json()
                
        # توحيد الاستجابة
        shipping_info = {
            "status": data.get("status"),
            "location": data.get("current_location"),
            "estimated_delivery": data.get("estimated_delivery_date"),
            "tracking_events": data.get("events", [])
        }
        
        return p.ToolResult(
            f"Package status: {shipping_info['status']}. " +
            f"Current location: {shipping_info['location']}",
            data=shipping_info
        )
        
    except asyncio.TimeoutError:
        return p.ToolResult("Shipping service timeout. Please try again later.", 
                          error=True)
    except Exception as e:
        await log_tool_error("get_shipping_info", str(e), context)
        return p.ToolResult("Unable to retrieve shipping information", 
                          error=True)
```

### 3. التكامل في الوقت الفعلي

```python
@p.tool
async def check_live_inventory(context: p.ToolContext, 
                              product_id: str) -> p.ToolResult:
    """فحص المخزون في الوقت الفعلي"""
    
    try:
        # استعلام المخزون الفعلي من Redis
        redis_client = await get_redis_connection()
        inventory_key = f"inventory:{product_id}"
        
        current_stock = await redis_client.get(inventory_key)
        
        if current_stock is None:
            # عند إخفاق ذاكرة التخزين المؤقت، الاستعلام من قاعدة البيانات والتخزين المؤقت
            async with get_db_connection() as conn:
                result = await conn.fetchval(
                    "SELECT quantity FROM inventory WHERE product_id = $1",
                    product_id
                )
                
            if result is None:
                return p.ToolResult("Product not found", error=True)
                
            current_stock = result
            # التخزين المؤقت لمدة 5 دقائق
            await redis_client.setex(inventory_key, 300, current_stock)
        else:
            current_stock = int(current_stock)
            
        # تحديد حالة المخزون
        if current_stock == 0:
            status = "Out of stock"
        elif current_stock < 10:
            status = "Low stock"
        else:
            status = "In stock"
            
        return p.ToolResult(
            f"Current stock: {current_stock} units ({status})",
            data={"product_id": product_id, "quantity": current_stock, "status": status}
        )
        
    except Exception as e:
        await log_tool_error("check_live_inventory", str(e), context)
        return p.ToolResult("Error checking inventory", error=True)
```

## أنماط تشغيل LLMOps المتقدمة

### 1. اختبار A/B والطرح التدريجي

```python
async def setup_ab_testing():
    """تهيئة الوكيل لاختبار A/B"""
    
    # الوكيل الأساسي (الإصدار الحالي)
    baseline_agent = await server.create_agent(
        name="BaselineAgent",
        description="Current production agent"
    )
    
    # وكيل التجربة (الإصدار الجديد)
    experiment_agent = await server.create_agent(
        name="ExperimentAgent", 
        description="New agent with improved guidelines"
    )
    
    # إضافة إرشادات أكثر تفصيلاً
    await experiment_agent.create_guideline(
        condition="Customer mentions competitor pricing",
        action="Acknowledge their research and highlight our unique value propositions",
        tools=[get_value_propositions, get_competitive_analysis]
    )
    
    return baseline_agent, experiment_agent

@p.tool
async def route_to_agent_variant(context: p.ToolContext, 
                               user_id: str) -> p.ToolResult:
    """توجيه المستخدم إلى مجموعة اختبار A/B"""
    
    # تعيين مجموعة متسقة باستخدام تجزئة معرف المستخدم
    import hashlib
    hash_value = int(hashlib.md5(user_id.encode()).hexdigest(), 16)
    
    # توزيع 50/50
    if hash_value % 2 == 0:
        variant = "baseline"
    else:
        variant = "experiment"
    
    # تسجيل بيانات التجربة
    await log_ab_test_assignment(user_id, variant)
    
    return p.ToolResult(f"Assigned to {variant} group", 
                       data={"variant": variant})
```

### 2. تحسين الأداء والتخزين المؤقت

```python
from functools import lru_cache
import asyncio

class ToolCache:
    """نظام تخزين مؤقت لنتائج تنفيذ الأدوات"""
    
    def __init__(self):
        self._cache = {}
        self._cache_expiry = {}
    
    async def get_or_compute(self, key: str, compute_func, ttl: int = 300):
        """الاسترداد من الذاكرة المؤقتة أو الحساب والتخزين المؤقت"""
        
        now = asyncio.get_event_loop().time()
        
        # التحقق من وجود النتيجة في الذاكرة المؤقتة
        if key in self._cache and self._cache_expiry.get(key, 0) > now:
            return self._cache[key]
        
        # الحساب عند إخفاق الذاكرة المؤقتة
        result = await compute_func()
        
        # تخزين النتيجة مؤقتاً
        self._cache[key] = result
        self._cache_expiry[key] = now + ttl
        
        return result

tool_cache = ToolCache()

@p.tool
async def get_product_recommendations(context: p.ToolContext,
                                    customer_id: str) -> p.ToolResult:
    """توصيات منتجات مخصصة (مع التخزين المؤقت)"""
    
    cache_key = f"recommendations:{customer_id}"
    
    async def compute_recommendations():
        # عمل استدلال ML كثيف
        async with get_ml_service() as ml:
            recommendations = await ml.get_recommendations(customer_id)
        return recommendations
    
    try:
        # تخزين مؤقت لمدة 10 دقائق
        recommendations = await tool_cache.get_or_compute(
            cache_key, compute_recommendations, ttl=600
        )
        
        return p.ToolResult(
            f"Found {len(recommendations)} recommended products",
            data={"recommendations": recommendations}
        )
        
    except Exception as e:
        await log_tool_error("get_product_recommendations", str(e), context)
        return p.ToolResult("Recommendation system temporarily unavailable", error=True)
```

### 3. استعادة الأخطاء والتسامح مع الأعطال

```python
@p.tool
async def resilient_payment_processing(context: p.ToolContext,
                                     payment_data: dict) -> p.ToolResult:
    """معالجة مدفوعات مرنة"""
    
    # محاولة بوابات الدفع الأساسية بالترتيب
    for gateway in ["primary", "secondary", "tertiary"]:
        try:
            result = await process_payment_with_gateway(gateway, payment_data)
            
            if result.success:
                await log_payment_success(gateway, payment_data)
                return p.ToolResult(
                    f"Payment completed. Confirmation: {result.transaction_id}",
                    data={"transaction_id": result.transaction_id}
                )
                
        except Exception as e:
            await log_payment_failure(gateway, str(e), payment_data)
            
            # إذا فشلت البوابة الأخيرة أيضاً
            if gateway == "tertiary":
                # الإضافة إلى قائمة انتظار إعادة المحاولة غير المتزامنة
                await enqueue_payment_retry(payment_data)
                
                return p.ToolResult(
                    "Payment processing encountered an issue. Please try again shortly.",
                    error=True
                )
            
            # الانتقال إلى البوابة التالية
            continue
    
    return p.ToolResult("All payment systems temporarily unavailable", 
                      error=True)

async def setup_circuit_breaker():
    """تنفيذ نمط قاطع الدائرة"""
    
    circuit_breakers = {}
    
    async def call_with_circuit_breaker(service_name: str, func, *args, **kwargs):
        breaker = circuit_breakers.get(service_name)
        
        if not breaker:
            breaker = CircuitBreaker(
                failure_threshold=5,
                timeout=60,
                expected_exception=Exception
            )
            circuit_breakers[service_name] = breaker
        
        return await breaker.call(func, *args, **kwargs)
    
    return call_with_circuit_breaker
```

## الأمان والامتثال

### 1. حماية البيانات والخصوصية

```python
import hashlib
from cryptography.fernet import Fernet

class DataProtection:
    """أدوات حماية البيانات"""
    
    def __init__(self):
        self.encryption_key = os.getenv('ENCRYPTION_KEY').encode()
        self.fernet = Fernet(self.encryption_key)
    
    def mask_pii(self, text: str) -> str:
        """إخفاء البيانات الشخصية"""
        import re
        
        # إخفاء عناوين البريد الإلكتروني
        text = re.sub(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b', 
                     '***@***.***', text)
        
        # إخفاء أرقام الهاتف
        text = re.sub(r'\b\d{3}-\d{4}-\d{4}\b', '***-****-****', text)
        
        # إخفاء أرقام بطاقات الائتمان
        text = re.sub(r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b', 
                     '****-****-****-****', text)
        
        return text
    
    def encrypt_sensitive_data(self, data: str) -> str:
        """تشفير البيانات الحساسة"""
        return self.fernet.encrypt(data.encode()).decode()
    
    def decrypt_sensitive_data(self, encrypted_data: str) -> str:
        """فك تشفير البيانات الحساسة"""
        return self.fernet.decrypt(encrypted_data.encode()).decode()

data_protection = DataProtection()

@p.tool
async def log_conversation_securely(context: p.ToolContext,
                                  conversation_data: dict) -> p.ToolResult:
    """التسجيل الآمن"""
    
    # إخفاء البيانات الشخصية
    masked_data = data_protection.mask_pii(str(conversation_data))
    
    # حفظ سجل المراجعة
    audit_log = {
        "timestamp": datetime.now().isoformat(),
        "agent_id": context.agent_id,
        "session_id": hashlib.sha256(context.session_id.encode()).hexdigest()[:16],
        "action": "conversation_logged",
        "data_hash": hashlib.sha256(masked_data.encode()).hexdigest()
    }
    
    await save_audit_log(audit_log)
    
    return p.ToolResult("Conversation logged securely")
```

### 2. إدارة الأدوار والتحكم في الوصول

```python
class RoleBasedAccessControl:
    """التحكم في الوصول القائم على الأدوار"""
    
    def __init__(self):
        self.permissions = {
            "customer_service": [
                "read_order", "update_contact_info", "process_return"
            ],
            "sales": [
                "read_order", "create_quote", "apply_discount"
            ],
            "manager": [
                "read_order", "update_contact_info", "process_return",
                "create_quote", "apply_discount", "override_policy"
            ]
        }
    
    async def check_permission(self, agent_role: str, action: str) -> bool:
        """التحقق من الصلاحية"""
        return action in self.permissions.get(agent_role, [])

rbac = RoleBasedAccessControl()

@p.tool
async def apply_discount(context: p.ToolContext,
                        order_id: str,
                        discount_percent: float) -> p.ToolResult:
    """تطبيق الخصم (مع التحقق من الصلاحيات)"""
    
    # التحقق من الصلاحيات
    agent_role = context.user_data.get("role", "customer_service")
    
    if not await rbac.check_permission(agent_role, "apply_discount"):
        return p.ToolResult("Insufficient permissions to apply discount", error=True)
    
    # التحقق من حد الخصم
    max_discount = 30 if agent_role == "manager" else 10
    
    if discount_percent > max_discount:
        return p.ToolResult(
            f"Discount exceeds maximum allowed ({max_discount}%) for your role",
            error=True
        )
    
    try:
        # منطق تطبيق الخصم
        result = await apply_order_discount(order_id, discount_percent)
        
        # سجل المراجعة
        await log_action(
            agent_id=context.agent_id,
            action="apply_discount",
            details={"order_id": order_id, "discount": discount_percent}
        )
        
        return p.ToolResult(f"Applied {discount_percent}% discount to order {order_id}")
        
    except Exception as e:
        await log_tool_error("apply_discount", str(e), context)
        return p.ToolResult("Failed to apply discount", error=True)
```

## مراقبة الأداء والتحليلات

### 1. نظام جمع المقاييس

```python
import time
from dataclasses import dataclass
from typing import Optional

@dataclass
class ConversationMetrics:
    session_id: str
    agent_id: str
    start_time: float
    end_time: Optional[float] = None
    message_count: int = 0
    tool_calls: int = 0
    errors: int = 0
    user_satisfaction: Optional[int] = None
    resolution_achieved: bool = False

class MetricsCollector:
    def __init__(self):
        self.active_sessions = {}
    
    async def start_session(self, session_id: str, agent_id: str):
        self.active_sessions[session_id] = ConversationMetrics(
            session_id=session_id,
            agent_id=agent_id,
            start_time=time.time()
        )
    
    async def record_message(self, session_id: str):
        if session_id in self.active_sessions:
            self.active_sessions[session_id].message_count += 1
    
    async def record_tool_call(self, session_id: str, success: bool = True):
        if session_id in self.active_sessions:
            metrics = self.active_sessions[session_id]
            metrics.tool_calls += 1
            if not success:
                metrics.errors += 1
    
    async def end_session(self, session_id: str, 
                         satisfaction: Optional[int] = None,
                         resolved: bool = False):
        if session_id not in self.active_sessions:
            return
        
        metrics = self.active_sessions[session_id]
        metrics.end_time = time.time()
        metrics.user_satisfaction = satisfaction
        metrics.resolution_achieved = resolved
        
        await self.save_metrics(metrics)
        del self.active_sessions[session_id]
    
    async def save_metrics(self, metrics: ConversationMetrics):
        duration = metrics.end_time - metrics.start_time if metrics.end_time else 0
        
        metric_data = {
            "session_id": metrics.session_id,
            "agent_id": metrics.agent_id,
            "duration_seconds": duration,
            "message_count": metrics.message_count,
            "tool_calls": metrics.tool_calls,
            "error_count": metrics.errors,
            "satisfaction_score": metrics.user_satisfaction,
            "resolution_achieved": metrics.resolution_achieved,
            "timestamp": datetime.now().isoformat()
        }
        
        await save_to_timeseries_db(metric_data)
        await update_dashboard(metric_data)

metrics_collector = MetricsCollector()

@p.tool
async def collect_user_feedback(context: p.ToolContext,
                               satisfaction_score: int,
                               feedback_text: str = "") -> p.ToolResult:
    
    await metrics_collector.record_message(context.session_id)
    
    feedback_data = {
        "session_id": context.session_id,
        "agent_id": context.agent_id,
        "satisfaction_score": satisfaction_score,
        "feedback_text": feedback_text,
        "timestamp": datetime.now().isoformat()
    }
    
    await save_feedback(feedback_data)
    
    if satisfaction_score <= 2:
        await trigger_quality_alert(feedback_data)
    
    return p.ToolResult("Thank you for your feedback!")
```

### 2. تنفيذ لوحة التحكم في الوقت الفعلي

```python
import asyncio
from collections import defaultdict, deque

class RealTimeDashboard:
    def __init__(self):
        self.active_sessions = 0
        self.hourly_metrics = defaultdict(lambda: {
            "conversations": 0,
            "avg_satisfaction": 0,
            "resolution_rate": 0,
            "avg_duration": 0
        })
        self.recent_errors = deque(maxlen=100)
    
    async def update_active_sessions(self, delta: int):
        self.active_sessions += delta
        await self.broadcast_update("active_sessions", self.active_sessions)
    
    async def record_conversation_end(self, metrics: ConversationMetrics):
        hour_key = datetime.now().strftime("%Y-%m-%d %H:00")
        hourly = self.hourly_metrics[hour_key]
        
        hourly["conversations"] += 1
        
        if metrics.user_satisfaction:
            current_avg = hourly["avg_satisfaction"]
            count = hourly["conversations"]
            new_avg = ((current_avg * (count - 1)) + metrics.user_satisfaction) / count
            hourly["avg_satisfaction"] = new_avg
        
        if metrics.resolution_achieved:
            resolution_count = hourly.get("resolutions", 0) + 1
            hourly["resolutions"] = resolution_count
            hourly["resolution_rate"] = resolution_count / hourly["conversations"]
        
        duration = metrics.end_time - metrics.start_time
        current_avg_duration = hourly["avg_duration"]
        new_avg_duration = ((current_avg_duration * (count - 1)) + duration) / count
        hourly["avg_duration"] = new_avg_duration
        
        await self.broadcast_update("hourly_metrics", dict(self.hourly_metrics))
    
    async def record_error(self, error_data: dict):
        self.recent_errors.append(error_data)
        await self.broadcast_update("recent_errors", list(self.recent_errors))
    
    async def broadcast_update(self, metric_type: str, data):
        message = {
            "type": metric_type,
            "data": data,
            "timestamp": datetime.now().isoformat()
        }
        await websocket_broadcast(message)

dashboard = RealTimeDashboard()

async def websocket_handler(websocket, path):
    try:
        await websocket.send(json.dumps({
            "type": "initial_data",
            "data": {
                "active_sessions": dashboard.active_sessions,
                "hourly_metrics": dict(dashboard.hourly_metrics),
                "recent_errors": list(dashboard.recent_errors)
            }
        }))
        
        await websocket.wait_closed()
        
    except Exception as e:
        print(f"WebSocket error: {e}")
```

## الخاتمة: مستقبل LLMOps الموثوق

يحل Parlant المشكلات الجوهرية في LLMOps من خلال تحول نموذجي من **"الأمل" إلى "الضمان"**:

### القيمة الأساسية

1. **إمكانية التنبؤ**: سلوك وكيل متسق مضمون من خلال التحكم القائم على الإرشادات
2. **قابلية التوسع**: ميزات على مستوى المؤسسات ودعم الأنظمة متعددة الوكلاء
3. **إمكانية المراقبة**: إمكانية تفسير كاملة ومراقبة في الوقت الفعلي
4. **الاستقرار**: معالجة قوية للأخطاء وآليات استعادة الأعطال
5. **الأمان**: حماية بيانات مدمجة وأنظمة التحكم في الوصول

### البدء

```bash
# تثبيت Parlant
pip install parlant

# بناء وكيل جاهز للإنتاج في 60 ثانية
python -c "
import parlant.sdk as p
import asyncio

async def main():
    async with p.Server() as server:
        agent = await server.create_agent(name='ProductionAgent')
        await agent.create_guideline(
            condition='User needs help',
            action='Provide helpful assistance',
            tools=[]
        )
        print('Agent ready at http://localhost:8800')
        await asyncio.sleep(3600)

asyncio.run(main())
"
```

### الأثر على الأعمال

- **تحسين رضا العملاء**: تجربة مستخدم محسّنة من خلال جودة خدمة متسقة
- **خفض التكاليف التشغيلية**: تخفيض تكاليف العمالة من خلال خدمة العملاء الآلية
- **إدارة المخاطر**: الامتثال التلقائي للوائح ومعايير الأمان
- **قابلية التوسع**: توسع مرن بما يتماشى مع نمو الأعمال

مع Parlant، لن تحتاج بعد الآن إلى الاعتماد على سلوك الذكاء الاصطناعي غير القابل للتنبؤ.

### موارد إضافية

- [الموقع الرسمي لـ Parlant](https://www.parlant.io)
- [الوثائق الكاملة](https://www.parlant.io/docs)
- [مجتمع Discord](https://discord.gg/duxWqxKk6J)
- [مستودع GitHub](https://github.com/emcie-co/parlant)
- [أمثلة عملية](https://www.parlant.io/docs/quickstart/examples)

---

💡 لا تتردد في التواصل في أي وقت عبر [Thaki Cloud Discord](https://discord.gg/thakicloud)!
