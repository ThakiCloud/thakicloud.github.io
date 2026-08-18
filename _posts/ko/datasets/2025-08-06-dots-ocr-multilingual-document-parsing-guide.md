---
title: "dots.ocr: 1.7B 파라미터로 달성한 SOTA 다국어 문서 파싱 - 완전 분석"
excerpt: "RedNote가 공개한 dots.ocr로 다국어 문서 레이아웃 분석과 OCR을 단일 비전-언어 모델에서 구현하는 방법을 알아봅니다."
seo_title: "dots.ocr 다국어 문서 파싱 모델 완전 분석 - Thaki Cloud"
seo_description: "1.7B 파라미터 VLM으로 SOTA 성능을 달성한 dots.ocr의 아키텍처, 벤치마크 결과, 실제 활용법을 상세히 분석합니다."
date: 2025-08-06
last_modified_at: 2025-08-06
tags:
  - dots.ocr
  - document-parsing
  - multilingual-ocr
  - vision-language-model
  - document-ai
  - layout-detection
  - rednote
  - omnidocbench
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ko/datasets/dots-ocr-multilingual-document-parsing-guide/"
reading_time: true
categories:
  - datasets
  - llmops
---

⏱️ **예상 읽기 시간**: 8분

![dots.ocr 통합 문서 파싱 개요]({{ '/assets/images/dots-ocr-multilingual-document-parsing-guide-hero.webp' | relative_url }})

## 서론

문서 파싱 분야에서 혁신적인 변화가 일어나고 있습니다. 전통적으로 문서 레이아웃 감지와 텍스트 인식은 여러 개의 독립적인 모델이 파이프라인 형태로 연결되어 처리되었습니다. 하지만 RedNote의 연구팀이 공개한 **dots.ocr**은 단일 비전-언어 모델(VLM)로 이 모든 작업을 통합하면서도 SOTA(State-of-the-Art) 성능을 달성했습니다.

특히 주목할 점은 1.7B 파라미터라는 상대적으로 작은 모델 크기로도 Doubao-1.5나 Gemini 2.5 Pro와 같은 대형 모델과 비교할 만한 성능을 보여준다는 것입니다. 이는 효율성과 성능을 동시에 추구하는 실용적 AI 시스템 설계의 훌륭한 사례입니다.

## dots.ocr의 핵심 특징

### 1. 통합 아키텍처의 혁신

dots.ocr의 가장 큰 혁신은 **단일 비전-언어 모델**로 다음 작업들을 동시에 수행한다는 점입니다:

- **레이아웃 감지**: 텍스트, 표, 이미지, 수식 등의 영역 식별
- **텍스트 인식**: OCR을 통한 정확한 텍스트 추출
- **읽기 순서**: 인간이 읽는 순서대로 요소 정렬
- **포맷 변환**: Markdown, HTML, LaTeX 등 적절한 형식으로 출력

기존의 복잡한 멀티모델 파이프라인을 단순한 프롬프트 변경만으로 다양한 작업 모드로 전환할 수 있습니다.

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
<div class="d3-arch" data-arch-root id="gualdocumentparsingguide-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 711, "height": 630, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "IN", "x": 286, "y": 24, "w": 156, "h": 46, "title": "Image or PDF input"}, {"id": "VLM", "x": 289, "y": 148, "w": 149, "h": 46, "title": "dots.ocr 1.7B VLM"}, {"id": "L", "x": 537, "y": 272, "w": 142, "h": 46, "title": "Layout Detection"}, {"id": "O", "x": 312, "y": 272, "w": 170, "h": 46, "title": "Text Recognition OCR"}, {"id": "R", "x": 136, "y": 272, "w": 121, "h": 46, "title": "Reading Order"}, {"id": "F", "x": 24, "y": 404, "w": 149, "h": 46, "title": "Format Conversion"}, {"id": "J", "x": 295, "y": 396, "w": 205, "h": 62, "title": ["Structured JSON with bbox", "and 11 categories"]}, {"id": "OUT", "x": 142, "y": 536, "w": 212, "h": 62, "title": ["Markdown or HTML tables or", "LaTeX formulas"]}], "edges": [{"src": "IN", "dst": "VLM", "kind": "data", "line": [364, 70, 364, 148]}, {"src": "VLM", "dst": "L", "kind": "data", "curve": [[438, 190], [608, 233], [608, 233], [608, 272]]}, {"src": "VLM", "dst": "O", "kind": "data", "curve": [[376, 194], [397, 233], [397, 233], [397, 272]]}, {"src": "VLM", "dst": "R", "kind": "data", "curve": [[302, 194], [197, 233], [197, 233], [197, 272]]}, {"src": "VLM", "dst": "F", "kind": "data", "curve": [[289, 188], [99, 233], [99, 357], [99, 404]]}, {"src": "L", "dst": "J", "kind": "data", "curve": [[608, 318], [608, 357], [608, 357], [490, 396]]}, {"src": "O", "dst": "J", "kind": "data", "line": [397, 318, 397, 396]}, {"src": "R", "dst": "J", "kind": "data", "curve": [[197, 318], [197, 357], [197, 357], [308, 396]]}, {"src": "F", "dst": "OUT", "kind": "data", "curve": [[99, 450], [99, 497], [99, 497], [182, 536]]}, {"src": "J", "dst": "OUT", "kind": "data", "curve": [[397, 458], [397, 497], [397, 497], [314, 536]]}]});
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
      const container = document.getElementById('gualdocumentparsingguide-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'gualdocumentparsingguide-1';
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

위 구조에서 보듯 하나의 VLM이 레이아웃 감지부터 포맷 변환까지 전 과정을 담당하며, 프롬프트만 바꾸면 레이아웃 전용, OCR 전용, 특정 영역 분석 등으로 모드가 전환됩니다.

### 2. 뛰어난 다국어 지원

dots.ocr은 저자원 언어를 포함한 다국어 문서 파싱에서 결정적인 우위를 보여줍니다:

```text
지원 언어 예시:
- 영어 (English)
- 중국어 (Chinese)
- 티베트어 (Tibetan)
- 네덜란드어 (Dutch)
- 칸나다어 (Kannada)
- 러시아어 (Russian)
```

이는 글로벌 비즈니스 환경에서 다양한 언어로 작성된 문서를 처리해야 하는 기업들에게 매우 유용한 기능입니다.

## 벤치마크 성능 분석

### OmniDocBench 결과

dots.ocr은 OmniDocBench에서 다음과 같은 SOTA 성능을 달성했습니다:

| 작업 영역 | dots.ocr 성능 | 비교 대상 |
|---------|-------------|----------|
| 텍스트 인식 | SOTA | 기존 OCR 모델들 |
| 표 인식 | SOTA | 전문 표 인식 모델들 |
| 읽기 순서 | SOTA | 레이아웃 분석 모델들 |
| 수식 인식 | Doubao-1.5/Gemini2.5-Pro 수준 | 대형 VLM들 |

### 다국어 성능 우위

자체 다국어 벤치마크인 **dots.ocr-bench**에서는 레이아웃 감지와 콘텐츠 인식 모두에서 결정적 우위를 보여주었습니다. 이는 기존 모델들이 주로 영어와 중국어에 최적화되어 있던 것과 달리, 다양한 언어에 대한 강력한 일반화 능력을 의미합니다.

## 실제 구현 및 활용법

### 1. 환경 설정

먼저 dots.ocr을 사용하기 위한 환경을 설정해보겠습니다:

```bash
# 모델 다운로드 및 등록
python3 tools/download_model.py
export hf_model_path=./weights/DotsOCR
export PYTHONPATH=$(dirname "$hf_model_path"):$PYTHONPATH

# vLLM 서버 설정 (주의: 디렉토리명에 점(.) 사용 금지)
sed -i '/^from vllm\.entrypoints\.cli\.main import main$/a\
from DotsOCR import modeling_dots_ocr_vllm' `which vllm`
```

### 2. vLLM 서버 실행

```bash
# GPU 메모리 최적화된 vLLM 서버 실행
CUDA_VISIBLE_DEVICES=0 vllm serve ${hf_model_path} \
  --tensor-parallel-size 1 \
  --gpu-memory-utilization 0.95 \
  --chat-template-content-format string \
  --served-model-name model \
  --trust-remote-code
```

### 3. 다양한 파싱 모드 활용

dots.ocr의 강력함은 단일 모델로 다양한 작업을 수행할 수 있다는 점입니다:

#### 전체 레이아웃 분석 및 인식
```bash
# 이미지 파일 파싱
python3 dots_ocr/parser.py demo/demo_image1.jpg

# PDF 파일 파싱 (대용량 PDF의 경우 스레드 수 증가)
python3 dots_ocr/parser.py demo/demo_pdf1.pdf --num_thread 64
```

#### 레이아웃 감지만
```bash
python3 dots_ocr/parser.py demo/demo_image1.jpg --prompt prompt_layout_only_en
```

#### 텍스트 추출만 (헤더/푸터 제외)
```bash
python3 dots_ocr/parser.py demo/demo_image1.jpg --prompt prompt_ocr
```

#### 특정 영역 분석
```bash
# 바운딩 박스 지정으로 특정 영역만 분석
python3 dots_ocr/parser.py demo/demo_image1.jpg \
  --prompt prompt_grounding_ocr \
  --bbox 163 241 1536 705
```

### 4. HuggingFace Transformers 기반 사용법

vLLM 대신 HuggingFace Transformers를 사용하고 싶다면:

```python
import torch
from transformers import AutoModelForCausalLM, AutoProcessor
from qwen_vl_utils import process_vision_info

# 모델 로드
model_path = "./weights/DotsOCR"
model = AutoModelForCausalLM.from_pretrained(
    model_path,
    attn_implementation="flash_attention_2",
    torch_dtype=torch.bfloat16,
    device_map="auto",
    trust_remote_code=True
)
processor = AutoProcessor.from_pretrained(model_path, trust_remote_code=True)

# 프롬프트 설정
prompt = """Please output the layout information from the PDF image, 
including each layout element's bbox, its category, and the corresponding 
text content within the bbox.

1. Bbox format: [x1, y1, x2, y2]
2. Layout Categories: ['Caption', 'Footnote', 'Formula', 'List-item', 
   'Page-footer', 'Page-header', 'Picture', 'Section-header', 'Table', 'Text', 'Title']
3. Text Extraction & Formatting Rules:
   - Picture: Text field omitted
   - Formula: LaTeX format
   - Table: HTML format
   - Others: Markdown format
4. Output: Single JSON object sorted by reading order
"""

# 메시지 구성 및 추론
messages = [{
    "role": "user",
    "content": [
        {"type": "image", "image": "demo/demo_image1.jpg"},
        {"type": "text", "text": prompt}
    ]
}]

# 추론 실행
text = processor.apply_chat_template(messages, tokenize=False, add_generation_prompt=True)
image_inputs, video_inputs = process_vision_info(messages)
inputs = processor(text=[text], images=image_inputs, videos=video_inputs, 
                  padding=True, return_tensors="pt").to("cuda")

generated_ids = model.generate(**inputs, max_new_tokens=24000)
output_text = processor.batch_decode(
    [out_ids[len(in_ids):] for in_ids, out_ids in zip(inputs.input_ids, generated_ids)],
    skip_special_tokens=True, clean_up_tokenization_spaces=False
)
```

## 출력 결과 분석

dots.ocr은 다음과 같은 형태의 구조화된 결과를 제공합니다:

### 1. JSON 구조화 데이터
- **바운딩 박스**: 각 요소의 정확한 위치 좌표
- **카테고리**: 11개 레이아웃 카테고리 자동 분류
- **텍스트 내용**: 요소별 추출된 텍스트

### 2. 마크다운 변환
- 모든 감지된 셀의 텍스트를 연결한 마크다운 파일
- 벤치마크 호환성을 위한 헤더/푸터 제외 버전 제공

### 3. 시각화 결과
- 원본 이미지에 감지된 레이아웃 바운딩 박스 오버레이

## 성능 최적화 및 주의사항

### 최적 성능을 위한 권장사항

#### 이미지 해상도 최적화
```bash
# PDF 파싱 시 DPI 설정 (권장: 200 DPI)
# 최적 해상도: 11,289,600 픽셀 이하
```

#### GPU 메모리 최적화
```bash
# vLLM 서버 실행 시 GPU 메모리 활용률 조정
--gpu-memory-utilization 0.95  # 필요에 따라 조정
```

### 알려진 제약사항

#### 1. 복잡한 문서 요소
- **고복잡도 표**: 현재 완벽하지 않음
- **수식**: 복잡한 수학 공식의 경우 정확도 제한
- **이미지**: 문서 내 이미지는 현재 파싱되지 않음

#### 2. 파싱 실패 조건
- 문자-픽셀 비율이 과도하게 높은 경우
- 연속된 특수문자(`...`, `___`)로 인한 무한 반복 출력

#### 3. 대안 프롬프트 활용
문제 발생 시 다음 프롬프트들을 시도해보세요:
- `prompt_layout_only_en`: 레이아웃 감지만
- `prompt_ocr`: 텍스트 추출만
- `prompt_grounding_ocr`: 특정 영역 분석

## 실무 활용 시나리오

### 1. 다국어 기업 문서 관리
```python
# 다국어 계약서, 보고서 일괄 처리
for document in multilingual_documents:
    result = parse_document(document, language="auto")
    structured_data = extract_structured_info(result)
    store_to_database(structured_data)
```

### 2. 학술 논문 데이터베이스 구축
```python
# 수식과 표가 포함된 논문 자동 파싱
papers = load_academic_papers()
for paper in papers:
    layout_info = dots_ocr.parse(paper, mode="academic")
    formulas = extract_latex_formulas(layout_info)
    tables = extract_html_tables(layout_info)
    create_searchable_index(formulas, tables)
```

### 3. 법률 문서 디지털화
```python
# 복잡한 법률 문서의 구조화
legal_docs = load_legal_documents()
for doc in legal_docs:
    parsed = dots_ocr.parse(doc, preserve_reading_order=True)
    sections = identify_legal_sections(parsed)
    create_legal_knowledge_base(sections)
```

## 미래 발전 방향

RedNote 연구팀은 다음과 같은 개선 사항을 계획하고 있습니다:

### 단기 목표
- **표 및 수식 파싱 정확도 향상**
- **대용량 PDF 처리 성능 최적화**
- **문서 내 이미지 파싱 기능 추가**

### 장기 비전
- **범용 인식 모델**: 일반 감지, 이미지 캡셔닝, OCR 통합
- **더 강력하고 효율적인 모델**: 성능과 효율성 동시 개선
- **커뮤니티 협업**: 오픈소스 기여를 통한 발전

## 결론

dots.ocr은 문서 파싱 분야에서 패러다임 전환을 보여주는 혁신적인 모델입니다. 1.7B 파라미터라는 비교적 작은 크기로도 SOTA 성능을 달성하면서, 동시에 실용적인 배포 가능성을 입증했습니다.

특히 **단일 모델로 다양한 작업 수행**, **뛰어난 다국어 지원**, **효율적인 아키텍처**라는 세 가지 핵심 강점은 실무 환경에서의 광범위한 활용 가능성을 시사합니다.

다국어 문서 처리, 학술 자료 디지털화, 법률 문서 관리 등 다양한 분야에서 dots.ocr의 활용을 통해 업무 효율성을 크게 향상시킬 수 있을 것으로 기대됩니다. 앞으로의 발전 방향도 명확하게 제시되어 있어, 지속적인 개선을 통해 더욱 강력한 도구로 발전할 것으로 전망됩니다.

---

**참고 자료**
- [dots.ocr GitHub Repository](https://github.com/rednote-hilab/dots.ocr)
- [HuggingFace Model Hub](https://huggingface.co/models?search=dots.ocr)
- [OmniDocBench 공식 문서](https://omnidocbench.github.io/)