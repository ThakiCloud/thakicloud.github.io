---
title: "토큰에 피크 요금이 붙었습니다: AI 추론이 전력 시장을 닮아가는 중"
excerpt: "DeepSeek이 8월 16일부터 시간대별 API 요금을 도입합니다. 같은 날 뉴스에는 가격 반토막, 9년 된 GPU 장기 계약, 50억 달러 채권이 나란히 올라왔습니다. 다 합쳐 놓고 보면 AI 추론 시장은 전력 시장의 요금 구조를 그대로 밟아가는 중입니다."
seo_title: "AI 추론 가격, 전력 시장을 닮아간다: DeepSeek 피크 요금제와 오늘의 신호들"
seo_description: "DeepSeek의 첫 시간대별 API 요금, Gemini 3.7 Flash 가격 인하, CoreWeave의 2029년 A100 계약을 하나의 렌즈로 읽습니다. 추론 비용을 전력 요금처럼 다루는 팀이 무엇을 준비해야 하는지 정리했습니다."
date: 2026-08-14
last_modified_at: 2026-08-14
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "robot"
tags:
  - ai-frontier
  - llmops
  - paxis
  - thakicloud
categories:
  - news
audiobook: "https://drive.google.com/file/d/1skMuthyMyPlyVjezZT7oLlgB4LHM_zA7/view"
audiobook_label: "▶ 5분 브리핑으로 듣기"
audiobook_note: "NotebookLM 오디오 개요 (AI 생성)"
---

AI 추론에 매달 돈을 쓰는 팀이라면 이번 주부터 요금표를 읽는 방법을 새로 배워야 합니다. DeepSeek이 8월 16일 16시(UTC)부터 V4 라인업 API에 피크와 오프피크 요금을 나눠 적용하면서, 토큰 가격이 모델마다 하나씩 붙은 정가가 아니라 시간에 따라 움직이는 값이 되기 시작했기 때문입니다.

![토큰에 피크 요금이 붙었습니다: AI 추론이 전력 시장을 닮아가는 중 개념을 형상화한 이미지](/assets/images/token-peak-pricing-power-market-hero.webp)
*글의 핵심 개념을 형상화했습니다.*

## 요금표에 시간이 들어왔습니다

DeepSeek의 변경 자체는 짧게 요약됩니다. V4 라인업 요금이 피크와 오프피크로 갈리고, V4 Pro의 피크 시간대 출력 비용은 3.96달러로 오릅니다. 숫자만 보면 인상 공지 한 건이지만, 구조를 보면 성격이 다릅니다. 지금까지 대형 모델 API의 가격표는 모델 이름 옆에 입력가와 출력가가 하나씩 적힌 표였습니다. 시간대를 나눈다는 것은 공급자가 자기 클러스터의 부하 곡선을 고객에게 그대로 공개했다는 뜻입니다.

전력회사가 계시별 요금제를 쓰는 이유와 정확히 같습니다. 발전 설비는 연중 최대 수요에 맞춰 지어야 하고, 그 설비는 새벽 세 시에도 똑같이 감가상각됩니다. 그래서 수요가 몰리는 시간에는 비싸게 받고 한가한 시간에는 싸게 받아 부하를 평탄하게 만듭니다. GPU 클러스터도 같은 물리 법칙 아래 있습니다. 다만 지금까지는 그 사정을 공급자가 혼자 삼키고 평균 단가에 녹여 왔을 뿐입니다.

## 성능은 수렴하고 가격만 벌어집니다

같은 날 올라온 다른 소식들이 이 변화의 배경을 설명해 줍니다. 구글은 Gemini 3.7 Flash를 내놓으면서 입력 100만 토큰당 0.75달러, 출력 100만 토큰당 3.75달러라는 도입가를 붙였습니다. 직전 모델을 낸 지 3주 만이고, 겨냥한 용도는 소프트웨어 엔지니어링입니다. 공교롭게도 DeepSeek의 피크 출력가와 구글의 출력가는 3달러 후반대에서 만납니다. 한쪽은 올리고 한쪽은 내렸는데 도착지가 비슷하다는 점이 지금 시장의 온도를 보여줍니다.

가격 격차가 성능 격차보다 훨씬 크다는 사실도 같은 날 확인됐습니다. Perplexity가 추가한 Grok 4.6은 Code Arena의 WebDev 부문에서 1,630점으로 5위에 올랐습니다. 바로 아래가 Claude Fable 5의 1,627점이고 그다음이 GPT-5.6 Sol xHigh의 1,622점입니다. 세 모델의 점수 차이는 8점 안에 들어옵니다. 그런데 Grok 4.6은 그 성능을 60% 낮은 비용으로 낸다고 소개됐습니다. 성능 3점 차이와 비용 60% 차이 중 구매 결정을 흔드는 쪽이 무엇인지는 굳이 따질 필요가 없겠지요.

구매자 입장에서 이 흐름의 실익은 협상력입니다. 상위권 모델이 8점 안에 몰려 있다면 특정 공급자에 묶일 이유가 줄어듭니다. 반대로 위험도 같이 커집니다. 코딩 어시스턴트를 특정 모델의 응답 습관에 맞춰 프롬프트와 후처리까지 다듬어 놓았다면, 60% 싼 대안이 나와도 갈아타는 데 몇 주가 걸립니다. 순위표가 분기마다 흔들리는 시장에서는 어느 모델이 최고인지보다 모델을 얼마나 빨리 바꿔 낄 수 있는지가 실제 비용을 가릅니다.

전력을 쓰는 사람은 콘센트에서 나온 전자가 어느 발전소에서 왔는지 구분하지 못합니다. 구분되는 것은 단가와 안정성뿐입니다. 코딩 벤치마크 상위권이 8점 안에 모여 있다는 것은 추론도 그 지점을 향해 가고 있다는 신호로 읽힙니다.

## 2020년에 만든 설비가 2029년까지 돕니다

상품화된 시장에서는 오래된 설비의 운명이 달라집니다. CoreWeave가 2020년에 나온 Nvidia A100에 대해 2029년까지 이어지는 다년 계약을 맺었다는 소식이 그 사례입니다. 통상적인 감가상각 주기를 훌쩍 넘겨 매출을 만드는 하드웨어인 셈입니다. 초기 AI 하드웨어는 곧 쓸모없어진다는 이야기가 반복돼 왔는데, 계약서 한 장이 그 서사를 뒤집었습니다.

전력망에서도 오래된 발전소가 사라지지 않습니다. 최신 고효율 설비는 값이 비싼 시간대와 까다로운 부하에 배치하고, 낡은 설비는 값싸고 꾸준한 기저 부하를 담당합니다. 추론 워크로드도 똑같이 계층화할 수 있습니다. 최신 가속기는 지연에 민감한 대화형 트래픽과 대형 모델에 쓰고, 이전 세대는 야간 배치와 임베딩 생성처럼 시간을 다투지 않는 작업에 붙이면 됩니다. 세대별 플릿을 워크로드 성격에 맞춰 배치하는 운영 능력이 곧 자산 회수 기간을 늘리는 지렛대가 됩니다. 이 계산은 인프라를 직접 굴리는 쪽에만 해당하지 않습니다. 서비스를 사서 쓰는 쪽도 마찬가지여서, 모든 작업에 최신 세대를 요구하는 계약은 필요 없는 프리미엄을 매달 내는 구조가 됩니다. 어떤 작업이 구세대 가속기로 충분한지 아는 팀이 같은 예산으로 더 많은 일을 돌립니다.

## 설비를 짓는 돈이 결국 요금표로 돌아옵니다

자본 쪽 신호도 같은 방향입니다. AMD는 AI 분야 성장과 일반 운영 자금을 위해 50억 달러 규모 채권 발행을 신청했습니다. 회사 역사상 최대 규모가 될 가능성이 있는 조달입니다. Databricks는 50억 달러를 유치해 기업가치 1,900억 달러에 도달했고, 연 매출 런레이트 70억 달러를 넘긴 뒤의 조달이라 2월 대비 42% 상승한 값입니다.

주식이 아니라 채권으로 돈을 조달한다는 것은 수요 예측에 대한 자신감의 표현입니다. 동시에 그 이자는 언젠가 원가에 반영됩니다. 전력이 자본집약 산업인 이유가 발전소 건설비 때문이듯, AI 인프라도 같은 재무 구조로 옮겨가고 있습니다. 그렇게 지어진 설비의 회수 압박이 결국 시간대별 요금 같은 형태로 사용자 앞에 나타납니다.

## 자가발전이라는 선택지가 자라고 있습니다

그리드에만 의존하지 않는 길도 넓어졌습니다. Nvidia는 에이전트 작업에서 Claude Sonnet 5를 능가하는 것을 목표로 한 Nemotron 3.5 Lightning 30B를 공개했습니다. 오픈 웨이트 MoE 구조이고, 사이버보안과 금융 분야의 자율 워크플로를 대량으로 실행하는 용도를 겨냥합니다. Alibaba도 8월 13일 Hugging Face에 Qwen 3.8-27B 사전 공개 페이지를 올리며 새 패밀리의 두 번째 모델을 예고했습니다.

30B 안팎이라는 크기가 중요합니다. 자체 인프라에 올릴 수 있는 규모이기 때문입니다. 공장이 자가발전 설비를 두는 이유가 전기를 더 싸게 만들기 위해서만은 아닙니다. 그리드 요금이 출렁일 때 헤지가 되고, 정전이 나도 라인이 멈추지 않기 때문입니다. 같은 날 Grok 4.6 출시 과정에서 다수 사용자가 이용 한도에 걸려 SpaceXAI가 한도를 리셋해야 했다는 소식은 이 비유가 과장이 아님을 보여줍니다. 외부 공급에 전량을 걸어 두면, 남들이 다 몰리는 그 시각에 내 워크플로가 함께 멈춥니다.

## 변동 요금은 예산 짜는 방식을 바꿉니다

시간대별 요금이 자리를 잡으면 곤란해지는 쪽은 재무입니다. 단가가 하나일 때는 월 토큰 사용량에 숫자 하나를 곱하면 예산이 나왔습니다. 피크와 오프피크가 갈리면 같은 사용량도 언제 썼느냐에 따라 청구서가 달라집니다. 사용량 관리에서 사용 시각 관리로 관심사가 한 칸 이동하는 셈입니다.

이 변화는 조직 안에서 낯익은 문제를 하나 다시 꺼냅니다. 누가 언제 얼마를 썼는지 팀 단위로 갈라 볼 수 있느냐는 질문입니다. 총액만 보이는 대시보드로는 어느 작업을 심야로 옮겨야 절감이 되는지 알 수 없습니다. 반대로 실행 단위마다 모델과 시각과 토큰이 기록으로 남아 있으면, 요금표가 바뀔 때마다 옮길 후보가 바로 눈에 들어옵니다. 계량기 없이 절전 계획을 세울 수 없다는 이야기와 같습니다.

## 그래서 쓰는 쪽은 부하를 옮길 수 있어야 합니다

전력 요금제가 계시별로 바뀌면 대형 수용가는 부하 이동부터 검토합니다. 미룰 수 있는 공정을 심야로 옮기고, 못 미루는 공정은 그대로 두고, 정전에 대비해 자가발전을 켭니다. 추론도 다르지 않습니다. 야간 리포트 생성, 대량 문서 분류, 회귀 평가 배치는 오프피크로 미뤄도 아무도 불편하지 않습니다. 반대로 고객 응대나 코딩 어시스턴트는 초 단위로 급합니다.

분류 기준도 어렵지 않습니다. 사람이 화면 앞에서 기다리는 작업인지, 결과가 다음 근무일 아침에만 있으면 되는 작업인지 두 갈래로 나누는 것으로 시작하면 충분합니다. 후자에 속한 작업이 전체 토큰의 절반을 넘는 조직이 생각보다 많습니다.

문제는 이 구분을 할 수 있으려면 에이전트의 작업이 관리 가능한 대상으로 존재해야 한다는 점입니다. 프롬프트가 코드 안에 흩어져 있고 어떤 호출이 어느 모델로 나갔는지 사후에 알 수 없다면, 요금표가 아무리 정교해져도 대응할 방법이 없습니다. ThakiCloud의 Paxis가 Skills와 Tools, Policies, Audit Logs를 일급 리소스로 다루는 이유가 여기에 있습니다. 작업이 이름을 가진 자원이면 작업별로 모델을 고를 수 있고, CostRouter가 성격에 맞는 티어로 보낼 수 있으며, 감사 로그가 어떤 실행이 언제 얼마를 썼는지 되짚어 줍니다. 규제 산업 고객이라면 소버린 환경이나 온프렘 쿠버네티스 위에 오픈 웨이트 모델을 올려 자가발전 축을 함께 세울 수도 있습니다.

가격만 문제인 것도 아닙니다. OpenAI가 1년 사이 두 번째 최고수익책임자로 사이버보안 기업 Wiz 출신의 Dali Rajic을 앉힌 인사는, 엔터프라이즈 판매에서 보안과 감사 신뢰가 단가만큼 무겁게 다뤄진다는 사실을 보여줍니다. 자율도를 단계로 나누고 위험한 작업에 정책 게이트와 사람 승인을 거는 설계, 격리된 샌드박스에서 도구를 실행하는 구조가 필요한 이유도 같습니다. 싸게 돌리는 것과 안심하고 돌리는 것은 별개의 문제라서, 둘을 한 플랫폼에서 함께 다룰 수 있어야 도입이 진행됩니다.

## 요금표를 읽는 사람이 남습니다

오늘의 뉴스를 하나씩 떼어 놓으면 가격 조정, 신모델, 계약, 조달 같은 평범한 항목들입니다. 겹쳐 놓으면 하나의 그림이 나옵니다. 설비는 자본으로 지어지고, 낡은 설비는 기저 부하로 남으며, 단가는 시간에 따라 갈리고, 큰 수용가는 자가발전을 함께 갖춥니다. 전력 산업이 백 년에 걸쳐 만든 구조를 AI 추론은 몇 분기 만에 밟아가고 있습니다.

준비할 것은 의외로 단순합니다. 우리 워크로드 중 무엇이 지연을 견디는지 목록으로 만들어 두는 일부터 시작하면 됩니다. 그 목록이 있으면 다음에 어떤 공급자가 요금표를 바꾸든 옮길 곳이 보입니다. 목록이 없으면 평균 단가 인상을 그대로 맞게 됩니다. 요금표는 앞으로 더 자주, 더 복잡하게 바뀔 겁니다. 오늘 한 시간을 들여 만든 그 목록이 다음 분기 청구서에서 답을 합니다.

## 참고 자료

이 글은 아래 뉴스를 종합해 작성했습니다.

- HuggingNews, [DeepSeek Raises V4 Pro Peak Price to $3.96 in First Dynamic Pricing Shift](https://huggingnews.com/ai/deepseek-raises-v4-pro-peak-price-to-396-in-first-dynamic-pricing-shift-d1ac7031)
- HuggingNews, [Perplexity Adds Grok 4.6 With Fable 5 Benchmark Match at 60% Lower Cost](https://huggingnews.com/ai/perplexity-adds-grok-46-with-fable-5-benchmark-match-at-60percent-lower-1b519991)
- HuggingNews, [Nvidia Launches Nemotron 3.5 Lightning 30B Model to Outperform Claude Sonnet 5 on Agentic Tasks](https://huggingnews.com/ai/nvidia-launches-nemotron-35-lightning-30b-model-to-outperform-claude-son-3fc994d0)
- HuggingNews, [SpaceXAI Resets Grok Limits After Users Hit Caps During 4.6 Launch](https://huggingnews.com/ai/update-spacexai-resets-grok-limits-after-users-hit-caps-during-46-launch-7d5d2595)
- HuggingNews, [Google Halves Gemini Flash Price with 3.7 Model 3 Weeks After Prior Release](https://huggingnews.com/ai/google-halves-gemini-flash-price-with-37-model-3-weeks-after-prior-relea-da423822)
- HuggingNews, [OpenAI Hires Dali Rajic as 2nd CRO in Year to Bolster IPO Growth](https://huggingnews.com/ai/openai-hires-dali-rajic-as-2nd-cro-in-year-to-bolster-ipo-growth-b05ee859)
- HuggingNews, [CoreWeave Signs A100 Contract Through 2029, Reversing Short Lived Chip Narrative](https://huggingnews.com/ai/coreweave-signs-a100-contract-through-2029-reversing-short-lived-chip-na-640d676c)
- HuggingNews, [Alibaba Launches Qwen 3.8-27B Pre Release Page, second model in Qwen 3.8 record rollout](https://huggingnews.com/ai/update-alibaba-launches-qwen-38-27b-pre-release-page-second-model-in-qwe-9d3eee9a)
- HuggingNews, [Databricks Reaches $190 Billion Valuation in $5 Billion Raise After Crossing $7 Billion Revenue Run](https://huggingnews.com/ai/databricks-reaches-190-billion-valuation-in-5-billion-raise-after-crossi-8668dd12)
- HuggingNews, [AMD Plans $5 Billion Debt Offering for Potentially Largest Sale Ever](https://huggingnews.com/ai/amd-plans-5-billion-debt-offering-for-potentially-largest-sale-ever-22bb964a)

