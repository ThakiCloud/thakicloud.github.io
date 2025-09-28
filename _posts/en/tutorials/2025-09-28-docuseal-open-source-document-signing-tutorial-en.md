---
title: "DocuSeal: Complete Tutorial for Open Source Document Signing Platform"
excerpt: "Learn how to set up and use DocuSeal, the open-source alternative to DocuSign. This comprehensive tutorial covers Docker installation, PDF form creation, and digital signature workflows."
seo_title: "DocuSeal Tutorial: Open Source Document Signing Platform Guide - Thaki Cloud"
seo_description: "Complete DocuSeal tutorial covering installation, setup, and usage. Learn to create PDF forms, manage digital signatures, and integrate this open-source DocuSign alternative."
date: 2025-09-28
categories:
  - tutorials
tags:
  - docuseal
  - open-source
  - document-signing
  - pdf
  - docker
  - digital-signature
  - e-signature
author_profile: true
toc: true
toc_label: "Table of Contents"
lang: en
permalink: /en/tutorials/docuseal-open-source-document-signing-tutorial/
canonical_url: "https://thakicloud.github.io/en/tutorials/docuseal-open-source-document-signing-tutorial/"
---

⏱️ **Estimated Reading Time**: 8 minutes

## Introduction

In today's digital world, document signing and processing have become essential for businesses and individuals alike. While commercial solutions like DocuSign are popular, they can be expensive and may not offer the flexibility that organizations need. Enter [DocuSeal](https://github.com/docusealco/docuseal), an open-source alternative that provides secure and efficient digital document signing capabilities.

DocuSeal is a comprehensive platform that allows you to create PDF forms, collect signatures, and manage document workflows—all while maintaining full control over your data and infrastructure. With over 10,000 stars on GitHub, it has proven to be a reliable solution for organizations seeking cost-effective document management.

## What is DocuSeal?

DocuSeal is an open-source document signing platform that offers:

- **PDF Form Builder**: WYSIWYG editor for creating interactive PDF forms
- **Multiple Field Types**: Support for 12 different field types including signatures, dates, files, and checkboxes
- **Multi-Submitter Support**: Handle documents requiring multiple signatures
- **Automated Email Notifications**: Built-in SMTP integration for workflow automation
- **Flexible Storage**: Support for local disk, AWS S3, Google Storage, and Azure Cloud
- **Mobile Optimization**: Responsive design that works seamlessly on all devices
- **Multi-Language Support**: Available in 6 UI languages with signing support in 14 languages
- **API Integration**: RESTful API and webhooks for system integration

## Prerequisites

Before we begin, ensure you have the following installed on your system:

- **Docker**: Version 20.10 or later
- **Docker Compose**: Version 2.0 or later (optional but recommended)
- **Web Browser**: Modern browser with JavaScript enabled
- **Email Server**: SMTP server for email notifications (optional)

## Installation Methods

DocuSeal offers multiple deployment options. We'll focus on Docker-based installations, which are the most straightforward and portable.

### Method 1: Quick Docker Setup

The fastest way to get DocuSeal running is with a single Docker command:

```bash
docker run --name docuseal -p 3000:3000 -v $(pwd)/docuseal-data:/data docuseal/docuseal
```

This command:
- Creates a container named `docuseal`
- Maps port 3000 from the container to your local machine
- Creates a volume to persist data in the `docuseal-data` directory
- Uses SQLite as the default database

### Method 2: Docker Compose (Recommended)

For production environments or when you need more control, use Docker Compose:

```bash
# Download the docker-compose.yml file
curl https://raw.githubusercontent.com/docusealco/docuseal/master/docker-compose.yml > docker-compose.yml

# Start the application
docker compose up -d
```

For custom domain deployment with automatic SSL:

```bash
sudo HOST=your-domain-name.com docker compose up
```

### Method 3: Database Configuration

For production use, you might want to use PostgreSQL or MySQL instead of SQLite:

```bash
# PostgreSQL example
docker run --name docuseal \
  -p 3000:3000 \
  -v $(pwd)/docuseal-data:/data \
  -e DATABASE_URL="postgresql://username:password@host:5432/docuseal" \
  docuseal/docuseal

# MySQL example
docker run --name docuseal \
  -p 3000:3000 \
  -v $(pwd)/docuseal-data:/data \
  -e DATABASE_URL="mysql2://username:password@host:3306/docuseal" \
  docuseal/docuseal
```

## Initial Setup and Configuration

### 1. First Access

Once DocuSeal is running, open your web browser and navigate to:

```
http://localhost:3000
```

You'll be greeted with the DocuSeal setup wizard.

### 2. Admin Account Creation

Create your administrator account by providing:
- **Full Name**: Your display name
- **Email Address**: Will be used for login and notifications
- **Password**: Choose a strong password
- **Organization Name**: Your company or organization name

### 3. SMTP Configuration (Optional)

To enable email notifications, configure your SMTP settings:

```yaml
# Environment variables for SMTP
SMTP_ADDRESS: smtp.gmail.com
SMTP_PORT: 587
SMTP_USERNAME: your-email@gmail.com
SMTP_PASSWORD: your-app-password
SMTP_DOMAIN: gmail.com
SMTP_AUTHENTICATION: plain
SMTP_ENABLE_STARTTLS_AUTO: true
```

## Creating Your First Document Template

### Step 1: Upload a PDF Document

1. Click on **"New Template"** from the dashboard
2. Upload your PDF document or create a new one
3. Give your template a descriptive name
4. Add any necessary description or instructions

### Step 2: Add Form Fields

DocuSeal provides a drag-and-drop interface for adding fields:

#### Available Field Types:

- **Signature**: For collecting digital signatures
- **Initials**: For collecting initials
- **Text**: Single-line text input
- **Date**: Date picker field
- **Number**: Numeric input with validation
- **Select**: Dropdown selection
- **Checkbox**: Boolean checkbox
- **Radio**: Multiple choice selection
- **File**: File upload capability
- **Image**: Image insertion
- **Phone**: Phone number with formatting
- **Email**: Email address with validation

#### Adding Fields:

1. Select the field type from the toolbar
2. Click and drag to position the field on the document
3. Resize the field as needed
4. Configure field properties:
   - **Required**: Make the field mandatory
   - **Default Value**: Pre-populate with default text
   - **Validation**: Add custom validation rules
   - **Conditional Logic**: Show/hide based on other fields

### Step 3: Configure Submitters

Define who needs to sign or fill out the document:

1. Click **"Add Submitter"**
2. Specify submitter details:
   - **Name**: Display name for the submitter
   - **Email**: Email address for notifications
   - **Role**: Define their role (Signer, Reviewer, etc.)
3. Assign fields to specific submitters by color-coding

## Document Workflow Management

### Sending Documents for Signature

1. **Select Template**: Choose your prepared template
2. **Add Recipients**: Enter recipient information
3. **Customize Message**: Add a personal message
4. **Set Signing Order**: Define the sequence if multiple signers
5. **Send**: DocuSeal automatically sends email invitations

### Tracking Progress

The dashboard provides real-time tracking:

- **Pending**: Documents waiting for action
- **In Progress**: Currently being signed
- **Completed**: Fully executed documents
- **Declined**: Rejected documents

### Automated Reminders

Configure automatic reminders for pending signatures:

```yaml
# Reminder settings
REMINDER_INTERVAL: 3 # days
MAX_REMINDERS: 3
REMINDER_MESSAGE: "Please complete your document signing"
```

## Advanced Features

### API Integration

DocuSeal provides a comprehensive REST API for integration:

```bash
# Create a new submission
curl -X POST https://your-docuseal-instance.com/api/submissions \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "template_id": 123,
    "submitters": [
      {
        "name": "John Doe",
        "email": "john@example.com"
      }
    ]
  }'
```

### Webhook Configuration

Set up webhooks to receive real-time notifications:

```json
{
  "webhook_url": "https://your-app.com/webhooks/docuseal",
  "events": [
    "submission.created",
    "submission.completed",
    "submission.declined"
  ]
}
```

### Template Creation via API

Create templates programmatically:

```bash
# Upload and create template
curl -X POST https://your-docuseal-instance.com/api/templates \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -F "file=@document.pdf" \
  -F "name=Contract Template"
```

## Security and Compliance

### PDF Signature Verification

DocuSeal automatically adds cryptographic signatures to PDFs:

- **Digital Certificates**: Uses X.509 certificates
- **Timestamp Authority**: Adds trusted timestamps
- **Signature Validation**: Built-in verification tools
- **Audit Trail**: Complete signing history

### Data Protection

- **Encryption**: All data encrypted at rest and in transit
- **Access Control**: Role-based permissions
- **Audit Logging**: Comprehensive activity logs
- **GDPR Compliance**: Data protection features

## Troubleshooting Common Issues

### Docker Container Won't Start

```bash
# Check container logs
docker logs docuseal

# Common solutions
docker system prune  # Clean up Docker resources
docker pull docuseal/docuseal:latest  # Update to latest version
```

### Database Connection Issues

```bash
# Test database connectivity
docker exec -it docuseal rails db:migrate:status

# Reset database if needed
docker exec -it docuseal rails db:reset
```

### Email Delivery Problems

1. Verify SMTP credentials
2. Check firewall settings
3. Test with a different SMTP provider
4. Review email logs in the application

### Performance Optimization

For high-volume usage:

```yaml
# Docker Compose optimization
services:
  docuseal:
    environment:
      - RAILS_MAX_THREADS=10
      - WEB_CONCURRENCY=3
      - RAILS_ENV=production
    deploy:
      resources:
        limits:
          memory: 2G
        reservations:
          memory: 1G
```

## Production Deployment Considerations

### SSL/TLS Configuration

Always use HTTPS in production:

```nginx
# Nginx configuration example
server {
    listen 443 ssl;
    server_name your-domain.com;
    
    ssl_certificate /path/to/certificate.crt;
    ssl_certificate_key /path/to/private.key;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### Backup Strategy

Regular backups are essential:

```bash
# Database backup
docker exec docuseal pg_dump -U postgres docuseal > backup.sql

# File storage backup
rsync -av ./docuseal-data/ ./backups/$(date +%Y%m%d)/
```

### Monitoring and Logging

Set up monitoring for production:

```yaml
# Docker Compose with logging
services:
  docuseal:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

## Integration Examples

### React Integration

```jsx
import React, { useEffect } from 'react';

const DocuSealEmbed = ({ submissionId }) => {
  useEffect(() => {
    const script = document.createElement('script');
    script.src = 'https://your-docuseal-instance.com/embed.js';
    script.onload = () => {
      window.DocuSeal.embed({
        src: `https://your-docuseal-instance.com/s/${submissionId}`,
        email: 'user@example.com'
      });
    };
    document.body.appendChild(script);
  }, [submissionId]);

  return <div id="docuseal-form"></div>;
};
```

### Node.js API Integration

```javascript
const axios = require('axios');

class DocuSealClient {
  constructor(apiToken, baseUrl) {
    this.client = axios.create({
      baseURL: baseUrl,
      headers: {
        'Authorization': `Bearer ${apiToken}`,
        'Content-Type': 'application/json'
      }
    });
  }

  async createSubmission(templateId, submitters) {
    try {
      const response = await this.client.post('/api/submissions', {
        template_id: templateId,
        submitters: submitters
      });
      return response.data;
    } catch (error) {
      console.error('Error creating submission:', error);
      throw error;
    }
  }
}
```

## Conclusion

DocuSeal provides a powerful, open-source alternative to commercial document signing platforms. Its flexibility, comprehensive feature set, and active development community make it an excellent choice for organizations of all sizes.

Key benefits of using DocuSeal:

- **Cost-Effective**: No per-signature fees or user limits
- **Data Ownership**: Complete control over your documents and data
- **Customization**: Open source allows for custom modifications
- **Integration**: Comprehensive API for seamless integration
- **Security**: Enterprise-grade security features
- **Scalability**: Handles everything from small teams to large enterprises

Whether you're a small business looking to digitize your document workflows or a large enterprise needing a customizable signing solution, DocuSeal provides the tools and flexibility to meet your needs.

For more advanced configurations and enterprise features, consider exploring DocuSeal's Pro features or contributing to the open-source project on [GitHub](https://github.com/docusealco/docuseal).

## Additional Resources

- **Official Documentation**: [DocuSeal Docs](https://www.docuseal.com/docs)
- **GitHub Repository**: [https://github.com/docusealco/docuseal](https://github.com/docusealco/docuseal)
- **Community Support**: [GitHub Discussions](https://github.com/docusealco/docuseal/discussions)
- **API Reference**: [API Documentation](https://www.docuseal.com/api)
- **Live Demo**: [Try DocuSeal](https://demo.docuseal.com)

---

*Have questions about DocuSeal or need help with implementation? Feel free to reach out through the comments below or join the community discussions on GitHub.*
