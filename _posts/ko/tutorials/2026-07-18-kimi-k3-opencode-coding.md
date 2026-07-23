---
title: "Kimi K3로 코딩하기: OpenCode 터미널 에이전트에 2.8T 오픈 모델 연결하기"
seo_title: "Kimi K3 + OpenCode로 터미널에서 코딩하기 - Thaki Cloud"
seo_description: "Moonshot AI가 공개한 2.8조 파라미터 오픈 MoE 모델 Kimi K3를 오픈소스 터미널 코딩 에이전트 OpenCode에 붙여서 코딩하는 방법을 실제 설치 과정과 함께 정리합니다. OpenCode 1.18.3 설치, 프로바이더 인증, 모델 선택 흐름을 직접 확인하고, 2.8T 오픈 모델을 온프렘에서 서빙한다는 관점에서 ThakiCloud의 ai-platform과 Paxis 적용 시사점을 짚습니다."
excerpt: "Fable 5급이라 불리는 2.8T 오픈 모델 Kimi K3를 프로프라이어터리 IDE가 아니라 오픈소스 터미널 에이전트에 붙이는 실전 방법을 봅니다. OpenCode를 직접 설치해 프로바이더 연결 흐름까지 확인했습니다."
date: 2026-07-18
tags:
  - kimi-k3
  - opencode
  - moonshot-ai
  - coding-agent
  - open-weight
  - terminal
  - developer-tools
  - paxis
  - ai-coding
categories:
  - tutorials
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/ko/tutorials/kimi-k3-opencode-coding/"
---

지난 며칠 사이 개발자 타임라인은 "Kimi K3로 코딩하는 법"이라는 스레드로 뒤덮였습니다. 반응은
대체로 두 갈래였습니다. 하나는 벤치마크가 실제로 좋다는 것이고, 다른 하나는 그 모델을 특정
회사의 닫힌 도구가 아니라 내 터미널에서 내가 고른 에이전트로 돌릴 수 있다는 것이었습니다. 이 글은
두 번째 갈래를 다룹니다. 이 글을 읽는 대상은 코딩 에이전트를 특정 벤더의 GUI에 묶어 두기보다,
오픈소스 도구에 원하는 모델을 갈아 끼우며 쓰고 싶은 개발자입니다. 결론부터 말하면, 오픈소스 터미널
에이전트 OpenCode에 Moonshot AI의 Kimi K3를 프로바이더로 붙이면 특정 IDE에 종속되지 않고도 2.8조
파라미터급 모델로 코딩할 수 있습니다.

## 개요

Moonshot AI는 2026년 7월 16일 Kimi K3를 공개했습니다. 회사 발표 기준으로 총 2.8조 파라미터의
Mixture-of-Experts 모델이며, 지금까지 나온 오픈 웨이트 모델 중 가장 큰 축에 듭니다. 흥미로운 점은
성능 지표만이 아닙니다. 이 모델은 프로프라이어터리 챗봇 안에만 갇혀 있지 않고, 터미널에서 도는
오픈소스 코딩 에이전트에 프로바이더로 연결됩니다. 즉 "어떤 IDE를 쓰느냐"와 "어떤 모델로 코딩하느냐"를
분리할 수 있게 됐습니다.

ThakiCloud 관점에서 이 조합은 두 가지 이유로 눈여겨볼 만합니다. 첫째, 코딩 에이전트가 벤더 종속을
벗어나 모델을 자유롭게 교체할 수 있다는 것은 에이전트 플랫폼 설계의 핵심 전제와 맞닿아 있습니다.
둘째, 2.8조 파라미터 오픈 웨이트 모델은 결국 누군가가 실제 GPU 위에서 서빙해야 하며, 그 서빙 비용과
온프렘 요구가 곧 인프라 사업의 질문으로 돌아옵니다. 이 글에서는 먼저 도구를 직접 설치해 연결 흐름을
확인하고, 그다음 이 두 관점을 정리합니다.

## 이 도구는 무엇인가

OpenCode는 터미널에서 도는 오픈소스 코딩 에이전트입니다. 코드베이스의 파일을 읽고, 구조를 설명하고,
코드를 편집하고, 변경을 리뷰하고, 연결된 LLM 프로바이더를 통해 작업을 실행합니다. 특정 모델에 묶이지
않고 프로바이더를 갈아 끼우는 구조라, 같은 워크플로 위에서 모델만 바꿔 가며 쓸 수 있습니다.

Kimi K3는 그 프로바이더 자리에 들어가는 모델입니다. Moonshot AI 발표 기준 핵심 사양은 다음과
같습니다. 총 2.8조 파라미터의 MoE 구조로, 896개의 전문가(expert) 중 토큰당 16개가 활성화됩니다.
어텐션은 Kimi Delta Attention(KDA)이라는 하이브리드 선형 어텐션 방식을 씁니다. 여기에 잔차 연결을
대체하는 Attention Residuals 기법, 네이티브 비전 이해, 그리고 최대 100만 토큰 컨텍스트를 갖췄습니다.
전체 모델 가중치는 2026년 7월 27일 공개 예정입니다.

두 도구가 연결되는 흐름을 그림으로 보면 다음과 같습니다.

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
<div class="d3-arch" data-arch-root id="0718kimik3opencodecoding-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 340, "height": 854, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 35, "y": 24, "w": 163, "h": 62, "title": ["개발자 터미널", "OpenCode TUI 또는 run"]}, {"id": "B", "x": 111, "y": 164, "w": 163, "h": 62, "title": ["프로바이더 계층", "opencode auth login"]}, {"id": "C", "x": 78, "y": 304, "w": 230, "h": 68, "title": ["모델 선택", "/models 또는 opencode models"]}, {"id": "D", "x": 118, "y": 464, "w": 149, "h": 62, "title": ["Moonshot AI 프로바이더", "Kimi K3"]}, {"id": "E", "x": 94, "y": 604, "w": 198, "h": 78, "title": ["Kimi Delta Attention", "2.8T MoE · 896 전문가 · 토큰당", "16 활성"]}, {"id": "F", "x": 52, "y": 760, "w": 128, "h": 62, "title": ["코드 읽기·편집·리뷰·실행", "최대 1M 컨텍스트"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[150, 86], [193, 125], [193, 125], [193, 164]]}, {"src": "B", "dst": "C", "kind": "data", "line": [193, 226, 193, 304]}, {"src": "C", "dst": "D", "kind": "data", "line": [193, 372, 193, 464]}, {"src": "D", "dst": "E", "kind": "data", "line": [193, 526, 193, 604]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[193, 682], [193, 721], [193, 721], [150, 760]]}, {"src": "F", "dst": "A", "kind": "event", "label": "세션 반복", "curve": [[82, 760], [40, 565], [40, 265], [82, 86]], "off": "50%"}]});
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
      const container = document.getElementById('0718kimik3opencodecoding-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '0718kimik3opencodecoding-1';
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

기존 접근과의 차이는 명확합니다. 벤더가 제공하는 GUI 에이전트를 쓰면 모델과 도구가 한 묶음으로 딸려
옵니다. 반면 OpenCode 같은 오픈소스 에이전트는 도구를 고정한 채 프로바이더만 교체합니다. 어제는
자체 호스팅 모델, 오늘은 Kimi K3, 내일은 또 다른 모델을 같은 명령 인터페이스로 쓸 수 있습니다.

## 설치 및 통합

실제 설치와 연결 흐름을 격리된 샌드박스에서 직접 확인했습니다. 아래 명령과 버전은 재현 과정에서
캡처한 실제 값입니다.

먼저 OpenCode를 설치합니다. npm 전역 설치로 바로 잡혔습니다.

```bash
npm install -g opencode-ai
opencode --version
# 1.18.3
```

설치된 CLI가 제공하는 명령 표면을 확인했습니다. TUI 실행부터 헤드리스 실행, 프로바이더 관리,
모델 조회, MCP 서버 관리까지 코딩 에이전트가 필요로 하는 명령이 갖춰져 있습니다.

```bash
opencode --help
# opencode [project]        start opencode tui              [default]
# opencode run [message..]  run opencode with a message
# opencode providers        manage AI providers and credentials   [aliases: auth]
# opencode models [provider]  list all available models
# opencode mcp              manage MCP (Model Context Protocol) servers
# opencode agent            manage agents
# opencode serve            starts a headless opencode server
```

프로바이더 인증은 `opencode auth` 하위 명령이 담당합니다.

```bash
opencode auth --help
# opencode auth list    list providers and credentials   [aliases: ls]
# opencode auth login   log in to a provider
# opencode auth logout  log out from a configured provider
```

Kimi K3를 붙이는 순서는 다음과 같습니다. Moonshot AI 공식 OpenCode 가이드 기준입니다.

1. Kimi 오픈 플랫폼에서 API 키를 발급받아 안전하게 보관합니다.
2. `opencode auth login`을 실행하고 프로바이더로 **Moonshot AI**를 선택한 뒤 API 키를 입력합니다.
3. OpenCode 안에서 `/models`(또는 셸에서 `opencode models moonshotai`)로 **Kimi K3**를 선택합니다.
4. 낮은 위험의 작업으로 연결을 검증합니다.

```bash
opencode run "이 프로젝트의 폴더 구조를 설명하고 먼저 읽어야 할 파일 세 개를 추천해 줘."
```

한 가지 확인해 둘 사실이 있습니다. 설치 직후 기본 모델 카탈로그에는 Moonshot 프로바이더가 잡혀
있지 않았습니다. 재현 중 `opencode models`를 Moonshot/Kimi로 필터링하면 결과가 비어 있었고, 이는
프로바이더를 `auth login`으로 명시적으로 추가해야 카탈로그에 노출된다는 뜻입니다. 즉 위 2번 단계는
선택이 아니라 필수입니다.

## 실제 실험 결과

이번 재현에서 직접 캡처한 값과, 모델 자체의 공개 지표를 구분해 정리합니다. 도구 설치와 연결 흐름은
직접 확인한 실측값이고, 벤치마크 점수는 Moonshot과 제3자(Artificial Analysis)가 공개한 보고값입니다.

직접 확인한 실측 결과는 다음과 같습니다.

- OpenCode 설치 성공, 버전 1.18.3(npm `opencode-ai`, 종료 코드 0).
- CLI가 프로바이더 인증(`auth`), 모델 조회(`models`), 헤드리스 실행(`run`), MCP 관리(`mcp`),
  에이전트 관리(`agent`)를 모두 제공함을 확인.
- 설치 직후 기본 카탈로그에 Moonshot 프로바이더 미포함 → `auth login`으로 명시 추가 필요.

라이브 Kimi K3 추론까지는 실행하지 않았습니다. Kimi K3 호출에는 잔액이 있는 유료 API 키가 필요하고
(신규 가입 검증으로 받은 바우처는 K3에 사용할 수 없습니다), 이번 재현 환경에는 해당 키가 없었습니다.
그래서 "설치와 연결 흐름은 실측, 실제 코드 생성 품질은 공개 지표 인용"으로 선을 긋습니다. 없는 수치를
지어내지 않습니다.

모델의 공개 벤치마크는 다음과 같습니다. 아래 점수는 Artificial Analysis가 공개한 보고값 기준이며,
가중치가 아직 완전 공개되지 않아 독립 재현으로는 검증되지 않았음을 함께 밝힙니다.

| 벤치마크 | Kimi K3 | 순위 | 상위/비교 모델 |
|---|---|---|---|
| GDPval-AA v2 | 1,687 | 3위 | Fable 5 Max 1,815 · GPT-5.6 Sol Max 1,747.8 · (Opus 4.8 1,600) |
| AA-Briefcase | 1,527 | 2위 | Fable 5 Max 1,587 · GPT-5.6 Sol Max 1,495 |

숫자를 그대로 읽으면, Kimi K3는 최상위 프런티어 모델 바로 아래 구간에 자리합니다. 특히 장기 지식
노동을 측정한다는 AA-Briefcase에서 2위를 기록했다는 점은, 코딩처럼 여러 단계를 오가는 에이전트
작업에서 쓸 만하다는 신호로 해석할 수 있습니다. 다만 이는 보고값이며, 실제 코딩 워크플로에서의
체감은 각자의 코드베이스로 검증하는 편이 정확합니다.

## ThakiCloud 제품 적용 시사점

이 조합은 ThakiCloud의 두 제품 렌즈 모두와 맞닿습니다. 하나는 에이전트 플랫폼 관점, 다른 하나는
인프라 서빙 관점입니다.

**Paxis 렌즈(에이전트·도구·모델 교체).** Paxis는 ThakiCloud의 Agent-Native Cloud 제어 평면으로,
Skills·Tools·Policies·Audit Logs를 일급 리소스로 다룹니다. OpenCode가 보여 주는 "도구는 고정하고
프로바이더만 교체한다"는 구조는 Paxis의 설계 철학과 정확히 겹칩니다. Paxis에서 코딩 에이전트는
960개가 넘는 스킬을 BM25로 선택해 격리된 샌드박스에서 실행하고, 모든 행동을 정책 게이트와 감사
로그로 통과시킵니다. 여기에 Kimi K3 같은 오픈 웨이트 모델을 프로바이더로 붙이면, 에이전트의 두뇌를
비용과 성능에 따라 갈아 끼우면서도 실행 격리와 감사 체계는 그대로 유지할 수 있습니다. 또한 OpenCode가
MCP 서버 관리(`opencode mcp`)를 내장하고 있다는 점은, MCP 커넥터를 일급 리소스로 다루는 Paxis의
접근과 자연스럽게 연결됩니다.

**ai-platform 렌즈(2.8T 모델 서빙).** 오픈 웨이트라는 말은 결국 누군가가 이 모델을 실제 GPU 위에서
서빙해야 한다는 뜻입니다. 2.8조 파라미터 MoE는 토큰당 16개 전문가만 활성화되므로 활성 파라미터는
전체보다 훨씬 작지만, 896개 전문가 전체를 메모리에 올려야 하는 구조라 온프렘 서빙의 문턱은 낮지
않습니다. 여기서 ThakiCloud의 ai-platform이 답하는 질문이 등장합니다. K8s와 Kueue 기반 GPU 스케줄링,
vLLM/SGLang 서빙, 그리고 양자화를 통한 메모리 절감이 결합될 때 이런 대형 오픈 모델을 멀티테넌트
환경에서 경제적으로 돌릴 수 있습니다. 가중치가 7월 27일 공개되면, 자체 호스팅 대비 API 호출의 비용
곡선을 실제로 비교해 볼 수 있습니다. 낮은 서빙 비용은 곧 에이전트 경제성으로 이어지고, 이는 다시
Paxis 위에서 도는 에이전트의 단가를 낮춥니다. 두 렌즈가 한 방향을 가리키는 셈입니다.

## 한계 및 반론

몇 가지 냉정한 반론을 함께 적습니다.

첫째, 벤치마크 점수와 실제 코딩 체감은 다릅니다. AA-Briefcase 2위가 곧 "내 코드베이스에서 최고"를
보장하지 않습니다. 리더보드 상위 모델이 특정 언어나 프레임워크, 사내 컨벤션에서 오히려 약할 수
있으므로, 도입 판단은 자신의 실제 작업으로 검증해야 합니다.

둘째, 이 글의 실측은 도구 설치와 연결 흐름까지입니다. 라이브 Kimi K3 추론은 유료 API 키 제약으로
실행하지 못했습니다. 실제 생성 품질, 지연 시간, 토큰 비용은 각자의 키로 직접 재 봐야 하는 영역으로
남습니다.

셋째, "오픈 웨이트"가 곧 "공짜"나 "쉬운 운영"을 의미하지는 않습니다. 가중치가 공개돼도 2.8T MoE를
안정적으로 서빙하려면 상당한 GPU 자원과 운영 역량이 필요합니다. 자체 호스팅과 API 호출 사이의
손익분기는 사용량과 지연 요구에 따라 갈립니다.

넷째, Kimi K3 API에는 잔액이 필요하며 신규 바우처로는 K3를 쓸 수 없습니다. 무료로 최상위 모델을
무제한 쓴다는 기대는 접어야 합니다. 그럼에도 도구와 모델을 분리해 선택할 수 있다는 구조적 자유는,
특정 벤더에 묶이는 것보다 장기적으로 유리한 위치입니다.

## 출처

- [MarkTechPost, "Moonshot AI Releases Kimi K3: A 2.8 Trillion Parameter Open MoE Model With Kimi Delta Attention and 1M Context" (2026-07-16)](https://www.marktechpost.com/2026/07/16/moonshot-ai-releases-kimi-k3-a-2-8-trillion-parameter-open-moe-model-with-kimi-delta-attention-and-1m-context/)
- [Fortune, "Moonshot's Kimi K3 pushes Chinese AI into Fable-level territory" (2026-07-16)](https://fortune.com/2026/07/16/moonshots-kimi-k3-pushes-chinese-ai-into-fable-level-territory/)
- [Artificial Analysis, "Kimi K3" 모델 페이지 (본문 GDPval-AA v2·AA-Briefcase 벤치마크 수치의 출처)](https://artificialanalysis.ai/models/kimi-k3)
- [Kimi API Platform, "Use Kimi Models in OpenCode"](https://platform.kimi.ai/docs/guide/open-code)
- [OpenCode (sst/opencode), v1.18.3 릴리스](https://github.com/sst/opencode)
- [Simon Willison, "Kimi K3, and what we can still learn from the pelican benchmark" (2026-07-16)](https://simonwillison.net/2026/Jul/16/kimi-k3/)
- VentureBeat, "China's Moonshot AI releases Kimi K3, the largest open-source model ever" (기사 존재는 확인, 이번 세션에서 URL 응답은 미확인)
- OpenCode 1.18.3 (`npm install -g opencode-ai`): 본문 명령과 버전은 직접 재현 캡처값
