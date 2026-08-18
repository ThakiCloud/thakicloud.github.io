---
title: "팔로워 1등 했더니 전부 내 클론"
excerpt: "성장 곡선을 만리장성처럼 세우려 했는데, 장성에도 내리막이 있더라고요."
date: 2026-07-28
categories:
  - 만화
tags:
  - growth-metrics
  - vanity-metric
  - startup
  - on-prem
  - agents
author_profile: true
toc: false
image: /assets/images/posts/만화/follower-growth-chart-clones/strip.webp
video: /assets/videos/posts/만화/follower-growth-chart-clones/comic.ko.mp4
published: false
---

지난 90일 동안 X 팔로워가 얼마나 늘었는지로 스타트업 순위를 매긴 표가 타임라인을 돌았습니다. 이런 숫자를 흔히 허영 지표라고 부릅니다. 보기에는 근사한데 매출이나 재방문율 같은 실제 사업 체력과는 연결이 헐거운 지표라는 뜻이죠. 문제는 순위표가 뜨는 순간 모두가 그 숫자를 올리는 쪽으로 뛴다는 데 있습니다. 그래서 유진과 파시스, 메티스도 만리장성 위에 올라가 우리 곡선을 세워보기로 합니다. 성벽이 오르막만 있는 게 아니라는 사실은 뛰기 시작한 다음에 알게 됩니다.

![팔로워 1등 했더니 전부 내 클론](/assets/images/posts/만화/follower-growth-chart-clones/strip.webp)

> 원 뉴스: [RT @benln: Pulled the fastest-growing startups on X by follower growth over last 90 days: https://t.co/RTy5umq7QO](https://x.com/hjguyhan/status/2081867551878070739) · twitter

**▶ 만화 영상판, 캐릭터들이 직접 말합니다 (한국어 자막 포함)**

<video controls playsinline preload="metadata" poster="/assets/images/posts/만화/follower-growth-chart-clones/strip.webp" style="width:100%;border-radius:8px;">
  <source src="/assets/videos/posts/만화/follower-growth-chart-clones/comic.ko.mp4" type="video/mp4">
  <track kind="subtitles" srclang="ko" label="한국어" src="/assets/videos/posts/만화/follower-growth-chart-clones/comic.ko.vtt" default>
</video>

[영상 다운로드](/assets/videos/posts/만화/follower-growth-chart-clones/comic.ko.mp4)

## ThakiCloud 제품 적용 시사점

남의 플랫폼에 있는 숫자는 그 플랫폼 규칙이 바뀌면 같이 흔들립니다. 반대로 내 시설 안에서 나온 숫자는 누가 기울여도 기울지 않죠. ThakiCloud가 온프렘, 그러니까 자기 데이터센터 안에서 모델과 데이터를 돌리는 방식을 고집하는 이유도 여기 있습니다. 메티스는 GPU 가동률과 큐 대기시간, 잡별 실제 처리량을 그대로 보여주고, 파시스는 에이전트를 몇 마리 풀었는지가 아니라 그 에이전트들이 통과시킨 검증 게이트 수로 스스로를 채점합니다. 이 만화도 그렇게 굴러갑니다. 뉴스를 고르고 대본을 쓰고 그림을 뽑는 파이프라인 전체가 사내 랙 위에서 돌고, 품질 판정은 모델의 자기 보고가 아니라 코드가 계산한 게이트가 합니다. 팔로워는 늘면 좋고, 가동률은 늘면 돈이 됩니다.

---

*이 만화는 업계 뉴스를 바탕으로 자동 생성된 초안입니다.*
