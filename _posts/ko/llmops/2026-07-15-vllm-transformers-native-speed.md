---
title: "한 번만 구현하면 vLLM 네이티브 속도로: Transformers 백엔드가 서빙 이중화를 끝내다"
excerpt: "지금까지 새 모델 아키텍처는 두 번 만들어야 했습니다. 한 번은 학습·연구를 위한 Transformers에서, 또 한 번은 프로덕션 추론을 위한 vLLM에서요. vLLM v0.25.0의 네이티브 속도 Transformers 백엔드는 이 이중화를 끝냅니다. 원리는 torch.fx로 모델 그래프를 정적 분석해 어텐션·정규화·MLP 같은 알려진 패턴을 찾아 vLLM의 최적화 커널로 다시 붙이는 것입니다. 저희는 이 백엔드가 실제로 수행하는 그래프 분석 단계를 4층 디코더로 직접 재현해, 178개 노드 중 어떤 것들이 퓨전 대상이 되는지 실측했습니다. 그리고 이것이 멀티테넌트로 오픈웨이트 모델을 서빙하는 ThakiCloud 인프라에 무엇을 의미하는지 짚어봅니다."
tags:
  - vllm
  - transformers
  - inference
  - serving
  - torch-fx
  - llmops
  - self-hosting
  - open-weights
  - paxis
date: 2026-07-15
lang: ko
canonical_url: "https://thakicloud.com/tech-blog/ko/llmops/vllm-transformers-native-speed/"
categories:
  - llmops
---

## 개요

오픈웨이트 모델을 직접 서빙해 본 팀이라면 익숙한 벽이 하나 있습니다. 좋은 모델이 공개되었는데, 정작 그 모델을 빠르게 추론하려면 서빙 엔진이 그 아키텍처를 지원할 때까지 기다려야 한다는 벽입니다. Transformers 라이브러리에 올라온 새 구조는 학습과 연구에는 곧바로 쓸 수 있지만, vLLM 같은 고성능 추론 엔진에서 제 속도를 내려면 누군가가 그 아키텍처를 vLLM 안에 처음부터 다시 구현해야 했습니다. 같은 모델을 사실상 두 번 만드는 셈이었습니다.

이 글은 추론 비용과 서빙 지연을 책임지는 엔지니어링 리더, 온프레미스나 소버린 환경에서 오픈웨이트 모델을 직접 굴리는 실무자, 그리고 새 아키텍처를 실험하면서 배포 속도를 걱정하는 데이터 과학자를 위한 것입니다. 2026년 7월, Hugging Face의 Clement Delangue가 오픈소스 추론의 큰 전환점을 공유했습니다. vLLM v0.25.0부터 Transformers 모델을 vLLM 안에서 **네이티브 속도로** 돌릴 수 있게 되었고, 많은 경우 손으로 짠 전용 구현과 대등하거나 그것을 앞선다는 내용이었습니다.

핵심은 이렇습니다. 모델 저자가 아키텍처를 Transformers에 한 번만 구현하면, vLLM의 최적화된 추론 스택을 별도 작업 없이 그대로 누릴 수 있게 되었다는 것입니다. 저희는 이 주장을 개념으로만 받아들이지 않고, 이 백엔드가 내부적으로 수행하는 그래프 분석 단계를 작은 디코더 블록으로 직접 재현해 실측했습니다. 이 글은 그 원리와 측정 과정, 그리고 이것이 멀티테넌트로 다양한 모델을 서빙하는 저희 인프라에 어떤 의미인지를 풀어냅니다.

## 이 기술은 무엇인가

`--model-impl transformers` 플래그 하나면, vLLM은 전용으로 포팅된 구현 대신 Transformers 라이브러리의 모델 정의를 그대로 불러와 서빙합니다. 겉보기에는 단순한 호환 계층 같지만, v0.25.0의 백엔드가 특별한 이유는 이 호환성이 더 이상 속도를 희생하지 않기 때문입니다. 예전의 호환 경로는 "돌아가기는 하지만 느린" 폴백에 가까웠습니다. 이제는 컴파일 타임이 아니라 런타임에 추론 전용 레이어 퓨전을 동적으로 적용해, 호환 가능한 아키텍처라면 전용 코드에 필적하는 속도를 냅니다.

그 원리를 조금 더 들여다보면 두 단계로 나뉩니다. 먼저 백엔드는 `torch.fx`로 모델의 연산 그래프를 정적 분석해, 어텐션 점수 계산, RMSNorm 정규화, SwiGLU MLP, Mixture-of-Experts 같은 최적화 가능한 패턴을 찾습니다. 그다음 추상 구문 트리를 조작해 그 부분의 소스를 제자리에서 다시 쓰고, 찾아낸 연산을 vLLM의 최적화 커널로 매핑합니다. MoE 모델이라면 Expert Parallelization 커널에, 어텐션이라면 페이지드 어텐션 계열 커널에 붙는 식입니다. 결국 Transformers가 표현한 아키텍처 위에 vLLM이 처리량과 지연을 최적화해 얹는 구조입니다.

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
<div class="d3-arch" data-arch-root id="mtransformersnativespeed-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 391, "height": 1070, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 147, "y": 24, "w": 120, "h": 46, "title": "새 모델 아키텍처"}, {"id": "B", "x": 126, "y": 148, "w": 163, "h": 62, "title": ["Transformers로 1회 구현", "학습·연구용"]}, {"id": "C", "x": 138, "y": 288, "w": 138, "h": 52, "title": "vLLM 서빙 방식"}, {"id": "D", "x": 239, "y": 836, "w": 120, "h": 62, "title": ["vLLM에 재구현", "전용 커널 수작업 포팅"]}, {"id": "E", "x": 38, "y": 432, "w": 156, "h": 46, "title": "torch.fx 정적 그래프 분석"}, {"id": "F", "x": 24, "y": 556, "w": 184, "h": 62, "title": ["알려진 패턴 탐지", "어텐션·RMSNorm·SwiGLU·MoE"]}, {"id": "G", "x": 56, "y": 696, "w": 120, "h": 62, "title": ["ast로 소스 재작성", "런타임 레이어 퓨전"]}, {"id": "H", "x": 49, "y": 836, "w": 135, "h": 62, "title": ["vLLM 최적화 커널에 매핑", "EP·페이지드 어텐션"]}, {"id": "I", "x": 136, "y": 976, "w": 142, "h": 62, "title": ["네이티브 속도 추론", "4B~235B 매칭 또는 추월"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [207, 70, 207, 148]}, {"src": "B", "dst": "C", "kind": "data", "line": [207, 210, 207, 288]}, {"src": "C", "dst": "D", "kind": "data", "label": "과거", "curve": [[240, 340], [299, 517], [299, 727], [299, 836]], "off": "50%"}, {"src": "C", "dst": "E", "kind": "data", "label": "현재: model-impl transformers", "curve": [[174, 340], [116, 386], [116, 386], [116, 432]], "off": "50%"}, {"src": "E", "dst": "F", "kind": "data", "line": [116, 478, 116, 556]}, {"src": "F", "dst": "G", "kind": "data", "line": [116, 618, 116, 696]}, {"src": "G", "dst": "H", "kind": "data", "line": [116, 758, 116, 836]}, {"src": "H", "dst": "I", "kind": "data", "curve": [[116, 898], [116, 937], [116, 937], [167, 976]]}, {"src": "D", "dst": "I", "kind": "data", "curve": [[299, 898], [299, 937], [299, 937], [248, 976]]}]});
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
      const container = document.getElementById('mtransformersnativespeed-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'mtransformersnativespeed-1';
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

이 변화의 실질적 의미는 서빙 엔진과 모델 생태계 사이의 시차가 사라진다는 데 있습니다. 과거에는 새 아키텍처가 나올 때마다 학습용 구현과 추론용 구현이라는 두 개의 코드베이스가 필요했고, 둘 사이의 간극이 곧 "좋은 모델이 나왔지만 아직 빠르게 서빙할 수 없는" 공백이었습니다. 이제 그 공백이 좁아집니다. 커스텀 아키텍처를 실험하는 연구팀이든, 갓 공개된 모델을 프로덕션에 올리려는 운영팀이든, Transformers 구현 하나로 vLLM 속도를 얻습니다.

## 설치 및 통합

이 백엔드는 별도 패키지가 아니라 vLLM 자체에 포함됩니다. v0.25.0 이상의 vLLM을 설치한 뒤 서빙 명령에 `--model-impl transformers`를 붙이면 됩니다. Hugging Face 블로그가 제시한 실제 예시는 다음과 같습니다.

```bash
# 단일 GPU, 밀집(dense) 모델
vllm serve Qwen/Qwen3-4B --model-impl transformers

# 텐서 병렬 2장, 대형 밀집 모델
vllm serve Qwen/Qwen3-32B \
  --model-impl transformers \
  --tensor-parallel-size 2

# 데이터 병렬 + 전문가 병렬, MoE 모델
vllm serve Qwen/Qwen3-235B-A22B-FP8 \
  --model-impl transformers \
  --data-parallel-size 8 \
  --enable-expert-parallel
```

파이썬 API에서도 동일하게 오프라인 추론에 쓸 수 있습니다.

```python
from vllm import LLM, SamplingParams

llm = LLM(
    model="Qwen/Qwen3-4B",
    model_impl="transformers",   # 전용 포팅 대신 Transformers 정의 사용
)
out = llm.generate(
    ["ThakiCloud는 오픈웨이트 모델을 어떻게 서빙하나요?"],
    SamplingParams(max_tokens=256, temperature=0.7),
)
print(out[0].outputs[0].text)
```

세 예시에서 눈여겨볼 점은 텐서 병렬, 데이터 병렬, 전문가 병렬 같은 분산 서빙 옵션이 Transformers 백엔드에서도 그대로 동작한다는 것입니다. 즉 호환성을 얻는 대가로 스케일 아웃을 포기하지 않아도 됩니다. 밀집 4B 모델부터 235B MoE까지 같은 플래그 하나로 커버됩니다.

## 실제 실험 결과

이 환경은 macOS(Apple Silicon)라 vLLM의 CUDA 커널을 실행할 수 없어, vLLM 처리량 벤치마크 자체는 재현하지 못했습니다. 대신 이 백엔드가 내부적으로 수행하는 **가장 핵심적인 단계, 즉 torch.fx로 모델 그래프를 정적 분석해 퓨전 대상 패턴을 찾아내는 과정**을 CPU에서 직접 재현했습니다. 실제 서빙 모델과 같은 구조(그룹 쿼리 어텐션과 SwiGLU MLP)를 가진 4층 Llama 계열 디코더를 순수 PyTorch로 만들고, `torch.fx.symbolic_trace`로 그래프를 떠서 노드를 분류했습니다.

측정 결과는 다음과 같았습니다. 파라미터 2.902M의 이 작은 디코더를 추적하니 torch.fx 그래프에 총 **178개의 노드**가 잡혔습니다. 연산 종류별로는 함수 호출 80개, 메서드 호출 60개, 모듈 호출 28개, 속성 조회 8개였습니다. 이 가운데 백엔드가 곧바로 퓨전 커널로 바꿀 수 있는 함수 수준 패턴은 RMSNorm 리덕션 16개, 어텐션 관련 행렬곱 8개, 소프트맥스 4개, SwiGLU 활성화 4개로 합계 32개였고, 여기에 QKV·출력·MLP 투영과 정규화를 담은 모듈 호출 28개가 더해집니다. 순전파 지연은 시퀀스 길이 64에서 평균 1.4ms였으며 torch 2.13.0에서 측정했습니다.

![torch.fx 그래프에서 퓨전 대상이 되는 노드 분포를 보여주는 막대 차트]({{ '/assets/images/vllm-transformers-native-speed-results.webp' | relative_url }})

이 숫자가 말해주는 바는 분명합니다. 178개 노드짜리 작은 블록 하나에서도 어텐션과 정규화, MLP 활성화라는 정형화된 패턴이 반복적으로 나타나고, 이것들이 바로 백엔드가 노려 vLLM 커널로 치환하는 지점입니다. 실제 수십 층짜리 대형 모델에서는 이 패턴이 층수만큼 곱해지므로, 그래프 분석 한 번으로 모델 전체의 병목 연산을 일괄 퓨전할 수 있게 됩니다. Hugging Face가 밝힌 바에 따르면 이 방식으로 Transformers 백엔드는 4B부터 235B까지, 텐서 병렬과 MoE 구성을 포함해 네이티브 vLLM 처리량과 대등하거나 그것을 앞섰습니다. 저희 실험은 그 처리량 수치를 재현한 것이 아니라, 그 처리량이 나오는 **메커니즘의 뼈대**를 실측으로 확인한 것입니다.

## ThakiCloud 제품 적용 시사점

ThakiCloud의 **ai-platform**은 K8s와 Kueue 기반 GPU 스케줄링 위에서 다양한 고객 환경에 모델을 서빙하는 멀티테넌트 AI/ML 인프라입니다. 이 백엔드는 저희 같은 서빙 사업자에게 직접적인 이득입니다. 첫째, **모델 온보딩 리드타임이 줄어듭니다.** 새 오픈웨이트 모델이 공개되면 지금까지는 vLLM이 그 아키텍처를 정식 지원할 때까지 기다리거나 자체 포팅을 감수해야 했지만, Transformers에 구현이 있으면 `--model-impl transformers`로 곧바로 최적화된 속도의 서빙 파드를 띄울 수 있습니다. 이는 "새 모델을 얼마나 빨리 제품에 태우느냐"라는 경쟁력에 직결됩니다.

둘째, **커스텀 아키텍처의 서빙 경로가 단순해집니다.** 특정 고객을 위해 미세조정하거나 구조를 변형한 모델을 온프레미스에서 서빙할 때, 전용 vLLM 포팅 없이 Transformers 정의만으로 배포할 수 있다면 유지보수 부담이 크게 줄어듭니다. 소버린 클라우드나 규제 환경처럼 self-hosting이 요구되는 경우, 엔진과 모델의 버전 정합성을 맞추느라 소모하던 시간이 절약됩니다. 텐서·데이터·전문가 병렬이 그대로 지원되므로, 저희가 이미 운용하는 멀티 GPU 서빙 토폴로지를 바꾸지 않고도 이 경로를 채택할 수 있습니다.

에이전트 관점에서는 **Paxis** 렌즈도 맞닿습니다. Paxis는 ai-platform 위에서 도는 Agent-Native Cloud 제어 평면으로, 다양한 모델을 도구처럼 갈아 끼우며 에이전트를 실행합니다. 서빙 계층이 새 오픈웨이트 모델을 더 빠르고 저렴하게 올릴 수 있다는 것은, 그 위에서 도는 에이전트가 선택할 수 있는 모델 풀이 넓어지고 교체 비용이 낮아진다는 뜻입니다. 저비용·저지연 서빙이 결국 에이전트 워크로드의 경제성을 만든다는 점에서, ai-platform의 서빙 효율과 Paxis의 에이전트 유연성은 같은 방향을 봅니다.

## 한계 및 반론

이 백엔드가 만능은 아닙니다. 몇 가지 분명한 한계를 짚어야 공정합니다. 먼저 성능 이점은 "호환 가능한 아키텍처"에 한정됩니다. torch.fx가 정적으로 추적할 수 있어야 하고, 백엔드가 알고 있는 패턴에 들어맞아야 퓨전이 적용됩니다. 동적 제어 흐름이 심하거나 아직 알려지지 않은 신형 연산을 쓰는 구조라면 일부는 퓨전되지 않은 경로로 폴백하며, 그만큼 속도 이점이 줄어듭니다. 즉 모든 Transformers 모델이 자동으로 네이티브 속도를 내는 것은 아닙니다.

둘째, 이 기능은 v0.25.0에서 성숙 단계에 들어섰을 뿐 여전히 진화 중입니다. 특정 양자화 조합, 특정 어텐션 변형, 드문 MoE 라우팅 방식 등에서는 전용 포팅 구현이 여전히 더 안정적이거나 빠를 수 있습니다. 프로덕션에 올리기 전에는 대상 모델과 대상 하드웨어에서 실제 처리량과 정확도를 각자 벤치마크해 확인하는 편이 안전합니다. 저희가 이 글에서 vLLM 처리량 수치를 직접 인용하지 않고 공식 발표에 귀속한 것도 같은 이유입니다. 수치는 환경에 따라 달라지므로, ThakiCloud GPU 클러스터를 대상으로 한 실측은 별도로 진행할 예정입니다.

셋째, 반론도 가능합니다. 서빙 엔진과 모델 라이브러리가 강하게 결합되면, Transformers의 변경이 서빙 안정성에 영향을 줄 여지가 생깁니다. 두 코드베이스를 분리해 유지하던 시절에는 추론 스택을 독립적으로 고정할 수 있었지만, 백엔드를 공유하면 버전 관리 전략을 다시 짜야 합니다. 그럼에도 새 모델을 두 번 구현하던 비용에 견주면, 이 결합이 주는 온보딩 속도의 이득이 대부분의 서빙 시나리오에서 더 크다고 저희는 판단합니다.

## 출처

- [Native-speed vLLM transformers modeling backend (Hugging Face Blog)](https://huggingface.co/blog/native-speed-vllm-transformers-backend)
- [vLLM v0.25.0: transformers backend now matches native vLLM speed (daily.dev)](https://daily.dev/posts/vllm-v0-25-0-transformers-backend-now-matches-native-vllm-speed-z8kvnsk7c)
- [Transformers modeling backend integration in vLLM (vLLM Blog)](https://blog.vllm.ai/2025/04/11/transformers-backend.html)
- [Clement Delangue (@ClementDelangue) on X](https://x.com/ClementDelangue/status/2076763231788339669)
- 실험 코드·로그: `outputs/blog-impl/vllm-transformers-native-speed/` (torch.fx 그래프 분석 재현, torch 2.13.0, CPU)
