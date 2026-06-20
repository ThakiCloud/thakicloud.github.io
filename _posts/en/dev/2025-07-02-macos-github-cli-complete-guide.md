---
title: "macOS GitHub CLI Full Automation Series - Part 1: Installation and Environment Setup"
excerpt: "Building a fully automated GitHub CLI environment on macOS: zshrc scripts, aliases, and one-click workflow configuration"
seo_title: "macOS GitHub CLI Full Automation Part 1 - Installation and Environment Setup - Thaki Cloud"
seo_description: "How to fully automate GitHub CLI on macOS: a step-by-step guide from Homebrew installation to advanced zshrc scripts and custom aliases for a professional-grade development environment"
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
toc_label: "Table of Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/en/dev/2025-07-02-macos-github-cli-complete-guide/"
lang: en
reading_time: true
---

⏱️ **Estimated reading time**: 20 min

## Series Overview

The **macOS GitHub CLI Full Automation Series** covers building an expert-level workflow that fully automates GitHub tasks from the terminal. We will build a system that handles everything from issue creation to project management and wiki writing with a single click.

This series covers **fully automated scripts**, **intelligent aliases**, and **separate management for work and personal projects** that you can use in real-world development. You will learn how to dramatically improve development productivity beyond simple CLI usage.

## Part 1: Building a Complete Development Environment

### Goals
- Build a fully automated GitHub CLI environment
- Configure advanced zshrc settings and intelligent aliases
- Set up a work/personal account separation management system
- Establish the foundation for one-click workflows

## Prerequisites

### Checking System Requirements

```bash
# Check macOS version (Big Sur 11.0 or later recommended)
sw_vers

# Check Xcode Command Line Tools installation
xcode-select --install

# Check shell (zsh is default)
echo $SHELL
```

### Initializing the Development Environment

```bash
# Create development directory structure
mkdir -p ~/Development/{work,personal}
mkdir -p ~/.config/gh
mkdir -p ~/Documents/github-automation

# Create integrated script directory (modular structure)
mkdir -p ~/scripts/github-cli/{core,issue,project,wiki,system}
mkdir -p ~/scripts/github-cli/project/templates
mkdir -p ~/scripts/github-cli/wiki/templates

# Create environment variable file
touch ~/.env.github
chmod 600 ~/.env.github
```

## Installing and Initially Configuring GitHub CLI

### 1. Advanced Homebrew Setup

```bash
# Install Homebrew (latest version)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Set Homebrew path (added automatically to .zshrc)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
source ~/.zshrc

# Install all required tools at once
brew install gh jq fzf bat exa ripgrep fd tree curl wget
brew install --cask visual-studio-code

# Verify installation
gh --version
jq --version
```

### 2. Fully Automating GitHub CLI Authentication

#### Creating a Multi-Account Management Script

```bash
# Multi-account management script
cat > ~/scripts/github-cli/core/auth.sh << 'EOF'
#!/bin/bash

# GitHub account management script
# Usage: gh-account [work|personal|list|current]

WORK_TOKEN_FILE="$HOME/.config/gh/work_token"
PERSONAL_TOKEN_FILE="$HOME/.config/gh/personal_token"
CURRENT_CONTEXT_FILE="$HOME/.config/gh/current_context"

function gh-account() {
    case "$1" in
        "work")
            if [[ -f "$WORK_TOKEN_FILE" ]]; then
                gh auth login --with-token < "$WORK_TOKEN_FILE"
                echo "work" > "$CURRENT_CONTEXT_FILE"
                echo "🏢 Switched to work account."
                gh auth status
            else
                echo "❌ Work account token is not configured."
                echo "Save your token to $WORK_TOKEN_FILE"
            fi
            ;;
        "personal")
            if [[ -f "$PERSONAL_TOKEN_FILE" ]]; then
                gh auth login --with-token < "$PERSONAL_TOKEN_FILE"
                echo "personal" > "$CURRENT_CONTEXT_FILE"
                echo "👤 Switched to personal account."
                gh auth status
            else
                echo "❌ Personal account token is not configured."
                echo "Save your token to $PERSONAL_TOKEN_FILE"
            fi
            ;;
        "current")
            if [[ -f "$CURRENT_CONTEXT_FILE" ]]; then
                CONTEXT=$(cat "$CURRENT_CONTEXT_FILE")
                echo "Current context: $CONTEXT"
                gh auth status
            else
                echo "No context has been set."
            fi
            ;;
        "list")
            echo "Available accounts:"
            [[ -f "$WORK_TOKEN_FILE" ]] && echo "  - work (work account)"
            [[ -f "$PERSONAL_TOKEN_FILE" ]] && echo "  - personal (personal account)"
            ;;
        *)
            echo "Usage: gh-account [work|personal|list|current]"
            ;;
    esac
}
EOF

chmod +x ~/scripts/github-cli/core/auth.sh
```

#### Token Setup Tool

```bash
# Token setup helper script
cat > ~/scripts/github-cli/core/setup-tokens.sh << 'EOF'
#!/bin/bash

echo "🔐 GitHub Token Setup Helper"
echo "=============================="
echo

# Work account token setup
echo "1️⃣ Work Account Token Setup"
echo "GitHub -> Settings -> Developer settings -> Personal access tokens -> Tokens (classic)"
echo "Required permissions: repo, workflow, write:packages, delete:packages, admin:org, admin:public_key, admin:repo_hook, admin:org_hook, gist, notifications, user, delete_repo, write:discussion, admin:enterprise"
echo
read -p "Enter your work account token: " WORK_TOKEN
echo "$WORK_TOKEN" > "$HOME/.config/gh/work_token"
chmod 600 "$HOME/.config/gh/work_token"
echo "✅ Work account token has been saved."
echo

# Personal account token setup
echo "2️⃣ Personal Account Token Setup"
read -p "Enter your personal account token: " PERSONAL_TOKEN
echo "$PERSONAL_TOKEN" > "$HOME/.config/gh/personal_token"
chmod 600 "$HOME/.config/gh/personal_token"
echo "✅ Personal account token has been saved."
echo

echo "🎉 Setup complete! Switch accounts with 'gh-account work' or 'gh-account personal'."
EOF

chmod +x ~/scripts/github-cli/core/setup-tokens.sh
```

## Advanced zshrc Configuration and Automation

### 1. Fully Automated zshrc Configuration

```bash
# Back up existing .zshrc
cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)

# Create new .zshrc
cat > ~/.zshrc << 'EOF'
# ===============================================
# GitHub CLI Full Automation Environment Setup
# Author: Thaki Cloud
# Version: 2.0
# ===============================================

# Homebrew setup
if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Oh My Zsh setup (optional)
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git github gh zsh-autosuggestions zsh-syntax-highlighting)

# Default environment variables
export EDITOR="code"
export BROWSER="open"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# GitHub CLI environment variables
export GITHUB_TOKEN_WORK="$(cat ~/.config/gh/work_token 2>/dev/null || echo '')"
export GITHUB_TOKEN_PERSONAL="$(cat ~/.config/gh/personal_token 2>/dev/null || echo '')"

# Development directories
export DEV_HOME="$HOME/Development"
export WORK_DIR="$DEV_HOME/work"
export PERSONAL_DIR="$DEV_HOME/personal"
export GITHUB_CLI_SCRIPTS="$HOME/scripts/github-cli"

# PATH setup
export PATH="$GITHUB_CLI_SCRIPTS:$HOME/.local/bin:$PATH"

# ===============================================
# GitHub CLI Functions
# ===============================================

# Modular script loading
source ~/scripts/github-cli/core/auth.sh
source ~/scripts/github-cli/core/context.sh 2>/dev/null || true
source ~/scripts/github-cli/core/utils.sh 2>/dev/null || true

# Display current GitHub context
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

# Add GitHub context to prompt
PROMPT='$(gh_context) '$PROMPT

# ===============================================
# Intelligent Alias System
# ===============================================

# Improved base commands
alias ls='exa --icons'
alias ll='exa -la --icons --git'
alias tree='exa --tree --icons'
alias cat='bat'
alias find='fd'
alias grep='rg'

# Enhanced git aliases
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

# GitHub CLI base aliases
alias ghis='gh issue list'
alias ghpr='gh pr list'
alias ghrepo='gh repo list'

# ===============================================
# Full Automation Functions
# ===============================================

# Smart repository clone
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
    
    echo "✅ Repository cloned into the $context directory."
}

# Issue-driven development workflow
function issue_start() {
    local issue_num="$1"
    local description="$2"
    
    if [[ -z "$issue_num" ]]; then
        echo "Usage: issue_start <issue-number> [description]"
        return 1
    fi
    
    # Fetch issue information
    local issue_info=$(gh issue view "$issue_num" --json title,body)
    local issue_title=$(echo "$issue_info" | jq -r '.title')
    
    # Generate branch name
    local branch_name="issue-${issue_num}"
    if [[ -n "$description" ]]; then
        branch_name="${branch_name}-$(echo "$description" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')"
    fi
    
    # Create and checkout branch
    git checkout -b "$branch_name"
    
    # Add comment to issue
    gh issue comment "$issue_num" --body "🚀 Work has started.

**Branch**: \`$branch_name\`
**Assignee**: $(gh api user -q .login)
**Start time**: $(date '+%Y-%m-%d %H:%M:%S')

---
_This comment was generated automatically._"
    
    echo "✅ Started work on issue #$issue_num."
    echo "📝 Title: $issue_title"
    echo "🌿 Branch: $branch_name"
}

# Complete issue and create PR
function issue_finish() {
    local issue_num="$1"
    local commit_message="$2"
    
    if [[ -z "$issue_num" ]]; then
        echo "Usage: issue_finish <issue-number> [commit-message]"
        return 1
    fi
    
    # Check current branch
    local current_branch=$(git branch --show-current)
    
    # Commit changes
    git add .
    if [[ -n "$commit_message" ]]; then
        git commit -m "$commit_message

Closes #$issue_num"
    else
        git commit -m "Fix #$issue_num: $(gh issue view $issue_num -q .title)

Closes #$issue_num"
    fi
    
    # Push branch
    git push -u origin "$current_branch"
    
    # Create PR
    local pr_body="## Changes

This PR resolves issue #$issue_num.

### Key Changes
- 

### How to Test
- 

### Checklist
- [x] Code written
- [ ] Test cases added
- [ ] Documentation updated
- [ ] Code review requested

---
Closes #$issue_num"
    
    gh pr create \
        --title "Fix #$issue_num: $(gh issue view $issue_num -q .title)" \
        --body "$pr_body" \
        --draft
    
    echo "✅ PR has been created."
    echo "🔗 PR link: $(gh pr view --json url -q .url)"
}

# Quick project creation
function create_project() {
    local project_name="$1"
    local project_desc="$2"
    
    if [[ -z "$project_name" ]]; then
        echo "Usage: create_project <project-name> [description]"
        return 1
    fi
    
    # Create project
    local project_url=$(gh project create \
        --title "$project_name" \
        --body "${project_desc:-$project_name project}" \
        --format json | jq -r '.url')
    
    echo "✅ Project created: $project_url"
}

# Quick wiki edit
function wiki_edit() {
    local page_name="$1"
    
    if [[ -z "$page_name" ]]; then
        echo "Usage: wiki_edit <page-name>"
        return 1
    fi
    
    # Clone wiki if not present
    if [[ ! -d ".wiki" ]]; then
        local repo_name=$(basename "$(git remote get-url origin)" .git)
        git clone "$(git remote get-url origin | sed 's/\.git$/.wiki.git/')" .wiki
    fi
    
    cd .wiki
    
    # Create or edit page file
    local file_name="${page_name}.md"
    if [[ ! -f "$file_name" ]]; then
        touch "$file_name"
    fi
    
    "$EDITOR" "$file_name"
    
    # Auto-commit and push
    git add "$file_name"
    git commit -m "docs: update $page_name page"
    git push origin master
    
    cd ..
    echo "✅ Wiki page '$page_name' has been updated."
}

# ===============================================
# Productivity Functions
# ===============================================

# GitHub dashboard
function gh_dashboard() {
    echo "🚀 GitHub Dashboard $(date '+%Y-%m-%d %H:%M')"
    echo "$(gh_context) $(cat ~/.config/gh/current_context 2>/dev/null || echo 'Unknown') account"
    echo "========================================"
    echo
    
    echo "📋 My assigned issues (latest 5):"
    gh issue list --assignee @me --state open --limit 5 || echo "  No assigned issues."
    echo
    
    echo "🔄 PRs requesting review:"
    gh pr list --search "review-requested:@me" --limit 5 || echo "  No PRs requesting review."
    echo
    
    echo "✅ Recently closed issues (3):"
    gh issue list --assignee @me --state closed --limit 3 || echo "  No recently closed issues."
    echo
    
    echo "📊 Open PRs:"
    gh pr list --author @me --state open --limit 5 || echo "  No open PRs."
}

# Quick issue creation
function quick_issue() {
    local title="$1"
    local body="$2"
    local labels="$3"
    
    if [[ -z "$title" ]]; then
        echo "Usage: quick_issue <title> [body] [label1,label2]"
        return 1
    fi
    
    local issue_body="${body:-## Description

Please write a detailed description of the issue.

## Steps to Reproduce

1. 
2. 
3. 

## Expected Result


## Actual Result


## Additional Information

}"
    
    local created_issue=$(gh issue create \
        --title "$title" \
        --body "$issue_body" \
        ${labels:+--label "$labels"} \
        --format json)
    
    local issue_number=$(echo "$created_issue" | jq -r '.number')
    local issue_url=$(echo "$created_issue" | jq -r '.url')
    
    echo "✅ Issue created:"
    echo "📝 #$issue_number: $title"
    echo "🔗 $issue_url"
    
    # Ask whether to start work immediately
    read -p "Would you like to start working on this right away? (y/N): " start_work
    if [[ "$start_work" =~ ^[Yy]$ ]]; then
        issue_start "$issue_number"
    fi
}

# Quick development environment setup
function dev_setup() {
    local repo_url="$1"
    
    if [[ -z "$repo_url" ]]; then
        echo "Usage: dev_setup <repository-URL>"
        return 1
    fi
    
    # Smart clone
    gclone "$repo_url"
    
    # Auto-configure development environment
    if [[ -f "package.json" ]]; then
        echo "📦 Node.js project detected, installing dependencies..."
        npm install
    elif [[ -f "requirements.txt" ]]; then
        echo "🐍 Python project detected, setting up virtual environment and installing dependencies..."
        python -m venv venv
        source venv/bin/activate
        pip install -r requirements.txt
    elif [[ -f "Gemfile" ]]; then
        echo "💎 Ruby project detected, installing dependencies..."
        bundle install
    fi
    
    # Open in VS Code
    code .
    
    echo "✅ Development environment setup complete!"
}

# ===============================================
# Autocomplete Setup
# ===============================================

# fzf setup
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# GitHub CLI autocomplete
if command -v gh >/dev/null 2>&1; then
    eval "$(gh completion -s zsh)"
fi

# ===============================================
# Run on Startup
# ===============================================

# Environment check
function check_github_env() {
    if ! command -v gh >/dev/null 2>&1; then
        echo "⚠️  GitHub CLI is not installed."
        echo "   Install it with: brew install gh"
    elif ! gh auth status >/dev/null 2>&1; then
        echo "⚠️  GitHub CLI authentication is required."
        echo "   Set up your account with the gh-account command."
    fi
}

# Check environment on startup (silently)
check_github_env 2>/dev/null

# Welcome message
echo "🚀 GitHub CLI full automation environment loaded!"
echo "💡 Run 'gh_dashboard' to check your current status."

# Load Oh My Zsh (if installed)
[[ -f "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"
EOF

# Reload .zshrc
source ~/.zshrc
```

### 2. Advanced Script Directory Structure

```bash
# Project template creation script
cat > ~/scripts/github-cli/project/templates/create-repo-with-template.sh << 'EOF'
#!/bin/bash

# Create a repository from a template with initial setup
# Usage: create-repo-with-template.sh <repo-name> <template-type> [visibility]

REPO_NAME="$1"
TEMPLATE_TYPE="$2"
VISIBILITY="${3:-public}"

if [[ -z "$REPO_NAME" || -z "$TEMPLATE_TYPE" ]]; then
    echo "Usage: $0 <repo-name> <template-type> [public|private]"
    echo "Template types: react, node, python, ruby, docs, minimal"
    exit 1
fi

# Check current context
CONTEXT=$(cat ~/.config/gh/current_context 2>/dev/null || echo 'personal')
echo "🔧 Creating repository under the $CONTEXT account."

# Create repository
echo "📦 Creating repository..."
gh repo create "$REPO_NAME" \
    --"$VISIBILITY" \
    --description "Auto-generated $TEMPLATE_TYPE project" \
    --gitignore "$TEMPLATE_TYPE" \
    --license mit \
    --clone

cd "$REPO_NAME"

# Generate initial files by template type
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

Project documentation

## Table of Contents

- [Installation](docs/installation.md)
- [Usage](docs/usage.md)
- [API](docs/api.md)
DOCEOF
        ;;
    *)
        echo "# $REPO_NAME" > README.md
        ;;
esac

# Initial commit
git add .
git commit -m "🎉 Initial commit with $TEMPLATE_TYPE template"
git push -u origin main

# Create default labels
gh label create "bug" --color "d73a4a" --description "Something isn't working" 2>/dev/null || true
gh label create "enhancement" --color "a2eeef" --description "New feature or request" 2>/dev/null || true
gh label create "documentation" --color "0075ca" --description "Improvements or additions to documentation" 2>/dev/null || true
gh label create "good first issue" --color "7057ff" --description "Good for newcomers" 2>/dev/null || true
gh label create "help wanted" --color "008672" --description "Extra attention is needed" 2>/dev/null || true

# Create default issue templates
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

echo "✅ Repository '$REPO_NAME' was created successfully!"
echo "🔗 $(gh repo view --json url -q .url)"
EOF

chmod +x ~/scripts/github-cli/project/templates/create-repo-with-template.sh
```

### 3. Workflow Automation Script

```bash
# Generate daily activity report
cat > ~/scripts/github-cli/system/daily-report.sh << 'EOF'
#!/bin/bash

# Generate daily GitHub activity report
DATE=$(date '+%Y-%m-%d')
REPORT_FILE="$HOME/Documents/github-automation/daily-report-$DATE.md"

mkdir -p "$(dirname "$REPORT_FILE")"

cat > "$REPORT_FILE" << REPORTHEADER
# GitHub Daily Activity Report
**Date**: $DATE  
**Account**: $(cat ~/.config/gh/current_context 2>/dev/null || echo 'Unknown')

## 📊 Today's Activity Summary
REPORTHEADER

# Issues created today
echo "### Issues Created" >> "$REPORT_FILE"
gh issue list --author @me --search "created:$DATE" --limit 10 --json number,title,url | \
    jq -r '.[] | "- [#\(.number)](\(.url)) \(.title)"' >> "$REPORT_FILE" 2>/dev/null || \
    echo "- No issues created." >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"

# Issues closed today
echo "### Issues Completed" >> "$REPORT_FILE"
gh issue list --assignee @me --state closed --search "closed:$DATE" --limit 10 --json number,title,url | \
    jq -r '.[] | "- [#\(.number)](\(.url)) \(.title)"' >> "$REPORT_FILE" 2>/dev/null || \
    echo "- No issues completed." >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"

# PRs today
echo "### Pull Requests" >> "$REPORT_FILE"
gh pr list --author @me --search "created:$DATE" --limit 10 --json number,title,url | \
    jq -r '.[] | "- [#\(.number)](\(.url)) \(.title)"' >> "$REPORT_FILE" 2>/dev/null || \
    echo "- No PRs created." >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"

# PRs reviewed
echo "### Pull Requests Reviewed" >> "$REPORT_FILE"
gh api "search/issues?q=reviewed-by:@me+type:pr+updated:$DATE" | \
    jq -r '.items[] | "- [#\(.number)](\(.html_url)) \(.title)"' >> "$REPORT_FILE" 2>/dev/null || \
    echo "- No PRs reviewed." >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"

# Work in progress
echo "### 🔄 Work in Progress" >> "$REPORT_FILE"
gh issue list --assignee @me --state open --limit 5 --json number,title,url | \
    jq -r '.[] | "- [#\(.number)](\(.url)) \(.title)"' >> "$REPORT_FILE" 2>/dev/null || \
    echo "- No issues in progress." >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "*This report was generated automatically.*" >> "$REPORT_FILE"

echo "✅ Daily report generated: $REPORT_FILE"
cat "$REPORT_FILE"
EOF

chmod +x ~/scripts/github-cli/system/daily-report.sh
```

## Separating Workspaces by Account

### 1. Intelligent Directory Management

```bash
# Create context management script
cat > ~/scripts/github-cli/core/context.sh << 'EOF'
#!/bin/bash

# Workspace context management functions

function workspace_init() {
    local context="$1"
    
    case "$context" in
        "work")
            cd "$WORK_DIR"
            gh-account work
            echo "🏢 Switched to work workspace."
            echo "📂 Location: $WORK_DIR"
            ls -la
            ;;
        "personal")
            cd "$PERSONAL_DIR"
            gh-account personal
            echo "👤 Switched to personal workspace."
            echo "📂 Location: $PERSONAL_DIR"
            ls -la
            ;;
        *)
            echo "Usage: workspace_init [work|personal]"
            ;;
    esac
}

# Display current workspace
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

# Add workspace aliases to .zshrc
cat >> ~/.zshrc << 'EOF'

# Shortcut aliases
alias work="workspace_init work"
alias personal="workspace_init personal"

# Add workspace info to prompt
PROMPT='$(current_workspace) '$PROMPT
EOF

source ~/.zshrc
```

### 2. Per-Project Configuration Automation

```bash
# Per-project environment configuration automation
cat > ~/scripts/github-cli/core/utils.sh << 'EOF'
#!/bin/bash

# Per-project Git configuration automation
# Runs automatically from .git/hooks/post-checkout

CURRENT_DIR="$(pwd)"
CONTEXT=""

# Detect workspace
if [[ "$CURRENT_DIR" == *"/work/"* ]]; then
    CONTEXT="work"
elif [[ "$CURRENT_DIR" == *"/personal/"* ]]; then
    CONTEXT="personal"
fi

# Apply Git configuration
case "$CONTEXT" in
    "work")
        git config user.email "your-work-email@company.com"
        git config user.name "Your Work Name"
        echo "🏢 Work Git configuration applied."
        ;;
    "personal")
        git config user.email "your-personal-email@gmail.com"
        git config user.name "Your Personal Name"
        echo "👤 Personal Git configuration applied."
        ;;
esac

# Set GitHub CLI context
if [[ -n "$CONTEXT" ]]; then
    echo "$CONTEXT" > ~/.config/gh/current_context
    echo "GitHub CLI context: $CONTEXT"
fi
EOF

chmod +x ~/scripts/github-cli/core/utils.sh
```

## Preview of the Next Part

In the next part, **[Full Issue Management Automation](macos-github-cli-issue-automation-guide)**, we will cover:

- Intelligent issue creation and classification system
- Automatic labeling and assignee assignment
- Dynamic issue template generation
- Workflow-based issue status management
- Sprint planning automation

---

## Other Posts in This Series

- **Part 1: Installation and Environment Setup** (current)
- [Part 2: Full Issue Management Automation](macos-github-cli-issue-automation-guide)
- [Part 3: Project Management and Work/Personal Project Separation](github-cli-project-management-automation)
- [Part 4: Full Wiki Management Automation](github-cli-wiki-automation-guide)
- [Part 5: Advanced Workflows and Real-World Application](github-cli-advanced-workflows)
