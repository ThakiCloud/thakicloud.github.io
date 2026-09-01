---
title: "LLM으로 법률을 물을 때 가짜 조문을 막는 법: 국가법령정보 Open API로 답을 근거에 묶기"
excerpt: "ChatGPT나 Claude에 법을 물으면 그럴듯한 가짜 조문이 튀어나올 때가 있습니다. 문제는 모델의 지능이 아니라 답을 검증된 원문에 묶지 않은 설계입니다. 법제처 국가법령정보 Open API를 근거원으로 삼아 LLM 법률 답변을 인용 기반으로 바꾸는 방법을, 서빙 관점에서 정리했습니다."
date: 2026-07-22
tags:
  - RAG
  - 근거기반생성
  - 법률AI
  - LLM환각
  - 인용
  - 국가법령정보
  - LLMOps
  - 온프렘
  - self-hosting
  - paxis
author_profile: true
toc: true
toc_label: 법률 LLM 근거 설계
lang: ko
categories:
  - llmops
canonical_url: "https://thakicloud.com/tech-blog/ko/llmops/llm-legal-grounding-korean-law-api/"
---

![검증된 원문에 답을 묶는 근거 기반 파이프라인]({{ '/assets/images/llm-legal-grounding-korean-law-api-hero.webp' | relative_url }})

## 왜 읽어야 하나

이 글은 LLM에 법률·규정 질문을 붙이려는 개발자와, 고위험 도메인의 답변 품질을 책임지는 인프라 담당자를 위해 썼습니다. 법률 질의에서 LLM이 가짜 조문을 지어내는 문제는 모델을 더 큰 것으로 바꾼다고 풀리지 않습니다. 답을 검증된 법령 원문에 묶는 근거 기반(RAG) 설계라야 풀립니다. 법제처가 공개한 국가법령정보 Open API를 근거원으로 붙이면 모델이 조문을 지어내는 대신 실제 조항 번호와 시행일을 인용하게 만들 수 있습니다.

## 개요

한 소셜 타임라인에서 "ChatGPT나 Claude로 법률 자문을 받고 싶은데 가짜 조문을 만들어낼까 걱정된다면 국내 법령 데이터를 쓰라"는 팁이 돌았습니다. 걱정에는 근거가 있습니다. 미국에서는 ChatGPT가 자격 없이 법률 자문을 제공하도록 방치했다는 이유로 OpenAI를 상대로 한 소송이 제기됐고, Forbes 보도는 법적 문제를 챗봇과 그냥 상의하는 것 자체가 위험할 수 있다고 지적합니다. 모델은 문장을 그럴듯하게 완성하는 데 최적화돼 있을 뿐이라, 존재하지 않는 조문을 실제 조문처럼 써 내려가는 것을 스스로 막지 못합니다.

그런데 같은 시장에서 정반대 신호도 나옵니다. 한국에서는 Claude가 유료 생성형 AI 시장에서 ChatGPT를 처음으로 앞질렀고, 법률 스타트업 로앤컴퍼니는 Claude를 얹은 AI 법률 비서 SuperLawyer로 출시 180일 만에 국내 변호사의 약 20%에 해당하는 6,000명을 확보했다고 밝혔습니다. 같은 기술을 두고 한쪽은 위험하다 하고 다른 쪽은 실무에 안착시켰다면 차이는 모델이 아니라 답을 다루는 설계에 있는 셈입니다. 이 글은 그 설계, 즉 LLM의 법률 답변을 검증된 원문에 묶는 근거 기반 파이프라인을 국가법령정보 Open API로 뜯어봅니다.

## 이 기술은 무엇인가

핵심 개념은 단순합니다. 모델에게 "법이 뭐라고 하는지 아느냐"고 묻는 대신 "이 질문에 관련된 조문을 먼저 찾아 온 뒤 그 원문만 근거로 답하라"고 시키는 것입니다. 검색이 답의 재료를 공급하면 생성은 그 재료 안에서만 이뤄집니다. 모든 주장에는 조항 번호와 시행일이라는 인용이 붙고, 모델이 상상으로 채우던 빈칸은 검증된 텍스트로 바뀝니다.

이때 재료의 신뢰도가 품질을 좌우합니다. 아무 웹 문서나 긁어 온 법령 요약본은 개정 전 조문이거나 출처가 불명확할 수 있습니다. 그래서 근거원은 권위 있는 원본이어야 합니다. 법제처의 국가법령정보 공동활용 Open API는 현행 법령 본문, 조항 번호, 시행일, 개정 이력, 소관 부처를 구조화된 형태로 제공합니다. 특정 날짜 기준으로 그날 효력이 있던 법령을 조회하는 기능도 있어서 "지금 유효한 조문"과 "당시 유효했던 조문"을 구분해 인용할 수 있습니다. 법률 질의에서 시행일 구분은 사소한 디테일이 아니라 답의 정오를 가르는 축입니다.

전체 흐름을 세로로 정리하면 다음과 같습니다.

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
<div class="d3-arch" data-arch-root id="galgroundingkoreanlawapi-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 282, "height": 1096, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "Q", "x": 38, "y": 24, "w": 135, "h": 62, "title": ["사용자 질문", "예: 계약 해지 위약금 상한"]}, {"id": "R", "x": 46, "y": 164, "w": 120, "h": 62, "title": ["질의 정규화", "쟁점·키워드 추출"]}, {"id": "S", "x": 38, "y": 304, "w": 135, "h": 62, "title": ["국가법령정보 Open API", "관련 조문 검색"]}, {"id": "F", "x": 112, "y": 444, "w": 120, "h": 62, "title": ["필터", "시행일·현행 여부 확인"]}, {"id": "C", "x": 94, "y": 584, "w": 156, "h": 62, "title": ["컨텍스트 조립", "조문 원문 + 조항번호 + 시행일"]}, {"id": "G", "x": 111, "y": 724, "w": 121, "h": 62, "title": ["LLM 생성", "제공된 조문만 근거로 답"]}, {"id": "V", "x": 38, "y": 864, "w": 135, "h": 62, "title": ["인용 검증 게이트", "모든 주장에 조항 매핑 확인"]}, {"id": "A", "x": 46, "y": 1018, "w": 120, "h": 46, "title": "답변 + 조항 인용"}], "edges": [{"src": "Q", "dst": "R", "kind": "data", "line": [106, 86, 106, 164]}, {"src": "R", "dst": "S", "kind": "data", "line": [106, 226, 106, 304]}, {"src": "S", "dst": "F", "kind": "data", "curve": [[135, 366], [172, 405], [172, 405], [172, 444]]}, {"src": "F", "dst": "C", "kind": "data", "line": [172, 506, 172, 584]}, {"src": "C", "dst": "G", "kind": "data", "line": [172, 646, 172, 724]}, {"src": "G", "dst": "V", "kind": "data", "curve": [[172, 786], [172, 825], [172, 825], [135, 864]]}, {"src": "V", "dst": "S", "kind": "data", "label": "매핑 실패", "curve": [[77, 864], [40, 685], [40, 475], [77, 366]], "off": "50%"}, {"src": "V", "dst": "A", "kind": "data", "label": "매핑 성공", "line": [106, 926, 106, 1018], "lx": 106, "ly": 968}]});
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
      const container = document.getElementById('galgroundingkoreanlawapi-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'galgroundingkoreanlawapi-1';
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

기존 접근과의 차이는 검증 게이트에 있습니다. 단순 RAG는 검색한 문서를 프롬프트에 붙이고 답을 받는 데서 멈춥니다. 고위험 도메인에서는 여기에 한 단계를 더 얹습니다. 생성된 답의 모든 법적 주장이 실제로 검색해 온 조문에 매핑되는지 코드로 검사합니다. 매핑되지 않는 주장이 하나라도 있으면 그 답은 사용자에게 나가지 않습니다. 이 게이트가 "모델이 근거 밖에서 지어낸 문장"을 걸러 내는 마지막 방벽 역할을 합니다.

## 설치 및 통합

근거원을 붙이는 첫 단계는 API 키 발급입니다. 국가법령정보 공동활용 포털(open.law.go.kr)에서 사용자 등록 후 인증키를 받습니다. 이후 조문 검색과 본문 조회는 URL 기반 호출로 이뤄지며, 공식 가이드는 Python과 Node.js를 포함한 여러 언어의 예시를 제공합니다.

아래는 특정 쟁점 키워드로 현행 법령을 조회한 뒤, 그 원문만 컨텍스트로 조립하는 최소 패턴입니다. 실제 응답 스키마와 파라미터는 포털의 활용가이드를 기준으로 삼습니다.

```python
import requests

LAW_API = "https://www.law.go.kr/DRF/lawSearch.do"

def search_statutes(keyword: str, oc_key: str) -> list[dict]:
    """국가법령정보 Open API로 현행 법령 검색. 조항 원문을 근거원으로 반환."""
    params = {
        "OC": oc_key,          # 발급받은 인증키
        "target": "law",       # 법령 검색
        "type": "JSON",
        "query": keyword,
        "display": 5,
    }
    resp = requests.get(LAW_API, params=params, timeout=10)
    resp.raise_for_status()
    return resp.json().get("LawSearch", {}).get("law", [])

def build_context(hits: list[dict]) -> str:
    """검색된 조문을 인용 가능한 컨텍스트로 조립. 시행일·소관부처를 함께 실어 근거를 명시."""
    lines = []
    for h in hits:
        lines.append(
            f"[{h.get('법령명한글')}] "
            f"시행일 {h.get('시행일자')}, 소관 {h.get('소관부처명')}\n"
            f"{h.get('법령상세링크')}"
        )
    return "\n\n".join(lines)
```

이 컨텍스트를 프롬프트에 실을 때는 지시를 분명히 못 박습니다. "아래 제공된 조문만 근거로 답하고, 제공되지 않은 조문은 인용하지 말라. 관련 조문이 없으면 없다고 답하라." 근거가 없을 때 "없다"고 말하게 만드는 지시가 환각을 막는 핵심입니다. 모델이 빈칸을 지어내는 대신 정직하게 비워 두게 하는 것입니다.

마지막으로 검증 게이트를 코드로 소유합니다. 생성된 답에서 인용된 조항 번호를 추출해, 실제로 컨텍스트에 실린 조문 목록과 대조합니다. 목록에 없는 조항을 인용했다면 그 답은 재검색 루프로 되돌립니다. 이 판정은 모델의 자기 보고가 아니라 결정론적 코드가 내려야 신뢰할 수 있습니다.

## 근거 기반 설계가 만드는 차이

직접 벤치마크를 돌려 새 수치를 만들지는 않았습니다. 대신 이미 공개된 실무 지표가 근거 기반 설계의 효과를 보여 줍니다. 로앤컴퍼니의 SuperLawyer는 Claude를 얹되 답을 판례와 법령에 묶는 방식으로 설계됐습니다. Anthropic이 공개한 고객 사례에 따르면 출시 180일 만에 6,000명의 변호사(국내 변호사의 약 20%)를 확보했고, 무료에서 유료로의 전환율 60.2%, 2개월 차 재사용률 79.1%, 첫 180일 동안 누적 230만 시간 절감을 기록했습니다. 전문가가 매일 검증하는 도구에서 이 정도의 유지율이 나왔다는 것은 답이 그럴듯한 수준을 넘어 실제로 신뢰할 만했다는 신호로 읽힙니다.

반대편에는 근거 없이 법을 답하게 뒀을 때의 비용이 있습니다. 미국의 OpenAI 소송과 "법적 문제를 챗봇과 상의하지 말라"는 경고는 근거 게이트 없는 법률 답변이 법적 책임 문제로까지 번질 수 있음을 보여 줍니다. 같은 모델이라도 원문에 묶었는가 아닌가에 따라 결과가 이렇게 갈립니다. 지표가 말하는 교훈은 명확합니다. 고위험 도메인에서 품질을 끌어올리는 지렛대는 모델 등급이 아니라 근거 설계입니다.

## ThakiCloud 제품 적용 시사점

이 패턴은 ThakiCloud의 두 제품에 자연스럽게 맞물립니다.

Paxis 관점에서 보면 근거 기반 법률 답변은 Agent-Native Cloud가 다루는 전형적인 워크로드입니다. Paxis는 Skills, Tools, Policies, Audit Logs를 일급 리소스로 취급합니다. 법령 검색은 격리 샌드박스에서 실행되는 Tool에 해당합니다. 인용 검증 게이트는 답을 내보내기 전에 통과해야 하는 Policy로 걸리고, 어떤 조문을 근거로 어떤 답을 냈는지는 Audit Log에 남습니다. 법률처럼 책임 소재가 중요한 도메인에서는 "왜 이렇게 답했는가"를 사후에 추적할 수 있어야 하는데, 정책 게이트와 감사 로그가 그 추적성을 기본으로 제공합니다. 모든 주장에 조항 인용을 강제하는 근거 게이트 자체를 재사용 가능한 스킬로 묶어 두면 법률뿐 아니라 의료·금융·규정 준수처럼 원문 인용이 필요한 다른 고위험 도메인에도 그대로 옮겨 쓸 수 있습니다.

ai-platform 관점도 있습니다. 법령이나 판례 같은 데이터는 외부 API로 나가는 것 자체가 민감할 수 있고, 공공·규제 기관은 데이터 주권과 온프렘 서빙을 요구하는 경우가 많습니다. ThakiCloud의 ai-platform은 K8s와 Kueue 기반 GPU 스케줄링 위에서 모델을 멀티테넌트로 서빙하며, 자체 인프라에서 근거원과 모델을 함께 운용하도록 설계돼 있습니다. 법령 데이터를 내부에 두고 그 위에서 검색과 생성을 모두 돌리면, 근거 기반의 정확성과 데이터 주권을 동시에 지킬 수 있습니다. 낮은 서빙 비용은 이런 도메인 특화 파이프라인을 상시 운용할 수 있게 하는 전제 조건입니다.

## 한계 및 반론

근거 기반 설계도 만능은 아닙니다. 가장 먼저 걸리는 문제는 근거원의 신선도입니다. 국가법령정보 데이터가 개정을 즉시 반영하더라도 파이프라인이 캐시한 스냅샷이 오래됐다면 폐지된 조문을 인용할 위험이 남고, 시행일 필터와 정기 동기화 없이는 이 문제를 막기 어렵습니다. 조문을 정확히 인용한다고 그 해석까지 옳다는 보장도 없습니다. 법률 자문의 본질은 조문 검색이 아니라 사안에 대한 적용이고, 그 판단은 여전히 자격 있는 전문가의 몫입니다. 이 파이프라인은 전문가를 대체하는 도구가 아니라 초안을 근거 위에 세우는 보조 도구로 봐야 합니다. 검증 게이트에도 한계는 있습니다. 인용 매핑만 검사한다면 조문은 맞게 인용했지만 논리를 잘못 편 답을 그대로 통과시킬 수 있습니다. 게이트는 환각의 하한선을 지킬 뿐, 논증의 품질까지 보증하지는 못합니다.

## 정리

LLM에 법을 물을 때 가짜 조문이 나오는 문제는 모델의 한계가 아니라 설계의 공백입니다. 답을 검증된 원문에 묶고 근거가 없으면 없다고 말하게 하는 데다, 모든 주장에 인용을 강제하는 게이트까지 코드로 소유하면 같은 모델도 전혀 다른 신뢰도를 냅니다. 한국에서 Claude를 얹은 법률 도구가 실무에 안착한 것과 근거 없는 챗봇 자문이 소송으로 번진 것의 차이가 바로 여기서 갈립니다. 고위험 도메인에 LLM을 붙이려 한다면 더 큰 모델을 찾기 전에 국가법령정보 Open API 같은 권위 있는 근거원부터 연결하고 인용 검증 게이트를 세우시기 바랍니다. 근거 설계가 먼저입니다.

## 출처

- [법제처 국가법령정보 공동활용 Open API](https://open.law.go.kr/LSO/openApi/guideList.do)
- [법제처 국가법령정보 공유서비스 (공공데이터포털)](https://www.data.go.kr/data/15000115/openapi.do)
- [Anthropic 고객 사례: Law&Company](https://www.anthropic.com/customers/law-and-company)
- [KED Global: Claude, 한국 유료 생성형 AI 시장에서 ChatGPT 추월](https://www.kedglobal.com/artificial-intelligence/newsView/ked202604270002)
- [Forbes: OpenAI 법률 자문 관련 소송](https://www.forbes.com/sites/lanceeliot/2026/03/09/landmark-lawsuit-against-openai-for-allowing-chatgpt-to-provide-legal-advice-could-be-a-huge-game-changer-for-all-ai-makers/)
