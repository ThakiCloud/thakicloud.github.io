#!/bin/bash

# Git AI Commit Message Generator
# AI-Git-Narrator 대안 스크립트
# Ollama Qwen3 모델 사용

set -e

# 색상 정의
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 설정 변수
OLLAMA_MODEL="${OLLAMA_MODEL:-qwen2.5:7b}"
LANGUAGE="${GIT_AI_LANG:-ko}"
STYLE="${GIT_AI_STYLE:-conventional}"

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

# 도움말 표시
show_help() {
    echo "Git AI Commit Message Generator"
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  commit      Generate commit message from staged changes"
    echo "  pr          Generate PR description from branch changes"
    echo "  setup       Setup script for first time use"
    echo ""
    echo "Options:"
    echo "  --lang=ko|en|ja    Language for commit message (default: ko)"
    echo "  --style=simple|conventional|detailed    Message style (default: conventional)"
    echo "  --model=MODEL      Ollama model to use (default: qwen3:8b)"
    echo ""
    echo "Environment Variables:"
    echo "  OLLAMA_MODEL       Default model (qwen3:8b, qwen2.5:7b, etc.)"
    echo "  GIT_AI_LANG        Default language (ko, en, ja)"
    echo "  GIT_AI_STYLE       Default style (simple, conventional, detailed)"
    echo ""
    echo "Examples:"
    echo "  $0 commit                    # Generate Korean conventional commit"
    echo "  $0 commit --lang=en          # Generate English commit message"
    echo "  $0 pr                        # Generate PR description"
    echo "  $0 setup                     # First time setup"
}

# Ollama 서비스 확인
check_ollama() {
    if ! command -v ollama &> /dev/null; then
        log_error "Ollama가 설치되지 않았습니다."
        log_info "설치 방법: brew install ollama"
        exit 1
    fi
    
    if ! curl -s http://localhost:11434/api/tags &> /dev/null; then
        log_error "Ollama 서비스가 실행되지 않고 있습니다."
        log_info "다음 명령어로 시작하세요: brew services start ollama"
        exit 1
    fi
    
    if ! ollama list | grep -q "$OLLAMA_MODEL"; then
        log_error "모델 '$OLLAMA_MODEL'이 설치되지 않았습니다."
        log_info "다음 명령어로 설치하세요: ollama pull $OLLAMA_MODEL"
        exit 1
    fi
}

# Git 저장소 확인
check_git_repo() {
    if ! git rev-parse --git-dir &> /dev/null; then
        log_error "Git 저장소가 아닙니다."
        exit 1
    fi
}

# 언어별 프롬프트 생성
get_commit_prompt() {
    local lang=$1
    local style=$2
    
    case $lang in
        ko)
            case $style in
                conventional)
                    echo "다음 git diff를 분석하여 Conventional Commits 형식의 한국어 커밋 메시지를 생성해주세요. 
형식: type(scope): description
타입: feat, fix, docs, style, refactor, test, chore 중 선택
최대 72자 이내로 작성하고, 변경사항의 핵심만 간결하게 표현해주세요.
반드시 한국어로만 응답하고, 다른 언어(중국어, 영어 등)는 절대 사용하지 마세요."
                    ;;
                simple)
                    echo "다음 git diff를 분석하여 간단하고 명확한 한국어 커밋 메시지를 한 줄로 생성해주세요. 50자 이내로 작성하세요."
                    ;;
                detailed)
                    echo "다음 git diff를 분석하여 상세한 한국어 커밋 메시지를 생성해주세요. 제목(50자 이내)과 본문(상세 설명)으로 구성하세요."
                    ;;
            esac
            ;;
        en)
            case $style in
                conventional)
                    echo "Analyze the git diff and create a Conventional Commits format message.
Format: type(scope): description
Types: feat, fix, docs, style, refactor, test, chore
Keep under 72 characters and be concise."
                    ;;
                simple)
                    echo "Analyze the git diff and create a simple, clear commit message in one line. Keep under 50 characters."
                    ;;
                detailed)
                    echo "Analyze the git diff and create a detailed commit message with title (under 50 chars) and body (detailed explanation)."
                    ;;
            esac
            ;;
        ja)
            case $style in
                conventional)
                    echo "次のgit diffを分析して、Conventional Commits形式の日本語コミットメッセージを生成してください。
形式: type(scope): description
72文字以内で簡潔に表現してください。"
                    ;;
                simple)
                    echo "次のgit diffを分析して、シンプルで明確な日本語コミットメッセージを一行で生成してください。50文字以内で作成してください。"
                    ;;
                detailed)
                    echo "次のgit diffを分析して、詳細な日本語コミットメッセージを生成してください。タイトル（50文字以内）と本文（詳細説明）で構成してください。"
                    ;;
            esac
            ;;
    esac
}

# PR 설명 프롬프트 생성
get_pr_prompt() {
    local lang=$1
    
    case $lang in
        ko)
            echo "다음 git diff를 분석하여 Pull Request 설명을 한국어로 생성해주세요.
포함할 내용:
## 개요
- 변경사항의 목적과 배경

## 주요 변경사항
- 수정된 파일들과 핵심 변경내용

## 테스트
- 테스트 방법이나 확인사항

최대 500자 이내로 작성하세요."
            ;;
        en)
            echo "Analyze the git diff and create a Pull Request description in English.
Include:
## Overview
- Purpose and background of changes

## Key Changes
- Modified files and core changes

## Testing
- Testing methods or verification steps

Keep under 500 characters."
            ;;
        ja)
            echo "git diffを分析して、日本語でPull Request説明を生成してください。
含める内容:
## 概要
- 変更の目的と背景

## 主な変更点
- 修正されたファイルと主要な変更内容

## テスト
- テスト方法や確認事項

500文字以内で作成してください。"
            ;;
    esac
}

# 커밋 메시지 생성
generate_commit_message() {
    local lang=$1
    local style=$2
    
    log_info "Git diff 분석 중..."
    
    # 스테이징된 변경사항 확인
    if ! git diff --cached --quiet; then
        local git_diff=$(git diff --cached)
    elif ! git diff --quiet; then
        log_warning "스테이징된 변경사항이 없습니다. 워킹 디렉토리의 변경사항을 분석합니다."
        local git_diff=$(git diff)
    else
        log_error "분석할 변경사항이 없습니다."
        log_info "git add를 사용하여 변경사항을 스테이징하거나 파일을 수정하세요."
        exit 1
    fi
    
    local prompt=$(get_commit_prompt "$lang" "$style")
    
    log_info "AI 커밋 메시지 생성 중... (모델: $OLLAMA_MODEL)"
    
    # Git diff와 프롬프트를 결합하여 Ollama에 전송 (임시 파일 사용)
    local temp_file=$(mktemp)
    cat > "$temp_file" << EOF
$prompt

Git Diff:
\`\`\`
$git_diff
\`\`\`

응답은 커밋 메시지만 한 줄로 간결하게 출력하세요. 설명이나 부연설명은 절대 포함하지 마세요.
EOF
    
    local raw_response=$(timeout 30 bash -c "cat '$temp_file' | ollama run '$OLLAMA_MODEL' 2>/dev/null" || echo "")
    
    # 임시 파일 정리
    rm -f "$temp_file"
    
    if [ -n "$raw_response" ]; then
        # 응답에서 커밋 메시지만 추출 (첫 번째 유효한 라인)
        local commit_message=$(echo "$raw_response" | grep -E '^(feat|fix|docs|style|refactor|test|chore)' | head -1 | sed 's/[^가-힣a-zA-Z0-9:()_\-\s.]/ /g' | sed 's/  */ /g' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
        
        if [ -n "$commit_message" ]; then
            echo "$commit_message"
        else
            # fallback: 첫 번째 라인에서 특수문자를 공백으로 치환
            echo "$raw_response" | head -1 | sed 's/[^가-힣a-zA-Z0-9:()_\-\s.]/ /g' | sed 's/  */ /g' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' || echo "feat: 테스트 파일 추가"
        fi
    else
        log_error "커밋 메시지 생성에 실패했습니다."
        echo "feat: 테스트 파일 추가"
    fi
}

# PR 설명 생성
generate_pr_description() {
    local lang=$1
    
    log_info "브랜치 변경사항 분석 중..."
    
    # 현재 브랜치와 main/master 브랜치 간 차이 확인
    local main_branch="main"
    if git show-ref --verify --quiet refs/heads/master; then
        main_branch="master"
    fi
    
    if ! git rev-parse --verify "$main_branch" &> /dev/null; then
        log_error "main 또는 master 브랜치를 찾을 수 없습니다."
        exit 1
    fi
    
    local git_diff=$(git diff "$main_branch"...HEAD)
    
    if [ -z "$git_diff" ]; then
        log_error "분석할 브랜치 변경사항이 없습니다."
        exit 1
    fi
    
    local prompt=$(get_pr_prompt "$lang")
    
    log_info "AI PR 설명 생성 중... (모델: $OLLAMA_MODEL)"
    
    # 임시 파일을 사용하여 Git diff 특수 문자 문제 해결
    local temp_file=$(mktemp)
    cat > "$temp_file" << EOF
$prompt

Git Diff:
\`\`\`
$git_diff
\`\`\`

응답은 PR 설명만 출력하세요.
EOF
    
    local pr_description=$(cat "$temp_file" | ollama run "$OLLAMA_MODEL" 2>/dev/null)
    
    # 임시 파일 정리
    rm -f "$temp_file"
    
    if [ -n "$pr_description" ]; then
        echo "$pr_description"
    else
        log_error "PR 설명 생성에 실패했습니다."
        exit 1
    fi
}

# 스크립트 설정
setup_script() {
    log_info "Git AI Commit 설정 중..."
    
    # Homebrew를 통해 Ollama 설치
    if ! command -v ollama &> /dev/null; then
        log_info "Ollama 설치 중..."
        brew install ollama
        brew services start ollama
        sleep 3
    fi
    
    # Qwen3 모델 설치
    if ! ollama list | grep -q "qwen3:8b"; then
        log_info "Qwen3:8b 모델 다운로드 중..."
        ollama pull qwen3:8b
    fi
    
    # zshrc에 aliases 추가
    if ! grep -q "# Git AI Aliases" ~/.zshrc 2>/dev/null; then
        log_info "Shell aliases 추가 중..."
        cat >> ~/.zshrc << 'EOF'

# Git AI Aliases
alias gitmsg="git-ai-commit commit"
alias gitpr="git-ai-commit pr"
alias acommit="git-ai-commit commit | head -1"
alias smartcommit='msg=$(git-ai-commit commit | head -1) && if [ -n "$msg" ]; then echo "제안된 커밋 메시지: $msg" && read -p "이 메시지로 커밋하시겠습니까? (y/n): " response && if [[ "$response" =~ ^[Yy]$ ]]; then git commit -m "$msg"; else echo "커밋이 취소되었습니다."; fi; else echo "AI 커밋 메시지 생성에 실패했습니다."; fi'

echo "🤖 Git AI aliases loaded!"
EOF
        log_success "Shell aliases가 추가되었습니다."
    fi
    
    # 스크립트를 PATH에 추가
    local script_dir="$(dirname "$(readlink -f "$0")")"
    local script_name="$(basename "$0")"
    
    if [ ! -f "/usr/local/bin/$script_name" ]; then
        log_info "스크립트를 시스템 PATH에 추가 중..."
        sudo ln -sf "$script_dir/$script_name" "/usr/local/bin/$script_name"
    fi
    
    log_success "설정이 완료되었습니다!"
    echo ""
    echo "사용법:"
    echo "  gitmsg           # AI 커밋 메시지 생성"
    echo "  gitpr            # AI PR 설명 생성"
    echo "  smartcommit      # AI 메시지로 자동 커밋"
    echo ""
    echo "새 터미널을 열거나 'source ~/.zshrc'를 실행하세요."
}

# 명령행 인수 처리
while [[ $# -gt 0 ]]; do
    case $1 in
        --lang=*)
            LANGUAGE="${1#*=}"
            shift
            ;;
        --style=*)
            STYLE="${1#*=}"
            shift
            ;;
        --model=*)
            OLLAMA_MODEL="${1#*=}"
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            break
            ;;
    esac
done

# 메인 명령 처리
case "${1:-help}" in
    commit)
        check_ollama
        check_git_repo
        generate_commit_message "$LANGUAGE" "$STYLE"
        ;;
    pr)
        check_ollama
        check_git_repo
        generate_pr_description "$LANGUAGE"
        ;;
    setup)
        setup_script
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        log_error "알 수 없는 명령: $1"
        show_help
        exit 1
        ;;
esac 