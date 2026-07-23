---
title: "Skill Graveyard: Safely Deprecating Skills in an Agent Harness With Over 2,000 Units"
excerpt: "If your team has kept expanding its catalog of agent skills or MCP tools, you've probably felt routing accuracy start to slip at some point. What happens if, instead of building a better retriever, you shrink the corpus itself? This post introduces an experiment that deprecated 160 skills without regression in a real production harness holding 2,164 units."
tags:
  - skill-ecosystem
  - agent-harness
  - skill-routing
  - retriever-degradation
  - autonomous-deprecation
  - redundancy-detection
  - usage-telemetry
  - bm25-retrieval
  - corpus-pruning
  - self-improving-pipelines
date: 2026-07-17
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/research/skill-graveyard-safe-deprecation/"
categories:
  - research
author_profile: true
toc: true
---

Cloud and AI engineers who have kept adding skills, subagents, and MCP tools to their agent harness have likely experienced, once the catalog crosses a few hundred entries, the router picking the wrong skill or failing to pick anything at all. The paper introduced in this post tackles that phenomenon from the opposite direction of improving the retriever: shrinking the corpus itself. It is a case study that designs and empirically measures a policy for safely pruning skills, targeting a production harness with 2,164 registered units.

## The More Skills You Add, the More the Router Struggles

Agent platforms now ship capability not as one giant prompt but as a library of named, reusable skill units (workflows, subagents, slash commands, tool definitions). The problem is that as this library grows, the router's accuracy in finding the right skill drops in tandem. The paper calls this phenomenon the "SRA Noise Problem," using the same term the authors' harness already had in place. It describes how, as the number of distractor candidates grows, the probability that the correct skill lands at the top of the ranking falls.

This paper picks up directly from two earlier technical reports by the same authors. The first report broke routing failure down as a query decomposition problem, and found that even with oracle-level perfect query decomposition, the retriever recovered only 63.6% of the correct steps. The second report built a repair loop that jointly improved the retriever's synonym expansion and query decomposition, but that too failed to saturate routing accuracy. Both papers only touched the side of "making the retriever better at finding things within a corpus that keeps growing while staying fixed." This paper tests the opposite lever: shrinking the corpus itself.

## When the Corpus Grew 21.6x, Top-1 Accuracy Was Cut in Half

The authors empirically measured the relationship between corpus size and retrieval accuracy on a Claude Code harness that ThakiCloud actually operates in production (2,164 registered units, of which 1,930 are pure skill definitions). They subsampled the corpus in six steps from 100 up to the full 2,164 and measured Recall@5, gated Recall@5, and Top-1 accuracy at each step.

The results diverged sharply by metric. Top-1 accuracy collapsed by 42.2 percentage points, from 0.778 to 0.356, as the corpus grew 21.6x. Over the same range, Recall@5 fell by only 17.8 percentage points (from 0.978 to 0.800), and Recall@5 that passed the abstain gate dropped by just 4.4 percentage points (from 0.711 to 0.667), staying nearly flat past a corpus size of 250. In other words, a router that picks a single candidate and executes it immediately is leaning on the metric that collapses first.

The authors formalize this phenomenon as the concept of "skill half-life." If a metric's half-life is defined as the corpus size at which the metric falls below half of its small-corpus baseline value, Top-1's half-life already falls within the range of corpus sizes currently in production use. Recall@5-type metrics, by contrast, had not yet reached their half-life within this measurement range.

![Skill Half-Life: Retrieval Accuracy vs. Corpus Size]({{ '/assets/images/posts/research/skill-graveyard-safe-deprecation/fig-growth-curve.png' | relative_url }})
*Results of the subsampling experiment by corpus size, measured on ThakiCloud's production Claude Code harness (63-case suite). While Top-1 accuracy collapses by 42.2 percentage points across a 21.6x corpus growth range, gated Recall@5 remains relatively robust.*

## Always Re-Search Before Deleting

Building on this observation, the paper proposes an autonomous deprecation policy that combines two signals. The first is usage telemetry, which looks at call frequency, recency, and failure history. The second is semantic redundancy, which computes similarity between skill description text to find near-duplicate clusters. Notably, this similarity is the same signal the router already used for retrieval.

Selecting low-usage, redundant skills as candidates based on these two signals alone still leaves a dangerous risk of false positives, because a skill with low usage might be the only one covering a specific query. So the paper adds one more runtime safeguard. Before actually deleting a candidate, it re-simulates retrieval against a 63-case labeled suite (45 positive cases with a known correct skill, 10 native cases that must be handled directly without any skill, and 8 negative cases that look plausible but must never be selected), assuming that skill is absent. If any positive or native case can no longer be retrieved, that skill is judged irreplaceable, is removed from the deletion candidates, and the next-lowest-usage redundant skill in the same cluster becomes the deletion target instead. If all candidates within a cluster are exhausted with no replacement skill available, the policy does not force the target reduction to be met and instead simply records the shortfall.

## 160 Skills Were Removed, and No Measurable Regression Followed

In the actual corpus, 131 semantic redundancy clusters were found, and both policies, guarded and unguarded, identified the same 160 skills as deprecation candidates. Had the deletion run without the guard, 4 of these would have been mistakenly deleted, since they were low-usage but the only skill in their cluster covering a specific positive or native case. Turning on the safeguard reduces these false deletions from 4 to 0. What's interesting is that because the guard only swaps out which skill within a cluster gets deleted rather than reducing the overall deletion target, the corpus reduction rate stays exactly the same, 7.39% (160/2,164), regardless of whether the guard is on or off.

![False Deprecations: Naive vs. Guarded Policy]({{ '/assets/images/posts/research/skill-graveyard-safe-deprecation/fig-guard-comparison.png' | relative_url }})
*Comparison of two policies that each reduce the corpus by the same 7.39%. Running without the safeguard produces 4 false deletions, but the safeguard reduces false deletions to 0 by substituting the next-lowest-usage redundant skill within the cluster.*

After applying the guard and removing 160 skills, re-scoring on the same 63-case standard suite produced identical results across all five metrics compared to before removal: Recall@5 (0.822), gated Recall@5 (0.667), Top-1 (0.378), hallucination rate (0.0), and negative-avoidance rate (0.375). In other words, 7.39% of the corpus was removed with no measurable regression whatsoever.

## What It Means for Companies and the Ecosystem, and the Limits the Authors Draw Themselves

At the company level, this result is practical. It means the corpus can be safely trimmed using only the telemetry and similarity computation the harness already had in place for routing and retrospection, without retraining or rebuilding the retriever. A smaller corpus is also plausibly likely to reduce the onboarding token cost of loading the skill list on every turn, but the authors state explicitly that they did not directly measure that cost in this experiment.

The two signals this policy uses, usage telemetry and semantic redundancy, do not depend on any feature unique to the ThakiCloud repository. The authors therefore anticipate that the approach could in principle transfer to other agent platforms that keep expanding MCP servers or tools through an open marketplace model. Beyond this, the concept of "skill half-life" itself provides a shared vocabulary for comparing how differently various metrics collapse as a retrieval corpus grows, and this work makes contact with related research by being the first to publish empirical data for a safe-deprecation policy that combines usage and semantic redundancy.

That said, the authors also lay out the limits of this result item by item themselves. The most important point is that the label suite the safeguard consults at runtime and the suite used to score regression are the same 63 cases. This means the result is not a general guarantee across the full production query distribution, but only shows that the cases the guard was designed to protect were not actually broken. The authors precisely characterize this as a result "relative to the regression criterion itself." They also note that this is a case study limited to a single repository and a single corpus; that a baseline experiment comparing this against random deletion or deletion using usage alone as a single signal is missing, so it has not yet been proven that this two-signal policy is actually safer than simpler methods; and that per-cluster logs of which skill the guard actually substituted within each cluster were not published, so the substitution mechanism could only be confirmed through aggregate figures. They separately note that the negative-avoidance rate reaching only 3 out of 8 (0.375) is a weakness the harness already carried independent of this deprecation policy.

Above all, this experiment did not reverse the accuracy decline caused by corpus growth itself; it only showed that no additional regression occurred in the process of shrinking the corpus. Actually reversing the growth curve, and validating this safeguard through continuous monitoring that goes beyond the 63-case suite, remain tasks for future work.

You can find further details of the paper on the Hugging Face dataset page.

[Skill Graveyard: Safe Autonomous Deprecation in Growing Agent Skill Ecosystems](https://huggingface.co/datasets/thaki-AI/daily-paper-2026-07-17-skill-graveyard-safe-deprecation)
