---
title: "Keep the Model, Cut the Thinking: Routing Reasoning Effort Per Subtask"
seo_title: "Effort-Routing Paper Review: Per-Subtask Reasoning Effort Allocation in Multi-Agent Workflows | ThakiCloud"
seo_description: "A review of the Effort-Routing paper, which challenges the common practice of pinning a single reasoning-effort tier across every subtask in a multi-agent workflow. Covers a cost-savings model for the 'how much to think' axis separated from model choice, Proposition 1's decomposition of savings, a low-cost rule-based classifier, and a measurement protocol that has not yet been run."
excerpt: "Subtasks inside a workflow vary wildly in difficulty, yet orchestrators typically pin one reasoning-effort tier across all of them. This paper builds a cost model that quantifies that waste and states the conditions under which routing pays off, leaving execution for future work."
date: 2026-07-29
tags:
  - reasoning-effort
  - test-time-compute
  - 멀티에이전트
  - 에이전트-하네스
  - 토큰비용
  - LLM-라우팅
  - 비용-품질-트레이드오프
  - 워크플로-오케스트레이션
categories: [research]
author_profile: true
toc: true
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/research/effort-routing-multi-agent-cost/"
audiobook: "https://drive.google.com/file/d/1nzs3_d9jIZBeYdRQXL3kWlMZGoEI6oit/view"
audiobook_label: "▶ Listen: 5-minute briefing"
audiobook_note: "NotebookLM audio overview (AI-generated)"
---

If you run a multi-agent orchestrator and are trying to cut token costs, the question this paper takes on will sound familiar. A single workflow mixes subtasks as trivial as pulling a value out of JSON with subtasks that have to satisfy four interlocking constraints at once, and yet we usually pin the same reasoning-effort tier across all of them. The Effort-Routing paper works out, with equations, exactly where that habit wastes money, and sets the conditions under which a policy that lets each subtask think only as much as it needs actually saves. It is not, however, a paper that measured this policy in practice. The authors say up front that they have implemented neither a classifier nor an executor, and this post carries that admission forward rather than glossing over it.

![Illustration of the core idea of Keep the Model, Cut the Thinking: Routing Reasoning Effort Per Subtask](/assets/images/effort-routing-multi-agent-cost-hero.webp)
*A visual metaphor for the article's key idea.*

## Why every subtask gets the same amount of thinking time

Recent reasoning models let you dial a thinking budget on every call. In this repository's own Workflow harness, each `agent()` call can carry an `effort` parameter from low to xhigh, and ultracode mode defaults to the most expensive of those, xhigh. The problem is that there is no principle for tuning that knob per subtask. Operators typically pick one conservatively high tier, apply it to the whole workflow, and walk away, because a failure on the hardest subtask is the outcome they most want to avoid.

But when a subtask that parses a log for an error code sits next to a subtask that has to reconcile four mutually constrained requirements into a single migration plan, in the same workflow, buying both the same amount of deliberation is almost certainly wasted spend on the first one. If there is a cheap way to spot that waste in advance, and if the cost of figuring that out is smaller than the savings it unlocks, then a policy that assigns a different tier per subtask is justified. The paper starts by formalizing exactly when that condition holds and when it collapses.

Most prior routing work chose which model to use. This paper holds the model fixed and pulls "how much to think" out as a separate resource axis. That does not mean the two axes are fully independent. Later in the paper the authors walk back that framing as too strong, pointing out that routing to a smaller model can raise the effective difficulty of the same subtask, which in turn can push the required effort tier back up. The two axes are not independent so much as separately adjustable.

## Proposition 1: cutting the savings apart precisely

The paper's central tool is a single accounting identity. The authors decompose the cost difference Δ between a fixed policy and a routing policy into exactly two terms. One is the savings recovered by dropping easy subtasks to a lower tier. The other is the retry cost incurred when routing assigns too low a tier to a subtask and it fails.

![Conceptual diagram of per-tier cost and quality curves](/assets/images/posts/research/effort-routing-multi-agent-cost/fig-cost-quality-curves.webp)
*As the tier rises, expected cost C(e) increases while the success probability Q(d,e) saturates once it reaches the sufficient tier e*(d). This is a conceptual sketch of the paper's analytical model, not measured data.*

Two conditions fall out of this decomposition. The first is a necessary condition: if the set of subtasks the fixed tier actually over-provisions (the paper calls it O) is empty, routing can never win, because there is nothing left to downgrade regardless of how good the classifier is. The second is a sufficient condition, an inequality stating that the number of subtasks the classifier mis-routes to too low a tier must be smaller than the savings recovered from the subtasks it correctly downgrades. Turning that inequality into two measurable quantities, the count of wrongly-downgraded subtasks and the summed savings of correctly-downgraded ones, is the proposition's real contribution.

![Decomposition of savings: downtiering recovery versus correction retry cost](/assets/images/posts/research/effort-routing-multi-agent-cost/fig-savings-decomposition.webp)
*Δ splits exactly into the savings recovered from correct downtiering minus the retry cost incurred by under-tiering. This, too, is a diagram of the analytical model, not a measurement.*

The authors are careful to state this is not a dominance theorem. The necessary condition explicitly leaves room for routing to lose. They also offer a supporting argument that a convex savings curve makes the downtiering recovery larger, but they flag this as an empirical property that depends on a vendor's tier pricing, not a proven fact.

## A low-cost classifier, and a protocol that has not been run

Having established the conditions for savings, the paper proposes a rule-based classifier that predicts subtask difficulty. It has to read only the prompt before generation (so it can run without a model call), it has to be fast on the order of microseconds, and the reasoning behind its tier choice has to be readable directly from the trace. To satisfy those three constraints, the authors use a scoring function built from just three features instead of a trained classifier: word count, the number of matches against eleven sequencing markers (step, then, finally, and so on), and the number of matches against thirteen constraint markers (must, unless, at least, and so on). The weights and thresholds are all fixed in a single table, and the authors state explicitly that these are declared starting values, not tuned ones.

The measurement protocol places twelve subtasks across three small dependency workflows: log triage, spec reconciliation, and query repair. The reason these twelve are grouped into workflows with real data dependencies rather than laid out as twelve independent problems is that the paper's claim is specifically about subtask-level routing inside a decomposed workflow. A scattered single-problem benchmark could not test that setting.

![Twelve subtasks arranged across three workflows](/assets/images/posts/research/effort-routing-multi-agent-cost/fig-benchmark-structure.webp)
*Log triage, spec reconciliation, and query repair span twelve subtasks ranging from trivial to hard. This is a benchmark design diagram, not measured results.*

Six policy arms are laid out for comparison: a naive baseline that always fixes high, the cheapest single fixed tier chosen with hindsight, a classifier-free competitor that starts at low and retries once on failure, an oracle that assigns the true sufficient tier directly, random routing matched to the tier distribution the classifier actually produces, and finally the classifier-routing policy the paper proposes. The reason the authors include random routing is worth noting on its own: without it, there is no way to tell whether savings come from features correlated with difficulty or simply from a lower average tier. Without that comparison, the classifier has not proven anything about itself.

Here is the fact the paper itself emphasizes most, and it needs to be stated plainly. This protocol has not been run. No execution script exists in the repository, no classifier has been implemented, and nowhere in this paper does a savings rate, an accuracy number, or a dollar figure appear. Proposition 1 is an accounting identity that holds inside the cost model as defined. It is not a finding confirmed by experiment.

## What it leaves for the company, society, and science

From a company standpoint, if this formalization is eventually measured, it gives us grounds to add a new cost-savings axis, fully orthogonal to model-tier routing, to the jarvis Workflow pipeline. Since our pipeline and parallel stages already accept a per-call `effort` override, the integration cost of bolting on a classifier is low. Socially, if a policy that reaches the same quality with fewer thinking tokens is confirmed, it adds empirical weight to efforts to curb the inference cost and energy burden that grow as AI automation spreads. Scientifically, the authors themselves acknowledge that prior work such as RADAR already separated model size and reasoning budget into two axes, and they scope this paper's remaining contribution narrowly to three things: granularity at the level of subtasks inside a decomposed workflow rather than a single query, a rule-based classifier cheap enough to sit on the dispatch hot path, and instrumentation that measures tier cost curves on an actual production harness.

## Limitations, and the fact that none of this has been measured yet

The paper's own list of limitations is long and honest. The heaviest item is, again, the experiment that was never run. Proposition 1 is not a proven dominance theorem but a decomposition that holds under one particular retry convention, and its necessary condition explicitly leaves room for routing to lose. Because the rule-based classifier is not learned, it can misjudge prompts that are short but hard, or long but trivial, and the weights and thresholds fixed in that one table are declared values, not validated ones. The benchmark's twelve subtasks are too small to support fine-grained accuracy claims, and convexity is argued but not measured. Latency is left out of the cost model entirely, and the authors separately warn that if a subtask on the critical path gets delayed by a retry, token count can drop while the deadline is still missed. And the entire safety argument, they note explicitly, holds only for subtasks that have a deterministic checker. For subtasks like summarization or planning that a program cannot score, an under-tiered pass can produce an answer that looks plausible but is actually worse, without ever triggering a retry.

What the authors propose as the next step is clear: implement the classifier, build the executor, run the protocol as specified, and report the result honestly even if it turns out routing offers no benefit. This paper is not that experiment. It is the document that designed how that experiment should be run.

The full paper is available on [Hugging Face](https://huggingface.co/datasets/thaki-AI/daily-paper-2026-07-29-effort-routing-multi-agent-cost).
