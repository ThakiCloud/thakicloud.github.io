---
title: "OpenPipe ART: دليل شامل لإطار عمل تدريب وكلاء التعلم التعزيزي"
excerpt: "من تدريب الوكلاء متعددة الخطوات باستخدام GRPO إلى تطبيقات العالم الحقيقي. بناء وكلاء ذكاء اصطناعي جاهزين للإنتاج باستخدام نماذج Qwen وLlama وKimi"
seo_title: "دليل OpenPipe ART للتعلم التعزيزي للوكلاء - تدريب GRPO متعدد الخطوات - Thaki Cloud"
seo_description: "تدريب وكلاء ذكاء اصطناعي فعليين باستخدام OpenPipe ART. دليل شامل يغطي خوارزمية GRPO والتدريب متعدد الخطوات ودوال مكافأة RULER وتكامل vLLM"
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
toc_label: "جدول المحتويات"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/ar/llmops/openpipe-art-agent-reinforcement-trainer-guide/"
reading_time: true
lang: ar
published: false
---

⏱️ **وقت القراءة المقدر**: 30 دقيقة

## مقدمة

**OpenPipe ART (Agent Reinforcement Trainer)** هو إطار عمل متقدم للتعلم التعزيزي يُستخدم لتدريب وكلاء الذكاء الاصطناعي متعددة الخطوات في بيئات العمل الحقيقية. يعتمد على خوارزمية **GRPO (Group Relative Policy Optimization)**، وهو ما يُتيح تطوير وكلاء جاهزين للإنتاج مع طيف واسع من نماذج اللغة، بما فيها Qwen2.5 وQwen3 وLlama وKimi.

### المزايا الأساسية لـ ART

- 🚀 **خوارزمية GRPO**: تعلم مستقر متعدد الخطوات عبر تحسين السياسة النسبي الجماعي
- 🎯 **التركيز على الإنتاج**: تدريب على مهام حقيقية كالبحث في البريد الإلكتروني والألعاب والبرمجة
- 🔧 **تكامل RULER**: نظام تقييم آلي دون الحاجة إلى هندسة دوال المكافأة يدويًا
- 🌐 **Client-Server**: بنية قابلة للتوسع للبيئات الموزعة
- 📊 **المراقبة**: تكامل كامل مع W&B وLangfuse وOpenPipe

### النماذج المدعومة

| عائلة النموذج | الإصدارات المدعومة | الميزات |
|------------|----------|------|
| **Qwen** | 2.5, 3.0 | دعم متعدد اللغات صيني/إنجليزي |
| **Llama** | 3.1, 3.2 | نماذج Meta مفتوحة المصدر |
| **Kimi** | الأحدث | تخصص في السياق الطويل |
| **HuggingFace** | جميع النماذج المتوافقة | دعم النماذج المخصصة |

## إعداد البيئة والتثبيت

### 1. المتطلبات الأساسية

```bash
# يتطلب Python 3.8 أو أعلى
python --version

# التحقق من دعم CUDA (اختياري)
nvidia-smi

# التحقق من تثبيت Git
git --version
```

### 2. تثبيت OpenPipe ART

```bash
# استنساخ المستودع
git clone https://github.com/OpenPipe/ART.git
cd ART

# إنشاء بيئة افتراضية وتفعيلها
python -m venv venv_art
source venv_art/bin/activate  # macOS/Linux
# venv_art\Scripts\activate  # Windows

# تثبيت التبعيات
pip install -r requirements.txt

# تثبيت للتطوير (اختياري)
pip install -e .
```

### 3. ضبط متغيرات البيئة

```bash
# إنشاء ملف .env
cat > .env << 'EOF'
# إعدادات النموذج
OPENAI_API_KEY=your_openai_api_key
OPENPIPE_API_KEY=your_openpipe_api_key

# إعدادات المراقبة
WANDB_API_KEY=your_wandb_api_key
LANGFUSE_SECRET_KEY=your_langfuse_secret_key
LANGFUSE_PUBLIC_KEY=your_langfuse_public_key
LANGFUSE_HOST=https://cloud.langfuse.com

# إعدادات التدريب
ART_SERVER_PORT=8000
ART_CLIENT_WORKERS=4
EOF

# تحميل متغيرات البيئة
source .env
```

## فهم خوارزمية GRPO

### ما هي GRPO؟

**Group Relative Policy Optimization** هي الخوارزمية الأساسية في ART، وهي تقنية تعلم تعزيزي متخصصة في تدريب الوكلاء متعددة الخطوات.

```python
# مثال على مفهوم GRPO الأساسي
import torch
import torch.nn.functional as F

class GRPOTrainer:
    def __init__(self, model, reference_model, beta=0.1):
        self.model = model
        self.reference_model = reference_model
        self.beta = beta  # وزن تباعد KL
    
    def compute_grpo_loss(self, states, actions, rewards, group_baselines):
        """حساب دالة خسارة GRPO"""
        
        # احتمالات اللوغاريتم للسياسة الحالية
        current_logprobs = self.model.get_log_probs(states, actions)
        
        # احتمالات اللوغاريتم للنموذج المرجعي
        with torch.no_grad():
            reference_logprobs = self.reference_model.get_log_probs(states, actions)
        
        # عقوبة تباعد KL
        kl_penalty = self.beta * (current_logprobs - reference_logprobs)
        
        # حساب الميزة النسبية الجماعية
        group_advantages = rewards - group_baselines
        
        # خسارة GRPO
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

### مقارنة GRPO مقابل PPO

| الميزة | GRPO | PPO |
|------|------|-----|
| **التعلم متعدد الخطوات** | متخصص | التركيز على خطوة واحدة |
| **التقييم الجماعي** | مدعوم | تقييم فردي |
| **الاستقرار** | عالٍ | متوسط |
| **سرعة التقارب** | سريع | متوسط |

## مثال عملي: وكيل البحث في البريد الإلكتروني

### 1. تحليل مثال ART-E [RULER]

لنطبق المثال الأكثر عملية، وهو وكيل البحث في البريد الإلكتروني.

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
        """تهيئة البيئة"""
        self.current_query = self.sample_query()
        self.search_history = []
        
        return {
            'query': self.current_query,
            'available_actions': ['search', 'filter', 'sort', 'select'],
            'search_results': [],
            'step': 0
        }
    
    async def step(self, action: Dict[str, Any]) -> tuple:
        """تنفيذ الإجراء وتحديث الحالة"""
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
        """منطق البحث في البريد الإلكتروني"""
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
        """حساب المكافأة بناءً على نتائج البحث"""
        if not results:
            return -0.1  # عقوبة عدم وجود نتائج
        
        # مكافأة بناءً على درجات الصلة
        relevance_scores = [r['relevance_score'] for r in results[:5]]
        avg_relevance = sum(relevance_scores) / len(relevance_scores)
        
        # مكافأة التنوع
        diversity_bonus = len(set(r['sender'] for r in results[:10])) * 0.01
        
        return min(avg_relevance * 0.1 + diversity_bonus, 1.0)

class EmailSearchAgent(Agent):
    def __init__(self, model_name: str = "Qwen/Qwen2.5-7B-Instruct"):
        super().__init__(model_name)
        self.action_history = []
        
    async def select_action(self, state: Dict[str, Any]) -> Dict[str, Any]:
        """اختيار الإجراء بناءً على الحالة"""
        
        # بناء الرسالة الافتتاحية
        system_prompt = """
        أنت متخصص في البحث في البريد الإلكتروني. للعثور على رسائل تطابق طلب المستخدم،
        يمكنك تنفيذ الإجراءات التالية بالتسلسل:
        
        1. search: البحث في رسائل البريد بالكلمة المفتاحية
        2. filter: تصفية نتائج البحث (حسب التاريخ أو المرسل وما إلى ذلك)
        3. sort: ترتيب النتائج (حسب الصلة أو التاريخ وما إلى ذلك)
        4. select: اختيار البريد الإلكتروني النهائي
        
        في كل خطوة، اختر الإجراء الأمثل للعثور على البريد الإلكتروني الذي يريده المستخدم.
        """
        
        # وصف الحالة الحالية
        state_description = f"""
        الوضع الحالي:
        - استعلام البحث: {state['query']}
        - الخطوة الحالية: {state['step']}
        - الإجراءات المتاحة: {state['available_actions']}
        - عدد نتائج البحث: {len(state.get('search_results', []))}
        """
        
        # طلب الإجراء من النموذج
        response = await self.generate_response(
            system_prompt + state_description,
            max_tokens=150,
            temperature=0.7
        )
        
        # تحليل الاستجابة
        action = self.parse_action(response, state)
        self.action_history.append(action)
        
        return action
    
    def parse_action(self, response: str, state: Dict[str, Any]) -> Dict[str, Any]:
        """تحليل استجابة النموذج إلى إجراء"""
        response_lower = response.lower()
        
        if 'search' in response_lower and state['step'] == 0:
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
        
        # الإجراء الافتراضي
        return {
            'type': 'search',
            'query': state['query'],
            'reasoning': 'Default search action'
        }
```

### 2. سكريبت التدريب

```python
# train_email_agent.py
import asyncio
import json
from art.trainer import GRPOTrainer
from art.environment import Environment
from email_agent import EmailSearchEnvironment, EmailSearchAgent

async def train_email_agent():
    """تدريب وكيل البحث في البريد الإلكتروني"""
    
    # تحميل قاعدة بيانات البريد الإلكتروني
    with open('email_database.json', 'r') as f:
        email_db = json.load(f)
    
    # تهيئة البيئة والوكيل
    env = EmailSearchEnvironment(email_db)
    agent = EmailSearchAgent("Qwen/Qwen2.5-7B-Instruct")
    
    # إعداد التدريب
    trainer = GRPOTrainer(
        agent=agent,
        environment=env,
        learning_rate=1e-5,
        batch_size=8,
        episodes_per_batch=32,
        max_episode_length=10,
        kl_penalty=0.1
    )
    
    # تشغيل التدريب
    for epoch in range(100):
        print(f"Epoch {epoch + 1}/100")
        
        # جمع الحلقات
        episodes = await trainer.collect_episodes()
        
        # تحديث النموذج
        loss_info = await trainer.update_policy(episodes)
        
        # التسجيل
        if epoch % 10 == 0:
            print(f"Policy Loss: {loss_info['policy_loss']:.4f}")
            print(f"KL Divergence: {loss_info['kl_loss']:.4f}")
            print(f"Average Reward: {loss_info['avg_reward']:.4f}")
            
            # حفظ نقطة التحقق
            await trainer.save_checkpoint(f"checkpoint_epoch_{epoch}.pt")
    
    print("اكتمل التدريب!")

if __name__ == "__main__":
    asyncio.run(train_email_agent())
```

### 3. سكريبت التقييم

```python
# evaluate_email_agent.py
import asyncio
import json
from email_agent import EmailSearchEnvironment, EmailSearchAgent

async def evaluate_agent():
    """تقييم الوكيل المُدرَّب"""
    
    # تحميل بيانات الاختبار
    with open('test_queries.json', 'r') as f:
        test_queries = json.load(f)
    
    with open('email_database.json', 'r') as f:
        email_db = json.load(f)
    
    # تهيئة البيئة والوكيل
    env = EmailSearchEnvironment(email_db)
    agent = EmailSearchAgent("Qwen/Qwen2.5-7B-Instruct")
    
    # تحميل نقطة التحقق
    agent.load_checkpoint("best_checkpoint.pt")
    
    total_success = 0
    total_queries = len(test_queries)
    
    for i, query_data in enumerate(test_queries):
        print(f"Testing query {i+1}/{total_queries}: {query_data['query']}")
        
        # تهيئة البيئة
        state = await env.reset()
        state['query'] = query_data['query']
        
        done = False
        step_count = 0
        max_steps = 10
        
        while not done and step_count < max_steps:
            # الوكيل يختار الإجراء
            action = await agent.select_action(state)
            
            # تنفيذ الإجراء في البيئة
            state, reward, done, info = await env.step(action)
            step_count += 1
            
            print(f"  Step {step_count}: {action['type']} - Reward: {reward:.3f}")
        
        # تحديد النجاح
        if done and reward > 0.5:  # حد النجاح
            total_success += 1
            print(f"  نجح!")
        else:
            print(f"  فشل")
    
    success_rate = total_success / total_queries
    print(f"\nمعدل النجاح الكلي: {success_rate:.2%}")

if __name__ == "__main__":
    asyncio.run(evaluate_agent())
```

## البنية Client-Server

### 1. إعداد الخادم

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
        """تسجيل عميل جديد"""
        self.active_clients[client_id] = websocket
        print(f"Client {client_id} connected")
    
    async def distribute_episodes(self, episodes: List[Dict]):
        """توزيع الحلقات على العملاء"""
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
        """إرسال رسالة إلى عميل محدد"""
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
    """لوحة تحكم التدريب"""
    return HTMLResponse(content="""
    <!DOCTYPE html>
    <html>
    <head>
        <title>ART Training Dashboard</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; }
            .status { padding: 20px; background: #f0f0f0; border-radius: 5px; }
        </style>
    </head>
    <body>
        <h1>ART Training Dashboard</h1>
        <div class="status">
            <h3>حالة الخادم: يعمل</h3>
            <p>العملاء النشطون: <span id="client-count">0</span></p>
            <p>الحلقات في قائمة الانتظار: <span id="episode-count">0</span></p>
        </div>
    </body>
    </html>
    """)

@app.get("/status")
async def get_status():
    """واجهة برمجية لحالة الخادم"""
    return {
        "active_clients": len(server.active_clients),
        "episodes_queued": len(server.training_queue),
        "results_available": len(server.results_queue)
    }

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

### 2. إعداد العميل

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
        """الاتصال بالخادم"""
        self.websocket = await websockets.connect(self.server_url)
        print(f"Client {self.client_id} connected to server")
        
        await self.send_message({
            'type': 'status_update',
            'status': 'connected',
            'client_id': self.client_id
        })
    
    async def send_message(self, message: dict):
        """إرسال رسالة إلى الخادم"""
        await self.websocket.send(json.dumps(message))
    
    async def handle_server_messages(self):
        """معالجة الرسائل الواردة من الخادم"""
        async for message in self.websocket:
            data = json.loads(message)
            
            if data['type'] == 'train_episodes':
                await self.process_episodes(data['episodes'])
            elif data['type'] == 'update_model':
                await self.update_model(data['model_state'])
            elif data['type'] == 'shutdown':
                break
    
    async def process_episodes(self, episodes: list):
        """معالجة الحلقات وإجراء التدريب"""
        print(f"Processing {len(episodes)} episodes")
        
        results = []
        for episode in episodes:
            result = await self.run_episode(episode)
            results.append(result)
        
        await self.send_message({
            'type': 'episode_result',
            'results': results,
            'client_id': self.client_id
        })
    
    async def run_episode(self, episode_config: dict):
        """تشغيل حلقة واحدة"""
        if not self.agent or not self.environment:
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
            action = await self.agent.select_action(state)
            next_state, reward, done, info = await self.environment.step(action)
            
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
    """بدء تشغيل العميل"""
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

## نظام المكافأة المتكامل مع RULER

### 1. التقييم الآلي باستخدام RULER

```python
# ruler_evaluator.py
from typing import Dict, List, Any
import json
import re

class RULERRewardSystem:
    """نظام حساب المكافأة الآلي المستند إلى RULER"""
    
    def __init__(self, task_config: Dict[str, Any]):
        self.task_config = task_config
        self.evaluation_criteria = self.load_criteria()
        
    def load_criteria(self) -> Dict[str, Any]:
        """تحميل معايير التقييم"""
        return {
            'accuracy': {
                'weight': 0.4,
                'description': 'دقة المهمة'
            },
            'efficiency': {
                'weight': 0.3,
                'description': 'كفاءة التنفيذ (عدد الخطوات)'
            },
            'completeness': {
                'weight': 0.2,
                'description': 'اكتمال المهمة'
            },
            'user_satisfaction': {
                'weight': 0.1,
                'description': 'رضا المستخدم'
            }
        }
    
    def evaluate_episode(self, episode_data: Dict[str, Any]) -> float:
        """تقييم الحلقة بأكملها"""
        
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
        
        return min(max(total_score, 0.0), 1.0)
    
    def evaluate_accuracy(self, episode_data: Dict[str, Any]) -> float:
        """تقييم الدقة"""
        if not episode_data.get('final_result'):
            return 0.0
        
        expected_result = episode_data.get('expected_result')
        actual_result = episode_data.get('final_result')
        
        if not expected_result:
            return self.heuristic_accuracy_evaluation(actual_result, episode_data)
        
        if isinstance(expected_result, str) and isinstance(actual_result, str):
            return self.string_similarity(expected_result, actual_result)
        elif isinstance(expected_result, dict) and isinstance(actual_result, dict):
            return self.dict_similarity(expected_result, actual_result)
        else:
            return 1.0 if expected_result == actual_result else 0.0
    
    def evaluate_efficiency(self, episode_data: Dict[str, Any]) -> float:
        """تقييم الكفاءة بناءً على عدد الخطوات"""
        actual_steps = len(episode_data.get('actions', []))
        optimal_steps = episode_data.get('optimal_steps', actual_steps)
        
        if actual_steps <= optimal_steps:
            return 1.0
        else:
            penalty = (actual_steps - optimal_steps) / optimal_steps
            return max(0.0, 1.0 - penalty * 0.5)
    
    def evaluate_completeness(self, episode_data: Dict[str, Any]) -> float:
        """تقييم الاكتمال"""
        required_actions = episode_data.get('required_actions', [])
        performed_actions = episode_data.get('actions', [])
        
        if not required_actions:
            return 1.0 if episode_data.get('done', False) else 0.5
        
        performed_action_types = [action.get('type') for action in performed_actions]
        completed_requirements = 0
        
        for req_action in required_actions:
            if req_action in performed_action_types:
                completed_requirements += 1
        
        return completed_requirements / len(required_actions)
    
    def evaluate_user_satisfaction(self, episode_data: Dict[str, Any]) -> float:
        """تقييم رضا المستخدم (استدلالي)"""
        error_penalty = len(episode_data.get('errors', [])) * 0.1
        
        response_time = episode_data.get('response_time', 0)
        time_penalty = max(0, (response_time - 30) / 60) * 0.2
        
        base_score = 1.0
        final_score = base_score - error_penalty - time_penalty
        
        return max(0.0, final_score)
    
    def string_similarity(self, expected: str, actual: str) -> float:
        """حساب تشابه النصوص"""
        from difflib import SequenceMatcher
        return SequenceMatcher(None, expected.lower(), actual.lower()).ratio()
    
    def dict_similarity(self, expected: dict, actual: dict) -> float:
        """حساب تشابه القواميس"""
        expected_keys = set(expected.keys())
        actual_keys = set(actual.keys())
        
        key_match = len(expected_keys & actual_keys) / len(expected_keys | actual_keys)
        
        matching_keys = expected_keys & actual_keys
        value_matches = 0
        
        for key in matching_keys:
            if expected[key] == actual[key]:
                value_matches += 1
        
        value_match = value_matches / len(matching_keys) if matching_keys else 0
        
        return (key_match + value_match) / 2
    
    def heuristic_accuracy_evaluation(self, result: Any, episode_data: Dict[str, Any]) -> float:
        """تقييم الدقة الاستدلالي"""
        task_type = episode_data.get('task_type', 'general')
        
        if task_type == 'email_search':
            return self.evaluate_email_search_accuracy(result, episode_data)
        else:
            return 0.7 if episode_data.get('done', False) else 0.3
    
    def evaluate_email_search_accuracy(self, result: Any, episode_data: Dict[str, Any]) -> float:
        """تقييم دقة البحث في البريد الإلكتروني"""
        if not result or not isinstance(result, dict):
            return 0.0
        
        if 'selected_email' not in result:
            return 0.2
        
        email = result['selected_email']
        query = episode_data.get('original_query', '').lower()
        
        content = f"{email.get('subject', '')} {email.get('body', '')}".lower()
        
        query_words = query.split()
        matches = sum(1 for word in query_words if word in content)
        keyword_score = matches / len(query_words) if query_words else 0
        
        sender_score = 0
        if 'sender' in email and any(word in email['sender'].lower() for word in query_words):
            sender_score = 0.2
        
        return min(1.0, keyword_score * 0.7 + sender_score + 0.1)

# مثال على الاستخدام
ruler_system = RULERRewardSystem({
    'task_type': 'email_search',
    'optimal_steps': 5,
    'required_actions': ['search', 'filter', 'select']
})

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

## نظام المراقبة والتسجيل

### 1. التكامل مع Weights & Biases

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
        """تهيئة تشغيل W&B"""
        self.run = wandb.init(
            project=self.project_name,
            name=self.experiment_name,
            config=config,
            tags=["ART", "GRPO", config.get("model_name", "unknown")],
            notes=f"ART training with {config.get('agent_type', 'unknown')} agent"
        )
        
        self.episode_table = wandb.Table(columns=[
            "episode_id", "total_reward", "steps", "success", "accuracy", "efficiency"
        ])
        
        self.action_table = wandb.Table(columns=[
            "episode_id", "step", "action_type", "reward", "state_description"
        ])
    
    def log_training_metrics(self, epoch: int, metrics: Dict[str, float]):
        """تسجيل مقاييس التدريب"""
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
        """تسجيل بيانات الحلقة"""
        if not self.run:
            return
            
        episode_id = episode_data.get("episode_id", "unknown")
        total_reward = episode_data.get("total_reward", 0)
        steps = episode_data.get("steps", 0)
        success = episode_data.get("success", False)
        
        accuracy = episode_data.get("accuracy_score", 0)
        efficiency = 1.0 - (steps / episode_data.get("max_steps", steps)) if steps > 0 else 0
        
        self.episode_table.add_data(
            episode_id, total_reward, steps, success, accuracy, efficiency
        )
        
        for i, action in enumerate(episode_data.get("actions", [])):
            self.action_table.add_data(
                episode_id,
                i,
                action.get("type", "unknown"),
                action.get("reward", 0),
                action.get("state_description", "")[:100]
            )
    
    def log_model_artifacts(self, model_path: str, epoch: int):
        """تسجيل مُخرجات النموذج"""
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
        """إنهاء التشغيل ورفع الجداول"""
        if not self.run:
            return
            
        self.run.log({"episodes": self.episode_table})
        self.run.log({"actions": self.action_table})
        
        wandb.finish()

logger = ARTWandbLogger("email-agent-training", "qwen2.5_email_search_v1")

config = {
    "model_name": "Qwen/Qwen2.5-7B-Instruct",
    "agent_type": "email_search",
    "learning_rate": 1e-5,
    "batch_size": 8,
    "max_episodes": 1000,
    "max_steps_per_episode": 10
}

logger.initialize_run(config)

for epoch in range(100):
    metrics = {
        "policy_loss": 0.123,
        "kl_divergence": 0.045,
        "average_reward": 0.67,
        "success_rate": 0.82
    }
    
    logger.log_training_metrics(epoch, metrics)

logger.finish_run()
```

### 2. التكامل مع Langfuse

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
        """تتبع حلقة"""
        
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
        """تتبع توليد النموذج"""
        
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
    
    def get_performance_analytics(self, trace_ids: List[str]) -> Dict[str, Any]:
        """استخراج بيانات تحليلات الأداء"""
        
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
            
            if trace.output.get("success", False):
                successful_episodes += 1
            
            reward = trace.output.get("total_reward", 0)
            total_reward += reward
            
            spans = trace.observations
            steps = len([s for s in spans if s.type == "SPAN"])
            total_steps += steps
            
            for span in spans:
                if span.type == "SPAN" and span.name.startswith("action_"):
                    action_type = span.name.split("_")[-1]
                    action_counts[action_type] = action_counts.get(action_type, 0) + 1
        
        analytics["success_rate"] = successful_episodes / len(trace_ids) if trace_ids else 0
        analytics["average_reward"] = total_reward / len(trace_ids) if trace_ids else 0
        analytics["average_steps"] = total_steps / len(trace_ids) if trace_ids else 0
        analytics["action_distribution"] = action_counts
        
        return analytics

tracker = ARTLangfuseTracker()

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

## مشروع عملي: وكيل لعبة الذكاء الاصطناعي

### 1. وكيل لعبة 2048

```python
# games/game_2048.py
import numpy as np
import random
from typing import Tuple, List, Dict, Any
from art.environment import Environment

class Game2048Environment(Environment):
    """بيئة لعبة 2048"""
    
    def __init__(self, board_size: int = 4):
        super().__init__()
        self.board_size = board_size
        self.board = None
        self.score = 0
        self.moves_count = 0
        
    async def reset(self) -> Dict[str, Any]:
        """تهيئة اللعبة"""
        self.board = np.zeros((self.board_size, self.board_size), dtype=int)
        self.score = 0
        self.moves_count = 0
        
        self.add_random_tile()
        self.add_random_tile()
        
        return await self.get_state()
    
    async def step(self, action: Dict[str, Any]) -> Tuple[Dict, float, bool, Dict]:
        """تنفيذ الإجراء"""
        direction = action.get('direction')
        
        prev_board = self.board.copy()
        prev_score = self.score
        
        moved = self.move(direction)
        
        if moved:
            self.add_random_tile()
            self.moves_count += 1
        
        reward = self.calculate_reward(prev_board, prev_score, moved)
        done = self.is_game_over()
        
        state = await self.get_state()
        info = {
            'moved': moved,
            'score_increase': self.score - prev_score,
            'max_tile': np.max(self.board)
        }
        
        return state, reward, done, info
    
    def move(self, direction: str) -> bool:
        """تحريك ودمج اللوحة"""
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
        """التحرك لليسار"""
        moved = False
        for i in range(self.board_size):
            row = self.board[i, :]
            new_row, row_moved = self.merge_line(row)
            self.board[i, :] = new_row
            if row_moved:
                moved = True
        return moved
    
    def move_right(self) -> bool:
        """التحرك لليمين"""
        moved = False
        for i in range(self.board_size):
            row = self.board[i, ::-1]
            new_row, row_moved = self.merge_line(row)
            self.board[i, :] = new_row[::-1]
            if row_moved:
                moved = True
        return moved
    
    def move_up(self) -> bool:
        """التحرك للأعلى"""
        moved = False
        for j in range(self.board_size):
            col = self.board[:, j]
            new_col, col_moved = self.merge_line(col)
            self.board[:, j] = new_col
            if col_moved:
                moved = True
        return moved
    
    def move_down(self) -> bool:
        """التحرك للأسفل"""
        moved = False
        for j in range(self.board_size):
            col = self.board[::-1, j]
            new_col, col_moved = self.merge_line(col)
            self.board[:, j] = new_col[::-1]
            if col_moved:
                moved = True
        return moved
    
    def merge_line(self, line: np.ndarray) -> Tuple[np.ndarray, bool]:
        """منطق دمج الصف"""
        non_zero = line[line != 0]
        
        merged = []
        i = 0
        while i < len(non_zero):
            if i < len(non_zero) - 1 and non_zero[i] == non_zero[i + 1]:
                merged_value = non_zero[i] * 2
                merged.append(merged_value)
                self.score += merged_value
                i += 2
            else:
                merged.append(non_zero[i])
                i += 1
        
        result = np.zeros(self.board_size, dtype=int)
        result[:len(merged)] = merged
        
        moved = not np.array_equal(line, result)
        
        return result, moved
    
    def add_random_tile(self):
        """إضافة 2 أو 4 في موضع عشوائي"""
        empty_cells = [(i, j) for i in range(self.board_size) 
                      for j in range(self.board_size) if self.board[i, j] == 0]
        
        if empty_cells:
            i, j = random.choice(empty_cells)
            self.board[i, j] = 2 if random.random() < 0.9 else 4
    
    def is_game_over(self) -> bool:
        """التحقق من انتهاء اللعبة"""
        if np.any(self.board == 0):
            return False
        
        for i in range(self.board_size):
            for j in range(self.board_size):
                current = self.board[i, j]
                
                if j < self.board_size - 1 and self.board[i, j + 1] == current:
                    return False
                
                if i < self.board_size - 1 and self.board[i + 1, j] == current:
                    return False
        
        return True
    
    def calculate_reward(self, prev_board: np.ndarray, prev_score: int, moved: bool) -> float:
        """حساب المكافأة"""
        if not moved:
            return -0.1
        
        score_reward = (self.score - prev_score) / 100.0
        
        empty_cells = np.sum(self.board == 0)
        empty_reward = empty_cells * 0.01
        
        max_tile = np.max(self.board)
        max_tile_reward = np.log2(max_tile) * 0.1 if max_tile > 0 else 0
        
        smoothness = self.calculate_smoothness()
        smoothness_reward = smoothness * 0.05
        
        total_reward = score_reward + empty_reward + max_tile_reward + smoothness_reward
        
        return total_reward
    
    def calculate_smoothness(self) -> float:
        """حساب نعومة اللوحة"""
        smoothness = 0
        
        for i in range(self.board_size):
            for j in range(self.board_size):
                if self.board[i, j] != 0:
                    value = np.log2(self.board[i, j])
                    
                    if j < self.board_size - 1 and self.board[i, j + 1] != 0:
                        target_value = np.log2(self.board[i, j + 1])
                        smoothness -= abs(value - target_value)
                    
                    if i < self.board_size - 1 and self.board[i + 1, j] != 0:
                        target_value = np.log2(self.board[i + 1, j])
                        smoothness -= abs(value - target_value)
        
        return smoothness
    
    async def get_state(self) -> Dict[str, Any]:
        """إرجاع الحالة الحالية"""
        return {
            'board': self.board.tolist(),
            'score': self.score,
            'moves_count': self.moves_count,
            'max_tile': int(np.max(self.board)),
            'empty_cells': int(np.sum(self.board == 0)),
            'available_moves': self.get_available_moves()
        }
    
    def get_available_moves(self) -> List[str]:
        """إرجاع اتجاهات الحركة المتاحة"""
        moves = []
        
        for direction in ['up', 'down', 'left', 'right']:
            temp_board = self.board.copy()
            temp_env = Game2048Environment(self.board_size)
            temp_env.board = temp_board
            
            if temp_env.move(direction):
                moves.append(direction)
        
        return moves

class Game2048Agent(Agent):
    """وكيل لعبة 2048"""
    
    def __init__(self, model_name: str = "Qwen/Qwen2.5-7B-Instruct"):
        super().__init__(model_name)
        self.strategy = "minimax"
        
    async def select_action(self, state: Dict[str, Any]) -> Dict[str, Any]:
        """اختيار الإجراء"""
        
        if self.strategy == "minimax":
            return await self.minimax_action(state)
        else:
            return await self.ml_based_action(state)
    
    async def minimax_action(self, state: Dict[str, Any]) -> Dict[str, Any]:
        """اختيار الإجراء باستخدام minimax"""
        board = np.array(state['board'])
        available_moves = state['available_moves']
        
        if not available_moves:
            return {'direction': 'up', 'reasoning': 'No moves available'}
        
        best_move = None
        best_score = -float('inf')
        
        for move in available_moves:
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
        """تقييم الحركة (minimax)"""
        if depth == 0:
            return self.evaluate_board(board)
        
        temp_env = Game2048Environment(board.shape[0])
        temp_env.board = board.copy()
        
        if not temp_env.move(direction):
            return -1000
        
        empty_cells = [(i, j) for i in range(board.shape[0]) 
                      for j in range(board.shape[0]) if temp_env.board[i, j] == 0]
        
        if not empty_cells:
            return self.evaluate_board(temp_env.board)
        
        total_score = 0
        for i, j in empty_cells:
            for value in [2, 4]:
                prob = 0.9 if value == 2 else 0.1
                
                temp_env.board[i, j] = value
                
                next_score = max([
                    self.evaluate_move(temp_env.board, next_dir, depth - 1)
                    for next_dir in ['up', 'down', 'left', 'right']
                ])
                
                total_score += prob * next_score
                
                temp_env.board[i, j] = 0
        
        return total_score / len(empty_cells)
    
    def evaluate_board(self, board: np.ndarray) -> float:
        """دالة تقييم اللوحة"""
        empty_score = np.sum(board == 0) * 10
        
        max_tile = np.max(board)
        max_score = np.log2(max_tile) * 100 if max_tile > 0 else 0
        
        smoothness = self.calculate_smoothness(board) * 50
        
        monotonicity = self.calculate_monotonicity(board) * 100
        
        return empty_score + max_score + smoothness + monotonicity
    
    def calculate_smoothness(self, board: np.ndarray) -> float:
        """حساب النعومة"""
        smoothness = 0
        size = board.shape[0]
        
        for i in range(size):
            for j in range(size):
                if board[i, j] != 0:
                    value = np.log2(board[i, j])
                    
                    for di, dj in [(0, 1), (1, 0)]:
                        ni, nj = i + di, j + dj
                        if ni < size and nj < size and board[ni, nj] != 0:
                            target_value = np.log2(board[ni, nj])
                            smoothness -= abs(value - target_value)
        
        return smoothness
    
    def calculate_monotonicity(self, board: np.ndarray) -> float:
        """حساب الرتابة"""
        totals = [0, 0, 0, 0]
        
        for i in range(board.shape[0]):
            current = 0
            next_val = 1
            
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

async def train_2048_agent():
    """تدريب وكيل 2048"""
    
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

## الخلاصة

**OpenPipe ART (Agent Reinforcement Trainer)** إطار عمل متقدم لتدريب وكلاء الذكاء الاصطناعي متعددة الخطوات في بيئات العمل الحقيقية.

### النتائج الرئيسية

1. **خوارزمية GRPO**: تدريب تعلم تعزيزي مستقر وفعال
2. **القابلية للإنتاج**: دعم مهام حقيقية متنوعة تشمل البحث في البريد الإلكتروني والألعاب والبرمجة
3. **قابلية التوسع**: تدريب موزع واسع النطاق ببنية Client-Server
4. **الأتمتة**: يُغني تكامل RULER عن هندسة دوال المكافأة يدويًا

### نقاط التطبيق العملي

- **الشركات الناشئة**: تطوير وكلاء ذكاء اصطناعي عملية بموارد محدودة
- **المؤسسات**: تدريب وكلاء متخصصة لأتمتة سير العمل
- **مؤسسات البحث**: منصة بحث للتعلم التعزيزي متعدد الخطوات
- **المطورون**: وكلاء ذكية قابلة للتكامل مع الألعاب والأدوات والخدمات

### الخطوات التالية

1. **ابدأ بالمثال الأساسي**: انطلق من وكيل البحث في البريد الإلكتروني
2. **بيئات مخصصة**: نفِّذ بيئة المهمة الخاصة بك
3. **النشر في الإنتاج**: ادمج الوكلاء في الخدمات الحقيقية
4. **المساهمة في المجتمع**: شارك في تطوير [OpenPipe ART GitHub](https://github.com/OpenPipe/ART)

طوِّر وكلاء ذكاء اصطناعي إنتاجية من الجيل التالي باستخدام OpenPipe ART!

---

**المراجع**:
- [OpenPipe ART GitHub](https://github.com/OpenPipe/ART)
- [GRPO Paper](https://arxiv.org/abs/2402.03300)
- [OpenPipe Official Documentation](https://docs.openpipe.ai/)
- [Langfuse Integration Guide](https://langfuse.com/docs)
