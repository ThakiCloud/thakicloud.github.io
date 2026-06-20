---
title: "NVFP4로 Blackwell GPU에서 LLM 서빙 비용 절반 줄이기"
excerpt: "NVIDIA Blackwell의 네이티브 4비트 부동소수점 포맷 NVFP4가 H100 FP8 대비 어떤 이점을 주는지, 그리고 vLLM/TensorRT-LLM 스택에서 실제로 적용하는 방법을 설명한다."
seo_title: "NVFP4 Blackwell LLM 서빙 양자화 가이드 - Thaki Cloud"
seo_description: "NVIDIA Blackwell GPU의 NVFP4 양자화를 활용해 LLM 서빙 처리량을 높이고 GPU 메모리 비용을 줄이는 실전 전략. vLLM과 TensorRT-LLM 적용 방법 포함."
date: 2026-06-20
last_modified_at: 2026-06-20
categories:
  - llmops
tags:
  - nvfp4
  - quantization
  - blackwell
  - vllm
  - tensorrt-llm
  - gpu-memory
  - llm-serving
  - inference-cost
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/llmops/nvfp4-blackwell-llm-serving-quantization/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 8분

GPU 클러스터 비용을 줄이는 가장 직접적인 방법 중 하나는 같은 GPU에서 더 많은 처리량을 뽑는 것입니다. 양자화가 그 수단이고, NVIDIA Blackwell GPU와 NVFP4의 조합은 2026년 LLM 서빙 스택에서 실질적인 선택지가 됐습니다.

## FP8에서 NVFP4로 넘어온 배경

H100(Hopper) 시대의 양자화 기준은 FP8이었습니다. INT8 대비 더 넓은 동적 범위를 유지하면서 연산 밀도를 높였고, 대부분의 서빙 프레임워크가 FP8 지원을 2024~2025년에 갖췄습니다.

Blackwell에서 NVIDIA는 한 단계 더 낮춰 NVFP4를 네이티브 텐서 코어 포맷으로 도입했습니다. NVFP4는 공유 지수부를 가진 4비트 부동소수점으로, 단순 INT4와 달리 부동소수점 의미론을 유지하면서 메모리 풋프린트를 FP8의 절반으로 줄입니다.

Nota AI와 Microsoft Azure AI Foundry가 공개한 자료에 따르면, Blackwell GPU(B200)에서 NVFP4 dense 연산 성능은 FP8 대비 5배입니다. GPU당 10 PFLOPS dense NVFP4 대 2 PFLOPS dense FP8입니다. 이 차이는 메모리 대역폭이 아니라 연산 처리량에서 옵니다.

## NVFP4가 실제로 의미하는 것

모델 크기를 숫자로 보면 이해가 쉽습니다.

Llama-3.1-70B를 기준으로 BF16은 약 140GB, FP8은 약 70GB, NVFP4는 약 35GB가 됩니다. H100 80GB 한 장에 FP8 70B 모델을 올리면 KV 캐시 공간이 거의 없습니다. NVFP4라면 동일 GPU에 모델을 올리고도 KV 캐시에 상당한 여유가 생깁니다. 더 긴 컨텍스트를 소화하거나 배치를 키워 처리량을 늘릴 수 있습니다.

다만 NVFP4는 Blackwell 전용입니다. H100/A100 환경에서는 FP8이 여전히 최선입니다.

## 프레임워크 지원 현황 (2026년 6월 기준)

**TensorRT-LLM**: Blackwell용 NVFP4 지원이 가장 성숙합니다. v0.17 이상에서 B200과 기타 Blackwell GPU에 네이티브 NVFP4 양자화를 지원합니다. 처리량 최우선 프로덕션 환경에 권장합니다.

**vLLM**: FP8을 통한 Blackwell 지원이 안정화됐고, NVFP4 지원은 확장 중입니다. Llama 4 Scout에 대한 Blackwell 레시피가 공식 문서에 올라와 있습니다. ModelOpt와 FlashInfer를 조합해 NVFP4 실행 경로를 씁니다.

**SGLang**: Blackwell 지원을 추가하고 있으나 NVFP4 지원 성숙도는 TensorRT-LLM에 뒤처집니다.

## vLLM에서 FP8 양자화 실전 설정

Blackwell이 아직 없는 환경이라면 H100에서 FP8부터 시작합니다. vLLM의 FP8 설정은 비교적 간단합니다.

```bash
# H100에서 FP8 서빙
vllm serve meta-llama/Llama-3.1-70B-Instruct \
  --quantization fp8 \
  --kv-cache-dtype fp8 \
  --gpu-memory-utilization 0.90 \
  --max-model-len 32768
```

`--kv-cache-dtype fp8`은 KV 캐시도 FP8로 저장해 메모리 효율을 추가로 높입니다. KV 캐시는 긴 컨텍스트에서 메모리를 빠르게 잠식하기 때문에 이 옵션은 거의 항상 켜는 것이 낫습니다.

## Blackwell 환경에서 NVFP4 적용

B200 또는 GB200 클러스터에서 TensorRT-LLM을 사용하는 경우 ModelOpt로 모델을 먼저 양자화합니다.

```bash
# ModelOpt로 NVFP4 양자화
python -m modelopt.torch.quantization.calib \
  --model meta-llama/Llama-3.1-70B-Instruct \
  --quantization nvfp4 \
  --calib-dataset cnn_dailymail \
  --output-dir ./llama-70b-nvfp4

# TensorRT-LLM 엔진 빌드
trtllm-build \
  --checkpoint-dir ./llama-70b-nvfp4 \
  --output-dir ./llama-70b-nvfp4-engine \
  --gemm-plugin nvfp4 \
  --max-batch-size 64 \
  --max-input-len 8192 \
  --max-output-len 2048
```

캘리브레이션 데이터셋 선택이 품질에 영향을 미칩니다. 실제 서빙 트래픽 분포와 비슷한 데이터로 캘리브레이션할수록 정확도 손실이 줄어듭니다.

## K8s 서빙 스택 통합 전략

ThakiCloud처럼 ArgoCD와 Kueue로 GPU 워크로드를 관리하는 환경에서 NVFP4 도입 시 고려할 점이 있습니다.

**GPU 타입별 분기**: Kueue ClusterQueue를 Hopper 노드풀과 Blackwell 노드풀로 분리하고, 각 풀에 적합한 양자화 설정을 다르게 가져갑니다. Blackwell 풀 배포에는 NVFP4, Hopper 풀에는 FP8을 씁니다.

```yaml
# Helm values: GPU 타입별 설정 분기
serving:
  gpuType: "blackwell"  # or "hopper"
  quantization:
    blackwell: "nvfp4"
    hopper: "fp8"
  kvCacheDtype:
    blackwell: "fp8"   # KV 캐시는 FP8 유지 (NVFP4 KV 캐시는 아직 실험적)
    hopper: "fp8"
```

**정확도 회귀 검증**: 양자화 후 모델 교체 전 반드시 품질 회귀 테스트를 거칩니다. MMLU, HumanEval, 또는 자체 벤치마크를 기준으로 BF16 baseline 대비 정확도 차이를 측정하고 허용 임계치(보통 0.5~1%p)를 정해 ArgoCD 배포 파이프라인의 게이트로 씁니다.

## 비용 계산: 실제 절감액

100 GPU 클러스터에서 FP8 대신 NVFP4를 써서 같은 GPU에 2배 컨텍스트를 처리하거나 GPU 수를 절반으로 줄일 수 있다면, GPU당 시간당 $3 기준으로 연간 절감액은 수십만 달러 규모가 됩니다. 물론 실제 절감폭은 모델 크기, 컨텍스트 길이, 배치 구성에 따라 달라집니다.

Blackwell 하드웨어에 대한 접근이 생기기 시작했다면 NVFP4 전환 검토를 미룰 이유가 없습니다. TensorRT-LLM v0.17 이상이면 적용 경로가 충분히 성숙했습니다.
