---
title: "MCPStore: Complete Guide to MCP Service Management for AI Agents"
excerpt: "Learn how to use MCPStore, an elegant open-source MCP service management tool that enables AI Agents to easily integrate and use various tools with multi-agent isolation support."
seo_title: "MCPStore Tutorial: MCP Service Management for AI Agents - Thaki Cloud"
seo_description: "Complete tutorial on MCPStore - open-source MCP service management tool with LangChain integration, multi-agent isolation, and RESTful API for AI development."
date: 2025-09-28
categories:
  - tutorials
tags:
  - MCP
  - AI-Agents
  - Python
  - LangChain
  - API
  - Open-Source
author_profile: true
toc: true
toc_label: "Table of Contents"
lang: en
permalink: /en/tutorials/mcpstore-mcp-service-management-tutorial/
canonical_url: "https://thakicloud.github.io/en/tutorials/mcpstore-mcp-service-management-tutorial/"
---

⏱️ **Estimated Reading Time**: 12 minutes

## Introduction

MCPStore is a revolutionary open-source tool that simplifies MCP (Model Context Protocol) service management for AI Agents. With over 236 GitHub stars and growing popularity, MCPStore provides an elegant solution for managing MCP services with features like multi-agent isolation, LangChain integration, and intuitive web interfaces.

## What is MCPStore?

MCPStore is a one-stop open-source high-quality MCP service management tool that makes it easy for AI Agents to use various tools. It offers:

- **Chain Call Design**: Clear context isolation with `store.for_store()` and `store.for_agent("agent_id")`
- **Multi-Agent Support**: Dedicated toolsets for different functional agents
- **LangChain Integration**: Seamless integration with popular AI frameworks
- **RESTful API**: Complete web service interface
- **Vue Frontend**: Intuitive web interface for service management

## Installation and Setup

### Quick Installation

The simplest way to get started with MCPStore is through pip:

```bash
pip install mcpstore
```

### Verify Installation

After installation, you can verify that MCPStore is working correctly:

```python
from mcpstore import MCPStore

# Initialize the store
store = MCPStore.setup_store()
print("MCPStore initialized successfully!")
```

## Basic Usage

### Setting Up Your First MCP Service

Let's start with a basic example of adding and using an MCP service:

```python
from mcpstore import MCPStore

# Initialize the store
store = MCPStore.setup_store()

# Add a service to the global store
store.for_store().add_service({
    "name": "mcpstore-wiki",
    "url": "https://mcpstore.wiki/mcp"
})

# List available tools
tools = store.for_store().list_tools()
print(f"Available tools: {len(tools)}")

# Use a tool (example)
# result = store.for_store().use_tool(tools[0].name, {"query": "Hello!"})
```

### Understanding Chain Call Design

MCPStore uses a chain call design that provides clear context isolation:

```python
# Global store space - shared across all agents
global_context = store.for_store()

# Agent-specific space - isolated for each agent
agent_context = store.for_agent("my-agent-id")
```

## Multi-Agent Isolation

One of MCPStore's most powerful features is its ability to create isolated environments for different AI agents.

### Creating Isolated Agent Environments

```python
from mcpstore import MCPStore

# Initialize Store
store = MCPStore.setup_store()

# Create Knowledge Management Agent with Wiki tools
agent_id1 = "knowledge-agent"
knowledge_agent = store.for_agent(agent_id1)
knowledge_agent.add_service({
    "name": "mcpstore-wiki",
    "url": "http://mcpstore.wiki/mcp"
})

# Create Development Support Agent with different tools
agent_id2 = "development-agent"
dev_agent = store.for_agent(agent_id2)
dev_agent.add_service({
    "name": "mcpstore-demo",
    "url": "http://mcpstore.wiki/mcp"
})

# Each agent has completely isolated toolsets
knowledge_tools = store.for_agent(agent_id1).list_tools()
dev_tools = store.for_agent(agent_id2).list_tools()

print(f"Knowledge Agent Tools: {len(knowledge_tools)}")
print(f"Development Agent Tools: {len(dev_tools)}")
```

### Benefits of Multi-Agent Isolation

- **Security**: Each agent can only access its assigned tools
- **Organization**: Clear separation of concerns between different agent roles
- **Scalability**: Easy to add new agents without affecting existing ones
- **Debugging**: Isolated environments make troubleshooting easier

## LangChain Integration

MCPStore provides seamless integration with LangChain, making it easy to incorporate MCP tools into your AI workflows.

### Complete LangChain Example

```python
from langchain.agents import create_tool_calling_agent, AgentExecutor
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import ChatOpenAI
from mcpstore import MCPStore

# Setup MCPStore
store = MCPStore.setup_store()
store.for_store().add_service({
    "name": "mcpstore-wiki",
    "url": "https://mcpstore.wiki/mcp"
})

# Get tools for LangChain
tools = store.for_store().for_langchain().list_tools()

# Configure LLM (replace with your API key)
llm = ChatOpenAI(
    temperature=0,
    model="gpt-4",
    openai_api_key="your-api-key-here"
)

# Create prompt template
prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a helpful assistant with access to various tools."),
    ("human", "{input}"),
    ("placeholder", "{agent_scratchpad}"),
])

# Create and configure agent
agent = create_tool_calling_agent(llm, tools, prompt)
agent_executor = AgentExecutor(agent=agent, tools=tools, verbose=True)

# Execute query
query = "What information can you provide about MCPStore?"
response = agent_executor.invoke({"input": query})
print(f"Response: {response['output']}")
```

### Alternative LLM Providers

MCPStore works with various LLM providers. Here's an example with DeepSeek:

```python
llm = ChatOpenAI(
    temperature=0,
    model="deepseek-chat",
    openai_api_key="your-deepseek-api-key",
    openai_api_base="https://api.deepseek.com"
)
```

## Web API Interface

MCPStore provides a complete RESTful API for web-based applications.

### Starting the API Server

```python
from mcpstore import MCPStore

# Setup and start API server
prod_store = MCPStore.setup_store()
prod_store.start_api_server(host='0.0.0.0', port=18200)
```

Or using the command line:

```bash
mcpstore run api
```

### Main API Endpoints

#### Service Management

```bash
# Add a new service
curl -X POST http://localhost:18200/for_store/add_service \
  -H "Content-Type: application/json" \
  -d '{"name": "my-service", "url": "https://example.com/mcp"}'

# List all services
curl -X GET http://localhost:18200/for_store/list_services

# Delete a service
curl -X POST http://localhost:18200/for_store/delete_service \
  -H "Content-Type: application/json" \
  -d '{"name": "my-service"}'
```

#### Tool Operations

```bash
# List available tools
curl -X GET http://localhost:18200/for_store/list_tools

# Execute a tool
curl -X POST http://localhost:18200/for_store/use_tool \
  -H "Content-Type: application/json" \
  -d '{"tool_name": "search", "parameters": {"query": "hello"}}'
```

#### Monitoring & Health

```bash
# Get system statistics
curl -X GET http://localhost:18200/for_store/get_stats

# Health check
curl -X GET http://localhost:18200/for_store/health
```

## Vue Frontend Interface

MCPStore includes a beautiful Vue.js frontend for intuitive service management.

### Features of the Web Interface

- **Service Management**: Add, remove, and configure MCP services
- **Tool Visualization**: View available tools and their parameters
- **Real-time Monitoring**: Monitor service health and usage statistics
- **Multi-language Support**: Interface available in multiple languages

### Accessing the Web Interface

After starting the API server, you can access the web interface at:

```
http://localhost:18200
```

The interface provides:
- Dashboard with service overview
- Tool explorer with interactive testing
- Configuration management
- Usage analytics

## Advanced Configuration

### Custom Service Configuration

```python
# Advanced service configuration
service_config = {
    "name": "custom-service",
    "url": "https://your-mcp-service.com/mcp",
    "timeout": 30,
    "retry_attempts": 3,
    "headers": {
        "Authorization": "Bearer your-token",
        "Custom-Header": "value"
    }
}

store.for_store().add_service(service_config)
```

### Environment-Specific Setup

```python
import os
from mcpstore import MCPStore

# Production setup
if os.getenv('ENVIRONMENT') == 'production':
    store = MCPStore.setup_store(
        config_path='/etc/mcpstore/config.json',
        log_level='INFO'
    )
else:
    # Development setup
    store = MCPStore.setup_store(log_level='DEBUG')
```

## Best Practices

### 1. Service Organization

```python
# Organize services by functionality
store.for_agent("web-scraper").add_service({
    "name": "web-scraping-tools",
    "url": "https://scraping-service.com/mcp"
})

store.for_agent("data-analyst").add_service({
    "name": "analytics-tools",
    "url": "https://analytics-service.com/mcp"
})
```

### 2. Error Handling

```python
try:
    result = store.for_store().use_tool("search", {"query": "test"})
    print(f"Success: {result}")
except Exception as e:
    print(f"Error using tool: {e}")
```

### 3. Resource Management

```python
# Clean up resources when done
store.cleanup()
```

## Troubleshooting

### Common Issues and Solutions

#### 1. Service Connection Issues

```python
# Check service health
services = store.for_store().list_services()
for service in services:
    health = store.for_store().check_service_health(service.name)
    print(f"{service.name}: {health}")
```

#### 2. Tool Execution Failures

```python
# Debug tool execution
tools = store.for_store().list_tools()
for tool in tools:
    print(f"Tool: {tool.name}")
    print(f"Parameters: {tool.parameters}")
    print(f"Description: {tool.description}")
```

#### 3. API Server Issues

```bash
# Check if API server is running
curl -X GET http://localhost:18200/for_store/health

# Check server logs
mcpstore logs
```

## Performance Optimization

### 1. Connection Pooling

```python
# Configure connection pooling for better performance
store = MCPStore.setup_store(
    max_connections=10,
    connection_timeout=30
)
```

### 2. Caching

```python
# Enable caching for frequently used tools
store.for_store().enable_caching(
    cache_size=100,
    cache_ttl=300  # 5 minutes
)
```

## Security Considerations

### 1. API Authentication

```python
# Configure API authentication
store.start_api_server(
    host='0.0.0.0',
    port=18200,
    auth_token='your-secure-token'
)
```

### 2. Service Validation

```python
# Validate services before adding
def validate_service(service_config):
    required_fields = ['name', 'url']
    return all(field in service_config for field in required_fields)

if validate_service(service_config):
    store.for_store().add_service(service_config)
```

## Integration Examples

### 1. FastAPI Integration

```python
from fastapi import FastAPI
from mcpstore import MCPStore

app = FastAPI()
store = MCPStore.setup_store()

@app.post("/execute-tool")
async def execute_tool(tool_name: str, parameters: dict):
    result = store.for_store().use_tool(tool_name, parameters)
    return {"result": result}
```

### 2. Django Integration

```python
# views.py
from django.http import JsonResponse
from mcpstore import MCPStore

store = MCPStore.setup_store()

def execute_tool(request):
    tool_name = request.POST.get('tool_name')
    parameters = request.POST.get('parameters', {})
    
    result = store.for_store().use_tool(tool_name, parameters)
    return JsonResponse({"result": result})
```

## Community and Contributing

MCPStore is an active open-source project that welcomes community contributions:

- **GitHub Repository**: [https://github.com/whillhill/mcpstore](https://github.com/whillhill/mcpstore)
- **Documentation**: [doc.mcpstore.wiki](http://doc.mcpstore.wiki/)
- **Issues**: Report bugs and request features on GitHub
- **Pull Requests**: Contribute code improvements

### Ways to Contribute

1. ⭐ Star the project on GitHub
2. 🐛 Report bugs and issues
3. 🔧 Submit pull requests
4. 💬 Share usage experiences
5. 📖 Improve documentation

## Conclusion

MCPStore represents a significant advancement in MCP service management for AI applications. Its elegant design, multi-agent isolation capabilities, and comprehensive integration options make it an essential tool for developers working with AI agents.

Key takeaways:

- **Easy Setup**: Simple pip installation and intuitive API
- **Multi-Agent Support**: Isolated environments for different agent roles
- **Framework Integration**: Seamless LangChain and other framework support
- **Web Interface**: Beautiful Vue.js frontend for visual management
- **Production Ready**: RESTful API and robust architecture

Whether you're building a single AI agent or managing a complex multi-agent system, MCPStore provides the tools and flexibility you need to succeed.

## Next Steps

1. Install MCPStore and try the basic examples
2. Explore the web interface and API endpoints
3. Integrate with your existing AI workflows
4. Join the community and contribute to the project

Start your MCPStore journey today and experience the future of MCP service management!

---

*For more tutorials and AI development resources, visit [Thaki Cloud](https://thakicloud.github.io).*




