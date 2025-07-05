#!/bin/bash

set -e

echo "🚀 GitHub Act 설치 및 테스트 스크립트"
echo "===================================="

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# 색깔 출력을 위한 변수
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# 1. 환경 확인
check_environment() {
    print_status "환경 확인 중..."
    
    # macOS 확인
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "이 스크립트는 macOS에서 실행되어야 합니다."
        exit 1
    fi
    
    print_success "macOS 환경 확인 완료"
    
    # Homebrew 확인
    if ! command -v brew &> /dev/null; then
        print_error "Homebrew가 설치되어 있지 않습니다."
        print_status "Homebrew 설치: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi
    
    print_success "Homebrew 확인 완료: $(brew --version | head -n 1)"
}

# 2. Docker 확인 및 설치
setup_docker() {
    print_status "Docker 환경 확인 중..."
    
    if ! command -v docker &> /dev/null; then
        print_warning "Docker가 설치되어 있지 않습니다."
        print_status "Docker Desktop 설치 중..."
        brew install --cask docker
        
        print_warning "Docker Desktop을 실행하고 다시 스크립트를 실행해주세요."
        exit 1
    fi
    
    # Docker 실행 상태 확인
    if ! docker ps &> /dev/null; then
        print_warning "Docker가 실행되고 있지 않습니다."
        print_status "Docker Desktop 시작 중..."
        open -a Docker
        
        # Docker가 시작될 때까지 대기
        print_status "Docker 시작을 기다리는 중..."
        local count=0
        while ! docker ps &> /dev/null && [ $count -lt 60 ]; do
            sleep 2
            ((count++))
            printf "."
        done
        echo ""
        
        if ! docker ps &> /dev/null; then
            print_error "Docker 시작에 실패했습니다. Docker Desktop을 수동으로 시작하고 다시 시도해주세요."
            exit 1
        fi
    fi
    
    print_success "Docker 확인 완료: $(docker --version)"
}

# 3. Act 설치
install_act() {
    print_status "Act 설치 확인 중..."
    
    if command -v act &> /dev/null; then
        print_success "Act가 이미 설치되어 있습니다: $(act --version)"
        return 0
    fi
    
    print_status "Act 설치 중..."
    brew install act
    
    if command -v act &> /dev/null; then
        print_success "Act 설치 완료: $(act --version)"
    else
        print_error "Act 설치에 실패했습니다."
        exit 1
    fi
}

# 4. Act 설정 파일 생성
setup_act_config() {
    print_status "Act 설정 파일 생성 중..."
    
    # .actrc 파일 생성
    cat > .actrc << 'EOF'
# Docker 이미지 설정 (macOS ARM64 호환)
-P ubuntu-latest=catthehacker/ubuntu:act-latest
-P ubuntu-22.04=catthehacker/ubuntu:act-22.04
-P ubuntu-20.04=catthehacker/ubuntu:act-20.04

# 환경 변수 파일 지정
--env-file .env.local

# 워크플로우 실행 옵션
--container-architecture linux/amd64
--verbose
--rm
EOF
    
    # 로컬 환경 변수 파일 생성
    if [[ ! -f .env.local ]]; then
        cat > .env.local << 'EOF'
# GitHub Actions 환경 변수
GITHUB_ACTIONS=true
RUNNER_OS=Linux
RUNNER_ARCH=X64
CI=true

# Jekyll 환경 변수
JEKYLL_ENV=development

# Node.js 환경 변수
NODE_ENV=development

# 기타
LANG=C.UTF-8
EOF
    fi
    
    print_success "Act 설정 파일 생성 완료"
}

# 5. 워크플로우 목록 확인
list_workflows() {
    print_status "사용 가능한 워크플로우 확인 중..."
    
    if [[ ! -d .github/workflows ]]; then
        print_error ".github/workflows 디렉토리가 존재하지 않습니다."
        return 1
    fi
    
    echo ""
    echo "📝 발견된 워크플로우 파일들:"
    find .github/workflows -name "*.yml" -o -name "*.yaml" | while read file; do
        echo "  - $file"
    done
    
    echo ""
    print_status "Act로 확인한 워크플로우 목록:"
    if act --list 2>/dev/null; then
        print_success "워크플로우 목록 확인 완료"
    else
        print_warning "워크플로우 목록을 가져올 수 없습니다. 워크플로우 파일에 문제가 있을 수 있습니다."
    fi
}

# 6. Docker 이미지 사전 다운로드
pull_docker_images() {
    print_status "필요한 Docker 이미지 다운로드 중..."
    
    # 자주 사용되는 이미지들 미리 다운로드
    images=(
        "catthehacker/ubuntu:act-latest"
        "catthehacker/ubuntu:act-22.04"
    )
    
    for image in "${images[@]}"; do
        print_status "이미지 다운로드: $image"
        if docker pull "$image" &> /dev/null; then
            print_success "다운로드 완료: $image"
        else
            print_warning "다운로드 실패: $image"
        fi
    done
}

# 7. 간단한 테스트 실행
run_test() {
    print_status "Act 테스트 실행 중..."
    
    echo ""
    echo "🧪 드라이런 테스트 (실제 실행하지 않음):"
    if act push --dryrun 2>/dev/null; then
        print_success "드라이런 테스트 성공"
    else
        print_warning "드라이런 테스트에서 경고가 있었습니다."
    fi
    
    echo ""
    echo "실제 워크플로우를 테스트하시겠습니까?"
    echo "주의: 실제 Docker 컨테이너가 실행되며 시간이 걸릴 수 있습니다."
    read -p "CI 워크플로우를 실행하시겠습니까? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "CI 워크플로우 실행 중... (이 작업은 몇 분 걸릴 수 있습니다)"
        
        # CI 워크플로우의 lint-test 잡만 실행
        if act push -j lint-test --verbose; then
            print_success "CI 테스트 성공!"
        else
            print_warning "CI 테스트에서 일부 문제가 발생했습니다."
        fi
    else
        print_status "실제 테스트를 건너뜁니다."
    fi
}

# 8. 사용법 안내
show_usage() {
    echo ""
    echo "🎉 Act 설치 및 설정 완료!"
    echo "=========================="
    echo ""
    echo "📚 기본 사용법:"
    echo "  act --list                    # 워크플로우 목록 확인"
    echo "  act push --dryrun            # Push 이벤트 드라이런"
    echo "  act push -j lint-test        # 특정 잡 실행"
    echo "  act workflow_dispatch        # 수동 워크플로우 실행"
    echo ""
    echo "🛠️  유용한 옵션:"
    echo "  --verbose                    # 상세 로그 출력"
    echo "  --dryrun                     # 실제 실행하지 않고 계획만 확인"
    echo "  --secret-file .secrets       # 비밀값 파일 사용"
    echo "  --env KEY=VALUE              # 환경 변수 추가"
    echo ""
    echo "📁 생성된 파일:"
    echo "  .actrc                       # Act 설정 파일"
    echo "  .env.local                   # 로컬 환경 변수"
    echo ""
    echo "🔧 zshrc에 추가할 수 있는 alias:"
    echo "  alias act-list='act --list'"
    echo "  alias act-ci='act push -j lint-test'"
    echo "  alias act-dry='act push --dryrun'"
    echo ""
}

# 메인 실행 함수
main() {
    echo "시작 시간: $(date)"
    echo ""
    
    check_environment
    setup_docker
    install_act
    setup_act_config
    pull_docker_images
    list_workflows
    run_test
    show_usage
    
    echo ""
    print_success "모든 설정이 완료되었습니다!"
    echo "종료 시간: $(date)"
}

# 스크립트 실행
main "$@" 