---
title: "NVIDIA TensorRT-LLM 완전 가이드: Docker 최적화부터 Kubernetes 배포까지"
excerpt: "NVIDIA TensorRT-LLM을 활용하여 고성능 LLM 추론 서비스를 구축하고, 최소 Docker 이미지 생성부터 Helm을 통한 Kubernetes 배포까지 단계별로 구현하는 실전 가이드입니다."
date: 2025-06-21
tags: 
  - TensorRT-LLM
  - NVIDIA
  - Docker
  - Kubernetes
  - Helm
  - LLM
  - Inference
  - GPU
author_profile: true
toc: true
toc_label: "TensorRT-LLM 배포 가이드"
published: false
categories:
  - llmops
  - tutorials
---

## 개요

NVIDIA TensorRT-LLM은 GPU에서 대규모 언어 모델(LLM) 추론을 최적화하는 오픈소스 라이브러리입니다. 이 가이드에서는 [NVIDIA TensorRT-LLM](https://github.com/NVIDIA/TensorRT-LLM)을 활용하여 프로덕션 환경에서 고성능 LLM 서비스를 구축하는 전체 과정을 다룹니다.

### TensorRT-LLM의 주요 특징

- **최적화된 성능**: 커스텀 어텐션 커널, 인플라이트 배칭, 페이지드 KV 캐싱
- **다양한 양자화**: FP8, FP4, INT4 AWQ, INT8 SmoothQuant 지원
- **PyTorch 백엔드**: 빠른 개발 및 실험을 위한 유연한 워크플로우
- **확장성**: 단일 GPU부터 멀티노드 배포까지 지원

## 시스템 아키텍처

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
<div class="d3-arch" data-arch-root id="sdeploymentcompleteguide-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 886, "height": 598, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 716, "y": 24, "w": 120, "h": 46, "title": "클라이언트 요청"}, {"id": "B", "x": 698, "y": 148, "w": 156, "h": 46, "title": "Kubernetes Ingress"}, {"id": "C", "x": 594, "y": 272, "w": 170, "h": 46, "title": "TensorRT-LLM Service"}, {"id": "D", "x": 276, "y": 396, "w": 142, "h": 46, "title": "TensorRT-LLM Pod"}, {"id": "E", "x": 287, "y": 520, "w": 120, "h": 46, "title": "GPU 노드"}, {"id": "F", "x": 287, "y": 24, "w": 120, "h": 46, "title": "Helm Chart"}, {"id": "G", "x": 374, "y": 272, "w": 120, "h": 46, "title": "ConfigMap"}, {"id": "H", "x": 199, "y": 272, "w": 120, "h": 46, "title": "Deployment"}, {"id": "I", "x": 523, "y": 148, "w": 120, "h": 46, "title": "Service"}, {"id": "J", "x": 24, "y": 272, "w": 120, "h": 46, "title": "HPA"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [776, 70, 776, 148]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[776, 194], [776, 233], [776, 233], [715, 272]]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[679, 318], [679, 357], [679, 357], [418, 406]]}, {"src": "D", "dst": "E", "kind": "data", "line": [347, 442, 347, 520]}, {"src": "F", "dst": "G", "kind": "data", "curve": [[379, 70], [434, 109], [434, 233], [434, 272]]}, {"src": "F", "dst": "H", "kind": "data", "curve": [[314, 70], [259, 109], [259, 233], [259, 272]]}, {"src": "F", "dst": "I", "kind": "data", "curve": [[407, 63], [583, 109], [583, 109], [583, 148]]}, {"src": "F", "dst": "J", "kind": "data", "curve": [[287, 61], [84, 109], [84, 233], [84, 272]]}, {"src": "G", "dst": "D", "kind": "data", "curve": [[434, 318], [434, 357], [434, 357], [379, 396]]}, {"src": "H", "dst": "D", "kind": "data", "curve": [[259, 318], [259, 357], [259, 357], [314, 396]]}, {"src": "I", "dst": "C", "kind": "data", "curve": [[583, 194], [583, 233], [583, 233], [643, 272]]}, {"src": "J", "dst": "D", "kind": "data", "curve": [[84, 318], [84, 357], [84, 357], [276, 402]]}]});
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
      const container = document.getElementById('sdeploymentcompleteguide-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'sdeploymentcompleteguide-1';
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

## 환경 요구사항

### 하드웨어 요구사항
- NVIDIA GPU (Compute Capability 7.0+)
- CUDA 12.4+
- 최소 16GB GPU 메모리 (모델에 따라 다름)

### 소프트웨어 요구사항
- Docker 20.10+
- Kubernetes 1.24+
- Helm 3.8+
- NVIDIA Container Toolkit

## 단계 1: 개발 환경 설정

### 1.1 프로젝트 초기화

```bash
# 프로젝트 디렉토리 생성
mkdir tensorrt-llm-deployment
cd tensorrt-llm-deployment

# 디렉토리 구조 생성
mkdir -p {docker,helm,scripts,configs}
```

### 1.2 TensorRT-LLM 설치 및 테스트

```bash
# Python 환경 설정
python -m venv tensorrt-env
source tensorrt-env/bin/activate

# TensorRT-LLM 설치
pip install tensorrt-llm --extra-index-url https://pypi.nvidia.com
```

### 1.3 기본 추론 테스트

```python
# test_inference.py
import torch
from tensorrt_llm import LLM, SamplingParams

def test_basic_inference():
    """기본 추론 테스트"""
    
    # LLM 초기화 (예: Llama-2-7B)
    llm = LLM(
        model="meta-llama/Llama-2-7b-chat-hf",
        tensor_parallel_size=1,
        dtype="float16"
    )
    
    # 샘플링 파라미터 설정
    sampling_params = SamplingParams(
        temperature=0.8,
        top_p=0.95,
        max_tokens=512
    )
    
    # 추론 실행
    prompts = ["Hello, how are you?", "What is machine learning?"]
    outputs = llm.generate(prompts, sampling_params)
    
    for output in outputs:
        print(f"Prompt: {output.prompt}")
        print(f"Generated: {output.outputs[0].text}")
        print("-" * 50)

if __name__ == "__main__":
    test_basic_inference()
```

## 단계 2: 최적화된 Docker 이미지 구축

### 2.1 멀티스테이지 Dockerfile

```dockerfile
# docker/Dockerfile
# Stage 1: Build stage
FROM nvcr.io/nvidia/tensorrt:24.02-py3 as builder

WORKDIR /workspace

# 시스템 의존성 설치
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-dev \
    build-essential \
    cmake \
    git \
    && rm -rf /var/lib/apt/lists/*

# Python 의존성 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# TensorRT-LLM 설치
RUN pip install --no-cache-dir tensorrt-llm \
    --extra-index-url https://pypi.nvidia.com

# Stage 2: Runtime stage
FROM nvcr.io/nvidia/cuda:12.4-runtime-ubuntu22.04

WORKDIR /app

# 런타임 의존성만 설치
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    libcudnn8 \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# 빌드 스테이지에서 Python 환경 복사
COPY --from=builder /usr/local/lib/python3.10/dist-packages /usr/local/lib/python3.10/dist-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# 애플리케이션 코드 복사
COPY src/ ./src/
COPY configs/ ./configs/

# 환경 변수 설정
ENV PYTHONPATH=/app
ENV CUDA_VISIBLE_DEVICES=0

# 비루트 사용자 생성
RUN groupadd -r tensorrt && useradd -r -g tensorrt tensorrt
RUN chown -R tensorrt:tensorrt /app
USER tensorrt

# 헬스체크 추가
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD python3 -c "import requests; requests.get('http://localhost:8000/health')"

EXPOSE 8000

CMD ["python3", "src/server.py"]
```

### 2.2 의존성 파일

```txt
# requirements.txt
fastapi==0.104.1
uvicorn[standard]==0.24.0
pydantic==2.5.0
torch==2.1.0
transformers==4.36.0
accelerate==0.24.1
numpy==1.24.3
```

### 2.3 FastAPI 서버 구현

```python
# src/server.py
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import torch
import logging
import os
from tensorrt_llm import LLM, SamplingParams

# 로깅 설정
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="TensorRT-LLM API Server", version="1.0.0")

class GenerationRequest(BaseModel):
    prompt: str
    max_tokens: int = 512
    temperature: float = 0.8
    top_p: float = 0.95
    stream: bool = False

class GenerationResponse(BaseModel):
    text: str
    tokens_used: int
    latency_ms: float

class TensorRTLLMService:
    def __init__(self):
        self.model = None
        self.load_model()
    
    def load_model(self):
        """모델 로드"""
        try:
            model_path = os.getenv("MODEL_PATH", "meta-llama/Llama-2-7b-chat-hf")
            tensor_parallel_size = int(os.getenv("TENSOR_PARALLEL_SIZE", "1"))
            
            logger.info(f"Loading model: {model_path}")
            
            self.model = LLM(
                model=model_path,
                tensor_parallel_size=tensor_parallel_size,
                dtype="float16",
                trust_remote_code=True
            )
            
            logger.info("Model loaded successfully")
            
        except Exception as e:
            logger.error(f"Failed to load model: {e}")
            raise
    
    def generate(self, request: GenerationRequest) -> GenerationResponse:
        """텍스트 생성"""
        import time
        
        start_time = time.time()
        
        sampling_params = SamplingParams(
            temperature=request.temperature,
            top_p=request.top_p,
            max_tokens=request.max_tokens
        )
        
        outputs = self.model.generate([request.prompt], sampling_params)
        
        end_time = time.time()
        latency_ms = (end_time - start_time) * 1000
        
        generated_text = outputs[0].outputs[0].text
        tokens_used = len(outputs[0].outputs[0].token_ids)
        
        return GenerationResponse(
            text=generated_text,
            tokens_used=tokens_used,
            latency_ms=latency_ms
        )

# 전역 서비스 인스턴스
service = TensorRTLLMService()

@app.get("/health")
async def health_check():
    """헬스 체크"""
    return {"status": "healthy", "model_loaded": service.model is not None}

@app.post("/generate", response_model=GenerationResponse)
async def generate_text(request: GenerationRequest):
    """텍스트 생성 API"""
    try:
        response = service.generate(request)
        return response
    except Exception as e:
        logger.error(f"Generation failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/metrics")
async def get_metrics():
    """메트릭 정보"""
    gpu_memory = torch.cuda.memory_allocated() if torch.cuda.is_available() else 0
    return {
        "gpu_memory_used": gpu_memory,
        "gpu_available": torch.cuda.is_available(),
        "gpu_count": torch.cuda.device_count()
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

### 2.4 Docker 이미지 빌드

```bash
# scripts/build-docker.sh
#!/bin/bash

set -e

# 환경 변수
IMAGE_NAME="tensorrt-llm-server"
TAG=${1:-"latest"}
REGISTRY=${REGISTRY:-"your-registry.com"}

echo "Building TensorRT-LLM Docker image..."

# Docker 빌드
docker build \
    -t ${IMAGE_NAME}:${TAG} \
    -f docker/Dockerfile \
    .

# 이미지 크기 확인
echo "Image size:"
docker images ${IMAGE_NAME}:${TAG}

# 레지스트리에 푸시 (옵션)
if [ "$PUSH" = "true" ]; then
    echo "Pushing to registry..."
    docker tag ${IMAGE_NAME}:${TAG} ${REGISTRY}/${IMAGE_NAME}:${TAG}
    docker push ${REGISTRY}/${IMAGE_NAME}:${TAG}
fi

echo "Build completed successfully!"
```

## 단계 3: Helm Chart 구성

### 3.1 Chart 구조 생성

```bash
# Helm Chart 생성
helm create helm/tensorrt-llm
cd helm/tensorrt-llm

# 불필요한 파일 제거
rm -rf templates/tests
rm templates/hpa.yaml templates/ingress.yaml
```

### 3.2 Values 파일 구성

```yaml
# helm/tensorrt-llm/values.yaml
replicaCount: 1

image:
  repository: tensorrt-llm-server
  pullPolicy: IfNotPresent
  tag: "latest"

nameOverride: ""
fullnameOverride: ""

serviceAccount:
  create: true
  annotations: {}
  name: ""

podAnnotations: {}

podSecurityContext:
  fsGroup: 1000

securityContext:
  capabilities:
    drop:
    - ALL
  readOnlyRootFilesystem: false
  runAsNonRoot: true
  runAsUser: 1000

service:
  type: ClusterIP
  port: 8000

ingress:
  enabled: false
  className: ""
  annotations: {}
  hosts:
    - host: tensorrt-llm.local
      paths:
        - path: /
          pathType: Prefix
  tls: []

resources:
  limits:
    nvidia.com/gpu: 1
    memory: 16Gi
    cpu: 4
  requests:
    nvidia.com/gpu: 1
    memory: 8Gi
    cpu: 2

autoscaling:
  enabled: true
  minReplicas: 1
  maxReplicas: 5
  targetCPUUtilizationPercentage: 70
  targetMemoryUtilizationPercentage: 80

nodeSelector:
  accelerator: nvidia-tesla-v100

tolerations:
  - key: nvidia.com/gpu
    operator: Exists
    effect: NoSchedule

affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: accelerator
          operator: In
          values:
          - nvidia-tesla-v100
          - nvidia-tesla-a100

# TensorRT-LLM 특정 설정
tensorrtllm:
  model:
    path: "meta-llama/Llama-2-7b-chat-hf"
    tensorParallelSize: 1
  
  inference:
    maxTokens: 512
    temperature: 0.8
    topP: 0.95

# 모니터링 설정
monitoring:
  enabled: true
  serviceMonitor:
    enabled: true
    interval: 30s
  
# 로깅 설정
logging:
  level: INFO
  format: json
```

### 3.3 Deployment 템플릿

{% raw %}
```yaml
# helm/tensorrt-llm/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "tensorrt-llm.fullname" . }}
  labels:
    {{- include "tensorrt-llm.labels" . | nindent 4 }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "tensorrt-llm.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      {{- with .Values.podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      labels:
        {{- include "tensorrt-llm.selectorLabels" . | nindent 8 }}
    spec:
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "tensorrt-llm.serviceAccountName" . }}
      securityContext:
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
      containers:
        - name: {{ .Chart.Name }}
          securityContext:
            {{- toYaml .Values.securityContext | nindent 12 }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: 8000
              protocol: TCP
          env:
            - name: MODEL_PATH
              value: {{ .Values.tensorrtllm.model.path | quote }}
            - name: TENSOR_PARALLEL_SIZE
              value: {{ .Values.tensorrtllm.model.tensorParallelSize | quote }}
            - name: MAX_TOKENS
              value: {{ .Values.tensorrtllm.inference.maxTokens | quote }}
            - name: TEMPERATURE
              value: {{ .Values.tensorrtllm.inference.temperature | quote }}
            - name: TOP_P
              value: {{ .Values.tensorrtllm.inference.topP | quote }}
            - name: LOG_LEVEL
              value: {{ .Values.logging.level | quote }}
          livenessProbe:
            httpGet:
              path: /health
              port: http
            initialDelaySeconds: 120
            periodSeconds: 30
            timeoutSeconds: 10
            failureThreshold: 3
          readinessProbe:
            httpGet:
              path: /health
              port: http
            initialDelaySeconds: 60
            periodSeconds: 10
            timeoutSeconds: 5
            failureThreshold: 3
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
          volumeMounts:
            - name: model-cache
              mountPath: /root/.cache
            - name: tmp
              mountPath: /tmp
      volumes:
        - name: model-cache
          emptyDir:
            sizeLimit: 50Gi
        - name: tmp
          emptyDir: {}
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
```
{% endraw %}

### 3.4 HPA 구성

{% raw %}
```yaml
# helm/tensorrt-llm/templates/hpa.yaml
{{- if .Values.autoscaling.enabled }}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ include "tensorrt-llm.fullname" . }}
  labels:
    {{- include "tensorrt-llm.labels" . | nindent 4 }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ include "tensorrt-llm.fullname" . }}
  minReplicas: {{ .Values.autoscaling.minReplicas }}
  maxReplicas: {{ .Values.autoscaling.maxReplicas }}
  metrics:
    {{- if .Values.autoscaling.targetCPUUtilizationPercentage }}
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: {{ .Values.autoscaling.targetCPUUtilizationPercentage }}
    {{- end }}
    {{- if .Values.autoscaling.targetMemoryUtilizationPercentage }}
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: {{ .Values.autoscaling.targetMemoryUtilizationPercentage }}
    {{- end }}
{{- end }}
```
{% endraw %}

### 3.5 ServiceMonitor 구성

{% raw %}
```yaml
# helm/tensorrt-llm/templates/servicemonitor.yaml
{{- if and .Values.monitoring.enabled .Values.monitoring.serviceMonitor.enabled }}
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: {{ include "tensorrt-llm.fullname" . }}
  labels:
    {{- include "tensorrt-llm.labels" . | nindent 4 }}
spec:
  selector:
    matchLabels:
      {{- include "tensorrt-llm.selectorLabels" . | nindent 6 }}
  endpoints:
  - port: http
    path: /metrics
    interval: {{ .Values.monitoring.serviceMonitor.interval }}
{{- end }}
```
{% endraw %}

## 단계 4: Kubernetes 클러스터 준비

### 4.1 GPU 노드 설정

```bash
# scripts/setup-gpu-nodes.sh
#!/bin/bash

echo "Setting up GPU nodes for Kubernetes..."

# NVIDIA Container Toolkit 설치
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

# Docker 설정
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

# NVIDIA Device Plugin 설치
kubectl apply -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.14.0/nvidia-device-plugin.yml

echo "GPU nodes setup completed!"
```

### 4.2 네임스페이스 및 RBAC 설정

```yaml
# configs/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: tensorrt-llm
  labels:
    name: tensorrt-llm
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: tensorrt-llm-quota
  namespace: tensorrt-llm
spec:
  hard:
    requests.nvidia.com/gpu: "4"
    limits.nvidia.com/gpu: "4"
    requests.memory: "64Gi"
    limits.memory: "128Gi"
```

## 단계 5: 배포 및 운영

### 5.1 배포 스크립트

```bash
# scripts/deploy.sh
#!/bin/bash

set -e

NAMESPACE=${NAMESPACE:-"tensorrt-llm"}
RELEASE_NAME=${RELEASE_NAME:-"tensorrt-llm"}
VALUES_FILE=${VALUES_FILE:-"values.yaml"}

echo "Deploying TensorRT-LLM to Kubernetes..."

# 네임스페이스 생성
kubectl apply -f configs/namespace.yaml

# Helm 배포
helm upgrade --install ${RELEASE_NAME} ./helm/tensorrt-llm \
    --namespace ${NAMESPACE} \
    --values helm/tensorrt-llm/${VALUES_FILE} \
    --wait \
    --timeout 10m

# 배포 상태 확인
kubectl get pods -n ${NAMESPACE}
kubectl get svc -n ${NAMESPACE}

echo "Deployment completed successfully!"

# 서비스 테스트
echo "Testing service..."
kubectl port-forward -n ${NAMESPACE} svc/${RELEASE_NAME} 8000:8000 &
PF_PID=$!

sleep 5

curl -X POST "http://localhost:8000/generate" \
    -H "Content-Type: application/json" \
    -d '{"prompt": "Hello, how are you?", "max_tokens": 100}'

kill $PF_PID

echo "Service test completed!"
```

### 5.2 모니터링 설정

```yaml
# configs/grafana-dashboard.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: tensorrt-llm-dashboard
  namespace: monitoring
data:
  dashboard.json: |
    {
      "dashboard": {
        "title": "TensorRT-LLM Metrics",
        "panels": [
          {
            "title": "GPU Memory Usage",
            "type": "graph",
            "targets": [
              {
                "expr": "gpu_memory_used_bytes / gpu_memory_total_bytes * 100"
              }
            ]
          },
          {
            "title": "Request Latency",
            "type": "graph",
            "targets": [
              {
                "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))"
              }
            ]
          },
          {
            "title": "Throughput (Requests/sec)",
            "type": "graph",
            "targets": [
              {
                "expr": "rate(http_requests_total[5m])"
              }
            ]
          }
        ]
      }
    }
```

### 5.3 로드 테스트

```python
# scripts/load_test.py
import asyncio
import aiohttp
import time
import json
from typing import List

class LoadTester:
    def __init__(self, base_url: str):
        self.base_url = base_url
        self.results = []
    
    async def send_request(self, session: aiohttp.ClientSession, prompt: str):
        """단일 요청 전송"""
        start_time = time.time()
        
        try:
            async with session.post(
                f"{self.base_url}/generate",
                json={
                    "prompt": prompt,
                    "max_tokens": 100,
                    "temperature": 0.8
                }
            ) as response:
                result = await response.json()
                end_time = time.time()
                
                self.results.append({
                    "success": True,
                    "latency": end_time - start_time,
                    "tokens": result.get("tokens_used", 0)
                })
                
        except Exception as e:
            end_time = time.time()
            self.results.append({
                "success": False,
                "latency": end_time - start_time,
                "error": str(e)
            })
    
    async def run_load_test(self, concurrent_users: int, requests_per_user: int):
        """로드 테스트 실행"""
        prompts = [
            "What is artificial intelligence?",
            "Explain machine learning in simple terms.",
            "How does neural network work?",
            "What are the benefits of cloud computing?",
            "Describe the future of AI technology."
        ]
        
        async with aiohttp.ClientSession() as session:
            tasks = []
            
            for user in range(concurrent_users):
                for req in range(requests_per_user):
                    prompt = prompts[req % len(prompts)]
                    task = self.send_request(session, prompt)
                    tasks.append(task)
            
            await asyncio.gather(*tasks)
    
    def print_results(self):
        """결과 출력"""
        successful = [r for r in self.results if r["success"]]
        failed = [r for r in self.results if not r["success"]]
        
        if successful:
            latencies = [r["latency"] for r in successful]
            tokens = [r["tokens"] for r in successful]
            
            print(f"Total requests: {len(self.results)}")
            print(f"Successful: {len(successful)}")
            print(f"Failed: {len(failed)}")
            print(f"Success rate: {len(successful)/len(self.results)*100:.2f}%")
            print(f"Average latency: {sum(latencies)/len(latencies):.2f}s")
            print(f"Min latency: {min(latencies):.2f}s")
            print(f"Max latency: {max(latencies):.2f}s")
            print(f"Average tokens: {sum(tokens)/len(tokens):.2f}")

async def main():
    tester = LoadTester("http://localhost:8000")
    
    print("Starting load test...")
    await tester.run_load_test(concurrent_users=10, requests_per_user=5)
    
    print("\nLoad test results:")
    tester.print_results()

if __name__ == "__main__":
    asyncio.run(main())
```

## 단계 6: 운영 및 최적화

### 6.1 성능 튜닝

```yaml
# configs/performance-values.yaml
# 고성능 설정을 위한 values 오버라이드
resources:
  limits:
    nvidia.com/gpu: 2
    memory: 32Gi
    cpu: 8
  requests:
    nvidia.com/gpu: 2
    memory: 16Gi
    cpu: 4

tensorrtllm:
  model:
    tensorParallelSize: 2
  
  inference:
    batchSize: 32
    maxSequenceLength: 2048

# 노드 어피니티 최적화
affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchExpressions:
          - key: app.kubernetes.io/name
            operator: In
            values:
            - tensorrt-llm
        topologyKey: kubernetes.io/hostname
```

### 6.2 자동 스케일링 설정

```yaml
# configs/custom-metrics-hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: tensorrt-llm-custom-hpa
  namespace: tensorrt-llm
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: tensorrt-llm
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Pods
    pods:
      metric:
        name: gpu_utilization
      target:
        type: AverageValue
        averageValue: "70"
  - type: Pods
    pods:
      metric:
        name: queue_length
      target:
        type: AverageValue
        averageValue: "5"
```

### 6.3 백업 및 복구

```bash
# scripts/backup.sh
#!/bin/bash

NAMESPACE="tensorrt-llm"
BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)"

mkdir -p ${BACKUP_DIR}

echo "Creating backup..."

# Helm values 백업
helm get values tensorrt-llm -n ${NAMESPACE} > ${BACKUP_DIR}/values.yaml

# ConfigMaps 백업
kubectl get configmaps -n ${NAMESPACE} -o yaml > ${BACKUP_DIR}/configmaps.yaml

# Secrets 백업
kubectl get secrets -n ${NAMESPACE} -o yaml > ${BACKUP_DIR}/secrets.yaml

# PVC 백업 (있는 경우)
kubectl get pvc -n ${NAMESPACE} -o yaml > ${BACKUP_DIR}/pvc.yaml

echo "Backup completed: ${BACKUP_DIR}"
```

## 트러블슈팅

### 일반적인 문제들

1. **GPU 리소스 부족**
```bash
# GPU 사용량 확인
kubectl describe nodes | grep -A 5 "nvidia.com/gpu"

# Pod GPU 할당 확인
kubectl get pods -n tensorrt-llm -o custom-columns=NAME:.metadata.name,GPU:.spec.containers[0].resources.requests.'nvidia\.com/gpu'
```

2. **메모리 부족 오류**
```bash
# 메모리 사용량 모니터링
kubectl top pods -n tensorrt-llm

# OOMKilled 이벤트 확인
kubectl get events -n tensorrt-llm --field-selector reason=OOMKilling
```

3. **모델 로딩 실패**
```bash
# Pod 로그 확인
kubectl logs -n tensorrt-llm deployment/tensorrt-llm -f

# 초기화 컨테이너 추가
initContainers:
- name: model-downloader
  image: busybox
  command: ['sh', '-c', 'echo "Preparing model cache..."']
```

## 보안 고려사항

### 1. 네트워크 정책

```yaml
# configs/network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: tensorrt-llm-policy
  namespace: tensorrt-llm
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/name: tensorrt-llm
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
    ports:
    - protocol: TCP
      port: 8000
  egress:
  - to: []
    ports:
    - protocol: TCP
      port: 443  # HTTPS
    - protocol: TCP
      port: 80   # HTTP
```

### 2. Pod Security Standards

```yaml
# configs/pod-security.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: tensorrt-llm
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

## 결론

이 가이드에서는 NVIDIA TensorRT-LLM을 활용하여 고성능 LLM 추론 서비스를 구축하는 전체 과정을 다뤘습니다. 

### 주요 성과
- **최적화된 Docker 이미지**: 멀티스테이지 빌드로 이미지 크기 최소화
- **확장 가능한 아키텍처**: Kubernetes와 Helm을 활용한 자동 스케일링
- **프로덕션 준비**: 모니터링, 로깅, 보안 설정 포함
- **성능 최적화**: GPU 리소스 효율적 활용

### 다음 단계
1. **모델 최적화**: 양자화 및 압축 기법 적용
2. **멀티 모델 서빙**: 여러 모델 동시 서비스
3. **A/B 테스팅**: 모델 버전 비교 및 점진적 배포
4. **비용 최적화**: Spot 인스턴스 활용 및 리소스 스케줄링

[NVIDIA TensorRT-LLM](https://github.com/NVIDIA/TensorRT-LLM)을 활용하면 기존 대비 최대 4배 빠른 추론 성능을 달성할 수 있습니다. 이 가이드를 바탕으로 여러분만의 고성능 LLM 서비스를 구축해보세요. 