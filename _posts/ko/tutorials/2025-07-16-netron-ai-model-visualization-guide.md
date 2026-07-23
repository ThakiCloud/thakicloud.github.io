---
title: "Netron: AI 모델 시각화 완전 가이드 - PyTorch, TensorFlow, ONNX 모델 분석"
excerpt: "macOS에서 Netron을 활용하여 다양한 AI 모델(PyTorch, TensorFlow, ONNX)을 시각화하고 분석하는 완전한 실습 가이드"
seo_title: "Netron AI 모델 시각화 도구 완전 가이드 macOS PyTorch TensorFlow - Thaki Cloud"
seo_description: "Netron으로 AI 모델을 시각화하세요. PyTorch, TensorFlow, ONNX 모델 구조를 직관적으로 분석하고 디버깅하는 방법을 실습과 함께 학습합니다"
date: 2025-07-16
last_modified_at: 2025-07-16
tags:
  - Netron
  - AI
  - 모델시각화
  - PyTorch
  - TensorFlow
  - ONNX
  - 딥러닝
  - 머신러닝
  - 모델분석
  - 신경망
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/tutorials/netron-ai-model-visualization-guide/"
reading_time: true
published: false
categories:
  - tutorials
---

⏱️ **예상 읽기 시간**: 15분

## 서론

딥러닝 모델을 개발하거나 분석할 때, 모델의 구조를 시각적으로 이해하는 것은 매우 중요합니다. **Netron**은 다양한 AI 모델 포맷을 지원하는 오픈소스 시각화 도구로, 복잡한 신경망 구조를 직관적으로 분석할 수 있게 해줍니다.

이번 튜토리얼에서는 macOS 환경에서 Netron을 설치하고, PyTorch, TensorFlow, ONNX 등 다양한 모델 포맷을 시각화하는 방법을 실습해보겠습니다.

### 🎯 학습 목표

- Netron 도구의 특징과 장점 이해
- macOS에서 다양한 방법으로 Netron 설치
- PyTorch, TensorFlow, ONNX 모델 생성 및 시각화
- 모델 구조 분석 및 디버깅 방법 학습

## Netron 소개

### 📊 주요 특징

**Netron**은 Lutz Roeder가 개발한 신경망 모델 시각화 도구입니다:

- **📋 광범위한 포맷 지원**: ONNX, TensorFlow Lite, Core ML, Keras, Caffe, PyTorch 등
- **🌐 크로스 플랫폼**: macOS, Windows, Linux, 웹 브라우저
- **🎨 직관적 인터페이스**: 드래그 앤 드롭으로 간편한 모델 로딩
- **🔍 상세한 분석**: 레이어별 파라미터, 텐서 형태, 연산 정보 제공
- **🚀 빠른 렌더링**: 대용량 모델도 빠르게 시각화

### 🏗️ 지원 모델 포맷

| 포맷 | 지원 수준 | 주요 용도 |
|------|-----------|-----------|
| **ONNX** | ✅ 완전 지원 | 범용 모델 교환 |
| **TensorFlow Lite** | ✅ 완전 지원 | 모바일/엣지 배포 |
| **Keras** | ✅ 완전 지원 | 고수준 API 모델 |
| **PyTorch** | 🔄 ONNX 변환 | 연구용 모델 |
| **Core ML** | ✅ 완전 지원 | iOS/macOS 배포 |
| **Caffe** | ✅ 완전 지원 | 클래식 프레임워크 |
| **TensorFlow** | 🧪 실험적 지원 | 대규모 프로덕션 |

### 🔄 시각화 워크플로우

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
<div class="d3-arch" data-arch-root id="imodelvisualizationguide-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 584, "height": 618, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 257, "y": 24, "w": 120, "h": 46, "title": "AI 모델 개발"}, {"id": "B", "x": 248, "y": 148, "w": 138, "h": 52, "title": "모델 포맷"}, {"id": "C", "x": 374, "y": 292, "w": 120, "h": 46, "title": "ONNX 변환"}, {"id": "D", "x": 199, "y": 292, "w": 120, "h": 46, "title": "Keras/TFLite"}, {"id": "E", "x": 24, "y": 292, "w": 120, "h": 46, "title": "직접 로딩"}, {"id": "F", "x": 199, "y": 416, "w": 120, "h": 46, "title": "Netron 시각화"}, {"id": "G", "x": 432, "y": 540, "w": 120, "h": 46, "title": "구조 분석"}, {"id": "H", "x": 257, "y": 540, "w": 120, "h": 46, "title": "성능 최적화"}, {"id": "I", "x": 82, "y": 540, "w": 120, "h": 46, "title": "디버깅"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [317, 70, 317, 148]}, {"src": "B", "dst": "C", "kind": "data", "label": "PyTorch", "curve": [[359, 200], [434, 246], [434, 246], [434, 292]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "TensorFlow", "curve": [[296, 200], [259, 246], [259, 246], [259, 292]], "off": "50%"}, {"src": "B", "dst": "E", "kind": "data", "label": "ONNX", "curve": [[248, 195], [84, 246], [84, 246], [84, 292]], "off": "50%"}, {"src": "C", "dst": "F", "kind": "data", "curve": [[434, 338], [434, 377], [434, 377], [319, 418]]}, {"src": "D", "dst": "F", "kind": "data", "line": [259, 338, 259, 416]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[84, 338], [84, 377], [84, 377], [199, 418]]}, {"src": "F", "dst": "G", "kind": "data", "curve": [[319, 455], [492, 501], [492, 501], [492, 540]]}, {"src": "F", "dst": "H", "kind": "data", "curve": [[280, 462], [317, 501], [317, 501], [317, 540]]}, {"src": "F", "dst": "I", "kind": "data", "curve": [[215, 462], [142, 501], [142, 501], [142, 540]]}]});
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
      const container = document.getElementById('imodelvisualizationguide-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'imodelvisualizationguide-1';
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

## 개발환경 준비

### 💻 테스트 환경 정보

```bash
# 시스템 정보
macOS: Sonoma 14.x
Python: 3.12.8
PyTorch: 2.7.0
TensorFlow: 2.19.0
Netron: 8.4.4
```

### 🛠️ Netron 설치 방법

#### 방법 1: Homebrew로 GUI 앱 설치

```bash
# Homebrew를 통한 설치 (권장)
brew install --cask netron

# 설치 확인
ls -la /Applications/Netron.app
```

#### 방법 2: Python 패키지 설치

```bash
# pip를 통한 설치
pip3 install netron

# 버전 확인
python3 -c "import netron; print(netron.__version__)"
```

#### 방법 3: 온라인 브라우저 버전

브라우저에서 [https://netron.app](https://netron.app)에 접속하여 즉시 사용 가능합니다.

**설치 결과**:
```
🍺  netron was successfully installed!
Successfully installed netron-8.4.4
```

## 실습: 다양한 모델 생성 및 시각화

### 🧪 테스트 모델 생성

실제 테스트를 위한 다양한 AI 모델을 생성해보겠습니다:

```python
#!/usr/bin/env python3
"""
Netron AI 모델 시각화 테스트 스크립트
"""

import torch
import torch.nn as nn
import torch.onnx
import tensorflow as tf
import numpy as np
import os

class SimpleNet(nn.Module):
    """간단한 CNN 모델 (PyTorch)"""
    def __init__(self):
        super(SimpleNet, self).__init__()
        self.conv1 = nn.Conv2d(3, 16, 3, padding=1)
        self.relu1 = nn.ReLU()
        self.pool1 = nn.MaxPool2d(2, 2)
        self.conv2 = nn.Conv2d(16, 32, 3, padding=1)
        self.relu2 = nn.ReLU()
        self.pool2 = nn.MaxPool2d(2, 2)
        self.fc1 = nn.Linear(32 * 8 * 8, 128)
        self.relu3 = nn.ReLU()
        self.fc2 = nn.Linear(128, 10)
        
    def forward(self, x):
        x = self.pool1(self.relu1(self.conv1(x)))
        x = self.pool2(self.relu2(self.conv2(x)))
        x = x.view(x.size(0), -1)
        x = self.relu3(self.fc1(x))
        x = self.fc2(x)
        return x

def create_pytorch_model():
    """PyTorch 모델 생성 및 ONNX 변환"""
    print("🧪 PyTorch 모델 생성 중...")
    
    model = SimpleNet()
    model.eval()
    
    # 더미 입력 데이터
    dummy_input = torch.randn(1, 3, 32, 32)
    
    # PyTorch 모델 저장
    torch.save(model.state_dict(), 'simple_model.pth')
    print("✅ PyTorch 모델 저장 완료: simple_model.pth")
    
    # ONNX 변환
    torch.onnx.export(
        model,
        dummy_input,
        'simple_model.onnx',
        export_params=True,
        opset_version=11,
        do_constant_folding=True,
        input_names=['input'],
        output_names=['output'],
        dynamic_axes={
            'input': {0: 'batch_size'},
            'output': {0: 'batch_size'}
        }
    )
    print("✅ ONNX 모델 변환 완료: simple_model.onnx")
    return True

def create_tensorflow_model():
    """TensorFlow 모델 생성"""
    print("🧪 TensorFlow 모델 생성 중...")
    
    model = tf.keras.Sequential([
        tf.keras.layers.Conv2D(16, 3, activation='relu', 
                               input_shape=(32, 32, 3)),
        tf.keras.layers.MaxPooling2D(),
        tf.keras.layers.Conv2D(32, 3, activation='relu'),
        tf.keras.layers.MaxPooling2D(),
        tf.keras.layers.Flatten(),
        tf.keras.layers.Dense(128, activation='relu'),
        tf.keras.layers.Dense(10, activation='softmax')
    ])
    
    model.compile(
        optimizer='adam',
        loss='sparse_categorical_crossentropy',
        metrics=['accuracy']
    )
    
    # Keras 모델 저장
    model.save('simple_model.keras')
    print("✅ Keras 모델 저장 완료: simple_model.keras")
    
    # TensorFlow Lite 변환
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    tflite_model = converter.convert()
    
    with open('simple_model.tflite', 'wb') as f:
        f.write(tflite_model)
    print("✅ TensorFlow Lite 모델 변환 완료: simple_model.tflite")
    
    return True
```

### 📊 모델 생성 실행 결과

```bash
python3 test_netron_models.py
```

**실행 결과**:
```
🎯 Netron AI 모델 시각화 도구 테스트
============================================================
📍 작업 디렉토리: /Users/hanhyojung/thaki/thaki.github.io/netron-test
🐍 PyTorch 버전: 2.7.0
🔥 TensorFlow 버전: 2.19.0

🎯 Netron 테스트용 모델 생성 시작
==================================================
🧪 PyTorch 모델 생성 중...
✅ PyTorch 모델 저장 완료: simple_model.pth
✅ ONNX 모델 변환 완료: simple_model.onnx
🧪 TensorFlow 모델 생성 중...
✅ Keras 모델 저장 완료: simple_model.keras
✅ TensorFlow Lite 모델 변환 완료: simple_model.tflite

📋 모델 상세 정보
==================================================

ONNX 모델:
  📁 파일명: simple_model.onnx
  📊 크기: 1,076,602 bytes (1051.4 KB)
  📍 경로: /Users/hanhyojung/thaki/thaki.github.io/netron-test/simple_model.onnx
  🔧 ONNX 버전: 6
  🏗️ 그래프 노드 수: 16

Keras 모델:
  📁 파일명: simple_model.keras
  📊 크기: 648,022 bytes (632.8 KB)
  📍 경로: /Users/hanhyojung/thaki/thaki.github.io/netron-test/simple_model.keras

TensorFlow Lite 모델:
  📁 파일명: simple_model.tflite
  📊 크기: 618,284 bytes (603.8 KB)
  📍 경로: /Users/hanhyojung/thaki/thaki.github.io/netron-test/simple_model.tflite
```

## Netron 시각화 방법

### 🖥️ GUI 애플리케이션 사용

#### Netron.app 실행
```bash
# 애플리케이션 실행
open /Applications/Netron.app

# 또는 Finder에서 실행
# Applications > Netron.app
```

#### 모델 파일 로딩
1. **드래그 앤 드롭**: 모델 파일을 Netron 창에 끌어다 놓기
2. **파일 메뉴**: File > Open에서 모델 파일 선택
3. **더블 클릭**: .onnx, .keras 파일을 더블 클릭하여 바로 열기

### 🌐 브라우저 버전 사용

#### 온라인 버전
```bash
# 브라우저에서 접속
open https://netron.app
```

#### 로컬 서버 실행
```bash
# Python에서 로컬 서버 시작
python3 -c "import netron; netron.start('simple_model.onnx')"

# 또는 포트 지정
python3 -c "import netron; netron.start('simple_model.onnx', port=8080)"
```

### 📱 명령어 인터페이스

#### 각 모델별 시각화 명령어

```bash
# ONNX 모델 시각화
netron simple_model.onnx

# Keras 모델 시각화  
netron simple_model.keras

# TensorFlow Lite 모델 시각화
netron simple_model.tflite

# Python에서 실행
python3 -c "import netron; netron.start('simple_model.onnx')"
```

## 모델 분석 실습

### 🔍 ONNX 모델 분석

#### 모델 구조 정보
- **입력 텐서**: input (1×3×32×32) - RGB 이미지
- **출력 텐서**: output (1×10) - 10개 클래스 분류
- **총 레이어 수**: 16개 노드
- **파라미터 수**: 약 1.05MB

#### 주요 레이어 분석
1. **Conv2d_0**: 3→16 채널, 3×3 커널
2. **Relu_1**: ReLU 활성화 함수
3. **MaxPool_2**: 2×2 풀링, stride=2
4. **Conv2d_3**: 16→32 채널, 3×3 커널
5. **Gemm_14**: 완전연결층 (2048→128)
6. **Gemm_16**: 출력층 (128→10)

### 🧠 Keras 모델 분석

#### 모델 아키텍처
```python
Model: "sequential"
_________________________________________________________________
Layer (type)                Output Shape              Param #   
=================================================================
conv2d (Conv2D)            (None, 30, 30, 16)        448       
max_pooling2d (MaxPooling2D) (None, 15, 15, 16)      0         
conv2d_1 (Conv2D)          (None, 13, 13, 32)        4640      
max_pooling2d_1 (MaxPooling2D) (None, 6, 6, 32)      0         
flatten (Flatten)          (None, 1152)              0         
dense (Dense)              (None, 128)               147584    
dense_1 (Dense)            (None, 10)                1290      
=================================================================
Total params: 153,962
Trainable params: 153,962
Non-trainable params: 0
```

### 📱 TensorFlow Lite 분석

#### 최적화 효과
- **원본 Keras**: 632.8 KB
- **TFLite 변환**: 603.8 KB  
- **압축률**: 4.6% 감소
- **양자화**: 없음 (fp32 유지)

#### 모바일 최적화 특징
- **연산자 융합**: 일부 레이어가 단일 연산으로 결합
- **메모리 효율화**: 중간 텐서 재사용 최적화
- **하드웨어 가속**: GPU/NPU 지원 준비

## 실전 활용 사례

### 🛠️ 모델 디버깅

#### 1. 차원 불일치 문제 해결
```python
# 문제 상황: 예상과 다른 출력 차원
# Netron에서 각 레이어의 출력 shape 확인
# → Conv2D 출력이 예상과 다름 발견
# → padding 설정 수정 필요
```

#### 2. 레이어 연결 오류 발견
```python
# Netron 시각화를 통해 발견 가능한 문제들:
# - Skip connection 누락
# - 잘못된 레이어 순서
# - Activation function 누락
# - Batch normalization 위치 오류
```

### 🚀 성능 최적화

#### 1. 모델 경량화 전후 비교
```bash
# 원본 모델
netron original_model.onnx

# 프루닝 후 모델  
netron pruned_model.onnx

# 양자화 후 모델
netron quantized_model.onnx
```

#### 2. 병목 구간 식별
- **파라미터 수가 많은 레이어**: Dense, Large Conv2D
- **계산량이 많은 연산**: MatMul, Convolution
- **메모리 사용량**: 중간 텐서 크기 분석

### 📊 모델 비교 분석

#### 아키텍처 비교
```python
# 같은 작업을 위한 다른 모델들 비교
models = [
    'resnet18.onnx',      # ResNet 아키텍처
    'mobilenet_v2.onnx',  # MobileNet 아키텍처  
    'efficientnet.onnx'   # EfficientNet 아키텍처
]

for model in models:
    # Netron으로 구조 비교
    # 파라미터 수, 레이어 깊이, 연산량 분석
```

## 고급 활용 팁

### 🎨 시각화 커스터마이징

#### 1. 레이어 그룹화
- **기능별 색상 구분**: Conv → 파란색, Dense → 녹색
- **블록 단위 접기**: ResNet Block, Inception Module
- **관심 영역 확대**: 특정 레이어 상세 분석

#### 2. 메타데이터 활용
```python
# ONNX 모델에 메타데이터 추가
import onnx

model = onnx.load('model.onnx')
model.metadata_props.append(
    onnx.StringStringEntryProto(key='author', value='Thaki Cloud')
)
model.metadata_props.append(
    onnx.StringStringEntryProto(key='description', value='CNN for CIFAR-10')
)
onnx.save(model, 'model_with_metadata.onnx')
```

### 🔧 자동화 스크립트

#### 배치 시각화 스크립트
```bash
#!/bin/bash
# 여러 모델을 자동으로 시각화

models_dir="./models"
output_dir="./visualizations"

for model_file in "$models_dir"/*.onnx; do
    model_name=$(basename "$model_file" .onnx)
    echo "시각화 중: $model_name"
    
    # HTML로 내보내기 (Netron 8.4.4+)
    python3 -c "
import netron
import sys
netron.serve('$model_file', browse=False, port=8080)
# 스크린샷 캡처 로직 추가 가능
"
done
```

### 📈 성능 프로파일링

#### 모델 복잡도 분석
```python
def analyze_model_complexity(onnx_path):
    """ONNX 모델의 복잡도 분석"""
    import onnx
    
    model = onnx.load(onnx_path)
    
    # 노드 타입별 통계
    node_types = {}
    for node in model.graph.node:
        op_type = node.op_type
        node_types[op_type] = node_types.get(op_type, 0) + 1
    
    # 파라미터 수 계산
    total_params = 0
    for initializer in model.graph.initializer:
        shape = [dim for dim in initializer.dims]
        params = 1
        for dim in shape:
            params *= dim
        total_params += params
    
    print(f"📊 모델 복잡도 분석")
    print(f"  노드 타입별 통계: {node_types}")
    print(f"  총 파라미터 수: {total_params:,}")
    
    return node_types, total_params
```

## zshrc Aliases 가이드

개발 효율성을 위한 유용한 alias들을 추가하세요:

```bash
# ~/.zshrc에 추가

# Netron 관련 aliases
alias netron-app="open /Applications/Netron.app"
alias netron-online="open https://netron.app"
alias netron-serve="python3 -c 'import netron; netron.serve'"

# 모델 분석 aliases
alias onnx-info="python3 -c 'import onnx; m=onnx.load(\"$1\"); print(f\"Nodes: {len(m.graph.node)}\")'"
alias model-size="ls -lh *.onnx *.keras *.tflite *.pth 2>/dev/null"

# 빠른 시각화 aliases
alias viz-onnx="netron"
alias viz-keras="netron"
alias viz-tflite="netron"

# 개발 환경 aliases
alias torch-ver="python3 -c 'import torch; print(torch.__version__)'"
alias tf-ver="python3 -c 'import tensorflow as tf; print(tf.__version__)'"
alias netron-ver="python3 -c 'import netron; print(netron.__version__)'"

# 모델 생성 테스트
alias test-models="cd ~/netron-test && python3 test_netron_models.py"
```

설정 적용:
```bash
source ~/.zshrc
```

## 트러블슈팅

### 🚨 자주 발생하는 문제들

#### 1. 모델 로딩 실패

**증상**: "Failed to load model" 오류

**해결책**:
```bash
# 파일 형식 확인
file simple_model.onnx

# 파일 권한 확인  
ls -la simple_model.onnx

# ONNX 모델 검증
python3 -c "import onnx; onnx.checker.check_model(onnx.load('simple_model.onnx'))"
```

#### 2. 브라우저에서 열리지 않음

**증상**: `netron.start()` 실행 후 브라우저가 열리지 않음

**해결책**:
```python
# 수동으로 브라우저 열기
import netron
import webbrowser

netron.start('model.onnx', browse=False, port=8080)
webbrowser.open('http://localhost:8080')
```

#### 3. 대용량 모델 시각화 문제

**증상**: 메모리 부족으로 시각화 실패

**해결책**:
```bash
# 메모리 사용량 확인
top -pid $(pgrep python)

# 모델 경량화 후 시각화
python3 -c "
import onnx
from onnx import optimizer

model = onnx.load('large_model.onnx')
optimized = optimizer.optimize(model)
onnx.save(optimized, 'optimized_model.onnx')
"
```

### 🔍 디버깅 도구

#### Netron 로그 확인
```bash
# Python 로그 활성화
export PYTHONPATH=/usr/local/lib/python3.12/site-packages
python3 -c "import logging; logging.basicConfig(level=logging.DEBUG); import netron; netron.start('model.onnx')"
```

#### 모델 호환성 확인
```python
def check_model_compatibility(model_path):
    """모델 호환성 확인"""
    import os
    
    if not os.path.exists(model_path):
        print(f"❌ 파일이 존재하지 않음: {model_path}")
        return False
    
    file_size = os.path.getsize(model_path)
    if file_size == 0:
        print(f"❌ 빈 파일: {model_path}")
        return False
    
    print(f"✅ 파일 크기: {file_size:,} bytes")
    
    # 확장자별 검증
    if model_path.endswith('.onnx'):
        try:
            import onnx
            model = onnx.load(model_path)
            onnx.checker.check_model(model)
            print("✅ ONNX 모델 검증 통과")
            return True
        except Exception as e:
            print(f"❌ ONNX 검증 실패: {e}")
            return False
    
    # 기타 포맷은 파일 존재 여부만 확인
    return True
```

## 결론

### 🏆 주요 성과

이번 튜토리얼에서 다음과 같은 결과를 얻었습니다:

1. **✅ 다양한 설치 방법 학습**: GUI, Python 패키지, 온라인 버전
2. **✅ 멀티 포맷 지원 확인**: ONNX, Keras, TensorFlow Lite 모델 생성 및 시각화
3. **✅ 실전 활용 방법 습득**: 디버깅, 최적화, 성능 분석 기법
4. **✅ 자동화 도구 구축**: 배치 처리 및 분석 스크립트

### 📊 성능 비교 요약

| 모델 포맷 | 파일 크기 | 로딩 속도 | 시각화 품질 | 호환성 |
|-----------|-----------|-----------|-------------|--------|
| **ONNX** | 1,051 KB | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Keras** | 633 KB | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **TFLite** | 603 KB | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |

### 🔮 확장 가능성

- **CI/CD 통합**: 모델 배포 파이프라인에 시각화 단계 추가
- **협업 도구**: 팀 간 모델 구조 공유 및 리뷰
- **교육 자료**: 딥러닝 개념 설명을 위한 시각적 자료
- **연구 발표**: 논문 및 학회 발표용 모델 다이어그램
- **자동 문서화**: 모델 아키텍처 문서 자동 생성

### 💡 다음 단계

1. **고급 모델 분석**: Transformer, GAN 등 복잡한 아키텍처 시각화
2. **성능 벤치마킹**: 다양한 모델의 추론 성능 비교
3. **커스텀 레이어**: 사용자 정의 연산자 시각화
4. **모델 압축**: 프루닝, 양자화 전후 비교 분석

Netron을 활용하면 복잡한 AI 모델도 직관적으로 이해하고 분석할 수 있습니다. 특히 모델 디버깅과 최적화 과정에서 매우 유용한 도구로 활용할 수 있습니다.

**더 궁금한 점이 있으시면 댓글로 문의해주세요!** 🚀 