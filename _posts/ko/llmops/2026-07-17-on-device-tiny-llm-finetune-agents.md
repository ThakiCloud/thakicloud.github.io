---
title: "폰 안에서 46%를 90%로: 온디바이스 에이전트를 위한 작은 LLM 파인튜닝"
excerpt: "Google AI Edge의 Cormac Brick은 270M 파라미터의 FunctionGemma를 파인튜닝해 특정 에이전트 과제에서 정확도를 46%에서 90%로 끌어올린 사례를 발표했습니다. 핵심은 큰 모델을 부르는 대신, 작은 모델을 좁은 과제에 맞춰 폰 위에서 돌리는 것입니다. 저희는 이 접근이 왜 지연·프라이버시·비용을 동시에 잡는지, 그리고 온디바이스 특화 모델의 흐름이 ThakiCloud의 서빙 인프라와 에이전트 플랫폼에 무엇을 의미하는지 짚어봅니다."
tags:
  - on-device
  - fine-tuning
  - functiongemma
  - gemma
  - litert-lm
  - edge-ai
  - small-language-model
  - function-calling
  - serving
  - self-hosting
  - llmops
  - paxis
date: 2026-07-17
lang: ko
canonical_url: "https://thakicloud.com/tech-blog/ko/llmops/on-device-tiny-llm-finetune-agents/"
categories:
  - llmops
---

## 개요

작은 모델은 똑똑하지 않다는 통념이 오래갔습니다. 그래서 실무자들은 웬만한 과제를 전부 큰 모델에 던졌고, 그 대가로 지연과 비용과 데이터 유출 위험을 감수했습니다. 그런데 과제를 아주 좁게 잡으면 이야기가 달라집니다. 범용성을 버리고 한 가지 일만 잘하도록 작은 모델을 다듬으면, 그 좁은 영역에서는 큰 모델을 부를 이유가 사라집니다.

Google AI Edge의 Principal Engineer인 Cormac Brick이 발표한 "From 46% to 90%: Fine-Tuning Tiny LLMs for On-Device Agents"는 정확히 이 지점을 겨냥합니다. 270M 파라미터의 FunctionGemma를 특정 에이전트 과제에 맞춰 파인튜닝하자, 정확도가 46%에서 90%로 올랐다는 것이 발표의 제목이자 요지입니다. 이 모델은 Pixel 7에서 초당 약 2,000토큰의 prefill 처리량을 낸다고 보고되었습니다. 모두 폰 안에서, 서버 호출 없이 벌어지는 일입니다.

이 글은 멀티테넌트 추론 인프라를 운영하는 ThakiCloud의 관점에서 이 발표를 읽습니다. 왜 작은 특화 모델이 온디바이스에서 의미를 갖는지, 파인튜닝이 실제로 무엇을 바꾸는지, LiteRT-LM 같은 런타임이 배포를 어떻게 단순화하는지, 그리고 이 흐름이 저희의 서빙 인프라와 에이전트 플랫폼에 어떤 실무적 의미를 갖는지 순서대로 살펴봅니다. 아래에 인용한 정확도와 처리량, 소요 시간 수치는 모두 발표와 관련 보도의 보고값이며, ThakiCloud가 직접 재현한 값이 아닙니다.

{% include video id="-TiET_K-E_g" provider="youtube" %}

위 영상은 Cormac Brick의 원 발표 전체입니다. 아래 분석은 이 발표와 공개 보도를 근거로 합니다.

## 이 기술은 무엇인가

FunctionGemma는 Gemma 계열에서 함수 호출(function calling)에 특화된 270M 파라미터 모델입니다. 함수 호출은 온디바이스 에이전트의 핵심 동작입니다. 사용자의 자연어 요청을 앱이 실행할 수 있는 구조화된 도구 호출로 바꾸는 일이기 때문입니다. "내일 오전 9시에 알람 맞춰줘"를 `setAlarm(time="09:00", date="tomorrow")` 같은 호출로 변환하는 것이 그 예입니다. 이 변환만 정확하다면, 굳이 수십억 파라미터의 범용 모델을 불러올 필요가 없습니다.

문제는 범용으로 배포된 작은 모델이 특정 앱의 도구 스키마에서는 정확도가 낮다는 점입니다. 발표가 말하는 46%가 바로 그 지점입니다. 여기서 파인튜닝이 등장합니다. 목표 앱의 실제 함수 스키마와 요청 패턴에 맞춰 모델을 좁게 다듬으면, 같은 270M 모델이 90%까지 올라간다는 것입니다.

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
<div class="d3-arch" data-arch-root id="icetinyllmfinetuneagents-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 494, "height": 806, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 254, "y": 24, "w": 120, "h": 62, "title": ["사용자 자연어 요청", "내일 9시 알람"]}, {"id": "B", "x": 254, "y": 164, "w": 120, "h": 46, "title": "온디바이스 에이전트"}, {"id": "C", "x": 227, "y": 288, "w": 174, "h": 52, "title": "FunctionGemma 270M"}, {"id": "D", "x": 342, "y": 432, "w": 120, "h": 62, "title": ["정확도 약 46%", "앱 스키마 미정렬"]}, {"id": "E", "x": 167, "y": 432, "w": 120, "h": 62, "title": ["정확도 약 90%", "실제 함수 스키마 정렬"]}, {"id": "F", "x": 249, "y": 572, "w": 191, "h": 62, "title": ["구조화된 함수 호출", "setAlarm 09:00 tomorrow"]}, {"id": "G", "x": 285, "y": 712, "w": 120, "h": 62, "title": ["앱이 직접 실행", "서버 호출 없음"]}, {"id": "H", "x": 24, "y": 572, "w": 170, "h": 62, "title": ["LiteRT-LM 런타임", "Pixel 7 약 2000 tok/s"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [314, 86, 314, 164]}, {"src": "B", "dst": "C", "kind": "data", "line": [314, 210, 314, 288]}, {"src": "C", "dst": "D", "kind": "data", "label": "범용 배포", "curve": [[346, 340], [402, 386], [402, 386], [402, 432]], "off": "50%"}, {"src": "C", "dst": "E", "kind": "data", "label": "과제 특화 파인튜닝", "curve": [[283, 340], [227, 386], [227, 386], [227, 432]], "off": "50%"}, {"src": "E", "dst": "F", "kind": "data", "curve": [[279, 494], [345, 533], [345, 533], [345, 572]]}, {"src": "F", "dst": "G", "kind": "data", "line": [345, 634, 345, 712]}, {"src": "E", "dst": "H", "kind": "data", "curve": [[175, 494], [109, 533], [109, 533], [109, 572]]}]});
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
      const container = document.getElementById('icetinyllmfinetuneagents-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'icetinyllmfinetuneagents-1';
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

## 46%에서 90%로: 파인튜닝이 하는 일

이 격차의 정체를 이해하는 것이 중요합니다. 큰 모델은 방대한 범용 지식으로 낯선 스키마도 어느 정도 추론해 냅니다. 작은 모델은 그 여유가 없습니다. 대신 좁은 분포에 집중시키면, 그 분포 안에서는 큰 모델 못지않게 정확해집니다. 파인튜닝은 모델에게 새로운 지능을 주입하는 것이 아니라, 이미 가진 용량을 목표 과제 쪽으로 몰아주는 작업에 가깝습니다.

발표에 따르면 이 파인튜닝은 대단히 짧은 시간에 끝납니다. 관련 소개에서는 약 21분 만에 학습이 완료된다고 전해집니다. 270M이라는 작은 규모 덕분에 학습 자체가 가볍고, 컨슈머 하드웨어로도 충분히 감당됩니다. 이는 데이터 과학 실무에 직접적인 함의를 갖습니다. 앱마다, 도구 세트마다 별도의 작은 특화 모델을 두고 각각을 짧게 학습시키는 운영 방식이 현실적이라는 뜻입니다. 하나의 거대한 범용 모델로 모든 앱을 커버하는 대신, 과제별로 잘게 나눈 특화 모델 여러 개를 두는 것입니다.

이 발상은 저희가 콘텐츠 배치 작업에서 지켜온 원칙과도 닿아 있습니다. 자유도가 높은 범용 해법보다, 검증된 좁은 골격에 채워 넣는 특화 해법이 평균 품질을 올립니다. 작은 모델의 파인튜닝은 이 원칙을 모델 수준에서 구현한 사례입니다.

## 온디바이스가 주는 것: 지연·프라이버시·오프라인·비용

발표가 온디바이스를 강조하는 이유는 네 가지로 정리됩니다.

지연이 줄어듭니다. 요청이 네트워크를 왕복하지 않으므로, 함수 호출 변환이 폰 안에서 즉시 끝납니다. 에이전트가 사용자 동작에 실시간으로 반응해야 하는 UI라면 이 차이는 결정적입니다.

프라이버시가 지켜집니다. 사용자의 요청과 개인 데이터가 기기를 벗어나지 않습니다. 헬스, 금융, 메시징처럼 민감한 맥락에서는 데이터가 서버로 나가지 않는다는 사실 자체가 제품의 요건이 됩니다.

오프라인에서 동작합니다. 네트워크가 없어도 에이전트가 기능합니다. 클라우드 모델은 연결이 끊기면 무력해지지만, 온디바이스 모델은 그렇지 않습니다.

비용이 사라집니다. 추론이 기기에서 일어나므로 토큰당 API 과금이 없습니다. 사용량이 많은 앱일수록 이 절감은 커집니다.

## LiteRT-LM과 배포 스택

작은 모델을 학습하는 것과 그것을 수많은 기기에 배포하는 것은 별개의 문제입니다. 발표는 LiteRT-LM을 배포 런타임으로 제시합니다. LiteRT-LM은 Gemma 4 같은 모델을 모바일부터 임베디드 시스템까지 폭넓은 하드웨어에 올릴 수 있게 하는 런타임입니다. 여기에 AI Core를 결합하면 온디바이스 에이전트 스킬을 구동할 수 있다고 설명합니다.

핵심은 하나의 모델을 다양한 하드웨어에 일관되게 배포하는 경로가 갖춰져 있다는 점입니다. 학습된 특화 모델을 각 기기의 가속기에 맞춰 다시 짜맞추는 수고 없이, 런타임이 그 이질성을 흡수합니다. 이것이 온디바이스 에이전트를 실험 수준에서 제품 수준으로 끌어올리는 실무적 조건입니다.

## ThakiCloud 제품 적용 시사점

온디바이스 특화 모델의 흐름은 클라우드 서빙을 운영하는 저희에게 반대 방향의 신호처럼 보일 수 있지만, 실제로는 두 제품 모두에 직접적인 함의를 줍니다.

**ai-platform 렌즈.** 작은 특화 모델의 부상은 서빙 인프라의 초점을 바꿉니다. ThakiCloud의 ai-platform은 K8s와 Kueue 기반 GPU 스케줄링, 멀티테넌트 격리, 온프레미스 서빙을 제공합니다. 여기서 온디바이스 파인튜닝이 던지는 질문은 "모든 것을 온디바이스로 보내면 서버는 필요 없어지는가"가 아닙니다. 오히려 반대입니다. 앱마다 별도의 특화 모델을 짧게 학습시키려면, 그 학습 잡을 저비용으로 대량 돌릴 인프라가 필요합니다. 270M 모델의 21분짜리 파인튜닝을 수백 개의 도구 세트에 대해 반복하는 워크로드는, Kueue가 GPU를 큐잉하고 멀티테넌트로 격리하는 인프라가 정확히 겨냥하는 종류입니다. 학습은 서버에서, 추론은 기기에서라는 분업이 자연스러운 귀결입니다.

동시에 모든 조직이 기기 추론만으로 충분하지는 않습니다. 더 큰 컨텍스트나 복잡한 추론이 필요한 순간에는 여전히 서버 모델이 개입합니다. 이때 소스 데이터를 외부 클라우드로 보내기 꺼리는 조직에게는 온프레미스 서빙과 self-hosting이 중요해집니다. 낮은 서빙 비용에서 경쟁력을 갖추는 것이 이 조직들을 붙잡는 핵심입니다.

**Paxis 렌즈.** FunctionGemma의 본질은 자연어를 구조화된 도구 호출로 바꾸는 것입니다. 이것은 Paxis가 하는 일의 축소판입니다. Paxis는 ThakiCloud의 Agent-Native Cloud로, 960개가 넘는 스킬을 BM25로 선택해 격리 샌드박스에서 실행하고, 모든 행동을 정책 게이트와 감사 로그로 통과시킵니다. 온디바이스 에이전트가 좁은 도구 세트에 대한 함수 호출을 폰에서 처리한다면, Paxis는 훨씬 넓은 스킬 공간에 대한 도구 라우팅을 클라우드에서 처리합니다. 두 층은 경쟁하지 않고 보완합니다. 가벼운 로컬 의도 해석은 기기가, 복잡한 멀티에이전트 오케스트레이션과 감사가 필요한 작업은 Paxis가 맡는 계층 구조가 그려집니다.

## 한계 및 반론

이 접근에도 분명한 한계가 있습니다.

첫째, 특화의 대가는 범용성입니다. 46%를 90%로 올린 그 모델은 학습된 좁은 과제에서만 강합니다. 도구 스키마가 바뀌거나 새로운 앱 영역으로 넘어가면 다시 파인튜닝해야 합니다. 앱과 도구가 자주 바뀌는 환경에서는 유지보수 부담이 그만큼 커집니다.

둘째, 90%가 충분한가는 과제에 달렸습니다. 함수 호출을 잘못하면 잘못된 동작을 실행하는 것이므로, 실패 비용이 큰 도메인에서는 10%의 오류가 치명적일 수 있습니다. 이 경우 온디바이스 결과를 서버 모델이 검증하는 이중 구조가 필요해집니다.

셋째, 학습이 21분이라는 수치는 규모와 하드웨어에 크게 의존합니다. 데이터 준비, 스키마 정렬, 평가까지 포함한 실제 운영 비용은 학습 시간만으로 판단할 수 없습니다. 발표의 인상적인 수치는 잘 정돈된 조건에서의 값임을 감안해야 합니다.

넷째, 온디바이스 배포는 기기 파편화와 마주합니다. LiteRT-LM이 이질성을 흡수한다고 해도, 실제 기기별 성능과 메모리 제약은 여전히 개별 검증을 요구합니다.

그럼에도 작은 특화 모델을 기기에서 돌린다는 방향은 설득력이 있습니다. 지연, 프라이버시, 오프라인, 비용이라는 네 가지 이점이 동시에 성립하는 지점이기 때문입니다. 저희에게 이 흐름은 서버가 필요 없어진다는 신호가 아니라, 학습과 추론의 분업이 어디에 놓여야 하는지를 다시 그리게 하는 신호입니다.

## 출처

- [From 46% to 90%: Fine-Tuning Tiny LLMs for On-Device Agents - Cormac Brick, Google (YouTube)](https://www.youtube.com/watch?v=-TiET_K-E_g)
- [Google's Cormac Brick on Tiny LLMs for On-Device Agents - StartupHub.ai](https://www.startuphub.ai/ai-news/ai-research/2026/google-s-cormac-brick-on-tiny-llms-for-on-device-agents)
- [Fine-tune FunctionGemma 270M for Mobile Actions - Google AI for Developers](https://ai.google.dev/gemma/docs/mobile-actions)
