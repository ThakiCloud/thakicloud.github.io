---
title: "Microsoft ArchScale: A Complete Guide to Scalable LLM Pretraining"
excerpt: "Building neural architecture research and large-scale model training pipelines with ArchScale. From mu-P++ scaling laws to 128K context training."
seo_title: "ArchScale LLM Pretraining Guide - Microsoft Framework - Thaki Cloud"
seo_description: "A complete guide to large language model pretraining with Microsoft ArchScale. Covers mu-P++ scaling, long context training, distributed processing, and performance evaluation."
date: 2025-07-19
last_modified_at: 2025-07-19
categories:
  - llmops
tags:
  - ArchScale
  - Microsoft
  - LLM
  - 사전훈련
  - 스케일링
  - μP++
  - 분산훈련
  - 롱컨텍스트
  - PyTorch
  - torchrun
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/en/llmops/archscale-scalable-pretraining-framework-guide/"
reading_time: true
lang: en
---

⏱️ **Estimated reading time**: 25 min

## Introduction

**Microsoft ArchScale** is a simple yet scalable pretraining framework designed for neural architecture research. It supports efficient training of models ranging from 110M to 3.3B parameters, and **mu-P++** scaling laws drastically cut the cost of hyperparameter tuning.

### Core Features of ArchScale

- 🎯 **Multiple architecture support**: Phi4-mini-Flash, SambaY, Transformer++, Mamba, and more
- 📊 **mu-P++ scaling**: Automatically transfers hyperparameters tuned on small models to large models
- 🚀 **Efficient training**: Optimization techniques including Flash Attention, RoPE, and fused kernels
- 📏 **Long context**: Variable-length training up to 128K sequence length
- 🔍 **Comprehensive evaluation**: RULER, Phonebook, reasoning benchmarks, and more

## Environment Setup and Installation

### 1. Docker Setup

ArchScale recommends using Docker for environment configuration:

```bash
# Clone the ArchScale repository
git clone https://github.com/microsoft/ArchScale.git
cd ArchScale

# Build the Docker image
docker build -t archscale:latest .

# Run the container with GPU support
docker run --gpus all -it --rm \
    -v $(pwd):/workspace \
    -v /path/to/data:/data \
    archscale:latest bash
```

### 2. Direct Installation

If you are not using Docker:

```bash
# Install dependencies
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
pip install lightning datasets transformers wandb

# Clone and install ArchScale
git clone https://github.com/microsoft/ArchScale.git
cd ArchScale
pip install -e .
```

### 3. Data Preparation

#### Tokenizing the SlimPajama Dataset

```bash
# Tokenize data following the Samba codebase reference
# Example: SlimPajama preprocessing
python scripts/prepare_data.py \
    --input_dir /path/to/slimpajama \
    --output_dir /path/to/tokenized_data \
    --tokenizer microsoft/Phi-4-mini-flash-reasoning \
    --context_length 8192
```

## Core Concept: mu-P++ Scaling Laws

### What is mu-P++?

**mu-P++ (Maximal Update Parameterization)** is a technique that automatically scales optimal hyperparameters as model size changes.

```python
# Example BaseHyperparameters configuration
from lit_gpt.config import BaseHyperparameters

# Hyperparameters based on d16 (depth=16)
base_hps = BaseHyperparameters(
    eta0=5e-4,          # learning rate
    b0=8388608,         # batch size (number of tokens)
    warmup_tokens0=25_165_824_000,  # warmup token count
    # other optimization-related parameters
)

# Automatically scaled when training d8 or d24 models
```

### Advantages of Scaling Laws

1. **Cost reduction**: Tune hyperparameters on small models and apply to large models
2. **Consistency**: Stable training regardless of model size
3. **Efficiency**: Significantly fewer experiments required

## Practical Training Guide

### 1. Phi4-mini-Flash Model Pretraining

Training the Phi4-mini-Flash model on 5T tokens of high-quality data:

```bash
#!/bin/bash
# phi4_pretrain.sh

export LIGHTNING_ARTIFACTS_DIR='/path/to/output_dir'
export MASTER_ADDR='master_node_ip'
export MASTER_PORT='29500'

# Distributed training with 1K GPUs (128 nodes x 8 GPUs)
torchrun --nnodes=128 --nproc_per_node=8 \
    --rdzv_backend=c10d \
    --rdzv_endpoint=${MASTER_ADDR}:${MASTER_PORT} \
    pretrain.py \
    --train_data_dir /path/to/phi4/data \
    --base_hps.eta0=5e-4 \
    --base_hps.b0=8388608 \
    --base_hps.warmup_tokens0=25_165_824_000 \
    --ctx_len 8192 \
    --max_tokens 5e12 \
    --resume="auto" \
    --train_model phi4miniflash \
    --depth 32 \
    --train_name scaling
```

### 2. SambaY Architecture Training (Recommended)

Training the cleaner SambaY model architecture:

```bash
#!/bin/bash
# sambay_pretrain.sh

torchrun --nnodes=128 --nproc_per_node=8 \
    --rdzv_backend=c10d \
    --rdzv_endpoint=${MASTER_ADDR}:${MASTER_PORT} \
    pretrain.py \
    --train_data_dir /path/to/data \
    --train_model sambayda \
    --depth 24 \
    --vocab_size 200064 \
    --train_name scaling_mup_tie \
    --ctx_len 8192 \
    --max_tokens 1e12
```

### 3. FLOPs Scaling Experiments

Training models of various sizes from 110M to 3.3B parameters:

```bash
#!/bin/bash
# flops_scaling.sh

export MASTER_ADDR='localhost'
export MASTER_PORT='29500'

# Experiments with various depths using 8 GPUs
for depth in 8 12 16 20 24; do
    echo "Training model with depth=${depth}"
    
    torchrun --nnodes=1 --nproc_per_node=8 \
        --rdzv_backend=c10d \
        --rdzv_endpoint=${MASTER_ADDR}:${MASTER_PORT} \
        pretrain.py \
        --train_data_dir /path/to/slim_pajama/data \
        --val_data_dir /path/to/slim_pajama/data \
        --train_model sambay \
        --depth ${depth} \
        --train_name scaling_mup \
        --max_tokens 1e11
done

# Generate scaling curve
python plot_flops_scaling.py \
    --log_dir /path/to/output_dir \
    --output_file flops_scaling_results.png
```

### 4. Data Scaling Experiments

Scaling from 100B to 600B tokens with a 1B parameter model:

```bash
#!/bin/bash
# data_scaling.sh

# Data scaling with 64 GPUs (8 nodes x 8 GPUs)
for tokens in 1e11 2e11 3e11 4e11 5e11 6e11; do
    echo "Training with ${tokens} tokens"
    
    torchrun --nnodes=8 --nproc_per_node=8 \
        --rdzv_backend=c10d \
        --rdzv_endpoint=${MASTER_ADDR}:${MASTER_PORT} \
        pretrain.py \
        --train_data_dir /path/to/slim_pajama/data \
        --val_data_dir /path/to/slim_pajama/data \
        --train_model transformer \
        --depth 16 \
        --max_tokens ${tokens} \
        --train_name scaling_mup_tie
done

# Analyze data scaling curve
python plot_data_scaling.py \
    --log_dir /path/to/output_dir \
    --output_file data_scaling_results.png
```

## Hyperparameter Tuning Strategy

### 1. Efficient Tuning with mu-P++

```bash
#!/bin/bash
# hyperparameter_sweep.sh

# Hyperparameter tuning based on d16, 1B model
# In practice, run fast experiments on d8 model
for lr in 4e-4 1e-4 1e-3; do
    for batch_size in 4194304 8388608 16777216; do
        echo "Testing lr=${lr}, batch_size=${batch_size}"
        
        torchrun --nnodes=1 --nproc_per_node=8 \
            --rdzv_backend=c10d \
            --rdzv_endpoint=${MASTER_ADDR}:${MASTER_PORT} \
            pretrain.py \
            --train_data_dir /path/to/slim_pajama/data \
            --val_data_dir /path/to/slim_pajama/data \
            --train_model transformer \
            --depth 8 \
            --base_hps.eta0=${lr} \
            --base_hps.b0=${batch_size} \
            --train_name "hp_sweep_lr${lr}_bs${batch_size}" \
            --max_tokens 1e10
    done
done
```

### 2. Analyzing Optimal Hyperparameters

```python
# analyze_hyperparameters.py
import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path

def analyze_sweep_results(log_dir):
    """Analyze hyperparameter sweep results"""
    results = []
    
    for log_file in Path(log_dir).glob("*/metrics.csv"):
        # Extract final loss for each experiment
        df = pd.read_csv(log_file)
        final_loss = df['val_loss'].min()
        
        # Extract hyperparameters from experiment name
        exp_name = log_file.parent.name
        lr = float(exp_name.split('lr')[1].split('_')[0])
        bs = int(exp_name.split('bs')[1])
        
        results.append({
            'learning_rate': lr,
            'batch_size': bs,
            'final_loss': final_loss
        })
    
    results_df = pd.DataFrame(results)
    
    # Find optimal hyperparameters
    best_idx = results_df['final_loss'].idxmin()
    best_config = results_df.iloc[best_idx]
    
    print(f"Optimal configuration:")
    print(f"Learning rate: {best_config['learning_rate']}")
    print(f"Batch size: {best_config['batch_size']}")
    print(f"Final loss: {best_config['final_loss']:.4f}")
    
    return results_df, best_config

if __name__ == "__main__":
    results_df, best_config = analyze_sweep_results("/path/to/sweep_logs")
```

## Long Context Training

### 1. 32K Context Training with ProLong-64K Data

```bash
#!/bin/bash
# long_context_training.sh

# Preprocess ProLong-64K data (pre-tokenize)
python scripts/preprocess_prolong.py \
    --input_dir /path/to/prolong_raw \
    --output_dir /path/to/prolong_tokenized \
    --max_length 65536 \
    --shuffle

# Train with 32K sequence length
torchrun --nnodes=1 --nproc_per_node=8 \
    --rdzv_backend=c10d \
    --rdzv_endpoint=${MASTER_ADDR}:${MASTER_PORT} \
    pretrain.py \
    --train_data_dir /path/to/prolong_tokenized \
    --val_data_dir /path/to/prolong_tokenized \
    --train_model transformer \
    --depth 16 \
    --ctx_len 32768 \
    --max_tokens 4e10 \
    --train_name scaling_mup_rbase_varlen
```

### 2. 128K Context Training (Maximum Scale)

```bash
#!/bin/bash
# ultra_long_context.sh

# Train 128K context in memory-saving mode
torchrun --nnodes=4 --nproc_per_node=8 \
    --rdzv_backend=c10d \
    --rdzv_endpoint=${MASTER_ADDR}:${MASTER_PORT} \
    pretrain.py \
    --train_data_dir /path/to/prolong_tokenized \
    --train_model transformer \
    --depth 20 \
    --ctx_len 131072 \
    --fsdp_save_mem=true \
    --train_name ultra_long_context \
    --max_tokens 2e10
```

### 3. Variable-Length Training Configuration

```python
# variable_length_config.py
from lit_gpt.config import Config

def setup_variable_length_training():
    """Configuration for variable-length training"""
    config = Config(
        # Base model configuration
        n_layer=16,
        n_head=16,
        n_embd=2048,
        
        # Variable-length settings
        variable_length=True,
        pack_sequences=True,
        eos_token_id=2,  # Document separation with EOS token
        
        # RoPE settings (for long context)
        rope_base=10000,  # default value
        rope_scaling=None,  # or {"type": "linear", "factor": 2.0}
        
        # Memory optimization
        use_gradient_checkpointing=True,
        attention_dropout=0.0,
        residual_dropout=0.1
    )
    
    return config
```

## Mamba Architecture Training

### 1. Installing Mamba-1

```bash
# Install variable-length Mamba
git clone https://github.com/zigzagcai/varlen_mamba.git --branch feat/add-cu_seqlens
cd varlen_mamba
pip install --no-build-isolation -e .
```

### 2. Training Mamba Models

```bash
#!/bin/bash
# mamba_training.sh

torchrun --nnodes=2 --nproc_per_node=8 \
    --rdzv_backend=c10d \
    --rdzv_endpoint=${MASTER_ADDR}:${MASTER_PORT} \
    pretrain.py \
    --train_data_dir /path/to/data \
    --train_model mamba \
    --depth 16 \
    --ctx_len 16384 \
    --train_name mamba_varlen \
    --max_tokens 1e11
```

## Comprehensive Evaluation System

### 1. Standard NLP Benchmarks

```bash
#!/bin/bash
# standard_evaluation.sh

python eval.py \
    --model ArchScale \
    --model_args pretrained=/path/to/checkpoint.pth,config="sambay_d16" \
    --tasks wikitext,lambada_openai,arc_easy,arc_challenge,winogrande,hellaswag,piqa,social_iqa \
    --device cuda \
    --batch_size 16 \
    --trust_remote_code \
    --output_path /path/to/eval_results.json
```

### 2. Long Context Evaluation

#### RULER Benchmark

```bash
#!/bin/bash
# ruler_evaluation.sh

# Needle-in-a-Haystack test
python eval.py \
    --model ArchScale \
    --model_args pretrained=/path/to/checkpoint.pth,config="sambay_d16",max_length=32768,tokenizer=Orkhan/llama-2-7b-absa \
    --metadata='{"max_seq_lengths":[32768]}' \
    --tasks niah_single_1,niah_single_2,niah_single_3 \
    --device cuda \
    --batch_size 4 \
    --trust_remote_code
```

#### Phonebook Evaluation

```bash
#!/bin/bash
# phonebook_evaluation.sh

python eval_phonebook.py \
    --checkpoint_path /path/to/checkpoint.pth \
    --config "sambay_d16" \
    --min_eval_len 1850 \
    --max_eval_len 32000 \
    --output_dir /path/to/phonebook_results \
    --eval_batch_size 4 \
    --num_samples 1000
```

### 3. Reasoning Evaluation

```bash
#!/bin/bash
# reasoning_evaluation.sh

# Math/science reasoning evaluation (requires vLLM backend)
./eval_reason.sh microsoft/Phi-4-mini-flash-reasoning aime24 /path/to/output_dir

# GSM8K math problem solving
./eval_reason.sh microsoft/Phi-4-mini-flash-reasoning gsm8k /path/to/output_dir

# MATH dataset evaluation
./eval_reason.sh microsoft/Phi-4-mini-flash-reasoning math /path/to/output_dir
```

### 4. Evaluation Result Analysis

```python
# evaluation_analysis.py
import json
import pandas as pd
import matplotlib.pyplot as plt

def analyze_evaluation_results(results_dir):
    """Comprehensive analysis of evaluation results"""
    
    # Load standard benchmark results
    with open(f"{results_dir}/standard_eval.json", 'r') as f:
        standard_results = json.load(f)
    
    # Load long context results
    with open(f"{results_dir}/phonebook_results.json", 'r') as f:
        phonebook_results = json.load(f)
    
    # Load reasoning results
    with open(f"{results_dir}/reasoning_results.json", 'r') as f:
        reasoning_results = json.load(f)
    
    # Organize results
    summary = {
        "Standard NLP": {
            "HellaSwag": standard_results.get("hellaswag", {}).get("acc_norm", 0),
            "PIQA": standard_results.get("piqa", {}).get("acc_norm", 0),
            "WinoGrande": standard_results.get("winogrande", {}).get("acc", 0),
            "ARC-E": standard_results.get("arc_easy", {}).get("acc_norm", 0),
            "ARC-C": standard_results.get("arc_challenge", {}).get("acc_norm", 0)
        },
        "Long Context": {
            "Phonebook (16K)": phonebook_results.get("16384", {}).get("accuracy", 0),
            "Phonebook (32K)": phonebook_results.get("32768", {}).get("accuracy", 0),
        },
        "Reasoning": {
            "GSM8K": reasoning_results.get("gsm8k", {}).get("accuracy", 0),
            "AIME": reasoning_results.get("aime24", {}).get("accuracy", 0),
            "MATH": reasoning_results.get("math", {}).get("accuracy", 0)
        }
    }
    
    # Visualize results
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    for idx, (category, scores) in enumerate(summary.items()):
        tasks = list(scores.keys())
        values = list(scores.values())
        
        axes[idx].bar(tasks, values)
        axes[idx].set_title(f"{category} Performance")
        axes[idx].set_ylabel("Accuracy")
        axes[idx].tick_params(axis='x', rotation=45)
    
    plt.tight_layout()
    plt.savefig(f"{results_dir}/evaluation_summary.png", dpi=300, bbox_inches='tight')
    
    return summary

# Example usage
if __name__ == "__main__":
    summary = analyze_evaluation_results("/path/to/eval_results")
    print("Evaluation Result Summary:")
    for category, scores in summary.items():
        print(f"\n{category}:")
        for task, score in scores.items():
            print(f"  {task}: {score:.3f}")
```

## Monitoring and Logging

### 1. Weights and Biases Integration

```python
# wandb_integration.py
import wandb
from datetime import datetime

def setup_wandb_logging(config):
    """Configure W&B logging"""
    
    # Initialize project
    wandb.init(
        project="archscale-pretraining",
        name=f"experiment_{datetime.now().strftime('%Y%m%d_%H%M%S')}",
        config={
            "model_architecture": config.train_model,
            "depth": config.depth,
            "context_length": config.ctx_len,
            "max_tokens": config.max_tokens,
            "learning_rate": config.base_hps.eta0,
            "batch_size": config.base_hps.b0,
            "scaling_method": "muP++" if "mup" in config.train_name else "standard"
        },
        tags=[config.train_model, f"depth_{config.depth}", config.train_name]
    )
    
    return wandb

def log_training_metrics(step, metrics):
    """Log training metrics"""
    wandb.log({
        "step": step,
        "train/loss": metrics["train_loss"],
        "train/perplexity": metrics["train_ppl"],
        "val/loss": metrics["val_loss"],
        "val/perplexity": metrics["val_ppl"],
        "lr": metrics["learning_rate"],
        "gpu_memory": metrics["gpu_memory_gb"],
        "tokens_per_second": metrics["tokens_per_sec"]
    })

def log_evaluation_results(eval_results):
    """Log evaluation results"""
    for task, result in eval_results.items():
        wandb.log({
            f"eval/{task}": result["accuracy"],
            f"eval/{task}_samples": result["num_samples"]
        })
```

### 2. System Monitoring

```python
# system_monitor.py
import psutil
import GPUtil
import torch
import time
from threading import Thread

class SystemMonitor:
    def __init__(self, log_interval=60):
        self.log_interval = log_interval
        self.monitoring = False
        
    def start_monitoring(self):
        """Start system monitoring"""
        self.monitoring = True
        monitor_thread = Thread(target=self._monitor_loop)
        monitor_thread.daemon = True
        monitor_thread.start()
        
    def stop_monitoring(self):
        """Stop system monitoring"""
        self.monitoring = False
        
    def _monitor_loop(self):
        """Monitoring loop"""
        while self.monitoring:
            metrics = self._collect_metrics()
            self._log_metrics(metrics)
            time.sleep(self.log_interval)
    
    def _collect_metrics(self):
        """Collect system metrics"""
        # CPU and memory usage
        cpu_percent = psutil.cpu_percent(interval=1)
        memory = psutil.virtual_memory()
        
        # GPU metrics
        gpus = GPUtil.getGPUs()
        gpu_metrics = []
        for gpu in gpus:
            gpu_metrics.append({
                "id": gpu.id,
                "utilization": gpu.load * 100,
                "memory_used": gpu.memoryUsed,
                "memory_total": gpu.memoryTotal,
                "temperature": gpu.temperature
            })
        
        # PyTorch memory (CUDA)
        torch_memory = {}
        if torch.cuda.is_available():
            for i in range(torch.cuda.device_count()):
                torch_memory[f"cuda_{i}"] = {
                    "allocated": torch.cuda.memory_allocated(i) / 1024**3,  # GB
                    "reserved": torch.cuda.memory_reserved(i) / 1024**3,    # GB
                    "max_allocated": torch.cuda.max_memory_allocated(i) / 1024**3
                }
        
        return {
            "timestamp": time.time(),
            "cpu_percent": cpu_percent,
            "memory_percent": memory.percent,
            "memory_available_gb": memory.available / 1024**3,
            "gpu_metrics": gpu_metrics,
            "torch_memory": torch_memory
        }
    
    def _log_metrics(self, metrics):
        """Log metrics"""
        print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] System Metrics:")
        print(f"  CPU: {metrics['cpu_percent']:.1f}%")
        print(f"  Memory: {metrics['memory_percent']:.1f}%")
        
        for gpu in metrics['gpu_metrics']:
            print(f"  GPU {gpu['id']}: {gpu['utilization']:.1f}% | "
                  f"{gpu['memory_used']:.1f}GB/{gpu['memory_total']:.1f}GB | "
                  f"{gpu['temperature']}°C")
        
        # Also log to W&B
        if wandb.run is not None:
            wandb.log({
                "system/cpu_percent": metrics['cpu_percent'],
                "system/memory_percent": metrics['memory_percent'],
                **{f"system/gpu_{gpu['id']}_util": gpu['utilization'] 
                   for gpu in metrics['gpu_metrics']},
                **{f"system/gpu_{gpu['id']}_memory": gpu['memory_used'] 
                   for gpu in metrics['gpu_metrics']}
            })
```

## Production Deployment Strategy

### 1. Model Conversion and Optimization

```python
# model_optimization.py
import torch
from transformers import AutoModelForCausalLM, AutoTokenizer
from lit_gpt.model import GPT
from lit_gpt.config import Config

def convert_archscale_to_hf(checkpoint_path, config_name, output_dir):
    """Convert ArchScale model to HuggingFace format"""
    
    # Load ArchScale model
    config = Config.from_name(config_name)
    model = GPT(config)
    
    checkpoint = torch.load(checkpoint_path, map_location="cpu")
    model.load_state_dict(checkpoint["model"])
    
    # Convert to HuggingFace format
    # (actual implementation varies by architecture)
    hf_model = convert_to_hf_format(model, config)
    
    # Save
    hf_model.save_pretrained(output_dir)
    
    return hf_model

def quantize_model(model_path, output_path, quantization_type="int8"):
    """Model quantization"""
    import torch.quantization as quant
    
    model = AutoModelForCausalLM.from_pretrained(model_path)
    
    if quantization_type == "int8":
        model = quant.quantize_dynamic(
            model, {torch.nn.Linear}, dtype=torch.qint8
        )
    elif quantization_type == "int4":
        # Using BitsAndBytes
        from transformers import BitsAndBytesConfig
        
        quantization_config = BitsAndBytesConfig(
            load_in_4bit=True,
            bnb_4bit_quant_type="nf4",
            bnb_4bit_compute_dtype=torch.float16
        )
        
        model = AutoModelForCausalLM.from_pretrained(
            model_path,
            quantization_config=quantization_config,
            device_map="auto"
        )
    
    model.save_pretrained(output_path)
    return model
```

### 2. Serving Optimization

```python
# serving_optimization.py
import vllm
from vllm import LLM, SamplingParams
import ray

class ArchScaleInferenceServer:
    def __init__(self, model_path, gpu_memory_utilization=0.9):
        """ArchScale model serving server"""
        
        # Initialize vLLM engine
        self.llm = LLM(
            model=model_path,
            gpu_memory_utilization=gpu_memory_utilization,
            max_model_len=32768,  # Long context support
            enable_prefix_caching=True,  # Speed up with prefix caching
            enforce_eager=False,  # CUDA graph optimization
        )
        
        # Default sampling parameters
        self.default_sampling_params = SamplingParams(
            temperature=0.7,
            top_p=0.9,
            max_tokens=1024,
            repetition_penalty=1.1
        )
    
    def generate(self, prompts, sampling_params=None):
        """Batch generation"""
        if sampling_params is None:
            sampling_params = self.default_sampling_params
            
        outputs = self.llm.generate(prompts, sampling_params)
        
        results = []
        for output in outputs:
            results.append({
                "prompt": output.prompt,
                "generated_text": output.outputs[0].text,
                "finish_reason": output.outputs[0].finish_reason,
                "tokens": len(output.outputs[0].token_ids)
            })
        
        return results
    
    async def generate_stream(self, prompt, sampling_params=None):
        """Streaming generation"""
        if sampling_params is None:
            sampling_params = self.default_sampling_params
            
        # vLLM streaming implementation
        for output in self.llm.generate_stream([prompt], sampling_params):
            yield output.outputs[0].text

# Scalable deployment using Ray Serve
@ray.serve.deployment(num_replicas=2)
class ArchScaleService:
    def __init__(self, model_path):
        self.inference_server = ArchScaleInferenceServer(model_path)
    
    async def __call__(self, request):
        prompts = request["prompts"]
        sampling_params = SamplingParams(**request.get("sampling_params", {}))
        
        results = self.inference_server.generate(prompts, sampling_params)
        return {"results": results}
```

### 3. Performance Benchmarking

```python
# performance_benchmark.py
import time
import asyncio
import aiohttp
import statistics
from concurrent.futures import ThreadPoolExecutor

class PerformanceBenchmark:
    def __init__(self, server_url="http://localhost:8000"):
        self.server_url = server_url
        
    async def single_request_latency(self, prompt, num_requests=100):
        """Measure single request latency"""
        latencies = []
        
        async with aiohttp.ClientSession() as session:
            for _ in range(num_requests):
                start_time = time.time()
                
                async with session.post(
                    f"{self.server_url}/generate",
                    json={"prompts": [prompt]}
                ) as response:
                    await response.json()
                
                latency = time.time() - start_time
                latencies.append(latency)
        
        return {
            "mean_latency": statistics.mean(latencies),
            "median_latency": statistics.median(latencies),
            "p95_latency": sorted(latencies)[int(0.95 * len(latencies))],
            "p99_latency": sorted(latencies)[int(0.99 * len(latencies))]
        }
    
    async def throughput_test(self, prompt, concurrent_requests=50, duration_seconds=60):
        """Measure throughput"""
        completed_requests = 0
        start_time = time.time()
        
        async def worker():
            nonlocal completed_requests
            async with aiohttp.ClientSession() as session:
                while time.time() - start_time < duration_seconds:
                    try:
                        async with session.post(
                            f"{self.server_url}/generate",
                            json={"prompts": [prompt]}
                        ) as response:
                            await response.json()
                            completed_requests += 1
                    except Exception as e:
                        print(f"Request failed: {e}")
        
        # Execute concurrent requests
        tasks = [worker() for _ in range(concurrent_requests)]
        await asyncio.gather(*tasks)
        
        actual_duration = time.time() - start_time
        throughput = completed_requests / actual_duration
        
        return {
            "total_requests": completed_requests,
            "duration_seconds": actual_duration,
            "requests_per_second": throughput
        }
    
    def token_generation_speed(self, prompts, output_lengths):
        """Measure token generation speed"""
        total_tokens = 0
        total_time = 0
        
        for prompt, expected_length in zip(prompts, output_lengths):
            start_time = time.time()
            
            # Actual request (synchronous)
            import requests
            response = requests.post(
                f"{self.server_url}/generate",
                json={
                    "prompts": [prompt],
                    "sampling_params": {"max_tokens": expected_length}
                }
            )
            
            generation_time = time.time() - start_time
            actual_tokens = len(response.json()["results"][0]["generated_text"].split())
            
            total_tokens += actual_tokens
            total_time += generation_time
        
        return {
            "total_tokens": total_tokens,
            "total_time": total_time,
            "tokens_per_second": total_tokens / total_time
        }

# Example benchmark run
async def run_benchmark():
    benchmark = PerformanceBenchmark()
    
    test_prompt = "Explain the concept of machine learning in simple terms:"
    
    # Latency test
    latency_results = await benchmark.single_request_latency(test_prompt)
    print("Latency Results:", latency_results)
    
    # Throughput test
    throughput_results = await benchmark.throughput_test(test_prompt)
    print("Throughput Results:", throughput_results)
    
    # Token generation speed test
    speed_results = benchmark.token_generation_speed([test_prompt], [100])
    print("Generation Speed:", speed_results)

if __name__ == "__main__":
    asyncio.run(run_benchmark())
```

## Production Operations Guide

### 1. Checkpoint Management

```python
# checkpoint_manager.py
import torch
import shutil
from pathlib import Path
import json
from datetime import datetime

class CheckpointManager:
    def __init__(self, base_dir, max_checkpoints=5):
        self.base_dir = Path(base_dir)
        self.max_checkpoints = max_checkpoints
        self.metadata_file = self.base_dir / "checkpoint_metadata.json"
        
    def save_checkpoint(self, model, optimizer, scheduler, step, metrics):
        """Save checkpoint"""
        checkpoint_dir = self.base_dir / f"checkpoint_{step}"
        checkpoint_dir.mkdir(parents=True, exist_ok=True)
        
        # Save model state
        torch.save({
            "model": model.state_dict(),
            "optimizer": optimizer.state_dict(),
            "scheduler": scheduler.state_dict(),
            "step": step,
            "metrics": metrics
        }, checkpoint_dir / "model.pth")
        
        # Save metadata
        metadata = {
            "step": step,
            "timestamp": datetime.now().isoformat(),
            "metrics": metrics,
            "path": str(checkpoint_dir)
        }
        
        self._update_metadata(metadata)
        self._cleanup_old_checkpoints()
        
        return checkpoint_dir
    
    def load_latest_checkpoint(self):
        """Load the latest checkpoint"""
        if not self.metadata_file.exists():
            return None
            
        with open(self.metadata_file, 'r') as f:
            all_metadata = json.load(f)
        
        if not all_metadata:
            return None
            
        # Find the latest checkpoint
        latest = max(all_metadata, key=lambda x: x["step"])
        checkpoint_path = Path(latest["path"]) / "model.pth"
        
        if checkpoint_path.exists():
            return torch.load(checkpoint_path), latest
        
        return None
    
    def _update_metadata(self, new_metadata):
        """Update metadata"""
        all_metadata = []
        
        if self.metadata_file.exists():
            with open(self.metadata_file, 'r') as f:
                all_metadata = json.load(f)
        
        all_metadata.append(new_metadata)
        
        with open(self.metadata_file, 'w') as f:
            json.dump(all_metadata, f, indent=2)
    
    def _cleanup_old_checkpoints(self):
        """Remove old checkpoints"""
        with open(self.metadata_file, 'r') as f:
            all_metadata = json.load(f)
        
        if len(all_metadata) <= self.max_checkpoints:
            return
        
        # Delete oldest checkpoints
        sorted_metadata = sorted(all_metadata, key=lambda x: x["step"])
        to_remove = sorted_metadata[:-self.max_checkpoints]
        
        for metadata in to_remove:
            checkpoint_path = Path(metadata["path"])
            if checkpoint_path.exists():
                shutil.rmtree(checkpoint_path)
        
        # Update metadata
        remaining_metadata = sorted_metadata[-self.max_checkpoints:]
        with open(self.metadata_file, 'w') as f:
            json.dump(remaining_metadata, f, indent=2)
```

### 2. Automated Experiment Management

```python
# experiment_manager.py
import yaml
import subprocess
import time
from pathlib import Path
import wandb

class ExperimentManager:
    def __init__(self, config_file):
        with open(config_file, 'r') as f:
            self.config = yaml.safe_load(f)
        
        self.experiments = self.config["experiments"]
        self.base_command = self.config["base_command"]
        
    def run_experiment_suite(self):
        """Run the full experiment suite"""
        results = {}
        
        for exp_name, exp_config in self.experiments.items():
            print(f"Starting experiment: {exp_name}")
            
            # Run experiment
            result = self._run_single_experiment(exp_name, exp_config)
            results[exp_name] = result
            
            # Log result
            self._log_experiment_result(exp_name, result)
        
        # Summarize all results
        self._generate_summary_report(results)
        
        return results
    
    def _run_single_experiment(self, exp_name, exp_config):
        """Run a single experiment"""
        
        # Build command
        command = self._build_command(exp_config)
        
        # Measure execution time
        start_time = time.time()
        
        try:
            # Run experiment
            result = subprocess.run(
                command,
                shell=True,
                capture_output=True,
                text=True,
                timeout=exp_config.get("timeout", 3600*24)  # 24 hours default
            )
            
            duration = time.time() - start_time
            
            if result.returncode == 0:
                # Successful experiment
                metrics = self._extract_metrics(result.stdout)
                return {
                    "status": "success",
                    "duration": duration,
                    "metrics": metrics,
                    "stdout": result.stdout[-1000:],  # Last 1000 chars only
                    "stderr": result.stderr
                }
            else:
                # Failed experiment
                return {
                    "status": "failed",
                    "duration": duration,
                    "error": result.stderr,
                    "returncode": result.returncode
                }
                
        except subprocess.TimeoutExpired:
            return {
                "status": "timeout",
                "duration": time.time() - start_time,
                "error": "Experiment timed out"
            }
        except Exception as e:
            return {
                "status": "error",
                "duration": time.time() - start_time,
                "error": str(e)
            }
    
    def _build_command(self, exp_config):
        """Build experiment command"""
        command_parts = [self.base_command]
        
        for key, value in exp_config.items():
            if key in ["timeout", "description"]:
                continue
                
            if isinstance(value, bool):
                if value:
                    command_parts.append(f"--{key}")
            else:
                command_parts.append(f"--{key} {value}")
        
        return " ".join(command_parts)
    
    def _extract_metrics(self, stdout):
        """Extract metrics from output"""
        metrics = {}
        
        for line in stdout.split('\n'):
            if 'final_loss:' in line:
                try:
                    metrics['final_loss'] = float(line.split('final_loss:')[1].strip())
                except:
                    pass
            elif 'best_val_loss:' in line:
                try:
                    metrics['best_val_loss'] = float(line.split('best_val_loss:')[1].strip())
                except:
                    pass
        
        return metrics

# Example experiment configuration (experiments.yaml)
experiments_yaml = """
base_command: "torchrun --nnodes=1 --nproc_per_node=8 pretrain.py"

experiments:
  small_lr_sweep_1:
    train_data_dir: "/path/to/data"
    train_model: "transformer"
    depth: 8
    base_hps.eta0: 1e-4
    max_tokens: 1e10
    train_name: "lr_sweep_1e4"
    timeout: 7200
    description: "Learning rate 1e-4 test"
    
  small_lr_sweep_2:
    train_data_dir: "/path/to/data"
    train_model: "transformer"
    depth: 8
    base_hps.eta0: 5e-4
    max_tokens: 1e10
    train_name: "lr_sweep_5e4"
    timeout: 7200
    description: "Learning rate 5e-4 test"
    
  small_lr_sweep_3:
    train_data_dir: "/path/to/data"
    train_model: "transformer"
    depth: 8
    base_hps.eta0: 1e-3
    max_tokens: 1e10
    train_name: "lr_sweep_1e3"
    timeout: 7200
    description: "Learning rate 1e-3 test"
"""
```

## Troubleshooting Guide

### 1. Common Errors and Solutions

```python
# troubleshooting.py

class ArchScaleTroubleshooter:
    @staticmethod
    def diagnose_oom_error():
        """Diagnose and resolve OOM errors"""
        print("Diagnosing Out of Memory (OOM) error:")
        print("1. Check GPU memory:")
        print("   nvidia-smi")
        print("\n2. Reduce batch size:")
        print("   --base_hps.b0=4194304  # Half the default")
        print("\n3. Enable Gradient Checkpointing:")
        print("   --gradient_checkpointing=true")
        print("\n4. FSDP memory-saving mode:")
        print("   --fsdp_save_mem=true")
        print("\n5. Reduce context length:")
        print("   --ctx_len=4096  # Half of default 8192")
    
    @staticmethod
    def diagnose_slow_training():
        """Diagnose slow training"""
        print("Diagnosing slow training:")
        print("1. Check data loading bottleneck:")
        print("   --num_workers=8  # Increase data loader workers")
        print("\n2. Enable Mixed Precision:")
        print("   --precision=bf16")
        print("\n3. Use Compiled mode:")
        print("   --compile=true")
        print("\n4. Verify Flash Attention:")
        print("   pip install flash-attn")
        print("\n5. Pre-tokenize dataset:")
        print("   Use pre-tokenized data")
    
    @staticmethod
    def diagnose_distributed_issues():
        """Diagnose distributed training issues"""
        print("Diagnosing distributed training issues:")
        print("1. Check network connectivity:")
        print("   ping $MASTER_ADDR")
        print("\n2. Verify port availability:")
        print("   netstat -an | grep $MASTER_PORT")
        print("\n3. Set NCCL environment variables:")
        print("   export NCCL_DEBUG=INFO")
        print("   export NCCL_IB_DISABLE=1  # If InfiniBand issues")
        print("\n4. Check firewall settings:")
        print("   Open port range 29500-29510")
        print("\n5. Synchronize time across nodes:")
        print("   ntpdate -s time.nist.gov")
```

### 2. Performance Optimization Checklist

```bash
#!/bin/bash
# performance_optimization_checklist.sh

echo "ArchScale Performance Optimization Checklist"

echo "1. Hardware configuration check:"
echo "   - GPU memory: 24GB+ recommended"
echo "   - GPU interconnect: NVLink or PCIe 4.0+"
echo "   - Storage: NVMe SSD recommended"
echo "   - Network: 10Gbps+ (for distributed training)"

echo -e "\n2. Software optimization:"
echo "   - Use PyTorch 2.0+"
echo "   - CUDA 12.1+ recommended"
echo "   - Install Flash Attention 2.0"
echo "   - Consider installing xFormers"

echo -e "\n3. Training configuration optimization:"
echo "   - Use Mixed Precision (bf16)"
echo "   - Adjust Gradient Accumulation"
echo "   - Tune DataLoader num_workers"
echo "   - Adjust prefetch factor"

echo -e "\n4. Memory optimization:"
echo "   - Use FSDP (Fully Sharded Data Parallel)"
echo "   - Enable Gradient Checkpointing"
echo "   - Consider Model Sharding"
echo "   - CPU Offloading (if needed)"

echo -e "\n5. Data pipeline:"
echo "   - Use pre-tokenized data"
echo "   - Enable data caching"
echo "   - Parallel data loading"
echo "   - Use compressed data format"
```

## Conclusion

**Microsoft ArchScale** is a robust and flexible framework for large-scale language model pretraining. Through the content covered in this guide, you can achieve the following outcomes:

### Key Results

1. **Cost-efficient research**: Cut hyperparameter tuning costs by 90% with mu-P++ scaling
2. **Scalable architecture**: Consistent training pipeline from 110M to billions of parameters
3. **Long context support**: Efficient training up to 128K tokens
4. **Comprehensive evaluation**: Multi-dimensional performance assessment through RULER, Phonebook, and reasoning benchmarks

### Practical Application Points

- **Startups**: Effective model research with limited resources
- **Research institutions**: Architecture experiments and scaling law research across diverse configurations
- **Enterprises**: Efficient pretraining of domain-specific models
- **Developers**: Building production systems using the latest LLM techniques

### Next Steps

1. **Small-scale experiments**: Start with 8 GPUs and validate mu-P++ scaling
2. **Architecture exploration**: Compare SambaY, Mamba, and other architectures
3. **Production optimization**: Serving optimization through vLLM and quantization
4. **Community contribution**: Contribute improvements to [ArchScale GitHub](https://github.com/microsoft/ArchScale)

ArchScale gives you the tools to develop your own next-generation language model efficiently.

---

**References**:
- [Microsoft ArchScale GitHub](https://github.com/microsoft/ArchScale)
- [mu-P++ Paper](https://arxiv.org/abs/2507.06607)
- [Flash Attention Paper](https://arxiv.org/abs/2205.14135)
- [RULER Benchmark](https://arxiv.org/abs/2404.06654)
