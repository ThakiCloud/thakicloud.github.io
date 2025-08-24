# 🌍 Thaki Cloud 다국어 기술 블로그

> 🇺🇸 [English README](README-en.md) | 🇸🇦 [العربية README](README-ar.md)

Thaki Cloud 공식 다국어 기술 블로그 리포지토리에 오신 것을 환영합니다! 이 블로그는 **한국어, 영어, 아랍어** 3개 언어로 서비스되며, 프라이빗 클라우드 솔루션(IaaS, PaaS, SaaS), LLM Ops 및 AI 엔지니어링 분야에서의 저희 전문 지식, 인사이트, 그리고 혁신을 전 세계 독자들과 공유하는 플랫폼입니다.

## ✨ 목적

*   **글로벌 인재 채용**: 다국어 콘텐츠를 통해 전 세계 최고의 기술 인재를 유치합니다.
*   **지식 공유**: 전문가의 인사이트, 튜토리얼, 연구 및 뉴스를 다국어로 공유하여 글로벌 기술 커뮤니티에 기여합니다.
*   **브랜드 구축**: Thaki Cloud를 국제적인 기술 리더로 자리매김합니다.
*   **문화적 접근성**: 언어 장벽 없이 모든 사용자가 기술 지식에 접근할 수 있도록 합니다.

## 🛠️ 기술 스택

*   **정적 사이트 생성기**: [Jekyll](https://jekyllrb.com/)
*   **테마**: [Minimal Mistakes](https://mmistakes.github.io/minimal-mistakes/)
*   **콘텐츠 형식**: Markdown
*   **다국어 지원**: 한국어, 영어, 아랍어 (브라우저 언어 자동 감지)
*   **호스팅**: GitHub Pages
*   **CI/CD**: GitHub Actions (다국어 빌드 자동화)
*   **로컬 테스트**: act (GitHub Actions 로컬 실행)

## 🌐 웹사이트 접속 가이드

### 자동 언어 감지
[**thakicloud.github.io**](https://thakicloud.github.io)에 접속하면 브라우저 언어 설정에 따라 자동으로 해당 언어 페이지로 리디렉션됩니다:

- **한국어 브라우저** → `/ko/` (한국어 블로그)
- **영어 브라우저** → `/en/` (영어 블로그)  
- **아랍어 브라우저** → `/ar/` (아랍어 블로그)

### 직접 언어 선택
원하는 언어로 직접 접속할 수도 있습니다:

- 🇰🇷 **한국어**: [thakicloud.github.io/ko/](https://thakicloud.github.io/ko/)
- 🇺🇸 **English**: [thakicloud.github.io/en/](https://thakicloud.github.io/en/)
- 🇸🇦 **العربية**: [thakicloud.github.io/ar/](https://thakicloud.github.io/ar/)

### 언어 전환
각 페이지 상단 네비게이션에서 언어를 자유롭게 전환할 수 있으며, 선택한 언어는 쿠키에 저장되어 다음 방문 시 기억됩니다.

---

## ✍️ 다국어 블로그 게시물 작성 방법

Thaki Cloud 다국어 기술 블로그에 콘텐츠를 기고하는 방법을 안내합니다. 모든 게시물은 **한국어, 영어, 아랍어** 3개 언어로 작성됩니다.

### 1. 다국어 포스트 자동 생성

다국어 포스트 생성 스크립트를 사용하여 3개 언어 템플릿을 한 번에 생성할 수 있습니다:

```bash
# 사용법: new-multilingual-post <title-slug> <category>
~/scripts/new-multilingual-post.sh "ai-tutorial-guide" "tutorials"
```

### 2. 카테고리 선택

현재 지원하는 카테고리는 다음과 같습니다:

*   `agentops` (AI 에이전트 개발 및 운영)
*   `careers` (커리어 및 성장)
*   `culture` (개발팀 문화 및 방법론)
*   `datasets` (데이터 분석 및 처리)
*   `dev` (프로그래밍 및 개발 팁)
*   `devops` (개발 운영 및 인프라)
*   `llmops` (대규모 언어 모델 운영)
*   `news` (최신 기술 동향)
*   `owm` (오픈 워크플로우 관리)
*   `research` (기술 연구 및 논문 리뷰)
*   `tutorials` (실습 가이드)

각 언어별로 별도 디렉토리 구조를 가집니다:
- 한국어: `_posts/ko/<category>/`
- 영어: `_posts/en/<category>/`
- 아랍어: `_posts/ar/<category>/`

### 3. 언어별 콘텐츠 작성

스크립트 실행 후 다음 3개 파일이 생성됩니다:

```
_posts/ko/tutorials/2025-01-28-ai-tutorial-guide.md  (한국어)
_posts/en/tutorials/2025-01-28-ai-tutorial-guide.md  (영어)
_posts/ar/tutorials/2025-01-28-ai-tutorial-guide.md  (아랍어)
```

각 파일을 해당 언어로 작성하거나 번역합니다.

### 4. 프론트 매터(Front Matter) 구조

생성된 템플릿에는 다국어 최적화된 프론트 매터가 포함됩니다:

**한국어 예시:**
```yaml
---
title: "AI 튜토리얼 가이드"
excerpt: "AI 기술의 기초부터 고급까지 다루는 완전 가이드"
seo_title: "AI 튜토리얼 완전 가이드 - Thaki Cloud"
seo_description: "AI 기술을 처음부터 배우고 싶은 개발자를 위한 단계별 튜토리얼"
date: 2025-01-28
lang: ko
categories:
  - tutorials
tags:
  - ai
  - tutorial
  - guide
author_profile: true
toc: true
canonical_url: "https://thakicloud.github.io/ko/tutorials/ai-tutorial-guide/"
---
```

**영어 예시:**
```yaml
---
title: "Complete AI Tutorial Guide"
excerpt: "Comprehensive guide covering AI technology from basics to advanced"
seo_title: "Complete AI Tutorial Guide - Thaki Cloud"
seo_description: "Step-by-step tutorial for developers who want to learn AI technology from scratch"
date: 2025-01-28
lang: en
categories:
  - tutorials
tags:
  - ai
  - tutorial
  - guide
author_profile: true
toc: true
canonical_url: "https://thakicloud.github.io/en/tutorials/ai-tutorial-guide/"
---
```

### 5. 콘텐츠 작성 가이드

각 언어별로 해당 언어의 독자를 고려하여 콘텐츠를 작성합니다:

**한국어 콘텐츠:**
```markdown
⏱️ **예상 읽기 시간**: 15분

## 서론

AI 기술이 급속도로 발전하면서...

## 주요 내용

### 1. 기초 개념
- 머신러닝의 기본 원리
- 딥러닝과의 차이점

### 2. 실습 예제
```python
import tensorflow as tf
# 한국어 주석으로 설명
```

## 결론
```

**영어 콘텐츠:**
```markdown
⏱️ **Estimated reading time**: 15 min read

## Introduction

As AI technology rapidly evolves...

## Main Content

### 1. Fundamental Concepts
- Basic principles of machine learning
- Differences from deep learning

### 2. Practical Examples
```python
import tensorflow as tf
# Explanations in English comments
```

## Conclusion
```

### 6. 이미지 및 미디어 추가

이미지는 언어별로 구분하여 관리할 수 있습니다:

```
assets/images/posts/
├── ko/ai-tutorial-guide/
│   ├── diagram-ko.png
│   └── screenshot-ko.png
├── en/ai-tutorial-guide/
│   ├── diagram-en.png
│   └── screenshot-en.png
└── ar/ai-tutorial-guide/
    ├── diagram-ar.png
    └── screenshot-ar.png
```

Markdown에서 링크:
```markdown
![AI 다이어그램](/assets/images/posts/ko/ai-tutorial-guide/diagram-ko.png)
```

### 7. 다국어 빌드 및 미리보기

#### 언어별 개별 미리보기:
```bash
# 한국어 사이트 (포트 4000)
bundle exec jekyll serve --config _config.yml,_config-ko.yml --port 4000

# 영어 사이트 (포트 4001)  
bundle exec jekyll serve --config _config.yml,_config-en.yml --port 4001

# 아랍어 사이트 (포트 4002)
bundle exec jekyll serve --config _config.yml,_config-ar.yml --port 4002
```

#### 통합 다국어 빌드:
```bash
# 전체 다국어 사이트 빌드
./scripts/build-multilingual.sh

# 빌드된 사이트 미리보기
cd _site && python3 -m http.server 4000
```

접속 URL:
- 한국어: http://localhost:4000/ko/
- 영어: http://localhost:4000/en/
- 아랍어: http://localhost:4000/ar/

### 8. 게시물 발행

#### 로컬 테스트:
```bash
# CI/CD 테스트 (act 사용)
act -j build -W .github/workflows/multilingual-deploy.yml --container-architecture linux/amd64

# 또는 테스트 스크립트 실행
~/scripts/test-multilingual-ci.sh
```

#### GitHub에 배포:
```bash
# 모든 언어 파일 커밋
git add _posts/ko/ _posts/en/ _posts/ar/
git commit -m "feat: Add multilingual AI tutorial guide"
git push origin main
```

GitHub Actions가 자동으로 다국어 사이트를 빌드하고 배포합니다:
1. 한국어, 영어, 아랍어 각각 빌드
2. 통합 사이트 생성
3. GitHub Pages에 배포

---

## 🎯 다국어 블로그 관리 명령어

편의를 위한 유용한 명령어들:

```bash
# 블로그 상태 확인
echo "📊 다국어 블로그 상태:"
echo "🇰🇷 한국어 포스트: $(find _posts/ko -name '*.md' | wc -l)"
echo "🇺🇸 영어 포스트: $(find _posts/en -name '*.md' | wc -l)"  
echo "🇸🇦 아랍어 포스트: $(find _posts/ar -name '*.md' | wc -l)"

# 언어별 디렉토리 이동
cd _posts/ko/    # 한국어 포스트
cd _posts/en/    # 영어 포스트  
cd _posts/ar/    # 아랍어 포스트
```

---

이것으로 끝입니다! Thaki Cloud 다국어 기술 블로그에 대한 여러분의 기고를 기대합니다. 질문이 있으시면 프로젝트 관리자에게 문의하십시오. 

# 📝 기여 및 문서 작성/배포 가이드

이 저장소는 Jekyll 기반 블로그 및 문서 사이트입니다. 아래는 로컬에서 브랜치 생성, 문서 작성, GitHub PR 및 머지, 그리고 사전 로컬 CI 체크 방법에 대한 상세 가이드입니다.

---

## 1. 로컬 개발 및 기여 워크플로우

### 1) 브랜치 생성
```sh
git checkout main
# 최신화
git pull origin main
# 새 브랜치 생성 (예: docs/update-local-ci-guide)
git checkout -b docs/update-local-ci-guide
```

### 2) 문서 작성 및 수정
- `_posts/`, `_pages/`, `docs/` 등 원하는 위치에 마크다운 문서 작성
- 예시: `docs/local-ci-check-guide.md` 참고

### 3) 변경 사항 커밋
```sh
git status # 변경 파일 확인
git add docs/local-ci-check-guide.md # 또는 수정한 파일들
git commit -m "docs: 로컬 CI 체크 가이드 추가"
```

### 4) 원격 저장소로 푸시
```sh
git push origin docs/update-local-ci-guide
```

### 5) GitHub에서 Pull Request(PR) 생성
- GitHub 저장소에 접속 → "Compare & pull request" 클릭
- PR 제목/설명 작성, 리뷰어 지정(필요시)
- PR 생성

### 6) PR CI 통과 및 리뷰
- GitHub Actions에서 자동으로 CI가 실행됨
- 모든 체크(✅) 통과 시 리뷰어 승인 후 Merge

### 7) 머지 및 브랜치 정리
- PR이 main/develop에 머지되면, 로컬/원격 브랜치 삭제
```sh
git checkout main
git pull origin main
git branch -d docs/update-local-ci-guide
git push origin --delete docs/update-local-ci-guide
```

---

## 2. 로컬 CI 사전 체크 요약

> **자세한 내용은 [`docs/local-ci-check-guide.md`](docs/local-ci-check-guide.md) 참고**

### 필수 환경
- Ruby 3.2+, Node.js 18+, Python3
- Bundler, npm, pip

### 주요 체크 항목
1. **의존성 설치**
   - `bundle install`, `npm install -g ...`, `pip install ...`
2. **Jekyll Doctor/Build**
   - `bundle exec jekyll doctor`
   - `JEKYLL_ENV=production bundle exec jekyll build --verbose --trace`
3. **마크다운 린트**
   - `markdownlint '_posts/**/*.md' ...`
4. **HTML 유효성/링크 체크**
   - `html-validate`, `broken-link-checker`
5. **보안 검사**
   - `trivy fs .`, `detect-secrets scan`
6. **Lighthouse 퍼포먼스**
   - `lhci autorun`
7. **배포 시뮬레이션**
   - `_site/` 내 필수 파일 존재 및 통계 확인

### 체크리스트 예시
- [ ] Ruby, Node, Python 환경 및 버전 확인
- [ ] 의존성 설치 완료
- [ ] Jekyll doctor/build 성공
- [ ] 마크다운/HTML/링크 오류 없음
- [ ] 보안 점검 완료
- [ ] Lighthouse 점검
- [ ] 배포 시뮬레이션 통과

---

## 3. 참고
- CI와 완전히 동일한 환경은 아닐 수 있으니, 의존성 버전/설정 차이에 주의하세요.
- 추가적인 워크플로우나 설정이 있다면 그에 맞게 커맨드를 보완하세요.
- 자세한 명령어와 설명은 [`docs/local-ci-check-guide.md`](docs/local-ci-check-guide.md)에서 확인하세요. 