---
title: "GUI 없는 클라우드 맥에서 iOS 앱을 브라우저로 테스트하기: serve-sim"
seo_title: "serve-sim 웹 iOS 시뮬레이터로 헤드리스 개발 - Thaki Cloud"
seo_description: "Expo 코어 개발자 Evan Bacon이 만든 serve-sim은 iOS 시뮬레이터 화면을 브라우저로 스트리밍하고 에이전트가 CLI로 제어하게 해 줍니다. GUI 없는 클라우드 맥에서 AI 코딩 에이전트가 iOS 앱을 빌드하고 직접 테스트하는 워크플로와, 이것이 ThakiCloud의 Paxis 에이전트 플랫폼 및 헤드리스 개발 인프라에 주는 시사점을 정리합니다."
excerpt: "Mac Mini를 클라우드에 두면 GUI가 없어 iOS 시뮬레이터를 볼 수 없습니다. serve-sim은 시뮬레이터의 프레임버퍼를 브라우저로 스트리밍하고 WebSocket으로 제어까지 열어, AI 코딩 에이전트가 헤드리스 환경에서 iOS 앱을 빌드하고 실제로 조작하며 테스트하게 합니다."
date: 2026-07-11
tags:
  - ios-simulator
  - agent-skills
  - developer-tools
  - headless
  - claude-code
  - expo
categories:
  - dev
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/ko/dev/serve-sim-ios-simulator-web/"
---

AI 코딩 에이전트에게 iOS 앱을 만들어 달라고 하면 한 가지 근본적인 벽에 부딪힙니다. 에이전트는 코드를 쓰고 빌드까지는 할 수 있지만, 화면에서 실제로 무슨 일이 벌어지는지 볼 수 없습니다. 특히 개발 환경을 클라우드의 Mac Mini에 올려 두면 문제가 더 커집니다. GUI가 없는 헤드리스 서버에서는 Xcode 시뮬레이터 창 자체가 뜨지 않기 때문입니다.

Expo 코어 팀의 Evan Bacon이 만든 [serve-sim](https://github.com/EvanBacon/serve-sim)은 이 벽을 정면으로 겨냥합니다. 실제로 이 도구는 인디 개발자 levelsio가 "클라우드의 Mac Mini에서 Claude Code가 빌드한 iOS 앱을 브라우저로 실시간 확인할 수 있게 됐다"고 소개하면서 널리 알려졌습니다. serve-sim의 슬로건은 간단합니다. "Apple 시뮬레이터의 `npx serve`."

## 개요

serve-sim이 흥미로운 이유는 단순한 화면 미러링 도구가 아니기 때문입니다. 이 도구는 두 가지를 동시에 엽니다. 하나는 시뮬레이터 화면을 브라우저로 보내는 영상 스트림이고, 다른 하나는 브라우저나 에이전트가 시뮬레이터를 조작하도록 하는 제어 채널입니다. 즉 "보는 것"과 "조작하는 것"을 모두 원격에서 가능하게 만듭니다.

이 조합이 중요한 이유는 AI 코딩 에이전트의 개발 루프를 완성하기 때문입니다. 에이전트가 코드를 고치고, 빌드하고, 실행한 뒤, 그 결과 화면을 보고, 버튼을 눌러 다음 단계로 넘어가는 전체 순환을 사람 없이 돌릴 수 있게 됩니다. ThakiCloud의 Agent-Native Cloud인 Paxis가 지향하는 "에이전트가 격리된 환경에서 실제 작업을 수행하는" 구조와 정확히 맞닿아 있어, 하나의 오픈소스 도구가 그 워크플로를 어떻게 구현하는지 살펴볼 가치가 있습니다.

![클라우드 헤드리스 서버의 스마트폰 화면이 빛의 입자로 흩어져 네트워크를 타고 브라우저 창으로 흘러 들어가는 추상 이미지]({{ '/assets/images/serve-sim-ios-simulator-web-hero.webp' | relative_url }})
*헤드리스 서버의 시뮬레이터 화면이 스트림이 되어 원격 브라우저로 흘러 들어가는 구조를 형상화했습니다.*

## serve-sim은 무엇인가

serve-sim의 동작 원리는 생각보다 단순하고 영리합니다. 별도의 Xcode 플러그인을 설치하거나 앱에 계측 코드를 심을 필요가 없습니다. 대신 작은 Swift 헬퍼 프로세스를 띄워, 이미 부팅된 iOS 시뮬레이터의 프레임버퍼를 애플이 제공하는 `simctl io` 인터페이스로 캡처합니다.

캡처한 화면은 두 갈래로 노출됩니다. 첫째, MJPEG 스트림으로 브라우저에 최대 60 FPS의 영상을 보냅니다. 둘째, WebSocket 제어 채널을 함께 열어 브라우저 쪽에서 탭·제스처 같은 입력을 시뮬레이터로 되돌려 보냅니다. 그 위에 React로 만든 프리뷰 UI가 얹혀, 사람이 브라우저에서 실제 기기처럼 앱을 만질 수 있습니다.

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
<div class="d3-arch" data-arch-root id="1servesimiossimulatorweb-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 247, "height": 922, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 24, "y": 24, "w": 121, "h": 46, "title": "부팅된 iOS 시뮬레이터"}, {"id": "B", "x": 24, "y": 148, "w": 121, "h": 46, "title": "Swift 헬퍼 프로세스"}, {"id": "C", "x": 25, "y": 272, "w": 120, "h": 62, "title": ["simctl io로", "프레임버퍼 캡처"]}, {"id": "D", "x": 81, "y": 412, "w": 120, "h": 62, "title": ["MJPEG 영상 스트림", "최대 60 FPS"]}, {"id": "E", "x": 53, "y": 690, "w": 135, "h": 46, "title": "WebSocket 제어 채널"}, {"id": "F", "x": 66, "y": 552, "w": 149, "h": 46, "title": "브라우저 React 프리뷰 UI"}, {"id": "G", "x": 61, "y": 828, "w": 120, "h": 62, "title": ["에이전트 CLI", "탭·제스처·회전·카메라"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [85, 70, 85, 148]}, {"src": "B", "dst": "C", "kind": "data", "line": [85, 194, 85, 272]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[109, 334], [141, 373], [141, 373], [141, 412]]}, {"src": "C", "dst": "E", "kind": "data", "curve": [[60, 334], [29, 443], [29, 575], [90, 690]]}, {"src": "D", "dst": "F", "kind": "data", "line": [141, 474, 141, 552]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[121, 690], [121, 644], [121, 644], [134, 598]]}, {"src": "E", "dst": "G", "kind": "data", "line": [121, 736, 121, 828]}, {"src": "F", "dst": "E", "kind": "event", "label": "사람이 조작", "curve": [[147, 598], [160, 644], [160, 644], [134, 690]], "off": "50%"}, {"src": "G", "dst": "E", "kind": "event", "label": "에이전트가 조작", "curve": [[103, 828], [75, 782], [75, 782], [106, 736]], "off": "50%"}]});
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
      const container = document.getElementById('1servesimiossimulatorweb-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '1servesimiossimulatorweb-1';
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

핵심은 "어떤 부팅된 시뮬레이터든" 대상이 된다는 점입니다. 앱을 수정할 필요가 없으므로, 이미 있는 프로젝트에 그대로 붙일 수 있습니다. 게다가 시뮬레이터 로그를 브라우저로 전달해, browser-use 계열 MCP 도구가 그 로그를 읽어 상태를 판단하게 할 수도 있습니다. 브라우저 창에 영상·이미지를 드래그 앤 드롭하면 시뮬레이터 기기에 파일로 추가되는 편의 기능도 있습니다.

## 설치 및 사용

serve-sim의 진입 장벽은 낮습니다. Node.js가 있는 맥에서 한 줄이면 됩니다.

```bash
npx serve-sim
```

실행하면 로컬 `http://localhost:3200`에서 프리뷰를 확인할 수 있습니다. 로컬에서 쓰거나, LAN을 통해 같은 네트워크의 다른 기기에서 접속하거나, 원격 맥에 올려 두고 터널링으로 어디서든 접속하는 세 가지 모드를 지원합니다. levelsio의 사례가 바로 세 번째로, 클라우드의 헤드리스 Mac Mini에서 실행하고 원격 브라우저로 확인하는 방식입니다.

에이전트 통합은 별도의 Agent Skill로 제공됩니다. 저장소의 `skills/serve-sim`에 담긴 이 스킬은 Claude Code·Cursor·Codex CLI·Gemini CLI를 비롯해 오픈 Agent Skills 표준을 구현한 모든 호스트에게 시뮬레이터를 CLI로 조작하는 방법을 가르칩니다. 탭, 제스처, 하드웨어 버튼, 화면 회전, 카메라 입력 주입, 그리고 스트림을 호스트의 프리뷰 창으로 넘기는 동작까지 포함됩니다.

## 재현 참고

이 글을 작성한 실행 환경은 GUI가 없는 헤드리스 배치 세션으로, Node.js 실행이 정책상 차단되어 있어 `npx serve-sim`을 직접 구동해 화면을 캡처하지는 못했습니다. 따라서 이 글의 명령과 동작 설명은 저장소 README와 공식 소개 자료에서 확인한 사실에 근거하며, 벤치마크 수치를 지어내지 않았습니다. 실제 시뮬레이터 스트리밍 화면과 지연 시간은 macOS + Xcode 시뮬레이터가 부팅된 환경에서 위 명령으로 직접 확인하시기 바랍니다.

## ThakiCloud 제품 적용 시사점

serve-sim은 표면적으로는 iOS 개발자용 도구지만, 그 아래에는 에이전트 네이티브 개발이라는 더 큰 흐름이 깔려 있습니다.

**Paxis 렌즈 (에이전트 네이티브 개발).** ThakiCloud의 Paxis는 스킬을 격리 샌드박스에서 실행하고 모든 행동을 정책 게이트와 감사 로그로 통과시키는 Agent-Native Cloud 제어 평면입니다. serve-sim이 채택한 개방형 Agent Skills 표준은 Paxis의 스킬 하네스가 다루는 것과 같은 계약 모델입니다. 하나의 스킬이 "시뮬레이터를 탭하고 회전시키고 화면을 읽는" 능력을 여러 에이전트 호스트에 공통으로 제공한다는 발상은, Paxis가 960개 이상의 스킬을 BM25로 선택해 격리 실행하는 구조와 정확히 같은 방향을 향합니다. 특히 serve-sim의 제어 채널처럼 에이전트가 실제 UI를 조작하는 워크로드는, 그 조작이 정책 게이트를 통과하고 감사 로그로 기록되어야 안전하게 프로덕션에 올릴 수 있습니다. serve-sim이 "능력"을 제공한다면, Paxis는 그 능력을 "안전하게 통제"하는 계층을 제공합니다.

**ai-platform 렌즈 (헤드리스 실행 인프라).** serve-sim의 진짜 매력은 헤드리스 원격 맥에서 동작한다는 점입니다. GUI 없는 서버에서 빌드하고 스트리밍한다는 발상은 ThakiCloud ai-platform이 Kubernetes 위에서 워크로드를 GUI 없이 스케줄링하고 실행하는 방식과 같은 철학입니다. iOS 빌드가 요구하는 macOS 러너를 온디맨드로 붙이고, 그 위에서 에이전트가 빌드·테스트를 자동으로 돌린 뒤 결과만 사람에게 스트리밍하는 파이프라인은 CI를 넘어 "에이전트 주도 QA"로 확장될 수 있습니다. 저비용 헤드리스 실행 인프라(ai-platform)가 에이전트 자동화(Paxis)의 경제성을 떠받치는 구조입니다.

## 한계 및 반론

몇 가지는 냉정하게 짚어야 합니다.

첫째, serve-sim은 시뮬레이터를 대상으로 합니다. 실제 물리 기기가 아니라 시뮬레이터이므로, 카메라·센서·성능 특성처럼 실기기에서만 드러나는 문제는 여전히 잡지 못합니다. 시뮬레이터 통과가 실기기 통과를 보장하지 않는다는 오래된 한계는 그대로 남습니다.

둘째, MJPEG 스트리밍은 단순하고 호환성이 좋지만 압축 효율이 높지 않습니다. 60 FPS 고화질 스트림을 원격 터널로 계속 흘리면 대역폭과 지연이 병목이 될 수 있습니다. 반응 속도가 중요한 제스처 테스트에서는 네트워크 왕복 지연이 그대로 조작 지연으로 이어집니다.

셋째, 에이전트가 화면을 "보고 조작"할 수 있게 되는 것과, 그 판단이 정확한 것은 별개입니다. 에이전트가 스트림을 잘못 해석해 엉뚱한 버튼을 누르는 실패는 여전히 가능하며, 이 지점이 바로 정책 게이트와 사람 검토가 필요한 이유입니다. 도구가 능력을 열어 줄수록, 그 능력을 통제하는 계층의 중요성이 커집니다.

그럼에도 serve-sim의 방향은 분명합니다. "에이전트가 코드만 쓰는 단계"에서 "에이전트가 빌드하고 실행하고 직접 화면을 조작하며 검증하는 단계"로 넘어가는 데 필요한 실질적인 다리를 하나 놓았습니다. 헤드리스 클라우드에서 모바일 앱을 에이전트로 개발하려는 팀이라면, 지금 바로 `npx serve-sim` 한 줄로 그 세계를 열어 볼 수 있습니다.


## 관련 슬라이드

본문 내용을 NotebookLM(`neo_swiss` 스타일)으로 요약한 슬라이드입니다.

![serve-sim-ios-simulator-web 슬라이드 1]({{ '/assets/images/serve-sim-ios-simulator-web-slide-01.webp' | relative_url }})

![serve-sim-ios-simulator-web 슬라이드 2]({{ '/assets/images/serve-sim-ios-simulator-web-slide-02.webp' | relative_url }})

![serve-sim-ios-simulator-web 슬라이드 3]({{ '/assets/images/serve-sim-ios-simulator-web-slide-03.webp' | relative_url }})

![serve-sim-ios-simulator-web 슬라이드 4]({{ '/assets/images/serve-sim-ios-simulator-web-slide-04.webp' | relative_url }})

## 출처

- Evan Bacon. "serve-sim: The `npx serve` of Apple Simulators." GitHub. <https://github.com/EvanBacon/serve-sim>
- @levelsio, serve-sim 소개 트윗. <https://x.com/levelsio/status/2075328941317886210>
