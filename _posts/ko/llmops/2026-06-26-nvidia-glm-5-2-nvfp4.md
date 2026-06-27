---
title: "NVIDIA GLM-5.2-NVFP4: 753B 프런티어 MoE를 4비트로 서빙하기"
excerpt: "NVIDIA가 ZAI의 753B MoE 추론 모델 GLM-5.2를 NVFP4(4비트)로 양자화해 Hugging Face에 공개했습니다. 모든 가중치를 일괄로 깎는 대신 MoE 전문가의 선형 연산자만 4비트로 줄이고 공유 전문가와 어텐션은 BF16으로 남기는 선택적 양자화로, FP8 기준선 대비 정확도를 거의 그대로 유지합니다. 양자화 전략과 공개 벤치마크, vLLM/SGLang 배포 명령을 ThakiCloud의 K8s 멀티테넌트 서빙 관점에서 정리합니다."
seo_title: "NVIDIA GLM-5.2-NVFP4 753B MoE 4비트 양자화 vLLM SGLang 서빙 분석 - Thaki Cloud"
seo_description: "nvidia/GLM-5.2-NVFP4(NVFP4 4비트 양자화)의 선택적 양자화 전략, FP8 대비 정확도 유지, vLLM/SGLang 배포 명령, Blackwell TP=8 요구를 ThakiCloud K8s 기반 멀티테넌트 서빙 플랫폼 관점에서 분석합니다."
date: 2026-06-26
last_modified_at: 2026-06-26
categories:
  - llmops
tags:
  - nvfp4
  - quantization
  - vllm
  - sglang
  - glm
  - moe
  - inference-optimization
  - model-optimizer
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "microchip"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/ko/llmops/nvidia-glm-5-2-nvfp4/"
reading_time: true
---

![16비트 신경망 격자가 4비트의 압축된 코어로 응축되는 추상 이미지](/assets/images/nvidia-glm-5-2-nvfp4-hero.png)
*16비트 가중치가 4비트로 응축되는 개념을 시각화한 이미지입니다.*

프런티어급 추론 모델을 자체 인프라에서 서빙하려는 팀에게 가장 먼저 부딪히는 벽은 GPU 메모리입니다. 753B 파라미터를 16비트로 그대로 올리면 1.5TB에 가까운 메모리가 필요하고, 이는 곧 GPU 노드 여러 대를 의미합니다. NVIDIA가 2026년 6월 25일 Hugging Face에 공개한 `nvidia/GLM-5.2-NVFP4`는 ZAI(zai-org)의 GLM-5.2를 4비트로 양자화해 이 벽을 낮추려는 시도입니다.

이 글은 GLM-5.2라는 모델 자체의 소개글이 아닙니다. 이 모델의 추론 토큰 길이가 자가호스팅 비용 셈법을 어떻게 바꾸는지는 [추론 토큰 경제성 글](https://thakicloud.github.io/ko/llmops/glm-5-2-reasoning-token-economics/)에서, 컨슈머 하드웨어용 1비트 GGUF 양자화는 [Unsloth GGUF 글](https://thakicloud.github.io/ko/llmops/unsloth-glm-5-2-1bit-gguf/)에서 이미 다뤘습니다. 이 글이 보려는 것은 데이터센터 트랙입니다. NVIDIA가 직접 공개한 NVFP4 양자화가 어떤 구조를 택했고, 어떤 하드웨어에서 어떻게 서빙되며, 멀티테넌트 서빙을 운영하는 입장에서 무엇을 의미하는가입니다.

본문의 정확도 수치는 모두 NVIDIA가 모델카드에 공개한 공식 측정치입니다. 753B 모델은 NVIDIA Blackwell 전용에 8-way 텐서 병렬을 요구하므로 ThakiCloud의 개발 환경에서는 직접 재현하지 못했습니다. 따라서 이 글은 공개 자료에 기반한 분석이며, 재현 수치를 임의로 만들어 넣지 않았습니다. 출처가 갈리는 값은 `[추정]`으로 표시합니다.

## 개요

![753B 파라미터를 16비트로 올리면 1.5TB에 달하는 GPU 메모리 벽](/assets/images/nvidia-glm-5-2-nvfp4-slide-02.png)
*프런티어급 모델을 자체 인프라에 서빙할 때 가장 먼저 부딪히는 벽은 GPU 메모리입니다.*

`nvidia/GLM-5.2-NVFP4`는 ZAI의 `zai-org/GLM-5.2`를 NVIDIA Model Optimizer(ModelOpt)로 양자화한 버전입니다. 베이스 모델은 추론과 코딩을 위한 Mixture-of-Experts(MoE) 구조로, 총 753B 파라미터 중 토큰당 40B만 활성화됩니다. 네트워크 아키텍처는 `GlmMoeDsaForCausalLM`이며, IndexShare 인덱서를 사용하는 희소 어텐션(sparse attention)으로 최대 1M 토큰의 긴 컨텍스트를 지원합니다. 라이선스는 베이스 모델과 동일한 MIT로, 상업·비상업 모두 사용 가능합니다.

핵심을 한 문장으로 요약하면 이렇습니다. **MoE는 연산량을, 선택적 NVFP4 양자화는 메모리를 줄이되, 정확도에 민감한 부분은 일부러 양자화에서 제외합니다.** MoE 구조 덕분에 753B 모델이면서도 토큰당 계산은 40B 활성 전문가에 한정됩니다. 여기에 NVFP4가 더해져 모델의 메모리 무게 대부분을 차지하는 라우팅 전문가의 가중치를 16비트에서 4비트로 낮춥니다. 그러면서도 공유 전문가는 양자화하지 않고 BF16으로 남겨, 정확도 손실을 최소화하는 방향을 택했습니다.

타이밍도 의미가 있습니다. 강한 오픈웨이트 모델이 MIT로 풀리는 흐름과, NVIDIA가 그 모델을 자사 하드웨어에 맞춰 곧장 서빙 가능한 형태로 재배포하는 흐름이 맞물립니다. 모델 주권을 고민하는 조직에게 이것은 추상적 정책 이슈가 아니라 "어떤 GPU에 무엇을 어떻게 올릴 것인가"라는 당장의 아키텍처 선택입니다.

## 이 모델은 무엇인가

![지식 용량은 753B, 토큰당 연산은 40B 활성 전문가로 분리하는 MoE 희소성](/assets/images/nvidia-glm-5-2-nvfp4-slide-03.png)
*MoE 희소성과 어텐션 희소성이 결합해 지식 용량과 연산량을 분리합니다.*

GLM-5.2는 ZAI가 공개한 MoE 추론·코딩 모델입니다. 일반적인 밀집(dense) 모델과 달리, 트랜스포머 블록 안에 여러 개의 전문가(expert) 네트워크를 두고 입력 토큰마다 일부만 활성화합니다. GLM-5.2는 총 753B 파라미터를 가지지만 토큰 하나를 생성할 때 실제로 계산에 참여하는 것은 40B 활성 파라미터뿐입니다. 즉 모델의 "지식 용량"은 753B급이지만, 추론 시 연산 비용은 40B 밀집 모델에 가깝습니다.

여기에 더해 GLM-5.2는 IndexShare 인덱서를 활용한 희소 어텐션을 사용합니다. 1M 토큰이라는 긴 컨텍스트를 지원하면서도 모든 토큰 쌍을 빠짐없이 비교하는 완전 어텐션의 비용을 피하려는 설계입니다. 모델카드는 이 아키텍처를 `glm_moe_dsa`로 표기하며, 실행을 위해 `transformers>=5.3.0`을 요구합니다. 이 두 가지, 즉 MoE 희소성과 어텐션 희소성이 결합해 프런티어급 추론 능력을 비교적 절약된 연산으로 제공하는 것이 GLM-5.2의 출발점입니다.

NVFP4는 NVIDIA가 정의한 4비트 부동소수점 데이터 타입입니다. 정수 4비트가 아니라 부동소수점이라는 점이 중요합니다. 구체적으로는 작은 부동소수점(E2M1) 값을 16개씩 묶고, 그 블록마다 FP8(E4M3) 스케일을 붙이는 블록 단위 2단계 스케일링을 씁니다. 블록마다 동적 범위를 따라가기 때문에 단순 정수 양자화보다 분포의 꼬리를 잘 보존합니다. NVIDIA는 이 모델이 자사가 처음부터 학습한 모델이 아니라 제3자 모델을 양자화한 버전임을 모델카드에 명확히 밝히고 있으며, 양자화 도구로 오픈소스 NVIDIA Model Optimizer를 사용했습니다.

## 핵심은 "선택적" 양자화입니다

![GLM-5.2-NVFP4 선택적 양자화 전략과 서빙 경로 도식](/assets/images/nvidia-glm-5-2-nvfp4-diagram.png)
*MoE 라우팅 전문가의 선형 연산자만 NVFP4로 양자화하고, 공유 전문가와 어텐션은 BF16으로 남깁니다.*

이 모델에서 가장 중요한 설계 결정은 "무엇을 양자화하지 않았는가"입니다. 모델카드의 표현을 그대로 옮기면, "MoE 전문가 안 트랜스포머 블록 내부 선형 연산자의 가중치와 활성값만 양자화하며, 공유 전문가는 양자화하지 않는다"입니다. 정리하면 다음과 같습니다.

- **NVFP4(4비트)로 양자화**: MoE 라우팅 전문가의 선형 연산자 가중치와 활성값. 이 부분이 753B 파라미터의 대부분을 차지하므로, 메모리 절감 효과의 거의 전부가 여기서 나옵니다.
- **BF16(16비트)로 보존**: 공유 전문가, 그리고 IndexShare 희소 어텐션 경로. 모든 토큰이 항상 통과하는 부분이라 정확도에 미치는 영향이 크기 때문입니다.

이 전략이 합리적인 이유는 MoE의 파라미터 분포에 있습니다. 라우팅 전문가는 수가 많아 전체 파라미터의 압도적 비중을 차지하지만, 각 토큰은 그중 일부만 사용합니다. 반대로 공유 전문가와 어텐션은 파라미터 비중은 작지만 모든 토큰이 반드시 통과합니다. 따라서 "양이 많고 듬성듬성 쓰이는 곳은 과감하게 4비트로, 양은 적지만 항상 쓰이는 곳은 정밀하게 16비트로" 나누는 것이 메모리와 정확도를 동시에 챙기는 합리적 절충입니다. 정확도 표가 거의 손실 없이 유지되는 근본 원인이 바로 이 선택적 양자화에 있습니다.

양자화 보정(calibration)에는 NVIDIA의 Nemotron 계열 데이터셋이 사용되었습니다. 모델카드는 Nemotron-SFT-Instruction-Following-Chat-v2, Nemotron-Science-v1, Nemotron-Competitive-Programming-v1, Nemotron-SFT-Agentic-v2, Nemotron-Math-v2, Nemotron-SFT-SWE-v2, Nemotron-SFT-Multilingual-v1을 보정 데이터로 명시합니다. 추론·과학·코딩·에이전트·수학·다국어를 고루 포함하는 구성으로, 평가 벤치마크의 성격과 결을 맞춘 것을 알 수 있습니다.

## 공개 벤치마크: FP8 대비 정확도

![FP8 기준선과 NVFP4의 벤치마크 점수 비교 막대 그래프](/assets/images/nvidia-glm-5-2-nvfp4-results.png)
*nvidia/GLM-5.2-NVFP4 모델카드의 공개 측정치입니다. 기준선은 GLM-5.2-FP8입니다.*

NVIDIA가 모델카드에 공개한 정확도 비교는 아래와 같습니다. 기준선은 BF16이 아니라 한 단계 압축된 `GLM-5.2-FP8`이라는 점이 특징입니다. 즉 "압축 안 한 원본 대비"가 아니라 "이미 8비트로 줄인 버전 대비 4비트가 얼마나 손해인가"를 묻는, 더 까다로운 비교입니다.

| 벤치마크 | baseline (FP8) | NVFP4 |
|---|---|---|
| GPQA Diamond | 89.52 | 89.39 |
| SciCode | 49.85 | 49.04 |
| IFBench | 74.95 | 75.81 |
| AA-LCR | 69.38 | 70.13 |
| τ²-Bench Telecom | 97.9 | 98.25 |

측정 조건은 temperature 1.0, top_p 0.95이며, GPQA Diamond는 max_new_tokens 100000, 나머지는 64000을 사용했습니다. AA-LCR은 SGLang으로, 나머지는 vLLM으로 측정되었습니다. 다섯 개 벤치마크는 각각 대학원 수준 과학 추론(GPQA Diamond, 448문항), 과학 코딩(SciCode), 지시 따르기(IFBench), 긴 컨텍스트 회상(AA-LCR), 에이전트 도구 사용(τ²-Bench Telecom)을 평가합니다.

결과를 보면 GPQA(−0.13)와 SciCode(−0.81)에서는 소폭 하락했지만, IFBench(+0.86), AA-LCR(+0.75), τ²-Bench Telecom(+0.35)에서는 오히려 NVFP4가 더 높습니다. 4비트가 8비트를 이기는 것이 직관에 어긋나 보일 수 있지만, 이 정도 차이는 양자화 손실이라기보다 샘플링 분산 범위 안의 잡음으로 보는 편이 안전합니다. 핵심 메시지는 "FP8을 4비트로 한 번 더 줄여도 정확도가 사실상 평평하게 유지된다"는 것이며, 이는 앞서 설명한 선택적 양자화 전략의 직접적인 결과입니다.

## 배포: vLLM과 SGLang

![Runtime vLLM/SGLang, 8-way 텐서 병렬, Blackwell 8-GPU 노드로 구성되는 배포 스택](/assets/images/nvidia-glm-5-2-nvfp4-slide-06.png)
*런타임·텐서 병렬·하드웨어 요구를 한 화면에 정리한 배포 스택입니다.*

이 체크포인트는 SGLang과 vLLM 두 런타임을 공식 지원하며, 하드웨어는 NVIDIA Blackwell, 운영체제는 Linux를 요구합니다. NVFP4 텐서 코어가 Blackwell 세대에만 존재하기 때문에, 이전 세대 GPU에서는 이 4비트 경로를 그대로 활용할 수 없다는 점이 중요한 제약입니다. 모델카드가 제시하는 SGLang 서빙 명령은 다음과 같습니다.

```sh
pip install -U "transformers>=5.3.0" && \
python3 -m sglang.launch_server \
    --model nvidia/GLM-5.2-NVFP4 \
    --tensor-parallel-size 8 \
    --quantization modelopt_fp4 \
    --tool-call-parser glm47 \
    --reasoning-parser glm45 \
    --trust-remote-code \
    --chunked-prefill-size 131072 \
    --mem-fraction-static 0.80
```

여기서 읽어야 할 신호가 몇 가지 있습니다. `--tensor-parallel-size 8`은 이 모델이 단일 GPU가 아니라 8장으로 구성된 노드를 전제로 한다는 뜻입니다. `--quantization modelopt_fp4`는 런타임이 ModelOpt가 생성한 NVFP4 형식을 인식하도록 지정합니다. `--chunked-prefill-size 131072`는 1M 컨텍스트를 처리할 때 프리필을 잘라 메모리 급증을 막는 설정이며, 긴 컨텍스트 서빙에서 안정성을 좌우하는 값입니다. `--tool-call-parser glm47`과 `--reasoning-parser glm45`는 GLM 계열의 도구 호출과 추론 토큰 형식을 파싱하기 위한 옵션으로, 에이전트 워크로드에 그대로 연결됩니다.

메모리 측면을 거칠게 따져보면, 753B를 BF16으로 올릴 경우 약 1.5TB가 필요합니다[추정]. 라우팅 전문가가 파라미터 대부분을 차지하고 이를 4비트로 줄이므로, 실제 가중치 메모리는 대략 3분의 1 수준으로 내려가 8-way 텐서 병렬 단일 노드에 적재할 수 있는 범위로 들어옵니다(커뮤니티 NVFP4 미러 배포본은 약 1.37TB→459GB, 약 3배 수준으로 보고합니다 [추정]). 모델카드가 양자화 전후의 정확한 GB 수치를 명시하지는 않으므로 이 메모리 값에는 `[추정]` 표시를 남깁니다. 분명한 사실은 `--tensor-parallel-size 8`이라는 명령 자체가 "Blackwell 8장이면 1M 컨텍스트의 753B 추론 모델을 서빙할 수 있다"는 것을 가리킨다는 점입니다.

## ThakiCloud 제품 적용 시사점

![멀티테넌트 SaaS 플랫폼에서의 전략적 가치: 데이터 주권, 엔지니어링 오버헤드 소거, 도입 표준](/assets/images/nvidia-glm-5-2-nvfp4-slide-07.png)
*멀티테넌트 SaaS 운영 관점에서 이 체크포인트가 갖는 전략적 가치입니다.*

ThakiCloud ai-platform은 Kueue로 GPU를 스케줄링하고 vLLM으로 모델을 서빙하는 K8s 멀티테넌트 플랫폼입니다. 이 환경에서 `nvidia/GLM-5.2-NVFP4`는 서빙 후보의 폭을 실질적으로 넓힙니다. 753B 파라미터가 4비트로 내려와 단일 Blackwell 8-GPU 노드에 들어오면, Kueue ResourceFlavor로 해당 노드 풀을 NVFP4 전용으로 분리할 수 있고, 양자화로 확보한 GPU 메모리 여유는 곧 동시 처리 테넌트 수 증가로 이어집니다. 데이터를 외부 API로 내보낼 수 없는 공공·금융 고객에게 온프렘에서 프런티어 추론을 제공하는 것은 그 자체로 플랫폼 차별점입니다. NVIDIA가 ModelOpt로 직접 검증한 체크포인트를 그대로 쓸 수 있으므로, 내부 팀은 753B 양자화 파이프라인 대신 멀티테넌트 라우팅과 비용 관측에 집중할 수 있습니다. GLM-5.2에 적용된 "라우팅 전문가 4비트, 공유 전문가와 어텐션 BF16" 레시피는 사내 MoE 양자화 기준으로도 바로 활용할 수 있습니다.

Paxis는 ai-platform 위에서 동작하는 에이전트 제어 평면입니다. 960개 이상의 스킬을 갖춘 Skill Harness, 샌드박스 격리 실행, DAG 멀티에이전트, MCP 커넥터, 정책 게이트와 감사 로그가 핵심 구성 요소입니다. Paxis는 models.yaml 하나를 단일 출처(SSOT)로 삼아 LLM을 교체하는 구조여서, GLM-5.2-NVFP4 엔드포인트가 ai-platform에 올라오면 코드 수정 없이 해당 엔드포인트로 라우팅이 가능합니다. 온프렘에 저비용 프런티어 엔드포인트가 확보될수록 Paxis 에이전트가 외부 유료 API 대신 이 엔드포인트에서 동작하게 되어, 스킬 실행당 단위 경제성이 개선됩니다. ai-platform이 더 많은 추론 용량을 더 낮은 비용으로 공급할수록, Paxis 에이전트의 운영 범위도 함께 넓어집니다.

## 한계 및 반론

가장 큰 한계는 **하드웨어 종속성**입니다. NVFP4 4비트 경로는 Blackwell 텐서 코어를 전제로 하므로, Hopper(H100/H200) 등 이전 세대만 보유한 환경에서는 이 체크포인트의 이점을 그대로 살릴 수 없습니다. "4비트라서 싸다"는 서사는 Blackwell 노드를 이미 확보했거나 확보할 계획이 있을 때에만 성립하며, 오히려 새 자본 지출을 전제로 합니다.

둘째, **벤치마크의 범위**입니다. 모델카드의 정확도 표는 다섯 개 벤치마크에 한정되며, 모두 영어권 추론·코딩·에이전트 과제에 가깝습니다. 한국어를 포함한 다국어 실사용 품질, 그리고 1M 컨텍스트를 끝까지 채웠을 때의 회상 안정성은 공개 표만으로는 단정하기 어렵습니다. 도입 전 우리 도메인 데이터로 BF16/FP8 대비 회귀를 측정하는 별도 평가가 반드시 필요합니다.

셋째, **메모리 수치의 불확실성**입니다. 앞서 적었듯 모델카드는 양자화 전후의 정확한 메모리 GB를 공개하지 않습니다. 이 글의 메모리 추정은 파라미터 수와 양자화 범위에서 역산한 값이므로, 실제 배포 시 KV 캐시와 1M 프리필 버퍼까지 더하면 노드당 실효 메모리는 가중치만의 추정치보다 큽니다. 운영 계획은 가중치 메모리가 아니라 피크 메모리를 기준으로 잡아야 합니다.

넷째, **선택적 양자화의 양면성**입니다. 공유 전문가와 어텐션을 BF16으로 남긴 덕분에 정확도는 지켜졌지만, 그만큼 메모리 절감 폭은 "전부 4비트"보다 작습니다. 즉 이 모델은 "최대 압축"이 아니라 "정확도를 지키는 선에서의 압축"을 택한 것이며, 한 장의 워크스테이션 GPU에 올리려는 극단적 비용 환경이라면 NVFP4가 아니라 더 공격적인 1비트 GGUF 같은 절충이 더 맞습니다(품질은 더 떨어집니다).

정리하면, `nvidia/GLM-5.2-NVFP4`는 프런티어급 753B MoE 추론 모델을 정확도 손실 없이 4비트로 끌어내려, Blackwell 8-GPU 노드에서의 자체 서빙을 현실적 선택지로 만든 사례입니다. ThakiCloud 관점에서는 온프레미스·데이터 주권 요구가 있는 고객에게 프런티어 추론을 제공할 카드가 한 장 늘어난 것이며, 동시에 "선택적 양자화"라는 일반 원칙을 우리 모델 도입 기준에 반영할 계기가 됩니다. 다만 그 문은 Blackwell이라는 열쇠가 있어야 열립니다.

## 출처 (Sources)

- [nvidia/GLM-5.2-NVFP4 · Hugging Face](https://huggingface.co/nvidia/GLM-5.2-NVFP4)
- [베이스 모델 GLM-5.2 (ZAI) · Hugging Face](https://huggingface.co/zai-org/GLM-5.2)
- [NVIDIA Model Optimizer · GitHub](https://github.com/NVIDIA/Model-Optimizer)
- [Introducing NVFP4 for Efficient and Accurate Low-Precision Inference · NVIDIA Technical Blog](https://developer.nvidia.com/blog/introducing-nvfp4-for-efficient-and-accurate-low-precision-inference/)
