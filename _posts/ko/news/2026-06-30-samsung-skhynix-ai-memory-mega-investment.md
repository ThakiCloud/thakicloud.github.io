---
title: "삼성·SK, 10년간 4,755조 원 국내 투자: 호남 메모리 팹부터 15GW AI 데이터센터까지"
excerpt: "2026년 6월 29일 삼성전자와 SK하이닉스가 향후 10년간 국내에 합산 4,755조 원을 투자한다고 발표했습니다. 서남권 메모리 팹 4기(800조), SK의 15GW AI 데이터센터(1,000조)를 중심으로 발표 내용을 정리하고, HBM 슈퍼사이클과 정책 환경, 그리고 국내 AI 인프라 수요가 ThakiCloud의 K8s·Kueue 기반 서빙 플랫폼에 무엇을 의미하는지 살펴봅니다."
seo_title: "삼성·SK 4755조 투자 발표 총정리: 호남 팹·AI 데이터센터 - Thaki Cloud"
seo_description: "삼성 2655조·SK 2100조 합계 4755조 원 국내 투자 발표를 정리했습니다. 서남권 메모리 팹 800조, SK 15GW AI 데이터센터 1000조, HBM 슈퍼사이클과 반도체 특별법, 그리고 ThakiCloud의 K8s·Kueue 서빙 관점 시사점을 다룹니다."
date: 2026-06-30
last_modified_at: 2026-06-30
disable_mathjax: true
tags:
  - samsung
  - sk-hynix
  - hbm
  - ai-memory
  - semiconductor
  - data-center
  - sovereign-ai
  - kubernetes
  - kueue
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "microchip"
canonical_url: "https://thakicloud.com/tech-blog/ko/news/samsung-skhynix-ai-memory-mega-investment/"
categories:
  - news
audiobook: /assets/audio/posts/samsung-skhynix-ai-memory-mega-investment/audiobook-ko.mp3
audiobook_note: "AI 로컬 합성 오디오북 (Qwen3-TTS)"
published: false
---

2026년 6월 29일 청와대 영빈관에서 큰 숫자가 하나 나왔습니다. 삼성전자와 SK하이닉스가 앞으로 10년간 국내에 합산 4,755조 원을 투자하겠다는 계획입니다. 이재명 대통령이 주재한 "대한민국 대도약 3대 메가프로젝트 국민보고회" 자리에서 이재용 회장과 최태원 회장이 직접 선언했습니다.

이 글은 그날 발표된 내용을 차분히 정리합니다. 무엇을, 어디에, 얼마나 짓겠다는 것인지, 그 배경에 어떤 산업 흐름과 정책이 있는지, 그리고 이것이 AI 인프라를 운용하는 사업자에게 무엇을 의미하는지 순서대로 짚겠습니다.

![삼성·SK 10년 국내 투자 계획 규모를 정부 연간 예산과 비교한 막대 그래프]({{ '/assets/images/samsung-skhynix-ai-memory-mega-investment-results.webp' | relative_url }})

## 무엇을 발표했나

발표는 기업 단독 IR이 아니라 대통령이 "한국형 AI 산업혁명"으로 규정한 국가 메가프로젝트 선언이었습니다. 투자 주체는 두 그룹입니다. 삼성그룹이 2,655조 원, SK그룹이 2,100조 원을 향후 10년간 국내에 집행하겠다고 밝혔고, 합치면 4,755조 원입니다. 정부 연간 예산(약 728조 원)의 6.5배에 해당하는 규모입니다.

이재용 회장은 광주를 신규 반도체 단지 후보지로 직접 언급하며 "인센티브 지원이 기대되는 광주를 후보지로 계획 중"이라고 말했습니다. 최태원 회장은 한국을 "AI를 소비하는 나라에서 수출하는 나라로" 전환하겠다고 강조했습니다. 곽노정 SK하이닉스 CEO는 용인 클러스터의 반도체특별법 적용과 지방 정주 여건 개선을 함께 요청했습니다.

다만 4,755조 원은 10년 이상에 걸친 누적 계획 집행액이라는 점을 짚어둘 필요가 있습니다. 두 회사의 현재 연간 설비투자 합계는 약 70조 원대(삼성 DS 약 41조, SK하이닉스 약 29조)입니다. 발표 규모와 연간 집행 속도는 구분해서 봐야 합니다.

> 달러 환산 참고: 발표 금액의 기준은 원화입니다. 1달러=1,380원으로 환산하면 4,755조 원은 약 3조 4,000억 달러 규모입니다.

## 투자 구조: 서남권 800조 팹과 15GW 데이터센터

총계 4,755조 원 안에서 가장 구속력 있는 약정은 서남권(호남) 메모리 팹입니다. 삼성과 SK가 각각 400조 원씩, 합쳐서 800조 원을 투입해 메모리 팹 4기(각사 2기)를 신설합니다. 삼성은 광주를 후보지로 보고 있습니다. 나머지 항목은 다음과 같이 구성됩니다.

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
<div class="d3-arch" data-arch-root id="ixaimemorymegainvestment-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 588, "height": 703, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 24, "y": 317, "w": 135, "h": 62, "title": ["삼성·SK 10년 국내 투자", "4,755조 원"]}, {"id": "B", "x": 237, "y": 141, "w": 120, "h": 62, "title": ["삼성전자", "2,655조"]}, {"id": "C", "x": 237, "y": 434, "w": 120, "h": 62, "title": ["SK그룹", "2,100조"]}, {"id": "B1", "x": 436, "y": 24, "w": 120, "h": 62, "title": ["평택·용인 반도체", "약 2,030조"]}, {"id": "B2", "x": 436, "y": 141, "w": 120, "h": 62, "title": ["충청 HBM 패키징", "140조"]}, {"id": "C1", "x": 435, "y": 375, "w": 121, "h": 62, "title": ["AI 데이터센터", "1,000조 · 15GW"]}, {"id": "C2", "x": 436, "y": 492, "w": 120, "h": 62, "title": ["용인 반도체", "600조"]}, {"id": "C3", "x": 436, "y": 609, "w": 120, "h": 62, "title": ["청주 낸드 증산", "100조"]}, {"id": "D", "x": 436, "y": 258, "w": 120, "h": 62, "title": ["서남권 메모리 팹 4기", "800조 · 양사 공동"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[110, 317], [198, 172], [198, 172], [237, 172]]}, {"src": "A", "dst": "C", "kind": "data", "curve": [[120, 379], [198, 465], [198, 465], [237, 465]]}, {"src": "B", "dst": "B1", "kind": "data", "curve": [[323, 141], [396, 55], [396, 55], [436, 55]]}, {"src": "B", "dst": "B2", "kind": "data", "line": [357, 172, 436, 172]}, {"src": "C", "dst": "C1", "kind": "data", "curve": [[349, 434], [396, 406], [396, 406], [435, 406]]}, {"src": "C", "dst": "C2", "kind": "data", "curve": [[349, 496], [396, 523], [396, 523], [436, 523]]}, {"src": "C", "dst": "C3", "kind": "data", "curve": [[314, 496], [396, 640], [396, 640], [436, 640]]}, {"src": "B", "dst": "D", "kind": "data", "line": [342, 203, 436, 260]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[321, 434], [396, 338], [396, 338], [436, 318]]}]});
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
      const container = document.getElementById('ixaimemorymegainvestment-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ixaimemorymegainvestment-1';
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

SK 쪽에서 눈여겨볼 항목은 AI 데이터센터입니다. SKT가 주도해 2035년까지 1,000조 원을 들여 전국 15GW 규모의 AI 데이터센터를 구축하겠다는 계획입니다. 데이터센터 1GW 건설 캐펙스가 통상 10억~30억 달러 수준임을 고려하면, 15GW에 1,000조 원이라는 규모는 대략 정합합니다. 여기에 SK하이닉스의 청주 낸드플래시 증산(100조 원)이 별도로 더해집니다. 삼성은 평택·용인 반도체에 약 2,030조 원, 충청 HBM 패키징에 140조 원을 배정했습니다.

## 왜 지금, 이렇게 큰 규모인가: HBM 슈퍼사이클

이 거대한 숫자의 동력은 한 가지로 수렴합니다. HBM, 고대역폭메모리 수요입니다. HBM은 AI 가속기에 적층 탑재되는 고부가 메모리로, 일반 DRAM보다 단가가 5~7배 높습니다. 글로벌 HBM 시장은 2025년 약 350억 달러에서 2026년 약 546억~580억 달러로, 58% 이상 성장이 전망됩니다.

수요의 뿌리는 하이퍼스케일러의 지출입니다. 아마존·마이크로소프트·구글·메타·오라클의 2026년 AI 인프라 캐펙스는 6,000억 달러를 넘어섰고, 그중 메모리가 차지하는 비중이 약 30%까지 올라왔습니다. 2023~2024년의 8%에서 약 4배로 뛴 수치입니다. NVIDIA의 Blackwell·Rubin 수요만으로 수천억 달러 규모의 수주 잔고가 쌓였고, 세 HBM 공급사인 SK하이닉스·마이크론·삼성의 2026년 생산분은 사실상 완판된 상태입니다.

핵심은 이 병목이 자본 부족이 아니라 생산 용량 부족에서 온다는 점입니다. 돈이 없어서 못 만드는 것이 아니라 팹이 부족해서 못 만드는 상황입니다. 그래서 두 회사가 동시에 대규모 증설로 향하는 것입니다. SK하이닉스는 2025년 3분기 영업이익률 47%를 기록했고, 이 수익이 용인·청주 설비로 재투입되는 선순환 구조를 만들었습니다.

## 정책이 받쳐주는 구조: 반도체 특별법

한국은 미국이나 유럽처럼 현금 보조금을 직접 주는 대신 세액공제 중심으로 반도체를 지원해왔습니다. 2025년 2월 통과된 K-칩스법은 대기업 시설투자 세액공제율을 15%에서 20%로 올렸고, R&D 공제를 2031년까지 연장했습니다. 두 회사 합산 약 6조 원의 감세 효과로 추산됩니다.

여기에 2026년 1월 통과된 반도체 특별법이 더해졌습니다. 이 법은 전력·용수·도로 같은 산업기반시설 조성에 국가와 지자체가 직접 지원할 근거를 마련했습니다. 시행은 2026년 3분기 예정입니다. 이번 800조 원 호남 팹이 실제로 가동되려면 이 특별법에 따른 전력·용수 인프라의 적기 공급이 결정적 변수입니다. 곽노정 CEO가 발표 자리에서 용인 클러스터의 특별법 적용을 직접 요청한 것도 이 때문입니다.

## 글로벌 경쟁: 세 HBM 공급사의 동시 증설

| 기업 | 위치 | 최근 투자 | HBM 상황 |
|---|---|---|---|
| SK하이닉스 | 메모리 1위 | 용인 600조 등 | HBM 점유 약 57%, HBM4 우선공급 |
| 삼성전자 | 메모리 추격 | 평택·용인 약 2,030조 | HBM 점유 약 35%, 2026년 50% 증설 |
| 마이크론 | 메모리 3위 | FY26 약 200억 달러 | 2026년 HBM 완판, HBM4 2분기 양산 |
| TSMC | 파운드리 | 애리조나 1,650억 달러 | CoWoS 패키징 2026년 매진 |

세 HBM 공급사 모두 2026년 생산분이 매진된 상황입니다. 문제는 2027~2028년입니다. 이때 가동될 한국 팹이 충분하지 않으면 HBM4·HBM5 수요 증가분을 마이크론에 내줄 수 있습니다. 파운드리 쪽에서는 TSMC가 애리조나에만 1,650억 달러를 투입하며 CoWoS 패키징 용량을 2026년까지 매진시켰고, 인텔은 파운드리 구조조정으로 HBM 경쟁에서 사실상 이탈했습니다.

## 전력이 진짜 병목: 데이터센터의 입지 경쟁

2026년 1분기부터 AI 인프라의 핵심 병목은 칩이 아니라 전력으로 이동했습니다. 미국에서는 약 7GW 규모의 데이터센터 프로젝트가 전력 부족으로 지연되거나 취소됐습니다. 역설적으로 이는 전력과 토지를 확보할 수 있는 한국 서남권과 중동의 입지 매력을 높입니다.

SK가 2035년까지 1,000조 원을 들여 전국 15GW급 AI 데이터센터를 짓겠다는 것은 단순한 부동산 투자가 아닙니다. 메모리 제조사가 자신이 HBM을 납품하는 데이터센터를 직접 구축하면, 수요를 스스로 창출하고 NVIDIA와 하이퍼스케일러가 사양을 결정하는 공급망 구조에서 협상력을 회복할 수 있습니다. 삼성도 해남 AI 데이터센터, 세종 AI 서버 기판 공장 등으로 같은 수직통합 방향을 향하고 있습니다.

## 시장 반응

발표 직후 삼성전자 주가는 등락 끝에 323,000원에 마감했고, 6월 30일에는 SK하이닉스가 삼성전자를 제치고 코스피 시총 1위를 탈환했습니다. 일부 전문가는 2000년 닷컴 버블 당시 시스코-마이크로소프트 역전과 비교하며 고점 신호를 거론했으나, 다수 애널리스트는 "실적과 매크로를 더 지켜봐야 한다"며 단순 과열 판단을 유보했습니다. 삼성의 2026년 영업이익 추정치(361조 원)가 SK하이닉스(262조 원)보다 높아 밸류에이션 역전이 과도하다는 시각도 있습니다.

## ThakiCloud 관점: 하드웨어가 늘수록 소프트웨어 계층이 중요해집니다

이 발표의 본질은 한국이 AI 인프라를 국가 차원에서 수직통합한다는 것이며, 이는 ThakiCloud의 ai-platform 사업과 직접 맞닿습니다.

국내 AI 데이터센터가 15GW 규모로 확장되면 그 위에서 모델을 학습하고 서빙할 멀티테넌트 인프라 수요가 함께 커집니다. ThakiCloud는 Kubernetes와 Kueue 기반 GPU 스케줄링, vLLM 서빙으로 바로 이 계층을 겨냥합니다. 팹과 데이터센터가 하드웨어를 공급하면, 그 위에서 여러 고객의 워크로드를 안전하게 격리하며 굴리는 제어 평면이 필요해집니다.

수요의 성격도 우리에게 유리합니다. 국가 기간산업과 공공 영역은 외부 클라우드가 아니라 자체 데이터센터 안에서 모델을 운용해야 하는 경우가 많습니다. 보안 요구가 까다로운 환경일수록 그렇습니다. ThakiCloud의 self-hosting, 멀티테넌트 격리, 비용효율 서빙은 이 소버린 AI 수요에 정확히 부합합니다.

그리고 가장 중요한 변화가 있습니다. HBM과 고성능 GPU가 늘어날수록 경쟁의 축은 "얼마나 많이 샀는가"에서 "얼마나 효율적으로 굴리는가"로 옮겨갑니다. 값비싼 가속기를 놀리지 않게 하는 GPU 라이프사이클 관리와 큐잉이 결국 비용을 좌우합니다. 4,755조 원이 만들어낼 하드웨어를 효율적으로 굴리는 소프트웨어 계층, 바로 그곳에 ThakiCloud가 제공하는 가치가 있습니다.

## 한계와 반론: 낙관만 하기엔 이릅니다

이 발표를 무조건 호재로만 읽는 것은 위험합니다. 반대 방향의 근거를 정직하게 짚겠습니다.

먼저 4,755조 원은 10년 누적 "계획"이며 연간 집행이 검증된 숫자가 아닙니다. 정부 행사라는 특성상 상향 편향이 있을 수 있고, 과거 2024년에 발표된 용인 622조 클러스터도 일정 지연을 겪었습니다. 발표와 집행 사이에는 늘 간극이 있습니다.

다음으로 HBM 슈퍼사이클이 꺾이면 오늘의 증설은 내일의 공급과잉이 됩니다. 메모리는 역사적으로 사이클이 가파른 산업입니다. AI 캐펙스가 일부 분석대로 과투자라면, 2027~2028년 가동될 팹이 하필 수요 둔화기와 겹칠 수 있습니다.

전력·용수 인프라가 제때 공급되지 않으면 800조 원을 들인 팹도 가동이 미뤄집니다. 글로벌 데이터센터 지연의 주원인이 전력인 만큼 이는 추상적 우려가 아니라 실질적 리스크입니다.

마지막으로 시총 역전을 두고 밸류에이션이 실적을 앞서간다는 경고가 나옵니다. 발표의 규모가 곧 실적을 보장하지는 않습니다.

## 정리

2026년 6월 29일 발표의 골격은 명확합니다. 삼성과 SK가 10년간 4,755조 원을 국내에 투자하며, 그 중심에는 서남권 800조 메모리 팹과 SK의 15GW AI 데이터센터가 있습니다. 이 모든 것을 끌어가는 동력은 HBM 슈퍼사이클이고, 성패는 전력·용수 인프라의 속도에 달려 있습니다.

한국이 AI 하드웨어를 국가 규모로 짓는 동안, 그 하드웨어를 효율적으로 굴리는 소프트웨어 계층의 가치는 함께 커집니다. ThakiCloud는 바로 그 지점에서 K8s·Kueue 기반 서빙과 소버린 인프라로 자리를 잡아가고 있습니다.

## 출처

- 파이낸셜뉴스, 서남권 팹 4기 삼성·SK 4,755조 (2026-06-29): [https://www.fnnews.com/news/202606291837098645](https://www.fnnews.com/news/202606291837098645)
- 뉴시스, 삼성·SK 800조 호남 반도체 허브 (2026-06-29): [https://www.newsis.com/view/NISX20260629_0003687807](https://www.newsis.com/view/NISX20260629_0003687807)
- 아주경제, SKT 15GW AI 데이터센터 (2026-06-29): [https://www.ajunews.com/view/20260629171803513](https://www.ajunews.com/view/20260629171803513)
- 한국경제, 용인 600조·청주 100조 (2026-06-29): [https://www.hankyung.com/article/2026062943107](https://www.hankyung.com/article/2026062943107)
- CNBC, South Korea Samsung SK Hynix mega-projects (2026-06-29): [https://www.cnbc.com/2026/06/29/samsung-sk-hynix-reported-1point3-reported-trillion-spending-plans.html](https://www.cnbc.com/2026/06/29/samsung-sk-hynix-reported-1point3-reported-trillion-spending-plans.html)
- SK hynix, 2026 Market Outlook (HBM Supercycle): [https://news.skhynix.com/2026-market-outlook-focus-on-the-hbm-led-memory-supercycle/](https://news.skhynix.com/2026-market-outlook-focus-on-the-hbm-led-memory-supercycle/)
- TrendForce, Micron CapEx $20B·2026 HBM booked (2025-12-18): [https://www.trendforce.com/news/2025/12/18/news-micron-hikes-capex-to-20b-with-2026-hbm-supply-fully-booked-hbm4-ramps-2q26/](https://www.trendforce.com/news/2025/12/18/news-micron-hikes-capex-to-20b-with-2026-hbm-supply-fully-booked-hbm4-ramps-2q26/)
- 정책브리핑, 반도체 특별법 국회 통과 (2026-01-30): [https://www.korea.kr/briefing/pressReleaseView.do?newsId=156742072](https://www.korea.kr/briefing/pressReleaseView.do?newsId=156742072)
