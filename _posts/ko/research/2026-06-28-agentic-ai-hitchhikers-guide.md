---
title: "에이전트 AI를 처음부터 시스템까지 한 권으로: 'The Hitchhiker's Guide to Agentic AI'를 읽었습니다"
excerpt: "arXiv에 올라온 'The Hitchhiker's Guide to Agentic AI: From Foundations to Systems'는 LLM 기질부터 정렬·추론, 에이전트 시스템, 그리고 프로덕션 배포까지 에이전트 AI의 전 계층을 한 번에 꿰는 실무 레퍼런스입니다. 네 개 층위로 정리하고, ThakiCloud의 Agent-Native Cloud인 Paxis 관점에서 무엇을 가져갈 수 있는지 짚었습니다."
seo_title: "에이전트 AI 전 계층 가이드 정리 - Hitchhiker's Guide to Agentic AI - Thaki Cloud"
seo_description: "arXiv:2606.24937 'The Hitchhiker's Guide to Agentic AI'를 LLM 기질, 정렬·추론, 에이전트 시스템(MCP·스킬·메모리·멀티에이전트·A2A), 배포·평가의 네 층위로 정리하고 ThakiCloud Paxis Agent-Native Cloud 적용 관점을 더했습니다."
date: 2026-06-28
last_modified_at: 2026-06-28
tags:
  - agentic-ai
  - llm
  - mcp
  - multi-agent
  - rag
  - agent-skills
  - a2a
  - survey
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ko/research/agentic-ai-hitchhikers-guide/"
reading_time: true
categories:
  - research
audiobook: https://drive.google.com/file/d/1Ux2j1A6u8wE_CMdSKRn8q8vqXdM_pmAb/view
audiobook_note: "AI 로컬 합성 오디오북 (Qwen3-TTS)"
published: false
---

![빛으로 이루어진 네 개의 층이 아래에서 위로 쌓이며 서로 연결되는 추상 구조]({{ '/assets/images/agentic-ai-hitchhikers-guide-hero.webp' | relative_url }})

## 개요

에이전트 AI를 공부하다 보면 자료가 흩어져 있다는 사실에 먼저 부딪힙니다. 트랜스포머 구조는 한 곳에서, 강화학습 정렬은 다른 곳에서, MCP와 멀티에이전트 협업은 또 다른 블로그에서 조각조각 익히게 됩니다. 각 조각은 충실하지만, 그것들이 어떻게 한 시스템으로 이어지는지를 보여주는 자료는 드뭅니다.

2026년 6월 arXiv에 공개된 [The Hitchhiker's Guide to Agentic AI: From Foundations to Systems](https://arxiv.org/abs/2606.24937)가 채우려는 빈자리가 바로 여기입니다. 이 문서는 짧은 서베이가 아니라, LLM이라는 기질에서 출발해 정렬과 추론을 거쳐 에이전트 시스템을 세우고 프로덕션까지 배포하는 전 과정을 한 권으로 묶은 실무 레퍼런스입니다. 각 장은 이론적 토대와 함께 구현 가이드, 코드 예시, 그리고 1차 문헌 참조를 짝지어 제시합니다.

ThakiCloud처럼 에이전트를 일급 리소스로 다루는 플랫폼을 운영하는 입장에서 이 가이드는 남의 이야기가 아닙니다. 우리가 Paxis(Agent-Native Cloud)에서 매일 다루는 스킬, 도구, 메모리, 멀티에이전트 오케스트레이션이 이 문서의 후반부 절반을 그대로 차지하기 때문입니다. 이 글은 가이드의 구조를 네 개 층위로 정리하고, 우리 제품 관점에서 무엇을 취할 수 있는지를 함께 짚습니다.

![파편화된 지식에서 단일 시스템으로 정리한 도식]({{ '/assets/images/agentic-ai-hitchhikers-guide-slide-02.webp' | relative_url }})
*흩어진 에이전트 AI 지식을 하나의 시스템으로 묶는 것이 이 가이드의 출발점입니다.*

## 이 가이드는 무엇인가

이 문서는 "에이전트를 만들고 싶은 실무자"를 독자로 상정합니다. 그래서 개념을 나열하는 데 그치지 않고, 첫 원리에서 시작해 프로덕션 배포로 끝나는 스택 전체를 따라갑니다. 핵심은 계층 사이의 의존 관계입니다. 좋은 에이전트는 갑자기 등장하지 않습니다. 잘 학습된 모델 위에 정렬과 추론 능력이 얹히고, 그 위에 도구 사용과 메모리, 협업이 쌓여야 비로소 시스템이 됩니다.

가이드가 다루는 범위를 네 개 층위로 압축하면 다음과 같습니다.

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
<div class="d3-arch" data-arch-root id="genticaihitchhikersguide-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 268, "height": 678, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 24, "y": 24, "w": 212, "h": 94, "title": ["1. LLM 기질", "트랜스포머 · GPU 시스템", "SFT · LoRA · MoE · 압축 · 추론", "최적화"]}, {"id": "B", "x": 28, "y": 196, "w": 205, "h": 78, "title": ["2. 정렬과 추론", "RLHF · PPO · DPO · GRPO", "보상 모델링 · CoT · 테스트타임 스케일링"]}, {"id": "C", "x": 28, "y": 366, "w": 205, "h": 110, "title": ["3. 에이전트 시스템", "궤적 기반 RL · RAG / Agentic", "RAG", "메모리 · MCP · 스킬/도구 · A2A ·", "멀티에이전트"]}, {"id": "D", "x": 45, "y": 568, "w": 170, "h": 78, "title": ["4. 배포와 평가", "에이전트 프레임워크 · 에이전트 UI", "평가 방법론 · 프로덕션 배포"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [130, 118, 130, 196]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[139, 274], [150, 320], [150, 320], [141, 366]]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[138, 476], [145, 522], [145, 522], [137, 568]]}, {"src": "D", "dst": "C", "kind": "event", "label": "피드백", "curve": [[123, 568], [115, 522], [115, 522], [122, 476]], "off": "50%"}, {"src": "C", "dst": "B", "kind": "event", "label": "재학습 신호", "curve": [[119, 366], [110, 320], [110, 320], [121, 274]], "off": "50%"}]});
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
      const container = document.getElementById('genticaihitchhikersguide-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'genticaihitchhikersguide-1';
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

아래에서 각 층을 차례로 살펴봅니다.

## 기반: LLM 기질

가이드는 트랜스포머 구조와 GPU 시스템에서 출발합니다. 그다음 학습과 미세조정으로 넘어가는데, 지도 미세조정(SFT), LoRA 같은 파라미터 효율 기법, 그리고 전문가 혼합(MoE) 구조를 다룹니다. 마지막으로 모델 압축과 추론 최적화로 마무리합니다.

이 순서가 의미하는 바가 있습니다. 에이전트의 행동 품질은 결국 기반 모델의 능력에 묶여 있고, 그 모델을 실제로 굴리는 비용은 압축과 추론 최적화에서 갈립니다. 추론 비용을 낮추지 못하면 에이전트가 도구를 여러 번 호출하고 긴 궤적을 밟는 순간 경제성이 무너집니다. 즉 가장 아래 층의 효율이 가장 위 층의 실현 가능성을 결정합니다.

![기반 모델 압축·최적화와 추론 비용의 관계를 정리한 슬라이드]({{ '/assets/images/agentic-ai-hitchhikers-guide-slide-04.webp' | relative_url }})
*가장 아래 층의 효율이 가장 위 층의 실현 가능성을 결정합니다.*

## 정렬과 추론 층

두 번째 층은 정렬과 추론입니다. 인간 피드백 기반 강화학습(RLHF)에서 시작해 PPO, DPO와 그 변형들, 그리고 GRPO와 보상 모델링을 다룹니다. 이어서 큰 추론 모델을 위한 강화학습으로 넘어가며, 사고 사슬(chain-of-thought)과 테스트타임 스케일링을 짚습니다.

여기서 중요한 전환이 일어납니다. 단순히 "사람이 좋아하는 답"을 내도록 맞추는 단계에서, "스스로 더 오래 생각해 더 나은 답에 도달하는" 추론 능력으로 무게 중심이 옮겨갑니다. 에이전트가 여러 단계를 계획하고 중간 결과를 검증하려면 이 추론 층이 탄탄해야 합니다. 정렬이 안전을 책임진다면, 추론은 자율성을 책임집니다.

![정렬에서 추론으로 넘어가는 3단계를 정리한 슬라이드]({{ '/assets/images/agentic-ai-hitchhikers-guide-slide-05.webp' | relative_url }})
*정렬이 안전을 책임진다면, 추론은 자율성을 책임집니다.*

## 에이전트 시스템: MCP, 스킬, 메모리, 멀티에이전트

가이드의 후반부 절반이 여기에 할애됩니다. 그만큼 에이전트 AI의 무게중심이 이 층에 있다는 뜻입니다. 다루는 주제를 보면 우리에게 익숙한 이름들이 줄지어 등장합니다.

- **궤적 기반 강화학습**: 단발 응답이 아니라, 도구 호출과 관찰이 이어지는 행동 궤적 전체를 학습 신호로 삼습니다.
- **RAG와 Agentic RAG**: 검색 증강 생성을 정적 파이프라인에서 에이전트가 능동적으로 검색 전략을 결정하는 형태로 끌어올립니다.
- **메모리 시스템**: 세션을 넘어 지식을 누적하고 회수하는 구조입니다.
- **MCP(Model Context Protocol)**: 에이전트가 외부 도구·데이터와 표준화된 방식으로 연결되는 통로입니다.
- **에이전트 스킬과 도구 사용**: 능력을 재사용 가능한 단위로 패키징하고 선택·실행합니다.
- **A2A(Agent-to-Agent) 프로토콜과 멀티에이전트 구조**: 에이전트끼리 작업을 위임하고 조율합니다.

이 목록은 사실상 Agent-Native 플랫폼의 부품 명세서와 같습니다. 스킬을 어떻게 고르고, 도구를 어떻게 안전하게 호출하며, 메모리를 어떻게 라우팅하고, 여러 에이전트의 작업을 어떻게 DAG로 묶는가. 가이드는 이 질문들을 흩어진 기법이 아니라 하나의 시스템 설계 문제로 다룹니다.

![에이전트 시스템 부품 명세서: 메모리·MCP·스킬·멀티에이전트]({{ '/assets/images/agentic-ai-hitchhikers-guide-slide-06.webp' | relative_url }})
*이 부품 목록은 사실상 Agent-Native 플랫폼의 명세서와 같습니다.*

## 배포와 평가

마지막 층은 실제 운영입니다. 에이전트 개발 프레임워크, 에이전트 UI 설계, 에이전트 작업에 맞는 평가 방법론, 그리고 프로덕션 배포를 다룹니다.

평가가 별도 층으로 분리되어 있다는 점이 인상적입니다. 단일 응답의 정확도만 보던 시절의 지표로는 도구를 여러 번 호출하고 여러 단계를 밟는 에이전트를 측정할 수 없습니다. 궤적의 성공률, 중간 단계의 안전성, 비용 대비 효용을 함께 봐야 합니다. 가이드가 평가를 구현의 부록이 아니라 독립된 주제로 둔 것은, 에이전트 시스템에서 "잘 돌아가는지 어떻게 아는가"가 그만큼 어려운 문제이기 때문입니다.

![단일 응답 정확도를 넘어 궤적 기반 평가로 전환하는 슬라이드]({{ '/assets/images/agentic-ai-hitchhikers-guide-slide-07.webp' | relative_url }})
*단일 응답 정확도만 보던 지표로는 다단계 에이전트를 측정할 수 없습니다.*

## ThakiCloud 제품 적용 시사점

이 가이드의 후반부는 ThakiCloud의 **Paxis** 설계도와 거의 겹칩니다. Paxis는 ai-platform 위에서 도는 Agent-Native Cloud 제어 평면으로, 스킬·도구·정책·감사 로그를 일급 리소스로 다룹니다. 가이드가 다루는 부품들을 우리 레이어에 대응시키면 이렇게 읽힙니다.

- **에이전트 스킬과 도구 사용 → Skill Harness**: Paxis는 960개가 넘는 스킬을 BM25로 선택해 격리 샌드박스에서 실행합니다. 가이드가 강조하는 "능력을 재사용 단위로 패키징한다"는 원칙을 운영 규모에서 구현한 형태입니다.
- **MCP → MCP 커넥터**: Paxis는 OAuth 자동 재연결을 갖춘 MCP 커넥터로 외부 도구·데이터를 연결합니다. 가이드의 표준 연결 통로가 제품에서는 끊겨도 스스로 복구하는 인프라로 들어옵니다.
- **메모리 시스템 → HKE 지식 엔진**: 세션을 넘는 지식 누적·회수를 위키 기반 지식 엔진으로 다룹니다.
- **멀티에이전트·A2A → DAG 멀티에이전트**: 작업을 DAG로 묶어 위임하고 조율하며, NL Cron으로 시점을 제어합니다.
- **배포·평가·안전 → 정책 게이트 + 감사 로그 + 자가진화 스킬**: 모든 에이전트 행동을 정책 게이트와 감사 로그로 통과시키고, 반복 패턴은 자가진화 스킬로 흡수합니다. 가이드가 평가를 독립 층으로 둔 문제의식과 정확히 맞닿습니다.

기반 층의 시사점도 빼놓을 수 없습니다. 가이드 첫 층의 추론 최적화·압축은 그대로 **ai-platform**의 과제입니다. ThakiCloud의 ai-platform은 쿠버네티스와 Kueue 기반 GPU 스케줄링, vLLM 서빙, 멀티테넌트 격리를 통해 에이전트가 도구를 여러 번 호출해도 경제성이 유지되는 추론 기반을 제공합니다. 낮은 서빙 비용(ai-platform)이 곧 에이전트의 경제성(Paxis)을 만든다는 점에서, 이 가이드의 가장 아래 층과 가장 위 층은 우리 제품에서 한 줄로 이어집니다.

![가이드의 이론을 ThakiCloud Paxis 레이어에 매핑한 표]({{ '/assets/images/agentic-ai-hitchhikers-guide-slide-08.webp' | relative_url }})
*가이드의 부품 명세가 Paxis의 실제 레이어와 거의 1:1로 대응합니다.*

## 한계 및 반론

이 문서를 만능 교재로 받아들이는 것은 경계해야 합니다. 첫째, 분야의 속도입니다. 에이전트 AI는 월 단위로 표준이 바뀝니다. 오늘 정리된 MCP·A2A 구현 세부는 6개월 뒤 달라질 수 있고, 가이드의 코드 예시도 버전에 묶입니다. 개념 지도로는 오래 유효하지만, 구현 디테일은 늘 1차 출처로 다시 확인해야 합니다.

둘째, "전부 다룬다"는 것은 곧 "어느 것도 끝까지 깊게 파지 못한다"는 뜻이기도 합니다. 한 권으로 전 계층을 묶으면 폭은 얻지만, 특정 기법을 실제 프로덕션 수준으로 끌어올리려면 결국 전용 문헌과 실험이 필요합니다. 이 가이드의 진짜 가치는 답을 주는 데 있다기보다, 흩어진 조각들이 한 시스템 안에서 어디에 놓이는지를 보여주는 지도에 있습니다. 지도와 실제 주행은 다른 일입니다.

![가이드는 지도이고 실제 구현은 주행이라는 한계를 정리한 슬라이드]({{ '/assets/images/agentic-ai-hitchhikers-guide-slide-09.webp' | relative_url }})
*지도와 실제 주행은 다릅니다. 구현 디테일은 늘 1차 출처로 다시 확인해야 합니다.*

## 출처

- [The Hitchhiker's Guide to Agentic AI: From Foundations to Systems (arXiv:2606.24937)](https://arxiv.org/abs/2606.24937)
- [alphaXiv 페이지](https://www.alphaxiv.org/abs/2606.24937)
