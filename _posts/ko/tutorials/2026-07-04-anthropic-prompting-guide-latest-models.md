---
title: "Anthropic 프롬프팅 가이드 정독: Fable 5·Sonnet 5·Opus 4.8 모델별 전략"
excerpt: "Anthropic이 최신 모델용 프롬프팅 베스트 프랙티스를 정리한 공식 가이드를 뜯어봅니다. 모델별 차이, 핵심 기법(명료성·예시·XML·사고연쇄·역할·체이닝·확장 사고), 마이그레이션까지. ThakiCloud가 Paxis 스킬 하니스에서 프롬프트를 계약으로 굳히는 방식과 연결합니다."
tags:
  - prompt-engineering
  - claude
  - developer-experience
  - agent-native
  - paxis
date: 2026-07-04
lang: ko
canonical_url: "https://thakicloud.com/tech-blog/ko/tutorials/anthropic-prompting-guide-latest-models/"
categories:
  - tutorials
---

![구조화된 지시가 층층이 쌓여 하나의 정돈된 출력으로 수렴하는 추상 이미지]({{ '/assets/images/anthropic-prompting-guide-latest-models-hero.webp' | relative_url }})
*명료한 지시와 구조가 모여 예측 가능한 출력으로 수렴하는 프롬프팅의 원리를 형상화했습니다.*

## 개요

프롬프트를 잘 쓰는 일은 여전히 모델을 잘 쓰는 일의 8할입니다. 모델이 강해질수록 느슨한 지시도 어느 정도 따라오지만, 산출물의 형태와 품질을 안정적으로 뽑아내려면 여전히 명료한 계약이 필요합니다.

Anthropic은 최신 모델을 대상으로 한 프롬프팅 베스트 프랙티스를 공식 문서로 정리해 두고 있습니다. 이 가이드는 Claude Fable 5, Claude Sonnet 5, Claude Opus 4.8을 비롯한 현행 모델을 함께 다루며, 모델별로 어디서 동작이 갈리는지, 모든 모델에 공통으로 통하는 기법이 무엇인지, 이전 세대에서 넘어올 때 무엇을 고쳐야 하는지를 나눠 설명합니다. 이 글에서는 그 구조와 핵심 기법을 정리하고, ThakiCloud가 에이전트 플랫폼 Paxis에서 프롬프트를 즉흥이 아니라 계약으로 다루는 방식과 연결해 봅니다.

## 이 가이드는 무엇인가

Anthropic의 프롬프팅 문서는 크게 세 부분으로 짜여 있습니다.

첫째는 모델별 안내입니다. Fable 5, Sonnet 5, Opus 4.8이 서로 다르게 반응하는 지점을 먼저 짚어, 같은 프롬프트라도 모델에 따라 조정이 필요할 수 있음을 알려 줍니다. 둘째는 모든 현행 모델에 공통으로 적용되는 기법입니다. 일반 원칙부터 출력 포맷팅, 도구 사용, 사고(thinking), 에이전트 시스템 설계까지 폭넓게 다룹니다. 셋째는 마이그레이션 고려 사항으로, 이전 세대에서 넘어온 프롬프트를 어떻게 손봐야 하는지를 안내합니다.

이 세 갈래 구조를 그림으로 옮기면 다음과 같습니다.

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
<div class="d3-arch" data-arch-root id="omptingguidelatestmodels-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 657, "height": 926, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 24, "y": 428, "w": 120, "h": 46, "title": "프롬프팅 가이드"}, {"id": "B", "x": 222, "y": 840, "w": 120, "h": 46, "title": "모델별 안내"}, {"id": "C", "x": 222, "y": 428, "w": 120, "h": 46, "title": "공통 기법"}, {"id": "D", "x": 222, "y": 24, "w": 120, "h": 46, "title": "마이그레이션"}, {"id": "B1", "x": 420, "y": 832, "w": 205, "h": 62, "title": ["Fable 5 Sonnet 5 Opus 4.8", "동작 차이"]}, {"id": "C1", "x": 463, "y": 731, "w": 120, "h": 46, "title": "명료한 지시"}, {"id": "C2", "x": 463, "y": 630, "w": 120, "h": 46, "title": "멀티샷 예시"}, {"id": "C3", "x": 463, "y": 529, "w": 120, "h": 46, "title": "사고 연쇄 CoT"}, {"id": "C4", "x": 463, "y": 428, "w": 120, "h": 46, "title": "XML 태그 구조화"}, {"id": "C5", "x": 463, "y": 327, "w": 120, "h": 46, "title": "역할 프롬프팅"}, {"id": "C6", "x": 463, "y": 226, "w": 120, "h": 46, "title": "프롬프트 체이닝"}, {"id": "C7", "x": 463, "y": 125, "w": 120, "h": 46, "title": "확장 사고 도구 사용"}, {"id": "D1", "x": 462, "y": 24, "w": 121, "h": 46, "title": "이전 세대 프롬프트 이관"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[90, 474], [183, 863], [183, 863], [222, 863]]}, {"src": "A", "dst": "C", "kind": "data", "line": [144, 451, 222, 451]}, {"src": "A", "dst": "D", "kind": "data", "curve": [[90, 428], [183, 47], [183, 47], [222, 47]]}, {"src": "B", "dst": "B1", "kind": "data", "line": [342, 863, 420, 863]}, {"src": "C", "dst": "C1", "kind": "data", "curve": [[290, 474], [381, 754], [381, 754], [463, 754]]}, {"src": "C", "dst": "C2", "kind": "data", "curve": [[293, 474], [381, 653], [381, 653], [463, 653]]}, {"src": "C", "dst": "C3", "kind": "data", "curve": [[305, 474], [381, 552], [381, 552], [463, 552]]}, {"src": "C", "dst": "C4", "kind": "data", "line": [342, 451, 463, 451]}, {"src": "C", "dst": "C5", "kind": "data", "curve": [[305, 428], [381, 350], [381, 350], [463, 350]]}, {"src": "C", "dst": "C6", "kind": "data", "curve": [[293, 428], [381, 249], [381, 249], [463, 249]]}, {"src": "C", "dst": "C7", "kind": "data", "curve": [[290, 428], [381, 148], [381, 148], [463, 148]]}, {"src": "D", "dst": "D1", "kind": "data", "line": [342, 47, 462, 47]}]});
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
      const container = document.getElementById('omptingguidelatestmodels-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'omptingguidelatestmodels-1';
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

문서와 별개로 Anthropic은 9개 장으로 구성된 인터랙티브 프롬프트 엔지니어링 튜토리얼도 공개하고 있어, 예제와 연습을 직접 실행하며 익힐 수 있습니다.

## 핵심 기법 정리

가이드가 강조하는 기법은 화려한 트릭이 아니라 기본기의 반복입니다. 실무에서 효과 순으로 정리하면 다음과 같습니다.

명료한 지시가 첫째입니다. 무엇을 할지, 어떤 형태로 내놓을지, 무엇을 평가 기준으로 삼을지를 구체적으로 적습니다. "도와줘" 같은 모호한 요청 대신 동작 하나에 결과물 하나를 지정합니다. 산출물의 형태를 명시하는 것만으로도 품질이 가장 크게 올라갑니다.

멀티샷 예시가 둘째입니다. 원하는 어조와 형식을 두세 개의 예로 보여 주면 모델이 그 리듬을 따라옵니다. 특히 출력 포맷이 까다로울 때, 말로 설명하기보다 예시 하나를 붙이는 편이 훨씬 정확합니다.

사고 연쇄(chain of thought)가 셋째입니다. 답을 내기 전에 단계적으로 생각하도록 요청하면 복잡한 추론의 정확도가 올라갑니다. 다만 사고에는 토큰 비용이 따르므로, 정말 추론이 필요한 작업에만 씁니다.

XML 태그를 이용한 구조화가 넷째입니다. 지시, 맥락, 예시, 입력 데이터를 태그로 구분하면 모델이 각 부분의 역할을 헷갈리지 않습니다. 긴 컨텍스트를 다룰 때 특히 효과가 큽니다.

역할 프롬프팅이 다섯째입니다. 모델에게 특정 관점이나 전문가 역할을 부여하면 그 맥락에 맞는 어휘와 판단이 나옵니다. 리뷰, 감사, 특정 도메인 분석에 유용합니다.

프롬프트 체이닝이 여섯째입니다. 하나의 큰 요청을 여러 단계로 쪼개 각 단계의 출력을 다음 단계의 입력으로 넘기면, 한 번에 모든 것을 요구할 때보다 각 단계의 품질이 안정됩니다.

마지막으로 확장 사고와 도구 사용, 에이전트 시스템 설계가 있습니다. 확장 사고는 내부 추론에 예산을 배분하는 기능이고, 도구 사용과 에이전트 설계는 모델이 외부 도구를 호출하고 결과를 다시 받아 다음 행동을 정하는 루프를 다룹니다. 이 부분이 최신 가이드에서 비중이 커진 영역입니다.

## ThakiCloud 제품 적용 시사점

이 가이드가 우리에게 실용적인 이유는, ThakiCloud의 에이전트 플랫폼 Paxis가 프롬프트를 정확히 이 방식으로 다루기 때문입니다. Paxis는 ai-platform 위에서 도는 Agent-Native Cloud 제어 평면으로, 스킬과 도구, 정책, 감사 로그를 일급 리소스로 관리합니다. 그 안에서 프롬프트는 매번 새로 짜는 즉흥물이 아니라, 스킬에 패키징되어 버전 관리되는 계약입니다.

가이드의 첫째 기법인 명료한 지시는 Paxis의 스킬 하니스 설계 원칙과 그대로 겹칩니다. 능력은 얇은 하니스가 아니라 두터운 스킬에 쌓고, 각 스킬은 입력과 처리, 출력, 실패 복구까지를 명시적으로 규정합니다. 산출물의 형태와 평가 기준을 코드가 소유하게 만들면, 모델은 내용 생성에만 집중하고 포맷은 흔들리지 않습니다.

XML 구조화와 프롬프트 체이닝은 DAG 멀티에이전트 오케스트레이션과 맞닿아 있습니다. Paxis는 960개가 넘는 스킬을 BM25로 선택해 격리된 샌드박스에서 실행하는데, 큰 작업을 단계로 쪼개 각 단계의 출력을 다음으로 넘기는 체이닝은 이 오케스트레이션의 기본 문법입니다. 각 단계를 독립된 스킬로 두면 실패한 단계만 다시 돌릴 수 있어 회복 정밀도가 올라갑니다.

역할 프롬프팅과 도구 사용은 정책 게이트, 감사 로그와 결합됩니다. 특정 역할을 부여한 서브에이전트가 도구를 호출하고 결과를 받아 다음 행동을 정하는 루프는, 모든 행동이 정책 게이트와 감사 로그를 통과할 때 비로소 안전하게 자율화됩니다. 가이드가 강조하는 에이전트 시스템 설계가 우리에게는 곧 감사 가능한 자율 실행의 문제로 번역됩니다.

정리하면, 좋은 프롬프팅의 원칙과 견고한 에이전트 플랫폼의 설계 원칙은 사실상 같은 곳을 가리킵니다. 자유도를 줄이고 검증된 골격에 내용을 채워 평균 품질을 올리는 것. 이 가이드는 그 원칙을 프롬프트 수준에서, Paxis는 플랫폼 수준에서 실천합니다.

## 한계 및 반론

이 가이드에도 유의할 점이 있습니다. 첫째, 모델별 안내는 시간이 지나면 낡습니다. 모델이 새로 나오거나 업데이트되면 어제 통하던 프롬프트가 오늘은 다르게 반응할 수 있으므로, 가이드를 도그마가 아니라 현재 시점의 스냅샷으로 읽어야 합니다.

둘째, 기법을 많이 안다고 좋은 프롬프트가 나오는 것은 아닙니다. XML 태그와 사고 연쇄, 역할 프롬프팅을 한꺼번에 쌓으면 오히려 지시가 무거워지고 토큰만 늘 수 있습니다. 각 기법은 언제 쓰지 않을지를 아는 것이 언제 쓸지를 아는 것만큼 중요합니다.

셋째, 확장 사고는 공짜가 아닙니다. 사고 토큰은 비용이며, 모든 작업에 최대 사고를 켜는 것은 낭비입니다. 앞서 다룬 모델 라우팅 관점과 마찬가지로, 사고 예산도 작업 난도에 맞춰 배분해야 합니다.

결론적으로 이 가이드의 가치는 새로운 마법을 알려 주는 데 있지 않습니다. 기본기를 언제 어떻게 조합하는지에 대한 판단을 벼리는 데 있습니다. 그리고 그 판단을 매번 다시 하지 않도록 스킬과 정책으로 굳히는 것이 플랫폼의 몫입니다.

## 출처

- "Prompting best practices", Claude Platform Docs: [platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices)
- "Prompt engineering overview", Anthropic Docs: [docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview)
- "Anthropic's Interactive Prompt Engineering Tutorial", GitHub: [github.com/anthropics/prompt-eng-interactive-tutorial](https://github.com/anthropics/prompt-eng-interactive-tutorial)
