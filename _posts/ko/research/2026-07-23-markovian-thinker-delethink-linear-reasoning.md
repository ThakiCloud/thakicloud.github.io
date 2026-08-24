---
title: "생각이 길어져도 비용은 선형으로: 마르코프 사고와 Delethink가 긴 추론을 다시 설계하는 법"
seo_title: "Markovian Thinker Delethink 고정 청크로 긴 추론을 선형 비용으로 | ThakiCloud"
seo_description: "긴 사고연쇄는 상태가 계속 커져서 비용이 제곱으로 늘어납니다. 마르코프 사고는 고정 크기 상태만 보고 추론을 이어 가게 만들어 비용을 선형으로 낮춥니다. Delethink 환경에서 8K 청크로 훈련한 1.5B 모델이 24K까지 사고하며, 96K 사고 길이에서 훈련 비용이 27 H100-월에서 7 H100-월로 줄었습니다."
excerpt: "긴 추론의 진짜 비용은 상태가 무한정 커지는 데서 옵니다. 마르코프 사고는 사고를 고정 크기 청크로 끊고, 청크 경계에서 짧은 상태만 넘겨 이어 가게 해 비용을 제곱에서 선형으로 바꿉니다."
date: 2026-07-23
tags:
  - 긴 추론
  - 사고연쇄
  - 마르코프 사고
  - Delethink
  - 강화학습
  - 추론 비용 최적화
  - 선형 스케일링
  - KV 캐시
  - 테스트타임 스케일링
  - 추론 서빙
categories: [research]
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/ko/research/markovian-thinker-delethink-linear-reasoning/"
---

추론 모델을 점점 더 길게 생각하게 만들다가 비용이 감당 안 되는 지점을 만난 적이 있다면 이 글이 그 이야기입니다. 긴 사고연쇄의 진짜 비용은 모델이 생각하는 동안 상태가 무한정 커져 비용이 사고 길이의 제곱으로 늘어나는 데서 옵니다. 마르코프 사고(Markovian Thinking)는 정책이 고정 크기 상태만 보고 추론을 이어 가게 해 이 비용을 선형으로 낮춥니다. 이 발상을 구현한 Delethink 환경에서 8K 토큰 청크로 훈련한 1.5B 모델은 24K 토큰까지 사고하면서 같은 예산의 기존 방식과 맞먹거나 앞섰고 96K 사고 길이에서는 훈련 비용이 27 H100-월에서 7 H100-월로 줄었습니다.

![고정 크기 청크를 따라 선형 궤도로 흐르는 긴 추론을 형상화한 추상 이미지](/assets/images/markovian-thinker-delethink-linear-reasoning-hero.webp)
*긴 사고를 고정 크기 청크로 끊고 짧은 상태만 다음으로 넘기는 마르코프 사고를 형상화했습니다.*

## 왜 읽어야 하나

이 글은 긴 추론 모델을 서빙하거나 강화학습으로 훈련하는 엔지니어, 그리고 그 추론 비용을 책임지는 플랫폼 담당자를 겨냥합니다. 모델이 더 길게 생각하게 하고 싶은데 그 길이에 비례해 제곱으로 뛰는 계산량과 메모리를 어떻게 감당할지, 여러분이 지금 마주한 고민이 바로 이것일 겁니다. 마르코프 사고(arXiv:2510.06557, McGill-NLP)는 사고 길이를 문맥 크기에서 분리하는 방식으로 답합니다. 추론을 고정 크기 청크로 끊고 청크 경계에서 다음 청크로 넘길 짧은 텍스트 상태만 남기면, 사고가 아무리 길어져도 비용은 선형으로만 늘고 메모리는 상수로 유지됩니다.

## 개요

지난 몇 년간 추론 모델의 성능은 사고연쇄를 길게 늘이는 방향으로 올랐습니다. 더 오래 생각할수록 더 어려운 문제를 풀 수 있다는 것이 이 흐름의 전제입니다. 그런데 이 길어지는 사고에는 잘 드러나지 않는 대가가 붙어 있습니다. 표준적인 강화학습 사고 환경에서 상태는 프롬프트에 그때까지 생성한 모든 추론 토큰을 더한 것으로 정의됩니다. 즉 모델이 생각을 이어 갈수록 상태가 계속 부풀고 어텐션 기반 정책은 그 커지는 상태를 매번 다시 훑어야 하므로 계산량이 사고 길이의 제곱으로 늘어납니다. 메모리도 함께 자랍니다. 생각을 두 배로 길게 하면 비용은 네 배가 되는 셈입니다.

마르코프 사고는 이 전제 자체를 다시 봅니다. 상태를 무한정 키우는 대신, 정책이 항상 고정된 크기의 상태만 보고 추론을 진행하게 만듭니다. 사고 길이가 문맥 크기와 묶여 있던 고리를 끊어 사고가 길어져도 계산은 선형으로, 메모리는 상수로 유지되게 합니다. 마르코프 과정에서 다음 상태가 바로 앞의 고정 상태에만 의존하듯, 다음 사고 조각도 앞선 모든 토큰이 아니라 방금 넘겨받은 고정 상태에만 의존하게 됩니다.

## 이 기술은 무엇인가

마르코프 사고를 실제로 구현한 것이 Delethink라는 강화학습 환경입니다. Delethink는 추론을 고정 크기 청크로 구조화합니다. 각 청크 안에서 모델은 평소처럼 자유롭게 생각합니다. 그러다 청크 경계에 이르면 환경이 문맥을 리셋하고 프롬프트를 짧은 이월분(carryover)으로 다시 초기화합니다. 핵심은 정책이 강화학습으로 이 습관 자체를 배운다는 점입니다. 각 청크가 끝나갈 무렵 정책은 리셋 이후에도 추론을 매끄럽게 이어 가기에 충분한 텍스트 상태를 스스로 써 두는 법을 익힙니다. 다음 청크는 앞선 청크 전체가 아니라 이 짧은 상태만 물려받아 시작합니다.

아래 도표가 이 흐름을 보여 줍니다.

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
<div class="d3-arch" data-arch-root id="delethinklinearreasoning-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 445, "height": 772, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 24, "y": 24, "w": 170, "h": 46, "title": "청크 시작: 짧은 이월 상태로 초기화"}, {"id": "B", "x": 91, "y": 148, "w": 163, "h": 46, "title": "청크 안에서 평소처럼 자유롭게 사고"}, {"id": "C", "x": 103, "y": 286, "w": 138, "h": 52, "title": "청크 경계 도달?"}, {"id": "D", "x": 84, "y": 430, "w": 177, "h": 46, "title": "청크 끝에서 텍스트 상태를 스스로 기록"}, {"id": "E", "x": 112, "y": 554, "w": 120, "h": 46, "title": "환경이 문맥을 리셋"}, {"id": "F", "x": 42, "y": 678, "w": 135, "h": 62, "title": ["다음 청크: 전체 이력 대신", "짧은 상태만 이월"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[132, 70], [172, 109], [172, 109], [172, 148]]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[177, 194], [187, 240], [187, 240], [177, 286]]}, {"src": "C", "dst": "B", "kind": "data", "label": "아니오", "curve": [[155, 286], [124, 240], [124, 240], [156, 194]], "off": "50%"}, {"src": "C", "dst": "D", "kind": "data", "label": "예", "line": [172, 338, 172, 430], "lx": 172, "ly": 380}, {"src": "D", "dst": "E", "kind": "data", "line": [172, 476, 172, 554]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[172, 600], [172, 639], [172, 639], [137, 678]]}, {"src": "F", "dst": "A", "kind": "data", "curve": [[81, 678], [46, 515], [46, 240], [86, 70]]}, {"src": "D", "dst": "D", "kind": "event", "label": "강화학습이 좋은 상태 기록을 보상", "curve": [[261, 440], [340, 430], [340, 476], [261, 466]], "off": "50%"}]});
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
      const container = document.getElementById('delethinklinearreasoning-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'delethinklinearreasoning-1';
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

기존의 긴 사고연쇄 방식(LongCoT)과의 차이가 여기서 갈립니다. LongCoT은 생성한 모든 토큰을 문맥에 계속 쌓아 두므로 상태가 무한정 커집니다. Delethink는 청크마다 문맥을 비우고 짧은 상태만 넘기므로 상태 크기가 고정됩니다. 사고의 길이는 청크를 몇 번 이어 붙이느냐로 늘리되, 한 번에 문맥에 올라가는 양은 청크 하나 크기로 묶어 둡니다.

## 논문이 보고한 실험 결과

논문이 보고한 수치는 이 발상이 실제로 통한다는 것을 보여 줍니다. R1-Distill 1.5B 모델을 Delethink 환경에서 8K 토큰 청크로 훈련했더니, 이 모델은 최대 24K 토큰까지 사고하면서 24K 예산으로 훈련한 기존 LongCoT-RL과 맞먹거나 그것을 앞섰습니다. 8K짜리 창만 보면서도 그보다 세 배 긴 추론을 해냈습니다.

비용 차이는 규모가 커질수록 벌어집니다. 논문은 평균 사고 길이 96K 지점에서 LongCoT-RL의 훈련 비용이 27 H100-월인 데 비해 Delethink는 7 H100-월이라고 보고합니다. 선형 대 제곱의 차이가 만드는 격차입니다.

| 항목 | LongCoT-RL | Delethink(마르코프 사고) |
|---|---|---|
| 상태 크기 | 사고 길이에 비례해 무한정 증가 | 청크 크기로 고정 |
| 계산 스케일링 | 사고 길이의 제곱 | 사고 길이에 선형 |
| 96K 사고 길이 훈련 비용 | 27 H100-월 | 7 H100-월 |
| 테스트타임 스케일링 | 정체 경향 | 계속 개선 |

테스트타임 스케일링에서도 차이가 납니다. 추론 시점에 사고를 더 늘렸을 때 LongCoT이 정체되는 지점에서 Delethink는 계속 개선됩니다. 또 하나 흥미로운 관찰은 강화학습 초기화 시점 분석에서 나옵니다. 1.5B부터 120B까지 시중의 여러 추론 모델이 다양한 벤치마크에서 마르코프적 궤적을 별도 훈련 없이도 곧잘 샘플링합니다. 이렇게 자연 발생하는 긍정 샘플이 강화학습을 규모에서도 효과적으로 만드는 밑거름이 됩니다.

위 수치는 모두 논문이 보고한 값이며 저희가 별도로 재현해 측정한 것은 아닙니다. 구체적 실험 조건은 원문과 공개된 코드 저장소에서 직접 확인하시길 권합니다.

## ThakiCloud 제품 적용 시사점

마르코프 사고의 실무적 함의는 ThakiCloud 두 제품 모두에 해당합니다.

ai-platform 관점이 특히 직접적입니다. 긴 추론을 서빙할 때 비용을 실제로 밀어 올리는 것은 사고가 길어질수록 커지는 KV 캐시와 어텐션 계산입니다. 문맥이 무한정 자라면 H200 한 장에 올릴 수 있는 동시 요청 수가 줄고 멀티테넌트 환경에서 GPU 메모리 압박이 심해집니다. 마르코프 사고처럼 한 번에 문맥에 올라가는 양을 청크 크기로 고정하면, KV 캐시 발자국이 사고 길이와 무관하게 상수로 유지됩니다. 이는 Kueue 기반 GPU 스케줄링 위에서 같은 하드웨어로 더 많은 동시 추론을, 그것도 더 긴 사고를 요구하는 워크로드로 소화할 수 있게 된다는 의미입니다. 온프레미스와 소버린 배포처럼 GPU 예산이 빡빡한 환경일수록 선형 비용의 이점은 커집니다.

Paxis 관점도 있습니다. Paxis는 ThakiCloud의 Agent-Native Cloud로, 에이전트가 여러 단계에 걸쳐 길게 추론하고 도구를 호출하는 워크플로를 격리 샌드박스에서 실행합니다. 에이전트의 추론이 길어질수록 문맥이 부풀어 비용과 지연이 함께 오르는데, 마르코프 사고의 고정 상태 이월은 긴 에이전트 루프를 상수 메모리로 유지하는 길을 제시합니다. 스킬 하네스가 여러 스킬을 이어 붙여 긴 작업을 수행할 때, 각 단계가 전체 이력이 아니라 압축된 상태만 물려받게 하는 설계는 에이전트 경제성을 직접 개선합니다.

## 한계 및 반론

가장 큰 물음은 정보 손실입니다. 청크 경계에서 문맥을 리셋하고 짧은 상태만 넘긴다는 것은, 앞선 청크의 세부가 그 짧은 상태에 담기지 못하면 영영 사라진다는 의미입니다. 정책이 정말 중요한 것을 상태에 잘 압축해 넣도록 학습해야 하며 상태 크기와 청크 크기를 잘못 잡으면 긴 의존성을 요구하는 문제에서 성능이 떨어질 수 있습니다. 모든 추론이 마르코프적으로 잘 쪼개지는 것은 아닙니다.

또한 이 방식은 강화학습으로 상태 기록 습관을 길들여야 비로소 작동합니다. 상태를 쓰는 법을 아직 배우지 못한 모델에 그냥 적용하면 청크 사이가 끊깁니다. 다만 논문이 관찰한 대로 시중 모델들이 마르코프적 궤적을 어느 정도 자연히 샘플링한다는 점은 이 부트스트랩 부담을 덜어 줍니다. 마지막으로 보고된 이득은 논문의 실험 설정과 벤치마크에 대한 것이며 도메인이 크게 다른 실제 프로덕션 추론으로 그대로 이전될지는 별도의 검증이 필요합니다.

## 정리

긴 추론의 비용 문제를 모델을 더 키우는 것으로 풀려 하기 전에, 마르코프 사고의 답은 문제의 정의 자체를 바꾸는 데 있습니다. 핵심은 상태를 무한정 키우지 않고 고정하는 것입니다. 긴 추론을 서빙하거나 훈련한다면 오늘 가져갈 한 가지는 분명합니다. 사고를 길게 늘리는 것과 문맥을 무한정 키우는 것은 같은 일이 아니며 둘을 분리하면 같은 성능을 훨씬 적은 비용으로 얻을 여지가 생깁니다. 청크 경계에서 무엇을 남기고 무엇을 버릴지를 정책이 스스로 배우게 하는 이 설계는, 추론 비용이 곧 사업 비용인 서빙 현장에서 가장 먼저 검토해 볼 만한 저비용 개선 지점입니다.

출처: [The Markovian Thinker: Architecture-Agnostic Linear Scaling of Reasoning (arXiv:2510.06557)](https://arxiv.org/abs/2510.06557) · [코드 저장소(McGill-NLP/the-markovian-thinker)](https://github.com/McGill-NLP/the-markovian-thinker)
