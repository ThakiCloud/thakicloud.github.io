---
title: "Complete Guide to LLM Fine-tuning with Unsloth Docker: From Setup to Production"
excerpt: "Learn how to fine-tune large language models efficiently using Unsloth's Docker container. This comprehensive tutorial covers installation, configuration, and practical examples for local LLM training."
seo_title: "Unsloth Docker LLM Fine-tuning Tutorial - Complete Guide 2025"
seo_description: "Master LLM fine-tuning with Unsloth Docker. Step-by-step tutorial covering installation, GPU setup, Jupyter Lab access, and practical training examples for efficient model customization."
date: 2025-10-03
categories:
  - tutorials
tags:
  - unsloth
  - docker
  - llm
  - fine-tuning
  - machine-learning
  - gpu
  - jupyter
  - nvidia
author_profile: true
toc: true
toc_label: "Table of Contents"
lang: en
permalink: /en/tutorials/unsloth-docker-llm-training-tutorial/
canonical_url: "https://thakicloud.github.io/en/tutorials/unsloth-docker-llm-training-tutorial/"
---

⏱️ **Estimated Reading Time**: 12 minutes

## Introduction

Fine-tuning large language models (LLMs) has become increasingly important for creating specialized AI applications. However, setting up the proper environment for LLM training can be challenging due to complex dependencies and potential conflicts. Unsloth's Docker solution eliminates these issues by providing a pre-configured, stable environment for efficient LLM fine-tuning.

In this comprehensive tutorial, we'll explore how to use Unsloth's Docker image to fine-tune LLMs locally, covering everything from initial setup to practical training examples.

## What is Unsloth?

Unsloth is a powerful framework designed to accelerate LLM fine-tuning while reducing memory usage. It provides significant performance improvements over traditional fine-tuning methods, making it possible to train larger models on consumer hardware.

### Key Benefits of Unsloth Docker

- **Dependency Management**: Eliminates "dependency hell" with a fully contained environment
- **System Safety**: Runs without root privileges, keeping your system clean
- **Portability**: Works consistently across different platforms and setups
- **Pre-configured Environment**: Includes all necessary tools and libraries
- **Regular Updates**: Frequently updated with the latest improvements

## Prerequisites

Before starting, ensure you have:

- **NVIDIA GPU**: Required for efficient training (RTX 3060 or better recommended)
- **Docker**: Installed and running on your system
- **NVIDIA Container Toolkit**: For GPU access within containers
- **Sufficient Storage**: At least 50GB free space for models and data
- **RAM**: 16GB or more recommended

## Step 1: Installing Docker and NVIDIA Container Toolkit

### Installing Docker

For Linux systems:
```bash
# Update package index
sudo apt-get update

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

For other systems, visit the [official Docker installation guide](https://docs.docker.com/get-docker/).

### Installing NVIDIA Container Toolkit

The NVIDIA Container Toolkit enables GPU access within Docker containers:

```bash
# Set version (use latest stable version)
export NVIDIA_CONTAINER_TOOLKIT_VERSION=1.17.8-1

# Install NVIDIA Container Toolkit
sudo apt-get update && sudo apt-get install -y \
  nvidia-container-toolkit=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
  nvidia-container-toolkit-base=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
  libnvidia-container-tools=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
  libnvidia-container1=${NVIDIA_CONTAINER_TOOLKIT_VERSION}

# Restart Docker daemon
sudo systemctl restart docker
```

### Verify Installation

Test your GPU access:
```bash
# Test NVIDIA Docker integration
docker run --rm --gpus all nvidia/cuda:11.8-base-ubuntu20.04 nvidia-smi
```

## Step 2: Running the Unsloth Docker Container

### Basic Container Setup

Create a working directory and run the container:

```bash
# Create working directory
mkdir -p ~/unsloth-workspace
cd ~/unsloth-workspace

# Run Unsloth container with basic configuration
docker run -d \
  --name unsloth-training \
  -e JUPYTER_PASSWORD="mypassword" \
  -p 8888:8888 \
  -p 2222:22 \
  -v $(pwd)/work:/workspace/work \
  --gpus all \
  unsloth/unsloth
```

### Advanced Configuration

For production use, consider this enhanced setup:

```bash
# Generate SSH key for secure access
ssh-keygen -t rsa -b 4096 -f ~/.ssh/unsloth_key

# Run container with advanced settings
docker run -d \
  --name unsloth-production \
  -e JUPYTER_PORT=8000 \
  -e JUPYTER_PASSWORD="secure_password_2024" \
  -e "SSH_KEY=$(cat ~/.ssh/unsloth_key.pub)" \
  -e USER_PASSWORD="unsloth2024" \
  -p 8000:8000 \
  -p 2222:22 \
  -v $(pwd)/work:/workspace/work \
  -v $(pwd)/models:/workspace/models \
  -v $(pwd)/datasets:/workspace/datasets \
  --gpus all \
  --restart unless-stopped \
  unsloth/unsloth
```

## Step 3: Accessing Jupyter Lab

### Web Interface Access

1. Open your browser and navigate to `http://localhost:8888`
2. Enter the password you set (default: "unsloth")
3. You'll see the Jupyter Lab interface with pre-loaded notebooks

### SSH Access (Optional)

For command-line access:
```bash
# Connect via SSH
ssh -i ~/.ssh/unsloth_key -p 2222 unsloth@localhost
```

## Step 4: Understanding the Container Structure

The Unsloth container is organized as follows:

```
/workspace/
├── work/                    # Your mounted work directory
├── unsloth-notebooks/       # Example fine-tuning notebooks
├── models/                  # Model storage (if mounted)
└── datasets/               # Dataset storage (if mounted)

/home/unsloth/              # User home directory
```

## Step 5: Your First Fine-tuning Example

Let's create a simple fine-tuning example using Llama-3.

### Create a New Notebook

1. In Jupyter Lab, create a new notebook
2. Add the following code cells:

```python
# Cell 1: Install and import dependencies
from unsloth import FastLanguageModel
import torch

# Cell 2: Load the model
model, tokenizer = FastLanguageModel.from_pretrained(
    model_name="unsloth/llama-3-8b-bnb-4bit",
    max_seq_length=2048,
    dtype=None,
    load_in_4bit=True,
)

# Cell 3: Configure LoRA
model = FastLanguageModel.get_peft_model(
    model,
    r=16,
    target_modules=["q_proj", "k_proj", "v_proj", "o_proj",
                    "gate_proj", "up_proj", "down_proj"],
    lora_alpha=16,
    lora_dropout=0,
    bias="none",
    use_gradient_checkpointing="unsloth",
    random_state=3407,
    use_rslora=False,
    loftq_config=None,
)

# Cell 4: Prepare dataset
alpaca_prompt = """Below is an instruction that describes a task, paired with an input that provides further context. Write a response that appropriately completes the request.

### Instruction:
{}

### Input:
{}

### Response:
{}"""

def formatting_prompts_func(examples):
    instructions = examples["instruction"]
    inputs       = examples["input"]
    outputs      = examples["output"]
    texts = []
    for instruction, input, output in zip(instructions, inputs, outputs):
        text = alpaca_prompt.format(instruction, input, output) + tokenizer.eos_token
        texts.append(text)
    return { "text" : texts, }

# Load dataset
from datasets import load_dataset
dataset = load_dataset("yahma/alpaca-cleaned", split="train")
dataset = dataset.map(formatting_prompts_func, batched=True)

# Cell 5: Training configuration
from trl import SFTTrainer
from transformers import TrainingArguments

trainer = SFTTrainer(
    model=model,
    tokenizer=tokenizer,
    train_dataset=dataset,
    dataset_text_field="text",
    max_seq_length=2048,
    dataset_num_proc=2,
    packing=False,
    args=TrainingArguments(
        per_device_train_batch_size=2,
        gradient_accumulation_steps=4,
        warmup_steps=5,
        max_steps=60,
        learning_rate=2e-4,
        fp16=not torch.cuda.is_bf16_supported(),
        bf16=torch.cuda.is_bf16_supported(),
        logging_steps=1,
        optim="adamw_8bit",
        weight_decay=0.01,
        lr_scheduler_type="linear",
        seed=3407,
        output_dir="outputs",
    ),
)

# Cell 6: Start training
trainer_stats = trainer.train()
```

### Monitor Training Progress

The training process will display progress bars and loss metrics. Monitor these to ensure training is proceeding correctly.

## Step 6: Saving and Using Your Fine-tuned Model

### Save in Different Formats

```python
# Save as Hugging Face format
model.save_pretrained("my_finetuned_model")
tokenizer.save_pretrained("my_finetuned_model")

# Save as GGUF for Ollama
model.save_pretrained_gguf("my_model", tokenizer, quantization_method="q4_k_m")

# Save for VLLM
model.save_pretrained_merged("my_model_vllm", tokenizer, save_method="merged_16bit")
```

### Test Your Model

```python
# Test inference
FastLanguageModel.for_inference(model)

inputs = tokenizer(
    [alpaca_prompt.format(
        "What is the capital of France?",
        "",
        ""
    )], return_tensors="pt").to("cuda")

outputs = model.generate(**inputs, max_new_tokens=64, use_cache=True)
print(tokenizer.batch_decode(outputs))
```

## Advanced Configuration Options

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `JUPYTER_PASSWORD` | Jupyter Lab password | `unsloth` |
| `JUPYTER_PORT` | Jupyter Lab port | `8888` |
| `SSH_KEY` | SSH public key | `None` |
| `USER_PASSWORD` | User password for sudo | `unsloth` |

### GPU Memory Optimization

For systems with limited GPU memory:

```python
# Use smaller batch sizes
per_device_train_batch_size=1
gradient_accumulation_steps=8

# Enable gradient checkpointing
use_gradient_checkpointing="unsloth"

# Use 4-bit quantization
load_in_4bit=True
```

### Multi-GPU Training

For systems with multiple GPUs:

```bash
# Run container with all GPUs
docker run -d \
  --gpus all \
  # ... other parameters
  unsloth/unsloth

# In training script, use DataParallel
model = torch.nn.DataParallel(model)
```

## Troubleshooting Common Issues

### GPU Not Detected

```bash
# Check GPU availability
nvidia-smi

# Verify Docker GPU access
docker run --rm --gpus all nvidia/cuda:11.8-base-ubuntu20.04 nvidia-smi
```

### Memory Issues

- Reduce batch size
- Enable gradient checkpointing
- Use 4-bit quantization
- Clear GPU cache: `torch.cuda.empty_cache()`

### Container Access Issues

```bash
# Check container status
docker ps -a

# View container logs
docker logs unsloth-training

# Restart container
docker restart unsloth-training
```

## Best Practices

### 1. Data Management

- Use volume mounts for persistent storage
- Organize datasets in dedicated directories
- Backup important models regularly

### 2. Resource Monitoring

```python
# Monitor GPU usage
import GPUtil
GPUtil.showUtilization()

# Monitor system resources
import psutil
print(f"CPU: {psutil.cpu_percent()}%")
print(f"RAM: {psutil.virtual_memory().percent}%")
```

### 3. Security Considerations

- Use strong passwords for Jupyter access
- Implement SSH key authentication
- Run containers as non-root users
- Regularly update the Unsloth image

### 4. Performance Optimization

- Use appropriate batch sizes for your GPU
- Enable mixed precision training
- Utilize gradient accumulation for effective larger batch sizes
- Monitor training metrics to prevent overfitting

## Production Deployment

### Docker Compose Setup

Create a `docker-compose.yml` for easier management:

```yaml
version: '3.8'
services:
  unsloth:
    image: unsloth/unsloth
    container_name: unsloth-production
    environment:
      - JUPYTER_PASSWORD=secure_password
      - JUPYTER_PORT=8888
      - USER_PASSWORD=unsloth2024
    ports:
      - "8888:8888"
      - "2222:22"
    volumes:
      - ./work:/workspace/work
      - ./models:/workspace/models
      - ./datasets:/workspace/datasets
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
    restart: unless-stopped
```

### Automated Training Pipeline

Create a training script for automated workflows:

```python
#!/usr/bin/env python3
"""
Automated Unsloth training pipeline
"""
import argparse
import json
from pathlib import Path
from unsloth import FastLanguageModel
from transformers import TrainingArguments
from trl import SFTTrainer

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--config", required=True, help="Training config JSON file")
    args = parser.parse_args()
    
    # Load configuration
    with open(args.config) as f:
        config = json.load(f)
    
    # Initialize model
    model, tokenizer = FastLanguageModel.from_pretrained(
        model_name=config["model_name"],
        max_seq_length=config["max_seq_length"],
        load_in_4bit=config.get("load_in_4bit", True)
    )
    
    # Configure LoRA
    model = FastLanguageModel.get_peft_model(
        model,
        r=config["lora_r"],
        target_modules=config["target_modules"],
        lora_alpha=config["lora_alpha"],
        lora_dropout=config["lora_dropout"],
        bias="none",
        use_gradient_checkpointing="unsloth"
    )
    
    # Training logic here...
    print("Training completed successfully!")

if __name__ == "__main__":
    main()
```

## Conclusion

Unsloth Docker provides an excellent solution for LLM fine-tuning, eliminating setup complexity while maintaining performance and flexibility. By following this tutorial, you now have:

- A fully configured Unsloth environment
- Understanding of basic and advanced configuration options
- Practical experience with fine-tuning workflows
- Knowledge of best practices and troubleshooting techniques

The containerized approach ensures reproducible results and makes it easy to scale your fine-tuning operations across different environments.

### Next Steps

1. **Experiment with Different Models**: Try fine-tuning various model architectures
2. **Explore Advanced Techniques**: Investigate reinforcement learning and DPO training
3. **Optimize for Production**: Implement automated training pipelines
4. **Monitor Performance**: Set up comprehensive logging and monitoring

### Additional Resources

- [Unsloth Official Documentation](https://docs.unsloth.ai/)
- [Unsloth GitHub Repository](https://github.com/unslothai/unsloth)
- [Docker Best Practices](https://docs.docker.com/develop/best-practices/)
- [NVIDIA Container Toolkit Documentation](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/)

Happy fine-tuning! 🚀
