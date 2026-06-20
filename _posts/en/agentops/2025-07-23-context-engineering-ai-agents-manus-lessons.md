---
title: "Context Engineering for AI Agents: Practical Lessons from Building Manus"
excerpt: "A detailed analysis of the context optimization strategies and core principles for production AI agents, drawn from the Manus AI team's experience rebuilding their framework four times."
seo_title: "AI Agent Context Engineering Practical Guide - Manus Case Study - Thaki Cloud"
seo_description: "Learn proven context engineering strategies from the Manus build experience: KV-cache optimization, dynamic tool management, file system utilization, and more for AI agent development."
date: 2025-07-23
last_modified_at: 2025-07-23
lang: en
categories:
  - agentops
  - llmops
tags:
  - AI에이전트
  - 컨텍스트엔지니어링
  - LLM최적화
  - KV캐시
  - 프로덕션AI
  - Manus
  - 도구관리
  - 에이전트프레임워크
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/en/agentops/context-engineering-ai-agents-manus-lessons/"
reading_time: true
---

⏱️ **Estimated reading time**: 12 min

## Introduction

One of the hardest choices in AI agent development is deciding between model training and context engineering. Through the hands-on experience shared by Yichao 'Peak' Ji of the Manus AI team, we can explore context optimization strategies validated in production environments.

Having witnessed the shift from the BERT era to GPT-3, the Manus team arrived at their current optimization strategy through an empirical approach they call "Stochastic Graduate Descent," rebuilding their framework four times in the process.

## KV-Cache-Centric Design: The Key Metric for Production Agents

### Why Does KV-Cache Hit Rate Matter?

For a production-stage AI agent, the KV-cache hit rate is the most important performance metric, because it directly affects latency and cost.

A typical agent task flow:
1. Receive user input
2. Select an action based on current context
3. Execute the action in the environment and generate an observation
4. Add the action-observation pair to the context
5. Repeat until the task is complete

**Manus real-world data**: Average input-to-output token ratio of 100:1

### Real Impact on Cost Optimization

Cost comparison using Claude Sonnet as reference:
- Cached input tokens: $0.30/MTok
- Uncached tokens: $3.00/MTok
- **10x cost difference**

### KV-Cache Optimization Strategies

#### 1. Prompt Prefix Stabilization

```python
# Invalidates the cache
system_prompt = f"""
Current time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
You are an AI agent...
"""

# Cache-friendly pattern
system_prompt = """
You are an AI agent...
Current task: {task_description}
"""
```

#### 2. Append-Only Context Design

```python
class AgentContext:
    def __init__(self):
        self.actions = []
        self.observations = []
    
    def add_step(self, action, observation):
        # Append only, no modification
        self.actions.append(action)
        self.observations.append(observation)
    
    def serialize(self):
        # Guarantee deterministic serialization
        return json.dumps({
            'actions': self.actions,
            'observations': self.observations
        }, sort_keys=True)
```

#### 3. Explicit Cache Breakpoint Management

```python
def create_cache_breakpoints(context):
    breakpoints = [
        'system_prompt_end',
        'tools_definition_end',
        'conversation_start'
    ]
    
    for bp in breakpoints:
        context.add_cache_marker(bp)
```

## Dynamic Tool Management: Masking vs. Removal

### The Tool Explosion Problem

With the adoption of MCP (Model Context Protocol), the number of tools is growing exponentially. Adding tools indiscriminately degrades the agent's decision-making quality.

### Manus's Solution: Context-Aware State Machine

Reasons to mask tools rather than remove them:

1. **KV-cache preservation**: Tool definitions sit at the front of the context, so changing them invalidates the entire cache
2. **Reference integrity**: If a tool referenced by a previous action disappears, it causes model confusion

### Function Call Control Implementation

```python
class FunctionCallController:
    def __init__(self):
        self.call_modes = {
            'auto': '<|im_start|>assistant',
            'required': '<|im_start|>assistant<tool_call>',
            'specified': '<|im_start|>assistant<tool_call>{"name": "browser_'
        }
    
    def constrain_tools(self, context, allowed_prefixes):
        """Allow only tools with specific prefixes"""
        # Control via token logit masking
        pass
```

### Tool Naming Conventions

```python
# Use consistent prefixes
BROWSER_TOOLS = [
    'browser_navigate',
    'browser_click',
    'browser_extract'
]

SHELL_TOOLS = [
    'shell_execute',
    'shell_cd',
    'shell_env'
]
```

## Using the File System as Context

### Context Window Limitations

Despite modern LLMs offering 128K+ token windows, real-world agent scenarios face these problems:

1. **Massive observation data**: Unstructured data such as web pages and PDFs
2. **Performance degradation**: Model performance decline in long contexts
3. **High cost**: Token costs remain high even with prefix caching

### Manus's File System Approach

```python
class FileSystemContext:
    def __init__(self, sandbox_path):
        self.sandbox_path = sandbox_path
        self.context_files = {}
    
    def store_observation(self, content, context_type):
        """Store large observations as files"""
        file_path = f"{self.sandbox_path}/observations/{uuid4()}.{context_type}"
        with open(file_path, 'w') as f:
            f.write(content)
        
        return {
            'type': 'file_reference',
            'path': file_path,
            'summary': self.generate_summary(content)
        }
    
    def restore_observation(self, file_ref):
        """Restore content from file when needed"""
        with open(file_ref['path'], 'r') as f:
            return f.read()
```

### Recoverable Compression Strategy

```python
def compress_context(self, context):
    """Compression without information loss"""
    compressed = []
    
    for item in context:
        if item['type'] == 'web_page':
            # Preserve URL for recovery
            compressed.append({
                'type': 'web_page_ref',
                'url': item['url'],
                'summary': item['summary']
            })
        elif item['type'] == 'document':
            # Preserve file path
            compressed.append({
                'type': 'document_ref',
                'path': item['path'],
                'key_points': item['key_points']
            })
    
    return compressed
```

## Maintaining Goals via Attention Manipulation

### Todo List-Based Attention Control

Why Manus creates and updates a `todo.md` file for complex tasks:

1. **Goal re-confirmation**: Repeatedly place goals at the end of the context
2. **Solving the lost-in-the-middle problem**: Prevent forgetting of critical information in long contexts
3. **Natural language-based attention bias**: Implemented without special architectural changes

### Concrete Implementation Example

```markdown
# todo.md example

## Current Task: Website Performance Optimization

### Completed
- [x] Measure current page load time
- [x] Analyze image file sizes
- [x] Check CSS/JS file compression status

### In Progress
- [ ] Implement caching strategy
- [ ] Apply image optimization

### Next Steps
- [ ] Run performance tests
- [ ] Write results report
```

### Average Task Complexity

**Manus real-world data**: Average of 50 tool calls required per task

## Error Utilization Strategy: Learn From Failures Instead of Hiding Them

### The Trap of Removing Failures

Common error handling approaches:
- Remove failed actions
- Reset state and retry
- Add randomness by adjusting "temperature"

### Manus's Error Utilization Strategy

```python
class ErrorLearningContext:
    def handle_failed_action(self, action, error):
        """Keep failed actions in context"""
        error_context = {
            'action': action,
            'error': error,
            'timestamp': datetime.now(),
            'learning_signal': True
        }
        
        # Keep failure information in context
        self.context.append(error_context)
        
        # Reduce the probability of the model repeating similar mistakes
        self.update_action_priors(action, negative_signal=True)
```

### The Importance of Error Recovery

Error recovery is a core indicator of truly agentic behavior. Most academic research and benchmarks today focus only on success under ideal conditions, failing to reflect the complexity of real production environments.

## Avoiding the Few-Shot Prompting Trap

### The Risk of Pattern Imitation

The language model's strong imitation ability can actually become a problem in agent systems:

```python
# Problematic uniform pattern
context_examples = [
    "Action: analyze file, Observation: 20 items found",
    "Action: analyze file, Observation: 15 items found",
    "Action: analyze file, Observation: 25 items found"
]
# The model ends up always choosing "analyze file"
```

### Manus's Diversity-Promoting Strategy

```python
class ContextDiversifier:
    def add_structural_variation(self, action, observation):
        """Introduce structural variation"""
        templates = [
            "Executed: {action} -> Result: {observation}",
            "Action: {action}\nObservation: {observation}",
            "{action} completed. {observation}"
        ]
        
        template = random.choice(templates)
        return template.format(action=action, observation=observation)
    
    def add_semantic_noise(self, text):
        """Diversify expression while preserving meaning"""
        synonyms = {
            'analyze': ['review', 'inspect', 'check'],
            'execute': ['perform', 'run', 'process']
        }
        # Random synonym substitution
        return self.apply_synonyms(text, synonyms)
```

## Practical Application Guide

### Development Phase Checklist

#### 1. Design Phase
- [ ] Design a KV-cache-friendly prompt structure
- [ ] Define tool naming conventions (consistent prefixes)
- [ ] Plan a file system-based memory architecture

#### 2. Implementation Phase
- [ ] Implement an append-only context structure
- [ ] Implement tool control via token logit masking
- [ ] Implement a recoverable compression strategy

#### 3. Optimization Phase
- [ ] Monitor KV-cache hit rate
- [ ] Introduce context diversity mechanisms
- [ ] Build an error learning system

### Performance Monitoring Metrics

```python
class AgentMetrics:
    def __init__(self):
        self.metrics = {
            'kv_cache_hit_rate': 0.0,
            'avg_context_length': 0,
            'error_recovery_rate': 0.0,
            'task_completion_rate': 0.0,
            'cost_per_interaction': 0.0
        }
    
    def calculate_efficiency_score(self):
        """Calculate a composite efficiency score"""
        weights = {
            'kv_cache_hit_rate': 0.3,
            'error_recovery_rate': 0.25,
            'task_completion_rate': 0.25,
            'cost_efficiency': 0.2
        }
        
        return sum(self.metrics[k] * weights[k] for k in weights)
```

## Future Outlook: State Space Models and Agents

### The Potential of SSMs

An interesting perspective presented by the Manus team: if State Space Models (SSMs) master file-based memory, it may be possible to build efficient agents without Transformer's full attention.

Potential advantages of SSM-based agents:
- **Speed**: Faster inference than Transformers
- **Efficiency**: Optimized memory usage
- **Scalability**: Ability to handle long sequences

This suggests the potential to be the true successor to the Neural Turing Machine.

## Conclusion

The lessons from the Manus team's four framework rebuilds are clear: context engineering is central to AI agent development and requires a systematic approach.

### Summary of Core Principles

1. **KV-cache first**: Optimizing hit rate directly impacts performance and cost
2. **Masking over removal**: Ensures stability in tool management
3. **File system utilization**: External memory for unlimited context
4. **Learn from failures**: Use errors as learning signals rather than hiding them
5. **Maintain diversity**: Structural variation to avoid pattern traps

### Advice for Practitioners

If you are an AI agent development team, use these questions to audit your current system:

- Are you measuring KV-cache hit rate?
- Does adding a tool invalidate the entire cache?
- How are you handling failed actions?
- Is your context too uniform?

Context engineering is still a developing field. But based on principles validated in real production environments like Manus, you can build more efficient and robust AI agents.

The future of agents will be built on carefully designed context. Start now.

---

**References**:
- [Manus AI original blog](https://manus.im/blog/Context-Engineering-for-AI-Agents-Lessons-from-Building-Manus)
- Research on KV-Cache optimization
- MCP (Model Context Protocol) documentation
