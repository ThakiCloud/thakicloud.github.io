#!/bin/bash

# Tiledesk Design Studio 테스트 환경 설정 스크립트
# 작성일: 2025-08-19

echo "🎨 Tiledesk Design Studio 테스트 환경 설정을 시작합니다..."

# 환경 변수 설정
export TILEDESK_TEST_DIR="$(pwd)"
export NODE_VERSION="$(node --version)"
export NPM_VERSION="$(npm --version)"
export NG_VERSION="$(ng version --json 2>/dev/null | jq -r '.apps[0].dependencies."@angular/cli" // "14.2.6"')"

echo "📊 현재 환경 정보:"
echo "  Node.js: $NODE_VERSION"
echo "  npm: $NPM_VERSION"
echo "  Angular CLI: $NG_VERSION"
echo "  Test Directory: $TILEDESK_TEST_DIR"

# .zshrc에 추가할 alias들 생성
ALIASES_FILE="$HOME/.zshrc_tiledesk_aliases"

cat > "$ALIASES_FILE" << 'EOF'
# Tiledesk Design Studio 테스트 환경 aliases
# 생성일: 2025-08-19

# 디렉토리 이동
alias td-dir="cd ~/work/thakicloud/thakicloud.github.io/tutorials/tiledesk-test/design-studio"
alias td-blog="cd ~/work/thakicloud/thakicloud.github.io"

# 개발 서버 관리
alias td-install="npm install"
alias td-start="ng serve --port 4200 --host localhost"
alias td-build="ng build --output-path=dist --base-href ./"
alias td-test="ng test"

# 프로젝트 정보
alias td-info="echo 'Tiledesk Design Studio 정보:' && echo 'GitHub: https://github.com/Tiledesk/design-studio' && echo 'License: MIT' && echo 'Angular: 14.2.6'"
alias td-deps="npm list --depth=0"
alias td-version="cat package.json | grep version"

# 개발 도구
alias td-doctor="ng doctor"
alias td-lint="ng lint"
alias td-clean="rm -rf node_modules dist && npm install"

# 포트 관리
alias td-port="lsof -i :4200"
alias td-kill="kill -9 \$(lsof -t -i:4200) 2>/dev/null || echo 'No process on port 4200'"

# 로그 확인
alias td-log="tail -f ng-serve.log"

echo "🎨 Tiledesk Design Studio aliases loaded!"
EOF

# .zshrc에 source 추가 (중복 방지)
if ! grep -q "source ~/.zshrc_tiledesk_aliases" ~/.zshrc; then
    echo "" >> ~/.zshrc
    echo "# Tiledesk Design Studio aliases" >> ~/.zshrc
    echo "source ~/.zshrc_tiledesk_aliases" >> ~/.zshrc
    echo "✅ ~/.zshrc에 Tiledesk aliases 추가됨"
else
    echo "ℹ️  Tiledesk aliases가 이미 ~/.zshrc에 설정되어 있습니다"
fi

# 즉시 aliases 로드
source "$ALIASES_FILE"

echo ""
echo "🎯 사용 가능한 명령어들:"
echo "  td-dir      - Tiledesk 프로젝트 디렉토리로 이동"
echo "  td-install  - 의존성 설치"
echo "  td-start    - 개발 서버 시작 (http://localhost:4200)"
echo "  td-build    - 프로덕션 빌드"
echo "  td-info     - 프로젝트 정보 확인"
echo "  td-clean    - node_modules 정리 후 재설치"
echo "  td-kill     - 포트 4200의 프로세스 종료"
echo ""
echo "✨ 설정 완료! 새 터미널에서 'td-dir' 명령어로 시작하세요."
