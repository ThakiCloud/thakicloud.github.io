---
title: "GB200 NVL72에서 DeepSeek 671B 최적화: 2.7배 성능 향상 달성"
excerpt: "NVIDIA GB200 NVL72에서 SGLang을 활용한 DeepSeek 671B 모델의 대규모 추론 최적화 및 성능 분석"
date: 2025-06-17
categories:
  - llmops
tags:
  - GB200
  - DeepSeek
  - SGLang
  - Model Optimization
  - Large Scale Inference
  - NVIDIA Blackwell
  - Expert Parallelism
author_profile: true
toc: true
toc_label: "목차"
---

## 개요

NVIDIA GB200 NVL72는 현재 세계에서 가장 진보된 AI 훈련 및 추론 하드웨어입니다. SGLang 팀이 GB200 NVL72에서 DeepSeek 671B 모델을 prefill-decode 분리와 대규모 expert parallelism으로 실행한 결과, **GPU당 7,583 tokens/sec의 디코딩 성능을 달성하여 H100 대비 2.7배의 성능 향상**을 이뤄냈습니다.

이는 2,000 토큰 입력 길이 기준으로 측정된 결과이며, 지속적인 최적화를 통해 더욱 향상될 것으로 예상됩니다.

---

## 핵심 기술 구성 요소

SGLang에 통합된 주요 Blackwell 특화 컴포넌트들은 다음과 같습니다:

### Blackwell DeepGEMM

**FP8 정밀도 최적화** - Blackwell 아키텍처를 완전히 활용하도록 재작성된 고성능 General Matrix Multiplication (GEMM) 라이브러리입니다.

- 새로운 API에서 입력 스케일에 대한 양자화 및 패킹 도입
- 빠른 행렬 곱셈을 위한 새로운 UMMA 기능 활용
- FP8 정밀도에 특화된 최적화

### Blackwell DeepEP

**MoE 토큰 셔플링 최적화** - Mixture of Experts (MoE)에서 라우팅된 전문가를 위한 토큰 셔플링을 위해 설계된 통신 라이브러리입니다.

- 원격 GPU 메모리를 로컬 가상 주소 공간에 매핑하여 NVLink 전용 환경 지원
- 기존 DeepEP 성능 대비 15% 향상
- 대규모 expert parallelism 지원

### FlashInfer Blackwell FMHA

**어텐션 커널 최적화** - DeepSeek prefilling을 위한 고성능 Fused Multi-Head Attention (FMHA) 커널로, Blackwell 아키텍처를 지원하도록 재작성되었습니다.

### Blackwell CUTLASS MLA

**Multi-Head Latent Attention 최적화** - Blackwell 아키텍처에 최적화된 Multi-Head Latent Attention (MLA) 커널입니다.

- 새로운 UMMA 기능 활용
- TMA를 위한 2-SM 클러스터 모드 활성화
- KV 캐시의 L2 읽기 트래픽 감소

### Blackwell Mooncake

**KV 캐시 전송 엔진** - prefill-decode 분리를 위한 Key-Value (KV) 캐시 전송에 활용되는 전송 엔진입니다.

- DeepEP와 유사한 기술을 사용하여 NVLink 지원
- 효율적인 메모리 전송 최적화

---

## 성능 실험 결과

### 엔드투엔드 성능 분석

GB200 NVL72에서 DeepSeek의 디코딩 성능을 평가하기 위해 H100과의 비교 실험을 수행했습니다.

**실험 설정**:
- 14개 노드 중 12개를 디코딩용, 나머지를 prefill용으로 사용
- 실제 운영 환경을 모방한 구성 (18개 노드 중 6개 prefill, 12개 decode)
- 이전 블로그 포스트와 동일한 실험 설정 및 베이스라인 사용

**성능 결과**:
다양한 시퀀스 길이에서 GB200 NVL72가 H100 대비 **2.5-3.4배 성능 향상**을 달성했습니다.

### 성능 향상 요인

#### 향상된 메모리 대역폭 및 연산 성능
- GB200 NVL72는 H100 대비 더 높은 메모리 대역폭과 연산 FLOPS 제공
- 커널 실행 속도 가속화

#### 대용량 메모리로 인한 배치 크기 증가
- 증가된 메모리 용량으로 더 큰 KV 캐시 지원
- 더 큰 배치 크기로 커널 효율성 향상
- H100과 유사한 Inter-Token Latency (ITL) 요구사항 충족

#### 대규모 NVLink 도메인
- H100 클러스터의 RDMA 기반 노드 간 통신과 달리 순수 NVLink 솔루션 사용
- 통신 지연 시간 대폭 감소
- two-batch overlap 비활성화로 커널 성능 향상 및 낭비 방지

#### PD 및 대규모 EP
- 바닐라 TP16 베이스라인 대비 PD 분리로 prefill과 decode 단계의 유연한 분리
- 리소스 활용 최적화
- 대규모 EP로 메모리 액세스 압력 감소를 통한 MoE 성능 향상

---

## 배치 크기 영향 분석

배치 크기가 시스템에 미치는 영향을 이해하기 위한 절제 연구를 수행했습니다.

**실험 조건**:
- 입력 길이: 2,000 토큰
- 출력 길이: 100 토큰
- 다양한 배치 크기 테스트

**결과**:
- 더 큰 배치 크기일수록 처리량 향상
- 동일한 배치 크기에서 GB200 NVL72가 H100보다 빠른 성능 시연
- 소규모 배치 크기에 대한 최적화는 아직 미완성

---

## 향후 개발 방향

현재 2.5-3.4배 성능 향상을 달성했지만, 추가 개선 가능성이 여전히 존재합니다:

### 다양한 하드웨어 및 병렬화 구성

**소규모 배치 최적화** - B200, RTX 5090과 같은 하드웨어에서 흔히 발생하는 단일 노드의 소규모 배치 크기 실행은 아직 최적화되지 않아 성능이 최적화되지 않을 것으로 예상됩니다.

### Prefill 성능 향상

현재 디코딩 성능에 집중했지만, 다음 단계에서는 prefill 단계 최적화를 우선시할 예정입니다.

### 지연 시간 중심 최적화

이 블로그에서는 처리량에 집중했지만, 지연 시간 최소화는 향후 작업 방향입니다.

### 커널 최적화

많은 커널이 아직 GB200의 메모리 대역폭이나 연산 능력을 완전히 포화시키지 못하고 있습니다.

### 통신 오버랩

GB200 NVL72의 통신 하드웨어 변화를 고려하여, H100에서 활용되는 것과 유사하거나 다른 기술을 사용해 통신을 연산과 오버랩하여 지연 시간을 더욱 줄이고 처리량을 향상시킬 수 있습니다.

### Multi-Token Prediction (MTP)

한 번의 forward pass에서 여러 토큰을 예측하는 것은 특히 배치 크기가 너무 작아 커널이 완전한 성능을 달성하지 못할 때 유익합니다.

---

## 실무 적용 가이드

### 하드웨어 요구사항

**GB200 NVL72 클러스터**:
- 최소 12개 노드 (디코딩용)
- 추가 2-6개 노드 (prefill용)
- NVLink 기반 고속 인터커넥트

### 소프트웨어 스택

**SGLang 설정**:
```bash
# SGLang 설치 및 설정
pip install sglang[all]

# Blackwell 특화 컴포넌트 활성화
export SGLANG_USE_BLACKWELL_DEEPGEMM=1
export SGLANG_USE_BLACKWELL_DEEPEP=1
export SGLANG_USE_FLASHINFER_BLACKWELL=1
```

**DeepSeek 671B 배포**:
```python
import sglang as sgl

# 대규모 EP 설정으로 DeepSeek 671B 실행
runtime = sgl.Runtime(
    model_path="deepseek-ai/deepseek-v3",
    tp_size=16,  # Tensor Parallelism
    ep_size=8,   # Expert Parallelism
    enable_pd_disaggregation=True,
    prefill_nodes=2,
    decode_nodes=12
)
```

### 성능 모니터링

**주요 메트릭**:
- GPU당 tokens/sec
- Inter-Token Latency (ITL)
- 메모리 사용률
- NVLink 대역폭 활용률

```python
# 성능 모니터링 예시
def monitor_performance(runtime):
    metrics = runtime.get_metrics()
    print(f"Throughput: {metrics['tokens_per_sec_per_gpu']:.2f} tokens/sec/GPU")
    print(f"ITL: {metrics['inter_token_latency']:.2f}ms")
    print(f"Memory Usage: {metrics['memory_usage']:.1f}%")
```

---

## 비용 효율성 분석

### H100 대비 TCO 개선

**성능 향상**:
- 2.7배 높은 디코딩 처리량
- 동일한 워크로드 처리를 위한 GPU 수 감소
- 전력 효율성 향상

**운영 비용 절감**:
- 인프라 비용 감소
- 냉각 및 전력 비용 절약
- 관리 복잡성 감소

### ROI 계산

```python
# 간단한 ROI 계산 예시
def calculate_roi(h100_cost, gb200_cost, performance_multiplier=2.7):
    """
    H100 대비 GB200의 ROI 계산
    """
    h100_total_cost = h100_cost * (1 / performance_multiplier)  # 동일 성능을 위한 H100 비용
    gb200_total_cost = gb200_cost
    
    savings = h100_total_cost - gb200_total_cost
    roi_percentage = (savings / gb200_total_cost) * 100
    
    return roi_percentage

# 예시 계산
roi = calculate_roi(h100_cost=30000, gb200_cost=50000)
print(f"GB200 ROI: {roi:.1f}%")
```

---

## 결론

GB200 NVL72에서 DeepSeek 671B 모델의 성능 최적화는 대규모 LLM 추론의 새로운 가능성을 보여줍니다. SGLang과 Blackwell 특화 컴포넌트들의 조합으로 달성한 2.7배 성능 향상은 다음과 같은 의미를 갖습니다:

**기술적 성과**:
- Blackwell 아키텍처의 완전한 활용
- prefill-decode 분리를 통한 리소스 최적화
- 대규모 expert parallelism의 효과적 구현

**실무적 가치**:
- 대규모 LLM 서빙의 비용 효율성 개선
- 실시간 추론 서비스의 확장성 향상
- 차세대 하드웨어 도입의 명확한 ROI 제시

향후 prefill 최적화, 지연 시간 개선, 그리고 Multi-Token Prediction 등의 추가 최적화를 통해 더욱 향상된 성능을 기대할 수 있습니다. 이러한 발전은 대규모 AI 서비스의 경제성과 접근성을 크게 개선할 것으로 전망됩니다.

더 자세한 정보와 재현 방법은 [LMSYS 블로그](https://lmsys.org/blog/2025-06-16-gb200-part-1/?linkId=100000369785742)에서 확인할 수 있습니다. 