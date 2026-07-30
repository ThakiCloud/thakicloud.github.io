# Thaki Cloud 기술 블로그

> 다른 언어로 보기: [English README](README.md)

**Thaki Cloud 기술 블로그**의 소스 저장소입니다. AI/ML 엔지니어링, LLMOps, DevOps, 쿠버네티스, 프라이빗 클라우드 인프라를 다루는 한국어·영어 이중언어 기술 블로그입니다.

라이브 사이트: **https://thakicloud.com/tech-blog/**

- 한국어: https://thakicloud.com/tech-blog/ko/
- English: https://thakicloud.com/tech-blog/en/

사이트 루트에 접속하면 브라우저 언어에 맞는 언어로 리디렉션되며, 이전에 선택한 언어가 있으면 그것을 우선합니다.

## 기술 스택

- **정적 사이트 생성기**: [Jekyll](https://jekyllrb.com/) 4.x
- **테마**: [Minimal Mistakes](https://mmistakes.github.io/minimal-mistakes/) + 커스텀 `thaki` 스킨
- **외관**: 다크 전용. 다크 테마의 thakicloud.com 쉘에 임베드되도록 튜닝
- **콘텐츠**: 마크다운. 언어별로 `_posts/<lang>/<category>/`에 한 편씩
- **검색**: 클라이언트 사이드 Lunr, 언어별 인덱스
- **호스팅**: Amazon S3 + CloudFront
- **CI/CD**: GitHub Actions (`main` push 시 빌드 → S3 배포 → CloudFront 무효화)

## 저장소 구조

```
_posts/ko/<category>/   한국어 글
_posts/en/<category>/   영어 글
_pages/{ko,en}/         언어별 홈 + 검색 페이지
_config.yml             기본 사이트 설정 (permalink, defaults, exclude)
_data/navigation.yml    언어 전환기
_includes/ _layouts/    테마 오버라이드 (masthead, SEO, hreflang 등)
assets/css/main.scss    디자인 토큰 및 다크 테마
.github/workflows/      jekyll.yml 이 활성 빌드·배포 파이프라인
```

사용 카테고리: `agentops`, `llmops`, `dev`, `research`, `tutorials`, `owm`, `datasets`, `news`, `culture`, `careers`, 그리고 만화(영어는 `comics`, 한국어는 `만화`).

## 로컬 개발

Ruby 3.2 이상과 Bundler가 필요합니다.

```bash
bundle install
bundle exec jekyll serve
```

접속:

- http://localhost:4000/tech-blog/ko/
- http://localhost:4000/tech-blog/en/

## 글 작성

글은 YAML front matter가 있는 마크다운입니다. 언어별 카테고리 폴더에 배치합니다.

```
_posts/ko/tutorials/2026-07-27-my-post.md
_posts/en/tutorials/2026-07-27-my-post.md
```

한국어 글이 원본이며, 영어 형제 글은 같은 `slug`·`categories`·`date`·`tags`를 공유하고 제목·요약·SEO 필드·본문만 번역합니다. 발행 상태는 패리티로 유지됩니다. 영어 번역은 한국어 원본이 발행된 경우에만 발행되고, 언어별로 최대 250편까지 발행합니다(초과분은 `published: false`로 저장소에 남습니다).

front matter에 `lang`(`ko` 또는 `en`)과 `canonical_url`을 지정하며, permalink(`/ko/<category>/<slug>/`, `/en/<category>/<slug>/`)는 폴더 경로에서 자동 결정됩니다.

## 배포

`main`에 push하면 `.github/workflows/jekyll.yml`이 실행되어 Jekyll로 사이트를 빌드하고, `_site/`를 S3에 `--delete`로 동기화한 뒤 CloudFront를 무효화합니다. 별도 수동 절차 없이 몇 분 내에 반영됩니다.

## 언어 지원

블로그는 **한국어와 영어**로 제공됩니다. 아랍어는 2026년 7월에 중단되어 더 이상 빌드·배포·링크되지 않습니다.

## 라이선스

콘텐츠 저작권은 © Thaki Cloud에 있습니다. Minimal Mistakes 테마는 MIT License로 배포됩니다.
