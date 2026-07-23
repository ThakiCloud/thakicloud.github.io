---
title: "토큰 사용량은 폭증하는데 AI 비용은 절반으로: 코인베이스의 더 나은 기본값 전략"
excerpt: "코인베이스 CEO 브라이언 암스트롱이 공개한 AI 비용 통제법은 사용량 제한이나 경고 알림이 아니라 더 나은 기본값, 라우팅, 캐싱이었습니다. 직원의 91%가 애초에 사용 한도에 닿지도 않았다는 데이터를 근거로, 마찰을 늘리는 대신 LLM 게이트웨이의 기본 모델을 오픈웨이트로 바꾼 이 전략을 분석하고, ThakiCloud ai-platform의 저비용 서빙 관점에서 무엇을 시사하는지 정리했습니다."
seo_title: "코인베이스 AI 비용 절감 전략: 라우팅·캐싱·기본값 - Thaki Cloud"
seo_description: "코인베이스는 토큰 사용량이 기하급수적으로 늘어나는 가운데 AI 비용을 절반 가까이 줄였습니다. 핵심은 모델 라우팅, 공격적 캐싱, 오픈웨이트 기본값입니다. 직원 91%가 한도에 닿지 않는다는 데이터와 LLM 게이트웨이 전략을 분석하고, ThakiCloud ai-platform의 멀티테넌트 저비용 서빙 관점 시사점을 정리합니다."
date: 2026-06-27
last_modified_at: 2026-06-27
tags:
  - llmops
  - model-routing
  - inference-cost
  - open-weight-models
  - llm-gateway
  - cost-optimization
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "coins"
canonical_url: "https://thakicloud.com/tech-blog/ko/llmops/coinbase-flat-ai-spend-routing-caching-defaults/"
categories:
  - llmops
---

## 개요

AI를 본격적으로 쓰는 조직이라면 한 번쯤 마주치는 딜레마가 있습니다. 직원들이 LLM을 많이 쓸수록 생산성은 오르지만, 토큰 청구서도 함께 기하급수적으로 늘어납니다. 흔한 대응은 사용량에 상한을 걸고, 한도를 넘으면 경고를 보내고, 비싼 모델 사용을 까다롭게 만드는 것입니다. 그런데 이 방식은 비용을 누르는 대신 직원의 생산성에 마찰을 더하는 부작용을 낳습니다.

2026년 6월, 코인베이스 CEO 브라이언 암스트롱이 자사의 다른 해법을 공개했습니다. 그의 표현을 빌리면 "토큰 사용량이 기하급수적으로 늘어나는 와중에 AI 지출을 평평하게 유지하는 법"이고, 결론은 명확합니다. 마찰과 지출 경고가 아니라, 더 나은 기본값과 라우팅과 캐싱으로 푼다는 것입니다. 실제로 코인베이스는 토큰 사용량이 폭증하는 동안 AI 지출을 절반 가까이 줄였다고 밝혔습니다.

ThakiCloud는 다양한 고객 환경에서 모델을 서빙하는 ai-platform을 운영하므로, 추론 비용을 어떻게 통제하느냐는 남의 이야기가 아닙니다. 코인베이스의 전략은 단일 기업의 사내 정책이지만, 그 안에는 모델 서빙 인프라를 운영하는 누구에게나 적용되는 LLMOps 원칙이 담겨 있습니다. 이 글은 그 전략을 사실 그대로 정리하고, 서빙 플랫폼 관점에서 무엇을 시사하는지 분석한 기록입니다.

## 무엇이 핵심인가: 마찰이 아니라 기본값

코인베이스 접근의 출발점은 데이터입니다. 사용량 한도를 조이려다 발견한 사실은, 직원의 91%가 애초에 사용 한도에 닿지도 않는다는 것이었습니다. 즉 비용을 끌어올리는 주범은 "한도를 꽉 채우는 소수의 헤비 유저"가 아니라, 전체 사용의 기본 동작이 비싼 모델로 향해 있다는 구조적 문제였습니다.

여기서 나온 슬로건이 "사용량 제한이 아니라 더 나은 기본값(Better Defaults, not Usage Caps)"입니다. 엔지니어는 여전히 원하는 모델을 자유롭게 고를 수 있습니다. 다만 아무것도 지정하지 않았을 때 도달하는 기본 모델을, 비싼 프런티어 모델이 아니라 저렴한 오픈웨이트 모델로 바꾼 것입니다. 코인베이스는 자사 LLM 게이트웨이에서 GLM 5.2, Kimi 2.7 같은 오픈웨이트 모델을 기본값으로 두는 실험을 진행 중이라고 밝혔습니다.

이 발상의 힘은 인간의 행동 양식을 거스르지 않는다는 데 있습니다. 대부분의 사용자는 기본값을 그대로 씁니다. 기본값을 바꾸면 강제하지 않고도 다수의 행동이 자연스럽게 이동합니다. 한도를 낮추고 경고를 늘리는 방식이 사용자와 시스템 사이에 마찰을 만드는 것과 정반대입니다. 전체 흐름을 도식으로 그리면 다음과 같습니다.

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
<div class="d3-arch" data-arch-root id="ndroutingcachingdefaults-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 645, "height": 942, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 221, "y": 24, "w": 120, "h": 62, "title": ["엔지니어 요청", "모델 미지정"]}, {"id": "B", "x": 221, "y": 164, "w": 120, "h": 46, "title": "LLM 게이트웨이"}, {"id": "C", "x": 112, "y": 288, "w": 138, "h": 52, "title": "기본값 정책"}, {"id": "D", "x": 24, "y": 432, "w": 120, "h": 62, "title": ["비싼 프런티어 모델", "높은 토큰 단가"]}, {"id": "E", "x": 199, "y": 432, "w": 156, "h": 62, "title": ["오픈웨이트 기본값", "GLM 5.2 / Kimi 2.7"]}, {"id": "F", "x": 230, "y": 586, "w": 120, "h": 46, "title": "작업 난이도 라우팅"}, {"id": "G", "x": 143, "y": 732, "w": 120, "h": 46, "title": "저렴한 모델"}, {"id": "H", "x": 318, "y": 724, "w": 120, "h": 62, "title": ["프런티어 모델", "명시 선택"]}, {"id": "I", "x": 480, "y": 440, "w": 120, "h": 46, "title": "캐시 조회"}, {"id": "J", "x": 493, "y": 724, "w": 120, "h": 62, "title": ["캐시 응답", "토큰 0"]}, {"id": "K", "x": 318, "y": 864, "w": 120, "h": 46, "title": "지출 평탄화"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [281, 86, 281, 164]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[244, 210], [181, 249], [181, 249], [181, 288]]}, {"src": "C", "dst": "D", "kind": "data", "label": "기존", "curve": [[146, 340], [84, 386], [84, 386], [84, 432]], "off": "50%"}, {"src": "C", "dst": "E", "kind": "data", "label": "변경 후", "curve": [[215, 340], [277, 386], [277, 386], [277, 432]], "off": "50%"}, {"src": "E", "dst": "F", "kind": "data", "line": [277, 494, 286, 586]}, {"src": "F", "dst": "G", "kind": "data", "label": "단순 반복", "curve": [[261, 632], [203, 678], [203, 678], [203, 732]], "off": "50%"}, {"src": "F", "dst": "H", "kind": "data", "label": "고난도", "curve": [[319, 632], [378, 678], [378, 678], [378, 724]], "off": "50%"}, {"src": "B", "dst": "I", "kind": "data", "curve": [[341, 201], [540, 249], [540, 386], [540, 440]]}, {"src": "I", "dst": "J", "kind": "data", "label": "히트", "curve": [[543, 486], [553, 540], [553, 678], [553, 724]], "off": "50%"}, {"src": "I", "dst": "F", "kind": "data", "label": "미스", "curve": [[513, 486], [452, 540], [452, 540], [344, 586]], "off": "50%"}, {"src": "G", "dst": "K", "kind": "data", "curve": [[203, 778], [203, 825], [203, 825], [318, 866]]}, {"src": "H", "dst": "K", "kind": "data", "line": [378, 786, 378, 864]}, {"src": "J", "dst": "K", "kind": "data", "curve": [[553, 786], [553, 825], [553, 825], [438, 866]]}]});
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
      const container = document.getElementById('ndroutingcachingdefaults-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ndroutingcachingdefaults-1';
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

*모델을 지정하지 않은 요청이 LLM 게이트웨이의 기본값 정책, 캐시 조회, 난이도 라우팅을 거쳐 저비용으로 지출이 평탄화되는 흐름.*

## 세 가지 기법

암스트롱이 제시한 비용 통제는 세 개의 축으로 정리됩니다. 어느 것도 새로운 발명은 아니지만, 셋을 게이트웨이 한 곳에서 조합한다는 점이 핵심입니다.

첫째, **더 똑똑한 모델 라우팅**입니다. 모든 작업을 같은 모델로 처리하지 않고, 각 작업을 그 작업을 완수할 수 있는 가장 저렴한 모델로 보냅니다. 요약이나 분류처럼 단순 반복 작업은 작은 모델로 충분하고, 복잡한 추론이 필요한 작업만 프런티어 모델로 올립니다. 핵심은 "최고 성능 모델이 항상 필요하지는 않다"는 인식입니다. 프런티어 모델의 성능이 결과에 아무 차이를 만들지 않는 일상 작업에 굳이 비싼 모델을 쓸 이유가 없습니다.

둘째, **공격적 캐싱**입니다. 반복되는 질의에 대해 중복 출력을 제거합니다. 같은 질문이 여러 번 들어오면 매번 모델을 호출하는 대신 캐시된 응답을 돌려줍니다. 캐시 히트는 토큰을 전혀 쓰지 않으므로, 반복성이 높은 워크로드일수록 절감 효과가 큽니다. 코드 어시스턴트나 사내 문서 질의처럼 비슷한 질문이 반복되는 환경에서 캐싱은 단순하지만 강력한 레버입니다.

셋째, **저렴한 오픈웨이트 모델로의 전환**입니다. 프런티어 성능이 가치를 더하지 않는 일상 작업에서는 오픈웨이트 모델로 옮깁니다. 앞의 기본값 전략과 맞물려, 라우팅의 기본 종착지 자체를 오픈웨이트로 두는 것입니다. 암스트롱은 더 나아가, 18개월 안에 AI 워크로드의 80%가 99% 더 저렴한 모델로 이동할 것이며, 인공지능 성장의 상한을 정하는 것은 모델 품질이 아니라 에너지와 연산 인프라가 될 것이라고 전망했습니다.

세 기법은 서로를 강화합니다. 라우팅이 작업을 적절한 모델로 분배하고, 캐싱이 반복 호출을 걷어내며, 오픈웨이트 기본값이 분배의 무게중심을 저비용 쪽으로 옮깁니다. 이 조합이 사용량 폭증과 비용 평탄화를 동시에 성립시킨 비결입니다.

## ThakiCloud 제품 적용 시사점

코인베이스의 전략은 사내 LLM 게이트웨이를 가진 단일 기업의 이야기지만, 그 원리는 ThakiCloud의 **ai-platform**이 제공하는 멀티테넌트 모델 서빙의 가치 제안과 정확히 겹칩니다. ai-platform은 쿠버네티스와 Kueue 기반 GPU 스케줄링 위에서 vLLM 등으로 모델을 서빙하는데, 코인베이스가 게이트웨이 한 곳에서 한 일을 우리는 서빙 플랫폼 차원에서 더 깊게 제공할 수 있습니다.

첫째, **라우팅을 플랫폼 기능으로**. 코인베이스는 게이트웨이에서 작업을 모델로 분배했습니다. ThakiCloud ai-platform은 멀티테넌트 환경에서 여러 모델을 동시에 서빙하므로, 테넌트별로 "단순 작업은 작은 모델, 고난도 작업만 큰 모델"이라는 라우팅 정책을 인프라 레벨에서 설정할 수 있습니다. 모델을 직접 호스팅하기 때문에, 외부 API에 의존할 때보다 라우팅 결정의 자유도와 비용 투명성이 큽니다.

둘째, **오픈웨이트 서빙의 경제성**. 코인베이스가 GLM 5.2, Kimi 2.7 같은 오픈웨이트 모델을 기본값으로 둔 핵심 이유는 저비용입니다. ai-platform은 바로 이 오픈웨이트 모델을 온프레미스나 소버린 환경에서 직접 서빙하는 데 특화되어 있습니다. 컨슈머 GPU 양자화 서빙, vLLM 기반 고처리량 추론, 멀티테넌트 자원 격리를 통해 토큰당 서빙 비용을 낮추는 것이 우리의 경쟁력입니다. 외부 프런티어 API의 토큰 단가에 묶이지 않고, 자체 인프라에서 오픈웨이트 모델을 효율적으로 돌릴수록 코인베이스가 말한 "99% 더 저렴한" 영역에 실제로 도달할 수 있습니다.

셋째, **에너지와 연산이 상한이라는 통찰**. 암스트롱은 AI 성장의 상한을 정하는 것이 모델 품질이 아니라 에너지와 연산 인프라라고 봤습니다. 이는 ThakiCloud가 GPU 자원을 Kueue로 효율적으로 스케줄링하고, 온프레미스 비용 효율을 강조하는 방향과 같은 지점을 가리킵니다. 추론 비용이 워크로드를 결정하는 시대에는, 같은 모델을 더 싸게 더 많이 돌리는 서빙 인프라 자체가 차별화 요소가 됩니다.

한편 정책과 감사 관점에서는 ThakiCloud의 Agent-Native Cloud인 **Paxis**도 맞물립니다. 코인베이스의 "기본값 정책"은 본질적으로 게이트웨이를 지나는 모든 요청에 적용되는 정책 게이트입니다. Paxis는 모든 에이전트 행동을 정책 게이트와 감사 로그로 통과시키므로, 어떤 모델이 어떤 작업에 기본으로 쓰였고 비용이 어디서 발생했는지를 추적 가능한 형태로 남길 수 있습니다. 비용 통제는 결국 가시성에서 시작하고, 가시성은 모든 호출이 기록될 때 성립합니다.

## 한계 및 반론

이 전략에도 분명한 한계가 있습니다. 먼저, 라우팅의 정확도 문제입니다. "이 작업은 작은 모델로 충분하다"는 판단이 틀리면 품질이 떨어지고, 그 손실은 토큰 절감액보다 클 수 있습니다. 단순해 보이는 작업이 사실은 미묘한 추론을 요구하는 경우, 저렴한 모델로 라우팅한 대가가 잘못된 결과로 돌아옵니다. 라우팅 정책은 한 번 짜고 끝나는 것이 아니라 지속적인 평가와 보정이 필요합니다.

둘째, 캐싱의 적용 범위입니다. 캐싱은 반복 질의에서 강력하지만, 매번 다른 맥락과 다른 입력이 들어오는 창의적 작업이나 개인화된 작업에서는 히트율이 낮습니다. 모든 워크로드가 캐싱의 혜택을 똑같이 받지는 않으므로, 절감 효과는 워크로드 성격에 크게 의존합니다.

셋째, 오픈웨이트 모델의 품질 격차입니다. "18개월 안에 80%가 99% 저렴한 모델로 이동한다"는 전망은 공격적입니다. 오픈웨이트 모델이 빠르게 따라잡고 있는 것은 사실이지만, 고난도 추론이나 긴 컨텍스트, 안정성이 중요한 영역에서는 여전히 프런티어 모델과의 격차가 존재합니다. 기본값을 오픈웨이트로 두되, 언제 프런티어로 올려야 하는지의 경계를 잘못 그으면 사용자 경험이 나빠집니다. 이 전망은 단정이라기보다 방향성으로 읽는 편이 안전합니다.

그럼에도 코인베이스 사례의 핵심 교훈은 견고합니다. 비용 통제는 사용자에게 마찰을 더하는 방식이 아니라, 기본값과 인프라를 바꾸는 방식으로 풀어야 한다는 것입니다. 그리고 그 인프라를 직접 소유할수록, 즉 모델을 자체 서빙할수록 통제의 폭이 넓어집니다. ThakiCloud ai-platform이 지향하는 저비용 멀티테넌트 서빙이 바로 그 통제의 토대입니다.

## 출처

- [Brian Armstrong 트윗](https://x.com/brian_armstrong/status/2070670644577280109): "How to keep AI spend flat while token usage grows exponentially" (2026-06-27)
- [Coinbase Says AI Costs Are Staying Flat As Token Usage Explodes (CryptoAdventure)](https://cryptoadventure.com/coinbase-says-ai-costs-are-staying-flat-as-token-usage-explodes/)
- [Coinbase CEO Halved AI Costs (Yahoo Finance)](https://finance.yahoo.com/markets/crypto/articles/coinbase-ceo-halved-ai-costs-130000536.html)
