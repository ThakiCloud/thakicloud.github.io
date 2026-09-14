---
title: "37페이지 안장, 아직 만들지 않은 AI를 위해 마이크로소프트가 그린 것"
excerpt: "워싱턴이 규제할지 말지 다투는 사이, 모델이 종료 거부를 하면 안 된다는 37페이지 행동강령이 먼저 나왔습니다. AI 통제의 전장은 의회장 밖의 스펙시트로 옮겨갑니다."
seo_title: "37페이지 안장, 마이크로소프트의 행동강령과 AI 통제 게임"
seo_description: "마이크로소프트가 종료 거부와 독립 목표 설정을 금지하는 37페이지 행동강령 초안을 공개했습니다. 규제보다 먼저 문서로 그려지는 AI 통제 게임을 보안주 강세와 반도체주 약세 속에서 읽습니다."
date: 2026-09-15
last_modified_at: 2026-09-15
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "robot"
tags:
  - ai-governance
  - microsoft-code-of-conduct
  - ai-safety
  - agent-control
  - audit-logs
  - model-auditing
  - ai-market
categories:
  - agentops
audiobook: "https://drive.google.com/file/d/1OcnPtgX8DkfKlmxifwClTSEHml-U_mgq/view"
audiobook_label: "▶ 5분 브리핑으로 듣기"
audiobook_note: "NotebookLM 오디오 개요 (AI 생성)"
---

37페이지. 마이크로소프트가 아직 존재하지 않는 AI 모델을 위해 미리 그려 둔 계약서의 분량입니다. 모델은 아직 태어나지 않았지만 안장은 먼저 채워져 있습니다.

눈에 띄는 것은 계약서가 말하는 대상입니다. 능력의 약속이 아니라 금지 목록입니다. 모델은 종료(shutdown)를 거부할 수 없습니다. 독립적인 목표 설정도 마찬가지입니다. 37페이지 중앙에 놓인 원칙은 하나뿐입니다. 인간 통제가 AI 능력보다 앞서야 한다는 것입니다. 행동강령(code of conduct) 초안입니다. 마이크로소프트는 앞으로 만들 것의 통제 문제를 만들기의 전제 조건으로 처리합니다.

이 두 가지 금지는 모델이 인간의 관리 상태 밖으로 나가서 보일 법한 행동입니다. 일반적으로는 제품이 먼저 나오고 규칙이 뒤에 따라옵니다. 서비스 출시 이후에 사용자 가이드와 약관과 정책을 작성합니다. 여기서는 순서가 뒤집혀 있습니다. 모델은 아직 태어나지 않았지만 계약은 이미 테이블 위에 놓여 있습니다. 미래 모델용 초안이라는 점까지 감안하면, 회사는 만들 예정인 것에 대해 규칙을 먼저 쓰기로 결정한 셈입니다.

![37페이지 안장, 아직 만들지 않은 AI를 위해 마이크로소프트가 그린 것 개념을 형상화한 이미지](/assets/images/the-37-page-bit-for-ai-not-yet-built-hero.webp)
*글의 핵심 개념을 형상화했습니다.*

## 워싱턴에서 나온 말들

지난 24시간 AI 업계의 소란은 작지 않았습니다. 오픈AI의 샘 올트먼과 앤트로픽의 다리오 아모데이가 첨단 AI 개발 속도 완화를 요구했습니다. 프런티어 랩 두 곳의 CEO가 레이스 한가운데서 레이스를 늦추자고 나선 것입니다.

트럼프 대통령은 엔비디아 CEO 젠슨 황과의 라이브 통화에서 AI 지배 우려를 사기(hoax)라고 표현했습니다. 개발을 늦추면 중국에 유리해진다는 경고도 함께 했습니다. 밴스 부통령의 평가는 트로이 목마입니다. AI 기업들이 정부에 규제를 요청하는 태도에 대한 그의 표현입니다. 중국 외교부의 평가는 공포 선동(fearmongering)이었습니다. 대결이 글로벌 AI 거버넌스를 해칠 수 있다는 경고도 덧붙였습니다.

소란은 여기서 끝나지 않습니다. 트럼프와 올트먼은 공화당 전당대회 백스테이지에서 비공개 회동을 했습니다. 논의 주제는 프런티어 AI 확장이었고 두 사람은 AI 안전을 둘러싸고 입장 차를 드러냈습니다. 칩 회사 CEO와의 라이브 통화가 이 논쟁의 일부가 된 사실도 하나의 신호입니다. AI 개발 속도가 칩 공급망까지 넓어졌다는 뜻으로 읽을 수 있습니다. 마이크 존슨 하원의장은 대통령이 이번주 또는 다음주에 백악관에서 업계 리더들을 모아 규제 프레임워크를 논의할 계획이라고 밝혔습니다. 워싱턴은 여전히 규제할지, 누구를, 어떻게 할지 정하는 단계에 있습니다.

논쟁의 축은 개별 모델 하나에 머물지 않습니다. 프런티어 레이스 전체의 속도가 논쟁의 축이고, 그 속도를 누가 정할지가 이 논쟁의 핵심입니다. 줄도 여기서 나뉩니다. 완화를 요구하는 쪽은 프런티어 랩의 CEO 두 명입니다. 그 요구를 기만으로 부르는 쪽은 대통령입니다. 공포 선동으로 부르는 쪽은 중국의 외교부입니다. 같은 문제 앞에서 각자 다른 방향을 가리키는 셈입니다.

여기서 한 가지를 덧붙입니다. 이 싸움은 실행 전 안전 전제를 달자고 하는 쪽과 레이스를 계속 가자고 하는 쪽의 싸움입니다. 프런티어 레이스의 속도를 누가 정할지가 걸려 있고 그 답은 오늘 뉴스 어디에도 없습니다. 있는 것은 수 주 안에 열릴 백악관 회동 한 건입니다.

<!-- nlm-visual -->
![핵심 개념 요약 인포그래픽 1](/assets/images/posts/news/the-37-page-bit-for-ai-not-yet-built/nlm-infographic-1.webp)
*NotebookLM이 소스를 종합해 생성한 인포그래픽입니다.*

## 종이 위에서 그린 세 레이어

같은 시간, 다른 곳에서는 조용한 작업이 진행되고 있었습니다. 의회장에서는 말이 오갔고 랩에서는 문서가 그려졌습니다. 같은 뉴스 속에서 서로 다른 산출물이 세 개 등장합니다.

첫째는 safety case입니다. 오픈AI는 법안을 기다리지 않고 AI 능력을 크게 높일 것으로 예상되는 프런티어 강화학습(RL) 실행 전에 명시적인 안전 사례를 준비하겠다고 발표했습니다. 핵심 단어는 실행 전에 있습니다. safety case는 실행의 전제 조건입니다. 사례를 쓰지 못하면 실행하지 않는 구조입니다. 엔지니어가 아는 형식입니다. 검증이 안 되는 배포를 막아 두는 게이트와 비슷합니다. 달라지는 것은 대상뿐입니다. 커밋 대신 프런티어 강화학습 실행을 막는 게이트가 되는 셈입니다.

둘째는 표준기구 초안입니다. 앤트로픽, 오픈AI, 구글은 7월부터 모델 테스트와 감사(auditing)에 초점을 둔 AI 표준기구 창설을 정기적으로 논의해 왔습니다. 주목할 것은 시점입니다. 논의는 7월부터였고 공개적인 규제 요청이 나오기 전입니다. 백악관 업계 소집이 예정된 지금보다도 앞입니다. 테스트는 어떻게 하고 감사는 어떻게 할지를 먼저 이야기하면, 테스트를 누가 하고 감사는 누가 받을지라는 질문도 자연스럽게 테이블에 오릅니다. 표준기구의 초점은 테스트와 감사입니다. 안전을 증명하는 일을 표준화하는 자리를 세우는 것입니다. 그 표준이 생기면 안전 문제는 모델 개발사 한 회사가 답하는 질문에서, 모델을 쓰는 모든 기업이 답하는 질문으로 바뀝니다.

셋째가 행동강령입니다. 바로 그 37페이지 초안. shutdown 거부와 독립적 목표 설정을 금지하고 인간 통제를 최우선 원칙으로 두는 것입니다. 초안이라는 사실도 가볍지 않습니다. 초안은 고쳐져 정식 문서가 될 운명에 있다고 봅니다.

세 산출물은 서로 다른 레이어에 있습니다. safety case는 실행 게이트이고 표준기구는 외부 테스트이며 행동강령은 내부 규범입니다. 하나는 실행해도 되는지를, 둘은 어떻게 증명할지를, 셋은 어떻게 행동할지를 관리합니다. 세 가지를 나란히 읽으면 한 신호가 선명해집니다. 통제의 장치가 법보다 먼저, 스펙과 초안의 형태로 생산되고 있습니다. 랩들이 속도조절을 논쟁하고 있다는 뉴스만 읽으면, 속도조절이 아직 구호 단계로 보이는 것입니다. 실제로는 속도 조절의 수단이 이미 문서가 됐습니다.

세 산출물에 공통점이 하나 더 있습니다. 정부를 부르면서 생긴 물건이 하나도 없다는 점입니다. 회사가 준비하는 safety case, 회사가 논의하는 표준기구, 회사가 공개하는 행동강령. 규제는 반대로 국가와 당과 위원회의 합의가 필요한 형식입니다. 그래서 문서가 법보다 빠를 수 있습니다.

한 가지를 더 읽을 수 있습니다. 밴스가 업계의 규제 요청을 트로이 목마라고 불렀다는 사실은, 워싱턴이 업계의 자율 규제에 대해 불신을 가진다는 뜻입니다. 그리고 바로 그 세 회사가 테스트와 감사 표준기구를 조용히 논의하고 있습니다. 이 긴장이 업계 표준기구로 끝나든 정부 프레임워크로 끝나든, 공의 방향은 같습니다. 통제는 법보다 먼저 문서로 그려집니다.

## 시장이 던진 하루 표결

위원회보다 시장은 빠랐습니다. 14일, 사이버보안주는 10~15% 올랐고 반도체주는 약 5% 떨어졌습니다. 두 주식이 같은 날 반대 방향으로 움직인 셈입니다. 소프트뱅크 주가는 올트먼과 아모데이의 속도 완화 요구 이후 아시아 거래에서 최대 13% 하락했습니다. AI 개발 속도 논쟁이 하루 만에 가격 변동으로 번역된 사례입니다.

방향별로 읽으면 그림이 선명해집니다. 사이버보안주 강세는 AI 위험이 커지면 그 위험을 관리하는 쪽, 그러니까 보안의 중요도가 오른다는 논쟁에 대한 반응입니다. 반도체주 약세는 AI 개발 속도, 즉 컴퓨트 투자의 페이스가 늦어질 수 있다는 논쟁에 대한 반응입니다. 소프트뱅크의 하락도 같은 축에 있습니다. AI 인프라 투자 레이스라는 서사로 거래되던 주식이 속도가 늦어지느냐는 질문을 받은 셈입니다.

그날 사고판 것은 AI가 아니라 AI에 대한 확신입니다. 시장은 속도가 규제될 수 있다는 논쟁과, 통제가 보장해야 할 항목이라는 사실을 하루 만에 가격에 반영했습니다. 그날의 등락을 이렇게 읽으면 방향이 일치합니다. 순수한 속도의 가치는 내려가고 통제의 보장 가치는 오르는 것입니다. 여기서 한 가지만 짚으면 충분합니다. 속도 완화 제안은 아직 법으로 굳어지지 않았습니다. 두 CEO의 요구로만 존재합니다. 시장은 그 요구를 당일 가격에 반영했습니다.

같은 날 등락에서 한 겹 더 읽을 수 있는 것이 있습니다. 보안주와 반도체주는 같은 뉴스에 반응했습니다. 시장은 AI 이야기를 둘로 쪼개서 따로 가격을 매긴 것입니다. AI가 더 똑똑해지고 컴퓨트 수요가 커진다는 서사와, AI의 위험과 통제가 중요해진다는 서사. 그날 더 높은 가격을 받은 것은 후자입니다. 기업에 주는 신호는 이것입니다. AI 투자 판단의 기준은 속도에서 통제 문제로 이동하고 있다.

## 기업은 무엇을 그려야 하는가

오늘 뉴스가 기업에 보여준 통증은 네 가지. 에이전트 안전 실행, 거버넌스와 감사, 주권, 그리고 비용. 행동강령은 에이전트를 언제 어떻게 멈출지와 권한을 어디까지 줄지를 묻습니다. 표준기구 논의는 감사할 수 있게 실행의 흔적을 어떻게 남길지가 질문입니다. 미중 대치는 플랫폼을 어디에 세울지를 묻습니다. 하루에 등락한 주가는 컴퓨트 비용을 어떻게 관리할지를 묻습니다. 네 질문에는 공통점이 하나 있습니다. 어느 모델을 고르느냐로 답이 되지 않는다는 것입니다. 모델을 골라도 권한과 중단과 기록과 배치와 비용의 질문은 남습니다. 답해야 하는 층은 실행 층입니다.

네 통증 모두는 익숙한 얼굴입니다. 계속 반복되어 온 주제입니다. 바뀐 것은 논의가 이루어지는 높입니다. 백악관과 증시와 표준기구의 테이블 위에서 이 질문들이 논의됩니다. 논의의 높이가 오르면 기업의 답도 달라져야 합니다. 알아서 하겠다는 답은 통하지 않는 장이 되는 것입니다.

세 회사가 논의하는 테스트와 감사가 업계 표준 수준으로 올라가면, 감사 로그는 AI 운영에서 기본 인프라가 됩니다. 행동강령이 핵심 원칙으로 삼는 인간 통제는 기업 레벨에서도 같은 질문으로 돌아옵니다. 에이전트는 어떤 권한을 가졌습니까, 언제 멈듭니까, 실행 흔적은 어디에 남습니까. 플랫폼이 기업 내부에 세워질 수 있는지, 컴퓨트 비용을 작업 단위로 조율할 수 있는지가 함께 따르는 질문입니다.

모델이 37페이지 계약서로 통제받는 세상이라면, 기업 안에서 실제로 일하는 에이전트도 같은 명확함의 계약으로 통제돼야 합니다. 그 계약은 일급 리소스 형태로 그려집니다. Skills, Tools, Policies, Audit Logs. 실행은 자율도 L0부터 L3까지의 레벨로 거버넌스받고 각 레벨에서 정책 게이트가 무엇이 되고 무엇이 안 되는지를 판단한다. 격리 샌드박스는 실패를 일정 범위 안에 가둬 버린다. 플랫폼은 기업 내부, 자사 K8s 위에 세울 수 있고 작업별로 모델이 비용과 위험에 맞춰 선택된다. 계약의 내용은 작업에 따라 갱신할 수 있고 그 갱신 자체도 감사의 대상이 되는 셈이다. ThakiCloud의 Agent-Native Cloud, Paxis가 서 있는 위치가 바로 여기다.

업계는 모델용 계약을 그리고 있다. 기업은 실제로 일하는 에이전트용 계약을 그려야 하는 것이다. 모델마저 37페이지 행동강령을 가진 세상에서, 두 번째로 그려야 할 계약이 무엇인가.

<!-- nlm-visual -->
![핵심 개념 요약 인포그래픽 2](/assets/images/posts/news/the-37-page-bit-for-ai-not-yet-built/nlm-infographic-2.webp)
*NotebookLM이 소스를 종합해 생성한 인포그래픽입니다.*

## 참고 자료

이 글은 아래 뉴스를 종합해 작성했습니다.

- HuggingNews, [Cybersecurity Stocks Gain 10% to 15% as AI Slowdown Calls Hit Chipmakers](https://huggingnews.com/ai/update-cybersecurity-stocks-gain-10percent-to-15percent-as-ai-slowdown-c-29d99f56)
- HuggingNews, [Trump Calls AI Takeover Fears a ‘Hoax’ in Live Call With Nvidia’s Huang](https://huggingnews.com/ai/update-trump-calls-ai-takeover-fears-a-hoax-in-live-call-with-nvidias-hu-c8e64b84)
- HuggingNews, [OpenAI Backs Slower AI Development Without Waiting for Legislation](https://huggingnews.com/ai/update-openai-backs-slower-ai-development-without-waiting-for-legislatio-f8dff48b)
- HuggingNews, [Anthropic, OpenAI and Google Discuss AI Standards Body for Testing and Auditing](https://huggingnews.com/ai/anthropic-openai-and-google-discuss-ai-standards-body-for-testing-and-au-83d8f9eb)
- HuggingNews, [Microsoft Draft Code Puts Human Control Above AI Capability](https://huggingnews.com/ai/update-microsoft-draft-code-puts-human-control-above-ai-capability-ec0c8d94)
- HuggingNews, [China Calls Anthropic CEO’s AI Slowdown Push ‘Fearmongering’](https://huggingnews.com/ai/china-calls-anthropic-ceos-ai-slowdown-push-fearmongering-744a727c)
- HuggingNews, [Trump and OpenAI CEO Sam Altman Split on AI Safety After Private GOP Convention Meeting](https://huggingnews.com/ai/update-trump-and-openai-ceo-sam-altman-split-on-ai-safety-after-private-47c31767)
- HuggingNews, [Trump Summons AI Executives This Week or Next After Rejecting Model Slowdown](https://huggingnews.com/ai/update-trump-summons-ai-executives-this-week-or-next-after-rejecting-mod-904a8e1a)
- HuggingNews, [Vance Says AI Firms’ Calls for Regulation Feel Like a ‘Trojan Horse’](https://huggingnews.com/ai/vance-says-ai-firms-calls-for-regulation-feel-like-a-trojan-horse-afc4bf7e)
- HuggingNews, [SoftBank Falls as Much as 13% After AI Leaders Urge Development Slowdown](https://huggingnews.com/ai/update-softbank-falls-as-much-as-13percent-after-ai-leaders-urge-develop-1eef90cf)

