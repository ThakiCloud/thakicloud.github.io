---
title: "B200 두 장으로 vLLM Prefill/Decode를 분리하면 정말 빨라질까"
excerpt: "NVIDIA B200 두 장에서 Qwen3.6-27B-NVFP4와 gemma-4-26B-A4B를 대상으로 텐서병렬, 데이터병렬, Prefill/Decode 분리(1P1D)의 초당 생성 토큰을 실제로 측정했습니다. 결론부터 말하면, 두 장뿐일 때 총 처리량의 승자는 분리가 아니라 데이터병렬이었고 분리는 지연을 고르게 만드는 쪽에서 값을 했습니다."
seo_title: "B200 2-GPU vLLM Prefill/Decode 분리 TPS 실측 - Qwen3.6-NVFP4 / gemma-4-FP8 | Thaki Cloud"
seo_description: "NVIDIA B200 2장에서 vLLM 0.24로 텐서병렬(TP=2), 데이터병렬(DP=2), Prefill/Decode 분리(1P1D, NIXL)의 TPS와 TPOT를 실측했습니다. NVFP4와 하이브리드 어텐션, MoE 서빙의 실전 gotcha까지 ThakiCloud GPU 서빙 운영 관점으로 정리합니다."
date: 2026-07-03
last_modified_at: 2026-07-03
tags:
  - vllm
  - b200
  - prefill-decode-disaggregation
  - nixl
  - nvfp4
  - gpu-serving
  - llmops
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "microchip"
header:
  image: /assets/images/b200-vllm-pd-disaggregation-hero.png
categories:
  - llmops
---

![B200 두 장이 Prefill과 Decode를 나눠 맡는 구조를 형상화한 이미지](/assets/images/b200-vllm-pd-disaggregation-hero.png)
*한 장은 Prefill, 한 장은 Decode를 맡고 KV 캐시가 NVLink로 건너가는 분리 서빙 구조를 형상화했습니다.*

## 개요

"GPU가 두 장 있으니 Prefill과 Decode를 따로 태우면 더 빠르지 않을까"는 서빙을 만지는 사람이라면 한 번쯤 떠올리는 생각입니다. 저희도 그 가설을 실제 하드웨어에서 검증했습니다. NVIDIA B200 두 장 위에서 vLLM 0.24로 세 가지 배치를 같은 워크로드로 돌려 초당 생성 토큰(TPS)을 쟀습니다. 대상 모델은 NVIDIA가 공개한 `Qwen3.6-27B-NVFP4`와 RedHat이 공개한 `gemma-4-26B-A4B-it-FP8-Dynamic` 두 가지입니다.

결론을 먼저 말씀드리면, 두 장뿐인 환경에서 총 처리량의 승자는 Prefill/Decode 분리가 아니었습니다. 분리는 오히려 총 TPS가 가장 낮았고, 대신 입력이 길고 출력이 짧은 트래픽에서 토큰 간 지연을 서너 배 낮추는 데서 값을 했습니다. 이 글은 그 수치와, 맨바닥 B200 박스를 실제로 돌게 만들기까지 부딪힌 벽들을 함께 정리합니다.

## 왜 이 실험을 했나

Prefill과 Decode는 성격이 다른 연산입니다. Prefill은 입력 전체를 한 번에 밀어 넣는 연산 집약적 단계이고, Decode는 토큰을 하나씩 뽑는 메모리 대역폭 집약적 단계입니다. 한 GPU에서 둘을 섞으면 무거운 Prefill이 Decode 스트림 사이에 끼어들어 토큰이 끊깁니다. 그래서 큰 클러스터에서는 Prefill 전용 노드와 Decode 전용 노드를 나누는 분리(disaggregation) 구조가 표준이 되어가고 있습니다.

문제는 "GPU가 딱 두 장"일 때입니다. 한 장을 Prefill 전용으로 묶으면 Decode가 바쁠 때 그 장이 놀고, Prefill이 한가할 때도 Decode를 도울 수 없습니다. 그래서 저희는 분리가 이득이라고 가정하지 않고, 같은 모델을 두 장에 그냥 복제하는 데이터병렬을 정식 경쟁자로 세워 측정으로 판정하기로 했습니다.

## 실험 환경

호스트는 드라이버만 깔린 베어메탈이었고, 나머지 소프트웨어 스택은 실행하면서 확인하고 확정했습니다.

| 항목 | 값 |
|---|---|
| GPU | NVIDIA B200 × 2 (각 183GB HBM), GPU0와 GPU1 사이 NVLink(NV18) |
| 드라이버 | 580.95.05 (CUDA 13 계열) |
| vLLM / torch | vLLM 0.24.0 / torch 2.11.0+cu130 |
| 어텐션 백엔드 | Triton (호스트에 CUDA 툴킷 nvcc가 없어 FlashInfer JIT 불가) |
| 모델 A | nvidia/Qwen3.6-27B-NVFP4 (dense 27B, 하이브리드 어텐션, NVFP4 가중치 + FP8 KV) |
| 모델 B | RedHatAI/gemma-4-26B-A4B-it-FP8-Dynamic (MoE 26.5B 중 활성 4B, FP8 W8A8) |

두 모델 모두 가중치가 B200 한 장에 들어갑니다. NVFP4는 약 15GB, FP8은 약 27GB이므로 텐서병렬로 굳이 쪼갤 필요가 없습니다. 그래서 두 장을 쓰는 세 가지 배치를 비교했습니다. 한 인스턴스를 두 장에 텐서병렬로 펴는 TP=2, 두 복제를 각 장에 올리는 데이터병렬 DP=2, 그리고 Prefill을 GPU0에 Decode를 GPU1에 두고 KV 캐시를 NIXL로 넘기는 분리 1P1D입니다.

## 측정 방법

부하 생성은 vLLM 내장 `vllm bench serve`를 썼고, 워크로드는 두 축으로 잡았습니다. 하나는 Decode가 무거운 트래픽(입력 512, 출력 2048), 다른 하나는 Prefill이 무거운 트래픽(입력 7500, 출력 200)입니다. 요청은 전량을 한 번에 투입해 포화 처리량을 봤습니다. 읽은 지표는 총 출력 처리량(TPS)과 토큰 간 지연(TPOT)입니다.

서버 기동과 벤치는 아래와 같은 형태로 돌렸습니다. 백엔드 환경 변수는 이 박스에서 필수였는데, 그 이유는 뒤에서 설명합니다.

```bash
# 공통 환경 (nvcc 부재 대응)
export VLLM_ATTENTION_BACKEND=TRITON_ATTN
export VLLM_USE_FLASHINFER_SAMPLER=0

# 데이터병렬 2복제 (한 엔드포인트, 두 장)
vllm serve $MODEL --data-parallel-size 2 --gpu-memory-utilization 0.90 \
  --max-model-len 32768 --trust-remote-code

# 벤치 (Decode 무거운 워크로드 예시)
vllm bench serve --model $MODEL --dataset-name random \
  --random-input-len 512 --random-output-len 2048 \
  --num-prompts 128 --request-rate inf --ignore-eos
```

분리는 Prefill 서버와 Decode 서버를 따로 띄우고 `--kv-transfer-config`로 NixlConnector를 물린 뒤, vLLM이 제공하는 프록시로 묶었습니다.

```bash
# Prefill (GPU0, producer)
CUDA_VISIBLE_DEVICES=0 VLLM_NIXL_SIDE_CHANNEL_PORT=5600 \
vllm serve $MODEL --port 8100 --tensor-parallel-size 1 \
  --kv-transfer-config '{"kv_connector":"NixlConnector","kv_role":"kv_producer"}'

# Decode (GPU1, consumer)
CUDA_VISIBLE_DEVICES=1 VLLM_NIXL_SIDE_CHANNEL_PORT=5601 \
vllm serve $MODEL --port 8200 --tensor-parallel-size 1 \
  --kv-transfer-config '{"kv_connector":"NixlConnector","kv_role":"kv_consumer"}'
```

## 결과: Qwen3.6-27B-NVFP4

| 토폴로지 | Decode TPS | Prefill TPS | Decode TPOT | Prefill TPOT |
|---|---|---|---|---|
| DP=2 (데이터병렬) | 8,245 | 2,230 | 11.4ms | 32.8ms |
| TP=2 (텐서병렬) | 7,655 | 1,545 | 12.2ms | 44.1ms |
| 1P1D (분리) | 6,023 | 1,330 | 14.8ms | 9.9ms |

그림이 선명합니다. 총 TPS는 데이터병렬이 두 워크로드 모두에서 1등이고, 분리가 꼴찌입니다. Decode 무거운 워크로드에서 데이터병렬은 텐서병렬보다 8% 높고 분리보다 37% 높습니다. Prefill 무거운 워크로드에서는 격차가 더 벌어져 데이터병렬이 분리의 1.7배입니다. 두 장뿐인데 한 장을 Prefill 전용으로 묶은 대가를, 노는 시간이 그대로 청구한 셈입니다.

그런데 분리가 유일하게 이긴 칸이 있습니다. Prefill 무거운 워크로드의 토큰 간 지연이 9.9ms로, 텐서병렬 44ms나 데이터병렬 33ms의 4분의 1 수준입니다. 이것이 분리의 존재 이유입니다. 섞인 구성에서는 무거운 Prefill이 Decode 사이에 끼어들어 토큰이 끊기는데, 분리 구성에서는 Decode 전용 장이 Prefill에 방해받지 않아 토큰이 매끄럽게 나옵니다. 분리는 "많이"가 아니라 "고르게"를 위한 기술이라는 교과서적 설명이, 그대로 숫자로 나타났습니다.

## 결과: gemma-4-26B-A4B-it-FP8-Dynamic

| 토폴로지 | Decode TPS | Prefill TPS | Decode TPOT | Prefill TPOT |
|---|---|---|---|---|
| TP=2 (텐서병렬) | 7,069 | 1,730 | 13.6ms | 40.9ms |
| 1P1D (분리) | 5,766 | 1,474 | 17.9ms | 8.7ms |
| DP=2 (데이터병렬) | 미측정 | 미측정 | 실패 | 실패 |

gemma는 MoE 모델이라 서빙 스택이 dense 모델보다 까다로웠습니다. 텐서병렬과 분리는 정상 측정됐지만, 데이터병렬은 두 번 시도했는데 모두 vLLM 0.24의 MoE와 데이터병렬을 함께 쓰는 경로에서 기동에 실패했습니다. 첫 시도는 CUTLASS MoE 워밍업 단정에서, 배치 토큰 상한을 낮춘 두 번째 시도는 KV 캐시 메모리 프로파일링의 MoE 순전파에서 죽었습니다. 즉 이 버전에서 gemma를 데이터병렬로 띄우는 것은 현재 지원되지 않으며, 그 자체가 유의미한 발견입니다. MoE 모델은 데이터병렬 안정성이 dense 모델보다 낮습니다. 측정 가능한 두 구성만 비교하면, 총 TPS는 텐서병렬이 분리보다 높다는 패턴이 gemma에서도 그대로 유지됩니다. 그리고 분리의 Prefill TPOT가 8.7ms로 텐서병렬 40.9ms를 압도하는 점도 Qwen과 동일합니다.

## 맨바닥 B200를 돌게 만들기까지

수치만큼 값진 것이 "어떻게 돌게 만들었나"입니다. 이 호스트는 드라이버만 있고 추론 스택이 없는 상태였고, 아래 벽들을 차례로 넘었습니다.

첫째, CUDA 컴파일러 nvcc가 없어 FlashInfer가 샘플러와 어텐션 커널을 런타임에 빌드하려다 실패했습니다. 어텐션 백엔드를 Triton으로 바꾸고 FlashInfer 샘플러를 끄자 정상 동작했습니다. 이는 곧, nvcc를 설치하면 Blackwell 전용 FlashInfer 고속 커널로 더 높은 TPS를 노릴 여지가 남아 있다는 뜻이기도 합니다.

둘째, 첫 서버 기동이 800초 안팎으로 매우 길었습니다. torch.compile과 CUDA 그래프 캡처 때문인데, 데이터병렬은 엔진 코어 두 개가 동시에 컴파일하느라 vLLM 기본 준비 타임아웃 600초를 넘겨 죽었습니다. 타임아웃을 1800초로 올려 해결했습니다.

셋째, Qwen3.6의 하이브리드 어텐션은 Mamba 계열 conv 상태를 갖는데, 이를 NIXL로 전송하려면 특정 conv 상태 레이아웃이 필요했습니다. 에러 메시지가 알려준 대로 `VLLM_SSM_CONV_STATE_LAYOUT=DS`를 설정하자 KV 전송이 성립했고, 프록시를 통한 한 건의 정확도 확인으로 분리가 실제로 올바르게 동작함을 검증했습니다.

이 발견들은 다시 밟지 않도록 재사용 가능한 실험 스킬에 실패 사례로 박아 두었습니다. 같은 벽을 다음 사람이 다시 만나지 않는 것, 그것이 실험을 자산으로 만드는 방법이라고 생각합니다.

## ThakiCloud 관점에서

저희는 쿠버네티스 위에서 GPU 추론을 서빙하는 주권형 AI 플랫폼을 만듭니다. 이 실험이 저희 운영에 주는 시사점은 분명합니다. 소수 GPU 환경에서 "분리가 최신이니까 분리하자"는 유행 추종은 오히려 처리량을 깎을 수 있다는 것입니다. 분리는 GPU가 충분히 많아 Prefill 풀과 Decode 풀을 독립적으로 스케일할 수 있고, 서비스 목표가 낮고 고른 토큰 지연일 때 값을 합니다. 반대로 GPU가 빠듯하고 목표가 총 처리량이라면 데이터병렬 복제가 더 나은 기본값입니다.

그래서 저희 플랫폼은 서빙 토폴로지를 하나로 고정하지 않고, 워크로드 모양과 GPU 예산에 따라 데이터병렬과 분리 사이를 고를 수 있도록 설계 방향을 잡고 있습니다. 그리고 이런 결정을 감이 아니라 측정으로 내리기 위해, 이번처럼 실제 하드웨어에서 토폴로지별 수치를 뽑는 벤치 파이프라인 자체를 재사용 가능한 자산으로 관리합니다.

## 결론과 한계

두 모델을 2×B200에서 가장 빠르게 서빙하라는 요구에 대한 실측 답은, 총 처리량이 목표라면 데이터병렬이고 Prefill/Decode 분리는 아니라는 것입니다. 다만 입력이 길고 출력이 짧으며 낮고 고른 토큰 지연이 목표인 서비스라면 분리가 TPOT를 서너 배 낮춰 주므로 그때는 분리가 정답입니다. 선택은 처리량이냐 지연 안정이냐이며, 이 실험은 그 트레이드오프에 실제 숫자를 붙였습니다.

한계도 정직하게 남깁니다. 어텐션 백엔드가 Triton으로 고정되어 Blackwell 네이티브 FlashInfer와 NVFP4 고속 경로의 상한은 측정하지 못했습니다. nvcc 설치가 후속 과제입니다. 요청률은 포화 한 점만 봤고 지연과 처리량의 전체 곡선은 그리지 않았습니다. Qwen의 다중 토큰 예측 speculative decoding과 gemma의 expert-parallel 같은 모델별 처리량 레버도 후속 축으로 남겼습니다. 이들을 더하면 절대 수치는 올라갈 수 있으나, 두 장에서 분리는 총 처리량을 위한 것이 아니라는 이 실험의 핵심 결론은 바뀌지 않을 것으로 봅니다.

## 참고 자료

- 모델 A: [nvidia/Qwen3.6-27B-NVFP4](https://huggingface.co/nvidia/Qwen3.6-27B-NVFP4)
- 모델 B: [RedHatAI/gemma-4-26B-A4B-it-FP8-Dynamic](https://huggingface.co/RedHatAI/gemma-4-26B-A4B-it-FP8-Dynamic)
- vLLM 분산 서빙 문서: [docs.vllm.ai](https://docs.vllm.ai/en/latest/features/disagg_prefill.html)
