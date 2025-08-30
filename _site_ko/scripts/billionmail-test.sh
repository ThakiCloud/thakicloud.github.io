#!/bin/bash

# BillionMail 튜토리얼 테스트 스크립트
# macOS Docker 환경 검증용

set -e

# 색상 코드
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 설정
PROJECT_NAME="billionmail"
TEST_DIR="$HOME/billionmail-test"
BASE_URL="http://localhost"

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

# 환경 준비
setup_test_environment() {
    log_info "🔧 테스트 환경 준비 중..."
    
    # 테스트 디렉토리 생성
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
    
    # BillionMail 클론 (이미 있으면 업데이트)
    if [ ! -d "BillionMail" ]; then
        log_info "📥 BillionMail 저장소 클론 중..."
        git clone https://github.com/aaPanel/BillionMail.git
    else
        log_info "📂 기존 BillionMail 디렉토리 사용"
    fi
    
    cd BillionMail
    
    # 환경 설정
    if [ ! -f ".env" ]; then
        cp env_init .env
        sed -i '' 's/BILLIONMAIL_HOSTNAME=.*/BILLIONMAIL_HOSTNAME=localhost/' .env
        log_success "✅ 환경 설정 파일 준비 완료"
    fi
}

# Docker 환경 확인
check_docker_environment() {
    log_info "🐳 Docker 환경 확인 중..."
    
    if ! command -v docker &> /dev/null; then
        log_error "❌ Docker가 설치되지 않았습니다"
        return 1
    fi
    
    if ! docker info &> /dev/null; then
        log_error "❌ Docker가 실행되지 않고 있습니다"
        return 1
    fi
    
    DOCKER_VERSION=$(docker --version | awk '{print $3}' | sed 's/,//')
    log_success "✅ Docker 설치됨: $DOCKER_VERSION"
}

# BillionMail 컨테이너 실행
start_billionmail() {
    log_info "🚀 BillionMail 컨테이너 시작 중..."
    
    cd "$TEST_DIR/BillionMail"
    
    # 기존 컨테이너 정리
    docker compose down --remove-orphans 2>/dev/null || true
    
    # 새 컨테이너 시작
    if docker compose up -d; then
        log_success "✅ BillionMail 컨테이너 시작됨"
    else
        log_error "❌ BillionMail 컨테이너 시작 실패"
        return 1
    fi
}

# 컨테이너 상태 확인
check_container_status() {
    log_info "📊 컨테이너 상태 확인 중..."
    
    cd "$TEST_DIR/BillionMail"
    
    # 컨테이너 목록 확인
    RUNNING_CONTAINERS=$(docker compose ps --services --filter "status=running" | wc -l)
    TOTAL_SERVICES=$(docker compose config --services | wc -l)
    
    log_info "실행 중인 컨테이너: $RUNNING_CONTAINERS/$TOTAL_SERVICES"
    
    # 개별 서비스 상태 확인
    docker compose ps --format "table {{.Service}}\t{{.Status}}\t{{.Ports}}"
    
    if [ "$RUNNING_CONTAINERS" -eq "$TOTAL_SERVICES" ]; then
        log_success "✅ 모든 서비스가 정상 실행 중"
    else
        log_warning "⚠️  일부 서비스가 실행되지 않음"
    fi
}

# 리소스 사용량 확인
check_resource_usage() {
    log_info "📈 리소스 사용량 확인 중..."
    
    # BillionMail 컨테이너만 필터링
    echo "=== BillionMail 컨테이너 리소스 사용량 ==="
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}" | grep billionmail
    
    # 총 메모리 사용량 계산
    TOTAL_MEM=$(docker stats --no-stream --format "{{.MemUsage}}" | grep -E "billionmail" | awk -F'/' '{print $1}' | sed 's/MiB//' | awk '{sum += $1} END {print sum}')
    
    if [ ! -z "$TOTAL_MEM" ]; then
        log_success "✅ 총 메모리 사용량: ${TOTAL_MEM}MB"
        
        if (( $(echo "$TOTAL_MEM < 1000" | bc -l) )); then
            log_success "🎯 메모리 효율성: 매우 우수 (1GB 미만)"
        elif (( $(echo "$TOTAL_MEM < 2000" | bc -l) )); then
            log_success "👍 메모리 효율성: 양호 (2GB 미만)"
        else
            log_warning "⚠️  메모리 사용량 높음 (2GB 이상)"
        fi
    fi
}

# 포트 접근성 테스트
test_port_accessibility() {
    log_info "🌐 포트 접근성 테스트 중..."
    
    # 주요 포트 목록
    declare -A PORTS=(
        ["80"]="HTTP"
        ["443"]="HTTPS"
        ["25"]="SMTP"
        ["587"]="SMTP Submission"
        ["993"]="IMAPS"
        ["143"]="IMAP"
    )
    
    for port in "${!PORTS[@]}"; do
        if lsof -i :$port &> /dev/null; then
            log_success "✅ 포트 $port (${PORTS[$port]}) 열림"
        else
            log_warning "⚠️  포트 $port (${PORTS[$port]}) 닫힘 또는 접근 불가"
        fi
    done
}

# 서비스 로그 확인
check_service_logs() {
    log_info "📋 서비스 로그 확인 중..."
    
    cd "$TEST_DIR/BillionMail"
    
    # Core 서비스 로그 (최근 10줄)
    echo "=== Core 서비스 로그 ==="
    docker compose logs --tail=10 core-billionmail | tail -5
    
    # Postfix 로그
    echo -e "\n=== Postfix 로그 ==="
    docker compose logs --tail=5 postfix-billionmail | tail -3
    
    # 에러 로그 확인
    ERROR_COUNT=$(docker compose logs | grep -i "error\|fail\|exception" | wc -l)
    if [ "$ERROR_COUNT" -gt 0 ]; then
        log_warning "⚠️  로그에서 $ERROR_COUNT 개의 에러/경고 발견"
    else
        log_success "✅ 심각한 에러 없음"
    fi
}

# 웹 인터페이스 접근 테스트
test_web_interface() {
    log_info "🌍 웹 인터페이스 접근 테스트 중..."
    
    # HTTP 연결 테스트
    local max_attempts=10
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if curl -f -s -m 5 "$BASE_URL" > /dev/null 2>&1; then
            log_success "✅ 웹 인터페이스 접근 가능: $BASE_URL"
            return 0
        fi
        
        attempt=$((attempt + 1))
        log_info "⏳ 시도 $attempt/$max_attempts - 3초 후 재시도..."
        sleep 3
    done
    
    log_warning "⚠️  웹 인터페이스 직접 접근 실패 (정상적인 경우일 수 있음)"
    log_info "💡 OrbStack 사용 시 다른 접근 방법이 필요할 수 있습니다"
}

# 기능별 검증
validate_features() {
    log_info "🔍 BillionMail 주요 기능 검증 중..."
    
    cd "$TEST_DIR/BillionMail"
    
    # 환경설정 파일 확인
    if [ -f ".env" ]; then
        log_success "✅ 환경설정 파일 존재"
    else
        log_error "❌ 환경설정 파일 없음"
    fi
    
    # Docker Compose 설정 확인
    if docker compose config &> /dev/null; then
        log_success "✅ Docker Compose 설정 유효"
    else
        log_error "❌ Docker Compose 설정 오류"
    fi
    
    # 데이터베이스 연결 확인
    if docker compose exec -T pgsql-billionmail pg_isready &> /dev/null; then
        log_success "✅ PostgreSQL 데이터베이스 연결 정상"
    else
        log_warning "⚠️  PostgreSQL 연결 확인 실패"
    fi
    
    # Redis 연결 확인
    if docker compose exec -T redis-billionmail redis-cli ping &> /dev/null; then
        log_success "✅ Redis 연결 정상"
    else
        log_warning "⚠️  Redis 연결 확인 실패"
    fi
}

# 정리 함수
cleanup_test_environment() {
    log_info "🧹 테스트 환경 정리 중..."
    
    cd "$TEST_DIR/BillionMail"
    
    if docker compose down; then
        log_success "✅ 컨테이너 정리 완료"
    else
        log_warning "⚠️  컨테이너 정리 중 오류 발생"
    fi
    
    # 이미지 정리 (선택사항)
    if [ "$1" = "--remove-images" ]; then
        log_info "🗑️  Docker 이미지 정리 중..."
        docker compose down --rmi all --volumes --remove-orphans
        log_success "✅ 이미지 정리 완료"
    fi
}

# 전체 테스트 실행
run_all_tests() {
    log_info "🚀 BillionMail 전체 테스트 시작..."
    echo
    
    # 1. 환경 준비
    setup_test_environment
    echo
    
    # 2. Docker 환경 확인
    check_docker_environment || return 1
    echo
    
    # 3. BillionMail 시작
    start_billionmail || return 1
    echo
    
    # 4. 컨테이너 상태 확인
    check_container_status
    echo
    
    # 5. 리소스 사용량 확인
    check_resource_usage
    echo
    
    # 6. 포트 접근성 테스트
    test_port_accessibility
    echo
    
    # 7. 기능별 검증
    validate_features
    echo
    
    # 8. 웹 인터페이스 테스트
    test_web_interface
    echo
    
    # 9. 서비스 로그 확인
    check_service_logs
    echo
    
    log_success "🎉 BillionMail 테스트 완료!"
    log_info "💡 테스트 디렉토리: $TEST_DIR"
    log_info "🌐 웹 인터페이스: $BASE_URL (환경에 따라 접근 방법 상이)"
}

# 사용법 표시
show_usage() {
    echo "BillionMail 테스트 스크립트"
    echo
    echo "사용법: $0 [옵션]"
    echo
    echo "옵션:"
    echo "  test      - 전체 테스트 실행"
    echo "  start     - BillionMail 시작만"
    echo "  status    - 컨테이너 상태 확인"
    echo "  resources - 리소스 사용량 확인"
    echo "  logs      - 서비스 로그 확인"
    echo "  cleanup   - 테스트 환경 정리"
    echo "  cleanup --remove-images - 이미지까지 정리"
    echo "  help      - 도움말 표시"
    echo
    echo "예시:"
    echo "  $0 test     # 전체 테스트 실행"
    echo "  $0 start    # BillionMail만 시작"
    echo "  $0 cleanup  # 정리"
}

# 메인 실행 로직
main() {
    case "${1:-test}" in
        "test")
            run_all_tests
            ;;
        "start")
            setup_test_environment
            check_docker_environment
            start_billionmail
            ;;
        "status")
            cd "$TEST_DIR/BillionMail"
            check_container_status
            ;;
        "resources")
            check_resource_usage
            ;;
        "logs")
            cd "$TEST_DIR/BillionMail"
            check_service_logs
            ;;
        "cleanup")
            cleanup_test_environment "$2"
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