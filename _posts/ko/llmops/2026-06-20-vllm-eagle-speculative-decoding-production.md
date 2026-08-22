---
title: "EAGLE 3.1 + vLLM: 프로덕션 추론 서빙에서 투기적 디코딩 실전 가이드"
excerpt: "EAGLE 3.1이 vLLM 메인에 머지된 2026년 5월 이후, 투기적 디코딩을 K8s LLM 서빙 스택에 어떻게 통합하고 실측 성능을 검증할지 다룬다."
seo_title: "EAGLE 3.1 + vLLM 투기적 디코딩 프로덕션 가이드 - Thaki Cloud"
seo_description: "vLLM에 통합된 EAGLE 3.1 투기적 디코딩의 원리, 설정 방법, K8s 멀티테넌트 환경에서의 실전 운용 전략을 ML 인프라 엔지니어 관점으로 정리한다."
date: 2026-06-20
last_modified_at: 2026-06-20
tags:
  - vllm
  - speculative-decoding
  - eagle
  - llm-serving
  - inference-optimization
  - kubernetes
  - gpu-utilization
  - throughput
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ko/llmops/vllm-eagle-speculative-decoding-production/"
reading_time: true
categories:
  - llmops
published: false
---

⏱️ **예상 읽기 시간**: 9분

![투기적 디코딩의 드래프트-검증 파이프라인을 형상화한 추상 이미지]({{ '/assets/images/vllm-eagle-speculative-decoding-production-hero.webp' | relative_url }})
*드래프트 모델이 토큰을 미리 생성하고 타깃 모델이 병렬로 검증하는 투기적 디코딩 구조를 형상화한 이미지입니다.*

투기적 디코딩(speculative decoding)은 드래프트 모델이 토큰을 빠르게 미리 생성하고 타깃 모델이 병렬로 검증하는 방식으로 레이턴시를 줄입니다. 이론은 2022년부터 있었지만 프로덕션 도입을 망설이게 만든 이유가 있었습니다. 드래프트 모델 관리 오버헤드, 배치 크기가 커지면 사라지는 이득, 그리고 프레임워크 지원 미흡이었습니다. 2026년 5월 EAGLE 3.1이 vLLM 메인 브랜치에 머지되면서 상황이 바뀌었습니다.

## 투기적 디코딩이 다시 주목받는 이유

일반 자기회귀 디코딩은 토큰을 하나씩 순차 생성합니다. GPU 메모리 대역폭이 병목이기 때문에 배치가 작을수록 GPU 활용률이 낮아지는 구조입니다. 투기적 디코딩은 이 구간을 노립니다.

드래프트 모델(보통 타깃의 1/10 규모)이 k개 토큰을 먼저 생성하면, 타깃 모델은 이를 한 번의 포워드 패스로 검증합니다. 검증 통과 토큰만 출력에 편입되고 첫 불일치 지점부터 재시작합니다. 수학적으로 출력 분포는 타깃 모델과 동일하게 유지됩니다. 즉 품질 저하 없이 속도를 올립니다.

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
<div class="d3-arch" data-arch-root id="lativedecodingproduction-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 898, "height": 204, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "D", "x": 24, "y": 67, "w": 121, "h": 62, "title": ["드래프트 모델", "타깃의 약 1/10 규모"]}, {"id": "V", "x": 287, "y": 101, "w": 120, "h": 62, "title": ["타깃 모델 병렬 검증", "1회 포워드 패스"]}, {"id": "A", "x": 485, "y": 106, "w": 138, "h": 52, "title": "토큰 수락 여부"}, {"id": "O", "x": 746, "y": 126, "w": 120, "h": 46, "title": "출력에 편입"}, {"id": "R", "x": 746, "y": 24, "w": 120, "h": 46, "title": "불일치 지점부터 재시작"}], "edges": [{"src": "D", "dst": "V", "kind": "data", "label": "\"k개 토큰 생성\"", "curve": [[145, 113], [216, 132], [216, 132], [287, 132]], "off": "50%"}, {"src": "V", "dst": "A", "kind": "data", "line": [407, 132, 485, 132]}, {"src": "A", "dst": "O", "kind": "data", "label": "\"수락\"", "line": [623, 141, 746, 149], "lx": 684, "ly": 145}, {"src": "A", "dst": "R", "kind": "data", "label": "\"첫 불일치\"", "line": [621, 106, 746, 64], "lx": 684, "ly": 77}, {"src": "R", "dst": "D", "kind": "data", "curve": [[746, 40], [554, 34], [347, 34], [145, 68]]}]});
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
      const container = document.getElementById('lativedecodingproduction-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'lativedecodingproduction-1';
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

EAGLE(Extrapolation Algorithm for Greater Language-model Efficiency)은 여기서 드래프트 품질을 크게 높입니다. 단순한 소형 언어 모델 대신, 타깃 모델의 피처 레이어를 활용해 다음 토큰을 예측하는 자동회귀 드래프트 헤드를 씁니다.

## EAGLE 3.1: 2026년 5월 vLLM 공식 통합

vLLM 팀이 2026년 5월 26일 게시한 블로그에 따르면, EAGLE 3.1은 기존 EAGLE-3 대비 추가 개선을 담았습니다. 핵심 수치를 살펴보면 동시 사용자 1명 기준 출력 처리량이 기존 대비 2.03배 높고, 동시성 4에서는 1.71배, 16에서는 1.66배입니다. 배치 크기가 늘어도 이득이 의미있게 유지되는 점이 이전 세대와 다릅니다.

AWS가 기여한 P-EAGLE도 이 시점에 vLLM 메인에 포함됐습니다. 코딩 태스크 벤치마크에서 EAGLE-3 단독 대비 20~30% 추가 개선을 보입니다.

## 설정: vLLM에서 EAGLE 3.1 활성화

vLLM v0.22.0 이상(또는 2026년 5월 이후 나이틀리)에서 아래처럼 활성화합니다.

```bash
vllm serve meta-llama/Llama-3.1-70B-Instruct \
  --speculative-model lmsys/eagle3-llama3.1-instruct-70b \
  --num-speculative-tokens 5 \
  --speculative-disable-by-batch-size 8 \
  --gpu-memory-utilization 0.92
```

`--speculative-disable-by-batch-size 8`은 동시 요청이 8개를 넘으면 투기적 디코딩을 자동 비활성화합니다. 배치가 클 때는 드래프트 오버헤드가 이득을 상회하기 때문에 이 파라미터를 반드시 설정해야 합니다.

EAGLE 드래프트 헤드는 타깃 모델과 같은 GPU를 공유하므로 별도 서버를 띄울 필요가 없습니다. 메모리 오버헤드는 드래프트 헤드 크기에 따라 다르지만 70B 타깃 기준 약 2~4GB 수준입니다.

## K8s 멀티테넌트 환경 적용 전략

ThakiCloud처럼 Kueue로 GPU 워크로드를 관리하는 환경에서는 몇 가지 고려가 필요합니다.

**워크로드 분리**: 투기적 디코딩은 단일 사용자 인터랙션(저배치)에서 효과가 큽니다. RAG 파이프라인이나 배치 추론처럼 동시 요청이 많은 워크로드는 일반 디코딩 경로가 낫습니다. Kueue의 LocalQueue를 활용해 인터랙티브 서빙용 큐와 배치 추론 큐를 분리하고, 인터랙티브 큐에 배포된 vLLM 인스턴스에만 EAGLE을 활성화합니다.

**ArgoCD 배포 관리**: EAGLE 드래프트 헤드는 타깃 모델 버전에 종속됩니다. Llama-3.1-70B를 업그레이드하면 eagle3-llama3.1-70b 드래프트도 같이 교체해야 합니다. Helm values에 두 모델 버전을 함께 명시하고, ArgoCD ApplicationSet으로 타깃-드래프트 쌍을 원자적으로 배포하도록 구성하면 버전 불일치를 막을 수 있습니다.

```yaml
# values.yaml 예시
serving:
  targetModel: "meta-llama/Llama-3.1-70B-Instruct"
  targetModelVersion: "v3.1"
  speculativeModel: "lmsys/eagle3-llama3.1-instruct-70b"
  speculativeModelVersion: "v3.1"
  numSpeculativeTokens: 5
  disableBatchSize: 8
```

**MIG 분리와의 호환**: A100/H100에서 MIG 파티셔닝을 쓰는 경우, EAGLE은 단일 MIG 인스턴스 내에서 실행됩니다. 드래프트 헤드와 타깃 모델이 같은 GPU 메모리를 쓰므로 MIG 슬라이스 크기 계획 시 추가 메모리를 반영해야 합니다.

## 핵심 메트릭 모니터링

vLLM은 `/metrics` 엔드포인트로 Prometheus 메트릭을 노출합니다. EAGLE 운용 시 중점적으로 봐야 할 지표는 다음과 같습니다.

```
# 투기적 디코딩 수락률 (높을수록 드래프트 품질 좋음)
vllm:spec_decode_accepted_tokens_total
vllm:spec_decode_draft_tokens_total

# KV 캐시 사용률 (드래프트 토큰이 캐시 압박을 높일 수 있음)
vllm:gpu_cache_usage_perc

# 배치당 처리량
vllm:generation_tokens_total
```

수락률이 60% 미만으로 떨어지면 드래프트 모델 미스매치나 입력 분포 변화를 의심합니다. 70% 이상이면 투기적 디코딩이 효과적으로 동작하는 것으로 봅니다.

## 언제 사용하고 언제 건너뛰나

투기적 디코딩이 유리한 시나리오는 명확합니다. 저배치(동시 요청 1~4개) 인터랙티브 채팅, 코딩 어시스턴트처럼 출력 분포가 예측 가능한 태스크, GPU 메모리가 드래프트 헤드를 수용할 여유가 있는 경우입니다.

반대로 대규모 배치 추론, 입력 분포가 매우 다양한 멀티모달 파이프라인, 그리고 TTFT(Time to First Token)보다 처리량 극대화가 목표인 워크로드에서는 일반 디코딩이 낫습니다.

EAGLE 3.1의 vLLM 통합은 드래프트 모델 관리 부담을 크게 줄였습니다. 서빙 레이턴시 개선이 필요한 인터랙티브 사용 사례라면 지금이 도입을 검토할 시점입니다.


## 관련 슬라이드

본문 내용을 NotebookLM(`prismatic_tech` 스타일)으로 요약한 슬라이드입니다.

![vllm-eagle-speculative-decoding-production 슬라이드 1]({{ '/assets/images/vllm-eagle-speculative-decoding-production-slide-01.webp' | relative_url }})

![vllm-eagle-speculative-decoding-production 슬라이드 2]({{ '/assets/images/vllm-eagle-speculative-decoding-production-slide-02.webp' | relative_url }})

![vllm-eagle-speculative-decoding-production 슬라이드 3]({{ '/assets/images/vllm-eagle-speculative-decoding-production-slide-03.webp' | relative_url }})

![vllm-eagle-speculative-decoding-production 슬라이드 4]({{ '/assets/images/vllm-eagle-speculative-decoding-production-slide-04.webp' | relative_url }})

## 출처

- vLLM Blog, "EAGLE 3.1: Advancing Speculative Decoding Through Collaboration Between the EAGLE Team, vLLM, and TorchSpec" (2026-05-26): <https://vllm.ai/blog/2026-05-26-eagle-3-1>
- Li et al., "EAGLE-3: Scaling up Inference Acceleration of Large Language Models via Training-Time Test" (arXiv:2503.01840): <https://arxiv.org/abs/2503.01840>
- AWS Machine Learning Blog, "P-EAGLE: Faster LLM inference with Parallel Speculative Decoding in vLLM": <https://aws.amazon.com/blogs/machine-learning/p-eagle-faster-llm-inference-with-parallel-speculative-decoding-in-vllm/>
- Red Hat Developer, "Fly Eagle(3) fly: Faster inference with vLLM & speculative decoding" (2025-07-01): <https://developers.redhat.com/articles/2025/07/01/fly-eagle3-fly-faster-inference-vllm-speculative-decoding>
