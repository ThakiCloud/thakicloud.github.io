---
title: "여섯 번째 학문, 제가 만들었습니다"
excerpt: "이름표가 다섯 장 붙는 동안, 우리는 그냥 우리 서버에서 한 번 돌려봤습니다."
date: 2026-07-31
categories:
  - 만화
tags:
  - ai-agents
  - context-engineering
  - agent-harness
  - on-prem
  - satire
author_profile: true
toc: false
image: /assets/images/posts/만화/the-sixth-engineering-discipline/strip.png
video: /assets/videos/posts/만화/the-sixth-engineering-discipline/comic.mp4
---

프롬프트 엔지니어링에서 시작한 이름표가 컨텍스트, 하네스, 루프를 지나 이제 그래프 엔지니어링까지 왔습니다. 새 용어가 나올 때마다 업계는 그걸 혁명이라 부르지만, 뜯어보면 하는 일은 하나로 모입니다. 프롬프트는 모델에게 말을 어떻게 거느냐, 컨텍스트는 그 순간 무엇을 보여줄지 고르는 일, 하네스는 도구와 검증 규칙을 감싸는 골격, 루프는 결과를 다시 입력으로 넣어 수렴시키는 반복, 그래프는 그 반복들을 노드와 화살표로 이어 설계도로 만든 것입니다. 즉 다섯 개 학문이 아니라 같은 문제를 다섯 번 다시 부른 셈인데, 강의는 다섯 번 팔렸습니다.

![여섯 번째 학문, 제가 만들었습니다](/assets/images/posts/만화/the-sixth-engineering-discipline/strip.png)

> 원 뉴스: [RT @akshay_pachaar: from prompt → context → harness → loop → graph engineering.](https://x.com/hjguyhan/status/2082589434772681072) · twitter

**▶ 만화 영상판 — 캐릭터들이 직접 말합니다**

<video controls playsinline preload="metadata" poster="/assets/images/posts/만화/the-sixth-engineering-discipline/strip.png" style="width:100%;border-radius:8px;">
  <source src="/assets/videos/posts/만화/the-sixth-engineering-discipline/comic.mp4" type="video/mp4">
  <track kind="subtitles" srclang="ko" label="한국어" src="/assets/videos/posts/만화/the-sixth-engineering-discipline/comic.ko.vtt" default>
</video>

[영상 다운로드](/assets/videos/posts/만화/the-sixth-engineering-discipline/comic.mp4)

## ThakiCloud 제품 적용 시사점

이름이 뭐로 바뀌든 마지막 질문은 똑같이 남습니다. 그 루프, 누구 기계에서 도나요. 다키클라우드는 그 질문에 먼저 답하는 쪽을 골랐습니다. 파시스는 에이전트를 실제로 풀고 결과를 다시 물려 수렴시키는 오케스트레이션을 맡고, 메티스는 그 반복이 도는 GPU와 데이터를 회사 시설 안에 둡니다. 온프렘은 남의 데이터센터가 아니라 자기 랙에서 돌린다는 뜻이고, 그래야 학습 데이터와 로그가 밖으로 나가지 않습니다. 이 블로그도 같은 구조로 굴러갑니다. 뉴스를 고르고 대본을 쓰고 그림과 영상을 뽑는 과정이 전부 사내 에이전트 루프고, 그 루프를 부르는 이름은 올해만 다섯 번 바뀌었지만 랙은 그대로 있습니다. 새 용어를 따라잡느라 지치셨다면, 용어 대신 인프라의 주인이 누구인지부터 확인해 보세요.

---

*이 만화는 업계 뉴스를 바탕으로 자동 생성된 초안입니다.*
