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
  "user flow"
  "styling"
  "project structure"
  "schema design"
  "api-spec"
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

  cat > "$file" <<EOF
---
title: "${title}"
description: "TODO: add description for ${title}"
alwaysApply: false
---

<!-- Write your ${title} content here -->
EOF
  echo "✅  Created $file"
done

printf "\n🎉  Done. Customise each .mdc file as needed.\n"
