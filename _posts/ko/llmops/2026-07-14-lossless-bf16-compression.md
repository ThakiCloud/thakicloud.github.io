---
title: "양자화 없이 GLM-5.2에서 423GB를 지웠다: BF16 지수 필드의 낭비를 실측하다"
excerpt: "누군가 GLM-5.2에서 1403GB를 980GB로 줄였다고 했습니다. 양자화도, 프루닝도 아니고, 비트 단위로 완전히 동일한 무손실 압축이라고요. 처음엔 믿기 어려웠습니다. 그래서 직접 Qwen2.5-0.5B의 가중치 4억 9천만 개를 열어 BF16 지수 필드의 엔트로피를 측정했습니다. 8비트를 할당받은 지수가 실제로는 2.64비트만 쓰고 있었고, 이론적으로 33.5퍼센트를 무손실로 줄일 수 있다는 계산이 나왔습니다. 이 낭비가 어디서 오는지, 왜 디스크뿐 아니라 VRAM까지 줄어드는지 실측 데이터로 풀어봅니다."
tags:
  - lossless-compression
  - bf16
  - quantization
  - vram
  - llmops
  - self-hosting
  - vllm
  - paxis
date: 2026-07-14
lang: ko
canonical_url: "https://thakicloud.com/tech-blog/ko/llmops/lossless-bf16-compression/"
categories:
  - llmops
---

![조밀하게 쌓인 유리 큐브가 손실 없이 더 작은 덩어리로 압축되는 모습을 표현한 추상 일러스트]({{ '/assets/images/lossless-bf16-compression-hero.png' | relative_url }})

## 개요

로컬에서 대형 오픈웨이트 모델을 서빙해 본 팀이라면 첫 번째 벽이 언제나 용량이라는 것을 압니다. GLM-5.2처럼 7천억 개가 넘는 파라미터를 가진 모델은 BF16 원본만으로 1.4테라바이트에 육박하고, 이걸 GPU 여러 장에 올리려면 VRAM이 곧 돈이 됩니다. 그동안 이 문제의 정답은 거의 항상 양자화였습니다. 16비트를 8비트로, 4비트로, 심지어 2비트로 줄이면서 약간의 품질을 내주는 거래였지요.

이 글은 추론 비용을 책임지는 엔지니어링 리더와 온프레미스로 모델을 서빙하려는 실무자, 그리고 정밀도를 한 비트도 잃을 수 없는 규제 환경의 데이터 과학자를 위한 것입니다. 최근 brianbell-x라는 연구자가 GLM-5.2에서 423GB를 지웠다고 공개했습니다. 1403GB가 980GB가 되었는데, 놀라운 것은 그 방식이 양자화가 아니라는 점이었습니다. 프루닝도, 증류도 아니고, 압축을 풀면 원본과 비트 단위로 완전히 동일한 무손실 압축이라고 했습니다. 무손실인데 30퍼센트가 줄어든다면, 원본 형식이 그만큼 낭비하고 있었다는 뜻입니다.

저희는 이 주장을 그대로 믿는 대신, 직접 검증하기로 했습니다. Qwen2.5-0.5B의 실제 학습된 가중치 4억 9천만 개를 열어 BF16 지수 필드의 엔트로피를 측정했고, 그 결과 8비트를 할당받은 지수가 실제로는 2.64비트어치의 정보만 담고 있음을 확인했습니다. 이론적 무손실 압축 한계는 33.5퍼센트였고, 이것은 원 저자가 실제 코덱으로 달성한 30.17퍼센트와 거의 맞아떨어졌습니다. 이 글은 그 측정 과정과, 왜 이 절감이 디스크뿐 아니라 VRAM에서도 일어나는지를 설명합니다.

## 이 기술은 무엇인가

먼저 BF16이 한 숫자를 어떻게 저장하는지 봐야 합니다. BF16(brain floating point 16)은 16비트를 세 부분으로 나눕니다. 부호 1비트, 지수 8비트, 가수 7비트입니다. 지수가 8비트나 되는 이유는 BF16이 FP32와 같은 넓은 표현 범위를 유지하도록 설계되었기 때문입니다. 즉 아주 크거나 아주 작은 값까지 표현할 수 있도록 지수에 넉넉하게 8비트를 준 것입니다.

문제는 학습이 끝난 모델의 가중치가 이 넓은 범위를 거의 쓰지 않는다는 데 있습니다. 잘 학습된 신경망의 가중치는 대부분 0 근처의 작은 값에 몰려 있습니다. 그 결과 지수 필드는 몇 개의 값 주위로 강하게 뭉치고, 8비트가 표현할 수 있는 256가지 가능성 중 극히 일부만 실제로 등장합니다. 여기서 낭비가 생깁니다. 8비트를 할당했지만 실제로 담기는 정보량은 그보다 훨씬 적습니다.

무손실 압축의 아이디어는 단순합니다. 정보량이 적은 지수 필드는 엔트로피 부호화로 짧게 표현하고, 정보량이 많아 압축이 거의 안 되는 부호와 가수 8비트는 그대로 둡니다. 원 저자의 구현은 부호와 지수를 묶어 4비트 코드로 치환하고, 이 코드가 가장 흔한 15개 지수 조합을 담은 룩업 테이블을 가리키게 했습니다. 룩업 테이블에 없는 드문 값은 전체 형식으로 따로 저장합니다. 이 과정을 도식으로 정리하면 다음과 같습니다.

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
<div class="d3-arch" data-arch-root id="4losslessbf16compression-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 261, "height": 958, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 24, "y": 24, "w": 205, "h": 62, "title": ["학습된 BF16 가중치", "16비트 = 부호 1 + 지수 8 + 가수 7"]}, {"id": "B", "x": 42, "y": 164, "w": 170, "h": 62, "title": ["지수 필드 분석", "256개 값 중 실제로는 소수만 등장"]}, {"id": "C", "x": 42, "y": 304, "w": 170, "h": 62, "title": ["지수 엔트로피 측정", "8비트 할당 → 실제 약 2.64비트"]}, {"id": "D", "x": 38, "y": 444, "w": 177, "h": 62, "title": ["부호+지수를 4비트 코드로 치환", "가장 흔한 15개 조합 → 룩업 테이블"]}, {"id": "E", "x": 63, "y": 584, "w": 128, "h": 62, "title": ["가수 7비트는 그대로 보존", "비트 단위 무손실"]}, {"id": "F", "x": 52, "y": 724, "w": 149, "h": 62, "title": ["드문 지수는 전체 형식으로 저장", "고정폭 주소 유지"]}, {"id": "G", "x": 28, "y": 864, "w": 198, "h": 62, "title": ["압축된 가중치", "가중치당 약 10.6비트 (약 33% 절감)"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [127, 86, 127, 164]}, {"src": "B", "dst": "C", "kind": "data", "line": [127, 226, 127, 304]}, {"src": "C", "dst": "D", "kind": "data", "line": [127, 366, 127, 444]}, {"src": "D", "dst": "E", "kind": "data", "line": [127, 506, 127, 584]}, {"src": "E", "dst": "F", "kind": "data", "line": [127, 646, 127, 724]}, {"src": "F", "dst": "G", "kind": "data", "line": [127, 786, 127, 864]}]});
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
      const container = document.getElementById('4losslessbf16compression-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '4losslessbf16compression-1';
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

이 접근은 양자화와 근본적으로 다릅니다. 양자화는 가수를 잘라내거나 값을 반올림해 정밀도를 실제로 버립니다. 반면 이 무손실 압축은 어떤 값도 버리지 않습니다. 같은 정보를 더 짧은 부호로 다시 적을 뿐이므로, 압축을 풀면 원본 가중치가 비트 하나 틀리지 않고 그대로 복원됩니다. DFloat11이나 ZipNN 같은 최근 연구가 같은 계열에 속하는데, ZipNN은 학습된 LLM 가중치의 BF16 지수 필드가 8비트 할당 안에서 약 2.6비트의 섀넌 엔트로피만 가진다고 보고했습니다. 저희가 궁금했던 것은 이 숫자가 실제 모델에서도 재현되는가였습니다.

## 직접 측정해 본 지수 엔트로피

검증을 위해 격리된 작업 환경에서 실제 학습된 BF16 모델 하나를 열었습니다. 대상은 Qwen2.5-0.5B로, 4억 9천만 개의 가중치를 가진 실제 배포 모델입니다. safetensors 파일의 바이너리 레이아웃을 직접 파싱해 각 BF16 텐서를 16비트 정수로 읽은 뒤, 지수에 해당하는 8비트를 추출해 값의 분포와 섀넌 엔트로피를 계산했습니다. 어떤 프레임워크의 추정치도 쓰지 않고, 실제 텐서 바이트에서 나온 숫자만 사용했습니다.

핵심 측정 코드는 다음과 같습니다. BF16 값을 16비트 정수로 본 뒤 지수 필드만 잘라내는 부분입니다.

```python
import numpy as np

def bf16_exponent_bytes(raw: np.ndarray) -> np.ndarray:
    # raw = BF16 값을 uint16으로 본 것. 지수 = 비트 14..7 (8비트)
    return ((raw >> 7) & 0xFF).astype(np.uint8)

# safetensors 헤더를 파싱해 BF16 텐서를 uint16로 읽고
# 지수 필드의 등장 빈도로 섀넌 엔트로피를 계산합니다.
```

측정 결과는 예상보다 훨씬 극적이었습니다. 290개의 BF16 텐서, 총 4억 9천4백만 개의 가중치를 훑은 결과입니다.

| 항목 | 측정값 |
|---|---|
| BF16 텐서 수 | 290개 |
| 전체 가중치 수 | 494,032,768개 |
| 실제 등장한 지수 값 | 256개 중 38개뿐 |
| 지수 필드 섀넌 엔트로피 | **2.6386비트** (8비트 할당 중) |
| 가장 흔한 지수 상위 3개의 비중 | 전체의 약 72퍼센트 |
| 원본 대비 압축 후 가중치당 비트 | 16비트 → 10.64비트 |
| 이론적 무손실 절감률 | **33.5퍼센트** |

지수 필드는 256가지 값을 표현할 수 있지만 실제로는 38가지만 등장했고, 그중 상위 3개가 전체 가중치의 72퍼센트를 덮었습니다. 섀넌 엔트로피는 2.6386비트로, ZipNN이 보고한 약 2.6비트와 거의 정확히 일치했습니다. 즉 8비트를 할당한 지수 필드가 실제로는 2.64비트어치의 정보만 담고 있었고, 나머지 5.36비트는 순수한 낭비였던 셈입니다.

이 낭비를 무손실로 걷어내면 가중치당 비트 수는 16비트에서 10.64비트로 줄어듭니다. 부호와 가수 8비트를 그대로 보존하고 지수를 엔트로피 한계까지 압축했을 때의 값입니다. 절감률로는 33.5퍼센트입니다.

![Qwen2.5-0.5B 실측 결과. BF16 지수 필드가 실제로는 2.64비트만 쓰며, 이를 무손실로 압축하면 GLM-5.2 기준 1403GB가 약 980GB로 줄어든다는 것을 보여주는 차트]({{ '/assets/images/lossless-bf16-compression-results.png' | relative_url }})

이 33.5퍼센트를 GLM-5.2(753B) 규모로 투영하면 1403GB가 약 933GB가 됩니다. 원 저자가 실제 코덱으로 달성한 값은 980GB, 즉 30.17퍼센트 절감이었습니다. 저희의 이론적 한계(33.5퍼센트)와 실제 구현(30.17퍼센트) 사이의 3퍼센트포인트 차이는 우연이 아닙니다. 실제 엔트로피 부호화기는 섀넌 한계에 완전히 도달하지 못하고, 드문 지수 값은 전체 형식으로 저장해야 하며, GPU에서 임의 접근을 하려면 코드 폭을 고정해야 하기 때문에 약간의 오버헤드가 붙습니다. 이론과 구현이 이렇게 가깝게 맞아떨어졌다는 것은 원 저자의 주장이 사실이며 접근법이 건전하다는 강력한 증거입니다.

## GPU에서 왜 VRAM까지 줄어드는가

여기서 가장 오해하기 쉬운 지점을 짚어야 합니다. 대부분의 압축은 디스크에서만 작아지고, 모델을 GPU에 올리는 순간 원래 크기로 되돌아갑니다. 압축을 풀어야 계산할 수 있기 때문입니다. 그런데 이 무손실 압축의 30퍼센트는 디스크 숫자가 아니라 VRAM 숫자입니다. 이것이 이 기법이 단순한 파일 압축과 다른 이유입니다.

비결은 고정폭 코드에 있습니다. 모든 가중치의 압축 코드가 같은 너비를 가지므로, N번째 가중치가 어느 주소에 있는지를 압축을 풀지 않고도 곧바로 계산할 수 있습니다. 별도의 언패킹 과정이나 원본 형식의 두 번째 복사본이 필요 없습니다. GPU 커널은 압축된 바이트를 그대로 읽어 들이고, 레지스터에 올려 둔 작은 룩업 테이블에서 코드를 조회하면서 곱셈을 수행합니다. 완전한 16비트 형식은 VRAM 안에 결코 존재하지 않습니다. 그래서 30퍼센트라는 숫자가 디스크뿐 아니라 실제 메모리 점유에도 그대로 나타나는 것입니다.

실무적으로 이것이 의미하는 바는 큽니다. 1403GB 모델을 서빙하려면 80GB H100이 최소 18장은 필요합니다. 무손실 압축으로 980GB가 되면 13장 안팎으로 내려갑니다. 품질을 한 비트도 잃지 않고 GPU 다섯 장을 아끼는 셈입니다. 양자화가 품질과 메모리를 맞바꾸는 거래였다면, 이 기법은 공짜 점심에 가깝습니다. 물론 완전히 공짜는 아니고, 뒤에서 그 대가를 다루겠습니다.

## ThakiCloud 제품 적용 시사점

이 기법은 ThakiCloud의 ai-platform 관점에서 특히 매력적입니다. ai-platform은 Kubernetes와 Kueue 기반 GPU 스케줄링 위에서 다양한 고객 환경에 모델을 서빙하는 인프라입니다. 온프레미스와 소버린 클라우드를 요구하는 국내 고객이 많은데, 이런 환경에서는 GPU 한 장 한 장이 곧 자본 지출이고 조달 리드타임입니다. 무손실 압축은 정밀도를 전혀 희생하지 않으면서 필요 GPU 수를 줄여 주므로, 품질에 민감한 규제 산업 고객에게 양자화보다 설득하기 쉬운 카드입니다. 금융이나 의료처럼 모델 출력의 재현성이 감사 대상이 되는 곳에서는 비트 단위 동일성이 그 자체로 요구사항이 되기도 합니다.

특히 vLLM이나 SGLang으로 대형 모델을 서빙하는 멀티테넌트 구성에서 효과가 큽니다. VRAM에서 30퍼센트를 되찾으면 같은 하드웨어에 더 큰 컨텍스트 윈도우를 잡거나, 더 많은 동시 요청을 태우거나, 한 노드에 더 큰 모델을 올릴 수 있습니다. ai-platform이 낮은 서빙 비용에서 경쟁력을 갖는 지점이 바로 이런 자원 효율의 누적입니다. 무손실 압축은 양자화, 페이지드 어텐션, 텐서 병렬화와 직교하는 별개의 축이므로 기존 최적화 위에 그대로 더해집니다.

한편 저비용 서빙은 에이전트 경제성으로 이어집니다. ThakiCloud의 Agent-Native Cloud 제어 평면인 Paxis는 격리된 샌드박스에서 수백 개의 스킬을 실행하고 모든 행동을 정책 게이트와 감사 로그로 통과시키는데, 이런 에이전트 워크로드는 대형 오픈웨이트 모델을 반복 호출합니다. 서빙 단가가 내려갈수록 에이전트를 더 공격적으로 돌릴 수 있으므로, ai-platform의 자원 효율이 곧 Paxis의 운용 경제성을 떠받치는 구조입니다.

## 한계 및 반론

이 기법이 만능은 아닙니다. 먼저 지수 엔트로피가 낮다는 전제는 잘 학습된 모델에서만 성립합니다. 가중치가 0 근처에 몰려 있어야 지수가 뭉치는데, 학습이 덜 되었거나 분포가 넓은 모델, 혹은 이미 강하게 양자화된 모델에서는 절감 폭이 작아집니다. 저희 측정도 특정 모델 하나에서 나온 값이므로, 아키텍처와 학습 방식에 따라 실제 수치는 달라질 수 있습니다.

둘째, 압축 코드를 실시간으로 해석하려면 GPU 커널이 룩업과 곱셈을 함께 처리해야 합니다. 이 커널이 잘 최적화되지 않으면 메모리는 아꼈지만 지연 시간이 늘어나는 역효과가 날 수 있습니다. 메모리 대역폭이 병목인 워크로드에서는 오히려 빨라질 수도 있지만, 이는 하드웨어와 커널 구현에 크게 의존하므로 실제 배포 전에 대상 GPU에서 반드시 벤치마크해야 합니다.

셋째, 이 방식은 어디까지나 무손실이라 4비트 양자화 같은 공격적 압축이 주는 절감에는 미치지 못합니다. 30퍼센트 절감은 훌륭하지만, 품질을 조금 내주고 4배를 줄이는 양자화와는 목적이 다릅니다. 두 기법은 경쟁 관계가 아니라 보완 관계이며, 정밀도가 절대적으로 중요한 구간에는 무손실 압축을, 품질 여유가 있는 구간에는 양자화를 쓰는 식의 조합이 현실적인 답입니다.

마지막으로 이 결과는 한 연구자의 공개 실험과 저희의 소규모 재현에 기반합니다. 프로덕션에 적용하려면 대상 모델과 서빙 스택에서 압축과 복원의 비트 동일성, 커널 성능, 실제 VRAM 절감을 독립적으로 검증하는 과정이 반드시 필요합니다.

## 출처

- brianbell-x, "Lossless Model Compression Experiment": [https://brianbell-x.github.io/weight-compression/](https://brianbell-x.github.io/weight-compression/)
- 측정 대상 모델: Qwen/Qwen2.5-0.5B (Hugging Face)
- 관련 연구: ZipNN, DFloat11 (BF16 지수 엔트로피 부호화 계열)
