---
title: "vLLM v0.25.0: Model Runner V2가 기본값이 되고 PagedAttention이 사라졌습니다"
excerpt: "vLLM v0.25.0이 232명의 기여자가 보낸 558개의 커밋과 함께 나왔습니다. 이번 릴리스의 핵심은 두 가지입니다. 첫째, Model Runner V2가 모든 밀집 모델의 기본 실행 경로가 되었습니다. 둘째, vLLM을 처음 유명하게 만든 PagedAttention의 레거시 구현이 코드베이스에서 삭제되었습니다. 여기에 효율적 비디오 샘플링(EVS), 동적 추측 디코딩, Mamba 하이브리드 접두어 캐싱이 더해졌습니다. 서빙 인프라를 운영하는 관점에서 무엇이 바뀌었고 어떤 마이그레이션을 준비해야 하는지 정리합니다."
tags:
  - dev
  - vllm
  - inference
  - serving
  - cuda
  - self-hosting
  - kubernetes
  - paxis
date: 2026-07-12
lang: ko
canonical_url: "https://thakicloud.com/tech-blog/ko/dev/vllm-v0-25-0-model-runner-v2/"
categories:
  - dev
audiobook: /assets/audio/posts/vllm-v0-25-0-model-runner-v2/audiobook-ko.mp3
audiobook_note: "AI 로컬 합성 오디오북 (Qwen3-TTS)"
---

## 개요

vLLM은 오픈 웨이트 LLM을 프로덕션에서 서빙할 때 사실상의 표준 추론 엔진입니다. 높은 처리량과 다양한 하드웨어 지원 덕분에, 자체 GPU에 모델을 올려 서빙하는 팀 대부분이 vLLM을 거칩니다. 그런 엔진의 새 릴리스는 단순한 버전 올림이 아니라, 서빙 스택 전체의 운영 방식에 영향을 주는 사건입니다.

이 글은 추론 인프라를 직접 운영하거나 서빙 비용을 책임지는 엔지니어를 위한 것입니다. 2026년에 공개된 vLLM v0.25.0은 232명의 기여자(신규 64명 포함)가 보낸 558개의 커밋을 담고 있습니다. 규모만큼이나 방향도 분명합니다. 지난 몇 개 릴리스에 걸쳐 준비해 온 새 실행 아키텍처를 이번에 기본값으로 승격하고, 그 과정에서 오래된 경로를 정리했습니다.

핵심을 먼저 요약하면 두 가지입니다. 첫째, **Model Runner V2(MRv2)가 모든 밀집(dense) 모델의 기본 실행 경로**가 되었습니다. 둘째, vLLM을 유명하게 만든 **PagedAttention의 레거시 구현이 삭제**되었습니다. 이 두 변화가 서빙 운영자에게 무엇을 의미하는지, 그리고 함께 들어온 비디오와 추측 디코딩 관련 기능이 어떤 워크로드에 도움이 되는지 짚습니다.

## 이 릴리스는 무엇을 바꿨나

가장 큰 구조적 변화는 MRv2의 승격입니다. 이전 릴리스에서 양자화 모델 지원을 다지며 준비해 온 MRv2가, 이번 v0.25.0부터 밀집 모델의 표준 실행 경로가 되었습니다. 이제 특별한 플래그 없이도 대부분의 모델이 이 새 코어 위에서 돕니다. vLLM 팀은 MRv2를 더 모듈화되고 빠른 코어로 설명하며, 이번 릴리스에서 이를 기본 경로로 확정했습니다.

이 변화의 자연스러운 귀결이 PagedAttention 레거시 구현의 삭제입니다. V1과 MRv2 백엔드가 표준 경로가 되면서, 과거의 어텐션 구현은 더 이상 유지할 이유가 없어졌습니다. PagedAttention은 KV 캐시를 페이지 단위로 관리해 메모리 낭비를 줄인 vLLM 초기의 상징 같은 기법이었지만, 그 아이디어는 이미 새 백엔드 안에 흡수되었습니다. 이번에 삭제된 것은 개념이 아니라 오래된 코드 경로입니다.

전체 실행 경로의 변화를 그림으로 정리하면 다음과 같습니다.

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
<div class="d3-arch" data-arch-root id="12vllmv0250modelrunnerv2-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 702, "height": 526, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 392, "y": 24, "w": 120, "h": 46, "title": "추론 요청"}, {"id": "B", "x": 383, "y": 148, "w": 138, "h": 52, "title": "실행 경로 선택"}, {"id": "C", "x": 469, "y": 292, "w": 177, "h": 62, "title": ["레거시 PagedAttention 경로", "이번 릴리스에서 삭제됨"]}, {"id": "D", "x": 279, "y": 292, "w": 135, "h": 62, "title": ["Model Runner V2", "모든 밀집 모델 표준 경로"]}, {"id": "E", "x": 550, "y": 440, "w": 120, "h": 46, "title": "양자화 모델 지원"}, {"id": "F", "x": 374, "y": 432, "w": 121, "h": 62, "title": ["동적 추측 디코딩", "풀 CUDA 그래프 호환"]}, {"id": "G", "x": 199, "y": 432, "w": 120, "h": 62, "title": ["Mamba 하이브리드", "접두어 캐싱"]}, {"id": "H", "x": 24, "y": 432, "w": 120, "h": 62, "title": ["멀티모달 접두어", "양방향 어텐션"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [452, 70, 452, 148]}, {"src": "B", "dst": "C", "kind": "data", "label": "v0.24 이전", "curve": [[490, 200], [558, 246], [558, 246], [558, 292]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "v0.25.0 기본", "curve": [[414, 200], [347, 246], [347, 246], [347, 292]], "off": "50%"}, {"src": "D", "dst": "E", "kind": "data", "curve": [[414, 341], [610, 393], [610, 393], [610, 440]]}, {"src": "D", "dst": "F", "kind": "data", "curve": [[386, 354], [435, 393], [435, 393], [435, 432]]}, {"src": "D", "dst": "G", "kind": "data", "curve": [[308, 354], [259, 393], [259, 393], [259, 432]]}, {"src": "D", "dst": "H", "kind": "data", "curve": [[279, 341], [84, 393], [84, 393], [84, 432]]}]});
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
      const container = document.getElementById('12vllmv0250modelrunnerv2-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '12vllmv0250modelrunnerv2-1';
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

## 핵심 변경 상세

이번 릴리스에서 MRv2 위에 새로 얹힌 기능들은 대체로 멀티모달과 긴 컨텍스트를 겨냥합니다.

첫째, **효율적 비디오 샘플링(EVS, Efficient Video Sampling)**입니다. 비디오를 다루는 비전 언어 모델은 프레임 수가 늘수록 토큰이 폭증해 메모리와 지연이 급격히 나빠집니다. EVS는 거의 정지된 시공간 영역의 토큰을 잘라내되, 남는 토큰의 위치 정체성(positional identity)은 보존합니다. 유지되는 토큰 수가 클립 길이에 대해 선형보다 느리게 증가하기 때문에, 메모리와 지연 예산을 넘기지 않으면서 훨씬 긴 시간적 컨텍스트를 다룰 수 있습니다.

둘째, **동적 추측 디코딩(dynamic speculative decoding)이 풀 CUDA 그래프와 호환**됩니다. 추측 디코딩은 작은 초안 모델이 여러 토큰을 미리 제안하고 본 모델이 이를 검증해 처리량을 끌어올리는 기법입니다. 이것이 CUDA 그래프 캡처와 함께 동작한다는 것은, 커널 실행 오버헤드를 줄이는 최적화와 추측 디코딩의 이득을 동시에 누릴 수 있다는 뜻입니다.

셋째, 여기에는 중요한 상호 배제가 하나 있습니다. **EVS 프루닝을 켜면 비디오 CUDA 그래프는 자동으로 비활성화**됩니다. EVS가 토큰 수를 데이터에 따라 달라지게 만들어, 고정된 형태를 전제하는 CUDA 그래프 캡처와 맞지 않기 때문입니다. 즉 긴 비디오의 토큰 절감을 택하면 그 경로에서는 CUDA 그래프 최적화를 포기하게 됩니다. 워크로드에 따라 어느 쪽이 유리한지 팀이 판단해야 하는 트레이드오프입니다.

이 밖에 실시간 임베딩(realtime embeddings), Mamba 하이브리드 모델을 위한 접두어 캐싱, 멀티모달 접두어의 양방향 어텐션 지원이 함께 들어왔습니다. Mamba 계열 하이브리드 아키텍처가 늘어나는 흐름에서, 이들에 대한 접두어 캐싱 지원은 반복 요청의 비용을 낮추는 실질적인 개선입니다.

## 설치 및 확인

vLLM v0.25.0은 표준 방식으로 설치합니다.

```bash
uv pip install vllm==0.25.0
```

설치 후 모델을 서빙하는 기본 명령은 이전과 동일합니다.

```bash
vllm serve <model-id>
```

MRv2가 기본 경로가 되었기 때문에, 밀집 모델을 서빙할 때 별도의 실행기 플래그를 지정할 필요는 대체로 없습니다.

정직하게 밝히면, 이 글을 작성한 환경에는 GPU가 없어 실제 처리량이나 지연을 직접 측정하지는 못했습니다. 그래서 이 글에는 저희가 실측하지 않은 성능 수치를 넣지 않았습니다. 인용한 사실은 모두 공식 릴리스 노트에서 확인한 것입니다. 즉 커밋과 기여자 수, MRv2의 기본 승격, PagedAttention 레거시 삭제, EVS와 동적 추측 디코딩의 특성은 공개된 릴리스 정보에 근거합니다. 실제 벤치마크는 자체 GPU 클러스터에서 대상 모델과 트래픽 패턴으로 직접 측정하시기를 권합니다.

## ThakiCloud 제품 적용 시사점

이 릴리스는 ThakiCloud의 **ai-platform** 운영과 곧바로 맞닿아 있습니다. ai-platform은 K8s와 Kueue로 GPU를 스케줄링하고 vLLM으로 다양한 고객 환경에 모델을 서빙합니다. vLLM이 서빙 스택의 핵심 엔진이기 때문에, 그 실행 아키텍처의 변화는 곧 저희 운영 방식의 변화이기도 합니다.

MRv2가 기본값이 되었다는 것은, 하나의 실행 경로를 표준으로 삼아 검증과 최적화를 집중할 수 있게 되었다는 뜻입니다. 여러 경로가 공존할 때는 버그 재현과 성능 튜닝이 경로마다 갈라지지만, 표준 경로가 정해지면 운영 복잡도가 줄어듭니다. 멀티테넌트 환경에서 수십 개의 모델을 동시에 서빙하는 입장에서는 이 단순화가 안정성으로 직결됩니다.

동적 추측 디코딩과 CUDA 그래프의 결합, 그리고 Mamba 하이브리드 접두어 캐싱은 서빙 단가를 낮추는 방향의 개선입니다. 낮은 서빙 비용은 온프레미스와 소버린 AI를 요구하는 고객에게 그대로 경쟁력이 됩니다. 자체 인프라에서 값싸게 서빙할 수 있어야, 그 위에서 도는 에이전트와 애플리케이션의 경제성이 성립하기 때문입니다. 이 지점에서 ai-platform의 저비용 서빙은 Paxis 같은 상위 에이전트 계층의 경제성을 떠받치는 토대가 됩니다.

## 한계 및 반론

가장 먼저 짚을 것은 이것이 파괴적 변경(breaking change)을 포함한다는 점입니다. PagedAttention 레거시 경로가 삭제되었기 때문에, 그 경로에 의존하던 커스텀 설정이나 서드파티 통합이 있다면 v0.25.0에서 깨질 수 있습니다. 프로덕션 서빙에서 버전을 올릴 때는 스테이징에서 대상 모델을 실제로 띄워 회귀를 확인한 뒤에 반영해야 합니다. 새 릴리스라고 곧바로 프로덕션에 올리는 것은 위험합니다.

둘째, 앞서 적은 EVS와 CUDA 그래프의 상호 배제처럼, 새 기능이 무조건 이득만 주지는 않습니다. 워크로드의 특성에 따라 어떤 최적화를 켜고 끌지 팀이 판단해야 하며, 이 판단은 실측 없이는 어렵습니다. "새 기능을 다 켜면 빨라진다"는 기대는 현실에서 자주 어긋납니다.

셋째, 릴리스 규모 자체가 리스크입니다. 558개의 커밋이 한 번에 들어온 릴리스는 그만큼 예상하지 못한 상호작용의 여지가 큽니다. 특정 모델 아키텍처나 하드웨어 조합에서만 나타나는 문제가 있을 수 있으므로, 자신이 서빙하는 정확한 모델과 GPU 조합에서 검증하는 절차를 건너뛰지 않는 것이 안전합니다.

정리하면, vLLM v0.25.0은 오랜 준비의 결과를 기본값으로 확정한 릴리스입니다. MRv2로의 통일과 레거시 정리는 장기적으로 서빙 스택을 단순하고 빠르게 만드는 방향이며, 이는 vLLM을 핵심 엔진으로 쓰는 ThakiCloud ai-platform의 운영에도 그대로 이롭습니다. 다만 그 이점을 안전하게 취하려면, 파괴적 변경에 대한 검증과 워크로드별 실측이라는 기본기를 지켜야 합니다.

## 출처

- vLLM v0.25.0 릴리스: [github.com/vllm-project/vllm/releases/tag/v0.25.0](https://github.com/vllm-project/vllm/releases/tag/v0.25.0)
- Model Runner V2 소개: [vllm.ai/blog/2026-03-24-mrv2](https://vllm.ai/blog/2026-03-24-mrv2)
- 효율적 비디오 샘플링(EVS) 논문: [arxiv.org/pdf/2510.14624](https://arxiv.org/pdf/2510.14624)
