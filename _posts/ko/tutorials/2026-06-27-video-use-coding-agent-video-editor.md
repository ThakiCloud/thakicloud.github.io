---
title: "코딩 에이전트로 영상을 편집합니다: video-use 스킬을 뜯어봤습니다"
excerpt: "midudev이 공유해 화제가 된 browser-use의 video-use는 폴더에 원본 영상을 넣고 한 문장을 입력하면 컷 편집, 필러 제거, 자막, 색보정, 애니메이션, 렌더링까지 코딩 에이전트가 자동으로 끝내는 무료 오픈소스 스킬입니다. 컷마다 병렬 서브에이전트를 띄우는 이 구조를 분석하고, ThakiCloud의 Agent-Native Cloud인 Paxis의 Skill Harness 관점에서 무엇을 시사하는지 정리했습니다."
seo_title: "video-use: 코딩 에이전트 영상 편집 스킬 분석 - Thaki Cloud"
seo_description: "browser-use의 오픈소스 video-use 스킬은 원본 영상 폴더와 한 문장만으로 컷 편집, 필러 제거, 자막, 색보정, 애니메이션, 렌더링을 자동화합니다. 병렬 서브에이전트 구조와 HyperFrames/Remotion/Manim/PIL 애니메이션 엔진을 분석하고, ThakiCloud Paxis의 Skill Harness 관점 시사점을 정리합니다."
date: 2026-06-27
last_modified_at: 2026-06-27
tags:
  - ai-coding
  - claude-code
  - agent-skills
  - video-editing
  - browser-use
  - agent-orchestration
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "film"
canonical_url: "https://thakicloud.com/tech-blog/ko/technique/video-use-coding-agent-video-editor/"
categories:
  - tutorials
---

## 개요

영상 편집은 오랫동안 사람이 타임라인 위에서 클립을 자르고 붙이는 수작업의 영역이었습니다. 컷 편집, 군더더기 발화 제거, 자막 삽입, 색보정, 모션 그래픽까지 한 편의 영상을 마무리하려면 전용 도구와 숙련된 손이 필요했습니다. 그런데 2026년 6월, 스페인의 개발자 인플루언서 midudev이 한 문장으로 정리한 트윗이 개발자 사이에서 빠르게 퍼졌습니다. "Claude Code가 이제 영상도 편집합니다. 이 스킬은 100% 무료에 오픈소스입니다."

화제의 주인공은 browser-use 팀이 공개한 `video-use`입니다. 브라우저를 코딩 에이전트로 조작하는 browser-use로 알려진 그 팀이, 이번에는 영상 편집을 코딩 에이전트에게 통째로 위임하는 스킬을 내놓았습니다. 사용법은 단순합니다. 원본 영상 파일을 폴더에 넣고, 어떤 영상을 원하는지 한 문장으로 적으면, 나머지는 에이전트가 알아서 합니다.

ThakiCloud는 에이전트가 격리된 환경에서 스킬을 골라 실행하는 구조를 Agent-Native Cloud로 제품화하고 있습니다. 그래서 video-use를 단순한 편집 도구로 보지 않고, "코딩 에이전트가 비개발 작업을 어떻게 분해하고 병렬화하는가"의 사례로 읽었습니다. 이 글은 video-use가 실제로 무엇을 하는지, 내부 구조가 어떻게 생겼는지, 그리고 그 설계가 우리 플랫폼 관점에서 무엇을 시사하는지 정리한 기록입니다.

## 이 기술은 무엇인가

video-use의 핵심 발상은 "영상 편집을 자연어 명령 하나로 환원한다"입니다. 사용자는 타임라인을 직접 만지지 않습니다. 대신 원하는 결과를 문장으로 묘사하고, 에이전트가 그 문장을 여러 개의 구체적인 편집 동작으로 분해합니다.

공개된 설명에 따르면 video-use는 다음을 자동으로 처리합니다.

- 원본 푸티지에서 불필요한 구간을 잘라내는 컷 편집
- "음", "어" 같은 군더더기 발화(필러 워드)의 자동 제거
- 음성을 인식해 자막을 생성하고 영상에 입히는 작업
- 색보정을 적용해 톤을 통일하는 작업
- 강조가 필요한 지점에 애니메이션 오버레이를 얹는 작업
- 위 모든 결과를 하나의 최종 MP4로 렌더링하는 작업

여기서 흥미로운 부분은 애니메이션 처리 방식입니다. video-use는 애니메이션 오버레이를 만들 때 한 가지 엔진에 묶이지 않고 HyperFrames, Remotion, Manim, PIL 중에서 작업 성격에 맞는 것을 선택합니다. 더 중요한 점은, 각 애니메이션을 만들 때마다 별도의 서브에이전트를 병렬로 띄운다는 것입니다. 애니메이션 하나당 에이전트 하나가 붙는 구조입니다.

이 설계는 일반적인 "거대한 단일 프롬프트로 영상을 만든다"는 접근과 근본적으로 다릅니다. 영상 편집이라는 큰 작업을 컷, 자막, 색보정, 애니메이션 같은 독립적인 하위 작업으로 쪼개고, 서로 의존하지 않는 작업은 병렬로 실행한 뒤, 마지막에 하나의 타임라인으로 합치는 방식입니다. 전체 흐름을 도식으로 그리면 다음과 같습니다.

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
<div class="d3-arch" data-arch-root id="secodingagentvideoeditor-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1226, "height": 754, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 724, "y": 24, "w": 120, "h": 62, "title": ["원본 영상 폴더", "+ 한 문장 지시"]}, {"id": "B", "x": 724, "y": 164, "w": 120, "h": 46, "title": "에이전트: 의도 분해"}, {"id": "C", "x": 1074, "y": 412, "w": 120, "h": 62, "title": ["컷 편집", "구간 선택"]}, {"id": "D", "x": 899, "y": 412, "w": 120, "h": 62, "title": ["필러 워드 제거", "음성 분석"]}, {"id": "E", "x": 724, "y": 412, "w": 120, "h": 62, "title": ["자막 생성", "음성 인식"]}, {"id": "F", "x": 549, "y": 412, "w": 120, "h": 62, "title": ["색보정", "톤 통일"]}, {"id": "G", "x": 199, "y": 288, "w": 120, "h": 46, "title": "애니메이션 오버레이"}, {"id": "G1", "x": 374, "y": 412, "w": 120, "h": 62, "title": ["서브에이전트 1", "HyperFrames"]}, {"id": "G2", "x": 199, "y": 412, "w": 120, "h": 62, "title": ["서브에이전트 2", "Remotion"]}, {"id": "G3", "x": 24, "y": 412, "w": 120, "h": 62, "title": ["서브에이전트 3", "Manim / PIL"]}, {"id": "H", "x": 549, "y": 552, "w": 120, "h": 46, "title": "타임라인 조립"}, {"id": "I", "x": 549, "y": 676, "w": 120, "h": 46, "title": "최종 MP4 렌더링"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [784, 86, 784, 164]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[844, 198], [1134, 249], [1134, 373], [1134, 412]]}, {"src": "B", "dst": "D", "kind": "data", "curve": [[844, 208], [959, 249], [959, 373], [959, 412]]}, {"src": "B", "dst": "E", "kind": "data", "line": [784, 210, 784, 412]}, {"src": "B", "dst": "F", "kind": "data", "curve": [[724, 208], [609, 249], [609, 373], [609, 412]]}, {"src": "B", "dst": "G", "kind": "data", "curve": [[724, 194], [259, 249], [259, 249], [259, 288]]}, {"src": "G", "dst": "G1", "kind": "data", "curve": [[319, 332], [434, 373], [434, 373], [434, 412]]}, {"src": "G", "dst": "G2", "kind": "data", "line": [259, 334, 259, 412]}, {"src": "G", "dst": "G3", "kind": "data", "curve": [[199, 332], [84, 373], [84, 373], [84, 412]]}, {"src": "C", "dst": "H", "kind": "data", "curve": [[1134, 474], [1134, 513], [1134, 513], [669, 568]]}, {"src": "D", "dst": "H", "kind": "data", "curve": [[959, 474], [959, 513], [959, 513], [669, 564]]}, {"src": "E", "dst": "H", "kind": "data", "curve": [[784, 474], [784, 513], [784, 513], [669, 554]]}, {"src": "F", "dst": "H", "kind": "data", "line": [609, 474, 609, 552]}, {"src": "G1", "dst": "H", "kind": "data", "curve": [[434, 474], [434, 513], [434, 513], [549, 554]]}, {"src": "G2", "dst": "H", "kind": "data", "curve": [[259, 474], [259, 513], [259, 513], [549, 564]]}, {"src": "G3", "dst": "H", "kind": "data", "curve": [[84, 474], [84, 513], [84, 513], [549, 568]]}, {"src": "H", "dst": "I", "kind": "data", "line": [609, 598, 609, 676]}]});
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
      const container = document.getElementById('secodingagentvideoeditor-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'secodingagentvideoeditor-1';
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

*video-use가 영상 편집을 컷, 자막, 색보정, 애니메이션으로 분해하고, 애니메이션마다 서브에이전트를 병렬로 띄운 뒤 하나의 타임라인으로 합치는 흐름.*

도식에서 보이듯, 애니메이션 블록은 하나의 노드가 아니라 여러 서브에이전트로 펼쳐집니다. 각 서브에이전트는 자신이 맡은 애니메이션만 책임지고, 서로의 중간 결과를 보지 않습니다. 이렇게 분리하면 애니메이션이 세 개든 다섯 개든 동시에 진행할 수 있고, 전체 소요 시간은 가장 오래 걸리는 애니메이션 하나의 시간으로 수렴합니다.

## 설치 및 통합

video-use는 코딩 에이전트 위에서 도는 스킬 형태로 배포됩니다. browser-use 팀의 공개 저장소(`browser-use/video-use`)에서 받을 수 있고, "Edit videos with coding agents"라는 한 줄 설명 그대로 코딩 에이전트가 호스트가 됩니다. 일반적인 사용 흐름은 저장소를 받아 스킬을 에이전트가 인식할 수 있는 위치에 두고, 작업 폴더에 원본 영상을 넣은 뒤, 에이전트에게 원하는 결과를 한 문장으로 지시하는 순서입니다.

애니메이션 엔진은 각각 성격이 다릅니다. Remotion은 React로 영상을 프로그래밍하는 프레임워크라 컴포넌트 기반 모션 그래픽에 강하고, Manim은 수식과 도형 애니메이션에 특화된 파이썬 라이브러리이며, PIL은 가벼운 이미지 합성에, HyperFrames는 프레임 단위 시퀀스 생성에 쓰입니다. video-use는 이 엔진들을 미리 한 가지로 고정하지 않고 작업마다 적절한 것을 고르므로, 사용 환경에는 이 엔진들이 요구하는 런타임(Node, 파이썬, ffmpeg 등)이 갖춰져 있어야 합니다.

> 재현 범위에 대한 정직한 기록: 이 글을 쓰는 환경은 외부 네트워크와 의존성 설치가 제한된 격리 환경이라, 원본 영상 자산과 무거운 렌더링 의존성(Remotion, Manim, ffmpeg)을 갖춘 전체 파이프라인을 직접 돌려 렌더링 시간이나 품질 수치를 측정하지는 못했습니다. 그래서 이 글의 분석은 공개된 스킬 설명과 아키텍처 구조에 근거하며, 측정하지 않은 벤치마크 수치는 싣지 않았습니다.

## 실제 동작이 의미하는 것

비록 전체 렌더링을 직접 돌리지는 못했지만, 공개된 동작 명세만으로도 이 스킬이 무엇을 노리는지는 분명합니다. 가장 큰 전환은 "편집의 단위가 클립이 아니라 의도가 된다"는 점입니다.

기존 편집 도구에서 사용자는 "3초 지점부터 7초까지 잘라내고, 거기에 페이드를 넣고, 자막을 단다"처럼 동작 단위로 사고합니다. video-use에서는 "발표 영상을 깔끔하게 정리해서 자막과 강조 애니메이션을 넣은 1분짜리 클립으로 만들어줘"처럼 결과 단위로 사고합니다. 그 사이의 변환, 즉 의도를 수십 개의 동작으로 풀어내는 일을 에이전트가 맡습니다.

두 번째 전환은 병렬화입니다. 영상 편집은 본질적으로 직렬 작업처럼 보이지만, 실제로는 독립적인 하위 작업이 많습니다. 자막 생성은 색보정과 무관하고, 두 번째 장면의 애니메이션은 첫 번째 장면의 애니메이션과 무관합니다. video-use가 애니메이션마다 서브에이전트를 띄우는 것은 이 독립성을 적극적으로 활용해 벽시계 시간을 줄이려는 설계입니다. ThakiCloud가 멀티에이전트 오케스트레이션에서 늘 강조하는 "서로 의존하지 않는 작업은 병렬로"라는 원칙과 정확히 같은 발상입니다.

## ThakiCloud 제품 적용 시사점

video-use는 영상이라는 비개발 도메인을 다루지만, 그 설계 원리는 ThakiCloud가 Agent-Native Cloud로 제품화하는 **Paxis**의 핵심과 맞닿아 있습니다. Paxis는 ai-platform 위에서 도는 에이전트 제어 평면으로, 스킬(Skills), 도구(Tools), 정책(Policies), 감사 로그(Audit Logs)를 일급 리소스로 다룹니다. video-use의 구조를 Paxis의 레이어에 대응시키면 다음 세 가지가 보입니다.

첫째, **Skill Harness 관점**입니다. video-use는 그 자체로 하나의 스킬이고, 내부에서 HyperFrames, Remotion, Manim, PIL이라는 여러 하위 도구를 상황에 맞게 선택합니다. Paxis의 Skill Harness는 960개가 넘는 스킬을 BM25로 선택해 적합한 것만 컨텍스트에 올리는 구조인데, video-use가 애니메이션 작업마다 엔진을 고르는 방식은 이 "필요한 것만 고른다"는 원리의 작은 사례입니다. 자유 설계를 검증된 골격에 채우는 방식이 평균 품질을 올린다는 우리의 경험과도 일치합니다.

둘째, **Sandbox 격리 실행 관점**입니다. 영상 렌더링은 ffmpeg, Node, 파이썬 같은 무거운 의존성을 끌어오고, 잘못하면 호스트 환경을 오염시킵니다. Paxis는 모든 스킬 실행을 격리된 샌드박스에서 처리해 메인 작업 트리를 보호합니다. video-use처럼 외부 런타임을 여럿 부르는 스킬일수록 이 격리는 선택이 아니라 필수입니다. 병렬 서브에이전트가 각자 다른 엔진을 돌릴 때, 서로의 임시 파일과 프로세스가 충돌하지 않도록 막아주는 경계가 있어야 안정적으로 동작합니다.

셋째, **DAG 멀티에이전트 오케스트레이션 관점**입니다. video-use의 흐름은 사실상 방향성 비순환 그래프(DAG)입니다. 컷, 자막, 색보정, 애니메이션 노드가 병렬로 갈라졌다가 타임라인 조립 노드로 다시 모입니다. Paxis는 이런 fan-out과 fan-in을 일급으로 표현하고, 각 노드의 실행을 정책 게이트와 감사 로그로 통과시킵니다. 누가 어떤 도구를 언제 호출했는지가 전부 기록되므로, 결과물이 어떻게 만들어졌는지 추적할 수 있습니다.

정리하면, video-use는 "코딩 에이전트가 비개발 작업을 분해하고 병렬화하는" 한 편의 데모이고, Paxis는 그런 패턴을 안전하고 추적 가능하게 운영하는 제어 평면입니다. 영상 편집이든 데이터 파이프라인이든, 작업을 스킬로 캡슐화하고 격리된 샌드박스에서 병렬 실행하며 모든 행동을 감사 로그로 남기는 골격은 동일합니다.

## 한계 및 반론

이 접근이 만능은 아닙니다. 먼저, 의도를 동작으로 분해하는 단계에서 에이전트의 판단이 들어가므로, 사용자가 머릿속에 그린 결과와 산출물이 어긋날 수 있습니다. "깔끔하게"라는 지시는 사람마다 기준이 다르고, 에이전트가 잘라낸 구간이 사실은 핵심이었을 수도 있습니다. 결국 한 문장으로 끝나는 것이 아니라 여러 차례 수정 지시를 주고받게 될 가능성이 큽니다.

둘째, 비용과 시간입니다. 애니메이션마다 서브에이전트를 띄우는 구조는 병렬화로 벽시계 시간을 줄이는 대신, 동시에 도는 에이전트와 렌더링 프로세스만큼 연산 자원을 더 씁니다. 짧은 클립 하나를 다듬는 데에는 과한 설계일 수 있습니다. 전통적인 편집 도구로 5분이면 끝낼 작업을 에이전트 오케스트레이션으로 돌리는 것이 항상 이득은 아닙니다.

셋째, 결정론의 부재입니다. 같은 원본과 같은 지시를 줘도 매번 똑같은 결과가 나온다는 보장이 없습니다. 전문적인 영상 제작에서는 재현성이 중요한데, 에이전트 기반 편집은 이 부분에서 아직 검증이 필요합니다. ThakiCloud가 배치 산출물에서 "포맷과 집계는 결정론적 코드가 소유하고 모델은 내용만 생성한다"는 원칙을 강조하는 이유도 여기에 있습니다. 창의적 편집은 모델에게 맡기더라도, 자막 타이밍이나 출력 규격 같은 결정론적 부분은 코드가 보장하는 하이브리드가 현실적인 타협점일 것입니다.

그럼에도 video-use가 보여준 방향은 분명합니다. 비개발 도메인의 복잡한 작업도 스킬로 캡슐화하고, 독립적인 하위 작업을 병렬 에이전트로 분해하며, 자연어 의도를 진입점으로 삼는 패턴은 앞으로 더 많은 영역으로 번질 것입니다. ThakiCloud가 Paxis로 만들고 있는 것이 바로 그 패턴을 안전하게 운영하는 토대입니다.

## 출처

- [browser-use/video-use (GitHub)](https://github.com/browser-use/video-use): "Edit videos with coding agents"
- [@midudev 트윗](https://x.com/midudev): video-use 스킬 소개 (2026-06-27)
- [video-use: Edit Videos with Claude Code (AIBit)](https://aibit.im/en/article/video-use-edit-videos-with-claude-code)
