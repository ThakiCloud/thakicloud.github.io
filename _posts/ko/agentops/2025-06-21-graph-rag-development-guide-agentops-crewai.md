---
title: "AgentOps와 CrewAI로 구축하는 Graph RAG 시스템 완전 가이드"
excerpt: "전통적인 RAG의 한계를 극복하는 Graph RAG를 AgentOps와 CrewAI를 활용하여 단계별로 구축하는 실전 가이드입니다."
date: 2025-06-21
tags: 
  - GraphRAG
  - AgentOps
  - CrewAI
  - Neo4j
  - Weaviate
  - RAG
  - KnowledgeGraph
  - MultiAgent
author_profile: true
toc: true
toc_label: "Graph RAG 개발 가이드"
published: false
categories:
  - agentops
  - tutorials
---

## 개요

전통적인 RAG(Retrieval Augmented Generation)는 벡터 검색을 통해 의미적으로 유사한 문서를 찾아 컨텍스트를 제공하지만, 데이터 간의 관계나 연결성을 충분히 활용하지 못합니다. Graph RAG는 이러한 한계를 극복하여 엔티티 간의 관계를 활용한 더 풍부한 컨텍스트를 제공합니다.

이 가이드에서는 [Weaviate의 Graph RAG 접근법](https://weaviate.io/blog/graph-rag)을 참고하여 AgentOps와 CrewAI를 활용한 실전 Graph RAG 시스템을 단계별로 구축해보겠습니다.

## Graph RAG vs 전통적인 RAG

### 전통적인 RAG의 한계점

전통적인 RAG는 각 문서를 독립적인 벡터로 표현하여 의미적 유사성만을 기반으로 검색합니다:

```python
# 전통적인 RAG의 데이터 표현
documents = [
    {"text": "계약서 A", "embedding": [0.1, 0.2, ...]},
    {"text": "계약서 B", "embedding": [0.3, 0.4, ...]},
    {"text": "계약서 C", "embedding": [0.5, 0.6, ...]}
]
```

이 방식은 문서 간의 관계나 엔티티 간의 연결성을 파악하지 못합니다.

### Graph RAG의 장점

Graph RAG는 엔티티와 관계를 그래프로 구조화하여 더 풍부한 컨텍스트를 제공합니다:

- **관계 기반 검색**: 엔티티 간 연결을 통한 확장된 컨텍스트
- **커뮤니티 탐지**: 밀접하게 연결된 엔티티 그룹 식별
- **계층적 요약**: 엔티티 및 커뮤니티 수준의 요약 정보

## 시스템 아키텍처

우리가 구축할 Graph RAG 시스템의 전체 아키텍처입니다:

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
<div class="d3-arch" data-arch-root id="pmentguideagentopscrewai-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 655, "height": 722, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 49, "y": 24, "w": 120, "h": 46, "title": "문서 입력"}, {"id": "B", "x": 24, "y": 148, "w": 170, "h": 46, "title": "CrewAI Agent: 엔티티 추출"}, {"id": "C", "x": 38, "y": 272, "w": 142, "h": 46, "title": "Neo4j: 지식 그래프 구축"}, {"id": "D", "x": 38, "y": 396, "w": 142, "h": 46, "title": "Weaviate: 벡터 인덱싱"}, {"id": "E", "x": 470, "y": 24, "w": 120, "h": 46, "title": "사용자 쿼리"}, {"id": "F", "x": 441, "y": 148, "w": 163, "h": 46, "title": "CrewAI Agent: 쿼리 분석"}, {"id": "G", "x": 463, "y": 272, "w": 120, "h": 46, "title": "하이브리드 검색"}, {"id": "H", "x": 502, "y": 396, "w": 121, "h": 46, "title": "Neo4j: 그래프 탐색"}, {"id": "I", "x": 312, "y": 396, "w": 135, "h": 46, "title": "Weaviate: 벡터 검색"}, {"id": "J", "x": 350, "y": 520, "w": 163, "h": 46, "title": "CrewAI Agent: 응답 생성"}, {"id": "K", "x": 371, "y": 644, "w": 120, "h": 46, "title": "최종 응답"}, {"id": "L", "x": 224, "y": 24, "w": 120, "h": 46, "title": "AgentOps"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[113, 70], [119, 109], [119, 109], [113, 148]]}, {"src": "B", "dst": "C", "kind": "data", "line": [109, 194, 109, 272]}, {"src": "C", "dst": "D", "kind": "data", "line": [109, 318, 109, 396]}, {"src": "E", "dst": "F", "kind": "data", "line": [530, 70, 525, 148]}, {"src": "F", "dst": "G", "kind": "data", "line": [523, 194, 523, 272]}, {"src": "G", "dst": "H", "kind": "data", "curve": [[537, 318], [563, 357], [563, 357], [563, 396]]}, {"src": "G", "dst": "I", "kind": "data", "curve": [[470, 318], [380, 357], [380, 357], [380, 396]]}, {"src": "H", "dst": "J", "kind": "data", "curve": [[563, 442], [563, 481], [563, 481], [480, 520]]}, {"src": "I", "dst": "J", "kind": "data", "curve": [[380, 442], [380, 481], [380, 481], [412, 520]]}, {"src": "J", "dst": "K", "kind": "data", "line": [431, 566, 431, 644]}, {"src": "L", "dst": "B", "kind": "data", "curve": [[224, 67], [99, 109], [99, 109], [105, 148]]}, {"src": "L", "dst": "F", "kind": "data", "curve": [[310, 70], [354, 109], [354, 109], [460, 148]]}, {"src": "L", "dst": "J", "kind": "data", "curve": [[278, 70], [268, 233], [268, 419], [370, 520]]}]});
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
      const container = document.getElementById('pmentguideagentopscrewai-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'pmentguideagentopscrewai-1';
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

## 필수 도구 설치 및 설정

### 1. 기본 환경 설정

```bash
# 프로젝트 디렉토리 생성
mkdir graph-rag-system
cd graph-rag-system

# Python 가상환경 생성 (uv 사용)
uv venv graph-rag-env
source graph-rag-env/bin/activate

# 필수 패키지 설치
uv add crewai agentops neo4j weaviate-client langchain openai python-dotenv
```

### 2. 환경 변수 설정

```bash
# .env 파일 생성
cat > .env << 'EOF'
# OpenAI API
OPENAI_API_KEY=your_openai_api_key

# AgentOps
AGENTOPS_API_KEY=your_agentops_api_key

# Neo4j
NEO4J_URI=bolt://localhost:7687
NEO4J_USERNAME=neo4j
NEO4J_PASSWORD=your_neo4j_password

# Weaviate
WEAVIATE_URL=http://localhost:8080
WEAVIATE_API_KEY=your_weaviate_api_key
EOF
```

### 3. Docker로 데이터베이스 실행

```bash
# Neo4j 실행
docker run -d \
  --name neo4j \
  -p 7474:7474 -p 7687:7687 \
  -e NEO4J_AUTH=neo4j/your_password \
  neo4j:latest

# Weaviate 실행
docker run -d \
  --name weaviate \
  -p 8080:8080 \
  -e QUERY_DEFAULTS_LIMIT=25 \
  -e AUTHENTICATION_ANONYMOUS_ACCESS_ENABLED=true \
  -e PERSISTENCE_DATA_PATH='/var/lib/weaviate' \
  -e DEFAULT_VECTORIZER_MODULE='none' \
  -e ENABLE_MODULES='text2vec-openai' \
  -e CLUSTER_HOSTNAME='node1' \
  cr.weaviate.io/semitechnologies/weaviate:latest
```

## 단계 1: CrewAI 에이전트 설계

### 엔티티 추출 에이전트

{% raw %}
```python
# agents/entity_extractor.py
from crewai import Agent, Task, Crew
from langchain.llms import OpenAI
import agentops

class EntityExtractorAgent:
    def __init__(self):
        agentops.init()
        
        self.llm = OpenAI(temperature=0)
        
        self.agent = Agent(
            role='엔티티 추출 전문가',
            goal='문서에서 핵심 엔티티와 관계를 정확하게 추출',
            backstory="""
            당신은 텍스트 분석의 전문가로, 문서에서 사람, 조직, 개념, 
            날짜 등의 엔티티와 그들 간의 관계를 식별하는 데 특화되어 있습니다.
            """,
            verbose=True,
            allow_delegation=False,
            llm=self.llm
        )
    
    @agentops.record_function('extract_entities')
    def extract_entities(self, text: str) -> dict:
        """문서에서 엔티티와 관계를 추출합니다."""
        
        task = Task(
            description=f"""
            다음 텍스트에서 엔티티와 관계를 추출하세요:
            
            텍스트: {text}
            
            다음 형식으로 결과를 반환하세요:
            {{
                "entities": [
                    `"name": "엔티티명", "type": "PERSON|ORGANIZATION|CONCEPT|DATE", "description": "설명"`
                ],
                "relationships": [
                    `"source": "엔티티1", "target": "엔티티2", "relationship": "관계타입", "description": "관계설명"`
                ]
            }}
            """,
            agent=self.agent,
            expected_output="JSON 형식의 엔티티와 관계 정보"
        )
        
        crew = Crew(
            agents=[self.agent],
            tasks=[task],
            verbose=True
        )
        
        result = crew.kickoff()
        return result
```
{% endraw %}

### 쿼리 분석 에이전트

```python
# agents/query_analyzer.py
from crewai import Agent, Task, Crew
import agentops

class QueryAnalyzerAgent:
    def __init__(self):
        self.agent = Agent(
            role='쿼리 분석 전문가',
            goal='사용자 쿼리를 분석하여 최적의 검색 전략 결정',
            backstory="""
            당신은 자연어 쿼리를 분석하여 어떤 엔티티가 중요한지, 
            어떤 관계를 탐색해야 하는지 파악하는 전문가입니다.
            """,
            verbose=True,
            allow_delegation=False
        )
    
    @agentops.record_function('analyze_query')
    def analyze_query(self, query: str) -> dict:
        """쿼리를 분석하여 검색 전략을 결정합니다."""
        
        task = Task(
            description=f"""
            사용자 쿼리를 분석하세요: "{query}"
            
            다음 정보를 추출하세요:
            1. 핵심 엔티티들
            2. 필요한 관계 타입들
            3. 검색 범위 (로컬/글로벌)
            4. 우선순위
            
            JSON 형식으로 반환하세요.
            """,
            agent=self.agent,
            expected_output="쿼리 분석 결과 JSON"
        )
        
        crew = Crew(
            agents=[self.agent],
            tasks=[task],
            verbose=True
        )
        
        return crew.kickoff()
```

## 단계 2: 지식 그래프 구축

### Neo4j 그래프 빌더

```python
# graph/neo4j_builder.py
from neo4j import GraphDatabase
import json
import agentops

class Neo4jGraphBuilder:
    def __init__(self, uri: str, username: str, password: str):
        self.driver = GraphDatabase.driver(uri, auth=(username, password))
    
    def close(self):
        self.driver.close()
    
    @agentops.record_function('create_entity')
    def create_entity(self, entity: dict):
        """엔티티를 Neo4j에 생성합니다."""
        with self.driver.session() as session:
            query = """
            MERGE (e:Entity {name: $name})
            SET e.type = $type,
                e.description = $description,
                e.summary = $summary
            RETURN e
            """
            session.run(query, 
                       name=entity['name'],
                       type=entity['type'],
                       description=entity.get('description', ''),
                       summary=entity.get('summary', ''))
    
    @agentops.record_function('create_relationship')
    def create_relationship(self, relationship: dict):
        """관계를 Neo4j에 생성합니다."""
        with self.driver.session() as session:
            query = """
            MATCH (a:Entity {name: $source})
            MATCH (b:Entity {name: $target})
            MERGE (a)-[r:RELATED {type: $rel_type}]->(b)
            SET r.description = $description,
                r.summary = $summary
            RETURN r
            """
            session.run(query,
                       source=relationship['source'],
                       target=relationship['target'],
                       rel_type=relationship['relationship'],
                       description=relationship.get('description', ''),
                       summary=relationship.get('summary', ''))
    
    @agentops.record_function('detect_communities')
    def detect_communities(self):
        """Leiden 알고리즘으로 커뮤니티를 탐지합니다."""
        with self.driver.session() as session:
            # 그래프 프로젝션 생성
            session.run("""
            CALL gds.graph.project(
                'entityGraph',
                'Entity',
                'RELATED'
            )
            """)
            
            # Leiden 알고리즘 실행
            result = session.run("""
            CALL gds.leiden.write('entityGraph', {
                writeProperty: 'communityId'
            })
            YIELD communityCount, modularity
            RETURN communityCount, modularity
            """)
            
            return result.single()
```

### 커뮤니티 요약 생성

```python
# graph/community_summarizer.py
from crewai import Agent, Task, Crew
import agentops

class CommunitySummarizerAgent:
    def __init__(self):
        self.agent = Agent(
            role='커뮤니티 요약 전문가',
            goal='관련 엔티티들의 커뮤니티에 대한 포괄적인 요약 생성',
            backstory="""
            당신은 복잡한 관계 네트워크를 분석하여 
            핵심 패턴과 인사이트를 도출하는 전문가입니다.
            """,
            verbose=True,
            allow_delegation=False
        )
    
    @agentops.record_function('summarize_community')
    def summarize_community(self, entities: list, relationships: list) -> str:
        """커뮤니티에 대한 요약을 생성합니다."""
        
        task = Task(
            description=f"""
            다음 엔티티들과 관계들로 구성된 커뮤니티를 분석하고 요약하세요:
            
            엔티티들: {entities}
            관계들: {relationships}
            
            다음 관점에서 포괄적인 요약을 작성하세요:
            1. 주요 테마와 패턴
            2. 핵심 인물이나 조직
            3. 중요한 연결점
            4. 전체적인 맥락과 의미
            """,
            agent=self.agent,
            expected_output="커뮤니티에 대한 상세한 요약"
        )
        
        crew = Crew(
            agents=[self.agent],
            tasks=[task],
            verbose=True
        )
        
        return crew.kickoff()
```

## 단계 3: 벡터 인덱싱

### Weaviate 벡터 스토어

```python
# vector/weaviate_store.py
import weaviate
from weaviate.classes.config import Configure
import agentops

class WeaviateVectorStore:
    def __init__(self, url: str, api_key: str = None):
        if api_key:
            self.client = weaviate.connect_to_local(
                host=url,
                headers={"X-OpenAI-Api-Key": api_key}
            )
        else:
            self.client = weaviate.connect_to_local(host=url)
        
        self._setup_schema()
    
    def _setup_schema(self):
        """Weaviate 스키마를 설정합니다."""
        try:
            self.client.collections.create(
                name="Entity",
                vectorizer_config=Configure.Vectorizer.text2vec_openai(),
                properties=[
                    weaviate.classes.config.Property(
                        name="name",
                        data_type=weaviate.classes.config.DataType.TEXT
                    ),
                    weaviate.classes.config.Property(
                        name="type",
                        data_type=weaviate.classes.config.DataType.TEXT
                    ),
                    weaviate.classes.config.Property(
                        name="description",
                        data_type=weaviate.classes.config.DataType.TEXT
                    ),
                    weaviate.classes.config.Property(
                        name="summary",
                        data_type=weaviate.classes.config.DataType.TEXT
                    ),
                    weaviate.classes.config.Property(
                        name="entity_id",
                        data_type=weaviate.classes.config.DataType.TEXT
                    )
                ]
            )
        except Exception as e:
            print(f"스키마가 이미 존재하거나 생성 중 오류: {e}")
    
    @agentops.record_function('index_entity')
    def index_entity(self, entity: dict):
        """엔티티를 벡터 인덱스에 추가합니다."""
        collection = self.client.collections.get("Entity")
        
        collection.data.insert({
            "name": entity['name'],
            "type": entity['type'],
            "description": entity.get('description', ''),
            "summary": entity.get('summary', ''),
            "entity_id": entity['name']
        })
    
    @agentops.record_function('search_entities')
    def search_entities(self, query: str, limit: int = 10):
        """벡터 검색으로 관련 엔티티를 찾습니다."""
        collection = self.client.collections.get("Entity")
        
        response = collection.query.near_text(
            query=query,
            limit=limit
        )
        
        return response.objects
```

## 단계 4: 하이브리드 검색 시스템

### 검색 오케스트레이터

```python
# search/hybrid_retriever.py
from typing import List, Dict
import agentops

class HybridRetriever:
    def __init__(self, neo4j_builder, weaviate_store):
        self.neo4j = neo4j_builder
        self.weaviate = weaviate_store
    
    @agentops.record_function('hybrid_search')
    def search(self, query: str, search_strategy: dict) -> dict:
        """하이브리드 검색을 수행합니다."""
        
        # 1. 벡터 검색으로 관련 엔티티 찾기
        vector_results = self.weaviate.search_entities(
            query, 
            limit=search_strategy.get('entity_limit', 10)
        )
        
        entity_names = [obj.properties['name'] for obj in vector_results]
        
        # 2. Neo4j에서 그래프 탐색
        graph_context = self._traverse_graph(
            entity_names, 
            search_strategy.get('traversal_depth', 2)
        )
        
        # 3. 커뮤니티 정보 수집
        community_summaries = self._get_community_summaries(entity_names)
        
        return {
            'entities': vector_results,
            'graph_context': graph_context,
            'community_summaries': community_summaries
        }
    
    def _traverse_graph(self, entity_names: List[str], depth: int) -> dict:
        """그래프를 탐색하여 관련 정보를 수집합니다."""
        with self.neo4j.driver.session() as session:
            query = f"""
            MATCH (start:Entity)
            WHERE start.name IN $entity_names
            MATCH path = (start)-[*1..{depth}]-(connected)
            RETURN start.name as start_entity,
                   connected.name as connected_entity,
                   connected.type as entity_type,
                   connected.summary as entity_summary,
                   relationships(path) as relationships
            LIMIT 100
            """
            
            result = session.run(query, entity_names=entity_names)
            
            context = {
                'connected_entities': [],
                'relationships': []
            }
            
            for record in result:
                context['connected_entities'].append({
                    'name': record['connected_entity'],
                    'type': record['entity_type'],
                    'summary': record['entity_summary']
                })
                
                for rel in record['relationships']:
                    context['relationships'].append({
                        'source': rel.start_node['name'],
                        'target': rel.end_node['name'],
                        'type': rel.type,
                        'summary': rel.get('summary', '')
                    })
            
            return context
    
    def _get_community_summaries(self, entity_names: List[str]) -> List[str]:
        """엔티티들의 커뮤니티 요약을 가져옵니다."""
        with self.neo4j.driver.session() as session:
            query = """
            MATCH (e:Entity)-[:IN_COMMUNITY]->(c:Community)
            WHERE e.name IN $entity_names AND c.summary IS NOT NULL
            RETURN DISTINCT c.summary as community_summary
            ORDER BY c.rating DESC
            LIMIT 5
            """
            
            result = session.run(query, entity_names=entity_names)
            return [record['community_summary'] for record in result]
```

## 단계 5: 응답 생성 에이전트

### 최종 응답 생성기

```python
# agents/response_generator.py
from crewai import Agent, Task, Crew
import agentops

class ResponseGeneratorAgent:
    def __init__(self):
        self.agent = Agent(
            role='지능형 응답 생성 전문가',
            goal='검색된 정보를 종합하여 정확하고 유용한 답변 생성',
            backstory="""
            당신은 복잡한 정보를 분석하고 사용자가 이해하기 쉬운 
            형태로 종합하여 제시하는 전문가입니다.
            """,
            verbose=True,
            allow_delegation=False
        )
    
    @agentops.record_function('generate_response')
    def generate_response(self, query: str, search_results: dict) -> str:
        """검색 결과를 바탕으로 최종 응답을 생성합니다."""
        
        # 컨텍스트 정리
        entities_context = self._format_entities(search_results['entities'])
        graph_context = self._format_graph_context(search_results['graph_context'])
        community_context = self._format_community_summaries(
            search_results['community_summaries']
        )
        
        task = Task(
            description=f"""
            사용자 질문: "{query}"
            
            다음 정보들을 종합하여 정확하고 유용한 답변을 생성하세요:
            
            ## 관련 엔티티 정보:
            {entities_context}
            
            ## 그래프 연결 정보:
            {graph_context}
            
            ## 커뮤니티 요약:
            {community_context}
            
            답변 작성 가이드라인:
            1. 사용자 질문에 직접적으로 답변
            2. 관련 엔티티들 간의 관계 설명
            3. 중요한 연결점과 패턴 강조
            4. 구체적인 예시와 근거 제시
            5. 명확하고 구조화된 형태로 작성
            """,
            agent=self.agent,
            expected_output="사용자 질문에 대한 포괄적이고 정확한 답변"
        )
        
        crew = Crew(
            agents=[self.agent],
            tasks=[task],
            verbose=True
        )
        
        return crew.kickoff()
    
    def _format_entities(self, entities) -> str:
        """엔티티 정보를 포맷팅합니다."""
        formatted = []
        for entity in entities:
            props = entity.properties
            formatted.append(f"- {props['name']} ({props['type']}): {props.get('summary', props.get('description', ''))}")
        return "\n".join(formatted)
    
    def _format_graph_context(self, graph_context: dict) -> str:
        """그래프 컨텍스트를 포맷팅합니다."""
        entities_info = []
        for entity in graph_context['connected_entities']:
            entities_info.append(f"- {entity['name']} ({entity['type']}): {entity.get('summary', '')}")
        
        relationships_info = []
        for rel in graph_context['relationships']:
            relationships_info.append(f"- {rel['source']} --[{rel['type']}]--> {rel['target']}: {rel.get('summary', '')}")
        
        return f"연결된 엔티티들:\n" + "\n".join(entities_info) + f"\n\n관계들:\n" + "\n".join(relationships_info)
    
    def _format_community_summaries(self, summaries: List[str]) -> str:
        """커뮤니티 요약을 포맷팅합니다."""
        if not summaries:
            return "관련 커뮤니티 요약이 없습니다."
        
        formatted = []
        for i, summary in enumerate(summaries, 1):
            formatted.append(f"{i}. {summary}")
        
        return "\n".join(formatted)
```

## 단계 6: 메인 Graph RAG 시스템

### 전체 시스템 통합

```python
# main.py
import os
from dotenv import load_dotenv
import agentops

from agents.entity_extractor import EntityExtractorAgent
from agents.query_analyzer import QueryAnalyzerAgent
from agents.response_generator import ResponseGeneratorAgent
from graph.neo4j_builder import Neo4jGraphBuilder
from graph.community_summarizer import CommunitySummarizerAgent
from vector.weaviate_store import WeaviateVectorStore
from search.hybrid_retriever import HybridRetriever

load_dotenv()

class GraphRAGSystem:
    def __init__(self):
        # AgentOps 초기화
        agentops.init(api_key=os.getenv('AGENTOPS_API_KEY'))
        
        # 컴포넌트 초기화
        self.entity_extractor = EntityExtractorAgent()
        self.query_analyzer = QueryAnalyzerAgent()
        self.response_generator = ResponseGeneratorAgent()
        self.community_summarizer = CommunitySummarizerAgent()
        
        # 데이터베이스 연결
        self.neo4j_builder = Neo4jGraphBuilder(
            uri=os.getenv('NEO4J_URI'),
            username=os.getenv('NEO4J_USERNAME'),
            password=os.getenv('NEO4J_PASSWORD')
        )
        
        self.weaviate_store = WeaviateVectorStore(
            url=os.getenv('WEAVIATE_URL'),
            api_key=os.getenv('OPENAI_API_KEY')
        )
        
        # 검색 시스템
        self.retriever = HybridRetriever(
            self.neo4j_builder,
            self.weaviate_store
        )
    
    @agentops.record_function('index_document')
    def index_document(self, document_text: str, document_id: str):
        """문서를 인덱싱하여 지식 그래프를 구축합니다."""
        
        print(f"문서 {document_id} 인덱싱 시작...")
        
        # 1. 엔티티와 관계 추출
        extraction_result = self.entity_extractor.extract_entities(document_text)
        
        # 2. Neo4j에 엔티티와 관계 저장
        for entity in extraction_result['entities']:
            self.neo4j_builder.create_entity(entity)
            # Weaviate에도 인덱싱
            self.weaviate_store.index_entity(entity)
        
        for relationship in extraction_result['relationships']:
            self.neo4j_builder.create_relationship(relationship)
        
        # 3. 커뮤니티 탐지
        community_result = self.neo4j_builder.detect_communities()
        print(f"커뮤니티 탐지 완료: {community_result['communityCount']}개 커뮤니티")
        
        # 4. 커뮤니티 요약 생성 (간소화된 버전)
        # 실제 구현에서는 각 커뮤니티별로 요약을 생성해야 합니다
        
        print(f"문서 {document_id} 인덱싱 완료")
    
    @agentops.record_function('query')
    def query(self, user_query: str) -> str:
        """사용자 쿼리에 대한 답변을 생성합니다."""
        
        print(f"쿼리 처리 시작: {user_query}")
        
        # 1. 쿼리 분석
        query_analysis = self.query_analyzer.analyze_query(user_query)
        
        # 2. 하이브리드 검색
        search_results = self.retriever.search(user_query, query_analysis)
        
        # 3. 응답 생성
        response = self.response_generator.generate_response(
            user_query, 
            search_results
        )
        
        print("쿼리 처리 완료")
        return response
    
    def close(self):
        """리소스 정리"""
        self.neo4j_builder.close()
        self.weaviate_store.client.close()
        agentops.end_session('Success')

# 사용 예시
if __name__ == "__main__":
    # Graph RAG 시스템 초기화
    graph_rag = GraphRAGSystem()
    
    try:
        # 샘플 문서 인덱싱
        sample_document = """
        김철수는 ABC 회사의 CEO로서 2023년에 XYZ 파트너십 계약을 체결했다.
        이 계약은 AI 기술 개발을 위한 협력을 목적으로 하며, 
        박영희 CTO가 기술 총괄을 담당한다. ABC 회사는 서울에 본사를 두고 있으며,
        주요 사업 분야는 인공지능과 데이터 분석이다.
        """
        
        graph_rag.index_document(sample_document, "doc_001")
        
        # 쿼리 실행
        response = graph_rag.query("김철수와 관련된 회사와 파트너십에 대해 알려주세요.")
        print("\n=== 답변 ===")
        print(response)
        
    finally:
        graph_rag.close()
```

## 실행 및 테스트

### 1. 시스템 실행

```bash
# 데이터베이스 실행 확인
docker ps

# Graph RAG 시스템 실행
python main.py
```

### 2. 성능 모니터링

AgentOps 대시보드에서 다음 메트릭을 모니터링할 수 있습니다:

- **엔티티 추출 성능**: 추출된 엔티티 수, 처리 시간
- **검색 성능**: 벡터 검색 vs 그래프 검색 비교
- **응답 품질**: 사용자 피드백, 응답 길이
- **시스템 리소스**: 메모리 사용량, API 호출 수

### 3. 고급 기능 활용

```python
# 배치 문서 처리
def batch_index_documents(graph_rag, documents):
    for doc_id, doc_text in documents.items():
        try:
            graph_rag.index_document(doc_text, doc_id)
            print(f"✅ {doc_id} 처리 완료")
        except Exception as e:
            print(f"❌ {doc_id} 처리 실패: {e}")

# 커스텀 검색 전략
custom_strategy = {
    'entity_limit': 15,
    'traversal_depth': 3,
    'community_focus': True
}

response = graph_rag.retriever.search(query, custom_strategy)
```

## 성능 최적화 팁

### 1. 인덱싱 최적화

- **배치 처리**: 대량 문서는 배치로 처리
- **병렬 처리**: 멀티프로세싱으로 엔티티 추출 가속화
- **캐싱**: 자주 사용되는 엔티티 정보 캐싱

### 2. 검색 최적화

- **인덱스 튜닝**: Neo4j 인덱스 최적화
- **쿼리 최적화**: Cypher 쿼리 성능 튜닝
- **결과 제한**: 검색 결과 수 적절히 제한

### 3. 메모리 관리

```python
# 메모리 효율적인 배치 처리
def process_large_dataset(graph_rag, dataset, batch_size=100):
    for i in range(0, len(dataset), batch_size):
        batch = dataset[i:i+batch_size]
        
        for doc in batch:
            graph_rag.index_document(doc['text'], doc['id'])
        
        # 배치 완료 후 메모리 정리
        import gc
        gc.collect()
```

## 트러블슈팅

### 일반적인 문제들

1. **Neo4j 연결 실패**
   ```bash
   # Neo4j 상태 확인
   docker logs neo4j
   
   # 포트 확인
   netstat -an | grep 7687
   ```

2. **Weaviate 스키마 오류**
   ```python
   # 스키마 재생성
   client.collections.delete("Entity")
   weaviate_store._setup_schema()
   ```

3. **AgentOps 연결 문제**
   ```python
   # API 키 확인
   import agentops
   agentops.init(api_key="your_key", auto_start_session=False)
   ```

## 확장 가능성

### 1. 다중 언어 지원

```python
# 언어별 엔티티 추출기
class MultilingualEntityExtractor:
    def __init__(self):
        self.extractors = {
            'ko': KoreanEntityExtractor(),
            'en': EnglishEntityExtractor(),
            'ja': JapaneseEntityExtractor()
        }
    
    def extract(self, text: str, language: str):
        return self.extractors[language].extract_entities(text)
```

### 2. 실시간 업데이트

```python
# 실시간 문서 모니터링
import watchdog
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

class DocumentWatcher(FileSystemEventHandler):
    def __init__(self, graph_rag_system):
        self.graph_rag = graph_rag_system
    
    def on_created(self, event):
        if event.is_file and event.src_path.endswith('.txt'):
            with open(event.src_path, 'r') as f:
                content = f.read()
            self.graph_rag.index_document(content, event.src_path)
```

### 3. API 서버 구축

```python
# FastAPI로 REST API 제공
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()
graph_rag = GraphRAGSystem()

class QueryRequest(BaseModel):
    query: str
    strategy: dict = {}

@app.post("/query")
async def query_endpoint(request: QueryRequest):
    response = graph_rag.query(request.query)
    return {"response": response}

@app.post("/index")
async def index_endpoint(document: dict):
    graph_rag.index_document(document['text'], document['id'])
    return {"status": "indexed"}
```

## 결론

이 가이드에서는 AgentOps와 CrewAI를 활용하여 Graph RAG 시스템을 구축하는 전체 과정을 다뤘습니다. 전통적인 RAG의 한계를 극복하고 엔티티 간의 관계를 활용한 더 풍부한 컨텍스트를 제공하는 시스템을 만들 수 있습니다.

핵심 포인트:
- **멀티 에이전트 아키텍처**: CrewAI로 전문화된 에이전트들이 협력
- **하이브리드 검색**: 벡터 검색과 그래프 탐색의 결합
- **지능형 모니터링**: AgentOps로 시스템 성능 추적
- **확장 가능한 설계**: 다양한 도메인과 언어로 확장 가능

Graph RAG는 복잡한 관계가 중요한 도메인(법률, 의료, 금융 등)에서 특히 강력한 성능을 발휘합니다. 이 가이드를 바탕으로 여러분만의 지능형 검색 시스템을 구축해보세요.

## 참고 자료

- [Weaviate Graph RAG 블로그](https://weaviate.io/blog/graph-rag)
- [Microsoft GraphRAG 논문](https://arxiv.org/abs/2404.16130)
- [CrewAI 공식 문서](https://docs.crewai.com/)
- [AgentOps 가이드](https://docs.agentops.ai/)
- [Neo4j Graph Data Science](https://neo4j.com/docs/graph-data-science/) 