---
title: "집에서 도는 지능: Personal AI Computer와 온프렘 서빙의 경제학"
excerpt: "tom_doerr가 공유한 최대 384GB VRAM Personal AI Computer 빌드 가이드를 출발점으로, VRAM이 어떻게 실행 가능한 모델을 결정하는지 계산으로 따져보고, 이 개인용 한 대를 조직 규모의 온프렘 서빙으로 올릴 때 무엇이 필요한지 ThakiCloud ai-platform 관점에서 정리합니다."
tags:
  - on-premise
  - vram
  - gpu
  - self-hosting
  - vllm
  - open-weights
date: 2026-07-04
lang: ko
canonical_url: "https://thakicloud.com/tech-blog/ko/llmops/personal-ai-computer-onprem-vram/"
categories:
  - llmops
---

지난 며칠 사이 개발자 타임라인에서 조용히 화제가 된 프로젝트가 있습니다. "Personal AI Computer", 즉 클라우드 API를 빌리는 대신 집이나 사무실에 직접 AI 컴퓨터를 조립해 오픈웨이트 모델을 온전히 내 손으로 돌리는 빌드 가이드입니다. 최대 384GB VRAM 구성까지 정리되어 있어서, "그 정도면 어떤 모델까지 로컬에서 돌아가는가"라는 실무적인 질문이 자연스럽게 따라옵니다. 이 글은 온프레미스 AI 인프라를 검토하는 엔지니어링 리더와 ML 플랫폼 팀, 그리고 로컬에서 모델을 굴려보려는 데이터 과학자를 위한 것입니다. VRAM이 실행 가능한 모델을 어떻게 결정하는지 계산으로 확인하고, 개인용 한 대를 조직 규모의 서빙으로 확장할 때 무엇이 달라지는지를 ThakiCloud의 ai-platform 관점과 함께 다룹니다.

결론부터 말씀드리면 이렇습니다. 로컬 AI의 실행 가능성은 대부분 VRAM 한 가지 변수로 결정됩니다. 그리고 개인용 빌드가 증명하는 것은 "기술적으로 가능하다"는 사실이지, "조직이 그대로 운영할 수 있다"는 뜻은 아닙니다. 그 간극이 정확히 온프렘 서빙 플랫폼이 존재하는 이유입니다.

## 이 기술은 무엇인가

화제의 중심에 있는 저장소는 `autonomous-ai/autonomous-computer`입니다. MIT 라이선스로 공개된, 집에서 AI 컴퓨터를 처음부터 조립하는 오픈소스 가이드입니다. 특징은 "글로만 설명하지 않는다"는 점입니다. 각 빌드는 가격과 구매 링크가 붙은 부품 명세(BOM), 섀시를 직접 출력하거나 가공할 수 있는 3D 파일(STL과 STEP), 배선도, BIOS 튜닝 값, 그리고 조립 과정을 담은 단계별 사진으로 구성됩니다. 소프트웨어 쪽도 운영체제와 NVIDIA 드라이버 설치부터 추론 엔진 세 가지(Ollama, vLLM, llama.cpp), 마지막으로 로컬 에이전트를 붙이는 단계까지 이어집니다.

제시되는 구성은 세 가지입니다.

- **Home**: RTX 5090 2장, VRAM 합계 64GB
- **Business**: GPU 8장 구성, VRAM 합계 약 256GB
- **Team**: RTX PRO 6000 Blackwell 4장, VRAM 합계 384GB

프로젝트가 반복해서 강조하는 철학은 "Own your intelligence", 즉 지능을 소유하라는 것입니다. 클라우드에서 빌린 모델은 어느 날 밤 정책이 바뀌거나 서비스가 종료되면 사라질 수 있지만, 내 집에서 도는 모델은 그렇지 않다는 논리입니다. 데이터 주권과 통제권을 하드웨어 수준에서 확보하겠다는 관점이며, 온프렘 수요가 커지는 흐름과 정확히 맞닿아 있습니다.

전체 흐름을 정리하면 다음과 같습니다.

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
<div class="d3-arch" data-arch-root id="onalaicomputeronpremvram-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 541, "height": 896, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 214, "y": 24, "w": 120, "h": 46, "title": "예산과 목표 모델 결정"}, {"id": "B", "x": 214, "y": 148, "w": 120, "h": 46, "title": "VRAM 예산 산정"}, {"id": "C", "x": 205, "y": 272, "w": 138, "h": 52, "title": "어느 빌드 구성인가"}, {"id": "D", "x": 389, "y": 416, "w": 120, "h": 62, "title": ["Home", "RTX 5090 2장"]}, {"id": "E", "x": 214, "y": 416, "w": 120, "h": 62, "title": ["Business", "GPU 8장"]}, {"id": "F", "x": 24, "y": 416, "w": 135, "h": 62, "title": ["Team", "RTX PRO 6000 4장"]}, {"id": "G", "x": 214, "y": 556, "w": 120, "h": 46, "title": "추론 엔진 선택"}, {"id": "H", "x": 289, "y": 694, "w": 156, "h": 46, "title": "Ollama / llama.cpp"}, {"id": "I", "x": 114, "y": 694, "w": 120, "h": 46, "title": "vLLM"}, {"id": "J", "x": 214, "y": 818, "w": 120, "h": 46, "title": "로컬 에이전트 연결"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [274, 70, 274, 148]}, {"src": "B", "dst": "C", "kind": "data", "line": [274, 194, 274, 272]}, {"src": "C", "dst": "D", "kind": "data", "label": "64GB", "curve": [[337, 324], [449, 370], [449, 370], [449, 416]], "off": "50%"}, {"src": "C", "dst": "E", "kind": "data", "label": "256GB", "line": [274, 324, 274, 416], "lx": 274, "ly": 366}, {"src": "C", "dst": "F", "kind": "data", "label": "384GB", "curve": [[208, 324], [92, 370], [92, 370], [92, 416]], "off": "50%"}, {"src": "D", "dst": "G", "kind": "data", "curve": [[449, 478], [449, 517], [449, 517], [334, 558]]}, {"src": "E", "dst": "G", "kind": "data", "line": [274, 478, 274, 556]}, {"src": "F", "dst": "G", "kind": "data", "curve": [[92, 478], [92, 517], [92, 517], [214, 559]]}, {"src": "G", "dst": "H", "kind": "data", "label": "단순 로컬 실행", "curve": [[305, 602], [367, 648], [367, 648], [367, 694]], "off": "50%"}, {"src": "G", "dst": "I", "kind": "data", "label": "고처리량 서빙", "curve": [[241, 602], [174, 648], [174, 648], [174, 694]], "off": "50%"}, {"src": "H", "dst": "J", "kind": "data", "curve": [[367, 740], [367, 779], [367, 779], [308, 818]]}, {"src": "I", "dst": "J", "kind": "data", "curve": [[174, 740], [174, 779], [174, 779], [237, 818]]}]});
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
      const container = document.getElementById('onalaicomputeronpremvram-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'onalaicomputeronpremvram-1';
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

## VRAM이 실행 가능성을 결정한다

로컬에서 어떤 모델이 도는지는 사실상 VRAM 하나로 판가름 납니다. 커뮤니티에서 굳어진 어림 공식은 명료합니다. FP16(반정밀도)에서는 파라미터 10억 개당 약 2GB, INT4 계열 양자화(Q4)에서는 약 0.5GB가 필요하고, 여기에 KV 캐시와 활성화, 프레임워크 오버헤드로 15~20%를 더 얹습니다. 즉 Q4 기준으로 대략 "파라미터 수(B) × 0.5 × 1.2"가 최소 VRAM입니다.

이 공식을 대표 모델 크기에 적용하면 아래 표가 됩니다. 오버헤드 20%를 포함한 계산값입니다.

| 모델 규모 | Q4 필요 VRAM | Q8 필요 VRAM |
|---|---|---|
| 8B | 5GB | 10GB |
| 32B | 19GB | 38GB |
| 70B | 42GB | 84GB |
| 122B | 73GB | 146GB |
| 235B | 141GB | 282GB |
| 405B | 243GB | 486GB |

이 계산은 임의로 지어낸 수치가 아니라 공개된 가이드들과 교차 검증됩니다. 예를 들어 Llama 3 70B를 Q4_K_M으로 돌릴 때 실측 요구량은 약 40~43GB로 보고되는데, 위 계산값 42GB와 일치합니다. Qwen 3.5 122B급은 Q4에서 70~81GB가 필요하다고 알려져 있고 계산값 73GB가 그 범위 안에 들어옵니다. Llama 3.1 405B는 Q4에서 243GB로, 위 표와 정확히 맞아떨어집니다. 참고로 Q4_K_M은 대부분의 작업에서 Q8과 사실상 구분되지 않는 커뮤니티 표준으로, FP16 대비 perplexity가 0.2~0.5 정도만 증가합니다.

## 각 빌드가 실제로 무엇을 돌리는가

계산된 VRAM 요구량을 세 빌드 구성의 용량선과 겹쳐 보면 그림이 선명해집니다.

![모델 규모와 양자화별 필요 VRAM, 그리고 세 빌드 구성의 용량선]({{ '/assets/images/personal-ai-computer-onprem-vram-results.webp' | relative_url }})

용량선 위에 막대가 걸치지 않아야 그 모델이 해당 구성에서 실행됩니다. 정리하면 이렇습니다.

- **Home(64GB)**: 70B를 Q8로, 122B를 Q4로 여유 있게 소화합니다. 개인 실험과 소규모 팀의 코딩 보조에는 충분한 급입니다.
- **Business(256GB)**: 235B급을 Q8 근처까지 밀어붙일 수 있고, 여러 중형 모델을 동시에 상주시켜 라우팅하기에 적합합니다.
- **Team(384GB)**: 405B를 Q4(243GB)로 올리고도 141GB가 남습니다. 이 여유분이 긴 컨텍스트의 KV 캐시와 동시 요청을 감당하는 실질적인 헤드룸이 됩니다.

여기서 놓치기 쉬운 지점이 하나 있습니다. 표의 숫자는 "가중치를 올리는 데 필요한 최소치"일 뿐입니다. 실사용에서는 컨텍스트 길이와 동시 사용자 수가 늘어날수록 KV 캐시가 선형 이상으로 부풀어 VRAM 예산을 잠식합니다. 즉 405B가 "겨우 들어가는" 구성과 "여유 있게 서빙되는" 구성은 전혀 다른 이야기입니다.

## ThakiCloud 제품 적용 시사점

Personal AI Computer가 증명하는 것은 강력하지만 동시에 제한적입니다. 한 대의 기계, 한 명의 사용자, 수동 운영이라는 전제 안에서만 성립하기 때문입니다. 이 "집에서 한 대"를 조직 규모로 올리는 순간 완전히 다른 문제들이 등장하고, 바로 그 지점이 ThakiCloud의 **ai-platform**이 다루는 영역입니다.

ai-platform은 Kubernetes 위에서 Kueue로 GPU를 큐잉하고 스케줄링하며, vLLM으로 모델을 멀티테넌트로 서빙합니다. 개인 빌드에서는 GPU 4장을 한 사람이 독점하지만, 조직에서는 여러 팀과 여러 모델이 같은 GPU 풀을 두고 경쟁합니다. 이때 필요한 것은 테넌트 격리, 공정한 큐잉, 우선순위 기반 스케줄링, 그리고 사용량과 비용의 관측입니다. 개인 빌드가 수동으로 "지금은 이 모델만 올린다"고 결정하는 일을, 플랫폼은 정책과 스케줄러로 자동화합니다.

경제학의 방향도 같습니다. 개인 빌드의 "Own your intelligence"가 데이터 주권과 통제권을 하드웨어로 확보하는 논리라면, ai-platform은 같은 논리를 조직 규모에서 실현합니다. 온프레미스와 소버린 배포, 낮은 단위 서빙 비용, 그리고 self-hosting을 통한 데이터 통제는 국내 규제 대응이 필요한 고객 환경에서 특히 무게를 가집니다. 개인이 감당하기 어려운 RTX PRO 6000급 GPU의 활용률을 여러 워크로드가 공유해 끌어올리는 것도 플랫폼만이 할 수 있는 일입니다.

로컬 모델 위에서 에이전트를 돌리는 경우라면 ThakiCloud의 **Paxis** 관점도 겹칩니다. Paxis는 ai-platform 위에서 도는 Agent-Native Cloud 제어 평면으로, 스킬을 격리 샌드박스에서 실행하고 모든 행동을 정책 게이트와 감사 로그로 통과시킵니다. 자체 하드웨어에서 도는 모델에 자체 통제 평면을 붙이면, "지능을 소유한다"는 개인 빌드의 철학이 조직 수준의 거버넌스로 확장됩니다.

## 한계 및 반론

개인 빌드의 낭만을 그대로 받아들이기 전에 짚어야 할 현실이 있습니다.

첫째, 하드웨어 자체의 비용과 운영 부담입니다. RTX PRO 6000 Blackwell 4장 구성은 초기 CAPEX가 상당하고, 전력과 발열, 소음, 유지보수까지 지속적으로 따라옵니다. 단일 기계는 곧 단일 장애점이기도 합니다.

둘째, 클라우드가 여전히 합리적인 경우가 분명히 존재합니다. 사용량이 들쭉날쭉한 버스티 워크로드, 최신 프론티어 모델이 반드시 필요한 작업, 글로벌 저지연 서비스는 온프렘 한 대로 대응하기 어렵습니다. 온프렘의 손익분기는 "꾸준히 높은 활용률"이라는 전제 위에서만 성립합니다.

셋째, Q4 양자화가 공짜는 아닙니다. 평균적으로는 품질 저하가 미미하지만, 코딩이나 수학처럼 정밀도에 민감한 작업에서는 열화가 드러날 수 있습니다. 또한 앞서 언급했듯 긴 컨텍스트와 높은 동시성은 KV 캐시를 통해 VRAM 예산을 빠르게 소진시켜, "가중치는 들어가는데 서빙은 안 되는" 상황을 만듭니다.

결국 Personal AI Computer는 훌륭한 출발점이자 강력한 개념 증명입니다. 다만 개인의 한 대가 주는 통제권을 조직 전체가 안정적으로 누리려면, 그 위에 격리와 스케줄링, 관측과 거버넌스를 얹는 플랫폼 계층이 반드시 필요합니다. 개인 빌드가 던진 질문("지능을 소유할 수 있는가")에 조직 규모로 답하는 일이, 온프렘 AI 플랫폼이 풀고 있는 문제입니다.

## 출처

- [autonomous-ai/autonomous-computer (GitHub)](https://github.com/autonomous-ai/autonomous-computer)
- [Autonomous Computer: Build Your Own Home AI (writeup)](https://pasqualepillitteri.it/en/news/4998/autonomous-computer-build-home-ai-locally)
- [Best Local AI Models by VRAM: 8GB to 384GB (2026)](https://www.modemguides.com/blogs/ai-infrastructure/best-local-ai-models-by-vram-2026)
- [GPU Memory Requirements for LLMs (Spheron)](https://www.spheron.network/blog/gpu-memory-requirements-llm/)
- [Build an AI PC in 2026: Complete Hardware Guide (Local AI Master)](https://localaimaster.com/blog/ai-pc-build-guide)
- 원 공유: [@tom_doerr, Personal AI Computer build guides](https://x.com/tom_doerr)
