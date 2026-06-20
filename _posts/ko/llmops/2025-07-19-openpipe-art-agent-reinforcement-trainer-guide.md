---
title: "OpenPipe ART: 실전 에이전트 강화학습 프레임워크 완벽 가이드"
excerpt: "GRPO를 활용한 멀티스텝 에이전트 훈련부터 실제 업무 태스크 적용까지. Qwen, Llama, Kimi 모델로 실무형 AI 에이전트 개발하기"
seo_title: "OpenPipe ART 강화학습 에이전트 가이드 - GRPO 멀티스텝 훈련 - Thaki Cloud"
seo_description: "OpenPipe ART로 실전 AI 에이전트 강화학습하기. GRPO 알고리즘, 멀티스텝 훈련, RULER 보상함수, vLLM 통합까지 완벽 가이드"
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
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/llmops/openpipe-art-agent-reinforcement-trainer-guide/"
reading_time: true
published: false
---

⏱️ **예상 읽기 시간**: 30분

## 서론

**OpenPipe ART (Agent Reinforcement Trainer)**는 실제 업무 환경에서 멀티스텝 AI 에이전트를 훈련할 수 있는 혁신적인 강화학습 프레임워크입니다. **GRPO (Group Relative Policy Optimization)** 알고리즘을 활용하여 Qwen2.5, Qwen3, Llama, Kimi 등 다양한 언어모델로 실무형 에이전트를 개발할 수 있습니다.

### ART의 핵심 특징

- 🚀 **GRPO 알고리즘**: 그룹 상대 정책 최적화로 안정적인 멀티스텝 학습
- 🎯 **실무 중심**: 이메일 검색, 게임, 코딩 등 실제 태스크에서 훈련
- 🔧 **RULER 통합**: 보상함수 엔지니어링 없이 자동 평가 시스템
- 🌐 **클라이언트-서버**: 분산 환경에서 확장 가능한 아키텍처
- 📊 **모니터링**: W&B, Langfuse, OpenPipe 완전 통합

### 지원 모델

| 모델 패밀리 | 지원 버전 | 특징 |
|------------|----------|------|
| **Qwen** | 2.5, 3.0 | 중국어/영어 멀티모달 지원 |
| **Llama** | 3.1, 3.2 | Meta의 오픈소스 모델 |
| **Kimi** | Latest | 롱 컨텍스트 특화 |
| **HuggingFace** | 모든 호환 모델 | 커스텀 모델 지원 |

## 환경 설정 및 설치

### 1. 기본 요구사항

```bash
# Python 3.8+ 필요
python --version

# CUDA 지원 확인 (선택사항)
nvidia-smi

# Git 설치 확인
git --version
```

### 2. OpenPipe ART 설치

```bash
# 저장소 클론
git clone https://github.com/OpenPipe/ART.git
cd ART

# 가상환경 생성 및 활성화
python -m venv venv_art
source venv_art/bin/activate  # macOS/Linux
# venv_art\Scripts\activate  # Windows

# 의존성 설치
pip install -r requirements.txt

# 개발용 설치 (선택사항)
pip install -e .
```

### 3. 환경 변수 설정

```bash
# .env 파일 생성
cat > .env << 'EOF'
# 모델 설정
OPENAI_API_KEY=your_openai_api_key
OPENPIPE_API_KEY=your_openpipe_api_key

# 모니터링 설정
WANDB_API_KEY=your_wandb_api_key
LANGFUSE_SECRET_KEY=your_langfuse_secret_key
LANGFUSE_PUBLIC_KEY=your_langfuse_public_key
LANGFUSE_HOST=https://cloud.langfuse.com

# 훈련 설정
ART_SERVER_PORT=8000
ART_CLIENT_WORKERS=4
EOF

# 환경 변수 로드
source .env
```

## GRPO 알고리즘 이해

### GRPO란?

**Group Relative Policy Optimization**은 ART의 핵심 알고리즘으로, 멀티스텝 에이전트 훈련에 특화된 강화학습 기법입니다.

```python
# GRPO 핵심 개념 코드 예시
import torch
import torch.nn.functional as F

class GRPOTrainer:
    def __init__(self, model, reference_model, beta=0.1):
        self.model = model
        self.reference_model = reference_model
        self.beta = beta  # KL divergence 가중치
    
    def compute_grpo_loss(self, states, actions, rewards, group_baselines):
        """GRPO 손실 함수 계산"""
        
        # 현재 정책의 로그 확률
        current_logprobs = self.model.get_log_probs(states, actions)
        
        # 참조 모델의 로그 확률
        with torch.no_grad():
            reference_logprobs = self.reference_model.get_log_probs(states, actions)
        
        # KL divergence 페널티
        kl_penalty = self.beta * (current_logprobs - reference_logprobs)
        
        # 그룹 상대적 이점 계산
        group_advantages = rewards - group_baselines
        
        # GRPO 손실
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

### GRPO vs PPO 비교

| 특징 | GRPO | PPO |
|------|------|-----|
| **멀티스텝 학습** | 특화됨 | 단일 스텝 중심 |
| **그룹 기반 평가** | 지원 | 개별 평가 |
| **안정성** | 높음 | 보통 |
| **수렴 속도** | 빠름 | 보통 |

## 실전 예제: 이메일 검색 에이전트

### 1. ART•E [RULER] 예제 분석

가장 실용적인 예제인 이메일 검색 에이전트를 구현해봅시다.

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
        """환경 초기화"""
        self.current_query = self.sample_query()
        self.search_history = []
        
        return {
            'query': self.current_query,
            'available_actions': ['search', 'filter', 'sort', 'select'],
            'search_results': [],
            'step': 0
        }
    
    async def step(self, action: Dict[str, Any]) -> tuple:
        """액션 실행 및 상태 업데이트"""
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
        """이메일 검색 로직"""
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
        """검색 결과 기반 보상 계산"""
        if not results:
            return -0.1  # 결과 없음 페널티
        
        # 관련성 점수 기반 보상
        relevance_scores = [r['relevance_score'] for r in results[:5]]
        avg_relevance = sum(relevance_scores) / len(relevance_scores)
        
        # 다양성 보너스
        diversity_bonus = len(set(r['sender'] for r in results[:10])) * 0.01
        
        return min(avg_relevance * 0.1 + diversity_bonus, 1.0)

class EmailSearchAgent(Agent):
    def __init__(self, model_name: str = "Qwen/Qwen2.5-7B-Instruct"):
        super().__init__(model_name)
        self.action_history = []
        
    async def select_action(self, state: Dict[str, Any]) -> Dict[str, Any]:
        """상태 기반 액션 선택"""
        
        # 시스템 프롬프트 구성
        system_prompt = """
        당신은 이메일 검색 전문가입니다. 사용자의 요청에 맞는 이메일을 찾기 위해
        다음 액션들을 순차적으로 수행할 수 있습니다:
        
        1. search: 키워드로 이메일 검색
        2. filter: 검색 결과를 필터링 (날짜, 발신자 등)
        3. sort: 결과 정렬 (관련성, 날짜 등)
        4. select: 최종 이메일 선택
        
        각 단계에서 최적의 액션을 선택하여 사용자가 원하는 이메일을 찾아주세요.
        """
        
        # 현재 상태 설명
        state_description = f"""
        현재 상황:
        - 검색 쿼리: {state['query']}
        - 현재 단계: {state['step']}
        - 사용 가능한 액션: {state['available_actions']}
        - 검색 결과 수: {len(state.get('search_results', []))}
        """
        
        # 모델에게 액션 요청
        response = await self.generate_response(
            system_prompt + state_description,
            max_tokens=150,
            temperature=0.7
        )
        
        # 응답 파싱
        action = self.parse_action(response, state)
        self.action_history.append(action)
        
        return action
    
    def parse_action(self, response: str, state: Dict[str, Any]) -> Dict[str, Any]:
        """모델 응답을 액션으로 파싱"""
        response_lower = response.lower()
        
        if 'search' in response_lower and state['step'] == 0:
            # 검색 키워드 추출
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
        
        # 기본 액션
        return {
            'type': 'search',
            'query': state['query'],
            'reasoning': 'Default search action'
        }
```

### 2. 훈련 스크립트

```python
# train_email_agent.py
import asyncio
import json
from art.trainer import GRPOTrainer
from art.environment import Environment
from email_agent import EmailSearchEnvironment, EmailSearchAgent

async def train_email_agent():
    """이메일 검색 에이전트 훈련"""
    
    # 이메일 데이터베이스 로드
    with open('email_database.json', 'r') as f:
        email_db = json.load(f)
    
    # 환경 및 에이전트 초기화
    env = EmailSearchEnvironment(email_db)
    agent = EmailSearchAgent("Qwen/Qwen2.5-7B-Instruct")
    
    # 훈련 설정
    trainer = GRPOTrainer(
        agent=agent,
        environment=env,
        learning_rate=1e-5,
        batch_size=8,
        episodes_per_batch=32,
        max_episode_length=10,
        kl_penalty=0.1
    )
    
    # 훈련 실행
    for epoch in range(100):
        print(f"Epoch {epoch + 1}/100")
        
        # 에피소드 수집
        episodes = await trainer.collect_episodes()
        
        # 모델 업데이트
        loss_info = await trainer.update_policy(episodes)
        
        # 로깅
        if epoch % 10 == 0:
            print(f"Policy Loss: {loss_info['policy_loss']:.4f}")
            print(f"KL Divergence: {loss_info['kl_loss']:.4f}")
            print(f"Average Reward: {loss_info['avg_reward']:.4f}")
            
            # 체크포인트 저장
            await trainer.save_checkpoint(f"checkpoint_epoch_{epoch}.pt")
    
    print("Training completed!")

if __name__ == "__main__":
    asyncio.run(train_email_agent())
```

### 3. 평가 스크립트

```python
# evaluate_email_agent.py
import asyncio
import json
from email_agent import EmailSearchEnvironment, EmailSearchAgent

async def evaluate_agent():
    """훈련된 에이전트 평가"""
    
    # 테스트 데이터 로드
    with open('test_queries.json', 'r') as f:
        test_queries = json.load(f)
    
    with open('email_database.json', 'r') as f:
        email_db = json.load(f)
    
    # 환경 및 에이전트 초기화
    env = EmailSearchEnvironment(email_db)
    agent = EmailSearchAgent("Qwen/Qwen2.5-7B-Instruct")
    
    # 체크포인트 로드
    agent.load_checkpoint("best_checkpoint.pt")
    
    total_success = 0
    total_queries = len(test_queries)
    
    for i, query_data in enumerate(test_queries):
        print(f"Testing query {i+1}/{total_queries}: {query_data['query']}")
        
        # 환경 초기화
        state = await env.reset()
        state['query'] = query_data['query']
        
        done = False
        step_count = 0
        max_steps = 10
        
        while not done and step_count < max_steps:
            # 에이전트 액션 선택
            action = await agent.select_action(state)
            
            # 환경에서 액션 실행
            state, reward, done, info = await env.step(action)
            step_count += 1
            
            print(f"  Step {step_count}: {action['type']} - Reward: {reward:.3f}")
        
        # 성공 여부 판단
        if done and reward > 0.5:  # 성공 임계값
            total_success += 1
            print(f"  ✅ Success!")
        else:
            print(f"  ❌ Failed")
    
    success_rate = total_success / total_queries
    print(f"\nOverall Success Rate: {success_rate:.2%}")

if __name__ == "__main__":
    asyncio.run(evaluate_agent())
```

## 클라이언트-서버 아키텍처

### 1. 서버 설정

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
        """클라이언트 등록"""
        self.active_clients[client_id] = websocket
        print(f"Client {client_id} connected")
    
    async def distribute_episodes(self, episodes: List[Dict]):
        """에피소드를 클라이언트들에게 분산"""
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
        """특정 클라이언트에게 메시지 전송"""
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
    """훈련 대시보드"""
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
            // 실시간 상태 업데이트 로직
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
    """서버 상태 API"""
    return {
        "active_clients": len(server.active_clients),
        "episodes_queued": len(server.training_queue),
        "results_available": len(server.results_queue)
    }

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

### 2. 클라이언트 설정

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
        """서버에 연결"""
        self.websocket = await websockets.connect(self.server_url)
        print(f"Client {self.client_id} connected to server")
        
        # 상태 업데이트 전송
        await self.send_message({
            'type': 'status_update',
            'status': 'connected',
            'client_id': self.client_id
        })
    
    async def send_message(self, message: dict):
        """서버에 메시지 전송"""
        await self.websocket.send(json.dumps(message))
    
    async def handle_server_messages(self):
        """서버 메시지 처리"""
        async for message in self.websocket:
            data = json.loads(message)
            
            if data['type'] == 'train_episodes':
                await self.process_episodes(data['episodes'])
            elif data['type'] == 'update_model':
                await self.update_model(data['model_state'])
            elif data['type'] == 'shutdown':
                break
    
    async def process_episodes(self, episodes: list):
        """에피소드 처리 및 훈련"""
        print(f"Processing {len(episodes)} episodes")
        
        results = []
        for episode in episodes:
            # 에피소드 실행
            result = await self.run_episode(episode)
            results.append(result)
        
        # 결과를 서버로 전송
        await self.send_message({
            'type': 'episode_result',
            'results': results,
            'client_id': self.client_id
        })
    
    async def run_episode(self, episode_config: dict):
        """단일 에피소드 실행"""
        if not self.agent or not self.environment:
            # 에이전트와 환경 초기화
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
            # 에이전트 액션 선택
            action = await self.agent.select_action(state)
            
            # 환경에서 액션 실행
            next_state, reward, done, info = await self.environment.step(action)
            
            # 데이터 수집
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
    """클라이언트 시작"""
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

## RULER 통합 보상 시스템

### 1. RULER 기반 자동 평가

```python
# ruler_evaluator.py
from typing import Dict, List, Any
import json
import re

class RULERRewardSystem:
    """RULER 기반 자동 보상 계산 시스템"""
    
    def __init__(self, task_config: Dict[str, Any]):
        self.task_config = task_config
        self.evaluation_criteria = self.load_criteria()
        
    def load_criteria(self) -> Dict[str, Any]:
        """평가 기준 로드"""
        return {
            'accuracy': {
                'weight': 0.4,
                'description': '작업 정확도'
            },
            'efficiency': {
                'weight': 0.3,
                'description': '실행 효율성 (단계 수)'
            },
            'completeness': {
                'weight': 0.2,
                'description': '작업 완성도'
            },
            'user_satisfaction': {
                'weight': 0.1,
                'description': '사용자 만족도'
            }
        }
    
    def evaluate_episode(self, episode_data: Dict[str, Any]) -> float:
        """에피소드 전체 평가"""
        
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
        
        return min(max(total_score, 0.0), 1.0)  # 0-1 범위로 클램핑
    
    def evaluate_accuracy(self, episode_data: Dict[str, Any]) -> float:
        """정확도 평가"""
        if not episode_data.get('final_result'):
            return 0.0
        
        expected_result = episode_data.get('expected_result')
        actual_result = episode_data.get('final_result')
        
        if not expected_result:
            # 휴리스틱 평가
            return self.heuristic_accuracy_evaluation(actual_result, episode_data)
        
        # 직접 비교
        if isinstance(expected_result, str) and isinstance(actual_result, str):
            return self.string_similarity(expected_result, actual_result)
        elif isinstance(expected_result, dict) and isinstance(actual_result, dict):
            return self.dict_similarity(expected_result, actual_result)
        else:
            return 1.0 if expected_result == actual_result else 0.0
    
    def evaluate_efficiency(self, episode_data: Dict[str, Any]) -> float:
        """효율성 평가 (단계 수 기반)"""
        actual_steps = len(episode_data.get('actions', []))
        optimal_steps = episode_data.get('optimal_steps', actual_steps)
        
        if actual_steps <= optimal_steps:
            return 1.0
        else:
            # 단계 수가 증가할수록 점수 감소
            penalty = (actual_steps - optimal_steps) / optimal_steps
            return max(0.0, 1.0 - penalty * 0.5)
    
    def evaluate_completeness(self, episode_data: Dict[str, Any]) -> float:
        """완성도 평가"""
        required_actions = episode_data.get('required_actions', [])
        performed_actions = episode_data.get('actions', [])
        
        if not required_actions:
            return 1.0 if episode_data.get('done', False) else 0.5
        
        # 필수 액션 수행 여부 확인
        performed_action_types = [action.get('type') for action in performed_actions]
        completed_requirements = 0
        
        for req_action in required_actions:
            if req_action in performed_action_types:
                completed_requirements += 1
        
        return completed_requirements / len(required_actions)
    
    def evaluate_user_satisfaction(self, episode_data: Dict[str, Any]) -> float:
        """사용자 만족도 평가 (휴리스틱)"""
        # 에러 발생 여부
        error_penalty = len(episode_data.get('errors', [])) * 0.1
        
        # 응답 시간 고려
        response_time = episode_data.get('response_time', 0)
        time_penalty = max(0, (response_time - 30) / 60) * 0.2  # 30초 초과시 페널티
        
        # 기본 점수에서 페널티 차감
        base_score = 1.0
        final_score = base_score - error_penalty - time_penalty
        
        return max(0.0, final_score)
    
    def string_similarity(self, expected: str, actual: str) -> float:
        """문자열 유사도 계산"""
        from difflib import SequenceMatcher
        return SequenceMatcher(None, expected.lower(), actual.lower()).ratio()
    
    def dict_similarity(self, expected: dict, actual: dict) -> float:
        """딕셔너리 유사도 계산"""
        expected_keys = set(expected.keys())
        actual_keys = set(actual.keys())
        
        # 키 일치율
        key_match = len(expected_keys & actual_keys) / len(expected_keys | actual_keys)
        
        # 값 일치율
        matching_keys = expected_keys & actual_keys
        value_matches = 0
        
        for key in matching_keys:
            if expected[key] == actual[key]:
                value_matches += 1
        
        value_match = value_matches / len(matching_keys) if matching_keys else 0
        
        return (key_match + value_match) / 2
    
    def heuristic_accuracy_evaluation(self, result: Any, episode_data: Dict[str, Any]) -> float:
        """휴리스틱 정확도 평가"""
        # 작업 유형별 휴리스틱 평가
        task_type = episode_data.get('task_type', 'general')
        
        if task_type == 'email_search':
            return self.evaluate_email_search_accuracy(result, episode_data)
        elif task_type == 'code_generation':
            return self.evaluate_code_accuracy(result, episode_data)
        elif task_type == 'question_answering':
            return self.evaluate_qa_accuracy(result, episode_data)
        else:
            # 일반적인 휴리스틱
            return 0.7 if episode_data.get('done', False) else 0.3
    
    def evaluate_email_search_accuracy(self, result: Any, episode_data: Dict[str, Any]) -> float:
        """이메일 검색 정확도 평가"""
        if not result or not isinstance(result, dict):
            return 0.0
        
        # 이메일이 선택되었는지 확인
        if 'selected_email' not in result:
            return 0.2
        
        email = result['selected_email']
        query = episode_data.get('original_query', '').lower()
        
        # 이메일 내용과 쿼리의 관련성 확인
        content = f"{email.get('subject', '')} {email.get('body', '')}".lower()
        
        # 키워드 매칭 점수
        query_words = query.split()
        matches = sum(1 for word in query_words if word in content)
        keyword_score = matches / len(query_words) if query_words else 0
        
        # 발신자 관련성 (있다면)
        sender_score = 0
        if 'sender' in email and any(word in email['sender'].lower() for word in query_words):
            sender_score = 0.2
        
        return min(1.0, keyword_score * 0.7 + sender_score + 0.1)  # 기본 점수 0.1

# 사용 예시
ruler_system = RULERRewardSystem({
    'task_type': 'email_search',
    'optimal_steps': 5,
    'required_actions': ['search', 'filter', 'select']
})

# 에피소드 데이터 예시
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

## 모니터링 및 로깅 시스템

### 1. Weights & Biases 통합

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
        """W&B 실행 초기화"""
        self.run = wandb.init(
            project=self.project_name,
            name=self.experiment_name,
            config=config,
            tags=["ART", "GRPO", config.get("model_name", "unknown")],
            notes=f"ART training with {config.get('agent_type', 'unknown')} agent"
        )
        
        # 아티팩트 추적을 위한 테이블 생성
        self.episode_table = wandb.Table(columns=[
            "episode_id", "total_reward", "steps", "success", "accuracy", "efficiency"
        ])
        
        self.action_table = wandb.Table(columns=[
            "episode_id", "step", "action_type", "reward", "state_description"
        ])
    
    def log_training_metrics(self, epoch: int, metrics: Dict[str, float]):
        """훈련 메트릭 로깅"""
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
        """에피소드 데이터 로깅"""
        if not self.run:
            return
            
        episode_id = episode_data.get("episode_id", "unknown")
        total_reward = episode_data.get("total_reward", 0)
        steps = episode_data.get("steps", 0)
        success = episode_data.get("success", False)
        
        # 메트릭 계산
        accuracy = episode_data.get("accuracy_score", 0)
        efficiency = 1.0 - (steps / episode_data.get("max_steps", steps)) if steps > 0 else 0
        
        # 에피소드 테이블에 추가
        self.episode_table.add_data(
            episode_id, total_reward, steps, success, accuracy, efficiency
        )
        
        # 액션별 세부 로깅
        for i, action in enumerate(episode_data.get("actions", [])):
            self.action_table.add_data(
                episode_id,
                i,
                action.get("type", "unknown"),
                action.get("reward", 0),
                action.get("state_description", "")[:100]  # 처음 100자만
            )
    
    def log_model_artifacts(self, model_path: str, epoch: int):
        """모델 아티팩트 로깅"""
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
        """실행 종료 및 테이블 업로드"""
        if not self.run:
            return
            
        # 테이블 업로드
        self.run.log({"episodes": self.episode_table})
        self.run.log({"actions": self.action_table})
        
        # 실행 종료
        wandb.finish()

# 사용 예시
logger = ARTWandbLogger("email-agent-training", "qwen2.5_email_search_v1")

# 설정으로 실행 초기화
config = {
    "model_name": "Qwen/Qwen2.5-7B-Instruct",
    "agent_type": "email_search",
    "learning_rate": 1e-5,
    "batch_size": 8,
    "max_episodes": 1000,
    "max_steps_per_episode": 10
}

logger.initialize_run(config)

# 훈련 중 메트릭 로깅
for epoch in range(100):
    # ... 훈련 로직 ...
    
    metrics = {
        "policy_loss": 0.123,
        "kl_divergence": 0.045,
        "average_reward": 0.67,
        "success_rate": 0.82
    }
    
    logger.log_training_metrics(epoch, metrics)

logger.finish_run()
```

### 2. Langfuse 통합

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
        """에피소드 추적"""
        
        # 에피소드를 하나의 트레이스로 생성
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
        
        # 각 액션을 개별 스팬으로 추적
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
        """모델 생성 추적"""
        
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
        """훈련 세션 추적"""
        
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
        """성능 분석 데이터 추출"""
        
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
            
            # 성공률 계산
            if trace.output.get("success", False):
                successful_episodes += 1
            
            # 보상 누적
            reward = trace.output.get("total_reward", 0)
            total_reward += reward
            
            # 스텝 수 계산
            spans = trace.observations
            steps = len([s for s in spans if s.type == "SPAN"])
            total_steps += steps
            
            # 액션 분포 계산
            for span in spans:
                if span.type == "SPAN" and span.name.startswith("action_"):
                    action_type = span.name.split("_")[-1]
                    action_counts[action_type] = action_counts.get(action_type, 0) + 1
        
        # 분석 결과 계산
        analytics["success_rate"] = successful_episodes / len(trace_ids) if trace_ids else 0
        analytics["average_reward"] = total_reward / len(trace_ids) if trace_ids else 0
        analytics["average_steps"] = total_steps / len(trace_ids) if trace_ids else 0
        analytics["action_distribution"] = action_counts
        
        return analytics

# 사용 예시
tracker = ARTLangfuseTracker()

# 에피소드 추적
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

## 실전 프로젝트: 게임 AI 에이전트

### 1. 2048 게임 에이전트

```python
# games/game_2048.py
import numpy as np
import random
from typing import Tuple, List, Dict, Any
from art.environment import Environment

class Game2048Environment(Environment):
    """2048 게임 환경"""
    
    def __init__(self, board_size: int = 4):
        super().__init__()
        self.board_size = board_size
        self.board = None
        self.score = 0
        self.moves_count = 0
        
    async def reset(self) -> Dict[str, Any]:
        """게임 초기화"""
        self.board = np.zeros((self.board_size, self.board_size), dtype=int)
        self.score = 0
        self.moves_count = 0
        
        # 초기 2개 숫자 배치
        self.add_random_tile()
        self.add_random_tile()
        
        return await self.get_state()
    
    async def step(self, action: Dict[str, Any]) -> Tuple[Dict, float, bool, Dict]:
        """액션 실행"""
        direction = action.get('direction')  # 'up', 'down', 'left', 'right'
        
        prev_board = self.board.copy()
        prev_score = self.score
        
        # 이동 실행
        moved = self.move(direction)
        
        if moved:
            self.add_random_tile()
            self.moves_count += 1
        
        # 보상 계산
        reward = self.calculate_reward(prev_board, prev_score, moved)
        
        # 게임 종료 확인
        done = self.is_game_over()
        
        state = await self.get_state()
        info = {
            'moved': moved,
            'score_increase': self.score - prev_score,
            'max_tile': np.max(self.board)
        }
        
        return state, reward, done, info
    
    def move(self, direction: str) -> bool:
        """보드 이동 및 합치기"""
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
        """왼쪽으로 이동"""
        moved = False
        for i in range(self.board_size):
            row = self.board[i, :]
            new_row, row_moved = self.merge_line(row)
            self.board[i, :] = new_row
            if row_moved:
                moved = True
        return moved
    
    def move_right(self) -> bool:
        """오른쪽으로 이동"""
        moved = False
        for i in range(self.board_size):
            row = self.board[i, ::-1]  # 뒤집기
            new_row, row_moved = self.merge_line(row)
            self.board[i, :] = new_row[::-1]  # 다시 뒤집기
            if row_moved:
                moved = True
        return moved
    
    def move_up(self) -> bool:
        """위로 이동"""
        moved = False
        for j in range(self.board_size):
            col = self.board[:, j]
            new_col, col_moved = self.merge_line(col)
            self.board[:, j] = new_col
            if col_moved:
                moved = True
        return moved
    
    def move_down(self) -> bool:
        """아래로 이동"""
        moved = False
        for j in range(self.board_size):
            col = self.board[::-1, j]  # 뒤집기
            new_col, col_moved = self.merge_line(col)
            self.board[:, j] = new_col[::-1]  # 다시 뒤집기
            if col_moved:
                moved = True
        return moved
    
    def merge_line(self, line: np.ndarray) -> Tuple[np.ndarray, bool]:
        """한 줄 합치기 로직"""
        # 0이 아닌 요소들을 왼쪽으로 이동
        non_zero = line[line != 0]
        
        # 인접한 같은 숫자 합치기
        merged = []
        i = 0
        while i < len(non_zero):
            if i < len(non_zero) - 1 and non_zero[i] == non_zero[i + 1]:
                # 합치기
                merged_value = non_zero[i] * 2
                merged.append(merged_value)
                self.score += merged_value
                i += 2
            else:
                merged.append(non_zero[i])
                i += 1
        
        # 결과 배열 생성
        result = np.zeros(self.board_size, dtype=int)
        result[:len(merged)] = merged
        
        # 변화 여부 확인
        moved = not np.array_equal(line, result)
        
        return result, moved
    
    def add_random_tile(self):
        """무작위 위치에 2 또는 4 추가"""
        empty_cells = [(i, j) for i in range(self.board_size) 
                      for j in range(self.board_size) if self.board[i, j] == 0]
        
        if empty_cells:
            i, j = random.choice(empty_cells)
            self.board[i, j] = 2 if random.random() < 0.9 else 4
    
    def is_game_over(self) -> bool:
        """게임 종료 확인"""
        # 빈 칸이 있으면 계속 가능
        if np.any(self.board == 0):
            return False
        
        # 합칠 수 있는 인접한 타일이 있는지 확인
        for i in range(self.board_size):
            for j in range(self.board_size):
                current = self.board[i, j]
                
                # 오른쪽 확인
                if j < self.board_size - 1 and self.board[i, j + 1] == current:
                    return False
                
                # 아래쪽 확인
                if i < self.board_size - 1 and self.board[i + 1, j] == current:
                    return False
        
        return True
    
    def calculate_reward(self, prev_board: np.ndarray, prev_score: int, moved: bool) -> float:
        """보상 계산"""
        if not moved:
            return -0.1  # 무효한 이동 페널티
        
        # 점수 증가 보상
        score_reward = (self.score - prev_score) / 100.0
        
        # 빈 칸 보상
        empty_cells = np.sum(self.board == 0)
        empty_reward = empty_cells * 0.01
        
        # 최대 타일 보상
        max_tile = np.max(self.board)
        max_tile_reward = np.log2(max_tile) * 0.1 if max_tile > 0 else 0
        
        # 보드 평활성 보상 (인접한 타일들의 차이가 작을수록 좋음)
        smoothness = self.calculate_smoothness()
        smoothness_reward = smoothness * 0.05
        
        total_reward = score_reward + empty_reward + max_tile_reward + smoothness_reward
        
        return total_reward
    
    def calculate_smoothness(self) -> float:
        """보드 평활성 계산"""
        smoothness = 0
        
        for i in range(self.board_size):
            for j in range(self.board_size):
                if self.board[i, j] != 0:
                    value = np.log2(self.board[i, j])
                    
                    # 오른쪽과 비교
                    if j < self.board_size - 1 and self.board[i, j + 1] != 0:
                        target_value = np.log2(self.board[i, j + 1])
                        smoothness -= abs(value - target_value)
                    
                    # 아래쪽과 비교
                    if i < self.board_size - 1 and self.board[i + 1, j] != 0:
                        target_value = np.log2(self.board[i + 1, j])
                        smoothness -= abs(value - target_value)
        
        return smoothness
    
    async def get_state(self) -> Dict[str, Any]:
        """현재 상태 반환"""
        return {
            'board': self.board.tolist(),
            'score': self.score,
            'moves_count': self.moves_count,
            'max_tile': int(np.max(self.board)),
            'empty_cells': int(np.sum(self.board == 0)),
            'available_moves': self.get_available_moves()
        }
    
    def get_available_moves(self) -> List[str]:
        """가능한 이동 방향 반환"""
        moves = []
        
        for direction in ['up', 'down', 'left', 'right']:
            # 임시로 이동해보고 변화가 있는지 확인
            temp_board = self.board.copy()
            temp_env = Game2048Environment(self.board_size)
            temp_env.board = temp_board
            
            if temp_env.move(direction):
                moves.append(direction)
        
        return moves

class Game2048Agent(Agent):
    """2048 게임 에이전트"""
    
    def __init__(self, model_name: str = "Qwen/Qwen2.5-7B-Instruct"):
        super().__init__(model_name)
        self.strategy = "minimax"  # 또는 "deep_learning"
        
    async def select_action(self, state: Dict[str, Any]) -> Dict[str, Any]:
        """액션 선택"""
        
        if self.strategy == "minimax":
            return await self.minimax_action(state)
        else:
            return await self.ml_based_action(state)
    
    async def minimax_action(self, state: Dict[str, Any]) -> Dict[str, Any]:
        """미니맥스 기반 액션 선택"""
        board = np.array(state['board'])
        available_moves = state['available_moves']
        
        if not available_moves:
            return {'direction': 'up', 'reasoning': 'No moves available'}
        
        best_move = None
        best_score = -float('inf')
        
        for move in available_moves:
            # 각 이동에 대해 점수 계산
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
        """이동 평가 (미니맥스)"""
        if depth == 0:
            return self.evaluate_board(board)
        
        # 임시 환경에서 이동 시뮬레이션
        temp_env = Game2048Environment(board.shape[0])
        temp_env.board = board.copy()
        
        if not temp_env.move(direction):
            return -1000  # 무효한 이동
        
        # 새로운 타일이 추가될 모든 가능한 위치에 대해 평가
        empty_cells = [(i, j) for i in range(board.shape[0]) 
                      for j in range(board.shape[0]) if temp_env.board[i, j] == 0]
        
        if not empty_cells:
            return self.evaluate_board(temp_env.board)
        
        total_score = 0
        for i, j in empty_cells:
            for value in [2, 4]:
                prob = 0.9 if value == 2 else 0.1
                
                # 새 타일 추가
                temp_env.board[i, j] = value
                
                # 다음 레벨 평가
                next_score = max([
                    self.evaluate_move(temp_env.board, next_dir, depth - 1)
                    for next_dir in ['up', 'down', 'left', 'right']
                ])
                
                total_score += prob * next_score
                
                # 타일 제거
                temp_env.board[i, j] = 0
        
        return total_score / len(empty_cells)
    
    def evaluate_board(self, board: np.ndarray) -> float:
        """보드 평가 함수"""
        # 빈 칸 점수
        empty_score = np.sum(board == 0) * 10
        
        # 최대 타일 점수
        max_tile = np.max(board)
        max_score = np.log2(max_tile) * 100 if max_tile > 0 else 0
        
        # 평활성 점수
        smoothness = self.calculate_smoothness(board) * 50
        
        # 단조성 점수 (큰 수가 한쪽으로 몰려있으면 좋음)
        monotonicity = self.calculate_monotonicity(board) * 100
        
        return empty_score + max_score + smoothness + monotonicity
    
    def calculate_smoothness(self, board: np.ndarray) -> float:
        """평활성 계산"""
        smoothness = 0
        size = board.shape[0]
        
        for i in range(size):
            for j in range(size):
                if board[i, j] != 0:
                    value = np.log2(board[i, j])
                    
                    for di, dj in [(0, 1), (1, 0)]:  # 오른쪽, 아래
                        ni, nj = i + di, j + dj
                        if ni < size and nj < size and board[ni, nj] != 0:
                            target_value = np.log2(board[ni, nj])
                            smoothness -= abs(value - target_value)
        
        return smoothness
    
    def calculate_monotonicity(self, board: np.ndarray) -> float:
        """단조성 계산"""
        totals = [0, 0, 0, 0]  # up, down, left, right
        
        for i in range(board.shape[0]):
            current = 0
            next_val = 1
            
            # 수평 단조성
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
        
        # 수직 단조성
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

# 훈련 스크립트
async def train_2048_agent():
    """2048 에이전트 훈련"""
    
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
        
        # 최고 점수 추적
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

## 결론

**OpenPipe ART (Agent Reinforcement Trainer)**는 실제 업무 환경에서 멀티스텝 AI 에이전트를 효과적으로 훈련할 수 있는 혁신적인 프레임워크입니다.

### 🎯 핵심 성과

1. **GRPO 알고리즘**: 안정적이고 효율적인 강화학습 훈련
2. **실무 적용성**: 이메일 검색, 게임, 코딩 등 다양한 실제 태스크 지원
3. **확장성**: 클라이언트-서버 아키텍처로 대규모 분산 훈련 가능
4. **자동화**: RULER 통합으로 보상함수 엔지니어링 생략

### 🚀 실무 적용 포인트

- **스타트업**: 제한된 자원으로 실용적인 AI 에이전트 개발
- **기업**: 업무 자동화를 위한 특화 에이전트 훈련
- **연구기관**: 멀티스텝 강화학습 연구 플랫폼
- **개발자**: 게임, 툴, 서비스에 통합 가능한 지능형 에이전트

### 📈 다음 단계

1. **기본 예제**: 이메일 검색 에이전트로 시작
2. **커스텀 환경**: 자신만의 태스크 환경 구현
3. **프로덕션 배포**: 실제 서비스에 에이전트 통합
4. **커뮤니티 기여**: [OpenPipe ART GitHub](https://github.com/OpenPipe/ART)에 개선사항 기여

OpenPipe ART를 통해 차세대 실무형 AI 에이전트를 개발해보세요! 🚀

---

**참고 자료**:
- [OpenPipe ART GitHub](https://github.com/OpenPipe/ART)
- [GRPO 논문](https://arxiv.org/abs/2402.03300)
- [OpenPipe 공식 문서](https://docs.openpipe.ai/)
- [Langfuse 통합 가이드](https://langfuse.com/docs) 