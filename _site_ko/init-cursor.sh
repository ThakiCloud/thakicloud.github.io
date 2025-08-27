#!/usr/bin/env bash
# init_cursor_rules.sh — create Cursor .mdc rule scaffolds
# Generates .cursor/rules/*.mdc from a canonical list, deduplicating automatically.

set -euo pipefail

#######################################################################
# 1. 원본 항목 정의 -- 필요 시 여기에만 추가하세요
#######################################################################
declare -a RAW_ITEMS=(
  "PRD"
  "app-flow-doc"
  "tech-stack-doc"
  "frontend-guidelines"
  "backend-structure"
  "security-checklist"
  "user-flow"
  "styling"
  "project-structure"
  "schema design"
  "api-spec"
  "design" 
  "requirements" 
  "architecture"
  "roadmap"
  "context"
)

#######################################################################
# 2. 정규화(소문자·공백→하이픈) + Dedup
#######################################################################
for i in "${!RAW_ITEMS[@]}"; do
  RAW_ITEMS[$i]=$(echo "${RAW_ITEMS[$i]}" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
done

declare -A seen=()
UNIQUE_ITEMS=()
for item in "${RAW_ITEMS[@]}"; do
  if [[ -z "${seen[$item]:-}" ]]; then
    UNIQUE_ITEMS+=("$item")
    seen["$item"]=1
  fi
done

#######################################################################
# 3. .mdc 파일 생성
#######################################################################
printf "\n📁  Creating .cursor/rules structure...\n"
mkdir -p .cursor/rules

# slug → Title Case 변환: api-spec → Api Spec
to_title() {
  echo "$1" | tr '-' ' ' | awk '{for(i=1;i<=NF;i++){ $i=toupper(substr($i,1,1)) substr($i,2)}; print}'
}

for slug in "${UNIQUE_ITEMS[@]}"; do
  file=".cursor/rules/${slug}.mdc"
  if [[ -f "$file" ]]; then
    echo "⚠️  $file already exists — skipping"
    continue
  fi

  title="$(to_title "$slug")"

  if [[ "$slug" == "prd" ]]; then
    cat > "$file" <<EOF
---
title: "PRD"
description: "Product Requirements Document – single source of truth for the project."
alwaysApply: false
---

## 프로젝트 개요 (Project Overview)

<!-- 프로젝트의 비전, 문제 정의, 목표를 서술하세요. -->

## 기술 스택 (Tech Stack)

| Layer | Tech/Tool | Rationale |
|-------|-----------|-----------|
| Frontend | | |
| Backend  | | |
| Database | | |
| Infrastructure | | |

## 유저 플로우 (User Flow)

```mermaid
flowchart TD
    User["사용자"] -->|Action| System["서비스"]
```

## 핵심 기능 (Core Features)

1. Feature 1  
   - KPI:  
   - Priority:

## UI 상세 (UI Details)

<!-- 주요 화면, 컴포넌트, 인터랙션을 설명하거나 링크하세요. -->

## 백엔드 스키마 (Backend Schema)

```sql
-- 예: CREATE TABLE users (...)
```

## 보안 가이드라인 (Security Guidelines)

- 인증/인가  
- 데이터 암호화  
- 로깅 및 모니터링

## 규제 준수 (Regulations)

- GDPR  
- 기타 산업 표준

EOF
  else
    cat > "$file" <<EOF
---
title: "${title}"
description: "TODO: add description for ${title}"
alwaysApply: false
---

<!-- Write your ${title} content here -->
EOF
  fi
  echo "✅  Created $file"
done

printf "\n🎉  Done. Customise each .mdc file as needed.\n"
