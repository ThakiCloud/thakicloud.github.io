#!/bin/bash

# Onlook 튜토리얼 테스트 스크립트
# macOS 환경 검증용

set -e

# 색상 코드
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 설정
PROJECT_NAME="onlook"
TEST_DIR="$HOME/onlook-test"
WEB_PORT="8080"
CDN_PORT="8083"
TEMPLATE_PORT="8084"

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
    log_info "🔧 Onlook 테스트 환경 준비 중..."
    
    # 테스트 디렉토리 생성
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
    
    # Onlook 클론 (이미 있으면 업데이트)
    if [ ! -d "onlook" ]; then
        log_info "📥 Onlook 저장소 클론 중..."
        git clone https://github.com/onlook-dev/onlook.git
    else
        log_info "🔄 기존 Onlook 저장소 업데이트 중..."
        cd onlook
        git pull
        cd ..
    fi
    
    cd onlook
    log_success "✅ 환경 준비 완료"
}

# 의존성 설치
install_dependencies() {
    log_info "📦 의존성 설치 중..."
    
    # Bun 설치 확인
    if ! command -v bun &> /dev/null; then
        log_info "📥 Bun 설치 중..."
        curl -fsSL https://bun.sh/install | bash
        source ~/.zshrc
    fi
    
    # 프로젝트 의존성 설치
    log_info "🔨 프로젝트 의존성 설치 중..."
    bun install
    
    log_success "✅ 의존성 설치 완료"
}

# 개발 서버 시작
start_dev_server() {
    log_info "🚀 Onlook 개발 서버 시작 중..."
    
    # 백그라운드에서 개발 서버 시작
    timeout 60s bun dev > /tmp/onlook-dev.log 2>&1 &
    DEV_PID=$!
    
    # 서버 시작 대기
    log_info "⏳ 서버 시작 대기 중..."
    sleep 30
    
    echo $DEV_PID
}

# 헬스 체크
health_check() {
    log_info "🔍 Onlook 서비스 상태 확인 중..."
    
    local services_ok=0
    
    # Web Server 체크
    if curl -f -s http://localhost:$WEB_PORT > /dev/null 2>&1; then
        log_success "✅ Web Server (포트 $WEB_PORT) 정상 동작"
        ((services_ok++))
    else
        log_warning "⚠️ Web Server (포트 $WEB_PORT) 응답 없음"
    fi
    
    # CDN Server 체크
    if curl -f -s http://localhost:$CDN_PORT > /dev/null 2>&1; then
        log_success "✅ CDN Server (포트 $CDN_PORT) 정상 동작"
        ((services_ok++))
    else
        log_warning "⚠️ CDN Server (포트 $CDN_PORT) 응답 없음"
    fi
    
    # Template Server 체크
    if curl -f -s http://localhost:$TEMPLATE_PORT > /dev/null 2>&1; then
        log_success "✅ Template Server (포트 $TEMPLATE_PORT) 정상 동작"
        ((services_ok++))
    else
        log_warning "⚠️ Template Server (포트 $TEMPLATE_PORT) 응답 없음"
    fi
    
    if [ $services_ok -gt 0 ]; then
        log_success "🎉 총 $services_ok개 서비스가 정상 동작 중"
        return 0
    else
        log_error "❌ 모든 서비스 연결 실패"
        return 1
    fi
}

# 성능 테스트
performance_test() {
    log_info "📊 성능 테스트 실행 중..."
    
    # 응답 시간 측정
    local response_time=$(curl -o /dev/null -s -w '%{time_total}' http://localhost:$WEB_PORT)
    log_info "⚡ Web Server 응답 시간: ${response_time}초"
    
    # 메모리 사용량 확인
    if command -v ps &> /dev/null; then
        local memory_usage=$(ps aux | grep -E "bun|onlook" | grep -v grep | awk '{sum+=$6} END {print sum/1024}')
        if [ ! -z "$memory_usage" ]; then
            log_info "💾 총 메모리 사용량: ${memory_usage}MB"
        fi
    fi
    
    log_success "✅ 성능 테스트 완료"
}

# 정리 작업
cleanup() {
    log_info "🧹 정리 작업 중..."
    
    # 개발 서버 프로세스 종료
    if [ ! -z "$DEV_PID" ]; then
        kill $DEV_PID 2>/dev/null || true
    fi
    
    # 모든 관련 프로세스 종료
    pkill -f "bun.*onlook" 2>/dev/null || true
    pkill -f "node.*onlook" 2>/dev/null || true
    
    log_success "✅ 정리 완료"
}

# 백업 생성
backup_project() {
    log_info "💾 프로젝트 백업 생성 중..."
    
    local backup_dir="$HOME/onlook-backups"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    
    mkdir -p "$backup_dir"
    
    # 프로젝트 백업 (node_modules 제외)
    tar -czf "$backup_dir/onlook_backup_$timestamp.tar.gz" \
        --exclude="node_modules" \
        --exclude=".next" \
        --exclude="dist" \
        --exclude=".git" \
        -C "$TEST_DIR" onlook
    
    log_success "✅ 백업 생성: $backup_dir/onlook_backup_$timestamp.tar.gz"
}

# 시스템 정보 수집
system_info() {
    log_info "💻 시스템 정보 수집 중..."
    
    echo "=== 시스템 정보 ==="
    echo "운영체제: $(sw_vers -productName) $(sw_vers -productVersion)"
    echo "Node.js: $(node --version 2>/dev/null || echo 'Not installed')"
    echo "Bun: $(bun --version 2>/dev/null || echo 'Not installed')"
    echo "Git: $(git --version 2>/dev/null || echo 'Not installed')"
    echo "메모리: $(sysctl -n hw.memsize | awk '{print $1/1024/1024/1024 " GB"}')"
    echo "CPU: $(sysctl -n machdep.cpu.brand_string)"
    echo ""
}

# 메인 테스트 함수
run_test() {
    log_info "🎯 Onlook 종합 테스트 시작..."
    
    # Trap으로 정리 작업 보장
    trap cleanup EXIT
    
    system_info
    setup_test_environment
    install_dependencies
    
    local dev_pid=$(start_dev_server)
    DEV_PID=$dev_pid
    
    if health_check; then
        performance_test
        log_success "🎉 모든 테스트 통과!"
        return 0
    else
        log_error "❌ 테스트 실패"
        return 1
    fi
}

# 로그 확인
show_logs() {
    log_info "📋 개발 서버 로그 확인..."
    
    if [ -f "/tmp/onlook-dev.log" ]; then
        echo "=== 최근 로그 ==="
        tail -20 /tmp/onlook-dev.log
    else
        log_warning "로그 파일을 찾을 수 없습니다"
    fi
}

# 도움말 출력
show_help() {
    echo "Onlook 테스트 스크립트 사용법:"
    echo ""
    echo "명령어:"
    echo "  test        - 전체 테스트 실행"
    echo "  setup       - 환경 설정만 실행"
    echo "  health      - 헬스 체크만 실행"
    echo "  cleanup     - 정리 작업만 실행"
    echo "  backup      - 프로젝트 백업"
    echo "  logs        - 로그 확인"
    echo "  help        - 도움말 출력"
    echo ""
    echo "예시:"
    echo "  ./onlook-test.sh test"
    echo "  ./onlook-test.sh health"
    echo "  ./onlook-test.sh backup"
}

# 메인 로직
case "${1:-test}" in
    "test")
        run_test
        ;;
    "setup")
        setup_test_environment
        install_dependencies
        ;;
    "health")
        health_check
        ;;
    "performance")
        performance_test
        ;;
    "cleanup")
        cleanup
        ;;
    "backup")
        backup_project
        ;;
    "logs")
        show_logs
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        log_error "알 수 없는 명령어: $1"
        show_help
        exit 1
        ;;
esac 