#!/bin/bash

# AnyCrawl 테스트 스크립트
# 작성자: ThakiCloud  
# 목적: macOS에서 AnyCrawl 설치 및 기본 기능 테스트

set -e

echo "🚀 AnyCrawl 테스트 스크립트 시작"
echo "======================================"

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 함수 정의
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 1. 시스템 요구사항 확인
print_status "시스템 요구사항 확인 중..."

# Docker 확인
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    print_success "Docker 설치됨: $DOCKER_VERSION"
else
    print_error "Docker가 설치되지 않았습니다."
    echo "Homebrew로 설치하려면: brew install --cask docker"
    exit 1
fi

# Docker Compose 확인
if command -v docker-compose &> /dev/null; then
    COMPOSE_VERSION=$(docker-compose --version)
    print_success "Docker Compose 설치됨: $COMPOSE_VERSION"
else
    print_error "Docker Compose가 설치되지 않았습니다."
    exit 1
fi

# Git 확인
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version)
    print_success "Git 설치됨: $GIT_VERSION"
else
    print_error "Git이 설치되지 않았습니다."
    exit 1
fi

# jq 확인 (JSON 처리용)
if command -v jq &> /dev/null; then
    JQ_VERSION=$(jq --version)
    print_success "jq 설치됨: $JQ_VERSION"
else
    print_warning "jq가 설치되지 않음. JSON 응답 파싱을 위해 설치를 권장합니다."
    echo "설치 명령어: brew install jq"
fi

# 2. 테스트 디렉토리 설정
TEST_DIR="$HOME/anycrawl-test-$(date +%Y%m%d-%H%M%S)"
print_status "테스트 디렉토리 생성: $TEST_DIR"

mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

# 3. AnyCrawl 저장소 클론
print_status "AnyCrawl 저장소 클론 중..."
git clone https://github.com/any4ai/AnyCrawl.git
cd AnyCrawl

print_success "AnyCrawl 저장소 클론 완료"

# 4. 환경 설정 파일 생성
print_status "환경 설정 파일 생성 중..."

# .env 파일 생성
cat > .env << 'EOF'
NODE_ENV=production
ANYCRAWL_API_PORT=8080
ANYCRAWL_HEADLESS=true
ANYCRAWL_IGNORE_SSL_ERROR=true
ANYCRAWL_KEEP_ALIVE=true
ANYCRAWL_AVAILABLE_ENGINES=cheerio,playwright,puppeteer
ANYCRAWL_API_DB_TYPE=sqlite
ANYCRAWL_API_DB_CONNECTION=/usr/src/app/db/database.db
ANYCRAWL_REDIS_URL=redis://redis:6379
ANYCRAWL_API_AUTH_ENABLED=false
ANYCRAWL_API_CREDITS_ENABLED=false
EOF

print_success "환경 설정 파일 생성 완료"

# 5. Docker 컨테이너 실행
print_status "Docker 컨테이너 빌드 및 실행 중..."
print_warning "이 과정은 몇 분이 소요될 수 있습니다..."

# Docker 이미지 빌드 및 실행 (백그라운드)
docker-compose up --build -d

# 서비스 시작 대기
sleep 30

# 컨테이너 상태 확인
if docker-compose ps | grep -q "Up"; then
    print_success "AnyCrawl 서비스 실행 중"
else
    print_error "AnyCrawl 서비스 시작 실패"
    echo "로그 확인: docker-compose logs"
    exit 1
fi

# 6. API 테스트 스크립트 생성
cat > test-api.sh << 'EOF'
#!/bin/bash

API_URL="http://localhost:8080"
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== AnyCrawl API 테스트 ===${NC}"

# 헬스 체크
echo -e "\n${BLUE}1. 헬스 체크${NC}"
if curl -s "$API_URL/health" | grep -q "ok"; then
    echo -e "${GREEN}✅ API 서버 정상 동작${NC}"
else
    echo -e "${RED}❌ API 서버 응답 없음${NC}"
    exit 1
fi

# 기본 웹 스크래핑 테스트
echo -e "\n${BLUE}2. 웹 스크래핑 테스트 (Cheerio)${NC}"
curl -X POST "$API_URL/v1/scrape" \
  -H 'Content-Type: application/json' \
  -d '{
    "url": "https://httpbin.org/html",
    "engine": "cheerio"
  }' | jq -r '.data.title // "테스트 완료"'

# JavaScript 렌더링 테스트
echo -e "\n${BLUE}3. JavaScript 렌더링 테스트 (Playwright)${NC}"
curl -X POST "$API_URL/v1/scrape" \
  -H 'Content-Type: application/json' \
  -d '{
    "url": "https://httpbin.org/json",
    "engine": "playwright"
  }' | jq -r '.success // false'

# SERP 검색 테스트
echo -e "\n${BLUE}4. SERP 검색 테스트${NC}"
curl -X POST "$API_URL/v1/search" \
  -H 'Content-Type: application/json' \
  -d '{
    "query": "AnyCrawl web crawler",
    "limit": 5
  }' | jq -r '.data.results[0].title // "검색 완료"'

echo -e "\n${GREEN}🎉 모든 테스트 완료!${NC}"
EOF

chmod +x test-api.sh
print_success "API 테스트 스크립트 생성 완료"

# 7. 사용 예제 스크립트 생성
cat > examples.sh << 'EOF'
#!/bin/bash

API_URL="http://localhost:8080"

echo "🔍 AnyCrawl 사용 예제"
echo "===================="

echo -e "\n📰 예제 1: 뉴스 사이트 스크래핑"
curl -X POST "$API_URL/v1/scrape" \
  -H 'Content-Type: application/json' \
  -d '{
    "url": "https://news.ycombinator.com",
    "engine": "cheerio"
  }' | jq '.data.title'

echo -e "\n🔍 예제 2: 기술 관련 검색"
curl -X POST "$API_URL/v1/search" \
  -H 'Content-Type: application/json' \
  -d '{
    "query": "machine learning python",
    "pages": 1,
    "limit": 3
  }' | jq '.data.results[] | {title, url}'

echo -e "\n🌐 예제 3: SPA 웹사이트 크롤링"
curl -X POST "$API_URL/v1/scrape" \
  -H 'Content-Type: application/json' \
  -d '{
    "url": "https://httpbin.org/delay/2",
    "engine": "playwright"
  }' | jq '.data.metadata'

echo -e "\n✅ 예제 실행 완료"
EOF

chmod +x examples.sh
print_success "예제 스크립트 생성 완료"

# 8. 환경 정보 수집
cat > environment-info.txt << EOF
AnyCrawl 테스트 환경 정보
========================

시스템 정보:
- OS: $(uname -s) $(uname -r)
- 아키텍처: $(uname -m)

Docker 환경:
- Docker: $(docker --version)
- Docker Compose: $(docker-compose --version)

개발 도구:
- Git: $(git --version)
- jq: $(jq --version 2>/dev/null || echo "설치되지 않음")

AnyCrawl 설정:
- 포트: 8080
- 데이터베이스: SQLite
- 지원 엔진: cheerio, playwright, puppeteer

생성 시간: $(date)
테스트 디렉토리: $(pwd)
EOF

print_success "환경 정보 저장: environment-info.txt"

# 9. 최종 안내
echo ""
echo "🎉 AnyCrawl 테스트 환경 설정 완료!"
echo "=================================="
echo ""
echo "📁 테스트 디렉토리: $TEST_DIR/AnyCrawl"
echo ""
echo "🚀 다음 단계:"
echo "1. cd $TEST_DIR/AnyCrawl"
echo "2. ./test-api.sh 실행하여 기본 API 테스트"
echo "3. ./examples.sh 실행하여 실제 사용 예제 확인"
echo ""
echo "📋 생성된 파일들:"
echo "- test-api.sh: API 기능 테스트 스크립트"
echo "- examples.sh: 실전 사용 예제 스크립트"
echo "- environment-info.txt: 시스템 환경 정보"
echo "- .env: AnyCrawl 환경 설정 파일"
echo ""
echo "🐳 Docker 관리 명령어:"
echo "- 로그 확인: docker-compose logs -f"
echo "- 서비스 중지: docker-compose down"
echo "- 서비스 재시작: docker-compose restart"
echo ""
echo "💡 팁: API 문서는 http://localhost:8080/docs 에서 확인 가능합니다!"

# 10. 실시간 테스트 옵션
echo ""
read -p "지금 API 테스트를 실행하시겠습니까? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "API 테스트 실행 중..."
    ./test-api.sh
else
    print_success "테스트 환경 준비 완료. 언제든지 ./test-api.sh로 시작하세요!"
fi
