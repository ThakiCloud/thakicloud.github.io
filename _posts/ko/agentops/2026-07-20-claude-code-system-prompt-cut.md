---
title: "시스템 프롬프트를 80% 잘라낸 이유: 똑똑해진 모델은 얇은 하네스를 원합니다"
excerpt: "Anthropic이 Claude Code의 시스템 프롬프트를 80% 걷어냈다는 소식이 개발자 사이에서 화제가 됐습니다. 담당자는 새 모델이 '더 작은 시스템 프롬프트를 원하고', 오히려 우리가 준 지침보다 더 상상력이 풍부하다고 설명했습니다. 모델이 강해질수록 하네스는 얇아지고 규칙은 맥락으로 바뀐다는 이 흐름을, ThakiCloud가 Paxis 스킬 하네스와 룰 시스템을 운용하며 실제로 관찰한 내용과 함께 정리합니다."
seo_title: "Claude Code 시스템 프롬프트 80% 삭감: 얇은 하네스와 맥락 스티어링 - Thaki Cloud"
seo_description: "Anthropic이 Claude Code 시스템 프롬프트를 80% 줄인 사건을 분석합니다. 왜 똑똑한 모델은 얇은 프롬프트를 원하는지, 스캐폴딩 간섭 연구가 말하는 것, 하드 규칙에서 맥락 스티어링으로의 전환, 그리고 ThakiCloud Paxis의 얇은 하네스·두꺼운 스킬 설계에 주는 시사점을 정리했습니다."
date: 2026-07-20
last_modified_at: 2026-07-20
tags:
  - ai-coding
  - agentic
  - system-prompt
  - prompt-engineering
  - claude-code
  - claude-fable-5
  - agentops
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "robot"
canonical_url: "https://thakicloud.com/tech-blog/ko/agentops/claude-code-system-prompt-cut/"
categories:
  - agentops
audiobook: /assets/audio/posts/claude-code-system-prompt-cut/audiobook-ko.mp3
audiobook_note: "AI 로컬 합성 오디오북 (Qwen3-TTS)"
---

![두꺼운 시스템 프롬프트가 얇은 하네스로 얇아지는 흐름]({{ '/assets/images/claude-code-system-prompt-cut-hero.png' | relative_url }})

## 개요

최근 개발자 커뮤니티에서 짧은 소식 하나가 유독 많이 인용됐습니다. Anthropic이 Claude Code의 시스템 프롬프트를 약 80% 걷어냈다는 이야기입니다. 흥미로운 부분은 삭감 자체보다 그 이유였습니다. Anthropic의 Tariq Shihipar(@trq212)는 새 Fable 5 계열 모델이 "더 작은 시스템 프롬프트를 원한다"고 말했고, 지침과 예시를 많이 넣는 것이 오히려 모델의 발목을 잡을 수 있다고 설명했습니다. 모델이 우리가 적어 준 규칙보다 더 상상력이 풍부하기 때문이라는 것입니다.

이 문장은 단순한 제품 최적화 소식이 아닙니다. 지난 몇 년간 프롬프트 엔지니어링은 "빠뜨리지 말고 다 적어라"는 방향으로 진화해 왔습니다. 하지 말아야 할 것, 지켜야 할 형식, 예외 상황까지 시스템 프롬프트에 촘촘히 박아 넣는 것이 좋은 하네스라고 여겨졌습니다. 그런데 모델이 충분히 강해지면 그 촘촘함이 자산이 아니라 부채가 될 수 있다는 신호가 나온 것입니다.

ThakiCloud는 쿠버네티스 기반 AI/ML SaaS 플랫폼을 운영하면서, 그 위에서 도는 에이전트 제어 평면 Paxis를 통해 960개가 넘는 스킬과 수십 개의 상시 룰을 하네스로 관리합니다. 그래서 "시스템 프롬프트를 얼마나 넣을 것인가"는 우리에게 트렌드 문장이 아니라 매일 마주하는 설계 결정입니다. 이 글은 이번 삭감이 무엇을 뜻하는지, 왜 똑똑한 모델일수록 얇은 하네스를 원하는지, 그리고 그 원리를 실제 운영에 어떻게 옮길 수 있는지를 정리합니다.

## 무엇이 바뀌었나

보도된 내용의 핵심은 두 가지입니다. 첫째, Claude Code의 시스템 프롬프트 분량이 대폭 줄었다는 사실입니다. 둘째, 그 근거가 "모델이 약해서 더 채운다"가 아니라 "모델이 강해져서 덜 채운다"는 방향이라는 점입니다.

Anthropic 측 설명을 옮기면, 새 모델은 훈련 과정에서 행동 규범을 스스로 내재화하는 정도가 커졌습니다. 예전에는 배포 시점의 시스템 프롬프트에 일일이 풀어써야 했던 것들을, 이제는 모델이 가중치 안에 어느 정도 지니고 있다는 것입니다. 그 결과 시스템 프롬프트의 역할이 "모든 규칙을 담은 규정집"에서 "가벼운 맥락 설정자"로 옮겨간다는 해석이 뒤따랐습니다. 또한 딱딱한 금지문("이것을 하지 마라") 대신 맥락으로 방향을 잡아 주는 방식으로 모델을 스티어링한다는 언급도 있었습니다.

아래는 이 변화의 구조를 도식화한 것입니다. 왼쪽의 두꺼운 규정집 방식과, 오른쪽의 얇은 맥락 설정 방식이 각각 어디에 능력을 쌓는지가 다릅니다.

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
<div class="d3-arch" data-arch-root id="laudecodesystempromptcut-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 641, "height": 490, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [{"x": 24, "y": 24, "w": 195, "h": 434, "label": "예전: 두꺼운 시스템 프롬프트", "lx": 36, "ly": 42}, {"x": 414, "y": 24, "w": 195, "h": 434, "label": "지금: 얇은 하네스 + 맥락", "lx": 426, "ly": 42}], "nodes": [{"id": "A1", "x": 62, "y": 63, "w": 120, "h": 62, "title": ["모든 규칙·예외·형식을", "시스템 프롬프트에 명시"]}, {"id": "A2", "x": 62, "y": 217, "w": 120, "h": 62, "title": ["모델이 지침을", "그대로 따르길 기대"]}, {"id": "A3", "x": 62, "y": 357, "w": 120, "h": 62, "title": ["지침이 능력을", "제약할 수 있음"]}, {"id": "B1", "x": 452, "y": 63, "w": 120, "h": 62, "title": ["시스템 프롬프트는", "가벼운 맥락만 설정"]}, {"id": "B2", "x": 452, "y": 217, "w": 120, "h": 62, "title": ["모델이 내재화한", "판단을 활용"]}, {"id": "B3", "x": 452, "y": 357, "w": 120, "h": 62, "title": ["규칙은 필요할 때", "맥락으로 주입"]}, {"id": "OLD", "x": 257, "y": 71, "w": 120, "h": 46, "title": "OLD"}, {"id": "NEW", "x": 257, "y": 225, "w": 120, "h": 46, "title": "NEW"}], "edges": [{"src": "A1", "dst": "A2", "kind": "data", "line": [122, 125, 122, 217]}, {"src": "A2", "dst": "A3", "kind": "data", "line": [122, 279, 122, 357]}, {"src": "B1", "dst": "B2", "kind": "data", "line": [512, 125, 512, 217]}, {"src": "B2", "dst": "B3", "kind": "data", "line": [512, 279, 512, 357]}, {"src": "OLD", "dst": "NEW", "kind": "event", "label": "모델이 강해지면서 이동", "line": [317, 117, 317, 225], "lx": 317, "ly": 167}]});
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
      const container = document.getElementById('laudecodesystempromptcut-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'laudecodesystempromptcut-1';
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

여기서 조심해야 할 부분이 있습니다. "시스템 프롬프트를 줄여라"가 곧 "지침을 없애라"는 뜻은 아닙니다. 줄어든 것은 배포 시점에 항상 얹혀 있던 상시 하네스이고, 도메인 지식과 판단 근거는 여전히 어딘가에 있어야 합니다. 바뀐 것은 그 지식을 어디에 두느냐입니다.

## 왜 똑똑한 모델은 얇은 프롬프트를 원하나

이 현상은 감으로만 도는 이야기가 아닙니다. 에이전트 스캐폴딩(하네스)이 많아질수록 성능이 좋아지지 않고 오히려 서로 간섭한다는 연구들이 나오고 있습니다. 예를 들어 "More Is Not Always Better: Cross-Component Interference in LLM Agent Scaffolding"(arXiv 2605.05716)은 하네스 구성 요소를 더 넣을수록 요소끼리 간섭이 생겨 전체 성능이 꺾이는 지점을 다룹니다. 지침을 더 넣는 것이 단조 증가하는 이득이 아니라는 관찰입니다.

직관적으로 풀어 보면 이렇습니다. 시스템 프롬프트에 규칙을 하나 넣을 때마다 모델은 그 규칙을 매 순간 지켜야 할 제약으로 인식합니다. 규칙이 적을 때는 이 제약이 유용한 가드레일이지만, 규칙이 수십 개로 늘어나면 서로 충돌하거나 현재 작업과 무관한 지침이 판단을 흐립니다. 약한 모델은 명시적 지침이 없으면 헤매므로 이 비용을 감수할 가치가 있었습니다. 그러나 강한 모델은 상황을 스스로 읽어 내는 능력이 커졌기 때문에, 불필요한 지침이 주는 간섭 비용이 지침이 주는 이득을 넘어서기 시작합니다.

바로 이 지점에서 "모델이 우리가 준 지침보다 더 상상력이 풍부하다"는 표현이 이해됩니다. 촘촘한 규칙은 최악의 출력을 막는 하한선을 세우지만, 동시에 최선의 출력을 누르는 천장이 되기도 합니다. 모델이 그 천장보다 높이 올라갈 수 있게 되면, 규칙을 걷어내는 것이 곧 성능을 여는 일이 됩니다.

다만 이 논리는 무조건적이지 않습니다. 하한선을 걷어내면 평균은 오를 수 있어도 분산이 커집니다. 즉 가끔 나오는 나쁜 출력을 막아 주던 가드레일이 사라집니다. 그래서 실무에서는 "무엇을 걷어낼 것인가"가 "얼마나 걷어낼 것인가"보다 중요합니다.

## 규칙에서 맥락으로

이번 소식에서 가장 실무적으로 유용한 대목은 "딱딱한 금지문 대신 맥락으로 스티어링한다"는 부분입니다. 같은 의도를 전달하는 두 가지 방식이 있습니다.

첫째는 하드 규칙입니다. "전문 용어를 쓰지 마라", "이 형식을 반드시 지켜라"처럼 금지와 강제로 표현합니다. 이 방식은 명확하지만 상시 하네스로 쌓이면 앞서 말한 간섭을 만듭니다. 둘째는 맥락 설정입니다. "이 글은 열여섯 살이 읽을 수준으로 쉽게 풀어 씁니다"처럼 원하는 결과의 상태를 서술합니다. 강한 모델에게는 후자가 더 안정적으로 작동하는 경우가 많습니다. 부정형 지시를 이해하지 못해서가 아니라, 긍정적으로 서술된 목표가 모델이 스스로 세부를 채울 여지를 주기 때문입니다.

여기서 중요한 구분이 하나 생깁니다. 모든 지식을 시스템 프롬프트에서 빼는 것이 아니라, 상시 하네스와 온디맨드 지식을 분리하는 것입니다. 매 순간 필요한 최소한만 상시로 두고, 특정 작업에서만 필요한 지식은 그 작업이 시작될 때 맥락으로 불러옵니다. 이렇게 하면 상시 하네스는 얇게 유지되고, 도메인 지식은 필요한 순간에 두껍게 공급됩니다.

단, 형식의 일관성처럼 흔들리면 안 되는 것은 여전히 결정론적 코드가 소유해야 합니다. 모델에게 "매번 같은 JSON 형식으로 답하라"고 부탁하는 대신, 출력 형식과 집계는 코드가 강제하고 모델은 내용만 생성하게 하는 편이 안전합니다. 프롬프트를 얇게 만드는 흐름과 형식을 코드로 고정하는 원칙은 충돌하지 않습니다. 오히려 서로를 보완합니다. 흔들리면 안 되는 것은 코드로 내리고, 판단이 필요한 것은 모델에게 맡기며, 상시 하네스에서는 둘 다 덜어 냅니다.

## ThakiCloud 제품 적용 시사점

이 흐름은 ThakiCloud의 에이전트 플랫폼 Paxis 설계 철학과 정확히 맞닿아 있습니다. Paxis는 ai-platform 위에서 도는 Agent-Native Cloud 제어 평면으로, 스킬(Skills)·도구(Tools)·정책(Policies)·감사 로그(Audit Logs)를 일급 리소스로 다룹니다. 핵심 설계 원칙 중 하나가 바로 "얇은 하네스, 두꺼운 스킬"입니다. 모델 루프와 권한, 보안 같은 하네스는 최소로 유지하고, 도메인 지식과 판단과 실패 사례는 스킬 쪽에 두껍게 쌓습니다.

Paxis의 스킬 하네스는 960개가 넘는 스킬을 상시 시스템 프롬프트에 모두 얹지 않습니다. 대신 요청이 들어오면 BM25 검색으로 관련 스킬만 골라 그 순간에 맥락으로 불러옵니다. 이것이 정확히 이번 소식이 말하는 "가벼운 맥락 설정자"의 구현입니다. 상시로 지불하는 하네스 비용은 얇게 유지하면서, 특정 작업에서만 두꺼운 지식을 공급하는 구조입니다. 스킬 하나를 인덱스에 올리는 순간부터 그 이름과 설명은 매 세션 토큰 비용을 발생시키므로, 우리는 "이게 없으면 에이전트가 틀리는가"라는 기준으로 각 문장의 상시 탑재 여부를 판정합니다.

맥락 스티어링 원칙도 우리 운영과 연결됩니다. Paxis의 정책 게이트와 감사 로그는 흔들리면 안 되는 규칙을 결정론적 코드로 강제합니다. 반면 콘텐츠 품질이나 판단이 필요한 영역은 모델에게 맡기되, 얇은 룰로 방향만 잡아 줍니다. 상시 룰은 매 턴 토큰을 지불하기 때문에, 항상 필요한 규칙만 상시로 두고 가끔 필요한 것은 스킬로 내려 온디맨드로 로드합니다. Anthropic이 시스템 프롬프트에서 배운 교훈을, 우리는 스킬과 룰의 경계를 긋는 일에서 매일 적용하고 있는 셈입니다.

인프라 관점에서도 함의가 있습니다. 시스템 프롬프트가 얇아지면 입력 토큰이 줄고, 이는 서빙 비용과 지연에 직접 영향을 줍니다. ai-platform이 vLLM으로 모델을 서빙하고 멀티테넌트로 운용하는 환경에서, 상시 하네스를 줄이는 것은 단순한 품질 문제가 아니라 경제성 문제이기도 합니다. 낮은 서빙 비용이 에이전트를 더 많이, 더 자주 돌릴 수 있는 여력을 만들고, 그 여력이 다시 에이전트 경제성을 만듭니다.

## 한계 및 반론

이 흐름을 그대로 일반화하는 데는 주의가 필요합니다. 몇 가지 반론을 정직하게 짚습니다.

첫째, "얇게 만들수록 좋다"는 결론은 위험합니다. 프롬프트 삭감이 성능을 여는 것은 모델이 충분히 강할 때의 이야기이며, 그 임계는 모델과 작업마다 다릅니다. 약한 모델이나 고위험 작업에서 하네스를 성급히 걷어내면 하한선이 사라져 나쁜 출력이 늘어납니다. 실제로 우리 운영에서도 저비용 모델이 콘텐츠 품질에서 흔들릴 때는 형식을 코드로 더 강하게 고정하는 방향으로 대응합니다.

둘째, 이번 소식의 구체 수치는 Anthropic 담당자의 공개 발언과 이를 정리한 매체 보도에 기반한 것으로, 삭감 전후의 정확한 프롬프트 길이나 벤치마크 수치가 공개된 것은 아닙니다. "80%"라는 숫자는 발표된 표현이지만, 그 성능 효과를 우리가 독립적으로 재현해 측정한 것은 아니라는 점을 분명히 해 둡니다.

셋째, 프롬프트를 걷어낸 자리를 무엇이 채우는지가 관건입니다. 지침을 시스템 프롬프트에서 뺀다고 지식이 사라지지는 않습니다. 그 지식은 모델의 가중치, 온디맨드로 불러오는 스킬, 또는 결정론적 코드 게이트 중 어딘가로 옮겨가야 합니다. 옮길 곳을 마련하지 않고 그냥 지우기만 하면, 얇아진 하네스는 곧 통제되지 않는 출력으로 돌아옵니다. 결국 이것은 "적게 쓰기" 경쟁이 아니라 "무엇을 어디에 둘 것인가"라는 설계 문제입니다.

정리하면, 이번 삭감은 프롬프트 엔지니어링의 무게 중심이 옮겨가고 있음을 보여 주는 하나의 지표입니다. 모델이 강해질수록 상시 하네스는 얇아지고, 규칙은 맥락과 코드로 나뉘어 재배치됩니다. ThakiCloud는 이 원칙을 Paxis의 얇은 하네스와 두꺼운 스킬로 이미 운용하고 있으며, 이번 소식은 그 방향이 우리만의 취향이 아니라 업계가 함께 향하는 흐름임을 확인시켜 줍니다.

## 출처

- Anthropic, Tariq Shihipar(@trq212) 공개 발언 정리 보도, [the-decoder.com](https://the-decoder.com/anthropic-says-it-cut-80-percent-of-claude-codes-system-prompt-because-fable-5-models-want-a-smaller-system-prompt/)
- ["Anthropic Slashes Claude Code System Prompt by 80%", ClaudeAINews](https://www.claudeainews.com/news/anthropic-cuts-claude-code-system-prompt-80-percent)
- ["More Is Not Always Better: Cross-Component Interference in LLM Agent Scaffolding", arXiv 2605.05716](https://arxiv.org/abs/2605.05716)
