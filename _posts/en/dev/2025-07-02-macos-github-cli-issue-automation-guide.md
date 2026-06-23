---
title: "macOS GitHub CLI Complete Automation Series - Part 2: Full Issue Management Automation"
excerpt: "From intelligent issue creation and automatic labeling to sprint planning - a professional guide to automating every aspect of GitHub issue management"
seo_title: "macOS GitHub CLI Automation Part 2 - Issue Management Automation - Thaki Cloud"
seo_description: "How to fully automate GitHub CLI workflows from issue creation and classification to labeling, assignee allocation, and sprint planning. A complete guide to building an intelligent issue management system."
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
toc_label: "Table of Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/en/dev/macos-github-cli-issue-automation-guide/"
lang: en
reading_time: true
published: false
---

⏱️ **Estimated reading time**: 25 min

## Series Introduction

This post is Part 2 of the **macOS GitHub CLI Complete Automation Series**. Building on the environment established in Part 1, it covers how to fully automate GitHub issue management.

GitHub issues go far beyond simple bug tracking - they are the central axis for managing every task in a project. In this part, we will build a professional-grade system that automates the entire process: **intelligent issue creation**, **automatic classification**, **dynamic labeling**, and **sprint planning automation**.

## Part 2: Full Issue Management Automation

### Goals
- Build an intelligent issue creation and classification system
- Implement automatic labeling and assignee allocation mechanisms
- Create a dynamic issue template generation system
- Manage issue status through workflow-based automation
- Automate sprint planning and backlog management

## Intelligent Issue Creation System

### 1. AI-Based Issue Classifier

```bash
# Issue classification and automatic labeling system
cat > ~/scripts/github-cli/issue/create.sh << 'EOF'
#!/bin/bash

# Intelligent issue creation system
# Usage: smart-issue-creator.sh <title> [description] [priority]

TITLE="$1"
DESCRIPTION="$2"
PRIORITY="${3:-medium}"

if [[ -z "$TITLE" ]]; then
    echo "Usage: smart-issue-creator.sh <title> [description] [priority:low|medium|high|critical]"
    exit 1
fi

# Keyword-based automatic classification
function classify_issue() {
    local title_lower=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]')
    local desc_lower=$(echo "$DESCRIPTION" | tr '[:upper:]' '[:lower:]')
    local combined="$title_lower $desc_lower"
    
    # Bug-related keywords
    if echo "$combined" | grep -E "(bug|error|crash|fail|broken|fix|issue)" >/dev/null; then
        echo "bug"
    # Feature enhancement keywords
    elif echo "$combined" | grep -E "(feature|enhance|improve|add|new|implement)" >/dev/null; then
        echo "enhancement"
    # Documentation-related keywords
    elif echo "$combined" | grep -E "(doc|readme|wiki|guide|manual)" >/dev/null; then
        echo "documentation"
    # Performance-related keywords
    elif echo "$combined" | grep -E "(performance|slow|speed|optimize|memory|cpu)" >/dev/null; then
        echo "performance"
    # Security-related keywords
    elif echo "$combined" | grep -E "(security|vulnerable|exploit|auth|permission)" >/dev/null; then
        echo "security"
    # Testing-related keywords
    elif echo "$combined" | grep -E "(test|testing|spec|coverage|unit|integration)" >/dev/null; then
        echo "testing"
    else
        echo "general"
    fi
}

# Set label color by priority
function get_priority_color() {
    case "$1" in
        "critical") echo "b60205" ;;
        "high") echo "d93f0b" ;;
        "medium") echo "fbca04" ;;
        "low") echo "0e8a16" ;;
        *) echo "fbca04" ;;
    esac
}

# Automatic assignee allocation
function auto_assign() {
    local issue_type="$1"
    local context=$(cat ~/.config/gh/current_context 2>/dev/null || echo 'personal')
    
    # Assign team members for work projects
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

# Execute issue creation
ISSUE_TYPE=$(classify_issue)
ASSIGNEE=$(auto_assign "$ISSUE_TYPE")
PRIORITY_COLOR=$(get_priority_color "$PRIORITY")

# Create labels if they do not exist
gh label create "$ISSUE_TYPE" --color "1d76db" --description "Auto-classified as $ISSUE_TYPE" 2>/dev/null || true
gh label create "priority:$PRIORITY" --color "$PRIORITY_COLOR" --description "$PRIORITY priority issue" 2>/dev/null || true

# Generate detailed issue body
ISSUE_BODY="## Issue Information

**Classification**: $ISSUE_TYPE
**Priority**: $PRIORITY
**Auto-assigned**: $ASSIGNEE

## Description

${DESCRIPTION:-Please write a detailed description of the issue.}

## Details

### Steps to Reproduce (for bugs)
1. 
2. 
3. 

### Expected Result


### Actual Result


### Environment
- OS: $(uname -s)
- Browser: 
- Version: 

## Acceptance Criteria

- [ ] 

## Related Issues


---
*This issue was automatically classified. If the classification is incorrect, please update the labels.*"

# Create the issue
CREATED_ISSUE=$(gh issue create \
    --title "$TITLE" \
    --body "$ISSUE_BODY" \
    --label "$ISSUE_TYPE,priority:$PRIORITY" \
    --assignee "$ASSIGNEE" \
    --format json)

ISSUE_NUMBER=$(echo "$CREATED_ISSUE" | jq -r '.number')
ISSUE_URL=$(echo "$CREATED_ISSUE" | jq -r '.url')

echo "Intelligent issue created!"
echo "#$ISSUE_NUMBER: $TITLE"
echo "Classification: $ISSUE_TYPE (Priority: $PRIORITY)"
echo "Assignee: $ASSIGNEE"
echo "$ISSUE_URL"

# Check whether to start work immediately
if [[ "$ASSIGNEE" == "@me" ]]; then
    read -p "Would you like to start working on this now? (y/N): " start_work
    if [[ "$start_work" =~ ^[Yy]$ ]]; then
        # Call the issue_start function created in Part 1
        issue_start "$ISSUE_NUMBER"
    fi
fi
EOF

chmod +x ~/scripts/github-cli/issue/create.sh
```

### 2. Dynamic Issue Template Generator

```bash
# Dynamic issue template generation system
cat > ~/scripts/github-cli/issue/template-generator.sh << 'EOF'
#!/bin/bash

# Automatically generate issue templates by project type
# Usage: template-generator.sh [project-type]

PROJECT_TYPE="${1:-general}"

# Detect project type
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

# Bug report template by project type
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

# Common feature request template
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

echo "Issue templates for $PROJECT_TYPE project created!"
echo "Check the .github/ISSUE_TEMPLATE/ directory."
EOF

chmod +x ~/scripts/github-cli/issue/template-generator.sh
```

## Issue Workflow Automation

### 1. Status-Based Automatic Management

```bash
# Create issue workflow automation script
cat > ~/scripts/github-cli/issue/workflow.sh << 'EOF'
#!/bin/bash

# Issue workflow automation functions

# Change issue status and trigger automatic actions
function issue_status() {
    local issue_num="$1"
    local status="$2"
    
    if [[ -z "$issue_num" || -z "$status" ]]; then
        echo "Usage: issue_status <issue-number> <status>"
        echo "Status: todo, in-progress, review, testing, done"
        return 1
    fi
    
    case "$status" in
        "todo")
            gh issue edit "$issue_num" \
                --remove-label "in-progress,review,testing" \
                --add-label "todo" \
                --milestone ""
            gh issue comment "$issue_num" --body "Issue moved to TODO status."
            ;;
            
        "in-progress") 
            gh issue edit "$issue_num" \
                --remove-label "todo,review,testing" \
                --add-label "in-progress" \
                --assignee "@me"
            gh issue comment "$issue_num" --body "Work started. Assignee: $(gh api user -q .login)"
            
            # Automatically create a branch
            issue_start "$issue_num"
            ;;
            
        "review")
            gh issue edit "$issue_num" \
                --remove-label "todo,in-progress,testing" \
                --add-label "review"
            
            # If a PR exists, automatically request review
            local pr_number=$(gh pr list --search "closes:#$issue_num" --json number -q '.[0].number')
            if [[ -n "$pr_number" && "$pr_number" != "null" ]]; then
                gh pr ready "$pr_number"
                gh pr edit "$pr_number" --add-reviewer "@team-leads"
                gh issue comment "$issue_num" --body "Code review requested. PR #$pr_number"
            fi
            ;;
            
        "testing")
            gh issue edit "$issue_num" \
                --remove-label "todo,in-progress,review" \
                --add-label "testing"
            gh issue comment "$issue_num" --body "In testing phase. Please check with the QA team."
            ;;
            
        "done")
            gh issue close "$issue_num"
            gh issue comment "$issue_num" --body "Issue completed. Thank you everyone who worked on this!"
            
            # Clean up related branch
            local current_branch=$(git branch --show-current)
            if [[ "$current_branch" == *"issue-$issue_num"* ]]; then
                git checkout main
                git branch -d "$current_branch" 2>/dev/null || true
                echo "Branch '$current_branch' cleaned up."
            fi
            ;;
            
        *)
            echo "Unsupported status."
            echo "Available statuses: todo, in-progress, review, testing, done"
            return 1
            ;;
    esac
    
    echo "Issue #$issue_num status changed to '$status'."
}

# Bulk issue status change
function bulk_issue_status() {
    local status="$1"
    shift
    local issues=("$@")
    
    if [[ -z "$status" || ${#issues[@]} -eq 0 ]]; then
        echo "Usage: bulk_issue_status <status> <issue1> <issue2> ..."
        return 1
    fi
    
    echo "Changing status of ${#issues[@]} issues to '$status'..."
    
    for issue in "${issues[@]}"; do
        echo "Processing: #$issue"
        issue_status "$issue" "$status"
        sleep 1  # Avoid API rate limits
    done
    
    echo "All issue status changes complete."
}

# Automatic priority adjustment
function auto_prioritize() {
    local issue_num="$1"
    
    if [[ -z "$issue_num" ]]; then
        echo "Usage: auto_prioritize <issue-number>"
        return 1
    fi
    
    # Fetch issue information
    local issue_info=$(gh issue view "$issue_num" --json labels,comments,reactions,createdAt)
    local labels=$(echo "$issue_info" | jq -r '.labels[].name' | tr '\n' ' ')
    local comment_count=$(echo "$issue_info" | jq '.comments | length')
    local reaction_count=$(echo "$issue_info" | jq '.reactions.totalCount')
    local created_days_ago=$(( ($(date +%s) - $(date -d "$(echo "$issue_info" | jq -r '.createdAt')" +%s)) / 86400 ))
    
    local priority="medium"
    
    # Priority calculation logic
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
    
    # Remove existing priority labels and set new priority
    gh issue edit "$issue_num" \
        --remove-label "priority:low,priority:medium,priority:high,priority:critical" \
        --add-label "priority:$priority"
    
    echo "Issue #$issue_num priority adjusted to '$priority'."
    echo "Analysis: $comment_count comments, $reaction_count reactions, created ${created_days_ago} days ago"
}
EOF

chmod +x ~/scripts/github-cli/issue/workflow.sh

# Add script loading to .zshrc
cat >> ~/.zshrc << 'EOF'

# Load issue management script
source ~/scripts/github-cli/issue/workflow.sh
EOF

source ~/.zshrc
```

### 2. Sprint Planning Automation

```bash
# Sprint management system
cat > ~/scripts/github-cli/issue/sprint-manager.sh << 'EOF'
#!/bin/bash

# Sprint management automation system
# Usage: sprint-manager.sh <command> [options]

COMMAND="$1"
SPRINT_NAME="$2"
DURATION="${3:-14}"  # Default 2 weeks

case "$COMMAND" in
    "create")
        if [[ -z "$SPRINT_NAME" ]]; then
            echo "Usage: sprint-manager.sh create <sprint-name> [duration-days]"
            exit 1
        fi
        
        # Create sprint milestone
        START_DATE=$(date +%Y-%m-%d)
        END_DATE=$(date -d "+${DURATION} days" +%Y-%m-%d)
        
        gh milestone create "$SPRINT_NAME" \
            --description "Sprint period: $START_DATE to $END_DATE" \
            --due-date "$END_DATE"
        
        echo "Sprint '$SPRINT_NAME' created."
        echo "Period: $START_DATE to $END_DATE"
        
        # Automatically assign issues from backlog
        echo "Automatically assigning issues from backlog..."
        
        # Add high-priority issues to the sprint
        gh issue list --label "priority:high" --state open --limit 5 --json number | \
            jq -r '.[] | .number' | while read issue_num; do
            gh issue edit "$issue_num" --milestone "$SPRINT_NAME"
            echo "  Issue #$issue_num added to sprint."
        done
        ;;
        
    "status")
        if [[ -z "$SPRINT_NAME" ]]; then
            echo "Usage: sprint-manager.sh status <sprint-name>"
            exit 1
        fi
        
        echo "Sprint '$SPRINT_NAME' Status"
        echo "================================"
        
        # Total issue count
        TOTAL_ISSUES=$(gh issue list --milestone "$SPRINT_NAME" --json number | jq length)
        CLOSED_ISSUES=$(gh issue list --milestone "$SPRINT_NAME" --state closed --json number | jq length)
        OPEN_ISSUES=$((TOTAL_ISSUES - CLOSED_ISSUES))
        
        echo "Progress: $CLOSED_ISSUES/$TOTAL_ISSUES ($(( CLOSED_ISSUES * 100 / TOTAL_ISSUES ))%)"
        echo
        
        echo "Issues by status:"
        echo "  Open issues: $OPEN_ISSUES"
        echo "  Completed issues: $CLOSED_ISSUES"
        echo
        
        echo "In-progress issues:"
        gh issue list --milestone "$SPRINT_NAME" --state open --json number,title,assignees | \
            jq -r '.[] | "  #\(.number): \(.title) (\(.assignees[0].login // "unassigned"))"'
        ;;
        
    "burndown")
        if [[ -z "$SPRINT_NAME" ]]; then
            echo "Usage: sprint-manager.sh burndown <sprint-name>"
            exit 1
        fi
        
        # Generate burndown chart data
        BURNDOWN_FILE="$HOME/Documents/github-automation/burndown-$SPRINT_NAME.csv"
        
        echo "date,remaining_issues" > "$BURNDOWN_FILE"
        
        # Generate data for the last 14 days
        for i in $(seq 0 13); do
            DATE=$(date -d "-$i days" +%Y-%m-%d)
            REMAINING=$(gh issue list --milestone "$SPRINT_NAME" --search "created:>=$DATE" --json number | jq length)
            echo "$DATE,$REMAINING" >> "$BURNDOWN_FILE"
        done
        
        echo "Burndown chart data generated: $BURNDOWN_FILE"
        ;;
        
    "close")
        if [[ -z "$SPRINT_NAME" ]]; then
            echo "Usage: sprint-manager.sh close <sprint-name>"
            exit 1
        fi
        
        echo "Closing sprint '$SPRINT_NAME'..."
        
        # Move incomplete issues to the next sprint
        OPEN_ISSUES=$(gh issue list --milestone "$SPRINT_NAME" --state open --json number,title)
        OPEN_COUNT=$(echo "$OPEN_ISSUES" | jq length)
        
        if [[ $OPEN_COUNT -gt 0 ]]; then
            echo "$OPEN_COUNT incomplete issues remain."
            read -p "Enter next sprint name (or press Enter to move to backlog): " NEXT_SPRINT
            
            echo "$OPEN_ISSUES" | jq -r '.[] | .number' | while read issue_num; do
                if [[ -n "$NEXT_SPRINT" ]]; then
                    gh issue edit "$issue_num" --milestone "$NEXT_SPRINT"
                    echo "  Issue #$issue_num moved to '$NEXT_SPRINT'."
                else
                    gh issue edit "$issue_num" --milestone ""
                    echo "  Issue #$issue_num moved to backlog."
                fi
            done
        fi
        
        # Generate sprint report
        REPORT_FILE="$HOME/Documents/github-automation/sprint-report-$SPRINT_NAME.md"
        
        cat > "$REPORT_FILE" << REPORTEOF
# Sprint '$SPRINT_NAME' Completion Report

## Summary
- Total issues: $(gh issue list --milestone "$SPRINT_NAME" --json number | jq length)
- Completed issues: $(gh issue list --milestone "$SPRINT_NAME" --state closed --json number | jq length)
- Incomplete issues: $OPEN_COUNT

## Completed Issues
$(gh issue list --milestone "$SPRINT_NAME" --state closed --json number,title | jq -r '.[] | "- [#\(.number)](\(.html_url)) \(.title)"')

## Incomplete Issues
$(gh issue list --milestone "$SPRINT_NAME" --state open --json number,title | jq -r '.[] | "- [#\(.number)](\(.html_url)) \(.title)"')

---
*Report generated: $(date)*
REPORTEOF
        
        echo "Sprint completion report: $REPORT_FILE"
        
        # Close milestone
        gh milestone edit "$SPRINT_NAME" --state closed
        echo "Sprint '$SPRINT_NAME' closed."
        ;;
        
    *)
        echo "GitHub Sprint Management System"
        echo "Usage: sprint-manager.sh <command> [options]"
        echo
        echo "Commands:"
        echo "  create <sprint-name> [duration]  - Create a new sprint"
        echo "  status <sprint-name>              - View sprint status"
        echo "  burndown <sprint-name>            - Generate burndown chart data"
        echo "  close <sprint-name>               - Close and wrap up sprint"
        ;;
esac
EOF

chmod +x ~/scripts/github-cli/issue/sprint-manager.sh
```

## Advanced Issue Analysis and Insights

### 1. Issue Analytics Dashboard

```bash
# Issue analysis and insights generation script
cat > ~/scripts/github-cli/issue/analytics.sh << 'EOF'
#!/bin/bash

# Issue analytics dashboard
function issue_analytics() {
    local period="${1:-30}"  # Default 30 days
    
    echo "GitHub Issue Analytics Dashboard (Last ${period} days)"
    echo "=================================================="
    echo
    
    # Basic statistics
    echo "Basic Statistics:"
    local total_issues=$(gh issue list --search "created:>=$(date -d "-${period} days" +%Y-%m-%d)" --json number | jq length)
    local closed_issues=$(gh issue list --search "created:>=$(date -d "-${period} days" +%Y-%m-%d) is:closed" --json number | jq length)
    local bug_issues=$(gh issue list --search "created:>=$(date -d "-${period} days" +%Y-%m-%d) label:bug" --json number | jq length)
    
    echo "  Total issues created: $total_issues"
    echo "  Completed issues: $closed_issues ($(( closed_issues * 100 / total_issues ))%)"
    echo "  Bug issues: $bug_issues"
    echo
    
    # Analysis by label
    echo "Analysis by label:"
    gh issue list --search "created:>=$(date -d "-${period} days" +%Y-%m-%d)" --json labels | \
        jq -r '.[] | .labels[].name' | sort | uniq -c | sort -nr | head -10 | \
        while read count label; do
            echo "  $label: $count"
        done
    echo
    
    # Analysis by assignee
    echo "Analysis by assignee:"
    gh issue list --search "created:>=$(date -d "-${period} days" +%Y-%m-%d)" --json assignees | \
        jq -r '.[] | .assignees[]?.login' | sort | uniq -c | sort -nr | head -5 | \
        while read count assignee; do
            echo "  $assignee: $count"
        done
    echo
    
    # Open issues by priority
    echo "Open issues by priority:"
    for priority in critical high medium low; do
        local count=$(gh issue list --label "priority:$priority" --state open --json number | jq length)
        echo "  $priority: $count"
    done
    echo
    
    # Long-standing open issues
    echo "Long-standing open issues (30+ days):"
    gh issue list --search "created:<$(date -d "-30 days" +%Y-%m-%d) is:open" --limit 5 --json number,title,createdAt | \
        jq -r '.[] | "  #\(.number): \(.title) (created: \(.createdAt | split("T")[0]))"'
}

# Issue health check
function issue_health_check() {
    echo "Issue Health Check"
    echo "==================="
    echo
    
    local warnings=0
    
    # Check for unassigned issues
    local unassigned=$(gh issue list --search "is:open no:assignee" --json number | jq length)
    if [[ $unassigned -gt 5 ]]; then
        echo "Too many unassigned issues: ${unassigned}"
        warnings=$((warnings + 1))
    fi
    
    # Check for unlabeled issues
    local unlabeled=$(gh issue list --search "is:open no:label" --json number | jq length)
    if [[ $unlabeled -gt 3 ]]; then
        echo "Issues without labels: ${unlabeled}"
        warnings=$((warnings + 1))
    fi
    
    # Check for stale issues
    local stale_issues=$(gh issue list --search "is:open created:<$(date -d "-60 days" +%Y-%m-%d)" --json number | jq length)
    if [[ $stale_issues -gt 10 ]]; then
        echo "Many issues are 60+ days old: ${stale_issues}"
        warnings=$((warnings + 1))
    fi
    
    # Check for high-priority issues
    local high_priority=$(gh issue list --label "priority:high,priority:critical" --state open --json number | jq length)
    if [[ $high_priority -gt 5 ]]; then
        echo "High-priority issues are accumulating: ${high_priority}"
        warnings=$((warnings + 1))
    fi
    
    if [[ $warnings -eq 0 ]]; then
        echo "Issue management is in good shape!"
    else
        echo
        echo "Improvement suggestions:"
        echo "  - Assign owners to unassigned issues"
        echo "  - Classify issues without labels"
        echo "  - Review and clean up old issues"
        echo "  - Prioritize high-priority issues"
    fi
}
EOF

chmod +x ~/scripts/github-cli/issue/analytics.sh

# Add analytics script loading to .zshrc
cat >> ~/.zshrc << 'EOF'

# Load issue analytics script
source ~/scripts/github-cli/issue/analytics.sh
EOF

source ~/.zshrc
```

### 2. Automatic Notification System

```bash
# Daily issue notification system
cat > ~/scripts/github-cli/system/daily-issue-alert.sh << 'EOF'
#!/bin/bash

# Daily issue status notification system
# Run daily as a cron job: 0 9 * * * ~/scripts/github-cli/system/daily-issue-alert.sh

ALERT_FILE="$HOME/Documents/github-automation/daily-alert-$(date +%Y-%m-%d).md"

cat > "$ALERT_FILE" << 'ALERTHEADER'
# Daily Issue Alert

## Urgent Alerts
ALERTHEADER

# Check for critical issues
CRITICAL_ISSUES=$(gh issue list --label "priority:critical" --state open --json number,title,createdAt)
CRITICAL_COUNT=$(echo "$CRITICAL_ISSUES" | jq length)

if [[ $CRITICAL_COUNT -gt 0 ]]; then
    echo "**CRITICAL priority issues unresolved: ${CRITICAL_COUNT}**" >> "$ALERT_FILE"
    echo "$CRITICAL_ISSUES" | jq -r '.[] | "- [#\(.number)](\(.html_url)) \(.title)"' >> "$ALERT_FILE"
else
    echo "No critical issues." >> "$ALERT_FILE"
fi

echo "" >> "$ALERT_FILE"

# Long-standing open issues
echo "## Long-standing open issues (7+ days)" >> "$ALERT_FILE"
STALE_ISSUES=$(gh issue list --search "is:open created:<$(date -d "-7 days" +%Y-%m-%d)" --limit 10 --json number,title,createdAt)
STALE_COUNT=$(echo "$STALE_ISSUES" | jq length)

if [[ $STALE_COUNT -gt 0 ]]; then
    echo "$STALE_ISSUES" | jq -r '.[] | "- [#\(.number)](\(.html_url)) \(.title) (created: \(.createdAt | split("T")[0]))"' >> "$ALERT_FILE"
else
    echo "No long-standing open issues." >> "$ALERT_FILE"
fi

echo "" >> "$ALERT_FILE"

# Today's tasks
echo "## Today's Tasks" >> "$ALERT_FILE"
TODAY_ISSUES=$(gh issue list --assignee @me --state open --limit 5 --json number,title)
TODAY_COUNT=$(echo "$TODAY_ISSUES" | jq length)

if [[ $TODAY_COUNT -gt 0 ]]; then
    echo "$TODAY_ISSUES" | jq -r '.[] | "- [ ] [#\(.number)](\(.html_url)) \(.title)"' >> "$ALERT_FILE"
else
    echo "No assigned issues!" >> "$ALERT_FILE"
fi

# Print summary to terminal
echo "Daily issue alert generated: $ALERT_FILE"
if [[ $CRITICAL_COUNT -gt 0 ]]; then
    echo "CRITICAL issues require attention: $CRITICAL_COUNT"
fi
if [[ $STALE_COUNT -gt 5 ]]; then
    echo "Long-standing issues need cleanup: $STALE_COUNT"
fi

# Optional: send via Slack or email
# slack-alert.sh "$ALERT_FILE" 2>/dev/null || true
EOF

chmod +x ~/scripts/github-cli/system/daily-issue-alert.sh
```

## What's Next

The next part, **[Project Management + Company/Personal Project Separation](github-cli-project-management-automation)**, will cover:

- Full automation of GitHub Projects v2
- Dynamic kanban board management
- Separated workflows for company and personal projects
- Team collaboration automation systems
- Project metrics and reporting

---

## Other Posts in This Series

- [Part 1: Installation and Environment Setup](macos-github-cli-complete-guide)
- **Part 2: Full Issue Management Automation** (current)
- [Part 3: Project Management + Company/Personal Project Separation](github-cli-project-management-automation)
- [Part 4: Full Wiki Management Automation](github-cli-wiki-automation-guide)
- [Part 5: Advanced Workflows and Real-World Application](github-cli-advanced-workflows)
