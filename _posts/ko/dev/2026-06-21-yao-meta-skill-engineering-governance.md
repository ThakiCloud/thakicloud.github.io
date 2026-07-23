---
title: "스킬을 '소프트웨어처럼' 다루는 메타스킬: yao-meta-skill v1.1.0 직접 검증 리포트"
excerpt: "Anthropic 공식 Skill-creator보다 강력하다고 입소문이 난 오픈소스 메타스킬 yao-meta-skill을 ThakiCloud 환경에 직접 클론하고 로컬 검증 게이트를 돌렸습니다. Skill IR, Output Eval Lab, Review Studio 2.0의 구조를 실측 수치로 분해하고, 사내 .claude/skills 거버넌스 관점에서 시사점을 정리합니다."
seo_title: "yao-meta-skill v1.1.0 검증 리포트 - Thaki Cloud"
seo_description: "yao-meta-skill(YAO) 메타스킬을 직접 클론·검증한 실측 리포트. Skill IR 플랫폼 중립 표현, Output Eval Lab, Review Studio 2.0 거버넌스 게이트를 632파일·77테스트 규모로 분해하고 ThakiCloud .claude/skills 운영에 적용"
date: 2026-06-21
last_modified_at: 2026-06-21
tags:
  - claude-skills
  - meta-skill
  - skill-governance
  - skill-ir
  - agent-skills
  - evaluation
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
categories:
  - dev
published: false
canonical_url: "https://thakicloud.com/tech-blog/ko/dev/yao-meta-skill-engineering-governance/"
---

![모듈형 블록이 정밀 조립 라인을 이루고 거버넌스 게이트가 빛나는 추상 이미지]({{ '/assets/images/yao-meta-skill-hero.webp' | relative_url }})
*스킬을 일회성 프롬프트가 아니라 버전·검증·거버넌스가 붙은 '재사용 자산'으로 다루는 메타스킬의 개념도입니다.*

## 개요

Claude Code, Cursor, Codex CLI 같은 에이전트 환경에서 스킬(Skill)은 더 이상 단순한 프롬프트 모음이 아닙니다. 반복되는 업무를 패키징해 여러 하니스(harness)를 가로질러 재사용하는 능력 상품에 가깝습니다. 그런데 스킬이 늘어날수록 품질 편차, 트리거 충돌, 컨텍스트 비용이라는 세 가지 문제가 동시에 커집니다. 중국 인플루언서 @vista8(팔로워 약 113K)이 "Anthropic 공식 Skill-creator보다 강력하다"고 추천하면서 화제가 된 오픈소스 프로젝트 yao-meta-skill은 바로 이 지점을 정조준합니다.

이름의 YAO는 "Yielding AI Outcomes"의 약자이며, 저장소 설명은 스스로를 "재사용 가능한 에이전트 스킬을 위한 엄격한 엔지니어링·평가·거버넌스·이식성 시스템"이라고 규정합니다. 저는 이 주장을 그대로 받아들이지 않고 ThakiCloud 작업 환경에 직접 클론한 뒤, 저장소가 함께 제공하는 로컬 검증 게이트를 실제로 실행해 보았습니다. 이 글은 그 실측 결과를 바탕으로 yao-meta-skill의 구조를 분해하고, 사내 `.claude/skills` 운영 관점에서 무엇을 빌려올 수 있는지 정리한 구현 리포트입니다.

## 이 도구는 무엇인가

yao-meta-skill은 "스킬을 만들어 주는 스킬", 즉 메타스킬입니다. 워크플로 노트, 프롬프트 세트, 대화 트랜스크립트, 런북, 문서 패턴처럼 반복되는 작업을 입력으로 받아 검증 가능한 스킬 패키지로 변환합니다. 핵심 설계는 세 개의 기둥으로 정리됩니다.

첫째, **Skill IR(Intermediate Representation)** 입니다. 의도, 트리거, 입력, 출력, 경계(boundaries), 참조, 기대 산출물을 플랫폼 중립적인 중간 표현으로 먼저 기술합니다. 그다음 타깃 컴파일러와 어댑터가 이 IR을 OpenAI, Claude, 일반 에이전트 스킬, Agent-Skills 호환 패키지, VS Code 지향 워크플로 등 다섯 가지 타깃으로 변환합니다. 한 번 기술한 스킬을 여러 환경으로 컴파일한다는 발상은, 사내에서 같은 스킬을 Claude Code와 Cursor 양쪽에 중복 관리하던 부담을 정확히 겨냥합니다.

둘째, **Output Eval Lab** 입니다. 트리거 검사, 출력 단언(assertion), 실행 증거, 시간·토큰 증거, 벤치마크 재현성, 블라인드 리뷰 팩까지 스킬의 출력 품질을 데이터로 검증하는 계층입니다. 모델이 "잘 됐다"고 주장하는 대신 코드가 실제로 검증하는 구조라는 점이 인상적입니다.

셋째, **Review Studio 2.0** 입니다. 의도, 트리거, 출력 평가, 컨텍스트 비용, 런타임 점검, 릴리스 증거를 하나의 HTML 게이트 페이지로 모아 보여 줍니다. 스킬 하나를 릴리스하기 전에 무엇을 통과해야 하는지를 시각적으로 확정하는 관문입니다.

라이선스는 MIT이며, 매니페스트는 성숙도 등급을 "governed", 라이프사이클 단계를 "library", 리뷰 주기를 "quarterly"로 선언합니다. 스킬을 코드처럼 버전·등급·리뷰 주기로 관리하겠다는 의도가 메타데이터 수준에서부터 드러납니다.

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
<div class="d3-arch" data-arch-root id="illengineeringgovernance-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 205, "height": 722, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "IN", "x": 39, "y": 24, "w": 120, "h": 46, "title": "반복 작업 입력"}, {"id": "IR", "x": 39, "y": 148, "w": 120, "h": 46, "title": "Skill IR"}, {"id": "COMPILE", "x": 28, "y": 272, "w": 142, "h": 46, "title": "타깃 컴파일러 (다중 플랫폼)"}, {"id": "EVAL", "x": 31, "y": 396, "w": 135, "h": 46, "title": "Output Eval Lab"}, {"id": "REVIEW", "x": 24, "y": 520, "w": 149, "h": 46, "title": "Review Studio 2.0"}, {"id": "REL", "x": 39, "y": 644, "w": 120, "h": 46, "title": "릴리스 증거"}], "edges": [{"src": "IN", "dst": "IR", "kind": "data", "line": [99, 70, 99, 148]}, {"src": "IR", "dst": "COMPILE", "kind": "data", "line": [99, 194, 99, 272]}, {"src": "COMPILE", "dst": "EVAL", "kind": "data", "line": [99, 318, 99, 396]}, {"src": "EVAL", "dst": "REVIEW", "kind": "data", "line": [99, 442, 99, 520]}, {"src": "REVIEW", "dst": "REL", "kind": "data", "line": [99, 566, 99, 644]}]});
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
      const container = document.getElementById('illengineeringgovernance-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'illengineeringgovernance-1';
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
*반복 작업 입력이 Skill IR을 거쳐 다중 플랫폼으로 컴파일되고, Output Eval Lab과 Review Studio 게이트를 통과해 릴리스 증거로 마무리되는 파이프라인입니다.*

## 설치 및 통합 (실제 명령)

검증은 격리된 샌드박스에서 진행했습니다. 사내 규칙에 따라 작업 트리는 저장소 바깥에 두고, 종료 후 정리했습니다.

```bash
# 1) 외부 저장소 클론
git clone --depth 1 https://github.com/yaojingang/yao-meta-skill

# 2) 최소 의존성은 공용 .venv에 설치 (python-runtime 규칙)
VIRTUAL_ENV="$REPO_ROOT/.venv" uv pip install "PyYAML==6.0.3"
```

저장소의 의존성은 놀라울 만큼 가볍습니다. CI 요구 사항(`requirements-ci.txt`)은 `PyYAML==6.0.3` 단 한 줄이었습니다. 무거운 런타임 없이 순수 파이썬 표준 라이브러리 중심으로 검증 도구를 구성했다는 뜻이며, 이는 CI 파이프라인에 끼워 넣기 좋은 신호입니다.

저장소를 클론한 직후 측정한 실제 구성은 다음과 같습니다. 추적 파일 632개, 테스트 77개, 평가(evals) 29개, 스킬 아틀라스 항목 10개, 스키마 3개, 템플릿 2개입니다. 단일 "스킬 하나"가 아니라, 스킬을 생산·검증·거버넌스하는 작은 공장(factory)에 가깝습니다.

![yao-meta-skill 리포지토리 구성과 로컬 검증 게이트 결과 차트]({{ '/assets/images/yao-meta-skill-results.webp' | relative_url }})
*왼쪽은 저장소의 실측 구성(로그 스케일), 오른쪽은 로컬 검증 게이트 4종이 모두 통과한 결과입니다.*

## 실제 검증 결과

`Makefile`에는 25개가 넘는 검증 타깃이 정의되어 있었습니다. 그중 스킬 IR, 컴파일러, 출력 평가, 린트 네 가지를 실제로 돌려 결과를 캡처했습니다.

```bash
make skill-ir-check
# python3 tests/verify_skill_ir.py        -> {"ok": true}
# python3 tests/verify_skill_ir_paths.py  -> {"ok": true}

make compiler-check
# python3 tests/verify_compile_skill.py    -> {"ok": true}

make output-eval-check
# python3 tests/verify_output_eval_lab.py  -> {"ok": true}

python3 scripts/lint_skill.py ./   # 번들된 SKILL.md 대상
# {"ok": true, "failures": [], "warnings": []}
```

네 개 게이트가 모두 `ok: true`로 통과했고, 린트는 실패 0건·경고 0건이었습니다. 이 수치는 제가 직접 실행해 캡처한 값이며, 외부에서 인용한 것이 아닙니다. 흥미로운 점은 검증 결과가 산문이 아니라 `{"ok": true}` 형태의 결정론적 JSON으로 출력된다는 것입니다. 이는 사람이 읽고 판단하는 보고가 아니라, 상위 파이프라인이 자동으로 게이트할 수 있는 기계 판독 형식입니다. ThakiCloud가 사내 룰에서 강조해 온 "포맷은 코드가 소유한다"는 원칙과 정확히 같은 방향입니다.

다만 한 가지 한계도 실측으로 드러났습니다. `lint_skill.py`는 인자 없이 호출하면 사용법 오류를 내고, 스킬 디렉터리를 명시해야 동작했습니다. 컨텍스트 사이즈 측정 스크립트(`context_sizer.py`)는 일부 경로에서 토큰 추정값을 0으로 반환했는데, 인자 전달 방식에 민감한 것으로 보였습니다. 즉 "make 타깃은 잘 동작하지만, 개별 스크립트를 직접 호출할 때는 인터페이스를 정확히 맞춰야 한다"는 운영상의 주의가 필요합니다.

## ThakiCloud K8s AI/ML SaaS 플랫폼 적용 및 시사점

ThakiCloud는 이미 1000개가 넘는 사내 스킬과 룰을 운영하고 있습니다. 이 규모에서 가장 큰 비용은 스킬 자체가 아니라, 인덱스에 올라간 모든 스킬이 매 세션 지불하는 컨텍스트 세금과 트리거 충돌입니다. yao-meta-skill에서 빌려올 만한 지점은 세 가지로 압축됩니다.

첫째, **Skill IR 발상의 부분 도입**입니다. 사내 스킬을 Claude Code와 Cursor 양쪽에 중복 관리하는 대신, 의도·트리거·경계를 중립적으로 한 번만 기술하고 환경별로 컴파일하는 패턴은 관리 표면을 줄여 줍니다. 전면 도입은 과하더라도, 신규 스킬의 description과 트리거를 IR 스키마처럼 구조화하는 것만으로도 효과가 있습니다.

둘째, **Output Eval Lab식 게이트의 차용**입니다. 사내에는 이미 편집 게이트와 결정론적 검증 스크립트가 있지만, "트리거가 의도대로 발화하는가"를 데이터로 검사하는 트리거 평가는 상대적으로 약합니다. 스킬 라우터의 오발화(distractor noise)를 줄이는 데 직접 쓸 수 있는 패턴입니다.

셋째, **Review Studio식 단일 릴리스 게이트**입니다. 새 스킬을 머지하기 전에 의도·트리거·컨텍스트 비용·런타임을 한 페이지에서 확인하는 관문은, K8s 위에서 돌아가는 AI/ML SaaS의 배포 게이트(ArgoCD, Kueue)와 철학적으로 동형입니다. 코드 배포에 게이트를 거는 것처럼, 스킬 배포에도 게이트를 거는 것입니다.

## 한계 및 반론

낙관 일변도로 정리하지 않기 위해 반대 논거도 분명히 적습니다.

첫째, **"공식보다 강력하다"는 주장의 출처는 인플루언서 추천**이라는 점입니다. 저장소 구조와 로컬 검증이 견고한 것은 사실이지만, Anthropic 공식 Skill-creator는 대화 우선의 빠른 생성 루프에 강점이 있어 목적이 다릅니다. 두 도구는 경쟁이라기보다 상보적입니다. "더 강력하다"는 비교는 거버넌스가 필요한 팀 자산을 만들 때에 한정해 받아들이는 편이 정확합니다.

둘째, **도입 비용**입니다. 632파일 규모의 공장을 그대로 들이는 것은 1인 또는 소규모 팀에는 과합니다. 핵심 발상(IR, 트리거 평가, 단일 게이트)만 선별적으로 차용하는 것이 현실적입니다.

셋째, **운영 인터페이스의 민감성**입니다. 앞서 실측으로 확인했듯, 개별 스크립트는 인자에 민감하고 일부 측정값이 0으로 나오는 경우가 있었습니다. CI에 끼워 넣을 때는 make 타깃 단위로 감싸고, 개별 스크립트의 인터페이스를 고정해 두는 것이 안전합니다.

결론적으로 yao-meta-skill은 "스킬을 소프트웨어처럼 엔지니어링한다"는 방향성을 가장 구체적으로 구현한 오픈소스 사례 중 하나입니다. 전부를 도입하지 않더라도, 스킬이 자산이 되는 조직이라면 그 설계 원칙은 충분히 살펴볼 가치가 있습니다.

## 출처

- yao-meta-skill (GitHub, MIT): [github.com/yaojingang/yao-meta-skill](https://github.com/yaojingang/yao-meta-skill)
- 저장소 매니페스트·검증 결과: 본 글의 모든 수치는 v1.1.0을 직접 클론해 로컬에서 측정한 값입니다.
