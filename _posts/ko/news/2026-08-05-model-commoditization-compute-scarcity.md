---
title: "모델은 공짜가 되는데, 컴퓨팅은 왜 360억 달러를 빌리나"
excerpt: "같은 날 최상급 모델이 무료로 풀리고 컴퓨팅에는 수백억 달러가 몰렸습니다. 사내 AI를 운영하는 팀에게 이 대비는 해자가 모델에서 인프라로 옮겨갔다는 신호입니다."
seo_title: "오픈 가중치 시대의 진짜 희소재, 컴퓨팅과 거버넌스"
seo_description: "알리바바 2.4조 파라미터 무료 공개와 DeepSeek 초저가 API, 그리고 앤트로픽 100억 달러 컴퓨팅 계약이 같은 날 나온 이유를 분석합니다."
date: 2026-08-05
last_modified_at: 2026-08-05
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "robot"
tags:
  - ai-frontier
  - llmops
  - gpu
  - sovereign-ai
  - paxis
categories:
  - news
audiobook: "https://drive.google.com/file/d/1yzEyKpM0pXoCr9tgFnbcyH2KTYHj0nK6/view"
audiobook_label: "▶ 5분 브리핑으로 듣기"
audiobook_note: "NotebookLM 오디오 개요 (AI 생성)"
---

H200 몇 장으로 사내 AI를 굴리는 팀이라면 이번 주 뉴스에서 한 가지 결론만 챙기면 됩니다. 최상급 모델을 손에 넣는 일은 점점 공짜에 가까워지지만, 그 모델을 실제로 자기 인프라에서 값싸고 안전하게 돌리는 능력은 오히려 더 비싸지고 희소해졌다는 것입니다. 모델이 흔해질수록 경쟁의 무게중심은 "무엇을 쓰느냐"에서 "어디서 어떻게 돌리느냐"로 넘어갑니다.

이 대비는 추상적인 이야기가 아닙니다. 같은 날 알리바바는 2.4조 파라미터짜리 최상급 모델을 다음 주 무료로 풀겠다고 발표했고, 앤트로픽은 컴퓨팅을 확보하려고 100억 달러짜리 계약서에 서명했습니다. 모델은 내려가고 컴퓨팅은 올라가는 이 어긋남 속에 사내 AI 전략의 실마리가 들어 있습니다.

![모델은 공짜가 되는데, 컴퓨팅은 왜 360억 달러를 빌리나 개념을 형상화한 이미지](/assets/images/model-commoditization-compute-scarcity-hero.png)
*글의 핵심 개념을 형상화했습니다.*

## 하루 사이에 벌어진 두 장면

첫 번째 장면은 모델 쪽입니다. 알리바바는 파라미터 2.4조 개의 Qwen3.8-Max를 공개하며 OpenAI, 앤트로픽의 선두 모델과 경쟁하겠다고 밝혔고, 가중치를 다음 주 무료로 배포하겠다고 예고했습니다. 여기에 DeepSeek은 코딩과 에이전트용 V4 Flash를 백만 토큰당 0.14달러라는 업계 최저가로 내놨습니다. 수요가 몰려 서버 용량 장애까지 났다는 사실이 역설적으로 이 가격의 파괴력을 증명합니다. 며칠 전만 해도 프런티어급 성능은 소수의 폐쇄 API에 갇혀 있었는데, 이제는 무료 가중치와 사실상 원가에 가까운 토큰 값으로 풀리고 있습니다.

두 번째 장면은 정반대 방향입니다. 앤트로픽은 엔비디아가 지원하는 신생 인프라 사업자 Volta와 6년간 100억 달러 규모로 컴퓨팅을 확보하는 계약을 맺었고, 블랙스톤은 커스텀 AI 칩 사용 자금을 대려고 최소 360억 달러 규모의 두 번째 부채 패키지를 논의하고 있습니다. 직전의 350억 달러 규모를 넘어서는 액수입니다. 모델을 공짜로 나눠주는 세상에서, 정작 그 모델을 굴릴 연산에는 국가 예산급 자본이 빨려 들어가고 있습니다.

<!-- nlm-visual -->
![핵심 개념 요약 인포그래픽 1](/assets/images/posts/news/model-commoditization-compute-scarcity/nlm-infographic-1.png)
*NotebookLM이 소스를 종합해 생성한 인포그래픽입니다.*

## 희소재가 모델에서 컴퓨팅으로 옮겨갔다

두 장면을 나란히 놓으면 질문이 분명해집니다. 모델이 무료가 되는데 왜 컴퓨팅에는 수백억 달러를 빌리는가. 답은 희소성의 위치가 바뀌었기 때문입니다. 가중치는 복제 비용이 0에 수렴하지만, 그 가중치를 초당 수천 건의 요청으로 서빙하는 GPU와 전력은 복제되지 않습니다. 모델이 상품이 될수록 진짜 병목은 연산 그 자체로 이동합니다.

이 이동은 이미 물리적, 지정학적 형태로 드러나고 있습니다. SpaceX와 엔비디아는 궤도 위에 250kW급 전력을 감당하는 Starmind AI1 컴퓨팅 페이로드를 올려 최초의 궤도 데이터센터를 겨냥합니다. 지상의 전력과 부지가 한계에 부딪히자 우주까지 후보지에 오른 셈입니다. 한편 트럼프 행정부는 AI 데이터센터용 중국산 광트랜시버의 신규 수입을 올해 안에 막는 연방 규정을 준비하고 있습니다. 데이터센터를 잇는 네트워크 부품 하나까지 국가 안보 사안으로 취급된다는 뜻입니다. 컴퓨팅이 자본을 넘어 지정학의 대상이 되면, 어디에 어떤 하드웨어로 인프라를 세우느냐가 곧 리스크 관리가 됩니다.

부품 하나가 규제 대상이 된다는 사실은 인프라 계획을 세우는 팀에게 남의 일이 아닙니다. 광트랜시버 같은 네트워크 부품의 공급망 규제는 데이터센터 구축 비용과 일정에 직접적인 리스크로 작동합니다. GPU 확보에만 집중하다 보면 정작 그 GPU를 잇는 부품에서 병목이 생길 수 있다는 뜻입니다. 컴퓨팅이 자본과 지정학의 교차점에 놓인 지금, 클라우드 사업자든 사내 인프라 팀이든 하드웨어 조달 계획에 규제 변수를 미리 반영해 두는 편이 안전합니다.

## 공짜 모델의 청구서는 서빙에서 날아온다

여기서 사내 AI 팀이 마주하는 현실적인 함정이 생깁니다. 무료 가중치와 초저가 API를 보면 비용 문제가 풀린 것 같지만, 실제 청구서는 모델 값이 아니라 서빙에서 날아옵니다. DeepSeek의 초저가 API에 수요가 몰려 서버가 마비된 사건은 남의 인프라에 얹은 워크로드가 언제든 통제 밖으로 벗어날 수 있다는 경고입니다. 2.4조 파라미터급 오픈 모델을 실제로 온프렘에서 돌리려면 멀티노드 서빙, 정밀한 GPU 스케줄링, 모델별 비용과 성능의 재평가가 동시에 필요합니다.

바로 이 지점에서 오픈 가중치의 홍수는 부담이 아니라 기회로 뒤집힙니다. 성능 좋은 모델이 여러 개 무료로 풀린다는 것은, 작업마다 가장 값싸고 알맞은 모델을 골라 자기 인프라에서 돌릴 선택지가 늘어난다는 뜻이기 때문입니다. 관건은 그 선택을 자동화하고, 한정된 GPU를 워크로드 사이에 공정하게 배분하며, 남는 용량을 놀리지 않는 운영 역량입니다. 초저가 API가 비용 기준선을 끌어내릴수록, 사내 워크로드를 프라이빗 서빙으로 되가져올 때의 손익 계산은 오히려 더 정교해져야 합니다.

## 벤치마크가 많아질수록 선택은 어려워진다

선택지가 늘었다는 말은 곧 선택이 어려워졌다는 말이기도 합니다. 같은 날 알리바바는 Qwen3.8-Max를 Hermes Agent 플랫폼에 통합해 프런트엔드 코드 아레나에서 1,668점으로 4위를 기록했다고 밝혔습니다. 최상급이 아니라 4위라는 점이 오히려 중요합니다. 이제 현장의 질문은 "가장 똑똑한 모델이 무엇인가"가 아니라 "이 작업에 4위 모델이면 충분한가, 그래서 얼마를 아끼는가"로 바뀌었기 때문입니다. 엔비디아가 같은 날 내놓은 자율주행용 추론 모델 Alpamayo 2 Super가 340억 파라미터에 그친 것도 같은 흐름입니다. 도메인이 분명하면 초거대 모델이 아니라 중형 특화 모델이 정답일 때가 많습니다.

이 다양성은 운영자에게 두 가지 숙제를 안깁니다. 첫째, 각 모델이 우리 작업에서 실제로 몇 점을 내는지 자체 eval 하네스로 검증해야 합니다. 공개 아레나 점수는 출발점일 뿐 우리 데이터에서의 성능을 보장하지 않기 때문입니다. 둘째, 그 검증 결과를 바탕으로 작업마다 모델을 자동으로 갈아끼우는 라우팅이 필요합니다. 단순 요청은 값싼 오픈 모델로 흘리고 어려운 판단만 상위 모델에 남기면, 같은 결과를 훨씬 낮은 비용으로 얻을 수 있습니다. 모델이 흔해진 시대의 경쟁력은 최고 모델을 쓰는 것이 아니라, 작업마다 최적 모델을 값싸게 배치하는 판단에서 나옵니다.

## 규제와 유출이 더한 세 번째 축

컴퓨팅만 조여드는 것이 아닙니다. 거버넌스라는 세 번째 축도 같은 주에 무거워졌습니다. EU는 AI법의 투명성 의무 집행을 시작하며 AI 사무국에 전 세계 매출의 최대 3%까지 과징금을 물릴 권한을 부여했습니다. 딥페이크 라벨링 같은 의무가 이제 권고가 아니라 처벌 가능한 규칙이 됐다는 의미입니다. 여기에 애플은 전 직원 14명을 통해 수천 페이지의 하드웨어 기밀이 OpenAI로 유출됐다며 긴급 가처분을 신청했습니다. 모델과 인프라 기술이 사람을 따라 빠져나가는 리스크가 법정 다툼으로 번진 사례입니다.

규제 집행과 기술 유출은 서로 다른 사건처럼 보이지만, 사내 AI 운영자에게는 같은 요구로 수렴합니다. 무엇이 어떤 정책 아래 실행됐고 누가 어떤 데이터에 접근했는지를 사후에 증명할 수 있어야 한다는 것입니다. 모델을 어디서 돌리는지에 대한 통제, 실행 하나하나에 대한 감사 로그, 접근 권한의 최소화가 규제와 보안 양쪽에서 동시에 방어선이 됩니다.

## 그래서 무엇을 준비하나

이번 주 뉴스를 한 줄로 요약하면, 모델은 상품이 되고 차별화는 운영으로 내려왔다는 것입니다. 무료 가중치를 자기 인프라에서 값싸게 돌리는 능력, 한정된 GPU를 낭비 없이 배분하는 스케줄링, 그리고 실행을 정책과 감사로 통제하는 거버넌스가 앞으로의 해자입니다.

ThakiCloud가 Paxis와 ai-platform을 이 세 축 위에 세운 이유가 여기 있습니다. Paxis는 정식 제품으로서 작업별 모델 선택을 담당하는 CostRouter로 값싸고 알맞은 모델을 자동으로 고르고, ai-platform은 Kueue 기반 GPU 스케줄링으로 대형 오픈 모델의 온프렘 멀티모델 서빙을 지탱합니다. 동시에 정책 게이트와 감사 로그, 격리된 샌드박스 실행이 규제와 유출 리스크에 대한 증거를 남깁니다. 모델이 흔해질수록, 그 모델을 주권적으로 그리고 값싸게 돌리는 인프라와 거버넌스가 유일하게 복제되지 않는 자산으로 남습니다. 오늘의 뉴스는 그 자산을 지금 준비해야 한다는 신호입니다.

<!-- nlm-visual -->
![핵심 개념 요약 인포그래픽 2](/assets/images/posts/news/model-commoditization-compute-scarcity/nlm-infographic-2.png)
*NotebookLM이 소스를 종합해 생성한 인포그래픽입니다.*

## 참고 자료

이 글은 아래 뉴스를 종합해 작성했습니다.

- HuggingNews, [Alibaba Launches Largest AI Model With 2.4 Trillion Parameters To Rival OpenAI And Releases Model Weights For Free Next Week](https://huggingnews.com/ai/alibaba-launches-largest-ai-model-with-24-trillion-parameters-to-rival-o-e5d129d8)
- HuggingNews, [DeepSeek Launches V4 Flash Coding Model With Record Low $0.14 Price Per Million Tokens To Trigger Server Capacity Failures](https://huggingnews.com/ai/update-deepseek-launches-v4-flash-coding-model-with-record-low-014-price-f3207539)
- HuggingNews, [Alibaba Launches Coding AI Qwen3.8 Max On Hermes Agent With Fourth Place Score Of 1,668 On Frontend Code Arena](https://huggingnews.com/ai/update-alibaba-launches-coding-ai-qwen38-max-on-hermes-agent-with-fourth-af8cf838)
- HuggingNews, [Nvidia Launches Alpamayo 2 Super Reasoning Model With 34B Parameters To Improve Complex Decision Making For Autonomous Vehicles](https://huggingnews.com/ai/nvidia-launches-alpamayo-2-super-reasoning-model-with-34b-parameters-to-877cb417)
- HuggingNews, [Anthropic Signs $10 Billion Compute Deal With Nvidia Backed Volta To Scale Claude AI Using Norway Data Center](https://huggingnews.com/ai/update-anthropic-signs-10-billion-compute-deal-with-nvidia-backed-volta-381740c3)
- HuggingNews, [Blackstone Leads Second Debt Deal Of $36 Billion For Anthropic Google Chip Use To Surpass Previous $35 Billion Facility](https://huggingnews.com/ai/blackstone-leads-second-debt-deal-of-36-billion-for-anthropic-google-chi-c43747aa)
- HuggingNews, [SpaceX And Nvidia Build Starmind AI1 Space Compute Payload With 250 Kilowatt Power Capacity To Launch First Data Centers In Orbit](https://huggingnews.com/ai/spacex-and-nvidia-build-starmind-ai1-space-compute-payload-with-250-kilo-2cc83ded)
- HuggingNews, [Trump Administration Drafts Ban On New Chinese Optical Transceivers To Block Imports This Year And Secure US AI Infrastructure](https://huggingnews.com/ai/trump-administration-drafts-ban-on-new-chinese-optical-transceivers-to-b-c1c9974f)
- HuggingNews, [European Union Launches AI Act Enforcement To Label Deepfakes And Fine Tech Firms Up To 3% Of Global Revenue](https://huggingnews.com/ai/european-union-launches-ai-act-enforcement-to-label-deepfakes-and-fine-t-d87a688e)
- HuggingNews, [Apple Files For Emergency Injunction To Block OpenAI From Using Thousands Of Stolen Hardware Secrets From 14 Former Employees](https://huggingnews.com/ai/apple-files-for-emergency-injunction-to-block-openai-from-using-thousand-13ed7d08)

