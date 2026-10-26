---
title: "MetisRCA-E4B: 근거를 대거나 물러나는 4B급 장애 원인 분석 모델"
excerpt: "장애 원인 분석을 에이전트에 붙이려는 팀을 위한 글입니다. Nemotron 3.5 Bolt E4B에 LoRA를 얹은 MetisRCA-E4B는 미공개 평가셋에서 원인 top-1 0.873을 내고 근거 없는 진단을 0.3%로 줄였습니다. 한계도 같이 적습니다."
seo_title: "MetisRCA-E4B 장애 원인 분석 모델 - ThakiCloud"
seo_description: "장애 원인 분석을 에이전트에 붙이려는 팀을 위한 글입니다. Nemotron 3.5 Bolt E4B에 LoRA를 얹은 MetisRCA-E4B는 미공개 평가셋에서 원인 top-1 0.873을 내고 근거 없는 진단을 0.3%로 줄였습니다. 한계도 같이 적습니다."
date: 2026-10-26
published: true
categories:
  - research
tags:
  - Nemotron
  - Bolt E4B
  - LoRA
  - RCA
  - Small Language Model
  - Paxis
author_profile: true
toc: true
toc_label: "목차"
lang: ko
permalink: /ko/research/metisrca-e4b/
canonical_url: "https://thakicloud.github.io/ko/research/metisrca-e4b/"
---

장애 원인 분석을 에이전트에 붙이려는 팀을 위한 글입니다. MetisRCA-E4B는 학습에 쓰지 않은 평가셋에서 원인 top-1 0.873을 내고, 근거 없는 진단은 0.3%로 줄였습니다. 다만 한 번도 못 본 장애 메커니즘에서는 같은 크기의 Qwen3.5-4B보다 낮고, 진단 가능한 사례의 약 15%에서 불필요하게 기권합니다.

## Nemotron 3.5 Bolt E4B는 어떤 모델인가

Bolt E4B는 NVIDIA가 Gemma-4-E4B-it을 기반으로 추가 post-training한 소형 언어 모델입니다. 전체 파라미터 8B, 실효 4B이고 입출력 각각 최대 64K 토큰을 지원합니다. 멀티턴 도구 사용, 지시 따르기, 입력 근거 유지를 강화했고, 강화학습은 GRPO로 진행했다고 밝힙니다. 낮은 메모리와 낮은 첫 토큰 지연이 목표라 로컬 비서나 엣지 장비에 맞습니다. 라이선스는 OpenMDW-1.1이며 Q4_K_M 4GB 판이 따로 공개되어 있습니다. BF16 판은 커스터마이징용 배포본이라 저희는 이 판을 본체로 썼습니다.

## 어떻게 만들었나

![BF16 본체에서 GGUF까지의 파이프라인](/assets/images/posts/research/bolt-specialists/pipeline-ko.svg)
*그림 1. 노란색 두 단계가 점수를 부풀리지 않게 막습니다. 라벨 생성과 누출 검사는 모델이 아니라 코드가 맡습니다.*

BF16 가중치 위에서 LoRA SFT를 했습니다. rank 16, alpha 32로 어텐션과 MLP 텍스트 경로의 선형층 258개에 어댑터를 붙였고 학습률은 2e-4, 2 에폭입니다. 정답 라벨은 코드가 만들고, 학습셋과 평가셋 사이에 누출과 계보 검사를 걸었습니다. 모델은 장애 증거를 읽고 원인을 한 줄로 진단하되, 근거가 부족하면 `INSUFFICIENT_EVIDENCE`로 기권하고 다음 도구를 요청하는 읽기 전용 역할입니다.

## 측정 결과

같은 프롬프트와 디코딩으로 세 모델을 비교했습니다. 아래 표는 같은 평가 행끼리 짝지은 값입니다.

| 평가 | MetisRCA-E4B | Qwen3.5-4B | Bolt 본체 |
|---|---|---|---|
| 미공개 평가 전체 (1,566건) 원인 top-1 | 0.873 | 0.694 | 0.619 |
| 못 본 메커니즘 (783건) top-1 | 0.784 | 0.814 | - |
| Cloud-OpsBench, 진단 가능한 못 본 메커니즘 top-1 | 0.783 | 0.831 | 0.764 |

미공개 평가 전체에서 근거 F1은 0.82이고, 근거 없는 진단 비율은 0.3%로 Qwen3.5-4B의 7.3%보다 훨씬 낮습니다. 차이는 정확도보다 태도에서 큽니다. 근거가 부족한 사례에서 물러나는 능력이 이 어댑터의 핵심입니다.

## 보정 결과: 기권 정책

저장소에 `abstain_policy.py`로 추론 시점의 기권 정책을 함께 넣었습니다. 가중치는 같습니다. 임계값 1.5는 검증셋에서만 골랐고 평가셋에는 한 번만 적용했습니다.

| 못 본 메커니즘 (783건) | 기본 디코딩 | 보정 |
|---|---|---|
| 원인 top-1 (Qwen3.5-4B 0.814) | 0.784 | 0.824 |
| 불필요한 기권 | 15.3% | 9.4% |
| 올바른 기권 | 78.7% | 73.6% |
| 근거 없는 진단 | 0.26% | 0.26% |

불필요한 기권을 5% 아래로 낮추겠다는 사전 등록 기준은 충족하지 못했습니다. Cloud-OpsBench에서 진단 가능한 360건을 같은 조건으로 비교하면 기본 디코딩 282건, 보정 298건, Qwen3.5-4B 299건을 맞혔습니다. 한 건 차이로 뒤집니다. 미공개 평가 전체 top-1은 0.873에서 0.897로 올랐습니다. GGUF를 llama.cpp로 돌리면 보정 없는 기본 v4와 같게 동작하고, 보정은 transformers가 필요합니다. Q4_K_M GGUF(5.34GB)는 본 평가 분할에서 BF16과 같은 top-1 0.9697을 유지했습니다.

## 한계

한 번도 못 본 장애 메커니즘에서는 기본 디코딩 기준으로 Qwen3.5-4B가 더 높았고, 보정을 해도 새로운 원인을 더 잘 맞힌다고는 말하지 않습니다. 이 모델의 강점은 근거 인용과 기권입니다. 진단 가능한 사례에서도 약 15%는 기권합니다. 틀릴 때 원인을 지어내기보다 멈추는 쪽이라 에이전트에는 안전한 실패이지만, 새로운 유형의 장애가 들어오면 더 큰 모델이나 사람이 이어받는 경로가 반드시 필요합니다.

## Paxis에서 쓰는 방식

Paxis는 기업 업무를 AI 에이전트로 자동화하는 ThakiCloud의 플랫폼입니다. 아래는 설계 방향이며 출시된 기능이 아닙니다. MetisRCA-E4B는 읽기 전용 RCA 단계로 둡니다. 근거 id를 인용해 원인을 제시하거나, 기권하고 다음에 필요한 도구를 요청합니다.

![에이전트 앞단의 사전 점검과 읽기 전용 RCA 단계](/assets/images/posts/research/bolt-specialists/paxis-flow-ko.svg)
*그림 2. 모델은 제안하고 권한은 코드가 정합니다. RCA 단계는 읽기 전용이라 기권하면 다음 도구 요청으로 이어집니다.*

기권이 에이전트의 다음 조회로 이어지면 약 15%의 과도한 기권은 도구 호출 한 번의 비용으로 끝납니다. 처음 보는 유형의 장애는 상위 모델이나 사람에게 넘깁니다. 어떤 조치를 실행할지는 이 모델이 아니라 모델 밖의 권한 검사가 정합니다.

## 모델 받기

- MetisRCA-E4B: https://huggingface.co/ThakiCloud/MetisRCA-E4B
- 컬렉션: https://huggingface.co/collections/ThakiCloud/thakicloud-bolt-e4b-specialists-6ade97db98b0258cb49447a0
