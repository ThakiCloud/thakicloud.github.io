---
title: "vLLM Prefix Caching in Production: Cut Inference Costs by Half with KV Cache Reuse"
excerpt: "How to configure and measure vLLM Automatic Prefix Caching in production, with real hit-rate and cost-reduction numbers."
seo_title: "vLLM Prefix Caching KV Cache Reuse Production Guide - Thaki Cloud"
seo_description: "How to enable vLLM Automatic Prefix Caching, how PagedAttention KV block hashing works, conditions for achieving 60-85% hit rates, and practical patterns for multi-tenant SaaS."
date: 2026-06-20
last_modified_at: 2026-06-20
categories:
  - dev
tags: [vllm, prefix-caching, kv-cache, llm-serving, gpu, inference, kubernetes, pagedattention]
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/en/dev/vllm-prefix-caching-kv-reuse-production/"
reading_time: true
lang: en
---

⏱️ **Estimated reading time**: 7 min

Prefix Caching is the easiest inference cost optimization you can capture. When a system prompt or long context repeats across requests, reusing the KV Cache instead of recomputing it can cut GPU time by more than half. vLLM ships this as Automatic Prefix Caching (APC).

## Why Prefix Caching Works

LLM inference has two phases: prefill (processing the input) and decode (generating tokens). Prefix Caching operates only on the prefill phase. When two requests share the same leading tokens (the prefix), the KV (Key-Value) states for that segment are loaded from cache rather than recomputed.

The numbers make the value concrete. Cache hits deliver reported cost savings of 85-95%. In agent loops and multi-tenant SaaS environments, hit rates of 60-85% are realistic without special effort. There is no penalty on cache misses, so enabling the feature is the default strategy.

One important boundary: Prefix Caching does not affect decode speed. It improves Time to First Token (TTFT) but leaves Tokens Per Second (TPS) unchanged. Mixing these up leads to wrong expectations.

## How vLLM KV Block Hashing Works

vLLM manages KV Cache in fixed-size blocks under PagedAttention. Automatic Prefix Caching identifies each block by hashing both the block's own tokens and every preceding token in the sequence.

```
block hash = hash(hash of preceding blocks || token IDs of current block)
```

This lets vLLM determine in O(1) how many blocks can be reused by any incoming request. When a new request arrives, vLLM scans the block table for matching hashes and reuses those blocks. Prefill starts from the first non-matching block.

As of 2026, PagedAttention is the de facto standard in production inference stacks. vLLM, SGLang, and TensorRT-LLM all ship it by default. KV Cache waste has dropped below 4%, and the 2-4x throughput gains come directly from this architecture.

## Enabling Prefix Caching

One flag enables it on the vLLM server:

```bash
python -m vllm.entrypoints.openai.api_server \
  --model meta-llama/Llama-3-70b-instruct \
  --enable-prefix-caching \
  --max-model-len 32768 \
  --gpu-memory-utilization 0.90
```

In Kubernetes, add the flag to the Deployment args section:

```yaml
containers:
- name: vllm
  image: vllm/vllm-openai:latest
  args:
  - "--model"
  - "meta-llama/Llama-3-70b-instruct"
  - "--enable-prefix-caching"
  - "--max-model-len"
  - "32768"
  resources:
    limits:
      nvidia.com/gpu: "1"
```

## Patterns for Higher Hit Rates

### Pin the system prompt at the front

Hit rate is proportional to prefix length and stability. When the system prompt is identical at the start of every request, its KV Cache is computed only once. The longer and more stable the system prompt, the larger the savings.

```python
messages = [
    {"role": "system", "content": SYSTEM_PROMPT},  # constant across requests
    {"role": "user", "content": user_query},         # varies per request
]
```

### Accumulate context in agent loops

Multi-step agents keep the prefix long by appending conversation history. From step 2 onward, the KV state for all preceding steps is served from cache.

### Put RAG documents before the question

In Retrieval-Augmented Generation, placing retrieved documents before the user question allows requests that reference the same document set to hit each other's cache. Hit rates of 60-80% for the document segment are realistic in patterns like codebase QA and long-document analysis.

## Monitoring Hit Rate

vLLM exposes cache hit rate via Prometheus metrics:

```promql
# cache hit rate
rate(vllm:cache_hit_tokens_total[5m]) 
/ rate(vllm:prompt_tokens_total[5m])
```

When hit rate is low, check these first:

- Does the system prompt include per-request variable strings such as timestamps or session IDs?
- Is GPU memory tight enough that cache blocks are evicted too frequently?
- Does block size align with prefix length?

## Comparison with LMCache

A benchmark published in April 2026 on Level Up Coding comparing vLLM Prefix Caching and LMCache ([Level Up Coding, April 2026](https://levelup.gitconnected.com/vllm-prefix-caching-vs-lmcache-benchmarking-kv-reuse-tradeoffs-944fbaf98b56)) shows that on a single node, vLLM's built-in APC delivers sufficient performance. For distributed multi-node serving, a separate distributed KV layer such as LMCache or llm-d becomes worth evaluating. At ThakiCloud's current scale, starting with built-in APC and adding distributed storage only when the node count grows is the practical sequence.

## Things to Watch

In multi-tenant environments, KV Cache sharing across tenants is a potential information-leakage path. vLLM shares cache blocks whenever prefix tokens match, regardless of tenant identity. Tenants with distinct system prompts are naturally isolated. If you use a shared system prompt while putting tenant data into the context, the design requires careful review.

Enabling `--enable-chunked-prefill` alongside Prefix Caching increases throughput further. The two features work well together.

## Summary

vLLM Prefix Caching is a free optimization enabled by a single flag. On workloads with hit rates above 60%, it can reduce GPU costs by more than half. The three patterns that drive hit rate are: fixing the system prompt, accumulating context in agent loops, and placing RAG documents before the question. There is no reason to leave it off.
