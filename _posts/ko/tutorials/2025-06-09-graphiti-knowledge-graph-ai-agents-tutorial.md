---
title: "Graphiti로 AI 에이전트용 실시간 지식 그래프 구축하기"
date: 2025-06-09
categories: 
  - tutorials
  - ai
tags: 
  - graphiti
  - knowledge-graph
  - ai-agents
  - neo4j
  - rag
  - python
author_profile: true
toc: true
toc_label: "목차"
---

AI 에이전트의 메모리와 지식 관리는 점점 중요해지고 있습니다. 특히 실시간으로 변화하는 정보를 효과적으로 저장하고 검색할 수 있는 시스템이 필요합니다. Graphiti는 이러한 요구사항을 충족하는 실시간 지식 그래프 구축 도구로, AI 에이전트에게 강력한 메모리 시스템을 제공합니다.

## Graphiti란?

[Graphiti](https://github.com/getzep/graphiti)는 AI 에이전트를 위한 실시간 지식 그래프 구축 도구입니다. 기존의 GraphRAG와는 달리 동적이고 지속적으로 업데이트되는 데이터셋에 최적화되어 있습니다.

### 주요 특징

- **실시간 업데이트**: 배치 처리가 아닌 연속적이고 점진적인 업데이트 지원
- **고속 검색**: 일반적으로 1초 이하의 응답 시간 제공
- **시간적 추적**: 명시적인 이중 시간 추적으로 데이터 변화 관리
- **맞춤형 엔티티**: 사용자 정의 엔티티 타입 지원
- **높은 확장성**: 대용량 데이터셋에 최적화

## 설치 및 환경 설정

### 사전 요구사항

시작하기 전에 다음 요소들이 필요합니다:

- Python 3.10 이상
- Neo4j 5.26 이상
- OpenAI API 키

### Neo4j 설치

가장 간단한 방법은 Neo4j Desktop을 사용하는 것입니다:

1. [Neo4j Desktop](https://neo4j.com/download/) 다운로드 및 설치
2. 새 프로젝트 생성 후 데이터베이스 인스턴스 생성
3. 데이터베이스 시작 및 연결 정보 확인

### Graphiti 설치

```bash
# 기본 설치
pip install graphiti-core

# 또는 Poetry 사용
poetry add graphiti-core

# 추가 LLM 제공자와 함께 설치
pip install graphiti-core[anthropic,groq,google-genai]
```

### 환경 변수 설정

```bash
# .env 파일에 다음 내용 추가
OPENAI_API_KEY=your_openai_api_key_here
NEO4J_URI=bolt://localhost:7687
NEO4J_USERNAME=neo4j
NEO4J_PASSWORD=your_password_here

# 선택사항: 병렬 런타임 활성화 (Enterprise 버전만)
USE_PARALLEL_RUNTIME=true
```

## 기본 사용법

### 1. Graphiti 초기화

```python
import os
from graphiti_core import Graphiti

# 환경 변수에서 연결 정보 가져오기
neo4j_uri = os.getenv("NEO4J_URI", "bolt://localhost:7687")
neo4j_user = os.getenv("NEO4J_USERNAME", "neo4j")
neo4j_password = os.getenv("NEO4J_PASSWORD")

# Graphiti 인스턴스 생성
graphiti = Graphiti(
    uri=neo4j_uri,
    user=neo4j_user,
    password=neo4j_password
)

# 필요한 인덱스와 제약 조건 생성
await graphiti.build_indices_and_constraints()
```

### 2. 에피소드 추가

Graphiti에서 "에피소드"는 지식 그래프에 추가할 정보 단위입니다:

```python
import asyncio

async def add_knowledge():
    # 텍스트 에피소드 추가
    text_episode = """
    오늘 회의에서 김철수 팀장이 새로운 프로젝트 Alpha에 대해 발표했다.
    이 프로젝트는 AI 기반 추천 시스템을 개발하는 것으로, 
    예상 완료일은 2025년 8월이다. 
    개발팀은 이영희, 박민수, 정수진으로 구성되었다.
    """
    
    await graphiti.add_episode(
        name="meeting_notes_20250609",
        episode_body=text_episode,
        source_description="팀 회의 노트"
    )
    
    # 구조화된 JSON 에피소드 추가
    json_episode = {
        "project": "Alpha",
        "manager": "김철수",
        "team_members": ["이영희", "박민수", "정수진"],
        "deadline": "2025-08-01",
        "status": "시작됨",
        "technology": "AI 추천 시스템"
    }
    
    await graphiti.add_episode(
        name="project_alpha_info",
        episode_body=json_episode,
        source_description="프로젝트 정보"
    )

# 실행
asyncio.run(add_knowledge())
```

### 3. 지식 검색

#### 관계 검색 (Edge Search)

```python
async def search_relationships():
    # 프로젝트 관련 관계 검색
    results = await graphiti.search_edges(
        query="프로젝트 Alpha와 관련된 사람들",
        limit=10
    )
    
    for edge in results:
        print(f"관계: {edge.source_node_name} -> {edge.relation_type} -> {edge.target_node_name}")
        print(f"설명: {edge.summary}")
        print("---")

asyncio.run(search_relationships())
```

#### 노드 검색

```python
async def search_nodes():
    # 특정 인물 정보 검색
    results = await graphiti.search_nodes(
        query="김철수 팀장",
        limit=5
    )
    
    for node in results:
        print(f"노드: {node.name}")
        print(f"타입: {node.node_type}")
        print(f"설명: {node.summary}")
        print("---")

asyncio.run(search_nodes())
```

## 고급 활용법

### 1. 커스텀 엔티티 타입 사용

```python
from graphiti_core.nodes import NodeType
from graphiti_core.edges import EdgeType

# 커스텀 노드 타입 정의
class CustomNodeType(NodeType):
    EMPLOYEE = "Employee"
    PROJECT = "Project"
    DEPARTMENT = "Department"

# 커스텀 엣지 타입 정의
class CustomEdgeType(EdgeType):
    WORKS_ON = "works_on"
    MANAGES = "manages"
    BELONGS_TO = "belongs_to"

# 커스텀 타입으로 에피소드 추가
episode_with_custom_types = """
직원 김철수는 개발부에 속해 있으며, 프로젝트 Alpha를 관리한다.
이영희는 김철수가 관리하는 프로젝트 Alpha에서 작업한다.
"""

await graphiti.add_episode(
    name="custom_types_episode",
    episode_body=episode_with_custom_types,
    source_description="조직 구조 정보"
)
```

### 2. 시간적 쿼리 활용

```python
from datetime import datetime, timedelta

async def temporal_search():
    # 특정 시간 범위 내의 정보 검색
    start_time = datetime.now() - timedelta(days=7)
    end_time = datetime.now()
    
    results = await graphiti.search_edges(
        query="최근 프로젝트 업데이트",
        created_after=start_time,
        created_before=end_time,
        limit=10
    )
    
    print(f"지난 7일간 {len(results)}개의 관련 업데이트가 있었습니다.")

asyncio.run(temporal_search())
```

### 3. 그래프 거리 기반 재랭킹

```python
async def reranked_search():
    # 검색 결과를 그래프 거리 기반으로 재랭킹
    results = await graphiti.search_edges(
        query="프로젝트 팀원",
        limit=20,
        rerank=True  # 그래프 거리 기반 재랭킹 활성화
    )
    
    for i, edge in enumerate(results):
        print(f"{i+1}. {edge.source_node_name} -> {edge.target_node_name}")
        print(f"   관련성 점수: {edge.score}")

asyncio.run(reranked_search())
```

## 다른 LLM 제공자 사용

### Google Gemini 사용

```python
from graphiti_core.llm_client.gemini_client import GeminiClient, LLMConfig
from graphiti_core.embedder.gemini import GeminiEmbedder, GeminiEmbedderConfig

# Gemini를 사용한 Graphiti 설정
graphiti_gemini = Graphiti(
    uri="bolt://localhost:7687",
    user="neo4j",
    password="password",
    llm_client=GeminiClient(
        config=LLMConfig(
            api_key="your_google_api_key",
            model="gemini-2.0-flash"
        )
    ),
    embedder=GeminiEmbedder(
        config=GeminiEmbedderConfig(
            api_key="your_google_api_key",
            embedding_model="embedding-001"
        )
    )
)
```

### Azure OpenAI 사용

```python
from openai import AsyncAzureOpenAI
from graphiti_core.llm_client import LLMConfig, OpenAIClient
from graphiti_core.embedder.openai import OpenAIEmbedder, OpenAIEmbedderConfig

# Azure OpenAI 클라이언트 생성
azure_client = AsyncAzureOpenAI(
    api_key="your_azure_api_key",
    api_version="2023-12-01-preview",
    azure_endpoint="https://your-resource.openai.azure.com"
)

# Azure OpenAI를 사용한 Graphiti 설정
graphiti_azure = Graphiti(
    uri="bolt://localhost:7687",
    user="neo4j",
    password="password",
    llm_client=OpenAIClient(
        llm_config=LLMConfig(
            small_model="gpt-4-mini",
            model="gpt-4"
        ),
        client=azure_client
    ),
    embedder=OpenAIEmbedder(
        config=OpenAIEmbedderConfig(
            embedding_model="text-embedding-3-small"
        ),
        client=azure_client
    )
)
```

## REST API 서버 구축

Graphiti는 FastAPI 기반의 REST API 서버도 제공합니다:

```bash
# 서버 실행
cd server
python -m uvicorn main:app --reload --port 8000

# 또는 Docker 사용
docker-compose up
```

### API 사용 예시

```python
import requests

# 에피소드 추가
response = requests.post("http://localhost:8000/episodes/", json={
    "name": "api_test_episode",
    "episode_body": "API를 통해 추가된 테스트 에피소드입니다.",
    "source_description": "API 테스트"
})

# 검색
search_response = requests.get(
    "http://localhost:8000/search/edges",
    params={"query": "테스트", "limit": 5}
)

results = search_response.json()
print(f"검색 결과: {len(results)}개")
```

## MCP 서버 통합

Model Context Protocol (MCP) 서버를 통해 AI 어시스턴트와 통합할 수 있습니다:

```bash
# MCP 서버 실행
cd mcp_server
python -m mcp_server.main

# Docker로 실행
docker run -p 8080:8080 graphiti-mcp-server
```

## 성능 최적화 팁

### 1. 인덱싱 최적화

```python
# 사용자 정의 인덱스 생성
await graphiti.build_indices_and_constraints()

# 주기적인 인덱스 재구축
await graphiti.rebuild_indices()
```

### 2. 배치 처리

```python
# 여러 에피소드 일괄 추가
episodes = [
    {"name": "ep1", "episode_body": "첫 번째 에피소드", "source_description": "배치1"},
    {"name": "ep2", "episode_body": "두 번째 에피소드", "source_description": "배치1"},
    {"name": "ep3", "episode_body": "세 번째 에피소드", "source_description": "배치1"},
]

for episode in episodes:
    await graphiti.add_episode(**episode)
```

### 3. 검색 최적화

```python
# 검색 범위 제한으로 성능 향상
results = await graphiti.search_edges(
    query="특정 주제",
    limit=5,  # 결과 수 제한
    node_types=["Person", "Project"],  # 특정 노드 타입만 검색
    created_after=datetime.now() - timedelta(days=30)  # 시간 범위 제한
)
```

## 실제 활용 사례

### 1. 고객 지원 챗봇

```python
class CustomerSupportBot:
    def __init__(self):
        self.graphiti = Graphiti(
            uri="bolt://localhost:7687",
            user="neo4j",
            password="password"
        )
    
    async def handle_customer_query(self, customer_id: str, query: str):
        # 고객 히스토리 검색
        history = await self.graphiti.search_edges(
            query=f"고객 {customer_id} 관련 이슈",
            limit=10
        )
        
        # 관련 해결책 검색
        solutions = await self.graphiti.search_nodes(
            query=query + " 해결방법",
            limit=5
        )
        
        return {
            "history": history,
            "suggested_solutions": solutions
        }
```

### 2. 연구 논문 관리 시스템

```python
class ResearchPaperManager:
    def __init__(self):
        self.graphiti = Graphiti(
            uri="bolt://localhost:7687",
            user="neo4j", 
            password="password"
        )
    
    async def add_paper(self, title: str, authors: list, abstract: str, keywords: list):
        paper_info = {
            "title": title,
            "authors": authors,
            "abstract": abstract,
            "keywords": keywords,
            "added_date": datetime.now().isoformat()
        }
        
        await self.graphiti.add_episode(
            name=f"paper_{title.replace(' ', '_')}",
            episode_body=paper_info,
            source_description="연구 논문 데이터베이스"
        )
    
    async def find_related_papers(self, topic: str):
        return await self.graphiti.search_edges(
            query=f"{topic} 관련 논문",
            limit=20
        )
```

## 문제 해결

### 일반적인 문제들

1. **Neo4j 연결 오류**

   ```python
   # 연결 테스트
   try:
       await graphiti.health_check()
       print("Neo4j 연결 성공")
   except Exception as e:
       print(f"연결 실패: {e}")
   ```

2. **OpenAI API 한도 초과**

   ```python
   # API 호출 제한 설정
   import time
   
   async def add_episodes_with_delay(episodes):
       for episode in episodes:
           await graphiti.add_episode(**episode)
           time.sleep(1)  # 1초 대기
   ```

3. **메모리 사용량 최적화**

   ```python
   # 주기적으로 연결 정리
   await graphiti.close()
   ```

## 모니터링 및 유지보수

### 그래프 상태 확인

```python
async def check_graph_status():
    # 노드 수 확인
    node_count = await graphiti.get_node_count()
    print(f"총 노드 수: {node_count}")
    
    # 엣지 수 확인
    edge_count = await graphiti.get_edge_count()
    print(f"총 엣지 수: {edge_count}")
    
    # 최근 업데이트 확인
    recent_episodes = await graphiti.get_recent_episodes(limit=10)
    print(f"최근 에피소드 수: {len(recent_episodes)}")
```

### 정기적인 유지보수

```python
async def maintenance_routine():
    # 오래된 노드 정리 (선택사항)
    cutoff_date = datetime.now() - timedelta(days=365)
    await graphiti.cleanup_old_nodes(before_date=cutoff_date)
    
    # 인덱스 최적화
    await graphiti.optimize_indices()
    
    # 통계 업데이트
    await graphiti.update_graph_statistics()
```

## 결론

Graphiti는 AI 에이전트에게 강력한 메모리 시스템을 제공하는 혁신적인 도구입니다. 실시간 업데이트, 고속 검색, 시간적 추적 등의 특징으로 기존의 GraphRAG 시스템을 뛰어넘는 성능을 제공합니다.

이 튜토리얼에서 다룬 내용들을 바탕으로 자신만의 지식 그래프 시스템을 구축해보세요. Graphiti의 유연성과 확장성을 활용하면 다양한 AI 애플리케이션에서 뛰어난 성능을 얻을 수 있을 것입니다.

---

**참고 링크:**

- [Graphiti GitHub 저장소](https://github.com/getzep/graphiti)
- [Graphiti 공식 문서](https://help.getzep.com/graphiti)
- [Neo4j Desktop 다운로드](https://neo4j.com/download/)
- [OpenAI API 문서](https://platform.openai.com/docs)
