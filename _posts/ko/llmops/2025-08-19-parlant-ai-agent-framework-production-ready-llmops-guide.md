---
title: "Parlant AI 에이전트 프레임워크: 프로덕션 환경 LLMOps 완벽 가이드"
excerpt: "지시사항을 100% 준수하는 AI 에이전트 구축. Parlant의 가이드라인 기반 제어 시스템으로 예측 가능하고 신뢰할 수 있는 LLM 애플리케이션을 운영하는 방법"
seo_title: "Parlant AI 에이전트 프레임워크 LLMOps 완벽 가이드 - Thaki Cloud"
seo_description: "Parlant를 활용해 프로덕션 환경에서 안정적인 AI 에이전트를 구축하고 운영하는 LLMOps 가이드. 가이드라인 기반 제어, 대화형 여정, 엔터프라이즈급 기능 구현 방법"
date: 2025-08-19
last_modified_at: 2025-08-19
categories:
  - llmops
tags:
  - parlant
  - ai-agents
  - llm-framework
  - production-ai
  - guideline-control
  - conversation-analytics
  - agent-reliability
  - enterprise-ai
  - emcie
author_profile: true
toc: true
toc_label: "Parlant LLMOps 가이드"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/llmops/parlant-ai-agent-framework-production-ready-llmops-guide/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 15분

## 서론: LLM 에이전트의 근본적 문제

AI 에이전트를 개발해본 경험이 있다면 이런 상황을 겪어봤을 것입니다:

- ✅ 테스트 환경에서는 완벽하게 작동
- ❌ 실제 사용자와의 대화에서 시스템 프롬프트 무시
- ❌ 중요한 순간에 할루시네이션 발생
- ❌ 예외 상황에서 일관성 없는 응답
- ❌ 매번 다른 결과로 예측 불가능한 동작

이것이 바로 **LLMOps의 핵심 과제**입니다. [Parlant](https://github.com/emcie-co/parlant)는 이 문제에 대한 혁신적인 해결책을 제시합니다.

> 🌟 **Parlant 핵심 가치 제안**: "지시사항을 희망하는 대신 보장하는" AI 에이전트 프레임워크

## Parlant가 해결하는 LLMOps 핵심 문제들

### 1. 시스템 프롬프트 의존성 탈피

**기존 방식의 한계:**
```python
# 전통적인 방식: 47개 규칙을 담은 시스템 프롬프트에 의존
system_prompt = """
You are a helpful assistant. Please follow these rules:
1. Always check user authentication
2. Never reveal sensitive information
3. Respond in Korean
... (44 more rules)
"""
```

**Parlant의 해결책:**
```python
# 가이드라인 기반 보장된 제어
await agent.create_guideline(
    condition="Customer asks about refunds", 
    action="Check order status first to see if eligible",
    tools=[check_order_status],
)
```

### 2. 예측 불가능한 동작을 일관성 있는 규칙으로 변환

| 기존 LLM 에이전트 | Parlant 에이전트 |
|---|---|
| 복잡한 시스템 프롬프트 | 자연어 가이드라인 |
| LLM이 규칙을 따르길 희망 | **보장된** 규칙 준수 |
| 예측 불가능한 동작 | 일관되고 예측 가능한 응답 |
| 디버깅 어려움 | 완전한 설명 가능성 |
| 수동 프롬프트 엔지니어링 | 반복적 개선을 통한 자동화 |

## Parlant 핵심 아키텍처 이해

### 1. 가이드라인 기반 제어 시스템

Parlant의 핵심은 **조건부 가이드라인 시스템**입니다:

```python
import parlant.sdk as p

async def setup_customer_service_agent():
    agent = await server.create_agent(
        name="CustomerServiceBot",
        description="Enterprise customer service agent"
    )
    
    # 인증 관련 가이드라인
    await agent.create_guideline(
        condition="User mentions account issues",
        action="First verify identity using security questions",
        tools=[verify_identity]
    )
    
    # 환불 정책 가이드라인  
    await agent.create_guideline(
        condition="Customer requests refund",
        action="Check order date and return policy eligibility first",
        tools=[check_order_status, verify_return_policy]
    )
    
    # 에스컬레이션 가이드라인
    await agent.create_guideline(
        condition="Customer expresses frustration or asks for manager",
        action="Acknowledge feelings and transfer to human agent",
        tools=[transfer_to_human]
    )
```

### 2. 컨버세이셔널 여정(Conversational Journeys)

사용자를 목표까지 단계별로 안내하는 시스템:

```python
# 대출 신청 여정 예시
async def setup_loan_application_journey():
    # 1단계: 초기 자격 확인
    await agent.create_guideline(
        condition="User inquires about loan",
        action="Collect basic eligibility information: income, employment, credit score range",
        tools=[collect_basic_info]
    )
    
    # 2단계: 문서 준비 안내
    await agent.create_guideline(
        condition="User qualifies for pre-approval",
        action="Guide through required documents: pay stubs, tax returns, bank statements",
        tools=[document_checklist]
    )
    
    # 3단계: 신청서 작성 지원
    await agent.create_guideline(
        condition="All documents ready",
        action="Assist with application form completion and submission",
        tools=[application_form_helper]
    )
```

### 3. 동적 가이드라인 매칭

컨텍스트에 따라 적절한 가이드라인을 자동 선택:

```python
# 컨텍스트 인식 가이드라인
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

## 프로덕션 환경 LLMOps 구현

### 1. 엔터프라이즈급 설정

```python
import parlant.sdk as p
import os
from datetime import datetime

async def production_setup():
    # 프로덕션 서버 설정
    async with p.Server(
        host="0.0.0.0",
        port=8800,
        cors_allowed_origins=["https://yourapp.com"],
        log_level="INFO"
    ) as server:
        
        # 에이전트 생성
        agent = await server.create_agent(
            name="ProductionAgent",
            description="Production-ready customer service agent",
            model="gpt-4o-mini",  # 또는 claude-3-5-sonnet-20241022
        )
        
        # 보안 가이드라인
        await setup_security_guidelines(agent)
        
        # 비즈니스 로직 가이드라인  
        await setup_business_guidelines(agent)
        
        # 모니터링 설정
        await setup_monitoring(agent)
        
        return agent

async def setup_security_guidelines(agent):
    """보안 관련 가이드라인 설정"""
    
    # PII 보호
    await agent.create_guideline(
        condition="User shares personal information like SSN or credit card",
        action="Immediately warn about not sharing sensitive data and clear the information",
        tools=[clear_sensitive_data]
    )
    
    # 권한 확인
    await agent.create_guideline(
        condition="User requests account modifications",
        action="Verify identity through multi-factor authentication",
        tools=[verify_mfa]
    )
```

### 2. 모니터링 및 분석 시스템

```python
async def setup_monitoring(agent):
    """대화 분석 및 모니터링 설정"""
    
    # 성능 메트릭 수집
    await agent.create_guideline(
        condition="Conversation ends",
        action="Log satisfaction score and resolution status",
        tools=[log_conversation_metrics]
    )
    
    # 에러 추적  
    await agent.create_guideline(
        condition="Tool execution fails",
        action="Log error details and provide fallback response",
        tools=[log_error, provide_fallback]
    )

@p.tool
async def log_conversation_metrics(context: p.ToolContext, 
                                 satisfaction_score: int,
                                 resolution_status: str) -> p.ToolResult:
    """대화 메트릭 로깅"""
    
    metrics = {
        "timestamp": datetime.now().isoformat(),
        "agent_id": context.agent_id,
        "session_id": context.session_id,
        "satisfaction_score": satisfaction_score,
        "resolution_status": resolution_status,
        "turn_count": len(context.conversation_history)
    }
    
    # 메트릭 저장 (예: DataDog, CloudWatch)
    await save_metrics(metrics)
    
    return p.ToolResult("Metrics logged successfully")
```

### 3. 스케일링과 부하 관리

```python
# 멀티 에이전트 설정
async def setup_multi_agent_system():
    """부하 분산을 위한 멀티 에이전트 시스템"""
    
    agents = {}
    
    # 전문 영역별 에이전트
    agents['sales'] = await create_sales_agent()
    agents['support'] = await create_support_agent() 
    agents['technical'] = await create_technical_agent()
    
    # 라우팅 에이전트
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
    """판매 에이전트로 전환"""
    
    # 컨텍스트 보존하며 전환
    transfer_data = {
        "conversation_history": context.conversation_history,
        "user_context": context.user_data,
        "transfer_reason": "sales_inquiry"
    }
    
    await initiate_agent_transfer("sales", transfer_data)
    
    return p.ToolResult("Transferring to sales specialist...")
```

## 실전 도구 통합 패턴

### 1. 데이터베이스 연동

```python
@p.tool
async def check_order_status(context: p.ToolContext, 
                           order_id: str) -> p.ToolResult:
    """주문 상태 확인 도구"""
    
    try:
        # 데이터베이스 쿼리
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
        # 에러 처리 및 로깅
        await log_tool_error("check_order_status", str(e), context)
        return p.ToolResult("Unable to check order status. Please try again.", 
                          error=True)

@p.tool
async def update_customer_profile(context: p.ToolContext,
                                customer_id: str,
                                updates: dict) -> p.ToolResult:
    """고객 프로필 업데이트"""
    
    # 권한 확인
    if not await verify_agent_permissions(context, "customer_update"):
        return p.ToolResult("Insufficient permissions", error=True)
    
    try:
        async with get_db_connection() as conn:
            # 안전한 업데이트 (화이트리스트 기반)
            allowed_fields = ['phone', 'email', 'preferences']
            filtered_updates = {k: v for k, v in updates.items() 
                             if k in allowed_fields}
            
            if not filtered_updates:
                return p.ToolResult("No valid fields to update", error=True)
                
            # 업데이트 실행
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

### 2. 외부 API 통합

```python
@p.tool
async def get_shipping_info(context: p.ToolContext, 
                          tracking_number: str) -> p.ToolResult:
    """배송 정보 조회"""
    
    try:
        # 외부 배송업체 API 호출
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
                
        # 응답 정규화
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

### 3. 실시간 통합

```python
@p.tool
async def check_live_inventory(context: p.ToolContext, 
                              product_id: str) -> p.ToolResult:
    """실시간 재고 확인"""
    
    try:
        # Redis에서 실시간 재고 조회
        redis_client = await get_redis_connection()
        inventory_key = f"inventory:{product_id}"
        
        current_stock = await redis_client.get(inventory_key)
        
        if current_stock is None:
            # 캐시 미스 시 데이터베이스에서 조회 후 캐싱
            async with get_db_connection() as conn:
                result = await conn.fetchval(
                    "SELECT quantity FROM inventory WHERE product_id = $1",
                    product_id
                )
                
            if result is None:
                return p.ToolResult("Product not found", error=True)
                
            current_stock = result
            # 5분간 캐싱
            await redis_client.setex(inventory_key, 300, current_stock)
        else:
            current_stock = int(current_stock)
            
        # 재고 상태 판단
        if current_stock == 0:
            status = "품절"
        elif current_stock < 10:
            status = "재고 부족"
        else:
            status = "재고 충분"
            
        return p.ToolResult(
            f"현재 재고: {current_stock}개 ({status})",
            data={"product_id": product_id, "quantity": current_stock, "status": status}
        )
        
    except Exception as e:
        await log_tool_error("check_live_inventory", str(e), context)
        return p.ToolResult("재고 확인 중 오류가 발생했습니다", error=True)
```

## 고급 LLMOps 운영 패턴

### 1. A/B 테스트 및 점진적 배포

```python
async def setup_ab_testing():
    """A/B 테스트를 위한 에이전트 설정"""
    
    # 베이스라인 에이전트 (기존 버전)
    baseline_agent = await server.create_agent(
        name="BaselineAgent",
        description="Current production agent"
    )
    
    # 실험 에이전트 (새 버전)  
    experiment_agent = await server.create_agent(
        name="ExperimentAgent", 
        description="New agent with improved guidelines"
    )
    
    # 더 자세한 가이드라인 추가
    await experiment_agent.create_guideline(
        condition="Customer mentions competitor pricing",
        action="Acknowledge their research and highlight our unique value propositions",
        tools=[get_value_propositions, get_competitive_analysis]
    )
    
    return baseline_agent, experiment_agent

@p.tool
async def route_to_agent_variant(context: p.ToolContext, 
                               user_id: str) -> p.ToolResult:
    """사용자를 A/B 테스트 그룹에 따라 라우팅"""
    
    # 사용자 ID 기반 해싱으로 일관된 그룹 배정
    import hashlib
    hash_value = int(hashlib.md5(user_id.encode()).hexdigest(), 16)
    
    # 50/50 split
    if hash_value % 2 == 0:
        variant = "baseline"
    else:
        variant = "experiment"
    
    # 실험 데이터 로깅
    await log_ab_test_assignment(user_id, variant)
    
    return p.ToolResult(f"Assigned to {variant} group", 
                       data={"variant": variant})
```

### 2. 성능 최적화 및 캐싱

```python
from functools import lru_cache
import asyncio

class ToolCache:
    """도구 실행 결과 캐싱 시스템"""
    
    def __init__(self):
        self._cache = {}
        self._cache_expiry = {}
    
    async def get_or_compute(self, key: str, compute_func, ttl: int = 300):
        """캐시에서 조회하거나 계산 후 캐싱"""
        
        now = asyncio.get_event_loop().time()
        
        # 캐시 히트 확인
        if key in self._cache and self._cache_expiry.get(key, 0) > now:
            return self._cache[key]
        
        # 캐시 미스 시 계산
        result = await compute_func()
        
        # 캐싱
        self._cache[key] = result
        self._cache_expiry[key] = now + ttl
        
        return result

tool_cache = ToolCache()

@p.tool
async def get_product_recommendations(context: p.ToolContext,
                                    customer_id: str) -> p.ToolResult:
    """개인화된 상품 추천 (캐싱 적용)"""
    
    cache_key = f"recommendations:{customer_id}"
    
    async def compute_recommendations():
        # 무거운 ML 추론 작업
        async with get_ml_service() as ml:
            recommendations = await ml.get_recommendations(customer_id)
        return recommendations
    
    try:
        # 10분간 캐싱
        recommendations = await tool_cache.get_or_compute(
            cache_key, compute_recommendations, ttl=600
        )
        
        return p.ToolResult(
            f"추천 상품 {len(recommendations)}개를 찾았습니다",
            data={"recommendations": recommendations}
        )
        
    except Exception as e:
        await log_tool_error("get_product_recommendations", str(e), context)
        return p.ToolResult("추천 시스템이 일시적으로 사용할 수 없습니다", error=True)
```

### 3. 오류 복구 및 장애 대응

```python
@p.tool
async def resilient_payment_processing(context: p.ToolContext,
                                     payment_data: dict) -> p.ToolResult:
    """복원력 있는 결제 처리"""
    
    # 주 결제 게이트웨이 시도
    for gateway in ["primary", "secondary", "tertiary"]:
        try:
            result = await process_payment_with_gateway(gateway, payment_data)
            
            if result.success:
                await log_payment_success(gateway, payment_data)
                return p.ToolResult(
                    f"결제가 완료되었습니다. 확인번호: {result.transaction_id}",
                    data={"transaction_id": result.transaction_id}
                )
                
        except Exception as e:
            await log_payment_failure(gateway, str(e), payment_data)
            
            # 마지막 게이트웨이도 실패한 경우
            if gateway == "tertiary":
                # 비동기 재시도 큐에 추가
                await enqueue_payment_retry(payment_data)
                
                return p.ToolResult(
                    "결제 처리 중 문제가 발생했습니다. 잠시 후 다시 시도해주세요.",
                    error=True
                )
            
            # 다음 게이트웨이로 계속
            continue
    
    return p.ToolResult("모든 결제 시스템이 일시적으로 사용할 수 없습니다", 
                      error=True)

async def setup_circuit_breaker():
    """회로 차단기 패턴 구현"""
    
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

## 보안 및 컴플라이언스

### 1. 데이터 보호 및 프라이버시

```python
import hashlib
from cryptography.fernet import Fernet

class DataProtection:
    """데이터 보호 유틸리티"""
    
    def __init__(self):
        self.encryption_key = os.getenv('ENCRYPTION_KEY').encode()
        self.fernet = Fernet(self.encryption_key)
    
    def mask_pii(self, text: str) -> str:
        """PII 마스킹"""
        import re
        
        # 이메일 마스킹
        text = re.sub(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b', 
                     '***@***.***', text)
        
        # 전화번호 마스킹  
        text = re.sub(r'\b\d{3}-\d{4}-\d{4}\b', '***-****-****', text)
        
        # 신용카드 번호 마스킹
        text = re.sub(r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b', 
                     '****-****-****-****', text)
        
        return text
    
    def encrypt_sensitive_data(self, data: str) -> str:
        """민감 데이터 암호화"""
        return self.fernet.encrypt(data.encode()).decode()
    
    def decrypt_sensitive_data(self, encrypted_data: str) -> str:
        """민감 데이터 복호화"""
        return self.fernet.decrypt(encrypted_data.encode()).decode()

data_protection = DataProtection()

@p.tool
async def log_conversation_securely(context: p.ToolContext,
                                  conversation_data: dict) -> p.ToolResult:
    """보안 로깅"""
    
    # PII 마스킹
    masked_data = data_protection.mask_pii(str(conversation_data))
    
    # 감사 로그 저장
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

### 2. 권한 관리 및 접근 제어

```python
class RoleBasedAccessControl:
    """역할 기반 접근 제어"""
    
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
        """권한 확인"""
        return action in self.permissions.get(agent_role, [])

rbac = RoleBasedAccessControl()

@p.tool
async def apply_discount(context: p.ToolContext,
                        order_id: str,
                        discount_percent: float) -> p.ToolResult:
    """할인 적용 (권한 확인 포함)"""
    
    # 권한 확인
    agent_role = context.user_data.get("role", "customer_service")
    
    if not await rbac.check_permission(agent_role, "apply_discount"):
        return p.ToolResult("Insufficient permissions to apply discount", error=True)
    
    # 할인 한도 확인
    max_discount = 30 if agent_role == "manager" else 10
    
    if discount_percent > max_discount:
        return p.ToolResult(
            f"Discount exceeds maximum allowed ({max_discount}%) for your role",
            error=True
        )
    
    try:
        # 할인 적용 로직
        result = await apply_order_discount(order_id, discount_percent)
        
        # 감사 로그
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

## 성능 모니터링 및 분석

### 1. 메트릭 수집 시스템

```python
import time
from dataclasses import dataclass
from typing import Optional

@dataclass
class ConversationMetrics:
    """대화 메트릭 데이터 클래스"""
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
    """메트릭 수집기"""
    
    def __init__(self):
        self.active_sessions = {}
    
    async def start_session(self, session_id: str, agent_id: str):
        """세션 시작 기록"""
        self.active_sessions[session_id] = ConversationMetrics(
            session_id=session_id,
            agent_id=agent_id,
            start_time=time.time()
        )
    
    async def record_message(self, session_id: str):
        """메시지 수 증가"""
        if session_id in self.active_sessions:
            self.active_sessions[session_id].message_count += 1
    
    async def record_tool_call(self, session_id: str, success: bool = True):
        """도구 호출 기록"""
        if session_id in self.active_sessions:
            metrics = self.active_sessions[session_id]
            metrics.tool_calls += 1
            if not success:
                metrics.errors += 1
    
    async def end_session(self, session_id: str, 
                         satisfaction: Optional[int] = None,
                         resolved: bool = False):
        """세션 종료 및 메트릭 저장"""
        if session_id not in self.active_sessions:
            return
        
        metrics = self.active_sessions[session_id]
        metrics.end_time = time.time()
        metrics.user_satisfaction = satisfaction
        metrics.resolution_achieved = resolved
        
        # 메트릭 저장
        await self.save_metrics(metrics)
        
        # 메모리에서 제거
        del self.active_sessions[session_id]
    
    async def save_metrics(self, metrics: ConversationMetrics):
        """메트릭을 저장소에 저장"""
        
        # 세션 길이 계산
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
        
        # 시계열 데이터베이스에 저장 (예: InfluxDB, CloudWatch)
        await save_to_timeseries_db(metric_data)
        
        # 실시간 대시보드 업데이트
        await update_dashboard(metric_data)

metrics_collector = MetricsCollector()

@p.tool
async def collect_user_feedback(context: p.ToolContext,
                               satisfaction_score: int,
                               feedback_text: str = "") -> p.ToolResult:
    """사용자 피드백 수집"""
    
    # 메트릭 업데이트
    await metrics_collector.record_message(context.session_id)
    
    # 피드백 저장
    feedback_data = {
        "session_id": context.session_id,
        "agent_id": context.agent_id,
        "satisfaction_score": satisfaction_score,
        "feedback_text": feedback_text,
        "timestamp": datetime.now().isoformat()
    }
    
    await save_feedback(feedback_data)
    
    # 낮은 점수의 경우 알림
    if satisfaction_score <= 2:
        await trigger_quality_alert(feedback_data)
    
    return p.ToolResult("Thank you for your feedback!")
```

### 2. 실시간 대시보드 구현

```python
import asyncio
from collections import defaultdict, deque

class RealTimeDashboard:
    """실시간 대시보드 데이터 관리"""
    
    def __init__(self):
        self.active_sessions = 0
        self.hourly_metrics = defaultdict(lambda: {
            "conversations": 0,
            "avg_satisfaction": 0,
            "resolution_rate": 0,
            "avg_duration": 0
        })
        self.recent_errors = deque(maxlen=100)  # 최근 100개 에러만 보관
    
    async def update_active_sessions(self, delta: int):
        """활성 세션 수 업데이트"""
        self.active_sessions += delta
        await self.broadcast_update("active_sessions", self.active_sessions)
    
    async def record_conversation_end(self, metrics: ConversationMetrics):
        """대화 종료 메트릭 업데이트"""
        hour_key = datetime.now().strftime("%Y-%m-%d %H:00")
        hourly = self.hourly_metrics[hour_key]
        
        hourly["conversations"] += 1
        
        if metrics.user_satisfaction:
            # 평균 만족도 업데이트 (이동 평균)
            current_avg = hourly["avg_satisfaction"]
            count = hourly["conversations"]
            new_avg = ((current_avg * (count - 1)) + metrics.user_satisfaction) / count
            hourly["avg_satisfaction"] = new_avg
        
        if metrics.resolution_achieved:
            # 해결률 업데이트
            resolution_count = hourly.get("resolutions", 0) + 1
            hourly["resolutions"] = resolution_count
            hourly["resolution_rate"] = resolution_count / hourly["conversations"]
        
        # 평균 대화 시간 업데이트
        duration = metrics.end_time - metrics.start_time
        current_avg_duration = hourly["avg_duration"]
        new_avg_duration = ((current_avg_duration * (count - 1)) + duration) / count
        hourly["avg_duration"] = new_avg_duration
        
        await self.broadcast_update("hourly_metrics", dict(self.hourly_metrics))
    
    async def record_error(self, error_data: dict):
        """에러 기록"""
        self.recent_errors.append(error_data)
        await self.broadcast_update("recent_errors", list(self.recent_errors))
    
    async def broadcast_update(self, metric_type: str, data):
        """WebSocket을 통해 대시보드 업데이트 브로드캐스트"""
        message = {
            "type": metric_type,
            "data": data,
            "timestamp": datetime.now().isoformat()
        }
        
        # WebSocket 클라이언트들에게 브로드캐스트
        await websocket_broadcast(message)

dashboard = RealTimeDashboard()

# WebSocket 핸들러 예시
async def websocket_handler(websocket, path):
    """대시보드 WebSocket 핸들러"""
    
    try:
        # 초기 데이터 전송
        await websocket.send(json.dumps({
            "type": "initial_data",
            "data": {
                "active_sessions": dashboard.active_sessions,
                "hourly_metrics": dict(dashboard.hourly_metrics),
                "recent_errors": list(dashboard.recent_errors)
            }
        }))
        
        # 연결 유지
        await websocket.wait_closed()
        
    except Exception as e:
        print(f"WebSocket error: {e}")
```

## 결론: 신뢰할 수 있는 LLMOps의 미래

Parlant는 **"희망에서 보장으로"**의 패러다임 전환을 통해 LLMOps의 근본적 문제를 해결합니다:

### 🎯 핵심 가치 

1. **예측 가능성**: 가이드라인 기반 제어로 일관된 에이전트 동작 보장
2. **확장성**: 엔터프라이즈급 기능과 멀티 에이전트 시스템 지원  
3. **관찰 가능성**: 완전한 설명 가능성과 실시간 모니터링
4. **안정성**: 견고한 오류 처리와 장애 복구 메커니즘
5. **보안**: 내장된 데이터 보호와 접근 제어 시스템

### 🚀 시작하기

```bash
# Parlant 설치
pip install parlant

# 60초 만에 프로덕션급 에이전트 구축
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
        print('🎉 Agent ready at http://localhost:8800')
        await asyncio.sleep(3600)  # 1시간 동안 실행

asyncio.run(main())
"
```

### 📈 비즈니스 임팩트

- **고객 만족도 향상**: 일관된 서비스 품질로 사용자 경험 개선
- **운영 비용 절감**: 자동화된 고객 서비스로 인건비 절약  
- **위험 관리**: 규정 준수와 보안 기준 자동 충족
- **확장성**: 비즈니스 성장에 따른 유연한 확장

**Parlant로 LLM 에이전트의 새로운 표준을 경험해보세요.** 더 이상 불확실한 AI 동작에 의존할 필요가 없습니다.

### 추가 리소스

- 🌐 [Parlant 공식 웹사이트](https://www.parlant.io)
- 📚 [완전한 문서](https://www.parlant.io/docs)
- 💬 [Discord 커뮤니티](https://discord.gg/duxWqxKk6J)
- 🔧 [GitHub 레포지토리](https://github.com/emcie-co/parlant)
- 📖 [실전 예제 모음](https://www.parlant.io/docs/quickstart/examples)

---

💡 **궁금한 점이 있으시면** [Thaki Cloud Discord](https://discord.gg/thakicloud)에서 언제든 문의하세요!
