---
title: "AWS Agent Squad: 멀티 에이전트 오케스트레이션 프레임워크 완전 가이드"
excerpt: "AWS Labs의 Agent Squad 프레임워크 완벽 가이드 - 기본 설정부터 고급 멀티 에이전트 오케스트레이션까지 Python과 TypeScript 구현 예제 포함"
seo_title: "AWS Agent Squad 튜토리얼: 멀티 에이전트 오케스트레이션 프레임워크 가이드"
seo_description: "멀티 에이전트 AI 오케스트레이션을 위한 AWS Agent Squad 프레임워크 학습. Python/TypeScript 예제, Bedrock 통합, 실무 구현을 포함한 완전한 튜토리얼."
date: 2025-09-07
tags:
  - aws
  - agent-squad
  - 멀티에이전트
  - 오케스트레이션
  - bedrock
  - ai-agents
  - python
  - typescript
author_profile: true
toc: true
toc_label: "튜토리얼 목차"
lang: ko
permalink: /ko/tutorials/aws-agent-squad-multi-agent-orchestration-framework-tutorial/
canonical_url: "https://thakicloud.com/tech-blog/ko/tutorials/aws-agent-squad-multi-agent-orchestration-framework-tutorial/"
published: false
categories:
  - tutorials
---

⏱️ **예상 읽기 시간**: 15분

## Agent Squad 소개

AWS Labs의 **Agent Squad**(이전 Multi-Agent Orchestrator)는 복잡한 대화를 처리하기 위해 여러 AI 에이전트를 오케스트레이션하는 유연하고 경량화된 오픈소스 프레임워크입니다. GitHub에서 6.6천 개 이상의 스타를 받으며 성장하는 커뮤니티 지원을 받고 있어, 멀티 에이전트 AI 시스템의 중요한 발전을 나타냅니다.

### Agent Squad의 특별함

Agent Squad는 AI 애플리케이션에서 지능적인 대화 라우팅에 대한 증가하는 요구를 해결합니다. 단일 AI 에이전트가 모든 쿼리를 처리하는 대신, 컨텍스트와 의도를 기반으로 전문화된 에이전트에게 대화를 지능적으로 분배합니다.

## 주요 기능과 특징

### 🧠 지능적 의도 분류
프레임워크는 다음을 기반으로 가장 적합한 에이전트로 쿼리를 동적으로 라우팅합니다:
- **컨텍스트 분석**: 대화 흐름과 히스토리 이해
- **콘텐츠 평가**: 쿼리 의미론과 의도 분석
- **에이전트 전문화**: 쿼리를 에이전트 전문 분야와 매칭

### 🔤 이중 언어 지원
**Python**과 **TypeScript** 모두에서 완전 구현:
- 언어 간 동일한 기능
- 언어별 최적화
- 기존 코드베이스와의 원활한 통합

### 🌊 유연한 응답 처리
스트리밍 및 비스트리밍 응답 모두 지원:
- **실시간 스트리밍**: 대화형 대화용
- **배치 처리**: 분석 작업용
- **혼합 모드 지원**: 서로 다른 에이전트가 다른 응답 유형 사용 가능

### 📚 컨텍스트 관리
정교한 대화 컨텍스트 처리:
- **에이전트 간 메모리**: 에이전트 전환 시 컨텍스트 유지
- **세션 지속성**: 대화 히스토리 기억
- **컨텍스트 상속**: 에이전트 간 관련 정보 전달

## 아키텍처 개요

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
<div class="d3-arch" data-arch-root id="ationframeworktutorialko-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 701, "height": 1100, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 287, "y": 24, "w": 120, "h": 46, "title": "사용자 쿼리"}, {"id": "B", "x": 265, "y": 148, "w": 163, "h": 46, "title": "Agent Squad 오케스트레이터"}, {"id": "C", "x": 287, "y": 272, "w": 120, "h": 46, "title": "의도 분류기"}, {"id": "D", "x": 278, "y": 396, "w": 138, "h": 52, "title": "라우팅 결정"}, {"id": "E", "x": 549, "y": 526, "w": 120, "h": 46, "title": "기술 에이전트"}, {"id": "F", "x": 374, "y": 526, "w": 120, "h": 46, "title": "헬스 에이전트"}, {"id": "G", "x": 199, "y": 526, "w": 120, "h": 46, "title": "여행 에이전트"}, {"id": "H", "x": 24, "y": 526, "w": 120, "h": 46, "title": "사용자 정의 에이전트"}, {"id": "I", "x": 549, "y": 650, "w": 120, "h": 46, "title": "Bedrock LLM"}, {"id": "J", "x": 374, "y": 650, "w": 120, "h": 46, "title": "OpenAI GPT"}, {"id": "K", "x": 199, "y": 650, "w": 120, "h": 46, "title": "Lex Bot"}, {"id": "L", "x": 24, "y": 650, "w": 120, "h": 46, "title": "Lambda 함수"}, {"id": "M", "x": 287, "y": 774, "w": 120, "h": 46, "title": "응답 핸들러"}, {"id": "N", "x": 287, "y": 898, "w": 120, "h": 46, "title": "컨텍스트 관리자"}, {"id": "O", "x": 287, "y": 1022, "w": 120, "h": 46, "title": "최종 응답"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [347, 70, 347, 148]}, {"src": "B", "dst": "C", "kind": "data", "line": [347, 194, 347, 272]}, {"src": "C", "dst": "D", "kind": "data", "line": [347, 318, 347, 396]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[416, 439], [609, 487], [609, 487], [609, 526]]}, {"src": "D", "dst": "F", "kind": "data", "curve": [[382, 448], [434, 487], [434, 487], [434, 526]]}, {"src": "D", "dst": "G", "kind": "data", "curve": [[312, 448], [259, 487], [259, 487], [259, 526]]}, {"src": "D", "dst": "H", "kind": "data", "curve": [[278, 439], [84, 487], [84, 487], [84, 526]]}, {"src": "E", "dst": "I", "kind": "data", "line": [609, 572, 609, 650]}, {"src": "F", "dst": "J", "kind": "data", "line": [434, 572, 434, 650]}, {"src": "G", "dst": "K", "kind": "data", "line": [259, 572, 259, 650]}, {"src": "H", "dst": "L", "kind": "data", "line": [84, 572, 84, 650]}, {"src": "I", "dst": "M", "kind": "data", "curve": [[609, 696], [609, 735], [609, 735], [407, 783]]}, {"src": "J", "dst": "M", "kind": "data", "curve": [[434, 696], [434, 735], [434, 735], [379, 774]]}, {"src": "K", "dst": "M", "kind": "data", "curve": [[259, 696], [259, 735], [259, 735], [314, 774]]}, {"src": "L", "dst": "M", "kind": "data", "curve": [[84, 696], [84, 735], [84, 735], [287, 783]]}, {"src": "M", "dst": "N", "kind": "data", "line": [347, 820, 347, 898]}, {"src": "N", "dst": "O", "kind": "data", "line": [347, 944, 347, 1022]}]});
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
      const container = document.getElementById('ationframeworktutorialko-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ationframeworktutorialko-1';
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

아키텍처는 다음으로 구성됩니다:
1. **오케스트레이터**: 중앙 라우팅 및 관리
2. **분류기**: 의도 감지 및 에이전트 선택
3. **에이전트**: 전문화된 AI 컴포넌트
4. **컨텍스트 관리자**: 메모리 및 상태 관리
5. **응답 핸들러**: 출력 처리 및 포맷팅

## 설치 및 설정

### Python 설치

Agent Squad는 통합 요구사항에 따른 모듈형 설치 옵션을 제공합니다:

```bash
# 기본 AWS 통합 (가장 일반적)
pip install "agent-squad[aws]"

# OpenAI 통합
pip install "agent-squad[openai]"

# Anthropic 통합
pip install "agent-squad[anthropic]"

# 모든 통합을 포함한 전체 설치
pip install "agent-squad[all]"
```

### 환경 설정

격리를 위한 가상 환경 생성:

```bash
# 가상 환경 생성
python -m venv agent-squad-env
source agent-squad-env/bin/activate  # Windows에서는: agent-squad-env\Scripts\activate

# AWS 지원과 함께 설치
pip install "agent-squad[aws]"
```

### TypeScript/Node.js 설치

```bash
# 새 프로젝트 초기화
npm init -y

# Agent Squad 설치
npm install @awslabs/agent-squad

# AWS SDK 설치 (AWS 통합 사용 시)
npm install @aws-sdk/client-bedrock-runtime
```

## 기본 구현 튜토리얼

### Python 구현

전문화된 에이전트로 기본 멀티 에이전트 시스템을 만들어보겠습니다:

```python
import sys
import asyncio
from agent_squad.orchestrator import AgentSquad
from agent_squad.agents import BedrockLLMAgent, BedrockLLMAgentOptions, AgentStreamResponse

class AgentSquadTutorial:
    def __init__(self):
        # 오케스트레이터 초기화
        self.orchestrator = AgentSquad()
        
        # 에이전트 설정
        self._setup_agents()
    
    def _setup_agents(self):
        """다양한 도메인을 위한 전문화된 에이전트 설정"""
        
        # 기술 전문 에이전트
        tech_agent = BedrockLLMAgent(BedrockLLMAgentOptions(
            name="기술 전문가",
            streaming=True,
            description="""소프트웨어 개발, 클라우드 컴퓨팅, AI/ML, 
                         사이버보안, 블록체인, 신기술 혁신 전문가입니다. 
                         기술 가이드, 아키텍처 조언, 기술 솔루션의 
                         비용 분석을 제공합니다.""",
            model_id="anthropic.claude-3-sonnet-20240229-v1:0",
        ))
        
        # 건강 및 웰빙 에이전트
        health_agent = BedrockLLMAgent(BedrockLLMAgentOptions(
            name="건강 및 웰빙 전문가",
            streaming=True,
            description="""건강, 웰빙, 영양, 피트니스, 정신건강, 
                         의료 정보 전문가입니다. 증거 기반의 
                         건강 가이드와 웰빙 팁을 제공합니다.""",
            model_id="anthropic.claude-3-sonnet-20240229-v1:0",
        ))
        
        # 비즈니스 및 금융 에이전트
        business_agent = BedrockLLMAgent(BedrockLLMAgentOptions(
            name="비즈니스 및 금융 전문가",
            streaming=True,
            description="""비즈니스 전략, 재무 계획, 시장 분석, 
                         창업, 비즈니스 운영 전문가입니다. 
                         전략적 비즈니스 인사이트를 제공합니다.""",
            model_id="anthropic.claude-3-sonnet-20240229-v1:0",
        ))
        
        # 오케스트레이터에 에이전트 추가
        self.orchestrator.add_agent(tech_agent)
        self.orchestrator.add_agent(health_agent)
        self.orchestrator.add_agent(business_agent)
    
    async def process_query(self, user_input, user_id="user123", session_id="session456"):
        """에이전트 스쿼드를 통해 사용자 쿼리 처리"""
        
        try:
            # 적절한 에이전트로 요청 라우팅
            response = await self.orchestrator.route_request(
                user_input=user_input,
                user_id=user_id,
                session_id=session_id,
                additional_params={},
                streaming=True
            )
            
            # 응답 처리
            await self._handle_response(response)
            
        except Exception as e:
            print(f"쿼리 처리 중 오류: {e}")
    
    async def _handle_response(self, response):
        """스트리밍 및 비스트리밍 응답 모두 처리"""
        
        if response.streaming:
            print("\n🤖 **스트리밍 응답**\n")
            
            # 메타데이터 표시
            self._print_metadata(response.metadata)
            
            print("\n📝 **응답:**")
            
            # 콘텐츠 스트리밍
            async for chunk in response.output:
                if isinstance(chunk, AgentStreamResponse):
                    print(chunk.text, end='', flush=True)
                else:
                    print(f"예상치 못한 청크 타입: {type(chunk)}", file=sys.stderr)
            
            print("\n")  # 스트리밍 후 새 줄
            
        else:
            # 비스트리밍 응답 처리
            print("\n🤖 **응답**\n")
            self._print_metadata(response.metadata)
            print(f"\n📝 **응답:** {response.output.content}")
    
    def _print_metadata(self, metadata):
        """형식화된 방식으로 응답 메타데이터 출력"""
        print(f"🎯 **에이전트:** {metadata.agent_name} (ID: {metadata.agent_id})")
        print(f"👤 **사용자:** {metadata.user_id}")
        print(f"🔗 **세션:** {metadata.session_id}")
        print(f"❓ **쿼리:** {metadata.user_input}")
        if metadata.additional_params:
            print(f"⚙️ **매개변수:** {metadata.additional_params}")

# 사용 예제 및 테스트
async def main():
    """Agent Squad 기능을 시연하는 메인 함수"""
    
    # 튜토리얼 시스템 초기화
    agent_system = AgentSquadTutorial()
    
    # 다양한 도메인에 대한 테스트 쿼리
    test_queries = [
        "마이크로서비스 아키텍처 구현의 모범 사례는 무엇인가요?",
        "식단과 운동을 통해 심혈관 건강을 개선하려면 어떻게 해야 하나요?",
        "기술 스타트업을 위한 사업 계획을 세울 때 고려해야 할 사항은 무엇인가요?",
        "Docker 컨테이너와 가상 머신의 차이점을 설명해주세요",
        "바쁜 직장인을 위한 효과적인 스트레스 관리 기법은 무엇인가요?"
    ]
    
    print("🚀 **Agent Squad 튜토리얼 데모**\n")
    print("=" * 50)
    
    for i, query in enumerate(test_queries, 1):
        print(f"\n**테스트 쿼리 {i}:**")
        print("-" * 30)
        await agent_system.process_query(query)
        print("=" * 50)

if __name__ == "__main__":
    asyncio.run(main())
```

### TypeScript 구현

동등한 TypeScript 구현은 다음과 같습니다:

```typescript
import { AgentSquad } from '@awslabs/agent-squad';
import { BedrockLLMAgent, BedrockLLMAgentOptions } from '@awslabs/agent-squad';

class AgentSquadTutorial {
    private orchestrator: AgentSquad;
    
    constructor() {
        this.orchestrator = new AgentSquad();
        this.setupAgents();
    }
    
    private setupAgents(): void {
        // 기술 전문가 에이전트
        const techAgent = new BedrockLLMAgent({
            name: '기술 전문가',
            streaming: true,
            description: `소프트웨어 개발, 클라우드 컴퓨팅, AI/ML, 
                         사이버보안, 블록체인, 신기술 전문가입니다.`,
            modelId: 'anthropic.claude-3-sonnet-20240229-v1:0',
        } as BedrockLLMAgentOptions);
        
        // 건강 및 웰빙 에이전트
        const healthAgent = new BedrockLLMAgent({
            name: '건강 및 웰빙 전문가',
            streaming: true,
            description: `건강, 웰빙, 영양, 피트니스, 정신건강, 
                         의료 정보 전문가입니다.`,
            modelId: 'anthropic.claude-3-sonnet-20240229-v1:0',
        } as BedrockLLMAgentOptions);
        
        // 오케스트레이터에 에이전트 추가
        this.orchestrator.addAgent(techAgent);
        this.orchestrator.addAgent(healthAgent);
    }
    
    async processQuery(
        userInput: string, 
        userId: string = 'user123', 
        sessionId: string = 'session456'
    ): Promise<void> {
        try {
            const response = await this.orchestrator.routeRequest(
                userInput,
                userId,
                sessionId,
                {},
                true
            );
            
            await this.handleResponse(response);
            
        } catch (error) {
            console.error('쿼리 처리 중 오류:', error);
        }
    }
    
    private async handleResponse(response: any): Promise<void> {
        if (response.streaming) {
            console.log('\n🤖 **스트리밍 응답**\n');
            
            // 메타데이터 표시
            this.printMetadata(response.metadata);
            
            console.log('\n📝 **응답:**');
            
            // 스트리밍 응답 처리
            for await (const chunk of response.output) {
                if (chunk.text) {
                    process.stdout.write(chunk.text);
                }
            }
            
            console.log('\n');
            
        } else {
            console.log('\n🤖 **응답**\n');
            this.printMetadata(response.metadata);
            console.log(`\n📝 **응답:** ${response.output.content}`);
        }
    }
    
    private printMetadata(metadata: any): void {
        console.log(`🎯 **에이전트:** ${metadata.agentName} (ID: ${metadata.agentId})`);
        console.log(`👤 **사용자:** ${metadata.userId}`);
        console.log(`🔗 **세션:** ${metadata.sessionId}`);
        console.log(`❓ **쿼리:** ${metadata.userInput}`);
    }
}

// 사용 예제
async function main() {
    const agentSystem = new AgentSquadTutorial();
    
    const testQueries = [
        "클라우드 컴퓨팅의 최신 트렌드는 무엇인가요?",
        "재택근무하면서 정신건강을 어떻게 유지할 수 있나요?"
    ];
    
    console.log('🚀 **Agent Squad 튜토리얼 데모 (TypeScript)**\n');
    
    for (const query of testQueries) {
        await agentSystem.processQuery(query);
        console.log('='.repeat(50));
    }
}

main().catch(console.error);
```

## 고급 설정

### 사용자 정의 에이전트 생성

기본 에이전트 클래스를 확장하여 사용자 정의 에이전트를 생성할 수 있습니다:

```python
from agent_squad.agents import Agent, AgentOptions
from typing import Optional, Dict, Any

class CustomDatabaseAgent(Agent):
    def __init__(self, options: AgentOptions):
        super().__init__(options)
        # 데이터베이스 연결, 도구 등 초기화
        
    async def process_request(
        self, 
        input_text: str, 
        user_id: str, 
        session_id: str, 
        chat_history: list,
        additional_params: Optional[Dict[str, Any]] = None
    ):
        # 사용자 정의 처리 로직
        # 데이터베이스 쿼리, 계산 수행 등
        
        # 구조화된 응답 반환
        return {
            "content": "데이터베이스 쿼리 결과...",
            "metadata": {
                "query_time": "0.5초",
                "records_found": 42
            }
        }
```

### 고급 오케스트레이터 설정

```python
from agent_squad.orchestrator import AgentSquad
from agent_squad.classifiers import BedrockClassifier, BedrockClassifierOptions

# 사용자 정의 분류기를 사용한 오케스트레이터 생성
classifier = BedrockClassifier(BedrockClassifierOptions(
    model_id="anthropic.claude-3-haiku-20240307-v1:0",
    inference_config={
        "maxTokens": 1000,
        "temperature": 0.1
    }
))

orchestrator = AgentSquad(
    classifier=classifier,
    logger=custom_logger,
    config={
        "LOG_AGENT_CHAT": True,
        "LOG_CLASSIFIER_CHAT": True,
        "LOG_CLASSIFIER_RAW_OUTPUT": True,
        "LOG_CLASSIFIER_OUTPUT": True,
        "LOG_EXECUTION_TIMES": True,
        "MAX_RETRIES": 3,
        "USE_DEFAULT_AGENT_IF_NONE_IDENTIFIED": True,
        "MAX_TOKENS": 1000,
        "TEMPERATURE": 0.1
    }
)
```

## 실제 사용 사례 및 예제

### 고객 서비스 자동화

```python
async def setup_customer_service_agents():
    """전문화된 고객 서비스 에이전트 설정"""
    
    orchestrator = AgentSquad()
    
    # 기술 지원 에이전트
    tech_support = BedrockLLMAgent(BedrockLLMAgentOptions(
        name="기술 지원",
        description="기술적 문제, 문제 해결, 제품 지원을 처리합니다",
        model_id="anthropic.claude-3-sonnet-20240229-v1:0",
    ))
    
    # 청구 및 계정 에이전트
    billing_agent = BedrockLLMAgent(BedrockLLMAgentOptions(
        name="청구 지원",
        description="청구 문의, 계정 관리, 결제 문제를 처리합니다",
        model_id="anthropic.claude-3-sonnet-20240229-v1:0",
    ))
    
    # 일반 정보 에이전트
    info_agent = BedrockLLMAgent(BedrockLLMAgentOptions(
        name="정보 에이전트",
        description="일반적인 회사 정보, 정책, 기본 문의를 제공합니다",
        model_id="anthropic.claude-3-sonnet-20240229-v1:0",
    ))
    
    orchestrator.add_agent(tech_support)
    orchestrator.add_agent(billing_agent)
    orchestrator.add_agent(info_agent)
    
    return orchestrator
```

### 교육 플랫폼

```python
async def setup_educational_agents():
    """다양한 학문 분야를 위한 에이전트 설정"""
    
    orchestrator = AgentSquad()
    
    subjects = [
        ("수학", "수학, 미적분, 통계, 문제 해결 전문가"),
        ("과학", "물리학, 화학, 생물학, 과학적 개념 전문가"),
        ("문학", "문학 분석, 글쓰기, 언어 예술 전문가"),
        ("역사", "세계사, 역사 분석, 사회 연구 전문가")
    ]
    
    for name, description in subjects:
        agent = BedrockLLMAgent(BedrockLLMAgentOptions(
            name=f"{name} 튜터",
            description=description,
            model_id="anthropic.claude-3-sonnet-20240229-v1:0",
            streaming=True
        ))
        orchestrator.add_agent(agent)
    
    return orchestrator
```

## 성능 최적화

### 연결 풀링 및 캐싱

```python
from agent_squad.orchestrator import AgentSquad
import asyncio
from functools import lru_cache

class OptimizedAgentSquad:
    def __init__(self):
        self.orchestrator = AgentSquad()
        self._connection_pool = self._setup_connection_pool()
        self._setup_caching()
    
    def _setup_connection_pool(self):
        """더 나은 성능을 위한 연결 풀 설정"""
        # 다양한 서비스를 위한 연결 풀 설정
        return {
            'bedrock': self._create_bedrock_pool(),
            'openai': self._create_openai_pool(),
        }
    
    @lru_cache(maxsize=1000)
    def _cached_classification(self, query_hash: str):
        """유사한 쿼리에 대한 분류 결과 캐싱"""
        # 분류 결과 캐싱 구현
        pass
    
    async def batch_process_queries(self, queries: list):
        """여러 쿼리를 동시에 처리"""
        tasks = [
            self.orchestrator.route_request(query, f"user_{i}", f"session_{i}")
            for i, query in enumerate(queries)
        ]
        
        results = await asyncio.gather(*tasks, return_exceptions=True)
        return results
```

### 모니터링 및 로깅

```python
import logging
import time
from functools import wraps

class AgentSquadMonitor:
    def __init__(self, orchestrator):
        self.orchestrator = orchestrator
        self.logger = logging.getLogger('agent_squad_monitor')
        self._setup_monitoring()
    
    def _setup_monitoring(self):
        """포괄적인 모니터링 설정"""
        self.metrics = {
            'total_requests': 0,
            'successful_requests': 0,
            'failed_requests': 0,
            'average_response_time': 0,
            'agent_usage': {}
        }
    
    def monitor_request(self, func):
        """요청 성능을 모니터링하는 데코레이터"""
        @wraps(func)
        async def wrapper(*args, **kwargs):
            start_time = time.time()
            self.metrics['total_requests'] += 1
            
            try:
                result = await func(*args, **kwargs)
                self.metrics['successful_requests'] += 1
                
                # 에이전트 사용량 추적
                agent_name = result.metadata.agent_name
                self.metrics['agent_usage'][agent_name] = \
                    self.metrics['agent_usage'].get(agent_name, 0) + 1
                
                return result
                
            except Exception as e:
                self.metrics['failed_requests'] += 1
                self.logger.error(f"요청 실패: {e}")
                raise
                
            finally:
                # 평균 응답 시간 업데이트
                response_time = time.time() - start_time
                self._update_average_response_time(response_time)
        
        return wrapper
    
    def _update_average_response_time(self, response_time):
        """응답 시간의 실행 평균 업데이트"""
        current_avg = self.metrics['average_response_time']
        total_requests = self.metrics['total_requests']
        
        self.metrics['average_response_time'] = \
            (current_avg * (total_requests - 1) + response_time) / total_requests
    
    def get_performance_report(self):
        """성능 보고서 생성"""
        return {
            'summary': self.metrics,
            'success_rate': self.metrics['successful_requests'] / self.metrics['total_requests'] * 100,
            'most_used_agent': max(self.metrics['agent_usage'], 
                                 key=self.metrics['agent_usage'].get) if self.metrics['agent_usage'] else None
        }
```

## 배포 전략

### AWS Lambda 배포

```python
import json
import asyncio
from agent_squad.orchestrator import AgentSquad
from agent_squad.agents import BedrockLLMAgent, BedrockLLMAgentOptions

# Lambda 컨테이너 재사용을 위한 글로벌 오케스트레이터 인스턴스
orchestrator = None

def lambda_handler(event, context):
    """Agent Squad를 위한 AWS Lambda 핸들러"""
    
    global orchestrator
    
    # 콜드 스타트 시 오케스트레이터 초기화
    if orchestrator is None:
        orchestrator = setup_orchestrator()
    
    # 요청 데이터 추출
    body = json.loads(event['body'])
    user_input = body['message']
    user_id = body.get('user_id', 'anonymous')
    session_id = body.get('session_id', 'default')
    
    # 요청 처리
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    
    try:
        response = loop.run_until_complete(
            orchestrator.route_request(user_input, user_id, session_id)
        )
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'response': response.output.content,
                'agent': response.metadata.agent_name,
                'success': True
            })
        }
        
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e),
                'success': False
            })
        }
    
    finally:
        loop.close()

def setup_orchestrator():
    """프로덕션 설정으로 오케스트레이터 설정"""
    squad = AgentSquad()
    
    # 프로덕션 에이전트 추가
    tech_agent = BedrockLLMAgent(BedrockLLMAgentOptions(
        name="프로덕션 기술 에이전트",
        description="프로덕션 준비된 기술 지원 에이전트",
        model_id="anthropic.claude-3-sonnet-20240229-v1:0",
    ))
    
    squad.add_agent(tech_agent)
    return squad
```

### Docker 배포

```dockerfile
# Agent Squad 애플리케이션을 위한 Dockerfile
FROM python:3.11-slim

WORKDIR /app

# 시스템 의존성 설치
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# requirements를 복사하고 Python 의존성 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 애플리케이션 코드 복사
COPY . .

# 포트 노출
EXPOSE 8000

# 환경 변수 설정
ENV PYTHONPATH=/app
ENV AWS_DEFAULT_REGION=us-east-1

# 애플리케이션 실행
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## 모범 사례 및 팁

### 1. 에이전트 설계 원칙

- **단일 책임**: 각 에이전트는 명확하게 정의된 도메인을 가져야 함
- **명확한 설명**: 더 나은 라우팅을 위해 상세한 에이전트 설명 작성
- **성능 최적화**: 다양한 작업에 적절한 모델 크기 사용
- **오류 처리**: 견고한 오류 처리 및 폴백 메커니즘 구현

### 2. 컨텍스트 관리

```python
# 효과적인 컨텍스트 관리
async def manage_conversation_context(orchestrator, user_id, session_id):
    """컨텍스트 관리 모범 사례"""
    
    # 중요한 컨텍스트 정보 저장
    context = {
        'user_preferences': get_user_preferences(user_id),
        'conversation_history': get_conversation_history(session_id),
        'current_task': 'information_gathering'
    }
    
    # additional_params를 통해 컨텍스트 전달
    response = await orchestrator.route_request(
        user_input="이전 대화를 계속해주세요",
        user_id=user_id,
        session_id=session_id,
        additional_params=context
    )
    
    return response
```

### 3. 보안 고려사항

```python
# 입력 검증 및 살균화
def validate_input(user_input: str) -> bool:
    """보안을 위한 사용자 입력 검증"""
    
    # 악성 콘텐츠 확인
    forbidden_patterns = [
        r'<script.*?</script>',
        r'javascript:',
        r'on\w+\s*='
    ]
    
    import re
    for pattern in forbidden_patterns:
        if re.search(pattern, user_input, re.IGNORECASE):
            return False
    
    # 입력 길이 확인
    if len(user_input) > 10000:
        return False
    
    return True

# 속도 제한 구현
from collections import defaultdict
import time

class RateLimiter:
    def __init__(self, max_requests=100, time_window=3600):
        self.max_requests = max_requests
        self.time_window = time_window
        self.requests = defaultdict(list)
    
    def is_allowed(self, user_id: str) -> bool:
        now = time.time()
        user_requests = self.requests[user_id]
        
        # 오래된 요청 제거
        self.requests[user_id] = [
            req_time for req_time in user_requests 
            if now - req_time < self.time_window
        ]
        
        # 제한 미만인지 확인
        if len(self.requests[user_id]) < self.max_requests:
            self.requests[user_id].append(now)
            return True
        
        return False
```

## 문제 해결 가이드

### 일반적인 문제 및 해결책

1. **에이전트 선택 문제**
   ```python
   # 에이전트 선택 디버그
   orchestrator.config['LOG_CLASSIFIER_OUTPUT'] = True
   orchestrator.config['LOG_CLASSIFIER_RAW_OUTPUT'] = True
   ```

2. **큰 컨텍스트로 인한 메모리 문제**
   ```python
   # 컨텍스트 절단 구현
   def truncate_context(context, max_length=8000):
       if len(context) > max_length:
           return context[-max_length:]
       return context
   ```

3. **성능 병목 현상**
   ```python
   # 비동기 처리 구현
   import asyncio
   
   async def process_multiple_requests(requests):
       tasks = [process_single_request(req) for req in requests]
       return await asyncio.gather(*tasks)
   ```

## 구현 테스트

포괄적인 테스트 스위트 생성:

```python
import pytest
import asyncio
from agent_squad.orchestrator import AgentSquad

class TestAgentSquad:
    @pytest.fixture
    async def orchestrator(self):
        """테스트 오케스트레이터 설정"""
        squad = AgentSquad()
        # 테스트 에이전트 추가
        return squad
    
    @pytest.mark.asyncio
    async def test_tech_query_routing(self, orchestrator):
        """기술 쿼리가 기술 에이전트로 라우팅되는지 테스트"""
        response = await orchestrator.route_request(
            "Docker 컨테이너를 어떻게 배포하나요?",
            "test_user",
            "test_session"
        )
        
        assert "tech" in response.metadata.agent_name.lower()
    
    @pytest.mark.asyncio
    async def test_streaming_response(self, orchestrator):
        """스트리밍 기능 테스트"""
        response = await orchestrator.route_request(
            "머신러닝 설명해주세요",
            "test_user",
            "test_session",
            streaming=True
        )
        
        assert response.streaming is True
        
        # 스트리밍된 콘텐츠 수집
        content = ""
        async for chunk in response.output:
            content += chunk.text
        
        assert len(content) > 0
```

## 결론

Agent Squad는 멀티 에이전트 AI 시스템의 강력한 진화를 나타내며, 다음을 제공합니다:

- 더 나은 사용자 경험을 위한 **지능적 라우팅**
- 다양한 AI 공급자를 지원하는 **유연한 아키텍처**
- 엔터프라이즈 배포를 위한 **프로덕션 준비 기능**
- **강력한 커뮤니티 지원**과 활발한 개발

프레임워크의 이중 언어 지원(Python/TypeScript)과 모듈형 설계는 프로토타이핑과 프로덕션 배포 모두에 탁월한 선택이 됩니다. 고객 서비스 시스템, 교육 플랫폼, 또는 복잡한 대화형 AI 애플리케이션을 구축하든, Agent Squad는 정교한 멀티 에이전트 오케스트레이션을 위한 기반을 제공합니다.

### 다음 단계

1. 기본 구현을 **실험**해보세요
2. 특정 사용 사례에 맞게 **에이전트를 사용자 정의**하세요
3. **모니터링**과 성능 최적화를 구현하세요
4. 선호하는 클라우드 플랫폼에 **배포**하세요
5. 오픈소스 커뮤니티에 **기여**하세요

고급 기능과 엔터프라이즈 지원을 위해서는 [공식 문서](https://awslabs.github.io/agent-squad/)를 탐색하고 성장하는 Agent Squad 개발자 커뮤니티에 참여하세요.

---

*이 튜토리얼은 AWS Agent Squad 작업을 위한 포괄적인 기반을 제공합니다. 프레임워크가 계속 발전함에 따라 공식 저장소와 문서를 통해 최신 기능과 모범 사례를 계속 업데이트하세요.*
