# 🚀 GitHub 프로젝트 및 위키 설정 완료 가이드

## 📋 설정 완료 현황

### ✅ 완료된 작업

#### 1. GitHub Project 생성
- **프로젝트명**: Thaki Cloud 기술 블로그 관리
- **URL**: https://github.com/orgs/ThakiCloud/projects/2
- **상태**: 활성화됨

#### 2. 라벨 시스템 구축
다음 라벨들이 생성되어 이슈 관리에 활용됩니다:

| 라벨 | 색상 | 설명 | 용도 |
|------|------|------|------|
| `blog-post` | ![#0052cc](https://via.placeholder.com/15/0052cc/000000?text=+) | 블로그 포스트 작성 관련 | 모든 블로그 포스트 이슈 |
| `llmops` | ![#d73a4a](https://via.placeholder.com/15/d73a4a/000000?text=+) | LLM Ops 관련 | LLMOps 카테고리 포스트 |
| `dev` | ![#f9c513](https://via.placeholder.com/15/f9c513/000000?text=+) | 개발 관련 | 개발/아키텍처 포스트 |
| `tutorials` | ![#0e8a16](https://via.placeholder.com/15/0e8a16/000000?text=+) | 튜토리얼 관련 | 실습 가이드 포스트 |
| `research` | ![#b60205](https://via.placeholder.com/15/b60205/000000?text=+) | 연구 관련 | 연구/분석 포스트 |

#### 3. 초기 이슈 생성 및 프로젝트 연결
다음 이슈들이 생성되고 프로젝트에 추가되었습니다:

- **Issue #49**: 📝 DeepSeek-R1 vs OpenAI o1 성능 비교 분석
  - 라벨: `blog-post`, `llmops`
  - 예상 기간: 2주

- **Issue #50**: 🛠️ Kubernetes에서 LLM 서빙 최적화 가이드
  - 라벨: `blog-post`, `dev`, `tutorials`
  - 예상 기간: 3주

- **Issue #51**: 📚 AI 에이전트 프레임워크 비교 연구
  - 라벨: `blog-post`, `research`
  - 예상 기간: 4주

#### 4. 위키 활성화
- 리포지토리 위키 기능이 활성화되었습니다
- 첫 페이지 생성 후 위키 리포지토리가 생성됩니다

## 🎯 위키 초기 설정 가이드

### 1. 위키 첫 페이지 생성
GitHub 웹 인터페이스에서 위키 초기 페이지를 생성합니다:

1. https://github.com/ThakiCloud/thakicloud.github.io/wiki 접속
2. "Create the first page" 클릭
3. 아래 내용으로 Home 페이지 생성:

```markdown
# Thaki Cloud 기술 블로그 위키

AI/ML Engineering, LLMOps, DevOps 전문 기술 블로그의 공식 위키입니다.

## 📚 주요 페이지

- [[블로그 작성 가이드|Blog-Writing-Guide]]
- [[카테고리 분류 규칙|Category-Guidelines]]
- [[기술 스택 문서|Tech-Stack]]
- [[CI/CD 워크플로우|CICD-Workflow]]
- [[SEO 최적화 가이드|SEO-Guide]]

## 🎯 블로그 카테고리

### 개발 관련
- `dev`: 개발 및 아키텍처
- `tutorials`: 기술 인사이트 & 튜토리얼

### AI/ML 관련  
- `llmops`: LLM Ops & AI 엔지니어링
- `research`: 산업 연구 & 분석
- `reviews`: 학술 논문 리뷰

### 기타
- `careers`: Thaki Cloud Life & 커리어
- `news`: 기술 뉴스 & 트렌드
- `science`: 과학 & 딥테크
- `misc`: 기타

## 🔗 유용한 링크

- [메인 블로그](https://thakicloud.github.io)
- [GitHub 프로젝트](https://github.com/orgs/ThakiCloud/projects/2)
- [Thaki Cloud 공식 사이트](https://thakicloud.co.kr)
```

### 2. 추가 위키 페이지 생성
다음 페이지들을 순차적으로 생성하세요:

#### `Blog-Writing-Guide`
```markdown
# 블로그 작성 가이드

## 파일명 규칙
- 형식: `YYYY-MM-DD-title.md`
- 위치: `_posts/category/`

## Front Matter 템플릿
\```yaml
---
title: "포스트 제목"
excerpt: "요약 (100-150자)"
seo_title: "SEO 제목 (60자 이내) - Thaki Cloud"
seo_description: "SEO 설명 (150-160자)"
date: YYYY-MM-DD
categories:
  - 주요카테고리
tags:
  - 태그1
  - 태그2
author_profile: true
toc: true
canonical_url: "https://thakicloud.github.io/카테고리/포스트-slug/"
---
\```

## 작성 체크리스트
- [ ] 파일명이 올바른 형식인가?
- [ ] Front Matter가 완전한가?
- [ ] 카테고리가 적절한가?
- [ ] SEO 최적화가 되어있는가?
- [ ] 목차(TOC)가 설정되어 있는가?
```

#### `Tech-Stack`
```markdown
# 기술 스택 문서

## 블로그 기술 스택
- **정적 사이트 생성기**: Jekyll 4.x
- **테마**: Minimal Mistakes
- **호스팅**: GitHub Pages
- **CI/CD**: GitHub Actions
- **도메인**: thakicloud.github.io

## 개발 환경
- **Ruby**: 3.2+
- **Node.js**: 18+
- **Python**: 3.x (스크립트용)
- **Git**: 최신 버전

## 주요 도구
- **에디터**: Cursor, VS Code
- **터미널**: zsh + Oh My Zsh
- **패키지 관리**: Bundler (Ruby), npm (Node.js)
- **린팅**: markdownlint, html-validate
```

### 3. 위키 리포지토리 클론 (페이지 생성 후)
첫 페이지 생성 후 위키를 로컬에서 관리할 수 있습니다:

```bash
# 위키 리포지토리 클론
git clone https://github.com/ThakiCloud/thakicloud.github.io.wiki.git wiki

# 위키 디렉토리로 이동
cd wiki

# 새 페이지 생성
touch New-Page.md

# 내용 추가 후 커밋
git add .
git commit -m "Add new wiki page"
git push origin master
```

## 📊 프로젝트 관리 워크플로우

### 1. 새 블로그 포스트 기획
1. GitHub Issues에서 새 이슈 생성
2. 적절한 라벨 추가 (`blog-post` + 카테고리)
3. 프로젝트에 이슈 추가
4. 담당자 지정 및 마일스톤 설정

### 2. 작업 진행 상황 관리
1. 프로젝트 보드에서 이슈 상태 업데이트
2. 진행 상황을 코멘트로 기록
3. 완료 시 이슈 클로즈

### 3. 정기 리뷰
- 주간 프로젝트 리뷰 미팅
- 월간 블로그 성과 분석
- 분기별 콘텐츠 전략 수립

## 🎉 다음 단계

1. **위키 초기 페이지 생성** (위 가이드 참조)
2. **팀원들에게 프로젝트 접근 권한 부여**
3. **블로그 포스트 작성 시작**
4. **정기 리뷰 프로세스 수립**

---

*이 문서는 Thaki Cloud 기술 블로그의 GitHub 프로젝트 및 위키 설정 완료를 기념하여 작성되었습니다.* 