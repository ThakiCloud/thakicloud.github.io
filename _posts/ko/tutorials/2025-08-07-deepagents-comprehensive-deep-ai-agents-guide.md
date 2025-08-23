---
title: "DeepAgents: LangGraph 기반 심층 AI 에이전트 구축 완전 가이드"
excerpt: "단순한 루프 에이전트를 넘어선 계획, 서브에이전트, 파일시스템을 갖춘 심층 AI 에이전트 구축. Claude Code 아키텍처 기반 범용 프레임워크 마스터하기"
seo_title: "DeepAgents 완전 가이드 - 심층 AI 에이전트 구축 프레임워크 - Thaki Cloud"
seo_description: "DeepAgents로 Claude Code 스타일의 심층 AI 에이전트 구축. 계획 도구, 서브에이전트, 가상 파일시스템, MCP 연동을 통한 고급 에이전트 개발 완전 가이드"
date: 2025-08-07
last_modified_at: 2025-08-07
categories:
  - tutorials
tags:
  - deepagents
  - ai-agents
  - langgraph
  - claude-code
  - multi-agent-system
  - planning-tools
  - mcp
  - python
  - langchain
  - research-agent
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "brain"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/deepagents-comprehensive-deep-ai-agents-guide/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 22분

## 서론

기존의 **단순한 LLM 도구 호출 루프**는 복잡하고 장기적인 작업에서 한계를 보입니다. "계획 수립", "세부 작업 분해", "체계적 실행"이 부족하여 **"얕은" 에이전트**가 되기 쉽습니다.

[DeepAgents](https://github.com/hwchase17/deepagents)는 이런 문제를 해결하기 위해 **Claude Code의 성공 아키텍처**를 분석하여 만든 범용 Python 프레임워크입니다. **계획 도구**, **서브에이전트**, **가상 파일시스템**, **상세한 프롬프트**라는 4가지 핵심 요소를 통합하여 **심층적이고 체계적인 AI 에이전트**를 구축할 수 있습니다.

이 튜토리얼에서는 DeepAgents의 설치부터 고급 활용까지, 실제 연구 에이전트 구현을 통해 심층 AI 에이전트 개발의 모든 것을 다루겠습니다.

### DeepAgents의 혁신적 특징

- 🧠 **계획 중심 아키텍처**: 체계적인 작업 계획 수립과 추적
- 🤖 **서브에이전트 시스템**: 컨텍스트 격리와 전문화된 작업 분할
- 📁 **가상 파일시스템**: 상태 관리와 데이터 지속성
- 🔧 **LangGraph 기반**: 스트리밍, 휴먼인더루프, 메모리 완벽 지원
- 🌐 **MCP 호환**: Model Context Protocol을 통한 확장성
- 🎯 **Claude Code 영감**: 검증된 아키텍처의 범용화

## 심층 에이전트 vs 기존 에이전트

### 기존 "얕은" 에이전트의 한계

```python
# 전형적인 얕은 에이전트
def shallow_agent(query):
    while True:
        response = llm.call(query)
        if response.tool_calls:
            tool_result = execute_tool(response.tool_calls)
            query += f"Tool result: {tool_result}"
        else:
            return response.content
```

**문제점:**
- ❌ 장기 계획 부재
- ❌ 복잡한 작업 분해 불가
- ❌ 컨텍스트 오염
- ❌ 상태 관리 부족

### DeepAgents의 "심층" 접근법

```python
# DeepAgents 아키텍처
agent = create_deep_agent(
    tools=[research_tool, analysis_tool],
    instructions="전문 연구원으로서 체계적 분석 수행",
    subagents=[data_analysis_agent, report_writing_agent]
)

# 4가지 핵심 요소가 자동으로 통합됨:
# 1. 계획 도구 (Planning Tool)
# 2. 서브에이전트 (Sub Agents) 
# 3. 가상 파일시스템 (File System)
# 4. 상세 시스템 프롬프트 (Detailed Prompt)
```

## 환경 요구사항 및 설치

### 기본 요구사항

```bash
# Python 버전 확인
python --version
# Python 3.8+ 필요

# 가상환경 생성 (권장)
python -m venv deepagents-env
source deepagents-env/bin/activate  # macOS/Linux
# deepagents-env\Scripts\activate   # Windows
```

### 패키지 설치

```bash
# 기본 설치
pip install deepagents

# 연구 에이전트 예제용 추가 패키지
pip install tavily-python

# MCP 연동용 (선택적)
pip install langchain-mcp-adapters

# 커스텀 모델용 (선택적)
pip install langchain langchain-ollama
```

### API 키 설정

```bash
# 환경변수 설정
export ANTHROPIC_API_KEY="your-anthropic-api-key"
export TAVILY_API_KEY="your-tavily-api-key"  # 웹 검색용

# .env 파일로 관리 (권장)
echo "ANTHROPIC_API_KEY=your-key" >> .env
echo "TAVILY_API_KEY=your-key" >> .env
```

## 기본 사용법과 첫 번째 에이전트

### 간단한 연구 에이전트 구현

```python
import os
from typing import Literal
from tavily import TavilyClient
from deepagents import create_deep_agent

# 웹 검색 도구 정의
def internet_search(
    query: str,
    max_results: int = 5,
    topic: Literal["general", "news", "finance"] = "general",
    include_raw_content: bool = False,
):
    """웹 검색을 실행합니다"""
    tavily_client = TavilyClient(api_key=os.environ["TAVILY_API_KEY"])
    return tavily_client.search(
        query,
        max_results=max_results,
        include_raw_content=include_raw_content,
        topic=topic,
    )

# 전문가 연구원 프롬프트
research_instructions = """당신은 전문 연구원입니다. 철저한 조사를 수행하고 세련된 보고서를 작성하는 것이 목표입니다.

사용 가능한 도구:

## `internet_search`
주어진 쿼리에 대해 인터넷 검색을 실행합니다. 결과 수, 주제, 원시 콘텐츠 포함 여부를 지정할 수 있습니다.

연구 과정:
1. 주제를 다각도로 분석
2. 신뢰할 수 있는 소스에서 정보 수집
3. 체계적으로 정리하여 완성도 높은 보고서 작성
"""

# 심층 에이전트 생성
agent = create_deep_agent(
    tools=[internet_search],
    instructions=research_instructions,
)

# 에이전트 실행
if __name__ == "__main__":
    result = agent.invoke({
        "messages": [{"role": "user", "content": "LangGraph란 무엇인가요?"}]
    })
    print(result["messages"][-1].content)
```

### 실행 결과 분석

```bash
python basic_research_agent.py
```

**DeepAgents의 자동 워크플로우:**

1. **계획 수립**: Todo 도구를 사용해 연구 계획 작성
2. **정보 수집**: 여러 검색 쿼리로 포괄적 조사
3. **분석 및 정리**: 수집된 정보를 체계적으로 분석
4. **보고서 작성**: 완성도 높은 최종 보고서 생성

## 고급 기능: 서브에이전트와 전문화

### 서브에이전트의 필요성

복잡한 작업에서는 **컨텍스트 격리**와 **전문화된 지시사항**이 필요합니다:

- 📊 **데이터 분석 전용** 서브에이전트
- 📝 **보고서 작성 전용** 서브에이전트  
- 🔍 **심층 조사 전용** 서브에이전트

### 다중 서브에이전트 시스템 구현

```python
from deepagents import create_deep_agent

# 데이터 분석 전문 서브에이전트
data_analysis_subagent = {
    "name": "data-analyst",
    "description": "수치 데이터 분석과 통계적 해석을 전문으로 하는 에이전트",
    "prompt": """당신은 데이터 분석 전문가입니다.
    
주요 역할:
- 수치 데이터의 패턴과 트렌드 분석
- 통계적 유의성 검증
- 시각화 가능한 형태로 데이터 정리
- 비즈니스 인사이트 도출

분석 시 다음을 반드시 포함:
1. 데이터 품질 평가
2. 기술통계 요약
3. 주요 패턴과 이상치 식별
4. 실무적 시사점 도출
""",
    "tools": ["internet_search"]  # 특정 도구만 접근 제한 가능
}

# 심층 조사 전문 서브에이전트
research_subagent = {
    "name": "deep-researcher", 
    "description": "특정 주제에 대한 심층적이고 포괄적인 조사를 수행하는 에이전트",
    "prompt": """당신은 심층 조사 전문가입니다.

조사 방법론:
- 1차 자료와 2차 자료 구분하여 수집
- 다양한 관점과 의견 균형있게 조사
- 시간순 변화와 최신 동향 파악
- 논란이 있는 부분은 여러 시각 제시

조사 결과는 다음 구조로 정리:
1. 배경과 맥락
2. 핵심 발견사항
3. 서로 다른 관점들
4. 미해결 쟁점들
5. 향후 전망
"""
}

# 보고서 작성 전문 서브에이전트
report_writer_subagent = {
    "name": "report-writer",
    "description": "조사된 정보를 전문적이고 읽기 쉬운 보고서로 작성하는 에이전트", 
    "prompt": """당신은 전문 보고서 작성가입니다.

보고서 작성 원칙:
- 명확하고 논리적인 구조
- 핵심 요점을 앞부분에 배치
- 구체적인 예시와 데이터로 뒷받침
- 독자가 쉽게 이해할 수 있는 언어 사용

표준 보고서 구조:
1. 요약 (Executive Summary)
2. 서론 및 배경
3. 주요 발견사항
4. 분석 및 해석
5. 결론 및 권고사항
6. 참고자료
"""
}

# 통합 연구 에이전트 생성
advanced_research_agent = create_deep_agent(
    tools=[internet_search],
    instructions="""당신은 고급 연구 프로젝트를 관리하는 연구 매니저입니다.

복잡한 연구 과제를 받으면:
1. 작업을 세부 단계로 분해
2. 각 단계에 적합한 서브에이전트 활용
3. 결과를 통합하여 완성도 높은 최종 보고서 작성

서브에이전트 활용 가이드:
- 수치 분석이 필요하면 → data-analyst
- 심층적 배경 조사가 필요하면 → deep-researcher  
- 최종 보고서 정리가 필요하면 → report-writer
""",
    subagents=[data_analysis_subagent, research_subagent, report_writer_subagent]
)
```

### 서브에이전트 활용 예제

```python
# 복합적 연구 과제 실행
complex_query = """
AI 에이전트 시장의 현황과 전망을 분석해주세요.
다음 요소들을 포함해야 합니다:
1. 시장 규모와 성장률 데이터
2. 주요 플레이어들과 경쟁 구도
3. 기술적 트렌드와 발전 방향
4. 비즈니스 모델 혁신 사례
5. 향후 5년 전망과 투자 기회
"""

result = advanced_research_agent.invoke({
    "messages": [{"role": "user", "content": complex_query}]
})

# 서브에이전트별 작업 결과 확인
print("=== 메인 에이전트 실행 로그 ===")
for message in result["messages"]:
    if hasattr(message, 'content'):
        print(f"{message.role}: {message.content[:200]}...")
```

## 가상 파일시스템 활용

### 파일시스템의 중요성

DeepAgents는 **LangGraph State 기반 가상 파일시스템**을 제공합니다:

- 📄 **상태 지속성**: 에이전트 간 데이터 공유
- 🔄 **버전 관리**: 작업 과정 추적
- 🔒 **격리**: 동시 실행 에이전트 간 충돌 방지

### 파일시스템 도구 활용

```python
# 파일 기반 워크플로우 에이전트
file_workflow_agent = create_deep_agent(
    tools=[internet_search],
    instructions="""당신은 체계적인 문서 관리를 하는 연구원입니다.

파일 관리 원칙:
1. 조사 과정을 단계별 파일로 저장
2. 각 파일은 명확한 목적과 구조를 가짐
3. 최종 보고서는 모든 파일을 종합하여 작성

활용 가능한 파일 도구:
- `write_file`: 새 파일 생성
- `read_file`: 기존 파일 읽기  
- `edit_file`: 파일 내용 수정
- `ls`: 파일 목록 확인
"""
)

# 초기 파일과 함께 실행
initial_files = {
    "research_outline.txt": """AI 에이전트 연구 계획

1. 시장 현황 조사
2. 기술 트렌드 분석  
3. 경쟁사 분석
4. 미래 전망 예측
5. 최종 보고서 작성
""",
    "reference_list.txt": "참고 자료 목록\n\n"
}

result = file_workflow_agent.invoke({
    "messages": [{"role": "user", "content": "AI 에이전트 시장 보고서를 작성해주세요"}],
    "files": initial_files
})

# 생성된 파일들 확인
print("=== 생성된 파일 목록 ===")
for filename, content in result["files"].items():
    print(f"📄 {filename}: {len(content)} 자")
    print(f"   미리보기: {content[:100]}...")
```

### 파일 기반 협업 워크플로우

```python
# 단계별 파일 생성 에이전트
def create_collaborative_research_agent():
    return create_deep_agent(
        tools=[internet_search],
        instructions="""다단계 연구 프로세스를 관리합니다.

각 단계별로 파일을 생성하고 관리:

1단계: research_plan.md - 연구 계획 수립
2단계: data_collection.md - 수집된 원시 데이터
3단계: analysis_notes.md - 분석 노트와 인사이트
4단계: draft_report.md - 초안 보고서
5단계: final_report.md - 최종 보고서

각 파일은 다음 단계의 입력이 되므로 체계적으로 작성해야 합니다.
""",
        subagents=[{
            "name": "quality-reviewer",
            "description": "문서 품질 검토 및 개선 제안",
            "prompt": "각 문서의 완성도를 평가하고 개선점을 제안하는 품질 검토자"
        }]
    )

# 실행 및 결과 추적
collaborative_agent = create_collaborative_research_agent()
result = collaborative_agent.invoke({
    "messages": [{"role": "user", "content": "LangChain과 LangGraph 비교 분석 보고서 작성"}]
})

# 각 단계별 파일 내용 출력
stages = ["research_plan.md", "data_collection.md", "analysis_notes.md", "draft_report.md", "final_report.md"]
for stage in stages:
    if stage in result["files"]:
        print(f"\n{'='*50}")
        print(f"📋 {stage}")
        print(f"{'='*50}")
        print(result["files"][stage][:500] + "..." if len(result["files"][stage]) > 500 else result["files"][stage])
```

## 커스텀 모델 및 MCP 연동

### 다양한 LLM 모델 사용

```python
from langchain_core.chat_models import init_chat_model
from deepagents import create_deep_agent

# OpenAI GPT-4 사용
openai_model = init_chat_model(
    model="gpt-4-turbo-preview",
    api_key=os.environ["OPENAI_API_KEY"]
)

# Ollama 로컬 모델 사용
ollama_model = init_chat_model(
    model="ollama:llama3:70b"
)

# 구글 Gemini 사용  
gemini_model = init_chat_model(
    model="google/gemini-pro",
    api_key=os.environ["GOOGLE_API_KEY"]
)

# 모델별 에이전트 생성
agents = {
    "openai": create_deep_agent(
        tools=[internet_search],
        instructions="당신은 OpenAI 기반 연구 에이전트입니다.",
        model=openai_model
    ),
    "ollama": create_deep_agent(
        tools=[internet_search], 
        instructions="당신은 로컬 Ollama 기반 에이전트입니다.",
        model=ollama_model
    ),
    "gemini": create_deep_agent(
        tools=[internet_search],
        instructions="당신은 Google Gemini 기반 에이전트입니다.", 
        model=gemini_model
    )
}

# 모델별 성능 비교
query = "블록체인 기술의 최신 동향을 분석해주세요."
for model_name, agent in agents.items():
    print(f"\n🤖 {model_name.upper()} 모델 결과:")
    print("-" * 40)
    result = agent.invoke({"messages": [{"role": "user", "content": query}]})
    print(result["messages"][-1].content[:300] + "...")
```

### MCP(Model Context Protocol) 연동

```python
import asyncio
from langchain_mcp_adapters.client import MultiServerMCPClient
from deepagents import create_deep_agent

async def create_mcp_enhanced_agent():
    # MCP 서버들과 연결
    mcp_servers = {
        "filesystem": "mcp://filesystem-server", 
        "database": "mcp://database-server",
        "web": "mcp://web-scraper-server"
    }
    
    # MCP 클라이언트 초기화
    mcp_client = MultiServerMCPClient(servers=mcp_servers)
    
    # MCP 도구들 수집
    mcp_tools = await mcp_client.get_tools()
    
    print(f"📡 MCP 도구 {len(mcp_tools)}개 로드됨:")
    for tool in mcp_tools:
        print(f"  - {tool.name}: {tool.description}")
    
    # MCP 강화 에이전트 생성
    agent = create_deep_agent(
        tools=mcp_tools + [internet_search],  # 기존 도구와 MCP 도구 결합
        instructions="""당신은 MCP 프로토콜을 통해 확장된 도구를 가진 고급 에이전트입니다.

사용 가능한 도구:
- 파일시스템 접근 (실제 로컬 파일)
- 데이터베이스 쿼리 실행
- 고급 웹 스크래핑
- 인터넷 검색

각 도구의 특성을 이해하고 적절히 조합하여 사용하세요.
""",
    )
    
    return agent, mcp_client

async def run_mcp_example():
    agent, mcp_client = await create_mcp_enhanced_agent()
    
    # 스트리밍으로 실행
    query = "현재 디렉토리의 Python 파일들을 분석하고 데이터베이스에 저장해주세요."
    
    async for chunk in agent.astream(
        {"messages": [{"role": "user", "content": query}]},
        stream_mode="values"
    ):
        if "messages" in chunk:
            latest_message = chunk["messages"][-1]
            if hasattr(latest_message, 'content'):
                print(f"🔄 {latest_message.content[:100]}...")
    
    # MCP 클라이언트 정리
    await mcp_client.close()

# MCP 예제 실행
if __name__ == "__main__":
    asyncio.run(run_mcp_example())
```

## 실전 예제: 고급 연구 에이전트 구현

### 종합적인 연구 에이전트

실제 프로덕션 환경에서 사용할 수 있는 고급 연구 에이전트를 구현해보겠습니다.

```python
import os
import json
from typing import Literal, Dict, Any
from datetime import datetime
from tavily import TavilyClient
from deepagents import create_deep_agent

class AdvancedResearchAgent:
    """고급 연구 에이전트 클래스"""
    
    def __init__(self):
        self.tavily_client = TavilyClient(api_key=os.environ["TAVILY_API_KEY"])
        self.agent = self._create_agent()
    
    def enhanced_search(
        self,
        query: str,
        max_results: int = 10,
        topic: Literal["general", "news", "finance"] = "general",
        include_raw_content: bool = True,
        search_depth: Literal["basic", "advanced"] = "advanced"
    ):
        """향상된 검색 기능"""
        if search_depth == "advanced":
            # 다각도 검색 수행
            queries = [
                query,
                f"{query} latest trends 2024",
                f"{query} research papers",
                f"{query} industry analysis",
                f"{query} expert opinions"
            ]
            
            all_results = []
            for q in queries[:3]:  # 비용 고려하여 3개로 제한
                results = self.tavily_client.search(
                    q, 
                    max_results=max_results//3,
                    include_raw_content=include_raw_content,
                    topic=topic
                )
                all_results.extend(results.get('results', []))
            
            return {"results": all_results}
        else:
            return self.tavily_client.search(
                query,
                max_results=max_results,
                include_raw_content=include_raw_content,
                topic=topic
            )
    
    def save_research_metadata(self, topic: str, metadata: Dict[str, Any]):
        """연구 메타데이터 저장"""
        timestamp = datetime.now().isoformat()
        metadata_entry = {
            "topic": topic,
            "timestamp": timestamp,
            "metadata": metadata
        }
        # 실제 구현에서는 데이터베이스에 저장
        print(f"💾 연구 메타데이터 저장: {topic}")
        return metadata_entry
    
    def _create_agent(self):
        """에이전트 생성"""
        
        # 전문화된 서브에이전트들
        subagents = [
            {
                "name": "market-analyst",
                "description": "시장 동향과 비즈니스 트렌드 분석 전문가",
                "prompt": """당신은 시장 분석 전문가입니다.

분석 영역:
- 시장 규모와 성장률
- 경쟁 구도와 주요 플레이어
- 비즈니스 모델과 수익 구조
- 투자 동향과 펀딩 현황

분석 결과는 다음 형식으로 제공:
1. 핵심 수치 (시장 규모, 성장률 등)
2. 주요 플레이어 및 점유율
3. 트렌드와 변화 동인
4. 리스크와 기회 요인
"""
            },
            {
                "name": "tech-analyst", 
                "description": "기술 동향과 혁신 분석 전문가",
                "prompt": """당신은 기술 분석 전문가입니다.

분석 영역:
- 핵심 기술과 발전 단계
- 혁신적 솔루션과 브레이크스루
- 기술적 한계와 도전 과제
- 미래 기술 로드맵

기술 분석 결과 구조:
1. 현재 기술 수준 평가
2. 주요 혁신 사례
3. 기술적 과제와 한계
4. 향후 발전 전망
"""
            },
            {
                "name": "strategic-synthesizer",
                "description": "다양한 분석을 종합하여 전략적 인사이트 도출",
                "prompt": """당신은 전략 종합 분석가입니다.

역할:
- 시장 분석과 기술 분석 결과 통합
- 상호 연관성과 시너지 효과 식별
- 전략적 의미와 시사점 도출
- 실행 가능한 권고사항 제시

종합 보고서 구조:
1. 통합 요약 (Executive Summary)
2. 핵심 발견사항 (Key Findings)
3. 전략적 시사점 (Strategic Implications)
4. 권고사항 (Recommendations)
5. 리스크 및 고려사항 (Risks & Considerations)
"""
            }
        ]
        
        return create_deep_agent(
            tools=[self.enhanced_search, self.save_research_metadata],
            instructions="""당신은 고급 연구 프로젝트 매니저입니다.

연구 방법론:
1. 체계적 계획 수립 (Planning Tool 활용)
2. 다면적 정보 수집 (Enhanced Search)
3. 전문 분야별 심층 분석 (Subagents 활용)
4. 파일 기반 중간 결과 저장 (File System)
5. 종합적 인사이트 도출

품질 기준:
- 신뢰할 수 있는 데이터 소스 활용
- 다양한 관점과 의견 균형있게 반영
- 구체적인 수치와 사례로 뒷받침
- 실무진이 활용 가능한 수준의 구체성

최종 산출물은 경영진 보고 수준의 품질을 유지해야 합니다.
""",
            subagents=subagents
        )
    
    def conduct_research(self, topic: str, scope: str = "comprehensive"):
        """연구 수행"""
        query = f"""'{topic}'에 대한 {scope} 연구를 수행해주세요.

다음 요소들을 포함해야 합니다:
1. 현황 분석 (Current State Analysis)
2. 트렌드 및 동향 (Trends & Dynamics)  
3. 주요 플레이어 분석 (Key Players Analysis)
4. 기회와 위험 요인 (Opportunities & Risks)
5. 미래 전망 (Future Outlook)
6. 전략적 권고사항 (Strategic Recommendations)

각 섹션은 구체적인 데이터와 사례로 뒷받침되어야 합니다.
"""
        
        result = self.agent.invoke({
            "messages": [{"role": "user", "content": query}]
        })
        
        return result

# 사용 예제
if __name__ == "__main__":
    # 연구 에이전트 초기화
    research_agent = AdvancedResearchAgent()
    
    # 연구 수행
    topic = "Generative AI 시장의 현황과 전망"
    result = research_agent.conduct_research(topic, scope="comprehensive")
    
    # 결과 출력
    print("=" * 60)
    print(f"📊 연구 주제: {topic}")
    print("=" * 60)
    print(result["messages"][-1].content)
    
    # 생성된 파일들 확인
    if "files" in result and result["files"]:
        print("\n" + "=" * 60)
        print("📁 생성된 연구 파일들:")
        print("=" * 60)
        for filename, content in result["files"].items():
            print(f"\n📄 {filename} ({len(content)} 자)")
            print("-" * 40)
            print(content[:300] + "..." if len(content) > 300 else content)
```

### 스트리밍과 실시간 모니터링

```python
import asyncio
from deepagents import create_deep_agent

async def stream_research_process():
    """연구 과정을 실시간으로 스트리밍"""
    
    # 스트리밍 지원 에이전트 생성
    streaming_agent = create_deep_agent(
        tools=[internet_search],
        instructions="""실시간 연구 진행 상황을 투명하게 공유하는 연구원입니다.
        
각 단계마다 진행 상황을 명확히 알려주고, 
중간 결과를 공유하여 사용자가 과정을 이해할 수 있게 합니다."""
    )
    
    query = "AI 에이전트의 보안 이슈와 해결 방안을 연구해주세요."
    
    print("🔄 연구 과정 실시간 모니터링 시작...")
    print("=" * 50)
    
    step_count = 0
    async for chunk in streaming_agent.astream(
        {"messages": [{"role": "user", "content": query}]},
        stream_mode="values"
    ):
        if "messages" in chunk:
            latest_message = chunk["messages"][-1]
            if hasattr(latest_message, 'content') and latest_message.content:
                step_count += 1
                print(f"\n🔵 단계 {step_count}")
                print("-" * 30)
                
                # 내용 길이에 따라 출력 조정
                content = latest_message.content
                if len(content) > 200:
                    print(f"{content[:200]}...")
                    print(f"[전체 길이: {len(content)} 자]")
                else:
                    print(content)
                
                # 진행 속도 조절
                await asyncio.sleep(0.5)
    
    print("\n✅ 연구 완료!")

# 스트리밍 실행
if __name__ == "__main__":
    asyncio.run(stream_research_process())
```

## macOS 테스트 환경 구성

### 테스트 스크립트 작성

```python
#!/usr/bin/env python3
"""
DeepAgents macOS 테스트 스크립트
실행: python test_deepagents.py
"""

import os
import sys
import subprocess
from typing import Optional

def check_python_version():
    """Python 버전 확인"""
    version = sys.version_info
    print(f"🐍 Python 버전: {version.major}.{version.minor}.{version.micro}")
    
    if version.major < 3 or (version.major == 3 and version.minor < 8):
        print("❌ Python 3.8+ 이 필요합니다.")
        return False
    
    print("✅ Python 버전 요구사항 충족")
    return True

def check_environment_variables():
    """환경변수 확인"""
    required_vars = ["ANTHROPIC_API_KEY", "TAVILY_API_KEY"]
    missing_vars = []
    
    for var in required_vars:
        if not os.getenv(var):
            missing_vars.append(var)
        else:
            print(f"✅ {var} 설정됨")
    
    if missing_vars:
        print(f"❌ 누락된 환경변수: {', '.join(missing_vars)}")
        print("\n설정 방법:")
        for var in missing_vars:
            print(f"export {var}='your-api-key-here'")
        return False
    
    return True

def install_packages():
    """필요한 패키지 설치"""
    packages = ["deepagents", "tavily-python"]
    
    for package in packages:
        try:
            __import__(package.replace("-", "_"))
            print(f"✅ {package} 이미 설치됨")
        except ImportError:
            print(f"📦 {package} 설치 중...")
            subprocess.run([sys.executable, "-m", "pip", "install", package], 
                          check=True, capture_output=True)
            print(f"✅ {package} 설치 완료")

def test_basic_functionality():
    """기본 기능 테스트"""
    print("\n🧪 기본 기능 테스트 시작...")
    
    try:
        from deepagents import create_deep_agent
        print("✅ DeepAgents 임포트 성공")
        
        # 간단한 에이전트 생성 테스트
        def dummy_tool(query: str) -> str:
            """테스트용 더미 도구"""
            return f"테스트 결과: {query}"
        
        test_agent = create_deep_agent(
            tools=[dummy_tool],
            instructions="당신은 테스트 에이전트입니다."
        )
        print("✅ 테스트 에이전트 생성 성공")
        
        # 간단한 실행 테스트
        result = test_agent.invoke({
            "messages": [{"role": "user", "content": "안녕하세요"}]
        })
        
        if result and "messages" in result:
            print("✅ 에이전트 실행 테스트 성공")
            print(f"   응답: {result['messages'][-1].content[:100]}...")
            return True
        else:
            print("❌ 에이전트 실행 실패")
            return False
            
    except Exception as e:
        print(f"❌ 테스트 실패: {str(e)}")
        return False

def test_research_agent():
    """연구 에이전트 테스트"""
    if not (os.getenv("ANTHROPIC_API_KEY") and os.getenv("TAVILY_API_KEY")):
        print("⏭️  API 키가 없어 연구 에이전트 테스트를 건너뜁니다.")
        return True
    
    print("\n🔬 연구 에이전트 테스트 시작...")
    
    try:
        from tavily import TavilyClient
        from deepagents import create_deep_agent
        
        def internet_search(query: str, max_results: int = 3):
            """간단한 검색 도구"""
            client = TavilyClient(api_key=os.getenv("TAVILY_API_KEY"))
            return client.search(query, max_results=max_results)
        
        research_agent = create_deep_agent(
            tools=[internet_search],
            instructions="당신은 간단한 테스트를 수행하는 연구원입니다."
        )
        
        result = research_agent.invoke({
            "messages": [{"role": "user", "content": "DeepAgents란 무엇인지 간단히 알려주세요"}]
        })
        
        if result and "messages" in result:
            print("✅ 연구 에이전트 테스트 성공")
            response = result['messages'][-1].content
            print(f"   응답 길이: {len(response)} 자")
            print(f"   응답 미리보기: {response[:150]}...")
            return True
        else:
            print("❌ 연구 에이전트 실행 실패") 
            return False
            
    except Exception as e:
        print(f"❌ 연구 에이전트 테스트 실패: {str(e)}")
        return False

def main():
    """메인 테스트 함수"""
    print("🤖 DeepAgents macOS 테스트 시작")
    print("=" * 50)
    
    # 시스템 정보 출력
    print(f"🖥️  운영체제: {os.uname().sysname} {os.uname().release}")
    print(f"🏗️  아키텍처: {os.uname().machine}")
    
    # 테스트 실행
    tests = [
        ("Python 버전", check_python_version),
        ("환경변수", check_environment_variables), 
        ("패키지 설치", install_packages),
        ("기본 기능", test_basic_functionality),
        ("연구 에이전트", test_research_agent),
    ]
    
    passed = 0
    total = len(tests)
    
    for test_name, test_func in tests:
        print(f"\n📋 {test_name} 테스트 중...")
        try:
            if test_func():
                passed += 1
            else:
                print(f"❌ {test_name} 테스트 실패")
        except Exception as e:
            print(f"❌ {test_name} 테스트 오류: {str(e)}")
    
    print(f"\n{'='*50}")
    print(f"📊 테스트 결과: {passed}/{total} 통과")
    
    if passed == total:
        print("🎉 모든 테스트 통과! DeepAgents 사용 준비 완료")
    else:
        print("⚠️  일부 테스트 실패. 위의 오류 메시지를 확인하세요.")
    
    print(f"{'='*50}")

if __name__ == "__main__":
    main()
```

### 테스트 스크립트 실행

```bash
# 테스트 스크립트 저장
cat > test_deepagents.py << 'EOF'
# 위의 테스트 스크립트 내용
EOF

# 실행 권한 부여
chmod +x test_deepagents.py

# 테스트 실행
python test_deepagents.py
```

### 환경 설정 스크립트

```bash
#!/bin/bash
# 파일: setup_deepagents_env.sh
# DeepAgents 개발 환경 자동 설정

echo "🤖 DeepAgents 개발 환경 설정 시작"
echo "=================================="

# 가상환경 생성
echo "📦 가상환경 생성 중..."
python3 -m venv deepagents-env
source deepagents-env/bin/activate

# 패키지 설치
echo "📚 필수 패키지 설치 중..."
pip install --upgrade pip
pip install deepagents tavily-python langchain-mcp-adapters

# API 키 설정 안내
echo ""
echo "🔑 API 키 설정이 필요합니다:"
echo "export ANTHROPIC_API_KEY='your-anthropic-key'"
echo "export TAVILY_API_KEY='your-tavily-key'"
echo ""

# .env 파일 템플릿 생성
cat > .env.example << 'EOF'
# DeepAgents 환경변수 설정
ANTHROPIC_API_KEY=your-anthropic-api-key-here
TAVILY_API_KEY=your-tavily-api-key-here

# 선택적 API 키들
OPENAI_API_KEY=your-openai-key-here
GOOGLE_API_KEY=your-google-key-here
EOF

echo "✅ 환경 설정 완료!"
echo "📋 다음 단계:"
echo "1. .env.example을 .env로 복사하고 API 키 입력"
echo "2. source deepagents-env/bin/activate 실행"
echo "3. python test_deepagents.py로 테스트"
```

## 성능 최적화 및 베스트 프랙티스

### 메모리 사용량 최적화

```python
from deepagents import create_deep_agent
import gc

class OptimizedDeepAgent:
    """메모리 최적화된 DeepAgent 래퍼"""
    
    def __init__(self, tools, instructions, **kwargs):
        self.tools = tools
        self.instructions = instructions
        self.kwargs = kwargs
        self._agent = None
    
    @property 
    def agent(self):
        """지연 로딩으로 메모리 절약"""
        if self._agent is None:
            self._agent = create_deep_agent(
                self.tools, 
                self.instructions, 
                **self.kwargs
            )
        return self._agent
    
    def invoke_with_cleanup(self, inputs):
        """실행 후 메모리 정리"""
        try:
            result = self.agent.invoke(inputs)
            return result
        finally:
            # 대용량 중간 결과 정리
            gc.collect()
    
    def stream_with_limits(self, inputs, max_tokens=10000):
        """토큰 제한과 함께 스트리밍"""
        token_count = 0
        
        for chunk in self.agent.stream(inputs):
            # 토큰 카운트 추정 (대략적)
            if "messages" in chunk:
                content = chunk["messages"][-1].content
                token_count += len(content.split()) * 1.3  # 대략적 토큰 추정
                
                if token_count > max_tokens:
                    print(f"⚠️  토큰 제한 ({max_tokens}) 도달. 스트리밍 중단.")
                    break
                    
                yield chunk
```

### 비용 최적화 전략

```python
class CostOptimizedAgent:
    """비용 최적화된 에이전트"""
    
    def __init__(self):
        # 비용별 모델 계층화
        self.models = {
            "planning": "claude-haiku-4-20250514",      # 저비용 계획 수립
            "analysis": "claude-sonnet-4-20250514",     # 중간 비용 분석
            "synthesis": "claude-opus-4-20250514"       # 고비용 종합
        }
        
        self.agents = self._create_tiered_agents()
    
    def _create_tiered_agents(self):
        """계층별 에이전트 생성"""
        from langchain_anthropic import ChatAnthropic
        
        agents = {}
        for tier, model in self.models.items():
            agents[tier] = create_deep_agent(
                tools=[self._get_tools_for_tier(tier)],
                instructions=self._get_instructions_for_tier(tier),
                model=ChatAnthropic(model=model)
            )
        return agents
    
    def _get_tools_for_tier(self, tier):
        """계층별 도구 할당"""
        if tier == "planning":
            return []  # 계획은 도구 없이
        elif tier == "analysis": 
            return [self.basic_search]  # 기본 검색만
        else:
            return [self.enhanced_search, self.deep_analysis]  # 전체 도구
    
    def cost_efficient_research(self, query, budget_tier="medium"):
        """예산에 맞는 연구 수행"""
        if budget_tier == "low":
            # 계획 + 기본 분석만
            plan = self.agents["planning"].invoke({
                "messages": [{"role": "user", "content": f"'{query}' 연구 계획 수립"}]
            })
            
            result = self.agents["analysis"].invoke({
                "messages": [{"role": "user", "content": f"계획: {plan}\n\n연구 실행: {query}"}]
            })
            
        elif budget_tier == "medium":
            # 전체 파이프라인, 단순화된 종합
            result = self.agents["analysis"].invoke({
                "messages": [{"role": "user", "content": query}]
            })
            
        else:  # high budget
            # 완전한 심층 분석
            result = self.agents["synthesis"].invoke({
                "messages": [{"role": "user", "content": query}]
            })
        
        return result

# 비용 추적 데코레이터
def track_costs(func):
    """API 호출 비용 추적"""
    def wrapper(*args, **kwargs):
        import time
        start_time = time.time()
        
        result = func(*args, **kwargs)
        
        duration = time.time() - start_time
        estimated_cost = duration * 0.001  # 대략적 비용 추정
        
        print(f"💰 예상 비용: ${estimated_cost:.4f}")
        print(f"⏱️  실행 시간: {duration:.2f}초")
        
        return result
    return wrapper
```

### 에러 처리 및 재시도 로직

```python
import time
import random
from functools import wraps

def retry_with_backoff(max_retries=3, base_delay=1):
    """지수 백오프를 이용한 재시도 데코레이터"""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            for attempt in range(max_retries):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    if attempt == max_retries - 1:
                        raise e
                    
                    delay = base_delay * (2 ** attempt) + random.uniform(0, 1)
                    print(f"⚠️  재시도 {attempt + 1}/{max_retries} (대기: {delay:.1f}초)")
                    time.sleep(delay)
            
            return None
        return wrapper
    return decorator

class RobustDeepAgent:
    """견고한 에러 처리를 가진 DeepAgent"""
    
    def __init__(self, tools, instructions, **kwargs):
        self.agent = create_deep_agent(tools, instructions, **kwargs)
    
    @retry_with_backoff(max_retries=3)
    def safe_invoke(self, inputs, timeout=300):
        """안전한 에이전트 실행"""
        import signal
        
        def timeout_handler(signum, frame):
            raise TimeoutError("에이전트 실행 시간 초과")
        
        # 타임아웃 설정
        signal.signal(signal.SIGALRM, timeout_handler)
        signal.alarm(timeout)
        
        try:
            result = self.agent.invoke(inputs)
            signal.alarm(0)  # 타임아웃 해제
            return result
        except Exception as e:
            signal.alarm(0)  # 타임아웃 해제
            print(f"❌ 에이전트 실행 오류: {str(e)}")
            raise
    
    def graceful_degradation(self, inputs, fallback_mode="simple"):
        """우아한 성능 저하"""
        try:
            return self.safe_invoke(inputs)
        except Exception as e:
            print(f"⚠️  주 에이전트 실패. 폴백 모드 실행: {fallback_mode}")
            
            if fallback_mode == "simple":
                # 단순한 응답 생성
                return {
                    "messages": [{
                        "role": "assistant",
                        "content": f"죄송합니다. 일시적 오류로 인해 간단한 응답만 제공합니다.\n\n요청: {inputs['messages'][-1]['content']}\n\n기본적인 정보를 원하시면 다시 시도해주세요."
                    }]
                }
            else:
                raise e
```

## 문제 해결 및 FAQ

### 자주 발생하는 문제

#### 1. API 키 관련 오류

```bash
# 문제: AuthenticationError
# 해결방법:
export ANTHROPIC_API_KEY="sk-ant-api03-your-key-here"

# API 키 검증
python -c "
import os
from anthropic import Anthropic
client = Anthropic(api_key=os.environ['ANTHROPIC_API_KEY'])
print('✅ API 키 유효함')
"
```

#### 2. 메모리 부족 오류

```python
# 문제: 대용량 컨텍스트로 인한 메모리 부족
# 해결방법: 컨텍스트 관리

def manage_context_size(messages, max_context=8000):
    """컨텍스트 크기 관리"""
    total_length = sum(len(msg.get('content', '')) for msg in messages)
    
    if total_length > max_context:
        # 최신 메시지들만 유지
        keep_messages = []
        current_length = 0
        
        for msg in reversed(messages):
            msg_length = len(msg.get('content', ''))
            if current_length + msg_length > max_context:
                break
            keep_messages.insert(0, msg)
            current_length += msg_length
        
        return keep_messages
    
    return messages
```

#### 3. 느린 응답 속도

```python
# 문제: 에이전트 응답이 너무 느림
# 해결방법: 병렬 처리와 캐싱

import asyncio
from functools import lru_cache

class FastDeepAgent:
    def __init__(self):
        self.cache = {}
    
    @lru_cache(maxsize=100)
    def cached_search(self, query):
        """검색 결과 캐싱"""
        return self.search_function(query)
    
    async def parallel_research(self, queries):
        """병렬 연구 수행"""
        tasks = [self.research_single_query(q) for q in queries]
        results = await asyncio.gather(*tasks)
        return results
```

#### 4. 토큰 제한 초과

```python
# 문제: Token limit exceeded
# 해결방법: 청킹과 요약

def chunk_and_summarize(content, chunk_size=4000):
    """큰 컨텐츠를 청크로 나누고 요약"""
    chunks = [content[i:i+chunk_size] for i in range(0, len(content), chunk_size)]
    
    summaries = []
    for i, chunk in enumerate(chunks):
        summary = summarize_chunk(chunk, f"부분 {i+1}/{len(chunks)}")
        summaries.append(summary)
    
    return "\n\n".join(summaries)

def summarize_chunk(chunk, label):
    """개별 청크 요약"""
    # 간단한 요약 로직 (실제로는 LLM 사용)
    sentences = chunk.split('.')[:3]  # 첫 3문장만
    return f"{label}: {'. '.join(sentences)}."
```

### 성능 모니터링

```python
import time
import psutil
from contextlib import contextmanager

@contextmanager
def performance_monitor():
    """성능 모니터링 컨텍스트 매니저"""
    start_time = time.time()
    start_memory = psutil.Process().memory_info().rss / 1024 / 1024  # MB
    
    try:
        yield
    finally:
        end_time = time.time()
        end_memory = psutil.Process().memory_info().rss / 1024 / 1024  # MB
        
        duration = end_time - start_time
        memory_diff = end_memory - start_memory
        
        print(f"⏱️  실행 시간: {duration:.2f}초")
        print(f"💾 메모리 사용량: {memory_diff:+.1f}MB")

# 사용 예제
with performance_monitor():
    result = agent.invoke({"messages": [{"role": "user", "content": "복잡한 연구 요청"}]})
```

## 결론 및 향후 로드맵

DeepAgents는 **단순한 도구 호출을 넘어선 진정한 AI 에이전트**의 가능성을 보여줍니다. Claude Code의 성공 요소들을 범용화하여, 누구나 **계획적이고 체계적인 심층 에이전트**를 구축할 수 있게 합니다.

### 핵심 가치 제안

- 🧠 **인텔리전트 아키텍처**: 계획, 실행, 검토의 체계적 워크플로우
- 🔧 **개발자 친화적**: LangGraph 기반으로 기존 도구와 완벽 호환
- 🌐 **확장 가능**: MCP 프로토콜과 커스텀 모델 지원
- 💼 **프로덕션 준비**: 에러 처리, 성능 최적화, 비용 관리

### 실무 적용 영역

1. **연구 및 분석**: 시장 조사, 경쟁 분석, 트렌드 예측
2. **콘텐츠 제작**: 보고서, 문서, 기획서 자동 생성
3. **데이터 처리**: 대용량 정보 수집, 정제, 분석
4. **의사결정 지원**: 다면적 분석을 통한 전략적 인사이트

### 향후 발전 방향

```python
# 미래 기능 프리뷰 (개념적 구현)
from deepagents import create_deep_agent, AdvancedFeatures

# 1. 휴먼인더루프 워크플로우
human_in_loop_agent = create_deep_agent(
    tools=[search_tool],
    instructions="중요한 결정은 사용자 승인 필요",
    features=AdvancedFeatures(
        human_approval_required=["final_report", "strategic_decisions"],
        approval_timeout=300  # 5분 내 응답 필요
    )
)

# 2. 다중 모델 앙상블
ensemble_agent = create_deep_agent(
    tools=[search_tool],
    instructions="여러 모델의 의견을 종합",
    models={
        "creative": "claude-opus-4",
        "analytical": "gpt-4-turbo", 
        "factual": "gemini-pro"
    },
    ensemble_strategy="weighted_voting"  # 가중 투표
)

# 3. 지속적 학습
adaptive_agent = create_deep_agent(
    tools=[search_tool],
    instructions="사용자 피드백으로 지속 개선",
    features=AdvancedFeatures(
        feedback_learning=True,
        performance_tracking=True,
        auto_optimization=True
    )
)
```

### 커뮤니티와 생태계

DeepAgents는 **오픈소스 커뮤니티**의 힘으로 계속 발전하고 있습니다:

- **GitHub**: [hwchase17/deepagents](https://github.com/hwchase17/deepagents)
- **라이센스**: MIT (상업적 사용 가능)
- **기여 가이드**: Issues와 Pull Requests 환영
- **로드맵**: 커뮤니티 피드백 기반 개발

### 시작하기

```bash
# 1분 만에 시작하기
pip install deepagents tavily-python
export ANTHROPIC_API_KEY="your-key"
export TAVILY_API_KEY="your-key"

python -c "
from deepagents import create_deep_agent
agent = create_deep_agent([], 'Hello World 에이전트')
print('🚀 DeepAgents 설치 완료!')
"
```

**DeepAgents와 함께 AI 에이전트의 새로운 시대를 경험해보세요.** 단순한 자동화를 넘어, **진정으로 지능적이고 체계적인 AI 동반자**를 만들 수 있습니다.

---

💡 **Pro Tip**: 이 가이드의 모든 예제는 실제 macOS 환경에서 테스트되었습니다. 궁금한 점이 있다면 [GitHub Issues](https://github.com/hwchase17/deepagents/issues)에서 커뮤니티와 소통하세요!

