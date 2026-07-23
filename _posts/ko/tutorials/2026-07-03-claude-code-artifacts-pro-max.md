---
title: "Claude Code 아티팩트가 Pro·Max로 열렸습니다: 세션이 곧 살아있는 웹페이지"
excerpt: "Claude Code의 아티팩트 기능이 Team·Enterprise를 넘어 Pro·Max 요금제까지 확대됐습니다. 세션의 작업을 실시간으로 갱신되는 공유 가능한 웹페이지로 바꾸는 이 기능을 뜯어보고, ThakiCloud의 Paxis와 ai-platform 관점에서 어떻게 쓸 수 있는지 정리합니다."
tags:
  - claude-code
  - artifacts
  - agent-native
  - developer-experience
  - paxis
date: 2026-07-03
lang: ko
canonical_url: "https://thakicloud.com/tech-blog/ko/technique/claude-code-artifacts-pro-max/"
categories:
  - tutorials
---

![코드 세션의 결과물이 층을 이루며 하나의 살아있는 페이지로 조립되는 추상 이미지]({{ '/assets/images/claude-code-artifacts-pro-max-hero.webp' | relative_url }})
*코드 세션의 진행 상황이 실시간으로 갱신되는 하나의 공유 페이지로 응축됩니다.*

## 개요

코딩 에이전트가 몇 시간짜리 작업을 끝냈을 때, 정작 그 결과를 남에게 보여주는 일은 여전히 번거롭습니다. 터미널 로그를 캡처해 붙이거나, 변경 사항을 손으로 요약하거나, 별도로 대시보드를 만들어야 했습니다. 작업 자체보다 작업을 설명하는 데 시간이 더 드는 경우도 적지 않았습니다.

2026년 7월, Anthropic은 Claude Code의 아티팩트(Artifacts) 기능을 Pro와 Max 요금제까지 확대했습니다. 그동안 Team과 Enterprise에서만 쓸 수 있던 기능이 개인 개발자에게도 열린 것입니다. 핵심은 단순합니다. 아티팩트를 요청하면 Claude가 코드를 작성해 claude.ai에 라이브로 게시하고, 세션이 계속 돌아가는 동안 그 페이지를 실시간으로 갱신합니다. 페이지는 계정에 비공개로 귀속되며 완전히 자기완결적(self-contained)입니다.

이 글에서는 Claude Code 아티팩트가 정확히 무엇인지, Pro·Max 확대가 왜 의미가 있는지, 그리고 ThakiCloud가 운용하는 에이전트 플랫폼 Paxis와 AI 인프라 ai-platform의 관점에서 이 패턴을 어떻게 흡수할 수 있는지 살펴봅니다.

![코딩보다 작업을 설명하는 데 더 많은 시간이 드는 모순을 나타낸 인포그래픽]({{ '/assets/images/claude-code-artifacts-pro-max-slide-02.webp' | relative_url }})
*작업 자체보다 "지금 무슨 일이 벌어지고 있는지"를 설명하는 데 더 많은 에너지가 소모되던 문제.*

## Claude Code 아티팩트란 무엇인가

아티팩트는 원래 claude.ai 대화 안에서 코드나 문서를 별도 패널로 렌더링하는 기능이었습니다. 이번에 Claude Code로 들어온 아티팩트는 성격이 조금 다릅니다. 대화 한 번의 산출물이 아니라, 코딩 세션 전체의 진행 상황을 하나의 살아있는 시각 페이지로 만듭니다.

![단발성 산출물에서 세션 전체를 렌더링하는 살아있는 시각 페이지로 전환되는 개념도]({{ '/assets/images/claude-code-artifacts-pro-max-slide-04.webp' | relative_url }})
*대화 한 번의 산출물이 아니라 세션 전체의 진행 상황을 실시간으로 렌더링하는 살아있는 페이지입니다.*

Anthropic이 예시로 든 용도는 네 가지입니다. 풀 리퀘스트 설명(PR walkthrough), 시스템 동작을 설명하는 페이지(system explainer), 대시보드, 그리고 릴리스 체크리스트입니다. 공통점은 모두 "지금 무슨 일이 벌어지고 있는지"를 사람이 읽을 수 있게 정리한 산출물이라는 점입니다. 그리고 세션이 작업을 이어가는 동안 이 페이지가 스스로 갱신됩니다.

작업에서 게시까지의 흐름은 다음과 같습니다.

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
<div class="d3-arch" data-arch-root id="laudecodeartifactspromax-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 466, "height": 866, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 86, "y": 24, "w": 120, "h": 46, "title": "개발자: 아티팩트 요청"}, {"id": "B", "x": 68, "y": 148, "w": 156, "h": 46, "title": "Claude Code가 코드 작성"}, {"id": "C", "x": 71, "y": 272, "w": 149, "h": 46, "title": "claude.ai에 라이브 게시"}, {"id": "D", "x": 77, "y": 396, "w": 138, "h": 52, "title": "세션 계속 진행"}, {"id": "E", "x": 24, "y": 540, "w": 120, "h": 46, "title": "페이지 실시간 갱신"}, {"id": "F", "x": 199, "y": 540, "w": 120, "h": 46, "title": "자기완결 페이지 확정"}, {"id": "G", "x": 199, "y": 664, "w": 120, "h": 46, "title": "게시 링크 공유"}, {"id": "H", "x": 102, "y": 788, "w": 121, "h": 46, "title": "수신자: 계정 없이 열람"}, {"id": "I", "x": 278, "y": 788, "w": 156, "h": 46, "title": "계정 보유자: 리믹스로 사본 편집"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [146, 70, 146, 148]}, {"src": "B", "dst": "C", "kind": "data", "line": [146, 194, 146, 272]}, {"src": "C", "dst": "D", "kind": "data", "line": [146, 318, 146, 396]}, {"src": "D", "dst": "E", "kind": "data", "label": "작업 상태 변화", "curve": [[146, 448], [146, 494], [146, 494], [105, 540]], "off": "50%"}, {"src": "E", "dst": "D", "kind": "data", "curve": [[76, 540], [61, 494], [61, 494], [115, 448]]}, {"src": "D", "dst": "F", "kind": "data", "label": "완료", "curve": [[186, 448], [259, 494], [259, 494], [259, 540]], "off": "50%"}, {"src": "F", "dst": "G", "kind": "data", "line": [259, 586, 259, 664]}, {"src": "G", "dst": "H", "kind": "data", "curve": [[223, 710], [162, 749], [162, 749], [162, 788]]}, {"src": "G", "dst": "I", "kind": "data", "curve": [[295, 710], [356, 749], [356, 749], [356, 788]]}]});
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
      const container = document.getElementById('laudecodeartifactspromax-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'laudecodeartifactspromax-1';
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

여기서 두 가지 설계 결정이 눈에 띕니다. 첫째, 페이지가 자기완결적입니다. 외부 빌드 파이프라인이나 호스팅 설정 없이, 게시된 페이지 하나에 필요한 것이 다 들어갑니다. 둘째, 기본값이 비공개입니다. 페이지는 계정에 귀속되고, 게시 버튼을 눌러 링크를 공유하기 전까지는 남이 볼 수 없습니다.

![자기완결성과 기본 비공개라는 두 가지 설계 원칙을 나타낸 도식]({{ '/assets/images/claude-code-artifacts-pro-max-slide-06.webp' | relative_url }})
*자기완결성(외부 호스팅 불필요)과 기본 비공개(게시 전까지 계정에 귀속)라는 두 축.*

## Pro·Max 확대가 의미하는 것

기능 자체는 몇 달 전부터 Team과 Enterprise에서 쓸 수 있었습니다. 이번 변화의 핵심은 요금제 경계가 내려왔다는 것입니다.

정확히 구분하면 이렇습니다. claude.ai 대화에서 만드는 일반 아티팩트는 이전부터 Free·Pro·Max를 포함한 모든 요금제에서 게시할 수 있었습니다. 반면 Claude Code 세션을 라이브 페이지로 바꾸는 아티팩트는 Team·Enterprise 전용이었습니다. 이번에 그 경계가 Pro와 Max까지 확대됐습니다. 조직 단위 좌석 없이도 개인 개발자가 자기 세션을 공유 가능한 페이지로 만들 수 있게 된 것입니다.

![요금제별 아티팩트 게시 권한 매트릭스: 일반 대화형은 전 요금제, Code 세션 라이브 페이지는 Pro·Max로 확대]({{ '/assets/images/claude-code-artifacts-pro-max-slide-08.webp' | relative_url }})
*일반 대화형 아티팩트 게시는 이전부터 전 요금제 가능. 이번 변화는 Code 세션 라이브 페이지가 Pro·Max로 내려온 것입니다.*

이것이 왜 중요한지는 개인 개발자의 실제 작업 패턴을 보면 드러납니다. 오픈소스 기여자가 긴 리팩터링을 끝냈을 때, 리뷰어에게 변경의 맥락을 전달할 방법이 필요합니다. 사이드 프로젝트를 돌리는 1인 개발자가 진행 상황을 스스로 추적하거나 동료에게 데모를 보여줄 때도 마찬가지입니다. 지금까지 이런 사용자는 조직 요금제에 묶이지 않으면 이 기능을 쓸 수 없었습니다. Pro·Max 확대는 이 격차를 메웁니다.

한 가지 덧붙이면, Anthropic은 같은 기간 Pro·Max·Team의 Claude Code 주간 사용 한도를 한시적으로 상향하기도 했습니다. 기능 접근성과 사용량 여유가 함께 열린 셈이라, 개인 개발자가 실제로 이 기능을 시험해 볼 여지가 커졌습니다.

## 실제 사용 흐름

사용 방법은 대화에 가깝습니다. 세션 중에 "이 작업을 아티팩트로 만들어 줘"라고 요청하면, Claude Code가 현재 진행 상황을 담은 페이지를 생성해 claude.ai에 게시합니다. 반환된 링크를 열면 지금까지의 작업이 정리된 시각 페이지가 보이고, 세션이 계속 돌아가면 이 페이지가 새로고침 없이 갱신됩니다.

공유는 아티팩트 패널 하단의 게시 버튼을 통해 이뤄집니다. 링크를 받은 사람은 Claude 계정이 없어도 페이지를 열람할 수 있습니다. 계정이 있는 사람은 리믹스(remix) 기능으로 자기만의 편집 가능한 사본을 만들 수 있습니다. 즉 하나의 아티팩트가 읽기 전용 공유물이자 다른 사람이 이어받아 발전시킬 수 있는 출발점이 됩니다.

![요청, 실시간 갱신, 링크 게시, 리믹스로 이어지는 아티팩트 생명주기]({{ '/assets/images/claude-code-artifacts-pro-max-slide-07.webp' | relative_url }})
*요청(Prompt) → 실시간 갱신(Live Update) → 링크 게시(Publish) → 리믹스(Remix)로 이어지는 흐름.*

프라이버시 모델도 명확합니다. Claude Code에서 만든 페이지는 기본적으로 계정에 비공개입니다. 게시해 링크를 넘기는 순간에만 외부에 노출되며, 그전까지는 본인만 볼 수 있습니다. 민감한 내부 작업을 다루는 개발자에게는 이 기본값이 중요합니다. 실수로 공개되는 경로가 없기 때문입니다.

이 흐름에서 특히 실용적인 조합은 PR 설명입니다. 긴 변경을 마친 뒤 아티팩트를 요청하면, 무엇을 왜 바꿨는지, 어떤 파일이 영향을 받는지, 어떻게 검증했는지를 담은 페이지가 나옵니다. 리뷰어는 diff를 읽기 전에 이 페이지로 맥락을 먼저 잡을 수 있습니다. 인시던트 대응 페이지나 릴리스 체크리스트도 같은 방식으로, 사람이 읽을 요약을 에이전트가 스스로 유지하게 만드는 용도입니다.

## ThakiCloud 제품 적용 시사점

이 기능의 진짜 함의는 단일 도구의 편의를 넘어섭니다. "에이전트의 작업 산출물을 사람이 읽을 수 있는 공유 가능한 아티팩트로, 그것도 실시간으로 유지한다"는 패턴 자체가 에이전트 플랫폼의 핵심 과제이기 때문입니다.

**Paxis 관점 (에이전트 산출물의 일급 자원화).** ThakiCloud의 Paxis는 ai-platform 위에서 도는 Agent-Native Cloud 제어 평면으로, Skills·Tools·Policies·Audit Logs를 일급 리소스로 다룹니다. Claude Code 아티팩트가 보여주는 것은 에이전트의 중간·최종 산출물을 별도 관측 채널로 노출하는 방식입니다. Paxis에서 DAG 멀티에이전트가 긴 작업을 수행할 때, 각 노드의 진행 상황을 사람이 읽을 수 있는 라이브 페이지로 응축하면 운영자는 로그를 스크롤하지 않고도 흐름을 파악할 수 있습니다. 여기에 Paxis의 정책 게이트와 감사 로그를 결합하면, 아티팩트가 "누가 무엇을 언제 만들고 공유했는가"까지 추적되는 통제된 산출물이 됩니다. Anthropic의 기본 아티팩트가 계정 비공개인 것과 같은 맥락에서, Paxis는 산출물 공유에 정책 기반 접근 제어를 얹어 조직 단위로 확장할 수 있습니다.

![Paxis 관점: 에이전트 산출물을 정책 게이트와 감사 로그로 통제되는 일급 자원으로 다루는 도식]({{ '/assets/images/claude-code-artifacts-pro-max-slide-10.webp' | relative_url }})
*Paxis는 에이전트 산출물을 정책 게이트와 감사 로그 아래 두어 통제된 공유 아티팩트로 격상합니다.*

**ai-platform 관점 (내부 운영 페이지).** 인프라 측면에서는 자기완결 페이지가 내부 대시보드와 인시던트 페이지에 잘 맞습니다. ThakiCloud의 ai-platform은 K8s·Kueue GPU 스케줄링·vLLM 멀티테넌트 서빙을 운용하며, 이 위에서 도는 배치·서빙 작업은 상태를 사람에게 전달할 채널이 필요합니다. 에이전트가 릴리스 체크리스트나 배포 진행 페이지를 스스로 유지하게 만들면, 온프렘·소버린 환경에서 별도 관측 스택을 늘리지 않고도 운영 가시성을 확보할 수 있습니다. 자기완결이라는 성질은 외부 호스팅 의존을 줄이므로, 폐쇄망 요구가 강한 고객 환경에서도 부담이 적습니다.

![ai-platform 관점: 자기완결 페이지로 폐쇄망 내부 운영 가시성을 확보하는 도식]({{ '/assets/images/claude-code-artifacts-pro-max-slide-11.webp' | relative_url }})
*자기완결 페이지는 외부 호스팅 의존을 줄여, 온프렘·소버린 환경의 운영 가시성 확보에 유리합니다.*

두 관점은 서로를 보완합니다. ai-platform이 낮은 비용으로 에이전트 워크로드를 실행하고, Paxis가 그 산출물을 정책과 감사 아래 공유 가능한 아티팩트로 다룬다면, "에이전트가 일하고 그 결과가 곧바로 사람이 읽을 산출물이 되는" 경험을 자체 플랫폼 위에서 재현할 수 있습니다.

## 한계 및 반론

기대를 조정할 지점도 분명합니다.

![Claude Code 아티팩트의 태생적 한계와 ThakiCloud 플랫폼의 보완적 역할을 대비한 도식]({{ '/assets/images/claude-code-artifacts-pro-max-slide-12.webp' | relative_url }})
*호스팅 종속·프런트엔드 한계·지속성 부재라는 제약과, 그것을 메우는 온프렘·상태 지속성·통제 접근.*

첫째, 이 기능은 claude.ai 게시에 묶여 있습니다. 페이지가 Anthropic 인프라에 호스팅되므로, 완전한 폐쇄망이나 데이터 반출이 금지된 환경에서는 그대로 쓰기 어렵습니다. 소버린 요구가 강한 고객에게는 자체 호스팅 대안이 필요하며, 이것이 오히려 ThakiCloud 같은 온프렘 지향 플랫폼이 채울 수 있는 공백입니다.

둘째, 자기완결 페이지는 단순 요약과 대시보드에는 훌륭하지만, 복잡한 상호작용이나 대용량 데이터 연동에는 한계가 있습니다. 게시된 아티팩트는 본질적으로 가벼운 프런트엔드이며, 무거운 백엔드 로직을 대체하지 않습니다.

셋째, 실시간 갱신은 세션이 살아 있는 동안에만 유효합니다. 세션이 끝나면 페이지는 그 시점의 스냅샷으로 고정됩니다. 지속적으로 갱신되는 운영 대시보드가 필요하다면 별도 파이프라인이 여전히 필요합니다.

정리하면, Claude Code 아티팩트의 Pro·Max 확대는 개인 개발자가 에이전트 작업을 공유 가능한 산출물로 바꾸는 문턱을 크게 낮춘 변화입니다. 다만 호스팅과 지속성의 제약은 남아 있으며, 바로 그 지점에서 정책·감사·온프렘을 갖춘 에이전트 플랫폼이 보완적 가치를 가집니다. 도구의 편의를 흡수하되, 통제와 주권이 필요한 영역은 자체 플랫폼으로 메우는 것이 현실적인 접근입니다.

## 출처

- [ClaudeDevs (@ClaudeDevs) 발표 게시물](https://x.com/ClaudeDevs/status/2072770790114914317)
- [Publish and share artifacts (Claude Help Center)](https://support.claude.com/en/articles/9547008-publish-and-share-artifacts)
- [What are artifacts and how do I use them? (Claude Help Center)](https://support.claude.com/en/articles/9487310-what-are-artifacts-and-how-do-i-use-them)
