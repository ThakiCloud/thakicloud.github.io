---
title: "40만 달러 랙을 24GB 그래픽카드로? ktransformers의 '28배'를 직접 재현해봤습니다"
excerpt: "MoE 전문가를 CPU로 내려 24GB GPU 한 장으로 거대 모델을 돌린다는 ktransformers. 화제가 된 '28배'와 '40만 달러를 24GB로'를 RunPod에서 직접 쟀습니다. 트릭은 진짜였고, INT4 AMX 커널을 켜니 671B급이 디코딩 약 16 tok/s로 돌았습니다."
date: 2026-07-19
tags:
  - ktransformers
  - MoE
  - LLM서빙
  - GPU
  - AMX
  - LLMOps
  - 벤치마크
  - 인프라
author_profile: true
toc: true
toc_label: 28배의 해부
categories:
  - llmops
canonical_url: "https://thakicloud.com/tech-blog/ko/llmops/ktransformers-moe-offload-28x-validation/"
audiobook: "https://drive.google.com/file/d/1RyBSyAe6yY-C7xVGw3YxNi_PJ5o7aVjW/view"
audiobook_label: "▶ 5분 브리핑으로 듣기"
audiobook_note: "NotebookLM 오디오 개요 (AI 생성)"
---

이 글은 GPU 한 장으로 대형 MoE 모델을 자체 서빙할 수 있을지 저울질하는 인프라 담당자를 위한 것입니다. 결론만 먼저 말하면, ktransformers의 오프로드 트릭은 실재하고, INT4 AMX 커널을 제대로 켜면 671B급 모델이 약 16 tok/s의 준-인터랙티브 속도로 돌아갑니다.

![40만 달러 랙을 24GB 그래픽카드로? ktransformers의 '28배'를 직접 재현해봤습니다 개념을 형상화한 이미지](/assets/images/ktransformers-moe-offload-28x-validation-hero.png)
*24GB GPU 한 장으로 671B급 MoE를 돌리는 오프로드 구조를 형상화했습니다.*

## 왜 화제가 되었나

칭화대 MADSYS 연구실이 공개한 ktransformers(kvcache-ai/ktransformers, Apache 2.0, 별 1.7만 개)의 발상은 한 문장으로 끝납니다. MoE 모델에서 지금 호출되는 전문가만 GPU 근처에 두고, 대부분의 시간 놀고 있는 전문가는 CPU 메모리에 앉혀 두었다가 필요할 때만 불러옵니다. 이 배치 덕에 24GB VRAM에서 DeepSeek-V3와 R1을 139K 컨텍스트로 돌리고, 표준 설정 대비 최대 28배 빠르다는 이야기가 퍼졌습니다. 트릭이 허무할 만큼 단순해서 오히려 청구서가 어디 숨어 있는지 궁금했고, 그래서 RunPod에서 GPU를 여러 번 빌려 직접 숫자를 뽑았습니다.

<!-- nlm-visual -->
![ktransformers MoE 오프로드 요약 인포그래픽 1](/assets/images/posts/news/ktransformers-moe-offload-28x-validation/nlm-infographic-1.png)
*NotebookLM이 이 글을 종합해 생성한 인포그래픽입니다.*

## 실험 설계: 작은 모델로 메커니즘을 분리하다

먼저 메커니즘 자체를 상용 하드웨어에서 떼어 봤습니다. DeepSeek-V3는 671B라 24GB에 안 실리므로 같은 계열(MLA + fine-grained MoE)의 축소판인 Qwen3-30B-A3B(총 30B, 활성 3.3B)를 Q4로 대리 측정했습니다. RTX 4090에 AMD Ryzen 9 7950X를 붙인 구성에서, 모델을 통째로 GPU에 올리면 261.5 tok/s가 나오는데 전문가만 CPU로 내리면 12.0 tok/s, 전부 CPU면 7.4 tok/s였습니다. 여기서 핵심이 드러납니다. 오프로드는 순수 CPU보다 1.62배 빠르지만, 모델이 VRAM에 들어가기만 하면 full-GPU가 22배 앞섭니다. 즉 이 트릭은 속도가 목적이 아니라, 모델이 VRAM을 넘칠 때 그래도 돌아가게 만드는 도구입니다.

## Intel AMX 커널이 만든 진짜 배수

그럼 28배는 어디서 올까요. 우선 그 숫자는 디코딩이 아니라 프리필(prefill) 처리량 배수입니다(V0.3 기준 llama.cpp 대비 약 27.79배). 프리필은 프롬프트를 한 번에 밀어 넣어 병렬성이 큰 구간이라 배수가 크게 벌어지고, 디코딩은 토큰을 하나씩 뽑아 활성 파라미터의 CPU 연산이 병목입니다. 28배의 근거로 지목되는 AMX 커널만 따로 재보면, Sapphire Rapids 세대 Xeon Platinum 8470에서 AMX 커널은 같은 BF16 가중치 기준 AVX2보다 1.38배 빨랐습니다. 분명한 이득이지만 커널 하나가 28배를 만들지는 않습니다. 그 큰 배수는 어텐션과 KV 캐시를 GPU로 올린 지렛대, AMX 커널의 약 1.4배, INT4 양자화, 파이프라인 최적화가 특정 조건에서 곱해질 때, 그리고 비교 대상이 순수 CPU llama.cpp일 때만 나오는 값입니다.

## "40만 달러 랙을 24GB로"의 진실

"40만 달러 랙을 24GB 한 장으로"라는 문구도 뜯어볼 필요가 있습니다. 이건 메모리를 없앤 게 아니라 옮긴 것입니다. DeepSeek-V3를 Q4로 돌리려면 CPU 쪽에 약 380GB의 DRAM이 필요합니다. 전문가 가중치는 사라지지 않고 VRAM에서 시스템 RAM으로 자리를 옮길 뿐이므로, 정확한 표현은 "24GB GPU 한 장 + 대용량 RAM 서버"입니다. 비싼 GPU를 값싼 RAM으로 바꾼 것이지 총 메모리가 준 것은 아닙니다. 다만 하드웨어 주장 자체는 성립합니다. 24GB에도 80GB에도 안 들어가는 Qwen3-235B-A22B(Q4, 약 130GB)를 오프로드하면 GPU가 쓰는 메모리는 11GB에 불과했습니다. 235B 모델이 12GB 카드에도 올라간다는 뜻입니다.

## 디코딩을 가르는 INT4 커널: 진짜 tok/s와 비용

디코딩 속도는 어떤 CPU 커널을 켜느냐에 따라 네 배 넘게 갈립니다. 원저자가 공개한 값을 보면 DeepSeek-V3/R1을 q4km(INT4)으로 RTX 4090 24GB와 듀얼 Xeon Gold 6454S(382GB~1TB DRAM)에서 돌릴 때 디코딩이 최대 약 14~16 tok/s입니다. 반면 커널을 켜지 않은 경로는 훨씬 느립니다. SOSP25 논문의 최적화 이전 baseline은 decode 4.68 tok/s에 GPU 활용률 30% 미만이고, 전문가 배치만 흉내 낸 llama.cpp `--n-cpu-moe`(AMX INT4도 MLA도 CUDA graph도 없이)나 랜덤 BF16 가중치 외삽은 1.2~3.8 tok/s의 바닥을 찍습니다. 이 격차의 정체를 정식 스택으로 분리했습니다. Xeon Platinum 8480+(Sapphire Rapids, AMX 지원)와 2TB RAM, H100 위에 ktransformers의 kt-kernel(0.6.3, 소스 빌드)을 올려, DeepSeek-V3 실제 형상(히든 7168, MoE 중간 2048, 활성 전문가 8개, MoE 58개 층)의 디코딩을 커널만 바꿔 가며 쟀습니다.

| 커널 (동일 형상, 디코딩 토큰당) | MoE 전용 디코딩 |
|---|---|
| AMX INT4 (AMXInt4_MOE) | 12.4 tok/s |
| AMX INT8 (AMXInt8_MOE) | 6.0 tok/s |
| AMX BF16 (AMXBF16_MOE) | 3.2 tok/s |
| AVX2 BF16 (AVX2BF16_MOE) | 2.9 tok/s |

INT4 커널은 같은 형상에서 BF16보다 3.9배, AVX2보다 4.2배 빨랐습니다. 앞서 나온 1.2~3.8 tok/s의 바닥이 정확히 위 표의 BF16과 AVX2 줄이고, 오프로드 디코딩을 한 자릿수 초반으로 보고하는 측정은 대개 이 INT4 커널을 켜지 않은 값입니다. 이유는 단순합니다. 디코딩은 토큰마다 활성 전문가의 가중치를 RAM에서 읽어 오는 대역폭 병목 구간인데, INT4는 BF16보다 바이트를 4분의 1만 읽으면 됩니다. 이 12.4 tok/s는 MoE 층만 CPU에서 스레드 60개로 튜닝한 값이고(112개로 늘리면 NUMA 동기화 비용에 오히려 6.6으로 떨어졌습니다), 실제 서빙에서는 어텐션과 shared expert가 GPU에서 겹쳐 돌아 원저자가 공개한 14~16 tok/s와 같은 대역에 놓입니다. 한 자릿수 초반이 아니라 두 자릿수 초반, 준-인터랙티브가 맞습니다.

비용 그림도 다시 그려야 합니다. DeepSeek-V3-671B를 Q4로 담으려면 약 380GB가 필요해 2×A100 160GB에는 애초에 들어가지 않고, 정직한 full-GPU 기준은 8×H100/A100 노드입니다.

| 구성 | 하드웨어 | 시간당 | 디코딩 |
|---|---|---|---|
| Full-GPU (V3-671B) | 8×H100/A100 노드 | 약 $16~24 | 높음 |
| Offload (INT4 AMX) | 4090 24GB + 듀얼 Xeon | 약 $3 | 약 14~16 tok/s |

즉 대형 Xeon 서버를 이미 굴리고 있다면 그 위에 1,600달러짜리 4090 한 장을 꽂아 671B급을 준-인터랙티브로 돌릴 수 있고, 이는 8장짜리 GPU 노드를 새로 사거나 빌리는 것보다 압도적으로 쌉니다.

## 그래서 도입해야 하나

도입 판단은 두 질문으로 좁혀집니다. 이미 확보한 대형 AMX 서버와 대용량 RAM이 있는가, 그리고 돌리려는 모델이 GPU VRAM을 실제로 넘치는 대형 MoE(V3, R1 급)인가. 둘 다 맞으면 ktransformers는 값비싼 다중 GPU 노드를 사지 않고도 그 모델을 돌리는 가장 현실적인 경로입니다. 반대로 모델이 GPU에 통째로 들어간다면 고민 없이 full-GPU가 수십 배 빠르고, 수천 tok/s의 고동시성 실시간 서빙이 목표라면 여전히 다중 GPU가 맞습니다. 오프로드의 자리는 GPU에 안 들어가는 대형 모델을 한 장으로 준-인터랙티브하게 돌린다는 좁고 분명한 지점입니다. 그래서 ktransformers의 진짜 가치는 28배도 저렴한 서빙도 아니라, 다중 GPU를 살 수 없는 팀이 이미 가진 서버와 GPU 한 장으로 671B급 MoE를 아예 돌릴 수 있게 된다는 접근성 하나입니다.

<!-- nlm-visual -->
![ktransformers MoE 오프로드 요약 인포그래픽 2](/assets/images/posts/news/ktransformers-moe-offload-28x-validation/nlm-infographic-2.png)
*NotebookLM이 이 글을 종합해 생성한 인포그래픽입니다.*

## 재현 정보

모든 실험은 RunPod에서 진행했고 GPU 총비용은 약 18달러였습니다. 벤치 하네스와 원시 결과 JSON은 [github.com/sylvanus4/ktransformers-moe-offload-bench](https://github.com/sylvanus4/ktransformers-moe-offload-bench)(Apache-2.0)에 전부 공개했습니다. 직접 재현하거나 숫자를 검증하고 싶다면 그대로 받아 돌려 보시면 됩니다. 대형 MoE 오프로드를 벤치할 때 배수를 가르는 것은 결국 하나입니다. 저자가 실제로 서빙하는 경로, 특히 INT4 AMX 커널을 그대로 타고 있는지부터 확인하는 것입니다.
