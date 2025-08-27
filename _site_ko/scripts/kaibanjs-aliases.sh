#!/bin/bash
# KaibanJS 관련 zshrc aliases 설정 스크립트

echo "🔧 KaibanJS zshrc aliases 설정 중..."

# zshrc 백업 생성
cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
echo "📄 zshrc 백업 완료: ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"

# KaibanJS aliases 추가
cat >> ~/.zshrc << 'EOF'

# ===== KaibanJS AI Agent Kanban Aliases =====
# KaibanJS 관련 alias
alias kjs="npx kaibanjs@latest"
alias kjsinit="npx kaibanjs@latest init"
alias kjsstart="npm run kaiban"
alias kjstest="node src/test.js"

# 개발 환경 관련
alias nodedev="npm run dev"
alias nodestart="npm start"
alias nodeclean="rm -rf node_modules package-lock.json && npm install"

# 프로젝트 관리
alias kjsproj="mkdir kaibanjs-project && cd kaibanjs-project && kjsinit ."
alias kjslog="tail -f logs/kaibanjs.log"

# 환경 확인
alias kjsenv="echo 'Node:' \$(node --version) && echo 'npm:' \$(npm --version) && echo 'KaibanJS:' \$(npm list kaibanjs 2>/dev/null | grep kaibanjs || echo 'Not installed')"

# 자주 사용하는 개발 명령어 조합
alias kjsdev="kjsenv && npm install && kjsstart"
alias kjsfresh="nodeclean && kjsdev"

# AI 에이전트 관련 유틸리티
alias agentlist="find . -name '*.js' -exec grep -l 'new Agent' {} \;"
alias tasklist="find . -name '*.js' -exec grep -l 'new Task' {} \;"
alias teamlist="find . -name '*.js' -exec grep -l 'new Team' {} \;"

# 로그 및 모니터링
alias kjslogs="tail -f *.log | grep -E '(Agent|Task|Team)'"
alias kjsstatus="ps aux | grep -E '(node|kaibanjs)'"

# 테스트 및 디버깅
alias kjsdebug="NODE_OPTIONS='--inspect' npm start"
alias kjsverbose="DEBUG=* npm start"

echo "✅ KaibanJS aliases 설정 완료!"
echo "📝 사용법:"
echo "  kjsenv     - 환경 확인"
echo "  kjsinit    - 새 프로젝트 초기화"
echo "  kjsdev     - 개발 환경 시작"
echo "  kjstest    - 테스트 실행"
echo "  agentlist  - 에이전트 파일 찾기"
echo ""
echo "🔄 변경사항을 적용하려면 'source ~/.zshrc' 또는 새 터미널을 열어주세요."
EOF 