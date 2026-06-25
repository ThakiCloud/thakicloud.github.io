---
title: "macOS GitHub CLI 완전 자동화 시리즈 - 4편: 위키 관리 완전 자동화"
excerpt: "코드 기반 위키 자동 생성, API 문서 동기화, 다국어 문서 관리까지 - 개발 문서화의 모든 것을 자동화"
seo_title: "GitHub CLI 위키 자동화 4편 - 문서 관리 완전 자동화 - Thaki Cloud"
seo_description: "GitHub CLI로 위키 자동 생성, API 문서 동기화, 다국어 지원, 버전 관리까지 개발 문서화를 완전 자동화하는 전문가 가이드"
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
author_profile: true
toc: true
canonical_url: "https://thakicloud.github.io/ko/dev/github-cli-wiki-automation-guide/"
published: false
---

⏱️ **예상 읽기 시간**: 22분

## 시리즈 소개

**macOS GitHub CLI 완전 자동화 시리즈** 4편에서는 개발 문서화의 핵심인 위키 관리를 완전 자동화합니다. 코드 변경사항을 자동으로 위키에 반영하고, API 문서를 동기화하며, 다국어 지원까지 구현하는 전문가급 시스템을 구축해보겠습니다.

## 모듈형 스크립트 시스템 구축

### 1. 스크립트 디렉토리 구조 생성

```bash
# 체계적인 스크립트 구조 생성
mkdir -p ~/scripts/github-cli/{wiki,core,utils,config}

# 설정 파일 생성
cat > ~/scripts/github-cli/config/wiki-config.sh << 'EOF'
#!/bin/bash

# 위키 자동화 설정
export WIKI_CONFIG_VERSION="1.0"
export WIKI_BASE_DIR="$HOME/Documents/wikis"
export WIKI_TEMPLATES_DIR="$HOME/scripts/github-cli/wiki/templates"
export WIKI_CACHE_DIR="$HOME/.cache/github-wikis"
export WIKI_BACKUP_DIR="$HOME/Documents/wiki-backups"

# 다국어 설정
export SUPPORTED_LANGUAGES="ko,en,ja,zh"
export DEFAULT_LANGUAGE="ko"

# API 문서 설정
export API_DOCS_FORMAT="markdown"
export API_DOCS_AUTO_UPDATE="true"

# 품질 검증 설정
export SPELL_CHECK_ENABLED="true"
export LINK_CHECK_ENABLED="true"
export TOC_AUTO_GENERATE="true"

echo "📚 위키 설정이 로드되었습니다."
EOF

chmod +x ~/scripts/github-cli/config/wiki-config.sh
```

### 2. 핵심 위키 함수들

```bash
# 위키 핵심 함수들
cat > ~/scripts/github-cli/wiki/wiki-core.sh << 'EOF'
#!/bin/bash

# 위키 저장소 관리
function wiki_init() {
    local repo_url="$1"
    local wiki_name="${2:-$(basename "$repo_url" .git)}"
    
    if [[ -z "$repo_url" ]]; then
        echo "사용법: wiki_init <리포지토리URL> [위키명]"
        return 1
    fi
    
    # 위키 디렉토리 생성
    local wiki_dir="$WIKI_BASE_DIR/$wiki_name"
    mkdir -p "$wiki_dir"
    cd "$wiki_dir"
    
    # 위키 저장소 클론/초기화
    if [[ "$repo_url" == *".wiki.git" ]]; then
        git clone "$repo_url" .
    else
        # 메인 저장소에서 위키 URL 추출
        local wiki_url="${repo_url%.git}.wiki.git"
        git clone "$wiki_url" . 2>/dev/null || {
            # 위키가 없으면 생성
            echo "🚀 위키를 새로 생성합니다..."
            git init .
            create_wiki_structure
        }
    fi
    
    echo "✅ 위키 '$wiki_name'이 초기화되었습니다: $wiki_dir"
}

# 위키 구조 생성
function create_wiki_structure() {
    # 홈 페이지
    cat > Home.md << 'HOMEEOF'
# 프로젝트 위키

환영합니다! 이 위키는 자동으로 생성되고 관리됩니다.

## 📚 문서 구조

- [API 문서](API-Documentation)
- [설치 가이드](Installation-Guide)
- [개발 가이드](Development-Guide)
- [FAQ](FAQ)
- [변경 로그](Changelog)

## 🌍 다국어 지원

- [한국어](Home) (현재 페이지)
- [English](Home-EN)
- [日本語](Home-JA)
- [中文](Home-ZH)

---
*이 문서는 자동으로 생성되었습니다. 마지막 업데이트: $(date)*
HOMEEOF

    # 기본 페이지들 생성
    create_api_documentation_template
    create_installation_guide_template
    create_development_guide_template
    create_faq_template
    
    # 초기 커밋
    git add .
    git commit -m "📚 Initial wiki structure created automatically"
    
    echo "📚 기본 위키 구조가 생성되었습니다."
}

# API 문서 템플릿
function create_api_documentation_template() {
    cat > API-Documentation.md << 'APIEOF'
# API 문서

이 페이지는 자동으로 생성되고 업데이트됩니다.

## 인증

```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
     https://api.example.com/v1/endpoint
```

## 엔드포인트

### 기본 정보
- **Base URL**: `https://api.example.com/v1`
- **API 버전**: v1
- **응답 형식**: JSON

---
*API 문서는 코드에서 자동 생성됩니다.*
APIEOF
}

# 자동 위키 업데이트
function wiki_auto_update() {
    local repo_path="${1:-.}"
    local wiki_path="$2"
    
    if [[ -z "$wiki_path" ]]; then
        # 현재 리포지토리의 위키 경로 자동 감지
        local repo_name=$(basename "$(git -C "$repo_path" remote get-url origin)" .git)
        wiki_path="$WIKI_BASE_DIR/$repo_name"
    fi
    
    if [[ ! -d "$wiki_path" ]]; then
        echo "❌ 위키 디렉토리를 찾을 수 없습니다: $wiki_path"
        return 1
    fi
    
    echo "🔄 위키 자동 업데이트 시작..."
    
    # README.md에서 Home.md 동기화
    if [[ -f "$repo_path/README.md" ]]; then
        echo "📄 README.md → Home.md 동기화"
        sync_readme_to_wiki "$repo_path/README.md" "$wiki_path/Home.md"
    fi
    
    # API 문서 동기화
    if [[ -f "$repo_path/docs/api.md" ]] || [[ -d "$repo_path/docs/api" ]]; then
        echo "📡 API 문서 동기화"
        generate_api_docs "$repo_path" "$wiki_path"
    fi
    
    # 변경 로그 업데이트
    echo "📝 변경 로그 업데이트"
    update_changelog "$repo_path" "$wiki_path"
    
    # 위키 커밋 및 푸시
    cd "$wiki_path"
    if git diff --quiet; then
        echo "📄 변경사항이 없습니다."
    else
        git add .
        git commit -m "📚 Auto-update wiki from $(date '+%Y-%m-%d %H:%M')"
        git push origin master 2>/dev/null || git push origin main
        echo "✅ 위키가 업데이트되었습니다."
    fi
}

# README와 위키 동기화
function sync_readme_to_wiki() {
    local readme_file="$1"
    local wiki_file="$2"
    
    # README 내용을 위키 형식으로 변환
    {
        echo "# $(basename "$(dirname "$readme_file")" | tr '[:lower:]' '[:upper:]') 프로젝트"
        echo
        cat "$readme_file" | sed 's/^#/##/g'  # 헤더 레벨 조정
        echo
        echo "---"
        echo "*이 페이지는 README.md에서 자동 동기화됩니다.*"
        echo "*마지막 업데이트: $(date)*"
    } > "$wiki_file"
}
EOF

chmod +x ~/scripts/github-cli/wiki/wiki-core.sh
```

### 3. API 문서 자동 생성

```bash
# API 문서 자동 생성 시스템
cat > ~/scripts/github-cli/wiki/api-generator.sh << 'EOF'
#!/bin/bash

# API 문서 자동 생성
function generate_api_docs() {
    local repo_path="$1"
    local wiki_path="$2"
    
    echo "🔧 API 문서 자동 생성 중..."
    
    # OpenAPI/Swagger 파일 감지
    local openapi_file=""
    for file in "$repo_path"/{swagger.yaml,openapi.yaml,docs/swagger.yaml,docs/openapi.yaml,api.yaml}; do
        if [[ -f "$file" ]]; then
            openapi_file="$file"
            break
        fi
    done
    
    if [[ -n "$openapi_file" ]]; then
        echo "📋 OpenAPI 스펙 발견: $openapi_file"
        generate_from_openapi "$openapi_file" "$wiki_path/API-Documentation.md"
    else
        # 코드에서 API 엔드포인트 추출
        echo "🔍 코드에서 API 엔드포인트 추출 중..."
        extract_api_from_code "$repo_path" "$wiki_path/API-Documentation.md"
    fi
}

# OpenAPI에서 마크다운 생성
function generate_from_openapi() {
    local openapi_file="$1"
    local output_file="$2"
    
    # Python을 사용한 OpenAPI 파싱 (간단한 버전)
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
    
    # 마크다운 생성
    md = []
    md.append('# API 문서')
    md.append('')
    md.append(f'**생성일**: {datetime.now().strftime(\"%Y-%m-%d %H:%M\")}')
    md.append('')
    
    # 기본 정보
    info = spec.get('info', {})
    md.append(f'**버전**: {info.get(\"version\", \"N/A\")}')
    md.append(f'**설명**: {info.get(\"description\", \"API 문서\")}')
    md.append('')
    
    # 서버 정보
    servers = spec.get('servers', [])
    if servers:
        md.append('## 서버')
        for server in servers:
            md.append(f'- **{server.get(\"description\", \"기본 서버\")}**: \`{server.get(\"url\")}\`')
        md.append('')
    
    # 엔드포인트
    paths = spec.get('paths', {})
    if paths:
        md.append('## 엔드포인트')
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
    print('✅ OpenAPI 문서가 생성되었습니다.')
except Exception as e:
    print(f'❌ OpenAPI 파싱 오류: {e}')
" 2>/dev/null || {
        echo "⚠️ Python OpenAPI 파서를 사용할 수 없습니다. 기본 템플릿을 사용합니다."
        create_api_documentation_template > "$output_file"
    }
}

# 코드에서 API 추출
function extract_api_from_code() {
    local repo_path="$1" 
    local output_file="$2"
    
    {
        echo "# API 문서"
        echo
        echo "**자동 생성일**: $(date '+%Y-%m-%d %H:%M')"
        echo
        
        # Express.js 라우트 추출
        if find "$repo_path" -name "*.js" -o -name "*.ts" | head -1 >/dev/null; then
            echo "## 추출된 엔드포인트"
            echo
            
            # GET, POST, PUT, DELETE 패턴 찾기
            find "$repo_path" -name "*.js" -o -name "*.ts" | xargs grep -h -E "(app\.|router\.|route\.)(get|post|put|delete|patch)" | \
                sed 's/.*\.\(get\|post\|put\|delete\|patch\)\s*(\s*['\''\"]\([^'\''\"]*\)['\''\"]/### \U\1\E \2/' | \
                sort -u | head -20
            echo
        fi
        
        # FastAPI 라우트 추출
        if find "$repo_path" -name "*.py" | head -1 >/dev/null; then
            echo "## Python API 엔드포인트"
            echo
            
            find "$repo_path" -name "*.py" | xargs grep -h -E "@app\.(get|post|put|delete|patch)" | \
                sed 's/.*@app\.\([^(]*\)(\s*['\''\"]\([^'\''\"]*\)['\''\"]/### \U\1\E \2/' | \
                sort -u | head -20
            echo
        fi
        
        echo "---"
        echo "*이 문서는 코드에서 자동 추출되었습니다.*"
        
    } > "$output_file"
}

# API 문서 품질 검증
function validate_api_docs() {
    local wiki_path="$1"
    local api_file="$wiki_path/API-Documentation.md"
    
    if [[ ! -f "$api_file" ]]; then
        echo "❌ API 문서를 찾을 수 없습니다: $api_file"
        return 1
    fi
    
    echo "🔍 API 문서 품질 검증 중..."
    
    local issues=0
    
    # 기본 섹션 확인
    local required_sections=("# API 문서" "## 엔드포인트")
    for section in "${required_sections[@]}"; do
        if ! grep -q "$section" "$api_file"; then
            echo "⚠️ 필수 섹션 누락: $section"
            issues=$((issues + 1))
        fi
    done
    
    # 링크 검증
    if grep -q "http" "$api_file"; then
        echo "🔗 외부 링크 발견, 유효성 검사 권장"
    fi
    
    # 코드 블록 검증
    local code_blocks=$(grep -c '```' "$api_file")
    if [[ $((code_blocks % 2)) -ne 0 ]]; then
        echo "⚠️ 코드 블록이 제대로 닫히지 않았습니다."
        issues=$((issues + 1))
    fi
    
    if [[ $issues -eq 0 ]]; then
        echo "✅ API 문서 품질 검증 통과"
    else
        echo "⚠️ $issues개의 문제가 발견되었습니다."
    fi
    
    return $issues
}
EOF

chmod +x ~/scripts/github-cli/wiki/api-generator.sh
```

### 4. 다국어 위키 관리

```bash
# 다국어 위키 관리 시스템
cat > ~/scripts/github-cli/wiki/multilingual.sh << 'EOF'
#!/bin/bash

# 다국어 위키 생성
function wiki_translate() {
    local source_file="$1"
    local target_lang="$2"
    local wiki_path="${3:-.}"
    
    if [[ -z "$source_file" || -z "$target_lang" ]]; then
        echo "사용법: wiki_translate <소스파일> <대상언어> [위키경로]"
        echo "지원 언어: $SUPPORTED_LANGUAGES"
        return 1
    fi
    
    if [[ ! -f "$wiki_path/$source_file" ]]; then
        echo "❌ 소스 파일을 찾을 수 없습니다: $wiki_path/$source_file"
        return 1
    fi
    
    local base_name=$(basename "$source_file" .md)
    local target_file="$base_name-${target_lang^^}.md"
    
    echo "🌍 $source_file → $target_file 번역 중..."
    
    # 번역 템플릿 생성 (실제 번역은 수동 또는 외부 서비스 사용)
    {
        echo "# $(get_page_title "$wiki_path/$source_file") ($target_lang)"
        echo
        echo "> 🌍 **번역 상태**: 진행 중"
        echo "> 📅 **생성일**: $(date '+%Y-%m-%d')"
        echo "> 📄 **원본**: [$base_name]($base_name)"
        echo
        echo "---"
        echo
        
        # 원본 내용을 주석으로 포함 (번역 참조용)
        echo "<!-- 원본 내용 (번역 참조용):"
        cat "$wiki_path/$source_file"
        echo "-->"
        echo
        echo "## 번역이 필요한 내용"
        echo
        echo "이 페이지는 아직 번역되지 않았습니다."
        echo "번역에 기여하고 싶으시면 [이슈를 생성](../../issues/new)해주세요."
        echo
        echo "---"
        echo "*이 페이지는 자동으로 생성되었습니다.*"
        
    } > "$wiki_path/$target_file"
    
    echo "✅ 번역 템플릿이 생성되었습니다: $target_file"
}

# 다국어 네비게이션 생성
function create_multilingual_nav() {
    local wiki_path="${1:-.}"
    local page_name="$2"
    
    local languages=(ko en ja zh)
    local language_names=("한국어" "English" "日本語" "中文")
    
    echo "## 🌍 다국어 지원"
    echo
    
    for i in "${!languages[@]}"; do
        local lang="${languages[$i]}"
        local lang_name="${language_names[$i]}"
        
        if [[ "$lang" == "ko" ]]; then
            local file_suffix=""
        else
            local file_suffix="-${lang^^}"
        fi
        
        local target_file="$page_name$file_suffix"
        
        if [[ -f "$wiki_path/$target_file.md" ]]; then
            echo "- ✅ [$lang_name]($target_file)"
        else
            echo "- ⏳ $lang_name (번역 예정)"
        fi
    done
    echo
}

# 페이지 제목 추출
function get_page_title() {
    local file="$1"
    local title=$(head -1 "$file" | sed 's/^# //')
    echo "${title:-Untitled}"
}

# 번역 상태 추적
function translation_status() {
    local wiki_path="${1:-.}"
    
    echo "🌍 번역 상태 리포트"
    echo "==================="
    echo
    
    local base_files=($(find "$wiki_path" -name "*.md" ! -name "*-EN.md" ! -name "*-JA.md" ! -name "*-ZH.md" -exec basename {} .md \;))
    
    for base_file in "${base_files[@]}"; do
        echo "📄 $base_file:"
        
        for lang in EN JA ZH; do
            local trans_file="$base_file-$lang.md"
            if [[ -f "$wiki_path/$trans_file" ]]; then
                local lines=$(wc -l < "$wiki_path/$trans_file")
                if [[ $lines -gt 20 ]]; then
                    echo "  ✅ $lang (완료, ${lines}줄)"
                else
                    echo "  ⏳ $lang (진행 중, ${lines}줄)"
                fi
            else
                echo "  ❌ $lang (미번역)"
            fi
        done
        echo
    done
}
EOF

chmod +x ~/scripts/github-cli/wiki/multilingual.sh
```

### 5. zshrc 통합 설정

```bash
# zshrc에 위키 시스템 통합
cat >> ~/.zshrc << 'EOF'

# ===============================================
# GitHub 위키 자동화 시스템
# ===============================================

# 위키 스크립트 로딩
if [[ -d "$HOME/scripts/github-cli/wiki" ]]; then
    # 설정 로드
    source "$HOME/scripts/github-cli/config/wiki-config.sh"
    
    # 핵심 함수들 로드
    source "$HOME/scripts/github-cli/wiki/wiki-core.sh"
    source "$HOME/scripts/github-cli/wiki/api-generator.sh"
    source "$HOME/scripts/github-cli/wiki/multilingual.sh"
    
    echo "📚 GitHub 위키 자동화 시스템이 로드되었습니다."
fi

# 위키 관련 alias
alias wiki-init="wiki_init"
alias wiki-update="wiki_auto_update"
alias wiki-translate="wiki_translate"
alias wiki-status="translation_status"
alias api-docs="generate_api_docs"

# 통합 위키 관리 함수
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
            echo "GitHub 위키 관리 시스템"
            echo "사용법: wiki <command> [options]"
            echo
            echo "명령어:"
            echo "  init <repo-url>     - 위키 초기화"
            echo "  update [repo-path]  - 위키 자동 업데이트"
            echo "  translate <file> <lang> - 다국어 번역"
            echo "  status [wiki-path]  - 번역 상태 확인"
            echo "  api <repo-path>     - API 문서 생성"
            echo "  validate <wiki-path> - 문서 품질 검증"
            ;;
    esac
}
EOF

source ~/.zshrc
```

## 다음 편 예고

다음 편에서는 **고급 워크플로우와 실무 적용**을 다룹니다:
- 전체 시스템 통합 및 최적화
- CI/CD 파이프라인 연동
- 팀 온보딩 자동화
- 성능 모니터링 및 최적화
- 실무 적용 사례 및 트러블슈팅

---

## 이 시리즈의 다른 글 보기

- [1편: 설치와 환경 구성](macos-github-cli-complete-guide)
- [2편: 이슈 관리 완전 자동화](macos-github-cli-issue-automation-guide)
- [3편: 프로젝트 관리 + 회사/개인 프로젝트 분리](github-cli-project-management-automation)
- **4편: 위키 관리 완전 자동화** ← 현재 위치
- 5편: 고급 워크플로우와 실무 적용 (작성 예정) 