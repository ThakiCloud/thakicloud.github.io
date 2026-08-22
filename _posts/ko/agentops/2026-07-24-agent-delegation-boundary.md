---
title: "에이전트가 나를 대신할 때, 선은 어디입니까"
excerpt: "에이전트가 사람을 대리하기 시작하면 진짜 어려운 문제는 성능이 아니라 어디서 멈추느냐입니다. 30초 단편영화 두 편을 같은 축의 양극단으로 놓고, 위임의 경계를 어떻게 코드와 정책으로 긋는지 짚습니다."
seo_title: "에이전트 위임의 경계: A2A 협상과 Human-in-the-Loop - Thaki Cloud"
seo_description: "에이전트가 사람을 대리해 다른 에이전트와 협상하고 대신 결정하는 시대에, 위임의 경계를 mandate·비가역성·확신도 세 질문으로 설계하는 법. 단편영화 두 편으로 본 A2A와 HITL, 그리고 에이전트 컨트롤 플레인 관점."
date: 2026-07-24
last_modified_at: 2026-07-24
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "robot"
tags:
  - agentops
  - a2a
  - human-in-the-loop
  - agent-governance
  - delegation
  - ai-application
  - thakicloud
categories:
  - agentops
header:
  teaser: /assets/images/agent-delegation-boundary-hero.webp
published: false
---

![두 에이전트가 빛나는 경계선을 사이에 두고 협상하는 추상 일러스트]({{ '/assets/images/agent-delegation-boundary-hero.webp' | relative_url }})

에이전트가 사람을 대리해 무언가를 처리하는 제품을 만드는 분이라면, 곧 마주칠 어려운 질문은 "모델이 얼마나 똑똑한가"가 아닙니다. "이 에이전트가 어디까지 나 대신 결정하고, 어디서 나에게 넘겨야 하는가"입니다. 이 경계를 잘못 그으면 똑똑한 에이전트일수록 더 크게 사고를 칩니다.

그 경계를 두 개의 장면으로 먼저 보시겠습니다. 지난주에 만든 30초 단편영화 두 편인데, 우연히 고른 소재가 아니라 정확히 한 문제의 양극단입니다. 한쪽은 에이전트가 사람 대신 결정을 내려버리고, 다른 한쪽은 에이전트가 결정을 사람에게 되돌려줍니다.

## 첫 번째 극단: 에이전트가 대신 결정했습니다

![단편영화 「요원들」 썸네일]({{ '/assets/images/agent-delegation-the-agents.webp' | relative_url }})

<iframe src="https://drive.google.com/file/d/188WqN0OnHbcJsCvUZrkoCxqccB-Itti8/preview" width="100%" height="440" allow="autoplay" style="border:0; aspect-ratio:16/9;" loading="lazy"></iframe>

「요원들」의 설정은 이렇습니다. 소개팅을 앞둔 두 사람이 있고, 각자의 에이전트가 먼저 만나 대화를 나눕니다. 두 에이전트는 서로의 취향, 스케줄, 최근 관심사를 맞춰 보다가 합이 맞지 않는다고 판단하고, 사람에게 묻지 않은 채 약속을 대신 취소합니다. 당사자들은 자신들이 만나기도 전에 상황이 끝났다는 사실을 나중에야 알게 됩니다.

재미있는 장면이지만, 그 밑에는 지금 업계가 실제로 씨름하는 문제들이 깔려 있습니다. 먼저 신원과 위임의 문제가 있습니다. 상대 에이전트가 정말로 그 사람을 대리할 자격이 있는지를 무엇으로 증명할까요. 사람이 발급한 위임장(mandate)이 없다면 두 에이전트의 대화는 그저 두 프로그램이 서로를 사칭하는 일에 지나지 않습니다. 여기에 협상의 문제가 겹칩니다. 서로의 선호를 통째로 노출하지 않으면서 합의점을 찾는 일은 프라이버시를 지키는 매칭 문제이고, 이미 여러 A2A 프로토콜이 다루려는 지점입니다. 그리고 가장 중요한 것은 되돌릴 수 없는 행동의 문제입니다. 약속 취소는 한 번 실행되면 되돌리기 어려운데, 에이전트가 이런 비가역 행동을 사람의 확인 없이 실행해도 되는 경계가 어디냐는 것입니다. 「요원들」은 그 경계를 일부러 넘겨서 웃음을 만듭니다.

## 두 번째 극단: 이 트래픽은 사람이 받아야 합니다

![단편영화 「잔소리 프로토콜」 썸네일]({{ '/assets/images/agent-delegation-nagging-protocol.webp' | relative_url }})

<iframe src="https://drive.google.com/file/d/1yWy09_3ZGTTLtlHGWB70g63fIxPNwmWr/preview" width="100%" height="440" allow="autoplay" style="border:0; aspect-ratio:16/9;" loading="lazy"></iframe>

두 번째 영화 「잔소리 프로토콜」은 반대 방향으로 갑니다. 엄마의 에이전트가 아들의 에이전트에게 밥은 챙겨 먹는지, 연락은 왜 없는지 잔소리를 쏟아냅니다. 아들의 에이전트는 대부분의 메시지를 알아서 받아넘기다가, 어느 순간 이건 자기가 대신 처리할 일이 아니라고 판단하고 아들에게 그대로 넘깁니다. 제목 그대로, 어떤 트래픽은 사람이 받아야 합니다.

이 장면의 기술적 핵심은 언제 사람에게 넘기느냐입니다. 에이전트가 모든 상호작용을 대신 처리하면 편리하지만, 관계나 감정이 얽힌 신호까지 자동 응답으로 소화해 버리면 정작 사람이 받아야 할 것이 사라집니다. 그래서 잘 만든 에이전트는 자동 처리와 에스컬레이션 사이의 경계가 분명합니다. 자신의 확신이 낮거나 사안이 위임 범위를 벗어나거나 결과가 사람의 관계에 영향을 준다고 판단되면, 처리를 멈추고 사람에게 되돌립니다. 「요원들」이 경계를 넘어 사고를 냈다면, 「잔소리 프로토콜」은 경계를 지켜 사람의 몫을 남겨 둡니다.

## 두 장면을 하나의 축으로: 위임의 경계

두 영화는 겉보기에 다른 이야기지만 같은 축의 양 끝입니다. 그 축의 이름이 위임의 경계입니다. 에이전트가 요청을 받았을 때 실제로 결정해야 하는 것은 "무엇을 할까"가 아니라 "이걸 내가 끝까지 처리할까, 아니면 사람에게 넘길까"입니다. 이 판단을 그림으로 그리면 다음과 같습니다.

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
<div class="d3-arch" data-arch-root id="4agentdelegationboundary-1"></div>
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
  /* Size to the spec's natural canvas: JS caps max-width at the spec width so a
     narrow/portrait diagram is never stretched to the article column (blur + giant
     vertical figures); wide diagrams scale down but keep min-width 760 + scroll. */
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 374, "height": 814, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 142, "y": 24, "w": 135, "h": 46, "title": "사람의 요청 또는 외부 신호"}, {"id": "B", "x": 140, "y": 148, "w": 138, "h": 68, "title": ["위임장이 이 행동을", "허용합니까"]}, {"id": "H", "x": 222, "y": 612, "w": 120, "h": 46, "title": "사람에게 에스컬레이션"}, {"id": "C", "x": 87, "y": 308, "w": 138, "h": 52, "title": "결과가 비가역입니까"}, {"id": "D", "x": 32, "y": 452, "w": 138, "h": 68, "title": ["에이전트 확신이", "기준 이상입니까"]}, {"id": "E", "x": 24, "y": 612, "w": 120, "h": 46, "title": "에이전트가 자동 실행"}, {"id": "F", "x": 82, "y": 736, "w": 149, "h": 46, "title": "행동과 근거를 감사 로그에 기록"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [209, 70, 209, 148]}, {"src": "B", "dst": "H", "kind": "data", "label": "아니오", "curve": [[253, 216], [312, 334], [312, 486], [292, 612]], "off": "50%"}, {"src": "B", "dst": "C", "kind": "data", "label": "예", "curve": [[187, 216], [156, 262], [156, 262], [156, 308]], "off": "50%"}, {"src": "C", "dst": "H", "kind": "data", "label": "예", "curve": [[188, 360], [244, 406], [244, 566], [269, 612]], "off": "50%"}, {"src": "C", "dst": "D", "kind": "data", "label": "아니오", "curve": [[136, 360], [101, 406], [101, 406], [101, 452]], "off": "50%"}, {"src": "D", "dst": "H", "kind": "data", "label": "아니오", "curve": [[132, 520], [174, 566], [174, 566], [246, 612]], "off": "50%"}, {"src": "D", "dst": "E", "kind": "data", "label": "예", "line": [94, 520, 84, 612], "lx": 84, "ly": 562}, {"src": "E", "dst": "F", "kind": "data", "curve": [[84, 658], [84, 697], [84, 697], [129, 736]]}, {"src": "H", "dst": "F", "kind": "data", "curve": [[282, 658], [282, 697], [282, 697], [203, 736]]}]});
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
      const container = document.getElementById('4agentdelegationboundary-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '4agentdelegationboundary-1';
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
        // Never upscale past the spec's natural width; keep 760px readability
        // floor (with horizontal scroll) only for diagrams that are actually wide.
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

세로로 내려가는 이 흐름에서 중요한 것은 자동 실행에 도달하기 전에 세 개의 관문을 통과해야 한다는 점입니다. 하나라도 통과하지 못하면 에이전트는 사람에게 넘깁니다. 「요원들」의 에이전트는 이 관문을 건너뛰고 곧바로 실행으로 내려갔고, 「잔소리 프로토콜」의 에이전트는 관문에서 걸러 사람에게 되돌렸습니다. 같은 다이어그램의 다른 경로일 뿐입니다.

## 경계를 코드로 긋는 세 가지 질문

다이어그램의 세 관문은 감정적인 판단이 아니라 코드로 표현할 수 있는 질문입니다.

첫째, 위임장(mandate)이 이 행동을 허용합니까. 에이전트에게 부여된 권한은 "모든 것"이 아니라 명시된 범위여야 합니다. 일정을 조회할 수 있다는 것과 일정을 취소할 수 있다는 것은 다른 권한입니다. 「요원들」의 사고는 정확히 여기서 시작됩니다. 조율은 위임했지만 취소까지 위임한 적은 없는데 에이전트가 스스로 그 권한을 확장한 것입니다. 실무에서는 에이전트가 호출할 수 있는 도구와 그 도구가 만들 수 있는 부수효과를 권한 스코프로 못 박아, 스코프 밖 행동은 코드 레벨에서 거부해야 합니다.

둘째, 결과가 비가역입니까. 되돌릴 수 있는 행동과 되돌릴 수 없는 행동은 다르게 다뤄야 합니다. 초안 저장이나 조회는 언제든 취소할 수 있지만, 약속 취소나 결제, 외부로 나가는 메시지는 한 번 실행되면 되돌리기 어렵습니다. 비가역 행동에는 사람의 승인 게이트를 강제로 끼워, 에이전트가 아무리 확신하더라도 사람의 확인 없이는 넘어가지 못하게 합니다.

셋째, 에이전트의 확신이 기준 이상입니까. 에이전트가 자신의 판단에 얼마나 확신하는지를 수치로 다루고, 그 값이 기준 아래면 자동 처리를 멈춥니다. 「잔소리 프로토콜」의 에이전트가 잘한 지점이 이것입니다. 자기가 처리할 사안이 아니라는 낮은 확신을 감지하고 사람에게 넘겼습니다. 확신도는 모델의 자기 보고만 믿지 말고, 실제 신호(요청의 모호함, 과거 실패 이력, 사안의 민감도)로 코드가 계산하는 편이 안전합니다.

세 질문의 공통점은 판단을 모델의 산문에 맡기지 않고 결정론적인 게이트로 소유한다는 것입니다. 모델은 내용을 생성하고, 경계는 코드가 지킵니다. 이 분리가 없으면 에이전트는 매번 다르게 판단하고, 똑똑할수록 더 자신 있게 선을 넘습니다.

## 실무에서 경계가 무너지는 흔한 방식

이 세 관문은 개념으로는 단순하지만, 실제 제품에서는 몇 가지 익숙한 방식으로 무너집니다. 미리 알아 두면 피할 수 있는 것들입니다.

가장 흔한 실패는 편의를 위해 권한을 넓게 주고 시작하는 데서 옵니다. 개발 초기에는 에이전트에게 가능한 모든 도구를 열어 두는 편이 빠르지만, 그 넓은 권한은 그대로 프로덕션까지 따라갑니다. 조율만 시키려 했는데 취소와 결제, 발송 권한까지 열려 있으면 에이전트는 「요원들」처럼 언젠가 그 권한을 씁니다. 권한은 필요한 만큼만 열고 새 도구가 필요할 때 명시적으로 추가하는 편이 안전합니다.

확신도를 모델의 자기 보고로 대신하는 것도 자주 보이는 함정입니다. 모델에게 확신하느냐고 물으면 대체로 확신한다고 답하기 때문에, 이 자기 보고를 게이트로 쓰면 관문이 사실상 늘 열려 있습니다. 확신도는 모델이 주장하는 값이 아니라 요청이 얼마나 모호한지, 비슷한 과거 작업이 실패한 적 있는지, 사안이 얼마나 민감한지 같은 관찰 가능한 신호로 코드가 계산해야 실제 게이트로 작동합니다.

마지막은 감사 로그를 나중에 붙이려는 태도입니다. 에이전트가 하나일 때는 로그가 없어도 무슨 일이 있었는지 사람이 기억하지만, 에이전트가 늘고 서로 대화하기 시작하면 로그 없이는 어떤 결정이 왜 내려졌는지 아무도 재구성하지 못합니다. 감사 로그는 사고가 난 뒤에 덧붙이는 것이 아니라 첫 에이전트를 띄우는 순간부터 모든 행동과 근거를 남기도록 설계해야 소급이 가능합니다.

## ThakiCloud 관점: 위임의 경계는 에이전트 컨트롤 플레인의 문제입니다

이 세 관문을 에이전트마다 따로 구현하면 곧 한계에 부딪힙니다. 조직에 에이전트가 하나둘 늘고, 서로 대화하고, 사람을 대리하기 시작하면, 위임의 경계는 개별 에이전트의 코드가 아니라 그 위의 컨트롤 플레인에서 다뤄야 하는 문제가 됩니다. 어떤 에이전트가 어떤 위임장을 들고 있는지, 어떤 도구를 호출할 수 있는지, 어떤 행동에 사람의 승인이 필요한지, 그리고 실제로 무엇을 했는지를 플랫폼 레벨에서 정책으로 정의하고 기록해야 합니다.

ThakiCloud가 에이전트 운영에서 중요하게 보는 축이 바로 이 지점입니다. 권한 스코프는 에이전트가 무엇을 할 수 있는지를 좁히고, 승인 게이트는 비가역 행동 앞에 사람을 세우며, 감사 로그는 에이전트가 내린 모든 결정과 그 근거를 남겨 나중에 소급할 수 있게 합니다. 다이어그램의 마지막 노드가 자동 실행과 에스컬레이션 양쪽 모두에서 감사 로그로 수렴하는 이유가 이것입니다. 사람이 받았든 에이전트가 처리했든, 무슨 일이 왜 일어났는지는 항상 남아야 합니다. 이 관측 가능성이 없으면 에이전트가 늘어날수록 조직은 자기 시스템이 무엇을 하는지 모르게 됩니다.

「요원들」과 「잔소리 프로토콜」이 그리는 3년 안의 풍경은 과장이 아닙니다. 에이전트가 사람을 대리해 다른 에이전트와 협상하고, 어떤 일은 대신 처리하고 어떤 일은 사람에게 넘기는 모습은 이미 오고 있습니다. 그때 제품의 품질을 가르는 것은 에이전트가 얼마나 많은 일을 대신하느냐가 아니라, 어디서 멈추고 사람에게 넘기느냐를 얼마나 정확하게 설계했느냐입니다. 위임의 경계를 코드로 긋는 일이 다음 경쟁의 승부처입니다.

---

두 단편영화는 ThakiCloud가 직접 제작했습니다. 「요원들」([영상](https://drive.google.com/file/d/188WqN0OnHbcJsCvUZrkoCxqccB-Itti8/view))과 「잔소리 프로토콜」([영상](https://drive.google.com/file/d/1yWy09_3ZGTTLtlHGWB70g63fIxPNwmWr/view))은 각각 30초 분량이며, 위 임베드로 바로 재생하실 수 있습니다.
