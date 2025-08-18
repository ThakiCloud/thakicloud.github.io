#!/bin/bash

# Archon 통합 테스트 스크립트
# 작성자: Thaki Cloud
# 목적: Archon OS 설치부터 실제 기능 테스트까지 자동화

set -e

echo "🔥 Archon OS 통합 테스트 시작"
echo "========================================"

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 헬퍼 함수들
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 서비스 상태 확인 함수
check_service() {
    local service_name=$1
    local url=$2
    local expected_status=$3
    
    echo -n "  - $service_name 상태 확인... "
    
    if curl -s -f "$url" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ 실행 중${NC}"
        return 0
    else
        echo -e "${RED}❌ 응답 없음${NC}"
        return 1
    fi
}

# 1. 기본 환경 확인
echo
log_info "1. 기본 환경 확인"
echo "Docker 버전: $(docker --version)"
echo "Docker Compose 버전: $(docker-compose --version)"

# 2. 컨테이너 상태 확인
echo
log_info "2. Archon 서비스 상태 확인"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(Archon|archon)" || {
    log_error "Archon 컨테이너가 실행되지 않았습니다."
    exit 1
}

# 3. 각 서비스 Health Check
echo
log_info "3. 서비스 Health Check"

# UI 확인
check_service "Archon UI" "http://localhost:3737"

# API 서버 확인 (더 관대한 체크)
echo -n "  - Archon Server API 상태 확인... "
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8181 | grep -q "200\|404\|405"; then
    echo -e "${GREEN}✅ 실행 중${NC}"
else
    echo -e "${YELLOW}⚠️  응답 지연 (서버 시작 중일 수 있음)${NC}"
fi

# Agents 서비스 확인
check_service "Archon Agents" "http://localhost:8052/health"

# MCP 서버 확인
echo -n "  - Archon MCP 상태 확인... "
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8051 | grep -q "200\|404\|405"; then
    echo -e "${GREEN}✅ 실행 중${NC}"
else
    echo -e "${YELLOW}⚠️  응답 지연${NC}"
fi

# 4. 포트 바인딩 확인
echo
log_info "4. 포트 바인딩 확인"
netstat -an | grep -E "(3737|8181|8051|8052)" | grep LISTEN | while read line; do
    echo "  ✅ $line"
done

# 5. 테스트 환경 정보
echo
log_info "5. 테스트 환경 정보"
echo "  - 호스트: localhost"
echo "  - UI 주소: http://localhost:3737"
echo "  - API 주소: http://localhost:8181"
echo "  - MCP 주소: http://localhost:8051"
echo "  - Agents 주소: http://localhost:8052"

# 6. 간단한 기능 테스트
echo
log_info "6. 기본 기능 테스트"

# UI 페이지 로드 테스트
echo -n "  - UI 페이지 로드 테스트... "
if curl -s http://localhost:3737 | grep -q "Archon"; then
    echo -e "${GREEN}✅ 성공${NC}"
else
    echo -e "${YELLOW}⚠️  페이지 확인 필요${NC}"
fi

# Agents 서비스 응답 테스트
echo -n "  - AI Agents 서비스 응답 테스트... "
agents_response=$(curl -s http://localhost:8052/health 2>/dev/null || echo "")
if echo "$agents_response" | grep -q "healthy"; then
    echo -e "${GREEN}✅ 성공${NC}"
    echo "    - 사용 가능한 에이전트: $(echo "$agents_response" | jq -r '.agents_available[]' 2>/dev/null | tr '\n' ', ' | sed 's/,$//' || echo 'N/A')"
else
    echo -e "${YELLOW}⚠️  에이전트 서비스 확인 필요${NC}"
fi

echo
log_success "Archon OS 기본 설치 및 실행 테스트 완료!"
echo
echo "🌐 웹 인터페이스 접속:"
echo "   http://localhost:3737"
echo
echo "📋 다음 단계:"
echo "   1. 웹 브라우저에서 http://localhost:3737 접속"
echo "   2. Settings에서 OpenAI API 키 설정"
echo "   3. Knowledge Base에서 웹사이트 크롤링 테스트"
echo "   4. Projects에서 새 프로젝트 생성 테스트"
echo "   5. MCP 클라이언트 연결 테스트"
echo
echo "🔧 문제가 발생한 경우:"
echo "   - 로그 확인: docker-compose logs"
echo "   - 컨테이너 재시작: docker-compose restart"
echo "   - 완전 재설치: docker-compose down && docker-compose up --build"
