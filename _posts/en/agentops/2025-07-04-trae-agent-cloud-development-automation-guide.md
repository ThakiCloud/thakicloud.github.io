---
title: "TRAE Agent: Complete Cloud Development Automation Guide - AI-Powered Software Engineering"
excerpt: "A complete guide to TRAE Agent by ByteDance, an AI-powered software engineering agent. In-depth coverage of task planning, file management, shell operations, and automated implementation."
seo_title: "TRAE Agent Complete Guide - AI Software Engineering Agent by ByteDance - Thaki Cloud"
seo_description: "Complete technical guide to TRAE Agent by ByteDance. AI agent for automated software development, task planning, multi-tool integration, and development workflow automation with trajectory recording."
date: 2025-07-04
last_modified_at: 2025-07-04
categories:
  - agentops
tags:
  - trae-agent
  - ByteDance
  - ai-software-engineering
  - development-automation
  - llm-agents
  - trajectory-recording
  - cli-tools
  - code-automation
  - software-engineering
  - agentic-ai
author_profile: true
toc: true
toc_label: "Table of Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/en/agentops/trae-agent-cloud-development-automation-guide/"
lang: en
reading_time: true
---

⏱️ **Estimated reading time**: 12 min

## Introduction

**TRAE Agent** is an AI-powered software engineering agent developed by ByteDance. It automates the entire process of building, modifying, and extending software applications through advanced planning, multi-tool use, and trajectory recording capabilities.

TRAE Agent is built on a philosophy that goes beyond simple code generation: it functions as an intelligent agent that deeply understands development tasks, plans systematically, and executes end to end. It reduces development time, handles repetitive tasks, and lets engineers focus on creative problem solving.

## Core Architecture

TRAE Agent centers on three main components:

### 1. Task Planner

The task planner breaks down complex development tasks into actionable steps:

```python
from trae import TaskPlanner

planner = TaskPlanner(model="claude-3-7-sonnet-latest")

plan = planner.plan(
    task="Build a REST API for user authentication with JWT tokens",
    codebase_context="/path/to/project"
)

for step in plan.steps:
    print(f"Step {step.index}: {step.description}")
    print(f"  Tools: {step.required_tools}")
    print(f"  Files: {step.affected_files}")
```

### 2. Tool Executor

The tool executor provides a rich set of operations:

```python
from trae.tools import (
    FileManager,
    ShellExecutor,
    CodeSearcher,
    WebFetcher
)

# File operations
fm = FileManager(working_dir="/project")
content = fm.read("src/main.py")
fm.write("src/auth.py", new_content)
fm.patch("src/main.py", diff_patch)

# Shell operations
shell = ShellExecutor()
result = shell.run("pytest tests/ -v")
print(result.stdout)

# Code search
searcher = CodeSearcher(codebase="/project")
matches = searcher.find_usages("authenticate_user")
```

### 3. Trajectory Recorder

Every action is recorded for reproducibility and debugging:

```json
{
  "trajectory_id": "traj_2025_07_04_001",
  "task": "Add rate limiting to auth endpoints",
  "steps": [
    {
      "step": 1,
      "tool": "read_file",
      "input": "src/auth/router.py",
      "output": "...",
      "timestamp": "2025-07-04T09:00:01Z"
    },
    {
      "step": 2,
      "tool": "web_search",
      "input": "fastapi rate limiting best practices 2025",
      "output": "...",
      "timestamp": "2025-07-04T09:00:03Z"
    },
    {
      "step": 3,
      "tool": "write_file",
      "input": {
        "path": "src/auth/rate_limit.py",
        "content": "..."
      },
      "timestamp": "2025-07-04T09:00:10Z"
    }
  ]
}
```

## Installation and Setup

```bash
# Install trae-cli
pip install trae-cli

# Or from source
git clone https://github.com/bytedance/trae-agent.git
cd trae-agent
pip install -e .

# Configure API keys
trae config set --provider anthropic --api-key $ANTHROPIC_API_KEY
trae config set --provider openai --api-key $OPENAI_API_KEY

# Verify installation
trae --version
trae config list
```

### Configuration File

```json
{
  "default_provider": "anthropic",
  "default_model": "claude-3-7-sonnet-latest",
  "providers": {
    "anthropic": {
      "api_key": "${ANTHROPIC_API_KEY}",
      "models": ["claude-3-7-sonnet-latest", "claude-3-5-sonnet-20241022"]
    },
    "openai": {
      "api_key": "${OPENAI_API_KEY}",
      "models": ["gpt-4o", "o3-mini"]
    }
  },
  "trajectory": {
    "enabled": true,
    "output_dir": "~/.trae/trajectories",
    "max_size_mb": 100
  },
  "tools": {
    "shell": {
      "allowed_commands": ["git", "npm", "pip", "pytest", "make"],
      "timeout_seconds": 60
    },
    "web": {
      "enabled": true,
      "max_results": 10
    }
  }
}
```

## Basic Usage

### CLI Interface

```bash
# Simple task
trae run "Add input validation to the user registration endpoint"

# With project context
trae run "Refactor the database connection pooling" --project /path/to/project

# Interactive mode
trae chat

# Replay a trajectory
trae replay --trajectory ~/.trae/trajectories/traj_2025_07_04_001.json

# Dry run (plan only, no execution)
trae run "Add caching layer" --dry-run
```

### Python API

```python
from trae import TraeAgent

agent = TraeAgent(
    model="claude-3-7-sonnet-latest",
    project_path="/path/to/project",
    record_trajectory=True
)

# Run a task
result = agent.run(
    task="Implement pagination for the products API endpoint",
    context="We use FastAPI with SQLAlchemy and PostgreSQL"
)

print("Status:", result.status)
print("Files modified:", result.modified_files)
print("Trajectory:", result.trajectory_path)

# Check what changed
for change in result.changes:
    print(f"\n{change.file}:")
    print(change.diff)
```

## Advanced Features

### Custom Tool Integration

```python
from trae.tools import BaseTool
from typing import Any

class DatabaseInspector(BaseTool):
    name = "database_inspector"
    description = "Inspect database schema and query execution plans"
    
    def __init__(self, connection_string: str):
        self.connection_string = connection_string
    
    def get_schema(self, table: str) -> dict:
        """Return column definitions for a table."""
        # Connect and query information_schema
        ...
    
    def explain_query(self, sql: str) -> str:
        """Run EXPLAIN ANALYZE on a query."""
        ...
    
    def execute(self, action: str, **kwargs: Any) -> Any:
        if action == "get_schema":
            return self.get_schema(kwargs["table"])
        elif action == "explain":
            return self.explain_query(kwargs["sql"])
        raise ValueError(f"Unknown action: {action}")

# Register and use
agent = TraeAgent(model="claude-3-7-sonnet-latest")
agent.register_tool(DatabaseInspector("postgresql://localhost/mydb"))

result = agent.run(
    "Optimize the slow queries in the reporting module",
    tools=["database_inspector", "read_file", "write_file"]
)
```

### Multi-Step Workflows

```python
from trae import TraeAgent, Workflow

# Define a multi-step workflow
workflow = Workflow(name="feature-implementation")

workflow.add_step(
    name="research",
    task="Research best practices for implementing {feature}",
    tools=["web_search", "read_file"]
)

workflow.add_step(
    name="plan",
    task="Create an implementation plan based on the research",
    depends_on=["research"],
    tools=["write_file"]
)

workflow.add_step(
    name="implement",
    task="Implement the feature following the plan",
    depends_on=["plan"],
    tools=["read_file", "write_file", "shell"]
)

workflow.add_step(
    name="test",
    task="Write and run tests for the implementation",
    depends_on=["implement"],
    tools=["read_file", "write_file", "shell"]
)

# Execute the workflow
agent = TraeAgent(model="claude-3-7-sonnet-latest", project_path="/project")
results = agent.run_workflow(workflow, variables={"feature": "OAuth2 authentication"})

for step_name, result in results.items():
    print(f"{step_name}: {result.status}")
```

### Trajectory Analysis

```python
from trae.trajectory import TrajectoryAnalyzer

analyzer = TrajectoryAnalyzer()

# Load and analyze a trajectory
traj = analyzer.load("~/.trae/trajectories/traj_001.json")

print("Task:", traj.task)
print("Duration:", traj.duration_seconds, "seconds")
print("Token usage:", traj.total_tokens)
print("Files changed:", len(traj.modified_files))

# Find inefficiencies
issues = analyzer.find_issues(traj)
for issue in issues:
    print(f"Issue at step {issue.step}: {issue.description}")

# Compare two trajectories
traj2 = analyzer.load("~/.trae/trajectories/traj_002.json")
diff = analyzer.compare(traj, traj2)
print("Token reduction:", diff.token_reduction_percent, "%")
```

## Integration with Development Workflows

### GitHub Actions Integration

```yaml
# .github/workflows/trae-review.yml
name: TRAE Code Review

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  ai-review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'

      - name: Install TRAE
        run: pip install trae-cli

      - name: Run AI Review
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          # Get changed files
          git diff origin/main...HEAD --name-only > changed_files.txt
          
          # Run TRAE review
          trae run "Review the code changes in these files for bugs, security issues, and best practices violations" \
            --context-files changed_files.txt \
            --output review.md \
            --model claude-3-7-sonnet-latest

      - name: Post Review Comment
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const review = fs.readFileSync('review.md', 'utf8');
            
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `## AI Code Review\n\n${review}`
            });
```

### Pre-commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

# Run TRAE to check for common issues
echo "Running TRAE pre-commit check..."

trae run "Check the staged changes for obvious bugs, missing error handling, and style violations" \
  --staged-only \
  --fast-mode \
  --exit-on-issues

if [ $? -ne 0 ]; then
  echo "TRAE found issues. Review the output above before committing."
  exit 1
fi

echo "TRAE check passed."
```

### VS Code Extension

```json
// .vscode/settings.json
{
  "trae.enabled": true,
  "trae.model": "claude-3-7-sonnet-latest",
  "trae.autoRecord": true,
  "trae.suggestions": {
    "enabled": true,
    "trigger": "on-save",
    "scope": "current-file"
  },
  "trae.commands": [
    {
      "name": "Fix current file",
      "command": "trae run 'Fix any bugs and improve the code quality of the current file'",
      "keybinding": "ctrl+shift+f"
    },
    {
      "name": "Add tests",
      "command": "trae run 'Write comprehensive unit tests for the current file'",
      "keybinding": "ctrl+shift+t"
    }
  ]
}
```

## Kubernetes Deployment for Team Use

```yaml
# trae-server-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: trae-server
  namespace: dev-tools
spec:
  replicas: 2
  selector:
    matchLabels:
      app: trae-server
  template:
    metadata:
      labels:
        app: trae-server
    spec:
      containers:
      - name: trae-server
        image: your-registry/trae-server:latest
        ports:
        - containerPort: 8080
        env:
        - name: ANTHROPIC_API_KEY
          valueFrom:
            secretKeyRef:
              name: ai-secrets
              key: anthropic-key
        - name: OPENAI_API_KEY
          valueFrom:
            secretKeyRef:
              name: ai-secrets
              key: openai-key
        - name: TRAE_TRAJECTORY_DIR
          value: "/data/trajectories"
        resources:
          requests:
            memory: "1Gi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "1000m"
        volumeMounts:
        - name: trajectory-storage
          mountPath: /data/trajectories
      volumes:
      - name: trajectory-storage
        persistentVolumeClaim:
          claimName: trae-trajectories-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: trae-service
  namespace: dev-tools
spec:
  selector:
    app: trae-server
  ports:
  - port: 80
    targetPort: 8080
  type: ClusterIP
```

## Performance and Cost Optimization

### Token Budget Management

```python
from trae import TraeAgent, TokenBudget

# Set a strict token budget
budget = TokenBudget(
    max_input_tokens=50_000,
    max_output_tokens=10_000,
    warn_at_percent=80
)

agent = TraeAgent(
    model="claude-3-7-sonnet-latest",
    token_budget=budget
)

# Budget-aware task execution
result = agent.run(
    task="Refactor the authentication module",
    budget_strategy="conservative"  # Summarize context aggressively
)

print("Tokens used:", result.token_usage)
print("Estimated cost:", result.estimated_cost_usd)
```

### Caching Strategies

```python
from trae import TraeAgent
from trae.cache import FileSystemCache, RedisCache

# Cache file reads and web searches
cache = RedisCache(
    host="localhost",
    port=6379,
    ttl_seconds=3600
)

agent = TraeAgent(
    model="claude-3-7-sonnet-latest",
    tool_cache=cache
)

# First run: all tools execute normally
result1 = agent.run("Analyze dependencies in package.json")

# Second run with same context: cached tool calls reused
result2 = agent.run("List outdated packages in package.json")
print("Cache hit rate:", result2.cache_hit_rate)
```

## Security Considerations

### Sandboxed Execution

```python
from trae import TraeAgent
from trae.sandbox import DockerSandbox

# Run agent in an isolated Docker container
sandbox = DockerSandbox(
    image="python:3.12-slim",
    memory_limit="2g",
    cpu_limit=1.0,
    network="none",  # No network access from sandbox
    readonly_paths=["/project/src"],
    writable_paths=["/project/tests", "/tmp"]
)

agent = TraeAgent(
    model="claude-3-7-sonnet-latest",
    sandbox=sandbox
)

result = agent.run("Run the test suite and fix any failures")
```

### Command Allowlist

```python
from trae import TraeAgent
from trae.security import ShellPolicy

# Restrict which commands the agent can run
policy = ShellPolicy(
    allowed_commands=["pytest", "python", "pip", "git status", "git diff"],
    blocked_patterns=["rm -rf", "sudo", "curl", "wget", "ssh"],
    require_confirmation=["git commit", "git push"]
)

agent = TraeAgent(
    model="claude-3-7-sonnet-latest",
    shell_policy=policy
)
```

## Real-World Example: Building a Feature End to End

```bash
# Scenario: Add async task processing to a FastAPI app

trae run \
  "Add a background task processing system using Celery and Redis. 
   Requirements:
   - Task queue for email sending and report generation
   - Task status tracking endpoint
   - Retry logic with exponential backoff
   - Dead letter queue for failed tasks
   - Monitoring dashboard endpoint" \
  --project /path/to/fastapi-app \
  --model claude-3-7-sonnet-latest \
  --record-trajectory \
  --output-report implementation-summary.md
```

TRAE will:
1. Analyze the existing codebase structure
2. Research Celery integration patterns for FastAPI
3. Create the task configuration files
4. Implement worker definitions with retry logic
5. Add the status tracking endpoint
6. Write unit and integration tests
7. Update the requirements file
8. Generate a summary of all changes

## Conclusion

TRAE Agent represents a meaningful step forward in AI-assisted software engineering. Its combination of systematic task planning, rich tool access, and trajectory recording makes it a practical tool for automating real development workflows rather than just generating code snippets.

Key strengths:
- **End-to-end automation**: Plans and executes complete features, not just isolated code blocks
- **Trajectory recording**: Every action is logged for review and reproducibility
- **Flexible tool integration**: Extend with custom tools for any codebase
- **Team-friendly**: Server mode and CI/CD integrations support collaborative workflows
- **Security-aware**: Sandboxing and command allowlists for safe execution

TRAE Agent is best suited for well-defined feature additions, refactoring tasks, test generation, and code review automation. For exploratory research or tasks requiring significant judgment calls, human review of the trajectory remains essential.

---

**References**:
- [TRAE Agent GitHub](https://github.com/bytedance/trae-agent)
- [ByteDance AI Research](https://ai.bytedance.com)
- [Trajectory Recording Design](https://github.com/bytedance/trae-agent/docs/trajectory.md)
