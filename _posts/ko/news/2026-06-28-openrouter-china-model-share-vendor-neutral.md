---
title: "OpenRouter 점유율 역전이 말하는 것: 토큰은 매출이 아니다, 그리고 모델 중립의 값어치"
excerpt: "OpenRouter에서 미국 모델 토큰 점유율이 1년 만에 약 70%에서 약 30%로 떨어지고 중국 오픈웨이트 모델이 약 46%까지 올라왔습니다. 그러나 토큰 점유율과 매출 점유율이 갈라지는 시장 재편을 한 겹 들여다보고, 모델 중립 라우팅과 라이선스·데이터 컴플라이언스 레이어라는 ThakiCloud·Paxis의 자리를 정리합니다."
seo_title: "OpenRouter 미·중 모델 점유율 역전과 모델 중립 전략 - Thaki Cloud"
seo_description: "OpenRouter 토큰 점유율에서 미국 모델이 70%에서 30%로 내려가고 중국 모델이 46%로 올라온 데이터를 검증하고, 토큰 점유율과 매출 점유율의 분리(Anthropic 토큰 12%·매출 46%)를 짚습니다. DeepSeek·Qwen 부상의 원인과 모델 중립 라우팅·컴플라이언스 레이어라는 ThakiCloud·Paxis 관점 시사점을 정리합니다."
date: 2026-06-28
last_modified_at: 2026-06-28
categories:
  - news
tags:
  - openrouter
  - china-llm
  - open-weight-models
  - deepseek
  - qwen
  - model-neutrality
  - paxis
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "chart-bar"
canonical_url: "https://thakicloud.github.io/ko/news/openrouter-china-model-share-vendor-neutral/"
---

OpenRouter는 수백만 명의 개발자가 여러 LLM을 하나의 API로 골라 쓰는 플랫폼입니다. 어떤 모델이 실제로 얼마나 호출되는지를 비용에 민감한 개발자들의 실사용으로 보여주기 때문에, 시장의 선행 지표로 자주 인용됩니다. 그 OpenRouter에서 미국 모델의 토큰 점유율이 1년 만에 약 70%에서 약 30%로 내려앉았습니다.

![여러 모델 노드 사이에서 토큰 흐름이 재편되는 모습을 형상화한 개념 이미지](/assets/images/openrouter-china-model-share-vendor-neutral-hero.png)

이 글은 그 데이터를 검증하고, 헤드라인 한 줄로는 놓치기 쉬운 두 번째 층위를 짚은 뒤, 그것이 ThakiCloud와 Paxis 전략에 무엇을 의미하는지 정리합니다.

## 무슨 일이 일어났나

숫자부터 정리하겠습니다. 2025년 중반 약 70%였던 미국 모델(OpenAI·Anthropic·Google) 토큰 점유율은 2026년 중반 약 30%로 떨어졌습니다. 같은 기간 중국계 모델(DeepSeek·Qwen·MiniMax·Moonshot·Tencent 등)은 1년 전 2% 미만에서 약 46%까지 올라왔습니다. 변곡점은 2026년 2월 9일부터 15일 사이의 한 주였습니다. 이 주에 중국 모델이 처리한 토큰이 4.12조 개로, 미국 모델의 2.94조 개를 처음으로 앞질렀습니다.

수치는 매체마다 소수점이 갈립니다. 이 흐름을 널리 알린 한 분석가는 미국 72%에서 33%, 중국 47%로 집계했습니다. 반면 미식별 트래픽을 분리한 정밀 집계에서는 중국 약 46%, 미국 약 36%로 나옵니다. 어느 쪽이든 방향은 같고, "미국 33% 대 중국 47%"처럼 둘을 정면으로 빼서 비교하면 미식별 버킷이 가려진다는 점만 유의하면 됩니다.

## 왜 이렇게 빨랐나

이 변화의 동력은 중국 주요 랩의 급격한 오픈웨이트 전환입니다. DeepSeek은 R1과 V3를 사실상 무료로 공개하며 추론 품질에서 상위 모델에 근접했고, Alibaba의 Qwen 시리즈는 다국어와 코딩 태스크에서 두드러진 성과를 냈습니다. 두 계열 모두 MIT 또는 Apache 라이선스라 상업적 활용이 자유롭다는 점이 개발자 채택을 끌어올렸습니다. Qwen은 Hugging Face 다운로드에서 Llama를 제치고 가장 많이 받는 오픈 모델이 됐습니다.

엔비디아 반도체 수출 규제(H100·H200·B200의 대중국 제한)가 역설적으로 작용했다는 분석도 있습니다. 컴퓨팅이 부족하니 같은 성능을 더 적은 자원으로 뽑아내는 효율화 인센티브가 생겼다는 것입니다. 여기에 OpenRouter 사용자 상당수가 비용에 민감한 스타트업과 개인 개발자라는 점을 더하면, 가격과 라이선스가 유리한 쪽으로 쏠리는 흐름은 구조적입니다.

## 그런데 토큰은 매출이 아닙니다

헤드라인만 보면 "중국이 미국을 이겼다"가 됩니다. 한 겹 들어가면 다른 그림이 보입니다. 같은 OpenRouter에서 Anthropic은 토큰 점유율이 약 12%인데 매출의 약 46%를 가져간다는 분석이 있습니다. 시장이 둘로 갈라지고 있다는 신호입니다.

한쪽은 가장 싼 모델이 이기는 커머디티 시장입니다. 대량의 토큰이 오가지만 마진은 박합니다. 다른 쪽은 코딩이나 자율 에이전트처럼 실패 비용이 큰 고부가 작업에서 비싸도 잘하는 모델이 매출을 가져가는 시장입니다. 토큰 점유율은 앞의 시장을 비추고, 매출 점유율은 뒤의 시장을 비춥니다. 둘은 같은 지표가 아닙니다.

여기에 하나를 더 보태야 합니다. OpenRouter 사용자층은 비용에 민감한 개발자에 치우쳐 있어 전체 엔터프라이즈 시장을 대표하지 않습니다. 점유율 역전을 곧바로 "미국 패배"로 읽으면, 이 두 가지를 빼놓고 과한 결론으로 건너뛰게 됩니다. 진짜 사건은 승패가 아니라 시장이 토큰과 매출로 분리되고 있다는 재편입니다.

## ThakiCloud와 Paxis 관점

이 분리야말로 ThakiCloud와 Paxis 전략에 유리한 지점입니다. 두 가지로 나눠 정리하겠습니다.

첫째, 모델 중립입니다. 시장이 커머디티와 고부가로 갈라지고 모델 순위가 분기마다 뒤집히는 환경에서 가장 탄력적인 구조는 특정 벤더에 묶이지 않는 것입니다. Paxis는 고객이 OpenRouter처럼 비용과 성능의 트레이드오프를 직접 고르게 하는 모델 중립 라우팅을 지향합니다. 중국 오픈모델의 부상은 위협이 아니라 이 전략에 힘을 싣는 흐름입니다. 어느 모델이 위로 올라오든 그것을 1급 시민으로 얹을 수 있으면 시장 변동이 곧 기회가 됩니다.

둘째, 컴플라이언스 레이어입니다. 엔터프라이즈가 비용 때문에 DeepSeek나 Qwen 계열을 쓰기 시작하면, 곧바로 따라오는 질문이 상업 라이선스 조건과 데이터 거버넌스입니다. ThakiCloud의 Keycloak 기반 멀티테넌시와 ArgoCD GitOps 파이프라인은 다양한 모델을 얹기에 기술적으로 친화적입니다. 다만 솔직히 말하면, 모델별 상업 라이선스와 고객별 데이터 컴플라이언스를 자동으로 검증하는 레이어는 아직 갖춰야 할 숙제입니다. 이것은 공백이자 동시에 가장 분명한 기회입니다. 중국 오픈모델을 1급 시민으로 지원하는 추론 파이프라인과 라이선스·데이터 검증 레이어를 함께 제공하는 쪽이 규제 산업 고객을 잡습니다.

## 이 논리가 약해지는 경우

균형을 위해 반대 시나리오도 적어 둡니다. 첫째, 엔터프라이즈의 구매 결정은 개발자 실사용과 다르게 움직일 수 있습니다. 토큰 점유율 곡선이 그대로 엔터프라이즈 채택으로 이어진다는 보장은 없습니다. 둘째, 중국 모델의 데이터 리스크가 금융이나 공공처럼 규제가 강한 산업의 채택을 가로막으면, 점유율 곡선은 산업별로 다시 갈릴 수 있습니다. 셋째, 측정의 미식별 버킷이 커서 정밀 수치는 매체마다 흔들립니다.

지켜볼 지표는 셋입니다. 매출 점유율 곡선이 토큰 점유율과 같은 방향으로 가는지, 규제 산업에서 중국 모델 채택률이 실제로 오르는지, OpenRouter 바깥의 엔터프라이즈 게이트웨이에서도 같은 추세가 보이는지입니다.

## 정리

OpenRouter의 점유율 역전은 진짜입니다. 그러나 그것이 곧 "미국 패배"는 아닙니다. 토큰과 매출이 갈라지는 시장 재편의 한 단면입니다. 어느 모델이 위로 올라오든 거기에 종속되지 않는 쪽, 그리고 그 모델을 합법적이고 안전하게 얹는 검증 레이어를 가진 쪽이 이깁니다. ThakiCloud와 Paxis가 겨냥하는 자리가 바로 거기입니다.

함께 읽기: [빅테크 GPU 과투자의 진짜 논리: 비대칭 보험과 다음 세대 톨게이트](/ko/news/gpu-overinvestment-ai-agents-sovereign-ai/)

## 출처

- 원 분석: [@FurkanGozukara (X)](https://x.com/FurkanGozukara)
- OpenRouter 점유율 데이터: [officechai](https://officechai.com/ai/share-of-us-models-being-used-on-openrouter-has-collapsed-from-70-to-30-over-the-past-year/), [cryptobriefing](https://cryptobriefing.com/openrouter-us-models-token-share-collapse/), [Data Gravity](https://www.datagravity.dev/p/chinas-open-weight-takeover), [stockalarm](https://pro.stockalarm.io/blog/openrouter-llm-rankings-investor-analysis)
- 토큰 점유율과 매출 점유율의 분리: [Normal Guy (X)](https://x.com/Normal_2610/status/2070405462881665341)
- 중국 모델 데이터 리스크: [TechTimes](https://www.techtimes.com/articles/317352/20260529/chinese-ai-models-lead-openrouter-traffic-coding-gains-come-china-data-risk.htm)
