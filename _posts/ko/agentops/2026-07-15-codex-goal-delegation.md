---
title: "어려운 작업일수록 목표부터 쓰게 합니다: Codex goal 위임 프롬프팅"
excerpt: "한 개발자가 Codex에 어려운 /goal을 줄 때 '다른 스레드가 이 목표를 달성하도록 목표를 대신 써달라'고 먼저 요청한다는 팁을 공유했습니다. 얼핏 말장난처럼 들리지만, 그 안에는 검증 가능한 목표 명세를 모델에게 먼저 작성시키고 그 명세를 새 스레드에 위임한다는 실질적인 에이전트 운용 패턴이 들어 있습니다. Codex goal의 실제 동작을 확인하고, ThakiCloud가 운용하는 Goal Mode와 pge-loop, Paxis 관점에서 이 기법을 짚습니다."
seo_title: "Codex goal 위임 프롬프팅: 검증 가능한 목표를 먼저 쓰게 하는 기법 - Thaki Cloud"
seo_description: "Codex의 /goal 기능과 '다른 스레드를 위한 목표를 대신 쓰게 하는' 메타 프롬프팅 기법을 분석합니다. 측정 가능한 결과, 검증 표면, 제약이라는 목표의 세 요소, ThakiCloud의 Goal Mode와 pge-loop 실제 구현, Paxis Agent-Native Cloud 적용 관점을 정리했습니다."
date: 2026-07-15
last_modified_at: 2026-07-15
tags:
  - ai-coding
  - agentic
  - codex
  - goal-mode
  - agentops
  - verification
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "robot"
canonical_url: "https://thakicloud.com/tech-blog/ko/agentops/codex-goal-delegation/"
categories:
  - agentops
---

## 개요

최근 코딩 에이전트를 쓰는 개발자 사이에서 짧은 팁 하나가 오갔습니다. Codex에 정말 어려운 `/goal`을 줄 때, 곧바로 작업을 시키지 말고 먼저 "다른 스레드가 이 목표를 달성할 수 있도록, 그 목표를 대신 써달라"고 요청하라는 것입니다. 한 번 읽으면 말장난처럼 들립니다. 목표를 달성하라고 시키는 대신 목표를 쓰라고 시키는 것이 무슨 차이를 만드느냐는 의문이 자연스럽습니다.

그런데 이 팁은 에이전트를 오래 굴려본 사람이라면 몸으로 아는 한 가지 사실을 정확히 건드립니다. 어려운 작업이 실패하는 이유는 대개 모델이 약해서가 아니라, 목표가 기계가 판정할 수 있는 형태로 적혀 있지 않아서입니다. 사람은 "이 리팩터를 깔끔하게 끝내줘" 같은 문장을 목표라고 생각하지만, 에이전트에게 이 문장은 언제 멈춰야 할지, 무엇을 성공으로 볼지, 어디까지가 범위인지가 전부 비어 있는 지시입니다. 그래서 이 글은 "목표를 대신 쓰게 한다"는 기법을 하나씩 뜯어보고, ThakiCloud가 쿠버네티스 기반 AI/ML 플랫폼과 에이전트 플랫폼을 운영하면서 이미 같은 원리를 어떻게 코드로 강제하고 있는지 짚겠습니다.

![Codex 목표 위임 프롬프팅 개념 이미지]({{ '/assets/images/codex-goal-delegation-hero.png' | relative_url }})

## Codex goal은 무엇인가

먼저 재료가 되는 기능을 정확히 봐야 합니다. Codex의 `/goal`은 스레드에 지속적인 목표를 붙이는 기능입니다. OpenAI가 공개한 쿠킹북 문서 "Using Goals in Codex"에 따르면, 하나의 목표는 세 가지로 기술되어야 합니다. 측정 가능한 결과, 진행을 확인할 수 있는 검증 표면, 그리고 제약입니다. 이 세 가지가 갖춰지면 목표는 스레드에 붙은 지속적 표적이 됩니다.

동작 방식이 중요합니다. 한 번의 턴이 끝날 때마다 Codex는 현재까지의 증거를 살펴보고 목표가 충족됐는지를 스스로 판정합니다. 아직 아니라면, 그리고 목표가 여전히 활성 상태이고 예산 안에 있다면, 가장 최근 상태에서 이어서 계속 진행합니다. 요약하면 단발 응답이 아니라, 목표라는 종료 조건이 만족될 때까지 관찰과 판정을 반복하는 구조입니다. 오래 걸리는 작업을 "걸어두고 잊는" 워크플로로 바꿀 수 있다는 점이 이 기능의 매력입니다.

여기서 핵심은 목표의 품질이 전부를 결정한다는 사실입니다. 검증 표면이 흐릿하면 Codex는 언제 멈춰야 할지 판단하지 못하고, 제약이 없으면 범위를 벗어나 엉뚱한 파일까지 손을 댑니다. 측정 가능한 결과가 없으면 첫 파일 하나를 고치고는 다 됐다고 종료해 버립니다. 즉 좋은 목표를 쓰는 일 자체가 별도의 기술이고, 이 기술이 부족할 때 어려운 작업이 무너집니다.

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
<div class="d3-arch" data-arch-root id="60715codexgoaldelegation-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 701, "height": 834, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 287, "y": 24, "w": 120, "h": 46, "title": "어려운 작업 아이디어"}, {"id": "B", "x": 278, "y": 148, "w": 138, "h": 68, "title": ["목표가 기계 판정", "가능한 형태인가"]}, {"id": "C", "x": 549, "y": 308, "w": 120, "h": 62, "title": ["헛도는 반복", "또는 조기 종료"]}, {"id": "D", "x": 374, "y": 316, "w": 120, "h": 46, "title": "측정 가능한 결과"}, {"id": "E", "x": 199, "y": 316, "w": 120, "h": 46, "title": "검증 표면"}, {"id": "F", "x": 24, "y": 316, "w": 120, "h": 46, "title": "제약"}, {"id": "G", "x": 199, "y": 448, "w": 120, "h": 62, "title": ["스레드에 붙은", "지속적 목표"]}, {"id": "H", "x": 199, "y": 602, "w": 120, "h": 62, "title": ["턴 종료마다", "증거로 자기 판정"]}, {"id": "I", "x": 199, "y": 756, "w": 120, "h": 46, "title": "수렴 종료"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [347, 70, 347, 148]}, {"src": "B", "dst": "C", "kind": "data", "label": "아니오", "curve": [[416, 203], [609, 262], [609, 262], [609, 308]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "예", "curve": [[384, 216], [434, 262], [434, 262], [434, 316]], "off": "50%"}, {"src": "B", "dst": "E", "kind": "data", "label": "예", "curve": [[309, 216], [259, 262], [259, 262], [259, 316]], "off": "50%"}, {"src": "B", "dst": "F", "kind": "data", "label": "예", "curve": [[278, 203], [84, 262], [84, 262], [84, 316]], "off": "50%"}, {"src": "D", "dst": "G", "kind": "data", "curve": [[434, 362], [434, 409], [434, 409], [319, 455]]}, {"src": "E", "dst": "G", "kind": "data", "line": [259, 362, 259, 448]}, {"src": "F", "dst": "G", "kind": "data", "curve": [[84, 362], [84, 409], [84, 409], [199, 455]]}, {"src": "G", "dst": "H", "kind": "data", "curve": [[268, 510], [282, 556], [282, 556], [268, 602]]}, {"src": "H", "dst": "G", "kind": "data", "label": "미충족·예산 내", "curve": [[250, 602], [236, 556], [236, 556], [250, 510]], "off": "50%"}, {"src": "H", "dst": "I", "kind": "data", "label": "충족", "line": [259, 664, 259, 756], "lx": 259, "ly": 706}]});
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
      const container = document.getElementById('60715codexgoaldelegation-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '60715codexgoaldelegation-1';
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

## "다른 스레드를 위한 목표를 쓰게 한다"는 기법

이제 팁으로 돌아갑니다. 어려운 작업을 앞에 두고, 사람이 곧바로 목표를 잘 쓰기는 어렵습니다. 측정 가능한 결과가 무엇인지, 무엇으로 진행을 검증할지, 어떤 제약을 걸어야 할지를 사람이 처음부터 완벽하게 채우려면 그 자체로 작지 않은 설계 작업입니다. 이 팁이 제안하는 것은 그 설계를 모델에게 먼저 위임하라는 것입니다.

구체적으로는 이렇게 흐릅니다. 첫 번째 스레드에는 "이 어려운 작업을, 다른 스레드가 자율적으로 달성할 수 있도록 하는 목표를 작성하라"고 지시합니다. 이때 모델은 작업을 직접 하지 않습니다. 대신 작업을 이해하고, 무엇이 성공인지, 어떻게 검증할지, 어디까지가 범위인지를 명시한 목표 명세를 산출합니다. 사람은 그 명세를 검토하고 다듬은 뒤, 새 스레드에 목표로 넣어 실제 실행을 맡깁니다. 실행 스레드는 잘 정의된 종료 조건을 갖고 출발하므로, 앞에서 말한 헛도는 반복이나 조기 종료에 훨씬 덜 빠집니다.

이 기법이 효과적인 이유는 두 가지입니다. 첫째, 목표를 쓰는 일과 목표를 달성하는 일을 분리합니다. 두 작업은 성격이 다릅니다. 목표 작성은 문제를 넓게 이해하고 성공 기준을 언어로 고정하는 일이고, 목표 달성은 그 기준을 향해 좁게 파고드는 일입니다. 한 스레드가 둘을 동시에 하려 하면 검증 기준을 정하는 도중에 성급하게 구현으로 넘어가고, 결국 자기가 세우지도 않은 기준으로 자기를 채점하는 모순에 빠집니다. 분리하면 각 스레드가 한 가지에 집중합니다.

둘째, 사람에게 검토 지점을 만들어 줍니다. 모델이 산출한 목표 명세는 실행 전에 사람이 읽고 고칠 수 있는 물건입니다. 검증 표면이 약하면 이 단계에서 보강할 수 있고, 범위가 넓으면 제약을 더 걸 수 있습니다. 실행이 시작되고 나서 잘못을 발견하면 비용이 크지만, 목표 명세 단계에서 잡으면 저렴합니다. 즉 이 기법은 단순한 프롬프트 재주가 아니라, 값싼 검토 지점을 한 겹 끼워 넣는 구조적 장치입니다.

물론 이것은 만능이 아닙니다. 한 개발자 뉴스레터는 이 방식이 "네 시간짜리 작업을 걸어두고 잊는 워크플로로 바꾼다"고 표현했는데, 이는 잘 맞은 사례에 대한 인상이지 보장이 아닙니다. 목표를 잘 쓰게 하는 데 성공하더라도, 실행 스레드가 그 목표를 향해 제대로 수렴하는지는 별개의 문제입니다. 그래서 이 기법은 뒤에서 이야기할 검증 게이트와 함께 쓰일 때 비로소 값을 합니다.

## ThakiCloud 제품 적용 시사점

이 기법이 낯설지 않은 이유가 있습니다. ThakiCloud는 이미 같은 원리를 프롬프트 부탁이 아니라 코드 규율로 강제하고 있기 때문입니다. 주제가 에이전트 운용인 만큼 여기서는 우리의 에이전트 플랫폼 Paxis 관점을 중심에 두되, 그 아래 인프라인 ai-platform과의 연결도 함께 봅니다.

Paxis는 ThakiCloud의 Agent-Native Cloud로, 스킬과 도구와 정책과 감사 로그를 일급 리소스로 다루는 제어 평면입니다. 그 안에 Goal Mode라는 실행기가 있습니다. Goal Mode에서 목표를 만들 때 우리는 `check_cmd`와 `success_criteria`, 그리고 예산을 비워 두지 않도록 규칙으로 못 박아 두었습니다. 이 세 가지는 Codex 목표의 세 요소와 거의 일대일로 대응합니다. `success_criteria`는 측정 가능한 결과이고, `check_cmd`는 진행을 판정하는 검증 표면이며, 예산은 제약입니다. 목표가 빈 껍데기로 만들어지면 첫 반복에서 게이트가 실패하도록 설계해 두었기 때문에, "목표를 잘 쓰지 않으면 시작조차 되지 않는" 상태를 코드가 보장합니다.

"다른 스레드를 위한 목표를 쓰게 한다"는 위임 구조도 우리 안에 있습니다. 복잡한 요청이 들어오면 메인 에이전트가 그것을 하위 작업으로 분해하고, 각 하위 작업을 별도의 서브에이전트에 위임합니다. 이때 분해하는 주체와 실행하는 주체가 분리되는데, 이는 이 글의 기법이 목표 작성 스레드와 목표 실행 스레드를 나누는 것과 정확히 같은 발상입니다. 분해는 판단이 필요하므로 상위 모델이 맡고, 실행은 좁은 작업이므로 더 저렴한 모델에 내려보냅니다. 워커는 싸게, 게이트는 비싸게라는 원칙이 여기서 나옵니다.

무엇보다 우리는 팬아웃한 결과를 검증 없이 합치지 않습니다. 목표를 아무리 잘 써서 위임하더라도, 실행 결과가 옳은지는 실행 주체가 아니라 별도의 검증 단계가 판정해야 합니다. 코드 산출물은 테스트를 실제로 돌려 종료 코드로 판정하고, 콘텐츠나 판단 산출물은 서로 다른 시각의 검증기를 여러 개 띄워 다수결로 걸러냅니다. 모델이 "다 된 것 같습니다"라고 스스로 보고하는 문장은 루프의 종료 조건이 될 수 없습니다. 이 규율은 Codex goal의 "턴 종료마다 증거로 자기 판정한다"는 동작을 우리가 어떻게 신뢰 가능한 형태로 굳혔는지를 보여 줍니다.

인프라 렌즈에서도 연결이 있습니다. 이렇게 목표를 잘게 나누어 검증하며 돌리는 루프는 계산 자원을 꾸준히 소모합니다. ai-platform은 쿠버네티스와 Kueue 기반 GPU 스케줄링, vLLM 서빙, 멀티테넌트 격리를 제공하는 계층으로, 이런 에이전트 루프가 값싸고 안정적으로 돌 수 있는 바닥을 만듭니다. 저비용 서빙이 에이전트 경제성을 만들고, 그 위에서 Paxis의 목표 위임과 검증 루프가 실질적으로 성립합니다. 두 렌즈가 서로를 보완하는 구조입니다.

## 한계 및 반론

이 기법을 과대평가하지 않기 위해 반대편도 짚겠습니다.

첫째, 목표를 쓰게 하는 단계 자체가 실패할 수 있습니다. 모델이 그럴듯하지만 검증 불가능한 목표를 산출하면, 실행 스레드는 여전히 무엇을 성공으로 볼지 모른 채 출발합니다. 오히려 사람이 직접 짧고 단단한 목표를 쓰는 편이 나은 경우가 많습니다. 그래서 모델이 쓴 목표 명세는 반드시 사람이 검토하는 지점이 있어야 하고, 검토 없이 곧바로 실행에 넘기는 것은 값싼 검토 지점을 스스로 버리는 셈입니다.

둘째, 모든 작업에 이 오버헤드가 정당한 것은 아닙니다. 한 파일을 고치는 단순 수정이나 즉답형 질문에까지 목표를 대신 쓰게 하고 스레드를 나누는 것은 과잉입니다. 이 기법은 종료 조건이 흐릿하고 오래 걸리며 자율 실행이 가치가 있는 어려운 작업에서만 값을 합니다. 우리 내부 규칙도 반복 구현이나 수렴형 작업에만 루프 도구를 쓰고, 단발 편집에는 억지로 적용하지 않도록 선을 그어 두었습니다.

셋째, 자율 실행이 길어질수록 사람이 결과를 신뢰하고 검토를 멈추는 경향이 생깁니다. 목표를 잘 위임했다는 안도감이 오히려 위험합니다. 검증기가 아무것도 걸러내지 못한다면 그것은 전부 통과라는 신호가 아니라 검증기가 고장 났다는 신호일 가능성이 큽니다. 그래서 핵심 산출물은 주기적으로 사람이 표본을 뽑아 직접 확인해야 하고, 검증기는 통과가 아니라 반증을 지향하도록 설계해야 합니다.

정리하면, "어려운 작업일수록 목표부터 쓰게 하라"는 팁은 프롬프트 요령이 아니라 목표 작성과 목표 실행을 분리하고 그 사이에 검토 지점을 끼우는 구조적 조언입니다. Codex의 goal 기능이 이를 개인 개발자 손에 쥐여 주었다면, ThakiCloud는 같은 원리를 Paxis의 Goal Mode와 검증 루프로 팀 단위에서 강제합니다. 목표를 잘 쓰는 일이 곧 에이전트를 잘 굴리는 일이라는 사실은, 도구가 무엇이든 변하지 않습니다.

## 출처

- OpenAI Cookbook, ["Using Goals in Codex"](https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex)
- 원 트윗: nickbaumann_, Codex goal 위임 팁 게시글 (X/Twitter 특성상 자동 페치 검증 불가, 원문 확인 불가)
