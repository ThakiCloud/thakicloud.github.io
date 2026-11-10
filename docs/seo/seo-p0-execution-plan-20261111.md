# SEO P0 집행안 (실측 2026-11-11, 에이전트는 읽기만 — 집행은 사람)

대상 CloudFront 배포: `E1RQ006X2589V5` (thakicloud.com) · S3 `thakicloud-portal-com`, prefix `tech-blog/`

## 0. 실측 요약
| 검사 | 명령 | 결과 |
|---|---|---|
| apex robots | `curl -s https://thakicloud.com/robots.txt \| grep 'tech-blog/sitemap.xml'` | ✅ 1건 존재 (PR #167 반영 완료) |
| 없는 tech-blog 경로 | `curl -D- https://thakicloud.com/tech-blog/ko/nonexistent-article-abc999/` | ⛔ HTTP/2 200 · `content-type: text/html` · `x-cache: Error from cloudfront` · 92791 B · `canonical=https://thakicloud.com/` → **soft-404 그대로** |
| 없는 전역 경로 | `curl -D- https://thakicloud.com/zzz-nope/` | HTTP 200 · 92791 B (홈과 바이트 동일) → CustomErrorResponses 403/404→`/index.html`(200) |
| apex sitemap-ar | `curl -D- https://thakicloud.com/tech-blog/sitemap-ar.xml` | ⛔ 200 · `text/html` · 92791 B → XML 아님, soft-404 |
| apex sitemap index | `curl https://thakicloud.com/tech-blog/sitemap.xml` | ✅ 200 · `application/xml` · ko/en 2개만 (ar 없음) |
| www | `curl -o/dev/null -w '%{http_code} %{redirect_url}' https://www.thakicloud.com/` | ⛔ 200, Location 없음 → **301 미설정**(별도 200 서빙, canonical 만 apex) |
| github.io ar 203개 | sitemap-ar.xml 파싱 + 전건 probe | ⛔ 203/203 이 github.io 에서 **살아있는 200**, 전건 canonical → apex `/tech-blog/ar/...`(=soft-404) |

근거 문서 `scratchpad/minutes-gtm/seo/seo_audit.md` 는 **레포에 없다** (세션 스크래치패드는 휘발).

## 1. 왜 ar 을 복구하지 않는가
`thakicloud.github.io/_config.yml:207` 에 `exclude: _posts/ar`, 주석에 복구 브랜치
`archive/ar-posts-2026-08-13`. 아랍어는 의도적으로 내린 것이다. ar 빌드 워크플로
(`multilingual-deploy`, `unified-build-deploy`)는 전부 `.disabled`. ⇒ 복구가 아니라
**301/410 로 정리**가 맞다.

## 2. CloudFront 변경안 (`/tech-blog/*` behavior 분리)

⛔ **전역(Default) behavior 의 CustomErrorResponses 는 건드리지 않는다** — apex 는 SPA 이고
404→`/index.html`(200) 폴백이 클라이언트 라우팅의 동작 조건이다. 전역을 404 로 바꾸면 SPA 가 깨진다.

새 Cache Behavior 를 **Default 보다 위 우선순위**로 추가:

- Path pattern: `/tech-blog/*`
- Origin: 기존 S3 OAC 오리진(`thakicloud-portal-com`) 그대로
- Viewer protocol policy: Redirect HTTP to HTTPS
- Allowed methods: GET, HEAD
- Cache policy: 기존 Default 와 동일 (CachingOptimized)
- Function associations:
  - **Viewer request**: CloudFront Function `tech-blog-rewrite`
    (디렉터리 → `index.html` 보정 + ar 301/410 판정, 아래 3절)
- Custom error responses: 이 behavior 는 **오류 폴백을 쓰지 않는다**
  (CloudFront 의 CustomErrorResponses 는 distribution 단위이므로 behavior 로 끌 수 없음 →
   그래서 ① 404 응답 본문을 S3 `tech-blog/404.html` 로 두고 ② 아래 Function 이
   없는 경로를 직접 404/410 로 **종결**하는 방식이 필요하다. 전역 CustomErrorResponses 는
   오리진이 403/404 를 돌려준 경우에만 타므로, Function 이 먼저 응답하면 타지 않는다.)

## 3. CloudFront Function (viewer-request) 의사코드
```js
function handler(event) {
  var req = event.request, uri = req.uri;
  if (!uri.startsWith('/tech-blog/')) return req;          // 전역은 손대지 않음

  // (a) 아랍어 → ko 301 (168건, 목록 ar-301-map-20261111.tsv)
  var m = uri.match(/^\/tech-blog\/ar\/(.*)$/);
  if (m) {
    var ko = '/tech-blog/ko/' + m[1];
    if (AR_301[uri]) return { statusCode:301, statusDescription:'Moved Permanently',
                              headers:{ location:{ value: AR_301[uri] } } };
    // (b) ko 대응본이 없는 32건 + /tech-blog/ar/ + feed-ar.xml → 410
    return { statusCode:410, statusDescription:'Gone',
             headers:{'content-type':{value:'text/html; charset=utf-8'},
                      'cache-control':{value:'max-age=3600'}},
             body:'<!doctype html><title>Gone</title><p>This page has been retired.' };
  }
  // (c) 디렉터리 요청 → index.html (기존 soft-404 의 다른 반쪽)
  if (uri.endsWith('/')) req.uri = uri + 'index.html';
  else if (!uri.includes('.')) req.uri = uri + '/index.html';
  return req;
}
```
`AR_301` 은 168줄짜리 상수 맵. Function 코드 10KB 제한에 걸리면
**CloudFront Function 대신 S3 객체 리디렉션**(`x-amz-website-redirect-location`) 또는
Lambda@Edge 로 올린다. 대안(권장, 더 단순): ar 168건을 **S3 에 0바이트 객체 +
redirect 메타데이터**로 올리고 Function 은 (c) 디렉터리 보정만 한다 — 이러면 S3
웹사이트 엔드포인트 오리진이 필요하므로, 현재 OAC/REST 오리진 구성과 맞는지 먼저 확인할 것.

## 4. 없는 tech-blog 경로의 진짜 404
오리진 S3 에 `tech-blog/404.html` 을 두고, distribution CustomErrorResponses 는 그대로 두되
Function 에서 `/tech-blog/` 하위 미존재 판정은 할 수 없으므로(Function 은 오리진을 못 봄)
**정석은 Lambda@Edge origin-response 에서 403/404 를 404 로 통과시키는 것**이다.
최소 변경으로 soft-404 를 끊는 현실적 순서:
1. 전역 CustomErrorResponses 의 404 매핑에서 **Response page path 를 `/index.html` 로 두되
   Response code 를 200 → 404 로 바꾸는 것은 금지**(SPA 딥링크가 404 로 보인다).
2. 대신 `/tech-blog/*` 전용 **Lambda@Edge origin-response**: 오리진이 404 면
   `tech-blog/404.html` 본문 + statusCode 404 로 반환. 전역은 영향 없음.
⇒ Function 만으로는 (a)(b)(c) 까지, 진짜 404 는 Lambda@Edge 가 필요하다. 이 분기를 사람이 결정.

## 5. www → apex 301
현재 www 가 200 으로 같은 콘텐츠를 서빙한다(canonical 만 apex). 조치:
- Route53 에서 `www.thakicloud.com` 을 **별도 CloudFront 배포**(또는 S3 리디렉션 버킷)로 보내
  전 경로 `301 https://thakicloud.com$request_uri`.
- 또는 현재 배포의 Alias 에서 www 를 제거하고, www 전용 리디렉션 배포를 새로 만든다.
- ⛔ 같은 배포에 두 Alias 를 두고 CloudFront Function 으로 `Host: www` 를 301 하는 방법도 가능
  (가장 적은 리소스): viewer-request 에서 `event.request.headers.host.value === 'www.thakicloud.com'`
  이면 301. 이 경우 1절의 `/tech-blog/*` Function 과 **별개로 Default behavior 에도** Function 이 붙는다.

## 6. 집행 후 검증 (그대로 복사해 쓰면 된다)
```bash
curl -sI https://thakicloud.com/tech-blog/ko/nonexistent-article-abc999/ | head -1   # 404 기대
curl -sI https://thakicloud.com/tech-blog/ar/dev/vllm-production-quality-ci-release/ | sed -n '1p;/^location/Ip'  # 301 + ko
curl -sI https://thakicloud.com/tech-blog/ar/ | head -1                              # 410 기대
curl -s https://thakicloud.com/tech-blog/sitemap.xml | head -3                        # XML 유지
curl -sI https://www.thakicloud.com/ | sed -n '1p;/^location/Ip'                      # 301 → apex
curl -sI https://thakicloud.com/ | head -1                                            # 200 (SPA 무영향)
curl -sI https://thakicloud.com/solutions | head -1                                   # 200 (SPA 딥링크 무영향)
```

## 7. 선후관계 (중요)
`thakicloud.github.io/.github/workflows/gh-pages-redirect.yml` 은 **의도적으로 dormant** 이고
헤더에 "CloudFront Function(디렉토리→index.html) 수정이 확인된 뒤에만 실행" 이라고 적혀 있다.
⇒ 순서: ① `/tech-blog/*` behavior + Function 적용·검증 → ② `gh-pages-redirect.yml` 수동 실행
(github.io 를 301 스텁으로 교체) → ③ github.io `robots.txt` 의 sitemap-ar.xml 줄 제거,
`sitemap-ar.xml` 삭제. ②를 먼저 하면 라이브 링크가 홈 폴백으로 깨진다.

## 8. 산출 목록 파일
- `ar-url-classification-20261111.csv` — 203건 전체 (github.io URL, apex 등가, 상태, 판정, 301 타깃)
- `ar-301-map-20261111.tsv` — 168건 `apex_ar_url<TAB>ko_target`
- `ar-410-list-20261111.txt` — 35줄 (410 대상 32건 + ar 홈 2중복 + feed-ar.xml)
