---
title: "Why We Taught Claude Code Ourselves: ThakiCloud Internal Seminar Materials Now Public"
excerpt: "From environment setup to easy-to-miss features. Here is how the ThakiCloud engineering team internalized Claude Code, along with the complete seminar materials."
seo_title: "ThakiCloud Claude Code Internal Seminar Materials - Developer Productivity Internalization"
seo_description: "ThakiCloud's engineering team shares the Claude Code internal seminar materials. Slides and recorded video covering environment setup, key commands, mastering workflows, and easy-to-miss features."
date: 2026-06-20
last_modified_at: 2026-06-20
categories:
  - news
tags:
  - claude-code
  - seminar
  - developer-productivity
  - thakicloud
  - ai-tooling
  - internal-training
  - agentic-coding
lang: en
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/en/news/claude-code-seminar-thakicloud/"
reading_time: true
---

⏱️ **Estimated reading time**: 6 min

![Claude Code Seminar](/assets/images/claude-code-seminar-hero.png)

Many teams adopt AI coding tools. Far fewer teams use those tools well across the whole team. ThakiCloud did not stop at installing Claude Code. We ran an internal seminar to refine everything from environment setup to practical usage patterns, and today we are sharing those materials publicly.

## Why We Created an Internal Seminar

Claude Code is an AI coding agent that runs in the terminal. It reads code, edits files, runs tests, and handles git commits. The capabilities are powerful, but for a developer encountering it for the first time, there is a learning curve. Things like which config file lives where, which slash commands are actually useful, and when to reach for sub-agents are not obvious from reading the official documentation alone.

The ThakiCloud engineering team started using Claude Code as a primary tool while operating a K8s-based AI SaaS platform. A natural momentum built around learning together and using it together, and that led to the seminar.

We had two goals. One was to get every team member starting from the same baseline. The other was to collect each person's discovered tips and raise productivity for the whole team.

## What the Seminar Covered

### 1. Environment Setup (Claude-Code-환경설정&명령어)

The first thing we covered was configuration. Claude Code stores its config files under `~/.claude/`, and not understanding this structure leads to repeating the same setup across projects or running into conflicts.

We started with the role of `CLAUDE.md`. This file is the core document that tells the agent about project context. What stack is in use, what rules to follow, what commands are available: put this all here and you never have to explain it again. At ThakiCloud we use this file to manage our Go + React 19 stack, commit conventions, and frequently used make commands.

MCP server configuration was another important topic. We covered hands-on what tokens are needed and where they go when connecting to external services like Slack, GitHub, Google Calendar, and HuggingFace, and where to check when configuration errors occur.

Slash commands were also part of this session. We went from basic commands like `/review`, `/debug`, and `/compact` through to creating project-specific commands in `.claude/commands/`.

### 2. Mastering Claude Code (Claude-Code-마스터하기)

After environment setup, the next step was how to use it well.

One core topic was context management. The longer an agent session runs, the more the context window fills and quality drops. We covered the habit of keeping usage below 40%, the right timing for `/compact`, and how to carry state across sessions.

Multi-agent patterns were also important. Distributing complex tasks across multiple sub-agents is not simply a matter of running several things at once. The core question is which model tier to use for which task (haiku for exploration, sonnet for implementation, opus for architecture decisions) and how to balance cost against quality.

We covered Plan Mode too. Entered with two Shift+Tab presses, this mode forces the agent to plan before touching any code. It is a required step before irreversible changes like database migrations or API contract updates.

### 3. Easy-to-Miss Features (Claude-Code-놓치기쉬운기능)

The final session gathered features that are easy to overlook when actually working.

Hooks are the clearest example. When the agent stops, or before and after specific tools run, scripts can execute automatically. At ThakiCloud we use this to automate things like KB (knowledge base) compilation and the skill router gate.

Keyboard shortcuts also make a meaningful speed difference once you know them. Things like Esc-Esc for `/rewind` to undo the last turn, and `Ctrl+R` to recall previous conversation content.

This session also covered how to use the `ultrathink` keyword to enable extended thinking at maximum, and how to keep the system prompt stable so prompt caching does not break.

We introduced tools that work especially well alongside Claude Code, including RTK, a CLI that compresses terminal output by 60 to 90 percent using the `rtk` prefix.

## Seminar Materials Download

The materials below are freely available for reference within your team.

| Material | Format | Link |
|------|------|------|
| Mastering Claude Code | PPTX | [Open slides](https://drive.google.com/file/d/1U-wkk1dy-HZL7Ub4vwvLtb78RRdI_LF3/view) |
| Claude Code Seminar Full Pack | PDF | [Open PDF](https://drive.google.com/file/d/1ZmedC8GkU2oJKsex2n45q12Owehx10yk/view) |
| Easy-to-Miss Features (recording) | MP4 | [Watch video](https://drive.google.com/file/d/1-sDTY8r0w-yUWDd-Ow1QSQmvibaeLKEc/view) |

> The environment setup recording is currently being re-uploaded. It will be added to this post when ready.

## Why We See AI Tool Internalization as a Hiring Signal

ThakiCloud is not a team that merely "adopted" an AI coding tool. We teach it ourselves, build our own skills, and weave it into the workflow of the whole team.

As of this writing, the `~/.claude/skills/` directory at ThakiCloud contains hundreds of skills. Code review, infrastructure deployment, marketing content generation, patent drafting, stock analysis: these are skills that automate actual work processes. They run on top of Claude Code, and the seminar means every team member understands this system and can contribute to it.

For a developer joining ThakiCloud, that means more than just having access to AI tools. It means working alongside a team that understands how those tools are put together, and a team that keeps experimenting to use them better.

We hope these materials are useful for other teams too. Questions and feedback are always welcome.
