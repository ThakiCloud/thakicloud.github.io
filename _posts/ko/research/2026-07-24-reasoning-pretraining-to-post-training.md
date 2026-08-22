---
title: "RL로 얼마나 똑똑해질지는 사전학습이 이미 정해 놓았다: 체스로 밝힌 추론의 스케일링 법칙"
seo_title: "사전학습 손실이 RL 추론 성능을 예측한다 | 체스 스케일링 법칙 연구 | ThakiCloud"
seo_description: "NYU·Modal·UCLA 연구팀이 체스를 통제된 실험대로 삼아 사전학습부터 RL 후처리까지 전체 파이프라인을 관통하는 결합 스케일링 법칙을 찾았습니다. RL 후 성능은 사전학습 손실로 잘 예측되고, RL 보상 곡선의 기울기는 사전학습 토큰 수에 거의 선형으로 좋아집니다. GPU 예산을 사전학습과 RL에 어떻게 배분할지 정하는 데 직접 쓰이는 결과를 정리했습니다."
excerpt: "RL이 모델을 똑똑하게 만드는 것 같지만, 그 상한은 사전학습이 이미 그어 놓았습니다. 체스라는 통제된 실험대에서 사전학습 손실이 RL 후 추론 성능을 예측한다는 결합 스케일링 법칙을 살펴봅니다."
date: 2026-07-24
tags:
  - 강화학습
  - 사전학습
  - 후처리
  - 스케일링 법칙
  - 추론
  - LLM 학습
  - 컴퓨트 배분
  - GRPO
  - 체스
  - 검증 가능 보상
categories: [research]
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/ko/research/reasoning-pretraining-to-post-training/"
audiobook: /assets/audio/posts/reasoning-pretraining-to-post-training/audiobook-ko.mp3
audiobook_note: "AI 로컬 합성 오디오북 (Qwen3-TTS)"
published: false
---

RL 후처리로 추론 모델을 개선하려는데 GPU 예산을 사전학습과 RL 사이에 어떻게 나눠야 할지 고민하는 엔지니어라면, 이 논문이 답의 실마리를 줍니다. 핵심 결론부터 말씀드리면, RL로 도달할 수 있는 추론 성능의 상한은 사전학습이 이미 정해 놓으며, 그 관계는 사전학습 손실이라는 하나의 값으로 예측할 수 있을 만큼 규칙적입니다. NYU와 Modal Labs, UCLA 등의 연구팀이 체스를 통제된 실험대로 삼아 사전학습부터 RL 후처리까지 전체 파이프라인을 관통하는 결합 스케일링 법칙을 찾아냈습니다.

![사전학습 토대 위로 솟아오르는 스케일링 곡선을 형상화한 추상 이미지](/assets/images/reasoning-pretraining-to-post-training-hero.webp)
*사전학습이라는 토대가 이후 RL 성능의 상한을 떠받치는 구조를 형상화했습니다.*

## 왜 읽어야 하나

이 절은 LLM 학습 파이프라인을 직접 운영하는 엔지니어와, 한정된 GPU 예산을 사전학습·SFT·RL에 배분해야 하는 플랫폼 담당자를 대상으로 합니다. 핵심 결론은 이렇습니다. RL은 모델을 무에서 똑똑하게 만드는 마법이 아니라, 사전학습이 그어 놓은 상한 안에서 성능을 끌어올리는 단계이며, 그 상한은 사전학습 손실로 미리 가늠할 수 있습니다. 이 사실을 알면 "일단 작은 모델로 RL을 오래 돌려 보자" 같은 낭비를 피하고, 컴퓨트를 어디에 먼저 써야 할지 근거를 갖고 정할 수 있습니다.

## 개요

지난 2년 동안 RL 후처리는 복잡한 추론 과제에서 LLM을 개선하는 핵심 수단으로 자리 잡았습니다. GRPO, DPO 같은 방법으로 검증 가능한 보상을 주며 모델을 다듬는 것입니다. 그런데 대부분의 연구는 RL을 그 앞에 오는 사전학습과 떼어 놓고 다뤘습니다. 사전학습은 사전학습대로, RL은 RL대로 따로 최적화하는 식이었습니다.

이 논문은 그 둘을 하나의 파이프라인으로 묶어 봅니다. 두 가지 근본적인 질문을 던집니다. 첫째, 사전학습의 선택(모델 크기, 데이터 양)이 RL 컴퓨트의 수익을 어떻게 좌우하는가. 둘째, RL은 실제로 모델에게 무엇을 하는가. 이 질문에 답하려면 사전학습부터 RL까지 전체를 통제된 조건에서 반복 실험할 수 있어야 하는데, 실제 대형 언어모델로는 비용이 감당되지 않습니다. 연구팀이 체스를 택한 이유가 여기에 있습니다.

## 이 연구는 무엇인가

체스는 추론을 연구하기에 좋은 실험대입니다. 규칙이 명확하고, 수의 좋고 나쁨을 엔진으로 검증할 수 있으며, 난이도를 퍼즐 단위로 조절할 수 있습니다. 연구팀은 표준 LLM 학습 파이프라인을 체스에 그대로 옮겼습니다.

![체스가 실험대로 좋은 세 가지 이유: 명확한 규칙·검증 가능한 보상·세밀한 난이도 조절](/assets/images/reasoning-pretraining-to-post-training-slide-04.webp)
*명확한 규칙, 검증 가능한 보상, 세밀한 난이도 조절이라는 세 가지 성질이 체스를 통제된 실험대로 만듭니다.*

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
<div class="d3-arch" data-arch-root id="retrainingtoposttraining-1"></div>
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
  /* Size to the spec's natural canvas: JS caps max-width at the spec width so a
     narrow/portrait diagram is never stretched to the article column (blur + giant
     vertical figures); wide diagrams scale down but keep min-width 760 + scroll. */
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 257, "height": 568, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "Pre", "x": 50, "y": 24, "w": 120, "h": 78, "title": ["사전학습", "인간 체스 기보", "5M~1B 파라미터"]}, {"id": "SFT", "x": 101, "y": 180, "w": 120, "h": 62, "title": ["지도 미세조정", "합성 추론 트레이스"]}, {"id": "RL", "x": 97, "y": 334, "w": 128, "h": 62, "title": ["강화학습", "체스 퍼즐·검증 가능 보상"]}, {"id": "Eval", "x": 50, "y": 474, "w": 120, "h": 62, "title": ["평가", "퍼즐 정답률"]}], "edges": [{"src": "Pre", "dst": "SFT", "kind": "data", "curve": [[135, 102], [161, 141], [161, 141], [161, 180]]}, {"src": "SFT", "dst": "RL", "kind": "data", "line": [161, 242, 161, 334]}, {"src": "RL", "dst": "Eval", "kind": "data", "curve": [[161, 396], [161, 435], [161, 435], [132, 474]]}, {"src": "Pre", "dst": "Eval", "kind": "event", "label": "사전학습 손실이 예측", "curve": [[85, 102], [59, 211], [59, 365], [87, 474]], "off": "50%"}]});
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
      const container = document.getElementById('retrainingtoposttraining-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'retrainingtoposttraining-1';
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
        // Never upscale past the spec's natural width; keep 760px readability
        // floor (with horizontal scroll) only for diagrams that are actually wide.
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

먼저 500만에서 10억 파라미터에 이르는 언어모델을 인간의 체스 기보로 사전학습했습니다. 그다음 합성 추론 트레이스로 지도 미세조정을 했습니다. 사람이 수를 고를 때 머릿속으로 밟는 사고 과정을 흉내 낸 데이터입니다. 마지막으로 체스 퍼즐 위에서 RL을 돌렸습니다. 퍼즐은 정답이 검증 가능하므로, 보상을 명확하게 줄 수 있습니다.

이 설정의 장점은 파라미터 규모와 사전학습 데이터 양을 자유롭게 바꿔 가며 전체 파이프라인을 반복할 수 있다는 것입니다. 실제 LLM에서는 엄두도 못 낼 규모의 통제 실험을, 체스라는 축소판에서 수행한 셈입니다.

## 핵심 발견

연구팀이 찾은 결과는 크게 두 갈래입니다.

첫째, 결합 스케일링 법칙입니다. 특정 RL 컴퓨트 수준에서 RL 후 성능은 사전학습 손실로 잘 예측됩니다. 다시 말해, 모델을 RL로 다듬기 전에 사전학습이 얼마나 잘 됐는지를 보면, RL을 돌린 뒤 어디까지 갈지를 상당히 정확하게 가늠할 수 있다는 것입니다. 더 나아가, RL 보상 곡선의 기울기는 사전학습에 쓴 토큰 수가 늘수록 거의 선형으로 좋아집니다. 사전학습을 충분히 한 모델일수록 RL 컴퓨트 한 단위당 더 빠르게 개선된다는 뜻입니다.

이 발견의 실용적 함의는 컴퓨트 배분입니다. RL만 오래 돌린다고 성능이 무한히 오르지 않습니다. 사전학습이 부실하면 RL 곡선의 기울기 자체가 완만해, 같은 RL 컴퓨트를 부어도 덜 개선됩니다. 논문은 이 관계를 정량화해, 주어진 총 예산을 사전학습과 RL에 어떻게 나눠야 하는지를 정하는 근거를 제시합니다.

![사전학습이 부실할수록 RL 개선 곡선의 기울기가 완만해지고, 충분할수록 가팔라지는 비교](/assets/images/reasoning-pretraining-to-post-training-slide-07.webp)
*사전학습이 튼튼할수록 RL 컴퓨트 한 단위당 개선 폭, 곧 기울기가 가팔라집니다.*

둘째, RL이 정책에 실제로 하는 일입니다. RL이 그저 SFT 정책을 날카롭게 다듬기만 하는 것이 아니라는 점이 흥미롭습니다. 쉬운 퍼즐에서는 SFT 정책이 이미 선호하던 올바른 수를 증폭합니다. 원래 잘하던 것을 더 확실하게 만드는 것입니다. 반면 어려운 퍼즐에서는, SFT 정책이 선호하지 않던 올바른 수를 표면으로 끌어올립니다. 원래는 잘 두지 않던 수를 새로 발굴하는 것입니다. RL이 난이도에 따라 질적으로 다르게 작동한다는 이 관찰은, RL을 단순히 "확률 분포를 뾰족하게 만드는 과정"으로만 보던 통념을 흔듭니다.

![쉬운 퍼즐에서는 증폭, 어려운 퍼즐에서는 발굴로 RL이 이중적으로 작동하는 대비](/assets/images/reasoning-pretraining-to-post-training-slide-08.webp)
*쉬운 과제에서는 기존 강점을 증폭하고, 어려운 과제에서는 숨은 올바른 수를 발굴합니다.*

## ThakiCloud 제품 적용 시사점

이 연구는 ThakiCloud의 ai-platform이 다루는 문제와 정면으로 맞닿아 있습니다. ai-platform은 K8s와 Kueue GPU 스케줄링 위에서 SFT, CPT, DPO, GRPO, GKD 같은 여러 학습 방법을 지원하는 훈련 파이프라인을 운영합니다. 고객이 자신의 GPU 예산으로 추론 모델을 다듬으려 할 때, 가장 먼저 마주치는 질문이 바로 "어디에 컴퓨트를 쓸 것인가"입니다.

이 논문의 결합 스케일링 법칙은 그 질문에 원칙을 줍니다. 사전학습이나 계속학습(CPT)이 부실한 상태에서 RL 예산만 늘리는 것은 기울기가 완만한 곡선을 억지로 오르는 일입니다. 반대로 사전학습 손실을 먼저 낮춰 두면, 이후 RL 단계에서 같은 GPU 시간으로 더 큰 개선을 얻습니다. 플랫폼 관점에서 이는 학습 잡을 스케줄링할 때 단계별 예산 배분을 데이터 기반으로 조언할 수 있다는 뜻입니다. 사전학습 손실을 관측치로 삼아 RL 잡의 기대 수익을 미리 추정하고, 그에 맞춰 Kueue 큐의 우선순위를 조정하는 식입니다.

![SFT·CPT 잡의 사전학습 손실을 Kueue 스케줄러가 관측치로 삼아 DPO·GRPO 잡의 예산을 배분하는 구조도](/assets/images/reasoning-pretraining-to-post-training-slide-09.webp)
*ai-platform은 사전학습 손실을 동적 예산 배분의 관측치로 삼아 학습 잡을 스케줄링합니다.*

RL이 난이도에 따라 다르게 작동한다는 발견도 실무에 쓸모가 있습니다. 쉬운 과제 위주의 데이터로 RL을 돌리면 기존 강점을 증폭할 뿐 새 능력을 끌어내지 못할 수 있습니다. 어려운 과제를 충분히 섞어야 모델이 원래 선호하지 않던 올바른 행동을 발굴합니다. 검증 가능한 보상으로 GRPO를 돌리는 우리 고객이라면, 퍼즐 난이도 분포를 의식적으로 설계해야 한다는 실천적 교훈입니다.

물론 체스는 축소판입니다. 자연어 추론과 다른 점이 많습니다. 그럼에도 통제된 실험에서 나온 스케일링 법칙의 형태 자체는, 실제 파이프라인에서 컴퓨트 배분의 방향을 잡는 나침반으로 쓸 만합니다.

## 한계 및 반론

이 연구의 결론을 그대로 받아들이기 전에 짚어야 할 점이 있습니다.

![폐쇄 도메인의 맹점·프런티어 모델과의 규모 차이·단일 지표의 함정이라는 세 가지 한계](/assets/images/reasoning-pretraining-to-post-training-slide-11.webp)
*체스라는 통제된 실험대는 폐쇄 도메인, 작은 규모, 단일 지표라는 세 가지 경계를 안고 있습니다.*

첫째, 체스는 검증이 완벽한 폐쇄 도메인입니다. 수의 좋고 나쁨을 엔진이 정확히 판정하므로 보상이 깨끗합니다. 그러나 실제 자연어 추론에서는 보상 자체가 노이즈가 많고 편향될 수 있습니다. 체스에서 성립한 깔끔한 스케일링 법칙이 지저분한 실전 보상에서도 같은 형태로 유지될지는 별개의 문제입니다.

둘째, 모델 규모가 500만에서 10억 파라미터로, 프런티어 모델에 비하면 작습니다. 스케일링 법칙은 외삽이 위험한 도구입니다. 이 규모에서 관찰한 선형 관계가 수백억 파라미터 영역에서도 유지된다는 보장은 없습니다. 논문 자체도 이를 통제된 실험대의 발견으로 제시하지, 프런티어 규모의 확정으로 주장하지 않습니다.

셋째, 사전학습 손실이라는 단일 지표로 RL 후 성능을 예측한다는 것은 강력하지만, 그 손실이 무엇으로 낮아졌는지를 구분하지 못할 수 있습니다. 데이터 품질과 데이터 양이 같은 손실을 서로 다른 방식으로 만들 때, 그 뒤의 RL 거동이 정말 동일한지는 더 검증이 필요합니다.

## 정리

이 논문은 RL 후처리를 사전학습과 떼어 보던 관행을 뒤집어, 둘을 하나의 결합 스케일링 법칙으로 묶었습니다. RL 후 추론 성능은 사전학습 손실로 예측되고, RL 곡선의 기울기는 사전학습 토큰 수에 거의 선형으로 좋아집니다. 서두에서 세운 결론, 곧 RL로 도달할 성능의 상한은 사전학습이 이미 그어 놓았다는 명제가 이 결과로 뒷받침됩니다.

실무 takeaway는 명확합니다. 추론 모델을 다듬을 때 RL 예산부터 늘리기 전에, 사전학습 또는 계속학습이 충분한지를 먼저 보십시오. 사전학습 손실은 이후 RL의 기대 수익을 가늠하는 관측치입니다. 그리고 RL 데이터에는 어려운 과제를 충분히 섞어, 모델이 원래 선호하지 않던 올바른 행동까지 발굴하도록 하십시오. ThakiCloud의 ai-platform은 이 원칙을 학습 잡 스케줄링에 녹여, 고객이 GPU 예산을 단계별로 현명하게 배분하도록 돕습니다.

## 출처

- [Understanding Reasoning from Pretraining to Post-Training (arXiv:2607.16097)](https://arxiv.org/abs/2607.16097)
- [논문 HTML 전문 (arXiv)](https://arxiv.org/html/2607.16097)
- [저자 Pavel Izmailov 소개 스레드 (X)](https://x.com/Pavel_Izmailov/status/2079268684317508020)
