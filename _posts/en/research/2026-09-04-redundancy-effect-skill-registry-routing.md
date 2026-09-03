---
title: "The Size Stays the Same, but Only the Twins Grew: The Redundancy Effect in the Skill Registry"
seo_title: "Skill Routing Redundancy Effect: Holding Size Fixed and Splitting Duplicate Mass, Top-1 Accuracy 1/(m+1) Symmetry, Cluster-Aware Grading and Breakeven Deduplication Policy - ThakiCloud"
seo_description: "Our agent skill registry grew from about 1,600 entries to 2,234 in two weeks. The growth was near copies the curator rewrote every night. Holding size fixed and splitting composition, we show that the top-1 accuracy drop belongs to the duplicate mass, and introduce a one-line grading fix plus a breakeven policy for deduplication."
excerpt: "The school stays the same size; only students with identical faces grew. Grading by jersey number, three twins make the top chance one in four. Grading by the top five, nothing happens. Today's paper peels off the score drop the copy mass caused, and delivers a one-line grading fix and a breakeven point for deduplication."
date: 2026-09-04
last_modified_at: 2026-09-04
tags:
  - skill-routing
  - skill-ecosystem
  - agent-harness
  - registry-redundancy
  - near-duplicate-injection
  - deduplication-policy
  - embedding-similarity
  - recall-at-k
  - retrieval-scaling
  - router-cost
categories:
  - research
author_profile: true
toc: true
toc_label: "Contents"
canonical_url: "https://thakicloud.com/tech-blog/en/research/redundancy-effect-skill-registry-routing/"
---

The size stays the same, but only the top score quietly falls. This post is for you if you are a Korean cloud or AI engineer who watches the quality of the skill router. Today we introduce a paper our research team wrote. The paper separates the effect of registry size from the effect of duplicate mass. Our agent's skill registry grew from about 1,600 entries to 2,234 in two weeks. Most of the growth was not new functionality. It was similar documents that the nightly curator rewrote and stacked on top of existing skills.

![Illustration of the core idea of The Size Stays the Same, but Only the Twins Grew: The Redundancy Effect in the Skill Registry](/assets/images/redundancy-effect-skill-registry-routing-hero.webp)
*A visual metaphor for the article's key idea.*

## In plain terms

Think of a school with 2,000 students. The teacher has to find one of them. The jersey number on the roster is the answer.

The problem is that this school's administration office rewrites the roster every night. With each rewrite, one more student with the same face and the same jersey number as an existing student quietly appears. In the paper's terms, this is a near-duplicate mass. The school stays the same size, but the number of twins has grown.

Under strict grading, the jersey number of the student called first must exactly match the answer. If the correct student has three twins, the chance of calling the real one first is one in four.

With one twin it is one in two, with two twins one in three. The more copies there are, the lower the chance.

Under loose grading, it counts as correct if any one of the twins lands in the top five. If four twins all sit inside the top five, it does not matter who stands first. That is why the top score falls while the top-five score stays put.

But the case of calling another child first splits into two. If a twin of the real one is called first, the job is done. If a completely different student is called first, one with a similar face but a different number, the job is not done. In the paper's terms, channel A is the case where the correct student never made the top five, and channel B is the case where the correct student made it but another student was called first. B splits into two again: the harmless B1, where a twin was called first, and the malicious B2, where a different student was called first. The redundancy effect is precisely the B1 share.

![Three-channel decomposition of top-score errors: retrieval failure (A), ranking collision (B), harmless twin return (B1), malicious near-miss (B2)](/assets/images/posts/research/redundancy-effect-skill-registry-routing/fig1_error_channel_decomposition.webp)
*At fixed size, a conceptual diagram that splits top-1 accuracy errors into retrieval failure (A) and ranking collision (B), and then splits the collision into harmless twin return (B1) and malicious wrong answer (B2). It is a conceptual example from the paper, not measured values.*

## What We Tried

This analogy is not an assumption. Our skill registry actually grew from about 1,600 entries to 2,234 in two weeks. The cause is the LLM curator that runs every night, rewriting skill documents. Measured by embedding distance, the rewritten documents overlap existing skills. New functionality grew slowly, and the duplicate mass swelled fast.

The criterion for a twin is a pair with cosine similarity of τ or higher. The protocol's design value is 0.95. Similarity is measured in embedding space only, never matched by words. Prior research has already shown that word hashing alone struggles to catch near copies in natural language documents.

The paper from two days ago moved size. Holding composition fixed, it showed how the top score falls as the registry grows and calibrated a two-number survival model on a single recorded point. The recorded point: 2,029 entries, top accuracy 48.9 percent, top-five recall (Recall@5) 86.7 percent.

The signature of that point is unusual. From a start of 512 entries, top accuracy fell 26.2 points and top-five recall moved 0.0 points.

The error decomposition is the same. Ranking collisions are about 38 points, retrieval failures about 13 points. Collisions are about 2.9 times retrieval failures.

Today's paper flips the experiment. It fixes size and moves composition. It splits composition into unique functionality coverage and near-duplicate mass, and asks what percentage of the top-score drop belongs to the duplicate mass.

The paper's contributions divide into five. First, a model that adds composition to size. Second, a closed-form result: when the correct answer has m twins, the top win rate falls to 1/(m+1). Third, a one-line fix that grades with cluster awareness. Fourth, a deduplication policy with a breakeven condition. Fifth, an injection protocol that writes down falsification criteria. The measurement for the last item is a design for reproducibility and is not reported in the paper.

## The Results

Start with the sturdiest result. Assume the correct skill and its twins have equal quality, and that the correct answer's cluster is retrieved best. Under that premise, the probability that the real one stands first is exactly 1/(m+1), independent of the noise size. Three twins means one in four, 25 percent.

If the whole duplicate mass fits inside the top five, top-five recall is unaffected by the twins. That is, up to four twins, where m+1 is five or fewer.

![The symmetry result: with the correct cluster as the top-retrieved cluster, the top win rate drops to 1/(m+1) while top-five recall stays flat up to four twins](/assets/images/posts/research/redundancy-effect-skill-registry-routing/fig2_symmetry_strict_vs_recall.webp)
*The paper's symmetry result. Under the premise that the correct cluster is the top-retrieved cluster, the answer must be called first among m+1 homogeneous members to win, so it falls to 1/(m+1) as copies grow. Since the whole cluster fits inside the top five up to four twins (m=4), top-five recall (Recall@5) is unaffected. This is an interpretive model, not measured data.*

In plain terms: if only the twins grow, only the top falls, and the top-five stays put.

We also measured what share of top errors are harmless twin calls. Twins are not perfect copies. With a small quality difference, the model computes the probability that the correct answer beats each twin separately, then multiplies them. For a typical duplicate cluster with three twins, the calculation says 81.5 percent of top errors are the case where a twin was called first.

If the twins are exactly identical, the probability goes down further. Three of four are twins, so 75 percent. In the error decomposition at the recorded point, ranking collisions were about 38 points. The model's conclusion is that the mere existence of copies occupies a large part of the collisions.

In plain terms: it is the number of twins, not the teacher's eye, that takes the points.

The model also produces a tax schedule. At the recorded operating point, as duplicate density rises, top accuracy is taken away. At 60 percent duplicate density, the drop is 7 to 14 points depending on how the twins collide with one another.

![The duplicate tax schedule: at the recorded operating point, top accuracy falls as duplicate density rises, and γ=1.0 is twice as steep as γ=0.5](/assets/images/posts/research/redundancy-effect-skill-registry-routing/fig3_redundancy_tax_schedule.webp)
*The duplicate tax schedule. At the recorded operating point (N=2,029, r=0.867), 60 percent duplicate density drags strict top-1 accuracy down to 41.1 percent (γ=0.5) or 34.6 percent (γ=1.0). A per-twin collision multiplier of γ=1.0 makes the tax slope twice as steep as γ=0.5. This is an interpretive model, not measured data.*

In plain terms: even at the same size, a registry stacked with twins pays a tax on the top score.

On the other hand, duplication is not only a burden. Graded with cluster awareness, a duplicate mass counts as a single competitor. In the paper's terms, this is the effective size.

In the model, at 30 percent duplicate density with three twins, the effective size comes to about 1,572.

The predicted cluster-aware top accuracy is about 55.6 percent. The recorded strict value was 48.9 percent. The roughly 6.7 point difference is the score loss created by the duplicate mass.

Under these conditions, even growing physically to 2,510 entries, the effective size stays below the 50 percent breakpoint. Duplicate density buys headroom against size.

In plain terms: in the same school, the top score varies by about 7 points depending on how the twins are graded.

The test side needs a hand too. Of the fixed 63 questions, 21 have lost their correct skill to the nightly rewrites, leaving 42 valid items. When the correct skill grows a twin, strict grading penalizes a functionally correct routing as if it were wrong. The paper calls this soft-invalid. The paper pre-registers an audit rule for such items: if the correct skill's embedding has recently crossed the τ boundary with another entry, that item is re-graded with cluster awareness.

## So What Should You Change

First, fix the grader. One line is enough. Change the rule from 'correct only when the jersey number exactly matches the answer' to 'correct if it is the answer or a member of the twin cluster'. This one line removes the B1 channel from strict errors. Harmless twins no longer take a wrong mark. Malicious B2 and the unfound A remain wrong.

Second, fix the registry itself. Merging a cluster of m twins into one representative lifts the top win rate for requests that reach that cluster from 1/(m+1) to about 1. The benefit per decision is (m/(m+1)) × q × λ. q is the share of requests that reach the cluster, and λ is the value of one correct decision. Merge when the cumulative benefit over H decisions exceeds the one-time merge cost Cc. Cc is the one-time cost of curation, re-verification, and the regression risk of merging non-homogeneous skills.

The policy is simple. Merge clusters with two or more twins and a sufficient request share. It helps rather than competes with the mitigation ladder from the paper two days ago: first the namespace gate, then the pre-filter, then description cleanup. The gate shrinks the scope of competition; the merge removes the duplicate mass at the source.

Three cost channels answer whether a merge is worth it. First, index lookup cost stays nearly flat as size grows; registry size is not the cost bottleneck. Second, embedding computation sits on the hot path of every decision. Third, prompt cache invalidation. Every time the curator rewrites a visible skill document, cached request prefixes break. The duplicate mass pays cost not only in size but in rewrite frequency.

The injection protocol also writes down falsification criteria. If the strict score falls with duplicate density and the cluster-aware score stays flat within 2 points, most of the error is B1. If the cluster-aware score tilts by 2 points or more per 0.10 of density, that is the sign of the malicious B2 channel. If cost per request is flat in size but rises only with rewrite frequency, the cache invalidation channel is confirmed.

For the company, there is a way to grow the registry by coverage. 2,234 is a number made by the nightly automatic rewrites. Clean up the duplicate mass, and even a physically larger registry can keep its effective size small. The routing tax paid on every unattended run grows lighter.

For society, a cheap way to confirm remains. Libraries of thousands of skills are now the standard in agent operations. With an injection method and a breakeven condition, small teams can treat registry hygiene as measurable engineering, not folklore.

For science, the separation of size and composition remains. Routing scaling curves had been read as a function of size alone. The model that pulls the duplicate mass out as an independent variable, and the 1/(m+1) symmetry result, are its first decomposition. The actual value of the collision multiplier γ is settled by the protocol measurement.

## What Not to Trust

Of the numbers in this post, everything except the recorded values is a model prediction. The extension that adds composition on top of the survival model, calibrated at a single recorded point of 2,029 entries, is attached by leaning on assumptions. It was not fitted to data. The paper states this point clearly.

The symmetry result leans on assumptions too. The closed-form 1/(m+1) holds when the twins are exchangeable, but the quality-difference version assumes Gaussian noise and pair-wise independence among twins. If twins share similar documents, the real confusion is sharper than the model's and the fall is faster.

The τ value of 0.95 is a design constant, not a measured threshold. Which of strict grading and cluster-aware grading is the right one differs from harness to harness. If twins differ on subtle points such as parameters or side effects, the malicious B2 channel may not be small. The protocol's second falsification criterion is there to test exactly that case.

The test is small too. On a 63-question test, the binomial standard error is about 6.3 points. The protocol is therefore a design that leans on a 5-step density sweep and case-level bootstrapping.

The measurement is limited to one registry as well: one hybrid router mixing BM25 and embeddings, one harness. Public repositories have skill files in the millions, with no compiler or type system to catch duplicates. But the numbers in this post apply to a single school only.

What transfers is the shape. Even at fixed size, part of the top-score drop comes from the existence of copies, not from a lack of quality. Grading that counts twins as wrong creates a score drop that does not actually exist. This shape does not disappear even when the parameters change.

---

You can see the paper's detail page here: [The Redundancy Effect: Decomposing Skill-Registry Size from Duplicate Mass in Router Accuracy of a 2,200-Skill Agent Harness](https://huggingface.co/datasets/thaki-AI/daily-paper-2026-09-04-redundancy-effect-skill-registry-routing)

*In this post, model-computed values are rounded to one decimal place. The recorded values are only the top accuracy of 48.9 percent and top-five recall of 86.7 percent at the 2,029-entry point, plus the 512-entry comparison point. The rest are model predictions computed with recorded parameters, and the injection protocol's measurement is not reported in the paper.*
