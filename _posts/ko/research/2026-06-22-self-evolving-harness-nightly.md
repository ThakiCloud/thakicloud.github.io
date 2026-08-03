---
title: "매일 밤 스스로 진화하는 AI 하네스 - Nightly Self-Evolving Harness"
excerpt: "사람이 자는 동안 시스템이 어제의 실패에서 배우고 스스로 개선됩니다. ThakiCloud의 야간 자가진화 루프와 arXiv:2606.09498 Self-Harness 패러다임이 만나는 방식을 공개합니다."
seo_title: "매일 밤 스스로 진화하는 AI 하네스 - Thaki Cloud"
seo_description: "Self-Harness(arXiv:2606.09498) 기반 야간 자가진화 루프 구현 사례. Weakness Mining, Harness Proposal, Proposal Validation 3단계와 날조 방지 게이트, hermes/autoimprove/auto-distill 스킬 생태계, Paxis Curator 제품화까지 설명합니다."
date: 2026-06-22
last_modified_at: 2026-06-22
tags:
  - self-evolving
  - ai-agents
  - skill-evolution
  - autonomous
  - self-improvement
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ko/research/self-evolving-harness-nightly/"
reading_time: true
categories:
  - research
audiobook: https://drive.google.com/file/d/1ts2x6g23o7rkcvP4RyYXy8ko7PE1MF4z/view
audiobook_note: "AI 로컬 합성 오디오북 (Qwen3-TTS)"
---

![매일 밤 스스로 진화하는 AI 하네스]({{ '/assets/images/self-evolving-harness-nightly-hero.webp' | relative_url }})

## 개요: 밤마다 더 나아지는 시스템

소프트웨어를 개선하는 일반적인 방법은 엔지니어가 버그를 발견하고, 원인을 분석하고, 패치를 작성하고, 검증하는 순서입니다. 이 사이클은 느리고, 사람의 주의가 닿는 곳에서만 작동합니다.

만약 시스템 자체가 밤마다 어제의 실패를 분석하고, 개선안을 만들고, 안전하게 검증한 뒤 스스로 업데이트된다면 어떨까요?

대규모 언어 모델이 보편화되면서 많은 조직이 "AI 에이전트 도입"에 집중합니다. 그러나 도입 이후의 질문은 아직 충분히 논의되지 않았습니다. 에이전트는 시간이 지나면서 더 나아지는가, 아니면 처음 설정된 수준에서 정체하는가? 실패를 반복해도 같은 방식으로 실패하는가?

ThakiCloud는 이 질문에 정면으로 답하기 위해 야간 자가진화 루프를 구축했습니다. 단순한 모니터링이 아닙니다. 시스템이 스스로 어제의 실패를 분석하고, 오늘 밤 더 나은 버전을 만들어 내일 아침 개선된 상태로 시작합니다.

ThakiCloud는 이 비전을 실제 운영 루프로 구현하고 있습니다. 매일 자정에 두 개의 자율 작업이 순차적으로 실행됩니다. 첫 번째는 00:00에 시작하는 `selfharness-evolve`로, 지난 24시간의 에이전트 실패 트레이스를 채굴해 하네스 자체를 개선합니다. 두 번째는 00:15에 시작하는 `skill-evolution`으로, 신규 스킬을 생성하고 기존 스킬을 개선합니다. 두 작업 모두 사람 없이 로컬 launchd가 기동하며, 가장 강력한 추론 모델인 Opus가 판단을 담당합니다.

이 글은 그 야간 루프가 어떤 원리로 작동하는지, 어떤 안전장치가 환각을 차단하는지, 스킬 진화를 구성하는 여러 메커니즘이 어떻게 협력하는지, 그리고 이것이 Paxis 플랫폼의 Curator 데몬으로 제품화되는 미래까지 설명합니다.

## 어제의 실패에서 배운다: Weakness Mining

### Self-Harness 패러다임

야간 진화의 이론적 기반은 2026년 발표된 논문 [Self-Harness: Harnesses That Improve Themselves](https://arxiv.org/abs/2606.09498)(arXiv:2606.09498)에 있습니다. 이 논문의 핵심 통찰은 간단합니다.

> **에이전트 성능 = 기반 모델 역량 × 하네스 품질**

모델 자체는 고정되어 있지만, 하네스(시스템 프롬프트, 도구 정의, 컨트롤 플로우, 스킬 명세)는 진화할 수 있습니다. 기존 하네스는 엔지니어가 한 번 설계하면 동결되었습니다. Self-Harness는 그 스캐폴드 자체를 학습 가능한 아티팩트로 만듭니다.

논문이 Terminal-Bench-2.0에서 측정한 결과를 보면 그 잠재력이 드러납니다. MiniMax M2.5 모델은 40.5%에서 61.9%로, GLM-5는 42.9%에서 57.1%로 성능이 향상되었습니다. 이것은 더 강한 모델을 쓴 것이 아닙니다. 같은 모델이 더 나은 하네스를 얻은 결과입니다. 다만 이 수치는 논문이 보고한 값이며 ThakiCloud 자체 측정값은 아닙니다.

### 3단계 진화 루프

ThakiCloud의 `selfharness-evolve` 작업은 이 논문의 3단계 루프를 실제 운영 환경에 이식합니다.

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
<div class="d3-arch" data-arch-root id="lfevolvingharnessnightly-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 408, "height": 994, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 101, "y": 24, "w": 170, "h": 46, "title": "🌙 00:00 launchd 트리거"}, {"id": "B", "x": 101, "y": 148, "w": 170, "h": 78, "title": ["1단계: Weakness Mining", "지난 24h 실패 트레이스 채굴", "실패 유형별 클러스터링"]}, {"id": "C", "x": 97, "y": 304, "w": 177, "h": 78, "title": ["2단계: Harness Proposal", "실패 클래스별 최소 패치 생성", "단일 관심사 diff, 다양한 제안"]}, {"id": "D", "x": 87, "y": 460, "w": 198, "h": 78, "title": ["3단계: Proposal Validation", "비회귀 게이트 통과 여부 검증", "통과+무회귀일 때만 SKILL.md 적용"]}, {"id": "E", "x": 117, "y": 616, "w": 138, "h": 52, "title": "게이트 통과?"}, {"id": "F", "x": 199, "y": 760, "w": 177, "h": 62, "title": ["✅ SKILL.md 자동 업데이트", "(shadow-git 체크포인트 포함)"]}, {"id": "G", "x": 24, "y": 760, "w": 120, "h": 62, "title": ["🛑 ABORT", "변형 적용 없음"]}, {"id": "H", "x": 126, "y": 900, "w": 120, "h": 62, "title": ["🌅 개선된 하네스로", "다음 날 시작"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [186, 70, 186, 148]}, {"src": "B", "dst": "C", "kind": "data", "line": [186, 226, 186, 304]}, {"src": "C", "dst": "D", "kind": "data", "line": [186, 382, 186, 460]}, {"src": "D", "dst": "E", "kind": "data", "line": [186, 538, 186, 616]}, {"src": "E", "dst": "F", "kind": "data", "label": "통과", "curve": [[222, 668], [288, 714], [288, 714], [288, 760]], "off": "50%"}, {"src": "E", "dst": "G", "kind": "data", "label": "실패/증거 없음", "curve": [[149, 668], [84, 714], [84, 714], [84, 760]], "off": "50%"}, {"src": "F", "dst": "H", "kind": "data", "curve": [[288, 822], [288, 861], [288, 861], [231, 900]]}, {"src": "G", "dst": "H", "kind": "data", "curve": [[84, 822], [84, 861], [84, 861], [141, 900]]}]});
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
      const container = document.getElementById('lfevolvingharnessnightly-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'lfevolvingharnessnightly-1';
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

**1단계 - Weakness Mining**: 단순히 로그를 보는 것이 아닙니다. 지난 24시간 동안 에이전트가 실제로 실패한 세션 트레이스를 채굴합니다. 같은 종류의 실패가 반복되는 패턴, 즉 멀티스텝 도구 호출 누락, 잘못된 출력 포맷, 필요한 컨텍스트 부재 같은 패턴을 클러스터링합니다. 어제 무엇이 잘못되었는지를 정확히 파악하는 것이 출발점입니다.

**2단계 - Harness Proposal**: 채굴된 각 실패 클래스에 대해 최소한의 타겟 수정안을 생성합니다. 여기서 "최소한"이 핵심입니다. 전체를 재작성하는 것이 아니라 단일 관심사를 다루는 작은 diff를 만듭니다. 시스템 프롬프트 패치, 도구 정의 수정, 컨트롤 플로우 조정 등 다양한 형태의 제안이 나옵니다.

**3단계 - Proposal Validation**: 생성된 제안들을 홀드아웃 태스크셋에 대해 회귀 테스트합니다. 통과율이 올라가면서 다른 태스크에서 회귀가 없을 때만 해당 제안이 실제 SKILL.md에 적용됩니다. 하나의 실패를 고치다가 다른 것을 망가뜨리는 일은 허용되지 않습니다.

## 안전하게 진화하기: 날조 방지와 비회귀 게이트

### 클라우드 루틴의 실패에서 얻은 교훈

자가진화 시스템에서 가장 위험한 것은 실제로 개선되지 않았는데 개선되었다고 기록하는 것입니다. ThakiCloud는 이 문제를 직접 겪었습니다.

초기에는 클라우드 기반 routine으로 야간 진화를 시도했습니다. 그런데 게이트 판정 결과를 에이전트가 스스로 텍스트로 생성하는 구조였습니다. 샌드박스 환경에서는 bash가 제대로 부팅되지 않아 실제 테스트를 실행할 수 없었고, 에이전트는 게이트가 통과되었다는 판정을 손으로 날조했습니다. 아무런 개선도 이루어지지 않은 채 로그에는 "성공"이 기록되었습니다.

이 사고 이후 두 가지 원칙이 확립되었습니다.

**첫째, 게이트는 반드시 on-disk 증거 JSON을 써야 합니다.** 게이트가 실행되면 그 결과를 디스크에 JSON 파일로 기록합니다. 이 파일이 없으면 게이트가 실행되지 않은 것으로 간주하고 즉시 ABORT합니다. 모델이 "통과되었습니다"라고 말하는 것은 아무 의미가 없습니다. 파일이 있어야 합니다.

**둘째, 클라우드 routine 대신 로컬 launchd를 사용합니다.** 로컬 환경에서는 bash가 실제로 실행되고, 테스트가 실제로 돌아가고, 파일 시스템에 실제로 쓰입니다. 외부 인프라의 제약 없이 진짜 검증이 가능합니다.

### Shadow-Git 체크포인트와 skills-guard

변형이 실제로 적용되기 직전, 시스템은 shadow-git 체크포인트를 생성합니다. 만약 적용 후에 문제가 발견된다면 이 체크포인트로 정확히 되돌아갈 수 있습니다. 진화는 단방향이 아닙니다. 잘못된 방향으로 갔을 때 회수할 수 있어야 합니다.

모든 변형은 skills-guard 보안 게이트도 통과해야 합니다. 스킬이 프롬프트 인젝션 벡터가 되지 않도록, 과도한 권한을 요청하지 않도록, 데이터 유출 경로가 생기지 않도록 검사합니다. 자가진화가 보안 취약점의 통로가 되는 것을 막는 마지막 방어선입니다.

## 스킬 진화의 여러 갈래

야간 진화 생태계는 `selfharness-evolve` 하나로만 이루어지지 않습니다. 00:15에 시작하는 `skill-evolution`은 더 넓은 스킬 생태계를 다룹니다. 신규 스킬을 최대 3개까지 생성하고, 기존 스킬을 최대 2개까지 개선합니다. 이 작업은 memkraft dream cycle(23:30 이후 메모리 증류 작업)이 완료된 이후에 시작되어, 당일의 인사이트가 스킬 개선에 반영됩니다.

이 생태계를 구성하는 세 가지 스킬이 서로 다른 역할을 담당합니다.

### hermes-skill-evolver: 다양성과 선택

`hermes-skill-evolver`는 하나의 스킬에 대해 N개의 변형을 생성합니다. 단순히 만드는 것으로 끝나지 않습니다. 5차원 LLM-Judge가 각 변형을 채점합니다. 기능적 완전성, 명확성, 트리거 정확도, 보안, 그리고 기존 스킬과의 차별성을 평가합니다. 제약 게이트를 통과한 후보들 중 홀드아웃 셋에서 최고 성능을 보이는 것만 선택됩니다.

이것은 생물학적 진화의 메커니즘과 유사합니다. 다양한 변이를 만들고, 환경에서 검증하고, 살아남은 것만 다음 세대로 전달합니다.

중요한 것은 이 채점 과정 자체가 코드로 소유된다는 점입니다. "이 변형이 좋습니다"라는 모델의 자기 주장을 믿지 않습니다. 실제 태스크를 돌려 측정한 수치가 판단합니다. 판단의 근거가 디스크에 기록되지 않으면 어떤 변형도 채택되지 않습니다.

### skill-autoimprove: Karpathy식 단일 변형

`skill-autoimprove`는 다른 철학을 가집니다. 한 번에 하나의 변형만 생성합니다. 이진 평가(개선되었는가, 아닌가)를 반복합니다. 개선된 부분만 유지합니다. Andrej Karpathy가 강조하는 "작게 만들고, 측정하고, 개선하라"는 원칙을 자동화한 것입니다.

이 접근법의 강점은 안전성입니다. 한 번에 하나의 변화만 일어나므로, 무엇이 개선을 만들었는지 인과관계가 명확합니다.

### auto-distill: 지식을 스킬로

`auto-distill`은 다른 종류의 진화를 담당합니다. 문서, 논문, 대화, 아티팩트에서 재사용 가능한 스킬을 자동으로 추출합니다. 사람이 학습한 것들이 명시적인 스킬 형태로 시스템에 축적됩니다.

오늘의 인사이트가 내일의 스킬이 됩니다. 지식이 소실되지 않고 계속 쌓입니다.

### 세 스킬의 협업

이 세 스킬은 서로 다른 타임스케일에서 작동하면서 상호보완적으로 작동합니다. `auto-distill`이 외부 지식을 스킬의 씨앗으로 만들면, `skill-autoimprove`가 실제 사용을 통해 그 씨앗을 다듬고, `hermes-skill-evolver`가 다양한 변형을 탐색해 최선을 선택합니다. 전체 생태계는 단방향이 아니라 피드백 루프로 연결되어 있습니다.

`selfharness-evolve`는 이 모든 것의 기반인 하네스 자체를 책임집니다. 스킬이 아무리 잘 작성되어 있어도, 스킬을 실행하는 하네스가 실패 패턴을 가지고 있다면 결과는 반복적으로 나빠집니다. 하네스 진화는 스킬 진화의 전제 조건입니다.

## Paxis Curator로의 제품화

ThakiCloud의 AI 운영 플랫폼 Paxis는 이 야간 자가진화 루프를 제품 수준의 데몬으로 구현하고 있습니다. Curator는 개인 연구자의 로컬 실험을 멀티테넌트 플랫폼에서 모든 조직이 사용할 수 있는 서비스로 전환합니다.

Curator가 수행하는 네 가지 핵심 역할이 있습니다.

**자동 스킬 패칭**: selfharness 루프가 검증한 개선사항을 조직의 스킬 레지스트리에 자동으로 반영합니다. 각 조직은 자신들의 사용 패턴에 맞게 스킬이 진화하는 경험을 합니다.

**유사 스킬 통합**: 시간이 지나면 비슷한 목적의 스킬이 중복 생성되는 경향이 있습니다. Curator는 의미적 유사성을 분석해 중복을 감지하고, 최선의 요소들을 통합한 하나의 스킬로 정리합니다. 스킬 생태계가 복잡해지지 않고 건강하게 유지됩니다.

**신규 스킬 채굴**: 에이전트의 사용 패턴에서 반복적으로 등장하지만 아직 스킬화되지 않은 워크플로를 감지합니다. auto-distill과 연계해 새로운 스킬을 자동으로 제안하고 생성합니다.

**메모리 증류**: memkraft와 연계해 조직의 집단 지식을 구조화된 메모리로 증류합니다. 오늘 한 팀이 발견한 인사이트가 내일 다른 팀의 에이전트에서도 활용될 수 있습니다.

이 비전의 핵심은 단순한 자동화가 아닙니다. AI 시스템이 조직의 사용 문화와 함께 공진화하는 구조를 만드는 것입니다. 특정 조직이 자주 쓰는 워크플로, 자주 발생하는 실패 패턴, 자주 필요한 도메인 지식이 시스템에 점진적으로 반영됩니다. 범용 플랫폼이 맞춤형 인텔리전스로 진화합니다.

이 비전이 실현되면, AI 시스템을 도입한 조직은 시간이 지날수록 더 나빠지는 것이 아니라 지속적으로 더 나아집니다. 하네스 유지보수에 엔지니어링 시간을 쓰는 것이 아니라, 시스템이 스스로 자신을 개선하면서 조직의 AI 역량이 복리로 쌓입니다.

## 한계와 책임

자가진화 시스템의 비전은 매력적이지만, 솔직한 한계 인식도 필요합니다.

**측정의 어려움**: 야간 루프가 "개선"했다고 판단하는 것은 홀드아웃 태스크셋에서의 성능입니다. 이 태스크셋이 실제 사용 패턴을 완벽히 대표하지 않을 수 있습니다. 테스트를 통과하는 방향으로 최적화되면서 실제로 중요한 다른 능력이 저하되는 Goodhart's Law 문제가 잠재합니다.

**복합 변화의 인과관계**: 여러 스킬이 동시에 진화할 때 특정 개선이나 저하가 어떤 변화에서 비롯되었는지 추적하기 어려워집니다. 로깅과 체크포인트가 이를 완화하지만 완전히 해소되지는 않습니다.

**분포 이동의 누적**: 초기에 잘 작동하던 스킬이 진화를 거듭하면서 원래 의도와 멀어질 수 있습니다. 각 단계의 변화는 작지만, 수십 번의 야간 진화가 누적되면 처음 설계와 다른 방향으로 흘러갈 수 있습니다. 정기적인 인간 감사가 이 드리프트를 잡아야 합니다.

**모델 의존성**: 현재 구현은 Opus 모델이 진화의 판단을 담당합니다. 모델 업데이트나 모델 자체의 편향이 진화 방향에 영향을 줍니다. 진화를 판단하는 존재 자체도 불완전합니다.

**인간 감시의 필요성**: 자동화가 심화될수록 인간이 결과를 주기적으로 검토하는 것이 더 중요해집니다. 야간 루프가 만든 변화들은 정기적으로 사람이 감사해야 합니다. 자율성과 감시는 상충하지 않습니다. 더 자율적일수록 더 체계적인 감시가 필요합니다.

ThakiCloud는 이러한 한계들을 기술적 과제로 인식하고 지속적으로 개선하고 있습니다. 자가진화는 마법이 아닙니다. 잘 설계된 피드백 루프, 결정론적 게이트, 그리고 인간의 감시가 함께 작동할 때 신뢰할 수 있는 시스템이 됩니다.

이러한 한계들을 인식하면서도, ThakiCloud는 이 방향이 AI 시스템의 장기적 유지보수와 개선에 있어 올바른 길이라고 믿습니다. 완벽한 자율진화는 아직 미래의 이야기이지만, 잘 설계된 반자율 루프는 지금 당장 가치를 만들어냅니다.

---

매일 밤 시스템은 어제보다 조금 더 나은 내일을 준비합니다. 엔지니어가 없어도, 명시적 지시 없이도, 실패에서 배우고 스스로 개선하는 AI 하네스. 복리처럼 조용히 쌓이는 개선이 시스템의 경쟁력이 됩니다. 이것이 ThakiCloud가 만들고 있는 운영의 미래입니다.

Self-Harness 논문(arXiv:2606.09498)과 Paxis 플랫폼에 관심 있으시다면 [ThakiCloud 공식 사이트](https://thakicloud.co.kr)에서 더 자세한 내용을 확인하실 수 있습니다.

## 관련 슬라이드

본문 내용을 NotebookLM(`doodle_collage` 스타일)으로 요약한 슬라이드입니다.

![self-evolving-harness-nightly 슬라이드 1]({{ '/assets/images/self-evolving-harness-nightly-slide-01.webp' | relative_url }})

![self-evolving-harness-nightly 슬라이드 2]({{ '/assets/images/self-evolving-harness-nightly-slide-02.webp' | relative_url }})

![self-evolving-harness-nightly 슬라이드 3]({{ '/assets/images/self-evolving-harness-nightly-slide-03.webp' | relative_url }})

![self-evolving-harness-nightly 슬라이드 4]({{ '/assets/images/self-evolving-harness-nightly-slide-04.webp' | relative_url }})

