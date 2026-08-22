---
title: "Build Expensive, Run Cheap: Trimming Skill Costs Every Night"
excerpt: "Most agent work doesn't need a frontier model. Build a skill once with an expensive model, push its format down into code, and you can run the same quality on a cheaper model. Paxis measures this tradeoff automatically every night, downgrades models only when it's safe, and rolls back the moment quality slips. Here's how that system works, with real measurements."
tags:
  - cost-optimization
  - agent
  - model-routing
  - open-weights
  - paxis
date: 2026-07-03
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/build-expensive-run-cheap/"
categories:
  - llmops
published: false
---

![Key concept illustration]({{ '/assets/images/build-expensive-run-cheap-hero.webp' | relative_url }})

If you run agents in production, you've seen the same pattern in your monthly bill. Most of the token spend comes from frontier models, and most of what those models are actually doing isn't hard reasoning at all. It's sorting email, matching news items, rendering tables, and checking whether an output followed spec. This post is for engineering leaders and AI teams who want a concrete answer to two questions: how do you decide whether a skill built on an expensive model can be run on a cheap one without losing quality, and how do you automate that decision so it runs every night instead of once?

Here's the short version. Expensive models earn their keep while you're **building** a skill. Once the skill's format has been pushed down into code, actually **running** it is a job for a much cheaper model. And "cheap enough" should never be a matter of gut feel. It has to be a verdict that code measures.

## Most of the work doesn't need a frontier model

Break down what an agent handles in a given day and the work splits into two very different buckets. One bucket holds genuinely hard reasoning: ambiguous architecture calls, subtle debugging, decomposing a problem nobody has framed before. The other bucket holds routine, repetitive work: routing, classification, summarization, rendering, spec checking. The trouble starts when both buckets get handed to the same frontier model and billed at the same top rate every time.

Quality on the routine side isn't actually driven by model intelligence. It's driven by **guardrails**. When output format wobbles, it's not because the model is dumb, it's because the format was requested in prose instead of enforced. Once length caps, allowed enums, rendering rules, and pass criteria are owned by code, that same task comes out reliably even on a cheap model. What protects quality here isn't a pricier model, it's the code gate around it.


![Concept diagram]({{ '/assets/images/build-expensive-run-cheap-diagram.svg' | relative_url }})

*Concept diagram*

## Build expensive, push the format into code, run cheap

The pattern we actually use has three steps.

First, build the skill with an expensive model. Early on there's a lot of judgment to exercise and failure cases to work through, so a strong model earns its cost. Second, extract the deterministic parts of the skill into code: rendering, enum normalization, length checks, deduplication, JSON assembly, anything the model shouldn't have to solve fresh every single time. Third, drop the worker model down to a cheap tier. At this point the model is only generating body content, while the numbers, the format, and the pass/fail verdict all belong to code.

Here's real code showing why this is safe. Below is a validation gate for a skill that turns a Twitter timeline into a Slack digest, run against an actual production artifact. This skill fires five times a day and has produced more than 1,000 records cumulatively. It used to run Opus on every tweet; now it runs on Sonnet.

```
$ tweet_validate.py --dir outputs/twitter/hjguyhan
validated: 2/2 passed; decisions=1 (code-capped)
{"status": "ok", "passed": 2, "total": 2, "decisions": 1, "failed_ids": []}
```

Character count, link count, status enum, and pass/fail here aren't values the model claimed. They're values code recomputed straight from the actual strings. The decision flags were also capped by code to the top few. This gate behaves identically no matter which model wrote the content, which is exactly why dropping the worker from Opus to Sonnet didn't cost us any quality.

The sales CRM briefing follows the same structure. Below is real output from a renderer that takes a data JSON file and stamps out the Slack format deterministically.

```
$ sales_crm_render_brief.py --data brief.json --print-slack
:sunny: *ThakiCloud Sales Daily Brief* - 2026-07-03 (Thu)
*③ Urgent Actions*
1. [Company A] GPU expansion RFP deadline approaching <Electronic Times 2026-07-02>
...
```

Header numbering, link syntax, and thread structure are all glued on by code. That's why orchestration and formatting have been pushed down to Sonnet plus code, while only the copy that reaches the customer directly is deliberately kept on a stronger model. Where you downgrade and where you hold the line stays cleanly separated.

## A cost-optimization skill: measure, downgrade, roll back

Once the format is in code, the next question is whether the skill can actually move to a cheaper model. That's not a call a person should make by eyeballing outputs. So we built a cost-optimization skill that runs a real task on both the current tier and a cheaper candidate tier, and lets code score the results and render the verdict.

The mechanics are simple. Pick one representative task, run it on both the cheap model and the current model, have a judge model score each dimension, and let code compute the verdict from those scores. If there's no real reasoning gap and the overall score difference falls within a threshold, the skill downgrades. If there is a reasoning gap, it stays put. Every downgrade gets recorded in a central policy file, and if that skill later fails repeatedly, it's automatically escalated back up to the stronger model. It's a two-way policy: it saves money, but the moment quality wobbles it climbs back to the expensive model.

The key point is that this gate is a truth machine, not a downgrade machine. We tested whether our humanizer skill (which strips AI-sounding phrasing from writing) could move from Sonnet to Haiku. Here's what came back.

```
$ cost_evolve.py evolve --skill humanizer
{ "skill": "humanizer", "current": "sonnet", "candidate": "haiku",
  "headline_gap": 2.0, "reasoning_gaps": 1, "decision": "hold",
  "reason": "1 reasoning gap(s): rephrasing_naturalness",
  "recommend": "Codify the format gaps first" }
```

The gate refused the downgrade. Haiku genuinely fell short at rewriting sentences to sound natural. At the same time, it flagged three formatting gaps and told us those can be pushed into code. That's precisely the judgment we want: not downgrading indiscriminately, but picking out only what the data says is safe to downgrade.

## Paxis runs this decision automatically, every night

A one-time manual optimization pass doesn't stay useful for long. Skills keep multiplying and models keep changing underneath them. So inside Paxis, this decision runs on autopilot every night. Each night it surfaces downgrade candidates, runs them through the code gate, applies the downgrades that pass, and reports the rest along with the reasoning.

This is live today. Here's an actual candidate report from the last few days, unedited.

```
# cost-evolve candidates - 2026-07-03
10 candidate(s), ranked by est. savings.
| lever            | target   | action                              |
| model-deescalate | sod-ship | opus -> sonnet, apply only if PASS  |
| model-deescalate | eod-ship | opus -> sonnet, apply only if PASS  |
| mcp-prune        | codegraph| disable unused MCP server            |
| format-determinism | ...    | extract format into code, retry downgrade |
```

Worth being honest about one thing here: this system doesn't cut costs aggressively. The sod-ship and eod-ship skills above had just been promoted to a stronger model the day before, and the gate held off downgrading them, reasoning it was still too soon to reverse course. It only acts when it's actually confident. Meanwhile, the default tier for the bulk of our skills is already cheap. The handful pinned to a stronger model are the ones where quality genuinely matters, like blog editing, news comics, and customer-facing copy, and everything else only climbs up when the data demands it.

Here's the current state of things:

| Skill | Current | Verdict | Rationale |
| --- | --- | --- | --- |
| twitter-timeline | Sonnet | Downgraded | Format pushed into code, Opus to Sonnet, running normally every day |
| humanizer | Sonnet | Held | Haiku falls short at natural rewriting |
| sod/eod-ship | Opus | Held | Promoted yesterday, too soon to reverse |
| Everything else | Sonnet | Kept | Cheap tier was the default from the start |

Expensive models are the exception. Cheap models are the default. And that line gets redrawn by data every single night.

## If you have local GPUs, you can run the cheap tier yourself

Everything so far has been about moving tiers inside commercial APIs. Teams with local GPUs can take this a step further, because a meaningful chunk of that cheap tier can now be run directly on small open-weight models. Tool-calling capability in small and mid-sized open-weight models has recently reached a level that actually holds up in production.

Google's Gemma 4 is released under Apache 2.0, and its small E2B and E4B variants run on-device on phones and Jetson-class boards, a good fit for routing, classification, and simple tool-calling workers. Zhipu's GLM 5.2 is MIT-licensed and open-weight, leans hard into agentic tool use, and gets close to closed frontier model performance. Moonshot's Kimi K2.7-Code is an open-weight model built specifically for coding and multi-step tool execution. Across the industry, teams are already routing 60 to 80 percent of agent traffic to open-weight models like these, and sending only the genuinely hard remainder up to a frontier API.

Our point here is simple. Most of what a team's agents do isn't high-difficulty creative work, so that portion runs fine on a small model on your own hardware. Keep the frontier model around, and reserve it for the small slice of work that's genuinely hard.

## If you need help

If your team wants to combine recent open-weight models like GLM 5.2 and Kimi K2.7-Code to optimize cost, get in touch. We'll work with you to decide which tasks move to which tier, and what gets locked down with a code gate.

If your team has any local GPU capacity, we recommend our Metis inference platform. It optimizes inference for the hardware you already own, so small open-weight models run as efficiently as possible on your own infrastructure.

A structure where cheap models are the default and expensive models are the exception doesn't stay that way after a single setup pass. It needs a loop that measures every night, downgrades only when it's safe, and rolls back the moment something slips. Paxis provides that loop as a system.

## References

The licenses and agentic tool-use performance of the open-weight models mentioned above can be verified in the sources below.

- [Best Open-Source LLM Models in 2026 (Hugging Face Blog)](https://huggingface.co/blog/daya-shankar/open-source-llms)
- [GLM 5.2 vs Kimi K2.7 Code: Two Open-Weight Bets on Agentic Coding (Groundy)](https://groundy.com/articles/glm-5-2-vs-kimi-k2-7-code-two-open-weight-bets-on-agentic-coding/)
