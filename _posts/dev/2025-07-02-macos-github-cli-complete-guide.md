---
title: "macOS GitHub CLI 완전 자동화 시리즈 - 1편: 설치와 환경 구성"
excerpt: "macOS에서 GitHub CLI 완전 자동화 환경 구축: zshrc 스크립트, alias, 그리고 원클릭 워크플로우 설정까지"
seo_title: "macOS GitHub CLI 완전 자동화 1편 - 설치와 환경 구성 - Thaki Cloud"
seo_description: "macOS 환경에서 GitHub CLI를 완전 자동화하는 방법: Homebrew 설치부터 고급 zshrc 스크립트, 커스텀 alias까지 전문가 수준의 개발 환경을 구축하는 단계별 가이드"
date: 2025-07-02
last_modified_at: 2025-07-02
categories:
  - dev
tags:
  - github-cli
  - macos
  - github
  - git
  - terminal
  - homebrew
  - zsh
  - automation
  - workflow
  - productivity
  - scripting
  - alias
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/dev/macos-github-cli-complete-guide/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 20분

## 시리즈 소개

**macOS GitHub CLI 완전 자동화 시리즈**는 터미널에서 GitHub 작업을 완전히 자동화하는 전문가급 워크플로우 구축을 다룹니다. 이슈 생성부터 프로젝트 관리, 위키 작성까지 모든 과정을 원클릭으로 처리할 수 있는 시스템을 만들어보겠습니다.

이 시리즈에서는 실제 개발 현장에서 사용할 수 있는 **완전 자동화 스크립트**, **지능형 alias**, **회사/개인 프로젝트 분리 관리** 등을 다룹니다. 단순한 CLI 사용법을 넘어서 개발 생산성을 혁신적으로 향상시키는 방법을 배우게 됩니다.

## 1편: 완벽한 개발 환경 구축

### 목표
- GitHub CLI 완전 자동화 환경 구축
- 고급 zshrc 설정과 지능형 alias 구성
- 회사/개인 계정 분리 관리 시스템
- 원클릭 워크플로우 기반 마련

## 사전 준비사항

### 시스템 요구사항 확인

```bash
# macOS 버전 확인 (Big Sur 11.0 이상 권장)
sw_vers

# Xcode Command Line Tools 설치 확인
xcode-select --install

# Shell 확인 (zsh 기본)
echo $SHELL
```

### 개발 환경 초기화

```bash
# 개발 디렉토리 구조 생성
mkdir -p ~/Development/{work,personal}
mkdir -p ~/.config/gh
mkdir -p ~/Documents/github-automation

# 통합 스크립트 디렉토리 생성 (모듈러 구조)
mkdir -p ~/scripts/github-cli/{core,issue,project,wiki,system}
mkdir -p ~/scripts/github-cli/project/templates
mkdir -p ~/scripts/github-cli/wiki/templates

# 환경 변수 파일 생성
touch ~/.env.github
chmod 600 ~/.env.github
```

## GitHub CLI 설치 및 초기 설정

### 1. 고급 Homebrew 설정

```bash
# Homebrew 설치 (최신 버전)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Homebrew 경로 설정 (.zshrc에 자동 추가)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
source ~/.zshrc

# 필수 도구들 일괄 설치
brew install gh jq fzf bat exa ripgrep fd tree curl wget
brew install --cask visual-studio-code

# 설치 확인
gh --version
jq --version
```

### 2. GitHub CLI 인증 완전 자동화

#### 다중 계정 관리 스크립트 생성

```bash
# 다중 계정 관리 스크립트
cat > ~/scripts/github-cli/core/auth.sh << 'EOF'
#!/bin/bash

# GitHub 계정 관리 스크립트
# 사용법: gh-account [work|personal|list|current]

WORK_TOKEN_FILE="$HOME/.config/gh/work_token"
PERSONAL_TOKEN_FILE="$HOME/.config/gh/personal_token"
CURRENT_CONTEXT_FILE="$HOME/.config/gh/current_context"

function gh-account() {
    case "$1" in
        "work")
            if [[ -f "$WORK_TOKEN_FILE" ]]; then
                gh auth login --with-token < "$WORK_TOKEN_FILE"
                echo "work" > "$CURRENT_CONTEXT_FILE"
                echo "🏢 회사 계정으로 전환되었습니다."
                gh auth status
            else
                echo "❌ 회사 계정 토큰이 설정되지 않았습니다."
                echo "토큰을 $WORK_TOKEN_FILE 에 저장하세요."
            fi
            ;;
        "personal")
            if [[ -f "$PERSONAL_TOKEN_FILE" ]]; then
                gh auth login --with-token < "$PERSONAL_TOKEN_FILE"
                echo "personal" > "$CURRENT_CONTEXT_FILE"
                echo "👤 개인 계정으로 전환되었습니다."
                gh auth status
            else
                echo "❌ 개인 계정 토큰이 설정되지 않았습니다."
                echo "토큰을 $PERSONAL_TOKEN_FILE 에 저장하세요."
            fi
            ;;
        "current")
            if [[ -f "$CURRENT_CONTEXT_FILE" ]]; then
                CONTEXT=$(cat "$CURRENT_CONTEXT_FILE")
                echo "현재 컨텍스트: $CONTEXT"
                gh auth status
            else
                echo "컨텍스트가 설정되지 않았습니다."
            fi
            ;;
        "list")
            echo "사용 가능한 계정:"
            [[ -f "$WORK_TOKEN_FILE" ]] && echo "  - work (회사 계정)"
            [[ -f "$PERSONAL_TOKEN_FILE" ]] && echo "  - personal (개인 계정)"
            ;;
        *)
            echo "사용법: gh-account [work|personal|list|current]"
            ;;
    esac
}
EOF

chmod +x ~/scripts/github-cli/core/auth.sh
```

#### 토큰 설정 도구

```bash
# 토큰 설정 도우미 스크립트
cat > ~/scripts/github-cli/core/setup-tokens.sh << 'EOF'
#!/bin/bash

echo "🔐 GitHub 토큰 설정 도우미"
echo "=============================="
echo

# 회사 계정 토큰 설정
echo "1️⃣ 회사 계정 토큰 설정"
echo "GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)"
echo "필요한 권한: repo, workflow, write:packages, delete:packages, admin:org, admin:public_key, admin:repo_hook, admin:org_hook, gist, notifications, user, delete_repo, write:discussion, admin:enterprise"
echo
read -p "회사 계정 토큰을 입력하세요: " WORK_TOKEN
echo "$WORK_TOKEN" > "$HOME/.config/gh/work_token"
chmod 600 "$HOME/.config/gh/work_token"
echo "✅ 회사 계정 토큰이 저장되었습니다."
echo

# 개인 계정 토큰 설정
echo "2️⃣ 개인 계정 토큰 설정"
read -p "개인 계정 토큰을 입력하세요: " PERSONAL_TOKEN
echo "$PERSONAL_TOKEN" > "$HOME/.config/gh/personal_token"
chmod 600 "$HOME/.config/gh/personal_token"
echo "✅ 개인 계정 토큰이 저장되었습니다."
echo

echo "🎉 설정 완료! 'gh-account work' 또는 'gh-account personal'로 계정을 전환하세요."
EOF

chmod +x ~/scripts/github-cli/core/setup-tokens.sh
```

## 고급 zshrc 설정 및 자동화

### 1. 완전 자동화 zshrc 구성

```bash
# 기존 .zshrc 백업
cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)

# 새로운 .zshrc 생성
cat > ~/.zshrc << 'EOF'
# ===============================================
# GitHub CLI 완전 자동화 환경 설정
# Author: Thaki Cloud
# Version: 2.0
# ===============================================

# Homebrew 설정
if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Oh My Zsh 설정 (선택적)
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git github gh zsh-autosuggestions zsh-syntax-highlighting)

# 기본 환경 변수
export EDITOR="code"
export BROWSER="open"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# GitHub CLI 환경 변수
export GITHUB_TOKEN_WORK="$(cat ~/.config/gh/work_token 2>/dev/null || echo '')"
export GITHUB_TOKEN_PERSONAL="$(cat ~/.config/gh/personal_token 2>/dev/null || echo '')"

# 개발 디렉토리
export DEV_HOME="$HOME/Development"
export WORK_DIR="$DEV_HOME/work"
export PERSONAL_DIR="$DEV_HOME/personal"
export GITHUB_CLI_SCRIPTS="$HOME/scripts/github-cli"

# PATH 설정
export PATH="$GITHUB_CLI_SCRIPTS:$HOME/.local/bin:$PATH"

# ===============================================
# GitHub CLI 함수들
# ===============================================

# 모듈러 스크립트 로딩
source ~/scripts/github-cli/core/auth.sh
source ~/scripts/github-cli/core/context.sh 2>/dev/null || true
source ~/scripts/github-cli/core/utils.sh 2>/dev/null || true

# 현재 GitHub 컨텍스트 표시
function gh_context() {
    if [[ -f "$HOME/.config/gh/current_context" ]]; then
        CONTEXT=$(cat "$HOME/.config/gh/current_context")
        case "$CONTEXT" in
            "work") echo "🏢" ;;
            "personal") echo "👤" ;;
            *) echo "❓" ;;
        esac
    else
        echo "❓"
    fi
}

# 프롬프트에 GitHub 컨텍스트 추가
PROMPT='$(gh_context) '$PROMPT

# ===============================================
# 지능형 Alias 시스템
# ===============================================

# 기본 개선된 명령어들
alias ls='exa --icons'
alias ll='exa -la --icons --git'
alias tree='exa --tree --icons'
alias cat='bat'
alias find='fd'
alias grep='rg'

# Git 향상된 alias
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gm='git merge'
alias gr='git rebase'
alias gst='git stash'
alias gstp='git stash pop'

# GitHub CLI 기본 alias
alias ghis='gh issue list'
alias ghpr='gh pr list'
alias ghrepo='gh repo list'

# ===============================================
# 완전 자동화 함수들
# ===============================================

# 스마트 리포지토리 클론
function gclone() {
    local repo_url="$1"
    local context="$(cat ~/.config/gh/current_context 2>/dev/null || echo 'personal')"
    
    if [[ "$context" == "work" ]]; then
        cd "$WORK_DIR"
    else
        cd "$PERSONAL_DIR"
    fi
    
    gh repo clone "$repo_url"
    local repo_name=$(basename "$repo_url" .git)
    cd "$repo_name"
    
    echo "✅ 리포지토리가 $context 디렉토리에 클론되었습니다."
}

# 이슈 중심 개발 워크플로우
function issue_start() {
    local issue_num="$1"
    local description="$2"
    
    if [[ -z "$issue_num" ]]; then
        echo "사용법: issue_start <이슈번호> [설명]"
        return 1
    fi
    
    # 이슈 정보 가져오기
    local issue_info=$(gh issue view "$issue_num" --json title,body)
    local issue_title=$(echo "$issue_info" | jq -r '.title')
    
    # 브랜치명 생성
    local branch_name="issue-${issue_num}"
    if [[ -n "$description" ]]; then
        branch_name="${branch_name}-$(echo "$description" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')"
    fi
    
    # 브랜치 생성 및 체크아웃
    git checkout -b "$branch_name"
    
    # 이슈에 댓글 추가
    gh issue comment "$issue_num" --body "🚀 작업을 시작했습니다.

**브랜치**: \`$branch_name\`
**담당자**: $(gh api user -q .login)
**시작 시간**: $(date '+%Y-%m-%d %H:%M:%S')

---
_이 댓글은 자동으로 생성되었습니다._"
    
    echo "✅ 이슈 #$issue_num 작업을 시작했습니다."
    echo "📝 제목: $issue_title"
    echo "🌿 브랜치: $branch_name"
}

# 이슈 완료 및 PR 생성
function issue_finish() {
    local issue_num="$1"
    local commit_message="$2"
    
    if [[ -z "$issue_num" ]]; then
        echo "사용법: issue_finish <이슈번호> [커밋메시지]"
        return 1
    fi
    
    # 현재 브랜치 확인
    local current_branch=$(git branch --show-current)
    
    # 변경사항 커밋
    git add .
    if [[ -n "$commit_message" ]]; then
        git commit -m "$commit_message

Closes #$issue_num"
    else
        git commit -m "Fix #$issue_num: $(gh issue view $issue_num -q .title)

Closes #$issue_num"
    fi
    
    # 브랜치 푸시
    git push -u origin "$current_branch"
    
    # PR 생성
    local pr_body="## 변경사항

이 PR은 이슈 #$issue_num 을 해결합니다.

### 주요 수정사항
- 

### 테스트 방법
- 

### 체크리스트
- [x] 코드 작성 완료
- [ ] 테스트 케이스 추가
- [ ] 문서 업데이트
- [ ] 코드 리뷰 요청

---
Closes #$issue_num"
    
    gh pr create \
        --title "Fix #$issue_num: $(gh issue view $issue_num -q .title)" \
        --body "$pr_body" \
        --draft
    
    echo "✅ PR이 생성되었습니다."
    echo "🔗 PR 링크: $(gh pr view --json url -q .url)"
}

# 프로젝트 빠른 생성
function create_project() {
    local project_name="$1"
    local project_desc="$2"
    
    if [[ -z "$project_name" ]]; then
        echo "사용법: create_project <프로젝트명> [설명]"
        return 1
    fi
    
    # 프로젝트 생성
    local project_url=$(gh project create \
        --title "$project_name" \
        --body "${project_desc:-$project_name 프로젝트}" \
        --format json | jq -r '.url')
    
    echo "✅ 프로젝트가 생성되었습니다: $project_url"
}

# 위키 빠른 편집
function wiki_edit() {
    local page_name="$1"
    
    if [[ -z "$page_name" ]]; then
        echo "사용법: wiki_edit <페이지명>"
        return 1
    fi
    
    # 위키 클론 (없으면)
    if [[ ! -d ".wiki" ]]; then
        local repo_name=$(basename "$(git remote get-url origin)" .git)
        git clone "$(git remote get-url origin | sed 's/\.git$/.wiki.git/')" .wiki
    fi
    
    cd .wiki
    
    # 페이지 파일 생성/편집
    local file_name="${page_name}.md"
    if [[ ! -f "$file_name" ]]; then
        touch "$file_name"
    fi
    
    "$EDITOR" "$file_name"
    
    # 자동 커밋 및 푸시
    git add "$file_name"
    git commit -m "docs: $page_name 페이지 업데이트"
    git push origin master
    
    cd ..
    echo "✅ 위키 페이지 '$page_name'이 업데이트되었습니다."
}

# ===============================================
# 생산성 향상 함수들
# ===============================================

# GitHub 대시보드
function gh_dashboard() {
    echo "🚀 GitHub 대시보드 $(date '+%Y-%m-%d %H:%M')"
    echo "$(gh_context) $(cat ~/.config/gh/current_context 2>/dev/null || echo 'Unknown') 계정"
    echo "========================================"
    echo
    
    echo "📋 내 할당 이슈 (최근 5개):"
    gh issue list --assignee @me --state open --limit 5 || echo "  할당된 이슈가 없습니다."
    echo
    
    echo "🔄 리뷰 요청된 PR:"
    gh pr list --search "review-requested:@me" --limit 5 || echo "  리뷰 요청된 PR이 없습니다."
    echo
    
    echo "✅ 최근 닫힌 이슈 (3개):"
    gh issue list --assignee @me --state closed --limit 3 || echo "  최근 닫힌 이슈가 없습니다."
    echo
    
    echo "📊 진행 중인 PR:"
    gh pr list --author @me --state open --limit 5 || echo "  진행 중인 PR이 없습니다."
}

# 빠른 이슈 생성
function quick_issue() {
    local title="$1"
    local body="$2"
    local labels="$3"
    
    if [[ -z "$title" ]]; then
        echo "사용법: quick_issue <제목> [내용] [라벨1,라벨2]"
        return 1
    fi
    
    local issue_body="${body:-## 설명

이슈에 대한 자세한 설명을 작성해주세요.

## 재현 단계

1. 
2. 
3. 

## 예상 결과


## 실제 결과


## 추가 정보

}"
    
    local created_issue=$(gh issue create \
        --title "$title" \
        --body "$issue_body" \
        ${labels:+--label "$labels"} \
        --format json)
    
    local issue_number=$(echo "$created_issue" | jq -r '.number')
    local issue_url=$(echo "$created_issue" | jq -r '.url')
    
    echo "✅ 이슈가 생성되었습니다:"
    echo "📝 #$issue_number: $title"
    echo "🔗 $issue_url"
    
    # 자동으로 이슈 시작 여부 묻기
    read -p "바로 작업을 시작하시겠습니까? (y/N): " start_work
    if [[ "$start_work" =~ ^[Yy]$ ]]; then
        issue_start "$issue_number"
    fi
}

# 개발 환경 빠른 설정
function dev_setup() {
    local repo_url="$1"
    
    if [[ -z "$repo_url" ]]; then
        echo "사용법: dev_setup <리포지토리 URL>"
        return 1
    fi
    
    # 스마트 클론
    gclone "$repo_url"
    
    # 개발 환경 자동 설정
    if [[ -f "package.json" ]]; then
        echo "📦 Node.js 프로젝트 감지, 의존성 설치 중..."
        npm install
    elif [[ -f "requirements.txt" ]]; then
        echo "🐍 Python 프로젝트 감지, 가상환경 및 의존성 설치 중..."
        python -m venv venv
        source venv/bin/activate
        pip install -r requirements.txt
    elif [[ -f "Gemfile" ]]; then
        echo "💎 Ruby 프로젝트 감지, 의존성 설치 중..."
        bundle install
    fi
    
    # VS Code로 열기
    code .
    
    echo "✅ 개발 환경 설정 완료!"
}

# ===============================================
# 자동 완성 설정
# ===============================================

# fzf 설정
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# GitHub CLI 자동완성
if command -v gh >/dev/null 2>&1; then
    eval "$(gh completion -s zsh)"
fi

# ===============================================
# 시작 시 실행
# ===============================================

# 환경 확인
function check_github_env() {
    if ! command -v gh >/dev/null 2>&1; then
        echo "⚠️  GitHub CLI가 설치되지 않았습니다."
        echo "   brew install gh 로 설치하세요."
    elif ! gh auth status >/dev/null 2>&1; then
        echo "⚠️  GitHub CLI 인증이 필요합니다."
        echo "   gh-account 명령어로 계정을 설정하세요."
    fi
}

# 시작 시 환경 확인 (조용히)
check_github_env 2>/dev/null

# Welcome 메시지
echo "🚀 GitHub CLI 완전 자동화 환경이 로드되었습니다!"
echo "💡 'gh_dashboard' 명령어로 현재 상황을 확인하세요."

# Oh My Zsh 로드 (설치된 경우)
[[ -f "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"
EOF

# .zshrc 다시 로드
source ~/.zshrc
```

### 2. 고급 스크립트 디렉토리 구성

```bash
# 프로젝트 템플릿 생성 스크립트
cat > ~/scripts/github-cli/project/templates/create-repo-with-template.sh << 'EOF'
#!/bin/bash

# 리포지토리 템플릿 기반 생성 및 초기 설정
# 사용법: create-repo-with-template.sh <repo-name> <template-type> [visibility]

REPO_NAME="$1"
TEMPLATE_TYPE="$2"
VISIBILITY="${3:-public}"

if [[ -z "$REPO_NAME" || -z "$TEMPLATE_TYPE" ]]; then
    echo "사용법: $0 <repo-name> <template-type> [public|private]"
    echo "템플릿 타입: react, node, python, ruby, docs, minimal"
    exit 1
fi

# 현재 컨텍스트 확인
CONTEXT=$(cat ~/.config/gh/current_context 2>/dev/null || echo 'personal')
echo "🔧 $CONTEXT 계정으로 리포지토리를 생성합니다."

# 리포지토리 생성
echo "📦 리포지토리 생성 중..."
gh repo create "$REPO_NAME" \
    --"$VISIBILITY" \
    --description "Auto-generated $TEMPLATE_TYPE project" \
    --gitignore "$TEMPLATE_TYPE" \
    --license mit \
    --clone

cd "$REPO_NAME"

# 템플릿별 초기 파일 생성
case "$TEMPLATE_TYPE" in
    "react")
        npx create-react-app . --template typescript
        ;;
    "node")
        npm init -y
        mkdir -p src tests docs
        echo "console.log('Hello, World!');" > src/index.js
        ;;
    "python")
        mkdir -p src tests docs
        echo "# $REPO_NAME" > README.md
        echo "__version__ = '0.1.0'" > src/__init__.py
        echo "def hello():\n    return 'Hello, World!'" > src/main.py
        cat > requirements.txt << 'PYEOF'
# Production dependencies

# Development dependencies
pytest>=7.0.0
black>=22.0.0
flake8>=4.0.0
PYEOF
        ;;
    "docs")
        mkdir -p docs assets
        cat > README.md << 'DOCEOF'
# ${REPO_NAME}

프로젝트 문서

## 목차

- [설치](docs/installation.md)
- [사용법](docs/usage.md)
- [API](docs/api.md)
DOCEOF
        ;;
    *)
        echo "# $REPO_NAME" > README.md
        ;;
esac

# 초기 커밋
git add .
git commit -m "🎉 Initial commit with $TEMPLATE_TYPE template"
git push -u origin main

# 기본 라벨 생성
gh label create "bug" --color "d73a4a" --description "Something isn't working" 2>/dev/null || true
gh label create "enhancement" --color "a2eeef" --description "New feature or request" 2>/dev/null || true
gh label create "documentation" --color "0075ca" --description "Improvements or additions to documentation" 2>/dev/null || true
gh label create "good first issue" --color "7057ff" --description "Good for newcomers" 2>/dev/null || true
gh label create "help wanted" --color "008672" --description "Extra attention is needed" 2>/dev/null || true

# 기본 이슈 템플릿 생성
mkdir -p .github/ISSUE_TEMPLATE
cat > .github/ISSUE_TEMPLATE/bug_report.yml << 'BUGEOF'
name: 🐛 Bug Report
description: File a bug report
title: "[Bug]: "
labels: ["bug"]
body:
  - type: markdown
    attributes:
      value: |
        Thanks for taking the time to fill out this bug report!
  - type: textarea
    id: what-happened
    attributes:
      label: What happened?
      description: Also tell us, what did you expect to happen?
      placeholder: Tell us what you see!
    validations:
      required: true
  - type: dropdown
    id: version
    attributes:
      label: Version
      description: What version are you running?
      options:
        - latest
        - v1.0.0
    validations:
      required: true
BUGEOF

echo "✅ 리포지토리 '$REPO_NAME'이 성공적으로 생성되었습니다!"
echo "🔗 $(gh repo view --json url -q .url)"
EOF

chmod +x ~/scripts/github-cli/project/templates/create-repo-with-template.sh
```

### 3. 워크플로우 자동화 스크립트

```bash
# 일일 작업 보고서 생성
cat > ~/scripts/github-cli/system/daily-report.sh << 'EOF'
#!/bin/bash

# 일일 GitHub 활동 보고서 생성
DATE=$(date '+%Y-%m-%d')
REPORT_FILE="$HOME/Documents/github-automation/daily-report-$DATE.md"

mkdir -p "$(dirname "$REPORT_FILE")"

cat > "$REPORT_FILE" << REPORTHEADER
# GitHub 일일 활동 보고서
**날짜**: $DATE  
**계정**: $(cat ~/.config/gh/current_context 2>/dev/null || echo 'Unknown')

## 📊 오늘의 활동 요약
REPORTHEADER

# 오늘 생성한 이슈
echo "### 생성한 이슈" >> "$REPORT_FILE"
gh issue list --author @me --search "created:$DATE" --limit 10 --json number,title,url | \
    jq -r '.[] | "- [#\(.number)](\(.url)) \(.title)"' >> "$REPORT_FILE" 2>/dev/null || \
    echo "- 생성한 이슈가 없습니다." >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"

# 오늘 닫은 이슈
echo "### 완료한 이슈" >> "$REPORT_FILE"
gh issue list --assignee @me --state closed --search "closed:$DATE" --limit 10 --json number,title,url | \
    jq -r '.[] | "- [#\(.number)](\(.url)) \(.title)"' >> "$REPORT_FILE" 2>/dev/null || \
    echo "- 완료한 이슈가 없습니다." >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"

# 오늘의 PR
echo "### Pull Requests" >> "$REPORT_FILE"
gh pr list --author @me --search "created:$DATE" --limit 10 --json number,title,url | \
    jq -r '.[] | "- [#\(.number)](\(.url)) \(.title)"' >> "$REPORT_FILE" 2>/dev/null || \
    echo "- 생성한 PR이 없습니다." >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"

# 리뷰한 PR
echo "### 리뷰한 Pull Requests" >> "$REPORT_FILE"
gh api "search/issues?q=reviewed-by:@me+type:pr+updated:$DATE" | \
    jq -r '.items[] | "- [#\(.number)](\(.html_url)) \(.title)"' >> "$REPORT_FILE" 2>/dev/null || \
    echo "- 리뷰한 PR이 없습니다." >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"

# 진행 중인 작업
echo "### 🔄 진행 중인 작업" >> "$REPORT_FILE"
gh issue list --assignee @me --state open --limit 5 --json number,title,url | \
    jq -r '.[] | "- [#\(.number)](\(.url)) \(.title)"' >> "$REPORT_FILE" 2>/dev/null || \
    echo "- 진행 중인 이슈가 없습니다." >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "*이 보고서는 자동으로 생성되었습니다.*" >> "$REPORT_FILE"

echo "✅ 일일 보고서가 생성되었습니다: $REPORT_FILE"
cat "$REPORT_FILE"
EOF

chmod +x ~/scripts/github-cli/system/daily-report.sh
```

## 계정별 워크스페이스 분리

### 1. 지능형 디렉토리 관리

```bash
# 컨텍스트 관리 스크립트 생성
cat > ~/scripts/github-cli/core/context.sh << 'EOF'
#!/bin/bash

# 워크스페이스 컨텍스트 관리 함수들

function workspace_init() {
    local context="$1"
    
    case "$context" in
        "work")
            cd "$WORK_DIR"
            gh-account work
            echo "🏢 회사 워크스페이스로 전환되었습니다."
            echo "📂 위치: $WORK_DIR"
            ls -la
            ;;
        "personal")
            cd "$PERSONAL_DIR"
            gh-account personal
            echo "👤 개인 워크스페이스로 전환되었습니다."
            echo "📂 위치: $PERSONAL_DIR"
            ls -la
            ;;
        *)
            echo "사용법: workspace_init [work|personal]"
            ;;
    esac
}

# 현재 워크스페이스 표시
function current_workspace() {
    local pwd_path="$(pwd)"
    if [[ "$pwd_path" == "$WORK_DIR"* ]]; then
        echo "🏢 Work"
    elif [[ "$pwd_path" == "$PERSONAL_DIR"* ]]; then
        echo "👤 Personal"
    else
        echo "📁 Other"
    fi
}
EOF

chmod +x ~/scripts/github-cli/core/context.sh

# 워크스페이스 alias를 .zshrc에 추가
cat >> ~/.zshrc << 'EOF'

# 단축 alias
alias work="workspace_init work"
alias personal="workspace_init personal"

# 프롬프트에 워크스페이스 정보 추가
PROMPT='$(current_workspace) '$PROMPT
EOF

source ~/.zshrc
```

### 2. 프로젝트별 설정 자동화

```bash
# 프로젝트별 환경 설정 자동화
cat > ~/scripts/github-cli/core/utils.sh << 'EOF'
#!/bin/bash

# 프로젝트별 Git 설정 자동화
# .git/hooks/post-checkout 에서 자동 실행

CURRENT_DIR="$(pwd)"
CONTEXT=""

# 워크스페이스 감지
if [[ "$CURRENT_DIR" == *"/work/"* ]]; then
    CONTEXT="work"
elif [[ "$CURRENT_DIR" == *"/personal/"* ]]; then
    CONTEXT="personal"
fi

# Git 설정 적용
case "$CONTEXT" in
    "work")
        git config user.email "your-work-email@company.com"
        git config user.name "Your Work Name"
        echo "🏢 회사 Git 설정이 적용되었습니다."
        ;;
    "personal")
        git config user.email "your-personal-email@gmail.com"
        git config user.name "Your Personal Name"
        echo "👤 개인 Git 설정이 적용되었습니다."
        ;;
esac

# GitHub CLI 컨텍스트 설정
if [[ -n "$CONTEXT" ]]; then
    echo "$CONTEXT" > ~/.config/gh/current_context
    echo "GitHub CLI 컨텍스트: $CONTEXT"
fi
EOF

chmod +x ~/scripts/github-cli/core/utils.sh
```

## 다음 편 미리보기

다음 편 **[이슈 관리 완전 자동화](macos-github-cli-issue-automation-guide)**에서는:

- 지능형 이슈 생성 및 분류 시스템
- 자동 라벨링 및 담당자 할당  
- 이슈 템플릿 동적 생성
- 워크플로우 기반 이슈 상태 관리
- 스프린트 계획 자동화

---

## 이 시리즈의 다른 글 보기

- **1편: 설치와 환경 구성** ← 현재 위치
- [2편: 이슈 관리 완전 자동화](macos-github-cli-issue-automation-guide)
- [3편: 프로젝트 관리 + 회사/개인 프로젝트 분리](github-cli-project-management-automation)  
- [4편: 위키 관리 완전 자동화](github-cli-wiki-automation-guide)
- [5편: 고급 워크플로우와 실무 적용](github-cli-advanced-workflows) 