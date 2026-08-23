---
title: "24GB 그래픽카드로 122B 모델을? llama.cpp를 텐서 단위로 쪼갠 ATSInfer를 뜯어봤습니다"
excerpt: "레이어나 전문가 단위가 아니라 텐서 하나하나를 CPU와 GPU에 나눠 배치하면, RTX 4090 한 장으로 VRAM을 훌쩍 넘는 모델을 돌리면서 디코딩을 최대 3.29배 끌어올릴 수 있다는 논문 ATSInfer를 읽고, 그 원리와 우리 서빙 관점에서의 함의를 정리했습니다."
date: 2026-07-20
tags:
  - ATSInfer
  - llama.cpp
  - CPU오프로딩
  - GPU
  - LLM서빙
  - LLMOps
  - 양자화
  - 인프라
author_profile: true
toc: true
toc_label: 텐서 단위 스케줄링의 해부
categories:
  - llmops
canonical_url: "https://thakicloud.com/tech-blog/ko/llmops/atsinfer-hybrid-cpu-gpu-tensor-scheduling/"
---

이 글은 소비자용 GPU 한 장으로 거대 모델을 자체 서빙할지 저울질하는 엔지니어, 그리고 "24GB로 120B를 돌린다"는 요즘 트윗을 어디까지 믿어야 할지 판단해야 하는 인프라 담당자를 위해 썼습니다. 결론부터 말하면, 난징대학교 연구진이 공개한 ATSInfer(arXiv:2607.10183)의 핵심 아이디어는 단순하면서도 설득력이 있습니다. 지금까지의 오프로딩이 "레이어" 또는 "전문가(expert)" 단위로 뭉텅이째 CPU와 GPU를 오갔다면, ATSInfer는 그 단위를 **텐서 하나하나**까지 쪼갭니다. 다만 화제가 된 "최대 3.29배"라는 숫자는 몇 가지 전제 위에 서 있고, 아직 코드가 공개되지 않았다는 점도 함께 짚겠습니다. 저희는 RTX 4090과 120B급 모델을 이 자리에서 재현하지는 못했으므로, 이 글의 모든 수치는 **논문이 보고한 값**임을 먼저 분명히 해 둡니다.

## 개요

로컬 LLM을 돌려 본 사람이라면 한 번쯤 마주치는 벽이 있습니다. 모델 가중치가 GPU 메모리보다 크면, 남는 부분은 CPU 메모리로 내려야 합니다. llama.cpp의 `-ngl`(GPU에 올릴 레이어 수) 플래그가 바로 그 일을 합니다. 문제는 이 방식이 **레이어 단위**로만 자른다는 점입니다. 한 레이어 안에는 어텐션 가중치, FFN 가중치, 정규화 파라미터처럼 성격이 전혀 다른 텐서들이 섞여 있는데, 이들을 통째로 "GPU에 올리거나 / CPU에 두거나" 둘 중 하나로만 처리합니다.

이 뭉텅이 배치가 왜 손해인지는 간단합니다. 같은 1GB를 VRAM에 올려도, 어떤 텐서는 GPU에서 10배 빨라지고 어떤 텐서는 2배밖에 안 빨라집니다. VRAM은 희소 자원인데, 뭉텅이로 자르면 "GB당 이득이 큰 텐서"를 골라 담을 수가 없습니다. ATSInfer는 이 지점을 정확히 겨냥합니다. 텐서마다 CPU와 GPU에서의 성능을 프로파일링해, **VRAM 1GB당 속도 이득이 가장 큰 텐서부터** 채워 넣습니다. 최근 화제였던 ktransformers가 MoE 모델의 전문가를 CPU로 내리는 "전문가 단위" 트릭이었다면([관련 글: ktransformers의 28배를 재현해봤습니다](/tech-blog/ko/llmops/ktransformers-moe-offload-28x-validation/)), ATSInfer는 그보다 한 단계 더 잘게 쪼갠 "텐서 단위" 일반화라고 볼 수 있습니다. MoE뿐 아니라 밀집(dense) 모델에도 적용된다는 점이 특히 다릅니다.

## 이 기술은 무엇인가

ATSInfer는 llama.cpp를 약 1만 5천 줄의 C++로 확장한 하이브리드 CPU-GPU 추론 시스템입니다. 이름 그대로 "자동 텐서 스케줄링(Automated Tensor Scheduling)"이 핵심이며, 세 가지 메커니즘이 맞물려 돌아갑니다.

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
<div class="d3-arch" data-arch-root id="idcpugputensorscheduling-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 351, "height": 962, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 97, "y": 24, "w": 149, "h": 62, "title": ["모델 가중치", "(RAM, VRAM 용량 초과)"]}, {"id": "B", "x": 112, "y": 164, "w": 120, "h": 62, "title": ["텐서별 성능 프로파일링", "GB당 속도 이득 측정"]}, {"id": "C", "x": 95, "y": 304, "w": 153, "h": 68, "title": ["정적 배치 결정", "이득 큰 텐서부터 VRAM에"]}, {"id": "D", "x": 199, "y": 464, "w": 120, "h": 46, "title": "VRAM 상주"}, {"id": "E", "x": 24, "y": 464, "w": 120, "h": 46, "title": "RAM 상주"}, {"id": "F", "x": 104, "y": 588, "w": 135, "h": 62, "title": ["로드 인식 동적 전송", "런타임 부하 따라 승격·강등"]}, {"id": "G", "x": 108, "y": 728, "w": 128, "h": 62, "title": ["비동기 CPU-GPU 조율", "연산·PCIe 전송 오버랩"]}, {"id": "H", "x": 101, "y": 868, "w": 142, "h": 62, "title": ["토큰 출력", "prefill · decode"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [172, 86, 172, 164]}, {"src": "B", "dst": "C", "kind": "data", "line": [172, 226, 172, 304]}, {"src": "C", "dst": "D", "kind": "data", "label": "\"고이득 텐서\"", "curve": [[209, 372], [259, 418], [259, 418], [259, 464]], "off": "50%"}, {"src": "C", "dst": "E", "kind": "data", "label": "\"저이득 텐서\"", "curve": [[134, 372], [84, 418], [84, 418], [84, 464]], "off": "50%"}, {"src": "D", "dst": "F", "kind": "data", "curve": [[259, 510], [259, 549], [259, 549], [210, 588]]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[84, 510], [84, 549], [84, 549], [133, 588]]}, {"src": "F", "dst": "G", "kind": "data", "line": [172, 650, 172, 728]}, {"src": "G", "dst": "H", "kind": "data", "line": [172, 790, 172, 868]}]});
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
      const container = document.getElementById('idcpugputensorscheduling-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'idcpugputensorscheduling-1';
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

**첫째, 정적 텐서 배치(static placement)입니다.** 모델을 올리기 전에, 벤치마크로 각 텐서가 GPU에서 얼마나 빨라지는지를 미리 측정합니다. 그리고 "VRAM 1GB를 썼을 때 가장 많은 속도를 돌려주는" 텐서 순으로 GPU에 배치합니다. 이는 배낭 문제(knapsack)에 가까운 최적화로, 뭉텅이 배치가 놓치던 텐서 간 이질성을 정면으로 활용합니다.

**둘째, 로드 인식 동적 전송(load-aware dynamic transfer)입니다.** 정적 배치만으로는 부족합니다. 실제 추론 중에는 배치 크기, 컨텍스트 길이, 동시 요청 수에 따라 부하가 시시각각 변합니다. ATSInfer는 런타임 상황을 보고 특정 텐서를 RAM에서 GPU로 승격하거나 반대로 강등합니다. 정적 배치가 "출발선"이라면, 동적 전송은 "주행 중 차선 변경"에 해당합니다.

**셋째, 비동기 CPU-GPU 조율(asynchronous coordination)입니다.** CPU 연산, GPU 연산, 그리고 둘을 잇는 PCIe 전송을 서로 겹쳐(overlap) 실행합니다. 순진하게 구현하면 GPU가 CPU의 계산이나 데이터 전송을 기다리며 노는 시간이 생기는데, 이 조율 계층이 그 유휴 시간을 메웁니다. 논문은 이 덕분에 GPU SM(스트리밍 멀티프로세서) 평균 활용도가 약 70% 올라갔다고 보고합니다.

## 논문이 보고한 실험 결과

다시 강조하지만, 아래 수치는 **논문이 보고한 값**이며 저희가 직접 재현한 것이 아닙니다. ATSInfer는 아직 코드가 공개되지 않았고(트윗에서도 "연구자들이 llama.cpp 팀에 코드를 공유해 주길"이라는 반응이 있었습니다), 120B급 모델과 RTX 4090은 이 글을 쓰는 샌드박스에서 재현하기 어렵습니다. 그래서 저희는 재현 대신 **구조 분석과 함의 정리**에 집중합니다.

논문의 헤드라인 수치는 다음과 같습니다. 기존 하이브리드 시스템(llama.cpp의 레이어 단위 오프로딩 포함) 대비, prefill(첫 토큰까지의 처리량)은 최대 1.94배, decode(초당 생성 토큰)는 최대 3.29배 빨라졌습니다.

![ATSInfer가 논문에서 보고한 최대 속도 향상 비교]({{ '/assets/images/atsinfer-hybrid-cpu-gpu-tensor-scheduling-results.webp' | relative_url }})

실험 환경은 RTX 4090(24GB) 및 RTX 3060 시스템에 64GB RAM 구성이며, 검증에 사용한 모델은 다음과 같습니다.

- Llama 3.1-70B (INT4)
- Qwen3-Next-80B-A3B (INT4)
- Qwen3.5-122B-A10B (INT4)
- GPT-OSS-120B (MXFP4)

즉 24GB 한 장으로 122B 파라미터 모델(A10B, 활성 파라미터 기준으로는 더 작은 MoE)까지 구동했다는 것이 핵심 주장입니다. 여기서 두 가지를 분리해 읽어야 합니다. 첫째, "3.29배"는 특정 조건에서의 **최댓값**이지 모든 모델·모든 배치에서 나오는 평균이 아닙니다. 둘째, 이 이득은 근본적으로 "GPU에 안 들어가던 것을 넣어 돌린다"가 아니라 "어차피 CPU-GPU를 오갈 수밖에 없는 상황에서, 오가는 방식을 더 똑똑하게 만든다"에서 옵니다. 병목이 PCIe 대역폭이라는 물리 법칙은 그대로이므로, ATSInfer의 기여는 그 대역폭을 낭비 없이 쓰고 GPU 유휴 시간을 줄인 데 있습니다.

## ThakiCloud 제품 적용 시사점

ThakiCloud의 **ai-platform**은 Kubernetes와 Kueue 기반으로 다양한 고객 환경에서 모델을 서빙하는 AI/ML 인프라입니다. ATSInfer 같은 텐서 단위 스케줄링은 저희가 특히 주목하는 흐름과 맞닿아 있습니다.

첫째, **온프레미스·소버린 환경의 경제성**입니다. 국내 공공·금융 고객처럼 데이터를 외부로 내보낼 수 없는 환경에서는 자체 GPU로 모델을 돌려야 합니다. 이때 H100 8장짜리 랙 대신 소비자용 GPU 몇 장으로 중대형 모델을 감당할 수 있다면, 초기 CAPEX가 극적으로 낮아집니다. ATSInfer의 실험이 보여 주는 것은, "VRAM이 모자라면 무조건 GPU를 더 사야 한다"는 전제가 텐서 배치 최적화로 상당 부분 완화될 수 있다는 점입니다. 물론 그 대가는 처리량 감소이므로, 저지연이 필수인 워크로드에는 부적합합니다. 이 트레이드오프를 워크로드별로 판단하는 것이 저희 서빙 계층의 역할입니다.

둘째, **멀티테넌트 스케줄링과의 결합**입니다. ATSInfer의 "로드 인식 동적 전송"은 단일 노드 안에서의 텐서 이동이지만, 그 발상은 클러스터 수준에서도 유효합니다. Kueue로 GPU 자원을 큐잉하고 할당할 때, 어떤 요청을 어떤 정밀도·어떤 오프로딩 프로파일로 처리할지를 부하에 따라 결정하는 정책은 저희가 이미 고민하는 영역입니다. 텐서 단위 프로파일링이 노드 안에서 자원 이득을 짜내듯, 클러스터 스케줄러는 노드 사이에서 같은 일을 합니다.

셋째, **비용-품질 곡선의 재정의**입니다. 저희는 [ktransformers 재현 글](/tech-blog/ko/llmops/ktransformers-moe-offload-28x-validation/)에서 "28배" 같은 화제 수치가 숨은 전제 위에 서 있음을 직접 측정으로 보였습니다. ATSInfer의 "3.29배"도 같은 렌즈로 봐야 합니다. 마케팅 수치가 아니라, 우리 고객의 실제 모델·실제 배치·실제 SLA에서 어떤 숫자가 나오는지를 검증하는 것이 저희가 제공하는 가치입니다. 낮은 서빙 비용에서의 경쟁력은 결국 이런 검증의 축적에서 나옵니다.

## 한계 및 반론

가장 큰 한계는 **코드 미공개**입니다. 논문의 수치가 재현 가능한지, 다른 하드웨어·다른 모델에서도 유지되는지는 코드가 나와야 검증할 수 있습니다. 15,000줄 규모의 C++ 확장이라면 유지보수와 llama.cpp 본류 병합도 만만치 않은 과제입니다. 병합되지 못한 포크는 시간이 지나면 상류 변경을 따라가지 못해 쓸모가 줄어듭니다.

둘째, **이득의 조건 의존성**입니다. 텐서 단위 배치의 효과는 CPU 성능, RAM 대역폭, PCIe 세대에 크게 좌우됩니다. 논문의 실험은 64GB RAM을 전제하는데, RAM이 부족하면 텐서를 CPU에 둘 여유 자체가 없어집니다. PCIe 3.0 시스템에서는 전송이 병목이 되어 이득이 크게 줄어들 가능성이 높습니다([추정], 논문이 세대별 비교를 명시하지 않았습니다).

셋째, **decode 최적화의 태생적 천장**입니다. decode는 메모리 대역폭에 묶인(memory-bound) 작업입니다. 아무리 스케줄링을 잘해도 VRAM 밖에 있는 가중치는 매 토큰마다 어떤 식으로든 접근해야 하므로, 순수 VRAM 상주 대비 느릴 수밖에 없습니다. ATSInfer가 하는 일은 "느려지는 정도를 최소화"하는 것이지 "느려짐을 없애는" 것이 아닙니다. 반대편 논거를 세워 보면, 진짜 저지연·고처리량이 필요한 프로덕션 서빙이라면 여전히 모델 전체가 VRAM에 들어가는 GPU를 쓰는 편이 옳습니다. ATSInfer가 빛나는 지점은 "그 GPU를 살 여력이 없거나, 살 필요까지는 없는" 개발·평가·소규모 배치 구간입니다.

그럼에도 이 방향성은 분명한 가치가 있습니다. 하드웨어를 늘리지 않고 소프트웨어로 자원 활용을 짜내는 접근은, 온프렘·비용효율·self-hosting을 무기로 삼는 저희 같은 플랫폼에 특히 잘 맞습니다. 코드가 공개되면 저희 서빙 벤치마크에 편입해 실제 수치를 직접 측정할 계획입니다.

## 출처

- ATSInfer 논문: [arXiv:2607.10183, Automated Tensor Scheduling for Hybrid CPU-GPU LLM Inference on Consumer Devices](https://arxiv.org/abs/2607.10183)
- 관련 글: [40만 달러 랙을 24GB로? ktransformers의 28배를 직접 재현해봤습니다](/tech-blog/ko/llmops/ktransformers-moe-offload-28x-validation/)
