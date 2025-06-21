---
title: "바이브 코딩 시대: AI 개발 도구 Cursor, 전문가처럼 활용하기 (2025년 4월 가이드)"
excerpt: "Cursor, Windsurf, Replit 등 AI 개발 도구 비교 분석과 바이브 코딩 실전 전략. Project Rules, Edit-Test Loop를 통한 생산성 극대화 가이드"
date: 2025-05-27
categories:
  - dev
tags:
  - VibeCoding
  - Cursor
  - GenerativeAI
  - LLM
  - Gemini
  - o3
  - Codex
  - AI코딩
author_profile: true
# toc: true
# toc_label: "Table of Contents"
# comments: true
---

> **핵심 메시지**  구조화와 제어가 잘 된 환경에서 **Cursor**와 생성형 AI를 결합하면, 소규모 팀도 대형 서비스 수준의 생산성을 얻을 수 있다. 이 글은 **바이브 코딩(Vibe Coding)** 문화 속에서 Cursor를 "유능한 주니어"처럼 다루는 실전 전략을 담고 있다.

## 1 · End‑to‑End AI 개발 파이프라인

| 단계 | 무슨 일?          | 맡은 AI                                | 한 줄 요약                      |
| -- | -------------- | ------------------------------------ | --------------------------- |
| 1  | **PRD 작성**     | **o3**                               | "이 제품은 이런 기능이 필요해요!"        |
| 2  | **실행 계획**      | **Gemini 2.5 Pro**                   | "1주 차엔 로그인, 2주 차엔 결제…"      |
| 3  | **코드 작성**      | **Gemini MAX / Sonnet MAX + Cursor** | "코드는 내가 맡을게!"               |
| 4  | **테스트 케이스 작성** | **Gemini 2.5 Pro**                   | "이렇게 테스트해 보면 오류를 잡을 수 있어요." |
| 5  | **테스트 실행**     | **Codex**                            | "PASS/FAIL 결과를 보여 줄게."      |
| 6  | **디버깅 & 개선**   | **o3 or Gemini**                     | "에러 원인은 여기! 이렇게 고치세요."      |

> ✨ **포인트** – AI마다 **역할을 고정**해 전문화시키면 협업 충돌을 줄이고, 결과 품질이 안정된다.

---

## 2 · 생성형 AI 개발 도구 Landscape

### 2‑1 도구 비교 테이블

| 도구명                | 분류           | 주요 특징                                              | 한 줄 평              |
| ------------------ | ------------ | -------------------------------------------------- | ------------------ |
| **Lovable**        | 콜드 스타트       | 프론트·디자인·백엔드 자동 통합, Supabase·이메일 내장                 | 아이디어가 명확한 IT인에게 최적 |
| **Replit**         | 콜드 스타트 / 부스팅 | 브라우저 기반 완전한 개발 환경, 배포·오토스케일링, 모바일 지원               | 비개발자·비IT인에게 추천     |
| **V0 by Vercel**   | 콜드 스타트       | UI 컴포넌트 자동 생성, Figma 연동, shadcn 스타일링               | 디자이너라면 생산성 ↑       |
| **Trae**           | 부스팅          | 무제한 무료, VS Code 기반, 멀티 에이전트                        | "공짜가 최고"라면 실용적     |
| **Cursor**         | 부스팅          | VS Code 기반 AI 코딩, Project Rules 커스터마이징, 터미널·Git 통합 | 개발 경험자에겐 **필수**    |
| **Windsurf**       | 부스팅          | 에이전틱 채팅 UI, 컨텍스트 유지력이 높은 대화형 개발, Flows             | 똑똑한 AI 조수 느낌       |
| **GitHub Copilot** | 부스팅          | VS Code 확장, GitHub 기반 코드 보완                        | 대체재가 많아진 베테랑       |

### 2‑2 콜드 스타트 vs 부스팅

* **콜드 스타트** : 초기 UI·백엔드·배포를 "0→1"로 빠르게 세팅할 때 강력.
* **부스팅** : 이미 굴러가는 프로젝트의 **TDD, 자동화, 코드 품질**을 끌어올릴 때 효과.

### 2‑3 페르소나별 추천

* **비개발자·기획자·디자이너** → Replit, V0, Lovable
* **프론트/백엔드 개발자** → Cursor, Windsurf, Copilot
* **생산성 극대화형 유저** → Trae, Cursor, Windsurf
* **모바일 중심 개발 or 빠른 실험** → Replit
* **GitHub 워크플로우 최적화** → Copilot

---

## 3 · Cursor Master Guide

> Cursor는 잘 쓰면 **시니어 1명+주니어 3명**에 맞먹는 생산성을 낸다. 핵심은 **Rule‑Driven TDD**와 **작은 단위 Loop**.

### 3‑1 핵심 전략 4‑행 요약

| 🎯 목적         | ⚙️ 규칙                | 🧠 컨텍스트            | 🧪 검증              |
| ------------- | -------------------- | ------------------ | ------------------ |
| 구조·제약을 명확히 전달 | Project Rules로 행동 통제 | 코드 수정 내역·채팅 기록 재활용 | 테스트 주도 + 예제 기반 피드백 |

### 3‑2 Project Rules 설정

1. **5‒10개의 명확한 규칙** 정의 ⇒ `Cursor > Settings > Project Rules`
2. `/_Generate Cursor Rules` 명령으로 자동 생성 가능
3. 예시 Rules 파일 (`.cursor/rules`):

```text
Always read .cursor/design.md before writing code.
Do not write monolithic files; prefer small, composable modules.
Each endpoint must have a test file with the same name.
Do not modify files in __tests__/ (see .cursorignore).
```

### 3‑3 Edit‑Test Loop (Micro Increment)

1. **작업 정의** → 작은 기능·파일 단위 설정
2. **실패 테스트 작성** (`__tests__/`)
3. **AI에게 코드 작성** 지시 (Agent mode)
4. **테스트 실행**
5. **실패 시 루프** → AI가 분석·수정
6. **테스트 통과 후** → 개발자 리뷰

### 3‑4 베스트 프랙티스 체크리스트 (from "Cursor Best Practices")

* **Claude로 최초 Plan** 작성 → `instructions.md` 저장
* **.cursorrules** 활용으로 광범위 룰 설정
* **Chain‑of‑thought** 유도형 프롬프트 사용
* 문제 발생 시 Cursor에 **전체 파일 리스트+오류 설명** 보고서 요청 후 LLM에게 수정법 질문
* **Resync / Index**를 자주 → `.cursorsignore`로 불필요 파일 제외
* **git**으로 변경 단위를 작게 (commit 자주)
* **@file / @folder** 명령으로 필요한 컨텍스트만 명시적 전달
* 옵션 `YOLO mode` → AI가 자동으로 vitest·npm test 등 작성

---

## 4 · .cursor 폴더 Template

```text
.cursor/
├── design.md          # 시스템 설계 개요
├── requirements.md    # 기능 요구사항
├── architecture.md    # 폴더·파일 구조
├── rules              # Project Rules
├── roadmap.md         # 마일스톤
├── context.md         # 핵심 개념·정책
```

> 각 Markdown 파일은 **글로벌 컨텍스트**로 인식되어, 다음 프롬프트에서도 자동 참고된다.

물론입니다. 요청하신 대로 **4개의 상위 챕터** 아래에 각 `.cursor/` 파일을 포함하여 구조화된 형태로 정리해드리겠습니다.

---

# 📁 1. 시스템 설계 및 아키텍처

### 📄 `design.md` – 시스템 설계 개요

* 사용자 로그인 후 챗봇 생성 및 다양한 LLM API 연동
* 멀티테넌시, 리소스 제한, 과금 시스템 포함
* 핵심 모듈:

  * Auth Service (OAuth2 / JWT)
  * Bot Builder (프롬프트 및 LLM 설정)
  * Message Processor (LLM 호출 및 응답 핸들링)
  * Usage Tracker (요금 추적)
  * Admin Panel (관리자 기능)
* 아키텍처 다이어그램 포함 예정 (Mermaid 또는 이미지)

### 📄 `architecture.md` – 폴더 및 파일 구조 설명

* 디렉토리 구조:

  ```
  /api/
   ├── auth/
   ├── bots/
   ├── chat/
   └── usage/
  ```

* 각 디렉토리 역할:

  * `auth/`: 로그인, 토큰, 인증 미들웨어
  * `bots/`: 챗봇 생성/삭제 API
  * `chat/`: 대화 처리 및 LLM 연동
  * `usage/`: 사용량 기록, 통계, 과금
* 인증은 항상 `middlewares/auth.ts`를 통해 수행

---

# 📁 2. 기능 명세 및 요구사항

### 📄 `requirements.md` – 기능 요구사항

```text
# 📋 기능 요구사항

## 인증 및 사용자 관리
- [ ] 이메일/소셜 로그인 지원
- [ ] 사용자 정보 및 토큰 저장
- [ ] 관리자 계정 분리

## 챗봇 관리
- [ ] 챗봇 생성/삭제 API
- [ ] 프롬프트 커스터마이징
- [ ] LLM 종류별 API 키 연결

## 대화 시스템
- [ ] POST /chat 입력 시 LLM 호출
- [ ] 대화 로그 DB 저장
```

---

# 📁 3. 개발 규칙 및 정책

### 📄 `rules` – 프로젝트 규칙

* `design.md`와 `requirements.md`를 항상 우선 확인
* 파일 추가/수정 시 `architecture.md` 반드시 갱신
* 기능 단위 분리, 모놀리식 파일 금지
* 테스트는 `__tests__/`에 작성
* `__tests__/`, `/scripts/`는 직접 수정 금지
* 모든 코드에 TypeScript 사용 (백/프 공통)

---

# 📁 4. 프로젝트 진행 및 컨텍스트

### 📄 `roadmap.md` – 개발 로드맵

* **Phase 1 (MVP)**

  * Auth API, Chat API 완료
  * Bot CRUD 및 무료 요금제 진행 중
* **Phase 2**

  * Stripe 연동, 사용량 추적, 알림 기능
* **Phase 3**

  * 팀 기능, 데이터 익스포트

### 📄 `context.md` – 핵심 개념 및 정책

* **Bot**: 사용자 정의 프롬프트 + LLM 설정 단위
* **Session**: 대화 흐름 단위
* **LLM**: Claude, GPT, Gemini 등 외부 API
* **기본 정책**

  * 기본 요금제는 GPT-3.5만 사용 가능
  * 봇 생성은 사용자당 3개까지
  * Claude, Gemini는 유료 요금제 한정

---

## 5 · 결론 & 실전 Tips

1. **설계 없이는 Cursor 사용 금지** – 문서부터 정리하라.
2. **테스트를 먼저** – 고정된 테스트로 범위를 명확히.
3. **AI 출력은 반드시 리뷰** – 잘못된 코드는 수정 예시로 재학습.
4. **밤새 인덱싱** – 대형 프로젝트는 느린 Context Lookup을 방지.
5. **Cursor = 유능한 주니어** – 방향만 잡아주면 멀리 간다.
