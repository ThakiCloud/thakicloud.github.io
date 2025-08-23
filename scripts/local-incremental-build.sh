#!/bin/bash

# 로컬 증분 빌드 스크립트
# 변경된 포스트만 감지하여 최적화된 Jekyll 빌드 실행

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN} ⚡ 로컬 증분 빌드${NC}"
    echo -e "${CYAN}========================================${NC}"
}

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

# 기본값 설정
SERVE_MODE=false
FORCE_FULL=false
LIMIT_POSTS=0
COMPARE_WITH="HEAD~1"
PROFILE=false

# 옵션 파싱
while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--serve)
            SERVE_MODE=true
            shift
            ;;
        -f|--force-full)
            FORCE_FULL=true
            shift
            ;;
        -l|--limit)
            LIMIT_POSTS="$2"
            shift 2
            ;;
        -c|--compare)
            COMPARE_WITH="$2"
            shift 2
            ;;
        -p|--profile)
            PROFILE=true
            shift
            ;;
        -h|--help)
            echo "사용법: $0 [옵션]"
            echo ""
            echo "옵션:"
            echo "  -s, --serve             빌드 후 서버 실행"
            echo "  -f, --force-full        전체 빌드 강제 실행"
            echo "  -l, --limit NUMBER      빌드할 포스트 수 제한"
            echo "  -c, --compare COMMIT    비교할 커밋 (기본값: HEAD~1)"
            echo "  -p, --profile           빌드 프로파일링 활성화"
            echo "  -h, --help              도움말 표시"
            echo ""
            echo "예시:"
            echo "  $0                      # 증분 빌드"
            echo "  $0 -s                   # 빌드 후 서버 실행"
            echo "  $0 -f                   # 전체 빌드"
            echo "  $0 -l 10                # 최근 10개 포스트만 빌드"
            echo "  $0 -p                   # 프로파일링과 함께 빌드"
            exit 0
            ;;
        *)
            print_error "알 수 없는 옵션: $1"
            exit 1
            ;;
    esac
done

print_header

# 의존성 확인
print_status "의존성 확인 중..."

if ! command -v bundle &> /dev/null; then
    print_error "Bundler가 설치되어 있지 않습니다. 'gem install bundler'를 실행하세요."
    exit 1
fi

if ! bundle check &> /dev/null; then
    print_warning "Gem 의존성이 최신이 아닙니다. bundle install을 실행합니다..."
    bundle install
fi

print_success "의존성 확인 완료"

# 변경사항 분석
print_status "변경사항 분석 중..."

if [[ -f "scripts/detect-post-changes.sh" ]]; then
    CHANGE_INFO=$(./scripts/detect-post-changes.sh -f json -c $COMPARE_WITH)
    BUILD_TYPE=$(echo "$CHANGE_INFO" | grep -o '"build_type": "[^"]*"' | cut -d'"' -f4)
    POSTS_CHANGED=$(echo "$CHANGE_INFO" | grep -o '"posts_changed": [0-9]*' | cut -d':' -f2 | tr -d ' ')
    TOTAL_CHANGED=$(echo "$CHANGE_INFO" | grep -o '"total_changed": [0-9]*' | cut -d':' -f2 | tr -d ' ')
else
    print_warning "변경사항 감지 스크립트를 찾을 수 없습니다. 기본 분석을 사용합니다."
    
    CHANGED_FILES=$(git diff --name-only $COMPARE_WITH HEAD 2>/dev/null || echo "")
    if echo "$CHANGED_FILES" | grep -q -E '^(_config\.yml|_data/|_includes/|_layouts/|_sass/|assets/)'; then
        BUILD_TYPE="full"
    elif echo "$CHANGED_FILES" | grep -q -E '^(_posts/|_pages/)'; then
        BUILD_TYPE="incremental"
    else
        BUILD_TYPE="none"
    fi
    
    POSTS_CHANGED=$(echo "$CHANGED_FILES" | grep '^_posts/' | wc -l)
    TOTAL_CHANGED=$(echo "$CHANGED_FILES" | wc -l)
fi

# 강제 전체 빌드 확인
if [[ "$FORCE_FULL" == "true" ]]; then
    BUILD_TYPE="full"
    print_warning "전체 빌드가 강제로 설정되었습니다."
fi

# 빌드 명령어 구성
JEKYLL_CMD="bundle exec jekyll"
BUILD_ARGS=""

if [[ "$SERVE_MODE" == "true" ]]; then
    JEKYLL_CMD="$JEKYLL_CMD serve"
    BUILD_ARGS="$BUILD_ARGS --livereload --open-url"
else
    JEKYLL_CMD="$JEKYLL_CMD build"
fi

# 환경 설정
export JEKYLL_ENV=development

# 빌드 타입별 최적화
case $BUILD_TYPE in
    "full")
        print_status "전체 빌드 실행 중..."
        BUILD_ARGS="$BUILD_ARGS --verbose"
        if [[ "$PROFILE" == "true" ]]; then
            BUILD_ARGS="$BUILD_ARGS --profile"
        fi
        ;;
    "incremental")
        print_status "증분 빌드 실행 중... (변경된 포스트: $POSTS_CHANGED개)"
        BUILD_ARGS="$BUILD_ARGS --incremental"
        
        # 포스트 수 제한 최적화
        if [[ $LIMIT_POSTS -gt 0 ]]; then
            BUILD_ARGS="$BUILD_ARGS --limit_posts $LIMIT_POSTS"
            print_status "포스트 수를 $LIMIT_POSTS개로 제한합니다."
        elif [[ $POSTS_CHANGED -le 5 && $TOTAL_CHANGED -le 10 ]]; then
            BUILD_ARGS="$BUILD_ARGS --limit_posts 20"
            print_status "변경사항이 적어 최근 20개 포스트만 빌드합니다."
        elif [[ $POSTS_CHANGED -le 10 ]]; then
            BUILD_ARGS="$BUILD_ARGS --limit_posts 50"
            print_status "변경사항이 적어 최근 50개 포스트만 빌드합니다."
        fi
        ;;
    "none")
        if [[ "$SERVE_MODE" == "true" ]]; then
            print_warning "변경사항이 없지만 서버 모드로 실행합니다."
            BUILD_ARGS="$BUILD_ARGS --incremental --limit_posts 10"
        else
            print_warning "빌드가 필요한 변경사항이 없습니다."
            echo "서버 모드로 실행하려면 -s 옵션을 사용하세요."
            exit 0
        fi
        ;;
esac

# 빌드 시작 시간 기록
START_TIME=$(date +%s)

print_status "빌드 명령어: $JEKYLL_CMD $BUILD_ARGS"
echo ""

# Jekyll 빌드 실행
if eval "$JEKYLL_CMD $BUILD_ARGS"; then
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    
    echo ""
    print_success "빌드가 성공적으로 완료되었습니다! (소요 시간: ${DURATION}초)"
    
    if [[ "$SERVE_MODE" == "false" ]]; then
        # 빌드 결과 통계
        if [[ -d "_site" ]]; then
            SITE_SIZE=$(du -sh _site | cut -f1)
            FILE_COUNT=$(find _site -type f | wc -l)
            HTML_COUNT=$(find _site -name '*.html' | wc -l)
            
            echo ""
            print_status "빌드 통계:"
            echo "  📁 사이트 크기: $SITE_SIZE"
            echo "  📄 총 파일 수: $FILE_COUNT"
            echo "  🌐 HTML 파일: $HTML_COUNT"
        fi
        
        echo ""
        print_status "다음 단계:"
        echo "  - 로컬 서버 실행: $0 -s"
        echo "  - 프로덕션 빌드: JEKYLL_ENV=production $JEKYLL_CMD build"
        echo "  - 변경사항 확인: ./scripts/detect-post-changes.sh"
    fi
else
    print_error "빌드 중 오류가 발생했습니다."
    exit 1
fi
