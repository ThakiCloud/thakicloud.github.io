---
title: "Google Agent Development Kit (ADK) 완전 가이드: 차세대 AI 에이전트 개발하기"
date: 2025-06-09
categories: 
  - tutorials
  - ai
tags: 
  - google-adk
  - ai-agents
  - python
  - vertex-ai
  - gemini
  - automation
author_profile: true
toc: true
toc_label: "목차"
---

Google의 Agent Development Kit (ADK)는 2025년 4월에 발표된 오픈소스 AI 에이전트 개발 프레임워크입니다. Vertex AI와 완벽하게 통합되어 누구나 강력한 AI 에이전트와 멀티 에이전트 시스템을 쉽게 구축할 수 있게 되었습니다. 이 가이드에서는 기초부터 실제 엔터프라이즈 애플리케이션 구축까지 모든 과정을 상세히 다뤄보겠습니다.

## Google ADK란?

Google Agent Development Kit (ADK)는 Gemini 모델을 활용한 자율적인 AI 에이전트를 구축하기 위한 Python 프레임워크입니다. Google Agentspace와 Customer Engagement Suite (CES) 에이전트를 구동하는 동일한 프레임워크를 기반으로 제작되었습니다.

### ADK의 핵심 특징

1. **100줄 미만의 직관적인 코드**로 강력한 AI 에이전트 구축
2. **오픈소스 접근법**과 엔터프라이즈급 제어 기능의 결합
3. **멀티모달 상호작용**: 양방향 오디오/비디오 스트리밍 지원
4. **Agent Garden**: 즉시 사용 가능한 샘플과 도구 모음
5. **모델 선택의 자유**: Gemini, Anthropic, Meta, Mistral AI 등 200+ 모델 지원

## 설치 및 환경 설정

### 사전 요구사항

```bash
# Python 3.9 이상 필요
python --version

# 가상환경 생성 (권장)
python -m venv .venv
source .venv/bin/activate  # Linux/macOS
# .venv\Scripts\activate  # Windows
```

### ADK 설치

```bash
# ADK 설치
pip install google-adk
```

### Google Cloud 설정

```bash
# Google Cloud CLI 설치 및 인증
gcloud auth application-default login

# 프로젝트 설정
gcloud config set project YOUR_PROJECT_ID

# Vertex AI API 활성화
gcloud services enable aiplatform.googleapis.com
```

### 환경 변수 설정

```bash
# .env 파일 생성
GOOGLE_GENAI_USE_VERTEXAI=TRUE
GOOGLE_CLOUD_PROJECT=your-project-id
GOOGLE_CLOUD_LOCATION=us-central1
GOOGLE_API_KEY=your-api-key  # AI Studio 사용 시
```

## 핵심 구성 요소

### 1. Agent 클래스

ADK에서 에이전트의 핵심이 되는 클래스입니다:

```python
from google.adk.agents import Agent

agent = Agent(
    name="assistant",
    description="도움이 되는 AI 어시스턴트입니다.",
    instruction="당신은 친절하고 도움이 되는 AI 어시스턴트입니다.",
    model="gemini-2.0-flash",
    tools=[]  # 사용 가능한 도구들
)
```

### 2. 기본 도구 함수

에이전트가 외부 시스템과 상호작용할 수 있게 해주는 기능입니다:

```python
def get_weather(city: str) -> dict:
    """특정 도시의 날씨 정보를 가져옵니다.
    
    Args:
        city: 날씨를 확인할 도시명
    
    Returns:
        dict: 날씨 정보가 포함된 딕셔너리
    """
    if city.lower() == "seoul":
        return {
            "status": "success",
            "report": f"{city}의 현재 날씨는 맑음, 기온 25도입니다."
        }
    else:
        return {
            "status": "error", 
            "error_message": f"'{city}'의 날씨 정보를 찾을 수 없습니다."
        }
```

### 3. ADK 실행

```python
# 터미널에서 직접 실행
adk run your_agent_directory

# 웹 UI로 실행
adk web
```

## 기본 에이전트 구축하기

### 1. 프로젝트 구조 생성

```bash
mkdir weather_agent/
touch weather_agent/__init__.py \
      weather_agent/agent.py \
      weather_agent/.env
```

### 2. 단순한 날씨 에이전트

```python
# weather_agent/__init__.py
from . import agent

# weather_agent/agent.py
from google.adk.agents import Agent

def get_weather(city: str) -> dict:
    """특정 도시의 날씨 정보를 반환합니다."""
    weather_data = {
        "seoul": "맑음, 25°C",
        "busan": "흐림, 22°C", 
        "jeju": "비, 20°C"
    }
    
    city_lower = city.lower()
    if city_lower in weather_data:
        return {
            "status": "success",
            "report": f"{city}의 날씨: {weather_data[city_lower]}"
        }
    else:
        return {
            "status": "error",
            "error_message": f"{city}의 날씨 정보가 없습니다."
        }

def get_current_time(city: str) -> dict:
    """특정 도시의 현재 시간을 반환합니다."""
    import datetime
    from zoneinfo import ZoneInfo
    
    timezone_map = {
        "seoul": "Asia/Seoul",
        "tokyo": "Asia/Tokyo",
        "new york": "America/New_York"
    }
    
    city_lower = city.lower()
    if city_lower in timezone_map:
        tz = ZoneInfo(timezone_map[city_lower])
        now = datetime.datetime.now(tz)
        return {
            "status": "success",
            "report": f"{city}의 현재 시간: {now.strftime('%Y-%m-%d %H:%M:%S %Z')}"
        }
    else:
        return {
            "status": "error",
            "error_message": f"{city}의 시간대 정보가 없습니다."
        }

# 루트 에이전트 생성
root_agent = Agent(
    name="weather_time_agent",
    model="gemini-2.0-flash",
    description="날씨와 시간을 알려주는 에이전트",
    instruction="사용자의 날씨와 시간 관련 질문에 도움이 되는 답변을 제공합니다.",
    tools=[get_weather, get_current_time]
)
```

### 3. 에이전트 실행 및 테스트

```bash
# 에이전트 디렉토리로 이동
cd weather_agent

# 명령줄에서 실행
adk run .

# 또는 웹 UI로 실행
adk web
```

## 멀티 에이전트 시스템 구축

### 1. 전문화된 에이전트들

```python
from google.adk.agents import Agent

# 기술 지원 에이전트
technical_support = Agent(
    name="tech_support",
    model="gemini-2.0-flash",
    description="기술적 문제를 해결하는 전문가",
    instruction="""
    당신은 기술 지원 전문가입니다.
    - 시스템 오류 진단 및 해결
    - 소프트웨어 설치 및 설정 지원
    - 하드웨어 문제 해결
    
    항상 단계별로 명확한 해결책을 제시하세요.
    """,
    tools=[diagnose_system, fix_software_issue]
)

# 고객 서비스 에이전트
customer_service = Agent(
    name="customer_service",
    model="gemini-2.0-flash", 
    description="고객 문의를 처리하는 서비스 담당자",
    instruction="""
    당신은 친절한 고객 서비스 담당자입니다.
    - 제품 정보 제공
    - 주문 상태 확인
    - 반품/교환 처리
    
    항상 고객 중심적이고 해결책 지향적으로 응답하세요.
    """,
    tools=[check_order_status, process_return]
)

# 코디네이터 에이전트
coordinator = Agent(
    name="support_coordinator",
    model="gemini-2.5-pro",
    description="고객 문의를 적절한 전문가에게 연결하는 조정자",
    instruction="""
    당신은 고객 지원 조정자입니다.
    고객의 문의 내용을 분석하여 적절한 전문가에게 연결합니다:
    
    - 기술적 문제 → tech_support
    - 주문/배송/반품 문의 → customer_service
    - 복합적 문제는 순차적으로 처리
    
    항상 고객에게 어떤 전문가가 도움을 줄 것인지 설명하세요.
    """,
    handoffs=[technical_support, customer_service]
)
```

### 2. 컨텍스트 관리

```python
from pydantic import BaseModel
from typing import List, Optional

class SupportContext(BaseModel):
    customer_id: str
    issue_type: str
    priority: str = "medium"
    history: List[str] = []
    resolution_status: str = "open"

def add_interaction(ctx, interaction: str) -> str:
    """고객 상호작용을 컨텍스트에 추가합니다."""
    context = ctx.get()
    context.history.append(interaction)
    ctx.set(context)
    return f"상호작용이 기록되었습니다: {interaction}"

def update_priority(ctx, new_priority: str) -> str:
    """문제 우선순위를 업데이트합니다."""
    context = ctx.get()
    old_priority = context.priority
    context.priority = new_priority
    ctx.set(context)
    return f"우선순위가 {old_priority}에서 {new_priority}로 변경되었습니다."

context_aware_agent = Agent(
    name="context_support",
    model="gemini-2.0-flash",
    description="컨텍스트를 관리하는 지원 에이전트",
    instruction="고객 상호작용을 추적하고 우선순위를 관리합니다.",
    tools=[add_interaction, update_priority]
)
```

## 고급 기능 활용하기

### 1. Vertex AI 통합

```python
from google.adk.agents import Agent

# Vertex AI 최적화 에이전트
vertex_agent = Agent(
    name="vertex_optimized",
    model="gemini-2.5-pro-experimental",  # 향상된 추론 능력
    description="Vertex AI 최적화 에이전트",
    instruction="""
    당신은 복잡한 분석과 추론이 필요한 작업을 수행합니다.
    Gemini 2.5 Pro의 향상된 추론 능력을 활용하여:
    
    1. 복잡한 문제를 단계별로 분해
    2. 다각도에서 분석
    3. 논리적 결론 도출
    """,
    tools=[analyze_data, generate_insights]
)
```

### 2. Model Context Protocol (MCP) 통합

```python
# MCP를 통한 외부 데이터 소스 연결
def setup_mcp_agent():
    """MCP를 통해 데이터베이스와 연결된 에이전트를 설정합니다."""
    
    # MCP 서버 설정 (별도 구성 필요)
    agent = Agent(
        name="data_agent",
        model="gemini-2.0-flash",
        description="외부 데이터와 연결된 에이전트",
        instruction="""
        MCP를 통해 연결된 데이터 소스에서 정보를 검색하고 분석합니다.
        항상 최신 데이터를 기반으로 정확한 답변을 제공합니다.
        """,
        tools=[query_database, fetch_api_data]
    )
    
    return agent
```

### 3. Agent Engine 배포

```python
# Agent Engine을 통한 프로덕션 배포
def deploy_to_agent_engine():
    """에이전트를 Vertex AI Agent Engine에 배포합니다."""
    
    # 배포 구성
    deployment_config = {
        "agent_name": "production_agent",
        "model": "gemini-2.0-flash",
        "scaling": "auto",
        "session_management": True,
        "evaluation_enabled": True
    }
    
    # 실제 배포는 Google Cloud Console 또는 CLI를 통해 수행
    print("Agent Engine 배포 설정이 완료되었습니다.")
    print("Google Cloud Console에서 배포를 진행하세요.")
```

## 실제 활용 사례

### 1. 고객 지원 자동화 시스템

```python
class CustomerSupportSystem:
    def __init__(self):
        self.triage_agent = Agent(
            name="triage",
            model="gemini-2.0-flash",
            description="고객 문의 분류 에이전트",
            instruction="""
            고객 문의를 다음 카테고리로 분류합니다:
            - 기술지원: 시스템 오류, 설치 문제
            - 주문문의: 주문 상태, 배송 추적
            - 결제문의: 결제 오류, 환불 요청
            - 일반문의: 제품 정보, 사용법
            """,
            tools=[self._classify_inquiry]
        )
        
        self.resolution_agent = Agent(
            name="resolver",
            model="gemini-2.5-pro",
            description="문제 해결 에이전트", 
            instruction="""
            분류된 문의에 대해 적절한 해결책을 제시합니다.
            필요시 다른 부서나 전문가에게 에스컬레이션합니다.
            """,
            tools=[self._resolve_issue, self._escalate_issue]
        )
    
    def _classify_inquiry(self, inquiry: str) -> dict:
        """문의를 분류합니다."""
        categories = {
            "기술": ["오류", "설치", "작동", "버그"],
            "주문": ["배송", "주문", "추적", "도착"],
            "결제": ["결제", "환불", "카드", "청구"],
            "일반": ["사용", "기능", "방법", "정보"]
        }
        
        for category, keywords in categories.items():
            if any(keyword in inquiry for keyword in keywords):
                return {"category": category, "confidence": 0.8}
        
        return {"category": "일반", "confidence": 0.5}
    
    def _resolve_issue(self, issue: str, category: str) -> str:
        """문제를 해결합니다."""
        solutions = {
            "기술": "기술팀에서 확인 후 해결 방안을 안내드리겠습니다.",
            "주문": "주문 상태를 확인하여 업데이트해드리겠습니다.", 
            "결제": "결제 관련 문제를 확인하고 처리해드리겠습니다.",
            "일반": "요청하신 정보를 제공해드리겠습니다."
        }
        return solutions.get(category, "담당 부서에서 확인 후 답변드리겠습니다.")
    
    def _escalate_issue(self, issue: str, priority: str) -> str:
        """복잡한 문제를 에스컬레이션합니다."""
        return f"우선순위 {priority} 문제로 전문팀에 전달되었습니다."

    async def process_inquiry(self, inquiry: str):
        """고객 문의를 처리합니다."""
        # 1. 문의 분류
        classification = await self.triage_agent.run(inquiry)
        
        # 2. 해결책 제시
        resolution = await self.resolution_agent.run(
            f"분류: {classification}\n문의: {inquiry}"
        )
        
        return {
            "classification": classification,
            "resolution": resolution,
            "timestamp": datetime.now().isoformat()
        }
```

### 2. 콘텐츠 제작 자동화 시스템

```python
class ContentCreationSystem:
    def __init__(self):
        self.research_agent = Agent(
            name="researcher",
            model="gemini-2.0-flash",
            description="콘텐츠 연구 전문가",
            instruction="""
            주제에 대한 심층 리서치를 수행합니다:
            - 최신 트렌드 분석
            - 관련 키워드 발굴  
            - 타겟 오디언스 분석
            - 경쟁사 콘텐츠 분석
            """,
            tools=[self._research_topic, self._analyze_trends]
        )
        
        self.writer_agent = Agent(
            name="writer",
            model="gemini-2.5-pro",
            description="콘텐츠 작성 전문가",
            instruction="""
            연구 결과를 바탕으로 고품질 콘텐츠를 작성합니다:
            - 매력적인 제목과 구조
            - SEO 최적화
            - 읽기 쉬운 문체
            - 실용적인 정보 제공
            """,
            tools=[self._write_content, self._optimize_seo]
        )
        
        self.editor_agent = Agent(
            name="editor",
            model="gemini-2.0-flash",
            description="콘텐츠 편집자",
            instruction="""
            작성된 콘텐츠를 검토하고 개선합니다:
            - 문법 및 맞춤법 검사
            - 논리적 구조 점검
            - 브랜드 톤앤매너 일치성
            - 최종 품질 보증
            """,
            tools=[self._edit_content, self._quality_check]
        )
    
    def _research_topic(self, topic: str) -> dict:
        """주제에 대한 리서치를 수행합니다."""
        return {
            "trends": ["AI 에이전트 증가", "자동화 도구 수요"],
            "keywords": ["AI 에이전트", "자동화", "효율성"],
            "audience": "기술 관심자, 개발자, 비즈니스 리더"
        }
    
    def _analyze_trends(self, topic: str) -> list:
        """최신 트렌드를 분석합니다."""
        return [
            "AI 에이전트 도입 급증",
            "멀티 에이전트 시스템 관심 증가",
            "Google ADK 주목받는 중"
        ]
    
    def _write_content(self, research_data: dict, content_type: str) -> str:
        """리서치 데이터를 바탕으로 콘텐츠를 작성합니다."""
        return "연구 결과를 바탕으로 작성된 고품질 콘텐츠"
    
    def _optimize_seo(self, content: str) -> dict:
        """SEO 최적화를 수행합니다."""
        return {
            "title_optimized": True,
            "keywords_density": "적정",
            "meta_description": "생성됨"
        }
    
    def _edit_content(self, content: str) -> str:
        """콘텐츠를 편집합니다."""
        return "편집 완료된 콘텐츠"
    
    def _quality_check(self, content: str) -> bool:
        """품질을 검사합니다."""
        return True

    async def create_content(self, topic: str, content_type: str):
        """완전한 콘텐츠 제작 파이프라인을 실행합니다."""
        # 1. 리서치
        research = await self.research_agent.run(f"주제 '{topic}' 리서치")
        
        # 2. 작성
        draft = await self.writer_agent.run(
            f"리서치: {research}\n콘텐츠 타입: {content_type}"
        )
        
        # 3. 편집
        final_content = await self.editor_agent.run(f"편집 대상: {draft}")
        
        return {
            "research": research,
            "draft": draft,
            "final_content": final_content,
            "created_at": datetime.now().isoformat()
        }
```

## 모니터링 및 최적화

### 1. 에이전트 성능 모니터링

```python
import logging
from datetime import datetime

class AgentMonitor:
    def __init__(self):
        self.logger = logging.getLogger(__name__)
        logging.basicConfig(level=logging.INFO)
    
    def track_execution(self, agent_name: str, task: str, start_time: datetime):
        """에이전트 실행을 추적합니다."""
        execution_time = (datetime.now() - start_time).total_seconds()
        
        self.logger.info(f"""
        에이전트 실행 완료:
        - 에이전트: {agent_name}
        - 작업: {task}
        - 실행 시간: {execution_time:.2f}초
        - 완료 시각: {datetime.now()}
        """)
        
        return {
            "agent": agent_name,
            "task": task,
            "execution_time": execution_time,
            "timestamp": datetime.now().isoformat()
        }
    
    def analyze_performance(self, executions: list):
        """성능을 분석합니다."""
        if not executions:
            return "분석할 데이터가 없습니다."
        
        avg_time = sum(e["execution_time"] for e in executions) / len(executions)
        max_time = max(e["execution_time"] for e in executions)
        min_time = min(e["execution_time"] for e in executions)
        
        return {
            "total_executions": len(executions),
            "average_time": avg_time,
            "max_time": max_time,
            "min_time": min_time,
            "performance_grade": "우수" if avg_time < 5 else "보통"
        }
```

### 2. 비용 최적화

```python
class CostOptimizer:
    def __init__(self):
        self.model_costs = {
            "gemini-2.0-flash": {"input": 0.075, "output": 0.30},  # 1M 토큰당 USD
            "gemini-2.5-pro": {"input": 1.25, "output": 5.00},
            "gemini-pro": {"input": 0.50, "output": 1.50}
        }
    
    def recommend_model(self, task_complexity: str, budget_priority: str):
        """작업 복잡도와 예산에 따라 최적 모델을 추천합니다."""
        
        if task_complexity == "simple" and budget_priority == "high":
            return "gemini-2.0-flash"
        elif task_complexity == "complex" and budget_priority == "low":
            return "gemini-2.5-pro"
        else:
            return "gemini-pro"
    
    def estimate_cost(self, model: str, input_tokens: int, output_tokens: int):
        """예상 비용을 계산합니다."""
        costs = self.model_costs.get(model, self.model_costs["gemini-pro"])
        
        input_cost = (input_tokens / 1_000_000) * costs["input"]
        output_cost = (output_tokens / 1_000_000) * costs["output"] 
        
        return {
            "model": model,
            "input_cost": input_cost,
            "output_cost": output_cost,
            "total_cost": input_cost + output_cost,
            "currency": "USD"
        }
```

## Agent2Agent 프로토콜

### 1. 에이전트 간 통신

```python
class Agent2AgentSystem:
    def __init__(self):
        self.agents = {}
        self.protocol_version = "1.0"
    
    def register_agent(self, agent: Agent, capabilities: list):
        """에이전트를 등록하고 능력을 공개합니다."""
        self.agents[agent.name] = {
            "agent": agent,
            "capabilities": capabilities,
            "status": "active",
            "registered_at": datetime.now()
        }
    
    def discover_agents(self, required_capability: str):
        """특정 능력을 가진 에이전트를 찾습니다."""
        matching_agents = []
        
        for name, info in self.agents.items():
            if required_capability in info["capabilities"]:
                matching_agents.append({
                    "name": name,
                    "capabilities": info["capabilities"]
                })
        
        return matching_agents
    
    def negotiate_interaction(self, requester: str, provider: str, task: str):
        """에이전트 간 상호작용을 협상합니다."""
        requester_info = self.agents.get(requester)
        provider_info = self.agents.get(provider)
        
        if not requester_info or not provider_info:
            return {"status": "error", "message": "에이전트를 찾을 수 없습니다."}
        
        return {
            "status": "success",
            "interaction_id": f"{requester}_{provider}_{datetime.now().timestamp()}",
            "protocol": self.protocol_version,
            "task": task
        }

# 사용 예시
a2a_system = Agent2AgentSystem()

# 에이전트 등록
a2a_system.register_agent(
    weather_agent, 
    ["weather_info", "location_data"]
)

a2a_system.register_agent(
    support_agent,
    ["customer_service", "issue_resolution"]
)

# 협업 에이전트 찾기
weather_agents = a2a_system.discover_agents("weather_info")
print(f"날씨 정보 제공 가능한 에이전트: {weather_agents}")
```

## 보안 및 가드레일

### 1. 입력 검증 및 필터링

```python
def validate_input(user_input: str) -> dict:
    """사용자 입력을 검증합니다."""
    
    # 악성 입력 패턴 검사
    malicious_patterns = [
        "system prompt",
        "ignore previous instructions",
        "프롬프트 무시",
        "시스템 명령"
    ]
    
    for pattern in malicious_patterns:
        if pattern.lower() in user_input.lower():
            return {
                "valid": False,
                "reason": "잠재적 악성 입력 감지",
                "risk_level": "high"
            }
    
    # 길이 검사
    if len(user_input) > 10000:
        return {
            "valid": False,
            "reason": "입력이 너무 깁니다",
            "risk_level": "medium"
        }
    
    return {
        "valid": True,
        "reason": "입력이 안전합니다",
        "risk_level": "low"
    }

def secure_agent_wrapper(agent: Agent):
    """보안 래퍼로 에이전트를 보호합니다."""
    
    class SecureAgent:
        def __init__(self, base_agent):
            self.base_agent = base_agent
            self.logger = logging.getLogger(f"secure_{base_agent.name}")
        
        async def run(self, user_input: str):
            # 입력 검증
            validation = validate_input(user_input)
            
            if not validation["valid"]:
                self.logger.warning(f"입력 차단: {validation['reason']}")
                return "입력이 안전하지 않아 처리할 수 없습니다."
            
            # 안전한 실행
            try:
                result = await self.base_agent.run(user_input)
                self.logger.info("에이전트 실행 완료")
                return result
            except Exception as e:
                self.logger.error(f"에이전트 실행 오류: {str(e)}")
                return "처리 중 오류가 발생했습니다."
    
    return SecureAgent(agent)
```

### 2. 권한 관리

```python
class PermissionManager:
    def __init__(self):
        self.permissions = {}
        self.role_permissions = {
            "admin": ["read", "write", "execute", "delete"],
            "user": ["read", "write"],
            "guest": ["read"]
        }
    
    def assign_role(self, agent_name: str, role: str):
        """에이전트에 역할을 할당합니다."""
        if role in self.role_permissions:
            self.permissions[agent_name] = self.role_permissions[role]
            return True
        return False
    
    def check_permission(self, agent_name: str, action: str) -> bool:
        """에이전트가 특정 작업을 수행할 권한이 있는지 확인합니다."""
        agent_perms = self.permissions.get(agent_name, [])
        return action in agent_perms
    
    def secure_tool_execution(self, agent_name: str, tool_name: str, action: str):
        """도구 실행 시 권한을 확인합니다."""
        if not self.check_permission(agent_name, action):
            raise PermissionError(f"{agent_name}은(는) {action} 권한이 없습니다.")
        
        logging.info(f"{agent_name}이(가) {tool_name}을(를) {action} 권한으로 실행")
        return True
```

## 모범 사례 및 팁

### 1. 에이전트 설계 원칙

```python
# ✅ 좋은 예시
good_agent = Agent(
    name="customer_support_specialist",  # 명확하고 구체적인 이름
    model="gemini-2.0-flash",  # 작업에 적합한 모델 선택
    description="고객 문의를 전문적으로 처리하는 에이전트",  # 명확한 설명
    instruction="""
    당신은 전문적인 고객 지원 담당자입니다.
    
    핵심 역할:
    1. 고객 문의사항 정확히 파악
    2. 신속하고 정확한 해결책 제시  
    3. 필요시 적절한 부서로 에스컬레이션
    
    응답 원칙:
    - 친절하고 전문적인 톤 유지
    - 구체적이고 실행 가능한 답변
    - 불확실한 경우 명시적으로 표현
    - 항상 고객 관점에서 사고
    """,  # 구체적이고 명확한 지침
    tools=[search_knowledge_base, escalate_to_human, log_interaction]  # 필요한 도구만
)

# ❌ 피해야 할 예시
bad_agent = Agent(
    name="agent1",  # 모호한 이름
    model="gemini-2.5-pro",  # 불필요하게 비싼 모델
    description="에이전트",  # 불명확한 설명
    instruction="도움을 주세요",  # 모호한 지침  
    tools=all_available_tools  # 불필요한 도구들까지 모두 포함
)
```

### 2. 에러 처리 및 복구

```python
async def robust_agent_execution(agent: Agent, task: str, max_retries: int = 3):
    """견고한 에이전트 실행 함수"""
    
    for attempt in range(max_retries):
        try:
            result = await agent.run(task)
            logging.info(f"에이전트 실행 성공 (시도 {attempt + 1})")
            return result
            
        except Exception as e:
            logging.warning(f"시도 {attempt + 1} 실패: {str(e)}")
            
            if attempt == max_retries - 1:
                logging.error("모든 재시도 실패")
                return f"작업 실행 중 오류가 발생했습니다: {str(e)}"
            
            # 지수적 백오프
            await asyncio.sleep(2 ** attempt)
    
    return "최대 재시도 횟수를 초과했습니다."
```

### 3. 테스트 전략

```python
import pytest
from unittest.mock import AsyncMock, patch

class TestADKAgents:
    @pytest.fixture
    def sample_agent(self):
        return Agent(
            name="test_agent",
            model="gemini-2.0-flash",
            description="테스트용 에이전트",
            instruction="테스트를 위한 에이전트입니다."
        )
    
    @pytest.mark.asyncio
    async def test_basic_response(self, sample_agent):
        """기본 응답 테스트"""
        with patch.object(sample_agent, 'run', return_value="테스트 응답"):
            response = await sample_agent.run("안녕하세요")
            assert response == "테스트 응답"
    
    @pytest.mark.asyncio  
    async def test_tool_integration(self, sample_agent):
        """도구 통합 테스트"""
        mock_tool = AsyncMock(return_value="도구 실행 결과")
        sample_agent.tools = [mock_tool]
        
        with patch.object(sample_agent, 'run', return_value="도구가 실행되었습니다"):
            response = await sample_agent.run("도구를 실행해주세요")
            assert "실행" in response
    
    def test_agent_configuration(self, sample_agent):
        """에이전트 설정 테스트"""
        assert sample_agent.name == "test_agent"
        assert sample_agent.model == "gemini-2.0-flash"
        assert "테스트" in sample_agent.description
```

## 결론

Google Agent Development Kit (ADK)는 AI 에이전트 개발의 새로운 표준을 제시합니다. 이 가이드에서 다룬 핵심 내용들:

### 주요 장점
1. **간편한 시작**: 100줄 미만의 코드로 강력한 에이전트 구축
2. **엔터프라이즈 준비**: Vertex AI와의 완벽한 통합
3. **오픈 생태계**: Agent2Agent 프로토콜로 다양한 시스템과 연동
4. **확장성**: 단일 에이전트부터 복잡한 멀티 에이전트 시스템까지

### 차별화 요소
- **Google의 신뢰성**: Gemini 모델과 최적화된 통합
- **Agent Garden**: 즉시 사용 가능한 샘플과 도구
- **Agent Engine**: 완전 관리형 프로덕션 런타임
- **멀티모달 지원**: 텍스트, 오디오, 비디오 상호작용

### 다음 단계
- Agent Engine을 통한 프로덕션 배포
- Google Cloud 서비스와의 심화 통합
- Agent2Agent 프로토콜을 활용한 에코시스템 구축
- 엔터프라이즈 보안 및 규정 준수 강화

Google ADK는 실험실의 개념이 아닌 실무에서 바로 활용할 수 있는 도구입니다. 이 가이드를 통해 여러분만의 혁신적인 AI 에이전트 솔루션을 구축해보세요.

---

**참고 링크:**
- [Google ADK 공식 문서](https://cloud.google.com/vertex-ai/generative-ai/docs/agent-development-kit)
- [Vertex AI Agents 가이드](https://cloud.google.com/vertex-ai/generative-ai/docs/agents)
- [Agent Garden 샘플](https://github.com/GoogleCloudPlatform/agent-garden)
- [Google Codelabs: ADK 시작하기](https://codelabs.developers.google.com/your-first-agent-with-adk) 