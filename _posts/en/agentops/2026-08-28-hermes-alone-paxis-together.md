---
title: "The tool that is enough alone, and short as a team"
seo_title: "Same in-house 245k model, two agents, one task - what each leaves behind | ThakiCloud"
seo_description: "We pointed a local Hermes desktop and Paxis at the same in-house Qwen3.8-27B NVFP4 245k endpoint and gave both the same two pieces of real company work. The answers matched. The records did not. Screen recordings plus ledger queries for audit events, per-call execution traces, and skill matching."
excerpt: "Two products, one model, identical answers. One left rows saying who asked for what and which model spent how much. The other left a conversation."
date: 2026-08-28
tags:
  - Paxis
  - Hermes
  - agents
  - audit log
  - execution trace
  - self-hosted
  - Qwen
  - AgentOps
categories: [agentops]
author_profile: true
toc: true
toc_label: "Contents"
toc_sticky: true
reading_time: true
canonical_url: "https://thakicloud.com/tech-blog/en/agentops/hermes-alone-paxis-together/"
---

If you run a local agent against your own model and work mostly by yourself, the tool you already have is probably enough. That is what we found. The split is not answer quality. It is what the answer leaves behind.

We pointed the Hermes desktop app at our in-house endpoint. The model is `thakicloud/Qwen3.8-27B-NVFP4-GPTQ-txt-245k-dflash`, an arm serving a 245,760 token context. We selected that same model in the Paxis model picker. Then we handed both the **same prompt** for two procedures that actually run in our company. One decides whether a spending request exceeds its remaining budget. The other merges monthly KPIs that every team reports in a different shape.

![One model behind two very different interfaces](/assets/images/hermes-alone-paxis-together-hero.webp)
*The same endpoint feeds a chat log on one side and a queryable ledger on the other.*

## First task: budget check on spending requests

We supplied remaining budgets for three cost centers and three requests, and asked for an approve or reject verdict per item. Arithmetic settles the answer. DOC-8841 asks for 4,500,000 against 3,200,000 remaining, so it is over by 1,300,000. DOC-8842 asks for 21,000,000 against 31,500,000, so it passes. DOC-8843 asks for 300,000 against 50,000, so it is over by 250,000.

Here is Hermes.

<video controls muted playsinline preload="none" poster="{{ site.url }}{{ site.baseurl }}/assets/images/hermes-245k-budget-poster.jpg" style="max-width:100%">
  <source src="{{ site.url }}{{ site.baseurl }}/assets/videos/posts/hermes-245k-budget.mp4" type="video/mp4">
</video>

The same prompt in Paxis.

<video controls muted playsinline preload="none" poster="{{ site.url }}{{ site.baseurl }}/assets/images/paxis-245k-budget-poster.jpg" style="max-width:100%">
  <source src="{{ site.url }}{{ site.baseurl }}/assets/videos/posts/paxis-245k-budget.mp4" type="video/mp4">
</video>

All three verdicts matched, and the overage figures matched to the won. This post is not an attempt to decide which one is smarter. Both ran on the same model, so matching was close to expected.

## Second task: rolling up team KPIs

Sales, engineering and support each sent August figures in their own format. We asked for one standard table with month over month change. Units are mixed, and some metrics are better when they go down.

<video controls muted playsinline preload="none" poster="{{ site.url }}{{ site.baseurl }}/assets/images/hermes-245k-kpi-poster.jpg" style="max-width:100%">
  <source src="{{ site.url }}{{ site.baseurl }}/assets/videos/posts/hermes-245k-kpi.mp4" type="video/mp4">
</video>

<video controls muted playsinline preload="none" poster="{{ site.url }}{{ site.baseurl }}/assets/images/paxis-245k-kpi-poster.jpg" style="max-width:100%">
  <source src="{{ site.url }}{{ site.baseurl }}/assets/videos/posts/paxis-245k-kpi.mp4" type="video/mp4">
</video>

Both produced nine metrics in one table and both concluded that exactly one figure got worse, sales contract value falling 7.7 percent. Both also flagged direction correctly for the metrics where lower is better.

## Where they diverged

After the turns finished we opened both stores. This is the part that matters.

Paxis prints a receipt under the answer. Which agent ran, on which model, for how many turns, with input and output token counts, plus the trace identifier for that run. The budget case was 2 turns in 13.8 seconds, 24,411 tokens in and 2,374 out. The KPI case was 2 turns in 9.0 seconds, 23,467 in and 1,736 out.

Underneath, the ledger keeps one row per call. Pulling the calls from a single budget turn in time order gives this.

| Time | Model | In | Out | Latency |
|---|---|---|---|---|
| 09:38:19 | paxis-distill-8b | 2,728 | 100 | 715ms |
| 09:38:20 | Qwen3.8-27B NVFP4 245k | 7,076 | 238 | 1,143ms |
| 09:38:21 | Qwen3.8-27B NVFP4 245k | 8,451 | 270 | 1,177ms |
| 09:38:22 | Qwen3.8-27B NVFP4 245k | 9,437 | 1,132 | 2,291ms |
| 09:38:25 | Qwen3.8-27B NVFP4 245k | 8,099 | 1,109 | 3,356ms |

The first row stands out. One routing classification went to a distilled 8B, and every call that actually wrote the answer went to the 245k model. What matters is less that we designed it that way and more that **the fact can be pulled into a table later**. When a bill looks wrong you can name the call responsible, and when an answer is wrong you can name the model that wrote the sentence.

Audit events accumulated separately over the same minutes. `agent.routing.grounded`, `subagent.dispatched`, `subagent.completed` and `agent.tool.invoked` all landed as rows, and tool invocations carry an actor (`dev-hyojung`). The table holds 15,135 rows so far, of which 101 are `agent.tool.blocked`, meaning policy actually stopped a tool. This is a table, not a log file, so it answers queries.

We opened the Hermes store the same way. Sessions and messages persist, along with a per session model usage rollup. The budget case took 9 API calls with 126,861 tokens in and 2,442 out. The KPI case took 4 calls with 48,477 in and 983 out. That is useful. What is not there is any table named for audit, policy, permission or approval. The count is zero.

## This is not a flaw in Hermes

It would be easy to draw the wrong conclusion. Hermes has no audit log because it aims at a different seat, not because someone forgot. When you ask for something on your own laptop and check the result yourself, recording who asked has no reader. There is one actor and they are sitting in front of the screen.

Watch the Hermes clips again and you will notice they are fast and quiet. Paste, press enter, get a table. For one person that is the better experience, and pointing it at our in-house model took a few lines of configuration.

The trouble starts when the same work becomes the organization's work. Rejecting a budget line blocks someone's spending, and that person asks why. The KPI table goes to an executive review, and when a number is wrong somebody has to trace which team's data was transformed how. What is needed then is not a better answer but **the provenance of that answer**. With a personal tool, people run their own copies and paste the pieces together, and the provenance stays scattered across individual chat windows.

## What Paxis did in addition

In the Paxis clips a step passes before the answer appears. It scores eight candidates from the corpus where we registered company procedures as skills, puts `budget-balance-auto-check` first at 0.70, and reads that procedure before answering. Classification landed on Finance at 95 percent.

The practical meaning is plain. The procedure the company agreed on attaches even when the person writing the prompt does not recall it. Whether the weights are 30/30/25/15, or whether the hold threshold is 60 points, belongs in a registered procedure rather than in one operator's memory. Which procedure attached is itself in the trace.

Tokens diverged too. On the budget case Hermes used 126,861 input tokens and Paxis used 24,411, roughly five times apart. The cause is structural. Hermes ships its full toolset on every call while Paxis narrows to the matched skill. Read that as an observation from these two cases rather than a general cost comparison, since the call counts and architectures differ and the figures are not divided by a common yardstick.

## What we cannot claim

Some honest limits.

The Paxis clips did not run on the 245k model alone. One routing classification went to the distilled 8B. The sentence "same model" is true of the calls that wrote the answers, and the table above shows the split. Our recording verification gate held both takes for exactly this reason, and rather than delete the verdict we wrote it here.

The timings are not quotable numbers. Each case ran once, sequentially, on the same machine. They are not a median of five runs, so read the seconds as an order of magnitude. The token counts come straight out of the ledger and are firmer.

The strongest counter-argument deserves to go first: **an audit log can be bolted onto anything.** Nothing prevents adding logging to Hermes. So our claim is not that Hermes keeps no record. It is whether verdicts, delegation and blocking are first class concepts in the schema, or something each team writes when the need arrives. In Paxis `agent.tool.blocked` is a row you can query. In a personal tool it is usually something you have to build.

## Wrapping up

Two products on one model produced the same answers on the same work. So the choice is settled by the next question rather than by answer quality. Will you have to explain this verdict to someone later? Will this number be merged with pieces other people produced? If neither, a local agent is enough, and we use one that way. If either, the record has to be part of the product.

Metis serves the model, Signum provides the identity and audit floor, and Paxis runs the work on top. The 245k arm in this post runs on our internal demo cluster, and both products pointed at the same endpoint.

These figures are not a simulation. They come from runs on our internal demo cluster on 28 August 2026, and the call table was pulled directly from the Paxis execution ledger.
