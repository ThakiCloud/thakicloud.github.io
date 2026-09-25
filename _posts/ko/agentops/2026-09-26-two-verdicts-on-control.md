---
title: "두 번의 판결, 같은 말 '통제"
excerpt: "법원은 모델의 안전 장치를 국가안보 위협으로 규정했고 같은 회사의 최고경영자는 안전 장치 없는 에이전트를 인류의 위협으로 경고했습니다. 통제라는 한 단어에 두 번의 판결이 내려진 주, 에이전트를 돌리는 회사가 붙잡아야 할 자리를 분석합니다."
seo_title: "두 번의 판결, 같은 말 '통제': AI 모델의 법적 상태가 기업 조달 변수가 된 주"
seo_description: "DC 순회법원의 Anthropic 배제 확정, 유엔 안보리의 글로벌 AI 기준 촉구, 오라클의 불가항력 선언, 샌더스 초지능 금지법까지. 통제라는 말에 걸린 두 방향의 힘과, 에이전트를 돌리는 회사의 실행 플랫폼 자리를 분석합니다."
date: 2026-09-26
last_modified_at: 2026-09-26
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "robot"
tags:
  - agent-governance
  - ai-regulation
  - model-procurement
  - national-security
  - audit-log
  - multi-model
  - sovereign-ai
categories:
  - agentops
audiobook: "https://drive.google.com/file/d/1slO-LgM8Q3gQIJukISF2lXPUZI2deHi5/view"
audiobook_label: "▶ 5분 브리핑으로 듣기"
audiobook_note: "NotebookLM 오디오 개요 (AI 생성)"
---

에이전트를 남의 프런티어 모델 위에 올려 돌리는 회사라면, 이번 주는 통제라는 단어의 가격이 바뀐 주간으로 읽어야 합니다. 한 쪽에서 법원은 모델의 안전 장치를 국가안보 위협으로 규정했습니다. 다른 쪽에서, 같은 회사의 최고경영자는 안전 장치가 없는 에이전트가 인류의 주도권을 영구히 약화시킬 수 있다고 경고했지요. 한 단어에, 한 주에, 두 번의 판결이 내려졌습니다. 어느 쪽의 판결이 옳은지가 오늘의 포인트는 아닙니다. 에이전트를 돌리는 회사라면, 두 판결 어느 쪽에도 흔들리지 않는 자리가 어디인지를 묻는 주간이었습니다.

![두 번의 판결, 같은 말 '통제 개념을 형상화한 이미지](/assets/images/two-verdicts-on-control-hero.webp)
*글의 핵심 개념을 형상화했습니다.*

## 첫 번째 판결, 안전 장치가 위협이 된 때

판결의 장소는 워싱턴입니다. 금요일, 미 DC 순회법원의 의견이 갈린 재판부는 Anthropic의 내부 AI 안전 가드레일이 미군 작전의 공급망 위협을 이룬다고 판단했습니다. 안전 장치가 위협의 근거가 된 판결입니다. 같은 법원은 Anthropic의 이전 승소를 뒤집고 펜타곤의 블랙리스트를 유지했습니다. Claude는 미군 조달과 정부 계약에서 배제됐습니다. 이 배제는 계약 자격의 문제입니다. 서비스가 꺼진다는 뜻은 아닙니다. Anthropic이 국방부의 공급망 리스크 지정을 해제해 달라고 낸 법적 도전도 실패했습니다. 항소법원은 블랙리스트를 그대로 두고 말입니다. 승소로 끝나 있던 사안이 다시 뒤집힌 겁니다.

이 판결에는 천천히 읽어야 할 두 가지 디테일이 있습니다. 먼저, 이 판결은 재판부 의견이 갈린 채로 나왔습니다. 판결이 다툼 가능한 상태라는 뜻입니다. 모델의 법적 상태는 아직 확정되지 않은 사안이라는 뜻이기도 합니다. 다음으로, 지정의 근거는 서비스 중단이나 성능 문제가 아니었습니다. 모델 안에 들어 있는 안전 가드레일 그 자체였습니다. 공급망 리스크 지정이라는 말은 보통 부품이나 소재, 하드웨어에 붙이는 말입니다. 이번에는 소프트웨어의 설계값에 붙었습니다.

특정 모델의 API 위에 에이전트를 세우는 회사에 이 말은 구체적으로 다가옵니다. 모델을 고르는 회사는 평소 성능과 가격, 컨텍스트 길이를 봅니다. 그런데 모델 내부의 안전 설계도 모델과 함께 오는 스펙입니다. 회사가 손닿게 검증하거나 조정하거나 바꾸지 못하는 스펙이요. 이번 주 그 보이지 않던 스펙이 국가안보 변수가 됐습니다. 모델의 법적 상태는 조달 문서의 배경 소음이 아닙니다. 언제든 움직이는 변수입니다. 조달 검토에는 새로 써야 할 문장이 됐습니다.

배제의 범위도 생각보다 넓습니다. 미군 조달과 정부 계약이라는 말 안에는 공공 부문의 사업이 들어 있습니다. 국내 기업의 공공 수주와 유지보수 계약도 그 범위 안에 들어가는 셈입니다. 상대가 군이 아니라 공공기관이더라도, 공급망 리스크 지정이 붙은 모델은 검토 테이블에서 밀려나기 십상이 됩니다. API가 살아 있는 것과, 그 모델을 계약서에 쓸 수 있는 것은 별개의 문제입니다. 이번 주, 그 별개의 두 문장이 한데 묶였습니다.

<!-- nlm-visual -->
![핵심 개념 요약 인포그래픽 1](/assets/images/posts/news/two-verdicts-on-control/nlm-infographic-1.webp)
*NotebookLM이 소스를 종합해 생성한 인포그래픽입니다.*

## 두 번째 경고, 통제의 부재가 위협이 된 때

두 번째 장소는 뉴욕입니다. 같은 주, OpenAI와 Anthropic의 최고경영자들은 유엔 안전보장이사회에서 글로벌 AI 기준 마련을 촉구했습니다. 통제되지 않은 에이전트가 미래에 대한 인간의 주도권을 영구히 약화시킬 수 있다는 경고였습니다. 한 주 안에 한 회사의 안전 장치가 두 번, 다른 의미로 등장합니다. 워싱턴에서는 그 장치가 미군 작전의 공급망 위협을 이루는 주체였습니다. 뉴욕에서는 그 장치가 없는 시나리오가 문제였습니다.

통제라는 말의 두 쓰임은 같은 뜻을 가지지 않습니다. 펜타곤이 요구하는 통제라면, 모델은 시키는 일을 다 해야 합니다. 거절하고 늦추는 모델이 위협입니다. CEO들이 유엔에서 요구하는 통제라면, 사람이 모델 위에 지렛대를 쥐는 쪽입니다. 홀로 움직이는 에이전트가 위협입니다. 이번 주, 같은 말이 한 문장에서는 복종을 가리키고 다른 문장에서는 제약을 가리켰습니다.

기업에는 이 경고가 먼 미래의 이야기가 아닙니다. 통제되지 않은 에이전트라는 문장은, 지금 에이전트를 돌리는 회사의 운영 문장입니다. 사람이 미리 승인해야 할 행위의 경계가 어디인지, 그 경계를 누가 먼저 정할 것인가가 문제입니다. 유엔 테이블에서 논의되는 기준은, 결국 조달 문서의 체크리스트로 돌아옵니다. 그 체크리스트에 답을 갖춘 구조가 있는 회사와 없는 회사의 격차가, 다음 분기에 벌어지기 시작합니다.

통제의 기준을 정하는 자리에서는 더 큰 균열이 보입니다. 트럼프 행정부는 글로벌 AI 거버넌스 노선을 거부하고 AI 감독을 미국 법무부가 담당하는 방향으로 갔습니다. 같은 보도에서는 시진핑 중국 주석이 미국과 중국을 모두 "AI 강국"으로 부르며 기술이 인간의 통제를 벗어나지 않게 하는 것이 두 나라의 공동 책임이라고 했습니다. 글로벌 기준을 만들자던 주체, 감독을 자국으로 가져오려는 행정부, 인간의 통제를 함께 말하던 양강의 장면이 한 프레임에 모입니다. 기준의 방향은 아직 정해지지 않았습니다. 한 기준이면 컴플라이언스가 풀리지 않고 규제 주체와 정의와 관할이 모두 움직일 수 있다면, 감독에 대응하는 시스템은 변화라는 전제 위에서 지어야 합니다. 기준의 방향이 무엇이든, 기준의 이동 속도가 기업에는 더 큰 변수입니다. 한 글로벌 기준이 굳어지더라도, 그 과정의 관할과 정의가 흔들리는 구간은 남게 되니까요. 감사 로그가 그 구간에서도 작동하도록 구조를 갖춘 회사가, 감독의 방향이 불확실한 주간을 버틸 수 있는 회사입니다.

## 두 판결 사이, 회사가 붙잡아야 할 것

조달의 문제부터 짚어 볼 수 있습니다. Claude가 미군 조달과 정부 계약에서 배제됐다는 사실은, 좋은 모델 고리기에서 그 모델이 다음 주에도 쓸 수 있는가로 업계의 대화를 옮겼습니다. 프런티어 모델 하나에 워크플로를 묶어 둔 회사에서, 공급망 리스크 지정은 사업 연속성 문제입니다. 이미 승소로 끝났던 사안이 다시 뒤집혔다는 것은, 상태가 시간에 따라 움직인다는 뜻입니다. 모델 이름을 적는 조달 문장은 서명하는 순간부터, 시간이 지나면 다시 쓰이는 미완의 문장입니다. 그 변수는 해당 모델을 쓰는 모든 워크로드에 돌아옵니다. 모델 이름을 문서에 고정하는 순간, 문서가 승계하는 것은 모델의 법적 상태입니다. 점수 시트는 그 뒤의 문제입니다.

조달의 변수가 움직이는 사이, 돈의 변수도 같은 방향을 가리킵니다. 오라클은 1,650억 달러 규모의 뉴멕시코 AI 센터에 불가항력을 적용했습니다. 시설이 계획을 벗어나면 개발사 Blue Owl Capital에 대한 지급을 유예하겠다는 통보였습니다. 같은 보도에 따르면 관련 채권은 사상 처음으로 8% 수익률을 기록했습니다. 골드만삭스의 전망이 그러합니다. 미국 5대 하이퍼스케일러의 AI 지출은 2027년, 1조 2000억 달러에 달할 것으로 보입니다. 2026년 8000억 달러 지출 흐름의 연장선에, Amazon과 Alphabet, Microsoft, Oracle, Meta의 데이터센터와 에너지 조달 확장이 함께 언급됩니다. 인프라가 클수록, 남의 인프라에서 돌린다는 부담은 무거워집니다. 지급 유예와 8% 수익률, 두 숫자는 같은 사실을 가리킵니다. 대형 AI 센터조차 자금 조달 리스크의 문턱에 선 것이지요. 그리고 기업에는 이것이 비대칭입니다. 하이퍼스케일러의 capex는 그들만의 대차대조표 항목이지만 기업의 원장에겐 GPU 가격과 용량 배정 대기열로 도착합니다. 1조 2000억 달러로 커가는 지출 전망은, 컴퓨트의 공급 압력이 2027년까지 이어진다는 뜻이기도 합니다. 그런 시장에서는, 자기 안에서 돌린다는 선택이 연속성의 옵션으로 격상됩니다.

같은 주, 벤더들은 통합이라는 말을 키웠습니다. 마이크로소프트는 Autopilot과 Code를 포함한, 회사가 발표해 온 최대 규모의 Copilot 업데이트를 내놓았습니다. 사티아 나델라 CEO의 비전은 모든 기기에서 기업 워크플로를 관리하는 통합 생태계입니다. 통합은 편합니다. 기기를 한데 모으고 워크플로를 한 테이블에 올리면, 관리자는 편해지고 벤더는 강해집니다. 그런데 이번 주, 그 편의에 질문이 남겨졌습니다. 최대 규모의 자동화 기능의 이름은 Autopilot, 자동 조타입니다. 같은 주, 뉴욕에서는 에이전트가 통제되지 않으면 인간의 주도권이 영구히 약해진다는 경고가 나왔습니다. 조타의 이름과 경고를 같은 주에 읽는 기분이, 지금 업계 전체의 기분이 됩니다. 가장 편한 자리가 가장 안전한 자리라는 보장은 어디에도 없습니다. 이번 주 두 판결은 그 사실의 증거입니다.

규제의 축은 이 방향입니다. 샌더스 상원의원과 카사 하원의원이 발의한 법안은 초지능 AI의 영구적 금지를 목표로 하고 위반 시 20년의 구금형을 규정합니다. 어떤 모델을 쓰느냐가 형사 리스크의 범위에도 들어온다는 문장은, 기업의 모델 선택을 검토의 맨 위로 올리는 데 충분한 이유입니다. 감독이 법무부 쪽으로 이동한 방향은 이 그림을 완성합니다. 감독의 손이 수사 당국으로 넘어온다면, 기록은 이제부터 증거로 내 놓아야 하는 것이 됩니다. 기업이 매일 쌓는 감사 로그와 정책 기록은, 그 순간 앞에서 작동하는 방패가 됩니다. 이 방패는 그날보다 앞서 서 있어야 합니다.

## 그러면, 그 사이를 서야 할 자리는

두 판결을 실행 환경의 언어로 다시 쓰면, 공통의 전제가 보입니다. 어느 모델이, 어떤 권한으로, 어떤 기록을 남기며 어디에서 돌아가는가가 그 전제입니다. 그 답이 플랫폼에 미리 서 있을 때, 다음 판결이 내려지는 금요일에 기업은 당황하지 않습니다.

Paxis는 ThakiCloud의 Agent-Native Cloud로, v1.1에서 정식 제품입니다. 오늘의 두 판결이 가리키는 통증에, Paxis의 구조가 대응하는 지점이 있습니다.

조달의 질문에 대한 답은, 모델을 갈아끼우는 대가입니다. Paxis는 작업별 모델 선택, CostRouter로 과업마다 어울리는 모델을 배정합니다. 모델이 바뀌면 넘어가는 부담이 구조에 이미 들어 있는 겁니다. 모델은 소버린, 온프레미스 K8s(ai-platform) 위에서 격리된 샌드박스 안에 실행됩니다.

감독의 질문에 대한 답은 기록입니다. 감독의 방향이 법무부이든 글로벌 기준이든, 공통의 요구는 같습니다. 그 에이전트가 무엇을, 어떤 권한으로, 누구의 승인 아래 움직였는지를 받아 낼 수 있어야 합니다. Paxis는 Skills, Tools, Policies, Audit Logs를 일급 리소스로 관리합니다. 자율도는 L0에서 L3까지 거버넌스가 걸립니다. 정책 게이트를 통과한 실행만 감사 로그로 남습니다. 기존 시스템과의 연결은 MCP 커넥터와 스킬 마켓이 담당합니다.

돈의 질문에 대한 답은 실행 환경입니다. GPU 가격과 용량 대기열이 남의 대차대조표에서 온다면, 그 변동은 남의 고지사항입니다. 통제의 가격이 오르는 시장에서, Paxis의 과업별 모델 배정과 실행 구조는 그 고지를 받아 쓰는 자리보다, 과업과 모델을 다시 짤 수 있는 자리에 가깝습니다.

이번 주 두 판결은 한 방향의 두 얼굴입니다. 통제의 비용이, 모델을 만든 회사에서 그 모델을 쓰는 회사로 넘어오고 있습니다. 비용이 넘어오는 주, 먼저 서 있는 자리는 모델을 바꾸고 실행을 격리할 수 있으며 기록을 받아내는 자리입니다.

<!-- nlm-visual -->
![핵심 개념 요약 인포그래픽 2](/assets/images/posts/news/two-verdicts-on-control/nlm-infographic-2.webp)
*NotebookLM이 소스를 종합해 생성한 인포그래픽입니다.*

## 참고 자료

이 글은 아래 뉴스를 종합해 작성했습니다.

- HuggingNews, [DC Circuit Upholds Pentagon Ban on Anthropic as National Security Risk](https://huggingnews.com/ai/update-dc-circuit-upholds-pentagon-ban-on-anthropic-as-national-security-09d4e1d8)
- HuggingNews, [US Court Overturns Anthropic Win to Uphold Pentagon Blacklist](https://huggingnews.com/ai/update-us-court-overturns-anthropic-win-to-uphold-pentagon-blacklist-ec06aa13)
- HuggingNews, [Trump Rejects Global AI Governance for Justice Department Oversight](https://huggingnews.com/ai/update-trump-rejects-global-ai-governance-for-justice-department-oversig-f609f9e8)
- HuggingNews, [US Appeals Court Declines to Block Pentagon Blacklist of Anthropic](https://huggingnews.com/ai/us-appeals-court-declines-to-block-pentagon-blacklist-of-anthropic-34523dad)
- HuggingNews, [Oracle Invokes Force Majeure on $165B AI Center as Bonds Hit First Ever 8% Yield](https://huggingnews.com/ai/update-oracle-invokes-force-majeure-on-165b-ai-center-as-bonds-hit-first-237d11ef)
- HuggingNews, [OpenAI and Anthropic CEOs Urge Global AI Standards at UN Security Council](https://huggingnews.com/ai/openai-and-anthropic-ceos-urge-global-ai-standards-at-un-security-counci-796c82b3)
- HuggingNews, [Microsoft Launches Biggest Copilot Update With Autopilot and Code](https://huggingnews.com/ai/microsoft-launches-biggest-copilot-update-with-autopilot-and-code-2a61fe84)
- HuggingNews, [Goldman Forecasts $1.2 Trillion AI Spending by 5 US Hyperscalers in 2027](https://huggingnews.com/ai/update-goldman-forecasts-12-trillion-ai-spending-by-5-us-hyperscalers-in-67a450b2)
- HuggingNews, [Sanders Introduces Bill to Ban Superintelligent AI With 20 Year Prison Terms](https://huggingnews.com/ai/update-sanders-introduces-bill-to-ban-superintelligent-ai-with-20-year-p-af9f1535)
- HuggingNews, [Goldman Projects $1.2 Trillion AI Spend for Top 5 US Hyperscalers in 2027](https://huggingnews.com/ai/update-goldman-projects-12-trillion-ai-spend-for-top-5-us-hyperscalers-i-817c6bff)

