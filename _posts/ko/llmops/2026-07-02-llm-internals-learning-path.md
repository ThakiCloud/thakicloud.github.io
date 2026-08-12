---
title: "LLM 내부 구조를 체계적으로 배우는 법: 토큰화부터 추론 최적화까지"
excerpt: "LLM을 운영하면서도 KV 캐시가 왜 메모리를 잡아먹는지, GQA가 무엇을 절약하는지 설명하지 못한다면 최적화는 감에 의존하게 됩니다. amitshekhariitbhu/llm-internals는 토큰화, 어텐션 수식, 트랜스포머 블록, KV 캐시, MoE, GQA를 순서대로 엮은 학습 리포지토리입니다. 각 주제가 왜 인프라 엔지니어에게 직접적인 무기가 되는지 정리합니다."
seo_title: "LLM 내부 구조 학습 로드맵: 토큰화·어텐션·KV 캐시·MoE·GQA | Thaki Cloud"
seo_description: "llm-internals 학습 리포지토리를 분석해 토큰화(BPE), 어텐션 Q/K/V, 트랜스포머 블록, KV 캐시, MoE, GQA를 인프라 엔지니어 관점에서 정리하고, vLLM·Kueue 서빙 최적화와 연결합니다."
date: 2026-07-02
last_modified_at: 2026-07-02
tags:
  - llm-internals
  - transformer
  - kv-cache
  - mixture-of-experts
  - gqa
  - llm-inference
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "microchip"
canonical_url: "https://thakicloud.com/tech-blog/ko/technique/llm-internals-learning-path/"
categories:
  - llmops
---

![LLM 서빙의 블랙박스를 열다: 토큰화부터 추론 최적화까지, 인프라 엔지니어를 위한 멘탈 모델]({{ '/assets/images/llm-internals-learning-path-slide-01.webp' | relative_url }})

## 개요

LLM 서빙을 운영하다 보면 이상한 지점에 도달합니다. vLLM을 배포하고, GPU 사용률을 모니터링하고, 배치 크기를 조정하면서도 정작 "왜 이 요청이 KV 캐시를 이만큼 점유하는가", "GQA가 정확히 무엇을 줄여서 메모리 대역폭을 아끼는가"를 문장으로 설명하지 못하는 순간이 옵니다. 도구는 다룰 줄 알지만 그 아래의 원리는 흐릿한 상태입니다. 이 간극은 최적화를 감에 의존하게 만들고, 장애가 났을 때 원인을 추론하지 못하게 합니다.

![도구는 다루지만 그 아래의 원리를 모르는 상태: KV 캐시 점유와 GQA를 설명하지 못하는 간극]({{ '/assets/images/llm-internals-learning-path-slide-02.webp' | relative_url }})

이 문제를 정면으로 겨냥한 학습 리소스가 [amitshekhariitbhu/llm-internals](https://github.com/amitshekhariitbhu/llm-internals)입니다. 토큰화에서 시작해 어텐션, 트랜스포머 구조, KV 캐시, 그리고 추론 최적화까지 이어지는 순서로 블로그와 영상을 엮은 단계별 학습 리포지토리입니다. 원저자는 Amit Shekhar이며, 흩어진 일회성 튜토리얼 대신 하나의 정돈된 멘탈 모델을 세우도록 주제를 배열했습니다.

ThakiCloud는 K8s 위에서 다양한 고객 환경에 모델을 서빙하는 ai-platform을 운영합니다. 서빙 비용과 지연을 결정하는 요소는 대부분 이 리포지토리가 다루는 내부 구조에서 나옵니다. 그래서 이 글은 단순한 리소스 소개가 아니라, 각 주제가 인프라 엔지니어에게 왜 직접적인 무기가 되는지를 함께 정리합니다.

## 이 리소스는 무엇인가

llm-internals는 코드를 실행하는 프레임워크가 아니라 **학습 경로(learning path)** 입니다. LLM이 입력을 받아 다음 토큰을 내놓기까지의 파이프라인을 따라가면서, 각 단계에 필요한 개념을 외부 자료와 함께 순서대로 제시합니다. 핵심은 "무엇을 어떤 순서로 이해해야 전체 그림이 맞춰지는가"라는 커리큘럼 설계에 있습니다.

![Amit Shekhar의 llm-internals는 뒤 주제가 앞 주제 없이는 이해되지 않도록 설계된 순차적 학습 경로입니다]({{ '/assets/images/llm-internals-learning-path-slide-04.webp' | relative_url }})

리포지토리가 다루는 주요 주제는 다음과 같은 흐름을 따릅니다.

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
<div class="d3-arch" data-arch-root id="llminternalslearningpath-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 526, "height": 942, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 199, "y": 24, "w": 120, "h": 46, "title": "입력 텍스트"}, {"id": "B", "x": 167, "y": 148, "w": 184, "h": 62, "title": ["토큰화", "BPE Byte Pair Encoding"]}, {"id": "C", "x": 199, "y": 288, "w": 120, "h": 62, "title": ["임베딩", "토큰을 벡터로"]}, {"id": "D", "x": 192, "y": 428, "w": 135, "h": 62, "title": ["어텐션", "Query Key Value"]}, {"id": "E", "x": 287, "y": 568, "w": 120, "h": 62, "title": ["트랜스포머 블록", "어텐션 + FFN 반복"]}, {"id": "F", "x": 374, "y": 708, "w": 120, "h": 62, "title": ["KV 캐시", "생성 속도 가속"]}, {"id": "G", "x": 199, "y": 708, "w": 120, "h": 62, "title": ["MoE", "전문가 라우팅"]}, {"id": "H", "x": 24, "y": 708, "w": 120, "h": 62, "title": ["GQA", "KV 헤드 공유"]}, {"id": "I", "x": 199, "y": 848, "w": 120, "h": 62, "title": ["추론 최적화", "서빙 효율"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [259, 70, 259, 148]}, {"src": "B", "dst": "C", "kind": "data", "line": [259, 210, 259, 288]}, {"src": "C", "dst": "D", "kind": "data", "line": [259, 350, 259, 428]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[298, 490], [347, 529], [347, 529], [347, 568]]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[385, 630], [434, 669], [434, 669], [434, 708]]}, {"src": "E", "dst": "G", "kind": "data", "curve": [[308, 630], [259, 669], [259, 669], [259, 708]]}, {"src": "D", "dst": "H", "kind": "data", "curve": [[192, 486], [84, 529], [84, 669], [84, 708]]}, {"src": "F", "dst": "I", "kind": "data", "curve": [[434, 770], [434, 809], [434, 809], [319, 855]]}, {"src": "G", "dst": "I", "kind": "data", "line": [259, 770, 259, 848]}, {"src": "H", "dst": "I", "kind": "data", "curve": [[84, 770], [84, 809], [84, 809], [199, 855]]}]});
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
      const container = document.getElementById('llminternalslearningpath-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'llminternalslearningpath-1';
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

이 순서가 중요한 이유는, 뒤쪽 주제가 앞쪽 주제 없이는 이해되지 않기 때문입니다. KV 캐시는 어텐션의 Key/Value가 무엇인지 알아야 의미가 통하고, GQA는 멀티헤드 어텐션의 헤드 구조를 알아야 "무엇을 공유하는지" 보입니다. 리포지토리의 가치는 자료 하나하나의 깊이보다 이 의존 관계를 무너뜨리지 않는 배열에 있습니다.

## 핵심 주제 톺아보기

### 토큰화: 모든 것의 출발점

LLM은 글자나 단어를 직접 다루지 않고 토큰 단위로 처리합니다. 현대 모델 대부분은 BPE(Byte Pair Encoding) 계열을 씁니다. 자주 함께 등장하는 바이트 쌍을 반복적으로 병합해 어휘를 구성하는 방식입니다. 토큰화는 사소해 보이지만 서빙 관점에서 직접적인 비용 요소입니다. 같은 문장이라도 언어와 토크나이저에 따라 토큰 수가 크게 달라지고, 토큰 수는 곧 KV 캐시 점유량과 연산량으로 이어집니다. 한국어·아랍어 같은 비영어 텍스트가 영어보다 토큰을 더 많이 소모하는 현상은 서빙 비용 산정에서 반드시 고려해야 하는 지점입니다.

![모든 서빙 비용의 출발점은 토큰 분할에 있습니다: BPE와 비영어 텍스트의 토큰 소모]({{ '/assets/images/llm-internals-learning-path-slide-06.webp' | relative_url }})

### 어텐션: Query, Key, Value

트랜스포머의 심장은 셀프 어텐션입니다. 각 토큰은 세 벡터로 투영됩니다. Query는 "내가 무엇을 찾는가", Key는 "나는 무엇을 제공하는가", Value는 "실제로 전달할 내용"에 해당합니다. 어텐션 점수는 Query와 Key의 내적으로 계산되고, 스케일링과 소프트맥스를 거쳐 Value의 가중합을 만듭니다.

```
Attention(Q, K, V) = softmax( (Q · Kᵀ) / √d_k ) · V
```

이 수식 자체는 단순하지만, 시퀀스 길이 n에 대해 어텐션 연산이 O(n²)로 커진다는 사실이 이후의 모든 최적화를 낳습니다. 긴 컨텍스트가 왜 비싼지, 왜 서빙 인프라가 컨텍스트 길이에 민감한지가 여기서 출발합니다.

### 트랜스포머 블록과 KV 캐시

트랜스포머는 어텐션과 피드포워드 네트워크(FFN)를 묶은 블록을 여러 층 쌓은 구조입니다. 자기회귀 생성에서는 토큰을 하나씩 만들어 내는데, 매 스텝마다 이전 토큰들의 Key와 Value를 다시 계산하면 낭비가 큽니다. **KV 캐시**는 이미 계산한 Key/Value를 저장해 두고 재사용함으로써 생성 속도를 끌어올립니다.

문제는 이 캐시가 메모리를 먹는다는 점입니다. 캐시 크기는 대략 `2 × 층 수 × KV 헤드 수 × 헤드 차원 × 시퀀스 길이 × 배치 크기`에 비례합니다. 긴 컨텍스트와 많은 동시 요청은 이 값을 폭발적으로 키웁니다. vLLM의 PagedAttention이 KV 캐시를 페이지 단위로 관리해 단편화를 줄이는 이유가 바로 이 구조적 압박 때문입니다.

![생성 속도를 얻는 대신 거대한 메모리 장벽을 만납니다: KV 캐시 크기 공식과 PagedAttention]({{ '/assets/images/llm-internals-learning-path-slide-08.webp' | relative_url }})

### MoE와 GQA: 효율을 위한 구조 변화

**Mixture of Experts(MoE)** 는 FFN을 여러 개의 전문가(expert)로 나누고, 라우터가 토큰마다 일부 전문가만 활성화합니다. 파라미터 총량은 크지만 토큰당 실제 연산량은 작아지는 구조입니다. 대신 서빙에서는 전문가 병렬화, 라우팅 불균형, 메모리 배치라는 새로운 과제를 안깁니다.

![MoE는 파라미터 총량은 늘리고 토큰당 연산량은 줄입니다: 라우터가 일부 전문가만 선택적으로 활성화]({{ '/assets/images/llm-internals-learning-path-slide-10.webp' | relative_url }})

**Grouped-Query Attention(GQA)** 는 멀티헤드 어텐션(MHA)과 멀티쿼리 어텐션(MQA)의 절충안입니다. MHA는 모든 헤드가 각자의 Key/Value를 가지고, MQA는 모든 헤드가 하나의 Key/Value를 공유합니다. GQA는 헤드를 몇 개의 그룹으로 묶어 그룹 단위로 KV를 공유합니다. 결과적으로 **KV 캐시 크기와 메모리 대역폭이 줄어들면서** 품질 손실은 최소화됩니다. GQA를 이해하면 왜 최신 오픈웨이트 모델이 이 구조를 채택하는지, 그리고 서빙 시 메모리 예산이 왜 달라지는지가 선명해집니다.

## 왜 인프라 엔지니어에게 이 지식이 중요한가

위 주제들은 학문적 호기심의 대상이 아니라 서빙 비용의 직접 원인입니다. KV 캐시 크기 공식을 이해하면 동시 요청 수와 컨텍스트 길이가 GPU 메모리에 어떻게 부딪히는지 예측할 수 있습니다. GQA를 이해하면 같은 GPU에서 왜 어떤 모델은 더 많은 요청을 처리하는지 설명할 수 있습니다. MoE를 이해하면 전문가 병렬 배치가 왜 스케줄링을 복잡하게 만드는지 대비할 수 있습니다.

반대로 이 지식이 없으면, 장애 상황에서 "메모리가 부족합니다"라는 증상만 보고 배치 크기를 무작정 줄이거나 GPU를 늘리는 값비싼 대응만 반복하게 됩니다. 내부 구조를 아는 엔지니어는 KV 캐시 페이징, 컨텍스트 길이 상한, 양자화, GQA 모델 선택이라는 더 정밀한 레버를 손에 쥡니다.

## ThakiCloud 제품 적용 시사점

ThakiCloud의 **ai-platform**은 Kubernetes와 Kueue GPU 스케줄링 위에서 vLLM 기반 추론을 멀티테넌트로 제공합니다. 이 글에서 정리한 내부 구조는 그대로 운영 레버로 이어집니다.

![K8s 환경에서 이 지식은 멀티테넌트 운영의 무기가 됩니다: KV 캐시 예측, GQA와 양자화, MoE 병렬화]({{ '/assets/images/llm-internals-learning-path-slide-12.webp' | relative_url }})

- **KV 캐시**: PagedAttention과 KV 캐시 크기 공식을 근거로, 테넌트별 컨텍스트 길이 상한과 동시성 예산을 설정합니다. 캐시 점유를 예측하면 GPU 메모리 오버커밋 없이 처리량을 끌어올릴 수 있습니다.
- **GQA·양자화**: 같은 하드웨어에서 더 많은 요청을 담기 위해 GQA를 채택한 오픈웨이트 모델을 우선 후보로 검토하고, 양자화와 결합해 온프레미스·소버린 환경의 낮은 서빙 비용을 목표로 합니다.
- **MoE 서빙**: 전문가 병렬화가 필요한 MoE 모델은 Kueue 큐 설계와 노드 배치에서 별도 취급이 필요하다는 점을 사전에 반영합니다.

에이전트 관점에서는, ThakiCloud의 Agent-Native Cloud인 **Paxis**가 이런 내부 지식을 팀 자산으로 축적하는 데 유리합니다. Paxis는 스킬을 일급 리소스로 다루므로, "KV 캐시 예산 계산" 같은 반복 판단을 검증된 스킬로 굳혀 격리 샌드박스에서 재사용하고 감사 로그로 추적할 수 있습니다. 개별 엔지니어의 암묵지가 되기 쉬운 서빙 노하우를 조직의 절차적 지식으로 전환하는 통로가 됩니다.

## 한계 및 반론

이 리소스의 가장 큰 약점은 큐레이션 리포지토리의 숙명입니다. 외부 블로그와 영상을 엮는 구조이므로 링크가 낡거나 사라질 수 있고, 자료 간 표기·깊이의 편차도 존재합니다. 최신 아키텍처 변화(예: 새로운 어텐션 변형)가 즉시 반영된다는 보장도 없습니다.

또한 개념 이해와 실전 운영 사이에는 여전히 간극이 있습니다. KV 캐시 공식을 외운다고 해서 특정 GPU에서의 실제 처리량이 곧바로 나오지는 않습니다. 실측 벤치마크, 프로파일링, 워크로드별 튜닝은 별도의 실전 경험을 요구합니다. 이 학습 경로는 정확한 멘탈 모델을 세우는 출발점으로 가치가 크지만, 그 자체로 서빙 최적화의 종착점은 아닙니다. 원리를 이해한 뒤 실제 트래픽 위에서 검증하는 단계가 반드시 뒤따라야 합니다.

## 출처

- [amitshekhariitbhu/llm-internals (GitHub)](https://github.com/amitshekhariitbhu/llm-internals)
- 원 추천 트윗: Dan Kornas, "Stop learning LLM internals from random one-off tutorials"
