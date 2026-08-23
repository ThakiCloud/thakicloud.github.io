---
title: "토큰 비용을 34~71% 깎는 가역 압축: Headroom 실측 리포트와 ThakiCloud 컨텍스트 위생"
excerpt: "AI 코딩 에이전트의 가장 큰 숨은 비용은 컨텍스트입니다. Headroom(headroom-ai)을 ThakiCloud repo의 실제 JSON 도구 출력 3종에 직접 돌려 토큰 절감률을 측정했습니다. SmartCrusher가 무손실 가역 압축으로 토큰을 최대 71.2% 줄이는 과정을 설치 명령부터 측정 수치까지 정리합니다."
seo_title: "Headroom 가역 컨텍스트 압축 실측 리포트 - Thaki Cloud"
seo_description: "Headroom(headroom-ai) SmartCrusher 가역 JSON 압축을 실제 repo 데이터로 측정한 결과(토큰 34~71% 절감), 설치·통합 명령, K8s LLM 서빙 토큰 비용 절감과 컨텍스트 위생 실무 분석"
date: 2026-06-21
last_modified_at: 2026-06-21
tags:
  - headroom
  - context-compression
  - token-cost
  - llm-serving
  - rag
  - mcp
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/dev/headroom-reversible-context-compression/"
reading_time: true
categories:
  - dev
---

![데이터가 응축되는 추상 이미지]({{ '/assets/images/headroom-reversible-context-compression-hero.webp' | relative_url }})
*컨텍스트는 공짜가 아닙니다. 흩어진 토큰을 무손실로 응축하는 것이 Headroom의 일입니다.*

## 개요

AI 코딩 에이전트를 매일 돌리는 팀이라면 가장 큰 숨은 비용이 어디서 나오는지 알고 있습니다. 바로 컨텍스트입니다. 도구 출력, RAG 결과, 로그, 파일, 대화 히스토리가 매 턴 쌓이고, 그 토큰이 그대로 청구서가 됩니다. 멀티에이전트 워크플로에서는 이 비용이 선형이 아니라 곱셈으로 늘어납니다. 서브에이전트 한 개가 큰 검색 결과 JSON을 컨텍스트에 넣을 때마다 캐시 read 토큰이 함께 불어나기 때문입니다.

이 글은 단순 도구 소개가 아닙니다. 저희 ThakiCloud는 이미 Headroom을 프로덕션 도구 체인에 채택해 운영 중이고, 이번에는 저희 repo의 실제 JSON 도구 출력 3종을 가져와 Headroom을 직접 돌렸습니다. 설치 명령, 통합 코드, 그리고 실측 토큰 절감 수치까지 재현 가능한 형태로 정리합니다. 결론을 먼저 말하면, 반복 구조가 강한 JSON일수록 절감이 크고, 저희 데이터에서는 토큰 기준 최대 71.2%까지 줄었습니다. 모든 수치는 샌드박스에서 실제로 측정한 값이며, 추정값을 섞지 않았습니다.

## Headroom이란 무엇인가

Headroom(PyPI 패키지명 `headroom-ai`, GitHub `chopratejas/headroom`)은 넷플릭스 출신 엔지니어 Tejas Chopra가 오픈소스화한 컨텍스트 압축 도구입니다. 표방하는 목표는 명확합니다. 도구 출력, 로그, 파일, RAG 청크를 LLM에 닿기 전에 압축해 토큰을 줄이되 답은 동일하게 유지하는 것입니다.

기존 컨텍스트 절감 도구들은 대부분 비가역입니다. 한 번 자르면 원본을 되돌릴 수 없습니다. Headroom의 핵심 차별점은 로컬에서 동작하고, 여러 콘텐츠 타입을 커버하며, 가역(reversible)이라는 점입니다. 원본은 설정된 TTL 안에서 브레드크럼 해시로 복원할 수 있습니다. 즉 "압축했더니 에이전트가 디테일을 잃었다"는 전형적 실패를 구조적으로 막습니다. 압축본을 우선 투입하고, 특정 섹션이 필요할 때만 원본을 복원하는 운영이 가능합니다.

붙이는 방식도 세 가지입니다. 라이브러리로 직접 호출하거나, 프록시로 끼우거나, MCP 서버로 띄울 수 있습니다. 콘텐츠 타입을 인식해서 JSON의 이상치만 남기거나 로그의 실패 라인만 남기는 식으로 선택적으로 압축합니다.

### 내부 구성: SmartCrusher가 핵심

Headroom은 콘텐츠 타입별로 다른 압축기를 라우팅합니다. 이번 실험에서 실제로 동작한 변환기는 라우터 로그에 `router:protected:user_message`, `router:mixed:...`로 찍혔습니다. 즉 사용자 메시지는 보호하고, 도구 메시지의 JSON 페이로드만 골라 압축한다는 뜻입니다.

- **SmartCrusher**: 딕셔너리 배열, 중첩 객체, 혼합 타입을 다루는 범용 JSON 압축기입니다. 반복 구조의 JSON 도구 출력(검색 결과, 로그 행, 레코드 리스트)에서 중복되는 키를 폴딩하고 스키마를 추론해 결정론적으로 줄입니다. 이번 측정에서 절감의 대부분을 책임진 컴포넌트입니다.
- **코드 압축기**: 소스 코드를 구조 인식으로 압축합니다.
- **이미지 압축**: 이미지 페이로드도 절감 대상입니다.

아래 다이어그램이 이번에 관측한 데이터 흐름입니다. 도구 출력이 라우터를 거쳐 SmartCrusher로 들어가고, 압축 컨텍스트가 LLM 호출로 가는 동안 원본은 별도로 보관되어 필요 시 가역 복원됩니다.

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
<div class="d3-arch" data-arch-root id="rsiblecontextcompression-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 693, "height": 820, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 186, "y": 24, "w": 120, "h": 62, "title": ["도구 출력", "Tool Output"]}, {"id": "B", "x": 363, "y": 164, "w": 163, "h": 62, "title": ["Content-Type Router", "콘텐츠 타입 라우터"]}, {"id": "C", "x": 376, "y": 304, "w": 138, "h": 52, "title": "콘텐츠 타입 분기"}, {"id": "D", "x": 541, "y": 448, "w": 120, "h": 62, "title": ["SmartCrusher", "결정론적 JSON 압축"]}, {"id": "E", "x": 351, "y": 448, "w": 135, "h": 62, "title": ["코드 압축기", "Code Compressor"]}, {"id": "F", "x": 154, "y": 448, "w": 142, "h": 62, "title": ["이미지 압축기", "Image Compressor"]}, {"id": "G", "x": 340, "y": 588, "w": 156, "h": 62, "title": ["압축 컨텍스트", "Compressed Context"]}, {"id": "H", "x": 186, "y": 742, "w": 120, "h": 46, "title": "LLM 호출"}, {"id": "I", "x": 24, "y": 588, "w": 142, "h": 62, "title": ["원본 저장소", "Reversible Store"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[306, 76], [445, 125], [445, 125], [445, 164]]}, {"src": "B", "dst": "C", "kind": "data", "line": [445, 226, 445, 304]}, {"src": "C", "dst": "D", "kind": "data", "label": "JSON 배열·중첩 객체", "curve": [[501, 356], [601, 402], [601, 402], [601, 448]], "off": "50%"}, {"src": "C", "dst": "E", "kind": "data", "label": "소스 코드", "curve": [[435, 356], [418, 402], [418, 402], [418, 448]], "off": "50%"}, {"src": "C", "dst": "F", "kind": "data", "label": "이미지", "curve": [[376, 353], [225, 402], [225, 402], [225, 448]], "off": "50%"}, {"src": "D", "dst": "G", "kind": "data", "curve": [[601, 510], [601, 549], [601, 549], [496, 589]]}, {"src": "E", "dst": "G", "kind": "data", "line": [418, 510, 418, 588]}, {"src": "F", "dst": "G", "kind": "data", "curve": [[225, 510], [225, 549], [225, 549], [340, 591]]}, {"src": "G", "dst": "H", "kind": "data", "curve": [[418, 650], [418, 696], [418, 696], [303, 742]]}, {"src": "A", "dst": "I", "kind": "event", "label": "브레드크럼 해시 + TTL", "curve": [[186, 83], [95, 265], [95, 479], [95, 588]], "off": "50%"}, {"src": "I", "dst": "H", "kind": "event", "label": "가역 복원", "curve": [[95, 650], [95, 696], [95, 696], [196, 742]], "off": "50%"}]});
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
      const container = document.getElementById('rsiblecontextcompression-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'rsiblecontextcompression-1';
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
*Headroom 데이터 흐름: 도구 출력이 라우터를 거쳐 SmartCrusher로 압축된 후 LLM에 전달되며, 원본은 TTL 안에서 가역 복원됩니다. 도표를 클릭하면 크게 볼 수 있습니다.*

## 설치 및 통합

저희 환경의 Python 런타임은 단일 인터프리터(3.12.8) `.venv`로 통합되어 있습니다. 설치는 한 줄입니다.

```bash
VIRTUAL_ENV="$PWD/.venv" uv pip install "headroom-ai[code,relevance]"
```

`[code,relevance]` extra는 코드 구조 인식 압축과 관련도 기반 필터링을 켭니다. 평문 텍스트의 의미 기반 압축까지 쓰려면 추가 모델(약 261MB)이 필요하지만, 가장 효과가 큰 JSON 경로는 이 기본 설치만으로 동작합니다.

통합은 메시지 리스트를 그대로 넘기는 방식이 가장 단순합니다. 저희가 실제로 쓰는 래퍼(`scripts/headroom_compress.py`)의 핵심은 다음과 같습니다. 도구 출력을 `tool` 역할 메시지의 `content`로 넣고 `compress`를 호출하면 끝입니다.

```python
from headroom import compress

messages = [
    {"role": "user", "content": "Summarize this tool output"},
    {"role": "assistant", "content": None,
     "tool_calls": [{"id": "c1", "type": "function",
                     "function": {"name": "tool", "arguments": "{}"}}]},
    {"role": "tool", "tool_call_id": "c1", "content": raw_json_string},
]

result = compress(messages, model="claude-sonnet-4-5-20250929")
compressed = result.messages[-1]["content"]
print(result.tokens_before, "->", result.tokens_after, result.transforms_applied)
```

`compress`가 반환하는 객체에는 `tokens_before`, `tokens_after`, `transforms_applied`가 들어 있어, 압축이 실제로 무엇을 했는지 코드가 사후 검증할 수 있습니다. 모델이 자기보고하는 숫자가 아니라 라이브러리가 측정한 값이라는 점이 중요합니다. 저희는 여기에 더해 별도 토크나이저(tiktoken)로 한 번 더 교차 검증했습니다.

## 실제 실험 결과

실험은 격리된 git worktree 샌드박스에서 진행했습니다. 메인 작업 트리를 건드리지 않고, 결과만 evidence 디렉터리에 남기는 구조입니다. 테스트 데이터는 저희 repo의 실제 산출물 중 반복 구조가 뚜렷한 JSON 3종을 골랐습니다.

1. **skill_index.json**: 스킬 검색용 BM25 인덱스. 동일 스키마의 레코드가 대량 반복됩니다.
2. **seedance-prompts/raw-prompts.json**: 프롬프트 카탈로그 605개. 자연어 텍스트 비중이 높습니다.
3. **twitter timeline 아카이브**: 타임라인 레코드 1,385개. 동일 키 구조의 객체 배열입니다.

토큰 카운트는 `cl100k_base` 토크나이저로 측정했습니다. 바이트와 토큰을 모두 기록한 이유는, 압축이 단순 바이트 절감이 아니라 실제 청구 단위인 토큰에서 얼마나 효과가 있는지를 봐야 하기 때문입니다. 측정 결과는 다음과 같습니다.

| 테스트 데이터 | 원본 토큰 | 압축 토큰 | 토큰 절감 | 바이트 절감 | 소요 |
|---|---|---|---|---|---|
| skill_index (BM25 인덱스) | 1,618,287 | 465,445 | **71.2%** | 64.9% | 2.08s |
| twitter-timeline (레코드 배열) | 399,926 | 192,465 | **51.9%** | 57.0% | 0.24s |
| seedance-prompts (프롬프트 카탈로그) | 1,085,592 | 713,210 | **34.3%** | 38.5% | 0.57s |

![실측 압축률 차트]({{ '/assets/images/headroom-reversible-context-compression-results.webp' | relative_url }})
*ThakiCloud repo의 JSON 도구 출력 3종에 대한 실측 절감률. 바이트와 토큰을 함께 표기했습니다.*

수치를 읽는 방법이 중요합니다. **반복 구조가 강할수록 절감이 큽니다.** skill_index는 동일 스키마 레코드가 빽빽하게 반복되는 인덱스라 SmartCrusher의 키 폴딩 효과가 극대화되어 토큰을 71.2%나 줄였습니다. twitter timeline도 균일한 객체 배열이라 절반 이상 절감했습니다. 반면 seedance-prompts는 자연어 프롬프트 텍스트가 레코드의 대부분을 차지해, 구조 압축으로 깎을 여지가 상대적으로 적어 34.3%에 그쳤습니다. 이 차이가 바로 "JSON 경로에서 가장 효과가 크다"는 설계 의도를 그대로 보여줍니다.

소요 시간도 주목할 만합니다. 160만 토큰짜리 인덱스를 2초 만에 처리했고, 나머지는 1초 미만입니다. 이 정도면 도구 출력이 컨텍스트로 들어가기 직전에 인라인으로 끼워도 체감 지연이 거의 없습니다. 결정론적 압축이라 같은 입력에는 항상 같은 출력이 나오고, 따라서 캐시 친화적이기도 합니다.

한 가지 정직하게 짚을 점이 있습니다. 위 수치는 한 번씩 측정한 단일 런 값이며, 데이터셋 3종에 대한 결과입니다. 다른 종류의 JSON, 특히 값이 거의 유니크하고 반복 키가 적은 데이터에서는 절감률이 더 낮게 나올 수 있습니다. 그래도 저희 실측 범위에서 토큰 기준 34~71%라는 폭은, 적어도 반복 구조 도구 출력에 대해서는 충분히 의미 있는 결과입니다.

## ThakiCloud K8s AI/ML SaaS 플랫폼 적용 및 시사점

저희가 Headroom을 채택한 지점은 정확히 위 실험이 보여준 곳입니다. 바로 **반복 구조의 대용량 JSON 도구 출력**입니다. 저희 컨텍스트 위생 룰(`ecc-token-strategy`)에는 이런 규칙이 명시되어 있습니다. 반복 구조의 JSON 배열 도구 출력은 컨텍스트에 넣기 전에 SmartCrusher로 결정론적으로 압축한다, 평문은 압축 대상이 아니라 JSON 경로에 한정한다, 그리고 우선순위는 서브에이전트 요약이 먼저고 그다음이 headroom 압축이다.

이것이 K8s 위 멀티에이전트 오케스트레이션에서 특히 중요한 이유는 비용의 구조 때문입니다. 다수의 서브에이전트가 도는 워크플로에서 컨텍스트 위생은 곧 세 가지를 동시에 의미합니다. 첫째는 토큰 비용 통제입니다. 둘째는 캐시 히트율 관리입니다. 결정론적 압축은 동일 입력에 동일 출력을 보장하므로 프롬프트 캐시를 깨지 않습니다. 셋째는 응답 지연 관리입니다. 컨텍스트가 작을수록 모델이 더 빨리 응답합니다.

저희 LLM 서빙은 K8s 위에서 Kueue로 GPU 워크로드를 스케줄링하고, 다수의 추론 요청이 동시에 흐릅니다. 이 환경에서 컨텍스트가 비대해지면 그 비용은 한 요청에 그치지 않고 전체 처리량을 갉아먹습니다. Headroom은 이 레이어를 코드를 거의 바꾸지 않고 끼워 넣을 수 있게 해줍니다. 검색 결과나 로그 배열을 컨텍스트에 넣기 직전에 한 줄로 압축하고, 특정 섹션이 필요할 때만 가역 복원하는 운영이 가능합니다.

데이터 사이언티스트 관점에서도 실용적입니다. RAG 파이프라인에서 검색된 청크가 반복 메타데이터(소스 URL, 타임스탬프, 점수 같은 동일 키)를 잔뜩 달고 오는 경우, 그 메타데이터 부분이 바로 SmartCrusher가 가장 잘 깎는 영역입니다. 본문은 보존하면서 구조적 군더더기만 줄이므로, 검색 정확도를 희생하지 않고 컨텍스트 예산을 확보할 수 있습니다.

## 한계 및 반론

이 도구를 무비판적으로 권하지는 않습니다. 솔직한 한계와 반론을 정리합니다.

**첫째, 로컬 실행이 전제입니다.** Headroom은 로컬 프로세스를 실행할 수 있어야 동작하므로, 샌드박스로 완전히 격리된 실행 환경에서는 쓸 수 없습니다. 이 제약이 맞지 않는 배포 형태가 분명히 있습니다.

**둘째, 평문에는 효과가 제한적입니다.** 위 seedance-prompts 결과가 보여주듯, 자연어 텍스트 비중이 높은 데이터는 구조 압축으로 깎을 여지가 적습니다. 평문까지 의미 기반으로 줄이려면 추가 모델을 설치해야 하고, 그 경로는 결정론성과 속도를 일부 포기하게 됩니다.

**셋째, 단일 프로바이더만 쓰는 팀에는 과잉일 수 있습니다.** 한 모델 프로바이더의 네이티브 compaction만으로 충분하고 크로스 에이전트 메모리가 필요 없다면, 별도 압축 레이어를 도입하는 운영 부담이 이득보다 클 수 있습니다.

**넷째, 가장 강한 반론은 "그냥 서브에이전트로 요약하면 되지 않나"입니다.** 실제로 저희 룰의 우선순위도 서브에이전트 요약이 headroom 압축보다 앞섭니다. 요약은 비가역이지만 절감 폭이 훨씬 크고 의미 단위로 압축됩니다. 그렇다면 Headroom의 자리는 어디인가. 답은 "요약하면 디테일을 잃는데, 그 디테일이 나중에 필요할지 모를 때"입니다. 가역성이 바로 이 빈틈을 메웁니다. 압축본으로 평소에 돌다가, 특정 레코드의 원본이 필요해지는 순간 TTL 안에서 정확히 복원합니다. 요약과 압축은 경쟁 관계가 아니라 보완 관계입니다.

정리하면 Headroom은 "컨텍스트는 공짜가 아니다"라는 원칙을 가역 압축이라는 구체적 설계로 구현한 사례입니다. 저희 실측 범위에서 반복 구조 JSON에 대해 토큰을 34~71% 줄였고, 결정론성과 가역성 덕분에 캐시를 깨지 않으면서 디테일도 잃지 않았습니다. ThakiCloud가 컨텍스트 위생을 어떻게 비용과 신뢰성 문제로 다루는지에 관심 있는 엔지니어라면, 이런 레이어를 프로덕션에서 직접 운영하는 곳이 저희입니다.

---

출처: Headroom (headroom-ai), PyPI https://pypi.org/project/headroom-ai/ · GitHub https://github.com/chopratejas/headroom (작성자 Tejas Chopra). 본문 수치는 ThakiCloud repo 데이터로 직접 측정한 실측값입니다.
