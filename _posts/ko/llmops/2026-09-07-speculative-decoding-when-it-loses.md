---
title: "같은 기능을 켠 채로 배수가 1.4배에서 0.8배가 됐습니다"
excerpt: "추측 디코딩의 배수는 논문이 아니라 체크포인트·손님 수·샘플링·컨텍스트 예산이 정합니다. 같은 드래프터를 켜 둔 채 동시 접속만 1명에서 8명으로 늘렸더니 이득이 손해로 뒤집혔습니다."
date: 2026-09-07
permalink: /ko/llmops/speculative-decoding-when-it-loses/
categories:
  - llmops
  - product
tags:
  - 추측 디코딩
  - speculative-decoding
  - DFlash2
  - vLLM
  - 동시성
  - NVFP4
  - 서빙
  - B200
  - LLMOps
author_profile: true
toc: true
toc_label: "목차"
header:
  teaser: /assets/images/speculative-decoding-when-it-loses-hero.webp
canonical_url: "https://thakicloud.com/tech-blog/ko/llmops/speculative-decoding-when-it-loses/"
---

![동시성이 올라갈수록 낮아지는 배수 곡선을 형상화한 이미지](/assets/images/speculative-decoding-when-it-loses-hero.webp)
*손님이 늘수록 빈 좌석은 줄어듭니다. 추측 디코딩이 파먹던 것이 바로 그 좌석입니다.*

추측 디코딩을 켜기 전에 확인해야 할 숫자는 논문의 배속이 아니라 여러분 서버의 동시 접속 수입니다. 저희는 같은 드래프터를 켜 둔 채로 손님 수만 1명에서 8명으로 늘렸더니 배수가 1.4배에서 0.8배가 되는 것을 봤습니다. 추론 서빙을 운영하면서 "왜 우리는 논문만큼 안 빨라지지"를 묻고 계신 분께 드리는 글입니다.

## 쉽게 말하면

셔틀버스를 떠올려 주세요. 큰 언어 모델이 글자 하나를 쓰려면 매번 모델 전체를 메모리에서 읽어 옵니다. 버스가 승객 한 명을 태우려고 차고에서 정류장까지 왕복하는 셈입니다. 왕복 비용은 승객 수와 거의 무관하니, 어차피 가는 편에 사람을 더 태우면 공짜에 가깝습니다. 추측 디코딩은 바로 그 빈 좌석을 쓰는 기술입니다. 눈치 빠른 안내원이 다음 승객 몇 명을 미리 지목해 태웁니다. 기사님은 도착해서 한 번에 확인합니다. 맞으면 그만큼 왕복을 아끼고 틀리면 그 사람만 내려 줍니다.

문제는 빈 좌석이 항상 있지는 않다는 데 있습니다. 손님이 몰리면 버스는 이미 만석입니다. 더 태울 자리가 없습니다. 버스를 작은 차로 바꾸면 왕복이 싸지는 대신 빈 좌석도 같이 줍니다. 이 글은 그 빈 좌석이 언제 사라지는지를 저희 장비에서 재 본 기록입니다.

## 배수는 기능이 아니라 조건에 붙어 있습니다

먼저 저희가 무엇을 켰는지 밝혀 두겠습니다. 타깃은 저희가 만든 27B 체크포인트입니다. 드래프터는 DFlash2를 붙여 한 번에 일곱 토큰씩 제안하게 했습니다. 엔진은 vLLM 0.28.0이고 샘플링은 실제 서비스와 같은 값을 썼습니다. 같은 실행 안에서 켠 팔과 끈 팔을 짝지어 쟀습니다. 배수는 그 짝 안에서만 말합니다.

그렇게 재 보면 배수는 하나의 숫자가 아니라 곡선입니다. 그리고 그 곡선은 1.0을 아래로 통과합니다. 통과하는 지점이 어디냐가 이 글의 전부입니다.

## 손님이 늘면 파먹을 자리가 없습니다

가장 먼저 무너지는 축은 동시성입니다. Edge 예산 조건에서 INT4 체크포인트를 놓고 자유 서술을 시켰을 때, 동시 1명에서는 1.4배였던 것이 2명에서 1.2배, 4명에서 1.1배로 내려오다가 8명에서 0.8배가 됩니다. 켜 둔 채로 그냥 두면 손님이 여덟 명일 때 오히려 느려집니다. 저희 프로덕션 체크포인트를 더 큰 배치로 밀어붙이면 같은 붕괴가 더 극적으로 나옵니다. 동시 64명에서 기준선은 초당 2,306토큰인데 드래프터를 켜면 595토큰으로 떨어집니다. 0.3배입니다.

{% raw %}
<div class="specdec-fig" data-sf-root id="sf-59db362606"></div>
<style>
  .specdec-fig {
    --sf-page-bg:#ffffff; --sf-surface:#f7f8fa; --sf-text:#1a1d21; --sf-muted:#6b7280;
    --sf-border:#d5d9e0; --sf-accent:hsl(217 91% 45%); --sf-gain:#1a7f37; --sf-loss:#c0392b;
    --sf-marker:#b8620a;
    position: relative; max-width: 100%; color: var(--sf-text);
    font-family: -apple-system, BlinkMacSystemFont, "Apple SD Gothic Neo", "Malgun Gothic",
      "Segoe UI", "Noto Sans KR", system-ui, sans-serif;
  }
  @media (prefers-color-scheme: dark) {
    .specdec-fig { --sf-page-bg:#0f1115; --sf-surface:#171a21; --sf-text:#e6e8eb; --sf-muted:#9aa3af;
      --sf-border:#2a2f3a; --sf-accent:hsl(217 91% 68%); --sf-gain:#3fb950; --sf-loss:#f0625a; --sf-marker:#e2a53a; }
  }
  .specdec-fig[data-theme="light"] { --sf-page-bg:#ffffff; --sf-surface:#f7f8fa; --sf-text:#1a1d21; --sf-muted:#6b7280;
    --sf-border:#d5d9e0; --sf-accent:hsl(217 91% 45%); --sf-gain:#1a7f37; --sf-loss:#c0392b; --sf-marker:#b8620a; }
  .specdec-fig[data-theme="dark"] { --sf-page-bg:#0f1115; --sf-surface:#171a21; --sf-text:#e6e8eb; --sf-muted:#9aa3af;
    --sf-border:#2a2f3a; --sf-accent:hsl(217 91% 68%); --sf-gain:#3fb950; --sf-loss:#f0625a; --sf-marker:#e2a53a; }

  .specdec-fig .sf-title { font-size: 15px; font-weight: 700; margin: 0 0 10px; color: var(--sf-text); }
  .specdec-fig .sf-canvas { overflow-x: auto; background: var(--sf-page-bg); }
  .specdec-fig svg.sf-svg { display: block; width: 100%; max-width: 100%; height: auto; font-family: inherit; }
  .specdec-fig .sf-axis-label { font-size: 10.5px; fill: var(--sf-muted); }
  .specdec-fig .sf-tick-label { font-size: 10px; fill: var(--sf-muted); }
  .specdec-fig .sf-gridline { stroke: var(--sf-border); stroke-width: 1; }
  .specdec-fig .sf-axis-line { stroke: var(--sf-border); stroke-width: 1.25; }
  .specdec-fig .sf-ref-line { stroke: var(--sf-loss); stroke-width: 1.5; stroke-dasharray: 5 4; }
  .specdec-fig .sf-ref-label { font-size: 10px; fill: var(--sf-loss); font-weight: 600; }
  .specdec-fig .sf-loss-shade { fill: var(--sf-loss); opacity: 0.07; }
  .specdec-fig .sf-marker-dot { fill: var(--sf-marker); stroke: var(--sf-page-bg); stroke-width: 2; }
  .specdec-fig .sf-marker-cross { stroke: var(--sf-marker); stroke-width: 1; stroke-dasharray: 3 3; opacity: 0.85; }
  .specdec-fig .sf-curve-point { stroke: var(--sf-page-bg); stroke-width: 1.5; }

  .specdec-fig .sf-controls { display: flex; flex-wrap: wrap; gap: 14px 22px; align-items: flex-end; margin: 12px 0; }
  .specdec-fig .sf-field { display: flex; flex-direction: column; gap: 4px; min-width: 160px; }
  .specdec-fig .sf-field label { font-size: 11.5px; font-weight: 600; color: var(--sf-muted); }
  .specdec-fig .sf-field .sf-field-value { font-size: 12px; font-weight: 700; color: var(--sf-text); font-variant-numeric: tabular-nums; }
  .specdec-fig input[type="range"] { width: 100%; accent-color: var(--sf-accent); min-height: 28px; cursor: pointer; }
  .specdec-fig input[type="range"]:focus-visible { outline: 2px solid var(--sf-accent); outline-offset: 2px; }
  .specdec-fig select { font: inherit; font-size: 12.5px; padding: 7px 8px; min-height: 34px; border-radius: 8px;
    border: 1px solid var(--sf-border); background: var(--sf-surface); color: var(--sf-text); cursor: pointer; }
  .specdec-fig select:hover { border-color: var(--sf-accent); }
  .specdec-fig select:focus-visible { outline: 2px solid var(--sf-accent); outline-offset: 1px; }
  .specdec-fig select:disabled { opacity: 0.5; cursor: default; }

  .specdec-fig .sf-readout { display: flex; flex-wrap: wrap; gap: 10px 22px; margin: 10px 0 4px; padding: 10px 14px;
    border: 1px solid var(--sf-border); border-radius: 10px; background: var(--sf-surface); }
  .specdec-fig .sf-readout .sf-ro-item { display: flex; flex-direction: column; gap: 2px; min-width: 92px; }
  .specdec-fig .sf-readout dt { font-size: 10.5px; color: var(--sf-muted); font-weight: 600; }
  .specdec-fig .sf-readout dd { margin: 0; font-size: 15px; font-weight: 700; font-variant-numeric: tabular-nums; }
  .specdec-fig .sf-verdict-gain { color: var(--sf-gain); }
  .specdec-fig .sf-verdict-loss { color: var(--sf-loss); }
  .specdec-fig .sf-verdict-flat { color: var(--sf-muted); }

  .specdec-fig .sf-assumption { font-size: 11.5px; color: var(--sf-muted); background: var(--sf-surface);
    border: 1px dashed var(--sf-border); border-radius: 8px; padding: 8px 10px; margin: 8px 0; }
  .specdec-fig .sf-formula { font-size: 12px; color: var(--sf-text); font-family: ui-monospace, "JetBrains Mono",
    SFMono-Regular, Menlo, Consolas, monospace; background: var(--sf-surface); border-radius: 8px; padding: 8px 10px;
    margin: 8px 0; overflow-x: auto; }

  .specdec-fig .sf-legend { display: flex; flex-wrap: wrap; gap: 8px 18px; align-items: center; margin-top: 8px; font-size: 11.5px; color: var(--sf-text); }
  .specdec-fig .sf-legend .sf-item { display: inline-flex; align-items: center; gap: 6px; white-space: nowrap; }
  .specdec-fig .sf-legend .sf-swatch { width: 20px; height: 0; border-top: 2.5px solid; flex: none; }
  .specdec-fig .sf-legend .sf-swatch.sf-dashed { border-top-style: dashed; }

  .specdec-fig .sf-caption { font-size: 11px; color: var(--sf-muted); margin-top: 8px; }

  @media (prefers-reduced-motion: reduce) {
    .specdec-fig * { transition: none !important; }
  }
  .specdec-fig.sf-reduced-motion * { transition: none !important; }
</style>
<script>
(function () {
  var SPEC = ({"kind": "concurrency-curve", "title": "동시성이 배수를 먹습니다: 같은 드래프터, 다른 손님 수", "ariaLabel": "동시 요청 수에 따른 추측 디코딩 속도 배수 변화 그래프. 세 계열 모두 동시성이 커질수록 배수가 1.0 아래로 떨어진다.", "width": 880, "height": 480, "xLabel": "동시 요청 수 c (로그 스케일)", "yLabel": "속도 배수 (드래프터 tok/s ÷ 베이스라인 tok/s)", "referenceLine": 1.0, "verdictBands": {"gainMin": 1.05, "lossMax": 0.95}, "xTicks": [1, 2, 4, 8, 16, 64], "series": [{"name": "NVFP4-GPTQ · 131k · max_num_seqs 256", "color": "hsl(217 91% 45%)", "points": [{"c": 1, "baseline": 130.4, "drafter": 174.3, "speedup": 1.337}, {"c": 4, "baseline": 450.6, "drafter": 551.4, "speedup": 1.224}, {"c": 16, "baseline": 1253.5, "drafter": 1314.1, "speedup": 1.048}, {"c": 64, "baseline": 2306.5, "drafter": 595.1, "speedup": 0.258}]}, {"name": "KV fp8 · 256k · Edge 예산", "color": "hsl(160 65% 32%)", "points": [{"c": 1, "baseline": 107.0, "drafter": 155.6, "speedup": 1.454}, {"c": 2, "baseline": 198.3, "drafter": 266.1, "speedup": 1.342}, {"c": 4, "baseline": 362.2, "drafter": 462.4, "speedup": 1.277}, {"c": 8, "baseline": 588.6, "drafter": 749.5, "speedup": 1.273}]}, {"name": "INT4 · 256k · Edge 예산", "color": "hsl(28 80% 42%)", "points": [{"c": 1, "baseline": 113.7, "drafter": 162.0, "speedup": 1.425}, {"c": 2, "baseline": 209.9, "drafter": 258.4, "speedup": 1.231}, {"c": 4, "baseline": 382.8, "drafter": 404.5, "speedup": 1.057}, {"c": 8, "baseline": 671.5, "drafter": 547.5, "speedup": 0.815}]}], "sourceCaption": "실측: docs/measurements/2026-08-29-metis-edge-dflash2-drafter.json (NVFP4-GPTQ, vLLM 0.28.0, B200) · docs/measurements/2026-08-31-metis-edge-dflash2-edge-budget.json (KV fp8 / INT4, 256k, 96GB 예산 흉내). 세 계열은 서로 다른 서빙 설정이라 계열 간 절댓값 비교는 하지 않는다."});
  var I18N = ({"refBreakeven": "손익분기점", "refLegend": "기준선 1.0x (아래 = 손해, 굵은 선 = 손해 구간)", "seriesLabel": "계열 선택", "seriesAria": "비교할 계열 선택", "concurrencyLabel": "동시성 c 이동", "roC": "동시성 c", "roBase": "베이스라인 tok/s", "roDraft": "드래프터 tok/s", "roSpeed": "배수", "roVerdict": "판정", "verdictGain": "이득", "verdictLoss": "손해", "verdictFlat": "본전", "costFallbackPrefix": "가정: 드래프트 토큰 1개 생성 비용 ≈ 검증 비용의 ", "costFallbackSuffix": "% (실측치 아님)", "alphaLabel": "수용률 α (드래프트 한 글자 적중률)", "gammaLabel": "드래프트 길이 γ", "roTau": "예상 수용 길이 τ", "roSpeed2": "추정 배수", "curveLegend": "현재 α에서 γ에 따른 τ 계산치", "measuredPrefix": "실측 "});
  var UID = 'sf-59db362606';
  var SVGNS = 'http://www.w3.org/2000/svg';

  function el(tag, attrs, ns) {
    var e = ns ? document.createElementNS(SVGNS, tag) : document.createElement(tag);
    if (attrs) {
      for (var k in attrs) {
        if (k === 'text') { e.textContent = attrs[k]; continue; }
        e.setAttribute(k, attrs[k]);
      }
    }
    return e;
  }
  function svgEl(tag, attrs) { return el(tag, attrs, true); }
  function fmt(n, d) { d = (d === undefined) ? 1 : d; return Number(n).toFixed(d); }
  function clamp(v, a, b) { return Math.max(a, Math.min(b, v)); }

  function niceStep(range, targetTicks) {
    var raw = range / Math.max(1, targetTicks);
    var mag = Math.pow(10, Math.floor(Math.log10(raw)));
    var norm = raw / mag;
    var step = (norm < 1.5) ? 1 : (norm < 3) ? 2 : (norm < 7) ? 5 : 10;
    return step * mag;
  }

  // -- theme sync: mirrors the blog's own <html data-theme> toggle, not just
  //    prefers-color-scheme, so a manual dark-mode toggle recolors the figure too.
  function wireTheme(container) {
    var sync = function () {
      var t = document.documentElement.getAttribute('data-theme');
      if (t === 'dark' || t === 'light') container.setAttribute('data-theme', t);
      else container.removeAttribute('data-theme');
    };
    sync();
    try {
      var mo = new MutationObserver(function (muts) {
        for (var i = 0; i < muts.length; i++) {
          if (muts[i].attributeName === 'data-theme') { sync(); break; }
        }
      });
      mo.observe(document.documentElement, { attributes: true, attributeFilter: ['data-theme'] });
    } catch (e) { /* MutationObserver unavailable: static theme via media query only */ }
    var reduced = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    if (reduced) container.classList.add('sf-reduced-motion');
  }

  function makeCanvasSvg(wrap, w, h, ariaLabel) {
    var svg = svgEl('svg', {
      class: 'sf-svg', viewBox: '0 0 ' + w + ' ' + h, preserveAspectRatio: 'xMidYMid meet',
      role: 'img', 'aria-label': ariaLabel || ''
    });
    wrap.appendChild(svg);
    return svg;
  }

  // ---------------------------------------------------------------------
  // kind: concurrency-curve
  // ---------------------------------------------------------------------
  function renderConcurrencyCurve(container, spec) {
    var W = spec.width || 880, H = spec.height || 460;
    var series = spec.series || [];
    var refY = (spec.referenceLine === undefined) ? 1.0 : spec.referenceLine;
    var bands = spec.verdictBands || { gainMin: 1.05, lossMax: 0.95 };
    var pad = { l: 58, r: 18, t: 14, b: 46 };
    var plotW = W - pad.l - pad.r, plotH = H - pad.t - pad.b;

    var xVals = [];
    series.forEach(function (s) { (s.points || []).forEach(function (p) { if (xVals.indexOf(p.c) === -1) xVals.push(p.c); }); });
    xVals.sort(function (a, b) { return a - b; });
    var xTicks = spec.xTicks && spec.xTicks.length ? spec.xTicks.slice() : xVals.slice();
    var cMin = Math.min.apply(null, xVals), cMax = Math.max.apply(null, xVals);
    var logMin = Math.log10(cMin), logMax = Math.log10(cMax);
    var logSpan = Math.max(1e-9, logMax - logMin);
    function xScale(c) { return pad.l + (Math.log10(c) - logMin) / logSpan * plotW; }

    var allSpeed = [refY];
    series.forEach(function (s) { (s.points || []).forEach(function (p) { allSpeed.push(p.speedup); }); });
    var rawMin = Math.min.apply(null, allSpeed), rawMax = Math.max.apply(null, allSpeed);
    var yMin = Math.max(0, Math.floor((rawMin - 0.08) * 10) / 10);
    var yMax = Math.ceil((rawMax + 0.08) * 10) / 10;
    function yScale(v) { return pad.t + (yMax - v) / (yMax - yMin) * plotH; }

    var wrap = el('div', { class: 'sf-body' });
    if (spec.title) wrap.appendChild(el('h4', { class: 'sf-title', text: spec.title }));
    var canvas = el('div', { class: 'sf-canvas' });
    wrap.appendChild(canvas);
    var svg = makeCanvasSvg(canvas, W, H, spec.ariaLabel || spec.title);

    // loss-shade region below the reference line
    var refPix = yScale(refY);
    svg.appendChild(svgEl('rect', { class: 'sf-loss-shade', x: pad.l, y: refPix, width: plotW, height: (pad.t + plotH) - refPix }));

    // y gridlines
    var yStep = niceStep(yMax - yMin, 5);
    for (var yv = Math.ceil(yMin / yStep) * yStep; yv <= yMax + 1e-9; yv += yStep) {
      var yp = yScale(yv);
      svg.appendChild(svgEl('line', { class: 'sf-gridline', x1: pad.l, x2: pad.l + plotW, y1: yp, y2: yp }));
      svg.appendChild(svgEl('text', { class: 'sf-tick-label', x: pad.l - 8, y: yp + 3.5, 'text-anchor': 'end', text: fmt(yv, 1) + 'x' }));
    }
    // x axis + ticks (log scale)
    svg.appendChild(svgEl('line', { class: 'sf-axis-line', x1: pad.l, x2: pad.l + plotW, y1: pad.t + plotH, y2: pad.t + plotH }));
    xTicks.forEach(function (c) {
      var xp = xScale(c);
      svg.appendChild(svgEl('line', { class: 'sf-gridline', x1: xp, x2: xp, y1: pad.t, y2: pad.t + plotH }));
      svg.appendChild(svgEl('text', { class: 'sf-tick-label', x: xp, y: pad.t + plotH + 16, 'text-anchor': 'middle', text: 'c=' + c }));
    });
    // reference line
    svg.appendChild(svgEl('line', { class: 'sf-ref-line', x1: pad.l, x2: pad.l + plotW, y1: refPix, y2: refPix }));
    svg.appendChild(svgEl('text', { class: 'sf-ref-label', x: pad.l + plotW, y: refPix - 4, 'text-anchor': 'end', text: I18N.refBreakeven + ' (' + fmt(refY, 1) + 'x)' }));
    // axis labels
    if (spec.xLabel) svg.appendChild(svgEl('text', { class: 'sf-axis-label', x: pad.l + plotW / 2, y: H - 4, 'text-anchor': 'middle', text: spec.xLabel }));
    if (spec.yLabel) {
      var yl = svgEl('text', { class: 'sf-axis-label', x: 0, y: 0, 'text-anchor': 'middle', transform: 'translate(12,' + (pad.t + plotH / 2) + ') rotate(-90)', text: spec.yLabel });
      svg.appendChild(yl);
    }

    function drawSegment(x0, y0, x1, y1, color, extra) {
      var p = svgEl('line', { x1: x0, y1: y0, x2: x1, y2: y1, stroke: color, 'stroke-width': extra ? 3.2 : 2.4, 'stroke-linecap': 'round' });
      svg.appendChild(p);
    }
    function drawColoredSegment(x0, y0, x1, y1, seriesColor) {
      var above0 = y0 <= refPix, above1 = y1 <= refPix;
      if (above0 === above1) { drawSegment(x0, y0, x1, y1, above0 ? seriesColor : 'var(--sf-loss)', !above0); return; }
      var t = (refPix - y0) / (y1 - y0);
      var xc = x0 + t * (x1 - x0);
      drawSegment(x0, y0, xc, refPix, above0 ? seriesColor : 'var(--sf-loss)', !above0);
      drawSegment(xc, refPix, x1, y1, above1 ? seriesColor : 'var(--sf-loss)', !above1);
    }

    var seriesPixel = series.map(function (s) {
      var pts = (s.points || []).slice().sort(function (a, b) { return a.c - b.c; });
      return pts.map(function (p) { return { c: p.c, baseline: p.baseline, drafter: p.drafter, speedup: p.speedup, x: xScale(p.c), y: yScale(p.speedup) }; });
    });
    seriesPixel.forEach(function (pts, si) {
      var color = series[si].color;
      for (var i = 0; i < pts.length - 1; i++) drawColoredSegment(pts[i].x, pts[i].y, pts[i + 1].x, pts[i + 1].y, color);
      pts.forEach(function (p) {
        var isLoss = p.speedup < refY;
        var c = svgEl('circle', { class: 'sf-curve-point', cx: p.x, cy: p.y, r: isLoss ? 4.6 : 4, fill: isLoss ? 'var(--sf-loss)' : color });
        var t = svgEl('title', { text: series[si].name + ' · c=' + p.c + ' · ' + fmt(p.speedup, 3) + 'x' });
        c.appendChild(t);
        svg.appendChild(c);
      });
    });

    // marker (updated by controls)
    var markerCrossX = svgEl('line', { class: 'sf-marker-cross', x1: pad.l, x2: pad.l + plotW, y1: 0, y2: 0 });
    var markerCrossY = svgEl('line', { class: 'sf-marker-cross', x1: 0, x2: 0, y1: pad.t, y2: pad.t + plotH });
    var markerDot = svgEl('circle', { class: 'sf-marker-dot', r: 6.5 });
    svg.appendChild(markerCrossX); svg.appendChild(markerCrossY); svg.appendChild(markerDot);

    // legend
    var legend = el('div', { class: 'sf-legend' });
    series.forEach(function (s) {
      var item = el('span', { class: 'sf-item' });
      item.appendChild(el('span', { class: 'sf-swatch', style: 'border-color:' + s.color }));
      item.appendChild(el('span', { text: s.name }));
      legend.appendChild(item);
    });
    var refItem = el('span', { class: 'sf-item' });
    refItem.appendChild(el('span', { class: 'sf-swatch sf-dashed', style: 'border-color:var(--sf-loss)' }));
    refItem.appendChild(el('span', { text: I18N.refLegend }));
    legend.appendChild(refItem);
    wrap.appendChild(legend);

    // controls
    var controls = el('div', { class: 'sf-controls' });
    var multi = series.length > 1;
    var seriesField = el('div', { class: 'sf-field' });
    seriesField.appendChild(el('label', { for: UID + '-series', text: I18N.seriesLabel }));
    var seriesSelect = el('select', { id: UID + '-series', 'aria-label': I18N.seriesAria });
    series.forEach(function (s, i) {
      var opt = el('option', { value: i, text: s.name });
      seriesSelect.appendChild(opt);
    });
    if (!multi) seriesSelect.disabled = true;
    seriesField.appendChild(seriesSelect);
    controls.appendChild(seriesField);

    var idxField = el('div', { class: 'sf-field', style: 'flex:1; min-width:220px;' });
    var idxLabel = el('label', { for: UID + '-idx', text: I18N.concurrencyLabel });
    idxField.appendChild(idxLabel);
    var idxSlider = el('input', { type: 'range', id: UID + '-idx', min: 0, max: 0, step: 1, value: 0 });
    idxField.appendChild(idxSlider);
    var idxValue = el('div', { class: 'sf-field-value' });
    idxField.appendChild(idxValue);
    controls.appendChild(idxField);
    wrap.appendChild(controls);

    // readout
    var readout = el('dl', { class: 'sf-readout', role: 'status', 'aria-live': 'polite' });
    function roItem(key, label) {
      var d = el('div', { class: 'sf-ro-item' });
      d.appendChild(el('dt', { text: label }));
      var dd = el('dd', { id: UID + '-ro-' + key });
      d.appendChild(dd);
      readout.appendChild(d);
      return dd;
    }
    var roC = roItem('c', I18N.roC);
    var roBase = roItem('base', I18N.roBase);
    var roDraft = roItem('draft', I18N.roDraft);
    var roSpeed = roItem('speed', I18N.roSpeed);
    var roVerdict = roItem('verdict', I18N.roVerdict);
    wrap.appendChild(readout);

    if (spec.sourceCaption) wrap.appendChild(el('div', { class: 'sf-caption', text: spec.sourceCaption }));

    function verdictOf(speed) {
      if (speed >= bands.gainMin) return { text: I18N.verdictGain, cls: 'sf-verdict-gain' };
      if (speed <= bands.lossMax) return { text: I18N.verdictLoss, cls: 'sf-verdict-loss' };
      return { text: I18N.verdictFlat, cls: 'sf-verdict-flat' };
    }

    function update() {
      var si = Number(seriesSelect.value) || 0;
      var pts = seriesPixel[si];
      idxSlider.max = Math.max(0, pts.length - 1);
      var ii = clamp(Number(idxSlider.value) || 0, 0, pts.length - 1);
      idxSlider.value = ii;
      var p = pts[ii];
      idxValue.textContent = 'c = ' + p.c;
      markerDot.setAttribute('cx', p.x); markerDot.setAttribute('cy', p.y);
      markerCrossX.setAttribute('y1', p.y); markerCrossX.setAttribute('y2', p.y);
      markerCrossY.setAttribute('x1', p.x); markerCrossY.setAttribute('x2', p.x);
      roC.textContent = String(p.c);
      roBase.textContent = fmt(p.baseline, 1);
      roDraft.textContent = fmt(p.drafter, 1);
      roSpeed.textContent = fmt(p.speedup, 3) + 'x';
      var v = verdictOf(p.speedup);
      roVerdict.textContent = v.text;
      roVerdict.className = v.cls;
    }
    seriesSelect.addEventListener('change', function () { idxSlider.value = 0; update(); });
    idxSlider.addEventListener('input', update);
    update();

    container.appendChild(wrap);
  }

  // ---------------------------------------------------------------------
  // kind: acceptance-calculator
  // ---------------------------------------------------------------------
  function renderAcceptanceCalculator(container, spec) {
    var W = spec.width || 800, H = spec.height || 380;
    var A = spec.alpha, G = spec.gamma;
    var r = (spec.costRatio && spec.costRatio.r != null) ? spec.costRatio.r : 0.15;
    var costLabel = (spec.costRatio && spec.costRatio.label) || (I18N.costFallbackPrefix + Math.round(r * 100) + I18N.costFallbackSuffix + ' (r=' + r + ')');
    var markers = spec.measuredMarkers || [];
    var pad = { l: 46, r: 16, t: 14, b: 40 };
    var plotW = W - pad.l - pad.r, plotH = H - pad.t - pad.b;

    var wrap = el('div', { class: 'sf-body' });
    if (spec.title) wrap.appendChild(el('h4', { class: 'sf-title', text: spec.title }));

    var controls = el('div', { class: 'sf-controls' });
    function slider(key, cfg, label, unitFmt) {
      var f = el('div', { class: 'sf-field', style: 'flex:1; min-width:220px;' });
      f.appendChild(el('label', { for: UID + '-' + key, text: label }));
      var s = el('input', { type: 'range', id: UID + '-' + key, min: cfg.min, max: cfg.max, step: cfg.step, value: cfg.default });
      f.appendChild(s);
      var v = el('div', { class: 'sf-field-value' });
      f.appendChild(v);
      controls.appendChild(f);
      return { input: s, value: v, fmt: unitFmt };
    }
    var alphaCtl = slider('alpha', A, I18N.alphaLabel, function (v) { return 'α = ' + fmt(v, 2); });
    var gammaCtl = slider('gamma', G, I18N.gammaLabel, function (v) { return 'γ = ' + Math.round(v); });
    wrap.appendChild(controls);

    var canvas = el('div', { class: 'sf-canvas' });
    wrap.appendChild(canvas);
    var svg = makeCanvasSvg(canvas, W, H, spec.ariaLabel || spec.title);

    var readout = el('dl', { class: 'sf-readout', role: 'status', 'aria-live': 'polite' });
    function roItem(key, label) {
      var d = el('div', { class: 'sf-ro-item' });
      d.appendChild(el('dt', { text: label }));
      var dd = el('dd', { id: UID + '-ro-' + key });
      d.appendChild(dd);
      readout.appendChild(d);
      return dd;
    }
    var roAlpha = roItem('alpha', 'α');
    var roGamma = roItem('gamma', 'γ');
    var roTau = roItem('tau', I18N.roTau);
    var roSpeed = roItem('speed', I18N.roSpeed2);
    wrap.appendChild(readout);

    var formula = el('div', { class: 'sf-formula' });
    wrap.appendChild(formula);
    var assumption = el('div', { class: 'sf-assumption', text: costLabel });
    wrap.appendChild(assumption);
    if (spec.formulaNote) wrap.appendChild(el('div', { class: 'sf-caption', text: spec.formulaNote }));

    var legend = el('div', { class: 'sf-legend' });
    var curveItem = el('span', { class: 'sf-item' });
    curveItem.appendChild(el('span', { class: 'sf-swatch', style: 'border-color:var(--sf-accent)' }));
    curveItem.appendChild(el('span', { text: I18N.curveLegend }));
    legend.appendChild(curveItem);
    markers.forEach(function (m) {
      var item = el('span', { class: 'sf-item' });
      item.appendChild(el('span', { class: 'sf-swatch sf-dashed', style: 'border-color:var(--sf-marker)' }));
      item.appendChild(el('span', { text: I18N.measuredPrefix + m.label + ' τ=' + fmt(m.tau, 2) + (m.source ? ' (' + m.source + ')' : '') }));
      legend.appendChild(item);
    });
    wrap.appendChild(legend);
    if (spec.sourceCaption) wrap.appendChild(el('div', { class: 'sf-caption', text: spec.sourceCaption }));

    function tauOf(alpha, gamma) {
      var t = 0;
      for (var k = 1; k <= gamma; k++) t += Math.pow(alpha, k);
      return t;
    }

    function draw() {
      while (svg.firstChild) svg.removeChild(svg.firstChild);
      var alpha = Number(alphaCtl.input.value);
      var gamma = Math.round(Number(gammaCtl.input.value));
      alphaCtl.value.textContent = alphaCtl.fmt(alpha);
      gammaCtl.value.textContent = gammaCtl.fmt(gamma);

      var gMin = Math.round(G.min), gMax = Math.round(G.max);
      var curve = [];
      for (var g = gMin; g <= gMax; g++) curve.push({ g: g, tau: tauOf(alpha, g) });
      var tauNow = tauOf(alpha, gamma);
      var speedNow = tauNow / (1 + gamma * r);

      var markerTaus = markers.map(function (m) { return m.tau; });
      var yMax = Math.max.apply(null, curve.map(function (p) { return p.tau; }).concat(markerTaus).concat([tauNow])) * 1.15;
      yMax = Math.ceil(yMax * 5) / 5;
      var yMin = 0;
      function xScale(g) { return pad.l + (g - gMin) / Math.max(1, (gMax - gMin)) * plotW; }
      function yScale(v) { return pad.t + (yMax - v) / (yMax - yMin) * plotH; }

      var yStep = niceStep(yMax - yMin, 5);
      for (var yv = 0; yv <= yMax + 1e-9; yv += yStep) {
        var yp = yScale(yv);
        svg.appendChild(svgEl('line', { class: 'sf-gridline', x1: pad.l, x2: pad.l + plotW, y1: yp, y2: yp }));
        svg.appendChild(svgEl('text', { class: 'sf-tick-label', x: pad.l - 8, y: yp + 3.5, 'text-anchor': 'end', text: fmt(yv, 1) }));
      }
      svg.appendChild(svgEl('line', { class: 'sf-axis-line', x1: pad.l, x2: pad.l + plotW, y1: pad.t + plotH, y2: pad.t + plotH }));
      for (var g2 = gMin; g2 <= gMax; g2++) {
        var xp = xScale(g2);
        svg.appendChild(svgEl('text', { class: 'sf-tick-label', x: xp, y: pad.t + plotH + 16, 'text-anchor': 'middle', text: String(g2) }));
      }
      svg.appendChild(svgEl('text', { class: 'sf-axis-label', x: pad.l + plotW / 2, y: H - 4, 'text-anchor': 'middle', text: I18N.gammaLabel }));
      svg.appendChild(svgEl('text', { class: 'sf-axis-label', x: 0, y: 0, 'text-anchor': 'middle', transform: 'translate(12,' + (pad.t + plotH / 2) + ') rotate(-90)', text: I18N.roTau }));

      markers.forEach(function (m) {
        var yp = yScale(m.tau);
        svg.appendChild(svgEl('line', { x1: pad.l, x2: pad.l + plotW, y1: yp, y2: yp, stroke: 'var(--sf-marker)', 'stroke-width': 1.5, 'stroke-dasharray': '5 4' }));
        svg.appendChild(svgEl('text', { class: 'sf-tick-label', x: pad.l + plotW, y: yp - 4, 'text-anchor': 'end', text: m.label + ' τ=' + fmt(m.tau, 2) }));
      });

      var d = curve.map(function (p, i) { return (i === 0 ? 'M' : 'L') + xScale(p.g) + ' ' + yScale(p.tau); }).join(' ');
      svg.appendChild(svgEl('path', { d: d, fill: 'none', stroke: 'var(--sf-accent)', 'stroke-width': 2.4, 'stroke-linecap': 'round' }));
      curve.forEach(function (p) {
        svg.appendChild(svgEl('circle', { class: 'sf-curve-point', cx: xScale(p.g), cy: yScale(p.tau), r: 3, fill: 'var(--sf-accent)' }));
      });
      var mx = xScale(gamma), my = yScale(tauNow);
      svg.appendChild(svgEl('line', { class: 'sf-marker-cross', x1: pad.l, x2: pad.l + plotW, y1: my, y2: my }));
      svg.appendChild(svgEl('line', { class: 'sf-marker-cross', x1: mx, x2: mx, y1: pad.t, y2: pad.t + plotH }));
      svg.appendChild(svgEl('circle', { class: 'sf-marker-dot', cx: mx, cy: my, r: 6.5 }));

      roAlpha.textContent = fmt(alpha, 2);
      roGamma.textContent = String(gamma);
      roTau.textContent = fmt(tauNow, 2);
      roSpeed.textContent = fmt(speedNow, 2) + 'x';

      var terms;
      if (gamma <= 5) {
        terms = [];
        for (var k1 = 1; k1 <= gamma; k1++) terms.push('α' + sup(k1));
      } else {
        terms = ['α' + sup(1), 'α' + sup(2), '…', 'α' + sup(gamma)];
      }
      formula.textContent = 'τ = ' + terms.join(' + ') + ' = ' + fmt(tauNow, 3) + '  (α=' + fmt(alpha, 2) + ')';
    }
    function sup(n) {
      var map = { 0: '⁰', 1: '¹', 2: '²', 3: '³', 4: '⁴', 5: '⁵', 6: '⁶', 7: '⁷', 8: '⁸', 9: '⁹' };
      return String(n).split('').map(function (c) { return map[c] || c; }).join('');
    }

    alphaCtl.input.addEventListener('input', draw);
    gammaCtl.input.addEventListener('input', draw);
    draw();

    container.appendChild(wrap);
  }

  function bootstrap() {
    var container = document.getElementById(UID);
    if (!container || container.dataset.mounted === 'true') return;
    container.dataset.mounted = 'true';
    wireTheme(container);
    try {
      if (SPEC.kind === 'concurrency-curve') renderConcurrencyCurve(container, SPEC);
      else if (SPEC.kind === 'acceptance-calculator') renderAcceptanceCalculator(container, SPEC);
      else throw new Error('unknown kind: ' + SPEC.kind);
    } catch (err) {
      var pre = document.createElement('pre');
      pre.style.color = '#c0392b';
      pre.style.fontSize = '12px';
      pre.textContent = 'Failed to render speculative-decoding figure: ' + (err && err.message ? err.message : err);
      container.appendChild(pre);
    }
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', bootstrap, { once: true });
  else bootstrap();
})();
</script>
{% endraw %}

*슬라이더로 동시 접속 수를 옮겨 보시면 어느 조건이 어디에서 1.0을 지나는지 보입니다. 세 계열은 서빙 설정이 서로 달라 계열 간 절댓값 비교는 하지 않습니다.*

같은 드래프터를 세 가지 조건에 붙여 자유 서술을 시켰을 때의 배수입니다. 가로는 동시 접속 수이고 세로는 타깃 체크포인트입니다.

| 조건 | 1명 | 2명 | 4명 | 8명 | 16명 | 64명 |
|---|---|---|---|---|---|---|
| NVFP4-GPTQ · 131k · 배치 256 | 1.34배 | 미측정 | 1.22배 | 미측정 | 1.05배 | 0.26배 |
| KV fp8 · 256k · Edge 예산 | 1.45배 | 1.34배 | 1.28배 | 1.27배 | 미측정 | 미측정 |
| INT4 · 256k · Edge 예산 | 1.43배 | 1.23배 | 1.06배 | **0.82배** | 미측정 | 미측정 |

세 줄 모두 왼쪽에서 오른쪽으로 내려갑니다. 다만 내려가는 속도가 다르고, 1.0을 지나는 지점도 다릅니다. 같은 기능을 켰다는 사실만으로는 이 표의 어느 칸에 있는지 알 수 없습니다.

즉, 사람 말로는 이렇습니다. 손님이 없을 때 안내원은 도움이 됩니다. 손님이 많을 때 안내원은 자리를 차지합니다.

기전은 연속 배칭에 있습니다. vLLM 같은 엔진은 요청을 순서대로 처리하지 않고 매 스텝마다 지금 살아 있는 요청들을 한 묶음으로 모아 한 번에 계산합니다. 손님이 여럿이면 그 묶음만으로도 연산 유닛이 이미 꽉 찹니다. 버스가 만석이 된 상태입니다. 이때 추측 디코딩은 좌석을 만들어 주지 않습니다. 확정되지도 않은 후보 토큰을 만석 버스에 억지로 밀어 넣을 뿐입니다. 기각되면 그 계산은 전부 버려집니다. 한가할 때 공짜였던 것이 붐빌 때는 그냥 낭비입니다.

그래서 운영에서 필요한 것은 켜거나 끄는 스위치가 아니라 임계 동시성입니다. 저희 경우 그 값은 체크포인트마다 달랐습니다. 같은 드래프터인데도 KV 캐시를 fp8로 둔 팔은 8명에서도 1.3배를 유지했습니다. INT4 팔은 같은 지점에서 이미 물에 잠겼습니다.

## 채점을 한 번에 하는 구조

왜 수용률이 그렇게 중요한지 보려면 검증이 어떻게 이뤄지는지 알아야 합니다. 드래프터는 다음 토큰 하나만 찍지 않습니다. 여러 갈래를 한꺼번에 제안합니다. 이 갈래들은 하나의 긴 줄로 펴진 다음, 어텐션 마스크가 각 후보에게 자기 조상만 보이도록 가려 줍니다. 이 가림막이 없으면 서로 다른 갈래의 후보들이 상대를 참고해 버려서 채점이 오염됩니다. 가림막 덕분에 타깃 모델은 단 한 번의 계산으로 모든 갈래를 동시에, 그러나 서로 독립적으로 채점합니다. 채점이 끝나면 가장 길게 살아남은 경로만 남기고 나머지는 버립니다.

버스로 돌아오면 안내원이 갈래를 만들어 태우는 셈입니다. "이 사람 다음엔 저 사람, 아니면 그 사람" 하는 식입니다. 기사님은 한 번 확인하면서 모든 갈래를 함께 검사합니다. 그러니 갈래를 아무리 늘려도 확인 비용은 거의 그대로입니다. 실제로 아끼는 것은 살아남은 경로의 길이만큼입니다. 이 길이를 수용 길이라고 부릅니다.

{% raw %}
<!--
  animated-architecture-diagram - self-contained D3 embed template.
  HuggingFace research-article style: declarative NODES/EDGES/SEQ model,
  data(solid)/event(dashed) edges, hover-trace + tooltip, flow-dot animation
  along edge paths, replay button, scroll-into-view autoplay, reduced-motion +
  light/dark aware. The renderer injects window.__ARCH_SPEC__ at the marker.
  Format (D3 machinery + CSS) is owned by this committed template; the model
  only authors the JSON spec (content). See references/spec-schema.md.
-->
<div class="d3-arch" data-arch-root id="arch-3c2a29f8e3"></div>
<style>
  /* ---- Theme tokens (standalone; light default + dark override) ---- */
  .d3-arch {
    --page-bg: #ffffff;
    --surface-bg: #f7f8fa;
    --text-color: #1a1d21;
    --muted-color: #6b7280;
    --border-color: #d5d9e0;
    --primary-color: hsl(217 91% 55%); /* brand accent, swap for #1B4F72 etc. */
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
  /* Size to the spec's natural canvas: JS caps max-width at the spec width so a
     narrow/portrait diagram is never stretched to the article column (blur + giant
     vertical figures); wide diagrams scale down but keep min-width 760 + scroll. */
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
    const SPEC = ({"title": "트리 검증: 한 번의 채점으로 여러 갈래", "ariaLabel": "드래프터가 한 토큰이 아니라 여러 후보 경로를 동시에 제안하고, 이 경로들을 하나의 시퀀스로 편평하게 이어 붙입니다. 어텐션 마스크가 각 후보 위치를 자기 조상만 보도록 막은 채, 타깃 모델이 한 번의 forward로 모든 갈래를 동시에 채점합니다. 가장 길게 살아남은 경로만 채택되고 나머지는 버려지며, 채택된 결과가 다음 스텝의 시작점이 됩니다.", "legendTitle": "범례", "legend": {"data": "트리 검증 파이프라인", "event": "다음 스텝 시작점 갱신"}, "hint": "구성 요소에 마우스를 올려 연결을 확인하세요.", "width": 1200, "height": 300, "hop": 800, "total": 4000, "groups": [{"x": 10, "y": 160, "w": 1180, "h": 108, "label": "트리 기반 초안 검증 (EAGLE 스타일)", "lx": 22, "ly": 178}], "nodes": [{"id": "propose", "x": 20, "y": 190, "w": 150, "h": 64, "title": ["드래프터가", "갈래를 제안"], "sub": "여러 후보 제안", "desc": "타깃이 한 번에 한 토큰만 확인하는 대신, 작은 드래프터가 여러 후보 경로(갈래)를 동시에 제안합니다."}, {"id": "flatten", "x": 240, "y": 190, "w": 170, "h": 64, "title": ["하나의 시퀀스로", "편평화"], "sub": "여러 경로를 한 줄로", "desc": "여러 후보 경로를 하나의 긴 시퀀스로 이어 붙여, 타깃 모델에 한 번만 넣을 수 있게 만듭니다."}, {"id": "mask", "x": 480, "y": 190, "w": 190, "h": 64, "title": "어텐션 마스크", "sub": "조상만 보게 차단", "desc": "각 후보 위치가 자기 조상 위치만 보고 다른 후보 갈래는 보지 못하도록 어텐션 마스크로 막습니다. 트리 구조를 하나의 forward에서 재현하는 핵심 장치입니다."}, {"id": "verify", "x": 740, "y": 190, "w": 150, "h": 64, "title": ["타깃 forward", "1회로 채점"], "sub": "모든 갈래 동시", "desc": "타깃 모델이 forward를 단 한 번만 돌려 편평화된 시퀀스 전체를 동시에 채점합니다."}, {"id": "accept", "x": 960, "y": 190, "w": 200, "h": 64, "title": "가장 긴 경로만 채택", "sub": "나머지는 버림", "desc": "채점 결과 가장 길게 살아남은 경로 하나만 채택하고 나머지 후보 갈래는 모두 버립니다."}], "edges": [{"src": "propose", "dst": "flatten", "kind": "data", "line": [170, 222, 240, 222], "label": "평면화", "lx": 205, "ly": 212}, {"src": "flatten", "dst": "mask", "kind": "data", "line": [410, 222, 480, 222], "label": "마스킹", "lx": 445, "ly": 212}, {"src": "mask", "dst": "verify", "kind": "data", "line": [670, 222, 740, 222], "label": "동시 채점", "lx": 705, "ly": 212}, {"src": "verify", "dst": "accept", "kind": "data", "line": [890, 222, 960, 222], "label": "가장 길게", "lx": 925, "ly": 212}, {"src": "accept", "dst": "propose", "kind": "event", "curve": [[1060, 190], [1060, 30], [95, 30], [95, 190]], "label": "다음 스텝 시작점 갱신", "off": "50%"}], "seq": [{"e": 0, "t0": 0}, {"e": 1, "t0": 800}, {"e": 2, "t0": 1600}, {"e": 3, "t0": 2400}, {"e": 4, "t0": 3200}]});
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
      const container = document.getElementById('arch-3c2a29f8e3')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'arch-3c2a29f8e3';
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
        // Never upscale past the spec's natural width; keep 760px readability
        // floor (with horizontal scroll) only for diagrams that are actually wide.
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

*갈래를 하나의 줄로 펴고 마스크로 가린 뒤 한 번에 채점합니다. 살아남은 가장 긴 경로만 채택하고 나머지는 버립니다.*

수용 길이가 배수를 지배합니다. 저희 측정에서 프롬프트를 그대로 옮겨 쓰는 복사형 작업의 수용 길이는 3.1이었습니다. 새 문장을 쓰는 자유 서술은 2.2에 그쳤습니다. 같은 조건에서 복사형은 동시 8명에서도 1.1배로 버텼고 자유 서술은 0.8배로 내려갔습니다. 차이는 오직 드래프터가 얼마나 잘 맞히느냐입니다.

## 수용률을 넣어 보세요

수용 길이는 수용률에서 계산으로 나옵니다. 한 토큰이 채택될 확률을 알파, 한 번에 제안하는 길이를 감마라고 하면 기대 수용 길이는 등비수열의 합이 됩니다. 아래 계산기에 여러분 서버의 수용률을 넣어 보시면, 왜 수용률이 조금만 떨어져도 배수가 급하게 무너지는지 눈으로 보실 수 있습니다. 저희 자유 서술 값 2.2가 곡선의 어디쯤인지도 함께 표시해 두었습니다.

{% raw %}
<div class="specdec-fig" data-sf-root id="sf-df8acd51a7"></div>
<style>
  .specdec-fig {
    --sf-page-bg:#ffffff; --sf-surface:#f7f8fa; --sf-text:#1a1d21; --sf-muted:#6b7280;
    --sf-border:#d5d9e0; --sf-accent:hsl(217 91% 45%); --sf-gain:#1a7f37; --sf-loss:#c0392b;
    --sf-marker:#b8620a;
    position: relative; max-width: 100%; color: var(--sf-text);
    font-family: -apple-system, BlinkMacSystemFont, "Apple SD Gothic Neo", "Malgun Gothic",
      "Segoe UI", "Noto Sans KR", system-ui, sans-serif;
  }
  @media (prefers-color-scheme: dark) {
    .specdec-fig { --sf-page-bg:#0f1115; --sf-surface:#171a21; --sf-text:#e6e8eb; --sf-muted:#9aa3af;
      --sf-border:#2a2f3a; --sf-accent:hsl(217 91% 68%); --sf-gain:#3fb950; --sf-loss:#f0625a; --sf-marker:#e2a53a; }
  }
  .specdec-fig[data-theme="light"] { --sf-page-bg:#ffffff; --sf-surface:#f7f8fa; --sf-text:#1a1d21; --sf-muted:#6b7280;
    --sf-border:#d5d9e0; --sf-accent:hsl(217 91% 45%); --sf-gain:#1a7f37; --sf-loss:#c0392b; --sf-marker:#b8620a; }
  .specdec-fig[data-theme="dark"] { --sf-page-bg:#0f1115; --sf-surface:#171a21; --sf-text:#e6e8eb; --sf-muted:#9aa3af;
    --sf-border:#2a2f3a; --sf-accent:hsl(217 91% 68%); --sf-gain:#3fb950; --sf-loss:#f0625a; --sf-marker:#e2a53a; }

  .specdec-fig .sf-title { font-size: 15px; font-weight: 700; margin: 0 0 10px; color: var(--sf-text); }
  .specdec-fig .sf-canvas { overflow-x: auto; background: var(--sf-page-bg); }
  .specdec-fig svg.sf-svg { display: block; width: 100%; max-width: 100%; height: auto; font-family: inherit; }
  .specdec-fig .sf-axis-label { font-size: 10.5px; fill: var(--sf-muted); }
  .specdec-fig .sf-tick-label { font-size: 10px; fill: var(--sf-muted); }
  .specdec-fig .sf-gridline { stroke: var(--sf-border); stroke-width: 1; }
  .specdec-fig .sf-axis-line { stroke: var(--sf-border); stroke-width: 1.25; }
  .specdec-fig .sf-ref-line { stroke: var(--sf-loss); stroke-width: 1.5; stroke-dasharray: 5 4; }
  .specdec-fig .sf-ref-label { font-size: 10px; fill: var(--sf-loss); font-weight: 600; }
  .specdec-fig .sf-loss-shade { fill: var(--sf-loss); opacity: 0.07; }
  .specdec-fig .sf-marker-dot { fill: var(--sf-marker); stroke: var(--sf-page-bg); stroke-width: 2; }
  .specdec-fig .sf-marker-cross { stroke: var(--sf-marker); stroke-width: 1; stroke-dasharray: 3 3; opacity: 0.85; }
  .specdec-fig .sf-curve-point { stroke: var(--sf-page-bg); stroke-width: 1.5; }

  .specdec-fig .sf-controls { display: flex; flex-wrap: wrap; gap: 14px 22px; align-items: flex-end; margin: 12px 0; }
  .specdec-fig .sf-field { display: flex; flex-direction: column; gap: 4px; min-width: 160px; }
  .specdec-fig .sf-field label { font-size: 11.5px; font-weight: 600; color: var(--sf-muted); }
  .specdec-fig .sf-field .sf-field-value { font-size: 12px; font-weight: 700; color: var(--sf-text); font-variant-numeric: tabular-nums; }
  .specdec-fig input[type="range"] { width: 100%; accent-color: var(--sf-accent); min-height: 28px; cursor: pointer; }
  .specdec-fig input[type="range"]:focus-visible { outline: 2px solid var(--sf-accent); outline-offset: 2px; }
  .specdec-fig select { font: inherit; font-size: 12.5px; padding: 7px 8px; min-height: 34px; border-radius: 8px;
    border: 1px solid var(--sf-border); background: var(--sf-surface); color: var(--sf-text); cursor: pointer; }
  .specdec-fig select:hover { border-color: var(--sf-accent); }
  .specdec-fig select:focus-visible { outline: 2px solid var(--sf-accent); outline-offset: 1px; }
  .specdec-fig select:disabled { opacity: 0.5; cursor: default; }

  .specdec-fig .sf-readout { display: flex; flex-wrap: wrap; gap: 10px 22px; margin: 10px 0 4px; padding: 10px 14px;
    border: 1px solid var(--sf-border); border-radius: 10px; background: var(--sf-surface); }
  .specdec-fig .sf-readout .sf-ro-item { display: flex; flex-direction: column; gap: 2px; min-width: 92px; }
  .specdec-fig .sf-readout dt { font-size: 10.5px; color: var(--sf-muted); font-weight: 600; }
  .specdec-fig .sf-readout dd { margin: 0; font-size: 15px; font-weight: 700; font-variant-numeric: tabular-nums; }
  .specdec-fig .sf-verdict-gain { color: var(--sf-gain); }
  .specdec-fig .sf-verdict-loss { color: var(--sf-loss); }
  .specdec-fig .sf-verdict-flat { color: var(--sf-muted); }

  .specdec-fig .sf-assumption { font-size: 11.5px; color: var(--sf-muted); background: var(--sf-surface);
    border: 1px dashed var(--sf-border); border-radius: 8px; padding: 8px 10px; margin: 8px 0; }
  .specdec-fig .sf-formula { font-size: 12px; color: var(--sf-text); font-family: ui-monospace, "JetBrains Mono",
    SFMono-Regular, Menlo, Consolas, monospace; background: var(--sf-surface); border-radius: 8px; padding: 8px 10px;
    margin: 8px 0; overflow-x: auto; }

  .specdec-fig .sf-legend { display: flex; flex-wrap: wrap; gap: 8px 18px; align-items: center; margin-top: 8px; font-size: 11.5px; color: var(--sf-text); }
  .specdec-fig .sf-legend .sf-item { display: inline-flex; align-items: center; gap: 6px; white-space: nowrap; }
  .specdec-fig .sf-legend .sf-swatch { width: 20px; height: 0; border-top: 2.5px solid; flex: none; }
  .specdec-fig .sf-legend .sf-swatch.sf-dashed { border-top-style: dashed; }

  .specdec-fig .sf-caption { font-size: 11px; color: var(--sf-muted); margin-top: 8px; }

  @media (prefers-reduced-motion: reduce) {
    .specdec-fig * { transition: none !important; }
  }
  .specdec-fig.sf-reduced-motion * { transition: none !important; }
</style>
<script>
(function () {
  var SPEC = ({"kind": "acceptance-calculator", "title": "수용률을 넣어 보세요", "ariaLabel": "수용률 알파와 드래프트 길이 감마를 조절해 예상 수용 길이 타우와 추정 속도 배수를 계산하는 도구", "width": 820, "height": 400, "alpha": {"min": 0.3, "max": 0.95, "step": 0.01, "default": 0.7}, "gamma": {"min": 1, "max": 10, "step": 1, "default": 5}, "costRatio": {"r": 0.15, "label": "가정: 드래프트 토큰 1개를 만드는 비용 ≈ 검증(채점) 비용의 15% (r=0.15). 실측치가 아니라 배수를 어림잡기 위한 가정값입니다. 실제 비율은 드래프터와 본체 모델의 크기 차이에 따라 달라집니다."}, "formulaNote": "τ = α¹ + α² + ... + α^γ. 시리즈 입문 글에서 쓴 것과 같은 식입니다. k번째 글자가 살아남으려면 앞의 k-1개가 전부 맞아야 하므로 항이 α^k 로 줄어듭니다. 추정 배수는 τ / (1 + γ·r) 로 계산합니다.", "measuredMarkers": [{"label": "실측 자유 서술", "tau": 2.17, "source": "2026-08-29 원장"}, {"label": "실측 복사형", "tau": 3.08, "source": "2026-08-29 원장"}], "sourceCaption": "실측 마커 출처: docs/measurements/2026-08-29-metis-edge-dflash2-drafter.json (concurrency=1, freeform acceptance 2.165 · copy acceptance 3.075를 반올림). 곡선 자체는 이 글의 τ 공식으로 계산한 값이며 실측이 아닙니다."});
  var I18N = ({"refBreakeven": "손익분기점", "refLegend": "기준선 1.0x (아래 = 손해, 굵은 선 = 손해 구간)", "seriesLabel": "계열 선택", "seriesAria": "비교할 계열 선택", "concurrencyLabel": "동시성 c 이동", "roC": "동시성 c", "roBase": "베이스라인 tok/s", "roDraft": "드래프터 tok/s", "roSpeed": "배수", "roVerdict": "판정", "verdictGain": "이득", "verdictLoss": "손해", "verdictFlat": "본전", "costFallbackPrefix": "가정: 드래프트 토큰 1개 생성 비용 ≈ 검증 비용의 ", "costFallbackSuffix": "% (실측치 아님)", "alphaLabel": "수용률 α (드래프트 한 글자 적중률)", "gammaLabel": "드래프트 길이 γ", "roTau": "예상 수용 길이 τ", "roSpeed2": "추정 배수", "curveLegend": "현재 α에서 γ에 따른 τ 계산치", "measuredPrefix": "실측 "});
  var UID = 'sf-df8acd51a7';
  var SVGNS = 'http://www.w3.org/2000/svg';

  function el(tag, attrs, ns) {
    var e = ns ? document.createElementNS(SVGNS, tag) : document.createElement(tag);
    if (attrs) {
      for (var k in attrs) {
        if (k === 'text') { e.textContent = attrs[k]; continue; }
        e.setAttribute(k, attrs[k]);
      }
    }
    return e;
  }
  function svgEl(tag, attrs) { return el(tag, attrs, true); }
  function fmt(n, d) { d = (d === undefined) ? 1 : d; return Number(n).toFixed(d); }
  function clamp(v, a, b) { return Math.max(a, Math.min(b, v)); }

  function niceStep(range, targetTicks) {
    var raw = range / Math.max(1, targetTicks);
    var mag = Math.pow(10, Math.floor(Math.log10(raw)));
    var norm = raw / mag;
    var step = (norm < 1.5) ? 1 : (norm < 3) ? 2 : (norm < 7) ? 5 : 10;
    return step * mag;
  }

  // -- theme sync: mirrors the blog's own <html data-theme> toggle, not just
  //    prefers-color-scheme, so a manual dark-mode toggle recolors the figure too.
  function wireTheme(container) {
    var sync = function () {
      var t = document.documentElement.getAttribute('data-theme');
      if (t === 'dark' || t === 'light') container.setAttribute('data-theme', t);
      else container.removeAttribute('data-theme');
    };
    sync();
    try {
      var mo = new MutationObserver(function (muts) {
        for (var i = 0; i < muts.length; i++) {
          if (muts[i].attributeName === 'data-theme') { sync(); break; }
        }
      });
      mo.observe(document.documentElement, { attributes: true, attributeFilter: ['data-theme'] });
    } catch (e) { /* MutationObserver unavailable: static theme via media query only */ }
    var reduced = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    if (reduced) container.classList.add('sf-reduced-motion');
  }

  function makeCanvasSvg(wrap, w, h, ariaLabel) {
    var svg = svgEl('svg', {
      class: 'sf-svg', viewBox: '0 0 ' + w + ' ' + h, preserveAspectRatio: 'xMidYMid meet',
      role: 'img', 'aria-label': ariaLabel || ''
    });
    wrap.appendChild(svg);
    return svg;
  }

  // ---------------------------------------------------------------------
  // kind: concurrency-curve
  // ---------------------------------------------------------------------
  function renderConcurrencyCurve(container, spec) {
    var W = spec.width || 880, H = spec.height || 460;
    var series = spec.series || [];
    var refY = (spec.referenceLine === undefined) ? 1.0 : spec.referenceLine;
    var bands = spec.verdictBands || { gainMin: 1.05, lossMax: 0.95 };
    var pad = { l: 58, r: 18, t: 14, b: 46 };
    var plotW = W - pad.l - pad.r, plotH = H - pad.t - pad.b;

    var xVals = [];
    series.forEach(function (s) { (s.points || []).forEach(function (p) { if (xVals.indexOf(p.c) === -1) xVals.push(p.c); }); });
    xVals.sort(function (a, b) { return a - b; });
    var xTicks = spec.xTicks && spec.xTicks.length ? spec.xTicks.slice() : xVals.slice();
    var cMin = Math.min.apply(null, xVals), cMax = Math.max.apply(null, xVals);
    var logMin = Math.log10(cMin), logMax = Math.log10(cMax);
    var logSpan = Math.max(1e-9, logMax - logMin);
    function xScale(c) { return pad.l + (Math.log10(c) - logMin) / logSpan * plotW; }

    var allSpeed = [refY];
    series.forEach(function (s) { (s.points || []).forEach(function (p) { allSpeed.push(p.speedup); }); });
    var rawMin = Math.min.apply(null, allSpeed), rawMax = Math.max.apply(null, allSpeed);
    var yMin = Math.max(0, Math.floor((rawMin - 0.08) * 10) / 10);
    var yMax = Math.ceil((rawMax + 0.08) * 10) / 10;
    function yScale(v) { return pad.t + (yMax - v) / (yMax - yMin) * plotH; }

    var wrap = el('div', { class: 'sf-body' });
    if (spec.title) wrap.appendChild(el('h4', { class: 'sf-title', text: spec.title }));
    var canvas = el('div', { class: 'sf-canvas' });
    wrap.appendChild(canvas);
    var svg = makeCanvasSvg(canvas, W, H, spec.ariaLabel || spec.title);

    // loss-shade region below the reference line
    var refPix = yScale(refY);
    svg.appendChild(svgEl('rect', { class: 'sf-loss-shade', x: pad.l, y: refPix, width: plotW, height: (pad.t + plotH) - refPix }));

    // y gridlines
    var yStep = niceStep(yMax - yMin, 5);
    for (var yv = Math.ceil(yMin / yStep) * yStep; yv <= yMax + 1e-9; yv += yStep) {
      var yp = yScale(yv);
      svg.appendChild(svgEl('line', { class: 'sf-gridline', x1: pad.l, x2: pad.l + plotW, y1: yp, y2: yp }));
      svg.appendChild(svgEl('text', { class: 'sf-tick-label', x: pad.l - 8, y: yp + 3.5, 'text-anchor': 'end', text: fmt(yv, 1) + 'x' }));
    }
    // x axis + ticks (log scale)
    svg.appendChild(svgEl('line', { class: 'sf-axis-line', x1: pad.l, x2: pad.l + plotW, y1: pad.t + plotH, y2: pad.t + plotH }));
    xTicks.forEach(function (c) {
      var xp = xScale(c);
      svg.appendChild(svgEl('line', { class: 'sf-gridline', x1: xp, x2: xp, y1: pad.t, y2: pad.t + plotH }));
      svg.appendChild(svgEl('text', { class: 'sf-tick-label', x: xp, y: pad.t + plotH + 16, 'text-anchor': 'middle', text: 'c=' + c }));
    });
    // reference line
    svg.appendChild(svgEl('line', { class: 'sf-ref-line', x1: pad.l, x2: pad.l + plotW, y1: refPix, y2: refPix }));
    svg.appendChild(svgEl('text', { class: 'sf-ref-label', x: pad.l + plotW, y: refPix - 4, 'text-anchor': 'end', text: I18N.refBreakeven + ' (' + fmt(refY, 1) + 'x)' }));
    // axis labels
    if (spec.xLabel) svg.appendChild(svgEl('text', { class: 'sf-axis-label', x: pad.l + plotW / 2, y: H - 4, 'text-anchor': 'middle', text: spec.xLabel }));
    if (spec.yLabel) {
      var yl = svgEl('text', { class: 'sf-axis-label', x: 0, y: 0, 'text-anchor': 'middle', transform: 'translate(12,' + (pad.t + plotH / 2) + ') rotate(-90)', text: spec.yLabel });
      svg.appendChild(yl);
    }

    function drawSegment(x0, y0, x1, y1, color, extra) {
      var p = svgEl('line', { x1: x0, y1: y0, x2: x1, y2: y1, stroke: color, 'stroke-width': extra ? 3.2 : 2.4, 'stroke-linecap': 'round' });
      svg.appendChild(p);
    }
    function drawColoredSegment(x0, y0, x1, y1, seriesColor) {
      var above0 = y0 <= refPix, above1 = y1 <= refPix;
      if (above0 === above1) { drawSegment(x0, y0, x1, y1, above0 ? seriesColor : 'var(--sf-loss)', !above0); return; }
      var t = (refPix - y0) / (y1 - y0);
      var xc = x0 + t * (x1 - x0);
      drawSegment(x0, y0, xc, refPix, above0 ? seriesColor : 'var(--sf-loss)', !above0);
      drawSegment(xc, refPix, x1, y1, above1 ? seriesColor : 'var(--sf-loss)', !above1);
    }

    var seriesPixel = series.map(function (s) {
      var pts = (s.points || []).slice().sort(function (a, b) { return a.c - b.c; });
      return pts.map(function (p) { return { c: p.c, baseline: p.baseline, drafter: p.drafter, speedup: p.speedup, x: xScale(p.c), y: yScale(p.speedup) }; });
    });
    seriesPixel.forEach(function (pts, si) {
      var color = series[si].color;
      for (var i = 0; i < pts.length - 1; i++) drawColoredSegment(pts[i].x, pts[i].y, pts[i + 1].x, pts[i + 1].y, color);
      pts.forEach(function (p) {
        var isLoss = p.speedup < refY;
        var c = svgEl('circle', { class: 'sf-curve-point', cx: p.x, cy: p.y, r: isLoss ? 4.6 : 4, fill: isLoss ? 'var(--sf-loss)' : color });
        var t = svgEl('title', { text: series[si].name + ' · c=' + p.c + ' · ' + fmt(p.speedup, 3) + 'x' });
        c.appendChild(t);
        svg.appendChild(c);
      });
    });

    // marker (updated by controls)
    var markerCrossX = svgEl('line', { class: 'sf-marker-cross', x1: pad.l, x2: pad.l + plotW, y1: 0, y2: 0 });
    var markerCrossY = svgEl('line', { class: 'sf-marker-cross', x1: 0, x2: 0, y1: pad.t, y2: pad.t + plotH });
    var markerDot = svgEl('circle', { class: 'sf-marker-dot', r: 6.5 });
    svg.appendChild(markerCrossX); svg.appendChild(markerCrossY); svg.appendChild(markerDot);

    // legend
    var legend = el('div', { class: 'sf-legend' });
    series.forEach(function (s) {
      var item = el('span', { class: 'sf-item' });
      item.appendChild(el('span', { class: 'sf-swatch', style: 'border-color:' + s.color }));
      item.appendChild(el('span', { text: s.name }));
      legend.appendChild(item);
    });
    var refItem = el('span', { class: 'sf-item' });
    refItem.appendChild(el('span', { class: 'sf-swatch sf-dashed', style: 'border-color:var(--sf-loss)' }));
    refItem.appendChild(el('span', { text: I18N.refLegend }));
    legend.appendChild(refItem);
    wrap.appendChild(legend);

    // controls
    var controls = el('div', { class: 'sf-controls' });
    var multi = series.length > 1;
    var seriesField = el('div', { class: 'sf-field' });
    seriesField.appendChild(el('label', { for: UID + '-series', text: I18N.seriesLabel }));
    var seriesSelect = el('select', { id: UID + '-series', 'aria-label': I18N.seriesAria });
    series.forEach(function (s, i) {
      var opt = el('option', { value: i, text: s.name });
      seriesSelect.appendChild(opt);
    });
    if (!multi) seriesSelect.disabled = true;
    seriesField.appendChild(seriesSelect);
    controls.appendChild(seriesField);

    var idxField = el('div', { class: 'sf-field', style: 'flex:1; min-width:220px;' });
    var idxLabel = el('label', { for: UID + '-idx', text: I18N.concurrencyLabel });
    idxField.appendChild(idxLabel);
    var idxSlider = el('input', { type: 'range', id: UID + '-idx', min: 0, max: 0, step: 1, value: 0 });
    idxField.appendChild(idxSlider);
    var idxValue = el('div', { class: 'sf-field-value' });
    idxField.appendChild(idxValue);
    controls.appendChild(idxField);
    wrap.appendChild(controls);

    // readout
    var readout = el('dl', { class: 'sf-readout', role: 'status', 'aria-live': 'polite' });
    function roItem(key, label) {
      var d = el('div', { class: 'sf-ro-item' });
      d.appendChild(el('dt', { text: label }));
      var dd = el('dd', { id: UID + '-ro-' + key });
      d.appendChild(dd);
      readout.appendChild(d);
      return dd;
    }
    var roC = roItem('c', I18N.roC);
    var roBase = roItem('base', I18N.roBase);
    var roDraft = roItem('draft', I18N.roDraft);
    var roSpeed = roItem('speed', I18N.roSpeed);
    var roVerdict = roItem('verdict', I18N.roVerdict);
    wrap.appendChild(readout);

    if (spec.sourceCaption) wrap.appendChild(el('div', { class: 'sf-caption', text: spec.sourceCaption }));

    function verdictOf(speed) {
      if (speed >= bands.gainMin) return { text: I18N.verdictGain, cls: 'sf-verdict-gain' };
      if (speed <= bands.lossMax) return { text: I18N.verdictLoss, cls: 'sf-verdict-loss' };
      return { text: I18N.verdictFlat, cls: 'sf-verdict-flat' };
    }

    function update() {
      var si = Number(seriesSelect.value) || 0;
      var pts = seriesPixel[si];
      idxSlider.max = Math.max(0, pts.length - 1);
      var ii = clamp(Number(idxSlider.value) || 0, 0, pts.length - 1);
      idxSlider.value = ii;
      var p = pts[ii];
      idxValue.textContent = 'c = ' + p.c;
      markerDot.setAttribute('cx', p.x); markerDot.setAttribute('cy', p.y);
      markerCrossX.setAttribute('y1', p.y); markerCrossX.setAttribute('y2', p.y);
      markerCrossY.setAttribute('x1', p.x); markerCrossY.setAttribute('x2', p.x);
      roC.textContent = String(p.c);
      roBase.textContent = fmt(p.baseline, 1);
      roDraft.textContent = fmt(p.drafter, 1);
      roSpeed.textContent = fmt(p.speedup, 3) + 'x';
      var v = verdictOf(p.speedup);
      roVerdict.textContent = v.text;
      roVerdict.className = v.cls;
    }
    seriesSelect.addEventListener('change', function () { idxSlider.value = 0; update(); });
    idxSlider.addEventListener('input', update);
    update();

    container.appendChild(wrap);
  }

  // ---------------------------------------------------------------------
  // kind: acceptance-calculator
  // ---------------------------------------------------------------------
  function renderAcceptanceCalculator(container, spec) {
    var W = spec.width || 800, H = spec.height || 380;
    var A = spec.alpha, G = spec.gamma;
    var r = (spec.costRatio && spec.costRatio.r != null) ? spec.costRatio.r : 0.15;
    var costLabel = (spec.costRatio && spec.costRatio.label) || (I18N.costFallbackPrefix + Math.round(r * 100) + I18N.costFallbackSuffix + ' (r=' + r + ')');
    var markers = spec.measuredMarkers || [];
    var pad = { l: 46, r: 16, t: 14, b: 40 };
    var plotW = W - pad.l - pad.r, plotH = H - pad.t - pad.b;

    var wrap = el('div', { class: 'sf-body' });
    if (spec.title) wrap.appendChild(el('h4', { class: 'sf-title', text: spec.title }));

    var controls = el('div', { class: 'sf-controls' });
    function slider(key, cfg, label, unitFmt) {
      var f = el('div', { class: 'sf-field', style: 'flex:1; min-width:220px;' });
      f.appendChild(el('label', { for: UID + '-' + key, text: label }));
      var s = el('input', { type: 'range', id: UID + '-' + key, min: cfg.min, max: cfg.max, step: cfg.step, value: cfg.default });
      f.appendChild(s);
      var v = el('div', { class: 'sf-field-value' });
      f.appendChild(v);
      controls.appendChild(f);
      return { input: s, value: v, fmt: unitFmt };
    }
    var alphaCtl = slider('alpha', A, I18N.alphaLabel, function (v) { return 'α = ' + fmt(v, 2); });
    var gammaCtl = slider('gamma', G, I18N.gammaLabel, function (v) { return 'γ = ' + Math.round(v); });
    wrap.appendChild(controls);

    var canvas = el('div', { class: 'sf-canvas' });
    wrap.appendChild(canvas);
    var svg = makeCanvasSvg(canvas, W, H, spec.ariaLabel || spec.title);

    var readout = el('dl', { class: 'sf-readout', role: 'status', 'aria-live': 'polite' });
    function roItem(key, label) {
      var d = el('div', { class: 'sf-ro-item' });
      d.appendChild(el('dt', { text: label }));
      var dd = el('dd', { id: UID + '-ro-' + key });
      d.appendChild(dd);
      readout.appendChild(d);
      return dd;
    }
    var roAlpha = roItem('alpha', 'α');
    var roGamma = roItem('gamma', 'γ');
    var roTau = roItem('tau', I18N.roTau);
    var roSpeed = roItem('speed', I18N.roSpeed2);
    wrap.appendChild(readout);

    var formula = el('div', { class: 'sf-formula' });
    wrap.appendChild(formula);
    var assumption = el('div', { class: 'sf-assumption', text: costLabel });
    wrap.appendChild(assumption);
    if (spec.formulaNote) wrap.appendChild(el('div', { class: 'sf-caption', text: spec.formulaNote }));

    var legend = el('div', { class: 'sf-legend' });
    var curveItem = el('span', { class: 'sf-item' });
    curveItem.appendChild(el('span', { class: 'sf-swatch', style: 'border-color:var(--sf-accent)' }));
    curveItem.appendChild(el('span', { text: I18N.curveLegend }));
    legend.appendChild(curveItem);
    markers.forEach(function (m) {
      var item = el('span', { class: 'sf-item' });
      item.appendChild(el('span', { class: 'sf-swatch sf-dashed', style: 'border-color:var(--sf-marker)' }));
      item.appendChild(el('span', { text: I18N.measuredPrefix + m.label + ' τ=' + fmt(m.tau, 2) + (m.source ? ' (' + m.source + ')' : '') }));
      legend.appendChild(item);
    });
    wrap.appendChild(legend);
    if (spec.sourceCaption) wrap.appendChild(el('div', { class: 'sf-caption', text: spec.sourceCaption }));

    function tauOf(alpha, gamma) {
      var t = 0;
      for (var k = 1; k <= gamma; k++) t += Math.pow(alpha, k);
      return t;
    }

    function draw() {
      while (svg.firstChild) svg.removeChild(svg.firstChild);
      var alpha = Number(alphaCtl.input.value);
      var gamma = Math.round(Number(gammaCtl.input.value));
      alphaCtl.value.textContent = alphaCtl.fmt(alpha);
      gammaCtl.value.textContent = gammaCtl.fmt(gamma);

      var gMin = Math.round(G.min), gMax = Math.round(G.max);
      var curve = [];
      for (var g = gMin; g <= gMax; g++) curve.push({ g: g, tau: tauOf(alpha, g) });
      var tauNow = tauOf(alpha, gamma);
      var speedNow = tauNow / (1 + gamma * r);

      var markerTaus = markers.map(function (m) { return m.tau; });
      var yMax = Math.max.apply(null, curve.map(function (p) { return p.tau; }).concat(markerTaus).concat([tauNow])) * 1.15;
      yMax = Math.ceil(yMax * 5) / 5;
      var yMin = 0;
      function xScale(g) { return pad.l + (g - gMin) / Math.max(1, (gMax - gMin)) * plotW; }
      function yScale(v) { return pad.t + (yMax - v) / (yMax - yMin) * plotH; }

      var yStep = niceStep(yMax - yMin, 5);
      for (var yv = 0; yv <= yMax + 1e-9; yv += yStep) {
        var yp = yScale(yv);
        svg.appendChild(svgEl('line', { class: 'sf-gridline', x1: pad.l, x2: pad.l + plotW, y1: yp, y2: yp }));
        svg.appendChild(svgEl('text', { class: 'sf-tick-label', x: pad.l - 8, y: yp + 3.5, 'text-anchor': 'end', text: fmt(yv, 1) }));
      }
      svg.appendChild(svgEl('line', { class: 'sf-axis-line', x1: pad.l, x2: pad.l + plotW, y1: pad.t + plotH, y2: pad.t + plotH }));
      for (var g2 = gMin; g2 <= gMax; g2++) {
        var xp = xScale(g2);
        svg.appendChild(svgEl('text', { class: 'sf-tick-label', x: xp, y: pad.t + plotH + 16, 'text-anchor': 'middle', text: String(g2) }));
      }
      svg.appendChild(svgEl('text', { class: 'sf-axis-label', x: pad.l + plotW / 2, y: H - 4, 'text-anchor': 'middle', text: I18N.gammaLabel }));
      svg.appendChild(svgEl('text', { class: 'sf-axis-label', x: 0, y: 0, 'text-anchor': 'middle', transform: 'translate(12,' + (pad.t + plotH / 2) + ') rotate(-90)', text: I18N.roTau }));

      markers.forEach(function (m) {
        var yp = yScale(m.tau);
        svg.appendChild(svgEl('line', { x1: pad.l, x2: pad.l + plotW, y1: yp, y2: yp, stroke: 'var(--sf-marker)', 'stroke-width': 1.5, 'stroke-dasharray': '5 4' }));
        svg.appendChild(svgEl('text', { class: 'sf-tick-label', x: pad.l + plotW, y: yp - 4, 'text-anchor': 'end', text: m.label + ' τ=' + fmt(m.tau, 2) }));
      });

      var d = curve.map(function (p, i) { return (i === 0 ? 'M' : 'L') + xScale(p.g) + ' ' + yScale(p.tau); }).join(' ');
      svg.appendChild(svgEl('path', { d: d, fill: 'none', stroke: 'var(--sf-accent)', 'stroke-width': 2.4, 'stroke-linecap': 'round' }));
      curve.forEach(function (p) {
        svg.appendChild(svgEl('circle', { class: 'sf-curve-point', cx: xScale(p.g), cy: yScale(p.tau), r: 3, fill: 'var(--sf-accent)' }));
      });
      var mx = xScale(gamma), my = yScale(tauNow);
      svg.appendChild(svgEl('line', { class: 'sf-marker-cross', x1: pad.l, x2: pad.l + plotW, y1: my, y2: my }));
      svg.appendChild(svgEl('line', { class: 'sf-marker-cross', x1: mx, x2: mx, y1: pad.t, y2: pad.t + plotH }));
      svg.appendChild(svgEl('circle', { class: 'sf-marker-dot', cx: mx, cy: my, r: 6.5 }));

      roAlpha.textContent = fmt(alpha, 2);
      roGamma.textContent = String(gamma);
      roTau.textContent = fmt(tauNow, 2);
      roSpeed.textContent = fmt(speedNow, 2) + 'x';

      var terms;
      if (gamma <= 5) {
        terms = [];
        for (var k1 = 1; k1 <= gamma; k1++) terms.push('α' + sup(k1));
      } else {
        terms = ['α' + sup(1), 'α' + sup(2), '…', 'α' + sup(gamma)];
      }
      formula.textContent = 'τ = ' + terms.join(' + ') + ' = ' + fmt(tauNow, 3) + '  (α=' + fmt(alpha, 2) + ')';
    }
    function sup(n) {
      var map = { 0: '⁰', 1: '¹', 2: '²', 3: '³', 4: '⁴', 5: '⁵', 6: '⁶', 7: '⁷', 8: '⁸', 9: '⁹' };
      return String(n).split('').map(function (c) { return map[c] || c; }).join('');
    }

    alphaCtl.input.addEventListener('input', draw);
    gammaCtl.input.addEventListener('input', draw);
    draw();

    container.appendChild(wrap);
  }

  function bootstrap() {
    var container = document.getElementById(UID);
    if (!container || container.dataset.mounted === 'true') return;
    container.dataset.mounted = 'true';
    wireTheme(container);
    try {
      if (SPEC.kind === 'concurrency-curve') renderConcurrencyCurve(container, SPEC);
      else if (SPEC.kind === 'acceptance-calculator') renderAcceptanceCalculator(container, SPEC);
      else throw new Error('unknown kind: ' + SPEC.kind);
    } catch (err) {
      var pre = document.createElement('pre');
      pre.style.color = '#c0392b';
      pre.style.fontSize = '12px';
      pre.textContent = 'Failed to render speculative-decoding figure: ' + (err && err.message ? err.message : err);
      container.appendChild(pre);
    }
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', bootstrap, { once: true });
  else bootstrap();
})();
</script>
{% endraw %}

*곡선은 공식으로 계산한 값이고, 점선 두 개만 저희 실측입니다. 자유 서술이 2.2에 머무는 이유가 곡선의 완만한 구간에 있다는 것이 보입니다.*

## 양자화는 이득을 줄이지만 없애지 않습니다

두 번째 축은 체크포인트입니다. 여기서 흔히 오해가 생깁니다. 저희도 처음에는 양자화가 추측 디코딩을 망가뜨린다고 의심했습니다. 같은 조건에서 체크포인트만 바꿔 재 보니 그렇지 않았습니다.

원본 bf16 모델에서 기준선은 초당 88.7토큰이었고 드래프터를 켜면 266.4토큰이 되어 3.0배였습니다. 4비트로 양자화한 저희 체크포인트에서는 기준선이 129.0토큰으로 올라갑니다. 읽어 올 가중치가 줄었으니 당연합니다. 여기에 같은 드래프터를 켜면 286.9토큰이 되어 2.2배입니다. 배수는 3.0배에서 2.2배로 줄었습니다. 그런데 절대 처리량은 양자화와 드래프터를 함께 쓴 쪽이 가장 높습니다.

버스로 말하면 이렇습니다. 양자화는 버스를 더 작고 빠른 차로 바꾼 것입니다. 왕복이 싸졌으니 승객 한 명당 비용이 줄었습니다. 대신 남는 빈 좌석도 함께 줄었습니다. 추측 디코딩이 파먹던 것이 바로 그 빈 좌석입니다. 두 최적화는 같은 병목을 공략하기 때문에 부분적으로 겹칩니다. 그래도 둘 다 켜는 쪽이 가장 빠릅니다.

{% raw %}
<!--
  animated-architecture-diagram - self-contained D3 embed template.
  HuggingFace research-article style: declarative NODES/EDGES/SEQ model,
  data(solid)/event(dashed) edges, hover-trace + tooltip, flow-dot animation
  along edge paths, replay button, scroll-into-view autoplay, reduced-motion +
  light/dark aware. The renderer injects window.__ARCH_SPEC__ at the marker.
  Format (D3 machinery + CSS) is owned by this committed template; the model
  only authors the JSON spec (content). See references/spec-schema.md.
-->
<div class="d3-arch" data-arch-root id="arch-fa8debfaa1"></div>
<style>
  /* ---- Theme tokens (standalone; light default + dark override) ---- */
  .d3-arch {
    --page-bg: #ffffff;
    --surface-bg: #f7f8fa;
    --text-color: #1a1d21;
    --muted-color: #6b7280;
    --border-color: #d5d9e0;
    --primary-color: hsl(217 91% 55%); /* brand accent, swap for #1B4F72 etc. */
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
  /* Size to the spec's natural canvas: JS caps max-width at the spec width so a
     narrow/portrait diagram is never stretched to the article column (blur + giant
     vertical figures); wide diagrams scale down but keep min-width 760 + scroll. */
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
    const SPEC = ({"title": "대역폭 예산: 추측 디코딩이 파먹는 자리", "ariaLabel": "자기회귀 생성은 매 토큰마다 가중치 전체를 메모리에서 읽어야 해서 연산 유닛이 대부분 유휴 상태가 됩니다. 추측 디코딩은 드래프터가 여러 후보를 미리 쓰고 타깃이 한 번의 forward로 한꺼번에 채점해 이 유휴를 씁니다. bf16 경로는 88.7에서 266.4 tok/s로 3.00배, NVFP4-GPTQ 경로는 129.0에서 286.9 tok/s로 2.22배 빨라집니다. 양자화는 가중치를 4비트로 줄여 읽을 것이 줄고 기준선이 오르지만, 그만큼 추측 디코딩이 파먹을 유휴도 줄어듭니다.", "legendTitle": "범례", "legend": {"data": "처리 흐름", "event": "유휴 예산에 미치는 영향"}, "hint": "구성 요소에 마우스를 올려 연결을 확인하세요.", "width": 1090, "height": 460, "hop": 800, "total": 4800, "groups": [{"x": 455, "y": 206, "w": 590, "h": 102, "label": "측정값 · 2026-08-22 B200 실측", "lx": 467, "ly": 224}, {"x": 10, "y": 326, "w": 585, "h": 102, "label": "양자화 경로", "lx": 22, "ly": 344}], "nodes": [{"id": "read_weights", "x": 20, "y": 50, "w": 200, "h": 64, "title": ["가중치 전체를", "메모리에서 읽음"], "sub": "매 토큰마다", "desc": "자기회귀 생성은 토큰 하나를 만들 때마다 모델 가중치 전체를 메모리에서 다시 읽어야 합니다."}, {"id": "idle", "x": 290, "y": 50, "w": 190, "h": 64, "title": ["연산 유닛은", "대부분 쉼"], "sub": "유휴 상태", "desc": "가중치를 나르는 동안 GPU의 연산 능력은 대부분 놀고 있습니다. 메모리 대역폭 병목입니다."}, {"id": "specdec", "x": 550, "y": 50, "w": 260, "h": 64, "title": "추측 디코딩이 유휴를 씀", "sub": "드래프터가 후보를 미리 씀", "desc": "작은 드래프터가 여러 후보 토큰을 먼저 쓰고, 타깃 모델이 한 번의 forward로 한꺼번에 채점합니다. 남는 계산력을 그대로 씁니다."}, {"id": "bf16_arm", "x": 470, "y": 230, "w": 230, "h": 64, "title": "bf16 경로", "sub": "88.7→266.4 tok/s (3.00배)", "desc": "bf16 그대로 서빙하면 추측 디코딩만으로 88.7 tok/s에서 266.4 tok/s로, 3.00배 빨라집니다."}, {"id": "nvfp4_arm", "x": 750, "y": 230, "w": 280, "h": 64, "title": "NVFP4-GPTQ 경로", "sub": "129→287 tok/s (2.22배 · 최고)", "desc": "NVFP4-GPTQ로 양자화한 뒤 추측 디코딩을 얹으면 129.0 tok/s에서 286.9 tok/s로, 2.22배. 배율은 더 작지만 절대 처리량은 두 경로 중 가장 높습니다."}, {"id": "quantize", "x": 20, "y": 350, "w": 220, "h": 64, "title": ["가중치를 4비트로", "줄임"], "sub": "NVFP4-GPTQ", "desc": "가중치를 4비트 정수로 양자화합니다 (NVFP4-GPTQ 레시피)."}, {"id": "baseline_up", "x": 310, "y": 350, "w": 270, "h": 64, "title": "읽을 것이 줄어 기준선이 오름", "sub": "파먹을 유휴가 줄어듦", "desc": "가중치가 작아지면 같은 forward에서 읽을 바이트가 줄어 기준선 처리량 자체가 올라갑니다. 그만큼 추측 디코딩이 파먹을 유휴도 줄어듭니다."}], "edges": [{"src": "read_weights", "dst": "idle", "kind": "data", "line": [220, 82, 290, 82], "label": "매번", "lx": 255, "ly": 72}, {"src": "idle", "dst": "specdec", "kind": "data", "line": [480, 82, 550, 82], "label": "남는 계산력", "lx": 515, "ly": 72}, {"src": "specdec", "dst": "bf16_arm", "kind": "data", "curve": [[610, 114], [610, 175], [585, 205], [585, 230]], "label": "추측 디코딩 적용", "off": "45%"}, {"src": "specdec", "dst": "nvfp4_arm", "kind": "data", "curve": [[750, 114], [750, 175], [890, 205], [890, 230]], "label": "동일 메커니즘", "off": "55%"}, {"src": "quantize", "dst": "baseline_up", "kind": "data", "line": [240, 382, 310, 382], "label": "정밀도 축소", "lx": 275, "ly": 372}, {"src": "baseline_up", "dst": "nvfp4_arm", "kind": "data", "curve": [[580, 382], [750, 382], [890, 340], [890, 294]], "label": "기준선 상승", "off": "50%"}, {"src": "baseline_up", "dst": "idle", "kind": "event", "curve": [[350, 350], [350, 270], [385, 180], [385, 114]], "label": "파먹을 유휴 자체가 줄어듦", "off": "45%"}], "seq": [{"e": 0, "t0": 0}, {"e": 1, "t0": 800}, {"e": 2, "t0": 1600}, {"e": 4, "t0": 1600}, {"e": 6, "t0": 2400}, {"e": 5, "t0": 2400}, {"e": 3, "t0": 3200}]});
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
      const container = document.getElementById('arch-fa8debfaa1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'arch-fa8debfaa1';
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
        // Never upscale past the spec's natural width; keep 760px readability
        // floor (with horizontal scroll) only for diagrams that are actually wide.
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

*양자화는 읽어 올 가중치를 줄여 기준선을 올립니다. 추측 디코딩이 파먹던 유휴가 그만큼 줄어듭니다. 두 최적화가 같은 병목을 공략하기 때문입니다.*

이 구분이 중요한 이유는, 배수가 줄었다고 드래프터를 빼면 절대 속도가 함께 내려가기 때문입니다. 판단 기준은 배수가 아니라 최종 처리량이어야 합니다.

## 안내원을 고르는 방법도 결과의 부호를 바꿉니다

드래프터를 어떻게 만드느냐도 축입니다. 프롬프트에서 이어질 만한 구절을 찾아 제안하는 방식이 있습니다. 모델의 내부 상태를 보고 학습으로 예측하는 방식도 있습니다. 앞의 것은 정류장에 붙은 명단을 보고 찍는 안내원입니다. 뒤의 것은 단골 얼굴을 아는 안내원입니다.

명단을 보는 방식은 답이 프롬프트 안에 있을 때만 잘 맞습니다. 저희가 양자화한 체크포인트 네 개에서 이 방식을 재 봤더니 자유 서술에서 전부 기준선보다 느렸습니다. 반면 원본 bf16 모델에서는 같은 방식이 이득을 냈습니다. 같은 워크로드인데 체크포인트에 따라 결론의 부호가 뒤집힌 것입니다. 학습된 드래프터는 그 축소를 견뎠습니다. 명단을 보는 방식은 견디지 못했습니다.

여기에 샘플링이 하나 더 얹힙니다. 논문의 배속표는 대개 온도 0에서 측정됩니다. 저희 서비스는 모델 설정에 따라 온도 1.0으로 돕니다. 같은 모델과 같은 설정에서 온도만 바꿔 재 보니 명단 방식의 배수가 수학 문제에서 1.3배에서 4.2배 구간이던 것이 0.3배에서 1.0배 구간으로 내려갔습니다. 이유는 단순합니다. 안내원은 가장 그럴듯한 승객을 지목합니다. 온도가 높으면 버스는 다른 승객을 태웁니다. 지목은 기각되고 확인 비용만 남습니다.

## 대가는 지연이 아니라 자리입니다

마지막 축은 메모리 예산입니다. 드래프터도 모델이라 자기 KV 캐시를 씁니다. Edge 예산을 흉내 낸 조건에서 재 보니 KV 캐시 풀이 약 36퍼센트 줄었습니다. 그만큼 담을 수 있는 대화가 줄어듭니다. 이것을 세션 수로 옮기면 256k 컨텍스트를 기준으로 동시에 담을 수 있는 세션이 6.7개에서 4.3개가 됩니다.

즉, 사람 말로는 안내원도 좌석에 앉는다는 뜻입니다. 짧은 대화를 많이 처리하는 서비스라면 신경 쓸 필요가 없습니다. 긴 문서를 다루는 서비스에서는 이 손실이 속도 이득보다 먼저 아플 수 있습니다.

## 그래서 무엇을 바꾸면 되나

먼저 여러분의 워크로드 구성비를 재십시오. 저희가 실제 트래픽에서 생성한 토큰의 93.5퍼센트는 자유 서술이었습니다. 프롬프트를 그대로 옮겨 쓰는 비율은 0.1 언저리에 머물렀습니다. 공개 벤치마크는 복사형에 가까운 작업이 많아 실제보다 후한 배수를 보여 줍니다. 벤치마크의 배속표는 여러분의 열이 아닐 가능성이 높습니다.

다음으로 배수 곡선을 여러분 장비에서 직접 그리십시오. 필요한 것은 한 점이 아니라 1.0을 가로지르는 지점입니다. 재는 방법은 어렵지 않습니다. 드래프터를 켠 팔과 끈 팔을 같은 실행 안에서 짝지어 놓고, 동시 접속을 1, 2, 4, 8, 16으로 올리며 각 지점의 초당 생성 토큰을 기록하면 됩니다. 워크로드는 실제 서비스가 받는 프롬프트로 하십시오. 공개 벤치마크 프롬프트로 재면 복사형에 가까워져 곡선이 실제보다 위에 그려집니다. 그리고 팔 사이에 엔진 버전이나 양자화 방식이 섞이지 않게 하십시오. 그렇게 섞인 비교는 드래프터의 효과가 아니라 두 서버의 차이를 잰 것입니다. 그 지점보다 낮은 동시성에서만 드래프터를 켜는 것이 지금으로서는 가장 안전한 운영입니다. 요청마다 켜고 끄는 기능은 아직 없습니다. 추측 여부는 엔진을 띄울 때 정해지고 엔드포인트 전체에 걸립니다. 그래서 지연이 중요한 트래픽과 대량 배치 트래픽을 같은 엔드포인트에 태우고 있다면, 먼저 그 둘을 나누는 것이 순서입니다.

그리고 켜기 전에 서빙 설정부터 보십시오. 저희는 컴파일이 꺼진 상태와 켜진 상태의 차이가 추측 디코딩의 이득보다 훨씬 크다는 것을 이미 확인한 적이 있습니다. 기본값으로 띄운 엔드포인트에 드래프터를 얹는 것은 순서가 뒤바뀐 일입니다.

켜 둔 뒤에는 수용률을 계속 보십시오. vLLM 은 추측 디코딩의 제안 수와 채택 수를 지표로 내보냅니다. 이 두 값의 비가 곧 앞의 계산기에서 넣어 보신 알파입니다. 배포한 다음에 트래픽 성격이 바뀌면 이 값이 조용히 내려가고, 배수도 같이 내려갑니다. 모델을 바꾸지 않았는데 느려졌다는 제보가 들어오면 이 지표를 먼저 보십시오. 체크포인트를 교체할 때도 마찬가지입니다. 저희는 서드파티 INT4 체크포인트로 갈아 끼웠을 때 유효 구간이 달라지는 것을 확인했습니다. 새 체크포인트를 올릴 때마다 임계 동시성은 다시 재야 합니다.

마지막으로 판단 기준을 배수가 아니라 최종 처리량과 세션 수용량으로 잡으십시오. 배수는 기준선이 느릴수록 커지는 숫자라서, 잘 튜닝된 서버일수록 작아 보입니다.

## 못 믿을 부분

정직하게 남겨 둡니다. 동시성 곡선은 각 조건에서 한 번씩 실행한 값입니다. 자유 서술 저동시성 구간은 산포가 조금 큽니다. Edge 예산 측정은 8k 길이의 고정 프롬프트로 했기 때문에, 실제 256k 프롬프트에서 드래프터가 어떻게 움직이는지는 아직 재지 않았습니다. 측정 장비는 B200입니다. 최종 목표 장비는 세대가 달라 커널이 다릅니다. 부호는 옮겨갈 가능성이 높지만 절대값은 아닙니다. 64명 지점의 붕괴는 실측이지만 그 지점에 맞는 최적 배치 설정은 따로 찾아보지 않았습니다. 온도 비교는 명단 방식 드래프터에서 잰 값이므로 학습된 드래프터에 그대로 옮기면 안 됩니다.

## ThakiCloud 관점

이 결과는 저희가 Metis 추론 서빙에서 추측 디코딩을 다루는 방식을 바꿨습니다. 기능을 전역으로 켜는 대신, 체크포인트마다 임계 동시성을 먼저 재고 그 아래 구간을 쓰는 엔드포인트에만 붙입니다. 온프렘 어플라이언스처럼 동시 사용자가 적고 응답 지연이 중요한 환경은 이 기술이 가장 잘 먹는 자리입니다. 반대로 대량 배치 처리에서는 켜지 않는 것이 낫습니다. 어떤 기능을 켤지를 아는 것만큼 언제 꺼야 하는지를 아는 것이 서빙 원가를 지킵니다.

## 함께 읽을 것

이 글은 품질이 아니라 속도를 다뤘습니다. 같은 간극을 품질 쪽에서 파고든 좋은 교육 자료가 있습니다. Lily Zhang과 Madison Kanna가 NeurIPS 2026 Education Track에 낸 [Speculative Decoding: How It Evolved, When It Stays Lossless, and What's Next](https://neurips2026-speculative-decoding.vercel.app/)는 추측 디코딩의 발전사와 무손실 보장이 배포 현장에서 언제 깨지는지를 그림과 인터랙티브 데모로 설명합니다. 특히 공개 트래픽의 일부만 측정된 도메인이라는 지적은 저희가 자체 트래픽에서 확인한 구성비 문제와 같은 이야기입니다.

시리즈의 앞선 글도 함께 보시면 도움이 됩니다. 원리는 [투기 디코딩 쉽게 읽기](/tech-blog/ko/llmops/speculative-decoding-easy-guide/), 양자화와의 조합은 [초당 97토큰이 458토큰이 됐습니다](/tech-blog/ko/llmops/quant-drafter-ladder/), 드래프터 선택은 [lookup이 안 맞았던 겁니다](/tech-blog/ko/llmops/speculative-decoding-lookup-vs-drafter/)에서 다뤘습니다.

측정 원장은 사내 `docs/measurements/2026-08-29-metis-edge-dflash2-drafter.json`과 `2026-08-31-metis-edge-dflash2-edge-budget.json`입니다.
