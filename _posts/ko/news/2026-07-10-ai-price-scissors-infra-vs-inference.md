---
title: "위로 폭발하는 랙, 아래로 무너지는 추론: 기업은 AI 가위의 한가운데 서 있습니다"
excerpt: "같은 날 발표된 두 개의 숫자가 정반대로 움직였습니다. 2100만 달러짜리 AI 랙과 34배 싸진 추론 요금입니다. 이 벌어지는 가위의 한가운데에서 기업이 쥐어야 할 손잡이를 짚어봅니다."
seo_title: "AI 가위: 2100만 달러 랙과 34배 싼 추론이 같은 날 말하는 것"
seo_description: "HBM4 랙 가격 폭등과 딥시크발 추론 요금 붕괴가 같은 날 나왔습니다. 인프라 자본비용과 모델 원가가 반대로 벌어지는 구조를 뜯어보고, 그 사이에서 기업이 통제할 수 있는 변수를 정리합니다."
date: 2026-07-10
last_modified_at: 2026-07-10
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "robot"
tags:
  - ai-infrastructure
  - hbm4
  - inference-cost
  - sovereign-ai
  - gpu-cloud
  - model-routing
  - tco
categories:
  - news
canonical_url: "https://thakicloud.com/tech-blog/ko/news/ai-price-scissors-infra-vs-inference/"
audiobook: "https://drive.google.com/file/d/1gSpJ4N7oAw9vrpZpgK46X0F6abZzsU-k/view"
audiobook_label: "▶ 5분 브리핑으로 듣기"
audiobook_note: "NotebookLM 오디오 개요 (AI 생성)"
published: false
---

![위로 치솟는 랙 값과 아래로 무너지는 추론 값 사이에 낀 기업을 나타낸 AI 가위 개념도]({{ '/assets/images/ai-price-scissors-infra-vs-inference-hero.webp' | relative_url }})

![위로 폭발하는 랙, 아래로 무너지는 추론: 기업은 AI 가위의 한가운데 서 있습니다 개념을 형상화한 이미지](/assets/images/ai-price-scissors-infra-vs-inference-hero.png)
*글의 핵심 개념을 형상화했습니다.*

## 같은 날, 두 숫자가 서로를 등지고 걸어갔습니다

오늘 아침 뉴스에는 정반대 방향으로 움직이는 두 개의 숫자가 나란히 실렸습니다. 하나는 위로 튀어 올랐습니다. 엔비디아 루빈 울트라 랙의 평균 판매가가 2100만 달러로 보도됐습니다. 직전 세대인 블랙웰 울트라의 400만 달러와 견주면 다섯 배가 넘습니다. 다른 하나는 바닥으로 꺼졌습니다. 딥시크가 V4-Pro 요금을 75퍼센트 영구 인하하면서, 출력 토큰 기준으로 오픈AI보다 34배, 앤스로픽보다 29배 싼 가격표를 내걸었습니다.

한쪽에서는 AI를 굴리는 쇳덩어리가 폭등하고, 다른 한쪽에서는 그 쇳덩어리가 뱉어내는 답변의 값이 폭락합니다. 얼핏 모순처럼 보이는 이 장면이 사실은 하나의 사건입니다. 오늘 다이제스트를 관통하는 이야기는 특정 모델이 얼마나 똑똑해졌는가가 아니라, AI 경제의 위층과 아래층이 서로 반대로 벌어지고 있다는 사실입니다. 벌어지는 두 날 사이에 낀 것은 결국 이 기술을 실제로 쓰려는 기업입니다.

<!-- nlm-visual -->
![핵심 개념 요약 인포그래픽 1](/assets/images/posts/news/ai-price-scissors-infra-vs-inference/nlm-infographic-1.png)
*NotebookLM이 소스를 종합해 생성한 인포그래픽입니다.*

## 위층: 쇳덩어리는 점점 비싸집니다

랙 가격만의 이야기가 아닙니다. 위층 전체가 값을 올리고 있습니다. 번스타인은 HBM4와 LPDDR5X 메모리 단가가 2027년 기가바이트당 53달러까지 오른다고 내다봤습니다. 랙 원가의 절반 이상이 GPU와 HBM에 쏠려 있으니, 메모리가 오르면 서버 한 대의 몸값이 통째로 따라 오릅니다. 그런데도 삼성전자와 SK하이닉스, 마이크론은 증설 속도를 늦추기는커녕 앞당기고 있습니다. 새 공장이 실제 물량을 내놓기까지 최소 3년이 걸려 의미 있는 공급 증가는 2028년 이후에나 가능하다는 계산이 깔려 있기 때문입니다. 마이크론은 2035년까지 미국에 2500억 달러를 붓겠다고 못 박았고, SK하이닉스는 공모가 149달러로 약 40조 원 규모의 미국 주식예탁증서 상장에 나섰습니다. 외국 기업의 미국 증시 상장으로는 최대 규모입니다. 지금의 투자는 가격이 곧 꺾인다는 신호가 아니라, 앞으로 몇 년간 이어질 AI발 수요에 미리 자리를 잡아두는 포석입니다. 다만 같은 날 미국 상무장관이 뉴욕 팹 행사에서 한국 기업들에 미국 내 생산 확대를 공개적으로 압박했다는 소식도 함께 실렸습니다. 국내 대규모 투자와 대미 투자 요구 사이에서 자금과 인력을 어떻게 나눌지가 메모리 3사의 새로운 숙제로 얹혔습니다.

비싸지는 것은 값만이 아니라 복잡도이기도 합니다. 삼성전자는 HBM과 로직, 실리콘포토닉스를 한데 묶는 2.xD 패키징을 개발 중이라고 밝혔습니다. 대역폭 병목을 넘어서려면 서로 다른 칩을 정교하게 붙여야 하고, 그럴수록 파운드리와 첨단 패키징의 캐파에 공급망 전체가 매입니다. 성능을 끌어올릴수록 만드는 난이도와 원가가 함께 오르는 구조입니다. 엔비디아는 성능 향상으로 총소유비용이 개선된다고 말하지만, 랙당 원가의 절반이 GPU와 HBM에 쏠린 이상 실제 투자 회수 속도가 이 사이클의 지속 가능성을 결정하는 진짜 변수로 떠올랐습니다.

여기에 더 무거운 벽이 하나 더 서 있습니다. 전력입니다. 중앙일보와 조세일보가 나란히 짚었듯, AI 경쟁의 축은 반도체 확보에서 데이터센터 운영으로 이미 넘어갔습니다. 정부는 2029년까지 550조 원, 2035년까지 1000조 원이 넘는 AI 데이터센터 투자를 유치하겠다고 목표를 세웠고, 그 가운데 18.4기가와트 목표의 81퍼센트를 SK그룹이 맡는 구조입니다. 문제는 서울과 경기 지역이 관련 전력 계약의 78.7퍼센트를 차지하는데 정작 핵심 부지는 포화에 가깝다는 점입니다. GPU를 사 오는 일보다 계통 연계와 변전소 증설 인허가가 더 긴 리드타임을 요구합니다. 액침냉각 같은 액체 냉각을 도입하면 냉각에 드는 전력을 90퍼센트 넘게 줄일 수 있다지만, 이런 설비를 24시간 무중단으로 돌릴 고숙련 운영 인력을 3년에서 5년 이상 붙잡아 두기가 쉽지 않다는 인력난이 또 다른 병목으로 지목됩니다. 그래서 이미 대규모 송전 권리를 쥔 옛 비트코인 채굴업체들이 AI 인프라 공급자로 다시 값이 매겨지고 있습니다. 코어사이언티픽과 아이렌, 테라울프 같은 기업이 하이퍼스케일러와 장기 전력 계약을 맺으면서, 시장은 이들을 채굴 채산성이 아니라 확보한 전력 용량, 곧 메가와트 단위로 다시 평가하기 시작했습니다. 위층에서 진짜 희소한 자원은 이제 칩이 아니라 전기입니다.

## 아래층: 답변의 값은 점점 싸집니다

같은 날, 아래층에서는 정확히 반대되는 힘이 작동했습니다. 딥시크의 인하는 일회성 프로모션이 아니라 영구 정책이었고, 그 파장은 통계로 잡혔습니다. 버셀과 오픈라우터 같은 개발자 플랫폼에서 중국계 모델의 트래픽 점유율이 단기간에 두 자릿수로 뛰었고, 린디 같은 실제 스타트업은 앤스로픽에서 딥시크로 서비스를 통째로 갈아탔습니다. 가격에 민감한 고객층은 이미 움직이고 있습니다.

메타의 행보는 이 흐름을 한층 또렷하게 보여줍니다. 그동안 라마를 오픈소스로 풀며 생태계를 키우던 메타가 뮤즈 스파크 1.1로 처음 유료 API 사업에 뛰어들면서, 경쟁사의 약 4분의 1 수준이라는 파격적인 가격을 들고 나왔습니다. 저커버그는 가격이 매력적일 것이라고 자신했습니다. 여기에 메타는 9월부터 자체 AI 칩을 양산해 엔비디아 의존을 낮추고, 올해 최대 1450억 달러에 이르는 인프라 지출을 회수하려고 유휴 컴퓨팅까지 외부에 팔겠다고 나섰습니다. 구글의 TPU, 아마존의 트레이니엄에 이어 메타의 커스텀 실리콘까지, 빅테크가 직접 칩을 찍고 남는 연산을 되파는 국면입니다. 위층의 비용 압박이 클수록 아래층에서는 그 압박을 남에게 넘기기 위한 가격 전쟁이 격화됩니다.

이 가위질이 실리콘밸리만의 이야기가 아니라는 점이 국내 뉴스에서 드러납니다. 하정우 씨는 울산이 제조 산업 데이터를 많이 축적한 만큼 산업 AI 전환의 가능성이 크다고 말했고, 아이티센코어는 국민은행과 손잡았으며 SK AX는 제조 현장을 겨냥한 풀스택 전환을 내놓았습니다. LG는 물리 법칙을 이해하는 월드모델 개발에 나섰고, 알리페이는 결제와 신뢰, 개방을 앞세워 에이전트 시대의 승부수를 던졌습니다. 제조와 금융과 공공이 저마다 AI를 실제 업무에 밀어 넣기 시작했다는 뜻입니다. 문제는 이들이 AI를 도입하는 그 순간, 방금 살펴본 두 날 사이에 그대로 끼어든다는 데 있습니다. 위로는 인프라 자본비용이, 아래로는 모델 원가와 주권 리스크가 동시에 이들을 누릅니다.

## 왜 이 둘은 같은 힘일까요

모순처럼 보이던 두 방향은 사실 같은 뿌리에서 갈라집니다. AI 수요가 폭발하면서 상류에 있는 반도체와 전력의 희소성이 값을 밀어 올립니다. 동시에 그 수요를 잡으려는 모델 공급자들의 경쟁이 하류의 마진을 무너뜨립니다. 위로 오르는 자본비용과 아래로 내리는 판매가격이 같은 수요에서 태어난 쌍둥이라는 뜻입니다. 그래서 이 구도는 가위를 닮았습니다. 두 날은 반대로 움직이지만 하나의 축에 묶여 있습니다.

기업이 서 있는 자리는 정확히 그 가위의 한가운데입니다. 인프라를 직접 지으려면 폭등하는 위층 비용을 감당해야 하고, 모델을 외부 API로만 쓰려면 남의 가격 정책과 데이터 주권 리스크에 몸을 맡겨야 합니다. 게다가 딥시크는 중국계 모델이고 메타는 폐쇄형 유료로 돌아섰습니다. 금융과 공공처럼 망분리와 데이터 주권 규제가 엄격한 영역에서는 저 싼 값을 그대로 가져다 쓰기 어렵습니다. 값이 싸다는 사실과 그 값을 안전하게 쓸 수 있다는 사실은 전혀 다른 문제입니다.

## 가위 한가운데에서 쥐어야 할 손잡이

여기서 흔한 반론 하나를 짚고 넘어가야 합니다. 딥시크가 34배 싸고 메타가 4분의 1 가격을 들고 나왔으니, 그냥 제일 싼 외부 API를 골라 쓰면 되지 않느냐는 것입니다. 값만 보면 맞는 말입니다. 그러나 싼 값에는 조건이 붙어 있습니다. 딥시크는 중국계 모델이고, 메타는 오픈소스에서 폐쇄형 유료로 돌아섰으며, 이 둘의 가격은 언제든 공급자의 사정에 따라 다시 오를 수 있습니다. 남의 가격 정책에 원가 구조를 통째로 맡기는 것은 절감이 아니라 새로운 종속입니다. 진짜 절감은 그 싼 값을 내 통제 안으로 가져올 때 완성됩니다.

그렇다면 벌어지는 두 날 사이에서 기업이 통제할 수 있는 변수는 무엇일까요. 뉴스가 힌트를 흘려두었습니다. AI 데이터센터 기사의 핵심 교훈은 확보한 GPU를 못 돌리면 무의미하다는 것이었습니다. 즉 위층 비용을 흡수하는 첫 번째 손잡이는 유휴를 없애는 스케줄링입니다. 딥시크 사례의 교훈은 저가 모델과 고가 모델을 작업 난이도에 따라 나눠 쓰는 라우팅이었습니다. 두 번째 손잡이는 작업마다 알맞은 모델을 고르는 배분입니다. 메타 유료화와 중국계 모델 확산의 교훈은 싼 값을 데이터 주권 안에서 흡수하려면 오픈 웨이트를 내 인프라에서 직접 서빙해야 한다는 것이었습니다. 세 번째 손잡이는 온프렘과 소버린입니다. 그리고 과기정통부와 KISA가 발간한 AI 보안 레드티밍 가이드가 프롬프트 인젝션과 에이전트 권한 오남용을 표준 위협으로 못 박았듯, 네 번째 손잡이는 실행을 안전하게 가두는 정책과 감사입니다.

ThakiCloud가 Agent-Native Cloud로 만든 Paxis는 바로 이 네 손잡이를 한 손에 쥐도록 설계했습니다. 작업마다 알맞은 모델을 고르는 CostRouter는 딥시크류 저가 모델과 고성능 모델을 워크로드에 따라 갈라 태워 아래층의 가격 붕괴를 비용 절감으로 되받습니다. 격리 샌드박스 실행과 멀티테넌시는 확보한 GPU의 유휴 시간을 줄여 위층의 자본비용을 흡수합니다. 소버린과 온프렘 쿠버네티스 기반은 오픈 웨이트 모델을 국내 규제 안에서 직접 서빙하게 해, 싼 값과 데이터 주권을 동시에 가져갑니다. 그리고 Skills, Tools, Policies, Audit Logs를 일급 리소스로 두고 L0부터 L3까지 자율도를 나눈 거버넌스는, 레드티밍 가이드가 요구하는 정책 게이트와 감사 로그를 처음부터 제품 안에 심어둡니다.

{% raw %}
<!--
  animated-architecture-diagram — self-contained D3 embed template.
  HuggingFace research-article style: declarative NODES/EDGES/SEQ model,
  data(solid)/event(dashed) edges, hover-trace + tooltip, flow-dot animation
  along edge paths, replay button, scroll-into-view autoplay, reduced-motion +
  light/dark aware. The renderer injects window.__ARCH_SPEC__ at the marker.
  Format (D3 machinery + CSS) is owned by this committed template; the model
  only authors the JSON spec (content). See references/spec-schema.md.
-->
<div class="d3-arch" data-arch-root id="scissorsinfravsinference-1"></div>
<style>
  /* ---- Theme tokens (standalone; light default + dark override) ---- */
  .d3-arch {
    --page-bg: #ffffff;
    --surface-bg: #f7f8fa;
    --text-color: #1a1d21;
    --muted-color: #6b7280;
    --border-color: #d5d9e0;
    --primary-color: hsl(217 91% 55%); /* brand accent — swap for #1B4F72 etc. */
    position: relative;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Noto Sans KR", system-ui, sans-serif;
    color: var(--text-color);
  }
  @media (prefers-color-scheme: dark) {
    .d3-arch {
      --page-bg: #0f1115;
      --surface-bg: #171a21;
      --text-color: #e6e8eb;
      --muted-color: #9aa3af;
      --border-color: #2a2f3a;
      --primary-color: hsl(217 91% 62%);
    }
  }
  .d3-arch[data-theme="light"] { --page-bg:#fff; --surface-bg:#f7f8fa; --text-color:#1a1d21; --muted-color:#6b7280; --border-color:#d5d9e0; --primary-color:hsl(217 91% 55%); }
  .d3-arch[data-theme="dark"]  { --page-bg:#0f1115; --surface-bg:#171a21; --text-color:#e6e8eb; --muted-color:#9aa3af; --border-color:#2a2f3a; --primary-color:hsl(217 91% 62%); }

  .d3-arch .diagram-scroll { overflow-x: auto; }
  .d3-arch svg { display: block; width: 100%; max-width: 100%; height: auto; font-family: inherit; }

  /* Group boxes */
  .d3-arch .group rect { fill: none; stroke: var(--border-color); stroke-dasharray: 3 3; rx: 12px; }
  .d3-arch .group text { font-size: 10px; font-weight: 700; letter-spacing: 0.08em; text-transform: uppercase; fill: var(--muted-color); }

  /* Nodes */
  .d3-arch .node rect { fill: var(--surface-bg); stroke: var(--border-color); stroke-width: 1; transition: stroke 0.15s ease, opacity 0.15s ease; }
  .d3-arch .node .node-title { font-size: 12px; font-weight: 600; fill: var(--text-color); }
  .d3-arch .node .node-sub { font-size: 9.5px; fill: var(--muted-color); }
  .d3-arch .node { cursor: default; transition: opacity 0.15s ease; }

  /* Edges */
  .d3-arch .edge { transition: opacity 0.15s ease; }
  .d3-arch .edge path.main { fill: none; stroke-width: 1.5; }
  .d3-arch .edge.data path.main { stroke: var(--primary-color); }
  .d3-arch .edge.event path.main { stroke: var(--muted-color); stroke-dasharray: 5 4; }
  .d3-arch .edge text { font-size: 9.5px; fill: var(--muted-color); paint-order: stroke; stroke: var(--page-bg); stroke-width: 3px; stroke-linejoin: round; }

  /* Hover highlighting */
  .d3-arch.hovering .edge:not(.hl) { opacity: 0.12; }
  .d3-arch.hovering .node:not(.hl):not(.nb) { opacity: 0.25; }
  .d3-arch .node.hl rect { stroke: var(--primary-color); stroke-width: 1.5; }

  /* Flow animation */
  .d3-arch .flow-dot.data { fill: var(--primary-color); stroke: var(--page-bg); stroke-width: 1.5; }
  .d3-arch .flow-dot.event { fill: var(--page-bg); stroke: var(--muted-color); stroke-width: 1.5; }
  .d3-arch .node.anim-hl rect { stroke: var(--primary-color); stroke-width: 1.5; }
  .d3-arch .replay-btn { font: inherit; font-size: 11px; font-weight: 600; padding: 4px 10px; border: 1px solid var(--border-color); border-radius: 8px; background: var(--surface-bg); color: var(--text-color); cursor: pointer; transition: border-color 0.15s ease, opacity 0.15s ease; }
  .d3-arch .replay-btn:hover:not(:disabled) { border-color: var(--primary-color); }
  .d3-arch .replay-btn:disabled { opacity: 0.45; cursor: default; }
  .d3-arch .replay-btn:focus-visible { outline: 2px solid var(--primary-color); outline-offset: 1px; }

  /* Legend */
  .d3-arch .legend { display: flex; flex-direction: column; align-items: flex-start; gap: 6px; margin-top: 10px; }
  .d3-arch .legend-title { font-size: 12px; font-weight: 700; color: var(--text-color); }
  .d3-arch .legend .items { display: flex; flex-wrap: wrap; gap: 8px 18px; align-items: center; }
  .d3-arch .legend .item { display: inline-flex; align-items: center; gap: 7px; white-space: nowrap; font-size: 12px; color: var(--text-color); }
  .d3-arch .legend .swatch { width: 22px; height: 0; }
  .d3-arch .legend .swatch.data-line { border-top: 2.5px solid var(--primary-color); }
  .d3-arch .legend .swatch.event-line { border-top: 2.5px dashed var(--muted-color); }
  .d3-arch .legend .hint { font-size: 11px; font-style: italic; color: var(--muted-color); }
</style>
<script>
  (() => {
    const SPEC = ({"title": "", "ariaLabel": "", "width": 803, "height": 568, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "U", "x": 409, "y": 24, "w": 212, "h": 78, "title": ["위층 · 인프라 자본비용 상승", "HBM4 GB당 53달러 · 랙 2100만 달러", "· 전력 병목"]}, {"id": "D", "x": 156, "y": 32, "w": 198, "h": 62, "title": ["아래층 · 추론 가격 붕괴", "딥시크 34배 인하 · 메타 4분의 1 가격"]}, {"id": "E", "x": 283, "y": 194, "w": 205, "h": 78, "title": ["가위 한가운데 · 기업", "비싼 인프라 · 남의 가격정책 · 데이터 주권", "리스크"]}, {"id": "H1", "x": 630, "y": 350, "w": 120, "h": 62, "title": ["손잡이 1 · 스케줄링", "유휴 GPU 제거"]}, {"id": "H2", "x": 422, "y": 350, "w": 120, "h": 62, "title": ["손잡이 2 · 라우팅", "난이도별 모델 배분"]}, {"id": "H3", "x": 221, "y": 350, "w": 135, "h": 62, "title": ["손잡이 3 · 온프렘·소버린", "오픈 웨이트 직접 서빙"]}, {"id": "H4", "x": 35, "y": 350, "w": 121, "h": 62, "title": ["손잡이 4 · 정책·감사", "실행을 안전하게 가둠"]}, {"id": "P1", "x": 608, "y": 490, "w": 163, "h": 46, "title": "Paxis 격리 샌드박스·멀티테넌시"}, {"id": "P2", "x": 411, "y": 490, "w": 142, "h": 46, "title": "Paxis CostRouter"}, {"id": "P3", "x": 221, "y": 490, "w": 135, "h": 46, "title": "Paxis 소버린 쿠버네티스"}, {"id": "P4", "x": 24, "y": 490, "w": 142, "h": 46, "title": "Paxis 거버넌스 L0~L3"}], "edges": [{"src": "U", "dst": "E", "kind": "data", "label": "같은 수요에서 갈라진 쌍둥이", "curve": [[515, 102], [515, 148], [515, 148], [445, 194]], "off": "50%"}, {"src": "D", "dst": "E", "kind": "data", "label": "같은 수요에서 갈라진 쌍둥이", "curve": [[255, 94], [255, 148], [255, 148], [326, 194]], "off": "50%"}, {"src": "E", "dst": "H1", "kind": "data", "curve": [[488, 259], [690, 311], [690, 311], [690, 350]]}, {"src": "E", "dst": "H2", "kind": "data", "curve": [[434, 272], [482, 311], [482, 311], [482, 350]]}, {"src": "E", "dst": "H3", "kind": "data", "curve": [[337, 272], [289, 311], [289, 311], [289, 350]]}, {"src": "E", "dst": "H4", "kind": "data", "curve": [[283, 261], [95, 311], [95, 311], [95, 350]]}, {"src": "H1", "dst": "P1", "kind": "data", "line": [690, 412, 690, 490]}, {"src": "H2", "dst": "P2", "kind": "data", "line": [482, 412, 482, 490]}, {"src": "H3", "dst": "P3", "kind": "data", "line": [289, 412, 289, 490]}, {"src": "H4", "dst": "P4", "kind": "data", "line": [95, 412, 95, 490]}]});
    const ensureD3 = (cb) => {
      if (window.d3 && typeof window.d3.select === 'function') return cb();
      let s = document.getElementById('d3-cdn-script');
      if (!s) {
        s = document.createElement('script');
        s.id = 'd3-cdn-script';
        s.src = 'https://cdn.jsdelivr.net/npm/d3@7/dist/d3.min.js';
        document.head.appendChild(s);
      }
      const onReady = () => { if (window.d3 && typeof window.d3.select === 'function') cb(); };
      s.addEventListener('load', onReady, { once: true });
      if (window.d3) onReady();
    };

    const bootstrap = () => {
      const container = document.getElementById('scissorsinfravsinference-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'scissorsinfravsinference-1';
        const NODES = SPEC.nodes || [];
        const EDGES = SPEC.edges || [];
        const GROUPS = SPEC.groups || [];
        const HOP = SPEC.hop || 800;
        const legendCfg = SPEC.legend || {};
        const dataLabel = legendCfg.data || 'Data path';
        const eventLabel = legendCfg.event || 'Event side-channel';

        const byId = Object.fromEntries(NODES.map((n) => [n.id, n]));
        const cx = (n) => n.x + n.w / 2;
        const asTitle = (t) => Array.isArray(t) ? t : [t];

        // Canvas: explicit, else auto from node/group extents + padding
        let W = SPEC.width, H = SPEC.height;
        if (!W || !H) {
          const xs = [], ys = [];
          NODES.forEach((n) => { xs.push(n.x + n.w); ys.push(n.y + n.h); });
          GROUPS.forEach((g) => { xs.push(g.x + g.w); ys.push(g.y + g.h); });
          W = W || Math.max(760, Math.ceil(Math.max(...xs, 0) + 24));
          H = H || Math.ceil(Math.max(...ys, 0) + 20);
        }

        // Tooltip
        container.style.position = container.style.position || 'relative';
        const tip = document.createElement('div');
        Object.assign(tip.style, {
          position: 'absolute', top: '0px', left: '0px',
          transform: 'translate(-9999px, -9999px)', pointerEvents: 'none',
          padding: '8px 10px', borderRadius: '8px', fontSize: '12px', lineHeight: '1.4',
          border: '1px solid var(--border-color)', background: 'var(--surface-bg)',
          color: 'var(--text-color)', boxShadow: '0 4px 24px rgba(0,0,0,.18)',
          opacity: '0', transition: 'opacity .12s ease', maxWidth: '260px', zIndex: '3'
        });
        const tipInner = document.createElement('div');
        tip.appendChild(tipInner);

        const scroll = document.createElement('div');
        scroll.className = 'diagram-scroll';
        container.appendChild(scroll);

        const svg = d3.select(scroll).append('svg')
          .attr('viewBox', `0 0 ${W} ${H}`)
          .attr('preserveAspectRatio', 'xMidYMid meet')
          .attr('role', 'img')
          .attr('aria-label', SPEC.ariaLabel || SPEC.title || 'Architecture diagram');
        svg.style('max-width', W + 'px').style('min-width', Math.min(W, 760) + 'px').style('margin', '0 auto');

        const defs = svg.append('defs');
        const mkMarker = (id, color) => {
          defs.append('marker')
            .attr('id', id).attr('viewBox', '0 0 10 10')
            .attr('refX', 9).attr('refY', 5)
            .attr('markerWidth', 6.5).attr('markerHeight', 6.5)
            .attr('orient', 'auto-start-reverse')
            .append('path').attr('d', 'M 0 0 L 10 5 L 0 10 z').style('fill', color);
        };
        mkMarker(`${uid}-arrow-data`, 'var(--primary-color)');
        mkMarker(`${uid}-arrow-event`, 'var(--muted-color)');

        // Groups
        const groups = svg.append('g');
        GROUPS.forEach((gr) => {
          const g = groups.append('g').attr('class', 'group');
          g.append('rect').attr('x', gr.x).attr('y', gr.y).attr('width', gr.w).attr('height', gr.h).attr('rx', 12);
          if (gr.label) g.append('text').attr('x', gr.lx != null ? gr.lx : gr.x + 12).attr('y', gr.ly != null ? gr.ly : gr.y + 18).text(gr.label);
        });

        // Edges (under nodes)
        const edgeLayer = svg.append('g');
        const curvePath = (p) => `M ${p[0][0]} ${p[0][1]} C ${p[1][0]} ${p[1][1]}, ${p[2][0]} ${p[2][1]}, ${p[3][0]} ${p[3][1]}`;
        EDGES.forEach((e, i) => {
          const kind = e.kind === 'event' ? 'event' : 'data';
          const g = edgeLayer.append('g').attr('class', `edge ${kind}`).attr('data-src', e.src).attr('data-dst', e.dst);
          const marker = `url(#${uid}-arrow-${kind})`;
          if (e.line) {
            const [x1, y1, x2, y2] = e.line;
            e.pathEl = g.append('path').attr('class', 'main').attr('d', `M ${x1} ${y1} L ${x2} ${y2}`).attr('marker-end', marker).node();
            if (e.label) g.append('text').attr('x', e.lx != null ? e.lx : (x1 + x2) / 2).attr('y', e.ly != null ? e.ly : (y1 + y2) / 2 - 6).attr('text-anchor', e.anchor || 'middle').text(e.label);
          } else if (e.curve) {
            e.pathEl = g.append('path').attr('class', 'main').attr('d', curvePath(e.curve)).attr('marker-end', marker).node();
            if (e.label && e.off) {
              const p = e.curve;
              const lp = p[3][0] < p[0][0] ? [p[3], p[2], p[1], p[0]] : p;
              const lpId = `${uid}-lbl-${i}`;
              g.append('path').attr('id', lpId).attr('d', curvePath(lp)).attr('fill', 'none').attr('stroke', 'none');
              g.append('text').attr('dy', -5).append('textPath').attr('href', `#${lpId}`).attr('startOffset', e.off).attr('text-anchor', 'middle').text(e.label);
            } else if (e.label) {
              g.append('text').attr('x', e.lx).attr('y', e.ly).attr('text-anchor', e.anchor || 'start').text(e.label);
            }
          }
        });

        // Nodes (over edges)
        const nodeLayer = svg.append('g');
        NODES.forEach((n) => {
          const g = nodeLayer.append('g').attr('class', 'node').attr('data-id', n.id);
          g.append('rect').attr('x', n.x).attr('y', n.y).attr('width', n.w).attr('height', n.h).attr('rx', 9);
          const title = asTitle(n.title);
          const lines = title.length;
          const baseY = n.y + n.h / 2 - (lines - 1) * 7 - (n.sub ? 5 : -4);
          title.forEach((t, li) => {
            g.append('text').attr('class', 'node-title').attr('x', cx(n)).attr('y', baseY + li * 14).attr('text-anchor', 'middle').text(t);
          });
          if (n.sub) g.append('text').attr('class', 'node-sub').attr('x', cx(n)).attr('y', baseY + (lines - 1) * 14 + 15).attr('text-anchor', 'middle').text(n.sub);
        });

        // Hover highlighting
        const edgeSel = svg.selectAll('.edge');
        const nodeSel = svg.selectAll('.node');
        nodeSel
          .on('mouseenter', function () {
            const id = this.getAttribute('data-id');
            const n = byId[id];
            container.classList.add('hovering');
            const nb = new Set([id]);
            edgeSel.classed('hl', function () {
              const hit = this.getAttribute('data-src') === id || this.getAttribute('data-dst') === id;
              if (hit) { nb.add(this.getAttribute('data-src')); nb.add(this.getAttribute('data-dst')); }
              return hit;
            });
            nodeSel.classed('hl', function () { return this.getAttribute('data-id') === id; })
                   .classed('nb', function () { return nb.has(this.getAttribute('data-id')); });
            if (n && n.desc) { tipInner.innerHTML = `<strong>${asTitle(n.title).join('')}</strong><br>${n.desc}`; tip.style.opacity = '1'; }
          })
          .on('mousemove', function (event) {
            const [mx, my] = d3.pointer(event, container);
            const flip = mx > container.clientWidth - 280;
            tip.style.transform = `translate(${flip ? mx - 270 : mx + 14}px, ${my + 14}px)`;
          })
          .on('mouseleave', function () {
            container.classList.remove('hovering');
            edgeSel.classed('hl', false);
            nodeSel.classed('hl', false).classed('nb', false);
            tip.style.opacity = '0';
            tip.style.transform = 'translate(-9999px, -9999px)';
          });

        // Flow animation sequence: explicit SEQ, else auto forward-cascade of data edges
        const resolveEdge = (s) => {
          if (typeof s.e === 'number') return s.e;
          if (s.from && s.to) return EDGES.findIndex((e) => e.src === s.from && e.dst === s.to);
          return -1;
        };
        let SEQ = (SPEC.seq || []).map((s) => ({ e: resolveEdge(s), t0: s.t0 })).filter((s) => s.e >= 0);
        if (!SEQ.length) {
          let t = 0;
          EDGES.forEach((e, i) => { if ((e.kind || 'data') === 'data') { SEQ.push({ e: i, t0: t }); t += HOP; } });
        }
        const TOTAL = SPEC.total || (Math.max(0, ...SEQ.map((s) => s.t0)) + HOP + 800);

        let playing = false, replayBtn = null;
        const pulseNode = (id) => {
          const sel = nodeSel.filter(function () { return this.getAttribute('data-id') === id; });
          sel.classed('anim-hl', true);
          setTimeout(() => sel.classed('anim-hl', false), 550);
        };
        const play = () => {
          if (playing) return;
          playing = true;
          if (replayBtn) replayBtn.disabled = true;
          const layer = svg.append('g');
          const steps = SEQ.map((s) => {
            const edge = EDGES[s.e];
            return { ...s, edge, len: edge.pathEl.getTotalLength(), dot: null, arrived: false };
          });
          const start = performance.now();
          const frame = (now) => {
            const t = now - start;
            steps.forEach((s) => {
              if (t < s.t0) return;
              const f = Math.min(1, (t - s.t0) / HOP);
              if (f >= 1) { if (s.dot) { s.dot.remove(); s.dot = null; } if (!s.arrived) { s.arrived = true; pulseNode(s.edge.dst); } return; }
              if (!s.dot) s.dot = layer.append('circle').attr('class', `flow-dot ${s.edge.kind || 'data'}`).attr('r', (s.edge.kind === 'event') ? 4 : 5);
              const p = s.edge.pathEl.getPointAtLength(d3.easeCubicInOut(f) * s.len);
              s.dot.attr('cx', p.x).attr('cy', p.y);
            });
            if (t < TOTAL) requestAnimationFrame(frame);
            else { layer.remove(); playing = false; if (replayBtn) replayBtn.disabled = false; }
          };
          requestAnimationFrame(frame);
        };

        // Legend
        const legend = document.createElement('div');
        legend.className = 'legend';
        legend.innerHTML = `
          <div class="legend-title">${SPEC.legendTitle || 'Legend'}</div>
          <div class="items">
            <span class="item"><span class="swatch data-line"></span><span>${dataLabel}</span></span>
            <span class="item"><span class="swatch event-line"></span><span>${eventLabel}</span></span>
            <button class="replay-btn" type="button" aria-label="Replay the flow animation">&#9654; Replay</button>
            <span class="hint">${SPEC.hint || 'Hover a component to trace its connections.'}</span>
          </div>`;
        container.appendChild(legend);
        container.appendChild(tip);
        replayBtn = legend.querySelector('.replay-btn');
        replayBtn.addEventListener('click', play);

        const prefersReduced = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
        if (!prefersReduced && window.IntersectionObserver) {
          const io = new IntersectionObserver((entries) => {
            entries.forEach((en) => { if (en.isIntersecting) { io.disconnect(); play(); } });
          }, { threshold: 0.5 });
          io.observe(container);
        }
      } catch (err) {
        const pre = document.createElement('pre');
        pre.style.color = '#c0392b';
        pre.style.fontSize = '12px';
        pre.textContent = 'Failed to render architecture diagram: ' + (err && err.message ? err.message : err);
        container.appendChild(pre);
      }
    };

    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', () => ensureD3(bootstrap), { once: true });
    else ensureD3(bootstrap);
  })();
</script>
{% endraw %}

## 가위는 벌어질수록 손잡이가 중요해집니다

오늘의 두 숫자는 앞으로도 더 멀리 벌어질 가능성이 큽니다. 메모리 공급이 2028년까지 타이트하고 전력 병목은 몇 년의 인허가를 요구하니 위층은 쉽게 내려오지 않습니다. 반대로 자체 칩과 초저가 모델의 물결은 아래층을 계속 끌어내립니다. 이럴수록 승부는 두 날 자체가 아니라 그 사이를 쥐는 손잡이에서 갈립니다. 랙 값과 추론 값이라는 두 개의 숫자를 읽을 때, 그 사이에 놓인 스케줄링과 라우팅과 주권과 안전을 함께 읽어야 하는 이유입니다. 오늘의 뉴스는 어느 모델이 이겼는지를 묻지 않았습니다. 대신 그 모델을 굴리는 비용과 그 비용을 다루는 방식을 물었습니다. 가위의 한가운데에서 흔들리지 않으려면, 먼저 손잡이를 어디에 두었는지부터 확인해야 합니다.

<!-- nlm-visual -->
![핵심 개념 요약 인포그래픽 2](/assets/images/posts/news/ai-price-scissors-infra-vs-inference/nlm-infographic-2.png)
*NotebookLM이 소스를 종합해 생성한 인포그래픽입니다.*

## 참고 자료

- [엔비디아 루빈 울트라 랙 예상 판매가 2100만 달러](https://tech.ifeng.com/c/8uco339RORc) · 펑황망
- [번스타인, 엔비디아 베라 루빈 랙 910만 달러 전망…HBM4 가격 급등이 원가 압박](https://www.weeklypost.kr/news/articleView.html?idxno=11422) · 위클리포스트
- ['40조 잭팟' SK하이닉스, 알리바바도 넘었다…역대급 기록](https://www.hankyung.com/article/2026071072846) · 한국경제
- [마이크론, 미국 반도체 투자 2500억 달러로 확대…뉴욕 팹 착공](https://www.thelec.net/news/articleView.html?idxno=12157) · 디일렉
- [삼성전자 "HBM·로직·실리콘포토닉스 묶는 2.xD 개발 중"](http://inews24.com/view/1984212) · 아이뉴스24
- [딥시크, 75% 인하를 영구화하다…AI 가격 전쟁 격화](https://thenextweb.com/news/deepseek-v4-pro-75-percent-price-cut-permanent) · TheNextWeb
- [메타, 뮤즈 스파크 1.1 API 100만 토큰당 1.25/4.25달러 책정](https://aiweekly.co/alerts/meta-prices-muse-spark-11-api-at-125425-per-m-tokens) · AI Weekly
- [메타의 새 AI 칩, 9월부터 양산 시작](https://techcrunch.com/2026/07/09/metas-new-ai-chips-will-begin-production-in-september/) · TechCrunch
- [스타트업 린디, 클로드를 버리고 딥시크로 전환해 수백만 달러 절감](https://the-decoder.com/ai-startup-lindy-ditched-claude-entirely-for-deepseek-saving-millions-as-cost-pressure-mounts-on-anthropic/) · The Decoder
- [과기정통부·KISA, 'AI 보안 레드티밍 가이드' 발간](https://www.digitaltoday.co.kr/news/articleView.html?idxno=682799) · 디지털투데이

## 관련 슬라이드

본문 내용을 NotebookLM(`academic_edge` 스타일)으로 요약한 슬라이드입니다.

![ai-price-scissors-infra-vs-inference 슬라이드 1](/assets/images/ai-price-scissors-infra-vs-inference-slide-01.png)

![ai-price-scissors-infra-vs-inference 슬라이드 2](/assets/images/ai-price-scissors-infra-vs-inference-slide-02.png)

![ai-price-scissors-infra-vs-inference 슬라이드 3](/assets/images/ai-price-scissors-infra-vs-inference-slide-03.png)

![ai-price-scissors-infra-vs-inference 슬라이드 4](/assets/images/ai-price-scissors-infra-vs-inference-slide-04.png)

