---
title: "에이전트 절차적 메모리: 프롬프트 검색을 넘어서"
excerpt: "에이전트에게 스킬을 프롬프트로 넣어주는 방식은 컨텍스트를 잡아먹고 쉽게 깨집니다. 최근 연구는 절차적 메모리를 프롬프트 템플릿에서 빌드·검색·갱신이 분리된 구조로, 나아가 파라메트릭 신경 정책으로 옮기고 있습니다. Memp와 AFTER 벤치마크를 중심으로 이 전환의 지형을 정리하고, ThakiCloud Paxis의 스킬 하니스가 이 흐름을 어떻게 실무에 구현하는지 살펴봅니다."
seo_title: "에이전트 절차적 메모리: 프롬프트 검색을 넘어선 스킬 저장 | Thaki Cloud"
seo_description: "LLM 에이전트의 절차적 메모리 연구를 Memp(arXiv 2508.06433)와 AFTER 벤치마크(arXiv 2606.23127) 중심으로 정리하고, 빌드·검색·갱신 구조와 파라메트릭 전환, ThakiCloud Paxis 스킬 하니스 적용을 다룹니다."
date: 2026-07-02
last_modified_at: 2026-07-02
tags:
  - agent-memory
  - procedural-memory
  - llm-agents
  - skills
  - agent-skills
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "brain"
canonical_url: "https://thakicloud.com/tech-blog/ko/research/agent-procedural-memory-beyond-retrieval/"
categories:
  - research
audiobook: https://drive.google.com/file/d/1fE7l1erjZhLKd5yItoXxPJOI7k5NXbIB/view
audiobook_note: "AI 로컬 합성 오디오북 (Qwen3-TTS)"
published: false
---

![에이전트 절차적 메모리: 프롬프트 검색을 넘어 임시 템플릿에서 인지 인프라로의 전환]({{ '/assets/images/agent-procedural-memory-beyond-retrieval-slide-01.webp' | relative_url }})

## 개요

LLM 에이전트를 오래 굴려 본 사람은 같은 벽에 부딪힙니다. 에이전트가 매번 처음부터 추론하고, 지난주에 이미 해결한 절차를 또다시 더듬거립니다. 흔한 대응은 자주 쓰는 스킬을 프롬프트에 통째로 밀어 넣는 것입니다. 하지만 이 방식은 두 가지 이유로 취약합니다. 첫째, 스킬이 늘수록 컨텍스트 창을 잡아먹어 정작 과제에 쓸 여지가 줄어듭니다. 둘째, 프롬프트 템플릿은 상황이 조금만 달라져도 쉽게 깨집니다.

![병목: 과거 절차 유지율 0. 처음부터 다시 추론, 컨텍스트 창 고갈, 템플릿의 취약성]({{ '/assets/images/agent-procedural-memory-beyond-retrieval-slide-02.webp' | relative_url }})

최근 에이전트 메모리 연구는 이 문제를 **절차적 메모리(procedural memory)** 라는 렌즈로 다시 봅니다. 사람의 절차적 기억이 자전거 타기처럼 의식하지 않아도 실행되는 숙련된 동작을 담듯이, 에이전트의 절차적 메모리는 반복 과제의 실행 절차를 재사용 가능한 형태로 압축합니다. 핵심 흐름은 절차적 지식을 **프롬프트 검색을 넘어** 별도의 저장·검색·갱신 구조로, 나아가 모델 파라미터 안의 신경 정책으로 옮기는 것입니다.

이 글은 이 전환의 지형을 검증된 논문 중심으로 정리합니다. ThakiCloud의 Agent-Native Cloud인 Paxis가 스킬을 일급 리소스로 다루는 방식이 바로 이 연구 흐름의 실무 구현에 해당하므로, 마지막에 그 연결을 짚습니다.

## 절차적 메모리란 무엇인가

인지 관점에서 메모리는 흔히 세 가지로 나뉩니다. 사실을 담는 의미 기억(semantic), 사건을 담는 일화 기억(episodic), 그리고 방법을 담는 절차 기억(procedural)입니다. 에이전트 문헌에서 절차적 메모리는 "어떻게 하는가"를 담당합니다. 복잡한 동작 시퀀스를 재사용 가능한 패턴으로 추상화해, 매번 밑바닥부터 계획하지 않고도 실행하게 합니다.

문제는 현재 대부분의 에이전트에서 이 절차적 지식이 세 형태 중 하나로 존재한다는 점입니다. 사람이 손으로 짠 것, 깨지기 쉬운 프롬프트 템플릿에 담긴 것, 아니면 모델 파라미터에 암묵적으로 얽혀 갱신하기 비싼 것입니다. 연구가 겨냥하는 지점은 이 지식을 **학습 가능하고 갱신 가능한 일급 대상**으로 끌어올리는 것입니다.

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
<div class="d3-arch" data-arch-root id="ralmemorybeyondretrieval-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 351, "height": 916, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 58, "y": 24, "w": 120, "h": 46, "title": "과거 실행 궤적"}, {"id": "B", "x": 58, "y": 148, "w": 120, "h": 62, "title": ["절차 추출", "빌드 Build"]}, {"id": "C", "x": 103, "y": 288, "w": 138, "h": 52, "title": "저장 형태"}, {"id": "D", "x": 199, "y": 418, "w": 120, "h": 62, "title": ["비파라메트릭", "텍스트 스크립트"]}, {"id": "E", "x": 24, "y": 418, "w": 120, "h": 62, "title": ["파라메트릭", "신경 정책"]}, {"id": "F", "x": 112, "y": 558, "w": 120, "h": 62, "title": ["검색·선택", "Retrieval"]}, {"id": "G", "x": 112, "y": 698, "w": 120, "h": 46, "title": "과제 실행"}, {"id": "H", "x": 51, "y": 822, "w": 135, "h": 62, "title": ["피드백으로 갱신", "추가·수정·삭제 Update"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [118, 70, 118, 148]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[142, 210], [172, 249], [172, 249], [172, 288]]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[207, 340], [259, 379], [259, 379], [259, 418]]}, {"src": "C", "dst": "E", "kind": "data", "curve": [[137, 340], [84, 379], [84, 379], [84, 418]]}, {"src": "D", "dst": "F", "kind": "data", "curve": [[259, 480], [259, 519], [259, 519], [210, 558]]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[84, 480], [84, 519], [84, 519], [133, 558]]}, {"src": "F", "dst": "G", "kind": "data", "line": [172, 620, 172, 698]}, {"src": "G", "dst": "H", "kind": "data", "curve": [[172, 744], [172, 783], [172, 783], [142, 822]]}, {"src": "H", "dst": "B", "kind": "data", "curve": [[58, 822], [-18, 659], [-18, 379], [58, 210]]}]});
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
      const container = document.getElementById('ralmemorybeyondretrieval-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ralmemorybeyondretrieval-1';
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

## 프롬프트 검색을 넘어서: 저장·검색·갱신의 분리

이 흐름을 정면으로 다룬 대표 연구가 **Memp: Exploring Agent Procedural Memory**(arXiv 2508.06433)입니다. Memp는 절차적 메모리를 일급 최적화 대상으로 놓고, 과거 궤적을 두 층위로 증류합니다. 하나는 세밀한 단계별 지시이고, 다른 하나는 상위 수준의 스크립트 같은 절차입니다. 그리고 메모리 루프를 **빌드(build)·검색(retrieval)·갱신(update)** 세 국면으로 분리합니다. 갱신 국면에서는 실행 피드백에 따라 항목을 추가·수정·삭제합니다.

![분리된 메모리 루프(Memp 아키텍처): 빌드, 검색, 갱신 세 국면의 분리]({{ '/assets/images/agent-procedural-memory-beyond-retrieval-slide-05.webp' | relative_url }})

이 분리가 중요한 이유는, 프롬프트에 스킬을 밀어 넣는 방식과 근본적으로 다르기 때문입니다. 프롬프트 방식에서는 저장과 검색이 하나로 뭉개져 있고 갱신이라는 개념 자체가 희박합니다. 반면 세 국면을 분리하면 절차를 언제 어떻게 넣고 뺄지, 실패에서 무엇을 고칠지가 명시적인 설계 대상이 됩니다. 자료에 따르면 이 흐름의 큰 방향은 **명시적 비파라메트릭 템플릿에서 암묵적 파라메트릭 신경 정책으로**의 이동으로 요약됩니다(Foundation Agents 메모리 서베이, arXiv 2602.06052). 즉 절차를 텍스트로 저장해 검색하는 단계를 넘어, 경험을 모델의 정책 자체에 녹여 넣는 방향입니다.

## 왜 지금 중요한가: 평가의 어려움

절차적 메모리가 실제로 쓸 만한 스킬을 만들어 내는지는 아직 충분히 이해되지 않았습니다. 이 공백을 겨냥한 연구가 **Managing Procedural Memory in LLM Agents**(arXiv 2606.23127)입니다. 이 논문은 **AFTER**라는 벤치마크를 제안합니다. 6개 직무 역할에 걸친 382개의 현실적인 기업 과제와 22개의 절차적 스킬로 구성되어, 스킬이 과제·역할·모델 백본을 가로질러 얼마나 전이되는지를 측정합니다.

![전이 가능성 측정 AFTER 벤치마크: 현실 기업 과제 382개, 절차적 스킬 22개, 직무 역할 6개]({{ '/assets/images/agent-procedural-memory-beyond-retrieval-slide-06.webp' | relative_url }})

이 벤치마크가 던지는 질문이 핵심입니다. 한 상황에서 학습한 절차가 다른 상황에서도 통하는가? 모델을 바꿔도 스킬이 유효한가? 절차적 메모리를 도입하는 순간 우리는 "이 스킬이 실제로 재사용 가능한가"를 측정할 수단이 필요해집니다. 저장·검색·갱신 구조를 갖췄더라도, 전이가 안 되는 스킬은 결국 비싼 프롬프트 템플릿과 다를 바 없기 때문입니다.

## ThakiCloud 제품 적용 시사점

이 연구 흐름은 ThakiCloud의 **Paxis**에서 그대로 실무 형태를 갖춥니다. Paxis는 Agent-Native Cloud로 **스킬·도구·정책·감사 로그를 일급 리소스**로 다룹니다. 여기서 스킬 하니스는 사실상 프로덕션 절차적 메모리입니다.

![프로덕션 적용 Paxis Agent-Native Cloud: 960+ 스킬 하니스, 격리 샌드박스와 BM25, ai-platform 서빙, 거버넌스와 감사]({{ '/assets/images/agent-procedural-memory-beyond-retrieval-slide-07.webp' | relative_url }})

- **빌드·검색·갱신의 실무 대응**: Paxis의 스킬 하니스는 960개 이상의 스킬을 BM25로 선택(검색)하고, 격리 샌드박스에서 실행하며, 자가진화 루프로 스킬을 개선(갱신)합니다. Memp가 제시한 세 국면 분리가 운영 시스템의 형태로 구현된 셈입니다.
- **프롬프트 검색을 넘어선 구조**: 스킬을 매번 프롬프트에 밀어 넣는 대신 검증된 스킬을 선택적으로 불러 쓰므로, 컨텍스트 예산을 아끼면서 절차의 일관성을 유지합니다. 이는 이 글이 다룬 "프롬프트 검색을 넘어서"라는 방향과 정확히 일치합니다.
- **평가와 감사**: AFTER 벤치마크가 강조한 "전이 가능성"을 Paxis는 정책 게이트와 감사 로그로 관리합니다. 어떤 스킬이 언제 선택되어 무엇을 했는지가 추적되므로, 재사용 가능한 절차와 그렇지 않은 절차를 데이터로 구분할 근거가 남습니다.

인프라 관점에서는 ai-platform이 이 스킬 실행을 떠받칩니다. Kueue GPU 스케줄링과 멀티테넌트 서빙 위에서 에이전트가 스킬을 실행하므로, 절차적 메모리의 실행 비용이 곧 서빙 효율 문제로 이어집니다. 저비용 서빙(ai-platform)이 에이전트 경제성(Paxis)을 떠받치는 구조입니다.

## 한계 및 반론

절차적 메모리를 파라메트릭 신경 정책으로 옮기는 방향에는 분명한 대가가 따릅니다. 텍스트 스크립트는 사람이 읽고 고칠 수 있지만, 파라미터에 녹아든 절차는 감사와 갱신이 어렵습니다. 무엇이 저장되었는지 들여다보기 힘들고, 잘못된 절차를 골라내 삭제하기도 까다롭습니다. 규제·소버린 환경처럼 설명 가능성이 중요한 곳에서는 이 불투명성이 곧바로 위험이 됩니다.

![한계와 향후 과제: 파라메트릭 메모리의 불투명성, 검색 품질 저하, 도메인 간 전이의 불확실성]({{ '/assets/images/agent-procedural-memory-beyond-retrieval-slide-08.webp' | relative_url }})

또한 비파라메트릭 검색 방식도 만능은 아닙니다. 검색은 여전히 잘못된 절차를 불러올 수 있고, 저장소가 커질수록 선택 품질이 떨어질 수 있습니다. AFTER 같은 벤치마크가 보여주듯 스킬의 전이 가능성은 아직 검증 초기 단계이며, 한 도메인에서 통한 절차가 다른 도메인에서 통한다는 보장은 없습니다. 절차적 메모리는 에이전트를 매번 백지에서 시작하지 않게 하는 유망한 방향이지만, 저장 형태·검색 품질·갱신 안전성·평가 방법이 함께 성숙해야 실무에서 신뢰할 수 있는 자산이 됩니다.

## 출처

- [Memp: Exploring Agent Procedural Memory (arXiv 2508.06433)](https://arxiv.org/abs/2508.06433)
- [Managing Procedural Memory in LLM Agents: Control, Adaptation, and Evaluation (arXiv 2606.23127)](https://arxiv.org/abs/2606.23127)
- [Rethinking Memory Mechanisms of Foundation Agents in the Second Half: A Survey (arXiv 2602.06052)](https://arxiv.org/abs/2602.06052)
