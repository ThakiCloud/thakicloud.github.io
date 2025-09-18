---
title: "Complete Guide to Carbon ERP/MES: Open-Source Manufacturing Management System"
excerpt: "Learn how to set up and use Carbon, the powerful open-source ERP/MES/QMS system perfect for complex assembly, HMLV, and configure-to-order manufacturing."
seo_title: "Carbon ERP/MES Complete Tutorial: Manufacturing Management Setup Guide - Thaki Cloud"
seo_description: "Master Carbon ERP/MES system with our comprehensive tutorial. Perfect for manufacturing, complex assembly, HMLV operations, and configure-to-order processes."
date: 2025-09-09
lang: en
permalink: /en/tutorials/carbon-erp-mes-complete-setup-tutorial/
canonical_url: "https://thakicloud.github.io/en/tutorials/carbon-erp-mes-complete-setup-tutorial/"
categories:
  - tutorials
tags:
  - carbon
  - erp
  - mes
  - manufacturing
  - open-source
  - typescript
  - supabase
author_profile: true
toc: true
toc_label: "Table of Contents"
---

⏱️ **Estimated Reading Time**: 15 minutes

## Introduction

Carbon is a revolutionary open-source ERP (Enterprise Resource Planning), MES (Manufacturing Execution System), and QMS (Quality Management System) designed specifically for modern manufacturing environments. Built with TypeScript and powered by Supabase, Carbon excels in complex assembly operations, High Mix Low Volume (HMLV) manufacturing, and configure-to-order scenarios.

## What is Carbon ERP/MES?

Carbon represents the next generation of manufacturing management systems, offering:

- **Complete Manufacturing Suite**: Combines ERP, MES, and QMS in a single platform
- **Open Source Advantage**: Full transparency and customization capabilities
- **Modern Architecture**: Built with TypeScript, React, and Supabase
- **Scalable Design**: Perfect for growing manufacturing businesses
- **Industry Focus**: Optimized for complex assembly and configure-to-order operations

### Key Features

1. **Enterprise Resource Planning (ERP)**
   - Inventory management
   - Order processing
   - Financial tracking
   - Customer relationship management

2. **Manufacturing Execution System (MES)**
   - Production scheduling
   - Work order management
   - Real-time shop floor monitoring
   - Quality control integration

3. **Quality Management System (QMS)**
   - Quality control workflows
   - Compliance tracking
   - Document management
   - Audit trails

## Prerequisites

Before starting with Carbon, ensure you have the following:

- **Node.js v20** (using nvm)
- **Docker** installed and running
- **Git** for repository management
- Basic knowledge of TypeScript/JavaScript
- Understanding of manufacturing processes

### Required External Services

Carbon integrates with several cloud services for optimal functionality:

| Service | Purpose | Free Tier Available |
|---------|---------|-------------------|
| [Upstash](https://console.upstash.com/login) | Serverless Redis | ✅ Yes |
| [Trigger.dev](https://cloud.trigger.dev/login) | Job Runner | ✅ Yes |
| [PostHog](https://us.posthog.com/signup) | Analytics | ✅ Yes |

## Installation and Setup

### Step 1: Repository Setup

Clone the Carbon repository and navigate to the project directory:

```bash
# Clone the repository
git clone https://github.com/crbnos/carbon.git
cd carbon

# Use Node.js v20
nvm use

# Install dependencies
npm install
```

### Step 2: Database Initialization

Start the Docker containers for the database services:

```bash
# Pull and run database containers
npm run db:start
```

This command will start:
- PostgreSQL database
- Supabase local instance
- Redis cache
- Mailpit for email testing

### Step 3: Environment Configuration

Create your environment configuration file:

```bash
# Copy environment template
cp ./.env.example ./.env
```

Configure the following environment variables in your `.env` file:

#### Database Configuration
```env
# Supabase configuration (from db:start output)
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
SUPABASE_ANON_KEY=your_anon_key
SUPABASE_URL=http://localhost:54321
```

#### Redis Configuration
Create a Redis database in Upstash and add:
```env
UPSTASH_REDIS_REST_URL=your_upstash_url
UPSTASH_REDIS_REST_TOKEN=your_upstash_token
```

#### Job Runner Configuration
Set up Trigger.dev for background jobs:
```env
TRIGGER_PUBLIC_API_KEY=pk_dev_your_public_key
TRIGGER_API_KEY=tr_dev_your_server_key
TRIGGER_PROJECT_ID=proj_your_project_id
```

#### Analytics Configuration
Configure PostHog for product analytics:
```env
POSTHOG_API_HOST=https://[region].posthog.com
POSTHOG_PROJECT_PUBLIC_KEY=phc_your_project_key
```

#### Payment Processing
Add Stripe configuration for payment handling:
```env
STRIPE_SECRET_KEY=sk_test_your_stripe_key
```

Register Stripe webhooks:
```bash
npm run -w @carbon/stripe register:stripe
```

#### Authentication Setup

Choose one of the following authentication methods:

**Option 1: Email Authentication (Resend)**
```env
RESEND_API_KEY=re_your_resend_key
RESEND_DOMAIN=carbon.ms
```

**Option 2: Google OAuth**
```env
SUPABASE_AUTH_EXTERNAL_GOOGLE_CLIENT_ID=your_client_id.apps.googleusercontent.com
SUPABASE_AUTH_EXTERNAL_GOOGLE_CLIENT_SECRET=GOCSPX-your_client_secret
SUPABASE_AUTH_EXTERNAL_GOOGLE_REDIRECT_URI=http://127.0.0.1:54321/auth/v1/callback
```

### Step 4: Database Setup and Build

Initialize the database and build the application:

```bash
# Run database migrations and seed data
npm run db:build

# Build all packages
npm run build
```

### Step 5: Start the Development Environment

Launch all Carbon applications:

```bash
# Start all applications
npm run dev

# Or start specific applications
npm run dev:mes  # Manufacturing Execution System only
```

## Application Overview

After successful installation, you'll have access to multiple applications:

| Application | URL | Purpose |
|-------------|-----|---------|
| **ERP** | http://localhost:3000 | Enterprise Resource Planning |
| **MES** | http://localhost:3001 | Manufacturing Execution System |
| **Academy** | http://localhost:4111 | Training and Documentation |
| **Starter** | http://localhost:4000 | Getting Started Guide |

### Development Tools

| Tool | URL | Purpose |
|------|-----|---------|
| **Postgres** | postgresql://postgres:postgres@localhost:54322/postgres | Database Access |
| **Supabase Studio** | http://localhost:54323/project/default | Database Management |
| **Mailpit** | http://localhost:54324 | Email Testing |
| **Edge Functions** | http://localhost:54321/functions/v1/ | Serverless Functions |

## Using Carbon ERP/MES

### 1. Initial Setup and Configuration

1. **Access the ERP Application**: Navigate to http://localhost:3000
2. **Complete Initial Setup**: Follow the setup wizard to configure your organization
3. **User Management**: Create user accounts and assign roles
4. **Basic Configuration**: Set up locations, departments, and basic settings

### 2. Inventory Management

Configure your inventory system:

- **Item Master**: Define products, raw materials, and components
- **Locations**: Set up warehouses and storage locations
- **Stock Levels**: Configure minimum and maximum stock levels
- **Suppliers**: Manage vendor information and pricing

### 3. Manufacturing Setup

Configure manufacturing operations:

- **Bill of Materials (BOM)**: Define product structures
- **Routing**: Set up manufacturing processes
- **Work Centers**: Configure production resources
- **Quality Standards**: Define quality control parameters

### 4. Production Planning

Implement production workflows:

- **Production Orders**: Create and manage work orders
- **Scheduling**: Plan production activities
- **Resource Allocation**: Assign workers and equipment
- **Progress Tracking**: Monitor production status

## API Integration

Carbon provides comprehensive API access for integration with external systems.

### API Authentication

Generate an API key from the ERP settings and configure:

```javascript
import { Database } from "@carbon/database";
import { createClient } from "@supabase/supabase-js";

const apiKey = process.env.CARBON_API_KEY;
const apiUrl = process.env.CARBON_API_URL;
const publicKey = process.env.CARBON_PUBLIC_KEY;

const carbon = createClient<Database>(apiUrl, publicKey, {
  global: {
    headers: {
      "carbon-key": apiKey,
    },
  },
});

// Fetch inventory items
const { data, error } = await carbon.from("item").select("*");
```

### Internal API Usage

For monorepo development:

```javascript
import { getCarbonServiceRole } from "@carbon/auth";

const carbon = getCarbonServiceRole();

// Company-specific data access
const companyId = "your-company-id";
const { data, error } = await carbon
  .from("item")
  .select("*")
  .eq("companyId", companyId);
```

## Architecture Deep Dive

Carbon's architecture consists of several key packages:

### Core Packages

- **@carbon/database**: Schema, migrations, and type definitions
- **@carbon/documents**: PDF generation and email templates
- **@carbon/jobs**: Background job processing
- **@carbon/react**: Shared UI components
- **@carbon/utils**: Common utility functions

### Integration Packages

- **@carbon/ee**: Enterprise integrations
- **@carbon/stripe**: Payment processing
- **@carbon/lib**: Third-party service clients
- **@carbon/kv**: Redis caching layer

## Troubleshooting

### Common Issues and Solutions

**Database Connection Issues**
```bash
# Reset database containers
npm run db:kill
npm run db:build
```

**Port Conflicts**
- Check if ports 3000, 3001, 54321-54324 are available
- Stop conflicting services or modify port configurations

**Authentication Problems**
- Verify all authentication environment variables
- Check Supabase configuration
- Ensure redirect URLs match your setup

**Build Failures**
```bash
# Clean and rebuild
npm run clean
npm install
npm run build
```

## Best Practices

### Development Workflow

1. **Environment Management**: Use separate configurations for development, staging, and production
2. **Data Backup**: Regularly backup your database during development
3. **Version Control**: Use proper Git workflows for collaboration
4. **Testing**: Implement comprehensive testing for custom modifications

### Production Deployment

1. **Security Configuration**: Update default passwords and API keys
2. **SSL/TLS**: Implement HTTPS for production environments
3. **Database Optimization**: Configure appropriate database settings
4. **Monitoring**: Set up monitoring and alerting systems

### Performance Optimization

1. **Database Indexing**: Optimize database queries with proper indexing
2. **Caching Strategy**: Implement effective caching with Redis
3. **Asset Optimization**: Minimize and compress frontend assets
4. **Background Jobs**: Use background processing for heavy operations

## Advanced Configuration

### Custom Integrations

Carbon's modular architecture allows for easy integration with external systems:

- **ERP Systems**: Connect with existing ERP platforms
- **IoT Devices**: Integrate shop floor sensors and equipment
- **Quality Systems**: Connect inspection and testing equipment
- **Reporting Tools**: Integrate with business intelligence platforms

### Scaling Considerations

For large-scale deployments:

- **Database Clustering**: Implement PostgreSQL clustering
- **Load Balancing**: Use reverse proxies for traffic distribution
- **Microservices**: Consider breaking down into smaller services
- **Cloud Deployment**: Utilize cloud-native scaling features

## Conclusion

Carbon ERP/MES represents a powerful solution for modern manufacturing environments. Its open-source nature, combined with modern technology stack and comprehensive feature set, makes it an excellent choice for organizations looking to implement or upgrade their manufacturing management systems.

The system's flexibility allows for customization to meet specific industry requirements, while its API-first approach ensures seamless integration with existing business systems. Whether you're managing complex assembly operations, implementing HMLV manufacturing processes, or handling configure-to-order scenarios, Carbon provides the tools and capabilities needed for success.

## Next Steps

1. **Explore the Applications**: Familiarize yourself with each Carbon application
2. **Configure Your Environment**: Customize settings for your specific use case
3. **Import Your Data**: Migrate existing data to Carbon
4. **Train Your Team**: Utilize the Academy application for user training
5. **Customize and Extend**: Modify Carbon to meet your unique requirements

For additional resources and community support, visit the [Carbon GitHub repository](https://github.com/crbnos/carbon) and explore the comprehensive documentation available in the Academy application.

---

*Ready to revolutionize your manufacturing operations with Carbon? Start your journey today and experience the power of open-source manufacturing management.*
