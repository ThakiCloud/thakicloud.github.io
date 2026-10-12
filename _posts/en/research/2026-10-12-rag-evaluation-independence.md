---
title: "10,702 Questions, Only 5 Components: Why RAG Evaluation Independence Matters"
seo_title: "RAG Evaluation Independence: Why Question Count and Independent Components Differ, and Two Failed Benchmark Builds - ThakiCloud"
seo_description: "We tried twice, from Wikipedia and from Korean statutes, to build an independent benchmark for a RAG decision model, and stopped both times. The statute build could produce over 10,000 questions, but under the link rules fixed in advance they formed only 5 independent units. How the independence definition sets the effective sample size."
excerpt: "We could build ten thousand evaluation questions. But once questions that share the same passages were grouped together, only five independent clusters remained. Question count and independent sample size turned out to be very different numbers."
date: 2026-10-12
last_modified_at: 2026-10-12
tags:
  - rag
  - evaluation-design
  - independence
  - clustered-data
  - statistical-power
  - benchmark-construction
  - korean-law
  - paxis
categories:
  - research
author_profile: true
toc: true
toc_label: "Contents"
canonical_url: "https://thakicloud.com/tech-blog/en/research/rag-evaluation-independence/"
---

When people talk about the size of a benchmark, they usually count questions. We set out twice to build a benchmark that could independently verify a retrieval decision model: once from Wikipedia and once from Korean statutes. Both times we could make plenty of questions, and both times we stopped. The questions were leaning on each other.

This is for anyone who builds benchmarks, or has to decide whether to trust the numbers on someone else's. It is a record of two failed builds, but what caused the failures applies to other evaluations as well.

## In plain terms

Say a poll asked ten thousand people. Then it turns out most of them came from a few families in the same neighborhood. Family members tend to answer alike, so although ten thousand were asked, the number of real voices is the number of families.

Evaluation questions work the same way. Two questions that rely on the same passage are one family. If the model reads that passage well, it gets both right; if not, both wrong. So statistics should count families, not questions, as the unit. We call these families components.

The hard part is the rule for who belongs to which family. The tighter the rule, the bigger the families and the fewer of them there are.

## What we did

### Why we needed a new benchmark

The experiments in [our earlier post](/tech-blog/en/research/accuracy-vs-evidence-decisions-rag/) all reused one development set. To tell whether an apparent improvement generalizes or just fits that set, we needed a fresh, independent benchmark.

We fixed the pass line before building anything: the benchmark must be able to detect a 3-point accuracy difference. That power is computed from the number of components, not questions, counting at most four questions per component. On this rule we needed 261 components for the final evaluation and 168 for tuning.

### First attempt: Wikipedia-based multi-hop questions

The first attempt started from 2WikiMultihopQA, a Wikipedia-based dataset. 5,184 question candidates passed the first contamination check.

Then the passage-level check flagged 5,142 of them. The supporting passages, which hold the answer, were mostly clean. The problem was the distractor passages. The dataset's training and validation splits draw distractors from one shared pool of Wikipedia passages, and 87% of the distractors overlapped with validation data we keep sealed. Twenty questions survived.

Following the rules set in advance, we did not lower the bar. We made exactly one more attempt, replacing only the contaminated distractors with clean passages. 381 questions could be repaired, and 237 passed every check. The 159 assigned to the final split could only detect a 4.4-point difference, short of the 3-point target. On top of that, a classifier looking only at the documents told replaced passages apart with an AUC of 0.61. The replacement left a trace. We closed that path.

### Second attempt: citations inside Korean statutes

The second attempt used a source unrelated to Wikipedia: Korean statutes. We built multi-hop questions from articles that cite another article of the same law.

A small early audit already raised a warning. Of 128 chosen questions, 45 were tangled through boilerplate articles, like the joint-penalty clause that appears almost word for word in many laws. Of the 83 that remained, 82 sat in one cluster joined by citations between laws.

So we designed a harder task. Instead of the cited article, a decoy is inserted: the article with the same number from a different law. Before building it, we counted how much could be built. The rule for grouping families was fixed in writing beforehand. Laws that share a passage, contain near-identical articles, or serve as each other's decoy are one family.

## What came out

There were plenty of questions to build. The 1,656 laws in force yielded 10,702 question candidates that could take a decoy.

But grouped by the rule, they formed only 5 components. The largest held 1,566 laws and 98.9% of the candidate questions. That is far short of 261 and 168, and we stopped there under the stop rule set in advance.

Adding the link rules one at a time shows where the families grew.

| link rule | components | largest component |
|---|---|---|
| identical passages only | 1,357 | 44 laws |
| plus near-identical articles | 737 | 845 laws |
| plus laws used as decoys | 5 (counting components with candidates) | 1,566 laws |

*Near-identical articles are those whose 5-character fragments overlap with a Jaccard ratio of 0.8 or more. The first two rows are diagnostics computed after the verdict to see the cause.*

With identical passages alone, the laws split into 1,357 clusters. Adding near-identical articles created one cluster of 845 laws. The same-number decoy links then joined almost everything else.

In other words, we could have asked ten thousand people, but grouped by family, we had effectively asked five households.

### What the two attempts share

The two sources were entirely different, yet they failed in the same shape. With Wikipedia, distractors drawn from a shared passage pool were the problem. With statutes, boilerplate repeated across laws, and the decoys added to make questions harder, became bridges between questions. In both cases, the way the questions were built created links between them.

## What to change

First, it is more honest to report a benchmark's size as the number of independent units, not questions. Here, ten-thousand-odd questions and five independent units differ by more than 2,000 times.

Second, fix the independence rule before seeing the data, and count before building. The statute benchmark could be stopped with CPU computation alone, without running a model even once. Had we found out only after building every question and seeing model results, the temptation to loosen the rule would have been much stronger.

Third, check that devices that make questions harder do not erode independence. Decoys and distractors raise difficulty, but when many questions share one decoy source, that sharing is itself a link.

For ThakiCloud this lesson carries over to evaluating agent quality in Paxis. When agents are evaluated on customer work documents, the same internal policy or form passage shows up across many questions. However many questions there seem to be, unless questions sharing a passage are counted together, the results will look far more certain than they are.

## What not to trust

The strongest objection is that our independence definition may be too conservative. Sharing a near-identical article does not leak the answer. A joint-penalty clause appearing in several laws does not mean solving one law's question solves another's. A looser rule would give many more components.

So this result does not mean "1,656 laws amount to only 5 statistical samples." It means that the graph built from our pre-set link rules has 5 clusters. It is a failure of this evaluation's construction, not of the source data. We still did not loosen the rule after seeing the result to rescue this benchmark, because that would blur what is being verified.

Second, counting by components is one choice. Cluster-robust variance estimates, or weighting links by strength, would give different numbers.

Third, this cannot be extended to all RAG evaluation. These are two cases, Wikipedia-based multi-hop questions and Korean statute citations. A source that does not share passages may not have the same problem.

*These figures were computed by us, and only results recorded in our research ledger are cited.*
