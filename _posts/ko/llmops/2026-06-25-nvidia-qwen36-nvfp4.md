---
title: "NVFP4로 35B MoE를 4비트에 담기: Qwen3.6-35B-A3B-NVFP4 서빙 노트"
excerpt: "NVIDIA가 Alibaba의 Qwen3.6-35B-A3B를 NVFP4(4비트)로 양자화해 공개했습니다. GPU 메모리를 약 3.06배 줄이면서도 BF16 대비 정확도 손실은 대부분 1점 미만입니다. vLLM 배포 명령과 ThakiCloud의 직접 재현 결과, 그리고 온프레미스 서빙 관점의 한계를 함께 정리합니다."
seo_title: "Qwen3.6-35B-A3B-NVFP4 4비트 양자화 vLLM 서빙 - Thaki Cloud"
seo_description: "NVFP4 4비트 양자화로 35B MoE 모델의 GPU 메모리를 약 3.06배 줄이는 nvidia/Qwen3.6-35B-A3B-NVFP4를, vLLM 배포 명령과 ThakiCloud의 RunPod 재현 결과, Blackwell/Hopper 하드웨어 전제 관점에서 분석합니다."
date: 2026-06-25
last_modified_at: 2026-06-25
tags:
  - nvfp4
  - quantization
  - vllm
  - qwen3
  - moe
  - inference-optimization
  - model-optimizer
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "microchip"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ko/llmops/nvidia-qwen36-nvfp4/"
reading_time: true
categories:
  - llmops
audiobook: /assets/audio/posts/nvidia-qwen36-nvfp4/audiobook-ko.mp3
audiobook_note: "AI 로컬 합성 오디오북 (Qwen3-TTS)"
---

이 글은 Blackwell이나 Hopper GPU로 대형 언어 모델을 자체 인프라에서 서빙하려는 팀을 위한 것입니다. 핵심 한 줄은, NVIDIA가 공개한 `nvidia/Qwen3.6-35B-A3B-NVFP4`가 35B 규모의 MoE 모델을 4비트로 눌러 GPU 메모리를 약 3.06배 줄이면서도 정확도 손실을 대부분 1점 미만으로 막아 준다는 것입니다.

## 무엇을 4비트로 줄였나

이 모델은 Alibaba의 `Qwen/Qwen3.6-35B-A3B`를 NVIDIA Model Optimizer(ModelOpt)로 양자화한 버전입니다. 베이스 모델은 총 35B 파라미터 중 3B만 활성화되는 Mixture-of-Experts 구조이고, 최대 262K 컨텍스트를 지원하며, 라이선스는 Apache-2.0으로 상업 사용이 자유롭습니다. NVIDIA는 이것이 자사가 처음부터 만든 모델이 아니라 제3자 모델의 양자화본임을 모델카드에 분명히 밝히고 있습니다.

성능의 두 축은 서로 다른 일을 합니다. MoE는 속도를 담당해, 토큰 하나를 생성할 때 35B 전체가 아니라 3B의 활성 전문가만 계산에 참여하므로 연산량이 작은 밀집 모델에 가깝습니다. NVFP4는 메모리를 담당하는데, NVIDIA가 정의한 4비트 부동소수점 포맷으로 모든 값을 무차별하게 깎지 않고 MoE 트랜스포머 블록 안 선형 연산자의 가중치와 활성값에만 양자화를 적용합니다. 어텐션처럼 민감한 경로는 건드리지 않고 메모리를 가장 많이 차지하는 부분에 집중하기 때문에, 파라미터당 비트 수가 16에서 4로 줄어 디스크와 GPU 메모리 요구가 약 3.06배 감소하면서도 품질 저하는 작게 억제됩니다.

여기에는 하드웨어 전제가 하나 붙습니다. NVFP4 연산은 NVIDIA Hopper와 Blackwell 마이크로아키텍처에서만 가속되며, 모델카드의 테스트 하드웨어는 GB300으로 기재되어 있습니다. 이 전제는 뒤에서 다시 한계로 다루겠습니다.

## vLLM으로 띄우기

NVIDIA가 제시하는 기본 서빙 명령은 짧습니다. `vllm/vllm-openai:nightly` 이미지를 띄운 뒤 실행합니다.

```sh
vllm serve nvidia/Qwen3.6-35B-A3B-NVFP4 \
  --port 8000 \
  --quantization modelopt \
  --max-model-len 262144 \
  --reasoning-parser qwen3
```

`--quantization modelopt` 플래그가 NVFP4 체크포인트를 인식하게 하는 핵심입니다. GPU 메모리가 빠듯하면 `--max-model-len`을 먼저 낮췄다가 점진적으로 올리는 편이 안전한데, 262K 컨텍스트를 유지하려면 KV 캐시가 상당한 메모리를 요구하기 때문입니다. NVIDIA DGX Spark처럼 메모리가 제한된 환경을 위해서는 별도의 확장 명령도 제공됩니다.

```sh
vllm serve nvidia/Qwen3.6-35B-A3B-NVFP4 \
  --host 0.0.0.0 --port 8000 \
  --tensor-parallel-size 1 --trust-remote-code \
  --kv-cache-dtype fp8 --attention-backend flashinfer \
  --moe-backend marlin --gpu-memory-utilization 0.4 \
  --max-model-len 262144 --max-num-seqs 4 \
  --max-num-batched-tokens 8192 --enable-chunked-prefill \
  --async-scheduling --enable-prefix-caching \
  --speculative-config '{"method":"mtp","num_speculative_tokens":3,"moe_backend":"triton"}' \
  --load-format fastsafetensors \
  --reasoning-parser qwen3 --tool-call-parser qwen3_xml \
  --enable-auto-tool-choice
```

이 확장 명령은 `--kv-cache-dtype fp8`로 KV 캐시까지 8비트로 낮추고, `--gpu-memory-utilization 0.4`로 점유를 억제하며, MTP(Multi-Token Prediction) 기반 추측 디코딩과 도구 호출 파싱까지 켭니다. NVIDIA가 명시한 용도 자체가 AI 에이전트 시스템, 챗봇, RAG에 바로 붙일 사전 양자화 모델이므로, 옵션 구성이 그 시나리오를 그대로 반영합니다.

## 정확도는 얼마나 지켜지나

아래 표는 NVIDIA가 모델카드에 공개한 공식 평가로, 베이스 모델(BF16)을 기준으로 NVFP4 버전을 비교한 것입니다.

| 벤치마크 | BF16 (기준) | NVFP4 | Δ |
|---|---|---|---|
| MMLU Pro | 85.6 | 85.0 | -0.6 |
| GPQA Diamond | 84.9 | 84.8 | -0.1 |
| τ²-Bench Telecom | 95.5 | 94.7 | -0.8 |
| SciCode | 40.8 | 40.6 | -0.2 |
| AIME 2025 | 89.2 | 88.8 | -0.4 |
| AA-LCR | 62.0 | 62.0 | 0.0 |
| IFBench | 62.3 | 62.8 | +0.5 |
| MMMU PRO | 74.1 | 74.5 | +0.4 |

![BF16 대비 NVFP4 정확도 비교 막대 그래프]({{ '/assets/images/nvidia-qwen36-nvfp4-results.webp' | relative_url }})

8개 벤치마크 중 손실이 가장 큰 것이 τ²-Bench Telecom의 0.8점이고, GPQA Diamond는 0.1점, AA-LCR은 동률입니다. IFBench와 MMMU PRO는 오히려 NVFP4가 BF16을 소폭 앞서는데, 이는 양자화가 성능을 올린다는 뜻이 아니라 미세한 분포 변화가 일부 태스크에서 우연히 유리하게 작용한 것으로 읽어야 합니다. 요컨대 가중치를 4분의 1로 줄였는데도 추론, 수학, 코딩, 도구 사용 능력이 사실상 보존됩니다. 평가 조건은 SciCode가 temperature 0.6, top_p 0.95, 최대 131072 토큰이며 나머지는 temperature 1.0에 동일한 top_p와 토큰 상한을 씁니다. 메모리 쪽에서는 패킹된 체크포인트가 약 18.7B 규모로 집계되어 35B BF16 대비 크게 줄어드는데, 정확한 파일 크기는 저장소 사이드바를 확인해야 하며 이를 베이스 모델의 아키텍처 파라미터와 혼동하지 말라고 모델카드가 경고합니다.

## ThakiCloud가 직접 돌려 본 결과

수치를 옮기는 데 그치지 않고, 같은 베이스 모델을 RunPod의 NVIDIA H100 NVL 2장(Hopper, 합산 191GB) 위에서 직접 NVFP4로 양자화해 보았습니다. 보정 연산은 BF16에서 수행되므로 양자화 패스 자체는 Hopper에서도 그대로 재현됩니다. `nvidia-modelopt[hf]` 0.44.0으로 34.66B 파라미터 모델을 두 장에 자동 분산해 올린 뒤 `NVFP4_DEFAULT_CFG`로 8샘플 스모크 보정을 돌렸습니다. 의미가 있던 지점은, 2026년 5월 말 공개된 신규 아키텍처(내부명 `qwen3_5_moe`, Gated DeltaNet 계열)를 modelopt 0.44가 자동 인식했다는 것입니다. fused MoE 전문가 블록은 `_QuantFusedExperts`로, 어텐션 KV 캐시는 `_QuantAttention`으로 등록되었고 총 21,743개의 양자화기가 삽입되었으며, PTQ는 148초에 끝났습니다.

다만 정직하게 밝힐 부분이 있습니다. 양자화 패스는 통과했지만 4비트 체크포인트를 디스크로 내보내는 `export_hf_checkpoint` 단계가 modelopt 0.44와 transformers 5.x의 호환성 공백에 막혔습니다(`transformers>=5.0 support is experimental`). `qwen3_5_moe`가 요구하는 transformers 5.x 조합에서 통합 HF export가 아직 동작하지 않아 BF16로 폴백되었으며, 출시 한 달이 안 된 아키텍처에서 흔한 도구 체인 지연입니다. 따라서 패킹 크기와 정확도 수치는 위의 NVIDIA 공개본을 근거로 인용합니다.

이 파이프라인은 처음이 아닙니다. 같은 계열인 `Qwen/Qwen3-30B-A3B`를 RunPod B200(Blackwell SM100)에서 NVFP4(W4A4, group_size 16)로 양자화한 2026년 5월 1일 검증에서는 17.1GB 체크포인트를 137초의 PTQ로 생성했고, 전체 소요 약 25분에 비용은 B200 온디맨드 기준 약 3.48달러였습니다. 두 실행이 말해 주듯 NVFP4 양자화는 짧은 시간과 낮은 비용으로 끝나는 일회성 작업이며, NVIDIA처럼 사전 양자화본이 공개되면 그 작업조차 건너뛰고 바로 서빙으로 진입할 수 있습니다.

## 온프레미스 서빙 관점의 이득과 한계

멀티테넌트 환경에서 GPU는 가장 비싼 공유 자원이고, 메모리를 약 3.06배 줄인다는 것은 동일 GPU에 더 큰 모델이나 더 많은 동시 세션을 수용할 여지가 생긴다는 뜻입니다. 여기에 3B 수준 연산량의 MoE 특성이 겹치면 고품질 모델을 낮은 서빙 비용으로 제공한다는 온프레미스 가치 제안이 구체화됩니다. K8s 위에서는 GPU 워크로드를 Kueue로 큐잉하고 서빙은 vLLM 파드로 띄우되 `--quantization modelopt`로 체크포인트를 인식시키며, 절감된 메모리만큼 테넌트당 할당을 조정합니다.

그럼에도 네 가지 유보가 필요합니다. 첫째, 하드웨어 종속이 강합니다. NVFP4 Tensor Core는 Blackwell과 Hopper에만 있어 A100이나 V100에서는 가속되지 않으므로, 기존 자산이 이전 세대라면 노드 교체 비용을 감수하거나 INT8, FP8 같은 다른 경로를 택해야 합니다. 둘째, 메모리 절감과 처리량 향상은 별개입니다. 모델카드는 3.06배 메모리 절감만 명시할 뿐 처리량은 제시하지 않으며, 실제 처리량은 배치 크기와 컨텍스트 길이, KV 캐시 설정에 따라 달라집니다. 이번 재현도 B200 재고를 확보하지 못해 Hopper에서 양자화만 검증했고, native FP4 서빙 처리량은 별도 벤치마크로 남겨 두었습니다. 셋째, 양자화는 베이스 모델의 한계를 그대로 물려받습니다. 편향이나 부정확한 답변을 양자화가 해결하지는 않으므로 출력 필터링과 모니터링은 여전히 별도로 필요합니다. 넷째, 정확도 손실이 0은 아닙니다. τ²-Bench Telecom의 0.8점처럼 도구 사용과 정책 준수가 핵심인 시나리오에서는 상대적으로 큰 손실이 관찰되므로, 금융이나 의료처럼 작은 차이가 비용으로 직결되는 도메인에서는 BF16, FP8, NVFP4 중 무엇을 쓸지 테넌트별로 따지는 정책이 필요합니다.

정리하면, `nvidia/Qwen3.6-35B-A3B-NVFP4`는 Blackwell이나 Hopper 기반 인프라를 가진 팀에게 거의 손실 없이 메모리를 4분의 1로 줄이는 실용적 선택지입니다. 그 이점은 하드웨어 전제와 도메인별 정확도 검증 위에서만 성립하며, ThakiCloud는 자체 서빙 벤치마크로 처리량과 테넌트별 적합성을 확인한 뒤 노드 풀 정책에 반영할 계획입니다.


## 관련 슬라이드

본문 내용을 NotebookLM(`blue_collage` 스타일)으로 요약한 슬라이드입니다.

![nvidia-qwen36-nvfp4 슬라이드 1](/assets/images/nvidia-qwen36-nvfp4-slide-01.webp)

![nvidia-qwen36-nvfp4 슬라이드 2](/assets/images/nvidia-qwen36-nvfp4-slide-02.webp)

![nvidia-qwen36-nvfp4 슬라이드 3](/assets/images/nvidia-qwen36-nvfp4-slide-03.webp)

![nvidia-qwen36-nvfp4 슬라이드 4](/assets/images/nvidia-qwen36-nvfp4-slide-04.webp)

## 출처 (Sources)

- 모델카드: [nvidia/Qwen3.6-35B-A3B-NVFP4 · Hugging Face](https://huggingface.co/nvidia/Qwen3.6-35B-A3B-NVFP4)
- 베이스 모델: [Qwen/Qwen3.6-35B-A3B · Hugging Face](https://huggingface.co/Qwen/Qwen3.6-35B-A3B)
- 양자화 도구: [NVIDIA Model Optimizer (GitHub)](https://github.com/NVIDIA/Model-Optimizer)
- 추론 엔진: [vLLM (GitHub)](https://github.com/vllm-project/vllm)
