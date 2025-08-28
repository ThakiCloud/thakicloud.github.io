#!/bin/bash

set -e

echo "🚀 GitHub Act zshrc 별칭 설정 스크립트"
echo "====================================="

# 색깔 출력을 위한 변수
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
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

# zshrc 파일 확인
ZSHRC_FILE="$HOME/.zshrc"

if [ ! -f "$ZSHRC_FILE" ]; then
    print_warning ".zshrc 파일이 존재하지 않습니다. 생성 중..."
    touch "$ZSHRC_FILE"
fi

# Act 별칭이 이미 존재하는지 확인
if grep -q "# GitHub Act 별칭" "$ZSHRC_FILE"; then
    print_warning "Act 별칭이 이미 설정되어 있습니다."
    echo "기존 설정을 업데이트하시겠습니까? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "설정을 취소합니다."
        exit 0
    fi
    
    # 기존 Act 별칭 제거
    print_status "기존 Act 별칭 제거 중..."
    sed -i '' '/# GitHub Act 별칭/,/^$/d' "$ZSHRC_FILE"
fi

# Act 별칭 추가
print_status "Act 별칭 추가 중..."

cat >> "$ZSHRC_FILE" << 'EOF'

# GitHub Act 별칭
alias act-list='act --list'
alias act-dry='act push --dryrun'
alias act-ci='act push -j lint-test'
alias act-test='act workflow_dispatch -j simple-test'
alias act-verbose='act --verbose'
alias act-reuse='act --reuse'

# Act 함수들
act-job() {
    if [ -z "$1" ]; then
        echo "사용법: act-job <job-name>"
        act --list
        return 1
    fi
    act workflow_dispatch -j "$1"
}

act-workflow() {
    if [ -z "$1" ]; then
        echo "사용법: act-workflow <workflow-file>"
        find .github/workflows -name "*.yml" -exec basename {} \;
        return 1
    fi
    act -W ".github/workflows/$1"
}

# Act 개발 워크플로우 별칭들
alias act-quick='act push --dryrun -j lint-test'  # 빠른 린트 테스트
alias act-full='act push'                         # 전체 CI 실행
alias act-local='act workflow_dispatch -j simple-test'  # 로컬 테스트
alias act-prod='act push --env JEKYLL_ENV=production'   # 프로덕션 시뮬레이션

EOF

print_success "Act 별칭이 성공적으로 추가되었습니다!"

echo ""
print_status "추가된 별칭들:"
echo "  act-list      : 사용 가능한 워크플로우 목록"
echo "  act-dry       : Push 이벤트 드라이런"
echo "  act-ci        : CI 린트 테스트 실행"
echo "  act-test      : 간단한 로컬 테스트"
echo "  act-verbose   : 상세 로그와 함께 실행"
echo "  act-reuse     : 기존 컨테이너 재사용"
echo "  act-quick     : 빠른 린트 테스트"
echo "  act-full      : 전체 CI 파이프라인"
echo "  act-local     : 로컬 테스트 실행"
echo "  act-prod      : 프로덕션 환경 시뮬레이션"

echo ""
print_status "추가된 함수들:"
echo "  act-job <name>      : 특정 잡 실행"
echo "  act-workflow <file> : 특정 워크플로우 파일 실행"

echo ""
print_warning "새로운 별칭을 사용하려면 다음 명령어를 실행하세요:"
echo "  source ~/.zshrc"

echo ""
print_success "설정 완료! 🎉" 