---
title: "When Should a Skill Be Born? The Synthesis-Versus-Reuse Decision Boundary in Self-Evolving Agents"
seo_title: "Skill-Birth Decision Boundary: An Empirical Study | ThakiCloud Tech Blog"
seo_description: "We cover a paper that audited 811 commits and 1,972 skill-birth events to measure when a new skill should be automatically synthesized. The core finding is not whether a skill gets reused, but how fast and how intensely."
excerpt: "Auditing a self-evolving agent's skill library found that how fast a new skill gets reused is a far stronger signal than whether it gets reused at all."
date: 2026-07-31
tags:
  - skill-synthesis
  - agent-harness
  - self-evolving-systems
  - skill-ecosystem
  - decision-boundary
  - capability-gap-detection
categories: [research]
author_profile: true
toc: true
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/research/skill-birth-synthesis-boundary/"
audiobook: "https://drive.google.com/file/d/1TtM8KLEzpOqkHnQFK2vpyC6X5z3jNwzY/view"
audiobook_label: "▶ Listen: 5-minute briefing"
audiobook_note: "NotebookLM audio overview (AI-generated)"
published: false
---

If you operate an agent harness that grows its skill library automatically overnight, or if you are the kind of team stacking up skills one at a time without a dedicated automation group, this post is for you. The paper we cover today answers the question of whether a new skill can safely be synthesized on the spot when no existing skill clears the retrieval gate, and it grounds that answer in an audit of real production commit history. It comes from a full audit of the git history behind the self-evolving agent skill ecosystem that ThakiCloud uses for routing every day, tracking quantitatively how skills were born and how fast and how intensely they were reused afterward.

![Illustration of the core idea of When Should a Skill Be Born? The Synthesis-Versus-Reuse Decision Boundary in Self-Evolving Agents](/assets/images/skill-birth-synthesis-boundary-hero.webp)
*A visual metaphor for the article's key idea.*

## Why and When Should a Skill Be Born

Anyone running a skill-based agent harness eventually hits the moment when the router cannot get a single existing skill through the retrieval gate for a given request. At that point the harness has three paths open to it: answer natively without a skill, stitch together several existing skills as a stopgap, or pay the cost of authoring a brand-new skill.

The four prior papers this research team has published on the skill ecosystem all dealt with how to find existing skills better, when to retire them, and how to reweight them, never with whether to create one in the first place. The nightly repair loop that lifted routing accuracy from 32.8% to 52.9%, and the retirement study showing top-1 accuracy dropping 42.2 percentage points as the corpus grew from 100 to 2,164 skills, both took the existence of a skill as given and then worked with it. The question one step upstream of routing, of when to give birth to a genuinely new skill, has stayed open until now. This paper fills that gap with measurement.


## Tracing 1,972 Births Across 811 Commits

The research team audited the complete git history of the production skill directory that the agent actually uses for routing every day. Walking backward through 811 commits, they defined a birth as the moment a SKILL.md manifest was first added at a given path, and secured a total of 1,972 birth events.

Each birth is assigned to one of five source cohorts based on how many manifests were added together in the same commit and the pattern of the commit message: mass imports where twenty or more manifests land at once, autonomous pipeline synthesis created by nightly or scheduled automation, sync imports mirrored in from another repository, deliberate feature authorship where a human explicitly committed with a message like "feat: add X," and unclassified singleton additions that arrived with no expressed intent at all. Every skill was then tracked forward in time to see whether it was modified again, and if so, how quickly and how many times. Because this counted the entire population of 1,972 events rather than a sample, the paper reports plain descriptive statistics rather than confidence intervals or p-values.

## The Core Finding: Not Whether Skills Get Reused, But How Fast and How Hard

The first number that stands out is reuse itself. 39.0% of individually authored skills, meaning everything except mass imports lumped together, were eventually modified again, versus 35.1% of mass-imported skills. A 4-percentage-point gap is not large. Looking at that number alone, it would be easy to conclude that reuse rates are similar regardless of how a skill was created, so bulk-importing packages is cheap and reasonable.

But the story changes completely once you look at how long it took, among skills that were reused at all, to reach their first reuse. Individually authored skills got touched again at a median of 1.2 days, while mass-imported skills took 29.0 days, roughly a 24x gap. The picture is the same by modification intensity: individually authored skills were modified an average of 1.11 times after birth, versus 0.54 for mass-imported skills. This average includes the 0 count from skills that were never reused at all, so it is not explained away by sample bias.

![Bar chart comparing reuse rate by source cohort](/assets/images/posts/research/skill-birth-synthesis-boundary/fig_reuse_rate_by_cohort.webp)
*Reuse rate by source cohort. The deliberately authored deliberate_feat cohort is highest at 45.1%, with mass imports below it.*

The gap widens further once you split by cohort. The deliberately authored deliberate_feat cohort had the highest reuse rate at 45.1%, while other_singleton, which arrived with no expressed intent at all, was lowest at 28.2%. Even for similarly sized single additions, whether the commit message carried the intent "this is a new feature" alone opened a 17-percentage-point gap in reuse rate.

![Median days to first reuse by cohort, log scale](/assets/images/posts/research/skill-birth-synthesis-boundary/fig_median_days_reuse.webp)
*Restricted to cases where reuse occurred, individually authored skills reach first reuse 24 times faster than mass imports (median 1.2 days versus 29.0 days).*

The research team reads this economically. A skill that takes 29 days to be reused sits as pure debt on the library for that entire month. It adds retrieval noise, occupies index space, and competes with skills that are actually being used for the router's attention. In this dataset, mass import is both the channel that grows the corpus fastest, accounting for 75.2% (1,482) of all births, and the channel with the weakest and slowest reuse signal. That does not mean mass import is always wrong, but it does mean the intuition that "importing is cheap" only counts authoring cost and leaves out the standing cost of degraded retrieval performance.

## The Surprising Finding: Autonomous Synthesis Is Underused, Not Overused

The most counterintuitive part of this paper is the pipeline_autonomous cohort, skills a scheduler synthesizes on its own with no human in the loop. The literature often worries that skills created automatically by a scheduler, with no human involvement, are the main driver of noisy skill sprawl. The actual data shows the opposite picture.

![Bar chart of mean modifications after birth by cohort](/assets/images/posts/research/skill-birth-synthesis-boundary/fig_mean_modifications.webp)
*The pipeline_autonomous cohort has the highest reuse intensity at a mean of 2.83, more than double any other cohort, though its sample of 30 is the smallest.*

The autonomous synthesis cohort is the rarest of all, just 30 of the full 1,972, or 1.5%. Yet its modification intensity averages 2.83, more than double any other cohort, well ahead of the next highest, sync_import at 1.36 and deliberate_feat at 1.26. Its never-reused rate is also the second lowest at 56.7%, trailing only deliberate_feat at 54.9%. Skills born from autonomous synthesis get abandoned less often, and once used, they keep getting used actively. The problem was never quality, it was volume: while 255 deliberate_feat skills were born, only 30 autonomous ones were, an 8.5x gap.

The research team attaches two caveats to this result. One is that a sample of 30 leaves the average vulnerable to being pulled around by a handful of heavily modified skills. The other is that causality could run in reverse: the autonomous synthesis channel may so far have only been deployed selectively, into gaps that were already obviously needed. Even so, this signal points against the conventional wisdom that autonomous synthesis should be suppressed by default, and the paper offers it as grounds for gradual expansion paired with monitoring.

## The Skill-Birth Decision Policy (SBP): Four Axes

Building on this empirical result, the paper proposes a Skill-Birth Decision Policy (SBP), four axes for deciding, when a router fails to clear the retrieval gate and is about to give up on a response, whether to fall back to native, compose existing skills, or synthesize a new one.

The first axis is repeatability: has the same gap been seen twice or more? A one-off miss has no future over which to amortize authoring cost, so native fallback is the right answer. The second is composability: if two or three existing skills can be chained to cover the gap, prefer composition. Composition costs almost nothing to author and does not grow corpus size, avoiding the cost of degraded routing accuracy. The third is batch opportunity: if this gap is part of an external package that fills several related gaps at once, mass import can be justified too, though filling one isolated gap with a mass-import approach is the worst possible combination. The fourth is the authorship channel: once synthesis is justified, author it as a commit that explicitly labels its intent, and where a response failure has already recurred and the specification is clear, the paper suggests treating the autonomous synthesis channel as the leading candidate.

The research team is explicit that this policy has not yet been wired into a real router and validated. In an earlier paper they trained routing weights using an online reward signal alone, the reward metric went up, but a native-query hallucination rate the reward function could not see quietly rose along with it. Taking that lesson to heart, this policy is presented not as a validated intervention but as a hypothesis grounded in retrospective data.

## What This Means for Company, Society, and Science

The implications split into three layers. For the company, ThakiCloud's self-evolving agent harness gains measured triggers and guardrails for judging the return on investment of its nightly skill-generation pipeline. The signal that the autonomous synthesis channel deserves more confidence rather than less is something operational policy can act on directly. Socially, this gives companies without a dedicated skill-engineering organization a basis for turning the impulse of "let's just write a new skill" into an auditable policy. Scientifically, this is the first study to characterize the synthesis-versus-reuse decision boundary and the survival curve from birth to reuse for autonomously synthesized skills in a self-evolving agent ecosystem using real production data. Prior work on skill routing, retirement, and rollout all assumed the skill already existed; this paper asks how that skill should have been born in the first place.


## Limits: What We Still Don't Know

The paper discloses five limitations of its own. This is an observation from a single organization and a single repository, so the cohort ordering could reverse in other organizations. Cohort classification is a lexical approximation based on commit-message regex and batch size, not a verified read of actual authorial intent. There is also right-censoring: more recently born skills have had less time to be observed reaching reuse. Because reuse was defined as the existence of a later modifying commit, unrelated tidying such as a bulk formatting pass can register as reuse, and conversely a skill called hundreds of times but never modified once registers as no reuse.

The most decisive limitation is survivorship bias. A gap that was never even attempted as a skill and kept falling back to native leaves no trace whatsoever in git history, so it is fundamentally unobservable by this method. The research team states that closing this gap will require instrumentation at the router level that logs response-failure events by capability as the next step. Actually validating the policy will require gating a slice of router traffic through SBP and remeasuring the same birth-to-reuse survival metrics split between the policy-treated group and the existing baseline.

Full paper details are available on the following page.

[Skill Birth: Calibrating the Synthesis-versus-Reuse Decision Boundary in Self-Evolving Agent Skill Ecosystems](https://huggingface.co/datasets/thaki-AI/daily-paper-2026-07-31-skill-birth-synthesis-boundary)
