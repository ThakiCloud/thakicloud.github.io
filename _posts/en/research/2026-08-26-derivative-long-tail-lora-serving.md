---
title: "One Machine, Swap the Capsule: A Cheaper Way to Serve Community Model Variants"
seo_title: "Cost Frontier for Community LoRA Serving: Shared Server vs. Dedicated Server - ThakiCloud"
seo_description: "A popular open model quickly grows dozens or hundreds of community variants. This paper computes when pooling those variants onto one shared server beats giving each one its own dedicated server. At 32 variants the gap is about 30x, at 512 it is about 385x, and a dedicated server only wins when one variant takes more than a third of all requests."
excerpt: "Release one open model and community variants follow within days. Give each variant its own server and you buy the expensive body over and over. Pool them on one server and you buy the body once, then just swap a small piece. This paper works out exactly where that line falls."
date: 2026-08-26
last_modified_at: 2026-08-31
tags:
  - lora-adapter-serving
  - derivative-model-ecosystem
  - long-tail-traffic
  - adapter-multiplexing
  - serving-economics
  - community-fine-tunes
  - zipf-traffic-concentration
  - h200-gpu
  - multi-adapter-inference
  - slora
  - inference-cost
categories:
  - research
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/en/research/derivative-long-tail-lora-serving/"
---
Release a popular open model, and slightly tweaked community versions follow within days, often dozens of them. Pooling those versions onto one shared server costs far less than giving each version its own server. If you run a model service, or decide how many servers to buy, this post hands you that math directly.

This post introduces a paper our research team wrote autonomously. It is called "The Derivative Long Tail," and it draws the line between pooling servers and splitting them, using real numbers.

## In plain terms

Picture a coffee machine. The machine itself is big and expensive. A capsule is small and cheap. Nobody buys a whole new machine every time a new flavor comes out. You just make a new capsule and drop it in the drawer.

Serving an open model works the same way. The big, expensive body is the base model. The capsules are the small pieces the community builds on top of it, called LoRA adapters. One piece is worth less than half a percent of the body's size.

**A dedicated server rebuilds the whole body for every single piece.** A hundred pieces means a hundred full bodies. **A shared server keeps one body and stacks the pieces in a drawer instead.** When an order comes in, it just pulls out that one piece.

The drawer has a limit, though. A piece that does not fit has to make a trip to the storage room, and that trip is the extra cost the shared server pays. When most orders stick to a few favorite flavors, the drawer opens and closes less often, so that extra cost shrinks too.

## What we did

The paper lays every assumption out in one table, then computes both server setups against it. The base model is a strong open model, about 54 gigabytes in size. One piece is worth less than half a percent of that. That tiny size is exactly what makes the paper's question interesting.

A dedicated server reloads the full body for every piece. A shared server loads the body once and stacks pieces on top. The graphics card behind the shared server is H200-class, with 141 gigabytes of on-board memory. That space splits three ways.

- The body (base model): 54 gigabytes
- Short-term memory for the conversation: 27 gigabytes
- The drawer for pieces: 60 gigabytes

Because one piece costs half a percent of the body, that drawer holds about 220 pieces. In plain terms, the drawer looks roomy, but once the catalog passes 220 pieces, it runs out of room.

The paper also varied how concentrated customer orders were, testing low, medium, and high concentration. It swept the number of pieces from 2 up to 512.

## What came out

### Buying the body over and over is what drives the cost

The more pieces you have, the more times a dedicated server buys the full body. A shared server buys the body exactly once. The total cost gap ends up tracking roughly the number of pieces.

- 32 pieces: about 30x cheaper
- 256 pieces: about 230x cheaper
- 512 pieces, orders piled on a few flavors: about 480x cheaper

![Fleet advantage versus adapter count](/assets/images/posts/research/derivative-long-tail-lora-serving/fig1.webp)
*Fleet advantage ratio R(K, s) versus adapter count K for Zipf concentrations s = 0.5, 1, and 1.5, compared against the overhead-free diagonal R = K. R tracks K across the band, and the flat-traffic curve bends below K at K = 512 once the out-of-pool host-link penalty overtakes it. (Analytical model output, not a measurement.)*

There is one exception. When orders spread out evenly instead of piling up, going from 256 to 512 pieces overflows the 220-piece drawer, and the advantage actually shrinks slightly. Even at its worst, though, the shared server still comes out 190 times cheaper. In plain terms, adding more pieces never flips the advantage to the dedicated server's side.

### Overhead jumps once the drawer fills up

The shared server's extra cost comes from two sources: pulling a piece out of the drawer for each order, and the rare trip to the storage room when a piece does not fit. Within the 220-piece limit, the two split like this.

- Pulling a piece from the drawer: levels off around 10 percent
- A trip to the storage room: exactly zero

![Multiplex overhead decomposition versus adapter count (s = 1)](/assets/images/posts/research/derivative-long-tail-lora-serving/fig2.webp)
*Decomposition of the multiplexed per-token overhead δ(K, s = 1) into percentage points. The in-batch adapter restream term climbs to about 11 percent and flattens at the 223-adapter pool-fit boundary, while the out-of-pool host-link contention term stays exactly zero up to that boundary and jumps by +22.0 points at K = 512. (Analytical model output, not a measurement.)*

Past 220 pieces, the picture changes. At 512 pieces, the storage-room trip suddenly adds more than 22 percentage points, and the total extra cost climbs to about 34 percent. In plain terms, keeping the drawer from overflowing is the real job of running a shared server well.

### The one case where a dedicated server wins

Priced order by order, the picture can flip. If one piece pulls in a very large share of all orders, a dedicated server built just for that piece can be cheaper than the shared one. That crossover line drops as the catalog grows.

- At 2 pieces, the crossover line: almost all of the orders
- At 512 pieces, the crossover line: a little over a third of the orders

Not one piece in the traffic ranges the paper surveyed ever crossed that line. Even the single most popular piece falls short of it. In plain terms, within the community-variant traffic this paper looked at, a dedicated server never wins on a per-order basis.

### The catalog does not sit still

The list of variants keeps growing, because fine-tuning teams keep making new ones every week. The paper assumed 4 new pieces arrive each week and tracked what happens over time. Starting from 32 pieces, the catalog crosses the 220-piece drawer limit in under a year, and levels off at 512 after about two years.

![Catalog growth and fleet-advantage drift](/assets/images/posts/research/derivative-long-tail-lora-serving/fig3.webp)
*Under a constant arrival rate of 4 derivatives per week (K0 = 32, Kss = 512), the catalog crosses the pool-fit boundary around week 48 and saturates at 512 around week 120 (2.3 years), while the s = 1 fleet advantage drifts from 30x to about 385x over the same span. (Analytical model output, not a measurement.)*

Over that same stretch, the shared server's advantage grows from about 30x to about 385x. In plain terms, one new piece costs the shared server a drawer slot, and costs the dedicated fleet a whole extra body.

## What to change

The paper compresses all of this into one operating rule. With just one piece, either setup is fine. Between 2 and 220 pieces, the answer is always a shared server. Past 220, a shared server needs one more move: a bigger drawer, or a tighter way of stacking pieces.

Put a price on it and the gap gets real. Take 32 pieces, 100 million requests a month, and a graphics card renting for 5 dollars an hour. A shared server needs one graphics card, about 3,900 dollars a month. A dedicated setup needs 32 graphics cards, about 116,000 dollars a month. In plain terms, an operator with a single graphics card can match a 32-card team on the same catalog at a thirtieth of the price.

Shrinking the body further, say by compressing it more aggressively, ties into this same math. A smaller body makes each piece relatively heavier, so shrinking the body and the drawer limit move together, not apart.

For ThakiCloud, this is a direct rule for how many graphics cards Metis, our inference service, needs to keep up with community-variant demand. Maxis, the training and evaluation pipeline that produces those variants, feeds directly into that same demand. Every open model that ships now grows this kind of variant ecosystem around it, which means serving cost has to be planned per variant from day one.

## What not to trust

Every number in this paper comes from a calculation, not a measurement. The paper lays out its own follow-up: run real engines on real graphics cards across a range of order concentrations, measure the true numbers, then fit concentration levels from real production logs and check the frontier against them. Read the numbers here as predictions, not confirmed results.

The calculation also holds up well on its own terms. Switching order concentration between low, medium, and high barely moved the total cost gap within the drawer limit. A few things stayed fixed as assumptions, though: every piece is the same size, and the whole catalog sits on one base model. The batch size was also fixed at 32 orders at a time; a bigger batch would likely tilt the math even further toward the shared server.

The cost math leaves out isolation, security, and failure protection. A dedicated server keeps one bad piece from causing trouble for other customers. This calculation says a dedicated server always loses on a per-order basis, but where isolation genuinely matters, a dedicated server can still be the right call regardless of cost. The paper marks that exception outside its own math.

---

The paper's full page is available at the link below: [The Derivative Long Tail: Multiplex-vs-Dedicated LoRA Serving on H200](https://thakicloud.com/tech-blog/en/research/derivative-long-tail-lora-serving/)

*Numbers in the body are rounded for readability; exact values stay in each figure caption. Every number in this paper comes from an assumption table, not a measurement.*
