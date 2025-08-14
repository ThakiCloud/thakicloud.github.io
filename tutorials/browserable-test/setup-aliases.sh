#!/bin/bash

# Browserable SDK 테스트를 위한 macOS zsh alias 설정 스크립트
# 실행: chmod +x setup-aliases.sh && ./setup-aliases.sh

echo "🔧 Browserable 테스트용 alias 설정 중..."

# 현재 디렉토리 경로 저장
BROWSERABLE_TEST_DIR="$(pwd)"
echo "📁 테스트 디렉토리: $BROWSERABLE_TEST_DIR"

# zshrc 백업
if [ -f ~/.zshrc ]; then
    cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
    echo "✅ ~/.zshrc 백업 완료"
fi

# alias 추가
cat >> ~/.zshrc << EOF

# ========================================
# Browserable SDK 테스트 Aliases
# 생성일: $(date)
# ========================================

# 프로젝트 디렉토리
export BROWSERABLE_TEST_DIR="$BROWSERABLE_TEST_DIR"

# 빠른 네비게이션
alias btest="cd \$BROWSERABLE_TEST_DIR"
alias btestl="cd \$BROWSERABLE_TEST_DIR && ls -la"

# 환경 설정
alias benv="cd \$BROWSERABLE_TEST_DIR && code .env"
alias benvshow="cd \$BROWSERABLE_TEST_DIR && cat .env | grep -v '#' | grep '='"

# 패키지 관리
alias binstall="cd \$BROWSERABLE_TEST_DIR && npm install"
alias bupdate="cd \$BROWSERABLE_TEST_DIR && npm update"
alias bclean="cd \$BROWSERABLE_TEST_DIR && rm -rf node_modules package-lock.json && npm install"

# 테스트 실행
alias bquick="cd \$BROWSERABLE_TEST_DIR && npm test"
alias bfull="cd \$BROWSERABLE_TEST_DIR && RUN_FULL_TESTS=true npm test"
alias bgithub="cd \$BROWSERABLE_TEST_DIR && npm run github-trending"
alias bamazon="cd \$BROWSERABLE_TEST_DIR && npm run amazon-search"

# 개발 및 디버깅
alias bdebug="cd \$BROWSERABLE_TEST_DIR && DEBUG=true npm test"
alias bverbose="cd \$BROWSERABLE_TEST_DIR && DEBUG=true RUN_FULL_TESTS=true npm test"

# 로그 및 모니터링
alias btop="top -pid \$(pgrep -f 'node.*browserable')"
alias bps="ps aux | grep -E '(node|browserable)' | grep -v grep"

# 유틸리티
alias bhelp="echo '
🔧 Browserable 테스트 명령어:
  btest     - 테스트 디렉토리로 이동
  benv      - 환경 변수 파일 편집
  binstall  - 의존성 설치
  bquick    - 빠른 테스트 실행
  bfull     - 전체 테스트 실행
  bgithub   - GitHub 트렌딩 검색
  bamazon   - Amazon 제품 검색
  bdebug    - 디버그 모드로 테스트
  bhelp     - 이 도움말 표시
'"

# Docker 관련 (Browserable 서버용)
alias bdocker="docker ps | grep browserable"
alias bserver="echo '🌐 Browserable 서버 상태:' && curl -s http://localhost:2001/health || echo '❌ 서버 연결 실패'"
alias bui="open http://localhost:2001"

EOF

echo "✅ alias 설정 완료!"
echo ""
echo "🔄 설정을 적용하려면 다음 중 하나를 실행하세요:"
echo "   source ~/.zshrc"
echo "   또는 새 터미널 창을 열어주세요"
echo ""
echo "📚 사용 가능한 명령어를 보려면: bhelp"
echo ""
echo "🚀 빠른 시작:"
echo "   1. source ~/.zshrc"
echo "   2. btest"
echo "   3. binstall"
echo "   4. bquick"
