---
title: "Neither the Retriever nor Decomposition: A Ceiling-Gap Diagnostic for Skill Routing Bottlenecks"
seo_title: "Retriever vs Decomposition vs Corpus Redundancy - Skill Routing Diagnostics - Thaki Cloud"
seo_description: "A ceiling-gap diagnostic that tells you, with two numbers and no extra LLM calls, whether decomposition, the retriever, or corpus redundancy is the real bottleneck in an 1,898-skill harness. Covers dense retrieval, a contaminated synonym dictionary, and ordering metrics from a self-authored paper."
excerpt: "For a harness that routes hundreds of skills, this diagnostic tells you with two numbers whether your next investment should go into decomposition or the retriever. The measured answer turned out to be neither: the bottleneck was corpus redundancy."
date: 2026-07-09
tags:
  - skill-routing
  - agent-harness
  - compositional-decomposition
  - bm25-retrieval
  - corpus-redundancy
  - dense-retrieval
  - multi-skill-orchestration
  - autonomous-agents
categories:
  - research
author_profile: true
toc: true
lang: en
canonical_url: "https://thakicloud.github.io/en/research/retriever-vs-decomposition-skill-routing/"
---

If you operate an agent harness that manages hundreds or thousands of skills as individual files and routes natural language requests to whichever skill fits, or you are planning to build such a system, the question this paper tackles will feel familiar. When routing quality falls short of what you expect, should your next investment go into a decomposition layer that breaks a complex request into smaller pieces, or into fixing the retriever and the index that surface candidates in the first place. This paper offers a way to decide which side deserves investment first, using only two numbers, without having to build an expensive new LLM decomposition pipeline. And when the authors actually ran that diagnostic on their own corpus, the answer turned out to be neither decomposition nor the retriever.

> Revision note: the first version of this article stated that the comparison paper, SkillWeaver, reported "99.5 percent oracle top-1 recall." That was a misreading of the source. SkillWeaver's 99 percent figure measures context savings, not retrieval accuracy; the paper's actual retrieval performance is 34 to 41 percent category recall@1. This revised version corrects the comparison frame and rebuilds the conclusion accordingly.

## Revisiting the Assumption That "Retrieval Is Already Solved"

Recent work on skill routing points out that as skill libraries grow to hundreds or thousands of entries, models can no longer see every candidate on every turn. The emerging standard response is to narrow the field down to a handful of candidates through retrieval, and to split compound requests that span multiple skills into sub-tasks that are routed individually. SkillWeaver (arXiv:2606.18051), a representative paper that formalizes this line of work, argues that decomposition quality is the dominant bottleneck. Its reasoning: a standard LLM decomposer achieves only 34.2 percent step-level category recall, and fixing decomposition raises retrieval recall from 34 to 41 percent, so fixing decomposition is the key that unlocks retrieval.

The question this paper asks is whether that mechanism holds up in a different environment. The test bed is the authors' own production harness: a single organization's 1,898 file-based skills, a deterministic BM25-family lexical retriever, and requests that mix Korean and English in natural language. Rather than a clean, English-centric benchmark, the same claim is tested on a live, less curated, multilingual corpus. The short answer is that SkillWeaver's mechanism did not transfer to this environment, and the bottleneck sat upstream of both decomposition and retrieval.

## Core Contribution: The Ceiling-Gap Diagnostic

The paper's central idea is simple. Compute the ceiling gap, the coverage difference between an upper bound that assumes perfect decomposition (ORACLE) and the single-pass retrieval currently in production (SINGLE). ORACLE is obtained by feeding gold-standard sub-tasks, carefully split by a human in advance, straight into the retriever with no gating, so it requires no new LLM calls and no production decomposition pipeline. All you need is a small hand-prepared validation set.

What this diagnostic reads is not one number but the relationship between two. If ORACLE itself sits near 100 percent and the gap to SINGLE is large, you are in the regime SkillWeaver measured, and decomposition is the right investment. If, on the other hand, ORACLE itself falls well short of 100 percent, no amount of perfect decomposition can close the remaining gap, which means the retriever, the index, and ultimately the corpus deserve attention first.

## Measurement: Neither Lever Raised the Ceiling

On a 12-case compound routing benchmark, SINGLE's step coverage was 52.9 percent, while ORACLE, decomposition with all gating removed, reached 63.6 percent. Bootstrap 95 percent confidence intervals were [34.0, 72.2] and [42.8, 83.5] respectively, and the 10.7-point ceiling gap has a confidence interval of [2.1, 20.8], barely clearing zero. With only 12 samples, every figure should be read as a case study rather than a broad generalization. Still, the decisive fact is ORACLE's absolute level. A figure of 63.6 percent means that even with perfect decomposition, more than a third of the needed skills are still missed, a signal that decomposition is not the dominant lever in this regime.

So would swapping in a better retriever help? This is where the revised version diverges most sharply from the first draft. Rule-based decomposition (SAD, 35.0 percent), its refined re-splitting variant (ISAD, 37.1 percent), and a gated version of gold decomposition (SAD-AGENT, 41.9 percent) all scored below SINGLE. Switching the router to a multilingual embedding retriever actually dropped ORACLE to 45.4 percent, and a hybrid that combined BM25 with dense retrieval (RRF) landed at 64.0 percent, statistically indistinguishable from BM25's 63.6 percent. A better retrieval model did not raise the ceiling.

![Neither decomposition nor a better retriever raises the ceiling](/assets/images/posts/research/retriever-vs-decomposition-skill-routing/fig-strategies-retrievers.png)
*The left panel shows every decomposition strategy sitting below SINGLE (dotted line); the right panel shows dense and hybrid retrievers failing to beat the live BM25 baseline. Neither lever raised the ORACLE ceiling.*

## The Real Bottleneck: Skill Corpus Redundancy

To find out what was holding the ceiling down, the authors classified the ranking of every gold skill that ORACLE missed even without gating. Of 35 gold mentions across the 12 cases, 23 were retrieved, and the 12 misses split into two failure types, both of which trace back not to the search algorithm or decomposition but to a duplicated, uncurated corpus. The first is sibling saturation (5 of 12). A gold skill exists in the corpus, but near-identical siblings fill the top-k first: `competitive-analyst` was ranked 10th, pushed down by `competitive-analysis`, `kwp-product-management-competitive-analysis`, and `competitive-archetype-matrix`, while `trading-position-sizer` ranked 38th, crowded out by eight `trading-*` siblings. The second is name mismatch between gold and corpus (7 of 12). The needed capability exists in the corpus only under a sibling's name, so the exact gold name itself is never retrieved. `deep-research`, `naver-news-search`, and `academic-paper` all scored zero, with their capability family (`deep-research-pipeline`, `199-deep-research`, `market-researcher`, and so on) occupying that slot instead. Both failure types share the same root cause: the same capability is fragmented across multiple names, so there is no single canonical entry to rank first.

Crucially, these siblings were not disambiguated by an embedding retriever either. The dense retriever also failed to surface `deep-research` near the top and ranked `competitive-analyst` 33rd, because sibling skills are practically indistinguishable from gold based on description alone. Which one is "canonical" is not a matter of meaning but of naming, so no retriever can elevate an arbitrary canonical entry to first place. In practice, physically merging 46 environment-specific exact duplicates (from 1,898 down to 1,852) left ORACLE unchanged at 63.6 percent, and even crediting near-neighbors of gold as acceptable substitutes (TF-IDF cosine above 0.6, dense cosine above 0.7) moved ORACLE by at most 2 points, because automated similarity cannot group these short, generic siblings. Redundancy is real and it is the bottleneck, but it cannot be resolved mechanically; it requires human curation at the capability level.

## Retriever Performance Was an Artifact of a Hand-Built Synonym Dictionary

The live router's cross-lingual ability rests entirely on a hand-maintained Korean-English synonym dictionary. Removing that dictionary collapsed ORACLE from 63.6 percent to 20.8 percent and SINGLE from 52.9 percent to 18.8 percent. Roughly two-thirds of the measured coverage came not from the retrieval algorithm but from a manually maintained dictionary.

![Removing the hand-curated synonym dictionary collapses coverage](/assets/images/posts/research/retriever-vs-decomposition-skill-routing/fig-synonym-artifact.png)
*Removing the hand-built Korean-English synonym dictionary collapses coverage (ORACLE from 63.6 to 20.8). Cross-lingual ability is a product of curation, not a property of the retriever.*

This fact changes the interpretation. A look at internal logs shows that a single past expansion of the synonym dictionary, with no change to the decomposition logic, raised the ORACLE ceiling from 42.5 percent to 63.6 percent, a jump of 21.1 points. The first draft of this paper presented that jump as positive evidence that "retriever work, not decomposition, moved the needle." But that expansion added exactly the Korean terms the benchmark's gold answers needed (deep research, fact check, Slack, and others). Because that mismatch is what drove the expansion in the first place, the 21.1-point gain was measured on the same cases it was tuned against, in other words it reflects fitting the test set. This revised version withdraws that figure as evidence. A retriever whose cross-lingual ability is a dictionary tuned to the benchmark offers neither a ceiling nor an improvement that generalizes.

## What Decomposition Is Actually Good For: Execution Order

Step coverage misses the value decomposition actually provides. Comparing the order in which each strategy surfaces gold skills against the gold execution order (Kendall tau over covered pairs), SAD-AGENT recovered a perfect ordering with tau of 1.0 (across 4 cases with two or more covered gold skills), while SINGLE's ranking order was actually anti-correlated at tau of negative 0.22 (across 6 cases). Single-pass retrieval returns a bundle of relevant results with no execution semantics, while decomposition restores the order in which skills need to run. In this regime, decomposition does not raise coverage, but it is the only strategy that restores order.

![Decomposition recovers execution ordering](/assets/images/posts/research/retriever-vs-decomposition-skill-routing/fig-ordering.png)
*Decomposition's real contribution is recovering execution order (tau of 1.0). Single-pass ranked retrieval is actually anti-correlated (tau of negative 0.22), a difference that coverage metrics alone cannot see.*

## Contributions to Industry, Society, and Science

For companies, this diagnostic is a near-zero-cost procedure for deciding where to invest before building anything, directly applicable to their own harness. Unlike the first draft, however, the conclusion is not "invest in the retriever" but "diagnose the bottleneck before choosing a lever." If ORACLE falls well short of full coverage and the cause is corpus redundancy, the right answer is to consolidate the skill corpus and evaluate by equivalence class, rather than rebuilding a decomposition layer or swapping retrieval models. Notably, the first draft's own conclusion, that the retriever was the bottleneck, turned out to be an instance of exactly the mistake this diagnostic is meant to prevent: picking a lever before diagnosing the bottleneck.

Socially, this frees teams from over-engineering unnecessary decomposition layers and over-investing in retrieval models. When the true bottleneck is a redundant, uncurated skill library, cleaning up corpus hygiene lowers both compute cost and oversight burden at the same time. That means smaller organizations without large ML infrastructure teams can more easily operate a large, trustworthy skill library of their own.

Scientifically, this presents a case that does not transfer cleanly to either recent orthodoxy, that "retrieval is effectively solved" or that "decomposition is the sole bottleneck." By showing that in a less curated, Korean-English mixed real-world corpus the bottleneck shifts upstream of both decomposition and retrieval, to corpus hygiene, it reveals that which lever dominates is a property of the corpus and index, not an inherent property of retrieval or decomposition themselves. And the paper argues that the ceiling-gap diagnostic procedure itself, reading ORACLE's absolute level alongside its gap to SINGLE, generalizes as a method applicable across skill routing research broadly.

![Bootstrap confidence intervals at n=12](/assets/images/posts/research/retriever-vs-decomposition-skill-routing/fig-ceiling-gap-ci.png)
*With only 12 samples, confidence intervals are wide and the ceiling gap's sign is only barely significant. Every figure here should be read as a case-study measurement.*

## Limitations

The authors state their limitations plainly rather than hiding them. The compound benchmark has only 12 cases, so every figure must be read as a case study alongside its bootstrap confidence interval. They do not claim that specific numbers from a single organization's single corpus generalize to other environments; what generalizes is the diagnostic procedure. The dense retriever experiments used only a small multilingual embedding model, so billion-plus-parameter large-scale retrieval models remain untested, and the finding that "dense retrieval does not help" is scoped to standard-size models and this corpus. The substitutability ceiling cannot be cleanly measured by automated similarity, so quantifying the true ceiling would require human-curated equivalence classes. Only the Korean-English language pair was studied, other language pairs remain untested, and the diagnostic itself was not validated with a live A/B test. The fact that this study ran on a proprietary corpus is itself a limitation and a direction for future work; producing a public reproduction that preserves the redundancy structure is the next deliverable.

The full paper detail page is available here: [https://huggingface.co/datasets/thaki-AI/daily-paper-2026-07-09-retriever-vs-decomposition-skill-routing](https://huggingface.co/datasets/thaki-AI/daily-paper-2026-07-09-retriever-vs-decomposition-skill-routing)
