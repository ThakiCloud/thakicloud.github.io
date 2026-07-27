---
title: "에이전트가 스스로 자기 하네스를 고친다: Self-Harness가 보여준 자가개선의 진짜 병목"
seo_title: "Self-Harness 논문 리뷰: 하네스가 스스로 개선되는 3단계 루프 | ThakiCloud"
seo_description: "MiniMax M2.5, Qwen3.5-35B-A3B, GLM-5를 Terminal-Bench-2.0에서 40.5%에서 61.9%까지 끌어올린 Self-Harness(arXiv 2606.09498)를 정리했습니다. 사람 엔지니어 없이 에이전트가 자기 하네스를 약점 발굴, 개선안 제안, 개선안 검증의 3단계로 고칩니다. 자가개선 루프의 진짜 병목이 평가자라는 점을 ThakiCloud 관점에서 짚습니다."
excerpt: "모델을 바꾸지 않고 하네스만 스스로 고쳐서 Terminal-Bench 통과율을 최대 60% 넘게 올렸습니다. 다만 이 루프의 상한은 평가자가 얼마나 까다로워지느냐가 정합니다."
date: 2026-07-25
tags:
  - 에이전트
  - 자가개선
  - 하네스
  - 에이전트 하네스
  - Terminal-Bench
  - 평가자
  - LLM 에이전트
  - 에이전트 루프
  - 프로덕션 에이전트
  - MLOps
categories: [research]
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/ko/research/self-improving-agent-harness/"
---

프로덕션에서 에이전트 하네스를 운영하는 엔지니어라면, 모델을 더 큰 것으로 바꾸지 않고도 통과율을 크게 올릴 여지가 어디에 남아 있는지 늘 궁금하실 겁니다. Self-Harness(arXiv 2606.09498)의 결론부터 말씀드리면, 그 여지는 모델이 아니라 하네스에 있고, 놀랍게도 에이전트가 사람 손 없이 자기 하네스를 스스로 고쳐서 그 여지를 상당 부분 회수할 수 있습니다. 다만 이 자가개선 루프가 어디까지 올라가느냐는 생성기가 아니라 평가자가 얼마나 까다로워지느냐에 달려 있습니다. 이 글은 그 메커니즘과 한계를 정리합니다.

## 왜 읽어야 하나

이 글은 에이전트 하네스를 직접 운영하는 엔지니어, 그리고 자가개선 루프를 설계하려는 플랫폼 담당자를 대상으로 합니다. 여기서 하네스란 모델을 감싸는 시스템 프롬프트, 도구 정의, 라우팅 규칙, 출력 검증 게이트처럼 모델 바깥의 골격 전체를 말합니다. 핵심 결론은 이렇습니다. 에이전트 성능을 끌어올리는 지렛대는 모델 교체만이 아니라 하네스 개선이며, 그 개선을 에이전트가 스스로 반복할 수 있다는 것입니다. 대신 이 루프의 상한은 평가자의 품질이 정합니다. 이 사실을 알면 "성능이 안 나오니 더 큰 모델로 올리자"는 반사적 결정을 미루고, 하네스와 평가자를 먼저 손보는 순서를 갖게 됩니다.

## 개요

지난 2년 동안 에이전트 연구의 무게 중심은 모델 자체에서 모델을 둘러싼 골격으로 옮겨 왔습니다. 같은 모델이라도 시스템 프롬프트를 어떻게 쓰고, 어떤 도구를 주고, 실패를 어떻게 되먹임하느냐에 따라 결과가 크게 달라진다는 것이 반복해서 확인됐기 때문입니다. 그런데 이 하네스를 개선하는 일은 여전히 사람 엔지니어의 몫이었습니다. 실패 사례를 모아 읽고, 프롬프트를 고치고, 도구를 다듬는 지루한 수작업이 계속됐습니다.

Self-Harness는 이 수작업을 에이전트에게 넘깁니다. 사람 엔지니어도, 더 강한 외부 에이전트도 끌어들이지 않고, 에이전트가 자기 자신의 하네스를 스스로 고치도록 만드는 것입니다. 논문이 던지는 질문은 단순합니다. 모델 가중치를 전혀 건드리지 않고 하네스만 반복해서 고치면 성능이 얼마나 올라가는가, 그리고 그 개선은 어디에서 멈추는가.

## 이 연구는 무엇인가

Self-Harness의 뼈대는 세 단계가 맞물려 도는 루프입니다. 약점 발굴(Weakness Mining), 하네스 개선안 제안(Harness Proposal), 개선안 검증(Proposal Validation)입니다.

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
<div class="d3-arch" data-arch-root id="elfimprovingagentharness-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 329, "height": 648, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 24, "y": 24, "w": 135, "h": 94, "title": ["약점 발굴", "Weakness Mining", "실패한 실행에서", "하네스 결함 지점 추출"]}, {"id": "B", "x": 155, "y": 196, "w": 142, "h": 94, "title": ["개선안 제안", "Harness Proposal", "프롬프트·도구·규칙의", "구체적 수정안 생성"]}, {"id": "C", "x": 77, "y": 368, "w": 163, "h": 94, "title": ["개선안 검증", "Proposal Validation", "수정안이 실제로", "통과율을 올리는지 평가"]}, {"id": "D", "x": 39, "y": 554, "w": 120, "h": 62, "title": ["개선된 하네스", "모델 가중치는 그대로"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[159, 114], [226, 157], [226, 157], [226, 196]]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[226, 290], [226, 329], [226, 329], [195, 368]]}, {"src": "C", "dst": "D", "kind": "data", "label": "\"통과: 하네스에 반영\"", "curve": [[159, 462], [159, 508], [159, 508], [123, 554]], "off": "50%"}, {"src": "C", "dst": "A", "kind": "event", "label": "\"미달: 폐기\"", "curve": [[122, 368], [91, 329], [91, 157], [91, 118]], "off": "50%"}, {"src": "D", "dst": "A", "kind": "data", "curve": [[63, 554], [9, 415], [9, 243], [47, 118]]}]});
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
      const container = document.getElementById('elfimprovingagentharness-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'elfimprovingagentharness-1';
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

첫 단계인 약점 발굴은 실패한 실행을 뒤져 하네스의 어느 부분이 문제를 일으켰는지 찾아냅니다. 단순히 "틀렸다"가 아니라, 어떤 파일이나 어떤 절차에서 하네스가 에이전트를 잘못 이끌었는지를 짚는 것이 핵심입니다. 두 번째 단계인 하네스 개선안 제안은 그 약점을 겨냥해 시스템 프롬프트, 도구 정의, 라우팅 규칙을 어떻게 고칠지 구체적인 수정안을 만듭니다. 세 번째 단계인 개선안 검증은 그 수정안이 실제로 통과율을 올리는지 확인합니다. 여기서 통과한 수정안만 하네스에 반영되고, 그러지 못한 수정안은 폐기됩니다.

이 구조에서 중요한 점은 모델 가중치를 전혀 학습시키지 않는다는 것입니다. 개선되는 것은 오직 모델 바깥의 골격뿐입니다. 그래서 이 방법은 가중치를 다시 학습할 여력이 없는 팀도, 폐쇄형 모델을 API로만 쓰는 팀도 그대로 적용해 볼 수 있는 여지를 남깁니다.

## 실제 실험 결과

논문은 Terminal-Bench-2.0이라는 벤치마크 위에서 세 가지 기반 모델로 Self-Harness를 돌렸습니다. 결과를 표로 정리하면 다음과 같습니다.

| 기반 모델 | 개선 전 통과율 | 개선 후 통과율 | 상대 향상 |
|---|---|---|---|
| MiniMax M2.5 | 40.5% | 61.9% | 약 +53% |
| Qwen3.5-35B-A3B | 23.8% | 38.1% | 약 +60% |
| GLM-5 | 42.9% | 57.1% | 약 +33% |

세 모델 모두 가중치를 건드리지 않았는데도 held-out(학습에 쓰지 않은) 문제에서 통과율이 뚜렷하게 올랐습니다. Qwen3.5-35B-A3B의 경우 상대 향상이 약 60%에 이르렀습니다. 절대 수치로 보면 가장 낮았던 모델이 가장 큰 폭으로 개선됐다는 점도 눈에 띕니다. 하네스가 부실할수록 스스로 고칠 여지가 크다는 해석이 가능합니다.

여기서 한 가지 주의할 점을 덧붙입니다. 이 수치들은 논문 초록과 소개에서 확인한 값이며, 저희가 직접 재현한 것은 아닙니다. Terminal-Bench-2.0은 터미널 환경에서 실제 작업을 수행하는 능력을 재는 벤치마크이므로, 같은 하네스 개선 기법이 다른 도메인(예를 들어 문서 생성이나 데이터 분석)에서 같은 폭으로 통할지는 별도로 검증해야 합니다.

## 자가개선 루프의 진짜 병목: 평가자

이 논문에서 가장 곱씹을 대목은 성능 수치가 아니라 그 수치가 어디에서 멈추느냐입니다. 세 번째 단계인 개선안 검증이 곧 이 루프의 평가자 역할을 합니다. 그런데 자가개선 루프는 평가자가 더 까다로워지기를 멈추는 순간 함께 정체하는 경향이 있습니다. 개선안을 통과시키는 기준이 느슨하면, 에이전트는 실제로 더 나아지지 않는 변화를 자꾸 통과시키고, 루프는 겉으로만 도는 상태가 됩니다.

이것은 저희가 사내 규율로 반복해서 강조해 온 지점과 정확히 겹칩니다. 팬아웃한 결과를 합치기 전에 반드시 검증 단계로 닫아야 하고, 그 검증은 생성기와 다른 시각으로 적대적이어야 하며, 품질이 안 나올 때 가장 흔한 원인은 "모델이 약해서"가 아니라 "검증 단계가 없거나 약해서"라는 것입니다. Self-Harness는 이 원칙을 벤치마크 수치로 뒷받침합니다. 즉, 자가개선의 상한을 올리고 싶다면 생성기를 더 크게 만들기 전에 평가자를 더 까다롭게 만들어야 합니다.

## ThakiCloud 제품 적용 시사점

이 논문은 저희 Paxis 관점에서 특히 직접적입니다. Paxis는 ThakiCloud의 Agent-Native Cloud로, Skills와 Tools, Policies, Audit Logs를 일급 리소스로 다루는 제어 평면입니다. 960개가 넘는 스킬을 BM25로 선택해 격리된 샌드박스에서 실행하고, 모든 행동을 정책 게이트와 감사 로그로 통과시킵니다. Self-Harness가 말하는 하네스, 즉 프롬프트와 도구와 라우팅 규칙의 집합이 바로 Paxis의 스킬 하네스에 해당합니다.

Self-Harness의 3단계 루프는 Paxis의 자가진화 스킬 계층에 자연스럽게 대응됩니다. 실패한 실행 기록에서 약점을 뽑아내는 약점 발굴은 저희 스킬 회고와 채굴 루틴이 맡고, 하네스 개선안 제안은 스킬과 규칙을 고치는 진화 단계에, 개선안 검증은 결정론적 게이트와 적대적 표결에 대응합니다. 논문이 강조한 "평가자가 병목"이라는 결론은 저희가 게이트를 코드로 소유하고, 검증 단계를 생성기와 분리하며, 평가자가 실제로 무언가를 기각하지 않으면 그 평가자를 고장으로 간주하는 규율과 맞닿아 있습니다.

인프라 관점에서 보면 ai-platform 렌즈도 함께 작동합니다. 하네스만 고쳐서 성능을 올린다는 것은 값비싼 재학습 없이 추론 단계의 골격만 바꿔 개선한다는 뜻입니다. K8s 기반 멀티테넌트 서빙 환경에서 이런 방식은 GPU 재학습 비용을 들이지 않고도 고객별 하네스를 반복 개선할 수 있는 경로를 열어 줍니다. 저비용 서빙이 에이전트 경제성을 만들고, 그 위에서 하네스 자가개선이 품질을 끌어올리는 구조입니다.

## 한계 및 반론

Self-Harness에도 분명한 한계가 있습니다. 첫째, 이 방법의 상한은 결국 평가자의 품질에 묶여 있습니다. 검증 단계가 실제 성능을 제대로 가르지 못하면 루프는 정체하거나, 더 나쁘게는 벤치마크 특정 패턴에만 과적합할 수 있습니다. 둘째, Terminal-Bench-2.0이라는 특정 벤치마크에서 나온 수치이므로, 다른 과제 분포에서 같은 폭의 향상이 재현될지는 확인되지 않았습니다. 셋째, 하네스가 스스로 커지고 복잡해지면서 통제하기 어려운 방향으로 자라날 위험도 있습니다. 사람의 검토 없이 하네스가 무한히 자기 자신을 고치도록 두면, 어느 순간 왜 그렇게 동작하는지 아무도 설명하지 못하는 상태에 이를 수 있습니다.

그래서 이 기법을 실제 시스템에 넣을 때는 자가개선을 완전 자율로 풀어 두기보다, 사람이 주기적으로 표본을 검토하고 평가자 자체를 계속 강화하는 안전장치를 함께 두는 편이 현실적입니다. 자동화는 사고를 대체하는 것이 아니라 보조하는 도구라는 원칙이 여기서도 그대로 적용됩니다.

## 정리

Self-Harness가 주는 실무 교훈을 한 문장으로 줄이면 이렇습니다. 에이전트 성능이 벽에 부딪혔을 때 가장 먼저 손댈 곳은 더 큰 모델이 아니라 하네스와 그 하네스를 채점하는 평가자입니다. 모델 가중치를 전혀 건드리지 않고도 통과율을 최대 60% 넘게 올렸다는 결과는, 아직 회수하지 못한 성능이 골격 안에 상당히 남아 있음을 보여 줍니다. 다만 그 회수의 상한은 평가자가 정합니다. 여러분이 자가개선 루프를 운영하고 계신다면, 다음 스프린트에는 생성기보다 평가자를 먼저 더 까다롭게 만들어 보시길 권합니다. 그것이 이 논문이 수치로 증명한 가장 확실한 지렛대입니다.

## 출처

- Self-Harness: Harnesses That Improve Themselves, arXiv 2606.09498 (<https://arxiv.org/abs/2606.09498>)
