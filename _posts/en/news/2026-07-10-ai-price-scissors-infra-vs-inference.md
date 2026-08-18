---
title: "Racks Exploding Upward, Inference Collapsing Downward: Enterprises Stand in the Middle of the AI Scissors"
excerpt: "Two numbers released on the same day moved in opposite directions: a 21 million dollar AI rack and inference pricing that got 34 times cheaper. Here is a look at the handles enterprises need to grip in the middle of this widening scissors."
seo_title: "The AI Scissors: What a $21M Rack and 34x Cheaper Inference Say on the Same Day"
seo_description: "HBM4 rack price surges and DeepSeek-driven inference price collapse arrived on the same day. An analysis of the structure where infrastructure capital costs and model costs diverge in opposite directions, and the variables enterprises can actually control in between."
date: 2026-07-10
last_modified_at: 2026-07-10
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/news/ai-price-scissors-infra-vs-inference/"
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "robot"
tags:
  - ai-infrastructure
  - hbm4
  - inference-cost
  - sovereign-ai
  - gpu-cloud
  - model-routing
  - tco
categories:
  - news
audiobook: "https://drive.google.com/file/d/1lG7BE293M5awvsVzMlsLFrNO2au7J2lr/view"
audiobook_label: "▶ Listen: 5-minute briefing"
audiobook_note: "NotebookLM audio overview (AI-generated)"
---

![Concept diagram of the AI scissors showing an enterprise caught between soaring rack prices above and collapsing inference prices below]({{ '/assets/images/ai-price-scissors-infra-vs-inference-hero.webp' | relative_url }})

![Illustration of the core idea of Racks Exploding Upward, Inference Collapsing Downward: Enterprises Stand in the Middle of the AI Scissors](/assets/images/ai-price-scissors-infra-vs-inference-hero.webp)
*A visual metaphor for the article's key idea.*

## On the Same Day, Two Numbers Walked Away From Each Other

This morning's news carried two numbers moving in exactly opposite directions, side by side. One jumped upward. The average selling price of an Nvidia Rubin Ultra rack was reported at 21 million dollars, more than five times the 4 million dollars of the previous generation, Blackwell Ultra. The other sank to the floor. DeepSeek made a permanent 75 percent cut to its V4-Pro pricing, putting up a price tag that is 34 times cheaper than OpenAI and 29 times cheaper than Anthropic on an output-token basis.

On one side, the hardware that runs AI is soaring in price. On the other, the price of the answers that hardware produces is collapsing. What looks at first like a contradiction is actually one single event. The story running through today's digest is not about how smart any particular model has become, but about the fact that the upper and lower floors of the AI economy are pulling apart in opposite directions. Caught between the two diverging blades is, in the end, the enterprise that actually wants to use this technology.


## Upper Floor: The Hardware Keeps Getting More Expensive

This is not only a story about rack prices. The entire upper floor is raising its prices. Bernstein projected that HBM4 and LPDDR5X memory unit prices will climb to 53 dollars per gigabyte by 2027. Since more than half of a rack's cost is concentrated in GPUs and HBM, a rise in memory prices drags the entire price tag of a single server up with it. And yet Samsung Electronics, SK hynix, and Micron are not slowing their expansion pace, they are accelerating it. The calculation behind this is that a new fab takes at least three years to actually deliver volume, so a meaningful supply increase will not be possible until after 2028. Micron has committed to pouring 250 billion dollars into the United States through 2035, and SK hynix has moved to list American Depositary Shares in the United States at an IPO price of 149 dollars, a listing worth roughly 40 trillion won, the largest US listing ever by a foreign company. Today's investment is not a signal that prices are about to turn down, it is a bet placed in advance to secure a position for the AI-driven demand that will continue for years to come. That said, the same day's news also carried a report that the US Secretary of Commerce, at a New York fab event, publicly pressured Korean companies to expand production inside the United States. Deciding how to split capital and manpower between large domestic investments and demands for US investment has become a new homework assignment for the three memory makers.

Prices are not the only thing getting more expensive, complexity is too. Samsung Electronics said it is developing 2.xD packaging that combines HBM, logic, and silicon photonics into one. Getting past bandwidth bottlenecks requires precisely fusing different chips together, and the more that happens, the more the entire supply chain becomes hostage to foundry and advanced packaging capacity. It is a structure where difficulty and cost both climb together as performance rises. Nvidia says performance gains improve total cost of ownership, but with half of a rack's cost concentrated in GPUs and HBM, the actual speed of return on investment has emerged as the real variable that determines whether this cycle can sustain itself.

There is one more, heavier wall standing here: power. As Joongang Ilbo and Josea Ilbo both pointed out, the axis of AI competition has already shifted from securing semiconductors to operating data centers. The government has set a target of attracting over 550 trillion won in AI data center investment by 2029 and over 1,000 trillion won by 2035, and within that, the SK Group is taking on 81 percent of an 18.4 gigawatt target. The problem is that Seoul and Gyeonggi account for 78.7 percent of related power contracts, while the key sites there are already close to saturation. Grid interconnection and substation expansion permitting demand a longer lead time than simply buying GPUs. Liquid cooling such as immersion cooling can cut cooling power consumption by more than 90 percent, but a labor shortage is cited as another bottleneck, since it is not easy to retain the highly skilled operations staff needed to run such facilities around the clock for three to five years or more. That is why former Bitcoin mining companies, which already hold large-scale transmission rights, are being repriced as AI infrastructure suppliers. As firms like Core Scientific, IREN, and TeraWulf sign long-term power contracts with hyperscalers, the market has begun revaluing them not on mining profitability but on the power capacity they hold, measured in megawatts. The truly scarce resource on the upper floor now is not the chip, it is electricity.

## Lower Floor: The Price of an Answer Keeps Getting Cheaper

The same day, on the lower floor, exactly the opposite force was at work. DeepSeek's price cut was not a one-off promotion but a permanent policy, and its impact showed up in the numbers. On developer platforms like Vercel and OpenRouter, the traffic share of Chinese models jumped into double digits within a short period, and a real startup like Lindy switched its entire service from Anthropic to DeepSeek. Price-sensitive customers are already on the move.

Meta's moves make this trend even clearer. Meta, which had been building out its ecosystem by releasing Llama as open source, jumped into the paid API business for the first time with Muse Spark 1.1, and came out with a startling price roughly a quarter of what competitors charge. Zuckerberg said he was confident the pricing would be attractive. On top of that, Meta plans to start mass-producing its own AI chips from September to reduce its reliance on Nvidia, and is even moving to sell off idle compute externally in order to recoup infrastructure spending that could reach up to 145 billion dollars this year. Following Google's TPU and Amazon's Trainium, Meta's custom silicon now joins the picture, a phase in which Big Tech companies print their own chips and resell whatever compute is left over. The greater the cost pressure on the upper floor, the fiercer the price war on the lower floor to push that pressure onto someone else.

Domestic news shows that this scissors motion is not just a Silicon Valley story. Ha Jung-woo said Ulsan has a strong chance at industrial AI transformation given how much manufacturing data it has accumulated, ITCEN Core partnered with KB Kookmin Bank, and SK AX rolled out a full-stack transformation aimed at manufacturing sites. LG has begun developing a world model that understands the laws of physics, and Alipay placed its bet for the agent era on payment, trust, and openness. This means manufacturing, finance, and the public sector are each starting to push AI into real-world work. The problem is that the moment they adopt AI, they get caught right between the two blades just described. Infrastructure capital costs press down from above while model costs and sovereignty risk press up from below, both at once.

## Why Are These Two the Same Force

The two directions that looked like a contradiction actually branch from the same root. As AI demand explodes, the scarcity of semiconductors and power upstream pushes prices up. At the same time, competition among model providers trying to capture that demand collapses margins downstream. In other words, the rising capital costs above and the falling selling prices below are twins born from the same demand. That is why this structure resembles a pair of scissors. The two blades move in opposite directions, but they are bound to a single pivot.

The spot where enterprises stand is exactly in the middle of that scissors. If they build infrastructure themselves, they have to absorb the soaring costs of the upper floor. If they use models only through external APIs, they have to entrust themselves to someone else's pricing policy and to data sovereignty risk. On top of that, DeepSeek is a Chinese model and Meta has turned to a closed, paid model. In sectors like finance and the public sector, where network segregation and data sovereignty regulations are strict, it is difficult to simply take that cheap price and use it as is. The fact that a price is cheap and the fact that it can be used safely are entirely different problems.

## The Handles to Grip in the Middle of the Scissors

There is a common objection worth addressing here. Since DeepSeek is 34 times cheaper and Meta came out with a quarter of the price, why not just pick the cheapest external API and use it. Looking only at the price, that is a fair point. But the cheap price comes with strings attached. DeepSeek is a Chinese model, Meta has turned from open source to a closed, paid model, and the prices of both can rise again at any time depending on the provider's circumstances. Handing your entire cost structure over to someone else's pricing policy is not savings, it is a new form of dependency. Real savings are only complete once you bring that cheap price under your own control.

So what variables can enterprises actually control between these two diverging blades. The news has left hints. The core lesson from the AI data center article was that GPUs you have secured mean nothing if you cannot keep them running. In other words, the first handle for absorbing upper-floor costs is scheduling that eliminates idle time. The lesson from the DeepSeek case was routing, splitting work between cheap and expensive models according to task difficulty. The second handle is allocation, choosing the right model for each task. The lesson from Meta's move to paid pricing and the spread of Chinese models was that to absorb cheap pricing within data sovereignty, you need to serve open-weight models directly on your own infrastructure. The third handle is on-premises and sovereign deployment. And just as the AI security red-teaming guide published by the Ministry of Science and ICT and KISA designated prompt injection and agent permission abuse as standard threats, the fourth handle is policy and auditing that safely confines execution.

Paxis, the Agent-Native Cloud built by ThakiCloud, was designed to let organizations grip all four of these handles with one hand. CostRouter, which picks the right model for each task, splits workloads between DeepSeek-style low-cost models and high-performance models, turning the lower floor's price collapse back into cost savings. Isolated sandbox execution and multi-tenancy reduce idle time on secured GPUs, absorbing the upper floor's capital costs. A sovereign, on-premises Kubernetes foundation lets open-weight models be served directly within domestic regulation, capturing cheap pricing and data sovereignty at the same time. And governance that treats Skills, Tools, Policies, and Audit Logs as first-class resources and divides autonomy into levels from L0 to L3 embeds the policy gates and audit logs that the red-teaming guide demands, right into the product from the start.

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
<div class="d3-arch" data-arch-root id="scissorsinfravsinference-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 989, "height": 680, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "U", "x": 541, "y": 24, "w": 191, "h": 110, "title": ["Upper Floor · Rising", "Infrastructure Capital", "Costs", "HBM4 $53 per GB · $21M", "Rack · Power Bottleneck"]}, {"id": "D", "x": 288, "y": 32, "w": 198, "h": 94, "title": ["Lower Floor · Inference", "Price Collapse", "DeepSeek 34x Price Cut ·", "Meta Quarter Price"]}, {"id": "E", "x": 405, "y": 226, "w": 212, "h": 126, "title": ["Middle of the Scissors ·", "Enterprise", "Expensive Infrastructure ·", "Someone Else's Pricing", "Policy · Data Sovereignty", "Risk"]}, {"id": "H1", "x": 769, "y": 438, "w": 177, "h": 62, "title": ["Handle 1 · Scheduling", "Eliminate Idle GPUs"]}, {"id": "H2", "x": 551, "y": 430, "w": 163, "h": 78, "title": ["Handle 2 · Routing", "Model Allocation by", "Difficulty"]}, {"id": "H3", "x": 284, "y": 430, "w": 212, "h": 78, "title": ["Handle 3 · On-prem ·", "Sovereign", "Direct Open-Weight Serving"]}, {"id": "H4", "x": 24, "y": 438, "w": 205, "h": 62, "title": ["Handle 4 · Policy · Audit", "Safely Confine Execution"]}, {"id": "P1", "x": 759, "y": 586, "w": 198, "h": 62, "title": ["Paxis Isolated Sandbox ·", "Multi-tenancy"]}, {"id": "P2", "x": 562, "y": 594, "w": 142, "h": 46, "title": "Paxis CostRouter"}, {"id": "P3", "x": 284, "y": 594, "w": 212, "h": 46, "title": "Paxis Sovereign Kubernetes"}, {"id": "P4", "x": 35, "y": 594, "w": 184, "h": 46, "title": "Paxis Governance L0~L3"}], "edges": [{"src": "U", "dst": "E", "kind": "data", "label": "Twins Split From the Same Demand", "curve": [[636, 134], [636, 180], [636, 180], [583, 226]], "off": "50%"}, {"src": "D", "dst": "E", "kind": "data", "label": "Twins Split From the Same Demand", "curve": [[387, 126], [387, 180], [387, 180], [439, 226]], "off": "50%"}, {"src": "E", "dst": "H1", "kind": "data", "curve": [[617, 320], [858, 391], [858, 391], [858, 438]]}, {"src": "E", "dst": "H2", "kind": "data", "curve": [[586, 352], [633, 391], [633, 391], [633, 430]]}, {"src": "E", "dst": "H3", "kind": "data", "curve": [[436, 352], [390, 391], [390, 391], [390, 430]]}, {"src": "E", "dst": "H4", "kind": "data", "curve": [[405, 317], [127, 391], [127, 391], [127, 438]]}, {"src": "H1", "dst": "P1", "kind": "data", "line": [858, 500, 858, 586]}, {"src": "H2", "dst": "P2", "kind": "data", "line": [633, 508, 633, 594]}, {"src": "H3", "dst": "P3", "kind": "data", "line": [390, 508, 390, 594]}, {"src": "H4", "dst": "P4", "kind": "data", "line": [127, 500, 127, 594]}]});
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
      const container = document.getElementById('scissorsinfravsinference-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'scissorsinfravsinference-1';
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

## The Wider the Scissors Open, the More the Handles Matter

Today's two numbers are likely to keep drifting further apart. Memory supply will stay tight through 2028, and the power bottleneck requires years of permitting, so the upper floor will not come down easily. Conversely, the wave of custom chips and ultra-cheap models keeps pulling the lower floor down. The more this happens, the more the outcome is decided not by the two blades themselves, but by the handle gripping the space between them. That is why, when reading the two numbers of rack price and inference price, you also have to read the scheduling, routing, sovereignty, and safety that sit in between. Today's news did not ask which model won. Instead, it asked about the cost of running that model and the way that cost is managed. To stand steady in the middle of the scissors, you first have to check where your handles are.


## References

- [Nvidia Rubin Ultra Rack Expected to Sell for $21 Million](https://tech.ifeng.com/c/8uco339RORc) · Ifeng
- [Bernstein Projects Nvidia Vera Rubin Rack at $9.1 Million as HBM4 Price Surge Squeezes Costs](https://www.weeklypost.kr/news/articleView.html?idxno=11422) · Weekly Post
- ["40 Trillion Won Jackpot": SK hynix Surpasses Even Alibaba in a Record-Breaking Listing](https://www.hankyung.com/article/2026071072846) · Hankyung
- [Micron Expands US Semiconductor Investment to $250 Billion, Breaks Ground on New York Fab](https://www.thelec.net/news/articleView.html?idxno=12157) · TheElec
- [Samsung Electronics: "Developing 2.xD Packaging That Combines HBM, Logic, and Silicon Photonics"](http://inews24.com/view/1984212) · iNews24
- [DeepSeek Makes Its 75% Price Cut Permanent as the AI Price War Intensifies](https://thenextweb.com/news/deepseek-v4-pro-75-percent-price-cut-permanent) · TheNextWeb
- [Meta Prices Muse Spark 1.1 API at $1.25/$4.25 per Million Tokens](https://aiweekly.co/alerts/meta-prices-muse-spark-11-api-at-125425-per-m-tokens) · AI Weekly
- [Meta's New AI Chips Will Begin Production in September](https://techcrunch.com/2026/07/09/metas-new-ai-chips-will-begin-production-in-september/) · TechCrunch
- [Startup Lindy Ditched Claude Entirely for DeepSeek, Saving Millions of Dollars](https://the-decoder.com/ai-startup-lindy-ditched-claude-entirely-for-deepseek-saving-millions-as-cost-pressure-mounts-on-anthropic/) · The Decoder
- [Ministry of Science and ICT, KISA Publish "AI Security Red-Teaming Guide"](https://www.digitaltoday.co.kr/news/articleView.html?idxno=682799) · Digital Today
