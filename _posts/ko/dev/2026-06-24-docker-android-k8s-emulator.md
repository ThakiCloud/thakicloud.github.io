---
title: "Android 에뮬레이터를 컨테이너로 - docker-android로 K8s 위에 재현 가능한 디바이스 팜 만들기"
excerpt: "docker-android는 Android 에뮬레이터를 단일 컨테이너로 패키징해 헤드리스로 띄우는 오픈소스 프로젝트입니다. 이미지 크기와 KVM 요구사항을 실제 문서 기준으로 확인하고, ThakiCloud K8s 플랫폼에서 디바이스 패스스루 워크로드를 운용하는 관점을 정리합니다."
seo_title: "docker-android K8s 에뮬레이터 - 컨테이너 Android 디바이스 팜 구축 - Thaki Cloud"
seo_description: "docker-android로 Android 에뮬레이터를 헤드리스 컨테이너로 띄우는 방법. KVM 패스스루, GPU 가속, scrcpy 원격 제어, CI/CD 테스트 자동화를 ThakiCloud Kubernetes 기반으로 운용하는 실전 가이드."
date: 2026-06-24
last_modified_at: 2026-06-24
tags:
  - docker
  - android
  - kubernetes
  - kvm
  - ci-cd
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ko/dev/docker-android-k8s-emulator/"
reading_time: true
categories:
  - dev
published: false
---

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
<div class="d3-arch" data-arch-root id="dockerandroidk8semulator-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 351, "height": 582, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [{"x": 28, "y": 24, "w": 287, "h": 278, "label": "KVM 활성 K8s 노드 / Pod", "lx": 40, "ly": 42}], "nodes": [{"id": "EMU", "x": 66, "y": 201, "w": 212, "h": 62, "title": ["Android 에뮬레이터 (QEMU + KVM,", "옵션 CUDA)"]}, {"id": "KVM", "x": 112, "y": 63, "w": 120, "h": 46, "title": "/dev/kvm"}, {"id": "SVC", "x": 112, "y": 380, "w": 120, "h": 46, "title": "ADB Service"}, {"id": "CI", "x": 199, "y": 504, "w": 120, "h": 46, "title": "CI 팜"}, {"id": "SCRCPY", "x": 24, "y": 504, "w": 120, "h": 46, "title": "scrcpy 원격 제어"}], "edges": [{"src": "KVM", "dst": "EMU", "kind": "data", "label": "passthrough", "line": [172, 109, 172, 201], "lx": 172, "ly": 151}, {"src": "EMU", "dst": "SVC", "kind": "data", "line": [172, 263, 172, 380]}, {"src": "SVC", "dst": "CI", "kind": "data", "curve": [[204, 426], [259, 465], [259, 465], [259, 504]]}, {"src": "SVC", "dst": "SCRCPY", "kind": "data", "curve": [[139, 426], [84, 465], [84, 465], [84, 504]]}]});
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
      const container = document.getElementById('dockerandroidk8semulator-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'dockerandroidk8semulator-1';
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

모바일 앱을 테스트하려면 Android 디바이스가 필요합니다. 실제 단말을 여러 대 두는 방식은 관리가 번거롭고, 로컬에 무거운 에뮬레이터를 까는 방식은 환경이 사람마다 달라져 재현성이 떨어집니다. CI 파이프라인에 Android 테스트를 넣으려고 하면 이 문제는 더 커집니다. 빌드 노드마다 에뮬레이터를 일관되게 깔아야 하기 때문입니다.

`docker-android`(HQarroum 버전)는 이 문제를 컨테이너로 풉니다. Android 에뮬레이터를 최소 구성으로 패키징해 헤드리스로 띄우고, ADB와 화면 제어를 네트워크 너머로 노출합니다. 컨테이너 한 개로 깨끗하고 일관된 Android 환경을 초 단위로 만들 수 있으므로, CI/CD와 자동화 테스트에 잘 맞습니다.

이 글에서는 docker-android의 구조와 실제 요구사항을 문서 기준으로 확인하고, ThakiCloud의 Kubernetes 플랫폼 관점에서 이런 디바이스 클래스 워크로드를 어떻게 다룰 수 있는지를 정리합니다. AI/ML이 주제인 우리 플랫폼에서 모바일 에뮬레이터가 곧장 핵심은 아니지만, KVM 디바이스 패스스루와 GPU 가속이 필요한 컨테이너 워크로드를 어떻게 격리해 운용하는가라는 질문은 우리 인프라 역량과 직접 닿아 있습니다.

---

## docker-android는 무엇인가

HQarroum의 docker-android는 Alpine 기반의 작은 이미지에 Android 에뮬레이터와 KVM 지원, 그리고 JRE 11을 묶은 프로젝트입니다(현재 버전 1.1.0). 설계 초점은 분명합니다. 네트워크로 원격 제어 가능한 완전한 Android 에뮬레이터를, 최소한의 소프트웨어만으로 노출하는 것입니다. 이미지 안에는 에뮬레이터, 외부에서 접속하기 위한 ADB 서버, 그리고 libvirt를 갖춘 QEMU만 들어갑니다.

주요 특징은 다음과 같습니다.

- **최소 구성**: Alpine 기반으로 크기를 최적화했습니다. SDK와 에뮬레이터를 빼고 빌드하면 이미지가 훨씬 작아집니다.
- **커스터마이즈**: Android 버전, 디바이스 타입, 이미지 종류를 선택할 수 있습니다.
- **포트 포워딩 내장**: 에뮬레이터와 ADB를 컨테이너 네트워크 인터페이스로 노출합니다.
- **헤드리스**: GUI 없이 동작하므로 CI 팜에 적합합니다. [scrcpy](https://github.com/Genymobile/scrcpy)로 화면을 원격 제어할 수 있습니다.
- **재현성**: 에뮬레이터 이미지는 재시작할 때마다 초기화됩니다. 매번 같은 상태에서 시작한다는 뜻입니다.

위 다이어그램은 이 컨테이너를 ThakiCloud Kubernetes에 배치한 가정 구성입니다. KVM이 활성화된 노드의 파드에 에뮬레이터를 띄우고, `/dev/kvm`을 패스스루하며, GPU 가속이 필요하면 cuda 변형을 사용합니다. ADB는 Service로 노출해 CI 팜과 scrcpy가 접근합니다.

---

## 설치 및 통합

기본 빌드는 Android SDK, 플랫폼 도구, 에뮬레이터를 이미지에 함께 묶습니다. docker-compose로 띄우는 방법은 아래와 같습니다.

```bash
# 기본 에뮬레이터
docker compose up android-emulator

# GPU 가속
docker compose up android-emulator-cuda

# GPU 가속 + Google Play Store
docker compose up android-emulator-cuda-store
```

docker만 사용해 직접 빌드할 수도 있습니다.

```bash
docker build -t android-emulator .
```

이미지를 빌드한 뒤에는 KVM 드라이브를 마운트해 컨테이너를 실행합니다. Play Store 이미지를 쓰려면 에뮬레이터와 클라이언트가 같은 adbkey를 공유해야 하며, `adb keygen adbkey`로 키를 생성해 `./keys` 디렉터리에 넣습니다.

이미지 크기는 빌드 변형에 따라 크게 달라집니다. 저장소 문서에 명시된 비교표는 다음과 같습니다.

| 빌드 변형 | 압축 해제 | 압축 |
|---|---|---|
| API 33 + 에뮬레이터 | 5.84 GB | 1.97 GB |
| API 32 + 에뮬레이터 | 5.89 GB | 1.93 GB |
| API 28 + 에뮬레이터 | 4.29 GB | 1.46 GB |
| SDK·에뮬레이터 제외 | 414 MB | 138 MB |

에뮬레이터를 포함한 이미지는 압축 기준으로도 1.5GB 이상입니다. 다수의 노드에 분산 배포할 때는 레지스트리 대역폭과 노드 디스크를 함께 고려해야 합니다.

---

## 실제 동작 확인

이번 글에서는 컨테이너의 실제 부팅까지는 검증하지 못했습니다. 정직하게 기록합니다. 재현 시도 중 실패: 작업 호스트에 Docker 데몬이 없고, macOS는 `/dev/kvm`을 제공하지 않아 에뮬레이터 컨테이너가 부팅되지 않습니다. docker-android는 KVM 하드웨어 가속을 요구하므로, 실제 구동은 Linux 호스트 또는 중첩 가상화를 지원하는 KVM 노드에서만 가능합니다.

대신 검증 가능한 사실은 저장소 문서에서 직접 확인했습니다. 위 이미지 크기 비교표는 문서에 명시된 실제 수치이며, 빌드 변형과 compose 서비스 이름, KVM 마운트 요구사항도 문서 기준입니다. 측정하지 못한 부팅 시간이나 테스트 처리량 같은 수치는 만들어 넣지 않았습니다. 실제 도입 단계에서는 KVM 노드를 확보한 뒤 컨테이너 부팅 시간, ADB 연결 지연, 동시 실행 가능한 에뮬레이터 수를 직접 측정하는 절차가 필요합니다.

---

## ThakiCloud K8s AI/ML SaaS 플랫폼 적용 및 시사점

docker-android 자체는 AI/ML 도구가 아닙니다. 그러나 이 프로젝트가 드러내는 운영 요구사항은 ThakiCloud가 잘하는 영역과 정확히 겹칩니다.

첫째, **디바이스 패스스루 워크로드의 격리**입니다. 에뮬레이터는 `/dev/kvm`을 요구하는 특권 컨테이너에 가깝습니다. K8s에서 이런 디바이스 클래스 워크로드를 멀티테넌트 환경에서 안전하게 격리하려면, 노드 선택, 디바이스 플러그인, 보안 컨텍스트를 신중히 다뤄야 합니다. ThakiCloud는 이미 GPU를 device plugin과 Kueue로 큐잉하고 있으며, KVM 패스스루도 같은 패턴으로 다룰 수 있습니다.

둘째, **재현 가능한 테스트 팜**입니다. 헤드리스 에뮬레이터를 컨테이너로 묶으면, 깨끗한 환경을 노드 수만큼 수평 확장할 수 있습니다. CI/CD에서 Appium UI 테스트를 다수 병렬로 돌리는 구성은 K8s 잡 스케줄링의 전형적인 사용처입니다.

셋째, 더 멀리 보면 **온디바이스 AI 검증**으로 확장할 수 있습니다. 모바일에서 동작하는 경량 모델이나 에이전트의 동작을 자동화로 검증하려면, 격리된 Android 환경을 다수 띄워 회귀 테스트를 돌리는 디바이스 팜이 유용합니다. 현재 우리 플랫폼의 핵심은 아니지만, 멀티테넌트 GPU·디바이스 오케스트레이션 역량이 성숙해지면 이런 모바일 AI QA 팜도 같은 인프라 위에서 제공 가능한 형태로 확장할 수 있습니다.

요약하면, docker-android는 그 자체로 우리 제품은 아니지만 "특권·디바이스·GPU 가속이 얽힌 무거운 컨테이너 워크로드를 K8s에서 어떻게 길들이는가"라는 좋은 사례입니다. 이는 ThakiCloud가 강조하는 범용 K8s 오케스트레이션 역량을 보여 주는 구체적인 그림입니다.

---

## 한계 및 반론

- **무거운 의존성**: KVM 하드웨어 가속은 협상 대상이 아닙니다. 중첩 가상화를 지원하지 않는 환경에서는 성능이 급격히 떨어지거나 아예 부팅되지 않습니다. 클라우드 노드 선택이 곧 제약이 됩니다.
- **이미지 비대**: 에뮬레이터 포함 이미지는 압축해도 수 GB입니다. 노드 다수에 분산하면 레지스트리와 디스크 비용이 누적됩니다.
- **AI/ML 적합성의 거리**: 솔직히 이 도구는 우리 플랫폼의 핵심 워크로드인 학습·추론과는 거리가 있습니다. 모바일 테스트 수요가 없는 조직에는 직접적인 가치가 작습니다. 이 글의 가치는 "에뮬레이터 그 자체"가 아니라 "디바이스 패스스루 컨테이너의 운영 패턴"에 있습니다.
- **특권 컨테이너의 보안**: `/dev/kvm` 접근과 특권 설정은 멀티테넌트 보안 경계를 복잡하게 만듭니다. 테넌트 격리를 깨지 않으려면 전용 노드 풀과 엄격한 정책이 필요합니다.

결론적으로 docker-android는 모바일 테스트 자동화에 강력한 도구이며, 동시에 K8s에서 디바이스 클래스 워크로드를 다루는 방법을 보여 주는 교본입니다. 우리에게 직접 필요한 순간이 오기 전이라도, 그 운영 패턴은 미리 익혀 둘 가치가 있습니다.

---

## 출처

- docker-android (HQarroum): [https://github.com/HQarroum/docker-android](https://github.com/HQarroum/docker-android)
- Docker Hub 이미지: `halimqarroum/docker-android`
- scrcpy (원격 화면 제어): [https://github.com/Genymobile/scrcpy](https://github.com/Genymobile/scrcpy)
- 원 트윗(RT): [https://x.com/hjguyhan/status/2069427245295493446](https://x.com/hjguyhan/status/2069427245295493446)
