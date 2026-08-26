---
title: "Fable 5로 인터랙티브 웹을 짓는다: 3D, 스크롤 애니메이션, GLSL까지 한 프롬프트로"
excerpt: "Anthropic의 Claude Fable 5가 프런트엔드 생성에서 새로운 기준을 세우고 있습니다. 스크롤로 제어되는 3D 씬, GLSL 셰이더, 스크린샷 기반 리디자인을 단일 프롬프트에서 뽑아내는 워크플로를 실제 공개 가이드와 오픈소스 갤러리를 근거로 정리하고, 코딩 에이전트를 일급 리소스로 다루는 ThakiCloud Paxis 관점에서 이 흐름이 무엇을 의미하는지 짚습니다."
seo_title: "Claude Fable 5 인터랙티브 웹 디자인 - 3D 스크롤 애니메이션 GLSL 워크플로 (2026) - Thaki Cloud"
seo_description: "Claude Fable 5로 3D 인터랙티브 사이트, 스크롤 제어 애니메이션, GLSL 셰이더를 단일 프롬프트에서 생성하는 기법을 실제 공개 가이드(Viktor Oddy)와 오픈소스 갤러리(claude-directory)를 근거로 분석합니다. 프런트엔드 생성 워크플로, 스크린샷 리디자인, Three.js 통합을 다루고 코딩 에이전트를 일급 리소스로 다루는 ThakiCloud Paxis Agent-Native Cloud 관점의 함의를 정리합니다."
date: 2026-07-09
last_modified_at: 2026-07-09
tags:
  - claude-fable-5
  - web-design
  - frontend
  - interactive-animation
  - threejs
  - ai-coding
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ko/dev/fable5-interactive-web-design/"
reading_time: true
categories:
  - dev
audiobook: /assets/audio/posts/fable5-interactive-web-design/audiobook-ko.mp3
audiobook_note: "AI 로컬 합성 오디오북 (Qwen3-TTS)"
---

## 이 글을 누가 읽으면 좋은가

이 글은 AI 코딩 도구로 실제 제품 화면을 만드는 프런트엔드 개발자와 디자인 엔지니어, 그리고 코딩 에이전트를 팀의 워크플로에 배선하려는 플랫폼 엔지니어를 위해 씁니다. "AI가 그럴듯한 랜딩 페이지 목업을 뽑는다"는 이야기는 이미 흔합니다. 여기서 다루려는 질문은 한 단계 더 들어갑니다. 스크롤에 반응하는 3D 씬이나 셰이더 기반 배경처럼, 손으로 짜면 며칠 걸리는 인터랙션을 모델이 어디까지 실제로 만들어 내는가, 그리고 그 결과물을 프로덕션 파이프라인에 어떻게 얹을 것인가입니다. 결정을 앞둔 분이라면, 이 글은 과장 없이 현재 가능한 것과 아직 사람이 붙어야 하는 것을 구분해 드리는 데 목적이 있습니다.

![빛과 유리 표면이 겹치며 깊이감을 만드는 추상적인 3D 인터랙션의 이미지]({{ '/assets/images/fable5-interactive-web-design-hero.webp' | relative_url }})

## 개요

프런트엔드에서 AI 생성물의 벽은 오랫동안 "정적"이었습니다. 버튼과 카드가 가지런히 놓인 페이지는 잘 나오지만, 스크롤 위치에 따라 카메라가 움직이는 3D 씬이나 마우스를 따라 굴절되는 유리 재질처럼 상태와 시간이 얽힌 인터랙션은 모델이 자주 무너졌습니다. 코드가 컴파일은 되는데 화면에서는 아무 일도 일어나지 않거나, 프레임이 뚝뚝 끊기는 식이었습니다.

2026년 중반 들어 이 벽이 눈에 띄게 낮아졌습니다. 그 중심에 Anthropic의 Claude Fable 5가 있습니다. 개발자 Viktor Oddy는 "Claude Fable 5 Just Changed Web Design Forever!"라는 제목의 공개 가이드에서, 단일 프롬프트로 3D이면서 인터랙티브하고 애니메이션이 붙은 웹사이트를 만들어 내는 과정을 처음부터 끝까지 녹화해 공유했습니다. 이후 커뮤니티에서는 Fable 5로 만든 UI 실험을 모은 오픈소스 갤러리까지 등장했습니다. 이 글은 그 흐름을 따라가며, 무엇이 실제로 달라졌고 이것이 ThakiCloud처럼 에이전트를 인프라로 다루는 회사에 어떤 의미인지 정리합니다.

{% include video id="_JF_s-ZRTyY" provider="youtube" %}

위 영상은 Viktor Oddy가 Fable 5로 3D 인터랙티브 웹을 만드는 과정을 녹화한 가이드입니다.

![fable5-interactive-web-design 슬라이드 1]({{ '/assets/images/fable5-interactive-web-design-slide-01.webp' | relative_url }})

## Fable 5는 무엇이 다른가

Fable 5는 Anthropic이 공개한 Claude 계열 모델로, 특히 프런트엔드 엔지니어링과 여러 단계에 걸친 에이전트형 작업에서 강점을 보입니다. 여기서 "여러 단계"라는 표현이 중요합니다. 인터랙티브 웹 하나를 만드는 일은 사실 여러 작업의 묶음입니다. 레이아웃을 잡고, 3D 지오메트리를 정의하고, 스크롤 이벤트와 씬을 연결하고, 셰이더를 붙이고, 파일을 구조화하고, 성능을 다듬는 과정이 이어집니다. 기존 모델이 이 중 한두 단계를 처리하고 나머지를 사람에게 넘겼다면, Fable 5는 이 사슬을 더 길게 스스로 이어 갑니다.

구체적으로 공개 사례에서 반복적으로 확인되는 특징은 다음과 같습니다. 첫째, 스크롤로 제어되는 애니메이션을 코드로 구현합니다. 스크롤 진행도를 씬의 카메라나 요소 상태에 매핑하는, 손으로 짜면 상태 관리가 까다로운 부분을 모델이 직접 배선합니다. 둘째, Three.js 같은 3D 라이브러리와 GLSL 셰이더를 조합해 굴절, 노이즈, 파티클 같은 시각 효과를 만듭니다. 셋째, 스크린샷을 입력으로 받아 기존 사이트의 레이아웃과 인터랙션을 개선한 리디자인을 제안합니다. 넷째, 프로젝트 파일 구조와 애셋을 스스로 정리하며 단일 프롬프트에서 실행 가능한 결과물까지 밀고 갑니다.

이 능력들의 공통점은 "정적 마크업 생성"이 아니라 "상태와 시간이 얽힌 코드의 생성"이라는 점입니다. 바로 이 지점이 그동안 AI 프런트엔드의 약한 고리였고, Fable 5가 눈에 띄게 밀어 올린 부분입니다.

![fable5-interactive-web-design 슬라이드 2]({{ '/assets/images/fable5-interactive-web-design-slide-02.webp' | relative_url }})

## 인터랙티브 웹 디자인, 어떻게 만드는가

공개된 가이드와 갤러리의 결과물을 역으로 추적하면, 실전 워크플로는 대체로 아래 흐름을 따릅니다. 한 번에 완벽한 결과를 기대하기보다, 모델이 잘하는 단계를 큰 덩어리로 맡기고 사람이 검수하며 좁혀 가는 구조입니다.

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
<div class="d3-arch" data-arch-root id="ble5interactivewebdesign-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 322, "height": 848, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 55, "y": 24, "w": 135, "h": 62, "title": ["의도 프롬프트", "(무드·레퍼런스·스택 명시)"]}, {"id": "B", "x": 58, "y": 164, "w": 128, "h": 62, "title": ["초안 생성", "레이아웃 + 3D 씬 골격"]}, {"id": "C", "x": 58, "y": 304, "w": 128, "h": 62, "title": ["인터랙션 배선", "스크롤 진행도 → 씬 상태"]}, {"id": "D", "x": 106, "y": 444, "w": 184, "h": 62, "title": ["시각 효과", "GLSL 셰이더 · Three.js 재질"]}, {"id": "E", "x": 58, "y": 584, "w": 128, "h": 62, "title": ["사람 검수", "성능 · 접근성 · 브랜드"]}, {"id": "F", "x": 44, "y": 738, "w": 156, "h": 78, "title": ["빌드 · 배포", "React · Tailwind ·", "Three.js"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [122, 86, 122, 164]}, {"src": "B", "dst": "C", "kind": "data", "line": [122, 226, 122, 304]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[156, 366], [198, 405], [198, 405], [198, 444]]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[198, 506], [198, 545], [198, 545], [156, 584]]}, {"src": "E", "dst": "C", "kind": "data", "label": "\"수정 지시\"", "curve": [[89, 584], [46, 545], [46, 405], [89, 366]], "off": "50%"}, {"src": "E", "dst": "F", "kind": "data", "label": "\"통과\"", "line": [122, 646, 122, 738], "lx": 122, "ly": 688}]});
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
      const container = document.getElementById('ble5interactivewebdesign-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ble5interactivewebdesign-1';
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

핵심은 첫 프롬프트에 "무엇을 원하는가"를 충분히 구체적으로 담는 것입니다. 원하는 무드, 참고 사이트, 사용할 스택(예: React, Tailwind, Three.js)을 명시하면 모델의 초안 품질이 크게 달라집니다. 스크린샷을 함께 주면 리디자인 정확도가 올라갑니다. 초안이 나온 뒤에는 "스크롤 하단에서 카메라가 더 천천히 움직이게" 같은 인터랙션 단위의 수정 지시가 잘 먹힙니다. 즉, 프롬프트 한 방으로 끝내는 것이 아니라, 큰 골격은 모델에게 맡기고 인터랙션의 결을 사람이 조율하는 방식입니다.

주의할 점도 분명합니다. 화려한 셰이더와 3D는 모바일 성능과 접근성에서 대가를 치릅니다. 모델이 뽑은 결과가 데스크톱에서 근사해도, 저사양 기기나 스크린 리더 사용자를 위한 대응은 여전히 사람의 몫입니다. 이 검수 단계를 워크플로에 명시적으로 넣지 않으면, "예쁘지만 실전에 못 쓰는" 결과물이 쌓이기 쉽습니다.

![fable5-interactive-web-design 슬라이드 3]({{ '/assets/images/fable5-interactive-web-design-slide-03.webp' | relative_url }})

## 실제 사례와 오픈소스 갤러리

이 흐름이 개인의 자랑이 아니라는 근거는 공개 자료에 있습니다. 앞서 언급한 Viktor Oddy의 가이드는 과정 전체를 녹화로 남겼고, 커뮤니티에서는 Fable 5로 만든 UI 실험을 모은 오픈소스 갤러리 `pulkitxm/claude-directory`가 공개되어 있습니다. 이 저장소는 랜딩 페이지, 히어로 섹션, GLSL 셰이더, 디자인 시스템, 애니메이션, 3D를 React, Tailwind, Three.js 위에서 구현한 예제를 모아 둔 곳으로, 결과물을 직접 열어 코드까지 확인할 수 있습니다. 개별 실험을 브라우저에서 바로 볼 수 있으므로, "정말 되는가"를 스크린샷이 아니라 실행으로 검증할 수 있다는 점이 중요합니다.

또 다른 사례로는 Fable 5와 Higgsfield MCP를 조합해 시네마틱 스크롤 웹사이트를 만든 공개 기록도 있습니다. 여기서 눈여겨볼 부분은 모델이 단독으로 모든 것을 하는 것이 아니라, MCP 커넥터를 통해 외부 도구(여기서는 비주얼 애셋 생성)와 연결되어 하나의 결과물로 합쳐진다는 점입니다. 인터랙티브 웹 생성이 단일 모델의 재주가 아니라, 모델과 도구가 물려 돌아가는 파이프라인의 산물로 진화하고 있다는 신호입니다.

정리하면 지금 시점에서 확인 가능한 사실은 다음과 같습니다. 첫째, 단일 프롬프트에서 3D 인터랙티브 웹의 실행 가능한 초안이 나옵니다. 둘째, 그 결과가 공개 저장소에서 코드째 검증됩니다. 셋째, MCP 같은 도구 연결로 애셋 생성까지 파이프라인에 통합됩니다. 다만 이 사례들에서 정량적인 성능 벤치마크(프레임률, 번들 크기, 접근성 점수)는 표준화되어 공개된 것이 없으므로, 품질 판단은 여전히 각자의 검수 기준에 달려 있다는 점은 [추정]이 아니라 사실로 받아들이는 편이 안전합니다.

![fable5-interactive-web-design 슬라이드 4]({{ '/assets/images/fable5-interactive-web-design-slide-04.webp' | relative_url }})

## ThakiCloud 제품 적용 시사점

이 흐름은 ThakiCloud가 만드는 Paxis의 방향과 정확히 맞물립니다. Paxis는 ai-platform 위에서 도는 Agent-Native Cloud 제어 평면으로, 스킬(Skills)·도구(Tools)·정책(Policies)·감사 로그(Audit Logs)를 일급 리소스로 다룹니다. Fable 5가 보여 준 것은 코딩 에이전트가 단발 응답기를 넘어 여러 단계를 스스로 이어 가는 생성 주체가 되었다는 사실입니다. 이런 에이전트를 제품 워크플로에 얹으려면, "무엇을 생성하느냐"만큼이나 "어디서 어떤 권한으로 실행되고 무엇이 기록되느냐"가 중요해집니다.

Paxis 관점에서 위 워크플로를 다시 보면 각 단계가 제어 평면의 리소스로 환원됩니다. 인터랙티브 웹 생성 같은 반복 작업은 하나의 스킬로 등록되어 960여 개 스킬 풀에서 BM25로 선택되고, 실제 코드 생성과 빌드는 격리된 샌드박스에서 실행됩니다. Higgsfield MCP 사례처럼 외부 도구가 필요하면 MCP 커넥터가 OAuth 재연결까지 자동으로 처리합니다. 생성물이 프로덕션에 닿기 전에는 정책 게이트가 검수 규칙을 강제하고, 모든 행동은 감사 로그에 남습니다. 즉 "AI가 화면을 잘 만든다"는 개별 재주를, 팀이 신뢰하고 감사할 수 있는 반복 가능한 파이프라인으로 승격시키는 것이 제어 평면이 하는 일입니다.

인프라 층에서도 함의가 있습니다. 3D와 셰이더가 붙은 프런트엔드는 생성 단계에서 무거운 렌더링과 반복 빌드를 요구합니다. ThakiCloud의 ai-platform은 K8s와 Kueue 기반으로 이런 버스트성 작업을 격리된 테넌트 안에서 스케줄링하고, 필요할 때만 자원을 붙였다 떼는 방식으로 비용을 관리합니다. 온프레미스와 소버린 환경에서 자체 호스팅으로 이 파이프라인을 돌릴 수 있다는 점은, 코드와 디자인 애셋을 외부로 내보내기 어려운 고객에게 특히 의미가 있습니다. 저비용의 안정적인 생성·빌드 인프라(ai-platform)가 있어야, 그 위에서 에이전트 경제성(Paxis)이 성립합니다.

## 한계 및 반론

낙관만 정리하면 균형이 무너집니다. 몇 가지 반대편을 분명히 해 둡니다.

첫째, 생성된 인터랙션 코드의 유지보수성은 여전히 불확실합니다. 한 프롬프트에서 나온 3D 씬은 인상적이지만, 몇 달 뒤 다른 사람이 그 상태 관리 로직을 이해하고 수정할 수 있는가는 다른 문제입니다. 화려함과 유지보수성은 자주 상충합니다.

둘째, 성능과 접근성은 자동으로 따라오지 않습니다. 앞서 강조했듯 모바일 프레임률, 번들 크기, 스크린 리더 대응은 모델이 기본으로 챙겨 주는 영역이 아니며, 이를 검수 게이트로 명시하지 않으면 기술 부채로 남습니다.

셋째, 결과물의 독창성 문제입니다. 비슷한 프롬프트가 비슷한 3D 히어로 섹션을 양산하면, 모든 사이트가 같은 무드로 수렴하는 "AI 미학의 획일화"가 생길 수 있습니다. 도구가 강력할수록, 무엇을 만들지에 대한 사람의 판단이 오히려 더 중요해집니다.

넷째, 공개 사례에 표준화된 정량 지표가 없다는 점은 신중함을 요구합니다. "차원이 다르다"는 인상적인 증언은 많지만, 재현 가능한 벤치마크로 검증된 것은 아직 부족합니다. 실전 도입 전에는 자신의 스택과 기준으로 직접 재현해 보는 단계를 권합니다.

결론적으로 Fable 5는 인터랙티브 웹 생성의 문턱을 실질적으로 낮췄습니다. 다만 그 결과를 신뢰할 수 있는 제품으로 만드는 일은, 여전히 검수와 정책과 인프라의 문제입니다. 그리고 그 마지막 구간을 어떻게 시스템으로 닫느냐가, 도구를 쓰는 팀과 제품을 만드는 팀을 가릅니다.


## 출처

- Viktor Oddy, "Claude Fable 5 Just Changed Web Design Forever!" (가이드 영상 및 아티클), <https://www.youtube.com/watch?v=_JF_s-ZRTyY>
- pulkitxm/claude-directory, Fable 5로 만든 오픈소스 UI 실험 갤러리 (React·Tailwind·Three.js·GLSL), <https://github.com/pulkitxm/claude-directory>
- "I Built a Cinematic Scroll Website Using Claude Fable 5 and Higgsfield MCP", Medium, <https://medium.com/@info.booststash/i-built-a-cinematic-scroll-website-using-claude-fable-5-and-higgsfield-mcp-72fbcebb8ad1>
