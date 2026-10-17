---
title: "The Joule Frontier: The Cheapest Router Configuration According to the Token Ledger and the Cheapest According to the Meter Can Differ, and the Difference Is Closed Form"
seo_title: "The Joule Frontier paper introduction - On a self-hosted H200, the skill router economics of a 24/7 agent platform is expressed almost entirely in token dollars, but what the platform actually pays every second is physical energy. This paper introduces energy per routed request as a third objective alongside dollar cost and quality, and analyzes it across the 12-configuration space of a hybrid skill router. Under the structural power model E(c) = P0 t(c) + η W(c) + R(c), the cost-optimal configuration being strictly worse than the energy-optimal configuration is equivalent to the floor-time penalty exceeding the work-energy advantage, and the paper names this the closed-form energy tax. Decoupling is load-dependent, and at the crossover concurrency B* the orderings of the two objectives meet again. The energy-quality Pareto knee drifts with load. Quantization inside the rank-safety margin is dollar-neutral and strictly energy-dominant, an explicit upgrade of the earlier gatekeeper study. A measurement protocol calibrated with NVML integrated power sampling makes every condition falsifiable on production infrastructure, and the paper also states the proposition that the energy slice of TCO grows with uptime. - ThakiCloud"
seo_description: "The router of a 24/7 agent platform never sleeps, and what the platform actually pays every second is physical energy, not token dollars. This paper introduces joules per routed request as a third objective and gives, in closed form, the energy tax, which is the iff condition under which the cost-optimal and energy-optimal configurations decouple, the crossover concurrency B* and the knee drift that move with load, and energy-dominant quantization inside the rank-safety margin."
excerpt: "The token ledger prices only tokens, and the meter prices time and work. The two ledgers read different coordinates of the same router configuration, so the cheapest one can differ for each. This paper gives that difference as a closed-form function of measurable parameters."
date: 2026-10-18
tags:
  - energy-quality-frontier
  - skill-routing
  - gpu-power-telemetry
  - token-cost-decoupling
  - router-configuration-space
  - pareto-knee
  - h200-serving
  - sustainable-inference
  - agent-harness
  - llm-economics
categories:
  - research
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/en/research/joule-router-energy-quality-frontier/"
---

If you run a 24/7 agent platform on a self-hosted H200, or own the electricity bill (TCO) that comes with it, the question this post answers is an operations problem. The one-line conclusion: the router configuration that is cheapest on the token ledger is not always the same as the one that is cheapest on the meter. The size of that gap is a closed-form function of measurable parameters. ThakiCloud's paper **"The Joule Frontier: Measuring the Energy-Quality Tradeoff of Skill-Router Configurations and Its Decoupling from Token Cost on Self-Hosted H200"** introduces physical energy per routed request as a third objective alongside dollar cost and quality, and analyzes that value across the 12-configuration space of a hybrid skill router. This is an analytical paper. It reports no measured energy values. Every figure is a closed-form prediction under the declared assumptions, registered alongside a falsifiable measurement protocol designed to fill those predictions in.

![Illustration of the core idea of The Joule Frontier: The Cheapest Router Configuration According to the Token Ledger and the Cheapest According to the Meter Can Differ, and the Difference Is Closed Form](/assets/images/joule-router-energy-quality-frontier-hero.webp)
*A visual metaphor for the article's key idea.*

## The Problem: The Routing Literature Prices Only Dollars and Quality

In an unattended agent harness, every task passes through the skill router before execution. The retriever pulls candidate skills. The reranker decides, and the executor model performs the task. The router sits on the hot path of every request, so its economics matter at fleet scale. The routing literature prices the router in dollars. Token granularity, provider selection, and a security objective have been added to the cost-quality Pareto one after another.

But on self-hosted infrastructure, the dollar ledger is incomplete. The price of the GPU is amortized capex plus one small electricity line item. The token cost of a routing decision exists only as an internal shadow price. What the platform actually pays every second is physical energy: watt-hours that become heat, cooling load, and carbon. On a 24/7 agentic platform, the router never sleeps. Whether or not a task is in flight, that idle-time energy keeps getting paid.

The energy research side has already measured inference energy at the model, fleet, and schedule level, and characterized the phase structure of modern accelerators. But no paper yet prices the router's configuration decisions themselves in joules per routed request. The choices of retrieval depth, reranker tier, and embedding precision remained decisions visible only in the token ledger.

This paper asks the corresponding question over the skill router configuration grid of a self-hosted H200. Does the physical GPU energy per routed request decouple from routing accuracy and dollar cost? Does the energy-optimal configuration differ from the cost-optimal one at the measurable energy-quality Pareto knee?

The key to the answer is a structural asymmetry. The three hands that turn the coordinates of a configuration c = (k, τ, q) are three families: wall-clock time, work, and token count. The retrieval depth k raises time, work, and token count all at once. The reranker tier τ trades shadow price against work, and the wall-clock depends on the phase structure. The quantization precision q lowers work and wall-clock; token count is invariant, and quality is invariant within the rank-safety margin. Dollar cost is a function of token count, while energy is a function of time and work. Tokens and wall-clock are different coordinates of the same configuration space, and they are not monotonically related.

![Skill-router configuration space: where the token ledger and the power meter diverge](/assets/images/posts/research/joule-router-energy-quality-frontier/fig-router-coordinate-structure.webp)
*The router configuration c = (k, τ, q) moves three coordinate families, wall-clock time, work, and token count, and the two ledgers price different coordinates, so the cost-optimal and the energy-optimal can decouple. (Conceptual illustration: a structural schematic of the cost/energy/quality objectives over the k × τ × q grid; it makes no quantitative claim)*

In plain terms, the token ledger and the electricity meter are looking at different coordinates of the same dial. Whether the "cheapest" configuration is the same depends on what each ledger reads.

## The Structural Power Model and the Energy Tax: the iff Condition Between Cost-Optimal and Energy-Optimal

The paper prices the router stage with a structural power model. The router-stage energy per routed request decomposes into three terms: E(c) = P0 t(c) + η W(c) + R(c). P0 is not the idle power of an empty node; it is the floor power the serving GPU holds during the router-stage window. η is the marginal joule per unit of work, and R is a residual that absorbs the errors of phase mixing, clock throttling, and finite power sampling resolution. The protocol calibrates P0, η, and R with NVML integrated power sampling on the real node.

With the quality budget ε fixed, the feasible set F_ε is the set of configurations whose routing accuracy is at least 1-ε. Within it, the cost-optimal configuration c† minimizes dollar cost, and the energy-optimal configuration c‡ minimizes the per-request energy measured at reference load. The energy tax τ_E of a deployment that pins c† and ships it is defined as τ_E = E(c†)/E(c‡) - 1.

The main theorem gives the iff condition for this tax to be positive. The cost-optimal configuration being strictly worse than the energy-optimal one is equivalent to the floor-time penalty P0(t† - t‡) exceeding the work-energy advantage η(W‡ - W†) plus the residual difference. In the rate-work regime, the condition reduces to comparing the floor-to-work ratio P0/η against the marginal work rate of the energy-optimal configuration. A configuration that is cheap in tokens but slow in wall-clock gets a higher price from the meter, by exactly the time the floor stays on.

![Energy tax: floor-time penalty versus work-energy advantage](/assets/images/posts/research/joule-router-energy-quality-frontier/fig-energy-tax-condition.webp)
*The cost-optimal configuration being strictly energy-worse (energy tax > 0) is equivalent to the floor-time penalty it pays exceeding the work-energy advantage of the energy-optimal configuration. (Analytical model, not a measurement)*

Decoupling works through two different mechanisms. The first is the tier mechanism. At the same retrieval depth and precision, the tokens of the small reranker tier are cheap, but the decode is memory-bound, so the wall-clock is long. The large tier does more work, but the wall-clock is shorter in the prefill and batch-bound phases. The token ledger reads the price difference. The meter shows the floor-time difference. The second is the precision mechanism. Within the rank-safety margin, quantization strictly reduces energy while moving dollar and quality almost not at all: not a reversal of ranks, but a strictly positive energy saving at the point where both the dollar cost and the quality cost are zero.

The precision mechanism is an explicit upgrade of the earlier gatekeeper study. If the gatekeeper study showed that quantization is safe within the rank-safety margin, this paper extends that conclusion to "safe within the margin, and free in energy". The saving per request reaches exactly P0ρ_t t + ηρ_W W joules. ρ_t and ρ_W are the reductions in wall-clock and work that weight-only quantization brings. A compression result becomes an energy result.

## The Optimum That Moves with Load: Crossover Concurrency and Knee Drift

The decoupling of the cost-optimal and the energy-optimal depends on load. Under continuous batching, the router-stage wall-clock splits into a parallel part shared among in-flight requests and a serial part that cannot be shared. The per-request wall-clock is roughly t_ser + t_par/B. As concurrency B rises, the per-request floor share falls.

The crossover concurrency B*(c) = P0 t_par/(P0 t_ser + η W + R) given by the load lemma is the load at which the per-request floor share equals the work plus serial share. Below B*, the floor dominates: the energy-optimal configuration is the tier with the higher work rate, the one that finishes fastest. Above B*, work dominates: the energy-optimal configuration becomes the tier that does the least work.

![Per-request energy versus concurrency: load-dependent knee drift](/assets/images/posts/research/joule-router-energy-quality-frontier/fig-knee-drift-load.webp)
*For both tiers, the router-stage energy per request falls as concurrency rises, because the floor amortizes. At light load, the work-heavy fast tier leads. Past the crossover concurrency, the least-work tier takes over as the winner. (Analytical model, not a measurement)*

This result leads to the knee drift. With retrieval depth and precision fixed, the pairwise energy gap between two tiers that satisfy the rate-work tradeoff crosses zero exactly once as load rises. The energy-quality Pareto knee c_knee(B) effectively moves from the tier with the higher work rate to the tier with the minimum work. A deployment pinned to a configuration outside its own regime pays an energy tax on every request.

Reconvergence happens too. As B approaches saturation, the per-request energy is determined by work and serial time alone, independent of token count. The dollar ordering is still token-based. The two orderings agree on the retrieval depth k. On the precision q, the dollar ordering is flat while the energy ordering is strictly monotone. At saturation, the last place the two orderings diverge is the reranker tier τ, in its mispricing of n and W.

But is this knee trustworthy? The certification margin lemma answers in terms of error bounds. If the calibration errors are (δP, δη, δR), the knee is invariant as long as M, the relative energy gap to the neighboring configurations of the knee, exceeds the sum of those errors. Operationally, a "measurable" Pareto knee is a knee with a positive certification margin. The protocol reports that margin as part of the frontier output.

The consequence for TCO is a proposition. The energy slice S(u) of the annual TCO is strictly increasing in the uptime fraction u. The always-on router at u = 1 holds the largest slice, because the floor term is paid even when the request set is idle. Pinning the cost-optimal configuration makes the annual energy line item exactly 1 + τ_E times as large. In plain terms, the energy bill grows with uptime, not with traffic.

## The Decision Rule: Pick c‡(B) per Load Class and Report τ_E

The measurement protocol is the empirical counterpart of the analysis. It runs on a single H200-class GPU with the power cap pinned at 700 W, a continuous-batching engine, and a fixed tool-calling request set. The 12 configurations crossed with the load classes {1, 4, 16, 64} produce 48 cells. Serving timestamps cut out the router-stage window, so the executor-stage energy is excluded. P0 is calibrated with a no-load probe, and η and W with roofline counters (FLOPs, HBM bytes). Bootstrap confidence intervals cover Q, dollar, and energy respectively.

The deployment rule operates per load class. The protocol outputs, for each B, the energy-optimal c‡(B), the cost-optimal c†(B), and the tax τ_E(B). If τ_E(B) exceeds the operator's energy budget threshold, ship c‡(B): the tax is paid on every request and compounds with uptime. Otherwise, ship c†(B). τ_E(B) becomes an auditable number reported alongside token cost. Quantization within the rank-safety margin is the default move in every class; it is strictly dominant across the full space of the three objectives.

Falsification is registered per result as well. If the sign of τ_E under the calibrated (P0, η, R, t, W) differs from the condition, the energy tax theorem is falsified. If the knee does not cross B* while traversing the four load classes, the load lemma is falsified. If no quantization step within the margin passes the (ΔE < 0, Δ$ ≈ 0, ΔQ ≈ 0) triple, the precision corollary is void.

## The Meaning: What Stays for the Company, Society, and Science

On ThakiCloud's always-on agent platform, energy is the hidden slice of TCO. The router rides above every request. A measurable energy-optimal configuration per load class actually reduces electricity, heat, and downstream capex. The concrete decision of "when is cost-optimal routing energy-inefficient" becomes an auditable number τ_E(B) reported alongside token cost. This paper is the fourth axis of a series that has priced the cost-quality frontier of self-hosted agentic serving for a year. The gatekeeper priced compression, the thinking router priced the reasoning budget, and the concurrency tax priced serving load; this paper makes the physical energy of the routing stage itself an explicit objective.

A 24/7 agentic LLM workload is a growing electricity and carbon load. This paper quantifies the physical energy cost of routing choices considered "cheap". It also shows the points where a small quality loss, or no quality loss at all within the margin, buys a large energy saving. Configuration decisions are physical decisions. A token ledger that ignores them pays the floor twice: once in dollars, once in joules.

Scientifically, the paper introduces joules per routed request as a third objective in LLM router design, alongside dollar cost and quality, one that is physically grounded. The closed-form energy tax condition, the crossover concurrency B*, the certification margin, and the falsification protocol remain a new axis absent from the recent cost-quality routing literature.

## The Limits: Results That Hold on a Structural Model

The main results are all conditional on the piecewise structural model: a three-term model of a persistent floor, an active draw proportional to work, and a bounded residual. Inside the model, the iff of the energy tax and the crossing of the load lemma are exact. The protocol exists to estimate (P0, η, R) on a specific node, phase mix, and engine, and to verify that the residual is bounded. The weakest part of the model is the active-draw term. Phase mixing between embedding prefill and reranker decode can bend ηW into a nonlinear function of the phase split. That is why the residual is per-stage and per-load, and B* is per-configuration.

This paper does not report measured energy values. The contributions are the structural model, the decoupling condition, the crossover and certification results, and the falsification protocol. Multi-GPU interconnect energy, heterogeneous fleets, and grid-intensity optimization are out of scope. P_max is a platform constant, and P0 is a calibrated quantity.

There are two open compositions. In the concurrency tax, the accuracy Q(c;B) itself drifts at saturation, so the feasible set is load-dependent, and the joint (load, quality, energy) frontier is the natural next object. In the thinking router, a third term enters the water-filling allocation rule, pricing router-stage joules at each thinking-token allocation point.

The three figures in this post are all closed-form predictions of the analytical model, not measurements. Each caption says so.

The paper and its accompanying materials are available on Hugging Face.

https://huggingface.co/datasets/thaki-AI/daily-paper-2026-10-18-joule-router-energy-quality-frontier
