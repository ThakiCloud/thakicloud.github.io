---
title: "OpenHands AI 소프트웨어 개발 에이전트 완전 튜토리얼: 코드 작성부터 배포까지"
excerpt: "AI가 대신 코딩해주는 시대! OpenHands 설치부터 실전 활용까지 macOS 완벽 가이드"
seo_title: "OpenHands AI 개발 에이전트 완전 튜토리얼 - macOS Docker 설치 실행 가이드 - Thaki Cloud"
seo_description: "OpenHands AI 소프트웨어 개발 에이전트 완전 가이드. macOS Docker 설치, 실행, 사용법부터 고급 활용까지 단계별 튜토리얼"
date: 2025-06-28
categories: 
  - tutorials
  - dev
tags: 
  - OpenHands
  - AI개발에이전트
  - Docker
  - 소프트웨어개발
  - LLM
  - Claude
  - 자동화
  - macOS
  - 개발도구
author_profile: true
toc: true
toc_label: "OpenHands 튜토리얼"
canonical_url: "https://thakicloud.github.io/openhands-ai-software-development-agent-tutorial/"
published: false
---

**읽는 시간: 18분**

AI가 코드를 작성하고, 명령을 실행하며, 웹을 브라우징하고, API를 호출하는 시대가 왔습니다. **OpenHands** (이전 OpenDevin)는 인간 개발자가 할 수 있는 모든 작업을 수행할 수 있는 AI 소프트웨어 개발 에이전트입니다. 이 튜토리얼에서는 macOS 환경에서 OpenHands를 설치하고 실제로 활용하는 방법을 단계별로 안내합니다.

## OpenHands란 무엇인가?

**OpenHands**는 [All-Hands-AI](https://github.com/All-Hands-AI/OpenHands)에서 개발한 오픈소스 AI 소프트웨어 개발 플랫폼입니다. 59.4k 스타를 받으며 개발자 커뮤니티에서 큰 주목을 받고 있는 프로젝트입니다.

### 주요 특징

- **완전한 개발 환경**: 코드 수정, 명령 실행, 웹 브라우징, API 호출
- **인간과 동일한 능력**: StackOverflow 코드 복사도 가능
- **다양한 LLM 지원**: Claude Sonnet 4, GPT-4o, 로컬 모델 등
- **오픈소스**: MIT 라이선스로 자유로운 사용 가능
- **Docker 기반**: 안전한 샌드박스 환경에서 실행

### 지원하는 작업

OpenHands AI 에이전트는 다음과 같은 작업을 수행할 수 있습니다:

- 🔧 **코드 작성 및 수정**: 새로운 기능 개발, 버그 수정
- 🔨 **명령 실행**: 터미널 명령, 빌드, 테스트 실행
- 🌐 **웹 브라우징**: 정보 검색, 문서 참조
- 📡 **API 호출**: 외부 서비스 연동, 데이터 가져오기
- 📄 **문서 작성**: README, 주석, 설명서 생성
- 🧪 **테스트 작성**: 단위 테스트, 통합 테스트 생성

## 시스템 요구사항

### 필수 조건

- **운영체제**: macOS (Intel/Apple Silicon 모두 지원)
- **Docker**: Docker Desktop 또는 OrbStack
- **메모리**: 최소 8GB RAM (16GB 권장)
- **저장공간**: 최소 10GB 여유 공간

### 테스트 환경

```bash
- 운영체제: macOS Sequoia 15.0 (Darwin 25.0.0)
- 아키텍처: Apple Silicon (arm64)
- Docker: 28.2.2
- Python: 3.12.3
```

## 1단계: 환경 준비

### Docker 설치 확인

먼저 Docker가 설치되고 실행 중인지 확인합니다:

```bash
# Docker 버전 확인
docker --version

# Docker 실행 상태 확인
docker info
```

**예상 출력:**
```
Docker version 28.2.2, build e6534b4
```

Docker가 설치되지 않은 경우 [Docker Desktop](https://www.docker.com/products/docker-desktop) 또는 [OrbStack](https://orbstack.dev/)을 설치하세요.

### 포트 사용 확인

OpenHands는 기본적으로 포트 3000을 사용하지만, 이미 사용 중인 경우 다른 포트를 사용할 수 있습니다:

```bash
# 포트 3000 사용 여부 확인
lsof -i :3000

# 포트 3001 사용 여부 확인
lsof -i :3001
```

## 2단계: OpenHands 설치 및 테스트

### 자동화된 설치 스크립트

다음 스크립트를 사용하여 OpenHands를 쉽게 설치하고 테스트할 수 있습니다:

```bash
#!/bin/bash
# test_openhands.sh

echo "🚀 OpenHands AI 소프트웨어 개발 에이전트 테스트 시작"

# 시스템 정보 확인
echo "📋 시스템 환경 확인"
echo "- 운영체제: $(uname -s)"
echo "- 아키텍처: $(uname -m)"
echo "- Docker 버전: $(docker --version)"

# Docker 상태 확인
if docker info >/dev/null 2>&1; then
    echo "✅ Docker가 실행 중입니다"
else
    echo "❌ Docker가 실행되지 않고 있습니다"
    exit 1
fi

# OpenHands 이미지 다운로드
echo "📦 OpenHands 이미지 다운로드"
docker pull docker.all-hands.dev/all-hands-ai/runtime:0.47-nikolaik
docker pull docker.all-hands.dev/all-hands-ai/openhands:0.47

# OpenHands 디렉토리 생성
mkdir -p ~/.openhands
echo "✅ ~/.openhands 디렉토리 생성됨"

echo "✅ OpenHands 설치 완료!"
```

스크립트를 실행합니다:

```bash
chmod +x test_openhands.sh
./test_openhands.sh
```

### 테스트 결과

**성공 출력 예시:**
```
🚀 OpenHands AI 소프트웨어 개발 에이전트 테스트 시작
📋 시스템 환경 확인
- 운영체서: Darwin
- 아키텍처: arm64
- Docker 버전: Docker version 28.2.2, build e6534b4
✅ Docker가 실행 중입니다
📦 OpenHands 이미지 다운로드
✅ ~/.openhands 디렉토리 생성됨
✅ OpenHands 설치 완료!
```

## 3단계: OpenHands 실행

### 기본 실행 방법

포트 3001에서 OpenHands를 실행합니다:

```bash
docker run -it --rm --pull=always \
    -e SANDBOX_RUNTIME_CONTAINER_IMAGE=docker.all-hands.dev/all-hands-ai/runtime:0.47-nikolaik \
    -e LOG_ALL_EVENTS=true \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v ~/.openhands:/.openhands \
    -p 3001:3000 \
    --add-host host.docker.internal:host-gateway \
    --name openhands-app \
    docker.all-hands.dev/all-hands-ai/openhands:0.47
```

### 백그라운드 실행

GUI 없이 백그라운드에서 실행하려면:

```bash
docker run -d --pull=always \
    -e SANDBOX_RUNTIME_CONTAINER_IMAGE=docker.all-hands.dev/all-hands-ai/runtime:0.47-nikolaik \
    -e LOG_ALL_EVENTS=true \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v ~/.openhands:/.openhands \
    -p 3001:3000 \
    --add-host host.docker.internal:host-gateway \
    --name openhands-app \
    docker.all-hands.dev/all-hands-ai/openhands:0.47
```

### 웹 인터페이스 접속

브라우저에서 다음 URL로 접속합니다:

```
http://localhost:3001
```

## 4단계: zsh Alias 설정

편리한 사용을 위해 zsh alias를 설정합니다:

```bash
#!/bin/bash
# setup_openhands_aliases.sh

ZSHRC_FILE="$HOME/.zshrc"

# 백업 생성
cp "$ZSHRC_FILE" "$ZSHRC_FILE.backup.$(date +%Y%m%d_%H%M%S)"

# OpenHands alias 추가
cat << 'EOF' >> "$ZSHRC_FILE"

# ==================================================
# OpenHands AI 소프트웨어 개발 에이전트 Aliases
# ==================================================

# 기본 명령어
alias openhands-start='docker run -it --rm --pull=always \
    -e SANDBOX_RUNTIME_CONTAINER_IMAGE=docker.all-hands.dev/all-hands-ai/runtime:0.47-nikolaik \
    -e LOG_ALL_EVENTS=true \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v ~/.openhands:/.openhands \
    -p 3001:3000 \
    --add-host host.docker.internal:host-gateway \
    --name openhands-app \
    docker.all-hands.dev/all-hands-ai/openhands:0.47'

alias openhands-start-bg='docker run -d --pull=always \
    -e SANDBOX_RUNTIME_CONTAINER_IMAGE=docker.all-hands.dev/all-hands-ai/runtime:0.47-nikolaik \
    -e LOG_ALL_EVENTS=true \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v ~/.openhands:/.openhands \
    -p 3001:3000 \
    --add-host host.docker.internal:host-gateway \
    --name openhands-app \
    docker.all-hands.dev/all-hands-ai/openhands:0.47'

alias openhands-stop='docker stop openhands-app'
alias openhands-restart='docker restart openhands-app'
alias openhands-logs='docker logs -f openhands-app'
alias openhands-status='docker ps -a | grep openhands-app'
alias openhands-web='open http://localhost:3001'
alias openhands-clean='docker stop openhands-app 2>/dev/null || true && docker rm openhands-app 2>/dev/null || true'

# 편의 함수
openhands-help() {
    echo "🤖 OpenHands AI 개발 에이전트 도움말"
    echo "=================================="
    echo "openhands-start      - OpenHands 시작"
    echo "openhands-start-bg   - 백그라운드 시작"
    echo "openhands-stop       - 중지"
    echo "openhands-restart    - 재시작"
    echo "openhands-logs       - 로그 확인"
    echo "openhands-web        - 웹 브라우저 열기"
    echo "openhands-clean      - 완전 정리"
    echo ""
    echo "🌐 접속: http://localhost:3001"
}
EOF

echo "✅ OpenHands alias 설정 완료"
echo "새 터미널을 열거나 'source ~/.zshrc'를 실행하세요"
```

스크립트를 실행합니다:

```bash
chmod +x setup_openhands_aliases.sh
./setup_openhands_aliases.sh
source ~/.zshrc
```

### Alias 사용법

설정 후 다음과 같이 간단하게 사용할 수 있습니다:

```bash
# OpenHands 시작
openhands-start-bg

# 웹 브라우저 열기
openhands-web

# 상태 확인
openhands-status

# 로그 확인
openhands-logs

# 도움말
openhands-help
```

## 5단계: LLM 설정

### 지원하는 LLM

OpenHands는 다양한 LLM을 지원합니다:

| **제공업체** | **모델** | **성능** | **비용** |
|-------------|----------|----------|----------|
| **Anthropic** | Claude Sonnet 4 | ⭐⭐⭐⭐⭐ | 높음 |
| **OpenAI** | GPT-4o | ⭐⭐⭐⭐ | 높음 |
| **OpenAI** | GPT-4o-mini | ⭐⭐⭐ | 낮음 |
| **로컬** | Ollama | ⭐⭐⭐ | 무료 |

### 권장 설정

**최고 성능을 원한다면:**
- **모델**: `anthropic/claude-sonnet-4-20250514`
- **API 키**: Anthropic API 키 필요

**비용을 절약하려면:**
- **모델**: `openai/gpt-4o-mini`
- **API 키**: OpenAI API 키 필요

### API 키 설정

1. **웹 인터페이스에서 설정**:
   - `http://localhost:3001` 접속
   - Settings → LLM Provider 선택
   - API 키 입력

2. **환경변수로 설정**:
```bash
# Anthropic
export ANTHROPIC_API_KEY="your-api-key-here"

# OpenAI
export OPENAI_API_KEY="your-api-key-here"
```

## 6단계: 실전 사용 예제

### 예제 1: Python 웹 애플리케이션 생성

**프롬프트:**
```
Flask를 사용해서 간단한 할 일 관리 웹 애플리케이션을 만들어주세요.
- 할 일 추가, 삭제, 완료 표시 기능
- SQLite 데이터베이스 사용
- Bootstrap으로 예쁘게 스타일링
- 로컬에서 실행할 수 있도록 설정
```

**OpenHands가 수행하는 작업:**
1. Flask 애플리케이션 구조 생성
2. SQLite 데이터베이스 모델 정의
3. HTML 템플릿 작성 (Bootstrap 포함)
4. 라우팅 및 비즈니스 로직 구현
5. requirements.txt 생성
6. 실행 방법 안내

### 예제 2: API 문서 자동 생성

**프롬프트:**
```
내 FastAPI 프로젝트에 API 문서를 자동으로 생성하고,
README.md 파일도 업데이트해주세요.
프로젝트 구조를 분석해서 적절한 설명도 추가해주세요.
```

**OpenHands가 수행하는 작업:**
1. 프로젝트 구조 분석
2. FastAPI 엔드포인트 검색
3. Swagger/OpenAPI 문서 생성
4. README.md 업데이트
5. 코드 주석 추가

### 예제 3: 테스트 코드 작성

**프롬프트:**
```
내 Python 프로젝트에 pytest를 사용한 단위 테스트를 추가해주세요.
커버리지도 확인할 수 있게 설정해주세요.
```

**OpenHands가 수행하는 작업:**
1. 기존 코드 분석
2. pytest 테스트 케이스 작성
3. pytest.ini 설정 파일 생성
4. pytest-cov 설정
5. 테스트 실행 및 결과 확인

## 7단계: 고급 활용 방법

### 프로젝트별 설정

각 프로젝트에 대해 OpenHands 설정을 커스터마이징할 수 있습니다:

```bash
# 프로젝트 디렉토리에 설정 파일 생성
mkdir -p .openhands
cat > .openhands/config.toml << EOF
[core]
max_iterations = 100
max_chars = 10000000

[sandbox]
container_image = "docker.all-hands.dev/all-hands-ai/runtime:0.47-nikolaik"

[llm]
model = "anthropic/claude-sonnet-4-20250514"
api_key = "${ANTHROPIC_API_KEY}"
temperature = 0.1
max_tokens = 4096
EOF
```

### 플러그인 및 확장

OpenHands는 다양한 플러그인을 지원합니다:

- **코드 분석**: pylint, black, mypy 등
- **데이터베이스**: PostgreSQL, MongoDB 등
- **클라우드**: AWS, GCP, Azure 등
- **CI/CD**: GitHub Actions, Jenkins 등

### 헤드리스 모드

CLI에서 OpenHands를 사용할 수 있습니다:

```bash
# 명령줄에서 직접 실행
python -m openhands.core.main \
    --task "Python 계산기 만들기" \
    --agent CodeActAgent \
    --model anthropic/claude-sonnet-4-20250514
```

## 8단계: 문제 해결

### 일반적인 문제와 해결방법

**1. 포트 충돌**
```bash
# 다른 포트 사용
docker run ... -p 3002:3000 ...
```

**2. 메모리 부족**
```bash
# Docker 메모리 할당 증가
# Docker Desktop > Settings > Resources > Memory
```

**3. 권한 문제**
```bash
# Docker 소켓 권한 확인
ls -la /var/run/docker.sock
sudo chmod 666 /var/run/docker.sock
```

**4. 네트워크 연결 문제**
```bash
# DNS 설정 확인
docker run --dns=8.8.8.8 ...
```

### 로그 확인

```bash
# OpenHands 로그 확인
openhands-logs

# Docker 시스템 로그
docker system events

# 컨테이너 상세 정보
docker inspect openhands-app
```

## 9단계: 보안 고려사항

### 네트워크 보안

공용 네트워크에서 사용할 때는 추가 보안 조치가 필요합니다:

```bash
# 로컬 인터페이스만 바인딩
docker run ... -p 127.0.0.1:3001:3000 ...

# 방화벽 설정 (macOS)
sudo pfctl -f /etc/pf.conf
```

### 데이터 보호

```bash
# 민감한 데이터 제외
echo "*.env" >> ~/.openhands/.gitignore
echo "*.key" >> ~/.openhands/.gitignore
echo "*.pem" >> ~/.openhands/.gitignore
```

### 컨테이너 격리

```bash
# 읽기 전용 루트 파일시스템
docker run --read-only ...

# 제한된 권한으로 실행
docker run --user 1000:1000 ...
```

## 10단계: 성능 최적화

### 메모리 최적화

```bash
# Docker 메모리 제한 설정
docker run --memory=4g --memory-swap=4g ...
```

### 디스크 최적화

```bash
# 불필요한 Docker 이미지 정리
docker system prune -af

# OpenHands 캐시 정리
rm -rf ~/.openhands/cache/*
```

### CPU 최적화

```bash
# CPU 제한 설정
docker run --cpus="2.0" ...
```

## 실제 프로덕션 활용 사례

### 개발 워크플로우 자동화

**시나리오**: 새로운 기능 개발 프로세스 자동화

1. **요구사항 분석**: OpenHands가 기획서를 읽고 기술 스펙 작성
2. **코드 생성**: 기본 구조와 핵심 로직 구현
3. **테스트 작성**: 단위 테스트와 통합 테스트 자동 생성
4. **문서화**: API 문서와 사용자 가이드 작성
5. **CI/CD 설정**: GitHub Actions 워크플로우 구성

### 코드 리뷰 자동화

**시나리오**: Pull Request 자동 분석 및 개선 제안

```bash
# GitHub Actions에서 OpenHands 실행
- name: Code Review with OpenHands
  run: |
    python -m openhands.core.main \
      --task "이 PR을 리뷰하고 개선점을 제안해주세요" \
      --github-token ${{ secrets.GITHUB_TOKEN }} \
      --pr-number $`github.event.number`
```

### 레거시 코드 마이그레이션

**시나리오**: Python 2에서 Python 3으로 대규모 코드베이스 마이그레이션

1. **분석**: 호환성 문제 식별
2. **계획**: 마이그레이션 전략 수립
3. **실행**: 단계별 코드 변환
4. **검증**: 자동 테스트 실행
5. **문서화**: 변경 사항 기록

## OpenHands vs 기존 개발 도구

### 비교 분석

| **도구** | **자동화 수준** | **학습 곡선** | **확장성** | **비용** |
|----------|----------------|---------------|------------|----------|
| **OpenHands** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | API 비용 |
| **GitHub Copilot** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | $10/월 |
| **Cursor** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | $20/월 |
| **Tabnine** | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ | $12/월 |

### OpenHands의 장점

- **완전한 자동화**: 전체 개발 프로세스 커버
- **오픈소스**: 투명하고 확장 가능
- **다양한 LLM 지원**: 선택의 자유
- **격리된 환경**: 안전한 실험 가능

### 제한사항

- **API 비용**: 대규모 사용 시 비용 증가
- **네트워크 의존성**: 인터넷 연결 필수
- **학습 필요**: 효과적 사용을 위한 프롬프트 엔지니어링

## 커뮤니티와 리소스

### 공식 리소스

- **GitHub**: [All-Hands-AI/OpenHands](https://github.com/All-Hands-AI/OpenHands)
- **문서**: [docs.all-hands.dev](https://docs.all-hands.dev)
- **클라우드 서비스**: [OpenHands Cloud](https://cloud.all-hands.dev)

### 커뮤니티

- **Slack**: OpenHands 워크스페이스
- **Discord**: 커뮤니티 서버
- **Reddit**: r/OpenHands
- **Stack Overflow**: `openhands` 태그

### 기여하기

OpenHands는 오픈소스 프로젝트로 누구나 기여할 수 있습니다:

```bash
# 프로젝트 클론
git clone https://github.com/All-Hands-AI/OpenHands.git
cd OpenHands

# 개발 환경 설정
python -m venv venv
source venv/bin/activate
pip install -e .

# 테스트 실행
pytest tests/
```

## 결론

OpenHands는 AI 기반 소프트웨어 개발의 새로운 패러다임을 제시하는 강력한 도구입니다. 단순한 코드 자동완성을 넘어 전체 개발 프로세스를 자동화할 수 있는 잠재력을 가지고 있습니다.

### 핵심 가치

- **생산성 향상**: 반복적인 작업 자동화로 개발 속도 증가
- **품질 개선**: 일관된 코드 스타일과 베스트 프랙티스 적용
- **학습 효과**: AI의 코드 작성 과정을 통한 새로운 기술 습득
- **시간 절약**: 문서 작성, 테스트 생성 등의 부수적 작업 자동화

### 시작하기

1. **Docker 설치 및 확인**
2. **OpenHands 이미지 다운로드**
3. **zsh alias 설정**
4. **LLM API 키 준비**
5. **간단한 프로젝트로 실험**

AI가 대신 코딩해주는 미래는 이미 시작되었습니다. OpenHands와 함께 더 효율적이고 창의적인 개발 경험을 만나보세요!

**추가 정보와 최신 업데이트**: [GitHub Repository](https://github.com/All-Hands-AI/OpenHands)에서 확인하실 수 있습니다. 