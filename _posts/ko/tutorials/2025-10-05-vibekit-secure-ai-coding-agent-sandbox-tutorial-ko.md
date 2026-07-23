---
title: "VibeKit: AI 코딩 에이전트를 위한 궁극의 보안 계층 - 완전 가이드"
excerpt: "VibeKit을 사용하여 Claude Code, Gemini 등 AI 코딩 에이전트를 안전한 격리 샌드박스에서 실행하고, 내장된 데이터 편집 및 포괄적인 관찰 가능성을 활용하는 방법을 학습하세요."
seo_title: "VibeKit 튜토리얼: 데이터 편집 기능을 갖춘 안전한 AI 코딩 에이전트 샌드박스 - Thaki Cloud"
seo_description: "VibeKit 완전 가이드 - Claude Code와 Gemini 같은 AI 코딩 에이전트를 격리된 Docker 컨테이너에서 자동 민감 데이터 편집 및 실시간 모니터링과 함께 실행하는 방법"
date: 2025-10-05
tags:
  - vibekit
  - ai-agents
  - coding-security
  - docker-sandbox
  - claude-code
  - gemini-cli
  - data-redaction
  - observability
author_profile: true
toc: true
toc_label: "목차"
lang: ko
permalink: /ko/tutorials/vibekit-secure-ai-coding-agent-sandbox-tutorial/
canonical_url: "https://thakicloud.com/tech-blog/ko/tutorials/vibekit-secure-ai-coding-agent-sandbox-tutorial-ko/"
categories:
  - tutorials
published: false
audiobook: /assets/audio/posts/vibekit-secure-ai-coding-agent-sandbox-tutorial-ko/audiobook-ko.mp3
audiobook_note: "AI 로컬 합성 오디오북 (Qwen3-TTS)"
---

⏱️ **예상 읽기 시간**: 12분

## 소개

Claude Code, Gemini CLI, Codex와 같은 AI 코딩 에이전트가 점점 더 강력해짐에 따라, 안전한 실행 환경의 필요성이 그 어느 때보다 중요해졌습니다. **VibeKit**은 보안과 관찰 가능성을 완전히 유지하면서 이러한 AI 도구의 모든 잠재력을 활용할 수 있게 해주는 필수적인 보안 계층으로 등장했습니다.

이 포괄적인 튜토리얼에서는 VibeKit이 어떻게 격리된 Docker 샌드박스를 생성하고, 민감한 데이터를 자동으로 편집하며, 모든 AI 코딩 작업에 대한 실시간 모니터링을 제공하는지 살펴보겠습니다.

## VibeKit이란 무엇인가?

VibeKit은 AI 코딩 에이전트를 위해 특별히 설계된 오픈소스 보안 프레임워크입니다. AI가 생성한 코드와 로컬 개발 환경 사이의 보호 장벽 역할을 하여 다음을 보장합니다:

- **악성 코드**가 시스템에 영향을 줄 수 없음
- **민감한 데이터**가 자동으로 감지되고 편집됨
- **모든 작업**이 실시간으로 로깅되고 모니터링됨
- 인기 있는 AI 코딩 도구와의 **범용 호환성**

### 주요 기능 개요

🐳 **로컬 샌드박스 환경**
- 모든 AI 생성 코드를 격리된 Docker 컨테이너에서 실행
- 로컬 개발 설정에 대한 위험 제로
- 완전한 파일시스템 격리

🔒 **내장 데이터 편집**
- API 키, 비밀번호, 시크릿을 자동으로 감지하고 제거
- 사용자 정의 민감 데이터 패턴을 위한 구성 가능한 편집 규칙
- 모든 코드 완성의 실시간 스캔

📊 **포괄적인 관찰 가능성**
- 실시간 로그 및 실행 추적
- 성능 메트릭 및 리소스 사용량 모니터링
- 모든 AI 작업의 완전한 감사 추적

🌐 **범용 에이전트 지원**
- Claude Code, Gemini CLI, Grok CLI, Codex CLI와 작동
- OpenCode 및 사용자 정의 AI 에이전트와 호환
- 지원 확장을 위한 플러그인 아키텍처

💻 **오프라인 작동**
- 클라우드 의존성 불필요
- 로컬 머신에서 완전히 작동
- 완전한 프라이버시 및 데이터 주권

**그림 1. VibeKit 보안 샌드박스 아키텍처.**

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
<div class="d3-arch" data-arch-root id="ngagentsandboxtutorialko-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 753, "height": 538, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "AGENT", "x": 270, "y": 24, "w": 198, "h": 78, "title": ["AI Coding Agent: Claude", "Code / Gemini CLI / Grok", "CLI / Codex CLI"]}, {"id": "VK", "x": 277, "y": 180, "w": 184, "h": 46, "title": "VibeKit Security Layer"}, {"id": "BOX", "x": 523, "y": 304, "w": 198, "h": 62, "title": ["Isolated Docker Sandbox:", "filesystem isolation"]}, {"id": "RED", "x": 270, "y": 304, "w": 198, "h": 62, "title": ["Data Redaction: scan API", "keys and secrets"]}, {"id": "LOG", "x": 24, "y": 304, "w": 191, "h": 62, "title": ["Observability: logs and", "audit trail"]}, {"id": "SAFE", "x": 288, "y": 444, "w": 163, "h": 62, "title": ["Protected Local Dev", "Environment"]}], "edges": [{"src": "AGENT", "dst": "VK", "kind": "data", "line": [369, 102, 369, 180]}, {"src": "VK", "dst": "BOX", "kind": "data", "curve": [[461, 226], [622, 265], [622, 265], [622, 304]]}, {"src": "VK", "dst": "RED", "kind": "data", "line": [369, 226, 369, 304]}, {"src": "VK", "dst": "LOG", "kind": "data", "curve": [[277, 226], [120, 265], [120, 265], [120, 304]]}, {"src": "BOX", "dst": "SAFE", "kind": "data", "curve": [[622, 366], [622, 405], [622, 405], [451, 452]]}, {"src": "RED", "dst": "SAFE", "kind": "data", "line": [369, 366, 369, 444]}, {"src": "LOG", "dst": "SAFE", "kind": "data", "curve": [[120, 366], [120, 405], [120, 405], [288, 452]]}]});
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
      const container = document.getElementById('ngagentsandboxtutorialko-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ngagentsandboxtutorialko-1';
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

## 사전 요구사항

시작하기 전에 시스템에 다음이 설치되어 있는지 확인하세요:

### 시스템 요구사항

- **Node.js**: 버전 16 이상
- **Docker**: 최신 안정 버전
- **npm**: Node.js 설치와 함께 제공
- **운영체제**: macOS, Linux, 또는 WSL2가 있는 Windows

### 확인 명령어

```bash
# Node.js 버전 확인
node --version

# Docker 설치 확인
docker --version

# npm 버전 확인
npm --version
```

## 설치 가이드

### 1단계: VibeKit CLI 설치

VibeKit을 시작하는 가장 쉬운 방법은 전역 CLI 설치입니다:

```bash
# VibeKit CLI 전역 설치
npm install -g vibekit

# 설치 확인
vibekit --version
```

### 2단계: Docker 설정 확인

VibeKit은 격리된 샌드박스 생성을 위해 Docker에 의존합니다. Docker가 올바르게 구성되었는지 확인해봅시다:

```bash
# Docker 기능 테스트
docker run hello-world

# 사용 가능한 Docker 이미지 확인
docker images

# Docker 데몬이 실행 중인지 확인
docker info
```

### 3단계: 초기 구성

VibeKit을 위한 기본 구성 파일을 생성합니다:

```bash
# VibeKit 구성 디렉토리 생성
mkdir -p ~/.vibekit

# 기본 구성 생성
vibekit init
```

이렇게 하면 기본 설정이 포함된 `.vibekit.json` 구성 파일이 생성됩니다:

```json
{
  "sandbox": {
    "timeout": 30000,
    "memory_limit": "512m",
    "cpu_limit": "1.0"
  },
  "redaction": {
    "enabled": true,
    "patterns": [
      "api_key",
      "password",
      "secret",
      "token"
    ]
  },
  "logging": {
    "level": "info",
    "output": "console"
  }
}
```

## 기본 사용법 튜토리얼

### VibeKit으로 Claude Code 실행하기

가장 일반적인 사용 사례는 VibeKit의 보안 계층을 통해 Claude Code를 실행하는 것입니다:

```bash
# VibeKit 보호와 함께 Claude Code 실행
vibekit claude

# 상세 로깅과 함께 실행
vibekit claude --verbose

# 사용자 정의 타임아웃으로 실행
vibekit claude --timeout 60000
```

### 예제: 안전한 Python 스크립트 실행

AI가 생성한 Python 코드를 안전하게 실행하는 실제 예제를 살펴보겠습니다:

1. **Claude Code와 함께 VibeKit 시작:**
```bash
vibekit claude --language python
```

2. **AI에게 코드 생성 요청:**
```
CSV 데이터를 분석하고 시각화를 생성하는 Python 스크립트를 만들어주세요
```

3. **VibeKit이 자동으로:**
   - AI가 생성한 코드를 수신
   - 민감한 데이터 패턴을 스캔
   - 격리된 Docker 컨테이너를 생성
   - 코드를 안전하게 실행
   - 보안 로그와 함께 결과를 반환

### 다양한 AI 에이전트와 작업하기

VibeKit은 여러 AI 코딩 에이전트를 지원합니다. 사용 방법은 다음과 같습니다:

```bash
# Gemini CLI 통합
vibekit gemini

# Codex CLI 통합  
vibekit codex

# 사용자 정의 에이전트 통합
vibekit custom --agent-command "your-ai-agent"
```

## 고급 구성

### 사용자 정의 편집 패턴

민감한 데이터 감지를 위한 사용자 정의 패턴을 정의할 수 있습니다:

```json
{
  "redaction": {
    "enabled": true,
    "patterns": [
      {
        "name": "custom_api_key",
        "regex": "sk-[a-zA-Z0-9]{32}",
        "replacement": "[편집된_API_키]"
      },
      {
        "name": "database_url",
        "regex": "postgresql://[^\\s]+",
        "replacement": "[편집된_DB_URL]"
      }
    ]
  }
}
```

### 샌드박스 리소스 제한

향상된 보안을 위한 리소스 제한 구성:

```json
{
  "sandbox": {
    "memory_limit": "1g",
    "cpu_limit": "2.0",
    "disk_limit": "500m",
    "network_access": false,
    "timeout": 45000
  }
}
```

### 로깅 및 모니터링 설정

감사 추적을 위한 포괄적인 로깅 활성화:

```json
{
  "logging": {
    "level": "debug",
    "output": "file",
    "file_path": "~/.vibekit/logs/vibekit.log",
    "max_file_size": "10mb",
    "max_files": 5
  }
}
```

## SDK 통합

VibeKit으로 애플리케이션을 구축하는 개발자를 위해 SDK는 프로그래밍 방식의 액세스를 제공합니다:

### 설치

```bash
npm install @vibe-kit/sdk
```

### 기본 SDK 사용법

```javascript
import { VibeKit } from '@vibe-kit/sdk';

const vibekit = new VibeKit({
  sandbox: {
    timeout: 30000,
    memory_limit: '512m'
  },
  redaction: {
    enabled: true
  }
});

// 샌드박스에서 코드 실행
const result = await vibekit.execute({
  code: 'print("안녕하세요, 안전한 세상!")',
  language: 'python'
});

console.log('실행 결과:', result.output);
console.log('보안 로그:', result.security_logs);
```

### 고급 SDK 기능

```javascript
// 사용자 정의 편집 규칙
vibekit.addRedactionRule({
  name: 'credit_card',
  pattern: /\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b/g,
  replacement: '[편집된_신용카드]'
});

// 실시간 모니터링
vibekit.on('execution_start', (event) => {
  console.log('코드 실행 시작:', event.timestamp);
});

vibekit.on('security_alert', (alert) => {
  console.log('보안 경고:', alert.message);
});
```

## 보안 모범 사례

### 1. 정기 업데이트

최신 보안 패치를 받기 위해 VibeKit을 업데이트하세요:

```bash
# VibeKit CLI 업데이트
npm update -g vibekit

# SDK 업데이트
npm update @vibe-kit/sdk
```

### 2. 구성 강화

최대 보안을 위한 제한적인 샌드박스 설정 사용:

```json
{
  "sandbox": {
    "network_access": false,
    "file_system_access": "read-only",
    "environment_isolation": true,
    "resource_monitoring": true
  }
}
```

### 3. 감사 로그 관리

적절한 로그 순환 및 모니터링 구현:

```bash
# 로그 순환 설정
vibekit config set logging.rotation.enabled true
vibekit config set logging.rotation.max_size "50mb"
vibekit config set logging.rotation.max_files 10
```

### 4. 사용자 정의 보안 정책

조직별 보안 정책 정의:

```json
{
  "security_policies": {
    "allowed_languages": ["python", "javascript", "bash"],
    "blocked_imports": ["os", "subprocess", "socket"],
    "max_execution_time": 30000,
    "require_approval": ["file_operations", "network_requests"]
  }
}
```

## 일반적인 문제 해결

### Docker 연결 문제

```bash
# Docker 데몬 상태 확인
sudo systemctl status docker

# Docker 서비스 재시작
sudo systemctl restart docker

# Docker 연결 테스트
docker run --rm hello-world
```

### 권한 문제

```bash
# 사용자를 docker 그룹에 추가 (Linux)
sudo usermod -aG docker $USER

# 그룹 멤버십 다시 로드
newgrp docker
```

### 메모리 및 리소스 문제

```bash
# 시스템 리소스 확인
docker system df

# 사용하지 않는 컨테이너 정리
docker system prune

# 리소스 사용량 모니터링
docker stats
```

### 구성 검증

```bash
# VibeKit 구성 검증
vibekit config validate

# 기본 구성으로 재설정
vibekit config reset

# 현재 구성 표시
vibekit config show
```

## 성능 최적화

### 컨테이너 이미지 최적화

더 나은 성능을 위해 경량 베이스 이미지 사용:

```json
{
  "sandbox": {
    "base_images": {
      "python": "python:3.11-alpine",
      "node": "node:18-alpine",
      "general": "ubuntu:22.04"
    }
  }
}
```

### 리소스 할당 조정

사용 사례에 따른 리소스 할당 최적화:

```json
{
  "performance": {
    "parallel_executions": 3,
    "container_reuse": true,
    "image_caching": true,
    "memory_optimization": true
  }
}
```

## 모니터링 및 관찰 가능성

### 실시간 모니터링 대시보드

VibeKit은 웹 기반 모니터링 인터페이스를 제공합니다:

```bash
# 모니터링 대시보드 시작
vibekit monitor --port 8080

# http://localhost:8080에서 대시보드 액세스
```

### 메트릭 수집

포괄적인 메트릭 수집 활성화:

```json
{
  "metrics": {
    "enabled": true,
    "collection_interval": 5000,
    "export_format": "prometheus",
    "custom_metrics": [
      "execution_time",
      "memory_usage",
      "security_events"
    ]
  }
}
```

### 외부 모니터링과의 통합

```javascript
// 외부 시스템으로 메트릭 내보내기
const metrics = await vibekit.getMetrics();

// 모니터링 서비스로 전송
await monitoringService.send({
  timestamp: Date.now(),
  metrics: metrics,
  tags: ['vibekit', 'ai-agents']
});
```

## 사용 사례 및 예제

### 1. 안전한 코드 리뷰 자동화

```bash
# AI 지원으로 풀 리퀘스트 리뷰
vibekit claude --mode review --input "path/to/pr.diff"
```

### 2. 안전한 의존성 분석

```bash
# package.json의 보안 문제 분석
vibekit gemini --task security-audit --file package.json
```

### 3. 자동화된 테스트 생성

```bash
# 단위 테스트를 안전하게 생성
vibekit codex --generate tests --source-dir src/
```

### 4. 문서 생성

```bash
# 코드에서 문서 생성
vibekit claude --task documentation --input-dir src/
```

## 커뮤니티 및 지원

### 도움 받기

- **GitHub 저장소**: [https://github.com/superagent-ai/vibekit](https://github.com/superagent-ai/vibekit)
- **문서**: vibekit.sh의 공식 문서
- **Discord 커뮤니티**: 토론에 참여
- **이슈 트래커**: 버그 및 기능 요청 보고

### 기여하기

VibeKit은 오픈소스이며 기여를 환영합니다:

```bash
# 저장소 클론
git clone https://github.com/superagent-ai/vibekit.git

# 개발 의존성 설치
cd vibekit
npm install

# 테스트 실행
npm test

# 풀 리퀘스트 제출
```

## 결론

VibeKit은 AI 코딩 에이전트 보안에 대한 접근 방식의 패러다임 전환을 나타냅니다. 격리된 실행 환경, 자동 데이터 편집, 포괄적인 관찰 가능성을 제공함으로써 개발자가 보안을 손상시키지 않고 AI 코딩 도구의 모든 힘을 활용할 수 있게 합니다.

이 튜토리얼의 주요 요점:

1. **보안 우선**: 항상 격리된 환경에서 AI 생성 코드를 실행하세요
2. **데이터 보호**: 민감한 정보에 대한 자동 편집을 구현하세요
3. **모니터링**: 모든 AI 작업에 대한 포괄적인 로그와 메트릭을 유지하세요
4. **모범 사례**: 보안 가이드라인을 따르고 시스템을 업데이트하세요
5. **커뮤니티**: 지원과 기여를 위해 오픈소스 커뮤니티를 활용하세요

AI 코딩 에이전트가 계속 발전함에 따라 VibeKit은 보안과 관찰 가능성이 함께 발전하도록 보장하여 AI 지원 개발의 미래를 위한 견고한 기반을 제공합니다.

## 다음 단계

1. **VibeKit을 설치**하고 기본 예제를 시도해보세요
2. 특정 사용 사례에 맞는 **사용자 정의 편집 규칙을 구성**하세요
3. 기존 개발 워크플로우에 **SDK를 통합**하세요
4. **모니터링 및 관찰 가능성 대시보드를 설정**하세요
5. **커뮤니티에 참여**하고 프로젝트에 기여하세요

오늘 VibeKit으로 안전한 AI 코딩 여정을 시작하세요!
