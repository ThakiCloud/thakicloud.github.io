---
title: "When the Compliance Dashboard Reads 0%, Is It the Process Failing or the Sensor?"
seo_title: "Instrumentation Bias in Agent Governance: The Trap in Fan-Out Verification Closure Rates"
seo_description: "We audited a multi-agent harness's fan-out verification rule against real operational logs and got a 5% closure rate. We introduce a paper that formalizes why this number is only a floor on the true compliance rate, not the rate itself, as a new failure mode called instrumentation bias."
excerpt: "We tried to measure compliance with a fan-out verification rule and got 5%, and the re-experiment meant to validate that number returned exactly zero. Neither failure happened because the rule was missing. Both happened because the measurement path was never open."
date: 2026-08-14
tags:
  - instrumentation-bias
  - agent-governance
  - observability
  - multi-agent-fanout
  - audit-methodology
  - closure-rate
categories:
  - research
author_profile: true
toc: true
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/research/instrumentation-bias-agent-governance/"
audiobook: "https://drive.google.com/file/d/1zCysx3QOuW5fvGTGMUwcf2bfupaUWHxF/view"
audiobook_label: "▶ Listen: 5-minute briefing"
audiobook_note: "NotebookLM audio overview (AI-generated)"
---

If you run a fan-out architecture in production, one where multiple subagents launch in parallel and their results get merged into one, and you have a rule written down somewhere that a verification stage must run before that merge, this post is for you. When we counted actual compliance with that rule in our own production coding-agent harness, we got 5%. A follow-up experiment meant to check whether that number had improved returned not a single data point. Neither incident happened because the rule went unfollowed. Both happened because there was no path to measure whether it had been followed at all. This paper puts a name to that gap and shows why a quiet dashboard is not a signal that things are fine, it is a question with two possible answers.

![Illustration of the core idea of When the Compliance Dashboard Reads 0%, Is It the Process Failing or the Sensor?](/assets/images/instrumentation-bias-agent-governance-hero.webp)
*A visual metaphor for the article's key idea.*

## What Does the Number 5% Actually Prove

The fan-out pattern, dispatching multiple subagents in parallel and merging their results, is structurally risky. Errors in individual branches get laundered during the merge, so the combined output looks more confident than it should, and the natural point at which you would notice a wrong branch disappears. That is why many production harnesses adopt a rule that a verification stage must run before merging. The team behind this paper had adopted the same rule. After running it for months, though, they asked the obvious question: was it actually being followed?

Counting seemed simple. Every closure leaves a receipt in a ledger, and every fan-out dispatch is recorded in the session transcript, so dividing one by the other gives you the compliance rate. Scanning 1,877 production sessions turned up 180 fan-out dispatch events, of which 9 left a receipt: 5.0%.

![Baseline: 5.0% Fan-Out Closure Receipt Rate](/assets/images/posts/research/instrumentation-bias-agent-governance/fig1.webp)
*Results from auditing 1,877 production sessions. Of 180 fan-out dispatch events, 9 left a receipt (5.0%), and the remaining 171 were left in a state where compliance could not be determined.*

There are several ways to read that 5%. The first reading is that the rule was ignored 95% of the time. The second is that verification happened often but simply went unrecorded. Leaving a receipt in the original workflow meant writing a JSON verification record by hand, setting a kill/keep threshold, and manually invoking a logging script, five steps in all, and almost no one voluntarily completes that procedure once they already feel the verification itself is done. The third reading is that the measurement itself is an artifact of where and how it was observed. Under the framework this paper builds, the number the dashboard showed does not distinguish among any of these three.

## Instrumentation Bias: Having a Rule Is Not the Same as Being Able to Measure It

The paper names this phenomenon instrumentation bias. It defines two separate indicators: C_true, whether verification actually happened, and C_obs, whether a receipt for it is visible to the auditor, and defines the gap between their expected values, Δ, as instrumentation bias. In this system, a receipt guarantees that verification really happened, but the reverse does not hold. Verification can happen without leaving a receipt, for instance when it is done ad hoc mid-conversation or when an operator eyeballs the result. So Δ is structurally always at least zero, and the compliance rate a dashboard shows is only a floor on the true compliance rate. This asymmetry is dangerous because a low dashboard number is always compatible with a situation where actual compliance is high. The dashboard alone cannot tell you whether the process is broken or the sensor is.

The paper breaks the path that opens Δ into three mechanisms. Manual-step friction is when someone knows the logging procedure exists and is willing to follow it, but the procedure feels disproportionately expensive relative to the verification they have already completed. The tooling-awareness gap is when the orchestrating model's attention, at the moment of dispatch, is fixed on the substantive task and has no room left to recall the governance procedure. The hardest to deal with is the scope-parity gap: verification really happened and a receipt really was left, but the audit tooling runs on a different host, container, or network partition and simply cannot see it. Of the three, this is the most dangerous, because the signal that reaches the dashboard is indistinguishable from full non-compliance.

![Where Each Mechanism Suppresses the Receipt Signal](/assets/images/posts/research/instrumentation-bias-agent-governance/fig2.webp)
*A conceptual diagram with no figures attached. For behavioral compliance to become observable, a receipt must be emitted and that receipt must be collected by the auditor. Friction and the awareness gap suppress the emission step, while the scope-parity gap suppresses the collection step.*

The paper draws one distinction worth emphasizing here. Instrumentation bias is a different problem from Goodhart's Law, the observation that a measure stops meaning anything once it becomes a target. Goodhart's phenomenon is a validity problem: the metric keeps getting produced, but the process that produces it gets distorted. Instrumentation bias is a completeness problem: when the metric is produced correctly it is trustworthy, but it either does not get produced often enough or gets produced somewhere the auditor cannot reach. The two call for opposite responses. Guarding against Goodhart bias means being suspicious of a metric that looks good. Guarding against instrumentation bias means being suspicious of one that looks bad, or shows nothing at all.

## The Measurement: Root Cause, and a Second Failure

That same day, the team shipped two fixes. They replaced the five-step manual flow with two commands, `plan` and `tally`, moving threshold decisions, deduplication, and verification tallying from human judgment to deterministic code. They also attached a hook that fires automatically at dispatch time, so the receipt procedure gets surfaced at the exact moment a fan-out happens. Each fix targeted one mechanism precisely: the first targeted friction, the second targeted the awareness gap.

To check whether the fix actually raised the closure rate, the team designed a before/after natural experiment: split the timeline at the moment the hook shipped, and compare the receipt ratio in each window with a two-sample proportion test. When they ran it, both windows returned zero observations. Session files, dispatch calls, and ledger entries all came back as zero, and both z-statistics were undefined, impossible to compute at all.

The cause was a scope-parity gap in the audit tooling itself. Session transcripts get written under the local home directory of the machine running the interactive session, but this re-run scan executed on a separate batch compute node, one where that directory did not exist at all. The glob pattern expanded to an empty set, and every downstream aggregation deterministically inherited zero. What makes this trickier is that the failure was silent. The job exited cleanly with no error and reported zero in every field, exactly the shape you would get if verification genuinely never closed at all. The scan logic, the window parameters, the statistical design, and the ledger path were all correct. Every component a code review could inspect was fine, yet the result was empty. Whether an auditor stands in the same place as what it is auditing is a deployment property that no unit test, no code review, and no reasoning trace from the model that wrote the scanner could have caught.

## Three Implications This Result Leaves Behind

This incident leaves a different lesson at each of three levels. At the level of a single company, it yields a practical directive: when you quantify fan-out verification compliance in your own harness, verify separately that the rule exists and that the rule is instrumented. Treat those two as the same thing at the policy-design stage, and you will repeat both failure modes: misdiagnosing a process that is actually working well as broken and over-correcting it, or mistaking a system that no one is watching for a healthy one.

At the social level, this carries implications for the AI audit and regulation debate. The machine-readable compliance frameworks now emerging raise the value of evidence that reaches the ledger, but they do nothing for evidence that was never generated or never collected in the first place. If anything, they make the result look more plausible and authoritative without making it more complete. So the paper's proposal is that these frameworks should carry, as a required field alongside the compliance number, coverage metadata stating how much of the actual scope the auditor was able to observe.

At the scientific level, the core contribution is formalizing a new failure mode for autonomous agent harnesses. The paper decomposes instrumentation bias into three mechanisms, distinguishes it from the Goodhart phenomenon, and proposes a protocol for measuring it with a before/after natural experiment run against real production session logs, thousands of sessions and hundreds of fan-outs. What makes this paper most persuasive, though, is that the first attempt to run that protocol became a live instance of the third mechanism the framework itself predicted, the scope-parity gap. The team that had just finished cataloguing instrumentation bias reproduced that exact failure with its own hands.

## Limits and Next Steps

This study covers a single production harness at a single team. The figure of 5.0% reflects the tool usability of that system at that particular time, and the paper does not claim similar numbers would show up elsewhere. What it claims generalizes is not the number but the framework itself, and the structural principle that existence, instrumentation, and scope parity have to be checked as three separate properties.

The more fundamental limit is that, because the natural-experiment re-run failed, the paper cannot report a validated number for the actual effect of the fixes. It has only the pre-fix baseline and a live demonstration of the scope-parity failure mode. It cannot yet say that the two-command tool and the dispatch hook actually raised the closure rate. There is also no oracle that can independently confirm true compliance, C_true, so Δ remains a theoretical quantity that is clearly defined but not yet estimable, and the before/after design itself has a structural weakness: it cannot separate two channels, compliance that rose because logging got easier, and compliance that rose because people knew they were being watched. The top priority for the next step is re-running the experiment with a scanner that executes in the same scope as the interactive sessions, and adding a liveness assertion that fails loudly rather than quietly reporting zero when it finds no session files. After that, the goals are extending the protocol to other production harnesses and building an oracle, humans sampling and reviewing receipt-less fan-out events directly, that would turn Δ from an estimate into a calibrated value.

Paper detail page: [https://huggingface.co/datasets/thaki-AI/daily-paper-2026-08-14-instrumentation-bias-agent-governance](https://huggingface.co/datasets/thaki-AI/daily-paper-2026-08-14-instrumentation-bias-agent-governance)
