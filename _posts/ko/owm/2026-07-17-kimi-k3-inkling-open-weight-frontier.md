---
title: "한 주에 프론티어 오픈웨이트 두 개: Kimi K3 2.8조와 Thinking Machines Inkling 975B"
excerpt: "2026년 7월, 오픈웨이트 진영이 같은 주에 두 발을 쐈습니다. Moonshot AI는 2.8조 파라미터로 역대 최대 오픈웨이트가 될 Kimi K3를 공개했고, 미라 무라티의 Thinking Machines Lab은 첫 오픈웨이트 모델 Inkling(975B/41B 활성)을 Apache 2.0으로 풀었습니다. 두 모델의 팩트와 아키텍처, 벤치마크상 위치를 정리하고, 온프렘 서빙 관점에서 오늘 우리가 실제로 무엇을 얹을 수 있는지 솔직하게 리뷰합니다."
seo_title: "Kimi K3 vs Thinking Machines Inkling - 오픈웨이트 프론티어 비교와 온프렘 서빙 - Thaki Cloud"
seo_description: "Kimi K3(2.8조 MoE, 100만 컨텍스트, Kimi Delta Attention, 7/27 오픈웨이트)와 Inkling(975B/41B 활성, 45조 토큰, 텍스트·이미지·오디오, Apache 2.0)을 팩트 기반으로 정리. 아키텍처, 벤치마크, NVFP4 서빙, 파인튜닝, ThakiCloud K8s 온프렘 관점."
date: 2026-07-17
last_modified_at: 2026-07-17
tags:
  - kimi-k3
  - inkling
  - thinking-machines
  - moonshot
  - open-weight
  - mixture-of-experts
  - multimodal
  - nvfp4
  - vllm
  - on-premise
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ko/owm/kimi-k3-inkling-open-weight-frontier/"
reading_time: true
categories:
  - owm
audiobook: /assets/audio/posts/kimi-k3-inkling-open-weight-frontier/audiobook-ko.mp3
audiobook_note: "AI 로컬 합성 오디오북 (Qwen3-TTS)"
---

⏱️ **예상 읽기 시간**: 14분

![Kimi K3와 Thinking Machines Inkling 오픈웨이트 비교 개념도]({{ '/assets/images/kimi-k3-inkling-open-weight-frontier-hero.webp' | relative_url }})

## 개요

2026년 7월 중순, 오픈웨이트 진영이 같은 주에 두 발을 쐈습니다. 하나는 중국 Moonshot AI가 7월 16일에 예고한 **Kimi K3**로, 총 2.8조 파라미터를 얹어 7월 27일 가중치가 공개되면 역대 최대 오픈웨이트 모델이 됩니다. 다른 하나는 미라 무라티가 이끄는 미국 Thinking Machines Lab이 7월 15일에 공개한 첫 오픈웨이트 모델 **Inkling**으로, 975B 총 파라미터에 41B만 활성화되는 MoE 구조를 Apache 2.0으로 풀었습니다.

두 사건이 하루 간격으로 겹친 건 우연이지만 방향은 서로 정반대라 오히려 비교하기 좋습니다. Kimi K3는 "가장 크게, 가장 오래 자율적으로 코딩하는" 쪽으로 밀어붙였고 Inkling은 "적당한 크기로, 기업이 자기 데이터에 맞춰 파인튜닝하기 좋게"를 겨냥했습니다. 한쪽은 규모와 에이전틱 실행력, 다른 쪽은 커스터마이즈 가능성이 무기입니다.

ThakiCloud는 Kubernetes 위에서 Kueue로 GPU 쿼터를 관리하고 vLLM으로 모델을 멀티테넌트로 서빙하는 플랫폼을 운영합니다. 그래서 새 오픈웨이트가 나올 때 우리가 던지는 질문은 늘 같습니다. "우리가 이미 가진 GPU 위에 이걸 얹을 수 있는가, 얹는다면 몇 장이 필요한가, 테넌트에게 파인튜닝까지 열어 줄 수 있는가." 이 글은 두 모델의 팩트를 정리하고 아키텍처에서 눈여겨볼 대목을 짚은 뒤, 온프렘 서빙 관점에서 오늘 당장 무엇이 현실적인지 솔직하게 따져 봅니다.

## Kimi K3: 역대 최대 오픈웨이트가 겨냥한 것

`Kimi K3`는 Moonshot AI가 공개한 초대형 MoE 모델입니다. 회사 발표와 여러 보도를 종합한 핵심 스펙은 다음과 같습니다.

| 항목 | 값 |
|---|---|
| 개발사 | Moonshot AI (알리바바 투자) |
| 총 파라미터 | 2.8조 (MoE) |
| 컨텍스트 | 100만 토큰 |
| 모달리티 | 네이티브 멀티모달 (텍스트 + 이미지) |
| 핵심 기법 | Kimi Delta Attention, Attention Residuals |
| 라이선스 | Modified MIT (가중치 2026-07-27 공개) |
| 즉시 배포 | Kimi.com, Kimi Work, Kimi Code, Kimi API |
| API 가격 | 입력 100만 토큰당 $0.30(캐시 히트)/$3(미스), 출력 $15 |

숫자로 먼저 짚을 것은 규모입니다. 2.8조 파라미터는 지금까지 공개된 오픈웨이트 중 가장 크고 7월 27일 가중치가 풀리면 그 자리를 공식화합니다. 다만 MoE이므로 매 토큰에 2.8조가 전부 도는 것은 아니며 Moonshot은 활성 파라미터 수치는 아직 공개하지 않았습니다.

아키텍처에서 주목할 두 가지는 **Kimi Delta Attention**과 **Attention Residuals**입니다. Kimi Delta Attention은 장문 컨텍스트 디코딩을 최대 6.3배까지 가속하도록 설계된 어텐션 경로로, 100만 토큰이라는 긴 창을 실용 속도로 끌고 가기 위한 장치입니다. Attention Residuals는 학습 효율을 이전 세대 K2.6 대비 약 25% 끌어올리면서도 추가 연산 비용은 2% 미만이라고 회사는 설명합니다. 큰 모델일수록 학습 비용이 급증하는데, 그 곡선을 눌러 보려는 시도로 읽힙니다.

Moonshot이 강조하는 지점은 벤치마크 점수가 아니라 **용도**입니다. Kimi K3의 1순위 시나리오는 장기 실행 자율 소프트웨어 개발입니다. 큰 코드베이스를 훑고 여러 개발 도구를 조율하며 목표를 향해 다단계 작업을 이어 가도록 만들어졌습니다. 여기에 "vision-in-the-loop"라 부르는 시각 피드백 루프가 붙습니다. 화면 캡처를 보고 코드를 고친 뒤, 결과 화면을 다시 확인해 스스로 교정하는 방식입니다. 게임 개발, UI 디자인, CAD처럼 "눈으로 확인해야 하는" 작업에 특히 쓸모가 있다는 주장입니다. 공개 데모에서는 Three.js와 WebGPU, GPU Compute로 브라우저 안에 3D 오픈월드 게임을 통째로 만들어 냈고 창정 10호 로켓의 발사와 귀환 시뮬레이션, 애니멀 크로싱풍 게임을 프롬프트 한 번으로 플레이 가능한 수준까지 뽑아내는 장면을 보여 줬습니다.

### 벤치마크상 위치는 어디인가

여기서는 과장 없이 정확히 적는 게 중요합니다. Kimi K3는 특정 영역에서 최상위 폐쇄형 모델을 앞서지만 종합 순위에서는 그 바로 아래에 위치합니다.

앞선 쪽부터 보면, 아레나의 프론트엔드 코드 부문에서 Kimi K3는 1679점으로 1위에 올라 Claude Fable 5를 제쳤습니다. 직전 세대 K2.6이 18위였던 것을 생각하면 17계단을 뛴 결과입니다. 프론트엔드 7개 세부 영역 중 6개(브랜드 마케팅, 데이터 분석, 소비자 제품 등)에서 1위를 차지했고 게이밍 영역만 Fable 5에 밀려 2위였습니다.

한편 종합 지표에서는 위치가 다릅니다. 실무 작업 평가인 GDPval-AA v2에서 Kimi K3는 1687점으로 3위였고 그 위에는 Claude Fable 5 Max와 GPT-5.6 Sol Max가 있었습니다. Moonshot 스스로도 블로그에서 일부 영역은 여전히 GPT-5.6 Sol과 Claude Fable 5에 뒤진다고 인정하면서 다만 격차가 매우 좁다고 표현했습니다. Artificial Analysis의 독립 평가에서도 인텔리전스 지수와 실무 평가 양쪽에서 최상위 독점 모델 바로 뒤에 자리잡는 것으로 나타났습니다. Moonshot이 공개한 세부 점수로는 GPQA Diamond 93.5%, BrowseComp 91.2%가 공개 시점 오픈웨이트 최고치로 인용됩니다. 다만 이 수치들은 평가 하네스와 출처가 제각각이라, 같은 벤치마크명이라도 다른 기관 수치와 직접 비교할 때는 조심할 필요가 있습니다.

정리하면, Kimi K3는 "특정 코딩·프론트엔드 워크로드에서는 최상위, 종합으로는 최상위 독점 모델 바로 아래"라고 읽는 게 정확합니다. 그리고 이 위치를 오픈웨이트가, 그것도 훨씬 낮은 API 가격으로 차지했다는 점이 업계가 "또 하나의 DeepSeek 모먼트"라고 부르는 이유입니다.

## Inkling: 미라 무라티 랩의 첫 오픈웨이트, 커스터마이즈를 겨냥하다

`Inkling`은 Thinking Machines Lab이 처음부터 새로 학습해 공개한 첫 오픈웨이트 모델입니다. 방향이 Kimi K3와 정반대라 대비가 선명합니다. 규모로 압도하는 대신, 기업이 자기 도메인에 맞춰 파인튜닝하기 좋은 "기반 모델"을 지향합니다.

| 항목 | 값 |
|---|---|
| 개발사 | Thinking Machines Lab (미라 무라티) |
| 총 / 활성 파라미터 | 975B / 41B (MoE) |
| 레이어 | 66층 디코더 온리 트랜스포머 |
| 전문가 | 라우팅 256 + 공유 2, 토큰당 라우팅 6개 활성 |
| 컨텍스트 | 최대 100만 토큰 |
| 사전학습 | 45조 토큰 (텍스트·이미지·오디오·비디오) |
| 입력 / 출력 | 텍스트·이미지·오디오 / 텍스트 |
| 라이선스 | Apache 2.0 (즉시 공개) |
| 소형 버전 | Inkling-Small 276B / 12B 활성 (프리뷰) |

MoE 설계는 DeepSeek-V3 계열을 크게 따릅니다. 각 MoE 레이어에 라우팅 전문가 256개와 공유 전문가 2개를 두고 토큰마다 라우팅 전문가 6개를 활성화하며 공유 전문가 2개는 항상 켜 둡니다. 라우터는 시그모이드 기반이고 보조 손실 없이 부하를 분산하는 바이어스를 씁니다. 여기까지는 최근 대형 MoE의 표준 문법에 가깝습니다.

차이가 나는 곳은 어텐션과 멀티모달 처리입니다. Inkling은 슬라이딩 윈도우 레이어와 글로벌 레이어를 5대 1로 번갈아 배치하고 KV 헤드는 8개를 씁니다. 그리고 위치 인코딩에서 요즘 널리 쓰는 RoPE 대신 **상대적 위치 임베딩**을 채택했는데, 랩은 이 방식이 더 긴 시퀀스로의 외삽 성능이 낫다고 설명합니다. 여기에 키와 밸류 프로젝션 직후, 그리고 어텐션·MLP 잔차 가지 출력에 **짧은 컨볼루션**을 얹었습니다. 트랜스포머 표준 레시피에 몇 가지 계산량이 작은 개선을 골라 넣어, 효율과 장문 성능을 함께 노린 셈입니다.

멀티모달 처리는 특히 실용적입니다. Inkling은 별도의 무거운 인코더 없이 모달리티를 받아들입니다. 오디오는 dMel 스펙트로그램으로, 이미지는 40×40 픽셀 패치로 바꾼 뒤 4층 hMLP를 통과시키고 가벼운 임베딩 레이어로 투영해 디코더가 텍스트 토큰과 함께 처리합니다. 인코더가 따로 없다는 건 서빙 스택이 그만큼 단순해진다는 뜻이기도 합니다.

학습 쪽도 흥미롭습니다. 큰 행렬 가중치에는 Muon, 나머지에는 Adam을 썼고 NVIDIA GB300 NVL72 시스템에서 돌렸습니다. 후처리 학습은 합성 데이터 기반 SFT로 부트스트랩했는데, 그 합성 데이터 일부는 Kimi K2.5가 생성한 것이라고 밝힙니다. 이후 대부분의 연산은 비동기 강화학습에 투입돼 3천만 롤아웃 이상으로 확장됐습니다. 이 과정이 Inkling의 핵심 제어 장치인 **조절 가능한 사고 강도(thinking effort)**를 만들어 냈습니다. 사용자가 추론에 얼마나 많은 연산을 쓸지 다이얼로 조절할 수 있다는 뜻입니다.

### 벤치마크와 소형 버전

Thinking Machines가 공개한 벤치마크는 사고 강도 0.99에서 측정한 값들입니다. 오픈웨이트 기준으로는 강력합니다. GPQA Diamond 87.2%, AIME 2026 97.1%, SWEBench Verified 77.6%, 도구를 붙인 HLE 46.0% 등입니다. 다만 랩이 직접 실은 비교표에서 최상단은 대체로 폐쇄형 모델 차지였고 특히 Claude Fable 5(max)가 다수 항목에서 가장 높은 점수를 기록했습니다. 즉 Inkling의 셀링 포인트는 "폐쇄형 최고를 벤치마크로 이겼다"가 아니라, "오픈웨이트 최상위권 성능을 Apache 2.0으로, 그리고 파인튜닝 가능한 형태로 준다"는 데 있습니다.

같이 공개된 **Inkling-Small**은 276B 총 파라미터에 활성은 12B로, Inkling의 41B보다 훨씬 가볍습니다. 그런데도 여러 벤치마크에서 큰 형제와 대등하거나 앞섭니다. 예컨대 GPQA Diamond는 88.3%로 Inkling(87.2%)을 넘고 채팅 지시 이행(IFBench)과 일부 비전·오디오 항목에서도 앞섰습니다. 사전학습 데이터와 레시피를 소형 모델에 맞춰 개선한 결과라는 설명인데, 지연과 비용을 낮추면서 성능을 지키려는 조직에는 오히려 이쪽이 실전용일 수 있습니다.

## 두 모델을 나란히 놓으면

| 항목 | Kimi K3 | Inkling |
|---|---|---|
| 개발사 / 국적 | Moonshot AI / 중국 | Thinking Machines Lab / 미국 |
| 총 파라미터 | 2.8조 | 975B |
| 활성 파라미터 | 비공개 | 41B |
| 컨텍스트 | 100만 토큰 | 100만 토큰 |
| 입력 모달리티 | 텍스트 + 이미지 (vision-in-the-loop) | 텍스트 + 이미지 + 오디오 |
| 위치 인코딩 | Kimi Delta Attention | 상대적 위치 임베딩 (RoPE 대체) |
| 라이선스 | Modified MIT (7/27 공개) | Apache 2.0 (즉시) |
| 소형 버전 | 없음 | Inkling-Small 276B/12B |
| 겨냥한 축 | 장기 에이전틱 코딩·실행력 | 파인튜닝·도메인 커스터마이즈 |

같은 주에 나왔지만 두 모델은 서로 다른 질문에 답합니다. Kimi K3는 "가장 강한 자율 코딩 에이전트를 오픈웨이트로 만들 수 있는가"에, Inkling은 "기업이 자기 것으로 만들 수 있는 강한 기반 모델을 오픈웨이트로 줄 수 있는가"에 답합니다. 흥미로운 연결 고리도 있습니다. Inkling의 후처리 학습에 쓰인 합성 데이터 일부가 Kimi 계열(K2.5)에서 나왔다는 점인데, 오픈웨이트 생태계가 서로의 출력을 재료로 삼아 굴러가고 있다는 작은 증거입니다.

## ThakiCloud 서빙 관점: 오늘 실제로 무엇을 얹을 수 있나

우리 플랫폼의 렌즈로 보면 두 모델의 무게가 전혀 다릅니다. 핵심은 "우리가 이미 가진 H100/H200/B300 위에 오늘 얹히는가"입니다.

**Kimi K3부터.** 매력적이지만 온프렘 관점에서는 당장은 관망 대상입니다. 이유는 세 가지입니다. 첫째, 가중치가 7월 27일에야 풀리므로 그전에는 API로만 접근됩니다. 둘째, 2.8조 파라미터는 MoE라 해도 가중치 총량이 방대해, BF16이든 저비트 양자화든 단일 노드로는 감당하기 어렵고 다중 노드 구성이 필요합니다. 대부분의 조직에는 인프라 부담이 큽니다. 셋째, Moonshot이 활성 파라미터를 공개하지 않아 실제 서빙 메모리와 처리량을 아직 정밀하게 산정하기 어렵습니다. 그래서 지금 단계에서 Kimi K3는 "에이전틱 코딩 워크로드를 API로 검증해 보되, 온프렘 이식은 가중치 공개 이후 활성 파라미터와 양자화 체크포인트를 확인하고 판단"하는 게 합리적입니다.

**Inkling은 이야기가 다릅니다.** 이쪽은 오늘 우리 하드웨어 위에서 실제로 돌릴 수 있는 후보입니다. 공개된 두 체크포인트의 요구 사항이 구체적이라 계산이 섭니다.

| 체크포인트 | 최소 VRAM | 구성 예시 |
|---|---|---|
| BF16 | 약 2TB | B300 8장 또는 H200 16장 |
| NVFP4 | 약 600GB | B300 4장(W4A4) 또는 H200 8장(W4A16) |

NVFP4 체크포인트가 H200 8장에서 W4A16으로 돈다는 대목이 실질적입니다. H200 한 노드(8-GPU)로 975B급 멀티모달 모델을 얹을 수 있다는 뜻이고 이미 H200을 굴리는 조직이라면 새 하드웨어 없이 시험이 가능합니다. 서빙 런타임도 vLLM, SGLang, Hugging Face `transformers` 등을 지원합니다. OpenAI 호환 서빙은 `vllm serve thinkingmachines/Inkling --tensor-parallel-size 8` 한 줄로 뜹니다. 우리 플랫폼이 이미 vLLM 멀티테넌트 서빙을 표준 경로로 쓰고 있으니 결이 맞습니다.

여기에 우리에게 더 중요한 축은 **파인튜닝**입니다. Inkling은 커스터마이즈 자체를 차별화 포인트로 내세운 모델이고 64K·256K 컨텍스트로 파인튜닝을 지원합니다. ThakiCloud가 kubeflow 기반 LLM 훈련(SFT·CPT·DPO·GRPO 등)과 vLLM 서빙을 한 플랫폼에서 잇는다는 점을 생각하면, "오픈웨이트 기반 모델을 테넌트 데이터로 파인튜닝해 온프렘 서빙까지" 잇는 시나리오에 Inkling이 정확히 들어맞습니다. Inkling-Small(276B/12B)은 지연과 비용이 더 낮아, 멀티테넌트 환경에서 GPU 한 장당 더 많은 테넌트를 얹으려는 우리 비용 모델과 특히 궁합이 좋습니다.

정직하게 요약하면 이렇습니다. Kimi K3는 지금은 "API로 성능을 확인하고, 가중치 공개 뒤 온프렘 타당성을 재검토"할 관망 대상입니다. Inkling은 "NVFP4로 H200 한 노드에 얹고, 테넌트 파인튜닝까지 열어 볼 수 있는" 오늘의 실전 후보입니다. 규모의 화제성은 Kimi K3가 가져갔지만 이번 주 우리 플랫폼에 실제로 손에 잡히는 쪽은 Inkling입니다.

## 마무리

한 주에 프론티어 오픈웨이트가 두 개 나온 사건은 두 가지를 다시 확인시켜 줍니다. 하나는 오픈웨이트가 더 이상 폐쇄형의 뒤를 쫓는 위치가 아니라, 특정 워크로드에서는 앞서고 종합으로도 바로 아래까지 붙었다는 점입니다. 다른 하나는 그 경쟁이 이제 규모(Kimi K3)와 커스터마이즈 가능성(Inkling)이라는 서로 다른 축으로 갈라지기 시작했다는 점입니다.

온프렘 플랫폼을 운영하는 입장에서 이 갈림은 반가운 소식입니다. 우리는 벤치마크 1위 트로피가 아니라 "우리 GPU 위에 얹히는가, 테넌트가 자기 데이터로 만들 수 있는가"를 봅니다. 그 기준으로 이번 주의 답은 Inkling 쪽이 더 가깝고 Kimi K3는 7월 27일 가중치 공개 이후를 기다리는 항목입니다. 두 모델 모두 NVFP4 저비트 서빙을 전제로 설계와 배포가 이뤄졌다는 점은, 오픈웨이트 경쟁의 무게 중심이 "학습 규모"에서 "얹히는 비용"으로 옮겨 가고 있음을 보여 주는 신호이기도 합니다.

## 참고 자료

- [Inkling: Our open-weights model | Thinking Machines Lab](https://thinkingmachines.ai/news/introducing-inkling/)
- [Inkling Model Card | Thinking Machines Lab](https://thinkingmachines.ai/model-card/inkling/)
- [Thinking Machines Lab Releases Inkling | MarkTechPost](https://www.marktechpost.com/2026/07/15/thinking-machines-lab-releases-inkling-a-975b-parameter-open-weights-multimodal-moe-with-41b-active-parameters-and-controllable-thinking-effort/)
- [China's Moonshot throws down the gauntlet with Kimi K3 | SiliconANGLE](https://siliconangle.com/2026/07/16/chinas-moonshot-throws-gauntlet-kimi-k3-worlds-largest-open-weights-model/)
- [China's Moonshot AI releases Kimi K3, the largest open-source model ever | VentureBeat](https://venturebeat.com/technology/chinas-moonshot-ai-releases-kimi-k3-the-largest-open-source-model-ever-rivaling-top-u-s-systems)
- [Kimi K3 launches with 2.8 trillion parameters, open weights July 27 | CryptoBriefing](https://cryptobriefing.com/kimi-k3-open-weights-july-27/)
