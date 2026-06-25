---
title: "سلسلة الأتمتة الكاملة لـ GitHub CLI على macOS - الجزء الأول: التثبيت وإعداد البيئة"
excerpt: "بناء بيئة أتمتة كاملة لـ GitHub CLI على macOS: نصوص zshrc، والاختصارات alias، وإعداد سير عمل بنقرة واحدة"
seo_title: "أتمتة GitHub CLI الكاملة على macOS - الجزء الأول: التثبيت والإعداد - Thaki Cloud"
seo_description: "كيفية أتمتة GitHub CLI بالكامل على macOS: دليل خطوة بخطوة من تثبيت Homebrew إلى نصوص zshrc المتقدمة والاختصارات المخصصة لبناء بيئة تطوير احترافية"
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
toc_label: "جدول المحتويات"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/ar/dev/2025-07-02-macos-github-cli-complete-guide/"
lang: ar
reading_time: true
published: false
---

⏱️ **وقت القراءة المقدر**: 20 دقيقة

## نظرة عامة على السلسلة

تتناول **سلسلة الأتمتة الكاملة لـ GitHub CLI على macOS** بناء سير عمل احترافي يُؤتمت مهام GitHub بالكامل من الطرفية. سنبني نظاماً يتعامل مع كل شيء بدءاً من إنشاء Issues وحتى إدارة المشاريع وكتابة Wiki بنقرة واحدة.

تتضمن هذه السلسلة **نصوص أتمتة كاملة**، **اختصارات alias ذكية**، و**إدارة منفصلة لمشاريع العمل والمشاريع الشخصية** صالحة للاستخدام في بيئات التطوير الفعلية. ستتعلم كيفية تحسين إنتاجية التطوير بشكل جوهري بما يتجاوز الاستخدام البسيط لـ CLI.

## الجزء الأول: بناء بيئة تطوير متكاملة

### الأهداف
- بناء بيئة أتمتة كاملة لـ GitHub CLI
- ضبط إعدادات zshrc المتقدمة وتكوين اختصارات alias الذكية
- إعداد نظام فصل إدارة حسابات العمل والحسابات الشخصية
- تأسيس قاعدة لسير عمل بنقرة واحدة

## المتطلبات الأساسية

### التحقق من متطلبات النظام

```bash
# التحقق من إصدار macOS (يُوصى بـ Big Sur 11.0 أو أحدث)
sw_vers

# التحقق من تثبيت Xcode Command Line Tools
xcode-select --install

# التحقق من الـ shell (zsh هو الافتراضي)
echo $SHELL
```

### تهيئة بيئة التطوير

```bash
# إنشاء هيكل مجلدات التطوير
mkdir -p ~/Development/{work,personal}
mkdir -p ~/.config/gh
mkdir -p ~/Documents/github-automation

# إنشاء مجلد النصوص المتكاملة (هيكل وحدوي)
mkdir -p ~/scripts/github-cli/{core,issue,project,wiki,system}
mkdir -p ~/scripts/github-cli/project/templates
mkdir -p ~/scripts/github-cli/wiki/templates

# إنشاء ملف متغيرات البيئة
touch ~/.env.github
chmod 600 ~/.env.github
```

## تثبيت GitHub CLI والإعداد الأولي

### 1. إعداد Homebrew المتقدم

```bash
# تثبيت Homebrew (أحدث إصدار)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# ضبط مسار Homebrew (يُضاف تلقائياً إلى .zshrc)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
source ~/.zshrc

# تثبيت جميع الأدوات المطلوبة دفعة واحدة
brew install gh jq fzf bat exa ripgrep fd tree curl wget
brew install --cask visual-studio-code

# التحقق من التثبيت
gh --version
jq --version
```

### 2. الأتمتة الكاملة لمصادقة GitHub CLI

#### إنشاء نص إدارة حسابات متعددة

```bash
# نص إدارة الحسابات المتعددة
cat > ~/scripts/github-cli/core/auth.sh << 'EOF'
#!/bin/bash

# نص إدارة حسابات GitHub
# الاستخدام: gh-account [work|personal|list|current]

WORK_TOKEN_FILE="$HOME/.config/gh/work_token"
PERSONAL_TOKEN_FILE="$HOME/.config/gh/personal_token"
CURRENT_CONTEXT_FILE="$HOME/.config/gh/current_context"

function gh-account() {
    case "$1" in
        "work")
            if [[ -f "$WORK_TOKEN_FILE" ]]; then
                gh auth login --with-token < "$WORK_TOKEN_FILE"
                echo "work" > "$CURRENT_CONTEXT_FILE"
                echo "🏢 تم التبديل إلى حساب العمل."
                gh auth status
            else
                echo "❌ لم يتم تكوين token حساب العمل."
                echo "احفظ الـ token في $WORK_TOKEN_FILE"
            fi
            ;;
        "personal")
            if [[ -f "$PERSONAL_TOKEN_FILE" ]]; then
                gh auth login --with-token < "$PERSONAL_TOKEN_FILE"
                echo "personal" > "$CURRENT_CONTEXT_FILE"
                echo "👤 تم التبديل إلى الحساب الشخصي."
                gh auth status
            else
                echo "❌ لم يتم تكوين token الحساب الشخصي."
                echo "احفظ الـ token في $PERSONAL_TOKEN_FILE"
            fi
            ;;
        "current")
            if [[ -f "$CURRENT_CONTEXT_FILE" ]]; then
                CONTEXT=$(cat "$CURRENT_CONTEXT_FILE")
                echo "السياق الحالي: $CONTEXT"
                gh auth status
            else
                echo "لم يتم تعيين أي سياق."
            fi
            ;;
        "list")
            echo "الحسابات المتاحة:"
            [[ -f "$WORK_TOKEN_FILE" ]] && echo "  - work (حساب العمل)"
            [[ -f "$PERSONAL_TOKEN_FILE" ]] && echo "  - personal (الحساب الشخصي)"
            ;;
        *)
            echo "الاستخدام: gh-account [work|personal|list|current]"
            ;;
    esac
}
EOF

chmod +x ~/scripts/github-cli/core/auth.sh
```

#### أداة إعداد الـ Token

```bash
# نص مساعد لإعداد الـ token
cat > ~/scripts/github-cli/core/setup-tokens.sh << 'EOF'
#!/bin/bash

echo "🔐 مساعد إعداد GitHub Token"
echo "=============================="
echo

# إعداد token حساب العمل
echo "1️⃣ إعداد token حساب العمل"
echo "GitHub -> Settings -> Developer settings -> Personal access tokens -> Tokens (classic)"
echo "الصلاحيات المطلوبة: repo, workflow, write:packages, delete:packages, admin:org, admin:public_key, admin:repo_hook, admin:org_hook, gist, notifications, user, delete_repo, write:discussion, admin:enterprise"
echo
read -p "أدخل token حساب العمل: " WORK_TOKEN
echo "$WORK_TOKEN" > "$HOME/.config/gh/work_token"
chmod 600 "$HOME/.config/gh/work_token"
echo "✅ تم حفظ token حساب العمل."
echo

# إعداد token الحساب الشخصي
echo "2️⃣ إعداد token الحساب الشخصي"
read -p "أدخل token الحساب الشخصي: " PERSONAL_TOKEN
echo "$PERSONAL_TOKEN" > "$HOME/.config/gh/personal_token"
chmod 600 "$HOME/.config/gh/personal_token"
echo "✅ تم حفظ token الحساب الشخصي."
echo

echo "🎉 اكتمل الإعداد! بدّل بين الحسابات باستخدام 'gh-account work' أو 'gh-account personal'."
EOF

chmod +x ~/scripts/github-cli/core/setup-tokens.sh
```

## إعداد zshrc المتقدم والأتمتة

### 1. تكوين zshrc للأتمتة الكاملة

```bash
# نسخ احتياطي من .zshrc الحالي
cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)

# إنشاء .zshrc جديد
cat > ~/.zshrc << 'EOF'
# ===============================================
# إعداد بيئة الأتمتة الكاملة لـ GitHub CLI
# Author: Thaki Cloud
# Version: 2.0
# ===============================================

# إعداد Homebrew
if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# إعداد Oh My Zsh (اختياري)
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git github gh zsh-autosuggestions zsh-syntax-highlighting)

# متغيرات البيئة الأساسية
export EDITOR="code"
export BROWSER="open"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# متغيرات بيئة GitHub CLI
export GITHUB_TOKEN_WORK="$(cat ~/.config/gh/work_token 2>/dev/null || echo '')"
export GITHUB_TOKEN_PERSONAL="$(cat ~/.config/gh/personal_token 2>/dev/null || echo '')"

# مجلدات التطوير
export DEV_HOME="$HOME/Development"
export WORK_DIR="$DEV_HOME/work"
export PERSONAL_DIR="$DEV_HOME/personal"
export GITHUB_CLI_SCRIPTS="$HOME/scripts/github-cli"

# إعداد PATH
export PATH="$GITHUB_CLI_SCRIPTS:$HOME/.local/bin:$PATH"

# ===============================================
# دوال GitHub CLI
# ===============================================

# تحميل النصوص الوحدوية
source ~/scripts/github-cli/core/auth.sh
source ~/scripts/github-cli/core/context.sh 2>/dev/null || true
source ~/scripts/github-cli/core/utils.sh 2>/dev/null || true

# عرض سياق GitHub الحالي
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

# إضافة سياق GitHub إلى موجه الأوامر
PROMPT='$(gh_context) '$PROMPT

# ===============================================
# نظام اختصارات alias الذكي
# ===============================================

# أوامر أساسية محسّنة
alias ls='exa --icons'
alias ll='exa -la --icons --git'
alias tree='exa --tree --icons'
alias cat='bat'
alias find='fd'
alias grep='rg'

# اختصارات git المحسّنة
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

# اختصارات GitHub CLI الأساسية
alias ghis='gh issue list'
alias ghpr='gh pr list'
alias ghrepo='gh repo list'

# ===============================================
# دوال الأتمتة الكاملة
# ===============================================

# استنساخ مستودع ذكي
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
    
    echo "✅ تم استنساخ المستودع في مجلد $context."
}

# سير عمل التطوير المرتكز على Issues
function issue_start() {
    local issue_num="$1"
    local description="$2"
    
    if [[ -z "$issue_num" ]]; then
        echo "الاستخدام: issue_start <رقم-الـ-issue> [وصف]"
        return 1
    fi
    
    # جلب معلومات الـ issue
    local issue_info=$(gh issue view "$issue_num" --json title,body)
    local issue_title=$(echo "$issue_info" | jq -r '.title')
    
    # توليد اسم الـ branch
    local branch_name="issue-${issue_num}"
    if [[ -n "$description" ]]; then
        branch_name="${branch_name}-$(echo "$description" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')"
    fi
    
    # إنشاء الـ branch والتبديل إليه
    git checkout -b "$branch_name"
    
    # إضافة تعليق على الـ issue
    gh issue comment "$issue_num" --body "🚀 بدأ العمل.

**Branch**: \`$branch_name\`
**المسؤول**: $(gh api user -q .login)
**وقت البدء**: $(date '+%Y-%m-%d %H:%M:%S')

---
_تم توليد هذا التعليق تلقائياً._"
    
    echo "✅ بدأ العمل على issue رقم #$issue_num."
    echo "📝 العنوان: $issue_title"
    echo "🌿 الـ branch: $branch_name"
}

# إتمام الـ issue وإنشاء PR
function issue_finish() {
    local issue_num="$1"
    local commit_message="$2"
    
    if [[ -z "$issue_num" ]]; then
        echo "الاستخدام: issue_finish <رقم-الـ-issue> [رسالة-الـ-commit]"
        return 1
    fi
    
    # التحقق من الـ branch الحالي
    local current_branch=$(git branch --show-current)
    
    # حفظ التغييرات في commit
    git add .
    if [[ -n "$commit_message" ]]; then
        git commit -m "$commit_message

Closes #$issue_num"
    else
        git commit -m "Fix #$issue_num: $(gh issue view $issue_num -q .title)

Closes #$issue_num"
    fi
    
    # رفع الـ branch
    git push -u origin "$current_branch"
    
    # إنشاء PR
    local pr_body="## التغييرات

يحل هذا الـ PR الـ issue رقم #$issue_num.

### التعديلات الرئيسية
- 

### طريقة الاختبار
- 

### قائمة التحقق
- [x] اكتمل كتابة الكود
- [ ] إضافة حالات الاختبار
- [ ] تحديث التوثيق
- [ ] طلب مراجعة الكود

---
Closes #$issue_num"
    
    gh pr create \
        --title "Fix #$issue_num: $(gh issue view $issue_num -q .title)" \
        --body "$pr_body" \
        --draft
    
    echo "✅ تم إنشاء الـ PR."
    echo "🔗 رابط الـ PR: $(gh pr view --json url -q .url)"
}

# إنشاء مشروع سريع
function create_project() {
    local project_name="$1"
    local project_desc="$2"
    
    if [[ -z "$project_name" ]]; then
        echo "الاستخدام: create_project <اسم-المشروع> [وصف]"
        return 1
    fi
    
    # إنشاء المشروع
    local project_url=$(gh project create \
        --title "$project_name" \
        --body "${project_desc:-مشروع $project_name}" \
        --format json | jq -r '.url')
    
    echo "✅ تم إنشاء المشروع: $project_url"
}

# تعديل سريع للـ wiki
function wiki_edit() {
    local page_name="$1"
    
    if [[ -z "$page_name" ]]; then
        echo "الاستخدام: wiki_edit <اسم-الصفحة>"
        return 1
    fi
    
    # استنساخ الـ wiki إذا لم يكن موجوداً
    if [[ ! -d ".wiki" ]]; then
        local repo_name=$(basename "$(git remote get-url origin)" .git)
        git clone "$(git remote get-url origin | sed 's/\.git$/.wiki.git/')" .wiki
    fi
    
    cd .wiki
    
    # إنشاء ملف الصفحة أو تعديله
    local file_name="${page_name}.md"
    if [[ ! -f "$file_name" ]]; then
        touch "$file_name"
    fi
    
    "$EDITOR" "$file_name"
    
    # commit تلقائي ورفع
    git add "$file_name"
    git commit -m "docs: تحديث صفحة $page_name"
    git push origin master
    
    cd ..
    echo "✅ تم تحديث صفحة الـ wiki '$page_name'."
}

# ===============================================
# دوال تحسين الإنتاجية
# ===============================================

# لوحة تحكم GitHub
function gh_dashboard() {
    echo "🚀 لوحة تحكم GitHub $(date '+%Y-%m-%d %H:%M')"
    echo "$(gh_context) حساب $(cat ~/.config/gh/current_context 2>/dev/null || echo 'غير معروف')"
    echo "========================================"
    echo
    
    echo "📋 الـ issues المُسندة إليّ (آخر 5):"
    gh issue list --assignee @me --state open --limit 5 || echo "  لا توجد issues مُسندة."
    echo
    
    echo "🔄 الـ PRs التي تطلب مراجعتي:"
    gh pr list --search "review-requested:@me" --limit 5 || echo "  لا توجد PRs تطلب المراجعة."
    echo
    
    echo "✅ الـ issues المُغلقة مؤخراً (3):"
    gh issue list --assignee @me --state closed --limit 3 || echo "  لا توجد issues مُغلقة مؤخراً."
    echo
    
    echo "📊 الـ PRs الجارية:"
    gh pr list --author @me --state open --limit 5 || echo "  لا توجد PRs جارية."
}

# إنشاء issue سريع
function quick_issue() {
    local title="$1"
    local body="$2"
    local labels="$3"
    
    if [[ -z "$title" ]]; then
        echo "الاستخدام: quick_issue <عنوان> [محتوى] [تصنيف1,تصنيف2]"
        return 1
    fi
    
    local issue_body="${body:-## الوصف

اكتب وصفاً تفصيلياً للـ issue.

## خطوات إعادة الإنتاج

1. 
2. 
3. 

## النتيجة المتوقعة


## النتيجة الفعلية


## معلومات إضافية

}"
    
    local created_issue=$(gh issue create \
        --title "$title" \
        --body "$issue_body" \
        ${labels:+--label "$labels"} \
        --format json)
    
    local issue_number=$(echo "$created_issue" | jq -r '.number')
    local issue_url=$(echo "$created_issue" | jq -r '.url')
    
    echo "✅ تم إنشاء الـ issue:"
    echo "📝 #$issue_number: $title"
    echo "🔗 $issue_url"
    
    # السؤال عما إذا كان المستخدم يريد البدء فوراً
    read -p "هل تريد البدء في العمل عليه الآن؟ (y/N): " start_work
    if [[ "$start_work" =~ ^[Yy]$ ]]; then
        issue_start "$issue_number"
    fi
}

# إعداد بيئة تطوير سريع
function dev_setup() {
    local repo_url="$1"
    
    if [[ -z "$repo_url" ]]; then
        echo "الاستخدام: dev_setup <رابط-المستودع>"
        return 1
    fi
    
    # استنساخ ذكي
    gclone "$repo_url"
    
    # ضبط بيئة التطوير تلقائياً
    if [[ -f "package.json" ]]; then
        echo "📦 تم اكتشاف مشروع Node.js، جاري تثبيت الاعتماديات..."
        npm install
    elif [[ -f "requirements.txt" ]]; then
        echo "🐍 تم اكتشاف مشروع Python، جاري إعداد البيئة الافتراضية وتثبيت الاعتماديات..."
        python -m venv venv
        source venv/bin/activate
        pip install -r requirements.txt
    elif [[ -f "Gemfile" ]]; then
        echo "💎 تم اكتشاف مشروع Ruby، جاري تثبيت الاعتماديات..."
        bundle install
    fi
    
    # الفتح في VS Code
    code .
    
    echo "✅ اكتمل إعداد بيئة التطوير!"
}

# ===============================================
# إعداد الإكمال التلقائي
# ===============================================

# إعداد fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# إكمال تلقائي لـ GitHub CLI
if command -v gh >/dev/null 2>&1; then
    eval "$(gh completion -s zsh)"
fi

# ===============================================
# التشغيل عند بدء الجلسة
# ===============================================

# التحقق من البيئة
function check_github_env() {
    if ! command -v gh >/dev/null 2>&1; then
        echo "⚠️  لم يتم تثبيت GitHub CLI."
        echo "   ثبّته باستخدام: brew install gh"
    elif ! gh auth status >/dev/null 2>&1; then
        echo "⚠️  مصادقة GitHub CLI مطلوبة."
        echo "   أعدّ حسابك باستخدام أمر gh-account."
    fi
}

# التحقق من البيئة عند بدء الجلسة (بصمت)
check_github_env 2>/dev/null

# رسالة ترحيب
echo "🚀 تم تحميل بيئة الأتمتة الكاملة لـ GitHub CLI!"
echo "💡 نفّذ 'gh_dashboard' للاطلاع على وضعك الحالي."

# تحميل Oh My Zsh (إذا كان مثبتاً)
[[ -f "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"
EOF

# إعادة تحميل .zshrc
source ~/.zshrc
```

### 2. هيكل مجلد النصوص المتقدم

```bash
# نص إنشاء قالب مشروع
cat > ~/scripts/github-cli/project/templates/create-repo-with-template.sh << 'EOF'
#!/bin/bash

# إنشاء مستودع من قالب وإعداده مبدئياً
# الاستخدام: create-repo-with-template.sh <repo-name> <template-type> [visibility]

REPO_NAME="$1"
TEMPLATE_TYPE="$2"
VISIBILITY="${3:-public}"

if [[ -z "$REPO_NAME" || -z "$TEMPLATE_TYPE" ]]; then
    echo "الاستخدام: $0 <repo-name> <template-type> [public|private]"
    echo "أنواع القوالب: react, node, python, ruby, docs, minimal"
    exit 1
fi

# التحقق من السياق الحالي
CONTEXT=$(cat ~/.config/gh/current_context 2>/dev/null || echo 'personal')
echo "🔧 جاري إنشاء المستودع تحت حساب $CONTEXT."

# إنشاء المستودع
echo "📦 جاري إنشاء المستودع..."
gh repo create "$REPO_NAME" \
    --"$VISIBILITY" \
    --description "Auto-generated $TEMPLATE_TYPE project" \
    --gitignore "$TEMPLATE_TYPE" \
    --license mit \
    --clone

cd "$REPO_NAME"

# توليد الملفات الأولية حسب نوع القالب
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

توثيق المشروع

## جدول المحتويات

- [التثبيت](docs/installation.md)
- [الاستخدام](docs/usage.md)
- [API](docs/api.md)
DOCEOF
        ;;
    *)
        echo "# $REPO_NAME" > README.md
        ;;
esac

# الـ commit الأولي
git add .
git commit -m "🎉 Initial commit with $TEMPLATE_TYPE template"
git push -u origin main

# إنشاء التصنيفات الافتراضية
gh label create "bug" --color "d73a4a" --description "Something isn't working" 2>/dev/null || true
gh label create "enhancement" --color "a2eeef" --description "New feature or request" 2>/dev/null || true
gh label create "documentation" --color "0075ca" --description "Improvements or additions to documentation" 2>/dev/null || true
gh label create "good first issue" --color "7057ff" --description "Good for newcomers" 2>/dev/null || true
gh label create "help wanted" --color "008672" --description "Extra attention is needed" 2>/dev/null || true

# إنشاء قوالب issues الافتراضية
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

echo "✅ تم إنشاء المستودع '$REPO_NAME' بنجاح!"
echo "🔗 $(gh repo view --json url -q .url)"
EOF

chmod +x ~/scripts/github-cli/project/templates/create-repo-with-template.sh
```

### 3. نص أتمتة سير العمل

```bash
# توليد تقرير النشاط اليومي
cat > ~/scripts/github-cli/system/daily-report.sh << 'EOF'
#!/bin/bash

# توليد تقرير نشاط GitHub اليومي
DATE=$(date '+%Y-%m-%d')
REPORT_FILE="$HOME/Documents/github-automation/daily-report-$DATE.md"

mkdir -p "$(dirname "$REPORT_FILE")"

cat > "$REPORT_FILE" << REPORTHEADER
# تقرير نشاط GitHub اليومي
**التاريخ**: $DATE  
**الحساب**: $(cat ~/.config/gh/current_context 2>/dev/null || echo 'غير معروف')

## 📊 ملخص نشاط اليوم
REPORTHEADER

# الـ issues التي تم إنشاؤها اليوم
echo "### الـ Issues التي تم إنشاؤها" >> "$REPORT_FILE"
gh issue list --author @me --search "created:$DATE" --limit 10 --json number,title,url | \
    jq -r '.[] | "- [#\(.number)](\(.url)) \(.title)"' >> "$REPORT_FILE" 2>/dev/null || \
    echo "- لم يتم إنشاء أي issues." >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"

# الـ issues التي تم إغلاقها اليوم
echo "### الـ Issues المكتملة" >> "$REPORT_FILE"
gh issue list --assignee @me --state closed --search "closed:$DATE" --limit 10 --json number,title,url | \
    jq -r '.[] | "- [#\(.number)](\(.url)) \(.title)"' >> "$REPORT_FILE" 2>/dev/null || \
    echo "- لم تكتمل أي issues." >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"

# الـ PRs اليوم
echo "### Pull Requests" >> "$REPORT_FILE"
gh pr list --author @me --search "created:$DATE" --limit 10 --json number,title,url | \
    jq -r '.[] | "- [#\(.number)](\(.url)) \(.title)"' >> "$REPORT_FILE" 2>/dev/null || \
    echo "- لم يتم إنشاء أي PRs." >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"

# الـ PRs التي تمت مراجعتها
echo "### Pull Requests التي تمت مراجعتها" >> "$REPORT_FILE"
gh api "search/issues?q=reviewed-by:@me+type:pr+updated:$DATE" | \
    jq -r '.items[] | "- [#\(.number)](\(.html_url)) \(.title)"' >> "$REPORT_FILE" 2>/dev/null || \
    echo "- لم تتم مراجعة أي PRs." >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"

# الأعمال الجارية
echo "### 🔄 الأعمال الجارية" >> "$REPORT_FILE"
gh issue list --assignee @me --state open --limit 5 --json number,title,url | \
    jq -r '.[] | "- [#\(.number)](\(.url)) \(.title)"' >> "$REPORT_FILE" 2>/dev/null || \
    echo "- لا توجد issues جارية." >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "*تم توليد هذا التقرير تلقائياً.*" >> "$REPORT_FILE"

echo "✅ تم توليد التقرير اليومي: $REPORT_FILE"
cat "$REPORT_FILE"
EOF

chmod +x ~/scripts/github-cli/system/daily-report.sh
```

## فصل مساحات العمل حسب الحساب

### 1. الإدارة الذكية للمجلدات

```bash
# إنشاء نص إدارة السياق
cat > ~/scripts/github-cli/core/context.sh << 'EOF'
#!/bin/bash

# دوال إدارة سياق مساحة العمل

function workspace_init() {
    local context="$1"
    
    case "$context" in
        "work")
            cd "$WORK_DIR"
            gh-account work
            echo "🏢 تم التبديل إلى مساحة عمل العمل."
            echo "📂 الموقع: $WORK_DIR"
            ls -la
            ;;
        "personal")
            cd "$PERSONAL_DIR"
            gh-account personal
            echo "👤 تم التبديل إلى مساحة العمل الشخصية."
            echo "📂 الموقع: $PERSONAL_DIR"
            ls -la
            ;;
        *)
            echo "الاستخدام: workspace_init [work|personal]"
            ;;
    esac
}

# عرض مساحة العمل الحالية
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

# إضافة اختصارات مساحة العمل إلى .zshrc
cat >> ~/.zshrc << 'EOF'

# اختصارات مختصرة
alias work="workspace_init work"
alias personal="workspace_init personal"

# إضافة معلومات مساحة العمل إلى موجه الأوامر
PROMPT='$(current_workspace) '$PROMPT
EOF

source ~/.zshrc
```

### 2. أتمتة الإعداد لكل مشروع

```bash
# أتمتة إعداد بيئة كل مشروع
cat > ~/scripts/github-cli/core/utils.sh << 'EOF'
#!/bin/bash

# أتمتة إعداد Git لكل مشروع
# يُنفَّذ تلقائياً من .git/hooks/post-checkout

CURRENT_DIR="$(pwd)"
CONTEXT=""

# الكشف عن مساحة العمل
if [[ "$CURRENT_DIR" == *"/work/"* ]]; then
    CONTEXT="work"
elif [[ "$CURRENT_DIR" == *"/personal/"* ]]; then
    CONTEXT="personal"
fi

# تطبيق إعداد Git
case "$CONTEXT" in
    "work")
        git config user.email "your-work-email@company.com"
        git config user.name "Your Work Name"
        echo "🏢 تم تطبيق إعداد Git الخاص بالعمل."
        ;;
    "personal")
        git config user.email "your-personal-email@gmail.com"
        git config user.name "Your Personal Name"
        echo "👤 تم تطبيق إعداد Git الشخصي."
        ;;
esac

# ضبط سياق GitHub CLI
if [[ -n "$CONTEXT" ]]; then
    echo "$CONTEXT" > ~/.config/gh/current_context
    echo "سياق GitHub CLI: $CONTEXT"
fi
EOF

chmod +x ~/scripts/github-cli/core/utils.sh
```

## معاينة الجزء القادم

في الجزء القادم **[أتمتة إدارة Issues بالكامل](macos-github-cli-issue-automation-guide)**، سنتناول:

- نظام إنشاء Issues وتصنيفها بصورة ذكية
- الإسناد التلقائي للتصنيفات والمسؤولين
- التوليد الديناميكي لقوالب Issues
- إدارة حالة Issues بناءً على سير العمل
- أتمتة تخطيط Sprint

---

## مقالات أخرى في هذه السلسلة

- **الجزء الأول: التثبيت وإعداد البيئة** (الموقع الحالي)
- [الجزء الثاني: أتمتة إدارة Issues بالكامل](macos-github-cli-issue-automation-guide)
- [الجزء الثالث: إدارة المشاريع وفصل مشاريع العمل والمشاريع الشخصية](github-cli-project-management-automation)
- [الجزء الرابع: أتمتة إدارة Wiki بالكامل](github-cli-wiki-automation-guide)
- [الجزء الخامس: سير العمل المتقدم والتطبيق العملي](github-cli-advanced-workflows)
