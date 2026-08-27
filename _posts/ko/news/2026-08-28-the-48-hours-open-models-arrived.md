---
title: "1위가 되고, 연기가 되고, 그 사이 창고는 주인을 바꿨다"
excerpt: "GLM-5.3-Flash가 OpenRouter 1위에 올랐던 48시간, Z.ai는 정식 웨이트 공개를 미뤘고 Nvidia는 129억 달러로 모델 창고의 소유권을 사들였습니다. 오픈 모델 시대의 경쟁은 성능이 아니라, 모델이 도착하는 경로 위에서 벌어지고 있습니다."
seo_title: "1위가 되고, 연기가 되고, 그 사이 창고는 주인을 바꿨다 - Thaki Cloud"
seo_description: "Z.ai GLM-5.3-Flash의 1위 등극과 정식 웨이트 연기, Unsloth의 3비트 GGUF, Qwen 6B 공개, Nvidia의 Hugging Face 129억 달러 인수 합의까지. 48시간의 시간표로 오픈 모델의 '도착 경로'가 왜 기업의 거버넌스 질문이 되는지 정리합니다."
date: 2026-08-28
last_modified_at: 2026-08-28
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "robot"
tags:
  - nvidia
  - hugging-face
  - open-models
  - glm-5-3
  - qwen
  - microduck
  - ai-distribution
  - llmops
categories:
  - news
audiobook: "https://drive.google.com/file/d/12_NqRe0Mo86EhF3rrojTOKZi6b9_CYc-/view"
audiobook_label: "▶ 5분 브리핑으로 듣기"
audiobook_note: "NotebookLM 오디오 개요 (AI 생성)"
---

오픈 모델을 서빙에 올리는 팀, 혹은 새 모델을 서빙 풀에 빠르게 편입하는 팀이라면 이번 주는 48시간이 유난히 길었을 것입니다. 봐야 할 곳은 모델의 성능이 아니라, 모델이 도착하는 경로인가. 1위 등극, 출시 연기, 129억 달러의 창고 매입이 같은 시간표 위에 겹쳤습니다. 그 경로는 이제 거버넌스의 질문이 됐습니다.

이 글은 그 48시간을 시간표 순서로 따라가는 것입니다. 수요일의 예고, 목요일의 1위와 연기, 그리고 그 사이 다른 스케일로 움직이던 구조적 사건들까지. 서로 다른 크기의 사건들이 왜 한 장의 시간표로 읽히는지를 마지막에 하나의 질문으로 모읍니다.

![1위가 되고, 연기가 되고, 그 사이 창고는 주인을 바꿨다 개념을 형상화한 이미지](/assets/images/the-48-hours-open-models-arrived-hero.webp)
*글의 핵심 개념을 형상화했습니다.*

## 수요일, '목요일'이라는 예고

GLM-5.3-Flash가 수요일부터 제3자 서비스에 등장하기 시작했습니다. Venice는 해당 모델을 비공개로 제공했습니다. Ollama는 아직 성능이 완전히 갖춰지지 않았다는 신중한 평가로 응답했습니다. 같은 날 Z.ai는 GLM-5.3-Flash 데뷔에 이어 목요일에 GLM-5.3 오픈 웨이트를 공개할 예정이라고 알렸습니다.

GLM-5.3-Flash는 정식 GLM-5.3 웨이트 공개에 앞서 등장한 변형입니다. Venice가 비공개로 먼저 받은 것은 정식 웨이트 전에 유료 경유가 시작됐다는 뜻입니다. Ollama의 신중함은 로컬 서빙 쪽이 첫 주자의 성능을 아직 확신하지 못했음을 보여줍니다. 두 반응 사이에서 수요는 이미 형성돼 있었고, 공개 일정만 기다리고 있었습니다.

변형부터 세상에 내보내는 공개 방식은 수요를 먼저 확인하고 웨이트를 올리는 전략입니다. 오픈 모델의 데뷔, 순위 경쟁, 정식 웨이트 공개가 한 줄로 묶인 주 중반의 풍경입니다.

## 목요일, 1위와 128GB의 3비트

GLM-5.3-Flash는 OpenRouter 1위에 올랐습니다. 과거 Ox Alpha라는 이름으로 미리보기됐던 모델입니다. OpenRouter는 여러 벤더의 모델을 한곳에서 비교하는 시장입니다. 플래그십 오픈 모델이 이 시장의 정상을 밟은 것은, 수요가 벤더 이름보다 모델 자체를 따라가고 있다는 증거입니다.

1위 등극 이후 Unsloth가 GGUF 파일을 공개했습니다. 3비트 형태면 128GB RAM 시스템에서도 구동된다고 밝혔습니다. GGUF 양자화 파일이 3비트까지 내려왔습니다. 이 모델을 돌릴 수 있는 머신의 범위는 GPU 서버에서 범용 RAM 시스템으로 넓어집니다. 플래그십급 오픈 모델이 서빙할 수 있는 범용 메모리에 들어오기 시작한 신호입니다. 128GB RAM은 고가의 GPU 서버가 아니라 범용 워크스테이션의 사양입니다. 서빙 노드가 되는 머신의 하한이 다시 내려온 것입니다.

같은 시간 Qwen도 풀에 들어왔습니다. 알리바바는 6B 모델을 오픈 소스로 공개하며 Qwen4 아키텍처의 첫 미리보기를 했습니다. 멀티모달 Qwen3.8-Flash는 OpenRouter와 Qwen Cloud에 올랐습니다. 오픈 웨이트인 Qwen3.8-Flash-Next도 함께 등장했습니다. 다음 세대 아키텍처가 6B 소형 공개와 함께 예고된 것입니다.

6B급 소형은 경량 태스크를 낮은 단가로 처리하는 서빙 노드 후보가 됩니다. 대형이 정상을 밟는 동안 소형은 하한을 낮춥니다. 같은 주 안에 풀의 상하단이 모두 넓어지는 움직임입니다. 경량 태스크를 낮은 단가로 처리할 서빙 노드 후보가 한 주에 두 개 늘어난 셈입니다.

## '목요일'은 오지 않았습니다

정식 웨이트는 오지 않았습니다. Z.ai는 내일 도착한다고 예고한 GLM-5.3 오픈 웨이트 공개를 연기했습니다. 파트너들이 출시 전 더 넓은 프레임워크 호환성을 요청하자 출시 일정을 조정했다고 밝혔습니다. 1위 경쟁이 한창이던 시점에 정작 서빙에 들어갈 무거운 자산이 제자리에 멈춘 셈입니다.

연기 사실 자체보다 중요한 것은 '출시'와 '도착' 사이의 지점입니다. 벤더가 공개를 발표한 시점과 실제 서빙 풀에 편입할 수 있는 시점 사이에 호환성 검증이라는 지름이 존재합니다. 호환성이 충분히 넓지 않으면 1위에 오른 모델이라도 서빙 풀에는 들어오지 못합니다. 순위와 편입은 별개의 절차입니다. 서빙 팀의 수용 기준은 벤더의 발표가 아니라, 호환성 확인과 안정화 점검의 결과로 세워야 합니다. 출시 일정에 맞춘 편입은 연기를 서비스 장애로 바꾸는 방식입니다.

Ollama가 첫 주자부터 신중했던 이유도 같은 지점을 가리킵니다. 성능이 완전히 갖춰지지 않은 모델을 서빙에 올리면 호환성 문제는 결국 지연이라는 형태로 되돌아옵니다. 신규 오픈 웨이트를 서빙에 올리기 전 프레임워크와 서빙 엔진의 호환성을 확인하는 절차가 이번 주는 처음으로 크게 보인 사례로 읽힙니다.

## 399달러의 오리가 도착한 밤

도착의 대상은 소프트웨어로만 한정되지 않았습니다. Hugging Face는 399달러의 Microduck를 첫 번째 접근 가능한 RL 로봇으로 공개했습니다. Pollen Robotics와 선전 소재 Seeed Studio와 함께 Physical AI 오픈 소스 플랫폼으로 개발했습니다. 크기는 신장 25cm, 무게 1.7lb입니다.

Thom Wolf는 사전 주문 개시 후 5초마다 1대씩 주문이 들어왔다고 밝혔습니다. 데뷔 수 시간 만에 매출은 100만 달러를 넘어섰습니다. 399달러의 가격표는 Physical AI가 연구실용에서 실사용으로 넘어오는 과정에서 실험 비용의 하한을 다시 쓰는 사건입니다. 주문 속도는 수요가 가격보다 먼저 도착했음을 보여줍니다.

'첫 번째 접근 가능한 RL 로봇'이라는 표현이 중요합니다. 강화학습 실험의 진입 비용이 연구실 예산에서 창업자 예산으로 내려온 것입니다. Microduck가 의미하는 것은 로봇이 아니라, Physical AI의 실험 진입 비용이 낮은 지점에 도착했다는 사실입니다. 에이전트 오케스트레이션이 소프트웨어 워크플로를 넘어 단말까지 넓어지는 흐름의 시작으로도 볼 수 있습니다.

## 창고를 사들인 129억 달러

이 시간표에서 가장 큰 사건은 따로 있습니다. Nvidia가 129억 달러에 Hugging Face 인수를 합의했습니다. 공개된 취지는 AI 분배(디스트리뷰션) 레이어의 소유입니다. Hugging Face가 경쟁 후보의 관심을 받은 뒤 칩 제조사인 Nvidia가 오픈 소스 모델 저장소 인수에 합의에 이르렀다는 설명입니다. 경쟁 후보의 관심을 받았다는 문구가 남는 대목입니다. 창고는 이미 여러 쪽에서 원하던 자산이었습니다. 사들인 쪽은 칩 회사였습니다.

Hugging Face는 이 시간표의 모든 모델이 오가는 주소입니다. GLM-5.3-Flash의 GGUF도, Qwen3.8-Flash-Next의 웨이트도, Microduck의 플랫폼도 같은 창고에서 시작합니다. 창고의 소유자가 바뀌면 이 주에 벌어진 사건의 다음 장이 하나의 지점과 연결됩니다.

모델이 올라가는 창고를, 모델을 돌리는 칩을 파는 회사가 사들인 것입니다. 1위 경쟁과 출시 연기가 벌어진 바로 그 무대의 소유권이, 그 무대 위를 뛰던 모델보다 먼저 이동했습니다. 모델 저장소가 어디에 붙어 있는가에 따라 새 모델이 어떤 생태계에서 먼저 서빙되는지가 정해집니다.

분배 레이어의 집중이 의미하는 것은 명확합니다. 이후 모든 모델의 도착 경로가 하나의 지점과 더 강하게 연결된다는 사실입니다. 폐쇄망으로 운영하는 기업에는 더 직접적인 질문이 남습니다. 모델이 도착하는 경로가 한 지점에 집중될 때 그 경로가 막히면 서빙 풀 전체가 멈추는 구조인지 점검할 때가 왔습니다.

## 돈은 같은 방향으로 흘렀습니다

자본도 같은 주에 같은 방향으로 움직였습니다. Anthropic은 1.5조 달러 규모의 IPO를 계획하고 있습니다. 증권서는 노동절 이후에 공개합니다. 9월 말부터 10월 초 상장을 목표로 합니다. 주주들이 지분을 매도하도록 허용할 수도 있다는 설명이 함께 나왔습니다.

IPO가 성사되면 프런티어 벤더의 공급 구조는 자본 시장 일정에 더 강하게 연동됩니다. 증권서 공개 이후의 가격과 공급 조건 재조정은 서빙 풀을 운영하는 쪽에서 점검해야 할 변수입니다. 상장 이후 벤더의 가격 정책과 공급 조건은 자본 시장의 기대를 업고 움직일 수 있습니다. 서빙 비용은 그 움직임을 그대로 받습니다. 토큰 단가 변동에 대비한 자체 인퍼런스 서빙 투자의 기준을 점검할 시점입니다.

Meta는 내부 AI 개발 지연을 만회하기 위해 경쟁사 Anthropic의 모델에 연간 최대 100억 달러를 지출할 수 있다는 내부 전망을 갖고 있습니다. 자사 모델 대신 경쟁 모델을 대량으로 사는 구조입니다. 벤더 의존의 다른 얼굴이 내부 전망의 언어로 쓰여 있는 것입니다. 100억 달러 단위의 지출 이동은, 모델 선택이 이제 연 단위의 예산 문제라는 뜻입니다.

Micron은 미국의 AI 랩에 100억 달러를 투자하며 2500억 달러 규모의 미국 내 투자 공약을 확장합니다. 도널드 트럼프 대통령은 Micron이 전국 각지에 AI와 첨단 컴퓨팅 시설을 건설한다고 밝혔습니다. 칩 공급 증원은 장기적으로 인퍼런스 인프라의 단가를 누르는 배경이 됩니다.

칩, 모델, 분배, 단말이 같은 주에 움직였습니다. 돈은 그 방향을 모두 지나는 경로였습니다.

## 정리, 모델이 도착하는 길을 설계할 때

이번 주가 드러낸 통증은 모두 '도착 경로' 위에 있습니다. 호환성이 확인되기 전에는 서빙 풀에 넣을 수 없는 신규 오픈 모델, 분배 레이어가 단일 회사로 기울어지는 공급 구조, 100억 달러 단위로 움직이는 벤더 간 지출, 그리고 폐쇄망 안에서 모델을 받아들이는 주권 문제입니다. 네 가지는 서로 다른 뉴스처럼 보이지만 같은 지점을 가리킵니다. 모델이 어디에서, 어떤 검증으로, 어떤 경로로 서빙에 도달하는가. 그 질문에 답하는 방식이 다음 오픈 모델 주를 겪는 길이의 차이를 만드는 것이다.

Paxis는 ThakiCloud의 에이전트 네이티브 클라우드이며 정식 제품(v1.1 GA)입니다. 모델이 도착하는 경로를 플랫폼으로 묶었습니다. Skills, Tools, Policies, Audit Logs는 여기서 일급 리소스입니다. 모델 정책은 특정 벤더의 출시 일정에 연동하지 않는 셈입니다. 호환성과 안정화가 확인된 시점에 모델을 수용하도록 정합니다. 새 오픈 웨이트는 격리 샌드박스에서 평가한 뒤 정책 게이트를 거쳐 서빙 풀에 들어옵니다. 수용 결정은 감사 로그에 남습니다.

Nvidia-HF 합의가 보여주는 분배 레이어의 집중에는 온프레미스 K8s 기반의 자체 서빙과 로컬 모델 유통 경로가 대응합니다. 주권 문제가 현실이 되는 폐쇄망에서는 모델 공급 경로가 한 지점에 단절되지 않도록 로컬 모델 유통과 검수 절차를 갖추는 가치가 커집니다. GLM-5.3-Flash 3비트와 Qwen 6B처럼 경량 후보가 풀에 늘어난 환경에서는 작업별로 모델을 고르는 CostRouter가 실행 비용과 지연을 낮추는 쪽으로 작용합니다. 프런티어 벤더의 몸값이 1.5조 달러로 불어나는 시장에서는 멀티모델 라우팅으로 공급을 분산하는 정책의 가중이 더 커집니다.

예측은 단순합니다. 분배 레이어의 소유권이 이동할수록 모델의 도착 경로를 자체 거버넌스로 설계한 기업이 다음 48시간을 더 짧게 겪을 것입니다.

## 참고 자료

이 글은 아래 뉴스를 종합해 작성했습니다.

- HuggingNews, [Unsloth Releases 3 Bit GLM-5.3-Flash for 128GB RAM After Reaching No. 1 on OpenRouter](https://huggingnews.com/ai/update-unsloth-releases-3-bit-glm-53-flash-for-128gb-ram-after-reaching-7cea2e2d)
- HuggingNews, [Z.ai to Release GLM-5.3 Weights Thursday After GLM-5.3-Flash Debut](https://huggingnews.com/ai/zai-to-release-glm-53-weights-thursday-after-glm-53-flash-debut-400790de)
- HuggingNews, [Alibaba Qwen Open Sources 6B Active Model as First Preview of Qwen4 Architecture](https://huggingnews.com/ai/alibaba-qwen-open-sources-6b-active-model-as-first-preview-of-qwen4-arch-1add460b)
- HuggingNews, [Z.ai Delays GLM-5.3 Open Weights After Saying They Would Arrive Tomorrow](https://huggingnews.com/ai/update-zai-delays-glm-53-open-weights-after-saying-they-would-arrive-tom-c51fd505)
- HuggingNews, [Hugging Face's $399 Microduck Tops $1M in Sales Hours After Debut](https://huggingnews.com/ai/update-hugging-faces-399-microduck-tops-1m-in-sales-hours-after-debut-93ed5cca)
- HuggingNews, [Hugging Face Unveils $399 Microduck as First Accessible RL Robot](https://huggingnews.com/ai/hugging-face-unveils-399-microduck-as-first-accessible-rl-robot-7f562f80)
- HuggingNews, [Anthropic Plans $1.5 Trillion IPO and May Let Shareholders Sell Shares](https://huggingnews.com/ai/anthropic-plans-15-trillion-ipo-and-may-let-shareholders-sell-shares-7150e951)
- HuggingNews, [Meta Projects $10B Annual Spend on Rival Anthropic to Offset Internal AI Delay](https://huggingnews.com/ai/meta-projects-10b-annual-spend-on-rival-anthropic-to-offset-internal-ai-12e18671)
- HuggingNews, [Micron Invests $10B in US AI Labs, Expanding $250B Domestic Commitment](https://huggingnews.com/ai/micron-invests-10b-in-us-ai-labs-expanding-250b-domestic-commitment-8f67da09)
- HuggingNews, [Nvidia Agrees to Buy Hugging Face for $12.9B to Own AI Distribution Layer](https://huggingnews.com/ai/update-nvidia-agrees-to-buy-hugging-face-for-129b-to-own-ai-distribution-6fddbbc8)

