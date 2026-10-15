---
title: "27B 모델 하나로 답변 생성과 근거 판단을 같이 돌렸습니다: 마지막 4개 층만 갈라지는 공유 백본"
seo_title: "공유 백본 서빙: vLLM 한 엔진에서 27B 생성과 RAG 근거 판단 Gate를 함께 실행 - ThakiCloud"
seo_description: "Qwen3.8-27B를 GPU에 한 번만 올리고 답변 생성과 RAG 근거 판단을 같은 vLLM 엔진에서 처리했습니다. 0~43층은 공유하고 판단 요청만 44~47층에서 갈라집니다. 생성 결과는 원본 vLLM의 반복 실행 차이 수준을 유지했고 판단 256건은 전용 엔진과 한 건도 다르지 않았습니다."
excerpt: "답변을 쓰는 모델과 답해도 되는지 판단하는 모델이 사실상 같은 27B라면 두 번 올릴 이유가 없습니다. 같은 엔진 안에서 마지막 네 층만 갈라지게 만들었고 그 과정에서 중간값을 '읽기만 해도' 결과가 바뀌는 문제를 만났습니다."
date: 2026-10-15
last_modified_at: 2026-10-15
tags:
  - rag
  - evidence-sufficiency
  - vllm
  - shared-backbone
  - lora
  - llm-serving
  - torch-compile
  - qwen
  - paxis
  - metis
categories:
  - research
author_profile: true
toc: true
toc_label: "목차"
canonical_url: "https://thakicloud.com/tech-blog/ko/research/shared-backbone-evidence-gate-27b/"
---

검색 기반 에이전트를 운영하면 큰 모델이 두 번 필요해 보입니다. 하나는 답을 쓰고 다른 하나는 찾은 문서만으로 답해도 되는지 판단합니다. 저희 판단 모델은 원본 27B 모델의 앞쪽 44개 층을 그대로 쓰기 때문에, 두 모델을 따로 올리면 같은 계산을 두 번 하는 셈입니다.

그래서 27B 모델을 한 번만 올리고 같은 서빙 엔진에서 두 일을 함께 처리했습니다. 답변 생성은 원본 엔진을 반복 실행할 때 생기는 차이 이상으로 흔들리지 않았고 근거 판단 256건은 전용 판단 엔진과 하나도 다르지 않았습니다. 사내 모델 서빙 비용을 고민하는 분, 그리고 서빙 엔진에 기능을 덧붙이다 결과가 미묘하게 달라진 경험이 있는 분께 이 글을 권합니다.

![27B 모델 하나로 답변 생성과 근거 판단을 같이 돌렸습니다: 마지막 4개 층만 갈라지는 공유 백본 개념을 형상화한 이미지](/assets/images/shared-backbone-evidence-gate-27b-hero.webp)
*글의 핵심 개념을 형상화했습니다.*

## 쉽게 말하면

식당 주방을 떠올려 보겠습니다. 손님 주문이 두 종류 들어옵니다. 하나는 요리를 내 달라는 주문이고 다른 하나는 이 재료로 요리를 내도 되는지 검수해 달라는 주문입니다.

두 주문의 재료 손질은 거의 같습니다. 씻고 썰고 밑간을 하는 과정이 똑같습니다. 다른 것은 마지막 조리대에서 무엇을 하느냐뿐입니다. 그런데 지금까지는 손질 담당을 두 팀 두고 같은 일을 두 번 시켰습니다.

저희가 바꾼 것은 손질을 한 팀에 맡기고 검수 주문만 마지막 조리대 직전에 옆 조리대로 넘기는 구조입니다. 조건은 하나입니다. 요리 주문의 맛이 예전과 같아야 합니다. 같은 요리사가 같은 레시피로 두 번 만들 때 생기는 소금 한 알 정도의 차이는 허용하지만 그 이상 달라지면 안 됩니다.

<!-- nlm-visual -->
![핵심 개념 요약 인포그래픽 1](/assets/images/posts/news/shared-backbone-evidence-gate-27b/nlm-infographic-1.webp)
*NotebookLM이 소스를 종합해 생성한 인포그래픽입니다.*

## 무엇을 해봤나

### 갈라지는 지점

기반 모델은 Qwen3.8-27B이고 서빙 엔진은 vLLM 0.28.0입니다. 근거 판단 모델은 이전 글에서 소개한 판정표로, 원본 0~43층을 그대로 쓰고 44~47층에만 작은 LoRA를 붙였습니다. 그러니 0~43층 계산은 생성과 판단이 완전히 같습니다.

{% raw %}
<!--
  animated-architecture-diagram - self-contained D3 embed template.
  HuggingFace research-article style: declarative NODES/EDGES/SEQ model,
  data(solid)/event(dashed) edges, hover-trace + tooltip, flow-dot animation
  along edge paths, replay button, scroll-into-view autoplay, reduced-motion +
  light/dark aware. The renderer injects window.__ARCH_SPEC__ at the marker.
  Format (D3 machinery + CSS) is owned by this committed template; the model
  only authors the JSON spec (content). See references/spec-schema.md.
-->
<div class="d3-arch" data-arch-root id="dbackboneevidencegate27b-1"></div>
<style>
  /* ---- Theme tokens (standalone; light default + dark override) ---- */
  .d3-arch {
    --page-bg: #ffffff;
    --surface-bg: #f7f8fa;
    --text-color: #1a1d21;
    --muted-color: #6b7280;
    --border-color: #d5d9e0;
    --primary-color: hsl(217 91% 55%); /* brand accent, swap for #1B4F72 etc. */
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 353, "height": 660, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 101, "y": 24, "w": 142, "h": 46, "title": "요청 (질문 + 검색한 문서)"}, {"id": "B", "x": 112, "y": 148, "w": 121, "h": 62, "title": ["0~43층", "생성과 판단이 함께 계산"]}, {"id": "C", "x": 200, "y": 302, "w": 121, "h": 62, "title": ["44~63층 원본 그대로", "답변 토큰 생성"]}, {"id": "D", "x": 25, "y": 310, "w": 120, "h": 46, "title": "44층 중간값 복사"}, {"id": "E", "x": 24, "y": 442, "w": 121, "h": 62, "title": ["44~47층 + LoRA", "(판단 전용 가지)"]}, {"id": "F", "x": 24, "y": 582, "w": 121, "h": 46, "title": "답변 / 재검색 / 중단"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [172, 70, 172, 148]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[208, 210], [260, 256], [260, 256], [260, 302]]}, {"src": "B", "dst": "D", "kind": "data", "label": "\"판단 요청만\"", "curve": [[137, 210], [85, 256], [85, 256], [85, 310]], "off": "50%"}, {"src": "D", "dst": "E", "kind": "data", "line": [85, 356, 85, 442]}, {"src": "E", "dst": "F", "kind": "data", "line": [85, 504, 85, 582]}]});
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
      const container = document.getElementById('dbackboneevidencegate27b-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'dbackboneevidencegate27b-1';
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
*판단 요청은 44층 입구에서 중간값을 복사해 옆 가지로 갑니다. 생성 요청은 원본 경로를 그대로 지나갑니다. GPU 1장에 27B 가중치는 한 번만 올라갑니다.*

엔진은 하나이고 요청이 한 묶음으로 섞여 들어옵니다. 판단 요청은 정해진 문장 형식으로 끝나므로 엔진이 이를 보고 가지로 보냅니다. 판단 결과는 세 행동의 점수로 돌아오고 기존 판정표와 같은 문턱값으로 행동을 고릅니다.

### 판정 규칙을 먼저 정했습니다

결과를 보기 전에 판정 규칙을 문서로 고정했습니다. 생성 요청 64개를 원본 엔진과 공유 엔진에서 각각 돌리고 토큰이 하나라도 다르게 나온 요청 수를 셉니다. 이것을 원본 엔진을 두 번 돌렸을 때의 차이와 비교합니다. 공유 엔진의 차이가 원본의 반복 차이보다 많지 않아야 통과입니다.

처음에는 원본과 토큰 하나까지 똑같아야 통과로 하려 했습니다. 그런데 원본 엔진도 같은 입력을 두 번 넣으면 어떤 날은 0건, 어떤 날은 1건이 달랐습니다. 원본조차 못 지키는 기준으로는 판정할 수 없으므로, 그 기준은 판정 불능으로 남기고 반복 차이를 기준선으로 삼았습니다.

판단 요청을 섞었을 때 생성이 흔들리는지도 따로 봤습니다. 가지가 없는 엔진에서도 요청을 섞으면 묶음 구성이 달라져 차이가 생깁니다. 그래서 가지가 없는 엔진의 차이를 기준선으로 두고 그보다 더 흔들리는지만 봤습니다.

## 나온 결과

### 두 번 실패하고 세 번째에 통과했습니다

같은 규칙으로 세 번 판정했고 앞의 두 번은 실패했습니다. 실패 결과도 원장에 그대로 남겼습니다.

![시도별로 원본 엔진과 달라진 생성 요청 수. 1차 14건, 2차 11건, 3차 1건이며 3차 실행의 원본 반복 차이도 1건입니다](/assets/images/shared-backbone-evidence-gate-27b-fig-01.webp)
*회색은 같은 실행에서 원본 엔진을 두 번 돌렸을 때의 차이, 색 막대는 공유 엔진과 원본의 차이입니다. 64개 생성 요청 기준, H200 1장, vLLM 0.28.0.*

1차에서는 44층 중간값을 엔진이 원래 제공하는 방식으로 꺼냈습니다. 원본 반복 차이는 0건인데 공유 엔진은 14건이 달랐습니다. 2차에서는 중간값을 별도 버퍼에 복사하는 방식으로 바꿨지만 11건이었습니다.

원인을 나눠 보려고 진단 실행을 따로 했습니다. 가지를 끈 채 같은 코드로 돌리면 원본과 다른 요청이 한 건도 없었습니다. 반면 중간값을 꺼내기만 하고 가지 계산은 하지 않아도 13건이 달랐습니다. 가지 계산이 아니라 중간값을 읽는 행위 자체가 생성을 흔들었습니다.

유력한 설명은 컴파일러입니다. vLLM은 여러 연산을 하나로 묶어 빠르게 실행합니다. 그 한가운데에서 값을 꺼내면 묶는 방식이 달라지고 bf16 반올림이 일어나는 지점도 바뀝니다. 다만 커널이 실제로 어떻게 묶였는지 직접 확인하지는 않았으므로 아직은 가설입니다.

3차에서는 꺼내는 지점을 옮겼습니다. 44층 정규화 연산의 입력은 원래도 메모리에 따로 만들어지는 값이라, 거기서 복사하면 묶음을 건드리지 않을 것이라고 봤습니다. 정규화는 가지 쪽에서 다시 계산합니다. 결과는 64건 중 1건이었고 같은 실행에서 원본 반복 차이도 1건이었습니다. 두 1건은 같은 요청의 같은 22번째 토큰이었습니다.

즉, 사람 말로는 공유 엔진이 원본 엔진과 다른 정도가 원본 엔진이 자기 자신과 다른 정도와 같아졌습니다.

### 판단은 전용 엔진과 같았습니다

![왼쪽은 판단 256건 중 뒤집힌 수, 오른쪽은 KV 캐시 블록 수](/assets/images/shared-backbone-evidence-gate-27b-fig-02.webp)
*판단 비교 기준은 전용 판단 엔진, HF fp32, 그리고 참고용 HF bf16과 HF fp32의 차이입니다. KV 블록은 같은 메모리 설정(0.85)에서 엔진이 잡은 수입니다.*

판단 요청 256건을 공유 엔진에 넣고 기존 전용 판단 엔진과 비교했습니다. 행동이 뒤집힌 경우는 0건이었고 확률 차이는 최대 0.02였습니다. 32비트 기준 구현과 비교하면 1건이 뒤집혔는데 16비트 구현끼리 비교해도 5건이 뒤집히는 수준이라 수치 정밀도 범위 안입니다.

판단 요청을 섞었을 때 생성이 흔들리는 정도도 기준선 안이었습니다. 가지가 있는 엔진은 64건 중 2건, 가지가 없는 엔진은 3건이 달라졌습니다.

### 대가는 KV 캐시입니다

공짜는 아니었습니다. 같은 메모리 설정에서 KV 캐시 블록이 1,354개에서 1,216개로 10.2% 줄었습니다. 가지용 층과 복사 버퍼가 자리를 차지하기 때문입니다. 동시에 처리할 수 있는 긴 대화 수가 그만큼 줄어든다는 뜻입니다.

## 그래서 무엇을 바꾸면 되나

판단 모델이 원본의 앞부분을 그대로 쓴다면 별도 엔진을 띄우기 전에 한 엔진 안의 가지로 만들 수 있는지 먼저 보시기 바랍니다. 같은 가중치를 두 번 올리지 않아도 되고 판단 요청이 없을 때 판단용 엔진이 놀고 있는 일도 없습니다.

서빙 엔진 안에서 중간값을 꺼내는 기능을 만든다면 꺼내는 지점부터 신중히 고르셔야 합니다. 같은 값이라도 컴파일된 연산 묶음의 한가운데에서 읽으면 결과가 바뀔 수 있습니다. 저희 경우 정규화 연산의 입력처럼 원래 따로 만들어지는 값에서 읽자 문제가 사라졌습니다.

검증 기준은 원본 엔진의 반복 차이로 잡는 편이 현실적입니다. 토큰 하나까지 같아야 한다는 기준은 깔끔해 보이지만 원본도 지키지 못하면 아무것도 판정할 수 없습니다. 그리고 그 기준선은 실행마다 0건이기도 1건이기도 하므로 같은 실행 안에서 함께 재야 합니다.

ThakiCloud에서는 이 구조를 Paxis 에이전트가 검색 결과로 답할지 정하는 단계에 쓰려고 합니다. Metis 추론 엔드포인트 하나에서 답변과 판단을 함께 처리하면 에이전트 한 단계마다 GPU를 하나 더 붙이지 않아도 됩니다.

<!-- nlm-visual -->
![핵심 개념 요약 인포그래픽 2](/assets/images/posts/news/shared-backbone-evidence-gate-27b/nlm-infographic-2.webp)
*NotebookLM이 소스를 종합해 생성한 인포그래픽입니다.*

## 못 믿을 부분

먼저 이번 검증은 기능 검증입니다. 같은 엔진에서 둘 다 처리된다는 것과 결과가 유지된다는 것을 확인했을 뿐입니다. 처리량, 지연, GPU 비용 절감은 재지 않았습니다. 장시간 운영과 최대 메모리 사용량도 확인하지 않았습니다.

둘째, 범위가 좁습니다. 생성 요청은 64개, 판단 요청은 256개였고 GPU 1장에서 한 가지 설정으로만 돌렸습니다. 판단 모델은 공개한 네 시드 중 한 시드만 검증했습니다.

셋째, 토큰 단위 완전 일치는 판정 불능입니다. 원본 엔진도 반복 실행에서 1건이 달랐기 때문에, 공유 엔진이 원본과 비트 단위로 같은지는 이 환경에서 말할 수 없습니다. 실패 원인으로 든 컴파일러 설명도 직접 확인한 것이 아니라 가장 그럴듯한 설명입니다.

넷째, 아직 서비스 형태가 아닙니다. 생성과 판단을 HTTP API 두 개로 열고 재시작 뒤 복구까지 확인하는 배포 검증은 진행 중입니다. 서빙 코드와 통합 패키지도 그 검증이 끝난 뒤 공개할 예정이며 판단 모델 가중치는 [Hugging Face의 ECP-Q12-27B-Research-Preview](https://huggingface.co/ThakiCloud/ECP-Q12-27B-Research-Preview)에 있습니다.

*이 글의 수치는 저희 H200 GPU에서 실제로 잰 값이며 연구 원장에 기록된 결과만 인용했습니다.*
