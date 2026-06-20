---
title: "macOS GitHub CLI Complete Automation Series - Part 4: Complete Wiki Management Automation"
excerpt: "Auto-generate wikis from code, sync API documentation, and manage multilingual docs - automate your entire development documentation workflow"
seo_title: "GitHub CLI Wiki Automation Part 4 - Complete Documentation Automation - Thaki Cloud"
seo_description: "Expert guide to automating wiki generation, API doc synchronization, multilingual support, version management, and documentation quality checks with GitHub CLI"
date: 2025-07-02
categories:
  - dev
tags:
  - github-cli
  - wiki-automation
  - documentation
  - api-docs
  - markdown
  - multilingual
  - versioning
lang: en
author_profile: true
toc: true
canonical_url: "https://thakicloud.github.io/en/dev/github-cli-wiki-automation-guide/"
published: true
---

⏱️ **Estimated reading time**: 22 min

## Series Overview

Part 4 of the **macOS GitHub CLI Complete Automation Series** covers complete automation of wiki management, the foundation of development documentation. We will build an expert-level system that automatically reflects code changes in the wiki, synchronizes API documentation, and supports multiple languages.

## Building a Modular Script System

### 1. Script Directory Structure

```bash
# Create an organized script structure
mkdir -p ~/scripts/github-cli/{wiki,core,utils,config}

# Create config file
cat > ~/scripts/github-cli/config/wiki-config.sh << 'EOF'
#!/bin/bash

# Wiki automation configuration
export WIKI_CONFIG_VERSION="1.0"
export WIKI_BASE_DIR="$HOME/Documents/wikis"
export WIKI_TEMPLATES_DIR="$HOME/scripts/github-cli/wiki/templates"
export WIKI_CACHE_DIR="$HOME/.cache/github-wikis"
export WIKI_BACKUP_DIR="$HOME/Documents/wiki-backups"

# Multilingual configuration
export SUPPORTED_LANGUAGES="ko,en,ja,zh"
export DEFAULT_LANGUAGE="en"

# API docs configuration
export API_DOCS_FORMAT="markdown"
export API_DOCS_AUTO_UPDATE="true"

# Quality validation configuration
export SPELL_CHECK_ENABLED="true"
export LINK_CHECK_ENABLED="true"
export TOC_AUTO_GENERATE="true"

echo "Wiki configuration loaded."
EOF

chmod +x ~/scripts/github-cli/config/wiki-config.sh
```

### 2. Core Wiki Functions

```bash
# Core wiki functions
cat > ~/scripts/github-cli/wiki/wiki-core.sh << 'EOF'
#!/bin/bash

# Wiki repository management
function wiki_init() {
    local repo_url="$1"
    local wiki_name="${2:-$(basename "$repo_url" .git)}"
    
    if [[ -z "$repo_url" ]]; then
        echo "Usage: wiki_init <repository URL> [wiki name]"
        return 1
    fi
    
    # Create wiki directory
    local wiki_dir="$WIKI_BASE_DIR/$wiki_name"
    mkdir -p "$wiki_dir"
    cd "$wiki_dir"
    
    # Clone/initialize wiki repository
    if [[ "$repo_url" == *".wiki.git" ]]; then
        git clone "$repo_url" .
    else
        # Extract wiki URL from main repository
        local wiki_url="${repo_url%.git}.wiki.git"
        git clone "$wiki_url" . 2>/dev/null || {
            # Create wiki if it doesn't exist
            echo "Creating new wiki..."
            git init .
            create_wiki_structure
        }
    fi
    
    echo "OK: Wiki '$wiki_name' initialized at: $wiki_dir"
}

# Create wiki structure
function create_wiki_structure() {
    # Home page
    cat > Home.md << 'HOMEEOF'
# Project Wiki

Welcome! This wiki is automatically generated and maintained.

## Documentation Structure

- [API Documentation](API-Documentation)
- [Installation Guide](Installation-Guide)
- [Development Guide](Development-Guide)
- [FAQ](FAQ)
- [Changelog](Changelog)

## Multilingual Support

- [English](Home) (current)
- [Korean](Home-KO)
- [Japanese](Home-JA)
- [Chinese](Home-ZH)

---
*This document was automatically generated. Last updated: $(date)*
HOMEEOF

    # Create default pages
    create_api_documentation_template
    create_installation_guide_template
    create_development_guide_template
    create_faq_template
    
    # Initial commit
    git add .
    git commit -m "Initial wiki structure created automatically"
    
    echo "OK: Default wiki structure created."
}

# API documentation template
function create_api_documentation_template() {
    cat > API-Documentation.md << 'APIEOF'
# API Documentation

This page is automatically generated and updated.

## Authentication

```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
     https://api.example.com/v1/endpoint
```

## Endpoints

### Overview
- **Base URL**: `https://api.example.com/v1`
- **API Version**: v1
- **Response Format**: JSON

---
*API documentation is auto-generated from code.*
APIEOF
}

# Automatic wiki update
function wiki_auto_update() {
    local repo_path="${1:-.}"
    local wiki_path="$2"
    
    if [[ -z "$wiki_path" ]]; then
        # Auto-detect wiki path for current repository
        local repo_name=$(basename "$(git -C "$repo_path" remote get-url origin)" .git)
        wiki_path="$WIKI_BASE_DIR/$repo_name"
    fi
    
    if [[ ! -d "$wiki_path" ]]; then
        echo "FAIL: Wiki directory not found: $wiki_path"
        return 1
    fi
    
    echo "Starting automatic wiki update..."
    
    # Sync README.md to Home.md
    if [[ -f "$repo_path/README.md" ]]; then
        echo "Syncing README.md to Home.md"
        sync_readme_to_wiki "$repo_path/README.md" "$wiki_path/Home.md"
    fi
    
    # Sync API documentation
    if [[ -f "$repo_path/docs/api.md" ]] || [[ -d "$repo_path/docs/api" ]]; then
        echo "Syncing API documentation"
        generate_api_docs "$repo_path" "$wiki_path"
    fi
    
    # Update changelog
    echo "Updating changelog"
    update_changelog "$repo_path" "$wiki_path"
    
    # Commit and push wiki
    cd "$wiki_path"
    if git diff --quiet; then
        echo "No changes found."
    else
        git add .
        git commit -m "Auto-update wiki from $(date '+%Y-%m-%d %H:%M')"
        git push origin master 2>/dev/null || git push origin main
        echo "OK: Wiki updated."
    fi
}

# Sync README to wiki
function sync_readme_to_wiki() {
    local readme_file="$1"
    local wiki_file="$2"
    
    # Convert README content to wiki format
    {
        echo "# $(basename "$(dirname "$readme_file")" | tr '[:lower:]' '[:upper:]') Project"
        echo
        cat "$readme_file" | sed 's/^#/##/g'  # Adjust header levels
        echo
        echo "---"
        echo "*This page is automatically synced from README.md.*"
        echo "*Last updated: $(date)*"
    } > "$wiki_file"
}
EOF

chmod +x ~/scripts/github-cli/wiki/wiki-core.sh
```

### 3. Automatic API Documentation Generation

```bash
# API documentation auto-generation system
cat > ~/scripts/github-cli/wiki/api-generator.sh << 'EOF'
#!/bin/bash

# Automatic API documentation generation
function generate_api_docs() {
    local repo_path="$1"
    local wiki_path="$2"
    
    echo "Generating API documentation..."
    
    # Detect OpenAPI/Swagger file
    local openapi_file=""
    for file in "$repo_path"/{swagger.yaml,openapi.yaml,docs/swagger.yaml,docs/openapi.yaml,api.yaml}; do
        if [[ -f "$file" ]]; then
            openapi_file="$file"
            break
        fi
    done
    
    if [[ -n "$openapi_file" ]]; then
        echo "OpenAPI spec found: $openapi_file"
        generate_from_openapi "$openapi_file" "$wiki_path/API-Documentation.md"
    else
        # Extract API endpoints from code
        echo "Extracting API endpoints from code..."
        extract_api_from_code "$repo_path" "$wiki_path/API-Documentation.md"
    fi
}

# Generate Markdown from OpenAPI
function generate_from_openapi() {
    local openapi_file="$1"
    local output_file="$2"
    
    # Parse OpenAPI using Python (simplified version)
    python3 -c "
import yaml
import json
import sys
from datetime import datetime

def parse_openapi(file_path):
    with open(file_path, 'r') as f:
        if file_path.endswith('.yaml') or file_path.endswith('.yml'):
            spec = yaml.safe_load(f)
        else:
            spec = json.load(f)
    
    # Generate Markdown
    md = []
    md.append('# API Documentation')
    md.append('')
    md.append(f'**Generated**: {datetime.now().strftime(\"%Y-%m-%d %H:%M\")}')
    md.append('')
    
    # Basic info
    info = spec.get('info', {})
    md.append(f'**Version**: {info.get(\"version\", \"N/A\")}')
    md.append(f'**Description**: {info.get(\"description\", \"API Documentation\")}')
    md.append('')
    
    # Server info
    servers = spec.get('servers', [])
    if servers:
        md.append('## Servers')
        for server in servers:
            md.append(f'- **{server.get(\"description\", \"Default server\")}**: \`{server.get(\"url\")}\`')
        md.append('')
    
    # Endpoints
    paths = spec.get('paths', {})
    if paths:
        md.append('## Endpoints')
        for path, methods in paths.items():
            md.append(f'### {path}')
            for method, details in methods.items():
                if isinstance(details, dict):
                    summary = details.get('summary', method.upper())
                    md.append(f'#### {method.upper()} - {summary}')
                    if 'description' in details:
                        md.append(f'{details[\"description\"]}')
                    md.append('')
    
    return '\\n'.join(md)

try:
    content = parse_openapi('$openapi_file')
    with open('$output_file', 'w') as f:
        f.write(content)
    print('OK: OpenAPI documentation generated.')
except Exception as e:
    print(f'FAIL: OpenAPI parse error: {e}')
" 2>/dev/null || {
        echo "Python OpenAPI parser unavailable. Using default template."
        create_api_documentation_template > "$output_file"
    }
}

# Extract API from code
function extract_api_from_code() {
    local repo_path="$1" 
    local output_file="$2"
    
    {
        echo "# API Documentation"
        echo
        echo "**Auto-generated**: $(date '+%Y-%m-%d %H:%M')"
        echo
        
        # Extract Express.js routes
        if find "$repo_path" -name "*.js" -o -name "*.ts" | head -1 >/dev/null; then
            echo "## Extracted Endpoints"
            echo
            
            # Find GET, POST, PUT, DELETE patterns
            find "$repo_path" -name "*.js" -o -name "*.ts" | xargs grep -h -E "(app\.|router\.|route\.)(get|post|put|delete|patch)" | \
                sed 's/.*\.\(get\|post\|put\|delete\|patch\)\s*(\s*['\''\"]\([^'\''\"]*\)['\''\"]/### \U\1\E \2/' | \
                sort -u | head -20
            echo
        fi
        
        # Extract FastAPI routes
        if find "$repo_path" -name "*.py" | head -1 >/dev/null; then
            echo "## Python API Endpoints"
            echo
            
            find "$repo_path" -name "*.py" | xargs grep -h -E "@app\.(get|post|put|delete|patch)" | \
                sed 's/.*@app\.\([^(]*\)(\s*['\''\"]\([^'\''\"]*\)['\''\"]/### \U\1\E \2/' | \
                sort -u | head -20
            echo
        fi
        
        echo "---"
        echo "*This document was auto-extracted from code.*"
        
    } > "$output_file"
}

# API documentation quality validation
function validate_api_docs() {
    local wiki_path="$1"
    local api_file="$wiki_path/API-Documentation.md"
    
    if [[ ! -f "$api_file" ]]; then
        echo "FAIL: API documentation not found: $api_file"
        return 1
    fi
    
    echo "Validating API documentation quality..."
    
    local issues=0
    
    # Check required sections
    local required_sections=("# API Documentation" "## Endpoints")
    for section in "${required_sections[@]}"; do
        if ! grep -q "$section" "$api_file"; then
            echo "WARNING: Required section missing: $section"
            issues=$((issues + 1))
        fi
    done
    
    # Check for external links
    if grep -q "http" "$api_file"; then
        echo "External links found - validation recommended"
    fi
    
    # Validate code blocks
    local code_blocks=$(grep -c '```' "$api_file")
    if [[ $((code_blocks % 2)) -ne 0 ]]; then
        echo "WARNING: Code block is not properly closed."
        issues=$((issues + 1))
    fi
    
    if [[ $issues -eq 0 ]]; then
        echo "OK: API documentation quality check passed"
    else
        echo "WARNING: $issues issue(s) found."
    fi
    
    return $issues
}
EOF

chmod +x ~/scripts/github-cli/wiki/api-generator.sh
```

### 4. Multilingual Wiki Management

```bash
# Multilingual wiki management system
cat > ~/scripts/github-cli/wiki/multilingual.sh << 'EOF'
#!/bin/bash

# Generate multilingual wiki
function wiki_translate() {
    local source_file="$1"
    local target_lang="$2"
    local wiki_path="${3:-.}"
    
    if [[ -z "$source_file" || -z "$target_lang" ]]; then
        echo "Usage: wiki_translate <source file> <target language> [wiki path]"
        echo "Supported languages: $SUPPORTED_LANGUAGES"
        return 1
    fi
    
    if [[ ! -f "$wiki_path/$source_file" ]]; then
        echo "FAIL: Source file not found: $wiki_path/$source_file"
        return 1
    fi
    
    local base_name=$(basename "$source_file" .md)
    local target_file="$base_name-${target_lang^^}.md"
    
    echo "Translating $source_file to $target_file..."
    
    # Generate translation template (actual translation via manual or external service)
    {
        echo "# $(get_page_title "$wiki_path/$source_file") ($target_lang)"
        echo
        echo "> **Translation status**: In progress"
        echo "> **Created**: $(date '+%Y-%m-%d')"
        echo "> **Original**: [$base_name]($base_name)"
        echo
        echo "---"
        echo
        
        # Include original content as comment (translation reference)
        echo "<!-- Original content (translation reference):"
        cat "$wiki_path/$source_file"
        echo "-->"
        echo
        echo "## Content Awaiting Translation"
        echo
        echo "This page has not been translated yet."
        echo "To contribute a translation, [create an issue](../../issues/new)."
        echo
        echo "---"
        echo "*This page was automatically generated.*"
        
    } > "$wiki_path/$target_file"
    
    echo "OK: Translation template created: $target_file"
}

# Generate multilingual navigation
function create_multilingual_nav() {
    local wiki_path="${1:-.}"
    local page_name="$2"
    
    local languages=(en ko ja zh)
    local language_names=("English" "Korean" "Japanese" "Chinese")
    
    echo "## Multilingual Support"
    echo
    
    for i in "${!languages[@]}"; do
        local lang="${languages[$i]}"
        local lang_name="${language_names[$i]}"
        
        if [[ "$lang" == "en" ]]; then
            local file_suffix=""
        else
            local file_suffix="-${lang^^}"
        fi
        
        local target_file="$page_name$file_suffix"
        
        if [[ -f "$wiki_path/$target_file.md" ]]; then
            echo "- OK [$lang_name]($target_file)"
        else
            echo "- Pending: $lang_name (translation planned)"
        fi
    done
    echo
}

# Extract page title
function get_page_title() {
    local file="$1"
    local title=$(head -1 "$file" | sed 's/^# //')
    echo "${title:-Untitled}"
}

# Translation status tracking
function translation_status() {
    local wiki_path="${1:-.}"
    
    echo "Translation Status Report"
    echo "========================="
    echo
    
    local base_files=($(find "$wiki_path" -name "*.md" ! -name "*-EN.md" ! -name "*-JA.md" ! -name "*-ZH.md" ! -name "*-KO.md" -exec basename {} .md \;))
    
    for base_file in "${base_files[@]}"; do
        echo "$base_file:"
        
        for lang in KO JA ZH; do
            local trans_file="$base_file-$lang.md"
            if [[ -f "$wiki_path/$trans_file" ]]; then
                local lines=$(wc -l < "$wiki_path/$trans_file")
                if [[ $lines -gt 20 ]]; then
                    echo "  OK: $lang (complete, ${lines} lines)"
                else
                    echo "  PENDING: $lang (in progress, ${lines} lines)"
                fi
            else
                echo "  MISSING: $lang (not translated)"
            fi
        done
        echo
    done
}
EOF

chmod +x ~/scripts/github-cli/wiki/multilingual.sh
```

### 5. zshrc Integration

```bash
# Integrate wiki system into zshrc
cat >> ~/.zshrc << 'EOF'

# ===============================================
# GitHub Wiki Automation System
# ===============================================

# Load wiki scripts
if [[ -d "$HOME/scripts/github-cli/wiki" ]]; then
    # Load config
    source "$HOME/scripts/github-cli/config/wiki-config.sh"
    
    # Load core functions
    source "$HOME/scripts/github-cli/wiki/wiki-core.sh"
    source "$HOME/scripts/github-cli/wiki/api-generator.sh"
    source "$HOME/scripts/github-cli/wiki/multilingual.sh"
    
    echo "GitHub Wiki Automation System loaded."
fi

# Wiki-related aliases
alias wiki-init="wiki_init"
alias wiki-update="wiki_auto_update"
alias wiki-translate="wiki_translate"
alias wiki-status="translation_status"
alias api-docs="generate_api_docs"

# Integrated wiki management function
function wiki() {
    local command="$1"
    shift
    
    case "$command" in
        "init") wiki_init "$@" ;;
        "update") wiki_auto_update "$@" ;;
        "translate") wiki_translate "$@" ;;
        "status") translation_status "$@" ;;
        "api") generate_api_docs "$@" ;;
        "validate") validate_api_docs "$@" ;;
        *)
            echo "GitHub Wiki Automation System"
            echo "Usage: wiki <command> [options]"
            echo
            echo "Commands:"
            echo "  init <url>           - Initialize wiki"
            echo "  update [repo]        - Auto-update wiki"
            echo "  translate <file> <lang> - Create translation template"
            echo "  status               - Check translation status"
            echo "  api <repo> <wiki>    - Generate API documentation"
            echo "  validate <wiki>      - Validate documentation quality"
            ;;
    esac
}
EOF

source ~/.zshrc
```

## Practical Usage Scenarios

### Scenario 1: Initial Wiki Setup for New Project

```bash
# 1. Initialize wiki
wiki init https://github.com/yourusername/your-project.git

# 2. Generate API documentation
wiki api /path/to/project ~/Documents/wikis/your-project

# 3. Start multilingual support
wiki translate Home.md KO ~/Documents/wikis/your-project
wiki translate Home.md JA ~/Documents/wikis/your-project

# 4. Check translation status
wiki status ~/Documents/wikis/your-project
```

### Scenario 2: CI/CD Integration

```yaml
# .github/workflows/wiki-update.yml
name: Auto-update Wiki

on:
  push:
    branches: [main]
    paths:
      - 'docs/**'
      - 'README.md'
      - '*.yaml'
      - '*.yml'

jobs:
  update-wiki:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup GitHub CLI
        run: gh auth setup-git
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Clone Wiki
        run: |
          git clone ${{ github.server_url }}/${{ github.repository }}.wiki.git wiki
      
      - name: Update Wiki
        run: |
          # Run wiki auto-update scripts
          bash scripts/wiki-update.sh
        env:
          WIKI_PATH: ./wiki
          REPO_PATH: .
      
      - name: Push Wiki Changes
        run: |
          cd wiki
          git config user.email "github-actions@github.com"
          git config user.name "GitHub Actions"
          git add .
          git diff --staged --quiet || git commit -m "Auto-update wiki from ${{ github.sha }}"
          git push
```

### Scenario 3: Large-Scale Documentation Management

```bash
# Sync documentation for multiple projects
function bulk_wiki_update() {
    local projects_dir="${1:-$HOME/projects}"
    
    echo "Starting bulk wiki update..."
    echo
    
    find "$projects_dir" -name ".git" -type d -maxdepth 3 | while read git_dir; do
        local project_dir=$(dirname "$git_dir")
        local project_name=$(basename "$project_dir")
        
        echo "Processing: $project_name"
        
        # Auto-update wiki
        wiki update "$project_dir" "$WIKI_BASE_DIR/$project_name" 2>/dev/null && \
            echo "  OK: $project_name wiki updated" || \
            echo "  SKIP: $project_name (no wiki)"
    done
    
    echo
    echo "Bulk wiki update complete."
}
```

## Documentation Quality Management

### Automatic Quality Checks

```bash
# Documentation quality gate
function wiki_quality_gate() {
    local wiki_path="${1:-.}"
    local min_quality_score="${2:-70}"
    
    echo "Running documentation quality check..."
    echo
    
    local total_score=0
    local check_count=0
    
    # 1. Check for required pages
    local required_pages=("Home.md" "API-Documentation.md" "README.md")
    for page in "${required_pages[@]}"; do
        if [[ -f "$wiki_path/$page" ]]; then
            echo "OK: $page exists"
            total_score=$((total_score + 10))
        else
            echo "MISSING: $page"
        fi
        check_count=$((check_count + 1))
    done
    
    # 2. Check recent update
    local last_commit_days=$(( ($(date +%s) - $(git -C "$wiki_path" log -1 --format=%ct)) / 86400 ))
    if [[ $last_commit_days -lt 7 ]]; then
        echo "OK: Recently updated ($last_commit_days days ago)"
        total_score=$((total_score + 20))
    else
        echo "WARNING: Last update was $last_commit_days days ago"
    fi
    
    # 3. Check multilingual support
    local home_translations=$(find "$wiki_path" -name "Home-*.md" | wc -l)
    if [[ $home_translations -gt 0 ]]; then
        echo "OK: $home_translations languages supported"
        total_score=$((total_score + $((home_translations * 5))))
    else
        echo "INFO: No multilingual support yet"
    fi
    
    # 4. Check code examples
    local code_blocks=$(grep -r '```' "$wiki_path" --include="*.md" | wc -l)
    if [[ $code_blocks -gt 10 ]]; then
        echo "OK: $code_blocks code examples"
        total_score=$((total_score + 15))
    fi
    
    echo
    echo "Quality Score: $total_score"
    
    if [[ $total_score -ge $min_quality_score ]]; then
        echo "PASS: Documentation quality meets the standard"
        return 0
    else
        echo "FAIL: Documentation quality is below the standard (minimum: $min_quality_score)"
        return 1
    fi
}
```

## Preview of the Next Part

The final installment, **[Advanced Workflows and Real-World Application](github-cli-advanced-workflows)**, covers:

- Full system integration
- CI/CD pipeline connectivity
- Team onboarding automation
- Performance optimization and monitoring
- Complete production-ready system

---

## Other Posts in This Series

- [Part 1: Installation and Environment Setup](macos-github-cli-complete-guide)
- [Part 2: Complete Issue Management Automation](macos-github-cli-issue-automation-guide)
- [Part 3: Project Management + Work/Personal Project Separation](github-cli-project-management-automation)
- **Part 4: Complete Wiki Management Automation** (this post)
- [Part 5: Advanced Workflows and Real-World Application](github-cli-advanced-workflows)
