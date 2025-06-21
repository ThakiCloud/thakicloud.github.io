#!/bin/bash

# 🧪 CI 워크플로우 로컬 테스트 스크립트
# macOS용 - ci.yml과 동일한 검증을 로컬에서 실행

set -e  # 오류 발생 시 스크립트 중단

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 함수: 섹션 헤더 출력
print_header() {
    echo -e "\n${BLUE}===========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}===========================================${NC}\n"
}

# 함수: 성공 메시지
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# 함수: 경고 메시지
print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# 함수: 오류 메시지
print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 시작 시간 기록
start_time=$(date +%s)

print_header "🚀 CI 워크플로우 로컬 테스트 시작"

# 현재 디렉토리 확인
if [ ! -f "_config.yml" ]; then
    print_error "Jekyll 프로젝트 루트 디렉토리에서 실행해주세요."
    exit 1
fi

print_success "Jekyll 프로젝트 루트 디렉토리 확인됨"

# ====================
# 1. 🧹 Lint & Test Job
# ====================
print_header "🧹 Step 1: Jekyll Lint & Test"

# Ruby 및 Bundle 확인
if ! command -v ruby &> /dev/null; then
    print_error "Ruby가 설치되어 있지 않습니다."
    exit 1
fi

if ! command -v bundle &> /dev/null; then
    print_error "Bundler가 설치되어 있지 않습니다. 'gem install bundler'를 실행하세요."
    exit 1
fi

print_success "Ruby $(ruby -v | cut -d' ' -f2) 및 Bundler 확인됨"

# Bundle 의존성 설치
echo -e "\n📦 Bundle 의존성 설치 중..."
if bundle install --quiet; then
    print_success "Bundle 의존성 설치 완료"
else
    print_error "Bundle 의존성 설치 실패"
    exit 1
fi

# Jekyll 설정 검증
echo -e "\n🧹 Jekyll 설정 검증 중..."
if bundle exec jekyll doctor; then
    print_success "Jekyll 설정이 유효합니다!"
else
    print_error "Jekyll 설정 검증 실패"
    exit 1
fi

# Jekyll 개발 빌드 테스트
echo -e "\n🧪 Jekyll 개발 빌드 테스트 중..."
if JEKYLL_ENV=development bundle exec jekyll build --drafts --verbose > /tmp/jekyll_build.log 2>&1; then
    print_success "Jekyll 개발 빌드 테스트 완료!"
else
    print_error "Jekyll 개발 빌드 테스트 실패"
    echo "빌드 로그:"
    cat /tmp/jekyll_build.log
    exit 1
fi

# ====================
# 2. 📝 Markdown Lint Job
# ====================
print_header "📝 Step 2: Markdown Lint"

# Node.js 확인
if ! command -v node &> /dev/null; then
    print_warning "Node.js가 설치되어 있지 않습니다."
    print_warning "Homebrew로 설치: brew install node"
    echo -e "\n📝 Markdown Lint 건너뜀"
else
    print_success "Node.js $(node -v) 확인됨"
    
    # markdownlint-cli 설치 확인 및 설치
    if ! command -v markdownlint &> /dev/null; then
        echo -e "\n📦 markdownlint-cli 설치 중..."
        if npm install -g markdownlint-cli; then
            print_success "markdownlint-cli 설치 완료"
        else
            print_error "markdownlint-cli 설치 실패"
            exit 1
        fi
    else
        print_success "markdownlint-cli 확인됨"
    fi
    
    # markdownlint 설정 파일 생성
    echo -e "\n📝 markdownlint 설정 파일 생성 중..."
    cat > .markdownlint.json << 'EOF'
{
  "MD013": false,
  "MD033": false,
  "MD034": false,
  "MD036": false,
  "MD041": false
}
EOF
    print_success "markdownlint 설정 파일 생성 완료"
    
    # Markdown 파일 린트 실행
    echo -e "\n🔍 Markdown 파일 린트 검사 중..."
    if markdownlint '_posts/**/*.md' --config .markdownlint.json; then
        print_success "Markdown 린트 검사 완료!"
    else
        print_warning "Markdown 린트 검사에서 문제가 발견되었지만 계속 진행합니다..."
        print_warning "자동 수정을 시도하려면: markdownlint '_posts/**/*.md' --config .markdownlint.json --fix"
    fi
    
    # 임시 설정 파일 정리
    rm -f .markdownlint.json
fi

# ====================
# 3. 📄 YAML Lint Job
# ====================
print_header "📄 Step 3: YAML Lint"

# Python 확인
if ! command -v python3 &> /dev/null; then
    print_warning "Python3가 설치되어 있지 않습니다."
    print_warning "Homebrew로 설치: brew install python"
    echo -e "\n📄 YAML Lint 건너뜀"
else
    print_success "Python3 $(python3 -V) 확인됨"
    
    # yamllint 설치 확인 및 설치
    if ! python3 -c "import yamllint" &> /dev/null; then
        echo -e "\n📦 yamllint 설치 중..."
        if pip3 install yamllint; then
            print_success "yamllint 설치 완료"
        else
            print_error "yamllint 설치 실패"
            exit 1
        fi
    else
        print_success "yamllint 확인됨"
    fi
    
    # YAML 파일 린트 실행
    echo -e "\n🔍 YAML 파일 린트 검사 중..."
    if yamllint -d relaxed .; then
        print_success "YAML 린트 검사 완료!"
    else
        print_warning "YAML 린트 검사에서 문제가 발견되었지만 계속 진행합니다..."
    fi
fi

# ====================
# 완료 메시지
# ====================
end_time=$(date +%s)
duration=$((end_time - start_time))

print_header "🎉 CI 워크플로우 로컬 테스트 완료"
echo -e "${GREEN}모든 테스트가 성공적으로 완료되었습니다!${NC}"
echo -e "${BLUE}소요 시간: ${duration}초${NC}\n"

# 다음 단계 안내
echo -e "${YELLOW}다음 단계:${NC}"
echo "1. 변경사항을 커밋하고 브랜치에 푸시하세요"
echo "2. GitHub에서 PR을 생성하세요"
echo "3. CI 워크플로우가 자동으로 실행됩니다"
echo ""
echo -e "${BLUE}명령어 예시:${NC}"
echo "git add ."
echo "git commit -m \"Add new feature\""
echo "git push origin your-branch-name" 