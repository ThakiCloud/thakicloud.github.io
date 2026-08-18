---
title: "스킬 1,600개를 노이즈 없이 라우팅하는 법 - AI 에이전트 스킬 생태계 운영기"
excerpt: "스킬은 많을수록 좋은 게 아니라 세금입니다. Claude Code 기반 1,620개 스킬을 1인 운영하며 SRA + BM25 게이트로 노이즈를 걸러낸 라우팅 설계와 실측 벤치를 공개합니다."
seo_title: "AI 에이전트 스킬 1600개 라우팅 설계 - Skill Retrieval Augmentation - Thaki Cloud"
seo_description: "스킬이 많다고 좋은 게 아닙니다. Claude Code 기반 1,620개 스킬 생태계에서 SRA + BM25 게이트로 노이즈를 제거한 라우팅 설계와 실측 벤치를 공개합니다."
date: 2026-06-22
last_modified_at: 2026-06-22
tags:
  - skill-routing
  - ai-agents
  - retrieval-augmentation
  - claude-code
  - bm25
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ko/dev/skill-ecosystem-routing-sra/"
reading_time: true
categories:
  - dev
audiobook: /assets/audio/posts/skill-ecosystem-routing-sra/audiobook-ko.mp3
audiobook_note: "AI 로컬 합성 오디오북 (Qwen3-TTS)"
---

![스킬 생태계 라우팅 SRA 히어로 이미지]({{ '/assets/images/skill-ecosystem-routing-sra-hero.webp' | relative_url }})

AI 에이전트에 스킬을 계속 추가하고 있는 운영자라면 이 글이 도움이 됩니다. 결론부터 말하면, 스킬이 많을수록 에이전트가 강해진다는 직관은 틀렸고 라우팅이 없으면 스킬은 그냥 세금입니다.

ThakiCloud의 Claude Code 기반 에이전트 인프라는 지금 로컬 스킬 약 1,620개, 서브에이전트 55개, always-on 룰 36개, 슬래시 커맨드 22개, 훅 12개가 함께 돌아갑니다. 이 규모에 도달하면 스킬을 하나 더 넣는 일이 이득이 아니라 손해가 되는 지점이 옵니다. 모델이 관련 없는 스킬 이름들 사이에서 길을 잃고, 이름이 조금 겹치는 엉뚱한 스킬을 집어들거나, 아예 아무 스킬도 안 쓰고 날것으로 답하기 시작합니다.

## 스킬이 많으면 왜 느려지나

Claude Code의 컨텍스트 창은 유한합니다. 1,620개 스킬의 이름과 짧은 설명만 나열해도 수만 토큰입니다. 이걸 매 턴 주입하면 실제 작업에 쓸 토큰이 줄고 비용은 폭증합니다. 더 나쁜 건 정확도가 함께 떨어진다는 점입니다. "버그 고쳐줘"라는 간단한 요청에 `4phase-debugging` 스킬이 딸려 나와 복잡한 워크플로를 돌리거나, 단순 파일 편집에 `technical-writer`가 튀어나오는 억지 매칭이 스킬 수에 비례해 잦아집니다.

SRA 논문(arXiv:2604.24594)은 이를 "1,000개 이상 스킬 환경에서 디스트랙터 노이즈가 정확도의 주요 위험"이라고 정의합니다. 처방은 분명합니다. 스킬 전체를 매번 보여주지 말고, 지금 요청에 실제로 관련 있는 소수 후보만 걸러서 보여주면 됩니다.

## SRA + BM25 2단 게이트

ThakiCloud가 쓰는 구조는 SRA 논문의 3단계 프로토콜에 BM25 자동 게이트를 결합한 것입니다.

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
<div class="d3-arch" data-arch-root id="skillecosystemroutingsra-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 694, "height": 986, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 251, "y": 24, "w": 120, "h": 46, "title": "사용자 요청 도착"}, {"id": "B", "x": 242, "y": 148, "w": 138, "h": 68, "title": ["프리필터", "인사/명령/동일 턴?"]}, {"id": "C", "x": 338, "y": 316, "w": 120, "h": 46, "title": "토큰 0 패스스루"}, {"id": "D", "x": 163, "y": 308, "w": 120, "h": 62, "title": ["BM25 자동 검색", "retrieve.py"]}, {"id": "E", "x": 154, "y": 448, "w": 139, "h": 68, "title": ["SCORE_MIN 6.0", "이상 후보 있나?"]}, {"id": "F", "x": 244, "y": 616, "w": 149, "h": 46, "title": "후보 없음 = Native 실행"}, {"id": "G", "x": 69, "y": 608, "w": 120, "h": 62, "title": ["TOP_K 5 후보", "컨텍스트 주입"]}, {"id": "H", "x": 24, "y": 748, "w": 209, "h": 68, "title": ["모델 Triage", "Native vs Skill-worthy?"]}, {"id": "I", "x": 69, "y": 908, "w": 120, "h": 46, "title": "기본 도구로 직접 실행"}, {"id": "J", "x": 527, "y": 151, "w": 121, "h": 62, "title": ["Incorporation", "최적 스킬 1개 선택"]}, {"id": "worthy", "x": 528, "y": 24, "w": 120, "h": 46, "title": "worthy"}, {"id": "K", "x": 513, "y": 316, "w": 149, "h": 46, "title": "Skill 도구로 로드 및 실행"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [311, 70, 311, 148]}, {"src": "B", "dst": "C", "kind": "data", "label": "SKIP", "curve": [[348, 216], [398, 262], [398, 262], [398, 316]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "PROCEED", "curve": [[274, 216], [223, 262], [223, 262], [223, 308]], "off": "50%"}, {"src": "D", "dst": "E", "kind": "data", "line": [223, 370, 223, 448]}, {"src": "E", "dst": "F", "kind": "data", "label": "없음", "curve": [[264, 516], [318, 562], [318, 562], [318, 616]], "off": "50%"}, {"src": "E", "dst": "G", "kind": "data", "label": "있음", "curve": [[183, 516], [129, 562], [129, 562], [129, 608]], "off": "50%"}, {"src": "G", "dst": "H", "kind": "data", "line": [129, 670, 129, 748]}, {"src": "H", "dst": "I", "kind": "data", "label": "Native", "line": [129, 816, 129, 908], "lx": 129, "ly": 858}, {"src": "worthy", "dst": "J", "kind": "data", "line": [588, 70, 588, 151]}, {"src": "J", "dst": "K", "kind": "data", "line": [588, 213, 588, 316]}]});
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
      const container = document.getElementById('skillecosystemroutingsra-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'skillecosystemroutingsra-1';
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

첫 관문은 검색입니다. `skill-router-gate.py` 훅이 사용자가 프롬프트를 제출하는 `UserPromptSubmit` 순간에 먼저 실행됩니다. 인사나 단순 확인, 파일 경로를 직접 편집하는 순수 명령은 검색을 건너뛰고 토큰 0으로 통과시킵니다. `/review`, `/debug` 같은 명시적 트리거가 있으면 그 스킬로 바로 보냅니다. 그 외의 진짜 작업성 요청만 `retrieve.py`가 받아 BM25로 처리합니다. 이 엔진은 SKILL.md frontmatter와 에이전트 정의, 카탈로그를 미리 인덱싱해 두고, IDF 가중과 한영 교차 동의어 사전(25개 이상 어휘 쌍)으로 1,200개 이상의 스킬을 실시간으로 좁힙니다. 점수가 6.0 이상인 후보만 최대 5개를 뽑아 컨텍스트에 주입하고, 직전 턴과 같은 요청이면 재주입을 생략합니다.

다음은 모델의 분류입니다. 파일 편집이나 git 명령, grep, 코드 한 줄 수정처럼 내장 도구로 끝나는 일은 Native로 판단해 스킬 없이 바로 실행합니다. 구조화된 글쓰기나 멀티 도메인 리뷰, 파이프라인 오케스트레이션, 문서 생성처럼 체크리스트와 워크플로가 이득이 되는 일만 Skill-worthy로 넘깁니다. 애매하면 Native가 기본값입니다. 마지막으로 후보 중 하나를 고르고 이유를 한 문장으로 밝힌 뒤 로드합니다. 동점 후보가 둘 이상이면 사용자에게 물어보고, 마땅한 게 없으면 Native로 돌아갑니다. 억지로 끼워 맞추지 않습니다.

## description이 검색 정확도를 결정한다

BM25는 이름이 아니라 description 전문을 읽습니다. 그래서 description이 모호하면 비슷한 스킬들이 같은 점수를 받아 엉뚱한 후보가 올라옵니다. ThakiCloud는 모든 스킬에 세 문장 형식을 강제합니다. 첫 문장은 이 스킬이 무엇을 하는지 동사 하나로 정의하고, 둘째 문장은 영어와 한국어 트리거 키워드를 모두 담습니다. 한쪽 언어만 넣으면 그 언어로 들어온 요청의 절반을 놓칩니다. 셋째 문장은 경계입니다. "이 스킬로 오면 안 되는 경우"와 "그 대신 써야 하는 인접 스킬"을 못박아 유사 스킬 간 혼선을 끊습니다. description은 인덱싱 효율과 주입 비용을 고려해 1,024자 이내로 제한합니다.

여기서 얻은 교훈이 하나 있습니다. 이름이 그럴싸하면 대충 써도 찾아줄 거라는 생각은 착각입니다. 이름이 아무리 멋져도 description에 트리거가 없으면 검색에 안 걸립니다.

## 측정: 무엇이 개선됐나

아래 수치는 실운영 값이 아니라 63개 케이스 골드셋으로 잰 엔진의 잠재 정확도입니다. 운영 정확도는 다를 수 있습니다.

| 지표 | 수리 전 | 수리 후 |
|------|---------|---------|
| Recall@5 | 44.0% | 73.3% |
| Gated(게이트 통과율) | - | 53.3% |
| Top-1 정확도 | - | 31.1% |
| 환각(잘못된 스킬 로드) | 10.0% | 0.0% |

수리 전 Recall@5 44%는 관련 스킬이 후보 5개 안에 절반도 못 들어왔다는 뜻입니다. 모델이 아무리 잘 골라도 정답 자체가 없는 경우가 절반이었습니다. 이걸 73.3%까지 올렸고, 존재하지 않거나 완전히 무관한 스킬을 로드하는 환각은 0%로 떨어뜨렸습니다. 개선은 세 가지에서 나왔습니다. 한국어 트리거가 빠져 있던 스킬들을 일괄 보완했고, 인접 스킬끼리 겹쳐 점수 충돌을 일으키던 부분을 Do-NOT-use 절로 분리했으며, SCORE_MIN 임계값을 튜닝해 점수 낮은 노이즈가 컨텍스트에 새어드는 걸 막았습니다.

남은 숙제도 분명합니다. Top-1 정확도 31.1%는 후보 안에 정답이 있어도 모델이 최선을 고르지 못하는 경우가 많다는 뜻이고, 현재 천장은 대략 50%대로 [추정]합니다. 복합 요청은 더 약합니다. "리서치하고 팩트체크해서 docx로 만들어 슬랙에 올려줘" 같은 요청을 하나의 쿼리로 검색하면 뒤 단계 스킬이 누락됩니다. 12개 케이스 기준 단일 검색의 step_coverage는 32.8%에 그쳤고, 지금은 에이전트가 요청을 sub-task로 쪼개 각각 검색하는 방식으로 부분적으로만 보완하고 있습니다.

## 결국 하고 싶은 말

이 라우팅 구조는 ThakiCloud의 SaaS 제품 Paxis에서 그대로 일반화됩니다. 로컬에서는 운영자가 직접 description을 쓰고 벤치로 검증하지만, Paxis에서는 고객이 등록한 스킬끼리 충돌하지 않도록 description 품질을 자동 점검하는 게이트가 필요하고, 현재 개발 중입니다.

정리하면 스킬은 자산이 아니라 세금입니다. 컨텍스트 비용, 유지보수 비용, 라우팅 노이즈를 모두 늘립니다. 그래서 새 스킬을 만들기 전에 "이게 없으면 에이전트가 틀리나?"를 먼저 물어야 하고, 답이 "아니오"면 만들지 말아야 합니다. 1,620개 중 매일 실제로 쓰이는 스킬은 훨씬 적습니다. 나머지는 라우팅이 잘 되어 있을 때만 꺼내 쓸 수 있는 잠재 자산이고, 라우팅이 없으면 그저 노이즈입니다. SRA와 BM25 게이트, description 규율은 그 잠재 자산을 실제로 쓸 수 있게 만드는 인프라입니다. 완벽하지 않고 계속 고치는 중이지만, 방향은 맞습니다.
