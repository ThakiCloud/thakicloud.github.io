---
title: "VAE를 버린 통합 멀티모달: SenseNova U1과 NEO-Unify, 그리고 온프렘 서빙"
excerpt: "상탕(SenseTime)이 日日新 SenseNova U1을 Apache 2.0으로 공개했습니다. 비주얼 인코더와 VAE를 모두 없앤 NEO-Unify 아키텍처로 이해·생성·편집·인터리브를 한 모델에서 처리합니다. 오픈 가중치(8B-MoT/A3B-MoT)와 호스티드 U1 Pro의 차이, 벤치마크상 위치, transformers·vLLM-Omni·ComfyUI 서빙 경로, 그리고 A1111에는 왜 못 올리는지까지 온프렘 관점으로 정리합니다."
seo_title: "SenseNova U1 NEO-Unify 통합 멀티모달 - 오픈웨이트와 온프렘 서빙 - Thaki Cloud"
seo_description: "SenseNova U1(NEO-Unify, VAE 제거, 8B-MoT/A3B-MoT MoE, Apache 2.0)을 팩트 기반으로 정리. U1 Pro와 오픈 가중치 구분, 벤치마크, transformers·vLLM-Omni·GGUF 서빙, ComfyUI 지원과 A1111 비호환, ThakiCloud K8s 온프렘 서빙 관점."
date: 2026-07-19
last_modified_at: 2026-07-19
tags:
  - sensenova-u1
  - sensetime
  - neo-unify
  - unified-multimodal
  - text-to-image
  - mixture-of-transformers
  - open-weight
  - vllm
  - comfyui
  - on-premise
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ko/owm/sensenova-u1-neo-unify-unified-multimodal/"
reading_time: true
categories:
  - owm
---

⏱️ **예상 읽기 시간**: 15분

![SenseNova U1 NEO-Unify 통합 멀티모달 개념 비주얼]({{ '/assets/images/sensenova-u1-neo-unify-unified-multimodal-hero.webp' | relative_url }})

## 개요

이미지 생성 모델은 오랫동안 두 갈래로 갈라져 있었습니다. 한쪽에는 텍스트를 이해하는 언어 모델이 있고, 다른 한쪽에는 픽셀을 그리는 확산(diffusion) 모델이 있었습니다. Stable Diffusion 계열이 대표적입니다. 텍스트 인코더가 프롬프트를 해석하고, UNet 또는 DiT가 잠재 공간에서 노이즈를 걷어내고, VAE(변분 오토인코더)가 그 잠재값을 다시 픽셀로 복원합니다. 이해와 생성이 서로 다른 모듈에서 서로 다른 표현으로 일어나는 구조입니다.

상탕(SenseTime)이 2026년 4월부터 순차 공개한 日日新 SenseNova U1은 이 분리를 정면으로 부정합니다. 비주얼 인코더와 VAE를 모두 없애고, 언어와 시각 정보를 하나의 표현 공간에서 끝까지 다루는 NEO-Unify 아키텍처를 내세웁니다. 이해, 생성, 편집, 그리고 텍스트와 이미지를 번갈아 쏟아내는 인터리브 생성까지 단일 모델 안에서 처리합니다. 가중치는 Apache 2.0으로 풀렸고, 8B급이라 RTX 5090 한 장이면 돌아갑니다. 상업적 자체 호스팅이 허용된다는 뜻입니다.

이 글은 SenseNova U1이 무엇인지 팩트로 정리하고, 우리가 온프렘에서 실제로 무엇을 얹을 수 있는지, 그리고 흔히 기대하는 Automatic1111 같은 기존 도구에 왜 그대로 올릴 수 없는지까지 솔직하게 리뷰합니다. ThakiCloud는 다양한 고객 환경에서 모델을 서빙하는 것을 업으로 삼기 때문에, "오픈 가중치가 나왔다"는 헤드라인과 "우리 클러스터에 올릴 수 있다"는 현실 사이의 간격을 짚는 것이 핵심입니다.

## SenseNova U1은 무엇인가: VAE를 버린다는 것의 의미

NEO-Unify의 출발점은 단순한 관찰입니다. 픽셀과 단어는 본래 깊게 얽혀 있는데, 기존 파이프라인은 이를 억지로 분리해 왔다는 것입니다. 그래서 U1은 두 개의 중간 변환기를 통째로 제거합니다. 이미지를 특징으로 압축하던 비주얼 인코더(VE)도 없고, 잠재값을 픽셀로 되돌리던 VAE도 없습니다. 대신 언어와 시각 정보를 하나의 복합 표현으로 엮어 끝에서 끝까지 모델링합니다. 상탕은 이를 네이티브 MoT(Mixture-of-Transformers) 위에서 돌려, 모달리티 간 추론을 충돌 없이 효율적으로 수행한다고 설명합니다.

이 차이는 사용자 입장에서 "한 모델이 다 한다"로 드러납니다. 이미지를 이해하고(VQA), 이미지를 생성하고, 이미지를 편집하고, 텍스트와 이미지를 한 흐름 안에서 번갈아 만들어 냅니다. 요리 튜토리얼이나 여행 일기처럼 설명과 삽화가 교차하는 콘텐츠를 한 번의 생성으로 뽑을 수 있다는 것이 대표 사례로 제시됩니다. 공간 지능(spatial intelligence) 쪽에서도 복잡한 레이아웃과 물체 간 관계를 이해한다고 강조하는데, 이는 향후 로봇이 인식·추론·실행을 한 모델에서 완결하는 임베디드 AI로 이어지는 포석입니다.

아래는 기존 SD 계열 파이프라인과 U1의 통합 파이프라인을 나란히 놓은 개념도입니다.

```mermaid
flowchart TB
    subgraph SD["기존 SD 계열 (분리형)"]
        direction TB
        A1["텍스트 프롬프트"] --> A2["텍스트 인코더 (CLIP)"]
        A2 --> A3["UNet / DiT (잠재 확산)"]
        A3 --> A4["VAE 디코더"]
        A4 --> A5["픽셀 이미지"]
    end
    subgraph U1["SenseNova U1 (NEO-Unify 통합형)"]
        direction TB
        B1["텍스트 · 이미지 입력"] --> B2["단일 통합 표현 공간<br/>(VE 없음 · VAE 없음)"]
        B2 --> B3["네이티브 MoT 트랜스포머<br/>이해 · 생성 · 편집 공유"]
        B3 --> B4["텍스트 · 이미지 · 인터리브 출력"]
    end
    SD -.->|"모듈 3개, 표현 2종"| GAP["분리의 비용:<br/>이해와 생성이 다른 표현"]
    U1 -.->|"모듈 1개, 표현 1종"| WIN["통합의 이득:<br/>픽셀-단어 상관 보존"]
```

핵심은 U1이 확산 체크포인트가 아니라, LLM처럼 동작하는 통합 트랜스포머라는 점입니다. 이 사실 하나가 뒤에 나올 서빙 방식과 도구 호환성을 전부 결정합니다.

## 오픈된 것은 U1 Pro가 아니라 U1 Lite 시리즈입니다

여기서 반드시 짚어야 할 구분이 있습니다. 상탕 플랫폼 페이지(`sensenova.cn`)의 **U1 Pro**는 호스티드 상용 플래그십입니다. 고밀도 인포그래픽과 포스터 생성 데모가 인상적이지만, 이 "Pro" 등급 가중치는 HuggingFace에 올라와 있지 않습니다. API로만 접근하는 상용 티어로 보는 것이 맞습니다.

자체 호스팅이 가능한 것은 **U1 Lite 시리즈**입니다. 오픈된 주요 가중치는 다음과 같습니다.

| 모델 | 파라미터 | 성격 |
|---|---|---|
| SenseNova-U1-8B-MoT | 8B (dense MoT) | 플래그십 오픈 백본. 범용 멀티모달 |
| SenseNova-U1-A3B-MoT | A3B (MoE, ~3B 활성) | 경량 MoE 백본 |
| SenseNova-U1-8B-MoT-SFT / A3B-SFT | 8B / A3B | SFT 단계 가중치(×32 다운샘플링) |
| SenseNova-U1-8B-MoT-Infographic (V1/V2/V3) | 8B | 인포그래픽 특화, V3는 7/15 갱신 |
| SenseNova-U1-8B-MoT-Interleaved | 8B | 인터리브 생성 특화 |
| SenseNova-U1-8B-MoT-LoRA-8step | 0.4B | 8스텝 고속 생성 LoRA |

SFT 모델은 이해 웜업 → 생성 사전학습 → 통합 중간학습 → 통합 SFT를 거치고, 최종 모델은 여기에 T2I 강화학습을 한 번 더 얹어 얻습니다. 상탕은 오늘 공개한 것은 "Lite"이며 더 큰 규모의 버전을 예고했습니다. 즉 지금 손에 쥔 8B/A3B는 비교적 컴팩트한 버전이고, 상한은 아직 열려 있습니다.

정리하면, 블로그나 데모에서 "U1 Pro를 띄웠다"고 말하면 부정확합니다. 우리가 온프렘에 올리는 대상은 오픈된 **U1-8B-MoT**(또는 A3B)입니다.

## 벤치마크상 위치

상탕은 U1을 "오픈소스 진영에서 이해와 생성 양쪽 모두 SoTA"라고 주장합니다. 평가는 OneIG(EN/ZH), LongText(EN/ZH), BizGenEval(Easy/Hard), CVTG, IGenBench, 그리고 인포그래픽 벤치마크 위에서 이뤄졌습니다. 모델카드는 성능 대 생성 지연(latency) 트레이드오프 그래프를 강조하는데, 같은 품질을 더 빠르게 뽑는 쪽에 방점이 있습니다.

숫자를 그대로 인용하기보다 성격을 봐야 합니다. U1 Lite는 특히 복잡한 인포그래픽 생성, 즉 레이아웃 일관성과 텍스트 렌더링 정확도가 중요한 영역에서 상용급 결과를 낸다고 소개됩니다. 일부 매체는 U1 Lite의 출력 품질이 Qwen-Image 2.0 Pro나 Seedream 4.5에 견줄 만하다고 전하지만, 이는 벤더·2차 출처 기준이므로 [추정]으로 두고 실측으로 검증할 대상입니다. 우리 기준은 하나입니다. 우리 데이터와 우리 프롬프트로 우리 GPU에서 돌려 본 수치만 신뢰합니다.

## 설치와 서빙: 두 갈래 경로

U1이 확산 체크포인트가 아니라 통합 트랜스포머라는 사실은 서빙에서 그대로 드러납니다. 확산 UI에 얹는 게 아니라, LLM처럼 서빙합니다.

**경로 1: transformers 네이티브.** 공식 리포는 uv로 의존성을 깔고 태스크별 예제 스크립트를 제공합니다. 텍스트-투-이미지, 이미지 편집, 인터리브 생성이 각각 있습니다.

```bash
# 이미지 편집 예시 (VAE가 없어도 픽셀 단위 편집이 됩니다)
python examples/editing/inference.py \
  --model_path sensenova/SenseNova-U1-8B-MoT \
  --prompt "Change the animal's fur color to a darker shade." \
  --image examples/editing/data/images/1.webp \
  --cfg_scale 4.0 --img_cfg_scale 1.0 --num_steps 50 \
  --output output_edited.png --profile --compare

# 인터리브 생성 (설명 + 삽화를 한 흐름으로)
python examples/interleave/inference.py \
  --model_path sensenova/SenseNova-U1-8B-MoT \
  --prompt "토마토 계란 볶음 초보자용 삽화 튜토리얼을 만들어줘." \
  --resolution "16:9" --output_dir outputs/interleave/ --stem demo
```

**경로 2: vLLM-Omni 서빙.** 데모나 제품에 붙이려면 OpenAI 호환 엔드포인트가 필요합니다. vLLM-Omni가 U1을 공식 지원하며, 오프라인 추론과 온라인 서빙 예제를 모두 제공합니다. VRAM이 빠듯한 환경을 위해 모듈 단위 CPU 오프로드도 있습니다. 파이프라인이 컴포넌트 디스커버리를 구현해, 텍스트·비전 인코딩 단계에서는 LLM을 CPU로 내리고 확산 루프에서는 비전 인코더를 CPU로 내리는 식으로 GPU에 상주하는 가중치를 최소화합니다.

```bash
# vLLM-Omni: CPU 오프로드를 켠 텍스트-투-이미지
python end2end.py \
  --prompt "A cute cat sitting on a windowsill" \
  --width 2048 --height 2048 \
  --enable-cpu-offload --think
```

**저VRAM 옵션.** 공식 리포는 단일 GPU 레이어 오프로드 모드(`--vram_mode full|low|balanced`)와 GGUF 양자화 로딩을 함께 제공합니다. Q4 GGUF와 `balanced`를 조합하면 10~12GB급 소비자 카드에서도 돌릴 수 있다고 안내합니다. 즉 배치는 세 단계로 나뉩니다. 최고 속도가 필요하면 24GB 이상에서 `full`, 여유가 없으면 GGUF + `balanced`, 극단적으로 아끼려면 `low`입니다.

## 어떤 툴과 쓰는가: ComfyUI는 되고 A1111은 안 됩니다

가장 흔한 기대가 "Stable Diffusion WebUI(Automatic1111)에 체크포인트로 올려 쓰자"입니다. 결론부터 말하면 그건 안 됩니다. A1111은 UNet/DiT + VAE + CLIP 텍스트 인코더로 이뤄진 SD 계열 체크포인트만 로드하도록 설계돼 있습니다. U1은 VAE가 없는 통합 MoT 트랜스포머이므로, `.safetensors`를 체크포인트 폴더에 넣어도 로드 자체가 성립하지 않습니다. 구조가 다르기 때문에 생기는 근본적인 비호환입니다.

인터랙티브하게 손으로 프롬프트를 넣고 뽑고 싶다면, A1111의 실질적 대체는 **ComfyUI**입니다. 커뮤니티가 만든 커스텀 노드(`smthemex/ComfyUI_SenseNova_U1`)가 U1을 네이티브로 지원하며, 8B-MoT·A3B-MoT·8스텝 LoRA·GGUF를 모두 다룹니다.

| 도구 | 지원 | 비고 |
|---|---|---|
| ComfyUI | 지원 | `smthemex/ComfyUI_SenseNova_U1` 커스텀 노드. A1111의 실질적 대체 |
| Automatic1111 | 비호환 | SD 체크포인트만 로드. VAE 없는 통합 모델은 구조적으로 불가 |
| vLLM-Omni | 지원 | OpenAI 호환 서빙. 데모·제품 백엔드에 적합 |
| transformers | 지원 | 네이티브. 태스크별 예제 스크립트 |
| diffusers + GGUF | 지원 | 저VRAM 로딩 경로 |
| Replicate | 지원 | 레퍼런스 배포(`lucataco/sensenova-u1-8b-mot`) |

요약하면 두 축입니다. 사람이 만지는 인터랙티브 UI는 ComfyUI, 프로그램이 호출하는 데모·제품 백엔드는 vLLM-Omni(OpenAI 호환)입니다. A1111을 기대했다면 도구 선택을 바꿔야 합니다.

## ThakiCloud 서빙 관점

ThakiCloud의 ai-platform은 K8s 위에서 다양한 고객 환경에 모델을 서빙하는 것을 업으로 삼습니다. SenseNova U1은 이 렌즈에서 특히 다루기 좋은 후보입니다.

첫째, 크기가 온프렘 친화적입니다. 8B급은 fp16 기준 대략 16~20GB면 상주하므로 RTX 4090, 5090, A6000 한 장으로 서빙 파드를 세울 수 있고, A3B는 더 가볍습니다. Kueue로 GPU를 큐잉하고 멀티테넌트로 나눠 쓰는 우리 방식과 잘 맞습니다. 대형 프론티어 모델처럼 8xH200을 요구하지 않으므로, 고객사 자체 GPU 한두 장으로도 실전 워크로드가 성립합니다.

둘째, vLLM-Omni의 OpenAI 호환 엔드포인트가 통합 비용을 낮춥니다. 우리 Metis 서빙 계층과 데모 파이프라인은 이미 OpenAI 호환 인터페이스를 전제로 붙기 때문에, U1을 별도 확산 스택 없이 그대로 얹을 수 있습니다. 이미지 생성 API를 텍스트 LLM과 같은 관측·비용 계량 체계 아래로 통일한다는 점이 실무적 이득입니다.

셋째, Apache 2.0과 완전한 자체 호스팅은 소버린·온프렘 요구에 정확히 부합합니다. 데이터가 외부 API로 나가지 않아야 하는 공공·금융 고객에게, 국내 GPU 위에서 도는 이미지 생성 모델은 그 자체로 경쟁력입니다. 낮은 서빙 비용에서 나오는 경쟁력도 여기서 시작됩니다.

에이전트 관점도 열립니다. ThakiCloud의 Agent-Native Cloud인 Paxis는 스킬을 격리 샌드박스에서 실행하고 모든 행동을 정책 게이트와 감사 로그로 통과시키는데, U1처럼 자체 호스팅되는 통합 이미지 모델은 에이전트가 호출하는 "이미지 생성 툴"로 등록하기에 적합합니다. 인포그래픽·포스터 생성을 외부 API 없이 사내 파드로 완결하면, 저비용 서빙(ai-platform)이 에이전트 워크플로의 경제성(Paxis)을 그대로 끌어올립니다.

## 한계와 반론

균형을 위해 반대편도 봐야 합니다. 첫째, 지금 오픈된 것은 Lite(8B/A3B)이고 최상급 품질은 호스티드 U1 Pro에 있을 가능성이 큽니다. "오픈 SoTA"라는 표현은 오픈소스 진영 안에서의 비교이지, 상용 최상위 모델과 동급이라는 보장이 아닙니다.

둘째, 통합 아키텍처의 이점은 곧 생태계의 단점이기도 합니다. U1은 SD가 아니므로 ControlNet, 방대한 커뮤니티 LoRA, 인페인팅 확장 등 수년간 축적된 A1111/SD 워크플로 자산을 그대로 물려받지 못합니다. 기존 파이프라인을 U1으로 이관하려면 도구 체계를 새로 짜야 합니다. ComfyUI 노드와 자체 LoRA 트레이너가 있지만 생태계 성숙도는 아직 초기입니다.

셋째, 벤치마크 수치는 대부분 벤더 자기보고이며, 특히 한국어 텍스트 렌더링과 프롬프트 준수는 별도 검증이 필요합니다. 인포그래픽의 강점이 한글 조판에서도 유지되는지는 우리가 직접 돌려 봐야 확인됩니다.

넷째, 저VRAM 모드는 공짜가 아닙니다. CPU 오프로드와 레이어 스트리밍은 VRAM을 아끼는 대신 CPU-GPU 전송으로 지연을 늘립니다. 실시간성이 중요한 서비스라면 오프로드 없이 24GB급에서 `full`로 돌리는 편이 낫고, 이는 곧 GPU 비용으로 돌아옵니다.

## 마무리

SenseNova U1은 "VAE를 버린 통합 멀티모달"이라는 방향을 오픈 가중치로 실증한 사례입니다. 이해와 생성을 한 표현으로 묶는 접근이 얼마나 멀리 갈지는 더 큰 버전이 나와 봐야 알겠지만, 지금의 8B/A3B만으로도 온프렘 서빙 후보로는 충분히 매력적입니다. 다음 글에서는 이 모델을 RunPod과 우리 데모 파이프라인에 실제로 얹어, vLLM-Omni 서빙과 ComfyUI 워크플로를 나란히 돌려 본 결과를 수치와 함께 정리하겠습니다.

**참고 링크**

- 모델카드: [sensenova/SenseNova-U1-8B-MoT](https://huggingface.co/sensenova/SenseNova-U1-8B-MoT)
- 코드/문서: [OpenSenseNova/SenseNova-U1 (GitHub)](https://github.com/OpenSenseNova/SenseNova-U1)
- 논문: [SenseNova-U1: Unifying Multimodal Understanding and Generation with NEO-unify (arXiv:2605.12500)](https://arxiv.org/abs/2605.12500)
- 서빙: [vLLM-Omni SenseNova-U1 예제](https://docs.vllm.ai/projects/vllm-omni/en/latest/user_guide/examples/offline_inference/sensenova_u1/)
- ComfyUI 노드: [smthemex/ComfyUI_SenseNova_U1](https://github.com/smthemex/ComfyUI_SenseNova_U1)
- 호스티드 U1 Pro: [SenseNova U1 Pro](https://www.sensenova.cn/en/u1-pro)
