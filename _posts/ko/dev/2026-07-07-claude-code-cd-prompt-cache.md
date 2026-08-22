---
title: "Claude Code /cd - 세션을 재시작하지 않고 디렉터리를 옮기며 프롬프트 캐시를 지키는 법"
excerpt: "모노레포에서 라이브러리 디렉터리와 소비 서비스 디렉터리를 오갈 때, 세션을 재시작하면 대화 맥락도 프롬프트 캐시도 함께 날아갑니다. Claude Code v2.1.169에 들어온 /cd 명령은 실행 중인 세션을 다른 디렉터리로 옮기면서 캐시를 그대로 유지합니다. 캐시 읽기(0.1배)와 쓰기(1.25배) 요율 차이를 근거로 왜 이 한 줄이 코딩 에이전트 운영 비용을 크게 바꾸는지 짚고, ThakiCloud의 Paxis 코딩 에이전트와 ai-platform 서빙 비용 관점으로 연결합니다."
seo_title: "Claude Code /cd로 디렉터리 이동하며 프롬프트 캐시 지키기 (2026) - Thaki Cloud"
seo_description: "Claude Code v2.1.169의 /cd 명령은 세션을 재시작하지 않고 작업 디렉터리를 옮기면서 프롬프트 캐시를 유지합니다. 캐시 읽기 0.1배와 쓰기 1.25배 요율을 근거로 비용 모델을 계산하고, CLAUDE.md 재로딩이 시스템 프롬프트를 다시 쓰지 않는 이유, 그리고 Paxis 코딩 에이전트와 ai-platform 멀티테넌트 서빙 비용 관점을 함께 다룹니다."
date: 2026-07-07
last_modified_at: 2026-07-07
tags:
  - claude-code
  - prompt-caching
  - ai-agent
  - developer-tools
  - cost-optimization
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ko/dev/claude-code-cd-prompt-cache/"
reading_time: true
categories:
  - dev
audiobook: /assets/audio/posts/claude-code-cd-prompt-cache/audiobook-ko.mp3
audiobook_note: "AI 로컬 합성 오디오북 (Qwen3-TTS)"
published: false
---

코딩 에이전트를 오래 붙잡고 일하다 보면 디렉터리를 옮겨야 하는 순간이 반드시 옵니다. 공유 라이브러리에서 코어 모듈을 고친 다음, 그 모듈을 쓰는 서비스로 넘어가 통합을 확인해야 하는 모노레포 작업이 대표적입니다. 지금까지는 이럴 때 세션을 닫고 새 디렉터리에서 다시 열거나 `/clear`로 맥락을 비워야 했습니다. 그러면 여태 쌓은 대화 맥락이 사라지는 것은 물론이고, 눈에 잘 보이지 않는 비용 하나가 더 발생합니다. 바로 프롬프트 캐시가 통째로 무효화되어 다음 요청이 캐시 쓰기 요율로 다시 청구되는 것입니다. Claude Code v2.1.169에 조용히 들어온 `/cd` 명령은 이 두 손실을 동시에 막습니다. 이 글은 그 한 줄이 왜 단순한 편의 기능이 아니라 코딩 에이전트 운영 비용의 문제인지, 문서에 공개된 요율을 근거로 짚습니다.

![연속된 데이터 스트림이 두 갈래로 갈라져, 한쪽은 블록을 값비싸게 다시 쌓고 다른 쪽은 격자를 그대로 흘려보내는 추상 개념도]({{ '/assets/images/claude-code-cd-prompt-cache-hero.webp' | relative_url }})

## 개요

`/cd <경로>`는 실행 중인 Claude Code 세션을 다른 작업 디렉터리로 옮깁니다. 세션을 재시작하지 않으므로 대화 기록, 모델 선택, 권한 설정이 모두 새 디렉터리로 그대로 넘어갑니다. 여기까지는 흔한 편의 기능처럼 들립니다. 진짜 핵심은 그다음입니다. `/cd`는 프롬프트 캐시를 깨지 않습니다. 디렉터리를 옮긴 직후에 보내는 메시지가 캐시 쓰기 가격이 아니라 캐시 읽기 가격으로 청구됩니다.

이 차이가 사소하지 않은 이유는 캐시 요율 자체에 있습니다. Anthropic이 공개한 프롬프트 캐싱 요율에서 캐시 읽기는 표준 입력 단가의 약 10퍼센트, 즉 0.1배입니다. 반대로 캐시에 새로 쓰는 것은 기본 입력 단가의 1.25배가 붙습니다. 세션을 재시작하면 시스템 프롬프트, 도구 정의, 그리고 프로젝트의 `CLAUDE.md`가 모두 새 캐시로 다시 쓰여야 합니다. 큰 프로젝트일수록 이 프리픽스는 수만 토큰에 달합니다. `/cd`는 이 프리픽스를 다시 쓰지 않고 그대로 읽어 재사용합니다.

![디렉터리 전환의 숨은 비용: 프리픽스 재기록이라는 1.25배 프리미엄과 대화 맥락 손실]({{ '/assets/images/claude-code-cd-prompt-cache-slide-02.webp' | relative_url }})

ThakiCloud는 멀티테넌트 환경에서 여러 고객의 에이전트와 배치 작업을 같은 인프라 위에서 돌립니다. 이런 환경에서 토큰 경제성은 곧 서비스 원가입니다. 코딩 에이전트가 디렉터리를 옮길 때마다 프리픽스를 다시 캐싱한다면, 그 비용은 세션 수와 전환 횟수에 비례해 누적됩니다. `/cd`처럼 캐시를 보존하는 동작 하나가 대규모 운영에서는 무시할 수 없는 절감으로 이어집니다. 그래서 이 기능은 "편한 단축키"가 아니라 "비용 위생"의 문제로 보는 편이 정확합니다.

## 이 기술은 무엇인가

프롬프트 캐시가 어떻게 작동하는지 먼저 짚어야 `/cd`의 가치가 보입니다. Claude Code는 매 턴마다 시스템 프롬프트, 도구 정의, `CLAUDE.md`를 자동으로 캐싱합니다. 별도 설정이 필요 없습니다. 이 캐시된 프리픽스가 대화 앞부분을 차지하고, 그 뒤에 매번 새로운 메시지가 붙습니다. 캐시가 살아 있으면 이 프리픽스는 읽기 요율로만 청구됩니다. 캐시가 깨지면 프리픽스 전체를 다시 써야 합니다.

세션을 재시작하거나 `/clear`로 맥락을 비우면 캐시가 무효화됩니다. 그런데 디렉터리를 옮기는 작업의 함정은, 새 디렉터리에 다른 `CLAUDE.md`가 있다는 점입니다. 상식적으로는 시스템 프롬프트에 들어가는 `CLAUDE.md`가 바뀌면 캐시가 깨져야 할 것 같습니다. `/cd`의 영리한 부분이 여기입니다. 목적지 디렉터리의 `CLAUDE.md`를 시스템 프롬프트에 다시 써 넣는 대신, 대화의 다음 메시지로 덧붙입니다. 시스템 프롬프트를 다시 쓰지 않으니 캐시된 프리픽스가 그대로 유지되고, 새 `CLAUDE.md`는 그저 뒤에 붙는 사용자 메시지 하나로 처리됩니다. 이것이 캐시를 지키면서도 새 디렉터리의 규칙을 반영하는 방법입니다.

아래 도표는 디렉터리를 옮길 때 두 경로가 캐시에 어떻게 다르게 작동하는지를 보여 줍니다.

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
<div class="d3-arch" data-arch-root id="7claudecodecdpromptcache-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 373, "height": 746, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 117, "y": 24, "w": 120, "h": 78, "title": ["디렉터리 A에서", "세션 진행 중", "(프리픽스 캐시 활성)"]}, {"id": "B", "x": 108, "y": 180, "w": 138, "h": 68, "title": ["디렉터리 B로", "이동 필요"]}, {"id": "C", "x": 199, "y": 348, "w": 142, "h": 62, "title": ["시스템 프롬프트·도구·", "CLAUDE.md 캐시 무효화"]}, {"id": "D", "x": 210, "y": 496, "w": 120, "h": 78, "title": ["프리픽스 전체를", "다시 캐시 쓰기", "(1.25배 요율)"]}, {"id": "E", "x": 210, "y": 660, "w": 120, "h": 46, "title": "대화 맥락 손실"}, {"id": "F", "x": 24, "y": 340, "w": 120, "h": 78, "title": ["시스템 프롬프트 유지", "새 CLAUDE.md는", "메시지로 덧붙임"]}, {"id": "G", "x": 24, "y": 504, "w": 120, "h": 62, "title": ["프리픽스 캐시 읽기", "(0.1배 요율)"]}, {"id": "H", "x": 24, "y": 652, "w": 120, "h": 62, "title": ["대화·모델·권한", "그대로 유지"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [177, 102, 177, 180]}, {"src": "B", "dst": "C", "kind": "data", "label": "\"재시작 또는 /clear\"", "curve": [[217, 248], [270, 294], [270, 294], [270, 348]], "off": "50%"}, {"src": "C", "dst": "D", "kind": "data", "line": [270, 410, 270, 496]}, {"src": "D", "dst": "E", "kind": "data", "line": [270, 574, 270, 660]}, {"src": "B", "dst": "F", "kind": "data", "label": "\"/cd 경로\"", "curve": [[137, 248], [84, 294], [84, 294], [84, 340]], "off": "50%"}, {"src": "F", "dst": "G", "kind": "data", "line": [84, 418, 84, 504]}, {"src": "G", "dst": "H", "kind": "data", "line": [84, 566, 84, 652]}]});
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
      const container = document.getElementById('7claudecodecdpromptcache-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '7claudecodecdpromptcache-1';
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

이 그림의 핵심은 오른쪽 경로가 시스템 프롬프트를 건드리지 않는다는 점입니다. 왼쪽 경로는 프리픽스를 다시 쓰면서 그동안 쌓은 대화까지 함께 버립니다. 같은 목적지에 도착하지만 지불하는 비용이 완전히 다릅니다.

왜 뒤에 붙이면 캐시가 살아남는지는 프롬프트 캐싱이 프리픽스 단위로 동작하기 때문입니다. 캐시는 대화의 앞부분, 즉 접두부가 이전과 동일한 만큼을 재사용합니다. 접두부의 한 글자라도 바뀌면 그 지점부터 뒤는 전부 다시 계산해야 합니다. 그래서 자주 바뀌는 내용을 앞에 두면 캐시 적중률이 떨어지고, 안정적인 내용을 앞에 두고 변하는 내용을 뒤에 붙이면 적중률이 올라갑니다. `/cd`가 새 `CLAUDE.md`를 시스템 프롬프트가 아니라 대화 끝에 메시지로 덧붙이는 것은 정확히 이 원리를 지키는 설계입니다. 캐시된 접두부는 손대지 않고, 변화는 캐시 경계 바깥에서 흡수합니다.

## 설치 및 통합

`/cd`는 별도 설치가 필요 없습니다. Claude Code v2.1.169 이상이면 바로 쓸 수 있습니다. 이 명령은 2026년 6월 8일에 릴리스되었습니다. 사용법은 단순합니다.

![/cd 명령은 v2.1.169에서 도입되었으며, 실행 중인 세션을 닫지 않고 작업 디렉터리만 갱신하면서 캐시를 읽기 가격으로 유지합니다]({{ '/assets/images/claude-code-cd-prompt-cache-slide-03.webp' | relative_url }})

```bash
# 세션 안에서 다른 디렉터리로 이동
/cd ../consuming-service

# 절대 경로도 가능
/cd /Users/me/repo/apps/web

# 홈 기준 경로
/cd ~/repo/packages/core
```

명령을 실행하면 Claude Code는 작업 디렉터리를 갱신하고, 새 위치의 `CLAUDE.md`를 읽어 대화에 덧붙인 뒤, 하던 작업을 이어 갑니다. 대화 기록과 지금까지 내린 결정이 그대로 남아 있으므로, "방금 코어 모듈에서 고친 인터페이스를 이 서비스에서 검증해 줘" 같은 요청이 자연스럽게 이어집니다.

구체적인 예를 들어 보겠습니다. ThakiCloud의 플랫폼 워크스페이스는 Go 백엔드, 프론트엔드, GitOps 배포, 멀티클러스터 메시 등 일곱 개의 제품 리포지터리를 git 서브모듈로 묶어 둡니다. 백엔드 API의 응답 스키마를 바꾼 뒤 그 스키마를 소비하는 프론트엔드에서 화면이 제대로 나오는지 확인하는 작업은 이 구조에서 일상입니다. 예전 방식이라면 백엔드 세션을 닫고 프론트엔드 디렉터리에서 새 세션을 열어야 했고, 그러면 방금 무엇을 왜 바꿨는지를 새 세션에 다시 설명해야 했습니다. `/cd`를 쓰면 흐름이 끊기지 않습니다.

```bash
# 백엔드 서브모듈에서 스키마 수정 작업 진행 중
# ...

# 그 스키마를 소비하는 프론트엔드로 이동 (맥락·캐시 유지)
/cd ../ai-suite/apps/web

# 이어서 바로 물어봄: 방금 바꾼 필드명을 이 화면이 참조하는지 확인
```

이동 직후 프론트엔드 디렉터리의 `CLAUDE.md`가 대화에 덧붙으므로, 그 리포지터리의 규칙(FSD 경계나 TDS 토큰 사용 같은)이 즉시 반영됩니다. 동시에 백엔드에서 쌓은 맥락, 즉 어떤 필드를 왜 바꿨는지가 그대로 살아 있어 곧장 검증으로 넘어갈 수 있습니다.

캐시 경제성을 이해하려면 요율 표를 봐야 합니다. 아래는 Anthropic이 공개한 프롬프트 캐싱 요율을 정리한 것입니다.

| 항목 | 표준 입력 대비 요율 | 설명 |
|---|---|---|
| 캐시 읽기 | 0.1배 | 캐시된 프리픽스 재사용, 90퍼센트 할인 |
| 캐시 쓰기(5분 TTL) | 1.25배 | 새 프리픽스를 캐시에 기록, 첫 읽기가 회수 |
| 캐시 쓰기(1시간 TTL) | 2.0배 | `ENABLE_PROMPT_CACHING_1H=1` 설정 시 |
| 캐시 미사용 입력 | 1.0배 | 기준 단가 |

한 가지 주의할 맥락이 있습니다. Anthropic은 2026년 3월에 기본 캐시 TTL을 60분에서 5분으로 조용히 줄였습니다. 5분 안에 다음 요청이 없으면 캐시가 만료되어 다시 쓰기 비용을 냅니다. 긴 간격으로 작업한다면 1시간 옵션을 켜는 것을 고려할 수 있지만, 쓰기 프리미엄이 2.0배로 올라가므로 트레이드오프를 따져야 합니다. `/cd`는 이 TTL 안에서 세션을 이어 갈 때 캐시를 살려 두는 역할이라, 짧은 TTL 시대에 오히려 더 중요해졌습니다.

## 실제 실험 결과

정직하게 밝히자면, `/cd`는 대화형 슬래시 명령이라 이 글을 작성한 헤드리스 환경에서는 실제 세션을 띄워 상호작용 벤치마크를 돌릴 수 없었습니다. 그래서 측정값을 지어내는 대신, 공개된 요율만으로 계산할 수 있는 비용 모델을 제시합니다. 아래 수치는 측정값이 아니라 문서 기준 요율 계산이며, 그 사실을 분명히 표시합니다.

디렉터리를 옮긴 직후 첫 요청에서 캐시된 프리픽스가 어떻게 청구되는지 두 경로를 비교해 보겠습니다. 재시작이나 `/clear` 경로에서는 프리픽스가 캐시 쓰기(1.25배)로 다시 기록됩니다. `/cd` 경로에서는 같은 프리픽스가 캐시 읽기(0.1배)로 재사용됩니다. 프리픽스 크기가 같다고 놓으면, 전환 직후 프리픽스에 대해 지불하는 비용의 비율은 1.25 나누기 0.1, 즉 12.5배입니다. 다시 말해 재시작 경로는 `/cd` 경로보다 프리픽스 재청구에서 약 12.5배 비쌉니다.

![디렉터리 전환 시 캐시된 프리픽스 비용 비교: 재시작/재캐시 경로는 쓰기 1.25배, /cd 경로는 읽기 0.1배로, 문서 기준 요율상 약 12.5배 차이가 납니다]({{ '/assets/images/claude-code-cd-prompt-cache-results.webp' | relative_url }})

이 비율은 프리픽스의 절대 토큰 수와 무관하게 성립합니다. 다만 절대 절감액은 프리픽스가 클수록 커집니다. 대규모 프로젝트에서 시스템 프롬프트와 도구 정의, 그리고 두툼한 `CLAUDE.md`를 합친 프리픽스가 수만 토큰에 이르는 경우가 흔한데[추정], 이런 세션에서 하루에 디렉터리를 여러 번 오가면 재캐시 비용이 빠르게 쌓입니다. `/cd`는 그 전환마다 붙는 12.5배 프리미엄을 읽기 요율로 눌러 줍니다.

한 가지 더 짚을 점은, `/cd`가 지키는 것이 비용만이 아니라는 사실입니다. 재시작 경로에서 잃는 대화 맥락은 토큰으로 환산하기 어려운 비용입니다. 방금 고친 코드의 의도, 앞서 세운 가설, 이미 배제한 접근을 다시 설명해야 한다면 사람의 시간과 추가 토큰이 모두 듭니다. `/cd`는 이 재설명 비용까지 함께 제거합니다.

## ThakiCloud 제품 적용 시사점

이 기능은 ThakiCloud의 두 제품 관점에서 모두 의미가 있습니다.

![Paxis(에이전트 경제성)와 ai-platform(낮은 서빙 원가)이 캐시 보존 설계를 통해 서로를 보완하는 구조]({{ '/assets/images/claude-code-cd-prompt-cache-slide-07.webp' | relative_url }})

Paxis 관점에서 보면 `/cd`는 코딩 에이전트의 세션 위생 문제를 정확히 건드립니다. Paxis는 ThakiCloud의 Agent-Native Cloud로, 스킬과 도구, 정책, 감사 로그를 일급 리소스로 다루며 격리된 샌드박스에서 에이전트를 실행합니다. 코딩 에이전트가 여러 리포지터리와 서브모듈을 오가며 작업하는 것은 Paxis에서 흔한 시나리오입니다. 이때 전환마다 세션을 재시작해 프리픽스를 다시 캐싱한다면, 큰 스킬 하니스와 정책 컨텍스트를 매번 재청구하게 됩니다. `/cd`처럼 프리픽스를 보존하며 디렉터리 규칙만 메시지로 덧붙이는 방식은, 스킬 선택과 정책 게이트를 유지한 채로 작업 경로만 바꾸는 Paxis의 오케스트레이션 모델과 잘 맞습니다. 시스템 프롬프트를 다시 쓰지 않고 뒤에 컨텍스트를 덧붙인다는 발상 자체가, 상시 로딩되는 규칙 레이어를 캐시 안정성 관점에서 관리하는 원칙과 동일합니다.

ai-platform 관점에서는 캐시 경제성이 곧 멀티테넌트 서빙 원가입니다. ThakiCloud의 ai-platform은 K8s와 Kueue 기반 GPU 스케줄링 위에서 여러 고객의 추론 워크로드를 서빙합니다. 프롬프트 캐싱은 반복되는 프리픽스를 재사용해 입력 비용을 줄이는 핵심 레버인데, `/cd`가 보여 주는 원리, 즉 캐시를 깨지 않도록 컨텍스트를 앞이 아니라 뒤에 추가한다는 설계는 자체 서빙 스택에서도 그대로 적용됩니다. 캐시 무효화 지점을 최소화하도록 프롬프트 구조를 설계하면, 낮은 서빙 비용에서 경쟁력을 얻습니다. 두 렌즈는 서로를 보완합니다. 낮은 서빙 비용(ai-platform)이 에이전트 경제성(Paxis)을 만들고, 캐시를 지키는 에이전트 동작(Paxis)이 다시 인프라 부하를 낮춥니다.

## 한계 및 반론

`/cd`가 만능은 아닙니다.

![세 가지 제약: 5분 TTL, 규칙 불변성(세션 중 CLAUDE.md 편집은 갱신 전까지 미반영), 절감 비율의 한정된 범위]({{ '/assets/images/claude-code-cd-prompt-cache-slide-08.webp' | relative_url }})

먼저 캐시 보존은 5분 TTL 안에서만 의미가 있습니다. 디렉터리를 옮긴 뒤 오래 손을 놓으면 캐시가 만료되어, `/cd`를 썼든 안 썼든 다음 요청은 쓰기 비용을 냅니다. 짧은 TTL을 감안하면 `/cd`의 절감은 연속 작업 흐름에서 가장 크고, 간헐적 작업에서는 효과가 줄어듭니다.

둘째로, `CLAUDE.md`를 시스템 프롬프트가 아니라 메시지로 덧붙이는 방식에는 미묘한 함정이 있습니다. 세션 도중에 원본 프로젝트의 `CLAUDE.md`를 편집해도 그 변경은 캐시를 깨지 않는 대신, `/clear`나 `/compact` 또는 재시작 전까지는 적용되지 않습니다. 즉 규칙을 바꿨는데 세션이 이를 반영하지 않는 상황이 생길 수 있으므로, 규칙 변경 후에는 의도적으로 세션을 갱신해야 합니다.

셋째로, 캐시 절감 비율 12.5배는 어디까지나 전환 직후 프리픽스 재청구에 대한 문서 기준 계산입니다. 실제 세션 전체 비용에서 프리픽스가 차지하는 비중, 대화 길이, 전환 빈도에 따라 체감 절감폭은 달라집니다. 이 글의 비율을 "세션 비용이 12.5배 싸진다"로 확대 해석하면 안 됩니다. 정확히는 "전환 시점에 프리픽스를 다시 캐싱하지 않아도 된다"는 절감입니다.

그럼에도 결론은 분명합니다. 모노레포나 다중 리포지터리 작업에서 디렉터리를 오갈 일이 잦다면, `/cd`는 대화 맥락과 프롬프트 캐시를 동시에 지키는 가장 값싼 방법입니다. 코딩 에이전트를 비용까지 고려해 운영하는 팀이라면, 이 한 줄을 습관으로 만들 이유가 충분합니다.

![/cd는 편의 단축키가 아니라 코딩 에이전트의 대화 맥락과 캐시 경제성을 지키는 비용 위생 도구입니다]({{ '/assets/images/claude-code-cd-prompt-cache-slide-09.webp' | relative_url }})

## 출처

- [Manage sessions - Claude Code Docs](https://code.claude.com/docs/en/sessions)
- [How Claude Code uses prompt caching - Claude Code Docs](https://code.claude.com/docs/en/prompt-caching)
- [Claude Code /cd: Switch Projects Without Losing Cache](https://claudcod.com/blog/claude-code-cd-command/)
- [원 트윗(@delba_oliveira 리트윗)](https://x.com/hjguyhan/status/2074414356058763747)
