---
title: "Vanna: RAG 기반 오픈소스 Text-to-SQL 프레임워크 소개"
excerpt: "데이터베이스와 대화하듯 SQL을 생성하는 Vanna 프로젝트의 핵심 기능과 활용 방법을 살펴봅니다."
date: 2025-06-16
categories:
  - llmops
tags:
  - RAG
  - SQL
  - Vanna
  - Text-to-SQL
author_profile: true
toc: true
toc_label: "Contents"
---

## 프로젝트 개요

[Vanna](https://github.com/vanna-ai/vanna)는 **Retrieval-Augmented Generation(RAG)** 기법을 활용해 자연어 요청을 정확한 SQL 쿼리로 변환해 주는 오픈소스 Python 프레임워크입니다. 테이블 스키마·문서·샘플 쿼리를 학습한 뒤 "Ask" 메서드로 질문을 던지면, 실행 가능한 SQL 과 결과 시각화를 한 번에 제공합니다.

- **라이선스:** MIT
- **스타 수:** 18k+ ⭐ (2025.04 기준)
- **주요 기능:** Text-to-SQL, RAG 학습 파이프라인, 다중 LLM·벡터스토어·DB 지원

## 핵심 특징

| 구분 | 설명 |
|------|------|
| 높은 정확도 | 복잡한 스키마에서도 RAG 학습량에 비례해 정확도를 높일 수 있습니다. |
| BYO 스택 | OpenAI·Anthropic·HuggingFace 등 다양한 LLM, PgVector·Pinecone 등 벡터스토어, PostgreSQL·Snowflake 등 DB 를 자유롭게 조합할 수 있습니다. |
| 보안 & 프라이버시 | 실제 데이터는 LLM·벡터 DB 로 전송되지 않으며 SQL 실행은 로컬 환경에서 이뤄집니다. |
| 자기학습 | 성공적으로 실행된 SQL을 auto-train 하여 추후 정확도를 향상시킵니다. |

## 설치 방법

```bash
pip install vanna
```

선택적 의존성이 많으므로, 사용하려는 LLM·VectorStore·DB 에 맞춰 추가 패키지를 설치해야 합니다.

## 빠른 시작 예제

아래 예시는 **OpenAI + ChromaDB** 조합을 기반으로 최소한의 템플릿을 보여 줍니다.

```python
from vanna.openai.openai_chat import OpenAI_Chat
from vanna.chromadb.chromadb_vector import ChromaDB_VectorStore

class MyVanna(ChromaDB_VectorStore, OpenAI_Chat):
    def __init__(self, config=None):
        ChromaDB_VectorStore.__init__(self, config=config)
        OpenAI_Chat.__init__(self, config=config)

vn = MyVanna(config={
    "api_key": "sk-...",
    "model": "gpt-4o-mini"  # 원하는 OpenAI 모델 ID
})

# 1) 스키마 학습
vn.train(ddl="""
CREATE TABLE orders (
  id INT PRIMARY KEY,
  customer VARCHAR(100),
  total NUMERIC
);
""")

# 2) 질문 → SQL
print(vn.ask("상위 10개 고객의 총 주문 금액은?"))
```

## 지원 스택

- **LLMs:** OpenAI, Anthropic, Gemini, HuggingFace, AWS Bedrock, Ollama 등
- **VectorStores:** ChromaDB, FAISS, Pinecone, Qdrant, Milvus 등
- **Databases:** PostgreSQL, MySQL, ClickHouse, Snowflake, DuckDB 등

## 활용 시나리오

- **BI 팀:** 비개발자도 자연어로 데이터 탐색 및 차트 생성
- **데이터 플랫폼:** SaaS 제품 내 임베디드 분석 기능 제공
- **엔지니어링:** 레거시 SQL 쿼리 자동 생성·리팩토링

## 주의할 점

- **데이터 권한 관리**는 여전히 중요합니다. LLM이 생성한 SQL이 의도치 않은 데이터를 노출하지 않도록 RBAC·열 권한을 설정하세요.
- LLM 요금이 발생하므로 캐싱·쿼리 제한 정책을 설계하는 것이 좋습니다.

## 마무리

Vanna는 RAG 파이프라인을 간결하게 추상화해 Text-to-SQL 워크플로를 빠르게 구축할 수 있게 해 줍니다. 내부 데이터 분석 봇, 고객용 임베디드 쿼리 기능 등 다양한 영역에서 활용해 보세요. 