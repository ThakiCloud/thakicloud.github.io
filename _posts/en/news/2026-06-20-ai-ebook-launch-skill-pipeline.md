---
title: "From a One-Line Topic to a Sellable Ebook: Six Days, Five Books with ai-ebook-launch"
excerpt: "A hands-on record of running the ai-ebook-launch skill pipeline that ties research, cover art, a sales funnel, and distribution scripts into a single workflow."
seo_title: "AI Ebook Production Automation Pipeline ai-ebook-launch - Thaki Cloud"
seo_description: "An ebook production skill that automates six stages: topic research, body writing, gpt-image-2 cover, sales page, and Whop/X distribution. A real run record that produced five Korean ebooks in six days, with honest coverage of its limits."
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
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/en/news/ai-ebook-launch-skill-pipeline/"
lang: en
reading_time: true
---

⏱️ **Estimated reading time**: 7 min

This post is not a book review. It is a record of how much of the end-to-end book production process can be automated when the whole thing is wrapped in a single skill. Over the past six days, the `ai-ebook-launch` skill produced five Korean ebooks. The interesting part is not what the books are about but which steps ran without any human input, from a one-line topic to a state ready to sell.

## What the Skill Produces

The input is a single niche topic. The output is not just a book but a **complete sales kit**. An ebook PDF with a cover, a 30-day social content calendar, a sales page, a lead magnet, an email sequence, and deployment scripts all land in one folder. Think of it as a tool that prepares a book for sale, not merely one that writes it.

The folder structure reveals how the skill thinks.

```
outputs/<niche-slug>/
  research.md  content_calendar.json  sales_copy.json
  product.json  emails.json
  book/ (outline.json chapters/ images/ cover.pdf interior.pdf ebook.pdf)
  book-ko/ (Korean edition)
  sales_page.html  lead_magnet.pdf  quality_report.md
```

All data stays in JSON; human-readable outputs go to PDF and HTML. Code owns the format; the model fills in the content.

## The Six-Stage Pipeline

**1. Research.** The skill gathers competitive analysis for the target niche, real creator handles, content angles, and price benchmarks via web search. The result is condensed into a single `research.md` file.

**2. Content engine.** A 30-day organic social calendar is generated. Each post gets a hook type and CTA, and every entry is validated against the X API format. The tone mimics a human creator's style.

**3. The product (the book itself).** This is the heavy stage. An outline of 8 to 12 chapters is drafted, then a separate subagent is launched per chapter to write the body text. Using a fresh agent per chapter is a context hygiene decision: cramming all chapters into one session degrades quality in the later chapters. Cover images are generated with gpt-image-2; the key is to keep text out of the prompt, because Korean characters break inside generated images. A Python script overlays the title using a font (Apple SD Gothic Neo for the Korean edition) after generation. Finally `generate_ebook.py` merges the cover and interior into `ebook.pdf`.

**4. Sales assets.** A sales copy JSON is built with headline, problem-solution framing, pricing, FAQ, and a guarantee statement. An HTML sales page is auto-generated from that JSON. A 3-to-4-chapter lead magnet and a five-email nurture sequence come out alongside it.

**5. Distribution.** This stage only runs when credentials are present. Whop is the recommended store; its API is verified for product creation, pricing plans, and payment webhooks. Gumroad is not recommended because file upload is UI-only and the webhook API returns 404 as of June 2026. Social posting uses the X `POST /2/tweets` endpoint for organic posts only.

**6. Quality gate.** Beyond structural validation, the gate scores content depth, copy, and visuals on a 0-to-10 scale. The batch must average 8.0 or above with no individual dimension below 6. Anything that falls short goes back through a revision loop.

## Six Days, Five Books: What the Numbers Say

Here is the metadata from the actual runs.

| Title | Format | PDF size | Date |
|---|---|---|---|
| 10 Laws of Desire-Driven Markets (v2) | Korean ebook.pdf | 2.9 MB | 6/18 |
| 22 Laws of Human Psychology | Korean ebook.pdf | 261 KB | 6/18 |
| 10 Laws of Desire-Driven Markets (v1) | Korean ebook.pdf | 216 KB | 6/18 |
| Investment Strategy for Beginners | Korean book-ko | (PDF not generated) | 6/16 |
| The Exponential Wealth Formula | Korean ebook.pdf | book-pipeline | 6/19 |

PDF size varies from 216 KB to 2.9 MB, reflecting differences in chapter count and image density. The same topic appears as v1 and v2, showing that the workflow favors quick iteration over single-pass perfection.

## Honest Limits

Listing only the positives would make this post misleading. The boundaries of this skill are real.

Output format is PDF only. There is no EPUB and no KDP-native format. All five books produced were in Korean. A multi-language pipeline exists but was not exercised in this run. Distribution scripts are ready but no live store upload, KDP listing, or actual sale was confirmed. The revenue model assumes direct sales via Whop API and PDF delivery; traditional retail distribution is out of scope. Some figures such as platform fee percentages were not verified and should be checked against primary sources before use.

There are also hard-coded rules. Cold DM automation is blocked; scraping behind anti-bot walls is blocked; only reactive auto-replies to inbound DMs are allowed. Financial, health, and legal niches require mandatory disclaimers.

## ThakiCloud Perspective

What makes this skill interesting to us is not the books themselves but the shape of the pipeline. Breaking the flow into research, generation, validation, and distribution stages, with code owning the format at each step, is the same principle we apply to internal batch skills. Launching a fresh subagent per chapter to reset context, having the model handle only the prose while a deterministic script handles cover text and final assembly, and running a quality gate that checks both average and minimum scores simultaneously, all of this transfers directly regardless of content type.

This is not a story about automation replacing human judgment. Picking the topic, setting the quality gate thresholds, and handling licenses and disclaimers still require a person. What the skill did was handle the repetitive work in between, at a pace of five books in six days.
