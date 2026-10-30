---
title: "Google Gemini 4 Carbon: SOTA Cybersecurity and Long-Horizon at Half the Intro Price"
excerpt: "Google unveiled Gemini 4 Carbon on October 28. First on the Artificial Analysis Intelligence Index v5.0 with 59 points, 88.2% on SEC-bench Pro for vulnerability discovery, sustained agentic workflows over days, an intro $2/$10 (per 1M tokens) price structure, and a phased rollout plan."
seo_title: "Gemini 4 Carbon Released: Cybersecurity Benchmarks and Agent Execution Economics | ThakiCloud"
seo_description: "Gemini 4 Carbon dissected: AA Intelligence Index v5.0 59 points at #1, SEC-bench Pro 88.2%, ExploitGym 54.8%, CWE-bench 71.0%, days-long long-horizon agents, Fairwind Program phased release, intro $2/$10 then $4/$20. Per the official Google blog."
date: 2026-10-30
last_modified_at: 2026-10-30
author_profile: true
toc: true
toc_label: "Table of Contents"
toc_icon: "rocket"
tags:
  - gemini
  - google
  - frontier-model
  - cybersecurity
  - agentic
  - pricing
  - api
categories:
  - news
canonical_url: "https://thakicloud.com/tech-blog/en/news/gemini-4-carbon/"
header:
  teaser: /assets/images/gemini-4-carbon-hero.webp
---

## Who Should Read This

If you design model costs for agent workflows, or you operate a platform that uses frontier model APIs and open-weight models together, this post is for you. The core conclusion first: Gemini 4 Carbon, unveiled by Google on October 28, is a frontier model positioned around "cybersecurity and long-horizon work," and at the intro price of $2/$10 (per 1M tokens) it is the point where you can actually compute how those properties enter agent execution costs. In the first week of release, a subset of cyber defenders and trusted partners get access before general developers, so what matters now is less the performance numbers and more "which workloads this price tier applies to."

![Abstract image of a carbon lattice transforming into shields and long time lines](/assets/images/gemini-4-carbon-hero.webp)

## Overview

On October 28, 2026, Google announced Gemini 4 Carbon on its official blog (The Keyword) as "our next frontier model" and "our strongest model with state-of-the-art cybersecurity and long horizon capabilities." It came two weeks after the previous model, Gemini 4 Argon. Google presents Carbon as evidence of "the pace at which we're pushing the frontier forward."

One more piece of background. Argon, released in early October, is the first model of the Gemini 4 family, positioned around "solving your hardest problems." Carbon followed two weeks later, and Google frames that interval as evidence of frontier pace. Leading with specific axes (cybersecurity and long-horizon) in the second model reads as a signal that the Gemini 4 family is expanding the frontier along domain axes rather than a single "general intelligence" axis. Meanwhile, the Artificial Analysis Intelligence Index is a composite intelligence index that an independent benchmark operator assembles from multiple evaluation sets. Google's emphasis that v5.0 is the "recently updated" version means the #1 ranking is against the latest index.

This announcement has three axes. First, #1 on the Artificial Analysis Intelligence Index v5.0 (recently updated) with 59 points. Second, three cybersecurity-specialized benchmarks (SEC-bench Pro 88.2%, ExploitGym 54.8%, CWE-bench 71.0%) and a WebDev Arena gain (1768 elo, +89). Third, the design for long-horizon engineering work that "runs for days, persisting through dead ends," paired with safety metrics (high-severity misalignment alerts down about 80%, successful cheating on Terminal-Bench 4.0 at 0.0%).

The rollout is phased. Starting this week, a subset of cyber defenders gets access first; access expands to trusted partners through the Fairwind Program; and developers, businesses, and consumers are to be reached "as soon as possible" via product surfaces. Google also states it is participating in the U.S. government's voluntary pre-release model testing process. There are no public weights in this announcement; it is a frontier-capability-as-API configuration.

## What Is Gemini 4 Carbon

Carbon is a model built on Argon. It inherits Argon's multi-layered safety and security stack, and reads as tuned along two axes: long-running autonomous work and security work. The ability Google calls "sustained agentic workflows" is the tendency, when a task unfolds over days, for the model to hold context, escape dead ends, and return toward the goal. The official phrasing, "run for days to persist through dead ends," describes the behavior of exploring alternatives when work gets stuck while staying with the original goal. The core is not giving up. From the agent perspective, the price of this tendency is tokens. Dead-end exploration burns output tokens, so the stronger the long-horizon capability, the more "exploration efficiency" becomes the variable that determines real cost.

Two behavioral metrics in the same announcement support this direction. Versus Argon: "overreach reduced by 26%, under-service reduced by 29%." The two failure modes of agent models are "touching areas they were not asked to" and "deferring work they should do," and Google reports that Carbon reduces both at once.

The benchmark composition is the basis Google offers for this positioning. Where a typical frontier model announcement leads with a composite intelligence index and general coding or math benchmarks, the center of the Carbon announcement is the three security benchmarks.

| Benchmark | Role | Carbon result |
|---|---|---|
| SEC-bench Pro | Finding software vulnerabilities | 88.2% |
| ExploitGym | Exploiting vulnerabilities | 54.8% |
| CWE-bench | Patching vulnerabilities | 71.0% |

These three measure the three stages of the vulnerability lifecycle: find, exploit, patch. The reason to read the three numbers side by side is that one model covers both sides of the lifecycle, offense (find, exploit) and defense (patch). In a security workflow, if one model can perform "find the vulnerability in this code, build the exploit scenario for it, and propose a patch" as consecutive actions, the model-dependent part of the security review pipeline shrinks substantially. Presenting offense and defense numbers simultaneously at the frontier level is what makes this set a window into "what capability Google wants the model classified as."

These three are relatively new evaluation sets rather than long-established standard benchmarks. That makes them more useful for reading "what capability Google wants to classify the model as" than the raw numbers themselves. As composite indicators, the 59-point #1 on AA Intelligence Index v5.0 and the 1768 elo (+89, 4th) on WebDev Arena are presented alongside.

Safety metrics also carry significant weight in this announcement. Versus Argon: "more than 2x uplift in success rate for generating secure code," "0.0% successful cheating on Terminal-Bench 4.0 (0.4% cheating attempts)," "high-severity misalignment alerts down almost 80%," and "unsupported claims cut by approximately 2x."

The "cheating on Terminal-Bench" item deserves separate attention from the agent perspective. Terminal-Bench is an agent benchmark for completing tasks in a terminal environment, and the behavior where a model disturbs the grading structure to score instead of achieving the task's original goal (fixing the test, hardcoding the answer, bypassing the evaluation script) is called "cheating." The numbers 0.0% successful cheating and 0.4% attempts are a metric that lets you read the model as "one that solves problems within the rules" rather than "one that scores well." When entrusting long-horizon autonomous agents with a model, this metric should be weighed the same as success rate.

Accompanying safety mechanisms include prompt-injection resilience and chain-of-thought monitoring, inherited from the Argon stack, as explicitly stated. Google explains that Carbon explicitly learns behaviors such as putting methodological caveats directly into the deliverable, or retrieving relevant sources and surfacing discrepancies to the user before acting. The report also includes that on Gray Swan's Indirect Prompt Injection (IPI) Benchmark, it resisted every evaluated attack attempt at 0.0%.

## Release Path and Pricing

The price structure splits into the intro period and after.

| | Input (1M tokens) | Output (1M tokens) | Cached input |
|---|---|---|---|
| Intro period | $2 | $10 | 95% off the input price |
| After intro | $4 | $20 | (intro policy applies) |

The point to notice is the 95% discount on cached input. Agent workflows have a structure that repeatedly sends the system prompt, tool schemas, and knowledge context, so the share of cached tokens is high. With intro $2/$10 plus the 95% cache discount, a "temporary window where long agents can be run cheaply" opens. But the price rises to $4/$20 when the intro ends, so any execution economics built on this price must assume the intro (temporary) condition.

A concrete calculation. Assume one agent session: 2M input tokens (1.5M of them cached) and 200K output tokens. Uncached input is 500K x $2/M = $1.00 at the intro rate, cached input is 1.5M x $2/M x 5% = $0.15, and output is 200K x $10/M = $2.00. Total about $3.15. Running the same session at the post-intro price ($4/$20) gives $2.00 + $0.30 + $4.00 = about $6.30. The intro-period cost is exactly half for the same workload ($3.15 to $6.30). The higher the cache share, the more of the total cost concentrates in cached input (5% rate) and output, but in this assumption the unit price doubles, so the total doubles. The longer the agent runs over days, the more the same session repeats hundreds of times a day, which makes the intro window the cheapest segment for running experiments where the cost of failure is large.

The release order should be read in the same context as the price. A subset of cyber defenders, then Fairwind Program trusted partners, then developers, businesses, and consumers. The stronger the security capability, the more "who gets to use it first" carries the same weight as performance. There is still slack before it lands in general developers' hands, and in that interval the API surface (which products, which endpoints) will be decided. Two things to track. One is the pace of partner expansion through the Fairwind Program; the other is whether the intro price holds when developer access opens. The former separates "a security-specialized model" from "a general frontier model"; the latter determines where to anchor the agent execution budget.

## Implications for ThakiCloud Products

Two lenses.

**ai-platform (Metis) lens.** As long as frontier models are API-only, customers in on-premises and sovereign environments hold frontier-grade capability as "API calls" only. The structure where Metis serves multiple models (open-weight self-hosting + frontier APIs) on one platform is the alternative to that division. With Carbon shipping as "API-only, phased release," the importance of open-weight frontier alternatives (public weights of comparable capability) rises instead. The platform's job is to keep the model catalog solid enough that a customer can pick "this capability via API, that capability on-prem" as a single policy line.

That choice reduces to a cost comparison. Under intro $2/$10 plus 95% cache, API cost for agent workloads becomes almost predictable per session, and the breakeven against self-hosting's fixed GPU cost differs by domain. This price list provides the inputs for splitting "this domain via API, that domain on-prem" with a single policy gate.

The security domain deserves separate attention. Vulnerability discovery and patching at the SEC-bench Pro 88.2% and CWE-bench 71.0% level raises the baseline for the product area called "code security agents." Organizations running security agents have two options: using a frontier API as the scanner, or meeting that baseline with their own model plus deterministic gates. For the organizations that choose the latter (including environments where internal data must not leave to an external API), this announcement reads as a signal to re-measure "where our security agent stands."

The same structure appears from the sovereignty angle. Carbon participates in the U.S. government's voluntary pre-release testing process and takes the order where a subset of cyber defenders uses it first. The stronger the security capability, the more the access order for the national and public sector is decided first, and for such workloads to enter a domestic customer's on-premises environment as-is, the data sovereignty condition (the data flow of API calls, not the weights) must be solved alongside.

**Paxis lens.** "Agent workflows sustained over days" is the same problem as Paxis's long-running job design. For agent tasks that take days, cost is separated by (1) whether caching economics hold as context expands, (2) how many output tokens exploration returning from dead ends burns, and (3) whether checkpointing and resume are possible. Intro $2/$10 plus the 95% cache discount is a good condition for building a measured budget for those three questions. Specifically, for (1) to hold, the system prompt, tool schemas, and knowledge context must be kept stable across sessions so caching actually engages; for (3) to hold, state must be extractable from mid-job and resumable. If Paxis's long-running jobs support those two compositions at the job level, the Carbon intro period is a rare window to measure "how cheaply and how safely multi-day agents can be run."

Carbon's behavior of "putting methodological caveats directly into the deliverable" also matters from the Paxis perspective. When evidence and caveats are attached to an agent deliverable, the inputs a policy gate and audit log need to verify that deliverable are already inside it. Verification can shrink from "read the deliverable and dig into the sources again" to "check the caveats attached to the deliverable."

## Limitations and Counterarguments

First, every number is Google's self-report. None are reproduced on independent benchmarks, and the #1 on AA Intelligence Index v5.0 is against the "recently updated v5.0." Second, the three security benchmarks are new evaluation sets, and head-to-head comparison with existing models is not yet established. The 88.2% is closer to a number that says "what capability it is classified as" than "how good it is." Third, "runs for days" is a capability positioning, not a success-rate guarantee for day-scale tasks. Real success rates on long-horizon work vary widely by task domain. Fourth, the intro nature of the price. $2/$10 is the intro-period value, and it returns to $4/$20 after. Any execution economics done at this price must be recomputed with the period as a premise. Fifth, access limits. This week is a subset of cyber defenders; general developer access is not open yet. Verifying "SOTA" requires using it directly, and using it requires waiting.

## Summary

Gemini 4 Carbon is an announcement declaring "security + long-horizon agents" as the next axis of the frontier. The judgments needed right now are three. Whether a structure is needed to provide frontier-grade security capability via API to on-premises and sovereign customers. Whether to measure Paxis's long agent workflow budget under the intro $2/$10 plus 95% cache condition. And where the cost of running the same workload on open-weight self-hosting meets the $4/$20 that takes effect when the intro ends. The answers to those three questions complete only "after using the model directly," but the calculation frame can be set up now.

## Sources

- [Google The Keyword: Introducing Gemini 4 Carbon (2026-10-28)](https://blog.google/innovation-and-ai/models-and-research/gemini-models/introducing-gemini-4-carbon/)
- [Google DeepMind blog](https://deepmind.google/blog/)
- [X announcement (RT)](https://x.com/hjguyhan/status/2115812053827137736), 2026-10-29
