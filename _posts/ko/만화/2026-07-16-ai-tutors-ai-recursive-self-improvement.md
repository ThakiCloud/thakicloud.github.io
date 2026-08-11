---
title: "AI가 AI 과외하니 하루만에 93점"
excerpt: "AI가 AI를 하루만에 우등생 만듦 근데 밤새 돌린 GPU는 누구 거임?"
date: 2026-07-16
categories:
  - 만화
tags:
  - 재귀적자기개선
  - 사후학습
  - AI코딩
  - 온프렘
  - GPU비용
  - 주권AI
author_profile: true
toc: false
image: /assets/images/posts/만화/ai-tutors-ai-recursive-self-improvement/strip.png
audiobook: /assets/audio/posts/ai-tutors-ai-recursive-self-improvement/audiobook-ko.mp3
audiobook_note: "만화 캐릭터 목소리로 듣는 오디오북 (Qwen3-TTS 로컬)"
published: false
---

엔비디아가 흥미로운 실험 하나를 공개했습니다. 코딩 에이전트 Codex에게 프롬프트 딱 두 개를 줬더니, 작은 모델 Cosmos 3 Nano의 정확도를 하루 만에 54.41%에서 93.35%까지 끌어올렸다는 겁니다. AI가 다른 AI를 가르쳐 더 똑똑하게 만든 셈이죠. 이렇게 AI가 스스로를 개선하는 고리를 재귀적 자기개선(RSI)이라 부릅니다. 여기 쓰인 '사후학습'은 이미 만들어둔 모델을 추가로 다듬어 성능을 올리는 방법을 말합니다. 파시스와 메티스가 이 자기개선 마라톤을 폭포 앞에서 지켜봅니다.

![AI가 AI 과외하니 하루만에 93점]({{ '/assets/images/posts/만화/ai-tutors-ai-recursive-self-improvement/strip.png' | relative_url }})

> 원 뉴스: [RT @kimmonismus: NVIDIA says Codex post-trained Cosmos 3 Nano from 54.41% to 93.35% accuracy in one day - with two prompts](https://x.com/hjguyhan/status/2077521669154132233) · twitter

## ThakiCloud 제품 적용 시사점

자기개선 루프의 함정은 성능만 오르는 게 아니라는 데 있습니다. 모델이 좋아지는 만큼 GPU도 쉬지 않고 돌고, 그 시간은 고스란히 비용으로 쌓입니다. 남의 클라우드에서 이 고리를 돌리면 똑똑해지는 건 모델인데 늘어나는 건 청구서가 되기 쉽죠. 다키클라우드 메티스는 학습과 추론을 회사 자기 시설 안(온프렘)에서 돌리도록 설계돼, 자기개선의 결과물과 그 연산이 모두 내 통제 아래 남습니다. 파시스로 에이전트가 모델을 다듬고 메티스가 그 학습을 받아내는 고리를, 남의 요금 계량기가 아니라 내 랙 위에서 굴리자는 이야기입니다.

---

*이 만화는 업계 뉴스를 바탕으로 자동 생성된 초안입니다.*

## 관련 슬라이드

본문 내용을 NotebookLM(`cinematic_infographic` 스타일)으로 요약한 슬라이드입니다.

![ai-tutors-ai-recursive-self-improvement 슬라이드 1](/assets/images/ai-tutors-ai-recursive-self-improvement-slide-01.png)

![ai-tutors-ai-recursive-self-improvement 슬라이드 2](/assets/images/ai-tutors-ai-recursive-self-improvement-slide-02.png)

![ai-tutors-ai-recursive-self-improvement 슬라이드 3](/assets/images/ai-tutors-ai-recursive-self-improvement-slide-03.png)

![ai-tutors-ai-recursive-self-improvement 슬라이드 4](/assets/images/ai-tutors-ai-recursive-self-improvement-slide-04.png)

