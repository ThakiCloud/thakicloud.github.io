---
title: "Agents Last Exam: Why Computer-Use Agent Evaluation Has Evolved to 153 Long-Horizon Tasks"
excerpt: "agents-last-exam is a benchmark dataset of 153 long-horizon tasks for evaluating computer-use agents. Five domains including Business, Computing, Engineering, and Legal. CC-BY-4.0 license. A guide to building your own model benchmarking pipeline."
date: 2026-06-20
categories:
  - datasets
tags:
  - benchmark
  - computer-use
  - agent-evaluation
  - long-horizon
  - multi-step
  - cc-by-4.0
  - coding-agent
  - enterprise-software
lang: en
author_profile: true
toc: true
toc_label: "Agents Last Exam Guide"
reading_time: true
canonical_url: "https://thakicloud.github.io/en/datasets/agents-last-exam-benchmark/"
---

⏱️ **Estimated reading time**: 8 min

![Agents Last Exam agent evaluation overview](/assets/images/agents-last-exam-benchmark-hero.png)

## Dataset Overview

**agents-last-exam** is a benchmark dataset for evaluating computer-use agents on long-horizon tasks. It contains 153 tasks spanning multiple professional domains including Business, Computing, Mathematics, Engineering, and Legal, measuring whether agents can carry out real-world work workflows.

Where most existing benchmarks focus on single-turn question answering or simple code completion, this dataset is distinct in measuring "task completion" ability: agents use multiple tools in sequence, save intermediate outputs to files, and submit a final deliverable.

## Structure and Schema

### Scale

- 153 tasks total (v1.0 single split)
- `task_prompt` length per task: 502 to 5,840 characters
- `agent_must_do` required actions per task: 0 to 9
- Attached input files per task: 0 to 14

### Domain Distribution

| Domain | Estimated task count |
|--------|--------------|
| Computing and Mathematics | approximately 70 |
| Business and Finance | approximately 60 |
| Education and Information | approximately 10 |
| Engineering | approximately 10 |
| Legal | approximately 3 |

### Schema

Each record consists of the following fields.

| Field | Description |
|------|------|
| `task_id` | Task identifier |
| `title` | Task title |
| `summary` | Task summary |
| `category` | Top-level domain |
| `subdomain` | Specific subfield |
| `task_prompt` | Actual instructions given to the agent |
| `agent_must_do` | List of required actions verified by the evaluator |
| `software` | Software/tools to be used |
| `input_files` | List of input files needed to complete the task |
| `taxonomy` | Domain/subdomain metadata |
| `source_repo_path` | Verifiable source path |

### File Format

Parquet (auto-converted from source). Language is English.

### Example Task Types

- Accounting and finance: tax form processing, financial statement parsing, stock research
- Supply chain: Odoo ERP workflow automation
- Quantitative finance: option pricing, factor model replication
- Cybersecurity: malware analysis, packet forensics
- Infrastructure: Kubernetes optimization, AWS cost reduction
- Data engineering: ETL pipelines, recommendation systems

## License

The license is CC-BY-4.0. Attribution is required, but the dataset may be freely used, modified, and redistributed including for commercial purposes. This places it among the most permissive license categories for benchmark datasets.

## The Evolution of Agent Evaluation Standards

Understanding why this dataset receives attention requires a look at how agent evaluation standards have changed.

Early LLM benchmarks such as MMLU and HellaSwag measured accuracy on multiple-choice questions. As models scaled and those benchmarks saturated, evaluation shifted to code generation benchmarks such as HumanEval and MBPP. With the agent era came benchmarks such as SWE-Bench, where agents resolve actual GitHub issues in code.

agents-last-exam is a further step along that path. It measures whether an agent can complete not just code writing but an entire workflow: opening a browser, retrieving data from an ERP system, editing a spreadsheet, and submitting a report file.

### Evaluation Methodology

Evaluation is based on a deterministic output contract. When an agent submits a JSON, XLSX, code file, or report in the specified format, the contents are verified against domain-specific criteria:

- Financial accuracy: does the computed result match the reference value?
- Security rigor: does the malware analysis reach the correct conclusion?
- Data schema compliance: does the ETL output follow the specified schema?
- Executability: does the generated code actually run?

The required actions listed in `agent_must_do` are evaluated by weighted scoring, with a different verification rubric for each task.

### Software Categories

The software categories that agents must operate across the 153 tasks include browser automation, PDF parsing, GeoPackage workflows, Python/C++/SQL/shell scripting, Odoo, Metabase, Flowable BPMN, LibreOffice, Rhino 8, Docker, Kubernetes, and Linux permission management. The structure is not about demanding that a single agent handle all of these well, but about granularly measuring actual agent capability within specific domains.

## Building Your Own Model Measurement Pipeline

The practical value of this dataset lies in using it as a reference point for measuring your own agent models. Because the dataset does not provide baseline performance figures, each adopting organization must construct its own benchmarks. The flip side is that internal comparison baselines can be established independently without external published scores.

Steps for assembling an evaluation pipeline:

1. Filter tasks by domain: use `category` and `subdomain` to define the evaluation scope.
2. Set up tool environments: prepare the tools named in the `software` field in containerized environments for each task.
3. Run the agent: use each task's `task_prompt` as input to run the agent.
4. Collect outputs: save agent-generated files or responses to per-task output directories.
5. Run verification: automatically score completion based on the action list in `agent_must_do`.

## ThakiCloud Use Cases

On the ThakiCloud platform, there are two primary directions for using this dataset.

**Measuring internal agent capability**: AI agent models running in Kueue are periodically evaluated on the 153 agents-last-exam tasks to measure how well they complete real work tasks. Kubernetes-related tasks and data engineering tasks in particular can quantify the strengths and weaknesses of internal infrastructure models.

**Agent development regression testing**: Whenever an agent model or tool policy is updated, running the relevant domain task subset to check for performance degradation serves as an automated regression test. The CC-BY-4.0 license allows integration into internal pipelines without restriction.

Following an ArgoCD GitOps structure, task evaluation jobs can be managed as code and a workflow can be configured to run benchmarks automatically whenever the agent version changes.

## Summary

agents-last-exam illustrates the shift in agent evaluation standards from short-form responses to long-horizon task completion. The combination of 153 tasks, 5 domains, and a CC-BY-4.0 license can serve as a starting point for teams that want to measure the real-world capability of their own agent models. The absence of published baselines is inconvenient, but for the purpose of tracking internal progress without external comparison it actually provides more flexibility.

HuggingFace: [agents-last-exam/agents-last-exam](https://huggingface.co/datasets/agents-last-exam/agents-last-exam)
