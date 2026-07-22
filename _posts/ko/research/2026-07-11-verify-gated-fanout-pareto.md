---
title: "적은 검증이 더 안전하다: 멀티에이전트 검증 게이트의 비용-품질 곡선을 실측하다"
seo_title: "Verify-Gated Fan-Out: 멀티에이전트 검증 비용-품질 Pareto 곡선 실측 연구"
seo_description: "멀티에이전트 fan-out 파이프라인에서 검증자 모델 등급과 스켑틱 수를 올릴수록 안전해진다는 통념을 180회 실제 API 호출로 반증한 연구를 소개합니다. 가장 싼 등급, 최소 인원 구성이 Pareto 최적점이었습니다."
excerpt: "모든 fan-out은 적대적 검증으로 닫아야 한다는 원칙은 널리 퍼져 있지만, 검증자 등급과 스켑틱 수를 얼마나 써야 하는지는 실측 없이 관행으로 정해져 왔습니다. 12개 findings와 180회 실제 API 호출로 이 가정을 검증한 결과를 소개합니다."
date: 2026-07-11
tags: [멀티에이전트, LLM오케스트레이션, 적대적검증, 모델라우팅, 비용최적화, 환각탐지, AI에이전트, 스킬오케스트레이션]
categories: [research]
author_profile: true
toc: true
audiobook: /assets/audio/posts/verify-gated-fanout-pareto/audiobook-ko.mp3
audiobook_note: "AI 로컬 합성 오디오북 (Qwen3-TTS)"
canonical_url: "https://thakicloud.com/tech-blog/ko/research/verify-gated-fanout-pareto/"
---

여러 에이전트를 병렬로 실행해 결과를 취합하는 fan-out 파이프라인을 운영하거나 도입을 검토하는 클라우드·AI 엔지니어라면, 검증 단계에 어떤 모델을 얼마나 붙일지 한 번쯤 관행적으로 정해본 경험이 있을 것입니다. 이 글은 그 관행이 실제로는 어떤 비용을 치르고 어떤 안전을 사는지 실측한 연구를 소개합니다. 결론부터 말하면, 더 비싼 모델을 더 많이 투입하는 쪽이 항상 안전한 것은 아니었습니다.

## 문제의식: 검증 원칙은 있는데 실측은 없었다

여러 워커 에이전트가 각자 결과를 만들어내는 멀티에이전트 시스템에서는, 저비용 워커 모델이 그럴듯하지만 실제로는 근거 없는 결과를 내놓을 위험이 늘 존재합니다. 이를 막기 위해 실무에서는 "모든 fan-out은 적대적 검증으로 닫는다"는 원칙이 자리 잡았습니다. 워커가 내놓은 finding을 여러 명의 독립적인 스켑틱(skeptic) 에이전트가 반증하려 시도하고, 정해진 임계값을 넘는 반증이 모이면 코드가 그 finding을 자동으로 폐기하는 방식입니다.

문제는 이 원칙 안에 있는 두 변수, 즉 스켑틱을 맡을 검증자 모델의 등급과 스켑틱을 몇 명 붙일지, 그리고 어떤 다수결 규칙을 쓸지가 대부분 실측 없이 고정된 채로 쓰여왔다는 점입니다. 더 비싼 모델을 검증자로 쓰면 더 안전하고, 스켑틱을 더 많이 붙이면 더 안전하다는 가정은 직관적으로 그럴듯하지만, 실제 멀티에이전트 하네스에서 정답이 알려진 벤치마크로 이 가정을 확인한 연구는 이 논문 이전까지 없었습니다.

## 핵심 기여: 12개 findings, 180회 실제 API 호출로 27개 설정을 재구성하다

연구진은 실제 프로덕션급 멀티에이전트 오케스트레이션 하네스 위에서 통제된 벤치마크를 만들었습니다. 진짜로 타당한 finding 6개와 의도적으로 조작한 가짜 finding 6개, 총 12개를 준비하고, Haiku·Sonnet·Opus 세 검증자 등급 각각에 대해 finding마다 5명의 독립 스켑틱 verdict를 받았습니다. 이렇게 실제로 수집한 API 호출은 180회, 실패는 0건, 총비용은 96.91달러였습니다. 여기서 핵심적인 방법론은 이 하나의 draw를 사후에 잘라(post-hoc slicing) 스켑틱 인원 N(1/3/5)과 다수결·전원일치·단일거부(strict veto) 세 임계규칙을 조합한 27개 설정 전체를 추가 호출 없이 결정론적으로 재구성했다는 점입니다.

![Cost vs. Hallucination Survival Rate by Tier and Breadth](/assets/images/posts/research/verify-gated-fanout-pareto/fig_pareto_cost_quality.png)
*비용 대비 환각 생존율을 등급·인원별로 나타낸 실측 결과입니다. Opus에서 다수결·전원일치를 3~5명 규모로 쓴 경우를 제외하면 검증을 거친 모든 설정이 환각을 완전히 걸러냈고(0.0), 검증하지 않은 기준선은 모든 finding을 그대로 통과시켰습니다(1.0). Haiku 1명 구성(3.46달러)이 유일하게 Pareto 최적점이었습니다.*

가장 먼저 확인된 사실은 27개 설정 중 Pareto 최적점이 정확히 하나, 그것도 가장 싼 조합이었다는 것입니다. Haiku 스켑틱 1명만으로 12개 finding 전체를 검증하는 데 든 비용은 3.46달러였는데, 이 구성이 환각 생존율 0.0과 진짜 finding 생존율 1.0을 동시에 달성했습니다. 나머지 26개 설정은 비용·환각 억제·진짜 finding 보존 세 축 중 어느 하나에서라도 이 구성보다 못했습니다.

두 번째로 눈에 띄는 결과는 Opus가 단 한 번도 Pareto 최적이 아니었다는 점입니다. Opus를 1명만 써도 Sonnet 1명과 품질은 똑같은데 비용은 1.68배였고, Opus를 5명으로 다수결 규칙에 쓴 경우에는 최적점보다 15.66배 비싸면서 환각 생존율이 오히려 0.167로 더 나빠졌습니다. 검증자 등급을 올리는 쪽이 안전을 산다는 실무 직관이 이 벤치마크에서는 성립하지 않았습니다.

![Cost vs. True-Finding Survival Rate by Tier](/assets/images/posts/research/verify-gated-fanout-pareto/fig_cost_true_survival.png)
*진짜 finding이 검증을 통과하는 비율을 등급별로 나타낸 실측 결과입니다. Sonnet과 Opus는 모든 인원·규칙 조합에서 진짜 finding을 하나도 잃지 않았지만(1.0), Haiku를 단일거부 규칙으로 3명·5명 구성했을 때는 스켑틱의 오판으로 진짜 finding 하나가 잘못 폐기됐습니다(0.833).*

가장 흥미로운 발견은 스켑틱 인원을 늘리는 것이 항상 더 안전하지는 않다는 것이었습니다. Opus·다수결 조합에서 스켑틱을 3명에서 5명으로 늘리자 환각 생존율이 0.0에서 0.167로 오히려 악화됐습니다. 원인을 추적한 결과, 특정 가짜 finding 하나에 대해 5명 중 2명만 올바르게 반증했습니다(정답률 40%). 3명짜리 슬라이스에서는 2/3, 즉 67%로 과반을 넘겨 해당 finding이 폐기됐지만, 5명짜리 슬라이스에서는 같은 2명의 정답이 2/5, 즉 40%로 과반에 못 미쳐 finding이 살아남았습니다. 이는 스켑틱 개별 정답률이 50%를 밑도는 어려운 항목에서 상대다수결 규칙이 구조적으로 취약해지는, 콩도르세 역설과 같은 형태의 표 희석 현상입니다.

![Non-Monotonicity: Adding More Skeptics Can Harm Verification Safety](/assets/images/posts/research/verify-gated-fanout-pareto/fig_nonmonotonicity.png)
*스켑틱 인원을 늘릴수록 오히려 검증 안전성이 떨어지는 비단조 현상을 보여주는 분석 그래프입니다. Opus 다수결 규칙에서 환각 생존율은 N=1일 때 0.0이었다가 N=5에서 0.167로 상승했으며, 이는 개별 스켑틱 정답률이 항목별로 50% 아래로 떨어질 때 다수결 집계가 구조적으로 안전을 잃는다는 콩도르세식 희석 효과와 일치합니다.*

이 결과는 규칙 선택의 중요성도 드러냅니다. "전원일치"는 이름만 보면 가장 신중한 규칙 같지만, 실제로는 Opus 등급에서 N=3, N=5 모두 환각 생존율 0.167을 기록해 가장 취약한 규칙이었습니다. 반대로 스켑틱 1명이라도 반증하면 즉시 폐기하는 단일거부(strict veto) 규칙은 모든 등급·모든 인원 구성에서 환각 생존율 0을 달성한 유일한 규칙이었습니다. 다만 이 규칙에도 대가는 있어서, 저비용 등급인 Haiku에서는 노이즈로 인한 스켑틱의 오판이 진짜 finding을 잘못 폐기하는 사례가 소폭 발생했습니다(진짜 finding 생존율 0.833).

## 회사·사회·과학 기여

ThakiCloud는 "fan-out은 검증으로 닫는다"는 원칙을 이미 하우스룰로 운영해 왔지만, 검증자 등급과 스켑틱 인원, 다수결 규칙의 최적 조합은 그동안 서술적인 원칙으로만 존재했지 실측된 적이 없었습니다. 이번 연구는 실제 프로덕션 하네스와 결정론적 집계 스크립트로 얻은 Pareto 곡선을 제공함으로써, 스킬 리뷰나 리서치 fan-out, 논문 파이프라인처럼 이미 운영 중인 멀티에이전트 워크플로의 검증 게이트 설정을 비용 대비 최적화할 근거를 마련합니다.

더 넓게 보면, 이 연구는 검증 예산이 넉넉하지 않은 소규모 팀도 저비용으로 신뢰할 수 있는 에이전트 감사 파이프라인을 구축할 수 있음을 실증했습니다. fan-out 형태의 멀티에이전트 파이프라인에서 검증자 등급과 스켑틱 수, 다수결 임계값이 환각 생존율에 미치는 영향을 정답이 알려진 통제된 벤치마크로 정량화한 것도 이 연구가 처음입니다. 그동안 원칙 서술 수준에 머물러 있던 적대적 검증 관행을 측정 가능한 곡선으로 끌어올렸습니다.

## 한계

연구진은 이 결과의 한계를 명확히 밝히고 있습니다. 벤치마크 자체가 12개 finding, 단일 draw를 기반으로 한 소규모 실험이라, 백분율이 6분의 1 단위로 거칠게 움직입니다. 특히 N=3과 N=5 조건은 별도로 재추출한 독립 시행이 아니라 동일한 5회 draw를 사후에 잘라 구성한 것이기 때문에, 이상치 하나가 여러 셀에 동시에 영향을 줄 수 있고, 이런 이유로 통계적 유의성 검정도 표본 크기상 수행하지 않았습니다. Claude 계열의 Haiku·Sonnet·Opus 세 등급만 테스트했으므로 이 등급 간 서열이 다른 모델 패밀리에도 그대로 적용된다고 볼 근거는 없으며, 비용 수치는 2026년 7월 10일 시점의 API 단가를 반영한 것이라 가격이 바뀌면 어떤 설정이 지배적인지도 달라질 수 있습니다. 연구진은 콩도르세 희석 메커니즘 자체는 수학적으로 확실하지만, 실제 운영 환경에서 어려운 항목이 스켑틱 정답률 50% 미만 구간에 얼마나 자주 놓이는지는 이번 소규모 벤치마크만으로는 답할 수 없다고 못 박으며, 더 큰 규모의 seeded 벤치마크와 셀마다 독립적으로 재추출하는 후속 실험을 다음 과제로 제시합니다.

논문 상세 정보는 Hugging Face 데이터셋 페이지에서 확인할 수 있습니다: [https://huggingface.co/datasets/thaki-AI/daily-paper-2026-07-11-verify-gated-fanout-pareto](https://huggingface.co/datasets/thaki-AI/daily-paper-2026-07-11-verify-gated-fanout-pareto)

## 관련 슬라이드

본문 내용을 NotebookLM(`cinematic_infographic` 스타일)으로 요약한 슬라이드입니다.

![verify-gated-fanout-pareto 슬라이드 1](/assets/images/verify-gated-fanout-pareto-slide-01.png)

![verify-gated-fanout-pareto 슬라이드 2](/assets/images/verify-gated-fanout-pareto-slide-02.png)

![verify-gated-fanout-pareto 슬라이드 3](/assets/images/verify-gated-fanout-pareto-slide-03.png)

![verify-gated-fanout-pareto 슬라이드 4](/assets/images/verify-gated-fanout-pareto-slide-04.png)

