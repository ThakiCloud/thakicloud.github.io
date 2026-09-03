---
title: "We Actually Ran Agent Evaluation on Our Own Platform"
excerpt: "Instead of reading code, we pressed the actual evaluation button. Here is what happened when we graded real agents that use tools across multiple turns and deliver a final result, under real conditions."
seo_title: "Running Praxis Agent Evaluation for Real: What We Found"
seo_description: "We called the real evaluation API against real, working agents on our agent platform Praxis. Here is what recording a multi-turn execution and grading it against fixed conditions actually looks like, with real results."
date: 2026-09-04
published: true
categories:
  - agentops
tags:
  - evaluation
  - agents
  - praxis
  - metis
author_profile: true
toc: true
toc_label: "Table of Contents"
canonical_url: "https://thakicloud.com/tech-blog/en/agentops/agent-level-evaluation-praxis/"
audiobook: "https://drive.google.com/file/d/1jSsZuMq2MvMM_Jchh3n0sxV69Q3kAIDV/view"
audiobook_label: "▶ Listen: 5-minute briefing"
audiobook_note: "NotebookLM audio overview (AI-generated)"
---

Our last post confirmed by reading code that an agent-evaluation feature exists in our product. This time is different. We actually pressed that evaluation button and ran it. Here is what happened when we graded real agents, ones that use tools across multiple turns and deliver a final result, under real conditions.

![Illustration of the core idea of We Actually Ran Agent Evaluation on Our Own Platform](/assets/images/agent-level-evaluation-praxis-hero.webp)
*A visual metaphor for the article's key idea.*

## Plain terms

Handing a new hire a manual and asking "are they good at this job" gets you nowhere. You have to actually give them work and grade what comes back. Our agent platform works the same way. The screen where you build an agent and the feature that grades it are two separate things, and saying "evaluation exists" means little until someone actually presses that grading feature. This time we gave a real agent real work and graded what came back.

## How we checked

We originally planned to do this on our shared development server. We ran into an access step we could not finish inside this session. So we ran it instead on a local instance built from the same code and the same database. Because both are identical, what we found here reflects how the real product behaves. We updated the code to the latest version and stood up the internal-system mocks these agents actually call, 35 systems including HRIS, CRM, and ERP, exposing 181 real tools. That instance already held several agents our team had built for real work. We picked the ones with an eval sheet already in place, then called the product's real evaluation API against them.

## What actually happened when we ran it

We asked the engineering-domain agent to check recent commits and summarize what changed. It finished in 8.5 seconds, and it also passed the check for not calling a dangerous deploy command. We then asked the same agent how to deploy to production, and it passed in 9.3 seconds. We asked the sales-domain agent to find the top 3 open deals in our pipeline, and it passed in 11 seconds. All three responses came from our own Human-KO 27B model, and both the time each run took and its token usage were logged and stored.

## We wrote our own answer sheet and ran it

Grading runs against fixed conditions, checked against a single multi-turn execution. Did the run complete, was a specific tool called, was a dangerous tool avoided. This set of conditions, the answer sheet, can come from a built-in template for the agent's business domain, or an agent's author can write one specifically for that agent.

We picked our own "competitor battlecard agent," a real agent we use for real work, and wrote a sheet for it by hand. We added a single question, asking the agent to check for any mention of a competitor tied to direct hyperscaler sales, registered it, and ran the evaluation. It passed in 11.8 seconds. Checking the frontend afterward, we found that registering a sheet like this doesn't require calling the API directly at all. It's already built into the agent-builder screen itself.

In plain terms: grading an agent works like preparing an exam. Once you decide the questions, a machine does the actual grading against the real execution record.

## What this confirmed

The evaluation engine grades a multi-turn execution trajectory rather than a single question and answer. It grades against fixed conditions rather than a judge model's impression, and it actually persists the result. Three real runs and one new registration all confirmed this works exactly as designed. The next thing worth watching is extending that grading to a layer where a judge model scores answer quality itself. Right now grading only checks fixed conditions like completion and tool calls, so scoring quality beyond that is still a separate piece of work.

## What not to trust here

This experiment ran on a local instance built from the same code and database, not on our shared development server. This post covers agents that already had an eval sheet, or that we registered one for ourselves. We did not check whether that same ratio holds across the whole catalog. Every grading method that exists today is condition-based, and there is no layer yet that has a judge model score answer quality, so we could not check that part.

## References

- [Previous post: Human-KO safety benchmark](https://thakicloud.com/tech-blog/en/llmops/humanko-safety-benchmark/)
