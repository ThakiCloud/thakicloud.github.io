---
title: "Google Agent Development Kit (ADK) 샘플: 멀티 에이전트 애플리케이션 완벽 튜토리얼"
excerpt: "Google ADK의 공식 샘플 저장소를 활용하여 지능형 멀티 에이전트 시스템을 구축하는 방법을 실용적인 예제와 함께 배워보세요."
seo_title: "Google ADK 샘플 튜토리얼: 멀티 에이전트 애플리케이션 구축 - Thaki Cloud"
seo_description: "Google Agent Development Kit (ADK)의 설치부터 샘플 에이전트, 실전 구현 예제까지 멀티 에이전트 시스템 개발의 모든 것을 알아보세요."
date: 2025-09-21
categories:
  - tutorials
tags:
  - google-adk
  - 멀티에이전트시스템
  - ai-에이전트
  - python
  - java
  - 에이전트프레임워크
author_profile: true
toc: true
toc_label: "목차"
lang: ko
permalink: /ko/tutorials/google-adk-samples-tutorial/
canonical_url: "https://thakicloud.github.io/ko/tutorials/google-adk-samples-tutorial/"
---

⏱️ **예상 읽기 시간**: 15분

## Google Agent Development Kit (ADK) 소개

Google의 Agent Development Kit (ADK)는 지능적이고 자율적인 멀티 에이전트 시스템을 구축하기 위한 오픈소스 프레임워크입니다. ADK를 통해 개발자들은 도구와 상호작용하고, 서로 소통하며, 다양한 모델과 배포 환경에서 복잡한 작업을 수행할 수 있는 프로덕션 수준의 에이전트 애플리케이션을 개발할 수 있습니다.

[google/adk-samples](https://github.com/google/adk-samples) 저장소는 ADK를 기반으로 구축된 포괄적인 샘플 에이전트 컬렉션을 제공합니다. 간단한 대화형 봇부터 정교한 멀티 에이전트 워크플로우까지 다양한 범위를 다루며, ADK의 기능을 활용하고자 하는 개발자들에게 실용적인 예제와 시작점을 제공합니다.

## ADK의 주요 특징

### 1. 멀티 에이전트 아키텍처
ADK는 각각 전문화된 역할과 기능을 가진 여러 에이전트가 함께 작업할 수 있는 환경을 지원합니다. 이러한 아키텍처는 에이전트 간의 협업을 통해 복잡한 문제 해결을 가능하게 합니다.

### 2. 도구 통합
ADK로 구축된 에이전트는 외부 도구와 API와 상호작용할 수 있어, 언어 모델 응답을 넘어서 실제 세계의 작업을 수행할 수 있는 기능을 확장합니다.

### 3. 유연한 배포
ADK는 로컬 개발부터 클라우드 기반 프로덕션 시스템까지 다양한 배포 환경을 지원하여, 다양한 규모의 애플리케이션에 적합합니다.

### 4. 다중 언어 지원
이 프레임워크는 Python과 Java 모두를 위한 SDK를 제공하여, 개발자들이 선호하는 프로그래밍 언어로 작업할 수 있게 합니다.

## 저장소 구조 개요

ADK 샘플 저장소는 두 개의 주요 섹션으로 구성되어 있습니다:

```
adk-samples/
├── java/
│   ├── agents/
│   │   ├── software-bug-assistant/
│   │   └── time-series-forecasting/
│   └── README.md
└── python/
    ├── agents/
    │   ├── academic-research/
    │   ├── blog-writer/
    │   ├── customer-service/
    │   ├── data-science/
    │   ├── financial-advisor/
    │   ├── RAG/
    │   └── [20+ 개의 추가 샘플]
    └── README.md
```

## 설치 및 환경 설정

### 사전 요구사항

ADK 샘플을 사용하기 전에 다음 사항이 설치되어 있는지 확인하세요:

- **Python 3.8+** 또는 **Java 11+** (선택한 언어에 따라)
- 저장소 클론을 위한 **Git**
- 필요한 API가 활성화된 **Google Cloud 프로젝트**

### 1단계: 저장소 클론

```bash
# ADK 샘플 저장소 클론
git clone https://github.com/google/adk-samples.git
cd adk-samples
```

### 2단계: ADK 설치

선택한 언어에 대한 공식 ADK 설치 가이드를 따르세요:

**Python의 경우:**
```bash
pip install google-adk
```

**Java의 경우:**
```bash
# Maven 또는 Gradle 프로젝트에 ADK 의존성 추가
# Java README에서 자세한 지침 참조
```

### 3단계: 환경 구성

프로젝트 디렉토리에 `.env` 파일을 생성하고 필요한 환경 변수를 구성하세요:

```bash
# Google Cloud 구성
GOOGLE_APPLICATION_CREDENTIALS=/path/to/your/service-account-key.json
GOOGLE_CLOUD_PROJECT=your-project-id

# API 키 (특정 에이전트에서 필요한 경우)
OPENAI_API_KEY=your-openai-key
ANTHROPIC_API_KEY=your-anthropic-key
```

## 샘플 에이전트 탐색

### Python 샘플 심화 분석

Python 샘플은 다양한 사용 사례를 다룹니다. 주목할 만한 몇 가지 예제를 살펴보겠습니다:

#### 1. 고객 서비스 에이전트

고객 서비스 에이전트는 고객 문의를 처리하고, 지식 베이스에 접근하며, 복잡한 문제를 에스컬레이션할 수 있는 대화형 AI를 구축하는 방법을 보여줍니다.

**주요 기능:**
- 자연어 이해
- 지식 베이스 통합
- 에스컬레이션 워크플로우
- 다중 턴 대화

#### 2. 데이터 사이언스 에이전트

이 에이전트는 데이터 전처리, 시각화, 통계 분석을 포함한 AI 기반 데이터 분석 기능을 보여줍니다.

**기능:**
- 자동화된 데이터 정리
- 통계 분석
- 차트 생성
- 보고서 작성

#### 3. RAG (Retrieval-Augmented Generation) 에이전트

RAG 에이전트는 지식 집약적 작업을 위해 검색 메커니즘과 생성 기능을 결합하는 방법을 보여줍니다.

**구성 요소:**
- 문서 인덱싱
- 의미론적 검색
- 컨텍스트 인식 생성
- 출처 기여

### Java 샘플 개요

Java 샘플은 엔터프라이즈급 애플리케이션에 중점을 둡니다:

#### 1. 소프트웨어 버그 어시스턴트

소프트웨어 개발 팀을 위한 특화된 에이전트로, 버그 리포트를 분석하고 해결책을 제안하며 이슈 해결을 추적할 수 있습니다.

#### 2. 시계열 예측

머신러닝 모델을 사용하여 고급 시계열 분석 및 예측을 수행하는 에이전트입니다.

## 실용적인 구현 가이드

### 첫 번째 에이전트 실행하기

고객 서비스 에이전트를 예제로 실행 과정을 안내해드리겠습니다:

#### 1단계: 에이전트 디렉토리로 이동

```bash
cd python/agents/customer-service
```

#### 2단계: 의존성 설치

```bash
# 필요한 패키지 설치
pip install -r requirements.txt
```

#### 3단계: 에이전트 구성

환경에 맞게 구성 파일을 편집하세요:

```python
# config.py
AGENT_CONFIG = {
    "model": "gemini-pro",
    "temperature": 0.7,
    "max_tokens": 1000,
    "knowledge_base": "customer_kb.json"
}
```

#### 4단계: 에이전트 실행

```bash
python main.py
```

#### 5단계: 에이전트와 상호작용

실행되면 제공된 인터페이스를 통해 에이전트와 상호작용할 수 있습니다:

```
Customer Service Agent: 안녕하세요! 오늘 어떻게 도와드릴까요?
사용자: 주문에 문제가 있어요
Customer Service Agent: 주문 문제를 해결해드리겠습니다. 주문 번호를 알려주시겠어요?
```

## 고급 구성 및 커스터마이징

### 에이전트 동작 커스터마이징

구성 매개변수를 수정하여 에이전트 동작을 커스터마이징할 수 있습니다:

```python
from google.adk import Agent, AgentConfig

config = AgentConfig(
    name="custom-agent",
    model="gemini-pro",
    system_prompt="당신은 ...에 특화된 도움이 되는 어시스턴트입니다",
    tools=["web_search", "calculator", "email_sender"],
    memory_type="conversation",
    max_conversation_length=100
)

agent = Agent(config)
```

### 도구 통합

ADK를 사용하면 에이전트에 커스텀 도구를 통합할 수 있습니다:

```python
from google.adk.tools import Tool

class CustomTool(Tool):
    def __init__(self):
        super().__init__(
            name="custom_tool",
            description="커스텀 비즈니스 로직을 수행합니다"
        )
    
    def execute(self, parameters):
        # 여기에 커스텀 로직 작성
        return {"result": "커스텀 도구가 성공적으로 실행되었습니다"}

# 에이전트에 도구 등록
agent.add_tool(CustomTool())
```

### 멀티 에이전트 협력

복잡한 워크플로우의 경우, 함께 작업하는 여러 에이전트를 생성할 수 있습니다:

```python
from google.adk import MultiAgentSystem

# 전문화된 에이전트 생성
research_agent = Agent(research_config)
writing_agent = Agent(writing_config)
review_agent = Agent(review_config)

# 멀티 에이전트 시스템 생성
system = MultiAgentSystem([research_agent, writing_agent, review_agent])

# 워크플로우 정의
workflow = {
    "research": research_agent,
    "write": writing_agent,
    "review": review_agent
}

# 워크플로우 실행
result = system.execute_workflow(workflow, initial_input="AI에 관한 블로그 포스트 작성")
```

## 모범 사례 및 최적화

### 1. 프롬프트 엔지니어링

효과적인 프롬프트 엔지니어링은 에이전트 성능에 중요합니다:

```python
SYSTEM_PROMPT = """
당신은 다음 기능을 가진 전문 {domain} 어시스턴트입니다:
- {capability_1}
- {capability_2}
- {capability_3}

가이드라인:
1. 항상 정확하고 도움이 되는 정보를 제공하세요
2. 필요시 명확한 질문을 하세요
3. 사실적 주장을 할 때는 출처를 인용하세요
4. 복잡한 문제는 인간 전문가에게 에스컬레이션하세요

응답 형식:
- 간결하지만 포괄적으로 작성하세요
- 목록에는 불릿 포인트를 사용하세요
- 관련 예시를 포함하세요
"""
```

### 2. 오류 처리 및 복원력

프로덕션 배포를 위한 견고한 오류 처리를 구현하세요:

```python
from google.adk.exceptions import ADKException

try:
    response = agent.process(user_input)
except ADKException as e:
    logger.error(f"에이전트 처리 오류: {e}")
    response = "죄송합니다. 기술적 문제가 발생했습니다. 나중에 다시 시도해주세요."
```

### 3. 성능 모니터링

에이전트 성능과 사용 패턴을 모니터링하세요:

```python
from google.adk.monitoring import AgentMetrics

metrics = AgentMetrics(agent)
metrics.track_response_time()
metrics.track_success_rate()
metrics.track_user_satisfaction()
```

## 배포 전략

### 로컬 개발

개발 및 테스트를 위해:

```bash
# 디버그 모드로 실행
python main.py --debug --port 8000
```

### 클라우드 배포

Google Cloud에서의 프로덕션 배포:

```yaml
# Google App Engine을 위한 app.yaml
runtime: python39

env_variables:
  GOOGLE_CLOUD_PROJECT: your-project-id
  
automatic_scaling:
  min_instances: 1
  max_instances: 10
```

### 컨테이너 배포

컨테이너화된 배포를 위한 Docker 사용:

```dockerfile
FROM python:3.9-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
EXPOSE 8080

CMD ["python", "main.py", "--port", "8080"]
```

## 일반적인 문제 해결

### 1. 인증 오류

Google Cloud 자격 증명이 올바르게 구성되었는지 확인하세요:

```bash
# 애플리케이션 기본 자격 증명 설정
gcloud auth application-default login

# 또는 서비스 계정 키 내보내기
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json
```

### 2. 의존성 충돌

패키지 충돌을 피하기 위해 가상 환경을 사용하세요:

```bash
python -m venv adk-env
source adk-env/bin/activate  # Windows의 경우: adk-env\Scripts\activate
pip install -r requirements.txt
```

### 3. 메모리 문제

메모리 집약적인 에이전트의 경우 적절한 제한을 구성하세요:

```python
config = AgentConfig(
    max_memory_usage="2GB",
    cleanup_interval=300,  # 초
    conversation_history_limit=50
)
```

## 보안 고려사항

### 1. API 키 관리

소스 코드에 API 키를 하드코딩하지 마세요:

```python
import os
from google.cloud import secretmanager

def get_api_key(secret_name):
    client = secretmanager.SecretManagerServiceClient()
    name = f"projects/{PROJECT_ID}/secrets/{secret_name}/versions/latest"
    response = client.access_secret_version(request={"name": name})
    return response.payload.data.decode("UTF-8")
```

### 2. 입력 검증

사용자 입력을 검증하고 삭제하세요:

```python
import re

def validate_user_input(input_text):
    # 잠재적으로 해로운 내용 제거
    cleaned_input = re.sub(r'[<>"\']', '', input_text)
    
    # 입력 길이 제한
    if len(cleaned_input) > 1000:
        cleaned_input = cleaned_input[:1000]
    
    return cleaned_input
```

### 3. 속도 제한

남용을 방지하기 위해 속도 제한을 구현하세요:

```python
from functools import wraps
import time

def rate_limit(max_calls_per_minute=60):
    def decorator(func):
        last_called = {}
        
        @wraps(func)
        def wrapper(*args, **kwargs):
            user_id = kwargs.get('user_id', 'anonymous')
            now = time.time()
            
            if user_id in last_called:
                if now - last_called[user_id] < 60 / max_calls_per_minute:
                    raise Exception("속도 제한 초과")
            
            last_called[user_id] = now
            return func(*args, **kwargs)
        
        return wrapper
    return decorator
```

## 고급 사용 사례

### 1. 문서 처리 파이프라인

문서 처리를 위한 멀티 에이전트 파이프라인 생성:

```python
# 문서 분석 에이전트
analyzer_agent = Agent(analyzer_config)

# 정보 추출 에이전트
extractor_agent = Agent(extractor_config)

# 요약 생성 에이전트
summarizer_agent = Agent(summarizer_config)

# 파이프라인 실행
def process_document(document_path):
    # 1단계: 문서 구조 분석
    analysis = analyzer_agent.process(f"문서 분석: {document_path}")
    
    # 2단계: 핵심 정보 추출
    extraction = extractor_agent.process(f"데이터 추출: {analysis}")
    
    # 3단계: 요약 생성
    summary = summarizer_agent.process(f"요약: {extraction}")
    
    return {
        "analysis": analysis,
        "extracted_data": extraction,
        "summary": summary
    }
```

### 2. 지능형 고객 지원 시스템

포괄적인 고객 지원 시스템 구축:

```python
class CustomerSupportSystem:
    def __init__(self):
        self.routing_agent = Agent(routing_config)
        self.technical_agent = Agent(technical_config)
        self.billing_agent = Agent(billing_config)
        self.escalation_agent = Agent(escalation_config)
    
    def handle_inquiry(self, customer_inquiry):
        # 문의를 적절한 에이전트로 라우팅
        routing_decision = self.routing_agent.process(customer_inquiry)
        
        if routing_decision.category == "technical":
            return self.technical_agent.process(customer_inquiry)
        elif routing_decision.category == "billing":
            return self.billing_agent.process(customer_inquiry)
        elif routing_decision.escalate:
            return self.escalation_agent.process(customer_inquiry)
        else:
            return self.routing_agent.process(customer_inquiry)
```

## 성능 최적화

### 1. 캐싱 전략

응답 시간을 개선하기 위해 캐싱을 구현하세요:

```python
from functools import lru_cache
import hashlib

class CachedAgent:
    def __init__(self, agent):
        self.agent = agent
        self.response_cache = {}
    
    def process(self, input_text):
        # 캐시 키 생성
        cache_key = hashlib.md5(input_text.encode()).hexdigest()
        
        if cache_key in self.response_cache:
            return self.response_cache[cache_key]
        
        # 처리 후 결과 캐시
        response = self.agent.process(input_text)
        self.response_cache[cache_key] = response
        
        return response
```

### 2. 비동기 처리

더 나은 성능을 위해 비동기 처리를 사용하세요:

```python
import asyncio
from google.adk import AsyncAgent

async def process_multiple_requests(requests):
    agent = AsyncAgent(config)
    
    # 요청을 동시에 처리
    tasks = [agent.process_async(request) for request in requests]
    responses = await asyncio.gather(*tasks)
    
    return responses
```

## 테스트 및 품질 보증

### 1. 단위 테스트

에이전트를 위한 포괄적인 테스트를 생성하세요:

```python
import unittest
from unittest.mock import Mock, patch

class TestCustomerServiceAgent(unittest.TestCase):
    def setUp(self):
        self.agent = CustomerServiceAgent(test_config)
    
    def test_greeting_response(self):
        response = self.agent.process("안녕하세요")
        self.assertIn("안녕", response)
        self.assertIn("도움", response.lower())
    
    def test_order_inquiry(self):
        response = self.agent.process("주문 #12345에 대해 도움이 필요해요")
        self.assertIn("주문", response.lower())
    
    @patch('google.adk.llm.generate')
    def test_api_error_handling(self, mock_generate):
        mock_generate.side_effect = Exception("API 오류")
        response = self.agent.process("테스트 입력")
        self.assertIn("기술적 문제", response.lower())
```

### 2. 통합 테스트

에이전트 상호작용 및 워크플로우를 테스트하세요:

```python
def test_multi_agent_workflow():
    system = MultiAgentSystem([agent1, agent2, agent3])
    
    test_input = "이 복잡한 요청을 처리하세요"
    result = system.execute_workflow(workflow, test_input)
    
    assert result.success == True
    assert len(result.steps) == 3
    assert result.final_output is not None
```

## 모니터링 및 분석

### 1. 성능 지표

주요 성과 지표를 추적하세요:

```python
from google.adk.analytics import AgentAnalytics

analytics = AgentAnalytics()

# 응답 시간 추적
analytics.track_metric("response_time", response_time)

# 성공률 추적
analytics.track_metric("success_rate", success_count / total_count)

# 사용자 만족도 추적
analytics.track_metric("user_satisfaction", satisfaction_score)
```

### 2. 로깅 및 디버깅

포괄적인 로깅을 구현하세요:

```python
import logging

# 로깅 구성
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('agent.log'),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)

class LoggedAgent(Agent):
    def process(self, input_text):
        logger.info(f"입력 처리 중: {input_text[:100]}...")
        
        try:
            response = super().process(input_text)
            logger.info(f"응답 생성됨: {response[:100]}...")
            return response
        except Exception as e:
            logger.error(f"처리 오류: {e}")
            raise
```

## 향후 개선사항 및 로드맵

### 1. 향후 기능

Google은 새로운 기능으로 ADK를 지속적으로 개선하고 있습니다:

- **멀티모달 지원**: 비전 및 오디오 처리 통합
- **개선된 도구 생태계**: 사전 구축된 도구의 확장된 라이브러리
- **향상된 오케스트레이션**: 더 나은 멀티 에이전트 조정 메커니즘
- **성능 최적화**: 더 빠른 추론 및 지연 시간 감소

### 2. 커뮤니티 기여

ADK 샘플 저장소는 커뮤니티 기여를 환영합니다:

- **새로운 샘플 에이전트**: 도메인별 예제 기여
- **도구 통합**: 새로운 도구 구현 추가
- **문서화**: 가이드 및 튜토리얼 개선
- **버그 수정**: 문제 보고 및 수정

## 결론

Google의 Agent Development Kit (ADK)는 지능형 멀티 에이전트 시스템을 구축하기 위한 강력한 기반을 제공합니다. 포괄적인 샘플 저장소는 간단한 대화형 에이전트부터 복잡한 멀티 에이전트 워크플로우까지 다양한 사용 사례에 대한 실용적인 예제와 시작점을 제공합니다.

이 튜토리얼의 주요 요점:

1. **간단하게 시작**: 기본 샘플부터 시작하여 점진적으로 더 복잡한 예제를 탐색하세요
2. **신중한 커스터마이징**: 특정 사용 사례에 맞게 구성과 프롬프트를 조정하세요
3. **철저한 테스트**: 프로덕션 준비를 위한 포괄적인 테스트 전략을 구현하세요
4. **지속적인 모니터링**: 성능과 사용자 만족도 지표를 추적하세요
5. **설계 시 보안**: 처음부터 적절한 보안 조치를 구현하세요

ADK 생태계는 계속 발전하고 있으며, 샘플 저장소를 통해 커뮤니티와 지속적으로 소통하면 최신 기능과 모범 사례를 활용하는 데 도움이 될 것입니다.

## 추가 자료

- **공식 문서**: [ADK 문서](https://google.github.io/adk-docs/)
- **GitHub 저장소**: [google/adk-samples](https://github.com/google/adk-samples)
- **개발자 블로그**: [Google 개발자 블로그 - ADK](https://developers.googleblog.com)
- **커뮤니티 포럼**: [ADK 토론](https://github.com/google/adk-samples/discussions)
- **API 레퍼런스**: [ADK API 문서](https://google.github.io/adk-docs/api/)

---

*이 튜토리얼은 Google의 Agent Development Kit 샘플에 대한 포괄적인 소개를 제공합니다. 프레임워크가 계속 발전함에 따라 최신 업데이트와 기능에 대해서는 공식 문서를 확인하시기 바랍니다.*
