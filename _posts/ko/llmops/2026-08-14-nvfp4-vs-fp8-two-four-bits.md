---
title: "같은 4비트가 FP8을 사이에 두고 반대편에 섭니다"
excerpt: "B200에서 코더 MoE 하나를 네 정밀도로 서빙해 봤더니 NVFP4는 FP8보다 빠르고 W4A16은 느렸습니다. 비트폭이 같은데 부호가 갈리는 이유와, 4비트가 느리다는 측정이 나올 때 벤치마크 쪽을 먼저 의심해야 하는 이유를 정리합니다."
seo_title: "NVFP4 vs FP8 vs W4A16: B200 4비트 서빙 실측 - Thaki Cloud"
seo_description: "Qwen3-Coder-30B-A3B를 bf16, FP8, W4A16, NVFP4 네 정밀도로 단일 B200에서 측정했습니다. NVFP4는 FP8 대비 1.07~1.32배 빠르고 W4A16은 0.75~0.84배로 느립니다. HumanEval은 넷 다 구분되지 않습니다."
date: 2026-08-14
tags:
  - NVFP4
  - FP8
  - 양자화
  - Blackwell
  - LLMOps
author_profile: true
toc: true
toc_label: "목차"
lang: ko
permalink: /ko/llmops/nvfp4-vs-fp8-two-four-bits/
canonical_url: "https://thakicloud.com/tech-blog/ko/llmops/nvfp4-vs-fp8-two-four-bits/"
categories:
  - llmops
audiobook: "https://drive.google.com/file/d/15ymQqqV9dT0kw36rJCeFZAgJw3zsqmTl/view"
audiobook_label: "▶ 5분 브리핑으로 듣기"
audiobook_note: "NotebookLM 오디오 개요 (AI 생성)"
---

Blackwell에서 MoE를 서빙하며 정밀도를 고르고 있다면, 4비트를 하나로 묶어 생각하는 것이 가장 비싼 실수입니다. 같은 모델을 W4A16으로 내리면 FP8보다 느려지고 NVFP4로 내리면 FP8보다 빨라집니다. 비트폭은 같은데 결론의 부호가 반대죠.

![같은 4비트가 FP8을 사이에 두고 반대편에 섭니다 개념을 형상화한 이미지](/assets/images/nvfp4-vs-fp8-two-four-bits-hero.webp)
*글의 핵심 개념을 형상화했습니다.*

## 한 모델, 네 정밀도

Qwen3-Coder-30B-A3B 하나를 bf16, FP8, W4A16, NVFP4로 만들어 B200 한 장에서 같은 워크로드로 돌렸습니다. 입력 1,746토큰에 출력 256토큰, 동시성은 1에서 512까지, 레벨마다 세 번씩입니다.

| 동시성 | bf16 | FP8 | W4A16 | NVFP4 |
|---|---|---|---|---|
| 1 | 300.6 | 257.6 | 215.9 | **303.3** |
| 8 | 1,707.1 | 1,491.5 | 1,311.2 | **1,962.2** |
| 32 | 4,454.2 | 3,978.8 | 3,013.3 | **5,099.2** |
| 64 | 6,448.2 | 6,054.7 | 4,292.4 | **7,608.3** |
| 128 | 8,586.2 | 8,130.3 | 5,427.7 | **9,941.8** |
| 256 | 5,982.5 | 6,002.4 | 4,584.5 | **6,422.6** |
| 512 | 6,858.7 | 6,302.0 | 4,103.3 | **6,925.4** |

단위는 output tok/s입니다. NVFP4는 모든 동시성에서 FP8을 이깁니다. 배수로는 1.07배에서 1.32배 사이이고 동시성 8에서 가장 벌어집니다. W4A16은 반대로 모든 동시성에서 FP8에 집니다. FP8의 0.75배에서 0.84배 수준입니다.

동시성 256 위쪽은 네 정밀도가 전부 꺾인 뒤라 배수가 1.0 쪽으로 눌립니다. 그 구간 숫자를 헤드라인으로 쓰면 안 됩니다.

에너지에서는 격차가 더 벌어집니다. 동시성 128 기준으로 에너지당 토큰이 NVFP4는 12.82이고 FP8은 9.48입니다. 1.35배인데, 같은 지점의 처리량 이득 1.22배보다 큽니다. 4비트가 연산량만 줄이는 게 아니라 메모리 트래픽도 함께 줄이기 때문입니다.

![nvfp4-vs-fp8-two-four-bits 슬라이드 1](/assets/images/nvfp4-vs-fp8-two-four-bits-slide-01.webp)

## 활성값을 줄였느냐가 갈랐습니다

두 4비트의 차이는 활성값입니다.

W4A16은 가중치만 4비트로 저장하고 활성값은 16비트로 둡니다. 그래서 실제 행렬곱을 할 때 가중치를 다시 16비트로 풀어야 합니다. 메모리는 확실히 아끼는 대신 연산 경로에 디퀀타이즈라는 일이 하나 더 붙죠. 배치가 작아 메모리 대역폭이 병목인 구간에서는 이 거래가 남지만, 연산이 병목이 되는 순간부터는 순손실입니다.

NVFP4는 활성값까지 4비트로 내립니다. 그러면 Blackwell의 FP4 텐서코어가 그 값을 그대로 물어서 계산합니다. 푸는 단계가 없습니다. B200의 FP4 피크 연산량이 FP8의 두 배라는 스펙이 여기서 현금화되는 겁니다.

그래서 "4비트는 용량을 사지 속도를 사지 않는다"는 문장은 절반만 맞습니다. W4A16에 대해서는 참이고 NVFP4에 대해서는 거짓입니다.

![nvfp4-vs-fp8-two-four-bits 슬라이드 2](/assets/images/nvfp4-vs-fp8-two-four-bits-slide-02.webp)

## 품질은 넷 다 구분되지 않습니다

속도만 보고 고르면 안 되니 같은 하네스로 HumanEval 전수 164문항을 돌렸습니다. pass@1이 bf16 0.9207, FP8 0.9146, W4A16 0.9268, NVFP4 0.9024로 나왔습니다. 표준오차가 각각 0.021 수준인데 넷의 전체 폭이 0.024입니다. 유의한 차이가 하나도 없다는 뜻이죠.

여기서 정직하게 적어야 할 게 있습니다. **NVFP4가 넷 중 수치상 가장 낮습니다.** bf16 대비 z가 −0.58이라 이 검정력으로는 구분되지 않는 크기지만, 그렇다고 "NVFP4가 품질도 낫다"고 말할 근거는 없습니다. 방어할 수 있는 진술은 측정 가능한 손실이 없다는 데까지입니다.

하네스가 제대로 돌았는지는 bf16이 알려줍니다. 여기서 0.9207이 나왔고 다른 날 다른 하네스로 잰 같은 모델이 0.9267이었습니다. 0.6포인트면 노이즈 안입니다.

![nvfp4-vs-fp8-two-four-bits 슬라이드 3](/assets/images/nvfp4-vs-fp8-two-four-bits-slide-03.webp)

## 4비트가 느리게 나왔다면 벤치마크를 먼저 보십시오

저희도 한동안 NVFP4가 빠르지 않다는 측정을 들고 있었습니다. 커널은 멀쩡했고 재는 방식이 틀렸습니다.

가장 큰 원인은 프롬프트 길이였습니다. 29토큰이면 프리필이 거의 없어서 사실상 디코드만 재는 셈인데, 4비트가 이기는 구간은 연산이 병목인 곳입니다. 이길 수 있는 구간을 워크로드가 아예 보지 못한 겁니다.

GPU도 한 번도 포화되지 않았습니다. 사용률이 54에서 85퍼센트 사이를 오갔는데, 그 상태에서 나온 평평한 결과를 하드웨어 천장으로 읽었죠. 천장이 아니라 바닥이었습니다.

마지막으로 후보당 한 번씩만 쟀습니다. 나중에 같은 체크포인트를 다시 돌려 보니 재현 편차가 후보 사이의 차이보다 컸습니다. 애초에 순위를 매길 수 있는 데이터가 아니었던 겁니다.

![nvfp4-vs-fp8-two-four-bits 슬라이드 4](/assets/images/nvfp4-vs-fp8-two-four-bits-slide-04.webp)

## 커널 경로는 물어보지 말고 확인하십시오

NVFP4를 올렸다고 해서 FP4 텐서코어를 탄다는 보장은 없습니다. vLLM은 조건이 안 맞으면 조용히 weight-only Marlin 에뮬레이션으로 떨어집니다. 그 경로는 가중치만 4비트로 압축해 두고 연산은 더 높은 정밀도로 되돌려서 하기 때문에, 그 상태로 잰 숫자는 NVFP4가 아니라 에뮬레이션의 성능이죠.

서버 기동 로그에 어느 백엔드를 골랐는지가 한 줄로 찍힙니다.

```
INFO nvfp4.py:285 Using 'FLASHINFER_TRTLLM' NvFp4 MoE backend out of potential
backends: ['FLASHINFER_TRTLLM', 'FLASHINFER_CUTLASS', ..., 'MARLIN', 'EMULATION'].
```

여기에 `MARLIN`이 찍혀 있거나 아래 경고가 같이 보이면 그 런의 수치는 버려야 합니다.

```
WARNING marlin_utils_fp4.py Your GPU does not have native support for FP4
computation but FP4 quantization is being used.
```

저희는 이 줄을 사람이 읽는 대신 벤치 스크립트가 파싱해서, 네이티브가 아니면 런을 실패시키도록 바꿨습니다. 로그 어딘가에 있는 정보를 나중에 찾아 읽는 방식으로는 놓칩니다. 실제로 놓쳤고, 그래서 바꿨습니다.

한 가지 더 있습니다. 체크포인트가 FP4인지를 이 로그 줄로 판정하면 안 됩니다. dense 모델에는 MoE 백엔드 줄이 아예 안 찍히기 때문에, 진짜 NVFP4 dense 빌드를 물려도 "FP4 체크포인트가 아님"으로 읽고 통과시킵니다. 판정은 체크포인트의 `config.json`에서 해야 합니다.

## 어디까지 적용되는 이야기인가

Hopper에는 전이되지 않습니다. H200과 H100에는 FP4 텐서코어가 없어서 vLLM이 Marlin 경로로 갑니다. 같은 NVFP4 체크포인트를 H200에 올리면 bf16보다 15퍼센트 느립니다. 거기서 NVFP4가 사는 값은 속도가 아니라 적재 가능성입니다. 원래 두 장이 필요하던 모델이 한 장에 들어가죠.

측정 자체의 경계도 분명합니다. 모델 하나, GPU 한 장, 워크로드 한 형태입니다. 배치 구성이나 컨텍스트 길이가 다르면 배수는 달라집니다.

## 정리

Blackwell 타깃이라면 4비트 기본값은 NVFP4입니다. 품질은 FP8과 구분되지 않고, 속도는 1.07에서 1.32배 빠르며, 에너지당 토큰은 1.35배이고, 크기는 FP8의 58퍼센트입니다. 지는 축이 없습니다.

W4A16이 여전히 이기는 자리도 있습니다. 파일이 조금 더 작고, Hopper에서도 돕니다. 다만 속도를 노리고 W4A16을 고른 것이라면 그 선택은 어긋났습니다. 커널을 튜닝해서 좁힐 수 있는 격차가 아니라, 활성값을 안 줄인 데서 오는 구조적 격차입니다.

이 글의 수치는 단일 B200에서 vLLM 0.27.1로 잰 실측값이며 시뮬레이션이 아닙니다.


## 출처

- vLLM Project, [Quantization 지원 개요, vLLM Docs](https://docs.vllm.ai/en/latest/features/quantization/index.html)
- vLLM Project, [vllm-project/vllm, GitHub](https://github.com/vllm-project/vllm)
- NVIDIA, [Blackwell Architecture](https://www.nvidia.com/en-us/data-center/technologies/blackwell-architecture/)
- Qwen Team, [Qwen3-Coder-30B-A3B-Instruct 모델 카드, Hugging Face](https://huggingface.co/Qwen/Qwen3-Coder-30B-A3B-Instruct)
- Chen et al., [Evaluating Large Language Models Trained on Code, arXiv:2107.03374](https://arxiv.org/abs/2107.03374)
- NVIDIA, [TensorRT Model Optimizer, GitHub](https://github.com/NVIDIA/TensorRT-Model-Optimizer)
