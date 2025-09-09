#!/bin/bash

# Bytebot AI Desktop Agent 설정 테스트 스크립트
# macOS용 Docker 환경에서 Bytebot 설치 및 테스트

set -e

echo "🤖 Bytebot AI Desktop Agent 설정 테스트 시작..."
echo "=================================================="

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로그 함수들
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

# 시스템 요구사항 확인
check_requirements() {
    log_info "시스템 요구사항 확인 중..."
    
    # macOS 확인
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_error "이 스크립트는 macOS에서만 실행됩니다."
        exit 1
    fi
    log_success "macOS 환경 확인됨"
    
    # Docker 설치 확인
    if ! command -v docker &> /dev/null; then
        log_error "Docker가 설치되지 않았습니다. Docker Desktop을 설치해주세요."
        echo "다운로드 링크: https://www.docker.com/products/docker-desktop"
        exit 1
    fi
    log_success "Docker 설치 확인됨 ($(docker --version))"
    
    # Docker Compose 확인
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose가 설치되지 않았습니다."
        exit 1
    fi
    log_success "Docker Compose 설치 확인됨 ($(docker-compose --version))"
    
    # Docker 데몬 실행 확인
    if ! docker info &> /dev/null; then
        log_error "Docker 데몬이 실행되지 않았습니다. Docker Desktop을 시작해주세요."
        exit 1
    fi
    log_success "Docker 데몬 실행 중"
    
    # 메모리 확인
    total_memory=$(system_profiler SPHardwareDataType | grep "Memory:" | awk '{print $2}')
    if [[ "${total_memory%% *}" -lt 8 ]]; then
        log_warning "권장 메모리는 8GB 이상입니다. 현재: $total_memory"
    else
        log_success "메모리 확인됨: $total_memory"
    fi
}

# 테스트 디렉토리 생성
setup_test_environment() {
    log_info "테스트 환경 설정 중..."
    
    TEST_DIR="/tmp/bytebot-test-$(date +%s)"
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
    
    log_success "테스트 디렉토리 생성: $TEST_DIR"
}

# Bytebot 저장소 클론
clone_bytebot() {
    log_info "Bytebot 저장소 클론 중..."
    
    if git clone https://github.com/bytebot-ai/bytebot.git; then
        log_success "Bytebot 저장소 클론 완료"
        cd bytebot/docker
    else
        log_error "저장소 클론 실패"
        exit 1
    fi
}

# 환경 변수 설정 (테스트용 가짜 키)
setup_env() {
    log_info "환경 변수 설정 중..."
    
    # 사용자에게 실제 API 키 사용 여부 확인
    echo
    echo -e "${YELLOW}실제 AI API 키를 사용하시겠습니까?${NC}"
    echo "1) 예 (실제 Anthropic/OpenAI 키 입력)"
    echo "2) 아니오 (테스트용 가짜 키 사용 - 실행 실패 예상)"
    read -p "선택하세요 (1 또는 2): " choice
    
    case $choice in
        1)
            echo -e "${BLUE}사용할 AI 프로바이더를 선택하세요:${NC}"
            echo "1) Anthropic Claude (권장)"
            echo "2) OpenAI GPT"
            echo "3) Google Gemini"
            read -p "선택하세요 (1, 2, 또는 3): " provider_choice
            
            case $provider_choice in
                1)
                    read -p "Anthropic API 키를 입력하세요: " api_key
                    echo "ANTHROPIC_API_KEY=$api_key" > .env
                    log_success "Anthropic API 키 설정 완료"
                    ;;
                2)
                    read -p "OpenAI API 키를 입력하세요: " api_key
                    echo "OPENAI_API_KEY=$api_key" > .env
                    log_success "OpenAI API 키 설정 완료"
                    ;;
                3)
                    read -p "Google Gemini API 키를 입력하세요: " api_key
                    echo "GEMINI_API_KEY=$api_key" > .env
                    log_success "Google Gemini API 키 설정 완료"
                    ;;
                *)
                    log_error "잘못된 선택입니다."
                    exit 1
                    ;;
            esac
            ;;
        2)
            echo "ANTHROPIC_API_KEY=test-key-for-demo" > .env
            log_warning "테스트용 가짜 키 설정 (실제 AI 기능은 작동하지 않음)"
            ;;
        *)
            log_error "잘못된 선택입니다."
            exit 1
            ;;
    esac
}

# Docker 이미지 다운로드 및 서비스 시작
start_bytebot() {
    log_info "Bytebot 서비스 시작 중... (이 과정은 몇 분 소요될 수 있습니다)"
    
    # Docker 이미지 풀링
    log_info "Docker 이미지 다운로드 중..."
    if docker-compose pull; then
        log_success "Docker 이미지 다운로드 완료"
    else
        log_warning "일부 이미지 다운로드 실패 (빌드 시 자동 해결)"
    fi
    
    # 서비스 시작
    log_info "서비스 시작 중..."
    if docker-compose up -d; then
        log_success "Bytebot 서비스 시작 완료"
    else
        log_error "서비스 시작 실패"
        exit 1
    fi
    
    # 서비스 상태 확인
    sleep 10
    log_info "서비스 상태 확인 중..."
    docker-compose ps
}

# 서비스 헬스 체크
health_check() {
    log_info "서비스 헬스 체크 수행 중..."
    
    # 최대 60초 대기
    max_attempts=12
    attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        log_info "헬스 체크 시도 $((attempt + 1))/$max_attempts..."
        
        # 메인 UI 확인
        if curl -s http://localhost:9992 > /dev/null; then
            log_success "메인 UI (포트 9992) 응답 확인"
            break
        fi
        
        attempt=$((attempt + 1))
        if [ $attempt -lt $max_attempts ]; then
            log_info "5초 후 재시도..."
            sleep 5
        fi
    done
    
    if [ $attempt -eq $max_attempts ]; then
        log_error "서비스 헬스 체크 실패"
        log_info "컨테이너 로그 확인:"
        docker-compose logs --tail=20
        return 1
    fi
    
    # API 헬스 체크
    if curl -s http://localhost:9991/health > /dev/null 2>&1; then
        log_success "API 서비스 (포트 9991) 응답 확인"
    else
        log_warning "API 서비스 응답 없음 (아직 초기화 중일 수 있음)"
    fi
}

# 기본 기능 테스트
test_basic_functionality() {
    log_info "기본 기능 테스트 수행 중..."
    
    # 스크린샷 API 테스트
    log_info "스크린샷 API 테스트..."
    if curl -s -X POST http://localhost:9990/computer-use \
        -H "Content-Type: application/json" \
        -d '{"action": "screenshot"}' > /dev/null; then
        log_success "스크린샷 API 테스트 성공"
    else
        log_warning "스크린샷 API 테스트 실패 (초기화 진행 중일 수 있음)"
    fi
    
    # 간단한 작업 생성 테스트
    log_info "작업 생성 API 테스트..."
    response=$(curl -s -X POST http://localhost:9991/tasks \
        -H "Content-Type: application/json" \
        -d '{"description": "Take a screenshot of the desktop"}' 2>/dev/null || echo "")
    
    if [[ "$response" == *"id"* ]]; then
        log_success "작업 생성 API 테스트 성공"
    else
        log_warning "작업 생성 API 테스트 실패 (API 키 또는 초기화 문제일 수 있음)"
    fi
}

# 성능 모니터링
monitor_performance() {
    log_info "성능 모니터링..."
    
    echo
    echo "=== Docker 컨테이너 리소스 사용량 ==="
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"
    
    echo
    echo "=== 시스템 메모리 사용량 ==="
    vm_stat | grep -E "(free|active|inactive|wired)" | awk '{print $3, $0}'
    
    echo
    echo "=== 포트 사용 현황 ==="
    netstat -an | grep -E "(9990|9991|9992)" | head -5
}

# 사용법 안내
show_usage_guide() {
    echo
    echo "🎉 Bytebot 설정 및 테스트 완료!"
    echo "=================================="
    echo
    echo -e "${GREEN}접속 URL:${NC}"
    echo "  • 메인 UI: http://localhost:9992"
    echo "  • API 문서: http://localhost:9991/docs"
    echo "  • 컴퓨터 사용 API: http://localhost:9990"
    echo
    echo -e "${BLUE}다음 단계:${NC}"
    echo "  1. 웹 브라우저에서 http://localhost:9992 방문"
    echo "  2. 'Desktop' 탭에서 가상 데스크톱 확인"
    echo "  3. 'Tasks' 탭에서 간단한 작업 생성 테스트"
    echo
    echo -e "${BLUE}예시 작업:${NC}"
    echo "  • \"Take a screenshot of the desktop\""
    echo "  • \"Open Firefox and search for 'AI tutorials'\""
    echo "  • \"Create a new text file with current date\""
    echo
    echo -e "${YELLOW}중지 방법:${NC}"
    echo "  docker-compose down"
    echo
    echo -e "${YELLOW}로그 확인:${NC}"
    echo "  docker-compose logs -f"
}

# 정리 함수
cleanup() {
    log_info "테스트 환경 정리 중..."
    
    if [ -n "$TEST_DIR" ] && [ -d "$TEST_DIR" ]; then
        cd /tmp
        read -p "테스트 디렉토리를 삭제하시겠습니까? ($TEST_DIR) [y/N]: " delete_choice
        if [[ "$delete_choice" =~ ^[Yy]$ ]]; then
            rm -rf "$TEST_DIR"
            log_success "테스트 디렉토리 삭제 완료"
        else
            log_info "테스트 디렉토리 유지: $TEST_DIR"
        fi
    fi
}

# 에러 핸들링
handle_error() {
    log_error "스크립트 실행 중 오류가 발생했습니다."
    echo
    echo "=== 문제 해결 가이드 ==="
    echo "1. Docker Desktop이 실행 중인지 확인"
    echo "2. 충분한 메모리 (8GB+)가 있는지 확인"
    echo "3. 포트 9990-9992가 사용 중이지 않은지 확인"
    echo "4. 인터넷 연결이 안정적인지 확인"
    echo
    echo "=== 컨테이너 상태 확인 ==="
    if command -v docker-compose &> /dev/null; then
        docker-compose ps 2>/dev/null || true
        echo
        echo "=== 최근 로그 ==="
        docker-compose logs --tail=10 2>/dev/null || true
    fi
    
    cleanup
    exit 1
}

# 메인 함수
main() {
    # 에러 트랩 설정
    trap handle_error ERR
    
    echo "🤖 Bytebot AI Desktop Agent - macOS 테스트 스크립트"
    echo "이 스크립트는 Bytebot을 설치하고 기본 기능을 테스트합니다."
    echo
    
    # 실행 확인
    read -p "계속하시겠습니까? [y/N]: " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log_info "사용자가 테스트를 취소했습니다."
        exit 0
    fi
    
    # 테스트 단계 실행
    check_requirements
    setup_test_environment
    clone_bytebot
    setup_env
    start_bytebot
    
    if health_check; then
        test_basic_functionality
        monitor_performance
        show_usage_guide
        
        echo
        read -p "테스트가 완료되었습니다. 서비스를 중지하시겠습니까? [y/N]: " stop_choice
        if [[ "$stop_choice" =~ ^[Yy]$ ]]; then
            log_info "서비스 중지 중..."
            docker-compose down
            log_success "서비스 중지 완료"
        else
            log_info "서비스가 계속 실행됩니다."
        fi
    else
        log_error "헬스 체크 실패"
        handle_error
    fi
    
    cleanup
    log_success "테스트 완료!"
}

# 스크립트 실행
main "$@"
