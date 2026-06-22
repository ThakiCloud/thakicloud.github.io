---
title: "One Skill Is Not Enough: Compositional Skill Routing and the Decomposition Bottleneck Revealed by SkillWeaver"
excerpt: "A composite user request is not the problem of picking one skill but of composing several. SkillWeaver (arXiv:2606.18051) formalizes this problem and shows, with data, that the real bottleneck is not the retriever but decomposition."
seo_title: "SkillWeaver Compositional Skill Routing Paper Analysis - Thaki Cloud"
seo_description: "arXiv 2606.18051: Decompose-Retrieve-Compose composite skill routing, the decomposition bottleneck and SAD methodology, multi-agent evaluation design from a practitioner perspective"
date: 2026-06-21
last_modified_at: 2026-06-21
lang: en
categories:
  - research
tags:
  - skill-routing
  - llm-agent
  - multi-agent
  - mcp
  - arxiv-2606.18051
  - evaluation
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/en/research/skillweaver-compositional-skill-routing/"
reading_time: true
---

The pattern of LLM agents relying on external skills (reusable tool specifications) is now ubiquitous. Yet real-world work is not the problem of "picking" one skill but of "composing" several. A composite request such as "run deep research, fact-check it, turn it into a docx report, and post it to Slack" cannot be solved by a single skill search. The paper SkillWeaver (arXiv:2606.18051, "Compositional Skill Routing for LLM Agents: Decompose, Retrieve, and Compose"), released on arXiv on June 16, 2026, formally defines this problem and, more importantly, pinpoints **where the real bottleneck lies** with data.

At ThakiCloud, we operate a K8s-based AI/ML SaaS platform and have dealt directly with the routing quality of multi-agent workflows, so we see this paper's conclusion landing precisely on our own practice.

> 📄 **Full in-depth review (DOCX)**: You can [download the detailed peer review of this paper from Google Drive](https://drive.google.com/file/d/1xKcquYDJ534VquYHdJL93tvrmIdq3qVl/view).

## Problem Definition: Compositional Skill Routing

The paper formalizes composite skill routing in three stages.

1. **Decompose**: break a composite user query into atomic subtasks.
2. **Retrieve**: search for the skill that fits each subtask.
3. **Compose**: assemble an executable plan that accounts for dependencies.

The SkillWeaver framework implements these three stages as, respectively, an LLM task decomposer, a FAISS-indexed bi-encoder skill retriever, and a dependency-aware DAG planner. For evaluation, the authors also propose a benchmark composed of composite queries built on top of real MCP server skills collected from the public MCP ecosystem.

![SkillWeaver compositional skill routing pipeline](/assets/images/skillweaver-compositional-skill-routing-diagram.svg)

## The Key Finding: The Bottleneck Is Not the Retriever but "Decomposition"

The single most important line a data scientist should take from this paper is this: standard LLM decomposition produces low category recall at the step level.

In other words, no matter how good you make the retriever, **if decomposition drops more than half of the subtasks**, every downstream stage collapses. The intuitive move is to go "let's retrieve better," but the measurement says the opposite. The place to fix is decomposition.

To address this, the authors propose a retrieval-augmented loop that takes the retrieval results as feedback and iteratively aligns decomposition to the vocabulary of the skill library. It is an approach that makes decomposition converge toward "a form executable with the skills I actually have."

## Practical Value from a Data Scientist's Perspective

There are three reasons this paper is useful as a methodology rather than a mere demo.

- **A lesson in evaluation design**: evaluating a system with a single line of aggregate accuracy hides the bottleneck. You have to look at **stage-decomposed metrics** like step-level category recall to see where the loss occurs. This is a principle that applies directly when evaluating agent pipelines in MLOps.
- **Retriever vs decomposer diagnosis**: when multi-agent system quality falls short, the paper gives empirical grounds to measure the recall of the decomposition stage before upgrading your model tier. The message is: measure before you spend.
- **A reproducible benchmark**: because it runs on top of real MCP skills, it reflects the ecosystem's actual distribution rather than synthetic tasks.

## ThakiCloud Has Already Validated This Finding

We borrowed SkillWeaver's problem formulation and evaluation framework and directly measured single retrieval vs decomposition-based routing on top of our internal skill corpus. The result pointed in the same direction as the paper. Even with perfect decomposition there was a ceiling, and the bottleneck lay in both decomposition **and** retriever/description quality. In other words, the paper's conclusion that "retrieval is fine, just fix decomposition" does not transfer wholesale to every environment. Our practical lesson is that you must measure directly in each environment.

Operating this kind of measurement infrastructure and routing gate reproducibly on top of K8s is exactly the territory ThakiCloud works in. For an engineer who wants to treat agent routing quality as a data problem, this is a place where such problems are the daily work.

## Closing

SkillWeaver's message is clear. To raise routing quality on composite tasks, before scaling up the model you should **fix decomposition and measure stage by stage**. The paper's true lesson, measure before you fix, applies directly to every team operating multi-agent systems.

---

Source: "Compositional Skill Routing for LLM Agents: Decompose, Retrieve, and Compose", arXiv:2606.18051 (2026-06-16). https://arxiv.org/abs/2606.18051

📄 **Full in-depth review (DOCX)**: You can [download the detailed peer review of this paper from Google Drive](https://drive.google.com/file/d/1xKcquYDJ534VquYHdJL93tvrmIdq3qVl/view).
