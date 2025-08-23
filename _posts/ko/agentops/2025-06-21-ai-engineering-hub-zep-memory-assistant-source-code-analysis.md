---
title: "AI Engineering Hub Zep Memory Assistant 소스코드 완전 분석: 장기 기억 기반 AI 어시스턴트 구현"
excerpt: "10.7k 스타 AI Engineering Hub의 Zep Memory Assistant 프로젝트를 소스코드 레벨에서 심층 분석하고, 실전 구현 방법을 제시합니다."
date: 2025-06-21
categories: 
  - agentops
tags: 
  - Zep-Memory
  - AI-Engineering-Hub
  - LangGraph
  - Temporal-Knowledge-Graph
  - Long-Term-Memory
  - AgentOps
  - Source-Code-Analysis
  - Memory-Management
author_profile: true
toc: true
toc_label: "Zep Memory Assistant 분석"
---

## 개요

[AI Engineering Hub](https://github.com/patchy631/ai-engineering-hub)의 **Zep Memory Assistant** 프로젝트는 장기 기억 기능을 갖춘 AI 어시스턴트의 실전 구현을 보여주는 핵심 프로젝트입니다. 이 프로젝트는 Zep의 Temporal Knowledge Graph를 활용하여 사용자와의 대화를 기억하고 학습하는 지능형 어시스턴트를 구현합니다.

본 포스트에서는 Zep Memory Assistant의 **소스코드**를 상세히 분석하고, AgentOps 관점에서 실전 활용 방법을 제시합니다.

### Zep Memory Assistant란?

**Zep Memory Assistant**는 다음과 같은 특징을 가진 AI 어시스턴트입니다:

- **장기 기억**: 사용자와의 모든 대화를 기억하고 학습
- **Temporal Knowledge Graph**: 시간에 따른 정보 변화 추적
- **개인화된 응답**: 사용자 선호도와 과거 대화 기반 맞춤형 응답
- **실시간 학습**: 대화를 통한 지속적인 지식 업데이트

## 핵심 아키텍처 분석

### 1. 시스템 구조

```python
# 메인 아키텍처 구성요소
class ZepMemoryAssistant:
    def __init__(self, config):
        self.zep_client = ZepClient(api_key=config.zep_api_key)
        self.llm = ChatOpenAI(model="gpt-4", temperature=0.7)
        self.memory_store = ZepMemoryStore(client=self.zep_client)
        self.conversation_manager = ConversationManager()
        self.fact_extractor = FactExtractor()
        
    async def process_message(self, user_id: str, message: str):
        """메시지 처리 및 기억 저장"""
        # 1. 기존 기억 검색
        relevant_facts = await self.retrieve_relevant_facts(user_id, message)
        
        # 2. 컨텍스트 구성
        context = self.build_context(relevant_facts, message)
        
        # 3. LLM 응답 생성
        response = await self.generate_response(context)
        
        # 4. 새로운 기억 저장
        await self.store_memory(user_id, message, response)
        
        return response
```

### 2. 메모리 관리 시스템

```python
class ZepMemoryStore:
    def __init__(self, client: ZepClient):
        self.client = client
        self.session_manager = SessionManager()
        
    async def store_conversation(self, user_id: str, messages: List[Message]):
        """대화 저장 및 팩트 추출"""
        session_id = await self.session_manager.get_or_create_session(user_id)
        
        # Zep에 메시지 저장
        await self.client.memory.add(
            session_id=session_id,
            messages=[
                Message(
                    role_type=msg.role,
                    content=msg.content,
                    metadata=msg.metadata
                ) for msg in messages
            ]
        )
        
        # 자동 팩트 추출
        facts = await self.client.memory.get_facts(session_id)
        return facts
        
    async def retrieve_relevant_facts(self, user_id: str, query: str):
        """관련 팩트 검색"""
        search_results = await self.client.memory.search_sessions(
            user_id=user_id,
            text=query,
            search_scope="facts",
            limit=10
        )
        
        return [result.fact for result in search_results.results]
```

## 핵심 구현 컴포넌트

### 1. 대화 관리자 (ConversationManager)

```python
class ConversationManager:
    def __init__(self):
        self.active_sessions = {}
        self.context_window = 10  # 최근 10개 메시지 유지
        
    async def manage_conversation(self, user_id: str, message: str):
        """대화 흐름 관리"""
        session = self.get_session(user_id)
        
        # 컨텍스트 윈도우 관리
        if len(session.messages) > self.context_window:
            # 오래된 메시지는 요약하여 저장
            summary = await self.summarize_old_messages(
                session.messages[:-self.context_window]
            )
            session.summary = summary
            session.messages = session.messages[-self.context_window:]
            
        # 새 메시지 추가
        session.add_message(message)
        return session
        
    async def summarize_old_messages(self, messages: List[Message]):
        """오래된 메시지 요약"""
        prompt = f"""
        다음 대화를 핵심 정보만 포함하여 요약하세요:
        {self.format_messages(messages)}
        """
        
        summary = await self.llm.ainvoke(prompt)
        return summary.content
```

### 2. 팩트 추출기 (FactExtractor)

```python
class FactExtractor:
    def __init__(self):
        self.extraction_prompt = """
        사용자와의 대화에서 다음 정보를 추출하세요:
        1. 개인 정보 (이름, 직업, 관심사 등)
        2. 선호도 (좋아하는 것, 싫어하는 것)
        3. 중요한 사실들
        4. 감정 상태
        """
        
    async def extract_facts(self, conversation: str):
        """대화에서 팩트 추출"""
        prompt = f"{self.extraction_prompt}\n\n대화:\n{conversation}"
        
        response = await self.llm.ainvoke(prompt)
        facts = self.parse_extracted_facts(response.content)
        
        return facts
        
    def parse_extracted_facts(self, raw_facts: str):
        """추출된 팩트 파싱"""
        facts = []
        lines = raw_facts.split('\n')
        
        for line in lines:
            if line.strip() and not line.startswith('#'):
                fact = {
                    'content': line.strip(),
                    'confidence': self.calculate_confidence(line),
                    'category': self.categorize_fact(line),
                    'timestamp': datetime.now().isoformat()
                }
                facts.append(fact)
                
        return facts
```

### 3. 컨텍스트 빌더 (ContextBuilder)

```python
class ContextBuilder:
    def __init__(self):
        self.max_context_length = 4000  # 토큰 제한
        
    def build_context(self, user_facts: List[str], 
                     current_message: str, 
                     conversation_history: List[Message]):
        """응답 생성을 위한 컨텍스트 구성"""
        
        # 사용자 팩트 포맷팅
        facts_context = self.format_user_facts(user_facts)
        
        # 대화 히스토리 포맷팅
        history_context = self.format_conversation_history(conversation_history)
        
        # 현재 메시지 컨텍스트
        current_context = f"현재 사용자 메시지: {current_message}"
        
        # 전체 컨텍스트 조합
        full_context = f"""
        {facts_context}
        
        {history_context}
        
        {current_context}
        """
        
        # 토큰 제한 확인 및 조정
        if self.count_tokens(full_context) > self.max_context_length:
            full_context = self.trim_context(full_context)
            
        return full_context
        
    def format_user_facts(self, facts: List[str]):
        """사용자 팩트 포맷팅"""
        if not facts:
            return "사용자에 대한 알려진 정보가 없습니다."
            
        formatted_facts = "\n".join([f"- {fact}" for fact in facts])
        return f"사용자에 대한 알려진 정보:\n{formatted_facts}"
```

## LangGraph 통합 구현

### 1. 메모리 기반 LangGraph 에이전트

```python
from langgraph.graph import StateGraph, END
from langgraph.checkpoint.memory import MemorySaver

class ZepMemoryAgent:
    def __init__(self, zep_client: ZepClient):
        self.zep_client = zep_client
        self.llm = ChatOpenAI(model="gpt-4")
        self.graph = self.build_graph()
        
    def build_graph(self):
        """LangGraph 워크플로우 구성"""
        workflow = StateGraph(AgentState)
        
        # 노드 추가
        workflow.add_node("retrieve_memory", self.retrieve_memory_node)
        workflow.add_node("generate_response", self.generate_response_node)
        workflow.add_node("store_memory", self.store_memory_node)
        
        # 엣지 추가
        workflow.add_edge("retrieve_memory", "generate_response")
        workflow.add_edge("generate_response", "store_memory")
        workflow.add_edge("store_memory", END)
        
        # 시작점 설정
        workflow.set_entry_point("retrieve_memory")
        
        # 체크포인터로 상태 저장
        memory = MemorySaver()
        return workflow.compile(checkpointer=memory)
        
    async def retrieve_memory_node(self, state: AgentState):
        """메모리 검색 노드"""
        user_id = state["user_id"]
        message = state["current_message"]
        
        # Zep에서 관련 팩트 검색
        relevant_facts = await self.zep_client.memory.search_sessions(
            user_id=user_id,
            text=message,
            search_scope="facts"
        )
        
        state["relevant_facts"] = [r.fact for r in relevant_facts.results]
        return state
        
    async def generate_response_node(self, state: AgentState):
        """응답 생성 노드"""
        context = self.build_context(
            state["relevant_facts"],
            state["current_message"],
            state["conversation_history"]
        )
        
        response = await self.llm.ainvoke(context)
        state["response"] = response.content
        return state
        
    async def store_memory_node(self, state: AgentState):
        """메모리 저장 노드"""
        session_id = state["session_id"]
        
        # 새로운 대화 저장
        await self.zep_client.memory.add(
            session_id=session_id,
            messages=[
                Message(role_type="user", content=state["current_message"]),
                Message(role_type="assistant", content=state["response"])
            ]
        )
        
        return state
```

### 2. 상태 정의

```python
from typing import TypedDict, List

class AgentState(TypedDict):
    user_id: str
    session_id: str
    current_message: str
    conversation_history: List[Message]
    relevant_facts: List[str]
    response: str
    metadata: dict
```

## AgentOps 통합 및 모니터링

### 1. AgentOps 모니터링 설정

```python
import agentops
from agentops import track_agent

class MonitoredZepAssistant:
    def __init__(self, config):
        # AgentOps 초기화
        agentops.init(api_key=config.agentops_api_key)
        
        self.assistant = ZepMemoryAssistant(config)
        self.metrics_collector = MetricsCollector()
        
    @track_agent(name="zep_memory_assistant")
    async def process_message_with_monitoring(self, user_id: str, message: str):
        """모니터링이 포함된 메시지 처리"""
        
        # 시작 시간 기록
        start_time = time.time()
        
        try:
            # 메시지 처리
            response = await self.assistant.process_message(user_id, message)
            
            # 성공 메트릭 기록
            self.metrics_collector.record_success(
                user_id=user_id,
                response_time=time.time() - start_time,
                message_length=len(message),
                response_length=len(response)
            )
            
            return response
            
        except Exception as e:
            # 에러 메트릭 기록
            self.metrics_collector.record_error(
                user_id=user_id,
                error_type=type(e).__name__,
                error_message=str(e)
            )
            raise
```

### 2. 메트릭 수집기

```python
class MetricsCollector:
    def __init__(self):
        self.metrics = {
            'total_conversations': 0,
            'average_response_time': 0,
            'error_rate': 0,
            'memory_retrieval_accuracy': 0
        }
        
    def record_success(self, user_id: str, response_time: float, 
                      message_length: int, response_length: int):
        """성공 메트릭 기록"""
        agentops.record({
            'event_type': 'conversation_success',
            'user_id': user_id,
            'response_time': response_time,
            'message_length': message_length,
            'response_length': response_length,
            'timestamp': datetime.now().isoformat()
        })
        
        self.update_metrics(response_time)
        
    def record_error(self, user_id: str, error_type: str, error_message: str):
        """에러 메트릭 기록"""
        agentops.record({
            'event_type': 'conversation_error',
            'user_id': user_id,
            'error_type': error_type,
            'error_message': error_message,
            'timestamp': datetime.now().isoformat()
        })
        
    def calculate_memory_accuracy(self, retrieved_facts: List[str], 
                                 user_query: str):
        """메모리 검색 정확도 계산"""
        # 검색된 팩트의 관련성 평가
        relevance_scores = []
        
        for fact in retrieved_facts:
            similarity = self.calculate_similarity(fact, user_query)
            relevance_scores.append(similarity)
            
        accuracy = sum(relevance_scores) / len(relevance_scores) if relevance_scores else 0
        
        agentops.record({
            'event_type': 'memory_accuracy',
            'accuracy_score': accuracy,
            'retrieved_facts_count': len(retrieved_facts)
        })
        
        return accuracy
```

## 실전 구현 예제

### 1. 완전한 Zep Memory Assistant 구현

```python
class ProductionZepAssistant:
    def __init__(self, config):
        self.config = config
        self.zep_client = ZepClient(api_key=config.zep_api_key)
        self.llm = ChatOpenAI(model="gpt-4", temperature=0.7)
        self.agentops_client = agentops.Client(api_key=config.agentops_api_key)
        
        # 컴포넌트 초기화
        self.memory_store = ZepMemoryStore(self.zep_client)
        self.conversation_manager = ConversationManager()
        self.context_builder = ContextBuilder()
        self.fact_extractor = FactExtractor()
        
    async def chat(self, user_id: str, message: str, session_id: str = None):
        """메인 채팅 인터페이스"""
        
        # 세션 관리
        if not session_id:
            session_id = await self.create_new_session(user_id)
            
        try:
            # 1. 관련 기억 검색
            relevant_facts = await self.memory_store.retrieve_relevant_facts(
                user_id, message
            )
            
            # 2. 대화 히스토리 가져오기
            conversation_history = await self.get_conversation_history(session_id)
            
            # 3. 컨텍스트 구성
            context = self.context_builder.build_context(
                relevant_facts, message, conversation_history
            )
            
            # 4. 응답 생성
            response = await self.generate_contextual_response(context)
            
            # 5. 대화 저장
            await self.store_conversation(session_id, message, response)
            
            # 6. 메트릭 기록
            await self.record_conversation_metrics(user_id, message, response)
            
            return {
                'response': response,
                'session_id': session_id,
                'relevant_facts_count': len(relevant_facts)
            }
            
        except Exception as e:
            await self.handle_error(user_id, message, str(e))
            raise
            
    async def generate_contextual_response(self, context: str):
        """컨텍스트 기반 응답 생성"""
        
        system_prompt = """
        당신은 사용자의 과거 대화와 선호도를 기억하는 AI 어시스턴트입니다.
        제공된 컨텍스트를 바탕으로 개인화된 응답을 생성하세요.
        
        응답 가이드라인:
        1. 사용자의 과거 대화 내용을 참조하세요
        2. 개인적인 선호도를 고려하세요
        3. 자연스럽고 친근한 톤을 유지하세요
        4. 필요시 과거 대화를 언급하세요
        """
        
        messages = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": context}
        ]
        
        response = await self.llm.ainvoke(messages)
        return response.content
```

### 2. 사용 예제

```python
async def main():
    # 설정
    config = Config(
        zep_api_key="your-zep-api-key",
        openai_api_key="your-openai-api-key",
        agentops_api_key="your-agentops-api-key"
    )
    
    # 어시스턴트 초기화
    assistant = ProductionZepAssistant(config)
    
    # 사용자와 대화
    user_id = "user_123"
    
    # 첫 번째 대화
    response1 = await assistant.chat(
        user_id=user_id,
        message="안녕하세요! 저는 커피를 정말 좋아해요."
    )
    print(f"Assistant: {response1['response']}")
    
    # 두 번째 대화 (이전 대화 기억)
    response2 = await assistant.chat(
        user_id=user_id,
        message="오늘 아침에 마실 음료 추천해주세요.",
        session_id=response1['session_id']
    )
    print(f"Assistant: {response2['response']}")
    
    # 메트릭 확인
    metrics = await assistant.get_conversation_metrics(user_id)
    print(f"Conversation metrics: {metrics}")

if __name__ == "__main__":
    asyncio.run(main())
```

## 성능 최적화 및 모니터링

### 1. 메모리 검색 최적화

```python
class OptimizedMemoryRetrieval:
    def __init__(self, zep_client):
        self.zep_client = zep_client
        self.cache = TTLCache(maxsize=1000, ttl=300)  # 5분 캐시
        
    async def retrieve_with_caching(self, user_id: str, query: str):
        """캐싱을 포함한 메모리 검색"""
        cache_key = f"{user_id}:{hash(query)}"
        
        # 캐시 확인
        if cache_key in self.cache:
            return self.cache[cache_key]
            
        # Zep에서 검색
        results = await self.zep_client.memory.search_sessions(
            user_id=user_id,
            text=query,
            search_scope="facts",
            limit=10
        )
        
        facts = [r.fact for r in results.results]
        
        # 캐시 저장
        self.cache[cache_key] = facts
        
        return facts
```

### 2. A/B 테스트 프레임워크

```python
class ABTestFramework:
    def __init__(self):
        self.experiments = {}
        
    def create_experiment(self, name: str, variants: List[str]):
        """A/B 테스트 실험 생성"""
        self.experiments[name] = {
            'variants': variants,
            'results': {variant: [] for variant in variants}
        }
        
    def assign_variant(self, user_id: str, experiment_name: str):
        """사용자에게 변형 할당"""
        variants = self.experiments[experiment_name]['variants']
        user_hash = hash(user_id) % len(variants)
        return variants[user_hash]
        
    def record_result(self, experiment_name: str, variant: str, 
                     metric_name: str, value: float):
        """실험 결과 기록"""
        if experiment_name in self.experiments:
            self.experiments[experiment_name]['results'][variant].append({
                'metric': metric_name,
                'value': value,
                'timestamp': datetime.now()
            })
```

## 실제 활용 사례

### 1. 고객 지원 어시스턴트

```python
class CustomerSupportAssistant(ProductionZepAssistant):
    async def handle_support_request(self, customer_id: str, issue: str):
        """고객 지원 요청 처리"""
        
        # 고객 히스토리 검색
        customer_history = await self.get_customer_history(customer_id)
        
        # 이전 이슈 패턴 분석
        similar_issues = await self.find_similar_issues(issue)
        
        # 개인화된 지원 응답 생성
        response = await self.generate_support_response(
            customer_history, issue, similar_issues
        )
        
        return response
```

### 2. 개인 비서 어시스턴트

```python
class PersonalAssistant(ProductionZepAssistant):
    async def manage_schedule(self, user_id: str, request: str):
        """일정 관리"""
        
        # 사용자 선호도 및 패턴 분석
        preferences = await self.analyze_user_preferences(user_id)
        
        # 일정 추천
        suggestions = await self.generate_schedule_suggestions(
            request, preferences
        )
        
        return suggestions
```

## 결론

AI Engineering Hub의 Zep Memory Assistant는 장기 기억 기능을 갖춘 AI 어시스턴트의 실전 구현을 보여주는 뛰어난 예제입니다. 

### 주요 특징

1. **Temporal Knowledge Graph**: 시간에 따른 정보 변화 추적
2. **자동 팩트 추출**: 대화에서 중요 정보 자동 추출
3. **개인화된 응답**: 사용자별 맞춤형 응답 생성
4. **실시간 모니터링**: AgentOps를 통한 성능 추적

### 실전 활용 가이드

1. **메모리 관리**: 효율적인 장기 기억 저장 및 검색
2. **컨텍스트 최적화**: 관련성 높은 정보만 선별적 활용
3. **성능 모니터링**: 지속적인 성능 개선 및 최적화
4. **확장성**: 대규모 사용자 지원을 위한 아키텍처 설계

이 프로젝트를 통해 실제 운영 환경에서 사용할 수 있는 고품질의 메모리 기반 AI 어시스턴트를 구현할 수 있습니다. 