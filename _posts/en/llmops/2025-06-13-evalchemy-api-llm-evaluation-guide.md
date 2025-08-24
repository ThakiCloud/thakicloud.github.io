---
title: "Evaluating 100+ LLM Models with Just API Calls Using Evalchemy: Complete No-Installation Benchmark Guide"
excerpt: "Learn how to evaluate 100+ API models including GPT-4o, Claude-3, and Gemini without installation using the Evalchemy + Curator + LiteLLM combination"
seo_title: "Evalchemy API LLM Evaluation - No-Installation Benchmark Guide"
seo_description: "Complete guide to evaluating 100+ LLM models via API calls using Evalchemy, Curator, and LiteLLM. No installation required for GPT-4o, Claude-3, Gemini evaluation"
date: 2025-06-13
categories: 
  - llmops
tags: 
  - Evalchemy
  - LLM-Evaluation
  - Curator
  - LiteLLM
  - Benchmarking
  - API-Evaluation
  - MLOps
  - Model-Testing
author_profile: true
toc: true
toc_label: "Table of Contents"
canonical_url: "https://thakicloud.github.io/en/llmops/evalchemy-api-llm-evaluation-guide/"
---

⏱️ **Estimated Reading Time**: 12 minutes

## Executive Summary

**Evalchemy** originally focuses on local model installation methods (HuggingFace, vLLM, etc.), but thanks to **Curator model adapters** (LiteLLM integration) and **LM-Eval-Harness's OpenAI / Anthropic / other API backends**, you can execute identical benchmarks using **REST API calls only**.

Simply changing CLI flags like `--model curator` or `--model openai` enables evaluation of **over 100 API models** including GPT-4o, Claude-3, Gemini-2, and custom vLLM servers without installation.

This guide covers everything from environment setup to three representative patterns: official OpenAI, internal vLLM OpenAI-compatible endpoints, and Google Gemini.

## Understanding the Evalchemy / LM-Eval-Harness Pipeline

LM-Eval-Harness (referred to as *Harness*) performs evaluation using a **"two-round, three-stage"** structure:

**Data Loading & Split Generation** → **Model Generation (Inference)** → **Scoring (Metrics)**

In standard configuration, *train* and *eval* splits are processed sequentially, with "Generating..." logs appearing once for each. CLI flags like `--predict_only`, `--skip_train`, `--skip_eval` specify **which stages/rounds to skip** rather than reducing the dataset itself.

### Stage 1: Data Loading & Split Generation

#### Task YAML & CLI Interpretation

Harness reads `--tasks` (comma-separated list) or `--config YAML` to determine tasks to execute. YAML contains `task_name`, `batch_size`, `num_examples`, `subsample`, etc.

#### Dataset Parsing

Each task package's `__init__.py` contains the `DATASET_PATH` constant pointing to original JSON/JSONL locations.

#### Split Strategy

**Train split**: Used for few-shot prompt construction and "model generation" examples
**Eval split**: Generates responses using the same data (or validation set), then compares with ground truth for metrics
- `--skip_eval` → Skip entire eval split
- `--skip_train` → Skip train split & perform eval only

### Stage 2: Model Generation Rounds

#### Curator → LiteLLM → Backend

Evalchemy passes all prompts to **Curator LLM API** through `curator_lm.py`. Curator writes-caches request JSONL and calls **LiteLLM**, which sends REST POST requests to specified providers (OpenAI/Anthropic/vLLM/LM Studio).

#### Continuous Batching

Curator bundles requests within token and RPM limits for transmission, with additional dynamic batching occurring on the vLLM/LM Studio side.

#### Response Collection & Caching

Box-unit responses are `CuratorResponse`; text is extracted via `response_obj.dataset[i]["response"]`. All responses and original prompts are permanently stored in `$HOME/.cache/curator/<run-id>/responses_*.jsonl`.

### Stage 3: Scoring Phase

#### Metric Calculation

Various metric functions (Exact Match, BLEU, F1, Code-Elo) are called according to task definitions. Scoring executes after **eval split** generation completes. `--predict_only` skips metric functions and saves only generated outputs.

#### Result Aggregation & Output

Curator aggregates tokens, time, and costs for console table output. Harness records final dictionary to `--output_path` (JSON) with structure:

```jsonc
{ "results": {"AIME24": {"exact_match":0.83, …}},
  "configs": {...}, "versions": {...} }
```

### Execution Matrix by Flags

Different flag combinations control which stages execute:

**Default**: Both train and eval splits with scoring - full benchmark
**`--predict_only`**: Both splits without scoring - collect model responses only
**`--skip_eval`**: Train split only - quick inference testing
**`--skip_train`**: Eval split only with scoring - utilize existing few-shot cache

### Runtime Optimization Points

**Reduce Sample Count**: `--limit N` (task count) + JSON subset or `subsample:` key
**Limit Response Tokens**: `--gen_kwargs "max_new_tokens=256"` etc.
**Skip Rounds**: `--skip_eval` / `--skip_train` combinations
**Enable Cache**: `--use_cache DIR` → avoid re-calling identical prompts

Understanding the **"two split (generation-scoring)"** pattern as LM-Eval-Harness's core design enables efficient benchmark execution control through `--predict_only` and `--skip_*` flags. The Curator → LiteLLM → provider layer structure and response cache (`$HOME/.cache/curator/<run-id>/responses_*.jsonl`) prove invaluable for experiment reproduction and cost analysis.

## Prerequisites

### Dependency Installation

```bash
# Create Conda environment (recommended)
conda create -n evalchemy python=3.10
conda activate evalchemy

# Install Evalchemy + Curator + LiteLLM
pip install -e "git+https://github.com/mlfoundations/Evalchemy.git#egg=evalchemy[eval]" 
pip install bespokelabs-curator litellm  # For Curator-LiteLLM connection
```

**Evalchemy** wraps LM-Eval-Harness, automatically installing additional packages.

### API Credential Setup

```bash
export OPENAI_API_KEY="<your-openai-key>"
export ANTHROPIC_API_KEY="<your-anthropic-key>"
export GEMINI_API_KEY="<your-gcp-vertex-ai-key>"
# For custom vLLM servers, no key needed or use dummy values
```

LiteLLM reads environment variables directly and passes them to respective API providers.

## Understanding CLI Format

Key arguments and their meanings:

**`--model`**: Backend type (`curator`, `openai`, `anthropic`, etc.)
**`--model_name`**: `provider/model` notation (LiteLLM rules) - e.g., `openai/gpt-4o-mini`
**`--model_args`**: API base URL, tokenization options, etc. in `key=value` comma-separated format
**`--tasks`**: Benchmark list (comma-separated) - e.g., `MTBench,LiveCodeBench`

Additional options include `--batch_size`, `--apply_chat_template`, `--output_path`, etc. Detailed options are available in README and YAML examples in the `configs/` folder.

## Representative Scenario Commands

### OpenAI GPT-4o Evaluation

```bash
python -m eval.eval \
  --model curator \
  --tasks MTBench,LiveCodeBench \
  --model_name "openai/gpt-4o-mini" \
  --model_args "api_base=https://api.openai.com/v1" \
  --batch_size 8 \
  --output_path logs/gpt4o.json
```

Requests are forwarded to OpenAI ChatCompletion endpoint via Curator → LiteLLM.

### Internal vLLM (OpenAI-Compatible) Server Evaluation

```bash
python -m eval.eval \
  --model curator \
  --tasks AIME24,MATH500 \
  --model_name "openai/hf-mistral-7b-instruct" \
  --model_args "api_base=http://vllm.company.local:8000/v1,api_key=dummy" \
  --apply_chat_template True \
  --output_path logs/mistral_vllm.json
```

**LiteLLM's** "`openai/` prefix" rule and `api_base` flag enable calling any OpenAI-compatible server.

### Google Gemini-2 (Vertex AI) Evaluation

```bash
python -m eval.eval \
  --model curator \
  --tasks AIME24,GPQADiamond \
  --model_name "gemini/gemini-2.0-flash-thinking-exp-01-21" \
  --model_args "project_id=my-gcp-project" \
  --apply_chat_template False \
  --output_path logs/gemini.json
```

Curator provides **Gemini**-specific wrappers that work without separate installation.

## Advanced Usage Tips

### YAML Config for Repeated Tasks

Define `tasks`, `batch_size`, etc. in example files like `configs/light_gpt4omini0718.yaml`:

```bash
python -m eval.eval \
  --model curator \
  --model_name openai/gpt-4o-mini \
  --config configs/light_gpt4omini0718.yaml
```

This approach simplifies CLI commands.

### Async & Batch Processing Optimization

LM-Eval-Harness v0.4+ supports `batch_size` and `--parallelism` flags for OpenAI-style API calls, significantly reducing token costs:

```bash
python -m eval.eval \
  --model curator \
  --model_name "openai/gpt-4o-mini" \
  --batch_size 16 \
  --tasks MTBench \
  --parallelism 4
```

### Result Interpretation

```bash
jq '.results' logs/gpt4o.json             # Metrics by benchmark
jq '.config'  logs/gpt4o.json             # CLI options recorded during execution
```

JSON structure follows LM-Eval-Harness standards for direct integration with existing pipelines.

## Troubleshooting FAQ

Common issues and solutions:

**`401 Unauthorized`**: Missing API key environment variable → Check `echo $OPENAI_API_KEY`
**`Not Found /v1`**: Missing `/v1` in `api_base` → Use `http://host:port/v1` format
**`ValueError: must set tokenized_requests`**: Required for some models (e.g., Gemini) → Add `--model_args 'tokenized_requests=False'`
**Too slow**: Adjust `batch_size`, recommend **stream=False** in LiteLLM proxy

### Additional Debugging Tips

**Log Level Adjustment**

```bash
export LOGLEVEL=DEBUG
python -m eval.eval --model curator --model_name "openai/gpt-4o-mini" --tasks MTBench
```

**Network Connection Testing**

```bash
curl -H "Authorization: Bearer $OPENAI_API_KEY" \
     -H "Content-Type: application/json" \
     -d '{"model":"gpt-4o-mini","messages":[{"role":"user","content":"Hello"}]}' \
     https://api.openai.com/v1/chat/completions
```

## Real-World Use Cases

### Model Screening Workflow

```bash
#!/bin/bash
# Script for simultaneous multi-model evaluation

models=(
  "openai/gpt-4o-mini"
  "anthropic/claude-3-haiku-20240307"
  "gemini/gemini-1.5-flash"
)

for model in "${models[@]}"; do
  echo "Evaluating $model..."
  python -m eval.eval \
    --model curator \
    --model_name "$model" \
    --tasks MTBench,MATH500 \
    --batch_size 8 \
    --output_path "logs/$(echo $model | tr '/' '_').json" &
done

wait
echo "All evaluations completed!"
```

### CI/CD Pipeline Integration

```yaml
# .github/workflows/model-evaluation.yml
name: Model Evaluation

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  evaluate:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Set up Python
      uses: actions/setup-python@v3
      with:
        python-version: '3.10'
    
    - name: Install dependencies
      run: |
        pip install -e "git+https://github.com/mlfoundations/Evalchemy.git#egg=evalchemy[eval]"
        pip install bespokelabs-curator litellm
    
    - name: Run evaluation
      env:
        OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
      run: |
        python -m eval.eval \
          --model curator \
          --model_name "openai/gpt-4o-mini" \
          --tasks MTBench \
          --output_path results.json
    
    - name: Upload results
      uses: actions/upload-artifact@v3
      with:
        name: evaluation-results
        path: results.json
```

## Cost Optimization Strategies

### Token Usage Monitoring

```python
import json
import tiktoken

def estimate_cost(log_file, model_name="gpt-4o-mini"):
    """Estimate token usage and cost from evaluation results"""
    with open(log_file, 'r') as f:
        results = json.load(f)
    
    # Calculate input token count (example)
    encoder = tiktoken.encoding_for_model("gpt-4o-mini")
    total_tokens = 0
    
    for task_result in results.get('results', {}).values():
        if 'samples' in task_result:
            for sample in task_result['samples']:
                if 'prompt' in sample:
                    total_tokens += len(encoder.encode(sample['prompt']))
    
    # OpenAI pricing (2024 rates)
    cost_per_1k_tokens = 0.00015  # gpt-4o-mini input token rate
    estimated_cost = (total_tokens / 1000) * cost_per_1k_tokens
    
    print(f"Total tokens: {total_tokens:,}")
    print(f"Estimated cost: ${estimated_cost:.4f}")

# Usage example
estimate_cost("logs/gpt4o.json")
```

### Batch Size Optimization

```bash
# Start with small batches and gradually increase
for batch_size in 1 4 8 16; do
  echo "Testing batch_size=$batch_size"
  time python -m eval.eval \
    --model curator \
    --model_name "openai/gpt-4o-mini" \
    --tasks MTBench \
    --batch_size $batch_size \
    --output_path "logs/batch_${batch_size}.json"
done
```

## Production Deployment Considerations

### Scalability and Performance

Large-scale deployment requires careful consideration of infrastructure requirements, load balancing strategies, monitoring systems, and maintenance protocols. Implementation involves setting up distributed evaluation clusters, configuring automatic scaling mechanisms, and establishing comprehensive monitoring dashboards.

### Quality Assurance Protocols

Maintaining evaluation quality requires implementing comprehensive quality assurance protocols including automated testing, performance regression detection, and continuous monitoring of evaluation accuracy and consistency.

### Integration with MLOps Pipelines

Successful integration with existing MLOps workflows involves establishing standardized evaluation protocols, implementing automated reporting systems, and creating feedback loops for continuous model improvement.

## Conclusion

**Key Advantages**

**REST API calls only** instead of installation for easy benchmark reproduction
**Various LLM providers** (OpenAI, Anthropic, Google) testable through single CLI
**YAML config and async batch features** for significant cost and time savings

**Use Case Scenarios**

Rapid model screening before GPU resource acquisition
Performance comparison analysis between multiple API providers
Automated model evaluation in CI/CD pipelines
Cost-effective large-scale benchmark execution

Integrating the Evalchemy + Curator + LiteLLM combination into internal MLOps pipelines enables **rapid model screening and regression testing even before GPU resource acquisition**.

API-based evaluation has become essential for maintaining competitiveness in the rapidly evolving LLM ecosystem, allowing immediate verification of various cutting-edge models without local GPU environment setup costs.

---

**References:**

* [Evalchemy GitHub Repository](https://github.com/mlfoundations/Evalchemy)
* [Bespoke Curator Documentation](https://docs.bespokelabs.ai/bespoke-curator/getting-started)
* [LiteLLM Official Documentation](https://docs.litellm.ai/docs/providers)
* [LM-Eval-Harness](https://github.com/EleutherAI/lm-evaluation-harness)
* [OpenAI API Documentation](https://platform.openai.com/docs/models)
