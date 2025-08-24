---
title: "Water 프레임워크 완벽 가이드: 멀티 에이전트 오케스트레이션의 새로운 패러다임"
excerpt: "프레임워크에 구애받지 않는 멀티 에이전트 오케스트레이션 프레임워크 Water를 활용해 LangChain, CrewAI, 커스텀 에이전트를 통합하고 복잡한 워크플로우를 구축하는 방법을 소개합니다."
date: 2025-06-16
categories:
  - agentops
tags:
  - water
  - multi-agent
  - orchestration
  - workflow
  - python
author_profile: true
toc: true
toc_label: Water Framework Guide
---

## 개요

[Water](https://github.com/manthanguptaa/water)는 **프레임워크에 구애받지 않는** 멀티 에이전트 오케스트레이션 프레임워크입니다. LangChain, CrewAI, Agno 등 기존 에이전트 프레임워크나 커스텀 구현체를 그대로 활용하면서, 복잡한 멀티 에이전트 워크플로우를 조율할 수 있는 상위 레이어를 제공합니다. 프로덕션 환경에서 사용할 수 있도록 설계되었으며, FastAPI 기반 플레이그라운드를 통해 정의한 플로우를 즉시 테스트할 수 있습니다. \[GitHub Repo\]

## 1. 핵심 특징

| 특징 | 설명 |
| --- | --- |
| **Framework Agnostic** | 모든 에이전트 프레임워크 및 커스텀 구현체 통합 가능 |
| **Flexible Workflows** | Python으로 복잡한 멀티 에이전트 상호작용 정의 |
| **Production Ready** | 프로덕션 환경에서 사용 가능한 안정성 |
| **Playground** | FastAPI 서버로 정의한 플로우 즉시 테스트 |
| **Type Safety** | Pydantic 스키마 기반 입출력 검증 |

## 2. 설치 및 기본 설정

```bash
pip install water-ai
```

## 3. 기본 사용법

### 3.1 단순 태스크 정의

```python
import asyncio
from water import Flow, create_task
from pydantic import BaseModel

class NumberInput(BaseModel):
    value: int

class NumberOutput(BaseModel):
    result: int

def add_five(params, context):
    return {"result": params["input_data"]["value"] + 5}

# 태스크 생성
math_task = create_task(
    id="math_task",
    description="Add 5 to input number",
    input_schema=NumberInput,
    output_schema=NumberOutput,
    execute=add_five
)

# 플로우 정의 및 등록
flow = Flow(id="simple_math", description="Simple math flow").then(math_task).register()

async def main():
    result = await flow.run({"value": 10})
    print(result)  # {"result": 15}

if __name__ == "__main__":
    asyncio.run(main())
```

### 3.2 복합 워크플로우

```python
from water import Flow, create_task
from pydantic import BaseModel

class TextInput(BaseModel):
    text: str

class AnalysisOutput(BaseModel):
    sentiment: str
    keywords: list[str]

class SummaryOutput(BaseModel):
    summary: str

def analyze_text(params, context):
    text = params["input_data"]["text"]
    # 실제로는 LLM API 호출
    return {
        "sentiment": "positive",
        "keywords": ["AI", "framework", "orchestration"]
    }

def summarize_text(params, context):
    text = params["input_data"]["text"]
    analysis = context.get("analysis_result", {})
    # 분석 결과를 활용한 요약
    return {
        "summary": f"Text with {analysis.get('sentiment', 'unknown')} sentiment"
    }

# 태스크들 정의
analysis_task = create_task(
    id="analysis",
    description="Analyze text sentiment and extract keywords",
    input_schema=TextInput,
    output_schema=AnalysisOutput,
    execute=analyze_text
)

summary_task = create_task(
    id="summary",
    description="Summarize text based on analysis",
    input_schema=TextInput,
    output_schema=SummaryOutput,
    execute=summarize_text
)

# 순차 실행 플로우
sequential_flow = Flow(
    id="text_processing",
    description="Analyze and summarize text"
).then(analysis_task).then(summary_task).register()

# 병렬 실행 플로우
parallel_flow = Flow(
    id="parallel_processing",
    description="Parallel text processing"
).parallel([analysis_task, summary_task]).register()
```

## 4. 기존 프레임워크 통합

### 4.1 LangChain 에이전트 통합

```python
from langchain.agents import create_openai_functions_agent
from langchain.tools import DuckDuckGoSearchRun
from water import create_task

def langchain_agent_wrapper(params, context):
    # LangChain 에이전트 초기화
    search = DuckDuckGoSearchRun()
    agent = create_openai_functions_agent(
        llm=llm,
        tools=[search],
        prompt=prompt
    )
    
    # 에이전트 실행
    result = agent.invoke({"input": params["input_data"]["query"]})
    return {"response": result["output"]}

langchain_task = create_task(
    id="langchain_search",
    description="Search using LangChain agent",
    input_schema=QueryInput,
    output_schema=ResponseOutput,
    execute=langchain_agent_wrapper
)
```

### 4.2 CrewAI 통합

```python
from crewai import Agent, Task, Crew
from water import create_task

def crewai_wrapper(params, context):
    # CrewAI 에이전트 정의
    researcher = Agent(
        role='Researcher',
        goal='Research the given topic',
        backstory='Expert researcher',
        verbose=True
    )
    
    task = Task(
        description=f"Research: {params['input_data']['topic']}",
        agent=researcher
    )
    
    crew = Crew(agents=[researcher], tasks=[task])
    result = crew.kickoff()
    
    return {"research_result": str(result)}

crewai_task = create_task(
    id="crewai_research",
    description="Research using CrewAI",
    input_schema=TopicInput,
    output_schema=ResearchOutput,
    execute=crewai_wrapper
)
```

## 5. 고급 워크플로우 패턴

### 5.1 조건부 실행

```python
def conditional_router(params, context):
    sentiment = context.get("analysis_result", {}).get("sentiment")
    
    if sentiment == "negative":
        return "escalation_flow"
    elif sentiment == "positive":
        return "standard_flow"
    else:
        return "neutral_flow"

conditional_flow = Flow(
    id="conditional_processing",
    description="Route based on sentiment"
).then(analysis_task).route(conditional_router, {
    "escalation_flow": escalation_task,
    "standard_flow": standard_task,
    "neutral_flow": neutral_task
}).register()
```

### 5.2 루프 및 재시도

```python
def retry_wrapper(params, context):
    max_retries = 3
    for attempt in range(max_retries):
        try:
            result = risky_operation(params)
            return result
        except Exception as e:
            if attempt == max_retries - 1:
                raise e
            continue

retry_task = create_task(
    id="retry_task",
    description="Task with retry logic",
    input_schema=InputSchema,
    output_schema=OutputSchema,
    execute=retry_wrapper
)
```

## 6. FastAPI 플레이그라운드

```python
from water.playground import create_playground

# 모든 등록된 플로우를 포함한 FastAPI 앱 생성
app = create_playground()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

플레이그라운드 실행 후 `http://localhost:8000/docs`에서 Swagger UI를 통해 정의한 플로우들을 테스트할 수 있습니다.

## 7. 컨텍스트 및 상태 관리

```python
def stateful_task(params, context):
    # 이전 태스크 결과 접근
    previous_result = context.get("previous_task_id")
    
    # 글로벌 상태 업데이트
    context.set("current_step", "processing")
    
    # 세션 데이터 저장
    context.session["user_preferences"] = params["preferences"]
    
    return {"status": "completed"}
```

## 8. 에러 핸들링 및 모니터링

```python
def monitored_task(params, context):
    try:
        # 태스크 실행 시간 측정
        start_time = time.time()
        result = expensive_operation(params)
        execution_time = time.time() - start_time
        
        # 메트릭 로깅
        context.log_metric("execution_time", execution_time)
        context.log_metric("success", 1)
        
        return result
    except Exception as e:
        context.log_metric("error", 1)
        context.log_error(str(e))
        raise
```

## 9. 프로덕션 배포 예제

```python
from water import Flow, create_task
from water.middleware import AuthMiddleware, RateLimitMiddleware

# 미들웨어 설정
auth_middleware = AuthMiddleware(api_key="your-api-key")
rate_limit_middleware = RateLimitMiddleware(requests_per_minute=100)

# 프로덕션 플로우
production_flow = Flow(
    id="production_workflow",
    description="Production-ready workflow",
    middlewares=[auth_middleware, rate_limit_middleware]
).then(preprocessing_task).parallel([
    analysis_task,
    enrichment_task
]).then(aggregation_task).register()

# 배포
app = create_playground(
    title="Production API",
    version="1.0.0",
    enable_cors=True,
    enable_metrics=True
)
```

## 10. 로드맵 및 향후 계획

Water 프레임워크는 다음 기능들을 개발 중입니다:

- **Storage Layer**: 플로우 세션 및 태스크 실행 결과 저장
- **Human in the Loop**: 인간 개입이 필요한 워크플로우 지원
- **Retry Mechanism**: 개별 태스크 재시도 메커니즘
- **Visual Flow Builder**: 웹 기반 플로우 설계 도구

## 11. 결론

Water는 멀티 에이전트 시스템의 복잡성을 해결하면서도 기존 투자를 보호할 수 있는 혁신적인 오케스트레이션 프레임워크입니다. 프레임워크에 구애받지 않는 설계로 인해 LangChain, CrewAI 등 기존 도구들을 그대로 활용하면서도 더 복잡하고 확장 가능한 워크플로우를 구축할 수 있습니다. 프로덕션 환경에서의 안정성과 개발자 경험을 모두 고려한 설계로, 엔터프라이즈급 멀티 에이전트 시스템 구축에 적합합니다.

> 프로젝트 소스코드와 더 많은 예제는 GitHub에서 확인하세요: [manthanguptaa/water](https://github.com/manthanguptaa/water) \[GitHub Repo\]
