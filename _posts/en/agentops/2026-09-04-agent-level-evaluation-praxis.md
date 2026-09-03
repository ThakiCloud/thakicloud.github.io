---
title: "A Model Exam and an Agent Exam Are Different Tests — We Found the Answer Already Sitting in a Drawer"
excerpt: "The test sheet for grading a model and the one for grading an agent are different papers. Metis Benchmarks only grades the first one. We opened the code to find where the second answer sheet already lives."
seo_title: "How Far Along Is Agent-Level Evaluation? A Code-Level Look at Praxis agenteval"
seo_description: "After confirming Metis Benchmarks only evaluates model endpoints, we opened the agenteval module inside our agent platform Praxis to see what agent-level evaluation actually looks like in our own stack."
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
---

A few days ago we wrote about [measuring Human-KO's safety](https://thakicloud.com/tech-blog/en/llmops/humanko-safety-benchmark/). While doing that work, a different question came up alongside it: "Does this benchmark cover models only, or agents too?" Short answer: in our product UI, only models. But a tool for evaluating agents already existed in-house. It was just sitting in a different drawer.

## Plain terms

Hiring a cook usually involves two kinds of exam. A written test asks about ingredient properties and recipe knowledge. A practical test puts the candidate in a real kitchen and checks whether they handle a knife properly, control heat, and actually produce a finished dish. Both matter, but they're completely different test sheets — no amount of polishing the written exam will grade practical skill. A language-model benchmark is the written exam: one question, one graded answer. Agent evaluation is the practical exam: multiple steps, tool use, and whether a final result actually comes out the other end. Our company has both a written-exam sheet (Metis Benchmarks) and a practical-exam sheet (Praxis's agenteval). They were just filed in separate drawers, so one side didn't know the other existed.

## How we investigated

Instead of answering "does it exist" from memory, we read the actual code. That means the `agenteval` module's source inside our agent platform Praxis, the API router that calls it, and the database migrations backing it. It also means evidence that it has actually run in practice, such as logs and bug-fix commit messages. "Exists" and "actually runs" are different claims, so we only cite evidence for the latter.

## What we found — real, running, and it already caught a bug

Three findings.

First, `agenteval` doesn't grade a single question-answer pair — it evaluates a **multi-turn execution trajectory**. It records which tools an agent called, how many times, whether each call succeeded or failed, which skill was chosen, and whether a final artifact was actually delivered. Grading isn't a judge model's impression either. It runs on **nine deterministic conditions**: was a tool called, was a specific skill chosen, was an artifact actually delivered, did cost stay under budget, and so on.

Second, this isn't scaffolding — it's code that has actually run. Calling `POST /api/v1/agent-specs/{id}/eval` over REST executes it, and results persist in Postgres. There's even a real bug fix documented in the code comments. In one run, the team identifier was passed as an empty string. Every single tool call was denied as a result, and this exact evaluation tool is what caught it.

Third, and yet it is **not connected** to Metis Benchmarks. Across the entire repository, code referencing `agenteval` exists only inside Praxis; the name never appears anywhere in Metis Benchmarks' code. The two exam sheets aren't even in the same filing cabinet.

In plain terms: the practical-exam proctor already works here. The written-exam front desk just didn't have their phone number.

## What it would take to merge the two

Bringing the two drawers together needs three things. First, Metis Benchmarks needs to be able to target a Praxis agent spec, not just a model endpoint. Second, it needs a path that ingests a multi-turn execution trajectory rather than a single completed answer. Since `agenteval` already owns that grading logic, calling into it beats reimplementing it. Third, `agenteval`'s grading today is entirely condition-based (was a tool called, was an artifact produced) — there's no layer that has a judge model score answer *quality*. Metis Benchmarks doesn't have that layer either, so whichever side builds it first, it's homework both systems still need to do.

## What not to trust here

This investigation was done by reading code, not by running `agenteval` and producing a fresh result ourselves. We confirmed what the code is built to do, but did not separately verify how often it's invoked in production today or how many runs it has executed recently. And "no quality-judging layer" means we didn't find one in the code we read — it doesn't fully rule out something equivalent existing elsewhere that we didn't check.

## References

- [Human-KO safety benchmark article](https://thakicloud.com/tech-blog/en/llmops/humanko-safety-benchmark/)
