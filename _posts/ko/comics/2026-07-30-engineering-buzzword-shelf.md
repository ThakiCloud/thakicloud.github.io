---
title: "이름만 다섯 번 바뀐 그거"
excerpt: "프롬프트에서 그래프까지 학문이 다섯 개 생겼는데, 압축해보니 종이 한 장이었습니다."
date: 2026-07-30
categories:
  - comics
tags:
  - ai-engineering
  - agent-harness
  - buzzword-fatigue
  - on-prem
  - sovereign-ai
author_profile: true
toc: false
image: /assets/images/posts/만화/engineering-buzzword-shelf/strip.webp
video: /assets/videos/posts/만화/engineering-buzzword-shelf/comic.mp4
published: false
---

어제 X에서 돌던 한 줄이 유난히 찔렸습니다. 프롬프트 엔지니어링에서 컨텍스트, 하니스, 루프, 이제 그래프 엔지니어링까지, 용어는 계속 늘어나고 새 이름마다 혁명 취급을 받는다는 이야기였죠.
각각을 한 줄로 풀면 이렇습니다. 프롬프트는 무엇을 어떻게 물을지, 컨텍스트는 무엇을 얼마나 보여줄지, 하니스는 모델 주위에 붙이는 배선(도구·검증 게이트·출력 계약), 루프는 결과를 다시 넣어 통과할 때까지 반복하는 것, 그래프는 그 단계들을 노드와 간선으로 엮어 흐름을 고정하는 것입니다.
다섯 개 다 쓸모 있는 개념이고, 저희도 매일 씁니다. 다만 이름이 다섯 개로 늘어난다고 문제가 다섯 개로 쪼개지진 않습니다. 늘어나는 건 보통 청구서의 항목 수예요.

![이름만 다섯 번 바뀐 그거](/assets/images/posts/만화/engineering-buzzword-shelf/strip.webp)

> 원 뉴스: [RT @akshay_pachaar: from prompt → context → harness → loop → graph engineering.](https://x.com/hjguyhan/status/2082589434772681072) · twitter

**▶ 만화 영상판, 캐릭터들이 직접 말합니다**

<video controls playsinline preload="metadata" poster="/assets/images/posts/만화/engineering-buzzword-shelf/strip.webp" style="width:100%;border-radius:8px;">
  <source src="/assets/videos/posts/만화/engineering-buzzword-shelf/comic.mp4" type="video/mp4">
  <track kind="subtitles" srclang="ko" label="한국어" src="/assets/videos/posts/만화/engineering-buzzword-shelf/comic.ko.vtt" default>
</video>

[영상 다운로드](/assets/videos/posts/만화/engineering-buzzword-shelf/comic.mp4)

## ThakiCloud 제품 적용 시사점

저희가 이 흐름에서 배운 건 하나입니다. 이름이 아니라 그 아래 깔린 배선을 소유해야 남는다는 것.
파시스는 에이전트를 여러 갈래로 풀고 결과를 검증 게이트로 닫는 오케스트레이터입니다. 하니스든 루프든 그래프든, 결국 여기서 도구를 붙이고 실패를 되돌리는 배선 작업이죠. 메티스는 그 배선이 실제로 도는 플랫폼이고, 저희는 그걸 고객 시설 안에서 돌립니다. 온프렘은 자기 건물 안 하드웨어에서 돌리는 방식이고, 주권은 모델과 데이터, 인프라를 내 통제 아래 두는 상태를 말합니다.
이 만화도 그 배선의 산물입니다. 뉴스를 고르고 대본을 쓰고 그림을 뽑고 영상을 붙이는 과정 전부가 저희 파이프라인 안에서 돌아갑니다. 그러니 다음 분기에 여섯 번째 이름이 나와도 크게 놀랄 일은 없습니다. 이사만 안 가면 되니까요.

---

*이 만화는 업계 뉴스를 바탕으로 자동 생성된 초안입니다.*
