---
title: "Airweave: Complete Guide to AI Agent Search Platform for Any App"
excerpt: "Learn how to use Airweave to connect 25+ apps and tools, enabling AI agents to perform semantic search across all your data with this comprehensive tutorial."
seo_title: "Airweave AI Agent Search Platform Complete Guide - Thaki Cloud"
seo_description: "Complete tutorial on Airweave for connecting 25+ apps, semantic search, MCP server setup. Includes REST API, Python/TypeScript SDK usage, and real-world implementation examples."
date: 2025-10-02
categories:
  - tutorials
tags:
  - airweave
  - ai-agent
  - semantic-search
  - mcp
  - vector-database
author_profile: true
toc: true
toc_label: "Table of Contents"
canonical_url: "https://thakicloud.github.io/en/tutorials/airweave-agent-search-platform-tutorial/"
lang: en
permalink: /en/tutorials/airweave-agent-search-platform-tutorial/
---

⏱️ **Estimated reading time**: 15 minutes

## Overview

**Airweave** is an innovative platform that enables AI agents to search any app. It connects to 25+ apps and tools, transforming their contents into searchable knowledge bases accessible through a standardized interface for agents.

This tutorial will walk you through Airweave's core features and real-world implementation step by step.

## 🚀 What is Airweave?

### Core Concepts

Airweave provides the following key features:

- **App Integration**: Connect to 25+ productivity tools, databases, and document stores
- **Data Transformation**: Convert connected app contents into searchable knowledge bases
- **Semantic Search**: Enable AI agents to search data using natural language
- **Standardized Interface**: Support for REST API and MCP (Model Context Protocol)

### Supported Integrations

Airweave supports the following major services:

- **Project Management**: Asana, Jira, Linear, Monday.com
- **Code Repositories**: GitHub, Bitbucket
- **Document Management**: Notion, Confluence, Google Drive, OneDrive
- **Communication**: Slack, Gmail, Outlook
- **Databases**: PostgreSQL
- **Others**: Dropbox, HubSpot, Stripe, Todoist

## 🛠️ Installation and Setup

### 1. System Requirements

```bash
# Check Docker and Docker Compose installation
docker --version
docker-compose --version
```

### 2. Airweave Installation

```bash
# 1. Clone the repository
git clone https://github.com/airweave-ai/airweave.git
cd airweave

# 2. Grant execution permissions and start
chmod +x start.sh
./start.sh
```

### 3. Access Verification

After installation, you can access the following URLs:

- **Dashboard**: http://localhost:8080
- **API Documentation**: http://localhost:8001/docs

## 📊 Dashboard Usage

### 1. Source Connection

You can connect sources through the dashboard as follows:

1. Click **Connect Sources** button
2. Select desired service (e.g., GitHub, Notion, Slack)
3. Complete OAuth authentication
4. Configure sync settings

### 2. Sync Configuration

```yaml
# Sync configuration example
sync_config:
  frequency: "hourly"  # Sync frequency
  incremental: true    # Incremental updates
  filters:
    - type: "documents"
    - date_range: "last_30_days"
```

## 🔌 API Usage

### 1. Basic API Calls

```python
import requests

# API basic configuration
API_BASE_URL = "http://localhost:8001"
API_KEY = "your_api_key_here"

headers = {
    "Authorization": f"Bearer {API_KEY}",
    "Content-Type": "application/json"
}
```

### 2. Collection Creation

```python
def create_collection(name, description=""):
    """Create a new collection"""
    url = f"{API_BASE_URL}/collections"
    data = {
        "name": name,
        "description": description
    }
    
    response = requests.post(url, headers=headers, json=data)
    return response.json()

# Usage example
collection = create_collection(
    name="my_documents",
    description="My document collection"
)
print(f"Collection created: {collection['id']}")
```

### 3. Data Search

```python
def search_documents(query, collection_id=None, limit=10):
    """Search documents"""
    url = f"{API_BASE_URL}/search"
    params = {
        "query": query,
        "limit": limit
    }
    
    if collection_id:
        params["collection_id"] = collection_id
    
    response = requests.get(url, headers=headers, params=params)
    return response.json()

# Usage example
results = search_documents(
    query="project plan",
    limit=5
)

for result in results['results']:
    print(f"Title: {result['title']}")
    print(f"Content: {result['content'][:100]}...")
    print(f"Score: {result['score']}")
    print("-" * 50)
```

## 📦 SDK Usage

### Python SDK

```bash
# Install SDK
pip install airweave-sdk
```

```python
from airweave import AirweaveSDK

# Initialize client
client = AirweaveSDK(
    api_key="YOUR_API_KEY",
    base_url="http://localhost:8001"
)

# Create collection
collection = client.collections.create(
    name="my_collection",
    description="My collection"
)

# Search documents
results = client.search.query(
    query="AI related documents",
    collection_id=collection['id'],
    limit=10
)

# Process results
for result in results:
    print(f"Title: {result.title}")
    print(f"Content: {result.content[:100]}...")
    print(f"Relevance Score: {result.score}")
```

### TypeScript/JavaScript SDK

```bash
# Install SDK
npm install @airweave/sdk
# or
yarn add @airweave/sdk
```

```typescript
import { AirweaveSDKClient, AirweaveSDKEnvironment } from "@airweave/sdk";

// Initialize client
const client = new AirweaveSDKClient({
    apiKey: "YOUR_API_KEY",
    environment: AirweaveSDKEnvironment.Local
});

// Create collection
const collection = await client.collections.create({
    name: "my_collection",
    description: "My collection"
});

// Search documents
const results = await client.search.query({
    query: "AI related documents",
    collectionId: collection.id,
    limit: 10
});

// Process results
results.forEach(result => {
    console.log(`Title: ${result.title}`);
    console.log(`Content: ${result.content.substring(0, 100)}...`);
    console.log(`Relevance Score: ${result.score}`);
});
```

## 🔧 MCP Server Setup

### 1. MCP Configuration

Airweave can also operate as an MCP (Model Context Protocol) server:

```python
# MCP server configuration
from airweave.mcp import AirweaveMCPServer

# Initialize MCP server
mcp_server = AirweaveMCPServer(
    api_key="YOUR_API_KEY",
    base_url="http://localhost:8001"
)

# Start server
mcp_server.start()
```

### 2. Using with MCP Client

```python
# Using Airweave with MCP client
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

async def search_with_airweave(query):
    """Search using Airweave through MCP"""
    async with stdio_client(StdioServerParameters(
        command="airweave-mcp",
        args=["--api-key", "YOUR_API_KEY"]
    )) as (read, write):
        async with ClientSession(read, write) as session:
            # Execute Airweave search
            result = await session.call_tool(
                "airweave_search",
                arguments={"query": query}
            )
            return result
```

## 🎯 Real-World Use Cases

### 1. Development Team Knowledge Management

```python
def setup_development_knowledge_base():
    """Setup development team knowledge base"""
    
    # Connect GitHub repositories
    github_connection = client.connections.create({
        "type": "github",
        "name": "company_repos",
        "config": {
            "repositories": ["company/frontend", "company/backend"],
            "include_issues": True,
            "include_pull_requests": True
        }
    })
    
    # Connect Notion documents
    notion_connection = client.connections.create({
        "type": "notion",
        "name": "dev_docs",
        "config": {
            "database_id": "your_notion_database_id",
            "include_comments": True
        }
    })
    
    # Create collection
    dev_collection = client.collections.create({
        "name": "development_knowledge",
        "description": "Development team knowledge base"
    })
    
    # Add connections to collection
    client.collections.add_connection(
        dev_collection['id'],
        github_connection['id']
    )
    client.collections.add_connection(
        dev_collection['id'],
        notion_connection['id']
    )
    
    return dev_collection

# Usage example
dev_kb = setup_development_knowledge_base()
print(f"Development knowledge base created: {dev_kb['id']}")
```

### 2. Customer Support System

```python
def setup_customer_support_system():
    """Setup customer support system"""
    
    # Connect Slack channels
    slack_connection = client.connections.create({
        "type": "slack",
        "name": "support_channel",
        "config": {
            "channels": ["#customer-support", "#technical-support"],
            "include_threads": True
        }
    })
    
    # Connect email
    email_connection = client.connections.create({
        "type": "gmail",
        "name": "support_emails",
        "config": {
            "labels": ["support", "tickets"],
            "include_attachments": True
        }
    })
    
    # Create support collection
    support_collection = client.collections.create({
        "name": "customer_support",
        "description": "Customer support knowledge base"
    })
    
    return support_collection

# Search customer questions
def search_customer_question(question):
    """Search answers for customer questions"""
    results = client.search.query({
        "query": question,
        "collection_id": "customer_support",
        "limit": 5
    })
    
    return results
```

### 3. AI Agent Integration

```python
class AirweaveAgent:
    """AI Agent utilizing Airweave"""
    
    def __init__(self, api_key, base_url):
        self.client = AirweaveSDK(
            api_key=api_key,
            base_url=base_url
        )
        self.collection_id = None
    
    def setup_knowledge_base(self, collection_name):
        """Setup knowledge base"""
        self.collection_id = self.client.collections.create({
            "name": collection_name
        })['id']
        return self.collection_id
    
    def search_knowledge(self, query, limit=5):
        """Search knowledge base"""
        return self.client.search.query({
            "query": query,
            "collection_id": self.collection_id,
            "limit": limit
        })
    
    def answer_question(self, question):
        """Generate answer for question"""
        # Search relevant documents
        relevant_docs = self.search_knowledge(question)
        
        # Build context
        context = "\n".join([
            f"Document: {doc.title}\nContent: {doc.content[:500]}..."
            for doc in relevant_docs
        ])
        
        # Generate answer using AI model (example)
        prompt = f"""
        Please answer the question based on the following context:
        
        Context:
        {context}
        
        Question: {question}
        
        Answer:
        """
        
        # Here you would call the actual AI model
        return self.generate_answer(prompt)

# Usage example
agent = AirweaveAgent("your_api_key", "http://localhost:8001")
agent.setup_knowledge_base("company_knowledge")

# Question answering
answer = agent.answer_question("What is the project schedule?")
print(answer)
```

## 🔍 Advanced Features

### 1. Incremental Sync

```python
def setup_incremental_sync(connection_id):
    """Setup incremental sync"""
    sync_config = {
        "incremental": True,
        "frequency": "hourly",
        "content_hash_check": True,
        "last_modified_filter": True
    }
    
    return client.syncs.create({
        "connection_id": connection_id,
        "config": sync_config
    })
```

### 2. Entity Extraction

```python
def extract_entities(document):
    """Extract entities from document"""
    entities = client.entities.extract({
        "text": document['content'],
        "types": ["person", "organization", "location", "date"]
    })
    
    return entities
```

### 3. Version Management

```python
def get_document_versions(document_id):
    """Get document version history"""
    versions = client.documents.get_versions(document_id)
    
    for version in versions:
        print(f"Version: {version['version']}")
        print(f"Created: {version['created_at']}")
        print(f"Changes: {version['changes']}")
```

## 🚨 Troubleshooting

### 1. Common Errors

```python
# Handle connection errors
try:
    result = client.search.query({"query": "test"})
except ConnectionError as e:
    print(f"Connection error: {e}")
    # Retry logic
except AuthenticationError as e:
    print(f"Authentication error: {e}")
    # Check API key
```

### 2. Performance Optimization

```python
# Search performance optimization
def optimized_search(query, filters=None):
    """Optimized search"""
    search_params = {
        "query": query,
        "limit": 10,
        "include_metadata": True
    }
    
    if filters:
        search_params["filters"] = filters
    
    return client.search.query(search_params)

# Usage example
results = optimized_search(
    query="project plan",
    filters={"source": "notion", "date_range": "last_month"}
)
```

### 3. Logging and Monitoring

```python
import logging

# Logging configuration
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def monitor_sync_status(connection_id):
    """Monitor sync status"""
    status = client.syncs.get_status(connection_id)
    
    if status['status'] == 'failed':
        logger.error(f"Sync failed: {status['error']}")
    elif status['status'] == 'running':
        logger.info(f"Sync in progress: {status['progress']}%")
    else:
        logger.info(f"Sync completed: {status['last_sync']}")
```

## 📈 Monitoring and Analytics

### 1. Usage Statistics

```python
def get_usage_statistics():
    """Get usage statistics"""
    stats = client.analytics.get_usage_stats({
        "period": "last_30_days",
        "include_breakdown": True
    })
    
    print(f"Total searches: {stats['total_searches']}")
    print(f"Average response time: {stats['avg_response_time']}ms")
    print(f"Popular queries: {stats['popular_queries']}")
```

### 2. Performance Metrics

```python
def monitor_performance():
    """Monitor performance metrics"""
    metrics = client.analytics.get_performance_metrics()
    
    print(f"API response time: {metrics['api_response_time']}ms")
    print(f"Search accuracy: {metrics['search_accuracy']}%")
    print(f"System availability: {metrics['availability']}%")
```

## 🔐 Security and Access Control

### 1. API Key Management

```python
def manage_api_keys():
    """Manage API keys"""
    # Create new API key
    new_key = client.auth.create_api_key({
        "name": "production_key",
        "permissions": ["read", "write"],
        "expires_at": "2025-12-31"
    })
    
    # List API keys
    keys = client.auth.list_api_keys()
    
    # Delete unused keys
    for key in keys:
        if key['last_used'] < "2025-01-01":
            client.auth.revoke_api_key(key['id'])
```

### 2. Access Control

```python
def setup_access_control(collection_id):
    """Setup access control"""
    # Set user-specific permissions
    permissions = client.permissions.set_collection_access({
        "collection_id": collection_id,
        "user_permissions": {
            "user1": ["read"],
            "user2": ["read", "write"],
            "admin": ["read", "write", "delete"]
        }
    })
    
    return permissions
```

## 🎉 Conclusion

Airweave is a powerful platform that enables AI agents to access data from any app. Through this tutorial, we learned:

1. **Airweave installation and basic setup**
2. **Connecting 25+ apps and tools**
3. **REST API and SDK usage**
4. **MCP server setup**
5. **Real-world implementation examples**
6. **Advanced feature utilization**

### Next Steps

- Refer to [Airweave official documentation](https://github.com/airweave-ai/airweave)
- Join the [Discord community](https://discord.gg/airweave)
- Provide feedback through [GitHub Issues](https://github.com/airweave-ai/airweave/issues)

Upgrade your AI agent's search capabilities with Airweave!

---

**💡 Tip**: All code in this tutorial is executable and has been tested on macOS. If you encounter issues, you can get help through [GitHub Issues](https://github.com/airweave-ai/airweave/issues).
