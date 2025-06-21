---
title: "Jekyll 블로그에서 PPT·PDF 바로 보기 실전 가이드"
excerpt: "GitHub Pages 환경에서도 슬라이드(PPTX)와 PDF를 별도 플러그인 없이 손쉽게 임베드하는 6가지 방법을 정리했습니다."
date: 2025-06-16
categories:
  - dev
  - tutorials
tags:
  - Jekyll
  - GitHub Pages
  - PDF
  - PowerPoint
  - embed
author_profile: true
toc: true
toc_label: "목차"
---

아래는 **Jekyll 기반 블로그(예: GitHub Pages)에서 방문자가 PowerPoint(`*.ppt`, `*.pptx`)와 PDF 파일을 직접 열람**할 수 있게 하는 가장 실용적인 방법을 한눈에 정리한 표입니다. 상황별로 조합해 쓰는 것도 좋습니다. 예를 들어 PDF는 로컬 뷰어로, 슬라이드만 클라우드 뷰어로 띄우는 식이죠.

---

## 1. Ground rules 이해하기

- **Jekyll은 정적 사이트 생성기**이므로 서버 측 변환이 불가능합니다. HTML 임베드, 클라이언트-사이드 JS 뷰어, 외부 서비스 중 하나를 써야 합니다. ([GitHub Pages 정책][1])
- **GitHub Pages는 일부 플러그인만 허용**합니다. `jekyll-pdf-embed` 같은 Gem은 로컬 빌드나 자체 서버에선 동작하지만, GitHub Pages에선 렌더된 HTML을 별도로 배포하지 않는 한 작동하지 않습니다. ([GitHub Pages Gem][1])

---

## 2. 가장 간단한 HTML 임베드 (어디서나 동작)

| File type | Snippet (Markdown에 그대로)                                                        | Pros                                                           | Cons                                               |
| --------- | --------------------------------------------------------------------------------- | -------------------------------------------------------------- | -------------------------------------------------- |
| PDF       | `<embed src="/assets/my.pdf" type="application/pdf" width="100%" height="600" />` | 추가 의존성 0; 브라우저 기본 뷰어 이용                          | iOS·구형 Android는 기능 미흡; 검색·TOC 없음          |
| PPTX¹     | OneDrive 또는 Google Slides에서 생성한 `<iframe>` 코드                              | 변환 단계 없음                                                 | 외부 뷰어; 인터넷 필요                               |

¹ 변환을 꺼린다면 PPTX → PDF 변환 후 위 PDF 행을 재사용하세요.

출처: HTML `<embed>` / `<object>` 방식 ([loveplay1983.github.io][2], [Stack Overflow][3])

---

## 3. 번들 가능한 순수 정적 PDF 뷰어

### 3-A. Mozilla PDF.js

```html
<iframe src="/assets/pdfjs/web/viewer.html?file=/assets/my.pdf" width="100%" height="650"></iframe>
```

- 공식 `pdfjs` 빌드를 `/assets/pdfjs/`에 넣기만 하면 됩니다.
- 검색, 썸네일, 목차, 인쇄, 다운로드 제공.
  참고 ([mozilla.github.io][4])

### 3-B. `jekyll-pdf-embed` Gem

{% raw %}

```liquid
{% pdf https://example.com/report.pdf height="650" %}
```

{% endraw %}

- **PDF, PPT, PPTX** 모두 처리, 반응형 `<iframe>` 자동 래핑.
- 플러그인 활성화가 필요하므로 자체 호스팅 또는 GitHub Actions 배포가 전제.
  소스코드 ([GitHub][5])

### 3-C. `jekyll-spaceship` 플러그인

- MathJax, 반응형 미디어, **PDF 임베드**까지 통합 제공.
- 3-B와 동일한 호스팅 제약.
  소스코드 ([GitHub][6], [jekyll-themes.com][7])

---

## 4. 클라우드 슬라이드 뷰어 (PPTX에 최적)

### 4-A. Microsoft OneDrive / PowerPoint Online

1. 슬라이드를 OneDrive에 업로드.
2. **File → Share → Embed**에서 `<iframe>` 코드 복사 → 포스트에 붙여넣기.

- 애니메이션·발표자 노트 보존.
- Microsoft 뷰어에서 스트리밍.
  참고 ([Microsoft Support][8], [Stack Overflow][9])

### 4-B. Google Slides

1. Slides에서 **File → Publish to web → Embed** 실행.
2. 생성된 `<iframe>`을 Markdown에 붙여넣기.

- Google Workspace를 사용 중인 팀에 적합.
  참고 ([Stack Overflow][10])

### 4-C. Google Docs PDF/PowerPoint Viewer

업로드가 번거롭다면 URL만 공개해 두고 아래처럼 사용하세요.

```html
<iframe src="https://docs.google.com/gview?embedded=1&url=https://example.com/my.pptx" width="100%" height="600"></iframe>
```

- 가볍고 PDF·PPTX 모두 지원.
  참고 ([Stack Overflow][11])

---

## 5. 어떤 상황에 어떤 방법을 쓸까?

| Scenario                                                      | Recommended route                                             |
| ------------------------------------------------------------- | ------------------------------------------------------------- |
| GitHub Pages, 플러그인 불가                                   | PDF는 `<embed>`, PPTX는 OneDrive / Google Slides              |
| PDF에서 검색·썸네일 필요                                     | **PDF.js** 번들 (3-A)                                         |
| 플러그인으로 한방 해결(셀프 호스팅)                           | `jekyll-pdf-embed` (3-B)                                      |
| 이미 **jekyll-spaceship** 사용 중                             | 동일 플러그인 유지 (3-C)                                      |
| 개인정보·오프라인 접근 고려                                   | PPTX → PDF 변환 후 PDF.js 사용                                |

---

## 6. 구현 팁

- **iframe 반응형 처리**: 16:9 예시

  ```css
  .embed-wrap {position: relative; padding-top: 56.25%;}
  .embed-wrap iframe {position: absolute; top:0; left:0; width:100%; height:100%;}
  ```

  실제 예시는 [Stack Overflow][12]를 참고하세요.
- **PDF 미리 압축**(`pdfsizeopt`)으로 정적 번들 용량 최소화.
- **모바일 호환**을 위해 `<a href="file.pdf">Download PDF</a>` 등 대체 링크 추가.
- 자체 뷰어 사용 시 **CORS 헤더**를 꼭 설정하세요.
- 대용량 슬라이드는 Git LFS나 CDN에 보관해 레포를 가볍게 유지합니다.

---

### Bottom-line Recommendation

GitHub Pages에서 가장 간단하고 유지보수 부담 없는 조합은 다음과 같습니다.

1. **PDF** → 작은 문서는 `<embed>` 태그, 검색·UI 필요 시 **PDF.js**.
2. **PPTX** → OneDrive 또는 Google Slides에 업로드 후 `<iframe>` 임베드.

자체 서버(또는 GitHub Actions 활용)라면 `jekyll-pdf-embed`나 `jekyll-spaceship`을 추가해 작성자가 HTML 대신 Liquid 태그 하나만 입력해도 되게 만들 수 있습니다.

이 구성이면 빌드 과정은 순수 정적을 유지하면서 GitHub Pages 플러그인 제약을 지키고, 독자에게는 기기 친화적인 뷰잉 경험을 제공합니다.

[1]: https://github.com/github/pages-gem?utm_source=chatgpt.com
[2]: https://loveplay1983.github.io/posts/how-to-display-pdf-jekyll/?utm_source=chatgpt.com
[3]: https://stackoverflow.com/questions/62206911/jekyll-gh-pages-embed-pdf?utm_source=chatgpt.com
[4]: https://mozilla.github.io/pdf.js/examples/?utm_source=chatgpt.com
[5]: https://github.com/MihajloNesic/jekyll-pdf-embed?utm_source=chatgpt.com
[6]: https://github.com/jeffreytse/jekyll-spaceship?utm_source=chatgpt.com
[7]: https://jekyll-themes.com/jeffreytse/jekyll-spaceship?utm_source=chatgpt.com
[8]: https://support.microsoft.com/en-us/office/embed-a-presentation-in-a-web-page-or-blog-19668a1d-2299-4af3-91e1-ae57af723a60?utm_source=chatgpt.com
[9]: https://stackoverflow.com/questions/7101080/embed-a-powerpoint-in-a-web-page?utm_source=chatgpt.com
[10]: https://stackoverflow.com/questions/39696866/how-to-put-google-slide-on-jekyll?utm_source=chatgpt.com
[11]: https://stackoverflow.com/questions/6137457/how-to-embed-pdfs-that-work-in-all-web-and-mobile-browsers?utm_source=chatgpt.com
[12]: https://stackoverflow.com/questions/39696866/how-to-put-google-slide-on-jekyll
