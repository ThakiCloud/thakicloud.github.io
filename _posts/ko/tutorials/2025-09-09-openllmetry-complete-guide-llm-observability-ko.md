---
title: "OpenLLMetry 완전 가이드: OpenTelemetry를 활용한 LLM 관찰 가능성"
excerpt: "OpenLLMetry를 사용하여 AI 애플리케이션의 포괄적인 관찰 가능성을 구현하는 방법을 배워보세요. 오픈소스 솔루션으로 LLM 모니터링을 완벽하게 구현합니다."
seo_title: "OpenLLMetry 튜토리얼: LLM 관찰 가능성 및 모니터링 가이드 - Thaki Cloud"
seo_description: "OpenLLMetry를 활용한 LLM 관찰 가능성 완전 튜토리얼. 설치, 구성, AI 애플리케이션 모니터링을 실제 예제와 함께 학습하세요."
date: 2025-09-09
categories:
  - tutorials
tags:
  - openllmetry
  - llm-observability
  - opentelemetry
  - ai-monitoring
  - machine-learning
  - python
author_profile: true
toc: true
toc_label: "목차"
lang: ko
permalink: /ko/tutorials/openllmetry-complete-guide-llm-observability/
canonical_url: "https://thakicloud.github.io/ko/tutorials/openllmetry-complete-guide-llm-observability/"
published: false
---

⏱️ **예상 읽기 시간**: 15분

## 소개

대규모 언어 모델(LLM) 애플리케이션이 점점 복잡해지고 프로덕션에 배포되면서 모니터링과 관찰 가능성이 필수 요구사항이 되었습니다. [OpenLLMetry](https://github.com/traceloop/openllmetry)는 OpenTelemetry 표준을 통해 LLM 애플리케이션에 엔터프라이즈급 관찰 가능성을 제공하는 포괄적인 솔루션입니다.

OpenLLMetry는 LLM 애플리케이션을 위해 특별히 설계된 오픈소스 관찰 가능성 플랫폼입니다. OpenTelemetry 위에 구축되어 AI 애플리케이션의 성능, 비용, 행동에 대한 완전한 가시성을 제공하면서 기존 관찰 가능성 인프라와의 호환성을 유지합니다.

### OpenLLMetry가 중요한 이유

기존 모니터링 도구는 LLM 애플리케이션에 적용할 때 한계가 있습니다. OpenLLMetry는 다음과 같은 고유한 과제를 해결합니다:

- **토큰 사용량 추적**: 입력/출력 토큰과 관련 비용 모니터링
- **지연 시간 분석**: 다양한 모델 제공업체 간 응답 시간 추적
- **오류 모니터링**: LLM 특유의 오류와 실패 캡처 및 분석
- **성능 최적화**: AI 워크플로우의 병목 지점 식별
- **비용 관리**: 여러 LLM 제공업체의 지출 모니터링

## 사전 요구사항

OpenLLMetry를 시작하기 전에 다음이 필요합니다:

- **Python 3.8+** 시스템 설치
- **OpenTelemetry 개념에 대한 기본 이해**
- **모니터링할 LLM 애플리케이션** (OpenAI, Anthropic 등)
- **관찰 가능성 백엔드** (고급 설정을 위해 선택사항)

## 1부: OpenLLMetry 시작하기

### 설치 및 기본 설정

가장 간단한 설정부터 시작해보겠습니다. OpenLLMetry는 손쉽게 시작할 수 있는 편리한 SDK를 제공합니다.

#### 1단계: OpenLLMetry SDK 설치

```bash
# 핵심 SDK 설치
pip install traceloop-sdk

# 특정 통합을 위해 추가 패키지 설치
pip install openai anthropic  # LLM 제공업체 예시
```

#### 2단계: 기본 초기화

LLM 애플리케이션 모니터링을 시작하는 가장 간단한 방법은 코드 한 줄입니다:

```python
from traceloop.sdk import Traceloop

# 기본 설정으로 OpenLLMetry 초기화
Traceloop.init()
```

로컬 개발 환경에서는 즉시 추적을 확인하고 싶을 수 있습니다:

```python
# 즉시 추적 가시성을 위해 배치 전송 비활성화
Traceloop.init(disable_batch=True)
```

#### 3단계: 첫 번째 모니터링 LLM 호출

기본 모니터링을 보여주는 완전한 예제입니다:

```python
import openai
from traceloop.sdk import Traceloop

# OpenLLMetry 초기화
Traceloop.init(disable_batch=True)

# OpenAI 클라이언트 구성
client = openai.OpenAI(api_key="your-api-key")

# 모니터링된 LLM 호출
def generate_response(prompt):
    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "user", "content": prompt}
        ],
        max_tokens=100
    )
    return response.choices[0].message.content

# 모니터링된 함수 테스트
if __name__ == "__main__":
    result = generate_response("양자 컴퓨팅을 간단한 용어로 설명해주세요")
    print(result)
```

이 코드를 실행하면 OpenLLMetry가 자동으로:
- 요청과 응답을 캡처
- 토큰 사용량과 비용을 기록
- 응답 지연 시간을 측정
- 발생하는 모든 오류를 추적

## 2부: 고급 구성

### 데코레이터를 활용한 사용자 정의 추적

OpenLLMetry는 애플리케이션 로직의 사용자 정의 추적을 위한 데코레이터를 제공합니다:

```python
from traceloop.sdk import Traceloop
from traceloop.sdk.decorators import task, workflow

# OpenLLMetry 초기화
Traceloop.init()

@workflow(name="document_analysis_pipeline")
def analyze_document(document_text):
    """문서 분석을 위한 메인 워크플로우"""
    summary = summarize_text(document_text)
    sentiment = analyze_sentiment(document_text)
    keywords = extract_keywords(document_text)
    
    return {
        "summary": summary,
        "sentiment": sentiment,
        "keywords": keywords
    }

@task(name="text_summarization")
def summarize_text(text):
    """입력 텍스트를 요약"""
    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "system", "content": "다음 텍스트를 간결하게 요약하세요."},
            {"role": "user", "content": text}
        ],
        max_tokens=150
    )
    return response.choices[0].message.content

@task(name="sentiment_analysis")
def analyze_sentiment(text):
    """텍스트의 감정을 분석"""
    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "system", "content": "이 텍스트의 감정을 분석하세요. 긍정적, 부정적, 또는 중립적으로 응답하세요."},
            {"role": "user", "content": text}
        ],
        max_tokens=10
    )
    return response.choices[0].message.content

@task(name="keyword_extraction")
def extract_keywords(text):
    """텍스트에서 핵심 용어를 추출"""
    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "system", "content": "이 텍스트에서 5개의 핵심 용어를 추출하세요. 쉼표로 구분된 목록으로 반환하세요."},
            {"role": "user", "content": text}
        ],
        max_tokens=50
    )
    return response.choices[0].message.content
```

### 환경 기반 구성

프로덕션 배포를 위해 환경 변수를 통해 OpenLLMetry를 구성하세요:

```bash
# 환경 변수 설정
export TRACELOOP_API_KEY="your-traceloop-api-key"
export TRACELOOP_BATCH_EXPORT="true"
export TRACELOOP_TELEMETRY="false"  # 필요시 텔레메트리 비활성화
```

```python
import os
from traceloop.sdk import Traceloop

# 프로덕션 구성
Traceloop.init(
    api_key=os.getenv("TRACELOOP_API_KEY"),
    disable_batch=os.getenv("TRACELOOP_BATCH_EXPORT", "true").lower() == "false",
    telemetry_enabled=os.getenv("TRACELOOP_TELEMETRY", "true").lower() == "true"
)
```

## 3부: 인기 LLM 프레임워크와의 통합

### LangChain 통합

OpenLLMetry는 LangChain 애플리케이션과 완벽하게 통합됩니다:

```python
from langchain.llms import OpenAI
from langchain.chains import LLMChain
from langchain.prompts import PromptTemplate
from traceloop.sdk import Traceloop

# OpenLLMetry 초기화
Traceloop.init()

# LangChain 구성 요소 생성
llm = OpenAI(temperature=0.7)
prompt = PromptTemplate(
    input_variables=["topic"],
    template="{topic}에 대한 간단한 설명을 작성하세요"
)

# 체인 생성 및 실행
chain = LLMChain(llm=llm, prompt=prompt)

# 자동으로 추적됩니다
result = chain.run(topic="머신러닝")
print(result)
```

### LlamaIndex 통합

LlamaIndex 애플리케이션의 경우:

```python
from llama_index import VectorStoreIndex, SimpleDirectoryReader
from llama_index.llms import OpenAI
from traceloop.sdk import Traceloop

# OpenLLMetry 초기화
Traceloop.init()

# LlamaIndex 구성
llm = OpenAI(model="gpt-3.5-turbo")

# 문서 로드 및 인덱스 생성
documents = SimpleDirectoryReader("data").load_data()
index = VectorStoreIndex.from_documents(documents)

# 쿼리 엔진 생성
query_engine = index.as_query_engine(llm=llm)

# 자동 추적과 함께 쿼리
response = query_engine.query("이 문서들의 주요 주제는 무엇인가요?")
print(response)
```

## 4부: 벡터 데이터베이스 모니터링

OpenLLMetry는 벡터 데이터베이스 작업도 모니터링합니다:

### Pinecone 통합

```python
import pinecone
from traceloop.sdk import Traceloop

# OpenLLMetry 초기화
Traceloop.init()

# Pinecone 초기화
pinecone.init(
    api_key="your-pinecone-api-key",
    environment="your-environment"
)

# 인덱스 참조 생성
index = pinecone.Index("your-index-name")

# 모니터링된 벡터 작업
def search_similar_documents(query_vector, top_k=5):
    """벡터 유사도를 사용한 유사 문서 검색"""
    results = index.query(
        vector=query_vector,
        top_k=top_k,
        include_metadata=True
    )
    return results

# 모니터링된 업서트 작업
def store_document_embedding(doc_id, embedding, metadata):
    """Pinecone에 문서 임베딩 저장"""
    index.upsert([
        (doc_id, embedding, metadata)
    ])
```

### Chroma 통합

```python
import chromadb
from traceloop.sdk import Traceloop

# OpenLLMetry 초기화
Traceloop.init()

# Chroma 클라이언트 초기화
client = chromadb.Client()

# 컬렉션 가져오기 또는 생성
collection = client.get_or_create_collection("documents")

# 모니터링된 작업
def add_documents(documents, embeddings, ids, metadatas):
    """Chroma 컬렉션에 문서 추가"""
    collection.add(
        documents=documents,
        embeddings=embeddings,
        ids=ids,
        metadatas=metadatas
    )

def query_documents(query_text, n_results=5):
    """Chroma에서 유사 문서 쿼리"""
    results = collection.query(
        query_texts=[query_text],
        n_results=n_results
    )
    return results
```

## 5부: 관찰 가능성 백엔드 통합

### Datadog 통합

엔터프라이즈 모니터링을 위해 OpenLLMetry를 Datadog에 연결:

```python
from opentelemetry import trace
from opentelemetry.exporter.datadog import DatadogExporter, DatadogSpanProcessor
from opentelemetry.sdk.trace import TracerProvider
from traceloop.sdk import Traceloop

# Datadog 내보내기 구성
tracer_provider = TracerProvider()
datadog_exporter = DatadogExporter(
    agent_url="http://localhost:8126",  # Datadog Agent URL
    service="llm-application"
)

# Datadog 스팬 프로세서 추가
tracer_provider.add_span_processor(
    DatadogSpanProcessor(datadog_exporter)
)

# 추적 제공자 설정
trace.set_tracer_provider(tracer_provider)

# 사용자 정의 추적기로 OpenLLMetry 초기화
Traceloop.init()
```

### Honeycomb 통합

Honeycomb 관찰 가능성을 위해:

```python
import os
from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from traceloop.sdk import Traceloop

# Honeycomb 내보내기 구성
tracer_provider = TracerProvider()

otlp_exporter = OTLPSpanExporter(
    endpoint="https://api.honeycomb.io/v1/traces",
    headers={
        "x-honeycomb-team": os.getenv("HONEYCOMB_API_KEY"),
        "x-honeycomb-dataset": "llm-traces"
    }
)

# 배치 스팬 프로세서 추가
tracer_provider.add_span_processor(
    BatchSpanProcessor(otlp_exporter)
)

# 추적 제공자 설정
trace.set_tracer_provider(tracer_provider)

# OpenLLMetry 초기화
Traceloop.init()
```

## 6부: 사용자 정의 메트릭과 속성

### 사용자 정의 속성 추가

비즈니스 로직으로 추적을 향상시키세요:

```python
from traceloop.sdk import Traceloop
from traceloop.sdk.decorators import task
from opentelemetry import trace

# OpenLLMetry 초기화
Traceloop.init()

@task(name="customer_support_response")
def handle_customer_query(query, customer_id, priority="normal"):
    """사용자 정의 속성을 포함한 고객 지원 쿼리 처리"""
    
    # 현재 스팬 가져오기
    current_span = trace.get_current_span()
    
    # 사용자 정의 속성 추가
    current_span.set_attribute("customer.id", customer_id)
    current_span.set_attribute("query.priority", priority)
    current_span.set_attribute("query.length", len(query))
    
    # 우선순위에 따른 모델 결정
    model = "gpt-4" if priority == "high" else "gpt-3.5-turbo"
    current_span.set_attribute("llm.model", model)
    
    # 응답 생성
    response = client.chat.completions.create(
        model=model,
        messages=[
            {"role": "system", "content": "당신은 도움이 되는 고객 지원 상담원입니다."},
            {"role": "user", "content": query}
        ]
    )
    
    # 응답 속성 추가
    response_text = response.choices[0].message.content
    current_span.set_attribute("response.length", len(response_text))
    current_span.set_attribute("response.satisfactory", "unknown")  # ML 모델로 결정 가능
    
    return response_text
```

### 사용자 정의 메트릭 수집

비즈니스 KPI를 위한 사용자 정의 메트릭 생성:

```python
from opentelemetry import metrics
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.metrics.export import ConsoleMetricExporter, PeriodicExportingMetricReader
import time

# 메트릭 구성
metric_reader = PeriodicExportingMetricReader(
    ConsoleMetricExporter(), 
    export_interval_millis=5000
)
metrics.set_meter_provider(MeterProvider(metric_readers=[metric_reader]))

# 사용자 정의 측정기 생성
meter = metrics.get_meter("llm_application")

# 사용자 정의 메트릭 생성
request_counter = meter.create_counter(
    "llm_requests_total",
    description="총 LLM 요청 수"
)

response_time_histogram = meter.create_histogram(
    "llm_response_time",
    description="LLM 응답 시간(초)"
)

token_usage_counter = meter.create_counter(
    "llm_tokens_used",
    description="총 소비된 토큰"
)

def monitored_llm_call(prompt, model="gpt-3.5-turbo"):
    """사용자 정의 메트릭을 포함한 LLM 호출"""
    start_time = time.time()
    
    try:
        # 요청 카운터 증가
        request_counter.add(1, {"model": model})
        
        # LLM 호출
        response = client.chat.completions.create(
            model=model,
            messages=[{"role": "user", "content": prompt}]
        )
        
        # 응답 시간 기록
        response_time = time.time() - start_time
        response_time_histogram.record(response_time, {"model": model})
        
        # 토큰 사용량 기록
        usage = response.usage
        token_usage_counter.add(usage.total_tokens, {
            "model": model,
            "type": "total"
        })
        token_usage_counter.add(usage.prompt_tokens, {
            "model": model,
            "type": "prompt"
        })
        token_usage_counter.add(usage.completion_tokens, {
            "model": model,
            "type": "completion"
        })
        
        return response.choices[0].message.content
        
    except Exception as e:
        request_counter.add(1, {"model": model, "status": "error"})
        raise
```

## 7부: 프로덕션 모범 사례

### 오류 처리 및 복원력

프로덕션 환경을 위한 견고한 오류 처리 구현:

```python
from traceloop.sdk import Traceloop
from opentelemetry import trace
import logging
import sys

# 로깅 구성
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# 오류 처리와 함께 OpenLLMetry 초기화
try:
    Traceloop.init(
        disable_batch=False,  # 프로덕션에서 배치 활성화
        telemetry_enabled=False  # 프라이버시를 위해 텔레메트리 비활성화
    )
    logger.info("OpenLLMetry가 성공적으로 초기화되었습니다")
except Exception as e:
    logger.error(f"OpenLLMetry 초기화 실패: {e}")
    # 애플리케이션을 실패시키지 않고 추적 없이 계속
    pass

def safe_llm_call(prompt, max_retries=3, backoff_factor=2):
    """재시도 로직과 포괄적인 오류 처리를 포함한 LLM 호출"""
    
    span = trace.get_current_span()
    
    for attempt in range(max_retries):
        try:
            span.set_attribute("retry.attempt", attempt + 1)
            
            response = client.chat.completions.create(
                model="gpt-3.5-turbo",
                messages=[{"role": "user", "content": prompt}],
                timeout=30  # 프로덕션에서 타임아웃 설정
            )
            
            span.set_attribute("request.successful", True)
            return response.choices[0].message.content
            
        except openai.RateLimitError as e:
            span.set_attribute("error.type", "rate_limit")
            span.set_attribute("error.message", str(e))
            
            if attempt < max_retries - 1:
                wait_time = backoff_factor ** attempt
                logger.warning(f"속도 제한에 도달, 재시도 전 {wait_time}초 대기")
                time.sleep(wait_time)
            else:
                span.set_attribute("request.successful", False)
                raise
                
        except openai.APIError as e:
            span.set_attribute("error.type", "api_error")
            span.set_attribute("error.message", str(e))
            span.set_attribute("request.successful", False)
            
            logger.error(f"OpenAI API 오류: {e}")
            raise
            
        except Exception as e:
            span.set_attribute("error.type", "unknown")
            span.set_attribute("error.message", str(e))
            span.set_attribute("request.successful", False)
            
            logger.error(f"예상치 못한 오류: {e}")
            raise
```

### 성능 최적화

높은 처리량 애플리케이션을 위한 OpenLLMetry 최적화:

```python
from traceloop.sdk import Traceloop
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.sdk.trace import TracerProvider
import os

# 고성능 구성
tracer_provider = TracerProvider()

# 높은 처리량을 위한 배치 프로세서 구성
batch_processor = BatchSpanProcessor(
    span_exporter=your_exporter,  # 선택한 내보내기
    max_queue_size=2048,  # 큐 크기 증가
    export_timeout_millis=30000,  # 30초 타임아웃
    max_export_batch_size=512,  # 더 큰 배치 크기
    schedule_delay_millis=500  # 더 빈번한 내보내기
)

tracer_provider.add_span_processor(batch_processor)

# 성능 최적화와 함께 초기화
Traceloop.init(
    disable_batch=False,
    resource_attributes={
        "service.name": "llm-application",
        "service.version": "1.0.0",
        "deployment.environment": os.getenv("ENVIRONMENT", "production")
    }
)
```

### 보안 및 프라이버시 고려사항

보안 모범 사례 구현:

```python
from traceloop.sdk import Traceloop
from opentelemetry import trace
import hashlib
import re

# 프라이버시 중심 구성으로 초기화
Traceloop.init(
    telemetry_enabled=False,  # 텔레메트리 비활성화
    api_key=os.getenv("TRACELOOP_API_KEY")  # 환경 변수 사용
)

def sanitize_prompt(prompt):
    """추적 전 프롬프트에서 민감한 정보 제거"""
    
    # 이메일 주소 제거
    prompt = re.sub(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b', '[EMAIL]', prompt)
    
    # 전화번호 제거
    prompt = re.sub(r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b', '[PHONE]', prompt)
    
    # 신용카드 번호 제거
    prompt = re.sub(r'\b\d{4}[-\s]?\d{4}[-\s]?\d{4}[-\s]?\d{4}\b', '[CREDIT_CARD]', prompt)
    
    return prompt

def secure_llm_call(prompt, include_prompt_in_trace=False):
    """프라이버시 보호를 포함한 LLM 호출"""
    
    span = trace.get_current_span()
    
    # 내용을 노출하지 않고 추적을 위해 원본 프롬프트 해시
    prompt_hash = hashlib.sha256(prompt.encode()).hexdigest()[:16]
    span.set_attribute("prompt.hash", prompt_hash)
    span.set_attribute("prompt.length", len(prompt))
    
    # 선택적으로 정제된 프롬프트 포함
    if include_prompt_in_trace:
        sanitized_prompt = sanitize_prompt(prompt)
        span.set_attribute("prompt.sanitized", sanitized_prompt)
    
    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[{"role": "user", "content": prompt}]
    )
    
    # 프라이버시를 위해 응답 내용을 추적에 포함하지 않음
    response_text = response.choices[0].message.content
    span.set_attribute("response.length", len(response_text))
    span.set_attribute("response.hash", hashlib.sha256(response_text.encode()).hexdigest()[:16])
    
    return response_text
```

## 8부: 모니터링 및 알림

### 알림 설정

일반적인 LLM 애플리케이션 문제에 대한 알림 구성:

```python
from traceloop.sdk import Traceloop
from opentelemetry import trace
import time

# OpenLLMetry 초기화
Traceloop.init()

class LLMMonitor:
    def __init__(self):
        self.error_count = 0
        self.total_requests = 0
        self.total_cost = 0.0
        self.response_times = []
    
    def track_request(self, success=True, cost=0.0, response_time=0.0):
        """알림을 위한 요청 메트릭 추적"""
        self.total_requests += 1
        self.total_cost += cost
        self.response_times.append(response_time)
        
        if not success:
            self.error_count += 1
        
        # 이동 평균을 위해 최근 100개 응답 시간만 유지
        if len(self.response_times) > 100:
            self.response_times.pop(0)
        
        # 알림 조건 확인
        self.check_alerts()
    
    def check_alerts(self):
        """알림 조건 확인"""
        
        # 높은 오류율 알림
        if self.total_requests > 10:
            error_rate = self.error_count / self.total_requests
            if error_rate > 0.1:  # 10% 오류율
                self.send_alert(f"높은 오류율: {error_rate:.2%}")
        
        # 높은 응답 시간 알림
        if len(self.response_times) > 10:
            avg_response_time = sum(self.response_times[-10:]) / 10
            if avg_response_time > 5.0:  # 5초 평균
                self.send_alert(f"높은 응답 시간: {avg_response_time:.2f}초")
        
        # 비용 알림
        if self.total_cost > 100.0:  # $100 임계값
            self.send_alert(f"높은 비용: ${self.total_cost:.2f}")
    
    def send_alert(self, message):
        """알림 전송 (선호하는 알림 방법 구현)"""
        print(f"알림: {message}")
        # 여기에 Slack, 이메일 또는 기타 알림 구현

# 전역 모니터 인스턴스
monitor = LLMMonitor()

def monitored_llm_call_with_alerting(prompt):
    """모니터링 및 알림을 포함한 LLM 호출"""
    start_time = time.time()
    span = trace.get_current_span()
    
    try:
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[{"role": "user", "content": prompt}]
        )
        
        # 메트릭 계산
        response_time = time.time() - start_time
        cost = estimate_cost(response.usage)  # 비용 계산 구현
        
        # 성공한 요청 추적
        monitor.track_request(success=True, cost=cost, response_time=response_time)
        
        # 스팬에 메트릭 추가
        span.set_attribute("request.cost", cost)
        span.set_attribute("request.response_time", response_time)
        
        return response.choices[0].message.content
        
    except Exception as e:
        response_time = time.time() - start_time
        
        # 실패한 요청 추적
        monitor.track_request(success=False, response_time=response_time)
        
        # 스팬에 오류 정보 추가
        span.set_attribute("request.failed", True)
        span.set_attribute("error.message", str(e))
        
        raise

def estimate_cost(usage, model="gpt-3.5-turbo"):
    """토큰 사용량을 기반으로 요청 비용 추정"""
    # 간단한 비용 계산 (현재 가격으로 업데이트)
    pricing = {
        "gpt-3.5-turbo": {"input": 0.001, "output": 0.002}  # 1K 토큰당
    }
    
    if model in pricing:
        input_cost = (usage.prompt_tokens / 1000) * pricing[model]["input"]
        output_cost = (usage.completion_tokens / 1000) * pricing[model]["output"]
        return input_cost + output_cost
    
    return 0.0
```

## 테스트 및 검증

OpenLLMetry 설정을 검증하기 위한 포괄적인 테스트 스크립트를 생성해보겠습니다:

```python
#!/usr/bin/env python3
"""
OpenLLMetry 테스트 스크립트
OpenLLMetry 설치 및 구성을 검증하기 위해 실행하세요.
"""

import os
import sys
import time
from traceloop.sdk import Traceloop
from traceloop.sdk.decorators import task, workflow

def test_basic_initialization():
    """기본 OpenLLMetry 초기화 테스트"""
    print("기본 초기화 테스트 중...")
    
    try:
        Traceloop.init(disable_batch=True)
        print("✅ OpenLLMetry가 성공적으로 초기화되었습니다")
        return True
    except Exception as e:
        print(f"❌ 초기화 실패: {e}")
        return False

@task(name="test_task")
def test_custom_tracing():
    """사용자 정의 추적 데코레이터 테스트"""
    print("사용자 정의 추적 테스트 중...")
    time.sleep(0.1)  # 작업 시뮬레이션
    return "작업 완료"

@workflow(name="test_workflow")
def test_workflow_tracing():
    """워크플로우 레벨 추적 테스트"""
    print("워크플로우 추적 테스트 중...")
    result = test_custom_tracing()
    return f"워크플로우 결과: {result}"

def test_environment_configuration():
    """환경 기반 구성 테스트"""
    print("환경 구성 테스트 중...")
    
    # 환경 변수 확인
    required_vars = ["TRACELOOP_API_KEY"]
    optional_vars = ["TRACELOOP_BATCH_EXPORT", "TRACELOOP_TELEMETRY"]
    
    for var in required_vars:
        if not os.getenv(var):
            print(f"⚠️  경고: {var}가 설정되지 않았습니다")
    
    for var in optional_vars:
        value = os.getenv(var, "설정되지 않음")
        print(f"ℹ️  {var}: {value}")

def run_tests():
    """모든 테스트 실행"""
    print("🚀 OpenLLMetry 테스트 실행")
    print("=" * 40)
    
    tests = [
        test_basic_initialization,
        test_environment_configuration,
        test_workflow_tracing
    ]
    
    results = []
    for test in tests:
        try:
            result = test()
            results.append(result)
            print()
        except Exception as e:
            print(f"❌ 테스트 {test.__name__} 실패: {e}")
            results.append(False)
            print()
    
    # 요약
    passed = sum(1 for r in results if r)
    total = len(results)
    
    print("=" * 40)
    print(f"테스트 결과: {passed}/{total} 통과")
    
    if passed == total:
        print("🎉 모든 테스트가 통과했습니다! OpenLLMetry를 사용할 준비가 되었습니다.")
    else:
        print("⚠️  일부 테스트가 실패했습니다. 구성과 의존성을 확인하세요.")

if __name__ == "__main__":
    run_tests()
```

## 결론

OpenLLMetry는 LLM 애플리케이션 관찰 가능성을 위한 포괄적인 솔루션을 제공하며, 기존 OpenTelemetry 인프라와의 완벽한 통합을 제공하면서 AI 애플리케이션의 고유한 모니터링 요구사항을 해결합니다.

### 주요 요점

1. **간단한 설정**: 몇 줄의 코드로 시작 가능
2. **프레임워크 통합**: LangChain, LlamaIndex 등 인기 프레임워크와 완벽 연동
3. **프로덕션 준비**: 견고한 오류 처리, 성능 최적화, 보안 기능 포함
4. **확장 가능**: 사용자 정의 메트릭, 속성, 백엔드 통합 지원
5. **비용 효율적**: 여러 관찰 가능성 백엔드를 지원하는 오픈소스

### 다음 단계

1. **작게 시작**: 개발 환경에서 기본 모니터링부터 시작
2. **사용자 정의 메트릭 추가**: 사용 사례별 비즈니스 추적 구현
3. **프로덕션 배포**: 견고한 오류 처리 및 알림 구성
4. **팀 통합**: 기존 관찰 가능성 인프라에 연결
5. **지속적 개선**: 인사이트를 활용해 성능과 비용 최적화

OpenLLMetry는 LLM 애플리케이션 모니터링을 후속 작업이 아닌 일급 기능으로 변화시켜, 더 안정적이고 성능이 뛰어나며 비용 효율적인 AI 애플리케이션을 구축할 수 있게 해줍니다.

더 자세한 정보는 [OpenLLMetry GitHub 저장소](https://github.com/traceloop/openllmetry)를 방문하거나 [공식 문서](https://www.traceloop.com/openllmetry)를 확인하세요.

---

*즐거운 모니터링! 🚀*
