---
title: "In a Multi-Machine Agent Harness, a Skill Can Go Silently Dark and No One Notices"
seo_title: "Drift Detection in Agent Harnesses: Session Checks vs Periodic Sweeps Compared"
seo_description: "We measured silent drift, where skills and rules quietly turn off in a multi-machine agent harness, using 20 fault-injection simulations. We explain why periodic sweeps beat session-triggered checks at detecting it, using the inspection paradox from renewal theory."
excerpt: "Even with identical average check intervals, a periodic sweep cuts drift-detection time in half compared to a session-triggered check. We introduce a paper that explains why with 20 fault-injection simulations and the inspection paradox from renewal theory."
date: 2026-08-13
tags:
  - agent-harness
  - distributed-systems
  - drift-detection
  - self-healing
  - reliability-engineering
categories:
  - research
author_profile: true
toc: true
lang: en
canonical_url: https://thakicloud.com/tech-blog/en/research/skill-state-drift-self-healing/
---

If you run the same agent harness across multiple machines and have ever had a skill or rule quietly turn off on one of them while work kept going anyway, this post is about exactly that problem. In a multi-machine harness that toggles skills and rules on and off with symlinks, this paper answers, using 20 fault-injection simulations, which detects drift faster: checking state every time a session starts, or sweeping the whole system on a fixed schedule. The short answer: even when the average check interval is exactly the same, a periodic sweep cuts detection time in half compared to a session-triggered approach. And the reason is not luck. It is the inspection paradox from renewal theory.

## The Problem of Silent Capability Loss

Modern LLM agent harnesses no longer cram every capability into the prompt. Instead they pull capability out into version-controlled files: reusable skills and always-on behavioral rules live as files in a repository, and the harness decides at runtime which of them to show the agent. On a single machine, this decision is simple: use everything the repository has. Once you have multiple machines, that changes. The same repository gets cloned onto a personal workstation and an organizational one, and the two environments have different requirements. A skill that is appropriate on one may be inappropriate, or even a policy violation, on the other.

A two-layer design falls out of this naturally. A small, version-controlled manifest, a machine-scoped registry, declares what should be active for which class of machine. And a per-machine toggle layer records what is actually turned on. The key move here is implementing the toggle with a lightweight filesystem indirection, the presence or absence of a symbolic link, rather than deleting content outright, because deleting content destroys the audit trail and makes reverting expensive.

This design is attractive because it is cheap, reversible, and easy to inspect, but it has one structural weakness: the two layers can drift apart. The registry syncs through git, so it converges quickly, but the toggle layer is machine-local and deliberately kept out of version control, precisely to stop an act of turning something off on one machine from propagating to the other as a deletion. In exchange, this layer can be knocked out of sync by manual intervention, partial syncs, a hostname change, or a race between concurrent sessions on the same machine. When this drift happens, nothing dies. The agent still runs, still produces answers, still produces output that looks plausible. It just does so without a capability it should have had, or with one it should not have had. The paper calls this phenomenon silent capability loss, and the defining trait of this failure mode is that it stays invisible unless you specifically instrument for it.

## How the Experiment Was Designed

The recovery mechanism the paper's target repository uses is a self-healing check: it compares local toggle state against the registry and fixes every mismatch it finds, and by convention it fires at session start. Since that is already the moment the agent is booting up anyway, it piggybacks naturally on a cost that is already being paid, and there is an intuition that every session starts from a verified state. The authors show this intuition is interestingly wrong.

To test this, the authors built a controlled fault-injection simulation. They set up 5 machines, 50 skills and rules per machine, 250 total state cells, and let each cell drift independently with probability 0.0002 at each of 2000 steps. Then they pitted two detection strategies against each other under exactly matched conditions. The first, Eager, scans only that machine's cells every time a session starts on it, with a session starting at each machine at each step with probability 0.05. The second, Sweep, scans all 5 machines, all 250 cells, together every 20 steps.

There is a key design choice here. The session probability, 0.05, was chosen precisely so the average wait time is exactly 20 steps, matching Sweep's fixed 20-step period. That is, the two strategies' average per-machine check interval is made perfectly identical before comparing them. This rules out, from the start, the objection that one strategy wins simply by checking more often. The simulation ran across 10 seeds each, 20 runs total per strategy, in roughly 100 lines of pure Python, single-core CPU, no GPU, since this is a state-management experiment, not a model-inference experiment.

## Result: Same Average Interval, Sweep Is Twice as Fast

The measurement is unambiguous. Sweep's average detection lag is 9.41 steps; Eager's is 19.23 steps, a 51% difference, despite both strategies sharing an identical per-machine average check interval of exactly 20 steps. The tail lag gap is even wider. Eager's 95th-percentile lag swings from 41 to 78 steps depending on seed, while Sweep sits consistently between 17 and 19 steps across every seed. The reason is structural. Eager's worst case is unbounded in principle: a machine that rarely starts a session has no triggering event at all for a check, so it can sit neglected for an arbitrarily long time. Sweep's worst case, by contrast, is structurally capped at W=20 steps, and the measured p95 of 17 to 19 steps sits right up against that cap.

![Mean and P95 detection lag compared between session-start checks and periodic sweeps](/assets/images/posts/research/skill-state-drift-self-healing/fig-latency-comparison.png)
*Measured results aggregated over 10 seeds, T=2000 steps, and 250 state cells in a CPU-only container. Eager's p95 ranges from 41 to 78 steps by seed; Sweep's p95 is consistent at 17 to 19 steps across every seed.*

There is also an honest caveat here. Sweep does not win on every axis. The false-negative rate is 1.30% for Eager and 1.40% for Sweep, and residual drift at the end of the run is 0.8 and 0.9 cells out of 250, respectively. At 10 seeds, this difference is not statistically distinguishable, and what direction it does lean does not even favor Sweep. Both strategies eventually catch roughly 98.6 to 98.7% of drift events within the run window, and the residual that remains is mostly events injected just before the run ended, which never had a chance to be caught in the first place. What Sweep wins on is latency and its variance, not detection completeness.

## Why Sweep Wins: The Inspection Paradox

Explaining why this gap appears at identical average intervals requires looking at variance. Sweep's check interval is deterministic: exactly 20 steps every cycle, variance zero. Eager's check interval is the waiting time between independent Bernoulli trials with success probability 0.05, that is, a geometric distribution. Its expectation is 1/0.05 = 20, exactly matching Sweep, but its variance is (1-p)/p^2 = 380. Once this variance feeds into the second moment, Eager gets E[T^2] = 380 + 400 = 780, while Sweep gets E[T^2] = 400.

What matters here is that a drift event does not happen precisely at a check boundary. It gets injected at some arbitrary point inside an ongoing check interval, and what we actually measure is the wait from that point to the next check, the forward recurrence time. Renewal theory gives the expected residual lifetime seen from a randomly inserted point as E[R] = E[T^2] / (2E[T]). Except in the deterministic case, this differs from half the average interval. Plugging in Sweep gives 400/40 = 10; plugging in Eager gives 780/40 = 19.5, and the measured values of 9.41 and 19.23 line up closely with these predictions. The ratio of the two, 780/400 = 1.95, is essentially the same number as the roughly 2x gap actually measured.

![Renewal-theory calculation showing how variance in check interval creates the latency gap](/assets/images/posts/research/skill-state-drift-self-healing/fig-inspection-paradox.png)
*A calculation applying renewal theory's residual-lifetime formula, E[R] = E[T^2] / (2E[T]), directly. Deterministic Sweep gives 20^2/(2*20) = 10, and geometrically-distributed Eager gives 780/(2*20) = 19.5, matching the measured gap (9.41 versus 19.23) precisely.*

This phenomenon is the classic inspection paradox, also known as the bus-waiting-time paradox. An irregular, memoryless arrival process is size-biased from a random observer's point of view: you are more likely to land inside a long interval than a short one, because a long interval occupies more of the timeline. So expected wait time inflates beyond half the average, even when that average matches a deterministic schedule exactly. It is also worth noting that what Eager does every session amounts to nearly the same total work as Sweep in aggregate. Eager checks about 495.8 times per run, each time scanning 50 cells on a single machine, for a total of 24,790 cell comparisons. Sweep checks about 99.0 times per run, each time scanning all 250 cells, for a total of 24,750. The difference between these two totals is under 0.2%. Sweep simply compresses that same work into one-fifth as many check events.

![Overhead comparison split between number of check events and number of cell scans](/assets/images/posts/research/skill-state-drift-self-healing/fig-overhead.png)
*Total comparison work is nearly identical, 24,790 for Eager versus 24,750 for Sweep, but the number of check events differs sharply, 495.8 for Eager versus 99.0 for Sweep, one-fifth as many. This means Sweep cuts the fixed per-event overhead, process startup, session-start-hook latency, and the token cost of reporting the result, to one-fifth.*

The practical rule that falls out of this is cheap and general. If you are piggybacking a state check on a high-variance event like a deployment, a request, or a login, switching to a fixed-period timer with the same average rate cuts detection lag roughly in half. It leaves total check workload unchanged and removes only the inspection-paradox penalty that comes from variance. The authors stress, though, that the two strategies are not mutually exclusive. Leaving the session check in place as an essentially free, opportunistic supplementary layer, while handing the job of bounding worst-case exposure time to a fixed-period sweep, is a sensible hybrid for real deployments.

## What This Means for ThakiCloud and Beyond

This research grew directly out of a failure mode we ourselves experienced running our own multi-machine harness, an operating environment split across a home machine and an office machine and driven by launchd runners. The incidents already logged in our machine-scoped-jobs and skill-worktime-gate rules are exactly instances of this silent capability loss, and this research quantifies that and turns it into a reusable drift-audit and self-healing protocol that can be applied to other internal harnesses as well. More broadly, as more organizations run agent harnesses across multiple machines and environments, laptops and cloud, dev and production, configuration drift becomes a structural reliability risk that currently has no established measurement methodology of its own. Because the approach this paper proposes is not tied to any particular infrastructure, it applies as-is beyond LLM agents, to any distributed feature-flag or configuration system.

Scientifically, this research is, to our knowledge, the first to quantitatively characterize state-consistency failure and self-healing convergence time specific to agent capability harnesses. Related work has measured behavioral consistency in agents, whether repeating the same task produces the same tool calls, but that is a property of the model's stochastic policy. The state consistency this paper measures sits on an orthogonal axis: a problem that can exist even if the model itself is fully deterministic. The classic distributed-systems literature on self-healing and eventual consistency does not model the agent session itself as a healing trigger, and that is exactly the gap this paper newly identifies.

## Limitations

The authors are explicit about what this research does not prove. Drift is modeled as an i.i.d. Bernoulli process independent per cell, but real drift is likely to cluster. Events like a bad merge, an interrupted sync, or a hostname change that invalidates machine-class interpretation can knock multiple capabilities out of sync on one machine at once, and if that correlation exists, the relative advantage between the two strategies could shift in either direction. The simulation also only handles a single policy vector shared across all machines, and does not address the per-machine-class registry conflicts that show up in actual production.

The parameters were also tested at exactly one point, session probability 0.05 and sweep period 20, chosen precisely to match the average interval, and widening this ratio into a grid to look for a crossover point is left as future work. Above all, these results come from a controlled simulation, not real production incident data. Absolute latency figures should be read as ratios and shapes, not as predictions that will reproduce exactly in production. Finally, the comparison is limited to just two strategies, Eager and Sweep; alternatives such as hybrid schedules, adaptive periods, or escalation based on drift severity were not covered in this experiment.

Detailed paper information is available here: [https://huggingface.co/datasets/thaki-AI/daily-paper-2026-08-13-skill-state-drift-self-healing](https://huggingface.co/datasets/thaki-AI/daily-paper-2026-08-13-skill-state-drift-self-healing)
