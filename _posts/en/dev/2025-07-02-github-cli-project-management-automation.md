---
title: "macOS GitHub CLI Complete Automation Series - Part 3: Complete Project Management Separation"
excerpt: "Complete work/personal project separation, GitHub Projects v2 automation, and team collaboration workflows"
seo_title: "GitHub CLI Project Management Automation Part 3 - Work/Personal Separation - Thaki Cloud"
seo_description: "Expert guide to completely separating work and personal projects with GitHub CLI, automating Projects v2, and building team collaboration workflows"
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
lang: en
author_profile: true
toc: true
canonical_url: "https://thakicloud.github.io/en/dev/github-cli-project-management-automation/"
published: true
---

⏱️ **Estimated reading time**: 18 min

## Series Overview

Part 3 of the **macOS GitHub CLI Complete Automation Series** covers completely separating work and personal projects and automating GitHub Projects v2. We will build a project management system that you can use in production right away.

## Complete Work/Personal Project Separation System

### 1. Context-Based Project Management

```bash
# Create project context management system
cat > ~/scripts/github-cli/project/manage.sh << 'EOF'
#!/bin/bash

# Project context separation system

# Smart project creation (auto-detect context)
function create_project_smart() {
    local project_name="$1"
    local description="$2"
    local context=$(cat ~/.config/gh/current_context 2>/dev/null || echo 'personal')
    
    if [[ -z "$project_name" ]]; then
        echo "Usage: create_project_smart <project name> [description]"
        return 1
    fi
    
    # Apply context-specific settings
    case "$context" in
        "work")
            # Work project template
            gh project create \
                --title "[WORK] $project_name" \
                --body "${description:-Work project: $project_name}

## Project Information
- **Type**: Work Project
- **Created**: $(date '+%Y-%m-%d')
- **Owner**: $(gh api user -q .login)

## Goals
- [ ] Requirements analysis
- [ ] Design and planning
- [ ] Development and implementation
- [ ] Testing and validation
- [ ] Deployment and operations

## Metrics
- Estimated duration: 
- Priority: 
- Resources: " \
                --format json > /tmp/project_info.json
            ;;
        "personal")
            # Personal project template
            gh project create \
                --title "[PERSONAL] $project_name" \
                --body "${description:-Personal project: $project_name}

## Idea
${description:-Write project description here}

## Plan
- [ ] Refine idea
- [ ] Choose tech stack
- [ ] Build MVP
- [ ] Test and improve
- [ ] Deploy

## Learning Goals
- 
- 

## References
- " \
                --format json > /tmp/project_info.json
            ;;
    esac
    
    local project_id=$(cat /tmp/project_info.json | jq -r '.id')
    local project_url=$(cat /tmp/project_info.json | jq -r '.url')
    
    # Set context-specific fields
    setup_project_fields "$project_id" "$context"
    
    echo "OK: $context project '$project_name' created!"
    echo "URL: $project_url"
    
    rm -f /tmp/project_info.json
}

# Project field setup
function setup_project_fields() {
    local project_id="$1"
    local context="$2"
    
    # Common fields
    gh project field-create "$project_id" --name "Status" --type "single_select" \
        --options "Backlog,In Progress,Review,Testing,Done"
    
    gh project field-create "$project_id" --name "Priority" --type "single_select" \
        --options "Critical,High,Medium,Low"
    
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
                --options "Easy,Medium,Hard"
            gh project field-create "$project_id" --name "Tech Stack" --type "text"
            ;;
    esac
    
    echo "OK: $context project fields configured."
}

# Project dashboard
function project_dashboard() {
    local context=$(cat ~/.config/gh/current_context 2>/dev/null || echo 'personal')
    
    echo "$context Project Dashboard"
    echo "================================"
    echo
    
    # Active project list
    local projects=$(gh project list --owner @me --limit 10 --format json)
    local context_projects=$(echo "$projects" | jq -r --arg ctx "$context" '.[] | select(.title | startswith(if $ctx == "work" then "[WORK]" else "[PERSONAL]" end)) | "\(.number)|\(.title)|\(.url)"')
    
    if [[ -z "$context_projects" ]]; then
        echo "No $context projects found."
        echo "Create one with: create_project_smart <project name>"
        return
    fi
    
    echo "Active Projects:"
    echo "$context_projects" | while IFS='|' read -r number title url; do
        echo "  $title"
        
        # Calculate project progress
        local total_items=$(gh project item-list "$number" --format json | jq length)
        local done_items=$(gh project item-list "$number" --format json | jq '[.[] | select(.status == "Done")] | length')
        
        if [[ $total_items -gt 0 ]]; then
            local progress=$((done_items * 100 / total_items))
            echo "    Progress: $done_items/$total_items ($progress%)"
        else
            echo "    Progress: No items"
        fi
        echo "    URL: $url"
        echo
    done
}
EOF

chmod +x ~/scripts/github-cli/project/manage.sh

# Add project management script loading to .zshrc
cat >> ~/.zshrc << 'EOF'

# Load project management scripts
source ~/scripts/github-cli/project/manage.sh
EOF

source ~/.zshrc
```

### 2. Automatic Issue-Project Linking

```bash
# Issue-project automatic linking system
cat > ~/scripts/github-cli/project/issue-linker.sh << 'EOF'
#!/bin/bash

# Automatically assign issues to the appropriate project
# Usage: issue-linker.sh <issue number> [project ID]

ISSUE_NUM="$1"
PROJECT_ID="$2"

if [[ -z "$ISSUE_NUM" ]]; then
    echo "Usage: issue-linker.sh <issue number> [project ID]"
    exit 1
fi

# Fetch issue information
ISSUE_INFO=$(gh issue view "$ISSUE_NUM" --json title,labels,repository)
ISSUE_TITLE=$(echo "$ISSUE_INFO" | jq -r '.title')
ISSUE_LABELS=$(echo "$ISSUE_INFO" | jq -r '.labels[].name' | tr '\n' ' ')
REPO_NAME=$(echo "$ISSUE_INFO" | jq -r '.repository.name')

# Auto-select project (if ID not specified)
if [[ -z "$PROJECT_ID" ]]; then
    CONTEXT=$(cat ~/.config/gh/current_context 2>/dev/null || echo 'personal')
    
    # Find default project by context
    case "$CONTEXT" in
        "work")
            PROJECT_ID=$(gh project list --owner @me --format json | \
                jq -r '.[] | select(.title | contains("[WORK]")) | .number' | head -1)
            ;;
        "personal")
            PROJECT_ID=$(gh project list --owner @me --format json | \
                jq -r '.[] | select(.title | contains("[PERSONAL]")) | .number' | head -1)
            ;;
    esac
    
    if [[ -z "$PROJECT_ID" || "$PROJECT_ID" == "null" ]]; then
        echo "FAIL: No suitable project found."
        echo "Create a project first or specify a project ID."
        exit 1
    fi
fi

# Add issue to project
ITEM_ID=$(gh project item-add "$PROJECT_ID" --url "https://github.com/$(gh repo view --json owner,name -q '.owner.login + "/" + .name')/issues/$ISSUE_NUM" --format json | jq -r '.id')

if [[ "$ITEM_ID" == "null" ]]; then
    echo "FAIL: Could not add issue to project."
    exit 1
fi

# Auto-set fields
echo "Auto-configuring project fields..."

# Set priority
if echo "$ISSUE_LABELS" | grep -q "priority:critical"; then
    PRIORITY="Critical"
elif echo "$ISSUE_LABELS" | grep -q "priority:high"; then
    PRIORITY="High"
elif echo "$ISSUE_LABELS" | grep -q "priority:medium"; then
    PRIORITY="Medium"
else
    PRIORITY="Low"
fi

# Set status
if echo "$ISSUE_LABELS" | grep -q "in-progress"; then
    STATUS="In Progress"
elif echo "$ISSUE_LABELS" | grep -q "review"; then
    STATUS="Review"
elif echo "$ISSUE_LABELS" | grep -q "testing"; then
    STATUS="Testing"
else
    STATUS="Backlog"
fi

# Update fields (ignore errors)
gh project item-edit --project-id "$PROJECT_ID" --id "$ITEM_ID" --field-id "Priority" --single-select-option-id "$PRIORITY" 2>/dev/null || true
gh project item-edit --project-id "$PROJECT_ID" --id "$ITEM_ID" --field-id "Status" --single-select-option-id "$STATUS" 2>/dev/null || true

echo "OK: Issue #$ISSUE_NUM added to project!"
echo "Title: $ISSUE_TITLE"
echo "Priority: $PRIORITY"
echo "Status: $STATUS"
echo "Project URL: $(gh project view "$PROJECT_ID" --format json | jq -r '.url')"
EOF

chmod +x ~/scripts/github-cli/project/issue-linker.sh
```

### 3. Team Collaboration Automation

```bash
# Team collaboration workflow automation scripts
cat > ~/scripts/github-cli/project/collaboration.sh << 'EOF'
#!/bin/bash

# Team collaboration automation functions
function team_standup() {
    local project_id="$1"
    
    if [[ -z "$project_id" ]]; then
        echo "Usage: team_standup <project ID>"
        return 1
    fi
    
    echo "Team Standup Report - $(date '+%Y-%m-%d')"
    echo "=========================================="
    echo
    
    # Yesterday's completed tasks
    echo "Completed Yesterday:"
    gh issue list --search "closed:$(date -d 'yesterday' '+%Y-%m-%d')" --limit 10 --json number,title,assignees | \
        jq -r '.[] | "  #\(.number): \(.title) (\(.assignees[0].login // "unassigned"))"'
    echo
    
    # Today's planned tasks
    echo "Planned for Today:"
    gh project item-list "$project_id" --format json | \
        jq -r '.[] | select(.status == "In Progress") | "  \(.content.title) (\(.assignees[0].login // "unassigned"))"'
    echo
    
    # Blockers
    echo "Blockers:"
    gh issue list --label "blocked" --state open --json number,title | \
        jq -r '.[] | "  #\(.number): \(.title)"'
    
    [[ $(gh issue list --label "blocked" --state open --json number | jq length) -eq 0 ]] && echo "  None"
    echo
}

# Auto-assign code reviewers
function auto_assign_reviewers() {
    local pr_number="$1"
    
    if [[ -z "$pr_number" ]]; then
        echo "Usage: auto_assign_reviewers <PR number>"
        return 1
    fi
    
    local context=$(cat ~/.config/gh/current_context 2>/dev/null || echo 'personal')
    
    if [[ "$context" == "work" ]]; then
        # Work project: assign team leads and senior developers
        gh pr edit "$pr_number" --add-reviewer "@team-leads,@senior-devs"
        echo "OK: Team leads and senior developers assigned as reviewers."
    else
        # Personal project: self-review
        gh pr edit "$pr_number" --add-reviewer "@me"
        echo "OK: Self-review configured."
    fi
    
    # Change PR status to Ready for review
    gh pr ready "$pr_number"
    echo "OK: PR set to Ready for Review."
}

# Project metrics report
function project_metrics() {
    local project_id="$1"
    local days="${2:-7}"
    
    if [[ -z "$project_id" ]]; then
        echo "Usage: project_metrics <project ID> [period in days]"
        return 1
    fi
    
    echo "Project Metrics (last ${days} days)"
    echo "====================================="
    echo
    
    # Velocity calculation
    local completed_issues=$(gh issue list --search "closed:>=$(date -d "-${days} days" '+%Y-%m-%d')" --json number | jq length)
    local velocity=$(echo "scale=1; $completed_issues / $days" | bc -l)
    
    echo "Velocity: $velocity issues/day (total $completed_issues completed)"
    echo
    
    # Average lead time
    echo "Average Lead Time:"
    gh issue list --search "closed:>=$(date -d "-${days} days" '+%Y-%m-%d')" --limit 10 --json createdAt,closedAt | \
        jq -r '.[] | ((.closedAt | fromdateiso8601) - (.createdAt | fromdateiso8601)) / 86400' | \
        awk '{sum+=$1; count++} END {if(count>0) printf "  %.1f days\n", sum/count; else print "  No data"}'
    echo
    
    # Current progress
    local total_items=$(gh project item-list "$project_id" --format json | jq length)
    local done_items=$(gh project item-list "$project_id" --format json | jq '[.[] | select(.status == "Done")] | length')
    local progress=$((done_items * 100 / total_items))
    
    echo "Overall Progress: $done_items/$total_items ($progress%)"
    echo
    
    # Team contributions (for work projects)
    local context=$(cat ~/.config/gh/current_context 2>/dev/null || echo 'personal')
    if [[ "$context" == "work" ]]; then
        echo "Team Contributions:"
        gh issue list --search "closed:>=$(date -d "-${days} days" '+%Y-%m-%d')" --json assignees | \
            jq -r '.[] | .assignees[]?.login' | sort | uniq -c | sort -nr | \
            while read count assignee; do
                echo "  $assignee: $count items"
            done
    fi
}
EOF

chmod +x ~/scripts/github-cli/project/collaboration.sh

# Add collaboration scripts to .zshrc
cat >> ~/.zshrc << 'EOF'

# Load project collaboration scripts
source ~/scripts/github-cli/project/collaboration.sh
EOF

source ~/.zshrc
```

## GitHub Projects v2 Advanced Automation

### 1. Dynamic View Management

```bash
# Projects v2 view automation scripts
cat > ~/scripts/github-cli/project/view-manager.sh << 'EOF'
#!/bin/bash

# GitHub Projects v2 automatic view management
# Usage: view-manager.sh <command> <project-id> [options]

COMMAND="$1"
PROJECT_ID="$2"

case "$COMMAND" in
    "setup-views")
        if [[ -z "$PROJECT_ID" ]]; then
            echo "Usage: view-manager.sh setup-views <project ID>"
            exit 1
        fi
        
        echo "Configuring project views..."
        
        # Sprint view (current sprint only)
        gh project view-create "$PROJECT_ID" \
            --name "Current Sprint" \
            --layout "board" \
            --filter "Sprint:\"$(date '+Sprint %Y-%U')\""
        
        # Priority view
        gh project view-create "$PROJECT_ID" \
            --name "High Priority" \
            --layout "table" \
            --filter "Priority:\"Critical\",\"High\""
        
        # Team view (work projects)
        gh project view-create "$PROJECT_ID" \
            --name "Backend Team" \
            --layout "board" \
            --filter "Team:Backend"
        
        # Completed work view
        gh project view-create "$PROJECT_ID" \
            --name "Completed" \
            --layout "table" \
            --filter "Status:\"Done\""
        
        echo "OK: Project views configured!"
        ;;
        
    "update-sprint")
        local sprint_name="${3:-Sprint $(date '+%Y-%U')}"
        
        echo "Updating sprint view: $sprint_name"
        
        # Update sprint view filter
        gh project view-edit "$PROJECT_ID" \
            --name "Current Sprint" \
            --filter "Sprint:\"$sprint_name\""
        
        echo "OK: Sprint view updated."
        ;;
        
    "analytics")
        echo "Creating analytics views..."
        
        # Burndown chart view
        gh project view-create "$PROJECT_ID" \
            --name "Burndown" \
            --layout "table" \
            --filter "Status:\"Backlog\",\"In Progress\",\"Review\",\"Testing\""
        
        # Lead time analysis view
        gh project view-create "$PROJECT_ID" \
            --name "Lead Time Analysis" \
            --layout "table" \
            --filter "Status:\"Done\""
        
        echo "OK: Analytics views created."
        ;;
        
    *)
        echo "GitHub Projects v2 View Manager"
        echo "Usage: view-manager.sh <command> <project-id> [options]"
        echo
        echo "Commands:"
        echo "  setup-views     - Auto-create default views"
        echo "  update-sprint   - Update sprint view"
        echo "  analytics       - Create analytics views"
        ;;
esac
EOF

chmod +x ~/scripts/github-cli/project/view-manager.sh
```

### 2. Automatic Report Generation

```bash
# Automatic project report generation
cat > ~/scripts/github-cli/system/project-reporter.sh << 'EOF'
#!/bin/bash

# Automatic project progress report generation
PROJECT_ID="$1"
REPORT_TYPE="${2:-weekly}"

if [[ -z "$PROJECT_ID" ]]; then
    echo "Usage: project-reporter.sh <project ID> [weekly|monthly|sprint]"
    exit 1
fi

# Fetch project information
PROJECT_INFO=$(gh project view "$PROJECT_ID" --format json)
PROJECT_TITLE=$(echo "$PROJECT_INFO" | jq -r '.title')
PROJECT_URL=$(echo "$PROJECT_INFO" | jq -r '.url')

# Report file path
REPORT_DATE=$(date '+%Y-%m-%d')
REPORT_FILE="$HOME/Documents/github-automation/project-report-$PROJECT_ID-$REPORT_DATE.md"

# Generate report header
cat > "$REPORT_FILE" << REPORTHEADER
# Project Progress Report

**Project**: $PROJECT_TITLE
**Report Type**: $REPORT_TYPE
**Generated**: $REPORT_DATE
**URL**: [$PROJECT_TITLE]($PROJECT_URL)

## Summary
REPORTHEADER

# Period-based analysis
case "$REPORT_TYPE" in
    "weekly")
        PERIOD_START=$(date -d '7 days ago' '+%Y-%m-%d')
        PERIOD_DESC="Last week"
        ;;
    "monthly")
        PERIOD_START=$(date -d '30 days ago' '+%Y-%m-%d')
        PERIOD_DESC="Last month"
        ;;
    "sprint")
        PERIOD_START=$(date -d '14 days ago' '+%Y-%m-%d')
        PERIOD_DESC="Current sprint"
        ;;
esac

# Calculate progress
TOTAL_ITEMS=$(gh project item-list "$PROJECT_ID" --format json | jq length)
DONE_ITEMS=$(gh project item-list "$PROJECT_ID" --format json | jq '[.[] | select(.status == "Done")] | length')
PROGRESS=$((DONE_ITEMS * 100 / TOTAL_ITEMS))

# Add report content
cat >> "$REPORT_FILE" << REPORTBODY

### Overall Progress
- **Completed**: $DONE_ITEMS items
- **Total**: $TOTAL_ITEMS items
- **Progress**: $PROGRESS%

### $PERIOD_DESC Results
- **Issues closed**: $(gh issue list --search "closed:>=$PERIOD_START" --json number | jq length)
- **New issues created**: $(gh issue list --search "created:>=$PERIOD_START" --json number | jq length)

## Status Overview

### In Progress
$(gh project item-list "$PROJECT_ID" --format json | jq -r '.[] | select(.status == "In Progress") | "- \(.content.title)"')

### In Review
$(gh project item-list "$PROJECT_ID" --format json | jq -r '.[] | select(.status == "Review") | "- \(.content.title)"')

### In Testing
$(gh project item-list "$PROJECT_ID" --format json | jq -r '.[] | select(.status == "Testing") | "- \(.content.title)"')

## Next Steps
- [ ] 
- [ ] 
- [ ] 

## Blockers
$(gh issue list --label "blocked" --state open --json number,title | jq -r '.[] | "- [#\(.number)](\(.html_url)) \(.title)"')

---
*This report was automatically generated.*
REPORTBODY

echo "OK: Project report created: $REPORT_FILE"

# Print report summary to terminal
echo
echo "Report Summary:"
echo "  Progress: $PROGRESS% ($DONE_ITEMS/$TOTAL_ITEMS)"
echo "  $PERIOD_DESC completed: $(gh issue list --search "closed:>=$PERIOD_START" --json number | jq length) issues"
EOF

chmod +x ~/scripts/github-cli/system/project-reporter.sh
```

## Preview of the Next Part

The next part, **[Complete Wiki Management Automation](github-cli-wiki-automation-guide)**, covers:

- Code-based wiki auto-generation
- API documentation auto-sync
- Multilingual documentation management
- Version-based documentation management
- Automated documentation quality verification

---

## Other Posts in This Series

- [Part 1: Installation and Environment Setup](macos-github-cli-complete-guide)
- [Part 2: Complete Issue Management Automation](macos-github-cli-issue-automation-guide)
- **Part 3: Project Management + Work/Personal Project Separation** (this post)
- [Part 4: Complete Wiki Management Automation](github-cli-wiki-automation-guide)
- [Part 5: Advanced Workflows and Real-World Application](github-cli-advanced-workflows)
