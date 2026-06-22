# SEO 운영 가이드 (thakicloud.github.io)

이 문서는 코드로 끝낼 수 없는 **수동 등록 단계**와 자동화된 부분의 동작 방식을 정리한다.
대상: 국내 노출(Naver/Google) + 글로벌(en/ar, Google) 동시 강화.

## 1. 자동화된 것 (코드에 반영됨, 추가 작업 불필요)

- **hreflang**: `sitemap-ko/en/ar.xml`이 포스트별 `ko`/`en`/`ar` 상호 링크 + `x-default(=ko)` 출력.
  번역 매칭 키 = 언어 prefix를 뗀 URL(`{category}/{slug}/`). `_includes/hreflang-alternates.html`.
- **sitemap index**: `sitemap.xml`은 언어별 사이트맵 3개를 가리키는 인덱스.
- **구조화 데이터(JSON-LD)**: 포스트=`BlogPosting`+`BreadcrumbList`, 홈=`WebSite`+`SearchAction`.
  `_includes/head/structured-data.html`.
- **`<html lang>`/`dir`**: 페이지 언어대로 출력(아랍어는 `dir="rtl"`). `_layouts/default.html`.
- **PWA**: `site.webmanifest` + `<link rel="manifest">`.
- **GA4**: `G-H3R0WGN0LF`. **Google 인증**: `google_site_verification` 설정됨.

## 2. 수동 등록 — 이것만 하면 됨 (코드로 대체 불가)

### 2-1. Naver 서치어드바이저 (국내 노출 핵심)
1. https://searchadvisor.naver.com → 로그인 → **사이트 등록**: `https://thakicloud.github.io`
2. 소유확인 = **HTML 태그** 방식 선택 → 제공되는 `<meta name="naver-site-verification" content="XXXX">`의 **content 값**을
   `_config.yml`의 `naver_site_verification` 에 붙여넣기 → 커밋/배포 → "확인".
3. **요청 > 사이트맵 제출**: `sitemap-ko.xml` 제출(국내는 ko 우선). `sitemap.xml`(인덱스)도 제출.
4. **요청 > RSS 제출**: `feed.xml`.
5. (선택) **검증 > robots.txt** 확인, **수집 요청**으로 주요 글 색인 가속.

> 네이버는 hreflang 신뢰도가 낮다 → 국내는 **ko 사이트맵 단독 제출 + 콘텐츠/발행빈도**가 실효 동력.

### 2-2. Bing Webmaster (글로벌 보조 + ChatGPT/Copilot 노출)
1. https://www.bing.com/webmasters → **Import from Google Search Console** (가장 빠름, 사이트+사이트맵 자동 이관).
2. 수동 시: `bing_site_verification`에 `msvalidate.01` content 값 붙여넣기 → `sitemap.xml` 제출.

### 2-3. Google Search Console (이미 인증됨 — 사이트맵만 확인)
1. https://search.google.com/search-console → 속성 `https://thakicloud.github.io`
2. **Sitemaps**: `sitemap.xml`(인덱스) 제출 확인. 국제 타겟팅은 hreflang가 자동 처리하므로 country 설정 불필요.
3. 배포 후 **URL 검사**로 hreflang 인식 확인(International Targeting 리포트에서 오류 0 확인).

## 3. 배포 후 검증 체크리스트
- [ ] `curl -s https://thakicloud.github.io/sitemap.xml` → `<sitemapindex>` 3개
- [ ] 임의 포스트 소스에 `application/ld+json` 블록 3개(Organization/BlogPosting/BreadcrumbList) + 유효 JSON
- [ ] 아랍어 페이지 `<html lang="ar" dir="rtl">`
- [ ] [Rich Results Test](https://search.google.com/test/rich-results)로 BlogPosting/Breadcrumb 통과
- [ ] GSC International Targeting → hreflang 오류 없음

## 4. 다음 성장 레버 (코드 밖)
- 포스트별 `header.og_image` 지정으로 공유 CTR↑ (현재 기본 1장 fallback).
- Core Web Vitals: Mermaid 전역 로드 → 다이어그램 있는 글만 로드로 전환 검토(LCP).
- 발행 빈도·내부 링크·번역 커버리지(ko↔en↔ar 1:1)가 장기 순위의 본질.
