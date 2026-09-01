---
title: "The Score Stays the Same, but the Top Has Already Fallen Below Half: The Curse of Skills"
seo_title: "List-Size Scaling Law for Skill Routing Accuracy, Top Accuracy Breakpoint, Mitigation Order - ThakiCloud"
seo_description: "Our agent's tool list grew from about 1,600 entries to 2,029 in three weeks, and the monitoring score stayed the same. With a two-number survival model we find the size at which top accuracy halves, about 1,950, and show how to keep quality by shrinking the exam room first."
excerpt: "The test quietly shrank from 63 questions to 42, and the score stayed the same. As the school grows, more students come to look like that child, and the odds of putting the right answer at the front fall below half. Monitoring only checked whether it made the top five."
date: 2026-09-02
last_modified_at: 2026-09-02
tags:
  - skill-routing
  - retrieval-scaling-law
  - skill-ecosystem
  - agent-harness
  - registry-size
  - recall-at-k
  - top-1-accuracy
  - bm25-embedding-fusion
  - registry-churn
  - unattended-automation
categories:
  - research
author_profile: true
toc: true
toc_label: "Contents"
canonical_url: "https://thakicloud.com/tech-blog/en/research/curse-of-skills-registry-scaling/"
audiobook: "https://drive.google.com/file/d/1JH-aRBG3VlDwCPi-NHVdAdLp5uuuTvHP/view"
audiobook_label: "▶ Listen: 5-minute briefing"
audiobook_note: "NotebookLM audio overview (AI-generated)"
---

The score is unchanged, but the chance of choosing the right answer first has already fallen below half. This post is for you if you are a Korean cloud or AI engineer responsible for the quality of the skill router. Today we introduce a paper our research team wrote autonomously. Our agent's tool list quietly grew from about 1,600 entries to 2,029 in three weeks. In the meantime, the monitoring score landed back on the same number as before.

![Illustration of the core idea of The Score Stays the Same, but the Top Has Already Fallen Below Half: The Curse of Skills](/assets/images/curse-of-skills-registry-scaling-hero.webp)
*A visual metaphor for the article's key idea.*

## In plain terms

Think of an exam classroom. You have to find one child among 1,600 students. When the teacher lines up the whole school, if that child is standing within the first five, you record a 'found'.

But in practice, what has to happen is that child standing at the very front of the line. As the school grows, more students come to look like that child. So the odds of standing at the front drop sharply. The odds of making the top five stay almost the same.

The monitor only checks 'is it in the top five?'. So even when the front collapses, the score looks stable. The paper calls this phenomenon the curse of skills.

And the test has its own problem. The graded test had 63 questions. While students' names changed and dropped off, only 42 questions remained. Even if the same score comes out on a shrunken test, that is not stability; it is the sound of the test rotting.

In plain terms: the school grew, the test shrank, and the score stayed the same.

## What We Tried

The paper moves only one variable. Prior skill routing research varied the description text, compression, recovery, and ordering while holding the list size fixed. This paper does the opposite: it grows only the list.

The core is a survival model written with two numbers. The first number is the probability that the right answer qualifies to enter the competition. The second is the probability of staying ahead, per competitor. To remain at the front, it must survive every one of the remaining competitor exposures.

The model is calibrated from a single recorded point. At a list of 2,029 entries, top-five recall was 86.7 percent and top accuracy was 48.9 percent. These two numbers determine both calibration values. So every remaining number in this post is a prediction of the model.

Break down the top failures, and 'found it, but a competitor got ahead' is 38 points, while 'never found the right answer at all' is 13 points. Collisions are about 2.9 times retrieval failures.

In plain terms: it is a problem of being pushed out by confusion. It points at the competitors as the place to fix.

## The Results

First, the breakpoint. In the model's prediction, the list size at which top accuracy halves is about 1,950. That is smaller than today's 2,029. We are already past the half point.

The prediction curve is steep. In a classroom of 128, most stand at the front. At 8,192, you do not even hit one in ten.

The monitoring blind spot comes from here. While the list grows from 512 to 2,029, top accuracy drops 26.2 points. Top-five recall is 0.0 points; it does not move at all.

If the teacher only checks 'is it in the top five?', you do not know the front has already collapsed. This is the central prediction of the paper.

![Comparison of the predicted top accuracy curve and the top-five recall curve by list size](/assets/images/posts/research/curse-of-skills-registry-scaling/fig1_accuracy_vs_registry_size.webp)
*Top accuracy starts at 0.837 with a list of 128 entries, falls steeply to 0.489 at the recorded point of 2,029, and reaches 0.086 at 8,192. Top-five recall (Recall@5) stays near 0.867 up to about 4,000 entries. That flatness is the monitoring blind spot. These are predictions from an interpretive model, not measured data.*

In plain terms: behind the same score, the size of the classroom was different.

## So What Should You Change

The paper ranks three levers by predicted top accuracy.

The first is the namespace gate. Only skills in the namespaces a request could reach enter the competition. The right answer is always inside its own namespace, so nothing is missed. If only 5 percent of the 2,029 are admitted, the model predicts 84.3 percent top accuracy.

The second is the pre-filter. It shrinks the candidates before scoring. The cost is that it can miss the right answer too. The best setting, 128 candidates with a 95 percent right-answer inclusion rate, predicts 79.5 percent.

The third is description cleanup. It edits the descriptions of skill pairs that look similar to each other, cutting the confusion. Even fixing half of the confusing pairs leaves it at 65.1 percent.

The order is clear. First, reduce the number of students entering the exam room. Then, fix the wording.

![Comparison of predicted top accuracy across the three mitigation levers](/assets/images/posts/research/curse-of-skills-registry-scaling/fig2_mitigation_ladder_ranking.webp)
*The order assigned by the model. The namespace gate (5 percent admitted) gives 0.843, the best pre-filter setting (pool 128, inclusion 0.95) gives 0.795, and description cleanup (improving half of the confusing pairs) gives 0.651 predicted top accuracy. These are predictions from an interpretive model, not measured data.*

In plain terms: cutting down the students comes before fixing the sentences.

And fix the test itself. At the rate names change and drop off, the valid questions of a fixed test halve about every 36 days.

So the paper offers four devices. Record the verification time of each question. Report the number of valid questions together with every score. Deliberately change some questions and measure how much the score wobbles. And run the test with recently verified questions.

![Decay curve of the valid-question ratio of a fixed test under the flow of renames and deletions](/assets/images/posts/research/curse-of-skills-registry-scaling/fig3_suite_validity_decay.webp)
*A constant-hazard fit for the loss that quietly shrank the test from 63 questions to 42. The valid-question ratio halves in about 36 days, and the recorded point corresponds to a valid ratio of 0.67. These are predictions from an interpretive model, not measured data.*

We also write down, one line each, what this work leaves behind. For the company: monitoring gains eyes. You can now tell whether the router is degrading or the test is moving. For society: the cost floor lowers. If quality is held with a fixed order and cheap devices, small teams can run thousands of skills unattended without buying top-tier model APIs. For science: the first empirical study that takes list size as the variable remains. It is the first attempt to confirm in agent capability routing that, like a needle in a haystack, success decays exponentially as the candidates grow.

## What Not to Trust

All the numbers are calibrated from a single recorded point. From the two scores on a list of 2,029 entries with 42 valid questions, both calibration values come out. A separate measurement the paper designed in advance answers whether the same slope appears on smaller lists.

Treating competitors as independent of one another is the weakest bridge. Skills that share similar descriptions confuse one another much more sharply. If the descriptions homogenize, the real decay is faster than the model's. The breakpoint of 1,950 should be read as an upper bound.

The composition of requests is held constant over time. If ambiguous requests increase, the decay is faster. The measurement is also limited to one harness, Korean-English bilingual descriptions, and one fusion method.

The transferable claim is the shape itself. The pressure of size is exponential, not linear. Monitoring that only looks at the top five is structurally blind.

---

You can see the paper's detail page here: [The Curse of Skills: A Two-Parameter Scaling Model for Retrieval Routing Accuracy in a 2,000-Skill Agent Harness](https://huggingface.co/datasets/thaki-AI/daily-paper-2026-09-02-curse-of-skills-registry-scaling)

*In this post, numbers like 0.843 are rounded to one decimal place. The recorded production data is a single point at 2,029 entries. All the other numbers are predictions of the model calibrated at that point, and are the targets of confirmation by the measurement protocol the paper pre-registered.*
