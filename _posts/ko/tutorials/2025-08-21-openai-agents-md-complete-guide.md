---
title: "OpenAI AGENTS.md 완전 가이드: AI 코딩 에이전트를 위한 새로운 표준"
excerpt: "AGENTS.md는 AI 코딩 에이전트를 위한 간단하고 열린 형식의 가이드라인입니다. README.md를 보완하여 에이전트가 프로젝트에서 효과적으로 작업할 수 있도록 도와줍니다."
seo_title: "AGENTS.md 완전 가이드 - AI 코딩 에이전트 표준 포맷 - Thaki Cloud"
seo_description: "OpenAI가 제안한 AGENTS.md 형식을 활용하여 AI 코딩 에이전트의 효율성을 극대화하는 방법을 실제 예제와 함께 알아보세요."
date: 2025-08-21
last_modified_at: 2025-08-21
categories:
  - tutorials
tags:
  - AGENTS.md
  - OpenAI
  - AI코딩에이전트
  - 개발도구
  - 자동화
  - Next.js
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/openai-agents-md-complete-guide/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 8분

## 서론

AI 코딩 에이전트가 널리 사용되면서, 프로젝트에 대한 명확한 가이드라인을 제공하는 것이 중요해졌습니다. OpenAI가 제안한 [AGENTS.md](https://github.com/openai/agents.md) 형식은 이러한 필요를 충족시키는 혁신적인 해결책입니다.

**AGENTS.md란?**
- AI 코딩 에이전트를 위한 간단하고 열린 형식의 가이드라인
- "README for agents"라고 생각할 수 있는 전용 문서
- 현재 [20,000개 이상의 오픈소스 프로젝트](https://github.com/search?q=path%3AAGENTS.md&type=code)에서 사용 중

이 튜토리얼에서는 AGENTS.md의 개념부터 실제 구현까지 완전히 다뤄보겠습니다.

## AGENTS.md가 필요한 이유

### 1. README.md의 한계

README.md 파일은 **인간 개발자**를 위한 문서입니다:
- 프로젝트 개요
- 빠른 시작 가이드  
- 기여 가이드라인

하지만 AI 에이전트는 더 상세하고 구체적인 정보가 필요합니다:
- 빌드 및 테스트 명령어
- 코딩 컨벤션
- 특별한 주의사항
- 에이전트별 실행 지침

### 2. 에이전트 호환성

하나의 AGENTS.md 파일로 다양한 AI 코딩 도구에서 사용 가능:
- **OpenAI Codex**
- **Cursor**
- **Jules (Google)**
- **Amp**
- **Factory**
- **RooCode**

## 실제 프로젝트에서 AGENTS.md 테스트

### 테스트 환경 설정

실제 OpenAI의 agents.md 프로젝트를 클론하고 테스트해보겠습니다:

```bash
# 테스트 디렉토리 생성
mkdir -p tutorials/agents-md-test
cd tutorials/agents-md-test

# OpenAI agents.md 프로젝트 클론
git clone https://github.com/openai/agents.md.git openai-agents-md
cd openai-agents-md

# 종속성 설치
npm install

# 개발 서버 실행
npm run dev &
```

### 웹사이트 동작 확인

개발 서버가 실행되면 `http://localhost:3000`에서 확인할 수 있습니다:

```bash
# 서버 응답 확인
curl -s http://localhost:3000 | head -10
```

**실행 결과:**
```html
<!DOCTYPE html><html lang="en"><head><meta charSet="utf-8" data-next-head=""/>
<meta name="viewport" content="width=device-width" data-next-head=""/>
<title data-next-head="">AGENTS.md</title>
<meta name="description" content="AGENTS.md is a simple, open format for guiding coding agents, used by over 20k open-source projects. Think of it as a README for agents." data-next-head=""/>
```

✅ **테스트 성공:** Next.js 기반 웹사이트가 정상적으로 동작합니다.

## AGENTS.md 파일 구조 분석

### OpenAI 프로젝트의 실제 AGENTS.md

```markdown
# AGENTS Guidelines for This Repository

This repository contains a Next.js application located in the root of this repository. When
working on the project interactively with an agent (e.g. the Codex CLI) please follow
the guidelines below so that the development experience – in particular Hot Module
Replacement (HMR) – continues to work smoothly.

## 1. Use the Development Server, **not** `npm run build`

* **Always use `npm run dev` (or `pnpm dev`, `yarn dev`, etc.)** while iterating on the
  application.  This starts Next.js in development mode with hot-reload enabled.
* **Do _not_ run `npm run build` inside the agent session.**  Running the production
  build command switches the `.next` folder to production assets which disables hot
  reload and can leave the development server in an inconsistent state.

## 2. Keep Dependencies in Sync

If you add or update dependencies remember to:

1. Update the appropriate lockfile (`package-lock.json`, `pnpm-lock.yaml`, `yarn.lock`).
2. Re-start the development server so that Next.js picks up the changes.

## 3. Coding Conventions

* Prefer TypeScript (`.tsx`/`.ts`) for new components and utilities.
* Co-locate component-specific styles in the same folder as the component when
  practical.

## 4. Useful Commands Recap

| Command            | Purpose                                            |
| ------------------ | -------------------------------------------------- |
| `npm run dev`      | Start the Next.js dev server with HMR.             |
| `npm run lint`     | Run ESLint checks.                                 |
| `npm run test`     | Execute the test suite (if present).               |
| `npm run build`    | **Production build – _do not run during agent sessions_** |
```

### 주요 특징 분석

1. **명확한 명령어 가이드**: 에이전트가 실행해야 할 정확한 명령어 제시
2. **주의사항 명시**: `npm run build` 사용 금지 등 중요한 제약사항
3. **워크플로우 최적화**: HMR 등 개발 환경 최적화 방법
4. **구체적인 지침**: 추상적이 아닌 실행 가능한 지침

## 샘플 프로젝트로 AGENTS.md 실습

### Express.js API 서버 예제

실제 프로젝트에 적용할 수 있는 AGENTS.md를 만들어보겠습니다:

```bash
# 샘플 프로젝트 생성
mkdir sample-project
cd sample-project
```

### package.json 설정

```json
{
  "name": "sample-project",
  "version": "1.0.0",
  "description": "Sample project for AGENTS.md demonstration",
  "main": "index.js",
  "scripts": {
    "dev": "node index.js",
    "test": "jest",
    "lint": "eslint .",
    "build": "webpack --mode production"
  },
  "dependencies": {
    "express": "^4.18.0"
  },
  "devDependencies": {
    "jest": "^29.0.0",
    "eslint": "^8.0.0",
    "webpack": "^5.0.0"
  }
}
```

### 완성된 AGENTS.md 예제

```markdown
# AGENTS.md

## 프로젝트 개요
Express.js를 사용한 간단한 웹 API 서버입니다.

## 개발 환경 설정
- Node.js 18+ 필요
- npm install로 종속성 설치
- npm run dev로 개발 서버 시작

## 빌드 및 테스트 명령어
- `npm run dev` - 개발 서버 시작 (포트 3000)
- `npm run test` - Jest 테스트 실행
- `npm run lint` - ESLint 코드 검사
- `npm run build` - 프로덕션 빌드

## 코딩 컨벤션
- JavaScript ES6+ 사용
- 2스페이스 들여쓰기
- 세미콜론 사용
- camelCase 변수명
- 함수는 async/await 패턴 선호

## 테스트 지침
- 모든 API 엔드포인트에 대한 테스트 작성 필수
- __tests__ 폴더에 테스트 파일 위치
- 테스트 파일명: *.test.js 형식
- 커버리지 80% 이상 유지

## API 엔드포인트
- GET /api/health - 헬스체크
- GET /api/users - 사용자 목록 조회
- POST /api/users - 사용자 생성
- GET /api/users/:id - 특정 사용자 조회

## 보안 고려사항
- 입력 검증 필수 (express-validator 사용)
- API 키는 환경변수로 관리
- CORS 설정 확인
- Rate limiting 적용

## PR 가이드라인
- 브랜치명: feature/기능명 또는 fix/버그명
- 커밋 메시지: type(scope): description 형식
- 테스트 통과 후 PR 생성
- 코드 리뷰 2명 이상 승인 필요
```

### Express.js 서버 구현

```javascript
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Sample users data
let users = [
  { id: 1, name: 'John Doe', email: 'john@example.com' },
  { id: 2, name: 'Jane Smith', email: 'jane@example.com' }
];

// Get all users
app.get('/api/users', (req, res) => {
  res.json(users);
});

// Get user by ID
app.get('/api/users/:id', (req, res) => {
  const user = users.find(u => u.id === parseInt(req.params.id));
  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }
  res.json(user);
});

// Create new user
app.post('/api/users', (req, res) => {
  const { name, email } = req.body;
  if (!name || !email) {
    return res.status(400).json({ error: 'Name and email are required' });
  }
  
  const newUser = {
    id: users.length + 1,
    name,
    email
  };
  
  users.push(newUser);
  res.status(201).json(newUser);
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

module.exports = app;
```

## AGENTS.md 모범 사례

### 1. 필수 섹션들

**프로젝트 개요**
```markdown
## 프로젝트 개요
- 프로젝트의 목적과 주요 기능
- 사용된 기술 스택
- 아키텍처 개요
```

**설치 및 실행**
```markdown
## 설치 및 실행
- 필요한 시스템 요구사항
- 종속성 설치 명령어
- 개발 서버 실행 방법
```

**빌드 및 테스트**
```markdown
## 빌드 및 테스트
- `npm run build` - 프로덕션 빌드
- `npm run test` - 테스트 실행
- `npm run lint` - 코드 검사
```

### 2. 코딩 컨벤션

**스타일 가이드**
```markdown
## 코딩 컨벤션
- 들여쓰기: 2스페이스 또는 4스페이스
- 세미콜론 사용 여부
- 변수명 규칙 (camelCase, snake_case 등)
- 파일 구조 및 네이밍 규칙
```

### 3. 특별 지침

**주의사항**
```markdown
## 주의사항
- 절대 하지 말아야 할 명령어
- 특별한 환경변수 설정
- 보안 관련 고려사항
```

## 대규모 프로젝트에서의 활용

### 모노레포 구조

```
project-root/
├── AGENTS.md          # 루트 레벨 가이드
├── packages/
│   ├── api/
│   │   └── AGENTS.md  # API 서버 전용 가이드
│   ├── web/
│   │   └── AGENTS.md  # 웹 앱 전용 가이드
│   └── mobile/
│       └── AGENTS.md  # 모바일 앱 전용 가이드
```

### 계층적 가이드라인

1. **루트 AGENTS.md**: 전체 프로젝트 공통 규칙
2. **패키지별 AGENTS.md**: 특정 기술 스택 규칙
3. **우선순위**: 가장 가까운 AGENTS.md가 우선

## 실무 적용 팁

### 1. 기존 문서 마이그레이션

```bash
# 기존 문서를 AGENTS.md로 변경
mv CONTRIBUTING.md AGENTS.md

# 호환성을 위한 심볼릭 링크 생성
ln -s AGENTS.md CONTRIBUTING.md
```

### 2. 에이전트별 최적화

**Cursor용 최적화**
```markdown
## Cursor 설정
- TypeScript strict 모드 사용
- Auto-import 활성화
- Format on save 설정
```

**GitHub Copilot용 최적화**
```markdown
## GitHub Copilot 가이드
- JSDoc 주석 스타일 유지
- 함수명은 명확하게 작성
- 예외 처리 패턴 일관성 유지
```

### 3. 자동화 스크립트

**AGENTS.md 검증 스크립트**
```bash
#!/bin/bash
# validate-agents-md.sh

if [ ! -f "AGENTS.md" ]; then
    echo "❌ AGENTS.md 파일이 없습니다."
    exit 1
fi

echo "✅ AGENTS.md 파일이 존재합니다."

# 필수 섹션 확인
REQUIRED_SECTIONS=("프로젝트 개요" "빌드 및 테스트" "코딩 컨벤션")

for section in "${REQUIRED_SECTIONS[@]}"; do
    if grep -q "## $section" AGENTS.md; then
        echo "✅ '$section' 섹션 발견"
    else
        echo "❌ '$section' 섹션이 누락되었습니다."
        exit 1
    fi
done

echo "🎉 AGENTS.md 검증 완료!"
```

## 커뮤니티 및 생태계

### 1. 주요 채택 프로젝트들

- **OpenAI Codex**: 범용 CLI 도구
- **Apache Airflow**: 워크플로우 관리 플랫폼  
- **Temporal SDK**: 워크플로우 오케스트레이션
- **PlutoLang**: Lua 수퍼셋 언어

### 2. 에이전트 도구 호환성

| 도구 | 호환성 | 특징 |
|------|--------|------|
| OpenAI Codex | ✅ 완전 | 네이티브 지원 |
| Cursor | ✅ 완전 | 자동 인식 |
| Jules (Google) | ✅ 완전 | 기본 내장 |
| GitHub Copilot | 🔄 부분 | 컨텍스트 활용 |

### 3. 확장 가능성

**플러그인 생태계**
- VS Code 확장
- IntelliJ 플러그인
- Vim/Neovim 플러그인

## FAQ

### Q1: README.md와 AGENTS.md의 차이점은?

**README.md**: 인간 개발자를 위한 문서
- 프로젝트 소개
- 빠른 시작 가이드
- 라이선스 정보

**AGENTS.md**: AI 에이전트를 위한 문서
- 상세한 명령어
- 코딩 컨벤션
- 자동화 지침

### Q2: 필수 필드가 있나요?

아니요. AGENTS.md는 표준 마크다운 형식이므로 자유롭게 구성할 수 있습니다. 하지만 다음 섹션들을 권장합니다:
- 프로젝트 개요
- 설치 및 실행
- 빌드 및 테스트
- 코딩 컨벤션

### Q3: 여러 AGENTS.md가 충돌하면?

우선순위 규칙:
1. 편집 중인 파일에 가장 가까운 AGENTS.md
2. 사용자의 명시적 채팅 프롬프트
3. 상위 디렉토리의 AGENTS.md

### Q4: 에이전트가 자동으로 테스트를 실행하나요?

네, AGENTS.md에 테스트 명령어가 명시되어 있으면 에이전트가 자동으로 실행하고 실패 시 수정을 시도합니다.

## macOS에서 실습 환경 구축

### 개발 환경 설정

```bash
# Node.js 설치 (이미 설치되어 있다면 생략)
brew install node

# 프로젝트 디렉토리 생성
mkdir ~/agents-md-practice
cd ~/agents-md-practice

# OpenAI agents.md 프로젝트 클론
git clone https://github.com/openai/agents.md.git
cd agents.md

# 종속성 설치 및 실행
npm install
npm run dev
```

### 실습용 스크립트

```bash
#!/bin/bash
# setup-agents-md-practice.sh

echo "🚀 AGENTS.md 실습 환경 설정 중..."

# 실습 디렉토리 생성
mkdir -p ~/agents-md-practice
cd ~/agents-md-practice

# 샘플 프로젝트 생성
cat > package.json << 'EOF'
{
  "name": "agents-md-practice",
  "version": "1.0.0",
  "scripts": {
    "dev": "echo '개발 서버 실행됨'",
    "test": "echo '테스트 실행됨'",
    "lint": "echo '린트 검사 완료'"
  }
}
EOF

# 기본 AGENTS.md 템플릿 생성
cat > AGENTS.md << 'EOF'
# AGENTS.md

## 프로젝트 개요
AGENTS.md 실습을 위한 샘플 프로젝트입니다.

## 명령어
- `npm run dev` - 개발 서버 시작
- `npm run test` - 테스트 실행
- `npm run lint` - 코드 검사

## 코딩 컨벤션
- JavaScript ES6+ 사용
- 2스페이스 들여쓰기
EOF

echo "✅ 실습 환경 설정 완료!"
echo "📁 디렉토리: ~/agents-md-practice"
echo "📝 파일: AGENTS.md, package.json"
```

### zshrc에 유용한 별칭 추가

```bash
# ~/.zshrc에 추가
alias agents-practice="cd ~/agents-md-practice"
alias validate-agents="bash ~/scripts/validate-agents-md.sh"
alias new-agents="cp ~/templates/AGENTS.md.template ./AGENTS.md"

# 함수 추가
create-agents-project() {
    mkdir -p "$1"
    cd "$1"
    cp ~/templates/AGENTS.md.template ./AGENTS.md
    echo "📝 AGENTS.md 프로젝트 '$1' 생성됨"
}
```

## 결론

AGENTS.md는 AI 코딩 에이전트와 인간 개발자 간의 효과적인 협업을 위한 핵심 도구입니다. 이미 20,000개 이상의 프로젝트에서 채택되어 실질적인 표준으로 자리잡고 있습니다.

### 주요 장점

1. **표준화**: 다양한 AI 도구에서 일관된 경험 제공
2. **효율성**: 에이전트가 프로젝트를 빠르게 이해하고 작업 시작
3. **확장성**: 프로젝트 규모에 관계없이 적용 가능
4. **호환성**: 기존 문서와 충돌 없이 보완적 역할

### 다음 단계

1. **즉시 적용**: 현재 프로젝트에 AGENTS.md 파일 생성
2. **팀 도입**: 개발팀과 AGENTS.md 작성 규칙 공유
3. **지속 개선**: 에이전트 사용 경험을 바탕으로 내용 업데이트
4. **커뮤니티 참여**: [GitHub 프로젝트](https://github.com/openai/agents.md)에 기여

AI 코딩 에이전트가 점점 더 정교해지는 상황에서, AGENTS.md와 같은 표준화된 접근 방식은 개발 생산성을 크게 향상시킬 것입니다. 지금 바로 적용해보고 AI와의 협업 경험을 개선해보세요!
