---
title: "RAGFlow 튜토리얼: 설치부터 기본 사용까지"
excerpt: "오픈소스 Retrieval-Augmented Generation 엔진인 RAGFlow를 Docker 기반으로 설치하고 기본 채팅봇을 구축하는 과정을 단계별로 살펴봅니다."
date: 2025-06-16
categories:
  - tutorials
  - llmops
tags:
  - ragflow
  - RAG
  - LLMOPS
author_profile: true
toc: true
toc_label: RAGFlow Tutorial
---

## 개요

**RAGFlow**는 문서 이해에 특화된 Retrieval-Augmented Generation(RAG) 엔진입니다. 오픈소스로 공개되어 있어 누구나 설치 및 확장이 가능하며, PDF·표·SQL 등 다양한 형식의 정보를 LLM과 결합해 고품질 답변을 생성합니다. 본 튜토리얼에서는 GitHub 저장소에 공개된 [RAGFlow](https://github.com/infiniflow/ragflow) 프로젝트를 Docker로 설치하고, 기본 대시보드에 접속해 첫 질문을 던져보기까지의 전 과정을 다룹니다.

## 사전 요구사항

- Docker 24 이상, Docker Compose v2 이상
- 최소 16 GB RAM (Slim 이미지 사용 시 8 GB도 가능)
- x86-64 Linux·macOS·Windows (ARM Mac의 경우 직접 이미지를 빌드해야 함)
- 공개 LLM API 키(OpenAI, DeepSeek 등) 또는 내부 프록시

### 시스템 확인 예시

```bash
# Docker, Compose 버전 확인
docker --version
docker compose version
```

## 1. 빠른 설치(슬림 이미지)

RAGFlow는 **`v0.19.0-slim`** 이미지를 제공하여 2 GB 내외로 빠르게 체험할 수 있습니다. 아래 명령은 CPU만 사용해 컨테이너를 실행합니다.

```bash
# 1) 저장소 클론
git clone https://github.com/infiniflow/ragflow.git
cd ragflow/docker

# 2) 서버 기동
docker compose -f docker-compose.yml up -d
```

> GPU를 활용하려면 `docker-compose-gpu.yml` 파일을 선택하세요.

### 실행 상태 확인

```bash
docker logs -f ragflow-server | cat
```

아래와 유사한 배너가 출력되면 초기화가 완료된 것입니다.

```text
 ____   ___    ______ ______ __
/ __ \ /   |  / ____// ____// /____  _      __
... 생략 ...
```

## 2. 대시보드 접속 및 첫 질문

1. 브라우저 주소창에 `http://IP_OF_YOUR_MACHINE`를 입력합니다.
2. 관리자 계정을 생성하거나 기본 계정으로 로그인합니다.
3. 우측 상단 톱니바퀴 → **Service Config**에서 `user_default_llm` 항목을 원하는 LLM 서비스(OpenAI 등)로 선택한 뒤 API Key를 입력합니다.
4. **Chat** 탭으로 이동해 "RAGFlow 설치가 완료되었나요?"와 같이 질문해 정상 동작을 확인합니다.

## 3. 주요 설정 살펴보기

RAGFlow는 세 개 파일로 대부분의 환경을 제어합니다.

| 파일 | 역할 |
| --- | --- |
| `.env` | 포트·비밀번호 등 기본 환경변수 |
| `service_conf.yaml.template` | 백엔드 서비스별 상세 설정 |
| `docker-compose.yml` | 컨테이너 오케스트레이션 |

예를 들어 기본 HTTP 포트 `80`을 `8080`으로 바꾸려면 `docker-compose.yml`에서 아래 부분을 수정합니다.

```yaml
ports:
  - "8080:80"
```

수정 후 컨테이너를 재시작합니다.

```bash
docker compose -f docker-compose.yml up -d
```

### Elasticsearch → Infinity 전환

벡터·전문 검색 엔진을 **Elasticsearch**에서 **Infinity**로 변경하려면 다음 절차를 따릅니다.

1. 기존 컨테이너 중지 및 볼륨 삭제(데이터 초기화 주의)

   ```bash
   docker compose -f docker/docker-compose.yml down -v
   ```

2. `docker/.env`에서 `DOC_ENGINE=infinity`로 변경
3. 컨테이너 재기동

   ```bash
   docker compose -f docker-compose.yml up -d
   ```

> Infinity는 Linux/arm64 환경을 공식 지원하지 않습니다.

## 4. Python SDK 활용 예제

RAGFlow는 `/sdk/python` 폴더에 Python SDK를 제공합니다. 로컬 개발 환경에서 다음과 같이 간단히 호스트에 질의를 보낼 수 있습니다.

```python
from ragflow.sdk import Client

client = Client("http://localhost")  # 포트 변경 시 반영

answer = client.chat("RAGFlow란 무엇인가요?")
print(answer.text)
```

## 5. 컨테이너 종료 및 정리

```bash
# 프론트엔드·백엔드 모두 종료
docker compose -f docker-compose.yml down

# 볼륨까지 삭제하려면 -v 플래그 추가
docker compose -f docker-compose.yml down -v
```

## 마무리

이번 글에서는 RAGFlow를 **Docker**로 빠르게 배포하고, 대시보드에서 기본 채팅을 수행하는 과정을 살펴보았습니다. 다음 편에서는 PDF 업로드, Agentic Reasoning, 그래프 기반 RAG(GraphRAG) 등 고급 기능을 심화 탐구할 예정입니다.

> 본 튜토리얼은 GitHub `main` 브랜치 기준 **v0.19.0** 릴리스를 참조했습니다. 최신 정보는 항상 [RAGFlow GitHub](https://github.com/infiniflow/ragflow) 레포지토리를 확인하세요.
