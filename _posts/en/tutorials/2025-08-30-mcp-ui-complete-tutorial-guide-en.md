---
title: "MCP-UI Complete Tutorial: Building Next-Gen UI Experiences for AI Agents"
excerpt: "Learn how to create interactive UI components for MCP (Model Context Protocol) servers using MCP-UI. Complete guide with TypeScript and Ruby examples."
seo_title: "MCP-UI Tutorial: Build Interactive AI Agent UIs - Complete Guide"
seo_description: "Master MCP-UI development with this comprehensive tutorial. Learn to create interactive UI components for AI agents using TypeScript and Ruby with practical examples."
date: 2025-08-30
categories:
  - tutorials
tags:
  - mcp-ui
  - ai-agents
  - typescript
  - ruby
  - user-interface
  - model-context-protocol
author_profile: true
toc: true
toc_label: "Table of Contents"
lang: en
permalink: /en/tutorials/mcp-ui-complete-tutorial-guide/
canonical_url: "https://thakicloud.github.io/en/tutorials/mcp-ui-complete-tutorial-guide/"
---

⏱️ **Estimated Reading Time**: 15 minutes

## Introduction to MCP-UI

The Model Context Protocol (MCP) has revolutionized how AI agents interact with external systems. However, traditional text-based interactions often fall short when dealing with complex data visualization or interactive workflows. This is where **MCP-UI** comes in - a groundbreaking SDK that enables rich, interactive user interfaces within MCP servers.

MCP-UI allows developers to create dynamic UI components that can be rendered directly in MCP-compatible clients, providing users with intuitive visual interfaces for complex operations. Whether you're building data dashboards, form interfaces, or interactive visualizations, MCP-UI bridges the gap between AI agents and human-friendly interfaces.

## What is MCP-UI?

MCP-UI is an open-source SDK that extends the Model Context Protocol to support rich user interface components. It enables MCP servers to return not just text responses, but fully interactive UI elements that can be rendered in compatible clients.

### Key Features

- **Multiple Content Types**: Support for raw HTML, external URLs, and remote DOM components
- **Framework Flexibility**: Works with React, Web Components, and vanilla JavaScript
- **Security First**: All UI content runs in sandboxed iframes for maximum security
- **Interactive Actions**: UI components can trigger tool calls and interact with the agent
- **Cross-Platform**: Compatible with multiple MCP hosts including Postman, Goose, and Smithery

### Architecture Overview

MCP-UI follows a client-server architecture where:

1. **Server Side**: Creates UI resources using the MCP-UI server SDK
2. **Client Side**: Renders UI resources using the MCP-UI client renderer
3. **Communication**: UI actions are communicated back to the server via events

## Installation and Setup

### Prerequisites

Before getting started, ensure you have:
- Node.js 16+ (for TypeScript development)
- Ruby 3.0+ (for Ruby development)
- Basic understanding of MCP concepts
- Familiarity with React or Web Components

### TypeScript Installation

```bash
# Using npm
npm install @mcp-ui/server @mcp-ui/client

# Using pnpm
pnpm add @mcp-ui/server @mcp-ui/client

# Using yarn
yarn add @mcp-ui/server @mcp-ui/client
```

### Ruby Installation

```bash
gem install mcp_ui_server
```

## Building Your First MCP-UI Component

Let's start with a simple example that demonstrates the core concepts of MCP-UI.

### TypeScript Example: Interactive Greeting

#### Server-Side Implementation

```typescript
import { createUIResource } from '@mcp-ui/server';

// Simple HTML greeting
const createGreetingResource = (name: string) => {
  return createUIResource({
    uri: `ui://greeting/${Date.now()}`,
    content: {
      type: 'rawHtml',
      htmlString: `
        <div style="padding: 20px; border: 2px solid #007acc; border-radius: 8px; background: #f0f8ff;">
          <h2 style="color: #007acc; margin: 0 0 10px 0;">Hello, ${name}!</h2>
          <p style="margin: 0; color: #333;">Welcome to MCP-UI tutorial.</p>
          <button onclick="window.parent.postMessage({type: 'tool', payload: {toolName: 'nextStep', params: {action: 'continue'}}}, '*')" 
                  style="margin-top: 15px; padding: 8px 16px; background: #007acc; color: white; border: none; border-radius: 4px; cursor: pointer;">
            Continue Tutorial
          </button>
        </div>
      `
    },
    encoding: 'text'
  });
};

// Usage in your MCP server tool
export const greetingTool = {
  name: 'create_greeting',
  description: 'Create an interactive greeting UI',
  inputSchema: {
    type: 'object',
    properties: {
      name: { type: 'string', description: 'Name to greet' }
    },
    required: ['name']
  },
  handler: async (args: { name: string }) => {
    const resource = createGreetingResource(args.name);
    return {
      content: [
        {
          type: 'resource',
          resource: resource
        }
      ]
    };
  }
};
```

#### Client-Side Rendering

```typescript
import React from 'react';
import { UIResourceRenderer } from '@mcp-ui/client';

interface MCPUIAppProps {
  mcpResource: any;
}

function MCPUIApp({ mcpResource }: MCPUIAppProps) {
  const handleUIAction = (result: any) => {
    console.log('UI Action received:', result);
    
    // Handle different action types
    switch (result.payload?.toolName) {
      case 'nextStep':
        console.log('User wants to continue tutorial');
        // Trigger next step in your application
        break;
      default:
        console.log('Unknown action:', result);
    }
  };

  if (
    mcpResource.type === 'resource' &&
    mcpResource.resource.uri?.startsWith('ui://')
  ) {
    return (
      <UIResourceRenderer
        resource={mcpResource.resource}
        onUIAction={handleUIAction}
      />
    );
  }

  return <p>Unsupported resource type</p>;
}

export default MCPUIApp;
```

### Ruby Example: Simple Dashboard

```ruby
require 'mcp_ui_server'

class DashboardServer
  def create_dashboard_resource(data)
    McpUiServer.create_ui_resource(
      uri: "ui://dashboard/#{Time.now.to_i}",
      content: {
        type: :raw_html,
        htmlString: build_dashboard_html(data)
      },
      encoding: :text
    )
  end

  private

  def build_dashboard_html(data)
    <<~HTML
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h1 style="color: #2c3e50; text-align: center;">System Dashboard</h1>
        
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin: 20px 0;">
          #{data.map { |item| create_card_html(item) }.join}
        </div>
        
        <button onclick="refreshDashboard()" 
                style="width: 100%; padding: 12px; background: #3498db; color: white; border: none; border-radius: 6px; font-size: 16px; cursor: pointer;">
          Refresh Data
        </button>
        
        <script>
          function refreshDashboard() {
            window.parent.postMessage({
              type: 'tool',
              payload: {
                toolName: 'refresh_dashboard',
                params: { timestamp: new Date().toISOString() }
              }
            }, '*');
          }
        </script>
      </div>
    HTML
  end

  def create_card_html(item)
    <<~HTML
      <div style="background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); border-left: 4px solid #3498db;">
        <h3 style="margin: 0 0 10px 0; color: #2c3e50;">#{item[:title]}</h3>
        <p style="margin: 0; font-size: 24px; font-weight: bold; color: #27ae60;">#{item[:value]}</p>
        <small style="color: #7f8c8d;">#{item[:description]}</small>
      </div>
    HTML
  end
end

# Usage example
dashboard_data = [
  { title: 'Active Users', value: '1,234', description: 'Currently online' },
  { title: 'Revenue', value: '$45,678', description: 'This month' },
  { title: 'Orders', value: '892', description: 'Pending processing' }
]

server = DashboardServer.new
resource = server.create_dashboard_resource(dashboard_data)
```

## Advanced Features: Remote DOM Components

Remote DOM is MCP-UI's most powerful feature, allowing you to create dynamic, framework-aware components that can interact seamlessly with the host application.

### React Remote DOM Example

```typescript
import { createUIResource } from '@mcp-ui/server';

const createInteractiveFormResource = () => {
  return createUIResource({
    uri: 'ui://forms/user-registration',
    content: {
      type: 'remoteDom',
      script: `
        // Create form container
        const form = document.createElement('div');
        form.style.cssText = 'max-width: 400px; margin: 0 auto; padding: 20px; background: #f8f9fa; border-radius: 8px;';
        
        // Form title
        const title = document.createElement('h2');
        title.textContent = 'User Registration';
        title.style.cssText = 'color: #495057; margin-bottom: 20px; text-align: center;';
        form.appendChild(title);
        
        // Name input
        const nameGroup = createInputGroup('Name', 'text', 'name');
        form.appendChild(nameGroup);
        
        // Email input
        const emailGroup = createInputGroup('Email', 'email', 'email');
        form.appendChild(emailGroup);
        
        // Role select
        const roleGroup = createSelectGroup('Role', 'role', [
          { value: 'user', label: 'User' },
          { value: 'admin', label: 'Administrator' },
          { value: 'moderator', label: 'Moderator' }
        ]);
        form.appendChild(roleGroup);
        
        // Submit button
        const submitBtn = document.createElement('button');
        submitBtn.textContent = 'Register User';
        submitBtn.style.cssText = 'width: 100%; padding: 12px; background: #007bff; color: white; border: none; border-radius: 4px; font-size: 16px; cursor: pointer; margin-top: 20px;';
        
        submitBtn.addEventListener('click', (e) => {
          e.preventDefault();
          
          const formData = {
            name: form.querySelector('[name="name"]').value,
            email: form.querySelector('[name="email"]').value,
            role: form.querySelector('[name="role"]').value
          };
          
          // Validate form
          if (!formData.name || !formData.email) {
            alert('Please fill in all required fields');
            return;
          }
          
          // Send data to parent
          window.parent.postMessage({
            type: 'tool',
            payload: {
              toolName: 'register_user',
              params: formData
            }
          }, '*');
        });
        
        form.appendChild(submitBtn);
        
        // Helper functions
        function createInputGroup(label, type, name) {
          const group = document.createElement('div');
          group.style.cssText = 'margin-bottom: 15px;';
          
          const labelEl = document.createElement('label');
          labelEl.textContent = label;
          labelEl.style.cssText = 'display: block; margin-bottom: 5px; font-weight: 500; color: #495057;';
          
          const input = document.createElement('input');
          input.type = type;
          input.name = name;
          input.style.cssText = 'width: 100%; padding: 8px 12px; border: 1px solid #ced4da; border-radius: 4px; font-size: 14px;';
          input.required = true;
          
          group.appendChild(labelEl);
          group.appendChild(input);
          return group;
        }
        
        function createSelectGroup(label, name, options) {
          const group = document.createElement('div');
          group.style.cssText = 'margin-bottom: 15px;';
          
          const labelEl = document.createElement('label');
          labelEl.textContent = label;
          labelEl.style.cssText = 'display: block; margin-bottom: 5px; font-weight: 500; color: #495057;';
          
          const select = document.createElement('select');
          select.name = name;
          select.style.cssText = 'width: 100%; padding: 8px 12px; border: 1px solid #ced4da; border-radius: 4px; font-size: 14px;';
          
          options.forEach(option => {
            const optionEl = document.createElement('option');
            optionEl.value = option.value;
            optionEl.textContent = option.label;
            select.appendChild(optionEl);
          });
          
          group.appendChild(labelEl);
          group.appendChild(select);
          return group;
        }
        
        // Add form to root
        root.appendChild(form);
      `,
      framework: 'react'
    },
    encoding: 'text'
  });
};
```

## Testing Your MCP-UI Implementation

### Using UI Inspector

MCP-UI provides a built-in UI inspector for testing your implementations locally:

```bash
# Install the UI inspector
npm install -g @mcp-ui/ui-inspector

# Run the inspector
ui-inspector --server your-mcp-server-config.json
```

### Local Testing Setup

Create a test environment to verify your MCP-UI components:

```typescript
// test-mcp-ui.ts
import { createUIResource } from '@mcp-ui/server';
import { UIResourceRenderer } from '@mcp-ui/client';

// Test your UI resources
const testResource = createUIResource({
  uri: 'ui://test/component',
  content: {
    type: 'rawHtml',
    htmlString: '<div>Test Component</div>'
  },
  encoding: 'text'
});

console.log('Generated resource:', JSON.stringify(testResource, null, 2));
```

### Integration Testing

```bash
# Test with a real MCP server
curl -X POST http://localhost:3000/mcp \
  -H "Content-Type: application/json" \
  -d '{"method": "tools/call", "params": {"name": "create_greeting", "arguments": {"name": "World"}}}'
```

## Best Practices and Security

### Security Considerations

1. **Input Sanitization**: Always sanitize user inputs before rendering in HTML
2. **Content Security Policy**: Implement proper CSP headers for iframe content
3. **Sandbox Restrictions**: Leverage iframe sandboxing for untrusted content
4. **Event Validation**: Validate all UI action events before processing

### Performance Optimization

1. **Resource Caching**: Cache frequently used UI resources
2. **Lazy Loading**: Load UI components only when needed
3. **Bundle Size**: Keep JavaScript bundles small for faster loading
4. **Event Debouncing**: Debounce frequent UI events to prevent spam

### Code Organization

```typescript
// Organize your UI resources
export class UIResourceFactory {
  static createDashboard(data: DashboardData): UIResource {
    // Implementation
  }
  
  static createForm(schema: FormSchema): UIResource {
    // Implementation
  }
  
  static createChart(chartData: ChartData): UIResource {
    // Implementation
  }
}

// Use consistent naming conventions
const UI_NAMESPACES = {
  DASHBOARD: 'ui://dashboard',
  FORMS: 'ui://forms',
  CHARTS: 'ui://charts'
} as const;
```

## Supported MCP Hosts

MCP-UI is compatible with several MCP hosts, each with varying levels of feature support:

| Host | Rendering | UI Actions | Notes |
|------|-----------|------------|-------|
| **Postman** | ✅ | ⚠️ | Full rendering, partial action support |
| **Goose** | ✅ | ⚠️ | Good integration, some action limitations |
| **Smithery** | ✅ | ❌ | Display only, no interactive features |
| **MCPJam** | ✅ | ❌ | Playground environment |
| **VSCode** | 🔄 | 🔄 | Coming soon |

## Troubleshooting Common Issues

### UI Not Rendering

```typescript
// Check resource format
const resource = createUIResource({
  uri: 'ui://test/1', // Must start with 'ui://'
  content: {
    type: 'rawHtml', // Correct content type
    htmlString: '<div>Content</div>' // Valid HTML
  },
  encoding: 'text' // Correct encoding
});
```

### Actions Not Working

```javascript
// Ensure proper event format
window.parent.postMessage({
  type: 'tool', // Must be 'tool'
  payload: {
    toolName: 'your_tool_name', // Valid tool name
    params: { /* valid parameters */ }
  }
}, '*');
```

### Styling Issues

```html
<!-- Use inline styles for better compatibility -->
<div style="padding: 20px; background: #f0f0f0;">
  Content with inline styles
</div>
```

## Conclusion

MCP-UI represents a significant advancement in AI agent interfaces, enabling rich, interactive experiences that go far beyond traditional text-based interactions. By following this tutorial, you've learned how to:

- Set up MCP-UI in both TypeScript and Ruby environments
- Create interactive UI components using different content types
- Implement advanced features like Remote DOM components
- Handle UI actions and events properly
- Follow security best practices and optimization techniques

The future of AI agent interactions lies in seamless, intuitive user interfaces, and MCP-UI provides the foundation for building these next-generation experiences. Whether you're creating simple dashboards or complex interactive applications, MCP-UI offers the flexibility and power needed to bring your vision to life.

## Additional Resources

- **Official Documentation**: [mcpui.dev](https://mcpui.dev)
- **GitHub Repository**: [github.com/idosal/mcp-ui](https://github.com/idosal/mcp-ui)
- **Live Examples**: Try the hosted demo servers
- **Community**: Join the MCP-UI community for support and discussions

Start building your own MCP-UI components today and transform how users interact with your AI agents!
