---
title: "Kimi K3, 2.8조 파라미터 오픈웨이트를 실제로 서빙한다는 것"
excerpt: "Moonshot이 세계 최대 규모의 오픈웨이트 모델 Kimi K3를 공개했습니다. 프론트엔드 코딩 벤치마크에서 최상위 폐쇄 모델을 앞섰다는 점도 놀랍지만, 진짜 질문은 그 다음입니다. 2.8조 파라미터 모델을 자체 인프라에서 돌린다는 것은 실제로 무엇을 요구하는가. 다키클라우드 서빙 관점에서 정리했습니다."
date: 2026-07-18
tags:
  - KimiK3
  - 오픈웨이트
  - MoE
  - LLM서빙
  - 온프레미스
  - 소버린AI
  - LLMOps
  - 프론트엔드코딩
author_profile: true
toc: true
toc_label: 오픈웨이트 프론티어
categories:
  - llmops
  - owm
published: false
---

## 개요

2026년 7월 16일, 중국의 Moonshot AI가 Kimi K3를 공개했습니다. 총 2.8조 파라미터로, 현재까지 공개된 오픈웨이트 모델 가운데 가장 큰 규모입니다. 여러 매체가 이 릴리스를 두고 오픈웨이트 진영이 프론티어 수준에 도달한 사건이라고 평가했습니다.

가장 눈길을 끈 대목은 프론트엔드였습니다. AI 평가 플랫폼 Arena가 웹 인터페이스 구축 능력을 측정한 벤치마크에서 Kimi K3를 1위에 올렸고, 블라인드 테스트에서 개발자들은 프론트엔드 코딩에 있어 Anthropic의 Fable 5나 OpenAI의 GPT-5.6보다 Kimi를 더 선호했다고 보고되었습니다. Moonshot은 이를 웹 브라우저 안에서 Three.js와 WebGPU로 3D 오픈월드 게임을 만들어 내는 데모로 시연했습니다.

이 글은 벤치마크 순위를 되풀이하기보다, 그 다음 질문에 집중합니다. 오픈웨이트라는 말은 곧 누구나 이 모델을 자체 인프라에서 돌릴 수 있다는 뜻입니다. 그렇다면 2.8조 파라미터 모델을 실제로 서빙한다는 것은 무엇을 요구하는가. 다키클라우드는 고객사의 온프레미스 환경에서 모델을 서빙하는 것을 핵심 역량으로 삼고 있으므로, 이 릴리스를 운영자의 눈으로 읽어 보겠습니다.

## Kimi K3는 무엇인가

Kimi K3는 전문가 혼합, 곧 MoE 구조의 모델입니다. 총 2.8조 파라미터를 가지고 있지만, 하나의 토큰을 처리할 때 그 전부가 활성화되는 것은 아닙니다. 공개된 정보에 따르면 총 896개의 전문가 중 16개를 활성화하며, 이때 실제로 계산에 쓰이는 활성 파라미터 수는 약 500억 개 수준으로 추정됩니다[추정]. Moonshot은 활성 파라미터 수를 공식적으로 공개하지 않았습니다.

구조적으로는 두 가지 혁신이 소개되었습니다. 하나는 Kimi Delta Attention(KDA)이고, 다른 하나는 Attention Residuals(AttnRes)입니다. Moonshot은 이 둘이 효율과 추론 품질을 함께 끌어올린다고 설명합니다. 컨텍스트 길이는 100만 토큰으로, 긴 문맥을 다루는 에이전트 워크로드를 겨냥한 설계로 읽힙니다.

라이선스에 관해서는 신중할 필요가 있습니다. 직전 세대인 Kimi K2 계열은 2025년 7월에 수정 MIT 라이선스로 공개된 바 있으나, K3의 라이선스 조건 자체는 이 글을 쓰는 시점에 아직 확정 공개되지 않았습니다. Moonshot은 K3를 오픈이라고 부르며 전체 가중치를 2026년 7월 27일까지 공개하겠다고 예고했지만, 공개 시점 기준으로 공식 체크포인트가 Hugging Face 조직 계정에 아직 올라오지 않은 상태였습니다. 따라서 실제 도입을 검토한다면 최종 라이선스 문구와 가중치 공개 여부를 반드시 직접 확인해야 합니다.

## 왜 이 릴리스가 중요한가

오픈웨이트 모델이 특정 좁은 과제에서 최상위 폐쇄 모델을 앞서는 일은 이제 드물지 않습니다. 그러나 프론트엔드 코딩처럼 실무 개발자가 매일 쓰는 영역에서, 그것도 세계 최대 규모의 공개 가중치로 그 자리를 차지했다는 점은 의미가 다릅니다. 이는 성능 때문에 어쩔 수 없이 폐쇄 API에 종속되던 구조에, 자체적으로 운영 가능한 대안이 생겼다는 신호이기 때문입니다.

특히 프론트엔드와 UI 생성은 결과물을 눈으로 즉시 확인할 수 있는 영역입니다. Moonshot이 강조한 비전 인 더 루프, 곧 생성한 화면을 모델이 다시 보고 교정하는 순환 구조가 게임 개발, 사용자 인터페이스 설계, 컴퓨터 지원 설계 같은 시각적 과제에서 특히 유용하다는 주장도 이 맥락에 있습니다. 코드를 텍스트로만 생성하는 것을 넘어, 렌더링된 결과를 피드백으로 삼는다는 발상입니다.

## 2.8조 파라미터를 실제로 서빙한다는 것

여기서부터가 운영자의 영역입니다. 오픈웨이트라는 사실과 자체 서빙이 가능하다는 사실 사이에는 상당한 거리가 있습니다.

먼저 메모리입니다. 총 2.8조 파라미터를 원래의 정밀도로 그대로 올리려면 수 테라바이트 규모의 GPU 메모리가 필요합니다. 이는 단일 GPU는 물론이고 GPU 한 대에 여러 장을 꽂은 서버 한 대로도 감당하기 어려운 수준으로, 여러 노드에 걸친 분산 서빙이 전제됩니다. 다만 MoE 구조라는 점이 부담을 다소 덜어 줍니다. 매 토큰마다 전체가 아니라 일부 전문가만 활성화되므로, 계산량 자체는 활성 파라미터 규모에 가깝게 유지됩니다. 그럼에도 모든 전문가의 가중치는 언제든 호출될 수 있도록 메모리에 상주해야 하므로, 저장 부담은 총 파라미터를 따라갑니다.

그래서 현실적인 자체 서빙에는 두 가지 기법이 거의 필수로 따라옵니다. 하나는 양자화입니다. 가중치를 8비트나 4비트로 낮춰 메모리 사용량을 줄이면, 필요한 GPU 대수를 크게 낮출 수 있습니다. 다른 하나는 병렬화입니다. 텐서 병렬로 모델을 여러 GPU에 쪼개 싣고, MoE 모델의 경우 전문가 병렬을 더해 전문가들을 여러 장치에 분산합니다. 서빙 경로를 그림으로 잡으면 다음과 같습니다.

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
<div class="d3-arch" data-arch-root id="penweightfrontierserving-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 351, "height": 1070, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 112, "y": 24, "w": 120, "h": 46, "title": "사용자 요청"}, {"id": "B", "x": 112, "y": 148, "w": 120, "h": 62, "title": ["라우팅 게이트", "토큰별 전문가 선택"]}, {"id": "C", "x": 103, "y": 288, "w": 138, "h": 68, "title": ["활성 전문가만", "16 of 896"]}, {"id": "D", "x": 199, "y": 434, "w": 120, "h": 62, "title": ["텐서 병렬", "레이어를 GPU에 분할"]}, {"id": "E", "x": 24, "y": 434, "w": 120, "h": 62, "title": ["전문가 병렬", "전문가를 노드에 분산"]}, {"id": "F", "x": 112, "y": 574, "w": 120, "h": 62, "title": ["양자화된 가중치", "4비트 또는 8비트"]}, {"id": "G", "x": 112, "y": 714, "w": 120, "h": 46, "title": "분산 추론 실행"}, {"id": "H", "x": 112, "y": 838, "w": 120, "h": 46, "title": "응답 스트리밍"}, {"id": "I", "x": 112, "y": 976, "w": 120, "h": 62, "title": ["다중 노드", "GPU 메모리"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [172, 70, 172, 148]}, {"src": "B", "dst": "C", "kind": "data", "line": [172, 210, 172, 288]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[212, 356], [259, 395], [259, 395], [259, 434]]}, {"src": "C", "dst": "E", "kind": "data", "curve": [[131, 356], [84, 395], [84, 395], [84, 434]]}, {"src": "D", "dst": "F", "kind": "data", "curve": [[259, 496], [259, 535], [259, 535], [210, 574]]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[84, 496], [84, 535], [84, 535], [133, 574]]}, {"src": "F", "dst": "G", "kind": "data", "line": [172, 636, 172, 714]}, {"src": "G", "dst": "H", "kind": "data", "line": [172, 760, 172, 838]}, {"src": "H", "dst": "I", "kind": "event", "label": "KV 캐시 페이지", "line": [172, 884, 172, 976], "lx": 172, "ly": 926}]});
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
      const container = document.getElementById('penweightfrontierserving-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'penweightfrontierserving-1';
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

핵심은 이것입니다. 오픈웨이트는 가중치를 무료로 준다는 뜻이지, 서빙이 무료라는 뜻이 아닙니다. 이 규모의 모델을 자체 인프라에서 안정적으로 돌리려면 다중 노드 GPU 클러스터, 양자화 파이프라인, 분산 추론 엔진, 그리고 그것들을 묶는 스케줄링과 관측 계층이 함께 있어야 합니다. 바로 이 지점에서 플랫폼의 가치가 드러납니다.

## ThakiCloud 제품 적용 시사점

이 릴리스는 다키클라우드의 두 제품이 왜 필요한지를 동시에 보여 줍니다.

먼저 인프라 관점, 곧 ai-platform입니다. 다키클라우드의 ai-platform은 쿠버네티스 기반의 AI/ML 인프라로, Kueue를 통한 GPU 스케줄링, 멀티테넌트 격리, 분산 서빙, 관측성을 제공합니다. Kimi K3 같은 초대형 오픈웨이트 모델을 자체 인프라에서 서빙하려는 고객사에게 이 계층은 선택이 아니라 전제입니다. 다중 노드에 걸친 GPU 자원을 정책으로 관리하고, 양자화와 병렬화를 적용한 서빙을 운영 가능한 형태로 묶어 내는 일이 곧 도입 가능성 그 자체를 결정하기 때문입니다. 데이터를 외부로 내보낼 수 없는 소버린 환경에서, 프론티어급 오픈웨이트 모델을 자체적으로 돌릴 수 있다는 것은 그 자체로 강력한 도입 명분이 됩니다.

다음으로 에이전트 관점, 곧 Paxis입니다. Kimi K3의 강점이 프론트엔드 코딩과 시각적 생성에 있다는 점은 코딩 에이전트와 직결됩니다. Paxis는 다키클라우드의 Agent-Native Cloud로, 스킬과 도구, 정책, 감사 로그를 일급 리소스로 다룹니다. 격리된 샌드박스에서 스킬을 실행하고, 다중 에이전트를 DAG로 오케스트레이션하며, 모든 행동을 정책 게이트와 감사 로그로 통과시킵니다. 코드를 생성하고 그 결과를 다시 확인하며 교정하는 비전 인 더 루프 방식의 에이전트를, 안전한 실행 경계 안에서 운영하려는 조직에게 이런 제어 평면은 필수입니다. 강력한 오픈웨이트 코딩 모델과 안전한 에이전트 실행 환경이 결합할 때, 자체 인프라 위에서 도는 실용적인 코딩 에이전트가 완성됩니다.

두 관점은 서로를 보완합니다. 낮은 비용의 자체 서빙(ai-platform)이 있어야 에이전트를 상시 돌리는 경제성(Paxis)이 성립하고, 강력한 에이전트 워크로드(Paxis)가 있어야 그 서빙 인프라(ai-platform)에 존재 이유가 생깁니다.

## 한계 및 반론

과열된 분위기와 별개로, 냉정하게 남길 지점이 있습니다.

첫째, 이 글을 쓰는 시점에 전체 가중치가 아직 완전히 공개되지 않았을 가능성이 있고 최종 라이선스 조건도 확정되지 않았습니다. 벤치마크 성적과 실제로 손에 넣어 상업적으로 운영할 수 있는 모델은 다른 문제입니다. 도입을 검토한다면 발표 자료가 아니라 실제 공개된 가중치와 라이선스 문구를 근거로 판단해야 합니다.

둘째, 벤치마크 1위가 곧 모든 상황에서의 우위를 뜻하지는 않습니다. 프론트엔드 선호도 테스트는 특정 과제에서의 상대 평가이며, 자사의 실제 워크로드에서 어떻게 동작하는지는 직접 검증해야 합니다. 남이 보고한 순위를 그대로 자신의 결과로 가정하는 것은 위험합니다.

셋째, 자체 서빙의 총비용은 결코 작지 않습니다. 2.8조 파라미터 모델을 다중 노드에서 돌리는 데 드는 GPU, 전력, 운영 인력을 계산하면, 트래픽이 적은 조직에게는 폐쇄 API를 쓰는 편이 오히려 저렴할 수 있습니다. 오픈웨이트의 진짜 이점은 무조건적인 저비용이 아니라, 데이터 주권과 종속성 회피, 그리고 충분한 규모에서의 비용 통제 가능성에 있습니다. 자신의 트래픽 규모와 데이터 요구를 먼저 계산한 뒤에 결정해야 합니다.

## 출처

- [China's Moonshot AI releases Kimi K3, the largest open-source model ever (VentureBeat)](https://venturebeat.com/technology/chinas-moonshot-ai-releases-kimi-k3-the-largest-open-source-model-ever-rivaling-top-u-s-systems)
- [Moonshot AI Releases Kimi K3: A 2.8 Trillion Parameter Open MoE Model With Kimi Delta Attention (MarkTechPost)](https://www.marktechpost.com/2026/07/16/moonshot-ai-releases-kimi-k3-a-2-8-trillion-parameter-open-moe-model-with-kimi-delta-attention-and-1m-context/)
- [China's open-weight Kimi model stuns AI world with frontier-level results (Axios)](https://www.axios.com/2026/07/16/moonshot-kimi-ai-china-model-openai-anthropic)
- [China's Moonshot throws down the gauntlet with Kimi K3 (SiliconANGLE)](https://siliconangle.com/2026/07/16/chinas-moonshot-throws-gauntlet-kimi-k3-worlds-largest-open-weights-model/)
