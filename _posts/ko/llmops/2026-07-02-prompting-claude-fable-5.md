---
title: "Fable 5를 프롬프트하는 법: 앤트로픽 공식 가이드가 말하는 다섯 가지"
excerpt: "앤트로픽이 공개한 Claude Fable 5 프롬프트 가이드를 뜯어봅니다. 이전 모델용 지시를 덜어내고, 진행을 도구 결과로 감사하고, 서브에이전트를 적극 쓰고, 지난 실행에서 배우고, 제약을 명시하라는 다섯 원칙을 ThakiCloud 에이전트 운영 관점에서 정리합니다."
tags:
  - claude
  - fable-5
  - prompt-engineering
  - agent
  - anthropic
date: 2026-07-02
lang: ko
audiobook: https://drive.google.com/file/d/1SC2JUwlVjspyMUJTkxIJroLGohmbRwGQ/view
audiobook_note: "AI 로컬 합성 오디오북 (Qwen3-TTS)"
canonical_url: "https://thakicloud.com/tech-blog/ko/llmops/prompting-claude-fable-5/"
categories:
  - llmops
---

## 개요

새 모델이 나올 때마다 우리는 옛 모델에 맞춰 쌓아 둔 프롬프트를 그대로 물려줍니다. 그런데 앤트로픽이 공개한 Claude Fable 5 프롬프트 가이드는 정확히 그 반대를 권합니다. 이전 모델을 잘 다루게 만들던 지시가 Fable 5에서는 오히려 품질을 떨어뜨린다는 것입니다. 가이드의 표현을 그대로 옮기면, 이전 모델용으로 개발된 스킬은 "Claude Fable 5에게는 종종 너무 지시적이어서 출력 품질을 떨어뜨릴 수 있습니다".

이 문장 하나가 전체 가이드의 기조를 요약합니다. 더 똑똑해진 모델에게는 더 많은 규칙이 아니라 더 적은 규칙이 필요합니다. ThakiCloud처럼 에이전트를 실제로 운영하는 조직에게 이 전환은 남의 이야기가 아닙니다. 우리가 수백 개의 스킬과 룰로 에이전트를 통제하는 방식이 새 모델 앞에서는 짐이 될 수도 있다는 경고이기 때문입니다. 가이드가 제시하는 다섯 가지 원칙을 하나씩 살펴보고, 그중 상당수가 우리가 이미 실천해 온 규율과 겹친다는 점을 확인하겠습니다.

## 무엇이 달라졌나

Fable 5는 이전 세대보다 자율성이 높습니다. 스스로 서브에이전트를 더 적극적으로 띄우고, 긴 작업을 스스로 밀고 나가며, 요청하지 않은 행동까지 하는 경우가 생깁니다. 능력이 올라간 만큼 통제의 방식도 바뀌어야 합니다. 세세하게 손을 잡아 끄는 지시는 유능한 신입에게 매 단계를 지시하는 것과 같아서, 오히려 판단을 방해합니다. 가이드가 말하는 다섯 원칙은 이 자율성을 억누르는 대신 올바른 방향으로 흐르게 만드는 장치에 가깝습니다.

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
<div class="d3-arch" data-arch-root id="702promptingclaudefable5-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 892, "height": 398, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 383, "y": 24, "w": 120, "h": 62, "title": ["Fable 5", "높은 자율성"]}, {"id": "B", "x": 740, "y": 164, "w": 120, "h": 62, "title": ["1. 덜어내기", "과잉 지시 제거"]}, {"id": "C", "x": 565, "y": 164, "w": 120, "h": 62, "title": ["2. 도구 결과로 감사", "자기보고 금지"]}, {"id": "D", "x": 375, "y": 164, "w": 135, "h": 62, "title": ["3. 서브에이전트 적극 활용", "비동기 위임"]}, {"id": "E", "x": 199, "y": 164, "w": 121, "h": 62, "title": ["4. 지난 실행에서 학습", "교훈 기록"]}, {"id": "F", "x": 24, "y": 164, "w": 120, "h": 62, "title": ["5. 제약 명시", "할 일과 안 할 일"]}, {"id": "G", "x": 383, "y": 304, "w": 120, "h": 62, "title": ["방향은 잡되", "판단은 맡기는 프롬프트"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[503, 67], [800, 125], [800, 125], [800, 164]]}, {"src": "A", "dst": "C", "kind": "data", "curve": [[503, 78], [625, 125], [625, 125], [625, 164]]}, {"src": "A", "dst": "D", "kind": "data", "line": [443, 86, 443, 164]}, {"src": "A", "dst": "E", "kind": "data", "curve": [[383, 78], [260, 125], [260, 125], [260, 164]]}, {"src": "A", "dst": "F", "kind": "data", "curve": [[383, 67], [84, 125], [84, 125], [84, 164]]}, {"src": "B", "dst": "G", "kind": "data", "curve": [[800, 226], [800, 265], [800, 265], [503, 323]]}, {"src": "C", "dst": "G", "kind": "data", "curve": [[625, 226], [625, 265], [625, 265], [503, 312]]}, {"src": "D", "dst": "G", "kind": "data", "line": [443, 226, 443, 304]}, {"src": "E", "dst": "G", "kind": "data", "curve": [[260, 226], [260, 265], [260, 265], [383, 312]]}, {"src": "F", "dst": "G", "kind": "data", "curve": [[84, 226], [84, 265], [84, 265], [383, 323]]}]});
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
      const container = document.getElementById('702promptingclaudefable5-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '702promptingclaudefable5-1';
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

## 원칙 1: 덜어내라

가이드가 첫 번째로 강조하는 것은 삭제입니다. 이전 모델을 위해 촘촘하게 써 둔 지시가 Fable 5에서는 성능을 갉아먹습니다. 규칙이 많을수록 좋다는 직관은 이 모델에서 뒤집힙니다. 새 모델로 갈아탈 때 프롬프트를 더 쌓는 대신, 어떤 지시가 이제 불필요한지 걷어내는 작업이 먼저입니다.

이 원칙은 우리 저장소가 오래 지켜 온 "얇은 하네스, 두꺼운 스킬" 발상과 정확히 맞닿습니다. 능력은 하네스가 아니라 스킬과 데이터에 쌓되, 매 턴 지불하는 지시는 최소로 유지한다는 규율입니다. 새 모델을 맞이할 때 우리가 가장 먼저 할 일은 룰과 스킬을 늘리는 것이 아니라, "이 문장이 없으면 에이전트가 틀리는가"라는 질문을 통과하지 못하는 지시를 솎아내는 것입니다.

## 원칙 2: 진행을 도구 결과로 감사하라

긴 자율 실행에서 Fable 5는 실제 도구 결과에 비추어 진행 상황을 스스로 감사하도록 지시받아야 합니다. 가이드가 제시하는 예시 지시는 이렇습니다.

```text
Before reporting progress, audit each claim against a tool result
from this session. Only report work you can point to evidence for.
```

앤트로픽의 테스트에서 이 한 문장은 날조된 진행 보고를 거의 없앴다고 합니다. 모델이 "완료한 것 같습니다"라고 말하는 대신, 이 세션의 도구 결과 중 근거를 가리킬 수 있는 작업만 보고하게 만드는 것입니다.

이것은 우리가 여러 룰에서 반복해 온 원칙, 즉 모델의 자기보고는 루프의 종료 조건이 될 수 없다는 규율과 같습니다. 가장 믿을 수 있는 피드백은 테스트와 타입체커와 컴파일러처럼 통과와 실패를 객관적으로 돌려주는 결정론적 검증입니다. 우리 저장소의 검증 게이트가 exit 코드로 판정하고, fan-out 결과를 표결로 닫는 이유가 여기에 있습니다. 앤트로픽이 공식 가이드에 이 원칙을 명문화했다는 사실은, 자기보고를 믿지 않는 규율이 특정 팀의 취향이 아니라 에이전트 운영의 기본값이 되어 가고 있음을 보여 줍니다.

## 원칙 3: 서브에이전트를 적극 써라

Fable 5는 이전 모델보다 병렬 서브에이전트를 더 선뜻 띄웁니다. 가이드는 이 성향을 억누르지 말고 활용하되, 언제 위임이 적절한지 명시적으로 안내하고, 오케스트레이터와 서브에이전트 사이의 통신은 비동기를 선호하라고 권합니다. 위임 자체가 목적이 아니라, 독립적인 일을 병렬로 흘려보내 전체 처리량을 높이는 것이 목적입니다.

우리 저장소의 모델 라우팅 규율이 바로 이 지점을 다룹니다. 탐색과 파일 읽기는 저비용 모델에, 구현은 중간 티어에, 복잡한 추론과 검증만 고비용 모델에 배정하고, 서브에이전트를 띄울 때는 모델 파라미터를 반드시 지정합니다. Fable 5가 서브에이전트를 더 잘 다룬다는 것은, 이런 라우팅이 앞으로 더 큰 효과를 낸다는 뜻이기도 합니다. 지휘자는 가볍게 두고 무거운 일만 전문 서브에이전트로 격리하는 패턴이 모델의 성향과 맞물립니다.

## 원칙 4: 지난 실행에서 배워라

Fable 5는 이전 실행에서 얻은 교훈을 기록하고 참조할 수 있을 때 특히 잘 작동합니다. 가이드는 마크다운 파일 하나만큼 단순한 저장 공간이라도 마련해 주라고 권하며, 예시로 이렇게 적습니다.

```text
Store one lesson per file with a one-line summary at the top.
Record corrections and confirmed approaches alike, including why
they mattered.
```

교훈 하나를 파일 하나에 담고, 맨 위에 한 줄 요약을 붙이고, 교정과 확인된 접근을 이유와 함께 기록하라는 것입니다. 이 지침은 이 글을 쓰는 시스템의 메모리 구조와 놀랍도록 닮았습니다. ThakiCloud의 에이전트 메모리는 정확히 파일 하나에 사실 하나를 담고, 프론트매터에 한 줄 요약을 두며, 교정과 확정된 패턴을 이유와 함께 남기는 방식으로 운영됩니다. 세션이 시작될 때 직전까지의 학습을 상주 브리프로 읽어들이는 핫 메모리 루프도 같은 발상 위에 있습니다. 앤트로픽의 권고가 우리 메모리 규율과 이렇게 겹친다는 것은, 에이전트를 백지에서 매번 다시 시작하게 두지 않는 설계가 보편적인 정답에 가까워지고 있다는 신호입니다.

## 원칙 5: 제약을 명시하라

높은 자율성의 대가로 Fable 5는 요청하지 않은 행동을 이따금 합니다. 가이드는 이를 막기 위해 모델이 해야 할 일과 하지 말아야 할 일에 대한 명시적 제약을 정의하라고 권합니다. 방향을 열어 주되, 넘지 말아야 할 선은 분명히 그으라는 것입니다.

우리 운영에서 이 선은 승인 게이트와 되돌릴 수 없는 변경에 대한 안전망으로 구현됩니다. 스키마 변경이나 배포처럼 비가역적인 작업은 계획을 먼저 세우고 승인을 받게 하고, 매매 집행 같은 고위험 행동에는 하드 가드를 겁니다. 모델이 유능해질수록 "무엇을 할 수 있는가"보다 "무엇을 해서는 안 되는가"를 명확히 하는 일이 중요해집니다. Fable 5의 자율성은 제약이 잘 그어져 있을 때 자산이 되고, 그렇지 않을 때 위험이 됩니다.

## ThakiCloud 제품 적용 시사점

이 다섯 원칙은 ThakiCloud가 만드는 Paxis의 설계 철학과 그대로 포개집니다. Paxis는 ai-platform 위에서 도는 Agent-Native Cloud 제어 평면으로, 스킬과 도구와 정책과 감사 로그를 일급 리소스로 다룹니다. 가이드가 말하는 "덜어내기"는 우리가 스킬 하네스를 얇게 유지하고 능력을 스킬에 쌓는 방식이고, "도구 결과 감사"는 우리가 결정론적 검증 게이트로 fan-out을 닫는 방식이며, "서브에이전트 적극 활용"은 DAG 멀티에이전트와 모델 라우팅으로 구현됩니다. "지난 실행에서 배우기"는 우리 메모리 엔진과 핫 메모리 루프이고, "제약 명시"는 정책 게이트와 감사 로그입니다.

바꿔 말하면, 앤트로픽의 프롬프트 가이드는 우리가 이미 운영 중인 규율에 공식적인 근거를 얹어 줍니다. 새 모델이 강해질수록 이 규율의 값어치는 커집니다. 유능한 모델을 백지에서 시작하게 두거나, 자기보고를 그대로 믿거나, 과잉 지시로 판단을 막는 대신, 얇은 하네스와 검증 게이트와 지속 메모리로 감싸는 편이 낫습니다. Paxis가 파는 것이 바로 그 감싸는 방식입니다.

## 한계 및 반론

이 가이드를 도그마로 받아들이면 곤란합니다. "덜어내라"는 원칙은 매력적이지만, 무엇을 덜어낼지는 여전히 판단의 영역입니다. 잘못 걷어낸 지시 하나가 회귀를 부를 수 있고, 그 회귀를 감지하려면 결국 앞의 원칙, 즉 결정론적 검증과 지난 실행의 기록이 있어야 합니다. 원칙들은 서로를 떠받치기 때문에 하나만 골라 적용하면 효과가 반감됩니다.

또한 이 가이드는 Fable 5라는 특정 모델을 겨냥합니다. 여기 적힌 조언이 모든 모델, 특히 자율성이 낮은 소형 모델에 그대로 이전되지는 않습니다. 소형 모델일수록 오히려 더 촘촘한 지시와 고정된 골격이 품질을 지킵니다. "지시를 줄여라"를 모든 티어에 일괄 적용하면 저비용 워커의 출력이 흔들립니다. 모델 티어에 따라 프롬프트 규율을 다르게 가져가는 판단이 필요합니다.

마지막으로, 자율성이 높은 모델일수록 제약을 거는 일이 어려워진다는 역설이 있습니다. 서브에이전트를 스스로 띄우고 요청하지 않은 행동을 하는 모델에게 "하지 말라"를 강제하려면, 프롬프트만으로는 부족하고 결정론적 훅과 승인 게이트가 뒷받침되어야 합니다. 가이드는 프롬프트의 언어를 다루지만, 진짜 안전망은 코드가 소유해야 합니다.


## 관련 슬라이드

본문 내용을 NotebookLM(`architectural_portfolio` 스타일)으로 요약한 슬라이드입니다.

![prompting-claude-fable-5 슬라이드 1]({{ '/assets/images/prompting-claude-fable-5-slide-01.webp' | relative_url }})

![prompting-claude-fable-5 슬라이드 2]({{ '/assets/images/prompting-claude-fable-5-slide-02.webp' | relative_url }})

![prompting-claude-fable-5 슬라이드 3]({{ '/assets/images/prompting-claude-fable-5-slide-03.webp' | relative_url }})

![prompting-claude-fable-5 슬라이드 4]({{ '/assets/images/prompting-claude-fable-5-slide-04.webp' | relative_url }})

## 출처

- [Prompting Claude Fable 5, 앤트로픽 공식 문서 (platform.claude.com)](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5)
- [Redeploying Claude Fable 5, 앤트로픽 뉴스](https://www.anthropic.com/news/redeploying-fable-5)
