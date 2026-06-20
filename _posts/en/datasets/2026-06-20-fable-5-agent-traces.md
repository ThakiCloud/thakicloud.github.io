---
title: "Fable-5-traces: How to Distill Small Models Using Coding Agent Session Traces"
excerpt: "Glint-Research released 4,665 Fable 5 (Claude Code) agent traces in AGPL-3.0 under the HF Agent Traces format, with 81% tool-use composition. A practical guide to distilling small models and building self-hosted coding agents."
date: 2026-06-20
categories:
  - datasets
tags:
  - agent-traces
  - fable-5
  - claude-code
  - distillation
  - sft
  - tool-use
  - chain-of-thought
  - coding-agent
  - agpl-3.0
lang: en
author_profile: true
toc: true
toc_label: "Fable-5-traces Guide"
reading_time: true
canonical_url: "https://thakicloud.github.io/en/datasets/fable-5-agent-traces/"
---

⏱️ **Estimated reading time**: 8 min

![Fable 5 agent trace overview](/assets/images/fable-5-agent-traces-hero.png)

## Dataset Overview

**Fable-5-traces** is a collection of coding agent session traces released by Glint-Research. The dataset captures the reasoning, tool calls, and text outputs that Fable 5 (Claude Code) produced while performing real coding tasks, converted and published in the Hugging Face Agent Traces format.

Raw trace data showing what an agent thought, which tool it chose and why, and how it handled the result is the core ingredient for training small language models as policy models. This dataset is designed precisely for that purpose.

## Structure and Schema

### Scale

- 4,665 merged training examples in total
- 4,665 original Pi-style trace files
- 60 unique source sessions
- Total size: 188 MB

### Two Data Views

The dataset provides two simultaneous representations.

**Pi-style trace view** (`pi-traces/*.jsonl`): Raw trace files containing session events, model changes, thinking-level metadata, user context, and assistant reasoning together with tool outputs. Used to replay the exact order in which the agent reasoned.

**Merged JSONL view** (`fable5_cot_merged.jsonl`): All traces converted to flat records. Key fields are as follows.

| Field | Description |
|------|------|
| `uid` | Unique identifier |
| `source_file` | Original Pi trace filename |
| `context` | Task context (average approximately 6,600 characters) |
| `cot` | Agent reasoning chain (median approximately 2,365 characters) |
| `output_type` | `tool_use` or `text` |
| `output` | Actual tool call or text output |
| `completion` | Full completion (average approximately 3,700 characters) |
| `model` | Model used for the call |
| `origin` | Trace source |

### Tool Distribution

Of the 4,665 records, 3,799 (81.44%) are tool-use records and 866 (18.56%) are text output records. Tool types include Bash, Edit, Read, Write, PowerShell, and WebSearch, covering the categories that real coding agents use.

This ratio reflects the reality of coding agents. Most of the output a language model generates during coding work is tool calls, not text.

### Tags

Dataset tags: `agent-traces`, `pi-agent`, `claude-code`, `fable-5`, `chain-of-thought`, `tool-use`

## License

The license is AGPL-3.0, a copyleft license with source disclosure obligations. If a model trained on this dataset is distributed as a service, the full source code of that service must be released under AGPL-3.0 terms. There are no restrictions for internal research use or self-hosted private services.

For teams planning public-facing deployment in an enterprise context, a license review is required first. In the ThakiCloud operational environment, where the goal is internal tooling or research, AGPL-3.0 does not act as a practical constraint.

## Applications in Training and Evaluation

### Distillation

The core use case for this dataset is transferring the behavior of a large agent model into a small model. The procedure is as follows.

First, construct SFT data from the `context`, `cot`, and `output` fields of `fable5_cot_merged.jsonl`. The agent's reasoning process and tool call in a given context are converted into (input, reasoning, output) triples.

SFT-training a small code model such as Qwen 2.5 Coder 7B or DeepSeek Coder 6.7B on these triples can partially reproduce Fable 5-level tool-use behavior.

### Tool-Call Policy Modeling

The 3,799 tool-use records are also well-suited for training a tool selection policy model. Patterns showing when the agent uses Bash versus Read, and which it chooses between Edit and Write, are distributed across 60 sessions.

### Trace Visualization

The Pi-style trace view can also be used for agent session replay. It is possible to build a tool that lets humans review why the agent stalled at a particular step and the order in which it read and edited files.

## ThakiCloud Use Cases

In the context of ThakiCloud's K8s AI platform, the two most direct applications for this dataset are as follows.

**On-premises coding agent training**: In environments where external API agents cannot be used due to security requirements such as those set by the Korean National Intelligence Service, fine-tuning Qwen-series 7B to 14B models on Fable-5-traces can produce self-hosted coding agents. AGPL-3.0 source disclosure obligations do not apply to internal services, so there is no license issue.

**AI agent tool policy validation**: The tool call patterns of internally developed agents can be compared against the Fable 5 baseline. The tool selection distribution of the 3,799 tool-use records serves as a reference point for quantifying the tool usage patterns of internal agents.

Connecting this dataset directly to a Kueue-based training workflow allows Fable-5-traces SFT experiments to be managed as K8s batch jobs. At 188 MB, the dataset is well within the capacity a single A10G GPU node can handle.

## Summary

Fable-5-traces is a compact but dense dataset of real coding agent behavior. 4,665 records are not large in absolute terms, but they are high-quality trace data spanning full sessions from reasoning through tool calls, covering 60 unique sessions. Subject to verifying the AGPL-3.0 license conditions, this is a workable starting point for small model distillation experiments.

HuggingFace: [Glint-Research/Fable-5-traces](https://huggingface.co/datasets/Glint-Research/Fable-5-traces)
