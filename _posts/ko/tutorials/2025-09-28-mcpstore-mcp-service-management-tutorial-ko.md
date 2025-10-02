---
title: "MCPStore: AI 에이전트를 위한 MCP 서비스 관리 완벽 가이드"
excerpt: "MCPStore를 활용하여 AI 에이전트가 다양한 도구를 쉽게 통합하고 사용할 수 있도록 하는 오픈소스 MCP 서비스 관리 도구의 완벽한 사용법을 알아보세요."
seo_title: "MCPStore 튜토리얼: AI 에이전트용 MCP 서비스 관리 - Thaki Cloud"
seo_description: "MCPStore 완벽 가이드 - LangChain 통합, 멀티 에이전트 격리, RESTful API를 지원하는 오픈소스 MCP 서비스 관리 도구 튜토리얼"
date: 2025-09-28
categories:
  - tutorials
tags:
  - MCP
  - AI-에이전트
  - Python
  - LangChain
  - API
  - 오픈소스
author_profile: true
toc: true
toc_label: "목차"
lang: ko
permalink: /ko/tutorials/mcpstore-mcp-service-management-tutorial/
canonical_url: "https://thakicloud.github.io/ko/tutorials/mcpstore-mcp-service-management-tutorial/"
---

⏱️ **예상 읽기 시간**: 12분

## 소개

MCPStore는 AI 에이전트를 위한 MCP(Model Context Protocol) 서비스 관리를 혁신적으로 단순화하는 오픈소스 도구입니다. GitHub에서 236개 이상의 스타를 받으며 인기가 급상승하고 있는 MCPStore는 멀티 에이전트 격리, LangChain 통합, 직관적인 웹 인터페이스 등의 기능을 제공하는 우아한 솔루션입니다.

## MCPStore란 무엇인가?

MCPStore는 AI 에이전트가 다양한 도구를 쉽게 사용할 수 있도록 하는 원스톱 오픈소스 고품질 MCP 서비스 관리 도구입니다. 주요 특징은 다음과 같습니다:

- **체인 호출 설계**: `store.for_store()`와 `store.for_agent("agent_id")`를 통한 명확한 컨텍스트 격리
- **멀티 에이전트 지원**: 서로 다른 기능적 에이전트를 위한 전용 도구셋
- **LangChain 통합**: 인기 있는 AI 프레임워크와의 원활한 통합
- **RESTful API**: 완전한 웹 서비스 인터페이스
- **Vue 프론트엔드**: 서비스 관리를 위한 직관적인 웹 인터페이스

## 설치 및 설정

### 빠른 설치

MCPStore를 시작하는 가장 간단한 방법은 pip를 통한 설치입니다:

```bash
pip install mcpstore
```

### 설치 확인

설치 후 MCPStore가 올바르게 작동하는지 확인할 수 있습니다:

```python
from mcpstore import MCPStore

# 스토어 초기화
store = MCPStore.setup_store()
print("MCPStore가 성공적으로 초기화되었습니다!")
```

## 기본 사용법

### 첫 번째 MCP 서비스 설정

MCP 서비스를 추가하고 사용하는 기본 예제부터 시작해보겠습니다:

```python
from mcpstore import MCPStore

# 스토어 초기화
store = MCPStore.setup_store()

# 글로벌 스토어에 서비스 추가
store.for_store().add_service({
    "name": "mcpstore-wiki",
    "url": "https://mcpstore.wiki/mcp"
})

# 사용 가능한 도구 목록 조회
tools = store.for_store().list_tools()
print(f"사용 가능한 도구: {len(tools)}개")

# 도구 사용 예제
# result = store.for_store().use_tool(tools[0].name, {"query": "안녕하세요!"})
```

### 체인 호출 설계 이해하기

MCPStore는 명확한 컨텍스트 격리를 제공하는 체인 호출 설계를 사용합니다:

```python
# 글로벌 스토어 공간 - 모든 에이전트가 공유
global_context = store.for_store()

# 에이전트별 공간 - 각 에이전트마다 격리됨
agent_context = store.for_agent("my-agent-id")
```

## 멀티 에이전트 격리

MCPStore의 가장 강력한 기능 중 하나는 서로 다른 AI 에이전트를 위한 격리된 환경을 생성하는 능력입니다.

### 격리된 에이전트 환경 생성

```python
from mcpstore import MCPStore

# 스토어 초기화
store = MCPStore.setup_store()

# Wiki 도구를 가진 지식 관리 에이전트 생성
agent_id1 = "knowledge-agent"
knowledge_agent = store.for_agent(agent_id1)
knowledge_agent.add_service({
    "name": "mcpstore-wiki",
    "url": "http://mcpstore.wiki/mcp"
})

# 다른 도구를 가진 개발 지원 에이전트 생성
agent_id2 = "development-agent"
dev_agent = store.for_agent(agent_id2)
dev_agent.add_service({
    "name": "mcpstore-demo",
    "url": "http://mcpstore.wiki/mcp"
})

# 각 에이전트는 완전히 격리된 도구셋을 가짐
knowledge_tools = store.for_agent(agent_id1).list_tools()
dev_tools = store.for_agent(agent_id2).list_tools()

print(f"지식 에이전트 도구: {len(knowledge_tools)}개")
print(f"개발 에이전트 도구: {len(dev_tools)}개")
```

### 멀티 에이전트 격리의 장점

- **보안**: 각 에이전트는 할당된 도구에만 접근 가능
- **조직화**: 서로 다른 에이전트 역할 간의 명확한 관심사 분리
- **확장성**: 기존 에이전트에 영향을 주지 않고 새로운 에이전트 추가 용이
- **디버깅**: 격리된 환경으로 문제 해결이 더 쉬움

## LangChain 통합

MCPStore는 LangChain과의 원활한 통합을 제공하여 AI 워크플로우에 MCP 도구를 쉽게 통합할 수 있습니다.

### 완전한 LangChain 예제

```python
from langchain.agents import create_tool_calling_agent, AgentExecutor
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import ChatOpenAI
from mcpstore import MCPStore

# MCPStore 설정
store = MCPStore.setup_store()
store.for_store().add_service({
    "name": "mcpstore-wiki",
    "url": "https://mcpstore.wiki/mcp"
})

# LangChain용 도구 가져오기
tools = store.for_store().for_langchain().list_tools()

# LLM 구성 (API 키를 본인의 것으로 교체)
llm = ChatOpenAI(
    temperature=0,
    model="gpt-4",
    openai_api_key="your-api-key-here"
)

# 프롬프트 템플릿 생성
prompt = ChatPromptTemplate.from_messages([
    ("system", "당신은 다양한 도구에 접근할 수 있는 도움이 되는 어시스턴트입니다."),
    ("human", "{input}"),
    ("placeholder", "{agent_scratchpad}"),
])

# 에이전트 생성 및 구성
agent = create_tool_calling_agent(llm, tools, prompt)
agent_executor = AgentExecutor(agent=agent, tools=tools, verbose=True)

# 쿼리 실행
query = "MCPStore에 대해 어떤 정보를 제공할 수 있나요?"
response = agent_executor.invoke({"input": query})
print(f"응답: {response['output']}")
```

### 대안 LLM 제공업체

MCPStore는 다양한 LLM 제공업체와 작동합니다. DeepSeek 예제:

```python
llm = ChatOpenAI(
    temperature=0,
    model="deepseek-chat",
    openai_api_key="your-deepseek-api-key",
    openai_api_base="https://api.deepseek.com"
)
```

## 웹 API 인터페이스

MCPStore는 웹 기반 애플리케이션을 위한 완전한 RESTful API를 제공합니다.

### API 서버 시작

```python
from mcpstore import MCPStore

# API 서버 설정 및 시작
prod_store = MCPStore.setup_store()
prod_store.start_api_server(host='0.0.0.0', port=18200)
```

또는 명령줄 사용:

```bash
mcpstore run api
```

### 주요 API 엔드포인트

#### 서비스 관리

```bash
# 새 서비스 추가
curl -X POST http://localhost:18200/for_store/add_service \
  -H "Content-Type: application/json" \
  -d '{"name": "my-service", "url": "https://example.com/mcp"}'

# 모든 서비스 목록 조회
curl -X GET http://localhost:18200/for_store/list_services

# 서비스 삭제
curl -X POST http://localhost:18200/for_store/delete_service \
  -H "Content-Type: application/json" \
  -d '{"name": "my-service"}'
```

#### 도구 작업

```bash
# 사용 가능한 도구 목록 조회
curl -X GET http://localhost:18200/for_store/list_tools

# 도구 실행
curl -X POST http://localhost:18200/for_store/use_tool \
  -H "Content-Type: application/json" \
  -d '{"tool_name": "search", "parameters": {"query": "안녕하세요"}}'
```

#### 모니터링 및 상태 확인

```bash
# 시스템 통계 조회
curl -X GET http://localhost:18200/for_store/get_stats

# 상태 확인
curl -X GET http://localhost:18200/for_store/health
```

## Vue 프론트엔드 인터페이스

MCPStore는 직관적인 서비스 관리를 위한 아름다운 Vue.js 프론트엔드를 포함합니다.

### 웹 인터페이스 기능

- **서비스 관리**: MCP 서비스 추가, 제거 및 구성
- **도구 시각화**: 사용 가능한 도구와 매개변수 보기
- **실시간 모니터링**: 서비스 상태 및 사용 통계 모니터링
- **다국어 지원**: 여러 언어로 제공되는 인터페이스

### 웹 인터페이스 접근

API 서버를 시작한 후 다음 주소에서 웹 인터페이스에 접근할 수 있습니다:

```
http://localhost:18200
```

인터페이스는 다음을 제공합니다:
- 서비스 개요가 포함된 대시보드
- 대화형 테스트가 가능한 도구 탐색기
- 구성 관리
- 사용 분석

## 고급 구성

### 사용자 정의 서비스 구성

```python
# 고급 서비스 구성
service_config = {
    "name": "custom-service",
    "url": "https://your-mcp-service.com/mcp",
    "timeout": 30,
    "retry_attempts": 3,
    "headers": {
        "Authorization": "Bearer your-token",
        "Custom-Header": "value"
    }
}

store.for_store().add_service(service_config)
```

### 환경별 설정

```python
import os
from mcpstore import MCPStore

# 프로덕션 설정
if os.getenv('ENVIRONMENT') == 'production':
    store = MCPStore.setup_store(
        config_path='/etc/mcpstore/config.json',
        log_level='INFO'
    )
else:
    # 개발 설정
    store = MCPStore.setup_store(log_level='DEBUG')
```

## 모범 사례

### 1. 서비스 조직화

```python
# 기능별로 서비스 조직화
store.for_agent("web-scraper").add_service({
    "name": "web-scraping-tools",
    "url": "https://scraping-service.com/mcp"
})

store.for_agent("data-analyst").add_service({
    "name": "analytics-tools",
    "url": "https://analytics-service.com/mcp"
})
```

### 2. 오류 처리

```python
try:
    result = store.for_store().use_tool("search", {"query": "테스트"})
    print(f"성공: {result}")
except Exception as e:
    print(f"도구 사용 오류: {e}")
```

### 3. 리소스 관리

```python
# 작업 완료 후 리소스 정리
store.cleanup()
```

## 문제 해결

### 일반적인 문제와 해결책

#### 1. 서비스 연결 문제

```python
# 서비스 상태 확인
services = store.for_store().list_services()
for service in services:
    health = store.for_store().check_service_health(service.name)
    print(f"{service.name}: {health}")
```

#### 2. 도구 실행 실패

```python
# 도구 실행 디버깅
tools = store.for_store().list_tools()
for tool in tools:
    print(f"도구: {tool.name}")
    print(f"매개변수: {tool.parameters}")
    print(f"설명: {tool.description}")
```

#### 3. API 서버 문제

```bash
# API 서버 실행 상태 확인
curl -X GET http://localhost:18200/for_store/health

# 서버 로그 확인
mcpstore logs
```

## 성능 최적화

### 1. 연결 풀링

```python
# 더 나은 성능을 위한 연결 풀링 구성
store = MCPStore.setup_store(
    max_connections=10,
    connection_timeout=30
)
```

### 2. 캐싱

```python
# 자주 사용되는 도구에 대한 캐싱 활성화
store.for_store().enable_caching(
    cache_size=100,
    cache_ttl=300  # 5분
)
```

## 보안 고려사항

### 1. API 인증

```python
# API 인증 구성
store.start_api_server(
    host='0.0.0.0',
    port=18200,
    auth_token='your-secure-token'
)
```

### 2. 서비스 검증

```python
# 서비스 추가 전 검증
def validate_service(service_config):
    required_fields = ['name', 'url']
    return all(field in service_config for field in required_fields)

if validate_service(service_config):
    store.for_store().add_service(service_config)
```

## 통합 예제

### 1. FastAPI 통합

```python
from fastapi import FastAPI
from mcpstore import MCPStore

app = FastAPI()
store = MCPStore.setup_store()

@app.post("/execute-tool")
async def execute_tool(tool_name: str, parameters: dict):
    result = store.for_store().use_tool(tool_name, parameters)
    return {"result": result}
```

### 2. Django 통합

```python
# views.py
from django.http import JsonResponse
from mcpstore import MCPStore

store = MCPStore.setup_store()

def execute_tool(request):
    tool_name = request.POST.get('tool_name')
    parameters = request.POST.get('parameters', {})
    
    result = store.for_store().use_tool(tool_name, parameters)
    return JsonResponse({"result": result})
```

## 커뮤니티 및 기여

MCPStore는 커뮤니티 기여를 환영하는 활발한 오픈소스 프로젝트입니다:

- **GitHub 리포지토리**: [https://github.com/whillhill/mcpstore](https://github.com/whillhill/mcpstore)
- **문서**: [doc.mcpstore.wiki](http://doc.mcpstore.wiki/)
- **이슈**: GitHub에서 버그 신고 및 기능 요청
- **풀 리퀘스트**: 코드 개선 기여

### 기여 방법

1. ⭐ GitHub에서 프로젝트에 스타 주기
2. 🐛 버그 및 이슈 신고
3. 🔧 풀 리퀘스트 제출
4. 💬 사용 경험 공유
5. 📖 문서 개선

## 결론

MCPStore는 AI 애플리케이션을 위한 MCP 서비스 관리에서 중요한 발전을 나타냅니다. 우아한 설계, 멀티 에이전트 격리 기능, 포괄적인 통합 옵션으로 AI 에이전트를 다루는 개발자들에게 필수적인 도구가 되었습니다.

주요 요점:

- **쉬운 설정**: 간단한 pip 설치와 직관적인 API
- **멀티 에이전트 지원**: 서로 다른 에이전트 역할을 위한 격리된 환경
- **프레임워크 통합**: LangChain 및 기타 프레임워크와의 원활한 지원
- **웹 인터페이스**: 시각적 관리를 위한 아름다운 Vue.js 프론트엔드
- **프로덕션 준비**: RESTful API와 견고한 아키텍처

단일 AI 에이전트를 구축하든 복잡한 멀티 에이전트 시스템을 관리하든, MCPStore는 성공에 필요한 도구와 유연성을 제공합니다.

## 다음 단계

1. MCPStore를 설치하고 기본 예제를 시도해보세요
2. 웹 인터페이스와 API 엔드포인트를 탐색해보세요
3. 기존 AI 워크플로우와 통합해보세요
4. 커뮤니티에 참여하고 프로젝트에 기여해보세요

오늘 MCPStore 여정을 시작하고 MCP 서비스 관리의 미래를 경험해보세요!

---

*더 많은 튜토리얼과 AI 개발 리소스는 [Thaki Cloud](https://thakicloud.github.io)를 방문하세요.*


