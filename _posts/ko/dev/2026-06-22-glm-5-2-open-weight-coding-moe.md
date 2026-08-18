---
title: "GPT-5.5를 1/6 비용으로 따라잡은 오픈웨이트: GLM-5.2를 자체 호스팅 관점에서 뜯어봤습니다"
excerpt: "Z.ai가 MIT 라이선스로 공개한 744B MoE 코딩 모델 GLM-5.2가 SWE-bench Pro와 Terminal-Bench에서 GPT-5.5를 앞섰고, 비용은 약 1/6이라는 보도가 나왔습니다. Vercel CEO까지 감탄한 이 모델을 벤치마크 사실 확인, vLLM·SGLang 자체 호스팅 요구사항, 그리고 ThakiCloud의 온프렘·소버린 AI 서빙 관점에서 분석합니다."
seo_title: "GLM-5.2 오픈웨이트 코딩 모델 자체 호스팅 분석 - Thaki Cloud"
seo_description: "Z.ai GLM-5.2(744B MoE, MIT, 1M 컨텍스트)의 SWE-bench Pro 62.1·Terminal-Bench 81.0 벤치마크를 사실 확인하고, FP8·8x H200·vLLM·SGLang 자체 호스팅 요구사항과 ThakiCloud 온프렘 소버린 AI 서빙 시사점을 정리했습니다."
date: 2026-06-22
last_modified_at: 2026-06-22
tags:
  - glm-5-2
  - open-weight-llm
  - vllm
  - sglang
  - self-hosting
  - sovereign-ai
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
categories:
  - dev
canonical_url: "https://thakicloud.com/tech-blog/ko/dev/glm-5-2-open-weight-coding-moe/"
audiobook: /assets/audio/posts/glm-5-2-open-weight-coding-moe/audiobook-ko.mp3
audiobook_note: "AI 로컬 합성 오디오북 (Qwen3-TTS)"
---

## 개요

오픈웨이트 모델이 프런티어 코딩 능력을 따라잡는 흐름은 지난 1년간 계속됐지만, 2026년 6월의 GLM-5.2는 그 흐름에 분명한 변곡점을 찍었습니다. Vercel의 CEO인 기예르모 라우흐가 Z.ai의 GLM-5.2 코딩 능력에 거의 충격에 가까운 감탄을 공개적으로 표하면서 개발자 타임라인이 들썩였고, 곧이어 독립 벤치마크에서 여러 장기 호흡 코딩 과제에 대해 GPT-5.5를 앞섰다는 보도가 이어졌습니다. 더 중요한 사실은 가격입니다. 같은 능력을 약 1/6 비용으로 낸다는 점, 그리고 가중치가 MIT 라이선스로 완전히 공개됐다는 점이 결합되면서, 이 모델은 단순한 벤치마크 뉴스가 아니라 인프라 의사결정의 변수가 됐습니다.

ThakiCloud처럼 쿠버네티스 기반으로 AI/ML SaaS 플랫폼을 운영하는 입장에서 이 조합은 그냥 지나칠 수 없습니다. 폐쇄형 API에 종속되지 않고, 고객의 데이터 경계 안에서, 통제된 비용으로 프런티어급 코딩 모델을 띄울 수 있다면, 그것은 온프렘과 소버린 AI를 요구하는 고객에게 곧바로 팔 수 있는 제품이 됩니다. 이 글에서는 GLM-5.2의 공개된 사실을 먼저 확인하고, 실제로 자체 호스팅하려면 무엇이 필요한지, 그리고 우리 플랫폼 관점에서 어떤 의미가 있는지를 차례로 정리합니다. 모델 자체를 8장의 H200 위에 띄우는 것은 이 글의 범위를 벗어나므로, 수치는 모두 공개 문서와 보도에서 확인한 값만 인용하고 직접 재현하지 못한 부분은 명확히 구분했습니다.

## 이 모델은 무엇인가

GLM-5.2는 중국의 Z.ai(zai-org)가 2026년 6월 13일 공개한 대규모 Mixture-of-Experts 모델입니다. 전체 파라미터는 744B 규모이고, 토큰마다 활성화되는 파라미터는 약 40B로 직전 세대인 GLM-5.1과 비슷한 수준을 유지합니다. MoE 구조의 핵심이 바로 여기에 있습니다. 전체 용량은 거대하게 키우되, 한 번의 추론에서 실제로 계산에 참여하는 전문가(expert)는 일부만 활성화해 추론 비용을 억제하는 방식입니다. 744B라는 숫자에 겁먹기 전에, 실효 연산량은 40B급이라는 점을 먼저 이해해야 자체 호스팅 비용을 올바르게 가늠할 수 있습니다.

가장 눈에 띄는 변화는 컨텍스트 윈도우입니다. GLM-5.2는 100만(1M) 토큰 컨텍스트를 지원하며, 이는 GLM-5.1의 약 20만 토큰 한계에서 다섯 배가량 늘어난 수치입니다. 출력은 최대 131,072 토큰까지 가능합니다. 장기 호흡 코딩, 즉 거대한 코드베이스 전체를 컨텍스트에 올려 두고 여러 파일에 걸친 리팩터링이나 버그 추적을 수행하는 작업에서 이 컨텍스트 크기는 결정적입니다. 그리고 코딩 우선으로 훈련 초점을 맞췄다는 점이 벤치마크 결과로 드러납니다.

라이선스는 MIT입니다. 상업적 사용에 제약이 거의 없는 가장 관대한 오픈소스 라이선스 중 하나이며, 이는 비상업 조항이 붙은 일부 오픈웨이트 모델과 결정적으로 다른 지점입니다. 가중치는 허깅페이스에 공개돼 있고(zai-org/GLM-5.2-FP8), 소스와 레시피는 깃허브 저장소(zai-org/GLM-5)에서, 간편 실행은 Ollama 라이브러리(glm-5.2)를 통해 받을 수 있습니다.

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
<div class="d3-arch" data-arch-root id="glm52openweightcodingmoe-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 366, "height": 818, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 97, "y": 24, "w": 156, "h": 62, "title": ["GLM-5.2", "744B 전체 파라미터 · MoE"]}, {"id": "B", "x": 90, "y": 164, "w": 170, "h": 62, "title": ["MoE 라우팅", "토큰당 활성 약 40B 전문가만 계산"]}, {"id": "C", "x": 199, "y": 304, "w": 135, "h": 62, "title": ["1M 토큰 컨텍스트", "GLM-5.1 대비 약 5배"]}, {"id": "D", "x": 24, "y": 312, "w": 120, "h": 46, "title": "코딩 우선 학습"}, {"id": "E", "x": 115, "y": 444, "w": 121, "h": 46, "title": "장기 호흡 코딩 워크로드"}, {"id": "F", "x": 80, "y": 568, "w": 191, "h": 62, "title": ["SWE-bench Pro 62.1", "Terminal-Bench 2.1 81.0"]}, {"id": "G", "x": 83, "y": 708, "w": 184, "h": 78, "title": ["MIT 오픈웨이트 · 자체 호스팅", "FP8 · 8x H200 · vLLM /", "SGLang"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [175, 86, 175, 164]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[216, 226], [267, 265], [267, 265], [267, 304]]}, {"src": "B", "dst": "D", "kind": "data", "curve": [[135, 226], [84, 265], [84, 265], [84, 312]]}, {"src": "C", "dst": "E", "kind": "data", "curve": [[267, 366], [267, 405], [267, 405], [209, 444]]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[84, 358], [84, 405], [84, 405], [141, 444]]}, {"src": "E", "dst": "F", "kind": "data", "line": [175, 490, 175, 568]}, {"src": "F", "dst": "G", "kind": "data", "line": [175, 630, 175, 708]}]});
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
      const container = document.getElementById('glm52openweightcodingmoe-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'glm52openweightcodingmoe-1';
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
*전체 744B 용량 중 토큰당 약 40B만 활성화하는 MoE 라우팅과, 1M 컨텍스트·코딩 특화 학습이 장기 호흡 코딩 성능으로 연결되는 구조입니다.*

## 벤치마크: GPT-5.5를 어디서 앞섰나

화제의 핵심인 벤치마크부터 사실 확인을 했습니다. 독립 벤치마크 기준으로 GLM-5.2는 현재 최상위 오픈웨이트 코딩 모델로 평가됩니다. 구체적인 수치는 다음과 같습니다.

| 벤치마크 | GLM-5.2 | GPT-5.5 | Claude Opus 4.8 |
|---|---|---|---|
| SWE-bench Pro | 62.1 | 58.6 | 69.2 |
| Terminal-Bench 2.1 | 81.0 | (비교 수치 미확인) | GLM-5.2보다 소폭 우위 |

읽는 법은 이렇습니다. SWE-bench Pro에서 GLM-5.2의 62.1은 GPT-5.5의 58.6을 앞섭니다. 다만 Claude Opus 4.8의 69.2에는 미치지 못합니다. Terminal-Bench 2.1에서는 81.0을 기록하며 Claude Opus 4.8에 근소한 차이로 따라붙은 2위권으로 보도됐습니다. 즉 "모든 프런티어 모델을 이겼다"가 아니라, "최상위 폐쇄형 모델 바로 아래에 붙으면서, 같은 체급의 폐쇄형 API인 GPT-5.5는 여러 장기 호흡 코딩 과제에서 앞섰다"가 정확한 요약입니다.

여기에 비용이 결합됩니다. 보도에 따르면 GLM-5.2는 이 수준의 성능을 GPT-5.5 대비 약 1/6 비용으로 냅니다. 성능에서 한두 점 차이는 실무에서 충분히 감내할 수 있지만, 6배의 비용 차이는 인프라 전략을 바꾸는 크기입니다. 참고로 Z.ai가 직접 제공하는 관리형 GLM Coding Plan은 라이트가 월 10달러, 프로가 월 30달러, 맥스가 월 80달러 수준으로 책정돼 있습니다. 자체 호스팅 대신 관리형으로 시작해 보고 싶은 팀에게는 진입 비용이 낮은 편입니다.

## 자체 호스팅: 744B를 실제로 띄우려면

가중치가 공개됐다고 해서 노트북에서 돌아가는 것은 아닙니다. 744B MoE를 자체 호스팅하려면 무엇이 필요한지, 공개된 배포 가이드와 vLLM 공식 레시피에서 확인한 요구사항을 정리합니다. 아래 수치는 직접 8장의 H200을 띄워 재현한 것이 아니라 공개 문서에서 인용한 값이며, 실제 환경에서는 검증이 필요합니다.

FP8 양자화 버전의 가중치는 약 750GB 규모입니다. 한 보도는 FP8 변형이 가중치만으로 약 753GB의 GPU 메모리를 요구한다고 정리했습니다. FP8의 장점은 BF16 대비 메모리 요구량을 절반으로 줄인다는 점입니다. 8장의 H200으로 구성한 서버는 약 1,128GB의 총 VRAM을 제공하므로, FP8 가중치를 올리고도 KV 캐시를 위한 여유가 남습니다. 다만 1M 컨텍스트 워크로드에서는 FP8 KV 캐시를 켜야 하고, 그래도 8x H200에서는 여유가 빠듯해집니다.

서빙 프레임워크는 두 갈래가 일반적입니다. vLLM은 v0.23.0 이상을 최소 버전으로 요구하며, 8장의 GPU에 걸쳐 텐서 병렬(tensor-parallel-size 8)로 샤딩해 배포합니다.

```bash
# vLLM 기준 개념 예시 (실제 플래그·버전은 공식 레시피로 확인 필요)
vllm serve zai-org/GLM-5.2-FP8 \
  --tensor-parallel-size 8 \
  --kv-cache-dtype fp8 \
  --max-model-len 1000000
```

또 다른 선택지인 SGLang은 배치·동시 요청을 중심으로 설계된 구조화 생성 서빙 계층입니다. 제약 디코딩을 기본 지원하고, RadixAttention으로 KV 캐시를 공유하기 때문에 동시 클라이언트가 많은 워크로드에 자연스러운 출발점입니다. 전문가 병렬(`--enable-moe-ep`)과 FP8 KV 캐시(`fp8_e5m2`) 같은 옵션을 함께 씁니다.

핵심 운영 포인트는 분명합니다. FP8 KV 캐시는 KV 메모리를 절반으로 줄이면서 품질 영향이 미미하고, 1M 컨텍스트에서는 선택이 아니라 필수입니다. 대부분의 팀이 초기 자체 호스팅 평가를 시작할 때 FP8가 현실적인 출발점이라는 것이 공통된 권고입니다.

## ThakiCloud K8s AI/ML SaaS 플랫폼 적용 및 시사점

ThakiCloud의 AI 플랫폼은 쿠버네티스 위에서 Kueue로 GPU 워크로드를 스케줄링하고, vLLM 기반으로 모델을 서빙하며, 멀티테넌트 환경에서 여러 고객의 추론을 격리해 운영하는 구조입니다. GLM-5.2는 이 스택에 거의 그대로 들어맞습니다.

첫째, 온프렘과 소버린 AI 수요에 대한 직접적인 답입니다. 금융, 공공, 국방처럼 데이터가 외부 API로 나가는 것 자체가 금지되는 환경에서는, 능력이 아무리 좋아도 폐쇄형 클라우드 API를 쓸 수 없습니다. MIT 라이선스 오픈웨이트인 GLM-5.2는 고객의 데이터 경계 안에서 프런티어급 코딩 모델을 돌릴 수 있게 합니다. 8x H200 한 노드를 Kueue 큐에 등록하고 vLLM로 띄우면, 외부로 한 바이트도 나가지 않는 코딩 어시스턴트가 만들어집니다. 이는 ThakiCloud가 강조해 온 온프렘·자체 호스팅 가치 제안과 정확히 같은 방향입니다.

둘째, 비용 구조입니다. 약 1/6 비용이라는 보도가 사실이라면, 고객에게 폐쇄형 API 재판매가 아니라 자체 호스팅 기반의 예측 가능한 정액 인프라를 제안할 수 있습니다. MoE의 활성 40B 특성 덕분에 744B라는 규모에도 추론 단가는 통제 가능한 범위에 들어옵니다. 멀티테넌트로 GPU를 공유하고 SGLang의 RadixAttention으로 KV 캐시를 재활용하면, 노드당 처리량을 끌어올려 단가를 더 낮출 여지가 있습니다.

셋째, 1M 컨텍스트는 우리 플랫폼이 지향하는 에이전트 워크로드와 맞물립니다. 거대한 사내 코드베이스나 문서를 통째로 컨텍스트에 올려 두고 장기 호흡으로 작업하는 도메인 코딩 에이전트는, 짧은 컨텍스트 모델로는 불가능한 제품입니다. 다만 1M 컨텍스트는 KV 캐시 메모리를 크게 잡아먹으므로, 멀티테넌트 환경에서는 테넌트별 최대 컨텍스트 길이를 정책으로 통제하는 설계가 필요합니다.

## 한계 및 반론

기대를 키우기 전에 반대편도 분명히 짚어야 합니다. 우선 GLM-5.2는 모든 면에서 최강이 아닙니다. SWE-bench Pro 62.1은 Claude Opus 4.8의 69.2에 7점 이상 뒤집니다. 절대적인 코딩 품질이 최우선이고 데이터 외부 반출이 허용되는 환경이라면, 여전히 최상위 폐쇄형 모델이 합리적인 선택입니다. GLM-5.2의 가치는 "최강"이 아니라 "자체 호스팅 가능한 범위에서 최강에 가장 근접"이라는 점에 있습니다.

벤치마크 수치 자체도 보수적으로 받아들여야 합니다. 이 글의 모든 수치는 독립 보도와 공개 문서에서 인용한 것이지, 우리가 직접 동일 조건으로 재현한 값이 아닙니다. 벤치마크 점수는 평가 하니스, 프롬프트, 샘플링 설정에 따라 달라질 수 있으므로, 실제 도입 전에는 자사의 대표 과제로 재측정하는 절차가 반드시 필요합니다.

자체 호스팅의 진입 장벽도 현실적입니다. 8x H200급 노드는 도입과 운영 모두 만만치 않은 비용이며, 1M 컨텍스트를 실제로 활용하면 KV 캐시 압박으로 동시 처리 가능한 요청 수가 빠르게 줄어듭니다. "1M 컨텍스트 지원"과 "1M 컨텍스트를 멀티테넌트로 동시 서빙"은 전혀 다른 난이도의 문제입니다. 또한 중국 연구소가 공개한 모델이라는 점에서, 일부 고객은 공급망과 거버넌스 관점의 검토를 요구할 수 있습니다. 오픈웨이트라 가중치를 직접 검증하고 격리 환경에서 운영할 수 있다는 점이 이 우려를 상당 부분 완화하지만, 도입 의사결정에서 명시적으로 다뤄야 할 항목입니다.

결론적으로 GLM-5.2는 "폐쇄형을 무조건 대체한다"가 아니라, "온프렘·소버린·비용 통제가 중요한 워크로드에서 폐쇄형 API의 강력한 대안이 생겼다"로 읽는 것이 정확합니다. 그리고 그 워크로드야말로 ThakiCloud가 가장 잘하는 영역입니다.


## 관련 슬라이드

본문 내용을 NotebookLM(`prismatic_tech` 스타일)으로 요약한 슬라이드입니다.

![glm-5-2-open-weight-coding-moe 슬라이드 1]({{ '/assets/images/glm-5-2-open-weight-coding-moe-slide-01.webp' | relative_url }})

![glm-5-2-open-weight-coding-moe 슬라이드 2]({{ '/assets/images/glm-5-2-open-weight-coding-moe-slide-02.webp' | relative_url }})

![glm-5-2-open-weight-coding-moe 슬라이드 3]({{ '/assets/images/glm-5-2-open-weight-coding-moe-slide-03.webp' | relative_url }})

![glm-5-2-open-weight-coding-moe 슬라이드 4]({{ '/assets/images/glm-5-2-open-weight-coding-moe-slide-04.webp' | relative_url }})

## 출처

- [Z.ai's open-weights GLM-5.2 beats GPT-5.5 on multiple long-horizon coding benchmarks for 1/6th the cost (VentureBeat)](https://venturebeat.com/technology/z-ais-open-weights-glm-5-2-beats-gpt-5-5-on-multiple-long-horizon-coding-benchmarks-for-1-6th-the-cost)
- [GLM-5.2: Features, Setup, Benchmarks, and Model Switching Guide (DataCamp)](https://www.datacamp.com/blog/glm-5-2)
- [zai-org/GLM-5 (GitHub)](https://github.com/zai-org/GLM-5)
- [zai-org/GLM-5.2-FP8 (Hugging Face)](https://huggingface.co/zai-org/GLM-5.2-FP8)
- [GLM-5 and GLM-5.1 Series Usage (vLLM Recipes)](https://docs.vllm.ai/projects/recipes/en/latest/GLM/GLM5.html)
- [Deploy GLM-5.2 on GPU Cloud (Spheron)](https://www.spheron.network/blog/deploy-glm-5-2-gpu-cloud/)
- [Running GLM-5.2 at Home: SGLang, vLLM, Transformers, KTransformers (Groundy)](https://groundy.com/articles/running-glm-5-2-at-home-sglang-vllm-transformers-and-ktransformers-setup-guide/)
