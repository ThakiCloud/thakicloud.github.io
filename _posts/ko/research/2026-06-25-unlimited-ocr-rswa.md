---
title: "책 한 권을 한 번에 읽는 OCR: Baidu Unlimited OCR의 상수 KV 캐시 비밀"
excerpt: "Baidu가 공개한 Unlimited OCR은 디코더의 어텐션을 Reference Sliding Window Attention으로 바꿔 KV 캐시를 상수로 유지합니다. 수십 페이지 문서를 한 번의 순전파로 파싱하는 원리와, ThakiCloud 멀티테넌트 추론 관점의 의미를 정리했습니다."
seo_title: "Unlimited OCR R-SWA 상수 KV 캐시 장문 문서 파싱 분석 - Thaki Cloud"
seo_description: "Baidu Unlimited OCR(arXiv 2606.23050)의 Reference Sliding Window Attention 분석. 상수 KV 캐시로 32K 컨텍스트 한 번에 처리, OmniDocBench v1.5 93.23%. ThakiCloud 쿠버네티스 멀티테넌트 문서 추론 적용 관점."
date: 2026-06-25
last_modified_at: 2026-06-25
tags:
  - unlimited-ocr
  - document-parsing
  - sliding-window-attention
  - kv-cache
  - long-context
  - on-premise
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "file-text"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ko/research/unlimited-ocr-rswa/"
reading_time: true
categories:
  - research
audiobook: https://drive.google.com/file/d/1O8jtYL1Xb7S6CW2olgwnsIoIaedrOjDr/view
audiobook_note: "AI 로컬 합성 오디오북 (Qwen3-TTS)"
---

## 개요

문서를 기계가 읽을 수 있는 구조로 바꾸는 작업은 RAG와 에이전트 시대에 다시 핵심으로 떠올랐습니다. 계약서 한 건이 수십 페이지에 달하고, 재무 보고서나 논문은 표와 수식과 다단 레이아웃이 페이지를 가로질러 이어집니다. 이런 긴 문서를 정확한 읽기 순서로 한 번에 풀어내야 LLM이 제대로 활용할 수 있습니다.

문제는 비용입니다. 비전-언어 모델로 문서를 파싱할 때 디코더는 출력 토큰을 하나씩 자기회귀로 생성하는데, 표준 트랜스포머의 풀 어텐션은 시퀀스가 길어질수록 KV 캐시가 선형으로 커집니다. 페이지가 늘면 메모리가 함께 부풀고, 결국 한 번에 처리할 수 있는 문서 길이에 천장이 생깁니다. 그래서 기존 도구 대부분은 문서를 페이지 단위로 잘라 따로 처리한 뒤 다시 이어 붙였고, 이 과정에서 페이지를 넘나드는 표나 단락의 연속성이 깨지곤 했습니다.

Baidu가 공개한 **Unlimited OCR**(arXiv 2606.23050)은 이 천장을 다른 방식으로 걷어냅니다. 디코더의 모든 어텐션 레이어를 Reference Sliding Window Attention(R-SWA)으로 교체해서, 디코딩이 진행되는 내내 KV 캐시 크기를 상수로 유지합니다. 그 결과 32K 컨텍스트 한 번의 순전파로 수십 페이지짜리 문서를 통째로 전사할 수 있습니다. 논문 제목이 말하는 "one-shot long-horizon parsing", 즉 긴 문서를 한 방에 읽는다는 표현이 과장이 아닙니다.

저희 ThakiCloud는 쿠버네티스 기반 AI/ML SaaS 플랫폼에서 멀티테넌트 추론과 문서 처리 워크로드를 직접 운영합니다. 추론 비용의 상당 부분이 KV 캐시 메모리에서 나오는 환경이라, "길이에 상관없이 상수 메모리"라는 설계는 단순한 학술적 호기심이 아니라 서빙 경제성에 직접 닿는 주제입니다. 이번 글에서는 R-SWA가 무엇이고 왜 KV 캐시가 상수로 유지되는지, 그리고 우리 플랫폼 관점에서 어디에 맞는지를 정리합니다.

## Unlimited OCR란 무엇인가

Unlimited OCR은 바닥부터 새로 만든 모델이 아니라, DeepSeek-OCR을 한 단계 더 밀어붙인 모델입니다. DeepSeek-OCR의 강점인 **DeepEncoder**를 그대로 가져와 인코더로 쓰고, 디코더의 어텐션만 R-SWA로 갈아끼웠습니다.

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
<div class="d3-arch" data-arch-root id="20260625unlimitedocrrswa-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 373, "height": 948, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 41, "y": 24, "w": 120, "h": 62, "title": ["입력 문서", "(PDF, 이미지)"]}, {"id": "B", "x": 41, "y": 164, "w": 120, "h": 62, "title": ["SAM-ViT", "특징 추출"]}, {"id": "C", "x": 41, "y": 304, "w": 120, "h": 62, "title": ["CLIP-ViT", "16× 토큰 압축"]}, {"id": "D", "x": 41, "y": 444, "w": 120, "h": 62, "title": ["시각 참조 토큰", "(페이지당 256개)"]}, {"id": "E", "x": 119, "y": 584, "w": 138, "h": 52, "title": "R-SWA 어텐션"}, {"id": "F", "x": 216, "y": 444, "w": 120, "h": 62, "title": ["슬라이딩 윈도우", "최근 생성 텍스트"]}, {"id": "G", "x": 27, "y": 714, "w": 156, "h": 62, "title": ["MoE 디코더", "3B 파라미터 / ~500M 활성"]}, {"id": "H", "x": 221, "y": 854, "w": 120, "h": 62, "title": ["상수 KV 캐시", "(길이 무관)"]}, {"id": "I", "x": 24, "y": 854, "w": 142, "h": 62, "title": ["출력 텍스트", "(Markdown / 구조화)"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [101, 86, 101, 164]}, {"src": "B", "dst": "C", "kind": "data", "line": [101, 226, 101, 304]}, {"src": "C", "dst": "D", "kind": "data", "line": [101, 366, 101, 444]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[101, 506], [101, 545], [101, 545], [153, 584]]}, {"src": "F", "dst": "E", "kind": "data", "curve": [[276, 506], [276, 545], [276, 545], [223, 584]]}, {"src": "E", "dst": "G", "kind": "data", "curve": [[155, 636], [105, 675], [105, 675], [105, 714]]}, {"src": "G", "dst": "H", "kind": "data", "line": [146, 776, 244, 854]}, {"src": "G", "dst": "I", "kind": "data", "line": [101, 776, 95, 854]}, {"src": "H", "dst": "E", "kind": "event", "label": "유지", "curve": [[285, 854], [291, 815], [291, 675], [229, 636]], "off": "50%"}]});
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
      const container = document.getElementById('20260625unlimitedocrrswa-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '20260625unlimitedocrrswa-1';
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

*DeepEncoder가 페이지를 256개 시각 토큰으로 압축하고, R-SWA 디코더가 상수 KV 캐시로 긴 문서를 한 번에 전사합니다. 도표를 클릭하면 크게 볼 수 있습니다.*
*고압축 인코더가 페이지를 소수의 시각 토큰으로 줄이고, R-SWA 디코더가 상수 KV 캐시로 긴 출력을 생성합니다.*

**인코더(DeepEncoder)**: SAM-ViT와 CLIP-ViT를 직렬로 연결한 구조로, 16배 토큰 압축을 적용합니다. 1024×1024 해상도의 PDF 한 페이지가 단 256개의 시각 토큰으로 압축됩니다. 입력 측에서 이미 토큰 수를 크게 줄여 두기 때문에, 디코더가 참조해야 할 시각 정보의 양 자체가 작습니다. 이 고압축 설계가 뒤에 설명할 상수 KV 캐시와 맞물려 장문 처리를 가능하게 합니다.

**디코더(R-SWA를 적용한 LLM)**: 디코더는 3B 규모의 MoE(Mixture of Experts) 구조이며, 활성 파라미터는 약 500M입니다. 토큰마다 전체 3B가 아니라 일부 전문가만 활성화하므로, 파라미터 수에 비해 토큰당 연산이 가볍습니다. 여기에 모든 어텐션 레이어를 R-SWA로 교체한 것이 이 모델의 핵심 차별점입니다.

전체 모델은 약 30억 파라미터 규모이며 BF16 가중치로 공개되었고, 라이선스는 상업적 활용이 자유로운 MIT입니다. 가중치는 허깅페이스 `baidu/Unlimited-OCR`와 ModelScope에서 받을 수 있고, 코드와 함께 GitHub에 공개되었습니다. 공개 시점 기준 단일 중급 NVIDIA GPU 한 장에서 구동할 수 있다고 보고합니다.

이 모델은 앞서 저희가 다룬 PaddleOCR-VL과 같은 Baidu 계열이지만 접근법이 다릅니다. PaddleOCR-VL은 레이아웃 분석과 요소 인식을 두 단계로 분리해 작은 모델로 안정성을 확보한 반면, Unlimited OCR은 종단간 한 모델을 유지하되 어텐션 메커니즘을 바꿔 장문 한 방 처리를 노립니다. 같은 문제를 푸는 두 가지 설계 철학을 비교해 보는 재미가 있습니다.

## 핵심 메커니즘: Reference Sliding Window Attention

R-SWA를 이해하려면 먼저 두 가지 기존 방식의 약점을 봐야 합니다.

**풀 어텐션**은 모든 출력 토큰이 그 앞의 모든 토큰을 다 봅니다. 정확하지만 KV 캐시가 시퀀스 길이에 비례해 커집니다. 페이지가 늘면 메모리가 선형으로 늘어 천장에 부딪힙니다.

**일반 슬라이딩 윈도우 어텐션(SWA)**은 최근 W개의 토큰만 봅니다. KV 캐시가 윈도우 크기로 고정되어 메모리는 상수가 되지만, 윈도우 밖으로 밀려난 정보는 잊습니다. 일반 텍스트 생성에서는 통하지만, OCR처럼 "원본을 보고 그대로 옮겨 적어야 하는" 작업에서는 치명적입니다. 윈도우가 지나가면 어느 페이지를 전사하던 중이었는지 근거를 잃기 때문입니다.

R-SWA는 이 둘을 절충합니다. 핵심 발상은 인간이 긴 문서를 옮겨 적는 방식에서 왔습니다. 사람은 방금 쓴 몇 문장(단기 작업 기억)과, 눈앞에 펼쳐 둔 원본 문서(참조 대상)를 함께 보면서 받아 적습니다. R-SWA의 "Reference"는 바로 이 원본 참조에 해당합니다. 인코더가 만든 고압축 시각 토큰을 항상 참조 가능한 앵커로 유지하면서, 생성되는 텍스트 토큰에 대해서는 슬라이딩 윈도우를 적용합니다.

즉 어텐션이 보는 대상은 두 묶음으로 나뉩니다. 하나는 크기가 고정된 시각 참조 토큰(인코더 출력)이고, 다른 하나는 최근 생성 텍스트의 슬라이딩 윈도우입니다. 두 묶음 모두 길이가 상한으로 묶여 있으므로, 출력이 아무리 길어져도 KV 캐시 총량이 상수로 유지됩니다. 원본을 잊지 않으면서도 메모리는 일정한, 말 그대로 "작업 기억"을 모사한 어텐션입니다.

논문은 R-SWA가 OCR 전용 트릭이 아니라 범용 파싱 어텐션이라고 강조합니다. 긴 입력을 보고 긴 출력을 만들어야 하는 작업, 예컨대 음성 인식(ASR)이나 번역에도 같은 구조를 적용할 수 있다는 것입니다. 입력이라는 참조를 고정 앵커로 두고 출력에 슬라이딩 윈도우를 거는 패턴은 시퀀스-투-시퀀스 문제 전반에 일반화될 여지가 있습니다.

## 벤치마크 결과

성능 수치는 OmniDocBench 기준으로 보고됩니다. OmniDocBench는 본문, 표, 수식, 읽기 순서를 종합적으로 평가하는 문서 파싱 벤치마크입니다.

- **OmniDocBench v1.5 전체 점수 93.23%**: 베이스라인인 DeepSeek-OCR 대비 6.22%포인트 향상입니다.
- **OmniDocBench v1.6 전체 점수 93.92%**: 종단간 방식에서 SOTA로 보고됩니다.

주목할 점은 정확도 향상과 메모리 효율을 동시에 잡았다는 것입니다. 보통 윈도우를 좁혀 메모리를 줄이면 정확도가 떨어지는 트레이드오프가 발생하는데, R-SWA는 시각 참조를 고정 앵커로 유지함으로써 정확도 손실 없이 상수 KV 캐시를 달성했습니다. 페이지를 잘라 따로 처리하지 않고 연속 문서 스트림을 한 번에 흘려보낼 수 있다는 점도 실무적으로 큰 차이를 만듭니다. 페이지 경계에서 끊기는 표나 각주, 다단 본문의 연속성이 보존되기 때문입니다.

다만 위 수치는 모두 논문과 모델 카드가 보고한 값이며, 저희가 직접 재현한 수치는 아닙니다. Unlimited OCR은 3B MoE 모델이라 의미 있는 검증에는 GPU와 모델 다운로드가 필요해, 이번 글은 설계 분석에 초점을 맞췄습니다. 실측 재현은 별도 실험으로 다룰 계획입니다.

## ThakiCloud K8s AI/ML SaaS 플랫폼 적용 및 시사점

저희 ThakiCloud의 플랫폼 관점에서 이 모델이 흥미로운 이유는 명확합니다. 멀티테넌트 추론 서빙에서 가장 다루기 까다로운 자원이 바로 KV 캐시 메모리이기 때문입니다.

**서빙 경제성**: vLLM 같은 서빙 엔진에서 동시 처리 가능한 요청 수, 즉 배치 크기는 GPU 메모리에서 KV 캐시가 차지하는 양에 좌우됩니다. 풀 어텐션 모델은 긴 문서 요청 하나가 KV 캐시를 크게 잡아먹어 동시 처리량을 떨어뜨립니다. 반면 상수 KV 캐시 모델은 문서 길이와 무관하게 요청당 메모리가 예측 가능합니다. 한 장의 청구서든 200페이지 계약서든 같은 메모리 풋프린트로 처리되므로, 워크로드 길이 분포에 흔들리지 않고 배치 크기를 안정적으로 계획할 수 있습니다. 멀티테넌트 환경에서 테넌트별 자원 격리와 용량 산정이 훨씬 단순해집니다.

**온프레미스와 비용 효율**: 가중치가 MIT 라이선스로 공개되어 있고 단일 중급 GPU에서 돌아간다는 점은, 데이터를 외부로 내보낼 수 없는 고객에게 결정적입니다. 금융, 공공, 의료처럼 문서 자체가 민감 정보인 도메인에서는 클라우드 OCR API로 계약서를 올리는 것 자체가 컴플라이언스 위반이 될 수 있습니다. 상수 메모리 설계 덕에 적당한 GPU 한 장으로 장문 문서 파이프라인을 온프레미스에 세울 수 있다면, 저희가 Kueue로 GPU를 스케줄링하고 vLLM으로 서빙하는 스택 위에 자연스럽게 얹힙니다.

**적용 로드맵**: 저희 플랫폼에서 문서 인텔리전스 워크로드는 RAG 인덱싱 전처리와 에이전트의 문서 도구로 들어옵니다. 상수 KV 캐시 OCR은 이 두 경로 모두에서 긴 문서를 청크로 쪼개기 전에 통째로 정확히 파싱하는 1차 관문 역할을 할 수 있습니다. 특히 페이지를 넘나드는 표와 다단 레이아웃이 많은 한국어 공문서와 재무 문서에서, 페이지 분할 없이 연속 처리하는 능력은 후속 RAG 품질에 직접 기여합니다. 앞서 다룬 PaddleOCR-VL의 분리형 안정성과 Unlimited OCR의 장문 한 방 처리를 워크로드 특성에 따라 선택적으로 배치하는 것이 현실적인 운용 전략입니다.

## 한계 및 반론

설계가 우아하다고 해서 모든 상황에 맞는 것은 아닙니다.

**슬라이딩 윈도우의 본질적 제약**: R-SWA가 시각 참조를 앵커로 유지하더라도, 생성 텍스트 측은 여전히 슬라이딩 윈도우입니다. 출력 토큰 사이의 아주 먼 의존성, 예컨대 1페이지에서 정의한 약어를 180페이지에서 일관되게 풀어 쓰는 것 같은 장거리 텍스트 일관성은 시각 참조가 보강한다 해도 풀 어텐션만큼 보장된다고 단정하기 어렵습니다. 이 부분은 직접 재현 실험으로 확인해야 할 지점입니다.

**MoE의 운영 부담**: 3B MoE는 토큰당 연산은 가볍지만, 전문가 전체를 메모리에 올려야 하므로 활성 파라미터(500M)보다 실제 메모리 점유는 큽니다. 또한 MoE는 배치 내 토큰의 전문가 라우팅이 불균형해지면 처리량이 흔들리는 특성이 있어, 서빙 엔진의 MoE 지원 성숙도에 성능이 좌우됩니다.

**벤치마크와 실사용의 간극**: OmniDocBench 점수가 높다고 해서 한국어·아랍어 같은 비라틴 문자, 손글씨, 저품질 스캔, 도장이 겹친 공문서 등 실제 운영 환경의 까다로운 입력에서 같은 수준을 보장하지는 않습니다. 문서 OCR은 벤치마크와 현장의 격차가 특히 큰 영역이며, 도입 전 자사 문서 분포로 별도 평가가 반드시 필요합니다.

**검증의 필요**: 이 글의 모든 수치는 논문과 모델 카드 보고값입니다. 상수 KV 캐시가 실제 서빙에서 약속한 만큼의 처리량 이득을 주는지, 정확도 손실 없이 32K를 채우는지는 저희가 직접 벤치마크해 봐야 확정할 수 있습니다.

그럼에도 "참조를 고정하고 생성에 슬라이딩 윈도우를 건다"는 발상은 장문 시퀀스-투-시퀀스 작업의 메모리 천장을 다루는 깔끔한 한 수입니다. OCR을 넘어 ASR과 번역까지 일반화될 수 있다는 주장이 맞다면, 멀티테넌트 추론 플랫폼을 운영하는 입장에서 계속 지켜볼 가치가 충분합니다.

## 출처

- [Unlimited OCR Works: Welcome the Era of One-shot Long-horizon Parsing (arXiv 2606.23050)](https://arxiv.org/abs/2606.23050)
- [Hugging Face 논문 페이지](https://huggingface.co/papers/2606.23050)
- [baidu/Unlimited-OCR (Hugging Face 모델·가중치)](https://huggingface.co/baidu/Unlimited-OCR)
- [baidu/Unlimited-OCR (GitHub 코드)](https://github.com/baidu/Unlimited-OCR)
