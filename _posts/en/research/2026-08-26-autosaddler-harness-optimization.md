---
title: "It Fixes Itself From Failure Records: AutoSaddler Evolves the Agent Harness"
seo_title: "AutoSaddler: Automatic Harness Optimization From Failure Records - ThakiCloud"
seo_description: "AutoSaddler, from KAIST, POSTECH, and Microsoft, treats everything an agent uses to do its job as one system and fixes it by reading only its own failure records. Across GAIA2, SWE-Bench Pro, and Terminal-Bench 2.0 it beat hand-tuned automation baselines using far fewer tries, and we look at what this means for the Paxis self-evolution loop."
excerpt: "A program that used to be hand-tuned by people now fixes itself by reading only its failure records, and scores jumped on all three benchmarks tested. The trick is three habits: dig for the real cause, never patch blindly, and always test a fix before keeping it."
date: 2026-08-26
last_modified_at: 2026-08-31
tags:
  - harness-optimization
  - agent-evaluation
  - offline-learning
  - gaia2
  - swe-bench-pro
  - terminal-bench
  - self-improvement
  - paxis
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
reading_time: true
categories:
  - research
canonical_url: "https://thakicloud.com/tech-blog/en/research/autosaddler-harness-optimization/"
header:
  teaser: /assets/images/autosaddler-harness-optimization-hero.webp
---

An agent (a program that makes its own decisions across many steps) sometimes fails, and a person used to fix its setup by hand, one piece at a time. The paper we cover today made a program do that fixing itself, using only its own failure records. Across all three test tasks the score went up by a wide margin, and it reached that level with far fewer tries than other automated methods.

If you run several agents, or you have been hand-tuning their setup yourself, this is worth your time. It is the most concrete evidence so far that automating that tuning is the right direction, and it shows how to build it.

![An agent harness rewriting itself from failure traces](/assets/images/autosaddler-harness-optimization-hero.webp)
*A cracked chip with circuit lines radiating outward, standing in for a harness that repairs itself after failure.*

## In plain terms

Picture a bike courier. Leave the courier's own skill alone, and call everything else the gear: the bike, its gears, and the delivery app's settings. The gear covers the chain, the brakes, and even the wording of the app's route warnings.

The courier failed a few deliveries: late arrivals, spilled food, packages left at the wrong door. Until now, a mechanic looked the bike over and fixed it by feel. This paper turns that mechanic into a program, and one that looks only at the failed deliveries, never the successful ones.

This mechanic has three habits. First, it never just glances at the bike; it takes it apart to find the real cause. Second, it never tinkers randomly: every fix is either a big repair that swaps a part, or a small tweak that only adjusts a setting. Third, it test-rides the fixed bike not just on the route that failed but on other routes too, and keeps the fix only if it truly helps. It also logs every fix as a branch on a tree, so if one fix later causes trouble, that branch alone gets cut while the good ones stay.

## What we did

Fixing an agent's harness (harness: the prompts, tool setup, and control logic an agent runs on) has always been a person's job. On long tasks a small failure compounds into a whole failed job, and there is a lot to fix, wording, tool settings, control logic. Doing it all by hand costs a lot and mostly runs on gut feeling.

Thirteen researchers from KAIST, POSTECH, and Microsoft Research built AutoSaddler to turn this into a problem a program can learn to solve. The name comes from a device that tightens a bike saddle automatically. What it does is patch the harness like code, using only failed execution records as the learning signal.

The loop runs like mini-batch learning. It samples a batch of training tasks, runs the current harness, and keeps only the failures. It then digs into those records and the harness's own code to find the real cause. Once it has a cause, it writes a structured patch and tests it again on the same tasks. If that helps, it checks the fix once more on a separate set of tasks held back for validation. Only fixes that pass both checks get logged on the tree, and the whole loop repeats for a fixed number of tries.

Patches come in only two kinds. A capability patch, the big repair in our bike analogy, changes tool code, infrastructure settings, or the agent's own control logic. A steering patch, the small tweak, leaves the executable code untouched and only edits wording, prompts and tool descriptions. Removing this split and letting patches be written freely pushed the vast majority of fixes toward wording tweaks, and the high-value tool and infrastructure fixes were never even tried.

Three benchmarks tested this. GAIA2 covers general assistant tasks across ten simulated smartphone worlds. SWE-Bench Pro covers enterprise-scale software engineering tasks, and Terminal-Bench 2.0 covers eighty-nine tasks in system administration, machine learning, and security. Both the mechanic program and the courier agent ran on the same model, Claude Opus 4.6.

## What came out

### It gained 9 to 10 points and needed far fewer tries

All three tasks scored 9 to 10 points higher than the hand-built default harness, and beat the best existing automated method by 4 to 7 points.

| Benchmark | vs default harness | vs best automated method |
|---|---|---|
| GAIA2 | +9.0 | +7.4 |
| SWE-Bench Pro | +9.6 | +4.4 |
| Terminal-Bench 2.0 | +10.0 | +6.7 |

The bigger story is how few tries it took to get there. On GAIA2, AutoSaddler reached 72.3% with about 1,000 runs, while the other two methods used about 2,800 runs and still topped out at 64.6% and 61.5%. Counting only the runs that actually fed the learning, the gap widens further: AutoSaddler hit its best score after 147 runs, one rival needed 1,400. In plain terms, it matched the same score with roughly ten times fewer tries.

The systems and security benchmark told the same story. From the same starting point, AutoSaddler used 31 runs and only 12 records to reach 73.7%. The other method used 98 records and still sat at 63.2%.

### Drop any one of the three habits and the score falls

We checked whether all three habits actually matter by removing each one.

| Setting | Score (GAIA2, Pass@1) |
|---|---|
| AutoSaddler (full) | 62.0 |
| without deep diagnosis | 57.8 |
| without the capability/steering split | 56.9 |

Drop the split and the fixes pile up on one side. With editing left unconstrained, 91.5 percent of the patches went to steering, and the score moved among the largest swings in the table.
| without validation | 50.6 |

The biggest drop came from removing validation. A fix tailored to one failure often broke other tasks, and checking it again on held-back tasks caught most of those cases. In plain terms, validation is not a nice-to-have; it is what keeps the whole approach alive.

The run log holds one striking moment. At try 20, a fix to a frequently used tool crashed the score to 33.8%. The system rolled back to try 13 (67.7%) and re-applied only the fixes validated at tries 13 and 14, then hit its overall best of 72.3% at try 27. A straight list of fixes would have let that one bad patch poison everything after it. The tree structure let the system cut only the bad branch and keep the good ones.

### It still worked well handed to a weaker courier

When the fixed bike, tuned with the strong model (Opus 4.6), was handed to a weaker model (Haiku 4.5), the 5.6-point gain over the default agent still held. In plain terms, the benefit of the repair sticks to the bike and the app settings, not to the model, so it carries over to a different courier.

## What to change

First, build a real deep-diagnosis step before anything else. A quick glance at a failure pushes fixes toward wording tweaks and never touches the real cause. Our own Paxis self-evolution skill loop has been weighing whether to generate skill patches from failure records, and this result shows that diagnosis depth is what decides patch quality.

Second, validation is not optional. A fix built around one failure tends to break unseen tasks, and a second check on held-back tasks is what catches that. In one full run, only 21 of 51 candidate fixes made it through.

Third, keep fix history as a tree, not a straight line. Rolling back a bad branch while keeping the good ones is the same idea as designing a skill-patch ledger as a graph of fixes.

Fourth, the number of tries is a serving cost. A tenfold gap in tries to reach the same result is also a tenfold gap in Metis inference cost for the same outcome. Never re-running the cases that already succeeded changes the cost structure of the whole evaluation pipeline.

A related post, [The Model Is Frozen, the Harness Learns](/tech-blog/en/research/harness-continual-learning/), covers the same theme. AutoSaddler tunes before deployment; that post covers adapting after deployment.

## What not to trust

Both the mechanic program and the courier agent ran on one model family. Whether the same gain holds with a different company's model is not something this paper answers.

Validation only works when success or failure is clear-cut, and all three benchmarks had a clean answer key. How to define a held-back check for real work without a clean answer key is a question this design has to answer before it can be used there.

This is a tune-before-deployment approach. It matches how teams actually work, but it does not handle things changing after deployment. A new model or a new kind of task means starting the whole search over again.

Going deep costs money. Each diagnosis session makes about six more tool calls and six more file reads. The paper argues this trade pays for itself, but for a smaller agent or a tight budget, a quicker glance may be the more sensible choice.

---

*Source: [AutoSaddler, arXiv 2608.23041](https://arxiv.org/abs/2608.23041) (Sungho Park and 12 co-authors, 2026-08-24). Project site [aka.ms/AutoSaddler-website](https://aka.ms/AutoSaddler-website). Numbers in this post were verified against the paper itself and rounded for readability.*

> 📄 **Full deep review (DOCX)**: [Download the detailed peer review on Google Drive](https://drive.google.com/file/d/1rZ60AlAHZBBNcKjWuIxASN2NMC2d7t6Y/view).
