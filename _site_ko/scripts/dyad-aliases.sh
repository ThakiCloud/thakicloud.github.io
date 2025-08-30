#!/bin/bash

# dyad AI 앱 빌더 - zshrc Aliases 설정 스크립트
# 작성일: 2025-07-31
# 목적: dyad 개발 워크플로우 최적화를 위한 alias 설정

echo "🚀 dyad AI 앱 빌더 - zshrc Aliases 설정"
echo "========================================"

# 색상 설정
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# dyad 관련 alias들
DYAD_ALIASES='
# ====================================
# dyad AI 앱 빌더 관련 Aliases
# 작성일: 2025-07-31
# ====================================

# 🏗️ dyad 프로젝트 관리
alias dyad-new="cd ~/dyad-projects && mkdir"
alias dyad-open="code ~/dyad-projects"
alias dyad-backup="rsync -av ~/dyad-projects/ ~/Backup/dyad-projects/"
alias dyad-list="ls -la ~/dyad-projects/"
alias dyad-goto="cd ~/dyad-projects"
alias dyad-clean="find ~/dyad-projects -name node_modules -type d -exec rm -rf {} + 2>/dev/null"

# 🔧 Node.js 환경 관리
alias node-check="echo \"Node.js: \$(node --version)\" && echo \"npm: \$(npm --version)\""
alias npm-clean="rm -rf node_modules package-lock.json && npm install"
alias npm-audit-fix="npm audit fix --force"
alias npm-global-list="npm list -g --depth=0"
alias npm-outdated="npm outdated"
alias npm-update="npm update"

# 📝 Git 워크플로우 (dyad 프로젝트용)
alias git-dyad="git add . && git commit -m \"dyad: auto-generated code\" && git push"
alias git-feature="git checkout -b feature/"
alias git-hotfix="git checkout -b hotfix/"
alias git-cleanup="git branch --merged | grep -v main | xargs git branch -d"
alias git-recent="git for-each-ref --sort=-committerdate refs/heads/ --format=\"%(committerdate:short) %(refname:short)\""
alias git-size="git count-objects -vH"

# 🚀 개발 도구
alias serve-local="npx serve -s build -l 3000"
alias serve-dist="npx serve -s dist -l 8080"
alias build-size="npx bundlesize"
alias dep-check="npx depcheck"
alias audit-security="npm audit --audit-level moderate"
alias port-kill="lsof -ti:3000 | xargs kill -9 2>/dev/null"

# 🔍 dyad 소스코드 빌드 및 개발 (개발자용)
alias dyad-dev="cd ~/dyad && npm start"
alias dyad-build="cd ~/dyad && npm run make"
alias dyad-test="cd ~/dyad && npm test"
alias dyad-lint="cd ~/dyad && npm run lint"
alias dyad-update="cd ~/dyad && git pull && npm install"
alias dyad-doctor="cd ~/dyad && npm run ts && npm run lint"

# 🧪 테스트 및 디버깅
alias dyad-test-runner="bash ~/scripts/dyad-test.sh"
alias dyad-test-full="bash ~/scripts/dyad-test.sh --build-test --performance"
alias dyad-test-clean="bash ~/scripts/dyad-test.sh --cleanup"
alias dyad-debug="NODE_ENV=development DEBUG=dyad:* npm start"
alias dyad-profile="clinic doctor -- npm start"

# 📊 시스템 모니터링
alias dyad-mem="ps aux | grep -E \"(dyad|electron)\" | grep -v grep"
alias dyad-ports="lsof -i -P -n | grep -E \"(dyad|electron)\""
alias sys-mem="vm_stat | grep \"Pages free\""
alias sys-cpu="top -l 1 -s 0 | grep \"CPU usage\""

# 🔐 보안 및 백업
alias dyad-secure-backup="tar -czf ~/Backup/dyad-secure-\$(date +%Y%m%d).tar.gz ~/dyad-projects/"
alias dyad-env-check="env | grep -E \"(API_KEY|TOKEN|SECRET)\" | wc -l"
alias dyad-keys-audit="grep -r \"api.*key\" ~/dyad-projects/ --include=\"*.env*\" 2>/dev/null"

# 🌐 AI API 관리
alias api-openai-test="curl -H \"Authorization: Bearer \$OPENAI_API_KEY\" https://api.openai.com/v1/models | jq \".data[0].id\""
alias api-claude-test="curl -H \"x-api-key: \$ANTHROPIC_API_KEY\" https://api.anthropic.com/v1/messages"
alias ollama-status="curl -s http://localhost:11434/api/tags | jq \".models[].name\""
alias ollama-pull-code="ollama pull codellama:7b"
alias ollama-pull-llama="ollama pull llama3.1:8b"

# 📦 패키지 관리
alias pkg-install="npm install --save"
alias pkg-install-dev="npm install --save-dev"
alias pkg-uninstall="npm uninstall"
alias pkg-search="npm search"
alias pkg-info="npm info"
alias pkg-outdated-global="npm outdated -g"

# 🎨 개발 환경 설정
alias code-dyad="code ~/dyad-projects"
alias code-scripts="code ~/scripts"
alias edit-aliases="code ~/.zshrc"
alias reload-shell="source ~/.zshrc && echo \"Shell reloaded!\""
alias show-aliases="alias | grep dyad"

# 📝 로그 및 디버깅
alias dyad-logs="tail -f ~/.dyad/logs/*.log 2>/dev/null || echo \"No log files found\""
alias electron-logs="ls -la ~/Library/Logs/dyad/ 2>/dev/null || echo \"No Electron logs found\""
alias clear-logs="rm -rf ~/.dyad/logs/* 2>/dev/null && echo \"Logs cleared\""

# 🔄 업데이트 및 유지보수
alias update-dyad="cd ~/dyad && git pull origin main && npm install"
alias update-node="nvm install node --reinstall-packages-from=node"
alias update-npm="npm install -g npm@latest"
alias clean-all="npm-clean && dyad-clean && npm cache clean --force"

# 💡 도움말 및 정보
alias dyad-help="echo \"dyad 관련 주요 명령어:\"; alias | grep \"alias dyad\" | sort"
alias dyad-version="cd ~/dyad 2>/dev/null && git describe --tags --abbrev=0 || echo \"dyad not found\""
alias dyad-info="echo \"공식 웹사이트: https://dyad.sh\"; echo \"GitHub: https://github.com/dyad-sh/dyad\""
alias node-info="node --version && npm --version && echo \"npx: \$(npx --version)\""

# 🎯 빠른 작업 시작
alias work-dyad="dyad-goto && dyad-list"
alias new-react="dyad-new my-react-app && cd my-react-app && npm init -y"
alias new-next="dyad-new my-next-app && cd my-next-app && npx create-next-app@latest ."
alias quick-serve="python3 -m http.server 8000"

# ====================================
# dyad Aliases 끝
# ====================================
'

# zshrc 파일 백업
backup_zshrc() {
    if [ -f ~/.zshrc ]; then
        cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
        echo -e "${GREEN}✓${NC} .zshrc 파일이 백업되었습니다."
    fi
}

# alias 추가
add_aliases() {
    echo -e "${BLUE}📝${NC} dyad aliases를 .zshrc에 추가하는 중..."
    
    # 기존 dyad aliases 제거 (있다면)
    if grep -q "dyad AI 앱 빌더 관련 Aliases" ~/.zshrc 2>/dev/null; then
        echo -e "${YELLOW}⚠️${NC} 기존 dyad aliases를 제거하는 중..."
        sed -i '' '/# dyad AI 앱 빌더 관련 Aliases/,/# dyad Aliases 끝/d' ~/.zshrc
    fi
    
    # 새 aliases 추가
    echo "$DYAD_ALIASES" >> ~/.zshrc
    echo -e "${GREEN}✓${NC} dyad aliases가 추가되었습니다."
}

# 디렉토리 생성
create_directories() {
    echo -e "${BLUE}📁${NC} 필요한 디렉토리를 생성하는 중..."
    
    mkdir -p ~/dyad-projects/{templates,active,archive,shared}
    mkdir -p ~/Backup
    mkdir -p ~/scripts
    
    echo -e "${GREEN}✓${NC} 디렉토리가 생성되었습니다:"
    echo "  ~/dyad-projects/ (프로젝트 저장소)"
    echo "  ~/Backup/ (백업 디렉토리)"
    echo "  ~/scripts/ (스크립트 디렉토리)"
}

# 테스트 스크립트 설치
install_test_script() {
    echo -e "${BLUE}🧪${NC} dyad 테스트 스크립트를 설치하는 중..."
    
    if [ -f "./dyad-test.sh" ]; then
        cp ./dyad-test.sh ~/scripts/
        chmod +x ~/scripts/dyad-test.sh
        echo -e "${GREEN}✓${NC} 테스트 스크립트가 설치되었습니다: ~/scripts/dyad-test.sh"
    else
        echo -e "${YELLOW}⚠️${NC} dyad-test.sh 파일을 찾을 수 없습니다."
    fi
}

# 프로젝트 생성 스크립트 추가
create_project_script() {
    echo -e "${BLUE}🛠️${NC} 프로젝트 생성 스크립트를 생성하는 중..."
    
    cat << 'EOF' > ~/dyad-projects/create-project.sh
#!/bin/bash
# dyad 프로젝트 생성 도우미 스크립트

PROJECT_NAME=$1
PROJECT_TYPE=${2:-"react"}

if [ -z "$PROJECT_NAME" ]; then
    echo "사용법: ./create-project.sh <project-name> [react|next|vue|vanilla]"
    echo ""
    echo "예시:"
    echo "  ./create-project.sh my-todo-app react"
    echo "  ./create-project.sh my-blog next"
    echo "  ./create-project.sh my-portfolio vue"
    exit 1
fi

PROJECT_DIR="active/$PROJECT_NAME"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

echo "# $PROJECT_NAME" > README.md
echo "" >> README.md
echo "Created with dyad on $(date)" >> README.md
echo "Project type: $PROJECT_TYPE" >> README.md
echo "" >> README.md
echo "## Getting Started" >> README.md
echo "" >> README.md
echo "1. Open this project in dyad" >> README.md
echo "2. Start building with AI assistance" >> README.md
echo "3. Preview your app in real-time" >> README.md

echo "✅ Project '$PROJECT_NAME' created successfully!"
echo "📁 Location: $(pwd)"
echo "🚀 Open this directory in dyad to start building"
EOF

    chmod +x ~/dyad-projects/create-project.sh
    echo -e "${GREEN}✓${NC} 프로젝트 생성 스크립트가 생성되었습니다: ~/dyad-projects/create-project.sh"
}

# 환경 변수 템플릿 생성
create_env_template() {
    echo -e "${BLUE}🔑${NC} 환경 변수 템플릿을 생성하는 중..."
    
    cat << 'EOF' > ~/dyad-projects/.env.template
# ====================================
# dyad AI 앱 빌더 환경 변수 템플릿
# 복사 후 .env로 이름 변경하여 사용
# ====================================

# AI API Keys
OPENAI_API_KEY=your-openai-api-key-here
ANTHROPIC_API_KEY=your-anthropic-api-key-here
GOOGLE_API_KEY=your-google-api-key-here

# Ollama 설정 (로컬 AI)
OLLAMA_BASE_URL=http://localhost:11434
OLLAMA_MODEL=llama3.1:8b

# 개발 환경 설정
NODE_ENV=development
DEBUG=dyad:*
PORT=3000

# 기타 설정
BROWSER=none
REACT_APP_NAME=My-dyad-App
NEXT_TELEMETRY_DISABLED=1

# 주의사항:
# 1. 이 파일을 .env로 복사 후 실제 API 키를 입력하세요
# 2. .env 파일은 절대 Git에 커밋하지 마세요
# 3. API 키는 안전하게 보관하세요
EOF

    echo -e "${GREEN}✓${NC} 환경 변수 템플릿이 생성되었습니다: ~/dyad-projects/.env.template"
}

# 설치 완료 메시지
show_completion() {
    echo
    echo "🎉 dyad AI 앱 빌더 설정이 완료되었습니다!"
    echo "========================================"
    echo
    echo "📋 설치된 구성 요소:"
    echo "  ✓ zsh aliases ($(alias | grep dyad | wc -l | tr -d ' ') 개)"
    echo "  ✓ 프로젝트 디렉토리 구조"
    echo "  ✓ 테스트 스크립트"
    echo "  ✓ 프로젝트 생성 도우미"
    echo "  ✓ 환경 변수 템플릿"
    echo
    echo "🚀 시작하기:"
    echo "  1. 새 터미널을 열거나 'source ~/.zshrc' 실행"
    echo "  2. 'dyad-help' 명령어로 사용 가능한 alias 확인"
    echo "  3. 'dyad-test-runner' 명령어로 설치 테스트"
    echo "  4. 'work-dyad' 명령어로 프로젝트 디렉토리 이동"
    echo
    echo "💡 유용한 명령어:"
    echo "  dyad-new <project-name>    # 새 프로젝트 디렉토리 생성"
    echo "  dyad-open                  # VS Code로 프로젝트 폴더 열기"
    echo "  dyad-test-runner           # dyad 설치 테스트"
    echo "  dyad-info                  # dyad 공식 정보 확인"
    echo "  dyad-help                  # 모든 dyad 명령어 보기"
    echo
    echo "📚 자세한 사용법은 다음 블로그 포스트를 참고하세요:"
    echo "  https://thakicloud.github.io/tutorials/dyad-local-ai-app-builder-comprehensive-tutorial/"
    echo
}

# 메인 실행
main() {
    echo "dyad aliases 설정을 시작합니다..."
    echo
    
    backup_zshrc
    add_aliases
    create_directories
    install_test_script
    create_project_script
    create_env_template
    show_completion
    
    # zshrc 리로드 여부 묻기
    echo -n "지금 바로 zsh 설정을 리로드하시겠습니까? (y/n): "
    read -r response
    if [[ "$response" == "y" || "$response" == "Y" ]]; then
        source ~/.zshrc
        echo -e "${GREEN}✓${NC} zsh 설정이 리로드되었습니다."
    else
        echo "나중에 'source ~/.zshrc' 명령어를 실행하여 설정을 적용하세요."
    fi
}

# 실행
main 