---
title: "Large-Context LLM Inference with oLLM: Processing 100k Tokens on 8GB GPU"
excerpt: "Learn how to efficiently run large-context LLMs using the oLLM library on 8GB GPUs. A comprehensive guide to processing 100k token contexts with practical examples and optimization tips."
seo_title: "oLLM Large-Context LLM Inference Guide - 8GB GPU Optimization"
seo_description: "Complete guide to using oLLM library for processing 100k token contexts on 8GB GPUs. Includes contract analysis, medical records processing, and log analysis with real-world examples."
date: 2025-09-29
categories:
  - tutorials
tags:
  - oLLM
  - LLM
  - large-context
  - GPU-optimization
  - HuggingFace
author_profile: true
toc: true
toc_label: "Table of Contents"
canonical_url: "https://thakicloud.github.io/en/tutorials/ollm-large-context-llm-inference-guide/"
lang: en
permalink: /en/tutorials/ollm-large-context-llm-inference-guide/
---

⏱️ **Estimated reading time**: 15 minutes

# Large-Context LLM Inference with oLLM

One of the biggest constraints when working with Large Language Models (LLMs) is the **context length limitation**. With typical GPU memory, it's challenging to process long documents or conversation histories in a single pass.

**oLLM** is an innovative library that solves this problem. It enables processing 100k token contexts even with just 8GB of GPU memory.

## What is oLLM?

oLLM is a lightweight Python library built on top of HuggingFace Transformers and PyTorch. It features:

- **Large-context processing**: Handle up to 100k tokens
- **Low-cost GPU utilization**: Run large models with just 8GB VRAM
- **No quantization**: Maintains fp16/bf16 precision
- **SSD offloading**: Offloads KV cache and layer weights to SSD

## Supported Models and Performance

### Memory Usage on 8GB Nvidia 3060 Ti

| Model | Weights | Context Length | KV Cache | Baseline VRAM | oLLM GPU VRAM | oLLM Disk |
|-------|---------|----------------|----------|---------------|---------------|------------|
| qwen3-next-80B | 160 GB (bf16) | 50k | 20 GB | ~190 GB | ~7.5 GB | 180 GB |
| gpt-oss-20B | 13 GB (packed bf16) | 10k | 1.4 GB | ~40 GB | ~7.3GB | 15 GB |
| llama3-1B-chat | 2 GB (fp16) | 100k | 12.6 GB | ~16 GB | ~5 GB | 15 GB |
| llama3-3B-chat | 7 GB (fp16) | 100k | 34.1 GB | ~42 GB | ~5.3 GB | 42 GB |
| llama3-8B-chat | 16 GB (fp16) | 100k | 52.4 GB | ~71 GB | ~6.6 GB | 69 GB |

## Installation and Setup

### 1. Create Virtual Environment

```bash
# Create virtual environment
python3 -m venv ollm_env
source ollm_env/bin/activate  # Linux/Mac
# or
ollm_env\Scripts\activate  # Windows
```

### 2. Install oLLM

```bash
# Install via pip
pip install ollm

# Or install from source
git clone https://github.com/Mega4alik/ollm.git
cd ollm
pip install -e .
```

### 3. Install Additional Dependencies

```bash
# Install kvikio for your CUDA version
pip install kvikio-cu12  # For CUDA 12.x
# or
pip install kvikio-cu11  # For CUDA 11.x
```

### 4. Additional Installation for qwen3-next Model

```bash
# qwen3-next model requires special transformers version
pip install git+https://github.com/huggingface/transformers.git
```

## Basic Usage

### 1. Basic Inference Example

```python
from ollm import Inference, file_get_contents, TextStreamer

# Initialize model
o = Inference("llama3-1B-chat", device="cuda:0", logging=True)
o.ini_model(models_dir="./models/", force_download=False)

# Optional: Offload some layers to CPU for speed boost
o.offload_layers_to_cpu(layers_num=2)

# Set up KV cache (set to None if context is small)
past_key_values = o.DiskCache(cache_dir="./kv_cache/")

# Set up text streamer
text_streamer = TextStreamer(o.tokenizer, skip_prompt=True, skip_special_tokens=False)

# Compose messages
messages = [
    {"role": "system", "content": "You are a helpful AI assistant."},
    {"role": "user", "content": "List the planets."}
]

# Tokenize and generate
input_ids = o.tokenizer.apply_chat_template(
    messages, 
    reasoning_effort="minimal", 
    tokenize=True, 
    add_generation_prompt=True, 
    return_tensors="pt"
).to(o.device)

outputs = o.model.generate(
    input_ids=input_ids,
    past_key_values=past_key_values,
    max_new_tokens=500,
    streamer=text_streamer
).cpu()

# Decode result
answer = o.tokenizer.decode(outputs[0][input_ids.shape[-1]:], skip_special_tokens=False)
print(answer)
```

### 2. Run Command

```bash
# Run with CUDA memory allocation optimization
PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True python example.py
```

## Advanced Usage

### 1. Large Document Analysis

```python
def analyze_large_document(document_path, model_name="llama3-8B-chat"):
    """Function to analyze large documents"""
    
    # Initialize model
    o = Inference(model_name, device="cuda:0", logging=True)
    o.ini_model(models_dir="./models/", force_download=False)
    
    # Set up KV cache for large context
    past_key_values = o.DiskCache(cache_dir="./kv_cache/")
    
    # Read document
    document_content = file_get_contents(document_path)
    
    # Analysis prompt
    messages = [
        {
            "role": "system", 
            "content": "You are a document analysis expert. Analyze the given document and summarize key content while extracting important points."
        },
        {
            "role": "user", 
            "content": f"Please analyze the following document:\n\n{document_content}"
        }
    ]
    
    # Tokenize
    input_ids = o.tokenizer.apply_chat_template(
        messages, 
        tokenize=True, 
        add_generation_prompt=True, 
        return_tensors="pt"
    ).to(o.device)
    
    # Generate
    outputs = o.model.generate(
        input_ids=input_ids,
        past_key_values=past_key_values,
        max_new_tokens=1000,
        temperature=0.7,
        do_sample=True
    )
    
    # Return result
    result = o.tokenizer.decode(outputs[0][input_ids.shape[-1]:], skip_special_tokens=True)
    return result
```

### 2. Streaming Response Processing

```python
def stream_response(model_name, messages, max_tokens=500):
    """Function to handle streaming responses"""
    
    o = Inference(model_name, device="cuda:0", logging=True)
    o.ini_model(models_dir="./models/", force_download=False)
    
    # Set up text streamer
    text_streamer = TextStreamer(
        o.tokenizer, 
        skip_prompt=True, 
        skip_special_tokens=False
    )
    
    # Tokenize
    input_ids = o.tokenizer.apply_chat_template(
        messages, 
        tokenize=True, 
        add_generation_prompt=True, 
        return_tensors="pt"
    ).to(o.device)
    
    # Generate with streaming
    outputs = o.model.generate(
        input_ids=input_ids,
        max_new_tokens=max_tokens,
        streamer=text_streamer,
        temperature=0.7,
        do_sample=True
    )
    
    return outputs
```

## Real-World Use Cases

### 1. Contract and Regulatory Document Analysis

```python
def analyze_contract(contract_path):
    """Contract analysis"""
    messages = [
        {
            "role": "system",
            "content": "You are a legal document analysis expert. Analyze the contract's key clauses, risk factors, and rights and obligations clearly."
        },
        {
            "role": "user", 
            "content": f"Please analyze the following contract: {file_get_contents(contract_path)}"
        }
    ]
    return stream_response("llama3-8B-chat", messages, max_tokens=1000)
```

### 2. Medical Records Analysis

```python
def analyze_medical_records(records_path):
    """Medical records analysis"""
    messages = [
        {
            "role": "system",
            "content": "You are a medical data analysis expert. Analyze patient records and summarize key diagnoses, treatment processes, and precautions."
        },
        {
            "role": "user",
            "content": f"Please analyze the following medical records: {file_get_contents(records_path)}"
        }
    ]
    return stream_response("llama3-8B-chat", messages, max_tokens=1500)
```

### 3. Large Log File Analysis

```python
def analyze_logs(log_path):
    """Log file analysis"""
    messages = [
        {
            "role": "system",
            "content": "You are a system log analysis expert. Analyze logs to identify error patterns, performance issues, and security threats."
        },
        {
            "role": "user",
            "content": f"Please analyze the following log file: {file_get_contents(log_path)}"
        }
    ]
    return stream_response("llama3-8B-chat", messages, max_tokens=2000)
```

## Performance Optimization Tips

### 1. Memory Optimization

```python
# Save GPU memory by offloading layers
o.offload_layers_to_cpu(layers_num=4)  # Offload more layers to CPU

# Disk offloading for KV cache
past_key_values = o.DiskCache(cache_dir="./kv_cache/")
```

### 2. Speed Optimization

```python
# Optimize CUDA memory allocation
import os
os.environ['PYTORCH_CUDA_ALLOC_CONF'] = 'expandable_segments:True'

# Adjust batch size
batch_size = 1  # Adjust based on memory
```

### 3. Model Selection Guide

- **For fast responses**: llama3-1B-chat
- **For balanced performance**: llama3-8B-chat  
- **For highest quality**: qwen3-next-80B (requires more disk space)

## Troubleshooting

### 1. Out of Memory Error

```python
# Solution 1: Offload more layers to CPU
o.offload_layers_to_cpu(layers_num=6)

# Solution 2: Use smaller model
o = Inference("llama3-1B-chat", device="cuda:0")
```

### 2. Insufficient Disk Space

```python
# Disable KV cache (for small contexts)
past_key_values = None

# Or use smaller model
o = Inference("llama3-1B-chat", device="cuda:0")
```

### 3. Slow Performance

```python
# Optimize CUDA memory
os.environ['PYTORCH_CUDA_ALLOC_CONF'] = 'expandable_segments:True'

# Adjust layer offloading
o.offload_layers_to_cpu(layers_num=2)  # Offload fewer layers
```

## Conclusion

oLLM is an innovative tool that democratizes large-context LLM inference. With the ability to process 100k token contexts using just 8GB GPU, individual developers and small teams can now perform large document analysis.

Key advantages:
- **Cost efficiency**: Run large models without expensive GPUs
- **Flexibility**: Support for various models and context lengths
- **Practicality**: Tools that can be immediately applied to real work

Use oLLM to efficiently perform various large-scale text processing tasks such as contract analysis, medical record processing, and log analysis!

## References

- [oLLM GitHub Repository](https://github.com/Mega4alik/ollm)
- [HuggingFace Transformers](https://huggingface.co/docs/transformers/)
- [PyTorch CUDA Optimization Guide](https://pytorch.org/docs/stable/notes/cuda.html)
