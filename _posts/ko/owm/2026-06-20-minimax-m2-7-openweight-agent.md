---
title: "MiniMax-M2.7: 229B 오픈웨이트 에이전트 모델, 113종 양자화와 온프렘 라이선스 주의사항"
excerpt: "MiniMax가 공개한 M2.7은 229B 파라미터, FP8 지원, 113종 양자화 변형으로 온프렘 경로가 다양하다. 에이전트 팀 협업과 자기진화를 표방하지만, 라이선스가 'other'로 상용 배포 전 반드시 원문을 확인해야 한다."
seo_title: "MiniMax-M2.7 229B 오픈웨이트 에이전트 모델 온프렘 가이드 - Thaki Cloud"
seo_description: "MiniMax-M2.7의 아키텍처, 벤치마크(MLE Bench Lite 66.6%, SWE-Pro 56.22%, GDPval-AA ELO 1495), SGLang/vLLM/NIM 서빙 방법과 라이선스 주의사항을 정리했다."
date: 2026-06-20
last_modified_at: 2026-06-20
categories:
  - owm
tags:
  - minimax-m2-7
  - minimax
  - openweight
  - fp8
  - agent-model
  - sglang
  - vllm
  - nvidia-nim
  - self-hosting
  - quantization
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/owm/minimax-m2-7-openweight-agent/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 7분

![MiniMax-M2.7 자기진화 에이전트 팀 개념도](/assets/images/minimax-m2-7-hero.png)

## MiniMax-M2.7 개요

MiniMax가 `MiniMaxAI/MiniMax-M2.7`로 공개한 모델이다. 총 229B 파라미터이며 F32, BF16, FP8(F8_E4M3) 세 가지 dtype을 지원한다. FP8 네이티브 지원은 최신 NVIDIA GPU(H100, H200, Blackwell 계열)에서 메모리 효율과 throughput 측면의 이점을 준다.

라이선스는 "other"로 분류되어 있다. 모델을 사용하거나 상용 배포를 검토한다면 LICENSE 원문을 직접 읽어야 한다.

## 아키텍처

M2.7의 MoE 구조 세부 파라미터(전문가 수, 활성 전문가 수, 어텐션 방식, 컨텍스트 길이)는 공개 모델카드에 명시적으로 기재되어 있지 않다. 229B라는 총 파라미터 수와 FP8 지원이 주요 공개 정보다.

모델카드에서 강조하는 특징은 두 가지다. 첫째, 에이전트 팀 기능으로 역할 정체성을 가진 여러 에이전트가 협업하고 자율 의사결정을 수행한다고 설명한다. 둘째, 내부 버전 기준 100회 이상 자율 최적화 라운드를 거쳤다는 자기진화(self-evolution) 주장이 있다. 이 수치는 모델 개발사 주장이므로 독립 검증 없이 그대로 받아들이기보다는 실제 태스크에서 직접 확인하는 것이 맞다.

tool-use는 명시적으로 지원된다.

## 벤치마크

HF 모델카드 기준 수치다.

| 벤치마크 | MiniMax-M2.7 |
|---|---|
| MLE Bench Lite | 66.6% |
| SWE-Pro | 56.22% |
| SWE Multilingual | 76.5 |
| Multi SWE Bench | 52.7 |
| VIBE-Pro | 55.6% |
| Terminal Bench 2 | 57.0% |
| NL2Repo | 39.8% |
| GDPval-AA ELO | 1495 |
| Toolathon | 46.3% |
| MM Claw e2e | 62.7% |

GDPval-AA ELO 1495는 오픈웨이트 모델 중 최고 수준이라고 개발사가 주장한다. 에이전트 작업에 특화된 벤치마크로, 실제 의미는 다른 공개 모델들과의 직접 비교를 통해 확인해야 한다.

SWE-Pro 56.22%와 SWE Multilingual 76.5는 코드 에이전트 분야에서 준수한 수준이다. NL2Repo 39.8%는 자연어 기반 레포지토리 조작 태스크로, 상대적으로 낮은 편이다.

MM Claw e2e 62.7%는 멀티모달 에이전트 태스크 성능으로, 이미지와 텍스트를 함께 처리하는 파이프라인에서 참고할 수치다.

## 서빙 및 배포

### 지원 프레임워크

- **SGLang** (권장 프레임워크)
- **vLLM** (텐서 병렬)
- **Transformers** (HF)
- **NVIDIA NIM** (DGX/HGX 온프렘 즉시 배포)
- **Docker Model Runner** (컨테이너 기반)
- **OpenAI 호환 API** 제공

### 양자화 변형

113개 양자화 변형이 HF Hub에 등록되어 있다. 이 수는 이번에 리뷰하는 4개 모델 중 가장 많다. GPTQ, GGUF, AWQ, EXL2, FP8 등 다양한 포맷이 포함되어 있어서 대부분의 추론 프레임워크와 하드웨어 조합에서 시작점을 찾을 수 있다.

### 추론 파라미터

모델카드에서 권장하는 기본 파라미터는 temperature 1.0, top_p 0.95, top_k 40이다. 에이전트 태스크에서는 이 기본값을 유지하고 실험하는 것을 권장한다.

### 하드웨어 요구사항

229B BF16 기준 약 458GB VRAM이 필요하다. H100 80GB 기준 6장 이상이 필요한 규모다. FP8을 쓰면 절반 수준으로 줄어든다. NVIDIA NIM 경로를 쓰면 DGX 시스템에서 최적화된 서빙 스택을 그대로 가져올 수 있어서 초기 설정 부담이 줄어든다.

## ThakiCloud 관점

M2.7에서 가장 실용적으로 눈에 들어오는 두 가지를 꼽으면 다음과 같다.

**113종 양자화로 온프렘 경로 다양성이 최상급.** 소비자급 GPU부터 DGX급까지 거의 모든 구성을 커버하는 양자화 변형 수다. 팀의 GPU 인벤토리가 어떤 상태든 시작점을 찾기 어렵지 않다. NIM으로 DGX/HGX 환경에 배포하면 별도 서빙 스택 설정 없이 바로 쓸 수 있고, Ollama나 llama.cpp 변형으로 개발용 머신에서 가볍게 테스트하는 것도 가능하다.

**라이선스 "other"는 온프렘 상용 배포 전 필수 확인 항목.** 오픈웨이트라는 말이 상용 무료를 의미하지 않는다. 라이선스가 "other"로 분류되어 있다는 것은 표준 분류(MIT, Apache, Llama Community 등)와 다른 조건이 있다는 신호다. 상용 서비스에 붙이거나 내부 엔터프라이즈 배포를 계획한다면 LICENSE 원문을 법무팀과 함께 검토해야 한다. 기술 평가와 라이선스 검토는 병렬로 진행하되 후자가 배포 전에 완료되어야 한다.

에이전트 팀 협업이나 자기진화 기능은 실제 사용 사례에서 직접 검증하는 것이 맞다. 벤치마크와 개발사 설명만으로는 실제 워크플로에서 어떻게 동작하는지 알기 어렵다. 프로토타입 단계에서 소규모 양자화 버전으로 먼저 검증하고 필요한 하드웨어 규모를 산정하는 접근이 현실적이다.
