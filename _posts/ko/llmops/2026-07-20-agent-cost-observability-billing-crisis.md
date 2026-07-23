---
title: "250억 원짜리 청구서가 남긴 질문: AI 에이전트의 비용은 왜 보이지 않는가"
excerpt: "국내 사용자에게 250억 원이 청구된 사건부터 기업 60곳의 과다 청구 의혹까지, 최근 한 달의 AI 비용 뉴스는 하나의 공백을 가리킵니다. 한 번의 요청이 수백 번의 모델 호출로 번지는 에이전트 시대에, 청구서는 더 이상 무엇에 돈을 냈는지 설명해 주지 않습니다. 이 관측 공백을 어떻게 메울지 정리했습니다."
seo_title: "AI 에이전트 비용 관측성과 FinOps: 250억 청구 사건이 남긴 교훈"
seo_description: "2026년 7월 앤트로픽 250억 원 청구 오류, 기업 60곳 170만 달러 과다 청구 의혹, 리트라이 스톰과 섀도 IT까지. 에이전트 워크로드에서 비용이 관측 불가능해지는 구조를 분석하고, 자체 호스팅과 에이전트 비용 관측·거버넌스로 대응하는 ThakiCloud 전략을 정리합니다."
date: 2026-07-20
tags:
  - LLMOps
  - FinOps
  - 에이전트비용
  - 비용관측성
  - 모델라우팅
  - self-hosting
  - Paxis
  - AI인프라
author_profile: true
toc: true
toc_label: 보이지 않는 청구서의 해부
published: true
categories:
  - llmops
canonical_url: "https://thakicloud.com/tech-blog/ko/llmops/agent-cost-observability-billing-crisis/"
---

이 글은 조직에 Claude Code나 AI 에이전트를 도입하려는 플랫폼·인프라 담당자, 그리고 다음 달 AI 청구서를 설명해야 하는 재무·구매 담당자를 위해 썼습니다. 결론을 먼저 말씀드리면, 최근 한 달 동안 쏟아진 AI 비용 뉴스는 "AI가 비싸다"는 이야기가 아닙니다. 진짜 문제는 **청구서가 무엇에 대한 것인지 설명해 주지 않는다**는 데 있습니다. 한 번의 사용자 요청이 수십에서 수백 번의 모델 호출과 도구 실행, 그리고 실패 시 자동 재시도로 번지는 에이전트 구조에서, 최종 금액만으로는 어느 루프에서 돈이 샜는지 알 수가 없습니다. 저희는 이 관측 공백이야말로 지금 시장이 겪는 통증의 핵심이라고 봅니다.

## 개요

2026년 6월 말부터 7월까지의 뉴스를 한 줄로 요약하면 이렇습니다. 프런티어 모델을 모든 작업에 무차별로 쓰면 비용을 감당하기 어렵고, 그 비용이 어디서 발생했는지조차 추적하기 어렵다는 것입니다. 사건은 극적인 형태로 드러났습니다. 국내 한 사용자에게 처음 약 25억 원, 이후 약 250억 원의 결제가 시도됐습니다. 다행히 카드 한도 초과로 실제 출금은 없었지만, 비정상적인 금액이 표시 오류를 넘어 카드 승인 요청 단계까지 반복해서 전달됐다는 점이 사건의 무게를 다르게 만듭니다.

같은 시기, 다른 층위의 뉴스도 이어졌습니다. AI 비용 감사 업체가 기업 60곳의 청구서를 검토해 상당한 과다 청구를 주장했고, 여러 대기업이 프런티어 모델 사용을 조건에 따라 저가 모델로 분산하기 시작했으며, 미국·유럽 기업들이 비용을 이유로 중국 오픈웨이트 모델로 옮겨 갔다는 보도가 나왔습니다. 흥미롭게도 모델 공급사 스스로도 "모든 작업에 최고 성능 모델을 오래 돌리는 방식은 지속 가능하지 않다"는 취지로 대응하기 시작했습니다. 여러 방향의 뉴스가 같은 지점을 가리키고 있었습니다.

## 지난 한 달, 무슨 일이 있었나

가장 먼저 눈에 띈 것은 청구 시스템의 신뢰성 문제였습니다. 지디넷코리아 보도에 따르면, 국내 대학생 이용자에게 발생한 청구액은 약 166만 달러에서 시작해 열 배 규모인 약 1,662만 달러까지 늘어났습니다. 앤트로픽은 이후 답변에서 자동 충전 금액이 비정상적으로 높게 설정된 오류였다고 설명했지만, 당사자는 자동 충전 기능을 설정한 적이 없다고 밝혀 설정이 왜 생성됐는지는 여전히 명확하지 않습니다. 사용자가 여러 부서에 열다섯 통 넘는 메일을 보낸 뒤 나흘이 지나서야 자동 응답을 받았다는 대목은 기술 오류보다 대응 체계의 공백을 더 선명하게 보여 줍니다.

두 번째는 에이전트 비용의 관측 가능성 문제였습니다. AI타임스와 디인포메이션 보도에 따르면, 비용 감사 스타트업 보디트(Vaudit)는 기업 60곳의 약 3,400만 달러 청구서를 검토해 약 170만 달러를 과다 청구로 판단했다고 밝혔습니다. 검토 대상의 상당 부분은 Claude Code 사용 내역이었고, 파나소닉·HP·혼다 등이 고객사로 언급됐습니다. 이 업체가 주장한 유형은 저가 모델을 썼는데 고가 모델 요금으로 기록되거나, 작업을 완료하지 못했는데 비용이 발생하거나, 오류 후 자동 재시도가 반복되는 이른바 **리트라이 스톰(retry storm)**이었습니다. 여기서 짚어 둘 점이 두 가지 있습니다. 첫째, 앤트로픽은 완료되지 않은 요청이나 오류 응답에 비용을 청구하지 않으며 광범위한 과다 청구 증거도 없다고 반박했습니다. 둘째, 보디트는 환불 성공액의 일부를 수수료로 받는 상업적 감사 업체이므로, 이 수치는 독립 회계감사가 아니라 한쪽 당사자의 조사 결과로 읽는 것이 정확합니다. 즉 지금은 감사 업체의 주장과 공급사의 부인이 맞서는 국면입니다.

세 번째는 시장의 반응이었습니다. 디인포메이션은 기업들이 단순 분류·요약·변환 같은 작업은 저가 모델로, 복잡한 코딩·에이전트 작업은 프런티어 모델로, 반복적인 대량 작업은 오픈웨이트 또는 자체 호스팅 모델로 분리하기 시작했다고 보도했습니다. 파이낸셜타임스는 도어대시·지멘스·에어비앤비 등이 비용 절감을 위해 딥시크나 문샷 계열 모델을 도입했다고 전했습니다. 비즈니스인사이더 보도에서는 앤트로픽의 플랫폼 책임자들조차 부서별로 제각각 도입하는 이른바 **섀도 IT** 때문에 일부 기업의 AI 비용이 폭증했다고 인정하면서도, 사용 중단이나 일괄 예산 상한이 아니라 작업별 모델 선택과 조직 차원의 중앙 비용 관리가 필요하다고 주장했습니다. 요금 정책 자체도 자주 바뀌었습니다. 최신 고성능 모델의 구독 포함 여부와 종량제 전환 시점이 여러 차례 조정됐고, 프로모션 종료 시점이 반복해서 연장됐습니다. 실제로 Claude Fable 5 무료 제공이 7월 19일까지 연장됐다는 보도도 있었습니다. 성능보다 다음 달 비용을 예측하기 어렵다는 점이 구매 담당자에게는 더 큰 골칫거리였습니다.

## 에이전트 비용은 왜 관측되지 않는가

세 갈래의 뉴스를 관통하는 공통 원인은 결국 하나입니다. 에이전트 워크로드에서는 사용자가 보는 것과 청구서가 기록하는 것 사이의 거리가 너무 멀어졌습니다. 전통적인 API 호출은 요청 한 번에 응답 한 번, 비용 한 줄이었습니다. 반면 코딩 에이전트나 에이전트 SDK는 한 번의 지시가 계획 수립, 도구 호출, 파일 편집, 검증, 실패 시 재시도로 확장됩니다. 이 확장은 사용자에게 보이지 않는 곳에서 일어나고, 청구서에는 그 총합만 한 줄로 찍힙니다.

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
<div class="d3-arch" data-arch-root id="servabilitybillingcrisis-1"></div>
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
  .d3-arch svg { display: block; width: 100%; min-width: 760px; height: auto; font-family: inherit; }

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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 457, "height": 898, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "U", "x": 138, "y": 24, "w": 120, "h": 46, "title": "사용자 요청 1건"}, {"id": "P", "x": 296, "y": 148, "w": 120, "h": 46, "title": "에이전트 계획 수립"}, {"id": "L", "x": 296, "y": 272, "w": 120, "h": 46, "title": "실행 루프"}, {"id": "T", "x": 295, "y": 396, "w": 121, "h": 62, "title": ["도구 호출 · 모델 호출", "수십~수백 회"]}, {"id": "R", "x": 287, "y": 536, "w": 138, "h": 52, "title": "성공 여부"}, {"id": "RS", "x": 296, "y": 680, "w": 120, "h": 62, "title": ["자동 재시도", "(리트라이 스톰)"]}, {"id": "ACC", "x": 78, "y": 680, "w": 163, "h": 62, "title": ["토큰 · 캐시 · tool call", "누적 집계"]}, {"id": "INV", "x": 36, "y": 820, "w": 128, "h": 46, "title": "청구서: 최종 금액 한 줄"}], "edges": [{"src": "U", "dst": "P", "kind": "data", "curve": [[256, 70], [356, 109], [356, 109], [356, 148]]}, {"src": "P", "dst": "L", "kind": "data", "line": [356, 194, 356, 272]}, {"src": "L", "dst": "T", "kind": "data", "line": [356, 318, 356, 396]}, {"src": "T", "dst": "R", "kind": "data", "line": [356, 458, 356, 536]}, {"src": "R", "dst": "RS", "kind": "data", "label": "\"실패\"", "curve": [[374, 588], [406, 634], [406, 634], [376, 680]], "off": "50%"}, {"src": "RS", "dst": "T", "kind": "data", "curve": [[296, 692], [107, 634], [107, 497], [295, 444]]}, {"src": "R", "dst": "ACC", "kind": "data", "label": "\"성공\"", "curve": [[303, 588], [210, 634], [210, 634], [179, 680]], "off": "50%"}, {"src": "ACC", "dst": "INV", "kind": "data", "curve": [[159, 742], [159, 781], [159, 781], [122, 820]]}, {"src": "INV", "dst": "U", "kind": "event", "label": "관측 공백", "curve": [[77, 820], [40, 562], [40, 295], [139, 70]], "off": "50%"}]});
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
      const container = document.getElementById('servabilitybillingcrisis-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'servabilitybillingcrisis-1';
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

이 구조에서 비용이 새는 지점은 대부분 사용자의 시야 밖에 있습니다. 재시도 루프가 조용히 돌면서 호출 수를 부풀리고, 중간 클라우드 사업자를 거치면서 실제 모델 사용량과 최종 청구 내역이 어긋나며, 자동 충전 같은 설정 하나가 잘못되면 카드 승인 단계까지 비정상 금액이 흘러갑니다. 세 뉴스는 서로 다른 사건처럼 보이지만, 전부 이 관측 공백의 다른 얼굴입니다. 그래서 개인별 월 한도를 거는 것만으로는 부족합니다. 필요한 것은 모델별 비용, 세션별 토큰, 캐시 토큰, 도구 호출 횟수, 실패와 재시도 비용, 일별 이상 증가율을 **호출이 일어나는 그 순간에** 중앙에서 붙잡는 계측 계층입니다. 관측이 없으면 통제도 없고, 통제가 없으면 청구서는 늘 사후에 놀라는 서류가 됩니다.

## ThakiCloud 제품 적용 시사점

이 문제는 ThakiCloud가 운용하는 두 제품이 각기 다른 각도에서 겨냥하는 지점입니다. 인프라 관점과 에이전트 관점이 서로를 보완하기 때문에, 이번 주제에는 두 렌즈를 함께 씁니다.

**ai-platform 렌즈, 반복 워크로드는 소유가 답입니다.** 시장이 도달한 결론은 명료합니다. 쉬운 작업까지 프런티어 모델로 처리하면 비용이 감당되지 않고, 반복적인 대량 작업은 오픈웨이트 모델을 자체 호스팅하는 편이 경제적입니다. ThakiCloud의 ai-platform은 바로 이 지점을 위한 K8s 기반 AI/ML 인프라입니다. Kueue로 GPU를 큐잉해 활용률을 끌어올리고, vLLM으로 오픈웨이트 모델을 서빙하며, 멀티테넌트 격리로 부서별 사용량을 분리해 과금합니다. 종량제 API가 예측 불가능한 청구서를 만든다면, 자체 호스팅은 고정된 GPU 비용 위에서 사용량이 늘어도 단가가 튀지 않는 구조를 만듭니다. 요금 정책이 수시로 바뀌는 외부 종량제와 달리, 온프렘·소버린 배치는 비용의 예측 가능성 자체를 자산으로 돌려줍니다. 데이터가 외부로 나가지 않는다는 점은 국내 규제·보안 요구가 큰 조직에는 별도의 가치가 됩니다.

**Paxis 렌즈, 에이전트의 모든 행동을 감사 가능하게 만듭니다.** 관측 공백의 핵심은 에이전트 루프였고, 이것은 정확히 Paxis가 다루는 영역입니다. Paxis는 ai-platform 위에서 도는 ThakiCloud의 Agent-Native Cloud 제어 평면으로, Skills·Tools·Policies·Audit Logs를 일급 리소스로 취급합니다. 에이전트가 어떤 스킬을 어떤 도구로 몇 번 호출했는지, 어느 샌드박스에서 실행했는지가 전부 감사 로그로 남습니다. 이 구조에서는 리트라이 스톰이 조용히 청구서를 부풀리는 대신, 재시도 루프가 감사 로그에 그대로 드러나고 정책 게이트가 임계를 넘는 호출을 차단합니다. 960개가 넘는 스킬을 BM25로 선택해 격리 샌드박스에서 실행하고 모든 행동을 정책과 감사로 통과시키는 설계는, "청구서만 보고 어느 루프에서 비용이 났는지 확인하기 어렵다"는 바로 그 문제에 대한 구조적 답입니다. 저비용 서빙(ai-platform)이 에이전트를 경제적으로 만들고, 행동 단위 관측(Paxis)이 그 경제성을 예측 가능하게 만듭니다. 두 렌즈는 이렇게 맞물립니다.

## 한계 및 반론

균형을 위해 반대편도 분명히 해 두겠습니다. 첫째, 프런티어 모델이 무조건 낭비인 것은 아닙니다. 월스트리트저널 보도에 따르면 쇼피파이 같은 기업은 복잡한 코딩과 다단계 에이전트 작업에서 프런티어 모델이 엔지니어의 시간을 아껴 준다면 높은 가격도 정당화될 수 있다고 봅니다. 반대로 스포티파이나 트윌리오는 소폭의 성능 향상이 추가 비용을 정당화하는지 신중하게 따지고 있습니다. 즉 답은 "프런티어를 버리라"가 아니라 "작업 난이도에 따라 나누라"입니다. 자체 호스팅도 만능이 아닙니다. 최고 난도의 추론이 필요한 작업까지 오픈웨이트로 내리면 품질이 떨어지고, GPU 운영·모델 업데이트·보안 패치라는 새로운 운영 부담이 생깁니다.

둘째, 이 글에 인용한 과다 청구 수치는 확정된 사실이 아닙니다. 보디트의 주장은 상업적 감사 업체의 발표이고 앤트로픽은 이를 부인했으므로, 현재로서는 양측의 입장이 맞서는 상태로 읽는 것이 정확합니다. 250억 원 청구 사건 역시 실제 출금은 이뤄지지 않았고, 자동 충전 설정이 왜 생성됐는지에 대한 기술적 설명은 아직 공개되지 않았습니다. 저희가 이 뉴스에서 끌어내는 결론은 특정 공급사를 겨냥하는 것이 아니라, 에이전트 시대에는 어느 공급사를 쓰든 비용 관측성과 거버넌스를 사용자 쪽에서 확보해야 한다는 원칙입니다. 좋은 모델을 고르는 문제와 그 모델을 다스리는 문제는 별개이고, 최근 한 달의 뉴스는 후자가 그동안 비어 있었다는 사실을 드러냈을 뿐입니다.

## 출처

- [지디넷코리아, "250억원 결제 요청 받은 국내 이용자…앤트로픽 빌링 오류 논란" (2026-07-09)](https://zdnet.co.kr/view/?no=20260709165452)
- [지디넷코리아, "250억원 청구한 앤트로픽, 알고 보니 자동 충전 설정 오류" (2026-07-16)](https://zdnet.co.kr/view/?no=20260716093004)
- [AI타임스, "앤트로픽, 'AI 비용 과다 청구' 논란…실패한 작업도 돈 받았다" (2026-06)](https://www.aitimes.com/news/articleView.html?idxno=212155)
- [The Information, 기업의 AI 비용 통제와 모델 분산 도입 보도 (2026-06-23)](https://www.theinformation.com/titv/fedld)
- [Financial Times, "Companies turn to Chinese AI models to cut costs" (2026-07)](https://www.ft.com/content/9c8ff45b-7c20-4c2e-93c9-c52339ffdcee)
- [Business Insider, "Anthropic Official Warns Against 'Wrong' AI Cost Response" (2026-07-15)](https://www.businessinsider.com/anthropic-ai-costs-responses-routers-2026-7)
- [The Wall Street Journal, "Meet the Companies Shelling Out for Top AI Models" (2026-07)](https://www.wsj.com/cio-journal/meet-the-companies-shelling-out-for-top-ai-models-e1fe3375)
