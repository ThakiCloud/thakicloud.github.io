---
title: "Motia: Complete Tutorial for the Modern Unified Backend Framework"
excerpt: "Learn how to build unified APIs, background jobs, workflows, and AI agents with Motia - the framework that eliminates backend fragmentation using JavaScript, TypeScript, and Python."
seo_title: "Motia Tutorial: Unified Backend Framework Guide - Thaki Cloud"
seo_description: "Master Motia framework with hands-on examples: APIs, background jobs, workflows, AI agents in one system. JavaScript, TypeScript, Python support included."
date: 2025-09-10
categories:
  - tutorials
tags:
  - motia
  - backend-framework
  - javascript
  - typescript
  - python
  - apis
  - workflows
  - ai-agents
author_profile: true
toc: true
toc_label: "Table of Contents"
lang: en
permalink: /en/tutorials/motia-modern-backend-framework-tutorial/
canonical_url: "https://thakicloud.github.io/en/tutorials/motia-modern-backend-framework-tutorial/"
---

⏱️ **Estimated Reading Time**: 15 minutes

## Introduction

Modern backend development is **fragmented**. APIs live in Express.js, background jobs run in Bull Queue, workflows use separate orchestration tools, and AI agents exist in their own isolated runtimes. This fragmentation creates complexity, maintenance overhead, and operational challenges.

**[Motia](https://github.com/motiadev/motia)** solves this problem by unifying APIs, background jobs, workflows, and AI agents into a **single coherent system**. Similar to how React unified frontend development around components, Motia unifies backend development around **Steps**.

### What Makes Motia Different?

- **🔄 Unified System**: APIs, jobs, workflows, and AI agents in one framework
- **🌐 Multi-Language**: JavaScript, TypeScript, Python, Ruby support
- **👀 Built-in Observability**: Visual debugging and tracing out of the box
- **⚡ Zero Configuration**: Get started in under 60 seconds
- **🎯 Step-Based Architecture**: Everything is a Step with consistent patterns

## Prerequisites

Before starting this tutorial, ensure you have:

- **Node.js 16+** installed
- **npm or pnpm** package manager
- **Basic knowledge** of JavaScript/TypeScript
- **Python 3.8+** (for multi-language examples)
- **Terminal/Command line** access

## Chapter 1: Installation and Setup

### 1.1 Environment Verification

First, let's verify your development environment:

```bash
# Check Node.js version
node --version
# Should be 16.x or higher

# Check npm version
npm --version

# Check Python version (optional for multi-language features)
python3 --version
# Should be 3.8 or higher
```

### 1.2 Creating Your First Motia Project

Motia provides an interactive project generator that sets up everything you need:

```bash
# Create a new Motia project
npx motia@latest create -i

# Follow the interactive prompts:
# ✅ Project name: motia-tutorial
# ✅ Template: Full-stack (recommended)
# ✅ Language: TypeScript
# ✅ Features: API + Background Jobs + AI Integration
```

This creates a complete project structure:

```
motia-tutorial/
├── motia/
│   ├── steps/           # Your business logic
│   ├── events/          # Event definitions
│   └── workflows/       # Workflow configurations
├── web/                 # Frontend (optional)
├── package.json
└── motia.config.js      # Framework configuration
```

### 1.3 Starting the Development Environment

Navigate to your project and start the Motia development server:

```bash
cd motia-tutorial

# Install dependencies
npm install

# Start the development server
npx motia dev
```

This launches:
- **🌐 Motia Workbench**: http://localhost:3000 (Visual debugging interface)
- **🔌 API Server**: http://localhost:3001 (Your REST endpoints)
- **📊 Real-time Monitoring**: Live execution tracing

## Chapter 2: Understanding Steps

In Motia, **everything is a Step**. Steps are the fundamental building blocks that can be:

### 2.1 Step Types Overview

| Type | Trigger | Use Case | Example |
|------|---------|----------|---------|
| **api** | HTTP Request | REST endpoints | User registration |
| **event** | Message/Topic | Background processing | Email sending |
| **cron** | Schedule | Recurring jobs | Daily reports |
| **noop** | Manual | External processes | Third-party webhooks |

### 2.2 Creating Your First API Step

Let's create a user management API:

```typescript
// motia/steps/users/create-user.ts
import { api } from '@motia/core';
import { z } from 'zod';

// Input validation schema
const CreateUserSchema = z.object({
  name: z.string().min(2),
  email: z.string().email(),
  role: z.enum(['user', 'admin']).default('user')
});

export default api({
  id: 'create-user',
  method: 'POST',
  path: '/users',
  schema: {
    body: CreateUserSchema
  }
}, async ({ body }) => {
  // Simulate user creation
  const user = {
    id: Math.random().toString(36).substr(2, 9),
    ...body,
    createdAt: new Date().toISOString()
  };

  // Trigger welcome email event
  await motia.trigger('send-welcome-email', {
    userId: user.id,
    email: user.email,
    name: user.name
  });

  return {
    success: true,
    user
  };
});
```

### 2.3 Creating Background Event Steps

Now let's handle the welcome email as a background job:

```typescript
// motia/steps/emails/send-welcome-email.ts
import { event } from '@motia/core';
import { z } from 'zod';

const WelcomeEmailSchema = z.object({
  userId: z.string(),
  email: z.string().email(),
  name: z.string()
});

export default event({
  id: 'send-welcome-email',
  schema: WelcomeEmailSchema
}, async ({ userId, email, name }) => {
  // Simulate email sending delay
  await new Promise(resolve => setTimeout(resolve, 2000));

  console.log(`📧 Welcome email sent to ${name} (${email})`);

  // Update user record
  await motia.trigger('update-user-status', {
    userId,
    status: 'welcomed'
  });

  return {
    emailSent: true,
    timestamp: new Date().toISOString()
  };
});
```

### 2.4 Testing Your API

With the development server running, test your API:

```bash
# Create a new user
curl -X POST http://localhost:3001/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "role": "user"
  }'
```

Expected response:
```json
{
  "success": true,
  "user": {
    "id": "abc123def",
    "name": "John Doe",
    "email": "john@example.com",
    "role": "user",
    "createdAt": "2025-09-10T10:30:00.000Z"
  }
}
```

## Chapter 3: Multi-Language Support

One of Motia's powerful features is **seamless multi-language integration**. Let's add Python-based AI processing to our workflow.

### 3.1 Setting Up Python Integration

First, ensure Python dependencies are configured:

```bash
# Create Python requirements file
cat > requirements.txt << EOF
openai>=1.0.0
numpy>=1.21.0
pandas>=1.3.0
EOF

# Install Python dependencies
pip3 install -r requirements.txt
```

### 3.2 Creating Python-Based AI Steps

Create an AI-powered user analysis step:

```python
# motia/steps/ai/analyze_user_behavior.py
from motia import event
import json
import random
from typing import Dict, Any

@event(
    id="analyze-user-behavior",
    schema={
        "userId": str,
        "actions": list,
        "metadata": dict
    }
)
async def analyze_user_behavior(userId: str, actions: list, metadata: dict) -> Dict[str, Any]:
    """Analyze user behavior patterns using AI"""
    
    # Simulate AI processing
    behavior_score = random.uniform(0.1, 1.0)
    
    # Simple behavior analysis
    analysis = {
        "userId": userId,
        "behaviorScore": behavior_score,
        "riskLevel": "low" if behavior_score > 0.7 else "medium" if behavior_score > 0.4 else "high",
        "recommendations": [],
        "processedAt": "2025-09-10T10:30:00.000Z"
    }
    
    # Add recommendations based on score
    if behavior_score < 0.4:
        analysis["recommendations"].append("Increase user engagement activities")
        analysis["recommendations"].append("Send personalized content")
    elif behavior_score < 0.7:
        analysis["recommendations"].append("Monitor user activity closely")
    else:
        analysis["recommendations"].append("User shows excellent engagement")
    
    print(f"🤖 AI Analysis completed for user {userId}: {analysis['riskLevel']} risk")
    
    return analysis
```

### 3.3 Connecting TypeScript and Python Steps

Update your user creation flow to include AI analysis:

```typescript
// motia/steps/users/create-user.ts (updated)
export default api({
  id: 'create-user',
  method: 'POST',
  path: '/users',
  schema: {
    body: CreateUserSchema
  }
}, async ({ body }) => {
  const user = {
    id: Math.random().toString(36).substr(2, 9),
    ...body,
    createdAt: new Date().toISOString()
  };

  // Trigger multiple background processes
  await Promise.all([
    // Send welcome email (TypeScript)
    motia.trigger('send-welcome-email', {
      userId: user.id,
      email: user.email,
      name: user.name
    }),
    
    // Analyze user behavior (Python)
    motia.trigger('analyze-user-behavior', {
      userId: user.id,
      actions: ['registration'],
      metadata: { source: 'api', userAgent: 'tutorial' }
    })
  ]);

  return { success: true, user };
});
```

## Chapter 4: Scheduled Jobs and Cron Steps

Motia makes it easy to create recurring jobs with cron steps.

### 4.1 Creating Daily Report Generation

```typescript
// motia/steps/reports/daily-summary.ts
import { cron } from '@motia/core';

export default cron({
  id: 'daily-summary-report',
  schedule: '0 9 * * *', // Every day at 9 AM
}, async () => {
  console.log('📊 Generating daily summary report...');

  // Simulate report generation
  const report = {
    date: new Date().toISOString().split('T')[0],
    totalUsers: Math.floor(Math.random() * 1000) + 100,
    activeUsers: Math.floor(Math.random() * 500) + 50,
    revenue: Math.floor(Math.random() * 10000) + 1000
  };

  // Send report via email
  await motia.trigger('send-report-email', {
    reportType: 'daily-summary',
    data: report,
    recipients: ['admin@example.com']
  });

  return report;
});
```

### 4.2 Creating Cleanup Jobs

```typescript
// motia/steps/maintenance/cleanup-logs.ts
import { cron } from '@motia/core';

export default cron({
  id: 'cleanup-old-logs',
  schedule: '0 2 * * 0', // Every Sunday at 2 AM
}, async () => {
  console.log('🧹 Starting log cleanup process...');

  // Simulate cleanup process
  const deleted = Math.floor(Math.random() * 100) + 10;
  
  console.log(`✅ Cleanup completed: ${deleted} old log entries removed`);
  
  return {
    deletedEntries: deleted,
    cleanupDate: new Date().toISOString()
  };
});
```

## Chapter 5: Advanced Workflows

### 5.1 Creating Complex Multi-Step Workflows

Motia excels at orchestrating complex workflows. Let's create an e-commerce order processing workflow:

```typescript
// motia/steps/orders/process-order.ts
import { api } from '@motia/core';
import { z } from 'zod';

const ProcessOrderSchema = z.object({
  customerId: z.string(),
  items: z.array(z.object({
    productId: z.string(),
    quantity: z.number().min(1),
    price: z.number().min(0)
  })),
  paymentMethod: z.enum(['credit_card', 'paypal', 'bank_transfer'])
});

export default api({
  id: 'process-order',
  method: 'POST',
  path: '/orders',
  schema: {
    body: ProcessOrderSchema
  }
}, async ({ body }) => {
  const orderId = `order_${Date.now()}`;
  
  console.log(`🛒 Processing order ${orderId} for customer ${body.customerId}`);

  // Step 1: Validate inventory
  await motia.trigger('validate-inventory', {
    orderId,
    items: body.items
  });

  // Step 2: Process payment
  await motia.trigger('process-payment', {
    orderId,
    customerId: body.customerId,
    amount: body.items.reduce((sum, item) => sum + (item.price * item.quantity), 0),
    method: body.paymentMethod
  });

  // Step 3: Create shipping label (runs after payment)
  await motia.trigger('create-shipping-label', {
    orderId,
    customerId: body.customerId,
    items: body.items
  });

  return {
    success: true,
    orderId,
    status: 'processing',
    estimatedDelivery: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString()
  };
});
```

### 5.2 Workflow Step Dependencies

Create the supporting workflow steps:

```typescript
// motia/steps/orders/validate-inventory.ts
import { event } from '@motia/core';

export default event({
  id: 'validate-inventory'
}, async ({ orderId, items }) => {
  console.log(`📦 Validating inventory for order ${orderId}`);
  
  // Simulate inventory check
  await new Promise(resolve => setTimeout(resolve, 1000));
  
  const isValid = Math.random() > 0.1; // 90% success rate
  
  if (!isValid) {
    throw new Error(`Insufficient inventory for order ${orderId}`);
  }
  
  console.log(`✅ Inventory validated for order ${orderId}`);
  return { validated: true, orderId };
});

// motia/steps/orders/process-payment.ts
import { event } from '@motia/core';

export default event({
  id: 'process-payment'
}, async ({ orderId, customerId, amount, method }) => {
  console.log(`💳 Processing ${method} payment of $${amount} for order ${orderId}`);
  
  // Simulate payment processing
  await new Promise(resolve => setTimeout(resolve, 2000));
  
  const success = Math.random() > 0.05; // 95% success rate
  
  if (!success) {
    throw new Error(`Payment failed for order ${orderId}`);
  }
  
  console.log(`✅ Payment processed successfully for order ${orderId}`);
  return { paid: true, orderId, transactionId: `txn_${Date.now()}` };
});
```

## Chapter 6: Real-Time Monitoring and Debugging

### 6.1 Using the Motia Workbench

The Motia Workbench provides powerful debugging capabilities:

1. **🎯 Step Execution Traces**: See every step execution in real-time
2. **📊 Performance Metrics**: Monitor execution times and success rates
3. **🔍 Error Investigation**: Detailed error logs with stack traces
4. **🔄 Workflow Visualization**: See how your steps connect and flow

Access the workbench at: `http://localhost:3000`

### 6.2 Adding Custom Logging

Enhance your steps with structured logging:

```typescript
// motia/steps/users/create-user.ts (with logging)
import { api, logger } from '@motia/core';

export default api({
  id: 'create-user',
  method: 'POST',
  path: '/users'
}, async ({ body }) => {
  const startTime = Date.now();
  
  logger.info('User creation started', {
    email: body.email,
    role: body.role,
    timestamp: new Date().toISOString()
  });

  try {
    const user = {
      id: Math.random().toString(36).substr(2, 9),
      ...body,
      createdAt: new Date().toISOString()
    };

    await motia.trigger('send-welcome-email', {
      userId: user.id,
      email: user.email,
      name: user.name
    });

    logger.info('User created successfully', {
      userId: user.id,
      executionTime: Date.now() - startTime
    });

    return { success: true, user };
  } catch (error) {
    logger.error('User creation failed', {
      error: error.message,
      email: body.email,
      executionTime: Date.now() - startTime
    });
    throw error;
  }
});
```

## Chapter 7: Production Deployment

### 7.1 Environment Configuration

Create environment-specific configurations:

```javascript
// motia.config.js
module.exports = {
  development: {
    port: 3001,
    workbench: {
      enabled: true,
      port: 3000
    },
    database: {
      url: 'sqlite://./motia-dev.db'
    }
  },
  
  production: {
    port: process.env.PORT || 8080,
    workbench: {
      enabled: false // Disable in production
    },
    database: {
      url: process.env.DATABASE_URL
    },
    redis: {
      url: process.env.REDIS_URL
    }
  }
};
```

### 7.2 Docker Deployment

Create a production-ready Dockerfile:

```dockerfile
# Dockerfile
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY requirements.txt ./

# Install Node.js dependencies
RUN npm ci --only=production

# Install Python and dependencies
RUN apk add --no-cache python3 py3-pip
RUN pip3 install -r requirements.txt

# Copy application code
COPY . .

# Build the application
RUN npm run build

EXPOSE 8080

CMD ["npm", "start"]
```

### 7.3 Docker Compose for Development

```yaml
# docker-compose.yml
version: '3.8'

services:
  motia:
    build: .
    ports:
      - "3000:3000"  # Workbench
      - "3001:3001"  # API
    environment:
      - NODE_ENV=development
      - DATABASE_URL=sqlite://./motia.db
    volumes:
      - .:/app
      - /app/node_modules
    depends_on:
      - redis

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
```

## Chapter 8: Best Practices and Performance

### 8.1 Step Organization

Organize your steps by domain:

```
motia/steps/
├── users/
│   ├── create-user.ts
│   ├── update-profile.ts
│   └── delete-account.ts
├── orders/
│   ├── process-order.ts
│   ├── validate-inventory.ts
│   └── create-shipping-label.ts
├── notifications/
│   ├── send-email.ts
│   ├── send-sms.ts
│   └── push-notification.ts
└── analytics/
    ├── track-event.ts
    └── generate-report.ts
```

### 8.2 Error Handling Strategies

Implement robust error handling:

```typescript
// motia/steps/utils/error-handler.ts
import { event } from '@motia/core';

export default event({
  id: 'handle-step-error'
}, async ({ stepId, error, context, retryCount = 0 }) => {
  console.error(`❌ Step ${stepId} failed:`, error);

  // Implement retry logic
  if (retryCount < 3 && isRetryableError(error)) {
    console.log(`🔄 Retrying step ${stepId} (attempt ${retryCount + 1})`);
    
    await new Promise(resolve => setTimeout(resolve, 1000 * Math.pow(2, retryCount)));
    
    return motia.trigger(stepId, {
      ...context,
      __retry: retryCount + 1
    });
  }

  // Send alert for persistent failures
  await motia.trigger('send-alert', {
    level: 'error',
    message: `Step ${stepId} failed after ${retryCount} retries`,
    error: error.message,
    context
  });

  throw error;
});

function isRetryableError(error: Error): boolean {
  const retryablePatterns = [
    'ECONNRESET',
    'TIMEOUT',
    'NETWORK_ERROR',
    'RATE_LIMIT'
  ];
  
  return retryablePatterns.some(pattern => 
    error.message.includes(pattern)
  );
}
```

### 8.3 Performance Optimization

Optimize step performance:

```typescript
// motia/steps/optimized/batch-processor.ts
import { event } from '@motia/core';

export default event({
  id: 'batch-process-users',
  concurrency: 5 // Limit concurrent executions
}, async ({ userIds }) => {
  // Process users in batches
  const BATCH_SIZE = 10;
  const results = [];

  for (let i = 0; i < userIds.length; i += BATCH_SIZE) {
    const batch = userIds.slice(i, i + BATCH_SIZE);
    
    // Process batch in parallel
    const batchResults = await Promise.all(
      batch.map(userId => processUser(userId))
    );
    
    results.push(...batchResults);
  }

  return { processed: results.length, results };
});
```

## Testing Your Motia Application

### 9.1 Running the Complete Example

Let's test our complete application:

```bash
# Start the development server
npx motia dev

# In another terminal, test the user creation flow
curl -X POST http://localhost:3001/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Alice Johnson",
    "email": "alice@example.com",
    "role": "admin"
  }'

# Test the order processing workflow
curl -X POST http://localhost:3001/orders \
  -H "Content-Type: application/json" \
  -d '{
    "customerId": "cust_12345",
    "items": [
      {"productId": "prod_1", "quantity": 2, "price": 29.99},
      {"productId": "prod_2", "quantity": 1, "price": 49.99}
    ],
    "paymentMethod": "credit_card"
  }'
```

### 9.2 Monitoring in the Workbench

1. Open `http://localhost:3000` in your browser
2. Watch real-time step executions
3. Check the **Flow Visualization** to see step dependencies
4. Review **Performance Metrics** for optimization opportunities
5. Investigate any errors in the **Error Logs** section

## Conclusion

Congratulations! You've successfully learned how to:

✅ **Set up Motia** from scratch
✅ **Create API endpoints** with validation
✅ **Build background job processing** with events
✅ **Implement scheduled tasks** with cron steps
✅ **Integrate multiple languages** (TypeScript + Python)
✅ **Design complex workflows** with step dependencies
✅ **Monitor and debug** applications in real-time
✅ **Deploy to production** with Docker

### Key Takeaways

1. **Everything is a Step**: APIs, jobs, cron tasks, and AI agents all use the same pattern
2. **Multi-Language Support**: Seamlessly mix JavaScript/TypeScript with Python
3. **Built-in Observability**: No need for external monitoring tools
4. **Zero Configuration**: Focus on business logic, not infrastructure setup

### Next Steps

- **Explore the [Motia Examples](https://github.com/MotiaDev/motia-examples)** for more complex use cases
- **Join the [Motia Discord Community](https://discord.gg/motia)** for support and discussions
- **Read the [Official Documentation](https://motia.dev/docs)** for advanced features
- **Try building your own workflows** with AI integration

### Resources

- **🐙 GitHub Repository**: [https://github.com/motiadev/motia](https://github.com/motiadev/motia)
- **📚 Documentation**: [https://motia.dev](https://motia.dev)
- **💬 Community Discord**: [Discord Invite](https://discord.gg/motia)
- **🎯 Live Examples**: [ChessArena.ai](https://chessarena.ai) - Full production app built with Motia

Motia is transforming how we build backend systems. **What will you build next?**
