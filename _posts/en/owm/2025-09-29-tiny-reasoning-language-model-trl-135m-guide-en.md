---
title: "Tiny Reasoning Language Model (TRLM-135M): Revolutionizing Reasoning in Small Models"
excerpt: "TRLM-135M, a 135M parameter model, represents a breakthrough in step-by-step reasoning for small language models. Through a sophisticated 3-stage pipeline, it learns from general conversations to complex reasoning tasks."
seo_title: "TRLM-135M Tiny Reasoning Language Model Guide - Thaki Cloud"
seo_description: "Discover the 3-stage training pipeline and reasoning capabilities of the 135M parameter TRLM-135M model. Explore how small models can achieve advanced reasoning through innovative training methods."
date: 2025-09-29
categories:
  - owm
tags:
  - TRLM
  - SmallModels
  - ReasoningLearning
  - DPO
  - StepByStepReasoning
author_profile: true
toc: true
toc_label: "Table of Contents"
canonical_url: "https://thakicloud.github.io/en/owm/tiny-reasoning-language-model-trl-135m-guide/"
lang: en
permalink: /en/owm/tiny-reasoning-language-model-trl-135m-guide/
---

⏱️ **Estimated reading time**: 8 minutes

## Introduction

The **Tiny Reasoning Language Model (TRLM-135M)** is a research prototype with 135M parameters designed to study how small models can learn step-by-step reasoning. Built on top of SmolLM2-135M-Instruct, this model has been fine-tuned through a sophisticated **3-stage pipeline** that transforms general conversation abilities into advanced reasoning capabilities.

## Core Features of TRLM-135M

### Model Architecture
- **Base Model**: SmolLM2-135M-Instruct (Llama 3 based)
- **Parameters**: ~135M
- **Precision**: Mixed precision (bfloat16) training
- **Architecture**: Decoder-only transformer

### 3-Stage Training Pipeline

#### Stage 1: General Instruction Tuning (SFT)
- **Data**: ~58,000 samples
- **Content**: Everyday conversations and instruction following
- **Purpose**: Establish basic conversational abilities

#### Stage 2: Reasoning Trace Learning (SFT)
- **Data**: ~78,000 samples
- **Feature**: Reasoning processes with `<think>` tags
- **Purpose**: Learn step-by-step thinking processes

#### Stage 3: Preference Alignment (DPO)
- **Data**: ~50,000 preference pairs
- **Content**: Chosen vs rejected reasoning traces
- **Purpose**: Align reasoning style preferences

## Performance Evaluation Results

TRLM-135M shows significant improvements over the baseline SmolLM2-135M-Instruct across various benchmarks:

| Benchmark | TRLM-135M | SmolLM2-135M-Instruct | Improvement |
|-----------|-----------|----------------------|-------------|
| **ARC Challenge** | **40.61** | 37.3 | **+3.31** |
| **BBH** | **36.80** | 28.2 | **+8.6** |
| **BoolQ** | **62.17** | – | N/A |
| **GSM8K** | **2.59** | 1.4 | **+1.19** |
| **IFEval** | **35.49** | 29.9 | **+5.59** |
| **MMLU** | **34.95** | 29.3 | **+5.65** |
| **PIQA** | **64.91** | 66.3 | **-1.39** |

## Usage Guide

### Installation and Setup

```bash
pip install -U transformers accelerate
```

### Basic Usage Example

```python
from transformers import AutoModelForCausalLM, AutoTokenizer

model_name = "Shekswess/trlm-135m"
device = "cuda"  # or "cpu"

# Load tokenizer and model
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForCausalLM.from_pretrained(
    model_name,
).to(device)

# Example prompt
prompt = "Give me a brief explanation of gravity in simple terms."
messages = [
    {"role": "user", "content": prompt}
]

# Apply chat template
text = tokenizer.apply_chat_template(
    messages,
    tokenize=False,
    add_generation_prompt=True,
)

inputs = tokenizer([text], return_tensors="pt").to(model.device)

# Generate
outputs = model.generate(**inputs, max_new_tokens=256)
print(tokenizer.decode(outputs[0], skip_special_tokens=True))
```

### Recommended Settings for Reasoning Tasks

For reasoning-heavy tasks, use the following parameters:
- `temperature=0.6`
- `top_p=0.95`

## Technical Innovations

### 1. Step-by-Step Reasoning Learning
TRLM-135M utilizes `<think>` tags to help the model learn internal thinking processes. This approach enhances actual reasoning capabilities rather than simple pattern matching.

### 2. Reasoning Quality Improvement through DPO
Direct Preference Optimization (DPO) trains the model to prefer better reasoning processes, improving accuracy and consistency in reasoning tasks.

### 3. Efficiency of Small Models
With only 135M parameters, TRLM-135M demonstrates that high-quality reasoning is possible even with resource constraints.

## Research Significance

### Expanding Small Model Capabilities
TRLM-135M proves that small models can perform complex reasoning tasks with appropriate training methods. This opens new possibilities for AI applications in edge devices and mobile environments.

### Reasoning Learning Methodology
The 3-stage pipeline presents a new methodology for creating small models with reasoning capabilities, providing valuable reference for future small model development.

## Limitations and Considerations

### Production Readiness
- **Hallucinations**: Frequent logical errors and incorrect information generation
- **Small Size**: Limited general knowledge and reasoning depth
- **English Only**: Multilingual capabilities not explored

### Usage Considerations
- Recommended for research and experimental purposes only
- Should not be used for critical decision-making
- Requires additional verification and review

## Future Development Directions

### 1. Multilingual Support
Expanding the currently English-only model to support multiple languages would increase global usability.

### 2. Domain Specialization
Developing reasoning models specialized for specific domains like healthcare, law, and science is possible.

### 3. Efficiency Improvements
Research is needed to achieve the same performance with even fewer parameters.

## Conclusion

TRLM-135M represents a significant milestone in small model reasoning research. With only 135M parameters, it demonstrates substantial reasoning capabilities through its innovative 3-stage training pipeline, expanding the possibilities for small models.

As edge computing and mobile AI become increasingly important, research into small reasoning models like TRLM-135M is highly valuable. We can expect to see even more advanced small reasoning models in the future.

## References

- [TRLM-135M Hugging Face Model Page](https://huggingface.co/Shekswess/trlm-135m)
- [SmolLM2-135M-Instruct Base Model](https://huggingface.co/HuggingFaceTB/SmolLM2-135M-Instruct)
- [TRL (Transformers Reinforcement Learning) Library](https://github.com/huggingface/trl)

---

**💡 Tip**: When using TRLM-135M, apply `temperature=0.6` and `top_p=0.95` settings for reasoning tasks. This configuration helps achieve more consistent and logical reasoning results.
