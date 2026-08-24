---
title: "하네스 설계와 사후학습은 따로 놀 수 없다 - LLM 에이전트 성능을 좌우하는 하네스 인지 사후학습"
excerpt: "도구를 쓰는 LLM 에이전트는 모델을 감싸는 하네스 위에서 돕니다. 최근 arXiv 논문은 이 하네스 설계와 사후학습을 분리해서 다루면 성능이 무너진다는 점을, 특히 도구 환경이 바뀌는 상황에서 실증합니다. 하네스를 일급 리소스로 다루는 관점에서 이 결과를 풀어봅니다."
seo_title: "하네스 설계와 사후학습의 상호작용 - LLM 에이전트 하네스 인지 학습 - Thaki Cloud"
seo_description: "The Interplay of Harness Design and Post-Training in LLM Agents(arXiv:2606.25447) 정리. 하네스 정보량이 제로샷과 사후학습 성능을 함께 끌어올리고, 도구 환경 변화(OOD)에서 하네스 인지 사후학습만이 견고하게 일반화한다는 발견을, 에이전트 네이티브 클라우드와 추론·학습 인프라 관점에서 해석합니다."
date: 2026-07-20
last_modified_at: 2026-07-20
canonical_url: "https://thakicloud.com/tech-blog/ko/research/harness-design-post-training/"
lang: ko
reading_time: true
tags:
  - agent-harness
  - harness-engineering
  - post-training
  - tool-use
  - llm-agents
  - ood-generalization
  - agent-native-cloud
  - rlvr
author_profile: true
toc: true
categories:
  - research
---

에이전트를 직접 운영하거나, 도구 호출이 많은 워크플로를 붙여 본 엔지니어라면 한 가지 경험을 공유할 겁니다. 같은 베이스 모델을 쓰는데도 어떤 스캐폴딩(도구 목록, 도구 설명, 관측에 붙는 힌트) 위에 올리느냐에 따라 에이전트가 눈에 띄게 달라진다는 것입니다. 이 스캐폴딩을 최근에는 하네스(harness)라고 부릅니다. 이 글은 2026년 6월 공개된 논문 [The Interplay of Harness Design and Post-Training in LLM Agents](https://arxiv.org/abs/2606.25447)(arXiv:2606.25447)를 바탕으로, 하네스를 잘 짜는 것과 모델을 학습시키는 것이 왜 별개가 아닌지, 그리고 이 결과가 에이전트를 실제로 서빙하는 클라우드에 어떤 의미인지를 정리합니다. 결론을 먼저 말하면, 하네스는 학습이 끝난 뒤에 갈아 끼우는 부품이 아니라 학습 단계부터 함께 설계해야 하는 요소입니다.

## 개요: 왜 지금 하네스인가

지난 몇 달 사이 "모델보다 모델을 둘러싼 코드가 더 중요하다"는 주장이 부쩍 자주 보입니다. 도구를 쓰는 에이전트에서는 모델 가중치만큼이나 도구를 어떻게 노출하고 설명하는지, 매 스텝마다 무엇을 관측으로 돌려주는지가 최종 성능을 좌우하기 때문입니다. 같은 주제를 다룬 서베이 [From Question Answering to Task Completion](https://arxiv.org/abs/2606.20683)도 하네스 설계를 에이전트 시스템의 독립된 연구 축으로 정리합니다.

문제는 그동안 이 두 가지, 즉 하네스 설계와 사후학습(post-training)이 서로 다른 팀의 일처럼 다뤄졌다는 데 있습니다. 리서치 팀은 강화학습으로 정책을 다듬고, 플랫폼 팀은 도구와 프롬프트를 손봅니다. 이 논문의 기여는 그 분업이 틀렸음을 보이는 데 있습니다. 하네스의 정보량과 사후학습은 곱셈처럼 얽혀 있어서, 한쪽만 최적화하면 다른 쪽의 이득을 대부분 흘려버립니다. ThakiCloud처럼 하네스를 일급 리소스로 다루는 플랫폼 입장에서 이 발견은 곧 운영 원칙으로 번역됩니다.

## 하네스란 무엇이고 어디서 성능이 갈리는가

논문은 하네스를 "모델을 감싸는 스캐폴딩"으로 정의합니다. 구체적으로는 어떤 도구를 노출할지, 그 도구를 어떻게 설명할지, 그리고 매 스텝의 관측에 어떤 보조 정보를 함께 실어 줄지를 결정하는 층입니다. 도구 호출 에이전트의 한 사이클을 그리면 다음과 같습니다.

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
<div class="d3-arch" data-arch-root id="arnessdesignposttraining-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 807, "height": 844, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [{"x": 230, "y": 24, "w": 545, "h": 140, "label": "하네스: 모델을 감싸는 스캐폴딩", "lx": 242, "ly": 42}], "nodes": [{"id": "U", "x": 73, "y": 71, "w": 120, "h": 46, "title": "사용자 과제"}, {"id": "H", "x": 73, "y": 242, "w": 120, "h": 46, "title": "H"}, {"id": "T", "x": 268, "y": 71, "w": 120, "h": 46, "title": "노출할 도구 집합 선택"}, {"id": "D", "x": 443, "y": 71, "w": 120, "h": 46, "title": "도구 설명과 시그니처"}, {"id": "O", "x": 618, "y": 63, "w": 120, "h": 62, "title": ["매 스텝 관측에 붙는", "보조 정보와 힌트"]}, {"id": "M", "x": 73, "y": 518, "w": 120, "h": 46, "title": "LLM 정책 모델"}, {"id": "A", "x": 297, "y": 642, "w": 120, "h": 46, "title": "도구 호출과 행동"}, {"id": "E", "x": 73, "y": 766, "w": 120, "h": 46, "title": "환경 관측 반환"}, {"id": "R", "x": 122, "y": 642, "w": 120, "h": 46, "title": "과제 완료"}, {"id": "PT", "x": 24, "y": 380, "w": 120, "h": 46, "title": "정책 사후학습 단계"}], "edges": [{"src": "U", "dst": "H", "kind": "data", "line": [133, 117, 133, 242]}, {"src": "H", "dst": "M", "kind": "data", "curve": [[149, 288], [182, 334], [182, 472], [149, 518]]}, {"src": "M", "dst": "A", "kind": "data", "curve": [[193, 558], [357, 603], [357, 603], [357, 642]]}, {"src": "A", "dst": "E", "kind": "data", "curve": [[357, 688], [357, 727], [357, 727], [193, 772]]}, {"src": "E", "dst": "M", "kind": "data", "curve": [[115, 766], [84, 727], [84, 603], [115, 564]]}, {"src": "M", "dst": "R", "kind": "data", "curve": [[151, 564], [182, 603], [182, 603], [182, 642]]}, {"src": "H", "dst": "PT", "kind": "event", "label": "하네스 인지 사후학습", "curve": [[117, 288], [84, 334], [84, 334], [84, 380]], "off": "50%"}, {"src": "PT", "dst": "M", "kind": "event", "label": "하네스와 함께 학습된 정책", "curve": [[84, 426], [84, 472], [84, 472], [117, 518]], "off": "50%"}]});
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
      const container = document.getElementById('arnessdesignposttraining-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'arnessdesignposttraining-1';
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

여기서 핵심 변수는 하네스의 정보량(informativeness)입니다. 정보량이 높은 하네스는 도구를 풍부하게 설명하고 관측에 유용한 힌트를 실어 주므로, 모델이 사전 지식에 덜 의존하고도 올바른 도구를 고르도록 돕습니다. 정보량이 낮은 하네스는 반대로 최소한의 시그니처만 던져 주고 나머지를 모델의 추론에 맡깁니다. 이 차이가 학습과 만나면서 결과가 갈립니다.

## 이 논문이 뒤집은 통념

에이전트를 다뤄 본 사람들이 은연중에 가진 가정이 하나 있습니다. 좋은 하네스는 배포 직전에 얹으면 된다는 것입니다. 모델은 모델대로 잘 학습시키고 하네스는 나중에 도구 설명을 다듬어 붙이면 성능이 올라간다는 기대입니다. 논문은 이 가정을 정면으로 반박합니다.

첫째, 제로샷(추가 학습 없이 프롬프트만으로) 상황에서도 하네스 정보량이 높아질수록 성능이 단조롭게 개선되며 이 효과는 고용량 모델에서 더 뚜렷합니다. 정보가 풍부한 하네스에 담긴 사전 지식이 곧 성능이라는 뜻입니다.

둘째, 그리고 더 중요한 발견은 사후학습과의 상호작용입니다. 하네스를 학습 단계에 함께 넣고 훈련한 모델과, 학습이 끝난 뒤에 같은 하네스를 얹은 모델을 비교하면, 후자는 전자가 누린 이득의 극히 일부만 회복합니다. 즉 하네스 인지 사후학습(harness-aware post-training)은 성능을 얹어 주는 부가물이 아니라, 견고한 성능을 얻기 위한 전제 조건입니다. 하네스를 학습 이후에 갈아 끼우는 접근은 반쪽짜리라는 것입니다.

## 진짜 차이는 도구 환경이 바뀔 때 드러난다

가장 실무적인 결과는 분포 밖(OOD) 실험에서 나옵니다. 여기서 OOD란 학습 때 보지 못한 도구 환경, 예를 들어 도구가 추가·교체되거나 API 시그니처가 달라진 상황을 말합니다. 실제 운영에서는 이런 변화가 상수입니다. 도구는 계속 늘고 버전은 올라가며 테넌트마다 노출되는 도구 집합이 다릅니다.

논문은 두 갈래를 비교합니다. 정보량이 높은 하네스로 하네스 인지 사후학습을 한 에이전트는 도구 환경이 크게 바뀌어도 견고하게 버티고 과제 그룹을 가로질러 일반화합니다. 반면 설계 노력이 낮은 하네스로 학습한 에이전트는 도구 환경 변화가 강해질수록 성능이 급락하고 새로운 환경으로 전이하지 못합니다. 다시 말해 하네스에 담긴 사전 지식이 일반화의 앵커 역할을 합니다. 잘 설계된 하네스와 함께 학습한 정책은 낯선 도구 앞에서도 무엇을 어떻게 부를지에 대한 감을 유지하지만 빈약한 하네스로 학습한 정책은 그 감을 통째로 잃습니다.

이 대목이 클라우드 운영자에게 특히 뼈아픕니다. 벤치마크에서 잘 나온 에이전트가 프로덕션에서 무너지는 전형적인 이유가 바로 도구 환경 이동이기 때문입니다. 그리고 이 논문은 그 취약성이 상당 부분 하네스 설계 단계에서 이미 결정된다고 말합니다.

## ThakiCloud 제품 적용 시사점

이 발견은 ThakiCloud의 두 제품 축 모두와 맞닿아 있어서 하나의 렌즈로만 보면 절반을 놓칩니다.

첫 번째는 **Paxis 렌즈**입니다. Paxis는 ai-platform 위에서 도는 Agent-Native Cloud 제어 평면으로, Skills·Tools·Policies·Audit Logs를 일급 리소스로 다룹니다. 이 논문의 언어로 옮기면 Paxis의 Skill Harness가 바로 여기서 말하는 하네스입니다. 960여 개 스킬을 BM25로 선택해 노출 도구 집합을 정하고 각 스킬의 설명과 시그니처를 정돈하며 격리 샌드박스 실행 결과를 관측으로 되돌려 주는 과정 전체가 하네스 정보량을 결정합니다. 논문의 결론은 Paxis 설계 원칙을 뒷받침합니다. 스킬을 무작정 많이 노출하는 것이 아니라 과제에 맞게 선택해 정보량 높은 하네스를 구성하는 편이, 그리고 그 하네스를 학습·평가 루프와 함께 진화시키는 편이 낯선 도구 환경에서 견고함으로 이어지기 때문입니다. 정책 게이트와 감사 로그로 모든 행동을 통과시키는 구조도, 하네스를 실험 대상이자 버전 관리 대상으로 유지하려는 같은 문제의식의 연장선에 있습니다.

두 번째는 **ai-platform 렌즈**입니다. 하네스 인지 사후학습이 전제 조건이라는 결론은, 학습과 서빙을 한 인프라 안에서 붙여 두는 것의 가치를 높입니다. ai-platform은 K8s와 Kueue 기반 GPU 스케줄링 위에서 파인튜닝·RLVR 같은 사후학습 워크로드와 vLLM 추론 서빙을 함께 운용합니다. 하네스를 학습 시점에 반영하려면, 서빙에서 쓰는 도구 스키마와 관측 포맷을 학습 파이프라인이 그대로 참조할 수 있어야 합니다. 학습과 서빙이 다른 조직·다른 스택으로 분리돼 있으면 하네스가 어긋나고 논문이 경고한 "학습 후 하네스 교체"의 반쪽 이득에 갇힙니다. 멀티테넌트 환경에서 테넌트별로 다른 도구 집합을 노출하면서도 온프렘·소버린 요건을 지켜 self-hosting으로 학습·서빙을 한 울타리 안에 두는 구성은, 이 하네스-학습 정합을 지키기에 유리한 자리입니다.

두 렌즈는 서로를 보완합니다. Paxis가 하네스를 일급 리소스로 관리해 정보량과 버전을 통제하고 ai-platform이 그 하네스를 학습 루프에 흘려 넣어 하네스 인지 사후학습을 현실로 만듭니다.

## 한계 및 반론

이 논문의 결과를 과대 해석하지 않으려면 몇 가지를 함께 봐야 합니다.

먼저 "하네스 정보량을 높일수록 좋다"는 명제에는 비용이 딸려 옵니다. 관측에 힌트를 많이 실을수록 컨텍스트가 길어지고 도구 설명이 풍부할수록 프롬프트 토큰과 지연이 늘어납니다. 서빙 관점에서 정보량은 공짜가 아니며 처리량과의 트레이드오프를 함께 봐야 합니다. 논문이 말하는 정보량은 "무조건 더 많이"가 아니라 "과제에 유용한 사전 지식을 담는가"에 가깝게 읽는 편이 안전합니다.

또한 하네스 인지 사후학습은 학습 파이프라인을 손봐야 한다는 진입 비용을 요구합니다. 이미 만들어진 오픈웨이트 모델을 그대로 쓰는 다수의 실무에서는, 하네스만 다듬는 제로샷 개선이 여전히 현실적인 첫 수입니다. 논문 자신도 제로샷에서 정보량이 성능을 끌어올린다고 밝히므로, 학습 여력이 없는 팀에게는 이쪽이 합리적인 출발점입니다.

마지막으로, 논문의 OOD 실험이 다루는 도구 환경 이동이 실제 프로덕션의 변화 폭을 모두 대표한다고 단정하기는 어렵습니다. 벤치마크상의 도구 교체와, 수십 개 테넌트가 각자 API를 갱신하는 운영 환경 사이에는 간극이 있습니다. 그럼에도 방향성, 즉 "하네스를 학습과 함께 설계한 에이전트가 변화에 강하다"는 결론은, 도구가 끊임없이 바뀌는 실제 클라우드일수록 오히려 더 크게 작동할 가능성이 높습니다.

정리하면, 이 논문은 하네스를 배포 직전에 얹는 마감재가 아니라 학습 첫 단계부터 함께 설계하는 구조로 다루라고 말합니다. 하네스를 일급 리소스로 관리하고 학습과 서빙을 한 인프라 안에 두려는 방향은 그 권고와 정확히 같은 곳을 가리킵니다.

## 출처

- The Interplay of Harness Design and Post-Training in LLM Agents, arXiv:2606.25447: <https://arxiv.org/abs/2606.25447>
- From Question Answering to Task Completion: A Survey on Agent System and Harness Design, arXiv:2606.20683: <https://arxiv.org/abs/2606.20683>
