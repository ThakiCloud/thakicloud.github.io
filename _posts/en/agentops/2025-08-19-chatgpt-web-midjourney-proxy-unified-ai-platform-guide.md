---
title: "ChatGPT Web Midjourney Proxy: A Complete Guide to a Unified AI Platform"
excerpt: "A guide to building and operating an AgentOps platform that consolidates ChatGPT, Midjourney, GPTs, Suno, Luma, and other AI services into a single interface."
seo_title: "ChatGPT Midjourney Unified AI Platform Build Guide - Thaki Cloud"
seo_description: "A complete AgentOps guide for building a multi-AI-agent unified management platform using Docker-based ChatGPT Web Midjourney Proxy. Integrates a Vue.js-based web UI with real-time voice, image, and video generation AI services."
date: 2025-08-19
last_modified_at: 2025-08-19
lang: en
categories:
  - agentops
  - tutorials
tags:
  - chatgpt
  - midjourney
  - ai-platform
  - docker
  - vue.js
  - suno
  - luma
  - gpts
  - agentops
  - ai-integration
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/en/agentops/chatgpt-web-midjourney-proxy-unified-ai-platform-guide/"
reading_time: true
---

![Key concept illustration](/assets/images/chatgpt-web-midjourney-proxy-unified-ai-platform-guide-hero.png)

⏱️ **Estimated reading time**: 15 min

## Introduction

As AI services proliferate, managing multiple separate platforms has become a serious productivity drain. **ChatGPT Web Midjourney Proxy** is an open-source project that addresses this pain directly by integrating ChatGPT, Midjourney, GPTs, Suno, and Luma into a single web interface.

This guide covers everything you need to know -- from environment setup to production deployment and advanced AgentOps strategies.

![Architecture diagram](/assets/images/chatgpt-web-midjourney-proxy-unified-ai-platform-guide-diagram.svg)

*Architecture diagram*

## Project Overview

ChatGPT Web Midjourney Proxy is a unified AI management platform built on the following core capabilities:

### Supported AI Services

| Category | Services | Notes |
|----------|----------|-------|
| **Conversational AI** | ChatGPT GPT-3.5/4/4o | Multi-model support |
| **Image Generation** | Midjourney v6 | Full mode support |
| **Custom Agents** | GPT Store | Thousands of community GPTs |
| **Music Generation** | Suno | Lyrics-based song creation |
| **Video Generation** | Luma, Runway, Pika | Multi-engine |
| **Real-Time API** | Realtime API | Voice and text streaming |

### Technology Stack

```json
{
  "frontend": {
    "framework": "Vue.js 3.5.18",
    "ui_library": "Naive UI 2.42.0",
    "css_framework": "Tailwind CSS 3.4.17",
    "state_management": "Pinia 2.3.1",
    "build_tool": "Vite 4.5.14",
    "language": "TypeScript 4.9.5"
  },
  "deployment": {
    "container": "Docker",
    "proxy": "Nginx",
    "orchestration": "Kubernetes (optional)"
  }
}
```

## Environment Setup

### System Requirements

- **Docker**: 28.2.2 or later
- **Node.js**: 22.17.1 or later (for local development)
- **pnpm**: 10.13.1 or later

### macOS Setup

```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Node.js
brew install node

# Install pnpm
npm install -g pnpm

# Verify installation
node --version    # v22.17.1
pnpm --version    # 10.13.1
```

### Install Project Dependencies

```bash
# Clone the repository
git clone https://github.com/Dooy/chatgpt-web-midjourney-proxy.git
cd chatgpt-web-midjourney-proxy

# Install dependencies
pnpm install

# Verify installed packages
pnpm list
```

**Example installation output:**
```
packages/
  chatgpt-web-midjourney-proxy@1.0.0 (node_modules/.pnpm)
  ├── vue@3.5.18
  ├── naive-ui@2.42.0
  ├── pinia@2.3.1
  └── ... (907 packages)
```

## Configuration

### Environment Variables

Create a `.env.local` file:

```bash
# OpenAI API Configuration
OPENAI_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
OPENAI_API_BASE_URL=https://api.openai.com

# Midjourney Configuration (MJ-Proxy)
MJ_SERVER=https://your-mj-proxy-server.com
MJ_API_SECRET=your-mj-api-secret

# Suno Music Generation
SUNO_API_URL=https://api.suno.ai
SUNO_API_KEY=your-suno-key

# Luma Video Generation
LUMA_API_URL=https://api.lumalabs.ai
LUMA_API_KEY=your-luma-key

# Security Settings
AUTH_SECRET_KEY=your-random-secret-key-here

# Cloudflare R2 (file storage)
R2_ACCOUNT_ID=your-r2-account-id
R2_ACCESS_KEY_ID=your-r2-access-key
R2_SECRET_ACCESS_KEY=your-r2-secret-key
R2_BUCKET_NAME=your-r2-bucket-name
R2_PUBLIC_URL=https://your-r2-public-url.com
```

### Docker Compose Setup

```yaml
# docker-compose.yml
version: '3.8'

services:
  chatgpt-web:
    image: ydlhero/chatgpt-web-midjourney-proxy:latest
    container_name: chatgpt-web-mj
    restart: unless-stopped
    ports:
      - "6050:3002"
    environment:
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - OPENAI_API_BASE_URL=${OPENAI_API_BASE_URL}
      - MJ_SERVER=${MJ_SERVER}
      - MJ_API_SECRET=${MJ_API_SECRET}
      - AUTH_SECRET_KEY=${AUTH_SECRET_KEY}
    volumes:
      - ./data:/app/data
      - ./logs:/app/logs
    networks:
      - ai-platform-network

networks:
  ai-platform-network:
    driver: bridge
```

### Start with Docker Compose

```bash
# Start containers
docker-compose up -d

# Verify status
docker-compose ps

# Check logs
docker-compose logs -f chatgpt-web
```

## Local Development Server

### Start the Dev Server

```bash
# Start dev server
pnpm dev

# Build for production
pnpm build

# Preview production build
pnpm preview
```

**Expected output:**
```
  VITE v4.5.14  ready in 1247 ms

  ➜  Local:   http://localhost:1002/
  ➜  Network: use --host to expose
```

## Cloudflare R2 Setup

Cloudflare R2 is used for storing generated images and videos:

```bash
# Install Wrangler CLI
npm install -g wrangler

# Log in
wrangler login

# Create R2 bucket
wrangler r2 bucket create ai-platform-storage

# Set CORS policy
cat > cors.json << 'EOF'
[
  {
    "AllowedOrigins": ["*"],
    "AllowedMethods": ["GET", "PUT", "POST", "DELETE"],
    "AllowedHeaders": ["*"],
    "MaxAgeSeconds": 3600
  }
]
EOF

wrangler r2 bucket cors put ai-platform-storage --rules cors.json
```

## Security Configuration

### Brute Force Protection

```javascript
// src/middleware/rateLimiter.ts
import rateLimit from 'express-rate-limit'

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5,                    // 5 attempts
  message: {
    code: 429,
    message: 'Too many login attempts. Please try again in 15 minutes.'
  },
  standardHeaders: true,
  legacyHeaders: false,
})

const apiLimiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 minute
  max: 60,                  // 60 requests
  message: {
    code: 429,
    message: 'Too many API requests.'
  }
})

export { loginLimiter, apiLimiter }
```

### Custom Model Configuration

```javascript
// src/config/models.ts
export const CUSTOM_MODELS = {
  'gpt-4o-mini': {
    name: 'GPT-4o Mini',
    maxTokens: 128000,
    costPer1K: 0.00015,
    capabilities: ['text', 'vision']
  },
  'claude-3-5-sonnet': {
    name: 'Claude 3.5 Sonnet',
    maxTokens: 200000,
    costPer1K: 0.003,
    capabilities: ['text', 'vision', 'code']
  },
  'midjourney-v6': {
    name: 'Midjourney v6',
    type: 'image-generation',
    outputResolution: '2048x2048'
  }
}
```

## Multimodal Workflow

A core strength of this platform is the ability to chain AI services into a pipeline:

### Text to Image to Video to Music

```mermaid
graph LR
  A[Text Prompt] --> B[ChatGPT GPT-4o]
  B --> C[Refined Prompt]
  C --> D[Midjourney v6]
  D --> E[Generated Image]
  E --> F[Luma AI]
  F --> G[Video Clip]
  G --> H[Suno AI]
  H --> I[Complete Content]
```

**Implementation:**

```python
# multimodal_workflow.py
import asyncio
from typing import Optional

class MultimodalWorkflow:
    def __init__(self, config: dict):
        self.openai_client = OpenAIClient(config['openai_api_key'])
        self.mj_client = MidjourneyClient(config['mj_server'])
        self.luma_client = LumaClient(config['luma_api_key'])
        self.suno_client = SunoClient(config['suno_api_key'])
    
    async def text_to_complete_content(
        self, 
        prompt: str,
        style: Optional[str] = None
    ) -> dict:
        """Complete content generation pipeline"""
        
        print(f"Starting content pipeline: {prompt}")
        
        # Step 1: Refine prompt with ChatGPT
        refined_prompt = await self.openai_client.refine_prompt(
            prompt=prompt,
            system_message="You are a visual art director. Refine this prompt for Midjourney."
        )
        
        # Step 2: Generate image with Midjourney
        image_result = await self.mj_client.imagine(
            prompt=f"{refined_prompt} --v 6 --ar 16:9",
            webhook_url="https://your-domain.com/webhook/mj"
        )
        
        # Step 3: Generate video with Luma
        video_result = await self.luma_client.generate_video(
            image_url=image_result['image_url'],
            prompt=f"Cinematic motion: {refined_prompt}",
            duration=5
        )
        
        # Step 4: Generate music with Suno
        music_result = await self.suno_client.generate_music(
            lyrics=f"Visual journey: {prompt}",
            style=style or "cinematic ambient"
        )
        
        return {
            'original_prompt': prompt,
            'refined_prompt': refined_prompt,
            'image_url': image_result['image_url'],
            'video_url': video_result['video_url'],
            'music_url': music_result['audio_url'],
            'metadata': {
                'image_model': 'midjourney-v6',
                'video_model': 'luma-ai',
                'music_model': 'suno-v3'
            }
        }
```

## AI Agent Role Distribution

Allocate responsibilities across AI agents for enterprise scenarios:

```yaml
# agent-roles.yml
agents:
  content_strategist:
    model: "gpt-4o"
    role: "Strategic planning and content direction"
    responsibilities:
      - Analyze target audience and market positioning
      - Define content strategy and messaging
      - Ensure brand consistency
    
  visual_creator:
    model: "midjourney-v6"
    role: "Visual content generation"
    responsibilities:
      - Image creation
      - Brand identity design
      - Illustration and infographics
  
  video_producer:
    model: "luma-ai"
    role: "Video content production"
    responsibilities:
      - Image-to-video conversion
      - Motion graphics
      - Social media video clips
    
  music_composer:
    model: "suno-v3"
    role: "Background music and audio"
    responsibilities:
      - BGM generation aligned with content mood
      - Jingle creation
      - Podcast intros and outros

orchestration:
  workflow: "sequential"
  error_handling: "retry_with_fallback"
  max_retries: 3
  timeout_seconds: 120
```

## Realtime API Configuration

The integrated Realtime API enables voice and text streaming:

```javascript
// src/services/realtimeService.ts
import OpenAI from 'openai'

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
})

export class RealtimeService {
  private ws: WebSocket | null = null
  
  async connectRealtime(sessionId: string) {
    // Get ephemeral token
    const response = await openai.beta.realtime.sessions.create({
      model: 'gpt-4o-realtime-preview',
      voice: 'alloy',
      instructions: 'You are a helpful assistant.',
      input_audio_format: 'pcm16',
      output_audio_format: 'pcm16'
    })
    
    const token = response.client_secret.value
    
    // Connect WebSocket
    this.ws = new WebSocket(
      'wss://api.openai.com/v1/realtime?model=gpt-4o-realtime-preview',
      {
        headers: {
          'Authorization': `Bearer ${token}`,
          'OpenAI-Beta': 'realtime=v1'
        }
      }
    )
    
    this.ws.on('message', (data: Buffer) => {
      const event = JSON.parse(data.toString())
      this.handleRealtimeEvent(event)
    })
    
    return this.ws
  }
  
  private handleRealtimeEvent(event: any) {
    switch (event.type) {
      case 'response.audio.delta':
        // Handle audio streaming
        this.playAudioChunk(event.delta)
        break
        
      case 'response.text.delta':
        // Handle text streaming
        this.updateTextDisplay(event.delta)
        break
        
      case 'input_audio_buffer.speech_started':
        console.log('Speech detected')
        break
    }
  }
}
```

## Performance Optimization

### Token Usage Optimization

```javascript
// src/utils/tokenOptimizer.ts
export class TokenOptimizer {
  
  optimizeContext(messages: Message[], maxTokens: number = 4000): Message[] {
    let totalTokens = 0
    const optimizedMessages: Message[] = []
    
    // Keep system message
    const systemMessage = messages.find(m => m.role === 'system')
    if (systemMessage) {
      optimizedMessages.push(systemMessage)
      totalTokens += this.countTokens(systemMessage.content)
    }
    
    // Keep recent messages from newest
    const userMessages = messages
      .filter(m => m.role !== 'system')
      .reverse()
    
    for (const message of userMessages) {
      const tokens = this.countTokens(message.content)
      if (totalTokens + tokens > maxTokens) break
      
      optimizedMessages.unshift(message)
      totalTokens += tokens
    }
    
    return optimizedMessages
  }
  
  private countTokens(text: string): number {
    // Rough estimate: ~4 characters per token
    return Math.ceil(text.length / 4)
  }
}
```

### Caching Strategy

```javascript
// src/services/cacheService.ts
import { createClient } from 'redis'

export class CacheService {
  private client = createClient({ url: process.env.REDIS_URL })
  
  async getCachedResponse(key: string): Promise<string | null> {
    return await this.client.get(key)
  }
  
  async setCachedResponse(
    key: string, 
    value: string, 
    ttl: number = 3600
  ): Promise<void> {
    await this.client.setEx(key, ttl, value)
  }
  
  generateCacheKey(model: string, messages: Message[]): string {
    const hash = require('crypto')
      .createHash('md5')
      .update(JSON.stringify({ model, messages }))
      .digest('hex')
    
    return `response:${model}:${hash}`
  }
}
```

### Nginx Load Balancing

```nginx
# nginx.conf
upstream ai_platform_backend {
    least_conn;
    server backend1:3002 weight=3;
    server backend2:3002 weight=2;
    server backend3:3002 weight=1;
    keepalive 32;
}

server {
    listen 80;
    server_name your-domain.com;
    
    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com;
    
    ssl_certificate /etc/ssl/certs/your-cert.pem;
    ssl_certificate_key /etc/ssl/private/your-key.pem;
    
    # WebSocket support
    location /api/v1/chat/completions {
        proxy_pass http://ai_platform_backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header X-Real-IP $remote_addr;
        proxy_buffering off;
        proxy_read_timeout 300s;
    }
    
    # Static assets
    location / {
        proxy_pass http://ai_platform_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        
        # Cache static assets
        location ~* \.(js|css|png|jpg|svg)$ {
            expires 1y;
            add_header Cache-Control "public, no-transform";
        }
    }
}
```

## Monitoring and Operations

### Container Monitoring

```bash
# Real-time container stats
docker stats chatgpt-web-mj

# Check logs
docker logs chatgpt-web-mj --tail=100 -f

# Container health check
docker inspect --format='{{.State.Health.Status}}' chatgpt-web-mj
```

### API Metrics

```javascript
// src/middleware/metrics.ts
import { Counter, Histogram, register } from 'prom-client'

const httpRequestCount = new Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code']
})

const httpRequestDuration = new Histogram({
  name: 'http_request_duration_seconds',
  help: 'HTTP request duration',
  labelNames: ['method', 'route'],
  buckets: [0.1, 0.5, 1, 2, 5, 10]
})

const aiApiCallCount = new Counter({
  name: 'ai_api_calls_total',
  help: 'Total AI API calls by service',
  labelNames: ['service', 'model', 'status']
})

export { httpRequestCount, httpRequestDuration, aiApiCallCount }
```

## Troubleshooting

### Port Conflicts

```bash
# Check port 6050
lsof -i :6050

# Kill the conflicting process
kill -9 $(lsof -t -i:6050)

# Change port in docker-compose.yml
ports:
  - "6051:3002"  # Changed to 6051
```

### API Key Errors

```bash
# Verify OpenAI key
curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer ${OPENAI_API_KEY}"

# Verify Midjourney proxy
curl ${MJ_SERVER}/mj/submit/imagine \
  -H "mj-api-secret: ${MJ_API_SECRET}" \
  -H "Content-Type: application/json" \
  -d '{"prompt": "test"}'
```

### Memory Limit Issues

```yaml
# Increase memory in docker-compose.yml
services:
  chatgpt-web:
    deploy:
      resources:
        limits:
          memory: 2G
        reservations:
          memory: 1G
```

### Slow Response Times

```javascript
// src/config/timeouts.ts
export const TIMEOUT_CONFIG = {
  // Chat completions
  chatCompletion: 60000,    // 60 seconds
  
  // Image generation (longer for Midjourney)
  imageGeneration: 300000,  // 5 minutes
  
  // Video generation (longest pipeline)
  videoGeneration: 600000,  // 10 minutes
  
  // Music generation
  musicGeneration: 120000,  // 2 minutes
}
```

## Security Hardening

### API Key Encryption

```javascript
// src/utils/encryption.ts
import CryptoJS from 'crypto-js'

export class EncryptionService {
  private secretKey: string
  
  constructor(secretKey: string) {
    this.secretKey = secretKey
  }
  
  encrypt(text: string): string {
    return CryptoJS.AES.encrypt(text, this.secretKey).toString()
  }
  
  decrypt(encryptedText: string): string {
    const bytes = CryptoJS.AES.decrypt(encryptedText, this.secretKey)
    return bytes.toString(CryptoJS.enc.Utf8)
  }
}
```

### Docker Secrets

```yaml
# docker-compose.yml with secrets
version: '3.8'

services:
  chatgpt-web:
    image: ydlhero/chatgpt-web-midjourney-proxy:latest
    secrets:
      - openai_api_key
      - mj_api_secret
    environment:
      - OPENAI_API_KEY_FILE=/run/secrets/openai_api_key
      - MJ_API_SECRET_FILE=/run/secrets/mj_api_secret

secrets:
  openai_api_key:
    file: ./secrets/openai_api_key.txt
  mj_api_secret:
    file: ./secrets/mj_api_secret.txt
```

## Kubernetes Deployment

For enterprise-scale deployment:

```yaml
# kubernetes/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: chatgpt-web-mj
  namespace: ai-platform
spec:
  replicas: 3
  selector:
    matchLabels:
      app: chatgpt-web-mj
  template:
    metadata:
      labels:
        app: chatgpt-web-mj
    spec:
      containers:
      - name: chatgpt-web-mj
        image: ydlhero/chatgpt-web-midjourney-proxy:latest
        ports:
        - containerPort: 3002
        env:
        - name: OPENAI_API_KEY
          valueFrom:
            secretKeyRef:
              name: ai-platform-secrets
              key: openai-api-key
        resources:
          requests:
            cpu: "500m"
            memory: "512Mi"
          limits:
            cpu: "2000m"
            memory: "2Gi"
        livenessProbe:
          httpGet:
            path: /health
            port: 3002
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 3002
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: chatgpt-web-mj-service
  namespace: ai-platform
spec:
  selector:
    app: chatgpt-web-mj
  ports:
  - port: 80
    targetPort: 3002
  type: LoadBalancer
```

## Cost Optimization

```javascript
// src/utils/costOptimizer.ts
export class CostOptimizer {
  
  selectOptimalModel(task: TaskType, requirements: Requirements): string {
    const modelCosts: Record<string, number> = {
      'gpt-4o': 0.005,        // per 1K tokens
      'gpt-4o-mini': 0.00015,
      'gpt-3.5-turbo': 0.0005,
    }
    
    // Use cheaper model for simple tasks
    if (task === 'simple_qa' && !requirements.vision) {
      return 'gpt-3.5-turbo'
    }
    
    // Use mini model for most tasks
    if (!requirements.complex_reasoning) {
      return 'gpt-4o-mini'
    }
    
    // Full model only for complex tasks
    return 'gpt-4o'
  }
  
  estimateMonthlyCost(usage: UsageStats): CostEstimate {
    return {
      chatApi: usage.tokens * 0.003 / 1000,
      imageGeneration: usage.images * 0.04,
      videoGeneration: usage.videoSeconds * 0.1,
      storage: usage.storageGB * 0.015,
      total: 0 // sum of above
    }
  }
}
```

## Test Automation

```bash
#!/bin/bash
# test-platform.sh

echo "Starting platform test"

BASE_URL="http://localhost:6050"

# Health check
echo "1. Health check"
response=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/health")
if [ "$response" = "200" ]; then
    echo "PASS: Health check"
else
    echo "FAIL: Health check (status: $response)"
    exit 1
fi

# ChatGPT API test
echo "2. ChatGPT API test"
chat_response=$(curl -s -X POST "$BASE_URL/api/v1/chat/completions" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d '{
        "model": "gpt-4o-mini",
        "messages": [{"role": "user", "content": "Hello! Reply with OK."}],
        "max_tokens": 10
    }')

if echo "$chat_response" | grep -q "OK"; then
    echo "PASS: ChatGPT API"
else
    echo "FAIL: ChatGPT API"
    echo "Response: $chat_response"
fi

# Authentication test
echo "3. Auth test"
auth_response=$(curl -s -X POST "$BASE_URL/api/auth/login" \
    -H "Content-Type: application/json" \
    -d "{\"secret\": \"$AUTH_SECRET_KEY\"}")

if echo "$auth_response" | grep -q "token"; then
    echo "PASS: Auth"
else
    echo "FAIL: Auth"
fi

echo "Tests complete"
```

## CI/CD Pipeline

```yaml
# .github/workflows/deploy.yml
name: Deploy AI Platform

on:
  push:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '22'
        
    - name: Install pnpm
      run: npm install -g pnpm
      
    - name: Install dependencies
      run: pnpm install
      
    - name: Run tests
      run: pnpm test
      
    - name: Build
      run: pnpm build

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Build Docker image
      run: |
        docker build -t chatgpt-web-mj:${{ github.sha }} .
        docker tag chatgpt-web-mj:${{ github.sha }} chatgpt-web-mj:latest
        
    - name: Deploy to Kubernetes
      run: |
        kubectl set image deployment/chatgpt-web-mj \
          chatgpt-web-mj=chatgpt-web-mj:${{ github.sha }} \
          -n ai-platform
        kubectl rollout status deployment/chatgpt-web-mj -n ai-platform
```

## Actual Test Results

### Installation Verification

```bash
$ pnpm install
Packages: +907
Progress: resolved 907, reused 0, downloaded 907, added 907
Done in 45.2s

$ pnpm dev
> chatgpt-web-midjourney-proxy@1.0.0 dev
> vite --port 1002

  VITE v4.5.14  ready in 1247 ms

  ➜  Local:   http://localhost:1002/
  ➜  Network: use --host to expose
```

### Package Versions Confirmed

| Package | Version | Status |
|---------|---------|--------|
| Vue.js | 3.5.18 | Verified |
| Naive UI | 2.42.0 | Verified |
| Tailwind CSS | 3.4.17 | Verified |
| Pinia | 2.3.1 | Verified |
| Vite | 4.5.14 | Verified |
| TypeScript | 4.9.5 | Verified |

## Conclusion

ChatGPT Web Midjourney Proxy provides a practical solution for consolidating and managing multiple AI services under a unified platform. By leveraging the features described in this guide, teams can:

1. **Boost productivity**: Manage all AI tools in one place, eliminating context-switching overhead
2. **Reduce costs**: Implement caching and model selection to optimize API spend
3. **Ensure security**: Protect API keys and user data with hardened configurations
4. **Scale reliably**: Use Kubernetes for enterprise-grade deployment
5. **Automate workflows**: Integrate AI services into continuous delivery pipelines

The multimodal workflow capabilities open up creative possibilities that simply were not accessible before the aggregation of these tools.

---

> **References**
> - [ChatGPT Web Midjourney Proxy GitHub](https://github.com/Dooy/chatgpt-web-midjourney-proxy)
> - [OpenAI Realtime API Documentation](https://platform.openai.com/docs/api-reference/realtime)
> - [Midjourney API Documentation](https://docs.midjourney.com/)
> - [Luma AI API Documentation](https://docs.lumalabs.ai/)
