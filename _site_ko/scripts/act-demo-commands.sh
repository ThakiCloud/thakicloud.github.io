#!/bin/bash

set -e

echo "🚀 GitHub Act 데모 명령어 모음"
echo "==============================="

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# 색깔 출력을 위한 변수
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_section() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_command() {
    echo -e "\n${YELLOW}💻 명령어:${NC} $1"
    echo -e "${YELLOW}📋 설명:${NC} $2\n"
}

# 1. 기본 명령어들
print_section "📋 1. 기본 명령어들"

print_command "act --list" "워크플로우 목록 확인"
act --list

print_command "act --help" "사용 가능한 모든 옵션 확인"
echo "실제 실행하려면: act --help"

print_command "act --detect-event" "워크플로우에서 첫 번째 이벤트 자동 감지"
echo "실제 실행하려면: act --detect-event"

# 2. 특정 워크플로우 실행
print_section "🎯 2. 특정 워크플로우 실행"

print_command "act workflow_dispatch -j simple-test --dryrun" "특정 잡 드라이런 모드"
act workflow_dispatch -j simple-test --dryrun

print_command "act -W .github/workflows/act-test.yml" "특정 워크플로우 파일 실행"
echo "실제 실행하려면: act -W .github/workflows/act-test.yml"

# 3. 환경 변수 및 시크릿 테스트
print_section "🔐 3. 환경 변수 및 시크릿"

print_command "act --env MY_VAR=test_value" "환경 변수 주입"
echo "사용 예시: act workflow_dispatch -j simple-test --env CUSTOM_ENV=production"

print_command "act --secret-file .secrets" "시크릿 파일 사용"
cat > .secrets << 'EOF'
GITHUB_TOKEN=ghp_example_token_here
MY_SECRET=secret_value
EOF
echo "시크릿 파일 생성됨: .secrets"

# 4. 이벤트 시뮬레이션
print_section "📨 4. 다양한 이벤트 시뮬레이션"

print_command "act push" "Push 이벤트 시뮬레이션"
echo "실제 실행하려면: act push -j lint-test"

print_command "act pull_request" "Pull Request 이벤트 시뮬레이션"
echo "실제 실행하려면: act pull_request"

print_command "act workflow_dispatch" "수동 워크플로우 트리거"
echo "실제 실행하려면: act workflow_dispatch -j simple-test"

# 5. 디버깅 옵션들
print_section "🔍 5. 디버깅 및 문제 해결"

print_command "act --verbose" "상세 로그 출력"
print_command "act --dryrun" "실제 실행하지 않고 계획만 확인"
print_command "act --reuse" "기존 컨테이너 재사용 (빠른 테스트)"
print_command "act --rm=false" "테스트 후 컨테이너 유지 (디버깅용)"

# 6. 고급 사용법
print_section "⚡ 6. 고급 사용법"

print_command "act --platform ubuntu-latest=catthehacker/ubuntu:act-22.04" "사용자 정의 Docker 이미지"
print_command "act --artifact-server-path /tmp/artifacts" "아티팩트 저장 경로 지정"
print_command "act --container-architecture linux/amd64" "특정 아키텍처 지정"

# 7. 실용적인 개발 워크플로우
print_section "🛠️ 7. 실용적인 개발 워크플로우"

echo -e "${GREEN}📝 추천 개발 워크플로우:${NC}"
echo "1. 코드 변경 후 빠른 테스트:"
echo "   act push -j lint-test --dryrun"
echo ""
echo "2. 로컬에서 전체 CI 실행:"
echo "   act push"
echo ""
echo "3. 특정 워크플로우만 테스트:"
echo "   act workflow_dispatch -j simple-test"
echo ""
echo "4. 프로덕션 환경 시뮬레이션:"
echo "   act push --env JEKYLL_ENV=production"
echo ""

# 8. zshrc 별칭 추가 제안
print_section "🔧 8. 편의성을 위한 zshrc 별칭"

echo "다음 내용을 ~/.zshrc에 추가하세요:"
cat << 'EOF'

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

EOF

echo -e "\n${GREEN}✅ 데모 명령어 시연 완료!${NC}"
echo -e "${GREEN}이제 'source ~/.zshrc' 명령어로 별칭을 활성화하세요.${NC}"

# 정리
rm -f .secrets 