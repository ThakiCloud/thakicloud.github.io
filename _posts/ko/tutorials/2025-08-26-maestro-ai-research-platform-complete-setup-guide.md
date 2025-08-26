---
title: "MAESTRO: AI 기반 연구 플랫폼 완전 설치 및 활용 가이드"
excerpt: "AI 에이전트 기반 연구 자동화 플랫폼 MAESTRO의 설치부터 고급 활용까지 단계별 완전 가이드"
seo_title: "MAESTRO AI 연구 플랫폼 설치 가이드 - Docker, GPU 설정, 로컬 LLM 연동 - Thaki Cloud"
seo_description: "오픈소스 AI 연구 플랫폼 MAESTRO 설치 방법부터 GPU 최적화, SearXNG 검색 엔진 연동, 로컬 LLM 설정까지 실무 중심 튜토리얼"
date: 2025-08-26
categories:
  - tutorials
tags:
  - maestro
  - ai-research
  - docker
  - fastapi
  - react
  - postgresql
  - pgvector
  - searxng
  - local-llm
  - gpu
author_profile: true
toc: true
toc_label: "목차"
canonical_url: "https://thakicloud.github.io/ko/tutorials/maestro-ai-research-platform-complete-setup-guide/"
lang: ko
permalink: /ko/tutorials/maestro-ai-research-platform-complete-setup-guide/
---

⏱️ **예상 읽기 시간**: 25분

## 1. MAESTRO 소개

### MAESTRO란?

MAESTRO는 AI 기반의 연구 자동화 플랫폼으로, 복잡한 연구 작업을 효율적으로 처리할 수 있도록 설계된 오픈소스 애플리케이션입니다. AI 에이전트를 활용하여 문서 수집, 분석, 보고서 생성까지 전체 연구 워크플로우를 자동화할 수 있습니다.

### 주요 특징

- **AI 에이전트 기반 연구**: LLM을 활용한 자동화된 연구 파이프라인
- **RAG (Retrieval-Augmented Generation)**: 벡터 검색 기반 문서 처리
- **실시간 웹소켓 통신**: 작업 진행 상황 실시간 모니터링
- **완전 셀프 호스팅**: 로컬 환경에서 완전한 독립 운영 가능
- **다양한 LLM 지원**: OpenAI, 로컬 LLM, API 호환 모델
- **SearXNG 통합**: 프라이빗 메타 검색 엔진 연동

### 기술 스택

- **백엔드**: FastAPI, SQLAlchemy, PostgreSQL, pgvector
- **프론트엔드**: React, TypeScript, Vite, Tailwind CSS
- **인프라**: Docker Compose, WebSocket
- **AI/ML**: 벡터 임베딩, LLM API 통합

## 2. 시스템 요구사항

### 최소 하드웨어 사양

```bash
# CPU 모드 (최소)
- CPU: 4코어 이상
- RAM: 8GB 이상
- 저장공간: 10GB 이상
- OS: Linux, macOS, Windows (WSL2)

# GPU 모드 (권장)
- GPU: NVIDIA GPU (CUDA 11.0 이상)
- VRAM: 8GB 이상
- RAM: 16GB 이상
- 저장공간: 20GB 이상
```

### 필수 소프트웨어

```bash
# 공통 요구사항
- Docker Desktop (최신 버전)
- Docker Compose v2
- Git

# GPU 사용 시 추가 요구사항 (Linux)
- nvidia-container-toolkit
- NVIDIA 드라이버 (최신 버전)

# Windows 사용자
- WSL2 (Ubuntu 20.04 이상)
- Windows Terminal (권장)
```

## 3. 설치 및 초기 설정

### 3.1 저장소 클론 및 기본 설정

```bash
# 1. MAESTRO 저장소 클론
git clone https://github.com/murtaza-nasir/maestro.git
cd maestro

# 2. 실행 권한 부여 (Linux/macOS)
chmod +x start.sh stop.sh detect_gpu.sh maestro-cli.sh

# 3. 환경 설정 파일 생성
cp .env.example .env
```

### 3.2 환경변수 설정

`.env` 파일을 편집하여 기본 설정을 구성합니다:

```bash
# .env 파일 주요 설정
# ===================

# 데이터베이스 설정
POSTGRES_DB=maestro_db
POSTGRES_USER=maestro_user
POSTGRES_PASSWORD=your_secure_password_here

# JWT 보안 설정
JWT_SECRET_KEY=your_jwt_secret_key_here
JWT_ALGORITHM=HS256
JWT_ACCESS_TOKEN_EXPIRE_MINUTES=30

# LLM API 설정 (OpenAI 사용 시)
OPENAI_API_KEY=your_openai_api_key_here
LLM_MODEL=gpt-4

# 로컬 LLM 설정 (Ollama 사용 시)
LOCAL_LLM_BASE_URL=http://localhost:11434/v1
LOCAL_LLM_MODEL=llama3.1:8b
USE_LOCAL_LLM=true

# 검색 엔진 설정
SEARCH_ENGINE=searxng
SEARXNG_BASE_URL=http://searxng:8080

# GPU 설정
GPU_AVAILABLE=true
BACKEND_GPU_DEVICE=0
DOC_PROCESSOR_GPU_DEVICE=0

# CPU 전용 모드 (GPU 없는 환경)
FORCE_CPU_MODE=false
```

### 3.3 GPU 지원 확인

GPU 지원 여부를 확인하고 최적 설정을 적용합니다:

```bash
# GPU 감지 스크립트 실행
./detect_gpu.sh

# 출력 예시:
# =========== GPU Detection Results ===========
# Platform: Linux
# GPU Support: Available
# NVIDIA Driver: 525.147.05
# CUDA Version: 12.0
# Recommended Configuration: GPU-enabled
# ===========================================
```

## 4. 플랫폼별 설치 가이드

### 4.1 Linux (Ubuntu/Debian) - GPU 지원

```bash
# 1. NVIDIA 컨테이너 툴킷 설치
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

# 2. Docker 재시작
sudo systemctl restart docker

# 3. GPU 테스트
docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi

# 4. MAESTRO 시작
./start.sh
```

### 4.2 macOS (Apple Silicon/Intel)

```bash
# 1. Docker Desktop 설치 확인
docker --version
docker-compose --version

# 2. CPU 최적화 모드로 시작
docker-compose -f docker-compose.cpu.yml up -d

# 또는 환경변수 설정 후 일반 시작
echo "FORCE_CPU_MODE=true" >> .env
./start.sh
```

### 4.3 Windows (WSL2)

PowerShell을 관리자 권한으로 실행:

```powershell
# 1. WSL2 및 Ubuntu 설치 확인
wsl --list --verbose

# 2. Docker Desktop Windows 실행 확인
docker --version

# 3. 저장소 클론 (WSL2 내부)
wsl
cd /mnt/c/
git clone https://github.com/murtaza-nasir/maestro.git
cd maestro

# 4. 권한 설정 및 시작
chmod +x *.sh
./start.sh

# 또는 PowerShell 스크립트 사용
# .\start.ps1
```

## 5. 서비스 구성 및 시작

### 5.1 기본 서비스 시작

```bash
# 자동 플랫폼 감지로 시작
./start.sh

# 또는 수동으로 Docker Compose 실행
docker-compose up -d

# CPU 전용 모드
docker-compose -f docker-compose.cpu.yml up -d
```

### 5.2 서비스 상태 확인

```bash
# 컨테이너 상태 확인
docker-compose ps

# 로그 확인
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f postgres
docker-compose logs -f searxng

# 전체 로그 확인
docker-compose logs -f
```

### 5.3 데이터베이스 초기화

```bash
# 데이터베이스 상태 확인
./maestro-cli.sh reset-db --check

# 데이터베이스 통계 조회
./maestro-cli.sh reset-db --stats

# 백업과 함께 데이터베이스 리셋 (필요시)
./maestro-cli.sh reset-db --backup
```

## 6. 웹 인터페이스 접속 및 초기 설정

### 6.1 첫 접속 및 계정 생성

```bash
# 브라우저에서 접속
http://localhost:3000

# 또는 CLI로 관리자 계정 생성
./maestro-cli.sh create-user admin securepassword123 --admin
```

### 6.2 기본 설정 구성

웹 인터페이스에서 `Settings` 메뉴로 이동하여 다음을 설정합니다:

```yaml
# LLM 설정
Model Provider: OpenAI / Local LLM
API Key: [YOUR_API_KEY]
Model Name: gpt-4 / llama3.1:8b
Temperature: 0.7
Max Tokens: 4000

# 검색 설정
Search Engine: SearXNG
Categories: 
  - General
  - Science
  - IT
  - News
Results per Query: 10

# 연구 매개변수
Planning Context: 200000
Max Documents: 50
Chunk Size: 1000
Overlap: 200
```

## 7. 로컬 LLM 연동 (Ollama)

### 7.1 Ollama 설치 및 설정

```bash
# Ollama 설치 (Linux/macOS)
curl -fsSL https://ollama.ai/install.sh | sh

# Windows (PowerShell)
# Invoke-WebRequest -Uri https://ollama.ai/install.ps1 -OutFile install.ps1; .\install.ps1

# 모델 다운로드
ollama pull llama3.1:8b
ollama pull codellama:7b
ollama pull mistral:7b

# Ollama 서비스 시작
ollama serve
```

### 7.2 MAESTRO와 Ollama 연동

`.env` 파일을 다음과 같이 수정:

```bash
# 로컬 LLM 설정
USE_LOCAL_LLM=true
LOCAL_LLM_BASE_URL=http://host.docker.internal:11434/v1
LOCAL_LLM_MODEL=llama3.1:8b
LOCAL_LLM_API_KEY=ollama

# OpenAI 호환 엔드포인트 사용
LLM_PROVIDER=local
```

### 7.3 연동 테스트

```bash
# CLI로 모델 테스트
./maestro-cli.sh test-llm

# 또는 Python 스크립트로 직접 테스트
python << EOF
import requests

response = requests.post('http://localhost:11434/v1/chat/completions', 
    json={
        'model': 'llama3.1:8b',
        'messages': [{'role': 'user', 'content': 'Hello, MAESTRO!'}],
        'max_tokens': 100
    }
)
print(response.json())
EOF
```

## 8. SearXNG 검색 엔진 설정

### 8.1 SearXNG 컨테이너 설정 확인

```bash
# SearXNG 컨테이너 상태 확인
docker-compose logs searxng

# 설정 파일 확인
docker-compose exec searxng cat /etc/searxng/settings.yml
```

### 8.2 검색 카테고리 설정

SearXNG의 `settings.yml` 파일을 커스터마이징:

```yaml
# searxng/settings.yml
search:
  safe_search: 0
  autocomplete: duckduckgo
  default_lang: ""
  formats:
    - html
    - json  # MAESTRO 통합을 위해 필수

categories:
  general:
    - google
    - bing
    - duckduckgo
  science:
    - arxiv
    - pubmed
    - semantic scholar
  it:
    - github
    - stackoverflow
    - documentation
  news:
    - google news
    - reuters
    - bbc
```

### 8.3 프라이빗 검색 테스트

```bash
# SearXNG API 테스트
curl "http://localhost:8080/search?q=artificial+intelligence&format=json&category=science"

# MAESTRO에서 검색 테스트
# 웹 인터페이스 > Settings > Search > Test Search 버튼 클릭
```

## 9. 실전 활용 시나리오

### 9.1 문서 수집 및 분석

```bash
# CLI로 문서 일괄 업로드
./maestro-cli.sh ingest username ./research_documents

# 지원 형식
# - PDF, DOCX, TXT, MD
# - 웹 URL, arXiv 논문
# - JSON, CSV 데이터

# 업로드 진행 상황 모니터링
./maestro-cli.sh status username
```

### 9.2 연구 프로젝트 생성

웹 인터페이스에서 새 연구 프로젝트 생성:

```yaml
# 연구 설정 예시
Project Name: "AI Agent Architecture Analysis"
Research Question: "What are the latest trends in AI agent architectures?"
Scope: 
  - Academic papers (2023-2024)
  - Industry reports
  - Technical documentation
Output Format: "Comprehensive report with citations"
```

### 9.3 AI 에이전트 워크플로우 실행

```bash
# 1. 계획 수립 단계
Research Agent -> Planning Context Analysis
              -> Outline Generation
              -> Resource Identification

# 2. 데이터 수집 단계  
Search Agent -> Web Search (SearXNG)
             -> Document Retrieval
             -> Content Extraction

# 3. 분석 단계
Analysis Agent -> RAG-based Analysis
               -> Cross-reference Validation
               -> Insight Generation

# 4. 보고서 생성 단계
Report Agent -> Content Synthesis
             -> Citation Management
             -> Output Formatting
```

## 10. 고급 설정 및 최적화

### 10.1 GPU 메모리 최적화

```bash
# GPU 메모리 모니터링
nvidia-smi -l 1

# 메모리 사용량 최적화 설정
# .env 파일에 추가
MAX_GPU_MEMORY=8192  # MB 단위
BATCH_SIZE=32
CHUNK_OVERLAP=100
```

### 10.2 다중 GPU 설정

```bash
# 서비스별 GPU 할당
BACKEND_GPU_DEVICE=0
DOC_PROCESSOR_GPU_DEVICE=1
CLI_GPU_DEVICE=0

# GPU 로드 밸런싱 확인
nvidia-smi topo -m
```

### 10.3 성능 튜닝

```bash
# PostgreSQL 튜닝
# docker-compose.yml에서 postgres 서비스 설정
environment:
  - POSTGRES_SHARED_PRELOAD_LIBRARIES=pg_stat_statements,auto_explain
  - POSTGRES_LOG_STATEMENT=all
  - POSTGRES_EFFECTIVE_CACHE_SIZE=4GB
  - POSTGRES_SHARED_BUFFERS=1GB

# pgvector 인덱스 최적화
docker-compose exec postgres psql -U maestro_user -d maestro_db
CREATE INDEX CONCURRENTLY idx_embeddings_cosine ON documents 
USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
```

## 11. 문제 해결 가이드

### 11.1 일반적인 오류 및 해결책

```bash
# 1. 포트 충돌 오류
Error: Port 3000 already in use
해결: sudo lsof -i :3000; kill -9 <PID>

# 2. GPU 메모리 부족
CUDA out of memory
해결: FORCE_CPU_MODE=true 설정 또는 배치 크기 조정

# 3. 데이터베이스 연결 오류
Connection refused to PostgreSQL
해결: docker-compose restart postgres

# 4. Ollama 연결 실패
Local LLM connection failed
해결: host.docker.internal 대신 실제 IP 사용
```

### 11.2 디버깅 도구 활용

```bash
# 상세 로그 활성화
export MAESTRO_LOG_LEVEL=DEBUG
docker-compose up -d

# 컨테이너 내부 접근
docker-compose exec backend bash
docker-compose exec postgres psql -U maestro_user -d maestro_db

# 건강 상태 검사
curl http://localhost:8000/health
curl http://localhost:3000/health
```

### 11.3 데이터 백업 및 복구

```bash
# 데이터베이스 백업
docker-compose exec postgres pg_dump -U maestro_user maestro_db > backup.sql

# 벡터 데이터 백업 (pgvector 확장 포함)
docker-compose exec postgres pg_dump -U maestro_user -Fc maestro_db > backup.dump

# 복구
docker-compose exec -T postgres psql -U maestro_user -d maestro_db < backup.sql
```

## 12. 보안 고려사항

### 12.1 인증 및 권한 관리

```bash
# 강력한 JWT 시크릿 생성
openssl rand -hex 32

# 사용자 권한 설정
./maestro-cli.sh create-user researcher pass123 --role user
./maestro-cli.sh create-user admin admin123 --role admin

# API 키 로테이션
./maestro-cli.sh rotate-keys
```

### 12.2 네트워크 보안

```bash
# 방화벽 설정 (Ubuntu/Debian)
sudo ufw allow from 192.168.1.0/24 to any port 3000
sudo ufw allow from 192.168.1.0/24 to any port 8000

# Reverse Proxy 설정 (Nginx)
# nginx/maestro.conf
server {
    listen 443 ssl;
    server_name maestro.yourdomain.com;
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_websocket_upgrade on;
    }
    
    location /api {
        proxy_pass http://localhost:8000;
    }
}
```

## 13. 모니터링 및 유지보수

### 13.1 시스템 모니터링

```bash
# 리소스 사용량 모니터링
docker stats maestro_backend maestro_frontend maestro_postgres

# 로그 로테이션 설정
# docker-compose.yml에 추가
logging:
  driver: json-file
  options:
    max-size: "100m"
    max-file: "3"

# 자동 건강 검사
# healthcheck.sh
#!/bin/bash
curl -f http://localhost:8000/health || exit 1
curl -f http://localhost:3000/ || exit 1
```

### 13.2 정기 유지보수

```bash
# 주간 유지보수 스크립트
#!/bin/bash
# weekly_maintenance.sh

# 1. 컨테이너 업데이트
docker-compose pull
docker-compose up -d

# 2. 데이터베이스 정리
./maestro-cli.sh cleanup-orphaned-docs

# 3. 로그 압축
find /var/log/maestro -name "*.log" -mtime +7 -exec gzip {} \;

# 4. 시스템 상태 보고
./maestro-cli.sh system-report > /var/log/maestro/weekly_report_$(date +%Y%m%d).txt
```

## 14. 확장 및 커스터마이징

### 14.1 커스텀 AI 에이전트 개발

```python
# maestro_backend/agents/custom_agent.py
from maestro_backend.core.agent_base import BaseAgent

class CustomResearchAgent(BaseAgent):
    def __init__(self, config):
        super().__init__(config)
        self.specialty = "domain_specific_research"
    
    async def process_request(self, request):
        """커스텀 연구 로직 구현"""
        results = await self.search_documents(request.query)
        analysis = await self.analyze_with_llm(results)
        return await self.generate_report(analysis)
    
    async def search_documents(self, query):
        """도메인 특화 검색 로직"""
        # 구현 로직
        pass
```

### 14.2 API 확장

```python
# maestro_backend/api/custom_endpoints.py
from fastapi import APIRouter, Depends
from maestro_backend.core.auth import get_current_user

router = APIRouter(prefix="/api/custom", tags=["custom"])

@router.post("/domain-research")
async def domain_research(
    request: DomainResearchRequest,
    current_user: User = Depends(get_current_user)
):
    """커스텀 도메인 연구 엔드포인트"""
    agent = CustomResearchAgent(config)
    results = await agent.process_request(request)
    return {"results": results, "status": "completed"}
```

## 15. 트러블슈팅 체크리스트

### 15.1 설치 후 체크리스트

- [ ] Docker 컨테이너 모두 실행 중 (`docker-compose ps`)
- [ ] 포트 3000, 8000, 5432, 8080 접근 가능
- [ ] 데이터베이스 연결 정상 (`./maestro-cli.sh reset-db --check`)
- [ ] LLM API 연결 테스트 통과
- [ ] 웹 인터페이스 로그인 가능
- [ ] 검색 기능 정상 작동

### 15.2 성능 최적화 체크리스트

- [ ] GPU 메모리 사용량 모니터링
- [ ] PostgreSQL 인덱스 최적화
- [ ] SearXNG 응답 속도 확인
- [ ] 문서 처리 배치 크기 조정
- [ ] 캐시 설정 확인

## 16. 결론

MAESTRO는 AI 기반 연구 자동화의 새로운 패러다임을 제시하는 강력한 플랫폼입니다. 이 튜토리얼을 통해 기본 설치부터 고급 설정까지 완전히 마스터할 수 있습니다.

### 주요 성과

✅ **완전 셀프 호스팅 환경 구축**  
✅ **AI 에이전트 기반 연구 워크플로우 구현**  
✅ **로컬 LLM과 프라이빗 검색엔진 통합**  
✅ **확장 가능한 아키텍처 이해**  

### 다음 단계

1. **고급 AI 에이전트 개발**: 도메인 특화 연구 에이전트 구현
2. **기업 환경 배포**: Kubernetes 클러스터 배포 고려
3. **API 통합**: 기존 연구 도구와의 연동 확장
4. **커뮤니티 기여**: MAESTRO 오픈소스 프로젝트 참여

MAESTRO를 통해 연구 생산성을 혁신적으로 향상시키고, AI 에이전트의 무한한 가능성을 경험해보세요! 🚀

---

**참고 자료**
- [MAESTRO GitHub Repository](https://github.com/murtaza-nasir/maestro)
- [Docker Compose 공식 문서](https://docs.docker.com/compose/)
- [PostgreSQL + pgvector 가이드](https://github.com/pgvector/pgvector)
- [SearXNG 설정 가이드](https://docs.searxng.org/)
