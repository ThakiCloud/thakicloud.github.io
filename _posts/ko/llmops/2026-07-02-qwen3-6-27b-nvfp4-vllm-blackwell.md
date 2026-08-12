---
title: "Qwen3.6-27B를 NVFP4로: Blackwell 단일 GPU 서빙의 경제학"
excerpt: "NVIDIA가 Qwen3.6-27B를 NVFP4로 재양자화해 단일 Blackwell GPU에서 vLLM으로 바로 서빙할 수 있게 했습니다. MLP는 NVFP4로 내리고 어텐션과 KV 캐시는 FP8로 남기는 혼합 정밀도가 어떻게 22GB 안에 27B 모델을 담는지, 그리고 이 방식이 ThakiCloud ai-platform의 멀티테넌트 GPU 서빙 경제성에 어떤 의미인지 정리합니다."
seo_title: "Qwen3.6-27B-NVFP4 vLLM Blackwell 단일 GPU 서빙 분석 | Thaki Cloud"
seo_description: "NVIDIA ModelOpt의 Qwen3.6-27B-NVFP4 재양자화(MLP는 NVFP4 W4A16, 어텐션·KV 캐시는 FP8)와 vLLM 서빙 방법을 정리하고, 단일 Blackwell GPU 서빙이 ThakiCloud ai-platform의 GPU 비용 효율에 주는 시사점을 분석합니다."
date: 2026-07-02
last_modified_at: 2026-07-02
tags:
  - vllm
  - nvfp4
  - quantization
  - blackwell
  - model-serving
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "microchip"
canonical_url: "https://thakicloud.com/tech-blog/ko/llmops/qwen3-6-27b-nvfp4-vllm-blackwell/"
categories:
  - llmops
---

![Qwen3.6-27B를 NVFP4로: Blackwell 단일 GPU 서빙의 경제학 개념을 형상화한 이미지](/assets/images/qwen3-6-27b-nvfp4-vllm-blackwell-hero.png)
*글의 핵심 개념을 형상화했습니다.*

## 개요

27B 규모의 모델을 단일 GPU에서, 그것도 근사 무손실 정확도로 서빙할 수 있다면 온프레미스 추론의 경제학이 바뀝니다. NVIDIA가 공개한 nvidia/Qwen3.6-27B-NVFP4 체크포인트는 Qwen3.6-27B를 NVFP4 데이터 타입으로 재양자화해, 최신 vLLM에서 별도 설정 없이 바로 추론할 수 있게 만든 것입니다. vLLM 프로젝트가 Blackwell GPU에서 이 체크포인트가 추론 준비를 마쳤다고 알린 배경입니다.

핵심은 단순한 "4비트로 줄였다"가 아니라 **어디를 줄이고 어디를 남겼는가**에 있습니다. 이 글은 NVFP4 재양자화의 혼합 정밀도 설계를 뜯어보고, vLLM에서의 실제 서빙 방법을 정리한 뒤, 이 방식이 ThakiCloud ai-platform의 멀티테넌트 GPU 서빙 비용 구조에 무엇을 의미하는지 짚습니다. 실측이 필요한 대목은 정직하게 구분해 표기합니다.

## 이 기술은 무엇인가

NVFP4는 4비트 부동소수 포맷으로, 파라미터당 비트 수를 16에서 4로 낮춰 디스크와 GPU 메모리 요구를 약 2.5배 줄입니다. 하지만 nvidia/Qwen3.6-27B-NVFP4의 실제 설계는 전체를 4비트로 뭉개지 않습니다. NVIDIA ModelOpt의 재양자화는 **MLP 선형 계층만 NVFP4(W4A16)로 내리고, 어텐션 선형 계층과 KV 캐시는 FP8로 남깁니다.** 그 결과 약 22GB의 가중치가 단일 Blackwell GPU에 들어갑니다. NVIDIA는 이 구성이 FP8 기준선 대비 근사 무손실 정확도를 보인다고 보고합니다.

이 혼합 정밀도 선택에는 이유가 있습니다. MLP 계층은 파라미터 수가 압도적으로 많아 메모리 절감 효과가 크지만 4비트화에 상대적으로 관대합니다. 반면 어텐션과 KV 캐시는 긴 컨텍스트에서 품질에 민감하므로 FP8로 남겨 정확도를 지킵니다. 즉 "가장 무거운 곳을 가장 공격적으로 줄이고, 가장 민감한 곳은 보수적으로 남긴다"는 원칙입니다.

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
<div class="d3-arch" data-arch-root id="n3627bnvfp4vllmblackwell-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 526, "height": 878, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 164, "y": 24, "w": 191, "h": 46, "title": "Qwen3.6-27B 원본 FP16 가중치"}, {"id": "B", "x": 174, "y": 148, "w": 170, "h": 46, "title": "NVIDIA ModelOpt 재양자화"}, {"id": "C", "x": 374, "y": 272, "w": 120, "h": 62, "title": ["MLP 선형 계층", "NVFP4 W4A16"]}, {"id": "D", "x": 199, "y": 272, "w": 120, "h": 62, "title": ["어텐션 선형 계층", "FP8 유지"]}, {"id": "E", "x": 24, "y": 272, "w": 120, "h": 62, "title": ["KV 캐시", "FP8 유지"]}, {"id": "F", "x": 199, "y": 412, "w": 120, "h": 46, "title": "약 22GB 가중치"}, {"id": "G", "x": 174, "y": 536, "w": 170, "h": 46, "title": "단일 Blackwell GPU에 적재"}, {"id": "H", "x": 171, "y": 660, "w": 177, "h": 62, "title": ["vLLM 자동 감지", "quantization modelopt"]}, {"id": "I", "x": 181, "y": 800, "w": 156, "h": 46, "title": "OpenAI 호환 추론 엔드포인트"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [259, 70, 259, 148]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[324, 194], [434, 233], [434, 233], [434, 272]]}, {"src": "B", "dst": "D", "kind": "data", "line": [259, 194, 259, 272]}, {"src": "B", "dst": "E", "kind": "data", "curve": [[194, 194], [84, 233], [84, 233], [84, 272]]}, {"src": "C", "dst": "F", "kind": "data", "curve": [[434, 334], [434, 373], [434, 373], [319, 414]]}, {"src": "D", "dst": "F", "kind": "data", "line": [259, 334, 259, 412]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[84, 334], [84, 373], [84, 373], [199, 414]]}, {"src": "F", "dst": "G", "kind": "data", "line": [259, 458, 259, 536]}, {"src": "G", "dst": "H", "kind": "data", "line": [259, 582, 259, 660]}, {"src": "H", "dst": "I", "kind": "data", "line": [259, 722, 259, 800]}]});
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
      const container = document.getElementById('n3627bnvfp4vllmblackwell-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'n3627bnvfp4vllmblackwell-1';
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

기존의 통짜 4비트 양자화(예: 전 계층 W4)와 비교하면, 이 방식은 메모리 절감의 대부분을 취하면서 품질 손실은 민감 계층을 FP8로 남겨 방어합니다. 절감과 정확도 사이의 트레이드오프를 계층 단위로 다르게 잡은 것이 NVFP4 재양자화의 핵심 차별점입니다.

## 설치 및 서빙

vLLM은 체크포인트에서 ModelOpt 양자화를 자동 감지하므로 별도의 양자화 플래그를 굳이 지정하지 않아도 됩니다. 다만 NVFP4/W4A16을 지원하는 최신 vLLM이 필요하며, NVIDIA는 nightly 또는 ModelOpt 지원이 포함된 소스 빌드를 권장합니다. Docker로 nightly 이미지를 띄운 뒤 다음과 같이 서빙합니다.

```bash
# NVFP4/ModelOpt 지원 최신 vLLM (nightly 이미지)
docker run --gpus all -p 8000:8000 \
  vllm/vllm-openai:nightly \
  vllm serve nvidia/Qwen3.6-27B-NVFP4 \
    --port 8000 \
    --quantization modelopt \
    --max-model-len 262144 \
    --reasoning-parser qwen3
```

`--max-model-len 262144`는 Qwen3.6 계열의 긴 컨텍스트를 그대로 활용하는 설정이고, `--reasoning-parser qwen3`는 추론 토큰 파싱을 위한 것입니다. 엔드포인트는 OpenAI 호환이므로 기존 클라이언트를 그대로 붙일 수 있습니다.

## 실제 실험 결과

정직하게 밝힙니다. 이 체크포인트는 Blackwell 계열 GPU를 전제로 하며, 본 글을 작성한 환경에는 해당 하드웨어가 없어 **로컬에서 직접 재현하지 못했습니다.** 따라서 아래 수치는 우리가 측정한 값이 아니라 공개 출처가 보고한 값이며, 그대로 인용하되 출처를 명시합니다.

- NVIDIA는 NVFP4 재양자화 구성이 FP8 기준선 대비 **근사 무손실 정확도**를 보인다고 보고합니다(모델 카드 기준).
- 가중치 크기는 약 **22GB**로, 단일 Blackwell GPU에 적재됩니다(모델 카드 기준).
- 한 서드파티 벤치마크(loFT LLC)는 듀얼 RTX PRO 6000 Blackwell Max-Q 환경에서 NVFP4+MTP 구성으로 **약 190 tok/s의 생성 처리량**을 보고합니다. [추정] 성격의 외부 측정치이며, 우리 환경의 값이 아닙니다.

우리가 검증할 수 있었던 것은 서빙 경로의 사실관계입니다. vLLM이 ModelOpt 양자화를 자동 감지한다는 점, 혼합 정밀도(MLP는 NVFP4, 어텐션·KV는 FP8) 구성이라는 점, 그리고 22GB 가중치가 단일 Blackwell에 들어간다는 점은 공개 모델 카드와 vLLM 레시피에서 확인됩니다. 실제 처리량과 지연은 하드웨어를 확보한 뒤 별도로 측정할 사안으로 남깁니다.

## ThakiCloud 제품 적용 시사점

이 체크포인트가 흥미로운 이유는 벤치마크 숫자 자체보다 **서빙 경제학의 이동**에 있습니다. ThakiCloud ai-platform은 K8s와 Kueue 기반으로 다양한 고객 환경에서 모델을 서빙하며, GPU는 언제나 가장 비싼 자원입니다. 27B급 모델을 단일 GPU에, 그것도 근사 무손실로 담을 수 있다면 테넌트당 GPU 점유를 낮추고 같은 하드웨어에서 더 많은 모델 또는 더 많은 테넌트를 수용할 수 있습니다.

멀티테넌트 관점에서 이 절감은 곱셈으로 커집니다. 모델 하나가 2개 GPU에서 1개로 내려가면, 클러스터 전체의 동시 서빙 슬롯이 두 배 가까이 늘어납니다. Kueue 기반의 GPU 할당에서 이는 대기 큐를 줄이고 테넌트 간 공정 배분을 쉽게 만드는 직접적 효과로 이어집니다. 온프레미스·소버린 요구가 강한 고객에게는 특히 의미가 큽니다. 도입해야 할 GPU 대수 자체가 줄어 초기 투자와 운영 비용의 문턱이 낮아지기 때문입니다.

혼합 정밀도 설계는 우리 운영 철학과도 맞닿아 있습니다. 무차별적으로 정밀도를 낮추는 대신, 품질에 민감한 부분은 남기고 무거운 부분만 공격적으로 줄이는 접근은 "비용 효율과 품질을 동시에"라는 목표에 부합합니다. ai-platform에서 새 양자화 체크포인트를 도입할 때, 벤치마크 점수뿐 아니라 어느 계층을 어떤 정밀도로 다뤘는지를 함께 검토하는 이유입니다. NVFP4 재양자화는 그 검토의 좋은 참조 사례입니다.

## 한계 및 반론

첫째, 하드웨어 종속이 뚜렷합니다. NVFP4의 이점은 Blackwell 세대 GPU에서 극대화되며, 그 이전 세대에서는 동일한 효율을 기대하기 어렵습니다. 단일 GPU 서빙이라는 매력도 Blackwell을 확보했다는 전제 위에서만 성립합니다. GPU 조달 자체가 병목인 환경에서는 "단일 GPU면 충분"이라는 명제가 곧바로 비용 절감으로 이어지지 않을 수 있습니다.

둘째, 근사 무손실이라는 표현은 벤치마크 평균의 이야기입니다. 특정 도메인이나 긴 컨텍스트, 수치·코드처럼 정밀도에 민감한 과제에서는 FP8 기준선 대비 미세한 품질 저하가 드러날 수 있습니다. NVFP4 도입 판단은 모델 카드의 요약 수치가 아니라 실제 서빙할 워크로드에서의 평가로 확정해야 합니다.

셋째, 이 글의 처리량 수치는 우리 측정치가 아닙니다. 서드파티 벤치는 하드웨어 구성(듀얼 RTX PRO 6000, MTP 사용 여부)과 배치·컨텍스트 길이에 크게 좌우되므로, 우리 클러스터의 실제 값은 직접 측정하기 전까지는 미확정입니다. 이 글의 결론은 "NVFP4 단일 GPU 서빙이 서빙 경제학을 바꿀 잠재력이 있다"까지이며, "우리 환경에서 몇 tok/s가 나온다"는 별도 검증이 끝난 뒤에 말할 문제입니다.


## 관련 슬라이드

본문 내용을 NotebookLM(`neo_swiss` 스타일)으로 요약한 슬라이드입니다.

![qwen3-6-27b-nvfp4-vllm-blackwell 슬라이드 1]({{ '/assets/images/qwen3-6-27b-nvfp4-vllm-blackwell-slide-01.webp' | relative_url }})

![qwen3-6-27b-nvfp4-vllm-blackwell 슬라이드 2]({{ '/assets/images/qwen3-6-27b-nvfp4-vllm-blackwell-slide-02.webp' | relative_url }})

![qwen3-6-27b-nvfp4-vllm-blackwell 슬라이드 3]({{ '/assets/images/qwen3-6-27b-nvfp4-vllm-blackwell-slide-03.webp' | relative_url }})

![qwen3-6-27b-nvfp4-vllm-blackwell 슬라이드 4]({{ '/assets/images/qwen3-6-27b-nvfp4-vllm-blackwell-slide-04.webp' | relative_url }})

## 출처

- nvidia/Qwen3.6-27B-NVFP4 모델 카드, Hugging Face (<https://huggingface.co/nvidia/Qwen3.6-27B-NVFP4>)
- Qwen/Qwen3.6-27B, vLLM Recipes (<https://recipes.vllm.ai/Qwen/Qwen3.6-27B>)
- Measuring Qwen3.6-27B NVFP4+MTP on vLLM, loFT LLC (<https://loftllc.dev/en/docs/tech/llm-research/qwen3-6-27b-nvfp4-mtp-vllm-benchmark/>)
