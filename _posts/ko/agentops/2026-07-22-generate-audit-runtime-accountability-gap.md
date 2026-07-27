---
title: "코드를 쓰는 에이전트와 코드를 감시하는 에이전트가 같은 날 나왔습니다"
excerpt: "7월 22일, 오픈웨이트 릴리스 두 건이 거울처럼 마주 섰습니다. 하나는 코드를 생성하고 하나는 그 코드의 취약점을 찾습니다. 그런데 둘 다 답하지 못하는 질문이 하나 남습니다. 그 코드는 실제로 누구의 인프라에서, 어떤 권한으로 돌아가는가."
seo_title: "생성과 감사의 쌍: 오픈웨이트 코딩 에이전트가 남긴 런타임 책임 문제"
seo_description: "풀사이드 라구나 S 2.1과 시스코 안타레스가 같은 날 공개됐습니다. 코드 생성과 코드 감사가 오픈웨이트로 셀프호스팅되는 시대, 정작 비어 있는 실행 계층의 책임 문제를 짚습니다."
date: 2026-07-22
last_modified_at: 2026-07-22
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
canonical_url: "https://thakicloud.com/tech-blog/ko/agentops/generate-audit-runtime-accountability-gap/"
audiobook: /assets/audio/posts/generate-audit-runtime-accountability-gap/audiobook-ko.mp3
audiobook_note: "AI 로컬 합성 오디오북 (Qwen3-TTS)"
---

우연이라기엔 대칭이 너무 정확합니다. 2026년 7월 22일, 성격이 정반대인 오픈웨이트 모델 두 개가 같은 날 세상에 나왔습니다. 하나는 코드를 씁니다. 다른 하나는 코드의 취약점을 찾습니다. 풀사이드는 셀프호스팅 코딩 에이전트용 모델 라구나 S 2.1을 공개했고, 시스코는 코드 취약점 탐지에 특화된 소형 오픈웨이트 모델 안타레스를 내놨습니다. 창과 방패가 같은 진열장에 나란히 걸린 셈입니다.

이 두 릴리스를 따로 읽으면 각자 흔한 뉴스입니다. 나란히 놓고 보면 이야기가 달라집니다. 소프트웨어를 만드는 쪽과 그 소프트웨어를 감사하는 쪽이 동시에 에이전트로 넘어가고 있다는 뜻이기 때문입니다. 그리고 두 모델을 모두 자기 인프라에 올려놓는 순간, 아무도 대신 답해 주지 않는 질문이 남습니다. 이 에이전트들은 실제로 누구의 자원 위에서, 어떤 권한으로, 어떤 기록을 남기며 돌아가는가.

![코드를 쓰는 에이전트와 코드를 감시하는 에이전트가 같은 날 나왔습니다 개념을 형상화한 이미지](/assets/images/generate-audit-runtime-accountability-gap-hero.png)
*이번 주 뉴스의 핵심 흐름을 형상화했습니다.*

## 같은 날, 정확히 반대편에서

풀사이드의 라구나 S 2.1은 서구권 진영이 내놓은 대응 카드에 가깝습니다. 그동안 딥시크와 큐원 같은 중국계 오픈웨이트 모델이 코딩 에이전트 영역에서 앞서 나가던 흐름을 겨냥한 발표입니다. 외신들은 이 모델을 지난 1년간 나온 서구권 오픈웨이트 모델 가운데 자체 호스팅 에이전틱 코딩용으로 가장 신뢰할 만한 선택지로 소개했습니다. 흥미로운 대목은 성능이 아니라 몸집입니다. 활성 매개변수 80억 개짜리 저활성 구조로 몇 배 큰 경쟁 모델과 벤치마크에서 맞먹었다고 하니, 추론 비용과 온프레미스 구동 부담을 동시에 낮췄다는 점이 진짜 메시지입니다. DGX 스파크급 장비 한 대로 돌릴 수 있다는 대목은 곧 소규모 GPU 파티션에도 전용 코딩 에이전트를 태울 수 있다는 뜻입니다.

시스코의 안타레스는 반대편에서 같은 논리를 폅니다. 온디바이스로 돌아가는 소형 언어모델이 보안 영역에서 거대 범용 모델을 비용과 정확도 양면에서 앞선다는 것입니다. 시스코는 안타레스가 벤치마크에서 십여 개의 대형 오픈·클로즈드 모델을 능가하면서도 훨씬 저렴하게 구동된다고 주장했습니다. 여기서 결정적인 것은 실행 위치입니다. 로컬에서 돌아가므로 소스코드를 외부로 내보내지 않아도 됩니다. 소스코드 반출 규제가 엄격한 금융권과 공공기관에는 이 한 문장이 도입 여부를 가르는 조건이 됩니다.

두 모델은 방향이 반대인데 설계 철학이 똑같습니다. 작게 만들고, 오픈웨이트로 풀고, 남의 클라우드가 아니라 내 인프라에서 돌린다. 배포 전략마저 닮았습니다. 핵심 모델은 오픈웨이트로 공개하되 가장 성능이 좋은 버전은 자사 제품에 남겨 두는 방식은 요즘 보안 스타트업과 대형 벤더가 공통으로 택하는 문법입니다. 생성과 감사가 나란히 셀프호스팅의 규칙으로 재편되고 있는 것입니다.

<!-- nlm-visual -->
![이번 주 뉴스 요약 인포그래픽 1](/assets/images/posts/news/generate-audit-runtime-accountability-gap/nlm-infographic-1.png)
*NotebookLM이 이번 주 뉴스 소스를 종합해 생성한 인포그래픽입니다.*

## 오픈웨이트가 감사의 규칙을 바꾼 지점

과거의 코드 취약점 스캔은 대개 프런티어 모델을 호출하는 방식이었습니다. 문제는 두 가지였습니다. 비용이 상시 운영을 어렵게 만들었고, 스캔 대상인 소스코드가 외부 API로 흘러 나갔습니다. 국내 보안팀 다수가 예산 제약으로 상시 스캔을 포기했던 이유가 여기에 있습니다. 안타레스는 그 두 병목을 한꺼번에 건드립니다. 로컬 실행으로 반출 문제를 없애고, 소형 모델로 비용을 낮춥니다. 시스코가 대학과 공공 부문, 예산이 부족한 중소 보안팀을 명시적 대상으로 삼은 것도 이 맥락입니다.

같은 논리는 생성 쪽에도 그대로 적용됩니다. 라구나 S 2.1이 허용적 라이선스와 오픈웨이트를 함께 갖췄다는 점은 망분리 환경이나 국정원 요구사항을 충족해야 하는 금융·공공 분야에서 셀프호스팅 코딩 어시스턴트를 구성할 여지를 넓힙니다. 폐쇄형 API에 대한 의존을 줄이는 선택지가 하나 더 생긴 것입니다. 물론 이 자유에는 숙제가 따라옵니다. 국내 유통·지원 생태계와 한국어 코드 주석 대응력이 아직 검증되지 않았기 때문에, 실제 도입은 벤치마크 재현과 한국어 환경 적합성 테스트를 먼저 통과해야 합니다.

다만 시스코는 스스로 선을 그었습니다. 이 모델은 의존성 분석이나 비밀정보 스캔, 동적 테스트를 대체하지 않으며 초기 필터링 단계에 위치해야 한다는 것입니다. 정직한 제한입니다. 그리고 이 제한이 오늘의 진짜 주제로 이어집니다. 생성 모델도 감사 모델도 결국 자기 역할의 조각만 담당할 뿐, 두 조각을 하나의 책임 있는 흐름으로 엮는 일은 별개의 문제라는 사실입니다.

## 생성도 감사도 메우지 못하는 틈

같은 날의 다른 기사가 그 틈을 정확히 보여 줍니다. 국내 이커머스 플랫폼 아임웹은 개발과 운영 전반에 AI를 투입해 4년 걸릴 일을 3개월로 줄였다고 밝혔습니다. OpenAI와 앤스로픽, 구글의 모델을 상호 검증용으로 동시에 쓰는 보수적 문화까지 갖췄습니다. 그런데 한 문장이 눈에 걸립니다. 인프라 이상을 탐지하면 배포 후 자동 롤백을 사람 승인 없이 즉시 수행한다는 대목입니다. 생산성 관점에서는 자랑거리지만, 거버넌스 관점에서는 경보음입니다. 승인 없이 프로덕션을 되돌릴 수 있는 에이전트는, 승인 없이 다른 일도 할 수 있다는 뜻이기 때문입니다.

공공 쪽 신호는 정반대 방향에서 같은 결론을 가리킵니다. 예금보험공사는 생성형 AI 서비스를 도입하면서 모델 선정보다 데이터 카탈로그 구축과 AI 리스크 관리 체계를 선행 과제로 잡았습니다. 국민 자산을 다루는 기관이 모델보다 통제 체계를 먼저 세운다는 것은, 규제 산업에서 AI 도입의 실제 관문이 성능이 아니라 설명 가능성과 감사 추적이라는 점을 그대로 드러냅니다. 한쪽에서는 자율성이 앞서 나가고, 다른 한쪽에서는 통제가 먼저 자리를 잡습니다. 두 요구가 만나는 지점에 지금은 표준화된 계층이 비어 있습니다.

생성 모델은 코드를 만들고, 감사 모델은 코드의 결함을 찾습니다. 그러나 그 에이전트가 어떤 자율도로 움직이는지, 어떤 정책의 허락을 받고 실행되는지, 무엇을 언제 건드렸는지를 남기는 일은 두 모델 어느 쪽의 소관도 아닙니다. 이것은 모델의 문제가 아니라 실행 계층의 문제입니다.

## 하드웨어 주권만으로는 닫히지 않습니다

이 공백을 인프라의 규모로 메울 수 있을 것 같지만, 오늘 뉴스는 그렇지 않다고 말합니다. 같은 날 이재용·최태원·이해진 세 총수가 실리콘밸리에서 젠슨 황을 만나 엔비디아 중심의 AI 공급망 동맹을 재가동했습니다. 국내 소버린 AI 인프라 판도를 흔들 큰 움직임입니다. 삼성SDS는 퓨리오사AI의 국산 NPU를 얹은 NPUaaS를 출시하며 GPU 일변도였던 추론 인프라에 국산 대안을 처음 상용화 단계로 올렸습니다. 공공·금융 입장에서는 해외 GPU 의존을 낮출 소버린 옵션이 하나 더 생긴 것이고, 앞으로 정부 클라우드 입찰에서 국산 NPU가 요건으로 등장할 여지도 있습니다.

칩과 데이터센터, 공급망 차원의 주권은 이렇게 빠르게 채워지고 있습니다. 그런데 하드웨어 주권은 질문의 절반만 답합니다. 국산 NPU 위에서 셀프호스팅 코딩 에이전트가 돌아간다고 해서, 그 에이전트가 무엇을 할 권한이 있고 무엇을 남겨야 하는지가 저절로 정의되지는 않습니다. 반출을 막는 것과 실행을 통제하는 것은 다른 층위의 문제입니다. 소버린 인프라가 완성될수록, 그 위에서 움직이는 에이전트의 자율도와 감사를 소프트웨어로 규정하는 계층의 부재가 오히려 더 또렷하게 드러납니다.

## 실행 계층에서 답을 맞춥니다

생성과 감사, 그리고 그 사이에 남는 공백을 하나의 그림으로 정리하면 이렇습니다.

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
<div class="d3-arch" data-arch-root id="runtimeaccountabilitygap-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 492, "height": 756, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [{"x": 24, "y": 336, "w": 436, "h": 388, "label": "ThakiCloud Paxis · 실행 계층", "lx": 36, "ly": 354}], "nodes": [{"id": "G1", "x": 284, "y": 24, "w": 121, "h": 62, "title": ["코드를 작성하는 에이전트", "라구나 S 2.1"]}, {"id": "A1", "x": 109, "y": 24, "w": 120, "h": 62, "title": ["취약점을 찾는 에이전트", "안타레스"]}, {"id": "GAP", "x": 193, "y": 164, "w": 128, "h": 94, "title": ["비어 있는 질문", "누구의 자원 위에서", "어떤 권한으로", "무엇을 기록하며 실행되는가"]}, {"id": "P1", "x": 193, "y": 375, "w": 128, "h": 62, "title": ["정책 게이트", "L0-L3 자율도 거버넌스"]}, {"id": "P2", "x": 301, "y": 515, "w": 120, "h": 46, "title": "격리 샌드박스 실행"}, {"id": "P3", "x": 301, "y": 639, "w": 120, "h": 46, "title": "감사 로그"}, {"id": "P4", "x": 62, "y": 515, "w": 184, "h": 46, "title": "CostRouter · 소버린 쿠버네티스"}], "edges": [{"src": "G1", "dst": "GAP", "kind": "data", "curve": [[345, 86], [345, 125], [345, 125], [305, 164]]}, {"src": "A1", "dst": "GAP", "kind": "data", "curve": [[169, 86], [169, 125], [169, 125], [209, 164]]}, {"src": "GAP", "dst": "P1", "kind": "data", "line": [257, 258, 257, 375]}, {"src": "P1", "dst": "P2", "kind": "data", "curve": [[303, 437], [361, 476], [361, 476], [361, 515]]}, {"src": "P2", "dst": "P3", "kind": "data", "line": [361, 561, 361, 639]}, {"src": "P1", "dst": "P4", "kind": "data", "curve": [[211, 437], [154, 476], [154, 476], [154, 515]]}]});
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
      const container = document.getElementById('runtimeaccountabilitygap-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'runtimeaccountabilitygap-1';
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

ThakiCloud의 Paxis는 바로 이 비어 있는 계층을 다룹니다. Paxis는 에이전트를 위한 클라우드로, Skills와 Tools, Policies, Audit Logs를 일급 리소스로 취급하는 정식 제품입니다. 라구나 S 2.1 같은 코딩 에이전트를 백엔드에 붙이든 안타레스 같은 감사 모델을 스캔 전단에 붙이든, 그 에이전트는 결국 정책 게이트를 통과해 격리된 샌드박스에서 실행되고 모든 행위가 감사 로그에 남습니다. 아임웹 사례의 무승인 자동 롤백이 불안하게 읽혔다면, Paxis의 L0에서 L3까지 이어지는 자율도 거버넌스가 그 불안의 반대편입니다. 어떤 작업은 완전 자율로 두고 어떤 작업은 사람 승인을 강제하는 경계를 코드가 아니라 정책으로 선언할 수 있습니다.

소버린 요구도 같은 계층에서 만납니다. 안타레스가 소스코드 반출 없이 로컬에서 돌아야 의미가 있듯, Paxis는 소버린·온프렘 쿠버네티스 위에서 동작하며 작업별로 모델을 고르는 CostRouter를 갖췄습니다. 저비용 로컬 모델로 의심 파일을 좁힌 뒤 필요할 때만 큰 모델을 부르는 방식은, 시스코가 안타레스를 초기 필터로 위치시키라고 권한 그 설계를 인프라 차원에서 그대로 구현한 것입니다. MCP 커넥터와 스킬 마켓을 통해 새 모델과 도구를 얹더라도 실행과 기록의 규칙은 바뀌지 않습니다. 예금보험공사가 모델보다 먼저 세우려 했던 데이터 거버넌스와 리스크 관리 체계 역시, 개별 프로젝트마다 새로 짜는 것이 아니라 플랫폼이 기본으로 제공하는 정책과 감사 계층으로 흡수됩니다.

여기서 정당한 반론이 나올 수 있습니다. 결국 또 하나의 통제 계층을 얹는 것 아니냐, 오픈웨이트가 어렵게 되찾아 준 속도와 자율성을 정책과 감사라는 이름으로 다시 묶는 것 아니냐는 것입니다. 아임웹이 사람 승인 없이 즉시 롤백하는 방식으로 4년 걸릴 일을 3개월에 끝냈다면, 그 속도야말로 경쟁력의 원천일 수 있습니다. 타당한 지적입니다. 다만 자율도 거버넌스의 목적은 자율을 없애는 것이 아니라 자율의 범위를 명시적으로 그어 주는 데 있습니다. 승인 없이 롤백해도 되는 작업과 반드시 사람을 거쳐야 하는 작업을 구분해 선언해 두면, 안전한 영역에서는 오히려 더 과감하게 위임할 수 있습니다. 경계가 흐릿할 때 팀은 모든 자동화를 의심하지만, 경계가 정책으로 박혀 있을 때 팀은 그 안에서 마음 놓고 달립니다. 통제와 속도는 대립이 아니라, 경계가 선명할 때 함께 커집니다. 예금보험공사가 모델보다 통제 체계를 먼저 세운 것도 도입을 늦추려는 것이 아니라, 도입을 지속 가능하게 만들려는 선택이었습니다.

7월 22일의 두 릴리스는 에이전트가 코드를 쓰는 능력과 감시하는 능력을 동시에 갖추기 시작했음을 알립니다. 반가운 진전입니다. 다만 능력이 늘수록 책임의 공백도 함께 커집니다. 코드를 만드는 에이전트와 감사하는 에이전트가 흔해질수록, 정작 희소해지는 것은 그 에이전트들이 안전하게 실행되고 남김없이 기록되는 자리입니다. 창과 방패를 다 갖춘 다음에 남는 질문은 하나입니다. 이 둘은 결국 누구의 규칙 위에서 싸우는가. 모델을 고르는 일은 갈수록 쉬워지지만, 그 모델이 만든 결과에 책임을 지는 일은 여전히 어렵습니다. 오늘 나란히 걸린 창과 방패가 우리에게 알려 주는 것은, 다음 경쟁의 무대가 더 큰 모델이 아니라 그 모델들이 안전하게 살아 움직이는 실행 계층이라는 사실입니다.

## 참고 자료

이 글은 아래 뉴스를 종합해 작성했습니다.

- 글로벌경제, [엔비디아, 차세대 AI플랫폼 '베라루빈' 본격 공급 통해 "선두 수성"](https://www.getnews.co.kr/news/articleView.html?idxno=875704)
- 머니투데이, [LGU+·LS일렉트릭, AI 데이터센터 800V DC 공동 개발 나선다](https://www.mt.co.kr/tech/2026/07/22/2026072207035073681)
- 글로벌이코노믹, [HPE, 슈퍼컴퓨팅 개발환경 통합…소버린 AI 인프라 간소화](https://www.g-enews.com/view.php?ud=202607212059199803112616b072_1)
- 뉴스웍스, [[#클라우드 월드] 삼성SDS-퓨리오사AI 'NPUaaS' 출시·LG CNS 'AI 캠퍼스'...](https://www.newsworks.co.kr/news/articleView.html?idxno=847787)
- 지디넷코리아, ["SKT, AI팩토리에 가장 적극적인 통신사...풀스택AI·전국망 경쟁력"](https://zdnet.co.kr/view/?no=20260721191819)
- 약업신문, [BMS‧엔비디아, 생명공학 최강 AI 팩토리 구축](https://www.yakup.com/news/index.html?mode=view&cat=16&nid=330043)
- 글로벌이코노믹, [미국 데이터센터 전력 수요 급증… 호남 반도체 허브, 전력망·용수가 ...](https://www.g-enews.com/view.php?ud=202607220659395424fbbec65dfb_1)
- 디지털투데이, [풀사이드, 코딩 에이전트용 오픈웨이트 모델 '라구나 S 2.1' 공개](https://www.digitaltoday.co.kr/news/articleView.html?idxno=685807)
- 이투데이, [키미 쇼크에 ‘AI 2강’ 험로…'특화 AI' 키우고, 경량화 모델로 차별화...](https://www.etoday.co.kr/news/view/2605803)
- 디지털투데이, [포티투마루, 예금보험공사 데이터 관리체계 고도화·생성형 AI 서비스 구...](https://www.digitaltoday.co.kr/news/articleView.html?idxno=685817)
- 뉴스투데이, [밖에선 AI 인재 찾고 안에선 업무 혁신…NHN의 AX '승부수'](https://www.news2day.co.kr/article/20260721500191)
- 바이라인네트워크, [“4년 걸린 일을 3개월에”…아임웹이 안팎으로 AI 쓰는 법](https://byline.network/?p=9004111222612588)
- IT조선, [내년 지원 불투명한데…정부 '모두의 AI' 출시 서두르나](https://it.chosun.com/news/articleView.html?idxno=2023092166202)
- EBN, [이재용·최태원·이해진, 美서 젠슨 황 만난다…AI 공급망 동맹 재가동](https://www.ebn.co.kr/news/articleView.html?idxno=1717215)
- 디지털투데이, [시스코, 코드 취약점 탐지 특화 오픈웨이트 소형 모델 '안타레스' 공개](https://www.digitaltoday.co.kr/news/articleView.html?idxno=685800)
- 뉴스저널리즘, [AI가 바꾼 보안 공식…에스원 '현장 데이터'로 승부](https://www.ngetnews.com/news/articleView.html?idxno=551683)

<!-- nlm-visual -->
![이번 주 뉴스 요약 인포그래픽 2](/assets/images/posts/news/generate-audit-runtime-accountability-gap/nlm-infographic-2.png)
*NotebookLM이 이번 주 뉴스 소스를 종합해 생성한 인포그래픽입니다.*

## 관련 슬라이드

본문 내용을 NotebookLM(`cinematic_infographic` 스타일)으로 요약한 슬라이드입니다.

![generate-audit-runtime-accountability-gap 슬라이드 1](/assets/images/generate-audit-runtime-accountability-gap-slide-01.png)

![generate-audit-runtime-accountability-gap 슬라이드 2](/assets/images/generate-audit-runtime-accountability-gap-slide-02.png)

![generate-audit-runtime-accountability-gap 슬라이드 3](/assets/images/generate-audit-runtime-accountability-gap-slide-03.png)

![generate-audit-runtime-accountability-gap 슬라이드 4](/assets/images/generate-audit-runtime-accountability-gap-slide-04.png)

