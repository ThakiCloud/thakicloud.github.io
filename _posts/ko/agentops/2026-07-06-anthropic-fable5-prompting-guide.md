---
title: "Fable 5는 다르게 프롬프팅합니다: Anthropic 공식 가이드가 말하는 네 가지 전환"
excerpt: "Anthropic이 Claude Fable 5와 Mythos 5를 위한 공식 프롬프팅 가이드를 조용히 공개했습니다. 핵심은 더 정교한 프롬프트가 아니라 반대 방향입니다. 이전 모델용으로 쌓아온 지시를 지우고, effort로 지능·비용을 조절하고, 진행 보고를 증거에 감사시키고, 서브에이전트를 비동기로 오케스트레이션하라는 것입니다. 네 가지 전환을 실제 문서 근거로 정리하고, ThakiCloud의 Paxis Agent-Native Cloud와 ai-platform 운용 관점에서 무엇이 바뀌는지 짚습니다."
seo_title: "Anthropic Fable 5 공식 프롬프팅 가이드 정리: effort·검증·서브에이전트 - Thaki Cloud"
seo_description: "Anthropic 공식 Fable 5 프롬프팅 가이드의 네 가지 핵심 전환을 분석합니다. 과도한 프롬프트 삭제, effort 파라미터로 지능·지연·비용 제어, 증거 기반 진행 검증, 비동기 서브에이전트 오케스트레이션, 그리고 ThakiCloud Paxis·ai-platform 적용 관점을 정리했습니다."
date: 2026-07-06
last_modified_at: 2026-07-06
tags:
  - ai-coding
  - agentic
  - claude-fable-5
  - prompt-engineering
  - agentops
  - verification
  - subagents
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "robot"
canonical_url: "https://thakicloud.com/tech-blog/ko/agentops/anthropic-fable5-prompting-guide/"
categories:
  - agentops
audiobook: https://drive.google.com/file/d/1RiPCBx18whGJJWlhZ6cVaKUr2m9C4iBk/view
audiobook_note: "AI 로컬 합성 오디오북 (Qwen3-TTS)"
published: false
---

## 개요

Claude Fable 5를 다시 열기 전에 봐야 할 문서가 하나 생겼습니다. Anthropic이 Claude Fable 5와 Claude Mythos 5를 위한 공식 프롬프팅 가이드를 프롬프트 엔지니어링 문서 안에 조용히 올렸습니다. 요란한 발표 대신 문서 페이지 하나로 나왔기 때문에 놓친 분이 많지만, 내용을 읽어보면 지난 세대 모델을 다루던 습관을 상당 부분 뒤집으라는 이야기라 가볍게 넘길 문서가 아닙니다.

가장 반직관적인 지점부터 짚겠습니다. 이 가이드의 관통하는 메시지는 "더 잘 쓰라"가 아니라 "덜 쓰라"에 가깝습니다. 이전 모델에서 좋은 결과를 뽑기 위해 쌓아 올린 상세한 지시가 Fable 5에서는 오히려 품질을 떨어뜨릴 수 있다는 것입니다. Fable 5는 사람이 몇 시간, 며칠, 길게는 몇 주에 걸쳐 처리할 만큼 복잡하고 길고 모호한 작업을 위임하는 모델로 설계됐고, 그런 모델에는 과도한 손잡이가 방해가 됩니다. ThakiCloud는 쿠버네티스 기반 AI/ML SaaS 인프라와 그 위에서 도는 에이전트 플랫폼을 운영하며 이런 장기 자율 에이전트를 매일 다루기 때문에, 이 가이드의 권고 하나하나가 우리에게는 곧 운용 규칙의 문제입니다. 이 글은 가이드가 제시한 네 가지 전환을 문서 근거와 함께 정리하고, 그것이 우리 제품에 어떻게 내려앉는지를 짚습니다.

![장기 자율 에이전트를 위한 프롬프팅 전환을 표현한 추상 이미지]({{ '/assets/images/anthropic-fable5-prompting-guide-hero.webp' | relative_url }})

## 이 가이드는 무엇인가

이 문서는 Anthropic 공식 플랫폼 문서의 프롬프트 엔지니어링 섹션에 있는 "Prompting Claude Fable 5" 페이지입니다. Fable 5와 그 상위 결의 Mythos 5에 특화된 프롬프팅과 스캐폴딩 패턴을 다루며, 열네 개의 절로 구성돼 있습니다. 이전 세대를 위한 일반 프롬프트 문서와 별도로, 이 모델군에서 무엇이 달라졌는지에 초점을 맞춘 마이그레이션 성격의 안내서입니다.

핵심을 관통하는 전제는 능력 도약입니다. Fable 5는 이전 모델에서는 너무 복잡하거나 너무 길거나 너무 모호해서 넘기기 어려웠던 문제를 감당하도록 만들어졌습니다. 그래서 이 모델을 잘 쓰는 방법은 더 촘촘한 통제가 아니라, 모델에게 판단의 여지를 주되 그 판단이 헛돌지 않도록 검증과 위임의 뼈대를 세우는 쪽으로 이동합니다. 가이드의 권고는 크게 네 갈래로 읽힙니다.

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
<div class="d3-arch" data-arch-root id="opicfable5promptingguide-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 725, "height": 522, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 294, "y": 24, "w": 120, "h": 62, "title": ["장기 자율 작업 위임", "(시간·일·주 단위)"]}, {"id": "B", "x": 573, "y": 164, "w": 120, "h": 62, "title": ["전환 1", "과도한 지시 삭제"]}, {"id": "C", "x": 376, "y": 164, "w": 142, "h": 62, "title": ["전환 2", "effort로 지능·비용 제어"]}, {"id": "D", "x": 200, "y": 164, "w": 121, "h": 62, "title": ["전환 3", "진행 보고를 증거에 감사"]}, {"id": "E", "x": 24, "y": 164, "w": 121, "h": 62, "title": ["전환 4", "서브에이전트 비동기 위임"]}, {"id": "F", "x": 480, "y": 304, "w": 120, "h": 46, "title": "모델 판단 여지 확보"}, {"id": "G", "x": 201, "y": 304, "w": 120, "h": 46, "title": "환각성 진행 보고 억제"}, {"id": "H", "x": 25, "y": 304, "w": 120, "h": 46, "title": "병렬 처리·캐시 재사용"}, {"id": "I", "x": 201, "y": 428, "w": 120, "h": 62, "title": ["신뢰 가능한", "장기 자율 실행"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[414, 70], [633, 125], [633, 125], [633, 164]]}, {"src": "A", "dst": "C", "kind": "data", "curve": [[395, 86], [447, 125], [447, 125], [447, 164]]}, {"src": "A", "dst": "D", "kind": "data", "curve": [[312, 86], [261, 125], [261, 125], [261, 164]]}, {"src": "A", "dst": "E", "kind": "data", "curve": [[294, 71], [85, 125], [85, 125], [85, 164]]}, {"src": "B", "dst": "F", "kind": "data", "curve": [[633, 226], [633, 265], [633, 265], [575, 304]]}, {"src": "C", "dst": "F", "kind": "data", "curve": [[447, 226], [447, 265], [447, 265], [506, 304]]}, {"src": "D", "dst": "G", "kind": "data", "line": [261, 226, 261, 304]}, {"src": "E", "dst": "H", "kind": "data", "line": [85, 226, 85, 304]}, {"src": "F", "dst": "I", "kind": "data", "curve": [[540, 350], [540, 389], [540, 389], [321, 444]]}, {"src": "G", "dst": "I", "kind": "data", "line": [261, 350, 261, 428]}, {"src": "H", "dst": "I", "kind": "data", "curve": [[85, 350], [85, 389], [85, 389], [201, 435]]}]});
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
      const container = document.getElementById('opicfable5promptingguide-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'opicfable5promptingguide-1';
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

## 전환 1: 프롬프트를 더하지 말고 지우세요

가장 먼저 나오는 권고는 기존 프롬프트와 스킬을 다시 읽고, 이제는 필요 없어진 지시를 삭제하라는 것입니다. 가이드는 이전 모델을 위해 만든 프롬프트와 스킬이 Fable 5에는 종종 너무 세세해서(too prescriptive) 오히려 출력 품질을 떨어뜨릴 수 있다고 설명합니다. 능력이 크게 오른 순간이야말로 과거의 지시를 정리하기 좋은 시점이라는 것입니다.

이 조언이 낯설게 들리는 이유는, 우리가 프롬프트 엔지니어링을 대체로 더하는 작업으로 배워왔기 때문입니다. 예외를 만나면 규칙을 추가하고, 실수를 보면 금지 조항을 붙이는 식으로 프롬프트는 계속 자라납니다. 그런데 그 규칙들은 특정 모델의 약점을 메우려고 넣은 경우가 많습니다. 모델이 그 약점을 이미 넘어섰다면, 남아 있는 규칙은 도움이 아니라 모델의 판단을 좁히는 족쇄가 됩니다. 가이드가 삭제를 강조하는 이유가 여기에 있습니다.

물론 이 권고를 "프롬프트를 다 지워라"로 오독하면 위험합니다. 뒤에서 다룰 검증 지시처럼, 여전히 명시적으로 넣어야 하는 지시도 있습니다. 실무적으로는 지시를 하나씩 떼어 보며 품질이 떨어지지 않는지 확인하고, 특정 모델의 결함을 메우던 조항인지 아니면 작업의 본질적 제약인지를 구분하는 감사 작업에 가깝습니다.

## 전환 2: effort가 지능·지연·비용의 주 제어판입니다

Fable 5에서 지능과 지연, 비용 사이의 균형을 조절하는 일차적 손잡이는 effort 파라미터입니다. 가이드는 대부분의 작업을 high로 시작하고, 능력이 특히 중요한 워크로드에는 xhigh를, 반복적이고 정형화된 일에는 medium이나 low를 쓰라고 권합니다. 즉 프롬프트를 더 길게 써서 성능을 짜내는 대신, 작업의 성격에 맞춰 effort를 올리고 내리는 것이 기본 조작법이 됩니다.

이 변화는 운용 관점에서 중요합니다. effort를 올리면 모델은 더 많은 추론을 수행하므로 지연과 비용이 함께 올라갑니다. 따라서 effort는 무조건 높이는 값이 아니라, 작업의 난이도에 맞춰 배분하는 예산 개념으로 다뤄야 합니다. 정형 작업까지 xhigh로 돌리면 비용만 새고, 어려운 판단을 low로 처리하면 품질이 무너집니다. 프롬프트 문장의 정교함보다 effort 배분의 정확도가 결과와 청구서를 동시에 좌우하는 구조입니다.

## 전환 3: 진행 보고를 증거에 감사시키세요

장기 자율 작업에서 가장 아프게 무는 실패 모드는, 실제로는 검증되지 않은 일을 자신 있게 완료했다고 보고하는 것입니다. 몇 시간짜리 루프가 도는 동안 모델이 "이 단계는 끝냈습니다"라고 말하는데 그 근거가 없다면, 그 보고는 신뢰할 수 없고 자칫 잘못된 상태 위에서 다음 작업이 쌓입니다.

가이드는 이 문제에 대해 구체적인 지시 문장을 제시합니다. 진행을 보고하기 전에 각 주장을 이번 세션의 도구 결과에 비추어 감사하고, 근거를 가리킬 수 있는 작업만 보고하며, 아직 검증되지 않은 것은 그렇다고 말하라는 것입니다. 원문의 표현을 옮기면 다음과 같습니다.

```text
Before reporting progress, audit each claim against a tool result
from this session. Only report work you can point to evidence for;
if something is not yet verified, say so.
```

Anthropic은 이 지시가 자사 테스트에서, 심지어 환각성 보고를 유도하도록 설계한 과제에서도 조작된 진행 보고를 거의 없앴다고 밝힙니다. 여기서 핵심은 두 가지입니다. 첫째, 이것은 삭제하라던 전환 1과 모순되지 않습니다. 모델의 결함을 메우던 낡은 규칙은 지우되, 자율 실행의 신뢰를 지키는 이런 지시는 명시적으로 넣어야 합니다. 둘째, 검증의 기준을 모델의 자기 확신이 아니라 도구 결과라는 외부 증거에 둔다는 점입니다. 이는 우리가 오래 지켜온 원칙, 즉 모델의 자기 보고를 루프 종료 조건으로 삼지 않는다는 규율과 정확히 맞닿습니다.

## 전환 4: 서브에이전트를 비동기로 오케스트레이션하세요

네 번째 전환은 멀티에이전트 구조입니다. 가이드에 따르면 Fable 5는 병렬 서브에이전트를 디스패치하고 유지하는 데 훨씬 안정적이며, 오래 도는 서브에이전트나 동료 에이전트와의 지속적 통신도 신뢰성 있게 관리합니다. 권고는 명확합니다. 서브에이전트를 자주 쓰되 언제 위임이 적절한지에 대한 명시적 지침을 주고, 오케스트레이터가 각 서브에이전트의 반환을 기다리며 막히기보다 비동기 통신을 우선하라는 것입니다.

여기에는 비용과 성능의 실질적 근거가 붙습니다. 컨텍스트를 여러 하위 작업에 걸쳐 유지하는 장수(long-lived) 서브에이전트는 캐시 재사용을 통해 시간과 비용을 아끼고, 가장 느린 서브에이전트에 전체가 발목 잡히는 병목을 피합니다. 독립적인 하위 작업은 서브에이전트에 넘기고 오케스트레이터는 그 사이에 계속 일하라는 조언은, 사람이 팀을 운영하는 방식과 닮았습니다. 그리고 자기 비판만으로 품질을 담보하지 말고 독립적인 검증 서브에이전트를 쓰라는 권고는 전환 3의 증거 기반 검증을 멀티에이전트 층위로 끌어올린 것입니다.

## ThakiCloud 제품 적용 시사점

이 가이드는 우리가 운영하는 Paxis에 특히 직접적으로 내려앉습니다. Paxis는 ThakiCloud의 Agent-Native Cloud로, 960개가 넘는 스킬을 BM25로 선택해 격리된 샌드박스에서 실행하고, 모든 행동을 정책 게이트와 감사 로그로 통과시키는 에이전트 제어 평면입니다. 가이드의 네 가지 전환은 이 구조와 하나씩 대응합니다.

전환 1의 삭제 철학은 Skill Harness의 스킬 설계 원칙과 맞물립니다. 우리는 스킬을 얇게 유지하고 도메인 지식은 스킬 본문에 두텁게 쌓되 불필요한 문장은 컨텍스트 비용으로 취급해 덜어내는 규율을 이미 지켜왔습니다. Fable 5가 과도한 지시를 싫어한다는 공식 확인은, 오래된 스킬에서 특정 구세대 모델의 결함을 메우던 조항을 걷어낼 근거가 됩니다. 전환 3의 증거 기반 검증은 정책 게이트와 감사 로그가 이미 담당하는 몫입니다. 모델이 완료를 주장하는 것과, 그 완료가 도구 결과와 감사 로그로 뒷받침되는 것은 다르며, Paxis는 후자를 일급 리소스로 다룹니다. 전환 4의 비동기 서브에이전트 오케스트레이션은 DAG 멀티에이전트 실행과 정확히 같은 그림입니다. 오케스트레이터가 블로킹 없이 독립 작업을 병렬로 흘려보내고 검증 노드로 닫는 구조는 우리가 팬아웃을 검증 스테이지로 닫는다는 원칙과 그대로 겹칩니다.

인프라 관점의 ai-platform 렌즈도 함께 봐야 합니다. effort를 xhigh로 올리면 추론 토큰이 늘어 GPU 연산 수요가 커지고, 병렬 서브에이전트를 많이 띄우면 순간적인 GPU 팬아웃 부하가 발생합니다. ThakiCloud의 ai-platform은 Kueue 기반 GPU 스케줄링과 멀티테넌트 격리로 이런 가변 부하를 흡수하도록 설계돼 있습니다. 장수 서브에이전트의 캐시 재사용이 비용을 줄인다는 가이드의 지적은, 온프레미스와 소버린 환경에서 서빙 비용을 낮추려는 우리 목표와 방향이 같습니다. 저비용 서빙이 에이전트 경제성을 만들고, 그 경제성이 다시 더 공격적인 병렬 위임을 가능하게 하는 선순환입니다.

## 한계 및 반론

이 가이드를 그대로 신봉하기 전에 몇 가지를 분명히 해야 합니다. 첫째, 이 문서는 Fable 5와 Mythos 5에 특화된 안내입니다. 여기서 권하는 삭제 전략이나 effort 기본값을 다른 벤더의 모델이나 이전 세대에 그대로 옮기면 오히려 품질이 떨어질 수 있습니다. 권고의 유효 범위를 모델군 안으로 한정해서 읽어야 합니다.

둘째, "프롬프트를 지우라"는 조언은 오용되기 쉽습니다. 안전 제약, 도메인 규정, 조직의 정책처럼 모델 성능과 무관하게 반드시 남겨야 하는 지시가 있습니다. 삭제는 무차별적 청소가 아니라, 조항 하나하나가 구세대 모델의 결함을 메우던 것인지 작업의 본질적 제약인지를 가려내는 감사여야 합니다. 실제로 가이드 자신도 검증 지시는 명시적으로 넣으라고 말하므로, 이 문서의 메시지는 "덜 쓰되 남길 것은 분명히 남겨라"에 더 가깝습니다.

셋째, 환각성 진행 보고를 거의 없앴다는 수치는 Anthropic 자사 테스트 결과이며, 이 글에서 우리가 독립적으로 재현한 값은 아닙니다. 검증 지시가 효과적이라는 방향성에는 동의하지만, 각 조직은 자신의 워크로드에서 실제 실패율을 측정한 뒤 신뢰 수준을 정해야 합니다. 마지막으로 effort를 high로 기본값을 두라는 권고는 비용과 지연을 함께 끌어올리므로, 예산이 빠듯한 팀은 정형 작업을 medium과 low로 적극 내려 배분의 균형을 스스로 찾아야 합니다.

정리하면 이 가이드의 값어치는 새로운 마법 문구가 아니라, 강해진 모델을 다루는 태도의 전환에 있습니다. 통제를 더하는 대신 판단의 여지를 주고, 그 판단이 헛돌지 않도록 증거로 검증하고 위임으로 병렬화하라는 것입니다. 장기 자율 에이전트를 실제로 운영하는 입장에서 보면, 이것은 트렌드 문장이 아니라 운용 규칙의 재정렬입니다.


## 관련 슬라이드

본문 내용을 NotebookLM(`architectural_portfolio` 스타일)으로 요약한 슬라이드입니다.

![anthropic-fable5-prompting-guide 슬라이드 1]({{ '/assets/images/anthropic-fable5-prompting-guide-slide-01.png' | relative_url }})

![anthropic-fable5-prompting-guide 슬라이드 2]({{ '/assets/images/anthropic-fable5-prompting-guide-slide-02.png' | relative_url }})

![anthropic-fable5-prompting-guide 슬라이드 3]({{ '/assets/images/anthropic-fable5-prompting-guide-slide-03.png' | relative_url }})

![anthropic-fable5-prompting-guide 슬라이드 4]({{ '/assets/images/anthropic-fable5-prompting-guide-slide-04.png' | relative_url }})

## 출처

- Anthropic, "Prompting Claude Fable 5", Claude Platform Docs: [https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5)
