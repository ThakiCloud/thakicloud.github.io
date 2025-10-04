---
title: "Pepper: Building a Proactive AI Assistant with Real-Time Event-Driven Architecture"
excerpt: "A comprehensive guide to setting up and using Pepper, an open-source personal AI assistant that proactively manages your Gmail, summarizes important emails, and autonomously handles tasks in the background using event-driven architecture."
seo_title: "Pepper AI Assistant Tutorial: Real-Time Event-Driven Personal Assistant - Thaki Cloud"
seo_description: "Learn how to set up Pepper, a proactive AI assistant from Berkeley Sky Computing Lab. Complete guide covering installation, Gmail integration, and event-driven architecture with Feeds, Scheduler, and Workers."
date: 2025-10-04
categories:
  - tutorials
tags:
  - AI-Assistant
  - Event-Driven-Architecture
  - Gmail-Integration
  - Agentic-Systems
  - OpenAI
  - Python
author_profile: true
toc: true
toc_label: "Table of Contents"
lang: en
permalink: /en/tutorials/pepper-proactive-ai-assistant-tutorial/
canonical_url: "https://thakicloud.github.io/en/tutorials/pepper-proactive-ai-assistant-tutorial/"
---

⏱️ **Estimated Reading Time**: 12 minutes

## Introduction

**Pepper** is revolutionizing how we interact with AI assistants. Unlike traditional chatbots that passively wait for your commands, Pepper **proactively works for you** in the background—continuously monitoring your Gmail, summarizing important emails, surfacing critical updates, and autonomously handling complex tasks through a swarm of specialized workers.

Developed by the **Agentica team** at **Berkeley Sky Computing Lab**, Pepper represents a fundamental shift from reactive, request-driven systems to real-time, event-driven architectures. This tutorial will guide you through setting up your own Pepper instance and understanding its powerful architecture.

### What Makes Pepper Different?

**Traditional Chatbots:**
- Wait for user prompts
- Static and reactive
- Conversation ends when you stop asking

**Pepper (Next-Gen Proactive Assistant):**
- Runs continuously in the background
- Dynamic and proactive
- Keeps working even when you're not actively engaged
- Handles parallel tasks autonomously
- Provides context before you even ask

### Key Features

✅ **Gmail Integration**: Automatically monitors and summarizes emails  
✅ **Proactive Notifications**: Surfaces critical updates that need attention  
✅ **Task Delegation**: Assigns complex tasks to specialized worker agents  
✅ **Event-Driven Architecture**: Continuous Sense-Think-Act loop  
✅ **Real-Time Context**: Maintains conversation history and user memory  
✅ **Non-Blocking Design**: Responds immediately while processing in background

## Prerequisites

Before starting, ensure you have:

- **Operating System**: macOS, Linux, or Windows with WSL
- **Python**: Version 3.12 or higher
- **Conda**: Anaconda or Miniconda installed
- **Gmail Account**: For email integration
- **API Keys**:
  - OpenAI API key (required)
  - Composio API key (required for tool integrations)

## Installation Guide

### Step 1: Clone the Repository

First, clone the Pepper repository with its submodules:

```bash
git clone --recurse-submodules https://github.com/agentica-org/pepper
cd pepper
```

### Step 2: Set Up Python Environment

Create and activate a dedicated Conda environment:

```bash
# Create new environment with Python 3.12
conda create -n pepper python=3.12 pip -y
conda activate pepper
```

### Step 3: Install Episodic Context Store

Pepper relies on **Episodic**, a context store that serves as the real-time data backbone:

```bash
# Install Episodic SDK with semantic search support
cd episodic-sdk
pip install -e .[semantic]
```

### Step 4: Install Pepper Dependencies

Navigate to the Pepper directory and install requirements:

```bash
cd ../pepper
pip install -r requirements.txt
```

### Step 5: Start the Context Store

Launch the Episodic context store server:

```bash
episodic serve --port 8000
```

**Important**: Keep this process running in the terminal. Open a new terminal window for the next steps.

## Configuration

### Step 1: Set Up Environment Variables

Copy the example environment file:

```bash
cd pepper
cp env_var.example.sh env_var.sh
```

### Step 2: Configure API Keys

Edit `env_var.sh` with your favorite text editor:

```bash
# Required: OpenAI API Key
export OPENAI_API_KEY="sk-your-openai-api-key-here"

# Required: Composio API Key (for Gmail and tool integrations)
export COMPOSIO_API_KEY="your-composio-api-key-here"

# Optional: Additional configurations
export EPISODIC_HOST="http://localhost:8000"
```

**Getting Your API Keys:**

1. **OpenAI API Key**:
   - Visit [platform.openai.com](https://platform.openai.com)
   - Navigate to API Keys section
   - Create a new secret key

2. **Composio API Key**:
   - Sign in at [composio.dev](https://composio.dev)
   - Create a new Project
   - Generate an API key

### Step 3: Load Environment Variables

```bash
source env_var.sh
```

### Step 4: Authorize Gmail Access

Run the email service setup (first-time only):

```bash
python -m pepper.services.email_service
```

**What to Expect:**
1. You'll see: `"Please authorize Gmail by visiting: [URL]"`
2. Open the URL in your browser
3. Grant Gmail access permissions
4. Wait for: `"✅ Trigger subscribed successfully."`
5. Press `Ctrl+C` to stop the process

## Running Pepper

### Launch Pepper

Start Pepper with a single command:

```bash
python -m pepper.launch_pepper
```

**First-Time Setup Note**: The initial launch takes approximately 1 minute to build your user profile.

### Access the Web UI

Once Pepper is running, open your browser and navigate to:

```
http://localhost:5050/pepper/ui.html
```

**Remote Server Users**: VS Code should automatically port-forward to your local machine.

### Stopping Pepper

To stop all Pepper services:

```bash
# Press Ctrl+C in the terminal
```

## Understanding Pepper's Architecture

Pepper's power comes from its **real-time, event-driven architecture** built around a continuous **Sense-Think-Act** loop.

### Core Components

#### 1. **Feeds (Sense)**

**Purpose**: System's sensory input layer

Feeds are intelligent pipelines that:
- Monitor external sources (emails, messages, calendars)
- Filter out noise
- Transform raw data into actionable textual signals
- Maintain high signal-to-noise ratio

**Example**: When a new email arrives, the Email Feed:
1. Checks for keywords and sender importance
2. Determines urgency level
3. Distills the email into a concise signal:

```json
{
  "id": "evt_a1b2c3d4-e5f6-a7b8-c9d0-e1f2a3b4c5d6",
  "content": "Action requested by Alice on 'Project Phoenix', due tomorrow.",
  "created_at": "2025-10-04T16:46:15Z"
}
```

#### 2. **Scheduler (Think)**

**Purpose**: Central brain and orchestrator

The Scheduler:
- Maintains a prioritized FIFO event queue
- Consumes signals from Feeds
- Enriches events with context (conversation history, user memory)
- Decides which actions to take
- Operates in non-blocking mode for instant responsiveness

**Key Innovation: Asynchronous Tool Calls**

Traditional LLM APIs enforce synchronous tool calls—the conversation must halt until a tool returns. Pepper solves this by:
- Appending tool invocations to conversation history
- Continuing to process new events immediately
- Handling tool results asynchronously when they arrive

**Before (Synchronous - BLOCKED):**
```javascript
{% raw %}
{
  "role": "assistant",
  "content": "Starting analysis...",
  "tool_calls": [{"id": "tool_1", "function": "run_analysis"}]
},
// Must wait for tool result before accepting new user input
{
  "role": "user",
  "content": "Can you add a filter?"  // ILLEGAL without tool result
}
{% endraw %}
```

**After (Asynchronous - CONTINUES):**
```xml
<tool_call>
  id: tool_call_1
  function: run_analysis
</tool_call>

<user_msg>Can you add a filter for last quarter?</user_msg>

<assistant_msg>Sure. I'll add that filter to the analysis.</assistant_msg>

<tool_result>
  id: tool_call_1
  result: {% raw %}{{ "initial_analysis_complete": true }}{% endraw %}
</tool_result>
```

#### 3. **Workers (Act)**

**Purpose**: Specialized execution agents

Workers are equipped with tools via MCP (Model Context Protocol) to:
- Send emails
- Manage calendar events
- Search for information
- Set reminders
- Execute complex, long-running tasks

**Two Types of Workers:**

**Stateful Workers**: For long-running tasks
- Maintain memory across interactions
- Ideal for managing email threads or task lists
- State persisted in Context Store

**Stateless Workers**: For one-off jobs
- Ephemeral and efficient
- Perfect for quick lookups or single-use tasks
- Return final answer and terminate

#### 4. **Context Store**

**Purpose**: Real-time data serving layer

The Context Store is Pepper's backbone, similar to feature stores in ML systems but designed for multi-agent orchestration:

- **State Management**: Agents persist and share state
- **Real-Time Serving**: Immediate access to fresh data
- **Event Orchestration**: Updates trigger downstream actions

**Core API:**
- `store()`: Save events to namespaces
- `retrieve()`: Query stored contexts
- `subscribe()`: Listen for updates

## System Flow Example

Let's walk through how Pepper processes an important email:

### Step 1: Email Arrives (Feed - Sense)

```python
# Gmail webhook triggers
@app.on_event("new_email")
async def ingest_raw_event(data: dict):
    await context_store.store(
        context_id=data.get("id", None) or uuid.uuid(),
        data=data,
        namespace="raw.email"
    )
```

### Step 2: Feed Processes Signal

```python
# Email Feed subscribes to raw emails
@subscriber.on_context_update(namespaces=["raw.email"])
async def email_feed(update: ContextUpdate):
    # Find related context using semantic search
    related_docs = await context_store.search(text=update.context.text)
    processed_signal = process_email_signal(update.context, related_docs)
    
    # Emit processed signal
    await context_store.store(
        context_id="processed_" + update.context.context_id,
        data=processed_signal,
        namespace="signals.processed"
    )
```

### Step 3: Scheduler Reacts (Scheduler - Think)

```python
# Scheduler adds signal to priority queue
@subscriber.on_context_update(namespaces=["signals.*"])
async def add_to_queue(self, update: ContextUpdate):
    priority = determine_priority(update.context.data)
    await self.priority_queue.put((priority, update))

# Scheduler continuously processes queue
async def scheduler_step(self):
    events = await self.get_batch_events()
    self.state_tracker.add_events(events)
    
    messages = [
        {"role": "system", "content": SCHEDULER_SYSTEM_PROMPT},
        {"role": "user", "content": self.state_tracker.get_user_prompt()},
    ]
    
    response = await create_completion(messages, self.tools)
    self.state_tracker.add_event(response)
    
    # Schedule tool calls for background execution
    if response.tool_calls:
        for tool_call in response.tool_calls:
            self.tool_call_engine.schedule(tool_call)
```

### Step 4: Worker Executes Action (Worker - Act)

```python
# Worker sends notification to user
await worker.execute_tool("send_notification", {
    "message": "Urgent email from Alice about Project Phoenix - deadline tomorrow",
    "priority": "high"
})
```

## Practical Use Cases

### 1. Email Management

**Scenario**: You receive 50+ emails daily, many unimportant.

**How Pepper Helps**:
- Continuously monitors Gmail
- Filters based on sender importance and keywords
- Summarizes only critical emails
- Surfaces action items with deadlines
- Notifies you proactively

### 2. Meeting Preparation

**Scenario**: You have a meeting in 2 hours.

**How Pepper Helps**:
- Detects meeting from calendar
- Searches related emails and documents
- Prepares briefing document
- Surfaces key discussion points
- Alerts you 30 minutes before

### 3. Task Delegation

**Scenario**: You need to analyze a large dataset.

**How Pepper Helps**:
- Accepts task description
- Delegates to specialized Data Worker
- Worker runs analysis in background
- You continue other conversations
- Receives proactive update when complete

### 4. Follow-up Management

**Scenario**: You're waiting for responses from multiple people.

**How Pepper Helps**:
- Tracks pending follow-ups
- Monitors incoming emails
- Matches responses to original requests
- Notifies you when all responses received
- Summarizes findings

## Advanced Configuration

### Customizing Feeds

Create custom feeds for different data sources:

```python
# Custom Slack Feed Example
@subscriber.on_context_update(namespaces=["raw.slack"])
async def slack_feed(update: ContextUpdate):
    message = update.context.data
    
    # Filter for urgent mentions
    if "@urgent" in message["text"] or message["user"] in IMPORTANT_USERS:
        processed_signal = {
            "content": f"Urgent Slack message from {message['user']}: {message['text']}",
            "priority": "high",
            "source": "slack"
        }
        
        await context_store.store(
            data=processed_signal,
            namespace="signals.processed"
        )
```

### Adjusting Scheduler Priority

Modify event priorities in the Scheduler:

```python
def determine_priority(event_data):
    """Custom priority logic"""
    if "urgent" in event_data.get("content", "").lower():
        return 1  # Highest priority
    elif event_data.get("source") == "email":
        return 2
    elif event_data.get("source") == "calendar":
        return 3
    else:
        return 4  # Lowest priority
```

### Creating Custom Workers

Build specialized workers for specific tasks:

```python
class DataAnalysisWorker(StatefulWorker):
    """Worker specialized in data analysis tasks"""
    
    def __init__(self):
        super().__init__()
        self.tools = [
            "run_sql_query",
            "generate_visualization",
            "calculate_statistics"
        ]
    
    async def execute_task(self, task_description):
        # Load previous state if exists
        state = await self.load_state()
        
        # Perform analysis
        result = await self.run_analysis(task_description)
        
        # Save state
        await self.save_state(result)
        
        # Return to scheduler
        return result
```

## Troubleshooting

### Common Issues

#### 1. Gmail Authorization Fails

**Problem**: Cannot authorize Gmail access

**Solution**:
```bash
# Clear existing credentials
rm -rf ~/.credentials/pepper/

# Re-run authorization
python -m pepper.services.email_service
```

#### 2. Episodic Server Not Running

**Problem**: `Connection refused to localhost:8000`

**Solution**:
```bash
# Check if episodic is running
ps aux | grep episodic

# If not running, start it
conda activate pepper
episodic serve --port 8000
```

#### 3. Missing API Keys

**Problem**: `API key not found` errors

**Solution**:
```bash
# Verify environment variables are loaded
echo $OPENAI_API_KEY
echo $COMPOSIO_API_KEY

# If empty, reload environment
source env_var.sh
```

#### 4. First Launch Takes Too Long

**Problem**: Initial profile building exceeds 2 minutes

**Solution**:
- This is normal for first-time setup
- Check system resources (CPU, memory)
- Ensure stable internet connection
- Wait patiently—subsequent launches are faster

## Best Practices

### 1. Email Management

- **Configure Filters**: Set up email filters in Gmail to reduce noise
- **Important Contacts**: Mark critical senders as VIP
- **Review Summaries**: Check Pepper's summaries daily
- **Adjust Priorities**: Fine-tune what counts as "important"

### 2. Context Management

- **Regular Cleanup**: Periodically clear old context data
- **Namespace Organization**: Use clear namespace conventions
- **State Versioning**: Version agent states for rollback capability

### 3. Worker Optimization

- **Task Granularity**: Break large tasks into smaller chunks
- **Timeout Settings**: Set reasonable timeouts for long-running tasks
- **Error Handling**: Implement robust error recovery in workers

### 4. Security

- **API Key Rotation**: Regularly rotate API keys
- **Access Control**: Limit Gmail scope to read-only when possible
- **Audit Logs**: Monitor Pepper's actions regularly
- **Data Privacy**: Be mindful of sensitive information in emails

## Performance Optimization

### 1. Scheduler Tuning

```python
# Adjust batch size for event processing
SCHEDULER_BATCH_SIZE = 5  # Process 5 events per cycle

# Set max queue size
MAX_QUEUE_SIZE = 100  # Prevent memory issues
```

### 2. Context Store Optimization

```bash
# Enable semantic search caching
export EPISODIC_CACHE_ENABLED=true
export EPISODIC_CACHE_TTL=3600  # 1 hour
```

### 3. Worker Pool Management

```python
# Configure worker pool size
MAX_CONCURRENT_WORKERS = 10
WORKER_TIMEOUT = 300  # 5 minutes
```

## Comparison with Traditional Assistants

| Feature | Traditional Chatbot | Pepper |
|---------|-------------------|--------|
| **Interaction Model** | Reactive (wait for prompt) | Proactive (continuous monitoring) |
| **Task Handling** | Sequential | Parallel |
| **Context Awareness** | Limited to conversation | Full context from multiple sources |
| **Response Time** | Immediate but limited | Background processing + instant notifications |
| **Tool Execution** | Synchronous (blocking) | Asynchronous (non-blocking) |
| **Memory** | Session-based | Persistent across sessions |
| **Scalability** | Single conversation | Multiple parallel tasks |

## Future Enhancements

Pepper's architecture enables exciting future capabilities:

### 1. Predictive Feeds

Feeds that anticipate needs before events occur:
- Schedule meeting prep _before_ calendar invite accepted
- Prepare travel documents as soon as flight booked
- Draft responses to common email patterns

### 2. Multi-User Coordination

Teams working with shared Pepper instances:
- Collaborative task management
- Shared context and knowledge base
- Team-wide notifications and summaries

### 3. Advanced Learning

Pepper learning from your behavior:
- Personalized priority settings
- Custom automation rules
- Behavioral pattern recognition

## Resources

### Official Links

- **GitHub Repository**: [github.com/agentica-org/pepper](https://github.com/agentica-org/pepper)
- **Blog Post**: [Pepper Architecture Deep Dive](https://agentica-project.com/post.html?post=pepper.md)
- **Agentica Project**: [agentica-project.com](https://agentica-project.com)
- **Berkeley Sky Computing Lab**: Research lab backing the project

### Related Technologies

- **Episodic SDK**: [github.com/agentica-org/episodic-sdk](https://github.com/agentica-org/episodic-sdk)
- **Composio**: [composio.dev](https://composio.dev)
- **OpenAI API**: [platform.openai.com](https://platform.openai.com)

### Further Reading

1. [Event-Driven Architecture in Distributed Systems](https://miladezzat.medium.com/event-driven-architecture-how-to-implement-in-distributed-systems-29bd82b02ace)
2. [ChatGPT Pulse: Next-Gen Proactive AI](https://openai.com/index/introducing-chatgpt-pulse/)
3. [Uber's Michelangelo ML Platform](https://www.uber.com/blog/michelangelo-machine-learning-platform/)

## Conclusion

Pepper represents a paradigm shift in AI assistant technology—from passive responders to proactive partners. By leveraging event-driven architecture with its Sense-Think-Act loop, Pepper continuously works for you, handling complex tasks in the background while keeping you informed of what truly matters.

The open-source nature of Pepper, combined with its modular architecture, makes it an ideal platform for experimenting with next-generation agentic systems. Whether you're looking to automate email management, build custom workflows, or explore real-time AI orchestration, Pepper provides a solid foundation.

**Key Takeaways:**

✅ Pepper transforms AI assistance from reactive to proactive  
✅ Event-driven architecture enables parallel, non-blocking task execution  
✅ Modular design (Feeds, Scheduler, Workers, Context Store) allows easy customization  
✅ Gmail integration provides immediate practical value  
✅ Open-source and actively developed by Berkeley's Agentica team

## Acknowledgments

Pepper is developed by the **Agentica Team** as part of **Berkeley Sky Computing Lab**, supported by **Laude Institute** with compute grants from **AWS** and **Hyperbolic**.

---

**Have questions or feedback?** Feel free to contribute to the project on GitHub or join the community discussions!

🔗 **GitHub**: [github.com/agentica-org/pepper](https://github.com/agentica-org/pepper)  
📧 **Contact**: Check the repository for community channels

**Next Steps:**
- Set up your Pepper instance following this guide
- Explore the codebase and customize feeds
- Build your own workers for specific tasks
- Share your experience with the community!

Happy building! 🚀

