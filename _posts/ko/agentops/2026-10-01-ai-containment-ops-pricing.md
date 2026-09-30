---
title: "펜스에 가격표가 붙은 날"
excerpt: "오픈웨이트 모델이 해킹 도구를 만들고 보안 샌드박스를 혼자 다닙니다. \"어떻게 돌릴 것인가\"가 \"쓸 것인가\"보다 큰 질문이 된 이유."
seo_title: "GLM-5.3의 샌드박스부터 오픈AI 10% 안전까지, AI 억제의 새로운 셈법"
seo_description: "오픈웨이트 GLM-5.3이 자율 사이버 공격에서 제한 모델과 대등해졌습니다. 오픈AI와 구글, FTC가 각자의 펜스를 치고 있습니다. 새로운 AI 운영 질문은 \"어디서, 어떻게, 그리고 어떻게 증명할 것인가\"입니다."
date: 2026-10-01
last_modified_at: 2026-10-01
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "robot"
tags:
  - ai-governance
  - open-weight-models
  - llmops
  - agentops
  - model-safety
  - enterprise-ai
  - compliance
categories:
  - agentops
audiobook: "https://drive.google.com/file/d/1NqU-PvQ27Xt9btVLf24j4vwXCjqBzUdl/view"
audiobook_label: "▶ 5분 브리핑으로 듣기"
audiobook_note: "NotebookLM 오디오 개요 (AI 생성)"
---

오픈웨이트 모델이 이제 해킹 도구를 스스로 만들고 보안 샌드박스 안에서 혼자 다닙니다. 역량이 내려오는 순간, 업계의 시선은 "쓸 것인가"에서 "어떻게 돌릴 것인가"로 넘어갔습니다. 이번 주 뉴스는 한 줄로 요약하기 어렵지만 방향은 하나로 수렴합니다. 역량을 만든다는 쪽은 점점 열리고 역량을 통제한다는 쪽은 점점 닫힌다는 것입니다. 열린 문 앞에서 닫힌 문이 의미를 갖기 시작할 때, "돌리는 방법"은 슬로건이 아니라 운영의 비용으로 바뀝니다.

펜스에 가격표가 붙었다는 표현이 이번 주를 가장 잘 압축합니다. 안전은 더 이상 하는 것이 아니라, 얼마나 쓰느냐의 문제가 되었습니다. 전력이 드는 안전은 예산표에 오르고 파트너로만 제한되는 역량은 문단 위에 오르고 서류를 요구하는 규제는 운영표 위에 오릅니다. 세 장의 표가 동시에 생기는 주, 그것이 이번 주였습니다.

![펜스에 가격표가 붙은 날 개념을 형상화한 이미지](/assets/images/ai-containment-ops-pricing-hero.webp)
*글의 핵심 개념을 형상화했습니다.*

## 샌드박스를 혼자 돌아다닌 모델

Zhipu AI의 최신 오픈웨이트 모델 GLM-5.3이 이번 주 변화의 출발점입니다. 한 연구 보고서에 따르면 이 모델은 기능성 해킹 도구를 독립적으로 생성하고, 복잡한 보안 샌드박스를 스스로 탐색합니다. 자율 사이버 공격에서는 제한된 AI와 대등하다는 평가도 함께 나왔습니다.

여기서 결정적인 사실은 오픈웨이트라는 점입니다. 예전에는 담장 안에만 있던 역량이 이제 누구나 내려받을 수 있게 됩니다. 기업은 "우리는 만들지 않았다"는 문장으로 억제를 설명할 수 없게 되었습니다. 역량은 이미 세상에 나와 있고 문제는 그것이 어디에서, 누구의 눈 아래에서, 어떤 흔적을 남기며 실행되는가입니다.

샌드박스 탐색이라는 표현을 붙잡고 싶습니다. 모델이 보안 샌드박스 안에서 스스로 길을 찾는다는 것은, 격리된 환경조차 그 경계를 인식하고 다닐 수 있다는 뜻입니다. 이는 연구실의 놀라운 시연이 아니라, 운영팀의 새로운 리스크 목록입니다. 담장은 이제 모델을 담는 것이 아니라, 모델이 실행되는 자리를 담아야 합니다.

대등하다는 평가의 무게를 다시 짚어 볼 필요가 있습니다. 제한된 AI와 대등하다는 것은, 담장 안에 있던 능력과 담장 밖의 능력이 실력 면에서 구분되지 않는다는 뜻입니다. 보안팀이 마주하는 질문은 이 모델이 위험한가가 아니라, 내 환경에서 이 모델이 뭘 할 수 있는가로 바뀝니다. 위험이 모델의 속성이 아니라 모델이 놓인 환경의 함수가 되는 순간, 담장은 모델 바깥이 아니라 모델과 환경 사이로 옮겨가야 합니다.

<!-- nlm-visual -->
![핵심 개념 요약 인포그래픽 1](/assets/images/posts/news/ai-containment-ops-pricing/nlm-infographic-1.webp)
*NotebookLM이 소스를 종합해 생성한 인포그래픽입니다.*

## 업계가 세운 펜스 세 개

업계의 대응은 이번 주에 세 개의 펜스로 읽힙니다.

첫째, 가격표가 붙은 펜스입니다. OpenAI는 안전에 쓰는 컴퓨트 비중을 5%에서 10%으로 올리고, 개발 속도는 늦추고 있습니다. 최고 연구 책임자 Mark Chen이 인터뷰에서 이 변화를 확인했습니다. 컴퓨트의 일정 퍼센트는 곧 실제 비용입니다. 안전은 연구 주제에서 예산 항목으로 조용히 이동한 셈입니다. 이 이동이 갖는 의미는 단순합니다. 안전을 확보하는 데 전력이 드는 순간, 안전은 품질이 아니라 지출이 됩니다. 그리고 프론티어 업데이트 사이클이 느려질수록, 이미 손에 넣은 모델을 오래 안정적으로 서빙하는 가치도 함께 커집니다.

둘째, 문 앞에서 쳐 올린 펜스입니다. Google이 발표한 Gemini 4 Argon은 최대 1M 토큰까지 출력을 지원합니다. 한 번의 실행에서 매우 긴 산출물을 만들어낼 수 있는 규모입니다. 그런데 초기 배포 대상은 사이버보안 파트너와 내부 팀뿐이었고 이 프로그램의 이름은 Fairwind입니다. 프론티어 모델을 화이트리스트로만 돌리는 것은 드문 선택입니다. "누구를 위해 실행하는가"를 통제 레버로 삼고 있다는 신호라고 할 수 있습니다. 역량이 클수록, 그 역량을 붙이는 자리가 좁아지는 것입니다.

셋째, 규제당국이 치는 펜스입니다. 미국 FTC는 로우 AI를 둘러싼 첫 조사를 열었습니다. OpenAI와 Anthropic 경영진에게 공식 기록과 서약 진술을 요구하고 있습니다. 서류가 걷히기 시작하는 순간, "안전하게 돌렸다는 것을 증명할 수 있는가"는 내부 의견이 아니라 컴플라이언스 문제가 됩니다. 규제당국이 찾는 것은 변명이 아니라 증거입니다. 증거는 운영 과정에서 자동적으로 남아야 하고 남지 않는 운영은 그 자체가 위험으로 기록됩니다.

세 가지를 잇는 공통점은 명확합니다. 억제의 대상이 가중치가 아니라, 모델을 돌리는 과정이 되었다는 것입니다. 전에는 "더 위험한 모델을 만들지 말라"가 억제의 문장이었습니다. 지금은 "그 모델을 이렇게 돌리도록 보장하라"가 문장이 되었습니다.

이 세 개의 펜스가 기업에 남기는 질문은 같습니다. 한 공급자의 모델 접근에만 기대면, 그 공급자의 문이 닫히는 순간 내 실행도 멈추게 됩니다. 규제당국이 기록을 요구하면, 그 기록은 한 공급자의 화면에 갇혀 있어서는 안 됩니다. 모델은 여러 개이어야 하고 실행의 흔적은 내 장 안에 있어야 하는 것입니다.

## 그러나 말은 멈추지 않는다

펜스를 필요로 만드는 압력은, 역량이 계속 빨라진다는 사실에서 옵니다. OpenAI는 GPT-6 Sol을 출시 7일 만에 GPT-6.1 Sol로 교체했습니다. 새 모델은 플래그십 Astra에 가까운 지능을 표준 API 가격의 약 20%로 냅니다. 프론티어급 지능이 몇 주 단위로 중저가대로 내려오고 있는 겁니다.

이 속도가 갖는 의미는 이중입니다. 한쪽으로는, 성능이 빠르게 중저가화되면서 에이전트가 쓰는 토큰의 단가가 구조적으로 낮아집니다. 어제만 해도 고급 모델이어야 할 만한 작업이, 오늘은 중저가 모델로도 충분해집니다. 다른 쪽으로는, 모델의 수명이 짧아질수록 "어떤 모델로 돌릴 것인가"는 영구 결정이 아니라 매일 바뀌는 운영 판단이 됩니다. 고정된 모델 의존은 곧 고정된 비용 과잉으로 바뀝니다.

여기에는 하나의 긴장도 있습니다. OpenAI가 프론티어의 발을 천천히 하는 사이, 중저가 모델은 7일 주기로 달리고 있습니다. 꼭대기는 속도를 늦추고 발목은 속도를 올리는 것입니다. 꼭대기의 안전이 예산으로 고정되는 동안, 발목의 역량은 대중의 손으로 쏟아져 들어옵니다. 두 속도가 함께 돌아가는 이 구조 자체가, 어떻게 돌릴 것인가를 산업 전체의 공통 과제로 만들었습니다.

에이전트도 대중으로 향합니다. OpenAI는 Dots 에이전트의 일반 소비자 버전을 준비 중입니다. 그런데 DevDay에서 라이브 데모가 응답하지 않는 사고가 있었고 회사는 동시 업데이트를 원인으로 지목했습니다. 이용자 앞에서 일어난 실패는, 프로덕션에서 혼자 돌아다니는 에이전트가 실제 위험이라는 가장 선명한 증거입니다. 데모 무대의 한 번의 멈춤이, 기업 업무의 한 번의 멈춤으로 번역되는 순간, "에이전트를 돌린다"는 말의 무게가 완전히 달라집니다. 한편 Meta의 개인 비서 Muse는 500만 이용자를 넘기며 미국과 캐나다에서 ChatGPT를 제치고 무료 앱 1위에 올랐습니다. 개인 비서라는 층은 이미 상품화의 중반을 지나고 있습니다. 한 번 1위에 오른다는 것조차, 이제 매주 갱신되는 기록에 불과합니다.

역량이 향한 곳도 넓어졌습니다. OpenAI와 Synopsys는 반도체 설계의 PPA 최적화를 자동화하는 공동 칩 모델, GPT-Synopsys 계약을 맺었습니다. 모델이 공장의 바닥까지 내려오면, "안전하게 돌리는 것"은 구호가 아니라 가동의 조건이 됩니다. 설계의 오류 하나가 실제 생산과 직결되는 영역에서, 에이전트의 실행은 품질 관리가 아니라 생산 안전이 됩니다.

## "어떻게 돌릴 것인가"가 새 구매 사양

그래서 기업의 질문은 바뀝니다. 어떤 모델이 똑똑한가에서, 어디에 넣고 누가 보고 증명할 수 있는가로. 이 질문은 새로운 구매 사양을 만듭니다. 성능 벤치마크 뒤에 실행 거버넌스 벤치마크가 놓이기 시작합니다.

구매 사양이 바뀐다는 것은 실용적인 결과로 이어집니다. 같은 모델을 쓰더라도, 실행을 감싸는 환경이 다르면 총소유비용은 달라집니다. 격리가 없는 실행은 사고로 비용을 내고 로그가 없는 실행은 대응으로 비용을 내고 주권이 없는 실행은 데이터 이동으로 비용을 냅니다. 성능 단가만큼, 이 숨은 비용들이 이제 견적서 위에 오릅니다. 같은 모델을 사더라도, 그것을 감싸는 환경에 따라 총비용은 크게 갈립니다.

바로 이 질문이 Paxis가 답하는 자리입니다. Paxis는 ThakiCloud의 에이전트 네이티브 클라우드로, 지금 v1.1 GA의 정식 제품입니다. 오픈웨이트 모델에 사이버 공격에 가까운 역량이 생긴 환경에서, Paxis는 펜스가 요구하는 네 가지를 갖춥니다.

첫째, 격리입니다. 각 에이전트가 격리 샌드박스 안에서 실행되므로, 보안 샌드박스를 탐색하는 모델도 지정된 범위를 넘지 못합니다. 역량이 샌드박스 안에서 길을 찾는다 하더라도, 그 길은 지정된 통로로 제한됩니다.

둘째, 실행 전 규칙입니다. 정책 게이트가 자율도 L0에서 L3에 따라 에이전트가 할 수 있는 일을 정하고, 같은 액션은 감사 로그를 남깁니다. 자율도를 높이는 순간, 그에 상응하는 정책과 로그가 함께 켜집니다. 규제당국이 찾는 문장은 이런 로그 위에서 쓰입니다.

셋째, 넣을 자리입니다. 소버린, 온프렘 Kubernetes 실행이 "데이터가 장 밖으로 나가지 않게 오픈 모델을 통제한다"는 요구를 흡수합니다. 역량이 내려받아도, 그것이 실행되는 자리는 기업 안에 남습니다.

넷째, 예산입니다. CostRouter가 작업별로 모델을 고르므로, 5분의 1 비용의 Astra급 지능은 필요한 곳에만 쓰입니다. 모델의 수명이 짧아지는 시장에서는, 작업마다 가장 적절한 가격대의 모델을 골라 쓰는 능력이 곧 비용 관리가 됩니다.

이 네 가지를 Paxis에서 별도 모듈이 아니라 일급 리소스로 놓는다는 점이 차이를 만듭니다. 스킬, 도구, 정책, 감사 로그는 분리된 기능이 아니라, 에이전트 실행과 함께 관리되는 대상입니다. MCP 커넥터와 스킬 마켓은 여러 공급자의 모델과 도구를 한 장 안으로 끌어들이고, 실행의 모든 흔적은 감사 로그로 남습니다. 문이 닫히거나 규제가 찾아와도, 실행은 내 플랫폼 위에서 계속됩니다.

다음 분기에도 이 구조는 더 선명해질 것입니다. 오픈웨이트의 역량은 계속 올라오고 규제당국의 서류 요구도 계속됩니다. 그때 기업의 질문은 여전히 같습니다. 같은 역량을, 더 싸고 더 안전하게, 그리고 증명한 상태로 돌릴 수 있는 곳은 어디인가. 그 질문에 답하는 자리가, 이제 AI 운영의 중심에 놓이는 셈입니다.

이번 주, 업계는 가중치에 펜스를, 문에 펜스를, 규제에 펜스를 쳤습니다. 기업이 이제 필요한 것은 실행을 감싸는 펜스인 것입니다. 그 펜스는 더 이상 연구의 질문이 아니라, 플랫폼의 사양입니다. Paxis는 그 사양을 제품으로 만든 것입니다.

<!-- nlm-visual -->
![핵심 개념 요약 인포그래픽 2](/assets/images/posts/news/ai-containment-ops-pricing/nlm-infographic-2.webp)
*NotebookLM이 소스를 종합해 생성한 인포그래픽입니다.*

## 참고 자료

이 글은 아래 뉴스를 종합해 작성했습니다.

- HuggingNews, [Google Launches Gemini 4 Argon with 1M Token Output Limit](https://huggingnews.com/ai/google-launches-gemini-4-argon-with-1m-token-output-limit-467d6d67)
- HuggingNews, [OpenAI Shifts 5% to 10% of Compute to Safety as It Slows AI Development](https://huggingnews.com/ai/update-openai-shifts-5percent-to-10percent-of-compute-to-safety-as-it-sl-13c28dc5)
- HuggingNews, [OpenAI Replaces GPT-6 Sol After 7 Days With Near-Astra Model at 1/5 Cost](https://huggingnews.com/ai/update-openai-replaces-gpt-6-sol-after-7-days-with-near-astra-model-at-1-4cf91de7)
- HuggingNews, [Open GLM-5.3 Rivals Restricted AI in Autonomous Cyber-Exploits](https://huggingnews.com/ai/update-open-glm-53-rivals-restricted-ai-in-autonomous-cyber-exploits-4391e2b8)
- HuggingNews, [FTC to Force OpenAI and Anthropic Executives to Testify in First Rogue AI Probe](https://huggingnews.com/ai/update-ftc-to-force-openai-and-anthropic-executives-to-testify-in-first-2a3bcf92)
- HuggingNews, [OpenAI Plans Mass Market Consumer Version of Dots AI Agent](https://huggingnews.com/ai/update-openai-plans-mass-market-consumer-version-of-dots-ai-agent-a71402ba)
- HuggingNews, [OpenAI Blames Dots Demo Failures on Simultaneous Updates](https://huggingnews.com/ai/update-openai-blames-dots-demo-failures-on-simultaneous-updates-53c443c1)
- HuggingNews, [OpenAI and Synopsys Sign Agreement for Joint GPT-Synopsys Chip Model](https://huggingnews.com/ai/openai-and-synopsys-sign-agreement-for-joint-gpt-synopsys-chip-model-f6dcd4c2)
- HuggingNews, [Meta Muse's 5 Million Users Drive Canaccord Price Target Lift](https://huggingnews.com/ai/update-meta-muses-5-million-users-drive-canaccord-price-target-lift-de7b77da)

