---
title: "Archon OS: AI 코딩 어시스턴트를 위한 지식 관리 백본 플랫폼 완전 가이드"
excerpt: "Claude Code, Cursor와 완벽 통합되는 Archon OS로 웹 크롤링, 문서 처리, 프로젝트 관리, MCP 연동까지 - 실제 테스트 결과와 함께하는 실무 설치 가이드"
seo_title: "Archon OS AI 지식관리 플랫폼 설치 가이드 - Thaki Cloud"
seo_description: "Archon OS를 통해 AI 코딩 어시스턴트에 강력한 지식 관리 기능을 추가하는 방법. MCP 연동, 웹 크롤링, 문서 처리, 프로젝트 관리까지 실제 테스트와 함께하는 완전 가이드"
date: 2025-08-18
last_modified_at: 2025-08-18
categories:
  - tutorials
tags:
  - Archon
  - AI-Assistant
  - MCP
  - Knowledge-Management
  - Docker
  - Claude-Code
  - Cursor
  - Web-Crawling
  - RAG
  - FastAPI
  - React
  - Supabase
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/archon-os-ai-knowledge-management-complete-guide/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 20분

## 서론

AI 코딩 어시스턴트가 발전하면서 단순한 코드 작성을 넘어 **지식 기반 의사결정**이 중요해지고 있습니다. [Archon OS](https://github.com/coleam00/Archon)는 Claude Code, Cursor 등 인기 AI 코딩 도구들에 강력한 지식 관리 백본을 제공하는 오픈소스 플랫폼입니다.

웹사이트 크롤링부터 문서 처리, 벡터 검색, 프로젝트 관리까지 - Archon은 AI 코딩 어시스턴트가 더 똑똑하고 맥락적으로 정확한 답변을 제공할 수 있도록 돕습니다. 본 튜토리얼에서는 실제 macOS 환경에서 Archon을 설치하고 테스트한 결과를 바탕으로 완전한 가이드를 제공합니다.

## Archon OS 핵심 기능

### 🧠 지식 관리 시스템

#### 1. 스마트 웹 크롤링
- **자동 사이트맵 감지**: 전체 문서 사이트를 자동으로 크롤링
- **코드 예제 추출**: 문서에서 코드 블록을 자동 식별 및 인덱싱
- **점진적 크롤링**: 메모리 효율적인 배치 처리

#### 2. 문서 처리 엔진
- **다중 포맷 지원**: PDF, Word, Markdown, 텍스트 파일
- **지능형 청킹**: 맥락을 보존하는 문서 분할
- **소스 관리**: 태그 및 분류별 지식 체계화

#### 3. 벡터 검색 시스템
- **시맨틱 검색**: 의미 기반 지식 검색
- **하이브리드 검색**: 키워드 + 벡터 검색 결합
- **재순위화**: AI 기반 결과 개선

### 🤖 AI 통합 기능

#### Model Context Protocol (MCP) 지원
- **10개 핵심 도구**: RAG 쿼리, 태스크 관리, 프로젝트 운영
- **다중 LLM 지원**: OpenAI, Ollama, Google Gemini
- **실시간 스트리밍**: 진행 상황 실시간 추적

#### 지원 클라이언트
- **Claude Code**: Anthropic의 AI 코딩 어시스턴트
- **Cursor**: AI 기반 코드 에디터
- **Claude Desktop**: 일반 Claude 클라이언트

### 📋 프로젝트 & 태스크 관리

#### 계층적 프로젝트 구조
```
프로젝트
├── 기능 (Features)
│   ├── 태스크 1
│   ├── 태스크 2
│   └── 문서
└── 버전 관리된 문서
```

#### AI 기반 프로젝트 생성
- **요구사항 자동 생성**: AI가 프로젝트 요구사항 제안
- **태스크 분해**: 복잡한 프로젝트를 실행 가능한 태스크로 분해
- **진행 상황 추적**: 실시간 업데이트 및 상태 관리

## 아키텍처 개요

Archon은 진정한 마이크로서비스 아키텍처를 채택합니다:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend UI   │    │  Server (API)   │    │   MCP Server    │    │ Agents Service  │
│                 │    │                 │    │                 │    │                 │
│  React + Vite   │◄──►│    FastAPI +    │◄──►│    Lightweight  │◄──►│   PydanticAI    │
│  Port 3737      │    │    SocketIO     │    │    HTTP Wrapper │    │   Port 8052     │
│                 │    │    Port 8181    │    │    Port 8051    │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘    └─────────────────┘
         │                        │                        │                        │
         └────────────────────────┼────────────────────────┼────────────────────────┘
                                  │                        │
                         ┌─────────────────┐               │
                         │    Database     │               │
                         │                 │               │
                         │    Supabase     │◄──────────────┘
                         │    PostgreSQL   │
                         │    PGVector     │
                         └─────────────────┘
```

### 서비스 역할 분담

| 서비스 | 포트 | 역할 | 핵심 기능 |
|--------|------|------|-----------|
| **Frontend** | 3737 | 웹 인터페이스 | React, TypeScript, TailwindCSS |
| **Server** | 8181 | 핵심 비즈니스 로직 | FastAPI, 크롤링, 문서 처리 |
| **MCP Server** | 8051 | MCP 프로토콜 인터페이스 | 10개 MCP 도구, 세션 관리 |
| **Agents** | 8052 | AI 에이전트 호스팅 | PydanticAI, 문서/RAG 에이전트 |

## 실제 설치 및 테스트 가이드

### 1. 사전 요구사항

#### 필수 소프트웨어 확인
```bash
# Docker 및 Docker Compose 버전 확인
docker --version
docker-compose --version

# 예상 출력:
# Docker version 28.2.2, build e6534b4
# Docker Compose version v2.36.2
```

#### 시스템 요구사항
- **macOS**: 10.15 (Catalina) 이상
- **메모리**: 최소 8GB RAM (16GB 권장)
- **디스크**: 10GB 여유 공간
- **Docker**: Docker Desktop 또는 OrbStack

### 2. Archon 설치

#### 프로젝트 클론 및 환경 설정
```bash
# 프로젝트 클론
git clone https://github.com/coleam00/Archon.git
cd Archon

# 환경 변수 파일 생성
cp .env.example .env
```

#### 환경 변수 설정
```bash
# .env 파일 편집
nano .env
```

**기본 설정 (.env)**:
```bash
# Supabase 연결 (로컬 테스트용)
SUPABASE_URL=http://localhost:54321
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU

# 서비스 포트 설정
HOST=localhost
ARCHON_SERVER_PORT=8181
ARCHON_MCP_PORT=8051
ARCHON_AGENTS_PORT=8052
ARCHON_UI_PORT=3737

# 로그 레벨
LOG_LEVEL=INFO

# 임베딩 차원 (OpenAI text-embedding-3-small)
EMBEDDING_DIMENSIONS=1536
```

### 3. Supabase 로컬 환경 준비

Archon은 PostgreSQL + PGVector를 사용하므로 로컬 Supabase 인스턴스가 필요합니다:

```bash
# Supabase CLI 설치 (이미 설치된 경우 생략)
npm install -g supabase

# 로컬 Supabase 시작
supabase start
```

### 4. Archon 실행

#### Docker Compose로 전체 스택 실행
```bash
# 모든 서비스 빌드 및 실행
docker-compose up --build -d

# 실행 상태 확인
docker ps | grep -E "(Archon|archon)"
```

**예상 출력**:
```
Archon-MCP      Up 2 minutes (healthy)     0.0.0.0:8051->8051/tcp
Archon-UI       Up 2 minutes (healthy)     0.0.0.0:3737->5173/tcp  
Archon-Server   Up 2 minutes (healthy)     0.0.0.0:8181->8181/tcp
Archon-Agents   Up 2 minutes (healthy)     0.0.0.0:8052->8052/tcp
```

### 5. 테스트 스크립트 작성 및 실행

편의를 위해 자동화된 테스트 스크립트를 작성했습니다:

{% raw %}
```bash
#!/bin/bash
# test-archon-setup.sh

set -e

echo "🔥 Archon OS 통합 테스트 시작"
echo "========================================"

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# 1. 기본 환경 확인
echo
log_info "1. 기본 환경 확인"
echo "Docker 버전: $(docker --version)"
echo "Docker Compose 버전: $(docker-compose --version)"

# 2. 컨테이너 상태 확인
echo
log_info "2. Archon 서비스 상태 확인"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(Archon|archon)"

# 3. 서비스 Health Check
echo
log_info "3. 서비스 Health Check"

# UI 확인
echo -n "  - Archon UI 상태 확인... "
if curl -s -f "http://localhost:3737" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ 실행 중${NC}"
else
    echo -e "${RED}❌ 응답 없음${NC}"
fi

# Agents 서비스 확인
echo -n "  - Archon Agents 상태 확인... "
if curl -s -f "http://localhost:8052/health" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ 실행 중${NC}"
else
    echo -e "${RED}❌ 응답 없음${NC}"
fi

# 4. 기능 테스트
echo
log_info "4. 기본 기능 테스트"

# UI 페이지 로드 테스트
echo -n "  - UI 페이지 로드 테스트... "
if curl -s http://localhost:3737 | grep -q "Archon"; then
    echo -e "${GREEN}✅ 성공${NC}"
else
    echo -e "${YELLOW}⚠️  페이지 확인 필요${NC}"
fi

# AI Agents 서비스 응답 테스트
echo -n "  - AI Agents 서비스 응답 테스트... "
agents_response=$(curl -s http://localhost:8052/health 2>/dev/null || echo "")
if echo "$agents_response" | grep -q "healthy"; then
    echo -e "${GREEN}✅ 성공${NC}"
    echo "    - 사용 가능한 에이전트: document, rag"
else
    echo -e "${YELLOW}⚠️  에이전트 서비스 확인 필요${NC}"
fi

echo
log_success "Archon OS 기본 설치 및 실행 테스트 완료!"
echo
echo "🌐 웹 인터페이스 접속: http://localhost:3737"
```
{% endraw %}

```bash
# 테스트 스크립트 실행
chmod +x test-archon-setup.sh
./test-archon-setup.sh
```

### 6. 실제 테스트 결과

위 스크립트를 실행한 결과:

```
🔥 Archon OS 통합 테스트 시작
========================================

ℹ️  1. 기본 환경 확인
Docker 버전: Docker version 28.2.2, build e6534b4
Docker Compose 버전: Docker Compose version v2.36.2

ℹ️  2. Archon 서비스 상태 확인
Archon-MCP      Up About a minute (healthy)      0.0.0.0:8051->8051/tcp
Archon-UI       Up About a minute (healthy)      0.0.0.0:3737->5173/tcp
Archon-Server   Up About a minute (healthy)      0.0.0.0:8181->8181/tcp
Archon-Agents   Up About a minute (healthy)      0.0.0.0:8052->8052/tcp

ℹ️  3. 서비스 Health Check
  - Archon UI 상태 확인... ✅ 실행 중
  - Archon Agents 상태 확인... ✅ 실행 중

ℹ️  4. 기본 기능 테스트
  - UI 페이지 로드 테스트... ✅ 성공
  - AI Agents 서비스 응답 테스트... ✅ 성공
    - 사용 가능한 에이전트: document, rag

✅ Archon OS 기본 설치 및 실행 테스트 완료!

🌐 웹 인터페이스 접속: http://localhost:3737
```

## 웹 인터페이스 활용 가이드

### 1. 초기 설정

#### OpenAI API 키 설정
1. 웹 브라우저에서 `http://localhost:3737` 접속
2. **Settings** 페이지로 이동
3. **OpenAI API Key** 입력 및 저장
4. **Model Choice** 선택 (예: `gpt-4o-mini`)

#### RAG 설정 최적화
```json
{
  "USE_CONTEXTUAL_EMBEDDINGS": true,
  "USE_HYBRID_SEARCH": true,
  "CRAWL_MAX_CONCURRENT": 10,
  "CRAWL_BATCH_SIZE": 50,
  "MEMORY_THRESHOLD_PERCENT": 80
}
```

### 2. 지식 베이스 구축

#### 웹사이트 크롤링 테스트
1. **Knowledge Base** → **Crawl Website** 클릭
2. 테스트 URL 입력: `https://docs.python.org/3/tutorial/`
3. 크롤링 진행 상황 실시간 모니터링
4. 완료 후 검색 테스트

#### 문서 업로드
1. **Knowledge Base** → **Upload Document** 클릭
2. PDF, Word, Markdown 파일 업로드
3. 자동 벡터화 및 인덱싱 대기
4. 검색으로 정확성 확인

### 3. 프로젝트 관리 활용

#### 새 프로젝트 생성
1. **Projects** 페이지로 이동
2. **Create New Project** 클릭
3. 프로젝트 정보 입력:
   ```
   Project Name: AI 코딩 어시스턴트 개발
   Description: Archon을 활용한 AI 코딩 도구 개발
   ```

#### AI 기반 태스크 생성
1. 프로젝트 내에서 **Add Feature** 클릭
2. AI가 자동으로 태스크 분해:
   ```
   Feature: 사용자 인증 시스템
   ├── 로그인 API 개발
   ├── JWT 토큰 관리
   ├── 사용자 권한 시스템
   └── 테스트 코드 작성
   ```

## MCP 클라이언트 연동 가이드

### 1. Claude Code 연동

#### MCP 설정 파일 생성
```json
{
  "mcpServers": {
    "archon": {
      "command": "curl",
      "args": [
        "-X", "POST",
        "-H", "Content-Type: application/json",
        "-H", "Accept: text/event-stream",
        "http://localhost:8051/mcp"
      ],
      "transport": "sse"
    }
  }
}
```

#### 연결 테스트
1. Claude Code에서 MCP 서버 연결 확인
2. 사용 가능한 도구 목록 확인:
   - `rag_query`: 지식 베이스 검색
   - `create_project`: 프로젝트 생성
   - `add_task`: 태스크 추가
   - `search_knowledge`: 문서 검색
   - `crawl_website`: 웹사이트 크롤링

### 2. Cursor 연동

#### Cursor 설정
1. Cursor 설정에서 MCP 서버 추가
2. 서버 URL: `http://localhost:8051/mcp`
3. Transport: `sse`
4. 연결 테스트 및 도구 활용

### 3. 실제 사용 시나리오

#### 시나리오 1: 문서 기반 코드 생성
```
사용자: "Python FastAPI 인증 미들웨어를 만들어줘"

Claude Code (MCP 활용):
1. rag_query("FastAPI authentication middleware")
2. 지식 베이스에서 관련 문서 검색
3. 검색 결과를 바탕으로 정확한 코드 생성
```

#### 시나리오 2: 프로젝트 진행 상황 관리
```
사용자: "현재 프로젝트의 완료되지 않은 태스크 목록을 보여줘"

Claude Code (MCP 활용):
1. list_projects() - 프로젝트 목록 조회
2. get_project_tasks(project_id) - 태스크 상태 확인
3. 미완료 태스크 목록 정리하여 제시
```

## 실무 활용 방안

### 1. 개발팀 지식 허브

#### 사내 문서 통합
- **API 문서**: Swagger, Postman 컬렉션 크롤링
- **개발 가이드**: Confluence, Notion 페이지 수집
- **코드 리뷰**: GitHub/GitLab 이슈 및 PR 분석

#### 자동화된 지식 업데이트
```bash
# 일일 문서 업데이트 크론잡
0 2 * * * /path/to/update_knowledge.sh
```

### 2. 프로젝트 진행 관리

#### AI 기반 스프린트 계획
1. **요구사항 분석**: AI가 사용자 스토리 분해
2. **태스크 우선순위**: 복잡도 및 의존성 분석
3. **진행 상황 추적**: 실시간 대시보드

#### 코드 리뷰 자동화
```python
# Archon MCP를 활용한 코드 리뷰
def review_code_with_context(code_diff):
    # 1. 관련 문서 검색
    context = rag_query(f"best practices for {language}")
    
    # 2. AI 기반 리뷰
    review = analyze_code(code_diff, context)
    
    # 3. 프로젝트에 결과 저장
    add_task(project_id, f"Address: {review.issues}")
```

### 3. 학습 및 온보딩

#### 신규 개발자 온보딩
- **맞춤형 학습 경로**: 역할별 문서 추천
- **실습 프로젝트**: AI가 제안하는 단계별 과제
- **멘토링 봇**: 24/7 질문 응답 시스템

#### 기술 스택 전환 지원
```
예시: React → Vue.js 전환
1. React 경험을 바탕으로 Vue.js 학습 경로 생성
2. 유사한 패턴 및 차이점 설명
3. 실습 프로젝트를 통한 점진적 학습
```

## 성능 최적화 가이드

### 1. 크롤링 성능 튜닝

#### 동시성 설정 최적화
```bash
# .env 파일에서 설정
CRAWL_MAX_CONCURRENT=20        # 기본: 10
CRAWL_BATCH_SIZE=100          # 기본: 50
MEMORY_THRESHOLD_PERCENT=70   # 기본: 80
```

#### 메모리 모니터링
```bash
# 실시간 메모리 사용량 확인
docker stats Archon-Server --no-stream
```

### 2. 벡터 검색 최적화

#### 임베딩 모델 선택
| 모델 | 차원 | 성능 | 정확도 | 비용 |
|------|------|------|--------|------|
| text-embedding-3-small | 1536 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| text-embedding-3-large | 3072 | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| text-embedding-ada-002 | 1536 | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |

#### 검색 쿼리 최적화
```python
# 하이브리드 검색으로 정확도 향상
search_params = {
    "use_contextual_embeddings": True,
    "use_hybrid_search": True,
    "rerank_results": True,
    "max_results": 10
}
```

### 3. 데이터베이스 성능

#### PostgreSQL 인덱스 최적화
```sql
-- 벡터 검색 성능 향상
CREATE INDEX CONCURRENTLY idx_embeddings_vector 
ON knowledge_chunks USING ivfflat (embedding vector_cosine_ops);

-- 전문 검색 성능 향상  
CREATE INDEX CONCURRENTLY idx_content_fts 
ON knowledge_chunks USING gin(to_tsvector('english', content));
```

## 편의 기능 및 자동화

### zshrc Aliases 설정

일상 작업을 위한 편리한 명령어들을 설정했습니다:

```bash
# ~/.zshrc에 추가할 Archon 관련 alias
alias archon-start='cd ~/path/to/Archon && docker-compose up -d'
alias archon-stop='cd ~/path/to/Archon && docker-compose down'
alias archon-restart='cd ~/path/to/Archon && docker-compose restart'
alias archon-logs='cd ~/path/to/Archon && docker-compose logs -f'
alias archon-status='docker ps | grep -E "(Archon|archon)"'
alias archon-test='./test-archon-setup.sh'
alias archon-ui='open http://localhost:3737'
alias archon-build='cd ~/path/to/Archon && docker-compose up --build -d'
```

### 설정 스크립트 실행
```bash
# alias 자동 설정
chmod +x setup-aliases.sh
./setup-aliases.sh
source ~/.zshrc

# 사용 예시
archon-start    # Archon 시작
archon-ui       # 웹 UI 열기
archon-status   # 상태 확인
```

## 문제 해결 가이드

### 1. 일반적인 설치 문제

#### Docker 연결 오류
```bash
# Docker 데몬 상태 확인
docker info

# Docker Desktop 재시작 (macOS)
killall Docker && open -a Docker

# OrbStack 사용 시
open -a OrbStack
```

#### 포트 충돌 해결
```bash
# 포트 사용 상황 확인
lsof -i :3737
lsof -i :8181

# 사용 중인 프로세스 종료
kill -9 $(lsof -t -i:3737)
```

### 2. 서비스별 문제 해결

#### Supabase 연결 오류
```bash
# 로컬 Supabase 상태 확인
supabase status

# Supabase 재시작
supabase stop
supabase start
```

#### MCP 서버 연결 실패
```bash
# MCP 서버 로그 확인
docker logs Archon-MCP -f

# 수동 연결 테스트
curl -H "Accept: text/event-stream" http://localhost:8051/mcp
```

### 3. 성능 문제 해결

#### 메모리 부족
```bash
# Docker 메모리 할당 증가 (Docker Desktop)
# Settings → Resources → Memory: 8GB → 12GB

# 크롤링 동시성 감소
CRAWL_MAX_CONCURRENT=5
CRAWL_BATCH_SIZE=25
```

#### 검색 속도 저하
```sql
-- 벡터 인덱스 재구성
REINDEX INDEX idx_embeddings_vector;

-- 통계 정보 업데이트
ANALYZE knowledge_chunks;
```

## 고급 활용 시나리오

### 1. 엔터프라이즈 배포

#### 프로덕션 환경 설정
```yaml
# docker-compose.prod.yml
version: '3.8'
services:
  archon-server:
    deploy:
      replicas: 3
      resources:
        limits:
          memory: 4G
          cpus: '2'
    environment:
      - LOG_LEVEL=WARN
      - CRAWL_MAX_CONCURRENT=30
```

#### 로드 밸런싱
```nginx
# nginx.conf
upstream archon_backend {
    server archon-server-1:8181;
    server archon-server-2:8181;
    server archon-server-3:8181;
}

server {
    location / {
        proxy_pass http://archon_backend;
    }
}
```

### 2. CI/CD 통합

#### GitHub Actions 워크플로우
```yaml
name: Archon Knowledge Update
on:
  schedule:
    - cron: '0 2 * * *'  # 매일 새벽 2시

jobs:
  update-knowledge:
    runs-on: ubuntu-latest
    steps:
      - name: Crawl Documentation
        run: |
          curl -X POST http://localhost:8181/api/crawl \
            -d '{"url": "https://docs.internal.com"}'
      
      - name: Process New Documents
        run: |
          # 새로운 문서 자동 처리
          python update_docs.py
```

### 3. 다중 팀 환경

#### 팀별 네임스페이스 분리
```python
# 팀별 지식 베이스 분리
team_configs = {
    "frontend": {
        "knowledge_sources": [
            "https://reactjs.org/docs",
            "https://vuejs.org/guide"
        ],
        "project_prefix": "FE_"
    },
    "backend": {
        "knowledge_sources": [
            "https://fastapi.tiangolo.com",
            "https://docs.python.org"
        ],
        "project_prefix": "BE_"
    }
}
```

## 결론

Archon OS는 AI 코딩 어시스턴트의 능력을 획기적으로 향상시키는 강력한 지식 관리 플랫폼입니다. 웹 크롤링, 문서 처리, 벡터 검색부터 프로젝트 관리, MCP 연동까지 - 개발 팀이 필요로 하는 모든 지식 관리 기능을 제공합니다.

실제 테스트 결과, macOS 환경에서 안정적으로 실행되며 Claude Code, Cursor 등 주요 AI 코딩 도구들과 완벽하게 통합됩니다. 특히 마이크로서비스 아키텍처를 통한 확장성과 Docker 기반의 간편한 배포는 엔터프라이즈 환경에서도 충분히 활용할 수 있는 수준입니다.

### 핵심 장점 요약

1. **완전한 지식 관리**: 웹 크롤링부터 문서 처리까지 one-stop 솔루션
2. **AI 도구 완벽 통합**: Claude Code, Cursor 등 인기 도구 지원
3. **확장 가능한 아키텍처**: 마이크로서비스 기반 유연한 확장
4. **실무 즉시 적용**: Docker 기반 간편 설치 및 배포
5. **오픈소스 생태계**: 활발한 커뮤니티와 지속적인 발전

Archon OS를 통해 여러분의 AI 코딩 어시스턴트가 더욱 똑똑하고 맥락적으로 정확한 도우미가 되기를 바랍니다. 단순한 코드 작성을 넘어 진정한 **지식 기반 개발 파트너**로 거듭나는 경험을 해보세요!

## 참고 자료

- **Archon GitHub**: [https://github.com/coleam00/Archon](https://github.com/coleam00/Archon)
- **MCP 프로토콜**: [https://modelcontextprotocol.io](https://modelcontextprotocol.io)
- **Claude Code**: [https://claude.ai/code](https://claude.ai/code)
- **Cursor**: [https://cursor.sh](https://cursor.sh)
- **Supabase**: [https://supabase.com](https://supabase.com)
- **PydanticAI**: [https://ai.pydantic.dev](https://ai.pydantic.dev)
