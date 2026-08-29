---
title: "300자 창 안에서 어떤 특징이 라우팅을 가르는가: 스킬 description의 인과 귀속 프로토콜"
seo_title: "Routability Under Budget: 스킬 description 특징의 라우팅 정확도 인과 귀속 - ThakiCloud"
seo_description: "스킬 라우터는 각 description의 앞 300자만 봅니다. 이 논문은 description budget만 변화(300에서 full까지 사다리)하고 anti-trigger 문장만 ablation하며 변하지 않는 production BM25 scorer로 1,978개 스킬 코퍼스와 63개 수동 라벨 스위트에 점수를 매깁니다. 정확도 delta를 description 편집만으로 귀속하는 프로토콜을 내놓고 실측 복구 곡선은 뒤따릅니다."
excerpt: "라우터는 스킬 description의 300자 접두사만 보고 나머지 메타데이터는 그것을 쓰면서도 볼 수 없는 구성요소에 가려집니다. 이 논문은 그 창 안의 어떤 특징이 top-1 라우팅 정확도를 인과적으로 가르는지, 추가 자당 정확도를 얼마씩 사는지를 묻습니다. 답은 budget 사다리, anti-trigger ablation, 케이스별 counterfactual, 인덱스 재구축 control check로 짜인 프로토콜입니다."
date: 2026-08-23
last_modified_at: 2026-08-29
tags:
  - skill-routing
  - agent-harness
  - description-metadata
  - token-budget
  - truncation
  - causal-attribution
  - retrieval-accuracy
  - bm25
  - multilingual-triggers
categories:
  - research
author_profile: true
toc: true
toc_label: "목차"
canonical_url: "https://thakicloud.com/tech-blog/ko/research/routability-under-budget/"
---
수십 개에서 수천 개 스킬을 등록해 에이전트 하네스를 돌리고 스킬 인덱스에 얼마의 컨텍스트를 쓸지 정해야 하는 엔지니어라면 이 글을 읽어야 한다. 참고 하네스에서 유저 요청을 올바른 스킬로 매핑하는 skill router는 각 스킬 description의 앞 300자만 본다. 나머지 메타데이터는 그것을 쓰면서도 볼 수 없는 구성요소에 가려진다. 이 글은 ThakiCloud AI Research의 자율 연구 논문 'Routability Under Budget'을 소개한다. 논문은 300자 창 안에서 어떤 특징이 top-1 라우팅 정확도를 인과적으로 가르는지, 추가 1자당 정확도를 얼마씩 사는지 묻는다. 정직한 점을 먼저 둔다. 이 연구는 숫자가 아니라 측정 프로토콜을 내놓는다. 실측 정확도 복구 곡선은 뒤따른다. 이 글에서 라우팅 정확도 수치를 하나도 주장하지 않는다.

## description 창은 문서가 아니라 광고입니다

이 간극의 의미가 두 갈래다. 정확도에서는 라우터가 틀린 스킬을 고르거나 스킬을 찾지 못하면 에이전트가 생성 단계에 들기도 전에 실패 경로로 간다. 비용에서는 description 인덱스가 매 세션 컨텍스트로 다시 읽히므로 description을 길게 쓰는 것이 무료가 아니다. truncation budget은 컨텍스트 비용과 라우팅 정밀도를 바꾸는 토큰-품질 노브이고 그 노브의 값은 지금까지 관습이었다.

논문은 문제를 경쟁으로 다시 쓴다. 라우터가 접두사만 보기 때문에 스킬 description은 통상적 의미의 문서가 아니다. 약 2,000개 동료 스킬과 어휘 검색기의 주목을 두고 경쟁하는 고정 크기 광고다. 그 경쟁을 이기는 특징은 측정으로만 정할 수 있는 값이다.

선행 스킬 라우팅 연구는 retriever의 구조, 쿼리 분해, 코퍼스 성장, 임베딩 모델을 다뤘지만 내용 예산은 다루지 않았다. 이 연구팀의 계열도 같다. 구조, 가중치, 생태계 운영, 모델 축을 전부 재봤지만 description 내용 자체는 모든 연구에서 고정되어 있었다. 2026-07-09에 발표한 연구에서 한-영 혼재 쿼리의 프로덕션 하네스에서 결합 제약은 query decomposition이 아니라 retriever ceiling이라는 진단이 나왔다. 뒤를 이은 repair, 폐기, 출산, 양자화 연구는 각자 구조와 코퍼스 크기와 모델을 한 축씩 움직였다. 창 안의 어떤 특징이 라우팅 정확도를 가르는지에 대한 내용 예산 축은 아직 안 재본 것이다. 이 논문은 그 레버를 움직인다.

## description 창만 바꾸는 프로토콜

실험은 전적으로 결정적이다. 모델 추론과 네트워크 접근과 가속기 어느 것도 쓰지 않는다. variant 사이에서 바뀌는 것은 description 창뿐이고 ablation에서는 anti-trigger 텍스트도 함께 바뀐다. 그래서 정확도 delta는 전부 그 편집 하나로만 귀속된다.

점수 매김 대상 variant는 두 가족이다. 첫 번째가 description budget 사다리다. `current`, B300, B400, B600, B1000, B1500, B2000, `full`이며 런 이름은 라우터가 description 접두사를 얼마나 많이 볼 수 있는지를 글자 수로 뜻한다. shipped인 `current` 레짐과 truncation이 없는 `full` 레짐은 사다리 밖 앵커로 두지 않는다.

![Budget ladder: variant별 description 창](/assets/images/posts/research/routability-under-budget/fig2.png)
*이 연구가 조작하는 변수는 글자 단위의 description 접두사 길이다. shipped인 'current' 레짐과 truncation이 없는 'full' 레짐은 이 사다리 밖에 있다. variant matrix에서 설계한 창 크기이며 실측 값이 아니다.*

두 번째 가족이 `B300_noanti` ablation이다. 300자 budget에서 `Do NOT use`로 시작하는 anti-trigger 문장을 빼고 점수를 매긴다. anti-trigger 효과와 budget 효과를 분리하기 위해서다. 같은 budget에서 anti-trigger 문장을 빼면 top-1이 올라온다면, 좁은 창에서 하지 말라는 문장이 trigger가 쓸 자리를 먹고 있었다는 직접 증거가 된다.

scorer는 production pure BM25 어휘 채널이다. hybrid 임베딩 채널은 꺼져 있고 retrieval gate는 6.0이며 top-k는 5다. scorer에 관한 어떤 것도 variant 사이에서 바뀌지 않는다. 라벨 스위트는 positive, native, negative 케이스로 이루어진 고정 63개 수동 라벨 세트이며 variant matrix의 delta가 description 창 하나로만 나오도록 일정하게 유지된다.

![Causal attribution pipeline](/assets/images/posts/research/routability-under-budget/fig1.png)
개념 예시다. 변하는 것은 description 창(그리고 ablation에서는 anti-trigger 문장)뿐이고 코퍼스와 production scorer와 라벨 세트는 고정된다. 그래서 정확도 delta는 description 편집으로 귀속된다.*

각 variant는 top-1 정확도, recall@5, negative avoidance로 점수를 받는다. 이 프로토콜을 단순 벤치마크 실행과 나누는 것이 케이스별 counterfactual이기 때문. 어떤 라벨 태스크가 300자에서 떨어지고 어떤 더 큰 budget에서 처음으로 top-1로 회복되는지를 기록하는 것이다. 집합 복구 곡선이 태스크별 복구 지도로 바뀌는 지점이다. 어느 스킬의 description이 어느 글자에서 잘리고 그 잘림의 대가가 얼마인지 보여 준다.

프로토콜에는 인덱스 재구축에 대한 control check가 들어 있다. 프로덕션 스킬 라우팅 인덱스를 1,978개(약 2,000개) 스킬 코퍼스에 대해 풀 description으로 소스에서 재구축하고 재구축된 `current` variant를 production bench의 독립 실행과 교차 확인한다. scoring script가 캐시된 인덱스에서 production bench를 돌리면서 재구축과의 divergence를 찾아내고 완주한 런이 사다리가 라우터가 서빙하는 것과 같은 artifact 위에서 재졌음을 인증하는 셈이다.

이 연구의 기여는 프로토콜 그 자체다. description 작성 관습을 토큰 budget가 있는 에이전트 하네스의 측정 가능한 비용-품질 노브로 바꾼다. 실측 정확도 복구 곡선은 뒤따르고 라우팅 정확도 수치는 이 글에서 주장하지 않는다.

## 두 채널 비대칭: B300은 오늘보다 엄밀히 정보가 적습니다

사다리를 움직이게 한 동기가 shipped 하네스에 이미 들어 있는 메커니즘이기 때문이다. 라우터는 두 채널로 돌아간다. token 채널은 풀 description을 보지만 substring 채널은 앞 300자만 본다. 이 비대칭 때문에 B300 variant는 오늘의 레짐보다 엄밀히 정보가 적다. top-1 라우팅을 실제로 가르는 어휘 채널은 shipped 레짐에서 기근 상태이고 budget 사다리는 그 손실을 런마다 하나씩 재는 것이다.

![Two-channel truncation mechanism](/assets/images/posts/research/routability-under-budget/fig3.png)
개념 예시다. shipped 레짐은 비대칭이다. token 채널은 풀 description을 보고 substring 채널은 300자만 본다. 그래서 B300 variant는 오늘보다 엄밀히 정보가 적다.*

사다리가 알려 주는 것은 그 손실의 모양이다. 300에서 400 단계가 가팔라 1500에서 full까지 평탄하다면 손실의 대부분은 앞 100자에서 난다는 답이고 설계 규칙은 trigger를 앞 100자에 두라는 것이다. 곡선이 full까지 계속 오른다면 budget 자체가 병목이라는 답이고 대가는 컨텍스트로 치르는 것이다. 창 안의 특징 네 개, 한글 trigger 비율, ASCII 키워드 개수, anti-trigger 유무, trigger 표기 개수는 스킬별 top-1율과도 상관한다. 논문은 이 상관을 관측값으로 명시하고 인과로 읽지 않는다고 밝힌다. 인과적 명제는 실제로 창을 바꾸는 budget 사다리와 anti-trigger ablation에만 남긴다.

## 회사, 사회, 과학에 남는 것

ThakiCloud에는 1,978개 스킬 생태계의 description field 설계 규칙이 남는다. trigger 위치와 키워드 밀도와 budget 상한은 실측이 답한다. 그 규칙은 선행 repair 연구가 52.9%까지 끌어올린 sra_bench top-1을 더 올리고 매 세션 치르는 스킬 인덱스 컨텍스트 비용을 깎는 것으로 향한다. description 인덱스는 매 세션 다시 읽히므로 스킬당 몇 자의 절감도 레지스트리 전체에 곱해진다.

사회적으로는 스킬 메타데이터의 토큰 비용-품질 규율이다. Claude Code 계열 에이전트 하네스를 쓰는 모든 환경에 적용된다. skill 기반 자동화의 운영비를 내리는 근거가 관습에서 측정으로 바뀐다. 수백, 수천 스킬을 등록하는 팀은 description을 얼마나 길게 쓸지 추측할 필요가 없다. 추가 자당 라우팅 정확도를 얼마씩 사는지 재본 뒤 곡선이 평탄해지는 지점에서 budget을 설정할 수 있다.

과학적으로는 skill description 특징과 retrieval 정확도 사이의 첫 인과 귀속 측정이다. retriever-bottleneck 구조 진단의 다음 단계로서 구조가 아니라 내용 예산이라는 축을 연다. 프로토콜은 결과가 나오기 전에도 가치가 있다. description field만 변이시키고 local route로 완결되는 전적으로 결정론적 실험은 스킬 레지스트리를 가진 어떤 하네스든 재사용할 수 있고 인덱스 재구축의 control check는 라우터가 서빙하는 것과 같은 artifact 위에서 재졌다는 주장의 기준이 된다.

## 이 연구의 한계

이 연구에는 측정이 들어 있지 않다. 논문은 프로토콜 설계이고 재구축 인덱스의 control 비교도 모든 정확도 주장과 함께 뒤따른다. 이것이 첫 번째 한계이자 이 글을 방법론적 기여로 읽어야 하는 이유다.

scorer는 hybrid 임베딩을 끈 pure BM25 어휘 채널이므로 결과는 dense 또는 hybrid 라우터로 전이되지 않을 수 있다. 라벨 세트는 63개 수작업 케이스로 전체 쿼리 공간에 비해 좁고 그런 세트 위의 top-1 delta는 굵다. 창 안의 특징 통계는 인과 효과가 아니다. 관측 상관이면 인과로 읽을 수 없고 그 선을 논문 자체가 긋는다. 코퍼스 규모 약 2,000개는 하나의 운영점이고, budget 사다리의 모양은 훨씬 작거나 훨씬 큰 스킬 생태계에서는 다르게 굽을 수 있다.

---

논문 상세 페이지: https://thakicloud.com/tech-blog/ko/research/routability-under-budget/