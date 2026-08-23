---
title: "추론 강도 라벨은 정말 연산량을 줄여줄까: Qwen3-8B로 확인한 것"
excerpt: "reasoning effort 라벨로 토큰을 조절하려는 시도를 Qwen3-8B에 붙여 실측했다. 부드러운 길이 보상은 라벨이 연산량을 못 가르지만(1.1배), 모델을 전역적으로 더 토큰 효율적으로 만들었다. 왜 안 되는지와 하드 버짓(LCPO) 처방을 정리한다."
seo_title: "추론 강도 라벨과 토큰 제어 실측 - Qwen3-8B GRPO - Thaki Cloud"
seo_description: "Qwen3-8B에 effort-conditioned SFT+GRPO를 붙여 측정: 라벨은 연산량을 못 가름(1.08~1.28x, 목표 1.8x), 대신 토큰 효율 Pareto 개선. 정답 보상 지배 기전과 LCPO 하드버짓 처방."
date: 2026-07-27
last_modified_at: 2026-07-27
tags:
  - reasoning-effort
  - token-budget
  - grpo
  - lcpo
  - qwen3-8b
  - rlvr
  - inference-cost
  - reinforcement-learning
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
audiobook: "https://drive.google.com/file/d/15slDDoqxUHsPlqPR9Gg0ebe7s05VOB1R/view"
audiobook_label: "▶ 5분 브리핑으로 듣기"
audiobook_note: "NotebookLM 오디오 개요 (AI 생성)"
canonical_url: "https://thakicloud.com/tech-blog/ko/research/reasoning-effort-token-control/"
---

추론 모델을 서빙하면서 응답당 토큰, 즉 비용과 지연을 조절하고 싶은 엔지니어라면 "추론 강도(reasoning effort)" 라벨 하나로 연산량을 가를 수 있는지가 실질적인 관심사입니다. Qwen3-8B로 직접 붙여 보니, 길이 보상을 부드럽게 주는 흔한 방식으로는 라벨이 연산량을 거의 못 가릅니다. 대신 예상하지 못한 소득이 하나 나왔고, 왜 안 되는지도 분명해졌습니다.

![추론 강도 라벨은 정말 연산량을 줄여줄까: Qwen3-8B로 확인한 것 개념을 형상화한 이미지](/assets/images/reasoning-effort-token-control-hero.webp)
*글의 핵심 개념을 형상화했습니다.*

## 무엇을 했나

시스템 프롬프트에 `Reasoning effort: low|medium|high`를 넣고 모델이 그 라벨에 맞춰 추론 길이를 조절하도록 학습시켰습니다. 먼저 길이별로 균형을 맞춘 추론 데이터로 지도학습(SFT)을 하고, 이어서 길이 준수 보상을 주는 강화학습(GRPO)을 얹었습니다. 평가는 어려운 수학셋 MATH-500과 쉬운 산수셋 GSM8K에서 돌렸고, 토큰 예산을 256부터 4096까지 훑으며 정확도와 실제 생성 토큰을 함께 쟀습니다.

"제어가 된다"의 기준은 low 대비 high가 토큰을 1.8배 이상 더 쓰는 것으로 잡았습니다. o1, o3 계열이 보여 준 effort 다이얼 정도의 분리를 목표로 삼은 셈입니다.

<!-- nlm-visual -->
![핵심 개념 요약 인포그래픽 1](/assets/images/posts/news/reasoning-effort-token-control/nlm-infographic-1.webp)
*NotebookLM이 소스를 종합해 생성한 인포그래픽입니다.*

## 결과 하나: 라벨은 연산량을 못 가른다

| 모델 / 평가 | low | med | high | 분리 | 정확도(low→high) |
|---|---|---|---|---|---|
| Base Qwen3-8B / MATH-500 | 2887 | 3132 | 3268 | 1.13배 | 0.66 → 0.64 |
| 학습본(SFT+GRPO) / MATH-500 | 2332 | 2463 | 2516 | 1.08배 | 0.69 → 0.68 |
| 학습본 / GSM8K | 1173 | 1296 | 1502 | 1.28배 | 0.95 → 0.92 |

분리는 1.08배에서 1.28배에 그쳐, 목표 1.8배에 한참 못 미쳤습니다. MATH에서는 학습본의 분리(1.08배)가 학습 전 원본(1.13배)보다도 낮게 나왔습니다. 부드러운 길이 보상은 라벨을 살짝 건드릴 뿐, 연산량을 다이얼처럼 돌려 주지는 못합니다.

## 결과 둘: 그런데 모델이 더 효율적이 됐다

라벨 조건부 분리는 실패했는데, 같은 학습이 엉뚱하게도 전역 토큰 효율을 끌어올렸습니다. MATH-500에서 예산별 정확도를 보면 이렇습니다.

| 예산(토큰) | 원본 정확도 | 학습본 정확도 |
|---|---|---|
| 1024 | 0.31 | 0.41 |
| 2048 | 0.535 | 0.575 |
| 4096 | 0.63 (3118토큰) | 0.69 (2451토큰) |

4096 예산에서 학습본은 정확도가 6%포인트 높으면서 토큰은 670개쯤 덜 씁니다. effort 라벨과 무관하게 모든 구간이 짧아졌는데 정확도는 유지되거나 올랐습니다. 길이 준수를 가르치려던 학습이 라벨에는 안 붙고, 대신 모델 전체를 더 간결하게 만든 셈입니다. 서빙 관점에서는 이 소득도 반갑습니다. 같은 예산에 더 맞히거나, 같은 정확도를 더 싸게 내니까요.

## 왜 라벨에 안 붙었나

<div class="mermaid">
flowchart TB
    응답["모델 응답 생성<br/>Reasoning effort: low"] --> 판정{"정답인가"}
    판정 -- "아니오" --> 무보상["보상 0<br/>길이 항이 켜지지 않음"]
    판정 -- "예" --> 보상["보상 1.0<br/>길이가 목표에 가까우면 +0.5"]
    무보상 --> 무신호["길이 신호 소멸<br/>계속 길게 추론"]
    보상 --> 신호["길이 신호 작동<br/>짧게 답할 유인"]
    무신호 --> MATH["MATH-500<br/>짧으면 대개 오답<br/>분리 1.08배"]
    신호 --> GSM["GSM8K<br/>짧아도 정답 가능<br/>분리 1.28배"]
</div>
*길이 보상이 정답에 종속되어 있어, 짧으면 대개 틀리는 어려운 문제에서는 길이 항 자체가 사라집니다.*

보상 설계를 뜯어 보면 답이 나옵니다. 보상은 정답이면 1.0, 거기에 길이가 목표에 가까우면 0.5를 더 주는 구조인데, 이 길이 항이 정답일 때만 켜집니다. 어려운 MATH 문제는 짧게 답하면 대개 틀리고, 틀리면 보상이 0이라 길이 항 자체가 사라집니다. 그래서 "low"라고 요청해도 모델은 계속 길게 추론합니다. 길이 다이얼이 실제로 먹히는 곳은 맞으면서도 짧을 수 있는 쉬운 문제뿐이고, GSM8K(1.28배)가 MATH(1.08배)보다 분리가 큰 이유가 바로 여기에 있습니다. 어려운 과제에서 정답 보상이 길이 보상을 압도한다는 것, 이 한 가지가 부드러운 길이 보상이 effort 제어를 못 넣는 근본 원인입니다.

## 처방: 부드러운 넛지 대신 하드 버짓

원인이 "정답 보상 지배"라면 처방은 명확해집니다. 길이 항을 정답에 종속시키지 말고, effort 라벨을 아예 연산량의 상한으로 만들면 됩니다. 이것이 LCPO의 hard budget 방식입니다. low는 256, medium은 1024, high는 3072토큰처럼 라벨마다 예산을 정해 두고, 그 예산 안에서 맞혔을 때만 보상을 줍니다. 예산을 넘기면 초과분에 비례해 보상을 깎아 2배 지점에서 0으로 만듭니다. 이렇게 하면 "low"는 짧게 끝내야만 점수를 받으니, 모델은 낮은 강도에서 빠르게 답하며 정확도를 일부 내주고, 높은 강도에서만 오래 생각하도록 학습됩니다. 앞의 기전이 예측하는 그대로의 레버입니다.

이 방식은 이미 구현해 두었고(`grpo_l1.py --lcpo`), 수렴된 분리 수치를 뽑는 재실행은 GPU 확보에 맞춰 이어서 진행합니다.

## 정리

부드러운 길이 보상은 "추론 강도" 라벨을 연산량 다이얼로 바꾸지 못합니다. 대신 그 학습은 모델을 전역적으로 더 토큰 효율적으로 만들어, 같은 예산에 더 맞히고 같은 정확도를 더 싸게 냅니다. 라벨을 진짜 다이얼로 만들려면 보상을 넛지가 아니라 하드 버짓으로 바꿔야 하고, 그 근거는 "어려운 문제에서는 정답 보상이 길이 보상을 이긴다"는 관찰에 있습니다.

이 수치는 시뮬레이션이 아니라 Qwen3-8B를 실제 H200에서 학습해 MATH-500과 GSM8K로 측정한 값입니다(seed 1234).

<!-- nlm-visual -->
![핵심 개념 요약 인포그래픽 2](/assets/images/posts/news/reasoning-effort-token-control/nlm-infographic-2.webp)
*NotebookLM이 소스를 종합해 생성한 인포그래픽입니다.*

## 출처

- 하드 버짓 처방의 근거: [L1: Controlling How Long A Reasoning Model Thinks With Reinforcement Learning](https://arxiv.org/abs/2503.04697)
- 사용한 강화학습 알고리즘: [DeepSeekMath: Pushing the Limits of Mathematical Reasoning in Open Language Models](https://arxiv.org/abs/2402.03300)
- 학습 대상 모델: [Qwen3-8B](https://huggingface.co/Qwen/Qwen3-8B)
- 평가셋(어려운 수학): [HuggingFaceH4/MATH-500](https://huggingface.co/datasets/HuggingFaceH4/MATH-500)
- 평가셋(산수): [Training Verifiers to Solve Math Word Problems](https://arxiv.org/abs/2110.14168)
- 추론 강도 파라미터 규격: [OpenAI Reasoning models 문서](https://developers.openai.com/api/docs/guides/reasoning)
