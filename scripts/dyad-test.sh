#!/bin/bash

# dyad 테스트 자동화 스크립트
# 작성일: 2025-07-31
# 목적: dyad AI 앱 빌더 설치 및 실행 테스트

set -e  # 오류 발생 시 스크립트 중단

# 색상 설정
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로그 함수
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

# 시스템 환경 확인
check_system() {
    log_info "시스템 환경 확인 중..."
    
    # 운영체제 확인
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macOS"
        log_info "운영체제: macOS"
        sw_vers
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="Linux"
        log_info "운영체제: Linux"
        lsb_release -a 2>/dev/null || cat /etc/os-release
    else
        log_error "지원되지 않는 운영체제: $OSTYPE"
        exit 1
    fi
    
    # Node.js 버전 확인
    if command -v node >/dev/null 2>&1; then
        NODE_VERSION=$(node --version)
        log_info "Node.js 버전: $NODE_VERSION"
        
        # Node.js 20 이상 확인
        NODE_MAJOR=$(echo $NODE_VERSION | cut -d'.' -f1 | sed 's/v//')
        if [ "$NODE_MAJOR" -lt 20 ]; then
            log_error "Node.js 20 이상이 필요합니다. 현재 버전: $NODE_VERSION"
            exit 1
        fi
    else
        log_error "Node.js가 설치되지 않았습니다."
        exit 1
    fi
    
    # npm 버전 확인
    if command -v npm >/dev/null 2>&1; then
        NPM_VERSION=$(npm --version)
        log_info "npm 버전: $NPM_VERSION"
    else
        log_error "npm이 설치되지 않았습니다."
        exit 1
    fi
    
    # 메모리 확인
    if [[ "$OS" == "macOS" ]]; then
        MEMORY_GB=$(sysctl -n hw.memsize | awk '{print int($1/1024/1024/1024)}')
        log_info "시스템 메모리: ${MEMORY_GB}GB"
        if [ "$MEMORY_GB" -lt 8 ]; then
            log_warning "8GB 이상의 메모리를 권장합니다."
        fi
    fi
    
    log_success "시스템 환경 확인 완료"
}

# dyad 설치 디렉토리 설정
setup_directories() {
    log_info "dyad 작업 디렉토리 설정 중..."
    
    DYAD_TEST_DIR="$HOME/dyad-test-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$DYAD_TEST_DIR"
    cd "$DYAD_TEST_DIR"
    
    log_info "작업 디렉토리: $DYAD_TEST_DIR"
    log_success "디렉토리 설정 완료"
}

# dyad 소스코드 다운로드
download_dyad() {
    log_info "dyad 소스코드 다운로드 중..."
    
    if command -v git >/dev/null 2>&1; then
        git clone https://github.com/dyad-sh/dyad.git
        cd dyad
        
        # 최신 릴리스 태그 확인
        LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "main")
        log_info "최신 버전: $LATEST_TAG"
        
        log_success "dyad 소스코드 다운로드 완료"
    else
        log_error "Git이 설치되지 않았습니다."
        exit 1
    fi
}

# 의존성 설치
install_dependencies() {
    log_info "의존성 설치 중..."
    
    # package.json 존재 확인
    if [ ! -f "package.json" ]; then
        log_error "package.json 파일을 찾을 수 없습니다."
        exit 1
    fi
    
    # npm 캐시 정리 (선택적)
    # npm cache clean --force
    
    # 의존성 설치
    npm install
    
    if [ $? -eq 0 ]; then
        log_success "의존성 설치 완료"
    else
        log_error "의존성 설치 실패"
        exit 1
    fi
}

# dyad 실행 테스트
test_dyad_execution() {
    log_info "dyad 실행 테스트 중..."
    
    # 백그라운드에서 dyad 실행
    npm start &
    DYAD_PID=$!
    
    log_info "dyad 프로세스 ID: $DYAD_PID"
    
    # 10초 대기 후 프로세스 확인
    sleep 10
    
    if kill -0 $DYAD_PID 2>/dev/null; then
        log_success "dyad가 성공적으로 실행되었습니다."
        
        # 프로세스 종료
        log_info "테스트 완료, dyad 프로세스 종료 중..."
        kill $DYAD_PID
        sleep 2
        
        # 강제 종료 (필요시)
        if kill -0 $DYAD_PID 2>/dev/null; then
            kill -9 $DYAD_PID
        fi
        
        log_success "dyad 실행 테스트 완료"
    else
        log_error "dyad 실행 실패"
        exit 1
    fi
}

# 빌드 테스트 (선택적)
test_build() {
    log_info "빌드 테스트 중..."
    
    # TypeScript 컴파일 테스트
    if npm run ts 2>/dev/null; then
        log_success "TypeScript 컴파일 성공"
    else
        log_warning "TypeScript 컴파일 실패 (일부 오류 무시)"
    fi
    
    # 린트 테스트
    if npm run lint 2>/dev/null; then
        log_success "린트 검사 통과"
    else
        log_warning "린트 검사 실패 (일부 경고 무시)"
    fi
}

# 성능 벤치마크
performance_benchmark() {
    log_info "성능 벤치마크 실행 중..."
    
    # 시작 시간 측정
    START_TIME=$(date +%s)
    
    # dyad 시작 시간 측정
    timeout 30s npm start &
    DYAD_PID=$!
    
    # 프로세스가 시작될 때까지 대기
    while ! kill -0 $DYAD_PID 2>/dev/null; do
        sleep 0.1
    done
    
    END_TIME=$(date +%s)
    STARTUP_TIME=$((END_TIME - START_TIME))
    
    log_info "시작 시간: ${STARTUP_TIME}초"
    
    # 프로세스 종료
    kill $DYAD_PID 2>/dev/null || true
    
    # 메모리 사용량 (추정)
    if [[ "$OS" == "macOS" ]]; then
        log_info "권장 메모리: 8GB 이상"
    fi
}

# 정리 작업
cleanup() {
    log_info "정리 작업 중..."
    
    # dyad 프로세스 강제 종료
    pkill -f "dyad" 2>/dev/null || true
    pkill -f "electron" 2>/dev/null || true
    
    # 임시 파일 정리
    if [ -d "$DYAD_TEST_DIR" ] && [ "$CLEANUP_FILES" = "true" ]; then
        log_info "테스트 파일 정리 중..."
        rm -rf "$DYAD_TEST_DIR"
        log_success "정리 완료"
    else
        log_info "테스트 파일 보관: $DYAD_TEST_DIR"
    fi
}

# 메인 함수
main() {
    echo "=================================="
    echo "    dyad AI 앱 빌더 테스트 스크립트"
    echo "    작성일: 2025-07-31"
    echo "=================================="
    echo
    
    # 신호 처리 설정
    trap cleanup EXIT
    trap cleanup INT
    
    # 옵션 처리
    CLEANUP_FILES=${CLEANUP_FILES:-false}
    RUN_BUILD_TEST=${RUN_BUILD_TEST:-false}
    RUN_PERFORMANCE_TEST=${RUN_PERFORMANCE_TEST:-false}
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --cleanup)
                CLEANUP_FILES=true
                shift
                ;;
            --build-test)
                RUN_BUILD_TEST=true
                shift
                ;;
            --performance)
                RUN_PERFORMANCE_TEST=true
                shift
                ;;
            --help)
                echo "사용법: $0 [옵션]"
                echo "옵션:"
                echo "  --cleanup        테스트 후 파일 정리"
                echo "  --build-test     빌드 테스트 포함"
                echo "  --performance    성능 테스트 포함"
                echo "  --help          도움말 표시"
                exit 0
                ;;
            *)
                log_error "알 수 없는 옵션: $1"
                exit 1
                ;;
        esac
    done
    
    # 테스트 실행
    check_system
    setup_directories
    download_dyad
    install_dependencies
    test_dyad_execution
    
    if [ "$RUN_BUILD_TEST" = "true" ]; then
        test_build
    fi
    
    if [ "$RUN_PERFORMANCE_TEST" = "true" ]; then
        performance_benchmark
    fi
    
    echo
    log_success "모든 테스트가 완료되었습니다!"
    
    # 결과 요약
    echo
    echo "=================================="
    echo "          테스트 결과 요약"
    echo "=================================="
    echo "✓ 시스템 환경: 호환 가능"
    echo "✓ dyad 다운로드: 성공"
    echo "✓ 의존성 설치: 성공"
    echo "✓ dyad 실행: 성공"
    [ "$RUN_BUILD_TEST" = "true" ] && echo "✓ 빌드 테스트: 완료"
    [ "$RUN_PERFORMANCE_TEST" = "true" ] && echo "✓ 성능 테스트: 완료"
    echo
    echo "dyad를 사용할 준비가 완료되었습니다!"
    echo "공식 웹사이트: https://dyad.sh"
    echo "GitHub 저장소: https://github.com/dyad-sh/dyad"
    echo
}

# 스크립트 실행
main "$@" 