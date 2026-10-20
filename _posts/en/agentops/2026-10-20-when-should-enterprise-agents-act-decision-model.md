---
title: "When Should an Enterprise AI Agent Act? Why We Are Adding a Dedicated Decision Model to Paxis"
excerpt: "Answer, call a tool, or ask a human first. Instead of leaving that call entirely to the generative model, we split it between a 4B decision model and a deterministic policy layer. Here is why, and what we have measured so far."
seo_title: "Action Decisions for Enterprise AI Agents: Separating a Decision Model from Policy Enforcement | ThakiCloud"
seo_description: "We trained 2B, 4B and 9B decision models that pick one of seven next actions for an agent: answer, call a tool, ask for confirmation, refuse and more. The 4B made the fewest dangerous executions and decides in about 60 ms on vLLM."
date: 2026-10-20
last_modified_at: 2026-10-20
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "robot"
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/agentops/when-should-enterprise-agents-act-decision-model/"
tags:
  - paxis
  - agent-runtime
  - decision-model
  - tool-calling
  - policy-enforcement
  - human-in-the-loop
  - vllm
  - qwen3.5
categories:
  - agentops
---

The hard part of an enterprise AI agent is not writing a good sentence. It is choosing the next action. The same kind of request sometimes needs a direct answer, sometimes a tool call, and sometimes a human's confirmation before anything runs. At ThakiCloud we are splitting that judgment out into a small dedicated model and attaching it to the Paxis agent runtime. This post is the first record of that work. Model training and serving measurements are done; the experiment that wires the model into Paxis and compares it with the existing agent is just starting. We keep the two apart below.

## Why choosing the action is harder than answering

An agent connected to company systems does more than answer questions. It looks up data, chains several business tools, and sometimes changes real state, such as cancelling an order or updating a setting. "Tell me last month's revenue" and "Cancel customer A's order" look alike as sentences, but the first only needs a lookup while the second may need confirmation before it runs. "Change this employee's salary" may have to be refused depending on who is asking.

A typical LLM agent leaves much of this to the generative model. But writing a fluent answer and choosing the action a company policy calls for are different skills. A model can explain things well and still call a tool it should not, or skip a required confirmation. In the other direction, asking again for information the customer already gave slows the work down. Both kinds of mistakes cost product quality.

## Seven possible next actions

We define the agent's next action as one of seven.

| Code | Action | When |
|---|---|---|
| A | `ANSWER` | It can answer without a tool |
| B | `ASK_CLARIFICATION` | Information needed to proceed is missing |
| C | `ASK_CONFIRMATION` | Policy requires the user's confirmation before running |
| D | `CALL_TOOL` | One tool is enough |
| E | `CALL_MULTIPLE_TOOLS` | One tool's output is needed by the next |
| F | `ESCALATE` | A person or another team has to decide |
| G | `REFUSE` | Policy says not to do it |

The model writes no JSON and no reasoning. It reads the policy, the tool list and the request, then emits a single letter from A to G. One token is fast and cannot break format.

Two boundaries matter. When the decision model picks `CALL_TOOL`, it does not decide which tool or which arguments; the existing agent does that. And a recommendation to execute grants no permission. Permission stays with the deterministic policy layer from start to finish.

## 2B, 4B and 9B trained on the same data

We applied the same training data and output contract to the Qwen3.5 2B, 4B and 9B checkpoints. The training data is code-generated Korean customer-service policy scenarios, and the labels are computed by a policy executor. No label was written by an LLM. We put in many boundary cases: whether the user already gave the needed information, whether confirmation is needed first, whether policy forbids the request, whether one tool is enough. The models also learned to evaluate conditions that combine AND, OR and NOT. An earlier version had a habit of blocking whenever a restriction clause appeared, and it got none of 31 NOT-condition cases that should have run.

We cared less about average accuracy than about two kinds of mistake: a **dangerous execution**, where policy says refuse, confirm or escalate but the model runs a tool, and an **over-block**, where the model blocks a request it should execute or answer. val2 below is a 600-item set sealed before training, built from domains and sentence templates the training data never used.

| Metric | 2B | 4B | 9B |
|---|---|---|---|
| val2 accuracy | 96.5% | 97.7% | 97.8% |
| val2 dangerous executions (of 294) | 10 | **3** | 7 |
| val2 over-blocks (of 292) | 8 | **0** | 5 |
| Policy-composition regression set | 87.0% | **100%** | 93.8% |
| Multi-tool recall (391 regression items) | 91.3% | **98.2%** | 92.3% |

Bigger was not better across the board. The 9B was about as accurate as the 4B but made more dangerous executions and more over-blocks. What mattered for this task was drawing the action boundaries reliably, and the 4B did that best. We also ran an existing 27B generative policy model with the same A–G readout. It reached 74.0% on val2 with 26 dangerous executions. That model was never trained on the letter readout or on the AND/OR/NOT data, so read the number as a lower bound for a 27B.

The 100% on the composition regression set comes from data we opened several times during development. It does not mean 100% in production. We trusted the same direction showing up across several sets more than any single number.

## The 4B's remaining weakness, and why we stopped fixing it

The 4B has a weak spot. When a policy says "if the customer has several orders, the customer must say which one," it sometimes asked again even after the customer had said "the sneakers order." On one 300-item development set, 32 errors were this kind of unnecessary question. It is not dangerous, but it annoys users.

So we built 420 contrast examples, "specified means execute, unspecified means ask," and trained the 4B once more. Unnecessary questions dropped from 32 to 9. But the model leaned toward executing, and total dangerous executions rose from 6 to 16. By the rule we had set in advance, we threw the patch away and kept the original 4B. An extra question ends when the user answers; a wrong execution is hard to undo.

## Serving: about 60 ms per decision

A dedicated model adds a decision cost every time the agent acts, so serving speed matters as much as quality. We served the merged bf16 4B with vLLM 0.29.0 on one B200, calling `/v1/completions` with the output constrained to A–G and at most one token.

Single-request latency was 61.5 ms at the median and 63.3 ms at p95. With 32 concurrent requests it handled 288 requests per second. All 974 responses were valid letters, and the weights took about 7.9 GiB. Under the same setup the 2B was faster, 43.8 ms median and 359 requests per second, but its accuracy fell sharply on policy documents written in unfamiliar formats. So the 4B is the main model and the 2B is a lightweight option for throughput-bound deployments. The 2B is [public on Hugging Face](https://huggingface.co/ThakiCloud/Thaki-Decision-2B-v0.2); we plan to release the 4B after the Paxis integration is verified.

These 60 ms cover the decision model alone. End-to-end request time, including network calls, prompt assembly and agent execution, has to be measured in the Paxis integration experiment.

## In Paxis, the model sits between the policy layers

Paxis is ThakiCloud's Agent-Native Cloud control plane. It treats skills, tools, policies and audit logs as first-class resources, and every tool call an agent makes passes a policy gate and leaves an audit record. The decision model does not change that structure; it slots in between the existing policy check and the approval step.

<div class="mermaid">
flowchart TD
  U[User request] --> A[Paxis agent runtime<br/>LLM proposes a tool call]
  A --> P[PolicyStation<br/>permissions and tool policy · final authority]
  P -->|allowed| D[Decision Station<br/>Decision-4B picks one of seven actions]
  P -->|denied| X[Block + audit record]
  D -->|CALL_TOOL · CALL_MULTIPLE_TOOLS · ANSWER| Q[ApprovalStation<br/>required approvals]
  D -->|REFUSE · ESCALATE| X
  D -->|ASK_CONFIRMATION| Q
  D -->|ASK_CLARIFICATION| C[Ask the user]
  Q --> T[Tool execution]
</div>

The order matters. PolicyStation evaluates first, on the outside, so a tool the policy forbids never runs, whatever the decision model recommends. The Decision Station can only narrow what runs, never widen it. If the model server does not answer or returns an invalid letter, the decision is only logged and the request continues through the existing policy and approval path. A model failure never adds permission.

Reading the code also showed a gap we have to close. Paxis already has an approval mechanism for confirming before execution, but it is off by default and only the web chat can answer it. There is no path yet for handing a request to a person. If the model correctly picks `ESCALATE` but nothing can receive it, the product does not improve. So in the first stage an escalation decision is handled as a block plus an audit record, and a confirmation decision reuses the existing approval mechanism. Neither is ever treated as a successful execution.

## Shadow Mode first

Good offline accuracy is not a reason to put the model on the execution path right away. The first stage is Shadow Mode: the existing agent behaves as usual, and Decision-4B judges the same situation separately and only records its decision. It blocks and changes nothing.

What we want from this comparison is not how often the model gets A–G right. It is how many of the existing agent's wrong actions Decision-4B catches, and how many requests the existing agent handled correctly that Decision-4B would have blocked. That balance, plus the measured latency increase, decides whether the gate runs on every request or only on high-risk write actions. If it catches little and only adds latency, we will not roll it out everywhere.

## What ThakiCloud wants from this design

Instead of leaving every judgment to one large model, we split the work three ways. The general LLM understands and plans the task. The small decision model classifies the next action. The policy and approval system decides deterministically whether anything may actually run. This is not about replacing the general LLM with a small one. It is about finding the one judgment worth separating out and making just that part cheap and fast.

It is also where ThakiCloud's two products meet. The decision model runs on ai-platform's own GPUs and vLLM serving, so request contents never go to an external API, and the same setup works on-premises and in sovereign environments. At about 60 ms per decision and hundreds of decisions per second on a single GPU, the 4B keeps the agent's decision cost low. On top of it, Paxis governs actions with policy gates and audit logs.

## What we cannot claim yet

All training and evaluation data is code-generated Korean customer-service policy scenarios. Nothing guarantees the same performance on real company policy documents and real conversations. Even the sealed set comes from our own generator family, so it is not a test fully independent of how we built the training data. Dangerous executions are not zero either: three remain on val2. The decision model is therefore not a safety mechanism, and every real tool execution still needs a deterministic permission check in front of it.

In the next post we will compare the existing agent and Decision-4B on the same requests, using integration scenarios built from Paxis's real tools and policies. We will show both the cases where the existing agent was wrong and Decision-4B was right, and the cases where Decision-4B got in the way of normal work.
