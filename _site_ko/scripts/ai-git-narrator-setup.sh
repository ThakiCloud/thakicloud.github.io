#!/bin/bash

# AI-Git-Narrator + Ollama Qwen2 자동 설치 및 설정 스크립트
# 작성일: 2025-07-17
# 작성자: Thaki Cloud Team

set -e  # 오류 발생 시 스크립트 중단

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# 로그 함수
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# 시스템 요구사항 검사
check_system_requirements() {
    log_step "시스템 요구사항 검사 중..."
    
    # macOS 버전 확인
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_error "이 스크립트는 macOS에서만 실행됩니다."
        exit 1
    fi
    
    # macOS 버전 체크
    macos_version=$(sw_vers -productVersion)
    log_info "macOS 버전: $macos_version"
    
    # 메모리 확인
    memory_gb=$(system_profiler SPHardwareDataType | grep "Memory:" | awk '{print $2}')
    log_info "시스템 메모리: $memory_gb"
    
    # 최소 메모리 요구사항 체크 (8GB)
    memory_num=$(echo $memory_gb | grep -o '[0-9]*')
    if [ "$memory_num" -lt 8 ]; then
        log_warning "Qwen2:8b 모델 실행을 위해 최소 8GB RAM이 권장됩니다."
        log_info "더 작은 qwen2:3b 모델을 사용하는 것을 고려해보세요."
    fi
    
    # Homebrew 설치 확인
    if ! command -v brew &> /dev/null; then
        log_warning "Homebrew가 설치되지 않았습니다. 설치를 진행합니다..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Apple Silicon인 경우 PATH 추가
        if [[ $(uname -m) == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    else
        log_success "Homebrew가 이미 설치되어 있습니다."
    fi
    
    # Git 설치 확인
    if ! command -v git &> /dev/null; then
        log_error "Git이 설치되지 않았습니다. Git을 먼저 설치해주세요."
        exit 1
    else
        git_version=$(git --version)
        log_info "Git 버전: $git_version"
    fi
}

# Ollama 설치 및 설정
install_ollama() {
    log_step "Ollama 설치 및 설정 중..."
    
    # Ollama 설치 확인
    if ! command -v ollama &> /dev/null; then
        log_info "📦 Ollama 설치 중..."
        brew install ollama
        log_success "Ollama가 성공적으로 설치되었습니다."
    else
        log_info "Ollama가 이미 설치되어 있습니다."
        ollama_version=$(ollama --version)
        log_info "Ollama 버전: $ollama_version"
    fi
    
    # Ollama 서비스 시작
    log_info "🚀 Ollama 서비스 시작 중..."
    
    # 기존 서비스 중지 (필요시)
    if brew services list | grep -q "ollama.*started"; then
        log_info "기존 Ollama 서비스를 재시작합니다..."
        brew services restart ollama
    else
        brew services start ollama
    fi
    
    # 서비스 시작 대기
    log_info "Ollama 서비스 시작 대기 중..."
    sleep 5
    
    # Ollama 서비스 상태 확인
    for i in {1..10}; do
        if curl -s http://localhost:11434/api/tags &> /dev/null; then
            log_success "Ollama 서비스가 성공적으로 시작되었습니다."
            break
        else
            log_info "Ollama 서비스 시작 대기 중... ($i/10)"
            sleep 2
        fi
        
        if [ $i -eq 10 ]; then
            log_error "Ollama 서비스 시작에 실패했습니다."
            log_info "수동으로 'ollama serve'를 실행해보세요."
            exit 1
        fi
    done
}

# Qwen2 모델 다운로드
download_qwen2_model() {
    log_step "Qwen2 모델 다운로드 및 설정 중..."
    
    # 사용 가능한 모델 확인
    if ollama list | grep -q "qwen2:8b"; then
        log_info "Qwen2:8b 모델이 이미 설치되어 있습니다."
    else
        log_info "📥 Qwen2:8b 모델 다운로드 중... (약 4.7GB, 시간이 걸릴 수 있습니다)"
        
        # 메모리가 충분하지 않으면 3b 모델 권장
        memory_num=$(system_profiler SPHardwareDataType | grep "Memory:" | awk '{print $2}' | grep -o '[0-9]*')
        if [ "$memory_num" -lt 12 ]; then
            log_warning "메모리가 12GB 미만입니다. qwen2:3b 모델을 설치하시겠습니까? (y/n)"
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                ollama pull qwen2:3b
                QWEN_MODEL="qwen2:3b"
            else
                ollama pull qwen2:8b
                QWEN_MODEL="qwen2:8b"
            fi
        else
            ollama pull qwen2:8b
            QWEN_MODEL="qwen2:8b"
        fi
        
        log_success "Qwen2 모델이 성공적으로 다운로드되었습니다."
    fi
    
    # 모델 목록 확인
    log_info "설치된 모델 목록:"
    ollama list
    
    # 모델 테스트
    log_info "🧪 Qwen2 모델 테스트 중..."
    test_response=$(echo "Hello, can you help me write a git commit message?" | ollama run ${QWEN_MODEL:-qwen2:8b} --verbose 2>/dev/null || echo "테스트 실패")
    
    if [[ "$test_response" != "테스트 실패" ]]; then
        log_success "Qwen2 모델이 정상적으로 작동합니다."
    else
        log_warning "Qwen2 모델 테스트에서 문제가 발생했습니다."
    fi
}

# AI-Git-Narrator 설치
install_ai_git_narrator() {
    log_step "AI-Git-Narrator 설치 중..."
    
    # AI-Git-Narrator 설치 확인
    if ! command -v ai-git-narrator &> /dev/null; then
        log_info "📦 AI-Git-Narrator 설치 중..."
        
        # Homebrew tap 추가 및 설치
        brew tap pmusolino/tap
        brew install ai-git-narrator
        
        log_success "AI-Git-Narrator가 성공적으로 설치되었습니다."
    else
        log_info "AI-Git-Narrator가 이미 설치되어 있습니다."
        narrator_version=$(ai-git-narrator --version 2>/dev/null || echo "버전 정보 없음")
        log_info "AI-Git-Narrator 버전: $narrator_version"
    fi
    
    # 설치 확인
    if command -v ai-git-narrator &> /dev/null; then
        log_success "AI-Git-Narrator 설치가 확인되었습니다."
    else
        log_error "AI-Git-Narrator 설치에 실패했습니다."
        exit 1
    fi
}

# 설정 파일 생성
create_config_files() {
    log_step "AI-Git-Narrator 설정 파일 생성 중..."
    
    # 설정 디렉토리 생성
    mkdir -p ~/.config/ai-git-narrator
    
    # 기본 설정 파일 생성
    cat > ~/.config/ai-git-narrator/config.json << EOF
{
  "ai_provider": "ollama",
  "ollama": {
    "model": "${QWEN_MODEL:-qwen2:8b}",
    "base_url": "http://localhost:11434",
    "temperature": 0.7,
    "max_tokens": 150,
    "timeout": 30
  },
  "commit": {
    "language": "ko",
    "style": "conventional",
    "max_length": 72,
    "include_scope": true,
    "include_body": false
  },
  "pr": {
    "language": "ko",
    "include_summary": true,
    "include_changes": true,
    "max_length": 500
  }
}
EOF
    
    log_success "설정 파일이 생성되었습니다: ~/.config/ai-git-narrator/config.json"
    
    # 프로젝트별 설정 템플릿 생성
    cat > ~/.config/ai-git-narrator/template.json << 'EOF'
{
  "ai_provider": "ollama",
  "ollama": {
    "model": "qwen2:8b"
  },
  "commit": {
    "language": "en",
    "style": "simple",
    "max_length": 50,
    "custom_prefix": "[PROJECT] "
  }
}
EOF
    
    log_info "프로젝트별 설정 템플릿이 생성되었습니다: ~/.config/ai-git-narrator/template.json"
}

# Shell Aliases 설정
setup_shell_aliases() {
    log_step "Shell aliases 설정 중..."
    
    # 기존 설정 확인
    if grep -q "AI-Git-Narrator Aliases" ~/.zshrc 2>/dev/null; then
        log_info "AI-Git-Narrator aliases가 이미 설정되어 있습니다."
        return
    fi
    
    # zshrc에 aliases 추가
    cat >> ~/.zshrc << 'EOF'

# AI-Git-Narrator Aliases
alias gitmsg="ai-git-narrator commit"
alias gitpr="ai-git-narrator pr"
alias acommit="ai-git-narrator commit | head -1"
alias smartcommit='msg=$(ai-git-narrator commit 2>/dev/null | head -1) && if [ -n "$msg" ]; then echo "제안된 커밋 메시지: $msg" && read -p "이 메시지로 커밋하시겠습니까? (y/n): " response && if [[ "$response" =~ ^[Yy]$ ]]; then git commit -m "$msg"; else echo "커밋이 취소되었습니다."; fi; else echo "AI 커밋 메시지 생성에 실패했습니다."; fi'

# 한국어 aliases
alias 커밋메시지="ai-git-narrator commit"
alias PR설명="ai-git-narrator pr"

# Git 워크플로 aliases
alias gadd="git add ."
alias gstatus="git status"
alias glog="git log --oneline -10"

# AI 기반 워크플로
alias aiworkflow='echo "🤖 AI Git 워크플로:" && echo "1. gadd - 파일 추가" && echo "2. gitmsg - AI 커밋 메시지 생성" && echo "3. smartcommit - AI 메시지로 자동 커밋" && echo "4. gitpr - PR 설명 생성"'

echo "🤖 AI-Git-Narrator aliases loaded! Type 'aiworkflow' for help."
EOF
    
    log_success "Shell aliases가 ~/.zshrc에 추가되었습니다."
}

# Cursor IDE 설정 생성
setup_cursor_integration() {
    log_step "Cursor IDE 통합 설정 생성 중..."
    
    # 현재 디렉토리에 Cursor 설정 생성
    CURSOR_CONFIG_DIR=".vscode"
    mkdir -p "$CURSOR_CONFIG_DIR"
    
    # Tasks 설정
    cat > "$CURSOR_CONFIG_DIR/tasks.json" << 'EOF'
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "AI Commit Message",
      "type": "shell",
      "command": "ai-git-narrator",
      "args": ["commit"],
      "group": "build",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": false,
        "panel": "shared",
        "showReuseMessage": true,
        "clear": false
      },
      "problemMatcher": []
    },
    {
      "label": "AI PR Description",
      "type": "shell",
      "command": "ai-git-narrator",
      "args": ["pr"],
      "group": "build",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": false,
        "panel": "shared",
        "showReuseMessage": true,
        "clear": false
      },
      "problemMatcher": []
    },
    {
      "label": "Smart Auto Commit",
      "type": "shell",
      "command": "bash",
      "args": [
        "-c",
        "msg=$(ai-git-narrator commit 2>/dev/null | head -1) && if [ -n \"$msg\" ]; then echo \"제안된 메시지: $msg\" && git commit -m \"$msg\"; else echo \"AI 메시지 생성 실패\"; fi"
      ],
      "group": "build",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": false,
        "panel": "shared"
      },
      "problemMatcher": []
    }
  ]
}
EOF
    
    # 키보드 단축키 설정
    cat > "$CURSOR_CONFIG_DIR/keybindings.json" << 'EOF'
[
  {
    "key": "cmd+shift+g",
    "command": "workbench.action.tasks.runTask",
    "args": "AI Commit Message"
  },
  {
    "key": "cmd+shift+p",
    "command": "workbench.action.tasks.runTask",
    "args": "AI PR Description"
  },
  {
    "key": "cmd+alt+c",
    "command": "workbench.action.tasks.runTask",
    "args": "Smart Auto Commit"
  }
]
EOF
    
    # User Snippets
    mkdir -p "$CURSOR_CONFIG_DIR/snippets"
    cat > "$CURSOR_CONFIG_DIR/snippets/ai-git.code-snippets" << 'EOF'
{
  "AI Commit Message": {
    "prefix": "aicommit",
    "body": [
      "# AI가 제안한 커밋 메시지",
      "# 터미널에서 'gitmsg' 명령어를 실행하세요",
      "",
      "# 사용법:",
      "# 1. git add . 로 변경사항 스테이징",
      "# 2. gitmsg 명령어로 AI 메시지 생성",
      "# 3. smartcommit 으로 자동 커밋"
    ],
    "description": "AI 커밋 메시지 생성 가이드"
  },
  "AI Workflow": {
    "prefix": "aiflow",
    "body": [
      "# 🤖 AI Git Workflow",
      "# 1. gadd      - git add .",
      "# 2. gitmsg    - AI 커밋 메시지 생성",
      "# 3. smartcommit - AI 메시지로 자동 커밋",
      "# 4. gitpr     - PR 설명 생성"
    ],
    "description": "AI Git 워크플로 가이드"
  }
}
EOF
    
    log_success "Cursor IDE 통합 설정이 생성되었습니다: $CURSOR_CONFIG_DIR/"
    log_info "키보드 단축키:"
    log_info "  - Cmd+Shift+G: AI 커밋 메시지 생성"
    log_info "  - Cmd+Shift+P: AI PR 설명 생성"
    log_info "  - Cmd+Alt+C: 스마트 자동 커밋"
}

# 테스트 실행
run_tests() {
    log_step "AI-Git-Narrator 기능 테스트 중..."
    
    # 테스트 저장소 생성
    TEST_DIR="/tmp/ai-git-narrator-test-$(date +%s)"
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
    
    log_info "테스트 저장소 생성: $TEST_DIR"
    
    # Git 저장소 초기화
    git init --quiet
    git config user.name "AI Test User"
    git config user.email "test@ai-git-narrator.local"
    
    # 테스트 파일 생성
    cat > app.js << 'EOF'
// 사용자 인증 시스템
const express = require('express');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');

const app = express();
app.use(express.json());

// 사용자 등록 API
app.post('/register', async (req, res) => {
  const { email, password } = req.body;
  const hashedPassword = await bcrypt.hash(password, 10);
  
  // 데이터베이스에 저장 (여기서는 생략)
  res.json({ message: '사용자 등록 완료' });
});

// 로그인 API
app.post('/login', async (req, res) => {
  const { email, password } = req.body;
  
  // 사용자 인증 로직
  const token = jwt.sign({ email }, 'secret-key', { expiresIn: '1h' });
  res.json({ token });
});

app.listen(3000, () => {
  console.log('서버가 3000번 포트에서 실행 중입니다.');
});
EOF
    
    cat > package.json << 'EOF'
{
  "name": "ai-test-app",
  "version": "1.0.0",
  "description": "AI-Git-Narrator 테스트용 샘플 애플리케이션",
  "main": "app.js",
  "scripts": {
    "start": "node app.js",
    "test": "echo \"테스트 실행\" && exit 0"
  },
  "dependencies": {
    "express": "^4.18.2",
    "jsonwebtoken": "^9.0.0",
    "bcrypt": "^5.1.0"
  }
}
EOF
    
    cat > README.md << 'EOF'
# AI Git Narrator 테스트 프로젝트

이 프로젝트는 AI-Git-Narrator 기능을 테스트하기 위한 샘플 애플리케이션입니다.

## 기능
- JWT 기반 사용자 인증
- Express.js 웹 서버
- 비밀번호 해싱

## 설치 및 실행
```bash
npm install
npm start
```
EOF
    
    # 파일 스테이징
    git add .
    
    # AI 커밋 메시지 생성 테스트
    log_info "🧪 AI 커밋 메시지 생성 테스트 중..."
    
    # Ollama 서비스 상태 재확인
    if ! curl -s http://localhost:11434/api/tags &> /dev/null; then
        log_error "Ollama 서비스가 실행되지 않고 있습니다."
        log_info "다음 명령어로 서비스를 시작해주세요: brew services start ollama"
        return 1
    fi
    
    # AI 메시지 생성 (타임아웃 설정)
    if timeout 30 ai-git-narrator commit > ai_message.txt 2>/dev/null; then
        AI_MESSAGE=$(cat ai_message.txt)
        if [ -n "$AI_MESSAGE" ]; then
            log_success "✅ AI 커밋 메시지 생성 성공:"
            echo "$AI_MESSAGE" | head -3
            
            # 첫 번째 줄만 추출하여 커밋
            COMMIT_MSG=$(echo "$AI_MESSAGE" | head -1 | sed 's/^[[:space:]]*//')
            if [ -n "$COMMIT_MSG" ]; then
                git commit -m "$COMMIT_MSG" --quiet
                log_success "✅ 커밋 완료: $COMMIT_MSG"
            else
                log_warning "⚠️  커밋 메시지가 비어있습니다."
            fi
        else
            log_warning "⚠️  AI 메시지가 생성되지 않았습니다."
        fi
    else
        log_warning "⚠️  AI 메시지 생성 시간이 초과되었습니다."
        log_info "Ollama 서비스와 Qwen2 모델이 정상적으로 로드되었는지 확인해주세요."
    fi
    
    # 파일 수정 및 두 번째 테스트
    echo "" >> app.js
    echo "// 추가 기능: 로그아웃 API" >> app.js
    echo "app.post('/logout', (req, res) => {" >> app.js
    echo "  res.json({ message: '로그아웃 완료' });" >> app.js
    echo "});" >> app.js
    
    git add app.js
    
    log_info "🧪 두 번째 AI 메시지 생성 테스트 중..."
    if timeout 30 ai-git-narrator commit > ai_message2.txt 2>/dev/null; then
        AI_MESSAGE2=$(cat ai_message2.txt)
        if [ -n "$AI_MESSAGE2" ]; then
            log_success "✅ 두 번째 AI 메시지 생성 성공:"
            echo "$AI_MESSAGE2" | head -1
        fi
    fi
    
    # Git 로그 확인
    log_info "📋 Git 커밋 히스토리:"
    git log --oneline -5
    
    # 테스트 결과 요약
    echo ""
    log_success "🎉 테스트 완료!"
    log_info "테스트 저장소 위치: $TEST_DIR"
    log_info "생성된 파일들을 확인하고 필요시 정리하세요."
    
    # 원래 디렉토리로 돌아가기
    cd - > /dev/null
}

# 사용법 가이드 출력
show_usage_guide() {
    log_step "사용법 가이드"
    
    echo ""
    echo "🎯 기본 사용법:"
    echo "  1. git add .                  # 변경사항 스테이징"
    echo "  2. gitmsg                     # AI 커밋 메시지 생성"
    echo "  3. git commit -m \"\$(gitmsg)\"   # 생성된 메시지로 커밋"
    echo "  4. smartcommit                # 한 번에 자동 커밋"
    echo ""
    echo "🔧 고급 사용법:"
    echo "  - gitpr                       # AI PR 설명 생성"
    echo "  - 커밋메시지                   # 한국어 alias"
    echo "  - aiworkflow                  # 워크플로 도움말"
    echo ""
    echo "⚙️  설정 파일 위치:"
    echo "  - ~/.config/ai-git-narrator/config.json"
    echo "  - 프로젝트별 설정: .ai-git-narrator.json"
    echo ""
    echo "🚀 Cursor IDE 통합:"
    echo "  - Cmd+Shift+G: AI 커밋 메시지"
    echo "  - Cmd+Shift+P: AI PR 설명"
    echo "  - Cmd+Alt+C: 스마트 자동 커밋"
    echo ""
    echo "🔍 문제 해결:"
    echo "  - Ollama 서비스 재시작: brew services restart ollama"
    echo "  - 모델 재다운로드: ollama pull qwen2:8b"
    echo "  - 설정 확인: cat ~/.config/ai-git-narrator/config.json"
    echo ""
}

# 메인 실행 함수
main() {
    echo "🤖 AI-Git-Narrator + Ollama Qwen2 자동 설치 스크립트"
    echo "======================================================"
    echo ""
    
    check_system_requirements
    install_ollama
    download_qwen2_model
    install_ai_git_narrator
    create_config_files
    setup_shell_aliases
    setup_cursor_integration
    run_tests
    show_usage_guide
    
    echo ""
    log_success "🎉 모든 설치 및 설정이 완료되었습니다!"
    echo ""
    echo "📋 다음 단계:"
    echo "1. 새 터미널을 열거나 'source ~/.zshrc' 실행"
    echo "2. Git 저장소에서 'gadd' → 'gitmsg' → 'smartcommit' 시도"
    echo "3. Cursor IDE에서 Cmd+Shift+G로 AI 커밋 메시지 생성"
    echo "4. 문제 발생 시 위의 문제 해결 섹션 참조"
    echo ""
    echo "🔗 추가 정보:"
    echo "- AI-Git-Narrator GitHub: https://github.com/pmusolino/AI-Git-Narrator"
    echo "- Ollama 공식 사이트: https://ollama.ai"
    echo "- Qwen2 모델 정보: https://ollama.ai/library/qwen2"
    echo ""
}

# 스크립트 실행
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 