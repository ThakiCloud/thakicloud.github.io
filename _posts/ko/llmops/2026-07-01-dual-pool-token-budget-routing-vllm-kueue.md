---
title: "Dual-Pool Token-Budget Routing: vLLM 추론 GPU 시간 31~42% 절감하는 이원화 스케줄링"
excerpt: "짧은 응답 요청이 긴 응답 요청에 밀려 기다리는 HoL 블로킹은 GPU 시간을 낭비하는 조용한 적입니다. 요청을 short-context 풀과 long-context 풀로 나눠 라우팅하는 Dual-Pool Token-Budget Routing은 arXiv 2604.08075에서 GPU 시간 31~42% 절감, P99 TTFT 6% 개선을 측정했습니다. Kueue LocalQueue와 연동해 이 기법을 Kubernetes 위에서 구현하는 방법을 단계별로 정리합니다."
seo_title: "Dual-Pool Token-Budget Routing: vLLM GPU 시간 31~42% 절감 | Thaki Cloud"
seo_description: "vLLM 추론 요청을 short-context 풀과 long-context 풀로 이원화해 HoL 블로킹을 제거하고 GPU 시간 31~42%를 절감하는 Dual-Pool Token-Budget Routing 기법과 Kubernetes Kueue LocalQueue 연동 구현을 설명합니다."
date: 2026-07-01
last_modified_at: 2026-07-01
tags:
  - vllm
  - llm-inference
  - kueue
  - gpu-scheduling
  - llmops
  - kubernetes
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "microchip"
canonical_url: "https://thakicloud.com/tech-blog/ko/llmops/dual-pool-token-budget-routing-vllm-kueue/"
categories:
  - llmops
audiobook: "https://drive.google.com/file/d/1zaFojeuvXVOf_U9Le16SWo8BT8Fc0uxC/view"
audiobook_label: "▶ 5분 브리핑으로 듣기"
audiobook_note: "NotebookLM 오디오 개요 (AI 생성)"
published: false
---

![Dual-Pool Token-Budget Routing: vLLM 추론 GPU 시간 31~42% 절감하는 이원화 스케줄링 개념을 형상화한 이미지](/assets/images/dual-pool-token-budget-routing-vllm-kueue-hero.webp)
*글의 핵심 개념을 형상화했습니다.*

## 문제: HoL 블로킹이 GPU 시간을 조용히 낭비합니다

LLM 추론 서비스를 운영하다 보면 단일 대기열 구조에서 반복되는 현상을 하나 목격하게 됩니다. 챗봇 한 줄 응답처럼 토큰 수십 개로 끝나는 요청이, 긴 문서 요약이나 코드 생성 요청 뒤에 줄을 서서 수백 밀리초를 낭비하는 상황입니다. 이를 Head-of-Line(HoL) 블로킹이라고 부릅니다.

vLLM은 continuous batching으로 배치 효율을 크게 높였지만, 단일 풀 구조에서 긴 요청이 KV 캐시를 장기간 점유하면 짧은 요청의 선점(preemption)이 발생합니다. 선점된 요청은 재계산 비용을 지불하고, 전체 GPU 시간 효율이 떨어집니다.

arXiv 2604.08075가 제안한 **Dual-Pool Token-Budget Routing**은 이 문제를 근본적으로 해결합니다. 요청이 들어오는 시점에 예상 응답 길이를 기준으로 short-context 풀과 long-context 풀로 분리해 라우팅함으로써, 두 유형이 서로 간섭하지 않게 합니다.

논문이 측정한 결과는 다음과 같습니다.

| 지표 | 효과 |
|---|---|
| GPU 시간 절감 | **31~42%** |
| Preemption rate | **5.4배 감소** |
| P99 TTFT 개선 | **6%** |

## 핵심 원리: 토큰 버짓 기반 라우팅

Dual-Pool의 핵심은 단순합니다. 요청마다 **예상 최대 토큰 수**를 추정하고, 임계값을 기준으로 두 풀 중 하나에 할당합니다.

```
요청의 예상 토큰 합 = 입력 토큰 + 예상 출력 토큰
```

예상 출력 토큰을 모르는 경우(대부분의 실제 상황)에는 다음 두 가지 근사를 씁니다.

1. **요청 파라미터**: `max_tokens` 값을 상한으로 사용합니다.
2. **히스토리 기반 분류**: 같은 API 경로 또는 시스템 프롬프트 해시로 이전 요청 길이 분포를 추적해 P75 또는 P90 값을 기준으로 분류합니다.

임계값 설정은 워크로드 특성에 따라 다르지만, 논문에서 보고한 실험에서는 출력 512토큰을 기준으로 short/long을 나눴습니다.

## 아키텍처: 두 풀의 구조

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
<div class="d3-arch" data-arch-root id="enbudgetroutingvllmkueue-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 395, "height": 800, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 134, "y": 24, "w": 120, "h": 46, "title": "클라이언트 요청"}, {"id": "B", "x": 123, "y": 148, "w": 142, "h": 62, "title": ["라우터", "Token-Budget 분류기"]}, {"id": "C", "x": 225, "y": 302, "w": 135, "h": 62, "title": ["Short-Context 풀", "vLLM 인스턴스 A"]}, {"id": "D", "x": 31, "y": 302, "w": 128, "h": 62, "title": ["Long-Context 풀", "vLLM 인스턴스 B"]}, {"id": "E", "x": 221, "y": 442, "w": 142, "h": 62, "title": ["Kueue LocalQueue", "short-pool"]}, {"id": "F", "x": 24, "y": 442, "w": 142, "h": 62, "title": ["Kueue LocalQueue", "long-pool"]}, {"id": "G", "x": 232, "y": 582, "w": 120, "h": 62, "title": ["GPU 워커 그룹 A", "작은 KV 캐시 요청"]}, {"id": "H", "x": 35, "y": 582, "w": 120, "h": 62, "title": ["GPU 워커 그룹 B", "큰 KV 캐시 요청"]}, {"id": "I", "x": 134, "y": 722, "w": 120, "h": 46, "title": "응답 반환"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [194, 70, 194, 148]}, {"src": "B", "dst": "C", "kind": "data", "label": "예상 토큰 < 임계값", "curve": [[233, 210], [292, 256], [292, 256], [292, 302]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "예상 토큰 >= 임계값", "curve": [[154, 210], [95, 256], [95, 256], [95, 302]], "off": "50%"}, {"src": "C", "dst": "E", "kind": "data", "line": [292, 364, 292, 442]}, {"src": "D", "dst": "F", "kind": "data", "line": [95, 364, 95, 442]}, {"src": "E", "dst": "G", "kind": "data", "line": [292, 504, 292, 582]}, {"src": "F", "dst": "H", "kind": "data", "line": [95, 504, 95, 582]}, {"src": "G", "dst": "I", "kind": "data", "curve": [[292, 644], [292, 683], [292, 683], [230, 722]]}, {"src": "H", "dst": "I", "kind": "data", "curve": [[95, 644], [95, 683], [95, 683], [157, 722]]}]});
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
      const container = document.getElementById('enbudgetroutingvllmkueue-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'enbudgetroutingvllmkueue-1';
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

Short-context 풀은 KV 캐시를 빠르게 회전시켜 높은 throughput을 유지합니다. Long-context 풀은 긴 생성을 방해 없이 완료할 수 있는 충분한 KV 캐시 메모리를 확보합니다. 두 풀은 서로 선점 간섭을 일으키지 않습니다.

## Kueue LocalQueue 연동 구현

ThakiCloud의 ai-platform은 Kubernetes 위에서 Kueue를 통해 GPU 워크로드를 스케줄링합니다. Dual-Pool Routing을 Kueue LocalQueue와 연동하면 클러스터 수준에서 두 풀의 자원 배분을 선언적으로 관리할 수 있습니다.

### 1단계: ClusterQueue와 ResourceFlavor 정의

```yaml
apiVersion: kueue.x-k8s.io/v1beta1
kind: ClusterQueue
metadata:
  name: llm-inference-cq
spec:
  namespaceSelector: {}
  resourceGroups:
    - coveredResources: ["nvidia.com/gpu"]
      flavors:
        - name: gpu-a100
          resources:
            - name: nvidia.com/gpu
              nominalQuota: 8
---
apiVersion: kueue.x-k8s.io/v1beta1
kind: ResourceFlavor
metadata:
  name: gpu-a100
spec:
  nodeLabels:
    gpu.nvidia.com/model: A100
```

### 2단계: 풀별 LocalQueue 분리

```yaml
apiVersion: kueue.x-k8s.io/v1beta1
kind: LocalQueue
metadata:
  name: short-pool-queue
  namespace: llm-serving
spec:
  clusterQueue: llm-inference-cq
---
apiVersion: kueue.x-k8s.io/v1beta1
kind: LocalQueue
metadata:
  name: long-pool-queue
  namespace: llm-serving
spec:
  clusterQueue: llm-inference-cq
```

### 3단계: vLLM Deployment에 큐 어노테이션 추가

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vllm-short-pool
  namespace: llm-serving
  labels:
    kueue.x-k8s.io/queue-name: short-pool-queue   # 라벨, 어노테이션 아님
spec:
  replicas: 2
  template:
    spec:
      containers:
        - name: vllm
          image: vllm/vllm-openai:latest
          args:
            - "--model"
            - "meta-llama/Llama-3.1-8B-Instruct"
            - "--max-model-len"
            - "4096"       # short 풀: 작은 컨텍스트 한도
            - "--gpu-memory-utilization"
            - "0.7"        # KV 캐시를 짧게 쓰고 빠르게 회전
          resources:
            limits:
              nvidia.com/gpu: "1"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vllm-long-pool
  namespace: llm-serving
  labels:
    kueue.x-k8s.io/queue-name: long-pool-queue
spec:
  replicas: 2
  template:
    spec:
      containers:
        - name: vllm
          image: vllm/vllm-openai:latest
          args:
            - "--model"
            - "meta-llama/Llama-3.1-8B-Instruct"
            - "--max-model-len"
            - "32768"      # long 풀: 넉넉한 컨텍스트 허용
            - "--gpu-memory-utilization"
            - "0.90"       # KV 캐시를 크게 확보
          resources:
            limits:
              nvidia.com/gpu: "1"
```

큐 이름을 어디에 다는지가 조용한 함정입니다. `kueue.x-k8s.io/queue-name`은 **라벨**이어야 합니다. 어노테이션에 적으면 Kueue의 웹훅이 라벨 셀렉터로 대상을 고르기 때문에 이 Deployment를 아예 집어 가지 않고, 워크로드는 큐에 들어가지도 못한 채 평범하게 스케줄됩니다. 에러가 나지 않아서 더 늦게 발견됩니다.

### 4단계: 라우터 구현 (Python 예시)

```python
from fastapi import FastAPI, Request
import httpx

app = FastAPI()

SHORT_POOL_URL = "http://vllm-short-pool-svc:8000/v1/chat/completions"
LONG_POOL_URL  = "http://vllm-long-pool-svc:8000/v1/chat/completions"
TOKEN_THRESHOLD = 512  # 이 값은 워크로드 히스토리로 튜닝

def estimate_output_tokens(payload: dict) -> int:
    """max_tokens를 상한으로 사용. 없으면 256 기본값."""
    return payload.get("max_tokens") or 256

def route_request(payload: dict) -> str:
    """예상 토큰 수에 따라 라우팅 대상 URL 반환."""
    estimated = estimate_output_tokens(payload)
    if estimated < TOKEN_THRESHOLD:
        return SHORT_POOL_URL
    return LONG_POOL_URL

@app.post("/v1/chat/completions")
async def proxy(request: Request):
    payload = await request.json()
    target_url = route_request(payload)
    async with httpx.AsyncClient(timeout=120.0) as client:
        resp = await client.post(target_url, json=payload)
        return resp.json()
```

이 라우터는 Kubernetes Service로 노출하고, 기존 추론 엔드포인트 앞에 배치합니다.

## 운영 고려사항

### 임계값 튜닝

512토큰 임계값은 워크로드에 따라 달라집니다. 실제 운영에서는 다음 지표를 7일 이상 수집한 뒤 조정하는 것을 권장합니다.

- 요청별 실제 출력 토큰 분포 (P50, P90, P99)
- 풀별 preemption rate (`vllm:num_preemptions_total` Prometheus 메트릭)
- 풀별 `vllm:num_requests_waiting` 대기 큐 깊이

Short 풀 대기 큐가 지속적으로 깊어진다면 임계값을 낮추거나 short 풀 replica를 늘려야 합니다. Long 풀 GPU 사용률이 낮다면 임계값을 올려 long으로 가는 요청을 줄입니다.

### KEDA 오토스케일링 연동

vLLM Prometheus 메트릭 기반 KEDA ScaledObject를 추가하면 풀별로 독립적인 오토스케일링이 가능합니다.

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: vllm-short-pool-scaler
  namespace: llm-serving
spec:
  scaleTargetRef:
    name: vllm-short-pool
  minReplicaCount: 1
  maxReplicaCount: 8
  triggers:
    - type: prometheus
      metadata:
        serverAddress: http://prometheus:9090
        query: vllm:num_requests_waiting{deployment="vllm-short-pool"}
        threshold: "5"
```

KEDA 메트릭 기반 스케일링은 단순 HTTP RPS 기반보다 추론 부하에 더 직접 대응합니다. 위 임계값 `5`는 현재 대기 요청이 5개를 초과하면 scale-up을 시작하라는 의미입니다.

여기서도 오래된 예제를 그대로 옮기지 않도록 주의하십시오. 현재 KEDA Prometheus 스케일러 문서의 파라미터 목록에 `metricName`은 없습니다. 무엇을 보고 스케일할지는 `query`가 결정하므로 그 필드만 정확하면 됩니다.

### 모델 공유 vs 인스턴스 분리

두 풀이 반드시 서로 다른 vLLM 인스턴스를 써야 하는 것은 아닙니다. 동일 모델을 다른 `--max-model-len` 설정으로 띄우는 것이 기본 구성이지만, 메모리 예산이 넉넉하다면 단일 vLLM 인스턴스에 두 개의 외부 포트를 열고 내부적으로 priority class를 달리 적용하는 방법도 있습니다.

다만 preemption 간섭을 완전히 차단하려면 **인스턴스 분리가 더 명확합니다**. KV 캐시 메모리는 vLLM 프로세스 내에서 공유되기 때문입니다.

## ThakiCloud ai-platform 적용 관점

ThakiCloud의 ai-platform은 멀티테넌트 환경에서 여러 고객의 추론 워크로드를 단일 GPU 클러스터에서 서빙합니다. Dual-Pool Routing은 이 환경에서 두 가지 이점을 더합니다.

첫째, 테넌트 간 간섭을 줄입니다. 짧은 챗봇 응답이 주인 고객사 A의 요청이, 긴 문서 분석이 주인 고객사 B의 배치 요청에 밀리는 상황은 SLO 위반으로 이어집니다. 풀 분리는 이 간섭을 구조적으로 차단합니다.

둘째, GPU 예산 효율이 높아집니다. 논문이 측정한 31~42% GPU 시간 절감은 같은 GPU 예산으로 더 많은 요청을 소화하거나, 동일 처리량을 더 적은 GPU로 달성한다는 의미입니다. 온프렘 자원이 고정된 환경에서 이 절감률은 곧 서빙 비용 절감으로 직결됩니다.

Kueue LocalQueue를 이미 사용 중인 ThakiCloud 클러스터에서는 Short/Long 큐 선언과 라우터 배치만으로 이 구조를 추가할 수 있습니다. 기존 vLLM Deployment 스펙과의 호환성도 높아 적용 범위가 넓습니다.

## 정리

Dual-Pool Token-Budget Routing이 해결하는 문제는 단순합니다. 짧은 요청과 긴 요청이 같은 대기열에 섞이면 짧은 요청이 손해를 봅니다. 이를 대기열 단계에서 분리하면 각 유형의 요청이 자기 속도로 처리됩니다.

arXiv 2604.08075가 측정한 GPU 시간 31~42% 절감, preemption rate 5.4배 감소, P99 TTFT 6% 개선은 구현 복잡도에 비해 효과가 큰 기법입니다. Kubernetes 환경에서는 Kueue LocalQueue 두 개, vLLM Deployment 두 개, 경량 라우터 하나로 이 구조를 구현할 수 있습니다.


## 관련 슬라이드

본문 내용을 NotebookLM(`tech_pitch` 스타일)으로 요약한 슬라이드입니다.

![dual-pool-token-budget-routing-vllm-kueue 슬라이드 1](/assets/images/dual-pool-token-budget-routing-vllm-kueue-slide-01.webp)

![dual-pool-token-budget-routing-vllm-kueue 슬라이드 2](/assets/images/dual-pool-token-budget-routing-vllm-kueue-slide-02.webp)

![dual-pool-token-budget-routing-vllm-kueue 슬라이드 3](/assets/images/dual-pool-token-budget-routing-vllm-kueue-slide-03.webp)

![dual-pool-token-budget-routing-vllm-kueue 슬라이드 4](/assets/images/dual-pool-token-budget-routing-vllm-kueue-slide-04.webp)

## 출처

- [Dual-Pool Token-Budget Routing for Cost-Efficient and Reliable LLM Serving (arXiv)](https://arxiv.org/abs/2604.08075)
- [Engine Arguments: max-model-len and gpu-memory-utilization (vLLM Docs)](https://docs.vllm.ai/en/latest/configuration/engine_args.html)
- [vLLM Overview: Continuous Batching and PagedAttention (vLLM Docs)](https://docs.vllm.ai/en/latest/)
- [Production Metrics: num_preemptions_total and num_requests_waiting (vLLM Docs v0.9.2)](https://docs.vllm.ai/en/v0.9.2/usage/metrics.html)
- [ClusterQueue and ResourceFlavor Concepts (Kueue Docs)](https://kueue.sigs.k8s.io/docs/concepts/cluster_queue/)
- [LocalQueue Concept (Kueue Docs)](https://kueue.sigs.k8s.io/docs/concepts/local_queue/)
- [Run Deployment on Kueue (Kueue Docs)](https://kueue.sigs.k8s.io/docs/tasks/run/deployment/)
- [Prometheus Scaler Trigger Reference (KEDA Docs)](https://keda.sh/docs/latest/scalers/prometheus/)
