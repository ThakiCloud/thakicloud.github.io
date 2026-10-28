---
title: "The Morning Deadline: Elevating the morning deadline to the first goal of routing decisions, and establishing in theory the cost-quality-completion frontier of unattended agent night work and the break-even of rerank-stage skip"
seo_title: "The Morning Deadline: Deadline-aware model-tier routing for unattended agent night work, cost-quality-completion frontier, break-even of rerank-stage skip, DARP, morning deadline, self-hosted H200 - ThakiCloud"
seo_description: "When you run unattended agents overnight, the real constraint is not the token bill but the clock. This paper, built on ThakiCloud's own H200, lifts the morning deadline to the first goal of routing decisions and establishes in theory the three-axis cost-quality-completion frontier and the break-even of skipping the LLM rerank stage. At the core: the shadow price of time that is 0 in slack and peaks at the deadline knee; the degeneracy in which saving only the rerank call leaves an empty window and full T0 demotion is the only option left; the deadline-aware tier rule DARP that splits into three regimes; and the property that the last unit is bought in the two currencies of dollars and quality. The paper is analytical, so every value is a prediction and not a measurement, and the pre-registered measurement design fills the frontier in production."
excerpt: "In overnight work of unattended agents, the constraint is not the bill but the clock. This paper lifts the deadline to the first goal of routing and establishes the cost-quality-completion frontier and the break-even of rerank-stage skip. It is an analytical paper, so every value is a prediction, not a measurement."
date: 2026-10-28
tags:
  - deadline-aware-routing
  - unattended-agent-loops
  - overnight-automation
  - cost-quality-completion-frontier
  - model-tier-routing
  - rerank-stage-skip
  - h200-serving
  - agent-harness
  - sra-bench
categories: [research]
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/en/research/deadline-aware-overnight-agent-routing/"
audiobook: "https://drive.google.com/file/d/1_jB6QVEZ2qcvc_KWNsA-z9ZCDaJks7Yn/view"
audiobook_label: "▶ Listen: 5-minute briefing"
audiobook_note: "NotebookLM audio overview (AI-generated)"
---

If you are a cloud or AI engineer who runs unattended agents overnight, this post is for you. This post introduces the morning-deadline paper we built on our own H200. The paper lifts one fact to the first goal of routing decisions. A task processed overnight has value only if it finishes by morning.

Prior routing research fixed quality and cut cost. Interactive systems added a per-request latency SLO on top of that. This paper adds the time left until the deadline to the objective.

Here is the one-line conclusion. As the night deepens, the lever that keeps completions is not saving a few rerank calls. It is dropping that task, wholesale, to a tier with no LLM.

One thing to be clear about. This paper is an analytical paper. Every value in the body is a prediction of the analytical model, not a measurement. The actual numbers of the frontier are the part that the pre-registered measurement design fills in production.

![Illustration of the core idea of The Morning Deadline: Elevating the morning deadline to the first goal of routing decisions, and establishing in theory the cost-quality-completion frontier of unattended agent night work and the break-even of rerank-stage skip](/assets/images/deadline-aware-overnight-agent-routing-hero.webp)
*A visual metaphor for the article's key idea.*

## In plain terms

Think of a night parcel-delivery hub. The hub takes in a pile of parcels in the evening and must deliver all of them by morning. A parcel that misses the morning deadline has value 0, and the fuel already spent is a loss.

The dispatcher decides which driver goes with each parcel. There are three kinds of drivers. A veteran who knows every route, is fast, but is expensive. That is tier T2, the 27B NVFP4 big model. A young driver who handles ordinary courses cheaply. That is tier T1, the 8B small model. And a way with no driver at all. If the address is perfectly clear, you just leave the parcel in the building lobby. That is tier T0, with 0 LLM tokens.

So far the dispatcher watched only two things. Delivery quality and driver fares. This paper adds the clock to the dispatch decision.

**As the night deepens, the value of a minute is no longer 0.**

If delivery has slack, sending one parcel a few minutes earlier does not raise the count that arrives by morning. But once the day's volume grows beyond what can be delivered by morning, each minute gains a price. That price is highest where the volume exactly meets the deadline, and it falls as the overload deepens. The time one parcel uses is not just that parcel's cost. It is a latency cost that steals expected delivery from every other parcel in the same truck. So the dispatch rule built on the assumption that time is free is no longer optimal in front of a deadline.

In plain words then: when the night delivery is tight, the dispatcher's lever is not saving a little on the address recheck. It is removing the driver call entirely and dropping the parcel to the lobby.

<!-- nlm-visual -->
![Key-concept summary infographic 1](/assets/images/posts/news/deadline-aware-overnight-agent-routing/en/nlm-infographic-1.webp)
*Infographic generated by NotebookLM from the sources.*

## What we tried

After setting up the morning-deadline problem, the paper answers three questions of routing decisions. First, how much is a minute worth? Second, can we remove the re-selection step that picks a driver for each parcel? If so, in what form? Third, what should the deadline-aware tier rule be?

The routing pipeline has three stages. The first is retrieval: it pulls candidate skills from the skill list and uses 0 tokens. The second is LLM rerank: it picks one from those candidates. The third is execution. A tier is defined by which model is mounted on each stage. T2 is the teacher tier of the 27B NVFP4 big model. T1 is the student tier of the 8B small model. T0 is the retrieval-gate tier with 0 LLM tokens. In T0, rerank is skipped, routing goes by the retrieval top-1, and execution proceeds as a deterministic handoff.

The paper answers these three questions with four results. The shadow price of time, the break-even of rerank-stage skip, the deadline-aware tier rule DARP, and the dual currency of the last unit. It also provides a measurement design to verify them in production.

The design uses a fixed 63-task SRA holdout (45 positive, 10 native, 8 negative). There are three experimental arms. A0 is all T2, A2 is difficulty-gate tiering, and A3 is A2 with the deadline skip added. The three arms combine with the deadline sweep (from slack to overload, pressure 0.25 to 2.5). Prompt tokens are billed deterministically at the declared self-host rates (1.50 and 0.60 dollars per million input and output tokens), and bootstrap intervals are attached to estimate the frontier. The four pre-registered predictions, namely slack invariance, rescue dominance, the break-even band, and the two-currency crossing, are contrasted against measurements.

## The results

### Time gets a price, and its peak is the deadline knee

The first result is the shadow price of time. The paper defines it this way. How much the expected completion count grows when you remove Δd seconds of wall time from the total night load is exactly that price. In slack (load below the deadline) the price is 0. If the night still has room, speeding up one task by any number of seconds does not raise the completion count.

The moment load exceeds the deadline, the price appears. It is highest exactly at the deadline knee, where load and deadline just meet, and it falls as the overload deepens.

![Shadow price of time: the morning-deadline kink](/assets/images/posts/research/deadline-aware-overnight-agent-routing/fig1_shadow_price_kink.webp)
*Drawn with the analytical model: the expected completion value of one second removed from wall-time load (Prop. 1 of the paper). It is 0 while the schedule pressure pr=L/T is below 1, maximal at the deadline knee (pr=1), and shrinks as the overload deepens. It is the shape of a theoretical curve, not a measured value.*

The x-axis of the figure is the schedule pressure from the pre-registered deadline sweep (0.25, 0.8, 1.0, 1.25, 2.5). The y-axis is the price normalized to the knee value.

In plain words then: once a truck's volume exceeds what it can deliver by morning, each remaining minute on the clock gains a price. That price is highest where the volume exactly meets the deadline.

The extra wall time each task uses is a congestion externality: it steals expected completions from the whole remaining night by the amount of the shadow price. So the static cost-quality optimal tiering built on the assumption that time is free is not optimal in front of a deadline. The earlier frontier of this series and the interactive routing literature are the same. As long as time is treated as an inconvenient variable, that judgment holds only in the slack regime.

### Saving a little on rerank does not work

The second result is the break-even of removing the rerank stage. The paper gives the break-even condition as a function of schedule pressure. But the answer is unexpected.

The break-even window of the stage-only skip that saves just one rerank call is empty. The wall time it saves is only the 0.73 seconds of the small model's rerank, so under realistic task densities the window stays below 1. Deadline pressure alone does not justify it. It has meaning only at the moment when a task that would miss the deadline on the small model is rescued by the tier with no LLM, T0.

By contrast, the full demotion that drops a task wholesale to a tier with no LLM saves 12 seconds and widens the window to about 5.00. The operational trigger (pressure 1.25) falls inside this window.

![Rerank-stage skip window: stage-only skip vs full zero-LLM demotion](/assets/images/posts/research/deadline-aware-overnight-agent-routing/fig2_skip_window_degeneracy.webp)
*The break-even window (omega), drawn as an analytical model overlay. The stage-only skip that saves only the rerank call (about 0.30) sits below the operational trigger (1.25), while the full T0 demotion (about 5.00) contains the trigger. That difference is the degeneracy that separates the two actions. It is an analytical example, not a measured value.*

The paper even gives the degeneracy result that separates these two actions mathematically. In plain words then: as the night pressure rises, the dispatcher's lever is not saving a little on the address recheck. It is removing the driver call entirely and dropping the parcel to the lobby.

### The tier rule that watches the deadline, DARP

The third result is DARP, the deadline-aware routing policy. Each task receives the tier that maximizes its expected completion credit. The credit is the pass probability, minus the time price times wall time, minus the cost price times the bill. An upgrade from the 8B student to the 27B teacher is justified only if the teacher's quality gain pays back both the extra tokens and the extra seconds.

The rule splits into three regimes. In slack (pressure below 1), time is free, and the rule returns to the quality-per-dollar flip condition of this series' Thinking Router. At the boundary (1 or above, below the rescue onset), the time term dominates, so student-first is optimal even when the big model wins on quality per dollar. In overload (at or above the rescue onset), survival comes first. The task is dropped to the fastest tier that finishes within deadline+grace. If it does not fit in T0 either, the task is deferred to the next night. Parameters like the 1.25 trigger, the 2.0pp accuracy guard, and the 45-second grace are all set to match the pre-registered measurement controls exactly.

In plain words then: when the truck is light, "send the driver with the best quality per dollar" holds as is. But once it starts to overflow, the rule changes. It becomes: pick a driver who can deliver by morning. Parcels that cannot be delivered by morning are carried over to the next day.

### The last unit is bought in two currencies

The fourth result attaches here. The very last unit of the night's output: in what currency do you buy it?

In slack, you pay dollars only. Quality is not touched, and only the tier bill is added. Near the knee, you pay the tier bill and quality together. As the overload deepens, the dollar price falls to 0. T0 bills nothing, and only the quality price remains. The point where the two prices cross is exactly the deadline knee (pressure 1).

![Two-currency price of the last unit of the night's work](/assets/images/posts/research/deadline-aware-overnight-agent-routing/fig3_two_currency_last_unit.webp)
*A conceptual example of Prop. 4 of the paper, drawn with the analytical model. The marginal price of the very last completed unit, expressed in the two currencies of dollars (tier bill) and quality (pass probability), is paid in dollars only in slack and in quality only in overload, and the two prices cross at the deadline knee (pr=1). It is a conceptual schema, not a measured value.*

The true optimal completion level is not the maximum completion count. It is the point where the quality price of the last unit does not cross the level an operator will tolerate. The paper compares this to the Laffer curve of the morning-deadline version.

In plain words then: the last parcel of the night is not bought with the driver's fare alone. You also pay "the probability of arriving exactly." The moment that probability falls below the tolerated level, there is no reason to add one more.

## So what changes

Two things change on the operations side. First, "does it finish by tomorrow" is lifted to a first-class goal of routing decisions. Once the frontier is measured a single time, an operator can quote a night of service in three axes: price, quality, and completion. The promise becomes a measured line rather than an endless estimate. When an operator of self-hosted AI infrastructure can guarantee by-morning completion at a measured price, the capital and trust barriers to putting unattended agents into real work fall. Second, prepare the lever for the overload regime. As pressure rises, what works is not saving a little on rerank. It is dropping a task, wholesale, to a tier with no LLM. The T0 tier sits on the same line as the move to harden validated agent behavior into deterministic workflows.

On the science side, a third dimension is added to the LLM model routing literature. The existing literature measured per-request cost, quality, and latency SLOs. This paper lifts deadline completion to a first-class goal for batch agentic workloads. It reports the cost-quality-completion frontier and the break-even of rerank-stage skip.

<!-- nlm-visual -->
![Key-concept summary infographic 2](/assets/images/posts/news/deadline-aware-overnight-agent-routing/en/nlm-infographic-2.webp)
*Infographic generated by NotebookLM from the sources.*

## What you cannot trust

First, this paper is clearly analytical. The deliverable is the deadline routing theory and the measurement design it sets up. The actual numbers of the frontier are the part that design estimates and audits on production H200. That is why every figure above is a prediction of the analytical model, not a measurement. Among the overlay numbers there are prior-paper measurements (cited), protocol control values (declared), and assumed values to be replaced by measurements (placeholder), and the paper marks this cell by cell.

There are five limits. First, the load is a fluid approximation, so wall time is an expectation and the theorems hold on an expectation basis. Residual variation is carried by the bootstrap intervals. Second, mid-task escalation is a separate lever and is excluded from this design. Third, there is a single worker, so with C workers the shadow price scales by roughly C times. The position of the knee moves, but its existence is preserved. Fourth, the cost axis is the declared rate, so energy and hardware amortization are not in it. The shape of the frontier only rescales linearly with the rate, so this is a property, not a limit. Fifth, as the skill registry drifts, p_i0 (retrieval-gate quality) changes and the skip window shrinks, so DARP must be recalibrated for each registry version. The fixed holdout design keeps that calibration auditable.

---

The paper's detail page and companion materials are available here: [The Morning Deadline](https://huggingface.co/datasets/thaki-AI/daily-paper-2026-10-28-deadline-aware-overnight-agent-routing)

*This paper is an analytical paper. The values in the body are predictions of the analytical model, not measurements, and the placeholder among the overlay numbers is an assumed value that a measurement will replace. The actual numbers of the frontier are filled in by the pre-registered measurement design on production H200.*
