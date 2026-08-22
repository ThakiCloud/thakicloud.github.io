---
title: "When Serving MoE Models on B200, When Should You Turn On Quantization, Speculative Decoding, and Prefix Caching?"
seo_title: "B200 MoE Serving Break-Even Analysis: Precision, Speculative Decoding, and Prefix Caching Depend on Traffic Regime | ThakiCloud"
seo_description: "When serving MoE models on B200, precision (FP16/FP8/NVFP4), n-gram speculative decoding, and automatic prefix caching are not independent switches. We walk through a closed-form cost model showing how the three break-even points push against each other depending on the traffic regime, defined by concurrency, prefix sharing rate, and repetitiveness."
excerpt: "If lowering precision suddenly turned speculative decoding into a loss, it's because the two switches were never independent to begin with."
date: 2026-08-05
tags:
  - B200
  - MoE
  - Speculative-Decoding
  - Prefix-Caching
  - NVFP4
  - Quantization
  - LLM-Serving
  - Metis
  - Maxis
categories: [research]
author_profile: true
toc: true
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/research/traffic-regime-serving-breakeven/"
published: false
---

If you're on a team serving MoE (Mixture-of-Experts) models on B200, you've probably validated precision (FP16, FP8, NVFP4), n-gram speculative decoding, and automatic prefix caching against a single benchmark trace and flipped them on from there. This paper shows, through a closed-form cost model, that those three switches are not actually independent, and that which one pays off is decided not by precision itself but by the character of the traffic arriving right now: its concurrency, its prompt reuse rate, and its repetitiveness. It works out mathematically why winning on one benchmark trace is no guarantee of winning in the next time window or with the next tenant, and on top of that lays out a procedure for observing traffic and deciding the three switches in order, which makes it directly useful for engineers actually tuning serving costs.

![Illustration of the core idea of When Serving MoE Models on B200, When Should You Turn On Quantization, Speculative Decoding, and Prefix Caching?](/assets/images/traffic-regime-serving-breakeven-hero.webp)
*A visual metaphor for the article's key idea.*

## Why the Three Switches Cannot Be Turned On Independently

Precision, speculative decoding, and prefix caching are each well studied on their own, and serving-engine config files tend to treat them as unrelated boolean flags. The problem is that for all three levers, the sign of the payoff depends on traffic, and real production traffic is neither stationary nor homogeneous. A coding-agent tenant running long loops over a repository context that shifts only slightly turn by turn, a consumer chat tenant sending freshly composed prompts every time, and an overnight batch summarization job saturating the accelerators all have wildly different prefix sharing rates. The paper cites recent workload characterization studies such as ServeGen and TraceLab to confirm that prefix sharing rate is not a constant of the technique but an empirical variable of the deployment.

And the outcome is not symmetric. Turn a lever on in the regime where it helps, and the gain is bounded; turn it on in the regime where it doesn't, and the loss can grow effectively without bound, because the overhead is paid on every request regardless of whether the gain materializes. n-gram speculative decoding is exactly this case. On low-repetitiveness traffic, the target model rejects the draft's proposed candidates at close to the base rate, so every decode round pays the verification cost with almost no amortization. A configuration that was justified on a high-repetitiveness benchmark becomes a pure tax on a different traffic mix.

What makes the problem worse is that the levers are entangled with each other. Lowering precision changes the per-token memory bandwidth cost, which in turn changes the value of speculative decoding, a technique that trades decode steps for compute. Lowering precision also frees up HBM headroom, which lets the batch size grow at the same concurrency, which in turn grows the pool of KV blocks the prefix cache has to manage. And specifically for MoE targets, lowering precision erodes the acceptance rate of a higher-precision draft, because quantization perturbs the routing boundaries that determine the next-token distribution. The authors' earlier work identified this mechanism qualitatively, and this paper turns it into an explicit coupling term between the two levers.

## The Traffic Regime Decides the Break-Even Points

The heart of the paper is that it sets up cost per token (CPT) as a function of a traffic regime, defined by concurrency $C$, prefix sharing rate $\rho$, and repetitiveness $r$, together with precision $p$ and two toggles, $s$ for speculative decoding and $k$ for prefix caching. Decode cost is the bandwidth cost of reading active parameters from HBM divided by the realized batch size, and that batch size is itself capped by a KV cache capacity ceiling that depends on precision. Lower precision leaves the weights taking up less HBM, which frees more room for KV state, and that shifts the batch-size ceiling, the capacity knee, further to the right.

From here you can derive closed-form break-even conditions for precision, speculative decoding, and prefix caching individually, and more importantly, derive how the break-even boundary of one lever moves when another lever's state changes. This cross-coupling is the result the paper leans on hardest. The repetitiveness threshold $r^{\star}$ above which speculative decoding breaks even rises monotonically as precision drops from FP16 to FP8 to NVFP4. The cause is the acceptance-rate erosion coefficient $\eta(p)$ mentioned above, and the ordering works out to $\eta(\text{FP16}) \ge \eta(\text{FP8}) > \eta(\text{NVFP4})$.

The example numbers the paper gives (all example parameters) make this concrete. At low concurrency, FP16 already breaks even on speculative decoding once repetitiveness passes 0.06, but at NVFP4 that threshold more than doubles to 0.14. Push concurrency up into the regime where verification overhead carries more weight, and the FP16 threshold rises to 0.29 while NVFP4's rises to 0.45, widening the gap further. Lowering precision and raising concurrency push in the same direction. In this regime, turning on speculative decoding can end up a loss even on traffic that is quite repetitive.

![Graph showing how the speculative decoding repetitiveness threshold r* changes with concurrency and precision](/assets/images/posts/research/traffic-regime-serving-breakeven/fig-spec-decoding-breakeven.webp)
*All figures are calculated from example parameters, not measurements. As precision drops from FP16 to NVFP4, and as concurrency rises, the repetitiveness threshold at which speculative decoding turns profitable rises along with them.*

What makes this dangerous in practice is the order of operations. If an operator quantizes down from FP16 to capture the capacity gain but leaves speculative decoding on simply because it was validated at FP16, they have unknowingly crossed the break-even boundary in the wrong direction. An analysis that looks at only one lever at a time never surfaces this failure mode at all.

## Where Prefix Caching Flips

Prefix caching is a net gain only when the prefill savings exceed the cache management overhead: hashing, lookup, reference counting, and eviction. Working out this condition shows that the break-even prefix sharing rate $\rho^{\star}$ grows in proportion to the realized batch size $B_{\mathrm{eff}}$. The more resident requests there are, the larger the working set the cache has to manage, and the higher the hit rate has to be to justify it.

This is where the second counter-intuitive coupling shows up. As concurrency rises, $B_{\mathrm{eff}}$ rises with it up to the capacity knee, so the threshold needed to justify prefix caching rises together with concurrency. But lowering precision also pushes that capacity knee further to the right, so in a concurrency range that has already passed the higher-precision knee, quantization grows $B_{\mathrm{eff}}$ a second time. The upshot is that moving from FP16 to NVFP4 makes prefix caching harder to justify on the same traffic profile, the opposite of what intuition suggests, because the extra HBM headroom bought by quantization gets spent serving more concurrent requests, which only enlarges the working set the cache has to index and evict.

![Graph showing how the prefix caching break-even sharing rate rho* changes with realized batch size](/assets/images/posts/research/traffic-regime-serving-breakeven/fig-prefix-cache-breakeven.webp)
*This is an example calculation using an example coefficient (γL_ctx/(c_pre L_in) = 0.002). At a realized batch size of 32, the break-even sharing rate is a low 0.06, but it climbs to about 0.51 once batch size reaches 256, which pushes even a workload with a 40 percent prefix sharing rate below break-even.*

One more thing: this break-even value is inversely proportional to average prompt length. Longer prompts mean more prefill to save in absolute terms, so the break-even point drops; traffic with shorter prompts, conversely, is more prone to turning prefix caching into a tax. Output length, by contrast, enters both the numerator and the denominator equally and cancels out, so it has no effect on the break-even point itself.

## Precision's Gain Saturates

The gain from lowering precision also passes through three phases as concurrency rises. Below the capacity knee of either precision, batch size simply tracks concurrency, so the lower precision's advantage is pinned exactly at the bandwidth ratio (for example, exactly 1/4 if NVFP4 uses 1 byte for every 4 bytes FP16 uses). Once concurrency passes the higher precision's knee but not yet the lower precision's, the higher precision's batch size is capped by capacity and can no longer grow while the lower precision keeps growing its batch, so the gap widens linearly across that range. Once concurrency passes both knees, the gap stops widening and flattens out at a level that is always better than the bandwidth ratio, because the lower precision can keep more sequences resident.

![Graph showing how the NVFP4-to-FP16 cost-per-token ratio changes across low, medium, and high concurrency](/assets/images/posts/research/traffic-regime-serving-breakeven/fig-precision-concurrency-advantage.webp)
*Calculated with example parameters (b(FP16)=2, b(NVFP4)=0.5 bytes per parameter, capacity ratio K_NVFP4/K_FP16=1.33). NVFP4's advantage grows most steeply in the range between the two knees, then flattens out at around 0.19 above that.*

The operational implication is that the range between the two knees is exactly where a wrong concurrency estimate costs you the most. Outside that range, precision choice is relatively predictable, but between the two knees even a small miss on concurrency can swing the precision decision significantly.

## A Decision Procedure for Operators

The paper ties the three break-even conditions together into a single procedure. Because precision enters all three terms, decode, capacity, and speculative, while speculative decoding and prefix caching become independent of each other once precision is fixed, precision always comes first in the ordering. The procedure runs roughly as follows. First, observe concurrency, prefix sharing rate, and repetitiveness from the serving instance's in-flight request count, the engine's block cache hit statistics, and offline n-gram lookups over sampled prompts and completions. Next, keep only the precisions satisfying the quality bar $Q(p) \ge Q_{\min}$, and among the surviving candidates pick the one that minimizes decode cost. Then recompute the prefix caching decision based on the batch size realized at that precision, and the speculative decoding decision based on that precision's acceptance-rate erosion coefficient. Finally, if concurrency swings significantly on a daily cycle for a given segment, re-evaluate both toggles periodically.

The most important operational discipline is this last re-evaluation step. The paper points out that in practice, the common path into a misconfigured state is not flipping a lever wrong from the start, but changing precision later and inheriting a toggle that the change has already invalidated.

Applying this procedure to three example traffic types makes it more concrete. Coding-agent traffic running long loops over a stable repository context has both prefix sharing rate and repetitiveness high, so the recommendation is FP8 with both speculative decoding and prefix caching turned on. It stays at FP8 rather than dropping to NVFP4 because the acceptance-rate erosion coefficient $\eta$ needs to stay high enough to preserve the speculative gain. Open-ended chat traffic made of freshly composed prompts every time has both repetitiveness and sharing rate low, so it's better to turn both toggles off and run at the lowest precision on a pure bandwidth-and-capacity comparison. High-concurrency batch work running at saturation has a small decode cost in the first place, so verification overhead carries more weight, meaning speculative decoding should be off, prefix caching should be decided conditionally based on the observed sharing rate, and precision should go as low as possible, since NVFP4 pushes the capacity knee furthest out.

## What This Means for ThakiCloud

The problem this model addresses is exactly the problem Metis, our AI Inference / Token Factory layer, faces every day. In vLLM-based serving, how to combine precision, speculative decoding, and prefix caching per tenant and per Dedicated Endpoint is a direct lever on cost per token, and this paper gives a concrete procedure for re-evaluating that combination against an observable traffic regime instead of freezing it after a single benchmark. In particular, the warning against carrying a speculative decoding toggle forward unchanged after a precision change is worth checking immediately in any environment serving MoE-family models across multiple precisions.

There's a thread running to Maxis as well. The paper cites the authors' earlier work on router-aware selective NVFP4 quantization and offers a testable prediction: selectively protecting only the gating network and low-frequency experts should keep the acceptance-rate erosion coefficient $\eta$ much higher than uniform quantization does. If that holds, selective quantization would not just improve the accuracy-cost Pareto curve, it would also ease the speculative decoding break-even, letting you hold both levers at once in a range where uniform quantization would force a choice between them. For Maxis, which owns our training and compression pipeline, this is a hypothesis worth testing directly.

From the Paxis angle, it's striking that the traffic this paper classifies as the coding-agent-loop archetype, a long agent loop running repeatedly over a stable context, is exactly the shape of the execution traffic Paxis generates. That means as work-automation agents grow in number, the tuning standards for the inference layer supporting their execution have to grow more precise alongside them, and this paper's break-even procedure is a concrete tool for doing that tuning from observed traffic statistics rather than benchmark instinct. Scientifically, too, the authors present every result in falsifiable form and explicitly ask for verification through controlled B200 deployment sweeps, a stance that reads as a call for a culture of reproduction and verification in itself.

## Limitations and Next Steps

The first thing to disclose is that this paper is purely analytical. The authors did not measure any B200 deployment experiment. Every number in the text and figures is an example parameter chosen to illustrate the shape the equations draw, not an observed value. The authors themselves frame this as a collection of falsifiable structural predictions and state explicitly that a controlled B200 deployment sweep crossing the full $(C, \rho, r) \times (p, s, k)$ space, starting with the acceptance-rate erosion coefficient $\eta(p)$, is needed.

The assumptions baked into the model also limit its scope. Because it assumes traffic is stationary within a segment, daily concurrency swings or bursts are handled only through periodic re-evaluation and are not modeled directly. Treating acceptance probability as i.i.d. is also a simplification: in reality, a good n-gram match tends to be followed by a few more good tokens, a positive autocorrelation, which means the paper's predictions lean conservative and the real $r^{\star}$ may run somewhat lower than predicted. The authors state, though, that the paper's ordering relationships, such as the conclusion that the threshold rises as precision drops, depend only on the fact that $\bar{A}$ increases monotonically with acceptance rate, and are therefore unaffected by this simplification. The scope is also narrowed to a single model on a single B200-node class, so it does not cover multi-model coexistence or the interconnect cost of expert-parallel deployment, and the quality constraint $Q(p) \ge Q_{\min}$ is treated purely as an external filter rather than a term traded off against cost.

Full paper details are available at the following link: [https://huggingface.co/datasets/thaki-AI/daily-paper-2026-08-05-traffic-regime-serving-breakeven](https://huggingface.co/datasets/thaki-AI/daily-paper-2026-08-05-traffic-regime-serving-breakeven)
