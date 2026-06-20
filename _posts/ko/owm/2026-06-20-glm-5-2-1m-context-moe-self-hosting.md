---
title: "GLM-5.2: 753B MoE, 1M 컨텍스트, MIT 라이선스 온프렘 서빙 가이드"
excerpt: "Z.ai의 GLM-5.2는 DSA(Dynamic Sparse Attention)로 1M 컨텍스트를 2.9x FLOPs 절감하며 처리한다. MIT 라이선스로 온프렘 배포가 자유롭고, GGUF 29종 양자화로 소비자급 GPU에서도 실행된다."
seo_title: "GLM-5.2 753B MoE 1M 컨텍스트 온프렘 서빙 가이드 - Thaki Cloud"
seo_description: "GLM-5.2의 DSA 아키텍처, 벤치마크(HLE 40.5, AIME 2026 99.2, SWE-bench Pro 62.1), vLLM/SGLang/KTransformers 서빙 방법과 온프렘 요구사항을 정리했다."
date: 2026-06-20
last_modified_at: 2026-06-20
categories:
  - owm
tags:
  - glm-5-2
  - z-ai
  - moe
  - dynamic-sparse-attention
  - 1m-context
  - vllm
  - sglang
  - ktransformers
  - self-hosting
  - mit-license
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/owm/glm-5-2-1m-context-moe-self-hosting/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 7분

![GLM-5.2 희소 MoE와 1M 컨텍스트 개념도](/assets/images/glm-5-2-hero.png)

## GLM-5.2는 무엇이 다른가

Z.ai(智谱, 구 Zhipu AI)가 공개한 GLM-5.2는 총 753B 파라미터 규모의 MoE 모델입니다. HuggingFace 저장소 `zai-org/GLM-5.2`에서 접근할 수 있고, 라이선스는 MIT입니다.

이 모델에서 가장 주목할 부분은 1M 토큰 컨텍스트를 실용적인 FLOPs 수준으로 처리하는 방식입니다. "1M 컨텍스트 지원"을 표방하는 모델은 여럿 있지만, 실제 추론 비용이 벽이 됩니다. GLM-5.2는 DSA(Dynamic Sparse Attention)라는 어텐션 방식으로 이 문제를 정면으로 다뤘습니다.

## 아키텍처: DSA와 IndexShare

GLM-5.2의 핵심은 `glm_moe_dsa` 아키텍처입니다. DSA는 인접한 4개의 sparse attention 레이어가 인덱서(indexer)를 공유하는 IndexShare 방식을 씁니다.

전통적인 dense self-attention은 시퀀스 길이 $L$에 대해 $O(L^2)$ 복잡도를 가집니다. 128K를 넘어가는 구간부터 이 비용이 폭발적으로 커지는데, sparse attention은 각 토큰이 전체가 아닌 선택된 위치만 어텐드하게 해서 이를 줄입니다. GLM-5.2의 DSA는 1M 컨텍스트 기준 per-token FLOPs를 2.9x 절감한다고 HF 모델카드에 명시되어 있습니다.

추가로 speculative decoding 개선도 포함됐습니다. MTP(Multi-Token Prediction) 기반으로 수락률(acceptance rate)이 최대 20% 향상됐다는 수치가 제시됩니다. 서빙 throughput에 직접 영향을 주는 개선입니다.

지원 dtype은 BF16과 F32이고, active 파라미터 수는 공개 모델카드에 명시되어 있지 않습니다.

## 벤치마크

HF 모델카드 기준 수치를 표로 정리했습니다.

| 벤치마크 | GLM-5.2 |
|---|---|
| HLE | 40.5 |
| HLE w/Tools | 54.7 |
| AIME 2026 | 99.2 |
| SWE-bench Pro | 62.1 |
| Terminal Bench 2.1 | 82.7 |
| MCP-Atlas (Public) | 76.8 |

AIME 2026 99.2는 수학 추론 분야에서 매우 높은 수치입니다. SWE-bench Pro 62.1은 실제 소프트웨어 엔지니어링 과제에서의 성능이고, MCP-Atlas 76.8은 tool-use 시나리오를 반영합니다.

HLE(Humanity's Last Exam) w/Tools 54.7은 도구 없는 40.5 대비 상당한 폭으로 올라갑니다. 코딩 에이전트나 tool-use 파이프라인에 붙이는 방식이 효과적임을 시사합니다.

## 서빙 및 배포

### 지원 프레임워크

공식 지원 프레임워크는 다음과 같습니다.

- **vLLM** v0.23.0 이상
- **SGLang** v0.5.13.post1 이상
- **Transformers** v0.5.12 이상 (HF)
- **KTransformers** (소비자급 GPU 양자화 서빙)
- **Unsloth** (파인튜닝 포함)
- **Ascend NPU** (화웨이 NPU 지원)

### 양자화 변형

HF Hub에 GGUF 포함 29개 양자화 변형이 올라와 있습니다. Q4_K_M, Q8_0 등 다양한 비트 수 옵션이 있어서 GPU 메모리 여건에 따라 골라 쓸 수 있습니다. KTransformers와 조합하면 RTX 4090 수준의 소비자급 GPU에서도 추론이 가능합니다. 물론 풀 BF16 753B를 단일 노드에 올리는 것은 별개 문제입니다.

### 최소 요구사항

총 753B BF16 기준으로 약 1.5TB VRAM이 필요합니다. 실용적인 온프렘 배포는 양자화를 전제로 합니다. Q4 양자화 기준 약 375GB, Q8 기준 약 750GB 수준입니다. 멀티노드 텐서 병렬(TP) 설정이 필요하고, NVIDIA H100/A100 8장 이상 구성이 일반적인 시작점입니다.

Z.ai API를 통해 API 서빙을 쓸 수도 있습니다.

## ThakiCloud 관점

GLM-5.2에서 ThakiCloud 관점으로 가장 의미 있는 세 가지를 꼽으면 다음과 같습니다.

**MIT 라이선스.** 753B급 모델이 MIT 라이선스로 공개된 것은 드뭅니다. 상용 온프렘 구축 시 라이선스 검토 부담이 없다는 점이 엔터프라이즈 도입 장벽을 낮춥니다. Llama, Qwen 계열이 "Llama Community License"나 별도 조건을 달고 있는 것과 대비됩니다.

**DSA의 Kueue GPU 비용 산정 함의.** 1M 컨텍스트 작업에서 per-token FLOPs가 2.9x 절감된다면, 같은 GPU 예산으로 처리할 수 있는 시퀀스 수가 늘어납니다. Kueue로 GPU 쿼터를 관리하는 환경에서 long-context 배치 잡의 비용 예측이 달라집니다. 기존 dense attention 모델 기준으로 짠 GPU 예산을 GLM-5.2 기준으로 재산정할 필요가 있습니다.

**GGUF 29종 + KTransformers 경로.** 온프렘 GPU가 H100 급이 아닌 RTX 계열이라면 KTransformers와 GGUF 양자화 조합이 현실적인 서빙 경로입니다. 29종 양자화 변형이 HF에 이미 올라와 있어서 별도 변환 작업 없이 바로 쓸 수 있습니다. 소규모 팀이 제한된 하드웨어로 1M 컨텍스트 기능을 테스트하려는 경우 진입 장벽이 낮습니다.

긴 컨텍스트 long-horizon 태스크(계약서 전체 분석, 대형 코드베이스 이해, 장문 레포트 생성)에 온프렘 모델을 투입하려는 조직에게 GLM-5.2는 검토할 가치가 있습니다. 다만 풀 BF16 753B 서빙은 여전히 대형 GPU 클러스터를 전제로 하므로, 실사용 규모에 맞는 양자화 전략 선택이 중요합니다.
