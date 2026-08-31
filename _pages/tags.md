---
title: "태그"
layout: tags
permalink: /tags/
author_profile: true
sitemap: false
---

<!--
  2026-09-01: 이 페이지가 없어서 태그 링크 전부가 소프트404였다.

  실측: 빌드된 _site 의 **638쪽**이 `href="/tech-blog/tags/#..."` 를 렌더하는데
  `_site/tags/` 자체가 없었다. CloudFront 가 없는 키를 랜딩페이지로 폴백해 200 을
  돌려주므로 상태코드 모니터링에는 초록으로 보인다([[published-url-is-a-promise]]).

  링크 생성원: `_includes/page__taxonomy.html` → 테마 `_includes/tag-list.html` 이
  `site.tag_archive.path`(_config.yml:296 = /tags/) + "#" + slug 로 앵커를 만든다.
  즉 `tag_archive.type: liquid` 를 켜 두면 이 페이지는 **선택이 아니라 전제**다.

  다국어(ko/en)를 한 페이지가 함께 담는다 — 앵커 경로가 언어 중립이라 언어별로
  나누면 링크가 다시 깨진다. sitemap 제외: 색인 대상이 아니라 앵커 착지점이다.
-->
