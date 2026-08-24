---
title: "설계규칙을 검증 스크립트로 바꾸는 에이전트를 실행으로 채점하다: Rule2DRC 벤치마크"
seo_title: "Rule2DRC 반도체 DRC 검증 자동화 LLM 에이전트 벤치마크 | ThakiCloud"
seo_description: "자연어 설계규칙을 실행 가능한 DRC 검증 스크립트로 번역하는 LLM 에이전트를, 코드 유사도가 아니라 KLayout 실행 결과로 채점하는 대규모 벤치마크입니다. 규칙 1,000개와 레이아웃 13,921개로 구성되며, 정답 레이아웃을 에이전트에 주지 않고도 기능적 정확성을 잽니다. 서울대와 삼성 AI센터가 사내망 배포용 GUI 앱까지 만들었습니다."
excerpt: "그럴듯한 코드가 아니라 실제로 통과시키는 코드를 재는 것이 Rule2DRC의 핵심입니다. 전문가 수작업이던 EDA 검증을 도메인 특화 에이전트가 규제·보안 현장에서 대체하는 실증 사례를 살펴봅니다."
date: 2026-07-23
tags:
  - DRC
  - 설계검증
  - EDA
  - 반도체
  - LLM 에이전트
  - 실행 기반 채점
  - 벤치마크
  - 도메인 특화 에이전트
  - 온프레미스
  - KLayout
categories: [research]
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/ko/research/rule2drc-drc-llm-agent-benchmark/"
---

칩을 양산하기 전 수천 개의 설계규칙을 검증하는 일을 자동화하고 싶은 엔지니어라면 이 글을 읽을 가치가 있습니다. Rule2DRC(arXiv:2605.15669, 서울대 송현오 교수팀·삼성 AI센터, ICML 2026)는 자연어로 쓰인 설계규칙을 실행 가능한 DRC 검증 스크립트로 번역하는 LLM 에이전트를, 코드가 얼마나 정답과 비슷하게 생겼는지가 아니라 실제 검증엔진에서 돌려 통과시키는지로 채점하는 대규모 벤치마크입니다. 이 팀은 여기서 그치지 않고 삼성 사내 보안망에 배포할 수 있는 레이아웃 네이티브 에이전트 GUI 앱까지 만들었습니다. 도메인 특화 에이전트가 규제와 보안이 빡센 산업 현장에 실제로 들어가고 있다는 뜻입니다.

![자연어 설계규칙이 실행 가능한 검증 코드로 번역되는 흐름을 형상화한 추상 이미지](/assets/images/rule2drc-drc-llm-agent-benchmark-hero.webp)
*레이아웃 격자 패턴이 구조화된 검증 로직으로 흘러 들어가는 모습을 형상화했습니다.*

## 왜 읽어야 하나

이 절은 도메인 특화 LLM 에이전트를 규제·보안 환경에 배포하려는 엔지니어와, EDA·반도체 검증 같은 전문 작업을 에이전트로 자동화하려는 플랫폼 담당자를 대상으로 합니다. 전문가의 손을 타던 검증 작업을 에이전트에게 맡기려면, 그 에이전트가 정말 제대로 하는지부터 믿을 수 있어야 합니다. Rule2DRC는 이 질문에 실행으로 답합니다. 에이전트가 만든 스크립트를 실제 검증엔진에서 돌려 기능적 정확성으로 채점하는 것입니다. 그럴듯하게 생긴 코드와 실제로 동작하는 코드는 다르고 산업 현장에서 필요한 것은 후자입니다.

## 개요

반도체 칩은 양산에 들어가기 전에 수천 개의 기하학적 설계규칙을 만족하는지 검증받아야 합니다. 이 검증을 DRC, 즉 Design Rule Check라고 부릅니다. 그런데 문제는 규칙 자체가 자연어 문서로 쓰여 있다는 점입니다. "금속 배선 사이의 최소 간격은 얼마 이상이어야 한다" 같은 문장을 KLayout이나 SVRF 같은 전용 검증 언어의 스크립트로 옮겨야 검증 엔진이 실제로 레이아웃을 검사할 수 있습니다.

이 번역 작업이 만만치 않습니다. 공정 노드가 바뀔 때마다, 파운드리가 바뀔 때마다 수천 개의 규칙을 전문가가 손으로 스크립트로 옮겨 왔습니다. 반복적이면서도 고도의 전문성이 필요한 일이라, 자연스럽게 LLM 에이전트로 자동화하려는 시도가 나왔습니다. 규칙 문서를 읽고 검증 스크립트를 생성하고 틀리면 디버깅까지 하는 에이전트를 만들자는 것입니다.

여기서 진짜 병목은 에이전트를 만드는 것보다 그 에이전트를 제대로 평가하는 것이었습니다. 기존 벤치마크는 두 가지 한계를 안고 있었습니다. 하나는 평가셋이 작다는 것이고 다른 하나는 생성된 스크립트를 실제로 실행하지 않고 정답 코드와의 유사도로만 채점한다는 것입니다. 게다가 실행 피드백을 쓰려던 기존 방법들은 채점을 위해 정답 테스트 레이아웃을 에이전트의 입력으로 미리 요구하는 경우가 많았습니다. 실전에서는 그런 정답 레이아웃이 주어지지 않는데도 말입니다.

## 이 벤치마크는 무엇인가

Rule2DRC는 이 두 한계를 정면으로 겨냥합니다. 규칙을 스크립트로 옮기는 태스크 1,000개와, 그 스크립트를 채점하기 위한 칩 레이아웃 13,921개로 구성된 대규모 벤치마크입니다. 채점 방식이 핵심입니다. AI가 생성한 스크립트를 KLayout 검증 엔진에서 실제로 실행해, 레이아웃을 얼마나 올바르게 검사하는지를 기능적 정확성으로 잽니다. 코드가 정답과 비슷하게 생겼는지는 보지 않습니다.

정답 레이아웃을 에이전트의 입력으로 주지 않는다는 점이 특히 중요합니다. 채점하는 쪽에는 방대한 평가용 레이아웃이 있지만, 에이전트는 규칙 문서만 보고 스크립트를 짜야 합니다. 실전 상황을 그대로 재현한 셈입니다. 에이전트에게 정답지를 미리 보여 주고 채점하던 이전 방식과 여기서 갈립니다.

아래 도표가 Rule2DRC의 평가 흐름을 보여 줍니다.

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
<div class="d3-arch" data-arch-root id="2drcdrcllmagentbenchmark-1"></div>
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
  /* Size to the spec's natural canvas: JS caps max-width at the spec width so a
     narrow/portrait diagram is never stretched to the article column (blur + giant
     vertical figures); wide diagrams scale down but keep min-width 760 + scroll. */
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 352, "height": 832, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 25, "y": 24, "w": 120, "h": 62, "title": ["자연어 설계규칙", "(공정 규칙 문서)"]}, {"id": "B", "x": 25, "y": 164, "w": 120, "h": 62, "title": ["LLM 에이전트", "스크립트 생성·디버깅"]}, {"id": "C", "x": 25, "y": 304, "w": 120, "h": 62, "title": ["DRC 스크립트 후보", "(여러 개)"]}, {"id": "D", "x": 24, "y": 444, "w": 121, "h": 62, "title": ["SplitTester", "변별 테스트 케이스 생성"]}, {"id": "E", "x": 91, "y": 598, "w": 120, "h": 62, "title": ["KLayout 실행", "기능적 정확성 채점"]}, {"id": "F", "x": 91, "y": 738, "w": 120, "h": 62, "title": ["Best-of-N 선택", "최적 스크립트 확정"]}, {"id": "G", "x": 200, "y": 444, "w": 120, "h": 62, "title": ["평가용 레이아웃", "13,921개"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [85, 86, 85, 164]}, {"src": "B", "dst": "C", "kind": "data", "line": [85, 226, 85, 304]}, {"src": "C", "dst": "D", "kind": "data", "line": [85, 366, 85, 444]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[111, 506], [151, 552], [151, 552], [151, 598]]}, {"src": "E", "dst": "F", "kind": "data", "line": [151, 660, 151, 738]}, {"src": "G", "dst": "E", "kind": "event", "label": "채점에만 사용", "curve": [[260, 506], [260, 552], [260, 552], [195, 598]], "off": "50%"}, {"src": "E", "dst": "D", "kind": "event", "label": "실행 피드백", "curve": [[116, 598], [65, 552], [65, 552], [77, 506]], "off": "50%"}]});
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
      const container = document.getElementById('2drcdrcllmagentbenchmark-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '2drcdrcllmagentbenchmark-1';
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
        // Never upscale past the spec's natural width; keep 760px readability
        // floor (with horizontal scroll) only for diagrams that are actually wide.
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

여기서 두 번째 기여인 SplitTester가 등장합니다. 에이전트가 여러 후보 스크립트를 내놓았을 때, 어느 것이 가장 좋은지 고르는 일이 생각보다 어렵습니다. 후보들이 비슷하게 동작해서 겉으로는 구분이 안 되는 경우가 많기 때문입니다. SplitTester는 실행 피드백으로 변별력 있는 테스트 케이스를 스스로 생성하는 테스터 에이전트입니다. 구분되지 않던 후보들을 서로 다른 결과가 나오도록 갈라내는 테스트를 만들어, 어느 후보가 진짜 맞는지 드러나게 합니다. 이렇게 후보를 변별하면 여러 개 중 하나를 고르는 Best-of-N 선택 성능이 눈에 띄게 올라갑니다.

논문의 정량 결과에서는 프런티어 모델과 오픈소스 모델 사이의 격차가 뚜렷하게 나타났고 SplitTester를 붙였을 때 후보 선택 성능이 개선됐습니다. 다만 모델별 정확한 통과율 수치는 논문 표를 직접 확인하시길 권합니다. 이 벤치마크는 ICML 2026에 채택됐고 삼성 AI센터 NPRC 워크숍에서 우수연구상과 최우수포스터상을 받았다고 소개됐습니다.

## 왜 실행 기반 채점이 중요한가

코드 유사도 채점에서 실행 기반 채점으로 넘어간 것이 이 연구의 진짜 무게중심입니다. 유사도 채점은 "정답과 얼마나 닮았나"를 재고 실행 채점은 "실제로 통과시키나"를 잽니다. 두 질문은 전혀 다릅니다. 정답과 한 글자도 다르지 않게 생긴 코드가 실행하면 틀릴 수 있고 완전히 다르게 생긴 코드가 완벽하게 동작할 수 있습니다. 검증이라는 작업의 본질이 "실제로 규칙을 잡아내는가"에 있는 이상, 채점도 실행으로 해야 맞습니다.

이 방향은 반도체 검증에만 국한된 이야기가 아닙니다. 코딩 에이전트 전반의 평가 패러다임이 같은 곳을 향하고 있습니다. 테스트를 통과시키는 코드, 엔드포인트가 기대한 응답을 내는 코드, 데이터베이스에 올바른 행을 남기는 코드처럼 결정론적으로 확인 가능한 결과로 채점하는 흐름입니다. 모델이 "잘 됐다고 봅니다"라고 자기 보고하는 것을 믿지 않고 실행 결과가 판정을 내리게 하는 것입니다.

이 연구는 벤치마크에서 멈추지 않았습니다. 삼성 사내 보안 환경에서 사내 LLM과 통합해, 레이아웃과 검증 코드를 한 화면에서 다루는 GUI 앱까지 만들어 실제 현장에 배포 가능한 도구로 이어졌습니다. 도메인 특화 에이전트가 규제와 보안이 엄격한 산업에서 실제로 자리를 잡아가고 있다는 신호입니다.

## ThakiCloud 제품 적용 시사점

Rule2DRC가 보여 주는 그림은 ThakiCloud가 두 제품으로 겨냥하는 지점과 정확히 겹칩니다. 주제가 도메인 특화 에이전트를 보안 격리 환경에서 운용하는 것이므로, Paxis 렌즈가 중심이고 ai-platform 렌즈가 이를 받칩니다.

에이전트 관점에서 보면 Paxis가 이 수요를 그대로 받습니다. Paxis는 ThakiCloud의 ai-platform 위에서 도는 Agent-Native Cloud 제어 평면으로, Skills와 Tools, Policies, Audit Logs를 일급 리소스로 다룹니다. 삼성 사례의 "레이아웃 네이티브 GUI 앱 더하기 사내 LLM 통합"은 Paxis의 Agent Builder와 온프레미스 배포 모델 그 자체입니다. Rule2DRC의 실행 기반 채점은 Paxis의 검증 설계와 같은 철학을 공유합니다. Paxis는 스킬을 평가할 때 결과물이 정답과 비슷한지가 아니라 결정론적 실행 결과, 즉 assertion과 DB 행, 엔드포인트 출력으로 채점하는 방향을 이미 취하고 있습니다. SplitTester가 실행 피드백으로 후보를 갈라내 Best-of-N을 끌어올리는 방식은, Paxis의 멀티에이전트 오케스트레이터에서 Evaluator가 후보 산출물을 실행 결과로 변별하는 로직으로 참고할 만합니다.

인프라 관점에서는 ai-platform이 이 그림을 떠받칩니다. 사내 LLM을 검증 에이전트의 백엔드로 서빙하려면 온프레미스에서 안정적으로 도는 추론 스택이 필요합니다. ai-platform은 K8s와 Kueue 기반 GPU 스케줄링 위에서 vLLM 서빙과 scale-to-zero를 제공하고 멀티테넌트로 격리된 환경에서 모델을 운용합니다. 토큰 과금형 클라우드 API로는 삼성 사내망 같은 에어갭 요건을 맞출 수 없습니다. 낮은 서빙 비용에서 경쟁력을 갖는 온프렘 추론이 이런 도메인 에이전트의 경제성을 만듭니다. 저비용 서빙이 에이전트의 상시 운용 가능성을 열고 그 위에서 Paxis의 정책 게이트와 감사 로그가 규제 대응을 책임지는 구조입니다.

이 사례가 보여 주는 것은 범용 챗봇이 아니라 보안 격리 환경에서 도는 도메인 특화 에이전트가 산업 현장에 필요하다는 증거입니다. Paxis의 Sandbox Runtime과 자율성 레벨, Policy Engine, 온프레미스 감사 로그가 정확히 이 수요를 향합니다.

## 한계 및 반론

이 연구를 과대평가하지 않으려면 반대편도 봐야 합니다. Rule2DRC의 핵심 기여는 벤치마크와 채점 방법론이지, 검증 자동화가 이제 완성됐다는 뜻은 아닙니다. 프런티어 모델조차 모든 규칙을 완벽하게 스크립트로 옮기지 못했고 격차가 있다는 것은 아직 인간 전문가를 대체할 단계에는 이르지 못했다는 뜻이기도 합니다.

실행 기반 채점에도 전제 조건이 있습니다. 검증 엔진과 평가용 레이아웃이 갖춰져 있어야만 가능하기 때문입니다. Rule2DRC는 13,921개의 레이아웃을 준비했지만, 새로운 공정이나 다른 도메인에서 같은 규모의 실행 가능한 평가셋을 구축하는 일은 그 자체로 큰 비용입니다. 실행 채점이 유사도 채점보다 옳다는 것과, 그 실행 환경을 모든 곳에서 값싸게 갖출 수 있다는 것은 별개의 문제입니다.

사내망 배포 GUI 앱이 나왔다는 것과, 그것이 실무에서 전문가의 수작업을 실제로 얼마나 줄였는지는 다른 질문입니다. 논문 단계의 실증과 현장 운영의 신뢰성 사이에는 여전히 거리가 있고 그 거리를 메우는 것은 벤치마크보다 오래 쌓은 운영 데이터입니다.

## 정리

Rule2DRC의 메시지를 한 문장으로 줄이면, 도메인 특화 에이전트는 그럴듯한 코드가 아니라 실제로 통과시키는 코드로 채점해야 하고 그렇게 채점할 수 있을 때 비로소 규제·보안 현장에 배포할 수 있다는 것입니다. 자연어 규칙을 실행 스크립트로 옮기는 전문 작업을, 정답 레이아웃 없이도 실행 결과로 평가하는 벤치마크와, 그 위에서 후보를 변별하는 SplitTester, 그리고 사내망 배포 GUI 앱까지 이어진 한 줄기가 이를 보여 줍니다.

여러분이 도메인 특화 에이전트를 설계하고 있다면, 다음 행동은 분명합니다. 산출물을 유사도 대신 실행 결과로 채점하는 게이트를 먼저 세우고 후보가 여럿일 때는 그것들을 갈라내는 변별 테스트를 붙이는 것입니다. ThakiCloud는 이 두 가지를 Paxis의 Evaluator와 ai-platform의 온프렘 서빙으로 이미 실무에 녹이고 있습니다. 검증을 자동화하고 싶다면, 실행이 판정하게 하십시오.

## 출처

- 논문: [Rule2DRC (arXiv:2605.15669)](https://arxiv.org/abs/2605.15669)
- 서울대 공대 뉴스: [SNU Engineering News](https://eng.snu.ac.kr/en/communication/promotion/news?md=v&bbsidx=8189&sc=y)
