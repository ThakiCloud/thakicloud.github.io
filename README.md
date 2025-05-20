# Thaki Cloud 기술 블로그

Thaki Cloud 공식 기술 블로그 리포지토리에 오신 것을 환영합니다! 이 블로그는 프라이빗 클라우드 솔루션(IaaS, PaaS, SaaS), LLM Ops 및 AI 엔지니어링 분야에서의 저희 전문 지식, 인사이트, 그리고 혁신을 공유하는 플랫폼입니다. 저희의 주요 목표는 뛰어난 기술 전문가들과 소통하고 Thaki Cloud에서의 흥미로운 기회를 소개하는 것입니다.

## ✨ 목적

*   **인재 채용**: 저희의 기술적 깊이와 기업 문화를 선보여 최고의 기술 인재를 유치합니다.
*   **지식 공유**: 전문가의 인사이트, 튜토리얼, 연구 및 뉴스를 공유하여 기술 커뮤니티에 기여합니다.
*   **브랜드 구축**: Thaki Cloud를 저희 전문 분야의 선도적인 리더로 자리매김합니다.

## 🛠️ 기술 스택

*   **정적 사이트 생성기**: [Jekyll](https://jekyllrb.com/)
*   **테마**: [Minimal Mistakes](https://mmistakes.github.io/minimal-mistakes/)
*   **콘텐츠 형식**: Markdown
*   **호스팅**: (예: GitHub Pages, Netlify, Vercel - *실제 사용 중인 호스팅 솔루션으로 업데이트해주세요*)

## ✍️ 새 블로그 게시물 작성 방법: 간단 가이드

Thaki Cloud 기술 블로그에 콘텐츠를 기고하는 방법은 간단합니다. 다음 단계에 따라 게시물을 작성하고 발행하세요:

### 1. 카테고리 선택

먼저, 작성할 게시물이 어떤 카테고리에 가장 적합한지 결정합니다. 현재 카테고리는 다음과 같습니다:

*   `iaas` (IaaS & 프라이빗 클라우드)
*   `paas` (PaaS & 플랫폼 엔지니어링)
*   `saas` (SaaS 개발 및 아키텍처)
*   `llmops` (LLM Ops & AI 엔지니어링)
*   `tutorials` (기술 인사이트 & 튜토리얼)
*   `careers` (Thaki Cloud Life & 커리어)
*   `reviews` (학술 논문 리뷰)
*   `news` (기술 뉴스 & 트렌드)
*   `research` (산업 연구 & 분석)
*   `science` (과학 & 딥테크)
*   `misc` (기타)

각 카테고리에는 `_posts` 디렉토리 내에 전용 폴더가 있습니다 (예: `_posts/iaas/`, `_posts/llmops/`).

### 2. 게시물 파일 만들기

*   `_posts/` 디렉토리 내의 적절한 카테고리 폴더로 이동합니다. 예를 들어, LLM Ops에 관한 게시물이라면 `_posts/llmops/`로 이동합니다.
*   새 Markdown 파일(`.md`)을 만듭니다.
*   **파일 이름**은 다음 형식을 사용합니다: `YYYY-MM-DD-your-post-title.md`.
    *   예시: `2024-07-30-optimizing-inference-speed.md`

### 3. 프론트 매터(Front Matter) 추가

Markdown 파일 가장 처음에 "프론트 매터" 블록을 추가해야 합니다. 이는 게시물의 메타데이터를 제공합니다. 최소한의 예시는 다음과 같습니다:

```yaml
---
title: "LLM 추론 속도 최적화: 실용 가이드"
categories:
  - llmops # 단일 영어 단어 카테고리 이름을 사용하세요
# 선택 사항: 관련 태그 추가
# tags:
#   - performance
#   - llm
#   - optimization
# 선택 사항: 기본값과 다른 작성자 지정 (_config.yml 참조)
# author: "Your Name"
# 선택 사항: 목록 페이지에 표시될 발췌문 추가
# excerpt: "대규모 언어 모델의 추론 속도를 크게 향상시키는 주요 기술을 알아보세요..."
---

```

*   **`title`**: 블로그 게시물의 주 제목입니다.
*   **`categories`**: 게시물이 속한 카테고리입니다. **폴더 이름과 일치하는 짧은 단일 영어 단어 카테고리 이름**을 사용하세요 (예: `llmops`, `iaas`, `careers`). 적절한 경우 여러 개를 나열할 수 있지만, 보통 하나의 주 카테고리가 가장 좋습니다.

### 4. 콘텐츠 작성

프론트 매터 아래(닫는 `---` 다음)에 표준 Markdown을 사용하여 블로그 게시물 콘텐츠를 작성합니다.

```markdown
---
title: "LLM 추론 속도 최적화: 실용 가이드"
categories:
  - llmops
---

## 서론

LLM 추론 속도 최적화 가이드에 오신 것을 환영합니다...

### 주요 기술

1.  **양자화(Quantization)**: ...
2.  **가지치기(Pruning)**: ...

제목, 목록, 코드 블록, 이미지 등 모든 표준 Markdown 기능을 사용할 수 있습니다.
각 카테고리 폴더에 있는 플레이스홀더 가이드 파일(예: `_posts/llmops/placeholder-llm-ops-guide.md`)에서 더 구체적인 주제 아이디어나 구조적 제안을 참고하세요.
```

### 5. 이미지 추가 (선택 사항)

*   `assets/images/posts/` 내에 게시물 이미지를 위한 하위 폴더를 만듭니다. 이 하위 폴더 이름은 게시물 제목과 관련된 것으로 지정하는 것이 좋습니다 (예: `assets/images/posts/optimizing-inference-speed/`).
*   이미지를 이 폴더에 넣습니다.
*   Markdown에서 다음과 같이 링크합니다: `![이미지 대체 텍스트](/assets/images/posts/optimizing-inference-speed/your-image.png)`

### 6. 게시물 미리보기 (로컬 환경)

로컬 환경에 Jekyll이 설정되어 있다면 게시물을 미리 볼 수 있습니다:
1.  터미널을 엽니다.
2.  블로그의 루트 디렉토리로 이동합니다.
3.  `bundle exec jekyll serve`를 실행합니다.
4.  브라우저에서 `http://localhost:4000`을 열어 변경 사항을 확인합니다.

### 7. 게시물 발행

게시물에 만족하면 다음을 수행합니다:
1.  새 Markdown 파일(및 모든 이미지)을 Git 리포지토리에 커밋합니다.
2.  변경 사항을 GitHub(또는 Git 원격 저장소)의 메인 브랜치에 푸시합니다.

블로그는 자동으로 새 게시물을 다시 빌드하고 배포합니다. (정확한 메커니즘은 호스팅 설정에 따라 다릅니다. 예: GitHub Pages의 경우 GitHub Actions).

---

이것으로 끝입니다! Thaki Cloud 기술 블로그에 대한 여러분의 기고를 기대합니다. 질문이 있으시면 `.cursor/` 폴더의 프로젝트 문서를 참조하거나 프로젝트 관리자에게 문의하십시오. 