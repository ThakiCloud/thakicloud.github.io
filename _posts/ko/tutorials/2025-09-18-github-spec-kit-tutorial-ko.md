---
title: "GitHub Spec Kit 튜토리얼: 스펙·플랜·구현까지"
excerpt: "GitHub Spec Kit으로 스펙 기반 개발을 단계별로 실습: 베이스라인 스펙 작성, 명세 보완, 기술 플랜 생성, 점검, 구현 준비까지 macOS 기준 실행 흐름."
seo_title: "Spec Kit 튜토리얼 - 스펙 기반 개발 가이드 - Thaki Cloud"
seo_description: "Spec Kit으로 스펙 작성부터 플랜 수립·검증·구현 준비까지 실전 튜토리얼. macOS 스크립트, 트러블슈팅, 모범 사례 포함."
date: 2025-09-18
categories:
  - tutorials
tags:
  - spec-kit
  - spec-driven-development
  - github
  - planning
  - automation
author_profile: true
toc: true
toc_label: "목차"
lang: ko
permalink: /ko/tutorials/github-spec-kit-tutorial/
canonical_url: "https://thakicloud.github.io/ko/tutorials/github-spec-kit-tutorial/"
---

⏱️ 예상 읽기 시간: 12분

### 왜 이 튜토리얼인가
스펙 기반 개발은 제품 시나리오를 먼저 정교화한 뒤, 그 스펙으로 코드를 이끄는 접근입니다. GitHub Spec Kit은 템플릿·스크립트·체크리스트를 제공해 이 과정을 가속합니다. 이 글에서는 아이디어를 베이스라인 스펙으로 정리하고, 명세를 보완하며, 기술 플랜을 만들고 점검한 후 구현을 준비하는 전 과정을 macOS 기준으로 안내합니다.

참고: [GitHub Spec Kit 저장소](https://github.com/github/spec-kit) [인용: `http://github.com/github/spec-kit`]

---

## 1) 사전 준비
- macOS 13+ (Apple Silicon/Intel)
- Git 2.40+
- Node.js 18+ 또는 20+ (선택)
- Python 3.10+ (Spec Kit는 Python을 사용하지만, 템플릿 소비만으로는 필수 아님)
- GitHub 계정 및 SSH 설정(권장)

빠른 확인:
```bash
git --version
python3 --version
node -v  # 선택
```

---

## 2) Spec Kit 템플릿 가져오기
템플릿만 복사해도 되고, 포크/클론 후 사용해도 됩니다.
```bash
git clone https://github.com/github/spec-kit.git
cd spec-kit
ls -la templates/
ls -la docs/
```

---

## 3) 기능 작업 공간 생성
권장 구조에 맞춰 로컬 폴더를 만듭니다.
```bash
FEATURE_SLUG=taskify
mkdir -p features/${FEATURE_SLUG}
cd features/${FEATURE_SLUG}
cp ../../spec-kit/templates/spec-template.md ./spec.md
cp ../../spec-kit/templates/plan-template.md ./plan.md
cp ../../spec-kit/templates/tasks-template.md ./tasks.md
```

구조:
```bash
.
├── plan.md
├── spec.md
└── tasks.md
```

---

## 4) STEP 1 — 베이스라인 스펙 생성
`spec.md`에 제품 시나리오, 사용자 스토리, 수용 기준을 채웁니다. 간결한 PRD 느낌으로 시작하면 좋습니다.

도움 프롬프트:
```text
Taskify라는 작은 앱의 베이스라인 스펙을 작성하세요.
목표/비목표, 주요 페르소나, 사용자 여정, 수용 기준을 포함합니다.
말미에 Review & Acceptance Checklist를 추가합니다.
초기 범위는 한 번의 릴리스에 적합하도록 제한합니다.
```

좋은 스펙의 기준:
- 목표/비목표가 명확함
- 소수의 고신호 사용자 여정
- 테스트 가능한 수용 기준
- 객관적 체크가 가능한 리뷰 체크리스트

---

## 5) STEP 2 — 기능 명세 보완
`spec.md`를 읽고 애매한 부분을 구체화합니다.
- 값 범위 제약 예: 프로젝트당 5–15개의 기본 작업, 상태별 최소 1개 포함
- 에러/빈 상태 UX 명확화
- 지표 정의(지연 한도, 성공 기준)

도움 프롬프트:
```text
spec.md의 Review & Acceptance Checklist를 검토하고 충족된 항목만 체크하세요.
충족되지 않은 항목은 체크하지 말고 한 문장으로 이유를 설명하세요.
```

---

## 6) STEP 3 — 기술 플랜 생성
선택한 스택에 맞춰 `plan.md`를 구체화합니다. 예시:
```text
.NET Aspire + Postgres. 프론트엔드: Blazor Server(실시간 보드).
API: Projects, Tasks, Notifications. data-model.md, contracts, quickstart.md를 생성합니다.
```

세부 문서에 링크를 달고, 실행 순서로 배열합니다. 빠르게 변하는 스택은 research 문서로 버전을 고정합니다.

---

## 7) STEP 4 — 플랜 검증
구현 전 점검합니다.
- 핵심 작업이 순서화되어 있고 관련 스펙/계약을 참조하는가?
- 미지 영역이 연구 태스크로 정리되었는가?
- 비기능 요구가 테스트 가능하게 정의되었는가?

도움 프롬프트:
```text
plan.md와 링크된 문서를 감리해 누락을 찾고, 실행 단계별로 참조를 명시하세요.
과설계된 부분이 있다면 단순화 방안을 제시하세요.
```

---

## 8) STEP 5 — 구현 준비
- 기능 브랜치 생성 및 Draft PR 개설
- 스캐폴딩 스크립트 준비(디렉터리 생성, 계약/데이터 모델 빈 파일 추가)
- 빠른 리뷰를 위한 최소 산출물 커밋

간단 스크립트 예:
```bash
#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT=$(pwd)
mkdir -p src/api src/web docs contracts

echo "{}" > contracts/api-spec.json
cat > docs/quickstart.md <<'MD'
# Quickstart
1. 의존성 설치
2. API와 Web 실행
3. http://localhost:3000 열기
MD

echo "Scaffold complete at ${PROJECT_ROOT}"
```

---

## 9) macOS 테스트 스크립트
로컬 환경과 템플릿 존재를 확인하고 기능 공간을 준비합니다.
```bash
#!/usr/bin/env bash
# file: scripts/spec-kit-smoke-test.sh
set -euo pipefail

command -v git >/dev/null || { echo "git missing"; exit 1; }
command -v python3 >/dev/null || { echo "python3 missing"; exit 1; }

if [ ! -d "spec-kit/templates" ]; then
  echo "Spec Kit templates not found. Cloning..."
  rm -rf spec-kit
  git clone https://github.com/github/spec-kit.git
fi

FEATURE=${1:-taskify}
mkdir -p features/${FEATURE}
cp -f spec-kit/templates/spec-template.md features/${FEATURE}/spec.md
cp -f spec-kit/templates/plan-template.md features/${FEATURE}/plan.md
cp -f spec-kit/templates/tasks-template.md features/${FEATURE}/tasks.md

ls -la features/${FEATURE}
echo "OK: feature workspace ready"
```

예상 출력(요약):
```text
cloning into 'spec-kit'...
spec-template.md  plan-template.md  tasks-template.md
OK: feature workspace ready
```

---

## 10) 트러블슈팅 노트
공식 저장소 가이드에 따르면:
- 첫 시도 결과를 최종본으로 보지 말고 반복적으로 정제하세요.
- Review & Acceptance Checklist를 구현 전 반드시 검증하세요.
- 과설계를 경계하고 단순함을 우선하세요.

Linux Git 자격 증명 문제는 Git Credential Manager 설치 스크립트 예시를 참고하세요. 출처: [Spec Kit README](https://github.com/github/spec-kit) [인용: `http://github.com/github/spec-kit`]

---

## 11) 다음 단계
- `tasks.md`를 더 쪼개어 리뷰 가능한 작업 단위로 확장
- 초기부터 Draft PR을 열고 동일 브랜치에 스펙을 동반 커밋
- 구현 중 발견되는 사실을 스펙에 지속 반영

---

## 참고 자료
- Spec Kit 메인 저장소: [github/spec-kit](https://github.com/github/spec-kit) [인용: `http://github.com/github/spec-kit`]
