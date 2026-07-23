---
title: "Fable 5로 레이트리밋 없이 일하기: 모델 라우팅과 토큰 예산 전략"
excerpt: "T3 창시자 Theo가 공유한 Claude Fable 5 운용 팁을 뜯어봅니다. effort 레벨 선택, Codex 오케스트레이션, CLAUDE.md 모델 우선순위, 토큰 무거운 작업 위임까지. ThakiCloud가 Paxis와 ai-platform에서 쓰는 모델 라우팅 규율과 나란히 놓고 정리합니다."
tags:
  - claude-code
  - model-routing
  - cost-optimization
  - agent-native
  - paxis
date: 2026-07-04
lang: ko
canonical_url: "https://thakicloud.com/tech-blog/ko/dev/fable-model-routing-rate-limits/"
categories:
  - dev
---

![여러 크기의 처리 경로가 하나의 지휘 노드로 모였다가 다시 갈래로 흩어지는 추상 이미지]({{ '/assets/images/fable-model-routing-rate-limits-hero.webp' | relative_url }})
*무거운 작업과 가벼운 작업을 서로 다른 모델로 흘려보내는 라우팅의 개념을 형상화했습니다.*

## 개요

강력한 코딩 모델을 하나 붙잡고 모든 작업을 시키면 편합니다. 문제는 그 편함이 토큰 예산과 레이트리밋으로 되돌아온다는 점입니다. 가장 비싼 모델을 가장 단순한 작업에까지 쓰면, 정작 어려운 추론이 필요할 때 한도가 바닥나 있습니다.

2026년 7월 초, T3 스택 창시자 Theo(@theo)가 Claude Fable 5를 하루 종일 돌리면서도 레이트리밋에 걸리지 않는 방법을 공유했습니다. 요지는 단순합니다. 한 모델에 모든 것을 몰아주지 말고, 작업 성격에 따라 모델과 effort를 갈라 쓰라는 것입니다. 이 글에서는 그가 제시한 네 가지 전략을 실제 인용과 함께 정리하고, ThakiCloud가 Paxis와 ai-platform 운영에서 이미 쓰고 있는 모델 라우팅 규율과 나란히 놓아 봅니다.

이 주제가 중요한 이유는 명확합니다. 에이전트가 자율적으로 오래 도는 시대에는 모델 한 번의 품질보다 세션 전체의 토큰 흐름을 어떻게 설계하느냐가 실제 생산성과 비용을 가릅니다.

## 문제: 레이트리밋은 품질이 아니라 배분의 문제다

레이트리밋에 자주 걸리는 사용자는 대체로 모델이 약해서가 아니라 배분이 서툴러서 걸립니다. 파일 하나 읽기, 단순 grep, 로그 요약 같은 저난도 작업에도 최고 티어 모델을 최고 effort로 돌리면, 토큰이 선형이 아니라 기하급수로 소모됩니다. 특히 사고(thinking) 토큰은 눈에 보이지 않게 쌓입니다.

핵심 통찰은 이것입니다. 최고 모델은 유한한 자원이고, 그 자원을 어디에 쓸지 결정하는 일이 곧 라우팅입니다. Theo의 팁 네 가지는 전부 이 하나의 원칙을 서로 다른 각도에서 실천한 것입니다.

## Theo의 네 가지 전략

### 1. effort는 기본적으로 high로, xhigh와 max는 아껴서

Theo는 Fable을 당분간 "high" effort로만 쓴다고 밝혔습니다. 그의 표현을 그대로 옮기면, xhigh는 "토큰을 게걸스럽게 먹고(token hungry)", max와 extra는 "더 낮은 옵션보다 오히려 결과가 나쁜 용광로(a furnace with worse outputs than lower options)"라는 것입니다.

여기서 배울 점은 effort를 올린다고 품질이 단조 증가하지 않는다는 사실입니다. 사고 토큰이 늘어나면 오히려 산만해지거나 과도하게 우회하는 출력이 나올 수 있습니다. 대부분의 실무 작업에는 high가 품질과 비용의 균형점입니다. xhigh와 max는 정말로 깊은 추론이 필요한 단계에만 아껴서 씁니다.

### 2. Codex를 하위 실행기로 오케스트레이션

두 번째 전략은 모델을 계층으로 나누는 것입니다. Theo는 Claude Code가 Codex(GPT-5.5)를 구현 작업의 하위 실행기로 부르도록 가르쳤습니다. 그의 관찰에 따르면 GPT-5.5는 대단히 조종 가능(steerable)해서, Fable이 GPT-5.5를 어떻게 몰아갈지 학습할 수 있다는 것입니다.

즉 Fable은 지휘자(conductor)로서 판단과 분기를 맡고, 반복적이고 양이 많은 구현은 더 싼 실행기에 위임합니다. 이렇게 하면 값비싼 지휘 모델의 토큰은 판단에만 쓰이고, 구현 물량은 다른 예산에서 나갑니다.

### 3. CLAUDE.md에 모델 우선순위를 명시

세 번째는 이 라우팅을 즉흥이 아니라 계약으로 굳히는 것입니다. Theo는 CLAUDE.md에 어떤 작업에 어떤 모델을 우선할지, 서브에이전트와 워크플로를 오케스트레이션할 때 어떻게 배분할지를 큰 섹션으로 적어 두었다고 했습니다.

이 대목이 특히 중요합니다. 라우팅 규칙을 문서에 박아 두면 세션마다 다시 판단할 필요가 없고, 팀 전체가 같은 배분 규율을 공유합니다. 반복되는 프롬프트를 규칙으로 만드는 것은 프롬프트 위생의 기본이기도 합니다.

### 4. 토큰 무거운 작업은 다른 모델에 위임하고 결과만 회수

마지막으로 Theo는 불필요하게 토큰을 많이 먹는 작업(컴퓨터 사용, 코드베이스 전수 분석 등)은 다른 모델로 처리한 뒤 결과만 Fable에 보고하도록 했습니다.

이것은 메인 컨텍스트 위생과 직결됩니다. 대용량 탐색 출력을 지휘 모델의 컨텍스트에 그대로 쏟으면, 이후 모든 턴에서 그 큰 컨텍스트를 다시 읽는 비용이 선형으로 붙습니다. 무거운 읽기는 하위 실행기가 처리하고 요약만 올리면, 지휘 모델의 컨텍스트는 깨끗하게 유지됩니다.

네 전략을 하나의 흐름으로 그리면 다음과 같습니다.

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
<div class="d3-arch" data-arch-root id="lemodelroutingratelimits-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 501, "height": 900, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 228, "y": 24, "w": 120, "h": 46, "title": "작업 도착"}, {"id": "B", "x": 219, "y": 148, "w": 138, "h": 52, "title": "작업 성격 분류"}, {"id": "C", "x": 193, "y": 430, "w": 191, "h": 46, "title": "Fable 5 지휘자 high effort"}, {"id": "D", "x": 228, "y": 292, "w": 120, "h": 46, "title": "저비용 실행기"}, {"id": "E", "x": 24, "y": 292, "w": 149, "h": 46, "title": "Codex GPT-5.5 실행기"}, {"id": "F", "x": 219, "y": 554, "w": 138, "h": 52, "title": "깊은 추론 필요?"}, {"id": "G", "x": 287, "y": 698, "w": 142, "h": 46, "title": "xhigh max 아껴서 승격"}, {"id": "H", "x": 112, "y": 698, "w": 120, "h": 46, "title": "high 유지"}, {"id": "I", "x": 228, "y": 822, "w": 120, "h": 46, "title": "결과 종합"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [288, 70, 288, 148]}, {"src": "B", "dst": "C", "kind": "data", "label": "판단 분기 오케스트레이션", "curve": [[338, 200], [427, 246], [427, 384], [334, 430]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "탐색 grep 파일읽기", "line": [288, 200, 288, 292], "lx": 288, "ly": 242}, {"src": "B", "dst": "E", "kind": "data", "label": "대량 구현", "curve": [[220, 200], [99, 246], [99, 246], [99, 292]], "off": "50%"}, {"src": "D", "dst": "C", "kind": "data", "label": "요약만 회수", "line": [288, 338, 288, 430], "lx": 288, "ly": 380}, {"src": "E", "dst": "C", "kind": "data", "label": "산출물 회수", "curve": [[99, 338], [99, 384], [99, 384], [225, 430]], "off": "50%"}, {"src": "C", "dst": "F", "kind": "data", "line": [288, 476, 288, 554]}, {"src": "F", "dst": "G", "kind": "data", "label": "예", "curve": [[313, 606], [358, 652], [358, 652], [358, 698]], "off": "50%"}, {"src": "F", "dst": "H", "kind": "data", "label": "아니오", "curve": [[246, 606], [172, 652], [172, 652], [172, 698]], "off": "50%"}, {"src": "G", "dst": "I", "kind": "data", "curve": [[358, 744], [358, 783], [358, 783], [314, 822]]}, {"src": "H", "dst": "I", "kind": "data", "curve": [[172, 744], [172, 783], [172, 783], [245, 822]]}]});
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
      const container = document.getElementById('lemodelroutingratelimits-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'lemodelroutingratelimits-1';
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

## ThakiCloud 제품 적용 시사점

Theo의 팁이 반갑게 읽히는 이유는, ThakiCloud가 운영하는 에이전트 플랫폼 Paxis가 이미 같은 원칙 위에 서 있기 때문입니다. Paxis는 ai-platform 위에서 도는 Agent-Native Cloud 제어 평면으로, 스킬과 도구, 정책, 감사 로그를 일급 리소스로 다룹니다. 그 안에서 모델 라우팅은 장식이 아니라 비용 구조의 뼈대입니다.

우리의 서브에이전트 라우팅 규율은 Theo의 4번 전략과 정확히 같은 곳을 겨냥합니다. 탐색과 파일 읽기는 가장 싼 티어로, 구현과 리뷰는 중간 티어로, 아키텍처와 복잡한 다단계 추론만 최상위 티어로 보냅니다. 서브에이전트는 대용량 출력을 원본 그대로 올리지 않고 요약과 파일 경로만 회수합니다. 지휘 모델의 컨텍스트를 깨끗하게 유지하는 이 규칙은 Theo가 "결과만 보고하라"고 말한 것과 같은 실천입니다.

지휘자와 실행기를 나누는 2번 전략도 Paxis의 설계와 맞닿아 있습니다. Paxis의 스킬 하니스는 960개가 넘는 스킬을 BM25로 선택해 격리된 샌드박스에서 실행하는데, 이때 오케스트레이션 레이어는 가벼운 판단만 맡고 무거운 실행은 별도 워커로 격리됩니다. 값비싼 판단 모델을 라우팅과 집약에만 쓰고, 실제 중노동은 더 싼 워커에 배치하는 구조는 Theo가 Fable을 지휘자로, Codex를 실행기로 둔 것과 같은 그림입니다.

3번 전략, 즉 라우팅을 문서와 정책으로 굳히는 발상은 Paxis에서는 정책 게이트와 감사 로그로 구현됩니다. 어떤 작업이 어떤 자원으로 흘러야 하는지를 즉흥 판단이 아니라 명시된 규칙으로 고정하면, 자율 에이전트가 오래 돌아도 배분 규율이 흔들리지 않습니다.

인프라 층에서는 ai-platform 렌즈도 함께 작동합니다. 모델을 K8s와 Kueue 기반 GPU 위에서 서빙할 때, 저난도 요청을 작은 모델과 낮은 배치 우선순위로 흘려보내면 GPU 시간이 절약되고, 그 절약이 다시 에이전트 경제성으로 이어집니다. 낮은 서빙 비용이 곧 더 공격적인 라우팅을 감당할 여력을 만들어 줍니다. 요컨대 저비용 서빙(ai-platform)이 에이전트 오케스트레이션의 경제성(Paxis)을 떠받치는 구조입니다.

## 한계 및 반론

이 접근에도 약점은 있습니다. 첫째, 라우팅이 복잡해질수록 관리 비용이 생깁니다. 모델을 여러 개 엮으면 각 모델의 컨텍스트 창, 가격, 가용성이 서로 달라 디버깅이 어려워집니다. 지휘자가 실행기의 출력을 잘못 해석하면 오히려 왕복이 늘어 토큰을 더 씁니다.

둘째, "high가 항상 최선"은 Theo 개인의 관찰이며 작업 종류에 따라 다릅니다. 정말로 어려운 아키텍처 판단이나 미묘한 버그 추적에서는 더 높은 effort가 값을 합니다. 규칙은 기본값일 뿐, 예외를 판단하는 눈이 여전히 필요합니다.

셋째, 서로 다른 벤더의 모델을 섞는 오케스트레이션은 데이터 흐름과 보안 경계를 넓힙니다. 코드베이스 분석을 외부 실행기에 넘길 때 무엇이 그 모델의 컨텍스트로 들어가는지 반드시 통제해야 합니다. Paxis가 모든 행동을 정책 게이트와 감사 로그로 통과시키는 이유가 바로 여기에 있습니다.

결론적으로 레이트리밋은 더 비싼 요금제로 밀어붙일 문제가 아니라 배분으로 푸는 문제입니다. 싸게 시작하고, 무거운 판단에만 비싼 모델을 쓰며, 그 규칙을 문서와 정책으로 굳히는 것. 이것이 Theo의 네 가지 팁이 공통으로 가리키는 방향이자, ThakiCloud가 Paxis에서 매일 실천하는 규율입니다.

## 출처

- Theo(@theo), "I've been getting a TON done with Fable today and I'm not hitting rate limits": [x.com/theo/status/2072481845363822914](https://x.com/theo/status/2072481845363822914)
- "T3 Stack creator Theo shares Fable AI workflow", digg.com: [digg.com/tech/wmowks0x](https://digg.com/tech/wmowks0x)
- "Fable Is Back. Here's How to Actually Code With It", Wavect: [wavect.io/blog/coding-with-claude-fable-5](https://wavect.io/blog/coding-with-claude-fable-5/)
