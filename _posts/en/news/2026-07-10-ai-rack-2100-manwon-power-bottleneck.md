---
title: "21 Million Dollars for One Rack: When AI's Bill Arrived, the Bottleneck Moved to Power"
excerpt: "HBM4 has pushed the price of a single server rack to 21 million dollars, and SK hynix raised 40 trillion won in a single day. Now that capital and power have become the real bottleneck, the contest is moving down to the software layer that turns expensive compute into provable work."
seo_title: "In the Age of the 21 Million Dollar AI Rack, the Bottleneck Is Power and Proof, Not GPUs"
seo_description: "The thread running through the July 10, 2026 news is capital and power. Reading the 21 million dollar HBM4 rack, SK hynix's 40 trillion won ADR, and the 5,241 trillion won AIDC forecast, here is where ThakiCloud's Paxis opens a window of differentiation."
date: 2026-07-10
last_modified_at: 2026-07-10
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/news/ai-rack-2100-manwon-power-bottleneck/"
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "robot"
tags:
  - ai-infrastructure
  - hbm4
  - data-center-power
  - sovereign-ai
  - model-economics
  - agent-native-cloud
  - cost-routing
categories:
  - news
published: false
---

![Concept diagram of the power bottleneck narrowing into a server rack, with the software layer above it]({{ '/assets/images/ai-rack-2100-manwon-power-bottleneck-hero.webp' | relative_url }})

Picture a single invoice. The line item is one server rack, and the price is 21 million dollars, about 31.6 billion won in our currency. That is the expected unit price for Nvidia's next generation Rubin Ultra rack, reported today by Global Economic. Just one generation earlier, a Blackwell rack cost 3 to 4 million dollars, so this is a jump of five to seven times. The largest item on this bill is not the compute chip but memory. The HBM4e loaded into a single rack alone comes to 82,944 gigabytes, and at 18.49 dollars per gigabyte, the memory component alone tops 1.53 million dollars. An amount that used to approach the price of an entire previous generation server rack is now the price of a single part. The story running through today's digest starts here. The unit of AI competition has shifted from performance benchmarks to money and power.

## The Unit of Money Has Changed

Even the scale of the numbers feels unfamiliar now. SK hynix has fixed the offering price of its American Depositary Receipts for its Nasdaq listing at 149 dollars per share. At a total of 26.5 billion dollars, about 40 trillion won, that surpasses Alibaba's 25 billion dollars from 2014 and stands as the largest US listing by a foreign company on record. A company whose market capitalization has already crossed 1 trillion dollars is now raising dollars directly to pour into extreme ultraviolet equipment at its Yongin and Cheongju fabs and into overseas advanced packaging. Micron has enlarged its plan again, saying it will invest 250 billion dollars, about 376 trillion won, in the United States alone by 2035. Meta has offered a capital expenditure guidance of 115 to 135 billion dollars for this year alone.

Look at where this money is flowing and the direction is unmistakable. All of it heads toward memory expansion, data center construction, and securing semiconductors. Investment banks like Bank of America and Morgan Stanley read this price surge as both the basis for higher valuations at Korean memory companies and, at the same time, a downside risk that could squeeze Big Tech capital expenditure. Rising prices are an opportunity for the sellers, but a burden for whoever has to pay that price and still run a service. Once the structure where memory fills half the rack price becomes fixed, a GPU cloud operator's margin direction can swing on nothing more than when it chooses to adopt the next generation rack.

It is also notable that the competitive front does not stop at a single chip. Samsung Electronics said it is developing 2.xD heterogeneous integration that packages HBM, logic, and silicon photonics together, and it has also stepped into the on device inference market with Gaia, its accelerator for AI PCs. Gaia is built around processing in memory to cut data movement and raise power efficiency. That means the race to make computation faster has effectively become the same race as saving power. This trend leaves GPU cloud operators with homework of their own. They now have to prepare multi vendor hardware that spans NPUs and processing in memory, not just Nvidia alone.

## The Bottleneck Moved from GPUs to Power

A more interesting signal is where the bottleneck has moved to. The story reported by Joseilbo is symbolic. Companies that used to mine coins are transforming into AI infrastructure companies, and it turns out their real asset was never the mining rigs, it was the power. According to a CoinShares report, the share of AI and high performance computing in listed mining companies' revenue is expected to rise from around 30 percent now to as much as 70 percent by year end, and related contracts signed over the past year alone already exceed 70 billion dollars. TeraWulf signed a 20 year long term lease with Anthropic to expand to 401 megawatts by early 2028, and IREN added an Oklahoma site to grow its power pipeline to 4.5 gigawatts. Whoever secured cheap power contracts and substation facilities first has become the winner.

Korea is no different. Citing a Nomura forecast, JoongAng Ilbo reported that global AI data center investment will grow from 723 trillion won in 2025 to 5,241 trillion won in 2030, an average annual growth rate of 48 percent. On the 29th of last month, the government announced three mega projects, saying it would put 550 trillion won into 8.4 gigawatts of data centers in the first stage and exceed a total of 18.4 gigawatts and a cumulative 1,000 trillion won by 2035. SK is teaming up with AWS to open 5 gigawatts by 2029 and grow that to 15 gigawatts by 2035, while KT has declared it will spend 5 trillion won over five years to build demand based facilities in 25 locations nationwide. News that SK Telecom is staking its own bet on a 5 gigawatt class data center sits in the same context. The bottlenecks they all share converge on one thing, power, cooling, and land. In a reality where delays in grid interconnection with KEPCO and substation permitting are cited as the biggest constraint on expansion, the lesson from the United States, that whoever secures power first gains a structural advantage, carries over directly to Korea as well.

As the scale competition reorganizes around large conglomerate consortiums, it is not that smaller operators are left with no path at all. LG Uplus is building a facility in Paju that will supply 200 megawatts, and LG CNS is preparing a modular small scale data center that packs 576 GPUs into a single container. There is also an approach like KT's edge strategy, attaching facilities close to industrial sites to cut latency. For an operator that cannot compete head on for hyperscale land, the more realistic choice is to raise density in niches like modular builds, edge deployment, and diversified power contracts.

## But Is That Money Actually Coming Back as Results?

Asking the question from the opposite direction here is what gives us an honest picture. Is this record breaking capital actually being recovered as results? Today's news actually sends the opposite signal. Naver is expected to post its best ever second quarter with revenue of 3.3562 trillion won and operating profit of 570.1 billion won, yet its share price has fallen from a new high of 304,000 won on June 1 to 184,400 won on July 9, in just over a month. Kakao's cumulative GPT in Kakao users have reached 11 million, but brokerages uniformly lowered their target prices, citing insufficient evidence of monetization. The reason these companies cannot smile even after record breaking results is simple. The market is no longer asking about investment, it is asking about recovery.

Big Tech's response is even more blunt. Meta has abandoned its open source line and released its first paid model, Muse Spark 1.1, priced at 4.25 dollars per million output tokens, about 25 percent of the top tier models from OpenAI and Anthropic. Zuckerberg is even weighing a computing rental business that lends out data centers and GPUs externally, and has set up a separate internal organization called Meta Compute for it. Having signed a computing rental deal worth up to 21 billion dollars with CoreWeave back in April, Meta is now saying it wants to become a computing supplier like CoreWeave itself. It is a declaration that, having poured in hundreds of billions of dollars, it now intends to make money from that spend. On the other side, DeepSeek is absorbing a substantial share of developer traffic by leading with a price of 0.87 dollars per million output tokens, 34 times cheaper than OpenAI. The figure that Chinese open source models' share once spiked to 46 percent in OpenRouter statistics shows that this trend is not a matter of taste but a matter of cost. This is the backdrop for the assessment that the axis of competition has shifted from who builds the better model to who actually makes money.

Naver's case reveals this time lag in numbers. Its AI Factory project with Nvidia is meant to grow from 55 megawatts through 200 megawatts by 2028 to an eventual 1 gigawatt, aiming for 20 trillion won in annual revenue over the long term, yet depreciation expenses from GPU investment have squeezed its short term operating margin. That means the structure of building infrastructure first and recovering later is not an exception even at a major platform. This is exactly why investors demand evidence in the form of contracts and revenue, not just usage.

## The Layer That Turns Expensive Compute into Provable Work

To sum up, capital is pouring into semiconductors and power, and the companies running services on top of it are under pressure to prove recovery. If that is the case, the place where real value gets made is not underneath the hardware but above it, in the software layer that turns every expensive compute cycle into results without waste. This is exactly why ThakiCloud designed Paxis as an agent native cloud.

CostRouter, which selects a model per task, turns the options opened up by DeepSeek's and Meta's low cost APIs directly into a weapon. Route token sensitive workloads like email classification or document summarization to a cheap model, and deploy an expensive model only for the segments that need sophisticated reasoning, and you get the same result at a lower cost. In an era when the price of a single rack is exploding, the path to protecting cost is not cheaper hardware, it is the software discipline of routing every call to the right sized model.

Policy gates and audit logs are also an answer to the proof pressure that Naver and Kakao are experiencing. Paxis treats Skills, Tools, Policies, and Audit Logs as first class resources, and manages an agent's degree of autonomy across levels from L0 to L3. When a record is left of what authority an agent used to do what work, you can speak about performance based on the work actually done rather than on usage alone. When policy divides which tasks require human approval and which can be fully delegated, you can hand over evidence instead of raw numbers when faced with the question of recovery. Alipay building a trust layer by accumulating 300 million agent payments through delegated authentication and transaction tracing follows the same grammar.

The question of sovereignty overlaps here as well. One reporter's notebook pointed out that at an event proclaiming sovereign AI, the word that actually stood out most clearly was Nvidia. The government says it will use 5 trillion won in excess tax revenue to secure 10,000 Nvidia Vera Rubin GPUs and raise the share of domestic semiconductors to half by 2030, but the standard for whether sovereignty covers only data and models, or extends to computing and semiconductors as well, is still blurry. This gap becomes a window of positioning for an operator that has actually run a sovereign stack, on premises Kubernetes where data never leaves, in practice. While large operators claim to be sovereign even as they become deeply embedded in the Nvidia ecosystem, whoever builds up real references in computing localization and data sovereignty can get ahead before the standard is finalized.

Security is the last link in this chain of trust. The AI security red teaming guide published this week by the Ministry of Science and ICT and KISA defines eight major threats, including prompt injection and agent hijacking, and divides risk into five levels. Hijacking, where an agent is swayed by malicious instructions hidden in an external document or web page, can be met head on with a structure that confines every execution inside an isolated sandbox. At a moment when red teaming track records are hardening into a requirement in finance and public procurement, an architecture that quantitatively proves its level of isolation is both a regulatory response and, in itself, a competitive edge in procurement.

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
<div class="d3-arch" data-arch-root id="100manwonpowerbottleneck-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1034, "height": 806, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "C", "x": 402, "y": 24, "w": 205, "h": 94, "title": ["Capital surge", "Rack $21 million · SK", "hynix 40 trillion won ADR", "· Micron $250 billion"]}, {"id": "B", "x": 409, "y": 196, "w": 191, "h": 78, "title": ["Bottleneck shift · from", "GPUs to power", "Power · Cooling · Land"]}, {"id": "R", "x": 398, "y": 352, "w": 212, "h": 78, "title": ["Recovery pressure", "Naver and Kakao · stock", "down despite record profit"]}, {"id": "S", "x": 398, "y": 508, "w": 212, "h": 110, "title": ["Software layer where value", "is made", "Turning one expensive", "compute cycle into", "provable work"]}, {"id": "P1", "x": 790, "y": 704, "w": 212, "h": 62, "title": ["CostRouter · routing every", "call to the right model"]}, {"id": "P2", "x": 523, "y": 704, "w": 212, "h": 62, "title": ["Policy and audit logs ·", "proof by results not usage"]}, {"id": "P3", "x": 291, "y": 696, "w": 177, "h": 78, "title": ["Sovereign on premises", "Kubernetes · data", "sovereignty"]}, {"id": "P4", "x": 24, "y": 696, "w": 212, "h": 78, "title": ["Isolated sandbox · defense", "against hijacking and red", "teaming"]}], "edges": [{"src": "C", "dst": "B", "kind": "data", "line": [504, 118, 504, 196]}, {"src": "B", "dst": "R", "kind": "data", "line": [504, 274, 504, 352]}, {"src": "R", "dst": "S", "kind": "data", "line": [504, 430, 504, 508]}, {"src": "S", "dst": "P1", "kind": "data", "curve": [[610, 588], [896, 657], [896, 657], [896, 704]]}, {"src": "S", "dst": "P2", "kind": "data", "curve": [[577, 618], [629, 657], [629, 657], [629, 704]]}, {"src": "S", "dst": "P3", "kind": "data", "curve": [[431, 618], [380, 657], [380, 657], [380, 696]]}, {"src": "S", "dst": "P4", "kind": "data", "curve": [[398, 590], [130, 657], [130, 657], [130, 696]]}]});
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
      const container = document.getElementById('100manwonpowerbottleneck-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '100manwonpowerbottleneck-1';
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

Let us return to the invoice we started with. In an era when a single rack carries a price tag of 21 million dollars, the most expensive waste is running the wrong model on the wrong task on top of that rack and then being unable to explain what was actually done. Capital and power have already become the battleground. The next battleground is the layer above them that turns every cycle into provable work, and that is exactly the spot ThakiCloud is aiming for.

## References

- [Nvidia's Rubin Ultra rack expected to sell for 21 million dollars](https://tech.ifeng.com/c/8uco339RORc) · ifeng
- [SK hynix's "40 trillion won jackpot" surpasses even Alibaba, an all time record](https://www.hankyung.com/article/2026071072846) · Korea Economic Daily
- [Micron expands US semiconductor investment to 250 billion dollars, breaks ground on New York fab](https://www.thelec.net/news/articleView.html?idxno=12157) · TheLec
- [Meta projects 2026 capex at 115 to 135 billion dollars as data center spending expands](https://www.datacenterdynamics.com/en/news/meta-estimates-2026-capex-to-be-between-115-135bn/) · Data Center Dynamics
- [AI data centers draw 1,000 trillion won in regional investment, the remaining question is demand](https://www.mt.co.kr/tech/2026/07/01/2026070110330467488) · Money Today
- [Deputy Prime Minister for Science and ICT: "550 trillion won into AIDC by 2029, over 1,000 trillion won by 2035"](https://www.fnnews.com/news/202606291445337094) · Financial News
- [Bitcoin miners are becoming AI companies and selling their BTC to fund the transition](https://www.coindesk.com/markets/2026/03/27/bitcoin-miners-are-becoming-ai-companies-and-selling-their-btc-to-fund-the-transition) · CoinDesk
- [TeraWulf announces Anthropic lease at Justified Data Campus](https://investors.terawulf.com/news-events/press-releases/detail/142/terawulf-announces-anthropic-lease-at-justified-data-campus-and-sale-of-majority-interest-in-abernathy-joint-venture-to-fluidstack) · TeraWulf
- [Ads and commerce carried Naver and Kakao's second quarter results again](https://zdnet.co.kr/view/?no=20260708165303) · ZDNet Korea
- [Government to invest 5 trillion won in excess tax revenue to develop "sovereign AI"](https://www.hankyung.com/article/2026070228011) · Korea Economic Daily
