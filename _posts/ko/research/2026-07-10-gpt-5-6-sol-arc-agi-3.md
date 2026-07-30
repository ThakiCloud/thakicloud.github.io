---
title: "실행보다 정향이 먼저다: GPT-5.6 Sol이 ARC-AGI-3를 처음으로 깬 방법"
seo_title: "GPT-5.6 Sol ARC-AGI-3 7.8% 돌파 분석 - Thaki Cloud"
seo_description: "GPT-5.6 Sol이 ARC-AGI-3에서 7.78%로 첫 SOTA를 세우고 처음으로 게임을 클리어한 과정을 분석합니다. 정향(orientation) 중심 추론이 왜 에이전트 인프라와 서빙 경제성에 중요한지 ThakiCloud 관점에서 정리합니다."
excerpt: "ARC-AGI-3는 설명서 없는 대화형 게임에서 에이전트가 스스로 상황을 파악하고 적응하는지를 측정합니다. GPT-5.6 Sol은 이 벤치마크를 7.78%로 처음 돌파했는데, 그 원동력은 더 나은 실행이 아니라 낯선 환경에서 먼저 방향을 잡는 정향 능력이었습니다."
date: 2026-07-10
tags:
  - arc-agi
  - reasoning
  - agents
  - gpt-5-6
  - benchmark
  - agentic-ai
  - orientation
categories:
  - research
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/ko/research/gpt-5-6-sol-arc-agi-3/"
audiobook: /assets/audio/posts/gpt-5-6-sol-arc-agi-3/audiobook-ko.mp3
audiobook_note: "AI 로컬 합성 오디오북 (Qwen3-TTS)"
published: false
---

에이전트를 실제로 운용해 본 팀이라면 벤치마크 점수 한 줄에 쉽게 흥분하지 않습니다. 정적인 문제 풀이에서 90%를 넘긴 모델이 막상 낯선 도구, 처음 보는 UI, 설명서 없는 환경 앞에서는 갈피를 못 잡는 경우를 너무 많이 봤기 때문입니다. 그래서 ARC Prize가 GPT-5.6 Sol의 ARC-AGI-3 결과를 검증했다고 발표했을 때, 숫자 자체보다 그 숫자가 만들어진 방식이 훨씬 흥미로웠습니다.

핵심 사실은 이렇습니다. GPT-5.6 Sol은 ARC-AGI-3 세미프라이빗 세트에서 7.78%를 기록해 새로운 SOTA를 세웠고, 검증된 프런티어 모델 중 처음으로 ARC-AGI-3 게임 하나를 실제로 끝까지 클리어했습니다. 그런데 ARC Prize 측의 설명이 인상적입니다. Sol이 잘한 이유는 더 정확히 실행해서가 아니라, 처음 보는 상황에서 스스로 방향을 잡는 정향(orientation) 능력이 뛰어났기 때문이라는 것입니다.

![낯선 격자 세계에서 에이전트가 방향을 잡아 하나의 경로로 수렴하는 과정을 형상화한 추상 이미지]({{ '/assets/images/gpt-5-6-sol-arc-agi-3-hero.png' | relative_url }})
*설명서 없는 낯선 환경에서 흩어진 혼돈이 하나의 방향으로 수렴하는 정향의 순간을 형상화했습니다.*

## 개요

이 글이 다루는 것은 GPT-5.6 Sol이라는 모델의 종합 성능 순위가 아닙니다. 이 모델이 왜 다른 벤치마크가 아닌 ARC-AGI-3에서 의미 있는 진전을 만들었는지, 그리고 그 진전이 실무에서 에이전트를 만들고 서빙하는 우리에게 무엇을 시사하는지입니다.

ARC-AGI 시리즈는 성격이 크게 나뉩니다. ARC-AGI-1과 2는 정적인 격자 퍼즐로, 규칙을 추론해 정답 격자를 만드는 수동적 유동지능(fluid intelligence)을 측정합니다. 반면 ARC-AGI-3는 완전히 다른 종류의 문제입니다. 설명서가 주어지지 않는 대화형 턴제 게임 환경에서, 에이전트가 직접 행동하며 규칙을 발견하고 목표를 달성해야 합니다. 즉 "정답을 맞히는" 문제에서 "낯선 세계에 적응하는" 문제로 축이 옮겨간 것입니다.

이 차이가 ThakiCloud 관점에서 중요한 이유가 있습니다. 우리가 다루는 에이전트 워크로드는 대부분 후자에 가깝습니다. 처음 연결한 MCP 커넥터, 처음 보는 사내 API, 스키마가 바뀐 데이터소스 앞에서 에이전트가 얼마나 빨리 상황을 파악하고 안전하게 움직이는가. 이것이 실제 프로덕션 에이전트의 성패를 가르는 지점입니다. ARC-AGI-3는 바로 그 능력을 실험실 조건에서 측정합니다.

## ARC-AGI-3란 무엇이고 왜 이렇게 어려운가

ARC-AGI-3의 설계 철학은 "이전 세대를 포화시킨 종류의 진전에 저항하도록" 만들어졌습니다. ARC-AGI-1은 현재 사실상 포화 상태입니다. Sol과 Terra가 96.5% 안팎으로 거의 붙어 있고, 저비용 모델 Luna도 88%에 도달합니다. 정적 추론은 이제 프런티어 모델에게 풀린 문제에 가깝습니다.

ARC-AGI-2로 올라가면 격차가 벌어집니다. Sol이 92%(태스크당 약 1.44달러), Terra가 83.9%(1.09달러), Luna가 59.5%(0.67달러)를 기록합니다. 여기까지도 여전히 "주어진 문제를 얼마나 잘 푸느냐"의 영역입니다.

![ARC-AGI-1은 포화 상태이고 ARC-AGI-2에서 모델 간 격차가 벌어지는 모습을 대비한 도표]({{ '/assets/images/gpt-5-6-sol-arc-agi-3-slide-03.png' | relative_url }})
*정적 추론을 측정하는 ARC-AGI-1은 이미 포화 상태이고, ARC-AGI-2로 올라가면 Sol·Terra·Luna 사이에 성능과 비용의 격차가 드러납니다.*

문제는 ARC-AGI-3입니다. 이 벤치마크는 2026년 3월 공개 당시 최고 모델조차 0.37%밖에 못 넘겼습니다. 대화형 게임에서 어떤 행동이 무엇을 유발하는지, 목표가 무엇인지, 실패가 무엇을 뜻하는지를 아무런 사전 정보 없이 스스로 알아내야 하기 때문입니다. 인간에게는 쉬운 일이지만, 모델에게는 학습 분포 밖의 완전한 미지 영역입니다.

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
<div class="d3-arch" data-arch-root id="20260710gpt56solarcagi3-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 552, "height": 662, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 214, "y": 24, "w": 120, "h": 46, "title": "ARC-AGI 시리즈"}, {"id": "B", "x": 400, "y": 148, "w": 120, "h": 62, "title": ["ARC-AGI-1", "정적 격자 퍼즐"]}, {"id": "C", "x": 214, "y": 148, "w": 120, "h": 62, "title": ["ARC-AGI-2", "더 어려운 정적 추론"]}, {"id": "D", "x": 28, "y": 148, "w": 120, "h": 62, "title": ["ARC-AGI-3", "대화형 턴제 게임"]}, {"id": "B1", "x": 400, "y": 288, "w": 120, "h": 62, "title": ["수동적 유동지능", "Sol 96.5% 포화"]}, {"id": "C1", "x": 203, "y": 288, "w": 142, "h": 62, "title": ["규칙 추론 심화", "Sol 92% / 1.44달러"]}, {"id": "D1", "x": 28, "y": 288, "w": 120, "h": 62, "title": ["설명서 없음", "행동하며 규칙 발견"]}, {"id": "E", "x": 28, "y": 428, "w": 120, "h": 62, "title": ["정향이 필요", "낯선 환경 적응"]}, {"id": "F", "x": 24, "y": 568, "w": 128, "h": 62, "title": ["공개 당시 최고 0.37%", "사실상 미해결"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[334, 67], [460, 109], [460, 109], [460, 148]]}, {"src": "A", "dst": "C", "kind": "data", "line": [274, 70, 274, 148]}, {"src": "A", "dst": "D", "kind": "data", "curve": [[214, 67], [88, 109], [88, 109], [88, 148]]}, {"src": "B", "dst": "B1", "kind": "data", "line": [460, 210, 460, 288]}, {"src": "C", "dst": "C1", "kind": "data", "line": [274, 210, 274, 288]}, {"src": "D", "dst": "D1", "kind": "data", "line": [88, 210, 88, 288]}, {"src": "D1", "dst": "E", "kind": "data", "line": [88, 350, 88, 428]}, {"src": "E", "dst": "F", "kind": "data", "line": [88, 490, 88, 568]}]});
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
      const container = document.getElementById('20260710gpt56solarcagi3-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '20260710gpt56solarcagi3-1';
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

이 구조를 보면 ARC-AGI-3가 다른 벤치마크와 근본적으로 다른 축을 측정한다는 점이 분명해집니다. 앞의 두 세대는 "지능의 해상도"를 높이는 문제였다면, 3세대는 "지능의 적응성"을 요구합니다. 그리고 적응성은 실행 정확도만으로는 만들어지지 않습니다.

## GPT-5.6 Sol의 결과: 숫자로 보기

GPT-5.6 Sol은 최대 추론 강도(max reasoning effort) 설정에서 ARC-AGI-3 퍼블릭 세트 평균 13.33%, 세미프라이빗 세트 7.78%를 기록했습니다. 헤드라인으로 인용되는 7.8%가 바로 이 세미프라이빗 수치입니다. 직전 SOTA가 Claude Opus 4.8의 1.5%였다는 점을 감안하면, 5배 이상의 도약입니다.

더 상징적인 사건은 Sol이 검증된 프런티어 모델 중 처음으로 ARC-AGI-3 퍼블릭 게임 하나(ft09)를 실제로 클리어했다는 사실입니다. 이 게임에서 Sol의 성공률은 87%였습니다. 벤치마크가 라이브로 공개된 이후 어떤 모델도 게임 하나를 온전히 끝낸 적이 없었으니, 이것은 단순한 점수 갱신이 아니라 질적 문턱을 넘은 첫 사례입니다.

![프런티어 모델 최초로 ARC-AGI-3 퍼블릭 게임 ft09를 87% 성공률로 클리어한 첫 사례를 강조한 도표]({{ '/assets/images/gpt-5-6-sol-arc-agi-3-slide-02.png' | relative_url }})
*ft09 게임을 87% 성공률로 끝낸 것은 점수 갱신이 아니라 질적 문턱을 넘은 첫 완공입니다.*

단, 비용을 정직하게 봐야 합니다. 최대 추론 강도에서 ARC-AGI-3 전체 평가에 드는 비용은 총 2만 달러에 육박합니다. 이 능력은 아직 "가장 비싼 설정에서만 겨우 열리는" 능력입니다. 7.78%라는 숫자는 돌파의 신호이지, 문제가 풀렸다는 선언이 아닙니다. 92%가 나오는 ARC-AGI-2와 나란히 두고 보면, 대화형 적응이 정적 추론보다 여전히 한 세대 뒤에 있음을 알 수 있습니다.

![최대 추론 강도 평가 비용 2만 달러를 강조하며 정향 능력의 경제적 대가를 나타낸 도표]({{ '/assets/images/gpt-5-6-sol-arc-agi-3-slide-07.png' | relative_url }})
*7.78%는 최대 추론 강도에서만 겨우 열린 능력이며, 총 2만 달러의 평가 비용은 이 돌파가 아직 실무 배포와 거리가 있음을 보여 줍니다.*

## "실행"이 아니라 "정향"이 만든 돌파

가장 중요한 대목은 ARC Prize의 해석입니다. Sol이 ARC-AGI-3에서 성능을 낸 이유는 각 행동을 더 정확히 실행해서가 아니라, 낯선 환경에서 먼저 스스로를 올바르게 정향(orient)했기 때문이라는 것입니다.

정향과 실행은 다른 능력입니다. 실행은 "이 상황에서 무엇을 해야 하는지 알 때 그것을 정확히 수행하는 것"입니다. 정향은 "무엇을 해야 하는지 자체가 불분명할 때, 관찰과 시도를 통해 상황의 구조를 파악하는 것"입니다. 대부분의 벤치마크는 실행을 측정합니다. 문제와 목표가 명확히 주어지기 때문입니다. ARC-AGI-3는 목표조차 숨겨두고 정향을 측정합니다.

![실행과 정향의 개념·환경·행동 방식·평가 기준을 좌우로 대비한 비교 도표]({{ '/assets/images/gpt-5-6-sol-arc-agi-3-slide-05.png' | relative_url }})
*실행은 명확한 지시 아래 정답률을 겨루지만, 정향은 낯선 환경에서 관찰과 시도로 규칙을 발견하는 적응률을 겨룹니다.*

이 구분은 실무 에이전트 설계에 직접 닿습니다. 프로덕션에서 에이전트가 실패하는 순간은 대개 실행 단계가 아니라 정향 단계입니다. 함수를 잘못 호출해서가 아니라, 애초에 이 상황에서 어떤 함수를 왜 불러야 하는지를 잘못 판단해서 무너집니다. Sol의 결과는 정향 능력이 별도로 스케일할 수 있는 축이며, 이를 측정하는 벤치마크가 실제 에이전트 품질과 더 상관관계가 높을 수 있음을 시사합니다.

## ThakiCloud 제품 적용 시사점

이 주제는 ThakiCloud의 두 제품 모두에 걸칩니다.

![프런티어 모델을 Paxis 하네스와 ai-platform 서빙이 아래에서 떠받치는 ThakiCloud 아키텍처 도표]({{ '/assets/images/gpt-5-6-sol-arc-agi-3-slide-08.png' | relative_url }})
*프런티어 모델의 값비싼 능력은 Paxis 하네스가 정향을 보조하고 ai-platform이 추론 비용을 눌러 줄 때 비로소 운용 가능한 에이전트가 됩니다.*

**Paxis 렌즈(에이전트 정향).** Paxis는 ThakiCloud의 Agent-Native Cloud로, Skills·Tools·Policies·Audit Logs를 일급 리소스로 다룹니다. 여기서 정향은 추상적 개념이 아니라 설계 문제입니다. 에이전트가 새 MCP 커넥터에 처음 연결하거나 960여 개 스킬을 BM25로 선택할 때, 결국 "낯선 능력 공간에서 방향을 잡는" 문제를 매번 풉니다. ARC-AGI-3의 교훈은 이 정향 단계를 모델에게만 맡기지 말고 하네스가 도와야 한다는 것입니다. Paxis가 스킬 설명·정책 게이트·감사 로그로 행동 공간을 구조화하는 것은, 에이전트가 미지의 환경에서 헤매는 대신 검증된 골격 안에서 방향을 잡게 하는 정향 보조 장치에 해당합니다. Sol처럼 값비싼 최대 추론에 의존하지 않고도, 하네스가 정향 부담을 줄이면 저렴한 모델로도 안정적인 적응이 가능해집니다.

**ai-platform 렌즈(추론 경제성).** 동시에 2만 달러라는 평가 비용은 서빙 인프라의 문제이기도 합니다. 정향 중심 추론은 대개 긴 사고 궤적과 많은 시행착오를 요구하고, 이는 토큰 소비와 직결됩니다. ThakiCloud의 ai-platform은 K8s·Kueue GPU 스케줄링·vLLM 서빙으로 이런 고비용 추론 워크로드를 멀티테넌트 환경에서 비용 효율적으로 돌리는 데 초점을 둡니다. 낯선 환경에 적응하는 에이전트를 프로덕션에 올리려면, 최대 추론 강도의 비용을 감당 가능한 수준으로 눌러 줄 서빙 계층이 반드시 필요합니다. 저렴한 서빙이 곧 에이전트 경제성을 만든다는 명제가 여기서 다시 확인됩니다.

정리하면, Paxis가 정향의 부담을 하네스로 분산하고 ai-platform이 그 추론 비용을 눌러 줄 때, 비로소 값비싼 프런티어 데모가 아니라 운용 가능한 적응형 에이전트가 됩니다.

## 한계 및 반론

이 결과를 과대 해석하지 않도록 몇 가지 반론을 함께 둡니다.

첫째, 7.78%는 여전히 매우 낮은 절대 수치입니다. 인간이라면 대부분의 ARC-AGI-3 게임을 무리 없이 클리어하는데, 최고 모델이 게임 하나를 겨우 끝냈습니다. "돌파"는 맞지만 "해결"과는 거리가 멉니다. 이 지점에서 정향 능력의 일반화가 얼마나 견고한지는 아직 증명되지 않았습니다.

둘째, 비용 문제가 능력 주장을 상당 부분 상쇄합니다. 최대 추론 강도에서만 열리는 능력은 실무 배포 가능성과 별개입니다. 같은 정향 능력이 1/10 비용에서도 재현되는지가 실제 가치의 관건이며, 현재 데이터로는 알 수 없습니다.

셋째, 단일 벤치마크의 검증 결과라는 한계가 있습니다. Fable 5는 아직 ARC-AGI-3에서 벤치마크되지 않았고, 정향 능력이 ARC-AGI-3 게임군 밖의 실제 에이전트 태스크로 전이되는지는 별도 검증이 필요합니다. 벤치마크 특화(overfitting to benchmark)의 가능성을 배제할 근거가 아직 충분하지 않습니다.

![절대 수치 부족·비용 장벽·벤치마크 과적합 세 가지 한계와 정향이라는 다음 병목을 정리한 도표]({{ '/assets/images/gpt-5-6-sol-arc-agi-3-slide-11.png' | relative_url }})
*낮은 절대 수치·비용 장벽·벤치마크 과적합이라는 세 유보에도, 실행 정확도가 포화된 시대의 다음 병목이 정향이라는 방향성은 분명합니다.*

그럼에도 방향성은 분명합니다. 실행 정확도가 포화되는 시대에 다음 병목은 정향이며, 이를 측정하고 하네스로 보조하는 접근이 실무 에이전트의 다음 경쟁력이 될 것입니다. Sol의 7.78%는 그 전환점의 첫 좌표입니다.

## 출처

- [GPT-5.6 Sol ARC-AGI Results (ARC Prize)](https://arcprize.org/results/openai-gpt-5-6-sol)
- [ARC Prize 발표 (X/Twitter)](https://x.com/arcprize/status/2075270869992264003)
- [ARC Prize Leaderboard](https://arcprize.org/leaderboard)
- [GPT 5.6 Sol Tops ARC-AGI-3 With 7.8% (OfficeChai)](https://officechai.com/ai/gpt-5-6-sol-tops-arc-agi-3-with-7-8-becomes-first-model-to-make-meaningful-progress-on-benchmark/)
