---
title: "GitHub Pages로 여러 프로젝트 사이트 운영하기 - 완벽 가이드"
date: 2025-06-05
categories: 
  - tutorials
  - GitHub
tags: 
  - GitHub Pages
  - 정적 사이트
  - 웹 개발
  - DevOps
author_profile: true
toc: true
toc_label: "목차"
---

GitHub Pages는 개발자들이 무료로 정적 사이트를 호스팅할 수 있는 훌륭한 서비스입니다. 하지만 많은 사용자들이 이미 `https://username.github.io` 형태의 메인 사이트를 운영하고 있을 때, 추가 프로젝트 사이트를 어떻게 구성해야 할지 궁금해합니다. 이 글에서는 GitHub Pages의 URL 구조를 이해하고, 하나의 저장소에서 여러 하위 페이지를 효율적으로 관리하는 방법을 알아보겠습니다.

## GitHub Pages URL 구조 이해하기

GitHub Pages는 두 가지 유형의 사이트를 제공합니다.

### User/Organization 사이트 vs 프로젝트 사이트

| 사이트 유형           | 저장소 이름               | URL 예시                                  | 비고      |
| ---------------- | -------------------- | --------------------------------------- | ------- |
| **User/Org 사이트** | `username.github.io` | `https://username.github.io/`           | 1개만 가능  |
| **프로젝트 사이트**     | 그 외 모든 저장소           | `https://username.github.io/repo-name/` | 여러 개 가능 |

핵심은 `username.github.io` 저장소는 딱 하나만 존재할 수 있으며 루트 도메인에 맵핑되지만, 다른 저장소들은 모두 하위 경로 `/repo-name/`에 매핑된다는 점입니다.

### 실제 적용 예시

기존에 `https://username.github.io`가 이미 사용 중이라면, 새로운 `ai-notebooks` 저장소를 만들어 다음과 같은 주소로 접근할 수 있습니다:

```
https://username.github.io/ai-notebooks/
https://username.github.io/ai-notebooks/notebook-a/
https://username.github.io/ai-notebooks/notebook-b/
```

## 하나의 저장소로 여러 페이지 구성하기

GitHub Pages의 강력한 기능 중 하나는 하나의 저장소 내에서 하위 디렉토리 구조를 통해 여러 페이지를 만들 수 있다는 점입니다.

### 기본 디렉토리 구조

다음과 같은 구조로 저장소를 구성하면:

```
my-repo/
├── docs/
│   ├── index.html           --> https://username.github.io/my-repo/
│   ├── notebook-a/
│   │   └── index.html       --> https://username.github.io/my-repo/notebook-a/
│   ├── notebook-b/
│   │   └── index.html       --> https://username.github.io/my-repo/notebook-b/
│   └── tutorial/
│       └── index.html       --> https://username.github.io/my-repo/tutorial/
```

GitHub Pages 설정에서 **"Source: Deploy from `docs/`"**로 설정하면 각 하위 디렉토리로 자동 라우팅이 가능합니다.

### GitHub Pages 설정 방법

1. 저장소의 **Settings** 탭으로 이동
2. 좌측 사이드바에서 **Pages** 선택
3. **Source** 섹션에서 **Deploy from a branch** 선택
4. **Branch**를 `main` (또는 `master`)으로 설정
5. **Folder**를 `/docs`로 선택
6. **Save** 버튼 클릭

## 커스텀 도메인으로 완전 분리하기

원한다면 `https://ai.example.com` 같은 별도 도메인을 CNAME으로 연결할 수도 있습니다.

### 커스텀 도메인 설정 단계

1. 도메인 레지스트라에서 CNAME 레코드 추가:
   ```
   ai.example.com CNAME username.github.io
   ```

2. GitHub Pages 설정에서 **Custom domain** 필드에 `ai.example.com` 입력

3. **Enforce HTTPS** 체크박스 활성화

이렇게 설정하면 다음과 같이 깔끔한 URL로 접근할 수 있습니다:

```
https://ai.example.com/notebook-a/
https://ai.example.com/notebook-b/
```

## 정적 사이트 생성기 활용하기

더 구조화된 콘텐츠와 자동화된 빌드를 원한다면 정적 사이트 생성기를 사용하는 것을 추천합니다.

### 추천 도구들

| 도구         | 특징                                      | 사용 사례                    |
| ---------- | --------------------------------------- | ------------------------ |
| **Jekyll** | GitHub Pages 기본 지원, `_config.yml` 설정 가능 | 블로그, 문서 사이트               |
| **MkDocs** | 문서 중심, `mkdocs.yml`로 구조 정의              | 기술 문서, API 레퍼런스          |
| **Hugo**   | 빠르고 유연, 블로그/문서 모두 가능                    | 복잡한 사이트, 다국어 지원          |
| **VuePress** | Vue.js 기반, 컴포넌트 지원                      | 인터랙티브 문서               |

### Jekyll 설정 예시

Jekyll을 사용하는 경우 `_config.yml` 파일에서 하위 페이지를 쉽게 구성할 수 있습니다:

```yaml
# _config.yml
title: AI Notebooks Hub
description: 머신러닝 개발 환경 및 튜토리얼 모음

# 네비게이션 메뉴
header_pages:
  - notebook-a/index.md
  - notebook-b/index.md
  - tutorial/index.md

# 컬렉션 설정
collections:
  notebooks:
    output: true
    permalink: /:collection/:name/
```

## GitHub Actions로 자동 배포 구성하기

GitHub Actions를 활용하면 여러 서브 디렉토리를 각각 빌드해서 자동으로 배포할 수 있습니다.

### 기본 workflow 예시

`.github/workflows/deploy.yml` 파일을 만들어 다음과 같이 구성합니다:

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout
      uses: actions/checkout@v3
      
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        
    - name: Install dependencies
      run: npm install
      
    - name: Build site
      run: npm run build
      
    - name: Deploy to GitHub Pages
      uses: peaceiris/actions-gh-pages@v3
      if: github.ref == 'refs/heads/main'
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        publish_dir: ./dist
```

### 다중 환경 빌드 예시

여러 개발 환경(Mac, CUDA 등)을 Docker로 관리하는 경우, 각각을 빌드하고 문서로 생성하는 workflow도 구성할 수 있습니다:

```yaml
name: Build Multiple Environments

on:
  push:
    branches: [ main ]

jobs:
  build-docs:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        environment: [mac, cuda, cpu]
        
    steps:
    - name: Checkout
      uses: actions/checkout@v3
      
    - name: Build ${{ matrix.environment }} docs
      run: |
        mkdir -p docs/${{ matrix.environment }}
        # 각 환경별 문서 생성 로직
        
    - name: Upload artifacts
      uses: actions/upload-artifact@v3
      with:
        name: docs-${{ matrix.environment }}
        path: docs/${{ matrix.environment }}
```

## 실전 운영 팁

### 네비게이션 구성

하위 페이지들 간의 이동을 위해 공통 네비게이션을 구성하는 것이 중요합니다:

```html
<!-- 공통 네비게이션 -->
<nav class="main-nav">
  <ul>
    <li><a href="/my-repo/">홈</a></li>
    <li><a href="/my-repo/notebook-a/">Notebook A</a></li>
    <li><a href="/my-repo/notebook-b/">Notebook B</a></li>
    <li><a href="/my-repo/tutorial/">튜토리얼</a></li>
  </ul>
</nav>
```

### SEO 최적화

각 페이지별로 적절한 메타데이터를 설정합니다:

```html
<head>
  <title>AI Notebook A - 머신러닝 개발환경</title>
  <meta name="description" content="TensorFlow 기반 머신러닝 개발 환경 구축 가이드">
  <meta property="og:title" content="AI Notebook A">
  <meta property="og:description" content="TensorFlow 기반 머신러닝 개발 환경 구축 가이드">
</head>
```

### 404 페이지 처리

`docs/` 디렉토리에 `404.html` 파일을 추가해 사용자 경험을 개선합니다:

```html
<!DOCTYPE html>
<html>
<head>
  <title>페이지를 찾을 수 없습니다</title>
</head>
<body>
  <h1>404 - 페이지를 찾을 수 없습니다</h1>
  <p><a href="/my-repo/">홈으로 돌아가기</a></p>
</body>
</html>
```

## 마무리

GitHub Pages를 활용하면 하나의 저장소로도 여러 프로젝트 페이지를 효율적으로 관리할 수 있습니다. 핵심은 다음과 같습니다:

- `username.github.io` 저장소는 하나만 가능하지만, 다른 저장소들은 `/repo-name/` 경로로 무제한 생성 가능
- 하나의 저장소 내에서 하위 디렉토리 구조를 통해 여러 페이지 구성
- 정적 사이트 생성기와 GitHub Actions를 활용한 자동화
- 필요시 커스텀 도메인으로 완전히 별도 사이트처럼 운영

이러한 방법들을 조합하면 개발 프로젝트부터 기술 문서, 포트폴리오까지 다양한 용도의 사이트를 체계적으로 관리할 수 있습니다. 특히 여러 개발 환경이나 프로젝트를 동시에 진행하는 개발자에게는 매우 유용한 접근 방식입니다. 