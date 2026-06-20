---
title: "OpenPipe ART: Complete Guide to the Practical Agent Reinforcement Training Framework"
excerpt: "From multi-step agent training with GRPO to real-world task application. Building production-ready AI agents with Qwen, Llama, and Kimi models"
seo_title: "OpenPipe ART Reinforcement Learning Agent Guide - GRPO Multi-Step Training - Thaki Cloud"
seo_description: "Train real-world AI agents with OpenPipe ART. Complete guide covering GRPO algorithm, multi-step training, RULER reward functions, and vLLM integration"
date: 2025-07-19
last_modified_at: 2025-07-19
categories:
  - llmops
tags:
  - OpenPipe
  - ART
  - 강화학습
  - GRPO
  - 에이전트
  - 멀티스텝
  - Qwen
  - Llama
  - vLLM
  - RULER
  - 실무AI
author_profile: true
toc: true
toc_label: "Table of Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/en/llmops/openpipe-art-agent-reinforcement-trainer-guide/"
reading_time: true
lang: en
---

⏱️ **Estimated reading time**: 30 min

## Introduction

**OpenPipe ART (Agent Reinforcement Trainer)** is an innovative reinforcement learning framework for training multi-step AI agents in real-world work environments. Using the **GRPO (Group Relative Policy Optimization)** algorithm, it enables development of production-ready agents with a wide variety of language models including Qwen2.5, Qwen3, Llama, and Kimi.

### Core Features of ART

- 🚀 **GRPO Algorithm**: Stable multi-step learning via group relative policy optimization
- 🎯 **Production-Focused**: Training on real tasks such as email search, games, and coding
- 🔧 **RULER Integration**: Automated evaluation system without manual reward function engineering
- 🌐 **Client-Server**: Scalable architecture for distributed environments
- 📊 **Monitoring**: Full integration with W&B, Langfuse, and OpenPipe

### Supported Models

| Model Family | Supported Versions | Features |
|------------|----------|------|
| **Qwen** | 2.5, 3.0 | Chinese/English multimodal support |
| **Llama** | 3.1, 3.2 | Meta open-source models |
| **Kimi** | Latest | Long context specialization |
| **HuggingFace** | All compatible models | Custom model support |

## Environment Setup and Installation

### 1. Basic Requirements

```bash
# Python 3.8+ required
python --version

# Check CUDA support (optional)
nvidia-smi

# Check Git installation
git --version
```

### 2. Installing OpenPipe ART

```bash
# Clone the repository
git clone https://github.com/OpenPipe/ART.git
cd ART

# Create and activate a virtual environment
python -m venv venv_art
source venv_art/bin/activate  # macOS/Linux
# venv_art\Scripts\activate  # Windows

# Install dependencies
pip install -r requirements.txt

# Development install (optional)
pip install -e .
```

### 3. Setting Environment Variables

```bash
# Create .env file
cat > .env << 'EOF'
# Model settings
OPENAI_API_KEY=your_openai_api_key
OPENPIPE_API_KEY=your_openpipe_api_key

# Monitoring settings
WANDB_API_KEY=your_wandb_api_key
LANGFUSE_SECRET_KEY=your_langfuse_secret_key
LANGFUSE_PUBLIC_KEY=your_langfuse_public_key
LANGFUSE_HOST=https://cloud.langfuse.com

# Training settings
ART_SERVER_PORT=8000
ART_CLIENT_WORKERS=4
EOF

# Load environment variables
source .env
```

## Understanding the GRPO Algorithm

### What is GRPO?

**Group Relative Policy Optimization** is the core algorithm of ART, a reinforcement learning technique specialized for multi-step agent training.

```python
# GRPO core concept code example
import torch
import torch.nn.functional as F

class GRPOTrainer:
    def __init__(self, model, reference_model, beta=0.1):
        self.model = model
        self.reference_model = reference_model
        self.beta = beta  # KL divergence weight
    
    def compute_grpo_loss(self, states, actions, rewards, group_baselines):
        """Compute GRPO loss function"""
        
        # Log probabilities of the current policy
        current_logprobs = self.model.get_log_probs(states, actions)
        
        # Log probabilities of the reference model
        with torch.no_grad():
            reference_logprobs = self.reference_model.get_log_probs(states, actions)
        
        # KL divergence penalty
        kl_penalty = self.beta * (current_logprobs - reference_logprobs)
        
        # Group relative advantage calculation
        group_advantages = rewards - group_baselines
        
        # GRPO loss
        policy_loss = -(group_advantages * current_logprobs).mean()
        kl_loss = kl_penalty.mean()
        
        total_loss = policy_loss + kl_loss
        
        return {
            'total_loss': total_loss,
            'policy_loss': policy_loss,
            'kl_loss': kl_loss,
            'advantages': group_advantages.mean()
        }
```

### GRPO vs PPO Comparison

| Feature | GRPO | PPO |
|------|------|-----|
| **Multi-step learning** | Specialized | Single-step focused |
| **Group-based evaluation** | Supported | Individual evaluation |
| **Stability** | High | Moderate |
| **Convergence speed** | Fast | Moderate |

## Practical Example: Email Search Agent

### 1. Analysis of the ART-E [RULER] Example

Let us implement the most practical example, an email search agent.

```python
# examples/email_search/email_agent.py
import asyncio
from typing import List, Dict, Any
from art.environment import Environment
from art.agent import Agent
from art.trainer import GRPOTrainer

class EmailSearchEnvironment(Environment):
    def __init__(self, email_database: List[Dict]):
        super().__init__()
        self.email_db = email_database
        self.current_query = None
        self.search_history = []
        
    async def reset(self) -> Dict[str, Any]:
        """Initialize the environment"""
        self.current_query = self.sample_query()
        self.search_history = []
        
        return {
            'query': self.current_query,
            'available_actions': ['search', 'filter', 'sort', 'select'],
            'search_results': [],
            'step': 0
        }
    
    async def step(self, action: Dict[str, Any]) -> tuple:
        """Execute action and update state"""
        state = await self.get_state()
        
        if action['type'] == 'search':
            results = self.search_emails(action['query'])
            reward = self.calculate_search_reward(results)
            
        elif action['type'] == 'filter':
            results = self.filter_emails(state['search_results'], action['filters'])
            reward = self.calculate_filter_reward(results)
            
        elif action['type'] == 'select':
            selected_email = self.select_email(action['email_id'])
            reward = self.calculate_selection_reward(selected_email)
            done = True
        
        self.search_history.append(action)
        
        new_state = await self.get_state()
        return new_state, reward, done, {}
    
    def search_emails(self, query: str) -> List[Dict]:
        """Email search logic"""
        results = []
        query_terms = query.lower().split()
        
        for email in self.email_db:
            score = 0
            content = f"{email['subject']} {email['body']} {email['sender']}".lower()
            
            for term in query_terms:
                if term in content:
                    score += content.count(term)
            
            if score > 0:
                email_copy = email.copy()
                email_copy['relevance_score'] = score
                results.append(email_copy)
        
        return sorted(results, key=lambda x: x['relevance_score'], reverse=True)
    
    def calculate_search_reward(self, results: List[Dict]) -> float:
        """Calculate reward based on search results"""
        if not results:
            return -0.1  # No results penalty
        
        # Reward based on relevance scores
        relevance_scores = [r['relevance_score'] for r in results[:5]]
        avg_relevance = sum(relevance_scores) / len(relevance_scores)
        
        # Diversity bonus
        diversity_bonus = len(set(r['sender'] for r in results[:10])) * 0.01
        
        return min(avg_relevance * 0.1 + diversity_bonus, 1.0)

class EmailSearchAgent(Agent):
    def __init__(self, model_name: str = "Qwen/Qwen2.5-7B-Instruct"):
        super().__init__(model_name)
        self.action_history = []
        
    async def select_action(self, state: Dict[str, Any]) -> Dict[str, Any]:
        """Select action based on state"""
        
        # Build system prompt
        system_prompt = """
        You are an email search specialist. To find emails matching the user's request,
        you can perform the following actions in sequence:
        
        1. search: Search emails by keyword
        2. filter: Filter search results (by date, sender, etc.)
        3. sort: Sort results (by relevance, date, etc.)
        4. select: Select the final email
        
        At each step, choose the optimal action to find the email the user wants.
        """
        
        # Current state description
        state_description = f"""
        Current situation:
        - Search query: {state['query']}
        - Current step: {state['step']}
        - Available actions: {state['available_actions']}
        - Number of search results: {len(state.get('search_results', []))}
        """
        
        # Request action from model
        response = await self.generate_response(
            system_prompt + state_description,
            max_tokens=150,
            temperature=0.7
        )
        
        # Parse response
        action = self.parse_action(response, state)
        self.action_history.append(action)
        
        return action
    
    def parse_action(self, response: str, state: Dict[str, Any]) -> Dict[str, Any]:
        """Parse model response into action"""
        response_lower = response.lower()
        
        if 'search' in response_lower and state['step'] == 0:
            # Extract search keywords
            keywords = self.extract_keywords(response, state['query'])
            return {
                'type': 'search',
                'query': keywords,
                'reasoning': response
            }
        
        elif 'filter' in response_lower and len(state.get('search_results', [])) > 0:
            filters = self.extract_filters(response)
            return {
                'type': 'filter',
                'filters': filters,
                'reasoning': response
            }
        
        elif 'select' in response_lower:
            email_id = self.extract_email_id(response, state.get('search_results', []))
            return {
                'type': 'select',
                'email_id': email_id,
                'reasoning': response
            }
        
        # Default action
        return {
            'type': 'search',
            'query': state['query'],
            'reasoning': 'Default search action'
        }
```

### 2. Training Script

```python
# train_email_agent.py
import asyncio
import json
from art.trainer import GRPOTrainer
from art.environment import Environment
from email_agent import EmailSearchEnvironment, EmailSearchAgent

async def train_email_agent():
    """Train the email search agent"""
    
    # Load email database
    with open('email_database.json', 'r') as f:
        email_db = json.load(f)
    
    # Initialize environment and agent
    env = EmailSearchEnvironment(email_db)
    agent = EmailSearchAgent("Qwen/Qwen2.5-7B-Instruct")
    
    # Training configuration
    trainer = GRPOTrainer(
        agent=agent,
        environment=env,
        learning_rate=1e-5,
        batch_size=8,
        episodes_per_batch=32,
        max_episode_length=10,
        kl_penalty=0.1
    )
    
    # Run training
    for epoch in range(100):
        print(f"Epoch {epoch + 1}/100")
        
        # Collect episodes
        episodes = await trainer.collect_episodes()
        
        # Update model
        loss_info = await trainer.update_policy(episodes)
        
        # Logging
        if epoch % 10 == 0:
            print(f"Policy Loss: {loss_info['policy_loss']:.4f}")
            print(f"KL Divergence: {loss_info['kl_loss']:.4f}")
            print(f"Average Reward: {loss_info['avg_reward']:.4f}")
            
            # Save checkpoint
            await trainer.save_checkpoint(f"checkpoint_epoch_{epoch}.pt")
    
    print("Training completed!")

if __name__ == "__main__":
    asyncio.run(train_email_agent())
```

### 3. Evaluation Script

```python
# evaluate_email_agent.py
import asyncio
import json
from email_agent import EmailSearchEnvironment, EmailSearchAgent

async def evaluate_agent():
    """Evaluate the trained agent"""
    
    # Load test data
    with open('test_queries.json', 'r') as f:
        test_queries = json.load(f)
    
    with open('email_database.json', 'r') as f:
        email_db = json.load(f)
    
    # Initialize environment and agent
    env = EmailSearchEnvironment(email_db)
    agent = EmailSearchAgent("Qwen/Qwen2.5-7B-Instruct")
    
    # Load checkpoint
    agent.load_checkpoint("best_checkpoint.pt")
    
    total_success = 0
    total_queries = len(test_queries)
    
    for i, query_data in enumerate(test_queries):
        print(f"Testing query {i+1}/{total_queries}: {query_data['query']}")
        
        # Initialize environment
        state = await env.reset()
        state['query'] = query_data['query']
        
        done = False
        step_count = 0
        max_steps = 10
        
        while not done and step_count < max_steps:
            # Agent selects action
            action = await agent.select_action(state)
            
            # Execute action in environment
            state, reward, done, info = await env.step(action)
            step_count += 1
            
            print(f"  Step {step_count}: {action['type']} - Reward: {reward:.3f}")
        
        # Determine success
        if done and reward > 0.5:  # Success threshold
            total_success += 1
            print(f"  Success!")
        else:
            print(f"  Failed")
    
    success_rate = total_success / total_queries
    print(f"\nOverall Success Rate: {success_rate:.2%}")

if __name__ == "__main__":
    asyncio.run(evaluate_agent())
```

## Client-Server Architecture

### 1. Server Configuration

```python
# art_server.py
from fastapi import FastAPI, WebSocket
from fastapi.responses import HTMLResponse
import asyncio
import json
from typing import Dict, List
import uvicorn

app = FastAPI(title="ART Training Server")

class TrainingServer:
    def __init__(self):
        self.active_clients: Dict[str, WebSocket] = {}
        self.training_queue: List[Dict] = []
        self.results_queue: List[Dict] = []
        
    async def register_client(self, client_id: str, websocket: WebSocket):
        """Register a client"""
        self.active_clients[client_id] = websocket
        print(f"Client {client_id} connected")
    
    async def distribute_episodes(self, episodes: List[Dict]):
        """Distribute episodes to clients"""
        if not self.active_clients:
            return
        
        clients = list(self.active_clients.keys())
        episodes_per_client = len(episodes) // len(clients)
        
        for i, client_id in enumerate(clients):
            start_idx = i * episodes_per_client
            end_idx = start_idx + episodes_per_client if i < len(clients) - 1 else len(episodes)
            
            client_episodes = episodes[start_idx:end_idx]
            
            await self.send_to_client(client_id, {
                'type': 'train_episodes',
                'episodes': client_episodes,
                'client_id': client_id
            })
    
    async def send_to_client(self, client_id: str, message: Dict):
        """Send a message to a specific client"""
        if client_id in self.active_clients:
            try:
                await self.active_clients[client_id].send_text(json.dumps(message))
            except Exception as e:
                print(f"Failed to send to client {client_id}: {e}")
                del self.active_clients[client_id]

server = TrainingServer()

@app.websocket("/ws/{client_id}")
async def websocket_endpoint(websocket: WebSocket, client_id: str):
    await websocket.accept()
    await server.register_client(client_id, websocket)
    
    try:
        while True:
            data = await websocket.receive_text()
            message = json.loads(data)
            
            if message['type'] == 'episode_result':
                server.results_queue.append(message)
            elif message['type'] == 'status_update':
                print(f"Client {client_id}: {message['status']}")
                
    except Exception as e:
        print(f"Client {client_id} disconnected: {e}")
        if client_id in server.active_clients:
            del server.active_clients[client_id]

@app.get("/")
async def get_dashboard():
    """Training dashboard"""
    return HTMLResponse(content="""
    <!DOCTYPE html>
    <html>
    <head>
        <title>ART Training Dashboard</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; }
            .status { padding: 20px; background: #f0f0f0; border-radius: 5px; }
            .client { margin: 10px 0; padding: 10px; background: #e8f4f8; }
        </style>
    </head>
    <body>
        <h1>ART Training Dashboard</h1>
        <div class="status">
            <h3>Server Status: Running</h3>
            <p>Active Clients: <span id="client-count">0</span></p>
            <p>Episodes in Queue: <span id="episode-count">0</span></p>
        </div>
        
        <div id="clients">
            <h3>Connected Clients</h3>
        </div>
        
        <script>
            // Real-time status update logic
            function updateStatus() {
                fetch('/status')
                    .then(response => response.json())
                    .then(data => {
                        document.getElementById('client-count').textContent = data.active_clients;
                        document.getElementById('episode-count').textContent = data.episodes_queued;
                    });
            }
            
            setInterval(updateStatus, 2000);
        </script>
    </body>
    </html>
    """)

@app.get("/status")
async def get_status():
    """Server status API"""
    return {
        "active_clients": len(server.active_clients),
        "episodes_queued": len(server.training_queue),
        "results_available": len(server.results_queue)
    }

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

### 2. Client Configuration

```python
# art_client.py
import asyncio
import websockets
import json
import torch
from art.agent import Agent
from art.environment import Environment

class TrainingClient:
    def __init__(self, client_id: str, server_url: str = "ws://localhost:8000"):
        self.client_id = client_id
        self.server_url = f"{server_url}/ws/{client_id}"
        self.agent = None
        self.environment = None
        
    async def connect(self):
        """Connect to the server"""
        self.websocket = await websockets.connect(self.server_url)
        print(f"Client {self.client_id} connected to server")
        
        # Send status update
        await self.send_message({
            'type': 'status_update',
            'status': 'connected',
            'client_id': self.client_id
        })
    
    async def send_message(self, message: dict):
        """Send message to the server"""
        await self.websocket.send(json.dumps(message))
    
    async def handle_server_messages(self):
        """Handle messages from the server"""
        async for message in self.websocket:
            data = json.loads(message)
            
            if data['type'] == 'train_episodes':
                await self.process_episodes(data['episodes'])
            elif data['type'] == 'update_model':
                await self.update_model(data['model_state'])
            elif data['type'] == 'shutdown':
                break
    
    async def process_episodes(self, episodes: list):
        """Process episodes and train"""
        print(f"Processing {len(episodes)} episodes")
        
        results = []
        for episode in episodes:
            # Execute episode
            result = await self.run_episode(episode)
            results.append(result)
        
        # Send results to server
        await self.send_message({
            'type': 'episode_result',
            'results': results,
            'client_id': self.client_id
        })
    
    async def run_episode(self, episode_config: dict):
        """Run a single episode"""
        if not self.agent or not self.environment:
            # Initialize agent and environment
            self.agent = Agent(episode_config['model_name'])
            self.environment = Environment(episode_config['env_config'])
        
        state = await self.environment.reset()
        total_reward = 0
        steps = 0
        max_steps = episode_config.get('max_steps', 50)
        
        episode_data = {
            'states': [],
            'actions': [],
            'rewards': [],
            'done': False
        }
        
        while steps < max_steps:
            # Agent selects action
            action = await self.agent.select_action(state)
            
            # Execute action in environment
            next_state, reward, done, info = await self.environment.step(action)
            
            # Collect data
            episode_data['states'].append(state)
            episode_data['actions'].append(action)
            episode_data['rewards'].append(reward)
            
            total_reward += reward
            steps += 1
            state = next_state
            
            if done:
                episode_data['done'] = True
                break
        
        return {
            'episode_id': episode_config['episode_id'],
            'total_reward': total_reward,
            'steps': steps,
            'data': episode_data
        }

async def start_client(client_id: str):
    """Start the client"""
    client = TrainingClient(client_id)
    
    try:
        await client.connect()
        await client.handle_server_messages()
    except Exception as e:
        print(f"Client error: {e}")
    finally:
        if hasattr(client, 'websocket'):
            await client.websocket.close()

if __name__ == "__main__":
    import sys
    client_id = sys.argv[1] if len(sys.argv) > 1 else "client_1"
    asyncio.run(start_client(client_id))
```

## RULER-Integrated Reward System

### 1. Automated Evaluation with RULER

```python
# ruler_evaluator.py
from typing import Dict, List, Any
import json
import re

class RULERRewardSystem:
    """RULER-based automatic reward calculation system"""
    
    def __init__(self, task_config: Dict[str, Any]):
        self.task_config = task_config
        self.evaluation_criteria = self.load_criteria()
        
    def load_criteria(self) -> Dict[str, Any]:
        """Load evaluation criteria"""
        return {
            'accuracy': {
                'weight': 0.4,
                'description': 'Task accuracy'
            },
            'efficiency': {
                'weight': 0.3,
                'description': 'Execution efficiency (number of steps)'
            },
            'completeness': {
                'weight': 0.2,
                'description': 'Task completeness'
            },
            'user_satisfaction': {
                'weight': 0.1,
                'description': 'User satisfaction'
            }
        }
    
    def evaluate_episode(self, episode_data: Dict[str, Any]) -> float:
        """Evaluate the entire episode"""
        
        total_score = 0.0
        
        for criterion, config in self.evaluation_criteria.items():
            if criterion == 'accuracy':
                score = self.evaluate_accuracy(episode_data)
            elif criterion == 'efficiency':
                score = self.evaluate_efficiency(episode_data)
            elif criterion == 'completeness':
                score = self.evaluate_completeness(episode_data)
            elif criterion == 'user_satisfaction':
                score = self.evaluate_user_satisfaction(episode_data)
            else:
                score = 0.0
            
            weighted_score = score * config['weight']
            total_score += weighted_score
            
            print(f"{criterion}: {score:.3f} (weight: {config['weight']}) = {weighted_score:.3f}")
        
        return min(max(total_score, 0.0), 1.0)  # Clamp to 0-1 range
    
    def evaluate_accuracy(self, episode_data: Dict[str, Any]) -> float:
        """Evaluate accuracy"""
        if not episode_data.get('final_result'):
            return 0.0
        
        expected_result = episode_data.get('expected_result')
        actual_result = episode_data.get('final_result')
        
        if not expected_result:
            # Heuristic evaluation
            return self.heuristic_accuracy_evaluation(actual_result, episode_data)
        
        # Direct comparison
        if isinstance(expected_result, str) and isinstance(actual_result, str):
            return self.string_similarity(expected_result, actual_result)
        elif isinstance(expected_result, dict) and isinstance(actual_result, dict):
            return self.dict_similarity(expected_result, actual_result)
        else:
            return 1.0 if expected_result == actual_result else 0.0
    
    def evaluate_efficiency(self, episode_data: Dict[str, Any]) -> float:
        """Evaluate efficiency based on number of steps"""
        actual_steps = len(episode_data.get('actions', []))
        optimal_steps = episode_data.get('optimal_steps', actual_steps)
        
        if actual_steps <= optimal_steps:
            return 1.0
        else:
            # Score decreases as step count increases
            penalty = (actual_steps - optimal_steps) / optimal_steps
            return max(0.0, 1.0 - penalty * 0.5)
    
    def evaluate_completeness(self, episode_data: Dict[str, Any]) -> float:
        """Evaluate completeness"""
        required_actions = episode_data.get('required_actions', [])
        performed_actions = episode_data.get('actions', [])
        
        if not required_actions:
            return 1.0 if episode_data.get('done', False) else 0.5
        
        # Check whether required actions were performed
        performed_action_types = [action.get('type') for action in performed_actions]
        completed_requirements = 0
        
        for req_action in required_actions:
            if req_action in performed_action_types:
                completed_requirements += 1
        
        return completed_requirements / len(required_actions)
    
    def evaluate_user_satisfaction(self, episode_data: Dict[str, Any]) -> float:
        """Evaluate user satisfaction (heuristic)"""
        # Check for errors
        error_penalty = len(episode_data.get('errors', [])) * 0.1
        
        # Consider response time
        response_time = episode_data.get('response_time', 0)
        time_penalty = max(0, (response_time - 30) / 60) * 0.2  # Penalty beyond 30 seconds
        
        # Deduct penalties from base score
        base_score = 1.0
        final_score = base_score - error_penalty - time_penalty
        
        return max(0.0, final_score)
    
    def string_similarity(self, expected: str, actual: str) -> float:
        """Calculate string similarity"""
        from difflib import SequenceMatcher
        return SequenceMatcher(None, expected.lower(), actual.lower()).ratio()
    
    def dict_similarity(self, expected: dict, actual: dict) -> float:
        """Calculate dictionary similarity"""
        expected_keys = set(expected.keys())
        actual_keys = set(actual.keys())
        
        # Key match rate
        key_match = len(expected_keys & actual_keys) / len(expected_keys | actual_keys)
        
        # Value match rate
        matching_keys = expected_keys & actual_keys
        value_matches = 0
        
        for key in matching_keys:
            if expected[key] == actual[key]:
                value_matches += 1
        
        value_match = value_matches / len(matching_keys) if matching_keys else 0
        
        return (key_match + value_match) / 2
    
    def heuristic_accuracy_evaluation(self, result: Any, episode_data: Dict[str, Any]) -> float:
        """Heuristic accuracy evaluation"""
        # Heuristic evaluation by task type
        task_type = episode_data.get('task_type', 'general')
        
        if task_type == 'email_search':
            return self.evaluate_email_search_accuracy(result, episode_data)
        elif task_type == 'code_generation':
            return self.evaluate_code_accuracy(result, episode_data)
        elif task_type == 'question_answering':
            return self.evaluate_qa_accuracy(result, episode_data)
        else:
            # General heuristic
            return 0.7 if episode_data.get('done', False) else 0.3
    
    def evaluate_email_search_accuracy(self, result: Any, episode_data: Dict[str, Any]) -> float:
        """Evaluate email search accuracy"""
        if not result or not isinstance(result, dict):
            return 0.0
        
        # Check if an email was selected
        if 'selected_email' not in result:
            return 0.2
        
        email = result['selected_email']
        query = episode_data.get('original_query', '').lower()
        
        # Check relevance between email content and query
        content = f"{email.get('subject', '')} {email.get('body', '')}".lower()
        
        # Keyword matching score
        query_words = query.split()
        matches = sum(1 for word in query_words if word in content)
        keyword_score = matches / len(query_words) if query_words else 0
        
        # Sender relevance (if applicable)
        sender_score = 0
        if 'sender' in email and any(word in email['sender'].lower() for word in query_words):
            sender_score = 0.2
        
        return min(1.0, keyword_score * 0.7 + sender_score + 0.1)  # Base score 0.1

# Usage example
ruler_system = RULERRewardSystem({
    'task_type': 'email_search',
    'optimal_steps': 5,
    'required_actions': ['search', 'filter', 'select']
})

# Episode data example
episode_data = {
    'actions': [
        {'type': 'search', 'query': 'meeting schedule'},
        {'type': 'filter', 'filters': {'sender': 'boss@company.com'}},
        {'type': 'select', 'email_id': 'email_123'}
    ],
    'final_result': {
        'selected_email': {
            'id': 'email_123',
            'subject': 'Team Meeting Schedule for Next Week',
            'sender': 'boss@company.com',
            'body': 'Hi team, here is the schedule for next week...'
        }
    },
    'original_query': 'meeting schedule boss',
    'done': True,
    'task_type': 'email_search',
    'response_time': 25,
    'errors': []
}

reward = ruler_system.evaluate_episode(episode_data)
print(f"Episode Reward: {reward:.3f}")
```

## Monitoring and Logging System

### 1. Weights & Biases Integration

```python
# wandb_integration.py
import wandb
import json
from datetime import datetime
from typing import Dict, List, Any

class ARTWandbLogger:
    def __init__(self, project_name: str = "art-training", experiment_name: str = None):
        self.project_name = project_name
        self.experiment_name = experiment_name or f"art_experiment_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        self.run = None
        
    def initialize_run(self, config: Dict[str, Any]):
        """Initialize W&B run"""
        self.run = wandb.init(
            project=self.project_name,
            name=self.experiment_name,
            config=config,
            tags=["ART", "GRPO", config.get("model_name", "unknown")],
            notes=f"ART training with {config.get('agent_type', 'unknown')} agent"
        )
        
        # Create tables for artifact tracking
        self.episode_table = wandb.Table(columns=[
            "episode_id", "total_reward", "steps", "success", "accuracy", "efficiency"
        ])
        
        self.action_table = wandb.Table(columns=[
            "episode_id", "step", "action_type", "reward", "state_description"
        ])
    
    def log_training_metrics(self, epoch: int, metrics: Dict[str, float]):
        """Log training metrics"""
        if not self.run:
            return
            
        wandb.log({
            "epoch": epoch,
            "policy_loss": metrics.get("policy_loss", 0),
            "value_loss": metrics.get("value_loss", 0),
            "kl_divergence": metrics.get("kl_divergence", 0),
            "entropy": metrics.get("entropy", 0),
            "learning_rate": metrics.get("learning_rate", 0),
            "average_reward": metrics.get("average_reward", 0),
            "success_rate": metrics.get("success_rate", 0),
            "average_episode_length": metrics.get("average_episode_length", 0)
        })
    
    def log_episode(self, episode_data: Dict[str, Any]):
        """Log episode data"""
        if not self.run:
            return
            
        episode_id = episode_data.get("episode_id", "unknown")
        total_reward = episode_data.get("total_reward", 0)
        steps = episode_data.get("steps", 0)
        success = episode_data.get("success", False)
        
        # Calculate metrics
        accuracy = episode_data.get("accuracy_score", 0)
        efficiency = 1.0 - (steps / episode_data.get("max_steps", steps)) if steps > 0 else 0
        
        # Add to episode table
        self.episode_table.add_data(
            episode_id, total_reward, steps, success, accuracy, efficiency
        )
        
        # Detailed logging per action
        for i, action in enumerate(episode_data.get("actions", [])):
            self.action_table.add_data(
                episode_id,
                i,
                action.get("type", "unknown"),
                action.get("reward", 0),
                action.get("state_description", "")[:100]  # First 100 characters only
            )
    
    def log_model_artifacts(self, model_path: str, epoch: int):
        """Log model artifacts"""
        if not self.run:
            return
            
        artifact = wandb.Artifact(
            name=f"model_epoch_{epoch}",
            type="model",
            description=f"ART model checkpoint at epoch {epoch}"
        )
        artifact.add_file(model_path)
        self.run.log_artifact(artifact)
    
    def finish_run(self):
        """Finish run and upload tables"""
        if not self.run:
            return
            
        # Upload tables
        self.run.log({"episodes": self.episode_table})
        self.run.log({"actions": self.action_table})
        
        # Finish run
        wandb.finish()

# Usage example
logger = ARTWandbLogger("email-agent-training", "qwen2.5_email_search_v1")

# Initialize run with config
config = {
    "model_name": "Qwen/Qwen2.5-7B-Instruct",
    "agent_type": "email_search",
    "learning_rate": 1e-5,
    "batch_size": 8,
    "max_episodes": 1000,
    "max_steps_per_episode": 10
}

logger.initialize_run(config)

# Log metrics during training
for epoch in range(100):
    # ... training logic ...
    
    metrics = {
        "policy_loss": 0.123,
        "kl_divergence": 0.045,
        "average_reward": 0.67,
        "success_rate": 0.82
    }
    
    logger.log_training_metrics(epoch, metrics)

logger.finish_run()
```

### 2. Langfuse Integration

```python
# langfuse_integration.py
from langfuse import Langfuse
from langfuse.decorators import observe, langfuse_context
from typing import Dict, List, Any
import json

class ARTLangfuseTracker:
    def __init__(self):
        self.langfuse = Langfuse()
        
    @observe()
    def track_episode(self, episode_data: Dict[str, Any]):
        """Track an episode"""
        
        # Create a trace for the episode
        trace = self.langfuse.trace(
            name=f"episode_{episode_data.get('episode_id')}",
            input={
                "initial_state": episode_data.get("initial_state"),
                "task_description": episode_data.get("task_description")
            },
            output={
                "final_result": episode_data.get("final_result"),
                "total_reward": episode_data.get("total_reward"),
                "success": episode_data.get("success")
            },
            metadata={
                "agent_type": episode_data.get("agent_type"),
                "model_name": episode_data.get("model_name"),
                "environment": episode_data.get("environment_type")
            }
        )
        
        # Track each action as an individual span
        for i, action in enumerate(episode_data.get("actions", [])):
            span = trace.span(
                name=f"action_{i}_{action.get('type')}",
                input={
                    "state": action.get("state"),
                    "action_type": action.get("type"),
                    "parameters": action.get("parameters")
                },
                output={
                    "result": action.get("result"),
                    "reward": action.get("reward"),
                    "next_state": action.get("next_state")
                },
                metadata={
                    "step_number": i,
                    "reasoning": action.get("reasoning"),
                    "execution_time": action.get("execution_time")
                }
            )
        
        return trace
    
    @observe()
    def track_model_generation(self, prompt: str, response: str, metadata: Dict[str, Any]):
        """Track model generation"""
        
        generation = self.langfuse.generation(
            name="agent_action_generation",
            model=metadata.get("model_name", "unknown"),
            input=prompt,
            output=response,
            metadata={
                "temperature": metadata.get("temperature", 0.7),
                "max_tokens": metadata.get("max_tokens", 150),
                "token_count": metadata.get("token_count", 0),
                "latency_ms": metadata.get("latency_ms", 0)
            }
        )
        
        return generation
    
    def track_training_session(self, session_data: Dict[str, Any]):
        """Track a training session"""
        
        session = self.langfuse.trace(
            name=f"training_session_{session_data.get('session_id')}",
            input={
                "config": session_data.get("config"),
                "start_time": session_data.get("start_time")
            },
            output={
                "final_metrics": session_data.get("final_metrics"),
                "total_episodes": session_data.get("total_episodes"),
                "training_time": session_data.get("training_time")
            },
            metadata={
                "experiment_name": session_data.get("experiment_name"),
                "model_checkpoints": session_data.get("model_checkpoints"),
                "hardware_info": session_data.get("hardware_info")
            }
        )
        
        return session
    
    def get_performance_analytics(self, trace_ids: List[str]) -> Dict[str, Any]:
        """Extract performance analytics data"""
        
        analytics = {
            "total_traces": len(trace_ids),
            "success_rate": 0,
            "average_reward": 0,
            "average_steps": 0,
            "action_distribution": {},
            "error_patterns": []
        }
        
        successful_episodes = 0
        total_reward = 0
        total_steps = 0
        action_counts = {}
        
        for trace_id in trace_ids:
            trace = self.langfuse.get_trace(trace_id)
            
            # Calculate success rate
            if trace.output.get("success", False):
                successful_episodes += 1
            
            # Accumulate rewards
            reward = trace.output.get("total_reward", 0)
            total_reward += reward
            
            # Calculate step count
            spans = trace.observations
            steps = len([s for s in spans if s.type == "SPAN"])
            total_steps += steps
            
            # Calculate action distribution
            for span in spans:
                if span.type == "SPAN" and span.name.startswith("action_"):
                    action_type = span.name.split("_")[-1]
                    action_counts[action_type] = action_counts.get(action_type, 0) + 1
        
        # Compute analytics results
        analytics["success_rate"] = successful_episodes / len(trace_ids) if trace_ids else 0
        analytics["average_reward"] = total_reward / len(trace_ids) if trace_ids else 0
        analytics["average_steps"] = total_steps / len(trace_ids) if trace_ids else 0
        analytics["action_distribution"] = action_counts
        
        return analytics

# Usage example
tracker = ARTLangfuseTracker()

# Episode tracking
episode_data = {
    "episode_id": "ep_001",
    "agent_type": "email_search",
    "model_name": "Qwen/Qwen2.5-7B-Instruct",
    "initial_state": {"query": "find meeting emails"},
    "actions": [
        {
            "type": "search",
            "state": {"query": "find meeting emails"},
            "parameters": {"keywords": ["meeting", "schedule"]},
            "result": {"found_emails": 15},
            "reward": 0.3,
            "reasoning": "Initial search for meeting-related emails"
        }
    ],
    "final_result": {"selected_email": "email_123"},
    "total_reward": 0.85,
    "success": True
}

trace = tracker.track_episode(episode_data)
print(f"Episode tracked: {trace.id}")
```

## Real-World Project: Game AI Agent

### 1. 2048 Game Agent

```python
# games/game_2048.py
import numpy as np
import random
from typing import Tuple, List, Dict, Any
from art.environment import Environment

class Game2048Environment(Environment):
    """2048 game environment"""
    
    def __init__(self, board_size: int = 4):
        super().__init__()
        self.board_size = board_size
        self.board = None
        self.score = 0
        self.moves_count = 0
        
    async def reset(self) -> Dict[str, Any]:
        """Initialize the game"""
        self.board = np.zeros((self.board_size, self.board_size), dtype=int)
        self.score = 0
        self.moves_count = 0
        
        # Place two initial tiles
        self.add_random_tile()
        self.add_random_tile()
        
        return await self.get_state()
    
    async def step(self, action: Dict[str, Any]) -> Tuple[Dict, float, bool, Dict]:
        """Execute action"""
        direction = action.get('direction')  # 'up', 'down', 'left', 'right'
        
        prev_board = self.board.copy()
        prev_score = self.score
        
        # Execute move
        moved = self.move(direction)
        
        if moved:
            self.add_random_tile()
            self.moves_count += 1
        
        # Calculate reward
        reward = self.calculate_reward(prev_board, prev_score, moved)
        
        # Check game over
        done = self.is_game_over()
        
        state = await self.get_state()
        info = {
            'moved': moved,
            'score_increase': self.score - prev_score,
            'max_tile': np.max(self.board)
        }
        
        return state, reward, done, info
    
    def move(self, direction: str) -> bool:
        """Move and merge board"""
        if direction == 'left':
            return self.move_left()
        elif direction == 'right':
            return self.move_right()
        elif direction == 'up':
            return self.move_up()
        elif direction == 'down':
            return self.move_down()
        return False
    
    def move_left(self) -> bool:
        """Move left"""
        moved = False
        for i in range(self.board_size):
            row = self.board[i, :]
            new_row, row_moved = self.merge_line(row)
            self.board[i, :] = new_row
            if row_moved:
                moved = True
        return moved
    
    def move_right(self) -> bool:
        """Move right"""
        moved = False
        for i in range(self.board_size):
            row = self.board[i, ::-1]  # Flip
            new_row, row_moved = self.merge_line(row)
            self.board[i, :] = new_row[::-1]  # Flip back
            if row_moved:
                moved = True
        return moved
    
    def move_up(self) -> bool:
        """Move up"""
        moved = False
        for j in range(self.board_size):
            col = self.board[:, j]
            new_col, col_moved = self.merge_line(col)
            self.board[:, j] = new_col
            if col_moved:
                moved = True
        return moved
    
    def move_down(self) -> bool:
        """Move down"""
        moved = False
        for j in range(self.board_size):
            col = self.board[::-1, j]  # Flip
            new_col, col_moved = self.merge_line(col)
            self.board[:, j] = new_col[::-1]  # Flip back
            if col_moved:
                moved = True
        return moved
    
    def merge_line(self, line: np.ndarray) -> Tuple[np.ndarray, bool]:
        """Merge line logic"""
        # Move non-zero elements to the left
        non_zero = line[line != 0]
        
        # Merge adjacent identical numbers
        merged = []
        i = 0
        while i < len(non_zero):
            if i < len(non_zero) - 1 and non_zero[i] == non_zero[i + 1]:
                # Merge
                merged_value = non_zero[i] * 2
                merged.append(merged_value)
                self.score += merged_value
                i += 2
            else:
                merged.append(non_zero[i])
                i += 1
        
        # Build result array
        result = np.zeros(self.board_size, dtype=int)
        result[:len(merged)] = merged
        
        # Check if change occurred
        moved = not np.array_equal(line, result)
        
        return result, moved
    
    def add_random_tile(self):
        """Add 2 or 4 at a random position"""
        empty_cells = [(i, j) for i in range(self.board_size) 
                      for j in range(self.board_size) if self.board[i, j] == 0]
        
        if empty_cells:
            i, j = random.choice(empty_cells)
            self.board[i, j] = 2 if random.random() < 0.9 else 4
    
    def is_game_over(self) -> bool:
        """Check game over"""
        # Can continue if there are empty cells
        if np.any(self.board == 0):
            return False
        
        # Check for adjacent mergeable tiles
        for i in range(self.board_size):
            for j in range(self.board_size):
                current = self.board[i, j]
                
                # Check right
                if j < self.board_size - 1 and self.board[i, j + 1] == current:
                    return False
                
                # Check below
                if i < self.board_size - 1 and self.board[i + 1, j] == current:
                    return False
        
        return True
    
    def calculate_reward(self, prev_board: np.ndarray, prev_score: int, moved: bool) -> float:
        """Calculate reward"""
        if not moved:
            return -0.1  # Invalid move penalty
        
        # Score increase reward
        score_reward = (self.score - prev_score) / 100.0
        
        # Empty cell reward
        empty_cells = np.sum(self.board == 0)
        empty_reward = empty_cells * 0.01
        
        # Max tile reward
        max_tile = np.max(self.board)
        max_tile_reward = np.log2(max_tile) * 0.1 if max_tile > 0 else 0
        
        # Board smoothness reward (smaller difference between adjacent tiles is better)
        smoothness = self.calculate_smoothness()
        smoothness_reward = smoothness * 0.05
        
        total_reward = score_reward + empty_reward + max_tile_reward + smoothness_reward
        
        return total_reward
    
    def calculate_smoothness(self) -> float:
        """Calculate board smoothness"""
        smoothness = 0
        
        for i in range(self.board_size):
            for j in range(self.board_size):
                if self.board[i, j] != 0:
                    value = np.log2(self.board[i, j])
                    
                    # Compare with right
                    if j < self.board_size - 1 and self.board[i, j + 1] != 0:
                        target_value = np.log2(self.board[i, j + 1])
                        smoothness -= abs(value - target_value)
                    
                    # Compare with below
                    if i < self.board_size - 1 and self.board[i + 1, j] != 0:
                        target_value = np.log2(self.board[i + 1, j])
                        smoothness -= abs(value - target_value)
        
        return smoothness
    
    async def get_state(self) -> Dict[str, Any]:
        """Return current state"""
        return {
            'board': self.board.tolist(),
            'score': self.score,
            'moves_count': self.moves_count,
            'max_tile': int(np.max(self.board)),
            'empty_cells': int(np.sum(self.board == 0)),
            'available_moves': self.get_available_moves()
        }
    
    def get_available_moves(self) -> List[str]:
        """Return available move directions"""
        moves = []
        
        for direction in ['up', 'down', 'left', 'right']:
            # Try the move temporarily and check if there is a change
            temp_board = self.board.copy()
            temp_env = Game2048Environment(self.board_size)
            temp_env.board = temp_board
            
            if temp_env.move(direction):
                moves.append(direction)
        
        return moves

class Game2048Agent(Agent):
    """2048 game agent"""
    
    def __init__(self, model_name: str = "Qwen/Qwen2.5-7B-Instruct"):
        super().__init__(model_name)
        self.strategy = "minimax"  # or "deep_learning"
        
    async def select_action(self, state: Dict[str, Any]) -> Dict[str, Any]:
        """Select action"""
        
        if self.strategy == "minimax":
            return await self.minimax_action(state)
        else:
            return await self.ml_based_action(state)
    
    async def minimax_action(self, state: Dict[str, Any]) -> Dict[str, Any]:
        """Select action with minimax"""
        board = np.array(state['board'])
        available_moves = state['available_moves']
        
        if not available_moves:
            return {'direction': 'up', 'reasoning': 'No moves available'}
        
        best_move = None
        best_score = -float('inf')
        
        for move in available_moves:
            # Calculate score for each move
            score = self.evaluate_move(board, move, depth=3)
            
            if score > best_score:
                best_score = score
                best_move = move
        
        return {
            'direction': best_move,
            'reasoning': f'Minimax evaluation: {best_move} scored {best_score:.2f}',
            'expected_score': best_score
        }
    
    def evaluate_move(self, board: np.ndarray, direction: str, depth: int) -> float:
        """Evaluate move (minimax)"""
        if depth == 0:
            return self.evaluate_board(board)
        
        # Simulate move in a temporary environment
        temp_env = Game2048Environment(board.shape[0])
        temp_env.board = board.copy()
        
        if not temp_env.move(direction):
            return -1000  # Invalid move
        
        # Evaluate for all possible positions where a new tile could be added
        empty_cells = [(i, j) for i in range(board.shape[0]) 
                      for j in range(board.shape[0]) if temp_env.board[i, j] == 0]
        
        if not empty_cells:
            return self.evaluate_board(temp_env.board)
        
        total_score = 0
        for i, j in empty_cells:
            for value in [2, 4]:
                prob = 0.9 if value == 2 else 0.1
                
                # Add new tile
                temp_env.board[i, j] = value
                
                # Evaluate next level
                next_score = max([
                    self.evaluate_move(temp_env.board, next_dir, depth - 1)
                    for next_dir in ['up', 'down', 'left', 'right']
                ])
                
                total_score += prob * next_score
                
                # Remove tile
                temp_env.board[i, j] = 0
        
        return total_score / len(empty_cells)
    
    def evaluate_board(self, board: np.ndarray) -> float:
        """Board evaluation function"""
        # Empty cell score
        empty_score = np.sum(board == 0) * 10
        
        # Max tile score
        max_tile = np.max(board)
        max_score = np.log2(max_tile) * 100 if max_tile > 0 else 0
        
        # Smoothness score
        smoothness = self.calculate_smoothness(board) * 50
        
        # Monotonicity score (higher tiles concentrated to one side is better)
        monotonicity = self.calculate_monotonicity(board) * 100
        
        return empty_score + max_score + smoothness + monotonicity
    
    def calculate_smoothness(self, board: np.ndarray) -> float:
        """Calculate smoothness"""
        smoothness = 0
        size = board.shape[0]
        
        for i in range(size):
            for j in range(size):
                if board[i, j] != 0:
                    value = np.log2(board[i, j])
                    
                    for di, dj in [(0, 1), (1, 0)]:  # Right, down
                        ni, nj = i + di, j + dj
                        if ni < size and nj < size and board[ni, nj] != 0:
                            target_value = np.log2(board[ni, nj])
                            smoothness -= abs(value - target_value)
        
        return smoothness
    
    def calculate_monotonicity(self, board: np.ndarray) -> float:
        """Calculate monotonicity"""
        totals = [0, 0, 0, 0]  # up, down, left, right
        
        for i in range(board.shape[0]):
            current = 0
            next_val = 1
            
            # Horizontal monotonicity
            while next_val < board.shape[1]:
                while next_val < board.shape[1] and board[i, next_val] == 0:
                    next_val += 1
                
                if next_val >= board.shape[1]:
                    next_val -= 1
                
                current_value = np.log2(board[i, current]) if board[i, current] != 0 else 0
                next_value = np.log2(board[i, next_val]) if board[i, next_val] != 0 else 0
                
                if current_value > next_value:
                    totals[0] += next_value - current_value
                elif next_value > current_value:
                    totals[1] += current_value - next_value
                
                current = next_val
                next_val += 1
        
        # Vertical monotonicity
        for j in range(board.shape[1]):
            current = 0
            next_val = 1
            
            while next_val < board.shape[0]:
                while next_val < board.shape[0] and board[next_val, j] == 0:
                    next_val += 1
                
                if next_val >= board.shape[0]:
                    next_val -= 1
                
                current_value = np.log2(board[current, j]) if board[current, j] != 0 else 0
                next_value = np.log2(board[next_val, j]) if board[next_val, j] != 0 else 0
                
                if current_value > next_value:
                    totals[2] += next_value - current_value
                elif next_value > current_value:
                    totals[3] += current_value - next_value
                
                current = next_val
                next_val += 1
        
        return max(totals[0], totals[1]) + max(totals[2], totals[3])

# Training script
async def train_2048_agent():
    """Train the 2048 agent"""
    
    env = Game2048Environment()
    agent = Game2048Agent()
    
    trainer = GRPOTrainer(
        agent=agent,
        environment=env,
        learning_rate=5e-6,
        batch_size=16,
        episodes_per_batch=64,
        max_episode_length=200
    )
    
    best_score = 0
    
    for epoch in range(500):
        print(f"Epoch {epoch + 1}/500")
        
        episodes = await trainer.collect_episodes()
        
        # Track best score
        epoch_best = max([ep['total_reward'] for ep in episodes])
        if epoch_best > best_score:
            best_score = epoch_best
            await trainer.save_checkpoint(f"2048_best_model.pt")
        
        loss_info = await trainer.update_policy(episodes)
        
        if epoch % 50 == 0:
            print(f"Best Score: {best_score}")
            print(f"Average Reward: {loss_info['avg_reward']:.3f}")
            print(f"Policy Loss: {loss_info['policy_loss']:.6f}")

if __name__ == "__main__":
    asyncio.run(train_2048_agent())
```

## Conclusion

**OpenPipe ART (Agent Reinforcement Trainer)** is an innovative framework for effectively training multi-step AI agents in real-world work environments.

### Key Outcomes

1. **GRPO Algorithm**: Stable and efficient reinforcement learning training
2. **Production Applicability**: Support for diverse real-world tasks including email search, games, and coding
3. **Scalability**: Large-scale distributed training with client-server architecture
4. **Automation**: RULER integration eliminates manual reward function engineering

### Practical Application Points

- **Startups**: Develop practical AI agents with limited resources
- **Enterprises**: Train specialized agents for workflow automation
- **Research Institutions**: Multi-step reinforcement learning research platform
- **Developers**: Intelligent agents integrable into games, tools, and services

### Next Steps

1. **Start with the basic example**: Begin with the email search agent
2. **Custom environments**: Implement your own task environment
3. **Production deployment**: Integrate agents into real services
4. **Community contribution**: Contribute improvements to [OpenPipe ART GitHub](https://github.com/OpenPipe/ART)

Develop next-generation production AI agents with OpenPipe ART!

---

**References**:
- [OpenPipe ART GitHub](https://github.com/OpenPipe/ART)
- [GRPO Paper](https://arxiv.org/abs/2402.03300)
- [OpenPipe Official Documentation](https://docs.openpipe.ai/)
- [Langfuse Integration Guide](https://langfuse.com/docs)
