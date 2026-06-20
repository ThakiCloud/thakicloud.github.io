---
title: "GitHub CLI - أتمتة إدارة المشاريع [الجزء 3]"
excerpt: "نظام إدارة مشاريع قائم على السياق باستخدام GitHub CLI وGitHub Projects v2: الحقول المخصصة ومهام سير العمل وإشعارات الفريق وأتمتة إعداد التقارير."
seo_title: "أتمتة إدارة مشاريع GitHub CLI باستخدام Projects v2 - Thaki Cloud"
seo_description: "دليل عملي لأتمتة إدارة المشاريع باستخدام GitHub CLI وGitHub Projects v2. يغطي إدارة حقول الإصدار وتعيين المهام وإعداد التقارير التلقائية."
date: 2025-07-02
last_modified_at: 2025-07-02
categories:
  - dev
tags:
  - github-cli
  - project-management
  - automation
  - GitHub-Projects
  - agile
  - sprint-planning
  - team-management
lang: ar
dir: rtl
author_profile: true
toc: true
toc_label: "أتمتة إدارة المشاريع"
canonical_url: "https://thakicloud.github.io/ar/dev/github-cli-project-management-automation/"
published: true
---

⏱️ **وقت القراءة المقدر**: 18 دقائق

هذا الجزء الثالث من سلسلة GitHub CLI. سنستكشف كيفية بناء نظام إدارة مشاريع قائم على السياق وأتمتة مهام سير العمل المتكررة.

## إدارة المشاريع القائمة على السياق

### فهم بنية GitHub Projects v2

يوفر GitHub Projects v2 نظام إدارة مشاريع مرن للغاية. دعنا نتعلم كيفية أتمتته بالكامل.

```bash
#!/bin/bash
# project-automation.sh - أتمتة إدارة GitHub Projects

# الحصول على معرف المشروع
get_project_id() {
    local org="${1}"
    local project_name="${2}"
    
    gh project list \
        --owner "${org}" \
        --format json \
        --jq ".projects[] | select(.title == \"${project_name}\") | .number"
}

# إنشاء مشروع جديد
create_project_with_fields() {
    local org="${1}"
    local project_name="${2}"
    
    echo "إنشاء مشروع: ${project_name}"
    
    # إنشاء المشروع
    local project_number
    project_number=$(gh project create \
        --owner "${org}" \
        --title "${project_name}" \
        --format json \
        --jq '.number')
    
    echo "رقم المشروع: ${project_number}"
    
    # إضافة حقل الأولوية
    gh project field-create "${project_number}" \
        --owner "${org}" \
        --name "الأولوية" \
        --data-type SINGLE_SELECT \
        --single-select-options "حرج,عالٍ,متوسط,منخفض"
    
    # إضافة حقل تقدير نقاط القصة
    gh project field-create "${project_number}" \
        --owner "${org}" \
        --name "نقاط القصة" \
        --data-type NUMBER
    
    # إضافة حقل الإصدار
    gh project field-create "${project_number}" \
        --owner "${org}" \
        --name "الإصدار" \
        --data-type TEXT
    
    echo "تم إنشاء المشروع ${project_name} مع الحقول المخصصة"
    echo "${project_number}"
}
```

### إدارة العناصر في المشروع

```bash
# إضافة issue إلى مشروع
add_issue_to_project() {
    local issue_number="${1}"
    local project_number="${2}"
    local owner="${3}"
    local repo="${4}"
    
    # الحصول على URL الـ issue
    local issue_url
    issue_url=$(gh issue view "${issue_number}" \
        --repo "${repo}" \
        --json url \
        --jq '.url')
    
    # إضافة إلى المشروع
    gh project item-add "${project_number}" \
        --owner "${owner}" \
        --url "${issue_url}"
    
    echo "تمت إضافة الـ issue #${issue_number} إلى المشروع ${project_number}"
}

# تحديث حقول العنصر في المشروع
update_project_item() {
    local project_number="${1}"
    local item_id="${2}"
    local field_name="${3}"
    local field_value="${4}"
    local owner="${5}"
    
    # الحصول على معرف الحقل
    local field_id
    field_id=$(gh project field-list "${project_number}" \
        --owner "${owner}" \
        --format json \
        --jq ".fields[] | select(.name == \"${field_name}\") | .id")
    
    if [[ -z "${field_id}" ]]; then
        echo "خطأ: الحقل '${field_name}' غير موجود"
        return 1
    fi
    
    # تحديث قيمة الحقل
    gh project item-edit \
        --project-id "${project_number}" \
        --id "${item_id}" \
        --field-id "${field_id}" \
        --text "${field_value}" \
        --owner "${owner}"
    
    echo "تم تحديث حقل '${field_name}' إلى '${field_value}'"
}
```

## ربط المشكلات بالمشاريع

### أتمتة ربط المشكلات

```bash
#!/bin/bash
# issue-project-linker.sh - أتمتة ربط المشكلات بالمشاريع

# تصنيف المشكلة وإضافتها تلقائيًا
auto_categorize_and_add() {
    local issue_number="${1}"
    local repo="${2}"
    local org="${3}"
    
    # الحصول على بيانات المشكلة
    local issue_data
    issue_data=$(gh issue view "${issue_number}" \
        --repo "${repo}" \
        --json "title,labels,assignees,body,milestone")
    
    local title
    title=$(echo "${issue_data}" | jq -r '.title')
    
    local labels
    labels=$(echo "${issue_data}" | jq -r '.labels[].name' | tr '\n' ',')
    
    # تحديد المشروع المناسب بناءً على التسميات
    local target_project
    case "${labels}" in
        *bug*)
            target_project="تتبع الأخطاء"
            priority="عالٍ"
            ;;
        *feature*)
            target_project="خارطة الطريق"
            priority="متوسط"
            ;;
        *documentation*)
            target_project="الوثائق"
            priority="منخفض"
            ;;
        *urgent*|*critical*)
            target_project="تتبع الأخطاء"
            priority="حرج"
            ;;
        *)
            target_project="المهام العامة"
            priority="متوسط"
            ;;
    esac
    
    # الحصول على رقم المشروع
    local project_number
    project_number=$(get_project_id "${org}" "${target_project}")
    
    if [[ -z "${project_number}" ]]; then
        echo "تحذير: المشروع '${target_project}' غير موجود"
        return 1
    fi
    
    # إضافة إلى المشروع
    local item_id
    item_id=$(add_issue_to_project "${issue_number}" "${project_number}" "${org}" "${repo}")
    
    # تعيين الأولوية
    update_project_item "${project_number}" "${item_id}" "الأولوية" "${priority}" "${org}"
    
    echo "تمت إضافة المشكلة #${issue_number} '${title}' إلى مشروع '${target_project}' بأولوية '${priority}'"
}
```

## تلخيص وقوف الفريق اليومي

### إنشاء تقرير الفريق التلقائي

```bash
#!/bin/bash
# team-standup.sh - أتمتة تلخيص وقوف الفريق

generate_standup_report() {
    local repo="${1}"
    local org="${2}"
    local since="${3:-yesterday}"
    
    echo "=== تقرير وقوف الفريق - $(date '+%Y-%m-%d') ==="
    echo ""
    
    # PR مدموجة أمس
    echo "## طلبات السحب المدموجة"
    gh pr list \
        --repo "${repo}" \
        --state merged \
        --json "number,title,author,mergedAt,url" \
        --jq '.[] | select(.mergedAt >= "'$(date -d yesterday '+%Y-%m-%d')'") | 
              "- PR #\(.number): \(.title) (@\(.author.login))"'
    
    echo ""
    echo "## المشكلات المفتوحة هذا الأسبوع"
    gh issue list \
        --repo "${repo}" \
        --state open \
        --json "number,title,assignees,labels,createdAt" \
        --jq '.[] | select(.createdAt >= "'$(date -d '7 days ago' '+%Y-%m-%d')'") |
              "- #\(.number): \(.title) - المعيّن: \(.assignees[0].login // "غير معيّن")"'
    
    echo ""
    echo "## طلبات السحب المعلقة للمراجعة"
    gh pr list \
        --repo "${repo}" \
        --state open \
        --json "number,title,author,reviewRequests,createdAt" \
        --jq '.[] | select(.reviewRequests | length > 0) |
              "- PR #\(.number): \(.title) - المؤلف: @\(.author.login)"'
}

# الإرسال إلى Slack
send_standup_to_slack() {
    local report="${1}"
    local webhook_url="${2}"
    
    local payload
    payload=$(cat << EOF
{
    "text": "تقرير وقوف الفريق اليومي",
    "blocks": [
        {
            "type": "header",
            "text": {
                "type": "plain_text",
                "text": "تقرير وقوف الفريق - $(date '+%Y/%m/%d')"
            }
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "${report}"
            }
        }
    ]
}
EOF
)
    
    curl -s -X POST \
        -H 'Content-type: application/json' \
        --data "${payload}" \
        "${webhook_url}"
}
```

## أتمتة تعيين مراجعات الكود

### نظام التعيين الذكي

```bash
#!/bin/bash
# code-review-assigner.sh - نظام تعيين مراجعات الكود الذكي

# تعيين المراجعين بناءً على المعرفة بالكود
assign_code_reviewers() {
    local pr_number="${1}"
    local repo="${2}"
    
    # الحصول على الملفات المعدّلة
    local changed_files
    changed_files=$(gh pr view "${pr_number}" \
        --repo "${repo}" \
        --json "files" \
        --jq '.files[].path')
    
    # تحديد خبراء الكود
    declare -A expertise=(
        ["backend/"]="ahmed,sara"
        ["frontend/"]="ali,fatima"
        ["database/"]="omar,leila"
        ["infrastructure/"]="khaled,nour"
        ["security/"]="hana,ibrahim"
    )
    
    local reviewers=()
    
    while IFS= read -r file; do
        for area in "${!expertise[@]}"; do
            if [[ "${file}" == ${area}* ]]; then
                # إضافة خبراء هذه المنطقة
                IFS=',' read -ra area_experts <<< "${expertise[${area}]}"
                reviewers+=("${area_experts[@]}")
            fi
        done
    done <<< "${changed_files}"
    
    # إزالة المكررات
    local unique_reviewers
    unique_reviewers=$(echo "${reviewers[@]}" | tr ' ' '\n' | sort -u | tr '\n' ',' | sed 's/,$//')
    
    # الحصول على مؤلف PR لاستبعاده
    local pr_author
    pr_author=$(gh pr view "${pr_number}" \
        --repo "${repo}" \
        --json "author" \
        --jq '.author.login')
    
    # استبعاد المؤلف من المراجعين
    local filtered_reviewers
    filtered_reviewers=$(echo "${unique_reviewers}" | tr ',' '\n' | 
        grep -v "^${pr_author}$" | 
        head -3 |
        tr '\n' ',' | sed 's/,$//')
    
    if [[ -n "${filtered_reviewers}" ]]; then
        # طلب المراجعة
        gh pr edit "${pr_number}" \
            --repo "${repo}" \
            --add-reviewer "${filtered_reviewers}"
        
        echo "تم طلب المراجعة من: ${filtered_reviewers}"
    else
        echo "لم يُعثر على مراجعين مناسبين"
    fi
}
```

## إعداد تقارير المقاييس

### لوحة تحكم المشروع

```bash
#!/bin/bash
# project-metrics.sh - إعداد تقارير مقاييس المشروع

generate_project_metrics() {
    local repo="${1}"
    local period_days="${2:-30}"
    
    local since_date
    since_date=$(date -d "${period_days} days ago" '+%Y-%m-%dT00:00:00Z')
    
    echo "=== مقاييس المشروع - آخر ${period_days} يومًا ==="
    echo ""
    
    # مقاييس PR
    echo "## إحصائيات طلبات السحب"
    
    local total_prs
    total_prs=$(gh pr list \
        --repo "${repo}" \
        --state all \
        --json "number" \
        --jq 'length')
    
    local merged_prs
    merged_prs=$(gh pr list \
        --repo "${repo}" \
        --state merged \
        --json "number,mergedAt" \
        --jq "[.[] | select(.mergedAt >= \"${since_date}\")] | length")
    
    local open_prs
    open_prs=$(gh pr list \
        --repo "${repo}" \
        --state open \
        --json "number" \
        --jq 'length')
    
    echo "- إجمالي PR: ${total_prs}"
    echo "- PR مدموجة (${period_days} يوم): ${merged_prs}"
    echo "- PR مفتوحة: ${open_prs}"
    
    echo ""
    echo "## إحصائيات المشكلات"
    
    local total_issues
    total_issues=$(gh issue list \
        --repo "${repo}" \
        --state all \
        --json "number" \
        --jq 'length')
    
    local closed_issues
    closed_issues=$(gh issue list \
        --repo "${repo}" \
        --state closed \
        --json "number,closedAt" \
        --jq "[.[] | select(.closedAt >= \"${since_date}\")] | length")
    
    local open_issues
    open_issues=$(gh issue list \
        --repo "${repo}" \
        --state open \
        --json "number" \
        --jq 'length')
    
    echo "- إجمالي المشكلات: ${total_issues}"
    echo "- مشكلات مغلقة (${period_days} يوم): ${closed_issues}"
    echo "- مشكلات مفتوحة: ${open_issues}"
    
    echo ""
    echo "## أهم المساهمين"
    
    gh pr list \
        --repo "${repo}" \
        --state merged \
        --json "author,mergedAt" \
        --jq "[.[] | select(.mergedAt >= \"${since_date}\")] | 
              group_by(.author.login) | 
              map({user: .[0].author.login, count: length}) | 
              sort_by(-.count) | 
              .[:5] | 
              .[] | 
              \"- @\(.user): \(.count) PR\""
}

# تصدير التقرير بتنسيق Markdown
export_metrics_report() {
    local repo="${1}"
    local output_file="${2:-metrics-report.md}"
    
    {
        echo "# تقرير مقاييس المشروع"
        echo ""
        echo "**تاريخ التقرير**: $(date '+%Y-%m-%d')"
        echo "**المستودع**: ${repo}"
        echo ""
        generate_project_metrics "${repo}"
    } > "${output_file}"
    
    echo "تم تصدير التقرير: ${output_file}"
}
```

## إدارة طرق العرض في المشاريع

### إنشاء طرق عرض مخصصة

```bash
#!/bin/bash
# project-views.sh - إدارة طرق عرض المشاريع

# إنشاء طريقة عرض Sprint
create_sprint_view() {
    local project_number="${1}"
    local sprint_name="${2}"
    local owner="${3}"
    
    # إنشاء طريقة عرض Sprint
    gh api graphql -f query='
    mutation CreateView($projectId: ID!, $name: String!) {
        addProjectV2View(input: {
            projectId: $projectId
            name: $name
            layout: BOARD_LAYOUT
        }) {
            projectView {
                id
                name
            }
        }
    }' \
    -f projectId="${project_number}" \
    -f name="${sprint_name}"
    
    echo "تم إنشاء طريقة عرض: ${sprint_name}"
}

# تحديث تقرير Sprint تلقائيًا
update_sprint_report() {
    local repo="${1}"
    local project_number="${2}"
    local owner="${3}"
    
    # الحصول على إحصائيات Sprint الحالي
    local sprint_stats
    sprint_stats=$(gh project item-list "${project_number}" \
        --owner "${owner}" \
        --format json \
        --jq '{
            total: length,
            completed: [.items[] | select(.status == "Done")] | length,
            in_progress: [.items[] | select(.status == "In Progress")] | length,
            todo: [.items[] | select(.status == "Todo")] | length
        }')
    
    local total=$(echo "${sprint_stats}" | jq -r '.total')
    local completed=$(echo "${sprint_stats}" | jq -r '.completed')
    local in_progress=$(echo "${sprint_stats}" | jq -r '.in_progress')
    local todo=$(echo "${sprint_stats}" | jq -r '.todo')
    
    # حساب نسبة الاكتمال
    local completion_rate=0
    if [[ ${total} -gt 0 ]]; then
        completion_rate=$(( completed * 100 / total ))
    fi
    
    echo "=== حالة Sprint ==="
    echo "الإجمالي: ${total}"
    echo "مكتملة: ${completed} (${completion_rate}%)"
    echo "قيد التنفيذ: ${in_progress}"
    echo "في الانتظار: ${todo}"
    
    # إنشاء تقرير Markdown
    cat << EOF
## تحديث تقدم Sprint

| الحالة | العدد | النسبة |
|--------|-------|--------|
| مكتملة | ${completed} | ${completion_rate}% |
| قيد التنفيذ | ${in_progress} | - |
| في الانتظار | ${todo} | - |
| **الإجمالي** | **${total}** | - |

> **ملاحظة**: تم إنشاء هذا التقرير تلقائيًا في $(date '+%Y-%m-%d %H:%M')
EOF
}
```

## التقارير التلقائية

### جدولة التقارير الدورية

```bash
#!/bin/bash
# scheduled-reports.sh - جدولة التقارير التلقائية

# تكوين الجدولة (يستخدم مع cron)
# 0 9 * * 1 /path/to/scheduled-reports.sh weekly
# 0 9 * * * /path/to/scheduled-reports.sh daily

generate_scheduled_report() {
    local report_type="${1:-daily}"
    local repo="${2}"
    local slack_webhook="${3}"
    
    local report_content
    
    case "${report_type}" in
        "daily")
            report_content=$(generate_standup_report "${repo}" "" "yesterday")
            ;;
        "weekly")
            report_content=$(generate_project_metrics "${repo}" "7")
            ;;
        "monthly")
            report_content=$(generate_project_metrics "${repo}" "30")
            ;;
    esac
    
    # إرسال إلى Slack
    if [[ -n "${slack_webhook}" ]]; then
        send_standup_to_slack "${report_content}" "${slack_webhook}"
        echo "تم إرسال التقرير إلى Slack"
    else
        echo "${report_content}"
    fi
    
    # حفظ في ملف
    local report_file="${HOME}/.gh-reports/$(date '+%Y%m%d')-${report_type}.md"
    mkdir -p "$(dirname "${report_file}")"
    echo "${report_content}" > "${report_file}"
    echo "تم حفظ التقرير: ${report_file}"
}

# الوظيفة الرئيسية
main() {
    local command="${1:-daily}"
    local repo="${2:-}"
    local webhook="${3:-}"
    
    if [[ -z "${repo}" ]]; then
        repo=$(gh repo view --json nameWithOwner --jq '.nameWithOwner' 2>/dev/null || "")
    fi
    
    if [[ -z "${repo}" ]]; then
        echo "خطأ: يجب تحديد المستودع"
        exit 1
    fi
    
    generate_scheduled_report "${command}" "${repo}" "${webhook}"
}

main "$@"
```

## الخلاصة

في هذا الجزء الثالث، تعلمنا:

- **إدارة GitHub Projects v2**: إنشاء المشاريع والحقول المخصصة وإدارة العناصر بالكامل برمجيًا
- **أتمتة ربط المشكلات**: التصنيف التلقائي للمشكلات وإضافتها إلى المشاريع المناسبة
- **تقارير الفريق**: أتمتة تقارير الوقوف اليومي والإرسال إلى Slack
- **تعيين المراجعين**: نظام ذكي لتعيين مراجعي الكود بناءً على الخبرة
- **لوحات المقاييس**: إنشاء تقارير شاملة حول أداء المشروع

**المقالات السابقة في السلسلة**:
- الجزء 1: أساسيات GitHub CLI
- الجزء 2: أتمتة PR وسير العمل
- الجزء 3: إدارة المشاريع (هذه المقالة)
- الجزء 4: أتمتة Wiki والوثائق
- الجزء 5: سير العمل المتقدمة وCI/CD
