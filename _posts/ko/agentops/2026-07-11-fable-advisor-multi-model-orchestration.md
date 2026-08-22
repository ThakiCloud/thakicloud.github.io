---
title: "Fable 5가 지휘하고 Grok 4.5가 구현하는 크로스벤더 워크플로: fable-advisor"
seo_title: "Fable 5로 Grok 4.5 지휘하기 - fable-advisor 플러그인 분석 - Thaki Cloud"
seo_description: "fable-advisor는 Claude Fable 5가 스펙과 리뷰를 맡고 Grok 4.5가 실제 구현을 타이핑하는 크로스벤더 멀티에이전트 워크플로입니다. 지휘자-워커 분리 구조를 분해하고 ThakiCloud Paxis 관점에서 검증합니다."
excerpt: "Claude Fable 5가 스펙 작성과 diff 리뷰를 지휘하고, 실제 코드 타이핑은 Grok 4.5가 전담하는 fable-advisor 플러그인의 지휘자-워커 분리 구조를 분해하고, 멀티에이전트를 일급 리소스로 다루는 ThakiCloud 관점에서 검증합니다."
date: 2026-07-11
tags:
  - claude-code
  - multi-agent
  - model-routing
  - fable
  - grok
  - agentops
  - paxis
categories:
  - agentops
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/ko/agentops/fable-advisor-multi-model-orchestration/"
audiobook: "https://drive.google.com/file/d/1e7KfUD_JzGgMZVfqDCp78f4G_Yc-Pj6k/view"
audiobook_label: "▶ 5분 브리핑으로 듣기"
audiobook_note: "NotebookLM 오디오 개요 (AI 생성)"
published: false
---

코딩 에이전트를 쓰다 보면 자연스럽게 드는 생각이 있습니다. 스펙을 정교하게 쓰고 결과 diff를 날카롭게 리뷰하는 일과, 실제로 코드를 한 줄 한 줄 타이핑하는 일은 성격이 다른 작업인데, 왜 같은 모델 하나가 둘을 다 해야 하는가입니다. 최근 공개되어 화제가 된 `fable-advisor` 플러그인은 이 질문에 정면으로 답합니다. **Claude Fable 5는 지휘만 하고, 실제 구현은 Grok 4.5가 전담**하는 크로스벤더 워크플로입니다. 코딩 에이전트의 비용과 품질을 함께 고민하는 팀이라면, 역할별로 모델을 갈라 배치하는 이 구조에서 당장 옮겨 쓸 만한 설계 원칙을 얻을 수 있습니다.

![Fable 5가 지휘하고 Grok 4.5가 구현하는 크로스벤더 워크플로: fable-advisor 개념을 형상화한 이미지](/assets/images/fable-advisor-multi-model-orchestration-hero.webp)
*글의 핵심 개념을 형상화했습니다.*

## 개요

지금까지 멀티에이전트 코딩 워크플로는 대체로 한 벤더 안에서 이루어졌습니다. Claude Code라면 Opus가 지휘하고 Sonnet이나 Haiku가 서브에이전트로 도는 식입니다. `fable-advisor`가 흥미로운 지점은 이 분업을 **벤더 경계를 넘어** 구성한다는 데 있습니다. Anthropic의 Fable 5가 오케스트레이션 레이어를, xAI의 Grok 4.5가 구현 레이어를 맡습니다.

이 설계의 핵심 통찰은 명료합니다. 지휘와 구현은 요구하는 능력이 다르고, 비용 구조도 다릅니다. 스펙 작성과 diff 리뷰는 판단과 추론의 영역이라 지휘자에게 적합한 모델이 필요하고, 대량의 코드 타이핑은 처리량과 비용 효율이 중요합니다. `fable-advisor`는 이 둘을 서로 다른 벤더의 모델에 각각 배치해, 각 레이어에 가장 잘 맞는 모델을 쓰도록 합니다. 무료 오픈소스이며 라우팅 로직을 직접 커스터마이징할 수 있다는 점도 실전 도입 문턱을 낮춥니다.

![단일 벤더 멀티에이전트에서 크로스벤더 분업으로 넘어가는 패러다임 전환]({{ '/assets/images/fable-advisor-multi-model-orchestration-slide-03.webp' | relative_url }})

## 이 기술은 무엇인가

`fable-advisor`는 Claude Code에 얹는 플러그인으로, 세 가지 역할 분리를 강제합니다.

![Fable 5는 지휘자로 스펙과 리뷰를, Grok 4.5는 구현자로 코드 타이핑을 전담하는 역할 분리]({{ '/assets/images/fable-advisor-multi-model-orchestration-slide-04.webp' | relative_url }})

첫째, **지휘자(Fable 5)**는 스펙을 쓰고 결과를 리뷰합니다. 사용자의 요구를 받아 구현 스펙으로 분해하고, 구현이 끝난 뒤 diff를 검토합니다. 중요한 점은 지휘자가 **코드를 직접 쓰지 않는다**는 것입니다. 판단과 계약 정의에 집중합니다.

둘째, **구현자(Grok 4.5)**는 실제 타이핑을 전담합니다. 지휘자가 넘긴 스펙을 받아 Grok CLI를 경유해 Grok 4.5가 코드를 작성합니다. 저장소 이력을 보면, v3부터 기존의 Sonnet/Opus 구현 에이전트가 `grok-implementer`로 교체되어 Grok 4.5가 기본 타이핑 레인이 되었습니다. 즉 이 플러그인은 처음부터 크로스벤더였던 것이 아니라, 구현 레인을 저비용·고처리량 모델로 옮기는 방향으로 진화한 결과물입니다.

셋째, **병렬 실행**입니다. 서로 독립적인 스펙은 병렬 에이전트로 동시에 실행됩니다. 지휘자가 작업을 서로 의존하지 않는 단위로 분해하면, 각 단위가 별도 구현 에이전트로 동시에 진행됩니다. 이는 단순한 순차 위임이 아니라 DAG(방향성 비순환 그래프) 형태의 분업에 가깝습니다.

전체 흐름을 도식으로 보면 다음과 같습니다.

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
<div class="d3-arch" data-arch-root id="rmultimodelorchestration-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 635, "height": 518, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "U", "x": 262, "y": 24, "w": 120, "h": 46, "title": "사용자 요구"}, {"id": "F", "x": 262, "y": 148, "w": 121, "h": 62, "title": ["Fable 5 지휘자", "스펙 작성·diff 리뷰"]}, {"id": "S1", "x": 87, "y": 302, "w": 120, "h": 46, "title": "스펙 A"}, {"id": "S2", "x": 483, "y": 302, "w": 120, "h": 46, "title": "스펙 B"}, {"id": "G1", "x": 28, "y": 440, "w": 128, "h": 46, "title": "Grok 4.5 구현자 A"}, {"id": "G2", "x": 424, "y": 440, "w": 128, "h": 46, "title": "Grok 4.5 구현자 B"}, {"id": "R", "x": 262, "y": 302, "w": 120, "h": 46, "title": "통합·리뷰 결과"}], "edges": [{"src": "U", "dst": "F", "kind": "data", "line": [322, 70, 322, 148]}, {"src": "F", "dst": "S1", "kind": "data", "label": "독립 스펙 분해", "curve": [[262, 206], [147, 256], [147, 256], [147, 302]], "off": "50%"}, {"src": "F", "dst": "S2", "kind": "data", "label": "독립 스펙 분해", "curve": [[383, 200], [543, 256], [543, 256], [543, 302]], "off": "50%"}, {"src": "S1", "dst": "G1", "kind": "event", "label": "Grok CLI", "curve": [[147, 348], [147, 394], [147, 394], [110, 440]], "off": "50%"}, {"src": "S2", "dst": "G2", "kind": "event", "label": "Grok CLI", "curve": [[543, 348], [543, 394], [543, 394], [506, 440]], "off": "50%"}, {"src": "G1", "dst": "F", "kind": "data", "label": "diff", "curve": [[74, 440], [37, 394], [37, 256], [262, 195]], "off": "50%"}, {"src": "G2", "dst": "F", "kind": "data", "label": "diff", "curve": [[469, 440], [432, 394], [432, 256], [367, 210]], "off": "50%"}, {"src": "F", "dst": "R", "kind": "data", "line": [322, 210, 322, 302]}]});
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
      const container = document.getElementById('rmultimodelorchestration-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'rmultimodelorchestration-1';
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

## 설치 및 통합

플러그인 설치는 한 줄입니다. Claude Code의 플러그인 마켓플레이스에 저장소를 추가하면 됩니다.

```bash
claude plugin marketplace add DannyMac180/fable-advisor
```

구현 레인을 담당하는 Grok CLI는 별도 인증이 필요합니다. `grok login`으로 로그인하면 SuperGrok 또는 X Premium+ 구독 기반의 OAuth 인증으로 동작하며, 저장소 설명에 따르면 이 경로는 **토큰당 API 과금 없이** 구독만으로 구현 에이전트를 돌릴 수 있습니다. 이 지점이 비용 구조의 핵심입니다. 지휘자는 판단이 필요한 소량의 호출만 하고, 대량의 코드 타이핑은 구독형 요금제 안에서 처리되므로 종량 과금이 붙는 부분을 최소화합니다.

통합 관점에서 눈여겨볼 점은 라우팅 로직이 열려 있다는 것입니다. 어떤 작업을 어느 모델에 보낼지, 어떤 조건에서 병렬화할지를 사용자가 직접 조정할 수 있으므로, 팀의 예산과 품질 요구에 맞춰 레인을 재구성할 수 있습니다.

## 이 설계가 실제로 어떻게 동작하는가

`fable-advisor`는 벤치마크 수치를 내세우는 도구가 아니라 워크플로 패턴입니다. 저장소가 정량 지표를 제시하지 않으므로, 성능 수치가 아니라 설계가 만들어 내는 구조적 효과를 기준으로 봐야 합니다.

가장 큰 효과는 **비용과 품질의 분리**입니다. 판단이 필요한 오케스트레이션은 지휘자에게, 처리량이 필요한 구현은 저비용 구현자에게 배치하면, 전체 워크플로의 단가는 낮아지면서도 판단 품질은 유지됩니다. "지휘자는 싸게 자주 부르지 않고, 구현자는 비싸지 않게 많이 부른다"는 배치가 자연스럽게 성립합니다.

두 번째 효과는 **교차 검증**입니다. 구현자와 리뷰어가 서로 다른 벤더의 모델이라는 점은 흥미로운 부수 효과를 냅니다. 같은 모델이 자기 코드를 리뷰하면 같은 실수를 함께 놓치기 쉽지만, 다른 계열의 모델이 diff를 검토하면 서로의 사각지대를 잡아낼 여지가 커집니다. 지휘자-워커 분리가 단순 분업을 넘어 일종의 상호 검증 장치가 되는 셈입니다.

세 번째는 **병렬화로 인한 지연 단축**입니다. 독립적인 스펙을 동시에 구현하면, 전체 작업 시간이 순차 합계가 아니라 가장 오래 걸리는 단일 체인에 수렴합니다. 지휘자가 작업을 잘 분해할수록 이 이점은 커집니다.

![비용·품질·속도 세 축에서 단일 벤더 워크플로 대비 크로스벤더 분업의 구조적 이점]({{ '/assets/images/fable-advisor-multi-model-orchestration-slide-06.webp' | relative_url }})

## 지휘자-워커 패턴의 일반화

`fable-advisor`를 개별 플러그인이 아니라 하나의 설계 패턴으로 보면, 더 넓은 맥락이 보입니다. 이 패턴의 본질은 "메인 세션은 지휘만, 무거운 작업은 위임"입니다. 크로스벤더는 이 패턴의 한 변형일 뿐이고, 실제로는 같은 벤더 안에서도 성립합니다. 예를 들어 Claude Code에서 Fable 5를 지휘자로 두고 탐색은 Haiku, 구현은 Sonnet, 복잡한 추론은 Opus 서브에이전트로 분기하는 구성이 이미 널리 쓰입니다. `fable-advisor`가 한 일은 이 위임의 대상 모델을 벤더 경계 밖까지 넓힌 것입니다.

이 관점에서 보면 지휘자 모델의 선택 기준이 명확해집니다. 지휘자는 판단·분기·집약을 담당하므로, 정확도와 추론 품질이 중요하되 호출 빈도는 상대적으로 낮습니다. 반대로 구현자는 처리량과 단가가 중요합니다. 따라서 좋은 오케스트레이션은 "가장 비싼 모델을 지휘자에 두고 모든 것을 그 모델로 처리한다"가 아니라, "각 레이어에 그 레이어가 요구하는 특성의 모델을 배치한다"입니다. `fable-advisor`가 구현 레인을 구독형 저비용 모델로 옮긴 v3의 진화는 정확히 이 원칙을 따른 결과입니다.

한 가지 유의할 점은, 이 패턴이 유효하려면 위임의 경계가 명확해야 한다는 것입니다. 지휘자가 스펙을 모호하게 넘기면 구현자는 추측으로 채우고, 그 결과 리뷰 부담이 오히려 커집니다. 위임의 이득은 스펙이 충분히 구체적일 때만 실현됩니다. 이는 사람 조직의 분업과 다르지 않습니다. 명세가 분명할수록 위임이 잘 작동합니다.

## ThakiCloud 제품 적용 시사점

이 설계는 ThakiCloud가 에이전트를 운용하는 방식과 놀라울 만큼 겹칩니다.

**Paxis 관점**에서 가장 직접적입니다. Paxis는 ThakiCloud의 Agent-Native Cloud 제어 평면으로, DAG 형태의 멀티에이전트 실행을 핵심 능력으로 다룹니다. `fable-advisor`가 보여 주는 "스펙 작성 → 분산 구현 → 교차 리뷰" 구조는 Paxis의 스킬 하네스가 작업을 서브태스크로 분해하고, 격리 샌드박스에서 병렬 실행한 뒤, 검증 스테이지로 닫는 설계와 같은 골격입니다. 특히 지휘자가 코드를 직접 쓰지 않고 판단과 계약 정의에 집중한다는 원칙은, 능력을 모델 등급이 아니라 주변 계약 구조에서 끌어낸다는 우리 설계 철학과 정확히 일치합니다. 서로 다른 모델의 결과를 지휘자가 다시 리뷰하는 흐름은, 멀티에이전트 fan-out을 검증 스테이지로 닫아 환각 누적을 막는다는 우리 운영 원칙과도 맞닿습니다.

![fable-advisor의 분업 구조가 Paxis의 DAG 멀티에이전트·격리 샌드박스·계약 기반 철학과 겹치는 지점]({{ '/assets/images/fable-advisor-multi-model-orchestration-slide-07.webp' | relative_url }})

**ai-platform 관점**에서는 비용 구조의 각도가 유효합니다. ThakiCloud의 ai-platform은 K8s와 Kueue 기반으로 GPU 워크로드를 스케줄링하며 고객사의 추론·학습 워크로드를 서빙합니다. `fable-advisor`가 구현 레인을 저비용 모델로 위임해 전체 워크플로 단가를 낮추는 발상은, GPU 클라우드 고객사가 자기 워크로드를 설계할 때 그대로 적용할 수 있는 패턴입니다. 무거운 추론이 필요한 소수의 판단 단계와, 처리량이 중요한 다수의 실행 단계를 서로 다른 티어의 자원에 배치하면, 같은 결과를 더 낮은 비용으로 얻습니다. 저비용 서빙이 곧 에이전트 경제성을 만든다는 점에서, ai-platform의 비용 효율과 Paxis의 에이전트 오케스트레이션은 서로를 보완합니다.

![무거운 추론과 대규모 처리량을 분리해 자원을 배치하는 ai-platform의 비용 경제성 관점]({{ '/assets/images/fable-advisor-multi-model-orchestration-slide-08.webp' | relative_url }})

## 한계 및 반론

이 설계에도 분명한 대가가 따릅니다. 첫째는 **운영 복잡도**입니다. 두 벤더의 모델을 한 워크플로에 엮는다는 것은, 두 개의 인증 체계와 두 개의 요금제, 두 개의 장애 지점을 관리한다는 뜻입니다. 한쪽 벤더의 CLI가 바뀌거나 인증이 만료되면 워크플로 전체가 멈출 수 있습니다. 단일 벤더 워크플로의 단순함을 포기하는 대신 얻는 이점이므로, 그 이점이 복잡도를 정당화하는지 팀마다 판단이 다를 수 있습니다.

둘째는 **품질 위임의 위험**입니다. 구현을 저비용 모델에 맡긴다는 것은, 지휘자의 스펙과 리뷰가 충분히 촘촘하지 않으면 낮은 품질의 구현이 그대로 통과할 수 있다는 뜻입니다. 이 워크플로의 품질은 결국 지휘자의 리뷰 게이트가 얼마나 엄격한가에 달려 있습니다. 리뷰가 형식적이면 크로스벤더 분업의 교차 검증 효과가 사라지고, 비용만 아낀 저품질 파이프라인이 됩니다.

셋째는 **구독 기반 인증의 제약**입니다. Grok CLI가 구독 기반 OAuth로 동작한다는 점은 개인이나 소규모 팀에는 비용 이점이지만, 대규모 자동화나 무인 파이프라인에서는 구독 한도와 인증 갱신이 병목이 될 수 있습니다. 종량 과금이 없다는 장점은, 뒤집으면 사용량이 한도를 넘는 순간 확장이 막힌다는 뜻이기도 합니다.

그럼에도 `fable-advisor`가 던지는 메시지는 분명합니다. 코딩 에이전트의 미래는 하나의 만능 모델이 아니라, 각 레이어에 가장 잘 맞는 모델을 조합하는 오케스트레이션에 있다는 것입니다. 이는 멀티에이전트와 모델 라우팅을 일급 리소스로 다루는 ThakiCloud의 방향과 정확히 같은 곳을 가리킵니다.

## 출처

- [fable-advisor (GitHub)](https://github.com/DannyMac180/fable-advisor)
- [Grok CLI (x.ai/cli)](https://x.ai/cli)
