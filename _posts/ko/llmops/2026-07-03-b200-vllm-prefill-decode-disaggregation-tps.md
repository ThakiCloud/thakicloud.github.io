---
title: "B200 두 장으로 vLLM Prefill/Decode를 분리하면 정말 빨라질까"
excerpt: "NVIDIA B200 두 장에서 Qwen3.6-27B-NVFP4와 gemma-4-26B-A4B를 대상으로 텐서병렬, 데이터병렬, Prefill/Decode 분리(1P1D)의 초당 생성 토큰을 실제로 측정했습니다. 두 장뿐일 때 총 처리량의 승자는 분리가 아니라 데이터병렬이었고, 이 결과는 DistServe·Mooncake·DeepSeek·NVIDIA Dynamo 같은 대규모 사례와 모순되지 않습니다. 언제 분리하고 언제 그냥 DP/TP인지, 근거와 함께 판정 가이드를 정리합니다."
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
  image: /assets/images/b200-vllm-pd-disaggregation-hero.webp
categories:
  - llmops
---

![B200 두 장이 Prefill과 Decode를 나눠 맡는 구조를 형상화한 이미지]({{ '/assets/images/b200-vllm-pd-disaggregation-hero.webp' | relative_url }})
*한 장은 Prefill, 한 장은 Decode를 맡고 KV 캐시가 NVLink로 건너가는 분리 서빙 구조를 형상화했습니다.*

## 개요

"GPU가 두 장 있으니 Prefill과 Decode를 따로 태우면 더 빠르지 않을까"는 서빙을 만지는 사람이라면 한 번쯤 떠올리는 생각입니다. 저희도 그 가설을 실제 하드웨어에서 검증했습니다. NVIDIA B200 두 장 위에서 vLLM 0.24로 세 가지 배치를 같은 워크로드로 돌려 초당 생성 토큰(TPS)을 쟀습니다. 대상 모델은 NVIDIA가 공개한 `Qwen3.6-27B-NVFP4`와 RedHat이 공개한 `gemma-4-26B-A4B-it-FP8-Dynamic` 두 가지입니다.

결론을 먼저 말씀드리면, 두 장뿐인 환경에서 총 처리량의 승자는 Prefill/Decode 분리가 아니었습니다. 분리는 오히려 총 TPS가 가장 낮았고, 대신 입력이 길고 출력이 짧은 트래픽에서 토큰 간 지연을 서너 배 낮추는 데서 값을 했습니다. 그런데 이 결과는 NVIDIA나 중국 대규모 서빙 사례가 보고하는 큰 성능 향상과 모순되지 않습니다. 분리의 이득은 규모와 SLO에 달린 최적화이고, 우리는 그 곡선의 작은 끝을 잰 것이기 때문입니다. 그래서 이 글은 우리 실측 수치와 맨바닥 B200를 돌게 만든 과정에 더해, DistServe와 Splitwise, Mooncake, DeepSeek, NVIDIA Dynamo의 근거를 놓고 언제 분리하고 언제 그냥 데이터병렬이나 텐서병렬로 가야 하는지를 판정하는 가이드까지 함께 정리합니다.

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

## 그래서 언제 분리하고, 언제 그냥 DP/TP인가

여기서 자연스러운 의문이 생깁니다. NVIDIA 블로그도, 중국의 대규모 서빙 시스템들도 분리로 큰 성능 향상을 보고하는데, 왜 우리 결과는 반대일까요. 문헌을 실제로 뒤져 보면 답은 분명합니다. 우리 결과는 그들과 모순되지 않습니다. 분리의 이득은 규모와 SLO에 의존하는 최적화이지 보편적 승리가 아니며, 우리는 그 곡선의 작은 끝을 측정한 것뿐입니다.

이 크로스오버를 정면으로 연구한 논문이 있습니다. "Beyond the Buzz: A Pragmatic Take on Inference Disaggregation"([arXiv:2506.05508](https://arxiv.org/html/2506.05508))는 분리의 이점이 prefill이 무거운 트래픽에서 가장 크고, 반대로 출력이 긴 decode 중심 트래픽이나 느슨한 SLO, 작은 모델에서는 오히려 같은 GPU에 얹는 편(piggybacking)이 앞선다고 정리합니다. 8B급 작은 모델은 매핑되는 GPU 수가 적어 prefill과 decode를 나눌 여지 자체가 좁고, KV 캐시도 HBM에 여유롭게 들어가 굳이 옮길 이유가 없다는 것입니다. 두 장에서 27B 모델을 돌린 우리 상황이 정확히 그 구간입니다.

### 분리가 이기는 조건

분리로 큰 이득을 보고한 사례들은 공통 조건을 공유합니다. 첫째, GPU가 매우 많습니다. UCSD Hao AI Lab의 회고는 분리가 필요해지는 지점을 수백에서 수천 장 규모로 설명합니다([회고 글](https://haoailab.com/blogs/distserve-retro/)). 둘째, 지연 SLO가 빡셉니다. 분리의 대표 논문 DistServe(OSDI 2024)의 핵심 지표는 원시 처리량이 아니라 SLO를 90% 넘게 지키면서 몇 배의 요청을 소화하느냐, 즉 goodput입니다. OPT 13B에서 175B를 NVLink로 묶은 A100 클러스터에서 훨씬 빡센 SLO를 견뎠다고 보고합니다([USENIX](https://www.usenix.org/conference/osdi24/presentation/zhong-yinmin), [arXiv:2401.09670](https://arxiv.org/abs/2401.09670)). 셋째, 대형 또는 MoE 모델을 비대칭 병렬로 태웁니다. DeepSeek-V3/R1 계열은 prefill을 좁은 전문가 병렬로, decode를 넓은 전문가 병렬로 나눠 텐서병렬 대비 decode 처리량이 크게 올랐다고 공개했는데, 그 설정이 96장 H100에 prefill 4노드와 decode 9노드를 나눠 얹는 규모였습니다([LMSYS](https://www.lmsys.org/blog/2025-05-05-large-scale-ep/)). 넷째, 긴 컨텍스트로 KV 캐시가 크고 재사용됩니다. Mooncake는 KV 캐시 중심 분리로 긴 컨텍스트에서 강점을 보고합니다([arXiv:2407.00079](https://arxiv.org/abs/2407.00079)). 다섯째, KV를 싸게 옮길 고속 패브릭이 있습니다. Splitwise는 InfiniBand로, Mooncake는 수백 Gbps급 RDMA로 KV를 넘겨 전송 부담을 낮췄습니다([Microsoft Research](https://www.microsoft.com/en-us/research/blog/splitwise-improves-gpu-usage-by-splitting-llm-inference-phases/)). NVIDIA가 Dynamo와 GB200 NVL72로 보고하는 큰 배수도 671B급 초대형 모델을 수십 장 규모 랙에서 돌린 결과입니다([NVIDIA](https://developer.nvidia.com/blog/introducing-nvidia-dynamo-a-low-latency-distributed-inference-framework-for-scaling-reasoning-ai-models/)).

### DP/TP가 나은 조건

반대로 아래 조건에서는 그냥 데이터병렬이나 텐서병렬로 복제하는 편이 낫습니다. 모델이 GPU 한두 장에 들어갈 만큼 작을 때, 출력이 길어 decode가 지배하는 트래픽일 때, 지연 SLO가 느슨할 때, GPU가 소수여서 prefill 풀과 decode 풀을 따로 놀지 않게 채울 여유가 없을 때, 개발이나 저QPS 일회성 워크로드라 분리 운영의 복잡도가 정당화되지 않을 때, 그리고 노드 간 대역폭이 NVLink나 InfiniBand급이 아니라 PCIe급이라 KV 전송이 오히려 병목이 될 때입니다. 우리 실험의 2×B200 환경은 이 목록의 여러 항목에 정확히 해당합니다. 27B 모델이 한 장에 들어가고, GPU가 둘뿐이며, 총 처리량이 목표였습니다.

### 판정을 가르는 네 변수

결국 선택은 네 가지 변수의 조합으로 결정됩니다. prefill과 decode의 연산 비율(prefill이 무거울수록 분리 유리), 지연 SLO의 빡셈(빡셀수록 분리 유리), GPU 규모(클수록 분리 유리), 그리고 KV 전송 비용 대비 절감량(캐시가 크고 재사용되거나 패브릭이 빠를수록 분리 유리)입니다. 어느 하나라도 반대쪽이면 분리의 이득은 줄고, 소수 GPU에 작은 모델에 느슨한 SLO가 겹치면 분리는 손해입니다.

### 근거 요약

| 시스템 | 보고된 이득 | 측정된 규모 | 출처 |
|---|---|---|---|
| DistServe (OSDI'24) | SLO 준수하 7.4배 요청 또는 12.6배 빡센 SLO | OPT 13B~175B, A100 NVLink 클러스터 | [arXiv:2401.09670](https://arxiv.org/abs/2401.09670) |
| Splitwise (ISCA'24) | 1.4배 처리량(비용 20%↓) 또는 2.35배 처리량 | prompt/token 풀 분리, InfiniBand KV 전송 | [MS Research](https://www.microsoft.com/en-us/research/blog/splitwise-improves-gpu-usage-by-splitting-llm-inference-phases/) |
| Mooncake (Kimi) | 시뮬레이션 SLO하 최대 525% 처리량 | 최대 800Gbps RDMA, 긴 컨텍스트 중심 | [arXiv:2407.00079](https://arxiv.org/abs/2407.00079) |
| DeepSeek-V3/R1 | TP 대비 decode 처리량 5.2배 | 96장 H100, prefill 4노드 / decode 9~18노드 | [LMSYS](https://www.lmsys.org/blog/2025-05-05-large-scale-ep/) |
| NVIDIA Dynamo + NVL72 | DeepSeek-R1에서 최대 수십 배 | 671B, GB200 NVL72 랙 | [NVIDIA](https://developer.nvidia.com/blog/introducing-nvidia-dynamo-a-low-latency-distributed-inference-framework-for-scaling-reasoning-ai-models/) |
| Beyond the Buzz (크로스오버 연구) | 작은 모델·decode 중심·느슨한 SLO에서 이득 축소/역전 | 모델·규모 교차 체계 연구 | [arXiv:2506.05508](https://arxiv.org/html/2506.05508) |

즉 분리는 "초대형 모델을 많은 GPU에 걸쳐 얹고, 빡센 지연 목표를 고속 패브릭 위에서 맞추는" 케이스의 기술입니다. 두 장에서 중형 모델을 돌리며 총 처리량을 노린다면 데이터병렬이 정답이고, 이것이 우리 실측과 문헌이 함께 가리키는 결론입니다. 위 배수들은 각 논문이 측정한 특정 규모의 값이며 일부(Mooncake 실측치, TensorRT-LLM 자체 수치)는 원문 간 표현이 엇갈려 그대로 인용하기 전 재확인이 필요합니다.

## 맨바닥 B200를 돌게 만들기까지

수치만큼 값진 것이 "어떻게 돌게 만들었나"입니다. 이 호스트는 드라이버만 있고 추론 스택이 없는 상태였고, 아래 벽들을 차례로 넘었습니다.

첫째, CUDA 컴파일러 nvcc가 없어 FlashInfer가 샘플러와 어텐션 커널을 런타임에 빌드하려다 실패했습니다. 어텐션 백엔드를 Triton으로 바꾸고 FlashInfer 샘플러를 끄자 정상 동작했습니다. 이는 곧, nvcc를 설치하면 Blackwell 전용 FlashInfer 고속 커널로 더 높은 TPS를 노릴 여지가 남아 있다는 뜻이기도 합니다.

둘째, 첫 서버 기동이 800초 안팎으로 매우 길었습니다. torch.compile과 CUDA 그래프 캡처 때문인데, 데이터병렬은 엔진 코어 두 개가 동시에 컴파일하느라 vLLM 기본 준비 타임아웃 600초를 넘겨 죽었습니다. 타임아웃을 1800초로 올려 해결했습니다.

셋째, Qwen3.6의 하이브리드 어텐션은 Mamba 계열 conv 상태를 갖는데, 이를 NIXL로 전송하려면 특정 conv 상태 레이아웃이 필요했습니다. 에러 메시지가 알려준 대로 `VLLM_SSM_CONV_STATE_LAYOUT=DS`를 설정하자 KV 전송이 성립했고, 프록시를 통한 한 건의 정확도 확인으로 분리가 실제로 올바르게 동작함을 검증했습니다.

이 발견들은 다시 밟지 않도록 재사용 가능한 실험 스킬에 실패 사례로 박아 두었습니다. 같은 벽을 다음 사람이 다시 만나지 않는 것, 그것이 실험을 자산으로 만드는 방법이라고 생각합니다.

## ThakiCloud 관점에서

저희는 쿠버네티스 위에서 GPU 추론을 서빙하는 주권형 AI 플랫폼을 만듭니다. 이 실험이 저희 운영에 주는 시사점은 분명합니다. "분리가 최신이니까 분리하자"는 유행 추종은 소수 GPU 환경에서 오히려 처리량을 깎을 수 있고, 반대로 대규모 고QPS 서비스에서 분리를 안 쓰는 것은 지연 SLO를 놓치는 일이라는 것입니다. 정답은 하나로 고정되지 않고, 앞 절의 네 변수, 곧 GPU 규모와 모델 크기, 트래픽의 prefill과 decode 비율, 지연 SLO, 그리고 패브릭 속도가 함께 정합니다.

문제는 그 크로스오버가 회사마다, 워크로드마다 다르다는 점입니다. 같은 27B 모델이라도 2장에서는 데이터병렬이 답이지만, 같은 모델을 수십 장에 얹어 긴 컨텍스트를 빡센 SLO로 서빙한다면 분리가 답이 됩니다. 그 경계를 감으로 찍으면 GPU 예산을 태우거나 SLO를 놓칩니다. 저희가 하는 일이 바로 이것입니다. 고객의 실제 하드웨어와 실제 트래픽 위에서 이번 글처럼 토폴로지별 수치를 뽑아 그 경계를 측정으로 찾고, 데이터병렬과 텐서병렬과 분리 사이를 워크로드에 맞춰 전환하는 서빙 플랫폼을 함께 구축합니다. 이번 실험에 쓴 벤치 파이프라인과 접속 자동화도 재사용 가능한 자산으로 관리해, 다음 모델과 다음 하드웨어에서 같은 판단을 며칠이 아니라 몇 시간에 내릴 수 있게 합니다.

그래서 B200이든 H200이든 새 가속기를 도입하며 "우리 워크로드에는 어떤 토폴로지가 맞는가"를 정해야 하는 팀이라면, 저희와 함께 그 답을 측정으로 내리는 것이 가장 빠른 길이라고 생각합니다. 유행이 아니라 여러분의 숫자로 결정하도록 돕는 것, 그것이 ThakiCloud가 추론 최적화에서 제공하는 가치입니다.

## 결론과 한계

두 모델을 2×B200에서 가장 빠르게 서빙하라는 요구에 대한 실측 답은, 총 처리량이 목표라면 데이터병렬이고 Prefill/Decode 분리는 아니라는 것입니다. 다만 입력이 길고 출력이 짧으며 낮고 고른 토큰 지연이 목표인 서비스라면 분리가 TPOT를 서너 배 낮춰 주므로 그때는 분리가 정답입니다. 선택은 처리량이냐 지연 안정이냐이며, 이 실험은 그 트레이드오프에 실제 숫자를 붙였습니다.

한계도 정직하게 남깁니다. 어텐션 백엔드가 Triton으로 고정되어 Blackwell 네이티브 FlashInfer와 NVFP4 고속 경로의 상한은 측정하지 못했습니다. nvcc 설치가 후속 과제입니다. 요청률은 포화 한 점만 봤고 지연과 처리량의 전체 곡선은 그리지 않았습니다. Qwen의 다중 토큰 예측 speculative decoding과 gemma의 expert-parallel 같은 모델별 처리량 레버도 후속 축으로 남겼습니다. 이들을 더하면 절대 수치는 올라갈 수 있으나, 두 장에서 분리는 총 처리량을 위한 것이 아니라는 이 실험의 핵심 결론은 바뀌지 않을 것으로 봅니다.

## 참고 자료

- 모델 A: [nvidia/Qwen3.6-27B-NVFP4](https://huggingface.co/nvidia/Qwen3.6-27B-NVFP4)
- 모델 B: [RedHatAI/gemma-4-26B-A4B-it-FP8-Dynamic](https://huggingface.co/RedHatAI/gemma-4-26B-A4B-it-FP8-Dynamic)
- vLLM 분산 서빙 문서: [docs.vllm.ai](https://docs.vllm.ai/en/latest/features/disagg_prefill.html)
- DistServe (OSDI 2024): [arXiv:2401.09670](https://arxiv.org/abs/2401.09670)
- Splitwise (ISCA 2024): [Microsoft Research](https://www.microsoft.com/en-us/research/blog/splitwise-improves-gpu-usage-by-splitting-llm-inference-phases/)
- Mooncake (Kimi/Moonshot): [arXiv:2407.00079](https://arxiv.org/abs/2407.00079)
- DeepSeek 대규모 전문가 병렬: [LMSYS 블로그](https://www.lmsys.org/blog/2025-05-05-large-scale-ep/)
- NVIDIA Dynamo: [NVIDIA 개발자 블로그](https://developer.nvidia.com/blog/introducing-nvidia-dynamo-a-low-latency-distributed-inference-framework-for-scaling-reasoning-ai-models/)
- 크로스오버 연구 (Beyond the Buzz): [arXiv:2506.05508](https://arxiv.org/html/2506.05508)
- 분리 서빙 18개월 회고: [Hao AI Lab](https://haoailab.com/blogs/distserve-retro/)
