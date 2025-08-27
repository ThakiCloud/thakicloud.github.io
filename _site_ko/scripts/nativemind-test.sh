#!/bin/bash

# NativeMind 튜토리얼 테스트 스크립트
# macOS 환경 검증용

set -e

# 색상 코드
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 설정
PROJECT_NAME="nativemind"
TEST_DIR="$HOME/nativemind-test"
OLLAMA_PORT="11434"
EXTENSION_VERSION="1.5.3"

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

# 시스템 정보 수집
system_info() {
    log_info "💻 시스템 정보 수집 중..."
    
    echo "=== NativeMind 테스트 환경 ==="
    echo "운영체제: $(sw_vers -productName) $(sw_vers -productVersion)"
    echo "CPU: $(sysctl -n machdep.cpu.brand_string)"
    echo "메모리: $(sysctl -n hw.memsize | awk '{print $1/1024/1024/1024 " GB"}')"
    echo "Ollama: $(ollama --version 2>/dev/null || echo 'Not installed')"
    echo "Chrome: $(google-chrome --version 2>/dev/null || echo 'Not detected')"
    echo ""
}

# Ollama 환경 확인
check_ollama_environment() {
    log_info "🦙 Ollama 환경 확인 중..."
    
    # Ollama 설치 확인
    if ! command -v ollama &> /dev/null; then
        log_warning "⚠️ Ollama가 설치되지 않았습니다"
        echo "설치 방법: brew install ollama"
        return 1
    fi
    
    # Ollama 서비스 확인
    if ! pgrep -x "ollama" > /dev/null; then
        log_warning "⚠️ Ollama 서비스가 실행되지 않았습니다"
        log_info "🚀 Ollama 서비스 시작 중..."
        ollama serve > /tmp/ollama.log 2>&1 &
        sleep 5
    fi
    
    # API 연결 테스트
    if curl -f -s http://localhost:$OLLAMA_PORT/api/tags > /dev/null; then
        log_success "✅ Ollama API 정상 접근 (포트 $OLLAMA_PORT)"
    else
        log_error "❌ Ollama API 접근 실패"
        return 1
    fi
    
    # 설치된 모델 확인
    local model_count=$(curl -s http://localhost:$OLLAMA_PORT/api/tags | python3 -c "import sys, json; print(len(json.load(sys.stdin)['models']))" 2>/dev/null || echo "0")
    log_info "📦 설치된 AI 모델: $model_count 개"
    
    if [ "$model_count" -eq 0 ]; then
        log_warning "⚠️ 설치된 모델이 없습니다"
        echo "권장 모델 설치: ollama pull qwen3:4b"
    else
        log_success "✅ Ollama 환경 정상"
    fi
}

# 확장 프로그램 다운로드
download_extension() {
    log_info "📥 NativeMind 확장 프로그램 다운로드 중..."
    
    # 테스트 디렉토리 생성
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
    
    # 이미 다운로드되어 있는지 확인
    if [ -f "manifest.json" ]; then
        log_success "✅ 확장 프로그램이 이미 준비되어 있습니다"
        return 0
    fi
    
    # 최신 릴리스 URL 가져오기
    local download_url=$(curl -s https://api.github.com/repos/NativeMindBrowser/NativeMindExtension/releases/latest | grep "browser_download_url.*chrome.*zip" | cut -d '"' -f 4)
    
    if [ -z "$download_url" ]; then
        log_error "❌ 다운로드 URL을 찾을 수 없습니다"
        return 1
    fi
    
    # 파일 다운로드
    log_info "🔗 다운로드 URL: $download_url"
    if curl -L -o "nativemind-extension.zip" "$download_url"; then
        log_success "✅ 다운로드 완료 ($(du -h nativemind-extension.zip | awk '{print $1}'))"
    else
        log_error "❌ 다운로드 실패"
        return 1
    fi
    
    # 압축 해제
    if unzip -q nativemind-extension.zip; then
        log_success "✅ 압축 해제 완료"
        rm nativemind-extension.zip
    else
        log_error "❌ 압축 해제 실패"
        return 1
    fi
}

# 확장 프로그램 구조 분석
analyze_extension() {
    log_info "🔍 확장 프로그램 구조 분석 중..."
    
    cd "$TEST_DIR"
    
    if [ ! -f "manifest.json" ]; then
        log_error "❌ manifest.json을 찾을 수 없습니다"
        return 1
    fi
    
    # 매니페스트 정보 출력
    local version=$(cat manifest.json | python3 -c "import sys, json; print(json.load(sys.stdin)['version'])" 2>/dev/null || echo "unknown")
    local permissions=$(cat manifest.json | python3 -c "import sys, json; print(len(json.load(sys.stdin)['permissions']))" 2>/dev/null || echo "unknown")
    
    log_info "📋 확장 프로그램 정보:"
    echo "  버전: $version"
    echo "  권한 수: $permissions 개"
    echo "  크기: $(du -sh . | awk '{print $1}')"
    
    # 주요 파일 확인
    local files_ok=0
    
    for file in "manifest.json" "background.js" "popup.html"; do
        if [ -f "$file" ]; then
            echo "  ✅ $file"
            ((files_ok++))
        else
            echo "  ❌ $file (누락)"
        fi
    done
    
    if [ $files_ok -eq 3 ]; then
        log_success "✅ 확장 프로그램 구조 정상"
        return 0
    else
        log_warning "⚠️ 일부 파일이 누락되었습니다"
        return 1
    fi
}

# 성능 테스트
performance_test() {
    log_info "📊 성능 테스트 실행 중..."
    
    # Ollama API 응답 시간 측정
    local response_time=$(curl -o /dev/null -s -w '%{time_total}' http://localhost:$OLLAMA_PORT/api/tags)
    log_info "⚡ Ollama API 응답 시간: ${response_time}초"
    
    # 시스템 리소스 확인
    local memory_usage=$(ps aux | grep -E "ollama" | grep -v grep | awk '{sum+=$6} END {print sum/1024}' 2>/dev/null || echo "0")
    if [ "${memory_usage%.*}" -gt 0 ]; then
        log_info "💾 Ollama 메모리 사용량: ${memory_usage}MB"
    fi
    
    # 확장 프로그램 크기 정보
    local extension_size=$(du -sh "$TEST_DIR" | awk '{print $1}')
    log_info "📦 확장 프로그램 크기: $extension_size"
    
    log_success "✅ 성능 테스트 완료"
}

# 설치 가이드 출력
installation_guide() {
    log_info "📖 Chrome 확장 프로그램 설치 가이드"
    
    echo ""
    echo "=== NativeMind 설치 방법 ==="
    echo "1. Chrome 브라우저에서 chrome://extensions/ 접속"
    echo "2. 우상단 '개발자 모드' 토글 활성화"
    echo "3. '압축해제된 확장 프로그램을 로드합니다' 클릭"
    echo "4. 다음 폴더 선택: $TEST_DIR"
    echo "5. NativeMind 아이콘이 툴바에 나타나는지 확인"
    echo ""
    echo "=== Ollama 모델 설치 (권장) ==="
    echo "ollama pull qwen3:4b      # 균형잡힌 성능"
    echo "ollama pull gemma3:4b     # 이미지 인식 특화"
    echo "ollama pull phi4:mini     # 빠른 응답"
    echo ""
}

# 정리 작업
cleanup() {
    log_info "🧹 정리 작업 중..."
    
    # Ollama 프로세스는 유지 (사용자가 직접 제어)
    log_info "ℹ️ Ollama 서비스는 계속 실행됩니다"
    log_info "ℹ️ 중지하려면: pkill ollama"
    
    log_success "✅ 정리 완료"
}

# 백업 생성
backup_extension() {
    log_info "💾 확장 프로그램 백업 생성 중..."
    
    local backup_dir="$HOME/nativemind-backups"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    
    mkdir -p "$backup_dir"
    
    if [ -d "$TEST_DIR" ]; then
        tar -czf "$backup_dir/nativemind_backup_$timestamp.tar.gz" -C "$HOME" "nativemind-test"
        log_success "✅ 백업 생성: $backup_dir/nativemind_backup_$timestamp.tar.gz"
    else
        log_warning "⚠️ 백업할 확장 프로그램을 찾을 수 없습니다"
    fi
}

# Ollama 모델 관리
manage_models() {
    log_info "🤖 Ollama 모델 관리"
    
    case "${2:-list}" in
        "install")
            log_info "📦 권장 모델 설치 중..."
            ollama pull qwen3:4b
            ollama pull phi4:mini
            log_success "✅ 모델 설치 완료"
            ;;
        "list")
            log_info "📋 설치된 모델 목록:"
            ollama list
            ;;
        "clean")
            log_warning "⚠️ 모든 모델을 삭제하시겠습니까? (y/N)"
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                ollama list | awk 'NR>1 {print $1}' | xargs -I {} ollama rm {}
                log_success "✅ 모델 정리 완료"
            fi
            ;;
        *)
            echo "사용법: $0 models [install|list|clean]"
            ;;
    esac
}

# 메인 테스트 함수
run_test() {
    log_info "🧠 NativeMind 종합 테스트 시작..."
    
    # Trap으로 정리 작업 보장
    trap cleanup EXIT
    
    system_info
    
    if check_ollama_environment && download_extension && analyze_extension; then
        performance_test
        installation_guide
        log_success "🎉 모든 테스트 통과!"
        return 0
    else
        log_error "❌ 테스트 실패"
        return 1
    fi
}

# 도움말 출력
show_help() {
    echo "NativeMind 테스트 스크립트 사용법:"
    echo ""
    echo "명령어:"
    echo "  test        - 전체 테스트 실행"
    echo "  download    - 확장 프로그램 다운로드만"
    echo "  analyze     - 확장 프로그램 분석만"
    echo "  ollama      - Ollama 환경 확인만"
    echo "  models      - 모델 관리 [install|list|clean]"
    echo "  backup      - 확장 프로그램 백업"
    echo "  cleanup     - 정리 작업"
    echo "  help        - 도움말 출력"
    echo ""
    echo "예시:"
    echo "  ./nativemind-test.sh test"
    echo "  ./nativemind-test.sh models install"
    echo "  ./nativemind-test.sh backup"
}

# 메인 로직
case "${1:-test}" in
    "test")
        run_test
        ;;
    "download")
        download_extension
        ;;
    "analyze")
        analyze_extension
        ;;
    "ollama")
        system_info
        check_ollama_environment
        ;;
    "models")
        manage_models "$@"
        ;;
    "performance")
        performance_test
        ;;
    "backup")
        backup_extension
        ;;
    "cleanup")
        cleanup
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