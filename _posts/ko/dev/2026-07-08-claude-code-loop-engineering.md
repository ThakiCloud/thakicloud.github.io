---
title: "프롬프트를 그만 치고 루프를 설계하라: Claude Code 루프 엔지니어링 공식 문서 읽기"
excerpt: "Anthropic이 2026년 7월 7일 'Getting started with loops'라는 첫 공식 루프 엔지니어링 문서를 공개했습니다. 매 단계를 사람이 프롬프트로 지시하는 방식에서, 에이전트를 대신 프롬프트해 주는 시스템을 설계하는 방식으로 넘어가는 전환입니다. 수동 루프, /loop 간격 루프, /schedule 루틴, 그리고 /goal 완료 조건을 정리하고, 이 패턴을 실제로 무인 파이프라인에 배선한 ThakiCloud의 운영 사례와 Paxis 에이전트 제어 평면 관점으로 연결합니다."
seo_title: "Claude Code 루프 엔지니어링 - /goal /loop /schedule 공식 가이드 읽기 (2026) - Thaki Cloud"
seo_description: "Anthropic의 공식 문서 'Getting started with loops'(2026-07-07)를 소개합니다. 수동 루프, /loop 간격 루프, /schedule 스케줄 루틴, /goal 완료 조건과 턴 캡, 검증 가능한 성공 기준 설계, 스킬 기반 검증을 정리하고, pge-loop와 Goal Mode, launchd cron 러너로 이 패턴을 실제 무인 파이프라인에 배선한 ThakiCloud 사례와 Paxis Agent-Native Cloud 관점의 함의를 다룹니다."
date: 2026-07-08
last_modified_at: 2026-07-08
tags:
  - claude-code
  - loop-engineering
  - ai-agent
  - agentic-automation
  - developer-tools
  - orchestration
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ko/dev/claude-code-loop-engineering/"
reading_time: true
categories:
  - dev
---

## 이 글을 누가 읽으면 좋은가

이 글은 코딩 에이전트를 단발 도구가 아니라 오래 돌아가는 자동화 시스템으로 운영하려는 개발자와 플랫폼 엔지니어를 위해 씁니다. "매번 프롬프트를 치는 대신 에이전트가 스스로 반복하게 하려면 무엇을 정해 줘야 하는가", "무한 반복과 비용 폭주를 어떻게 막는가"라는 실무 질문을 다룹니다. Anthropic이 공개한 공식 루프 문서를 읽고, 그 개념을 실제 무인 파이프라인에 배선한 우리 운영 경험과 겹쳐 봅니다.

![빛나는 화살표가 순환하는 피드백 루프 고리와 그 중심의 검증 게이트를 표현한 추상 이미지]({{ '/assets/images/claude-code-loop-engineering-hero.png' | relative_url }})

## 개요

지금까지 코딩 에이전트를 쓰는 방식은 대화였습니다. 사람이 프롬프트를 치면 에이전트가 한 번 응답하고 멈춥니다. 다음 지시가 올 때까지 기다립니다. 이 방식은 짧은 작업에는 훌륭하지만, PR 리뷰 반영, CI 수정, 이슈 트리아지, 의존성 업그레이드처럼 반복적이고 끝이 정해진 작업의 흐름에는 맞지 않습니다. 사람이 계속 옆에 붙어 매 턴을 프롬프트해야 하기 때문입니다.

Anthropic은 2026년 7월 7일 「Getting started with loops」라는 공식 문서를 공개하며 이 전환에 이름을 붙였습니다. 루프 엔지니어링입니다. 문서의 핵심 문장은 이렇습니다. 매 프롬프트를 직접 타이핑하는 것을 멈추고, 에이전트를 대신 프롬프트해 주는 시스템을 설계하기 시작하는 것. 이 글은 그 문서가 정리한 루프의 종류와 정지 조건을 읽고, 우리가 이 패턴을 실제로 무인 파이프라인에 어떻게 배선했는지까지 이어 봅니다.

## 루프 엔지니어링이란 무엇인가

루프 엔지니어링은 프롬프트 엔지니어링의 다음 단계입니다. 프롬프트 엔지니어링이 "한 번의 응답을 잘 받아내는 지시문"을 다듬는 일이라면, 루프 엔지니어링은 "관찰하고 판단하고 실행하고 다시 관찰하는 반복 구조" 자체를 설계하는 일입니다. 좋은 루프의 품질을 결정하는 것은 모델의 능력만이 아니라 루프가 매 회차마다 받는 피드백의 질입니다.

![프롬프트 엔지니어링(과거)과 루프 엔지니어링(미래)의 작동 방식 비교]({{ '/assets/images/claude-code-loop-engineering-slide-02.png' | relative_url }})

가장 신뢰할 수 있는 피드백은 테스트, 타입 체커, 린터처럼 통과와 실패를 객관적으로 돌려주는 결정론적 검증입니다. "완료된 것 같습니다"라는 모델의 자기 보고는 루프의 종료 조건이 될 수 없습니다. 루프가 언제 멈춰야 하는지는 모델의 주장이 아니라 도구의 판정이 결정해야 합니다.

## 세 가지 루프 유형과 /goal

공식 문서는 루프를 세 가지 유형으로 나눕니다. 어느 것을 쓸지는 "사람이 실시간으로 개입하는가", "끝이 정해져 있는가", "정해진 시각에 반복되는가"로 갈립니다.

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
<div class="d3-arch" data-arch-root id="laudecodeloopengineering-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 540, "height": 634, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "Q1", "x": 287, "y": 24, "w": 138, "h": 68, "title": ["사람이 실시간으로", "지켜보는가"]}, {"id": "M", "x": 388, "y": 184, "w": 120, "h": 78, "title": ["수동 루프", "프롬프트로 시작", "완료 판단 시 정지"]}, {"id": "Q2", "x": 195, "y": 189, "w": 138, "h": 68, "title": ["정해진 목표를", "달성할 때까지인가"]}, {"id": "G", "x": 296, "y": 354, "w": 121, "h": 78, "title": ["/goal", "완료 조건 + 예산 상한", "기준 충족 시 종료"]}, {"id": "Q3", "x": 103, "y": 359, "w": 138, "h": 68, "title": ["정해진 간격이나", "일정으로 반복인가"]}, {"id": "L", "x": 199, "y": 532, "w": 121, "h": 62, "title": ["/loop 간격 루프", "프롬프트를 주기로 재실행"]}, {"id": "S", "x": 24, "y": 524, "w": 120, "h": 78, "title": ["/schedule 루틴", "사람 없이 반복 실행", "끌 때까지 유지"]}], "edges": [{"src": "Q1", "dst": "M", "kind": "data", "label": "예, 짧은 단발 작업", "curve": [[395, 92], [448, 138], [448, 138], [448, 184]], "off": "50%"}, {"src": "Q1", "dst": "Q2", "kind": "data", "label": "아니오", "curve": [[317, 92], [264, 138], [264, 138], [264, 189]], "off": "50%"}, {"src": "Q2", "dst": "G", "kind": "data", "label": "예", "curve": [[301, 257], [356, 308], [356, 308], [356, 354]], "off": "50%"}, {"src": "Q2", "dst": "Q3", "kind": "data", "label": "아니오", "curve": [[227, 257], [172, 308], [172, 308], [172, 359]], "off": "50%"}, {"src": "Q3", "dst": "L", "kind": "data", "label": "간격 반복", "curve": [[207, 427], [260, 478], [260, 478], [260, 532]], "off": "50%"}, {"src": "Q3", "dst": "S", "kind": "data", "label": "이벤트 · 스케줄", "curve": [[137, 427], [84, 478], [84, 478], [84, 524]], "off": "50%"}]});
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
      const container = document.getElementById('laudecodeloopengineering-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'laudecodeloopengineering-1';
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

첫째는 수동 루프입니다. 사용자 프롬프트로 시작하고, Claude가 작업을 끝냈다고 판단하거나 추가 맥락이 필요하다고 판단하면 멈춥니다. 정기적인 프로세스나 스케줄에 속하지 않는 비교적 짧은 작업에 적합합니다.

둘째는 `/loop` 간격 루프입니다. 하나의 프롬프트를 정해진 간격으로 재실행합니다. 문서가 든 예시는 이렇습니다. `/loop 5m check my PR, address review comments, and fix failing CI` 처럼 5분마다 PR을 확인하고 리뷰 코멘트를 반영하며 실패한 CI를 고치는 식입니다.

셋째는 `/schedule` 스케줄 루틴입니다. 이벤트나 일정에 의해, 실시간으로 지켜보는 사람 없이 발동합니다. 각 작업은 목표를 달성하면 종료하지만, 루틴 자체는 끌 때까지 계속 돌아갑니다. 버그 리포트, 이슈 트리아지, 마이그레이션, 의존성 업그레이드처럼 잘 정의된 반복 작업 스트림에 적합합니다.

이 셋을 관통하는 것이 `/goal`입니다. `/goal`은 완료 조건을 설정하고, 사람이 매 단계를 프롬프트하지 않아도 Claude가 그 조건을 향해 계속 작업하게 합니다. 방향형 목표를 두고 도구 피드백으로 수렴시키는 구조입니다.

## 좋은 성공 기준을 설계하는 법

루프의 성패는 성공 기준을 얼마나 잘 정의하느냐에 달려 있습니다. 공식 문서는 좋은 성공 기준의 세 가지 성질을 강조합니다.

![검증 가능성, 범위 경계, 성공 지표, 턴 캡이라는 네 가지 성공 기준]({{ '/assets/images/claude-code-loop-engineering-slide-04.png' | relative_url }})

첫째는 검증 가능성입니다. Claude가 프로그램적으로 또는 명시적 관찰로 완료를 확인할 수 있어야 합니다. "모든 유닛 테스트가 통과한다"는 검증 가능한 기준입니다. 반면 "코드를 개선한다"는 검증 불가능합니다.

둘째는 범위 경계입니다. 무엇이 범위 안이고 무엇이 밖인지를 명시해야 합니다. "결제 서비스를 리팩터하되 데이터베이스 계층은 건드리지 말라"처럼 경계가 있는 목표가 안전합니다.

셋째는 성공 지표입니다. 숫자가 도움이 됩니다. "`/search` 엔드포인트의 API 응답 시간을 200ms 아래로 낮춰라"는 구체적인 목표를 줍니다. 테스트 통과, Lighthouse 점수, 빈 큐처럼 결정론적으로 판정되는 기준이 가장 잘 작동합니다.

그리고 안전 밸브가 하나 더 필요합니다. 턴 캡입니다. "5번 시도 후 정지" 같은 상한이 없으면, 모호한 목표를 두고 에이전트가 "이 정도면 됐다"를 판단하느라 오랜 시간과 토큰을 쓸 수 있습니다. 완료 조건에 턴 캡을 함께 넣는 것이 가장 단순한 방어책입니다.

## 검증 게이트와 스킬

문서가 반복해서 짚는 원칙은 피드백의 질이 루프의 질을 결정한다는 것입니다. 그래서 스킬이 등장합니다. 스킬은 루프가 매 회차마다 실행하는 검증 절차를 재사용 가능한 형태로 묶어, 에이전트가 자기 출력을 스스로 검증할 방법을 갖게 합니다. 루프가 아무것도 거르지 못하고 항상 통과만 시킨다면, 그것은 검증기가 고장 났다는 신호입니다.

![검증 게이트가 있으면 품질이 복리로 쌓이고, 없으면 환각이 복리로 누적된다]({{ '/assets/images/claude-code-loop-engineering-slide-05.png' | relative_url }})

이 지점이 실무적으로 가장 중요합니다. 병렬로 여러 하위 작업을 펼치는 팬아웃 루프는 검증 스테이지 없이 결과를 합치면 환각을 누적합니다. 코드 작업이면 테스트의 종료 코드가, 리서치나 콘텐츠 작업이면 적대적 반증 표결이 결과를 감사한 뒤에야 다음 단계로 넘어가야 합니다. 품질이 안 나올 때 흔한 오해는 모델을 더 비싼 등급으로 올리는 것이지만, 더 흔한 원인은 검증 스테이지의 부재입니다.

## ThakiCloud 제품 적용 시사점

우리에게 이 문서가 특별한 이유는, 여기 적힌 패턴을 이미 실제 무인 파이프라인에 배선해 운영하고 있기 때문입니다.

우리 저장소에는 세 가지 층의 루프가 돌고 있습니다. 첫째, 컴파일러와 테스트 러너를 보상 신호로 삼아 코드 변환을 테스트 통과까지 반복하는 pge-loop가 있습니다. 이것은 문서의 `/goal`이 말하는 "검증 가능한 완료 조건"을 `make test-short`의 종료 코드로 구현한 것입니다. 둘째, 목표를 달성 상태까지 자율적으로 추구하는 Goal Mode가 있습니다. 상태 파일과 예산 상한, `check_cmd` 게이트를 갖춰 문서의 턴 캡과 성공 지표 원칙을 그대로 따릅니다. 셋째, 정해진 시각에 사람 없이 반복되는 launchd cron 러너들이 문서의 `/schedule` 루틴에 해당합니다. 모니터링과 콘텐츠 생성처럼 매 틱마다 사람의 판단이 필요 없는 작업은 Claude를 상주시키지 않고 cron으로 돌려 비용을 0으로 유지합니다.

![L1 pge-loop, L2 Goal Mode, L3 launchd cron으로 구성된 ThakiCloud 무인 파이프라인의 3계층 루프 아키텍처]({{ '/assets/images/claude-code-loop-engineering-slide-06.png' | relative_url }})

이 운영 규율이 곧 Paxis의 설계 철학입니다. Paxis는 ThakiCloud의 Agent-Native Cloud 제어 평면으로, 스킬과 도구, 정책, 감사 로그를 일급 리소스로 다룹니다. 루프 엔지니어링의 관점에서 Paxis가 제공하는 것은 네 가지입니다. 자연어 Cron으로 스케줄 루틴을 선언하고, DAG 멀티에이전트로 팬아웃과 검증 스테이지를 조립하며, 960개가 넘는 스킬을 BM25로 선택해 격리 샌드박스에서 실행하고, 모든 루프의 행동을 정책 게이트와 감사 로그로 통과시킵니다. 문서가 강조하는 "검증 없는 팬아웃은 위험하다"는 원칙이, Paxis에서는 정책 게이트라는 인프라 기능으로 강제됩니다.

![자연어 Cron, DAG 멀티에이전트, 960개 이상 격리 샌드박스 스킬, 정책 게이트와 감사 로그로 구성된 Paxis 통제 평면]({{ '/assets/images/claude-code-loop-engineering-slide-07.png' | relative_url }})

그 아래에서 ai-platform 렌즈도 함께 작동합니다. 오래 돌아가는 루프는 결국 추론 비용의 문제입니다. Kubernetes와 Kueue 기반 GPU 스케줄링 위에서 낮은 서빙 비용을 유지하는 것이, 스케줄 루틴을 지속 가능하게 만드는 경제적 토대가 됩니다. 저비용 서빙이 에이전트 루프의 경제성을 만들고, 그 위에서 Paxis가 루프의 안전과 조립을 책임지는 구조입니다.

## 한계 및 반론

루프 엔지니어링을 만능으로 받아들이면 오히려 위험합니다.

![세션 길이에 따른 누적 비용 곡선과 검증 불가·비용 폭주·인지적 항복이라는 3대 한계]({{ '/assets/images/claude-code-loop-engineering-slide-08.png' | relative_url }})

첫 번째 한계는 검증 불가능한 작업입니다. 성공을 결정론적으로 판정할 수 없는 작업을 루프로 돌리면, 에이전트는 종료 조건 없이 예산만 태웁니다. 게이트를 먼저 정의할 수 없다면 루프가 아니라 단발 실행이 옳습니다.

두 번째 한계는 비용입니다. 매 틱마다 거대한 맥락을 다시 읽는 긴 세션 루프는 캐시 읽기 비용이 선형으로 늘어납니다. 24시간 모니터링을 한 세션에 누적하는 패턴은 특히 비쌉니다. 사람이나 이벤트가 있을 때만 에이전트를 부르고, 단순 폴링은 cron으로 빼는 것이 원칙입니다.

세 번째 한계는 인지적 항복입니다. 루프가 깊어질수록 결과를 신뢰하고 검토를 멈추는 경향이 생깁니다. 자동화는 사고를 대체하는 것이 아니라 보조하는 도구입니다. 핵심 산출물은 주기적으로 사람이 표본 검토해야 하며, 검증기가 아무것도 거르지 못하면 그것을 고장 신호로 읽어야 합니다.

이 세 한계는 모두 하나의 원칙으로 요약됩니다. 루프를 시작하기 전에 종료 게이트를 먼저 정의하라. 게이트가 있으면 루프는 복리로 품질을 쌓고, 게이트가 없으면 루프는 환각을 복리로 쌓습니다.

![루프를 시작하기 전에 종료 게이트를 먼저 정의하라]({{ '/assets/images/claude-code-loop-engineering-slide-09.png' | relative_url }})

## 출처

- Anthropic, "Getting started with loops" (2026-07-07): [claude.com/blog/getting-started-with-loops](https://claude.com/blog/getting-started-with-loops)
- Claude Code Docs, "Keep Claude working toward a goal": [code.claude.com/docs/en/goal](https://code.claude.com/docs/en/goal)
