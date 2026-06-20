---
title: "Qwen3-4B GRPO Training Complete Guide - Korean Reasoning Dataset Utilization and Colab Notebook Analysis"
excerpt: "A detailed analysis of the GRPO (Gradient-based Reasoning Policy Optimization) training process for the Qwen3-4B model, with a practical guide for effective model training using Korean reasoning datasets."
seo_title: "Qwen3-4B GRPO Korean Reasoning Model Training Guide - Thaki Cloud"
seo_description: "Complete analysis of the Qwen3-4B GRPO training process. A detailed practitioner guide covering Colab notebook internals and Korean reasoning dataset usage."
date: 2025-07-30
last_modified_at: 2025-07-30
categories:
  - llmops
  - tutorials
tags:
  - Qwen3-4B
  - GRPO
  - 한국어추론
  - 강화학습
  - Colab
  - Unsloth
  - 추론모델
  - 데이터셋
  - 알리바바
  - Korean-Reasoning
author_profile: true
toc: true
toc_label: "Table of Contents"
toc_icon: "brain"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/en/llmops/qwen3-4b-grpo-korean-reasoning-training-guide/"
lang: en
reading_time: true
---

⏱️ **Estimated reading time**: 8 min

## Colab Notebook Analysis and Korean Dataset Usage Guide

This document explains the key components used for model training based on an analysis of the provided Colab notebook, and offers a concrete guide for training a model using Korean datasets.

### 1. Colab Notebook Analysis Results

#### 1.1 Datasets Used

- **Pre-finetuning:** A subset of the `unsloth/OpenMathReasoning-mini` dataset was used to familiarize the model with the custom GRPO formatting. This dataset is a filtered collection of high-quality samples from the Open Math Reasoning dataset that include DeepSeek R1 reasoning traces.
- **GRPO training:** The `open-r1/DAPO-Math-17k-Processed` dataset (English version) was used to run GRPO training to strengthen the model's reasoning capabilities. This dataset contains a variety of math problems and their solutions.

#### 1.2 Frameworks and Libraries Used

- **Unsloth:** The core framework for optimizing LoRA model training speed.
- **Hugging Face Transformers:** Handles fundamental NLP tasks such as model loading and tokenization.
- **trl:** Used to implement advanced training techniques such as SFT (Supervised Fine-Tuning) and GRPO (Gradient-based Reasoning Policy Optimization).
- **datasets:** Efficiently manages dataset loading, preprocessing, and handling.
- **vllm:** Supports fast inference for trained models.
- **torch:** The PyTorch framework for deep learning computations.

#### 1.3 Training Configuration

- **SFT Pre-finetuning:**
  - **Epochs:** 2
  - **Learning Rate:** 2e-4
  - **Batch Size (per device):** 1
  - **Gradient Accumulation Steps:** 1
- **GRPO Training:**
  - **Max Steps:** 100 (adjust this value to complete 1 epoch over the full dataset)
  - **Learning Rate:** 5e-6
  - **Batch Size (per device):** 4 (set equal to num_generations)
  - **Gradient Accumulation Steps:** 1 (can be increased to 4 for smoother training)
  - **num_generations:** 4 (can be reduced if out-of-memory errors occur)
  - **max_prompt_length:** 202 (90th percentile length of the dataset plus 1)
  - **max_completion_length:** 1846 (max_seq_length minus max_prompt_length)

#### 1.4 Training Time and Recommended GPU

- **SFT Pre-finetuning time:** Approximately 2.8 minutes (170.89 seconds)
- **GRPO training time:** Approximately 2.95 hours (10607.69 seconds)
- **Recommended GPU:** **Tesla T4**, as confirmed in the notebook runtime environment and Unsloth initialization output.

### 2. Korean Reasoning Dataset List

The following is a list of datasets on Hugging Face Hub that can be used for training Korean reasoning models.

| Dataset Name | Description | Source |
|---|---|---|
| lemon-mint/korean_reasoning_v0.1 | No description available. | Hugging Face Hub |
| lemon-mint/korean_reasoning_v0.2 | No description available. | Hugging Face Hub |
| lemon-mint/korean_reasoning_v1.0 | No description available. | Hugging Face Hub |
| lemon-mint/korean-reasoning-v01-sample | No description available. | Hugging Face Hub |
| lemon-mint/korean-reasoning-v01-test | No description available. | Hugging Face Hub |
| lemon-mint/korean-reasoning-v01 | No description available. | Hugging Face Hub |
| lemon-mint/korean-reasoning-v02 | No description available. | Hugging Face Hub |
| lemon-mint/korean-realqa-reasoning-v01 | No description available. | Hugging Face Hub |
| lemon-mint/korean-reasoning-v02-raw | No description available. | Hugging Face Hub |
| lemon-mint/korean-reasoning-v02-raw-conversational | No description available. | Hugging Face Hub |
| lemon-mint/korean-reasoning-v01-raw | No description available. | Hugging Face Hub |
| lemon-mint/korean-reasoning-v01-raw-conversational | No description available. | Hugging Face Hub |
| lemon-mint/korean-realqa-reasoning-v01-raw | No description available. | Hugging Face Hub |
| lemon-mint/korean-realqa-reasoning-v01-raw-conversational | No description available. | Hugging Face Hub |
| lemon-mint/korean-realqa-reasoning-v01-preference | No description available. | Hugging Face Hub |
| exp-models/korean-reasoning-mixture-20250203-preference | No description available. | Hugging Face Hub |
| exp-models/korean-reasoning-mixture-20250203-plaintext | No description available. | Hugging Face Hub |
| koreankiwi99/mnlp_stem_reasoning | No description available. | Hugging Face Hub |

### 3. Training Guide for Korean Datasets

Training the model with Korean datasets requires some modifications to the existing notebook code. The following describes the main areas to update.

#### 3.1 Dataset Loading

Use the `load_dataset` function from the `datasets` library to load the desired Korean dataset.

```python
from datasets import load_dataset

# Example: loading the 'lemon-mint/korean_reasoning_v0.1' dataset
# Split names ('train', 'validation', 'test', etc.) may differ by dataset.
dataset = load_dataset("lemon-mint/korean_reasoning_v0.1", split="train")
```

#### 3.2 Data Preprocessing and Formatting

For GRPO training, the dataset must follow a specific conversation format (`system`, `user`, `assistant`) and a reasoning/answer format (`<start_working_out>`, `<end_working_out>`, `<SOLUTION>`, `</SOLUTION>`). You will need to modify the preprocessing and formatting functions to match the structure of the loaded Korean dataset.

- **Column mapping:** The column names for the problem (prompt) and solution in the loaded dataset may differ from the original notebook. Check the dataset documentation and update the code to map or directly access the correct column names.

```python
# Check dataset column names and modify as needed
# dataset = dataset.rename_columns({"original_prompt_col": "prompt", "original_solution_col": "solution"})
```

- **Custom formatting function (modifying `format_dataset`):** The `format_dataset` function in the original notebook removes `<think>` and `</think>` tags from the English dataset and adds new GRPO tags. For Korean datasets, you may need to rewrite this function entirely or modify it depending on how the problem and solution text are structured. The goal is to convert each sample into a list of conversation messages in the form `{% raw %}{"role": "system", "content": system_prompt}, {"role": "user", "content": problem}, {"role": "assistant", "content": "<start_working_out>reasoning<end_working_out><SOLUTION>answer</SOLUTION>"}{% endraw %}`. If the Korean dataset includes reasoning traces, extract that portion and place it between `<start_working_out>` and `<end_working_out>`, and place the final answer between `<SOLUTION>` and `</SOLUTION>`.

```python
def format_korean_dataset(x):
    # Extract the problem and solution according to the Korean dataset structure
    problem = x["prompt"]   # Example: assuming the problem is in the 'prompt' column
    solution = x["solution"] # Example: assuming the solution is in the 'solution' column

    # Separate the reasoning trace and final answer based on the solution structure
    # Example: if the solution is in the format 'reasoning trace###final answer'
    # parts = solution.split("###")
    # thoughts = parts[0].strip() if len(parts) > 1 else ""
    # answer = parts[-1].strip()

    # If the Korean dataset solution contains only the final answer
    thoughts = "This dataset does not include a reasoning trace." # Or set another default value
    answer = solution.strip()

    final_prompt = \
        reasoning_start + thoughts + reasoning_end + \
        solution_start + answer + solution_end

    return [
        {"role" : "system",    "content" : system_prompt},
        {"role" : "user",      "content" : problem},
        {"role" : "assistant", "content" : final_prompt},
    ]

# Apply to the dataset
dataset["Messages"] = dataset.apply(format_korean_dataset, axis = 1)
```

- **Tokenization and length filtering:** The process of tokenizing the formatted messages and filtering by `max_seq_length` can be applied the same way as in the original notebook. However, token lengths may differ for Korean text, so verify the `maximum_length` calculation result.

#### 3.3 Reward Function Modifications

The reward functions, which are central to GRPO training, may also need to be modified to match the characteristics of the Korean dataset.

- **`match_format` and related functions:** The `match_format_exactly` and `match_format_approximately` functions use the defined GRPO tags (`reasoning_end`, `solution_start`, `solution_end`). If the tags themselves have not been changed, these functions can be used without modification.
- **`check_answer` and `check_numbers` functions:** These functions extract the final answer from the generated text and determine whether it is correct. If the Korean dataset answers are in a form other than numbers (for example, Korean text sentences), you will need to modify the `match_numbers` regular expression or change the answer comparison logic. Even for numeric answers, additional preprocessing (such as removing commas) may be needed depending on how numbers are expressed in Korean.

```python
import re

# Review whether the regular expression needs to be updated to handle Korean numbers and related symbols
# match_numbers = re.compile(...)

# Review whether the answer extraction and comparison logic inside check_answer and check_numbers needs updating
# In particular, change the logic if the answers are not numeric
```

#### 3.4 GRPO Trainer Configuration

When configuring the `GRPO Trainer`, `max_prompt_length` and `max_completion_length` must be recalculated based on the tokenization output lengths of the Korean dataset. The remaining GRPO settings (`learning_rate`, `num_generations`, etc.) can be adjusted experimentally to suit the characteristics of the model and dataset.

### 4. Conclusion

This document analyzed the GRPO training process for the Qwen3-4B model and proposed a training approach using Korean datasets. Properly adapting the data preprocessing and reward functions to the characteristics of the Korean dataset is the key to successful model training. Use the guidelines provided as a reference for developing Korean reasoning models.
