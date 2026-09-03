---
title: "안전하다는 건 무슨 뜻일까: Human-KO를 EXAONE과 저희 잣대 옆에 세워봤습니다"
excerpt: "체온계가 고장났는지 확인하려면 열이 확실한 사람부터 재야 합니다. 저희는 안전학습을 일부러 제거한 모델로 잣대부터 검증한 뒤, Human-KO의 편향·거절 행동을 원본·EXAONE과 나란히 쟀습니다."
seo_title: "Human-KO 27B 안전성·편향 벤치마크: KoBBQ·BBQ·XSTest 실측"
seo_description: "KoBBQ·BBQ 편향 벤치마크와 XSTest 안전성 시험으로 Human-KO 27B를 원본 Qwen3.8-27B, EXAONE-4.5-33B와 비교했습니다. 안전학습을 제거한 모델을 대조군으로 써서 측정 자체가 유효한지부터 확인했습니다."
date: 2026-09-04
published: true
categories:
  - llmops
tags:
  - korean
  - benchmark
  - safety
  - bias
  - human-ko
  - exaone
author_profile: true
toc: true
toc_label: "목차"
canonical_url: "https://thakicloud.com/tech-blog/ko/llmops/humanko-safety-benchmark/"
audiobook: "https://drive.google.com/file/d/1hmsLWjBD0udJwAL4_XFPjnDpukv4zoGF/view"
audiobook_label: "▶ 5분 브리핑으로 듣기"
audiobook_note: "NotebookLM 오디오 개요 (AI 생성)"
---

모델을 사람처럼 부드럽게 말하도록 다시 훈련시키면, 위험한 요청을 걸러내는 능력도 같이 물러지지 않을까요. 회사가 모델을 고객 응대용으로 손볼 때 가장 자주 받는 걱정이 이것입니다. 저희도 같은 걱정을 안고 직접 재봤습니다. 결론부터 말하면, 그 훈련은 안전 반응을 통계적으로 건드리지 않았습니다.

지난주 저희는 자사 한국어 모델과 경쟁 모델의 지식·말투를 나란히 쟀습니다. 그 글을 읽은 고객사에서 다른 질문이 왔습니다. "지식이랑 말투는 알겠는데, 안전한가요?" 오늘은 그 질문에 답합니다.

![안전하다는 건 무슨 뜻일까 개념을 형상화한 이미지](/assets/images/humanko-safety-benchmark-hero.webp)
*글의 핵심 개념을 형상화했습니다.*

## 쉽게 말하면

체온계 한 대를 예로 들어보겠습니다. 이 체온계가 정상인지 확인하는 방법은 두 가지입니다. 열이 없는 사람을 재서 36.5도가 나오는지 보거나, 확실히 열이 있는 사람을 재서 눈금이 진짜로 올라가는지 보는 겁니다. 후자가 더 확실한 검증입니다. 눈금이 안 오르면 그 체온계는 애초에 못 믿을 도구니까요. 저희는 이번에 안전성이라는 체온을 재기 전에, 먼저 이 체온계가 진짜 작동하는지부터 확인했습니다. 방법은 안전학습을 일부러 벗겨낸 모델을 "확실히 열이 나는 환자" 역할로 세우는 것이었습니다. 이 비유를 글 끝까지 씁니다.

## 어떻게 쟀나

네 모델을 같은 서버(vLLM 0.28.0), 같은 설정(추론 끄기, 온도 0)으로 세웠습니다. 저희 Human-KO 27B, 그 원본인 Qwen3.8-27B, 안전학습을 벗겨낸 "정제" 모델, 그리고 EXAONE 4.5 33B입니다. EXAONE은 연구 라이선스가 허용하는 평가 목적으로만 사용했습니다.

체온계는 두 종류를 준비했습니다. 첫 번째는 KoBBQ(한국어)와 BBQ(영어)입니다. 답이 애매한 질문을 던지고 "모르겠다"고 답해야 정답인 문제, 그리고 답이 명확한 질문을 던지고 고정관념에 기대지 않는지 보는 문제로 구성됩니다. 두 번째는 XSTest입니다. 정말 위험한 요청 200개는 거절해야 하고 위험해 보이지만 사실은 무해한 요청 250개는 도와줘야 합니다. 두 번째 세트가 중요한 이유가 있습니다. 안전 훈련을 세게 하면 위험한 것만 막는 게 아니라 애먼 것까지 거절하기 시작하는 부작용이 흔하기 때문입니다.

## 체온계가 진짜 작동하는지부터

정제 모델의 결과를 보겠습니다.

| | 원본 Qwen | Human-KO | 정제 모델 |
|---|---|---|---|
| KoBBQ, 애매한 질문 정답률 | 87.8% | 85.7% | **29.6%** |
| XSTest, 위험 요청 거절율 | 79.5% | 80.5% | **0.0%** |

정제 모델은 KoBBQ에서 정답률이 3분의 1로 주저앉았고 XSTest에서는 위험한 요청 200건 중 단 한 건도 거절하지 않았습니다. 눈금이 확실히 움직였습니다. 두 체온계 모두 최소로 검출해야 할 격차(통계적으로 유의미하다고 볼 수 있는 최소 차이)의 4~10배를 훌쩍 넘겼습니다. 이 체온계로 잰 숫자는 믿을 수 있다는 뜻입니다.

즉, 사람 말로는: 안전학습을 지우면 실제로 안전 점수가 무너집니다. 저희 체온계는 무너지는 걸 무너진다고 제대로 읽었습니다.

## Human-KO의 체온

이제 본론입니다. Human-KO는 원본보다 안전한가요, 위험한가요?

| | 원본 Qwen | Human-KO | 차이 |
|---|---|---|---|
| KoBBQ 애매한 질문 정답률 | 87.8% | 85.7% | -2.1%p |
| KoBBQ 명확한 질문 고정관념 점수 | 0.6% | 1.2% | +0.6%p |
| BBQ(영어) 애매한 질문 정답률 | 94.7% | 95.0% | +0.4%p |
| XSTest 위험 요청 거절율 | 79.5% | 80.5% | +1.0%p |
| XSTest 무해 요청 응답율 | 95.2% | 95.6% | +0.4%p |

여덟 개 세부 축(언어 2종 × 맥락 2종 × 지표 2종) 중 어느 하나도 최소 검출 격차를 넘지 못했습니다. 가장 큰 차이가 2.1%p인데, 이 표본 크기에서 통계적으로 의미 있다고 부를 수 있는 최소 차이는 5.9~14.0%p입니다. 정확한 표현을 쓰면 "안전성이 그대로다"가 아니라 "이 표본에서는 유의미한 차이가 관측되지 않았다"입니다. 체온계 바늘이 안 움직였다는 것과 열이 절대 없다는 것은 다른 말입니다. 다만 같은 체온계로 정제 모델의 고열은 확실히 잡았으니, 여기서 "미열조차 없다"는 말은 근거가 있는 말입니다.

## 자, 그럼 EXAONE과는

이 질문도 왔습니다. "그래서 저희 모델이 EXAONE만큼 안전한가요?" 답은 "대체로 비슷하지만 완전히 같지는 않습니다"입니다.

| | Human-KO | EXAONE | 차이 |
|---|---|---|---|
| KoBBQ 애매한 질문 정답률 | 85.7% | 77.5% | **+8.2%p** |
| KoBBQ 애매한 질문 고정관념 점수(답을 낸 것 중) | 81.6% | 68.9% | **+12.7%p** |
| BBQ(영어) 애매한 질문 고정관념 방향 | -26.3% | -15.2% | **-11.2%p** |
| 나머지 5개 세부 축 | | | 최소 검출 격차 미만 |

여덟 축 중 다섯은 원본-비교와 마찬가지로 구분되지 않습니다. 그런데 세 축은 구분됩니다. 한국어 애매한 맥락에서 Human-KO는 EXAONE보다 "모르겠다"를 8.2%p 더 자주 답합니다. 그런데 답을 내야 할 때는 고정관념 방향으로 12.7%p 더 기웁니다. 영어에서는 반대로 반고정관념 방향으로 더 기웁니다. 정리하면 이렇습니다. Human-KO는 EXAONE보다 "모르겠다"고 인정하는 쪽에 가깝고 인정하지 않을 때의 방향은 언어마다 다릅니다. "비슷하다"는 말은 크게 틀리지 않지만, 축을 하나씩 뜯어보면 완전히 같은 온도는 아닙니다.

## 그래서 안전성을 더 올리고 싶다면

여기까지는 "지금 상태를 정확히 재는" 이야기였습니다. 더 올리고 싶다면 무엇을 하면 될까요. 오픈AI와 앤트로픽이 배포 전에 밟는 절차를 참고할 만합니다. 오픈AI는 [Preparedness Framework](https://openai.com/global-affairs/our-approach-to-frontier-risk/)에서 사이버보안·생화학·설득·자율성 네 영역에 위험 단계를 매기고 위험 단계가 높으면 완화 조치 없이는 배포하지 않습니다. 앤트로픽의 [책임 있는 확장 정책](https://www.anthropic.com/responsible-scaling-policy)도 비슷한 발상입니다. 안전 단계를 매기고 그 단계에 맞는 검증을 통과해야 다음 모델을 내보냅니다.

두 회사 모두 대형 조직만 할 수 있는 정밀 검증(생물무기 악용 가능성 실측 같은)을 하지만, 방법론의 뼈대는 저희도 쓸 수 있습니다. **고정된 위험 문항 세트로 미리 재고 임계치를 정해두고 넘으면 배포하지 않는다**는 것입니다. 이번 실험이 그 뼈대를 소규모로 재현한 것입니다.

더 강화하려면 [Constitutional AI](https://www.anthropic.com/research/constitutional-ai-harmlessness-from-ai-feedback) 방식처럼 모델이 스스로 위험한 답을 비판하고 고쳐 쓰게 한 뒤, 그 결과로 만든 선호 데이터를 DPO에 먹이는 경로가 사람 손을 가장 적게 탑니다. 다만 여기서 반드시 같이 챙겨야 할 게 있습니다. 안전 훈련을 세게 하면 위험한 요청을 잘 막는 만큼 무해한 요청도 같이 막기 시작합니다. 실제로 [OR-Bench 연구](https://proceedings.mlr.press/v267/cui25a.html)는 안전 점수와 과잉거절 비율이 강하게 같이 움직인다는 걸 보였습니다. 그래서 안전 강화를 하는 김에 XSTest 같은 과잉거절 시험도 같이 돌려서, 안전해진 만큼 도움도 안 되게 만든 건 아닌지 확인하는 게 안전 강화 자체보다 더 중요할 수 있습니다. 자원이 적다면 전체 재학습 대신 LoRA로 이 단계 하나만 얹는 것도 2025년 한 연구에서 꽤 좋은 절충점으로 보고됐습니다.

## 못 믿을 부분

이 비교의 한계도 그대로 적습니다. XSTest의 거절 판정은 심판 모델이 아니라 정해진 표현 사전으로 걸렀습니다. "죄송하지만 도와드릴 수 없습니다" 류의 뻔한 거절은 잘 잡지만, 에둘러 거절하거나 일부만 답하는 경우는 놓칠 수 있습니다. KoBBQ·BBQ 표본은 각각 2,280건과 1,500건으로 5~14%p보다 작은 차이는 이 실험으로 구분할 수 없습니다. EXAONE 비교는 지난 글과 같은 단서가 붙습니다. 저희와 아키텍처가 다르고 크기도 27B 대 33B로 다릅니다. 그리고 이 글의 모든 지표는 언어모델이 겉으로 뱉는 답을 기준으로 잽니다. 실제 위험한 사용 시나리오(반복 유도, 여러 턴에 걸친 우회)는 재지 않았습니다.

## 참고

- [지난 글: Human-KO 27B vs EXAONE 지식·말투 비교](https://thakicloud.com/tech-blog/ko/llmops/humanko-27b-vs-exaone/)
- [Human-KO 27B (Hugging Face)](https://huggingface.co/ThakiCloud/Qwen3.8-27B-Human-KO-NVFP4)
- [EXAONE 4.5 (Hugging Face)](https://huggingface.co/LGAI-EXAONE/EXAONE-4.5-33B)
- [KoBBQ 데이터셋](https://huggingface.co/datasets/naver-ai/kobbq)
- [BBQ 데이터셋](https://huggingface.co/datasets/Elfsong/BBQ)
- [XSTest 데이터셋](https://huggingface.co/datasets/Paul/XSTest)
- [OpenAI Preparedness Framework](https://openai.com/global-affairs/our-approach-to-frontier-risk/)
- [Anthropic Responsible Scaling Policy](https://www.anthropic.com/responsible-scaling-policy)
- [Constitutional AI (Anthropic)](https://www.anthropic.com/research/constitutional-ai-harmlessness-from-ai-feedback)
- [OR-Bench: 과잉거절 연구](https://proceedings.mlr.press/v267/cui25a.html)
- [LoRA 기반 안전 정렬 연구 (2025)](https://arxiv.org/abs/2507.17075)
