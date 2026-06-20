---
title: "From a One-Line Topic to a Sellable Ebook: 5 Books in 6 Days with the ai-ebook-launch Skill"
excerpt: "A record of actually running an ebook production skill that bundles research, cover design, sales funnel, and deployment scripts into a single pipeline."
seo_title: "AI Ebook Production Automation Pipeline ai-ebook-launch - Thaki Cloud"
seo_description: "An ebook production skill that automates topic selection, manuscript writing, gpt-image-2 cover design, sales page, and Whop/X distribution across 6 stages. A real-world record of producing 5 Korean ebooks in 6 days, including its limitations."
date: 2026-06-20
last_modified_at: 2026-06-20
categories:
  - news
tags:
  - ai-ebook-launch
  - ebook
  - automation
  - agentic-pipeline
  - gpt-image-2
  - content-pipeline
  - skill
  - self-publishing
lang: en
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/en/news/ai-ebook-launch-skill-pipeline/"
reading_time: true
---

⏱️ **Estimated reading time**: 7 min

![Conceptual diagram of the one-line topic to sellable ebook automation pipeline](/assets/images/ai-ebook-pipeline-hero.png)

This post is not about what the books say. It is a record of how far automation goes when the entire process of producing a book is wrapped into a single skill. Over the past 6 days, the `ai-ebook-launch` skill produced 5 Korean ebooks. The interesting part is not "what books were written" but "which steps between a one-line topic and a sales-ready state ran without human hands."

## What This Skill Produces

The input is one niche topic. The output is not just a book but **a complete sales kit**. A PDF ebook with a cover, a 30-day social content calendar, a sales page, a lead magnet, an email sequence, and deployment scripts all land in one folder. Think of it less as a tool for writing a book and more as a tool for getting a book ready to sell.

The folder structure reveals the skill's thinking.

```
outputs/<niche-slug>/
  research.md  content_calendar.json  sales_copy.json
  product.json  emails.json
  book/ (outline.json chapters/ images/ cover.pdf interior.pdf ebook.pdf)
  book-ko/ (Korean edition)
  sales_page.html  lead_magnet.pdf  quality_report.md
```

All data is in JSON; human-readable outputs are PDF and HTML. Code owns the format, the model fills in the content.

## The 6-Stage Pipeline

**1. Research.** Competitive analysis of the target niche, real creator handles, content angles, and price benchmarks are gathered via web search. The result is consolidated into a single `research.md` file.

**2. Content engine.** A 30-day organic social calendar is created. Each post gets a hook type and a CTA, and passes validation against the X API format. The tone mimics a human writing in the creator's style.

**3. Product, meaning the book itself.** This is the heaviest stage. An 8 to 12 chapter outline is drafted, and a sub-agent is launched per chapter to write the body text. The reason for a fresh agent per chapter is context hygiene. Pushing all chapters into one session causes quality to degrade toward the end. The cover image is generated with gpt-image-2, and the key here is keeping text out of the prompt. Korean characters break inside AI-generated images, so only the background is generated and the title is overlaid by a Python script using a font. Korean editions use Apple SD Gothic Neo. Finally `generate_ebook.py` merges the cover and interior into `ebook.pdf`.

**4. Sales assets.** Sales copy is created with a headline, problem and solution framing, pricing, FAQ, and guarantee language. An HTML sales page is auto-generated from that JSON. A 3 to 4 chapter lead magnet and a 5-email nurture sequence are produced alongside.

**5. Distribution.** This stage only runs when credentials are present. Whop is the recommended store; its API has been validated for product creation, pricing plans, and payment webhooks. Gumroad is not recommended because file upload is UI-only and the webhook API returns 404 as of June 2026. Social distribution uses the X `POST /2/tweets` endpoint for organic posting only.

**6. Quality gate.** Beyond automated structure checks, content depth, copy, and visuals are scored from 0 to 10. The requirement is an average of 8.0 or above with no individual item below 6. Failing scores return to a revision loop.

## 6 Days, 5 Books: Observed Results

The metadata of the skill's output looks like this.

| Title | Format | PDF size | Generated | Sample |
|---|---|---|---|---|
| 욕망을 읽는 10가지 시장의 법칙 (v2) | Korean ebook.pdf | 2.9 MB | 6/18 | [View PDF](https://drive.google.com/file/d/1LUDP2cVE4dpdRfn7X5hjYRMxqGrlzJbp/view) |
| 사람을 읽는 22가지 마음의 법칙 | Korean ebook.pdf | 261 KB | 6/18 | [View PDF](https://drive.google.com/file/d/1jRDO9deuRhuyuq7FvKdjT1PwV6s0omj-/view) |
| 부의 지수 함수 | Korean ebook.pdf | 88 KB | 6/19 | [View PDF](https://drive.google.com/file/d/1wi0bIwAPA8DiwxI_fQaxoFPCXHZqEJNL/view) |
| 욕망을 읽는 10가지 시장의 법칙 (v1) | Korean ebook.pdf | 216 KB | 6/18 | (omitted) |
| 주린이를 위한 투자 전략 교과서 | Korean book-ko | (PDF not generated) | 6/16 | (PDF not generated) |

Three of the output PDFs are publicly available on Google Drive. The "View PDF" links above let you see the actual skill output directly.

PDF sizes range from 216 KB to 2.9 MB, reflecting differences in chapter count and image density. Running the same topic twice as v1 and v2 is also visible. This is closer to fast iteration than producing a polished final version in one pass.

## Honest Limitations

Listing only the positives makes a post dishonest. The current boundaries of the skill are clear.

Output is PDF only. No EPUB, no KDP native format. All five books are in Korean. Pipelines for other languages exist but were not used in this run. Distribution scripts are prepared but no live store uploads or Amazon KDP registrations were confirmed. Payment and delivery assume Whop API and direct PDF delivery under a direct-sales model; traditional bookstore distribution is outside the skill's scope. Some figures like pricing fees are partially unverified and should be checked against source materials before adoption.

Rules are also built in. Cold DM automation is blocked, and scraping behind anti-bot walls is not allowed. Only reactive auto-replies to inbound DMs are permitted. Finance, health, and legal niches require mandatory disclaimer language.

## ThakiCloud Perspective

What we find interesting about this skill is not the books themselves but the shape of the pipeline. Breaking research, generation, validation, and distribution into discrete stages with code owning the format at each stage matches the principles we apply to our own internal batch skills. A fresh sub-agent per chapter to cycle out context, leaving only content to the model while cover text and assembly go to deterministic scripts, and a quality gate that checks both average score and minimum floor simultaneously: the content type changes, but the skeleton transfers directly.

This is not a story about automation replacing people. Choosing the topic, setting the quality gate thresholds, handling licensing and disclaimers: those judgments remain human. What the skill did was push the repetitive labor between those judgment points at the pace of 5 books in 6 days.
