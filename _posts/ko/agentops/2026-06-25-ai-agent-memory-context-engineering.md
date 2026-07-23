---
title: "AI 에이전트에게 진짜 기억을 주는 법 - 컨텍스트 엔지니어링 4가지 기법"
excerpt: "컨텍스트 창은 크다고 좋은 것이 아닙니다. 토큰이 늘수록 모델의 회상 정확도가 떨어지는 컨텍스트 로트(context rot) 때문입니다. Anthropic이 정리한 컴팩션, 구조적 노트, 서브에이전트, 파일 기반 메모리 도구 네 가지 기법을 살펴보고, ThakiCloud가 실제 에이전트 운용에 어떻게 적용하는지 정리합니다."
seo_title: "AI 에이전트 메모리와 컨텍스트 엔지니어링 4기법 - Thaki Cloud"
seo_description: "컨텍스트 로트, 어텐션 예산, 컴팩션, 구조적 노트테이킹, 서브에이전트 아키텍처, 파일 기반 메모리 도구. 장기 실행 AI 에이전트가 컨텍스트 창 한계를 넘는 방법과 멀티테넌트 플랫폼 적용 관점."
date: 2026-06-25
last_modified_at: 2026-06-25
tags:
  - ai-agent
  - context-engineering
  - memory
  - llm
  - agent-architecture
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ko/agentops/ai-agent-memory-context-engineering/"
reading_time: true
audiobook: https://drive.google.com/file/d/193SGbK-XbseE5RHN3soLHZHWBRiEUrud/view
audiobook_note: "AI 로컬 합성 오디오북 (Qwen3-TTS)"
categories:
  - agentops
published: false
---

LLM 에이전트를 오래 돌려 본 사람은 같은 벽에 부딪힙니다. 대화가 길어질수록 에이전트가 앞에서 한 약속을 잊고, 초반에 정한 규칙을 무시하기 시작합니다. 흔한 처방은 "컨텍스트 창이 더 크면 해결된다"입니다. 그러나 이것은 틀린 진단입니다. 진짜 문제는 창의 크기가 아니라 그 안의 토큰을 어떻게 관리하느냐, 즉 컨텍스트 엔지니어링입니다. 이 글은 장기 실행 에이전트가 컨텍스트 한계를 넘는 네 가지 검증된 기법을 정리하고, ThakiCloud가 실제 에이전트 운용에 이를 어떻게 녹였는지 보여 줍니다.

## 개요

컨텍스트 엔지니어링은 프롬프트 엔지니어링의 다음 단계입니다. 프롬프트 엔지니어링이 "어떤 말을 적느냐"에 집중했다면, 컨텍스트 엔지니어링은 "추론 시점에 모델의 한정된 주의 예산에 어떤 토큰을 채워 넣느냐"를 다룹니다. 시스템 지시, 도구 정의, MCP, 외부 데이터, 메시지 이력 전체가 대상입니다. 에이전트는 루프를 돌면서 다음 턴에 쓸 수 있는 데이터를 계속 만들어 내고, 이 정보는 주기적으로 정제돼야 합니다.

왜 토큰을 아껴야 할까요. LLM도 사람처럼 일정 지점을 넘으면 집중을 잃습니다. 토큰 수가 늘수록 그 안의 정보를 정확히 회상하는 능력이 떨어지는 현상을 컨텍스트 로트(context rot)라고 부릅니다. 정도의 차이는 있어도 모든 모델에서 나타납니다. 근본 원인은 트랜스포머 구조입니다. 모든 토큰이 다른 모든 토큰에 주의를 보내므로 토큰 n개에 대해 n의 제곱에 해당하는 관계가 생깁니다. 컨텍스트가 길어질수록 주의 예산이 묽어집니다. 그래서 컨텍스트는 무한한 저장소가 아니라 한정된 자원으로 다뤄야 합니다. 핵심은 원하는 결과를 낼 가능성을 가장 높이는 고신호 토큰의 최소 집합을 찾는 것입니다.

## 에이전트 메모리의 문제 구조

장기 실행 작업은 토큰 수가 컨텍스트 창을 넘는 행동의 연속에서 일관성과 목표 지향성을 유지해야 합니다. 대규모 코드베이스 마이그레이션이나 수 시간짜리 리서치처럼 수십 분에서 여러 시간 이어지는 작업이 그렇습니다. 이때 단순히 모든 것을 창에 쌓아 두는 방식은 컨텍스트 로트로 무너집니다. 그래서 정보를 창 밖으로 빼내고, 필요할 때만 다시 끌어오는 구조가 필요합니다. 아래 도식이 그 골격입니다.

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
<div class="d3-arch" data-arch-root id="memorycontextengineering-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 911, "height": 394, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "LOOP", "x": 24, "y": 258, "w": 120, "h": 46, "title": "에이전트 루프"}, {"id": "FULL", "x": 222, "y": 72, "w": 138, "h": 52, "title": "컨텍스트 한계 근접?"}, {"id": "COMPACT", "x": 503, "y": 125, "w": 149, "h": 46, "title": "컴팩션: 요약 후 새 창 재시작"}, {"id": "NOTE", "x": 500, "y": 24, "w": 156, "h": 46, "title": "구조적 노트: 핵심을 파일에 기록"}, {"id": "STORE", "x": 744, "y": 125, "w": 135, "h": 46, "title": "파일 기반 메모리 (창 밖)"}, {"id": "SUB", "x": 231, "y": 228, "w": 120, "h": 46, "title": "서브에이전트 분리"}, {"id": "DISTILL", "x": 489, "y": 258, "w": 177, "h": 46, "title": "1,000-2,000 토큰 요약만 반환"}], "edges": [{"src": "LOOP", "dst": "FULL", "kind": "data", "curve": [[96, 258], [183, 98], [183, 98], [222, 98]]}, {"src": "FULL", "dst": "COMPACT", "kind": "data", "label": "예", "curve": [[360, 124], [425, 148], [425, 148], [503, 148]], "off": "50%"}, {"src": "FULL", "dst": "NOTE", "kind": "data", "label": "아니오", "curve": [[360, 72], [425, 47], [425, 47], [500, 47]], "off": "50%"}, {"src": "NOTE", "dst": "STORE", "kind": "data", "curve": [[656, 47], [705, 47], [705, 47], [787, 125]]}, {"src": "COMPACT", "dst": "STORE", "kind": "data", "line": [652, 148, 744, 148]}, {"src": "LOOP", "dst": "SUB", "kind": "data", "curve": [[144, 262], [183, 251], [183, 251], [231, 251]]}, {"src": "SUB", "dst": "DISTILL", "kind": "data", "curve": [[351, 251], [425, 251], [425, 251], [489, 263]]}, {"src": "DISTILL", "dst": "LOOP", "kind": "data", "curve": [[489, 298], [425, 311], [183, 311], [144, 299]]}, {"src": "STORE", "dst": "LOOP", "kind": "data", "label": "리셋 후 재로드", "curve": [[800, 171], [578, 355], [291, 355], [115, 304]], "off": "50%"}]});
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
      const container = document.getElementById('memorycontextengineering-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'memorycontextengineering-1';
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

이 구조의 목표는 단순합니다. 상세한 작업 컨텍스트는 창 밖으로 격리하고, 메인 에이전트의 창에는 결정에 필요한 고신호 토큰만 남기는 것입니다.

## 네 가지 기법

### 컴팩션

컴팩션은 컨텍스트 창이 한계에 가까워졌을 때 내용을 요약하고 그 요약으로 새 창을 다시 시작하는 기법입니다. 장기 일관성을 끌어올리는 첫 번째 지렛대입니다. 핵심은 충실도 높은 요약입니다. 창의 내용을 고밀도로 압축해 에이전트가 성능 저하를 최소화한 채 이어가게 합니다. 예를 들어 Claude Code는 메시지 이력을 모델에 넘겨 가장 중요한 세부를 요약하고 압축하는 방식으로 이를 구현합니다. 컴팩션이 제대로 되면 에이전트는 사실상 끊김 없이 작업을 계속합니다.

### 구조적 노트테이킹

구조적 노트테이킹은 에이전트가 작업 중 핵심 정보를 창 밖 파일에 적어 두고, 나중에 다시 읽는 방식입니다. 컨텍스트가 리셋된 뒤에도 에이전트는 자기가 남긴 노트를 읽어 수 시간짜리 작업을 이어갑니다. 요약 단계를 넘나드는 이 일관성 덕분에, 모든 정보를 창에 들고 있어야만 가능했을 장기 전략이 비로소 실현됩니다. 사람이 회의 중 메모를 남기고 다음 회의에서 그 메모로 맥락을 복구하는 것과 같은 원리입니다.

### 서브에이전트 아키텍처

서브에이전트는 컨텍스트 한계를 우회하는 또 다른 길입니다. 한 에이전트가 프로젝트 전체의 상태를 떠안는 대신, 전문화된 서브에이전트가 깨끗한 컨텍스트 창으로 좁은 작업을 맡습니다. 메인 에이전트는 고수준 계획으로 조율하고, 서브에이전트는 깊은 기술 작업이나 탐색을 수행합니다. 각 서브에이전트는 수만 토큰을 써 가며 광범위하게 탐색하지만, 메인에는 1,000에서 2,000 토큰 수준으로 정제된 요약만 돌려줍니다. 상세한 탐색 컨텍스트는 서브에이전트 안에 격리되고, 메인 에이전트의 창은 결정에 집중하는 깔끔한 분업이 만들어집니다.

### 파일 기반 메모리 도구

Anthropic은 Sonnet 4.5 출시와 함께 Claude 개발자 플랫폼에 메모리 도구를 퍼블릭 베타로 공개했습니다. 파일 시스템을 통해 컨텍스트 창 밖에 정보를 저장하고 다시 참조하기 쉽게 만든 도구입니다. 이를 통해 에이전트는 시간에 걸쳐 지식 베이스를 쌓고, 세션을 넘어 프로젝트 상태를 유지하며, 모든 것을 창에 들고 있지 않아도 이전 작업을 참조합니다. 앞의 세 기법이 원리라면, 이 도구는 그 원리를 표준 인터페이스로 묶은 구현입니다.

## 단순 접근과의 비교

이 기법들의 가치를 보려면 흔한 대안과 비교하는 것이 좋습니다. 첫 번째 대안은 모든 것을 그냥 큰 컨텍스트 창에 욱여넣는 방식입니다. 단순하지만 컨텍스트 로트로 무너지고, 매 턴 거대한 이력을 다시 읽으니 비용도 선형으로 늘어납니다. 두 번째 대안은 벡터 검색 기반 RAG입니다. 외부 지식을 끌어오는 데는 강하지만, 에이전트 자신이 작업 중 만든 상태(중간 결정, 진행 상황, 자기 노트)를 다루는 데는 어색합니다. RAG는 읽기에 최적화돼 있지 쓰기와 갱신에 최적화돼 있지 않기 때문입니다.

파일 기반 메모리와 구조적 노트는 이 빈틈을 메웁니다. 에이전트가 스스로 적고, 갱신하고, 리셋 후 다시 읽는 상태 저장소를 제공하기 때문입니다. 또 하나의 원칙은 적시 인출(just-in-time)입니다. 모든 정보를 미리 창에 올리는 대신, 가벼운 식별자(파일 경로, 인덱스 항목)만 들고 있다가 정말 필요한 순간에만 본문을 읽어 옵니다. 컴팩션, 노트, 서브에이전트, 적시 인출은 서로 배타적이지 않고 함께 쌓을수록 강해집니다.

## ThakiCloud의 적용

이 네 가지 기법은 추상적인 이론이 아니라 ThakiCloud가 매일 돌리는 에이전트 운용의 골격 그 자체입니다. 우리 내부 에이전트 하니스는 파일 기반 메모리 아키텍처를 3계층으로 둡니다. 매 세션에 로드되는 `MEMORY.md` 인덱스가 한 줄짜리 포인터를 들고 있고, 상세 사실은 `memory/topics/`에, 긴 작업 기록은 `memory/sessions/`에 분리해 둡니다. 인덱스만 컨텍스트에 올리고 상세는 필요할 때만 끌어오는 이 구조가 바로 구조적 노트테이킹과 파일 기반 메모리, 그리고 적시 인출의 결합입니다.

인덱스는 대략 다음과 같은 한 줄 포인터의 모음입니다.

```markdown
- [Model Routing](feedback_model_routing.md) - 서브에이전트 모델 스태킹: 탐색은 저비용, 구현은 중간, 아키텍처는 고비용
- [Hermes Ecosystem](project_hermes_ecosystem.md) - 독립 에이전트 프레임워크 설치 기록
```

각 항목은 한 파일에 하나의 사실을 담고, 본문 안에서 다른 메모리를 링크로 연결합니다. 세션은 이 인덱스만 읽고, 관련 있는 항목의 본문은 그 순간에만 펼쳐 봅니다. 새 사실이 생기면 기존 파일을 갱신하고, 틀린 것으로 드러난 메모리는 삭제합니다. 이 위생 작업이 노트 오염 전파를 막는 장치입니다.

서브에이전트 분업도 그대로 씁니다. 코드베이스 전수 탐색이나 대용량 검색은 메인 컨텍스트에서 직접 하지 않고, 저비용 모델의 서브에이전트에 위임해 결론 요약만 회수합니다. 원본 덤프를 메인에 쏟지 않는다는 규칙은 Anthropic이 말한 "서브에이전트는 1,000에서 2,000 토큰 요약만 반환한다"와 정확히 같은 원칙입니다. 이렇게 하면 메인 세션의 캐시 재읽기 비용이 선형으로 부푸는 것을 막을 수 있습니다.

컴팩션도 운용 규율에 박혀 있습니다. 우리는 컨텍스트 사용률을 40% 이하로 유지하고, 60%를 넘기기 전에 수동 컴팩션을 실행하는 것을 권장합니다. 자동 컴팩션이 돌기 전에 작업자가 의도한 초점으로 먼저 압축하는 편이 충실도가 높기 때문입니다. 멀티테넌트 환경에서 이것은 단순한 품질 문제가 아니라 비용 문제입니다. 거대한 컨텍스트가 매 턴 반복되면 캐시 재읽기 토큰이 비용의 큰 부분을 차지합니다. 컨텍스트를 한정 자원으로 다루는 규율이 곧 단위 추론 비용을 낮추는 길입니다.

플랫폼 관점에서 정리하면, 에이전트 메모리는 ThakiCloud가 여러 고객의 장기 실행 에이전트를 같은 인프라 위에서 안정적으로 운용하기 위한 핵심 역량입니다. 세션을 넘어 상태를 유지하면서도 컨텍스트를 가볍게 유지하는 에이전트는 그 자체로 배포 가능한 제품이 됩니다. Kubernetes 기반 멀티테넌트 위에서 이 메모리 계층을 테넌트별로 격리해 운용할 수 있다는 점이 우리 제안의 차별점입니다.

## 한계 및 반론

기법마다 대가가 있습니다. 컴팩션은 요약 과정에서 정보를 잃습니다. 무엇을 버릴지 잘못 고르면 뒤 작업이 어긋납니다. 충실도 높은 요약은 그 자체로 어려운 문제이며, 요약 프롬프트의 품질에 결과가 좌우됩니다.

구조적 노트와 파일 메모리는 노트가 오염되면 그대로 오염을 전파합니다. 잘못 적힌 사실이 파일에 남으면 이후 세션이 그것을 진실로 받아들입니다. 그래서 메모리에 무엇을 적을지에 대한 게이트가 필요하고, 오래된 사실을 정리하는 위생 작업이 따릅니다.

서브에이전트는 분업의 경계를 잘못 그으면 오히려 오버헤드가 됩니다. 단일 파일 편집이나 단순 조회까지 서브에이전트로 위임하면 컨텍스트를 아끼는 대신 디스패치 비용만 늘어납니다. 위임은 메인 컨텍스트 위생을 위한 도구이지 모든 작업의 기본값이 아닙니다.

마지막으로 모델이 더 똑똑해질수록 이런 처방의 필요가 줄어든다는 점도 정직하게 인정해야 합니다. 이미 더 강한 모델은 덜 규범적인 엔지니어링으로도 더 큰 자율성을 보입니다. 그래도 컨텍스트를 한정 자원으로 다루는 원칙 자체는 능력이 커져도 남을 것입니다. 기법은 바뀌어도 주의 예산을 아낀다는 방향은 유효합니다.


## 관련 슬라이드

본문 내용을 NotebookLM(`architectural_mono` 스타일)으로 요약한 슬라이드입니다.

![ai-agent-memory-context-engineering 슬라이드 1]({{ '/assets/images/ai-agent-memory-context-engineering-slide-01.webp' | relative_url }})

![ai-agent-memory-context-engineering 슬라이드 2]({{ '/assets/images/ai-agent-memory-context-engineering-slide-02.webp' | relative_url }})

![ai-agent-memory-context-engineering 슬라이드 3]({{ '/assets/images/ai-agent-memory-context-engineering-slide-03.webp' | relative_url }})

![ai-agent-memory-context-engineering 슬라이드 4]({{ '/assets/images/ai-agent-memory-context-engineering-slide-04.webp' | relative_url }})

## 출처

- Anthropic, "Effective context engineering for AI agents" (2025-09-29): [https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- Anthropic, 메모리 및 컨텍스트 관리 쿡북: [https://platform.claude.com/cookbook/tool-use-memory-cookbook](https://platform.claude.com/cookbook/tool-use-memory-cookbook)
