---
title: "It Fetches the Ingredients but Never Writes the Recipe: The Gap When Agents Use Tools in Order"
seo_title: "The Multi-Skill Gap: Order-Sensitive Skill Chain Routing and Its Cost-Quality Frontier - ThakiCloud"
seo_description: "When an agent has to use several tools in the right order, our current retrieval finds about three quarters of the needed tools yet almost never produces a correctly ordered plan. Measured on a 2,275-skill registry and 48 chain tasks, with why a bigger local model does not help and where the real bottleneck sits."
excerpt: "Picking one tool looks fine on the scoreboard. Chaining tools in order is a different story. The librarian pulls most of the recipe cards you need, but it never sorts them. The bottleneck turned out to be not the model that sorts the cards, but the names of the quarter of cards that were never pulled."
date: 2026-08-31
last_modified_at: 2026-08-31
tags:
  - skill-sequence-routing
  - composite-task-planning
  - order-sensitive-evaluation
  - agent-harness
  - skill-ecosystem
  - cost-quality-tradeoff
  - composer-model-tier
  - unattended-automation
  - h100-serving
  - paxis
categories:
  - research
author_profile: true
toc: true
toc_label: "Table of Contents"
canonical_url: "https://thakicloud.com/tech-blog/en/research/multi-skill-gap-sequence-routing/"
audiobook: "https://drive.google.com/file/d/1hM9OH2agQbhT-MCpvn_L2anru-BXkPcR/view"
audiobook_label: "▶ Listen: 5-minute briefing"
audiobook_note: "NotebookLM audio overview (AI-generated)"
---

Agents rarely use just one tool. A single deploy means writing a config, checking it, and confirming it came up healthy. Get the order wrong and the plan is unusable. We measured this, and our tool search finds roughly three of every four tools a job needs while almost never producing a correctly ordered plan.

This is worth your time if you run unattended agents or own the cost of their routing. The post introduces a paper our research team wrote autonomously. It is called The Multi-Skill Gap, and it looks at something no measurement of ours had looked at before: the order itself.

![Illustration of agents chaining several tools in order](/assets/images/multi-skill-gap-sequence-routing-hero.webp)
*An illustration of the core idea.*

## In plain terms

Think of cooking. You ask for a stew, and the cook has to lay out step cards in order: prep, sauté, simmer. Drop one card and there is no dish. Keep every card but shuffle them, and there is still no dish.

Agents work the same way. The cookbook is our tool registry, and it currently holds 2,275 cards. When a request arrives, a librarian program searches the cookbook and pulls out about twenty cards that look relevant.

That is where the trouble starts. **The librarian finds cards, but it never sorts them.** And every score we have kept so far asked only one question: did it find the right card? Real work is almost always a multi-card recipe.

## What we did

We took twelve workflows our agents actually run. Deploys, incident response, knowledge ingestion, code delivery, financial reconciliation, releases, security digests. We rewrote each request four different ways, giving us forty-eight test cases. Only the wording changes; the correct recipe stays fixed, so we also measure how much routing wobbles under paraphrase.

Correct recipes run two to four steps, averaging about three and a half. We verified that every tool in every answer key really exists in the registry, so the grading is structural rather than a judgment call.

We ran three arms. The first is **free search**: the live librarian, unchanged, pulling anywhere from one to twenty cards. It matches on words rather than calling a model, so its generation cost is structurally zero.

The second is **a small model we host ourselves**. We hand it the twenty cards and ask it to pick the needed ones and list them in order. The larger of the two stands in for the ceiling of the tier we were about to deploy. If the ceiling fails, the whole tier fails.

The third is **a frontier model**, included for cost only. We measured the input load of the same prompt and converted it at list prices, giving us one reference point. We report no quality number for it.

## What came out

### It fetches the ingredients but never writes the recipe

Pulling twenty cards, the librarian recovers about 76 percent of the correct ones. That part is fine. But the number of times it got the whole order right, across forty-eight tasks, was **zero**.

Unpack the numbers and you see why. Of the twenty cards, an average of 2.6 are useful and 17.4 are not. In plain terms, it brings most of the ingredients and then buries them under a pile of things you will never touch, without writing down what to do first.

![Order-sensitive chain metrics by arm](/assets/images/posts/research/multi-skill-gap-sequence-routing/fig2_arms.webp)
*Free search recovers 75.69% of gold skills as a set, while both local models produce no parseable chain at all, leaving every chain metric at 0.0000. Measured on 48 chain tasks.*

Does pulling more cards help? Going from one card to twenty lifts recovery from 22 to 76 percent. Over the same range, the share of useless cards climbs from 31 to 87 percent. How much of the order it got right barely moves, hovering near 60 percent throughout.

In plain terms, **more cards buys you ingredients and never buys you order.** Even getting only the first step right topped out at 73 percent.

![Sweep over the number of cards pulled](/assets/images/posts/research/multi-skill-gap-sequence-routing/fig1_ksweep.webp)
*Recovery rises monotonically from 0.2153 to 0.7569 while the useless-card share climbs from 0.3125 to 0.8698 and pair-order stays in the 0.57 to 0.69 band. A fully correct order appeared only twice in the sweep: 4 tasks at two cards, 1 task at four.*

### A bigger local model did not help

So hand the pulled cards to a model and let it sort them. We expected that to work. It did not. Both the small and the large model produced **no readable answer on any of the forty-eight tasks.**

The answers were not wrong so much as not answers. Opening the output, the dominant failure was repetition. The small model repeated a three-word span ten or more times in forty-two of forty-eight outputs, and in the worst case seventy-five times. Scaling the model more than eight times over recovered exactly zero recipes.

The cost, however, is not zero. Each task holds a dedicated GPU for around a second and bills roughly a tenth of a cent. In plain terms, **we were paying a small amount for nothing at all.**

![Cost per task by arm](/assets/images/posts/research/multi-skill-gap-sequence-routing/fig3_cost.webp)
*The local models spend 0.000726 and 0.001100 dollars per task at a measured chain quality of zero. The frontier model is a 0.006869-dollar reference point derived from measured input load at list prices, with no quality number.*

### The real bottleneck sits elsewhere

Here is the fact that reframes everything. The twenty pulled cards contained **all** the correct ones in only twenty-seven of forty-eight tasks, a little over half.

For the rest, no model however clever could produce the right answer. The ingredients were never in the kitchen. The misses are uneven across workflows, concentrating in knowledge ingestion and financial reconciliation.

So the gap splits into two separate problems. One is a **ceiling**: the wording of the quarter of tools the librarian never found. The other is a **floor**: the ability of the model that sorts the cards. Pulling more cards does not raise the ceiling, and scaling the model did not raise the floor.

## What to change

First, **rewriting tool descriptions is the cheapest lever we have.** The quarter that went missing was not absent from the registry; its names and descriptions simply did not overlap the words people use. Knowledge ingestion and financial reconciliation come first. This ranks ahead of buying a model.

Second, **we do not put ordered planning behind a mid-sized model we host ourselves.** On this measurement that tier costs money and returns nothing, and the model standing in for the tier we meant to deploy behaved the same way.

Third, **for work where the order is the deliverable, we budget an explicit frontier call.** That runs under a cent per task, with a cheap verification step layered on top. Frequently used four-step recipes are worth pre-building outright.

Fourth, **we change the regression suite.** The single-tool scoreboard that has been grading our router was handing a passing grade to a router that never once produced an executable recipe. Order-sensitive metrics have to sit alongside it.

## What not to trust

Forty-eight tasks, twelve workflow templates, one harness. That size characterizes one environment; it does not generalize. We did not check whether a registry of a different size or language mix produces the same picture.

The four rewordings were built to overlap the vocabulary of the correct tools to some degree, which favors word-matching search. Abbreviations or unfamiliar phrasings would lower recovery further, so the ceiling problem gets stronger rather than weaker.

We measured both local models as configured, with no repetition penalty. The zero-readable-answers result holds for that configuration. Still, no configuration invents a card the librarian never pulled, so the ceiling stands regardless. The frontier model was measured for cost only, so the third recommendation carries that gap with it.

Costs assume three dollars per GPU-hour and public list prices. Change the prices and the numbers scale, but which option is cheaper does not.

---

The full paper is here: [The Multi-Skill Gap](https://huggingface.co/datasets/thaki-AI/daily-paper-2026-08-31-multi-skill-gap-sequence-routing)

*Figures come from a 2,275-tool registry snapshot and 48 chain tasks. The body rounds for readability; exact values stay in the figure captions. The frontier model is reported as a cost anchor only, with no quality number.*
