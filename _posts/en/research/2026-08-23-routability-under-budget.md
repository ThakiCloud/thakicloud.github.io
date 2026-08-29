---
title: "Which Features Determine Routing Inside the 300-Character Window: A Causal Attribution Protocol for Skill Descriptions"
seo_title: "Routability Under Budget: Causal Attribution of Routing Accuracy to Skill Description Features - ThakiCloud"
seo_description: "The skill router sees only the first 300 characters of each description. This paper varies only the description budget (a ladder from 300 to full), ablates only the anti-trigger sentences, and scores a 1,978-skill corpus against a 63-case manual label suite with the unchanged production BM25 scorer. It delivers a protocol that attributes accuracy deltas to description edits alone; the measured recovery curves follow."
excerpt: "The router sees only the 300-character prefix of each skill description; the rest of the metadata is hidden behind components it relies on but cannot see. This paper asks which features inside that window causally determine top-1 routing accuracy and how much accuracy each additional character buys. The answer is a protocol built from a budget ladder, an anti-trigger ablation, per-case counterfactuals, and an index rebuild control check."
date: 2026-08-23
last_modified_at: 2026-08-29
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
If you run an agent harness with dozens to thousands of registered skills and have to decide how much context the skill index gets, this post is for you. In the reference harness, the skill router that maps a user request to the right skill sees only the first 300 characters of each skill description. The rest of the metadata is hidden behind components that rely on it but cannot see it. This post introduces "Routability Under Budget," an autonomous research paper from ThakiCloud AI Research. The paper asks which features inside the 300-character window causally determine top-1 routing accuracy and how much accuracy each additional character buys. A point of honesty up front: this study delivers a measurement protocol, not numbers. The measured accuracy recovery curves follow. This post makes no routing accuracy claims at all.

## The description window is an ad, not a document

This gap has two sides. On accuracy, when the router picks the wrong skill or finds no skill at all, the agent goes down a failure path before it ever reaches generation. On cost, the description index is re-read as context every session, so writing long descriptions is not free. The truncation budget is a token-quality knob that trades context cost against routing precision, and the value of that knob has been set by convention so far.

The paper reframes the problem as competition. Because the router sees only the prefix, a skill description is not a document in the ordinary sense. It is a fixed-size advertisement competing for the attention of a lexical retrieval engine against roughly 2,000 peer skills. The features that win that competition are values only measurement can settle.

Prior skill routing research covered retriever architecture, query decomposition, corpus growth, and embedding models, but never the content budget. This research team's own lineage is the same. They re-measured the architecture, weighting, ecosystem operation, and model axes, yet the description content itself stayed fixed in every study. In the paper published on 2026-07-09, the diagnosis for mixed Korean-English queries in the production harness was that the binding constraint was the retriever ceiling, not query decomposition. The repair, discard, birth, and quantization studies that followed each moved one axis at a time among architecture, corpus size, and model. The content budget axis, which asks what features inside the window determine routing accuracy, had not been measured. This paper moves that lever.

## A protocol that changes only the description window

The experiment is fully deterministic. It uses no model inference, no network access, and no accelerators. The only thing that changes between variants is the description window, and in the ablation the anti-trigger text changes with it. So every accuracy delta is attributable to that single edit alone.

The scored variants come in two families. The first is the description budget ladder: `current`, B300, B400, B600, B1000, B1500, B2000, `full`, where the run names state, in characters, how much of the description prefix the router may see. The shipped `current` regime and the truncation-free `full` regime are not kept as anchors outside the ladder.

![Budget ladder: description window per variant](/assets/images/posts/research/routability-under-budget/fig2.webp)
*The variable this study manipulates is the description prefix length, in characters. The shipped 'current' regime and the truncation-free 'full' regime sit outside this ladder. The window sizes are as designed in the variant matrix, not measured values.*

The second family is the `B300_noanti` ablation. It scores the 300-character budget with the anti-trigger sentences that begin with `Do NOT use` removed, in order to separate the anti-trigger effect from the budget effect. If top-1 rises at the same budget once the anti-trigger sentences are removed, that is direct evidence that in the narrow window the do-not-use sentences were eating the space the triggers need.

The scorer is the production pure BM25 lexical channel. The hybrid embedding channel is off, the retrieval gate is 6.0, and top-k is 5. Nothing about the scorer changes between variants. The label suite is a fixed set of 63 manual labels made up of positive, native, and negative cases, and it is held constant so that the deltas in the variant matrix come from the description window alone.

![Causal attribution pipeline](/assets/images/posts/research/routability-under-budget/fig1.webp)
A conceptual example. Only the description window changes (and in the ablation, the anti-trigger sentences), while the corpus, the production scorer, and the label set are fixed. So accuracy deltas are attributed to the description edit.*

Each variant is scored on top-1 accuracy, recall@5, and negative avoidance. What separates this protocol from a plain benchmark run is the per-case counterfactual. It records which labeled tasks drop out at 300 characters and which recover to top-1 for the first time at a larger budget. That is the point where the aggregate recovery curve becomes a per-task recovery map, showing where each skill's description gets cut and what that cut costs.

The protocol includes a control check for index rebuilding. It rebuilds the production skill routing index from source, with full descriptions, against the 1,978 (roughly 2,000) skill corpus, then cross-validates the rebuilt `current` variant against an independent run of the production bench. The scoring script runs the production bench on the cached index and looks for divergence from the rebuild. This certifies that the completed runs were measured on the same artifact the router serves, the artifact on which the ladder was scored.

The contribution of this study is the protocol itself. It turns description-writing convention into a measurable cost-quality knob for agent harnesses with a token budget. The measured accuracy recovery curves follow, and this post makes no routing accuracy claims.

## Two-channel asymmetry: B300 is strictly less informative than today

The motivation for moving the ladder is a mechanism already inside the shipped harness. The router runs on two channels. The token channel sees the full description, but the substring channel sees only the first 300 characters. Because of this asymmetry, the B300 variant is strictly less informative than today's regime. The lexical channel that actually determines top-1 routing is starved in the shipped regime, and the budget ladder measures that loss one run at a time.

![Two-channel truncation mechanism](/assets/images/posts/research/routability-under-budget/fig3.webp)
A conceptual example. The shipped regime is asymmetric: the token channel sees the full description while the substring channel sees only 300 characters. So the B300 variant is strictly less informative than today.*

What the ladder reveals is the shape of that loss. If the step from 300 to 400 is steep and the curve is flat from 1500 to full, the answer is that most of the loss happens in the first 100 characters, and the design rule is to put the triggers in the first 100. If the curve keeps climbing all the way to full, the answer is that the budget itself is the bottleneck, and the price is paid in context. Four features inside the window, the Korean trigger ratio, the ASCII keyword count, the presence of anti-triggers, and the number of trigger mentions, also correlate with per-skill top-1 rates. The paper states that it marks this correlation as an observation and does not read it as causation. The causal claims are reserved for the budget ladder and the anti-trigger ablation, the only places where the window is actually changed.

## What remains for the company, society, and science

For ThakiCloud, the deliverable is description field design rules for the 1,978-skill ecosystem. Measurement answers where triggers go, what keyword density to hold, and where the budget ceiling sits. Those rules point toward pushing the sra_bench top-1, which the earlier repair study raised to 52.9%, even higher, and cutting the skill index context cost paid every session. Because the description index is re-read every session, a saving of a few characters per skill multiplies across the whole registry.

For society, it is a token cost-quality discipline for skill metadata, applicable to every environment that runs agent harnesses in the Claude Code lineage. The basis for lowering the operating cost of skill-based automation shifts from convention to measurement. Teams registering hundreds or thousands of skills no longer need to guess how long to write descriptions. After measuring how much routing accuracy each additional character buys, they can set the budget where the curve flattens.

Scientifically, it is the first causal attribution measurement between skill description features and retrieval accuracy. As the next step beyond the structural diagnosis of the retriever bottleneck, it opens the axis of content budget rather than structure. The protocol has value before any results exist. A fully deterministic experiment that mutates only the description field and completes on a local route is reusable by any harness with a skill registry, and the index rebuild control check sets the standard for the claim that a measurement was taken on the same artifact the router serves.

## Limitations of this study

This study contains no measurements. The paper is a protocol design, and the control comparison against the rebuilt index follows together with all accuracy claims. That is the first limitation, and the reason this post should be read as a methodological contribution.

The scorer is the pure BM25 lexical channel with hybrid embedding switched off, so the results may not transfer to dense or hybrid routers. The label set, 63 hand-built cases, is narrow relative to the full query space, and top-1 deltas on such a set are coarse. The feature statistics inside the window are not causal effects. An observed correlation cannot be read as causation, and the paper itself draws that line. A corpus of roughly 2,000 skills is a single operating point, and the shape of the budget ladder can bend differently in much smaller or much larger skill ecosystems.

---

Full paper page: https://thakicloud.com/tech-blog/en/research/routability-under-budget/
