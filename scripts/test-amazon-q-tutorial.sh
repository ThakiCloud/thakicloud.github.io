#!/bin/bash

# Amazon Q Developer CLI 튜토리얼 테스트 스크립트
# macOS 환경에서 실행 가능한 자동화된 설정 및 테스트

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

# 시스템 요구사항 확인
check_system_requirements() {
    log_info "시스템 요구사항 확인 중..."
    
    # macOS 버전 확인
    if [[ "$(uname)" != "Darwin" ]]; then
        log_error "이 스크립트는 macOS에서만 실행됩니다."
        exit 1
    fi
    
    macos_version=$(sw_vers -productVersion)
    log_info "macOS 버전: $macos_version"
    
    # Homebrew 설치 확인
    if ! command -v brew &> /dev/null; then
        log_warning "Homebrew가 설치되지 않았습니다. 설치를 진행합니다..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        log_success "Homebrew가 이미 설치되어 있습니다."
        brew --version
    fi
}

# Amazon Q CLI 설치 함수
install_amazon_q() {
    log_info "Amazon Q Developer CLI 설치 시작..."
    
    # 기존 설치 확인
    if command -v q &> /dev/null; then
        log_warning "Amazon Q가 이미 설치되어 있습니다."
        q --version
        return 0
    fi
    
    # Homebrew로 설치 시도
    if brew install amazon-q; then
        log_success "Amazon Q Developer CLI가 Homebrew를 통해 성공적으로 설치되었습니다."
    else
        log_error "Homebrew 설치에 실패했습니다. 대안 방법을 시도합니다..."
        install_amazon_q_manual
    fi
}

# 수동 설치 함수 (Homebrew 실패 시)
install_amazon_q_manual() {
    log_info "수동 설치 방법을 시도합니다..."
    
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # 공식 웹사이트에서 다운로드 (실제 URL은 확인 필요)
    log_info "Amazon Q DMG 파일 다운로드 중..."
    curl -L -o amazon-q.dmg "https://aws.amazon.com/q/developer/cli/download" || {
        log_error "다운로드에 실패했습니다. 수동으로 설치해 주세요."
        cd ~
        rm -rf "$TEMP_DIR"
        return 1
    }
    
    # DMG 마운트 및 설치
    log_info "DMG 파일 마운트 및 설치 중..."
    hdiutil mount amazon-q.dmg
    cp -R "/Volumes/Amazon Q/Amazon Q.app" /Applications/
    hdiutil unmount "/Volumes/Amazon Q"
    
    # 정리
    cd ~
    rm -rf "$TEMP_DIR"
    
    log_success "Amazon Q가 수동으로 설치되었습니다."
}

# 셸 통합 설정
setup_shell_integration() {
    log_info "셸 통합 설정 중..."
    
    # 현재 셸 확인
    current_shell=$(basename "$SHELL")
    log_info "현재 셸: $current_shell"
    
    case $current_shell in
        "zsh")
            setup_zsh_integration
            ;;
        "bash")
            setup_bash_integration
            ;;
        "fish")
            setup_fish_integration
            ;;
        *)
            log_warning "지원되지 않는 셸입니다: $current_shell"
            ;;
    esac
}

# Zsh 통합 설정
setup_zsh_integration() {
    log_info "Zsh 통합 설정 중..."
    
    # .zshrc 백업
    if [[ -f ~/.zshrc ]]; then
        cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
        log_info ".zshrc 백업이 생성되었습니다."
    fi
    
    # Amazon Q 초기화 추가
    if ! grep -q 'eval "$(q init zsh)"' ~/.zshrc; then
        echo 'eval "$(q init zsh)"' >> ~/.zshrc
        log_success "Zsh에 Amazon Q 통합이 추가되었습니다."
    else
        log_info "Zsh 통합이 이미 설정되어 있습니다."
    fi
}

# Bash 통합 설정
setup_bash_integration() {
    log_info "Bash 통합 설정 중..."
    
    # .bash_profile 또는 .bashrc 확인
    if [[ -f ~/.bash_profile ]]; then
        profile_file=~/.bash_profile
    else
        profile_file=~/.bashrc
    fi
    
    # 백업 생성
    if [[ -f "$profile_file" ]]; then
        cp "$profile_file" "${profile_file}.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "프로필 파일 백업이 생성되었습니다."
    fi
    
    # Amazon Q 초기화 추가
    if ! grep -q 'eval "$(q init bash)"' "$profile_file"; then
        echo 'eval "$(q init bash)"' >> "$profile_file"
        log_success "Bash에 Amazon Q 통합이 추가되었습니다."
    else
        log_info "Bash 통합이 이미 설정되어 있습니다."
    fi
}

# Fish 통합 설정
setup_fish_integration() {
    log_info "Fish 통합 설정 중..."
    
    # Fish 설정 디렉토리 생성
    mkdir -p ~/.config/fish
    
    # 백업 생성
    if [[ -f ~/.config/fish/config.fish ]]; then
        cp ~/.config/fish/config.fish ~/.config/fish/config.fish.backup.$(date +%Y%m%d_%H%M%S)
        log_info "Fish 설정 파일 백업이 생성되었습니다."
    fi
    
    # Amazon Q 초기화 추가
    if ! grep -q 'q init fish | source' ~/.config/fish/config.fish; then
        echo 'q init fish | source' >> ~/.config/fish/config.fish
        log_success "Fish에 Amazon Q 통합이 추가되었습니다."
    else
        log_info "Fish 통합이 이미 설정되어 있습니다."
    fi
}

# 권한 확인 및 안내
check_permissions() {
    log_info "필요한 권한 확인 중..."
    
    log_warning "다음 권한들을 수동으로 설정해야 합니다:"
    echo "1. 시스템 환경설정 → 보안 및 개인정보보호 → 개인정보보호 → 접근성"
    echo "   - Amazon Q 추가 및 활성화"
    echo ""
    echo "2. 시스템 환경설정 → 보안 및 개인정보보호 → 개인정보보호 → 입력 모니터링"
    echo "   - Amazon Q 추가 및 활성화"
    echo ""
    
    read -p "권한 설정을 완료하셨나요? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_warning "권한 설정 후 다시 실행해 주세요."
        return 1
    fi
}

# Amazon Q 설정 테스트
test_amazon_q_setup() {
    log_info "Amazon Q 설정 테스트 중..."
    
    # q 명령어 사용 가능 여부 확인
    if ! command -v q &> /dev/null; then
        log_error "q 명령어를 찾을 수 없습니다. 설치를 다시 확인해 주세요."
        return 1
    fi
    
    # Amazon Q doctor 실행
    log_info "Amazon Q doctor 실행 중..."
    if q doctor; then
        log_success "Amazon Q가 올바르게 설정되었습니다."
    else
        log_warning "Amazon Q 설정에 문제가 있을 수 있습니다."
    fi
}

# 자동완성 기능 테스트
test_autocomplete_features() {
    log_info "자동완성 기능 테스트 중..."
    
    # 테스트할 명령어들
    test_commands=("git" "npm" "docker" "aws")
    
    for cmd in "${test_commands[@]}"; do
        if command -v "$cmd" &> /dev/null; then
            log_info "$cmd 명령어에 대한 자동완성 스펙 확인 중..."
            # 실제 자동완성 테스트는 대화형이므로 여기서는 명령어 존재 여부만 확인
            log_success "$cmd 명령어가 사용 가능합니다."
        else
            log_warning "$cmd 명령어가 설치되지 않았습니다."
        fi
    done
}

# 성능 최적화 설정
optimize_performance() {
    log_info "Amazon Q 성능 최적화 설정 적용 중..."
    
    # 기본 성능 설정 적용
    q config set suggestion-delay 100
    q config set max-suggestions 10
    q config set theme auto
    
    log_success "성능 최적화 설정이 적용되었습니다."
}

# 사용법 안내
show_usage_guide() {
    log_info "Amazon Q Developer CLI 사용법 안내"
    echo ""
    echo "=== 기본 사용법 ==="
    echo "1. 터미널에서 명령어를 입력하기 시작합니다"
    echo "2. Tab 키를 눌러 자동완성 제안을 확인합니다"
    echo "3. 화살표 키로 제안을 탐색하고 Enter로 선택합니다"
    echo ""
    echo "=== 유용한 명령어 ==="
    echo "• q doctor          : 설정 상태 진단"
    echo "• q config          : 설정 관리"
    echo "• q cache clear     : 캐시 지우기"
    echo "• q --help          : 도움말 보기"
    echo ""
    echo "=== 테스트해 볼 명령어들 ==="
    echo "• git <Tab>         : Git 명령어 자동완성"
    echo "• npm <Tab>         : NPM 명령어 자동완성"
    echo "• docker <Tab>      : Docker 명령어 자동완성"
    echo ""
}

# 정리 함수
cleanup_on_error() {
    log_error "설치 중 오류가 발생했습니다."
    log_info "다음 사항을 확인해 주세요:"
    echo "1. 인터넷 연결 상태"
    echo "2. 관리자 권한"
    echo "3. 시스템 요구사항"
    echo ""
    echo "문제가 지속되면 수동 설치를 시도해 주세요:"
    echo "https://aws.amazon.com/q/developer/cli/"
}

# 메인 함수
main() {
    echo "========================================"
    echo "Amazon Q Developer CLI 설치 및 설정 스크립트"
    echo "========================================"
    echo ""
    
    # 트랩 설정 (오류 발생 시 정리)
    trap cleanup_on_error ERR
    
    # 단계별 실행
    check_system_requirements
    install_amazon_q
    setup_shell_integration
    check_permissions
    test_amazon_q_setup
    test_autocomplete_features
    optimize_performance
    show_usage_guide
    
    echo ""
    echo "========================================"
    log_success "Amazon Q Developer CLI 설정이 완료되었습니다!"
    echo "========================================"
    echo ""
    log_info "새 터미널 창을 열고 자동완성 기능을 테스트해 보세요."
    log_info "예: 'git ' 입력 후 Tab 키를 눌러보세요."
}

# 스크립트 실행
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
