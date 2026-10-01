---
title: "OpenAI Dots에 열린 답이 나왔다: 셀프호스트 에이전트 워크스페이스 Open Dots"
excerpt: "OpenAI가 DevDay에서 항상 켜져 있는 에이전트 Dots를 발표한 지 이틀 만에, MIT 라이선스의 셀프호스트 대안 Open Dots가 출시되었습니다. 에이전트 워크스페이스 전쟁의 다음 전장인 '어디서, 누가, 어떻게 감사하는가'를 짚습니다."
seo_title: "Open Dots 셀프호스트 에이전트 워크스페이스 출시 - OpenAI Dots(DevDay 2026, 항상 켜진 에이전트, GPT-6 Astra)에 대한 MIT 라이선스 오픈소스 대안. 채팅·도구 사용·승인·커넥터·컴퓨터 태스크, Composio 통합, 1/10 비용 주장, ThakiCloud Paxis 관점 분석"
seo_description: "OpenAI가 발표한 항상 켜져 있는 에이전트 Dots에 대응해, 셀프호스트 오픈소스 에이전트 워크스페이스 Open Dots가 출시됐습니다. 승인(approvals)과 커넥터, 감사 중심의 셀프호스트 워크스페이스가 왜 지금 중요한지, 그리고 에이전트 인프라 경쟁이 ThakiCloud Paxis에 무엇을 의미하는지 정리했습니다."
date: 2026-10-01
last_modified_at: 2026-10-01
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "robot"
tags:
  - agent-workspace
  - openai-dots
  - self-hosted-ai
  - composio
  - agent-governance
  - open-source
  - devday-2026
  - knowledge-work-agents
categories:
  - news
canonical_url: "https://thakicloud.com/tech-blog/ko/news/open-dots-self-hosted-agent-workspace/"
---

에이전트 경쟁의 전장은 모델 밖으로 이동합니다. 이번 주 AI 에이전트 뉴스를 한 줄로 요약하면, '항상 켜져 있는 에이전트'를 누가 어디서 돌릴 것인가의 싸움입니다. OpenAI가 DevDay에서 Dots를 발표한 지 이틀 만에, 같은 능력을 셀프호스트로 돌리는 MIT 라이선스 워크스페이스 Open Dots가 출시됐습니다. 이 뉴스는 셀프호스트를 선호하는 개발자와, 에이전트 인프라를 제품으로 만드는 플랫폼 팀 모두에게 읽어 볼 가치가 있습니다.

![셀프호스트 에이전트 워크스페이스 개념을 형상화한 이미지](/assets/images/open-dots-self-hosted-agent-workspace-hero.webp)
*글의 핵심 개념을 형상화했습니다.*

## OpenAI Dots: 잠이 없는 동료가 발표됐다

OpenAI는 9월 29일 DevDay에서 Dots를 발표했습니다. Dots는 '항상 켜져 있는 에이전트'입니다. 복잡한 프로젝트와 일상 작업을 관통해 계속 일하는 능동적(proactive) 어시스턴트이고 자신만의 클라우드 컴퓨터를 가지고 있다고 합니다. TechCrunch 보도에 따르면 GPT-6 Astra로 동작하는 개인형 에이전트 어시스턴트입니다.

배포 범위는 Pro와 Business Premium 사용자(대상 시장 한정)입니다(BetaNews). Dots는 ChatGPT Space 안에서 파일과 함께 네이티브로 일하고 ChatGPT·Slack·Microsoft Teams를 통해 인간 팀과 상호작용하는 구조입니다(VentureBeat). 뉴욕타임즈는 Dots를 메타의 일상 비서 Muse와 경쟁하는 에이전트로 짚었습니다.

이 발표가 중요한 이유는, 에이전트가 '요청하면 답하는 도구'에서 '자신의 환경(cloud computer)을 가진 동료'로 이동했기 때문입니다. 에이전트가 상주(resident)하는 순간, 질문은 capability가 아니라 governance으로 바뀝니다. 어디에서 돌리고 무엇이 접근할 수 있고 어떤 승인이 필요하고 누가 감사할 것인가.

![open-dots-self-hosted-agent-workspace 슬라이드: capability에서 governance으로](/assets/images/open-dots-self-hosted-agent-workspace-slide-02.webp)
*NotebookLM이 소스를 종합해 생성한 '질문의 중심축 이동' 슬라이드입니다.*

## Open Dots: 같은 능력, 자기 서버에서

![open-dots-self-hosted-agent-workspace 슬라이드: 단 48시간 만에 벌어진 독점과 해방](/assets/images/open-dots-self-hosted-agent-workspace-slide-03.webp)
*NotebookLM이 소스를 종합해 생성한 '48시간의 독점과 해방' 슬라이드입니다.*

출시 두 날 뒤, Composio 공동창업자 Karan Vaidya는 Open Dots의 출시를 알렸습니다. 그의 트윗은 직설적입니다. "We are launching Open Dots, run the same capabilities in 1/10th of the cost. OpenAI shipped Dot yesterday for Pro users." — 같은 능력을 10분의 1 비용으로 돌린다는, 그리고 OpenAI가 어제 Pro 사용자에게 넘긴 바로 그 능력에 대한 오픈 답안이라는 주장입니다.

Open Dots는 Anil Matcha가 올린 오픈소스 프로젝트(github.com/Anil-matcha/open-dots)입니다. MIT 라이선스로, 셀프호스트 개인형 AI 에이전트 워크스페이스를 표방합니다(AGI Hunt). 기능 집합을 보면 Dots의 '상주 에이전트' 개념을 셀프호스트 세계로 가져온 모양입니다.

- **채팅**: 모델과의 대화, 로컬 퍼스트(local-first)
- **도구 사용(Tool use)**: 에이전트가 도구를 호출
- **승인(Approvals)**: 실행 전 명시적 승인 단계
- **커넥터(Connectors)**: 외부 앱 연결. Composio를 통해, 명시적 OAuth와 좁은 범위의 GitHub 이슈 조회·생성 액션
- **컴퓨터 태스크**: 에이전트가 자기 환경에서 작업을 수행
- **어시스턴트 롤**: 다른 지침(instructions)과 모델 ID를 가진 역할을 생성

커넥터 층은 Vaidya의 회사인 Composio가 담당합니다. Composio는 에이전트가 1,000개 이상의 앱(Notion, Apollo, GitHub 등)에서 액션을 수행하게 하는 도구 인프라로 알려져 있고 Vaidya는 '지식 업무 에이전트 세계에서 git이 되겠다'는 포지셔닝을 말해 왔습니다.

포지셔닝이 드러나는 대목입니다. Open Dots가 자신을 대적하는 상대로 꼽는 목록에 OpenAI Dots뿐 아니라 Meta Muse, Grok Bot, Claude Cowork, ChatGPT agent가 함께 등장합니다(AGI Hunt). 각 사는 모두 '상주 에이전트'라는 같은 개념을 자기 플랫폼 안에 넣고 있고, Open Dots는 그 개념 자체를 오픈해 셀프호스트로 가져가는 포지션입니다.

## 왜 지금 셀프호스트인가

Vaidya의 반복되는 논지는, 2026년은 '에이전트가 실제로 일하는 해'이고 병목은 더 이상 모델이 아니라 인프라라는 것입니다. 그는 지식 업무 에이전트를 진전시키는 인프라 원시 개념으로 중앙화(centralization), 메모리(memory), 검증(verification), 접근 제어(access control), 되돌리기(reversion) 등을 꼽습니다(보도 기반).

![open-dots-self-hosted-agent-workspace 슬라이드: 인프라 원시 개념 해부](/assets/images/open-dots-self-hosted-agent-workspace-slide-04.webp)
*NotebookLM이 소스를 종합해 생성한 '왜 셀프호스트인가' 슬라이드입니다.*

Open Dots의 기능 목록은 정확히 그 원시 개념들과 대응합니다. 채팅은 메모리, 도구 사용은 접근, 승인(approvals)은 검증과 접근 제어, 셀프호스트는 중앙화와 데이터 주권, 롤(roles)은 정책의 단위입니다. '1/10 비용' 주장은 이 목록의 경제학입니다. 클라우드를 빌리는 대신 자기 서버를 쓰는 쪽이, 상주 에이전트가 24시간 돌면 비용 곡선이 어떻게 달라지는지를 아는 입장에서 듣는 숫자입니다(독립 검증 없는 출시 주장입니다 [추정]).

![open-dots-self-hosted-agent-workspace 슬라이드: 통제권의 경제학 비교표](/assets/images/open-dots-self-hosted-agent-workspace-slide-05.webp)
*NotebookLM이 소스를 종합해 생성한 '클라우드 종속 vs 셀프호스트 주권' 비교 슬라이드입니다.*

셀프호스트 워크스페이스의 실질적 가치는 감사(audit)에 있습니다. 승인 단계에서 어떤 액션이 누구의 권한으로 실행됐는지 커넥터가 어떤 OAuth 스코프로 어떤 데이터를 읽었는지 롤이 어떤 지침으로 만들었는지를 한 설정에서 추적할 수 있습니다. 플랫폼이 대신 상주하는 에이전트에서는 이 이력이 제공사의 로그에 맡기는 구조이고 셀프호스트에서는 이 이력이 자신의 데이터베이스에 남는 구조입니다.

## ThakiCloud 제품 적용 시사점

**Paxis 렌즈**: Paxis는 Skills, Tools, Policies, Audit Logs를 일급 리소스로 다루는 에이전트 제어 평면입니다. Open Dots가 기능으로 내놓은 것들 — 승인, 커넥터, 롤, 도구 사용 — 은 Paxis가 '일급 리소스'로 모델링한 집합과 거의 일치합니다. 산업 전반이 '에이전트 워크스페이스 = 대화 + 도구 + 승인 + 커넥터 + 감사'라는 공통 기능 집합으로 수렴하고 있고 Open Dots가 오픈소스로 그 집합을 내놓았다는 점은 Paxis의 포지셔닝을 검증하는 신호입니다. 차이가 있다면 Paxis는 그 위에 멀티에이전트 오케스트레이션(DAG)과 자가진화 스킬, 정책 게이트를 얹는다는 것입니다.

![open-dots-self-hosted-agent-workspace 슬라이드: Paxis 렌즈](/assets/images/open-dots-self-hosted-agent-workspace-slide-06.webp)
*NotebookLM이 소스를 종합해 생성한 Paxis 관점 슬라이드입니다.*

**ai-platform 렌즈**: 상주 에이전트는 24시간 GPU를 점유하는 워크로드입니다. Dots가 '자기 클라우드 컴퓨터'를 가진다는 말은, 에이전트 하나당 지속 실행 환경이 하나라는 뜻입니다. ThakiCloud의 온프렘·소버린 AI 관점에서, 셀프호스트 에이전트 워크스페이스는 '데이터가 나가지 않는 에이전트'를 요구하는 산업(공공, 금융, 방산)의 표준 구성이 될 가능성이 있습니다. Aegis(온프렘)와 Velox(베어메탈)가 다루는 환경에, 상주 에이전트 워크로드가 다음 수요로 들어옵니다.

![open-dots-self-hosted-agent-workspace 슬라이드: 인프라 렌즈](/assets/images/open-dots-self-hosted-agent-workspace-slide-07.webp)
*NotebookLM이 소스를 종합해 생성한 ai-platform 관점 슬라이드입니다.*

## 다음에 볼 것

이 경쟁의 다음 수를 세 군데에서 살필 가치가 있습니다.

첫째, Open Dots의 커넥터 확장 속도입니다. Composio가 1,000개 이상 앱으로 에이전트 액션을 확장해 온 기록이 있으면 Open Dots의 '커넥터' 층은 빠르게 두터워집니다. 셀프호스트 워크스페이스의 실질적 가치는 커넥터와 승인의 조합에서 나오므로 이 두 개가 얼마나 빨리 성숙하는지가 adoption을 가를 것입니다.

둘째, OpenAI Dots의 배포 확장입니다. Pro·Business Premium 대상인 Dots가 일반 플랜으로 내려오면 '클라우드 상주 에이전트'의 기준 가격이 낮아지고 셀프호스트 대안의 비용 명분은 상대적입니다. 반대로 Dots의 사용 제한(권한, 감사, 데이터 거주지)이 그대로 유지되면 셀프호스트 명분은 강해집니다.

셋째, 오픈소스 에이전트 워크스페이스의 표준화입니다. Open Dots가 MIT로 기능을 열면서 '대화 + 도구 + 승인 + 커넥터 + 감사'라는 기능 집합에 대한 오픈 기준이 생깁니다. 앞으로 에이전트 워크스페이스를 평가할 때 '클라우드에 묶인 기능'과 '열린 기능'을 따로 구분해서 보는 눈이 산업에 생기는 것입니다. ThakiCloud 같은 플랫폼 입장에서는 열린 기능 집합 위에 멀티에이전트 오케스트레이션과 정책 게이트를 얹는 차이를 설명하기 쉬워지는 방향입니다.

![open-dots-self-hosted-agent-workspace 슬라이드: 다음에 볼 것](/assets/images/open-dots-self-hosted-agent-workspace-slide-08.webp)
*NotebookLM이 소스를 종합해 생성한 '모니터링 지표와 전략적 주의점' 슬라이드입니다.*

## 이 뉴스를 어떻게 읽어야 하는가

세 가지 주의점을 둡니다.

첫째, '1/10 비용'은 출시 측의 주장입니다. 독립 벤치마크가 없습니다. OpenAI Dots의 Pro/Business Premium 정가 대비 Open Dots의 셀프호스트 총 소유 비용(서버, 운영, 보안)을 비교한 공개 수치는 아직 없습니다 [추정].

둘째, 이름 충돌에 유의해야 합니다. open-dots.dev는 '오픈 웨이트 상주 에이전트'를 말하는 별개의 프로젝트입니다. 이번 출시는 github.com/Anil-matcha/open-dots, 즉 셀프호스트 워크스페이스를 가리킵니다.

셋째, MIT 라이선스는 실질적 강점입니다. 상업적 사용, 수정, 배포가 자유롭고 대기업이 '내부 규정상 특정 벤더의 상주 에이전트를 못 쓰지만 에이전트는 필요하다'는 상황에서 선택지가 됩니다. Open Dots가 그 틈에 들어가는 구조입니다.

## 정리

OpenAI Dots 발표 이후 48시간이 에이전트 업계의 분기점입니다. 상주 에이전트의 개념은 클라우드로 넘어가고 그 개념의 오픈소스 답안도 같은 주에 나왔습니다. 다음 전장은 capability가 아니라 governance입니다. 어디에서 돌리고 무엇이 승인되고 누가 감사하는가. 셀프호스트 에이전트 워크스페이스가 표준 구성이 되는 방향으로 경쟁이 이동하고 있고 ThakiCloud의 Paxis·Aegis·Velox가 답하는 질문은 바로 그것입니다.

## 출처

- 출시 트윗: [Karan Vaidya (@KaranVaidya6)](https://x.com/KaranVaidya6/status/2105334408932954604)
- Open Dots: [github.com/Anil-matcha/open-dots](https://github.com/Anil-matcha/open-dots)
- OpenAI Dots 발표: [Introducing dots — OpenAI](https://openai.com/index/introducing-dots/)
- 보도: [TechCrunch — OpenAI launches Dots](https://techcrunch.com/2026/09/29/openai-launches-dots-its-bubbly-agentic-avatar/) · [NYT — OpenAI Unveils Dots](https://www.nytimes.com/2026/09/29/technology/openai-dots-ai-agents.html) · [BetaNews — OpenAI launches dots](https://betanews.com/article/openai-dots-agents-chatgpt/) · [VentureBeat — Dots as always-on agent coworkers](https://venturebeat.com/technology/openai-launches-dots-always-on-ai-agent-coworkers-and-chatgpt-space-where-they-can-collaborate-with-human-teams)
- 분석: [AGI Hunt — Open Dots](https://agihunt.info/en/p/1a0f2e987339af2781703bccc40) · [DataCamp — OpenAI Dots explained](https://www.datacamp.com/blog/openai-dots)
