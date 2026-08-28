---
title: "What you need after the agent has answered"
seo_title: "Running real company work on our in-house 245k model with Paxis - procedure matching, execution traces, audit | ThakiCloud"
seo_description: "We pointed Paxis at our in-house Qwen3.8-27B NVFP4 245k endpoint and ran two real company procedures. It picked the registered procedure out of 922 skills, logged the model and token count of every call, and accumulated audit events carrying an actor. Screen recordings plus ledger queries."
excerpt: "A local agent answers just fine. What separates an organization is whether the answer records which procedure it followed, which model spent what, and who asked."
date: 2026-08-28
tags:
  - Paxis
  - agents
  - audit log
  - execution trace
  - skill routing
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

If you run a local agent against your own model and work mostly alone, the answers themselves already come out fine. That is what we found. But once a team runs the same work, one more question attaches to every answer. Which procedure did it follow, which model spent how much, and who asked for it.

This post records what happened when we pointed Paxis at our in-house endpoint and gave it two procedures that actually run in our company. The model is `thakicloud/Qwen3.8-27B-NVFP4-GPTQ-txt-245k-dflash`, an arm serving a 245,760 token context. One decides whether a spending request exceeds its remaining budget; the other merges monthly KPIs that every team reports in a different shape.

![What remains after the agent answers](/assets/images/hermes-alone-paxis-together-hero.webp)
*A queryable ledger on one side, a conversation on the other. One model feeds both.*

![One model behind two interfaces](/assets/images/hermes-alone-paxis-together-slide-01.webp)
*The same Qwen3.8-27B NVFP4 245k arm, seen by a local agent (Hermes desktop) and by Paxis.*

Measurement conditions first. Everything pointed at `https://e70a2682812d-8000.demo.thakicloud.net`, and the prompt was pasted character for character. Each case ran once, sequentially, on the same MacBook. So the seconds below indicate an order of magnitude. Token counts and row counts are read straight out of the product's own ledger.

## First task: budget check on spending requests

We supplied remaining budgets for three cost centers and three requests, and asked for an approve or reject verdict per item. Arithmetic settles the answer. DOC-8841 asks for 4,500,000 against 3,200,000 remaining, over by 1,300,000. DOC-8842 asks for 21,000,000 against 31,500,000, so it passes. DOC-8843 asks for 300,000 against 50,000, over by 250,000.

<video controls muted playsinline preload="none" poster="{{ site.url }}{{ site.baseurl }}/assets/images/paxis-245k-budget-poster.jpg" style="max-width:100%">
  <source src="{{ site.url }}{{ site.baseurl }}/assets/videos/posts/paxis-245k-budget.mp4" type="video/mp4">
</video>

![Verdicts on the three spending requests](/assets/images/hermes-alone-paxis-together-slide-02.webp)
*All three correct to the won, with rejection reasons attached.*

All three landed. The value of that screen is not the verdict, though. It is the step that runs **before** the answer.

## An agreed procedure replaces the prompt

Watch the clip again and Paxis opens a candidate list before writing anything. It scores eight entries from the corpus where we registered company procedures as skills, puts `budget-balance-auto-check` first at 0.70, and reads that procedure before answering. Domain classification landed on Finance at 95 percent. This instance currently holds **922 registered procedures**.

The practical meaning is plain. The procedure the company agreed on attaches even when the person writing the prompt cannot recall it. Whether the weights are 30/30/25/15, or whether the hold threshold is 60 points, belongs in a registered procedure. It is not a value to leave in one operator's memory.

When the procedure changes you edit one registered copy rather than hunting through everyone's prompt snippets. And which procedure attached is itself recorded in that run's trace.

## Second task: rolling up team KPIs

Sales, engineering and support each sent August figures in their own format. We asked for one standard table with month over month change. Units are mixed, and some metrics are better when they go down.

<video controls muted playsinline preload="none" poster="{{ site.url }}{{ site.baseurl }}/assets/images/paxis-245k-kpi-poster.jpg" style="max-width:100%">
  <source src="{{ site.url }}{{ site.baseurl }}/assets/videos/posts/paxis-245k-kpi.mp4" type="video/mp4">
</video>

Nine metrics came back in one table, with exactly one figure worse than July: sales contract value falling from 520M to 480M won, down 7.7 percent. Direction was flagged correctly for the metrics where lower is better.

Now suppose that table goes to an executive review. If one number is wrong, somebody has to trace which team's data was transformed how. That is why the next axis matters.

## What every call leaves behind

Paxis prints a receipt under the answer. Which agent ran, on which model, for how many turns, with input and output token counts, and the trace identifier for that run. The budget case was 2 turns in 13.8 seconds, 24,411 tokens in and 2,374 out. The KPI case was 2 turns in 9.0 seconds, 23,467 in and 1,736 out.

Underneath, the ledger keeps **one row per call**. Pulling the calls from a single budget turn in time order gives this.

| Time | Model | In | Out | Latency |
|---|---|---|---|---|
| 09:38:19 | paxis-distill-8b | 2,728 | 100 | 715ms |
| 09:38:20 | Qwen3.8-27B NVFP4 245k | 7,076 | 238 | 1,143ms |
| 09:38:21 | Qwen3.8-27B NVFP4 245k | 8,451 | 270 | 1,177ms |
| 09:38:22 | Qwen3.8-27B NVFP4 245k | 9,437 | 1,132 | 2,291ms |
| 09:38:25 | Qwen3.8-27B NVFP4 245k | 8,099 | 1,109 | 3,356ms |

![Model and tokens per call within one turn](/assets/images/hermes-alone-paxis-together-slide-04.webp)
*Only the routing classification went to the 8B; every call that wrote the answer went to the 245k.*

The first row stands out. One routing classification went to a distilled 8B, and every call that actually wrote the answer went to the 245k model. What matters is less that we designed it that way and more that **the fact can be pulled into a table later**. When a bill looks wrong you can name the call responsible; when an answer is wrong you can name the model that wrote the sentence. This instance's call ledger currently holds 9,881 rows.

Context volume falls out of the same structure. Paxis sent 24,411 input tokens upstream for the budget case, because it narrows to the matched skill rather than shipping a full tool catalogue on every call.

## Who asked for it becomes a row

Audit events accumulated separately over the same minutes. `agent.routing.grounded`, `subagent.dispatched`, `subagent.completed` and `agent.tool.invoked` all landed as rows, and tool invocations carry an actor (`dev-hyojung`). The table holds 15,151 rows so far, of which 101 are `agent.tool.blocked`, meaning policy actually stopped a tool. It answers SQL because it is a table.

Rejecting a budget line blocks someone's spending. That person asks why, and the question usually arrives days later. What you need then is one query with a filter on it rather than a scroll back through a chat window.

Audit is not the only thing. Approval proposals sit in `approval_proposals` at 160 rows, credentials live in a vault with versions and an access log, and execution quality gets scored separately in `eval_reports` at 122 rows. Metering accumulates in `usage_entries` at 9,613 rows alongside rate contracts. None of this looks related to answer quality, yet every item becomes something a person asks about once an organization actually runs agents.

![The layers under a provable process](/assets/images/hermes-alone-paxis-together-slide-05.webp)
*The model writes the answer; the infrastructure above it runs the work.*

## What we cannot claim

Some honest limits.

The Paxis runs did not go to the 245k model alone. One routing classification went to the distilled 8B. The sentence "same model" is true of the calls that wrote the answers, and the table above shows the split. Our recording verification gate held both takes for exactly this reason, and rather than delete the verdict we wrote it here.

The timings are not quotable numbers. Each case ran once, sequentially, on the same machine, so read the seconds as an order of magnitude. Token counts and row counts come straight out of the ledger and are firmer.

This is also not a post about what a local agent cannot do. In a seat built for one person a local tool is faster and quieter, and pointing it at an in-house model takes a few lines of configuration. When there is one actor and that actor is sitting in front of the screen, most of what is listed above simply is not needed.

## Wrapping up

Put the same model behind either one and the answer comes out. What separates them in an organization is what comes next. Will you have to explain this verdict days later? Will this number be merged with pieces other people produced? When the procedure changes, is there one place to edit?

Metis serves the model, Signum provides the identity and audit floor, and Paxis runs the work on top. The 245k arm in this post runs on our internal demo cluster.

These figures come from runs on our internal demo cluster on 28 August 2026, and the call table was pulled directly from the Paxis execution ledger.
