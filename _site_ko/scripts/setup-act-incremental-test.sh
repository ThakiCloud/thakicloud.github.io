#!/bin/bash

# GitHub Actions 로컬 테스트를 위한 act 설정 스크립트
# macOS용 증분 빌드 테스트 환경 구축

set -e

echo "🚀 GitHub Actions 로컬 테스트 환경 설정 시작..."

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 함수 정의
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

# 1. act 설치 확인 및 설치
print_status "act 설치 상태 확인 중..."

if ! command -v act &> /dev/null; then
    print_warning "act가 설치되어 있지 않습니다. 설치를 진행합니다..."
    
    if command -v brew &> /dev/null; then
        print_status "Homebrew를 사용하여 act 설치 중..."
        brew install act
    else
        print_error "Homebrew가 설치되어 있지 않습니다. 먼저 Homebrew를 설치해주세요."
        echo "설치 명령어: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi
else
    print_success "act가 이미 설치되어 있습니다. ($(act --version))"
fi

# 2. Docker 설치 확인
print_status "Docker 설치 상태 확인 중..."

if ! command -v docker &> /dev/null; then
    print_error "Docker가 설치되어 있지 않습니다."
    echo "Docker Desktop for Mac을 설치해주세요: https://www.docker.com/products/docker-desktop"
    exit 1
else
    if ! docker info &> /dev/null; then
        print_error "Docker가 실행되고 있지 않습니다. Docker Desktop을 시작해주세요."
        exit 1
    fi
    print_success "Docker가 정상적으로 실행 중입니다."
fi

# 3. act 설정 파일 생성
print_status "act 설정 파일 생성 중..."

# .actrc 파일 생성 (act 기본 설정)
cat > .actrc << 'EOF'
# act 기본 설정
--container-architecture linux/amd64
--platform ubuntu-latest=catthehacker/ubuntu:act-latest
--platform ubuntu-22.04=catthehacker/ubuntu:act-22.04
--platform ubuntu-20.04=catthehacker/ubuntu:act-20.04
EOF

# secrets 파일 생성 (필요한 경우)
if [ ! -f .secrets ]; then
    cat > .secrets << 'EOF'
# GitHub Actions secrets for local testing
# GITHUB_TOKEN=your_github_token_here
EOF
    print_warning ".secrets 파일이 생성되었습니다. 필요한 경우 토큰을 추가하세요."
fi

# 4. 테스트용 환경 변수 파일 생성
cat > .env.act << 'EOF'
# Act 로컬 테스트용 환경 변수
JEKYLL_ENV=production
GITHUB_REPOSITORY=thakicloud/thakicloud.github.io
GITHUB_REF=refs/heads/main
GITHUB_SHA=test-commit-sha
GITHUB_RUN_NUMBER=999
EOF

print_success "act 설정 파일들이 생성되었습니다."

# 5. 테스트 스크립트 생성
print_status "테스트 스크립트 생성 중..."

# 증분 빌드 테스트 스크립트
cat > scripts/test-incremental-build.sh << 'EOF'
#!/bin/bash

# 증분 빌드 워크플로우 로컬 테스트 스크립트

set -e

echo "🧪 증분 빌드 워크플로우 로컬 테스트 시작..."

# 색상 정의
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

# 1. 변경 감지 job만 테스트
print_status "변경 감지 job 테스트 중..."
act -j detect-changes \
    --workflows .github/workflows/incremental-build.yml \
    --env-file .env.act \
    --verbose

print_success "변경 감지 job 테스트 완료"

# 2. 전체 워크플로우 테스트 (dry-run)
print_warning "전체 워크플로우 dry-run 테스트..."
act -n \
    --workflows .github/workflows/incremental-build.yml \
    --env-file .env.act

print_success "전체 워크플로우 구조 검증 완료"

echo ""
echo "🎉 모든 테스트가 완료되었습니다!"
echo ""
echo "📋 다음 명령어로 개별 테스트를 실행할 수 있습니다:"
echo "  - 변경 감지만: act -j detect-changes --workflows .github/workflows/incremental-build.yml"
echo "  - 빌드만: act -j incremental-build --workflows .github/workflows/incremental-build.yml"
echo "  - 전체 워크플로우: act --workflows .github/workflows/incremental-build.yml"
echo ""
EOF

chmod +x scripts/test-incremental-build.sh

# 빠른 테스트 스크립트
cat > scripts/quick-test-changes.sh << 'EOF'
#!/bin/bash

# 변경사항 빠른 테스트 스크립트

set -e

echo "⚡ 변경사항 빠른 테스트..."

# 최근 변경된 파일 확인
echo "📝 최근 변경된 파일들:"
git diff --name-only HEAD~1 HEAD | head -10

echo ""
echo "🔍 변경 감지 job만 실행..."

# 변경 감지 job만 빠르게 테스트
act -j detect-changes \
    --workflows .github/workflows/incremental-build.yml \
    --env-file .env.act \
    --quiet

echo ""
echo "✅ 빠른 테스트 완료!"
EOF

chmod +x scripts/quick-test-changes.sh

print_success "테스트 스크립트가 생성되었습니다."

# 6. zshrc alias 추가
print_status "zshrc alias 설정 중..."

ALIAS_CONTENT='
# GitHub Actions 로컬 테스트 aliases
alias act-test="act --workflows .github/workflows/incremental-build.yml --env-file .env.act"
alias act-detect="act -j detect-changes --workflows .github/workflows/incremental-build.yml --env-file .env.act"
alias act-build="act -j incremental-build --workflows .github/workflows/incremental-build.yml --env-file .env.act"
alias act-quick="./scripts/quick-test-changes.sh"
alias act-full="./scripts/test-incremental-build.sh"
alias act-dry="act -n --workflows .github/workflows/incremental-build.yml --env-file .env.act"
'

# .zshrc에 alias가 이미 있는지 확인
if ! grep -q "# GitHub Actions 로컬 테스트 aliases" ~/.zshrc 2>/dev/null; then
    echo "$ALIAS_CONTENT" >> ~/.zshrc
    print_success "zshrc에 alias가 추가되었습니다."
    print_warning "새 터미널을 열거나 'source ~/.zshrc'를 실행하여 alias를 활성화하세요."
else
    print_warning "zshrc에 이미 alias가 설정되어 있습니다."
fi

# 7. 첫 테스트 실행
print_status "초기 테스트 실행 중..."

echo ""
echo "🧪 변경 감지 기능 테스트..."
if act -j detect-changes \
    --workflows .github/workflows/incremental-build.yml \
    --env-file .env.act \
    --quiet; then
    print_success "초기 테스트가 성공적으로 완료되었습니다!"
else
    print_warning "초기 테스트에서 일부 오류가 발생했지만 설정은 완료되었습니다."
fi

# 8. 사용법 안내
echo ""
echo "🎉 GitHub Actions 로컬 테스트 환경 설정이 완료되었습니다!"
echo ""
echo "📋 사용 가능한 명령어:"
echo "  act-quick  : 빠른 변경사항 테스트"
echo "  act-detect : 변경 감지 job만 테스트"
echo "  act-build  : 빌드 job만 테스트"
echo "  act-test   : 전체 워크플로우 테스트"
echo "  act-dry    : 워크플로우 구조 검증 (실행 안함)"
echo "  act-full   : 전체 테스트 스크립트 실행"
echo ""
echo "📁 생성된 파일들:"
echo "  .actrc                          : act 기본 설정"
echo "  .env.act                        : 테스트용 환경 변수"
echo "  .secrets                        : GitHub secrets (필요시 편집)"
echo "  scripts/test-incremental-build.sh : 전체 테스트 스크립트"
echo "  scripts/quick-test-changes.sh   : 빠른 테스트 스크립트"
echo ""
echo "🚀 이제 'act-quick' 명령어로 빠른 테스트를 시작해보세요!"
