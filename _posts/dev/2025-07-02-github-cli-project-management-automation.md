---
title: "macOS GitHub CLI 완전 자동화 시리즈 - 3편: 프로젝트 관리 완전 분리"
excerpt: "회사/개인 프로젝트 완전 분리, GitHub Projects v2 자동화, 팀 협업 워크플로우까지"
seo_title: "GitHub CLI 프로젝트 관리 자동화 3편 - 회사/개인 분리 - Thaki Cloud"
seo_description: "GitHub CLI로 회사와 개인 프로젝트를 완전 분리하고, Projects v2 자동화, 팀 협업 워크플로우를 구축하는 전문가 가이드"
date: 2025-07-02
categories:
  - dev
tags:
  - github-cli
  - project-management
  - automation
  - github-projects
  - team-collaboration
  - workflow-separation
author_profile: true
toc: true
canonical_url: "https://thakicloud.github.io/dev/github-cli-project-management-automation/"
---

⏱️ **예상 읽기 시간**: 18분

## 시리즈 소개

**macOS GitHub CLI 완전 자동화 시리즈** 3편에서는 회사와 개인 프로젝트를 완전히 분리하고, GitHub Projects v2를 자동화하는 방법을 다룹니다. 실무에서 바로 활용할 수 있는 프로젝트 관리 시스템을 구축해보겠습니다.

## 회사/개인 프로젝트 완전 분리 시스템

### 1. 컨텍스트 기반 프로젝트 관리

```bash
# 프로젝트 컨텍스트 관리 시스템 생성
cat > ~/scripts/github-cli/project/manage.sh << 'EOF'
#!/bin/bash

# 프로젝트 컨텍스트 분리 시스템

# 프로젝트 생성 (컨텍스트 자동 감지)
function create_project_smart() {
    local project_name="$1"
    local description="$2"
    local context=$(cat ~/.config/gh/current_context 2>/dev/null || echo 'personal')
    
    if [[ -z "$project_name" ]]; then
        echo "사용법: create_project_smart <프로젝트명> [설명]"
        return 1
    fi
    
    # 컨텍스트별 설정 적용
    case "$context" in
        "work")
            # 회사 프로젝트 템플릿
            gh project create \
                --title "🏢 $project_name" \
                --body "${description:-회사 프로젝트: $project_name}

## 📋 프로젝트 정보
- **타입**: 회사 프로젝트
- **생성일**: $(date '+%Y-%m-%d')
- **담당팀**: $(gh api user -q .login)

## 🎯 목표
- [ ] 요구사항 분석
- [ ] 설계 및 기획
- [ ] 개발 및 구현
- [ ] 테스트 및 검증
- [ ] 배포 및 운영

## 📊 메트릭스
- 예상 기간: 
- 우선순위: 
- 리소스: " \
                --format json > /tmp/project_info.json
            ;;
        "personal")
            # 개인 프로젝트 템플릿
            gh project create \
                --title "👤 $project_name" \
                --body "${description:-개인 프로젝트: $project_name}

## 💡 아이디어
${description:-프로젝트 설명을 작성하세요}

## 🚀 계획
- [ ] 아이디어 구체화
- [ ] 기술 스택 선정
- [ ] MVP 개발
- [ ] 테스트 및 개선
- [ ] 배포

## 📚 학습 목표
- 
- 

## 🔗 참고 자료
- " \
                --format json > /tmp/project_info.json
            ;;
    esac
    
    local project_id=$(cat /tmp/project_info.json | jq -r '.id')
    local project_url=$(cat /tmp/project_info.json | jq -r '.url')
    
    # 컨텍스트별 필드 생성
    setup_project_fields "$project_id" "$context"
    
    echo "✅ $context 프로젝트 '$project_name'이 생성되었습니다!"
    echo "🔗 $project_url"
    
    rm -f /tmp/project_info.json
}

# 프로젝트 필드 설정
function setup_project_fields() {
    local project_id="$1"
    local context="$2"
    
    # 공통 필드
    gh project field-create "$project_id" --name "Status" --type "single_select" \
        --options "📋 Backlog,🚀 In Progress,👀 Review,🧪 Testing,✅ Done"
    
    gh project field-create "$project_id" --name "Priority" --type "single_select" \
        --options "🔴 Critical,🟠 High,🟡 Medium,🟢 Low"
    
    case "$context" in
        "work")
            gh project field-create "$project_id" --name "Sprint" --type "text"
            gh project field-create "$project_id" --name "Story Points" --type "number"
            gh project field-create "$project_id" --name "Team" --type "single_select" \
                --options "Backend,Frontend,DevOps,QA,Design"
            gh project field-create "$project_id" --name "Due Date" --type "date"
            ;;
        "personal")
            gh project field-create "$project_id" --name "Learning Goal" --type "text"
            gh project field-create "$project_id" --name "Difficulty" --type "single_select" \
                --options "🟢 Easy,🟡 Medium,🔴 Hard"
            gh project field-create "$project_id" --name "Tech Stack" --type "text"
            ;;
    esac
    
    echo "📊 $context 프로젝트 필드가 설정되었습니다."
}

# 프로젝트 대시보드
function project_dashboard() {
    local context=$(cat ~/.config/gh/current_context 2>/dev/null || echo 'personal')
    
    echo "📊 $context 프로젝트 대시보드"
    echo "================================"
    echo
    
    # 활성 프로젝트 목록
    local projects=$(gh project list --owner @me --limit 10 --format json)
    local context_projects=$(echo "$projects" | jq -r --arg ctx "$context" '.[] | select(.title | startswith(if $ctx == "work" then "🏢" else "👤" end)) | "\(.number)|\(.title)|\(.url)"')
    
    if [[ -z "$context_projects" ]]; then
        echo "📝 $context 프로젝트가 없습니다."
        echo "💡 'create_project_smart <프로젝트명>'으로 생성하세요."
        return
    fi
    
    echo "📋 활성 프로젝트:"
    echo "$context_projects" | while IFS='|' read -r number title url; do
        echo "  $title"
        
        # 프로젝트 진행률 계산
        local total_items=$(gh project item-list "$number" --format json | jq length)
        local done_items=$(gh project item-list "$number" --format json | jq '[.[] | select(.status == "✅ Done")] | length')
        
        if [[ $total_items -gt 0 ]]; then
            local progress=$((done_items * 100 / total_items))
            echo "    진행률: $done_items/$total_items ($progress%)"
        else
            echo "    진행률: 아이템 없음"
        fi
        echo "    🔗 $url"
        echo
    done
}
EOF

chmod +x ~/scripts/github-cli/project/manage.sh

# .zshrc에 프로젝트 관리 스크립트 로딩 추가
cat >> ~/.zshrc << 'EOF'

# 프로젝트 관리 스크립트 로딩
source ~/scripts/github-cli/project/manage.sh
EOF

source ~/.zshrc
```

### 2. 자동 이슈-프로젝트 연동

```bash
# 이슈-프로젝트 자동 연동 시스템
cat > ~/scripts/github-cli/project/issue-linker.sh << 'EOF'
#!/bin/bash

# 이슈를 적절한 프로젝트에 자동 할당
# 사용법: issue-linker.sh <이슈번호> [프로젝트ID]

ISSUE_NUM="$1"
PROJECT_ID="$2"

if [[ -z "$ISSUE_NUM" ]]; then
    echo "사용법: issue-linker.sh <이슈번호> [프로젝트ID]"
    exit 1
fi

# 이슈 정보 가져오기
ISSUE_INFO=$(gh issue view "$ISSUE_NUM" --json title,labels,repository)
ISSUE_TITLE=$(echo "$ISSUE_INFO" | jq -r '.title')
ISSUE_LABELS=$(echo "$ISSUE_INFO" | jq -r '.labels[].name' | tr '\n' ' ')
REPO_NAME=$(echo "$ISSUE_INFO" | jq -r '.repository.name')

# 프로젝트 자동 선택 (ID가 지정되지 않은 경우)
if [[ -z "$PROJECT_ID" ]]; then
    CONTEXT=$(cat ~/.config/gh/current_context 2>/dev/null || echo 'personal')
    
    # 컨텍스트별 기본 프로젝트 찾기
    case "$CONTEXT" in
        "work")
            PROJECT_ID=$(gh project list --owner @me --format json | \
                jq -r '.[] | select(.title | contains("🏢")) | .number' | head -1)
            ;;
        "personal")
            PROJECT_ID=$(gh project list --owner @me --format json | \
                jq -r '.[] | select(.title | contains("👤")) | .number' | head -1)
            ;;
    esac
    
    if [[ -z "$PROJECT_ID" || "$PROJECT_ID" == "null" ]]; then
        echo "❌ 적절한 프로젝트를 찾을 수 없습니다."
        echo "💡 먼저 프로젝트를 생성하거나 프로젝트 ID를 지정하세요."
        exit 1
    fi
fi

# 이슈를 프로젝트에 추가
ITEM_ID=$(gh project item-add "$PROJECT_ID" --url "https://github.com/$(gh repo view --json owner,name -q '.owner.login + "/" + .name')/issues/$ISSUE_NUM" --format json | jq -r '.id')

if [[ "$ITEM_ID" == "null" ]]; then
    echo "❌ 이슈를 프로젝트에 추가하는데 실패했습니다."
    exit 1
fi

# 자동 필드 설정
echo "🔧 프로젝트 필드를 자동 설정 중..."

# 우선순위 설정
if echo "$ISSUE_LABELS" | grep -q "priority:critical"; then
    PRIORITY="🔴 Critical"
elif echo "$ISSUE_LABELS" | grep -q "priority:high"; then
    PRIORITY="🟠 High"
elif echo "$ISSUE_LABELS" | grep -q "priority:medium"; then
    PRIORITY="🟡 Medium"
else
    PRIORITY="🟢 Low"
fi

# 상태 설정
if echo "$ISSUE_LABELS" | grep -q "in-progress"; then
    STATUS="🚀 In Progress"
elif echo "$ISSUE_LABELS" | grep -q "review"; then
    STATUS="👀 Review"
elif echo "$ISSUE_LABELS" | grep -q "testing"; then
    STATUS="🧪 Testing"
else
    STATUS="📋 Backlog"
fi

# 필드 업데이트 (에러 무시)
gh project item-edit --project-id "$PROJECT_ID" --id "$ITEM_ID" --field-id "Priority" --single-select-option-id "$PRIORITY" 2>/dev/null || true
gh project item-edit --project-id "$PROJECT_ID" --id "$ITEM_ID" --field-id "Status" --single-select-option-id "$STATUS" 2>/dev/null || true

echo "✅ 이슈 #$ISSUE_NUM이 프로젝트에 추가되었습니다!"
echo "📋 제목: $ISSUE_TITLE"
echo "🎯 우선순위: $PRIORITY"
echo "📊 상태: $STATUS"
echo "🔗 프로젝트 링크: $(gh project view "$PROJECT_ID" --format json | jq -r '.url')"
EOF

chmod +x ~/scripts/github-cli/project/issue-linker.sh
```

### 3. 팀 협업 자동화

```bash
# 팀 협업 워크플로우 자동화 스크립트 생성
cat > ~/scripts/github-cli/project/collaboration.sh << 'EOF'
#!/bin/bash

# 팀 협업 자동화 함수들
function team_standup() {
    local project_id="$1"
    
    if [[ -z "$project_id" ]]; then
        echo "사용법: team_standup <프로젝트ID>"
        return 1
    fi
    
    echo "🗣️  팀 스탠드업 리포트 - $(date '+%Y-%m-%d')"
    echo "=========================================="
    echo
    
    # 어제 완료된 작업
    echo "✅ 어제 완료된 작업:"
    gh issue list --search "closed:$(date -d 'yesterday' '+%Y-%m-%d')" --limit 10 --json number,title,assignees | \
        jq -r '.[] | "  #\(.number): \(.title) (\(.assignees[0].login // "미할당"))"'
    echo
    
    # 오늘 진행할 작업
    echo "🚀 오늘 진행할 작업:"
    gh project item-list "$project_id" --format json | \
        jq -r '.[] | select(.status == "🚀 In Progress") | "  \(.content.title) (\(.assignees[0].login // "미할당"))"'
    echo
    
    # 블로커
    echo "🚫 블로커 및 이슈:"
    gh issue list --label "blocked" --state open --json number,title | \
        jq -r '.[] | "  #\(.number): \(.title)"'
    
    [[ $(gh issue list --label "blocked" --state open --json number | jq length) -eq 0 ]] && echo "  없음"
    echo
}

# 코드 리뷰 자동 할당
function auto_assign_reviewers() {
    local pr_number="$1"
    
    if [[ -z "$pr_number" ]]; then
        echo "사용법: auto_assign_reviewers <PR번호>"
        return 1
    fi
    
    local context=$(cat ~/.config/gh/current_context 2>/dev/null || echo 'personal')
    
    if [[ "$context" == "work" ]]; then
        # 회사 프로젝트: 팀 리드와 시니어 개발자 할당
        gh pr edit "$pr_number" --add-reviewer "@team-leads,@senior-devs"
        echo "🔍 팀 리드와 시니어 개발자가 리뷰어로 할당되었습니다."
    else
        # 개인 프로젝트: 자신을 리뷰어로 할당 (셀프 리뷰)
        gh pr edit "$pr_number" --add-reviewer "@me"
        echo "👤 셀프 리뷰가 설정되었습니다."
    fi
    
    # PR 상태를 자동으로 Ready for review로 변경
    gh pr ready "$pr_number"
    echo "✅ PR이 리뷰 준비 상태로 변경되었습니다."
}

# 프로젝트 메트릭스 리포트
function project_metrics() {
    local project_id="$1"
    local days="${2:-7}"
    
    if [[ -z "$project_id" ]]; then
        echo "사용법: project_metrics <프로젝트ID> [기간(일)]"
        return 1
    fi
    
    echo "📊 프로젝트 메트릭스 (최근 ${days}일)"
    echo "====================================="
    echo
    
    # 벨로시티 계산
    local completed_issues=$(gh issue list --search "closed:>=$(date -d "-${days} days" '+%Y-%m-%d')" --json number | jq length)
    local velocity=$(echo "scale=1; $completed_issues / $days" | bc -l)
    
    echo "🚀 벨로시티: $velocity 이슈/일 (총 $completed_issues개 완료)"
    echo
    
    # 리드 타임 계산 (평균)
    echo "⏱️  평균 리드 타임:"
    gh issue list --search "closed:>=$(date -d "-${days} days" '+%Y-%m-%d')" --limit 10 --json createdAt,closedAt | \
        jq -r '.[] | ((.closedAt | fromdateiso8601) - (.createdAt | fromdateiso8601)) / 86400' | \
        awk '{sum+=$1; count++} END {if(count>0) printf "  %.1f일\n", sum/count; else print "  데이터 없음"}'
    echo
    
    # 현재 진행 상황
    local total_items=$(gh project item-list "$project_id" --format json | jq length)
    local done_items=$(gh project item-list "$project_id" --format json | jq '[.[] | select(.status == "✅ Done")] | length')
    local progress=$((done_items * 100 / total_items))
    
    echo "📈 전체 진행률: $done_items/$total_items ($progress%)"
    echo
    
    # 팀별 기여도 (회사 프로젝트인 경우)
    local context=$(cat ~/.config/gh/current_context 2>/dev/null || echo 'personal')
    if [[ "$context" == "work" ]]; then
        echo "👥 팀별 기여도:"
        gh issue list --search "closed:>=$(date -d "-${days} days" '+%Y-%m-%d')" --json assignees | \
            jq -r '.[] | .assignees[]?.login' | sort | uniq -c | sort -nr | \
            while read count assignee; do
                echo "  $assignee: $count개"
            done
    fi
}
EOF

chmod +x ~/scripts/github-cli/project/collaboration.sh

# .zshrc에 협업 스크립트 로딩 추가
cat >> ~/.zshrc << 'EOF'

# 프로젝트 협업 스크립트 로딩
source ~/scripts/github-cli/project/collaboration.sh
EOF

source ~/.zshrc
```

## GitHub Projects v2 고급 자동화

### 1. 동적 뷰 관리

```bash
# Projects v2 뷰 자동화 스크립트
cat > ~/scripts/github-cli/project/view-manager.sh << 'EOF'
#!/bin/bash

# GitHub Projects v2 뷰 자동 관리
# 사용법: view-manager.sh <command> <project-id> [options]

COMMAND="$1"
PROJECT_ID="$2"

case "$COMMAND" in
    "setup-views")
        if [[ -z "$PROJECT_ID" ]]; then
            echo "사용법: view-manager.sh setup-views <프로젝트ID>"
            exit 1
        fi
        
        echo "🎯 프로젝트 뷰 자동 설정 중..."
        
        # 스프린트 뷰 (현재 스프린트만)
        gh project view-create "$PROJECT_ID" \
            --name "🏃‍♂️ Current Sprint" \
            --layout "board" \
            --filter "Sprint:\"$(date '+Sprint %Y-%U')\""
        
        # 우선순위별 뷰
        gh project view-create "$PROJECT_ID" \
            --name "🔥 High Priority" \
            --layout "table" \
            --filter "Priority:\"🔴 Critical\",\"🟠 High\""
        
        # 팀별 뷰 (회사 프로젝트)
        gh project view-create "$PROJECT_ID" \
            --name "🏗️ Backend Team" \
            --layout "board" \
            --filter "Team:Backend"
        
        # 완료된 작업 뷰
        gh project view-create "$PROJECT_ID" \
            --name "✅ Completed" \
            --layout "table" \
            --filter "Status:\"✅ Done\""
        
        echo "✅ 프로젝트 뷰가 설정되었습니다!"
        ;;
        
    "update-sprint")
        local sprint_name="${3:-Sprint $(date '+%Y-%U')}"
        
        echo "🔄 스프린트 뷰 업데이트: $sprint_name"
        
        # 스프린트 뷰 필터 업데이트
        gh project view-edit "$PROJECT_ID" \
            --name "🏃‍♂️ Current Sprint" \
            --filter "Sprint:\"$sprint_name\""
        
        echo "✅ 스프린트 뷰가 업데이트되었습니다."
        ;;
        
    "analytics")
        echo "📊 프로젝트 분석 뷰 생성 중..."
        
        # 번다운 차트용 뷰
        gh project view-create "$PROJECT_ID" \
            --name "📈 Burndown" \
            --layout "table" \
            --filter "Status:\"📋 Backlog\",\"🚀 In Progress\",\"👀 Review\",\"🧪 Testing\""
        
        # 리드 타임 분석용 뷰
        gh project view-create "$PROJECT_ID" \
            --name "⏱️ Lead Time Analysis" \
            --layout "table" \
            --filter "Status:\"✅ Done\""
        
        echo "✅ 분석 뷰가 생성되었습니다."
        ;;
        
    *)
        echo "GitHub Projects v2 뷰 관리자"
        echo "사용법: view-manager.sh <command> <project-id> [options]"
        echo
        echo "명령어:"
        echo "  setup-views     - 기본 뷰들 자동 생성"
        echo "  update-sprint   - 스프린트 뷰 업데이트"
        echo "  analytics       - 분석용 뷰 생성"
        ;;
esac
EOF

chmod +x ~/scripts/github-cli/project/view-manager.sh
```

### 2. 자동 보고서 생성

```bash
# 프로젝트 보고서 자동 생성
cat > ~/scripts/github-cli/system/project-reporter.sh << 'EOF'
#!/bin/bash

# 프로젝트 진행 보고서 자동 생성
PROJECT_ID="$1"
REPORT_TYPE="${2:-weekly}"

if [[ -z "$PROJECT_ID" ]]; then
    echo "사용법: project-reporter.sh <프로젝트ID> [weekly|monthly|sprint]"
    exit 1
fi

# 프로젝트 정보 가져오기
PROJECT_INFO=$(gh project view "$PROJECT_ID" --format json)
PROJECT_TITLE=$(echo "$PROJECT_INFO" | jq -r '.title')
PROJECT_URL=$(echo "$PROJECT_INFO" | jq -r '.url')

# 보고서 파일 경로
REPORT_DATE=$(date '+%Y-%m-%d')
REPORT_FILE="$HOME/Documents/github-automation/project-report-$PROJECT_ID-$REPORT_DATE.md"

# 보고서 헤더 생성
cat > "$REPORT_FILE" << REPORTHEADER
# 📊 프로젝트 진행 보고서

**프로젝트**: $PROJECT_TITLE  
**보고서 유형**: $REPORT_TYPE  
**생성일**: $REPORT_DATE  
**링크**: [$PROJECT_TITLE]($PROJECT_URL)

## 📈 요약
REPORTHEADER

# 기간별 분석
case "$REPORT_TYPE" in
    "weekly")
        PERIOD_START=$(date -d '7 days ago' '+%Y-%m-%d')
        PERIOD_DESC="지난 주"
        ;;
    "monthly")
        PERIOD_START=$(date -d '30 days ago' '+%Y-%m-%d')
        PERIOD_DESC="지난 달"
        ;;
    "sprint")
        PERIOD_START=$(date -d '14 days ago' '+%Y-%m-%d')
        PERIOD_DESC="현재 스프린트"
        ;;
esac

# 진행률 계산
TOTAL_ITEMS=$(gh project item-list "$PROJECT_ID" --format json | jq length)
DONE_ITEMS=$(gh project item-list "$PROJECT_ID" --format json | jq '[.[] | select(.status == "✅ Done")] | length')
PROGRESS=$((DONE_ITEMS * 100 / TOTAL_ITEMS))

# 보고서 내용 추가
cat >> "$REPORT_FILE" << REPORTBODY

### 전체 진행률
- **완료**: $DONE_ITEMS개
- **전체**: $TOTAL_ITEMS개  
- **진행률**: $PROGRESS%

### $PERIOD_DESC 성과
- **완료된 이슈**: $(gh issue list --search "closed:>=$PERIOD_START" --json number | jq length)개
- **새로 생성된 이슈**: $(gh issue list --search "created:>=$PERIOD_START" --json number | jq length)개

## 📋 상태별 현황

### 🚀 진행 중
$(gh project item-list "$PROJECT_ID" --format json | jq -r '.[] | select(.status == "🚀 In Progress") | "- \(.content.title)"')

### 👀 리뷰 대기
$(gh project item-list "$PROJECT_ID" --format json | jq -r '.[] | select(.status == "👀 Review") | "- \(.content.title)"')

### 🧪 테스트 중
$(gh project item-list "$PROJECT_ID" --format json | jq -r '.[] | select(.status == "🧪 Testing") | "- \(.content.title)"')

## 🎯 다음 주 계획
- [ ] 
- [ ] 
- [ ] 

## 🚨 주의사항 및 블로커
$(gh issue list --label "blocked" --state open --json number,title | jq -r '.[] | "- [#\(.number)](\(.html_url)) \(.title)"')

---
*이 보고서는 자동으로 생성되었습니다.*
REPORTBODY

echo "✅ 프로젝트 보고서가 생성되었습니다: $REPORT_FILE"

# 보고서 요약을 터미널에 출력
echo
echo "📊 보고서 요약:"
echo "  진행률: $PROGRESS% ($DONE_ITEMS/$TOTAL_ITEMS)"
echo "  $PERIOD_DESC 완료: $(gh issue list --search "closed:>=$PERIOD_START" --json number | jq length)개 이슈"
EOF

chmod +x ~/scripts/github-cli/system/project-reporter.sh
```

## 다음 편 미리보기

다음 편 **[위키 관리 완전 자동화](github-cli-wiki-automation-guide)**에서는:

- 코드 기반 위키 자동 생성
- API 문서 자동 동기화  
- 다국어 문서 관리
- 버전별 문서 관리
- 문서 품질 자동 검증

---

## 이 시리즈의 다른 글 보기

- [1편: 설치와 환경 구성](macos-github-cli-complete-guide)
- [2편: 이슈 관리 완전 자동화](macos-github-cli-issue-automation-guide)
- **3편: 프로젝트 관리 + 회사/개인 프로젝트 분리** ← 현재 위치
- [4편: 위키 관리 완전 자동화](github-cli-wiki-automation-guide)
- [5편: 고급 워크플로우와 실무 적용](github-cli-advanced-workflows) 