---
title: "Eclaire: Building Your Own Local-First AI Assistant for Personal Data Management"
excerpt: "Complete guide to setting up and using Eclaire, an open-source AI assistant that unifies tasks, notes, docs, photos, and bookmarks while keeping your data private and local."
seo_title: "Eclaire Local-First AI Assistant Tutorial - Complete Setup Guide"
seo_description: "Learn how to set up Eclaire, the open-source local-first AI assistant for personal data management. Step-by-step tutorial with installation, configuration, and usage examples."
date: 2025-10-03
categories:
  - tutorials
tags:
  - eclaire
  - ai-assistant
  - local-first
  - privacy
  - data-management
  - open-source
  - llm
  - self-hosted
author_profile: true
toc: true
toc_label: "Table of Contents"
lang: en
permalink: /en/tutorials/eclaire-local-first-ai-assistant-tutorial/
canonical_url: "https://thakicloud.github.io/en/tutorials/eclaire-local-first-ai-assistant-tutorial/"
---

⏱️ **Estimated Reading Time**: 15 minutes

## Introduction

In an era where data privacy and AI capabilities are increasingly important, **Eclaire** emerges as a groundbreaking solution that combines the power of artificial intelligence with the security of local-first architecture. This open-source AI assistant allows you to unify tasks, notes, documents, photos, and bookmarks while keeping all your data completely private and under your control.

Unlike cloud-based AI assistants that send your data to external servers, Eclaire runs entirely on your local machine, ensuring that your sensitive information never leaves your device. This tutorial will guide you through the complete process of setting up, configuring, and using Eclaire to transform how you manage your personal and professional data.

## What is Eclaire?

Eclaire is a **local-first, open-source AI assistant** designed to help you organize and interact with your personal data ecosystem. Built with privacy as a core principle, it provides intelligent assistance without compromising your data security.

### Key Features

**🔒 Privacy-First Architecture**
- All data processing happens locally on your machine
- No external API calls or cloud dependencies for core functionality
- Complete control over your data and AI interactions

**🤖 Advanced AI Capabilities**
- Support for multiple LLM backends (llama.cpp, vLLM, MLX, Ollama)
- Intelligent document processing and OCR
- Multi-modal AI support for text and images
- Tool calling and agentic capabilities

**📊 Unified Data Management**
- Task management and note-taking
- Document processing and archiving
- Photo organization with AI-powered analysis
- Bookmark management with content extraction
- Full-text search across all data types

**🛠️ Developer-Friendly**
- RESTful API for extensibility
- Modular architecture with clear separation of concerns
- Docker support for easy deployment
- Comprehensive documentation and community support

### Architecture Overview

Eclaire follows a modern, modular architecture:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Backend API   │    │ Background      │
│   (Next.js)     │◄──►│   (Node.js)     │◄──►│ Workers         │
│                 │    │                 │    │ (BullMQ/Redis)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 ▼
                    ┌─────────────────┐
                    │   Data Layer    │
                    │ PostgreSQL +    │
                    │ File Storage    │
                    └─────────────────┘
                                 ▲
                    ┌─────────────────┐
                    │   AI Services   │
                    │ Local LLM       │
                    │ Backends        │
                    └─────────────────┘
```

## Prerequisites and System Requirements

Before installing Eclaire, ensure your system meets the following requirements:

### Hardware Requirements

**Minimum Configuration:**
- **RAM**: 16GB (32GB recommended for larger models)
- **Storage**: 50GB free space (for models and data)
- **CPU**: Modern multi-core processor (Intel/AMD x64 or Apple Silicon)

**Recommended Configuration:**
- **RAM**: 32GB or more
- **Storage**: 100GB+ SSD
- **GPU**: Optional but recommended for faster inference
- **CPU**: Apple Silicon M1+ or modern Intel/AMD with AVX2 support

### Software Dependencies

**Core Requirements:**
- **Node.js**: Version 18+ 
- **Docker**: Latest version with Docker Compose
- **Git**: For cloning the repository

**System Dependencies (will be installed automatically):**
- PostgreSQL 15+
- Redis 7+
- PM2 (Process Manager)

**Optional Dependencies for Enhanced Features:**
- LibreOffice (for document processing)
- Poppler (for PDF processing) 
- GraphicsMagick/ImageMagick (for image processing)
- Ghostscript (for PostScript processing)
- libheif (for HEIC/HEIF photo processing)

### Operating System Support

Eclaire supports the following operating systems:

- **macOS**: 10.15+ (Catalina and later)
- **Linux**: Ubuntu 20.04+, Debian 11+, CentOS 8+
- **Windows**: Windows 10+ with WSL2

## Installation Guide

### Step 1: Install System Dependencies

**For macOS:**
```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install required dependencies
brew install node git docker
brew install --cask libreoffice
brew install poppler graphicsmagick imagemagick ghostscript libheif

# Start Docker Desktop
open /Applications/Docker.app
```

**For Ubuntu/Debian:**
```bash
# Update package list
sudo apt update

# Install Node.js 18+
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Docker
sudo apt-get install -y docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Install additional dependencies
sudo apt-get install -y libreoffice poppler-utils graphicsmagick imagemagick ghostscript libheif-examples

# Log out and back in for Docker group changes to take effect
```

### Step 2: Clone and Setup Eclaire

```bash
# Clone the repository
git clone https://github.com/eclaire-labs/eclaire.git
cd eclaire

# Run the automated setup
npm run setup:dev
```

The setup script will:
1. Check all system dependencies
2. Copy environment configuration files
3. Create required data directories
4. Install npm dependencies for all applications
5. Start dependencies (PostgreSQL, Redis, AI models via PM2)
6. Initialize the database with sample data

**Note:** The first run will download AI models automatically, which may take 5-10 minutes depending on your internet connection and the selected models.

### Step 3: Monitor Setup Progress

You can monitor the AI model download and setup progress:

```bash
# Check PM2 processes
pm2 list

# Monitor AI model loading logs
pm2 logs llama_backend --lines 100

# Check overall system status
pm2 monit
```

### Step 4: Start Development Servers

```bash
# Start all development servers
npm run dev
```

This will start:
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:3001
- **Background Workers**: Running via PM2

### Step 5: Verify Installation

Open your browser and navigate to `http://localhost:3000`. You should see the Eclaire interface.

Test the backend API:
```bash
curl http://localhost:3001/health
```

Expected response:
```json
{
  "status": "ok",
  "timestamp": "2025-10-03T10:30:00.000Z",
  "services": {
    "database": "connected",
    "redis": "connected",
    "ai_backend": "ready"
  }
}
```

## Configuration and Model Selection

### Understanding Eclaire's AI Architecture

Eclaire uses two types of AI models:

1. **Backend Model**: For AI assistant conversations and tool calling
2. **Workers Model**: For document processing and multi-modal tasks

### Default Model Configuration

By default, Eclaire comes configured with:
- **Backend**: Qwen3 14B Q4_K_XL GGUF (for conversations)
- **Workers**: Gemma3 4B Q4_K_XL GGUF (for processing)

These models are chosen to run efficiently on typical development machines (MacBook Pro M1+ with 32GB RAM).

### Checking Current Models

```bash
# List currently configured models
./tools/model-cli/run.sh list
```

Expected output:
```
┌─────────────────────────────────────────┬───────────┬─────────────────────────────────┬─────────────────────────────────┬──────────────────┬─────────────┐
│ ID                                      │ Provider  │ Short Name                      │ Model                           │ Context          │ Status      │
├─────────────────────────────────────────┼───────────┼─────────────────────────────────┼─────────────────────────────────┼──────────────────┼─────────────┤
│ llamacpp-qwen3-14b-gguf-q4-k-xl         │ llamacpp  │ qwen3-14b-gguf-q4_k_xl          │ qwen3-14b-gguf-q4_k_xl          │ backend          │ 🟢 ACTIVE   │
├─────────────────────────────────────────┼───────────┼─────────────────────────────────┼─────────────────────────────────┼──────────────────┼─────────────┤
│ llamacpp-gemma-3-4b-it-qat-gguf-q4-k-xl │ llamacpp  │ gemma-3-4b-it-qat-gguf-q4_k_xl  │ gemma-3-4b-it-qat-gguf-q4_k_xl  │ workers          │ 🟢 ACTIVE   │
└─────────────────────────────────────────┴───────────┴─────────────────────────────────┴─────────────────────────────────┴──────────────────┴─────────────┘
```

### Changing Models

If you want to use different models:

1. **Import a new model:**
```bash
# Example: Import a larger model
./tools/model-cli/run.sh import https://huggingface.co/mlx-community/Qwen3-30B-A3B-4bit-DWQ-10072025
```

2. **Update PM2 configuration:**
Edit `pm2.deps.config.js` to use your new model:
```javascript
{
  name: 'llama_backend',
  script: 'llama-server',
  args: '-hf your-new-model-repo:model-file --port 11434',
  // ... other configuration
}
```

3. **Download the model locally:**
```bash
# Pre-download to avoid delays during first use
printf '' | llama-cli --hf-repo your-new-model-repo -n 0 --no-warmup
```

4. **Restart services:**
```bash
pm2 restart pm2.deps.config.js
```

### Supported LLM Backends

Eclaire supports multiple LLM backends:

- **llama.cpp**: Default, excellent for GGUF models
- **vLLM**: High-performance inference server
- **MLX**: Optimized for Apple Silicon
- **Ollama**: User-friendly model management
- **Custom OpenAI-compatible endpoints**

## Core Features and Usage

### 1. AI Assistant Conversations

The AI assistant is your primary interface for interacting with Eclaire:

**Starting a Conversation:**
1. Open Eclaire at `http://localhost:3000`
2. Click on the chat interface
3. Type your question or request

**Example Interactions:**
```
User: "Help me organize my project notes"
Assistant: I can help you organize your notes. Would you like me to:
1. Create categories for your existing notes
2. Set up a new project structure
3. Search through your current notes for specific topics

User: "Find all documents related to 'machine learning'"
Assistant: I'll search through your documents for machine learning content...
[Returns relevant documents with summaries]
```

### 2. Document Management

**Uploading Documents:**
1. Navigate to the Documents section
2. Drag and drop files or use the upload button
3. Eclaire will automatically process and index the content

**Supported Formats:**
- **Text**: TXT, MD, RTF
- **Documents**: PDF, DOC, DOCX, ODT
- **Presentations**: PPT, PPTX, ODP
- **Spreadsheets**: XLS, XLSX, ODS
- **Images**: JPG, PNG, GIF, HEIC, HEIF (with OCR)
- **Web**: HTML, MHTML

**Document Processing Features:**
- **OCR**: Automatic text extraction from images and scanned PDFs
- **Metadata Extraction**: Author, creation date, keywords
- **Content Summarization**: AI-generated summaries
- **Full-Text Search**: Search within document content

### 3. Task Management

**Creating Tasks:**
```javascript
// Via API
POST /api/tasks
{
  "title": "Review quarterly reports",
  "description": "Analyze Q3 performance metrics",
  "priority": "high",
  "due_date": "2025-10-15",
  "tags": ["quarterly", "analysis"]
}
```

**Task Features:**
- Priority levels (low, medium, high, urgent)
- Due dates and reminders
- Tag-based organization
- AI-powered task suggestions
- Progress tracking

### 4. Note-Taking System

**Creating Notes:**
1. Use the Notes interface
2. Write in Markdown format
3. Add tags for organization
4. Link to related documents or tasks

**Advanced Features:**
- **Bi-directional linking**: Connect related notes
- **AI summarization**: Generate note summaries
- **Search integration**: Find notes by content
- **Version history**: Track note changes

### 5. Photo Organization

**Photo Upload and Processing:**
1. Upload photos via the Photos section
2. Eclaire automatically extracts metadata
3. AI analyzes content for tagging
4. OCR processes any text in images

**AI-Powered Features:**
- **Object detection**: Identify people, objects, scenes
- **Text extraction**: OCR for documents in photos
- **Smart tagging**: Automatic tag generation
- **Duplicate detection**: Find similar images

### 6. Bookmark Management

**Adding Bookmarks:**
1. Use the browser extension (if available)
2. Manually add URLs via the interface
3. Import from browser bookmark files

**Content Processing:**
- **Page archiving**: Save full page content
- **Metadata extraction**: Title, description, keywords
- **Content summarization**: AI-generated summaries
- **Link analysis**: Identify related bookmarks

## Advanced Configuration

### Environment Variables

Key configuration files:
- `apps/backend/.env`: Backend API configuration
- `apps/frontend/.env`: Frontend application settings
- `apps/workers/.env`: Background worker settings

**Important Variables:**
```bash
# Database Configuration
DATABASE_URL=postgresql://eclaire:password@localhost:5432/eclaire

# Redis Configuration  
REDIS_URL=redis://localhost:6379

# AI Model Configuration
AI_LOCAL_PROVIDER_URL=http://localhost:11434/v1
AI_WORKERS_PROVIDER_URL=http://localhost:11435/v1

# Security
JWT_SECRET=your-secure-jwt-secret
ENCRYPTION_KEY=your-32-character-encryption-key

# File Storage
STORAGE_PATH=./data/users
MAX_FILE_SIZE=100MB
```

### Database Configuration

**PostgreSQL Settings:**
```sql
-- Recommended PostgreSQL configuration for Eclaire
-- Add to postgresql.conf

shared_preload_libraries = 'pg_stat_statements'
max_connections = 100
shared_buffers = 256MB
effective_cache_size = 1GB
work_mem = 4MB
maintenance_work_mem = 64MB
```

### Performance Optimization

**For Better Performance:**

1. **SSD Storage**: Use SSD for database and file storage
2. **Memory Allocation**: Allocate sufficient RAM for models
3. **CPU Optimization**: Enable all available CPU cores
4. **GPU Acceleration**: Use GPU-enabled models if available

**Model Performance Tuning:**
```bash
# Adjust model parameters in pm2.deps.config.js
args: [
  '--model', 'your-model-path',
  '--ctx-size', '4096',        # Context window size
  '--threads', '8',            # CPU threads
  '--gpu-layers', '35',        # GPU acceleration
  '--batch-size', '512'        # Batch processing
]
```

## API Reference

### Authentication

Eclaire uses JWT-based authentication:

```javascript
// Login
POST /api/auth/login
{
  "username": "your-username",
  "password": "your-password"
}

// Response
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "username": "your-username",
    "email": "user@example.com"
  }
}
```

### Core API Endpoints

**Documents:**
```javascript
// Upload document
POST /api/documents
Content-Type: multipart/form-data

// Get documents
GET /api/documents?page=1&limit=20&search=query

// Get document by ID
GET /api/documents/:id

// Delete document
DELETE /api/documents/:id
```

**Tasks:**
```javascript
// Create task
POST /api/tasks
{
  "title": "Task title",
  "description": "Task description",
  "priority": "medium",
  "due_date": "2025-10-15T10:00:00Z"
}

// Update task
PUT /api/tasks/:id
{
  "status": "completed"
}

// Get tasks
GET /api/tasks?status=pending&priority=high
```

**Search:**
```javascript
// Universal search
GET /api/search?q=query&type=documents&limit=10

// Advanced search
POST /api/search/advanced
{
  "query": "machine learning",
  "filters": {
    "type": ["documents", "notes"],
    "date_range": {
      "start": "2025-01-01",
      "end": "2025-10-03"
    },
    "tags": ["ai", "research"]
  }
}
```

**AI Assistant:**
```javascript
// Chat with AI
POST /api/chat
{
  "message": "Help me find documents about AI",
  "context": {
    "conversation_id": "uuid-here",
    "user_preferences": {}
  }
}

// Response
{
  "response": "I found 5 documents about AI...",
  "actions": [
    {
      "type": "search_results",
      "data": [...]
    }
  ],
  "conversation_id": "uuid-here"
}
```

## Troubleshooting

### Common Issues and Solutions

**1. Models Not Loading**
```bash
# Check model status
pm2 logs llama_backend

# Common solutions:
# - Ensure sufficient RAM (16GB+ recommended)
# - Check model file integrity
# - Verify Hugging Face connectivity
# - Restart PM2 processes: pm2 restart all
```

**2. Database Connection Issues**
```bash
# Check PostgreSQL status
pm2 logs postgres

# Verify connection
psql -h localhost -U eclaire -d eclaire

# Reset database if needed
npm run db:reset
```

**3. Frontend Not Loading**
```bash
# Check frontend logs
npm run dev

# Common solutions:
# - Clear browser cache
# - Check port 3000 availability
# - Verify backend API connectivity
# - Restart development server
```

**4. File Upload Failures**
```bash
# Check storage permissions
ls -la data/users/

# Verify disk space
df -h

# Check file size limits in .env
MAX_FILE_SIZE=100MB
```

**5. AI Processing Slow**
```bash
# Monitor system resources
top
htop

# Optimize model parameters
# Edit pm2.deps.config.js:
# - Reduce context size
# - Adjust thread count
# - Enable GPU if available
```

### Performance Monitoring

**System Health Check:**
```bash
# Overall system status
curl http://localhost:3001/health

# Detailed metrics
curl http://localhost:3001/metrics

# PM2 monitoring
pm2 monit

# Database performance
psql -d eclaire -c "SELECT * FROM pg_stat_activity;"
```

### Log Analysis

**Important Log Locations:**
```bash
# Application logs
tail -f data/logs/backend.log
tail -f data/logs/workers.log
tail -f data/logs/frontend.log

# PM2 logs
pm2 logs --lines 100

# System logs (Linux)
journalctl -u docker
```

## Security Considerations

### Data Privacy

**Local-First Architecture Benefits:**
- All data processing happens locally
- No external API calls for core functionality
- Complete control over data access and retention
- Compliance with privacy regulations (GDPR, CCPA)

### Security Best Practices

**1. Environment Security:**
```bash
# Use strong passwords and keys
JWT_SECRET=$(openssl rand -base64 32)
ENCRYPTION_KEY=$(openssl rand -base64 32)

# Restrict file permissions
chmod 600 .env*
chmod 700 data/
```

**2. Network Security:**
```bash
# Bind to localhost only (default)
HOST=127.0.0.1
PORT=3000

# Use HTTPS in production
SSL_CERT_PATH=/path/to/cert.pem
SSL_KEY_PATH=/path/to/key.pem
```

**3. Database Security:**
```sql
-- Create dedicated database user
CREATE USER eclaire WITH PASSWORD 'strong-password';
GRANT ALL PRIVILEGES ON DATABASE eclaire TO eclaire;

-- Enable row-level security
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;
```

### Backup and Recovery

**Automated Backup Script:**
```bash
#!/bin/bash
# backup-eclaire.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="./backups/$DATE"

mkdir -p "$BACKUP_DIR"

# Backup database
pg_dump -h localhost -U eclaire eclaire > "$BACKUP_DIR/database.sql"

# Backup user data
tar -czf "$BACKUP_DIR/user_data.tar.gz" data/users/

# Backup configuration
cp -r config/ "$BACKUP_DIR/"
cp .env* "$BACKUP_DIR/"

echo "Backup completed: $BACKUP_DIR"
```

**Recovery Process:**
```bash
# Restore database
psql -h localhost -U eclaire eclaire < backup/database.sql

# Restore user data
tar -xzf backup/user_data.tar.gz -C ./

# Restore configuration
cp backup/.env* ./
cp -r backup/config/ ./
```

## Conclusion

Eclaire represents a significant step forward in personal AI assistance, combining the power of modern large language models with the security and privacy of local-first architecture. By following this comprehensive tutorial, you now have:

1. **A fully functional local AI assistant** running on your own hardware
2. **Complete control over your data** with no external dependencies
3. **Advanced AI capabilities** for document processing, task management, and intelligent search
4. **A solid foundation** for customization and extension

### Key Benefits Achieved

- **Privacy Protection**: Your sensitive data never leaves your device
- **Performance**: Local processing eliminates network latency
- **Customization**: Full control over models and configuration
- **Cost Efficiency**: No ongoing subscription fees or API costs
- **Reliability**: No dependence on external services or internet connectivity

### Next Steps

**Immediate Actions:**
1. Start using Eclaire for your daily tasks and document management
2. Upload your existing documents and notes
3. Experiment with different AI models to find the best fit for your needs
4. Set up automated backups to protect your data

**Advanced Exploration:**
1. **API Integration**: Build custom applications using Eclaire's REST API
2. **Model Optimization**: Fine-tune models for your specific use cases
3. **Workflow Automation**: Create automated workflows for document processing
4. **Community Contribution**: Contribute to the open-source project

### Resources and Community

- **Official Repository**: [https://github.com/eclaire-labs/eclaire](https://github.com/eclaire-labs/eclaire)
- **Documentation**: Comprehensive guides and API references
- **Community Support**: GitHub Issues for questions and bug reports
- **Contributing**: Help improve Eclaire for everyone

Eclaire is more than just an AI assistant—it's a platform for building the future of personal data management. With its strong foundation in privacy, security, and extensibility, you're well-equipped to take control of your digital life while harnessing the power of artificial intelligence.

Start exploring, experimenting, and building with Eclaire today. Your private, intelligent, and powerful AI assistant awaits!



