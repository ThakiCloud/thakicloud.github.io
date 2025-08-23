---
title: "Agno 멀티 에이전트 시스템 구축 완전 가이드"
date: 2025-06-08
categories: 
  - tutorials
tags: 
  - AI
  - MultiAgent
  - Agno
  - Python
  - Framework
  - Tutorial
  - AGI
author_profile: true
toc: true
toc_label: "Agno 완전 가이드"
---

Agno는 메모리, 지식, 추론 기능을 갖춘 멀티 에이전트 시스템을 구축하기 위한 풀스택 프레임워크입니다. 27.9k GitHub 스타를 보유한 이 프레임워크는 5단계 에이전틱 시스템을 지원하며, 뛰어난 성능과 확장성을 제공합니다.

## Agno란 무엇인가?

[Agno](https://github.com/agno-agi/agno)는 **메모리, 지식, 추론을 갖춘 멀티 에이전트 시스템**을 구축하기 위한 포괄적인 프레임워크입니다. MPL-2.0 라이선스 하에 배포되며, 현재 GitHub에서 27.9k 스타와 3.6k 포크를 기록하고 있습니다.

### 5단계 에이전틱 시스템 지원

Agno는 다음과 같은 5단계 에이전틱 시스템을 지원합니다:

- **Level 1**: 도구와 지시사항을 갖춘 에이전트
- **Level 2**: 지식과 저장소를 갖춘 에이전트  
- **Level 3**: 메모리와 추론을 갖춘 에이전트
- **Level 4**: 추론과 협업이 가능한 에이전트 팀
- **Level 5**: 상태와 결정론을 갖춘 에이전틱 워크플로우

## 핵심 특징

### 성능 최적화

Agno의 가장 인상적인 특징 중 하나는 **탁월한 성능**입니다:

- **에이전트 인스턴스화**: 평균 ~3μs
- **메모리 사용량**: 평균 ~6.5KiB

이는 Apple M4 MacBook Pro에서 측정된 결과로, 수천 개의 에이전트를 생성하는 대규모 시스템에서도 병목 현상 없이 작동할 수 있습니다.

### 모델 중립성

23개 이상의 모델 제공업체를 지원하는 **통합 인터페이스**를 제공하여 벤더 락인을 방지합니다. OpenAI, Anthropic, Google 등 다양한 제공업체의 모델을 동일한 API로 사용할 수 있습니다.

### 고급 기능

- **추론 우선 설계**: 복잡한 자율 에이전트의 신뢰성 향상
- **네이티브 멀티모달**: 텍스트, 이미지, 오디오, 비디오 입출력 지원
- **고급 멀티 에이전트 아키텍처**: 추론, 메모리, 공유 컨텍스트를 갖춘 에이전트 팀
- **내장 에이전틱 검색**: 20개 이상의 벡터 데이터베이스 지원
- **구조화된 출력**: 완전한 타입 안전성을 갖춘 응답 생성
- **사전 구축된 FastAPI 라우트**: 0에서 프로덕션까지 몇 분 만에 배포

## 설치 및 설정

### 기본 설치

```bash
pip install -U agno
```

### 가상환경 설정

```bash
# uv 사용 (권장)
uv venv --python 3.12
source .venv/bin/activate

# 또는 기존 방식
python -m venv agno-env
source agno-env/bin/activate  # Linux/Mac
# agno-env\Scripts\activate  # Windows
```

## 실전 예제: 추론 에이전트

### Level 1: 기본 추론 에이전트

YFinance API를 사용하여 금융 정보에 대한 질문에 답변하는 추론 에이전트를 구축해보겠습니다.

```python
from agno.agent import Agent
from agno.models.anthropic import Claude
from agno.tools.reasoning import ReasoningTools
from agno.tools.yfinance import YFinanceTools

# 추론 에이전트 생성
reasoning_agent = Agent(
    model=Claude(id="claude-sonnet-4-20250514"),
    tools=[
        ReasoningTools(add_instructions=True),
        YFinanceTools(
            stock_price=True, 
            analyst_recommendations=True, 
            company_info=True, 
            company_news=True
        ),
    ],
    instructions="Use tables to display data.",
    markdown=True,
)

# 에이전트 실행
reasoning_agent.print_response(
    "Write a report on NVDA",
    stream=True,
    show_full_reasoning=True,
    stream_intermediate_steps=True,
)
```

### 필요한 의존성 설치 및 실행

```bash
# 의존성 설치
uv pip install agno anthropic yfinance

# API 키 설정
export ANTHROPIC_API_KEY=sk-ant-api03-xxxx

# 에이전트 실행
python reasoning_agent.py
```

## 고급 예제: 멀티 에이전트 팀

### Level 4: 협업하는 에이전트 팀

복잡한 작업을 위해 전문화된 에이전트들이 협업하는 시스템을 구축해보겠습니다.

```python
from agno.agent import Agent
from agno.models.openai import OpenAIChat
from agno.tools.duckduckgo import DuckDuckGoTools
from agno.tools.yfinance import YFinanceTools
from agno.team import Team

# 웹 검색 전문 에이전트
web_agent = Agent(
    name="Web Agent",
    role="Search the web for information",
    model=OpenAIChat(id="gpt-4o"),
    tools=[DuckDuckGoTools()],
    instructions="Always include sources",
    show_tool_calls=True,
    markdown=True,
)

# 금융 데이터 전문 에이전트
finance_agent = Agent(
    name="Finance Agent",
    role="Get financial data",
    model=OpenAIChat(id="gpt-4o"),
    tools=[YFinanceTools(
        stock_price=True, 
        analyst_recommendations=True, 
        company_info=True
    )],
    instructions="Use tables to display data",
    show_tool_calls=True,
    markdown=True,
)

# 에이전트 팀 구성
agent_team = Team(
    mode="coordinate",
    members=[web_agent, finance_agent],
    model=OpenAIChat(id="gpt-4o"),
    success_criteria="A comprehensive financial news report with clear sections and data-driven insights.",
    instructions=["Always include sources", "Use tables to display data"],
    show_tool_calls=True,
    markdown=True,
)

# 팀 실행
agent_team.print_response(
    "What's the market outlook and financial performance of AI semiconductor companies?", 
    stream=True
)
```

### 추가 의존성 설치

```bash
pip install duckduckgo-search yfinance
python agent_team.py
```

## 에이전틱 RAG 구현

### 지식 기반 에이전트 구축

문서 검색과 추론을 결합한 에이전틱 RAG 시스템을 구현할 수 있습니다:

```python
from agno.agent import Agent
from agno.models.openai import OpenAIChat
from agno.tools.reasoning import ReasoningTools
from agno.knowledge.pdf import PDFReader
from agno.vectordb.pgvector import PgVector

# 벡터 데이터베이스 설정
vector_db = PgVector(
    table_name="documents",
    db_url="postgresql://user:password@localhost:5432/agno_db"
)

# 지식 기반 에이전트
knowledge_agent = Agent(
    model=OpenAIChat(id="gpt-4o"),
    tools=[ReasoningTools(add_instructions=True)],
    knowledge_base=vector_db,
    instructions=[
        "Use the knowledge base to find relevant information",
        "Always cite your sources",
        "If information is not in the knowledge base, clearly state that"
    ],
    markdown=True,
)

# PDF 문서 추가
pdf_reader = PDFReader()
documents = pdf_reader.read("path/to/document.pdf")
vector_db.load_documents(documents)

# 질의 응답
knowledge_agent.print_response(
    "What are the key findings in the research paper?",
    stream=True,
    show_full_reasoning=True
)
```

## 성능 벤치마크

### 인스턴스화 성능

Agno의 성능 우위는 다른 프레임워크와의 비교에서 명확히 드러납니다:

```python
# 성능 테스트 실행
./scripts/perf_setup.sh
source .venvs/perfenv/bin/activate

# Agno 성능 측정
python evals/performance/instantiation_with_tool.py

# LangGraph 성능 측정 (비교용)
python evals/performance/other/langgraph_instantiation.py
```

Apple M4 MacBook Pro에서 측정된 결과:

- **Agno**: 평균 3μs 인스턴스화 시간
- **메모리 사용량**: 평균 6.5KiB

이는 대규모 멀티 에이전트 시스템에서 중요한 성능 이점을 제공합니다.

## 프로덕션 배포

### FastAPI 통합

```python
from agno.api.routes import AgentRoutes
from fastapi import FastAPI

# FastAPI 앱 생성
app = FastAPI(title="Agno Agent API")

# 에이전트 라우트 추가
agent_routes = AgentRoutes(agent=reasoning_agent)
app.include_router(agent_routes.router, prefix="/agent")

# 서버 실행
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

### 모니터링 설정

Agno는 [agno.com](https://agno.com)에서 실시간 모니터링을 제공합니다:

```python
# 모니터링 활성화
agent = Agent(
    model=OpenAIChat(id="gpt-4o"),
    tools=[ReasoningTools()],
    monitoring=True,  # 모니터링 활성화
)
```

## 개발 환경 최적화

### Cursor IDE 설정

Cursor IDE에서 Agno 개발을 위한 설정:

1. Cursor 설정 또는 환경설정 섹션으로 이동
2. 문서 소스 관리 섹션 찾기
3. `https://docs.agno.com`을 문서 URL 목록에 추가
4. 변경사항 저장

이제 Cursor에서 Agno 문서에 직접 접근할 수 있습니다.

## 고급 기능

### 구조화된 출력

```python
from pydantic import BaseModel
from typing import List

class StockAnalysis(BaseModel):
    symbol: str
    current_price: float
    recommendation: str
    key_metrics: List[str]

# 구조화된 출력을 위한 에이전트
structured_agent = Agent(
    model=OpenAIChat(id="gpt-4o"),
    tools=[YFinanceTools()],
    response_model=StockAnalysis,
)

# 타입 안전한 응답 받기
response = structured_agent.run("Analyze AAPL stock")
print(f"Symbol: {response.symbol}")
print(f"Price: ${response.current_price}")
```

### 메모리와 세션 관리

```python
from agno.storage.postgres import PostgresStorage
from agno.memory.db import PgMemoryDb

# 영구 저장소 설정
storage = PostgresStorage(
    table_name="agent_sessions",
    db_url="postgresql://user:password@localhost:5432/agno_db"
)

# 메모리 데이터베이스 설정
memory = PgMemoryDb(
    table_name="agent_memory",
    db_url="postgresql://user:password@localhost:5432/agno_db"
)

# 메모리와 저장소를 갖춘 에이전트
persistent_agent = Agent(
    model=OpenAIChat(id="gpt-4o"),
    storage=storage,
    memory=memory,
    session_id="user_123",
)
```

## 텔레메트리 설정

Agno는 기본적으로 모델 사용 통계를 수집합니다. 이를 비활성화하려면:

```bash
export AGNO_TELEMETRY=false
```

## 결론

Agno는 현대적인 멀티 에이전트 시스템 구축을 위한 강력하고 성능 최적화된 프레임워크입니다. 뛰어난 성능, 모델 중립성, 그리고 포괄적인 기능 세트를 통해 프로토타입부터 프로덕션까지 전체 개발 라이프사이클을 지원합니다.

특히 추론을 일급 시민으로 다루는 접근 방식과 네이티브 멀티모달 지원은 차세대 AI 애플리케이션 개발에 필수적인 기능들입니다. 27.9k GitHub 스타를 기록한 활발한 커뮤니티와 함께, Agno는 AGI 시대를 준비하는 개발자들에게 최적의 선택입니다.

더 자세한 정보는 [공식 문서](https://docs.agno.com), [커뮤니티 포럼](https://community.agno.com), 그리고 [GitHub 리포지토리](https://github.com/agno-agi/agno)에서 확인할 수 있습니다.
