---
title: "Kimi Code CLI 뜯어보기: 오픈소스 터미널 에이전트가 ACP로 에디터를 삼키는 법"
excerpt: "문샷AI가 MIT 라이선스로 공개한 오픈소스 코딩 CLI를 공식 문서 기준으로 분석합니다. 서브에이전트와 MCP 편의성은 클로드 코드와 겹치지만, 진짜 차별점은 Agent Client Protocol 네이티브 지원과 모델 개방성입니다."
seo_title: "Kimi Code CLI와 ACP 완전 분석: 오픈소스 에이전트 CLI의 진짜 차별점"
seo_description: "문샷AI Kimi Code CLI의 서브에이전트, MCP, Agent Client Protocol을 공식 문서 기준으로 검증합니다. 클로드 코드 대비 실제 차별점과 온프렘 셀프호스팅 관점을 정리합니다."
date: 2026-07-20
last_modified_at: 2026-07-20
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "robot"
tags:
  - agentops
  - kimi
  - moonshot
  - coding-agent
  - mcp
  - agent-client-protocol
  - paxis
  - thakicloud
categories:
  - agentops
canonical_url: "https://thakicloud.com/tech-blog/ko/agentops/kimi-code-cli-acp-open-source-agent/"
---

터미널에서 코딩 에이전트를 쓰는 개발자, 특히 코드를 외부로 내보낼 수 없는 조직에서 일하는 분들을 위한 글입니다. 결론부터 말하면 **Kimi Code CLI**의 진짜 무기는 세간에 도는 "클로드 코드에 없는 기능"이 아니라, 개방 표준 ACP 네이티브 지원과 온프렘 서빙까지 열어 둔 모델 개방성입니다.

Kimi Code CLI는 문샷AI가 MIT 라이선스로 공개한 오픈소스 터미널 코딩 에이전트입니다. 클로드 코드, 제미나이 CLI, 코덱스 CLI와 같은 계열이며 공식 저장소는 [MoonshotAI/kimi-code](https://github.com/MoonshotAI/kimi-code)입니다. 이전 프로젝트 [MoonshotAI/kimi-cli](https://github.com/MoonshotAI/kimi-cli)에서 진화했고 기존 세션과 설정이 그대로 이어집니다.

이름에 K3가 붙지 않는다는 점부터 짚고 갑니다. 이 도구는 특정 모델에 종속되지 않습니다. 기본값으로 코딩 특화 모델 Kimi K2.7 Code를 붙여 쓰지만 설정에서 K3를 포함한 다른 모델로 자유롭게 전환합니다. K3는 문샷이 2026년 7월 16일 공개한 2조8000억 매개변수급 오픈 MoE 모델로, Kimi Delta Attention과 최대 100만 토큰 컨텍스트를 내세웁니다. CLI가 붙일 수 있는 여러 모델 중 하나일 뿐입니다.

전체 구조를 먼저 그려 두면 나머지가 잘 붙습니다. 핵심은 이 CLI가 한쪽으로는 MCP 클라이언트가 되어 도구와 데이터에 연결되고, 다른 한쪽으로는 ACP 서버가 되어 에디터에 연결되는 이중 역할입니다.

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
<div class="d3-arch" data-arch-root id="odecliacpopensourceagent-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1378, "height": 892, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [{"x": 24, "y": 24, "w": 567, "h": 124, "label": "개발자 에디터 (ACP 클라이언트)", "lx": 36, "ly": 42}, {"x": 591, "y": 380, "w": 373, "h": 310, "label": "Kimi Code CLI (에이전트 코어)", "lx": 603, "ly": 398}, {"x": 786, "y": 24, "w": 560, "h": 124, "label": "MCP 서버 (도구 · 데이터)", "lx": 798, "ly": 42}], "nodes": [{"id": "ZED", "x": 62, "y": 63, "w": 120, "h": 46, "title": "Zed"}, {"id": "JB", "x": 237, "y": 63, "w": 120, "h": 46, "title": "JetBrains 계열"}, {"id": "VSC", "x": 412, "y": 63, "w": 142, "h": 46, "title": "VS Code / Neovim"}, {"id": "ACP", "x": 600, "y": 226, "w": 177, "h": 62, "title": ["Agent Client Protocol", "JSON-RPC over stdio"]}, {"id": "MAIN", "x": 629, "y": 419, "w": 120, "h": 62, "title": ["메인 에이전트", "대화 히스토리 유지"]}, {"id": "SUB", "x": 742, "y": 573, "w": 184, "h": 78, "title": ["서브에이전트", "coder · explore · plan", "각자 격리 컨텍스트"]}, {"id": "MODEL", "x": 625, "y": 782, "w": 163, "h": 78, "title": ["모델 계층", "Kimi K2.7 Code / K3", "또는 OpenAI 호환 엔드포인트"]}, {"id": "T1", "x": 824, "y": 63, "w": 120, "h": 46, "title": "Context7"}, {"id": "T2", "x": 999, "y": 63, "w": 135, "h": 46, "title": "Chrome DevTools"}, {"id": "T3", "x": 1189, "y": 63, "w": 120, "h": 46, "title": "사내 커넥터"}, {"id": "EDITOR", "x": 629, "y": 63, "w": 120, "h": 46, "title": "EDITOR"}, {"id": "MCP", "x": 434, "y": 589, "w": 120, "h": 46, "title": "MCP"}], "edges": [{"src": "EDITOR", "dst": "ACP", "kind": "data", "line": [689, 109, 689, 226]}, {"src": "ACP", "dst": "MAIN", "kind": "data", "label": "kimi acp", "line": [689, 288, 689, 419], "lx": 689, "ly": 330}, {"src": "MAIN", "dst": "SUB", "kind": "data", "curve": [[747, 481], [834, 527], [834, 527], [834, 573]]}, {"src": "MAIN", "dst": "MODEL", "kind": "data", "label": "추론 요청", "curve": [[689, 481], [689, 612], [689, 736], [698, 782]], "off": "50%"}, {"src": "SUB", "dst": "MODEL", "kind": "data", "label": "추론 요청", "curve": [[834, 651], [834, 690], [834, 736], [765, 782]], "off": "50%"}, {"src": "MAIN", "dst": "MCP", "kind": "data", "label": "도구 호출", "curve": [[669, 481], [640, 527], [640, 527], [533, 589]], "off": "50%"}]});
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
      const container = document.getElementById('odecliacpopensourceagent-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'odecliacpopensourceagent-1';
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

## 서브에이전트와 MCP, 편하지만 새롭진 않다

내장 서브에이전트는 세 종류입니다. **coder**는 파일을 읽고 쓰고 명령을 실행하는 범용 엔지니어링 담당, **explore**는 읽기 전용 탐색 담당, **plan**은 셸 없이 구현 계획만 내놓는 담당입니다. 이름보다 중요한 것은 각 서브에이전트가 완전히 독립된 컨텍스트 윈도우를 가진다는 점입니다. 메인의 대화 히스토리는 서브에이전트에 노출되지 않고, 서브에이전트의 중간 추론과 도구 호출 로그도 메인에 섞이지 않으며 최종 결론만 반환됩니다. 긴 세션에서도 메인 컨텍스트가 로그로 부풀지 않고 얇게 유지되는 이유입니다. 백그라운드 실행과 병렬 실행까지 지원해 여러 탐색을 동시에 돌릴 수 있습니다. 자세한 내용은 공식 문서 [Agents and Sub-Agents](https://moonshotai.github.io/kimi-code/en/customization/agents.html)에 있습니다.

MCP 연동은 두 경로로 관리합니다. 하나는 `kimi mcp add` 같은 CLI 서브커맨드이고, 다른 하나는 TUI 안에서 쓰는 대화형 슬래시 명령 `/mcp-config`입니다. 후자 덕분에 JSON 설정 파일을 손으로 편집하지 않고도 서버를 추가하고 인증할 수 있습니다.

```bash
# HTTP 트랜스포트 (OAuth 옵션 지원)
kimi mcp add --transport http context7 https://mcp.context7.com/mcp

# stdio 트랜스포트로 로컬 프로세스 연결
kimi mcp add --transport stdio chrome-devtools -- npx chrome-devtools-mcp@latest
```

여기까지가 널리 홍보되는 부분인데, 냉정하게 보면 서브에이전트와 격리 컨텍스트, MCP 편의성, 이미지 붙여넣기는 모두 클로드 코드도 이미 제공합니다. 차별점이라 부르기 어렵습니다. 관련 문서는 [MCP 설정](https://moonshotai.github.io/kimi-cli/en/customization/mcp.html)을 참고하시기 바랍니다.


![kimi-code-cli-acp-open-source-agent 슬라이드 1](/assets/images/kimi-code-cli-acp-open-source-agent-slide-01.webp)

## Agent Client Protocol, 여기가 진짜다

Agent Client Protocol(ACP)은 Zed 에디터 팀이 만든 개방 표준으로, Apache 라이선스이며 JSON-RPC 2.0을 stdio 위에서 주고받습니다. 에디터가 에이전트를 자식 프로세스로 띄우고 표준 입출력으로 통신하는 방식이라, 전송 메커니즘은 언어 서버 프로토콜(LSP)과 동일합니다.

LSP 비유가 이해를 크게 돕습니다. LSP 이전에는 에디터마다 언어마다 별도 통합을 만들어야 했습니다. LSP는 이 M 곱하기 N 문제를 M 더하기 N으로 바꿨습니다. 에디터 하나가 표준만 구현하면 누가 만든 언어 서버든 그 덕을 봅니다. ACP는 정확히 같은 일을 에이전트에 합니다. 에디터가 ACP를 구현하면 누가 만든 에이전트든 표준 방식으로 꽂힙니다. 이 개념은 [Zed의 ACP 소개](https://zed.dev/acp)와 [마크 누리의 해설 글](https://blog.marcnuri.com/agent-client-protocol-acp-introduction)에서 확인할 수 있습니다.

MCP와 방향이 반대라는 점이 핵심입니다. MCP는 에이전트에서 도구로 향하고 이때 에이전트가 클라이언트입니다. ACP는 에디터에서 에이전트로 향하고 이때 에이전트가 서버, 에디터가 클라이언트입니다. 같은 에이전트가 한쪽으로는 MCP 클라이언트, 다른 쪽으로는 ACP 서버를 동시에 맡습니다. Kimi Code CLI는 `kimi acp` 서브커맨드로 이 프로토콜을 별도 설치 없이 네이티브로 지원합니다. Zed는 네이티브로, JetBrains는 플러그인으로 연결되어, 개발자는 익숙한 에디터를 떠나지 않고 Kimi 세션을 몰 수 있습니다.

입력 방식에도 오해가 하나 있습니다. 문샷이 정면에 내세우는 것은 정적 스크린샷이 아니라 **화면 녹화 영상 입력**입니다. 데모 클립을 채팅에 떨어뜨리면 에이전트가 말로 설명하기 어려운 동작을 직접 보고 이해합니다. 기본 모델 K2.7 Code가 비전 인코더 MoonViT를 갖춘 네이티브 멀티모달이라 텍스트, 이미지, 영상을 모두 받습니다. 물론 이미지 붙여넣기도 되지만 진짜 홍보 포인트는 영상입니다.


![kimi-code-cli-acp-open-source-agent 슬라이드 2](/assets/images/kimi-code-cli-acp-open-source-agent-slide-02.webp)

## 설치와 모델 개방성

설치는 간결합니다. 아래는 [공식 시작 가이드](https://moonshotai.github.io/kimi-cli/en/guides/getting-started.html) 기준입니다.

```bash
# 1) 설치 스크립트 실행 (uv를 함께 설치)
curl -LsSf https://code.kimi.com/install.sh | bash

# 2) 프로젝트 디렉터리에서 실행
kimi

# 3) 인증 설정
/login
```

macOS는 `brew install kimi-code`, 윈도우는 파워셸 스크립트도 제공합니다. 소스 개발에는 Node 24.15 이상과 pnpm이 필요합니다. 더 중요한 것은 프로바이더 개방성입니다. `~/.kimi-code/config.toml`에서 OpenAI 호환 엔드포인트, Anthropic API 키, 구글 GenAI나 Vertex AI까지 다중 프로바이더로 등록할 수 있어 특정 모델에 락인되지 않습니다. 문서는 [Providers and models](https://moonshotai.github.io/kimi-cli/en/configuration/providers.html)에 있습니다.


![kimi-code-cli-acp-open-source-agent 슬라이드 3](/assets/images/kimi-code-cli-acp-open-source-agent-slide-03.webp)

## 클로드 코드에는 없는 기능인가
![kimi-code-cli-acp-open-source-agent 슬라이드 4](/assets/images/kimi-code-cli-acp-open-source-agent-slide-04.webp)


가장 널리 퍼진 "클로드 코드에 없는 기능"이라는 프레이밍은 대부분 과장입니다. 진짜 차이는 두 곳뿐입니다. 첫째, ACP를 CLI에 1차 기능으로 내장한 점입니다. 클로드 코드는 Zed가 만든 별도 어댑터를 거쳐 베타로 연결되니, 전자는 켜면 바로 되고 후자는 브릿지를 하나 더 얹어야 합니다([Zed의 베타 글](https://zed.dev/blog/claude-code-via-acp) 참고). 둘째, 모델 개방성입니다. Kimi는 오픈웨이트 K 시리즈에 멀티 프로바이더 전환까지 열려 있어 온프렘 서빙이 가능하지만, 클로드 코드는 CLI가 열려 있어도 모델이 API 전용입니다.

이 개방성은 셀프호스팅 관점에서 의미가 큽니다. 오픈웨이트 K 시리즈를 사내 GPU 클러스터에 올리고 CLI를 내부 엔드포인트로 라우팅하면, 외부 API 의존이나 데이터 반출 없이 사내 코딩 에이전트를 구축할 수 있습니다. 코드가 밖으로 나가면 안 되는 금융이나 공공 영역의 온프렘 보안 요건과 정합합니다. 다만 개방성이 곧 손쉬운 셀프호스팅을 뜻하지는 않습니다. 2조8000억 매개변수급 모델을 실제로 서빙하려면 상당한 GPU 자원이 필요하고, 작은 팀에는 API 경로가 여전히 현실적입니다. 도구 생태계의 성숙도와 안정성도 클로드 코드나 코덱스 CLI가 앞설 수 있습니다. 오픈소스라는 사실이 곧 프로덕션 준비 완료는 아닙니다.

그럼에도 개방 표준 위에서 에이전트와 에디터가 느슨하게 결합되는 방향은 분명한 흐름입니다. 특정 벤더 CLI에 종속되지 않고 모델과 에디터를 각각 갈아 끼울 수 있는 세계가 개발자에게 더 유리하며, Kimi Code CLI는 그 세계를 앞당기는 조각 중 하나입니다.


## 출처

- [MoonshotAI/kimi-code (공식 저장소)](https://github.com/MoonshotAI/kimi-code)
- [MoonshotAI/kimi-cli (이전 저장소)](https://github.com/MoonshotAI/kimi-cli)
- [Kimi Code CLI 시작 가이드](https://moonshotai.github.io/kimi-cli/en/guides/getting-started.html)
- [Agents and Sub-Agents 문서](https://moonshotai.github.io/kimi-code/en/customization/agents.html)
- [MCP 설정 문서](https://moonshotai.github.io/kimi-cli/en/customization/mcp.html)
- [Zed - Agent Client Protocol](https://zed.dev/acp)
- [ACP: The LSP for AI Coding Agents](https://blog.marcnuri.com/agent-client-protocol-acp-introduction)
- [Zed - Claude Code via ACP (베타)](https://zed.dev/blog/claude-code-via-acp)
- [MarkTechPost - Kimi K3 공개](https://www.marktechpost.com/2026/07/16/moonshot-ai-releases-kimi-k3-a-2-8-trillion-parameter-open-moe-model-with-kimi-delta-attention-and-1m-context/)
