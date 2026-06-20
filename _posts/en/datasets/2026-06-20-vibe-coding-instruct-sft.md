---
title: "Vibe-Coding-Instruct: SFT for Lightweight Code Agents Using 1.1 Million Samples"
excerpt: "Vibe-Coding-Instruct by lazarus19 is an Apache-2.0 dataset of 1.1 million coding instruction-response pairs. It has already been used to train 7 Gemma/Qwen derivative models, and can be used directly to build a custom code agent SFT pipeline."
date: 2026-06-20
categories:
  - datasets
tags:
  - sft
  - instruction-tuning
  - coding-agent
  - vibe-coding
  - apache-2.0
  - qwen
  - gemma
  - code-generation
  - fine-tuning
lang: en
author_profile: true
toc: true
toc_label: "Vibe-Coding-Instruct Guide"
reading_time: true
canonical_url: "https://thakicloud.github.io/en/datasets/vibe-coding-instruct-sft/"
---

⏱️ **Estimated reading time**: 7 min

![Vibe Coding Instruct SFT overview](/assets/images/vibe-coding-instruct-sft-hero.png)

## Dataset Overview

**Vibe-Coding-Instruct** is a coding instruction-response pair dataset released by lazarus19 on HuggingFace. It contains 1.1 million samples in the training split, carries an Apache-2.0 license, and has a total file size of 459 MB. Seven models have already been trained on this dataset and are publicly available, primarily the RavenX-OpenFable-Coder series based on Gemma and Qwen architectures.

The term "vibe coding" refers to a development style in which the LLM generates the full code while the human provides only direction. This dataset is designed as instruction data for fine-tuning models that support that style.

## Structure and Schema

### Scale

- Training split: 1,100,000 samples
- Total file size: 459 MB
- Language: English
- File format: JSON (source), Parquet (auto-converted by HuggingFace)

### Schema

Each record consists of four fields.

| Field | Type | Value range |
|------|------|---------|
| `instruction` | string | 35 to 89 characters |
| `input` | string | Single value across the entire dataset |
| `output` | string | 14 distinct values |
| `prompt` | string | 170 to 337 characters |

The `instruction` field contains the coding task prompt, and the `prompt` field holds the formatted input actually passed to the model. The 14 distinct output values indicate that the instruction types in the dataset cluster into specific categories.

### Instruction Types

Instruction categories observed in published samples include:

- Coding assistant and AI application creation
- MERN stack, AI app, and containerized environment deployment
- React infinite re-rendering and API 500 error debugging
- Chatbot platform, scalable SaaS, and AI project manager system design
- Local LLM integration using Ollama and llama.cpp

## License

The license is Apache-2.0. Commercial use, modification, redistribution, and patent use are all permitted. There is no source disclosure requirement, so the dataset can be used in corporate internal fine-tuning pipelines without restriction.

The license of a model trained on this Apache-2.0 dataset follows the license of the base model used for training, so the license terms of Qwen or Gemma base models must be checked separately.

## Dataset Characteristics from an SFT Pipeline Perspective

### Practical Value of 1.1 Million Samples

1.1 million samples is generally sufficient scale for instruction tuning of small code models in the 1B to 7B range. Too much data can actually cause overfitting to particular instruction types or extend training time excessively. Compared to early instruction datasets such as Alpaca and the FLAN series, which were in the 50K to 100K range, this is more than ten times larger.

At 459 MB, the actual file size is within the range a single A100 80GB node or two A10G 24GB nodes can process per epoch.

### Implications of 14 Distinct Output Values

The fact that the `output` field has only 14 distinct values is also a limitation of this dataset. If the outputs are composed of fixed response patterns in defined categories rather than diverse code snippets, a model trained solely on this data may have difficulty flexibly handling a broad range of coding tasks. This is why mixing with other code generation datasets or adding custom data for specific domains is advisable.

### Validated Derivative Model Path

According to the dataset page, 7 models have already been trained using this dataset. The RavenX-OpenFable-Coder series is available in both Gemma and Qwen architectures, meaning a structure already exists for reproducing or modifying the same pipeline.

## Building a Custom Code Agent SFT Pipeline

### Basic Training Configuration

Loading the data with the HuggingFace datasets library is all that is needed to get started.

```python
from datasets import load_dataset

dataset = load_dataset("lazarus19/Vibe-Coding-Instruct")
train_data = dataset["train"]
```

For SFT training, the `prompt` field is used as model input and the `output` field as the target label. Using the `SFTTrainer` from the TRL (Transformer Reinforcement Learning) library makes configuration straightforward.

### Domain-Specific Data Mixing Strategy

Rather than using all 1.1 million Vibe-Coding-Instruct samples as-is, a more practical and effective approach is to create additional ThakiCloud platform-specific instructions and mix them in. For example, adding a few thousand instruction samples covering internal patterns such as Kubernetes manifest generation, ArgoCD configuration writing, and Go backend API code generation layers domain-specific capability on top of general code ability.

This approach is also effective when combined with Fable-5-traces. A two-stage SFT configuration is possible: use Vibe-Coding-Instruct to establish baseline code generation ability, then train tool-call policy on top with Fable-5-traces.

### Base Model Selection

Looking at the derivative model paths shown on the dataset page, Qwen2.5-Coder and Gemma3 series were primarily used. In a ThakiCloud on-premises hosting context, using Qwen2.5-Coder-7B-Instruct as the base model and SFT-ing with this dataset produces an internal code agent without external API dependency.

## ThakiCloud Use Cases

The ThakiCloud platform applications for this dataset organize around the following directions.

**Foundation data for self-hosted code agents**: The Apache-2.0 license allows unrestricted integration into internal fine-tuning pipelines. Processing the 1.1 million Vibe-Coding-Instruct samples as Kueue batch jobs completes the full training cycle on ThakiCloud infrastructure.

**Acquiring baseline code capability**: When domain-specific data is scarce, using Vibe-Coding-Instruct first to establish general-purpose code capability and then incrementally adding internal domain data is a realistic strategy.

**Reference to RavenX derivative models**: The training configurations of the 7 already-published derivative models can be used as a reference to set a starting point with minimal experimentation cost.

One consideration: the limited diversity of 14 distinct `output` values suggests that a model trained solely on this data may show generalization failure when faced with new types of coding tasks. A strategy of mixing with supplementary datasets or internal data is recommended.

## Summary

Vibe-Coding-Instruct is a coding instruction dataset with 1.1 million samples, Apache-2.0 license, and 459 MB size. It has an established track record of producing 7 models, and the Qwen and Gemma fine-tuning paths are validated. The barrier to using it as a starting point for custom code agent SFT experiments is low. Recognizing the output diversity limitation and planning a strategy to mix with domain-specific data makes it feasible to build a practical on-premises code agent.

HuggingFace: [lazarus19/Vibe-Coding-Instruct](https://huggingface.co/datasets/lazarus19/Vibe-Coding-Instruct)
