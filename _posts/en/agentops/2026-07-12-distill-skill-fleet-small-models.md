---
title: "Distilling Our Own Skills Into Small Models to Run Them Automatically: The Last 6 Months"
excerpt: "Running agent skills exclusively on frontier APIs makes costs explode once you hit thousands of calls. Research from the first half of 2026 has pushed distilling those skills into 1B to 35B small models and running them locally automatically to a practical stage. This post surveys recent techniques like on-policy skill distillation, multi-teacher distillation, and training-free agent distillation, and explains why ThakiCloud's already-confirmed small-worker results (Gemma-4-26B tying Haiku) and our thin-harness, format-determinism architecture are well suited to this shift, along with where it breaks down."
seo_title: "Distilling Agent Skills Into Small Models for Automated Execution - Thaki Cloud"
seo_description: "A survey of first-half-2026 SLM agent and on-policy skill distillation research (Skill-SD, SOD, OPID, AgentDistill, multi-teacher MOPD), covering the hybrid architecture behind distilling the ThakiCloud skill fleet into small local models for automated execution, real measurements (Gemma-4-26B tied Haiku), pitfalls, and verification gates."
date: 2026-07-12
last_modified_at: 2026-07-12
lang: en
canonical_url: "https://thakicloud.github.io/en/agentops/distill-skill-fleet-small-models/"
tags:
  - agentops
  - distillation
  - small-language-models
  - on-policy-distillation
  - skill-fleet
  - cost-efficiency
  - platform-engineering
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "robot"
categories:
  - agentops
---

## Overview

Any team that has actually run agents in production hits the same wall. Running a single skill can mean dozens to hundreds of calls to a frontier model, and once a few dozen of these skills fire unattended every day, the bill screams first. The capability is there, but paying top-tier model rates on every single call is the problem.

So the direction becomes obvious. Take the skills a company has already validated and is already using, and distill them into a small model that knows only as much as the skill actually needs, then run it locally and automatically. What's interesting is that this direction is no longer theoretical. Over the six months of the first half of 2026, a wave of research has pushed "small model plus agent skill distillation" to a level you can actually deploy. This post surveys that trend and covers how ThakiCloud is actually moving its skill fleet to small models, as well as where it breaks.

The intended audience is clear: platform and MLOps engineers who run many agent skills and are weighing frontier API costs against automation in their design. If you're a different kind of reader, say someone who needs a management-level cost verdict, the last section alone gets you there.

![Hybrid architecture diagram showing the four-stage pipeline from validated skill fleet to per-skill teacher to on-policy distillation to small local worker, alongside hybrid routing that keeps the conductor and downgrades only the worker, plus retro-driven escalation](/assets/images/distill-skill-fleet-small-models-diagram-en.svg)

## Why Now: Small Models Have Become the Default for Agents

First, let's align on terms. As of 2026, a small language model (SLM) refers to a model in roughly the 1B to 35B range that runs on a single GPU, a workstation, or sometimes on-device, while still getting the assigned job done. The key isn't size itself, it's whether the model is sufficient for the task.

The case for small models in agent workflows rests on three things: cost, latency, and modularity. A multi-agent setup built from five specialized small models is cheaper, faster, and easier to debug than sending a single prompt to a frontier model. That's exactly the point NVIDIA researchers made in their argument that small language models are the future of agentic AI. The capability threshold for agent tasks has dropped low enough that work which needed a frontier API a year ago can now be handled by a model you run yourself.

The cost gap isn't trivial either. The calculation keeps coming back that running a small model costs anywhere from one-tenth to one-thirtieth of the top-tier model in the same family. In agent systems that call a model thousands of times for a single complex task, moving even part of that traffic to small models cuts operating costs by an order of magnitude. For operations that fire skills unattended at scale, that saving shows up directly on the bottom line.

## What's Happened in the Last 6 Months: How to Move Skills to Small Models

Over the past two quarters, the center of gravity moved from plain knowledge distillation to agent skill distillation, and then to on-policy distillation. The approach that has taken hold has the student model generate its own trajectories, with the teacher scoring them token by token. Here's how the major threads break down.

| Approach | One-line summary | Where it excels |
|---|---|---|
| Multi-teacher on-policy distillation (MOPD) | Set up domain-specific RL expert teachers, and as the student generates its own rollouts, each teacher scores every token | Consolidating multiple skills into one small student |
| Skill-conditioned self-distillation (Skill-SD) | The same model acts as both teacher and student, refining multi-turn trajectories conditioned on the skill | Multi-turn agents, no separate teacher needed |
| Step-wise on-policy distillation (SOD) | Injects dense supervision signal step by step rather than over the whole trajectory | Stabilizing small agents with long chains of tool calls |
| On-policy skill distillation (OPID) | Compensates for the sparse reward of agentic reinforcement learning with dense teacher signal | Agent tasks where rewards are sparse |
| Training-free agent distillation (AgentDistill) | Transfers reusable toolboxes (MCP boxes) to hand off capability without retraining | Fast handoff, avoiding training cost |

A few threads land directly on real-world practice. First, the approach frontier labs have converged on is to build separate reinforcement-learning expert teachers per domain (one for math, one for code, one for agents), then have all of them score the student's own generated output during on-policy distillation and merge it into a single student. A good teacher doesn't have to be a bigger model. A checkpoint that's the same base and same size as the student, but pushed deep into a single domain, can actually make a better teacher. Specialization creates the teacher, not scale.

Second, evidence has piled up that distilling tool-using small agents actually works. When a large agent equipped with search and code tools gets distilled into a small model, that small model has been reported to outperform models a full size class larger, particularly on tasks outside its training distribution. That means agent distillation is a practical route to producing a "capable small model that can use tools."

## Why Our Skill Architecture Suits This Shift

This is where ThakiCloud's structure becomes relevant. We've long followed the principle of putting capability into the skill rather than the harness. Thin harness, fat skills. We keep the loop and permissions that wrap the model minimal, while packing domain knowledge, judgment, templates, and failure cases densely into the skill itself. That means the same skill is designed to keep working no matter which model you swap in underneath it.

Format determinism layers on top of that. In batch skills that run on a schedule, we don't have the model generate the format, only the content. Numbers, enum values, rendering, and aggregation are all owned by deterministic code. Combine these two principles and something interesting happens. Even if you demote the worker model from frontier down to a local small model, the output doesn't wobble, because the format and validation that govern quality are baked into code. The small model only has to produce the content, and the harness guarantees the rest.

This isn't speculation, it's a measured result. In June 2026 we set up a local small model (Gemma-4-26B) as a skill worker and ran a live A/B test against the Claude family. The result: Gemma tied Haiku 18 to 18 on worker compliance. The one wall we ran into was a context ceiling of roughly 10,000 tokens, past which requests started failing. So we settled on hybrid routing. A frontier conductor handles heavy reasoning and orchestration, while a local small model handles standardized worker tasks. The direction of distilling skills into small models for automated execution has already been partially validated in our own environment. Running speech synthesis (VoxCPM2) and speech recognition (Qwen-ASR) workers locally already fits the same pattern.

## Where It Breaks: Not Romanticizing Distillation

Being on the right path doesn't make the pitfalls disappear. Let's lay out the counterarguments first.

The most practical wall is divergence over chains of tool calls. Reasoning that interleaves tool use becomes less stable the longer it runs on a small model. On-policy distillation eases this with dense supervision, but a single wrong tool call can propagate into later reasoning steps, widening the gap between the student's trajectory and the teacher's. That's exactly why step-wise distillation (SOD) supervises step by step instead of over the whole trajectory, to catch this divergence early. Hand a long agent task to a small model as-is and it collapses partway through.

The second wall is signal conflict among multiple teachers. When teachers disagree on alignment, format, or values, the student either gets averaged into mush or actually loses quality from the conflicting signal. That's why about half of recent research is focused on purification, filtering out the bad teacher signal. The lever isn't attaching more teachers, it's the gate that decides which teacher to trust on which token. This lines up exactly with a principle we already follow: fan-out must always close through a verification stage. Gather multiple results, but only use what survives adversarial verification before merging.

The third point cuts deeper. Distillation produces a follower trapped under the teacher's ceiling. It inherits the teacher's blind spots along with its knowledge, and it can't get ahead on its own. So distillation shouldn't be positioned as a replacement for frontier orchestration, it should be positioned as a deployment-layer strategy for running already-validated skills cheaply and at scale. That's why keeping the conductor and demoting only the worker is the honest conclusion in a hybrid setup.

## The ThakiCloud Execution Roadmap

We've laid out a three-step path. First, stand up a specialized teacher per skill. The first candidates are standardized skills that fire at high volume, news digests, Twitter summaries, report renderers, skills where format determinism already lives in code. These already have their format owned by code, so the small student only has to get the content right. Second, distill small students on-policy from those teachers and run them locally and automatically. Knowing where the context ceiling sits, we keep any skill that needs long context on the conductor and only demote short, repetitive workers. Third, protect quality with retrospective-driven escalation. We're already running an automatic promotion loop that starts with a small model, and if a particular skill fails repeatedly, rolls that skill alone back up to a higher-tier model. Start cheap, and let the data catch failures, then promote only that skill.

This roadmap delivers three benefits. Cost drops by an order of magnitude for high-volume unattended execution, latency shrinks with local execution, and on the sovereignty side, dependence on external APIs and data movement both decrease. For us, running a Kubernetes-based AI/ML platform, these three things aren't marketing copy, they're daily operating metrics.

## Closing

The direction of "distill skills into small models and run them automatically these days" is correct. But the specifics matter. Setting up domain expert teachers, consolidating them into a small student on-policy, attaching a verification gate that filters bad teacher signal, and supervising step by step for tasks with long chains of tool calls, that's close to the current standard. ThakiCloud starts from an advantageous position in this shift thanks to its existing thin-harness and format-determinism structure, and the measured result of a Gemma worker tying Haiku backs that starting position with data. Keeping the frontier as conductor and demoting validated skills to small workers is the most realistic path to protecting both cost and quality at the same time.

## References

- Small Language Models are the Future of Agentic AI (arXiv 2506.02153): [https://arxiv.org/pdf/2506.02153](https://arxiv.org/pdf/2506.02153)
- Skill-SD: Skill-Conditioned Self-Distillation for Multi-turn LLM Agents (arXiv 2604.10674): [https://arxiv.org/pdf/2604.10674](https://arxiv.org/pdf/2604.10674)
- SOD: Step-wise On-policy Distillation for Small Language Model Agents (arXiv 2605.07725): [https://arxiv.org/pdf/2605.07725](https://arxiv.org/pdf/2605.07725)
- OPID: On-Policy Skill Distillation for Agentic Reinforcement Learning (arXiv 2606.26790): [https://arxiv.org/pdf/2606.26790](https://arxiv.org/pdf/2606.26790)
- AgentDistill: Training-Free Agent Distillation with Generalizable MCP Boxes (arXiv 2506.14728): [https://arxiv.org/pdf/2506.14728](https://arxiv.org/pdf/2506.14728)
- Distilling LLM Agent into Small Models with Retrieval and Code Tools (arXiv 2505.17612): [https://arxiv.org/pdf/2505.17612](https://arxiv.org/pdf/2505.17612)
- Distillation in 2026 (so far): which frontier models use it and how (Hugging Face): [https://huggingface.co/blog/sergiopaniego/distillation-2026](https://huggingface.co/blog/sergiopaniego/distillation-2026)
- How Small Language Models Are Key to Scalable Agentic AI (NVIDIA Technical Blog): [https://developer.nvidia.com/blog/how-small-language-models-are-key-to-scalable-agentic-ai/](https://developer.nvidia.com/blog/how-small-language-models-are-key-to-scalable-agentic-ai/)
