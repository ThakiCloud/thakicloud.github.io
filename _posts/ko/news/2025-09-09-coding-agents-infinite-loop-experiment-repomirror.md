---
title: "코딩 에이전트를 무한 루프에 넣었더니 하룻밤에 6개 저장소가 완성된 혁신적 실험"
excerpt: "Claude 코딩 에이전트를 while 루프에 넣어 자동으로 1000건 이상의 커밋과 여러 프로그래밍 언어 간 포팅 작업을 성공시킨 놀라운 실험 결과를 상세히 소개합니다."
seo_title: "코딩 에이전트 무한 루프 실험: AI가 하룻밤에 6개 저장소 완성한 방법 - Thaki Cloud"
seo_description: "Claude 코딩 에이전트를 무한 루프로 실행하여 React→Vue, Python→TypeScript 자동 포팅에 성공한 혁신적 실험과 RepoMirror 도구 개발 과정을 자세히 알아보세요."
date: 2025-09-09
tags:
  - 코딩에이전트
  - AI자동화
  - 코드포팅
  - RepoMirror
  - Claude
  - 프로그래밍자동화
author_profile: true
toc: true
toc_label: "목차"
lang: ko
permalink: /ko/news/coding-agents-infinite-loop-experiment-repomirror/
canonical_url: "https://thakicloud.com/tech-blog/ko/news/coding-agents-infinite-loop-experiment-repomirror/"
categories:
  - news
published: false
---

⏱️ **예상 읽기 시간**: 8분

![무한 루프 속에서 서로를 비추며 포팅되는 두 저장소를 형상화한 추상 이미지]({{ '/assets/images/coding-agents-infinite-loop-experiment-repomirror-hero.webp' | relative_url }})
*무한 루프 안에서 소스 저장소를 타깃 형태로 반복 변환하는 RepoMirror의 미러링 구조를 형상화한 이미지입니다.*

## 서론: AI 코딩 자동화의 새로운 패러다임

최근 개발자 커뮤니티에서 화제가 된 혁신적인 실험이 있습니다. 한 개발자가 Claude 코딩 에이전트를 헤드리스 방식으로 무한 while 루프에 넣어두었더니, 하룻밤 사이에 1000건이 넘는 커밋과 함께 여러 개의 완전한 코드베이스 포팅 작업이 자동으로 완성되었다는 놀라운 결과입니다. 이 실험은 단순히 AI의 코딩 능력을 보여주는 것을 넘어서, 소프트웨어 개발 자동화의 새로운 가능성을 제시하고 있습니다.

## 무한 루프 코딩 에이전트의 작동 원리

### 기본 개념과 실행 방식

이 실험의 핵심은 코딩 에이전트에게 지속적이고 반복적인 작업 환경을 제공하는 것이었습니다. 개발자는 `while :; do cat prompt.md | claude -p --dangerously-skip-permissions; done`과 같은 간단한 쉘 스크립트를 통해 Claude 코딩 에이전트가 무한히 반복 실행되도록 설정했습니다. 이 방식은 Geoff Huntley가 제안한 방법론을 기반으로 하며, 에이전트가 각 작업 사이클마다 파일을 수정하고, 커밋하고, 푸시하는 전체 과정을 자동화합니다.

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
<div class="d3-arch" data-arch-root id="loopexperimentrepomirror-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 275, "height": 742, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "P", "x": 41, "y": 24, "w": 120, "h": 46, "title": "prompt.md 읽기"}, {"id": "C", "x": 101, "y": 148, "w": 120, "h": 46, "title": "claude -p 실행"}, {"id": "E", "x": 94, "y": 272, "w": 135, "h": 46, "title": "파일 수정 · 커밋 · 푸시"}, {"id": "T", "x": 80, "y": 396, "w": 163, "h": 46, "title": ".agent · TODO.md 갱신"}, {"id": "Q", "x": 32, "y": 520, "w": 138, "h": 52, "title": "작업 완료 판단"}, {"id": "Z", "x": 41, "y": 664, "w": 120, "h": 46, "title": "루프 종료"}], "edges": [{"src": "P", "dst": "C", "kind": "data", "curve": [[123, 70], [161, 109], [161, 109], [161, 148]]}, {"src": "C", "dst": "E", "kind": "data", "line": [161, 194, 161, 272]}, {"src": "E", "dst": "T", "kind": "data", "line": [161, 318, 161, 396]}, {"src": "T", "dst": "Q", "kind": "data", "curve": [[161, 442], [161, 481], [161, 481], [125, 520]]}, {"src": "Q", "dst": "P", "kind": "data", "label": "\"미완료\"", "curve": [[76, 520], [40, 357], [40, 171], [78, 70]], "off": "50%"}, {"src": "Q", "dst": "Z", "kind": "data", "label": "\"완료 시 pkill 자기 종료\"", "line": [101, 572, 101, 664], "lx": 101, "ly": 614}]});
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
      const container = document.getElementById('loopexperimentrepomirror-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'loopexperimentrepomirror-1';
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

### 작업 추적 및 관리 시스템

에이전트는 작업 과정에서 자신의 진행 상황과 계획을 체계적으로 기록합니다. `.agent/` 디렉토리에 작업 내역과 향후 계획을 문서화하며, `TODO.md` 파일을 통해 완성도와 남은 작업을 지속적으로 업데이트합니다. 이러한 자기 문서화 능력은 에이전트가 단순한 코드 생성 도구를 넘어서 프로젝트 관리 역량까지 갖추고 있음을 보여줍니다.

## 다양한 언어 간 포팅 실험 성과

### React에서 Vue로의 전환

가장 주목할 만한 성과 중 하나는 assistant-ui React 프로젝트를 Vue로 완전히 포팅한 것입니다. 에이전트는 React의 컴포넌트 구조와 상태 관리 로직을 Vue의 Composition API와 반응성 시스템에 맞게 자동으로 변환했습니다. 이 과정에서 각 컴포넌트의 라이프사이클 메서드, 이벤트 핸들링, 그리고 스타일링까지 모두 Vue의 규칙에 맞게 재작성되었으며, 원본 프로젝트의 기능성을 그대로 유지하면서도 Vue 생태계의 모범 사례를 따르는 코드가 생성되었습니다.

### Python에서 TypeScript로의 혁신적 변환

Browser Use라는 Python 프로젝트를 TypeScript로 포팅하는 작업에서는 더욱 놀라운 결과가 나타났습니다. 에이전트는 GCP VM에서 tmux 세션을 통해 지속적으로 실행되었으며, 개발자가 아침에 확인했을 때 거의 완벽하게 동작하는 TypeScript 포트가 완성되어 있었습니다. Python의 동적 타이핑 시스템을 TypeScript의 정적 타입 시스템으로 변환하는 복잡한 작업이 자동으로 처리되었으며, 심지어 Python 특유의 라이브러리 사용 패턴도 TypeScript 생태계에 적합한 형태로 재구성되었습니다.

### 양방향 포팅과 생태계 적응

흥미롭게도 에이전트는 Vercel AI SDK를 TypeScript에서 Python으로 역방향 포팅하는 작업도 수행했습니다. 이 과정에서 FastAPI와 Flask를 위한 자동 어댑터를 생성했으며, Python의 다양한 스키마 검증 도구들과의 호환성도 확보했습니다. 이는 단순한 문법 변환을 넘어서 각 언어 생태계의 특성과 관습을 이해하고 적용하는 높은 수준의 지능을 보여주는 사례입니다.

## 에이전트의 예상치 못한 창발적 행동들

### 자율적 테스트 코드 작성

실험 과정에서 가장 놀라운 발견 중 하나는 에이전트가 명시적인 지시 없이도 자발적으로 테스트 코드를 작성한다는 점이었습니다. 에이전트는 포팅된 코드의 정확성을 검증하기 위해 단위 테스트와 통합 테스트를 자동으로 생성했으며, 심지어 엣지 케이스까지 고려한 포괄적인 테스트 스위트를 구축했습니다. 이러한 행동은 현대 소프트웨어 개발에서 테스트 주도 개발(TDD)의 중요성을 AI가 스스로 인식하고 실천하고 있음을 의미합니다.

### 지능적 자기 종료 메커니즘

더욱 흥미로운 현상은 에이전트가 작업 완료를 스스로 판단하고 `pkill` 명령을 통해 자신의 프로세스를 종료하는 행동을 보인 것입니다. 이는 할팅 문제(Halting Problem)의 실질적 해결책을 제시하는 것처럼 보이며, AI가 작업의 완성도를 자체적으로 평가하고 적절한 시점에 작업을 마무리할 수 있음을 보여줍니다. 이러한 자율성은 무인 자동화 시스템의 핵심 요소로 여겨집니다.

### 기능 확장과 혁신적 개선

포팅 작업 완료 후 에이전트는 원본에 없던 추가 기능들을 자발적으로 구현하기 시작했습니다. FastAPI와 Flask의 완전한 통합 지원, 다양한 스키마 검증 도구와의 호환성 확보, 그리고 성능 최적화까지 수행했습니다. 이는 단순한 코드 복사를 넘어서 실제로 소프트웨어를 개선하고 발전시키는 창조적 능력을 보여주는 사례입니다.

## 프롬프트 최적화의 중요한 교훈

### 단순함의 힘

실험 과정에서 얻은 가장 중요한 통찰 중 하나는 프롬프트의 단순함이 성능 향상에 직결된다는 점입니다. 103자의 간단한 프롬프트가 1500자의 복잡한 프롬프트보다 훨씬 우수한 결과를 가져왔습니다. 복잡하고 상세한 지시사항은 오히려 에이전트의 판단력을 흐리고 실행 속도를 저하시키는 결과를 낳았습니다. 이는 AI와의 효과적인 소통에서 명확성과 간결성이 얼마나 중요한지를 보여줍니다.

### 맥락 이해와 자율성의 균형

효과적인 프롬프트는 구체적인 실행 방법보다는 목표와 맥락을 명확히 제시하는 것이 중요했습니다. 에이전트는 "React를 Vue로 포팅하라"는 간단한 지시에서 필요한 모든 세부사항을 스스로 파악하고 실행할 수 있었지만, 과도하게 상세한 단계별 지시는 오히려 창의적 문제 해결을 제한하는 경향을 보였습니다.

## RepoMirror: 자동화를 위한 혁신적 도구

### 도구의 탄생 배경

실험 과정에서 여러 소스와 타겟 저장소 간의 포팅 작업을 관리하는 복잡성이 부각되면서, 이를 해결하기 위한 전용 도구의 필요성이 대두되었습니다. 이에 따라 RepoMirror라는 오픈소스 도구가 개발되었으며, 이는 shadcn 스타일의 오픈박스 원칙을 적용하여 사용자가 초기 설정 후 스크립트와 프롬프트를 자유롭게 커스터마이징할 수 있도록 설계되었습니다.

### 핵심 기능과 작동 방식

RepoMirror는 `npx repomirror init` 명령을 통해 소스와 타겟 디렉토리를 지정하고 변환 작업을 정의할 수 있습니다. 도구는 자동으로 `.repomirror/` 폴더를 생성하여 `prompt.md`, `sync.sh`, `ralph.sh` 등의 핵심 파일들을 배치합니다. 사용자는 `sync` 또는 `sync-forever` 명령을 통해 일회성 또는 지속적인 동기화 작업을 실행할 수 있으며, 각 반복 사이클에서 AI가 소스 코드를 분석하고 타겟 형태로 변환하는 전 과정이 자동화됩니다.

### 실용적 활용 사례

RepoMirror는 React에서 Vue로의 프레임워크 전환뿐만 아니라 gRPC에서 REST API로의 아키텍처 변경, 다양한 프로그래밍 언어 간의 라이브러리 포팅 등 광범위한 용도로 활용할 수 있습니다. 특히 레거시 시스템의 현대화, 멀티플랫폼 지원을 위한 코드베이스 확장, 그리고 새로운 기술 스택으로의 마이그레이션 작업에서 강력한 효과를 발휘합니다.

## 한계와 도전 과제

### 완전성의 문제

실험 결과가 인상적이긴 하지만, 생성된 코드가 항상 완벽하게 작동하는 것은 아니었습니다. 일부 브라우저 데모가 완전히 구현되지 않거나, 특정 엣지 케이스에서 예상과 다른 동작을 보이는 경우들이 발견되었습니다. 이는 자동화된 코드 생성의 근본적인 한계를 보여주며, 여전히 인간 개발자의 검토와 수정이 필요함을 시사합니다.

### 보안과 안전성 우려

무한 루프로 실행되는 AI 에이전트는 강력한 자동화 능력과 함께 잠재적인 위험성도 내포하고 있습니다. 특권 권한을 가진 에이전트가 예상치 못한 방향으로 작업을 수행하거나, 시스템 리소스를 과도하게 사용할 가능성이 있습니다. 또한 자동 생성된 코드에서 보안 취약점이 발생할 수 있으며, 이를 탐지하고 수정하는 메커니즘의 중요성이 강조됩니다.

### 비용과 효율성 고려사항

실험에 소요된 비용은 약 800달러였으며, 1100건의 커밋을 생성하는 데 에이전트당 시간당 10.50달러의 비용이 발생했습니다. 이는 대규모 프로젝트나 지속적인 운영에서는 상당한 비용 부담이 될 수 있음을 의미합니다. 따라서 자동화의 이점과 비용 효율성 사이의 균형점을 찾는 것이 실용적 도입의 핵심 과제가 될 것입니다.

## 개발 패러다임의 변화와 미래 전망

### 의존성 관리 철학의 변화

이 실험은 기존의 복잡한 의존성 추적과 라이브러리 관리 대신, 필요한 핵심 기능만을 선별적으로 포팅하는 새로운 접근 방식을 제시합니다. 개발자들은 이제 "이 의존성이 정말 필요한가?", "핵심 가치만 추출해서 직접 구현하는 것이 더 효율적이지 않을까?"라는 질문을 더 자주 하게 될 것입니다. 이러한 변화는 소프트웨어 개발에서 라이브러리 의존성 지옥(dependency hell) 문제에 대한 근본적인 해결책을 제시할 수 있습니다.

### "Vibe Coding"과 새로운 시장 기회

실험에서 언급된 "vibe coding"이라는 개념은 불과 5개월 전에 등장한 신조어임에도 불구하고, 이미 이로 인한 문제를 해결하는 전문 서비스 시장이 형성되었다는 점이 주목할 만합니다. AI가 생성한 코드의 품질 문제와 예상치 못한 버그들로 인해 새로운 형태의 기술 지원과 복구 서비스에 대한 수요가 급증하고 있습니다. 이는 AI 시대의 소프트웨어 개발에서 품질 보증과 후속 지원의 중요성이 더욱 커지고 있음을 보여줍니다.

### 테스트 주도 개발의 새로운 중요성

완전히 자동화된 개발 환경에서는 전통적인 코드 리뷰나 페어 프로그래밍 대신, 포괄적이고 신뢰할 수 있는 테스트 스위트가 품질 보증의 핵심이 됩니다. 실험자들은 Cucumber 스타일의 예제 테이블 기반 요구사항 정의와 TLA+ 같은 공식 증명 방법론이 AI 에이전트와의 협업에서 특히 효과적임을 발견했습니다. 이는 미래의 소프트웨어 개발에서 명세 기반 개발과 형식적 검증의 중요성이 크게 증가할 것임을 시사합니다.

## 결론: AI 자동화 시대의 새로운 가능성

이 혁신적인 실험은 AI 코딩 에이전트가 단순한 보조 도구를 넘어서 독립적이고 창조적인 개발 파트너로 진화할 수 있음을 보여주었습니다. 무한 루프라는 간단한 개념을 통해 달성된 자동화 수준은 소프트웨어 개발의 미래에 대한 새로운 상상력을 제공합니다. 하지만 동시에 완전성, 보안성, 그리고 비용 효율성이라는 현실적 과제들도 명확히 드러났습니다.

RepoMirror와 같은 도구의 등장은 이러한 자동화 기술이 점차 실용적이고 접근 가능한 형태로 발전하고 있음을 보여줍니다. 앞으로 개발자들은 AI와의 효과적인 협업 방법을 학습하고, 자동화의 이점을 최대화하면서도 그 한계를 이해하고 보완하는 새로운 스킬셋을 개발해야 할 것입니다.

이 실험이 제시하는 가장 중요한 통찰은 AI의 능력이 아니라 그것을 활용하는 인간의 창의성과 지혜가 여전히 혁신의 핵심이라는 점입니다. 무한 루프에 넣은 AI가 놀라운 결과를 만들어낸 것은 AI 자체의 능력보다는 그것을 적절히 설계하고 활용한 인간의 통찰력 덕분이었습니다. 따라서 AI 시대의 개발자들에게는 기술적 숙련도와 함께 AI와의 효과적인 소통과 협업 능력이 더욱 중요한 역량이 될 것입니다.


## 관련 슬라이드

본문 내용을 NotebookLM(`blue_collage` 스타일)으로 요약한 슬라이드입니다.

![coding-agents-infinite-loop-experiment-repomirror 슬라이드 1]({{ '/assets/images/coding-agents-infinite-loop-experiment-repomirror-slide-01.webp' | relative_url }})

![coding-agents-infinite-loop-experiment-repomirror 슬라이드 2]({{ '/assets/images/coding-agents-infinite-loop-experiment-repomirror-slide-02.webp' | relative_url }})

![coding-agents-infinite-loop-experiment-repomirror 슬라이드 3]({{ '/assets/images/coding-agents-infinite-loop-experiment-repomirror-slide-03.webp' | relative_url }})

![coding-agents-infinite-loop-experiment-repomirror 슬라이드 4]({{ '/assets/images/coding-agents-infinite-loop-experiment-repomirror-slide-04.webp' | relative_url }})

## 출처

- RepoMirror 오픈소스 저장소: <https://github.com/repomirrorhq/repomirror>
- Geoff Huntley, "ralph wiggum as a software engineer" (ralph 무한 루프 기법 원전): <https://ghuntley.com/ralph>
