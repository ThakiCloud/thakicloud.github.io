---
title: "실패만 파던 AI가 상 받음"
excerpt: "약점 콕 집어 고치면 이긴대. 근데 파시스 약점은 '그만 풀기'였음"
date: 2026-07-11
categories:
  - 만화
tags:
  - TRACE
  - agentic-training
  - self-improvement
  - on-prem
  - sovereignty
  - ai-coding
author_profile: true
toc: false
image: /assets/images/posts/만화/trace-targeted-self-improvement/strip.png
audiobook: /assets/audio/posts/trace-targeted-self-improvement/audiobook-ko.mp3
audiobook_note: "만화 캐릭터 목소리로 듣는 오디오북 (Qwen3-TTS 로컬)"
---

이번 주 화제는 'TRACE'라는 연구입니다. ICML 워크숍에서 스포트라이트로 뽑혔는데요, 핵심은 의외로 단순합니다. 에이전트가 아무거나 마구 학습하는 대신, 자기가 실패한 기록을 되짚어 '지금 나에게 부족한 능력이 정확히 뭔가'를 먼저 진단하고, 딱 그 부분만 골라 훈련합니다. 무작정 강화학습을 돌리거나(direct RL), 프롬프트를 갈아끼우거나(GEPA), 가짜 데이터를 붓는 방식보다 이 '약점 조준' 방식이 더 잘 나왔다고 합니다. 힘으로 밀어붙이는 것보다, 어디가 약한지 아는 게 이긴 셈이죠.

![실패만 파던 AI가 상 받음]({{ '/assets/images/posts/만화/trace-targeted-self-improvement/strip.png' | relative_url }})

> 원 뉴스: [RT @hangoo_kang: “TRACE: Capability-Targeted Agentic Training” got Spotlight @ ICML AIWILD 🎉](https://x.com/hjguyhan/status/2075500035207565421) · twitter

## ThakiCloud 제품 적용 시사점

다키클라우드가 오래 밀어온 그림과 정확히 맞닿습니다. 파시스는 에이전트를 지휘하고, 메티스는 그 에이전트가 부족한 능력을 다시 학습시킵니다. TRACE의 교훈은 '실패 기록을 진단해 약점만 다시 훈련하라'인데, 그 실패 기록이야말로 회사의 가장 민감한 자산입니다. 남의 클라우드에 로그를 통째로 넘겨서 훈련시키면 약점도, 그걸 고친 노하우도 밖으로 새어 나갑니다. 온프렘(자기 시설 안에서 돌리는 방식)과 주권(모델·데이터·인프라를 내 통제 아래 두는 것)이 필요한 이유가 여기 있습니다. 실패는 집에서 고쳐야 새지 않으니까요. 참고로 이 블로그도 실패를 회고해 스킬을 다시 벼리는 자기개선 루프로 굴러갑니다.

---

*이 만화는 업계 뉴스를 바탕으로 자동 생성된 초안입니다.*
