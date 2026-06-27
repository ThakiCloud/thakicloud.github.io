---
title: "GitHub CLI - سير عمل متقدمة وتقنيات الأتمتة الاحترافية [الجزء 5]"
excerpt: "دليل شامل لسير العمل المتقدمة باستخدام GitHub CLI: نظام تحكم رئيسي، ودمج CI/CD، وأتمتة إعداد الفرق، وتحسين الأداء. الجزء الأخير من السلسلة."
seo_title: "سير العمل المتقدمة لـ GitHub CLI: أتمتة CI/CD وإعداد الفرق - Thaki Cloud"
seo_description: "دليل شامل حول سير العمل المتقدمة لـ GitHub CLI وأتمتة الإنتاج. يغطي أنماط أتمتة GitHub CLI المتقدمة بما في ذلك نظام التحكم الرئيسي ودمج CI/CD وأتمتة إعداد الفريق."
date: 2025-07-02
last_modified_at: 2025-07-02
categories:
  - dev
tags:
  - github-cli
  - automation
  - CI/CD
  - devops
  - shell-scripting
  - team-management
  - productivity
  - advanced-workflow
  - bash
lang: ar
dir: rtl
author_profile: true
toc: true
toc_label: "سير العمل المتقدمة"
canonical_url: "https://thakicloud.github.io/ar/dev/github-cli-advanced-workflows/"
published: true
---

⏱️ **وقت القراءة المقدر**: 25 دقائق

هذا هو الجزء الأخير من سلسلة GitHub CLI. سنغطي تقنيات الأتمتة المتقدمة التي ترفع إنتاجية الفرق إلى المستوى الاحترافي.

![رسم تخطيطي: يحمّل zshrc وحدات الأتمتة إلى موزّع gh موحّد يتحكم في GitHub](/assets/images/github-cli-advanced-workflows-hero.png)

## نظام التحكم الرئيسي

### بنية نظام التحكم الرئيسي

```bash
#!/bin/bash
# gh-master-controller.sh - نظام التحكم الرئيسي في GitHub CLI

set -euo pipefail

# تكوين المتغيرات العالمية
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_DIR="${HOME}/.config/gh-automation"
readonly LOG_DIR="${HOME}/.local/share/gh-automation/logs"
readonly CACHE_DIR="${HOME}/.cache/gh-automation"

# الألوان للإخراج
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

# تهيئة الدليل
init_directories() {
    mkdir -p "${CONFIG_DIR}" "${LOG_DIR}" "${CACHE_DIR}"
}

# تسجيل الأحداث
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${timestamp}] [${level}] ${message}" >> "${LOG_DIR}/automation.log"
    
    case "${level}" in
        "ERROR")
            echo -e "${RED}[${level}] ${message}${NC}" >&2
            ;;
        "SUCCESS")
            echo -e "${GREEN}[${level}] ${message}${NC}"
            ;;
        "WARNING")
            echo -e "${YELLOW}[${level}] ${message}${NC}"
            ;;
        *)
            echo "[${level}] ${message}"
            ;;
    esac
}

# التحقق من المتطلبات المسبقة
check_prerequisites() {
    local required_tools=("gh" "jq" "git" "curl")
    
    for tool in "${required_tools[@]}"; do
        if ! command -v "${tool}" &> /dev/null; then
            log "ERROR" "أداة مطلوبة غير موجودة: ${tool}"
            return 1
        fi
    done
    
    # التحقق من مصادقة GitHub
    if ! gh auth status &> /dev/null; then
        log "ERROR" "مصادقة GitHub CLI غير مكتملة. شغّل: gh auth login"
        return 1
    fi
    
    log "SUCCESS" "جميع المتطلبات المسبقة مكتملة"
    return 0
}

# الوظيفة الرئيسية لنظام التحكم
main() {
    init_directories
    check_prerequisites || exit 1
    
    local command="${1:-help}"
    
    case "${command}" in
        "setup-team")
            setup_team_automation "${@:2}"
            ;;
        "deploy")
            run_deployment_pipeline "${@:2}"
            ;;
        "monitor")
            monitor_repository "${@:2}"
            ;;
        "report")
            generate_team_report "${@:2}"
            ;;
        *)
            show_help
            ;;
    esac
}

main "$@"
```

### التكوين الديناميكي

```bash
# إدارة ملف التكوين
load_config() {
    local repo="${1}"
    local config_file="${CONFIG_DIR}/${repo//\//_}.json"
    
    if [[ ! -f "${config_file}" ]]; then
        # إنشاء تكوين افتراضي
        create_default_config "${repo}" > "${config_file}"
        log "INFO" "تم إنشاء ملف تكوين افتراضي: ${config_file}"
    fi
    
    cat "${config_file}"
}

create_default_config() {
    local repo="${1}"
    cat << EOF
{
    "repo": "${repo}",
    "automation": {
        "auto_merge": false,
        "require_reviews": 2,
        "protected_branches": ["main", "develop"],
        "label_automation": true
    },
    "notifications": {
        "slack_webhook": "",
        "email_recipients": []
    },
    "deployment": {
        "environments": ["staging", "production"],
        "auto_deploy_staging": true,
        "require_approval_production": true
    }
}
EOF
}
```

## دمج CI/CD المتقدم

### إدارة سير العمل

```bash
# مراقبة سير عمل GitHub Actions
monitor_workflows() {
    local repo="${1:-$(get_current_repo)}"
    local status_filter="${2:-in_progress}"
    
    log "INFO" "مراقبة سير العمل لـ ${repo}"
    
    gh run list \
        --repo "${repo}" \
        --status "${status_filter}" \
        --json "name,status,conclusion,url,startedAt" \
        --jq '.[] | {
            name: .name,
            status: .status,
            conclusion: (.conclusion // "running"),
            url: .url,
            started: .startedAt
        }'
}

# الانتظار حتى اكتمال CI
wait_for_ci() {
    local pr_number="${1}"
    local timeout="${2:-600}"
    local check_interval="${3:-30}"
    
    local elapsed=0
    
    log "INFO" "انتظار اكتمال CI لـ PR #${pr_number}"
    
    while [[ ${elapsed} -lt ${timeout} ]]; do
        local checks_status
        checks_status=$(gh pr checks "${pr_number}" --json "state,name,startedAt" 2>/dev/null)
        
        local pending_count
        pending_count=$(echo "${checks_status}" | jq '[.[] | select(.state == "pending")] | length')
        
        local failed_count
        failed_count=$(echo "${checks_status}" | jq '[.[] | select(.state == "failure")] | length')
        
        if [[ ${failed_count} -gt 0 ]]; then
            log "ERROR" "فشل فحص CI. عدد الفشل: ${failed_count}"
            return 1
        fi
        
        if [[ ${pending_count} -eq 0 ]]; then
            log "SUCCESS" "اكتملت جميع فحوصات CI بنجاح"
            return 0
        fi
        
        log "INFO" "الانتظار... عمليات فحص معلقة: ${pending_count} (${elapsed}/${timeout}s)"
        sleep "${check_interval}"
        elapsed=$((elapsed + check_interval))
    done
    
    log "ERROR" "انتهاء مهلة انتظار CI"
    return 1
}
```

### خط أنابيب النشر التلقائي

```bash
# خط أنابيب نشر كامل
run_deployment_pipeline() {
    local environment="${1:-staging}"
    local branch="${2:-$(git rev-parse --abbrev-ref HEAD)}"
    local repo="${3:-$(get_current_repo)}"
    
    log "INFO" "بدء خط أنابيب النشر: ${environment} <= ${branch}"
    
    # الخطوة 1: التحقق من اجتياز جميع فحوصات CI
    local latest_run
    latest_run=$(gh run list \
        --repo "${repo}" \
        --branch "${branch}" \
        --limit 1 \
        --json "databaseId,status,conclusion" \
        --jq '.[0]')
    
    local run_status
    run_status=$(echo "${latest_run}" | jq -r '.status')
    local run_conclusion
    run_conclusion=$(echo "${latest_run}" | jq -r '.conclusion')
    
    if [[ "${run_status}" != "completed" || "${run_conclusion}" != "success" ]]; then
        log "ERROR" "CI لم يكتمل بنجاح: status=${run_status}, conclusion=${run_conclusion}"
        return 1
    fi
    
    # الخطوة 2: إنشاء نشر
    local deployment_id
    deployment_id=$(gh api \
        --method POST \
        "/repos/${repo}/deployments" \
        --field "ref=${branch}" \
        --field "environment=${environment}" \
        --field "auto_merge=false" \
        --field "required_contexts=[]" \
        --jq '.id')
    
    log "INFO" "تم إنشاء النشر: ${deployment_id}"
    
    # الخطوة 3: تشغيل خطوات النشر الفعلية
    deploy_to_environment "${environment}" "${branch}"
    local deploy_result=$?
    
    # الخطوة 4: تحديث حالة النشر
    if [[ ${deploy_result} -eq 0 ]]; then
        gh api \
            --method POST \
            "/repos/${repo}/deployments/${deployment_id}/statuses" \
            --field "state=success" \
            --field "description=نجح النشر"
        
        log "SUCCESS" "اكتمل النشر لـ ${environment} بنجاح"
    else
        gh api \
            --method POST \
            "/repos/${repo}/deployments/${deployment_id}/statuses" \
            --field "state=failure" \
            --field "description=فشل النشر"
        
        log "ERROR" "فشل النشر لـ ${environment}"
        return 1
    fi
}
```

## أتمتة إعداد الفريق

### نص إعداد الأعضاء الجدد

```bash
#!/bin/bash
# setup-new-member.sh - أتمتة إعداد أعضاء الفريق الجدد

setup_new_team_member() {
    local username="${1}"
    local team_name="${2}"
    local org="${3:-$(gh api /user/orgs --jq '.[0].login')}"
    
    log "INFO" "إعداد عضو فريق جديد: ${username} في ${org}/${team_name}"
    
    # الخطوة 1: إضافة المستخدم إلى المنظمة
    gh api \
        --method PUT \
        "/orgs/${org}/memberships/${username}" \
        --field "role=member" &>/dev/null
    
    # الخطوة 2: إضافة إلى الفريق
    local team_slug
    team_slug=$(gh api "/orgs/${org}/teams" \
        --jq ".[] | select(.name == \"${team_name}\") | .slug")
    
    if [[ -z "${team_slug}" ]]; then
        log "WARNING" "الفريق غير موجود: ${team_name}. إنشاء..."
        team_slug=$(create_team "${team_name}" "${org}")
    fi
    
    gh api \
        --method PUT \
        "/orgs/${org}/teams/${team_slug}/memberships/${username}" \
        --field "role=member"
    
    # الخطوة 3: منح الأذونات اللازمة للمستودعات
    setup_repository_access "${username}" "${team_slug}" "${org}"
    
    # الخطوة 4: إرسال بريد ترحيبي تلقائي
    send_welcome_notification "${username}" "${org}" "${team_name}"
    
    log "SUCCESS" "اكتمل إعداد ${username}"
}

# إعداد الوصول للمستودعات
setup_repository_access() {
    local username="${1}"
    local team_slug="${2}"
    local org="${3}"
    
    # الحصول على قائمة المستودعات المعيّنة للفريق
    local repos
    repos=$(gh api \
        "/orgs/${org}/teams/${team_slug}/repos" \
        --jq '.[].full_name')
    
    while IFS= read -r repo; do
        # إضافة الإشارات وتكوين إعدادات المستودع
        setup_repo_notifications "${username}" "${repo}"
        log "INFO" "تم تكوين الوصول لـ ${repo}"
    done <<< "${repos}"
}

# إرسال إشعار ترحيبي
send_welcome_notification() {
    local username="${1}"
    local org="${2}"
    local team_name="${3}"
    
    local welcome_issue_body
    welcome_issue_body=$(cat << EOF
مرحبًا @${username}!

أهلًا بك في فريق ${team_name} التقني في ${org}.

## خطوات البدء

- [ ] راجع وثائق الفريق
- [ ] أعدّ بيئة التطوير المحلية
- [ ] اقرأ إرشادات المساهمة
- [ ] تعرّف على زملاء الفريق

## أدوات مفيدة

- نظام إدارة المشاريع: GitHub Projects
- قناة التواصل: Slack #engineering
- وثائق الفريق: wiki

نحن سعداء بانضمامك!
EOF
)
    
    # إنشاء issue ترحيبية في مستودع المنظمة
    gh issue create \
        --repo "${org}/.github" \
        --title "ترحيب بعضو جديد: @${username}" \
        --body "${welcome_issue_body}" \
        --label "onboarding" \
        --assignee "${username}" 2>/dev/null || true
}
```

## دمج zshrc وتحسين سير العمل

### إعداد بيئة GitHub CLI الكاملة

```bash
# ~/.zshrc - إضافات GitHub CLI

# ===== إعداد GitHub CLI =====
export GH_PAGER="less -FRX"
export GH_NO_UPDATE_NOTIFIER=1

# ===== اختصارات GitHub CLI =====
alias ghpr='gh pr create --fill'
alias ghprl='gh pr list --assignee @me'
alias ghprv='gh pr view --web'
alias ghis='gh issue create'
alias ghisl='gh issue list --assignee @me'
alias ghrun='gh run list --limit 5'
alias ghrw='gh run watch'

# ===== وظائف GitHub CLI المتقدمة =====

# بحث سريع وإنشاء PR
ghprc() {
    local title="${1:-}"
    local base="${2:-main}"
    
    if [[ -z "${title}" ]]; then
        gh pr create --fill --web
    else
        gh pr create \
            --title "${title}" \
            --base "${base}" \
            --fill
    fi
}

# دمج PR بعد الفحص
ghrm() {
    local pr_number="${1:-}"
    
    if [[ -z "${pr_number}" ]]; then
        # استخدام PR الحالي
        pr_number=$(gh pr view --json number --jq '.number' 2>/dev/null)
    fi
    
    if [[ -z "${pr_number}" ]]; then
        echo "لا يوجد PR مرتبط بالفرع الحالي"
        return 1
    fi
    
    # فحص حالة CI
    echo "جاري التحقق من حالة CI للـ PR #${pr_number}..."
    gh pr checks "${pr_number}" --watch
    
    # دمج بعد اجتياز الفحوصات
    gh pr merge "${pr_number}" --merge --delete-branch
}

# عرض لوحة تحكم سريعة
ghd() {
    echo "=== لوحة تحكم GitHub ==="
    echo ""
    
    echo "--- طلبات السحب الخاصة بي ---"
    gh pr list --assignee @me --limit 5 --json "number,title,state" \
        --jq '.[] | "#\(.number) \(.state) - \(.title)"'
    
    echo ""
    echo "--- المشكلات الخاصة بي ---"
    gh issue list --assignee @me --limit 5 --json "number,title,state" \
        --jq '.[] | "#\(.number) \(.state) - \(.title)"'
    
    echo ""
    echo "--- آخر سير العمل ---"
    gh run list --limit 3 --json "name,status,conclusion" \
        --jq '.[] | "\(.name): \(.status)/\(.conclusion)"'
}
```

## قائمة التحقق من النشر

### سير عمل مراجعة ما قبل النشر

```bash
#!/bin/bash
# pre-deploy-checklist.sh - التحقق الآلي قبل النشر

run_pre_deploy_checklist() {
    local repo="${1:-$(get_current_repo)}"
    local environment="${2:-production}"
    local branch="${3:-main}"
    
    log "INFO" "تشغيل قائمة التحقق قبل نشر ${environment}"
    
    local failed_checks=0
    local total_checks=0
    
    # قائمة الفحوصات
    declare -A checks=(
        ["اجتياز فحوصات CI"]="check_ci_status ${branch} ${repo}"
        ["اكتمال مراجعات الكود"]="check_pr_reviews ${repo}"
        ["بيئة النشر جاهزة"]="check_environment_health ${environment}"
        ["قاعدة البيانات محدّثة"]="check_database_migrations ${environment}"
        ["الخدمات التابعة تعمل"]="check_dependencies ${environment}"
    )
    
    for check_name in "${!checks[@]}"; do
        total_checks=$((total_checks + 1))
        
        echo -n "فحص: ${check_name}... "
        
        if eval "${checks[${check_name}]}" &>/dev/null; then
            echo -e "${GREEN}PASS${NC}"
        else
            echo -e "${RED}FAIL${NC}"
            failed_checks=$((failed_checks + 1))
        fi
    done
    
    echo ""
    echo "نتائج الفحص: $((total_checks - failed_checks))/${total_checks} نجاح"
    
    if [[ ${failed_checks} -gt 0 ]]; then
        log "ERROR" "فشل في ${failed_checks} فحص. إلغاء النشر."
        return 1
    fi
    
    log "SUCCESS" "نجاحت جميع فحوصات ما قبل النشر"
    return 0
}
```

## تحسين أداء GitHub CLI

### التخزين المؤقت وتجميع الطلبات

```bash
# آلية التخزين المؤقت للطلبات المتكررة
cached_gh_api() {
    local endpoint="${1}"
    local cache_ttl="${2:-300}" # 5 دقائق افتراضيًا
    local cache_file="${CACHE_DIR}/$(echo "${endpoint}" | md5sum | cut -d' ' -f1).json"
    
    # فحص صلاحية الكاش
    if [[ -f "${cache_file}" ]]; then
        local cache_age=$(( $(date +%s) - $(stat -c %Y "${cache_file}") ))
        
        if [[ ${cache_age} -lt ${cache_ttl} ]]; then
            cat "${cache_file}"
            return 0
        fi
    fi
    
    # جلب البيانات الحديثة
    local data
    data=$(gh api "${endpoint}")
    echo "${data}" > "${cache_file}"
    echo "${data}"
}

# تجميع الطلبات المتوازية
batch_api_requests() {
    local requests=("$@")
    local tmpdir=$(mktemp -d)
    local pids=()
    
    # تشغيل الطلبات بالتوازي
    for i in "${!requests[@]}"; do
        gh api "${requests[${i}]}" > "${tmpdir}/result_${i}.json" &
        pids+=($!)
    done
    
    # الانتظار لإتمام جميع الطلبات
    for pid in "${pids[@]}"; do
        wait "${pid}"
    done
    
    # دمج النتائج
    for i in "${!requests[@]}"; do
        if [[ -f "${tmpdir}/result_${i}.json" ]]; then
            cat "${tmpdir}/result_${i}.json"
        fi
    done
    
    rm -rf "${tmpdir}"
}
```

## نظام النسخ الاحتياطي والتعافي

### نسخ احتياطي لتكوينات المستودع

```bash
#!/bin/bash
# backup-repo-config.sh - نسخ احتياطي لتكوينات المستودع

backup_repository_config() {
    local repo="${1}"
    local backup_dir="${2:-${HOME}/.gh-backups/$(date '+%Y%m%d')}"
    
    mkdir -p "${backup_dir}/${repo//\//_}"
    
    log "INFO" "بدء نسخ احتياطي لـ ${repo}"
    
    # نسخ احتياطي للإعدادات
    backup_settings() {
        gh api "/repos/${repo}" \
            --jq '{
                name, description, private, 
                has_issues, has_projects, has_wiki,
                allow_merge_commit, allow_squash_merge, allow_rebase_merge,
                delete_branch_on_merge
            }' > "${backup_dir}/${repo//\//_}/settings.json"
    }
    
    # نسخ احتياطي للتسميات
    backup_labels() {
        gh label list \
            --repo "${repo}" \
            --json "name,color,description" \
            > "${backup_dir}/${repo//\//_}/labels.json"
    }
    
    # نسخ احتياطي لقواعد حماية الفروع
    backup_branch_protection() {
        local default_branch
        default_branch=$(gh api "/repos/${repo}" --jq '.default_branch')
        
        gh api "/repos/${repo}/branches/${default_branch}/protection" \
            2>/dev/null \
            > "${backup_dir}/${repo//\//_}/branch_protection.json" || true
    }
    
    backup_settings
    backup_labels
    backup_branch_protection
    
    log "SUCCESS" "اكتمل النسخ الاحتياطي في ${backup_dir}"
}

# استعادة التكوين من نسخة احتياطية
restore_repository_config() {
    local repo="${1}"
    local backup_dir="${2}"
    
    if [[ ! -d "${backup_dir}" ]]; then
        log "ERROR" "دليل النسخ الاحتياطي غير موجود: ${backup_dir}"
        return 1
    fi
    
    log "INFO" "استعادة تكوين ${repo} من ${backup_dir}"
    
    # استعادة التسميات
    if [[ -f "${backup_dir}/labels.json" ]]; then
        local labels
        labels=$(cat "${backup_dir}/labels.json")
        
        echo "${labels}" | jq -c '.[]' | while IFS= read -r label; do
            local name color description
            name=$(echo "${label}" | jq -r '.name')
            color=$(echo "${label}" | jq -r '.color')
            description=$(echo "${label}" | jq -r '.description // ""')
            
            gh label create \
                --repo "${repo}" \
                "${name}" \
                --color "${color}" \
                --description "${description}" \
                --force 2>/dev/null || true
        done
    fi
    
    log "SUCCESS" "اكتملت الاستعادة"
}
```

![رسم معماري لنظام أتمتة GitHub CLI المتكامل: تحميل zshrc ← الوحدات ← موزّع gh الموحّد ← GitHub](/assets/images/github-cli-advanced-workflows-diagram.svg)

## الخلاصة

في هذه السلسلة المكونة من خمسة أجزاء، تعلمنا:

### ما تعلمناه

1. **الأساسيات**: استخدام gh CLI الأساسي والعمليات اليومية
2. **أتمتة PR**: أتمتة دورة حياة طلبات السحب بالكامل
3. **إدارة المشاريع**: إدارة المشاريع القائمة على السياق وإعداد التقارير
4. **أتمتة Wiki**: أتمتة الوثائق المتعددة اللغات
5. **سير العمل المتقدمة**: نظام التحكم الرئيسي وتكامل CI/CD

### التوصيات النهائية

```bash
# قائمة المراجعة النهائية

# 1. ابدأ بالتدريج
start_simple() {
    echo "ابدأ بالاختصارات الأساسية وأضف الأتمتة تدريجيًا"
}

# 2. وثّق سير العمل
document_workflows() {
    echo "احتفظ بتوثيق محدّث لعمليات الأتمتة الخاصة بك"
}

# 3. اختبر قبل الأتمتة
test_before_automating() {
    echo "تحقق يدويًا أولًا، ثم أتمت عندما تكون العملية ثابتة"
}
```

**الخطوات التالية**:
- [توثيق GitHub CLI الرسمي](https://cli.github.com/manual/)
- [موسوعة GitHub Actions](https://github.com/features/actions)
- [واجهة برمجة تطبيقات GitHub REST](https://docs.github.com/en/rest)

## المصادر

- [GitHub CLI Manual (cli.github.com)](https://cli.github.com/manual/)
- [cli/cli - مستودع GitHub CLI](https://github.com/cli/cli)
- [توثيق GitHub Actions](https://docs.github.com/en/actions)
- [توثيق GitHub Projects](https://docs.github.com/en/issues/planning-and-tracking-with-projects)
