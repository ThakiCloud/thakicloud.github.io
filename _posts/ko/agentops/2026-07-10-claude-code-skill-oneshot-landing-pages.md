---
title: "한 번에 프리미엄 랜딩페이지를 만드는 Claude Code 스킬의 구조"
seo_title: "Claude Code 스킬로 랜딩페이지 원샷 생성 - Thaki Cloud"
seo_description: "Claude Code 스킬이 어떻게 자연어 한 번으로 프리미엄 랜딩페이지 HTML을 만들어 내는지 SKILL.md 기반 SOP 구조로 분석하고, ThakiCloud의 Paxis 스킬 하네스 운용 관점에서 검증합니다."
excerpt: "자연어 요청 한 번으로 프리미엄 랜딩페이지를 만든다는 Claude Code 스킬이 실제로 어떤 구조로 동작하는지 분해하고, 스킬을 일급 리소스로 다루는 ThakiCloud Paxis 관점에서 검증합니다."
date: 2026-07-10
tags:
  - claude-code
  - agent-skills
  - agentops
  - landing-page
  - frontend
  - paxis
categories:
  - agentops
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/ko/agentops/claude-code-skill-oneshot-landing-pages/"
audiobook: /assets/audio/posts/claude-code-skill-oneshot-landing-pages/audiobook-ko.mp3
audiobook_note: "AI 로컬 합성 오디오북 (Qwen3-TTS)"
---

최근 X에서 한 개발자가 "Claude Code가 프리미엄 랜딩페이지를 한 번에 만들도록 스킬을 만들었다"며 영상 속 세 개의 사이트를 모두 원샷으로 뽑았다고 공유했습니다([@the_cyw](https://x.com/the_cyw/status/2075338024406409239)). 반응이 뜨거웠던 이유는 결과물의 완성도 때문이지만, 엔지니어 입장에서 더 흥미로운 지점은 따로 있습니다. 똑같은 모델에 똑같이 "랜딩페이지 만들어줘"라고 해도 평범한 결과가 나오는데, 스킬 하나를 얹었더니 에이전시급 페이지가 한 번에 나온다는 사실입니다. 에이전트에게 반복 작업을 맡기는 엔지니어라면, 품질을 끌어올리는 지렛대가 모델 교체가 아니라 스킬 설계에 있다는 것이 여기서 가져갈 결론입니다.

![한 번에 프리미엄 랜딩페이지를 만드는 Claude Code 스킬의 구조 개념을 형상화한 이미지](/assets/images/claude-code-skill-oneshot-landing-pages-hero.webp)
*글의 핵심 개념을 형상화했습니다.*

## 개요

Claude Code 스킬은 마법이 아니라 **표준 작업 절차서(SOP)**입니다. 모델을 더 똑똑하게 바꾸는 것이 아니라, 모델이 이미 가진 능력을 특정 방향으로 강하게 제약해 평균 품질을 끌어올립니다. 랜딩페이지 스킬의 경우 그 제약이 곧 디자인 원칙, 레이아웃 규칙, 산출 포맷입니다.

이 관점은 ThakiCloud가 에이전트를 운용하는 원칙과 정확히 겹칩니다. 에이전트의 품질은 모델 등급이 아니라 그 모델을 감싸는 계약 구조에서 나온다는 것입니다. 랜딩페이지 스킬은 그 계약 구조를 프런트엔드 디자인이라는 좁은 영역에 집중시킨 좋은 사례입니다. 자유도를 줄여 평균 품질을 올리는 전형적인 스킬 설계이기도 합니다.

## 이 기술은 무엇인가

Claude Code 스킬은 본질적으로 `SKILL.md`라는 마크다운 파일 하나입니다. 이 파일 안에는 에이전트가 특정 작업을 할 때 따라야 할 원칙과 규칙, 그리고 사용자의 선호가 담깁니다. 사용자가 자연어로 요청하면, 관련 스킬이 에이전트의 컨텍스트에 주입되고, 에이전트는 그 지침을 SOP처럼 따르며 로컬에서 HTML과 CSS, 자바스크립트를 직접 생성합니다.

랜딩페이지 스킬이 만들어 내는 산출물의 형태는 공개된 여러 스킬에서 공통적으로 관찰됩니다. 하나의 자기완결형 HTML 파일로, 모든 CSS는 `<style>` 안에 인라인으로, 모든 자바스크립트는 `<script>` 안에 인라인으로 들어갑니다. 외부 의존성은 Google Fonts와 CDN으로 불러오는 GSAP 애니메이션 라이브러리 정도로 제한됩니다([Claude Directory](https://www.claudedirectory.org/skills/claude-skills-landing)). 파일 하나만 있으면 어디든 올려서 바로 서비스할 수 있는 구조입니다.

{% raw %}
<!--
  animated-architecture-diagram - self-contained D3 embed template.
  HuggingFace research-article style: declarative NODES/EDGES/SEQ model,
  data(solid)/event(dashed) edges, hover-trace + tooltip, flow-dot animation
  along edge paths, replay button, scroll-into-view autoplay, reduced-motion +
  light/dark aware. The renderer injects window.__ARCH_SPEC__ at the marker.
  Format (D3 machinery + CSS) is owned by this committed template; the model
  only authors the JSON spec (content). See references/spec-schema.md.
-->
<div class="d3-arch" data-arch-root id="skilloneshotlandingpages-1"></div>
<style>
  /* ---- Theme tokens (standalone; light default + dark override) ---- */
  .d3-arch {
    --page-bg: #ffffff;
    --surface-bg: #f7f8fa;
    --text-color: #1a1d21;
    --muted-color: #6b7280;
    --border-color: #d5d9e0;
    --primary-color: hsl(217 91% 55%); /* brand accent, swap for #1B4F72 etc. */
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 381, "height": 676, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "U", "x": 228, "y": 24, "w": 121, "h": 62, "title": ["자연어 요청", "프리미엄 랜딩페이지 생성"]}, {"id": "A", "x": 123, "y": 178, "w": 142, "h": 46, "title": "Claude Code 에이전트"}, {"id": "S", "x": 24, "y": 24, "w": 149, "h": 62, "title": ["SKILL.md", "디자인 원칙·레이아웃 규칙·선호"]}, {"id": "G", "x": 123, "y": 302, "w": 142, "h": 62, "title": ["단일 HTML 생성", "인라인 CSS · 인라인 JS"]}, {"id": "D1", "x": 221, "y": 442, "w": 120, "h": 62, "title": ["Google Fonts", "CDN"]}, {"id": "D2", "x": 46, "y": 442, "w": 120, "h": 62, "title": ["GSAP 애니메이션", "CDN"]}, {"id": "O", "x": 134, "y": 582, "w": 120, "h": 62, "title": ["자기완결형 페이지", "파일 하나로 배포"]}], "edges": [{"src": "U", "dst": "A", "kind": "data", "curve": [[289, 86], [289, 132], [289, 132], [225, 178]]}, {"src": "S", "dst": "A", "kind": "event", "label": "주입", "curve": [[99, 86], [99, 132], [99, 132], [162, 178]], "off": "50%"}, {"src": "A", "dst": "G", "kind": "data", "line": [194, 224, 194, 302]}, {"src": "G", "dst": "D1", "kind": "data", "curve": [[232, 364], [281, 403], [281, 403], [281, 442]]}, {"src": "G", "dst": "D2", "kind": "data", "curve": [[155, 364], [106, 403], [106, 403], [106, 442]]}, {"src": "D1", "dst": "O", "kind": "data", "curve": [[281, 504], [281, 543], [281, 543], [232, 582]]}, {"src": "D2", "dst": "O", "kind": "data", "curve": [[106, 504], [106, 543], [106, 543], [155, 582]]}]});
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
      const container = document.getElementById('skilloneshotlandingpages-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'skilloneshotlandingpages-1';
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

핵심은 "원샷"이라는 표현입니다. 사용자가 원하는 바를 평범한 문장으로 설명하면, 에이전트가 여러 번의 왕복 없이 한 번에 전체 페이지를 만들어 냅니다. 이것이 가능한 이유는 모델이 창의력을 발휘해서가 아니라, 스킬이 이미 "좋은 랜딩페이지란 무엇인가"에 대한 결정을 대부분 대신 내려 주기 때문입니다.

## 스킬이 대신 내려 주는 결정들

스킬 없이 랜딩페이지를 요청하면 결과가 제네릭한 이유는 명확합니다. 에이전트가 매번 처음부터 레이아웃, 여백, 타이포그래피, 색 대비, 애니메이션 타이밍을 새로 판단해야 하고, 그 판단은 안전한 평균값으로 수렴하기 때문입니다. 공개된 프리미엄 랜딩페이지 스킬들은 바로 이 판단을 미리 고정합니다([MindStudio 분석](https://www.mindstudio.ai/blog/claude-code-landing-page-generator-skill-city-service-matrix-seo)).

이런 스킬이 담는 디자인 철학은 대체로 일관됩니다. 불필요한 요소를 걷어 낸 의도적 절제를 바탕에 깔고, 대칭을 깨는 비대칭 레이아웃으로 시선을 유도하며, 그 위에 전환율을 높이는 심리적 장치를 얹습니다. 결과물이 템플릿처럼 보이지 않고 사람이 직접 다듬은 것처럼 느껴지도록 브랜드 권위와 전환이라는 두 축을 함께 겨냥합니다. 어떤 스킬 제작자는 이를 "정상급 디자인 에이전시의 전문성을 에이전트에게 이식하는 것"이라고 표현하기도 합니다.

여기서 얻는 교훈은 프런트엔드에만 국한되지 않습니다. 좋은 스킬은 모델에게 자유를 주는 것이 아니라, 검증된 골격을 주고 그 안을 채우게 하는 것입니다. 디자인 토큰, 레이아웃 그리드, 산출 포맷을 코드처럼 고정할수록 매 호출의 편차가 줄고 평균 품질이 올라갑니다. 반대로 "멋지게 만들어줘" 같은 산문 부탁만으로는 매번 다른 결과가 나옵니다.

## 직접 만들 때의 유의점

이런 스킬을 직접 작성해 본다면 몇 가지가 중요합니다. 첫째, 산출 포맷을 명시적으로 못박아야 합니다. "단일 HTML, 인라인 CSS/JS, 외부 의존성은 폰트와 GSAP만"처럼 구조를 규정하면 배포와 이식이 단순해집니다. 둘째, 디자인 판단을 규칙으로 환원해야 합니다. 여백 스케일, 타이포그래피 대비, 허용 색 팔레트, 애니메이션은 레이아웃을 흔들지 않는 `transform`과 `opacity` 위주로 같은 규칙을 SOP에 적어 두면 에이전트가 매번 다시 고민하지 않습니다. 셋째, 실패 사례를 담아야 합니다. 스킬에서 가장 밀도 높은 정보는 "이렇게 하지 마라" 목록입니다. 레이아웃을 흔드는 애니메이션 금지, 접근성 기본 위반 금지 같은 항목이 결과 품질을 실제로 지켜 줍니다([Ryan Doser 가이드](https://ryandoser.com/claude-code-landing-pages/)).

한 가지 덧붙이면, 스킬은 세금이기도 합니다. 스킬이 컨텍스트에 로드되는 순간부터 토큰 비용을 지불하므로, 모든 문장이 "이게 없으면 에이전트가 틀리는가"라는 질문을 통과해야 합니다. 불필요한 미사여구는 순손실입니다.

## ThakiCloud 제품 적용 시사점

이 사례가 ThakiCloud에 특별히 와닿는 이유는, 우리가 스킬을 일급 리소스로 다루는 플랫폼을 직접 운용하기 때문입니다.

**Paxis 관점(에이전트·스킬).** Paxis는 ThakiCloud의 Agent-Native Cloud로, Skills와 Tools, Policies, Audit Logs를 일급 리소스로 다룹니다. 랜딩페이지 스킬 같은 단위 능력은 정확히 Paxis의 Skill Harness가 관리하는 대상입니다. 우리는 수백 개 규모의 스킬을 BM25로 선택해 요청에 맞는 것만 에이전트 컨텍스트에 주입하고, 격리된 샌드박스에서 실행하며, 모든 행동을 정책 게이트와 감사 로그로 통과시킵니다. 랜딩페이지 스킬 하나가 잘 동작한다는 것은, 같은 패턴을 슬라이드 생성, 문서 렌더링, 인프라 배포 같은 다른 도메인으로 확장할 수 있다는 뜻이기도 합니다. 실제로 이 블로그의 이미지와 문서 산출물도 동일한 스킬 하네스 위에서 생성됩니다.

특히 이번 사례가 보여 주는 "포맷은 코드가 소유하고 모델은 내용만 채운다"는 원칙은 Paxis의 설계 철학과 그대로 맞닿아 있습니다. 산출 구조를 결정론적으로 고정하고 모델에게는 판단할 여지를 좁혀 줄수록, 다양한 모델 등급에서도 일관된 품질이 나옵니다.

**ai-platform 관점(인프라).** 이런 생성 워크로드를 외부 API에만 의존하지 않고 자체 인프라에서 돌리고 싶은 고객도 있습니다. ThakiCloud의 ai-platform은 K8s와 Kueue 기반 GPU 스케줄링 위에서 생성 모델을 서빙하므로, 온프레미스나 소버린 환경에서도 이런 스킬 기반 파이프라인을 자체 호스팅할 수 있습니다. 랜딩페이지 생성처럼 반복적이고 정형화된 작업일수록, 낮은 서빙 비용이 곧 에이전트 경제성으로 이어집니다.

## 한계 및 반론

물론 과장은 경계해야 합니다. "한 번에 프리미엄 페이지"라는 표현은 시연 조건에서 가장 잘 성립합니다. 실제 제품 랜딩페이지는 브랜드 자산, 카피 검수, 접근성 준수, 성능 예산, A/B 테스트 같은 요구가 겹치므로 원샷 산출물은 훌륭한 초안이지 최종본이 아닙니다. 특히 인라인으로 뭉친 단일 HTML은 빠른 배포에는 유리하지만, 여러 페이지가 자산을 공유하는 실제 사이트에서는 캐싱과 유지보수 측면에서 다시 분리해야 할 수 있습니다.

또한 스킬이 담은 디자인 취향이 곧 결과의 상한입니다. 스킬이 특정 미감에 최적화되어 있으면 그 미감에서 벗어난 요구에는 오히려 저항합니다. 이것은 버그가 아니라 설계된 트레이드오프입니다. 자유도를 줄여 평균을 올린 대가로 극단값을 포기한 것이며, 다양한 브랜드를 다뤄야 하는 팀이라면 스킬을 하나로 두지 않고 미감별로 나누는 편이 낫습니다.

이 사례의 진짜 가치는 "예쁜 페이지가 한 번에 나온다"가 아니라, **에이전트 품질은 모델이 아니라 스킬 설계에서 나온다**는 원칙을 눈에 보이게 증명했다는 데 있습니다. 그리고 그 원칙을 플랫폼 차원에서 운용 가능한 형태로 제품화한 것이 바로 Paxis입니다.


## 관련 슬라이드

본문 내용을 NotebookLM(`structured_mint` 스타일)으로 요약한 슬라이드입니다.

![claude-code-skill-oneshot-landing-pages 슬라이드 1]({{ '/assets/images/claude-code-skill-oneshot-landing-pages-slide-01.webp' | relative_url }})

![claude-code-skill-oneshot-landing-pages 슬라이드 2]({{ '/assets/images/claude-code-skill-oneshot-landing-pages-slide-02.webp' | relative_url }})

![claude-code-skill-oneshot-landing-pages 슬라이드 3]({{ '/assets/images/claude-code-skill-oneshot-landing-pages-slide-03.webp' | relative_url }})

![claude-code-skill-oneshot-landing-pages 슬라이드 4]({{ '/assets/images/claude-code-skill-oneshot-landing-pages-slide-04.webp' | relative_url }})

## 출처

- [@the_cyw, "I built a skill to let my Claude Code build premium landing pages"](https://x.com/the_cyw/status/2075338024406409239)
- [Claude Directory: Landing Page Skills](https://www.claudedirectory.org/skills/claude-skills-landing)
- [MindStudio: Claude Code Landing Page Generator Skill](https://www.mindstudio.ai/blog/claude-code-landing-page-generator-skill-city-service-matrix-seo)
- [Ryan Doser: How to Build Landing Pages With Claude Code](https://ryandoser.com/claude-code-landing-pages/)
