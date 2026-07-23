---
title: "Claude Code가 영상을 봅니다: /watch로 프레임·전사를 에이전트에 주입하는 claude-video"
excerpt: "코딩 에이전트는 오랫동안 텍스트만 읽어 왔습니다. claude-video는 yt-dlp·ffmpeg·Whisper를 얇게 엮어, 유튜브·Zoom·Loom·로컬 파일을 프레임 이미지와 타임스탬프 전사로 바꿔 Claude의 멀티모달 Read 컨텍스트에 넣습니다. GitHub 5,400개 넘는 스타를 받은 이 오픈소스 스킬의 실제 설치·사용법과 내부 동작(자막 우선, 3단계 프레임 추출, 중복 제거, 전사 폴백)을 뜯어보고, ThakiCloud의 Agent-Native Cloud인 Paxis 스킬 하네스와 ai-platform 서빙 관점에서 어떤 의미인지 정리합니다."
seo_title: "claude-video: Claude Code로 영상을 보는 /watch 스킬 분석 - Thaki Cloud"
seo_description: "claude-video(bradautomates)의 /watch 스킬을 분석합니다. yt-dlp 자막 우선, ffmpeg 3단계 프레임 추출, 16x16 그레이스케일 중복 제거, Whisper(Groq large-v3·OpenAI 폴백) 전사를 Claude 멀티모달 Read로 주입하는 구조와 ThakiCloud Paxis·ai-platform 적용 시사점을 다룹니다."
date: 2026-07-13
last_modified_at: 2026-07-13
tags:
  - agentops
  - claude-code
  - multimodal
  - agent-skills
  - video-understanding
  - ffmpeg
  - whisper
  - platform-engineering
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "robot"
canonical_url: "https://thakicloud.com/tech-blog/ko/agentops/claude-video-agent-watch/"
categories:
  - agentops
audiobook: /assets/audio/posts/claude-video-agent-watch/audiobook-ko.mp3
audiobook_note: "AI 로컬 합성 오디오북 (Qwen3-TTS)"
---

## 개요

코딩 에이전트는 지금까지 텍스트만 읽어 왔습니다. 소스 파일, 로그, 문서, API 응답까지 전부 글자였습니다. 그런데 실무에서 정작 중요한 정보 상당수는 영상 안에 있습니다. 제품 데모 녹화, 버그 재현 화면, 회의 녹화, 강의 영상, 경쟁사 릴리스 클립이 그렇습니다. 사람은 이걸 열어 보고 "2분 30초쯤에서 화면이 깨진다"고 말하지만, 에이전트에게는 그 영상이 그냥 열 수 없는 바이너리였습니다.

`claude-video`는 이 벽을 얇게 허무는 오픈소스 스킬입니다. 한 줄로 요약하면 "Claude에게 영상을 볼 수 있는 능력을 준다"이고, 실제로 하는 일은 영상을 프레임 이미지와 타임스탬프가 붙은 전사로 바꿔 Claude의 멀티모달 Read 컨텍스트에 밀어 넣는 것입니다. 2026년 7월 기준 GitHub 스타 5,400개를 넘겼고, 일부 집계에서는 7,000개까지 올라온 화제의 프로젝트입니다.

이 글을 읽는 대상은 명확합니다. Claude Code, Cursor, Copilot, Gemini CLI 같은 코딩 에이전트를 실무에 쓰면서 "영상 자료를 어떻게 파이프라인에 넣을까"를 고민하는 개발자와 플랫폼 엔지니어입니다. 그리고 이 기법이 단순한 편의 도구를 넘어 에이전트 플랫폼 설계에 어떤 의미인지 궁금한 분입니다. 결론부터 말하면, claude-video는 "얇은 하네스 + 검증된 도구 조합"이 어떻게 새로운 감각(視覺)을 에이전트에 붙이는지 보여 주는 좋은 사례이며, ThakiCloud가 Paxis에서 추구하는 방향과 정확히 겹칩니다.

![영상 프레임과 음성 파형이 하나의 렌즈로 흘러 들어가 시각을 얻는 에이전트를 형상화한 추상 이미지]({{ '/assets/images/claude-video-agent-watch-hero.png' | relative_url }})

## 이 도구는 무엇인가

claude-video는 모델을 새로 만들지 않습니다. 이미 검증된 세 개의 오픈소스 도구를 얇게 엮은 스킬입니다. 영상 다운로드와 자막 확보는 `yt-dlp`가, 프레임 추출과 오디오 변환은 `ffmpeg`가, 자막이 없을 때의 음성 전사는 `Whisper`가 맡습니다. 그리고 마지막 조립과 판단은 Claude의 멀티모달 Read 도구가 합니다. 새로 짠 것은 이 네 조각을 잇는 파이프라인과, 프레임을 지능적으로 솎아 내는 중복 제거 로직입니다.

핵심 인터페이스는 `/watch` 슬래시 커맨드 하나입니다. 사용자는 영상 URL이나 로컬 경로를 넘기고, 질문을 붙이고, 필요하면 구간을 지정합니다. 그러면 에이전트가 그 영상을 "보고" 답합니다. 입력 소스는 넓습니다. 유튜브뿐 아니라 Instagram, X, Vimeo 등 yt-dlp가 지원하는 사이트 전반과 Zoom·Loom 녹화, 로컬 mp4 파일까지 받습니다.

전체 흐름은 아래와 같습니다.

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
<div class="d3-arch" data-arch-root id="713claudevideoagentwatch-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 739, "height": 832, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 277, "y": 24, "w": 198, "h": 62, "title": ["에이전트: /watch URL·경로 + 질문", "선택적 --start / --end"]}, {"id": "B", "x": 435, "y": 164, "w": 142, "h": 46, "title": "yt-dlp: 자막 우선 확인"}, {"id": "C", "x": 437, "y": 301, "w": 138, "h": 52, "title": "자막이 존재하는가?"}, {"id": "D", "x": 544, "y": 482, "w": 163, "h": 46, "title": "무료 자막을 타임스탬프 전사로 사용"}, {"id": "E", "x": 284, "y": 458, "w": 205, "h": 94, "title": ["mono 16kHz 오디오 추출 후", "Whisper 전사", "Groq large-v3 우선 · OpenAI", "폴백"]}, {"id": "F", "x": 35, "y": 288, "w": 184, "h": 78, "title": ["ffmpeg 프레임 추출", "efficient · balanced ·", "token-burner"]}, {"id": "G", "x": 24, "y": 466, "w": 205, "h": 78, "title": ["중복 제거", "16x16 그레이스케일 · 마지막 유지 프레임", "대비"]}, {"id": "H", "x": 305, "y": 630, "w": 163, "h": 46, "title": "타임스탬프로 정렬: 프레임 + 전사"}, {"id": "I", "x": 284, "y": 754, "w": 205, "h": 46, "title": "Claude 멀티모달 Read 컨텍스트로 주입"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[434, 86], [506, 125], [506, 125], [506, 164]]}, {"src": "B", "dst": "C", "kind": "data", "line": [506, 210, 506, 301]}, {"src": "C", "dst": "D", "kind": "data", "label": "있음", "curve": [[543, 353], [626, 412], [626, 412], [626, 482]], "off": "50%"}, {"src": "C", "dst": "E", "kind": "data", "label": "없음", "curve": [[469, 353], [387, 412], [387, 412], [387, 458]], "off": "50%"}, {"src": "A", "dst": "F", "kind": "data", "curve": [[277, 83], [127, 125], [127, 249], [127, 288]]}, {"src": "F", "dst": "G", "kind": "data", "line": [127, 366, 127, 466]}, {"src": "D", "dst": "H", "kind": "data", "curve": [[626, 528], [626, 591], [626, 591], [468, 632]]}, {"src": "E", "dst": "H", "kind": "data", "line": [387, 552, 387, 630]}, {"src": "G", "dst": "H", "kind": "data", "curve": [[127, 544], [127, 591], [127, 591], [305, 634]]}, {"src": "H", "dst": "I", "kind": "data", "line": [387, 676, 387, 754]}]});
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
      const container = document.getElementById('713claudevideoagentwatch-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '713claudevideoagentwatch-1';
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

기존 접근과의 차이는 분명합니다. 지금까지 "AI가 유튜브를 요약한다"는 대부분 제목·설명·자막 텍스트만 읽고 추측하는 방식이었습니다. claude-video는 제목으로 짐작하지 않습니다. 실제 프레임을 이미지로 보고, 자막이나 전사를 함께 읽어 시각과 청각을 결합합니다. 화면에 무엇이 떠 있는지, 어느 시점에 UI가 깨지는지 같은 질문은 텍스트 자막만으로는 답할 수 없고, 프레임을 봐야 답이 나옵니다.

## 설치 및 사용

설치는 두 갈래입니다. Claude Code 사용자는 플러그인 마켓플레이스로 붙입니다.

```bash
# Claude Code: 마켓플레이스 등록 후 watch 스킬 설치
/plugin marketplace add bradautomates/claude-video
/plugin install watch@claude-video
```

Cursor, Copilot, Gemini CLI를 비롯한 50여 개 에이전트 호스트에서는 Agent Skills 규격으로 전역 설치합니다.

```bash
# Agent Skills 규격(호스트 50여 곳 공통)
npx skills add bradautomates/claude-video -g
```

시작에 별도 설정은 필요 없습니다. `yt-dlp`와 `ffmpeg`가 없으면 첫 실행 시 macOS에서는 brew로 자동 설치되고, Linux·Windows에서는 정확한 설치 명령을 출력합니다. Whisper용 API 키는 항상 필요한 것이 아니라, 영상에 자막이 아예 없을 때만 필요합니다. 공개 영상 상당수는 자막이 붙어 있어 무료 경로로 처리됩니다.

사용은 커맨드 한 줄입니다.

```bash
# 로컬 파일에 질문
/watch tutorial.mp4 "이 튜토리얼에서 사용하는 언어는 무엇인가요?"

# 유튜브 영상의 특정 구간만 집중 분석
/watch https://youtu.be/VIDEO "2분 30초 근처에서 무슨 일이 일어나나요?" --start 2:00 --end 3:00
```

`--start`와 `--end`가 중요합니다. 긴 영상 전체를 프레임으로 뜯으면 컨텍스트와 비용이 폭증합니다. 구간을 좁히면 그 부분만 다운로드하고 프레임을 뽑아 토큰을 아낍니다. 실무에서는 "회의 녹화 45분 중 데모가 나오는 12분 구간만" 같은 식으로 범위를 좁혀 쓰는 것이 정석입니다.

## 내부 동작: 자막 우선, 프레임 추출, 중복 제거, 전사

claude-video가 흥미로운 이유는 조각을 잇는 방식에 실용적 판단이 배어 있기 때문입니다. 문서화된 설계를 단계별로 보겠습니다. 아래 수치와 파라미터는 프로젝트가 공개한 설계 값이며, 제가 이 환경에서 직접 측정한 벤치마크가 아닙니다.

첫째, 전사는 자막 우선입니다. yt-dlp가 기존 자막을 먼저 확인해서, 있으면 영상 본체를 내려받지 않고 자막을 그대로 타임스탬프 전사로 씁니다. 즉각적이고 비용이 없습니다. 자막이 없을 때만 오디오를 mono 16kHz로 추출해 Whisper로 넘깁니다. 이때 속도와 비용을 고려해 Groq의 whisper-large-v3를 우선 쓰고, 안 되면 OpenAI whisper-1로 폴백합니다.

둘째, 프레임 추출은 세 단계 상세도를 제공합니다. `efficient`는 키프레임만 디코딩해 거의 즉시 끝납니다. `balanced`는 장면 전환(scene change) 프레임을 선호하되 충분히 안 나오면 길이를 고려한 균등 샘플링으로 보완합니다. `token-burner`는 장면 감지를 상한 없이 돌려 최대 충실도를 뽑되 그만큼 토큰을 태웁니다. 목적에 따라 "빠르게 훑을지, 꼼꼼히 볼지"를 고를 수 있습니다.

셋째, 중복 제거가 이 프로젝트의 작은 백미입니다. 추출한 각 프레임을 16×16 그레이스케일 썸네일로 줄이고, 직전 프레임이 아니라 **마지막으로 채택한 프레임**과 비교해 평균 절대 차이(mean absolute difference)를 구합니다. 이 값이 임계치 2.0 이하면 버립니다. 직전 프레임이 아니라 마지막 채택 프레임을 기준으로 삼는 이유가 핵심입니다. 프레임을 하나씩 비교하면 아주 천천히 바뀌는 페이드 인/아웃을 "거의 안 변했다"며 계속 통과시키지만, 마지막 채택본과 비교하면 누적 변화가 임계치를 넘는 순간을 잡아냅니다. 슬라이드가 서서히 넘어가는 강의 영상 같은 데서 실제로 유용한 설계입니다.

넷째, 최종 조립입니다. 프레임 이미지와 전사를 타임스탬프로 정렬해서, 프레임은 이미지로, 전사는 시각이 붙은 텍스트로 Claude의 컨텍스트에 들어갑니다. Claude는 "이 시점 화면에는 이런 게 보이고, 그때 이런 말이 나왔다"를 함께 읽고 답합니다.

## 실제 확인: 문서화된 동작과 재현 메모

정직하게 밝힙니다. 이 글을 쓰는 저작 환경은 외부 영상 다운로드가 막혀 있어, claude-video를 설치해 실제 유튜브 영상을 프레임으로 뜯는 라이브 벤치마크는 수행하지 못했습니다. 그래서 지연·정확도 수치를 지어내지 않습니다. 대신 프로젝트가 공개한 설계와 동작을 사실대로 정리하고, 재현 가능한 검증 지점을 남깁니다.

문서와 여러 사용기에서 일관되게 확인되는 사실은 다음과 같습니다. 자막이 있는 공개 영상은 다운로드 없이 무료로 전사됩니다. 프레임 상세도는 efficient/balanced/token-burner 세 단계이며, 각각 속도와 충실도가 다릅니다. 중복 제거는 16×16 그레이스케일 비교에 임계치 2.0을 씁니다. 전사 폴백 경로는 Groq whisper-large-v3에서 OpenAI whisper-1 순입니다. 포크 프로젝트 `mathiaschu/watch`는 이 중 전사 단계를 로컬 `mlx-whisper`로 바꿔 API 키 없이 완전 온디바이스로 돌리는 변형을 제공합니다.

직접 확인하려면 다음을 권합니다. 자막이 있는 짧은 공개 영상을 `--start`/`--end`로 1분 이내 구간만 잘라 `/watch`에 던지고, 프레임 상세도를 efficient와 token-burner로 각각 돌려 프레임 개수와 응답 토큰 차이를 비교하는 것입니다. 이 비교가 "구간 좁히기 + 상세도 선택"이 비용에 미치는 영향을 가장 직관적으로 보여 줍니다. 실측 없이 숫자를 인용하는 것보다, 각자 환경에서 이 두 축을 재는 편이 정확합니다.

## ThakiCloud 제품 적용 시사점

claude-video는 ThakiCloud가 밀고 있는 두 축과 자연스럽게 맞물립니다.

먼저 **Paxis 관점**입니다. Paxis는 ThakiCloud의 Agent-Native Cloud 제어 평면으로, Skills·Tools·Policies·Audit Logs를 일급 리소스로 다룹니다. claude-video가 보여 주는 건 정확히 Paxis가 지향하는 "얇은 하네스, 두꺼운 스킬" 구조입니다. 모델을 새로 학습시키지 않고, 검증된 도구(yt-dlp·ffmpeg·Whisper)를 스킬 하네스로 엮어 에이전트에 새 감각을 붙였습니다. Paxis의 Skill Harness는 960개가 넘는 스킬을 BM25로 선택해 격리된 샌드박스에서 실행하는데, claude-video 같은 멀티모달 스킬은 이 하네스에 그대로 얹을 후보입니다. 특히 영상 다운로드와 ffmpeg 실행은 임의 URL과 바이너리를 다루므로, Paxis의 Sandbox 격리 실행과 정책 게이트·감사 로그가 그대로 값을 합니다. 어떤 영상을, 어떤 구간까지, 어떤 상세도로 처리했는지가 감사 로그에 남으면, 비용과 데이터 접근을 동시에 통제할 수 있습니다.

다음은 **ai-platform 관점**입니다. claude-video의 전사 경로는 기본적으로 외부 API(Groq·OpenAI)에 의존합니다. 온프레미스·소버린 요구가 있는 고객이라면 이 부분이 그대로 리스크입니다. 여기서 ThakiCloud의 ai-platform이 답을 제공합니다. Whisper 계열 STT를 K8s 위에서 Kueue로 GPU를 스케줄링해 사내에서 서빙하면, 영상 전사를 외부로 내보내지 않고 폐쇄망 안에서 끝낼 수 있습니다. 포크 프로젝트가 mlx-whisper로 로컬 전사를 택한 것과 같은 방향을 조직 규모로 구현하는 셈입니다. 자막 없는 대량 회의 녹화를 사내 GPU 클러스터에서 배치로 전사하고, 그 결과를 에이전트가 소비하는 파이프라인은 멀티테넌트 서빙과 비용 효율이 강점인 ai-platform의 전형적인 활용처입니다.

두 관점은 서로를 보완합니다. ai-platform이 저비용·폐쇄망 전사와 프레임 처리를 받쳐 주면, 그 위에서 Paxis가 멀티모달 스킬을 정책·감사와 함께 오케스트레이션합니다. "싼 인프라가 에이전트의 새 감각을 경제적으로 만든다"는 구조가 여기서도 성립합니다.

## 한계 및 반론

몇 가지는 분명히 짚어야 합니다.

첫째, 토큰 비용입니다. 프레임을 이미지로 컨텍스트에 넣는 순간 토큰이 빠르게 쌓입니다. token-burner 모드로 긴 영상을 통째로 돌리면 한 번의 질문에 상당한 비용이 발생할 수 있습니다. `--start`/`--end`로 구간을 좁히고 efficient 상세도로 시작하는 규율이 필수입니다. 편리하다고 무절제하게 쓰면 청구서가 먼저 반응합니다.

둘째, 중복 제거는 만능이 아닙니다. 16×16 그레이스케일·임계치 2.0은 슬라이드·데모처럼 변화가 이산적인 영상에는 잘 맞지만, 카메라가 계속 흔들리는 핸드헬드 영상이나 미세한 텍스트 변화가 중요한 화면에서는 놓치거나 과하게 남길 수 있습니다. 임계치는 영상 성격에 따라 조정 대상입니다.

셋째, 소스 신뢰와 법적 문제입니다. yt-dlp로 임의 사이트에서 영상을 내려받는 행위는 대상 서비스의 약관·저작권과 충돌할 수 있습니다. 조직 파이프라인에 넣을 때는 어떤 소스를 허용할지 정책으로 못 박아야 하고, 이것이 바로 Paxis 같은 정책 게이트가 필요한 이유이기도 합니다.

넷째, 외부 API 의존입니다. 자막 없는 영상의 전사가 Groq·OpenAI로 나가면 데이터가 외부로 이동합니다. 민감한 내부 회의 녹화라면 앞서 말한 사내 Whisper 서빙으로 경로를 바꾸지 않는 한 그대로 노출입니다.

그럼에도 큰 그림은 유효합니다. claude-video는 "코딩 에이전트는 텍스트만 읽는다"는 전제를 얇고 실용적인 방식으로 깼습니다. 새 모델이 아니라 검증된 도구의 조합으로 감각을 확장한다는 접근은, 에이전트 플랫폼을 설계하는 입장에서 계속 참고할 만한 패턴입니다.

## 출처

- [bradautomates/claude-video (GitHub)](https://github.com/bradautomates/claude-video)
- [claude-video/README.md (GitHub)](https://github.com/bradautomates/claude-video/blob/main/README.md)
- [mathiaschu/watch, mlx-whisper 로컬 전사 포크 (GitHub)](https://github.com/mathiaschu/watch)
- [claude-video: Let Claude Watch Videos with /watch (knightli.com)](https://knightli.com/en/2026/07/08/claude-video-watch-video-transcript-frames-skill/)
- [Claude Video: The Open-Source Tool That Lets AI Coding Agents Watch and Analyze Any Video (CoddyKit)](https://www.coddykit.com/pages/blog-detail?id=512902&slug=claude-video-the-open-source-tool-that-lets-ai-coding-agents-watch-and-analyze-a)
