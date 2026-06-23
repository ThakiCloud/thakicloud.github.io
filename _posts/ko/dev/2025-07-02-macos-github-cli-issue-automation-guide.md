---
title: "macOS GitHub CLI 완전 자동화 시리즈 - 2편: 이슈 관리 완전 자동화"
excerpt: "지능형 이슈 생성, 자동 라벨링, 스프린트 계획까지 - GitHub 이슈 관리의 모든 것을 자동화하는 전문가 가이드"
seo_title: "macOS GitHub CLI 완전 자동화 2편 - 이슈 관리 자동화 - Thaki Cloud"
seo_description: "GitHub CLI로 이슈 생성부터 분류, 라벨링, 담당자 할당, 스프린트 계획까지 완전 자동화하는 방법. 지능형 이슈 관리 시스템 구축 가이드"
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
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/ko/dev/macos-github-cli-issue-automation-guide/"
reading_time: true
published: false
---

⏱️ **예상 읽기 시간**: 25분

## 시리즈 소개

이 글은 **macOS GitHub CLI 완전 자동화 시리즈**의 2편입니다. 1편에서 구축한 환경을 기반으로 GitHub 이슈 관리를 완전히 자동화하는 방법을 다룹니다.

GitHub 이슈는 단순한 버그 트래킹을 넘어서 프로젝트의 모든 작업을 관리하는 중심축입니다. 이번 편에서는 **지능형 이슈 생성**, **자동 분류 시스템**, **동적 라벨링**, **스프린트 계획 자동화**까지 모든 과정을 자동화하는 전문가급 시스템을 구축해보겠습니다.

## 2편: 이슈 관리 완전 자동화

### 목표
- 지능형 이슈 생성 및 분류 시스템 구축
- 자동 라벨링 및 담당자 할당 메커니즘
- 이슈 템플릿 동적 생성 시스템
- 워크플로우 기반 이슈 상태 관리
- 스프린트 계획 및 백로그 자동화

## 지능형 이슈 생성 시스템

### 1. AI 기반 이슈 분류기

```bash
# 이슈 분류 및 자동 라벨링 시스템
cat > ~/scripts/github-cli/issue/create.sh << 'EOF'
#!/bin/bash

# 지능형 이슈 생성 시스템
# 사용법: smart-issue-creator.sh <title> [description] [priority]

TITLE="$1"
DESCRIPTION="$2"
PRIORITY="${3:-medium}"

if [[ -z "$TITLE" ]]; then
    echo "사용법: smart-issue-creator.sh <title> [description] [priority:low|medium|high|critical]"
    exit 1
fi

# 키워드 기반 자동 분류
function classify_issue() {
    local title_lower=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]')
    local desc_lower=$(echo "$DESCRIPTION" | tr '[:upper:]' '[:lower:]')
    local combined="$title_lower $desc_lower"
    
    # 버그 관련 키워드
    if echo "$combined" | grep -E "(bug|error|crash|fail|broken|fix|issue)" >/dev/null; then
        echo "bug"
    # 기능 개선 키워드
    elif echo "$combined" | grep -E "(feature|enhance|improve|add|new|implement)" >/dev/null; then
        echo "enhancement"
    # 문서 관련 키워드  
    elif echo "$combined" | grep -E "(doc|readme|wiki|guide|manual)" >/dev/null; then
        echo "documentation"
    # 성능 관련 키워드
    elif echo "$combined" | grep -E "(performance|slow|speed|optimize|memory|cpu)" >/dev/null; then
        echo "performance"
    # 보안 관련 키워드
    elif echo "$combined" | grep -E "(security|vulnerable|exploit|auth|permission)" >/dev/null; then
        echo "security"
    # 테스트 관련 키워드  
    elif echo "$combined" | grep -E "(test|testing|spec|coverage|unit|integration)" >/dev/null; then
        echo "testing"
    else
        echo "general"
    fi
}

# 우선순위별 라벨 색상 설정
function get_priority_color() {
    case "$1" in
        "critical") echo "b60205" ;;
        "high") echo "d93f0b" ;;
        "medium") echo "fbca04" ;;
        "low") echo "0e8a16" ;;
        *) echo "fbca04" ;;
    esac
}

# 자동 담당자 할당
function auto_assign() {
    local issue_type="$1"
    local context=$(cat ~/.config/gh/current_context 2>/dev/null || echo 'personal')
    
    # 회사 프로젝트일 경우 팀별 담당자 할당
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

# 이슈 생성 실행
ISSUE_TYPE=$(classify_issue)
ASSIGNEE=$(auto_assign "$ISSUE_TYPE")
PRIORITY_COLOR=$(get_priority_color "$PRIORITY")

# 라벨 생성 (없으면)
gh label create "$ISSUE_TYPE" --color "1d76db" --description "Auto-classified as $ISSUE_TYPE" 2>/dev/null || true
gh label create "priority:$PRIORITY" --color "$PRIORITY_COLOR" --description "$PRIORITY priority issue" 2>/dev/null || true

# 상세한 이슈 본문 생성
ISSUE_BODY="## 📋 이슈 정보

**분류**: $ISSUE_TYPE
**우선순위**: $PRIORITY  
**자동 할당**: $ASSIGNEE

## 📝 설명

${DESCRIPTION:-이슈에 대한 자세한 설명을 작성해주세요.}

## 🔍 상세 정보

### 재현 단계 (버그인 경우)
1. 
2. 
3. 

### 예상 결과


### 실제 결과


### 환경 정보
- OS: $(uname -s)
- 브라우저: 
- 버전: 

## ✅ 완료 조건

- [ ] 

## 🔗 관련 이슈


---
*이 이슈는 자동으로 분류되었습니다. 잘못된 분류인 경우 라벨을 수정해주세요.*"

# 이슈 생성
CREATED_ISSUE=$(gh issue create \
    --title "$TITLE" \
    --body "$ISSUE_BODY" \
    --label "$ISSUE_TYPE,priority:$PRIORITY" \
    --assignee "$ASSIGNEE" \
    --format json)

ISSUE_NUMBER=$(echo "$CREATED_ISSUE" | jq -r '.number')
ISSUE_URL=$(echo "$CREATED_ISSUE" | jq -r '.url')

echo "✅ 지능형 이슈가 생성되었습니다!"
echo "📝 #$ISSUE_NUMBER: $TITLE"
echo "🏷️  분류: $ISSUE_TYPE (우선순위: $PRIORITY)"
echo "👤 담당자: $ASSIGNEE"
echo "🔗 $ISSUE_URL"

# 자동으로 작업 시작 여부 확인
if [[ "$ASSIGNEE" == "@me" ]]; then
    read -p "바로 작업을 시작하시겠습니까? (y/N): " start_work
    if [[ "$start_work" =~ ^[Yy]$ ]]; then
        # 1편에서 만든 issue_start 함수 호출
        issue_start "$ISSUE_NUMBER"
    fi
fi
EOF

chmod +x ~/scripts/github-cli/issue/create.sh
```

### 2. 이슈 템플릿 동적 생성기

```bash
# 동적 이슈 템플릿 생성 시스템
cat > ~/scripts/github-cli/issue/template-generator.sh << 'EOF'
#!/bin/bash

# 프로젝트 타입별 이슈 템플릿 자동 생성
# 사용법: template-generator.sh [project-type]

PROJECT_TYPE="${1:-general}"

# 프로젝트 유형 감지
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

# 프로젝트별 버그 리포트 템플릿
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

# 공통 기능 요청 템플릿
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

echo "✅ $PROJECT_TYPE 프로젝트용 이슈 템플릿이 생성되었습니다!"
echo "📁 .github/ISSUE_TEMPLATE/ 디렉토리를 확인하세요."
EOF

chmod +x ~/scripts/github-cli/issue/template-generator.sh
```

## 이슈 워크플로우 자동화

### 1. 상태 기반 자동 관리

```bash
# 이슈 워크플로우 자동화 스크립트 생성
cat > ~/scripts/github-cli/issue/workflow.sh << 'EOF'
#!/bin/bash

# 이슈 워크플로우 자동화 함수들

# 이슈 상태 변경 및 자동 액션
function issue_status() {
    local issue_num="$1"
    local status="$2"
    
    if [[ -z "$issue_num" || -z "$status" ]]; then
        echo "사용법: issue_status <이슈번호> <상태>"
        echo "상태: todo, in-progress, review, testing, done"
        return 1
    fi
    
    case "$status" in
        "todo")
            gh issue edit "$issue_num" \
                --remove-label "in-progress,review,testing" \
                --add-label "todo" \
                --milestone ""
            gh issue comment "$issue_num" --body "📋 이슈가 TODO 상태로 변경되었습니다."
            ;;
            
        "in-progress") 
            gh issue edit "$issue_num" \
                --remove-label "todo,review,testing" \
                --add-label "in-progress" \
                --assignee "@me"
            gh issue comment "$issue_num" --body "🚀 작업을 시작했습니다. 담당자: $(gh api user -q .login)"
            
            # 자동으로 브랜치 생성
            issue_start "$issue_num"
            ;;
            
        "review")
            gh issue edit "$issue_num" \
                --remove-label "todo,in-progress,testing" \
                --add-label "review"
            
            # PR이 있으면 자동으로 리뷰 요청
            local pr_number=$(gh pr list --search "closes:#$issue_num" --json number -q '.[0].number')
            if [[ -n "$pr_number" && "$pr_number" != "null" ]]; then
                gh pr ready "$pr_number"
                gh pr edit "$pr_number" --add-reviewer "@team-leads"
                gh issue comment "$issue_num" --body "👀 코드 리뷰가 요청되었습니다. PR #$pr_number"
            fi
            ;;
            
        "testing")
            gh issue edit "$issue_num" \
                --remove-label "todo,in-progress,review" \
                --add-label "testing"
            gh issue comment "$issue_num" --body "🧪 테스트 단계입니다. QA 팀에서 확인해주세요."
            ;;
            
        "done")
            gh issue close "$issue_num"
            gh issue comment "$issue_num" --body "✅ 이슈가 완료되었습니다. 작업해주신 모든 분들께 감사드립니다!"
            
            # 관련 브랜치 정리
            local current_branch=$(git branch --show-current)
            if [[ "$current_branch" == *"issue-$issue_num"* ]]; then
                git checkout main
                git branch -d "$current_branch" 2>/dev/null || true
                echo "🌿 브랜치 '$current_branch'가 정리되었습니다."
            fi
            ;;
            
        *)
            echo "❌ 지원하지 않는 상태입니다."
            echo "사용 가능한 상태: todo, in-progress, review, testing, done"
            return 1
            ;;
    esac
    
    echo "✅ 이슈 #$issue_num 상태가 '$status'로 변경되었습니다."
}

# 이슈 대량 상태 변경
function bulk_issue_status() {
    local status="$1"
    shift
    local issues=("$@")
    
    if [[ -z "$status" || ${#issues[@]} -eq 0 ]]; then
        echo "사용법: bulk_issue_status <상태> <이슈번호1> <이슈번호2> ..."
        return 1
    fi
    
    echo "🔄 ${#issues[@]}개 이슈의 상태를 '$status'로 변경합니다..."
    
    for issue in "${issues[@]}"; do
        echo "처리 중: #$issue"
        issue_status "$issue" "$status"
        sleep 1  # API 제한 방지
    done
    
    echo "✅ 모든 이슈 상태 변경이 완료되었습니다."
}

# 이슈 자동 우선순위 조정
function auto_prioritize() {
    local issue_num="$1"
    
    if [[ -z "$issue_num" ]]; then
        echo "사용법: auto_prioritize <이슈번호>"
        return 1
    fi
    
    # 이슈 정보 가져오기
    local issue_info=$(gh issue view "$issue_num" --json labels,comments,reactions,createdAt)
    local labels=$(echo "$issue_info" | jq -r '.labels[].name' | tr '\n' ' ')
    local comment_count=$(echo "$issue_info" | jq '.comments | length')
    local reaction_count=$(echo "$issue_info" | jq '.reactions.totalCount')
    local created_days_ago=$(( ($(date +%s) - $(date -d "$(echo "$issue_info" | jq -r '.createdAt')" +%s)) / 86400 ))
    
    local priority="medium"
    
    # 우선순위 계산 로직
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
    
    # 기존 우선순위 라벨 제거 및 새 우선순위 설정
    gh issue edit "$issue_num" \
        --remove-label "priority:low,priority:medium,priority:high,priority:critical" \
        --add-label "priority:$priority"
    
    echo "🎯 이슈 #$issue_num의 우선순위가 '$priority'로 조정되었습니다."
    echo "📊 분석 결과: 댓글 $comment_count개, 반응 $reaction_count개, 생성 후 ${created_days_ago}일"
}
EOF

chmod +x ~/scripts/github-cli/issue/workflow.sh

# .zshrc에 스크립트 로딩 추가
cat >> ~/.zshrc << 'EOF'

# 이슈 관리 스크립트 로딩
source ~/scripts/github-cli/issue/workflow.sh
EOF

source ~/.zshrc
```

### 2. 스프린트 계획 자동화

```bash
# 스프린트 관리 시스템
cat > ~/scripts/github-cli/issue/sprint-manager.sh << 'EOF'
#!/bin/bash

# 스프린트 관리 자동화 시스템
# 사용법: sprint-manager.sh <command> [options]

COMMAND="$1"
SPRINT_NAME="$2"
DURATION="${3:-14}"  # 기본 2주

case "$COMMAND" in
    "create")
        if [[ -z "$SPRINT_NAME" ]]; then
            echo "사용법: sprint-manager.sh create <스프린트명> [기간(일)]"
            exit 1
        fi
        
        # 스프린트 마일스톤 생성
        START_DATE=$(date +%Y-%m-%d)
        END_DATE=$(date -d "+${DURATION} days" +%Y-%m-%d)
        
        gh milestone create "$SPRINT_NAME" \
            --description "스프린트 기간: $START_DATE ~ $END_DATE" \
            --due-date "$END_DATE"
        
        echo "✅ 스프린트 '$SPRINT_NAME'이 생성되었습니다."
        echo "📅 기간: $START_DATE ~ $END_DATE"
        
        # 백로그에서 이슈 자동 할당
        echo "🔄 백로그에서 이슈를 자동 할당합니다..."
        
        # high priority 이슈들을 스프린트에 추가
        gh issue list --label "priority:high" --state open --limit 5 --json number | \
            jq -r '.[] | .number' | while read issue_num; do
            gh issue edit "$issue_num" --milestone "$SPRINT_NAME"
            echo "  📋 이슈 #$issue_num이 스프린트에 추가되었습니다."
        done
        ;;
        
    "status")
        if [[ -z "$SPRINT_NAME" ]]; then
            echo "사용법: sprint-manager.sh status <스프린트명>"
            exit 1
        fi
        
        echo "📊 스프린트 '$SPRINT_NAME' 현황"
        echo "================================"
        
        # 전체 이슈 수
        TOTAL_ISSUES=$(gh issue list --milestone "$SPRINT_NAME" --json number | jq length)
        CLOSED_ISSUES=$(gh issue list --milestone "$SPRINT_NAME" --state closed --json number | jq length)
        OPEN_ISSUES=$((TOTAL_ISSUES - CLOSED_ISSUES))
        
        echo "📈 진행률: $CLOSED_ISSUES/$TOTAL_ISSUES ($(( CLOSED_ISSUES * 100 / TOTAL_ISSUES ))%)"
        echo
        
        echo "📋 상태별 이슈:"
        echo "  🔴 열린 이슈: $OPEN_ISSUES"
        echo "  ✅ 완료된 이슈: $CLOSED_ISSUES"
        echo
        
        echo "📝 진행 중인 이슈:"
        gh issue list --milestone "$SPRINT_NAME" --state open --json number,title,assignees | \
            jq -r '.[] | "  #\(.number): \(.title) (\(.assignees[0].login // "미할당"))"'
        ;;
        
    "burndown")
        if [[ -z "$SPRINT_NAME" ]]; then
            echo "사용법: sprint-manager.sh burndown <스프린트명>"
            exit 1
        fi
        
        # 번다운 차트 데이터 생성
        BURNDOWN_FILE="$HOME/Documents/github-automation/burndown-$SPRINT_NAME.csv"
        
        echo "date,remaining_issues" > "$BURNDOWN_FILE"
        
        # 최근 14일간의 데이터 생성
        for i in $(seq 0 13); do
            DATE=$(date -d "-$i days" +%Y-%m-%d)
            REMAINING=$(gh issue list --milestone "$SPRINT_NAME" --search "created:>=$DATE" --json number | jq length)
            echo "$DATE,$REMAINING" >> "$BURNDOWN_FILE"
        done
        
        echo "📊 번다운 차트 데이터가 생성되었습니다: $BURNDOWN_FILE"
        ;;
        
    "close")
        if [[ -z "$SPRINT_NAME" ]]; then
            echo "사용법: sprint-manager.sh close <스프린트명>"
            exit 1
        fi
        
        echo "🏁 스프린트 '$SPRINT_NAME' 종료 처리..."
        
        # 완료되지 않은 이슈들을 다음 스프린트로 이동
        OPEN_ISSUES=$(gh issue list --milestone "$SPRINT_NAME" --state open --json number,title)
        OPEN_COUNT=$(echo "$OPEN_ISSUES" | jq length)
        
        if [[ $OPEN_COUNT -gt 0 ]]; then
            echo "⚠️  $OPEN_COUNT개의 미완료 이슈가 있습니다."
            read -p "다음 스프린트명을 입력하세요 (또는 백로그로 이동하려면 Enter): " NEXT_SPRINT
            
            echo "$OPEN_ISSUES" | jq -r '.[] | .number' | while read issue_num; do
                if [[ -n "$NEXT_SPRINT" ]]; then
                    gh issue edit "$issue_num" --milestone "$NEXT_SPRINT"
                    echo "  📋 이슈 #$issue_num이 '$NEXT_SPRINT'로 이동되었습니다."
                else
                    gh issue edit "$issue_num" --milestone ""
                    echo "  📋 이슈 #$issue_num이 백로그로 이동되었습니다."
                fi
            done
        fi
        
        # 스프린트 리포트 생성
        REPORT_FILE="$HOME/Documents/github-automation/sprint-report-$SPRINT_NAME.md"
        
        cat > "$REPORT_FILE" << REPORTEOF
# 스프린트 '$SPRINT_NAME' 완료 보고서

## 📊 요약
- 총 이슈: $(gh issue list --milestone "$SPRINT_NAME" --json number | jq length)개
- 완료된 이슈: $(gh issue list --milestone "$SPRINT_NAME" --state closed --json number | jq length)개
- 미완료 이슈: $OPEN_COUNT개

## ✅ 완료된 이슈
$(gh issue list --milestone "$SPRINT_NAME" --state closed --json number,title | jq -r '.[] | "- [#\(.number)](\(.html_url)) \(.title)"')

## ⏳ 미완료 이슈  
$(gh issue list --milestone "$SPRINT_NAME" --state open --json number,title | jq -r '.[] | "- [#\(.number)](\(.html_url)) \(.title)"')

---
*보고서 생성일: $(date)*
REPORTEOF
        
        echo "✅ 스프린트 완료 보고서: $REPORT_FILE"
        
        # 마일스톤 닫기
        gh milestone edit "$SPRINT_NAME" --state closed
        echo "✅ 스프린트 '$SPRINT_NAME'이 종료되었습니다."
        ;;
        
    *)
        echo "GitHub 스프린트 관리 시스템"
        echo "사용법: sprint-manager.sh <command> [options]"
        echo
        echo "명령어:"
        echo "  create <스프린트명> [기간]  - 새 스프린트 생성"
        echo "  status <스프린트명>        - 스프린트 현황 조회"
        echo "  burndown <스프린트명>      - 번다운 차트 데이터 생성"
        echo "  close <스프린트명>         - 스프린트 종료 및 정리"
        ;;
esac
EOF

chmod +x ~/scripts/github-cli/issue/sprint-manager.sh
```

## 고급 이슈 분석 및 인사이트

### 1. 이슈 분석 대시보드

```bash
# 이슈 분석 및 인사이트 생성 스크립트
cat > ~/scripts/github-cli/issue/analytics.sh << 'EOF'
#!/bin/bash

# 이슈 분석 대시보드
function issue_analytics() {
    local period="${1:-30}"  # 기본 30일
    
    echo "📊 GitHub 이슈 분석 대시보드 (최근 ${period}일)"
    echo "=================================================="
    echo
    
    # 기본 통계
    echo "📈 기본 통계:"
    local total_issues=$(gh issue list --search "created:>=$(date -d "-${period} days" +%Y-%m-%d)" --json number | jq length)
    local closed_issues=$(gh issue list --search "created:>=$(date -d "-${period} days" +%Y-%m-%d) is:closed" --json number | jq length)
    local bug_issues=$(gh issue list --search "created:>=$(date -d "-${period} days" +%Y-%m-%d) label:bug" --json number | jq length)
    
    echo "  총 생성된 이슈: $total_issues개"
    echo "  완료된 이슈: $closed_issues개 ($(( closed_issues * 100 / total_issues ))%)"
    echo "  버그 이슈: $bug_issues개"
    echo
    
    # 라벨별 분석
    echo "🏷️  라벨별 분석:"
    gh issue list --search "created:>=$(date -d "-${period} days" +%Y-%m-%d)" --json labels | \
        jq -r '.[] | .labels[].name' | sort | uniq -c | sort -nr | head -10 | \
        while read count label; do
            echo "  $label: $count개"
        done
    echo
    
    # 담당자별 분석
    echo "👥 담당자별 분석:"
    gh issue list --search "created:>=$(date -d "-${period} days" +%Y-%m-%d)" --json assignees | \
        jq -r '.[] | .assignees[]?.login' | sort | uniq -c | sort -nr | head -5 | \
        while read count assignee; do
            echo "  $assignee: $count개"
        done
    echo
    
    # 우선순위별 분석
    echo "🎯 우선순위별 미해결 이슈:"
    for priority in critical high medium low; do
        local count=$(gh issue list --label "priority:$priority" --state open --json number | jq length)
        echo "  $priority: $count개"
    done
    echo
    
    # 오래된 이슈 알림
    echo "⚠️  장기 미해결 이슈 (30일 이상):"
    gh issue list --search "created:<$(date -d "-30 days" +%Y-%m-%d) is:open" --limit 5 --json number,title,createdAt | \
        jq -r '.[] | "  #\(.number): \(.title) (생성: \(.createdAt | split("T")[0]))"'
}

# 이슈 건강도 체크
function issue_health_check() {
    echo "🏥 이슈 건강도 체크"
    echo "==================="
    echo
    
    local warnings=0
    
    # 미할당 이슈 체크
    local unassigned=$(gh issue list --search "is:open no:assignee" --json number | jq length)
    if [[ $unassigned -gt 5 ]]; then
        echo "⚠️  미할당 이슈가 너무 많습니다: ${unassigned}개"
        warnings=$((warnings + 1))
    fi
    
    # 라벨 없는 이슈 체크
    local unlabeled=$(gh issue list --search "is:open no:label" --json number | jq length)
    if [[ $unlabeled -gt 3 ]]; then
        echo "⚠️  라벨이 없는 이슈가 있습니다: ${unlabeled}개"
        warnings=$((warnings + 1))
    fi
    
    # 오래된 이슈 체크
    local stale_issues=$(gh issue list --search "is:open created:<$(date -d "-60 days" +%Y-%m-%d)" --json number | jq length)
    if [[ $stale_issues -gt 10 ]]; then
        echo "⚠️  60일 이상 된 이슈가 많습니다: ${stale_issues}개"
        warnings=$((warnings + 1))
    fi
    
    # 높은 우선순위 이슈 체크
    local high_priority=$(gh issue list --label "priority:high,priority:critical" --state open --json number | jq length)
    if [[ $high_priority -gt 5 ]]; then
        echo "🚨 높은 우선순위 이슈가 누적되고 있습니다: ${high_priority}개"
        warnings=$((warnings + 1))
    fi
    
    if [[ $warnings -eq 0 ]]; then
        echo "✅ 이슈 관리 상태가 양호합니다!"
    else
        echo
        echo "💡 개선 제안:"
        echo "  - 미할당 이슈에 담당자를 지정하세요"
        echo "  - 라벨이 없는 이슈를 분류하세요"
        echo "  - 오래된 이슈를 검토하고 정리하세요"
        echo "  - 높은 우선순위 이슈를 우선 처리하세요"
    fi
}
EOF

chmod +x ~/scripts/github-cli/issue/analytics.sh

# .zshrc에 분석 스크립트 로딩 추가
cat >> ~/.zshrc << 'EOF'

# 이슈 분석 스크립트 로딩
source ~/scripts/github-cli/issue/analytics.sh
EOF

source ~/.zshrc
```

### 2. 자동 알림 시스템

```bash
# 일일 이슈 알림 시스템
cat > ~/scripts/github-cli/system/daily-issue-alert.sh << 'EOF'
#!/bin/bash

# 일일 이슈 상태 알림 시스템
# cron job으로 매일 실행: 0 9 * * * ~/scripts/github-cli/system/daily-issue-alert.sh

ALERT_FILE="$HOME/Documents/github-automation/daily-alert-$(date +%Y-%m-%d).md"

cat > "$ALERT_FILE" << 'ALERTHEADER'
# 📢 일일 이슈 알림

## 🚨 긴급 알림
ALERTHEADER

# 긴급 이슈 체크
CRITICAL_ISSUES=$(gh issue list --label "priority:critical" --state open --json number,title,createdAt)
CRITICAL_COUNT=$(echo "$CRITICAL_ISSUES" | jq length)

if [[ $CRITICAL_COUNT -gt 0 ]]; then
    echo "⚠️ **CRITICAL 우선순위 이슈 ${CRITICAL_COUNT}개가 미해결입니다!**" >> "$ALERT_FILE"
    echo "$CRITICAL_ISSUES" | jq -r '.[] | "- [#\(.number)](\(.html_url)) \(.title)"' >> "$ALERT_FILE"
else
    echo "✅ Critical 이슈가 없습니다." >> "$ALERT_FILE"
fi

echo "" >> "$ALERT_FILE"

# 장기 미해결 이슈
echo "## ⏰ 장기 미해결 이슈 (7일 이상)" >> "$ALERT_FILE"
STALE_ISSUES=$(gh issue list --search "is:open created:<$(date -d "-7 days" +%Y-%m-%d)" --limit 10 --json number,title,createdAt)
STALE_COUNT=$(echo "$STALE_ISSUES" | jq length)

if [[ $STALE_COUNT -gt 0 ]]; then
    echo "$STALE_ISSUES" | jq -r '.[] | "- [#\(.number)](\(.html_url)) \(.title) (생성: \(.createdAt | split("T")[0]))"' >> "$ALERT_FILE"
else
    echo "✅ 장기 미해결 이슈가 없습니다." >> "$ALERT_FILE"
fi

echo "" >> "$ALERT_FILE"

# 오늘의 할 일
echo "## 📋 오늘의 할 일" >> "$ALERT_FILE"
TODAY_ISSUES=$(gh issue list --assignee @me --state open --limit 5 --json number,title)
TODAY_COUNT=$(echo "$TODAY_ISSUES" | jq length)

if [[ $TODAY_COUNT -gt 0 ]]; then
    echo "$TODAY_ISSUES" | jq -r '.[] | "- [ ] [#\(.number)](\(.html_url)) \(.title)"' >> "$ALERT_FILE"
else
    echo "🎉 할당된 이슈가 없습니다!" >> "$ALERT_FILE"
fi

# 터미널에 요약 출력
echo "📢 일일 이슈 알림 생성됨: $ALERT_FILE"
if [[ $CRITICAL_COUNT -gt 0 ]]; then
    echo "🚨 CRITICAL 이슈 $CRITICAL_COUNT개 확인 필요!"
fi
if [[ $STALE_COUNT -gt 5 ]]; then
    echo "⏰ 장기 미해결 이슈 $STALE_COUNT개 정리 필요!"
fi

# Slack이나 이메일로 알림 발송 (선택적)
# slack-alert.sh "$ALERT_FILE" 2>/dev/null || true
EOF

chmod +x ~/scripts/github-cli/system/daily-issue-alert.sh
```

## 다음 편 미리보기

다음 편 **[프로젝트 관리 + 회사/개인 프로젝트 분리](github-cli-project-management-automation)**에서는:

- GitHub Projects v2 완전 자동화
- 칸반 보드 동적 관리
- 회사/개인 프로젝트 워크플로우 분리
- 팀 협업 자동화 시스템
- 프로젝트 메트릭스 및 리포팅

---

## 이 시리즈의 다른 글 보기

- [1편: 설치와 환경 구성](macos-github-cli-complete-guide)
- **2편: 이슈 관리 완전 자동화** ← 현재 위치
- [3편: 프로젝트 관리 + 회사/개인 프로젝트 분리](github-cli-project-management-automation)
- [4편: 위키 관리 완전 자동화](github-cli-wiki-automation-guide)
- [5편: 고급 워크플로우와 실무 적용](github-cli-advanced-workflows) 