---
title: "에이전트의 기억을 영구화하는 법: 그래프 엔지니어링 5단계"
excerpt: "에이전트의 기억은 컨텍스트 창과 함께 죽습니다. 지식 그래프를 공유 메모리로 두면 그 기억이 영구화됩니다. 커뮤니티에서 정리된 Extract·Resolve·Assemble·Query·Repeat 5단계를 뜯어보고, 멀티에이전트 시스템에 어떻게 붙이는지 짚습니다."
seo_title: "그래프 엔지니어링: 멀티에이전트의 영구 기억 설계 - Thaki Cloud"
seo_description: "에이전트 메모리가 컨텍스트 창과 함께 사라지는 문제를, 지식 그래프 공유 메모리로 해결하는 그래프 엔지니어링 5단계(Extract·Resolve·Assemble·Query·Repeat)를 실무 관점에서 분석합니다. Haiku·Sonnet 모델 라우팅과 provenance, ThakiCloud Paxis 적용까지."
date: 2026-07-25
last_modified_at: 2026-07-25
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "diagram-project"
tags:
  - agentops
  - knowledge-graph
  - multi-agent
  - agent-memory
  - graph-engineering
  - rag
  - ai-application
  - thakicloud
categories:
  - agentops
header:
  teaser: /assets/images/graph-engineering-multi-agent-memory-hero.webp
audiobook: /assets/audio/posts/graph-engineering-multi-agent-memory/audiobook-ko.mp3
audiobook_note: "AI 로컬 합성 오디오북 (Qwen3-TTS)"
canonical_url: "https://thakicloud.com/tech-blog/ko/agentops/graph-engineering-multi-agent-memory/"
---

![언어 조각이 영구적인 노드와 엣지 네트워크로 응결되는 추상 일러스트]({{ '/assets/images/graph-engineering-multi-agent-memory-hero.webp' | relative_url }})

## 왜 읽어야 하나

멀티에이전트 시스템이나 오래 도는 에이전트 제품을 만드는 엔지니어라면, 이 글은 "모델을 더 큰 걸로 바꿔야 하나"라는 질문을 잠시 내려놓게 해드립니다. 핵심 결론부터 말씀드리면 이렇습니다. **에이전트의 기억은 컨텍스트 창과 함께 죽고, 지식 그래프를 공유 메모리로 두어야 그 기억이 영구화됩니다.** 최근 멀티에이전트 시스템을 위한 그래프 엔지니어링을 정리한 글이 공유되었는데, 그 뼈대인 다섯 단계(Extract, Resolve, Assemble, Query, Repeat)가 왜 지금 중요한지, 그리고 실제 시스템에 어떻게 붙이는지를 이 글에서 풀어드립니다.

## 개요

에이전트를 오래 돌려보신 분은 같은 벽에 부딪힙니다. 어제 워커가 알아낸 사실을 오늘 워커가 모릅니다. 대화가 길어지면 앞부분이 컨텍스트 창 밖으로 밀려나고, 그 순간 에이전트는 방금까지 알던 것을 잊습니다. 기억이 세션 단위로 증발하는 구조입니다.

흔한 처방은 벡터 RAG입니다. 문서를 임베딩해서 유사한 조각을 다시 불러오는 방식입니다. 이것으로 "비슷한 내용 찾기"는 되지만, "누가 무엇을 했고 그것이 무엇과 연결되는지"는 여전히 흐릿합니다. 같은 인물이 문서마다 다른 이름으로 등장하면 벡터는 그 둘을 하나로 묶지 못합니다. 관계를 따라 두세 다리 건너 추론하는 일도 임베딩 유사도만으로는 안정적이지 않습니다.

그래프 엔지니어링은 여기서 다른 답을 냅니다. 정보를 통째로 저장하는 대신, 개체와 개체 사이의 **관계를 명시적인 그래프**로 남깁니다. 그러면 에이전트의 기억이 문장 덩어리가 아니라 조회 가능한 구조가 됩니다.

## 이 기술은 무엇인가

핵심 아이디어는 단순합니다. 에이전트가 읽고 겪은 것을 **주어-서술어-목적어(S-P-O) 삼중항**으로 뽑아 지식 그래프에 쌓고, 필요할 때 그 그래프의 일부를 잘라내어 질의합니다. 노드는 개체이고, 엣지는 타입이 붙은 관계이며, 모든 삼중항에는 어디서 나왔는지를 가리키는 출처(provenance)가 함께 붙습니다.

컨텍스트 창이 "지금 이 순간 볼 수 있는 것"이라면, 지식 그래프는 "지금까지 확정된 것"입니다. 전자는 세션이 끝나면 사라지고, 후자는 남습니다. 이 분리가 그래프 엔지니어링의 전부라고 해도 지나치지 않습니다.

아래는 다섯 단계가 도는 순환 구조입니다.

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
<div class="d3-arch" data-arch-root id="ineeringmultiagentmemory-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 348, "height": 940, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "Doc", "x": 95, "y": 24, "w": 128, "h": 46, "title": "새 문서 / 에이전트 관찰"}, {"id": "Extract", "x": 64, "y": 148, "w": 191, "h": 62, "title": ["1. Extract", "Haiku가 개체와 S-P-O 삼중항 추출"]}, {"id": "Resolve", "x": 135, "y": 288, "w": 177, "h": 62, "title": ["2. Resolve", "Sonnet이 같은 개체를 하나로 병합"]}, {"id": "Assemble", "x": 132, "y": 442, "w": 184, "h": 62, "title": ["3. Assemble", "정규 노드 + 타입 엣지 + 출처로 조립"]}, {"id": "Graph", "x": 99, "y": 582, "w": 120, "h": 62, "title": ["지식 그래프", "공유 메모리"]}, {"id": "Query", "x": 74, "y": 722, "w": 170, "h": 62, "title": ["4. Query", "서브그래프를 잘라 Sonnet이 추론"]}, {"id": "Answer", "x": 99, "y": 862, "w": 120, "h": 46, "title": "엣지를 인용한 답변"}], "edges": [{"src": "Doc", "dst": "Extract", "kind": "data", "line": [159, 70, 159, 148]}, {"src": "Extract", "dst": "Resolve", "kind": "data", "curve": [[188, 210], [224, 249], [224, 249], [224, 288]]}, {"src": "Resolve", "dst": "Assemble", "kind": "data", "line": [224, 350, 224, 442]}, {"src": "Assemble", "dst": "Graph", "kind": "data", "curve": [[224, 504], [224, 543], [224, 543], [188, 582]]}, {"src": "Graph", "dst": "Query", "kind": "data", "line": [159, 644, 159, 722]}, {"src": "Query", "dst": "Answer", "kind": "data", "line": [159, 784, 159, 862]}, {"src": "Graph", "dst": "Extract", "kind": "event", "label": "5. Repeat: 새 정보로 계속 갱신", "curve": [[130, 582], [94, 473], [94, 319], [130, 210]], "off": "50%"}]});
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
      const container = document.getElementById('ineeringmultiagentmemory-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ineeringmultiagentmemory-1';
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

## 다섯 단계 자세히 보기

**1. Extract.** 문서 하나가 들어오면 값싼 모델(Haiku)이 개체와 S-P-O 삼중항을 뽑습니다. 문서당 한 번의 호출이면 충분합니다. 여기서 흥미로운 지점은 별도의 학습 데이터가 필요 없다는 것입니다. 무엇을 어떤 모양으로 뽑을지는 **Pydantic 스키마 하나**가 정의합니다. 스키마가 곧 유일한 학습 신호 역할을 합니다. 출력 형식을 코드가 소유하고 모델은 내용만 채우는 구조라, 결과가 흔들리지 않습니다.

**2. Resolve.** 추출된 개체 중 같은 대상을 가리키는 것들을 하나로 묶습니다. 이 단계는 조금 더 똑똑한 모델(Sonnet)이 맡습니다. 예를 들어 "Edwin Aldrin"과 "Buzz Aldrin"은 글자가 하나도 겹치지 않지만 같은 사람입니다. 문자열 매칭으로는 절대 못 잡습니다. 개체마다 붙은 설명을 문맥으로 삼아 모델이 "이 둘은 같다"를 판단합니다. 개체 해소(entity resolution)의 품질이 그래프 전체의 신뢰도를 좌우하는 자리입니다.

**3. Assemble.** 병합된 개체를 정규 노드로 만들고, 타입이 붙은 엣지로 연결하며, 모든 삼중항에 출처를 박아 하나의 연결된 그래프로 조립합니다. 출처가 붙어 있다는 점이 중요합니다. 나중에 "이 사실은 어느 문서에서 나왔는가"를 되짚을 수 있어야, 틀린 정보를 추적하고 걷어낼 수 있습니다.

**4. Query.** 질문이 오면 관련된 서브그래프를 직렬화해서 모델(Sonnet)에게 넘기고, 모델은 삼중항 위에서 추론합니다. 이때 모든 답변은 **특정 엣지를 인용**합니다. "왜 그렇게 답했는가"가 그래프의 어느 관계에 근거하는지 드러나므로, 답변이 검증 가능해집니다.

**5. Repeat.** 새 문서나 새 관찰이 들어오면 다시 1단계로 돌아갑니다. 그래프는 한 번 만들고 끝나는 산출물이 아니라, 계속 갱신되는 살아 있는 메모리입니다.

모델 라우팅이 단계마다 다르다는 점을 눈여겨보시면 좋습니다. 대량 추출은 값싼 Haiku가, 판단이 필요한 개체 해소와 질의 추론은 Sonnet이 맡습니다. 비싼 모델을 전 단계에 바르지 않고, 판단이 필요한 곳에만 씁니다. 이것은 저희가 사내 배치 작업에서 지키는 원칙과 정확히 같습니다. 워커는 싸게, 게이트만 비싸게 둡니다.

## 멀티에이전트에 어떻게 붙나

지식 그래프의 진짜 값어치는 여러 에이전트가 **같은 메모리를 공유**할 때 드러납니다. 워커 에이전트는 알아낸 것을 그래프에 씁니다. 평가 에이전트는 워커의 주장을 그래프에 비추어 사실 확인합니다. 그리고 밤새 도는 루프는 이 그래프를 통해 어제의 진척을 오늘로 이어받습니다.

이 그림은 저희가 여러 자동화 루프를 운영하며 얻은 교훈과 겹칩니다. 팬아웃한 서브에이전트의 결과는 반드시 검증 스테이지로 닫아야 하는데, 그 검증의 기준점이 될 공유 사실 저장소가 없으면 각 에이전트가 백지에서 다시 시작합니다. 그래프는 그 기준점 역할을 합니다. 워커가 쓰고, 평가자가 대조하고, 다음 루프가 물려받는 구조가 자연스럽게 만들어집니다.

## ThakiCloud 제품 적용 시사점

이 기법은 저희 **Paxis**에 특히 잘 맞습니다. Paxis는 ai-platform 위에서 도는 Agent-Native Cloud 제어 평면으로, Skills와 Tools, Policies, Audit Logs를 일급 리소스로 다룹니다. 그래프 엔지니어링의 다섯 단계는 Paxis의 몇몇 축과 그대로 대응됩니다.

먼저 지식 축입니다. Paxis의 위키 지식 엔진은 문서와 개체를 연결된 지식으로 다루는데, 여기에 S-P-O 삼중항과 개체 해소를 얹으면 에이전트가 조회할 수 있는 공유 메모리가 됩니다. 다음으로 오케스트레이션 축입니다. DAG 멀티에이전트가 팬아웃할 때, 각 워커가 그래프에 쓰고 평가자가 그래프로 대조하면 검증 루프가 데이터로 닫힙니다. 마지막으로 감사 축입니다. 모든 삼중항에 출처를 박는 provenance는 Paxis의 정책 게이트와 감사 로그 철학과 정확히 같은 방향입니다. 답변이 어느 근거에서 나왔는지 추적 가능하다는 것은, 규제와 온프렘 요구가 강한 환경에서 그 자체로 경쟁력입니다.

인프라 관점에서는 저희 **ai-platform** 렌즈도 붙습니다. 추출은 값싼 모델을 대량으로 호출하고 질의는 더 큰 모델을 선택적으로 호출하는 구조라, 모델 티어별로 서빙을 나누어 K8s 위에서 돌리기에 알맞습니다. Kueue로 배치 추출 작업을 스케줄링하고 vLLM으로 소형 모델을 값싸게 서빙하면, 그래프를 계속 갱신하는 비용을 통제할 수 있습니다. 저비용 서빙(ai-platform)이 그래프 유지 비용을 낮추고, 그것이 다시 에이전트의 경제성(Paxis)을 만듭니다.

## 한계 및 반론

그래프 엔지니어링이 만능은 아닙니다. 가장 아픈 지점은 개체 해소가 틀렸을 때입니다. 서로 다른 두 개체를 하나로 잘못 병합하면, 그 오류가 그래프 전체로 번져 이후 모든 질의를 오염시킵니다. 반대로 같은 개체를 갈라 두면 기억이 조각납니다. 이 단계에 모델 판단이 들어가는 이상, 완벽한 자동화는 어렵고 주기적인 감사가 필요합니다.

추출 단계의 환각도 문제입니다. 모델이 문서에 없는 삼중항을 지어내면, 출처가 붙어 있어도 그 출처 안에 실제로 그 관계가 있는지는 별도로 확인해야 합니다. 스키마가 형식은 강제하지만 내용의 진위까지 보장하지는 않습니다.

규모가 커지면 그래프가 비대해지고 질의 지연이 늘어납니다. 관련 서브그래프를 잘라내는 일 자체가 또 하나의 검색 문제가 되며, 잘라낸 조각이 너무 크면 다시 컨텍스트 창 한계로 돌아옵니다. 그리고 애초에 관계 추론이 필요 없는 단순한 조회라면, 무거운 그래프보다 평범한 벡터 RAG가 더 싸고 빠릅니다. 문제의 성격이 "비슷한 것 찾기"인지 "관계 따라가기"인지를 먼저 가르는 것이 순서입니다.

## 정리

에이전트에게 영구 기억을 주는 일은 더 큰 모델을 사는 것으로 해결되지 않습니다. 기억이 컨텍스트 창과 함께 죽는 구조를 바꾸어야 하고, 지식 그래프를 공유 메모리로 두는 것이 지금까지 나온 가장 실용적인 답입니다. Extract로 뽑고, Resolve로 묶고, Assemble로 조립하고, Query로 근거와 함께 답하고, Repeat로 갱신하는 다섯 단계가 그 방법입니다.

시작은 거창하지 않아도 됩니다. 여러분의 도메인에서 가장 중요한 개체와 관계 몇 가지를 정의한 **작은 Pydantic 스키마 하나**를 만들고, 값싼 모델로 문서 하나를 추출해 보십시오. 거기서부터 그래프가 자랍니다. 다음에 에이전트가 "그거 어제 알았는데 잊어버렸다"고 할 때, 답은 더 큰 모델이 아니라 더 나은 기억 구조라는 것을 기억하시면 됩니다.


## 관련 슬라이드

본문 내용을 NotebookLM(`blue_collage` 스타일)으로 요약한 슬라이드입니다.

![graph-engineering-multi-agent-memory 슬라이드 1](/assets/images/graph-engineering-multi-agent-memory-slide-01.webp)

![graph-engineering-multi-agent-memory 슬라이드 2](/assets/images/graph-engineering-multi-agent-memory-slide-02.webp)

![graph-engineering-multi-agent-memory 슬라이드 3](/assets/images/graph-engineering-multi-agent-memory-slide-03.webp)

![graph-engineering-multi-agent-memory 슬라이드 4](/assets/images/graph-engineering-multi-agent-memory-slide-04.webp)

## 출처

- [Codez (@0xCodez), "Graph Engineering for multi-agentic systems" (X)](https://x.com/0xCodez/status/2080250266851463209)
- [Anthropic Engineering, "How we built our multi-agent research system"](https://www.anthropic.com/engineering/multi-agent-research-system)

출처에 관해 한 가지 밝힙니다. 위 다섯 단계에 대해 저희가 직접 확인한 것은 위 X 게시물이며, 그 바탕이 된 문서의 저자와 분량은 확인하지 못했습니다. 같은 소재를 다룬 다른 소개 글은 저자를 다르게 적고 있어, 본문에서는 확인되지 않은 귀속을 쓰지 않았습니다.
