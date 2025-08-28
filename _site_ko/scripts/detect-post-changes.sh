#!/bin/bash

# 포스트 변경사항 감지 및 분석 스크립트
# 변경된 포스트만 식별하여 증분 빌드 최적화

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
    echo -e "${CYAN} 📝 포스트 변경사항 분석${NC}"
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
COMPARE_WITH="HEAD~1"
OUTPUT_FORMAT="summary"
MAX_FILES=20

# 옵션 파싱
while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--compare)
            COMPARE_WITH="$2"
            shift 2
            ;;
        -f|--format)
            OUTPUT_FORMAT="$2"
            shift 2
            ;;
        -m|--max)
            MAX_FILES="$2"
            shift 2
            ;;
        -h|--help)
            echo "사용법: $0 [옵션]"
            echo ""
            echo "옵션:"
            echo "  -c, --compare COMMIT    비교할 커밋 (기본값: HEAD~1)"
            echo "  -f, --format FORMAT     출력 형식 (summary|detailed|json)"
            echo "  -m, --max NUMBER        최대 파일 수 (기본값: 20)"
            echo "  -h, --help              도움말 표시"
            echo ""
            echo "예시:"
            echo "  $0                      # 최근 커밋과 비교"
            echo "  $0 -c HEAD~3            # 3개 커밋 전과 비교"
            echo "  $0 -f detailed          # 상세 정보 출력"
            echo "  $0 -f json              # JSON 형식 출력"
            exit 0
            ;;
        *)
            print_error "알 수 없는 옵션: $1"
            exit 1
            ;;
    esac
done

print_header

# Git 저장소 확인
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "Git 저장소가 아닙니다."
    exit 1
fi

# 변경된 파일 감지
print_status "변경된 파일 감지 중... (비교 대상: $COMPARE_WITH)"

# 모든 변경된 파일
ALL_CHANGED=$(git diff --name-only $COMPARE_WITH HEAD 2>/dev/null || echo "")

if [[ -z "$ALL_CHANGED" ]]; then
    print_warning "변경된 파일이 없습니다."
    exit 0
fi

# 카테고리별 분류
POSTS_CHANGED=$(echo "$ALL_CHANGED" | grep '^_posts/' | head -$MAX_FILES || true)
PAGES_CHANGED=$(echo "$ALL_CHANGED" | grep '^_pages/' | head -$MAX_FILES || true)
CONFIG_CHANGED=$(echo "$ALL_CHANGED" | grep -E '^(_config\.yml|_data/|Gemfile)' || true)
ASSETS_CHANGED=$(echo "$ALL_CHANGED" | grep -E '^(_includes/|_layouts/|_sass/|assets/)' || true)
OTHER_CHANGED=$(echo "$ALL_CHANGED" | grep -v -E '^(_posts/|_pages/|_config\.yml|_data/|Gemfile|_includes/|_layouts/|_sass/|assets/)' || true)

# 통계 계산
POSTS_COUNT=$(echo "$POSTS_CHANGED" | sed '/^$/d' | wc -l | tr -d ' ')
PAGES_COUNT=$(echo "$PAGES_CHANGED" | sed '/^$/d' | wc -l | tr -d ' ')
CONFIG_COUNT=$(echo "$CONFIG_CHANGED" | sed '/^$/d' | wc -l | tr -d ' ')
ASSETS_COUNT=$(echo "$ASSETS_CHANGED" | sed '/^$/d' | wc -l | tr -d ' ')
OTHER_COUNT=$(echo "$OTHER_CHANGED" | sed '/^$/d' | wc -l | tr -d ' ')
TOTAL_COUNT=$(echo "$ALL_CHANGED" | wc -l | tr -d ' ')

# 빌드 타입 결정
if [[ $CONFIG_COUNT -gt 0 || $ASSETS_COUNT -gt 0 ]]; then
    BUILD_TYPE="full"
    BUILD_REASON="설정 또는 에셋 파일 변경"
elif [[ $POSTS_COUNT -gt 0 || $PAGES_COUNT -gt 0 ]]; then
    BUILD_TYPE="incremental"
    BUILD_REASON="콘텐츠 파일 변경"
else
    BUILD_TYPE="none"
    BUILD_REASON="빌드 관련 파일 변경 없음"
fi

# 출력 형식에 따른 결과 표시
case $OUTPUT_FORMAT in
    "json")
        cat << EOF
{
  "build_type": "$BUILD_TYPE",
  "build_reason": "$BUILD_REASON",
  "total_changed": $TOTAL_COUNT,
  "posts_changed": $POSTS_COUNT,
  "pages_changed": $PAGES_COUNT,
  "config_changed": $CONFIG_COUNT,
  "assets_changed": $ASSETS_COUNT,
  "other_changed": $OTHER_COUNT,
  "changed_files": {
    "posts": [$(echo "$POSTS_CHANGED" | sed 's/.*/"&"/' | tr '\n' ',' | sed 's/,$//')],
    "pages": [$(echo "$PAGES_CHANGED" | sed 's/.*/"&"/' | tr '\n' ',' | sed 's/,$//')],
    "config": [$(echo "$CONFIG_CHANGED" | sed 's/.*/"&"/' | tr '\n' ',' | sed 's/,$//')],
    "assets": [$(echo "$ASSETS_CHANGED" | sed 's/.*/"&"/' | tr '\n' ',' | sed 's/,$//')],
    "other": [$(echo "$OTHER_CHANGED" | sed 's/.*/"&"/' | tr '\n' ',' | sed 's/,$//')]
  }
}
EOF
        ;;
    "detailed")
        echo ""
        print_status "📊 변경사항 상세 분석"
        echo ""
        echo -e "${CYAN}빌드 타입:${NC} $BUILD_TYPE"
        echo -e "${CYAN}빌드 이유:${NC} $BUILD_REASON"
        echo -e "${CYAN}총 변경 파일:${NC} $TOTAL_COUNT개"
        echo ""
        
        if [[ $POSTS_COUNT -gt 0 ]]; then
            echo -e "${GREEN}📝 변경된 포스트 ($POSTS_COUNT개):${NC}"
            echo "$POSTS_CHANGED" | sed 's/^/  - /'
            echo ""
        fi
        
        if [[ $PAGES_COUNT -gt 0 ]]; then
            echo -e "${GREEN}📄 변경된 페이지 ($PAGES_COUNT개):${NC}"
            echo "$PAGES_CHANGED" | sed 's/^/  - /'
            echo ""
        fi
        
        if [[ $CONFIG_COUNT -gt 0 ]]; then
            echo -e "${YELLOW}⚙️ 변경된 설정 파일 ($CONFIG_COUNT개):${NC}"
            echo "$CONFIG_CHANGED" | sed 's/^/  - /'
            echo ""
        fi
        
        if [[ $ASSETS_COUNT -gt 0 ]]; then
            echo -e "${BLUE}🎨 변경된 에셋 파일 ($ASSETS_COUNT개):${NC}"
            echo "$ASSETS_CHANGED" | sed 's/^/  - /'
            echo ""
        fi
        
        if [[ $OTHER_COUNT -gt 0 ]]; then
            echo -e "${CYAN}📁 기타 변경 파일 ($OTHER_COUNT개):${NC}"
            echo "$OTHER_CHANGED" | sed 's/^/  - /'
            echo ""
        fi
        ;;
    "summary"|*)
        echo ""
        print_status "📊 변경사항 요약"
        echo ""
        echo -e "  ${CYAN}빌드 타입:${NC} $BUILD_TYPE"
        echo -e "  ${CYAN}빌드 이유:${NC} $BUILD_REASON"
        echo ""
        echo -e "  📝 포스트: ${GREEN}$POSTS_COUNT${NC}개"
        echo -e "  📄 페이지: ${GREEN}$PAGES_COUNT${NC}개"
        echo -e "  ⚙️ 설정: ${YELLOW}$CONFIG_COUNT${NC}개"
        echo -e "  🎨 에셋: ${BLUE}$ASSETS_COUNT${NC}개"
        echo -e "  📁 기타: ${CYAN}$OTHER_COUNT${NC}개"
        echo -e "  📊 총합: ${GREEN}$TOTAL_COUNT${NC}개"
        echo ""
        
        if [[ $POSTS_COUNT -gt 0 && $POSTS_COUNT -le 5 ]]; then
            echo -e "${GREEN}변경된 포스트:${NC}"
            echo "$POSTS_CHANGED" | sed 's/^/  - /' | sed 's/_posts\///'
            echo ""
        elif [[ $POSTS_COUNT -gt 5 ]]; then
            echo -e "${GREEN}변경된 포스트 (처음 5개):${NC}"
            echo "$POSTS_CHANGED" | head -5 | sed 's/^/  - /' | sed 's/_posts\///'
            echo -e "  ${YELLOW}... 그리고 $(($POSTS_COUNT - 5))개 더${NC}"
            echo ""
        fi
        ;;
esac

# 권장사항 출력
if [[ $OUTPUT_FORMAT != "json" ]]; then
    echo ""
    print_status "💡 권장사항"
    
    case $BUILD_TYPE in
        "full")
            echo -e "  ${YELLOW}전체 빌드가 필요합니다.${NC}"
            echo "  - Jekyll 설정이나 템플릿이 변경되었습니다."
            echo "  - 모든 페이지가 다시 생성됩니다."
            ;;
        "incremental")
            echo -e "  ${GREEN}증분 빌드로 충분합니다.${NC}"
            echo "  - 변경된 콘텐츠만 다시 빌드됩니다."
            echo "  - 빌드 시간이 크게 단축됩니다."
            if [[ $POSTS_COUNT -le 10 ]]; then
                echo "  - --limit_posts 옵션으로 더욱 최적화 가능합니다."
            fi
            ;;
        "none")
            echo -e "  ${CYAN}빌드가 필요하지 않을 수 있습니다.${NC}"
            echo "  - Jekyll 사이트에 영향을 주지 않는 파일들만 변경되었습니다."
            ;;
    esac
    
    echo ""
    print_success "분석 완료!"
fi

# 환경 변수로 결과 내보내기 (GitHub Actions용)
if [[ -n "$GITHUB_OUTPUT" ]]; then
    echo "build_type=$BUILD_TYPE" >> $GITHUB_OUTPUT
    echo "posts_changed=$POSTS_COUNT" >> $GITHUB_OUTPUT
    echo "pages_changed=$PAGES_COUNT" >> $GITHUB_OUTPUT
    echo "config_changed=$CONFIG_COUNT" >> $GITHUB_OUTPUT
    echo "assets_changed=$ASSETS_COUNT" >> $GITHUB_OUTPUT
    echo "total_changed=$TOTAL_COUNT" >> $GITHUB_OUTPUT
fi
