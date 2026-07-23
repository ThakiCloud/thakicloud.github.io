---
title: "Cursor 1.0 출시! AI 코딩의 새로운 시대를 여는 혁신적 기능들"
date: 2025-06-05
tags: 
  - Cursor
  - AI Coding
  - Code Review
  - Jupyter
  - MCP
  - Development Tools
author_profile: true
toc: true
toc_label: Cursor 1.0 기능 가이드
published: false
categories:
  - tutorials
---

드디어 Cursor 1.0이 공개되었습니다! 이번 릴리스는 AI 기반 코딩 경험을 완전히 새로운 차원으로 끌어올리는 혁신적인 기능들로 가득합니다. BugBot을 통한 자동 코드 리뷰부터 모든 사용자에게 제공되는 Background Agent, 그리고 Jupyter Notebook 지원까지, 개발자들이 그동안 기다려온 모든 것들이 한꺼번에 출시되었습니다.

## BugBot으로 똑똑한 코드 리뷰

### 자동 PR 리뷰 시스템

BugBot은 여러분의 풀 리퀘스트를 자동으로 분석하여 잠재적인 버그나 문제점을 찾아내는 혁신적인 기능입니다.

**주요 특징:**

- GitHub PR에 자동으로 코멘트 작성
- 발견된 이슈에 대한 상세한 설명 제공
- "Fix in Cursor" 버튼으로 원클릭 수정 기능

### 설정 방법

BugBot을 사용하려면 [공식 문서](https://docs.cursor.com/bugbot)의 지침을 따라 설정하면 됩니다. 설정이 완료되면 자동으로 모든 PR을 모니터링하기 시작합니다.

## Background Agent, 이제 모든 사용자에게

### 원격 코딩 에이전트의 대중화

이전에 얼리 액세스로만 제공되던 Background Agent가 드디어 모든 사용자에게 공개되었습니다.

**사용 방법:**

- 채팅창의 클라우드 아이콘 클릭
- `Cmd/Ctrl+E` 단축키 사용
- 프라이버시 모드 비활성화 필요

**Background Agent의 장점:**

- 병렬 작업 처리로 효율성 극대화
- 대규모 태스크 분할 처리
- 원격 환경에서 안전한 코드 실행

## Jupyter Notebook 지원으로 데이터 과학 혁신

### AI 에이전트와 노트북의 만남

Cursor 에이전트가 이제 Jupyter Notebook에서도 완벽하게 작동합니다.

**지원 기능:**

- 여러 셀 동시 생성 및 수정
- 데이터 과학 작업 흐름 최적화
- 연구 및 분석 작업 자동화

**현재 제한사항:**

- Sonnet 모델에서만 지원 (추후 확장 예정)

### 사용 예시

```python
# Cursor가 자동으로 생성하는 데이터 분석 셀
import pandas as pd
import matplotlib.pyplot as plt

# 데이터 로드
df = pd.read_csv('data.csv')

# 시각화
plt.figure(figsize=(10, 6))
plt.plot(df['date'], df['value'])
plt.title('Data Trend Analysis')
plt.show()
```

## Memories 기능으로 프로젝트별 지식 관리

### 대화 기록 기반 지능형 메모리

새로운 Memories 기능은 프로젝트별로 중요한 대화 내용을 기억하고 활용할 수 있게 해줍니다.

**특징:**

- 프로젝트별 개별 메모리 저장
- 미래 대화에서 자동 참조
- 개별 메모리 관리 가능

### 활성화 방법

```
Settings → Rules → Memories 베타 기능 활성화
```

## MCP 원클릭 설치와 OAuth 지원

### 간편해진 MCP 서버 설정

MCP(Model Context Protocol) 서버 설치가 이제 단 한 번의 클릭으로 가능해졌습니다.

**새로운 기능:**

- 원클릭 MCP 서버 설치
- OAuth 인증 지원으로 보안 강화
- 공식 MCP 서버 목록 제공

### 개발자를 위한 배포 도구

MCP 개발자라면 다음과 같이 "Add to Cursor" 버튼을 문서에 추가할 수 있습니다:

```markdown
[Add to Cursor](https://docs.cursor.com/deeplinks)
```

자세한 정보는 [docs.cursor.com/tools](https://docs.cursor.com/tools)에서 확인하세요.

## 풍부한 채팅 응답과 시각화

### 대화 중 실시간 시각화

이제 Cursor와의 대화에서 바로 시각적 요소를 생성하고 확인할 수 있습니다.

**지원 형식:**

- Mermaid 다이어그램
- 마크다운 테이블
- 실시간 렌더링

### 예시: Mermaid 다이어그램

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
<div class="d3-arch" data-arch-root id="0605cursor10releaseguide-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 225, "height": 598, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 24, "y": 24, "w": 120, "h": 46, "title": "사용자 요청"}, {"id": "B", "x": 24, "y": 148, "w": 120, "h": 46, "title": "Cursor 분석"}, {"id": "C", "x": 73, "y": 272, "w": 120, "h": 46, "title": "코드 생성"}, {"id": "D", "x": 73, "y": 396, "w": 120, "h": 46, "title": "실시간 미리보기"}, {"id": "E", "x": 24, "y": 520, "w": 120, "h": 46, "title": "사용자 피드백"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [84, 70, 84, 148]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[102, 194], [133, 233], [133, 233], [133, 272]]}, {"src": "C", "dst": "D", "kind": "data", "line": [133, 318, 133, 396]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[133, 442], [133, 481], [133, 481], [102, 520]]}, {"src": "E", "dst": "B", "kind": "data", "curve": [[66, 520], [35, 419], [35, 295], [66, 194]]}]});
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
      const container = document.getElementById('0605cursor10releaseguide-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '0605cursor10releaseguide-1';
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

## 새로워진 설정과 대시보드

### 개선된 사용자 인터페이스

설정과 대시보드가 완전히 새롭게 디자인되었습니다.

**새로운 기능:**

- 개인/팀 사용량 분석
- 디스플레이 이름 변경
- 도구별/모델별 상세 통계
- 깔끔한 인터페이스

### 사용량 모니터링

```
Dashboard → Usage Analytics → 모델별 통계 확인
```

## 추가 개선사항들

### 파일 처리 능력 확장

**@Link와 웹 검색 개선:**

- PDF 파일 파싱 지원
- 네트워크 진단 기능 추가
- 병렬 도구 호출로 속도 향상

### 채팅 인터페이스 개선

**새로운 기능:**

- 도구 호출 결과 접기/펼치기
- 더 깔끔한 대화 정리
- 향상된 응답 속도

## 팀과 엔터프라이즈를 위한 기능

### 강화된 관리 도구

**엔터프라이즈 기능:**

- 안정화된 버전 접근 제한
- 팀 관리자의 프라이버시 모드 제어
- Admin API를 통한 사용량 관리

### 팀 관리 예시

```bash
# Admin API를 통한 팀 사용량 조회
curl -H "Authorization: Bearer YOUR_TOKEN" \
     https://api.cursor.com/v1/teams/usage
```

## 시작하기

### Cursor 1.0 업데이트

기존 Cursor 사용자라면:

1. **자동 업데이트 확인**
2. **새 기능 활성화**: Settings → Beta에서 원하는 기능 활성화
3. **BugBot 설정**: GitHub 연동 및 권한 설정

### 새로운 사용자

1. **Cursor 다운로드**: [cursor.sh](https://cursor.sh)
2. **계정 생성 및 로그인**
3. **프라이버시 설정**: Background Agent 사용을 위해 필요시 조정

## 버전별 주요 변화 타임라인

### 최근 업데이트 히스토리

**0.50 (May 15, 2025):**

- 통합 요청 기반 가격 정책
- 모든 최고급 모델에 Max Mode 지원
- 새로운 Tab 모델 도입

**0.49 (April 15, 2025):**

- 자동 규칙 생성 기능
- 향상된 에이전트 터미널 제어
- MCP 이미지 지원

**0.48 (March 23, 2025):**

- 채팅 탭 기능
- 커스텀 모드 (베타)
- 더 빠른 인덱싱

## 마무리

Cursor 1.0은 단순한 업데이트를 넘어서 AI 기반 개발 도구의 새로운 표준을 제시합니다. BugBot의 자동 코드 리뷰부터 Background Agent의 병렬 처리, Jupyter Notebook 지원까지, 모든 기능이 개발자의 생산성을 극대화하는 데 초점을 맞추고 있습니다.

특히 Memories 기능과 MCP 원클릭 설치는 AI와 개발자 간의 협업을 한 단계 더 발전시킨 혁신적인 기능들입니다. 데이터 과학자들에게는 Jupyter Notebook 지원이, 팀 단위로 작업하는 개발자들에게는 강화된 관리 도구들이 큰 도움이 될 것입니다.

지금 바로 Cursor 1.0을 경험해보고, AI가 만들어가는 코딩의 미래를 직접 느껴보시기 바랍니다!
