---
title: "RAGLight Complete Guide: From Basic RAG to Agentic Workflows"
excerpt: "Master RAGLight framework with hands-on examples covering RAG, Agentic RAG, RAT pipelines, and MCP integration for building powerful retrieval-augmented generation systems."
seo_title: "RAGLight Tutorial: Complete RAG Framework Guide - Thaki Cloud"
seo_description: "Learn RAGLight framework with practical examples. Build RAG, Agentic RAG, and RAT pipelines on macOS using Ollama, OpenAI, or Mistral for context-aware AI applications."
date: 2025-10-14
categories:
  - tutorials
tags:
  - raglight
  - rag
  - agentic-rag
  - ollama
  - python
  - llm
  - vector-database
  - mcp
  - huggingface
author_profile: true
toc: true
toc_label: "Contents"
lang: en
permalink: /en/tutorials/raglight-comprehensive-guide/
canonical_url: "https://thakicloud.github.io/en/tutorials/raglight-comprehensive-guide/"
---

⏱️ **Estimated Reading Time**: 15 minutes

## Introduction

**RAGLight** is a lightweight, modular Python framework designed to simplify the implementation of **Retrieval-Augmented Generation (RAG)**. By combining document retrieval with large language models (LLMs), RAGLight enables you to build context-aware AI systems that can answer questions based on your own documents and knowledge bases.

In this comprehensive tutorial, you'll learn how to:

- Set up RAGLight with various LLM providers (Ollama, OpenAI, Mistral)
- Build basic RAG pipelines for document-based question answering
- Implement Agentic RAG for multi-step reasoning tasks
- Use RAT (Retrieval-Augmented Thinking) for enhanced reasoning
- Integrate external tools using MCP (Model Context Protocol)

### What Makes RAGLight Special?

RAGLight stands out for its:

- **Modular Architecture**: Easily swap LLMs, embeddings, and vector stores
- **Multiple Provider Support**: Ollama, OpenAI, Mistral, LMStudio, vLLM, Google AI
- **Advanced Pipelines**: Basic RAG, Agentic RAG, and RAT with reasoning layers
- **MCP Integration**: Connect external tools and data sources seamlessly
- **Flexible Configuration**: Customize every aspect of your RAG pipeline

## Prerequisites

Before starting this tutorial, ensure you have:

### 1. Python Environment

```bash
# Check Python version (3.8 or higher required)
python3 --version

# Create a virtual environment (recommended)
python3 -m venv raglight-env
source raglight-env/bin/activate  # On macOS/Linux
# raglight-env\Scripts\activate  # On Windows
```

### 2. Ollama Installation (for local LLM)

```bash
# macOS
brew install ollama

# Or download from https://ollama.ai/download

# Start Ollama service
ollama serve

# Pull a model (in a new terminal)
ollama pull llama3.2:3b
```

**Alternative**: Use OpenAI or Mistral API if you prefer cloud-based LLMs.

### 3. Install RAGLight

```bash
pip install raglight
```

## Installation and Setup

### Environment Configuration

Create a `.env` file to store your API keys (if using cloud providers):

```bash
# .env file
OPENAI_API_KEY=your_openai_key_here
MISTRAL_API_KEY=your_mistral_key_here
```

### Project Structure

Set up your project directory:

```bash
mkdir raglight-tutorial
cd raglight-tutorial
mkdir data
mkdir knowledge_base
```

### Sample Data Creation

Create some sample documents for testing:

```bash
# data/document1.txt
cat > data/document1.txt << 'EOF'
RAGLight is a modular Python framework for Retrieval-Augmented Generation.
It supports multiple LLM providers including Ollama, OpenAI, and Mistral.
Key features include flexible vector store integration with ChromaDB and FAISS.
EOF

# data/document2.txt
cat > data/document2.txt << 'EOF'
Agentic RAG extends traditional RAG by incorporating autonomous agents.
These agents can perform multi-step reasoning and dynamic information retrieval.
Use cases include complex question answering and research assistants.
EOF

# data/document3.txt
cat > data/document3.txt << 'EOF'
Retrieval-Augmented Thinking (RAT) adds a specialized reasoning layer.
It uses reasoning LLMs to enhance response quality and analytical depth.
RAT is ideal for tasks requiring deep thinking and multi-hop reasoning.
EOF
```

## Basic RAG Pipeline

### Understanding the RAG Architecture

The basic RAG pipeline consists of three main components:

1. **Document Ingestion**: Your documents are split into chunks and converted to embeddings
2. **Vector Storage**: Embeddings are stored in a vector database (ChromaDB, FAISS, etc.)
3. **Retrieval & Generation**: When queried, relevant documents are retrieved and passed to the LLM

### Implementation

Here's a complete example of a basic RAG pipeline:

```python
#!/usr/bin/env python3
"""Basic RAG Pipeline with RAGLight"""

from raglight.rag.simple_rag_api import RAGPipeline
from raglight.config.rag_config import RAGConfig
from raglight.config.vector_store_config import VectorStoreConfig
from raglight.config.settings import Settings
from raglight.models.data_source_model import FolderSource
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Setup logging
Settings.setup_logging()

# Vector Store Configuration
vector_store_config = VectorStoreConfig(
    embedding_model=Settings.DEFAULT_EMBEDDINGS_MODEL,
    api_base=Settings.DEFAULT_OLLAMA_CLIENT,
    provider=Settings.HUGGINGFACE,
    database=Settings.CHROMA,
    persist_directory="./chroma_db",
    collection_name="my_knowledge_base"
)

# RAG Configuration
config = RAGConfig(
    llm="llama3.2:3b",  # Ollama model
    k=5,  # Number of documents to retrieve
    provider=Settings.OLLAMA,
    system_prompt=Settings.DEFAULT_SYSTEM_PROMPT,
    knowledge_base=[FolderSource(path="./data")]
)

# Initialize and build pipeline
print("Initializing RAG pipeline...")
pipeline = RAGPipeline(config, vector_store_config)

print("Building knowledge base...")
pipeline.build()

# Query the pipeline
query = "What are the key features of RAGLight?"
print(f"\nQuery: {query}")

response = pipeline.generate(query)
print(f"\nResponse:\n{response}")
```

### Key Configuration Options

**Vector Store Options:**
- `database`: CHROMA, FAISS, or QDRANT
- `provider`: HUGGINGFACE, OLLAMA, or OPENAI for embeddings
- `persist_directory`: Where to store the vector database

**RAG Options:**
- `llm`: Model name (e.g., "llama3.2:3b", "gpt-4", "mistral-large-2411")
- `k`: Number of relevant documents to retrieve
- `provider`: OLLAMA, OPENAI, MISTRAL, LMSTUDIO, GOOGLE

### Using Different LLM Providers

**OpenAI:**
```python
config = RAGConfig(
    llm="gpt-4",
    k=5,
    provider=Settings.OPENAI,
    api_key=Settings.OPENAI_API_KEY,
    knowledge_base=[FolderSource(path="./data")]
)
```

**Mistral:**
```python
config = RAGConfig(
    llm="mistral-large-2411",
    k=5,
    provider=Settings.MISTRAL,
    api_key=Settings.MISTRAL_API_KEY,
    knowledge_base=[FolderSource(path="./data")]
)
```

## Agentic RAG Pipeline

### What is Agentic RAG?

Agentic RAG extends traditional RAG by incorporating an autonomous agent that can:

- Perform multi-step reasoning
- Decide when to retrieve additional information
- Iterate through multiple retrieval-generation cycles
- Handle complex questions requiring multiple data sources

### Implementation

```python
"""Agentic RAG Pipeline with RAGLight"""

from raglight.rag.simple_agentic_rag_api import AgenticRAGPipeline
from raglight.config.agentic_rag_config import AgenticRAGConfig
from raglight.config.vector_store_config import VectorStoreConfig
from raglight.config.settings import Settings
from raglight.models.data_source_model import FolderSource
from dotenv import load_dotenv

load_dotenv()
Settings.setup_logging()

# Vector Store Configuration
vector_store_config = VectorStoreConfig(
    embedding_model=Settings.DEFAULT_EMBEDDINGS_MODEL,
    api_base=Settings.DEFAULT_OLLAMA_CLIENT,
    provider=Settings.HUGGINGFACE,
    database=Settings.CHROMA,
    persist_directory="./agentic_chroma_db",
    collection_name="agentic_knowledge_base"
)

# Agentic RAG Configuration
config = AgenticRAGConfig(
    provider=Settings.MISTRAL,
    model="mistral-large-2411",
    k=10,
    system_prompt=Settings.DEFAULT_AGENT_PROMPT,
    max_steps=4,  # Maximum reasoning steps
    api_key=Settings.MISTRAL_API_KEY,
    knowledge_base=[FolderSource(path="./data")]
)

# Initialize and build
print("Initializing Agentic RAG pipeline...")
agentic_rag = AgenticRAGPipeline(config, vector_store_config)

print("Building knowledge base...")
agentic_rag.build()

# Complex query requiring multiple steps
query = """
Compare the capabilities of basic RAG and Agentic RAG.
What are the specific use cases where Agentic RAG would be more beneficial?
"""

print(f"\nQuery: {query}")
response = agentic_rag.generate(query)
print(f"\nResponse:\n{response}")
```

### Key Features of Agentic RAG

**max_steps**: Controls how many reasoning iterations the agent can perform
```python
# Simple query: fewer steps needed
config = AgenticRAGConfig(max_steps=2, ...)

# Complex analysis: more steps allowed
config = AgenticRAGConfig(max_steps=10, ...)
```

**Custom Agent Prompt**: Tailor the agent's behavior
```python
custom_agent_prompt = """
You are a research assistant. When answering questions:
1. Break down complex queries into sub-questions
2. Retrieve relevant information for each sub-question
3. Synthesize findings into a comprehensive answer
4. Cite sources when possible
"""

config = AgenticRAGConfig(
    system_prompt=custom_agent_prompt,
    ...
)
```

## RAT (Retrieval-Augmented Thinking)

### Understanding RAT

RAT adds a specialized reasoning layer to the RAG pipeline:

1. **Retrieval**: Fetch relevant documents
2. **Reasoning**: Use a reasoning LLM to analyze retrieved content
3. **Thinking**: Generate intermediate reasoning steps
4. **Generation**: Produce final answer with enhanced context

### Implementation

```python
"""RAT Pipeline with RAGLight"""

from raglight.rat.simple_rat_api import RATPipeline
from raglight.config.rat_config import RATConfig
from raglight.config.vector_store_config import VectorStoreConfig
from raglight.config.settings import Settings
from raglight.models.data_source_model import FolderSource

Settings.setup_logging()

# Vector Store Configuration
vector_store_config = VectorStoreConfig(
    embedding_model=Settings.DEFAULT_EMBEDDINGS_MODEL,
    api_base=Settings.DEFAULT_OLLAMA_CLIENT,
    provider=Settings.HUGGINGFACE,
    database=Settings.CHROMA,
    persist_directory="./rat_chroma_db",
    collection_name="rat_knowledge_base"
)

# RAT Configuration
config = RATConfig(
    cross_encoder_model=Settings.DEFAULT_CROSS_ENCODER_MODEL,
    llm="llama3.2:3b",
    k=Settings.DEFAULT_K,
    provider=Settings.OLLAMA,
    system_prompt=Settings.DEFAULT_SYSTEM_PROMPT,
    reasoning_llm=Settings.DEFAULT_REASONING_LLM,
    reflection=3,  # Number of reasoning iterations
    knowledge_base=[FolderSource(path="./data")]
)

# Initialize and build
print("Initializing RAT pipeline...")
pipeline = RATPipeline(config, vector_store_config)

print("Building knowledge base...")
pipeline.build()

# Query requiring deep reasoning
query = """
Analyze the architectural differences between RAG, Agentic RAG, and RAT.
What are the trade-offs in terms of complexity, performance, and output quality?
"""

print(f"\nQuery: {query}")
response = pipeline.generate(query)
print(f"\nResponse:\n{response}")
```

### RAT Configuration Options

**reflection**: Number of reasoning iterations
```python
# Quick reasoning
config = RATConfig(reflection=1, ...)

# Deep analytical thinking
config = RATConfig(reflection=5, ...)
```

**cross_encoder_model**: Reranking model for better retrieval
```python
config = RATConfig(
    cross_encoder_model="cross-encoder/ms-marco-MiniLM-L-12-v2",
    ...
)
```

## MCP Integration

### What is MCP?

Model Context Protocol (MCP) allows your RAG pipeline to interact with external tools and services. This enables:

- Web search integration
- Database queries
- API calls to external services
- Code execution environments
- Custom tool integration

### MCP Server Setup

First, configure your MCP server (example using MCPClient):

```python
"""MCP Server Configuration"""

from raglight.rag.simple_agentic_rag_api import AgenticRAGPipeline
from raglight.config.agentic_rag_config import AgenticRAGConfig
from raglight.config.settings import Settings

# Configure MCP server URL
config = AgenticRAGConfig(
    provider=Settings.OPENAI,
    model="gpt-4o",
    k=10,
    mcp_config=[
        {% raw %}{"url": "http://127.0.0.1:8001/sse"}{% endraw %}  # Your MCP server URL
    ],
    system_prompt=Settings.DEFAULT_AGENT_PROMPT,
    max_steps=4,
    api_key=Settings.OPENAI_API_KEY
)

# Initialize with MCP
pipeline = AgenticRAGPipeline(config, vector_store_config)
pipeline.build()

# The agent can now use external tools
query = "Search the web for recent updates on RAG frameworks and summarize findings"
response = pipeline.generate(query)
```

### MCP Use Cases

**Web Search Integration:**
```python
# Agent can search and incorporate web results
query = "What are the latest developments in RAG technology in 2024?"
```

**Database Queries:**
```python
# Agent can query databases for real-time data
query = "Retrieve user statistics from our database and analyze trends"
```

**API Integration:**
```python
# Agent can call external APIs
query = "Check weather API and recommend activities based on forecast"
```

## Performance Comparison

### Pipeline Characteristics

| Pipeline Type | Complexity | Response Time | Use Case |
|--------------|------------|---------------|----------|
| **Basic RAG** | Low | Fast (< 5s) | Simple Q&A, document lookup |
| **Agentic RAG** | Medium | Moderate (5-15s) | Multi-step reasoning, research |
| **RAT** | High | Slower (15-30s) | Deep analysis, complex reasoning |
| **RAG + MCP** | Variable | Depends on tools | External tool integration |

### Choosing the Right Pipeline

**Use Basic RAG when:**
- You need fast responses
- Questions are straightforward
- Single document lookup is sufficient

**Use Agentic RAG when:**
- Questions require multiple steps
- You need dynamic retrieval
- Task involves research or exploration

**Use RAT when:**
- Deep analytical thinking is required
- Quality is more important than speed
- Complex multi-hop reasoning is needed

**Use MCP Integration when:**
- You need real-time external data
- Task requires tool usage
- Dynamic information is essential

## Best Practices

### 1. Document Preparation

**Chunk Size Optimization:**
```python
# For technical documents
chunk_size = 512

# For narrative content
chunk_size = 1024
```

**Folder Organization:**
```
knowledge_base/
├── technical_docs/
├── user_manuals/
├── api_reference/
└── faq/
```

### 2. Vector Store Management

**Persistence:**
```python
# Always use persistent storage in production
vector_store_config = VectorStoreConfig(
    persist_directory="./prod_vectordb",
    collection_name="production_kb"
)
```

**Collection Organization:**
```python
# Separate collections for different domains
collections = {
    "technical": "tech_docs_collection",
    "business": "business_docs_collection",
    "general": "general_knowledge_collection"
}
```

### 3. LLM Selection

**Development:**
```python
# Use local models for development
config = RAGConfig(
    llm="llama3.2:3b",
    provider=Settings.OLLAMA
)
```

**Production:**
```python
# Use more powerful models for production
config = RAGConfig(
    llm="gpt-4",
    provider=Settings.OPENAI
)
```

### 4. Error Handling

```python
"""Robust RAG Pipeline with Error Handling"""

try:
    pipeline = RAGPipeline(config, vector_store_config)
    pipeline.build()
    response = pipeline.generate(query)
except Exception as e:
    print(f"Pipeline error: {e}")
    # Fallback to basic LLM without RAG
    response = fallback_generate(query)
```

### 5. Ignore Folders Configuration

When indexing code repositories, exclude unnecessary directories:

```python
# Custom ignore folders
custom_ignore_folders = [
    ".venv",
    "venv",
    "node_modules",
    "__pycache__",
    ".git",
    "build",
    "dist",
    "my_custom_folder_to_ignore"
]

config = AgenticRAGConfig(
    ignore_folders=custom_ignore_folders,
    ...
)
```

### 6. Monitoring and Logging

```python
"""Enable detailed logging"""

import logging

# Configure logging level
logging.basicConfig(level=logging.INFO)

# Or use RAGLight's setup
Settings.setup_logging()

# Monitor performance
import time

start_time = time.time()
response = pipeline.generate(query)
elapsed_time = time.time() - start_time

print(f"Query processed in {elapsed_time:.2f}s")
```

## Advanced Customization

### Custom Pipeline Builder

```python
"""Custom RAG Pipeline with Builder Pattern"""

from raglight.rag.builder import Builder
from raglight.config.settings import Settings

# Build custom pipeline
rag = Builder() \
    .with_embeddings(
        Settings.HUGGINGFACE,
        model_name=Settings.DEFAULT_EMBEDDINGS_MODEL
    ) \
    .with_vector_store(
        Settings.CHROMA,
        persist_directory="./custom_db",
        collection_name="custom_collection"
    ) \
    .with_llm(
        Settings.OLLAMA,
        model_name="llama3.2:3b",
        system_prompt_file="./custom_prompt.txt",
        provider=Settings.OLLAMA
    ) \
    .build_rag(k=5)

# Ingest documents
rag.vector_store.ingest(data_path='./data')

# Query
response = rag.generate("Your question here")
```

### Code Repository Indexing

```python
"""Index code repositories"""

# Index code with signature extraction
rag.vector_store.ingest(repos_path=['./repo1', './repo2'])

# Search code
code_results = rag.vector_store.similarity_search("authentication logic")

# Search class signatures
class_results = rag.vector_store.similarity_search_class("User class definition")
```

### GitHub Repository Integration

```python
"""Index GitHub repositories directly"""

from raglight.models.data_source_model import GitHubSource

knowledge_base = [
    GitHubSource(url="https://github.com/Bessouat40/RAGLight"),
    GitHubSource(url="https://github.com/your-org/your-repo")
]

config = RAGConfig(
    knowledge_base=knowledge_base,
    ...
)
```

## Docker Deployment

### Dockerfile Example

```dockerfile
FROM python:3.10-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY . .

# Add host mapping for Ollama/LMStudio
# Run with: docker run --add-host=host.docker.internal:host-gateway your-image

CMD ["python", "app.py"]
```

### Build and Run

```bash
# Build image
docker build -t raglight-app .

# Run with host network access (for Ollama)
docker run --add-host=host.docker.internal:host-gateway raglight-app
```

## Troubleshooting

### Common Issues

**1. Ollama Connection Error:**
```python
# Check Ollama is running
# macOS/Linux:
ollama serve

# Update API base if needed
vector_store_config = VectorStoreConfig(
    api_base="http://localhost:11434",  # Default Ollama URL
    ...
)
```

**2. Memory Issues:**
```python
# Reduce chunk size and k value
config = RAGConfig(
    k=3,  # Retrieve fewer documents
    ...
)
```

**3. Slow Performance:**
```python
# Use smaller embedding models
vector_store_config = VectorStoreConfig(
    embedding_model="all-MiniLM-L6-v2",  # Smaller, faster model
    ...
)
```

**4. Vector Store Errors:**
```bash
# Clear and rebuild
rm -rf ./chroma_db
python rebuild_kb.py
```

## Conclusion

RAGLight provides a powerful, flexible framework for building retrieval-augmented generation systems. Whether you need simple document Q&A or complex agentic workflows with external tool integration, RAGLight's modular architecture makes it easy to build and scale.

### Key Takeaways

- **Start Simple**: Begin with Basic RAG and upgrade to Agentic RAG or RAT as needed
- **Choose Wisely**: Select the right pipeline based on your use case and performance requirements
- **Customize Extensively**: RAGLight's modular design allows complete customization
- **Scale Gradually**: Start locally with Ollama, then move to cloud providers for production

### Next Steps

1. **Experiment**: Try different LLM providers and vector stores
2. **Optimize**: Tune k values, chunk sizes, and model selection
3. **Integrate**: Add MCP servers for external tool access
4. **Deploy**: Containerize with Docker for production deployment

### Resources

- **RAGLight GitHub**: [https://github.com/Bessouat40/RAGLight](https://github.com/Bessouat40/RAGLight)
- **PyPI Package**: [https://pypi.org/project/raglight/](https://pypi.org/project/raglight/)
- **Ollama**: [https://ollama.ai](https://ollama.ai)
- **ChromaDB**: [https://www.trychroma.com](https://www.trychroma.com)
- **MCP Protocol**: Search "Model Context Protocol" for documentation

Happy building with RAGLight! 🚀

