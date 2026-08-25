---
title: "흐려질 일 없는 영상, 흐려지는 청구서"
excerpt: "영상 엔진이 이미지 모델의 '공간 주의'를 이식했대. 100컷 찍어도 얼굴이 안 바뀌고, 화질도 안 흐려지는데, 흐려지는 건 클라우드 청구서."
date: 2026-08-25
categories:
  - comics
tags:
  - fusion-model
  - spatial-attention
  - sharpness-creep
  - open-weights
  - onprem
  - serving-cost
author_profile: true
toc: false
image: /assets/images/posts/만화/nothing-blurs-but-the-invoice/strip.webp
video: /assets/videos/posts/만화/nothing-blurs-but-the-invoice/comic.mp4
canonical_url: "https://thakicloud.com/tech-blog/ko/comics/nothing-blurs-but-the-invoice/"
---

영상 모델이 이미지 모델의 '공간 주의'를 이식했다는 소식입니다. 공간 주의는 '무엇이 어디에 있는지'를 아는 시야예요. 이 시야를 영상 엔진에 주면 세트와 텍스처가 풍성해지고 컷을 많이 찍어도 캐릭터의 얼굴이 안 바뀝니다. 예전에는 샷이 넘어갈 때마다 화질이 서서히 흐려지는 '샤프니스 크립' 문제가 있었는데 이번에 그 문제도 사라졌다고 합니다. 다만 이런 모델을 어디서 돌리느냐는 또 다른 이야기입니다.

![흐려질 일 없는 영상, 흐려지는 청구서](/assets/images/posts/만화/nothing-blurs-but-the-invoice/strip.webp)

> 원 뉴스: [RT @C_of_Creativity: MiniMax-H3とZ-Imageの融合モデルでたー！！](https://x.com/hjguyhan/status/2091645755002065017) · twitter

**▶ 만화 영상판: 캐릭터들이 직접 말합니다 (한국어 자막 포함)**

<video controls playsinline preload="metadata" poster="/assets/images/posts/만화/nothing-blurs-but-the-invoice/strip.webp" style="width:100%;border-radius:8px;">
  <source src="/assets/videos/posts/만화/nothing-blurs-but-the-invoice/comic.mp4" type="video/mp4">
  <track kind="subtitles" srclang="ko" label="한국어" src="/assets/videos/posts/만화/nothing-blurs-but-the-invoice/comic.ko.vtt" default>
</video>

[영상 다운로드](/assets/videos/posts/만화/nothing-blurs-but-the-invoice/comic.mp4)

## ThakiCloud 제품 적용 시사점

ThakiCloud 관점에서 이 뉴스는 '모델은 어디서 돌리나'를 다시 묻게 합니다. 융합 모델을 내려받을 수 있다 해도 이 모델을 돌리는 GPU가 남의 집이라면 프레임당 정산은 피할 길이 없습니다. Metis는 모델을 온프렘 GPU에서 서빙합니다. 그러면 서빙 비용은 외부 청구서가 아니라 전기세로 끝나요. Paxis는 이 기반 위에서 워크플로를 실행하며 온프렘이니까 남의 집 계기기에 의존하지도 않아요. 공간 주의가 컷을 건너 얼굴을 일관되게 만듭니다. 마찬가지로 실행 환경의 주권이 비용 구조를 일관되게 만듭니다.

---

*이 만화는 업계 뉴스를 바탕으로 자동 생성된 초안입니다.*

## 관련 슬라이드

본문 내용을 NotebookLM(`neo_swiss` 스타일)으로 요약한 슬라이드입니다.

![nothing-blurs-but-the-invoice 슬라이드 1](/assets/images/nothing-blurs-but-the-invoice-slide-01.webp)

![nothing-blurs-but-the-invoice 슬라이드 2](/assets/images/nothing-blurs-but-the-invoice-slide-02.webp)

![nothing-blurs-but-the-invoice 슬라이드 3](/assets/images/nothing-blurs-but-the-invoice-slide-03.webp)

![nothing-blurs-but-the-invoice 슬라이드 4](/assets/images/nothing-blurs-but-the-invoice-slide-04.webp)

