---
title: "Claude Code Cookbook: 개발 생산성을 혁신하는 궁극의 AI 도구 가이드"
excerpt: "60개 이상의 명령어, 역할, 훅을 제공하는 Claude Code Cookbook을 활용하여 AI 기반 자동화로 개발 워크플로우를 혁신하는 완전한 튜토리얼."
seo_title: "Claude Code Cookbook 완전 가이드 - AI 개발 도구 튜토리얼"
seo_description: "Claude Code Cookbook 마스터하기: PR 자동화, 코드 리뷰, 리팩토링, 멀티 롤 에이전트, 개발 훅을 위한 60개 이상의 명령어로 AI 코딩 워크플로우 혁신."
date: 2025-09-23
tags:
  - claude-code
  - 개발도구
  - ai-자동화
  - github-워크플로우
  - 코드리뷰
  - 생산성
  - cli-도구
author_profile: true
toc: true
toc_label: "목차"
lang: ko
permalink: /ko/tutorials/claude-code-cookbook-comprehensive-guide/
canonical_url: "https://thakicloud.com/tech-blog/ko/tutorials/claude-code-cookbook-comprehensive-guide/"
published: false
categories:
  - tutorials
---

⏱️ **예상 읽기 시간**: 18분

## 서론

[Claude Code Cookbook](https://github.com/foreveryh/claude-code-cookbook)은 AI 기반 기능으로 개발 워크플로우를 혁신하도록 설계된 60개 이상의 명령어, 전문 역할, 자동화 훅의 획기적인 컬렉션입니다. 이 포괄적인 도구 키트는 개발자가 코드와 상호작용하고, 프로젝트를 관리하며, 지능적인 자동화를 통해 협업하는 방식을 완전히 변화시킵니다.

AI가 소프트웨어 개발을 재편하고 있는 시대에, Claude Code Cookbook은 고급 AI 기능과 일상적인 개발 작업 사이의 격차를 해소하는 실용적이고 검증된 솔루션으로 돋보입니다. 복잡한 리팩토링 처리, GitHub 워크플로우 관리, 철저한 코드 리뷰 수행 등 어떤 작업이든, 이 도구 키트는 개발 과정에서 AI를 활용하기 위한 구조화되고 신뢰할 수 있는 패턴을 제공합니다.

## Claude Code Cookbook이란?

### 개요

Claude Code Cookbook은 소프트웨어 개발을 위한 Claude Code의 기능을 향상시키도록 설계된 명령어, 역할, 자동화 스크립트의 큐레이션된 컬렉션입니다. 원래 wasabeef의 저장소에서 포크되어 커뮤니티에 의해 개선된 이 도구는 AI를 개발 워크플로우에 통합하는 체계적인 접근 방식을 제공합니다.

### 주요 구성 요소

이 도구 키트는 세 가지 주요 구성 요소로 이루어져 있습니다:

1. **명령어**: 특정 개발 작업을 위한 60개 이상의 전문 명령어
2. **역할**: 전문적인 관점과 분석을 제공하는 전문가 페르소나
3. **훅**: 개발 워크플로우에 원활하게 통합되는 자동화 스크립트

### 핵심 철학

이 쿡북은 "구조화된 AI 지원"의 원칙을 따릅니다. 일반적인 프롬프트 대신, 일반적인 개발 시나리오에 대해 일관되고 고품질의 결과를 생성하는 특정하고 상황에 맞는 명령어를 제공합니다.

## 명령어 카테고리 및 사용법

### 1. GitHub 워크플로우 명령어

이 쿡북은 일반적인 Git 작업을 간소화하는 명령어로 GitHub 워크플로우 자동화에 탁월합니다:

#### Pull Request 관리
```bash
# 열린 PR 목록 및 우선순위 지정
/pr-list

# 자동 분석으로 PR 생성
/pr-create

# 포괄적인 PR 리뷰
/pr-review

# PR 내용 자동 업데이트
/pr-auto-update

# 품질 검증으로 PR 자동 병합
/pr-merge
```

#### 이슈 관리
```bash
# 우선순위가 지정된 이슈 표시
/pr-issue

# 상세한 버그 리포트 생성
/bug-report

# 포괄적인 기능 명세서 작성
/feature-request
```

#### 고급 Git 작업
```bash
# 의미 있는 단위로 시맨틱 커밋
/semantic-commit

# CI/CD 상태 확인
/check-github-ci

# 병합 충돌 지능적 처리
/merge-conflict
```

### 2. 코드 품질 및 분석 명령어

이 명령어들은 코드 품질 유지 및 개선에 중점을 둡니다:

#### 코드 리뷰 및 분석
```bash
# 고급 코드 품질 리뷰
/smart-review

# 안전한 단계별 리팩토링
/refactor

# 기술 부채 분석
/tech-debt

# 포괄적인 오류 분석
/fix-error
```

#### 아키텍처 및 설계
```bash
# 상세한 명세서 작성
/spec

# 포괄적인 문서 생성
/generate-docs

# 성능 최적화 분석
/optimize
```

### 3. 개발 워크플로우 명령어

일상적인 개발 활동을 향상시키는 명령어들:

#### 프로젝트 관리
```bash
# 구현 계획 작성
/plan

# 실행 진행상황 추적
/show-plan

# 다국어 문서 업데이트
/update-doc-string
```

#### 의존성 관리
```bash
# 안전한 Flutter 의존성 업데이트
/update-flutter-deps

# Node.js 의존성 관리
/update-node-deps

# Rust 의존성 업데이트
/update-rust-deps
```

## 역할 기반 전문가 분석

### 사용 가능한 역할

이 쿡북에는 전문가 관점을 제공하는 특화된 역할들이 포함되어 있습니다:

| 역할 | 전문 분야 | 사용 사례 |
|------|-----------|-----------|
| `/role analyzer` | 시스템 분석 전문가 | 아키텍처 리뷰, 시스템 설계 |
| `/role architect` | 소프트웨어 아키텍처 | 디자인 패턴, 확장성 |
| `/role frontend` | UI/UX 및 성능 | 프론트엔드 최적화, 사용자 경험 |
| `/role mobile` | iOS/Android 개발 | 모바일 모범 사례, 플랫폼별 조언 |
| `/role performance` | 성능 최적화 | 속도 및 메모리 개선 |
| `/role qa` | 품질 보증 | 테스트 계획, 품질 지표 |
| `/role reviewer` | 코드 리뷰 전문가 | 코드 품질, 유지보수성 |
| `/role security` | 보안 전문가 | 취약점 평가, 보안 모범 사례 |

### 서브 에이전트 실행

역할들은 병렬 분석을 위해 독립적인 서브 에이전트로 실행될 수 있습니다:

```bash
# 일반 모드 (메인 컨텍스트에서 실행)
/role security
"이 프로젝트의 보안 검사"

# 서브 에이전트 모드 (독립적인 컨텍스트에서 실행)
/role security --agent
"프로젝트의 포괄적인 보안 감사 수행"

# 여러 역할과의 병렬 분석
/multi-role security,performance --agent
"시스템의 보안과 성능을 포괄적으로 분석"
```

### 역할 토론 기능

`/role-debate` 명령어는 여러 전문가 관점의 협업을 가능하게 합니다:

```bash
/role-debate
"이 프로젝트에 마이크로서비스 아키텍처와 모놀리식 아키텍처 중 어느 것을 사용해야 할까요?"
```

이 명령어는 서로 다른 역할 간의 토론을 조율하여 여러 전문가 관점에서 균형 잡힌 분석을 제공합니다.

## 자동화 훅

### 개발 자동화

이 쿡북에는 일반적인 개발 작업을 자동화하는 정교한 훅들이 포함되어 있습니다:

#### 파일 관리 훅
- **preserve-file-permissions.sh**: 편집 중 파일 권한 유지
- **ja-space-format.sh**: 일본어 텍스트 간격 자동 포맷
- **auto-comment.sh**: 새 파일 생성 시 문서화 촉구

#### 안전성 및 품질 훅
- **deny-check.sh**: 위험한 명령어 실행 방지
- **check-ai-commit.sh**: 커밋 메시지 품질 검증
- **check-continue.sh**: 지속 가능한 작업 식별

#### 알림 훅
- **notify-waiting**: 사용자 확인을 위한 macOS 알림
- **osascript**: 완료 알림

### 훅 구성

훅은 `settings.json`에서 구성되며 특정 지점에서 자동으로 실행됩니다:

- **PreToolUse**: 도구 작업 전 실행
- **PostToolUse**: 도구 작업 후 실행
- **Notification**: 사용자 알림 처리
- **Stop**: 작업 완료 시 실행

## 고급 기능

### 다국어 지원

이 쿡북은 여러 언어로 포괄적인 문서화를 지원합니다:

```bash
# 여러 언어로 문서 문자열 업데이트
/update-doc-string

# Dart 특화 문서 관리
/update-dart-doc
```

### 검색 및 분석

포괄적인 코드 분석을 위한 고급 검색 기능:

```bash
# 웹 검색 통합
/search-gemini

# 복잡한 문제를 위한 순차적 사고
/sequential-thinking

# 초구조화된 사고 과정
/ultrathink
```

### AI 글쓰기 향상

AI 생성 콘텐츠 개선을 위한 도구:

```bash
# AI 생성 텍스트 패턴 감지 및 수정
/style-ai-writing

# 전문 에이전트에게 작업 위임
/task
```

## 개발 워크플로우 통합

### 일반적인 개발 흐름

이 쿡북은 간소화된 개발 워크플로우를 가능하게 합니다:

{% raw %}
<!--
  animated-architecture-diagram — self-contained D3 embed template.
  HuggingFace research-article style: declarative NODES/EDGES/SEQ model,
  data(solid)/event(dashed) edges, hover-trace + tooltip, flow-dot animation
  along edge paths, replay button, scroll-into-view autoplay, reduced-motion +
  light/dark aware. The renderer injects window.__ARCH_SPEC__ at the marker.
  Format (D3 machinery + CSS) is owned by this committed template; the model
  only authors the JSON spec (content). See references/spec-schema.md.
-->
<div class="d3-arch" data-arch-root id="ensivedevelopmentguideko-1"></div>
<style>
  /* ---- Theme tokens (standalone; light default + dark override) ---- */
  .d3-arch {
    --page-bg: #ffffff;
    --surface-bg: #f7f8fa;
    --text-color: #1a1d21;
    --muted-color: #6b7280;
    --border-color: #d5d9e0;
    --primary-color: hsl(217 91% 55%); /* brand accent — swap for #1B4F72 etc. */
    position: relative;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Noto Sans KR", system-ui, sans-serif;
    color: var(--text-color);
  }
  @media (prefers-color-scheme: dark) {
    .d3-arch {
      --page-bg: #0f1115;
      --surface-bg: #171a21;
      --text-color: #e6e8eb;
      --muted-color: #9aa3af;
      --border-color: #2a2f3a;
      --primary-color: hsl(217 91% 62%);
    }
  }
  .d3-arch[data-theme="light"] { --page-bg:#fff; --surface-bg:#f7f8fa; --text-color:#1a1d21; --muted-color:#6b7280; --border-color:#d5d9e0; --primary-color:hsl(217 91% 55%); }
  .d3-arch[data-theme="dark"]  { --page-bg:#0f1115; --surface-bg:#171a21; --text-color:#e6e8eb; --muted-color:#9aa3af; --border-color:#2a2f3a; --primary-color:hsl(217 91% 62%); }

  .d3-arch .diagram-scroll { overflow-x: auto; }
  /* Size to the spec's natural canvas: JS caps max-width at the spec width so a
     narrow/portrait diagram is never stretched to the article column (blur + giant
     vertical figures); wide diagrams scale down but keep min-width 760 + scroll. */
  .d3-arch svg { display: block; width: 100%; max-width: 100%; height: auto; font-family: inherit; }

  /* Group boxes */
  .d3-arch .group rect { fill: none; stroke: var(--border-color); stroke-dasharray: 3 3; rx: 12px; }
  .d3-arch .group text { font-size: 10px; font-weight: 700; letter-spacing: 0.08em; text-transform: uppercase; fill: var(--muted-color); }

  /* Nodes */
  .d3-arch .node rect { fill: var(--surface-bg); stroke: var(--border-color); stroke-width: 1; transition: stroke 0.15s ease, opacity 0.15s ease; }
  .d3-arch .node .node-title { font-size: 12px; font-weight: 600; fill: var(--text-color); }
  .d3-arch .node .node-sub { font-size: 9.5px; fill: var(--muted-color); }
  .d3-arch .node { cursor: default; transition: opacity 0.15s ease; }

  /* Edges */
  .d3-arch .edge { transition: opacity 0.15s ease; }
  .d3-arch .edge path.main { fill: none; stroke-width: 1.5; }
  .d3-arch .edge.data path.main { stroke: var(--primary-color); }
  .d3-arch .edge.event path.main { stroke: var(--muted-color); stroke-dasharray: 5 4; }
  .d3-arch .edge text { font-size: 9.5px; fill: var(--muted-color); paint-order: stroke; stroke: var(--page-bg); stroke-width: 3px; stroke-linejoin: round; }

  /* Hover highlighting */
  .d3-arch.hovering .edge:not(.hl) { opacity: 0.12; }
  .d3-arch.hovering .node:not(.hl):not(.nb) { opacity: 0.25; }
  .d3-arch .node.hl rect { stroke: var(--primary-color); stroke-width: 1.5; }

  /* Flow animation */
  .d3-arch .flow-dot.data { fill: var(--primary-color); stroke: var(--page-bg); stroke-width: 1.5; }
  .d3-arch .flow-dot.event { fill: var(--page-bg); stroke: var(--muted-color); stroke-width: 1.5; }
  .d3-arch .node.anim-hl rect { stroke: var(--primary-color); stroke-width: 1.5; }
  .d3-arch .replay-btn { font: inherit; font-size: 11px; font-weight: 600; padding: 4px 10px; border: 1px solid var(--border-color); border-radius: 8px; background: var(--surface-bg); color: var(--text-color); cursor: pointer; transition: border-color 0.15s ease, opacity 0.15s ease; }
  .d3-arch .replay-btn:hover:not(:disabled) { border-color: var(--primary-color); }
  .d3-arch .replay-btn:disabled { opacity: 0.45; cursor: default; }
  .d3-arch .replay-btn:focus-visible { outline: 2px solid var(--primary-color); outline-offset: 1px; }

  /* Legend */
  .d3-arch .legend { display: flex; flex-direction: column; align-items: flex-start; gap: 6px; margin-top: 10px; }
  .d3-arch .legend-title { font-size: 12px; font-weight: 700; color: var(--text-color); }
  .d3-arch .legend .items { display: flex; flex-wrap: wrap; gap: 8px 18px; align-items: center; }
  .d3-arch .legend .item { display: inline-flex; align-items: center; gap: 7px; white-space: nowrap; font-size: 12px; color: var(--text-color); }
  .d3-arch .legend .swatch { width: 22px; height: 0; }
  .d3-arch .legend .swatch.data-line { border-top: 2.5px solid var(--primary-color); }
  .d3-arch .legend .swatch.event-line { border-top: 2.5px dashed var(--muted-color); }
  .d3-arch .legend .hint { font-size: 11px; font-style: italic; color: var(--muted-color); }
</style>
<script>
  (() => {
    const SPEC = ({"title": "", "ariaLabel": "", "width": 716, "height": 1666, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "Start", "x": 302, "y": 24, "w": 120, "h": 46, "title": "작업 확인"}, {"id": "PRList", "x": 214, "y": 148, "w": 120, "h": 62, "title": ["/pr-list", "열린 PR 목록"]}, {"id": "PRIssue", "x": 389, "y": 148, "w": 120, "h": 62, "title": ["/pr-issue", "열린 이슈 목록"]}, {"id": "TaskType", "x": 293, "y": 288, "w": 138, "h": 52, "title": "유형?"}, {"id": "Plan", "x": 32, "y": 432, "w": 120, "h": 62, "title": ["/spec", "요구사항 정의 & 설계"]}, {"id": "Fix", "x": 214, "y": 580, "w": 120, "h": 62, "title": ["/fix-error", "오류 분석"]}, {"id": "Refactor", "x": 389, "y": 580, "w": 120, "h": 62, "title": ["/refactor", "개선"]}, {"id": "Review", "x": 564, "y": 580, "w": 120, "h": 62, "title": ["/pr-review", "리뷰"]}, {"id": "Design", "x": 24, "y": 572, "w": 135, "h": 78, "title": ["/role architect", "/role-debate", "설계 컨설팅"]}, {"id": "Implementation", "x": 302, "y": 728, "w": 120, "h": 46, "title": "구현 & 테스트"}, {"id": "Check", "x": 230, "y": 852, "w": 121, "h": 62, "title": ["/smart-review", "품질 검사"]}, {"id": "Commit", "x": 220, "y": 992, "w": 142, "h": 62, "title": ["/semantic-commit", "목적별 커밋"]}, {"id": "PR", "x": 231, "y": 1132, "w": 120, "h": 62, "title": ["/pr-create", "자동 PR 생성"]}, {"id": "CI", "x": 220, "y": 1272, "w": 142, "h": 62, "title": ["/check-github-ci", "CI 상태 확인"]}, {"id": "Status", "x": 222, "y": 1412, "w": 138, "h": 52, "title": "문제 있음?"}, {"id": "Feedback", "x": 389, "y": 1556, "w": 120, "h": 78, "title": ["수정 응답", "/pr-feedback", "/fix-error"]}, {"id": "End", "x": 214, "y": 1572, "w": 120, "h": 46, "title": "완료"}], "edges": [{"src": "Start", "dst": "PRList", "kind": "data", "curve": [[329, 70], [274, 109], [274, 109], [274, 148]]}, {"src": "Start", "dst": "PRIssue", "kind": "data", "curve": [[394, 70], [449, 109], [449, 109], [449, 148]]}, {"src": "PRList", "dst": "TaskType", "kind": "data", "curve": [[274, 210], [274, 249], [274, 249], [327, 288]]}, {"src": "PRIssue", "dst": "TaskType", "kind": "data", "curve": [[449, 210], [449, 249], [449, 249], [397, 288]]}, {"src": "TaskType", "dst": "Plan", "kind": "data", "label": "새 기능", "curve": [[293, 332], [92, 386], [92, 386], [92, 432]], "off": "50%"}, {"src": "TaskType", "dst": "Fix", "kind": "data", "label": "버그 수정", "curve": [[330, 340], [274, 386], [274, 533], [274, 580]], "off": "50%"}, {"src": "TaskType", "dst": "Refactor", "kind": "data", "label": "리팩토링", "curve": [[393, 340], [449, 386], [449, 533], [449, 580]], "off": "50%"}, {"src": "TaskType", "dst": "Review", "kind": "data", "label": "리뷰", "curve": [[431, 333], [624, 386], [624, 533], [624, 580]], "off": "50%"}, {"src": "Plan", "dst": "Design", "kind": "data", "line": [92, 494, 92, 572]}, {"src": "Design", "dst": "Implementation", "kind": "data", "curve": [[92, 650], [92, 689], [92, 689], [302, 737]]}, {"src": "Fix", "dst": "Implementation", "kind": "data", "curve": [[274, 642], [274, 689], [274, 689], [329, 728]]}, {"src": "Refactor", "dst": "Implementation", "kind": "data", "curve": [[449, 642], [449, 689], [449, 689], [394, 728]]}, {"src": "Review", "dst": "Implementation", "kind": "data", "curve": [[624, 642], [624, 689], [624, 689], [422, 737]]}, {"src": "Implementation", "dst": "Check", "kind": "data", "curve": [[335, 774], [291, 813], [291, 813], [291, 852]]}, {"src": "Check", "dst": "Commit", "kind": "data", "line": [291, 914, 291, 992]}, {"src": "Commit", "dst": "PR", "kind": "data", "line": [291, 1054, 291, 1132]}, {"src": "PR", "dst": "CI", "kind": "data", "line": [291, 1194, 291, 1272]}, {"src": "CI", "dst": "Status", "kind": "data", "line": [291, 1334, 291, 1412]}, {"src": "Status", "dst": "Feedback", "kind": "data", "label": "예", "line": [322, 1464, 417, 1556], "lx": 378, "ly": 1506}, {"src": "Status", "dst": "End", "kind": "data", "label": "아니오", "curve": [[285, 1464], [274, 1510], [274, 1510], [274, 1572]], "off": "50%"}, {"src": "Feedback", "dst": "Implementation", "kind": "data", "curve": [[455, 1556], [461, 1303], [461, 1023], [398, 774]]}]});
    const ensureD3 = (cb) => {
      if (window.d3 && typeof window.d3.select === 'function') return cb();
      let s = document.getElementById('d3-cdn-script');
      if (!s) {
        s = document.createElement('script');
        s.id = 'd3-cdn-script';
        s.src = 'https://cdn.jsdelivr.net/npm/d3@7/dist/d3.min.js';
        document.head.appendChild(s);
      }
      const onReady = () => { if (window.d3 && typeof window.d3.select === 'function') cb(); };
      s.addEventListener('load', onReady, { once: true });
      if (window.d3) onReady();
    };

    const bootstrap = () => {
      const container = document.getElementById('ensivedevelopmentguideko-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ensivedevelopmentguideko-1';
        const NODES = SPEC.nodes || [];
        const EDGES = SPEC.edges || [];
        const GROUPS = SPEC.groups || [];
        const HOP = SPEC.hop || 800;
        const legendCfg = SPEC.legend || {};
        const dataLabel = legendCfg.data || 'Data path';
        const eventLabel = legendCfg.event || 'Event side-channel';

        const byId = Object.fromEntries(NODES.map((n) => [n.id, n]));
        const cx = (n) => n.x + n.w / 2;
        const asTitle = (t) => Array.isArray(t) ? t : [t];

        // Canvas: explicit, else auto from node/group extents + padding
        let W = SPEC.width, H = SPEC.height;
        if (!W || !H) {
          const xs = [], ys = [];
          NODES.forEach((n) => { xs.push(n.x + n.w); ys.push(n.y + n.h); });
          GROUPS.forEach((g) => { xs.push(g.x + g.w); ys.push(g.y + g.h); });
          W = W || Math.max(760, Math.ceil(Math.max(...xs, 0) + 24));
          H = H || Math.ceil(Math.max(...ys, 0) + 20);
        }

        // Tooltip
        container.style.position = container.style.position || 'relative';
        const tip = document.createElement('div');
        Object.assign(tip.style, {
          position: 'absolute', top: '0px', left: '0px',
          transform: 'translate(-9999px, -9999px)', pointerEvents: 'none',
          padding: '8px 10px', borderRadius: '8px', fontSize: '12px', lineHeight: '1.4',
          border: '1px solid var(--border-color)', background: 'var(--surface-bg)',
          color: 'var(--text-color)', boxShadow: '0 4px 24px rgba(0,0,0,.18)',
          opacity: '0', transition: 'opacity .12s ease', maxWidth: '260px', zIndex: '3'
        });
        const tipInner = document.createElement('div');
        tip.appendChild(tipInner);

        const scroll = document.createElement('div');
        scroll.className = 'diagram-scroll';
        container.appendChild(scroll);

        const svg = d3.select(scroll).append('svg')
          .attr('viewBox', `0 0 ${W} ${H}`)
          .attr('preserveAspectRatio', 'xMidYMid meet')
          .attr('role', 'img')
          .attr('aria-label', SPEC.ariaLabel || SPEC.title || 'Architecture diagram');
        // Never upscale past the spec's natural width; keep 760px readability
        // floor (with horizontal scroll) only for diagrams that are actually wide.
        svg.style('max-width', W + 'px').style('min-width', Math.min(W, 760) + 'px').style('margin', '0 auto');

        const defs = svg.append('defs');
        const mkMarker = (id, color) => {
          defs.append('marker')
            .attr('id', id).attr('viewBox', '0 0 10 10')
            .attr('refX', 9).attr('refY', 5)
            .attr('markerWidth', 6.5).attr('markerHeight', 6.5)
            .attr('orient', 'auto-start-reverse')
            .append('path').attr('d', 'M 0 0 L 10 5 L 0 10 z').style('fill', color);
        };
        mkMarker(`${uid}-arrow-data`, 'var(--primary-color)');
        mkMarker(`${uid}-arrow-event`, 'var(--muted-color)');

        // Groups
        const groups = svg.append('g');
        GROUPS.forEach((gr) => {
          const g = groups.append('g').attr('class', 'group');
          g.append('rect').attr('x', gr.x).attr('y', gr.y).attr('width', gr.w).attr('height', gr.h).attr('rx', 12);
          if (gr.label) g.append('text').attr('x', gr.lx != null ? gr.lx : gr.x + 12).attr('y', gr.ly != null ? gr.ly : gr.y + 18).text(gr.label);
        });

        // Edges (under nodes)
        const edgeLayer = svg.append('g');
        const curvePath = (p) => `M ${p[0][0]} ${p[0][1]} C ${p[1][0]} ${p[1][1]}, ${p[2][0]} ${p[2][1]}, ${p[3][0]} ${p[3][1]}`;
        EDGES.forEach((e, i) => {
          const kind = e.kind === 'event' ? 'event' : 'data';
          const g = edgeLayer.append('g').attr('class', `edge ${kind}`).attr('data-src', e.src).attr('data-dst', e.dst);
          const marker = `url(#${uid}-arrow-${kind})`;
          if (e.line) {
            const [x1, y1, x2, y2] = e.line;
            e.pathEl = g.append('path').attr('class', 'main').attr('d', `M ${x1} ${y1} L ${x2} ${y2}`).attr('marker-end', marker).node();
            if (e.label) g.append('text').attr('x', e.lx != null ? e.lx : (x1 + x2) / 2).attr('y', e.ly != null ? e.ly : (y1 + y2) / 2 - 6).attr('text-anchor', e.anchor || 'middle').text(e.label);
          } else if (e.curve) {
            e.pathEl = g.append('path').attr('class', 'main').attr('d', curvePath(e.curve)).attr('marker-end', marker).node();
            if (e.label && e.off) {
              const p = e.curve;
              const lp = p[3][0] < p[0][0] ? [p[3], p[2], p[1], p[0]] : p;
              const lpId = `${uid}-lbl-${i}`;
              g.append('path').attr('id', lpId).attr('d', curvePath(lp)).attr('fill', 'none').attr('stroke', 'none');
              g.append('text').attr('dy', -5).append('textPath').attr('href', `#${lpId}`).attr('startOffset', e.off).attr('text-anchor', 'middle').text(e.label);
            } else if (e.label) {
              g.append('text').attr('x', e.lx).attr('y', e.ly).attr('text-anchor', e.anchor || 'start').text(e.label);
            }
          }
        });

        // Nodes (over edges)
        const nodeLayer = svg.append('g');
        NODES.forEach((n) => {
          const g = nodeLayer.append('g').attr('class', 'node').attr('data-id', n.id);
          g.append('rect').attr('x', n.x).attr('y', n.y).attr('width', n.w).attr('height', n.h).attr('rx', 9);
          const title = asTitle(n.title);
          const lines = title.length;
          const baseY = n.y + n.h / 2 - (lines - 1) * 7 - (n.sub ? 5 : -4);
          title.forEach((t, li) => {
            g.append('text').attr('class', 'node-title').attr('x', cx(n)).attr('y', baseY + li * 14).attr('text-anchor', 'middle').text(t);
          });
          if (n.sub) g.append('text').attr('class', 'node-sub').attr('x', cx(n)).attr('y', baseY + (lines - 1) * 14 + 15).attr('text-anchor', 'middle').text(n.sub);
        });

        // Hover highlighting
        const edgeSel = svg.selectAll('.edge');
        const nodeSel = svg.selectAll('.node');
        nodeSel
          .on('mouseenter', function () {
            const id = this.getAttribute('data-id');
            const n = byId[id];
            container.classList.add('hovering');
            const nb = new Set([id]);
            edgeSel.classed('hl', function () {
              const hit = this.getAttribute('data-src') === id || this.getAttribute('data-dst') === id;
              if (hit) { nb.add(this.getAttribute('data-src')); nb.add(this.getAttribute('data-dst')); }
              return hit;
            });
            nodeSel.classed('hl', function () { return this.getAttribute('data-id') === id; })
                   .classed('nb', function () { return nb.has(this.getAttribute('data-id')); });
            if (n && n.desc) { tipInner.innerHTML = `<strong>${asTitle(n.title).join('')}</strong><br>${n.desc}`; tip.style.opacity = '1'; }
          })
          .on('mousemove', function (event) {
            const [mx, my] = d3.pointer(event, container);
            const flip = mx > container.clientWidth - 280;
            tip.style.transform = `translate(${flip ? mx - 270 : mx + 14}px, ${my + 14}px)`;
          })
          .on('mouseleave', function () {
            container.classList.remove('hovering');
            edgeSel.classed('hl', false);
            nodeSel.classed('hl', false).classed('nb', false);
            tip.style.opacity = '0';
            tip.style.transform = 'translate(-9999px, -9999px)';
          });

        // Flow animation sequence: explicit SEQ, else auto forward-cascade of data edges
        const resolveEdge = (s) => {
          if (typeof s.e === 'number') return s.e;
          if (s.from && s.to) return EDGES.findIndex((e) => e.src === s.from && e.dst === s.to);
          return -1;
        };
        let SEQ = (SPEC.seq || []).map((s) => ({ e: resolveEdge(s), t0: s.t0 })).filter((s) => s.e >= 0);
        if (!SEQ.length) {
          let t = 0;
          EDGES.forEach((e, i) => { if ((e.kind || 'data') === 'data') { SEQ.push({ e: i, t0: t }); t += HOP; } });
        }
        const TOTAL = SPEC.total || (Math.max(0, ...SEQ.map((s) => s.t0)) + HOP + 800);

        let playing = false, replayBtn = null;
        const pulseNode = (id) => {
          const sel = nodeSel.filter(function () { return this.getAttribute('data-id') === id; });
          sel.classed('anim-hl', true);
          setTimeout(() => sel.classed('anim-hl', false), 550);
        };
        const play = () => {
          if (playing) return;
          playing = true;
          if (replayBtn) replayBtn.disabled = true;
          const layer = svg.append('g');
          const steps = SEQ.map((s) => {
            const edge = EDGES[s.e];
            return { ...s, edge, len: edge.pathEl.getTotalLength(), dot: null, arrived: false };
          });
          const start = performance.now();
          const frame = (now) => {
            const t = now - start;
            steps.forEach((s) => {
              if (t < s.t0) return;
              const f = Math.min(1, (t - s.t0) / HOP);
              if (f >= 1) { if (s.dot) { s.dot.remove(); s.dot = null; } if (!s.arrived) { s.arrived = true; pulseNode(s.edge.dst); } return; }
              if (!s.dot) s.dot = layer.append('circle').attr('class', `flow-dot ${s.edge.kind || 'data'}`).attr('r', (s.edge.kind === 'event') ? 4 : 5);
              const p = s.edge.pathEl.getPointAtLength(d3.easeCubicInOut(f) * s.len);
              s.dot.attr('cx', p.x).attr('cy', p.y);
            });
            if (t < TOTAL) requestAnimationFrame(frame);
            else { layer.remove(); playing = false; if (replayBtn) replayBtn.disabled = false; }
          };
          requestAnimationFrame(frame);
        };

        // Legend
        const legend = document.createElement('div');
        legend.className = 'legend';
        legend.innerHTML = `
          <div class="legend-title">${SPEC.legendTitle || 'Legend'}</div>
          <div class="items">
            <span class="item"><span class="swatch data-line"></span><span>${dataLabel}</span></span>
            <span class="item"><span class="swatch event-line"></span><span>${eventLabel}</span></span>
            <button class="replay-btn" type="button" aria-label="Replay the flow animation">&#9654; Replay</button>
            <span class="hint">${SPEC.hint || 'Hover a component to trace its connections.'}</span>
          </div>`;
        container.appendChild(legend);
        container.appendChild(tip);
        replayBtn = legend.querySelector('.replay-btn');
        replayBtn.addEventListener('click', play);

        const prefersReduced = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
        if (!prefersReduced && window.IntersectionObserver) {
          const io = new IntersectionObserver((entries) => {
            entries.forEach((en) => { if (en.isIntersecting) { io.disconnect(); play(); } });
          }, { threshold: 0.5 });
          io.observe(container);
        }
      } catch (err) {
        const pre = document.createElement('pre');
        pre.style.color = '#c0392b';
        pre.style.fontSize = '12px';
        pre.textContent = 'Failed to render architecture diagram: ' + (err && err.message ? err.message : err);
        container.appendChild(pre);
      }
    };

    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', () => ensureD3(bootstrap), { once: true });
    else ensureD3(bootstrap);
  })();
</script>
{% endraw %}

### 모범 사례

1. **계획으로 시작**: 기능 계획에는 `/spec`, 추적에는 `/show-plan` 사용
2. **역할 활용**: 도메인별 분석에 전문 역할 사용
3. **리뷰 자동화**: 워크플로우에 `/smart-review`와 `/pr-review` 통합
4. **품질 유지**: 일관된 코드 품질과 안전성을 위해 훅 사용
5. **병렬 분석**: 포괄적인 다관점 분석을 위해 서브 에이전트 활용

## 설치 및 설정

### 전제 조건

- Claude Code (최신 버전)
- 적절한 권한으로 구성된 Git
- Node.js (특정 의존성 관리 명령어용)

### 설치 단계

1. **저장소 클론**:
```bash
git clone https://github.com/foreveryh/claude-code-cookbook.git
cd claude-code-cookbook
```

2. **Claude Code 구성**:
Claude Code 구성에 쿡북 명령어 추가:
```json
{
  "commands_directory": "./commands",
  "roles_directory": "./agents/roles",
  "hooks_directory": "./.claude/hooks"
}
```

3. **훅 설정**:
`settings.json`에서 자동 훅 구성:
```json
{
  "hooks": {
    "PreToolUse": ["deny-check.sh", "preserve-file-permissions.sh"],
    "PostToolUse": ["auto-comment.sh", "ja-space-format.sh"],
    "Notification": ["notify-waiting"],
    "Stop": ["check-continue.sh"]
  }
}
```

### 검증

다음을 실행하여 설치를 테스트하십시오:
```bash
/role-help  # 사용 가능한 역할 목록 표시
/pr-list    # 현재 PR 표시 (git 저장소에 있는 경우)
```

## 사용 사례 및 예제

### 1. 포괄적인 코드 리뷰

시나리오: 여러 구성 요소가 있는 복잡한 풀 리퀘스트 리뷰.

```bash
# 1단계: PR 개요 가져오기
/pr-list

# 2단계: 다중 역할 분석
/multi-role security,performance,reviewer --agent
"보안 취약점, 성능 문제, 코드 품질에 대해 PR #123 분석"

# 3단계: 상세 리뷰
/pr-review

# 4단계: 구조화된 피드백 제공
/pr-feedback
```

### 2. 기능 개발 워크플로우

시나리오: OAuth 통합을 포함한 새로운 사용자 인증 시스템 개발.

```bash
# 1단계: 명세서 작성
/spec
"OAuth 통합을 포함한 사용자 인증 시스템"

# 2단계: 아키텍처 컨설팅
/role-debate
"우리 사용 사례에 OAuth vs JWT vs 세션 기반 인증"

# 3단계: 구현 계획
/plan

# 4단계: 진행상황 추적
/show-plan

# 5단계: 품질 보증
/role qa --agent
"인증 시스템을 위한 포괄적인 테스트 전략 작성"
```

### 3. 기술 부채 관리

시나리오: 레거시 코드베이스에서 축적된 기술 부채 해결.

```bash
# 1단계: 기술 부채 분석
/tech-debt

# 2단계: 개선사항 우선순위 지정
/role architect --agent
"우선순위가 지정된 기술 부채 감소 계획 작성"

# 3단계: 안전한 리팩토링
/refactor

# 4단계: 변경사항 검증
/smart-review
```

## 고급 구성

### 사용자 정의 명령어

템플릿 구조를 따라 사용자 정의 명령어로 쿡북을 확장할 수 있습니다:

```markdown
# 사용자 정의 명령어 템플릿
## 목적
명령어가 수행하는 작업에 대한 간단한 설명

## 사용법
/custom-command [매개변수]

## 구현
상세한 구현 로직
```

### 환경별 훅

서로 다른 개발 환경에 대한 훅 구성:

```bash
# 개발 환경
export CLAUDE_ENV="development"

# 프로덕션 안전 훅
export CLAUDE_ENV="production"
```

### 다중 프로젝트 구성

여러 프로젝트에서 작업하는 팀을 위한 구성:

```json
{
  "projects": {
    "project1": {
      "commands": ["./project1-commands"],
      "roles": ["./project1-roles"]
    },
    "project2": {
      "commands": ["./project2-commands"],
      "roles": ["./project2-roles"]
    }
  }
}
```

## 성능 및 최적화

### 명령어 실행 최적화

1. **병렬 실행**: 독립적인 분석에 서브 에이전트 사용
2. **컨텍스트 관리**: 명령어에 적절한 컨텍스트 범위 유지
3. **캐싱**: 반복 작업에 Claude Code의 내장 캐싱 활용

### 메모리 및 리소스 관리

- **토큰 최적화**: 명령어가 토큰을 효율적으로 사용하도록 설계
- **컨텍스트 보존**: 훅이 작업 간 컨텍스트 유지
- **리소스 정리**: 임시 리소스의 자동 정리

## 문제 해결

### 일반적인 문제

1. **명령어를 찾을 수 없음**: 적절한 설치 및 구성 확인
2. **권한 오류**: 파일 권한 및 Git 구성 확인
3. **훅 실패**: 훅 스크립트에 실행 권한이 있는지 확인

### 디버그 모드

상세한 실행 정보를 위해 디버그 모드 활성화:
```bash
export CLAUDE_DEBUG=true
```

### 커뮤니티 지원

- **GitHub 이슈**: 버그 및 기능 요청 신고
- **문서**: 저장소에서 포괄적인 문서 제공
- **커뮤니티**: 지원 및 기여를 위한 활발한 커뮤니티

## 보안 고려사항

### 안전한 명령어 실행

이 쿡북에는 여러 보안 기능이 포함되어 있습니다:

- **명령어 검증**: `deny-check.sh`가 위험한 작업 방지
- **권한 보존**: 원본 파일 권한 유지
- **감사 추적**: 모든 작업의 포괄적인 로깅

### 모범 사례

1. **명령어 검토**: 실행 전 생성된 명령어 항상 검토
2. **훅 사용**: 환경에 안전 훅 구현
3. **접근 제어**: 팀 사용을 위한 적절한 접근 제어 구성
4. **정기 업데이트**: 보안 패치를 위해 쿡북을 최신 상태로 유지

## 향후 발전

### 로드맵

Claude Code Cookbook은 다음과 함께 계속 발전하고 있습니다:

- **새로운 명령어**: 커뮤니티 요청 명령어의 정기적 추가
- **향상된 역할**: 더 전문화된 전문가 역할
- **통합 개선**: 더 나은 IDE 및 플랫폼 통합
- **성능 최적화**: 속도와 효율성을 위한 지속적인 최적화

### 커뮤니티 기여

이 프로젝트는 기여를 환영합니다:

- **명령어 개발**: 특정 사용 사례를 위한 새로운 명령어 생성
- **역할 향상**: 전문화된 전문가 역할 개발
- **문서**: 문서 개선 및 번역
- **버그 수정**: 문제 해결 및 안정성 개선

## 결론

Claude Code Cookbook은 AI 기반 개발 도구에서 중요한 발전을 나타냅니다. 일반적인 개발 작업에 대한 구조화되고 신뢰할 수 있는 패턴을 제공함으로써, 개발자가 코드 품질과 개발 모범 사례를 유지하면서 AI의 모든 힘을 활용할 수 있게 합니다.

생산성을 향상시키려는 개별 개발자든, AI 지원 개발 관행을 표준화하려는 팀이든, 이 쿡북은 성공에 필요한 도구와 패턴을 제공합니다. 포괄적인 명령어 세트, 전문가 역할, 자동화 훅은 AI가 인간의 전문성을 대체하는 것이 아니라 보강하는 개발 환경을 만듭니다.

소프트웨어 개발의 미래는 인간의 창의성과 AI 기능 간의 지능적인 협업에 있습니다. Claude Code Cookbook은 이러한 협업을 위한 프레임워크를 제공하여 AI 지원이 강력할 뿐만 아니라 신뢰할 수 있고, 안전하며, 소프트웨어 엔지니어링 모범 사례와 일치하도록 보장합니다.

오늘 쿡북 탐색을 시작하여 구조화된 AI 지원의 힘으로 개발 워크플로우를 변화시키십시오. 이러한 패턴을 학습하는 데 투자한 시간은 생산성 향상, 코드 품질 개선, 개발 팀 전반의 협업 강화로 보상받을 것입니다.

---

*개발 워크플로우를 혁신할 준비가 되셨나요? [Claude Code Cookbook](https://github.com/foreveryh/claude-code-cookbook)을 클론하고 오늘부터 AI 기반 개발의 미래를 경험해보세요.*
