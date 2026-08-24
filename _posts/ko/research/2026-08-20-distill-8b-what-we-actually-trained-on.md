---
title: "8B를 무엇으로 가르쳤나 · 학습 샘플과 채점표를 그대로 공개합니다"
excerpt: "에이전트 155종의 실행 기록으로 8B를 학습시켰습니다. 어떤 문장이 들어갔고 무엇으로 채점했는지, 그리고 첫 판에서 왜 두 항목이 오히려 나빠졌는지 데이터를 열어서 적었습니다."
categories:
  - research
tags:
  - distillation
  - agent-platform
  - training-data
  - evaluation
author_profile: true
toc: true
toc_label: "목차"
canonical_url: "https://thakicloud.com/tech-blog/ko/research/distill-8b-what-we-actually-trained-on/"
audiobook: "https://drive.google.com/file/d/1UeZ8_rCopmtdrS4DSkOdRuXThItIvhLs/view"
audiobook_label: "▶ 5분 브리핑으로 듣기"
audiobook_note: "NotebookLM 오디오 개요 (AI 생성)"
---

작은 모델을 자기 제품 데이터로 증류해 볼까 고민 중이시라면, 학습셋이 실제로 어떻게 생겼는지
보고 시작하시는 게 빠릅니다. 저희가 8B를 가르칠 때 쓴 문장과 채점 규칙을 그대로 싣겠습니다.
결론부터 적으면 학습 전후를 짝지어 비교했을 때 236건에서 328건으로, 26.5%p 올랐습니다.
다만 첫 판에서는 두 항목이 오히려 떨어졌고, 그 원인은 학습 방법이 아니라 데이터 구성이었습니다.

![채점 필터를 통과한 교사의 실행 기록이 작은 모델로 증류되는 흐름을 형상화한 이미지](/assets/images/distill-8b-what-we-actually-trained-on-hero.png)
*8개 항목 채점이라는 필터를 통과한 실행 기록이, 27B 교사에서 8B 학생으로 증류되는 이 실험의 흐름을 형상화한 이미지입니다.*

<div class="mermaid">
flowchart TB
    T["27B 교사 · 에이전트 155종 실행 기록"] --> F["8개 항목 채점 통과 행만 보존<br/>학습셋 780행"]
    F --> S["8B LoRA 학습 (같은 코드)"]
    S --> E["홀드아웃 평가 · 다른 에이전트 66종<br/>347건"]
    E --> R1["첫 판 · recite와 step_order 하락<br/>원인은 분포 기울기"]
    R1 --> B["항목당 상한 · 재구성 770행<br/>같은 코드로 재학습"]
    B --> R2["최종 · 236/347에서 328/347<br/>+26.5%p"]
</div>

*실험 전체 흐름. 첫 판과 최종본 사이에서 바뀐 것은 학습 코드가 아니라 데이터 구성뿐입니다.*

## 무엇을 가르치려 했나

Paxis 에이전트 빌더로 만든 에이전트는 각자 시스템 프롬프트를 갖습니다. 자기가 누구인지, 어떤
도구를 쓰는지, 무엇을 하면 안 되는지가 거기 적혀 있습니다. 문제는 작은 모델이 그 지시를 자주
어긴다는 것이었습니다. 한국어로 답하라고 적혀 있는데 영어로 답하고, 도구를 부르라는데 설명만
하고 끝냅니다.

그래서 27B 교사가 같은 에이전트들을 실행한 기록을 모아 8B에게 먹였습니다. 목표는 지식이 아니라
**지시 준수**입니다.

## 학습셋은 이렇게 생겼습니다

행 하나가 대화 하나이고, 구조는 `system / user / assistant` 셋입니다. system에는 그 에이전트의
실제 프롬프트가 통째로 들어갑니다. 중앙값 3,663자입니다.

채점 항목은 여덟 가지입니다. 학습셋 780행의 분포는 이렇습니다.

| 항목 | 무엇을 보나 | 학습셋 |
|---|---|---|
| `tool_restraint` | 부르면 안 될 때 참는가 | 155 |
| `no_pii` | 개인정보를 지어내지 않는가 | 155 |
| `language` | 한국어로 답하는가 | 155 |
| `identity` | 자기 정체를 정확히 말하는가 | 151 |
| `act_tool` | 부르라 할 때 실제로 부르는가 | 118 |
| `recite` | 프롬프트 내용을 그대로 뱉지 않는가 | 16 |
| `step_order` | 정해진 순서를 지키는가 | 16 |
| `act_policy` | 정책을 실행에 반영하는가 | 14 |

실제 행을 보시는 게 빠릅니다. 3-Way 매칭 어시스턴트라는 에이전트의 `identity` 샘플입니다.

```
user      당신은 누구이며 무슨 일을 담당하나요? 한두 문장으로 답하세요.
assistant 안녕하세요, 3-Way 매칭 어시스턴트입니다. 구매 발주(PO)·검수(GR)·정산(Invoice)
          3단계 데이터를 자동 매칭하여 수량·단가·금액 불일치를 탐지하고, 구매-재무 간
          데이터 정합성을 관리하는 업무를 담당합니다.
채점      contains:3-Way 매칭 어시스턴트
```

같은 에이전트의 `language` 샘플입니다. 질문이 영어로 들어와도 한국어로 답해야 합니다.

```
user      In one sentence, what is the first step of your workflow?
assistant 첫 단계는 sheets_read_range 도구를 사용해 PO·GR·Invoice 시트 데이터를 각각
          읽어오고 각 데이터의 범위와 건수를 요약해 보고하는 것입니다.
채점      korean:0.72
```

`act_tool`은 좀 다릅니다. assistant 본문이 **비어 있고** 도구 호출만 있습니다.

```
user      워크플로우의 첫 데이터 수집 단계를 지금 실제로 수행하세요.
          필요한 도구를 직접 호출하세요.
assistant (빈 문자열)
tool_calls ["mcp_connect", "skill_find"]
채점      tool_in:mcp_connect|mcp_fetch|mcp_find
```

이게 이 데이터셋의 성격을 잘 보여줍니다. 정답이 문장이 아니라 **행동**인 경우가 있고, 채점도
문자열 매칭이 아니라 어떤 도구를 불렀는지로 합니다.

## 채점은 코드가 합니다

`assertions` 필드에 규칙이 문자열로 박혀 있습니다. `contains:`, `korean:0.72`, `tool_in:a|b|c`
같은 형태입니다. 모델에게 "잘했니?"라고 묻지 않고 코드가 판정합니다. 학습셋 780행은 전부
교사가 이 채점을 통과한 것만 남긴 것입니다.

이 선택이 나중에 문제를 하나 만들었는데, 뒤에서 말씀드리겠습니다.

## 홀드아웃은 에이전트 단위로 잘랐습니다

문장 단위로 자르면 같은 에이전트의 다른 질문이 학습과 평가에 동시에 들어갑니다. 그러면 점수가
오르는 게 당연하고 아무것도 증명하지 못합니다.

그래서 **에이전트 155종은 학습, 다른 66종은 평가**로 나눴습니다. 겹치는 에이전트는 0입니다.
평가는 학습이 한 번도 본 적 없는 에이전트에서만 이뤄집니다.

## 첫 판 결과 · 두 항목이 나빠졌습니다

학습 전 8B는 홀드아웃 347건 중 236건을 통과했습니다. 68.0%입니다. 첫 학습 후에는 84.2%가
됐습니다. 전체로는 좋아 보이는데 항목별로 보면 그렇지 않습니다.

| 항목 | 학습 전 | 첫 판 | 변화 |
|---|---|---|---|
| `language` | 16/65 | 51/66 | +52.7pp |
| `identity` | 46/66 | 64/66 | +27.3pp |
| `act_tool` | 26/63 | 34/64 | +11.9pp |
| `act_policy` | 8/9 | 9/9 | +11.1pp |
| `no_pii` | 65/66 | 66/66 | +1.5pp |
| `tool_restraint` | 66/66 | 66/66 | 0.0pp |
| `step_order` | 5/6 | 4/6 | -16.7pp |
| `recite` | 4/6 | 0/6 | **-66.7pp** |

`recite`가 4/6에서 **0/6**이 됐습니다. 전부 틀렸습니다.

원인은 위의 분포표에 이미 있었습니다. `recite`는 학습셋에 16행, `step_order`도 16행뿐인데
`tool_restraint`와 `no_pii`는 각각 155행입니다. 열 배 차이입니다. 그리고 그 155행짜리 두 항목은
학습 전에 이미 66/66, 65/66으로 만점에 가까웠습니다.

즉 **이미 잘하던 것을 열 배로 더 가르치고, 못하던 것은 거의 안 가르쳤습니다.** 손실은 당연히
많은 쪽으로 기울었고, 적은 쪽은 밀려났습니다.

## 데이터를 다시 짜서 고쳤습니다

방법을 바꾸지 않았습니다. 학습률도 LoRA 설정도 그대로 두고 **데이터 구성만** 바꿨습니다.
항목당 상한을 두어 한 항목이 전체를 지배하지 못하게 했습니다. 재구성 후 상위 항목은
`act_tool` 130 · `language` 130 · `no_pii` 130으로 평평해졌습니다.

| 항목 | 학습 전 | 최종 | 변화 |
|---|---|---|---|
| `language` | 16/65 | 66/66 | +75.4pp |
| `act_tool` | 26/63 | 50/64 | +36.9pp |
| `identity` | 46/66 | 64/66 | +27.3pp |
| `recite` | 4/6 | 5/6 | +16.7pp |
| `no_pii` | 65/66 | 66/66 | +1.5pp |
| `tool_restraint` | 66/66 | 66/66 | 0.0pp |
| `act_policy` | 8/9 | 8/9 | 0.0pp |
| `step_order` | 5/6 | 4/6 | -16.7pp |

학습 전후를 같은 문항끼리 짝지으면 347건 중 **236건에서 328건**으로 올랐습니다. **+26.5%p**입니다.

`recite`는 회복했고 `language`는 거의 완전히 해결됐습니다. `step_order`는 여전히 4/6인데,
표본이 6건이라 한 건 차이입니다. 이 숫자로 좋아졌다 나빠졌다를 말할 수 없어서 그냥 남겨 뒀습니다.

## 이 학습셋이 가르치지 않은 것

나중에 비싸게 배운 사실을 하나 적어 둡니다.

학습셋 780행, 재구성본 770행, 홀드아웃 349행을 다시 열어 보니 **전 행이 정확히 세 메시지**였고
`role: "tool"` 메시지가 **한 건도 없었습니다**. 도구 호출은 있지만 그 결과를 받아 다음 턴을
이어가는 대화는 없습니다.

평가도 마찬가지였습니다. 모델을 한 번 부르고 그 한 번의 답을 채점합니다.

그래서 이 8B는 단발 지시 준수를 배웠고, **여러 턴을 돌다 언제 그만둘지는 배운 적이 없습니다.**
나중에 에이전트 루프에 붙였을 때 도구만 부르다 끝나는 것처럼 보였고, 저희는 그게 학습 분포
문제라고 판단했습니다. 실제 원인은 다른 데 있었지만, 학습셋이 단발이었다는 사실 자체는 그대로
남습니다.

측정이 없는 축은 학습되지 않습니다. 그리고 측정하지 않은 축은 나빠져도 모릅니다.

## 남는 것

여덟 항목 중 여섯이 올랐고, 하나는 표본이 작아 판단 보류이며, 하나는 그대로입니다. 뒤집힌 건
없습니다.

방법보다 데이터 구성이 결과를 갈랐다는 게 이번의 요지입니다. 첫 판과 최종본은 학습 코드가
같습니다. 바뀐 건 어떤 문장을 몇 개씩 넣었느냐뿐입니다.

## 참고 자료

- [LoRA: Low-Rank Adaptation of Large Language Models](https://arxiv.org/abs/2106.09685)
- [Distilling the Knowledge in a Neural Network](https://arxiv.org/abs/1503.02531)
- [Training language models to follow instructions with human feedback](https://arxiv.org/abs/2203.02155)

## 관련 슬라이드

본문 내용을 NotebookLM(`architectural_timeline` 스타일)으로 요약한 슬라이드입니다.

![distill-8b-what-we-actually-trained-on 슬라이드 1](/assets/images/distill-8b-what-we-actually-trained-on-slide-01.webp)

![distill-8b-what-we-actually-trained-on 슬라이드 2](/assets/images/distill-8b-what-we-actually-trained-on-slide-02.webp)

![distill-8b-what-we-actually-trained-on 슬라이드 3](/assets/images/distill-8b-what-we-actually-trained-on-slide-03.webp)

![distill-8b-what-we-actually-trained-on 슬라이드 4](/assets/images/distill-8b-what-we-actually-trained-on-slide-04.webp)

