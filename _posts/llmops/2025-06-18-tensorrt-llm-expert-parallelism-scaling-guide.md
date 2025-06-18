---
title: "TensorRT-LLM Expert Parallelism 완전정복 - 대규모 MoE 모델 추론 최적화 가이드"
excerpt: "NVIDIA TensorRT-LLM의 Expert Parallelism 기술을 활용하여 Mixture of Experts 모델의 대규모 추론 성능을 최적화하는 방법을 알아봅니다."
date: 2025-06-18
categories: 
  - llmops
tags: 
  - TensorRT-LLM
  - Expert-Parallelism
  - MoE
  - GPU-Optimization
  - NVIDIA
  - Inference
  - Scaling
author_profile: true
toc: true
toc_label: "Expert Parallelism 가이드"
---

## 개요

대형 언어 모델(LLM)의 규모가 급속히 증가하면서, 단일 GPU로는 처리할 수 없는 모델들이 등장하고 있습니다. 특히 Mixture of Experts(MoE) 아키텍처는 여러 전문가(expert) 네트워크를 병렬로 운영하여 모델의 용량을 확장하는 혁신적인 접근법입니다. 이 글에서는 NVIDIA TensorRT-LLM의 Expert Parallelism 기술을 활용하여 MoE 모델의 추론 성능을 최적화하는 방법을 상세히 다루겠습니다.

## Mixture of Experts(MoE) 아키텍처 이해

### MoE의 기본 구조

MoE 아키텍처는 기존 dense 모델의 단일 Feedforward Neural Network(FFN) 레이어를 여러 개의 병렬 FFN 레이어(experts)로 교체합니다. 주요 특징은 다음과 같습니다:

- **Router Layer**: 각 토큰에 대해 TopK 전문가를 선택
- **Token Dispatch**: 선택된 전문가들에게 토큰의 hidden state를 분배
- **Parallel Processing**: 여러 전문가가 동시에 계산 수행
- **Result Aggregation**: 각 전문가의 결과를 결합하여 최종 출력 생성

이러한 구조는 Switch Transformer에서 처음 제안되었으며, 현재 Mistral Mixtral 8x7B와 같은 모델에서 널리 사용되고 있습니다.

### MoE의 장점

1. **확장성**: 모델 크기를 효과적으로 늘릴 수 있음
2. **효율성**: 각 토큰이 모든 파라미터를 사용하지 않아도 됨
3. **전문화**: 각 expert가 특정 도메인에 특화될 수 있음

## 병렬화 전략: Tensor Parallel vs Expert Parallel

### Tensor Parallel (TP)

Tensor Parallel은 기본적인 병렬화 패턴으로, 각 전문가의 가중치를 여러 GPU에 균등하게 분할합니다:

```python
# Tensor Parallel 설정 예시
--moe_tp_size 8  # 8개 GPU에 tensor parallel 적용
```

**특징:**
- 각 GPU가 모든 전문가의 부분 가중치를 보유
- 모든 GPU가 모든 토큰의 hidden state를 받음
- 부분 가중치로 계산 수행
- AllReduce 통신 필요

### Expert Parallel (EP)

Expert Parallel은 전문가 전체를 다른 GPU에 분배하는 방식입니다:

```python
# Expert Parallel 설정 예시
--moe_ep_size 8  # 8개 GPU에 expert parallel 적용
```

**특징:**
- 각 GPU가 일부 전문가의 완전한 가중치를 보유
- 해당 GPU의 전문가에 선택된 토큰만 처리
- 완전한 가중치로 계산 수행
- Point-to-point 통신 필요

### 하이브리드 접근법

두 방식을 결합하여 더 나은 성능을 얻을 수 있습니다:

```python
# 하이브리드 설정 예시
--moe_tp_size 4 --moe_ep_size 2  # 총 8개 GPU 사용
```

이 경우 `moe_tp_size * moe_ep_size = tp_size`를 만족해야 합니다.

## 성능 최적화 전략

### 1. 적절한 병렬화 전략 선택

**고처리량 시나리오 (Maximum Throughput)**
- Pipeline Parallel 활용 권장
- Llama 3.1 405B 기준 764 tokens/second 달성 가능

**저지연 시나리오 (Minimum Latency)**  
- Tensor Parallel 활용 권장
- Llama 3.1 405B 기준 56 tokens/second로 5.6배 빠른 응답

### 2. 메모리 효율성 고려사항

```python
# 메모리 효율적인 설정 예시
# Mixtral 8x7B 모델의 경우
num_experts_per_tok = 2  # TopK 설정
num_local_experts = 8    # 로컬 전문가 수
```

### 3. 통신 오버헤드 최적화

**NVLink Switch 활용**
- H200 HGX 시스템에서 NVLink Switch 사용 시
- Pipeline Parallel에서 3.5배 향상된 대역폭 제공
- Expert Parallel 간 통신 효율성 대폭 개선

## 실제 구현 방법

### 체크포인트 변환 설정

```bash
# Expert Parallel만 사용하는 경우
python convert_checkpoint.py \
    --moe_ep_size 8 \
    --model_dir /path/to/model \
    --output_dir /path/to/output

# Tensor Parallel만 사용하는 경우  
python convert_checkpoint.py \
    --moe_tp_size 8 \
    --model_dir /path/to/model \
    --output_dir /path/to/output

# 하이브리드 사용하는 경우
python convert_checkpoint.py \
    --moe_tp_size 4 \
    --moe_ep_size 2 \
    --model_dir /path/to/model \
    --output_dir /path/to/output
```

### 엔진 빌드 최적화

```bash
# 최적화된 엔진 빌드
trtllm-build \
    --checkpoint_dir /path/to/checkpoint \
    --output_dir /path/to/engine \
    --gemm_plugin float16 \
    --gpt_attention_plugin float16 \
    --paged_kv_cache enable \
    --max_batch_size 128
```

## 성능 벤치마크 결과

### GPU 처리량 비교

| 모델 | 병렬화 방식 | 처리량 (tokens/sec) | 개선율 |
|------|-------------|-------------------|--------|
| GPT MoE 1.8T | TP64 | 506 | 기준 |
| GPT MoE 1.8T | EP16PP4 | 764 | 1.5x |
| GPT MoE 1.8T | TP4EP4PP4 | 1,518 | 3x |

### 실제 운영 환경에서의 고려사항

**청킹(Chunking) 전략**
- 작은 청크 크기: 높은 TPS, 높은 TTFT
- 큰 청크 크기: 낮은 TTFT, 낮은 TPS
- 최적 청크 크기: 896 토큰 (GPT 1.8T MoE 기준)

## 모범 사례 및 권장사항

### 1. 배치 크기 최적화

```python
# 동적 배치 처리 설정
max_batch_size = 128
max_num_tokens = 8192
```

### 2. KV 캐시 관리

```python
# 페이지드 KV 캐시 활용
paged_kv_cache = True
kv_cache_free_gpu_mem_fraction = 0.9
```

### 3. 모니터링 및 디버깅

```bash
# 성능 모니터링
nvidia-smi dmon -s pucvmet -i 0,1,2,3,4,5,6,7
```

## 차세대 하드웨어: NVIDIA Blackwell

NVIDIA Blackwell 아키텍처는 MoE 모델 추론에 혁신적인 성능 향상을 제공합니다:

- **208B 트랜지스터**: 2세대 Transformer 엔진
- **5세대 NVLink**: 1.8TB/s 양방향 처리량
- **72 GPU 도메인**: 최대 72개 Blackwell GPU 연결 지원
- **30배 처리량 향상**: H100 대비 읽기 속도 20 tokens/second에서

## 결론

TensorRT-LLM의 Expert Parallelism은 대규모 MoE 모델의 추론 성능을 획기적으로 개선할 수 있는 핵심 기술입니다. 적절한 병렬화 전략 선택, 통신 오버헤드 최적화, 그리고 차세대 하드웨어 활용을 통해 기존 대비 최대 3배의 성능 향상을 달성할 수 있습니다.

특히 하이브리드 접근법(TP+EP+PP)을 통해 처리량과 지연시간의 균형을 맞추는 것이 중요하며, 실제 운영 환경에서는 워크로드 특성에 맞는 최적화가 필요합니다.

앞으로 MoE 모델이 더욱 발전함에 따라 Expert Parallelism 기술의 중요성은 계속 증가할 것으로 예상됩니다. 개발자들은 이러한 기술을 활용하여 더욱 효율적이고 확장 가능한 AI 시스템을 구축할 수 있을 것입니다.

## 참고 자료

- [NVIDIA TensorRT-LLM Expert Parallelism 문서](https://nvidia.github.io/TensorRT-LLM/advanced/expert-parallelism.html)
- [Scaling LLMs with NVIDIA Triton and TensorRT-LLM](https://developer.nvidia.com/blog/scaling-llms-with-nvidia-triton-and-nvidia-tensorrt-llm-using-kubernetes/)
- [Demystifying AI Inference Deployments for Trillion Parameter Models](https://developer.nvidia.com/blog/demystifying-ai-inference-deployments-for-trillion-parameter-large-language-models)
- [Switch Transformer Paper](https://arxiv.org/pdf/2101.03961.pdf) 