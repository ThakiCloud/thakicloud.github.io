---
title: "리더보드 1위가 아무도 안 사는 이유: 벤치마크가 사주지 못하는 것"
excerpt: "중국 키미 K3가 코딩 리더보드에서 클로드를 제쳤는데 실리콘밸리는 냉담합니다. 같은 주에 구글은 제미나이 3.5를 세 번째로 미뤘습니다. 성능 정점에서 산업이 깨닫는 진실은 하나입니다. 벤치마크 점수는 배포 신뢰를 사주지 못합니다."
seo_title: "벤치마크 1위 모델이 안 팔리는 이유와 실행 계층의 값어치"
seo_description: "키미 K3의 리더보드 1위와 제미나이 3.5 지연이 같은 주에 겹쳤습니다. 능력이 싸지고 흔해질수록 기업이 진짜 지불하는 것은 통제된 실행입니다. 그 실행 계층을 Paxis 관점에서 읽습니다."
date: 2026-07-18
last_modified_at: 2026-07-18
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "robot"
tags:
  - agentops
  - paxis
  - enterprise-ai
  - thakicloud
categories:
  - agentops
canonical_url: "https://thakicloud.com/tech-blog/ko/agentops/benchmark-wins-trust-gap-execution-layer/"
audiobook: "https://drive.google.com/file/d/1cwH-1XNXm0a_ZambJZqwji-d90Dwbvzb/view"
audiobook_label: "▶ 5분 브리핑으로 듣기"
audiobook_note: "NotebookLM 오디오 개요 (AI 생성)"
published: false
---

리더보드 화면을 캡처하는 순간이 있습니다. 어느 신생 모델이 익숙한 1등의 이름을 밀어내고 맨 위에 올라선 장면입니다. 2026년 7월, 중국 문샷AI의 오픈웨이트 모델 키미 K3가 바로 그 캡처를 만들어냈습니다. AI 평가 플랫폼 아레나의 프런트엔드 코딩 리더보드에서 앤스로픽 클로드 페이블 5를 제치고 1위에 올랐고, 매개변수 2조8000억개로 지금까지 공개된 오픈웨이트 모델 중 가장 큽니다. API 가격도 절반 이하입니다. 디지털투데이가 전한 실리콘밸리의 반응은 그런데 환호가 아니라 한 문장이었습니다. "벤치마크는 이겼는데 글쎄."

이 냉담함이 오늘의 진짜 뉴스입니다. 그리고 같은 주에 정반대 방향의 장면이 하나 더 겹쳤습니다.

![리더보드 1위가 아무도 안 사는 이유: 벤치마크가 사주지 못하는 것 개념을 형상화한 이미지](/assets/images/benchmark-wins-trust-gap-execution-layer-hero.webp)
*이번 주 뉴스의 핵심 흐름을 형상화했습니다.*

## 정상에서 멈칫한 두 장면

구글은 순다르 피차이 CEO가 5월 개발자 행사에서 6월 출시를 직접 공언했던 제미나이 3.5 프로를 세 번 연기해 7월로 밀었습니다. 뉴스로드 보도에 따르면 기존 아키텍처를 폐기하고 처음부터 다시 설계하는 전면 재구축을 단행했고, 코딩 성능이 내부 목표치에 미달한 것이 핵심 원인으로 지목됐습니다. 지연 소식 이후 주가가 한때 4%가량 빠졌고, 최근 6일 사이 제미나이 핵심 연구원 네 명이 앤트로픽으로 자리를 옮겼습니다.

뉴스로드는 지연의 배경으로 기술 난이도만 지목하지 않았습니다. 구글 클라우드와 딥마인드, 안드로이드 등 여러 조직이 각자 별도의 AI 코딩 도구를 만들며 자원을 중복 투입하는 구조, 그리고 중요한 코드는 사람이 직접 작성해야 한다는 내부 엔지니어링 문화가 속도를 늦췄다는 지적입니다. 성능의 최전선에서조차 사람이 어디까지 개입하고 무엇을 자동화에 맡길지가 아직 정리되지 않았다는 뜻입니다.

한쪽에서는 신생 오픈웨이트 모델이 리더보드 정상을 찍었는데 시장은 지갑을 열지 않고, 다른 한쪽에서는 프런티어 선두조차 다음 버전을 세 번이나 미룹니다. 두 장면은 모순처럼 보이지만 같은 이야기를 합니다. 성능 곡선의 정점에서, 벤치마크 숫자와 실제 배포 사이의 간극이 그 어느 때보다 크게 벌어졌다는 이야기입니다.

<!-- nlm-visual -->
![이번 주 뉴스 요약 인포그래픽 1](/assets/images/posts/news/benchmark-wins-trust-gap-execution-layer/nlm-infographic-1.webp)
*NotebookLM이 이번 주 뉴스 소스를 종합해 생성한 인포그래픽입니다.*

## 값이 내려갈수록 질문이 바뀝니다

능력 자체는 오히려 흔해지고 있습니다. 조선일보가 정리한 모델 가격표를 보면 경쟁 축은 이미 성능에서 가성비로 넘어갔습니다. 오픈AI GPT-5.6은 고성능 솔과 중저가 테라, 루나로 라인업을 쪼갰고, 메타 뮤즈 스파크는 출력 토큰 기준으로 앤스로픽 페이블 5의 약 12분의 1 가격을 부릅니다. 스페이스X의 그록 4.5는 코딩 평가에서 경쟁 모델보다 출력 토큰을 4배 넘게 적게 쓴다고 주장합니다. 키미 K3의 반값 API도 이 흐름의 한 갈래입니다.

가격이 바닥을 향하면 질문이 바뀝니다. "가장 똑똑한 모델이 무엇인가"에서 "이 능력을 우리 데이터와 업무에서 안전하게, 통제된 채, 감사 가능하게 돌릴 수 있는가"로 옮겨갑니다. 리더보드 1위가 안 팔리는 이유가 여기 있습니다. 기업이 결제하는 대상은 지능지표가 아니라 배포 가능성입니다. 벤치마크는 능력을 증명하지만 신뢰를 증명하지는 못합니다.

## 도입한 사람들이 먼저 말합니다

이 간극을 가장 정직하게 증언하는 쪽은 회의론자가 아니라 이미 도입한 사람들입니다. 도입 자체는 폭발하고 있습니다. 하나투어는 멀티 AI 에이전트 하이(H-AI)를 카카오톡 안의 챗GPT 창과 연동해 별도 앱 설치 없이 여행 추천을 받게 했고, 생성형 AI 검색 최적화를 적용한 뒤 챗GPT를 통한 유입량이 약 850% 늘었습니다. 익숙한 메신저 표면으로 AI가 파고드는 속도는 이렇게 가파른데, 정작 그 결과를 조직이 얼마나 믿고 맡길지는 별개의 곡선을 그립니다.

유통 대기업들은 AI 에이전트를 실제 업무에 깔기 시작했습니다. 롯데칠성음료는 생성형 AI와 OCR, RAG를 결합해 제품 라벨 검토 시간을 절반 이상 줄였고, 동원그룹은 계열사에 AI 사원을 도입해 하반기까지 약 50개를 추가할 계획입니다. 그런데 주간한국이 전한 이 확산 기사에서 딜로이트가 덧붙인 권고가 핵심입니다. 확산 초기 단계에서는 사람이 결과를 검증하고 승인하는 휴먼 인 더 루프 체계를 유지하라는 것입니다.

경영진을 AI로 대체하는 실험을 공개한 뤼튼 박민준 대표의 고백은 더 날카롭습니다. 역할별 AI가 토론해 의견을 내면 대표가 종합해 결정하는 구조를 돌려봤더니, 처음엔 편했지만 한 달 뒤부터는 AI 답변을 재확인하는 데 시간이 더 걸렸다고 했습니다. 그는 AI를 똑똑한 신입사원에 비유하며 회사 데이터와 조직 문화를 충분히 학습시켜야 제 역할을 한다고 강조했습니다.

같은 통증을 시장으로 바꾼 회사도 있습니다. 지란지교소프트가 과기정통부와 KISA의 우수 정보보호 기술로 지정받은 솔루션은 임직원이 챗GPT나 클로드에 무언가를 입력할 때 엔드포인트 단에서 실시간으로 검사해 개인정보와 기업 기밀이 새어 나가는 것을 막고, 프롬프트 입력 이력과 메일 발송 기록을 통합 감사합니다. 능력을 파는 것이 아니라 능력을 안전하게 쓰는 틀을 팝니다. 세 사례가 가리키는 방향은 똑같습니다. 모델이 똑똑해지는 것과 그 모델을 조직이 믿고 맡기는 것은 완전히 다른 문제입니다.

## 국가가 같은 값을 다르게 부릅니다

기업 단위에서 보이는 이 신호는 국가 단위로 올라가면 소버린 AI라는 이름을 답니다. 배경훈 부총리는 업무보고에서 앤트로픽 미토스급 프런티어 모델 개발에는 GPU 약 1만 장이 필요하다며 국가 주도 컴퓨팅 확충을 예고했고, 정부는 12월 전 국민 무료 서비스 모두의 AI를 내놓기로 했습니다. LG AI연구원 컨소시엄은 독자 파운데이션 모델 1차 평가에서 벤치마크와 전문가, 사용자 평가 전 부문 1위를 기록하며 행정안전부 서비스에 실증 적용됐습니다. 일본은 소니와 소프트뱅크, 혼다 등 44개사가 출자한 노에트라 컨소시엄이 엔비디아 루빈 GPU 약 2만7500장을 확보해 국가 AI 인프라를 짓습니다.

이 흐름을 단순한 국가주의로 읽으면 절반만 본 셈입니다. 국가들이 막대한 돈을 자국 모델과 자국 컴퓨팅에 쏟는 진짜 이유는, 능력이 흔해질수록 정작 희소해지는 자원이 통제된 실행이기 때문입니다. 누구의 인프라 위에서, 어떤 정책 아래, 무엇이 기록된 채 모델이 도는가. 국가가 소버린 AI라 부르는 값어치와 기업이 감사 로그와 휴먼 인 더 루프라 부르는 값어치는 규모만 다를 뿐 같은 것입니다.

## 돈도 신중해지기 시작했습니다

능력이 흔해지는 이 국면에서 무한정 쌓아 올리기만 하던 자본도 표정을 바꾸고 있습니다. 글로벌이코노믹이 짚은 대로, AI 설비투자를 지탱해온 하이퍼스케일러들의 신규 채권이 발행가 대비 평균 3.3포인트 하락하며 우량 IT 채권으로서는 이례적인 약세를 보였습니다. 골드만삭스 같은 대형 금융기관은 이들의 기초체력이 튼튼해 채무불이행 위험은 없다며 조기 거품론을 반박했지만, 북미 클라우드 사업자의 설비투자 증가율이 올해 83%에서 내년 23% 수준으로 둔화할 것이라는 전망이 함께 나옵니다. 무작정 짓는 시대가 끝나가고 선별의 시대가 열린다는 신호입니다.

그 비용은 이미 다른 곳으로 번지고 있습니다. 디지털투데이에 따르면 세계 2위 스마트폰 시장인 인도의 2분기 출하량이 6년 만에 최대 폭인 10% 감소했는데, 하이퍼스케일러의 AI 인프라 투자가 D램과 낸드 공급을 잠식해 저가 스마트폰의 메모리 원가를 밀어 올린 것이 원인으로 지목됐습니다. 능력을 원자재처럼 쓰는 세계의 청구서가 인도의 210달러짜리 스마트폰 소비자에게까지 도착한 셈입니다. 능력을 더 쌓는 방향의 수익은 얇아지고, 능력을 더 잘 다루는 방향의 수익이 두꺼워지는 전환이 이렇게 여러 지표에서 동시에 나타납니다.

## 모델을 고르는 시대에서 실행 계층을 소유하는 시대로

메타가 광고 대신 자사 컴퓨팅을 앤트로픽에 100억 달러 규모로 임대하려는 협상까지 겹쳐 보면 그림이 선명해집니다. 컴퓨팅은 상품이 되고, 모델은 반값으로 흔해지고, 리더보드 1위는 매주 바뀝니다. 이렇게 능력이 원자재가 되는 세계에서 값어치는 능력 위가 아니라 능력을 감싸는 실행 계층으로 옮겨갑니다. 어떤 모델을 고르느냐가 아니라 그 모델을 누구의 통제 아래 돌리느냐가 경쟁력이 됩니다.

아래 그림은 이 전환을 한 장으로 요약합니다. 상품이 된 능력이 왜 그 자체로는 배포되지 못하고, 실행 계층이라는 관문을 지나야 기업이 지불하는 통제된 배포가 되는지를 보여줍니다.

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
<div class="d3-arch" data-arch-root id="nstrustgapexecutionlayer-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1585, "height": 1169, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [{"x": 24, "y": 24, "w": 283, "h": 387, "label": "Capability is now a commodity", "lx": 36, "ly": 42}, {"x": 24, "y": 532, "w": 283, "h": 605, "label": "Paxis Agent-Native execution layer", "lx": 36, "ly": 550}], "nodes": [{"id": "M1", "x": 63, "y": 62, "w": 205, "h": 78, "title": ["Kimi K3 tops the coding", "leaderboard at half-price", "API"]}, {"id": "M2", "x": 63, "y": 195, "w": 205, "h": 62, "title": ["GPT-5.6 and Muse Spark up", "to 12x cheaper"]}, {"id": "M3", "x": 67, "y": 312, "w": 198, "h": 62, "title": ["The rank-1 model changes", "almost weekly"]}, {"id": "GAP", "x": 605, "y": 430, "w": 223, "h": 84, "title": ["Can we run it safely,", "controlled and audited on", "our own data"]}, {"id": "CAP", "x": 106, "y": 449, "w": 120, "h": 46, "title": "CAP"}, {"id": "RISK", "x": 1072, "y": 495, "w": 198, "h": 62, "title": ["Adopted but not trusted,", "re-verification fatigue"]}, {"id": "EXEC", "x": 1111, "y": 394, "w": 120, "h": 46, "title": "EXEC"}, {"id": "P1", "x": 67, "y": 570, "w": 198, "h": 62, "title": ["Policy gate and isolated", "sandbox"]}, {"id": "P2", "x": 63, "y": 687, "w": 205, "h": 62, "title": ["Audit logs on every agent", "run"]}, {"id": "P3", "x": 74, "y": 804, "w": 184, "h": 62, "title": ["L0 to L3 autonomy with", "human in the loop"]}, {"id": "P4", "x": 67, "y": 921, "w": 198, "h": 62, "title": ["CostRouter picks a model", "per task"]}, {"id": "P5", "x": 74, "y": 1038, "w": 184, "h": 62, "title": ["On-prem Kubernetes for", "sovereignty"]}, {"id": "VALUE", "x": 1348, "y": 378, "w": 205, "h": 78, "title": ["What enterprises actually", "pay for is controlled", "deployment"]}], "edges": [{"src": "CAP", "dst": "GAP", "kind": "data", "label": "a benchmark score is not deployment trust", "line": [226, 472, 605, 472], "lx": 456, "ly": 468}, {"src": "GAP", "dst": "RISK", "kind": "data", "label": "without governance", "curve": [[828, 498], [950, 526], [950, 526], [1072, 526]], "off": "50%"}, {"src": "GAP", "dst": "EXEC", "kind": "data", "label": "through an execution layer", "curve": [[828, 445], [950, 417], [950, 417], [1111, 417]], "off": "50%"}, {"src": "EXEC", "dst": "VALUE", "kind": "data", "line": [1231, 417, 1348, 417]}]});
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
      const container = document.getElementById('nstrustgapexecutionlayer-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'nstrustgapexecutionlayer-1';
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

ThakiCloud의 Paxis는 정확히 그 실행 계층을 제품으로 만든 Agent-Native Cloud입니다. 스킬과 툴, 정책, 감사 로그를 일급 리소스로 두어, 뤼튼 대표가 겪은 재확인의 피로와 딜로이트가 권고한 휴먼 인 더 루프를 L0에서 L3까지의 자율도 거버넌스로 설계합니다. 사람이 어디까지 손을 떼도 되는지를 감으로 정하지 않고 정책과 게이트로 정합니다. 지란지교소프트가 판 감사 기능은 Paxis에서 모든 에이전트 실행에 붙는 기본값이고, 정책 게이트와 격리 샌드박스는 반값 오픈웨이트 모델을 도입하면서도 기밀이 새지 않게 막는 틀이 됩니다. 가성비로 넘어간 모델 경쟁은 작업마다 다른 모델을 붙이는 CostRouter로 흡수하고, 소버린 AI가 부르는 주권의 요구는 온프렘 쿠버네티스 기반 ai-platform이 받습니다.

리더보드 1위가 안 팔리는 이유를 다시 뒤집으면 답이 됩니다. 기업이 사는 것은 정점의 점수가 아니라 통제된 실행입니다. 벤치마크가 사주지 못하는 그 신뢰를, 실행 계층이 대신 만듭니다.

<!-- nlm-visual -->
![이번 주 뉴스 요약 인포그래픽 2](/assets/images/posts/news/benchmark-wins-trust-gap-execution-layer/nlm-infographic-2.webp)
*NotebookLM이 이번 주 뉴스 소스를 종합해 생성한 인포그래픽입니다.*

## 참고 자료

이 글은 아래 뉴스를 종합해 작성했습니다.

- 위키트리, [메타, 광고 대신 컴퓨팅 판다… 앤트로픽과 100억 달러 임대 초기 협상](https://www.wikitree.co.kr/articles/1147052)
- 위키트리, [스페이스X, 펜타곤 AI 컴퓨팅 공급 협상…규모 수십억달러](https://www.wikitree.co.kr/articles/1147053)
- 굿모닝경제, [AI 인프라 550조 베팅…전력망부터 반도체까지 재편](https://www.goodkyung.com/news/articleView.html?idxno=289308)
- AI타임스, [일본, 엔비디아 '루빈'으로 국가 AI 인프라 구축…'피지컬 AI' 승부](https://www.aitimes.com/news/articleView.html?idxno=212885)
- 뉴스로드, [구글 차세대 AI '제미나이 3.5 프로' 출시 수개월 지연](http://www.newsroad.co.kr/news/articleView.html?idxno=61703)
- 디지털투데이, ["벤치마크는 이겼는데 글쎄"…中 키미 K3를 보는 실리콘밸리의 시선](https://www.digitaltoday.co.kr/news/articleView.html?idxno=684999)
- 조선일보, [AI 모델 경쟁, '최고 성능'보다 '가성비'로](https://www.chosun.com/economy/tech_it/2026/07/17/VQDA7CI2ERF4LG2YLQ76R6JG2A/)
- 한스경제, [카카오톡 안에 여행 추천 AI… 하나투어, 서비스 확대](http://www.hansbiz.co.kr/news/articleView.html?idxno=850868)
- 주간한국, ['업무 혁신' 유통家, 'AI 에이전트' 도입 본격화](https://weekly.hankooki.com/news/articleView.html?idxno=7173721)
- 동아일보, [박민준 뤼튼 대표 "경영진부터 AI로 대체할 것"](https://www.donga.com/news/Economy/article/all/20260717/134316474/1)
- 이데일리, ["미토스급 AI에 과감한 투자"… 배경훈 부총리, 첨단 인프라 확대](https://www.edaily.co.kr/news/newspath.asp?newsid=02696166645515504)
- 천지일보, [[K-AI 국가대표①] 빅테크 벽 넘은 LG AI연구원 'K-엑사원' AI 주권](https://www.newscj.com/news/articleView.html?idxno=3417568)
- 매일경제, [비용·용량 제한없는 '온국민 AI' 12월에 나온다…재원은 글쎄](https://www.mk.co.kr/article/12100854)
- 매일경제, [日, 소뱅 등 44곳 참여 소버린 AI 개시…올해 기반 모델 공개](https://www.mk.co.kr/article/12100992)
- 글로벌이코노믹, [AI 투자 숨고르기 조짐… 빅테크 조달 부담에 HBM 수요 '속도 변수'](https://www.g-enews.com/view.php?ud=202607180708261959fbbec65dfb_1)
- 뉴스로드, [車 두뇌 잡는 마이크론, 현대모비스·퀄컴과 '3~5년짜리' 메모리 동맹](http://www.newsroad.co.kr/news/articleView.html?idxno=61704)
- 디지털투데이, [AI 메모리 수요 여파에 인도 스마트폰 출하 10% 감소…6년 만에 최대 낙폭](https://www.digitaltoday.co.kr/news/articleView.html?idxno=685002)
- 매일일보, ['AI 보안기술기반 중소기업 정보유출 예방'…지란지교소프트, AI 보안](https://www.m-i.kr/news/articleView.html?idxno=1392577)

## 관련 슬라이드

본문 내용을 NotebookLM(`blue_collage` 스타일)으로 요약한 슬라이드입니다.

![benchmark-wins-trust-gap-execution-layer 슬라이드 1](/assets/images/benchmark-wins-trust-gap-execution-layer-slide-01.webp)

![benchmark-wins-trust-gap-execution-layer 슬라이드 2](/assets/images/benchmark-wins-trust-gap-execution-layer-slide-02.webp)

![benchmark-wins-trust-gap-execution-layer 슬라이드 3](/assets/images/benchmark-wins-trust-gap-execution-layer-slide-03.webp)

![benchmark-wins-trust-gap-execution-layer 슬라이드 4](/assets/images/benchmark-wins-trust-gap-execution-layer-slide-04.webp)

