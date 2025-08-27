#!/bin/bash

# Prompt Optimizer 테스트 스크립트
# 튜토리얼 검증용

set -e

# 색상 코드
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 설정
CONTAINER_NAME="prompt-optimizer-test"
PORT="8081"
BASE_URL="http://localhost:$PORT"

# 로깅 함수
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 헬스 체크 함수
health_check() {
    log_info "🔍 Prompt Optimizer 상태 확인 중..."
    
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if curl -f -s $BASE_URL > /dev/null 2>&1; then
            log_success "✅ 서비스가 정상 동작 중입니다: $BASE_URL"
            return 0
        fi
        
        attempt=$((attempt + 1))
        log_info "⏳ 시도 $attempt/$max_attempts - 2초 후 재시도..."
        sleep 2
    done
    
    log_error "❌ 서비스 연결 실패: $BASE_URL"
    return 1
}

# Docker 컨테이너 상태 확인
check_docker_status() {
    log_info "🐳 Docker 컨테이너 상태 확인..."
    
    if docker ps | grep -q $CONTAINER_NAME; then
        log_success "✅ 컨테이너가 실행 중입니다"
        docker ps | grep $CONTAINER_NAME | head -1
    else
        log_error "❌ 컨테이너가 실행되지 않고 있습니다"
        return 1
    fi
}

# 리소스 사용량 체크
check_resource_usage() {
    log_info "📊 리소스 사용량 체크..."
    
    if docker stats $CONTAINER_NAME --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}" 2>/dev/null; then
        log_success "✅ 리소스 사용량 확인 완료"
    else
        log_warning "⚠️  리소스 사용량을 확인할 수 없습니다"
    fi
}

# 응답 시간 테스트
test_response_time() {
    log_info "⏱️  응답 시간 테스트..."
    
    local response_time=$(curl -w "%{time_total}" -s -o /dev/null $BASE_URL 2>/dev/null)
    if [ $? -eq 0 ]; then
        log_success "✅ 응답 시간: ${response_time}초"
        
        # 1초 이내면 Good, 3초 이내면 OK, 그 이상이면 Slow
        if (( $(echo "$response_time < 1.0" | bc -l) )); then
            log_success "🚀 응답 속도: 매우 빠름"
        elif (( $(echo "$response_time < 3.0" | bc -l) )); then
            log_success "👍 응답 속도: 양호"
        else
            log_warning "🐌 응답 속도: 느림 (최적화 필요)"
        fi
    else
        log_error "❌ 응답 시간 측정 실패"
        return 1
    fi
}

# API 엔드포인트 테스트
test_api_endpoints() {
    log_info "🌐 API 엔드포인트 테스트..."
    
    # 기본 HTML 페이지 테스트
    if curl -f -s $BASE_URL | grep -q "Prompt Optimizer" 2>/dev/null; then
        log_success "✅ 메인 페이지 로드 성공"
    else
        log_warning "⚠️  메인 페이지에서 'Prompt Optimizer' 텍스트를 찾을 수 없습니다"
    fi
    
    # MCP 엔드포인트 테스트 (존재하는지만 확인)
    local mcp_status=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/mcp 2>/dev/null)
    if [ "$mcp_status" != "000" ]; then
        log_success "✅ MCP 엔드포인트 접근 가능 (HTTP $mcp_status)"
    else
        log_warning "⚠️  MCP 엔드포인트 테스트 실패"
    fi
}

# 컨테이너 로그 확인
check_container_logs() {
    log_info "📋 컨테이너 로그 확인..."
    
    local log_output=$(docker logs $CONTAINER_NAME --tail 10 2>&1)
    if [ $? -eq 0 ]; then
        log_success "✅ 최근 로그 (최근 10줄):"
        echo "$log_output" | sed 's/^/    /'
    else
        log_error "❌ 로그 확인 실패"
    fi
}

# 정리 함수
cleanup() {
    log_info "🧹 테스트 환경 정리..."
    
    if docker ps | grep -q $CONTAINER_NAME; then
        docker stop $CONTAINER_NAME > /dev/null 2>&1
        log_success "✅ 컨테이너 중지됨"
    fi
    
    if docker ps -a | grep -q $CONTAINER_NAME; then
        docker rm $CONTAINER_NAME > /dev/null 2>&1
        log_success "✅ 컨테이너 제거됨"
    fi
}

# 전체 테스트 실행
run_all_tests() {
    log_info "🚀 Prompt Optimizer 전체 테스트 시작..."
    echo
    
    # 1. Docker 상태 확인
    check_docker_status || return 1
    echo
    
    # 2. 헬스 체크
    health_check || return 1
    echo
    
    # 3. API 엔드포인트 테스트
    test_api_endpoints
    echo
    
    # 4. 응답 시간 테스트
    test_response_time
    echo
    
    # 5. 리소스 사용량 체크
    check_resource_usage
    echo
    
    # 6. 컨테이너 로그 확인
    check_container_logs
    echo
    
    log_success "🎉 모든 테스트 완료!"
    log_info "💡 브라우저에서 $BASE_URL 를 열어 직접 테스트해보세요"
}

# 사용법 표시
show_usage() {
    echo "Prompt Optimizer 테스트 스크립트"
    echo
    echo "사용법: $0 [옵션]"
    echo
    echo "옵션:"
    echo "  test      - 전체 테스트 실행"
    echo "  health    - 헬스 체크만 실행"
    echo "  status    - 컨테이너 상태 확인"
    echo "  logs      - 컨테이너 로그 확인"
    echo "  cleanup   - 테스트 환경 정리"
    echo "  help      - 도움말 표시"
    echo
    echo "예시:"
    echo "  $0 test     # 전체 테스트 실행"
    echo "  $0 health   # 헬스 체크만 실행"
    echo "  $0 cleanup  # 정리"
}

# 메인 실행 로직
main() {
    case "${1:-test}" in
        "test")
            run_all_tests
            ;;
        "health")
            health_check
            ;;
        "status")
            check_docker_status
            ;;
        "logs")
            check_container_logs
            ;;
        "cleanup")
            cleanup
            ;;
        "help"|"-h"|"--help")
            show_usage
            ;;
        *)
            log_error "알 수 없는 옵션: $1"
            show_usage
            exit 1
            ;;
    esac
}

# 스크립트 실행
main "$@" 