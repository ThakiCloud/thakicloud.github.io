---
title: "Skill Order Is Money Too: How the Manifest Order of Unattended Agents Sets Prefix Cache Reuse and the Break-Even Point"
seo_title: "The Manifest Order paper analysis - prefix cache economics of the fixed prefix (system prompt + tool schema + skill manifest) that an unattended agent loop resends every turn. Derives steady-state hit rates for the three arms F (global frequency first) / L (per-loop most-recently-used) / S (shuffled) on a serving instance shared by K loops, under exact-match prefix semantics and exponential eviction (τ=C/ρ). The shared-gap identity, the shared lifetime Kτ, the three break-even points (onset·peak·decay), the resend coefficient q(Δ), and the stability-first placement theorem. On H200/H100 with 14B/32B reference configurations, 12-89% token-billing savings; at Δ=900s with K=16, 14B/H200 46.3% vs 32B/H100 4.1%; trace-replay validation protocol - ThakiCloud"
seo_description: "An unattended agent loop resends the same fixed prefix every turn, and prefix cache reuse decides the cost of that resend. Manifest ordering is a deployment-time lever that needs no training and no engine change, yet its price and break-even point have not been treated as an economics problem. This paper derives the prefix cache economics of a serving instance shared by K loops in closed form and predicts 12-89% token-billing savings on H200/H100 reference configurations, with 14B/H200 at 46.3% versus 32B/H100 at 4.1%. Every number is a model prediction under the stated assumptions, and quality neutrality is an assumption to be measured."
excerpt: "An unattended agent loop resends the system prompt, the tool schema, and the skill manifest unchanged every turn. Prefix cache reuse decides the real cost of that resend, and the manifest order is a lever you can pull with no training and no engine change. This paper computes that price and its break-even point in closed form. On the H200+14B reference configuration, the prediction is 12-89% savings, with 14B/H200 reaching 46.3% and 32B/H100 staying at 4.1%. Every number is a model prediction under the stated assumptions."
date: 2026-09-20
tags:
  - prefix-caching
  - kv-cache-reuse
  - skill-manifest-ordering
  - tool-schema-ordering
  - agentic-workload-structure
  - inference-cost-optimization
  - h200-serving
  - unattended-automation
  - agent-harness
categories:
  - research
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/en/research/agentic-prefix-reuse-manifest-ordering/"
audiobook: "https://drive.google.com/file/d/1Nrj712P53uY8ltgdtUlE0AuUgszAuYyJ/view"
audiobook_label: "▶ Listen: 5-minute briefing"
audiobook_note: "NotebookLM audio overview (AI-generated)"
---

The order of the skill manifest is money, too. If you run unattended agents, or you answer for their serving bill, the ordering this post covers lands straight on the invoice. The paper computes in closed form the resend cost of the fixed header that gets sent again every turn, why the money an ordering can save can grow all the way to 80 percent, and where the break-even point sits. The lever needs neither training nor an engine change.

The fixed header here has three pieces: the system prompt, the tool schema, and the skill manifest. The three pieces barely change while the loop runs, and the serving engine reuses what stays in the cache instead of recomputing from the start every turn.

That cache is a prefix cache. Reuse holds only for the identical prefix starting from token 0. That is why ordering is money.

This post answers three questions. How much does a fixed manifest order save compared with a per-loop most-recently-used order or an order shuffled every turn? Where does the break-even point land, as a function of manifest size, turn interval, and cache contention? And how large is the savings on the H200 reference configuration?

![Illustration of the core idea of Skill Order Is Money Too: How the Manifest Order of Unattended Agents Sets Prefix Cache Reuse and the Break-Even Point](/assets/images/agentic-prefix-reuse-manifest-ordering-hero.webp)
*A visual metaphor for the article's key idea.*

## In Plain Terms

Picture the shelf of a shared library, and the structure of the paper fits it exactly. Twelve students are working the same assignment from the same textbook. After a student finishes one step, they leave, and the time until they come back is the turn interval. If the textbook is still on the shelf when they return, they just keep reading where they left off. If it has been pushed off the shelf, it has to be pulled fresh from the storage room.

The shelf has a fixed capacity, and as new books keep arriving, older ones get pushed off. And when twelve people use the same book at once, that book holds its place on the shelf much longer than a book used by a single person. What the paper measures is the price of how long that sharing on the shelf lasts.

The manifest order corresponds to the chapter order of the textbook. If every student uses the same chapter order, the front of the book is identical for everyone and the shelf sharing holds for a long time. If each student reorders to start from the chapter they last read, even the same book ends up opened at a different spot for each person, and the sharing breaks. Shuffle the chapter order every turn and you have to start again from the very first chapter.

<!-- nlm-visual -->
![Key-concept summary infographic 1](/assets/images/posts/news/agentic-prefix-reuse-manifest-ordering/en/nlm-infographic-1.webp)
*Infographic generated by NotebookLM from the sources.*

## The Price of the Prefix Resent Every Turn

An unattended agent loop is a structure that carries work across many turns without a human in between. The cost profile of this structure is simple. Every turn resends the entire input, and the front of it is always the same fixed prefix. The task context behind it grows turn after turn as tool results and temporary state pile up.

A serving engine with a prefix cache can serve this front part from the cache instead of recomputing it. Two conditions must hold at the same time. First, the ordering must keep the shared prefix intact. Reuse holds only for the identical prefix from token 0, so the manifest order determines how many tokens two loops actually share. Second, the cache must keep the shared blocks alive between turns.

In an unattended loop, the time between turns is mostly tool execution and external processing. With contention, the shared blocks can be evicted before the next turn arrives. Both conditions are set outside the engine, at deployment time.

The content of the manifest is decided by the skill router. Only the order in which in-scope skills are listed is decided by the operator. Changing the order touches neither the model nor the engine. It is a lever you can pull at deployment time, without training.

But this order has not yet been treated as an economics problem. How much a fixed order saves compared with a per-loop most-recently-used order or an order shuffled every turn is unknown. Where the break-even point lands for a given manifest size, turn interval, and level of cache contention is also unknown. When a fleet is built on H200-class instances, the operator is the one who has to answer these questions. The KV cache may be large enough to make between-turn sharing possible, but it does not guarantee it.

Earlier work priced other cost layers of the same fleet. The allocation of thinking tokens between the router and execution, quantization of the embedding model for retrieval, and multi-skill routing over a 2,275-skill registry. None of them priced the fixed prefix that every loop resends every turn. No matter how optimized the router and the execution are, these tokens are resent every turn. This paper prices that layer.

![Manifest ordering as a deployment-time, quality-neutral cost lever](/assets/images/posts/research/agentic-prefix-reuse-manifest-ordering/fig-lever-chain.webp)
*The fixed prefix, that is, the system prompt, the tool schema, and the skill manifest, is resent every turn. That order sets prefix cache reuse, and with it the resend cost. A structural concept diagram; no data is shown.*

## The Price, Derived in Closed Form

The paper derives the price of this ordering in closed form. One serving instance runs K loops at once, and each turn's input is the fixed prefix plus a task context that grows as the turns go on. Reuse holds only for the identical prefix from token 0. Cache eviction is modeled as an exponential: the longer it has been since a block was last used, the more its survival probability decays exponentially, and the time scale is τ, the KV cache capacity divided by the rate of incoming tokens.

On top of that sits the shared-access assumption. If q loops use the same block together, the block is touched every 1/q of the interval, and the eviction rate slows down by that much. A prefix used by K loops stays on the shelf that much longer.

Three orderings are compared. F is the global frequency-first order. All loops use the same order, and it is stable over time except when the skill registry is edited. L is the per-loop most-recently-used order. It is stable within a loop but diverges across loops, usually matching only at the top. S is the control arm that shuffles randomly every turn.

The steady-state hit rate, the fraction of input tokens served from the cache, splits clearly across the three arms. Under F, the whole fixed prefix becomes shared prefix. Because K loops touch it together, the eviction rate slows to 1/K of the single-user rate. Under L, the manifest differs from loop to loop, so sharing stops at the system prompt and the tool schema. S sticks to the static header only. Because the shuffled manifest stands in front of the task context, even the context of its own immediately preceding turn no longer hits.

Six results fall out of this structure. First, the shared gap: the hit-rate difference between F and L is proportional to the manifest length, and it widens as K grows and the turn interval lengthens. The difference is zero only when the manifest is empty, there is exactly one loop, or the turn interval is nearly nothing.

Second, the shared lifetime: under F, the effective lifetime of the fixed prefix grows K times over the single-user cache, to Kτ. The turn interval at which the shared hit rate falls to δ times its normal level is also proportional to this Kτ. Third, the three break-even points: the interval at which F starts to beat L, the interval at which the advantage peaks, and the interval at which it fades again are each derived. All three are proportional to τ. The larger the KV cache, that is, the closer to H200 class, the further every break-even interval shifts back, by the capacity ratio.

Fourth, the resend coefficient: under F, the cost of sending the cached manifest one more time is the cost of recomputing from scratch multiplied by a coefficient q. As the interval varies, q moves between the cached unit price, when the shared block survives the turn interval, and the uncached unit price, once it has been evicted. In the reference configurations, for intervals up to one hour, one resend costs between 1/10 and 3/5 of a fresh prefill.

Fifth, stability-first placement: editing the j-th skill description in the manifest invalidates every token after it, and every loop has to recompute on the next turn. Pushing frequently edited skills to the end of the manifest cuts the expected invalidation per edit round to roughly 1/N of a random placement. N is the number of skills. The composition rule the paper gives is this: place the stable core in order of access frequency, and the frequently changing tail in order of volatility.

Sixth, this lever composes multiplicatively with the others. The model tier and KV quantization change the unit price of every cost layer, thinking-token allocation changes the thinking layer, and manifest ordering touches only the fixed prefix layer. Because the layers do not overlap, the three levers compose by multiplication, and under the assumption that positional sensitivity is finite, the ordering is quality-neutral. It is the safest first dollar of the cost stack, and the only lever that involves no training and no engine change at all.

![Steady-state hit fraction by turn interval, by ordering arm](/assets/images/posts/research/agentic-prefix-reuse-manifest-ordering/fig-hitshape.webp)
*Curves of the steady-state hit fraction by turn interval, one for each of the three arms. F holds the shared prefix the longest, L falls off quickly, and S stops at the static header. Curves from an interpretive model, not measurements.*

## Predictions from the H200 Reference Configuration

Every number is a model prediction under the stated assumptions. The reference configurations are the four combinations of 14B and 32B models on the H200 (141GB) and the H100 (80GB). After subtracting the weights and the runtime overhead from the HBM, the H200 holds 2.3 times more KV cache than the H100 for the 14B model.

For the 32B model, the weights are 64GB and take up a larger share of the H100's smaller HBM, so the capacity gap widens to 6.1 times. The eviction time τ reflects that gap directly. Under the same contention, τ is 277 seconds for 14B/H200 and 23 seconds for 32B/H100. In plain words, the H200's larger memory is a wider shelf: 2.3 times wider for the 14B textbook, 6.1 times wider for the 32B one.

At Δ=900 seconds, K=16, and a 6,000-token manifest, the hit rates for 14B/H200 are 60 percent for F, 20 percent for L, and below 20 percent for S. The advantage of F comes from the shared lifetime. At K=16 on 14B/H200, the shared lifetime is 4,432 seconds, that is, 74 minutes. A one-hour tool delay fits inside that lifetime with room to spare. L does not get this lifetime, because each loop's manifest is evicted at the single-user rate. S holds only in the static header, and its ceiling is about 1/5 of the input.

In cost terms, under the token-billing regime (A), F saves 12-89% against the input cost of S. The savings are widest for large manifests and mid-range turn intervals. For manifests of 16,000 tokens or more, the savings hold at 60-80% over Δ=300-900 seconds and stay above 30 percent even at Δ=3,600 seconds. The comparison against L is sharper. L's manifest is evicted at the single-user rate while F's manifest holds up through sharing, so the savings reach 44.5-67.2% at Δ=900 seconds.

The four configurations side by side give the table below. Same conditions: Δ=900 seconds, K=16, 6,000-token manifest.

| Configuration | Eviction time τ (s) | F hit rate | L hit rate | S hit rate | Savings (F vs S) |
|---|---|---|---|---|---|
| 14B/H200 | 277 | 0.610 | 0.197 | 0.166 | 46.3% |
| 14B/H100 | 122 | 0.463 | 0.129 | 0.128 | 33.6% |
| 32B/H200 | 139 | 0.491 | 0.137 | 0.136 | 35.9% |
| 32B/H100 | 23 | 0.063 | 0.017 | 0.017 | 4.1% |

*Model predictions under the conditions Δ=900 seconds, K=16, 6,000-token manifest, and a 12-turn task; not measurements.*

The same lever delivers 46.3% savings on H200+14B and stays at 4.1% on H100+32B. The 11-fold difference comes from the KV cache capacity ratio, not from the ordering. 32B/H200 is in the middle at 35.9%. The 33.6% of 14B/H100 sits close to it because the eviction times of both configurations fall in the mid-100 seconds.

![Capacity-driven ordering of the fixed-prefix savings lever](/assets/images/posts/research/agentic-prefix-reuse-manifest-ordering/fig-capacity-ordering.webp)
*Because KV cache capacity sets the eviction time, the same ordering lever is worth more on H200+14B than on H100+32B. A gap that opens from the capacity ratio alone. A graph from an interpretive model, not a measurement.*

In the self-hosted regime (B), the shape of the savings changes. Here the savings are capped by the fraction of wall time that prefill occupies. At Δ=10 seconds, a 48,000-token manifest saves 45.8%, while at Δ=3,600 seconds it shrinks to 0.1%. In plain words, on self-hosted the value of this lever comes back as time-to-first-token headroom rather than as a line on the invoice. It lets you put more loops on the same instance under the same SLO.

The three break-even points come out under the same conditions. For 14B/H200 at K=16, the interval at which F starts to beat L is 15 seconds, the peak is at 820 seconds, and the fade point is at 10,212 seconds. At K=64, the fade point moves to 40,850 seconds, and a one-hour tool delay fits inside the shared lifetime with room to spare. 32B/H100 is different. With an eviction time of 23 seconds, onset is 1 second and the peak is 68 seconds. The advantage of F exists only inside the first minute of the tool delay.

What this lever leaves the company is a standing cost line item. It cuts the input-token spend of unattended skill-fleet loops with no training and no engine change, and it can be replayed end to end on H200 with our own agent traces. Socially, it lowers the inference cost and the energy per autonomous task. Skipping prefill cuts GPU-seconds, and energy tracks GPU-seconds almost one to one. Round-the-clock unattended automation becomes something even small organizations can afford. Scientifically, this is the first computation of the prefix cache economics of a structured agentic workload. Beyond the axes of model tier and quantization, it adds the axis of agent design to the LLM cost-optimization literature.

## Read as Operating Rules

First, the manifest order should be fixed in global access-frequency order. For the shared prefix to hold up as the union across K loops, every loop must use the same order. The router decides the content of the manifest, but the order is a lever only the operator can pull.

Second, frequently changing skills belong at the end of the manifest. An edit invalidates only the tokens after it, and pushing changes to the tail cuts the invalidation to roughly 1/N of the whole. The composition rule: the stable core in frequency order, the tail in volatility order.

Third, measure τ on your own instance first. τ is the KV cache capacity divided by the rate of incoming tokens. A narrow shelf means the textbook gets pushed off sooner. The effective range of the lever differs by machine and by traffic. On a machine with little KV cache headroom, or in a loop with long turn intervals, the lever may already be spent.

Fourth, on self-hosted, read the value of the savings as time-to-first-token headroom. The high hit rate of F removes GPU work per task and puts more loops on the same instance under the same SLO.

Fifth, measure positional sensitivity before counting the savings. By whatever fraction of tasks change their outcome under a reordering, the savings have to be reduced. The validation protocol of this paper is designed for that deduction in advance. On a dedicated H200, run the three arms F, L, and S together with two controls, cache off and manifest removed, pair the same tasks across arms, and gate on whether the success outcomes match.

<!-- nlm-visual -->
![Key-concept summary infographic 2](/assets/images/posts/news/agentic-prefix-reuse-manifest-ordering/en/nlm-infographic-2.webp)
*Infographic generated by NotebookLM from the sources.*

## What Cannot Be Trusted

The paper states plainly that it is an analysis paper. Every number in the body is a model prediction under assumptions A1 through A8, and there is not a single measurement. In place of measurements, it specifies a trace-replay protocol with a check attached to each assumption, opening the door for the predictions to become measurements.

First, quality neutrality is an assumption, not a proof. Long-context models lose performance on information placed in the middle of long inputs. This paper cites that limitation and assumes that a reordering can change task outcomes. A 48,000-token manifest is more than half of the input. This is a structure where the quality assumption bites hardest exactly where the savings are largest. The savings, then, may only be claimed after deducting the measured positional sensitivity.

Second, every result is scoped to a single instance. The model is for one serving instance shared by K loops, and a fleet is a set of instances each with a different τ. The routing and placement levers operate on top of this model.

Third, the eviction model is an approximation. Exponential eviction with τ set to the ratio of capacity to inflow is a mean-field approximation of most-recently-used eviction, and it is a value to be calibrated per instance.

Fourth, reuse holds only for the identical prefix from token 0. Position-independent reuse is an extension demonstrated by KV cache hijacking. This model does not count those hits. Conversely, the ordering lever moves no token anywhere within a turn, so it is safe inside this long-prefix semantics.

Finally, the dollar value on self-hosted is capped by the prefill share of wall time. The longer the tool delay, the thinner the invoice savings and the more the value moves into headroom.

Every number in this post is a prediction of an interpretive model under the stated assumptions, not a measurement. The three figures are concept diagrams and interpretive curves, and they carry no data.

---

The paper detail page is available here: [The Manifest Order: Measuring KV-Cache Prefix Reuse and Token Cost Savings from Skill-Manifest and Tool-Schema Ordering in Unattended Agentic Loops on H200](https://huggingface.co/datasets/thaki-AI/daily-paper-2026-09-20-agentic-prefix-reuse-manifest-ordering)
