---
title: "Engineering Fundamentals in the AI Era"
excerpt: "Even as code generation gets easier, engineering that owns design, testing, reproducibility, operations, and cost remains essential."
date: 2026-11-26
last_modified_at: 2026-11-26
tags:
  - ThakiCloud
  - AInative
  - Engineering
  - DevCulture
  - Quality
author_profile: true
toc: true
toc_label: Table of Contents
canonical_url: "https://thakicloud.com/tech-blog/en/culture/engineering-fundamentals/"
categories:
  - culture
---

![Abstract image of light beams flowing through a frame of interlocking gears]({{ '/assets/images/engineering-fundamentals-hero.webp' | relative_url }})

*AI-Native Culture 05*

## What Does It Mean That Code Is Produced Quickly?

AI can explore unfamiliar libraries, write implementation drafts, and generate candidate test cases. But code being generated is not the same as a problem being solved. If the requirement is misdefined, more code can make the problem worse.

The essence of engineering is not producing code; it is building trustworthy systems under constraints. AI changes the cost of implementation, but it does not remove responsibility for the system's correctness, security, performance, and maintainability.

## Productivity Is a Measurement Problem, Not a Feeling

Google's 2025 DORA report explains that the effect of adopting AI connects to the organization's existing capabilities.[1] The implication is that a solid development foundation and clear work flow matter.

In a randomized experiment analyzing 246 tasks performed by 16 experienced open source developers, METR reported that AI use increased task time by 19% in early 2025.[2] Developers felt they had gotten faster, but the measurement said otherwise. A February 2026 follow-up acknowledged the possibility of improved tools while stating that participant selection bias and time measurement problems make the effect size hard to estimate reliably.[3]

None of this supports the claim that AI development tools are always slower. Nor does a demo of fast code generation prove that real development productivity has improved.

## Contracts Before Implementation

Suppose you build a feature on a multi-tenant platform that queries API usage per project. Returning the correct response to normal requests is not enough. You must verify that data from other projects cannot be queried, that permission changes take effect immediately, and that a malformed identifier does not leak information.

Even if AI writes both the implementation and the tests, the same wrong assumption can be reflected in both. That is why independent requirements, negative tests, and real execution results are needed.

| Area | Evidence to check |
|---|---|
| Design | Requirements, alternatives, failure conditions |
| Implementation | Change scope, dependencies, code review |
| Validation | Independent tests, edge inputs, regression results |
| Operations | Observability metrics, rollback, incident response |
| Cost | Throughput, latency, computing and maintenance cost |

OpenAI's official engineering interview guide also treats design, code quality, performance, and test scope as important.[4] That connects to the point that code generation ability alone does not describe an engineer's capability.

## The Same Principles Apply to Research

When developing a new AI model or algorithm, define the comparison baseline, data separation, evaluation metrics, and judgment conditions before the experiment. Record results even when they do not match expectations, and separate errors in the evaluation tool from the model's actual failures. Check whether a small performance gap holds across repeated runs, and measure whether cost reduction reproduces in a real serving environment.

## Where Is the Value of an Engineer?

The more AI helps with implementation, the more important it becomes to define problems, judge the validity of a design, and verify results. The ability to write code directly remains the foundation of debugging and judgment. We do not set tools against fundamentals.

A good engineering culture respects the person who builds a good system more than the person who writes a lot of code. AI is a tool for reaching that goal, and the responsibility for the final outcome still belongs to us.

## References

1. [Google DORA, State of AI-assisted Software Development (2025)](https://dora.dev/research/2025/dora-report/)
2. [Becker et al., Measuring the Impact of Early-2025 AI on Experienced Open-Source Developer Productivity (2025)](https://arxiv.org/abs/2507.09089)
3. [METR, We are Changing our Developer Productivity Experiment Design (2026-02-24)](https://metr.substack.com/p/2026-02-24-uplift-update)
4. [OpenAI, Interview Guide](https://openai.com/interview-guide/)

## AI-Native Culture Series

1. [Beyond AI-Free Interviews](/tech-blog/en/culture/ai-native-organization-taking-vs-giving/)
2. [Leadership in the Age of AI](/tech-blog/en/culture/leadership-in-ai-era/)
3. [From Individual Knowledge to Organizational Intelligence](/tech-blog/en/culture/organizational-intelligence/)
4. [Why We Work with AI Agents](/tech-blog/en/culture/working-with-agents/)
5. [Engineering Fundamentals in the AI Era](/tech-blog/en/culture/engineering-fundamentals/)
6. [Accountability for AI-Generated Outcomes](/tech-blog/en/culture/accountability-for-ai/)
7. [Growing Junior Talent in the AI Era](/tech-blog/en/culture/growing-junior-talent/)
8. [AI Adoption vs. an AI-Native Organization](/tech-blog/en/culture/ai-native-organization/)
