---
title: "Claude Code로 영상을 만든다: claude-code-video-toolkit을 직접 돌려봤습니다"
excerpt: "Claude Code 안에서 슬래시 명령 한두 개로 1080p 영상을 렌더링하는 오픈소스 toolkit입니다. API 키 없이 examples/hello-world를 실제로 클론해 렌더했더니 750프레임 25초짜리 1080p 영상이 18초 만에 나왔습니다. 구조와 실측, 그리고 ThakiCloud 쿠버네티스 AI/ML SaaS 플랫폼 관점에서 GPU 영상 워크로드를 어떻게 보는지 정리합니다."
seo_title: "claude-code-video-toolkit 직접 실행 후기와 플랫폼 관점 - Thaki Cloud"
seo_description: "digitalsamba/claude-code-video-toolkit을 API 키 없이 직접 클론해 hello-world를 렌더한 실측(npm install 3.5초, 콜드 렌더 18.4초, 1920x1080 25초 2.15MB)과 구조 분석. Remotion·오픈소스 AI 모델 스택, ThakiCloud 쿠버네티스 GPU 워크로드 적용 관점을 정리합니다."
date: 2026-06-23
last_modified_at: 2026-06-23
tags:
  - ai-coding
  - claude-code
  - remotion
  - video-generation
  - gpu
  - platform-engineering
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "robot"
canonical_url: "https://thakicloud.com/tech-blog/ko/technique/claude-code-video-toolkit/"
categories:
  - tutorials
---

![자동화된 영상 제작 파이프라인을 추상적으로 표현한 이미지]({{ '/assets/images/claude-code-video-toolkit-hero.webp' | relative_url }})
*빛 입자가 정렬된 프레임으로 조립되는 모습으로 표현한 자동 영상 파이프라인.*

## 개요

영상 제작은 오랫동안 전용 편집기와 사람의 손이 필요한 작업이었습니다. 그런데 최근에는 코딩 에이전트가 코드를 쓰듯 영상도 코드로 기술하고 렌더링하는 흐름이 자리를 잡고 있습니다. `digitalsamba/claude-code-video-toolkit`은 그 흐름을 Claude Code 위에 얹은 오픈소스 toolkit입니다. 발표 시점 기준으로 GitHub 스타 약 1.6천 개, 포크 268개, 커밋 182개를 기록하고 있고 라이선스는 MIT입니다.

핵심 발상은 단순합니다. 영상 프로젝트를 React 기반 프레임워크인 Remotion으로 기술하고, 보이스와 이미지, 음악, b-roll 같은 자산 생성은 오픈소스 AI 모델에 위임하며, 이 모든 과정을 Claude Code의 슬래시 명령과 스킬로 묶는 것입니다. 사용자는 `/video` 한 번으로 템플릿에서 프로젝트를 만들고, `/setup`으로 클라우드 GPU와 저장소, 보이스를 설정한 뒤 렌더링으로 넘어갑니다.

ThakiCloud는 쿠버네티스 기반 AI/ML SaaS 플랫폼을 운영하면서 GPU 워크로드를 매일 다룹니다. 영상 렌더링과 생성형 자산 합성은 전형적인 GPU 바운드 작업이고, 멀티테넌트 환경에서 자원을 어떻게 배분하느냐가 곧 비용입니다. 그래서 이 toolkit은 단순한 콘텐츠 도구가 아니라, 우리 플랫폼이 다루는 워크로드 유형의 한 사례로 읽을 가치가 있습니다. 이 글에서는 toolkit을 실제로 클론해 돌려본 결과를 먼저 보여드리고, 그다음 플랫폼 관점에서 의미를 짚겠습니다.

## 이 도구는 무엇인가

claude-code-video-toolkit은 Claude Code를 영상 제작 워크스테이션으로 바꾸는 구성 묶음입니다. 크게 세 가지 층으로 이해하면 편합니다.

첫째는 슬래시 명령 층입니다. `/setup`은 클라우드 GPU와 파일 전송, 보이스 설정 같은 첫 환경 구성을 대화형으로 안내합니다. `/video`는 프로젝트를 만들고 열며, `/scene-review`는 Remotion Studio에서 장면별 검토를 돕습니다. 이 외에도 `/brand`, `/template`, `/generate-voiceover`, `/voice-clone`, `/redub`, `/record-demo`, `/publish` 등 영상 제작의 단계마다 명령이 준비되어 있습니다. `/publish`는 완성한 영상을 YouTube로 올리며 메타데이터를 `project.json`에서 자동으로 채웁니다.

둘째는 스킬 층입니다. Claude Code가 깊이 있게 다룰 수 있도록 도메인 지식을 묶어둔 것으로, Remotion(React 기반 영상 프레임워크), elevenlabs(음성), ffmpeg(미디어 처리), playwright-recording(브라우저 데모 녹화), frontend-design(시각 디자인), qwen-edit(이미지 편집), ideogram4(인-이미지 텍스트가 강한 이미지 생성), acestep(음악), ltx2(텍스트·이미지 기반 영상 클립), moviepy(파이썬 영상 합성), runpod(클라우드 GPU)까지 열한 가지가 포함됩니다.

셋째는 템플릿과 브랜드 층입니다. `templates/`에는 sprint-review, sprint-review-v2, product-demo, 그리고 9:16 세로형 숏폼을 위한 concept-explainer-short가 들어 있습니다. `brands/`에는 색상과 폰트, 보이스 설정을 담은 브랜드 프로필을 정의해 두고, `/video`로 프로젝트를 만들 때 자동으로 적용합니다. 아래 그림은 이 세 층이 어떻게 하나의 파이프라인으로 연결되는지를 보여줍니다.

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
<div class="d3-arch" data-arch-root id="23claudecodevideotoolkit-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 931, "height": 910, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 314, "y": 24, "w": 120, "h": 46, "title": "프롬프트 / 스크립트"}, {"id": "B", "x": 314, "y": 148, "w": 120, "h": 46, "title": "/video 명령"}, {"id": "C", "x": 278, "y": 272, "w": 191, "h": 62, "title": ["브랜드 프로필", "brand.json · voice.json"]}, {"id": "D", "x": 313, "y": 412, "w": 121, "h": 62, "title": ["Remotion 컴포지션", "React 비디오"]}, {"id": "E", "x": 489, "y": 560, "w": 120, "h": 46, "title": "AI 스킬 레이어"}, {"id": "E1", "x": 779, "y": 692, "w": 120, "h": 62, "title": ["Qwen3-TTS", "보이스·클론"]}, {"id": "E2", "x": 568, "y": 692, "w": 156, "h": 62, "title": ["FLUX.2 · Ideogram4", "이미지·타이틀카드"]}, {"id": "E3", "x": 393, "y": 692, "w": 120, "h": 62, "title": ["ACE-Step", "음악"]}, {"id": "E4", "x": 218, "y": 692, "w": 120, "h": 62, "title": ["LTX-2", "b-roll"]}, {"id": "F", "x": 28, "y": 552, "w": 149, "h": 62, "title": ["remotion render", "h264 · 1080p · 6x"]}, {"id": "G", "x": 42, "y": 700, "w": 121, "h": 46, "title": "out/video.mp4"}, {"id": "H", "x": 24, "y": 832, "w": 156, "h": 46, "title": "/publish → YouTube"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [374, 70, 374, 148]}, {"src": "B", "dst": "C", "kind": "data", "line": [374, 194, 374, 272]}, {"src": "C", "dst": "D", "kind": "data", "line": [374, 334, 374, 412]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[434, 467], [549, 513], [549, 513], [549, 560]]}, {"src": "E", "dst": "E1", "kind": "data", "curve": [[609, 598], [839, 653], [839, 653], [839, 692]]}, {"src": "E", "dst": "E2", "kind": "data", "curve": [[581, 606], [646, 653], [646, 653], [646, 692]]}, {"src": "E", "dst": "E3", "kind": "data", "curve": [[517, 606], [453, 653], [453, 653], [453, 692]]}, {"src": "E", "dst": "E4", "kind": "data", "curve": [[489, 598], [278, 653], [278, 653], [278, 692]]}, {"src": "D", "dst": "F", "kind": "data", "curve": [[313, 459], [102, 513], [102, 513], [102, 552]]}, {"src": "F", "dst": "G", "kind": "data", "line": [102, 614, 102, 700]}, {"src": "G", "dst": "H", "kind": "data", "line": [102, 746, 102, 832]}]});
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
      const container = document.getElementById('23claudecodevideotoolkit-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '23claudecodevideotoolkit-1';
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

특히 눈에 띄는 점은 비용 구조입니다. toolkit은 보이스(Qwen3-TTS), 이미지(FLUX.2), 음악(ACE-Step) 같은 생성형 자산을 상용 API가 아니라 오픈소스 모델에 의존하도록 설계했습니다. 사용자가 자신의 클라우드 GPU 계정에 모델을 배포해 원가로 돌리는 방식입니다. 저장소로는 Cloudflare R2의 무료 구간(10GB, 이그레스 무료)을, 컴퓨팅으로는 Modal의 스타터 플랜 월 30달러 무료 크레딧을 활용할 수 있다고 안내합니다. 자체 호스팅을 전제로 한 이 선택은 뒤에서 다룰 플랫폼 관점과 정확히 맞닿아 있습니다.

## 설치 및 통합

문서가 안내하는 빠른 시작은 다음과 같습니다. 저장소를 클론하고, 선택적으로 파이썬 의존성을 설치한 뒤 Claude Code를 여는 흐름입니다.

```shell
git clone https://github.com/digitalsamba/claude-code-video-toolkit.git
cd claude-code-video-toolkit
python3 -m pip install -r tools/requirements.txt   # 선택: AI 보이스오버·이미지 생성·음악·moviepy 예제
claude                                              # toolkit 안에서 Claude Code 실행
```

그다음 Claude Code 안에서 `/setup`으로 클라우드 GPU와 저장소, 보이스를 약 5분간 대화형으로 구성하고, `/video`로 첫 프로젝트를 만듭니다. 요구 사항은 Node.js 18 이상과 Claude Code이며, AI 도구를 쓰려면 파이썬 3.9 이상이 권장됩니다. FFmpeg는 선택입니다.

여기서 중요한 점은, 설정 없이도 곧바로 렌더링만 확인할 수 있는 경로가 따로 있다는 것입니다. `examples/hello-world`는 API 키가 전혀 필요 없는 최소 예제입니다. 저는 이 경로를 그대로 따라 실제로 돌려봤습니다.

```shell
cd examples/hello-world
npm install
npm run render
```

`hello-world`의 `package.json`을 보면 렌더 스크립트는 `npx remotion render src/index.ts SprintReview out/video.mp4`이고, 의존성은 Remotion 4.0.425 계열과 React 18입니다. 즉 별도의 외부 모델 호출 없이 React 컴포지션을 그대로 영상으로 굽는 구조입니다.

## 실제 실험 결과

검증은 격리된 git worktree 안에서 진행했고, 모든 수치는 실행 로그에서 그대로 가져왔습니다. 실행 환경은 Apple Silicon(arm64), Node.js 24.1.0, npm 11.3.0입니다.

먼저 의존성 설치입니다. `npm install`은 230개 패키지를 추가했고 약 3.5초가 걸렸습니다. 다만 감사 결과 10건의 취약점(보통 7건, 높음 3건)이 보고되었는데, 이 부분은 한계 절에서 다시 짚겠습니다.

렌더링 단계에서는 Remotion이 처음 한 번 Chrome Headless Shell을 내려받습니다. 이번 실행에서는 약 90.2MB를 다운로드했고, 이는 최초 1회성 비용입니다. 이어서 번들링과 합성이 진행되었습니다. 컴포지션은 `SprintReview`, 코덱은 h264, 동시성은 6배(6x)였고 전체 750프레임을 렌더링했습니다. 로그에는 "Cached bundle. Subsequent renders will be faster"라는 안내가 남아, 두 번째 실행부터는 번들 캐시 덕분에 더 빨라진다는 점을 명시합니다.

콜드 상태에서 다운로드와 번들링, 렌더링, 인코딩을 모두 포함한 `npm run render`의 벽시계 시간은 18.4초였습니다. 최종 산출물은 1920x1080 해상도, 30fps, 길이 25.0초, 용량 2.15MB(2,152,829바이트)의 h264 영상이었고 AAC 오디오 트랙을 포함했습니다. API 키는 하나도 쓰지 않았습니다.

![hello-world 렌더 파이프라인 단계별 실측 시간 차트]({{ '/assets/images/claude-code-video-toolkit-results.webp' | relative_url }})
*API 키 없이 측정한 hello-world 1080p 렌더 파이프라인의 단계별 벽시계 시간.*

정리하면, 별도 환경 구성 없이 클론 직후 약 30초 안에 1080p 영상 한 편이 손에 들어왔습니다. "2분 안에 렌더된다"는 예제 설명보다 오히려 빠른 결과였는데, 이는 하드웨어와 네트워크 상황에 따라 달라질 수 있으므로 절대적인 수치로 받아들일 필요는 없습니다. 중요한 것은 진입 장벽이 그만큼 낮다는 사실입니다.

## ThakiCloud 쿠버네티스 AI/ML SaaS 플랫폼 적용 및 시사점

이 toolkit이 흥미로운 이유는 우리 플랫폼이 다루는 워크로드와 구조적으로 닮았기 때문입니다. 영상 렌더링과 생성형 자산 합성은 모두 GPU 바운드 배치 작업이고, 짧고 굵게 자원을 쓰다가 유휴 상태로 돌아가는 패턴을 보입니다. ThakiCloud는 쿠버네티스 위에서 Kueue로 GPU 작업을 큐잉하고 우선순위를 매기며, vLLM 등으로 모델을 서빙합니다. toolkit이 권장하는 Modal·Daytona식 서버리스 영속성, 즉 유휴 시 환경을 동면시키고 요청 시 깨우는 모델은 우리가 Kueue로 달성하려는 자원 효율과 같은 문제를 다른 층위에서 푸는 방식입니다.

자랑할 만한 접점은 비용과 자체 호스팅입니다. toolkit은 상용 API 대신 Qwen3-TTS, FLUX.2, ACE-Step 같은 오픈웨이트 모델을 자신의 GPU에 올려 원가로 돌리도록 설계되어 있습니다. 이는 온프레미스와 자체 호스팅을 강점으로 내세우는 ThakiCloud의 방향과 정확히 일치합니다. 고객이 데이터와 모델을 외부로 내보내지 않고, 보안 요구가 높은 환경에서도 멀티테넌트로 생성형 워크로드를 운용하려 할 때, 우리 플랫폼은 이런 영상·미디어 파이프라인까지 자연스럽게 수용할 수 있습니다.

내부 활용 각도도 분명합니다. sprint-review와 product-demo 템플릿은 엔지니어링 조직이 반복적으로 만드는 산출물입니다. 이런 영상 생성을 쿠버네티스 잡으로 묶어 Kueue 큐에 태우면, 개발자가 로컬에서 무거운 렌더링을 돌리는 대신 공용 GPU 풀에서 우선순위에 따라 처리하도록 옮길 수 있습니다. toolkit 자체가 Claude Code에 묶여 있다는 점은 제약이지만, Remotion 렌더 단계만 떼어내 컨테이너화하면 우리 배치 인프라에 얹는 일은 어렵지 않습니다.

## 한계 및 반론

장점만 보기에는 분명한 약점들이 있습니다. 첫째, 의존성 보안입니다. 최소 예제의 `npm install`에서도 10건의 취약점(높음 3건 포함)이 보고되었습니다. 프로덕션에 올리려면 의존성 감사와 고정이 선행되어야 하며, 이는 자동화 파이프라인의 게이트로 강제하는 편이 안전합니다.

둘째, 무료라는 표현의 범위입니다. API 키 없이 곧바로 되는 것은 템플릿 기반 렌더링까지입니다. 보이스, 이미지, 음악, b-roll 같은 생성형 자산을 쓰려면 결국 자신의 클라우드 GPU에 모델을 배포해야 하고, 그 시점부터는 컴퓨팅 비용과 운영 부담이 생깁니다. "무료"는 원가로 직접 운용한다는 뜻이지 비용이 없다는 뜻이 아닙니다.

셋째, 도구 결합입니다. 이 워크플로는 Claude Code와 강하게 결합되어 있습니다. 슬래시 명령과 스킬이라는 추상화가 편리한 만큼, 특정 에이전트 환경에 종속되는 측면이 있습니다. 다행히 핵심 렌더링은 Remotion이라는 독립 프레임워크가 담당하므로, 필요하면 그 부분만 분리해 다른 오케스트레이션에 옮길 여지는 남아 있습니다.

넷째, Remotion은 React로 영상을 기술합니다. 디자이너나 비개발 직군에게는 진입 장벽이 될 수 있고, 복잡한 모션 그래픽을 코드로 다루는 일은 전용 편집기보다 손이 더 갈 수 있습니다. 결국 이 toolkit은 "코드로 영상을 다루는 데 익숙한 팀"에 가장 잘 맞습니다.

종합하면, claude-code-video-toolkit은 코드 친화적인 영상 자동화의 좋은 출발점입니다. API 키 없이 1080p 영상을 30초 안에 뽑아내는 경험은 분명한 강점이고, 오픈소스 모델 기반의 자체 호스팅 철학은 우리 플랫폼의 지향과도 잘 맞습니다. 다만 생성형 자산 단계의 실제 비용과 의존성 보안, 도구 결합이라는 현실을 함께 고려해야 균형 잡힌 판단이 가능합니다.

## 출처

- GitHub: [digitalsamba/claude-code-video-toolkit](https://github.com/digitalsamba/claude-code-video-toolkit)
- Remotion: [remotion.dev](https://www.remotion.dev/)
- 실측 환경: Apple Silicon(arm64), Node.js 24.1.0, npm 11.3.0 / 모든 수치는 직접 실행 로그에서 추출했습니다.
