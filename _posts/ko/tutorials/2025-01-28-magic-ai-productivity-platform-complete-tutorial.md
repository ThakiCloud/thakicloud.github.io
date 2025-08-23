---
title: "Magic AI 생산성 플랫폼 완전 가이드: 오픈소스 올인원 AI 솔루션 구축하기"
excerpt: "Magic은 첫 번째 오픈소스 올인원 AI 생산성 플랫폼입니다. 범용 AI Agent, 워크플로우 엔진, 엔터프라이즈 메신저, 협업 시스템을 포함한 완전한 제품군을 Docker로 설치하고 활용하는 방법을 단계별로 알아봅니다."
seo_title: "Magic AI 생산성 플랫폼 완전 설치 가이드 - Docker 기반 오픈소스 AI 솔루션 - Thaki Cloud"
seo_description: "Magic AI 플랫폼 설치부터 활용까지 완전 가이드. Super Magic AI Agent, Magic Flow 워크플로우, Magic IM 메신저 시스템을 Docker로 구축하고 엔터프라이즈 AI 생산성을 100배 향상시키는 방법을 알아보세요."
date: 2025-01-28
last_modified_at: 2025-01-28
categories:
  - tutorials
  - llmops
tags:
  - magic
  - ai-productivity
  - docker
  - ai-agent
  - workflow-engine
  - enterprise-ai
  - open-source
  - super-magic
  - magic-flow
  - magic-im
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/magic-ai-productivity-platform-complete-tutorial/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 15분

## 서론

Magic은 기업의 AI 생산성을 100배 향상시키기 위한 첫 번째 **오픈소스 올인원 AI 생산성 플랫폼**입니다. 단순한 AI 도구가 아닌, 범용 AI Agent, 시각적 워크플로우 엔진, 엔터프라이즈 메신저, 협업 시스템을 포함한 완전한 제품군을 제공합니다.

Magic은 다음과 같은 핵심 구성요소로 이루어져 있습니다:

- **Super Magic**: 복잡한 작업 시나리오를 위한 범용 AI Agent
- **Magic IM**: AI Agent와 통합된 엔터프라이즈급 메신저 시스템
- **Magic Flow**: 강력한 시각적 AI 워크플로우 오케스트레이션 시스템
- **Teamshare OS**: 엔터프라이즈급 온라인 협업 오피스 시스템 (출시 예정)

본 튜토리얼에서는 Docker를 사용하여 Magic 플랫폼을 설치하고, 각 구성요소의 특징과 활용 방법을 단계별로 살펴보겠습니다.

## Magic 플랫폼 개요

### 🎯 Magic이 해결하는 문제

현대 기업들은 다음과 같은 AI 생산성 관련 문제에 직면해 있습니다:

1. **분산된 AI 도구들**: 각각의 AI 서비스가 독립적으로 운영되어 통합이 어려움
2. **복잡한 워크플로우**: 여러 AI 모델과 서비스를 연결하는 복잡한 과정
3. **지식 관리 부족**: 기업 내 지식이 체계적으로 관리되지 않아 AI가 활용하기 어려움
4. **커뮤니케이션 단절**: AI와 인간의 협업이 자연스럽지 않음

Magic은 이러한 문제들을 **올인원 플랫폼**으로 해결합니다.

### 🔧 Magic 제품 매트릭스

#### 1. Super Magic - 범용 AI Agent

Super Magic은 복잡한 작업 시나리오를 위해 특별히 설계된 강력한 범용 AI Agent입니다.

**핵심 기능:**
- **자율 작업 이해**: 자연어 지시사항을 이해하고 작업 목표를 파악
- **자율 작업 계획**: 복잡한 작업을 단계별로 분해하고 실행 계획 수립
- **자율 실행**: 계획된 작업을 실제로 수행
- **자율 오류 수정**: 문제 발생 시 스스로 진단하고 해결 방법 탐색

**실제 사례:**
- 버핏의 2025년 주주총회 투자 인사이트 분석
- 베이징 휴머노이드 로봇 하프마라톤 관련 주식 분석
- '생각에 관한 생각' 핵심 포인트 요약
- SKU 판매 예측 요구사항 분석

#### 2. Magic Flow - 시각적 워크플로우 엔진

Magic Flow는 사용자가 자유로운 캔버스에서 복잡한 AI Agent 워크플로우를 구축할 수 있는 시각적 오케스트레이션 시스템입니다.

**핵심 특징:**
- **비주얼 오케스트레이션**: 드래그 앤 드롭으로 복잡한 AI 워크플로우 설계
- **풍부한 컴포넌트 라이브러리**: 텍스트 처리, 이미지 생성, 코드 실행 모듈 내장
- **포괄적인 모델 지원**: OpenAI API 프로토콜을 따르는 모든 대형 모델과 호환
- **시스템 통합 기능**: Magic IM 및 타사 메신저 시스템과 완벽 통합
- **커스텀 확장**: 특정 비즈니스 시나리오에 맞는 도구 노드 개발 지원
- **실시간 디버깅**: 포괄적인 디버깅 및 모니터링 기능으로 문제 신속 해결

#### 3. Magic IM - 엔터프라이즈 메신저

Magic IM은 내부 지식 관리와 지능형 고객 서비스 시나리오를 위해 특별히 설계된 엔터프라이즈급 AI Agent 대화 시스템입니다.

**핵심 기능:**
- **지식베이스 관리**: 다양한 문서 형식 가져오기, 자동 인덱싱, 의미론적 검색
- **대화 관리**: 포괄적인 대화 관리, 다양한 대화 내용에 대한 주제 구분
- **그룹 채팅**: 다중 사용자 실시간 협업 토론, AI가 지능적으로 그룹 채팅에 참여
- **멀티 조직 아키텍처**: 멀티 조직 배포 및 엄격한 조직 데이터 격리 지원
- **데이터 보안**: 엄격한 데이터 격리 및 접근 제어 메커니즘

#### 4. Teamshare OS - 협업 오피스 시스템 (출시 예정)

Teamshare OS는 팀 협업 효율성과 지식 관리를 향상시키기 위한 현대적인 엔터프라이즈급 협업 오피스 플랫폼입니다.

**예정 기능:**
- **지능형 문서 관리**: AI 보조 콘텐츠 생성 및 최적화
- **Magic Table**: 다차원 데이터 관리 도구
- **프로젝트 협업 관리**: 직관적인 프로젝트 보드 및 작업 관리
- **지식베이스**: 강력한 지식 통합 및 검색 시스템

## 시스템 요구사항

### 필수 요구사항

- **Docker 24.0+**: 컨테이너 오케스트레이션을 위한 핵심 플랫폼
- **Docker Compose 2.0+**: 멀티 컨테이너 관리 도구
- **최소 메모리**: 8GB RAM (권장: 16GB)
- **디스크 공간**: 최소 20GB 여유 공간
- **운영체제**: Linux, macOS, Windows (Docker가 지원하는 모든 플랫폼)

### 권장 사양

- **메모리**: 32GB RAM 이상
- **프로세서**: 멀티코어 CPU (8코어 이상 권장)
- **스토리지**: SSD 스토리지
- **네트워크**: 안정적인 인터넷 연결 (Docker 이미지 다운로드용)

### 사전 준비사항

#### macOS 환경

```bash
# Docker Desktop 설치 확인
docker --version
docker compose version

# Docker Desktop이 설치되지 않은 경우
brew install --cask docker

# 또는 Colima 사용 (경량화 옵션)
brew install colima docker docker-compose
colima start
```

#### Linux 환경

```bash
# Ubuntu/Debian 계열
sudo apt update
sudo apt install docker.io docker-compose-plugin

# Docker 서비스 시작
sudo systemctl start docker
sudo systemctl enable docker

# 사용자를 docker 그룹에 추가
sudo usermod -aG docker $USER
```

## Magic 플랫폼 설치 가이드

### 1단계: 저장소 클론 및 초기 설정

```bash
# Magic 저장소 클론
git clone https://github.com/dtyq/magic.git
cd magic

# 환경 변수 파일 복사
cp .env.example .env

# 권한 설정 (Linux/macOS)
chmod +x bin/magic.sh
```

### 2단계: 환경 변수 설정

Magic 플랫폼은 다양한 서비스가 통합되어 있어 환경 변수 설정이 중요합니다.

#### 기본 환경 변수 (.env)

```bash
# .env 파일 주요 설정 예시

# 플랫폼 설정
PLATFORM=linux/amd64  # 또는 linux/arm64 (시스템에 따라)

# MySQL 설정
MYSQL_USER=magic
MYSQL_PASSWORD=magic123456
MYSQL_DATABASE=magic

# Redis 설정
REDIS_HOST=redis
REDIS_AUTH=magic123456
REDIS_PORT=6379

# RabbitMQ 설정
AMQP_USER=admin
AMQP_PASSWORD=magic123456
AMQP_VHOST=/

# 웹 서비스 설정
MAGIC_SOCKET_BASE_URL=ws://localhost:9502
MAGIC_SERVICE_BASE_URL=http://localhost
```

#### Super Magic 설정 (선택사항)

Super Magic을 사용하려면 추가 설정이 필요합니다:

```bash
# Super Magic 환경 변수 설정
cp config/.env_super_magic.example config/.env_super_magic
cp config/config.yaml.example config/config.yaml

# Magic Gateway 설정
cp config/.env_magic_gateway.example config/.env_magic_gateway

# Sandbox Gateway 설정  
cp config/.env_sandbox_gateway.example config/.env_sandbox_gateway
```

### 3단계: 자동 설치 스크립트 실행

Magic은 설치 과정을 단순화하는 지능형 설치 스크립트를 제공합니다:

```bash
# 설치 스크립트 실행
./bin/magic.sh start
```

**설치 과정에서 다음과 같은 선택사항들이 제공됩니다:**

1. **언어 선택**: 한국어 또는 영어
2. **배포 방식**: 로컬 또는 원격 서버 배포
3. **Super Magic 설치**: Super Magic 서비스 포함 여부
4. **네트워크 설정**: 공개 IP 또는 도메인 사용 여부

### 4단계: 서비스 상태 확인

```bash
# 서비스 상태 확인
./bin/magic.sh status

# 서비스 로그 확인
./bin/magic.sh logs

# 특정 컨테이너 상태 확인
docker ps | grep magic
```

## Magic 서비스 구성요소

설치가 완료되면 다음 서비스들에 접근할 수 있습니다:

| 서비스 | URL/포트 | 설명 |
|--------|----------|------|
| **Magic Web UI** | `http://localhost:8080` | 메인 웹 인터페이스 |
| **Magic API** | `http://localhost:9501` | REST API 서비스 |
| **Super Magic** | `http://localhost:8002` | AI Agent 서비스 (선택사항) |
| **Magic Gateway** | `http://localhost:8001` | 게이트웨이 서비스 (선택사항) |
| **MySQL 데이터베이스** | `localhost:3306` | 메인 데이터베이스 |
| **Redis 캐시** | `localhost:6379` | 캐시 및 세션 스토리지 |
| **RabbitMQ 관리** | `http://localhost:15672` | 메시지 큐 관리 인터페이스 |
| **Qdrant 벡터DB** | `localhost:6333` | 벡터 데이터베이스 |
| **Caddy 파일서버** | `http://localhost:80` | 정적 파일 서비스 |

### 기본 접속 정보

**Magic Web Application:**
- URL: `http://localhost:8080`
- 계정 1: `13812345678` / 비밀번호: `letsmagic.ai`
- 계정 2: `13912345678` / 비밀번호: `letsmagic.ai`

**RabbitMQ Management:**
- URL: `http://localhost:15672`
- 사용자명: `admin`
- 비밀번호: `magic123456`

## 핵심 기능 활용 가이드

### Magic IM 사용하기

#### 1. 지식베이스 구축

```bash
# 지식베이스 관리 인터페이스 접속
# Magic Web UI > Knowledge Base 섹션

# 지원하는 파일 형식:
# - PDF 문서
# - Word 문서 (.docx)
# - 텍스트 파일 (.txt, .md)
# - Excel 스프레드시트
# - PowerPoint 프레젠테이션
```

#### 2. AI Agent와 대화

Magic IM의 AI Agent는 다음과 같은 고급 기능을 제공합니다:

- **컨텍스트 유지**: 긴 대화에서도 맥락을 기억
- **지식베이스 검색**: 업로드된 문서에서 관련 정보 자동 검색
- **멀티턴 대화**: 복잡한 질문에 대한 단계별 답변
- **그룹 채팅 참여**: 팀 토론에 지능적으로 참여

#### 3. 조직 관리

```bash
# 멀티 조직 설정
# 1. 관리자 계정으로 로그인
# 2. Organization Settings 접속
# 3. 새 조직 생성 또는 기존 조직 관리
# 4. 사용자 권한 및 역할 설정
```

### Magic Flow 워크플로우 구축

#### 1. 기본 워크플로우 생성

Magic Flow의 비주얼 에디터를 사용하여 AI 워크플로우를 구축합니다:

```javascript
// Magic Flow 워크플로우 예시: 문서 요약 파이프라인

// 1. 입력 노드: 문서 업로드
{
  "type": "input",
  "name": "document_input",
  "accept": ["pdf", "docx", "txt"]
}

// 2. 텍스트 추출 노드
{
  "type": "text_extractor",
  "name": "extract_text",
  "input": "document_input"
}

// 3. AI 요약 노드
{
  "type": "llm_summarize",
  "name": "summarize",
  "model": "gpt-4",
  "input": "extract_text",
  "prompt": "다음 문서를 3단락으로 요약해주세요:"
}

// 4. 출력 노드
{
  "type": "output",
  "name": "summary_output",
  "input": "summarize"
}
```

#### 2. 고급 워크플로우 패턴

**멀티 에이전트 협업:**

```yaml
{% raw %}
workflow:
  name: "Multi-Agent Document Analysis"
  agents:
    - name: "researcher"
      role: "정보 수집 및 사실 확인"
      tools: ["web_search", "knowledge_base"]
    
    - name: "analyst"
      role: "데이터 분석 및 인사이트 도출"
      tools: ["data_analysis", "chart_generation"]
    
    - name: "writer"
      role: "최종 보고서 작성"
      tools: ["text_generation", "formatting"]
  
  flow:
    1. researcher -> 정보 수집
    2. analyst -> 데이터 분석 
    3. writer -> 보고서 작성
    4. review -> 품질 검토
{% endraw %}
```

### Super Magic Agent 활용

#### 1. 복잡한 비즈니스 작업 자동화

Super Magic은 다음과 같은 복잡한 작업을 자율적으로 수행할 수 있습니다:

**투자 분석 예시:**

```bash
# Super Magic에게 투자 분석 요청
"버핏의 최근 주주총회 내용을 분석하고, 
언급된 투자 전략을 바탕으로 
현재 시장 상황에서 추천할 만한 
투자 포트폴리오를 제안해주세요."
```

Super Magic의 자율 실행 과정:
1. **작업 이해**: 버핏 주주총회 분석 + 투자 전략 도출 + 포트폴리오 제안
2. **정보 수집**: 웹 검색으로 최신 주주총회 내용 수집
3. **분석 실행**: AI 모델을 사용하여 핵심 투자 전략 추출
4. **시장 조사**: 현재 시장 데이터 및 동향 분석
5. **포트폴리오 구성**: 분석 결과를 바탕으로 구체적인 투자 제안
6. **결과 검증**: 제안 내용의 논리적 일관성 검토

#### 2. 에러 복구 및 자율 수정

Super Magic은 작업 실행 중 문제가 발생하면 스스로 진단하고 해결책을 찾습니다:

```python
# Super Magic의 자율 에러 처리 예시

class SuperMagicErrorRecovery:
    def handle_error(self, error_context):
        # 1. 에러 유형 분석
        error_type = self.analyze_error(error_context)
        
        # 2. 대안 전략 생성
        alternatives = self.generate_alternatives(error_type)
        
        # 3. 최적 해결책 선택
        best_solution = self.select_best_solution(alternatives)
        
        # 4. 수정된 접근법으로 재실행
        return self.retry_with_solution(best_solution)
```

## 고급 설정 및 커스터마이징

### 1. 사용자 정의 AI 모델 통합

Magic은 OpenAI API 호환 모델을 모두 지원합니다:

```bash
# config/.env_super_magic 설정 예시

# OpenAI
OPENAI_API_KEY=your_openai_key
OPENAI_MODEL=gpt-4

# Claude (Anthropic)
ANTHROPIC_API_KEY=your_claude_key
ANTHROPIC_MODEL=claude-3-sonnet

# 로컬 모델 (Ollama)
OLLAMA_BASE_URL=http://localhost:11434
OLLAMA_MODEL=llama2

# Azure OpenAI
AZURE_OPENAI_ENDPOINT=your_azure_endpoint
AZURE_OPENAI_API_KEY=your_azure_key
```

### 2. 커스텀 도구 개발

Magic Flow에서 사용할 커스텀 도구를 개발할 수 있습니다:

```python
# 커스텀 도구 예시: 한국 주식 정보 조회

class KoreanStockTool:
    def __init__(self):
        self.name = "korean_stock_info"
        self.description = "한국 주식 정보를 조회합니다"
    
    def execute(self, stock_code: str) -> dict:
        """
        한국 주식 정보 조회
        
        Args:
            stock_code: 주식 코드 (예: '005930' for 삼성전자)
        
        Returns:
            주식 정보 딕셔너리
        """
        # KRX API 또는 다른 데이터 소스 연동
        stock_info = self.fetch_stock_data(stock_code)
        
        return {
            "code": stock_code,
            "name": stock_info["name"],
            "price": stock_info["current_price"],
            "change": stock_info["price_change"],
            "volume": stock_info["volume"]
        }
```

### 3. 스케일링 및 로드 밸런싱

엔터프라이즈 환경에서의 스케일링 설정:

```yaml
# docker-compose.scale.yml
version: '3.8'

services:
  magic-service:
    deploy:
      replicas: 3
      resources:
        limits:
          memory: 8G
          cpus: '4'
    
  magic-web:
    deploy:
      replicas: 2
      resources:
        limits:
          memory: 2G
          cpus: '2'

  # 로드 밸런서 설정
  nginx-lb:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - magic-web
```

## 실제 사용 사례

### 사례 1: 기업 지식 관리 시스템

**상황**: 중간 규모 IT 기업의 기술 문서 관리 및 질의응답 시스템 구축

**구현**:
1. **Magic IM 지식베이스**: 모든 기술 문서, API 문서, 개발 가이드 업로드
2. **Magic Flow 워크플로우**: 문서 자동 분류 및 인덱싱 파이프라인 구축
3. **Super Magic**: 복잡한 기술 질문에 대한 자동 답변 시스템

**결과**:
- 개발자 질문 응답 시간 80% 단축
- 지식 검색 정확도 95% 달성
- 신입 개발자 온보딩 시간 50% 감소

### 사례 2: 마케팅 콘텐츠 생성 자동화

**상황**: 마케팅 팀의 콘텐츠 생성 업무 자동화

**구현**:
1. **Magic Flow**: 키워드 → 콘텐츠 기획 → 초안 작성 → 이미지 생성 워크플로우
2. **Super Magic**: 브랜드 가이드라인을 학습하여 일관된 톤앤매너 유지
3. **Magic IM**: 팀원 간 실시간 피드백 및 승인 프로세스

**결과**:
- 콘텐츠 생성 시간 70% 단축
- 브랜드 일관성 향상
- 창의적 업무에 더 많은 시간 투자 가능

### 사례 3: 고객 서비스 자동화

**상황**: 이커머스 기업의 24/7 고객 지원 시스템

**구현**:
1. **Magic IM**: 고객 문의 자동 분류 및 1차 응답
2. **Super Magic**: 복잡한 주문/배송/반품 문의 처리
3. **Magic Flow**: 에스컬레이션 규칙 및 워크플로우 자동화

**결과**:
- 고객 만족도 25% 증가
- 응답 시간 90% 단축
- 고객 서비스 운영비용 60% 절감

## 트러블슈팅

### 자주 발생하는 문제들

#### 1. Docker 관련 문제

**문제**: "Docker is not running" 에러
```bash
# 해결방법
# macOS
open -a Docker

# Linux
sudo systemctl start docker
sudo systemctl enable docker
```

**문제**: 메모리 부족으로 인한 컨테이너 재시작
```bash
# Docker 메모리 할당량 확인 및 증가
docker stats

# Docker Desktop에서 Resources > Memory 설정 증가 (최소 8GB)
```

#### 2. 네트워크 연결 문제

**문제**: 서비스 간 통신 실패
```bash
# 네트워크 상태 확인
docker network ls
docker network inspect magic-sandbox-network

# 네트워크 재생성
docker network rm magic-sandbox-network
docker network create magic-sandbox-network
```

#### 3. 환경 변수 설정 문제

**문제**: AI 모델 API 키 설정 오류
```bash
# 환경 변수 파일 검증
grep -v '^#' .env | grep -v '^$'

# API 키 테스트
curl -H "Authorization: Bearer $OPENAI_API_KEY" \
  https://api.openai.com/v1/models
```

### 로그 분석 및 디버깅

```bash
# 전체 서비스 로그 확인
./bin/magic.sh logs

# 특정 서비스 로그 확인
docker logs magic-service
docker logs magic-web
docker logs super-magic

# 실시간 로그 모니터링
docker logs -f magic-service

# 에러 로그만 필터링
docker logs magic-service 2>&1 | grep -i error
```

## 성능 최적화

### 1. 데이터베이스 최적화

```sql
-- MySQL 성능 튜닝
-- my.cnf 설정 권장값

[mysqld]
innodb_buffer_pool_size = 4G
innodb_log_file_size = 1G
max_connections = 1000
query_cache_size = 256M
tmp_table_size = 256M
max_heap_table_size = 256M
```

### 2. Redis 캐시 최적화

```bash
# Redis 설정 최적화
# redis.conf

maxmemory 2gb
maxmemory-policy allkeys-lru
save 900 1
save 300 10
save 60 10000
```

### 3. 벡터 데이터베이스 최적화

```yaml
# Qdrant 설정 최적화
storage:
  # 인덱스 성능 향상
  hnsw_config:
    m: 16
    ef_construct: 100
    
  # 메모리 사용량 최적화
  optimizers_config:
    memmap_threshold: 10000
```

## 보안 고려사항

### 1. 네트워크 보안

```yaml
# 프로덕션 환경 네트워크 격리
networks:
  magic-internal:
    driver: bridge
    internal: true
  
  magic-external:
    driver: bridge

services:
  magic-web:
    networks:
      - magic-external
      - magic-internal
  
  db:
    networks:
      - magic-internal  # 외부 접근 차단
```

### 2. 데이터 암호화

```bash
# 환경 변수 암호화
# .env 파일에 민감한 정보는 암호화하여 저장

# 예시: SOPS를 사용한 시크릿 관리
sops -e .env > .env.encrypted
```

### 3. 접근 제어

```nginx
# nginx.conf에서 IP 기반 접근 제어
location /admin {
    allow 192.168.1.0/24;
    allow 10.0.0.0/8;
    deny all;
    
    proxy_pass http://magic-web:8080;
}
```

## 결론

Magic AI 생산성 플랫폼은 기업의 AI 혁신을 위한 완전한 솔루션을 제공합니다. 범용 AI Agent인 Super Magic, 시각적 워크플로우 엔진인 Magic Flow, 엔터프라이즈 메신저인 Magic IM이 통합된 올인원 플랫폼으로서, 복잡한 비즈니스 프로세스를 지능적으로 자동화하고 팀 협업을 혁신적으로 개선할 수 있습니다.

### 핵심 장점 요약

1. **통합된 플랫폼**: 여러 AI 도구를 하나의 플랫폼에서 관리
2. **자율적 AI Agent**: 복잡한 작업을 스스로 계획하고 실행
3. **시각적 워크플로우**: 코딩 없이 복잡한 AI 파이프라인 구축
4. **엔터프라이즈급 보안**: 멀티 조직 지원 및 데이터 격리
5. **확장 가능성**: 커스텀 도구 및 모델 통합 지원

### 다음 단계

Magic 플랫폼을 성공적으로 설치했다면, 다음과 같은 단계로 활용도를 높여보세요:

1. **팀 교육**: 각 구성요소의 기능과 활용법 교육
2. **파일럿 프로젝트**: 작은 규모의 업무 자동화부터 시작
3. **점진적 확장**: 성공 사례를 바탕으로 적용 범위 확대
4. **커스터마이징**: 기업 특수 요구사항에 맞는 커스텀 개발
5. **성과 측정**: ROI 및 생산성 향상 지표 모니터링

Magic은 오픈소스로 제공되어 기업이 자유롭게 수정하고 확장할 수 있으며, 상용 서비스도 제공하여 더 강력한 관리 기능과 지원을 받을 수 있습니다. AI 시대의 생산성 혁명에 Magic과 함께 동참하시기 바랍니다.

---

**참고 링크:**
- [Magic 공식 웹사이트](https://www.letsmagic.ai)
- [Magic GitHub 저장소](https://github.com/dtyq/magic)
- [Magic 공식 문서](https://docs.letsmagic.cn/en)
- [Super Magic 데모](https://www.letsmagic.cn/share/777665156986277889)
