---
title: "LLM 없이 PDF를 마크다운으로: LiteParse와 RAG 인제스트 비용·데이터 주권"
excerpt: "LlamaIndex가 발표한 LiteParse는 LLM 없이 PDF를 마크다운으로 변환하는 Apache 2.0 오픈소스 파서입니다. 모델 비의존 파서의 비용·데이터 주권 이점과 한계를 ThakiCloud RAG 문서 인제스트 관점에서 정리합니다."
seo_title: "LiteParse model-free PDF 파서 RAG 인제스트 분석 - Thaki Cloud"
seo_description: "LlamaIndex LiteParse Apache 2.0 model-free PDF 파서, RAG 문서 인제스트 비용 절감과 데이터 주권, 모델 비의존 파싱 관점 분석"
date: 2026-06-21
last_modified_at: 2026-06-21
categories:
  - dev
tags:
  - liteparse
  - llamaindex
  - pdf-parsing
  - rag
  - document-ingest
  - open-source
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/dev/liteparse-model-free-pdf-parser-rag/"
reading_time: true
---

RAG 파이프라인의 첫 단계는 문서 인제스트입니다. 그리고 그 첫 단계에서 가장 흔히 막히는 것이 PDF 파싱입니다. 최근 LLM 기반 파서가 늘었지만, LLM을 매 문서에 돌리면 비용과 지연이 누적되고, 민감한 문서를 외부 모델에 보내는 데이터 주권 문제도 생깁니다. LlamaIndex(Jerry Liu)가 발표한 **LiteParse**는 다른 방향을 택합니다. **LLM 없이** PDF를 마크다운으로 변환하는 Apache 2.0 오픈소스 파서입니다.

저희 ThakiCloud는 K8s 기반 AI/ML SaaS 플랫폼에서 RAG 문서 인제스트를 다룹니다. 모델 비의존 파서가 왜 비용·주권 관점에서 매력적인지, 그리고 어디까지 헷지해야 하는지 짚어보겠습니다.

## 무엇이 다른가: 모델 비의존(model-free) 파싱

LiteParse의 핵심 차별점은 **파싱에 LLM을 쓰지 않는다**는 것입니다. 이 설계가 주는 이점은 분명합니다.

- **비용**: 문서당 LLM 호출 비용이 없습니다. 대량 문서를 인제스트할 때 비용이 선형으로 폭증하지 않습니다.
- **지연**: LLM 추론 왕복이 없으므로 파싱이 빠릅니다.
- **데이터 주권**: 문서를 외부 모델에 보내지 않습니다. 민감 문서를 사내에서 처리하려는 조직에 결정적 이점입니다.
- **결정론**: LLM 파서는 같은 문서도 호출마다 다르게 풀 수 있지만, 규칙 기반 파서는 재현 가능합니다.

LiteParse 측은 모델 비의존 파서 범주에서 여러 벤치마크 최고 점수를 주장합니다. 다만 이 주장은 **자체 측정이고 model-free 범주에 한정**된다는 점을 명시해야 합니다. LLM 기반 파서와의 절대 비교가 아니라, "모델을 안 쓰는 파서 중에서"라는 조건이 붙습니다. 속도·정확도 주장은 이 범주 한정으로 헷지하는 것이 정직합니다.

## RAG 인제스트 관점에서의 트레이드오프

모델 비의존 파서가 만능은 아닙니다. 트레이드오프를 분명히 해야 합니다.

- **구조가 복잡한 문서**: 표, 다단 레이아웃, 스캔된 이미지 PDF는 규칙 기반 파서가 어려워하는 영역입니다. LLM 비전 파서가 더 나을 수 있습니다.
- **하이브리드 전략**: 대부분의 일반 문서는 model-free 파서로 빠르고 싸게 처리하고, 구조가 복잡한 소수만 LLM 파서로 처리하는 하이브리드가 현실적입니다. 비용과 품질을 분리하는 설계입니다.

## ThakiCloud 관점: 인제스트 비용을 1급 시민으로

RAG 파이프라인을 프로덕션에서 운영하면, 인제스트 비용이 의외로 큰 비중을 차지합니다. 문서가 많고 자주 갱신될수록, 파싱에 LLM을 쓰는지 여부가 운영 비용을 좌우합니다. LiteParse 같은 model-free 파서를 기본 경로로 두고, 복잡한 문서만 LLM 파서로 에스컬레이션하는 라우팅이 비용 효율적입니다.

저희가 다루는 영역이 이 지점입니다. K8s 위에서 문서 인제스트 파이프라인을 표준화하고, 문서 유형에 따라 파서를 라우팅하며, 민감 문서를 사내에서 처리해 데이터 주권을 보장하는 일입니다. 인제스트를 단순 전처리가 아니라 비용·주권·품질이 만나는 1급 설계 문제로 다룹니다.

## 마치며

LiteParse는 "RAG 인제스트에 항상 LLM이 필요한 것은 아니다"라는 메시지를 줍니다. 모델 비의존 파서는 비용·지연·데이터 주권에서 분명한 이점이 있고, 복잡한 문서는 LLM 파서로 보완하는 하이브리드가 현실적입니다. 인제스트 비용을 1급 시민으로 다루는 일에 관심 있는 엔지니어라면, 이런 문제가 매일의 과제인 곳입니다.

---

출처: LlamaIndex LiteParse (Apache 2.0). GitHub: https://github.com/run-llama/llama_cloud_services (벤치마크 점수는 자체 측정, model-free 범주 한정 주장).
