---
title: "Nature급 그림과 교열을 코드로: nature-skills를 직접 돌려 본 학술 버티컬 리포트"
excerpt: "Nature 저널 기준의 과학 그림 생성과 학술 교열을 묶은 오픈소스 Claude 스킬 패키지 nature-skills를 직접 클론하고, nature-figure로 ThakiCloud 서빙 데이터를 제출 등급 2패널 그림으로 렌더링했습니다. 편집 가능한 SVG 36개 텍스트 태그까지 실측하고, 스킬 마켓플레이스의 버티컬 PMF 관점에서 시사점을 정리합니다."
seo_title: "nature-skills 학술 그림·교열 스킬 실측 리포트 - Thaki Cloud"
seo_description: "nature-skills(Yuan1z0825) Claude 스킬 패키지를 직접 실행한 리포트. nature-figure의 rcParams·PALETTE로 제출 등급 matplotlib 2패널 그림을 600dpi로 렌더링하고, 편집 가능한 SVG와 학술 버티컬 마켓플레이스 시사점을 분석"
date: 2026-06-21
last_modified_at: 2026-06-21
tags:
  - claude-skills
  - academic-writing
  - matplotlib
  - data-visualization
  - nature-figure
  - skill-marketplace
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
categories:
  - dev
canonical_url: "https://thakicloud.com/tech-blog/ko/dev/nature-skills-academic-figure-polishing/"
---

![다중 패널 데이터 곡선과 그림판이 학술적 분위기로 떠 있는 추상 이미지]({{ '/assets/images/nature-skills-hero.webp' | relative_url }})
*그림을 '예쁜 플롯'이 아니라 '시각적 논증'으로 다루는 학술 그림 스킬의 분위기를 담았습니다.*

## 개요

연구자가 Claude Code에 가장 자주 의뢰하는 두 가지 작업은 "논문에 들어갈 그림을 만들어 달라"와 "이 영문 초고를 저널 수준으로 다듬어 달라"입니다. 둘 다 일반적인 LLM에게 맡기면 결과가 매번 흔들립니다. 그림은 폰트 크기와 색상이 제멋대로이고, 교열은 규칙 없이 문장을 바꿔 버립니다. 오픈소스 스킬 패키지 nature-skills(Yuan1z0825/nature-skills)는 이 변동성을 검증된 골격으로 강등시키는 것을 목표로 합니다.

화제가 되면서 일부 공유 글은 "GitHub 2만+ 스타"라고 소개했지만, 제가 확인한 실제 수치는 그보다 훨씬 작은 약 265개 수준이었습니다[추정]. 별 개수의 과장은 흔한 일이므로, 이 글에서는 별점이 아니라 도구를 직접 돌려 본 실측 결과로 가치를 평가했습니다. nature-skills를 ThakiCloud 환경에 클론하고, 그 안의 nature-figure 스킬로 실제 서빙 데이터를 제출 등급 그림으로 렌더링한 구현 리포트입니다.

## 이 도구는 무엇인가

저장소를 클론해 확인한 실제 구성은 `skills/` 아래 12개의 스킬(공유 모듈 제외)이었습니다. nature-figure(과학 그림), nature-polishing(학술 교열), nature-academic-search(문헌 검색), nature-citation, nature-reviewer, nature-response(리뷰어 응답) 등 학술 워크플로 전체를 커버합니다. 라이선스는 MIT입니다.

이번 글의 주역인 **nature-figure는 버전 2.0.0**으로, 정적 계층과 동적 계층으로 분리된 라우터 구조를 갖습니다. 큰 설계·API·패턴·QA 지식은 온디맨드 참조 파일에 두고, 매 작업마다 백엔드(Python/R)를 감지해 필요한 조각만 로드합니다. 이는 ThakiCloud가 강조하는 점진적 공개(progressive disclosure)와 정확히 같은 패턴입니다.

가장 인상적인 설계는 **"그림 계약(figure contract)"** 입니다. 코드를 작성하기 전에 핵심 결론 한 문장, 증거 사슬, 아키타입 분류, 백엔드, 저널/내보내기 계약을 먼저 확정하도록 강제합니다. 스킬은 "그림은 시각적 논증이지 고립된 예쁜 플롯이 아니다"라고 못 박습니다. 또한 백엔드 선택을 **차단 게이트(blocking gate)** 로 둡니다. 사용자가 Python인지 R인지 명시하지 않으면 "Python or R?"을 묻고 멈춥니다. 모델이 임의로 기본값을 고르지 못하게 자유도를 줄인 것입니다.

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
<div class="d3-arch" data-arch-root id="sacademicfigurepolishing-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 394, "height": 742, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "FC", "x": 76, "y": 24, "w": 212, "h": 46, "title": "Figure Contract (핵심 결론 정의)"}, {"id": "BE", "x": 85, "y": 148, "w": 195, "h": 52, "title": "백엔드 게이트: Python or R?"}, {"id": "PY", "x": 199, "y": 292, "w": 163, "h": 46, "title": "matplotlib rcParams"}, {"id": "RR", "x": 24, "y": 292, "w": 120, "h": 46, "title": "ggplot2"}, {"id": "STYLE", "x": 94, "y": 416, "w": 177, "h": 46, "title": "rcParams + PALETTE 적용"}, {"id": "EXP", "x": 108, "y": 540, "w": 149, "h": 46, "title": "편집 가능한 SVG / TIFF"}, {"id": "QA", "x": 122, "y": 664, "w": 120, "h": 46, "title": "QA 계약"}], "edges": [{"src": "FC", "dst": "BE", "kind": "data", "line": [182, 70, 182, 148]}, {"src": "BE", "dst": "PY", "kind": "data", "label": "Python", "curve": [[218, 200], [281, 246], [281, 246], [281, 292]], "off": "50%"}, {"src": "BE", "dst": "RR", "kind": "data", "label": "R", "curve": [[147, 200], [84, 246], [84, 246], [84, 292]], "off": "50%"}, {"src": "PY", "dst": "STYLE", "kind": "data", "curve": [[281, 338], [281, 377], [281, 377], [219, 416]]}, {"src": "RR", "dst": "STYLE", "kind": "data", "curve": [[84, 338], [84, 377], [84, 377], [146, 416]]}, {"src": "STYLE", "dst": "EXP", "kind": "data", "line": [182, 462, 182, 540]}, {"src": "EXP", "dst": "QA", "kind": "data", "line": [182, 586, 182, 664]}]});
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
      const container = document.getElementById('sacademicfigurepolishing-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'sacademicfigurepolishing-1';
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
*핵심 결론을 정의하고 Python/R 백엔드 게이트를 통과한 뒤, rcParams와 PALETTE를 적용해 편집 가능한 SVG/TIFF를 내보내고 QA 계약으로 마무리되는 흐름입니다.*

## 설치 및 통합 (실제 명령)

검증은 저장소 바깥의 격리 샌드박스에서 진행한 뒤 정리했습니다.

```bash
# 1) 외부 저장소 클론
git clone --depth 1 https://github.com/Yuan1z0825/nature-skills

# 2) Python 백엔드 의존성 확인 (공용 .venv)
.venv/bin/python -c "import matplotlib; print(matplotlib.__version__)"
# matplotlib 3.11.0
```

nature-figure의 Python 빠른 시작(`static/fragments/backend/python.md`)에는 제출 등급 그림을 위한 `rcParams`가 명시되어 있고, `references/api.md`에는 저널 친화적인 PALETTE가 정의되어 있습니다. 핵심 설정은 다음과 같습니다.

```python
mpl.rcParams.update({
    "font.family": "sans-serif",
    "font.sans-serif": ["Arial", "Helvetica", "DejaVu Sans", "sans-serif"],
    "svg.fonttype": "none",   # SVG 안의 텍스트를 편집 가능하게 유지
    "pdf.fonttype": 42,       # PDF 안의 텍스트도 편집 가능한 TrueType
    "font.size": 7,           # 슬라이드용 대형 패널이 아니면 7pt 기준
    "axes.linewidth": 0.8,
})
# api.md PALETTE 발췌
P = {"blue_main": "#0F4D92", "red_strong": "#B64342", "neutral_dark": "#4D4D4D"}
```

`svg.fonttype: "none"` 한 줄이 핵심입니다. 일반적인 내보내기는 텍스트를 외곽선(path)으로 변환해 일러스트레이터에서 글자를 다시 편집할 수 없게 만듭니다. 이 설정은 텍스트를 `<text>` 태그로 유지해, 저널 교정 단계에서 라벨을 그대로 수정할 수 있게 합니다.

## 실제 실험 결과

스킬의 규칙(rcParams, PALETTE)을 그대로 적용해, ThakiCloud와 직접 관련된 데이터를 그림으로 렌더링했습니다. 주제는 GPU 추론 서빙의 배치 크기에 따른 지연(latency)과 처리량(throughput)을 FP16과 INT8로 비교하는 2패널 그림입니다. 플롯에 들어간 서빙 곡선 수치 자체는 예시(schematic)이며, 측정한 **실측값은 렌더링 과정에서 캡처한 메타 수치**입니다.

```
RENDER_MS=195.4
SVG_BYTES=24131
PNG_BYTES=254233          # 600 dpi
SVG_EDITABLE_TEXT_TAGS=36
PANELS=2 (a:latency, b:throughput)
RCPARAMS_FONT_SIZE=7.0
SVG_FONTTYPE=none
```

핵심 결과는 세 가지입니다. 첫째, 2패널 그림 렌더링이 약 195밀리초로 끝났습니다. 둘째, 600dpi PNG는 약 254KB, SVG는 약 24KB로 가벼웠습니다. 셋째, 그리고 가장 중요한 검증인데, **생성된 SVG 안에 `<text>` 태그가 36개** 존재했습니다. 이는 스킬이 약속한 "편집 가능한 텍스트"가 실제로 지켜졌다는 직접 증거입니다. 외곽선으로 변환됐다면 `<text>` 태그가 0개여야 합니다.

![FP16과 INT8의 추론 지연과 처리량을 비교한 Nature 스타일 2패널 그림]({{ '/assets/images/nature-skills-results.webp' | relative_url }})
*nature-figure의 rcParams와 PALETTE를 적용해 렌더링한 실제 결과물입니다. 왼쪽(a)은 배치 크기별 지연, 오른쪽(b)은 처리량을 보여 줍니다. 서빙 곡선 값은 예시 데이터입니다.*

이 수치들은 모두 제가 직접 실행해 stdout으로 캡처한 값이며, 외부 인용이 아닙니다. 스킬이 산문으로 "예쁘게 그렸습니다"라고 주장하는 대신, 실행 증거로 품질을 증명한다는 점이 핵심입니다.

## ThakiCloud K8s AI/ML SaaS 플랫폼 적용 및 시사점

nature-skills는 두 가지 결을 동시에 보여 줍니다.

데이터 과학 실무 관점에서는, **차트 스타일을 검증된 토큰으로 고정**한다는 발상이 즉시 유용합니다. ThakiCloud의 리포트와 대시보드는 매번 색·폰트·축이 흔들리기 쉬운데, nature-figure처럼 rcParams와 PALETTE를 한곳에 박아 두면 평균 품질이 올라갑니다. 특히 `svg.fonttype: "none"`으로 편집 가능한 SVG를 내보내는 패턴은, 디자인팀이 후처리하는 마케팅·세미나 자료에 그대로 쓸 수 있습니다. 본 글의 결과 그림이 그 증명입니다.

플랫폼 전략 관점에서는, nature-skills가 **학술 버티컬의 PMF(Product-Market Fit) 신호**를 보여 줍니다. 범용 스킬이 아니라 "Nature 저널 제출"이라는 좁고 깊은 사용처에 규칙을 응축했고, 그래서 결과의 일관성이 높습니다. K8s 기반 AI/ML SaaS를 운영하는 ThakiCloud 입장에서, 범용 LLM 위에 도메인 규칙을 얇게 얹은 버티컬 스킬은 차별화의 핵심 패턴입니다. 같은 골격을 의료, 금융, 특허 같은 사내 버티컬에 복제할 수 있습니다.

## 한계 및 반론

첫째, **별 개수 과장**입니다. 일부 공유 글의 "2만+ 스타"는 실제(약 265)와 크게 차이가 났습니다[추정]. 바이럴 신호를 그대로 신뢰하지 말고 직접 돌려 보는 절차가 필요하다는 점을, 이 사례가 다시 확인해 줍니다.

둘째, **그림 데이터의 진위 책임은 사용자에게 있습니다.** 스킬은 그림을 잘 그려 주지만, 거기에 들어가는 수치의 정확성은 보장하지 않습니다. 본 글에서 서빙 곡선을 예시로 명시한 이유도 이것입니다. 실제 논문이나 리포트에서는 측정값만 넣어야 합니다.

셋째, **백엔드 게이트의 강제성**은 자동화 파이프라인에서는 마찰이 될 수 있습니다. "Python or R?"을 매번 묻고 멈추는 동작은 대화형에서는 안전장치지만, 무인 배치에서는 백엔드를 미리 고정해 두는 래핑이 필요합니다.

결론적으로 nature-skills는 "도메인 규칙을 코드로 응축한 버티컬 스킬"의 좋은 사례입니다. 별점이 아니라 36개의 편집 가능한 텍스트 태그 같은 실측 증거로 가치를 판단할 때, 그 설계는 충분히 배울 점이 있습니다.

## 출처

- nature-skills (GitHub, MIT): [github.com/Yuan1z0825/nature-skills](https://github.com/Yuan1z0825/nature-skills)
- 본 글의 모든 실측 수치는 nature-figure v2.0.0을 직접 클론해 로컬에서 렌더링한 값입니다. 별 개수(약 265)는 검색 기준 추정치입니다.
