---
title: "Shannon AI Agent Orchestrator: Complete Tutorial for Enterprise-Grade AI Agent Management"
excerpt: "Learn how to set up and use Shannon, an open-source AI agent orchestrator with enterprise-grade security, cost controls, and vendor flexibility. A comprehensive guide from installation to advanced multi-agent workflows."
seo_title: "Shannon AI Agent Orchestrator Tutorial - Enterprise AI Agent Management"
seo_description: "Complete tutorial for Shannon AI Agent Orchestrator: installation, configuration, multi-agent workflows, security features, and enterprise deployment guide."
date: 2025-10-11
categories:
  - tutorials
tags:
  - AI-Agent
  - Orchestrator
  - Multi-Agent
  - Enterprise-AI
  - Shannon
  - Docker
  - Microservices
  - LLM
author_profile: true
toc: true
toc_label: "Table of Contents"
lang: en
permalink: /en/tutorials/shannon-ai-agent-orchestrator-tutorial/
canonical_url: "https://thakicloud.github.io/en/tutorials/shannon-ai-agent-orchestrator-tutorial/"
---

⏱️ **Estimated Reading Time**: 15 minutes

## Introduction

Shannon is an open-source AI agent orchestrator that provides enterprise-grade security, cost controls, and vendor flexibility. Unlike proprietary solutions like OpenAI AgentKit, Shannon offers complete control over your AI infrastructure while maintaining production-ready reliability and scalability.

### What Makes Shannon Special?

Shannon stands out in the AI agent orchestration landscape with its unique architecture and features:

- **Multi-language Architecture**: Go orchestrator, Rust agent-core, Python LLM service
- **Enterprise Security**: OPA policy enforcement, WASI sandbox, fine-grained access control
- **Cost Management**: Token budget management, circuit breaker patterns, automatic failure recovery
- **Vendor Flexibility**: Multi-provider LLM support (OpenAI, Anthropic, Google, DeepSeek)
- **Advanced Memory**: Vector memory with Qdrant, hierarchical memory, near-duplicate detection
- **Real-time Communication**: WebSocket and SSE streaming with event filtering

## Prerequisites

Before starting this tutorial, ensure you have:

- Docker and Docker Compose installed
- Basic understanding of containerized applications
- Familiarity with REST APIs and microservices
- An API key from at least one LLM provider (OpenAI, Anthropic, etc.)

## Installation and Setup

### 1. Clone the Repository

```bash
git clone https://github.com/Kocoro-lab/Shannon.git
cd Shannon
```

### 2. Environment Configuration

Create your environment configuration:

```bash
cp .env.example .env
```

Edit the `.env` file with your configuration:

```bash
# LLM Provider Configuration
OPENAI_API_KEY=your_openai_api_key_here
ANTHROPIC_API_KEY=your_anthropic_api_key_here

# Database Configuration
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_DB=shannon
POSTGRES_USER=shannon
POSTGRES_PASSWORD=your_secure_password

# Redis Configuration
REDIS_HOST=redis
REDIS_PORT=6379

# Qdrant Vector Database
QDRANT_HOST=qdrant
QDRANT_PORT=6333

# Service Ports
ORCHESTRATOR_PORT=8080
AGENT_CORE_PORT=8081
LLM_SERVICE_PORT=8082
```

### 3. Start Shannon Services

Shannon provides a convenient Makefile for service management:

```bash
# Start all services
make up

# View service status
make ps

# View logs
make logs

# Stop services
make down
```

### 4. Verify Installation

Check that all services are running:

```bash
# Check orchestrator health
curl http://localhost:8080/health

# Check agent-core health
curl http://localhost:8081/health

# Check LLM service health
curl http://localhost:8082/health
```

## Core Concepts

### Architecture Overview

Shannon follows a microservices architecture with three main components:

1. **Go Orchestrator**: Manages workflows, sessions, and agent coordination
2. **Rust Agent-Core**: Handles agent execution, memory management, and tool integration
3. **Python LLM Service**: Provides unified interface to multiple LLM providers

### Agent Patterns

Shannon supports multiple orchestration patterns:

- **ReAct**: Reasoning and Acting in language models
- **Tree-of-Thoughts**: Explores multiple reasoning paths
- **Chain-of-Thought**: Sequential reasoning steps
- **Debate**: Multiple agents discuss and reach consensus
- **Reflection**: Self-evaluation and improvement

## Basic Usage Tutorial

### 1. Creating Your First Agent

Let's create a simple agent that can answer questions and perform basic tasks:

```bash
curl -X POST http://localhost:8080/api/v1/agents \
  -H "Content-Type: application/json" \
  -d '{
    "name": "research-assistant",
    "description": "A helpful research assistant",
    "system_prompt": "You are a knowledgeable research assistant. Provide accurate, well-researched answers to user questions.",
    "model_provider": "openai",
    "model_name": "gpt-4",
    "max_tokens": 2000,
    "temperature": 0.7
  }'
```

### 2. Starting a Session

Create a session to interact with your agent:

```bash
curl -X POST http://localhost:8080/api/v1/sessions \
  -H "Content-Type: application/json" \
  -d '{
    "agent_id": "research-assistant",
    "session_config": {
      "max_turns": 50,
      "context_window": 10,
      "memory_enabled": true
    }
  }'
```

### 3. Sending Messages

Send a message to your agent:

```bash
curl -X POST http://localhost:8080/api/v1/sessions/{session_id}/messages \
  -H "Content-Type: application/json" \
  -d '{
    "content": "What are the key benefits of microservices architecture?",
    "message_type": "user"
  }'
```

### 4. Streaming Responses

For real-time responses, use the streaming endpoint:

```bash
curl -N http://localhost:8080/api/v1/sessions/{session_id}/stream \
  -H "Accept: text/event-stream"
```

## Advanced Features

### Multi-Agent Workflows

Shannon excels at orchestrating multiple agents working together. Here's how to set up a multi-agent workflow:

#### 1. Define Agent Roles

```yaml
# workflow.yaml
name: "content-creation-pipeline"
description: "Multi-agent content creation workflow"

agents:
  - name: "researcher"
    role: "research"
    system_prompt: "You are a thorough researcher. Gather comprehensive information on given topics."
    model: "gpt-4"
    
  - name: "writer"
    role: "content-creation"
    system_prompt: "You are a skilled writer. Create engaging content based on research."
    model: "claude-3-sonnet"
    
  - name: "editor"
    role: "review"
    system_prompt: "You are a meticulous editor. Review and improve content quality."
    model: "gpt-4"

workflow:
  pattern: "sequential"
  steps:
    - agent: "researcher"
      task: "Research the given topic thoroughly"
      output_to: ["writer"]
      
    - agent: "writer"
      task: "Create content based on research"
      input_from: ["researcher"]
      output_to: ["editor"]
      
    - agent: "editor"
      task: "Review and refine the content"
      input_from: ["writer"]
      final_output: true
```

#### 2. Execute Multi-Agent Workflow

```bash
curl -X POST http://localhost:8080/api/v1/workflows \
  -H "Content-Type: application/json" \
  -d '{
    "workflow_file": "workflow.yaml",
    "input": {
      "topic": "The Future of AI in Healthcare",
      "target_audience": "healthcare professionals",
      "word_count": 1500
    }
  }'
```

### Memory Management

Shannon provides sophisticated memory management capabilities:

#### Vector Memory Configuration

```json
{
  "memory_config": {
    "vector_memory": {
      "enabled": true,
      "collection_name": "agent_memory",
      "embedding_model": "text-embedding-ada-002",
      "similarity_threshold": 0.8,
      "max_results": 10
    },
    "hierarchical_memory": {
      "enabled": true,
      "recent_messages": 20,
      "semantic_compression": true,
      "deduplication_threshold": 0.95
    }
  }
}
```

#### Querying Agent Memory

```bash
curl -X GET "http://localhost:8080/api/v1/sessions/{session_id}/memory?query=microservices+benefits&limit=5" \
  -H "Accept: application/json"
```

### Security and Access Control

Shannon uses Open Policy Agent (OPA) for fine-grained access control:

#### 1. Define Security Policies

```rego
# policies/agent_access.rego
package shannon.agent_access

import future.keywords.if

# Allow access if user has required role
allow if {
    input.user.roles[_] == "agent_operator"
    input.action == "create_agent"
}

# Restrict model access based on user tier
allow if {
    input.user.tier == "premium"
    input.agent.model in ["gpt-4", "claude-3-opus"]
}

# Budget enforcement
allow if {
    input.user.monthly_budget > input.estimated_cost
}
```

#### 2. Apply Policies

```bash
curl -X POST http://localhost:8080/api/v1/policies \
  -H "Content-Type: application/json" \
  -d '{
    "name": "agent_access_policy",
    "policy_file": "policies/agent_access.rego",
    "enabled": true
  }'
```

### Cost Management

Shannon provides comprehensive cost management features:

#### 1. Set Budget Limits

```bash
curl -X POST http://localhost:8080/api/v1/budgets \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "user123",
    "monthly_limit": 100.00,
    "per_session_limit": 10.00,
    "alert_threshold": 0.8,
    "currency": "USD"
  }'
```

#### 2. Monitor Usage

```bash
curl -X GET http://localhost:8080/api/v1/usage/user123 \
  -H "Accept: application/json"
```

### Tool Integration

Shannon supports multiple tool integration methods:

#### 1. MCP (Model Context Protocol) Tools

```json
{
  "tools": [
    {
      "type": "mcp",
      "name": "file_operations",
      "server_url": "mcp://localhost:3000",
      "capabilities": ["read_file", "write_file", "list_directory"]
    }
  ]
}
```

#### 2. OpenAPI Tools

```json
{
  "tools": [
    {
      "type": "openapi",
      "name": "weather_api",
      "spec_url": "https://api.weather.com/openapi.json",
      "auth": {
        "type": "api_key",
        "key": "your_weather_api_key"
      }
    }
  ]
}
```

## Production Deployment

### Docker Compose Production Setup

For production deployment, use the provided production configuration:

```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  orchestrator:
    image: shannon/orchestrator:latest
    environment:
      - ENV=production
      - LOG_LEVEL=info
    deploy:
      replicas: 3
      resources:
        limits:
          memory: 1G
          cpus: '0.5'
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  agent-core:
    image: shannon/agent-core:latest
    deploy:
      replicas: 2
      resources:
        limits:
          memory: 2G
          cpus: '1.0'

  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: shannon_prod
      POSTGRES_USER: shannon
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    deploy:
      resources:
        limits:
          memory: 2G

volumes:
  postgres_data:
```

### Kubernetes Deployment

Shannon also provides Kubernetes manifests for cloud deployment:

```yaml
# k8s/orchestrator-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shannon-orchestrator
spec:
  replicas: 3
  selector:
    matchLabels:
      app: shannon-orchestrator
  template:
    metadata:
      labels:
        app: shannon-orchestrator
    spec:
      containers:
      - name: orchestrator
        image: shannon/orchestrator:latest
        ports:
        - containerPort: 8080
        env:
        - name: POSTGRES_HOST
          value: "postgres-service"
        - name: REDIS_HOST
          value: "redis-service"
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
```

## Monitoring and Observability

Shannon includes comprehensive monitoring capabilities:

### 1. Metrics Collection

Shannon exposes Prometheus metrics:

```bash
# View available metrics
curl http://localhost:8080/metrics
```

### 2. Grafana Dashboards

Import the provided Grafana dashboard:

```bash
# Import Shannon dashboard
curl -X POST http://grafana:3000/api/dashboards/db \
  -H "Content-Type: application/json" \
  -d @observability/grafana/shannon-dashboard.json
```

### 3. Distributed Tracing

Enable distributed tracing with Jaeger:

```yaml
# docker-compose.yml
services:
  jaeger:
    image: jaegertracing/all-in-one:latest
    ports:
      - "16686:16686"
      - "14268:14268"
    environment:
      - COLLECTOR_OTLP_ENABLED=true
```

## Troubleshooting

### Common Issues and Solutions

#### 1. Service Connection Issues

```bash
# Check service logs
make logs

# Restart specific service
docker-compose restart orchestrator

# Check network connectivity
docker network ls
docker network inspect shannon_default
```

#### 2. Memory Issues

```bash
# Monitor memory usage
docker stats

# Adjust memory limits in docker-compose.yml
services:
  agent-core:
    deploy:
      resources:
        limits:
          memory: 4G
```

#### 3. Database Connection Issues

```bash
# Check PostgreSQL logs
docker-compose logs postgres

# Test database connection
docker-compose exec postgres psql -U shannon -d shannon -c "SELECT 1;"
```

### Performance Optimization

#### 1. Connection Pooling

Configure connection pooling for better performance:

```yaml
# config/database.yaml
database:
  max_connections: 100
  max_idle_connections: 10
  connection_max_lifetime: 3600
```

#### 2. Caching Configuration

Optimize Redis caching:

```yaml
# config/redis.yaml
redis:
  max_connections: 50
  idle_timeout: 300
  cache_ttl: 3600
```

## Best Practices

### 1. Agent Design

- **Single Responsibility**: Design agents with specific, well-defined roles
- **Clear System Prompts**: Provide detailed, unambiguous instructions
- **Appropriate Model Selection**: Choose models based on task complexity and cost requirements

### 2. Workflow Design

- **Error Handling**: Implement robust error handling and fallback mechanisms
- **Resource Management**: Set appropriate timeouts and resource limits
- **Monitoring**: Include comprehensive logging and monitoring

### 3. Security

- **API Key Management**: Use secure secret management systems
- **Access Control**: Implement fine-grained access control policies
- **Audit Logging**: Enable comprehensive audit logging for compliance

### 4. Cost Optimization

- **Budget Monitoring**: Set up alerts for budget thresholds
- **Model Selection**: Use cost-effective models for appropriate tasks
- **Caching**: Implement intelligent caching to reduce API calls

## Conclusion

Shannon AI Agent Orchestrator provides a powerful, flexible platform for building and deploying enterprise-grade AI agent systems. With its microservices architecture, comprehensive security features, and advanced orchestration capabilities, Shannon enables organizations to harness the power of AI agents while maintaining control, security, and cost efficiency.

The platform's open-source nature ensures transparency and customizability, while its production-ready features make it suitable for enterprise deployment. Whether you're building simple chatbots or complex multi-agent workflows, Shannon provides the tools and infrastructure needed for success.

### Next Steps

1. **Explore Advanced Patterns**: Experiment with different orchestration patterns like Tree-of-Thoughts and Debate
2. **Custom Tool Development**: Create custom tools using the MCP protocol
3. **Production Deployment**: Deploy Shannon in your production environment
4. **Community Engagement**: Join the Shannon community on Discord and contribute to the project

### Resources

- **GitHub Repository**: [https://github.com/Kocoro-lab/Shannon](https://github.com/Kocoro-lab/Shannon)
- **Documentation**: Available in the `docs/` directory
- **Discord Community**: Join for support and discussions
- **Contributing Guide**: See `CONTRIBUTING.md` for contribution guidelines

Shannon represents the future of AI agent orchestration - open, secure, and enterprise-ready. Start building your AI agent systems today!
