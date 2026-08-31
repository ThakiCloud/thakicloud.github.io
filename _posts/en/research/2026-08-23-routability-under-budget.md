---
title: "The Sign Only Shows Its First 300 Characters: How to Measure What Decides Routing"
seo_title: "Routability Under Budget: A Causal Measurement Protocol for Skill Description Length and Routing Accuracy - ThakiCloud"
seo_description: "The program that picks a tool for our agents reads only the first 300 characters of each tool's description. This paper builds a way to measure what inside that 300-character window decides the pick. It is designed against a 2,275-skill registry and a 63-case check set, and this post reports no accuracy numbers."
excerpt: "The picking program never sees past the first 300 characters of a skill description. This post introduces a measurement plan for what inside that narrow window decides the pick, and how much accuracy one more character buys. The paper delivers the measuring stick only; the real numbers come in a follow-up."
date: 2026-08-23
last_modified_at: 2026-08-31
tags:
  - skill-routing
  - agent-harness
  - description-metadata
  - token-budget
  - truncation
  - causal-attribution
  - retrieval-accuracy
  - bm25
  - multilingual-triggers
categories:
  - research
author_profile: true
toc: true
toc_label: "Table of Contents"
canonical_url: "https://thakicloud.com/tech-blog/en/research/routability-under-budget/"
---

The program that picks a tool for our agents reads only the first 300 characters of each tool's description, and it never sees the rest. If you run an agent that has several tools or skills registered and have wondered how long each description should be, this post is for you. Up front, honestly: this paper delivers a way to measure the answer, not the answer itself.

## In plain terms

Picture a long row of shops, more than two thousand of them. To find the shop you need, you have to read the sign out front, but you are in a hurry, so you only catch the first few words before walking past. It does not matter how good the rest of the sign is. Once you have walked past it, those words might as well not exist.

Our own agents work the same way. Each tool's description is a sign, and the picking program is the shopper skimming past. Right now this row holds 2,275 signs, and the picking program decides which shop to enter after reading only the first 300 characters of each one.

In plain terms, a sign like this is not a careful set of instructions. It is a short ad line. This paper builds a ruler for figuring out which words inside that short ad line catch the shopper's eye. The paper only builds the ruler; it does not yet report a number measured with it.

## What we did

The program running today already reads only the first 300 characters of each description. The rest sits behind a wall the program relies on but cannot see.

Widening that window sounds like it would only help, but it can also cost more. If the picking program grabs the wrong shop or no shop at all, the whole job stalls before it even starts. On the other side, a description gets re-read as context every single time, so opening the window wider means paying for more characters every time, too.

So the research team built a way to change that window size step by step and watch how accuracy moves. The experiment calls no model and touches no network. Only the window size changes between setups, so any accuracy swing has one and only one explanation.

The window size runs from 300 characters up to the full, untruncated text, laid out as a six-step ladder.

![Budget ladder: description window per variant](/assets/images/posts/research/routability-under-budget/fig2.webp)
*The variable this study manipulates is the description prefix length, in characters. The shipped 'current' regime and the truncation-free 'full' regime sit outside this ladder. The window sizes are as designed in the variant matrix, not measured values.*

Separately, one more thing gets removed and put back as a test. The sentences that start with "do not use this for" get stripped out of the 300-character window and scored again. If ranking improves once those sentences are gone, that is direct evidence they were eating the space the useful keywords needed.

The scoring itself is plain keyword matching rather than meaning-aware search, using the BM25 method, and it stays fixed across every setup. Each setup is scored on three things: does it rank the right pick first, does it land the right pick in the top five, and does it avoid false positives. A fixed set of 63 check cases stays the same throughout, so any score gap traces back to the window size alone. For each check case, the team also records the exact window size where the right answer first appears, so a single recovery curve turns into a map of where each description gets cut and what that costs.

Finally, the team checks that all of this was measured on the same material the live service actually uses. They rebuild the search list from scratch with full descriptions across 1,978, or roughly 2,000, skills, and confirm the rebuilt version matches what today's service produces.

![Causal attribution pipeline](/assets/images/posts/research/routability-under-budget/fig1.webp)
*A conceptual example. Only the description window changes (and in the ablation, the anti-trigger sentences), while the corpus, the production scorer, and the label set are fixed. So accuracy deltas are attributed to the description edit.*

What this study delivers is the procedure itself. How long a description should be stops being a habit and becomes something you can measure.

## What came out

This paper has no measured accuracy numbers yet. Two other things came out first.

First, the live service is already paying a cost today. It runs on two paths at once: one path reads the full description, and the other reads only the first 300 characters using plain keyword matching. The path that actually decides which shop gets picked is the second one, the 300-character path. In plain terms, the live service is working with less information than it could already have today, for free.

![Two-channel truncation mechanism](/assets/images/posts/research/routability-under-budget/fig3.webp)
*A conceptual example. The shipped regime is asymmetric: the token channel sees the full description while the substring channel sees only 300 characters. So the B300 variant is strictly less informative than today.*

Second, there is an observation about which words help inside the window. The share of Korean-language keywords, the count of English keywords, whether a do-not-use sentence is present, and how many times the keyword repeats, all four move together with how often a skill gets picked first. The paper is careful to call this an observation, not a cause. Only the window-size ladder and the do-not-use ablation, the two places where the window is actually changed, are allowed to make a causal claim.

## What to change

First, for our own registry of roughly 2,000 skills, the writing rules for descriptions get settled by measurement rather than a guess. Where to place a keyword, how many English keywords to include, and where to cap the window all become answerable questions. This points toward pushing the picking program's first-pick accuracy, already raised to 52.9% by an earlier study, even higher, while cutting the cost of re-reading these descriptions every session.

Second, this discipline is not ours alone. Any agent setup that registers several tools faces the same trade-off. A team registering hundreds or thousands of skills no longer has to guess how long a description should be. After measuring how much accuracy one more character buys, they can set the cutoff where the curve goes flat.

Third, this paper has value even before its results exist. Because the experiment changes only the description window and finishes on a single machine with everything else held fixed, it can be reused by any system with a skill registry. Confirming that the rebuilt list matches what the live service uses sets a standard for what it means to measure on real, in-service material.

Fourth, we are not locking in a window size yet. Until the real accuracy recovery curve exists, we treat this procedure as a direction to follow, and we leave any decision that leans on a number for the follow-up.

## What not to trust

This study contains no measurements. It is a protocol design, and the check against the rebuilt list will arrive together with every accuracy claim that follows. That is the first thing not to trust here, and the reason to read this post as a methods introduction rather than a results post.

The scoring is plain keyword matching with no meaning-aware search, so the outcome may not carry over to systems that do use meaning-aware search. The 63 check cases were built by hand and are narrow next to the full space of possible requests, so any first-pick accuracy gap measured on them will be coarse. The relationship between window features and per-skill scores is an observation, not a cause; an observed pattern cannot be read as a cause, and the paper itself draws that line. A registry of roughly 2,000 skills is a single data point, and the shape of the ladder could bend differently in a much smaller or much larger registry.

---

Full paper page: https://thakicloud.com/tech-blog/en/research/routability-under-budget/

*Figures are scaled to a 1,978-skill (roughly 2,000) registry and a 63-case check set. No accuracy value has been measured yet, and this post makes no such claim.*
