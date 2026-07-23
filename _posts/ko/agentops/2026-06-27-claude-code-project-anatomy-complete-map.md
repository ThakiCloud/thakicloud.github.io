---
title: "Claude Code 프로젝트 구조의 완전한 지도를 우리 레포에 비춰봤습니다"
excerpt: "CLAUDE.md, rules, skills, agents, hooks, MCP까지. Claude Code 프로젝트의 모든 구성요소가 각각 어떤 역할 경계를 갖는지 정리한 '완전한 지도'를 읽고, ThakiCloud의 실제 레포(규칙 40개, 스킬 1655개, 에이전트 54개)를 그 지도에 직접 비춰 무엇이 맞고 무엇이 빠졌는지 실측했습니다. 새 지식을 어디에 둘지 결정하는 배치 트리와 K8s AI/ML SaaS 플랫폼 운영 관점을 함께 정리합니다."
seo_title: "Claude Code 프로젝트 구조 완전 지도 실측 - Thaki Cloud"
seo_description: "Claude Code 프로젝트의 CLAUDE.md, .claude/rules, skills, agents, hooks, MCP 구성요소별 역할 경계와 배치 결정 트리를 정리하고, ThakiCloud 실제 레포를 그 지도에 비춰 규칙 40개, 스킬 1655개, 에이전트 54개를 실측했습니다. K8s AI/ML SaaS 플랫폼 관점의 컨텍스트 위생 전략까지 다룹니다."
date: 2026-06-27
last_modified_at: 2026-06-27
tags:
  - ai-coding
  - claude-code
  - project-structure
  - context-engineering
  - agent-skills
  - platform-engineering
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "sitemap"
canonical_url: "https://thakicloud.com/tech-blog/ko/agentops/claude-code-project-anatomy-complete-map/"
categories:
  - agentops
published: false
audiobook: /assets/audio/posts/claude-code-project-anatomy-complete-map/audiobook-ko.mp3
audiobook_note: "AI 로컬 합성 오디오북 (Qwen3-TTS)"
---

![여러 갈래의 빛줄기가 하나의 중심 노드로 수렴했다가 다시 계층적으로 갈라지는 추상 구조]({{ '/assets/images/claude-code-project-anatomy-complete-map-hero.webp' | relative_url }})
*하나의 프로젝트 브레인에서 규칙, 스킬, 에이전트, 메모리로 갈라지는 Claude Code 프로젝트 구조를 추상화한 이미지.*

## 개요

Claude Code로 일을 하다 보면 `.claude` 폴더가 어느 순간 잡동사니가 됩니다. 규칙을 넣어야 할 내용이 `CLAUDE.md`로 가고, 가끔만 필요한 전문 지식이 항상 로드되는 규칙으로 박히며, 개인 환경 경로가 팀 공유 파일에 섞입니다. 각 구성요소가 "무엇을 담아야 하는가"의 경계가 흐려지면, 매 세션마다 쓰지도 않는 컨텍스트를 토큰으로 지불하게 됩니다.

2026년 6월, Prakash Bhandari가 정리한 "Claude Code Project Structure: The Complete Map"라는 글이 개발자 커뮤니티에서 화제가 됐습니다. `.claude` 폴더가 통제하는 다섯 개의 하위 시스템, 즉 지시(CLAUDE.md와 rules), 워크플로(skills와 commands), 전문가(agents), 권한(settings.json), 기억(memory)을 한 장의 지도로 그린 글입니다. ThakiCloud는 이미 이 구조 위에서 수백 개의 스킬과 수십 개의 에이전트를 운용하고 있어서, 글을 읽는 데 그치지 않고 우리 레포를 그 지도에 직접 비춰봤습니다.

이 글은 그 비교 실측의 기록입니다. 각 구성요소의 역할 경계를 정리하고, 우리 레포(`ai-platform-strategy`)의 실제 구성요소 수를 측정해 지도와 대조한 뒤, 쿠버네티스 기반 AI/ML SaaS 플랫폼을 운영하는 관점에서 이 구조가 왜 단순한 정리정돈 이상의 의미를 갖는지 정리했습니다.

## Claude Code 프로젝트 구조란 무엇인가

핵심 발상은 단순합니다. Claude Code는 두 곳에서 설정을 읽습니다. 프로젝트 디렉터리의 `.claude`와 홈 디렉터리의 `~/.claude`입니다. 프로젝트 파일은 git에 커밋해 팀과 공유하고, 홈 디렉터리 파일은 모든 프로젝트에 적용되는 개인 설정입니다. 이 두 갈래를 기준으로 모든 구성요소가 자리를 잡습니다.

지도의 본질은 "각 구성요소가 언제 컨텍스트에 로드되는가"입니다. 어떤 것은 매 세션 자동으로 들어오고, 어떤 것은 요청이 트리거할 때만 들어옵니다. 이 로드 타이밍의 차이가 곧 토큰 비용의 차이이고, 그래서 무엇을 어디에 두느냐가 단순한 취향이 아니라 운영 비용 문제가 됩니다.

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
<div class="d3-arch" data-arch-root id="rojectanatomycompletemap-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 588, "height": 856, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "ROOT", "x": 24, "y": 555, "w": 120, "h": 46, "title": "프로젝트 루트"}, {"id": "BRAIN", "x": 230, "y": 746, "w": 120, "h": 78, "title": ["CLAUDE.md", "프로젝트 브레인", "(매 세션 자동 로드)"]}, {"id": "LOCAL", "x": 222, "y": 613, "w": 135, "h": 78, "title": ["CLAUDE.local.md", "개인 오버라이드", "(gitignore)"]}, {"id": "IGNORE", "x": 229, "y": 496, "w": 121, "h": 62, "title": [".claudeignore", "컨텍스트 경계"]}, {"id": "MCP", "x": 230, "y": 379, "w": 120, "h": 62, "title": [".mcp.json", "외부 도구 연결"]}, {"id": "DOTC", "x": 230, "y": 278, "w": 120, "h": 46, "title": ".claude/"}, {"id": "SET", "x": 435, "y": 641, "w": 121, "h": 62, "title": ["settings.json", "권한·훅·환경변수"]}, {"id": "RULES", "x": 436, "y": 508, "w": 120, "h": 78, "title": ["rules/", "상시 규칙", "(매 턴 로드)"]}, {"id": "SKILLS", "x": 436, "y": 375, "w": 120, "h": 78, "title": ["skills/", "온디맨드 전문지식", "(요청 시 로드)"]}, {"id": "AGENTS", "x": 436, "y": 258, "w": 120, "h": 62, "title": ["agents/", "서브에이전트 정의"]}, {"id": "MEM", "x": 435, "y": 141, "w": 121, "h": 62, "title": ["agent-memory/", "에이전트가 학습한 지식"]}, {"id": "WT", "x": 436, "y": 24, "w": 120, "h": 62, "title": ["worktrees/", "병렬 격리"]}], "edges": [{"src": "ROOT", "dst": "BRAIN", "kind": "data", "curve": [[95, 601], [183, 785], [183, 785], [230, 785]]}, {"src": "ROOT", "dst": "LOCAL", "kind": "data", "curve": [[115, 601], [183, 652], [183, 652], [222, 652]]}, {"src": "ROOT", "dst": "IGNORE", "kind": "data", "curve": [[129, 555], [183, 527], [183, 527], [229, 527]]}, {"src": "ROOT", "dst": "MCP", "kind": "data", "curve": [[98, 555], [183, 410], [183, 410], [230, 410]]}, {"src": "ROOT", "dst": "DOTC", "kind": "data", "curve": [[92, 555], [183, 301], [183, 301], [230, 301]]}, {"src": "DOTC", "dst": "SET", "kind": "data", "curve": [[296, 324], [396, 672], [396, 672], [435, 672]]}, {"src": "DOTC", "dst": "RULES", "kind": "data", "curve": [[299, 324], [396, 547], [396, 547], [436, 547]]}, {"src": "DOTC", "dst": "SKILLS", "kind": "data", "curve": [[311, 324], [396, 414], [396, 414], [436, 414]]}, {"src": "DOTC", "dst": "AGENTS", "kind": "data", "line": [350, 294, 436, 289]}, {"src": "DOTC", "dst": "MEM", "kind": "data", "curve": [[308, 278], [396, 172], [396, 172], [435, 172]]}, {"src": "DOTC", "dst": "WT", "kind": "data", "curve": [[299, 278], [396, 55], [396, 55], [436, 55]]}]});
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
      const container = document.getElementById('rojectanatomycompletemap-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'rojectanatomycompletemap-1';
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
*Claude Code 프로젝트의 구성요소를 로드 타이밍 기준으로 정리한 구조도. 클릭하면 확대됩니다.*

## 구성요소별 역할 경계

지도가 진짜 가치를 갖는 지점은 "무엇을 어디에 담는가"의 경계입니다. 글이 정리한 각 구성요소의 책임을 우리가 실제로 운용하는 방식과 함께 정리하면 다음과 같습니다.

**CLAUDE.md는 프로젝트 브레인입니다.** 매 세션 자동으로 로드되며 팀 전체가 공유하는 표준 브리프입니다. 신규 계약자에게 첫날 건네는 안내서라고 생각하면 정확합니다. 무엇을 만들고 있는가, 어떤 스택 위에서 도는가, 어떤 컨벤션을 따르는가, 워크플로 규칙은 무엇인가. 이 네 가지 질문에만 답하는 것이 원칙입니다. 모든 줄이 임대료를 낸다는 점이 중요합니다. 뚱뚱한 `CLAUDE.md`는 곧 컨텍스트 낭비입니다.

**CLAUDE.local.md는 개인 오버라이드입니다.** 같은 포맷이지만 git에 절대 들어가지 않습니다. 로컬 환경 경로, 디버깅 단축키, 개인 선호, 내 머신의 특이사항이 여기 들어갑니다. 팀원끼리 달라도 되고, 공유 `CLAUDE.md`를 깔끔하게 유지하는 안전판 역할을 합니다.

**.claudeignore는 컨텍스트 경계입니다.** `.gitignore`와 같은 문법으로 Claude의 읽기 범위를 제한합니다. 이것이 없으면 `node_modules`, 생성된 마이그레이션, 벤더 의존성, 대용량 픽스처가 컨텍스트를 소진합니다. 대형 모노레포에서는 사실상 필수입니다.

**rules는 상시 규칙입니다.** 매 턴 자동으로 로드되므로 모든 작업에 적용되는 불변 규칙만 들어가야 합니다. 200줄짜리 아키텍처 문서를 규칙 파일에 넣으면, 그 내용이 무관한 세션에서도 매번 컨텍스트를 먹습니다. 그래서 문서는 스킬이 명시적으로 읽을 때까지 잠들어 있어야 합니다.

**skills는 온디맨드 전문지식입니다.** 요청이 트리거할 때만 로드됩니다. 항상 필요하지는 않은 전문 워크플로, 도메인별 파이프라인, 반복 작업 레시피가 여기 들어갑니다. "때때로만 필요한 것"이라는 기준이 `CLAUDE.md`와 skills를 가르는 선입니다.

**agents는 서브에이전트 정의입니다.** 독립적인 역할, 도구 조합, 모델 티어를 가진 전문가로, 필요할 때 소환됩니다. 탐색에는 저렴한 모델을, 구현에는 균형 잡힌 모델을, 아키텍처 결정에는 가장 비싼 모델을 배정하는 식으로 작업 성격에 따라 모델을 라우팅합니다.

**agent-memory는 에이전트가 학습한 지식입니다.** `CLAUDE.md`와의 핵심 차이가 여기 있습니다. `CLAUDE.md`는 사람이 알려준 것이고, agent-memory는 에이전트가 경험으로 배운 것입니다. 장기 실행 에이전트가 반복 패턴, 버그, 문서화되지 않은 컨벤션을 누적합니다.

## 새 지식은 어디에 두는가

지도를 외워도 막상 새 규칙이나 워크플로를 추가할 때 어디에 둘지 헷갈립니다. 글이 제시한 배치 결정 트리는 이 판단을 단순화합니다.

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
<div class="d3-arch" data-arch-root id="rojectanatomycompletemap-2"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 778, "height": 1042, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "START", "x": 505, "y": 24, "w": 135, "h": 46, "title": "새 지식·규칙·워크플로 추가"}, {"id": "Q1", "x": 503, "y": 148, "w": 138, "h": 68, "title": ["항상 적용 +", "전체 팀 공유?"]}, {"id": "CMD", "x": 597, "y": 311, "w": 149, "h": 62, "title": ["CLAUDE.md (짧게)", "또는 .claude/rules/"]}, {"id": "Q2", "x": 404, "y": 308, "w": 138, "h": 68, "title": ["가끔만 필요한", "전문 워크플로?"]}, {"id": "SK", "x": 501, "y": 479, "w": 135, "h": 46, "title": ".claude/skills/"}, {"id": "Q3", "x": 308, "y": 468, "w": 138, "h": 68, "title": ["독립 역할·", "도구 조합?"]}, {"id": "AG", "x": 406, "y": 639, "w": 135, "h": 46, "title": ".claude/agents/"}, {"id": "Q4", "x": 213, "y": 628, "w": 138, "h": 68, "title": ["개인 환경", "특이사항?"]}, {"id": "LO", "x": 310, "y": 791, "w": 135, "h": 62, "title": ["CLAUDE.local.md", "(gitignore)"]}, {"id": "Q5", "x": 117, "y": 788, "w": 138, "h": 68, "title": ["에이전트가", "경험으로 배운 것?"]}, {"id": "ME", "x": 199, "y": 956, "w": 177, "h": 46, "title": ".claude/agent-memory/"}, {"id": "PL", "x": 24, "y": 948, "w": 120, "h": 62, "title": ["plugins/", "(여러 프로젝트 배포)"]}], "edges": [{"src": "START", "dst": "Q1", "kind": "data", "line": [572, 70, 572, 148]}, {"src": "Q1", "dst": "CMD", "kind": "data", "label": "예", "curve": [[614, 216], [672, 262], [672, 262], [672, 311]], "off": "50%"}, {"src": "Q1", "dst": "Q2", "kind": "data", "label": "아니오", "curve": [[530, 216], [473, 262], [473, 262], [473, 308]], "off": "50%"}, {"src": "Q2", "dst": "SK", "kind": "data", "label": "예", "curve": [[514, 376], [569, 422], [569, 422], [569, 479]], "off": "50%"}, {"src": "Q2", "dst": "Q3", "kind": "data", "label": "아니오", "curve": [[432, 376], [377, 422], [377, 422], [377, 468]], "off": "50%"}, {"src": "Q3", "dst": "AG", "kind": "data", "label": "예", "curve": [[418, 536], [473, 582], [473, 582], [473, 639]], "off": "50%"}, {"src": "Q3", "dst": "Q4", "kind": "data", "label": "아니오", "curve": [[337, 536], [282, 582], [282, 582], [282, 628]], "off": "50%"}, {"src": "Q4", "dst": "LO", "kind": "data", "label": "예", "curve": [[322, 696], [377, 742], [377, 742], [377, 791]], "off": "50%"}, {"src": "Q4", "dst": "Q5", "kind": "data", "label": "아니오", "curve": [[241, 696], [186, 742], [186, 742], [186, 788]], "off": "50%"}, {"src": "Q5", "dst": "ME", "kind": "data", "label": "예", "curve": [[229, 856], [288, 902], [288, 902], [288, 956]], "off": "50%"}, {"src": "Q5", "dst": "PL", "kind": "data", "label": "아니오", "curve": [[143, 856], [84, 902], [84, 902], [84, 948]], "off": "50%"}]});
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
      const container = document.getElementById('rojectanatomycompletemap-2')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'rojectanatomycompletemap-2';
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
*새 지식을 어디에 배치할지 결정하는 트리. 항상 필요한지, 가끔 필요한지, 누가 만든 지식인지를 순서대로 묻습니다.*

가장 흔한 실수도 명확합니다. "가끔만 필요한" 지식을 `CLAUDE.md`에 다 때려넣으면 매 세션 토큰을 낭비합니다. `.claudeignore`가 없는 모노레포는 컨텍스트가 소진됩니다. `CLAUDE.local.md`를 git에 커밋하면 개인 정보와 경로가 노출됩니다. MCP 서버를 10개 이상 상시 활성화하면 사용하지 않아도 매번 약 1만 토큰을 낭비합니다.

## ThakiCloud 레포를 이 지도에 비춰보기

지도를 읽었으니 우리 레포를 거기에 비춰봤습니다. `ai-platform-strategy` 레포의 `.claude` 디렉터리를 실제로 측정한 결과는 다음과 같습니다.

| 구성요소 | 실측 | 로드 타이밍 |
|---|---|---|
| CLAUDE.md | 94줄 | 매 세션 자동 |
| .claude/rules | 40개 파일 | 매 턴 자동 |
| .claude/skills | 1655개 디렉터리 | 온디맨드 |
| .claude/agents | 54개 정의 | 소환 시 |
| .claude/hooks | 15개 | 이벤트 발생 시 |
| .claudeignore | 존재 (442바이트) | 상시 경계 |
| .mcp.json | 존재 (166바이트) | 서버 연결 시 |
| .claude/settings.json | 존재 (5KB) | 매 세션 |

![ThakiCloud 레포의 .claude 구성요소를 로드 타이밍별로 집계한 막대 그래프]({{ '/assets/images/claude-code-project-anatomy-complete-map-results.webp' | relative_url }})
*규칙 40개와 CLAUDE.md 94줄은 매 턴 들어오는 상시 비용이고, 스킬 1655개와 에이전트 54개는 필요할 때만 들어오는 온디맨드 자산입니다.*

이 숫자가 말해주는 것이 지도의 핵심을 그대로 증명합니다. 스킬 1655개를 전부 `CLAUDE.md`나 규칙에 넣었다면 매 세션이 즉시 컨텍스트 한계를 넘었을 것입니다. 실제로 이 1655개는 온디맨드로만 로드되고, 어떤 스킬을 띄울지는 별도의 라우터가 매 턴 후보를 좁혀 결정합니다. 반대로 상시 비용 영역인 규칙은 40개로 의도적으로 억제하고 있습니다. 규칙 파일당 2KB 이하를 목표로 하고, 그 이상이 되면 스킬로 강등하는 위생 규칙을 둔 결과입니다.

흥미로운 지점은 우리가 이 글의 출처를 읽고 곧바로 `claude-code-project-anatomy.md`라는 규칙 파일로 증류해 레포에 넣었다는 사실입니다. 즉 "프로젝트 구조 지도"라는 지식 자체가 배치 결정 트리를 한 번 통과해, 매 턴 참조되는 상시 규칙으로 자리 잡았습니다. 지도가 스스로를 지도 위에 배치한 셈입니다.

## ThakiCloud 제품 적용 시사점

Claude Code의 SKILL.md 레지스트리와 서브에이전트, rules 구조는 ThakiCloud가 개발 중인 Paxis의 핵심 설계 원칙과 직접 대응합니다. Paxis는 ThakiCloud의 Agent-Native Cloud로, 960개가 넘는 스킬을 BM25 기반 라우터로 선별한 뒤 격리된 샌드박스에서 실행하는 Skill Harness를 중심으로 구동됩니다. 이 글에서 정리한 "상시 로드 규칙은 최소로, 전문 워크플로는 온디맨드 스킬로"라는 배치 원칙은 Paxis가 스킬을 일급 리소스로 다루는 방식과 정확히 일치합니다. 얇은 harness 위에 두터운 스킬을 쌓는다는 thin harness, fat skills 원칙이 Paxis 에이전트 레지스트리의 설계 기반이 됩니다.

Paxis는 Claude Code의 이 구조를 단일 개발자 환경을 넘어 프로덕션 런타임으로 일반화한 제품입니다. 스킬과 도구, 정책과 감사 로그를 일급 리소스로 관리하고, DAG 멀티에이전트와 NL Cron, MCP 커넥터를 통해 에이전트 제어 평면을 실현합니다. 자가진화 스킬과 정책 게이트 기능은 Claude Code의 agent-memory가 학습한 지식을 관리자가 검토 및 승인하는 채널로 분리하는 아이디어를 그대로 제품 수준의 거버넌스로 끌어올린 것입니다. 컨텍스트 경계와 온디맨드 라우팅이라는 이 글의 교훈이 Paxis 설계 원칙의 실무 근거로 기능합니다.

이 Skill Harness가 실제로 구동될 LLM 엔드포인트는 ai-platform이 공급합니다. ai-platform은 vLLM 기반 멀티테넌트 모델 서빙과 Kueue GPU 스케줄링을 Kubernetes 위에서 운용하는 ThakiCloud의 AI/ML 인프라 계층으로, Paxis의 에이전트 추론 요청을 받아 처리하는 실행 기반이 됩니다.

## 한계 및 반론

이 지도가 만능은 아닙니다. 몇 가지 한계를 정직하게 짚습니다.

첫째, 구성요소 경계는 권고이지 강제가 아닙니다. Claude Code 자체가 "이 내용은 규칙이 아니라 스킬로 가야 한다"고 막아주지 않습니다. 경계를 지키는 것은 결국 팀의 규율이고, 우리처럼 토큰 위생 규칙과 라우터 게이트를 코드로 둬야 실제로 강제됩니다. 지도만 외운다고 자동으로 깔끔해지지 않습니다.

둘째, 스킬 1655개라는 숫자는 자랑이 아니라 양날의 검입니다. 후보가 많을수록 라우터가 잘못된 스킬을 띄울 노이즈 위험이 커집니다. 온디맨드라서 상시 토큰은 안 먹지만, 검색 정확도라는 다른 비용이 발생합니다. "온디맨드면 공짜"라는 단순한 결론은 위험합니다.

셋째, 이 구조는 Claude Code에 특화돼 있습니다. 다른 에이전트 실행 환경으로 옮기면 디렉터리 규약과 로드 메커니즘이 달라집니다. 그래서 지식 자체는 가능한 한 실행 환경 중립적으로 기술하고, 환경별 배선은 얇게 유지하는 편이 장기적으로 안전합니다.

마지막으로, 출처 글의 일부 수치(예: MCP 서버당 약 1천 토큰)는 환경과 버전에 따라 달라질 수 있는 근사치입니다. 절대값으로 받기보다 "상시 로드되는 것은 모두 비용이다"라는 방향성으로 읽는 것이 맞습니다.

## 출처

- [Claude Code Project Structure Explained: The Complete 2026 Guide](https://www.prakashbhandari.com.np/posts/claude-code-project-structure-2026/) (Prakash Bhandari)
- [Explore the .claude directory (Claude Code 공식 문서)](https://code.claude.com/docs/en/claude-directory)
- 실측 대상: ThakiCloud `ai-platform-strategy` 레포 `.claude` 디렉터리 (2026-06-27 측정)
