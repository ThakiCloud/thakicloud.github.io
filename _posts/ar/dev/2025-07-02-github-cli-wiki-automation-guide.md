---
title: "GitHub CLI - أتمتة Wiki والوثائق متعددة اللغات [الجزء 4]"
excerpt: "نظام وثائق Wiki معياري باستخدام GitHub CLI: توليد وثائق API تلقائيًا من OpenAPI والكود، وإدارة Wiki متعدد اللغات، وتتبع حالة الترجمة."
seo_title: "أتمتة GitHub CLI لـ Wiki والوثائق متعددة اللغات - Thaki Cloud"
seo_description: "دليل شامل لأتمتة وثائق GitHub Wiki باستخدام GitHub CLI: توليد تلقائي لوثائق API، وإدارة متعددة اللغات، وتتبع تحديثات الوثائق."
date: 2025-07-02
last_modified_at: 2025-07-02
categories:
  - dev
tags:
  - github-cli
  - wiki
  - documentation
  - automation
  - OpenAPI
  - multilingual
  - i18n
  - developer-experience
lang: ar
dir: rtl
author_profile: true
toc: true
toc_label: "أتمتة Wiki"
canonical_url: "https://thakicloud.github.io/ar/dev/github-cli-wiki-automation-guide/"
published: false
---

⏱️ **وقت القراءة المقدر**: 22 دقائق

هذا الجزء الرابع من سلسلة GitHub CLI. سنتعلم كيفية بناء نظام Wiki معياري وتوليد الوثائق تلقائيًا.

## بنية النظام المعياري لـ Wiki

### الهيكل الأساسي

```bash
.github/wiki/
   bin/
      wiki-init.sh           # تهيئة Wiki
      wiki-update.sh         # تحديث الصفحات
      api-doc-gen.sh         # توليد وثائق API
      translate-check.sh     # فحص حالة الترجمة
   templates/
      page-template.md       # قالب الصفحة
      api-template.md        # قالب وثيقة API
   config/
      wiki-config.json       # إعدادات Wiki
   scripts/
      extract-jsdoc.js       # استخراج تعليقات JSDoc
      parse-openapi.py       # تحليل مواصفات OpenAPI
```

### تهيئة Wiki

```bash
#!/bin/bash
# wiki-init.sh - تهيئة نظام Wiki

REPO="${1}"
WIKI_DIR="${HOME}/.wiki-automation/${REPO//\//_}"

init_wiki() {
    local repo="${1}"
    
    echo "تهيئة Wiki للمستودع: ${repo}"
    
    # استنساخ مستودع Wiki
    local wiki_url="https://github.com/${repo}.wiki.git"
    local local_wiki_path="${WIKI_DIR}/wiki"
    
    if [[ -d "${local_wiki_path}" ]]; then
        # تحديث المستودع الموجود
        git -C "${local_wiki_path}" pull origin master 2>/dev/null || \
        git -C "${local_wiki_path}" pull origin main 2>/dev/null
    else
        mkdir -p "${WIKI_DIR}"
        git clone "${wiki_url}" "${local_wiki_path}" 2>/dev/null || {
            echo "تعذّر الاستنساخ. التحقق من تفعيل Wiki..."
            enable_wiki "${repo}"
            git clone "${wiki_url}" "${local_wiki_path}"
        }
    fi
    
    echo "تمت التهيئة: ${local_wiki_path}"
}

# تفعيل Wiki في المستودع
enable_wiki() {
    local repo="${1}"
    
    gh api \
        --method PATCH \
        "/repos/${repo}" \
        --field "has_wiki=true" \
        --jq '.has_wiki'
    
    echo "تم تفعيل Wiki"
}

init_wiki "${REPO}"
```

## توليد وثائق API تلقائيًا

### من مواصفات OpenAPI

```bash
#!/bin/bash
# api-doc-gen.sh - توليد وثائق API من OpenAPI

generate_api_docs_from_openapi() {
    local openapi_file="${1}"
    local output_dir="${2}"
    local language="${3:-ar}"
    
    echo "توليد وثائق API من: ${openapi_file}"
    
    # التحقق من وجود الملف
    if [[ ! -f "${openapi_file}" ]]; then
        echo "خطأ: ملف OpenAPI غير موجود: ${openapi_file}"
        return 1
    fi
    
    # استخراج معلومات API
    local api_title
    api_title=$(python3 -c "
import yaml, json, sys

with open('${openapi_file}') as f:
    spec = yaml.safe_load(f) if '${openapi_file}'.endswith('.yaml') else json.load(f)

info = spec.get('info', {})
print(info.get('title', 'API Documentation'))
")
    
    local api_version
    api_version=$(python3 -c "
import yaml, json

with open('${openapi_file}') as f:
    spec = yaml.safe_load(f) if '${openapi_file}'.endswith('.yaml') else json.load(f)

info = spec.get('info', {})
print(info.get('version', '1.0.0'))
")
    
    # توليد ملفات الوثائق
    python3 << 'PYTHON_SCRIPT'
import yaml
import json
import sys
import os
from datetime import datetime

openapi_file = sys.argv[1] if len(sys.argv) > 1 else ''
output_dir = sys.argv[2] if len(sys.argv) > 2 else './docs'
language = sys.argv[3] if len(sys.argv) > 3 else 'en'

with open(openapi_file) as f:
    if openapi_file.endswith('.yaml') or openapi_file.endswith('.yml'):
        spec = yaml.safe_load(f)
    else:
        spec = json.load(f)

os.makedirs(output_dir, exist_ok=True)

paths = spec.get('paths', {})
tags = {}

for path, methods in paths.items():
    for method, details in methods.items():
        if method in ['get', 'post', 'put', 'delete', 'patch']:
            for tag in details.get('tags', ['General']):
                if tag not in tags:
                    tags[tag] = []
                tags[tag].append({
                    'method': method.upper(),
                    'path': path,
                    'summary': details.get('summary', ''),
                    'description': details.get('description', ''),
                    'parameters': details.get('parameters', []),
                    'requestBody': details.get('requestBody', {}),
                    'responses': details.get('responses', {})
                })

for tag, endpoints in tags.items():
    filename = f"{tag.lower().replace(' ', '-')}.md"
    filepath = os.path.join(output_dir, filename)
    
    with open(filepath, 'w', encoding='utf-8') as f:
        if language == 'ar':
            f.write(f"# {tag}\n\n")
            f.write(f"> تاريخ التوليد: {datetime.now().strftime('%Y-%m-%d %H:%M')}\n\n")
        else:
            f.write(f"# {tag}\n\n")
            f.write(f"> Generated: {datetime.now().strftime('%Y-%m-%d %H:%M')}\n\n")
        
        for endpoint in endpoints:
            f.write(f"## {endpoint['method']} `{endpoint['path']}`\n\n")
            f.write(f"{endpoint['summary']}\n\n")
            
            if endpoint['description']:
                f.write(f"{endpoint['description']}\n\n")
            
            if endpoint['parameters']:
                if language == 'ar':
                    f.write("### المعاملات\n\n")
                    f.write("| الاسم | الموقع | النوع | مطلوب | الوصف |\n")
                    f.write("|------|--------|------|-------|-------|\n")
                else:
                    f.write("### Parameters\n\n")
                    f.write("| Name | In | Type | Required | Description |\n")
                    f.write("|------|----|----|----------|-------------|\n")
                
                for param in endpoint['parameters']:
                    name = param.get('name', '')
                    location = param.get('in', '')
                    param_type = param.get('schema', {}).get('type', 'string')
                    required = 'نعم' if language == 'ar' and param.get('required', False) else ('Yes' if param.get('required', False) else 'No' if language != 'ar' else 'لا')
                    description = param.get('description', '')
                    f.write(f"| `{name}` | {location} | {param_type} | {required} | {description} |\n")
                
                f.write("\n")

print(f"تم توليد الوثائق في: {output_dir}")
PYTHON_SCRIPT
    
    echo "اكتمل توليد الوثائق"
}
```

### من تعليقات الكود (JSDoc)

```bash
# استخراج وثائق من تعليقات JSDoc
generate_docs_from_jsdoc() {
    local source_dir="${1}"
    local output_dir="${2}"
    
    echo "استخراج تعليقات JSDoc من: ${source_dir}"
    
    node << 'NODE_SCRIPT'
const fs = require('fs');
const path = require('path');

const sourceDir = process.argv[2] || './src';
const outputDir = process.argv[3] || './docs/api';

// البحث عن ملفات JavaScript/TypeScript
function findJSFiles(dir) {
    const files = [];
    const entries = fs.readdirSync(dir, { withFileTypes: true });
    
    for (const entry of entries) {
        const fullPath = path.join(dir, entry.name);
        if (entry.isDirectory() && !entry.name.startsWith('.') && entry.name !== 'node_modules') {
            files.push(...findJSFiles(fullPath));
        } else if (/\.(js|ts|jsx|tsx)$/.test(entry.name)) {
            files.push(fullPath);
        }
    }
    
    return files;
}

// استخراج تعليقات JSDoc
function extractJSDoc(content) {
    const jsdocPattern = /\/\*\*([\s\S]*?)\*\//g;
    const docs = [];
    let match;
    
    while ((match = jsdocPattern.exec(content)) !== null) {
        const comment = match[1];
        const doc = {
            description: '',
            params: [],
            returns: null,
            examples: []
        };
        
        const lines = comment.split('\n').map(l => l.replace(/^\s*\*\s?/, '').trim());
        
        for (const line of lines) {
            if (line.startsWith('@param')) {
                const paramMatch = line.match(/@param\s+\{([^}]+)\}\s+(\S+)\s*(.*)/);
                if (paramMatch) {
                    doc.params.push({
                        type: paramMatch[1],
                        name: paramMatch[2],
                        description: paramMatch[3]
                    });
                }
            } else if (line.startsWith('@returns') || line.startsWith('@return')) {
                const returnMatch = line.match(/@returns?\s+\{([^}]+)\}\s*(.*)/);
                if (returnMatch) {
                    doc.returns = { type: returnMatch[1], description: returnMatch[2] };
                }
            } else if (line.startsWith('@example')) {
                doc.examples.push(line.replace('@example', '').trim());
            } else if (!line.startsWith('@') && line) {
                doc.description += (doc.description ? ' ' : '') + line;
            }
        }
        
        docs.push(doc);
    }
    
    return docs;
}

// توليد Markdown
function generateMarkdown(file, docs) {
    let md = `# ${path.basename(file)}\n\n`;
    
    for (const doc of docs) {
        if (doc.description) {
            md += `## الوصف\n\n${doc.description}\n\n`;
        }
        
        if (doc.params.length > 0) {
            md += `## المعاملات\n\n`;
            md += `| الاسم | النوع | الوصف |\n`;
            md += `|------|------|-------|\n`;
            for (const param of doc.params) {
                md += `| \`${param.name}\` | ${param.type} | ${param.description} |\n`;
            }
            md += '\n';
        }
        
        if (doc.returns) {
            md += `## القيمة المرجعة\n\n`;
            md += `**النوع**: \`${doc.returns.type}\`\n\n`;
            if (doc.returns.description) {
                md += `${doc.returns.description}\n\n`;
            }
        }
        
        if (doc.examples.length > 0) {
            md += `## مثال\n\n\`\`\`javascript\n${doc.examples.join('\n')}\n\`\`\`\n\n`;
        }
    }
    
    return md;
}

const files = findJSFiles(sourceDir);
fs.mkdirSync(outputDir, { recursive: true });

for (const file of files) {
    const content = fs.readFileSync(file, 'utf8');
    const docs = extractJSDoc(content);
    
    if (docs.length > 0) {
        const relativePath = path.relative(sourceDir, file);
        const outputFile = path.join(outputDir, relativePath.replace(/\.(js|ts|jsx|tsx)$/, '.md'));
        
        fs.mkdirSync(path.dirname(outputFile), { recursive: true });
        fs.writeFileSync(outputFile, generateMarkdown(file, docs));
        
        console.log(`تم توليد: ${outputFile}`);
    }
}
NODE_SCRIPT
}
```

## إدارة Wiki متعدد اللغات

### هيكل الترجمة

```bash
#!/bin/bash
# multilingual-wiki.sh - إدارة Wiki متعدد اللغات

# الهيكل المقترح لـ Wiki متعدد اللغات
# Home.md (الصفحة الرئيسية)
# ar/
#   Home.md
#   API/
#     ...
# en/
#   Home.md
#   API/
#     ...
# ko/
#   Home.md
#   ...

SUPPORTED_LANGUAGES=("ar" "en" "ko" "ja" "zh")

# إنشاء هيكل Wiki متعدد اللغات
setup_multilingual_wiki() {
    local wiki_path="${1}"
    local base_language="${2:-ko}"
    
    echo "إعداد هيكل Wiki متعدد اللغات"
    
    for lang in "${SUPPORTED_LANGUAGES[@]}"; do
        mkdir -p "${wiki_path}/${lang}"
        
        # إنشاء ملف الصفحة الرئيسية
        if [[ ! -f "${wiki_path}/${lang}/Home.md" ]]; then
            create_home_page "${wiki_path}/${lang}/Home.md" "${lang}"
        fi
    done
    
    # إنشاء صفحة التنقل الرئيسية
    create_navigation_sidebar "${wiki_path}" "${SUPPORTED_LANGUAGES[@]}"
    
    echo "اكتمل إعداد الهيكل متعدد اللغات"
}

# إنشاء الصفحة الرئيسية بلغة محددة
create_home_page() {
    local file_path="${1}"
    local language="${2}"
    
    case "${language}" in
        "ar")
            cat > "${file_path}" << 'EOF'
# مرحبًا بك في الوثائق

اختر اللغة المفضلة لديك:

- [العربية](ar/Home)
- [English](en/Home)
- [한국어](ko/Home)

## أحدث التحديثات

سيظهر هنا آخر تحديث للوثائق تلقائيًا.
EOF
            ;;
        "en")
            cat > "${file_path}" << 'EOF'
# Welcome to the Documentation

## Getting Started

This wiki contains comprehensive documentation for the project.

## Latest Updates

Documentation updates will appear here automatically.
EOF
            ;;
    esac
    
    echo "تم إنشاء الصفحة الرئيسية: ${file_path}"
}

# نشر التحديثات في Wiki
publish_wiki_updates() {
    local wiki_path="${1}"
    local commit_message="${2:-تحديث الوثائق تلقائيًا}"
    
    cd "${wiki_path}" || return 1
    
    git add .
    
    if git diff --cached --quiet; then
        echo "لا توجد تغييرات للنشر"
        return 0
    fi
    
    git commit -m "${commit_message}"
    git push origin HEAD
    
    echo "تم نشر تحديثات Wiki"
}
```

## تتبع حالة الترجمة

### نظام تتبع الترجمة

```bash
#!/bin/bash
# translate-check.sh - تتبع حالة ترجمة الوثائق

# فحص مدى اكتمال الترجمة
check_translation_status() {
    local wiki_path="${1}"
    local source_lang="${2:-en}"
    
    echo "=== حالة الترجمة ==="
    echo ""
    
    # الحصول على جميع الملفات في اللغة المصدر
    local source_files
    source_files=$(find "${wiki_path}/${source_lang}" -name "*.md" -type f | sort)
    
    for lang in "${SUPPORTED_LANGUAGES[@]}"; do
        if [[ "${lang}" == "${source_lang}" ]]; then
            continue
        fi
        
        local total=0
        local translated=0
        local outdated=0
        
        while IFS= read -r source_file; do
            total=$((total + 1))
            
            # مقارنة المسار في اللغة الأخرى
            local relative_path="${source_file#${wiki_path}/${source_lang}/}"
            local target_file="${wiki_path}/${lang}/${relative_path}"
            
            if [[ -f "${target_file}" ]]; then
                # مقارنة تاريخ التعديل
                local source_time
                source_time=$(stat -c %Y "${source_file}" 2>/dev/null || stat -f %m "${source_file}")
                local target_time
                target_time=$(stat -c %Y "${target_file}" 2>/dev/null || stat -f %m "${target_file}")
                
                if [[ ${source_time} -gt ${target_time} ]]; then
                    outdated=$((outdated + 1))
                else
                    translated=$((translated + 1))
                fi
            fi
        done <<< "${source_files}"
        
        local missing=$((total - translated - outdated))
        local completion_rate=0
        if [[ ${total} -gt 0 ]]; then
            completion_rate=$(( translated * 100 / total ))
        fi
        
        printf "%-10s: %d/%d (%d%%) - ناقصة: %d, قديمة: %d\n" \
            "${lang}" "${translated}" "${total}" "${completion_rate}" "${missing}" "${outdated}"
    done
}

# إنشاء تقرير مفصل بالملفات الناقصة
generate_missing_translations_report() {
    local wiki_path="${1}"
    local source_lang="${2:-en}"
    local output_file="${3:-translation-status.md}"
    
    {
        echo "# حالة الترجمة"
        echo ""
        echo "تاريخ التقرير: $(date '+%Y-%m-%d')"
        echo ""
        
        for lang in "${SUPPORTED_LANGUAGES[@]}"; do
            if [[ "${lang}" == "${source_lang}" ]]; then
                continue
            fi
            
            echo "## ${lang}"
            echo ""
            echo "| الملف | الحالة |"
            echo "|-------|--------|"
            
            find "${wiki_path}/${source_lang}" -name "*.md" -type f | sort | while read -r source_file; do
                local relative_path="${source_file#${wiki_path}/${source_lang}/}"
                local target_file="${wiki_path}/${lang}/${relative_path}"
                
                local status
                if [[ -f "${target_file}" ]]; then
                    local source_time
                    source_time=$(stat -c %Y "${source_file}" 2>/dev/null || stat -f %m "${source_file}")
                    local target_time
                    target_time=$(stat -c %Y "${target_file}" 2>/dev/null || stat -f %m "${target_file}")
                    
                    if [[ ${source_time} -gt ${target_time} ]]; then
                        status="قديمة"
                    else
                        status="مكتملة"
                    fi
                else
                    status="ناقصة"
                fi
                
                echo "| \`${relative_path}\` | ${status} |"
            done
            
            echo ""
        done
    } > "${output_file}"
    
    echo "تم إنشاء تقرير الترجمة: ${output_file}"
}
```

## دمج zshrc لـ Wiki

### وظائف Wiki في zshrc

```bash
# ~/.zshrc - وظائف Wiki

# ===== إعدادات Wiki =====
export WIKI_BASE_DIR="${HOME}/.wiki-automation"
export WIKI_DEFAULT_LANG="ar"

# ===== اختصارات Wiki =====
alias wikis='wiki-status'
alias wikiu='wiki-update'
alias wikie='wiki-edit'

# عرض حالة Wiki
wiki-status() {
    local repo="${1:-$(gh repo view --json nameWithOwner --jq '.nameWithOwner' 2>/dev/null)}"
    
    if [[ -z "${repo}" ]]; then
        echo "خطأ: يجب تحديد المستودع"
        return 1
    fi
    
    echo "=== حالة Wiki: ${repo} ==="
    
    local wiki_path="${WIKI_BASE_DIR}/${repo//\//_}/wiki"
    
    if [[ ! -d "${wiki_path}" ]]; then
        echo "Wiki غير مهيأ. تشغيل: wiki-init ${repo}"
        return 1
    fi
    
    # عرض عدد الملفات
    local file_count
    file_count=$(find "${wiki_path}" -name "*.md" | wc -l)
    echo "عدد الصفحات: ${file_count}"
    
    # عرض آخر تحديث
    local last_update
    last_update=$(git -C "${wiki_path}" log -1 --format="%ar" 2>/dev/null || echo "غير معروف")
    echo "آخر تحديث: ${last_update}"
    
    # فحص حالة الترجمة
    if [[ -d "${wiki_path}/en" || -d "${wiki_path}/ar" ]]; then
        echo ""
        echo "حالة الترجمة:"
        check_translation_status "${wiki_path}" "en"
    fi
}

# تحديث Wiki
wiki-update() {
    local repo="${1:-$(gh repo view --json nameWithOwner --jq '.nameWithOwner' 2>/dev/null)}"
    local message="${2:-تحديث تلقائي للوثائق}"
    
    local wiki_path="${WIKI_BASE_DIR}/${repo//\//_}/wiki"
    
    if [[ ! -d "${wiki_path}" ]]; then
        echo "Wiki غير مهيأ. تشغيل: wiki-init ${repo}"
        return 1
    fi
    
    # سحب آخر التغييرات
    git -C "${wiki_path}" pull --rebase
    
    # توليد وثائق API إذا وجدت
    if [[ -f "openapi.yaml" || -f "openapi.json" ]]; then
        local openapi_file
        openapi_file=$(ls openapi.yaml openapi.json 2>/dev/null | head -1)
        
        generate_api_docs_from_openapi "${openapi_file}" "${wiki_path}/api/${WIKI_DEFAULT_LANG}"
    fi
    
    # نشر التغييرات
    publish_wiki_updates "${wiki_path}" "${message}"
}

# تحرير صفحة في Wiki
wiki-edit() {
    local page="${1}"
    local lang="${2:-${WIKI_DEFAULT_LANG}}"
    local repo="${3:-$(gh repo view --json nameWithOwner --jq '.nameWithOwner' 2>/dev/null)}"
    
    local wiki_path="${WIKI_BASE_DIR}/${repo//\//_}/wiki"
    local page_file="${wiki_path}/${lang}/${page}.md"
    
    mkdir -p "$(dirname "${page_file}")"
    
    "${EDITOR:-vim}" "${page_file}"
    
    # النشر بعد التحرير
    read -p "نشر التغييرات؟ [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        publish_wiki_updates "${wiki_path}" "تحديث: ${page}"
    fi
}
```

## الخلاصة

في هذا الجزء الرابع، تعلمنا:

- **نظام Wiki المعياري**: بناء نظام مرن وقابل للتوسع
- **توليد وثائق API تلقائيًا**: من مواصفات OpenAPI وتعليقات الكود
- **إدارة متعددة اللغات**: دعم المستخدمين في مناطق مختلفة
- **تتبع الترجمة**: مراقبة حالة الترجمة ومنع الوثائق القديمة
- **دمج zshrc**: تحسين سير العمل بأوامر سريعة

**المقالة التالية**: الجزء 5 - سير العمل المتقدمة وتكامل CI/CD (الجزء الأخير في السلسلة)
