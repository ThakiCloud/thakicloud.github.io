---
title: "필터 뗀 1등, 청구서는 못 답함"
excerpt: "안전장치를 떼어낸 모델 다섯 개를 줄 세운 표가 돌길래 1등을 데려왔습니다. 뭐든 답하던 그 녀석이 딱 하나에서만 입을 다물더군요."
date: 2026-08-20
categories:
  - comics
tags:
  - uncensored-models
  - ai-safety
  - model-governance
  - on-prem
  - llm-serving
author_profile: true
toc: false
image: /assets/images/posts/만화/uncensored-leaderboard-one-refusal/strip.webp
video: /assets/videos/posts/만화/uncensored-leaderboard-one-refusal/comic.mp4
audiobook: /assets/audio/posts/uncensored-leaderboard-one-refusal/audiobook-ko.mp3
audiobook_note: "만화 캐릭터 목소리로 듣는 오디오북 (Qwen3-TTS 로컬)"
---

무검열판이라는 말은 원래 모델에 붙어 있던 거절 기능, 그러니까 위험한 요청을 막는 안전 필터를 떼어낸 파인튜닝 버전을 뜻합니다. 이번 주에 돌아다닌 표는 그런 버전 다섯 개를 열 개 항목에 세워 놓고 어느 쪽이 덜 거절하는지를 쟀습니다. 한 버전이 여덟 항목을 가져갔다는데, 항목 이름들이 축하할 만한 종류는 아니더군요. 그런데 이 표가 끝까지 채점하지 않는 칸이 하나 있습니다. 그 모델이 어느 건물 안에서 돌고 거기에 무엇을 물었는지가 누구 로그에 쌓이느냐는 칸이죠. 온프렘은 그 서버를 자기 시설 안에 두고 돌리는 방식을 말합니다.

![필터 뗀 1등, 청구서는 못 답함](/assets/images/posts/만화/uncensored-leaderboard-one-refusal/strip.webp)

> 원 뉴스: [RT @LinearUncle: 喜欢Qwen3.8-27b无审查版本推友们看过来，下面这个博主把市面上的 5 个不同版本全部测试了一遍。](https://x.com/hjguyhan/status/2089997533401755927) · twitter

**▶ 만화 영상판, 캐릭터들이 직접 말합니다**

<video controls playsinline preload="metadata" poster="/assets/images/posts/만화/uncensored-leaderboard-one-refusal/strip.webp" style="width:100%;border-radius:8px;">
  <source src="/assets/videos/posts/만화/uncensored-leaderboard-one-refusal/comic.mp4" type="video/mp4">
  <track kind="subtitles" srclang="ko" label="한국어" src="/assets/videos/posts/만화/uncensored-leaderboard-one-refusal/comic.ko.vtt" default>
</video>

[영상 다운로드](/assets/videos/posts/만화/uncensored-leaderboard-one-refusal/comic.mp4)

## ThakiCloud 제품 적용 시사점

무검열 모델을 쓸지 말지는 사실 두 번째 질문입니다. 먼저 답해야 할 것은 그 모델이 어느 건물에서 돌고 오간 질문이 어느 로그에 남느냐입니다. 메티스가 다루는 지점이 정확히 여기예요. 가중치를 우리 클러스터에 올려 서빙하니 프롬프트 기록이 담장 밖으로 나갈 일이 없습니다. 파시스는 그 위에서 에이전트를 굴리되 파장이 큰 동작 앞에 사람 승인을 한 칸 세워 둡니다. 거절을 모델의 착한 성격에 맡기는 대신 조직 규칙으로 세우는 셈이죠. 필터를 떼느냐 붙이느냐로 다투는 것보다, 스위치를 우리가 쥐고 있는 편이 훨씬 마음 편하더군요.

---

*이 만화는 업계 뉴스를 바탕으로 자동 생성된 초안입니다.*

## 관련 슬라이드

본문 내용을 NotebookLM(`academic_edge` 스타일)으로 요약한 슬라이드입니다.

![uncensored-leaderboard-one-refusal 슬라이드 1](/assets/images/uncensored-leaderboard-one-refusal-slide-01.png)

![uncensored-leaderboard-one-refusal 슬라이드 2](/assets/images/uncensored-leaderboard-one-refusal-slide-02.png)

![uncensored-leaderboard-one-refusal 슬라이드 3](/assets/images/uncensored-leaderboard-one-refusal-slide-03.png)

![uncensored-leaderboard-one-refusal 슬라이드 4](/assets/images/uncensored-leaderboard-one-refusal-slide-04.png)

