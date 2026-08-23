---
title: "Agent Memory Wasn't an Ordering Problem, It Was a Duplication Problem"
seo_title: "Agent Memory Tiering, Measured: Why Deduplication Beats Ordering Policies | ThakiCloud"
seo_description: "We measured three memory tiering (hot/cold consolidation) policies for long-running autonomous agents against a real production corpus of 45 items. Similarity-based deduplication beat recency and frequency policies by 17 to 20 percent on AUC, and in the actual production configuration, an item-count cap, not the character cap, was the one quietly starving recall."
excerpt: "The memory briefing you reload every session runs on a fixed budget. When we tested the policies that decide what stays and what gets cut against a real corpus, removing duplicates first turned out to matter far more than ranking items well."
date: 2026-07-30
tags:
  - 에이전트-메모리
  - 컨텍스트-엔지니어링
  - 토큰비용
  - 에이전트-하네스
  - 정보검색
  - LLM-운영
  - 실측연구
categories: [research]
author_profile: true
toc: true
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/research/agent-memory-tiering-recall-cost/"
audiobook: "https://drive.google.com/file/d/1YvbgQfu1Ch3Rnj9JgZr6-5E10f0fQbO1/view"
audiobook_label: "▶ Listen: 5-minute briefing"
audiobook_note: "NotebookLM audio overview (AI-generated)"
---

If you run an autonomous coding agent that keeps working for weeks without a break, and you've noticed the memory briefing it injects at the start of every session keeps blowing past its budget, this post is about exactly that problem. We tested three policies for deciding what stays in that briefing and what gets cut, against a real production memory corpus, and the numbers show why the most common intuition ("keep the newest items") is not the best answer.

![Illustration of the core idea of Agent Memory Wasn't an Ordering Problem, It Was a Duplication Problem](/assets/images/agent-memory-tiering-recall-cost-hero.webp)
*A visual metaphor for the article's key idea.*

## The problem: context isn't free

A long-running agent accumulates a record of its own behavior while it works: corrections a person pointed out, behavioral patterns pulled from skill or agent retrospectives, lessons carried over from earlier tasks. That record is what keeps the agent from repeating in session n+1 a mistake it was called out on in session n. But the value of any single record depends on exactly one condition: it has to actually be sitting in context the moment the same situation comes up again.

The catch is that context is not free. A resident memory briefing injected into every session scales in cost with the number of sessions, not with the number of times it actually helped. So in practice, most harnesses cap the briefing at a fixed character budget and leave the choice of which items to keep to a consolidation policy. And that policy is almost always chosen by intuition: keep the newest items, or keep the most frequently referenced ones. Neither intuition has ever been tested side by side with an alternative, on the same corpus, under the same budget.

## Core contribution: testing three policies on a real corpus

We compared three policies, recency pruning, frequency retention, and similarity-based semantic deduplication (based on Jaccard similarity over token sets, not embeddings), against the memory corpus of an actual production agent harness currently in operation. The corpus holds 45 items (36 corrections, 9 patterns, 1,594 characters total) accumulated over five weeks, from 2026-06-23 to 2026-07-29. We swept the budget from 10 percent to 100 percent of the corpus in ten steps, measured "recall at budget" at each step, and summarized the result as area under the curve (AUC).

![Recall curves by budget for the three tiering policies](/assets/images/posts/research/agent-memory-tiering-recall-cost/recall-curves.webp)
*Semantic deduplication reaches a recall of 1.0 at just 70 percent of budget, while the two baseline policies need the full 100 percent to get there. (Measured on a CPU-only container.)*

The result was clear. Semantic deduplication scored an AUC of 0.7189, while recency pruning and frequency retention both landed at 0.6122. That is a gap of 0.1067 in absolute terms, and depending on which integration range you pick, a relative advantage of 17 to 20 percent (17.4 percent over the full range [0.1, 1.0], and 20.4 percent over [0.1, 0.7], the range where the policies actually diverge). What's more interesting is the shape of the recall curve. In the 30 to 50 percent budget range, deduplication holds a recall of 0.73 to 0.82, while the recency policy sits at only 0.58 to 0.64. And from 70 percent budget onward, deduplication reaches a recall of 1.0 and stays there, while the two baseline policies need to spend the entire 100 percent of budget to reach the same point. That means roughly 30 percent of the items in this corpus were effectively duplicates, and the two baselines never removed them, they just kept shuffling their order while the duplicates occupied space.

Interestingly, the recency and frequency policies landed on exactly the same AUC, but their curves had different shapes. When the budget is very tight, recency comes out ahead; in the middle range, frequency takes the lead; and once the budget is generous, the two converge again. Their integrals matched, but they were failing in completely different ways. That is itself evidence that "ranking items more cleverly" alone does not solve this problem.

## Why deduplication beats ordering policies

Recency pruning and frequency retention are both "ordering" policies. They assign a single rank to every item and cut from the bottom once the budget runs out. Neither checks whether two items say effectively the same thing. Semantic deduplication adds exactly one operation on top of that. Before ranking, it clusters items connected by a token-set Jaccard similarity of 0.5 or higher, and keeps only the most recent item from each cluster as the representative. After that, it ranks and cuts exactly like the recency policy. So the measured gain is not coming from "better judgment about importance," it is coming purely from removing duplicates.

![AUC comparison: semantic deduplication versus the two baselines](/assets/images/posts/research/agent-memory-tiering-recall-cost/auc-comparison.webp)
*Semantic deduplication scored an AUC of 0.7189, a relative gain of 17.4 percent over the 0.6122 shared by the recency and frequency policies. (Measured on a CPU-only container.)*

It is common for a person to point out the same correction across several sessions, each time in slightly different wording. To a human that reads as "the same thing again," but to an ordering policy it looks like three distinct items, and it claims three separate slots inside the budget. Switching from recency to frequency does not fix this either, and for the same reason: neither policy ever checks whether an item means the same thing as another item that's already kept. In the end, the axis that actually made better use of the budget was not more refined ranking, it was a single deduplication step.

## The hidden bug already in production: item-count caps and character caps are different variables

We also examined the configuration currently running in production. This harness applies both a per-section item-count cap (12 corrections, 6 patterns, 18 total) and a character cap (900 and 700 characters respectively, 1,600 total) at the same time. Under the current configuration, with both caps active, only 18 items survive and recall lands at 0.5778. But when we removed the item-count limit and kept only the same 1,600 character budget, all 45 items survived and recall reached 1.0.

![Production configuration ablation: item-count cap versus character cap](/assets/images/posts/research/agent-memory-tiering-recall-cost/production-ablation.webp)
*The item-count cap currently in place keeps only 18 of 45 items, landing at a recall of 0.5778, but removing the item-count cap and applying only the combined character budget keeps all 45 items and reaches a recall of 1.0. (Measured on a CPU-only container.)*

The numbers make the cause obvious. The current corpus totals 1,594 characters, which sits almost exactly at the combined character budget of 1,600. In other words, at this corpus size the character cap is effectively cutting nothing, while the item-count cap has already trimmed 27 items before it. Treating the two caps as a kind of "double safety net" and running them together is a common design, but this result shows that assumption is wrong. Which cap binds first depends not on corpus size but on the average length of an item. This corpus runs short, at roughly 35 characters per item on average, so the item-count cap (which allows roughly 89 characters per item) binds well before the character cap does. In a corpus with longer, more descriptive items, that relationship could flip immediately. The paper is also explicit that this result is specific to the current corpus size (1,594 characters): once the corpus grows past 1,600 characters, the character cap would actually start to bind.

## What this leaves for both the company and the field

The practical takeaway is simple. Remove duplicates before ranking, and tune the item-count cap and the character cap as separate variables rather than assuming that setting one turns the other into a mere safety net. Logging which of the two caps is actually the one binding at any given time makes it possible to quietly catch the moment the bottleneck flips as the corpus grows, instead of missing it.

At the methodology level, this small measurement procedure, budget sweep, recall curve, and AUC summary, is itself a reusable asset. It's deterministic and rerunnable, so any team can test the tiering policy they're about to deploy against their own corpus first. Scientifically, most recent work on agent memory focuses on tiering structure or architectural design, while this paper adds a different kind of evidence by validating the retention policy embedded inside that architecture through a controlled comparison on data from an actual deployed system.

## Limitations

The most important limitation is that the evaluation queries are not real future recall events. The 45 evaluation queries are deterministic subsequences built by taking every other token position from each item's token sequence, designed so that every item can be recalled by at least one query. This removes noise from the policy comparison, but it also means the measurement captures "how many items fit within the budget," not "how well the policy selects the items that will actually be needed in the future." The corpus is also small and drawn from a single source: one repository, five weeks, 45 items. The deduplication clustering threshold (0.5) and the query matching threshold (0.3) were each fixed once rather than swept for sensitivity, and the comparison did not include simpler alternative baselines such as shortest-first or set-cover-based policies. So what this paper shows is a precise snapshot, "for a corpus shaped like this, measured by recall in this way, deduplication wins," not a universal ranking of tiering policies in general.

Paper detail page: [https://huggingface.co/datasets/thaki-AI/daily-paper-2026-07-30-agent-memory-tiering-recall-cost](https://huggingface.co/datasets/thaki-AI/daily-paper-2026-07-30-agent-memory-tiering-recall-cost)
