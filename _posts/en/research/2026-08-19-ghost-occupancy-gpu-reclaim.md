---
title: "Ghost Occupancy Detector: A Multi-Signal Protocol for Safely Reclaiming Idle GPUs in a Kueue Cluster"
seo_title: "Ghost Occupancy Detection: How to Safely Reclaim Phantom GPU Occupancy in a Shared GPU Cluster"
seo_description: "A multi-signal protocol catches GPU occupancy that Kueue's queue accounting can't see. Utilization alone leaves false positives against active jobs, but adding process count drives the false-positive rate to exactly zero."
excerpt: "The queue reads full while the node has room to spare. That gap is ghost occupancy invisible to queue accounting. A multi-signal detection protocol shows, with measurement, how to reclaim it without killing active jobs."
date: 2026-08-19
tags:
  - ghost-occupancy
  - gpu-reclamation
  - kueue
  - kubernetes-scheduling
  - idle-workload-detection
  - multi-signal-protocol
  - autonomous-agent
  - quota-accounting-gap
  - cluster-ops-automation
  - multi-tenant-gpu
categories: [research]
author_profile: true
toc: true
audiobook: "https://drive.google.com/file/d/1U12KMRdbc6TF_JrfJhMrBju4qLU8JQWp/view"
audiobook_label: "▶ Listen: 5-minute briefing"
audiobook_note: "NotebookLM audio overview (AI-generated)"
canonical_url: "https://thakicloud.com/tech-blog/en/research/ghost-occupancy-gpu-reclaim/"
---

If you've run a cluster where Kueue manages the GPU queue and seen a dashboard reading "8/8 full"
when there's clearly room to spare, this paper is worth reading. Published today by ThakiCloud AI
Research, it addresses GPU occupancy that a queue manager can never see: Deployments that have
finished or died but are still holding their spot. The conclusion isn't simple. Sampling
utilization alone, no matter how many times you sample, never fully eliminates the risk of killing
an active job. Only adding a completely different axis, process count, drives that risk to exactly
zero.

![Illustration of the core idea of Ghost Occupancy Detector: A Multi-Signal Protocol for Safely Reclaiming Idle GPUs in a Kueue Cluster](/assets/images/ghost-occupancy-gpu-reclaim-hero.webp)
*A visual metaphor for the article's key idea.*

## The queue is accurate, but the GPU is already gone

Kueue only tracks Jobs it has admitted. Within that scope, accounting is accurate. The problem is
Deployments and StatefulSets. Whether it's a notebook session, a serving endpoint, or an
experimental pod, these objects never go through Kueue's admission path at all. Once a pod is
scheduled, it keeps holding the GPU whether or not the process inside it is doing anything.

Two failure modes recur here. One is a researcher launching a Deployment, the experiment
finishing, and nobody tearing it down. Since it was never in Kueue's ledger to begin with, nothing
looks wrong. The other is the process inside the container dying, typically because the GPU driver
faults, leaving the container reading as "Running" to Kubernetes while it actually does nothing at
all. In both cases, the resource picture the queue sees is wrong. The paper calls this discrepancy
the quota-accounting gap and is the first to formalize it. On a cluster where a handful of
expensive GPUs are shared across teams, a few of these ghost occupancies alone are enough to split
the difference between a job that schedules immediately and one that waits indefinitely behind
resources that don't exist.

## A problem that only resolves into three branches

The solution that comes to mind first is automation that periodically scans for Deployments that
look idle and deletes them. Easy to say, dangerous to build carelessly. GPU utilization isn't a
clean binary signal. Even a job running normally dips briefly toward zero when the dataloader
stalls, when it crosses a batch boundary, or while it's writing a checkpoint. The paper names this
the batch gap, and points out that a detector unable to distinguish that brief zero window from
real idleness will eventually delete a live job.

So the paper splits occupancy into three branches. ACTIVE is a genuinely live, in-progress job,
where the process stays alive even during a batch gap. FINISHED_IDLE is a Deployment whose work
finished but never scaled down, where utilization sits pinned at zero with no process left.
ZOMBIE_CRASHED is a case where the driver faulted and killed the process but the pod remains.
There's one tricky spot here. About one in four zombie containers leaves behind a defunct child
process the crashed driver failed to reap. A criterion that looks only at process count can't tell
this small subset of zombies apart from active jobs, and that's exactly where the recall loss
discussed later comes from.

![Safety versus recall trade-off](/assets/images/posts/research/ghost-occupancy-gpu-reclaim/fig1-safety-coverage.png)
*Averaged across 5 seeds times 2,000 instances. The two utilization-only detectors have perfect recall but leave a false-positive rate behind. Widening the observation window shrinks the false-positive rate from 10.93% to 3.50%, but never reaches zero. Only the combination that also checks process count and output growth reaches zero, at the cost of 6.10 points of recall. This experiment was measured on CPU-only containers.*

## Why five samples still don't reach zero

The most interesting part of the paper is the arithmetic. A detector using a five-sample window
that requires all five readings to be zero before flagging something for reclamation cuts the
false-positive rate from 10.93% to 3.50%. Stop there and you'll want to widen the window further.
But a batch gap isn't a property of an individual reading, it's a property of the instance's
overall state. If a job has a 15% chance of hitting a batch boundary, and within that window each
reading has a 1/4 chance of being nonzero, then the probability all five reads come back zero is
0.15 times (3/4)^5, or 3.56%. That's 214 out of 6,000 ACTIVE evaluations, close to the 210 the
paper actually observed. Each time you widen the window, the remaining false positives shrink only
by a fixed ratio of 3/4, an exponential decay that approaches zero but never reaches it. Wait time,
meanwhile, just grows in proportion to window length.

![210 remaining false positives from the utilization-only detector](/assets/images/posts/research/ghost-occupancy-gpu-reclaim/fig2-false-positives.png)
*Pooled count across 5 seeds. All 210 remaining false positives from the utilization-only detector trace back to the batch gap. When a job spends its entire window inside a gap, all five readings come back zero. The combination that also checks process count doesn't statistically reduce this false-positive rate, it eliminates it structurally, because a batch gap never touches whether the process is alive. This experiment was also measured on CPU-only containers.*

## Asymmetric cost and multi-signal detection

The paper establishes one principle. Wrongly deleting a live job, a false reclaim, costs
differently than reclaiming a dead resource one cycle late, a false keep. The latter simply gets
reconsidered at the next poll. The former is irreversible. So the paper sets false-positive rate,
not accuracy or F1, as the safety metric, and only compares recall among detectors that push that
metric as close to zero as possible.

The multi-signal protocol is this principle translated into code. It flags something for
reclamation only when all five utilization readings are zero, there is not a single live process
inside the container, and output size hasn't grown while the window was open. Across the benchmark
of 10,000 instances (5 seeds times 2,000, split 60% ACTIVE / 30% FINISHED_IDLE / 10%
ZOMBIE_CRASHED), this combination recorded zero false positives across all 6,000 ACTIVE
evaluations. Active jobs always keep between one and four processes alive even during a batch gap,
so no matter what utilization reads, they can never satisfy the process-count condition. The cost
is a recall of 93.90%. It misses 244 of the 4,000 reclamation targets, most of which happen to be
zombies whose defunct child process was still alive.

## Accuracy alone leads to the wrong choice

Read the table at face value and the multi-signal protocol doesn't look like the best detector.
Its accuracy, 97.56%, sits below multi-sample utilization alone at 97.90%. But accuracy is a
metric that averages away asymmetric cost, so it scores higher for a detector that kills a live
job roughly one time in twenty-nine. This is exactly the point the paper stresses. Accuracy can't
be the deployment criterion for this problem. Only precision, which isolates the irreversible
cost, correctly separates the two detectors.

![Where accuracy flips the deployment ranking](/assets/images/posts/research/ghost-occupancy-gpu-reclaim/fig3-accuracy-misleads.png)
*The multi-signal protocol is not the most accurate detector. Multi-sample utilization leads on accuracy, 0.9790 versus 0.9756. Because accuracy averages away an asymmetric cost structure, it actually favors the detector that kills a live job roughly one time in twenty-nine. Precision, which isolates only the irreversible cost, is the real metric that separates the two detectors. This experiment was also measured on CPU-only containers.*

## The agent gathers signals, the code decides

The most practical design decision in this paper is drawing a sharp line around what the LLM
agent is responsible for. Querying utilization metrics, exec-ing into a container to count the
process list, and comparing object-storage listings are each tasks where interfaces differ tool to
tool and output is messy. Cleaning up these heterogeneous tool calls into three normalized
features is exactly the kind of thing an agent is good at. But looking at those features and
deciding in natural language that "this Deployment looks idle" is not left to the agent. A single
fixed logical AND decides whether to reclaim. The reasons: feeding it the same signals twice
always produces the same conclusion, the false-positive rate can be measured exactly, and failure
modes can all be enumerated in advance. Binding pre-execution judgment to deterministic code this
way also lines up with recent safety research on agents that take irreversible actions.

It's also worth noting that checking the process list requires exec access into the container.
That's an area where the access is powerful and the risk is correspondingly high, and the paper's
position is that it should be narrowed to read-only process listing with credentials scoped per
namespace.

## Limits and the next experiment

The paper names four of its own limits. First, this is a controlled synthetic benchmark, not a
field trial run on a real cluster. Second, the roughly 6% recall loss the multi-signal protocol
gives up is a real operational cost, and whether it's tolerable depends on polling frequency and
how starved the cluster is for resources. Third, the paper proposes a fourth signal, whether
output upload has completed, but never uses it in evaluation. Fourth, the class ratio of 60%
ACTIVE / 30% FINISHED_IDLE / 10% ZOMBIE_CRASHED is a modeling choice, not a measured one.

As a next step, the paper proposes attaching this decision rule to a real cluster in read-only
shadow mode, logging only what it would have reclaimed, as a validation experiment. Only a shadow
trial like that can answer whether the missed 6.10% is delay that resolves itself on the next
cycle, or a structural loss where the same zombies with surviving defunct children keep getting
missed every time.

Full paper details and the original text are available here: [https://huggingface.co/datasets/thaki-AI/daily-paper-2026-08-19-ghost-occupancy-gpu-reclaim](https://huggingface.co/datasets/thaki-AI/daily-paper-2026-08-19-ghost-occupancy-gpu-reclaim)
