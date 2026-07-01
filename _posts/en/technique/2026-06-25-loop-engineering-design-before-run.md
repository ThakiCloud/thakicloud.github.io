---
title: "Design the Loop Before You Run It: Agent Loop Engineering That Doesn't Burn Tokens"
excerpt: "We're moving from an era of writing good prompts to an era of designing good loops. An agent loop launched without design burns tokens and delivers results you cannot use. This post covers how to design the small system that finds work, dispatches it, verifies results, records progress, and decides what comes next, plus the loop guardrails ThakiCloud built after a $700-in-one-day incident."
seo_title: "Agent Loop Engineering: Design Before You Run - Thaki Cloud"
seo_description: "What to design before running an agent loop (goal definition, memory file, verifier separation, caps), and how to control the two costs of tokens and attention. Includes the real loop operation guardrails from ThakiCloud's Kubernetes AI/ML SaaS platform."
date: 2026-06-25
last_modified_at: 2026-06-25
lang: en
categories:
  - technique
tags:
  - agentic
  - loop-engineering
  - claude-code
  - llmops
  - cost-optimization
  - platform-engineering
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "robot"
canonical_url: "https://thakicloud.github.io/en/technique/loop-engineering-design-before-run/"
slug: loop-engineering-design-before-run
---

## Overview

"Design the loop before you run it" is advice that has been spreading quickly through developer communities. The core point is simple: a poorly designed loop burns tokens and hands you results you cannot use. Writing a good prompt once and designing a system that feeds that prompt to an agent repeatedly are completely different tasks.

In one sentence: where people used to hand a prompt to a model, now people design a loop and the loop hands prompts to the model. You build a small system that finds work, assigns it to an agent, verifies the output, records what is done, and decides what comes next. Then that system wakes the agent so you do not have to.

ThakiCloud runs dozens of unattended loops and recurring agent tasks while operating a Kubernetes-based AI/ML SaaS platform. In the process, we experienced a single day that generated a $700 invoice, and we turned everything we learned from that incident directly into loop guardrails that are running in production today. This topic is not an abstract trend for us; it is an operational design problem we face every day. This post covers what to design before you run a loop and how we applied those lessons to a real platform.

## What Is Loop Engineering

Loop engineering means building the system that instructs agents instead of instructing agents directly yourself. When a person stays inside the loop, they have to type the next instruction every time an agent finishes a step. Loop engineering inserts a small automation in that position. The system finds work, hands it to the right agent, checks the result, records progress, and decides the next action.

The key point is that the person deliberately sets the level of autonomy. Leaving the loop fully autonomous makes it easy to lose both tokens and control, while requiring human confirmation at every step eliminates the benefit of automation. A good loop explicitly places autonomy and verification checkpoints between those extremes. Deciding at design time how far the agent can go on its own, and where a person or a separate verifier must step in, is the core of the work.

A second assumption is that the loop must know how to converge or stop. A loop without a termination condition is not automation; it is a leak. Half of loop design is defining "when does this stop."

## Four Things to Design Before You Run

Starting a loop without design is the most common failure pattern. Defining the following four things explicitly before you run prevents most token waste and quality collapse.

First, define the goal as a concrete, verifiable output. A vague goal like "improve this code" gives the loop no convergence criterion. Set a verifiable termination condition such as "until this test command passes." The termination condition is the loop's endpoint.

Second, write the memory file before the loop runs. Keep one markdown file or board that records what is done, what is next, and what was tried and failed. This file is the spine of the loop. If the agent reads and updates this file on every iteration, state is not lost even as the context grows long.

Third, separate the agent that produces from the agent that verifies. Never let the agent that did the work judge itself done. Either set up a separate gate with a verifiable condition, or have a second agent with its own instructions audit the result. A loop without a verification stage accumulates hallucinations.

Fourth, cap the loop with a maximum iteration count, a token budget, and a teardown stage. Then run it once all the way through and read every line of output. Whether a loop actually behaves as intended is something you can only know by reading the whole thing once. Skipping this review lets a poorly designed loop quietly burn tokens for days.

```text
[ 1. Goal Definition ]  verifiable termination condition (e.g., tests pass)
        |
        v
[ 2. Memory File ]  spine recording done / next / tried-failed
        |
        v
[ 3. Loop Run ] --- find work -> dispatch agent -> result ---+
        ^                                                    |
        |                                                    v
[ 4. Verifier Separation ]  producer agent != judge agent --> [ Gate passed? ]
        |                                                    |
        |  fail -> next iteration                            | pass
        +----------------------------------------------------+
        |
        v
[ 5. Cap ]  max-iter · token budget · teardown -> stop
```

The two cells most often missing from this flow are 4 (verifier separation) and 5 (cap). Without those two, the loop either runs forever or combines plausible but incorrect results and delivers them to you.

## Two Costs: Tokens and Attention

The loop's invoice arrives in two currencies: tokens and human attention. A single unattended run can burn millions of tokens, and the only case where that is justified is when those tokens buy something worth more than their cost.

The key insight here is that running polling or monitoring on an expensive model is almost always wasteful. Tasks like taking a price snapshot, comparing state, or running a health check require almost no judgment. Paying the top-tier model rate every tick for a one-line comparison result is a fast path to exploding costs with nothing to show for it.

So the first question to ask when designing a loop is "does this actually need the model to judge every tick?" If the answer is no, run that loop with a script and a scheduler without a model, and only call the model when a person or an event triggers it. If the model is genuinely needed for each iteration, use a lower model tier, keep state in a file, and make every wakeup start with minimal context.

## What ThakiCloud Learned from the $700 Incident

These principles did not arrive as a textbook for us; they arrived as a bill. On a single day, all nine sessions ran on the top-tier model, and one monitoring session alone ran for more than nine hours, more than 1,100 iterations, and consumed half of the total cost. Breaking down the costs, we found that a massive context being re-read on every iteration was consuming a significant fraction of the total through cache-read costs. The cause was not cache misses; it was the product of a giant context, a high iteration count, and an expensive per-token rate.

We turned what we learned directly into guardrails. First, we pulled recurring monitoring out of the model's hot loop and moved it to a scheduler (cron, launchd). Price monitors and state comparisons now run as scripts without a model, and only send a notification to the report channel when something unusual is detected. Model cost for that work is zero.

Second, loops that genuinely need a model are kept short and stateless. State lives in a file, every wakeup starts with minimal context, and context is reset before a session accumulates too many iterations. The reason is that as a session's context grows, the cache-read cost of each iteration increases linearly.

Third, the main session responsible for orchestration runs on a mid-tier model, and only the stages that truly require complex reasoning are isolated to a top-tier model subagent. On the day of the incident, the problem was that the main session itself was the expensive model, not the subagents. "Workers cheap, gates expensive" is the principle that came from that.

## Tool Selection: Distinguish Goal, Loop, and Schedule

The thing we emphasize most when designing loops is: when a request comes in for "repeat / automate / keep going," start by choosing the right tool. The three options are different machines.

Work that autonomously pursues a goal to a completion condition, ending in a "done" state, goes into goal mode. It operates convergently with a verification command gate, a budget, and a state file. Repeatedly implementing code until tests pass runs as a development loop with the test command as the termination gate. Work that needs to poll external state periodically during a session runs as an interval loop, with the polling interval chosen based on cache lifetime. Work that repeats unattended at a fixed time runs on a scheduler. That is the primary pattern in our environment, and because the model is not called every tick, cost approaches zero.

Blurring these distinctions causes incidents. Accumulating 24-hour monitoring in an interval loop causes costs to explode. Putting fixed-time repetition into goal mode leaves it without a convergence criterion, and it wanders. So before starting a loop, we require an answer to: "Is this a goal, a loop, or a schedule?"

## Application to ThakiCloud's K8s AI/ML SaaS Platform

Loop engineering goes beyond a single developer's productivity tip; it is a core operational competency for running a multi-tenant platform. ThakiCloud runs agents and pipelines in isolated environments for each customer, and uncontrolled token burning by any tenant's unattended loop becomes directly an operations cost and stability problem.

We manage unattended loops through a central registry and a standard signal bus. We declare in one place what each loop reads and writes, and when loops need to communicate, they connect only through declared signal topics, not arbitrary shared files. A loop that is not in the registry is invisible, and an invisible loop gets abandoned and becomes the seed of a cost incident. So we require every new loop to be registered.

From a platform perspective, this is product competitiveness. In an architecture that queues GPU workloads through Kueue on Kubernetes and isolates model serving per tenant, the ability to enforce loop costs and termination conditions in code is the foundation that lets on-premises customers run agents safely on their own infrastructure. An autonomous agent whose costs are not controlled is impressive in a demo and a liability in production. What we sell is the operational design that turns that liability into guardrails.

For practitioners, the implication is equally clear. When a data scientist or ML engineer runs overnight batch experiments or automates a data pipeline, covering three things alone prevents most cost incidents: separating the verifier, capping tokens, and keeping a memory file. This pattern is not tied to any particular vendor and works with any agent harness.

## Limitations and Objections

Loop engineering is not a universal solution. The strongest objection is that not every task is a loop problem. Forcing a one-off question or a single file edit into a loop adds design overhead and gains nothing. Loops have value only for work that is repetitive and verifiable.

A second objection is that verifier separation is not free. A separate verification agent costs additional tokens, and the verifier itself can be wrong. If a verifier never filters anything out, that may be a signal that verification is not working properly. Verification stages should therefore be designed with a different perspective from the producing agent, and ideally an adversarial one.

Finally, watch out for the temptation of automation itself. When a loop appears to run smoothly, people become careless about reviewing it. But the second currency on the invoice, attention, does not disappear because you automated. If the discipline of reading the output once all the way through and periodically sampling results is skipped, even a well-designed loop will quietly accumulate results you cannot use.

Ultimately, the core of loop engineering is not expanding autonomy but drawing the boundaries of autonomy clearly. The discipline of deciding before you run how far to delegate, where to stop, and what to verify with is what separates a loop that does not burn tokens from one that becomes a liability.

## Sources

- [Original tweet (Design before you run the loop)](https://x.com/hjguyhan/status/2069532808507429264)
- [Addy Osmani, "Loop Engineering"](https://addyosmani.com/blog/loop-engineering/)
- [looper: a tool for designing agent loops with visual review gates before execution](https://github.com/ksimback/looper)
- [awesome-agent-loops: a collection of /loop, /goal, /schedule use cases](https://github.com/serenakeyitan/awesome-agent-loops)
