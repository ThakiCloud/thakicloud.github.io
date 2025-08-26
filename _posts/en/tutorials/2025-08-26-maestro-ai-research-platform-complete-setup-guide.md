---
title: "MAESTRO: Complete AI-Powered Research Platform Setup and Usage Guide"
excerpt: "Comprehensive guide from installation to advanced usage of MAESTRO, an AI agent-based research automation platform"
seo_title: "MAESTRO AI Research Platform Setup Guide - Docker, GPU, Local LLM Integration - Thaki Cloud"
seo_description: "Complete tutorial for MAESTRO open-source AI research platform: installation, GPU optimization, SearXNG search engine integration, and local LLM configuration"
date: 2025-08-26
categories:
  - tutorials
tags:
  - maestro
  - ai-research
  - docker
  - fastapi
  - react
  - postgresql
  - pgvector
  - searxng
  - local-llm
  - gpu
author_profile: true
toc: true
toc_label: "Table of Contents"
canonical_url: "https://thakicloud.github.io/en/tutorials/maestro-ai-research-platform-complete-setup-guide/"
lang: en
permalink: /en/tutorials/maestro-ai-research-platform-complete-setup-guide/
---

⏱️ **Estimated Reading Time**: 25 minutes

## 1. Introduction to MAESTRO

### What is MAESTRO?

MAESTRO is an AI-powered research automation platform designed to efficiently handle complex research tasks. This open-source application automates entire research workflows from document collection to analysis and report generation using AI agents.

### Key Features

- **AI Agent-Based Research**: Automated research pipeline powered by LLMs
- **RAG (Retrieval-Augmented Generation)**: Vector search-based document processing
- **Real-time WebSocket Communication**: Live monitoring of task progress
- **Fully Self-Hosted**: Complete independent operation in local environments
- **Multiple LLM Support**: OpenAI, local LLMs, API-compatible models
- **SearXNG Integration**: Private metasearch engine connectivity

### Technology Stack

- **Backend**: FastAPI, SQLAlchemy, PostgreSQL, pgvector
- **Frontend**: React, TypeScript, Vite, Tailwind CSS
- **Infrastructure**: Docker Compose, WebSocket
- **AI/ML**: Vector embeddings, LLM API integration

## 2. System Requirements

### Minimum Hardware Specifications

```bash
# CPU Mode (Minimum)
- CPU: 4+ cores
- RAM: 8GB+
- Storage: 10GB+
- OS: Linux, macOS, Windows (WSL2)

# GPU Mode (Recommended)
- GPU: NVIDIA GPU (CUDA 11.0+)
- VRAM: 8GB+
- RAM: 16GB+
- Storage: 20GB+
```

### Required Software

```bash
# Common Requirements
- Docker Desktop (latest version)
- Docker Compose v2
- Git

# Additional for GPU Usage (Linux)
- nvidia-container-toolkit
- NVIDIA Drivers (latest)

# Windows Users
- WSL2 (Ubuntu 20.04+)
- Windows Terminal (recommended)
```

## 3. Installation and Initial Setup

### 3.1 Repository Clone and Basic Setup

```bash
# 1. Clone MAESTRO repository
git clone https://github.com/murtaza-nasir/maestro.git
cd maestro

# 2. Grant execution permissions (Linux/macOS)
chmod +x start.sh stop.sh detect_gpu.sh maestro-cli.sh

# 3. Create environment configuration file
cp .env.example .env
```

### 3.2 Environment Variables Configuration

Edit the `.env` file to configure basic settings:

```bash
# .env File Key Settings
# =====================

# Database Configuration
POSTGRES_DB=maestro_db
POSTGRES_USER=maestro_user
POSTGRES_PASSWORD=your_secure_password_here

# JWT Security Settings
JWT_SECRET_KEY=your_jwt_secret_key_here
JWT_ALGORITHM=HS256
JWT_ACCESS_TOKEN_EXPIRE_MINUTES=30

# LLM API Settings (for OpenAI)
OPENAI_API_KEY=your_openai_api_key_here
LLM_MODEL=gpt-4

# Local LLM Settings (for Ollama)
LOCAL_LLM_BASE_URL=http://localhost:11434/v1
LOCAL_LLM_MODEL=llama3.1:8b
USE_LOCAL_LLM=true

# Search Engine Configuration
SEARCH_ENGINE=searxng
SEARXNG_BASE_URL=http://searxng:8080

# GPU Configuration
GPU_AVAILABLE=true
BACKEND_GPU_DEVICE=0
DOC_PROCESSOR_GPU_DEVICE=0

# CPU-only Mode (for environments without GPU)
FORCE_CPU_MODE=false
```

### 3.3 GPU Support Verification

Check GPU support availability and apply optimal settings:

```bash
# Run GPU detection script
./detect_gpu.sh

# Example output:
# =========== GPU Detection Results ===========
# Platform: Linux
# GPU Support: Available
# NVIDIA Driver: 525.147.05
# CUDA Version: 12.0
# Recommended Configuration: GPU-enabled
# ===========================================
```

## 4. Platform-Specific Installation Guide

### 4.1 Linux (Ubuntu/Debian) - GPU Support

```bash
# 1. Install NVIDIA Container Toolkit
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

# 2. Restart Docker
sudo systemctl restart docker

# 3. Test GPU
docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi

# 4. Start MAESTRO
./start.sh
```

### 4.2 macOS (Apple Silicon/Intel)

```bash
# 1. Verify Docker Desktop installation
docker --version
docker-compose --version

# 2. Start in CPU-optimized mode
docker-compose -f docker-compose.cpu.yml up -d

# Or set environment variable and start normally
echo "FORCE_CPU_MODE=true" >> .env
./start.sh
```

### 4.3 Windows (WSL2)

Run PowerShell as Administrator:

```powershell
# 1. Verify WSL2 and Ubuntu installation
wsl --list --verbose

# 2. Verify Docker Desktop Windows execution
docker --version

# 3. Clone repository (inside WSL2)
wsl
cd /mnt/c/
git clone https://github.com/murtaza-nasir/maestro.git
cd maestro

# 4. Set permissions and start
chmod +x *.sh
./start.sh

# Or use PowerShell script
# .\start.ps1
```

## 5. Service Configuration and Startup

### 5.1 Basic Service Startup

```bash
# Start with automatic platform detection
./start.sh

# Or manually run Docker Compose
docker-compose up -d

# CPU-only mode
docker-compose -f docker-compose.cpu.yml up -d
```

### 5.2 Service Status Check

```bash
# Check container status
docker-compose ps

# Check logs
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f postgres
docker-compose logs -f searxng

# Check all logs
docker-compose logs -f
```

### 5.3 Database Initialization

```bash
# Check database status
./maestro-cli.sh reset-db --check

# Query database statistics
./maestro-cli.sh reset-db --stats

# Reset database with backup (if needed)
./maestro-cli.sh reset-db --backup
```

## 6. Web Interface Access and Initial Setup

### 6.1 First Access and Account Creation

```bash
# Access via browser
http://localhost:3000

# Or create admin account via CLI
./maestro-cli.sh create-user admin securepassword123 --admin
```

### 6.2 Basic Configuration

Navigate to the `Settings` menu in the web interface and configure:

```yaml
# LLM Settings
Model Provider: OpenAI / Local LLM
API Key: [YOUR_API_KEY]
Model Name: gpt-4 / llama3.1:8b
Temperature: 0.7
Max Tokens: 4000

# Search Settings
Search Engine: SearXNG
Categories: 
  - General
  - Science
  - IT
  - News
Results per Query: 10

# Research Parameters
Planning Context: 200000
Max Documents: 50
Chunk Size: 1000
Overlap: 200
```

## 7. Local LLM Integration (Ollama)

### 7.1 Ollama Installation and Setup

```bash
# Install Ollama (Linux/macOS)
curl -fsSL https://ollama.ai/install.sh | sh

# Windows (PowerShell)
# Invoke-WebRequest -Uri https://ollama.ai/install.ps1 -OutFile install.ps1; .\install.ps1

# Download models
ollama pull llama3.1:8b
ollama pull codellama:7b
ollama pull mistral:7b

# Start Ollama service
ollama serve
```

### 7.2 MAESTRO and Ollama Integration

Modify the `.env` file as follows:

```bash
# Local LLM Settings
USE_LOCAL_LLM=true
LOCAL_LLM_BASE_URL=http://host.docker.internal:11434/v1
LOCAL_LLM_MODEL=llama3.1:8b
LOCAL_LLM_API_KEY=ollama

# Use OpenAI-compatible endpoint
LLM_PROVIDER=local
```

### 7.3 Integration Testing

```bash
# Test model via CLI
./maestro-cli.sh test-llm

# Or test directly with Python script
python << EOF
import requests

response = requests.post('http://localhost:11434/v1/chat/completions', 
    json={
        'model': 'llama3.1:8b',
        'messages': [{'role': 'user', 'content': 'Hello, MAESTRO!'}],
        'max_tokens': 100
    }
)
print(response.json())
EOF
```

## 8. SearXNG Search Engine Configuration

### 8.1 SearXNG Container Configuration Check

```bash
# Check SearXNG container status
docker-compose logs searxng

# Check configuration file
docker-compose exec searxng cat /etc/searxng/settings.yml
```

### 8.2 Search Categories Configuration

Customize SearXNG's `settings.yml` file:

```yaml
# searxng/settings.yml
search:
  safe_search: 0
  autocomplete: duckduckgo
  default_lang: ""
  formats:
    - html
    - json  # Required for MAESTRO integration

categories:
  general:
    - google
    - bing
    - duckduckgo
  science:
    - arxiv
    - pubmed
    - semantic scholar
  it:
    - github
    - stackoverflow
    - documentation
  news:
    - google news
    - reuters
    - bbc
```

### 8.3 Private Search Testing

```bash
# Test SearXNG API
curl "http://localhost:8080/search?q=artificial+intelligence&format=json&category=science"

# Test search in MAESTRO
# Web Interface > Settings > Search > Test Search button
```

## 9. Practical Usage Scenarios

### 9.1 Document Collection and Analysis

```bash
# Bulk document upload via CLI
./maestro-cli.sh ingest username ./research_documents

# Supported formats
# - PDF, DOCX, TXT, MD
# - Web URLs, arXiv papers
# - JSON, CSV data

# Monitor upload progress
./maestro-cli.sh status username
```

### 9.2 Research Project Creation

Create a new research project in the web interface:

```yaml
# Research Configuration Example
Project Name: "AI Agent Architecture Analysis"
Research Question: "What are the latest trends in AI agent architectures?"
Scope: 
  - Academic papers (2023-2024)
  - Industry reports
  - Technical documentation
Output Format: "Comprehensive report with citations"
```

### 9.3 AI Agent Workflow Execution

```bash
# 1. Planning Phase
Research Agent -> Planning Context Analysis
              -> Outline Generation
              -> Resource Identification

# 2. Data Collection Phase  
Search Agent -> Web Search (SearXNG)
             -> Document Retrieval
             -> Content Extraction

# 3. Analysis Phase
Analysis Agent -> RAG-based Analysis
               -> Cross-reference Validation
               -> Insight Generation

# 4. Report Generation Phase
Report Agent -> Content Synthesis
             -> Citation Management
             -> Output Formatting
```

## 10. Advanced Configuration and Optimization

### 10.1 GPU Memory Optimization

```bash
# Monitor GPU memory
nvidia-smi -l 1

# Memory usage optimization settings
# Add to .env file
MAX_GPU_MEMORY=8192  # In MB
BATCH_SIZE=32
CHUNK_OVERLAP=100
```

### 10.2 Multi-GPU Configuration

```bash
# GPU allocation per service
BACKEND_GPU_DEVICE=0
DOC_PROCESSOR_GPU_DEVICE=1
CLI_GPU_DEVICE=0

# Check GPU load balancing
nvidia-smi topo -m
```

### 10.3 Performance Tuning

```bash
# PostgreSQL tuning
# In docker-compose.yml postgres service settings
environment:
  - POSTGRES_SHARED_PRELOAD_LIBRARIES=pg_stat_statements,auto_explain
  - POSTGRES_LOG_STATEMENT=all
  - POSTGRES_EFFECTIVE_CACHE_SIZE=4GB
  - POSTGRES_SHARED_BUFFERS=1GB

# pgvector index optimization
docker-compose exec postgres psql -U maestro_user -d maestro_db
CREATE INDEX CONCURRENTLY idx_embeddings_cosine ON documents 
USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
```

## 11. Troubleshooting Guide

### 11.1 Common Errors and Solutions

```bash
# 1. Port conflict error
Error: Port 3000 already in use
Solution: sudo lsof -i :3000; kill -9 <PID>

# 2. GPU memory shortage
CUDA out of memory
Solution: Set FORCE_CPU_MODE=true or adjust batch size

# 3. Database connection error
Connection refused to PostgreSQL
Solution: docker-compose restart postgres

# 4. Ollama connection failure
Local LLM connection failed
Solution: Use actual IP instead of host.docker.internal
```

### 11.2 Debugging Tools Usage

```bash
# Enable detailed logging
export MAESTRO_LOG_LEVEL=DEBUG
docker-compose up -d

# Access container internals
docker-compose exec backend bash
docker-compose exec postgres psql -U maestro_user -d maestro_db

# Health checks
curl http://localhost:8000/health
curl http://localhost:3000/health
```

### 11.3 Data Backup and Recovery

```bash
# Database backup
docker-compose exec postgres pg_dump -U maestro_user maestro_db > backup.sql

# Vector data backup (including pgvector extension)
docker-compose exec postgres pg_dump -U maestro_user -Fc maestro_db > backup.dump

# Recovery
docker-compose exec -T postgres psql -U maestro_user -d maestro_db < backup.sql
```

## 12. Security Considerations

### 12.1 Authentication and Authorization Management

```bash
# Generate strong JWT secret
openssl rand -hex 32

# User permission settings
./maestro-cli.sh create-user researcher pass123 --role user
./maestro-cli.sh create-user admin admin123 --role admin

# API key rotation
./maestro-cli.sh rotate-keys
```

### 12.2 Network Security

```bash
# Firewall configuration (Ubuntu/Debian)
sudo ufw allow from 192.168.1.0/24 to any port 3000
sudo ufw allow from 192.168.1.0/24 to any port 8000

# Reverse Proxy configuration (Nginx)
# nginx/maestro.conf
server {
    listen 443 ssl;
    server_name maestro.yourdomain.com;
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_websocket_upgrade on;
    }
    
    location /api {
        proxy_pass http://localhost:8000;
    }
}
```

## 13. Monitoring and Maintenance

### 13.1 System Monitoring

```bash
# Resource usage monitoring
docker stats maestro_backend maestro_frontend maestro_postgres

# Log rotation configuration
# Add to docker-compose.yml
logging:
  driver: json-file
  options:
    max-size: "100m"
    max-file: "3"

# Automatic health checks
# healthcheck.sh
#!/bin/bash
curl -f http://localhost:8000/health || exit 1
curl -f http://localhost:3000/ || exit 1
```

### 13.2 Regular Maintenance

```bash
# Weekly maintenance script
#!/bin/bash
# weekly_maintenance.sh

# 1. Update containers
docker-compose pull
docker-compose up -d

# 2. Database cleanup
./maestro-cli.sh cleanup-orphaned-docs

# 3. Log compression
find /var/log/maestro -name "*.log" -mtime +7 -exec gzip {} \;

# 4. System status report
./maestro-cli.sh system-report > /var/log/maestro/weekly_report_$(date +%Y%m%d).txt
```

## 14. Extension and Customization

### 14.1 Custom AI Agent Development

```python
# maestro_backend/agents/custom_agent.py
from maestro_backend.core.agent_base import BaseAgent

class CustomResearchAgent(BaseAgent):
    def __init__(self, config):
        super().__init__(config)
        self.specialty = "domain_specific_research"
    
    async def process_request(self, request):
        """Implement custom research logic"""
        results = await self.search_documents(request.query)
        analysis = await self.analyze_with_llm(results)
        return await self.generate_report(analysis)
    
    async def search_documents(self, query):
        """Domain-specific search logic"""
        # Implementation logic
        pass
```

### 14.2 API Extension

```python
# maestro_backend/api/custom_endpoints.py
from fastapi import APIRouter, Depends
from maestro_backend.core.auth import get_current_user

router = APIRouter(prefix="/api/custom", tags=["custom"])

@router.post("/domain-research")
async def domain_research(
    request: DomainResearchRequest,
    current_user: User = Depends(get_current_user)
):
    """Custom domain research endpoint"""
    agent = CustomResearchAgent(config)
    results = await agent.process_request(request)
    return {"results": results, "status": "completed"}
```

## 15. Troubleshooting Checklist

### 15.1 Post-Installation Checklist

- [ ] All Docker containers running (`docker-compose ps`)
- [ ] Ports 3000, 8000, 5432, 8080 accessible
- [ ] Database connection normal (`./maestro-cli.sh reset-db --check`)
- [ ] LLM API connection test passed
- [ ] Web interface login available
- [ ] Search functionality working normally

### 15.2 Performance Optimization Checklist

- [ ] GPU memory usage monitoring
- [ ] PostgreSQL index optimization
- [ ] SearXNG response speed verification
- [ ] Document processing batch size adjustment
- [ ] Cache configuration verification

## 16. Conclusion

MAESTRO presents a powerful platform that introduces a new paradigm for AI-powered research automation. Through this tutorial, you can completely master everything from basic installation to advanced configuration.

### Key Achievements

✅ **Complete Self-Hosted Environment Setup**  
✅ **AI Agent-Based Research Workflow Implementation**  
✅ **Local LLM and Private Search Engine Integration**  
✅ **Scalable Architecture Understanding**  

### Next Steps

1. **Advanced AI Agent Development**: Implement domain-specific research agents
2. **Enterprise Environment Deployment**: Consider Kubernetes cluster deployment
3. **API Integration**: Expand integration with existing research tools
4. **Community Contribution**: Participate in MAESTRO open-source project

Experience revolutionary research productivity improvements with MAESTRO and explore the infinite possibilities of AI agents! 🚀

---

**References**
- [MAESTRO GitHub Repository](https://github.com/murtaza-nasir/maestro)
- [Docker Compose Official Documentation](https://docs.docker.com/compose/)
- [PostgreSQL + pgvector Guide](https://github.com/pgvector/pgvector)
- [SearXNG Configuration Guide](https://docs.searxng.org/)
