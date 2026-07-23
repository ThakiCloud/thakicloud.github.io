---
title: "실시간 음성 에이전트, 어디가 병목인가: 지연 예산 계산기와 GPU 서빙 실측"
seo_title: "실시간 음성 에이전트 지연 예산 + 자가호스팅 GPU 벤치 - Thaki Cloud"
seo_description: "발화 종료부터 첫 응답 소리까지의 지연을 단계별로 배분해 병목을 진단하는 공개 계산기 voice-latency-budget를 소개하고, RunPod H200에서 우리 실제 스택(Qwen3-ASR·VoxCPM2·Qwen3-TTS·Qwen3.5-9B)을 측정해 자가호스팅 음성 스택의 진짜 병목이 어디인지 정리합니다. 네트워크 볼륨 다운로드-원스 비용최적화와 teardown 보장 하네스까지 재현 가능하게 공개합니다."
excerpt: "내 음성 에이전트의 어느 단계가 병목인지 벤더 SDK 없이 진단하는 공개 도구를 만들고, RunPod H200에서 우리 실제 스택(Qwen3-ASR·VoxCPM2·Qwen3-TTS)을 측정했습니다. STT는 빠르고, 비스트리밍 TTS가 진짜 병목이었습니다."
date: 2026-07-19
tags:
  - voice-agent
  - latency
  - vllm
  - qwen3-asr
  - voxcpm2
  - qwen3-tts
  - runpod
  - gpu-serving
  - ttft
  - llmops
  - real-time
categories:
  - llmops
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/ko/llmops/voice-agent-latency-budget-gpu-serving/"
---

실시간 음성 에이전트를 만들어 본 사람이라면 같은 벽에 부딪힙니다. 사용자가 말을 멈추고 나서
에이전트가 첫 소리를 내기까지의 지연이 조금만 길어져도 대화가 어색해집니다. 그런데 막상 "내
스택의 어느 단계가 느린가"를 물으면 답이 쉽게 나오지 않습니다. 발화 종료 감지, 네트워크 왕복,
음성 인식(STT), LLM 첫 토큰, 음성 합성(TTS)이 사슬처럼 엮여 있고, 각 벤더의 SDK는 자기 구간의
숫자만 보여주기 때문입니다. 이 글은 그 전체 사슬을 한눈에 진단하려고 만든 공개 도구
voice-latency-budget와, 그 도구의 자가호스팅 시나리오를 실제 GPU에서 측정한 결과를 다룹니다.
이 글을 읽을 대상은 실시간 음성 에이전트를 직접 서빙하려는 인프라·AI 엔지니어입니다. 결론부터
말하면, GPU 자가호스팅에서 지연의 병목은 흔히 짐작하는 LLM이 아니라 동시성 설계와 TTS 선택에
있었습니다.

## 왜 지연 예산이라는 관점이 필요한가

사람과 사람이 대화할 때 상대의 말이 끝나고 내가 반응하기까지의 간격은 언어에 상관없이 중앙값이
약 200밀리초로 수렴한다는 연구가 있습니다(Stivers 외, 2009, PNAS). 실시간 음성 에이전트가
"사람 같다"고 느껴지려면 발화 종료부터 첫 응답 소리까지가 이 구간에 가까워야 하고, 실무에서는
서브초, 즉 800밀리초 아래를 유지하는 것을 흔한 목표로 삼습니다. 이 숫자는 벤더가 공개한 목표와도
대체로 맞습니다. Deepgram은 300밀리초 미만, Vapi는 500밀리초 미만을 이야기합니다.

문제는 이 총예산을 어떻게 나눠 쓰느냐입니다. 네트워크가 왕복 40밀리초를 먹고, STT가 300밀리초,
LLM 첫 토큰이 500밀리초를 쓰면 이미 예산이 초과됩니다. 어느 단계를 줄여야 가장 크게 이득인지
감으로 판단하기는 어렵습니다. 그래서 각 단계의 예상 지연을 넣으면 누적 타임라인과 병목, 그리고
자연스러운 대화 구간에 드는지 여부를 즉시 보여주는 계산기를 만들었습니다. 완전히 클라이언트
사이드로 동작하고, 서버도 API 키도 없으며, 입력은 브라우저를 벗어나지 않습니다. 특정 제품을
홍보하지 않는 공공재 도구를 지향했습니다.

도구는 발화 종료 감지, 네트워크 왕복, STT, LLM 첫 토큰, 첫 문장 생성, TTS 합성, 재생 버퍼의
일곱 단계를 다룹니다. 각 단계의 슬라이더 힌트에는 2025년부터 2026년까지의 공개 자료에서 뽑은
일반 범위가 붙어 있고, 병목이 그 범위를 넘으면 처방을 띄웁니다. 프리셋으로 시작점을 잡고,
비교 모드로 두 구성을 겹쳐 보고, 부하가 걸렸을 때의 대략적인 p95도 함께 보여줍니다.

일곱 단계는 사슬처럼 이어지고, 이 지연들의 총합이 목표 예산 안에 들어와야 대화가 자연스럽게 느껴집니다. 아래 흐름에서 실제로 예산을 가장 크게 잡아먹는 병목은 비스트리밍 TTS였습니다.

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
<div class="d3-arch" data-arch-root id="tlatencybudgetgpuserving-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 212, "height": 1098, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 31, "y": 24, "w": 142, "h": 62, "title": ["End of utterance", "detection"]}, {"id": "B", "x": 42, "y": 164, "w": 120, "h": 62, "title": ["Network", "round-trip"]}, {"id": "C", "x": 31, "y": 304, "w": 142, "h": 62, "title": ["STT", "Qwen3-ASR ~133ms"]}, {"id": "D", "x": 42, "y": 444, "w": 120, "h": 62, "title": ["LLM", "first token"]}, {"id": "E", "x": 38, "y": 584, "w": 128, "h": 62, "title": ["First sentence", "ready"]}, {"id": "F", "x": 38, "y": 724, "w": 128, "h": 62, "title": ["TTS synthesis", "the bottleneck"]}, {"id": "G", "x": 42, "y": 864, "w": 120, "h": 62, "title": ["Playback", "buffer"]}, {"id": "H", "x": 24, "y": 1004, "w": 156, "h": 62, "title": ["First audio out", "target under 800ms"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [102, 86, 102, 164]}, {"src": "B", "dst": "C", "kind": "data", "line": [102, 226, 102, 304]}, {"src": "C", "dst": "D", "kind": "data", "line": [102, 366, 102, 444]}, {"src": "D", "dst": "E", "kind": "data", "line": [102, 506, 102, 584]}, {"src": "E", "dst": "F", "kind": "data", "line": [102, 646, 102, 724]}, {"src": "F", "dst": "G", "kind": "data", "line": [102, 786, 102, 864]}, {"src": "G", "dst": "H", "kind": "data", "line": [102, 926, 102, 1004]}]});
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
      const container = document.getElementById('tlatencybudgetgpuserving-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'tlatencybudgetgpuserving-1';
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

## 자가호스팅이라면 숫자가 어떻게 바뀌나

관리형 스트리밍 API의 지연 범위는 문서로 어느 정도 알 수 있습니다. 그러나 "우리가 실제로 쓰는
엔진을 GPU에 올리면 얼마가 나오는가"는 직접 재보지 않으면 알 수 없습니다. 그래서 우리가 로컬
MacBook에서 개발용으로 돌리던 바로 그 스택을 RunPod H200(141GB)에 올려 측정했습니다. 엔진은
STT에 Qwen3-ASR-1.7B, TTS에 VoxCPM2와 Qwen3-TTS-1.7B 두 가지, LLM에 최신 Qwen3.5-9B를 썼습니다.

비용을 아끼는 방식부터 적어 둡니다. GPU pod마다 수십 기가바이트의 모델과 CUDA 휠을 매번 새로
내려받으면 비싼 GPU가 다운로드를 기다리며 노는 시간에 요금이 붙습니다. 그래서 네트워크 볼륨 하나에
가상환경과 가중치를 딱 한 번만 내려받고(67기가바이트), GPU pod이 그 볼륨을 마운트해 재다운로드
없이 벤치했습니다. 끝나면 pod과 볼륨을 전부 삭제하도록 teardown을 finally 블록과 이름 기반
안전망으로 보장했습니다. 디버깅까지 포함한 전체 비용은 약 17달러였고 누수된 자원은 없었습니다.

## 측정 결과: 병목은 LLM도 STT도 아닌 TTS였다

단일 요청 기준으로 H200에서 재본 값은 이렇습니다.

| 엔진 | 모델 | 지연(단일) | 실시간 계수(RTF) |
|---|---|---|---|
| STT | Qwen3-ASR-1.7B | 133밀리초 / 10초 오디오 | 0.013 |
| TTS | VoxCPM2 (비스트리밍) | 673밀리초 / 문장 | 0.149 |
| TTS | Qwen3-TTS-1.7B (비스트리밍) | 6778밀리초 / 문장 | 1.205 |

STT는 걱정할 단계가 아니었습니다. Qwen3-ASR가 10초 오디오를 133밀리초에 전사합니다. 실시간
계수 0.013이면 사실상 즉시입니다. 진짜 이야기는 TTS에 있었습니다. 같은 한국어 문장을 같은 H200
에서 VoxCPM2는 0.67초에, Qwen3-TTS는 6.8초에 합성했습니다. 같은 카드에서 VoxCPM2가 열 배 가까이
빠릅니다. 그리고 두 엔진 모두 비스트리밍이라는 점이 중요합니다. 문장 전체를 합성한 뒤에야 첫
소리가 나오기 때문에, VoxCPM2의 0.67초조차 "스트리밍 100밀리초 TTFA"가 아니라 "0.67초 뒤 첫
소리"입니다. 로컬 MPS에서 초 단위였던 VoxCPM2가 GPU에서 0.67초로 준 것은 맞지만, 그렇다고
스트리밍이 된 것은 아닙니다. 실시간 턴을 만들려면 스트리밍 TTS로 바꾸거나 문장을 짧게 쪼개
합성해야 합니다. 이 도구를 만든 이유가 바로 이 지점을 숫자로 보이게 하려는 것이었습니다.

## 정직한 공백: LLM은 이 호스트에서 막혔다

Qwen3.5-9B의 vLLM 서빙 수치는 이번에 얻지 못했습니다. 원인은 성능이 아니라 인프라 버전 불일치
였습니다. 2026년 7월 기준 최신 vLLM은 CUDA 13용 torch를 당겨오는데, 우리가 배정받은 H200 호스트의
드라이버가 CUDA 12.8이라 "드라이버가 너무 낡았다"며 엔진이 뜨지 않았습니다. torch를 12.8용으로
낮추면 이번엔 vLLM의 컴파일된 연산이 깨졌고, transformers로 우회하니 멀티모달 생성 경로에서
에러가 났습니다. 엔진마다 요구하는 torch가 달라 하나를 맞추면 다른 하나가 깨지는 전형적인
의존성 충돌입니다. 깨끗한 vLLM 수치를 얻으려면 CUDA 13 드라이버가 깔린 호스트가 필요합니다.
계산기의 LLM 슬라이더에는 추정치를 넣고 추정임을 명시했습니다. 최신 모델을 최신 스택으로
서빙하려다 구형 드라이버에 걸리는 것도 자가호스팅의 현실적인 함정이라, 감추기보다 그대로 적어
둡니다.

## 어떻게 셋팅해서 서비스할까

측정을 레시피로 옮기면 이렇게 됩니다. STT는 Qwen3-ASR로 충분하니 그대로 두고, TTS는 두 엔진
중 열 배 빠른 VoxCPM2를 택하되 스트리밍이나 문장 청크로 첫 소리를 앞당깁니다. Qwen3-TTS의
비스트리밍 6.8초는 실시간 턴에 그대로 쓸 수 없습니다. LLM은 CUDA 13 드라이버 호스트에서 vLLM으로
올립니다. 세 엔진을 같은 노드에 두어 네트워크 홉을 없애고, 첫 문장이 나오는 즉시 TTS를 시작하는
문장 단위 스트리밍을 씁니다. 우리 로컬 MacBook 스택은 개발용이지 서빙 시스템이 아니며, 계산기의
로컬 프리셋도 "실시간 부적합 사례"로 명시해 두었습니다.

이 과정은 재현 가능하게 공개했습니다. 계산기는 브라우저에서 바로 열 수 있고, 벤치 하네스는 볼륨
생성부터 다운로드, GPU 벤치, 전체 삭제까지를 한 스크립트로 묶었습니다. 실측 결과 JSON과 서빙
가이드도 저장소에 정리해 두었습니다. 자가호스팅 음성 스택의 지연을 감이 아니라 숫자로 이야기하고
싶은 분들에게 출발점이 되기를 바랍니다.

- 계산기: [voice-latency-budget](https://sylvanus4.github.io/voice-latency-budget/)
- 저장소와 벤치 하네스, 서빙 가이드: [github.com/sylvanus4/voice-latency-budget](https://github.com/sylvanus4/voice-latency-budget)
