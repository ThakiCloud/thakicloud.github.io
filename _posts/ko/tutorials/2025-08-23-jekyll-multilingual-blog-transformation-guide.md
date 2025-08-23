---
title: "Jekyll 한국어 블로그를 3개 언어 다국어 시스템으로 완전 전환한 실제 경험기"
excerpt: "기존 한국어 Jekyll 블로그를 한국어/영어/아랍어 3개 언어를 지원하는 완전한 다국어 시스템으로 전환한 실제 구현 과정과 마주한 문제들, 그리고 해결 방법을 상세히 공유합니다."
seo_title: "Jekyll 다국어 블로그 실제 구현 경험기 - 한국어에서 3개 언어로 - Thaki Cloud"
seo_description: "Jekyll 블로그를 다국어로 전환하는 실제 과정에서 마주한 문제들과 해결책. GitHub Actions 증분 배포, Liquid 템플릿 오류, 언어별 검색 시스템 구축까지 모든 실무 경험을 공유합니다."
date: 2025-08-23
lang: ko
permalink: /ko/tutorials/jekyll-multilingual-blog-transformation-guide/
categories:
  - tutorials
tags:
  - Jekyll
  - 다국어
  - i18n
  - GitHub Actions
  - 블로그
  - 실무경험
  - 문제해결
  - CI/CD
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/ko/tutorials/jekyll-multilingual-blog-transformation-guide/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 20분

## 서론: 왜 다국어 블로그로 전환했나?

기존에 한국어로만 운영하던 Jekyll 기술 블로그를 **한국어, 영어, 아랍어** 3개 언어를 지원하는 완전한 다국어 시스템으로 전환하는 프로젝트를 진행했습니다. 

단순히 "다국어 지원하면 좋겠다"는 생각에서 시작했지만, 실제로 구현하면서 예상보다 훨씬 복잡한 문제들을 마주했습니다. 이 글은 그 실제 경험과 문제 해결 과정을 솔직하게 공유합니다.

### 🎯 목표했던 것들

- **3개 언어 완전 독립 운영**: `/ko/`, `/en/`, `/ar/` 각각의 독립적인 사이트
- **자동 언어 감지**: 브라우저 언어에 따른 스마트 리디렉션
- **언어별 독립 검색**: 각 언어별로 분리된 검색 시스템
- **증분 배포**: 변경된 언어만 빌드하는 효율적인 CI/CD
- **완전한 SEO**: 언어별 사이트맵, RSS 피드, 메타데이터

## 1단계: 현실 파악 - 기존 구조 분석

### 기존 블로그 상황

```
thakicloud.github.io/
├── _posts/
│   ├── 2025-08-20-some-post.md
│   ├── 2025-08-19-another-post.md
│   └── ... (모든 포스트가 루트에)
├── _config.yml (한국어 설정만)
└── 일반적인 Jekyll 구조
```

**첫 번째 깨달음**: 기존 포스트들을 어떻게 정리할 것인가? 

모든 기존 포스트가 한국어였으므로, 이들을 `_posts/ko/` 디렉토리로 이전해야 했습니다. 하지만 단순히 이동만 하면 안 되고, 각 포스트의 front matter에 `lang: ko`를 추가해야 했습니다.

### 실제 작업한 방법

```bash
# 1. 기존 포스트를 한국어 디렉토리로 이전
mkdir -p _posts/ko
find _posts -maxdepth 1 -name "*.md" -exec mv {} _posts/ko/ \;

# 2. 카테고리별 디렉토리 생성
mkdir -p _posts/ko/{tutorials,llmops,news,research,owm}
mkdir -p _posts/en/{tutorials,llmops,news,research,owm}  
mkdir -p _posts/ar/{tutorials,llmops,news,research,owm}
```

**예상치 못한 문제**: 기존 포스트들이 카테고리별로 정리되어 있지 않아서 수동으로 분류해야 했습니다. 100개가 넘는 포스트를 하나씩 확인하며 적절한 카테고리 폴더로 이동시키는 작업이 필요했습니다.

## 2단계: 설정 파일 분리 - 예상보다 복잡했던 부분

### 처음 계획

"간단하게 `_config-ko.yml`, `_config-en.yml`, `_config-ar.yml` 만들면 되겠지?"

### 실제로 마주한 문제들

#### 문제 1: Jekyll의 설정 상속 이해 부족

처음에는 각 언어별 설정 파일에 모든 설정을 다 넣으려고 했습니다. 하지만 Jekyll은 `--config` 옵션으로 여러 설정 파일을 지정할 때 **나중에 지정된 파일이 앞의 설정을 덮어쓴다**는 것을 몰랐습니다.

**해결책**: 공통 설정은 `_config.yml`에, 언어별 차이점만 각 언어 설정 파일에 넣는 구조로 변경했습니다.

```yaml
# _config.yml (공통 설정)
plugins:
  - jekyll-paginate
  - jekyll-sitemap
theme: minimal-mistakes-jekyll
markdown: kramdown
# ... 공통 설정들

# _config-ko.yml (한국어 전용)
locale: "ko-KR"
title: "Thaki Cloud Tech Blog | 다키클라우드 기술 블로그"
lang: "ko"
baseurl: "/ko"
# ... 한국어 전용 설정들
```

#### 문제 2: permalink 설정의 함정

각 언어별로 다른 URL 구조를 원했는데, 처음에는 이렇게 설정했습니다:

```yaml
# 잘못된 설정
permalink: /:categories/:title/
```

**문제**: 모든 언어의 포스트가 동일한 URL 패턴을 가져서 충돌이 발생했습니다.

**해결책**: 언어별 설정에서 permalink에 언어 코드를 포함시켰습니다:

```yaml
# _config-ko.yml
defaults:
  - scope:
      path: "_posts/ko"
      type: posts
    values:
      permalink: /ko/:categories/:title/
```

## 3단계: 네비게이션 시스템 - 생각보다 까다로웠던 UX

### 처음 생각한 단순한 구조

"네비게이션에 언어 선택 메뉴만 추가하면 되겠지?"

### 실제로 고려해야 했던 것들

#### 1. 언어별 네비게이션 텍스트

각 언어마다 메뉴 이름이 달라야 했습니다:
- 한국어: "포스트", "카테고리", "태그", "검색"
- 영어: "Posts", "Categories", "Tags", "Search"  
- 아랍어: "المقالات", "التصنيفات", "العلامات", "البحث"

#### 2. 언어 전환 시 UX 고려사항

사용자가 한국어 포스트를 보다가 영어로 전환하면 어디로 보내야 할까요?
- 같은 포스트의 영어 버전? (없을 수도 있음)
- 영어 홈페이지? (맥락이 끊김)
- 현재 카테고리의 영어 버전?

**최종 결정**: 언어 전환 시 해당 언어의 홈페이지로 보내되, 쿠키에 언어 선호도를 저장해서 다음 방문 시 기억하도록 했습니다.

### 실제 구현한 네비게이션 구조

```yaml
# _data/navigation.yml
ko:
  - title: "포스트"
    url: /ko/posts/
  - title: "언어"
    children:
      - title: "🇰🇷 한국어"
        url: /ko/
      - title: "🇺🇸 English"
        url: /en/
      - title: "🇸🇦 العربية"
        url: /ar/

en:
  - title: "Posts"
    url: /en/posts/
  # ... 영어 메뉴들

ar:
  - title: "المقالات"
    url: /ar/posts/
  # ... 아랍어 메뉴들
```

## 4단계: 자동 언어 감지 - JavaScript의 현실

### 이상적인 계획

"브라우저 언어 설정 보고 자동으로 리디렉션하면 되겠지!"

### 실제로 마주한 문제들

#### 문제 1: 브라우저 언어 감지의 한계

```javascript
// 처음 작성한 단순한 코드
const browserLang = navigator.language;
if (browserLang.startsWith('ko')) {
    window.location.href = '/ko/';
}
```

**문제점들**:
- `navigator.language`가 `ko-KR`, `en-US`, `ar-SA` 등 다양한 형태
- 사용자가 여러 언어를 설정한 경우 `navigator.languages` 배열 고려 필요
- 지원하지 않는 언어의 경우 기본값 처리 필요

#### 문제 2: 무한 리디렉션 방지

처음에는 단순하게 리디렉션만 했는데, 특정 상황에서 무한 리디렉션이 발생했습니다.

**해결책**: 쿠키를 활용한 상태 관리

```javascript
// 실제 구현한 안전한 리디렉션
function detectAndRedirect() {
    // 이미 언어별 페이지에 있으면 리디렉션 안 함
    if (window.location.pathname !== '/') return;
    
    // 저장된 언어 선호도 확인
    const savedLang = getCookie('preferred_language');
    if (savedLang) {
        window.location.href = '/' + savedLang + '/';
        return;
    }
    
    // 브라우저 언어 감지 후 리디렉션
    // ... 언어 감지 로직
}
```

## 5단계: 검색 시스템 - 가장 복잡했던 부분

### 처음 생각

"Jekyll 기본 검색에 언어 필터만 추가하면 되겠지?"

### 실제로 마주한 복잡함

#### 문제 1: Liquid 템플릿의 한계

언어별 검색 인덱스를 만들기 위해 이렇게 시도했습니다:

```liquid
{% raw %}
<!-- 처음 시도한 방법 (실패) -->
{% assign korean_posts = site.posts | where:"lang","ko" %}
{% for post in korean_posts %}
  <!-- 포스트 정보 출력 -->
{% endfor %}
{% endraw %}
```

**문제**: Jekyll 빌드 시 `Liquid Exception: Error accessing object` 오류 발생

**원인**: `where` 필터가 모든 상황에서 안정적으로 작동하지 않음

**해결책**: `for` 루프 내에서 `if` 조건문 사용

```liquid
{% raw %}
<!-- 실제로 작동한 방법 -->
{% for post in site.posts %}
  {% if post.lang == "ko" %}
    <!-- 포스트 정보 출력 -->
  {% endif %}
{% endfor %}
{% endraw %}
```

#### 문제 2: JavaScript 검색 로직

각 언어별로 다른 검색 인덱스를 로드해야 했는데, 현재 페이지의 언어를 어떻게 감지할 것인가가 문제였습니다.

**해결책**: HTML `lang` 속성 활용

```javascript
const currentLang = document.documentElement.lang || 'ko';
const searchIndexUrl = `/search-${currentLang}.json`;
```

## 6단계: GitHub Actions - CI/CD의 현실

### 처음 계획

"각 언어별로 빌드해서 합치면 되겠지!"

### 실제로 마주한 문제들

#### 문제 1: 빌드 시간 폭증

3개 언어를 모두 빌드하니 기존 대비 3배의 시간이 걸렸습니다. 작은 수정에도 전체 빌드가 돌아가는 비효율성이 있었습니다.

**해결책**: 증분 배포 시스템 구축

```yaml
# 변경사항 감지
- name: 🔍 변경사항 감지
  id: changes
  uses: dorny/paths-filter@v3
  with:
    filters: |
      korean:
        - '_posts/ko/**'
        - '_pages/ko/**'
        - '_config-ko.yml'
      english:
        - '_posts/en/**'
        - '_pages/en/**'
        - '_config-en.yml'
```

#### 문제 2: 파일 충돌 경고

빌드 과정에서 계속 이런 경고가 나왔습니다:

```
Conflict: The following destination is shared by multiple files.
/news/multilingual-test-post/index.html
- _posts/ar/news/2025-08-23-multilingual-test-post.md
- _posts/en/news/2025-08-23-multilingual-test-post.md
```

**원인**: 언어별 빌드를 할 때도 모든 언어의 포스트가 처리되고 있었음

**해결책**: 빌드 시 `--limit_posts` 옵션 사용과 언어별 완전 분리

## 7단계: SEO 최적화 - 세부사항의 중요성

### 사이트맵 생성에서 마주한 문제

#### 문제: 카테고리 중복

각 언어별 사이트맵에서 카테고리를 처리할 때, 모든 언어의 카테고리가 섞여서 나오는 문제가 있었습니다.

```liquid
{% raw %}
<!-- 문제가 있던 코드 -->
{% assign categories = site.categories | where: "lang", "ko" %}
{% endraw %}
```

**해결책**: 카테고리는 언어 구분 없이 전체를 포함하되, URL에 언어 코드를 포함시키는 방식으로 변경

```liquid
{% raw %}
<!-- 해결된 코드 -->
{% for category in site.categories %}
<url>
  <loc>{{ site.url }}/ko/categories/#{{ category[0] | slugify }}</loc>
  <!-- ... -->
</url>
{% endfor %}
{% endraw %}
```

### robots.txt 최적화

다국어 사이트맵을 모두 등록해야 했습니다:

```
# 언어별 사이트맵 등록
Sitemap: https://thakicloud.github.io/sitemap-ko.xml
Sitemap: https://thakicloud.github.io/sitemap-en.xml
Sitemap: https://thakicloud.github.io/sitemap-ar.xml
```

## 8단계: 자동화 도구 개발 - 개발자 경험 개선

### 포스트 생성의 번거로움

매번 3개 언어로 포스트를 만들어야 하는 번거로움이 있었습니다.

**해결책**: 다국어 포스트 생성 스크립트 개발

```bash
# 사용법
./scripts/new-multilingual-post.sh "my-post-title" "tutorials" "all"
```

이 스크립트는:
- 3개 언어 디렉토리에 동시에 파일 생성
- 언어별 템플릿 자동 적용
- front matter 자동 설정

### 로컬 개발 환경 개선

각 언어별로 따로 서빙하거나 통합해서 보는 기능이 필요했습니다.

```bash
# 언어별 개별 서빙
./scripts/serve-multilingual.sh ko 4000
./scripts/serve-multilingual.sh en 4001

# 통합 사이트 서빙
./scripts/serve-multilingual.sh all 8000
```

## 9단계: 실제 테스트와 문제 해결

### 로컬 테스트에서 발견한 문제들

#### 1. 한글 URL 인코딩 문제

한국어 포스트 제목이 URL에 포함될 때 인코딩 문제가 발생했습니다.

**해결책**: 포스트 파일명은 영어로, 제목만 한국어로 사용

#### 2. 아랍어 RTL 레이아웃

아랍어는 오른쪽에서 왼쪽으로 읽는 언어인데, 기본 테마가 이를 완전히 지원하지 않았습니다.

**임시 해결책**: CSS에서 `direction: rtl` 속성 추가 (향후 개선 필요)

### 성능 테스트 결과

- **빌드 시간**: 기존 30초 → 증분 배포 시 10초 (변경된 언어만)
- **사이트 크기**: 기존 50MB → 150MB (3배 증가는 예상 범위)
- **검색 속도**: 언어별 분리로 오히려 향상

## 10단계: 배포와 모니터링

### 첫 배포에서 발생한 문제

#### GitHub Pages 배포 실패

처음 배포할 때 GitHub Actions에서 계속 실패했습니다.

**원인**: Ruby 버전 불일치 (`3.1` → `3.2`로 변경 필요)

**해결**: 워크플로우 파일의 Ruby 버전 업데이트

```yaml
- name: 💎 Ruby 설정
  uses: ruby/setup-ruby@v1
  with:
    ruby-version: '3.2'  # 3.1에서 변경
```

### 실제 사용자 피드백

배포 후 받은 피드백들:

1. **긍정적**: "언어 자동 감지가 편리하다"
2. **개선 필요**: "언어 전환 시 같은 카테고리 페이지로 가면 좋겠다"
3. **버그 리포트**: "모바일에서 아랍어 메뉴가 깨진다"

## 결론: 배운 점들과 앞으로의 계획

### 🎯 성공적으로 달성한 것들

1. **완전한 다국어 지원**: 3개 언어 독립 운영 성공
2. **효율적인 CI/CD**: 증분 배포로 빌드 시간 70% 단축
3. **사용자 경험**: 자동 언어 감지와 쿠키 기반 선호도 저장
4. **SEO 최적화**: 언어별 사이트맵, RSS 피드 완성
5. **개발자 경험**: 자동화 스크립트로 관리 효율성 향상

### 😅 예상보다 어려웠던 점들

1. **Liquid 템플릿의 한계**: `where` 필터 문제로 많은 시행착오
2. **Jekyll 빌드 충돌**: 언어별 분리가 생각보다 복잡
3. **GitHub Actions 디버깅**: 로컬과 CI 환경의 차이점들
4. **아랍어 RTL 지원**: 기존 테마의 한계
5. **성능 최적화**: 3배 증가한 빌드 시간 관리

### 🚀 앞으로의 개선 계획

1. **아랍어 RTL 완전 지원**: 커스텀 CSS 개발
2. **언어별 콘텐츠 연결**: 같은 주제의 다국어 포스트 연결 시스템
3. **자동 번역 도구**: 초안 생성을 위한 번역 자동화
4. **성능 최적화**: 이미지 최적화, 캐싱 전략 개선
5. **사용자 분석**: 언어별 사용자 행동 분석 도구 추가

### 💡 다른 개발자들에게 주는 조언

1. **작은 단위로 테스트**: 한 번에 모든 언어를 구현하지 말고 단계적 접근
2. **Liquid 템플릿 주의**: `where` 필터보다 `for + if` 조합이 안정적
3. **로컬 테스트 필수**: GitHub Actions 디버깅은 시간이 오래 걸림
4. **사용자 경험 우선**: 기술적 완성도보다 실제 사용성이 중요
5. **문서화의 중요성**: 복잡한 설정은 반드시 문서로 남기기

이 프로젝트를 통해 단순해 보이는 "다국어 지원"이 실제로는 얼마나 많은 고려사항과 기술적 도전을 포함하고 있는지 깨달았습니다. 하지만 결과적으로 더 많은 사용자에게 콘텐츠를 전달할 수 있게 되어 매우 만족스러운 프로젝트였습니다.

여러분도 다국어 블로그를 고려하고 있다면, 이 경험기가 도움이 되기를 바랍니다! 🌐✨