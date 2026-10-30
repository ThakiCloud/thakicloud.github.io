---
title: "The Night Shift: A Paper That Puts the Break-Even Point and the Savings Ceiling, Against a Calibrated Heuristic, in Dollars for When an LLM Agent Directly Operates K8s GPU Queue Quotas and Node Scaling under Overnight Unattended-Agent Load"
seo_title: "The Night Shift: Autonomous K8s GPU Queue Operations by an LLM Agent, Provisioned-Cost vs Deadline-Reliability Frontier, Honest Bar, Break-Even L*=0.906 min, Kueue Quotas, Karpenter Node Scaling, FinOps, Self-Hosted Cluster - ThakiCloud"
seo_description: "ThakiCloud's analytical paper The Night Shift puts the break-even point in dollars for when an LLM agent directly operates Kueue GPU queue quotas and node provisioning under nonstationary overnight unattended-agent load. On the frontier comparing the three arms, static quota, calibrated threshold heuristic, and LLM agent controller, across the same night, the agent clears the honest bar only when the forecast gives 0.906 minutes of usable lead per burst, and the saturated savings are $6.52 per night (84.9% of the heuristic's insurance bill). The core is a break-even structure independent of actuation delay and inversely proportional to burstiness and horizon, a savings ceiling computable from telemetry, and a reproducible three-arm protocol over declared seeds."
excerpt: "Nobody watches the queue at night. Static Kueue quotas decide GPU capacity, and this paper puts in dollars, on the frontier of provisioned cost versus deadline reliability, where an LLM agent that directly operates those quotas and node scaling reaches break-even. It is an analytical paper, so no value in it is a measurement."
date: 2026-10-31
tags:
  - autonomous-k8s-operations
  - capacity-control
  - gpu-queue-management
  - cost-optimization
  - deadline-reliability
  - llm-agent-sre
  - kueue
  - overnight-automation
  - self-hosted-cluster
  - finops
categories: [research]
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/en/research/night-shift-k8s-capacity-agent/"
---

If you run unattended agents overnight to consume the GPUs of your self-hosted K8s cluster, or if you are a Korean cloud/AI engineer who carries the cost of Kueue queue and node scaling policies first-hand, this post is for you. Nobody is watching the queue at night, so static Kueue quotas and autoscalers tuned on daytime data decide GPU capacity. Until now there has been no framework for measuring what that decision costs in dollars per night, or where an LLM agent taking over that role starts to come out ahead. ThakiCloud's paper The Night Shift builds that framework. It pits three arms, static quota, calibrated threshold heuristic, and LLM agent controller, against the same night of demand and derives the frontier that compares provisioned GPU cost per completed unit as a function of deadline reliability, together with the break-even point on it.

The one-line conclusion: **the agent beats the calibrated heuristic only when the forecast gives less than one minute, exactly 0.906 minutes, of usable lead per burst.** When it does, the saturated savings are $6.52 per night, 84.9% of the heuristic's insurance bill.

One thing to make clear up front: this is an analytical paper. Every number in the body is one of three kinds, a declared protocol constant, exact arithmetic over those constants, or a range cited from external literature, and the paper labels each cell accordingly. The two figures below are of these same three kinds of calculation. Measurement is the job of the reproducible three-arm comparison protocol over declared seeds, and results run on an instrumented self-hosted cluster are reported in the companion study by the same team.

## At Night, Static Quotas Move the GPUs

From 23:00 to 07:00, unattended agent loops pour batch inference, training in progress, and evaluation sweeps into the Kueue queues that daytime traffic uses. Demand has a completely different shape from the day's. Burst episodes ride on top of diurnal baseline demand, so the same GPU pool idles in the morning and overflows at midnight.

This pressure shows up for real on ThakiCloud's own H200/H100 fleet. When the fastest GPU queue fills at midnight, new jobs get pushed down to the slower model tier, and the bottleneck is not the accelerators but the queue manager's quotas and blocked state. During the day an SRE can watch the queue. At night all that is left are the static quotas set before the lights go out and the thresholds tuned to daytime demand.

So should an LLM agent operate that capacity directly? Agentic SRE research has already moved a lot on the reactive axis. Benchmarks inject faults and score diagnosis and recovery success rates. Multi-agent recovery systems and agentic operations reviews around authority and safety have shown up too. The K8s agent line from the same team could already measure complexity-stratified incident recovery, serving-engine concurrency retuning, and the reclamation of GPU capacity that had stayed outside queue accounting.

All of those measurements are about after an incident has already happened, or they move only within fixed capacity. The axis where the queue admission quota and the node count themselves become levers for proactively moving cost is still open. With deadline reliability ρ held fixed, what does an agent controller spend per unit of work completed, and where does that cost cross the break-even point against a static policy and a well-calibrated heuristic? The Night Shift is the first to formalize this proactive economic axis.

## Three Arms Compare the Same Night

The paper casts the problem as a time-inhomogeneous MDP. The state is queue depth, the number of nodes that are on, the Kueue LocalQueue quota vector, and the forecast residual. Actions are restricted to hold, scale a node by 1, and set the quota vector. The cost at the end of the 8-hour night has three terms: the provisioned cost of GPU time that is on, penalties for jobs that exceed their deadline, and a decision bill that applies only to the agent arm.

The crux is the choice of what the cost means. What is billed is GPU time that is on. Under scale-to-fit semantics, a quota decision is a cost decision: if you hold a node up for queue headroom, it is billed whether or not that queue is actually used. A static policy keeps the pool on all night sized to the demand peak, while overnight demand mostly reverts to the mean, so a difference that was small by day becomes the size of the frontier by night.

The three arms are built as follows. P1 is static quota: node count and quotas stay fixed for the whole night, and nodes are sized to the overnight demand peak with zero margin. It is the policy the cluster actually runs when nobody is watching, and the reference point of the frontier. P2 is a calibrated threshold heuristic. An HPA-style controller reads utilization every 60 seconds, adds one node above 0.6, and removes one below 0.4. The heuristic goes through pre-run tuning against the declared demand regime. Existing research sets the honest bar (the honest baseline): the study in which a well-calibrated rule-based autoscaler beat all six mainstream deep reinforcement learning controllers on cost. P2's total burst response delay R is 6 minutes, 1 minute of detection plus 5 minutes of actuation.

P3 is the LLM agent controller. Every 180 seconds it hands a structured prompt, queue depth, utilization, the rate from the Metis token meter, the declared short-horizon forecast residual, and the current quota and node state, to a 27B-class instruct checkpoint served by local vLLM, and takes back the quota vector, node scaling, and the risk target κ* (one of the job deadline slack multipliers 1.5, 2.5, 3.5) as restricted structured actions. κ* acts as the admission buffer: a job enters the queue only if the expected queue delay stays within κ* times the remaining deadline slack. A metered bill of $0.001 per decision attaches, and a false alarm that gets reverted the next cycle is also captured at its declared cost (holding one GPU for 30 minutes).

![Night-shift control loop and three-arm comparison protocol](/assets/images/posts/research/night-shift-k8s-capacity-agent/fig_control_loop.webp)
*Overnight agent demand flows into the GPU queues managed by Kueue, and the three controller arms (P1 static quota, P2 calibrated threshold heuristic, P3 LLM agent) read the state and the forecast residual to move the quota vector and the number of provisioned nodes, with provisioned cost and deadline reliability aggregated into points on the frontier. Conceptual illustration (qualitative structure); it carries no quantitative claims.*

The comparison protocol is fixed so it is reproducible under declared demand and seeds. Overnight demand is declared as a synthetic Poisson process. Three bursts are laid on top of a diurnal baseline of 2.0 + 2.5sin(π(t - 0.5)/7.5) jobs per hour: excess 6/8/5 jobs per hour, duration 35/40/30 minutes, start 2.3/4.8/6.5 hours, seed 20261031. This shape is not a production trace reproduction. It is declared to match the operating pattern actually seen on the team's overnight fleet (daytime-based, manifest-based batch launches, model fallback surges). Runs total 14, two seeds per setting. P1 is a quota 3/5/8 sweep over the 8-GPU pool, P2 is a single setting, and P3 is a sweep over three risk targets. P3's decisions are real LLM calls, and call latency, token bills, and parse results are metered per call and included in the decision cost. Metrics recorded per run are deadline reliability ρ, admission delay p50/p95, and time-average and peak utilization. Provisioned GPU time and its dollars, the agent decision cost, and dollars per completed unit of work are also recorded.

## The Break-Even Point Is 0.906 Minutes of Forecast Lead per Burst

The analysis proceeds on the declared fluid model, as exact arithmetic over the constants. The declared constants are the 8-GPU pool, $2 per GPU-hour, service rate μ=2 jobs per GPU-hour, night length T=8 hours, burst excess b=8 jobs per hour, median duration τ_b=35 minutes, and minimum slack multiplier κ_min=1.5.

First, the static premium. Exact arithmetic over the declared trace puts the overnight mean demand at 4.91 jobs per hour and the peak at 12.43 jobs per hour. The peak-to-mean ratio r is 2.53, so a fleet that keeps the pool on all night without any scaling bills 2.53 times the mean-optimal cost. The static premium accounts for 60.5% of the static bill, and it is exactly the term every other arm competes against.

Second, the heuristic's insurance. For P2 to guarantee deadline reliability 1 against bursts with adversarial timing, it must hold a standing idle headroom h_h = bR/D that absorbs the response delay R=6 minutes. D is the total draining capacity that deadline slack and burst duration provide, converted into minutes and service rate; under the declared constants it is 100. The headroom is 0.48 GPUs, $7.68 per night. It is billed even on nights with weak bursts, because the heuristic cannot tell that a night's burst will be small.

The core result, the break-even, writes down how much of that insurance the forecast lead strips out. If the forecast gives L minutes of usable lead per burst, the agent's insurance shrinks to b·max(R-L, 0)/D and the night cost is g·T·b·max(R-L, 0)/D + OV. The condition for the agent to clear the honest bar is exactly L ≥ L*, with L* = OV·D/(g·T·b) minutes. Under the declared constants, the decision bill OV is $1.16, 160 decisions at $0.001 each per night plus one false alarm at $1.00, and L* is 0.906 minutes.

The shape of this number matters more in the body. L* is independent of the actuation delay R. If node actuation takes long, the heuristic's insurance cost and the value of the agent's lead grow by the same ratio, and the baseline stays where it is. The cited GPU bring-up of 2 to 10 minutes is, if anything, an asset for the agent arm. L* shrinks as burst excess b and horizon T grow, and is linear in the decision bill OV. At L=0 the agent loses exactly OV: an agent controller without forecast lead is nothing but the heuristic with its own bill attached. That is the paper's built-in negative-result guard.

![Break-even structure: heuristic insurance bill vs agent cost and net advantage](/assets/images/posts/research/night-shift-k8s-capacity-agent/fig_breakeven.webp)
*The calibrated heuristic's flat $7.68 per-night insurance bill, the agent's night cost falling from $8.84 at lead L=0 to the decision bill $1.16 at L=R=6 minutes, and the net advantage that crosses zero at the honest bar L*=0.906 minutes and rises to $6.52 per night at saturation (84.9% of the insurance). Exact arithmetic over the declared constants; an analytical model, not a measurement.*

Once the lead reaches R=6 minutes or more, the net advantage saturates. $6.52, the insurance $7.68 minus the decision bill $1.16, 84.9% of the heuristic's insurance, is the maximum per-night savings.

The shape and the ceiling of the frontier come out with it. The savings S(ρ) fall as ρ rises, in every arm. The agent's relative advantage is negative at low ρ, because only its own bill remains. At high ρ it vanishes, because every arm buys the last reliability points at superlinear cost. The relative advantage is largest in the mid-to-high ρ region where insurance capacity dominates the bill. The agent moves the operating point along the frontier; the shape of the frontier does not change. And the agent's total advantage is capped from above by the forecast lead value plus the cross-queue idle overlap term. Both terms are computable from telemetry alone, so the frontier carries an auditable ceiling. If measured savings exceed this ceiling, it means the metering is wrong.

## What the Company Gets First, and What Remains for Society and Science

ThakiCloud does not set this problem up as somebody else's case. Overnight capacity pressure shows up for real on its own H200/H100 fleet. On the night of September 1, 2026, the b200 queue filled to 8/8 and forced the h100 fallback, and the Kueue quotas and blocked queue state are visible as-is in the team's own gpu_queue.py. The Metis token meter and the demo cluster already have the instrumentation needed to run this protocol. The follow-up measurement checks the agent controller's admit/scale/idle policy: whether it cuts GPU time and dollars per completed unit, and whether it takes the SRE's overnight triage of full queues out of the loop.

On the society side, it provides a measurable form of the point that autonomous capacity operation cuts idle GPU waste and energy, for economic purposes and not only for safety. In organizations that run self-hosted AI infrastructure, when overnight unattended agent work becomes cheaper and more predictable, the power bill and the billed cost come down together.

On the science side, it adds a proactive axis to agentic SRE measurement. If existing measurement prices the reactive axis, incident diagnosis and recovery success rates, this paper prices a different object. It treats the LLM agent as a proactive capacity and cost controller under nonstationary demand, and decomposes the frontier of cost savings against deadline reliability into admission delay, utilization, SLO violations, and dollar cost. A framework that reports this frontier as a controlled measurement is the first case in the existing literature. The static/heuristic/agent three-arm comparison protocol is reusable on other clusters. Where the reactive-axis literature scores the agent by incident, this protocol scores the night by dollars per completed unit.

Giving the agent the authority to move capacity is also a safety question. The protocol ties that authority down in three ways. The action set is structured, quotas stay within the pool, and scaling is limited to ±1. A deterministic guard rejects emergency scale-downs, and a hard floor is placed on provisioned capacity while a queue is active. Every action is logged with its telemetry context.

## What This Paper Does Not Claim, and Its Limits

The paper does not claim that the agent arm wins. It only claims that an auditable answer in dollars exists for this question. The baseline is P2 (the calibrated heuristic), the lead statistic is L, the break-even is L*=0.906 minutes, and the ceiling is the savings ceiling computable from telemetry; all four names are pinned down.

There are five limits. First, demand is a declared synthetic trace. It is matched to the operating pattern of the team's overnight fleet, not a production reproduction. Calibrating it is the follow-up work. Second, the GPU price g and the LLM call unit price are declared constants. Since L* is inversely proportional to g, the honest bar is most conservative at the highest possible GPU price. Third, the agent's reliability is included in the decision bill. Parse failures and delays are all metered, and a decision that exceeds the 180-second budget is no-action. Fourth, P2 is a single queue. Once a multi-queue-aware heuristic appears, the cross-queue idle overlap channel shrinks. Since the ceiling comes from telemetry, that retreat is visible, not hidden. Fifth, the entire break-even stands on L. If the overnight manifest is unpredictable out beyond L*, the agent loses exactly its own bill, and the protocol is set up to measure L per burst.

The two figures and every number in this paper are the declared constants and the exact arithmetic over them. The measured frontier is the job of the three-arm protocol over declared seeds, run on an instrumented self-hosted cluster.

---

The paper's detail page and companion materials can be viewed here: [The Night Shift](https://huggingface.co/datasets/thaki-AI/daily-paper-2026-10-31-night-shift-k8s-capacity-agent)

*This is an analytical paper. Every value in the body is a declared protocol constant, exact arithmetic over those constants, or a cited range; none is a measurement. The measured frontier comes out as the result of running the three-arm comparison protocol on an instrumented self-hosted cluster in the follow-up study by the same team.*
