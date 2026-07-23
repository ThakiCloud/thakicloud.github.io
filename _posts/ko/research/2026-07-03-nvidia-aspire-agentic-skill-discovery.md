---
title: "NVIDIA ASPIRE: 로봇이 실패를 스킬로 바꾸는 에이전트형 스킬 발견"
excerpt: "로봇은 과제를 풀 때마다 시행착오를 버리고 매번 처음부터 다시 더듬습니다. NVIDIA의 ASPIRE는 LLM이 로봇 제어 코드를 직접 짜고, 실행에서 실패를 관찰해 수리하며, 검증된 수리 경험을 재사용 가능한 스킬로 증류하는 지속 학습 시스템입니다. 양팔 핸드오버 성공률이 추가 학습 없이 20%에서 92%로 오른 결과와 함께, ThakiCloud Paxis의 자가진화 스킬 하니스가 이 흐름을 어떻게 실무로 구현하는지 살펴봅니다."
seo_title: "NVIDIA ASPIRE: 로봇 스킬 발견과 지속 학습 | Thaki Cloud"
seo_description: "NVIDIA GEAR의 ASPIRE(arXiv 2607.00272)를 정리합니다. code-as-policy로 로봇 제어 코드를 쓰고 실패를 수리해 스킬로 증류하는 구조, 핸드오버 20%→92% 결과, 그리고 ThakiCloud Paxis 스킬 하니스 적용을 다룹니다."
date: 2026-07-03
last_modified_at: 2026-07-03
categories:
  - research
tags:
  - agent-skills
  - robotics
  - continual-learning
  - code-as-policy
  - nvidia
  - llm-agents
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "robot"
canonical_url: "https://thakicloud.com/tech-blog/ko/research/nvidia-aspire-agentic-skill-discovery/"
published: false
audiobook: /assets/audio/posts/nvidia-aspire-agentic-skill-discovery/audiobook-ko.mp3
audiobook_note: "AI 로컬 합성 오디오북 (Qwen3-TTS)"
---

![행동의 보관소: 실패를 스킬로 증류하는 에이전트 아키텍처]({{ '/assets/images/nvidia-aspire-agentic-skill-discovery-slide-01.webp' | relative_url }})

## 개요

로봇을 오래 굴려 본 사람은 익숙한 낭비를 봅니다. 로봇이 어떤 과제를 힘들게 성공시켜도, 그 과정에서 얻은 시행착오는 대부분 버려집니다. 다음 과제에서는 또 처음부터 더듬습니다. 실패를 딛고 만든 미세한 노하우, 이를테면 그리퍼가 미끄러졌을 때의 복구 방법이나 특정 물체를 다룰 때의 접근 각도 같은 것들이 시스템 어디에도 남지 않습니다. 사람이라면 한 번 배운 요령을 다음에 다시 쓰는데, 로봇은 그러지 못합니다.

![잊혀진 실패들의 낭비: 인간은 실패에서 요령을 배우지만 로봇은 매번 처음부터 다시 더듬습니다]({{ '/assets/images/nvidia-aspire-agentic-skill-discovery-slide-02.webp' | relative_url }})

NVIDIA GEAR 연구진이 2026년 6월 30일 공개한 **ASPIRE**(Agentic /Skills Discovery for Robotics, arXiv 2607.00272)는 정확히 이 지점을 겨냥합니다. ASPIRE의 발상은 단순하지만 강력합니다. 로봇에게 미리 정해진 정책을 주입하는 대신, 대형 언어 모델(LLM)이 로봇 제어 코드를 **직접 작성**하고, 그 코드를 실제 실행 환경에서 돌려 실패를 관찰하며, 반복적으로 수리한 뒤, 검증된 수리 경험을 **재사용 가능한 스킬(Skill)** 로 증류합니다. 경험이 버려지지 않고 복리처럼 쌓입니다.

이 글은 검증된 논문과 프로젝트 페이지를 근거로 ASPIRE의 구조와 실측 결과를 정리합니다. 그리고 이 흐름이 로봇공학만의 이야기가 아니라 소프트웨어 에이전트에도 그대로 적용된다는 점, 특히 ThakiCloud의 Agent-Native Cloud인 Paxis가 스킬을 일급 리소스로 다루는 방식과 어떻게 맞닿는지를 마지막에 짚습니다.

## ASPIRE는 무엇인가

ASPIRE는 **code-as-policy** 패러다임 위에 지속 학습(continual learning) 루프를 얹은 시스템입니다. 전통적인 로봇 학습은 대량의 시연 데이터로 신경 정책을 훈련하고, 새 상황을 만나면 다시 데이터를 모아 재훈련하는 방식이 많았습니다. 여기에는 두 가지 부담이 따릅니다. 데이터 수집 비용이 크고, 한 번 학습한 지식이 새로운 변형 앞에서 쉽게 무너집니다.

ASPIRE는 정책을 신경망 가중치가 아니라 **실행 가능한 코드**로 표현합니다. LLM이 과제를 받아 제어 프로그램을 작성하면, 그 프로그램이 시뮬레이션 또는 실제 로봇에서 실행됩니다. 실행이 실패하면 ASPIRE는 실행 궤적을 기록하고, 실패 원인을 분석하며, 프로그램을 고쳐 다시 시도합니다. 이 반복이 성공에 도달하면, 그 과정에서 검증된 수리 지식이 스킬 라이브러리에 저장됩니다. 다음 과제는 빈손이 아니라 이 라이브러리를 참조해 시작합니다.

![패러다임의 전환: 대규모 시연 데이터로 학습하는 블랙박스 신경망 정책에서, 실패를 연료 삼아 사람이 읽을 수 있는 코드로 스킬을 쌓는 code-as-policy로]({{ '/assets/images/nvidia-aspire-agentic-skill-discovery-slide-03.webp' | relative_url }})

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
<div class="d3-arch" data-arch-root id="ireagenticskilldiscovery-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 551, "height": 774, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 159, "y": 24, "w": 120, "h": 46, "title": "과제 지시"}, {"id": "B", "x": 155, "y": 148, "w": 128, "h": 62, "title": ["LLM이 제어 코드 작성", "code-as-policy"]}, {"id": "C", "x": 252, "y": 288, "w": 120, "h": 62, "title": ["실제 실행", "시뮬레이션 또는 로봇"]}, {"id": "D", "x": 296, "y": 428, "w": 138, "h": 52, "title": "성공 여부"}, {"id": "E", "x": 391, "y": 572, "w": 128, "h": 46, "title": "궤적 기록·실패 원인 분석"}, {"id": "F", "x": 252, "y": 696, "w": 120, "h": 46, "title": "프로그램 수리"}, {"id": "G", "x": 212, "y": 572, "w": 120, "h": 46, "title": "검증된 수리 경험 증류"}, {"id": "H", "x": 55, "y": 696, "w": 142, "h": 46, "title": "재사용 가능한 스킬 라이브러리"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [219, 70, 219, 148]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[260, 210], [312, 249], [312, 249], [312, 288]]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[336, 350], [365, 389], [365, 389], [365, 428]]}, {"src": "D", "dst": "E", "kind": "data", "label": "실패", "curve": [[398, 480], [455, 526], [455, 526], [455, 572]], "off": "50%"}, {"src": "E", "dst": "F", "kind": "data", "curve": [[455, 618], [455, 657], [455, 657], [365, 696]]}, {"src": "F", "dst": "C", "kind": "data", "curve": [[259, 696], [170, 595], [170, 454], [252, 349]]}, {"src": "D", "dst": "G", "kind": "data", "label": "성공", "curve": [[332, 480], [272, 526], [272, 526], [272, 572]], "off": "50%"}, {"src": "G", "dst": "H", "kind": "data", "curve": [[272, 618], [272, 657], [272, 657], [180, 696]]}, {"src": "H", "dst": "B", "kind": "event", "label": "다음 과제가 참조", "curve": [[99, 696], [53, 526], [53, 319], [155, 206]], "off": "50%"}]});
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
      const container = document.getElementById('ireagenticskilldiscovery-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ireagenticskilldiscovery-1';
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

핵심은 마지막 화살표입니다. 스킬 라이브러리가 다음 과제 작성의 입력으로 되돌아가면서, 시스템은 시간이 지날수록 더 나은 코드를 더 빨리 씁니다. 논문은 이렇게 쌓인 지식이 그리퍼 복구 휴리스틱, 내비게이션 전략, 프롬프트 레시피, 절차적 수정 같은 형태로 과제를 넘나들며 **전이(transfer)** 된다고 설명합니다. 특정 과제 하나를 잘 푸는 것이 아니라, 푸는 능력 자체가 축적됩니다.

## 실패를 스킬로 증류하는 루프

ASPIRE를 다른 로봇 학습과 구분하는 지점은 실패를 다루는 방식입니다. 대부분의 파이프라인에서 실패는 폐기 대상이거나, 기껏해야 보상 신호를 깎는 음의 신호입니다. ASPIRE는 실패를 **학습 재료**로 봅니다. 실패한 실행의 궤적에는 "무엇이 왜 어긋났는가"라는 정보가 들어 있고, LLM은 이 정보를 읽어 코드를 어디서 어떻게 고쳐야 하는지 추론합니다.

이 수리가 한 번의 임기응변으로 끝나면 의미가 제한적입니다. ASPIRE의 기여는 검증된 수리를 **일반화 가능한 스킬로 증류**하는 데 있습니다. 예를 들어 특정 물체를 집다가 미끄러진 실패를 고쳐 성공했다면, 그 복구 절차는 그 물체에만 묶이지 않고 유사한 파지 상황에 재적용될 수 있는 형태로 추상화됩니다. 스킬은 텍스트로 표현된 코드 조각이므로 사람이 읽고 감사할 수 있고, 라이브러리로 관리하며 버전을 매길 수 있습니다. 이는 블랙박스 신경 정책과 대비되는 큰 장점입니다.

이 구조 덕분에 ASPIRE는 **추가 학습 데이터 없이** 성능을 끌어올립니다. 새 시연을 수집해 모델을 재훈련하는 대신, 실행-실패-수리-증류 루프를 반복하는 것만으로 성공률이 오릅니다. 데이터 수집이 병목인 로봇공학에서 이는 실무적으로 중요한 성질입니다.

## 실제 실험 결과

논문과 프로젝트 페이지가 보고한 수치는 이 루프가 단순한 개념 이상임을 보여 줍니다. 가장 인상적인 결과는 Robosuite의 양팔 물체 핸드오버(bimanual object handover) 과제입니다. 기본 성공률 **20%**에서 시작해, 반복적 디버깅만으로 **92%**까지 올랐습니다. 추가 시연 데이터를 전혀 넣지 않고, 실행-수리 루프만으로 도달한 수치입니다.

![추가 데이터 없는 성능의 도약: Robosuite 양팔 핸드오버 20%에서 92%로, LIBERO-Pro 최대 77%·Robosuite 72%·BEHAVIOR-1K 최대 32% 향상]({{ '/assets/images/nvidia-aspire-agentic-skill-discovery-slide-05.webp' | relative_url }})

과제 유형을 넓혀도 이점이 유지됩니다. 논문은 ASPIRE가 선행 방법 대비 다음과 같은 향상을 보였다고 보고합니다. 교란(perturbation)이 가해진 조작 과제인 LIBERO-Pro에서 **최대 77%**, Robosuite 양팔 핸드오버에서 **72%**, 장기 지평(long-horizon) 가사 과제인 BEHAVIOR-1K에서 **최대 32%**의 성능 우위입니다. 특히 장기 과제 일반화 실험에서는 스킬 라이브러리가 커질수록 성공률이 꾸준히 올랐다고 합니다. 라이브러리의 성장과 성능의 상승이 함께 간다는 점은, 경험이 실제로 복리로 쌓인다는 이 시스템의 핵심 주장을 뒷받침합니다.

연구진은 NVIDIA GEAR 연구실을 중심으로 미시간대(UMich), 일리노이대(UIUC), UC 버클리, 카네기멜런대(CMU) 소속 연구자들로 구성됩니다. NVIDIA는 릴리스 시점에 ASPIRE의 스킬 라이브러리를 오픈소스로 공개한다고 밝혔으며, 상세는 프로젝트 페이지(research.nvidia.com/labs/gear/aspire)에서 확인할 수 있습니다. 다만 코드 저장소의 구체적 라이선스는 공개 시점 기준으로 명시가 확인되지 않아, 도입 전에는 실제 저장소의 라이선스 조항을 직접 확인하는 편이 안전합니다.

## ThakiCloud 제품 적용 시사점

ASPIRE의 대상은 로봇 팔이지만, 그 아키텍처가 던지는 메시지는 소프트웨어 에이전트에 그대로 옮겨집니다. "에이전트가 코드를 쓰고, 실패에서 배우며, 검증된 경험을 재사용 가능한 스킬로 증류해 라이브러리에 쌓는다"는 문장에서 '로봇'을 '클라우드 에이전트'로 바꾸면, 그것이 바로 ThakiCloud의 Agent-Native Cloud인 **Paxis**가 지향하는 구조입니다.

Paxis는 Skills·Tools·Policies·Audit Logs를 일급 리소스로 다룹니다. ASPIRE의 스킬 라이브러리가 Paxis에서는 BM25로 선택되는 960여 개의 스킬 하니스에 해당하고, ASPIRE의 code-as-policy 실행은 Paxis의 격리 샌드박스 실행에 대응합니다. ASPIRE가 실패 궤적을 기록하고 분석하듯, Paxis는 모든 에이전트 행동을 정책 게이트와 감사 로그로 통과시켜 무엇이 왜 실패했는지 소급 추적할 수 있게 합니다. 그리고 ASPIRE의 증류 루프가 지향하는 자기 개선은 Paxis의 자가진화 스킬로 구현됩니다. 실행에서 얻은 교훈이 새 스킬이나 스킬 개정으로 되돌아가, 다음 실행이 빈손에서 시작하지 않게 만드는 흐름입니다.

![물리적 로봇에서 클라우드 에이전트로: ASPIRE의 스킬 라이브러리·코드 실행·실패 궤적 추적·증류가 각각 Paxis의 BM25 스킬 하니스·격리 샌드박스·감사 로그·자가진화 스킬에 대응]({{ '/assets/images/nvidia-aspire-agentic-skill-discovery-slide-06.webp' | relative_url }})

인프라 관점에서는 ThakiCloud의 **ai-platform**이 이 루프의 토대를 제공합니다. ASPIRE류의 반복 실행-수리 루프는 시뮬레이션과 추론을 대량으로 돌려야 하므로 GPU 자원의 탄력적 스케줄링이 전제됩니다. ai-platform은 Kueue 기반 GPU 스케줄링과 멀티테넌트 격리 위에서 이런 반복 워크로드를 비용 효율적으로 수용하도록 설계되어 있습니다. 저비용 서빙이 에이전트의 실행-수리 반복을 경제적으로 만들고, 그렇게 쌓인 스킬이 다시 에이전트의 자율성을 높이는 선순환입니다. 온프레미스와 소버린 환경을 요구하는 고객에게는 이 전체 루프를 자체 인프라 안에서 돌릴 수 있다는 점이 특히 의미가 있습니다.

![루프를 가동하는 인프라 엔진: ai-platform의 Kueue 기반 탄력적 GPU 할당, 멀티테넌트 격리, 온프레미스·소버린을 지원하는 저비용 서빙]({{ '/assets/images/nvidia-aspire-agentic-skill-discovery-slide-07.webp' | relative_url }})

## 한계 및 반론

ASPIRE의 결과가 인상적이더라도 몇 가지 유보가 필요합니다. 첫째, 보고된 수치는 대부분 시뮬레이션 벤치마크(Robosuite, LIBERO-Pro, BEHAVIOR-1K)에서 나온 것입니다. 시뮬레이션에서의 반복 디버깅은 값싸고 안전하지만, 실제 하드웨어에서는 매 시도가 시간과 마모, 안전 리스크를 수반합니다. 실행-실패-수리 루프의 경제성이 실물 로봇에서도 유지되는지는 별도의 검증이 필요합니다.

![한계점과 경계선: 시뮬레이션과 현실의 간극, 저수준 제어의 한계, 스킬 라이브러리 비대화]({{ '/assets/images/nvidia-aspire-agentic-skill-discovery-slide-08.webp' | relative_url }})

둘째, code-as-policy는 LLM이 유효한 제어 코드를 쓸 수 있는 과제에서 강하지만, 정밀한 연속 제어나 고빈도 피드백이 필요한 동작에서는 코드로 표현하기 어려운 영역이 남습니다. ASPIRE는 이런 저수준 제어를 기존 스킬이나 프리미티브에 위임하는 것으로 보이며, 그 프리미티브의 품질이 전체 성능의 상한을 정할 수 있습니다.

셋째, 스킬 라이브러리가 커질수록 검색과 선택의 부담이 늘어납니다. 라이브러리 성장이 성능 상승과 함께 간다는 결과는 고무적이지만, 규모가 더 커졌을 때 잘못된 스킬을 고르거나 오래된 스킬이 오답을 유발하는 문제가 없는지는 지속적으로 지켜봐야 합니다. 이는 Paxis의 스킬 하니스가 이미 마주한 과제이기도 하며, BM25 선택과 정책 게이트, 감사 로그가 바로 이 위험을 관리하기 위한 장치입니다.

그럼에도 ASPIRE가 제시한 방향, 즉 실패를 버리지 않고 검증된 스킬로 복리처럼 쌓는다는 원칙은 로봇과 소프트웨어 에이전트 양쪽에서 앞으로 표준이 될 가능성이 큽니다. 능력을 데이터가 아니라 축적된 스킬로 키운다는 관점의 전환이 이 연구의 진짜 기여입니다.

## 출처

- ASPIRE: Agentic /Skills Discovery for Robotics, arXiv 2607.00272: <https://arxiv.org/abs/2607.00272>
- 프로젝트 페이지 (NVIDIA GEAR): <https://research.nvidia.com/labs/gear/aspire/>
- 논문 페이지 (Hugging Face): <https://huggingface.co/papers/2607.00272>
