#!/bin/bash

# Firecrawl 개발을 위한 zshrc aliases 설정
# 작성자: Thaki Cloud
# 날짜: 2025-08-21

echo "🔥 Firecrawl 개발 aliases 설정 중..."

# zshrc 백업
if [ -f ~/.zshrc ]; then
    cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
    echo "📦 기존 .zshrc 백업 완료"
fi

# Firecrawl aliases 추가
cat >> ~/.zshrc << 'EOF'

# ====================================
# Firecrawl Development Aliases
# ====================================

# 프로젝트 디렉토리
export FIRECRAWL_TEST_DIR="$HOME/thaki/thaki.github.io/tutorials/firecrawl-test"

# 기본 명령어
alias fctest="cd $FIRECRAWL_TEST_DIR"
alias fcsetup="cd $FIRECRAWL_TEST_DIR && chmod +x *.sh && ./test-firecrawl-setup.sh"
alias fcpython="cd $FIRECRAWL_TEST_DIR && source firecrawl-venv/bin/activate && python test-python-sdk.py"
alias fcnode="cd $FIRECRAWL_TEST_DIR && node test-nodejs-sdk.js"

# 가상환경 관리
alias fcvenv="cd $FIRECRAWL_TEST_DIR && source firecrawl-venv/bin/activate"
alias fcdeactivate="deactivate"

# 패키지 관리
alias fcpip="cd $FIRECRAWL_TEST_DIR && source firecrawl-venv/bin/activate && pip"
alias fcnpm="cd $FIRECRAWL_TEST_DIR && npm"

# 개발 도구
alias fclog="cd $FIRECRAWL_TEST_DIR && ls -la"
alias fcclean="cd $FIRECRAWL_TEST_DIR && rm -rf firecrawl-venv node_modules package-lock.json && echo '🧹 환경 정리 완료'"

# API 테스트 (환경 변수 필요)
alias fcapi="curl -X POST https://api.firecrawl.dev/v2/scrape -H 'Content-Type: application/json' -H 'Authorization: Bearer \$FIRECRAWL_API_KEY'"

# 문서 열기
alias fcdocs="open https://docs.firecrawl.dev"
alias fcgithub="open https://github.com/firecrawl/firecrawl"

# 로그 및 디버깅
alias fcstatus="cd $FIRECRAWL_TEST_DIR && echo '🔥 Firecrawl 환경 상태:' && echo 'Python:' && python3 --version && echo 'Node.js:' && node --version && echo 'NPM:' && npm --version"

EOF

echo "✅ Firecrawl aliases가 ~/.zshrc에 추가되었습니다."
echo ""
echo "🔄 변경사항을 적용하려면 다음 명령어를 실행하세요:"
echo "source ~/.zshrc"
echo ""
echo "📋 사용 가능한 aliases:"
echo "  fctest      - Firecrawl 테스트 디렉토리로 이동"
echo "  fcsetup     - Firecrawl 환경 설정"
echo "  fcpython    - Python SDK 테스트 실행"
echo "  fcnode      - Node.js SDK 테스트 실행"
echo "  fcvenv      - Python 가상환경 활성화"
echo "  fcstatus    - 환경 상태 확인"
echo "  fcclean     - 환경 정리"
echo "  fcdocs      - Firecrawl 문서 열기"
