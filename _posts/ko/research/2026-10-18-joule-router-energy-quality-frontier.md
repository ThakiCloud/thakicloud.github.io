---
title: "The Joule Frontier: token ledger가 가장 싼 router 구성과 미터가 가장 싼 구성은 다를 수 있고, 그 차이는 closed form입니다"
seo_title: "The Joule Frontier(Joule frontier) 논문 소개 - self-hosted H200 위에서 24/7 agent platform의 skill router economics는 거의 전부 token dollar로 표기되지만, 플랫폼이 실제로 매초 지불하는 것은 물리적 에너지입니다. 이 논문은 라우팅 요청당 에너지(energy per routed request)를 dollar cost와 quality와 나란한 세 번째 objective로 도입하고 hybrid skill router의 12개 구성 공간에서 분석합니다. 구조적 전력 모델 E(c) = P0 t(c) + η W(c) + R(c) 하에서, 비용 최적 구성이 에너지 최적 구성보다 엄격히 나쁜 것은 floor-time penalty가 work-energy advantage를 넘는 것과 동치이며, 이를 closed-form energy tax로 이름 붙입니다. decoupling은 load-dependent이고, crossover concurrency B*에서 두 objective 순서가 다시 만납니다. 에너지-품질 Pareto knee는 load와 함께 drift합니다. rank-safety margin 안의 quantization은 dollar-neutral이고 strictly energy-dominant이며, 이전 gatekeeper 연구의 명시적 upgrade입니다. NVML integrated power sampling으로 교정하는 measurement protocol이 모든 조건을 production 인프라에서 falsifiable하게 만들고, TCO의 energy slice가 uptime과 함께 커지는 proposition까지 제시합니다. - ThakiCloud"
seo_description: "24/7 agent platform의 router는 잠들지 않고, 플랫폼이 매초 실제로 지불하는 것은 token dollar가 아니라 물리적 에너지입니다. 이 논문은 라우팅 요청당 줄을 세 번째 objective로 도입하고, 비용 최적과 에너지 최적 구성이 decouple되는 iff 조건인 energy tax, load와 함께 이동하는 crossover concurrency B*와 knee drift, rank-safety margin 안의 energy-dominant quantization을 closed form으로 줍니다."
excerpt: "token ledger는 토큰만 가격 매기고, 미터는 시간과 일을 가격 매깁니다. 두 대장은 같은 라우터 구성의 다른 좌표를 읽으므로, 가장 싼 구성은 각자 다를 수 있습니다. 이 논문은 그 차이를 측정 가능한 매개변수의 closed-form 함수로 줍니다."
date: 2026-10-18
tags:
  - energy-quality-frontier
  - skill-routing
  - gpu-power-telemetry
  - token-cost-decoupling
  - router-configuration-space
  - pareto-knee
  - h200-serving
  - sustainable-inference
  - agent-harness
  - llm-economics
categories:
  - research
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/ko/research/joule-router-energy-quality-frontier/"
---

self-hosted H200에서 24/7 agent platform을 돌리거나, 그에 딸린 전기 bill(TCO)를 책임지는 국내 클라우드/AI 엔지니어라면 이 글이 답하는 질문은 곧 운영의 문제입니다. 한 줄의 결론은, token ledger가 가장 싼 router 구성이 미터가 가장 싼 구성과 항상 같지는 않다는 것입니다. 그 간극의 크기는 측정 가능한 매개변수의 closed-form 함수입니다. ThakiCloud의 논문 **"The Joule Frontier: Measuring the Energy-Quality Tradeoff of Skill-Router Configurations and Its Decoupling from Token Cost on Self-Hosted H200"**는 라우팅 요청당 물리적 에너지(energy per routed request)를 dollar cost와 quality와 나란한 세 번째 objective로 도입하고, hybrid skill router의 12개 구성 공간에서 그 값을 분석합니다. 이 논문은 분석 논문입니다. 측정된 에너지 값을 보고하지는 않고, 모든 그림은 선언된 가정에 대한 closed-form 예측이며, 그 예측을 반증 가능한 measurement protocol로 채우도록 함께 등록되어 있습니다.

![The Joule Frontier: token ledger가 가장 싼 router 구성과 미터가 가장 싼 구성은 다를 수 있고, 그 차이는 closed form입니다 개념을 형상화한 이미지](/assets/images/joule-router-energy-quality-frontier-hero.webp)
*글의 핵심 개념을 형상화했습니다.*

## 문제의식: 라우팅 문헌은 달러와 품질만 가격 매깁니다

무감시 agent harness에서는 모든 task가 실행에 앞서 skill router를 지나갑니다. retriever가 후보 skill을 추립니다. reranker가 결정하고 executor model이 task를 수행합니다. router는 모든 요청의 hot path 위에 앉으므로, 그 economics는 fleet scale에서 중요합니다. 라우팅 문헌은 router를 달러로 가격 매깁니다. cost-quality Pareto에 token granularity, provider 선택, security objective가 차례로 추가되어 왔습니다.

그런데 self-hosted 인프라에서 dollar 대장은 불완전합니다. GPU의 가격은 amortized capex에 작은 electricity line item 하나입니다. 라우팅 결정의 token cost는 internal shadow price로만 존재합니다. 플랫폼이 실제로 매초 지불하는 것은 물리적 에너지입니다. 그것이 열이 되고 cooling load가 되고 탄소가 되는 watt-hour입니다. 24/7 agentic platform에서는 router가 잠들지 않습니다. task가 in flight인지 여부와 무관하게, 그 idle-time energy가 계속 지불됩니다.

에너지 연구 쪽은 이미 model level, fleet level, schedule level에서 inference energy를 측정하고 modern accelerator의 phase structure를 특성화해 왔습니다. 그런데 router의 구성 결정 자체를 라우팅 요청당 줄로 가격 매기는 논문은 아직 없습니다. retrieval depth, reranker tier, embedding precision의 선택은 token ledger에서만 보이는 결정으로 남아 있었습니다.

이 논문은 self-hosted H200의 skill router 구성 grid 위에서 그에 해당하는 질문을 던집니다. 라우팅 요청당 physical GPU energy가 routing accuracy와 dollar cost에서 decouple하는지, 에너지 최적 구성이 비용 최적 구성과 측정 가능한 에너지-품질 Pareto knee(파레토 무릎)에서 다른지를 묻습니다.

답의 열쇠는 구조적 비대칭입니다. 구성 c = (k, τ, q)의 세 손이 돌리는 좌표가 세 가족, wall-clock time, work, token count입니다. retrieval depth k는 시간, work, token 수를 모두 올립니다. reranker tier τ는 shadow price와 work를 바꾸고 wall-clock은 phase structure에 따라 달라집니다. quantization precision q는 work와 wall-clock을 내립니다. token 수는 불변이고 quality는 랭크 안전 마진(rank-safety margin) 안에서 불변입니다. dollar cost는 token 수의 함수인 반면, energy는 시간과 work의 함수입니다. token과 wall-clock은 같은 구성 공간의 서로 다른 좌표입니다. 둘은 단조로 관련되어 있지 않습니다.

![Skill-router configuration space: where the token ledger and the power meter diverge](/assets/images/posts/research/joule-router-energy-quality-frontier/fig-router-coordinate-structure.webp)
*router 구성 c = (k, τ, q)가 wall-clock time, work, token count라는 세 좌표 가족을 움직이고 두 대장이 서로 다른 좌표를 가격 매기므로, 비용 최적과 에너지 최적은 decouple될 수 있습니다. (개념 예시: k × τ × q grid 위 cost/energy/quality objective의 구조 도식이며 양적 주장이 없습니다)*

사람 말로는, token ledger와 전기 미터가 같은 다이얼의 다른 좌표를 보고 있습니다. "가장 싼" 구성이 같을지는, 각 대장이 무엇을 읽느냐에 따라 갈립니다.

![joule-router-energy-quality-frontier 슬라이드 1](/assets/images/joule-router-energy-quality-frontier-slide-01.webp)

## 구조적 전력 모델과 energy tax: 비용 최적과 에너지 최적의 iff 조건

이 논문은 router stage를 구조적 전력 모델(structural power model)로 가격 매깁니다. 라우팅 요청당 router-stage energy E(c) = P0 t(c) + η W(c) + R(c)로 세 항에 분해합니다. P0는 빈 노드의 idle power가 아니라, serving GPU가 router-stage window 동안 유지하는 floor 전력입니다. η는 단위 work당 marginal joule이고 R은 phase mixing, clock throttling, 유한 power sampling 분해능의 오류를 흡수하는 residual입니다. protocol이 실제 노드에서 NVML integrated power sampling으로 P0, η, R을 교정합니다.

quality budget ε을 고정하면, feasible set F_ε는 routing accuracy가 1-ε 이상인 구성들의 집합입니다. 그 안에서 비용 최적 구성 c†는 dollar cost를, 에너지 최적 구성 c‡는 reference load에서 잰 요청당 energy를 각각 최소화합니다. c†를 고정해 배포하는 deployment의 energy tax(에너지 세금) τ_E는 τ_E = E(c†)/E(c‡) - 1로 정의됩니다.

주 정리는 이 세금이 양이 되기 위한 iff 조건을 줍니다. 비용 최적 구성이 에너지 최적 구성보다 엄격히 나쁜 것은, floor-time penalty P0(t† - t‡)가 work-energy advantage η(W‡ - W†)에 residual 차이를 더한 것을 넘는 것과 동치입니다. rate-work regime에서 이 조건은 floor-to-work 비율 P0/η와 에너지 최적 구성의 marginal work rate 비교로 축소됩니다. token으로 싸지만 wall-clock으로 느린 구성은, 미터가 floor가 켜져 있는 시간만큼 더 비싸게 평가합니다.

![Energy tax: floor-time penalty versus work-energy advantage](/assets/images/posts/research/joule-router-energy-quality-frontier/fig-energy-tax-condition.webp)
*비용 최적 구성이 엄격히 에너지-나쁜(energy tax > 0) 것은, 그것이 지는 floor-time penalty가 에너지 최적 구성의 work-energy advantage를 넘는 것과 동치입니다. (분석 모델, 실측이 아닙니다)*

decoupling은 서로 다른 두 메커니즘으로 작동합니다. 첫 번째가 tier 메커니즘입니다. 같은 retrieval depth와 precision에서, small reranker tier의 token은 싸지만 decode가 memory-bound이므로 wall-clock이 깁니다. large tier는 더 많은 work를 하지만 prefill과 batch-bound phase에서 wall-clock이 짧습니다. token ledger는 price 차이를 읽습니다. 미터는 floor-time 차이를 보여 줍니다. 두 번째가 precision 메커니즘입니다. rank-safety margin 안에서 quantization은 dollar와 quality를 거의 움직이지 않으면서 energy를 엄격히 줄입니다. 순위의 역전이 아니라, dollar 비용과 quality 비용이 제로인 지점에서 엄격히 양의 에너지 절약을 얻는 것입니다.

precision 메커니즘은 이전 gatekeeper 연구의 명시적 upgrade입니다. gatekeeper 연구가 rank-safety margin 안에서 quantization이 안전하다고 보인 결과라면, 이 논문은 그 결론을 "마진 안에서 안전하고 에너지로는 무료다"로 확장합니다. 요청당 절감량은 정확히 P0ρ_t t + ηρ_W W joule에 달합니다. ρ_t와 ρ_W는 weight-only quantization이 가져오는 wall-clock과 work의 감소분입니다. 압축 결과가 에너지 결과로 바뀝니다.

![joule-router-energy-quality-frontier 슬라이드 2](/assets/images/joule-router-energy-quality-frontier-slide-02.webp)

## 부하와 함께 이동하는 최적: crossover concurrency와 knee drift

비용 최적과 에너지 최적의 decoupling은 load에 달려 있습니다. continuous batching(컨티뉴어스 배칭)에서 router-stage wall-clock은 in-flight 요청끼지 나눠 먹는 parallel 부분과 나눠 먹지 못하는 serial 부분으로 갈립니다. 요청당 wall-clock은 대략 t_ser + t_par/B입니다. 동시성 B가 오르면 요청당 floor share가 떨어집니다.

load 정리가 주는 crossover concurrency(크로스오버 동시성) B*(c) = P0 t_par/(P0 t_ser + η W + R)는, 요청당 floor share가 work 더하기 serial share와 같은 load입니다. B* 이하에서는 floor가 지배합니다. 에너지 최적 구성은 work rate가 높은, 가장 빨리 끝나는 tier입니다. B* 이상에서는 work가 지배합니다. 에너지 최적 구성은 가장 적은 work를 하는 tier가 됩니다.

![Per-request energy versus concurrency: load-dependent knee drift](/assets/images/posts/research/joule-router-energy-quality-frontier/fig-knee-drift-load.webp)
*두 tier 모두 요청당 router-stage energy가 concurrency와 함께 내려갑니다. floor가 amortize되기 때문입니다. light load에서는 work-heavy fast tier가 앞서 있습니다. crossover concurrency를 지나면 least-work tier가 승자를 교체합니다. (분석 모델, 실측이 아닙니다)*

이 결과가 knee drift로 이어지는 것이다. retrieval depth와 precision을 고정하면, rate-work tradeoff를 만족하는 두 tier의 pairwise energy gap은 load가 오르는 동안 zero를 한 번 가로지릅니다. 에너지-품질 Pareto knee c_knee(B)는 work rate가 높은 tier에서 work가 최소인 tier로 이동하는 셈입니다. 자기 regime에서 벗어난 구성에 고정된 deployment는 모든 요청에서 energy tax를 지불하게 됩니다.

reconvergence도 일어나기도 합니다. B가 포화에 가까우면 요청당 energy는 token 수와 무관하게 work와 serial time만으로 결정됩니다. dollar 순서는 여전히 token 기반인 것입니다. 두 순서는 retrieval depth k에서 일치합니다. precision q에서는 dollar 순서가 평탄한데 energy 순서는 엄격히 단조입니다. 포화에서 두 순서가 마지막으로 갈라지는 곳은 reranker tier τ의 n과 W mispricing입니다.

그런데 이 knee는 믿을 만합니까. certification margin 정리가 오차 범위로 답합니다. 교정 오차가 (δP, δη, δR)라면, knee 이웃 구성과의 상대 energy gap M이 그 합을 넘는 한 knee는 불변입니다. 운영적으로 "측정 가능한" Pareto knee는 양의 certification margin을 가진 knee입니다. protocol은 그 margin을 frontier output의 일부로 보고합니다.

TCO에 대한 귀결은 proposition입니다. 연간 TCO의 energy slice S(u)는 uptime fraction u에 대해 엄격히 증가합니다. 항상 켜져 있는 router u = 1이 최대 slice를 직닙니다. floor 항은 request set이 idle인 때도 지불되기 때문입니다. 비용 최적 구성을 고정하면, 연간 energy line item이 정확히 1 + τ_E배가 됩니다. 사람 말로는, 에너지 bill은 traffic이 아니라 uptime과 함께 커집니다.

![joule-router-energy-quality-frontier 슬라이드 3](/assets/images/joule-router-energy-quality-frontier-slide-03.webp)

## 결정 규칙: 부하 클래스별로 c‡(B)를 고르고 τ_E를 보고합니다

measurement protocol은 분석의 경험적 counterpart입니다. power cap을 700 W로 고정 pin한 H200 class GPU 한 대, continuous-batching engine, 고정 tool-calling request set으로 진행합니다. 12개 구성이 load class {1, 4, 16, 64}와 곱해져 48개 셀을 만듭니다. serving timestamps가 router-stage window를 끊어 executor-stage energy는 제외됩니다. P0는 no-load probe로, η와 W는 roofline counter(FLOPs, HBM bytes)로 교정됩니다. bootstrap confidence interval이 Q, dollar, energy를 각각 덮습니다.

deployment rule은 load class별로 작동합니다. protocol은 B마다 에너지 최적 c‡(B), 비용 최적 c†(B), 세금 τ_E(B)을 출력합니다. τ_E(B)가 operator의 energy budget threshold를 넘으면 c‡(B)를 배포합니다. 세금은 모든 요청에서 지불되고 uptime과 함께 복리됩니다. 그렇지 않으면 c†(B)를 배포합니다. τ_E(B)는 token cost와 나란히 보고되는 감사 가능한 숫자가 됩니다. rank-safety margin 안의 quantization은 모든 클래스에서 default move입니다. 세 objective 전체 공간에서 strictly dominant합니다.

falsification도 결과별로 등록됩니다. calibrated (P0, η, R, t, W)에서 τ_E의 부호가 조건과 다르면 energy tax 정리가 반증됩니다. 네 load class를 지나는 동안 knee가 B*를 넘지 않으면, load 정리가 반증되는 것입니다. margin 안의 어떤 quantization step도 (ΔE < 0, Δ$ ≈ 0, ΔQ ≈ 0) triple을 통과하지 못하면 precision corollary가 무효가 됩니다.

![joule-router-energy-quality-frontier 슬라이드 4](/assets/images/joule-router-energy-quality-frontier-slide-04.webp)

## 의미: 회사, 사회, 과학에 남는 것

ThakiCloud의 always-on agent platform에서, energy는 TCO의 숨겨진 slice입니다. router는 모든 요청 위에서 돕니다. load class별로 측정 가능한 에너지 최적 구성은 전기, 열, downstream capex를 실제로 줄여 줍니다. "비용 최적 routing이 언제 에너지-비효율인가"라는 구체적 결정이 token cost와 함께 보고되는 감사 가능한 숫자 τ_E(B)가 됩니다. 이 논문은 self-hosted agentic serving의 cost-quality frontier를 일 년째 가격 매겨 온 시리즈의 네 번째 축입니다. gatekeeper가 compression을, thinking router가 reasoning budget을, concurrency tax가 serving load를 가격 매겼다면, 이 논문은 routing stage 자체의 physical energy를 명시적 objective로 만듭니다.

24/7 agentic LLM 워크로드는 커지는 전기와 탄소 부하입니다. 이 논문은 "싸다"고 여겨지는 routing choice의 physical energy 비용을 정량화합니다. 작은 quality 손실, 혹은 margin 안에서는 quality 손실 없이 큰 에너지 절약을 사는 지점도 함께 보여 줍니다. 구성 결정은 physical 결정입니다. 그것을 무시하는 token ledger는 floor를 두 번 지불합니다. 달러로 한 번, 줄로 한 번입니다.

과학적으로는, 이 논문이 LLM router 설계에 dollar cost와 quality와 나란한 세 번째, 물리적으로 grounded한 objective인 라우팅 요청당 줄을 도입합니다. closed-form energy tax 조건, crossover concurrency B*, certification margin, falsification protocol은 최근 cost-quality routing 문헌에 없던 새로운 축으로 남습니다.

## 한계: 구조적 모델 위에 성립하는 결과

주 결과는 전부 piecewise 구조적 모델의 조건부입니다. 지속적인 floor, work에 비례하는 active draw, bounded residual의 세 항으로 된 모델입니다. 모델 안에서 energy tax의 iff와 load 정리의 crossing은 정확합니다. protocol의 존재 이유는 특정 node, phase mix, engine 위에서 (P0, η, R)을 추정하고 residual이 bounded임을 검증하기 위해서입니다. 모델이 가장 약한 곳은 active-draw 항입니다. embedding prefill과 reranker decode 사이의 phase mixing이 ηW를 phase split의 비선형 함수로 굽힐 수 있습니다. 그래서 residual이 per-stage, per-load이며 B*가 per-configuration입니다.

이 논문은 측정된 에너지 값을 보고하지 않습니다. 기여는 구조적 모델, decoupling 조건, crossover와 certification 결과, falsification protocol입니다. multi-GPU interconnect energy, heterogeneous fleet, grid-intensity optimization은 제외됩니다. P_max는 platform constant이고 P0는 calibrated quantity입니다.

열려 있는 composition이 두 개 있습니다. concurrency tax에서는 accuracy Q(c;B) 자체가 포화에서 드리프트하므로 feasible set이 load-dependent이고 (load, quality, energy) 결합 frontier가 자연스러운 다음 대상입니다. thinking router에서는 water-filling 배분 규칙에 thinking token 배분점마다 router-stage joules를 가격 매기는 세 번째 항이 생깁니다.

이 글의 세 장은 모두 분석 모델의 closed-form 예측이며 실측이 아닙니다. 각 캡션에도 그렇게 적어 두었습니다.

논문 원문과 수반 자료는 Hugging Face에서 볼 수 있습니다.

https://huggingface.co/datasets/thaki-AI/daily-paper-2026-10-18-joule-router-energy-quality-frontier
