---
title: "The Description Budget: 스킬 설명에 얼마나 텍스트가 필요한지, 그리고 정확도-토큰 프런티어가 레지스트리 규모에 따라 어떻게 이동하는지"
seo_title: "The Description Budget(디스크립션 버짓) 논문 소개 - retrieval 기반 agent 하네스에서 각 스킬의 description은 dual-role artifact다. 같은 텍스트가 라우터의 BM25+embedding 인덱스 신호이자 per-request 프롬프트에 주입되는 payload다. 본 논문은 이를 description-budget 문제로 formalize하고 네 가지 가정(A1 coverage concavity, A2 linear collision load, A3 mean-field Plackett-Luce, A4 sublinear cluster saturation) 아래 KKT 분석으로 1차 구조를 유도한다. 닫힌 형태 버짓 규칙(Proposition 2)은 스킬별 최적 길이가 traffic 가중 discrimination value 대 cache 조정 payload price 비의 로그, L_i*(N) = (1/θ_i) ln(α_i θ_i (1+ζ m_i(N))/c_eff)임을 준다. Theorem 1은 최적점에서 surface mass(boilerplate)를 소거해 L_s* = 0을, corollary는 uniform budget의 배정 비효율을 traffic weight 분산으로 bound한다. 500에서 2,200 스킬로 레지스트리가 커질 때 frontier shift 부호는 a priori 불확정이며, A4는 log-N 상승, A4'(dense cluster)는 measurable peak를 지닌 non-monotone frontier를 주므로 confusion-pressure index가 regime을 판별한다(사전 등록 P1). cache 인식 rewrite payback(Proposition 4)은 prefix-cache 임계(약 3,500 토큰, plateau ρ ≈ 0.83)에서 payback cliff를 보여 임계 직전의 depth는 임계 초과 depth에 엄격히 dominated된다(P3). Proposition 5는 corpus side, retriever side, compute side 레버를 log-space에서 1차 additive 합성하고 적용 순서를 amortization으로 정한다. Ladder rewrite(약 5/12/20/30/40 토큰)와 registry sweep(N ∈ {500, 1,100, 2,200}), falsification 조건 P1-P3을 담은 측정 프로토콜은 사전 등록되어 있으며 본 논문은 해석 논문으로 새 실측을 보고하지 않는다 - ThakiCloud"
seo_description: "retrieval 기반 agent 하네스에서 스킬 description은 인덱스 신호와 프롬프트 payload를 동시에 맡는 dual-role artifact입니다. 본 논문은 이 역할을 description-budget 문제로 formalize하고, 스킬별 최적 길이가 traffic 가중 discrimination value 대 cache 조정 payload price 비의 로그임을 닫힌 형태로 줍니다. surface mass는 최적점에서 소거되고 uniform budget는 dominated되며 rewrite payback은 prefix-cache 임계에서 cliff를 보입니다. 본 논문은 해석 논문이며 측정 프로토콜은 사전 등록되어 있습니다."
excerpt: "스킬을 retrievable하게 만드는 같은 텍스트가 그것을 expensive하게 만듭니다. 본 논문은 description의 두 역할을 한 번에 가격 매기고, 스킬별 최적 길이를 닫힌 형태의 로그 법칙으로 줍니다. 500에서 2,200 스킬로 레지스트리가 커질 때 frontier shift의 부호는 어떤 regime이 맞는지를 가르는 판별 기준입니다."
date: 2026-10-10
tags:
  - skill-description-verbosity
  - retrieval-precision
  - prompt-inflation
  - cost-quality-frontier
  - registry-scaling
  - bm25-embedding-fusion
  - agent-harness
  - skill-ecosystem
  - sra-bench
  - token-cost-optimization
categories:
  - research
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/ko/research/description-budget-skill-verbosity/"
---

스킬 레지스트리를 둔 retrieval 기반 agent 하네스를 운영하거나, 스킬 description을 per-request 프롬프트에 주입하는 시스템을 맡고 있는 국내 클라우드·AI 엔지니어라면 이 글을 읽어야 합니다. 이런 아키텍처에서 description은 retrieval 정밀도와 per-request 토큰 비용이 동시에 거래되는 지점입니다. 이 논문은 그 거래에 대한 닫힌 형태의 답을 주는 셈입니다. ThakiCloud의 이번 논문, **"The Description Budget: Measuring the Retrieval-Precision versus Prompt-Inflation Frontier of Skill-Description Verbosity Across Registry Sizes in a 2,200-Skill Agent Harness"**는 스킬 description의 dual role, 인덱스 신호와 프롬프트 payload를, description-budget 문제로 정식화하는 것입니다. 스킬 하나당 description 텍스트가 얼마나 필요한지, 그리고 레지스트리가 약 500개에서 2,200개로 커질 때 정확도-per-프롬프트-토큰 frontier가 어떻게 이동하는지 두 질문에 답합니다. 본 논문은 해석 논문입니다. frontier를 닫힌 형태로 유도하고 그것을 시험할 측정 프로토콜을 사전 등록합니다.

## 문제의식: 같은 description이 인덱스 신호이자 프롬프트 payload

논문의 중심인 무인 agent 하네스에서 모든 user turn은 hybrid retrieval step을 통과하는 것입니다. 각 스킬 description에 대한 lexical BM25 점수와 dense embedding similarity를 fusion합니다. 이 fusion은 모든 request의 hot path 위에서 계산됩니다. 레지스트리는 한국-영어 혼합 쿼리를 응대하던 1,600개 스킬에서 2,200개 스킬로 자랐습니다. 인덱싱과 주입은 모두 스킬 description이라는 free-text 블록 하나로 처리됩니다.

스킬을 retrievable하게 만드는 같은 텍스트가 그것을 expensive하게 만듭니다. 주입되는 description의 모든 토큰은 들어가는 request마다 prefix-cache 할인만큼 뺀 뒤 다시 지불해 버립니다. 장황하고 boilerplate가 많을수록 neighboring query에 대한 distractor가 강해집니다. 인덱스에 들어가는 단어 하나하나가 off-target query의 collision 기회를 늘리기 때문입니다. verbosity는 retrieval 정밀도와 per-request 비용을 같은 순간에 반대 방향으로 거래합니다.

![Dual-role structure of a skill description](/assets/images/posts/research/description-budget-skill-verbosity/dual-role.webp)
*같은 텍스트 d_i가 retrieval 인덱스 신호(coverage gain과 collision loss)이자 주입되는 프롬프트 payload(비용과 reader degradation)로, description-budget 목적함수의 세 채널을 이룹니다. (개념 예시. coverage·collision·payload 세 가지 가치/비용 채널과 그 부호의 구조 다이어그램.)*

이 질문의 계보는 Gorilla에서 시작합니다. 2023년의 Gorilla는 fine-tuned LLaMA 모델을 document retriever로 거대한 API corpus에 연결했습니다. retrieval이 hallucinated API 사용을 상당히 완화하고 test-time 문서 변화에 적응한다는 것도 보여 주었습니다. 하지만 corpus 텍스트를 주어진 것으로 취급했습니다. API 엔트리 하나당 텍스트가 얼마나 필요한지 묻지 않았고 retrieved 텍스트가 프롬프트에 주입될 때마다 치르는 per-request 비용도 model의 대상이 아니었습니다. 2026년의 스킬-ecosystem 연구 물결은 selection side, rewriting side, compression side, compute side, security side에서 같은 문제를 공격합니다. registry size를 가로지르는 dual-role budget frontier를 model하는 일은 없습니다. 이 논문은 정확히 그 대상을 정의합니다. 의도적으로 Gorilla의 아키텍처를 upgrade합니다.

![description-budget-skill-verbosity 슬라이드 1](/assets/images/description-budget-skill-verbosity-slide-01.webp)

## 버짓 규칙: 최적 길이가 '차별 가치 / cache 조정 payload 가격'의 로그

논문은 스킬 description L_i 토큰을 capability content L_c와 surface mass L_s로 나눕니다. capability content는 스킬이 무엇을, 언제, 어떤 대상에 대해 실행하는지를 담고 surface mass는 boilerplate와 반복 서술을 지닙니다. name, 한 줄 capability, boundary sentence로 된 고정 structural template 아래 capability 비율이 길이 레벨에 걸쳐 일정하므로, 사다리 이동은 순수한 길이 이동입니다.

request 당 기대 가치 V_i는 네 항으로 쓰입니다. 첫째는 traffic 가중 coverage입니다. capability 토큰은 Poisson rate로 스킬의 executable region을 덮습니다. 붐비는 cluster에서 coverage는 (1+ζ m_i)로 증폭됩니다. 붐비는 cluster일수록 capability 토큰 하나하나가 더 많은 일을 합니다. 둘째는 collision입니다. surface 토큰 하나하나가 confusing neighbor m_i(N)개에 rate β로 혼선을 부과합니다. BM25 half에서는 인덱스된 단어가 많을수록 off-target query의 겹칠 기회가 늘고 dense half에서는 boilerplate가 embedding을 generic cluster 방향으로 당깁니다. 셋째는 cache 조정 payload 가격 c_eff L_i입니다. 넷째는 음의이거나 0인 reader degradation 항 Q_reader입니다. dual role의 긴장은 이 한 식 안에 있습니다. crowding이 capability의 가치와 surface의 가격을 동시에 올리기 때문입니다.

가정 A1(coverage concavity)부터 A4(sublinear cluster saturation) 아래, KKT 분석이 세 결과를 줍니다. 첫 번째는 Theorem 1입니다. V_i는 (L_c, L_s)에 대해 jointly concave이고 unique global maximizer가 존재하며 최적점에서 surface mass가 소거됩니다. L_s* = 0. boilerplate는 짧아지는 것이 아니라 통째로 사라집니다. robustness 가정 A5가 이를 날카롭게 하는 것입니다. 혼선 압력 m_i가 임계 c_eff/β 이상이면 최적 description은 순수 capability content입니다. 두 번째는 Proposition 2, 닫힌 형태 버짓 규칙입니다.

L_i*(N) = (1/θ_i) ln(α_i θ_i (1 + ζ m_i(N)) / c_eff)

스킬별 최적 길이는 traffic 가중 discrimination value와 cache 조정 payload price의 비의 로그입니다. comparative statics는 바로 읽힙니다. traffic weight α_i가 높으면 길고 neighborhood m_i가 붐비면 길고 토큰 가격 c_eff가 비싸면 짧습니다. 세 번째는 corollary입니다. uniform budget는 dominated됩니다. 같은 총 budget에서 모든 스킬에 같은 길이를 주면 손실은 (1/2) Σ c_eff θ_i (L_i* - B/N)²로 bound됩니다. traffic weight의 분산이 '누구나 같은 길이' authoring 관행의 배정 비효율을 가르는 measurable 상한이 됩니다.

![description-budget-skill-verbosity 슬라이드 2](/assets/images/description-budget-skill-verbosity-slide-02.webp)

## 500에서 2,200으로의 frontier 이동: 부호가 regime의 진위를 가른다

레지스트리가 500에서 2,200 스킬로 커질 때 frontier가 어떻게 이동하는지에 대한 단일한 답은 논문이 주지 않습니다. shift의 부호는 a priori로 불확정입니다.

A4(sublinear cluster saturation) 아래 혼선 질량은 m_i(N) = m_0 + Δm ln(N/N_0)로 로그 성장하고 frontier는 log-N 법칙으로 단조 상승합니다. 레지스트리가 붐빌수록 capability content의 가치가 오르므로 최적 길이가 커집니다. 대안 regime A4'(dense cluster) 아래 혼선 질량은 m_i ∝ N으로 가격에 선형으로 들어가고 discrimination value는 포화하는데 collision+payload price만 계속 커집니다. 그러면 frontier는 non-monotone이 되고 내부 N†에서 peak를 줍니다. 논문의 schematic에서 peak는 약 750 스킬 부근이고 A4 frontier와의 crossing은 약 1,560 부근입니다. 파라미터는 예시 값입니다.

두 regime 중 어느 쪽이 맞는지를 논문은 주장하지 않습니다. 둘 다 미지 함수 m_i(N)의 functional form입니다. 논문의 내용은 두 형태가 모양이 다른 frontier shift를 주며, measurable한 대상인 confusion-pressure index m̄(N)이 그 사이를 판별한다는 것입니다. 이것이 사전 등록된 falsification 조건 P1입니다. L*(2,200) - L*(500)가 500 스킬 길이의 10%를 넘고 m̄(N)이 N에 sublinear이면 데이터가 A4를 고르고 log 법칙이 확인됩니다. measurable한 peak를 지닌 non-monotone frontier는 A4'를 가릅니다. confidence interval 안에서 평탄한 frontier는 dual role 긴장 자체를 falsify합니다.

![Optimal description length across registry size: two competing regimes](/assets/images/posts/research/description-budget-skill-verbosity/frontier.webp)
*A4 sublinear-cluster frontier는 단조한 log-N 법칙으로 오르고 A4' dense-cluster frontier는 내부 peak를 지닌 non-monotone 형태이며, 500에서 2,200으로 커지는 사이 frontier shift의 부호가 regime을 판별합니다. (해석 모델이며 실측이 아닙니다.)*

## rewrite payback cliff: cache 임계는 건너거나, 가까이 가거나

Proposition 4는 registry 전체 rewrite를 가격 매깁니다. 일회성 비용은 rewrite와 인덱스 재구축의 합 R×N이 되기 때문입니다. request 당 절감 S는 rewrite가 prefix-cache 임계를 건너느냐에 따라 바뀌기도 합니다. 논문이 인용하는 production cache 측정은 two-tier인 셈입니다. 약 3,500 토큰의 날카로운 임계 아래에서 hit rate는 ρ ≈ 0.83로 plateau하고 그 위에서 할인은 다릅니다.

![Rewrite payback across the prefix-cache threshold](/assets/images/posts/research/description-budget-skill-verbosity/payback-cliff.webp)
*cache 임계 바로 아래에서 멈춘 registry 전체 rewrite는 임계를 건너는 rewrite보다 request 당 절감이 엄격히 작습니다. 임계를 건너는 순간 남아 있는 prefix 전체가 더 높은 plateau 할인으로 재가격매겨지기 때문입니다. (해석 모델이며 실측이 아닙니다.)*

rewrite depth ΔP가 임계 바로 아래에서 멈추면 제거되는 것은 tail 토큰뿐이고 그것들은 임계 위 할인으로 가격매겨집니다. 임계를 건너면 남아 있는 prefix 전체가 새로운 할인으로 재가격매겨지고 절감에 p_in (ρ_b - ρ_a) P_t만큼의 도약이 붙기도 합니다. 임계 바로 아래 depth는 임계 바로 위 depth에 엄격히 dominated됩니다. 최적 depth는 전체 budget 목표이거나 crossing depth이고 임계에 아주 가깝지만 못 미치는 지점은 없는 셈입니다. 이것이 사전 등록 P3입니다. jump 없는 단일 slope payback은 two-tier 재가격매김 메커니즘을 falsify하는 것입니다.

그 위에 Proposition 5가 세 레버를 합성합니다. corpus side의 budget b = L*, retriever side의 양자화 distortion ε과 fusion weight w, compute side의 router thinking 배정 t입니다. local regime에서 end-to-end task quality는 Q = Q̄ (1+η_c)(1+η_s)(1+η_r)로 분해되고 1차까지 레버는 log-space에서 additive로 합성됩니다. frontier의 모양은 유지되고 위치만 이동한다는 뜻입니다. 경제적으로 바른 적용 순서는 amortization입니다. b가 먼저, 일회성 비용 RN이 모든 향후 request에 걸쳐 상환됩니다. 다음 ε, retriever rebuild마다 offline으로 적용되는 것입니다. 그리고 t, task마다 비용이 드는 레버입니다. description budget은 가장 많이 amortization되는 레버이며 앞선 report의 retriever side 결과와 compute side 결과에 corpus side 축을 더합니다.

![description-budget-skill-verbosity 슬라이드 3](/assets/images/description-budget-skill-verbosity-slide-03.webp)

## 회사, 사회, 과학에 남는 것

회사에 가장 먼저 남는 것은 ThakiCloud입니다. 무인 agent loop의 자율 repair loop가 스킬 description을 밤마다 재작성하는데, 길이 정책은 없었습니다. 2026-10-03에 무한정 재작성이 일으킨 collateral routing drift가 실측되었습니다. 버짓 규칙은 스킬별, registry size별로 measurable한 길이 상한을 repair loop에 부여하는 상시 constraint입니다. SRA 라우팅을 안정화하고 무인 loop의 구조적 토큰 비용을 낮춘다는 것입니다.

사회로 가면 범위는 넓어집니다. 대규모 스킬/MCP 생태계를 운영하는 self-hosted agent 플랫폼 팀은 request마다 description 토큰을 지불합니다. Model Context Protocol의 ecosystem-level 조사는 17개 marketplace에 368,754개 server listing을 세고 98.5%의 tool은 적어도 하나 이상의 functional alternative를 지닙니다. 혼선 질량 m_i(N)이 큰 곳이 바로 그곳입니다. description 길이는 registry-level external 효과인 셈입니다. collision 항 β m_i L_s가 neighboring skill의 정밀도 손실을 스킬의 author에게 전가합니다. 스킬별 길이 budget은 external effect의 일부를 internalize합니다. budget 자체가 가격입니다. 공개된 description-budget 레시피는 품질 손실 없이 이 낭비를 감사하고 제거하는 수단을 줍니다.

과학으로는 스킬 description 텍스트의 두 역할, 검색 인덱스 신호와 프롬프트 컨텍스트를 통제 실험으로 분리한 첫 연구일까요. registry size에 의존하는 Pareto frontier, description-budget scaling 법칙은, registry size만 변인화한 기존 router scaling 결과와 겹치지 않는 축입니다. Gorilla가 LLM을 retriever로 거대한 API corpus에 연결했다면, 이 논문은 corpus 자체에 가격을 매긴다는 뜻입니다.

![description-budget-skill-verbosity 슬라이드 4](/assets/images/description-budget-skill-verbosity-slide-04.webp)

## 한계: 모든 숫자는 명시된 가정 위의 model 추정

논문의 모든 숫자는 명시된 가정 위에서 model 추정치로 도출됩니다. A1-A5는 측정 프로토콜이 고정하는 가설인 셈입니다. A4 대 A4' label은 열린 실증 문제로 남아 있습니다. 본 논문은 해석 논문으로 새 실측을 보고하지 않습니다.

scorer는 단일 hybrid family입니다. embedding model 하나와 고정 fusion weight w. adaptive fusion을 쓰면 가격 항이 바뀝니다. injection은 static이고 packer가 없는데, packing을 쓰면 reader가 간직하는 것이 바뀝니다. reader degradation 항 Q_reader는 placeholder이며 position-dependent 형태는 model되지 않았습니다. 인용된 3,500 토큰 임계를 넘는 cache 파라미터는 deployment-specific이고 C1-C2 조건으로 설정됩니다.

이 gap을 닫기 위해 논문은 측정 프로토콜을 사전 등록합니다. 스킬별 약 5, 12, 20, 30, 40 토큰의 ladder rewrite, functional cluster 구성을 보존한 N ∈ {500, 1,100, 2,200}의 registry sweep, 셀마다 recall@5, top-1 정확도, retrieval level hallucination rate, per-request prompt 토큰 팽창, downstream task success, confusion-pressure index를 기록합니다. 셀별 bootstrap confidence interval, cluster와 traffic quartile로 분할된 동결 audit set, 실행 전에 고정되는 코드와 registry snapshot입니다. 분석 규칙은 측정 전에 고정해 버립니다. 데이터에 맞춰 바꾸지 못합니다.

논문 원문과 수반 자료는 Hugging Face에서 볼 수 있습니다.

https://huggingface.co/datasets/thaki-AI/daily-paper-2026-10-10-description-budget-skill-verbosity
