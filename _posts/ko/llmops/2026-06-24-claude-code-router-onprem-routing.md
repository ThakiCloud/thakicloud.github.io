---
title: "Claude Code를 사내 모델로 라우팅하기 - claude-code-router로 비용 효율적 코딩 인프라 구축"
excerpt: "claude-code-router로 Claude Code 트래픽을 glm-5.2·MiniMax-M2.7·Kimi K2로 분기합니다. 세 모델을 실제로 호출해 검증하고, MiniMax thinking 누수를 고치고, 모든 라우팅 모델이 Sonnet보다 싼지 상시 측정하는 루프까지 구축한 실전 기록입니다."
seo_title: "claude-code-router 비용 라우팅 - Claude Code 멀티모델 구축 - Thaki Cloud"
seo_description: "claude-code-router로 Claude Code를 glm-5.2/MiniMax-M2.7/Kimi K2로 라우팅하는 실전 가이드. 작업별 모델 분기, MiniMax thinking 누수 해결, Sonnet 대비 비용 상시 측정 루프를 ThakiCloud 환경에서 검증."
date: 2026-06-24
last_modified_at: 2026-06-24
tags:
  - claude-code
  - model-routing
  - cost-optimization
  - ollama
  - minimax
  - on-premise
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ko/llmops/claude-code-router-onprem-routing/"
reading_time: true
categories:
  - llmops
audiobook: /assets/audio/posts/claude-code-router-onprem-routing/audiobook-ko.mp3
audiobook_note: "AI 로컬 합성 오디오북 (Qwen3-TTS)"
---

![개념 다이어그램]({{ '/assets/images/claude-code-router-onprem-routing-hero.webp' | relative_url }})

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
<div class="d3-arch" data-arch-root id="ecoderouteronpremrouting-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 931, "height": 437, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "CC", "x": 24, "y": 242, "w": 120, "h": 46, "title": "Claude Code"}, {"id": "CCR", "x": 318, "y": 192, "w": 184, "h": 46, "title": "claude-code-router 프록시"}, {"id": "GLM", "x": 712, "y": 359, "w": 184, "h": 46, "title": "Ollama Cloud · glm-5.2"}, {"id": "MM", "x": 708, "y": 242, "w": 191, "h": 62, "title": ["MiniMax-M2.7 (Anthropic", "엔드포인트)"]}, {"id": "KIMI", "x": 740, "y": 125, "w": 128, "h": 62, "title": ["Ollama Cloud ·", "kimi-k2.7-code"]}, {"id": "VLLM", "x": 729, "y": 24, "w": 149, "h": 46, "title": "사내 vLLM (GLM-air)"}, {"id": "AUDIT", "x": 24, "y": 141, "w": 120, "h": 46, "title": "일일 비용 측정 루프"}], "edges": [{"src": "CC", "dst": "CCR", "kind": "data", "curve": [[144, 265], [231, 265], [231, 265], [328, 238]]}, {"src": "CCR", "dst": "GLM", "kind": "data", "label": "default / background", "curve": [[437, 238], [605, 382], [605, 382], [712, 382]], "off": "50%"}, {"src": "CCR", "dst": "MM", "kind": "data", "label": "think / longContext", "curve": [[487, 238], [605, 273], [605, 273], [708, 273]], "off": "50%"}, {"src": "CCR", "dst": "KIMI", "kind": "event", "label": "코딩 서브에이전트 태그", "curve": [[487, 192], [605, 156], [605, 156], [740, 156]], "off": "50%"}, {"src": "CCR", "dst": "VLLM", "kind": "event", "label": "onprem 옵션", "curve": [[437, 192], [605, 47], [605, 47], [729, 47]], "off": "50%"}, {"src": "AUDIT", "dst": "CCR", "kind": "data", "label": "Sonnet 대비 효율 검사", "curve": [[144, 164], [231, 164], [231, 164], [328, 192]], "off": "50%"}]});
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
      const container = document.getElementById('ecoderouteronpremrouting-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ecoderouteronpremrouting-1';
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

## 개요

Claude Code는 터미널에서 동작하는 에이전트형 코딩 도구입니다. 기본 동작은 Anthropic API로 요청을 보내는 것이지만, 모든 요청이 같은 무게를 갖지는 않습니다. 백그라운드 요약, 짧은 자동완성, 긴 컨텍스트 분석, 깊은 추론이 필요한 리팩터링은 서로 다른 모델 등급을 요구합니다. 모든 요청을 가장 비싼 모델로 처리하면 비용이 빠르게 쌓이고, 반대로 전부 값싼 모델로 처리하면 품질이 무너집니다.

`claude-code-router`(이하 CCR)는 이 문제를 라우팅 계층으로 풉니다. Claude Code와 모델 백엔드 사이에 프록시를 두고, 요청 종류에 따라 다른 제공자와 모델로 트래픽을 분기합니다. 이 글은 개념 소개에 그치지 않습니다. 실제로 세 개의 외부 모델을 호출해 동작을 검증하고, 그 과정에서 만난 문제(죽은 API 키, thinking 태그 누수)를 고치고, 마지막으로 "이 라우팅이 정말 Anthropic Sonnet보다 싼가"를 상시 측정하는 루프까지 붙인 기록입니다.

핵심 원칙을 먼저 박아 둡니다. **CCR로 보내는 모든 모델은 Claude Sonnet보다 비용 효율적일 때만 의미가 있습니다.** 그렇지 않다면 품질만 떨어뜨리고 돈은 그대로 나가는 셈입니다. 그래서 단정하지 않고 측정합니다.

---


![개념 다이어그램]({{ '/assets/images/claude-code-router-onprem-routing-diagram.svg' | relative_url }})

*개념 다이어그램*

## claude-code-router는 무엇인가

CCR은 Anthropic 메시지 형식의 요청을 받아 OpenAI 호환 형식 등으로 변환한 뒤 설정된 제공자로 전달하는 프록시 서버입니다. Claude Code 클라이언트 자체는 건드리지 않습니다. `ccr code`로 세션을 띄우면 그 세션의 트래픽이 `localhost:3456` 프록시를 거쳐 라우팅됩니다.

핵심 기능은 다음과 같습니다.

- **요청 유형별 라우팅**: `default`, `background`, `think`, `longContext`, `webSearch` 등 유형마다 다른 모델을 지정합니다.
- **멀티 제공자**: OpenAI 호환 엔드포인트면 무엇이든 등록할 수 있습니다. 이번에는 Ollama Cloud와 MiniMax를 씁니다.
- **transformer**: 제공자마다 다른 API 규격을 변환기가 흡수합니다. Anthropic 네이티브 엔드포인트를 위한 `Anthropic` 패스스루 변환기가 이 글의 핵심 도구로 등장합니다.
- **동적 전환**: 세션 안에서 `/model provider,model` 명령으로 즉시 모델을 바꿉니다.

검증에 사용한 CCR 버전은 `1.0.62`입니다. 설정 파일은 `~/.claude-code-router/config.json`이며, 핵심은 `Providers` 배열과 `Router` 객체입니다.

---

## 무엇을 라우팅하는가 - 세 모델로 고정

이번 구성의 모델 풀은 정확히 세 개입니다. 모델을 늘리면 라우팅 표가 복잡해지고 검증 비용이 커지므로 의도적으로 좁혔습니다.

| 역할 | 모델 | 제공자 | 비고 |
|------|------|--------|------|
| 주력 (default·background) | `glm-5.2` | Ollama Cloud | 일상 코딩, 강력하고 저렴 |
| 추론 (think·longContext) | `MiniMax-M2.7` | MiniMax | thinking 분리, per-token이 매우 저렴 |
| 코딩 서브에이전트 | `kimi-k2.7-code` | Ollama Cloud | 어려운 코딩 턴 전용 |

`glm-5.2`를 주력으로 두고, 깊은 추론과 긴 컨텍스트만 MiniMax로, 까다로운 코딩 한 턴은 Kimi로 보내는 구조입니다.

---

## 실제 검증 결과 - 가정하지 않고 호출했다

설정을 쓰기 전에 세 모델을 직접 호출했습니다. 추정 수치를 적지 않기 위해 실제 응답을 확인했고, 그 과정에서 세 가지 사실이 드러났습니다.

**첫째, Ollama Cloud 키 하나가 GLM과 Kimi를 모두 커버합니다.** `glm-5.2`와 `kimi-k2.7-code` 모두 `https://ollama.com/v1`에서 정상 응답(HTTP 200)했습니다. Ollama Cloud는 GLM, Kimi, DeepSeek, Qwen 계열을 한 키로 묶어 제공합니다.

**둘째, 단독 Kimi 키는 죽어 있었습니다.** `.env`에 넣어 둔 Moonshot 단독 키는 moonshot.ai, moonshot.cn, Anthropic 호환 엔드포인트 모두에서 401(Invalid Authentication)을 반환했습니다. 다행히 Kimi K2는 Ollama Cloud의 `kimi-k2.7-code`로 동일하게 쓸 수 있어, 죽은 키는 막다른 길이 아니었습니다.

**셋째, MiniMax는 엔드포인트 선택이 품질을 가릅니다.** OpenAI 호환 엔드포인트(`/v1/chat/completions`)로 부르면 모델이 추론을 `<think>...</think>` 태그로 응답 본문에 인라인해 버리고, CCR의 변환 레이어가 이를 떼어내지 못해 그대로 사용자에게 노출됩니다(musistudio/claude-code-router#964). 같은 모델을 네이티브 Anthropic 엔드포인트(`/anthropic/v1/messages`)로 부르면 응답이 `thinking` 블록과 `text` 블록으로 깔끔하게 분리되어 옵니다.

마지막 항목은 단순히 "MiniMax를 빼자"로 끝낼 문제가 아니라 고쳐야 할 버그였습니다. 해결책은 아래 설정에 반영했습니다.

---

## 설정 - 비밀키는 저장소 밖, 설정은 코드로 생성

키를 설정 파일에 직접 박지 않습니다. 저장소의 `.env`를 읽어 `~/.claude-code-router/config.json`을 만드는 생성기 스크립트를 두었습니다. 저장소에는 키가 남지 않고, 키를 교체하면 스크립트만 다시 돌리면 됩니다.

생성되는 핵심 설정은 다음과 같습니다.

```json
{
  "LOG": true,
  "HOST": "127.0.0.1",
  "PORT": 3456,
  "API_TIMEOUT_MS": 1800000,
  "Providers": [
    {
      "name": "ollama",
      "api_base_url": "https://ollama.com/v1/chat/completions",
      "api_key": "<OLLAMA_GLM_API_KEY>",
      "models": ["glm-5.2", "kimi-k2.7-code"],
      "transformer": { "use": [["maxtoken", { "max_tokens": 16000 }]] }
    },
    {
      "name": "minimax",
      "api_base_url": "https://api.minimax.io/anthropic/v1/messages",
      "api_key": "<MINIMAX_API_KEY>",
      "models": ["MiniMax-M2.7"],
      "transformer": { "use": ["Anthropic"] }
    }
  ],
  "Router": {
    "default": "ollama,glm-5.2",
    "background": "ollama,glm-5.2",
    "think": "minimax,MiniMax-M2.7",
    "longContext": "minimax,MiniMax-M2.7",
    "longContextThreshold": 60000,
    "webSearch": "ollama,glm-5.2"
  }
}
```

MiniMax provider의 두 줄이 thinking 누수를 해결한 핵심입니다. `api_base_url`을 네이티브 Anthropic 경로로 두고 `Anthropic` 패스스루 변환기를 쓰면, MiniMax가 처음부터 Anthropic 메시지 형식(`thinking` + `text` 블록)으로 응답합니다. 프록시를 통과시켜 다시 확인했을 때 응답 블록은 `["thinking", "text"]`였고 `<think>` 누수는 0이었습니다.

추론 모델은 출력이 느리므로 타임아웃을 넉넉히(`1800000ms`) 잡고, GLM·Kimi처럼 추론을 먼저 토해내는 모델이 본문 전에 토큰을 소진하지 않도록 `maxtoken`으로 출력 헤드룸을 확보했습니다.

서브에이전트는 설정이 아니라 프롬프트 선두 태그로 분기합니다. 어려운 코딩 작업을 위임할 때는 프롬프트 맨 앞에 `<CCR-SUBAGENT-MODEL>ollama,kimi-k2.7-code</CCR-SUBAGENT-MODEL>`를 붙입니다.

---

## 어디에 어떻게 연결하는가

연결 지점은 하나입니다. 작업할 저장소에서 `ccr code`로 세션을 시작하면 그 세션의 메인과 서브 트래픽 전부가 프록시를 거쳐 위 라우팅대로 흐릅니다. 네이티브 `claude`는 그대로 Anthropic에 직결되므로 영향이 없습니다.

```bash
# 설정 생성 후 라우터 기동
python3 scripts/ccr/gen_ccr_config.py && ccr restart

# 비용 라우팅 세션 시작 (이게 연결 지점)
ccr code

# 세션 안에서 작업별로 모델 즉시 전환
/model ollama,kimi-k2.7-code     # 어려운 코딩 턴
/model minimax,MiniMax-M2.7      # 깊은 추론 턴
/model ollama,glm-5.2            # 일상 코딩
```

비용 효율 관점에서 권장하는 사용 패턴은 하이브리드입니다. 대량·반복·AFK 성격의 작업(테스트 생성, 일괄 리팩터, 로그 분석, 번역, 코드 탐색)은 `ccr code`로 돌려 비용을 깎고, 아키텍처 결정이나 미묘한 디버깅처럼 판단이 어려운 작업만 네이티브 `claude` 구독 세션으로 처리합니다. 일상 전체를 라우팅 세션으로 옮기면 메인이 GLM이 되어 어려운 작업의 품질이 떨어질 수 있기 때문입니다.

---

## 비용 효율 - Sonnet보다 싼지 상시 측정한다

이 구성의 존재 이유는 비용입니다. 그래서 "싸다"고 주장하지 않고 측정합니다.

2026년 6월 24일 기준 확인한 단가입니다(100만 토큰당 USD).

| 모델 | 입력 | 출력 | 과금 형태 | Sonnet 대비 |
|------|------|------|-----------|-------------|
| Claude Sonnet 4.6 (기준) | $3.00 | $15.00 | per-token | 1.0배 |
| MiniMax-M2.7 | $0.24 | $0.96 | per-token | 약 0.07배 |
| glm-5.2 / kimi-k2.7-code | - | - | 구독 $20/월(Pro) | 사용량 의존 |

MiniMax-M2.7은 토큰당 단가가 Sonnet의 7~8% 수준이라 언제나 압도적으로 쌉니다. 반면 Ollama Cloud는 토큰당이 아니라 월정액 구독제입니다. 즉 실효 단가는 `월 요금 ÷ 월 사용 토큰`이고, 적게 쓰면 $20 정액이 오히려 손해입니다. blended $9/M 기준으로 계산하면 **월 약 220만 토큰을 넘겨야** Sonnet보다 싸집니다.

이 손익분기는 추정이 아니라 측정 대상입니다. CCR 로그에는 요청마다 라우팅된 모델과 입출력 토큰이 남습니다. 이를 집계해 per-token 모델은 실제 비용 대 Sonnet 환산 비용의 비율을, 구독 모델은 월 투영 Sonnet 비용 대 구독료를 비교하는 측정 스크립트를 두었습니다. 측정 결과는 이력 파일에 누적되어 추세를 봅니다. 개선이란 시간이 지나며 비율이 더 낮아지는 것입니다.

이 루프는 launchd로 매일 한 번 자동 실행됩니다. Claude를 루프에 두지 않고 순수 스크립트만 cron으로 돌리므로 측정 자체의 비용은 0입니다. 측정에서 per-token 모델이 Sonnet보다 비싸지는 이상 신호가 잡히면 사내 Slack으로 경보가 갑니다. 구독 모델이 손익분기에 미달하는 저사용 상태는 경보 대신 리포트에만 남겨 램프업 초기의 잡음을 막습니다.

행동 규칙도 측정에 묶여 있습니다. per-token 모델의 비율이 1.0 이상이면(즉 Sonnet보다 비싸지면) 그 모델은 즉시 라우팅에서 내립니다. 구독 모델이 여러 달 저사용이면 플랜을 낮추거나 그 경로를 저가 per-token 모델로 바꿉니다. 단가가 바뀌면 가격표 파일만 갱신하면 다음 측정부터 반영됩니다.

---

## ThakiCloud 플랫폼 관점

이 라우팅 모델은 ThakiCloud가 이미 운용하는 인프라와 자연스럽게 맞물립니다.

**코드 보안**입니다. 금융, 공공, 의료처럼 소스 코드 외부 반출이 제한되는 환경에서는 위 설정의 `default`를 사내 vLLM 엔드포인트로 바꾸기만 하면 됩니다. Claude Code의 사용성을 유지하면서 프롬프트와 코드가 외부로 나가지 않는 구성이 됩니다. 이번 글의 외부 모델 구성은 비용 검증용이고, 같은 골격에 사내 GPU 서빙을 끼우면 온프레미스 버전이 됩니다.

**비용 통제**입니다. 작업별 라우팅은 곧 비용별 라우팅입니다. 빈도는 높지만 난도는 낮은 요청을 저가 모델로 보내고 고난도 추론만 상위 모델로 보내면, 비싼 모델 사용량을 실제로 필요한 곳으로 좁힐 수 있습니다. 그리고 그 효과를 측정 루프가 숫자로 증명합니다.

**정책의 코드화**입니다. 제공자와 라우팅 규칙, 가격표, 측정 기준이 모두 텍스트 파일로 관리되고 저장소에 커밋됩니다. 키만 `.env`에 남고 설정은 생성기로 재현되므로, 다른 머신에서도 같은 구성이 복원됩니다.

---

## 한계 및 반론

라우터를 도입한다고 모든 문제가 풀리지는 않습니다. 냉정하게 볼 지점이 여럿 있습니다.

- **품질 격차**: 라우팅의 가치는 백엔드 모델 품질에 종속됩니다. 복잡한 멀티스텝 리팩터링이나 미묘한 디버깅에서 오픈 모델이 상위 폐쇄 모델을 늘 따라잡지는 못합니다. 그래서 하이브리드를 권합니다.
- **도구 호출 신뢰도**: Claude Code는 도구 호출에 크게 의존합니다. OpenAI 호환 변환 레이어를 거치면 도구 호출 포맷이 흔들릴 수 있어, 탐색·요약 서브에이전트에는 안전하지만 편집·구현 서브에이전트에는 단계적 확대가 안전합니다.
- **구독제의 함정**: Ollama Cloud는 정액이라 적게 쓰면 손해입니다. 손익분기를 넘기지 못하면 차라리 Sonnet이 쌉니다. 측정 루프가 바로 이 지점을 감시합니다.
- **프록시는 단일 장애점**: 메인 트래픽도 CCR을 통과하므로 프록시가 죽으면 세션이 멈춥니다. 폴백은 네이티브 `claude`입니다.
- **"무료" 프레이밍의 함정**: 일부 변형판은 텔레메트리나 안전 가드 제거를 내세우며 "무료"를 강조합니다. 회사가 권장할 수 없는 방향입니다. 우리가 취하는 가치는 무료가 아니라 통제권, 즉 어떤 요청을 어떤 모델로 보낼지를 우리가 정하고 그 비용을 우리가 측정한다는 점입니다.

결론적으로 CCR은 비용을 줄이는 마법이 아니라 라우팅이라는 통제 장치입니다. 그 통제권을 검증된 모델 풀, thinking 누수 같은 실제 버그의 수정, 그리고 Sonnet 대비 상시 측정과 결합할 때 비로소 보안과 비용 양쪽에서 의미 있는 이득이 됩니다.

---

## 출처

- claude-code-router (musistudio): [https://github.com/musistudio/claude-code-router](https://github.com/musistudio/claude-code-router)
- MiniMax thinking 누수 이슈: [claude-code-router#964](https://github.com/musistudio/claude-code-router/issues/964)
- MiniMax M2.7 단가: [openrouter.ai/minimax/minimax-m2.7](https://openrouter.ai/minimax/minimax-m2.7)
- Ollama Cloud 요금: [ollama.com/pricing](https://ollama.com/pricing)
- Claude API 단가: [platform.claude.com/docs pricing](https://platform.claude.com/docs/en/about-claude/pricing)
