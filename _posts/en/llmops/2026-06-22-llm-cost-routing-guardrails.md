---
title: "How We Controlled LLM Operating Costs with Routing and Guardrails - Lessons from a $705/Day Incident"
excerpt: "We honestly disclose a $705 single-day billing incident and prove with numbers the root cause found in a one-month audit (Opus main session at 90.3%) along with the remedies: model routing, retro-based escalation, cron offloading, and context hygiene. Includes the path to productization with Praxis's cost-aware router."
seo_title: "LLM Cost Optimization in Practice: How Model Routing and Guardrails Prevent a $705/Day Incident - Thaki Cloud"
seo_description: "We disclose a $705 single-day Claude Opus overuse incident and a one-month $4,691 audit. We explain with numbers and code the cost control mechanisms we actually run in production: model routing, retro-based automatic escalation, cron offloading, and context hygiene."
date: 2026-06-22
last_modified_at: 2026-06-22
categories:
  - llmops
tags:
  - cost-optimization
  - llm-routing
  - model-routing
  - guardrails
  - token-economics
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
lang: en
canonical_url: "https://thakicloud.github.io/en/llmops/llm-cost-routing-guardrails/"
reading_time: true
---

![LLM Cost Routing Guardrails in Practice](/assets/images/llm-cost-routing-guardrails-hero.png)

## Overview: A Story That Began with a $705 Bill

On June 1, 2026, the Anthropic billing dashboard showed roughly $705 in charges for a single day.

All nine sessions were running on Opus. One monitoring session alone ran for 9.4 hours, 1,145 turns, and 138 ScheduleWakeup cycles, consuming $381. That single monitoring loop accounted for 54% of the entire day's cost. cache_read was 195M tokens, which represented 42% of the total bill.

It didn't take long to identify the cause. It was not a cache-miss problem. It was the result of a massive context accumulating repeated turns, multiplied by Opus pricing (input $15/MTok, output $75/MTok).

This post honestly discloses the results of a one-month cost audit triggered by that incident, along with four control mechanisms we actually run in production. At the end, we explain how this operational knowledge was productized in ThakiCloud Praxis and AI Platform.

---

## Where the Cost Leaks: One-Month Audit Results

After the incident, we analyzed one month of billing data using `cost_audit.py` and `router_audit.py`. Of the total $4,691 in costs, the most striking finding was this.

**90.3% of the cost came from Opus main session turns.** The session default model -- not the subagents -- was the largest leak point.

Intuitively, one might think "spawning many subagents makes things more expensive." Reality was different. Subagents were already using Sonnet, and the sub LLM routing compliance rate was 96.4%. The problem was that the orchestrator -- the session's main model -- was fixed to Opus. Hundreds of turns involving file searches, simple Q&As, and pipeline orchestration that Sonnet would have handled perfectly were all processed at Opus pricing ($15/MTok).

The counterfactual savings calculated by `router_audit.py` were clear. Switching the main to Sonnet would create $3,388 in headroom. Improving sub routing would save another $1,533/month, for a total of 80.4% reduction. That means more than $3,800 of the $4,691 was unnecessary spending.

What determines cost is not unit price but frequency. The difference between using Opus for 10 turns a day versus 1,000 turns is far greater than the unit price difference between Opus and Sonnet ($15 vs $3).

Here are the model unit prices summarized:

| Model | Input ($/MTok) | Output ($/MTok) | Cache Read ($/MTok) | Relative Cost |
|-------|---------------|-----------------|---------------------|--------------|
| Haiku | $0.80 | $4.00 | $0.08 | ~1x |
| Sonnet | $3.00 | $15.00 | $0.30 | ~4x |
| Opus | $15.00 | $75.00 | $1.50 | ~19x |

The input price difference between Opus and Haiku is roughly 19x. Running a single exploratory task on Haiku instead of Opus enables 18 additional Haiku calls with the cost saved.

---

## Model Routing: Task Nature Determines Model Tier

The first principle established from the audit is simple. **Always specify the model parameter explicitly and use the tier appropriate for the task.**

Omitting the `model` parameter in an Agent tool call causes it to run at the session default model (Opus if that's the default, at $15/MTok). This is the root of subagent cost leakage. In the Claude Code environment, valid values are `"haiku"`, `"sonnet"`, and `"opus"`. No separate slug mapping is needed.

Here is how we operate the routing table:

- **Exploration, file reading, grep, simple lookups**: `haiku`. Read-only work that only needs structured output. Tasks summarizing or comparing three or more files also belong here.
- **Codebase research, summarization, translation**: `haiku`. Tasks requiring no judgment.
- **Analysis, implementation, code generation, review**: `sonnet`. This is the sweet spot balancing quality and cost; most tasks fall here.
- **Report generation, content writing**: `sonnet`. The default for generative work.
- **Architecture decisions, complex multi-step reasoning, deep debugging**: `opus`. Justified only for these cases.

```python
Agent({
  description: "Explore usage patterns in the codebase",
  model: "haiku",   # exploration/search = haiku, model must be specified
  prompt: "..."
})
```

We also route the session default model based on task nature. We open sessions with `/model sonnet` for pipeline orchestration, everyday coding, and file searches. We switch to `/model opus` only at moments that require architecture decisions.

The core of the "2K token rule" is not to grep directly from the main Opus session for search/lookup tasks, but to delegate to a Haiku subagent. Any tool output expected to exceed 2K tokens has the subagent read it and return only a summary to the main context. Dumping the raw content into the main context is prohibited.

Applying this routing consistently produced a sub routing compliance rate of 96.4%. Most of the 55 exploratory agents now run on Haiku. The savings per individual task may seem small, but hundreds of exploratory tasks per day accumulate into a $1,533/month difference.

Session lifecycle management also matters. When a session exceeds 50 turns or context exceeds 40%, we start fresh with `/clear`. In mega-sessions, cache_read grows linearly per turn as the context swells. This is why cache_read costs were 42% of the total in the June 1 incident.

---

## Retro-Based Automatic Escalation: Data Decides the Model

The practical counterargument that "locking all skills to Sonnet would kill quality" is valid. Skills whose output quality is the product itself -- such as content classification, enrichment, and thread writing -- do genuinely fall short of Sonnet quality in some cases. That is why we chose **retro-based escalation**.

The core principle is "start cheap, and when the retro detects quality or failure issues, escalate only that skill to Opus." This does not contradict the global Opus restriction. It applies only to quality-output skills, and escalation happens only on data evidence.

The default is to start with Sonnet. If consecutive bad-runs exceed 2, that skill alone is automatically promoted to Opus. A clean run resets the streak, but there is no automatic demotion. Once a skill needed Opus, it can only be lowered manually. Failures and promotions trigger a Slack notification.

The implementation consists of two files.

`scripts/skills/skill_model_policy.json` serves as the central registry.

```json
{
  "skills": {
    "twitter-timeline-to-slack": {
      "model": "opus",
      "pinned": true,
      "reason": "classification+enrichment+thread writing quality threshold",
      "fail_streak": 0
    }
  },
  "_default": {
    "model": "sonnet",
    "escalate_to": "opus",
    "max_fail_streak": 2,
    "fail_streak": 0
  }
}
```

The runner fetches the model from the policy before execution and records the retro on exit.

```bash
SKILL_NAME="bespin-news-digest"
MODEL="${MY_MODEL:-$(python3 scripts/skills/skill_retro.py get-model "$SKILL_NAME" 2>/dev/null || echo sonnet)}"

# ... run claude -p --model "$MODEL" ...

python3 scripts/skills/skill_retro.py record "$SKILL_NAME" "$RC" "$RUN_LOG" 2>/dev/null || true
```

Bad-run detection is conservative. We count only `rc != 0` or log markers: `Failed to authenticate`, `API Error:`, `Traceback`. A single transient network error does not trigger escalation. The streak must accumulate. This conservatism is important. Aggressive detection would send every transient blip to Opus, eliminating the cost-control benefit.

Removing the model key for a skill from the plist `EnvironmentVariables` allows the policy to take effect. We only add the environment variable back when a manual override is needed. This structure means we do not need to decide "which model to use" upfront when adding a new skill. Start with Sonnet, and the data will promote it.

When quality feels insufficient, the first thing to do is **add a verification step**. Before escalating the model, try attaching an adversarial verify step to the fan-out results. The more common cause of quality issues is not a weak model but the absence of a verification stage. Configuring workers cheaply and putting only the final verification step on Opus maximizes quality per cost.

---

## Cron Offloading and Context Hygiene

The monitoring session that accounted for 54% of the June 1 incident was actually a task that Claude did not need to judge at every tick. Price snapshots, state comparisons, and health checks can run without Claude.

**Offload recurring monitoring out of the Claude hot-loop to cron.** Cost drops to $0.

```bash
# Run every 5 minutes; Slack alert only on anomaly detection
# com.thaki.toss-monitor.plist
scripts/toss_monitor_tick.sh
```

The key principle of this pattern is "invoke Claude only when there is a human or an event." Shell scripts handle all state polling; Claude is woken only when a threshold is crossed or an anomaly signal is detected. The 138 ScheduleWakeup cycles that burned $381 that day were mostly simple state checks. Extracting those to cron means Claude costs never arise.

If a Claude loop is truly necessary, we follow three rules.

First, use only Haiku or Sonnet. Opus is not justified for monitoring. Using a model that costs 19x more for simple state comparisons is wasteful. Second, keep state in a file (`monitor-state.json`) so each wakeup starts with minimal context. We read only the state file and make a judgment rather than pulling the entire prior conversation. Third, run `/clear` before a session exceeds 50 turns or 40% context.

We enumerate the specific anti-patterns the June 1 incident revealed in context hygiene. The same file was read 10 times within one session. We ran `cd` 153 times, yet git operates on the current working directory directly, so no `cd` prefix is needed. Large outputs were dumped raw into the main context. These three things drove cache_read to 42% of total cost.

Within a session, never re-read a file already read. Write large tool outputs to `/tmp/scratch-{task}.md` and return only the path to main. If repetitive-structure JSON array outputs are heavy, use headroom SmartCrusher compression. [estimate] Benchmarks show 50%+ savings are achievable. Prefixing with `rtk` also compresses shell output by 60-90%.

---

## Praxis, AI Platform: Productizing Operational Knowledge

This operational experience translated into two ThakiCloud products.

**Praxis's cost-aware LLM router** automatically switches to lower-cost models as budget headroom decreases. The per-step automatic model selection logic described above is implemented at the product level. When 70% of monthly budget is consumed, the default model drops to Sonnet; above 90%, it falls back to Haiku. Quality-threshold skills are pinned and excluded from demotion.

**AI Platform's cost tracking and quota control** aggregates LLM costs separately per team and project. The platform performs auditing equivalent to cost_audit.py automatically, and sends an alert when a particular team's Opus usage share exceeds a threshold. It applies the same mindset as coordinating GPU workloads with Kubernetes Kueue -- to LLM token budgets.

`claude-code-ccr-cost-routing` is a different direction of optimization. The main model stays on Anthropic, while subagents are routed to third-party providers (MiniMax, GLM, DeepSeek, Qwen). Exploration, summarization, and translation are handled at far lower unit costs than Sonnet, while the main orchestrator's consistency is preserved.

These three approaches share one thing in common. **Cost is not left to chance; code controls it deterministically.**

---

## Limitations and Lessons

There are limitations we must honestly disclose.

**Retro-based escalation has no automatic demotion.** Skills promoted to Opus can only be lowered manually. Over time, the number of pinned Opus skills may grow. Periodic manual review is required. This is a deliberate design choice. The conservative judgment is "don't demote a skill that once needed Opus without data," and the tradeoff is accepting the possibility of drift.

**Setting quality gates too strictly lengthens the re-dispatch loop.** Thresholds must be set realistically against historical pass rates. Trying to design a perfect gate from the start stalls operations. This is also why bad-run detection is designed conservatively. If a single transient network error triggered automatic Opus promotion, the cost-control benefit would be cut in half.

**Cost guardrails alone cannot substitute for quality.** The mechanisms described in this post are about maintaining quality while reducing cost -- not sacrificing quality to reduce cost. If quality drops in a specific skill, it is by design that the streak naturally promotes it to Opus.

The biggest lesson is this. **Model cost is determined not by model unit price but by frequency of model selection.** Even if Opus is priced at $15/MTok, if Opus is rarely used, costs stay low. Conversely, even if Haiku is $0.80/MTok, running it in a 1,145-turn loop generates substantial cost.

The second lesson is this. **Diagnose the root cause of quality issues first.** When you feel Sonnet is insufficient, the first thing to check is not the model tier but whether a verification step exists. If fan-out results are consumed without adversarial verification, quality will be unstable even with Opus. Workers configured cheaply with only the final gate on Opus is the correct direction.

The correct adoption sequence is as follows.

1. Offload loops and monitors to cron, eliminating Claude costs entirely.
2. Lower the session default model to Sonnet. This is the biggest lever on total cost.
3. Make the `model` parameter mandatory in all subagent calls.
4. Run `cost_audit.py` for one week to audit costs and identify leak points.
5. Escalate only skills with genuine quality shortfalls to Opus via the retro mechanism.
6. Repeat the audit periodically and adjust by watching the numbers.

Following this sequence, the $705/day incident will not recur. At the same time, a system takes shape where tasks where Sonnet quality suffices run on Sonnet, and explorations where Haiku suffices run on Haiku.

---

ThakiCloud is incorporating this operational experience into Praxis and AI Platform. If you are curious about how cost-aware LLM routing works as a product, contact us at [hello@thakicloud.co.kr](mailto:hello@thakicloud.co.kr).
