---
title: "MCP-UI: Building Next-Generation AI Interfaces with Model Context Protocol"
excerpt: "Learn how to create interactive UI experiences over MCP protocol. Build dynamic interfaces that enhance AI agent interactions with real-time components and seamless integration."
seo_title: "MCP-UI Tutorial: Next-Gen AI Interface Development Guide - Thaki Cloud"
seo_description: "Complete guide to MCP-UI development. Learn to build interactive AI interfaces with TypeScript, Python, and Ruby. Includes practical examples and deployment strategies."
date: 2025-10-03
categories:
  - tutorials
tags:
  - mcp-ui
  - ai-interface
  - typescript
  - python
  - ruby
  - model-context-protocol
  - ui-development
author_profile: true
toc: true
toc_label: "Table of Contents"
canonical_url: "https://thakicloud.github.io/en/tutorials/mcp-ui-next-generation-ai-interface-tutorial/"
---

⏱️ **Estimated Reading Time**: 15 minutes

## Introduction

The Model Context Protocol (MCP) has revolutionized how AI agents interact with external systems. Now, with **MCP-UI**, we can create rich, interactive user interfaces that seamlessly integrate with AI workflows. This tutorial will guide you through building next-generation AI interfaces using the MCP-UI framework.

## What is MCP-UI?

MCP-UI is an innovative framework that enables developers to create interactive user interfaces over the Model Context Protocol. It bridges the gap between AI agents and user experience by providing:

- **Dynamic UI Components**: Create interactive elements that respond to AI agent actions
- **Multi-Language Support**: SDKs available for TypeScript, Python, and Ruby
- **Secure Execution**: Sandboxed iframe execution for enhanced security
- **Flexible Content Types**: Support for HTML, external URLs, and remote DOM manipulation

## Prerequisites

Before we begin, ensure you have:

- Node.js 18+ installed
- Basic knowledge of TypeScript/JavaScript
- Understanding of MCP fundamentals
- Git for version control

## Setting Up Your Development Environment

### 1. Initialize Your Project

```bash
# Create a new project directory
mkdir mcp-ui-tutorial
cd mcp-ui-tutorial

# Initialize npm project
npm init -y

# Install MCP-UI dependencies
npm install @mcp-ui/server @mcp-ui/client
npm install -D typescript @types/node ts-node
```

### 2. Configure TypeScript

Create a `tsconfig.json` file:

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

## Building Your First MCP-UI Server

### 1. Create the Server Structure

```bash
mkdir src
touch src/server.ts src/ui-resources.ts
```

### 2. Implement UI Resources

Create `src/ui-resources.ts`:

```typescript
import { createUIResource } from '@mcp-ui/server';

// Simple HTML greeting component
export const greetingResource = createUIResource({
  uri: 'ui://greeting/welcome',
  content: {
    type: 'rawHtml',
    htmlString: `
      <div style="padding: 20px; border-radius: 8px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; font-family: Arial, sans-serif;">
        <h2>🚀 Welcome to MCP-UI!</h2>
        <p>This is your first interactive AI interface component.</p>
        <button onclick="alert('Hello from MCP-UI!')" style="padding: 10px 20px; background: white; color: #667eea; border: none; border-radius: 4px; cursor: pointer;">
          Click Me!
        </button>
      </div>
    `
  },
  encoding: 'text'
});

// Interactive dashboard component
export const dashboardResource = createUIResource({
  uri: 'ui://dashboard/analytics',
  content: {
    type: 'rawHtml',
    htmlString: `
      <div style="padding: 20px; font-family: Arial, sans-serif;">
        <h3>📊 AI Agent Analytics Dashboard</h3>
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; margin-top: 20px;">
          <div style="padding: 15px; background: #f8f9fa; border-radius: 8px; border-left: 4px solid #28a745;">
            <h4 style="margin: 0; color: #28a745;">Active Sessions</h4>
            <p style="font-size: 24px; margin: 10px 0; font-weight: bold;">42</p>
          </div>
          <div style="padding: 15px; background: #f8f9fa; border-radius: 8px; border-left: 4px solid #007bff;">
            <h4 style="margin: 0; color: #007bff;">Total Requests</h4>
            <p style="font-size: 24px; margin: 10px 0; font-weight: bold;">1,337</p>
          </div>
          <div style="padding: 15px; background: #f8f9fa; border-radius: 8px; border-left: 4px solid #ffc107;">
            <h4 style="margin: 0; color: #ffc107;">Response Time</h4>
            <p style="font-size: 24px; margin: 10px 0; font-weight: bold;">125ms</p>
          </div>
        </div>
      </div>
    `
  },
  encoding: 'text'
});

// External URL integration
export const externalResource = createUIResource({
  uri: 'ui://external/documentation',
  content: {
    type: 'externalUrl',
    iframeUrl: 'https://mcpui.dev'
  },
  encoding: 'text'
});

// Remote DOM interactive component
export const interactiveResource = createUIResource({
  uri: 'ui://interactive/tool-caller',
  content: {
    type: 'remoteDom',
    script: `
      const container = document.createElement('div');
      container.style.cssText = 'padding: 20px; background: #f0f8ff; border-radius: 8px; font-family: Arial, sans-serif;';
      
      const title = document.createElement('h3');
      title.textContent = '🔧 Interactive Tool Caller';
      title.style.cssText = 'margin: 0 0 15px 0; color: #2c3e50;';
      
      const button = document.createElement('button');
      button.textContent = 'Execute AI Tool';
      button.style.cssText = 'padding: 12px 24px; background: #3498db; color: white; border: none; border-radius: 6px; cursor: pointer; font-size: 16px;';
      
      const status = document.createElement('div');
      status.style.cssText = 'margin-top: 15px; padding: 10px; background: #ecf0f1; border-radius: 4px; font-size: 14px;';
      status.textContent = 'Ready to execute...';
      
      button.addEventListener('click', () => {
        status.textContent = 'Executing tool call...';
        status.style.background = '#fff3cd';
        
        // Send tool call to parent
        window.parent.postMessage({
          type: 'tool',
          payload: {
            toolName: 'aiInteraction',
            params: {
              action: 'process-data',
              timestamp: new Date().toISOString(),
              source: 'mcp-ui-interactive'
            }
          }
        }, '*');
        
        setTimeout(() => {
          status.textContent = 'Tool executed successfully! ✅';
          status.style.background = '#d4edda';
        }, 1000);
      });
      
      container.appendChild(title);
      container.appendChild(button);
      container.appendChild(status);
      root.appendChild(container);
    `,
    framework: 'react'
  },
  encoding: 'text'
});
```

### 3. Implement the MCP Server

Create `src/server.ts`:

```typescript
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListResourcesRequestSchema,
  ListToolsRequestSchema,
  ReadResourceRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';
import {
  greetingResource,
  dashboardResource,
  externalResource,
  interactiveResource
} from './ui-resources.js';

class MCPUIServer {
  private server: Server;

  constructor() {
    this.server = new Server(
      {
        name: 'mcp-ui-tutorial-server',
        version: '1.0.0',
      },
      {
        capabilities: {
          resources: {},
          tools: {},
        },
      }
    );

    this.setupHandlers();
  }

  private setupHandlers() {
    // List available resources
    this.server.setRequestHandler(ListResourcesRequestSchema, async () => {
      return {
        resources: [
          {
            uri: greetingResource.uri,
            name: 'Welcome Greeting',
            description: 'A welcoming UI component for new users',
            mimeType: 'text/html'
          },
          {
            uri: dashboardResource.uri,
            name: 'Analytics Dashboard',
            description: 'Interactive dashboard showing AI agent metrics',
            mimeType: 'text/html'
          },
          {
            uri: externalResource.uri,
            name: 'MCP-UI Documentation',
            description: 'External documentation in iframe',
            mimeType: 'text/html'
          },
          {
            uri: interactiveResource.uri,
            name: 'Interactive Tool Caller',
            description: 'Component that can trigger tool calls',
            mimeType: 'text/html'
          }
        ]
      };
    });

    // Read specific resource
    this.server.setRequestHandler(ReadResourceRequestSchema, async (request) => {
      const { uri } = request.params;

      const resources = {
        [greetingResource.uri]: greetingResource,
        [dashboardResource.uri]: dashboardResource,
        [externalResource.uri]: externalResource,
        [interactiveResource.uri]: interactiveResource
      };

      const resource = resources[uri];
      if (!resource) {
        throw new Error(`Resource not found: ${uri}`);
      }

      return {
        contents: [
          {
            uri: resource.uri,
            mimeType: 'application/json',
            text: JSON.stringify(resource.content)
          }
        ]
      };
    });

    // List available tools
    this.server.setRequestHandler(ListToolsRequestSchema, async () => {
      return {
        tools: [
          {
            name: 'aiInteraction',
            description: 'Handle AI interaction events from UI components',
            inputSchema: {
              type: 'object',
              properties: {
                action: { type: 'string' },
                timestamp: { type: 'string' },
                source: { type: 'string' }
              },
              required: ['action']
            }
          },
          {
            name: 'generateUIComponent',
            description: 'Generate a new UI component dynamically',
            inputSchema: {
              type: 'object',
              properties: {
                componentType: { type: 'string' },
                title: { type: 'string' },
                content: { type: 'string' }
              },
              required: ['componentType', 'title']
            }
          }
        ]
      };
    });

    // Handle tool calls
    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;

      switch (name) {
        case 'aiInteraction':
          return {
            content: [
              {
                type: 'text',
                text: `AI Interaction processed: ${args.action} at ${args.timestamp} from ${args.source}`
              }
            ]
          };

        case 'generateUIComponent':
          const newComponent = this.generateDynamicComponent(args);
          return {
            content: [
              {
                type: 'resource',
                resource: newComponent
              }
            ]
          };

        default:
          throw new Error(`Unknown tool: ${name}`);
      }
    });
  }

  private generateDynamicComponent(args: any) {
    const { componentType, title, content = '' } = args;
    
    let htmlContent = '';
    
    switch (componentType) {
      case 'alert':
        htmlContent = `
          <div style="padding: 20px; background: #fff3cd; border: 1px solid #ffeaa7; border-radius: 8px; color: #856404;">
            <h4>⚠️ ${title}</h4>
            <p>${content}</p>
          </div>
        `;
        break;
      case 'success':
        htmlContent = `
          <div style="padding: 20px; background: #d4edda; border: 1px solid #c3e6cb; border-radius: 8px; color: #155724;">
            <h4>✅ ${title}</h4>
            <p>${content}</p>
          </div>
        `;
        break;
      default:
        htmlContent = `
          <div style="padding: 20px; background: #f8f9fa; border-radius: 8px;">
            <h4>${title}</h4>
            <p>${content}</p>
          </div>
        `;
    }

    return {
      uri: `ui://dynamic/${Date.now()}`,
      content: {
        type: 'rawHtml',
        htmlString: htmlContent
      },
      encoding: 'text'
    };
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error('MCP-UI Tutorial Server running on stdio');
  }
}

// Start the server
const server = new MCPUIServer();
server.run().catch(console.error);
```

### 4. Add Package Scripts

Update your `package.json`:

```json
{
  "name": "mcp-ui-tutorial",
  "version": "1.0.0",
  "scripts": {
    "build": "tsc",
    "start": "node dist/server.js",
    "dev": "ts-node src/server.ts",
    "test": "echo \"No tests yet\" && exit 0"
  },
  "dependencies": {
    "@mcp-ui/server": "^5.12.0",
    "@mcp-ui/client": "^5.12.0",
    "@modelcontextprotocol/sdk": "^0.5.0"
  },
  "devDependencies": {
    "typescript": "^5.0.0",
    "@types/node": "^20.0.0",
    "ts-node": "^10.9.0"
  }
}
```

## Building a Client Application

### 1. Create Client Structure

```bash
mkdir client
cd client
npm init -y
npm install @mcp-ui/client react react-dom @types/react @types/react-dom
npm install -D webpack webpack-cli webpack-dev-server html-webpack-plugin ts-loader css-loader
```

### 2. Implement React Client

Create `client/src/App.tsx`:

```typescript
import React, { useState, useEffect } from 'react';
import { UIResourceRenderer } from '@mcp-ui/client';

interface MCPResource {
  type: string;
  resource: {
    uri: string;
    content: any;
  };
}

const App: React.FC = () => {
  const [resources, setResources] = useState<MCPResource[]>([]);
  const [selectedResource, setSelectedResource] = useState<MCPResource | null>(null);

  // Mock MCP resources for demonstration
  useEffect(() => {
    const mockResources: MCPResource[] = [
      {
        type: 'resource',
        resource: {
          uri: 'ui://greeting/welcome',
          content: {
            type: 'rawHtml',
            htmlString: `
              <div style="padding: 20px; border-radius: 8px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; font-family: Arial, sans-serif;">
                <h2>🚀 Welcome to MCP-UI!</h2>
                <p>This is your first interactive AI interface component.</p>
                <button onclick="alert('Hello from MCP-UI!')" style="padding: 10px 20px; background: white; color: #667eea; border: none; border-radius: 4px; cursor: pointer;">
                  Click Me!
                </button>
              </div>
            `
          }
        }
      },
      {
        type: 'resource',
        resource: {
          uri: 'ui://dashboard/analytics',
          content: {
            type: 'rawHtml',
            htmlString: `
              <div style="padding: 20px; font-family: Arial, sans-serif;">
                <h3>📊 AI Agent Analytics Dashboard</h3>
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; margin-top: 20px;">
                  <div style="padding: 15px; background: #f8f9fa; border-radius: 8px; border-left: 4px solid #28a745;">
                    <h4 style="margin: 0; color: #28a745;">Active Sessions</h4>
                    <p style="font-size: 24px; margin: 10px 0; font-weight: bold;">42</p>
                  </div>
                  <div style="padding: 15px; background: #f8f9fa; border-radius: 8px; border-left: 4px solid #007bff;">
                    <h4 style="margin: 0; color: #007bff;">Total Requests</h4>
                    <p style="font-size: 24px; margin: 10px 0; font-weight: bold;">1,337</p>
                  </div>
                  <div style="padding: 15px; background: #f8f9fa; border-radius: 8px; border-left: 4px solid #ffc107;">
                    <h4 style="margin: 0; color: #ffc107;">Response Time</h4>
                    <p style="font-size: 24px; margin: 10px 0; font-weight: bold;">125ms</p>
                  </div>
                </div>
              </div>
            `
          }
        }
      }
    ];

    setResources(mockResources);
    setSelectedResource(mockResources[0]);
  }, []);

  const handleUIAction = (result: any) => {
    console.log('UI Action received:', result);
    // Handle tool calls or other UI actions here
  };

  return (
    <div className="app-container">
      <h1>🎯 MCP-UI Tutorial Client</h1>
      
      <div className="main-layout">
        {/* Resource Selector */}
        <div className="resource-selector">
          <h3>Available Resources</h3>
          <div className="resource-list">
            {resources.map((resource, index) => (
              <button
                key={index}
                onClick={() => setSelectedResource(resource)}
                className="resource-button"
              >
                {resource.resource.uri}
              </button>
            ))}
          </div>
        </div>

        {/* Resource Renderer */}
        <div className="resource-renderer">
          <h3>Rendered Component</h3>
          {selectedResource && selectedResource.resource.uri?.startsWith('ui://') ? (
            <UIResourceRenderer
              resource={selectedResource.resource}
              onUIAction={handleUIAction}
            />
          ) : (
            <p>Select a UI resource to render</p>
          )}
        </div>
      </div>
    </div>
  );
};

export default App;
```

## Testing Your MCP-UI Implementation

### 1. Build and Run the Server

```bash
# Build the TypeScript server
npm run build

# Run the server
npm run dev
```

### 2. Test with UI Inspector

Install the MCP-UI inspector for testing:

```bash
npx @mcp-ui/inspector
```

### 3. Connect to Your Server

1. Open the UI Inspector
2. Add your server configuration
3. Test the interactive components
4. Verify tool calls work correctly

## Advanced Features

### 1. Python Integration

Create a Python MCP-UI server:

```python
from mcp_ui_server import create_ui_resource
import asyncio
from mcp import Server, types

# Create UI resources
html_resource = create_ui_resource({
    "uri": "ui://python/greeting",
    "content": {
        "type": "rawHtml",
        "htmlString": "<h2>Hello from Python MCP-UI!</h2>"
    },
    "encoding": "text"
})

server = Server("python-mcp-ui-server")

@server.list_resources()
async def list_resources() -> list[types.Resource]:
    return [
        types.Resource(
            uri=html_resource["uri"],
            name="Python Greeting",
            mimeType="text/html"
        )
    ]

@server.read_resource()
async def read_resource(uri: str) -> str:
    if uri == html_resource["uri"]:
        return json.dumps(html_resource["content"])
    raise ValueError(f"Resource not found: {uri}")

if __name__ == "__main__":
    asyncio.run(server.run())
```

### 2. Ruby Integration

Create a Ruby MCP-UI server:

```ruby
require 'mcp_ui_server'
require 'mcp'

# Create UI resource
html_resource = McpUiServer.create_ui_resource(
  uri: 'ui://ruby/greeting',
  content: {
    type: :raw_html,
    htmlString: '<h2>Hello from Ruby MCP-UI!</h2>'
  },
  encoding: :text
)

server = MCP::Server.new('ruby-mcp-ui-server')

server.list_resources do
  [
    {
      uri: html_resource[:uri],
      name: 'Ruby Greeting',
      mimeType: 'text/html'
    }
  ]
end

server.read_resource do |uri|
  if uri == html_resource[:uri]
    html_resource[:content].to_json
  else
    raise "Resource not found: #{uri}"
  end
end

server.run
```

## Security Considerations

### 1. Sandboxed Execution

MCP-UI executes all content in sandboxed iframes for security:

```typescript
// Content is automatically sandboxed
const secureResource = createUIResource({
  uri: 'ui://secure/component',
  content: {
    type: 'rawHtml',
    htmlString: `
      <!-- This runs in a secure sandbox -->
      <script>
        // Limited access to parent window
        console.log('Secure execution environment');
      </script>
    `
  },
  encoding: 'text'
});
```

### 2. Message Validation

Always validate messages from UI components:

```typescript
const handleUIAction = (result: any) => {
  // Validate message structure
  if (!result.type || !result.payload) {
    console.error('Invalid UI action format');
    return;
  }

  // Sanitize parameters
  const sanitizedPayload = {
    toolName: String(result.payload.toolName || ''),
    params: result.payload.params || {}
  };

  // Process validated action
  processToolCall(sanitizedPayload);
};
```

## Deployment Strategies

### 1. Containerized Deployment

Create a `Dockerfile`:

```dockerfile
FROM node:18-alpine

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

COPY dist/ ./dist/
EXPOSE 3000

CMD ["npm", "start"]
```

### 2. Serverless Deployment

Deploy to Cloudflare Workers:

```typescript
export default {
  async fetch(request: Request): Promise<Response> {
    const server = new MCPUIServer();
    
    if (request.method === 'POST') {
      const body = await request.json();
      const response = await server.handleRequest(body);
      return new Response(JSON.stringify(response));
    }
    
    return new Response('MCP-UI Server', { status: 200 });
  }
};
```

## Best Practices

### 1. Component Design

- **Keep components focused**: Each UI resource should have a single responsibility
- **Use semantic HTML**: Ensure accessibility and proper structure
- **Implement error boundaries**: Handle failures gracefully
- **Optimize performance**: Minimize resource size and complexity

### 2. State Management

```typescript
// Use consistent state patterns
const createStatefulComponent = (initialState: any) => {
  return createUIResource({
    uri: 'ui://stateful/component',
    content: {
      type: 'remoteDom',
      script: `
        let state = ${JSON.stringify(initialState)};
        
        function updateState(newState) {
          state = { ...state, ...newState };
          render();
        }
        
        function render() {
          // Update DOM based on state
        }
        
        render();
      `,
      framework: 'react'
    },
    encoding: 'text'
  });
};
```

### 3. Error Handling

```typescript
// Implement comprehensive error handling
const robustResource = createUIResource({
  uri: 'ui://robust/component',
  content: {
    type: 'remoteDom',
    script: `
      try {
        // Component logic here
      } catch (error) {
        console.error('Component error:', error);
        root.innerHTML = '<div style="color: red;">Component failed to load</div>';
      }
    `,
    framework: 'react'
  },
  encoding: 'text'
});
```

## Troubleshooting Common Issues

### 1. Resource Not Found

```bash
# Check resource URI format
Error: Resource not found: ui://invalid/uri

# Solution: Ensure proper URI format
uri: 'ui://namespace/component-name'
```

### 2. Sandbox Restrictions

```javascript
// Issue: Cannot access parent window
window.parent.someFunction(); // ❌ Blocked

// Solution: Use postMessage API
window.parent.postMessage({
  type: 'tool',
  payload: { /* data */ }
}, '*'); // ✅ Allowed
```

### 3. Content Security Policy

```html
<!-- Add CSP headers for security -->
<meta http-equiv="Content-Security-Policy" 
      content="default-src 'self'; script-src 'unsafe-inline';">
```

## Conclusion

MCP-UI represents a significant advancement in AI interface development, enabling developers to create rich, interactive experiences that seamlessly integrate with AI agents. By following this tutorial, you've learned:

- How to set up MCP-UI servers in multiple languages
- Creating various types of UI resources
- Implementing secure, interactive components
- Best practices for deployment and maintenance

The framework's flexibility and security features make it an excellent choice for building next-generation AI interfaces. As the ecosystem continues to evolve, MCP-UI will play a crucial role in shaping how users interact with AI systems.

## Next Steps

1. **Explore Advanced Components**: Experiment with complex UI patterns
2. **Integration Testing**: Test with different MCP hosts
3. **Performance Optimization**: Profile and optimize your components
4. **Community Contribution**: Share your components with the MCP-UI community

## Resources

- [MCP-UI Official Documentation](https://mcpui.dev)
- [GitHub Repository](https://github.com/idosal/mcp-ui)
- [MCP Protocol Specification](https://modelcontextprotocol.io)
- [Community Examples](https://github.com/idosal/mcp-ui/tree/main/examples)

---

*Ready to build the future of AI interfaces? Start experimenting with MCP-UI today and create experiences that will define the next generation of human-AI interaction!*
