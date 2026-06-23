---
layout: post
title: "Parlant AI Agent Framework: A Complete Production LLMOps Guide"
excerpt: "Build AI agents that follow instructions 100% of the time. Learn how to operate predictable and reliable LLM applications using Parlant's guideline-based control system."
seo_title: "Parlant AI Agent Framework: Complete Production LLMOps Guide - Thaki Cloud"
seo_description: "A production LLMOps guide for building and operating reliable AI agents with Parlant. Guideline-based control, conversational journeys, and enterprise-grade feature implementation."
date: 2025-08-19
last_modified_at: 2025-08-19
lang: en
canonical_url: "https://thakicloud.github.io/en/llmops/parlant-ai-agent-framework-production-ready-llmops-guide/"
categories: [llmops]
tags: [parlant, ai-agents, llm-framework, production-ai, guideline-control, conversation-analytics, agent-reliability, enterprise-ai, emcie]
toc: true
toc_label: "Parlant LLMOps Guide"
reading_time: 15 min
published: false
---

⏱️ **Estimated reading time**: 15 min

## Introduction: The Fundamental Problem with LLM Agents

If you have built AI agents before, you have likely encountered situations like these:

- ✅ Works perfectly in the test environment
- ❌ Ignores the system prompt in real user conversations
- ❌ Hallucinations at critical moments
- ❌ Inconsistent responses in edge cases
- ❌ Unpredictable behavior producing different results every time

This is the **core challenge of LLMOps**. [Parlant](https://github.com/emcie-co/parlant) offers an innovative solution to this problem.

> 🌟 **Parlant Core Value Proposition**: An AI agent framework that "guarantees instructions are followed, rather than hoping they will be."

## Core LLMOps Problems Parlant Solves

### 1. Breaking Free from System Prompt Dependency

**The limitation of the traditional approach:**
```python
# Traditional approach: relies on a system prompt containing 47 rules
system_prompt = """
You are a helpful assistant. Please follow these rules:
1. Always check user authentication
2. Never reveal sensitive information
3. Respond in Korean
... (44 more rules)
"""
```

**Parlant's solution:**
```python
# Guaranteed control through guideline-based rules
await agent.create_guideline(
    condition="Customer asks about refunds", 
    action="Check order status first to see if eligible",
    tools=[check_order_status],
)
```

### 2. Converting Unpredictable Behavior into Consistent Rules

| Traditional LLM Agent | Parlant Agent |
|---|---|
| Complex system prompts | Natural language guidelines |
| Hoping the LLM follows rules | **Guaranteed** rule adherence |
| Unpredictable behavior | Consistent and predictable responses |
| Difficult to debug | Full explainability |
| Manual prompt engineering | Automation through iterative improvement |

## Understanding Parlant's Core Architecture

### 1. Guideline-Based Control System

The heart of Parlant is its **conditional guideline system**:

```python
import parlant.sdk as p

async def setup_customer_service_agent():
    agent = await server.create_agent(
        name="CustomerServiceBot",
        description="Enterprise customer service agent"
    )
    
    # Authentication-related guideline
    await agent.create_guideline(
        condition="User mentions account issues",
        action="First verify identity using security questions",
        tools=[verify_identity]
    )
    
    # Refund policy guideline
    await agent.create_guideline(
        condition="Customer requests refund",
        action="Check order date and return policy eligibility first",
        tools=[check_order_status, verify_return_policy]
    )
    
    # Escalation guideline
    await agent.create_guideline(
        condition="Customer expresses frustration or asks for manager",
        action="Acknowledge feelings and transfer to human agent",
        tools=[transfer_to_human]
    )
```

### 2. Conversational Journeys

A system that guides users step-by-step toward their goal:

```python
# Loan application journey example
async def setup_loan_application_journey():
    # Step 1: Initial eligibility check
    await agent.create_guideline(
        condition="User inquires about loan",
        action="Collect basic eligibility information: income, employment, credit score range",
        tools=[collect_basic_info]
    )
    
    # Step 2: Document preparation guidance
    await agent.create_guideline(
        condition="User qualifies for pre-approval",
        action="Guide through required documents: pay stubs, tax returns, bank statements",
        tools=[document_checklist]
    )
    
    # Step 3: Application completion support
    await agent.create_guideline(
        condition="All documents ready",
        action="Assist with application form completion and submission",
        tools=[application_form_helper]
    )
```

### 3. Dynamic Guideline Matching

Automatically selects the appropriate guideline based on context:

```python
# Context-aware guidelines
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

## Production LLMOps Implementation

### 1. Enterprise-Grade Setup

```python
import parlant.sdk as p
import os
from datetime import datetime

async def production_setup():
    # Production server configuration
    async with p.Server(
        host="0.0.0.0",
        port=8800,
        cors_allowed_origins=["https://yourapp.com"],
        log_level="INFO"
    ) as server:
        
        # Create agent
        agent = await server.create_agent(
            name="ProductionAgent",
            description="Production-ready customer service agent",
            model="gpt-4o-mini",  # or claude-3-5-sonnet-20241022
        )
        
        # Security guidelines
        await setup_security_guidelines(agent)
        
        # Business logic guidelines
        await setup_business_guidelines(agent)
        
        # Monitoring setup
        await setup_monitoring(agent)
        
        return agent

async def setup_security_guidelines(agent):
    """Configure security-related guidelines"""
    
    # PII protection
    await agent.create_guideline(
        condition="User shares personal information like SSN or credit card",
        action="Immediately warn about not sharing sensitive data and clear the information",
        tools=[clear_sensitive_data]
    )
    
    # Permission verification
    await agent.create_guideline(
        condition="User requests account modifications",
        action="Verify identity through multi-factor authentication",
        tools=[verify_mfa]
    )
```

### 2. Monitoring and Analytics System

```python
async def setup_monitoring(agent):
    """Configure conversation analytics and monitoring"""
    
    # Performance metric collection
    await agent.create_guideline(
        condition="Conversation ends",
        action="Log satisfaction score and resolution status",
        tools=[log_conversation_metrics]
    )
    
    # Error tracking
    await agent.create_guideline(
        condition="Tool execution fails",
        action="Log error details and provide fallback response",
        tools=[log_error, provide_fallback]
    )

@p.tool
async def log_conversation_metrics(context: p.ToolContext, 
                                 satisfaction_score: int,
                                 resolution_status: str) -> p.ToolResult:
    """Log conversation metrics"""
    
    metrics = {
        "timestamp": datetime.now().isoformat(),
        "agent_id": context.agent_id,
        "session_id": context.session_id,
        "satisfaction_score": satisfaction_score,
        "resolution_status": resolution_status,
        "turn_count": len(context.conversation_history)
    }
    
    # Save metrics (e.g., DataDog, CloudWatch)
    await save_metrics(metrics)
    
    return p.ToolResult("Metrics logged successfully")
```

### 3. Scaling and Load Management

```python
# Multi-agent setup
async def setup_multi_agent_system():
    """Multi-agent system for load distribution"""
    
    agents = {}
    
    # Agents by specialty
    agents['sales'] = await create_sales_agent()
    agents['support'] = await create_support_agent() 
    agents['technical'] = await create_technical_agent()
    
    # Routing agent
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
    """Transfer to sales agent"""
    
    # Transfer while preserving context
    transfer_data = {
        "conversation_history": context.conversation_history,
        "user_context": context.user_data,
        "transfer_reason": "sales_inquiry"
    }
    
    await initiate_agent_transfer("sales", transfer_data)
    
    return p.ToolResult("Transferring to sales specialist...")
```

## Production Tool Integration Patterns

### 1. Database Integration

```python
@p.tool
async def check_order_status(context: p.ToolContext, 
                           order_id: str) -> p.ToolResult:
    """Tool to check order status"""
    
    try:
        # Database query
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
        # Error handling and logging
        await log_tool_error("check_order_status", str(e), context)
        return p.ToolResult("Unable to check order status. Please try again.", 
                          error=True)

@p.tool
async def update_customer_profile(context: p.ToolContext,
                                customer_id: str,
                                updates: dict) -> p.ToolResult:
    """Update customer profile"""
    
    # Permission check
    if not await verify_agent_permissions(context, "customer_update"):
        return p.ToolResult("Insufficient permissions", error=True)
    
    try:
        async with get_db_connection() as conn:
            # Safe update (whitelist-based)
            allowed_fields = ['phone', 'email', 'preferences']
            filtered_updates = {k: v for k, v in updates.items() 
                             if k in allowed_fields}
            
            if not filtered_updates:
                return p.ToolResult("No valid fields to update", error=True)
                
            # Execute update
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

### 2. External API Integration

```python
@p.tool
async def get_shipping_info(context: p.ToolContext, 
                          tracking_number: str) -> p.ToolResult:
    """Retrieve shipping information"""
    
    try:
        # Call external shipping carrier API
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
                
        # Normalize response
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

### 3. Real-Time Integration

```python
@p.tool
async def check_live_inventory(context: p.ToolContext, 
                              product_id: str) -> p.ToolResult:
    """Check real-time inventory"""
    
    try:
        # Query real-time inventory from Redis
        redis_client = await get_redis_connection()
        inventory_key = f"inventory:{product_id}"
        
        current_stock = await redis_client.get(inventory_key)
        
        if current_stock is None:
            # On cache miss, query database and cache result
            async with get_db_connection() as conn:
                result = await conn.fetchval(
                    "SELECT quantity FROM inventory WHERE product_id = $1",
                    product_id
                )
                
            if result is None:
                return p.ToolResult("Product not found", error=True)
                
            current_stock = result
            # Cache for 5 minutes
            await redis_client.setex(inventory_key, 300, current_stock)
        else:
            current_stock = int(current_stock)
            
        # Determine stock status
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

## Advanced LLMOps Operational Patterns

### 1. A/B Testing and Gradual Rollout

```python
async def setup_ab_testing():
    """Agent configuration for A/B testing"""
    
    # Baseline agent (current version)
    baseline_agent = await server.create_agent(
        name="BaselineAgent",
        description="Current production agent"
    )
    
    # Experiment agent (new version)
    experiment_agent = await server.create_agent(
        name="ExperimentAgent", 
        description="New agent with improved guidelines"
    )
    
    # Add more detailed guidelines
    await experiment_agent.create_guideline(
        condition="Customer mentions competitor pricing",
        action="Acknowledge their research and highlight our unique value propositions",
        tools=[get_value_propositions, get_competitive_analysis]
    )
    
    return baseline_agent, experiment_agent

@p.tool
async def route_to_agent_variant(context: p.ToolContext, 
                               user_id: str) -> p.ToolResult:
    """Route user to an A/B test group"""
    
    # Consistent group assignment using user ID hashing
    import hashlib
    hash_value = int(hashlib.md5(user_id.encode()).hexdigest(), 16)
    
    # 50/50 split
    if hash_value % 2 == 0:
        variant = "baseline"
    else:
        variant = "experiment"
    
    # Log experiment data
    await log_ab_test_assignment(user_id, variant)
    
    return p.ToolResult(f"Assigned to {variant} group", 
                       data={"variant": variant})
```

### 2. Performance Optimization and Caching

```python
from functools import lru_cache
import asyncio

class ToolCache:
    """Tool execution result caching system"""
    
    def __init__(self):
        self._cache = {}
        self._cache_expiry = {}
    
    async def get_or_compute(self, key: str, compute_func, ttl: int = 300):
        """Retrieve from cache or compute and cache the result"""
        
        now = asyncio.get_event_loop().time()
        
        # Check cache hit
        if key in self._cache and self._cache_expiry.get(key, 0) > now:
            return self._cache[key]
        
        # Compute on cache miss
        result = await compute_func()
        
        # Cache result
        self._cache[key] = result
        self._cache_expiry[key] = now + ttl
        
        return result

tool_cache = ToolCache()

@p.tool
async def get_product_recommendations(context: p.ToolContext,
                                    customer_id: str) -> p.ToolResult:
    """Personalized product recommendations (with caching)"""
    
    cache_key = f"recommendations:{customer_id}"
    
    async def compute_recommendations():
        # Heavy ML inference work
        async with get_ml_service() as ml:
            recommendations = await ml.get_recommendations(customer_id)
        return recommendations
    
    try:
        # Cache for 10 minutes
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

### 3. Error Recovery and Fault Tolerance

```python
@p.tool
async def resilient_payment_processing(context: p.ToolContext,
                                     payment_data: dict) -> p.ToolResult:
    """Resilient payment processing"""
    
    # Attempt primary payment gateways in order
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
            
            # If the last gateway also fails
            if gateway == "tertiary":
                # Add to async retry queue
                await enqueue_payment_retry(payment_data)
                
                return p.ToolResult(
                    "Payment processing encountered an issue. Please try again shortly.",
                    error=True
                )
            
            # Continue to next gateway
            continue
    
    return p.ToolResult("All payment systems temporarily unavailable", 
                      error=True)

async def setup_circuit_breaker():
    """Implement circuit breaker pattern"""
    
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

## Security and Compliance

### 1. Data Protection and Privacy

```python
import hashlib
from cryptography.fernet import Fernet

class DataProtection:
    """Data protection utilities"""
    
    def __init__(self):
        self.encryption_key = os.getenv('ENCRYPTION_KEY').encode()
        self.fernet = Fernet(self.encryption_key)
    
    def mask_pii(self, text: str) -> str:
        """Mask PII data"""
        import re
        
        # Mask email addresses
        text = re.sub(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b', 
                     '***@***.***', text)
        
        # Mask phone numbers
        text = re.sub(r'\b\d{3}-\d{4}-\d{4}\b', '***-****-****', text)
        
        # Mask credit card numbers
        text = re.sub(r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b', 
                     '****-****-****-****', text)
        
        return text
    
    def encrypt_sensitive_data(self, data: str) -> str:
        """Encrypt sensitive data"""
        return self.fernet.encrypt(data.encode()).decode()
    
    def decrypt_sensitive_data(self, encrypted_data: str) -> str:
        """Decrypt sensitive data"""
        return self.fernet.decrypt(encrypted_data.encode()).decode()

data_protection = DataProtection()

@p.tool
async def log_conversation_securely(context: p.ToolContext,
                                  conversation_data: dict) -> p.ToolResult:
    """Secure logging"""
    
    # Mask PII
    masked_data = data_protection.mask_pii(str(conversation_data))
    
    # Save audit log
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

### 2. Role Management and Access Control

```python
class RoleBasedAccessControl:
    """Role-based access control"""
    
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
        """Check permission"""
        return action in self.permissions.get(agent_role, [])

rbac = RoleBasedAccessControl()

@p.tool
async def apply_discount(context: p.ToolContext,
                        order_id: str,
                        discount_percent: float) -> p.ToolResult:
    """Apply discount (with permission check)"""
    
    # Permission check
    agent_role = context.user_data.get("role", "customer_service")
    
    if not await rbac.check_permission(agent_role, "apply_discount"):
        return p.ToolResult("Insufficient permissions to apply discount", error=True)
    
    # Check discount limit
    max_discount = 30 if agent_role == "manager" else 10
    
    if discount_percent > max_discount:
        return p.ToolResult(
            f"Discount exceeds maximum allowed ({max_discount}%) for your role",
            error=True
        )
    
    try:
        # Discount application logic
        result = await apply_order_discount(order_id, discount_percent)
        
        # Audit log
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

## Performance Monitoring and Analytics

### 1. Metrics Collection System

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

### 2. Real-Time Dashboard Implementation

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

## Conclusion: The Future of Reliable LLMOps

Parlant solves the fundamental problems of LLMOps through a paradigm shift from **"hoping" to "guaranteeing"**:

### Core Value

1. **Predictability**: Consistent agent behavior guaranteed through guideline-based control
2. **Scalability**: Enterprise-grade features and multi-agent system support
3. **Observability**: Full explainability and real-time monitoring
4. **Stability**: Robust error handling and fault recovery mechanisms
5. **Security**: Built-in data protection and access control systems

### Getting Started

```bash
# Install Parlant
pip install parlant

# Build a production-grade agent in 60 seconds
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

### Business Impact

- **Improved customer satisfaction**: Enhanced user experience through consistent service quality
- **Reduced operational costs**: Lower labor costs through automated customer service
- **Risk management**: Automatic compliance with regulations and security standards
- **Scalability**: Flexible scaling as the business grows

With Parlant, you no longer need to rely on unpredictable AI behavior.

### Additional Resources

- [Parlant Official Website](https://www.parlant.io)
- [Complete Documentation](https://www.parlant.io/docs)
- [Discord Community](https://discord.gg/duxWqxKk6J)
- [GitHub Repository](https://github.com/emcie-co/parlant)
- [Practical Examples](https://www.parlant.io/docs/quickstart/examples)

---

💡 Feel free to reach out anytime on [Thaki Cloud Discord](https://discord.gg/thakicloud)!
