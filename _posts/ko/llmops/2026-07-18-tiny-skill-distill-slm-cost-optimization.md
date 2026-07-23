---
title: "AI 운영비는 '반복 작업'에서 새어나갑니다: 온프레미스 전용 모델로 구조적으로 줄이는 방법"
excerpt: "AI 에이전트 비용의 대부분은 똑똑한 판단이 아니라 단순하고 반복적인 처리에서 발생합니다. 그 반복 작업만 작은 전용 모델로 떼어내 온프레미스에서 운영하면 호출당 비용이 크게 내려가고 데이터도 외부로 나가지 않습니다. 다키클라우드가 이 패턴을 직접 측정하고 전 과정을 공개했습니다."
date: 2026-07-18
tags:
  - AI비용절감
  - 온프레미스
  - SLM
  - 파인튜닝
  - 데이터주권
  - LLMOps
  - 엔터프라이즈AI
  - 플랫폼
author_profile: true
toc: true
toc_label: 비용 절감 실측
published: true
categories:
  - llmops
  - dev
canonical_url: "https://thakicloud.com/tech-blog/ko/llmops/tiny-skill-distill-slm-cost-optimization/"
---

## 결론부터 말씀드립니다

AI 도입 비용의 상당 부분은 모델이 똑똑한 판단을 하기 때문에 발생하는 것이 아닙니다. 같은 판정을 하루에 수천, 수만 번 반복하는 단순 작업에서 발생합니다. "이 요청이 안전한가", "이 문서는 어느 범주인가", "이 문장의 어투는 적절한가"와 같은 판정입니다. 이 반복 작업에까지 매번 최상위 외부 모델을 호출하면, 비용은 호출량에 비례해 늘어나고 민감한 데이터는 매번 외부로 나가게 됩니다.

다키클라우드의 제안은 단순합니다. 이 반복 작업만 작은 전용 모델로 떼어내 고객사의 자체 인프라, 곧 온프레미스에서 운영하고, 값비싼 최상위 모델은 정말 판단이 필요한 소수의 업무에만 사용하는 것입니다. 저희는 이 방식이 실제로 통하는지를 예측이 아니라 측정으로 확인했으며, 그 과정을 전부 공개했습니다. 이 글은 그 비용 이야기를 의사결정권자의 관점에서 정리한 것입니다.

## 왜 지금 이 이야기가 중요한가

생성형 AI를 실무에 도입하기 시작하면 세 가지가 동시에 커집니다. 비용은 호출량을 따라 선형으로 늘어나고, 데이터 노출은 외부 API를 호출할 때마다 발생하며, 특정 외부 모델 공급자에 대한 종속성은 점점 깊어집니다. 세 가지 모두 경영진이 통제하고자 하는 리스크입니다.

핵심은 다음과 같습니다. 여러분의 AI가 수행하는 일을 살펴보면 대부분은 좁고 반복적인 판정이며, 진짜 창의적 판단은 소수입니다. 그런데 현재는 이 둘을 구분하지 않고 전부 같은 최상위 모델에 맡기고 있습니다. 단순한 서류 분류까지 가장 높은 연봉의 전문가에게 맡기는 것과 다르지 않습니다.

## 다키클라우드의 접근: 반복 작업을 전용 모델로, 온프레미스로

방법은 세 단계입니다. 첫째, 업무 흐름은 최상위 모델로 설계합니다. 둘째, 규칙으로 굳힐 수 있는 부분은 코드로 고정합니다. 셋째, 언어모델이 실제로 필요한 좁은 반복 판정만 작은 모델(파라미터 10억 개 이하, 4비트)로 특화 학습하여 연결합니다. 그러면 그 작업은 흔한 온프레미스 GPU 한 장에서 처리되고, 최상위 모델은 정말 중요한 판단에만 투입됩니다.

다키클라우드 플랫폼은 바로 이 워크플로를 제품으로 제공합니다. 작은 전용 모델을 관리형으로 파인튜닝하고(고객사가 GPU 인프라를 직접 다룰 필요가 없습니다), 그 결과를 고객사의 온프레미스 환경에서 서빙합니다. 이 글의 실험은 그 패턴이 작동한다는 증거이며, 플랫폼은 그 패턴을 반복 가능하고 운영 가능한 형태로 만들어 드립니다.

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
<div class="d3-arch" data-arch-root id="stillslmcostoptimization-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 719, "height": 948, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [{"x": 421, "y": 24, "w": 266, "h": 410, "label": "Build pipeline", "lx": 433, "ly": 42}], "nodes": [{"id": "A", "x": 132, "y": 203, "w": 170, "h": 46, "title": "AI workflow requests"}, {"id": "B", "x": 133, "y": 327, "w": 167, "h": 68, "title": ["Repetitive narrow", "judgment?"]}, {"id": "C", "x": 367, "y": 526, "w": 212, "h": 78, "title": ["Small specialized SLM", "under 1B params, 4-bit", "~5MB LoRA adapter per task"]}, {"id": "D", "x": 24, "y": 534, "w": 191, "h": 62, "title": ["Top-tier external model", "reserved for the few"]}, {"id": "E", "x": 381, "y": 682, "w": 184, "h": 78, "title": ["On-prem GPU", "data never leaves your", "walls"]}, {"id": "F", "x": 367, "y": 838, "w": 212, "h": 78, "title": ["~3.6x cheaper per 1k calls", "tone accuracy 38.6% to", "99.1%"]}, {"id": "G", "x": 35, "y": 690, "w": 170, "h": 62, "title": ["Higher per-call cost", "used sparingly"]}, {"id": "H", "x": 458, "y": 63, "w": 191, "h": 62, "title": ["1. Design flow with top", "model"]}, {"id": "I", "x": 458, "y": 203, "w": 191, "h": 46, "title": "2. Freeze rules as code"}, {"id": "J", "x": 462, "y": 330, "w": 184, "h": 62, "title": ["3. Fine-tune small SLM", "for narrow judgments"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [217, 249, 217, 327]}, {"src": "B", "dst": "C", "kind": "data", "label": "Yes: safety check, doc class, tone check", "curve": [[276, 395], [345, 434], [345, 480], [414, 526]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "No: genuine judgment", "curve": [[171, 395], [120, 434], [120, 480], [120, 534]], "off": "50%"}, {"src": "C", "dst": "E", "kind": "data", "line": [473, 604, 473, 682]}, {"src": "E", "dst": "F", "kind": "data", "line": [473, 760, 473, 838]}, {"src": "D", "dst": "G", "kind": "data", "line": [120, 596, 120, 690]}, {"src": "H", "dst": "I", "kind": "data", "line": [554, 125, 554, 203]}, {"src": "I", "dst": "J", "kind": "data", "line": [554, 249, 554, 330]}, {"src": "J", "dst": "C", "kind": "event", "label": "provisions", "curve": [[554, 392], [554, 434], [554, 480], [510, 526]], "off": "50%"}]});
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
      const container = document.getElementById('stillslmcostoptimization-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'stillslmcostoptimization-1';
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
*반복적이고 좁은 판정은 온프레미스의 작은 전용 모델로 보내 호출당 비용을 낮추고 데이터를 내부에 두며, 진짜 판단이 필요한 소수 업무만 최상위 모델에 맡깁니다. 전용 모델은 작업당 약 5메가바이트 부착 파일로 만들어져 하나의 기본 모델 위에 여러 작업을 바꿔 끼울 수 있습니다.*

## 실측: 무엇을 확인했는가

과장을 피하기 위해 모든 수치를 직접 측정하고 공개했습니다. 실험 환경은 GPU 한 장이며, 학습과 추론 어느 단계에서도 외부 API를 호출하지 않았습니다. 즉 전 과정이 자체 인프라 안에서 완결됩니다. 이것이 데이터 주권의 실체입니다.

비용 측면입니다. 온프레미스에서 이 작은 전용 모델이 처리하는 1천 건당 비용은 최상위 외부 API 대비 약 3.6배 저렴했습니다. 이 수치는 단일 처리 기준이므로, 실제 운영처럼 묶어서 처리하면 격차는 더 벌어집니다.

품질 측면입니다. 좁은 반복 판정에서 작은 모델은 크게 향상되었습니다. 예를 들어 한국어 어투 판정은 학습 전 38.6퍼센트에서 학습 후 99.1퍼센트로, 뉴스 범주 분류는 거의 무작위 수준에서 80퍼센트 이상으로 올랐습니다. 학습에 사용하지 않은 실제 문장으로 다시 검증했을 때에도 안전 판정에서 88퍼센트, 범주 분류에서 89퍼센트 수준의 일치도를 보였습니다.

경제성 측면입니다. 이 전용 모델은 각 작업마다 약 5메가바이트의 작은 부착 파일로 만들어집니다. 전체 모델을 통째로 다시 학습하는 방식과 품질은 거의 같으면서(99.1퍼센트 대 96.9퍼센트) 크기는 약 300분의 1이며, 하나의 기본 모델 위에 여러 작업을 바꿔 끼울 수 있습니다. 하나의 작은 모델이 네 가지 반복 작업을 동시에 감당하기도 했습니다. 운영 관점에서 이는 적은 하드웨어로 더 많은 업무를 처리한다는 뜻으로 직결됩니다.

## 정직하게 남기는 한계

한 가지는 분명히 말씀드립니다. 최상위 모델이 이미 잘 처리하던 일반적인 작업에 성급하게 전용 학습을 적용했더니 오히려 성능이 떨어진 경우가 있었습니다. 즉 이 방식은 아무 작업에나 적용하는 것이 아니라, 반복적이고 좁은 작업을 선별하여 적용해야 효과가 납니다. 어디에 적용하고 어디에는 적용하지 않아야 하는지를 판단하는 일, 바로 그 지점에서 플랫폼과 전문성이 필요합니다. 저희는 좋은 결과와 좋지 않은 결과를 함께 공개합니다.

## 의사결정권자를 위한 요약

첫째, AI 운영비의 상당 부분은 반복 작업에서 새어나가고 있으며, 이 부분은 구조적으로 줄일 수 있습니다. 둘째, 그 방법은 반복 작업을 작은 전용 모델로 떼어내 온프레미스에서 운영하는 것이며, 이는 비용 절감과 데이터 주권을 동시에 확보해 줍니다. 셋째, 다키클라우드 플랫폼은 이 과정을 관리형으로 제공하여, 고객사가 GPU 인프라와 모델 학습의 복잡성을 직접 떠안지 않고도 도입하실 수 있게 합니다.

전체 실험 코드와 측정 결과는 누구나 재현할 수 있도록 공개해 두었습니다: [github.com/sylvanus4/tiny-skill-distill](https://github.com/sylvanus4/tiny-skill-distill). 여러분의 AI 워크로드 가운데 어느 부분을 전용 모델로 옮기면 비용이 얼마나 내려갈지, 저희가 함께 진단해 드리겠습니다.
