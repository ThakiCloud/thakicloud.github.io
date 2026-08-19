---
title: "마스코트 광고 일곱 편, 실제로 만들어진 결과물"
excerpt: "제품마다 한 편씩, 각 42초. 학습은 하지 않았고 캐릭터 스틸 넉 장에서 출발했습니다. 어느 조건화를 골랐는지는 취향이 아니라 컷 수가 정했습니다."
categories:
  - research
tags:
  - video-generation
  - character-consistency
  - ad-production
  - mascot
author_profile: true
toc: true
toc_label: "목차"
header:
  teaser: /assets/images/cf-seven-ads.jpg
---

마스코트로 제품 광고를 만들면 실제로 무엇이 나오는지 궁금한 분을 위한 글입니다. 방법론은
[앞 글](/ko/research/mascot-ad-stills-vs-storyboard/)에 적었고, 여기에는 완성된 일곱 편을 그대로
싣습니다. 각 42초, 1280×720, 캐릭터별 학습은 하지 않았습니다.

## Paxis

업무 자동화 제품입니다. 우주선 함교가 흔들리고 콘솔마다 붉은 경보가 터지는 데서 시작합니다.

<video controls muted playsinline preload="none" poster="{{ site.url }}{{ site.baseurl }}/assets/images/cf-ad-paxis-poster.jpg" style="max-width:100%">
  <source src="{{ site.url }}{{ site.baseurl }}/assets/videos/posts/cf-ad-paxis.mp4" type="video/mp4">
</video>

## Metis

추론과 토큰을 다루는 제품이라 공장 라인을 세계로 잡았습니다. 병입 컨베이어와 증기가 그 은유입니다.

<video controls muted playsinline preload="none" poster="{{ site.url }}{{ site.baseurl }}/assets/images/cf-ad-metis-poster.jpg" style="max-width:100%">
  <source src="{{ site.url }}{{ site.baseurl }}/assets/videos/posts/cf-ad-metis.mp4" type="video/mp4">
</video>

## Maxis

모델을 길러 내는 제품입니다. 정글에서 덩굴을 걷어내고 싹을 틔우는 쪽으로 갔습니다.

<video controls muted playsinline preload="none" poster="{{ site.url }}{{ site.baseurl }}/assets/images/cf-ad-maxis-poster.jpg" style="max-width:100%">
  <source src="{{ site.url }}{{ site.baseurl }}/assets/videos/posts/cf-ad-maxis.mp4" type="video/mp4">
</video>

## Telox

GPU를 실어 나르는 제품이라 증기 기관차와 철로를 세계로 썼습니다.

<video controls muted playsinline preload="none" poster="{{ site.url }}{{ site.baseurl }}/assets/images/cf-ad-telox-poster.jpg" style="max-width:100%">
  <source src="{{ site.url }}{{ site.baseurl }}/assets/videos/posts/cf-ad-telox.mp4" type="video/mp4">
</video>

## Velox

가상화를 걷어낸 속도가 주제입니다. 폭풍이 치는 부두 위를 달립니다.

<video controls muted playsinline preload="none" poster="{{ site.url }}{{ site.baseurl }}/assets/images/cf-ad-velox-poster.jpg" style="max-width:100%">
  <source src="{{ site.url }}{{ site.baseurl }}/assets/videos/posts/cf-ad-velox.mp4" type="video/mp4">
</video>

## Aegis

폐쇄망 안에서 버티는 제품입니다. 불타는 벌판에서 물러서지 않는 금고로 그렸습니다.

<video controls muted playsinline preload="none" poster="{{ site.url }}{{ site.baseurl }}/assets/images/cf-ad-aegis-poster.jpg" style="max-width:100%">
  <source src="{{ site.url }}{{ site.baseurl }}/assets/videos/posts/cf-ad-aegis.mp4" type="video/mp4">
</video>

## Signum

신원을 먼저 묻는 제품이라 밤 골목을 세계로 잡았습니다.

<video controls muted playsinline preload="none" poster="{{ site.url }}{{ site.baseurl }}/assets/images/cf-ad-signum-poster.jpg" style="max-width:100%">
  <source src="{{ site.url }}{{ site.baseurl }}/assets/videos/posts/cf-ad-signum.mp4" type="video/mp4">
</video>

## 어느 방법으로 만들었나

일곱 편이 같은 방법으로 만들어지지 않았습니다. 캐릭터 스틸을 조건으로 주는 방법과 스토리보드
시트를 조건으로 주는 방법을 제품마다 골랐는데, 고르는 규칙을 먼저 정하고 그 규칙에 맡겼습니다.
컷이 적은 쪽이 이기고, 다만 정체성이 0.05를 넘게 벌어지면 그쪽으로 뒤집습니다.

정체성 평균이 0.636 대 0.617로 붙어 있고 컷 수는 중앙값 15개 대 5개로 벌어졌으니, 실제로 갈리는
축에 결정을 맡기고 안 갈리는 축에는 큰 문턱을 둔 셈입니다. 규칙을 돌리자 다섯 편이 스토리보드로,
두 편이 스틸로 갔습니다. 스틸로 남은 둘은 이유가 분명합니다. Metis는 스토리보드 쪽 컷이 26개로
튀어 오른 유일한 예외였고, Telox는 정체성이 0.063 벌어져 문턱을 넘었습니다.

![최종 일곱 편]({{ site.url }}{{ site.baseurl }}/assets/images/cf-seven-ads.jpg)
*일곱 편을 한 장에 놓았습니다. 세계는 제품마다 다르고 캐릭터는 각자 유지됩니다.*

## 만들면서 고친 것

**해상도 기본값.** 처음 뽑은 편들이 눈에 띄게 흐렸는데 원인이 생성 해상도 832×480이었습니다.
스크립트 기본값이었고 아무도 올리지 않았습니다. 1280×720으로 바꾸자 비트레이트가 0.41 Mbps에서
3.0 Mbps로 올라갔습니다. 거기에 재인코딩이 세 번 겹쳐 화질을 더 깎고 있었습니다. 지금은 중간
단계를 무손실급으로 두고 마지막에 한 번만 압축합니다.

**끝 카드 잘림.** 제품 이름과 슬로건이 들어가는 카드를 832픽셀 화면에 877픽셀로 그린 적이
있습니다. 폭을 계산해 놓고 그 값을 확인하지 않았습니다. 지금은 카드를 영상과 같은 해상도로
그리고, 안전 영역을 넘으면 글자를 줄이며, 어떤 크기로도 안 들어가면 예외를 던집니다. 폭을
계산하는 코드는 그 폭에 대한 검사도 함께 져야 합니다.

**학습 클립의 잘림.** 이 프로젝트는 한 번 어댑터 여덟 종을 통째로 버렸습니다. 학습 클립 48개 중
38개에서 캐릭터가 프레임 밖으로 잘려 있었고, 한 캐릭터는 열두 개 전부 잘렸습니다. 그런데 모든
지표가 통과했습니다. 지표가 물은 것이 "일관적인가"였고 아무도 "쓸 만한가"를 묻지 않았기
때문입니다. 잘린 것끼리 일관되면 일관성 점수는 오히려 올라갑니다.

## 학습은 하지 않았습니다

일곱 편 어디에도 캐릭터별 학습이 들어가지 않았습니다. 스틸 넉 장이나 시트 한 장이 전부이고 소리도
모델이 함께 만듭니다. 준비 시간이 없다는 것이 학습 경로와의 가장 큰 차이입니다.

같은 캐릭터로 어댑터를 400스텝 학습시킨 결과도 갖고 있습니다. 정체성 점수가 0.560이었습니다. 이후
실험에서 학습 없이 동작 지시만 넣는 방식이 같은 캐릭터, 같은 평가기, 같은 레퍼런스에서 0.704를
냈습니다. 프롬프트 세트가 서로 달라 통제된 비교는 아니지만, 큰 영상 모델이 이미 아는 것을 다시
가르치기보다 무엇을 그릴지만 지시하는 편이 싸게 먹힌다는 방향은 읽힙니다.

## 남은 한계

정체성 지표로 쓴 CLIP-I는 프레임 전체를 보기 때문에 배경이 비슷하면 점수가 올라가고, 캐릭터 형태가
무너져도 색과 실루엣이 남으면 잘 떨어지지 않습니다. 상대 비교로는 쓸 만하지만 절대 품질로 읽으면
안 됩니다.

그리고 이 방식은 아직 동작 어휘가 좁습니다. 지금 확실히 전달되는 것은 다가오기와 도약 둘이고,
느린 정면 밀어넣기처럼 미묘한 동작은 모델이 무시했습니다. 광고 한 편을 지탱하려면 어휘가 더
필요합니다. 그것이 다음 작업입니다.
