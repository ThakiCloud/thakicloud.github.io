---
title: "묘사가 아니라 결정을 기억하라: 에이전트 메모리를 율-왜곡 문제로 다시 푼 Meta 참여 연구"
excerpt: "장기 실행 에이전트는 제한된 메모리 안에서 움직이지만, 지금까지의 메모리 기법은 관련성이나 요약 품질 같은 묘사적 기준으로 과거를 조직했습니다. Meta AI 연구자가 참여한 이 논문은 그 기준 자체가 틀렸다고 말합니다. 메모리의 가치는 과거를 충실히 묘사하는 데 있지 않고, 서로 다른 행동을 요구하는 상황을 고정 예산 안에서도 분리해 두는 데 있습니다. 저자들은 이를 결정 중심 율-왜곡 문제로 정식화하고 DeMem이라는 학습기를 제안해, 같은 메모리 예산에서 기존 기법들을 일관되게 앞섰습니다."
tags:
  - agent-memory
  - rate-distortion
  - long-horizon-agents
  - llm-agents
  - paxis
date: 2026-07-11
lang: ko
canonical_url: "https://thakicloud.com/tech-blog/ko/research/demem-agent-memory/"
categories:
  - research
audiobook: /assets/audio/posts/demem-agent-memory/audiobook-ko.mp3
audiobook_note: "AI 로컬 합성 오디오북 (Qwen3-TTS)"
published: false
---

![서로 다른 결정으로 이어지는 기억들이 분리된 경로로 갈라지는 모습을 표현한 추상 일러스트]({{ '/assets/images/demem-agent-memory-hero.webp' | relative_url }})

> 📄 **심층 리뷰 전문(DOCX)**: 이 논문의 상세 피어리뷰를 [Google Drive에서 다운로드](https://drive.google.com/file/d/1oxsADQALTfdn7I_mmZbaZfMnmqoCMF9o/view)할 수 있습니다.

## 개요

대화형 에이전트를 오래 굴려 본 사람이라면 익숙한 실패가 있습니다. 며칠 전에 사용자가 분명히 밝힌 선호나 결정을, 에이전트가 어느 순간 잊어버리고 반대로 행동하는 것입니다. 컨텍스트 창은 유한하고, 대화가 길어지면 과거 어딘가는 반드시 압축되거나 버려져야 합니다. 문제는 "무엇을 버릴 것인가"입니다.

지금까지의 에이전트 메모리는 이 질문에 대체로 **묘사적 기준**으로 답해 왔습니다. 관련성이 높은가, 현저한가, 요약이 잘 되는가. Meta AI의 연구자가 공동 저자로 참여한 이번 논문 「Remember the Decision, Not the Description」(arXiv 2605.10870)은 바로 이 기준 자체가 잘못됐다고 주장합니다. 이 글은 AI 에이전트를 설계하는 엔지니어와 연구자, 그리고 장기 메모리를 프로덕션에 얹어야 하는 팀을 위한 것입니다. 논문의 핵심 재정의와 그것을 뒷받침하는 실측 결과를 정리하고, 이 원리가 ThakiCloud의 에이전트 플랫폼 Paxis에 어떻게 적용되는지 살펴봅니다.

## 무엇이 문제인가

저자들의 출발점은 단순한 통찰입니다. 에이전트에게 메모리가 가치 있는 이유는 과거를 충실히 묘사하기 때문이 아니라, **서로 다른 행동을 요구하는 두 이력을 고정된 예산 안에서도 분리해 두기 때문**입니다.

간단한 예를 들어 보겠습니다. 사용자가 어제는 "이번 배포는 반드시 수동 승인 후에만 진행하라"고 했고, 오늘은 비슷한 문맥에서 "이 스크립트는 자동으로 돌려도 된다"고 했다고 합시다. 두 발화는 표면적으로 매우 유사합니다. 배포, 실행, 승인이라는 단어가 겹치고 요약하면 거의 같은 문장이 됩니다. 관련성 기반 메모리는 이 둘을 하나로 뭉쳐 "배포 관련 지시" 한 덩어리로 저장하기 쉽습니다. 그 순간 에이전트는 어느 쪽이 어느 상황에 적용되는지를 잃어버리고, 수동 승인이 필요한 배포를 자동으로 밀어붙이는 사고를 냅니다. 묘사적으로는 옳은 요약이지만 결정적으로는 치명적인 병합입니다.

구체적인 실패 모드는 이렇습니다. 두 상황이 텍스트상으로는 비슷하게 보이지만 실제로는 상반된 조치를 요구한다고 합시다. 메모리 예산이 빠듯하면 압축이 필요하고, 압축은 필연적으로 병합을 부릅니다. 이때 묘사적 유사도만 보면 이 둘을 하나로 합치게 됩니다. 그 결과 에이전트는 그 상태에 도달할 때마다 지속적으로 잘못된 결정을 내립니다. 관련성이나 요약 품질은 "이 둘을 합쳐도 되는가"라는 진짜 질문에 답하지 못합니다. 무엇이 비슷해 보이는지가 아니라, 무엇이 다르게 행동해야 하는지가 기준이 되어야 합니다.

## 핵심 아이디어: 결정 중심 율-왜곡

저자들은 이 문제를 정보이론의 율-왜곡(rate-distortion) 틀로 옮깁니다. 율-왜곡은 원래 "얼마나 압축하면(rate) 얼마나 왜곡(distortion)이 생기는가"를 다루는 이론인데, 여기서 왜곡의 정의를 바꾸는 것이 핵심입니다. 왜곡을 신호의 재구성 오차가 아니라 **압축이 유발하는 달성 가능한 결정 품질의 손실(decision loss)**로 정의합니다.

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
<div class="d3-arch" data-arch-root id="20260711dememagentmemory-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 427, "height": 792, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 155, "y": 24, "w": 120, "h": 62, "title": ["긴 상호작용 이력", "(고정 메모리 예산)"]}, {"id": "B", "x": 146, "y": 164, "w": 138, "h": 52, "title": "두 상황을 병합할까?"}, {"id": "C", "x": 246, "y": 294, "w": 149, "h": 62, "title": ["묘사 중심 기준", "관련성 · 현저성 · 요약 품질"]}, {"id": "D", "x": 28, "y": 294, "w": 163, "h": 62, "title": ["결정 중심 기준", "같은 상태가 결정 충돌을 유발하는가"]}, {"id": "E", "x": 253, "y": 434, "w": 135, "h": 62, "title": ["비슷해 보이면 병합", "→ 상반된 행동을 합쳐 버림"]}, {"id": "F", "x": 260, "y": 582, "w": 120, "h": 46, "title": "지속적 결정 오류"}, {"id": "G", "x": 24, "y": 434, "w": 170, "h": 62, "title": ["결정 충돌이 증명될 때만 분리", "certified refinement"]}, {"id": "H", "x": 49, "y": 574, "w": 121, "h": 62, "title": ["정확한 망각 경계", "+ 메모리-왜곡 프론티어"]}, {"id": "I", "x": 31, "y": 714, "w": 156, "h": 46, "title": "같은 예산에서 더 나은 결정 품질"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [215, 86, 215, 164]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[257, 216], [320, 255], [320, 255], [320, 294]]}, {"src": "B", "dst": "D", "kind": "data", "curve": [[172, 216], [109, 255], [109, 255], [109, 294]]}, {"src": "C", "dst": "E", "kind": "data", "line": [320, 356, 320, 434]}, {"src": "E", "dst": "F", "kind": "data", "line": [320, 496, 320, 582]}, {"src": "D", "dst": "G", "kind": "data", "line": [109, 356, 109, 434]}, {"src": "G", "dst": "H", "kind": "data", "line": [109, 496, 109, 574]}, {"src": "H", "dst": "I", "kind": "data", "line": [109, 636, 109, 714]}]});
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
      const container = document.getElementById('20260711dememagentmemory-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '20260711dememagentmemory-1';
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

비유하자면 이렇습니다. 오디오를 압축할 때 우리는 사람 귀에 안 들리는 주파수를 먼저 버립니다. 왜곡의 기준이 "사람이 듣는 소리"이기 때문입니다. 에이전트 메모리도 마찬가지여야 한다는 것이 저자들의 주장입니다. 버려야 할 것은 "덜 관련 있어 보이는 기억"이 아니라 "버려도 앞으로의 결정이 달라지지 않는 기억"입니다. 여기서 rate는 메모리 예산이고 distortion은 그 압축이 유발하는 결정 손실입니다. 두 상황을 같은 슬롯으로 묶었을 때 앞으로 잘못될 결정이 없다면, 그 병합은 무료입니다. 반대로 병합이 상반된 행동을 뭉갠다면 그것은 값비싼 왜곡입니다.

이 정의에서 두 가지가 따라 나옵니다. 첫째, **정확한 망각 경계(exact forgetting boundary)**입니다. 결정 품질을 해치지 않고 안전하게 잊을 수 있는 것의 경계를 정확히 규정합니다. 둘째, **메모리-왜곡 프론티어**입니다. 메모리 예산과 결정 품질 사이의 최적 트레이드오프 곡선을 특징짓습니다. 즉 "예산을 이만큼 줄이면 결정 품질이 최소한 이만큼은 떨어질 수밖에 없다"는 하한을 이론적으로 못 박습니다.

## DeMem: 이론을 알고리즘으로

이 이론을 실제 슬롯 기반 에이전트 메모리로 옮긴 것이 DeMem입니다. DeMem은 온라인 메모리 학습기로, 한 가지 원칙으로 작동합니다. **공유된 상태가 결정 충돌을 유발한다는 것을 데이터가 증명(certify)할 때만 메모리 파티션을 세분화합니다.**

여기서 "증명"이라는 조건이 중요합니다. 두 상황이 그저 달라 보인다고 해서 즉시 분리하는 것이 아니라, 같은 메모리 상태에서 서로 다른 결정이 필요하다는 증거가 실제로 쌓였을 때만 분리합니다. 반대로 그런 증거가 없으면 병합을 유지해 예산을 아낍니다. 이 보수성이 핵심입니다. 성급하게 분리하면 예산을 낭비해 정작 중요한 구분을 담을 자리가 없어지고, 성급하게 병합하면 상반된 행동을 뭉갭니다. certified refinement는 이 둘 사이에서 데이터가 말해 줄 때까지 기다리는 규율입니다. 저자들은 이 절차가 near-minimax regret 보장을 만족함을 증명합니다. 다시 말해 최악의 경우에도 최적 대비 후회가 이론적 한계에 가깝게 억제됩니다.

저자들은 이 메커니즘을 두 층위에서 검증합니다. 먼저 합성 진단 환경에서, 묘사적 유사도와 결정적 유사도가 일부러 어긋나도록 설계한 과제를 줍니다. 여기서 묘사만 보는 기준은 겉보기에 비슷한 상황을 계속 병합해 후회가 누적되는 반면, DeMem은 결정 충돌이 인증될 때만 세분화해 이 함정을 피합니다. 그다음 실제 장기 대화 벤치마크에서 이 우위가 상용 모델과 오픈웨이트 모델 양쪽으로 이전되는지를 확인합니다. 이론에서 시작해 통제된 메커니즘 검증을 거쳐 현실 벤치마크로 내려오는 이 구조가, 결과를 단순한 성능 표가 아니라 "왜 이기는가"에 대한 설명으로 만듭니다.

## 실험 결과

합성 진단에서 DeMem은 예산이 매칭된 모든 기법 중 누적 후회(cumulative regret)가 가장 낮았고, 묘사적 유사도와 결정적 유사도의 괴리가 커질수록 우위가 벌어졌습니다. 묘사만 보는 기준이 상반된 상황을 합쳐 지속적 오류를 내는 동안, DeMem은 결정 충돌이 증명될 때만 세분화해 이를 피했습니다.

실제 벤치마크에서도 결과가 이어졌습니다. LoCoMo(GPT-4.1-mini 백본)의 전체 점수 기준 실측치입니다.

| 기법 | Overall | Temporal |
|---|---|---|
| **DeMem** | **0.921** | **0.908** |
| Mnemis | 0.891 | 0.858 |
| EMem-G | 0.757 | 0.660 |
| Nemori | 0.731 | 0.454 |
| RAG | 0.710 | 0.634 |
| FullContext | 0.692 | 0.511 |
| Zep | 0.554 | 0.383 |
| Mem0 | 0.514 | 0.428 |

DeMem은 전체 점수에서 최고를 기록했고, 특히 먼 상호작용 사이의 구분 보존이 중요한 Temporal, Open-Domain, Multi-Hop 범주에서 강했습니다. 단일 사실을 회수하는 Single-Hop에서는 Mnemis(0.940)가 DeMem(0.935)을 근소하게 앞섰는데, 이는 단발 회수에서는 결정 중심 분리의 이점이 작다는 해석과 맞아떨어집니다. LongMemEval에서도 두 백본 모두에서 최고 평균 점수를 냈고, 크로스 세션 통합이 필요한 범주에서 이득이 가장 컸습니다. 특히 오픈웨이트 백본인 Llama-3.1-70B에서도 우위가 유지되어, 이 이점이 특정 상용 모델에 종속된 것이 아님을 보였습니다.

## ThakiCloud 제품 적용 시사점

이 논문의 통찰은 ThakiCloud의 Agent-Native Cloud 제어 평면인 Paxis의 메모리 설계와 정확히 맞닿습니다. Paxis는 ai-platform 위에서 도는 제어 평면으로 스킬, 도구, 정책, 감사 로그를 일급 리소스로 다루는데, 그 안의 지식 엔진과 메모리 계층이 바로 "무엇을 병합하고 무엇을 분리할 것인가"를 매일 결정합니다.

첫째, HKE 위키 지식 엔진의 병합 기준을 결정 중심으로 옮길 수 있습니다. 유사 항목을 텍스트 유사도만으로 병합하면, 상반된 조치를 요구하는 두 사례가 하나로 합쳐질 위험이 있습니다. 병합 직전에 "이 둘이 서로 다른 행동을 유발하는가"를 게이트로 두는 방식은 이 논문의 certified refinement를 그대로 옮긴 것입니다.

둘째, 세션 상주 핫 메모리의 예산 관리에 이론적 근거를 줍니다. 핫 메모리는 이미 문자 상한으로 예산을 강제하고 있는데, 무엇을 남기고 무엇을 버릴지의 기준을 "결정에 영향을 주는 구분을 보존한다"로 정렬하면 프루닝의 품질이 올라갑니다. 요약이 매끄러운 항목이 아니라, 결정을 가르는 항목을 우선 보존하는 것입니다.

셋째, Paxis가 남기는 정책 게이트와 감사 로그는 "같은 상태에서 다른 결정이 났다"를 사후에 증명할 수 있는 자연스러운 데이터원입니다. DeMem의 온라인 certified refinement를 실시간으로 돌리기 어렵다면, 이 감사 로그를 오프라인 배치로 분석해 병합/분리 정책을 주기적으로 갱신하는 실용 경로를 택할 수 있습니다. 결정 중심 메모리라는 원리와, 그 원리를 안전하게 반복 가능하게 만드는 감사 기반 오케스트레이션이 이렇게 맞물립니다.

## 한계 및 반론

몇 가지는 분명히 해 둘 필요가 있습니다.

첫째, 증명(certify)에는 비용이 듭니다. 결정 충돌을 데이터로 인증하려면 관측이 쌓여야 하는데, 콜드 스타트나 희소한 상호작용 환경에서는 세분화가 지연되어 초기 결정 품질이 어떻게 되는지 본문만으로는 판단하기 어렵습니다.

둘째, 프로덕션에서 "결정 품질 손실"을 온라인으로 추정하려면 보상 신호나 판정기가 필요합니다. 벤치마크에는 정답이 있어 이 신호를 쉽게 얻지만, 정답이 없는 실제 대화에서 이 신호를 어떻게 확보할지가 다음 과제로 남습니다. 앞서 제안한 감사 로그 활용이 하나의 답이 될 수 있으나, 이는 논문의 범위 밖입니다.

셋째, 부록에 계산 경도(computational hardness) 증명이 포함되어 있다는 것은 최적 파티션을 찾는 문제가 일반적으로 어렵다는 뜻입니다. DeMem은 그 실전 근사인데, 어떤 조건에서 이 근사가 무너지는지에 대한 경계가 더 필요합니다.

그럼에도 "에이전트 메모리를 묘사에서 결정으로 옮기라"는 원칙 자체는 단순하고 강력하며, 지금 당장 채택을 검토할 가치가 있습니다. 에이전트가 자꾸 과거의 결정을 잊는다면, 문제는 메모리가 작아서가 아니라 메모리가 엉뚱한 것을 보존하고 있어서일 수 있습니다.

> 📄 **심층 리뷰 전문(DOCX)**: 이 논문의 상세 피어리뷰를 [Google Drive에서 다운로드](https://drive.google.com/file/d/1oxsADQALTfdn7I_mmZbaZfMnmqoCMF9o/view)할 수 있습니다.


## 관련 슬라이드

본문 내용을 NotebookLM(`executive_report` 스타일)으로 요약한 슬라이드입니다.

![demem-agent-memory 슬라이드 1]({{ '/assets/images/demem-agent-memory-slide-01.webp' | relative_url }})

![demem-agent-memory 슬라이드 2]({{ '/assets/images/demem-agent-memory-slide-02.webp' | relative_url }})

![demem-agent-memory 슬라이드 3]({{ '/assets/images/demem-agent-memory-slide-03.webp' | relative_url }})

![demem-agent-memory 슬라이드 4]({{ '/assets/images/demem-agent-memory-slide-04.webp' | relative_url }})

## 출처

- 논문: [Remember the Decision, Not the Description: A Rate-Distortion Framework for Agent Memory (arXiv 2605.10870)](https://arxiv.org/abs/2605.10870)
- 벤치마크: LoCoMo, LongMemEval / 백본: GPT-4o-mini, GPT-4.1-mini, Qwen2.5-14B-Instruct, Llama-3.1-70B
- 표의 수치는 논문 Table 1(LoCoMo, GPT-4.1-mini)에서 인용했습니다.
