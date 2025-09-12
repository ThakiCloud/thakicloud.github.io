---
title: "AGENTS.md 완벽 가이드: AI 코드 생성 품질 향상시키기"
excerpt: "AI 에이전트의 성능을 극적으로 향상시키는 효과적인 AGENTS.md 파일 작성법을 실용적인 예제와 모범 사례를 통해 배워보세요."
seo_title: "AGENTS.md 튜토리얼: AI 코드 품질 향상 모범 사례 - Thaki Cloud"
seo_description: "더 나은 AI 코딩 지원을 위한 AGENTS.md 파일 작성 완벽 가이드. 실제 예제와 함께 배우는 규칙 설정, 안전 권한, 프로젝트 구조 정의 방법."
date: 2025-09-10
categories:
  - tutorials
tags:
  - ai
  - 코딩
  - 자동화
  - 생산성
  - 에이전트
author_profile: true
toc: true
toc_label: "목차"
lang: ko
permalink: /ko/tutorials/agents-md-comprehensive-tutorial-guide/
canonical_url: "https://thakicloud.github.io/ko/tutorials/agents-md-comprehensive-tutorial-guide/"
---

⏱️ **예상 읽기 시간**: 15분

AI 에이전트로 코드를 생성할 때 "이게 이렇게 똑똑하면서도 동시에 이렇게 바보 같을 수가?"라고 생각해본 적이 있다면, 이 포괄적인 가이드가 바로 당신을 위한 것입니다. 잘 작성된 `AGENTS.md` 파일 하나로 AI 코딩 경험을 좌절스러운 추측 게임에서 일관되고 고품질의 결과물로 바꿀 수 있습니다.

## 목차

1. [AGENTS.md란 무엇인가?](#agentsmd란-무엇인가)
2. [문제점: 맥락 없는 AI](#문제점-맥락-없는-ai)
3. [단계별 AGENTS.md 작성법](#단계별-agentsmd-작성법)
4. [고급 설정 전략](#고급-설정-전략)
5. [실전 예제](#실전-예제)
6. [완전한 AGENTS.md 템플릿](#완전한-agentsmd-템플릿)
7. [모범 사례와 팁](#모범-사례와-팁)

## AGENTS.md란 무엇인가?

AGENTS.md는 프로젝트 루트에 위치하는 표준화된 마크다운 파일로, AI 도구에 프로젝트에 대한 필수적인 맥락을 제공합니다. "AI 에이전트를 위한 README"라고 생각하면 되며, 매번 프롬프트에서 프로젝트별 지침을 반복할 필요를 없애줍니다.

### AGENTS.md가 중요한 이유

도구별 설정 파일(`.cursorrules`, `.builderrules` 등)과 달리, AGENTS.md는 여러 AI 코딩 도구에서 지원하는 범용 표준이 되고 있습니다:

- **일관성**: 다양한 AI 도구에서 동일한 규칙 적용
- **효율성**: 매번 채팅에서 프로젝트 맥락을 반복하지 않아도 됨
- **품질**: 당신의 기준에 맞는 더 나은 코드 결과물
- **확장성**: 팀과 복잡한 코드베이스에서 작동

### 지원 도구

- Builder.io 에이전트
- Cursor (참조를 통해)
- Claude Projects
- GitHub Copilot Chat
- Replit Agent
- 파일 조회를 통한 기타 다수 도구

## 문제점: 맥락 없는 AI

### AGENTS.md 없이 발생하는 일반적인 문제들

AI 에이전트가 프로젝트 맥락을 모를 때 발생하는 상황들을 살펴보겠습니다:

#### 탐색 단계 오버헤드
```
사용자: "설정 페이지에 다크 모드 토글을 추가해줘"

AI 에이전트 프로세스:
1. 🔍 저장소 구조 탐색 (시간/토큰 소모)
2. 🤔 프레임워크와 의존성 추측
3. 📝 코딩 규칙 가정
4. 🎯 일반적인 해결책 제시
```

#### 일반적인 문제점들
- **잘못된 라이브러리 버전**: v5 프로젝트에서 MUI v4 문법 사용
- **일관성 없는 패턴**: 당신이 선호하는 Redux/Zustand 대신 `useState` 사용
- **스타일 충돌**: 디자인 토큰 대신 하드코딩된 색상
- **아키텍처 불일치**: 모듈 방식 대신 거대한 컴포넌트 생성
- **도구 혼동**: 내장 기능 대신 복잡한 우회 방법 생성

### 실제 예제: 다크 모드 재앙

AGENTS.md 없이 AI가 생성할 수 있는 코드:

```jsx
// ❌ 맥락 없이 AI가 생성한 코드
const DarkModeToggle = () => {
  const [isDark, setIsDark] = useState(false);
  
  return (
    <div style={% raw %}{{
      backgroundColor: isDark ? '#333' : '#fff',
      color: isDark ? '#fff' : '#333',
      padding: '16px'
    }}{% endraw %}>
      <button onClick={() => setIsDark(!isDark)}>
        다크 모드 전환
      </button>
    </div>
  );
};
```

**문제점들:**
- 하드코딩된 색상 (디자인 토큰을 사용해야 함)
- 기본 `useState` (당신의 상태 관리 도구를 사용해야 함)
- 인라인 스타일 (CSS-in-JS 솔루션을 사용해야 함)
- 접근성 기능 누락

## 단계별 AGENTS.md 작성법

### 1단계: 기본 구조 생성

이 최소 템플릿으로 시작하세요:

```markdown
# AGENTS.md

### Do (해야 할 것)
- [선호하는 관행들]

### Don't (하지 말아야 할 것)
- [피해야 할 것들]

### Commands (명령어)
- [파일 범위 명령어들]

### Safety and Permissions (안전 및 권한)
- [허용/제한 사항]

### Project Structure (프로젝트 구조)
- [주요 파일 위치]
```

### 2단계: Dos and Don'ts 정의

가장 중요한 섹션입니다. 구체적이고 주관적으로 작성하세요:

```markdown
### Do (해야 할 것)
- TypeScript와 함께 React 18+ 사용
- `src/styles/tokens.ts`의 디자인 토큰과 함께 Tailwind CSS 사용
- `create()` 문법으로 Zustand 상태 관리 사용
- 베이스 레이어로 Radix UI 컴포넌트 사용
- 작고 집중된 컴포넌트 생성 (최대 100줄)
- 서버 상태는 React Query 사용
- 상속보다 컴포지션 선호
- 복잡한 함수에 JSDoc 주석 작성

### Don't (하지 말아야 할 것)
- TypeScript에서 `any` 타입 사용 금지
- 색상, 간격, 브레이크포인트 하드코딩 금지
- 100줄 이상의 컴포넌트 생성 금지
- 데이터 가져오기에 `useEffect` 사용 금지 (React Query 사용)
- 비즈니스 로직과 UI 컴포넌트 혼합 금지
- 시맨틱 HTML이 존재할 때 `div` 사용 금지
- 승인 없이 새로운 의존성 추가 금지
```

### 3단계: 파일 범위 명령어 설정

느린 프로젝트 전체 빌드를 피하고 타겟 명령어를 사용하세요:

```markdown
### Commands (명령어)

# 단일 파일 타입 체크
npx tsc --noEmit path/to/file.tsx

# 단일 파일 포맷
npx prettier --write path/to/file.tsx

# 수정과 함께 단일 파일 린트
npx eslint --fix path/to/file.tsx

# 특정 테스트 파일 실행
npm run test path/to/file.test.tsx

# 전체 프로젝트 빌드 (신중하게 사용)
npm run build

참고: 수정된 파일에 대해 항상 타입 체킹, 포맷팅, 린트를 실행하세요.
명시적으로 요청된 경우에만 전체 빌드를 실행하세요.
```

### 4단계: 안전 및 권한 설정

AI가 자율적으로 할 수 있는 것을 제어하세요:

```markdown
### Safety and Permissions (안전 및 권한)

사전 승인 없이 허용:
- 모든 프로젝트 파일 읽기
- 단일 파일에 대한 린트, 포맷, 타입 체킹 실행
- 특정 파일에 대한 단위 테스트 실행
- `src/components/`에서 컴포넌트 파일 생성/수정
- 문서 파일 업데이트

승인 필요:
- 새로운 npm 패키지 설치
- package.json, tsconfig.json 또는 설정 파일 수정
- 전체 프로젝트 빌드나 e2e 테스트 실행
- 파일 삭제나 파일 권한 변경
- git 커밋이나 푸시
- CI/CD 워크플로우 수정
```

### 5단계: 프로젝트 구조 문서화

탐색을 위한 로드맵을 제공하세요:

```markdown
### Project Structure (프로젝트 구조)

주요 디렉토리:
- `src/components/` - 재사용 가능한 UI 컴포넌트
- `src/pages/` - 페이지 레벨 컴포넌트
- `src/hooks/` - 커스텀 React 훅
- `src/utils/` - 순수 유틸리티 함수
- `src/types/` - TypeScript 타입 정의
- `src/styles/` - 스타일링과 디자인 토큰

중요한 파일들:
- `src/App.tsx` - 메인 애플리케이션 컴포넌트
- `src/routes.tsx` - 애플리케이션 라우팅
- `src/styles/tokens.ts` - 디자인 시스템 토큰
- `src/utils/api.ts` - API 클라이언트 설정
```

### 6단계: 구체적인 예제 제공

실제 코드베이스에서 좋고 나쁜 패턴을 보여주세요:

```markdown
### Good and Bad Examples (좋은 예제와 나쁜 예제)

✅ 좋은 패턴들:
- 컴포넌트: `src/components/Button/Button.tsx` 구조 따르기
- API 호출: `src/hooks/useUsers.ts`의 패턴 사용
- 폼: `src/components/ContactForm.tsx` 접근법 복사
- 스타일링: `src/components/Card/Card.tsx` 참조

❌ 피해야 할 패턴들:
- `src/legacy/`의 레거시 클래스 컴포넌트
- 직접 fetch() 호출 (React Query 사용)
- 인라인 스타일 (Tailwind 클래스 사용)
- 하드코딩된 API URL (환경 변수 사용)
```

## 고급 설정 전략

### API 문서 통합

```markdown
### API Reference (API 참조)

베이스 URL: `VITE_API_BASE_URL` 환경 변수 사용

엔드포인트:
- GET /api/users - 사용자 목록 (페이지네이션)
- POST /api/users - 사용자 생성
- GET /api/users/:id - 사용자 상세 정보
- PATCH /api/users/:id - 사용자 업데이트

인증: `useAuth()` 훅을 통한 Bearer 토큰
에러 처리: `src/utils/errors.ts`의 `ApiError` 클래스 사용

예제: 사용 패턴은 `src/hooks/api/` 참조
```

### 테스트 우선 개발 모드

```markdown
### Test-First Mode (테스트 우선 모드)

새로운 기능의 경우:
1. Jest와 React Testing Library를 사용해 실패하는 테스트를 먼저 작성
2. 테스트를 통과하는 최소한의 코드 구현
3. 테스트를 그린 상태로 유지하며 리팩토링

테스트 패턴:
- 컴포넌트 테스트: `src/components/Button/Button.test.tsx` 따르기
- 훅 테스트: `src/hooks/useLocalStorage/useLocalStorage.test.ts` 따르기
- 통합 테스트: API 모킹에 MSW 사용

커버리지 요구사항: 새로운 코드에 대해 >80% 유지
```

### 디자인 시스템 통합

```markdown
### Design System (디자인 시스템)

컴포넌트: `@company/design-system`의 컴포넌트 사용
토큰: `@company/design-system/tokens`에서 가져오기

사용 가능한 컴포넌트:
- Button: `<Button variant="primary" size="md" />`
- Input: `<Input placeholder="텍스트 입력" error="에러 메시지" />`
- Modal: `<Modal isOpen={true} onClose={handleClose} />`

문서: 전체 API는 `docs/design-system/` 참조
Figma: 컴포넌트가 Figma 라이브러리와 정확히 일치

커스텀 스타일링: 디자인 시스템 스타일을 덮어쓰지 말고 확장만 하기
```

### PR 및 코드 리뷰 가이드라인

```markdown
### Pull Request Checklist (풀 리퀘스트 체크리스트)

PR 생성 전:
- [ ] 모든 테스트가 로컬에서 통과
- [ ] Prettier로 코드 포맷팅
- [ ] TypeScript 오류 없음
- [ ] 린트 경고 없음
- [ ] 컴포넌트가 JSDoc으로 문서화됨
- [ ] WCAG 2.1 AA에 따른 접근성 준수

PR 요구사항:
- 작고 집중된 변경사항 (< 400줄)
- 변경사항에 대한 명확한 설명
- UI 변경사항에 대한 스크린샷
- 해당하는 경우 성능 영향 언급

리뷰 기준:
- 기존 패턴을 따르는 코드
- 적절한 에러 처리
- 반응형 디자인 구현
- 크로스 브라우저 호환성 고려
```

## 실전 예제

### 예제 1: 전자상거래 프로젝트

```markdown
# AGENTS.md

### Do (해야 할 것)
- App Router와 함께 Next.js 14+ 사용
- GraphQL과 함께 Shopify Storefront API 사용
- 커스텀 디자인 토큰과 함께 Tailwind CSS 사용
- Zod 검증과 함께 React Hook Form 사용
- 애니메이션에 Framer Motion 사용
- 반응형 디자인 생성 (모바일 우선)
- Next.js Image 컴포넌트로 이미지 최적화

### Don't (하지 말아야 할 것)
- Pages Router 사용 금지 (App Router 사용)
- 폼 검증 우회 금지
- Framer Motion 외 다른 애니메이션 라이브러리 사용 금지
- 제품 ID나 API 키 하드코딩 금지

### Commands (명령어)
npx next lint --fix --file path/to/file.tsx
npx prettier --write path/to/file.tsx
npm run type-check
npm run test:unit path/to/file.test.tsx

### Project Structure (프로젝트 구조)
- `app/` - Next.js App Router 페이지
- `components/` - 재사용 가능한 UI 컴포넌트
- `lib/shopify/` - Shopify API 통합
- `hooks/` - 장바구니, 사용자 등을 위한 커스텀 React 훅

### Good Examples (좋은 예제)
- 제품 페이지: `app/products/[handle]/page.tsx`
- 장바구니 로직: `hooks/useCart.ts`
- 폼 처리: `components/ContactForm.tsx`
```

### 예제 2: SaaS 대시보드

```markdown
# AGENTS.md

### Do (해야 할 것)
- TypeScript와 함께 React 18 사용
- 서버 상태에 React Query 사용
- 네비게이션에 React Router v6 사용
- 데이터 시각화에 Chart.js 사용
- 폼에 React Hook Form + Yup 사용
- 아토믹 디자인 원칙 따르기
- 적절한 에러 바운더리 구현

### Don't (하지 말아야 할 것)
- 클래스 컴포넌트 사용 금지
- UI 컴포넌트에 비즈니스 로직 혼합 금지
- 적절한 TypeScript 타입 없이 컴포넌트 생성 금지
- JSX에서 인라인 이벤트 핸들러 사용 금지

### API Integration (API 통합)
베이스 URL: `process.env.REACT_APP_API_URL`
인증: `useAuth()` 훅을 통한 JWT 토큰

주요 엔드포인트:
- `/dashboard/metrics` - 대시보드 데이터
- `/users/profile` - 사용자 정보
- `/projects` - 프로젝트 CRUD 작업

### Performance Requirements (성능 요구사항)
- 번들 크기 < 1MB gzipped
- First Contentful Paint < 2s
- Time to Interactive < 3s
- Lighthouse 점수 > 90
```

## 완전한 AGENTS.md 템플릿

프로젝트에 맞게 커스터마이징할 수 있는 포괄적인 템플릿입니다:

```markdown
# AGENTS.md

## 프로젝트 개요
프로젝트, 기술 스택, 목표에 대한 간단한 설명.

### Do (해야 할 것)
- [프레임워크] 버전 X.Y+ 사용
- 애플리케이션 상태에 [상태 관리] 사용
- [위치]의 디자인 토큰과 함께 [스타일링 솔루션] 사용
- 베이스 컴포넌트로 [컴포넌트 라이브러리] 사용
- 컴포넌트 구조에 [아키텍처 패턴] 따르기
- 작고 집중된 컴포넌트 생성 (최대 [X]줄)
- 모든 테스트에 [테스팅 라이브러리] 사용
- 적절한 에러 처리와 로딩 상태 구현
- 접근성 가이드라인 준수 (WCAG 2.1 AA)

### Don't (하지 말아야 할 것)
- 폐기된 API나 패턴 사용 금지
- 값 하드코딩 금지 (상수/환경 변수 사용)
- 크고 모놀리식한 컴포넌트 생성 금지
- 비즈니스 로직과 프레젠테이션 혼합 금지
- 에러 처리나 로딩 상태 건너뛰기 금지
- TypeScript에서 `any` 타입 사용 금지
- 팀 승인 없이 의존성 추가 금지

### Commands (명령어)

# 개발 명령어
npm run dev                              # 개발 서버 시작
npm run type-check                       # TypeScript 타입 체킹
npm run lint:check                       # 린터 실행
npm run lint:fix                         # 린터 이슈 수정
npm run format                           # Prettier로 포맷

# 파일 범위 명령어 (선호됨)
npx tsc --noEmit path/to/file.tsx        # 단일 파일 타입 체크
npx eslint --fix path/to/file.tsx        # 단일 파일 린트
npx prettier --write path/to/file.tsx    # 단일 파일 포맷

# 테스팅
npm run test                             # 모든 테스트 실행
npm run test:watch                       # 워치 모드
npm run test path/to/file.test.tsx       # 특정 테스트 실행
npm run test:coverage                    # 커버리지 리포트

# 빌드 및 배포
npm run build                            # 프로덕션 빌드
npm run preview                          # 프로덕션 빌드 미리보기

참고: 더 빠른 피드백 루프를 위해 파일 범위 명령어를 선호합니다.

### Safety and Permissions (안전 및 권한)

프롬프트 없이 허용:
- 프로젝트 파일과 문서 읽기
- 로컬에서 개발 서버 실행
- 린트, 포맷, 타입 체킹 실행
- 특정 파일이나 컴포넌트의 단위 테스트 실행
- 프로젝트 구조를 따라 컴포넌트 파일 생성/수정
- 컴포넌트 문서와 README 파일 업데이트

승인 필요:
- npm 패키지 설치나 업데이트
- 설정 파일 수정 (package.json, tsconfig.json 등)
- 전체 프로젝트 빌드나 end-to-end 테스트 실행
- CI/CD 워크플로우 변경
- 파일 삭제나 파일 권한 변경
- 버전 관리에 커밋하거나 변경사항 푸시
- 데이터베이스 스키마나 API 계약 수정

### Project Structure (프로젝트 구조)

```
src/
├── components/          # 재사용 가능한 UI 컴포넌트
│   ├── ui/             # 베이스 UI 컴포넌트 (버튼, 입력 등)
│   ├── forms/          # 폼 전용 컴포넌트
│   └── layout/         # 레이아웃 컴포넌트 (헤더, 사이드바 등)
├── pages/              # 페이지 레벨 컴포넌트
├── hooks/              # 커스텀 React 훅
├── services/           # API 호출과 외부 서비스
├── utils/              # 순수 유틸리티 함수
├── types/              # TypeScript 타입 정의
├── constants/          # 애플리케이션 상수
├── styles/             # 글로벌 스타일과 디자인 토큰
└── tests/              # 테스트 유틸리티와 설정
```

주요 파일들:
- `src/App.tsx` - 메인 애플리케이션 컴포넌트
- `src/main.tsx` - 애플리케이션 진입점
- `src/router.tsx` - 애플리케이션 라우팅 설정
- `src/styles/globals.css` - 글로벌 스타일과 CSS 변수
- `src/types/index.ts` - 공유 TypeScript 타입
- `src/utils/api.ts` - API 클라이언트 설정

### Good and Bad Examples (좋은 예제와 나쁜 예제)

✅ 이런 패턴들을 따르세요:
- 컴포넌트 구조: `src/components/ui/Button/Button.tsx`
- 커스텀 훅: `src/hooks/useLocalStorage/useLocalStorage.ts`
- API 통합: `src/services/userService.ts`
- 폼 처리: `src/components/forms/LoginForm.tsx`
- 에러 바운더리: `src/components/ErrorBoundary.tsx`

❌ 이런 패턴들을 피하세요:
- `src/legacy/`의 레거시 클래스 컴포넌트
- 컴포넌트에서 직접 API 호출 (서비스 사용)
- 인라인 스타일 (CSS 모듈이나 styled-components 사용)
- 거대한 컴포넌트 (작은 조각으로 나누기)

### API Documentation (API 문서)

베이스 URL: `process.env.VITE_API_BASE_URL`
인증: `useAuth()` 훅을 통한 Bearer 토큰

일반적인 엔드포인트:
- `GET /api/users` - 사용자 목록 가져오기
- `POST /api/users` - 새 사용자 생성
- `GET /api/users/:id` - ID로 사용자 가져오기
- `PUT /api/users/:id` - 사용자 업데이트
- `DELETE /api/users/:id` - 사용자 삭제

에러 처리: `src/utils/errors.ts`의 `ApiError` 클래스 사용
응답 형식: 모든 엔드포인트는 `{ data, error, message }` 구조 반환

### Design System (디자인 시스템)

컴포넌트 라이브러리: [라이브러리명] v[X.Y.Z]
디자인 토큰: `src/styles/tokens.ts`에서 가져오기
아이콘: `@heroicons/react` 또는 `lucide-react` 사용

사용 가능한 컴포넌트:
- `<Button variant="primary|secondary|outline" size="sm|md|lg" />`
- `<Input type="text|email|password" error="에러 메시지" />`
- `<Modal isOpen={boolean} onClose={function} title="모달 제목" />`
- `<Toast type="success|error|warning|info" message="토스트 메시지" />`

테마: CSS 커스텀 속성을 통한 라이트/다크 모드 지원
반응형: 정의된 브레이크포인트와 함께 모바일 우선 접근법

### Testing Guidelines (테스팅 가이드라인)

프레임워크: Jest + React Testing Library
커버리지: 새로운 코드에 대해 >80% 유지
테스트 타입:
- 단위 테스트: 개별 컴포넌트/함수 테스트
- 통합 테스트: 컴포넌트 상호작용 테스트
- E2E 테스트: 중요한 사용자 여정 테스트 (Playwright)

테스트 파일 명명:
- `ComponentName.test.tsx` - 컴포넌트 테스트
- `utils.test.ts` - 유틸리티 함수 테스트
- `hooks.test.ts` - 커스텀 훅 테스트

모킹:
- API 호출: MSW (Mock Service Worker) 사용
- 외부 서비스: `src/tests/mocks/`에서 모킹
- 환경 변수: 테스트 설정에서 재정의

### Performance Guidelines (성능 가이드라인)

번들 크기 목표:
- 메인 번들: < 250KB gzipped
- 총 초기 로드: < 1MB gzipped

Core Web Vitals 목표:
- Largest Contentful Paint (LCP): < 2.5s
- First Input Delay (FID): < 100ms
- Cumulative Layout Shift (CLS): < 0.1

최적화 전략:
- 코드 분할에 React.lazy() 사용
- 적절한 이미지 최적화 구현
- 비싼 컴포넌트에 React.memo() 사용
- useMemo/useCallback으로 리렌더링 최소화

### Pull Request Guidelines (풀 리퀘스트 가이드라인)

PR 크기: 가능하면 변경사항을 400줄 이하로 유지
커밋 메시지: conventional commits 형식 따르기

PR 전 필수 체크:
- [ ] 모든 테스트가 로컬에서 통과
- [ ] TypeScript 오류 없음
- [ ] 린트 경고 없음
- [ ] 컴포넌트가 적절히 문서화됨
- [ ] 성능 영향 평가됨
- [ ] 접근성 요구사항 충족

PR 설명에 포함되어야 할 사항:
- 변경사항 요약
- UI 변경에 대한 스크린샷
- 테스트 지침
- 호환성을 깨는 변경사항 (있는 경우)

### Error Handling (에러 처리)

글로벌 에러 바운더리: 처리되지 않은 React 에러 캐치
API 에러: 적절한 HTTP 코드와 함께 표준화된 에러 응답
폼 검증: 서버측 백업과 함께 클라이언트측 검증
로딩 상태: 적절한 로딩 인디케이터 표시

에러 리포팅: 프로덕션 에러 추적에 Sentry 사용
사용자 메시징: 사용자 친화적인 에러 메시지 표시

### Accessibility Requirements (접근성 요구사항)

모든 컴포넌트에 WCAG 2.1 AA 준수 필요
도구: 자동화된 테스트에 axe-core 사용

주요 요구사항:
- 적절한 시맨틱 HTML
- 키보드 네비게이션 지원
- 스크린 리더 호환성
- 색상 대비 비율 ≥ 4.5:1
- 모달/드롭다운의 포커스 관리
- 이미지의 대체 텍스트

### Environment Configuration (환경 설정)

개발: `npm run dev`로 로컬 개발 서버 시작
스테이징: `develop` 브랜치로 푸시 시 자동 배포
프로덕션: `main` 브랜치로 푸시 시 자동 배포

환경 변수:
- `VITE_API_BASE_URL` - API 엔드포인트 URL
- `VITE_APP_ENV` - 환경 식별자
- `VITE_SENTRY_DSN` - 에러 리포팅 설정

### When Stuck (막혔을 때)

구현 세부사항에 대해 확실하지 않다면:
1. 요구사항에 대한 명확한 질문하기
2. 간단한 구현 계획 제안하기
3. 코드베이스의 유사한 패턴 참조하기
4. 토론을 위해 댓글과 함께 초안 PR 생성하기

확인 없이 큰 추측성 변경을 하지 마세요.

### Additional Resources (추가 자료)

- 프로젝트 문서: `/docs/`
- 컴포넌트 Storybook: `npm run storybook`
- API 문서: `/docs/api.md`
- 기여 가이드라인: `/CONTRIBUTING.md`
- 코드 스타일 가이드: `/docs/style-guide.md`
```

## 모범 사례와 팁

### 1. 작게 시작해서 반복하기

가장 큰 문제점에 집중한 최소한의 AGENTS.md로 시작하세요:

```markdown
# AGENTS.md - v1.0

### Do (해야 할 것)
- 모든 새 코드에 TypeScript 사용
- 기존 컴포넌트 패턴 따르기

### Don't (하지 말아야 할 것)
- `any` 타입 사용 금지
- 200줄 이상의 파일 생성 금지

### Commands (명령어)
npx tsc --noEmit path/to/file.tsx
```

그 다음 변경하고 싶은 AI 동작을 기반으로 확장하세요.

### 2. 구체적인 예제 사용

추상적인 규칙 대신 실제 파일을 가리키세요:

```markdown
❌ 추상적: "좋은 컴포넌트 패턴 따르기"
✅ 구체적: "src/components/Button/Button.tsx 구조 복사하기"
```

### 3. 주관적이고 구체적으로 작성

단순히 "모범 사례를 사용하라"고 하지 말고 프로젝트에서 그것이 무엇을 의미하는지 정의하세요:

```markdown
❌ 모호함: "좋은 테스트 작성하기"
✅ 구체적: "React Testing Library로 컴포넌트 테스트, MSW로 API 호출 모킹"
```

### 4. AGENTS.md 버전 관리

프로젝트가 발전함에 따라 AI 지침도 함께 발전해야 합니다:

```markdown
# AGENTS.md - v2.1

<!-- Changelog:
v2.1 - React Query 패턴 추가
v2.0 - TypeScript로 마이그레이션
v1.0 - 초기 버전
-->
```

### 5. 팀 협업

AGENTS.md를 팀이 유지관리하는 살아있는 문서로 만드세요:

- 회고 중 정기 검토
- 새로운 도구/패턴 채택 시 업데이트
- 팀 멤버 간 공유 소유권

### 6. 도구별 적응

AGENTS.md를 기본적으로 지원하지 않는 도구들을 위해:

```markdown
# .cursorrules
./AGENTS.md의 모든 규칙과 가이드라인을 엄격히 따르세요

# claude.md  
AGENTS.md에 명시된 프로젝트 가이드라인을 따라주세요
```

### 7. 측정하고 조정하기

AGENTS.md의 영향을 추적하세요:

- **전후 비교**: AI 결과물의 전후 예제 저장
- **팀 피드백**: AI 지원 품질에 대한 정기 체크인
- **반복 주기**: 반복되는 문제를 기반으로 규칙 업데이트

### 8. 피해야 할 일반적인 함정들

**너무 길게**: 집중을 유지하세요 - 긴 파일은 무시됩니다
```markdown
❌ 모든 엣지 케이스를 다루는 50개 이상의 규칙
✅ 80%의 문제를 해결하는 10-15개의 핵심 규칙
```

**너무 모호하게**: 요구사항에 대해 구체적으로 작성하세요
```markdown
❌ "좋은 에러 처리 사용"
✅ "모든 API 호출에 ApiError 클래스와 함께 try-catch 블록 사용"
```

**도구별**: 일반적인 원칙에 집중하세요
```markdown
❌ "Cursor의 자동 완성 기능 사용"
✅ "와일드카드 가져오기보다 명시적 가져오기 선호"
```

**정적 규칙**: 프로젝트가 발전함에 따라 업데이트하세요
```markdown
✅ 새로운 패턴을 기반으로 한 정기 검토 및 업데이트
```

## 파워 유저를 위한 고급 팁

### 1. 맥락 인식 규칙

작업 유형에 따른 조건부 가이드라인 생성:

```markdown
### Context-Specific Guidelines (맥락별 가이드라인)

새로운 기능의 경우:
- 테스트를 먼저 작성 (TDD 접근법)
- TypeScript 인터페이스로 시작
- UI 컴포넌트를 위한 Storybook 스토리 생성

버그 수정의 경우:
- 회귀 테스트 추가
- 근본 원인 문서화
- 관련 문서 업데이트

리팩토링의 경우:
- 기존 API 계약 유지
- 변경사항을 반영하도록 테스트 업데이트
- 호환성을 깨는 변경에 대해 폐기 경고 사용
```

### 2. 개발 워크플로우와의 통합

```markdown
### Workflow Integration (워크플로우 통합)

pre-commit 훅:
- 스테이징된 파일에 `npm run lint:fix` 실행
- TypeScript 파일에 `npm run type-check` 실행
- 변경된 파일에 대한 관련 테스트 실행

CI/CD 고려사항:
- 모든 AGENTS.md 규칙이 CI에서 강제됨
- 실패한 체크는 PR 병합을 차단
- 성능 예산이 모니터링됨
```

### 3. 메트릭과 모니터링

```markdown
### Quality Metrics (품질 메트릭)

코드 품질을 위해 다음 메트릭을 추적:
- 번들 크기 영향 (webpack-bundle-analyzer 사용)
- TypeScript strict 모드 준수
- 테스트 커버리지 비율
- 접근성 위반 (axe-core 사용)
- 성능 점수 (Lighthouse CI)

허용 가능한 임계값:
- PR당 번들 크기 증가: < 5%
- 새로운 코드의 테스트 커버리지: > 80%
- 중요 페이지의 성능 점수: > 90
```

## 결론

잘 작성된 AGENTS.md 파일은 AI 지원 개발의 게임 체인저입니다. 일반적인 코드 생성기에서 당신의 특정 요구사항, 제약사항, 선호도를 이해하는 프로젝트 인식 어시스턴트로 AI 도구를 변환시킵니다.

### 핵심 요점

1. **단순하게 시작**: 기본적인 dos/don'ts로 시작해서 시간이 지나면서 확장
2. **구체적으로 작성**: 구체적인 예제와 파일 참조 사용
3. **최신 상태 유지**: 프로젝트가 발전함에 따라 정기 업데이트
4. **팀 소유권**: 공유 책임으로 만들기
5. **영향 측정**: AI 결과물 품질의 개선 추적

### 다음 단계

1. **첫 번째 AGENTS.md 생성**: 제공된 템플릿으로 시작
2. **AI 도구로 테스트**: 일반적인 프롬프트를 실행하고 결과 비교
3. **결과를 기반으로 반복**: AI 동작을 바탕으로 규칙 세분화
4. **팀과 공유**: 의견을 받고 유지관리 프로세스 수립
5. **모니터링 및 개선**: 정기 검토 및 업데이트

기억하세요: 목표는 첫날부터 완벽한 AI 지침을 작성하는 것이 아닙니다. 개발 경험을 개선하고 특정 프로젝트와 팀에 가장 적합한 것을 배워가면서 점진적으로 더 세밀해지는 기초를 만드는 것입니다.

### 추가 자료

- [AGENTS.md GitHub 저장소](https://github.com/AI-Engineer-Foundation/agents.md)
- [Builder.io 블로그 포스트](https://www.builder.io/blog/agents-md)
- [커뮤니티 예제](https://github.com/topics/agents-md)

AI와 함께 즐거운 코딩 되세요! 🚀

---

*이 튜토리얼은 포괄적인 AI 개발 시리즈의 일부입니다. AI 지원 개발, 자동화, 생산성 도구에 대한 다른 튜토리얼들도 확인해보세요.*
