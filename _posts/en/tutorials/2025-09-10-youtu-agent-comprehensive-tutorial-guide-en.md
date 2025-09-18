---
title: "Youtu-Agent: Complete Tutorial Guide for Building Powerful AI Agents"
excerpt: "Master Youtu-Agent, Tencent's open-source agent framework built on OpenAI-agents. Learn installation, configuration, and build real-world AI applications with web search, SVG generation, and evaluation capabilities."
seo_title: "Youtu-Agent Tutorial: Build AI Agents with Open-Source Models - Thaki Cloud"
seo_description: "Complete guide to Youtu-Agent framework: installation, setup, examples, and benchmarking. Build powerful AI agents with web search, automation, and async processing capabilities."
date: 2025-09-10
categories:
  - tutorials
tags:
  - youtu-agent
  - ai-agents
  - python
  - openai-agents
  - agent-framework
  - machine-learning
  - automation
author_profile: true
toc: true
toc_label: "Table of Contents"
lang: en
permalink: /en/tutorials/youtu-agent-comprehensive-tutorial-guide/
canonical_url: "https://thakicloud.github.io/en/tutorials/youtu-agent-comprehensive-tutorial-guide/"
---

⏱️ **Estimated Reading Time**: 15 minutes

## Introduction

In the rapidly evolving landscape of AI development, building robust and scalable agent frameworks has become crucial for researchers and developers alike. [Youtu-Agent](https://github.com/TencentCloudADP/youtu-agent), developed by Tencent Youtu Lab, emerges as a simple yet powerful solution that delivers exceptional performance with open-source models.

### What is Youtu-Agent?

Youtu-Agent is an open-source agent framework designed to provide significant value across different user groups - from AI researchers and LLM trainers to application developers and enthusiasts. Built on the foundation of `openai-agents` SDK, it inherits essential capabilities like streaming, tracing, and agent-loop functionalities while maintaining compatibility with both `responses` and `chat.completions` APIs.

### Key Features

**🚀 Performance & Accessibility**
- **Open-source model support & low-cost**: Promotes accessibility and cost-effectiveness for various applications
- **Fully asynchronous**: Enables high-performance and efficient execution, especially beneficial for evaluating benchmarks
- **Built on openai-agents**: Leverages proven foundation with streaming, tracing, and agent-loop capabilities

**🔧 Automation & Configuration**
- **YAML-based configuration**: Structured and easily manageable agent configurations
- **Automatic agent generation**: Agent configurations can be automatically generated based on user requirements
- **Tool generation & optimization**: Supports tool evaluation and automated optimization

**📊 Analysis & Debugging**
- **Tracing & analysis system**: Beyond OTEL, the `DBTracingProcessor` system provides in-depth analysis of tool calls and agent trajectories
- **Visual debugging**: Rich toolset and visual tracing tools make development intuitive

### Use Cases

Youtu-Agent excels in various practical applications:
- **Deep/Wide research**: Comprehensive search-oriented tasks
- **Webpage generation**: Creating web pages based on specific inputs
- **Trajectory collection**: Supporting data collection for training and research
- **Automation workflows**: Complex multi-step task automation

## System Requirements

Before we begin, ensure your system meets the following requirements:

### Prerequisites

- **Python**: Version 3.12 or higher
- **Operating System**: macOS, Linux, or Windows with WSL
- **Package Manager**: `uv` (recommended) or `pip`
- **Git**: For cloning the repository

### API Keys Required

To fully utilize Youtu-Agent's capabilities, you'll need:
- **LLM API Key**: OpenAI-compatible API (DeepSeek, OpenAI, etc.)
- **Search API Key**: Serper API for web search functionality
- **Content API Key**: Jina AI for content processing

## Installation Guide

### Step 1: Install Python and uv

First, ensure you have Python 3.12+ installed:

```bash
# Check Python version
python --version

# Install uv package manager (recommended)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Or install via pip
pip install uv
```

### Step 2: Clone the Repository

```bash
# Clone Youtu-Agent repository
git clone https://github.com/TencentCloudADP/youtu-agent.git
cd youtu-agent

# Verify directory structure
ls -la
```

### Step 3: Set Up Dependencies

```bash
# Sync dependencies using uv
uv sync

# Alternative: use make command
make sync

# Activate virtual environment
source ./.venv/bin/activate
```

### Step 4: Configure Environment Variables

```bash
# Copy environment template
cp .env.example .env

# Edit the .env file with your API keys
nano .env
```

Configure your `.env` file with the following settings:

```bash
# LLM Configuration (DeepSeek example)
UTU_LLM_TYPE=chat.completions
UTU_LLM_MODEL=deepseek-chat
UTU_LLM_BASE_URL=https://api.deepseek.com/v1
UTU_LLM_API_KEY=your-deepseek-api-key

# Web Search Tools
SERPER_API_KEY=your-serper-api-key
JINA_API_KEY=your-jina-api-key

# Judge LLM for Evaluations (optional)
JUDGE_LLM_TYPE=chat.completions
JUDGE_LLM_MODEL=deepseek-chat
JUDGE_LLM_BASE_URL=https://api.deepseek.com/v1
JUDGE_LLM_API_KEY=your-judge-api-key
```

## Basic Configuration

### Understanding Agent Configuration

Youtu-Agent uses YAML files for agent configuration. Let's examine the default configuration:

```yaml
# configs/agents/default.yaml
defaults:
  - /model/base
  - /tools/search@toolkits.search
  - _self_

agent:
  name: simple-tool-agent
  instructions: "You are a helpful assistant that can search the web."
```

### Core Components

**1. Agent**: An LLM configured with specific prompts, tools, and environment
**2. Toolkit**: Encapsulated set of tools that an agent can use
**3. Environment**: The operational context (browser, shell, etc.)
**4. ContextManager**: Configurable module for managing the agent's context window
**5. Benchmark**: Encapsulated workflow for specific datasets

## Getting Started: Your First Agent

### Running the Basic CLI Chatbot

Let's start with a simple example:

```bash
# Run basic agent without search tools
python scripts/cli_chat.py --stream --config base
```

This launches an interactive CLI chatbot. Try asking questions like:
- "Hello, how are you?"
- "What can you help me with?"
- "Explain quantum computing in simple terms"

### Running Agent with Web Search

For more advanced capabilities, use the search-enabled agent:

```bash
# Run agent with web search capabilities
python scripts/cli_chat.py --stream --config default
```

Now you can ask questions that require current information:
- "What are the latest developments in AI?"
- "Tell me about recent tech news"
- "What's the weather like in Tokyo today?"

## Practical Examples

### Example 1: SVG Generator

One of the most impressive features of Youtu-Agent is its ability to generate SVG visualizations based on research topics.

#### Command Line Version

```bash
# Generate SVG about DeepSeek V3.1 features
python examples/svg_generator/main.py
```

This command will:
1. Automatically search online for information about "DeepSeek V3.1 New Features"
2. Analyze and synthesize the collected information
3. Generate an SVG visualization representing the findings

#### Web UI Version

For a more interactive experience, you can use the web interface:

```bash
# Install frontend package
curl -LO https://github.com/TencentCloudADP/youtu-agent/releases/download/frontend%2Fv0.1.6/utu_agent_ui-0.1.6-py3-none-any.whl
uv pip install utu_agent_ui-0.1.6-py3-none-any.whl

# Run web version
python examples/svg_generator/main_web.py
```

Once started, access the web interface at `http://127.0.0.1:8848/` and interact with the agent through a user-friendly interface.

### Example 2: Research Assistant

Create a custom research assistant for in-depth analysis:

```python
# examples/research_assistant.py
import asyncio
from utu.core.agent import Agent
from utu.core.config import load_config

async def research_topic(topic: str):
    # Load configuration
    config = load_config("configs/agents/research.yaml")
    
    # Initialize agent
    agent = Agent(config)
    
    # Perform research
    response = await agent.chat(
        f"Conduct comprehensive research on: {topic}. "
        f"Provide detailed analysis with sources."
    )
    
    return response

# Usage
if __name__ == "__main__":
    topic = "Latest developments in quantum computing"
    result = asyncio.run(research_topic(topic))
    print(result)
```

## Advanced Features

### Custom Tool Development

Create your own tools to extend agent capabilities:

```python
# custom_tools/file_manager.py
from utu.core.tool import Tool
import os

class FileManagerTool(Tool):
    def __init__(self):
        super().__init__(
            name="file_manager",
            description="Manage files and directories"
        )
    
    async def list_files(self, directory: str = ".") -> str:
        """List files in specified directory"""
        try:
            files = os.listdir(directory)
            return f"Files in {directory}: {', '.join(files)}"
        except Exception as e:
            return f"Error listing files: {str(e)}"
    
    async def read_file(self, filepath: str) -> str:
        """Read contents of a file"""
        try:
            with open(filepath, 'r') as f:
                content = f.read()
            return f"Content of {filepath}:\n{content}"
        except Exception as e:
            return f"Error reading file: {str(e)}"
```

### Context Management

Optimize agent performance with custom context management:

```yaml
# configs/context/large_context.yaml
context_manager:
  max_tokens: 32768
  strategy: "sliding_window"
  preserve_system: true
  compression_ratio: 0.7
```

### Environment Configuration

Set up specialized environments for different tasks:

```yaml
# configs/environments/web_browser.yaml
environment:
  type: "browser"
  settings:
    headless: false
    timeout: 30
    user_agent: "YoutuAgent/1.0"
```

## Evaluation and Benchmarking

### Setting Up Evaluations

Youtu-Agent provides comprehensive evaluation capabilities:

```bash
# Prepare WebWalkerQA dataset
python scripts/data/process_web_walker_qa.py

# Run evaluation
python scripts/run_eval.py \
  --config_name ww \
  --exp_id my_experiment_001 \
  --dataset WebWalkerQA_15 \
  --concurrency 5
```

### Custom Benchmark Creation

Create your own benchmarks:

```python
# benchmarks/custom_benchmark.py
from utu.core.benchmark import Benchmark
from utu.core.dataset import Dataset

class CustomBenchmark(Benchmark):
    def __init__(self):
        super().__init__(name="custom_benchmark")
    
    async def preprocess(self, raw_data):
        """Preprocess raw data for evaluation"""
        return processed_data
    
    async def judge(self, response, ground_truth):
        """Evaluate agent response against ground truth"""
        return score
```

## Docker Deployment

For production deployments, use Docker:

```bash
# Build Docker image
docker build -t youtu-agent .

# Run with environment variables
docker run -it \
  -e UTU_LLM_API_KEY=your-api-key \
  -e SERPER_API_KEY=your-serper-key \
  -p 8848:8848 \
  youtu-agent
```

## Testing and Validation

### macOS Test Script

Create a comprehensive test script for macOS:

```bash
#!/bin/bash
# test_youtu_agent_macos.sh

echo "🧪 Testing Youtu-Agent on macOS"
echo "================================"

# Test 1: Check Python version
echo "1. Checking Python version..."
python_version=$(python --version 2>&1)
echo "Python version: $python_version"

if [[ $python_version == *"3.12"* ]] || [[ $python_version == *"3.13"* ]]; then
    echo "✅ Python version compatible"
else
    echo "❌ Python 3.12+ required"
    exit 1
fi

# Test 2: Check uv installation
echo -e "\n2. Checking uv installation..."
if command -v uv &> /dev/null; then
    echo "✅ uv is installed"
    uv --version
else
    echo "❌ uv not found, installing..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# Test 3: Test virtual environment
echo -e "\n3. Testing virtual environment..."
if [ -d ".venv" ]; then
    echo "✅ Virtual environment exists"
    source ./.venv/bin/activate
    python -c "import utu; print('✅ Youtu-Agent imported successfully')" 2>/dev/null || echo "❌ Failed to import utu"
else
    echo "❌ Virtual environment not found"
    exit 1
fi

# Test 4: Check environment configuration
echo -e "\n4. Checking environment configuration..."
if [ -f ".env" ]; then
    echo "✅ .env file exists"
    
    # Check for required keys
    if grep -q "UTU_LLM_API_KEY" .env; then
        echo "✅ LLM API key configured"
    else
        echo "⚠️  LLM API key not configured"
    fi
    
    if grep -q "SERPER_API_KEY" .env; then
        echo "✅ Serper API key configured"
    else
        echo "⚠️  Serper API key not configured"
    fi
else
    echo "❌ .env file not found"
    echo "Run: cp .env.example .env"
fi

# Test 5: Test basic agent functionality
echo -e "\n5. Testing basic agent functionality..."
python -c "
import asyncio
from utu.core.config import load_config
try:
    config = load_config('configs/agents/base.yaml')
    print('✅ Basic configuration loaded successfully')
except Exception as e:
    print(f'❌ Configuration error: {e}')
" 2>/dev/null

echo -e "\n🎉 macOS compatibility test completed!"
```

### Running Tests

```bash
# Make script executable
chmod +x test_youtu_agent_macos.sh

# Run compatibility test
./test_youtu_agent_macos.sh
```

## Troubleshooting

### Common Issues

**1. Import Errors**
```bash
# Ensure virtual environment is activated
source ./.venv/bin/activate

# Reinstall dependencies
uv sync --force
```

**2. API Connection Issues**
```bash
# Test API connectivity
python -c "
import os
from openai import OpenAI
client = OpenAI(
    api_key=os.getenv('UTU_LLM_API_KEY'),
    base_url=os.getenv('UTU_LLM_BASE_URL')
)
try:
    response = client.chat.completions.create(
        model=os.getenv('UTU_LLM_MODEL'),
        messages=[{'role': 'user', 'content': 'Hello'}],
        max_tokens=10
    )
    print('✅ API connection successful')
except Exception as e:
    print(f'❌ API error: {e}')
"
```

**3. Memory Issues**
```bash
# Reduce concurrency for large evaluations
python scripts/run_eval.py --concurrency 1

# Use smaller context windows
# Edit configs/context/base.yaml
```

## Performance Optimization

### Async Processing

Maximize performance with proper async usage:

```python
import asyncio
from utu.core.agent import Agent

async def process_multiple_queries(queries: list):
    agent = Agent.from_config("configs/agents/default.yaml")
    
    # Process queries concurrently
    tasks = [agent.chat(query) for query in queries]
    results = await asyncio.gather(*tasks)
    
    return results

# Usage
queries = [
    "What is machine learning?",
    "Explain neural networks",
    "What are transformers in AI?"
]

results = asyncio.run(process_multiple_queries(queries))
```

### Memory Management

```python
# Implement context compression
from utu.core.context import ContextManager

context_manager = ContextManager(
    max_tokens=16384,
    compression_strategy="summarize",
    preserve_recent=True
)
```

## Best Practices

### 1. Configuration Management

- Use version control for configuration files
- Create environment-specific configs
- Document custom configurations

### 2. Error Handling

```python
async def robust_agent_call(agent, message):
    max_retries = 3
    for attempt in range(max_retries):
        try:
            response = await agent.chat(message)
            return response
        except Exception as e:
            if attempt == max_retries - 1:
                raise e
            await asyncio.sleep(2 ** attempt)  # Exponential backoff
```

### 3. Monitoring and Logging

```python
import logging
from utu.core.tracing import setup_tracing

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Setup tracing
setup_tracing(
    service_name="my-agent-app",
    endpoint="http://localhost:4317"
)
```

## Integration Examples

### Flask Web Application

```python
from flask import Flask, request, jsonify
from utu.core.agent import Agent
import asyncio

app = Flask(__name__)
agent = Agent.from_config("configs/agents/web_assistant.yaml")

@app.route('/chat', methods=['POST'])
def chat():
    data = request.json
    message = data.get('message', '')
    
    async def process():
        return await agent.chat(message)
    
    response = asyncio.run(process())
    return jsonify({'response': response})

if __name__ == '__main__':
    app.run(debug=True)
```

### FastAPI Integration

```python
from fastapi import FastAPI
from pydantic import BaseModel
from utu.core.agent import Agent

app = FastAPI()
agent = Agent.from_config("configs/agents/api_assistant.yaml")

class ChatRequest(BaseModel):
    message: str

class ChatResponse(BaseModel):
    response: str

@app.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    response = await agent.chat(request.message)
    return ChatResponse(response=response)
```

## Conclusion

Youtu-Agent represents a significant advancement in agent framework development, offering a perfect balance of simplicity and power. Whether you're a researcher looking for a robust baseline for experimentation, a developer building production applications, or an enthusiast exploring AI capabilities, Youtu-Agent provides the tools and flexibility you need.

### Key Takeaways

1. **Easy Setup**: With Python 3.12+ and uv, getting started takes minutes
2. **Flexible Configuration**: YAML-based configs make customization straightforward
3. **Production Ready**: Async processing and comprehensive evaluation tools
4. **Extensible**: Custom tools and environments can be easily integrated
5. **Well Documented**: Comprehensive examples and clear documentation

### Next Steps

- Explore the [official documentation](https://tencentcloudadp.github.io/youtu-agent/)
- Join the community discussions on GitHub
- Experiment with custom tool development
- Contribute to the project's growth

### Resources

- **GitHub Repository**: [https://github.com/TencentCloudADP/youtu-agent](https://github.com/TencentCloudADP/youtu-agent)
- **Official Website**: [https://tencentcloudadp.github.io/youtu-agent/](https://tencentcloudadp.github.io/youtu-agent/)
- **Docker Setup Guide**: Refer to `docker/README.md` in the repository
- **Example Projects**: Check the `/examples` directory for more use cases

Happy building with Youtu-Agent! 🚀
