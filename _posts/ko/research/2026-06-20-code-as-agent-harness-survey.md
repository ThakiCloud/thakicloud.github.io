---
title: "코드가 에이전트 하네스다: AI 에이전트 인프라의 세 계층 구조 (arXiv:2605.18747)"
excerpt: "코드가 AI 에이전트 시스템의 기반 인프라로 기능하는 방식을 하네스 인터페이스, 하네스 메커니즘, 멀티에이전트 조율 세 계층으로 체계화한 서베이를 분석한다."
seo_title: "코드 기반 AI 에이전트 하네스 아키텍처 서베이 분석 - Thaki Cloud"
seo_description: "arXiv 2605.18747 Code as Agent Harness 서베이: 에이전트 인프라 3계층, 계획 및 적응 제어, 멀티에이전트 조율, 안전성 과제에 대한 심층 분석"
date: 2026-06-20
last_modified_at: 2026-06-20
tags:
  - ai-agent
  - agent-harness
  - code-agent
  - multi-agent
  - llm
  - arxiv-2605.18747
  - survey
  - agent-infrastructure
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ko/research/code-as-agent-harness-survey/"
reading_time: true
categories:
  - research
audiobook: https://drive.google.com/file/d/1jrZDyEtTFKYNmx8_0TRwXFI_Y_ezagzF/view
audiobook_note: "AI 로컬 합성 오디오북 (Qwen3-TTS)"
published: false
---

⏱️ **예상 읽기 시간**: 8분

## 서베이가 정리한 질문

에이전트 시스템을 구축하다 보면 반복되는 패턴이 있습니다. 에이전트가 환경과 상호작용하는 방식, 계획을 세우고 수정하는 방식, 여러 에이전트가 협력하는 방식. 이 패턴들이 흩어진 논문과 시스템 곳곳에 묻혀 있습니다.

arXiv:2605.18747 "Code as Agent Harness"는 이 패턴들을 하나의 프레임으로 묶습니다. 핵심 주장은 코드가 AI 에이전트 시스템의 기반 인프라로 작동한다는 것입니다. 코드가 에이전트와 추론 엔진을 연결하고, 환경과의 인터페이스를 정의하고, 멀티에이전트 조율을 가능하게 합니다. 이를 세 계층으로 체계화해서 분석한 서베이입니다.

## 3계층 프레임워크

아래 그림은 코드가 추론 엔진과 환경 사이에서 하네스로 작동하며, 그 위에 메커니즘과 조율이 쌓이는 세 계층을 요약합니다.

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
<div class="d3-arch" data-arch-root id="codeasagentharnesssurvey-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 503, "height": 628, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [{"x": 252, "y": 162, "w": 219, "h": 434, "label": "코드 = 에이전트 하네스", "lx": 264, "ly": 180}], "nodes": [{"id": "LLM", "x": 291, "y": 24, "w": 120, "h": 46, "title": "추론 엔진 LLM"}, {"id": "L1", "x": 290, "y": 201, "w": 121, "h": 62, "title": ["1계층 하네스 인터페이스", "LLM·환경 양방향 정의"]}, {"id": "L2", "x": 313, "y": 355, "w": 121, "h": 62, "title": ["2계층 하네스 메커니즘", "계획 수립 + 적응 제어"]}, {"id": "L3", "x": 313, "y": 495, "w": 121, "h": 62, "title": ["3계층 멀티에이전트 조율", "분배·집약·의존성 관리"]}, {"id": "ENV", "x": 24, "y": 355, "w": 191, "h": 62, "title": ["환경", "파일시스템·API·DB·GUI·외부 서비스"]}], "edges": [{"src": "LLM", "dst": "L1", "kind": "data", "label": "\"입출력·툴 시그니처\"", "line": [351, 70, 351, 201], "lx": 351, "ly": 112}, {"src": "L1", "dst": "L2", "kind": "data", "curve": [[360, 263], [373, 309], [373, 309], [373, 355]]}, {"src": "L2", "dst": "L3", "kind": "data", "line": [373, 417, 373, 495]}, {"src": "L1", "dst": "ENV", "kind": "data", "label": "\"실행 레이어\"", "curve": [[340, 263], [324, 309], [324, 309], [202, 355]], "off": "50%"}]});
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
      const container = document.getElementById('codeasagentharnesssurvey-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'codeasagentharnesssurvey-1';
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

### 1계층: 하네스 인터페이스

첫 번째 계층은 에이전트가 추론 엔진(LLM)과 환경 사이에 어떻게 위치하는지를 다룹니다. 코드는 여기서 두 방향의 인터페이스를 동시에 정의합니다.

LLM 방향으로는 모델이 받아야 할 입력 형식, 생성해야 할 출력 형식, 호출 가능한 툴의 시그니처를 정의합니다. 환경 방향으로는 파일 시스템, API, 데이터베이스, GUI, 외부 서비스와 상호작용하는 실행 레이어를 담당합니다.

이 인터페이스 계층이 잘 설계되면 에이전트 로직과 실행 환경이 분리됩니다. 에이전트 로직을 건드리지 않고 실행 환경을 교체할 수 있고, 테스트 환경과 프로덕션 환경을 동일한 에이전트 코드로 구동할 수 있습니다.

### 2계층: 하네스 메커니즘

두 번째 계층은 에이전트가 복잡한 태스크를 수행할 때 사용하는 메커니즘들을 다룹니다. 계획 수립(planning)과 적응 제어(adaptive control)가 중심입니다.

계획은 장기 목표를 단기 실행 가능한 단계로 분해하는 과정입니다. 코드 기반 하네스에서 계획 결과물 자체가 실행 가능한 코드 형태로 나올 때 장점이 있습니다. 계획과 실행 사이의 번역 비용이 줄어듭니다.

적응 제어는 실행 중 발생하는 예외와 실패를 처리하는 방식입니다. 에이전트가 계획대로 실행하다가 예상치 못한 상황을 만나면 어떻게 대응하는가. 재시도, 대안 경로 탐색, 사람에게 에스컬레이션 등의 패턴이 여기에 속합니다.

### 3계층: 멀티에이전트 조율

세 번째 계층은 여러 에이전트가 협력하는 방식을 다룹니다. 단일 에이전트로 해결하기 어려운 태스크를 여러 에이전트에 분배하고, 결과를 집약하고, 에이전트 간 의존성을 관리합니다.

코드가 하네스 역할을 할 때 멀티에이전트 조율이 자연스럽게 표현됩니다. 각 에이전트를 함수나 서비스처럼 다루고, 조율 로직을 일반 프로그래밍 패턴으로 작성할 수 있습니다.

## 응용 영역

서베이는 코딩 어시스턴트, GUI 자동화, 과학적 발견, 기업 워크플로를 주요 응용 영역으로 분석합니다.

**코딩 어시스턴트**: 코드 생성, 버그 수정, 테스트 작성을 에이전트가 수행하는 영역입니다. 코드 실행 결과가 즉각적인 피드백 신호가 되기 때문에 에이전트 학습에 유리한 환경입니다.

**GUI 자동화**: 브라우저, 데스크탑 앱, 모바일 앱을 에이전트가 직접 조작하는 영역입니다. 화면 요소 인식과 상호작용 코드 생성이 핵심입니다.

**과학적 발견**: 실험 설계, 데이터 분석, 결과 해석을 에이전트가 보조하는 영역입니다. 반복 실험과 가설 검증에서 코드 기반 하네스가 유용합니다.

**기업 워크플로**: 여러 SaaS 서비스와 내부 시스템을 연결하는 자동화입니다. API 통합과 데이터 흐름 관리가 주를 이룹니다.

## 미해결 과제들

서베이가 식별한 열린 과제들이 현실적입니다.

**평가 방법**: 에이전트 성능을 어떻게 측정하는가. 단일 태스크 정확도만으로는 부족합니다. 새 환경 적응 속도, 실패 복구 능력, 자원 효율 등 다차원 평가가 필요합니다.

**검증 전략**: 에이전트가 생성한 코드와 계획이 의도한 대로 작동하는지 어떻게 보장하는가. 실행 전 정적 분석, 샌드박스 실행, 형식 검증 등의 조합이 논의됩니다.

**안전성**: 에이전트가 의도하지 않은 부작용을 일으키는 것을 어떻게 막는가. 권한 관리, 실행 격리, 취소 메커니즘이 핵심입니다.

## ThakiCloud 플랫폼 관점

이 서베이의 3계층 프레임워크는 ThakiCloud가 에이전트 플랫폼을 설계할 때 유용한 참조점입니다.

현재 `ai-platform-strategy` 저장소의 구조를 보면 이 계층들이 이미 암묵적으로 존재합니다. `.claude/skills/` 아래 스킬 정의가 하네스 인터페이스에 해당하고, `scripts/` 아래 실행 코드가 하네스 메커니즘을 구현하며, 오케스트레이터 스킬들이 멀티에이전트 조율을 담당합니다.

차이가 있다면, 이 구조가 명시적 아키텍처 결정보다 점진적으로 형성됐다는 점입니다. 서베이의 프레임워크를 적용해 현재 구조를 평가하면 어디가 잘 설계됐고 어디가 취약한지 파악하기 쉬워집니다.

**하네스 인터페이스 관점에서**: 스킬 YAML 프론트매터가 툴 시그니처를 정의하는 방식이 일관성이 있는지 점검할 수 있습니다. `skill-description-quality` 룰이 이 부분을 이미 다루고 있습니다.

**하네스 메커니즘 관점에서**: `pge-loop`와 `dev-loop`가 적응 제어 메커니즘을 구현하고 있습니다. 실패 감지, 재시도, 에스컬레이션 경로가 명확히 정의됐는지 확인할 지점입니다.

**멀티에이전트 조율 관점에서**: 55개 전문 서브에이전트가 존재하지만, 에이전트 간 의존성 그래프가 명시적으로 관리되는지가 확장성의 관건입니다.

## 마치며

"Code as Agent Harness"는 에이전트 시스템을 처음 설계하는 팀에게 유용한 지도입니다. 어떤 문제를 어느 계층에서 다뤄야 하는지, 어떤 패턴이 검증됐는지, 어떤 문제가 아직 열려 있는지를 정리합니다.

서베이 논문의 한계도 있습니다. 각 영역을 폭넓게 다루다 보니 특정 설계 결정에 대한 깊은 분석은 원저 논문을 따로 찾아야 합니다. 하지만 에이전트 인프라를 체계적으로 이해하는 출발점으로서 가치가 있습니다.

원문: [https://arxiv.org/abs/2605.18747](https://arxiv.org/abs/2605.18747)

## 관련 슬라이드

본문 내용을 NotebookLM(`architectural_timeline` 스타일)으로 요약한 슬라이드입니다.

![code-as-agent-harness-survey 슬라이드 1]({{ '/assets/images/code-as-agent-harness-survey-slide-01.webp' | relative_url }})

![code-as-agent-harness-survey 슬라이드 2]({{ '/assets/images/code-as-agent-harness-survey-slide-02.webp' | relative_url }})

![code-as-agent-harness-survey 슬라이드 3]({{ '/assets/images/code-as-agent-harness-survey-slide-03.webp' | relative_url }})

![code-as-agent-harness-survey 슬라이드 4]({{ '/assets/images/code-as-agent-harness-survey-slide-04.webp' | relative_url }})

