---
title: "랙 한 대에 2100만 달러, AI의 청구서가 도착하자 병목은 전력으로 내려갔다"
excerpt: "HBM4가 서버 랙 한 대 값을 2100만 달러로 밀어올리고, SK하이닉스는 하루 만에 40조를 조달했습니다. 자본과 전력이 진짜 병목이 된 지금, 승부는 비싼 컴퓨트에서 증명 가능한 일을 뽑아내는 소프트웨어 층으로 내려가고 있습니다."
seo_title: "AI 랙 2100만 달러 시대, 병목은 GPU가 아니라 전력과 증명이다"
seo_description: "2026년 7월 10일 뉴스를 관통하는 축은 자본과 전력입니다. HBM4 랙 2100만 달러, SK하이닉스 40조 ADR, AIDC 5241조 전망을 읽고, ThakiCloud Paxis가 어디서 차별화 창을 여는지 짚습니다."
date: 2026-07-10
last_modified_at: 2026-07-10
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "robot"
tags:
  - ai-infrastructure
  - hbm4
  - data-center-power
  - sovereign-ai
  - model-economics
  - agent-native-cloud
  - cost-routing
categories:
  - news
canonical_url: "https://thakicloud.com/tech-blog/ko/news/ai-rack-2100-manwon-power-bottleneck/"
published: false
---

![서버 랙으로 좁아져 들어가는 전력 병목과 그 위 소프트웨어 층을 나타낸 개념도]({{ '/assets/images/ai-rack-2100-manwon-power-bottleneck-hero.webp' | relative_url }})

계산서 한 장을 상상해 보겠습니다. 품목은 서버 랙 한 대, 금액은 2100만 달러. 우리 돈으로 약 316억 원입니다. 오늘 글로벌이코노믹이 전한 엔비디아 차세대 루빈 울트라 랙의 예상 단가입니다. 불과 한 세대 전 블랙웰 랙이 300만에서 400만 달러였으니, 다섯 배에서 일곱 배 뛴 셈입니다. 이 청구서에서 가장 큰 항목은 연산 칩이 아니라 메모리입니다. 랙 하나에 실리는 HBM4e만 8만 2944기가바이트, 기가바이트당 18.49달러로 계산하면 메모리 단품값만 153만 달러를 넘습니다. 이전 세대 서버 랙 전체 가격에 육박하는 금액이 이제는 부품 하나의 값입니다. 오늘 다이제스트를 관통하는 이야기는 여기서 시작합니다. AI 경쟁의 단위가 성능 지표에서 돈과 전력으로 넘어갔다는 것입니다.

## 돈의 단위가 바뀌었다

숫자의 규모부터 낯설어졌습니다. SK하이닉스는 나스닥 상장을 위한 미국예탁증서 공모가를 주당 149달러로 확정했습니다. 총 265억 달러, 약 40조 원 규모로, 2014년 알리바바의 250억 달러를 넘어 외국 기업의 미국 상장 가운데 역대 최대입니다. 시가총액이 1조 달러를 돌파한 회사가 달러를 직접 끌어와 용인과 청주 팹의 극자외선 장비, 해외 첨단 패키징에 붓겠다고 합니다. 마이크론은 2035년까지 미국에만 2500억 달러, 약 376조 원을 투입한다고 계획을 또 키웠습니다. 메타는 올해 자본지출 가이던스로만 1150억에서 1350억 달러를 제시했습니다.

이 돈이 어디로 흘러가는지 보면 방향이 뚜렷합니다. 전부 메모리 증설, 데이터센터 건설, 반도체 확보로 향합니다. 뱅크오브아메리카와 모건스탠리 같은 투자은행은 이 단가 급등을 한국 메모리 기업 가치의 근거이자 동시에 빅테크 설비투자를 위축시킬 하방 위험으로 함께 봅니다. 값이 오른다는 건 파는 쪽에는 기회지만, 그 값을 치르고 서비스를 돌려야 하는 쪽에는 부담입니다. 랙 값의 절반이 메모리로 채워지는 구조가 굳어지면, GPU 클라우드 사업자는 차세대 랙 도입 시점을 언제로 잡느냐만으로도 마진의 방향이 갈립니다.

경쟁의 전선이 칩 하나에 머물지 않는다는 점도 눈에 띕니다. 삼성전자는 HBM과 로직, 실리콘포토닉스를 한 패키지로 묶는 2.xD 이종집적을 개발 중이라고 밝혔고, AI PC용 가속기 가이아로 온디바이스 추론 시장에도 발을 들였습니다. 가이아는 프로세싱 인 메모리를 결합해 데이터 이동을 줄이고 전력 효율을 끌어올리는 방향을 잡았습니다. 연산을 빠르게 만드는 싸움이 곧 전력을 아끼는 싸움과 같아졌다는 뜻입니다. 이 흐름은 GPU 클라우드 사업자에게도 앞으로 엔비디아 한 곳이 아니라 NPU와 프로세싱 인 메모리까지 아우르는 멀티벤더 하드웨어를 준비해야 한다는 숙제를 남깁니다.

## 병목은 GPU에서 전력으로 내려갔다

더 흥미로운 신호는 병목이 이동한 자리입니다. 조세일보가 전한 이야기는 상징적입니다. 코인을 캐던 기업들이 AI 인프라 회사로 변신하고 있는데, 그들이 가진 진짜 자산은 채굴기가 아니라 전력이었습니다. 코인셰어스 보고서에 따르면 상장 채굴 기업 매출에서 AI와 고성능컴퓨팅이 차지하는 비중이 지금 약 30퍼센트에서 연말 최대 70퍼센트까지 오를 전망이고, 지난 1년간 맺은 관련 계약만 700억 달러를 넘습니다. 테라울프는 앤트로픽과 20년 장기 임대를 맺어 2028년 초까지 401메가와트로 확장하고, IREN은 오클라호마 부지를 더해 전력 파이프라인을 4.5기가와트까지 늘렸습니다. 값싼 전력 계약과 변전 설비를 먼저 쥔 쪽이 승자가 된 것입니다.

한국도 다르지 않습니다. 중앙일보는 노무라 전망을 인용해 전 세계 AI 데이터센터 투자가 2025년 723조 원에서 2030년 5241조 원으로 연평균 48퍼센트씩 불어난다고 전했습니다. 정부는 지난달 29일 3대 메가프로젝트를 발표하며 1단계로 8.4기가와트 규모 데이터센터에 550조 원을 넣고, 2035년까지 총 18.4기가와트, 누적 1000조 원을 넘기겠다고 했습니다. SK는 AWS와 손잡고 2029년 5기가와트를 열어 2035년 15기가와트로 키우고, KT는 5년간 5조 원으로 전국 25곳에 실수요 기반 시설을 짓겠다고 선언했습니다. SK텔레콤이 5기가와트급 데이터센터로 승부수를 던진다는 소식도 같은 맥락에 놓입니다. 공통된 병목은 하나로 모입니다. 전력, 냉각, 부지입니다. 한전 계통 연계 지연과 변전소 인허가가 확장의 최대 제약으로 꼽히는 현실에서, 전력을 선점한 사업자가 구조적 우위를 갖는다는 미국의 교훈은 국내에도 그대로 옮겨옵니다.

규모 경쟁이 대기업 컨소시엄으로 재편되는 국면에서, 작은 사업자에게 남는 길이 아예 없는 것은 아닙니다. LG유플러스는 파주에 200메가와트를 공급하는 시설을 짓고, LG씨엔에스는 컨테이너 하나에 GPU 576장을 담는 모듈형 소형 데이터센터를 준비합니다. KT의 에지 전략처럼 산업 현장 가까이 설비를 붙여 지연을 줄이는 접근도 있습니다. 하이퍼스케일 부지를 두고 정면으로 붙기 어려운 사업자라면, 모듈형과 에지, 전력 계약 다변화 같은 틈새에서 밀도를 높이는 편이 현실적인 선택입니다.

## 그런데 그 돈은 성과로 돌아오고 있는가

여기서 반대 방향의 질문을 던져야 정직한 그림이 나옵니다. 이 사상 최대의 자본은 정말 성과로 회수되고 있을까요. 오늘 뉴스는 오히려 반대 신호를 보냅니다. 네이버는 2분기에 매출 3조 3562억 원, 영업이익 5701억 원으로 역대 2분기 최대를 예고했는데, 주가는 6월 1일 신고가 30만 4000원에서 한 달여 만에 7월 9일 18만 4400원까지 내려앉았습니다. 카카오는 지피티 인 카카오 누적 이용자가 1100만 명에 이르렀지만 수익화 증거가 부족하다는 이유로 증권사들이 일제히 목표주가를 낮췄습니다. 사상 최대 실적을 내고도 웃지 못하는 이유는 단순합니다. 시장은 이제 투자가 아니라 회수를 묻습니다.

빅테크의 반응은 더 직설적입니다. 메타는 오픈소스 노선을 접고 첫 유료 모델 뮤즈 스파크 1.1을 내놓았습니다. 출력 100만 토큰당 4.25달러로, 오픈AI와 앤트로픽 최고급 모델의 약 25퍼센트 수준입니다. 저커버그는 데이터센터와 GPU를 외부에 빌려주는 컴퓨팅 임대 사업까지 저울질하며 사내에 메타 컴퓨트라는 별도 조직을 꾸렸습니다. 4월에 코어위브와 최대 210억 달러 규모 컴퓨팅 임대 계약을 맺은 데 이어, 이번에는 스스로 코어위브 같은 컴퓨팅 공급자가 되겠다는 것입니다. 수천억 달러를 부어놓고 이제 그것으로 돈을 벌겠다는 선언입니다. 한쪽에서는 딥시크가 출력 100만 토큰당 0.87달러로 오픈AI보다 34배 싼 가격을 앞세워 개발자 트래픽의 상당 부분을 흡수하고 있습니다. 오픈라우터 통계에서 중국 오픈소스 모델의 점유율이 한때 46퍼센트까지 치솟았다는 수치는 이 흐름이 취향이 아니라 원가 문제임을 보여줍니다. 승부의 축이 더 좋은 모델을 누가 만드느냐에서 누가 실제로 돈을 버느냐로 넘어갔다는 평가가 나오는 배경입니다.

네이버의 사례는 이 시차를 숫자로 드러냅니다. 엔비디아와 손잡은 AI 팩토리는 55메가와트에서 2028년 200메가와트를 거쳐 최종 1기가와트까지 키우고 장기적으로 연매출 20조 원을 노리는 사업이지만, 정작 GPU 투자에 따른 감가상각비가 단기 영업이익률을 눌렀습니다. 인프라를 먼저 짓고 회수는 나중이라는 구조가 대형 플랫폼에서도 예외가 아니라는 뜻입니다. 투자자가 사용량이 아니라 계약과 매출이라는 증거를 요구하는 이유가 여기에 있습니다.

## 비싼 컴퓨트를 증명 가능한 일로 바꾸는 층

정리하면 이렇습니다. 자본은 반도체와 전력으로 쏟아지고, 그 위에서 서비스를 돌리는 기업은 회수를 증명하라는 압박을 받습니다. 그렇다면 진짜 가치가 만들어지는 자리는 하드웨어 아래가 아니라 그 위, 비싼 컴퓨트 한 사이클을 낭비 없이 성과로 바꾸는 소프트웨어 층입니다. ThakiCloud가 Paxis를 에이전트 네이티브 클라우드로 설계한 이유가 여기에 맞닿아 있습니다.

작업마다 모델을 골라 쓰는 CostRouter는 딥시크와 메타의 저가 API가 열어놓은 선택지를 그대로 무기로 씁니다. 이메일 분류나 문서 요약처럼 토큰에 민감한 워크로드는 값싼 모델로 흘리고, 정교한 추론이 필요한 구간에만 비싼 모델을 배치하면 같은 결과를 더 낮은 원가로 냅니다. 랙 한 대의 값이 폭발하는 시대에 원가를 지키는 길은 더 싼 하드웨어가 아니라, 매 호출을 적정 모델로 라우팅하는 소프트웨어 규율입니다.

정책 게이트와 감사 로그는 네이버와 카카오가 겪는 증명의 압박에 대한 답이기도 합니다. Paxis는 스킬과 툴, 정책, 감사 로그를 일급 리소스로 다루고, 에이전트의 자율도를 L0에서 L3까지 단계로 관리합니다. 에이전트가 무슨 권한으로 어떤 일을 했는지 기록으로 남으면, 사용량이 아니라 실제로 처리한 일을 근거로 성과를 말할 수 있습니다. 어떤 작업은 사람이 승인하고 어떤 작업은 완전히 위임할지를 정책으로 나누면, 회수를 묻는 질문 앞에서 숫자 대신 근거를 내밀 수 있습니다. 알리페이가 위임 인증과 거래 추적으로 3억 건의 에이전트 결제를 쌓아 신뢰 계층을 만든 것도 같은 문법입니다.

주권의 문제도 그대로 겹칩니다. 한 기자수첩은 소버린 AI를 외치는 자리에서 정작 가장 선명하게 남은 단어가 엔비디아였다고 꼬집었습니다. 정부는 초과세수 5조 원으로 엔비디아 베라루빈 GPU 1만 개를 확보하고 2030년까지 국산 반도체 비중을 절반으로 늘리겠다고 하지만, 데이터와 모델까지가 주권인지 컴퓨팅과 반도체까지 포함하는지 기준은 아직 흐릿합니다. 이 공백은 온프렘 쿠버네티스 위에서 데이터가 나가지 않는 소버린 스택을 실제로 굴려 보인 사업자에게 포지셔닝의 창이 됩니다. 대형 사업자가 소버린을 표방하면서도 엔비디아 생태계에 깊이 편입되는 사이, 컴퓨팅 국산화와 데이터 주권을 실제 레퍼런스로 쌓는 쪽이 기준이 확정되기 전에 앞서갈 수 있습니다.

보안은 이 신뢰의 마지막 고리입니다. 과기정통부와 KISA가 이번 주 펴낸 AI 보안 레드티밍 가이드는 프롬프트 인젝션과 에이전트 하이재킹을 포함한 8대 위협을 규정하고 위험을 5단계로 나눴습니다. 에이전트가 외부 문서나 웹페이지에 숨은 악성 지시에 휘둘리는 하이재킹은, 모든 실행을 격리 샌드박스 안에 가두는 구조로 정면 대응할 수 있습니다. 금융과 공공 조달에서 레드티밍 이력이 요건으로 굳어질 국면에서, 격리 수준을 정량으로 입증하는 아키텍처는 규제 대응인 동시에 그 자체가 조달 경쟁력이 됩니다.

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
<div class="d3-arch" data-arch-root id="100manwonpowerbottleneck-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 978, "height": 694, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "C", "x": 383, "y": 24, "w": 191, "h": 78, "title": ["자본 폭증", "랙 2100만 달러 · SK하이닉스 40조", "ADR · 마이크론 2500억 달러"]}, {"id": "B", "x": 400, "y": 180, "w": 156, "h": 62, "title": ["병목 이동 · GPU에서 전력으로", "전력 · 냉각 · 부지"]}, {"id": "R", "x": 372, "y": 320, "w": 212, "h": 62, "title": ["회수 압박", "네이버·카카오 · 사상 최대 실적에도 주가 하락"]}, {"id": "S", "x": 372, "y": 460, "w": 212, "h": 62, "title": ["가치가 만들어지는 소프트웨어 층", "비싼 컴퓨트 한 사이클을 증명 가능한 일로 전환"]}, {"id": "P1", "x": 755, "y": 600, "w": 191, "h": 62, "title": ["CostRouter · 매 호출 적정 모델", "라우팅"]}, {"id": "P2", "x": 502, "y": 608, "w": 198, "h": 46, "title": "정책·감사 로그 · 사용량 아닌 성과로 증명"}, {"id": "P3", "x": 263, "y": 608, "w": 184, "h": 46, "title": "소버린 온프렘 쿠버네티스 · 데이터 주권"}, {"id": "P4", "x": 24, "y": 608, "w": 184, "h": 46, "title": "격리 샌드박스 · 하이재킹·레드티밍 방어"}], "edges": [{"src": "C", "dst": "B", "kind": "data", "line": [478, 102, 478, 180]}, {"src": "B", "dst": "R", "kind": "data", "line": [478, 242, 478, 320]}, {"src": "R", "dst": "S", "kind": "data", "line": [478, 382, 478, 460]}, {"src": "S", "dst": "P1", "kind": "data", "curve": [[584, 511], [851, 561], [851, 561], [851, 600]]}, {"src": "S", "dst": "P2", "kind": "data", "curve": [[532, 522], [601, 561], [601, 561], [601, 608]]}, {"src": "S", "dst": "P3", "kind": "data", "curve": [[424, 522], [355, 561], [355, 561], [355, 608]]}, {"src": "S", "dst": "P4", "kind": "data", "curve": [[372, 511], [116, 561], [116, 561], [116, 608]]}]});
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
      const container = document.getElementById('100manwonpowerbottleneck-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '100manwonpowerbottleneck-1';
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

청구서 이야기로 돌아가 보겠습니다. 랙 한 대에 2100만 달러가 찍히는 시대에, 가장 비싼 낭비는 그 랙 위에서 엉뚱한 모델에 엉뚱한 일을 시키고도 무엇을 했는지 설명하지 못하는 것입니다. 자본과 전력은 이미 격전지가 되었습니다. 다음 격전지는 그 위에서 매 사이클을 증명 가능한 일로 바꾸는 층이고, ThakiCloud는 바로 그 자리를 겨냥하고 있습니다.

## 참고 자료

- [엔비디아 루빈 울트라 랙 예상 판매가 2100만 달러](https://tech.ifeng.com/c/8uco339RORc) · 펑황망
- ['40조 잭팟' SK하이닉스, 알리바바도 넘었다…역대급 기록](https://www.hankyung.com/article/2026071072846) · 한국경제
- [마이크론, 미국 반도체 투자 2500억 달러로 확대…뉴욕 팹 착공](https://www.thelec.net/news/articleView.html?idxno=12157) · 디일렉
- [메타, 2026년 자본지출 1150억~1350억 달러로 전망…데이터센터 지출 확대](https://www.datacenterdynamics.com/en/news/meta-estimates-2026-capex-to-be-between-115-135bn/) · Data Center Dynamics
- [AI 데이터센터, 지방에 '1000조' 투자…남은 숙제는 '수요'](https://www.mt.co.kr/tech/2026/07/01/2026070110330467488) · 머니투데이
- [과기부총리 "AIDC에 2029년까지 550조, 2035년까지 1000조 이상 투자"](https://www.fnnews.com/news/202606291445337094) · 파이낸셜뉴스
- [비트코인 채굴기업들이 AI 회사로 변신하며 전환 자금을 위해 BTC를 매각한다](https://www.coindesk.com/markets/2026/03/27/bitcoin-miners-are-becoming-ai-companies-and-selling-their-btc-to-fund-the-transition) · CoinDesk
- [테라울프, 저스티파이드 데이터 캠퍼스에서 앤스로픽과 임대 계약 발표](https://investors.terawulf.com/news-events/press-releases/detail/142/terawulf-announces-anthropic-lease-at-justified-data-campus-and-sale-of-majority-interest-in-abernathy-joint-venture-to-fluidstack) · TeraWulf
- [네이버·카카오 2분기 실적도 광고, 커머스가 살렸다](https://zdnet.co.kr/view/?no=20260708165303) · ZDNet Korea
- [초과세수 5조 투입…'소버린 AI' 개발한다](https://www.hankyung.com/article/2026070228011) · 한국경제
