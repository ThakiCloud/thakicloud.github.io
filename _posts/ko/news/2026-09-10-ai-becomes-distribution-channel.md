---
title: "AI가 판로가 된 주: Claude Marketplace에 들어온 5개사"
excerpt: "이번 주 Claude Marketplace에 CrowdStrike·Cursor·Factory·Gamma·Vercel이 들어왔습니다. 헤드라인은 다섯 회사지만 실제 뉴스는 하나입니다. 엔터프라이즈 소프트웨어가 AI 플랫폼의 크레드로 팔리기 시작했습니다."
seo_title: "AI가 판로가 된 주: Claude Marketplace에 들어온 5개사 | ThakiCloud"
seo_description: "CrowdStrike Falcon이 Claude Marketplace에, Cursor·Factory·Gamma·Vercel과 함께 추가됐습니다. AI 커밋먼트로 소프트웨어를 구매하는 새 판로, 보안 에이전트 워크플로, Paxis 관점의 시사점을 정리합니다."
date: 2026-09-10
last_modified_at: 2026-09-10
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "store"
tags:
  - claude-marketplace
  - crowdstrike-falcon
  - ai-procurement
  - enterprise-plugins
  - mcp
  - agent-governance
  - paxis
categories:
  - news
canonical_url: "https://thakicloud.com/tech-blog/ko/news/ai-becomes-distribution-channel/"
---

![글의 핵심 개념을 형상화한 이미지. 서로 다른 색의 빛줄기들이 단일 게이트를 통과해 하나의 코어로 수렴하는 모습](/assets/images/ai-becomes-distribution-channel-hero.webp)
*글의 핵심 개념을 형상화했습니다. 엔터프라이즈 소프트웨어가 AI 플랫폼이라는 단일 판로를 흐르기 시작했다는 이야기.*

## 왜 읽어야 하나

이 글은 다음 분기에 에이전트와 도구 구매를 계획하는 기업의 IT 의사결정자, 그리고 에이전트 실행 레이어를 직접 운영하는 팀을 위한 글입니다. 한 가지만 알면 됩니다. 이번 주 헤드라인은 "5개사가 Claude Marketplace에 들어왔다"였지만, 실제 뉴스는 **엔터프라이즈 소프트웨어가 AI 플랫폼의 크레드로 팔리기 시작했다는 것**이었습니다. 소프트웨어의 판로에 AI 플랫폼이 포함되기 시작한 순간입니다.

## 이번 주에 실제로 무엇이 일어났나

10일, @claudeai 공식 계정에서 Claude Marketplace의 신규 5개사를 발표했습니다. CrowdStrike, Cursor, Factory, Gamma, Vercel입니다. 트윗 본문은 "Enterprises can now use their Anthropic" 부분에서 잘려 있지만, 2일자로 나간 CrowdStrike의 1차 보도자료에서 구조의 핵심을 읽을 수 있습니다. 기존 Anthropic 커밋먼트의 일부를 사용해 CrowdStrike의 보안 솔루션을 구매할 수 있게 됐다는 것입니다.

CrowdStrike가 이 구조를 먼저 공식 발표한 무대는 9월 2일 Fal.Con이었습니다. 엔드포인트를 지키는 Falcon 플랫폼이 Claude Marketplace에 들어왔습니다.

같은 주에 claude.com 블로그에 "Cowork plugins across enterprise"가 올라와 마켓플레이스의 제품쪽 모양을 채워줬습니다. Cowork는 Claude Enterprise의 Chat과 Code와 함께 엔터프라이즈를 위한 스위트입니다. 플러그인은 Claude를 역할, 팀, 워크플로에 특화된 에이전트로 바꾸는 모듈형 확장입니다. 생산성, 엔터프라이즈 검색, 세일즈, 재무, 데이터, 법제, 마케팅, 고객 지원. 플러그인 라인업이 직무별로 구성됩니다. 관리자는 조직 안에서 사설 플러그인 마켓플레이스를 만들어, 팀별로 어떤 플러그인을 쓸지를 통제합니다.

## 왜 보안사가 첫 단추인가

구조에서 가장 흥미로운 지점은 첫 번째 파트너의 정체입니다. 콘텐츠 도구가 아니라 보안사입니다.

보도자료는 두 가지 특징을 나열합니다. 하나는 Charlotte AI AgentWorks입니다. 보안 팀이 자연어로 커스텀 보안 에이전트를 만들고 이 에이전트는 Falcon 플랫폼 데이터에 기반해 분류, 정보 보강, 위협 사냥, 대응 워크플로를 Claude 안에서 직접 실행합니다. 코딩이나 전문 AI 역량이 필요 없다는 설명입니다.

다른 하나는 데이터의 방향입니다. 양방향입니다. Falcon의 데이터가 Claude로 들어가고 동시에 Claude의 사용 로그와 이벤트가 Falcon 플랫폼으로 들어옵니다. 엔터프라이즈는 AI 관련 활동에 대한 하나의 통합 뷰를 갖고 AI 활동으로 인한 사고에 더 빠르게 대응할 수 있게 됩니다.

이것의 의미는 작지 않습니다. 감시 대상 목록에 엔드포인트와 서버 위에, AI가 일하는 공간 그 자체가 추가됐다는 뜻입니다. AI 활동 자체가 보안 감시 대상이 되는 지점에, 보안 도구가 AI 워크스페이스 바깥에서 로그를 뒤늦게 보는 구조로는 부족해졌고 CrowdStrike는 워크스페이스 안으로 들어왔습니다.

Anthropic의 엔터프라이즈 사이버 시큐리티 GTM을 맡은 Ash Alhashim은 Claude Marketplace가 Claude와 무리 없이 작동하는 신뢰할 만한 도구를 기업에 제공하도록 설계됐다고 말했습니다. CrowdStrike의 Daniel Bernard 최고사업책임자는 AI가 기업이 작동하는 방식과 기술을 구매하고 배포하는 방식을 바꾸고 있으며 그 선두가 보안이라고 했습니다. 양사가 같은 구조를 각자의 언어로 발표한 것 자체가 이번 주 뉴스의 무게입니다.

참고로 같은 주 보도들에 따르면, CrowdStrike는 OpenAI와의 유사한 연동도 포함해 AI 보안 얼라이언스를 확장 중입니다. "AI 플랫폼 안으로 들어간다"는 전략은 Anthropic 고유가 아닙니다. 최상위 모델사들이 모두 향하는 방향이라는 뜻입니다.

## 플러그인이 '역할'이 되는 구조

나머지 4개사를 보면 마켓플레이스의 취지선을 읽을 수 있습니다. Cursor는 AI 네이티브 코드 에디터, Factory는 AI 코드 에이전트 서비스, Gamma는 프레젠테이션과 덱 생성 도구, Vercel은 웹 배포 플랫폼입니다. 이 다섯 개 모두 모델이 아닙니다. 직원이 IDE나 브라우저 안에서 "일을 하는" 도구들입니다.

공통점은 엔터프라이즈 업무의 실행 레이어라는 점입니다. Claude가 두뇌라면, 이 회사들은 손과 발에 가깝습니다. 마켓플레이스는 모델의 능력이 아니라, 모델이 도달할 수 있는 범위를 팝니다.

역할별 플러그인 구조를 함께 보면 명백한 제품 철학이 보입니다. 같은 Claude가 재무 팀에는 재무 에이전트이고 세일즈 팀에는 딜 준비 에이전트이며, 보안 팀에는 인시던트 대응 에이전트가 됩니다. 어떤 에이전트가 어떤 도구에 도달할지는 개인의 취향이 정하지 않습니다. 조직의 큐레이션이 정합니다. 이것은 엔터프라이즈 AI 거버넌스의 새로운 축입니다. "에이전트가 어디까지 도달하고, 누가 그것을 결정하는가"라는 질문이 보안 정책 문서의 영역에서 마켓플레이스 레벨의 관리 항목으로 이동했습니다.

## 구매 구조가 바뀌는 지점

지금까지 기업은 AI 예산과 소프트웨어 예산을 별도의 라인으로 나눠 가졌습니다. AI 플랫폼을 계약하고 도구는 각사별로 개별 계약을 거쳐서 사던 구조였습니다. 이번 주 구조가 바꾸는 것은 지급 수단입니다.

Anthropic 커밋먼트의 일부로 CrowdStrike 보안 수트를 사면, AI 예산은 "AI 사용료"를 넘어 "기업이 AI를 통해 하는 일의 예산"으로 확장됩니다. 모델 플랫폼은 예산이 흐르는 판로가 됩니다.

IT 바이어에게는 다음 분기 예산표에 새 항목이 생깁니다. 어떤 AI 커밋먼트로 어떤 도구를 살 수 있고 그 도달 범위는 어떻게 거버넌스하는가. 소프트웨어 회사에게는 "모델 플랫폼 마켓플레이스에 존재한다"는 사실이, 영업과 SaaS 갱신 협상과 나란히 새로운 고투마켓 채널이 됩니다.

국내 흐름과도 겹치는 지점이 있습니다. 국민 단위의 실행 인프라를 AI로 세우는 구조가 움직이는 가운데, 그 인프라 위에 어떤 도구가 어떤 방식으로 유통되는지 묻는 것은, 개별 소프트웨어 회사의 판촉 영역을 넘어 시장 구조 문제로 올라섰습니다.

## 한계 및 반론

첫째, 락인입니다. 도구 구매가 단일 벤더의 커밋먼트에 묶이면 협상 구조가 바뀝니다. 모델 플랫폼을 바꿨을 때 커밋먼트로 구매한 도구가 계속使える지, 전환 비용은 얼마인지에 대한 답은 이번 발표 안에 없습니다.

둘째, 보안 역설입니다. Claude 사용 로그를 Falcon으로 끌어드리는 양방향 데이터 흐름은 그 자체로 새로운 데이터 경로입니다. 새로운 공격 표면이 생기며 그것이 구매 계약에서 어떤 경계로 처리되는지 검증은 배포 전에 거쳐야 합니다. 보안사가 AI 워크스페이스로 들어온다는 이야기는, 동시에 새로운 공격 표면도 들어온다는 이야기입니다.

셋째, 마켓플레이스의 형식입니다. 플러그인 형식과 사설 마켓플레이스는 현재 Anthropic 고유 구조입니다. MCP 같은 개방 표준과의 상호운용은 별개의 논의이며, 이 마켓플레이스가 proprietary 채널로 남을지 산업 공통 인프라로 갈지는 이번 주 뉴스가 얼마나 널리 퍼지느냐를 결정합니다.

마지막으로 신선도 유의입니다. 이번 5개사 중 1차 보도자료로 검증된 것은 CrowdStrike입니다. Cursor, Factory, Gamma, Vercel의 참여 형태는 @claudeai 발표와 회사 블로그로 확인했고, 상세가 공개되면 이 글에 반영하겠습니다.

## ThakiCloud 제품 적용 시사점

이번 주 뉴스가 가리키는 방향은, ThakiCloud가 이미 답해 두고 있는 설계 질문입니다.

Paxis는 ThakiCloud의 Agent-Native Cloud로, Skills, Tools, Policies, Audit Logs를 부속 기능이 아니라 일급 리소스로 관리합니다. Claude Marketplace의 사설 마켓플레이스, 즉 관리자가 에이전트가 도달할 도구를 통제하는 구조와 Paxis의 정책 게이트와 스킬 큐레이션은 같은 모양을 갖고 있습니다. Paxis는 작업을 격리된 샌드박스 안에서 실행하고, 모든 행동을 정책 게이트와 감사 로그로 통과시켜 이사회 테이블에서 꺼내 보여줄 수 있는 기록을 남깁니다. "에이전트가 어디까지 도달하고 누가 결정하는가"는 Paxis에서 처음부터 설계 전제로 들어 있는 질문입니다.

차이는 도는 자리입니다. Claude Marketplace는 Anthropic 클라우드 위의 구조이고 데이터 주권, 폐쇄망, 규제 요구로 같은 구조를 자기 인프라 위에서 돌려야 하는 기업은 ThakiCloud의 K8s 기반 ai-platform으로 답합니다. 온프레미스와 소버린 실행은 모델사 클라우드의 판로가 충족하지 못하는 조건이며, 그 경계에서 수직 통합 플랫폼의 자리가 나옵니다.

한 줄로 줄이면 이번 주 뉴스는 "에이전트 마켓플레이스 + 거버넌스"가 산업 전체의 제품 요구가 된 순간입니다. 방향은 검증됐고, 경쟁은 '어디서 돌리느냐'로 이동했습니다.

## 정리

IT 의사결정자에게는 에이전트 도입 발주서에 한 줄을 더할 때입니다. 어떤 커밋먼트에 어떤 마켓플레이스가 연결되고 그 안에 어떤 도구가 있으며, 그 도달 범위는 어떻게 거버넌스하는가.

이번 주 Claude Marketplace에는 다섯 개사가 들어왔습니다. 그러나 실제로 바뀐 구조는 그 아래층입니다. 엔터프라이즈 소프트웨어가 AI 플랫폼의 크레드로 구매되기 시작했고 보안사의 첫 진입이 그 판로의 첫 바퀴를 굴렀습니다. AI가 도구가 아니라 판로가 된 주, 도구의 경쟁이 "누가 그 판로를 거버넌스하느냐"의 경쟁으로 옮겨가는 지점입니다.

## 참고 자료

- @claudeai 공식 발표: [Claude Marketplace 신규 5개사](https://x.com/hjguyhan/status/2097897132208652677)
- CrowdStrike 보도자료: [CrowdStrike brings Falcon platform to Anthropic Claude Marketplace](https://www.crowdstrike.com/en-us/press-releases/crowdstrike-brings-falcon-platform-to-anthropic-claude-marketplace/)
- Anthropic 블로그: [Cowork plugins across enterprise](https://claude.com/blog/cowork-plugins-across-enterprise)
- Claude Support: [Manage plugins for your organization](https://support.claude.com/en/articles/13837433-manage-plugins-for-your-organization)
