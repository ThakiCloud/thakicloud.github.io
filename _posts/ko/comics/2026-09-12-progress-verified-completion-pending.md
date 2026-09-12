---
title: "환경은 스케일, 완료는 아직"
excerpt: "논문은 에이전트의 '환경'을 키웠고, 우리 집은 은하 레고를 키웠습니다."
date: 2026-09-12
categories:
  - comics
tags:
  - 에이전트 스케일링
  - Apodex 1.1
  - 실행 환경
  - 온프렘
  - ThakiCloud
  - 병맛만화
author_profile: true
toc: false
image: /assets/images/posts/만화/progress-verified-completion-pending/strip.webp
video: /assets/videos/posts/만화/progress-verified-completion-pending/comic.mp4
canonical_url: "https://thakicloud.com/tech-blog/ko/comics/progress-verified-completion-pending/"
---

이번 주 HuggingFace 트렌딩을 달군 논문 Apodex 1.1은 '복잡한 작업'을 위한 에이전트 지능을 스케일했다고 발표했습니다. 그런데 자세히 보면 뇌가 커진 게 아니라, 에이전트가 실제로 작업하는 실행 환경(executable environment)을 키운 것이 핵심입니다. 여러 에이전트가 긴 작업(long-horizon work)을 단계로 나눠 조율하게 훈련하고, 진행 상태를 기록해 중간에 어긋나도 복구해서 다시 이어 가게 하는 방식이에요. 이 '환경 스케일링'을 그대로 따라 해 본 우리 4살 리더 유진이, 회사에서 말하는 '복잡한 일'의 정석인 은하 레고에 전사적 에이전트를 투입하는 과정을 볼 수 있습니다.

![환경은 스케일, 완료는 아직](/assets/images/posts/만화/progress-verified-completion-pending/strip.webp)

> 원 뉴스: [Apodex 1.1: Scaling Agentic Intelligence for Complex Work](https://huggingface.co/papers/2608.23283) · hf-trending

**▶ 만화 영상판: 캐릭터들이 직접 말합니다 (한국어 자막 포함)**

<video controls playsinline preload="metadata" poster="/assets/images/posts/만화/progress-verified-completion-pending/strip.webp" style="width:100%;border-radius:8px;">
  <source src="/assets/videos/posts/만화/progress-verified-completion-pending/comic.mp4" type="video/mp4">
  <track kind="subtitles" srclang="ko" label="한국어" src="/assets/videos/posts/만화/progress-verified-completion-pending/comic.ko.vtt" default>
</video>

[영상 다운로드](/assets/videos/posts/만화/progress-verified-completion-pending/comic.mp4)

## ThakiCloud 제품 적용 시사점

Apodex 1.1이 가리키는 레버는 ThakiCloud가 매일 굴리는 지점과 정확히 겹칩니다. 성능이 '모델을 더 크게'에서 나오는 게 아니라, 에이전트가 작업하는 환경을 얼마나 잘 설계했는지에서 나온다는 것. 파시스는 바로 그 하네스를 제품으로 두고 있습니다. 에이전트를 풀면 풀리는 대로 오케스트레이션이 작업 상태를 붙잡고, 어긋난 구간은 복귀해서 이어 갑니다. 메티스는 같은 작업 위에 학습·추론 비용을 얹어, 어떤 레버가 실제로 진행을 만들었는지를 추론 차원에서 확인해 줍니다. 그리고 차이가 하나 더 있습니다. 이 환경이 어디서 돌느냐. 온프렘이면 스케일을 키울 때마다 남의 계량기가 아니라 우리 전기요금이 오릅니다. 자학이 절반인 말이지만, 소유도 절반은 그렇습니다.

---

*이 만화는 업계 뉴스를 바탕으로 자동 생성된 초안입니다.*

## 관련 슬라이드

본문 내용을 NotebookLM(`academic_edge` 스타일)으로 요약한 슬라이드입니다.

![progress-verified-completion-pending 슬라이드 1](/assets/images/progress-verified-completion-pending-slide-01.webp)

![progress-verified-completion-pending 슬라이드 2](/assets/images/progress-verified-completion-pending-slide-02.webp)

![progress-verified-completion-pending 슬라이드 3](/assets/images/progress-verified-completion-pending-slide-03.webp)

![progress-verified-completion-pending 슬라이드 4](/assets/images/progress-verified-completion-pending-slide-04.webp)

