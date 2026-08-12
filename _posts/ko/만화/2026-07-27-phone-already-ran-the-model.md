---
title: "폰이 다 하는데 왜 파리 밖으로"
excerpt: "손가락 다섯 개 세겠다고 파리 하늘 위로 프레임을 쏘아 올렸다."
date: 2026-07-27
categories:
  - 만화
tags:
  - 온디바이스AI
  - 오픈소스
  - 프라이버시
  - 온프렘
  - 엣지추론
author_profile: true
toc: false
image: /assets/images/posts/만화/phone-already-ran-the-model/strip.png
video: /assets/videos/posts/만화/phone-already-ran-the-model/comic.mp4
published: false
---

손이나 얼굴을 인식하는 모델을 쓰려면 영상을 어딘가로 올려야 한다고 생각하기 쉽습니다. 구글이 오픈소스로 공개한 실시간 ML 툴킷은 그 전제를 뒤집었습니다. 얼굴과 손, 자세, 제스처, 사물 인식을 휴대폰과 브라우저, 임베디드 기기 안에서 바로 처리하죠.
이런 방식을 온디바이스 추론이라고 부릅니다. 데이터를 모델이 있는 곳으로 보내는 대신, 모델을 데이터가 있는 자리로 내려보내 계산을 끝내는 겁니다. 업로드가 사라지니 응답이 빨라지고, 내 사진이 남의 서버를 거칠 일도 없습니다. 별 3만 6천 개가 괜히 붙은 게 아니에요.

![폰이 다 하는데 왜 파리 밖으로](/assets/images/posts/만화/phone-already-ran-the-model/strip.png)

> 원 뉴스: [RT @hank_aibtc: 还在为端侧AI推理又慢又耗电、隐私还担心云端上传而头疼吗？  ](https://x.com/hjguyhan/status/2081393928230838346) · twitter

**▶ 만화 영상판, 캐릭터들이 직접 말합니다**

<video controls playsinline preload="metadata" poster="/assets/images/posts/만화/phone-already-ran-the-model/strip.png" style="width:100%;border-radius:8px;">
  <source src="/assets/videos/posts/만화/phone-already-ran-the-model/comic.mp4" type="video/mp4">
  <track kind="subtitles" srclang="ko" label="한국어" src="/assets/videos/posts/만화/phone-already-ran-the-model/comic.ko.vtt" default>
</video>

[영상 다운로드](/assets/videos/posts/만화/phone-already-ran-the-model/comic.mp4)

## ThakiCloud 제품 적용 시사점

온디바이스는 결국 크기를 줄인 온프렘입니다. 온프렘은 모델과 데이터를 남의 시설이 아니라 내 시설 안에서 굴리는 방식이고, 폰이든 사내 랙이든 발상은 똑같아요. 다키클라우드는 그 발상을 회사 규모로 옮겨 놓았습니다. 메티스가 학습과 서빙을 고객 시설 안 GPU에서 끝내고, 파시스가 그 위에서 에이전트를 굴립니다.
프레임 하나 밖으로 나가지 않는 구조라 감사 로그가 짧아지고, 청구서에 '업로드'라는 줄이 아예 생기지 않습니다. 손바닥만 한 기기도 자기 안에서 추론을 끝내는데, 서버 랙이 못 할 이유는 없죠.

---

*이 만화는 업계 뉴스를 바탕으로 자동 생성된 초안입니다.*
