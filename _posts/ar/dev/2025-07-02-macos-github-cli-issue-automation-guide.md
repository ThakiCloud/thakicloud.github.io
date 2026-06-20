---
title: "سلسلة أتمتة GitHub CLI الكاملة على macOS - الجزء الثاني: أتمتة إدارة المشكلات بالكامل"
excerpt: "من إنشاء المشكلات الذكي والوسوم التلقائية إلى تخطيط السبرينت - دليل احترافي لأتمتة كل جوانب إدارة مشكلات GitHub"
seo_title: "أتمتة GitHub CLI على macOS الجزء الثاني - أتمتة إدارة المشكلات - Thaki Cloud"
seo_description: "كيفية أتمتة سير عمل GitHub CLI بالكامل من إنشاء المشكلات والتصنيف إلى الوسوم وتعيين المسؤولين وتخطيط السبرينت. دليل شامل لبناء نظام ذكي لإدارة المشكلات."
date: 2025-07-02
last_modified_at: 2025-07-02
categories:
  - dev
tags:
  - github-cli
  - issue-management
  - automation
  - workflow
  - project-management
  - scripting
  - productivity
  - agile
  - sprint-planning
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/ar/dev/2025-07-02-macos-github-cli-issue-automation-guide/"
lang: ar
reading_time: true
---

⏱️ **وقت القراءة المقدر**: 25 دقيقة

## مقدمة السلسلة

هذا المقال هو الجزء الثاني من **سلسلة أتمتة GitHub CLI الكاملة على macOS**. بالاعتماد على البيئة التي أعددناها في الجزء الأول، يتناول هذا الجزء كيفية أتمتة إدارة مشكلات GitHub بالكامل.

تتجاوز مشكلات GitHub مجرد تتبع الأخطاء لتصبح المحور الرئيسي لإدارة جميع مهام المشروع. في هذا الجزء، سنبني نظاماً احترافياً يؤتمت العملية بأكملها: **إنشاء المشكلات الذكي**، و**التصنيف التلقائي**، و**الوسوم الديناميكية**، و**أتمتة تخطيط السبرينت**.

## الجزء الثاني: أتمتة إدارة المشكلات بالكامل

### الأهداف
- بناء نظام ذكي لإنشاء المشكلات وتصنيفها
- تنفيذ آليات الوسوم التلقائية وتعيين المسؤولين
- إنشاء نظام ديناميكي لتوليد قوالب المشكلات
- إدارة حالة المشكلة من خلال أتمتة سير العمل
- أتمتة تخطيط السبرينت وإدارة الباكلوج

## نظام إنشاء المشكلات الذكي

### 1. مصنّف المشكلات القائم على الذكاء الاصطناعي

```bash
# نظام تصنيف المشكلات ووضع الوسوم تلقائياً
cat > ~/scripts/github-cli/issue/create.sh << 'EOF'
#!/bin/bash

# نظام إنشاء المشكلات الذكي
# الاستخدام: smart-issue-creator.sh <title> [description] [priority]

TITLE="$1"
DESCRIPTION="$2"
PRIORITY="${3:-medium}"

if [[ -z "$TITLE" ]]; then
    echo "الاستخدام: smart-issue-creator.sh <title> [description] [priority:low|medium|high|critical]"
    exit 1
fi

# التصنيف التلقائي القائم على الكلمات المفتاحية
function classify_issue() {
    local title_lower=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]')
    local desc_lower=$(echo "$DESCRIPTION" | tr '[:upper:]' '[:lower:]')
    local combined="$title_lower $desc_lower"
    
    # كلمات مفتاحية مرتبطة بالأخطاء
    if echo "$combined" | grep -E "(bug|error|crash|fail|broken|fix|issue)" >/dev/null; then
        echo "bug"
    # كلمات مفتاحية مرتبطة بالتحسينات
    elif echo "$combined" | grep -E "(feature|enhance|improve|add|new|implement)" >/dev/null; then
        echo "enhancement"
    # كلمات مفتاحية مرتبطة بالتوثيق
    elif echo "$combined" | grep -E "(doc|readme|wiki|guide|manual)" >/dev/null; then
        echo "documentation"
    # كلمات مفتاحية مرتبطة بالأداء
    elif echo "$combined" | grep -E "(performance|slow|speed|optimize|memory|cpu)" >/dev/null; then
        echo "performance"
    # كلمات مفتاحية مرتبطة بالأمان
    elif echo "$combined" | grep -E "(security|vulnerable|exploit|auth|permission)" >/dev/null; then
        echo "security"
    # كلمات مفتاحية مرتبطة بالاختبار
    elif echo "$combined" | grep -E "(test|testing|spec|coverage|unit|integration)" >/dev/null; then
        echo "testing"
    else
        echo "general"
    fi
}

# تحديد لون الوسم حسب الأولوية
function get_priority_color() {
    case "$1" in
        "critical") echo "b60205" ;;
        "high") echo "d93f0b" ;;
        "medium") echo "fbca04" ;;
        "low") echo "0e8a16" ;;
        *) echo "fbca04" ;;
    esac
}

# التعيين التلقائي للمسؤول
function auto_assign() {
    local issue_type="$1"
    local context=$(cat ~/.config/gh/current_context 2>/dev/null || echo 'personal')
    
    # تعيين أعضاء الفريق لمشاريع العمل
    if [[ "$context" == "work" ]]; then
        case "$issue_type" in
            "bug"|"performance") echo "@backend-team" ;;
            "enhancement") echo "@frontend-team" ;;
            "documentation") echo "@tech-writer" ;;
            "security") echo "@security-team" ;;
            "testing") echo "@qa-team" ;;
            *) echo "@dev-team" ;;
        esac
    else
        echo "@me"
    fi
}

# تنفيذ إنشاء المشكلة
ISSUE_TYPE=$(classify_issue)
ASSIGNEE=$(auto_assign "$ISSUE_TYPE")
PRIORITY_COLOR=$(get_priority_color "$PRIORITY")

# إنشاء الوسوم إن لم تكن موجودة
gh label create "$ISSUE_TYPE" --color "1d76db" --description "Auto-classified as $ISSUE_TYPE" 2>/dev/null || true
gh label create "priority:$PRIORITY" --color "$PRIORITY_COLOR" --description "$PRIORITY priority issue" 2>/dev/null || true

# توليد نص تفصيلي للمشكلة
ISSUE_BODY="## معلومات المشكلة

**التصنيف**: $ISSUE_TYPE
**الأولوية**: $PRIORITY
**التعيين التلقائي**: $ASSIGNEE

## الوصف

${DESCRIPTION:-يرجى كتابة وصف تفصيلي للمشكلة.}

## التفاصيل

### خطوات الإعادة (للأخطاء)
1. 
2. 
3. 

### النتيجة المتوقعة


### النتيجة الفعلية


### بيئة التشغيل
- نظام التشغيل: $(uname -s)
- المتصفح: 
- الإصدار: 

## معايير القبول

- [ ] 

## المشكلات ذات الصلة


---
*تم تصنيف هذه المشكلة تلقائياً. إذا كان التصنيف غير صحيح، يرجى تعديل الوسوم.*"

# إنشاء المشكلة
CREATED_ISSUE=$(gh issue create \
    --title "$TITLE" \
    --body "$ISSUE_BODY" \
    --label "$ISSUE_TYPE,priority:$PRIORITY" \
    --assignee "$ASSIGNEE" \
    --format json)

ISSUE_NUMBER=$(echo "$CREATED_ISSUE" | jq -r '.number')
ISSUE_URL=$(echo "$CREATED_ISSUE" | jq -r '.url')

echo "تم إنشاء المشكلة الذكية!"
echo "#$ISSUE_NUMBER: $TITLE"
echo "التصنيف: $ISSUE_TYPE (الأولوية: $PRIORITY)"
echo "المسؤول: $ASSIGNEE"
echo "$ISSUE_URL"

# التحقق مما إذا كان سيبدأ العمل فوراً
if [[ "$ASSIGNEE" == "@me" ]]; then
    read -p "هل تريد البدء في العمل الآن؟ (y/N): " start_work
    if [[ "$start_work" =~ ^[Yy]$ ]]; then
        # استدعاء دالة issue_start من الجزء الأول
        issue_start "$ISSUE_NUMBER"
    fi
fi
EOF

chmod +x ~/scripts/github-cli/issue/create.sh
```

### 2. منشئ قوالب المشكلات الديناميكي

```bash
# نظام توليد قوالب المشكلات الديناميكية
cat > ~/scripts/github-cli/issue/template-generator.sh << 'EOF'
#!/bin/bash

# توليد قوالب المشكلات تلقائياً حسب نوع المشروع
# الاستخدام: template-generator.sh [project-type]

PROJECT_TYPE="${1:-general}"

# اكتشاف نوع المشروع
function detect_project_type() {
    if [[ -f "package.json" ]]; then
        echo "javascript"
    elif [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]]; then
        echo "python"
    elif [[ -f "Gemfile" ]]; then
        echo "ruby"
    elif [[ -f "go.mod" ]]; then
        echo "go"
    elif [[ -f "Cargo.toml" ]]; then
        echo "rust"
    elif [[ -f "pom.xml" ]] || [[ -f "build.gradle" ]]; then
        echo "java"
    else
        echo "general"
    fi
}

[[ "$PROJECT_TYPE" == "general" ]] && PROJECT_TYPE=$(detect_project_type)

mkdir -p .github/ISSUE_TEMPLATE

# قالب تقرير الأخطاء حسب نوع المشروع
case "$PROJECT_TYPE" in
    "javascript"|"typescript")
        cat > .github/ISSUE_TEMPLATE/bug_report.yml << 'JSEOF'
name: 🐛 Bug Report
description: Report a bug in the application
title: "[Bug]: "
labels: ["bug", "needs-triage"]
body:
  - type: markdown
    attributes:
      value: |
        Thanks for reporting this bug! Please provide as much detail as possible.
  
  - type: textarea
    id: description
    attributes:
      label: Bug Description
      description: A clear description of what the bug is
      placeholder: Describe the bug...
    validations:
      required: true
      
  - type: textarea
    id: steps
    attributes:
      label: Steps to Reproduce
      description: Steps to reproduce the behavior
      placeholder: |
        1. Go to '...'
        2. Click on '....'
        3. Scroll down to '....'
        4. See error
    validations:
      required: true
      
  - type: textarea
    id: expected
    attributes:
      label: Expected Behavior
      description: What you expected to happen
    validations:
      required: true
      
  - type: dropdown
    id: browsers
    attributes:
      label: Browser
      description: Which browser(s) are you seeing the problem on?
      multiple: true
      options:
        - Chrome
        - Firefox
        - Safari
        - Edge
        - Other
    validations:
      required: true
      
  - type: input
    id: node-version
    attributes:
      label: Node.js Version
      description: What version of Node.js are you running?
      placeholder: "v18.17.0"
    validations:
      required: true
      
  - type: textarea
    id: additional
    attributes:
      label: Additional Context
      description: Add any other context about the problem here
JSEOF
        ;;
        
    "python")
        cat > .github/ISSUE_TEMPLATE/bug_report.yml << 'PYEOF'
name: 🐛 Bug Report  
description: Report a bug in the Python application
title: "[Bug]: "
labels: ["bug", "needs-triage"]
body:
  - type: textarea
    id: description
    attributes:
      label: Bug Description
      description: A clear description of what the bug is
    validations:
      required: true
      
  - type: textarea
    id: traceback
    attributes:
      label: Error Traceback
      description: If applicable, paste the full error traceback
      render: python
      
  - type: input
    id: python-version
    attributes:
      label: Python Version
      description: What version of Python are you using?
      placeholder: "3.11.0"
    validations:
      required: true
      
  - type: textarea
    id: environment
    attributes:
      label: Environment
      description: List relevant package versions
      placeholder: |
        - Django: 4.2.0
        - requests: 2.28.2
        - etc.
PYEOF
        ;;
esac

# قالب طلب الميزات المشترك
cat > .github/ISSUE_TEMPLATE/feature_request.yml << 'FEATEOF'
name: 🚀 Feature Request
description: Suggest a new feature or improvement
title: "[Feature]: "
labels: ["enhancement", "needs-discussion"]
body:
  - type: textarea
    id: problem
    attributes:
      label: Problem Statement
      description: What problem does this feature solve?
      placeholder: "I'm frustrated when..."
    validations:
      required: true
      
  - type: textarea
    id: solution
    attributes:
      label: Proposed Solution
      description: What would you like to happen?
    validations:
      required: true
      
  - type: textarea
    id: alternatives
    attributes:
      label: Alternatives Considered
      description: Any alternative solutions you've considered?
      
  - type: dropdown
    id: priority
    attributes:
      label: Priority
      description: How important is this feature?
      options:
        - Low
        - Medium  
        - High
        - Critical
    validations:
      required: true
      
  - type: checkboxes
    id: implementation
    attributes:
      label: Implementation Willingness
      description: Are you willing to help implement this feature?
      options:
        - label: I can help with implementation
        - label: I can help with testing
        - label: I can help with documentation
FEATEOF

echo "تم إنشاء قوالب المشكلات لمشروع $PROJECT_TYPE!"
echo "تحقق من دليل .github/ISSUE_TEMPLATE/"
EOF

chmod +x ~/scripts/github-cli/issue/template-generator.sh
```

## أتمتة سير عمل المشكلات

### 1. الإدارة التلقائية القائمة على الحالة

```bash
# إنشاء نص برمجي لأتمتة سير عمل المشكلات
cat > ~/scripts/github-cli/issue/workflow.sh << 'EOF'
#!/bin/bash

# دوال أتمتة سير عمل المشكلات

# تغيير حالة المشكلة وتشغيل الإجراءات التلقائية
function issue_status() {
    local issue_num="$1"
    local status="$2"
    
    if [[ -z "$issue_num" || -z "$status" ]]; then
        echo "الاستخدام: issue_status <رقم-المشكلة> <الحالة>"
        echo "الحالات: todo, in-progress, review, testing, done"
        return 1
    fi
    
    case "$status" in
        "todo")
            gh issue edit "$issue_num" \
                --remove-label "in-progress,review,testing" \
                --add-label "todo" \
                --milestone ""
            gh issue comment "$issue_num" --body "تم نقل المشكلة إلى حالة TODO."
            ;;
            
        "in-progress") 
            gh issue edit "$issue_num" \
                --remove-label "todo,review,testing" \
                --add-label "in-progress" \
                --assignee "@me"
            gh issue comment "$issue_num" --body "بدأ العمل. المسؤول: $(gh api user -q .login)"
            
            # إنشاء فرع تلقائياً
            issue_start "$issue_num"
            ;;
            
        "review")
            gh issue edit "$issue_num" \
                --remove-label "todo,in-progress,testing" \
                --add-label "review"
            
            # إذا كان هناك PR، طلب المراجعة تلقائياً
            local pr_number=$(gh pr list --search "closes:#$issue_num" --json number -q '.[0].number')
            if [[ -n "$pr_number" && "$pr_number" != "null" ]]; then
                gh pr ready "$pr_number"
                gh pr edit "$pr_number" --add-reviewer "@team-leads"
                gh issue comment "$issue_num" --body "تم طلب مراجعة الكود. PR #$pr_number"
            fi
            ;;
            
        "testing")
            gh issue edit "$issue_num" \
                --remove-label "todo,in-progress,review" \
                --add-label "testing"
            gh issue comment "$issue_num" --body "في مرحلة الاختبار. يرجى المراجعة مع فريق QA."
            ;;
            
        "done")
            gh issue close "$issue_num"
            gh issue comment "$issue_num" --body "تم إغلاق المشكلة. شكراً لجميع من عمل عليها!"
            
            # تنظيف الفرع المرتبط
            local current_branch=$(git branch --show-current)
            if [[ "$current_branch" == *"issue-$issue_num"* ]]; then
                git checkout main
                git branch -d "$current_branch" 2>/dev/null || true
                echo "تم تنظيف الفرع '$current_branch'."
            fi
            ;;
            
        *)
            echo "حالة غير مدعومة."
            echo "الحالات المتاحة: todo, in-progress, review, testing, done"
            return 1
            ;;
    esac
    
    echo "تم تغيير حالة المشكلة #$issue_num إلى '$status'."
}

# تغيير حالة مجموعة من المشكلات دفعةً واحدة
function bulk_issue_status() {
    local status="$1"
    shift
    local issues=("$@")
    
    if [[ -z "$status" || ${#issues[@]} -eq 0 ]]; then
        echo "الاستخدام: bulk_issue_status <الحالة> <مشكلة1> <مشكلة2> ..."
        return 1
    fi
    
    echo "جارٍ تغيير حالة ${#issues[@]} مشكلة إلى '$status'..."
    
    for issue in "${issues[@]}"; do
        echo "جارٍ المعالجة: #$issue"
        issue_status "$issue" "$status"
        sleep 1  # تجنب تجاوز حدود API
    done
    
    echo "اكتمل تغيير حالة جميع المشكلات."
}

# ضبط الأولوية تلقائياً
function auto_prioritize() {
    local issue_num="$1"
    
    if [[ -z "$issue_num" ]]; then
        echo "الاستخدام: auto_prioritize <رقم-المشكلة>"
        return 1
    fi
    
    # جلب معلومات المشكلة
    local issue_info=$(gh issue view "$issue_num" --json labels,comments,reactions,createdAt)
    local labels=$(echo "$issue_info" | jq -r '.labels[].name' | tr '\n' ' ')
    local comment_count=$(echo "$issue_info" | jq '.comments | length')
    local reaction_count=$(echo "$issue_info" | jq '.reactions.totalCount')
    local created_days_ago=$(( ($(date +%s) - $(date -d "$(echo "$issue_info" | jq -r '.createdAt')" +%s)) / 86400 ))
    
    local priority="medium"
    
    # منطق حساب الأولوية
    if echo "$labels" | grep -q "bug"; then
        if echo "$labels" | grep -q "critical\|security"; then
            priority="critical"
        elif [[ $reaction_count -gt 5 || $comment_count -gt 10 ]]; then
            priority="high"
        elif [[ $created_days_ago -gt 7 ]]; then
            priority="high"
        else
            priority="medium"
        fi
    elif echo "$labels" | grep -q "enhancement"; then
        if [[ $reaction_count -gt 10 || $comment_count -gt 15 ]]; then
            priority="high"
        elif [[ $created_days_ago -gt 30 ]]; then
            priority="low"
        fi
    fi
    
    # إزالة وسوم الأولوية الموجودة وتعيين الأولوية الجديدة
    gh issue edit "$issue_num" \
        --remove-label "priority:low,priority:medium,priority:high,priority:critical" \
        --add-label "priority:$priority"
    
    echo "تم ضبط أولوية المشكلة #$issue_num إلى '$priority'."
    echo "التحليل: $comment_count تعليق، $reaction_count تفاعل، أُنشئت منذ ${created_days_ago} يوماً"
}
EOF

chmod +x ~/scripts/github-cli/issue/workflow.sh

# إضافة تحميل النص البرمجي إلى .zshrc
cat >> ~/.zshrc << 'EOF'

# تحميل نص برمجي إدارة المشكلات
source ~/scripts/github-cli/issue/workflow.sh
EOF

source ~/.zshrc
```

### 2. أتمتة تخطيط السبرينت

```bash
# نظام إدارة السبرينت
cat > ~/scripts/github-cli/issue/sprint-manager.sh << 'EOF'
#!/bin/bash

# نظام أتمتة إدارة السبرينت
# الاستخدام: sprint-manager.sh <command> [options]

COMMAND="$1"
SPRINT_NAME="$2"
DURATION="${3:-14}"  # الافتراضي أسبوعان

case "$COMMAND" in
    "create")
        if [[ -z "$SPRINT_NAME" ]]; then
            echo "الاستخدام: sprint-manager.sh create <اسم-السبرينت> [مدة-بالأيام]"
            exit 1
        fi
        
        # إنشاء milestone للسبرينت
        START_DATE=$(date +%Y-%m-%d)
        END_DATE=$(date -d "+${DURATION} days" +%Y-%m-%d)
        
        gh milestone create "$SPRINT_NAME" \
            --description "فترة السبرينت: من $START_DATE إلى $END_DATE" \
            --due-date "$END_DATE"
        
        echo "تم إنشاء السبرينت '$SPRINT_NAME'."
        echo "الفترة: من $START_DATE إلى $END_DATE"
        
        # التعيين التلقائي للمشكلات من الباكلوج
        echo "جارٍ التعيين التلقائي للمشكلات من الباكلوج..."
        
        # إضافة المشكلات عالية الأولوية إلى السبرينت
        gh issue list --label "priority:high" --state open --limit 5 --json number | \
            jq -r '.[] | .number' | while read issue_num; do
            gh issue edit "$issue_num" --milestone "$SPRINT_NAME"
            echo "  تمت إضافة المشكلة #$issue_num إلى السبرينت."
        done
        ;;
        
    "status")
        if [[ -z "$SPRINT_NAME" ]]; then
            echo "الاستخدام: sprint-manager.sh status <اسم-السبرينت>"
            exit 1
        fi
        
        echo "حالة السبرينت '$SPRINT_NAME'"
        echo "================================"
        
        # إجمالي عدد المشكلات
        TOTAL_ISSUES=$(gh issue list --milestone "$SPRINT_NAME" --json number | jq length)
        CLOSED_ISSUES=$(gh issue list --milestone "$SPRINT_NAME" --state closed --json number | jq length)
        OPEN_ISSUES=$((TOTAL_ISSUES - CLOSED_ISSUES))
        
        echo "التقدم: $CLOSED_ISSUES/$TOTAL_ISSUES ($(( CLOSED_ISSUES * 100 / TOTAL_ISSUES ))%)"
        echo
        
        echo "المشكلات حسب الحالة:"
        echo "  المشكلات المفتوحة: $OPEN_ISSUES"
        echo "  المشكلات المكتملة: $CLOSED_ISSUES"
        echo
        
        echo "المشكلات قيد التنفيذ:"
        gh issue list --milestone "$SPRINT_NAME" --state open --json number,title,assignees | \
            jq -r '.[] | "  #\(.number): \(.title) (\(.assignees[0].login // "غير معين"))"'
        ;;
        
    "burndown")
        if [[ -z "$SPRINT_NAME" ]]; then
            echo "الاستخدام: sprint-manager.sh burndown <اسم-السبرينت>"
            exit 1
        fi
        
        # توليد بيانات مخطط الاحتراق
        BURNDOWN_FILE="$HOME/Documents/github-automation/burndown-$SPRINT_NAME.csv"
        
        echo "date,remaining_issues" > "$BURNDOWN_FILE"
        
        # توليد بيانات آخر 14 يوماً
        for i in $(seq 0 13); do
            DATE=$(date -d "-$i days" +%Y-%m-%d)
            REMAINING=$(gh issue list --milestone "$SPRINT_NAME" --search "created:>=$DATE" --json number | jq length)
            echo "$DATE,$REMAINING" >> "$BURNDOWN_FILE"
        done
        
        echo "تم توليد بيانات مخطط الاحتراق: $BURNDOWN_FILE"
        ;;
        
    "close")
        if [[ -z "$SPRINT_NAME" ]]; then
            echo "الاستخدام: sprint-manager.sh close <اسم-السبرينت>"
            exit 1
        fi
        
        echo "جارٍ إغلاق السبرينت '$SPRINT_NAME'..."
        
        # نقل المشكلات غير المكتملة إلى السبرينت التالي
        OPEN_ISSUES=$(gh issue list --milestone "$SPRINT_NAME" --state open --json number,title)
        OPEN_COUNT=$(echo "$OPEN_ISSUES" | jq length)
        
        if [[ $OPEN_COUNT -gt 0 ]]; then
            echo "يوجد $OPEN_COUNT مشكلة غير مكتملة."
            read -p "أدخل اسم السبرينت التالي (أو اضغط Enter للنقل إلى الباكلوج): " NEXT_SPRINT
            
            echo "$OPEN_ISSUES" | jq -r '.[] | .number' | while read issue_num; do
                if [[ -n "$NEXT_SPRINT" ]]; then
                    gh issue edit "$issue_num" --milestone "$NEXT_SPRINT"
                    echo "  تم نقل المشكلة #$issue_num إلى '$NEXT_SPRINT'."
                else
                    gh issue edit "$issue_num" --milestone ""
                    echo "  تم نقل المشكلة #$issue_num إلى الباكلوج."
                fi
            done
        fi
        
        # توليد تقرير السبرينت
        REPORT_FILE="$HOME/Documents/github-automation/sprint-report-$SPRINT_NAME.md"
        
        cat > "$REPORT_FILE" << REPORTEOF
# تقرير إتمام السبرينت '$SPRINT_NAME'

## الملخص
- إجمالي المشكلات: $(gh issue list --milestone "$SPRINT_NAME" --json number | jq length)
- المشكلات المكتملة: $(gh issue list --milestone "$SPRINT_NAME" --state closed --json number | jq length)
- المشكلات غير المكتملة: $OPEN_COUNT

## المشكلات المكتملة
$(gh issue list --milestone "$SPRINT_NAME" --state closed --json number,title | jq -r '.[] | "- [#\(.number)](\(.html_url)) \(.title)"')

## المشكلات غير المكتملة
$(gh issue list --milestone "$SPRINT_NAME" --state open --json number,title | jq -r '.[] | "- [#\(.number)](\(.html_url)) \(.title)"')

---
*تاريخ توليد التقرير: $(date)*
REPORTEOF
        
        echo "تقرير إتمام السبرينت: $REPORT_FILE"
        
        # إغلاق الـ milestone
        gh milestone edit "$SPRINT_NAME" --state closed
        echo "تم إغلاق السبرينت '$SPRINT_NAME'."
        ;;
        
    *)
        echo "نظام إدارة السبرينت على GitHub"
        echo "الاستخدام: sprint-manager.sh <command> [options]"
        echo
        echo "الأوامر:"
        echo "  create <اسم-السبرينت> [مدة]  - إنشاء سبرينت جديد"
        echo "  status <اسم-السبرينت>         - عرض حالة السبرينت"
        echo "  burndown <اسم-السبرينت>       - توليد بيانات مخطط الاحتراق"
        echo "  close <اسم-السبرينت>          - إغلاق السبرينت وترتيبه"
        ;;
esac
EOF

chmod +x ~/scripts/github-cli/issue/sprint-manager.sh
```

## تحليل المشكلات المتقدم والرؤى

### 1. لوحة تحليل المشكلات

```bash
# نص برمجي لتوليد تحليل المشكلات والرؤى
cat > ~/scripts/github-cli/issue/analytics.sh << 'EOF'
#!/bin/bash

# لوحة تحليل المشكلات
function issue_analytics() {
    local period="${1:-30}"  # الافتراضي 30 يوماً
    
    echo "لوحة تحليل مشكلات GitHub (آخر ${period} يوماً)"
    echo "=================================================="
    echo
    
    # الإحصاءات الأساسية
    echo "الإحصاءات الأساسية:"
    local total_issues=$(gh issue list --search "created:>=$(date -d "-${period} days" +%Y-%m-%d)" --json number | jq length)
    local closed_issues=$(gh issue list --search "created:>=$(date -d "-${period} days" +%Y-%m-%d) is:closed" --json number | jq length)
    local bug_issues=$(gh issue list --search "created:>=$(date -d "-${period} days" +%Y-%m-%d) label:bug" --json number | jq length)
    
    echo "  إجمالي المشكلات المنشأة: $total_issues"
    echo "  المشكلات المكتملة: $closed_issues ($(( closed_issues * 100 / total_issues ))%)"
    echo "  مشكلات الأخطاء: $bug_issues"
    echo
    
    # التحليل حسب الوسم
    echo "التحليل حسب الوسم:"
    gh issue list --search "created:>=$(date -d "-${period} days" +%Y-%m-%d)" --json labels | \
        jq -r '.[] | .labels[].name' | sort | uniq -c | sort -nr | head -10 | \
        while read count label; do
            echo "  $label: $count"
        done
    echo
    
    # التحليل حسب المسؤول
    echo "التحليل حسب المسؤول:"
    gh issue list --search "created:>=$(date -d "-${period} days" +%Y-%m-%d)" --json assignees | \
        jq -r '.[] | .assignees[]?.login' | sort | uniq -c | sort -nr | head -5 | \
        while read count assignee; do
            echo "  $assignee: $count"
        done
    echo
    
    # المشكلات المفتوحة حسب الأولوية
    echo "المشكلات المفتوحة حسب الأولوية:"
    for priority in critical high medium low; do
        local count=$(gh issue list --label "priority:$priority" --state open --json number | jq length)
        echo "  $priority: $count"
    done
    echo
    
    # المشكلات المفتوحة منذ وقت طويل
    echo "المشكلات المفتوحة منذ فترة طويلة (30 يوماً أو أكثر):"
    gh issue list --search "created:<$(date -d "-30 days" +%Y-%m-%d) is:open" --limit 5 --json number,title,createdAt | \
        jq -r '.[] | "  #\(.number): \(.title) (أُنشئت: \(.createdAt | split("T")[0]))"'
}

# فحص صحة المشكلات
function issue_health_check() {
    echo "فحص صحة المشكلات"
    echo "==================="
    echo
    
    local warnings=0
    
    # فحص المشكلات غير المعينة
    local unassigned=$(gh issue list --search "is:open no:assignee" --json number | jq length)
    if [[ $unassigned -gt 5 ]]; then
        echo "عدد كبير من المشكلات غير المعينة: ${unassigned}"
        warnings=$((warnings + 1))
    fi
    
    # فحص المشكلات بدون وسوم
    local unlabeled=$(gh issue list --search "is:open no:label" --json number | jq length)
    if [[ $unlabeled -gt 3 ]]; then
        echo "مشكلات بدون وسوم: ${unlabeled}"
        warnings=$((warnings + 1))
    fi
    
    # فحص المشكلات القديمة
    local stale_issues=$(gh issue list --search "is:open created:<$(date -d "-60 days" +%Y-%m-%d)" --json number | jq length)
    if [[ $stale_issues -gt 10 ]]; then
        echo "مشكلات عمرها 60 يوماً أو أكثر: ${stale_issues}"
        warnings=$((warnings + 1))
    fi
    
    # فحص المشكلات عالية الأولوية
    local high_priority=$(gh issue list --label "priority:high,priority:critical" --state open --json number | jq length)
    if [[ $high_priority -gt 5 ]]; then
        echo "تراكم المشكلات عالية الأولوية: ${high_priority}"
        warnings=$((warnings + 1))
    fi
    
    if [[ $warnings -eq 0 ]]; then
        echo "إدارة المشكلات في حالة جيدة!"
    else
        echo
        echo "اقتراحات للتحسين:"
        echo "  - تعيين مسؤولين للمشكلات غير المعينة"
        echo "  - تصنيف المشكلات بدون وسوم"
        echo "  - مراجعة المشكلات القديمة وترتيبها"
        echo "  - إعطاء الأولوية للمشكلات عالية الأهمية"
    fi
}
EOF

chmod +x ~/scripts/github-cli/issue/analytics.sh

# إضافة تحميل نص التحليل إلى .zshrc
cat >> ~/.zshrc << 'EOF'

# تحميل نص برمجي تحليل المشكلات
source ~/scripts/github-cli/issue/analytics.sh
EOF

source ~/.zshrc
```

### 2. نظام الإشعارات التلقائية

```bash
# نظام إشعارات المشكلات اليومية
cat > ~/scripts/github-cli/system/daily-issue-alert.sh << 'EOF'
#!/bin/bash

# نظام إشعارات حالة المشكلات اليومية
# تشغيل يومي عبر cron job: 0 9 * * * ~/scripts/github-cli/system/daily-issue-alert.sh

ALERT_FILE="$HOME/Documents/github-automation/daily-alert-$(date +%Y-%m-%d).md"

cat > "$ALERT_FILE" << 'ALERTHEADER'
# تنبيه المشكلات اليومي

## تنبيهات عاجلة
ALERTHEADER

# فحص المشكلات الحرجة
CRITICAL_ISSUES=$(gh issue list --label "priority:critical" --state open --json number,title,createdAt)
CRITICAL_COUNT=$(echo "$CRITICAL_ISSUES" | jq length)

if [[ $CRITICAL_COUNT -gt 0 ]]; then
    echo "**مشكلات CRITICAL غير محلولة: ${CRITICAL_COUNT}**" >> "$ALERT_FILE"
    echo "$CRITICAL_ISSUES" | jq -r '.[] | "- [#\(.number)](\(.html_url)) \(.title)"' >> "$ALERT_FILE"
else
    echo "لا توجد مشكلات حرجة." >> "$ALERT_FILE"
fi

echo "" >> "$ALERT_FILE"

# المشكلات المفتوحة منذ وقت طويل
echo "## المشكلات المفتوحة منذ وقت طويل (7 أيام أو أكثر)" >> "$ALERT_FILE"
STALE_ISSUES=$(gh issue list --search "is:open created:<$(date -d "-7 days" +%Y-%m-%d)" --limit 10 --json number,title,createdAt)
STALE_COUNT=$(echo "$STALE_ISSUES" | jq length)

if [[ $STALE_COUNT -gt 0 ]]; then
    echo "$STALE_ISSUES" | jq -r '.[] | "- [#\(.number)](\(.html_url)) \(.title) (أُنشئت: \(.createdAt | split("T")[0]))"' >> "$ALERT_FILE"
else
    echo "لا توجد مشكلات مفتوحة منذ وقت طويل." >> "$ALERT_FILE"
fi

echo "" >> "$ALERT_FILE"

# مهام اليوم
echo "## مهام اليوم" >> "$ALERT_FILE"
TODAY_ISSUES=$(gh issue list --assignee @me --state open --limit 5 --json number,title)
TODAY_COUNT=$(echo "$TODAY_ISSUES" | jq length)

if [[ $TODAY_COUNT -gt 0 ]]; then
    echo "$TODAY_ISSUES" | jq -r '.[] | "- [ ] [#\(.number)](\(.html_url)) \(.title)"' >> "$ALERT_FILE"
else
    echo "لا توجد مشكلات معينة لك!" >> "$ALERT_FILE"
fi

# طباعة الملخص في الطرفية
echo "تم توليد تنبيه المشكلات اليومي: $ALERT_FILE"
if [[ $CRITICAL_COUNT -gt 0 ]]; then
    echo "المشكلات الحرجة تحتاج إلى اهتمام: $CRITICAL_COUNT"
fi
if [[ $STALE_COUNT -gt 5 ]]; then
    echo "المشكلات القديمة تحتاج إلى ترتيب: $STALE_COUNT"
fi

# اختياري: إرسال عبر Slack أو البريد الإلكتروني
# slack-alert.sh "$ALERT_FILE" 2>/dev/null || true
EOF

chmod +x ~/scripts/github-cli/system/daily-issue-alert.sh
```

## ما التالي

في الجزء التالي، **[إدارة المشاريع + فصل مشاريع العمل عن الشخصية](github-cli-project-management-automation)**، سنتناول:

- الأتمتة الكاملة لـ GitHub Projects v2
- الإدارة الديناميكية للوحة Kanban
- فصل سير عمل مشاريع العمل عن الشخصية
- أنظمة أتمتة تعاون الفريق
- مقاييس المشروع وإعداد التقارير

---

## مقالات أخرى في هذه السلسلة

- [الجزء الأول: التثبيت وإعداد البيئة](macos-github-cli-complete-guide)
- **الجزء الثاني: أتمتة إدارة المشكلات بالكامل** (الموقع الحالي)
- [الجزء الثالث: إدارة المشاريع + فصل مشاريع العمل عن الشخصية](github-cli-project-management-automation)
- [الجزء الرابع: أتمتة إدارة Wiki بالكامل](github-cli-wiki-automation-guide)
- [الجزء الخامس: سير العمل المتقدم والتطبيق العملي](github-cli-advanced-workflows)
