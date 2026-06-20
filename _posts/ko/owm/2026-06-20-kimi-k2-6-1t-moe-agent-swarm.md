---
title: "Kimi K2.6: 1T MoE, 32B Active, 300 서브에이전트 스웜 아키텍처 분석"
excerpt: "Moonshot AI의 Kimi K2.6은 1T 총 파라미터 중 32B만 활성화하는 MoE 구조로 dense 32B급 추론 비용을 유지하면서 256K 컨텍스트와 멀티모달을 지원한다. 300 서브에이전트 스웜 기능이 K8s 멀티테넌트 에이전트 환경과 자연스럽게 연결된다."
seo_title: "Kimi K2.6 1T MoE 에이전트 스웜 아키텍처 온프렘 가이드 - Thaki Cloud"
seo_description: "Kimi K2.6 아키텍처(MLA 어텐션, 384전문가, MoonViT 400M), 벤치마크(SWE-Bench Verified 80.2, AIME 2026 96.4), vLLM/SGLang/KTransformers 서빙과 H100 서빙 footprint를 분석했다."
date: 2026-06-20
last_modified_at: 2026-06-20
categories:
  - owm
tags:
  - kimi-k2-6
  - moonshot-ai
  - moe
  - mla-attention
  - agent-swarm
  - 256k-context
  - multimodal
  - vllm
  - ktransformers
  - self-hosting
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/owm/kimi-k2-6-1t-moe-agent-swarm/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 8분

![Kimi K2.6 에이전트 스웜 개념도](/assets/images/kimi-k2-6-hero.png)

## Kimi K2.6 개요

Moonshot AI가 공개한 Kimi K2.6은 `moonshotai/Kimi-K2.6` 저장소에서 확인할 수 있습니다. 라이선스는 Modified MIT입니다. 총 1조(1T) 파라미터이지만 추론 시 활성화되는 파라미터는 32B에 불과합니다.

이 3.2% 활성화율이 실용적 의미를 가지는 이유는 명확합니다. GPU 메모리에 가중치를 올리는 데는 전체 1T가 필요하지만, 토큰 하나를 처리하는 FLOPs는 dense 32B 모델과 비슷합니다. 스토리지 요구사항과 추론 속도가 분리되는 구조입니다.

## 아키텍처 상세

### 레이어 구성

Kimi K2.6은 61개 레이어로 구성되며, 첫 번째 레이어는 dense 레이어입니다. 나머지는 MoE 레이어입니다. 전문가(expert)는 총 384개이고, 토큰당 8개가 선택됩니다. 여기에 shared expert 1개가 추가로 항상 활성화됩니다.

어텐션 방식은 MLA(Multi-head Latent Attention)입니다. DeepSeek V2에서 처음 공개된 방식으로 Key-Value 캐시를 저차원 잠재 공간으로 압축해 KV 캐시 메모리를 줄입니다. attention hidden dim은 7168, MoE hidden dim은 2048, attention head는 64개입니다. 활성화 함수는 SwiGLU를 씁니다.

### 컨텍스트와 어휘

컨텍스트 길이는 256K 토큰입니다. 어휘 크기는 160K로, 다국어 처리에 유리한 크기입니다.

### 비전 인코더

멀티모달 처리를 위해 MoonViT 400M 비전 인코더가 포함됐습니다. 이미지뿐 아니라 비디오 입력도 처리합니다.

### Thinking/Instant 모드

추론(Thinking) 모드와 즉각 응답(Instant) 모드를 전환해서 쓸 수 있습니다. Thinking 모드에서는 중간 추론 과정이 interleaved되어 출력됩니다. 연산 비용과 응답 품질 사이의 트레이드오프를 사용자가 선택할 수 있는 구조입니다.

### 에이전트 스웜

300개의 서브에이전트를 동시에 운용하고 4,000 조율 스텝까지 처리할 수 있다는 설명이 모델카드에 포함되어 있습니다. long-horizon coding 같은 복잡한 태스크를 다수 에이전트가 분산 처리하는 형태입니다.

## 벤치마크

HF 모델카드 기준 수치입니다.

| 벤치마크 | Kimi K2.6 |
|---|---|
| SWE-Bench Verified | 80.2 |
| SWE-Bench Pro | 58.6 |
| SWE-Bench Multilingual | 76.7 |
| Terminal-Bench 2.0 | 66.7 |
| LiveCodeBench v6 | 89.6 |
| AIME 2026 | 96.4 |
| GPQA-Diamond | 90.5 |
| HMMT 2026 | 92.7 |
| MMMU-Pro | 79.4 |
| MathVision | 87.4 |
| BrowseComp | 83.2 |
| HLE-Full w/tools | 54.0 |

SWE-Bench Verified 80.2는 실제 GitHub 이슈 해결 태스크에서 높은 수치입니다. AIME 2026 96.4는 수학 경시대회 수준 문제에서의 성능입니다. MMMU-Pro 79.4와 MathVision 87.4는 멀티모달 추론 능력을 보여줍니다.

BrowseComp 83.2는 웹 탐색 기반 정보 검색 태스크로, 에이전트 활용 시 의미 있는 지표입니다.

## 서빙 및 배포

### 지원 프레임워크

- **vLLM** (텐서 병렬 지원)
- **SGLang** (배치 추론 최적화)
- **KTransformers** (소비자급 GPU 양자화)
- **Transformers** 4.57.1 이상, 5 미만 (주의: 버전 상한 있음)

### 양자화

Native INT4를 포함해 39개 양자화 변형이 제공됩니다. llama.cpp, Ollama, LM Studio, Jan 등에서 바로 쓸 수 있는 형태입니다.

### 요구사항

1T 파라미터를 BF16으로 올리면 약 2TB VRAM이 필요합니다. 실제 서빙을 위해서는 INT4 양자화를 전제로 해도 H100 80GB 기준 약 8장 정도가 필요한 규모입니다. KTransformers를 쓰면 소비자급 GPU 클러스터에서 양자화된 버전을 올릴 수 있습니다.

Transformers 버전 제약(`>=4.57.1,<5`)이 있으니 환경 구성 시 반드시 확인해야 합니다.

## ThakiCloud 관점

두 가지가 특히 흥미롭습니다.

**1T 총/32B active로 얻는 서빙 효율.** active 파라미터가 32B 수준이라는 것은 추론 latency와 throughput이 사실상 dense 32B급으로 나온다는 의미입니다. 전체 가중치를 GPU에 올리는 비용(VRAM)과 토큰 생성 속도(FLOPs)가 분리됩니다. H100 1~2장 수준의 footprint로 서빙이 가능하다는 주장은 양자화를 전제로 한 것이지만, dense 70B 이상 모델과 비교했을 때 throughput 측면에서 유리합니다. Kueue로 GPU 쿼터를 관리하는 환경에서 실질 서빙 비용 계산에 이 구분이 중요합니다.

**300 서브에이전트 스웜과 K8s 멀티테넌트 연결.** Kimi K2.6이 표방하는 300 서브에이전트 동시 운용은 K8s 상에서 에이전트 파드를 배치하는 아키텍처와 자연스럽게 맞닿습니다. 각 서브에이전트를 독립된 워크로드로 스케줄링하고 Kueue로 우선순위를 조율하는 구성을 떠올릴 수 있습니다. 실제로 모델이 이 수준의 에이전트 조율을 어떻게 구현하는지는 레포 코드와 예제를 직접 확인해야 알 수 있지만, 멀티테넌트 에이전트 데모를 구성하려는 팀에게 참고 아키텍처가 됩니다.

39개 양자화 변형과 KTransformers 지원이 있어서, H100 풀 클러스터 없이도 기능 검증 단계에서 RTX 계열 GPU로 시작할 수 있습니다. 다만 Modified MIT 라이선스의 세부 조건은 원문을 직접 확인하고 사용 시나리오에 맞는지 검토해야 합니다.
