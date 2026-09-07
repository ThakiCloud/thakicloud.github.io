---
title: "We Left the Feature On and the Speedup Went From 1.4x to 0.8x"
excerpt: "The speedup you get from speculative decoding is set by your checkpoint, your concurrency, your sampling temperature, and your context budget, not by the number in a paper. We kept the same drafter running and raised concurrent users from one to eight. The gain turned into a loss."
date: 2026-09-07
permalink: /en/llmops/speculative-decoding-when-it-loses/
categories:
  - llmops
  - product
tags:
  - speculative-decoding
  - DFlash2
  - vLLM
  - concurrency
  - NVFP4
  - serving
  - B200
  - LLMOps
author_profile: true
toc: true
toc_label: "Contents"
header:
  teaser: /assets/images/speculative-decoding-when-it-loses-hero.webp
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/speculative-decoding-when-it-loses/"
---

![Descending bars crossing a threshold line, evoking a speedup curve going under break-even](/assets/images/speculative-decoding-when-it-loses-hero.webp)
*As riders fill the bus, the empty seats disappear. Those seats are exactly what speculative decoding was living on.*

The number to check before you turn on speculative decoding is not the speedup in a paper. It is how many concurrent users your server actually carries. We kept the same drafter switched on and raised concurrency from one user to eight, and the speedup fell from 1.4x to 0.8x. This is for anyone running inference in production who keeps asking why their own numbers never match the published ones.

## In plain terms

Picture a shuttle bus. For a large language model to write a single character, it has to read the entire model out of memory. That is a bus driving from the depot to the stop to pick up one passenger. The round trip costs roughly the same whether you carry one rider or ten, so anyone you add to a trip you were making anyway rides close to free. Speculative decoding is the technique that uses those empty seats. An attentive guide points at the next few likely passengers and loads them, and the driver checks everyone at once on arrival. Whoever was guessed right saves a whole round trip. Whoever was guessed wrong just gets off.

The catch is that the empty seats are not always there. When riders crowd in, the bus is already full and there is nowhere to put anyone extra. Swap in a smaller bus and each trip gets cheaper, but the spare seats shrink with it. This post is a record of when those seats disappear, measured on our own hardware.

## The speedup is attached to conditions, not to the feature

First, what we actually turned on. The target is our own 27B checkpoint, and the drafter is DFlash2 proposing seven tokens at a time. The engine is vLLM 0.28.0, and sampling matches what the live service uses. We paired the drafter-on and drafter-off arms inside the same run, and we only quote a speedup within that pair.

Measured that way, the speedup is not one number. It is a curve, and the curve crosses below 1.0. Where it crosses is the whole point of this post.

## Fill the bus and there are no seats left to take

Concurrency is the axis that collapses first. Running free-form generation on an INT4 checkpoint under an edge memory budget, one concurrent user gives 1.4x. Two gives 1.2x, four gives 1.1x, and eight gives 0.8x. Leave the feature on and eight simultaneous users make the server slower than it would be with the feature off. Push our production checkpoint to a larger batch and the same collapse gets more dramatic. At 64 concurrent users the baseline reaches 2,306 tokens per second, and turning the drafter on drops it to 595. That is 0.3x.

{% raw %}
<div class="specdec-fig" data-sf-root id="sf-551275ab58"></div>
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
  var SPEC = ({"kind": "concurrency-curve", "title": "Concurrency Eats the Multiplier: Same Drafter, More Guests", "ariaLabel": "Line chart of speculative-decoding speed multiplier versus concurrent request count. All three series fall below 1.0x as concurrency grows.", "width": 880, "height": 480, "xLabel": "Concurrent requests c (log scale)", "yLabel": "Speed multiplier (drafter tok/s ÷ baseline tok/s)", "referenceLine": 1.0, "verdictBands": {"gainMin": 1.05, "lossMax": 0.95}, "xTicks": [1, 2, 4, 8, 16, 64], "series": [{"name": "NVFP4-GPTQ · 131k · max_num_seqs 256", "color": "hsl(217 91% 45%)", "points": [{"c": 1, "baseline": 130.4, "drafter": 174.3, "speedup": 1.337}, {"c": 4, "baseline": 450.6, "drafter": 551.4, "speedup": 1.224}, {"c": 16, "baseline": 1253.5, "drafter": 1314.1, "speedup": 1.048}, {"c": 64, "baseline": 2306.5, "drafter": 595.1, "speedup": 0.258}]}, {"name": "KV fp8 · 256k · edge budget", "color": "hsl(160 65% 32%)", "points": [{"c": 1, "baseline": 107.0, "drafter": 155.6, "speedup": 1.454}, {"c": 2, "baseline": 198.3, "drafter": 266.1, "speedup": 1.342}, {"c": 4, "baseline": 362.2, "drafter": 462.4, "speedup": 1.277}, {"c": 8, "baseline": 588.6, "drafter": 749.5, "speedup": 1.273}]}, {"name": "INT4 · 256k · edge budget", "color": "hsl(28 80% 42%)", "points": [{"c": 1, "baseline": 113.7, "drafter": 162.0, "speedup": 1.425}, {"c": 2, "baseline": 209.9, "drafter": 258.4, "speedup": 1.231}, {"c": 4, "baseline": 382.8, "drafter": 404.5, "speedup": 1.057}, {"c": 8, "baseline": 671.5, "drafter": 547.5, "speedup": 0.815}]}], "sourceCaption": "Measured: docs/measurements/2026-08-29-metis-edge-dflash2-drafter.json (NVFP4-GPTQ, vLLM 0.28.0, B200) · docs/measurements/2026-08-31-metis-edge-dflash2-edge-budget.json (KV fp8 / INT4, 256k, emulating a 96GB budget). The three series use different serving configs, so absolute values are not compared across series."});
  var I18N = ({"refBreakeven": "Break-even", "refLegend": "Reference 1.0x (below is loss, shaded band is the loss zone)", "seriesLabel": "Series", "seriesAria": "Select series to compare", "concurrencyLabel": "Concurrency c", "roC": "Concurrency c", "roBase": "Baseline tok/s", "roDraft": "Drafter tok/s", "roSpeed": "Multiplier", "roVerdict": "Verdict", "verdictGain": "gain", "verdictLoss": "loss", "verdictFlat": "break-even", "costFallbackPrefix": "Assumption: generating one draft token costs about ", "costFallbackSuffix": "% of verification cost (not a measurement)", "alphaLabel": "Acceptance rate α (per-token draft hit rate)", "gammaLabel": "Draft length γ", "roTau": "Expected accepted length τ", "roSpeed2": "Estimated multiplier", "curveLegend": "τ computed from the formula at the current α, across γ", "measuredPrefix": "Measured "});
  var UID = 'sf-551275ab58';
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

*Drag the slider to see where each condition crosses 1.0. The three series run different serving configurations, so we do not compare their absolute values against each other.*

Here is the same drafter attached to three conditions, all on free-form generation. Columns are concurrent users, rows are the target checkpoint.

| Condition | 1 | 2 | 4 | 8 | 16 | 64 |
|---|---|---|---|---|---|---|
| NVFP4-GPTQ, 131k, batch 256 | 1.34x | not measured | 1.22x | not measured | 1.05x | 0.26x |
| KV fp8, 256k, edge budget | 1.45x | 1.34x | 1.28x | 1.27x | not measured | not measured |
| INT4, 256k, edge budget | 1.43x | 1.23x | 1.06x | **0.82x** | not measured | not measured |

Every row falls from left to right. They fall at different rates and they cross 1.0 at different places. Knowing that the feature is switched on tells you nothing about which cell you are sitting in.

In plain speech: when nobody is waiting, the guide helps. When everybody is waiting, the guide is taking up a seat.

The mechanism is continuous batching. Engines like vLLM do not process requests one after another. On every step they gather whatever requests are currently alive and compute them as one batch. With several users in flight, that batch alone already saturates the compute units. The bus is full. What speculative decoding does at that point is not create seats. It shoves unconfirmed candidate tokens onto a full bus, and everything rejected is compute thrown away. What was free when the bus was empty is pure waste when it is packed.

So what operations needs is not an on/off switch but a threshold concurrency. In our case that threshold moved with the checkpoint. With the same drafter, the arm running an fp8 KV cache held 1.3x even at eight users, while the INT4 arm was already underwater at the same point.

## Grading every branch in one pass

To see why the acceptance rate matters so much, you need to know how verification works. The drafter does not pick a single next token. It proposes several branches at once. Those branches get flattened into one long sequence, and an attention mask hides everything from each candidate except its own ancestors. Without that mask, candidates on different branches would read each other and contaminate the grading. With it, the target model grades every branch in a single forward pass, simultaneously but independently. When grading finishes, the longest surviving path is kept and the rest are discarded.

Back on the bus, the guide is not pointing at one passenger. The guide is building branches: this person, then that one, or otherwise that other one. The driver inspects all the branches in a single check. So adding branches barely changes the cost of checking, and what you actually save is the length of the path that survives. That length is called the acceptance length.

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
<div class="d3-arch" data-arch-root id="arch-340caf2e12"></div>
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
    const SPEC = ({"title": "Tree Verification: Many Branches, One Scoring Pass", "ariaLabel": "The drafter proposes several candidate paths at once instead of a single token, and flattens them into one sequence. An attention mask restricts each candidate position to seeing only its own ancestors, while the target model scores every branch at once in a single forward pass. Only the longest surviving path is accepted, the rest are discarded, and the accepted result becomes the start of the next step.", "legendTitle": "Legend", "legend": {"data": "Tree-verify pipeline", "event": "Next-step start update"}, "hint": "Hover over a component to see its connections.", "width": 1200, "height": 300, "hop": 800, "total": 4000, "groups": [{"x": 10, "y": 160, "w": 1180, "h": 108, "label": "Tree-based draft verification (EAGLE-style)", "lx": 22, "ly": 178}], "nodes": [{"id": "propose", "x": 20, "y": 190, "w": 150, "h": 64, "title": ["Drafter proposes", "branches"], "sub": "multiple candidates", "desc": "Instead of the target checking one token at a time, a small drafter proposes several candidate paths (branches) at once."}, {"id": "flatten", "x": 240, "y": 190, "w": 170, "h": 64, "title": ["Flatten into", "one sequence"], "sub": "many paths, one line", "desc": "Concatenates the candidate paths into one long sequence so they can be fed into the target model in a single pass."}, {"id": "mask", "x": 480, "y": 190, "w": 190, "h": 64, "title": "Attention mask", "sub": "blocks all but ancestors", "desc": "An attention mask blocks each candidate position from seeing any branch but its own ancestors. This is the key device that reproduces a tree structure inside a single forward pass."}, {"id": "verify", "x": 740, "y": 190, "w": 150, "h": 64, "title": ["Target forward", "scores once"], "sub": "all branches at once", "desc": "The target model runs a forward pass exactly once, scoring the entire flattened sequence all at the same time."}, {"id": "accept", "x": 960, "y": 190, "w": 200, "h": 64, "title": "Keep the longest path", "sub": "discard the rest", "desc": "After scoring, only the single longest surviving path is accepted; every other candidate branch is discarded."}], "edges": [{"src": "propose", "dst": "flatten", "kind": "data", "line": [170, 222, 240, 222], "label": "flatten", "lx": 205, "ly": 212}, {"src": "flatten", "dst": "mask", "kind": "data", "line": [410, 222, 480, 222], "label": "masking", "lx": 445, "ly": 212}, {"src": "mask", "dst": "verify", "kind": "data", "line": [670, 222, 740, 222], "label": "one pass", "lx": 705, "ly": 212}, {"src": "verify", "dst": "accept", "kind": "data", "line": [890, 222, 960, 222], "label": "longest wins", "lx": 925, "ly": 212}, {"src": "accept", "dst": "propose", "kind": "event", "curve": [[1060, 190], [1060, 30], [95, 30], [95, 190]], "label": "updates next step's start", "off": "50%"}], "seq": [{"e": 0, "t0": 0}, {"e": 1, "t0": 800}, {"e": 2, "t0": 1600}, {"e": 3, "t0": 2400}, {"e": 4, "t0": 3200}]});
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
      const container = document.getElementById('arch-340caf2e12')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'arch-340caf2e12';
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

*Branches are flattened into one line, masked so each candidate sees only its ancestors, then graded in a single pass. Only the longest surviving path is kept.*

Acceptance length governs the speedup. In our measurements, copy-style work that reproduces the prompt had an acceptance length of 3.1. Free-form writing came in at 2.2. Under identical conditions, copy-style held 1.1x even at eight concurrent users while free-form sank to 0.8x. The only difference is how often the drafter guesses right.

## Put your own acceptance rate in

Acceptance length follows from the acceptance rate by arithmetic. Call the chance that a single token is accepted alpha and the number of tokens proposed per round gamma, and the expected acceptance length is a geometric sum. Put your own acceptance rate into the calculator below and you can watch why a small drop in the rate collapses the speedup so quickly. We have marked where our own free-form value of 2.2 falls on the curve.

{% raw %}
<div class="specdec-fig" data-sf-root id="sf-1919a42ad2"></div>
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
  var SPEC = ({"kind": "acceptance-calculator", "title": "Try Different Acceptance Rates", "ariaLabel": "A tool that computes the expected accepted length tau and the estimated speed multiplier as you adjust the acceptance rate alpha and the draft length gamma.", "width": 820, "height": 400, "alpha": {"min": 0.3, "max": 0.95, "step": 0.01, "default": 0.7}, "gamma": {"min": 1, "max": 10, "step": 1, "default": 5}, "costRatio": {"r": 0.15, "label": "Assumption: generating one draft token costs about 15% of verification (scoring) cost (r=0.15). This is not a measurement, just an assumption used to estimate the multiplier. The real ratio depends on the size gap between the drafter and the target model."}, "formulaNote": "τ = α¹ + α² + ... + α^γ. This is the same formula used in the series' intro post. The k-th token survives only if all k-1 tokens before it were correct, so each term shrinks to α^k. The estimated multiplier is computed as τ / (1 + γ·r).", "measuredMarkers": [{"label": "freeform", "tau": 2.17, "source": "2026-08-29 ledger"}, {"label": "copy-style", "tau": 3.08, "source": "2026-08-29 ledger"}], "sourceCaption": "Measured-marker source: docs/measurements/2026-08-29-metis-edge-dflash2-drafter.json (concurrency=1, rounded from freeform acceptance 2.165 and copy acceptance 3.075). The curve itself is computed from this post's τ formula, not measured."});
  var I18N = ({"refBreakeven": "Break-even", "refLegend": "Reference 1.0x (below is loss, shaded band is the loss zone)", "seriesLabel": "Series", "seriesAria": "Select series to compare", "concurrencyLabel": "Concurrency c", "roC": "Concurrency c", "roBase": "Baseline tok/s", "roDraft": "Drafter tok/s", "roSpeed": "Multiplier", "roVerdict": "Verdict", "verdictGain": "gain", "verdictLoss": "loss", "verdictFlat": "break-even", "costFallbackPrefix": "Assumption: generating one draft token costs about ", "costFallbackSuffix": "% of verification cost (not a measurement)", "alphaLabel": "Acceptance rate α (per-token draft hit rate)", "gammaLabel": "Draft length γ", "roTau": "Expected accepted length τ", "roSpeed2": "Estimated multiplier", "curveLegend": "τ computed from the formula at the current α, across γ", "measuredPrefix": "Measured "});
  var UID = 'sf-1919a42ad2';
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

*The curve is computed from the formula. Only the two dashed lines are measured. You can see why free-form work sits on the flat part of the curve at 2.2.*

## Quantization shrinks the gain without removing it

The second axis is the checkpoint, and this is where a common misreading starts. We suspected at first that quantization was breaking speculative decoding. Changing only the checkpoint under otherwise identical conditions showed otherwise.

On the original bf16 model the baseline was 88.7 tokens per second, and turning on the drafter gave 266.4, a 3.0x gain. On our 4-bit checkpoint the baseline rises to 129.0, which is what you would expect when there are fewer weights to read. Adding the same drafter there gives 286.9, a 2.2x gain. The multiplier fell from 3.0x to 2.2x, and yet the highest absolute throughput belongs to the arm running quantization and the drafter together.

On the bus: quantization swapped in a smaller, faster vehicle. The round trip got cheaper, so the cost per rider fell, and the spare seats shrank along with it. Those spare seats were what speculative decoding had been eating. The two optimizations attack the same bottleneck, so they partly overlap. Running both is still the fastest option.

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
<div class="d3-arch" data-arch-root id="arch-d42510b160"></div>
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
    const SPEC = ({"title": "The Bandwidth Budget: Where Speculative Decoding Cuts In", "ariaLabel": "Autoregressive generation must read all the weights from memory for every single token, leaving compute units mostly idle. Speculative decoding puts that idle time to use: the drafter writes several candidates ahead of time, and the target scores them all at once in a single forward pass. The bf16 path speeds up 3.00x, from 88.7 to 266.4 tok/s, and the NVFP4-GPTQ path speeds up 2.22x, from 129.0 to 286.9 tok/s. Quantization shrinks the weights to 4 bits, so there is less to read and the baseline rises, but that also shrinks the idle time speculative decoding can eat into.", "legendTitle": "Legend", "legend": {"data": "Data flow", "event": "Effect on idle budget"}, "hint": "Hover over a component to see its connections.", "width": 1090, "height": 460, "hop": 800, "total": 4800, "groups": [{"x": 455, "y": 206, "w": 590, "h": 102, "label": "Measured · 2026-08-22 B200", "lx": 467, "ly": 224}, {"x": 10, "y": 326, "w": 585, "h": 102, "label": "Quantization path", "lx": 22, "ly": 344}], "nodes": [{"id": "read_weights", "x": 20, "y": 50, "w": 200, "h": 64, "title": ["Read full weights", "from memory"], "sub": "every token", "desc": "Autoregressive generation must re-read the entire model's weights from memory for every single token it produces."}, {"id": "idle", "x": 290, "y": 50, "w": 190, "h": 64, "title": ["Compute units", "mostly idle"], "sub": "idle state", "desc": "While weights are being moved, the GPU's compute capacity mostly sits idle. It is a memory-bandwidth bottleneck."}, {"id": "specdec", "x": 550, "y": 50, "w": 260, "h": 64, "title": ["Speculative decoding", "fills the idle time"], "sub": "drafter writes candidates first", "desc": "A small drafter writes several candidate tokens first, and the target model scores them all at once in a single forward pass, putting the GPU's spare compute to work."}, {"id": "bf16_arm", "x": 470, "y": 230, "w": 230, "h": 64, "title": "bf16 path", "sub": "88.7 to 266.4 tok/s (3.00x)", "desc": "Serving in plain bf16, speculative decoding alone takes it from 88.7 tok/s to 266.4 tok/s, a 3.00x speedup."}, {"id": "nvfp4_arm", "x": 750, "y": 230, "w": 280, "h": 64, "title": "NVFP4-GPTQ path", "sub": "129 to 287 tok/s (2.22x, highest)", "desc": "After quantizing to NVFP4-GPTQ and adding speculative decoding, throughput goes from 129.0 tok/s to 286.9 tok/s, a 2.22x speedup. The multiplier is smaller, but the absolute throughput is the highest of the two paths."}, {"id": "quantize", "x": 20, "y": 350, "w": 220, "h": 64, "title": ["Shrink weights to", "4 bits"], "sub": "NVFP4-GPTQ", "desc": "Quantizes the weights to 4-bit integers (the NVFP4-GPTQ recipe)."}, {"id": "baseline_up", "x": 310, "y": 350, "w": 270, "h": 64, "title": "Less to read raises the baseline", "sub": "less idle time to eat into", "desc": "Smaller weights mean fewer bytes to read per forward pass, so baseline throughput itself rises. That leaves less idle time for speculative decoding to eat into."}], "edges": [{"src": "read_weights", "dst": "idle", "kind": "data", "line": [220, 82, 290, 82], "label": "every time", "lx": 255, "ly": 72}, {"src": "idle", "dst": "specdec", "kind": "data", "line": [480, 82, 550, 82], "label": "spare compute", "lx": 515, "ly": 72}, {"src": "specdec", "dst": "bf16_arm", "kind": "data", "curve": [[610, 114], [610, 175], [585, 205], [585, 230]], "label": "apply spec decoding", "off": "45%"}, {"src": "specdec", "dst": "nvfp4_arm", "kind": "data", "curve": [[750, 114], [750, 175], [890, 205], [890, 230]], "label": "same mechanism", "off": "55%"}, {"src": "quantize", "dst": "baseline_up", "kind": "data", "line": [240, 382, 310, 382], "label": "fewer bits", "lx": 275, "ly": 372}, {"src": "baseline_up", "dst": "nvfp4_arm", "kind": "data", "curve": [[580, 382], [750, 382], [890, 340], [890, 294]], "label": "baseline rises", "off": "50%"}, {"src": "baseline_up", "dst": "idle", "kind": "event", "curve": [[350, 350], [350, 270], [385, 180], [385, 114]], "label": "less idle to eat into", "off": "45%"}], "seq": [{"e": 0, "t0": 0}, {"e": 1, "t0": 800}, {"e": 2, "t0": 1600}, {"e": 4, "t0": 1600}, {"e": 6, "t0": 2400}, {"e": 5, "t0": 2400}, {"e": 3, "t0": 3200}]});
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
      const container = document.getElementById('arch-d42510b160')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'arch-d42510b160';
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

*Quantization raises the baseline by leaving fewer weights to read, which shrinks the idle time speculative decoding was living on. Both optimizations attack the same bottleneck.*

This distinction matters because dropping the drafter on the grounds that its multiplier shrank also drops your absolute speed. The number to judge on is final throughput, not the multiplier.

## How you pick the guide also flips the sign

How the drafter is built is another axis. One approach searches the prompt for a plausible continuation and proposes that. Another predicts from the model's own hidden state after being trained to do so. The first is a guide reading names off a board at the stop. The second is a guide who knows the regulars by face.

Reading the board only works when the answer is already somewhere in the prompt. We measured that approach on four of our quantized checkpoints and it was slower than baseline on free-form generation in every one. On the original bf16 model the same approach produced a gain. Same workload, and the sign of the conclusion flipped with the checkpoint. The trained drafter absorbed the shrinking headroom. The board-reading one did not.

Sampling adds one more layer. Published speedup tables are usually measured at temperature zero. Our service runs at temperature 1.0 because the model config says so. Holding the model and the configuration fixed and changing only the temperature, the board-reading approach fell from a range of 1.3x to 4.2x on math problems down to a range of 0.3x to 1.0x. The reason is simple. The guide points at the most plausible passenger, and at a higher temperature the bus takes a different one. The guess is rejected and only the checking cost remains.

## The price is seats, not latency

The last axis is the memory budget. A drafter is a model too, and it keeps its own KV cache. Under a simulated edge budget, the KV cache pool shrank by roughly 36 percent. That is directly fewer conversations you can hold. Converted into sessions at a 256k context, what fit as 6.7 concurrent sessions becomes 4.3.

In plain speech, the guide also occupies a seat. A service handling many short chats will never notice. A service working through long documents may feel this loss before it ever feels the speed gain.

## What to change

Start by measuring your own workload mix. Of the tokens we generated on real traffic, 93.5 percent were free-form, and the share that copies straight out of the prompt sat around 0.1. Public benchmarks lean heavily on copy-like tasks, so they hand you a more generous multiplier than you will see. There is a good chance the benchmark column is not your column.

Next, draw the speedup curve on your own hardware. What you need is not one point but the place where the curve crosses 1.0. Measuring it is not hard. Pair a drafter-on arm and a drafter-off arm inside the same run, raise concurrency through 1, 2, 4, 8, and 16, and record tokens per second at each point. Use the prompts your service actually receives. Public benchmark prompts drift toward copy-style work and will draw the curve higher than reality. And do not let engine versions or quantization methods differ between the arms. A comparison mixed like that measures the difference between two servers, not the effect of the drafter.

Look at your serving configuration before you turn anything on. We have already found that the difference between compilation off and compilation on dwarfs anything speculative decoding contributes. Bolting a drafter onto an endpoint launched with defaults is doing things in the wrong order.

There is no per-request switch. Whether speculation runs is decided when the engine starts and it applies to the whole endpoint. So if latency-sensitive traffic and bulk batch traffic share one endpoint today, separating them is the first step.

Once it is on, keep watching the acceptance rate. vLLM exports the number of proposed and accepted tokens as metrics, and the ratio between them is the alpha you were moving in the calculator. If the character of your traffic shifts after deployment, that value quietly drops and the speedup follows it down. When someone reports that things got slower even though the model never changed, look at this metric first. The same applies when you swap checkpoints. We saw the useful range move when we switched to a third-party INT4 checkpoint. Every new checkpoint means measuring the threshold concurrency again.

Finally, judge on final throughput and session capacity rather than on the multiplier. The multiplier grows as the baseline gets worse, so the better tuned your server is, the smaller it will look.

## What not to trust here

Stated plainly. Each point on the concurrency curve comes from a single run, and the low-concurrency free-form region has noticeable spread. The edge-budget measurements used a fixed 8k prompt, so how the drafter behaves on a real 256k prompt is still unmeasured. We measured on B200, and the eventual target hardware is a different generation with different kernels. The sign of the result will probably carry over, but the absolute values will not. The collapse at 64 users is measured, though we did not go looking for the batch settings that would suit that point. The temperature comparison was measured on the board-reading drafter, so it should not be transferred to a trained one.

## How we read this at ThakiCloud

This changed how we handle speculative decoding in Metis inference serving. Rather than enabling it globally, we measure the threshold concurrency per checkpoint and attach the drafter only to endpoints that live below it. On-premise appliances, where concurrent users are few and response latency matters, are where this technique pays best. Bulk batch processing is where it should stay off. Knowing when to switch a feature off protects serving cost just as much as knowing when to switch it on.

## Further reading

This post is about speed, not quality. There is a good piece of teaching material that digs into the same gap from the quality side. [Speculative Decoding: How It Evolved, When It Stays Lossless, and What's Next](https://neurips2026-speculative-decoding.vercel.app/) by Lily Zhang and Madison Kanna, submitted to the NeurIPS 2026 Education Track, walks through the lineage of the technique and where the lossless guarantee breaks down in deployment, using figures and interactive demos. Their point that only a fraction of public traffic comes from measured domains is the same observation we reached from our own traffic mix.

Earlier posts in this series may help as well. The fundamentals are in [a plain guide to speculative decoding](/tech-blog/en/llmops/speculative-decoding-easy-guide/), the combination with quantization is in [97 tokens per second became 458](/tech-blog/en/llmops/quant-drafter-ladder/), and the choice of drafter is covered in [it was lookup that did not fit](/tech-blog/en/llmops/speculative-decoding-lookup-vs-drafter/).

The measurement ledgers are `docs/measurements/2026-08-29-metis-edge-dflash2-drafter.json` and `2026-08-31-metis-edge-dflash2-edge-budget.json`.
