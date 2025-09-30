---
title: "AIO Sandbox: Complete Guide to All-in-One AI Agent Development Environment"
excerpt: "Learn how to set up and use agent-infra/sandbox, the comprehensive Docker-based development environment that combines browser automation, terminal access, file operations, VSCode Server, and MCP integration in a single container."
seo_title: "AIO Sandbox Tutorial: All-in-One AI Agent Development Environment - Thaki Cloud"
seo_description: "Complete tutorial on agent-infra/sandbox - Docker container with browser automation, VSCode Server, Jupyter, MCP integration for AI agent development. Step-by-step setup guide."
date: 2025-09-30
categories:
  - tutorials
tags:
  - ai-agents
  - docker
  - sandbox
  - mcp
  - browser-automation
  - vscode
  - jupyter
author_profile: true
toc: true
toc_label: "Table of Contents"
canonical_url: "https://thakicloud.github.io/en/tutorials/agent-infra-sandbox-all-in-one-ai-development-tutorial/"
lang: en
permalink: /en/tutorials/agent-infra-sandbox-all-in-one-ai-development-tutorial/
---

⏱️ **Estimated Reading Time**: 12 minutes

## Introduction

In the rapidly evolving world of AI agent development, having a unified, comprehensive development environment is crucial for productivity and seamless workflows. The **AIO Sandbox** (All-in-One Sandbox) by agent-infra provides exactly that - a single Docker container that combines browser automation, terminal access, file operations, VSCode Server, Jupyter notebooks, and Model Context Protocol (MCP) integration.

This tutorial will guide you through setting up and using AIO Sandbox for AI agent development, from basic installation to advanced integration patterns with popular AI frameworks.

## What is AIO Sandbox?

AIO Sandbox is a Docker-based development environment that consolidates multiple tools and services into a single container:

- **🌐 Browser Automation**: Full browser control via VNC, Chrome DevTools Protocol (CDP), and MCP
- **💻 Development Tools**: VSCode Server, Jupyter Notebook, WebSocket-based terminal
- **📁 File Operations**: Complete file system access and manipulation
- **🤖 MCP Integration**: Pre-configured Model Context Protocol servers
- **🚀 Smart Previews**: Port forwarding and web application preview capabilities

All components share the same filesystem, enabling seamless workflows between different tools and interfaces.

## Prerequisites

Before starting, ensure you have:

- Docker installed on your system
- Basic knowledge of Docker commands
- Python programming experience (for examples)
- Understanding of AI agent concepts

## Quick Start Installation

### Method 1: Basic Docker Run

The fastest way to get started is with a simple Docker command:

```bash
# Run AIO Sandbox on port 8080
docker run --rm -it -p 8080:8080 ghcr.io/agent-infra/sandbox:latest
```

For users in mainland China, use the alternative registry:

```bash
docker run --rm -it -p 8080:8080 enterprise-public-cn-beijing.cr.volces.com/vefaas-public/all-in-one-sandbox:latest
```

### Method 2: Using Specific Version

To use a specific version (recommended for production):

```bash
# Example: Using version 1.0.0.125
docker run --rm -it -p 8080:8080 ghcr.io/agent-infra/sandbox:1.0.0.125
```

### Method 3: Docker Compose Setup

For more advanced configurations, create a `docker-compose.yaml` file:

```yaml
version: '3.8'
services:
  sandbox:
    container_name: aio-sandbox
    image: ghcr.io/agent-infra/sandbox:latest
    volumes:
      - ./workspace:/home/gem/workspace
    security_opt:
      - seccomp:unconfined
    extra_hosts:
      - "host.docker.internal:host-gateway"
    restart: "unless-stopped"
    shm_size: "2gb"
    ports:
      - "8080:8080"
    environment:
      WORKSPACE: "/home/gem"
      TZ: "UTC"
      HOMEPAGE: ""
      BROWSER_EXTRA_ARGS: ""
```

Then run:

```bash
docker-compose up -d
```

## Accessing the Sandbox

Once the container is running, you can access various interfaces:

- **Main Dashboard**: http://localhost:8080
- **VSCode Server**: http://localhost:8080/vscode
- **Jupyter Notebook**: http://localhost:8080/jupyter
- **VNC Browser**: http://localhost:8080/vnc
- **Terminal**: http://localhost:8080/terminal

## Core Components Overview

### 1. Browser Automation

AIO Sandbox provides three ways to interact with browsers:

#### VNC Interface
Visual browser interaction through remote desktop:
- Full GUI browser experience
- Mouse and keyboard interaction
- Screenshot capabilities

#### Chrome DevTools Protocol (CDP)
Programmatic browser control:
- Automated navigation
- Element interaction
- Performance monitoring
- Network interception

#### MCP Browser Tools
High-level browser automation through Model Context Protocol:
- Simplified API for common tasks
- AI-friendly interface
- Integrated with other MCP services

### 2. Development Environment

#### VSCode Server
Full IDE experience in your browser:
- Syntax highlighting and IntelliSense
- Integrated terminal
- Extension support
- Git integration

#### Jupyter Notebook
Interactive Python development:
- Code execution in cells
- Rich output display
- Data visualization
- Markdown documentation

### 3. File System Operations

Complete file system access through:
- Web-based file manager
- API endpoints for programmatic access
- Terminal file operations
- VSCode file explorer

## Python SDK Installation and Usage

### Installing the SDK

```bash
pip install agent-sandbox
```

### Basic SDK Usage

Here's a comprehensive example that demonstrates the key features:

```python
import asyncio
import base64
from playwright.async_api import async_playwright
from agent_sandbox import Sandbox

async def comprehensive_sandbox_demo():
    # Initialize sandbox client
    client = Sandbox(base_url="http://localhost:8080")
    
    # Get sandbox context information
    context = client.sandbox.get_sandbox_context()
    home_dir = context.home_dir
    print(f"Sandbox home directory: {home_dir}")
    
    # 1. File Operations
    print("\n=== File Operations ===")
    
    # Create a sample file
    sample_content = "Hello from AIO Sandbox!\nThis is a test file."
    client.file.write_file(file=f"{home_dir}/sample.txt", content=sample_content)
    
    # Read the file back
    file_content = client.file.read_file(file=f"{home_dir}/sample.txt")
    print(f"File content: {file_content.data.content}")
    
    # List files in directory
    files = client.file.list_files(directory=home_dir)
    print(f"Files in home directory: {[f.name for f in files.data.files]}")
    
    # 2. Shell Operations
    print("\n=== Shell Operations ===")
    
    # Execute shell commands
    result = client.shell.exec_command(command="ls -la")
    print(f"Shell output: {result.data.output}")
    
    # Create a Python script and execute it
    python_script = """
import datetime
import json

data = {
    'timestamp': datetime.datetime.now().isoformat(),
    'message': 'Generated from AIO Sandbox',
    'numbers': [1, 2, 3, 4, 5]
}

print(json.dumps(data, indent=2))
"""
    
    client.file.write_file(file=f"{home_dir}/script.py", content=python_script)
    script_result = client.shell.exec_command(command=f"cd {home_dir} && python script.py")
    print(f"Python script output: {script_result.data.output}")
    
    # 3. Jupyter Operations
    print("\n=== Jupyter Operations ===")
    
    # Execute Python code in Jupyter
    jupyter_code = f"""
import matplotlib.pyplot as plt
import numpy as np

# Generate sample data
x = np.linspace(0, 10, 100)
y = np.sin(x)

# Create plot
plt.figure(figsize=(10, 6))
plt.plot(x, y, 'b-', linewidth=2, label='sin(x)')
plt.xlabel('x')
plt.ylabel('y')
plt.title('Sine Wave Generated in AIO Sandbox')
plt.legend()
plt.grid(True)
plt.savefig('{home_dir}/sine_wave.png', dpi=150, bbox_inches='tight')
plt.show()

print("Plot saved successfully!")
"""
    
    jupyter_result = client.jupyter.execute_jupyter_code(code=jupyter_code)
    print(f"Jupyter execution result: {jupyter_result.data}")
    
    # 4. Browser Automation
    print("\n=== Browser Automation ===")
    
    # Get browser information
    browser_info = client.browser.get_browser_info()
    print(f"Browser CDP URL: {browser_info.data.cdp_url}")
    
    # Use Playwright with the sandbox browser
    async with async_playwright() as p:
        browser = await p.chromium.connect_over_cdp(browser_info.data.cdp_url)
        page = await browser.new_page()
        
        # Navigate to a website
        await page.goto("https://httpbin.org/json", wait_until="networkidle")
        
        # Get page content
        content = await page.content()
        print(f"Page title: {await page.title()}")
        
        # Take screenshot
        screenshot_bytes = await page.screenshot()
        screenshot_b64 = base64.b64encode(screenshot_bytes).decode('utf-8')
        
        # Save screenshot info
        client.file.write_file(
            file=f"{home_dir}/screenshot_info.txt", 
            content=f"Screenshot taken at: {asyncio.get_event_loop().time()}\nSize: {len(screenshot_bytes)} bytes"
        )
        
        await browser.close()
    
    print("Browser automation completed successfully!")
    
    # 5. Advanced File Operations
    print("\n=== Advanced File Operations ===")
    
    # Search for files
    search_result = client.file.search_files(directory=home_dir, pattern="*.py")
    print(f"Python files found: {[f.path for f in search_result.data.files]}")
    
    # Create a comprehensive report
    report_content = f"""
# AIO Sandbox Demo Report

Generated on: {asyncio.get_event_loop().time()}

## Files Created:
- sample.txt: Basic text file
- script.py: Python script with JSON output
- sine_wave.png: Matplotlib visualization
- screenshot_info.txt: Browser screenshot metadata

## Operations Performed:
1. File read/write operations
2. Shell command execution
3. Jupyter code execution with visualization
4. Browser automation with Playwright
5. File search and directory listing

## Sandbox Environment:
- Home Directory: {home_dir}
- Browser CDP Available: Yes
- Jupyter Kernel: Active
- Shell Access: Available

This report demonstrates the comprehensive capabilities of AIO Sandbox
for AI agent development and automation tasks.
"""
    
    client.file.write_file(file=f"{home_dir}/demo_report.md", content=report_content)
    print("Comprehensive demo completed! Check demo_report.md for summary.")

if __name__ == "__main__":
    asyncio.run(comprehensive_sandbox_demo())
```

## Advanced Integration Examples

### Integration with LangChain

```python
from langchain.tools import BaseTool
from agent_sandbox import Sandbox
from typing import Optional

class SandboxExecutionTool(BaseTool):
    name = "sandbox_execute"
    description = """Execute commands in AIO Sandbox environment. 
    Useful for running code, file operations, and browser automation."""
    
    def __init__(self, sandbox_url: str = "http://localhost:8080"):
        super().__init__()
        self.client = Sandbox(base_url=sandbox_url)
    
    def _run(self, command: str, operation_type: str = "shell") -> str:
        """Execute command in sandbox based on operation type."""
        try:
            if operation_type == "shell":
                result = self.client.shell.exec_command(command=command)
                return result.data.output
            elif operation_type == "jupyter":
                result = self.client.jupyter.execute_jupyter_code(code=command)
                return str(result.data)
            elif operation_type == "file_read":
                result = self.client.file.read_file(file=command)
                return result.data.content
            else:
                return f"Unsupported operation type: {operation_type}"
        except Exception as e:
            return f"Error executing command: {str(e)}"

# Usage example
sandbox_tool = SandboxExecutionTool()

# Execute Python code
python_result = sandbox_tool._run(
    command="print('Hello from LangChain + AIO Sandbox!')", 
    operation_type="jupyter"
)
print(python_result)
```

### Integration with OpenAI Assistant

```python
import json
from openai import OpenAI
from agent_sandbox import Sandbox

class OpenAISandboxIntegration:
    def __init__(self, openai_api_key: str, sandbox_url: str = "http://localhost:8080"):
        self.openai_client = OpenAI(api_key=openai_api_key)
        self.sandbox = Sandbox(base_url=sandbox_url)
    
    def run_code(self, code: str, language: str = "python") -> dict:
        """Execute code in sandbox and return results."""
        try:
            if language == "python":
                result = self.sandbox.jupyter.execute_jupyter_code(code=code)
                return {"success": True, "output": result.data}
            elif language == "shell":
                result = self.sandbox.shell.exec_command(command=code)
                return {"success": True, "output": result.data.output}
            else:
                return {"success": False, "error": f"Unsupported language: {language}"}
        except Exception as e:
            return {"success": False, "error": str(e)}
    
    def chat_with_code_execution(self, user_message: str) -> str:
        """Chat with OpenAI and execute code when needed."""
        tools = [{
            "type": "function",
            "function": {
                "name": "run_code",
                "description": "Execute Python or shell code in a sandbox environment",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "code": {"type": "string", "description": "Code to execute"},
                        "language": {"type": "string", "enum": ["python", "shell"], "default": "python"}
                    },
                    "required": ["code"]
                }
            }
        }]
        
        response = self.openai_client.chat.completions.create(
            model="gpt-4",
            messages=[{"role": "user", "content": user_message}],
            tools=tools
        )
        
        message = response.choices[0].message
        
        if message.tool_calls:
            # Execute the code
            tool_call = message.tool_calls[0]
            args = json.loads(tool_call.function.arguments)
            result = self.run_code(**args)
            
            if result["success"]:
                return f"Code executed successfully:\n{result['output']}"
            else:
                return f"Code execution failed: {result['error']}"
        else:
            return message.content

# Usage example
integration = OpenAISandboxIntegration(openai_api_key="your_api_key")
response = integration.chat_with_code_execution("Calculate the factorial of 10 and create a simple plot")
print(response)
```

## MCP (Model Context Protocol) Integration

AIO Sandbox comes with pre-configured MCP servers that provide AI-friendly interfaces:

### Available MCP Servers

1. **Browser MCP**: Web automation and scraping
2. **File MCP**: File system operations
3. **Shell MCP**: Command execution
4. **Markitdown MCP**: Document processing
5. **Arxiv MCP**: Research paper access

### Using MCP Tools

```python
from agent_sandbox import Sandbox

def demonstrate_mcp_tools():
    client = Sandbox(base_url="http://localhost:8080")
    
    # Example: Using browser MCP for web scraping
    # This would typically be used through an MCP client
    # The sandbox provides the server endpoints
    
    # Get MCP server information
    context = client.sandbox.get_sandbox_context()
    print(f"MCP servers available at: {context.home_dir}")
    
    # Example of combining multiple tools
    # 1. Use browser to fetch content
    browser_info = client.browser.get_browser_info()
    
    # 2. Use file operations to save results
    client.file.write_file(
        file=f"{context.home_dir}/mcp_demo.txt",
        content="MCP integration demo completed"
    )
    
    # 3. Use shell to process results
    result = client.shell.exec_command(
        command=f"wc -l {context.home_dir}/mcp_demo.txt"
    )
    
    print(f"File processing result: {result.data.output}")

demonstrate_mcp_tools()
```

## Production Deployment

### Kubernetes Deployment

For production environments, you can deploy AIO Sandbox on Kubernetes:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: aio-sandbox
  namespace: ai-agents
spec:
  replicas: 2
  selector:
    matchLabels:
      app: aio-sandbox
  template:
    metadata:
      labels:
        app: aio-sandbox
    spec:
      containers:
      - name: aio-sandbox
        image: ghcr.io/agent-infra/sandbox:latest
        ports:
        - containerPort: 8080
        resources:
          limits:
            memory: "4Gi"
            cpu: "2000m"
          requests:
            memory: "2Gi"
            cpu: "1000m"
        env:
        - name: WORKSPACE
          value: "/home/gem"
        - name: TZ
          value: "UTC"
        volumeMounts:
        - name: workspace-volume
          mountPath: /home/gem/workspace
      volumes:
      - name: workspace-volume
        persistentVolumeClaim:
          claimName: sandbox-workspace-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: aio-sandbox-service
  namespace: ai-agents
spec:
  selector:
    app: aio-sandbox
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
  type: LoadBalancer
```

### Environment Configuration

Key environment variables for production:

```bash
# Security
JWT_PUBLIC_KEY=your_jwt_public_key
PROXY_SERVER=your_proxy_server

# Workspace
WORKSPACE=/home/gem
HOMEPAGE=https://your-homepage.com

# Browser
BROWSER_EXTRA_ARGS=--no-sandbox --disable-dev-shm-usage

# Networking
DNS_OVER_HTTPS_TEMPLATES=https://cloudflare-dns.com/dns-query
WAIT_PORTS=3000,8000,9000

# Timezone
TZ=UTC
```

## Best Practices and Tips

### 1. Resource Management

- **Memory**: Allocate at least 2GB RAM for smooth operation
- **CPU**: 1-2 cores recommended for development, more for production
- **Storage**: Use persistent volumes for important data

### 2. Security Considerations

- Run with appropriate security contexts in production
- Use JWT authentication for API access
- Implement network policies in Kubernetes
- Regular security updates of the container image

### 3. Performance Optimization

- Use specific version tags instead of `latest`
- Configure appropriate resource limits
- Use local volumes for better I/O performance
- Monitor container metrics

### 4. Development Workflow

- Use volume mounts for persistent development
- Leverage the integrated VSCode for code editing
- Use Jupyter for interactive development and testing
- Combine browser automation with file operations for comprehensive workflows

## Troubleshooting

### Common Issues and Solutions

#### Container Won't Start
```bash
# Check Docker logs
docker logs <container_id>

# Ensure sufficient resources
docker stats

# Check port availability
netstat -tulpn | grep 8080
```

#### Browser Automation Issues
```bash
# Verify browser is running
curl http://localhost:8080/v1/browser/info

# Check VNC access
# Navigate to http://localhost:8080/vnc
```

#### File Permission Issues
```bash
# Fix ownership in container
docker exec -it <container_id> chown -R gem:gem /home/gem
```

#### MCP Server Connection Issues
```bash
# Check MCP server status
docker exec -it <container_id> ps aux | grep mcp

# Restart MCP servers if needed
docker restart <container_id>
```

## Conclusion

AIO Sandbox provides a comprehensive, unified environment for AI agent development that significantly simplifies the development workflow. By combining browser automation, development tools, file operations, and MCP integration in a single container, it eliminates the complexity of managing multiple separate services.

Key benefits include:

- **Unified Environment**: All tools share the same filesystem and network
- **Easy Setup**: Single Docker command to get started
- **Comprehensive APIs**: Python SDK and REST APIs for all functionality
- **Production Ready**: Kubernetes deployment support and security features
- **Extensible**: MCP integration for custom tool development

Whether you're building simple automation scripts or complex AI agent systems, AIO Sandbox provides the foundation you need for efficient development and deployment.

## Next Steps

1. **Experiment**: Try the examples in this tutorial
2. **Integrate**: Connect AIO Sandbox with your preferred AI framework
3. **Extend**: Develop custom MCP tools for your specific needs
4. **Deploy**: Move to production with Kubernetes or Docker Compose
5. **Contribute**: Join the community and contribute to the project

For more information, visit the [official repository](https://github.com/agent-infra/sandbox) and [documentation](https://sandbox.agent-infra.com).

---

*This tutorial provides a comprehensive introduction to AIO Sandbox. For the latest updates and advanced features, always refer to the official documentation.*
