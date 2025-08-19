# LangWatch 로컬 테스트 환경

## 개요

이 디렉토리는 LangWatch를 macOS 환경에서 로컬로 실행하고 테스트하기 위한 환경을 제공합니다.

## 사전 요구사항

- **Docker Desktop**: [다운로드](https://www.docker.com/products/docker-desktop)
- **Python 3.8+**: `python3 --version`으로 확인
- **Git**: LangWatch 리포지토리 클론용

## 빠른 시작

### 1. 자동 설정 (권장)

```bash
# 스크립트 실행
./test-langwatch-setup.sh
```

이 스크립트는 다음 작업을 자동으로 수행합니다:
- LangWatch 리포지토리 클론
- Docker 환경 설정 및 실행
- Python 테스트 환경 구성
- 기본 테스트 스크립트 생성
- 유용한 별칭 생성

### 2. 수동 설정

```bash
# LangWatch 클론
git clone https://github.com/langwatch/langwatch.git
cd langwatch

# 환경 설정
cp langwatch/.env.example langwatch/.env

# ARM Mac의 경우
docker compose -f compose.yml -f docker-compose.arm64.override.yml up -d --wait --build

# Intel Mac의 경우
docker compose up -d --wait --build
```

## 테스트 실행

### 기본 테스트

```bash
# Python 가상환경 활성화
source langwatch/langwatch-test-env/bin/activate

# 기본 테스트 실행
python test_langwatch_basic.py
```

### 수동 테스트

```bash
# 서버 상태 확인
curl http://localhost:5560/health

# 대시보드 열기
open http://localhost:5560
```

## 유용한 명령어

### Docker 관리

```bash
# 별칭 로드 (한 번만 실행)
source langwatch-aliases.sh

# LangWatch 시작
langwatch-start

# LangWatch 중지
langwatch-stop

# 로그 확인
langwatch-logs

# 컨테이너 상태 확인
langwatch-status
```

### 개발 환경

```bash
# Python 가상환경 활성화
langwatch-shell

# 테스트 실행
langwatch-test

# 대시보드 열기
langwatch-dash
```

## 트러블슈팅

### 포트 충돌

기본 포트 5560이 사용 중인 경우:

```bash
# 포트 사용 프로세스 확인
lsof -i :5560

# 다른 포트로 실행하려면 .env 파일 수정
echo "LANGWATCH_PORT=5561" >> langwatch/.env
```

### ARM64 (Apple Silicon) 관련

ARM64 Mac에서 오류가 발생하면:

```bash
# ARM64 전용 실행
docker compose -f compose.yml -f docker-compose.arm64.override.yml up -d
```

### 메모리 부족

Docker Desktop의 메모리 할당을 늘려주세요:
- Docker Desktop > Settings > Resources > Memory를 8GB 이상으로 설정

## 디렉토리 구조

```
langwatch-test/
├── README.md                 # 이 파일
├── test-langwatch-setup.sh   # 자동 설정 스크립트
├── langwatch-aliases.sh      # 유용한 별칭들
├── test_langwatch_basic.py   # 기본 테스트 스크립트
└── langwatch/               # LangWatch 클론 디렉토리
    ├── compose.yml          # Docker Compose 설정
    ├── docker-compose.arm64.override.yml  # ARM64 오버라이드
    └── langwatch-test-env/  # Python 가상환경
```

## 참고 링크

- [LangWatch GitHub](https://github.com/langwatch/langwatch)
- [LangWatch 문서](https://docs.langwatch.ai)
- [Docker Desktop 다운로드](https://www.docker.com/products/docker-desktop)
