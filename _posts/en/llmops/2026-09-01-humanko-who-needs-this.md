---
title: "Companies Whose Turn It Is to Own a Model — the Formula Thomson Reuters Just Proved"
excerpt: "Thomson Reuters trained open weights on 175 years of proprietary data to build its own model. The program cost $40M, but the final training run was about $450K. We confirmed the same formula works at a much smaller scale — this article maps which companies, and which seats, it fits."
seo_title: "Open Weights + Your Own Data: Who Should Own a Model"
seo_description: "Thomson Reuters' in-house LLM and the Human-KO 27B release point at the same formula. A segment-by-segment look at where owning a model fits: insurance call centers, brokerage compliance, brand voice, and air-gapped public sector."
date: 2026-09-01
published: true
categories:
  - llmops
tags:
  - korean
  - open-weights
  - domain-llm
  - human-ko
  - enterprise-ai
author_profile: true
toc: true
toc_label: "Table of Contents"
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/humanko-who-needs-this/"
---

Most companies are stuck on the same question these days. Renting a general-purpose model means it fits neither the work nor the voice; building one from scratch feels out of reach. Last week an announcement changed that arithmetic, and we reached the same conclusion at a far smaller scale. This article maps which companies, and which seats, the formula fits.

## Plain terms

It is the difference between off-the-rack and tailored suits. Until now a company either wore ill-fitting ready-made clothes (general models) or believed it had to build a whole garment factory (pretraining). But the cost of tailoring has collapsed. With good fabric, anyone can have a suit cut to measure — and the fabric (your own data) is already in the company wardrobe. This tailoring picture carries through the article.

## The formula proved last week

Thomson Reuters announced Thomson, its own model. It was not built from scratch: it starts from open weights and continues training on 175 years of the company's proprietary legal, tax, and accounting data. By the company's published benchmarks it competes with top commercial models.

The cost structure is the point. The program cost $40 million over two years, but the final training run itself was about $450 thousand. In plain terms: most of the money went not into running the sewing machine but into choosing, cleaning, and measuring the fabric. Deciding what data to feed, and how to evaluate, is the body of the work; training is the short final step.

One thing to state clearly: the small version Thomson Reuters published is licensed for academic, non-commercial use only, so taking the model itself into a commercial service is off the table. What you take is the formula, not the model.

## The same formula works small

Yesterday we released a miniature of the same formula. We changed a 27B open-weights model's Korean answering habits at the weight level: bullet-wall answers dropped from 97.5% to 2.0%. In blind human-likeness face-offs it won at around the 95% level against both its base model and a leading domestic model. The final training run took less than an hour.

The scale differs; the conclusion matches Thomson's. Most of the time went into designing the textbook (training data) and building the scale (evaluation), and once those stood, training itself was the cheap step. Full numbers and limits are in the [release article](https://thakicloud.com/tech-blog/en/llmops/humanko-27b-release/) and the [comparison article](https://thakicloud.com/tech-blog/en/llmops/humanko-27b-vs-exaone/).

## Which seats it fits

**Insurance call centers are the clearest seat.** A voice bot's answer comes out as speech, not on a screen. An eight-bullet answer cannot be read aloud, and a thousand-character answer holds the line hostage. A model whose default is short, polite prose fits this seat exactly, and shorter answers cut token cost in the same stroke. Adjacent seats are already open — Hanwha Life publicly operates a virtual-conversation training system for its planners.

**Brokerages already have a precedent.** Mirae Asset Securities built a finance-tuned small model in an on-premises environment. The next step from there is voice: instead of prompting compliance language — solicitation rules, mandatory disclosures — into every request, bake it in as the weight-level default. Priced against a single missed-disclosure incident, the arithmetic closes quickly.

**Some companies' voice is itself an asset.** Wanting a brand voice inside a model is a common ask, and the order of operations matters. Scraping other people's writing is blocked by copyright; the right path is building from assets the company already owns — newsletters, official blogs, support logs, brand guidelines are all fabric. And thin source material is workable: our training corpus was fully synthetic, and that path actually holding up is one of the things this release confirmed. The same pipeline with a different textbook produces a different company's model.

**The public sector fits best of all.** Demand for self-hosted models inside air-gapped networks is spreading — Korea Post Logistics is pursuing a mail-domain model of its own. Public documents are the lowest-copyright-risk fabric there is, and the direction is concrete: instead of civil-service answers that read like regulation documents, make plain-language replies the weight-level default.

## Why now

The door that kept finance out is opening. Korea's network-separation rules are being relaxed in stages for the first time in 13 years, and regulators have said generative-model exceptions are next. Until that lands, real demand stays inside internal networks — which is why an owned model and air-gapped infrastructure move as one body for now.

Our own run is a working example of that pairing. Training and merging went through Maxis, evaluation serving ran on Metis, and the same stack deploys unchanged into Aegis on-premises environments. A model is ultimately the part that sets the cost and quality of automated work, and the better the part fits, the better everything built on it runs.

## What not to trust yet

The limits, stated plainly. Thomson's performance numbers are the company's own and not yet independently verified. The segment analysis is our reading of public reporting, not a statement of contracts or collaborations with the companies named. And what we proved is the style axis — putting a voice into weights. Injecting domain knowledge at Thomson's scale is a different data problem, and we do not yet have measurements on that axis.

If the fabric is in your wardrobe, it is time to get a quote. Tailoring costs less than you think.

## References

- [Thomson Reuters launches its own model (LawSites)](https://www.lawnext.com/2026/08/thomson-reuters-launches-thomson-its-own-proprietary-llm-trained-on-westlaw-and-practical-law-content.html)
- [Cost structure of the announcement (SiliconANGLE)](https://siliconangle.com/2026/08/24/thomson-reuters-launches-proprietary-ai-model-for-legal-work/)
- [Human-KO release article](https://thakicloud.com/tech-blog/en/llmops/humanko-27b-release/)
- [Human-KO comparison article](https://thakicloud.com/tech-blog/en/llmops/humanko-27b-vs-exaone/)
- [Human-KO model (Hugging Face)](https://huggingface.co/ThakiCloud/Qwen3.8-27B-Human-KO)
- [Hanwha Life virtual-conversation training (Hanwha newsroom)](https://www.hanwha.co.kr/newsroom/media_center/news/news_view.do?seq=14095)
- [Mirae Asset on-premises small model (Datanet)](https://www.datanet.co.kr/news/articleView.html?idxno=196443)
- [Korea Post Logistics domain model (FN News)](https://www.fnnews.com/news/202607131447199698)
- [Network-separation deregulation (Economic Review)](https://www.econovill.com/news/articleView.html?idxno=742108)
- [Generative-model exceptions planned (ZDNet Korea)](https://zdnet.co.kr/view/?no=20260420161504)
