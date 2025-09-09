#!/bin/bash

# opcode 설치 및 빌드 테스트 스크립트 (macOS 전용)
# 작성자: Thaki Cloud
# 버전: 1.0
# 날짜: 2025-09-09

set -e  # 오류 발생 시 스크립트 중단

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

# 진행 상황 표시
show_progress() {
    local step=$1
    local total=$2
    local message=$3
    echo -e "${BLUE}[${step}/${total}]${NC} ${message}"
}

# 시스템 확인
check_system() {
    show_progress 1 8 "시스템 요구사항 확인 중..."
    
    # macOS 확인
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_error "이 스크립트는 macOS 전용입니다."
        exit 1
    fi
    
    log_success "macOS 시스템 확인됨"
    
    # 시스템 정보 표시
    log_info "시스템 정보:"
    echo "  - OS: $(sw_vers -productName) $(sw_vers -productVersion)"
    echo "  - 아키텍처: $(uname -m)"
    echo "  - 메모리: $(sysctl -n hw.memsize | awk '{print int($1/1024/1024/1024)"GB"}')"
}

# 필수 도구 확인
check_dependencies() {
    show_progress 2 8 "필수 도구 확인 중..."
    
    local missing_tools=()
    
    # Git 확인
    if ! command -v git &> /dev/null; then
        missing_tools+=("git")
    else
        log_success "Git 설치됨: $(git --version)"
    fi
    
    # Xcode Command Line Tools 확인
    if ! xcode-select -p &> /dev/null; then
        log_warning "Xcode Command Line Tools가 설치되지 않음"
        log_info "Xcode Command Line Tools 설치 중..."
        xcode-select --install
        log_info "설치 완료 후 스크립트를 다시 실행하세요."
        exit 1
    else
        log_success "Xcode Command Line Tools 설치됨"
    fi
    
    # Rust 확인
    if ! command -v rustc &> /dev/null; then
        missing_tools+=("rust")
    else
        log_success "Rust 설치됨: $(rustc --version)"
    fi
    
    # Cargo 확인
    if ! command -v cargo &> /dev/null; then
        missing_tools+=("cargo")
    else
        log_success "Cargo 설치됨: $(cargo --version)"
    fi
    
    # Bun 확인
    if ! command -v bun &> /dev/null; then
        missing_tools+=("bun")
    else
        log_success "Bun 설치됨: $(bun --version)"
    fi
    
    # Claude CLI 확인
    if ! command -v claude &> /dev/null; then
        missing_tools+=("claude")
    else
        log_success "Claude CLI 설치됨: $(claude --version 2>/dev/null || echo 'Version check failed')"
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        log_error "다음 도구들이 누락되었습니다: ${missing_tools[*]}"
        echo ""
        echo "설치 방법:"
        for tool in "${missing_tools[@]}"; do
            case $tool in
                "git")
                    echo "  Git: brew install git"
                    ;;
                "rust"|"cargo")
                    echo "  Rust: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
                    ;;
                "bun")
                    echo "  Bun: curl -fsSL https://bun.sh/install | bash"
                    ;;
                "claude")
                    echo "  Claude CLI: https://claude.ai/ 에서 다운로드"
                    ;;
            esac
        done
        exit 1
    fi
}

# Homebrew 의존성 설치
install_homebrew_deps() {
    show_progress 3 8 "Homebrew 의존성 확인 중..."
    
    if ! command -v brew &> /dev/null; then
        log_warning "Homebrew가 설치되지 않음"
        log_info "Homebrew 설치 중..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        log_success "Homebrew 설치됨: $(brew --version | head -n1)"
    fi
    
    # pkg-config 설치 (선택사항이지만 권장)
    if ! brew list pkg-config &> /dev/null; then
        log_info "pkg-config 설치 중..."
        brew install pkg-config
    else
        log_success "pkg-config 이미 설치됨"
    fi
}

# opcode 저장소 클론
clone_opcode() {
    show_progress 4 8 "opcode 저장소 클론 중..."
    
    local clone_dir="$HOME/opcode-test"
    
    # 기존 디렉토리 제거
    if [ -d "$clone_dir" ]; then
        log_warning "기존 테스트 디렉토리 제거 중..."
        rm -rf "$clone_dir"
    fi
    
    # 저장소 클론
    log_info "opcode 저장소 클론 중..."
    git clone https://github.com/getAsterisk/opcode.git "$clone_dir"
    
    if [ $? -eq 0 ]; then
        log_success "저장소 클론 완료: $clone_dir"
        echo "export OPCODE_TEST_DIR=\"$clone_dir\"" >> ~/.zshrc
    else
        log_error "저장소 클론 실패"
        exit 1
    fi
    
    cd "$clone_dir"
}

# 의존성 설치
install_dependencies() {
    show_progress 5 8 "프론트엔드 의존성 설치 중..."
    
    log_info "bun install 실행 중..."
    if bun install; then
        log_success "의존성 설치 완료"
    else
        log_error "의존성 설치 실패"
        exit 1
    fi
}

# 개발 빌드 테스트
test_dev_build() {
    show_progress 6 8 "개발 빌드 테스트 중..."
    
    log_info "개발 서버 시작 테스트 (10초 후 자동 종료)..."
    
    # 백그라운드에서 개발 서버 시작
    timeout 10 bun run tauri dev &
    local dev_pid=$!
    
    # 10초 대기
    sleep 10
    
    # 프로세스가 여전히 실행 중인지 확인
    if kill -0 $dev_pid 2>/dev/null; then
        log_success "개발 서버가 정상적으로 시작됨"
        kill $dev_pid 2>/dev/null
    else
        log_warning "개발 서버 시작에 문제가 있을 수 있음"
    fi
}

# 프로덕션 빌드 테스트
test_production_build() {
    show_progress 7 8 "프로덕션 빌드 테스트 중..."
    
    log_info "프로덕션 빌드 시작 (시간이 걸릴 수 있습니다)..."
    
    if bun run tauri build; then
        log_success "프로덕션 빌드 완료"
        
        # 빌드 결과 확인
        local app_path="src-tauri/target/release/opcode"
        if [ -f "$app_path" ]; then
            log_success "실행 파일 생성됨: $app_path"
            
            # 파일 정보 표시
            local file_size=$(du -h "$app_path" | cut -f1)
            log_info "실행 파일 크기: $file_size"
            
            # 실행 권한 확인
            if [ -x "$app_path" ]; then
                log_success "실행 파일이 실행 가능함"
            else
                log_warning "실행 권한이 없음"
                chmod +x "$app_path"
                log_info "실행 권한 추가됨"
            fi
        else
            log_error "실행 파일을 찾을 수 없음"
        fi
        
        # macOS 앱 번들 확인
        local app_bundle="src-tauri/target/release/bundle/macos/opcode.app"
        if [ -d "$app_bundle" ]; then
            log_success "macOS 앱 번들 생성됨: $app_bundle"
        fi
        
    else
        log_error "프로덕션 빌드 실패"
        exit 1
    fi
}

# 설치 후 확인
post_install_check() {
    show_progress 8 8 "설치 후 확인 중..."
    
    log_info "빌드 아티팩트 확인 중..."
    
    # 빌드 디렉토리 구조 표시
    if [ -d "src-tauri/target/release" ]; then
        log_info "빌드 결과물:"
        find src-tauri/target/release -name "opcode*" -type f -exec ls -lh {} \;
    fi
    
    # 사용 가능한 명령어 추가
    local zshrc_additions="
# opcode 관련 alias 추가
alias opcode-dev='cd \$OPCODE_TEST_DIR && bun run tauri dev'
alias opcode-build='cd \$OPCODE_TEST_DIR && bun run tauri build'
alias opcode-run='cd \$OPCODE_TEST_DIR && ./src-tauri/target/release/opcode'
alias opcode-dir='cd \$OPCODE_TEST_DIR'
"
    
    echo "$zshrc_additions" >> ~/.zshrc
    log_success "유용한 alias가 ~/.zshrc에 추가됨"
    
    # Claude CLI 연결 테스트 (선택사항)
    if command -v claude &> /dev/null; then
        log_info "Claude CLI 연결 테스트 중..."
        if claude --version &> /dev/null; then
            log_success "Claude CLI가 정상적으로 작동함"
        else
            log_warning "Claude CLI 연결에 문제가 있을 수 있음"
        fi
    fi
}

# 정리 함수
cleanup() {
    log_info "정리 작업 중..."
    # 필요시 임시 파일 정리
}

# 메인 실행 함수
main() {
    echo "================================================================"
    echo "              opcode 설치 및 빌드 테스트 스크립트"
    echo "================================================================"
    echo ""
    
    # 트랩 설정 (스크립트 종료 시 정리)
    trap cleanup EXIT
    
    # 시작 시간 기록
    local start_time=$(date +%s)
    
    # 모든 단계 실행
    check_system
    check_dependencies
    install_homebrew_deps
    clone_opcode
    install_dependencies
    test_dev_build
    test_production_build
    post_install_check
    
    # 완료 시간 계산
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    echo ""
    echo "================================================================"
    log_success "opcode 설치 및 빌드 테스트 완료!"
    echo "================================================================"
    echo ""
    log_info "소요 시간: ${duration}초"
    echo ""
    echo "다음 명령어를 사용할 수 있습니다:"
    echo "  opcode-dev    : 개발 서버 시작"
    echo "  opcode-build  : 프로덕션 빌드"
    echo "  opcode-run    : 빌드된 앱 실행"
    echo "  opcode-dir    : opcode 디렉토리로 이동"
    echo ""
    echo "변경사항을 적용하려면 새 터미널을 열거나 다음을 실행하세요:"
    echo "  source ~/.zshrc"
    echo ""
    log_info "opcode 사용법은 블로그 포스트를 참조하세요!"
}

# 스크립트 실행
main "$@"
