---
title: "When One Skill Description Hijacks the Routing of an Entire Registry: The Vulnerability and the Two Gates at Write Time"
seo_title: "ThakiCloud Autonomous Paper Analysis: The Registry Hijack - In a 2,029-skill registry, the SKILL.md description is the only routing signal of the BM25+embedding hybrid router. Maliciously editing this one description, rewritten nightly by the machine, can hijack top-1 routing on the first query, while top-1 drops by about 49 points and Recall@5 moves only about 0.2 points. The vulnerability split between the lexical lane and the semantic lane, the loss of attenuation under rank-level fusion (RRF), the union of the two gates, the idf-weighted description set-difference and embedding drift, a full-registry scan cost under 0.15%, and a precise restore path - ThakiCloud"
seo_description: "The skill registry description is the only routing signal of the BM25+embedding hybrid router and an everyday writing target rewritten nightly by the machine. This paper covers the speed at which one malicious description hijacks top-1 routing, the vulnerability split between the lexical lane and the semantic lane, the cost at which two complementary gates separate the four attack conditions from benign variation (full-registry scan, under 0.15% of a night cycle), and the precise restore path."
excerpt: "The skill description rewritten nightly by the machine is the router's only routing signal. When one sentence hijacks top-1 routing, the dashboard's Recall@5 moves only 0.2 points, and two gates catch every attack at a cost under 0.15% of a night cycle."
date: 2026-09-21
last_modified_at: 2026-09-21
tags:
  - skill-registry
  - skill-routing
  - adversarial-robustness
  - hybrid-retrieval
  - bm25-embedding-fusion
  - agent-security
  - embedding-drift
  - supply-chain
  - research
categories:
  - research
author_profile: true
toc: true
toc_label: "Table of Contents"
canonical_url: "https://thakicloud.com/tech-blog/en/research/registry-hijack-skill-router-robustness/"
---

You need this article if you run an agent that routes itself among thousands of skills. One sentence can hijack the routing of an entire registry. Because the description the machine rewrites nightly is the only signal the router sees and, at the same time, an everyday writing target.

This article introduces a ThakiCloud paper that pins down this risk and the cost of a check placed inside the same loop. The conclusion, in one line. One malicious description hijacks the top pick on the first query after it is written. The dashboard metric moves only 0.2 points, the top pick falls 49 points, and detection costs under 0.15% of a daily cycle.

![Illustration of the core idea of When One Skill Description Hijacks the Routing of an Entire Registry: The Vulnerability and the Two Gates at Write Time](/assets/images/registry-hijack-skill-router-robustness-hero.webp)
*A visual metaphor for the article's key idea.*

## Put Simply

A skill registry is a switchboard staffed by 2,029 employees. Every turn, that is, per query, the switchboard transfers a call to one employee. It looks at exactly one thing before transferring: the one-line job description card stuck on each desk, the description. The resume, the skill body, is read only after the call has been transferred. The machine rewrites the cards nightly. That is the entire setup of this paper. The description is the only routing signal and, at the same time, an everyday writing target.

Someone changes one employee's card to "I handle payment errors exclusively." Even if that employee cannot process payments, every payment-error call still lands on them. That is a registry hijack. The company barely sees it on the dashboard, because the metric that tracks "is the right employee in the top five" barely moves when one card changes. The dashboard does not see where the call actually goes. So the defense is not placed on the dashboard but at the moment the card changes. That is the entire article.

## Why the Line Rewritten Every Night Is an Attack Surface

The harness studied by this paper runs a skill registry of 2,029 skills. Every turn the router must pick one skill, and the only text the router scores is the SKILL.md front matter, the description. The skill body is loaded only after routing is done. Any defense that guards the body never sees the routing decision.

The description is not static. An LLM rewrites the descriptions of the entire registry nightly, the registry syncs over git, and agents that never talk to a human route by trusting it unconditionally, every turn. The writing, the fixing, and the trusting are all machine. Between a well-written description and a hijacked routing decision there is only the fact that writing is routine.

The attack needs almost nothing. No new skill, no body change, no other entry. Just rewrite the description of one existing entry. The attacker does not control the query stream, the router, the encoder, or the thresholds. There are three writable channels. Indirect prompt injection reaching the LLM that edits the text nightly. A third party with commit access to the registry. A self-evolving agent that generates skills from a template on its own. In all three cases the delivered artifact is the description, and the victim is the routing decision that fires before the body is read.

Exposure compounds. The description is scored on every turn of every agent that has synced the registry. Until it is rolled back, a single write carries endless exposure. The anomaly is not in the fact that the description changed but in the direction of the change. So monitoring must watch direction and be present at the moment of writing.

The paper fixes a deterministic attack family. Stuffing, which inserts the target task document wholesale. Paraphrase, which keeps the semantic frame and drops half of the content words. Disguise, which appends only 3 rare tokens that appear in at most 2 documents of the corpus. And blind, the single-description condition that targets all cases at once. On top of the four conditions, a benign paraphrase control group from an unrelated skill. All built from templates, no LLM in the loop. This is the lower bound of an LLM attacker and the exact target the gates must distinguish.

![Registry hijack: the attack channel and the in-loop defense](/assets/images/posts/research/registry-hijack-skill-router-robustness/fig1.webp)
*Conceptual diagram of the attack channel and the defense location. One machine-rewritten SKILL.md description is the only step that separates routine overnight writing from a hijacked top-1 routing decision. The defense stands in the same loop, where two gates after writing and a precise restore path take that place. A conceptual diagram from the interpretive model, not a measured setup.*

## The Lexical Lane Has a Ceiling, the Semantic Lane Is Open

The router's two lanes have different vulnerabilities. That is the paper's first concrete finding. The lexical lane, the BM25 side, has a ceiling.

Under a fixed query and a fixed corpus, the highest score a description can achieve is computable from corpus statistics alone. Stuffing the task document wholesale and appending just 3 rare tokens both hit the same ceiling. Wholesale insertion earns no substantial edge over 3 tokens. There is a flip side too. A description scoring near the ceiling against an unrelated query is an anomaly visible from the score distribution alone, without ground truth. The lexical attack surface is a closed, finite set.

The semantic lane, the embedding side, is open. Cosine similarity has no idf structure, and the set of descriptions close in meaning to the query, the paraphrase neighborhood, is effectively infinite. The paraphrase that keeps the semantic frame and drops only half the content words is the native attack of this lane. It is invisible to any statistic computed from token counts. The only statistic that constrains meaning lives on the embedding side, and it is how far the description's own vector has twisted from its stored baseline. That is embedding drift.

Fusion makes this worse. The production combiner is rank-level fusion (RRF). Under score-level fusion a weight attenuates interference from the other lane, but under RRF that attenuation disappears. A description pinned at lexical rank 1 keeps the full contribution of that lane, regardless of its semantic rank. As a result, the 3-token disguise, which barely moves meaning, achieves a large part of wholesale stuffing under RRF. A prediction that would be false under score-level fusion.

![Arm-vulnerability split: which lane each attack travels (qualitative)](/assets/images/posts/research/registry-hijack-skill-router-robustness/fig2.webp)
*Conceptual diagram of the per-lane vulnerability split. Lexical attacks saturate at the ceiling computable from the BM25 lane's corpus, semantic attacks pass through the open embedding lane, and the deployed rank-level fusion (RRF) removes the attenuation that score-level fusion provided. A conceptual diagram from the interpretive model, not a measured setup.*

## Why One Sentence Is the Peer of Thousands of Background Skills

The paper defines the top-1 hijack rate, where top-1 means the top pick. In the 63-case evaluation suite, the fraction of gold cases in which the injected description takes the top slot. The quantity the gates must keep near zero.

Fit the injection into a registry growth survival model and the risk of a single injected description equals the number of background skills in collision mass. At the calibration point, a 20 percent hijack rate is the mass of more than 800 background skills. In human terms, one card carries the weight of the whole switchboard.

Above 50 percent, the equivalent mass exceeds the entire registry, 2,029 skills. One description becomes the registry itself, in collision mass.

Speed is a step, not a drip. The rewritten description changes the score on the first query after it is written. The time to hijack is one night cycle. The attenuation on the size axis built up over 3 weeks of growth, while the hijack completes in a single write. After that, the only clock that matters is the detection interval. Without gates, a hijacked description lives out its full lifespan inside the registry and exposure keeps growing.

The natural monitor is blind. A full-capture injection moves top-1 by about 49 points while Recall@5 (recall, the fraction of cases in which the right answer lands within the top five candidates) moves only about 0.2 points. The concealment ratio is a bit over 200 to 1.

It is already blind on the size axis too. As the registry grew from 512 to 2,029, top-1 fell 26.2 points and Recall@5 did not move. A recall-centered monitor is doubly blind, to growth and to hijack. So the defense must sit at the moment of writing, not in a downstream monitor.

## Two Gates at the Moment of Writing Catch Every Attack

The gates live inside the loop that writes the description. They run after writing, before commit, once per night cycle. The job is to separate the four attack conditions from benign variation and hand flagged skills to the restore path. They must be cheap enough to run every cycle.

The first gate is the idf (inverse document frequency) weighted description set-difference. For each skill whose description changed, it compares the token sets before and after, and computes the idf-weighted change mass and the count of newly arrived rare tokens. Zero embedding calls.

Why idf-weighted. The attack moves 3 tokens, and each appears in at most 2 documents of the corpus, so each one is heavy. A benign paraphrase scatters a change of similar size across common words. On raw token overlap the order inverts and the benign side looks more changed. The idf weighting and the rare-token counter tell the two apart.

This gate's blind spot is the semantic lane, by construction. A careful paraphrase that keeps token mass stable is invisible to it.

The second gate is embedding drift. Each changed description is embedded with the router's own encoder. The distance from the description's own stored baseline is measured as 1 minus the cosine. One embedding per changed description. But the overnight incremental index has already re-embedded the changed descriptions and updated the index. So the marginal cost is vector storage and comparison, effectively free.

This statistic is query-independent. That makes it the detector for the semantic lane. A paraphrase that moves meaning must by construction move this too, and a benign paraphrase that preserves meaning moves it almost not at all.

The two gates are complementary. The set-difference gate misses token-stable semantic paraphrases. The drift gate lets benign variation through cleanly, but keeps a residual blind spot for low-mass lexical injections close to meaning-preserving. Their union, the scheme that detects if either one fires, covers all four attack conditions and does not touch the benign control group. Because the attack family travels one lane at a time, the union is the minimal complete gate.

![Gate complementarity: which gate sees which attack (qualitative 0/1)](/assets/images/posts/research/registry-hijack-skill-router-robustness/fig3.webp)
*Conceptual diagram of gate complementarity. Each gate misses one attack lane. The description set-difference gate misses semantic paraphrase, and the drift gate misses token-stable disguise. Their union detects all four attack conditions and does not detect the benign curator control group. A conceptual diagram from the interpretive model, not a measured setup.*

The cost calculation tilts one way. A full-registry drift scan is under 0.15% of a daily cycle, even at a pessimistic upper bound on encoder latency. The gates' cost is bounded, while the cost of a missed hijack is the exposure window times the hijack rate times the off-routing cost. Until a downstream monitor fires, the exposure window is infinite. If the off-routing cost is positive, the gates pay for themselves even if the hijack lasts only a few turns.

Restore is exact by construction. The injection is at the text level, so returning the description to the stored baseline text and the embedding to the stored baseline vector brings back the pre-injection registry bit for bit. Scores are deterministic. Same text, same query, same index, same score. The acceptance criterion is that the 5 metrics of the 63-case suite are exactly equal to the recorded baseline. Not approximately equal.

## So What Should You Change

What remains for the company running the harness is in-loop defense with a price tag. In a setup where an LLM rewrites 2,000-plus descriptions every night and agents that do not talk to a human route by trusting them, a single point of failure is a risk you can no longer afford. The two gates plug into the night cycle and restore is exact. Also left behind is the conclusion that a Recall@5 dashboard alone cannot hold routing quality. Top-1-level monitoring at the moment of writing is what the loop must own.

From the ecosystem view, the skill ecosystem turns machine-written metadata into a trusted channel for autonomous agents. This paper converts the first attack surface of that channel into a price. The skill-registry counterpart of software supply chain poisoning. Where the attack budget is one sentence rather than a poisoned package, and detection costs less than a fraction of a night cycle, the channel stays a trustworthy one.

What remains for science is the first controlled study of adversarial description injection against a hybrid retrieval router. The finding that the two lanes break differently. The lexical lane has a ceiling computable from the corpus, and the semantic lane is open. Also left is the demonstration that, under the deployed rank-level fusion, a weight is no longer an attenuator. Standing up the top-1 hijack rate as a registry robustness metric extends the registry scaling research line from benign variation to adversarial variation.

## What Not to Trust

First, this is an interpretive paper. Every number in this article is a model prediction calibrated at recorded production points, not a new measurement. The paper pre-registers a falsification protocol with 6 criteria. Each criterion is set to falsify a specific claim if it exceeds the number that claim makes.

The calibration point: 2,029 skills, top-1 around 49 percent, Recall@5 around 87 percent.

The attack is a lower bound. The attack family is built from templates without an LLM, and the per-case conditions use oracle targeting in which the attacker reads the target task document. An LLM attacker optimizing the templates is the upper bound, and the blind condition is the untargeted lower bound. The single-injection framing excludes multi-description attacks.

Gate thresholds are not fixed in advance. That a threshold pair separating the four conditions from the benign control exists is an existence claim, found by sweep. If an encoder update invalidates the stored baseline vectors, a one-time re-baselining the size of a full scan is required.

Harness-specific. One harness, one bilingual corpus, one local 300 million parameter encoder, one fusion constant. The transferable claims are the structural ones. The lexical ceiling is a property of BM25-family idf structure, RRF saturation is a property of rank-level fusion, and the concealment ratio is a property of the calibrated Poisson tail. The cost bound is pure arithmetic of size times cost. The gates statistically separate attack from variation only, and the verdict on whether a flagged skill is truly malicious is handed to a human reviewer.

The paper's detail page, with the formulas and the attack conditions table, is here: https://huggingface.co/datasets/thaki-AI/daily-paper-2026-09-21-registry-hijack-skill-router-robustness
