---
title: "الاستعداد لما بعد NVFP4: دليل شامل لأساليب الضغط الكمّي لخدمة vLLM (بما فيها Unsloth)"
excerpt: "بعيدًا عن NVFP4 المخصّصة لـ Blackwell، هذا الدليل يغطّي كل أسلوب ضغط كمّي يمكن خدمته بـ vLLM اليوم على Hopper وAmpere -- AWQ وGPTQ وFP8 وW4A16 وcompressed-tensors وUnsloth Dynamic 2.0 -- مع وصفات عمليّة وأعلام الخدمة."
seo_title: "دليل شامل للضغط الكمّي مع vLLM: AWQ وGPTQ وFP8 وW4A16 وUnsloth - Thaki Cloud"
seo_description: "مقارنة شاملة لأساليب الضغط الكمّي لنماذج LLM مع vLLM. يشمل llm-compressor (compressed-tensors) للصيغ W4A16 وW8A8 وFP8، وAWQ+Marlin، وGPTQModel، وAutoRound، وUnsloth Dynamic 2.0، ومسار الإنتاج merge-to-AWQ، بكود حقيقي."
date: 2026-06-20
last_modified_at: 2026-06-20
lang: ar
canonical_url: https://thakicloud.com/tech-blog/ar/llmops/llm-quantization-vllm-serving-unsloth/
tags:
  - quantization
  - vllm
  - awq
  - gptq
  - fp8
  - llm-compressor
  - unsloth
  - compressed-tensors
  - moe
  - thakicloud
header:
  teaser: /assets/images/llm-quant-vllm-hero.webp
toc: true
toc_sticky: true
categories:
  - llmops
published: false
---

![خريطة صيغ الضغط الكمّي التي تخدمها vLLM]({{ '/assets/images/llm-quant-vllm-hero.webp' | relative_url }})

## لماذا الضغط الكمّي مرّة أخرى

يأتي الجزء الأكبر من تكلفة الخدمة من ذاكرة GPU والإنتاجية. ضغط النموذج إلى 4 بت يتيح لك تحميل نموذج أكبر على نفس البطاقة، وخدمة النموذج ذاته لعدد أكبر من المستخدمين المتزامنين. السؤال هو: أيّ أسلوب ضغط كمّي يعمل فعلًا بكفاءة مع vLLM في بيئة الإنتاج؟

[ضغط NVFP4](https://github.com/ThakiCloud/praxis) الذي تناولناه سابقًا هو المسار المتقدّم لتشغيل W4A4 على أنوية Blackwell (B200) tensor cores. لكن أنوية NVFP4 موجودة في Blackwell فقط. بالنسبة للأجيال السابقة كـ H100 وA100، أو للمجموعات المختلطة من الأجهزة، تحتاج إلى تقنيات مختلفة. هذا المقال يستبعد NVFP4 ويرصد الأساليب التي يمكنك استخدامها الآن مع الأجهزة التي تمتلكها -- بما فيها Unsloth Dynamic 2.0 -- مع وصفات عمليّة كاملة.

## خريطة الضغط الكمّي في vLLM

| الأسلوب | عرض البت | تحميل vLLM | GPU | ملاحظات |
|---|---|---|---|---|
| AWQ + Marlin | W4A16 | `--quantization awq` (Marlin تلقائي) | Turing+ | معيار 4 بت في الإنتاج |
| GPTQ / GPTQModel | W4A16, W3 | `--quantization gptq` | Volta+ | الأوسع توافقًا |
| compressed-tensors | W4A16 / W8A8 / FP8 | اكتشاف تلقائي (لا حاجة لعلم) | Turing+ ~ Blackwell | الصيغة الرسمية لـ llm-compressor |
| FP8 (E4M3) | W8A8 FP8 | `--quantization fp8` أو تلقائي | Ada (cc>=8.9)، Hopper، Blackwell | الخيار الأول لنماذج MoE |
| INT8 W8A8 | W8A8 INT8 | compressed-tensors تلقائي | Turing+ | عائلة SmoothQuant |
| AutoRound | W4A16, INT2-4 | compressed-tensors تلقائي | CUDA، CPU، Intel | دقّة ممتازة عند بتّات منخفضة جدًا |
| bitsandbytes NF4 | W4A16 | `--quantization bitsandbytes` | Volta-Hopper | مُحسَّن للذاكرة، إنتاجية منخفضة |
| GGUF | Q4-Q8 | `repo:quant` (إضافة) | تجريبي | للنظام البيئي llama.cpp |

نقطتان جوهريّتان: أولًا، معيار 4 بت في إنتاج vLLM هو W4A16 عبر AWQ أو GPTQ مع **نواة Marlin**. في معايير JarvisLabs على Qwen2.5-32B، بلغ Marlin-AWQ 741 tok/s مقابل 68 tok/s لنواة AWQ الأساسية -- فرق جوهري ([المصدر](https://jarvislabs.ai/blog/vllm-quantization-complete-guide-benchmarks)). ثانيًا، صيغة **compressed-tensors** -- التي طوّرتها neuralmagic (Red Hat) ومشروع vLLM معًا -- تخزّن بيانات الضغط الكمّي في `quantization_config`، ويقرؤها vLLM ويحمّلها تلقائيًا دون أي أعلام إضافية.

## compressed-tensors وllm-compressor: المسار الموصى به

الضغط باستخدام `llm-compressor` يُنتج مخرجات بصيغة compressed-tensors، يكتشفها vLLM تلقائيًا. تُعالَج W4A16 وW8A8-INT8 وFP8 جميعها بأداة واحدة ([llm-compressor](https://github.com/vllm-project/llm-compressor)).

```python
# W4A16 (AWQ 스타일) llm-compressor 레시피
from llmcompressor.transformers import oneshot
from llmcompressor.modifiers.quantization import GPTQModifier

recipe = GPTQModifier(scheme="W4A16", targets="Linear", ignore=["lm_head"])
oneshot(
    model="Qwen/Qwen3-30B-A3B",
    dataset="open_platypus",   # 보정(calibration) 셋
    recipe=recipe,
    output_dir="Qwen3-30B-A3B-W4A16",
    max_seq_length=2048, num_calibration_samples=512,
)
```

لا تحتاج الخدمة إلى أعلام تكاد تُذكر.

```bash
# compressed-tensors는 자동 감지, --quantization 생략 가능
vllm serve ./Qwen3-30B-A3B-W4A16 --served-model-name qwen3-w4a16
# AWQ 체크포인트를 직접 서빙할 때
vllm serve TheBloke/...-AWQ --quantization awq
```

يمكن إنشاء FP8 ديناميكيًا دون بيانات معايرة، مما يجعله الخيار الأقل جهدًا.

```python
from llmcompressor.modifiers.quantization import QuantizationModifier
recipe = QuantizationModifier(targets="Linear", scheme="FP8_DYNAMIC", ignore=["lm_head"])
```

## نماذج MoE (Qwen3-MoE): FP8 Block-Wise أولًا

أهداف الخدمة الأساسية لدينا هي نماذج عائلة Qwen3-MoE. معماريات MoE صعبة التعامل معها في الضغط الكمّي. الخلاصة المباشرة: على وحدات GPU بـ cc>=8.9 (Ada وHopper وBlackwell)، **FP8 block-wise** هو الخيار الأول. لا يحتاج إلى بيانات معايرة ويحظى بدعم رسمي في vLLM. إذا كانت الذاكرة أضيق، تراجع إلى W4A16. لاحظ أن FP8 per-tensor يعاني من خطأ عدم تطابق الأبعاد في Qwen3-MoE، لذا block-wise هو الأكثر أمانًا ([المشكلة](https://github.com/vllm-project/llm-compressor/issues/2043)).

## Unsloth: الضبط الدقيق وضغط Dynamic 2.0

لـ Unsloth فائدتان: الضبط الدقيق بـ QLoRA، وضغط Dynamic 2.0.

**Dynamic 2.0 (UD)** لا يطبّق عرض بت موحدًا على جميع الطبقات. بدلًا من ذلك، يقيّم حساسية كل طبقة ويُخصّص دقة أعلى للطبقات الحرجة بينما يضغط الطبقات الأقل أهمية أكثر. والنتيجة خريطة ضغط كمّي مخصّصة لكل نموذج. في المعايير التي نشرها Unsloth، سجّل Gemma 3 27B مع Dynamic Q4_K_XL نسبة 71.47% في MMLU 5-shot، متجاوزًا خط الأساس Google QAT البالغ 70.64%، فيما بلغ حجم الملف 15.64GB فقط (أرقام Unsloth، [المدوّنة](https://unsloth.ai/blog/dynamic-v2)). على عكس النسخة الأولى التي عملت بشكل رئيسي مع MoE، توسّعت النسخة 2.0 لتشمل النماذج الكثيفة (dense) أيضًا.

نقاط تفتيش `unsloth/...-bnb-4bit` هي نقاط تفتيش مُضغوطة مسبقًا بـ NF4 4-bit، وتُستخدم أساسًا كنقطة انطلاق للضبط الدقيق بـ QLoRA. بعد التدريب، تُنتج استدعاءٌ واحد لـ `save_pretrained_gguf()` ملفًا بصيغة GGUF لـ llama.cpp.

### المسار العملي من Unsloth إلى خدمة vLLM

الصراحة مطلوبة هنا. من الصيغ التي يُنتجها Unsloth، قليل منها يصلح مباشرةً لخدمة vLLM في الإنتاج. يمكن تحميل bitsandbytes NF4 في vLLM لكن إنتاجيّته منخفضة (وثمّة تقارير عن أخطاء في الأشكال shape لبعض النماذج). أما Dynamic UD-GGUF فهو صيغة خاصة بـ llama.cpp غير مذكورة في الوثائق الرسمية لـ vLLM، وإن دعم vLLM للـ GGUF نفسه مُصنَّف صراحةً بأنه "highly experimental" ([vLLM GGUF](https://docs.vllm.ai/en/latest/features/quantization/gguf/)).

المسار العملي في الإنتاج إذن هو: **الضبط الدقيق مع Unsloth، وإعادة الضغط الكمّي للخدمة**.

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
<div class="d3-arch" data-arch-root id="zationvllmservingunsloth-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 878, "height": 267, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 24, "y": 99, "w": 135, "h": 62, "title": ["Unsloth QLoRA", "تدريب NF4 4-bit"]}, {"id": "B", "x": 237, "y": 99, "w": 120, "h": 62, "title": ["دمج LoRA", "merged_16bit"]}, {"id": "C1", "x": 453, "y": 157, "w": 142, "h": 78, "title": ["محلي/صغير الحجم:", "GGUF Q4_K_M", "Ollama·llama.cpp"]}, {"id": "C2", "x": 435, "y": 24, "w": 177, "h": 78, "title": ["إنتاج vLLM:", "إعادة تكميم W4A16/FP8", "llm-compressor"]}, {"id": "D", "x": 690, "y": 24, "w": 156, "h": 78, "title": ["vllm serve", "تحميل تلقائي لـ", "compressed-tensors"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [159, 130, 237, 130]}, {"src": "B", "dst": "C1", "kind": "data", "curve": [[343, 161], [396, 196], [396, 196], [453, 196]]}, {"src": "B", "dst": "C2", "kind": "data", "curve": [[343, 99], [396, 63], [396, 63], [435, 63]]}, {"src": "C2", "dst": "D", "kind": "data", "line": [612, 63, 690, 63]}]});
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
      const container = document.getElementById('zationvllmservingunsloth-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'zationvllmservingunsloth-1';
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

```python
# Unsloth: QLoRA 학습 후 16bit 병합
model.save_pretrained_merged("merged_model", tokenizer, save_method="merged_16bit")
# 이어서 위 llm-compressor W4A16/FP8 레시피로 재양자화 → vLLM 서빙
```

للخدمة المحلية أو التجريبية، استخدام Dynamic GGUF من Unsloth مع Ollama أو llama.cpp خيار معقول تمامًا من حيث الدقة والراحة. أما لخدمة الإنتاج متعددة المستخدمين، فالدمج أولًا ثم إعادة الضغط إلى W4A16 أو FP8 يمنحك إنتاجية أفضل مع vLLM.

## التكلفة والمراقبة

الضغط الكمّي يُقلّل التكلفة لكنه ليس مجانيًا. ثلاثة أشياء يجب تتبّعها معًا: وفر الذاكرة (تحميل نموذج أكبر أو سياق أطول على نفس البطاقة)، والإنتاجية (وجود نواة Marlin من عدمه يحدّد الرموز في الثانية)، والدقة (يجب قياس الانحدار في كل مهمة). بعد النشر، راقب إنتاجية الرموز وزمن أول رمز (TTFT) واستخدام الذاكرة لكل بطاقة عبر مقاييس vLLM، وشغّل مجموعات التقييم الأساسية قبل الضغط وبعده لرصد أي انحدار.

## منظور ThakiCloud: لماذا كان هذا الملخّص ضروريًا

منصة الذكاء الاصطناعي في ThakiCloud تعمل على Kubernetes، وتجدول أعباء عمل GPU بـ Kueue، وتخدم النماذج بـ vLLM. منصة الوكلاء Paxis لدينا تستدعي backend مستضاف ذاتيًا بـ vLLM (اسم الشفرة Metis) عبر واجهة برمجية متوافقة مع OpenAI. اختيارات الضغط الكمّي تؤثر مباشرةً على تكلفة الخدمة لكل رمز لدينا.

الواقع التشغيلي هو أسطول أجهزة متنوّع. NVFP4 هو الأمثل على Blackwell (B200)، لكن هذا المسار مغلق على عُقد Hopper وAmpere. لذا نُوجّه الضغط الكمّي حسب طبقة الأجهزة: Blackwell يحصل على NVFP4 أو FP8 block-wise؛ Hopper يحصل على FP8 وW4A16؛ Ampere يحصل على AWQ/GPTQ W4A16. توحيد كل شيء تحت compressed-tensors يعني أن vLLM يكتشف الصيغة تلقائيًا، فيكاد كود الخدمة لا يتغيّر عبر الطبقات. الضبط الدقيق للمجال يُنجز بتكلفة منخفضة مع Unsloth، ثم يُدمج ويُعاد ضغطه إلى W4A16 أو FP8 للخدمة في الإنتاج -- هذا هو مسارنا المعياري.

الميزة واضحة: في بيئات on-premises والاستضافة الذاتية، لا تغادر البيانات الحاوية أبدًا، ويمكننا استخراج أقل تكلفة ممكنة للخدمة مهما كان جيل GPU الذي يمتلكه العميل. الضغط الكمّي ليس مجرّد ضغط -- إنه الرافعة المحورية لكفاءة التكلفة التي نقدّمها.

## الخلاصة

- معيار 4 بت في إنتاج vLLM هو W4A16 (AWQ/GPTQ) مع نواة Marlin.
- للحصول على سلسلة أدوات موحّدة، llm-compressor + compressed-tensors هو الأسلس (اكتشاف تلقائي).
- لنماذج MoE، FP8 block-wise هو الخيار الأول؛ تراجع إلى W4A16 إذا كانت الذاكرة ضيّقة.
- Unsloth متميّز في الضبط الدقيق وضغط Dynamic عالي الدقة، لكن المسار العملي للخدمة في إنتاج vLLM هو الدمج أولًا ثم إعادة الضغط إلى W4A16 أو FP8.

## للاستزادة

- وثائق الضغط الكمّي في vLLM: [docs.vllm.ai](https://docs.vllm.ai/en/latest/features/quantization/)
- llm-compressor: [github.com/vllm-project/llm-compressor](https://github.com/vllm-project/llm-compressor)
- Unsloth Dynamic 2.0: [unsloth.ai/blog/dynamic-v2](https://unsloth.ai/blog/dynamic-v2)
- ThakiCloud Paxis: [github.com/ThakiCloud/praxis](https://github.com/ThakiCloud/praxis)
