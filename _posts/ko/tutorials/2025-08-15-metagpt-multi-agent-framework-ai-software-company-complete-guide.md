---
title: "MetaGPT: 멀티 에이전트 프레임워크로 AI 소프트웨어 회사 구축하기 완전 가이드"
excerpt: "자연어 한 줄로 완전한 소프트웨어를 개발하는 MetaGPT 멀티 에이전트 프레임워크. 설치부터 실제 프로젝트 생성까지 단계별 튜토리얼"
seo_title: "MetaGPT 멀티 에이전트 AI 소프트웨어 개발 튜토리얼 - Thaki Cloud"
seo_description: "MetaGPT로 AI 소프트웨어 회사 구축하기. Python 설치, 설정, 실제 프로젝트 생성까지 포함한 완전 가이드. 자연어 프로그래밍의 혁신"
date: 2025-08-15
last_modified_at: 2025-08-15
categories:
  - tutorials
  - llmops
tags:
  - metagpt
  - multi-agent
  - ai-software-company
  - natural-language-programming
  - llm-agents
  - gpt
  - python
  - automation
  - collaborative-ai
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/metagpt-multi-agent-framework-ai-software-company-complete-guide/"
reading_time: true
published: false
---

⏱️ **예상 읽기 시간**: 15분

## 서론

소프트웨어 개발의 미래가 바뀌고 있습니다. [MetaGPT](https://github.com/FoundationAgents/MetaGPT)는 **자연어 한 줄**만으로 완전한 소프트웨어를 개발할 수 있는 혁신적인 멀티 에이전트 프레임워크입니다. 마치 실제 소프트웨어 회사처럼 **제품 매니저, 아키텍트, 엔지니어** 역할을 하는 AI 에이전트들이 협업하여 코드를 생성합니다.

이 프레임워크는 **57.9k GitHub 스타**를 기록하며, **자연어 프로그래밍**의 새로운 패러다임을 제시하고 있습니다. MGX(MetaGPT X)라는 상용 서비스도 런칭하여 실제 비즈니스 환경에서 검증받고 있습니다.

### 이 가이드에서 배울 내용

- MetaGPT의 멀티 에이전트 아키텍처와 SOP(Standard Operating Procedures) 철학
- 완전한 개발 환경 설정 및 구성
- 실제 프로젝트 생성부터 배포까지 전체 워크플로우
- 커스텀 에이전트 개발 및 확장 방법
- 데이터 분석, 디베이트, 연구 등 다양한 활용 사례
- 프로덕션 환경에서의 최적화 전략

### 기술 요구사항

- **Python**: 3.9 이상, 3.12 미만
- **Node.js**: 18+ (프론트엔드 개발용)
- **pnpm**: 최신 버전
- **OpenAI API Key** 또는 호환 LLM
- **메모리**: 최소 8GB RAM
- **저장공간**: 5GB 이상

## MetaGPT 핵심 개념

### Code = SOP(Team) 철학

MetaGPT의 핵심 철학은 **"Code = SOP(Team)"**입니다. 실제 소프트웨어 회사의 표준 운영 절차(SOP)를 AI 에이전트 팀에 적용하여 체계적인 개발 프로세스를 구현합니다.

```python
# MetaGPT의 핵심 아키텍처
class SoftwareCompany:
    def __init__(self):
        self.roles = {
            "product_manager": ProductManager(),
            "architect": Architect(), 
            "project_manager": ProjectManager(),
            "engineers": [Engineer() for _ in range(3)],
            "qa_engineer": QAEngineer()
        }
        
        self.sop = StandardOperatingProcedures()
    
    def develop_software(self, requirement: str):
        # 1. 제품 매니저: 요구사항 분석
        user_stories = self.roles["product_manager"].analyze_requirements(requirement)
        
        # 2. 아키텍트: 시스템 설계
        architecture = self.roles["architect"].design_system(user_stories)
        
        # 3. 프로젝트 매니저: 작업 계획
        tasks = self.roles["project_manager"].create_tasks(architecture)
        
        # 4. 엔지니어들: 코드 구현
        code = self.parallel_development(tasks)
        
        # 5. QA: 품질 보증
        tested_code = self.roles["qa_engineer"].test_code(code)
        
        return tested_code
```

### 멀티 에이전트 협업 시스템

MetaGPT는 각 역할별 전문 에이전트가 단계적으로 협업하는 시스템입니다:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Product        │    │  Architect      │    │  Project        │
│  Manager        │───▶│                 │───▶│  Manager        │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Requirements   │    │  System Design  │    │  Task Planning  │
│  • User Stories │    │  • Architecture │    │  • Sprint Plan  │
│  • Use Cases    │    │  • APIs         │    │  • Resource     │
│  • Acceptance   │    │  • Database     │    │    Allocation   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Engineering Team                             │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐      │
│  │  Frontend     │  │  Backend      │  │  DevOps       │      │
│  │  Engineer     │  │  Engineer     │  │  Engineer     │      │
│  └───────────────┘  └───────────────┘  └───────────────┘      │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    QA Engineer                                  │
│  • Unit Testing    • Integration Testing    • Performance      │
│  • Code Review     • Security Analysis      • Documentation    │
└─────────────────────────────────────────────────────────────────┘
```

## 환경 설정 및 설치

### 1단계: Python 환경 준비

```bash
# Python 버전 확인
python --version  # 3.9 이상, 3.12 미만이어야 함

# Conda로 환경 생성 (권장)
conda create -n metagpt python=3.11
conda activate metagpt

# 또는 venv 사용
python -m venv metagpt-env
source metagpt-env/bin/activate  # Linux/macOS
# metagpt-env\Scripts\activate  # Windows
```

### 2단계: MetaGPT 설치

```bash
# PyPI에서 설치 (권장)
pip install --upgrade metagpt

# 또는 최신 개발 버전
pip install --upgrade git+https://github.com/FoundationAgents/MetaGPT.git

# 또는 소스에서 설치 (개발자용)
git clone https://github.com/FoundationAgents/MetaGPT.git
cd MetaGPT
pip install --upgrade -e .
```

### 3단계: Node.js 및 pnpm 설치

```bash
# Node.js 설치 확인 (18+ 필요)
node --version

# macOS (Homebrew)
brew install node pnpm

# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
npm install -g pnpm

# Windows (Chocolatey)
choco install nodejs pnpm
```

### 4단계: 설치 확인

```python
# test_installation.py
import sys
import subprocess

def test_metagpt_installation():
    print("🔍 MetaGPT 설치 확인 중...")
    
    # Python 버전 확인
    python_version = sys.version_info
    print(f"✅ Python 버전: {python_version.major}.{python_version.minor}.{python_version.micro}")
    
    if not (3, 9) <= (python_version.major, python_version.minor) < (3, 12):
        print("❌ Python 버전이 3.9-3.11 범위에 있지 않습니다")
        return False
    
    # MetaGPT 임포트 테스트
    try:
        import metagpt
        print(f"✅ MetaGPT 버전: {metagpt.__version__}")
    except ImportError as e:
        print(f"❌ MetaGPT 임포트 실패: {e}")
        return False
    
    # Node.js 및 pnpm 확인
    try:
        node_result = subprocess.run(['node', '--version'], capture_output=True, text=True)
        pnpm_result = subprocess.run(['pnpm', '--version'], capture_output=True, text=True)
        
        print(f"✅ Node.js: {node_result.stdout.strip()}")
        print(f"✅ pnpm: {pnpm_result.stdout.strip()}")
        
    except FileNotFoundError as e:
        print(f"❌ Node.js/pnpm 설치 확인 실패: {e}")
        return False
    
    print("🎉 모든 설치가 완료되었습니다!")
    return True

if __name__ == "__main__":
    test_metagpt_installation()
```

## 설정 및 구성

### 설정 파일 초기화

```bash
# MetaGPT 설정 초기화
metagpt --init-config

# 설정 파일 위치 확인
ls -la ~/.metagpt/config2.yaml
```

### LLM 제공자별 설정

#### OpenAI 설정

```yaml
# ~/.metagpt/config2.yaml
llm:
  api_type: "openai"
  model: "gpt-4-turbo"  # 또는 gpt-3.5-turbo, gpt-4o
  base_url: "https://api.openai.com/v1"
  api_key: "YOUR_OPENAI_API_KEY"
  
# 고급 설정
  max_tokens: 4096
  temperature: 0.7
  timeout: 60
```

#### Azure OpenAI 설정

```yaml
llm:
  api_type: "azure"
  model: "gpt-4"
  base_url: "https://YOUR_RESOURCE.openai.azure.com/"
  api_key: "YOUR_AZURE_API_KEY"
  api_version: "2024-02-15-preview"
  deployment_name: "gpt-4-deployment"
```

#### Ollama 로컬 LLM 설정

```bash
# Ollama 설치 및 모델 다운로드
curl -fsSL https://ollama.ai/install.sh | sh
ollama serve
ollama pull llama2  # 또는 codellama, mistral
```

```yaml
llm:
  api_type: "ollama"
  model: "llama2"
  base_url: "http://localhost:11434"
  # api_key는 필요 없음
```

#### Groq 설정 (빠른 추론용)

```yaml
llm:
  api_type: "groq"
  model: "mixtral-8x7b-32768"
  base_url: "https://api.groq.com/openai/v1"
  api_key: "YOUR_GROQ_API_KEY"
```

### 환경별 설정 최적화

```python
# config_optimizer.py
import yaml
import os
from pathlib import Path

class MetaGPTConfigOptimizer:
    def __init__(self):
        self.config_path = Path.home() / ".metagpt" / "config2.yaml"
        
    def create_optimized_config(self, environment="development"):
        """환경별 최적화된 설정 생성"""
        
        base_config = {
            "llm": {
                "api_type": "openai",
                "model": "gpt-4-turbo",
                "base_url": "https://api.openai.com/v1",
                "api_key": os.getenv("OPENAI_API_KEY", "YOUR_API_KEY_HERE")
            },
            "workspace": {
                "path": "./workspace"
            },
            "logging": {
                "level": "INFO"
            }
        }
        
        if environment == "development":
            # 개발 환경: 빠른 반복을 위한 설정
            config = {
                **base_config,
                "llm": {
                    **base_config["llm"],
                    "model": "gpt-3.5-turbo",  # 빠르고 저렴
                    "temperature": 0.3,  # 일관성 있는 결과
                    "max_tokens": 2048
                },
                "logging": {
                    "level": "DEBUG"
                }
            }
            
        elif environment == "production":
            # 프로덕션 환경: 품질 우선 설정
            config = {
                **base_config,
                "llm": {
                    **base_config["llm"],
                    "model": "gpt-4-turbo",  # 최고 품질
                    "temperature": 0.7,  # 창의성과 일관성 균형
                    "max_tokens": 4096,
                    "timeout": 120
                },
                "logging": {
                    "level": "WARNING"
                }
            }
            
        elif environment == "budget":
            # 예산 절약 환경: 비용 최적화
            config = {
                **base_config,
                "llm": {
                    **base_config["llm"],
                    "model": "gpt-3.5-turbo",
                    "temperature": 0.5,
                    "max_tokens": 1024
                }
            }
            
        return config
    
    def save_config(self, config):
        """설정 파일 저장"""
        self.config_path.parent.mkdir(exist_ok=True)
        
        with open(self.config_path, 'w') as f:
            yaml.dump(config, f, default_flow_style=False, indent=2)
        
        print(f"✅ 설정 파일 저장됨: {self.config_path}")
    
    def setup_environment_config(self, environment="development"):
        """환경별 설정 자동 생성"""
        config = self.create_optimized_config(environment)
        self.save_config(config)
        
        print(f"🔧 {environment} 환경 설정 완료")
        print("📝 다음 사항을 확인하세요:")
        print(f"   1. API 키가 올바르게 설정되었는지")
        print(f"   2. 모델이 사용 가능한지")
        print(f"   3. 네트워크 연결이 정상인지")

# 사용 예제
if __name__ == "__main__":
    optimizer = MetaGPTConfigOptimizer()
    
    # 개발 환경 설정
    optimizer.setup_environment_config("development")
```

## 기본 사용법

### CLI를 통한 간단한 프로젝트 생성

```bash
# 간단한 게임 만들기
metagpt "Create a 2048 game"

# 웹 애플리케이션 만들기
metagpt "Create a todo list web app with React frontend and Python backend"

# 데이터 분석 도구 만들기
metagpt "Create a data visualization dashboard for sales analytics"

# 생성된 프로젝트 확인
ls -la ./workspace/
```

### Python API를 통한 프로그래밍 방식 사용

```python
# basic_usage.py
import asyncio
from metagpt.software_company import generate_repo
from metagpt.utils.project_repo import ProjectRepo

async def create_simple_project():
    """간단한 프로젝트 생성 예제"""
    
    # 요구사항 정의
    requirement = """
    Create a simple web-based calculator that can:
    1. Perform basic arithmetic operations (+, -, *, /)
    2. Have a clean, responsive UI
    3. Show calculation history
    4. Support keyboard input
    5. Include unit tests
    """
    
    print("🚀 프로젝트 생성 시작...")
    print(f"📋 요구사항: {requirement}")
    
    # 프로젝트 생성
    repo: ProjectRepo = await generate_repo(requirement)
    
    # 결과 출력
    print("\n📁 생성된 프로젝트 구조:")
    print(repo)
    
    # 생성된 파일들 확인
    print("\n📄 주요 파일들:")
    for file_path in repo.all_files:
        print(f"   {file_path}")
    
    return repo

async def create_advanced_project():
    """고급 프로젝트 생성 예제"""
    
    requirement = """
    Create a microservices-based e-commerce platform with:
    
    Backend Services:
    - User authentication service (JWT-based)
    - Product catalog service with search
    - Shopping cart service
    - Order processing service
    - Payment integration service
    - Email notification service
    
    Frontend:
    - React-based customer portal
    - Admin dashboard for inventory management
    - Mobile-responsive design
    
    Infrastructure:
    - Docker containerization
    - API gateway
    - Database design (PostgreSQL)
    - Redis for caching
    - Message queue for async processing
    
    Quality Assurance:
    - Unit tests for all services
    - Integration tests
    - API documentation (OpenAPI/Swagger)
    - Performance testing setup
    - Security vulnerability scanning
    """
    
    print("🚀 고급 프로젝트 생성 시작...")
    
    # 프로젝트 생성
    repo: ProjectRepo = await generate_repo(requirement)
    
    # 프로젝트 분석
    print(f"\n📊 프로젝트 통계:")
    print(f"   총 파일 수: {len(repo.all_files)}")
    
    # 파일 유형별 분류
    file_types = {}
    for file_path in repo.all_files:
        ext = file_path.suffix.lower()
        file_types[ext] = file_types.get(ext, 0) + 1
    
    print(f"   파일 유형별 분포:")
    for ext, count in sorted(file_types.items()):
        print(f"     {ext or '(확장자 없음)'}: {count}개")
    
    return repo

# 사용 예제
async def main():
    # 간단한 프로젝트 먼저 테스트
    simple_repo = await create_simple_project()
    
    # 고급 프로젝트 생성 (시간이 더 걸림)
    # advanced_repo = await create_advanced_project()

if __name__ == "__main__":
    asyncio.run(main())
```

### 데이터 인터프리터 사용

```python
# data_interpreter_example.py
import asyncio
import pandas as pd
import numpy as np
from metagpt.roles.di.data_interpreter import DataInterpreter

async def analyze_iris_dataset():
    """Iris 데이터셋 분석 예제"""
    
    di = DataInterpreter()
    
    # 기본 분석 요청
    result = await di.run("Run data analysis on sklearn Iris dataset, include a plot")
    
    print("📊 분석 완료!")
    return result

async def analyze_custom_data():
    """커스텀 데이터 분석 예제"""
    
    # 샘플 데이터 생성
    np.random.seed(42)
    data = {
        'date': pd.date_range('2024-01-01', periods=100),
        'sales': np.random.normal(1000, 200, 100),
        'marketing_spend': np.random.normal(500, 100, 100),
        'region': np.random.choice(['North', 'South', 'East', 'West'], 100)
    }
    
    df = pd.DataFrame(data)
    df.to_csv('./sample_sales_data.csv', index=False)
    
    di = DataInterpreter()
    
    analysis_request = """
    Analyze the sales data in ./sample_sales_data.csv and provide:
    1. Summary statistics
    2. Correlation analysis between sales and marketing spend
    3. Regional performance comparison
    4. Time series trend analysis
    5. Visualizations for each analysis
    6. Recommendations based on findings
    """
    
    result = await di.run(analysis_request)
    
    print("📈 커스텀 데이터 분석 완료!")
    return result

async def financial_analysis():
    """금융 데이터 분석 예제"""
    
    di = DataInterpreter()
    
    request = """
    Create a financial analysis dashboard that:
    1. Downloads stock data for Apple, Google, Microsoft (last 2 years)
    2. Calculates key financial metrics (volatility, Sharpe ratio, etc.)
    3. Performs portfolio optimization
    4. Creates interactive charts showing:
       - Price movements
       - Returns distribution
       - Correlation heatmap
       - Risk-return scatter plot
    5. Provides investment recommendations
    """
    
    result = await di.run(request)
    
    print("💰 금융 분석 완료!")
    return result

# 실행 예제
async def main():
    print("🔍 데이터 분석 시작...")
    
    # 1. 기본 Iris 분석
    await analyze_iris_dataset()
    
    # 2. 커스텀 데이터 분석
    await analyze_custom_data()
    
    # 3. 금융 분석 (시간이 더 걸림)
    # await financial_analysis()

if __name__ == "__main__":
    asyncio.run(main())
```

## 고급 활용 사례

### 1. 디베이트 시스템

```python
# debate_system.py
import asyncio
from metagpt.roles import Role
from metagpt.schema import Message
from metagpt.actions import Action
from metagpt.environment import Environment

class DebateAction(Action):
    """디베이트 액션 클래스"""
    
    def __init__(self, stance: str):
        super().__init__()
        self.stance = stance  # "for" 또는 "against"
    
    async def run(self, topic: str, previous_arguments: list = None):
        """디베이트 논증 생성"""
        
        context = f"Topic: {topic}\nStance: {self.stance}"
        
        if previous_arguments:
            context += f"\nPrevious arguments:\n" + "\n".join(previous_arguments)
        
        prompt = f"""
        {context}
        
        Please provide a well-reasoned argument for your stance.
        Include:
        1. Main thesis
        2. Supporting evidence
        3. Counter-arguments to opposing views
        4. Logical conclusion
        
        Keep it concise but persuasive (200-300 words).
        """
        
        response = await self._aask(prompt)
        return response

class Debater(Role):
    """디베이터 역할 클래스"""
    
    def __init__(self, name: str, stance: str):
        super().__init__(name=name)
        self.stance = stance
        self.debate_action = DebateAction(stance)
        self.arguments_made = []
    
    async def _act(self) -> Message:
        """디베이트 수행"""
        
        # 최신 메시지에서 주제와 이전 논증들 추출
        topic = self.rc.env.get_topic()
        previous_args = self.rc.env.get_previous_arguments()
        
        # 논증 생성
        argument = await self.debate_action.run(topic, previous_args)
        self.arguments_made.append(argument)
        
        # 메시지 생성
        message = Message(
            content=argument,
            role=self.profile,
            cause_by=type(self.debate_action)
        )
        
        return message

class DebateEnvironment(Environment):
    """디베이트 환경 클래스"""
    
    def __init__(self, topic: str, rounds: int = 3):
        super().__init__()
        self.topic = topic
        self.rounds = rounds
        self.current_round = 0
        self.arguments = []
    
    def get_topic(self):
        return self.topic
    
    def get_previous_arguments(self):
        return self.arguments[-4:]  # 최근 4개 논증만 반환
    
    def add_argument(self, argument: str, debater: str):
        self.arguments.append(f"{debater}: {argument}")

async def run_debate():
    """디베이트 실행"""
    
    topic = "Should artificial intelligence replace human jobs?"
    
    # 환경 설정
    env = DebateEnvironment(topic, rounds=3)
    
    # 디베이터들 생성
    pro_debater = Debater("Pro-AI Advocate", "for")
    con_debater = Debater("Human-First Advocate", "against")
    
    # 환경에 디베이터들 추가
    env.add_role(pro_debater)
    env.add_role(con_debater)
    
    print(f"🎭 디베이트 시작: {topic}")
    print("=" * 80)
    
    # 디베이트 진행
    for round_num in range(env.rounds):
        print(f"\n📍 라운드 {round_num + 1}")
        print("-" * 40)
        
        # Pro 측 논증
        pro_message = await pro_debater._act()
        env.add_argument(pro_message.content, "Pro")
        print(f"\n🟢 Pro-AI Advocate:")
        print(pro_message.content)
        
        # Con 측 논증
        con_message = await con_debater._act()
        env.add_argument(con_message.content, "Con")
        print(f"\n🔴 Human-First Advocate:")
        print(con_message.content)
        
        print("\n" + "="*80)
    
    # 디베이트 요약
    print(f"\n📊 디베이트 완료!")
    print(f"총 {len(env.arguments)}개의 논증이 교환되었습니다.")
    
    return env.arguments

# 실행
if __name__ == "__main__":
    asyncio.run(run_debate())
```

### 2. 연구 어시스턴트

```python
# research_assistant.py
import asyncio
import json
from datetime import datetime
from pathlib import Path
from metagpt.roles import Role
from metagpt.actions import Action
from metagpt.schema import Message

class LiteratureReviewAction(Action):
    """문헌 검토 액션"""
    
    async def run(self, topic: str, search_terms: list):
        """문헌 검토 수행"""
        
        prompt = f"""
        Conduct a comprehensive literature review on: {topic}
        
        Search terms: {', '.join(search_terms)}
        
        Please provide:
        1. Key research themes and trends
        2. Major findings and conclusions
        3. Research gaps and future directions
        4. Methodology comparison
        5. Citation analysis
        6. Recommended reading list (10-15 papers)
        
        Format as a structured academic review.
        """
        
        review = await self._aask(prompt)
        return review

class ExperimentDesignAction(Action):
    """실험 설계 액션"""
    
    async def run(self, research_question: str, constraints: dict):
        """실험 설계 생성"""
        
        prompt = f"""
        Design an experiment to answer: {research_question}
        
        Constraints:
        - Budget: {constraints.get('budget', 'Not specified')}
        - Timeline: {constraints.get('timeline', 'Not specified')}
        - Resources: {constraints.get('resources', 'Not specified')}
        
        Please provide:
        1. Hypothesis formulation
        2. Experimental design (methodology)
        3. Variables identification (dependent, independent, control)
        4. Sample size calculation
        5. Data collection procedures
        6. Statistical analysis plan
        7. Ethical considerations
        8. Timeline and milestones
        """
        
        design = await self._aask(prompt)
        return design

class DataAnalysisPlanAction(Action):
    """데이터 분석 계획 액션"""
    
    async def run(self, data_description: str, research_objectives: list):
        """데이터 분석 계획 생성"""
        
        prompt = f"""
        Create a data analysis plan for:
        
        Data: {data_description}
        
        Research Objectives:
        {chr(10).join(f"{i+1}. {obj}" for i, obj in enumerate(research_objectives))}
        
        Please provide:
        1. Data preprocessing steps
        2. Descriptive analysis plan
        3. Statistical tests selection
        4. Visualization strategy
        5. Model selection rationale
        6. Validation procedures
        7. Interpretation guidelines
        8. Reporting structure
        """
        
        plan = await self._aask(prompt)
        return plan

class ResearchAssistant(Role):
    """연구 어시스턴트 역할"""
    
    def __init__(self, specialization: str = "General"):
        super().__init__(name=f"Research Assistant ({specialization})")
        self.specialization = specialization
        self.lit_review_action = LiteratureReviewAction()
        self.exp_design_action = ExperimentDesignAction()
        self.data_analysis_action = DataAnalysisPlanAction()
    
    async def conduct_literature_review(self, topic: str, search_terms: list):
        """문헌 검토 수행"""
        return await self.lit_review_action.run(topic, search_terms)
    
    async def design_experiment(self, research_question: str, constraints: dict):
        """실험 설계"""
        return await self.exp_design_action.run(research_question, constraints)
    
    async def create_analysis_plan(self, data_description: str, objectives: list):
        """분석 계획 생성"""
        return await self.data_analysis_action.run(data_description, objectives)

class ResearchProject:
    """연구 프로젝트 관리 클래스"""
    
    def __init__(self, project_name: str, output_dir: str = "./research_output"):
        self.project_name = project_name
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)
        
        self.assistant = ResearchAssistant()
        self.project_data = {
            "project_name": project_name,
            "created_at": datetime.now().isoformat(),
            "components": {}
        }
    
    async def run_comprehensive_research(self, research_config: dict):
        """종합적인 연구 수행"""
        
        print(f"🔬 연구 프로젝트 시작: {self.project_name}")
        print("=" * 60)
        
        # 1. 문헌 검토
        if "literature_review" in research_config:
            print("\n📚 문헌 검토 수행 중...")
            lit_config = research_config["literature_review"]
            
            literature_review = await self.assistant.conduct_literature_review(
                lit_config["topic"],
                lit_config["search_terms"]
            )
            
            self.project_data["components"]["literature_review"] = literature_review
            self._save_component("literature_review", literature_review)
            print("✅ 문헌 검토 완료")
        
        # 2. 실험 설계
        if "experiment_design" in research_config:
            print("\n🧪 실험 설계 수행 중...")
            exp_config = research_config["experiment_design"]
            
            experiment_design = await self.assistant.design_experiment(
                exp_config["research_question"],
                exp_config["constraints"]
            )
            
            self.project_data["components"]["experiment_design"] = experiment_design
            self._save_component("experiment_design", experiment_design)
            print("✅ 실험 설계 완료")
        
        # 3. 데이터 분석 계획
        if "data_analysis" in research_config:
            print("\n📊 데이터 분석 계획 수행 중...")
            data_config = research_config["data_analysis"]
            
            analysis_plan = await self.assistant.create_analysis_plan(
                data_config["data_description"],
                data_config["objectives"]
            )
            
            self.project_data["components"]["data_analysis_plan"] = analysis_plan
            self._save_component("data_analysis_plan", analysis_plan)
            print("✅ 데이터 분석 계획 완료")
        
        # 프로젝트 메타데이터 저장
        self._save_project_metadata()
        
        print(f"\n🎉 연구 프로젝트 완료!")
        print(f"📁 결과 위치: {self.output_dir}")
        
        return self.project_data
    
    def _save_component(self, component_name: str, content: str):
        """컴포넌트 결과 저장"""
        file_path = self.output_dir / f"{component_name}.md"
        
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(f"# {component_name.replace('_', ' ').title()}\n\n")
            f.write(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
            f.write(content)
        
        print(f"   💾 저장됨: {file_path}")
    
    def _save_project_metadata(self):
        """프로젝트 메타데이터 저장"""
        metadata_path = self.output_dir / "project_metadata.json"
        
        with open(metadata_path, 'w', encoding='utf-8') as f:
            json.dump(self.project_data, f, indent=2, ensure_ascii=False)

# 연구 프로젝트 실행 예제
async def run_ai_ethics_research():
    """AI 윤리 연구 프로젝트 예제"""
    
    research_config = {
        "literature_review": {
            "topic": "AI Ethics in Healthcare Applications",
            "search_terms": [
                "artificial intelligence ethics",
                "healthcare AI",
                "medical AI bias",
                "algorithmic fairness",
                "AI governance healthcare"
            ]
        },
        "experiment_design": {
            "research_question": "How can we measure and mitigate bias in AI diagnostic systems?",
            "constraints": {
                "budget": "$50,000",
                "timeline": "6 months",
                "resources": "Hospital partnership, anonymized patient data"
            }
        },
        "data_analysis": {
            "data_description": "Anonymized patient diagnostic data with demographic information and AI system predictions",
            "objectives": [
                "Identify potential bias in AI diagnostic accuracy across demographic groups",
                "Quantify disparities in false positive/negative rates",
                "Evaluate fairness metrics for the AI system",
                "Propose bias mitigation strategies"
            ]
        }
    }
    
    project = ResearchProject("AI_Ethics_Healthcare_Study")
    result = await project.run_comprehensive_research(research_config)
    
    return result

# 실행
if __name__ == "__main__":
    asyncio.run(run_ai_ethics_research())
```

### 3. 영수증 처리 어시스턴트

```python
# receipt_assistant.py
import asyncio
import json
import base64
from pathlib import Path
from datetime import datetime
from metagpt.roles import Role
from metagpt.actions import Action

class ReceiptProcessingAction(Action):
    """영수증 처리 액션"""
    
    async def run(self, receipt_data: str, processing_type: str = "extract"):
        """영수증 데이터 처리"""
        
        if processing_type == "extract":
            prompt = f"""
            Extract structured information from this receipt:
            
            {receipt_data}
            
            Please provide a JSON response with:
            {% raw %}{{
                "merchant_name": "Store name",
                "date": "YYYY-MM-DD",
                "time": "HH:MM",
                "total_amount": 0.00,
                "tax_amount": 0.00,
                "items": [
                    {{
                        "name": "Item name",
                        "quantity": 1,
                        "unit_price": 0.00,
                        "total_price": 0.00,
                        "category": "Category"
                    }}
                ],
                "payment_method": "Cash/Card/etc",
                "receipt_number": "Number if available",
                "location": "Store address if available"
            }}{% endraw %}
            """
        
        elif processing_type == "categorize":
            prompt = f"""
            Categorize the expenses in this receipt for accounting purposes:
            
            {receipt_data}
            
            Provide categorization based on standard business expense categories:
            - Office Supplies
            - Meals & Entertainment
            - Travel
            - Equipment
            - Marketing
            - Utilities
            - Professional Services
            - Other
            
            Format as JSON with explanations.
            """
        
        elif processing_type == "validate":
            prompt = f"""
            Validate the mathematical accuracy of this receipt:
            
            {receipt_data}
            
            Check:
            1. Item totals (quantity × unit price)
            2. Subtotal calculations
            3. Tax calculations
            4. Final total
            
            Report any discrepancies found.
            """
        
        response = await self._aask(prompt)
        return response

class ExpenseCategorizationAction(Action):
    """비용 분류 액션"""
    
    async def run(self, receipts_data: list, business_rules: dict):
        """비용 분류 수행"""
        
        prompt = f"""
        Categorize these expenses according to business rules:
        
        Business Rules:
        {json.dumps(business_rules, indent=2)}
        
        Receipts:
        {json.dumps(receipts_data, indent=2)}
        
        Provide:
        1. Categorized expenses by type
        2. Monthly/quarterly summaries
        3. Tax-deductible vs non-deductible items
        4. Flagged items requiring review
        5. Compliance notes
        """
        
        categorization = await self._aask(prompt)
        return categorization

class ReceiptAssistant(Role):
    """영수증 처리 어시스턴트"""
    
    def __init__(self):
        super().__init__(name="Receipt Processing Assistant")
        self.processing_action = ReceiptProcessingAction()
        self.categorization_action = ExpenseCategorizationAction()
        self.processed_receipts = []
    
    async def process_receipt(self, receipt_content: str):
        """단일 영수증 처리"""
        
        # 1. 데이터 추출
        extracted = await self.processing_action.run(receipt_content, "extract")
        
        # 2. 유효성 검증
        validation = await self.processing_action.run(receipt_content, "validate")
        
        # 3. 카테고리 분류
        categorization = await self.processing_action.run(receipt_content, "categorize")
        
        processed_data = {
            "extracted_data": extracted,
            "validation_result": validation,
            "categorization": categorization,
            "processed_at": datetime.now().isoformat()
        }
        
        self.processed_receipts.append(processed_data)
        return processed_data
    
    async def batch_process_receipts(self, receipt_files: list):
        """배치 영수증 처리"""
        
        results = []
        
        for i, receipt_file in enumerate(receipt_files):
            print(f"📄 처리 중: {receipt_file} ({i+1}/{len(receipt_files)})")
            
            # 파일 읽기
            with open(receipt_file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 처리
            result = await self.process_receipt(content)
            result["source_file"] = str(receipt_file)
            results.append(result)
        
        return results
    
    async def generate_expense_report(self, period: str = "monthly"):
        """비용 보고서 생성"""
        
        if not self.processed_receipts:
            return "처리된 영수증이 없습니다."
        
        # 비즈니스 규칙 정의
        business_rules = {
            "tax_deductible_categories": [
                "Office Supplies",
                "Business Meals",
                "Travel",
                "Professional Services"
            ],
            "approval_required_threshold": 500.00,
            "mileage_rate": 0.65,  # per mile
            "meal_deduction_percentage": 50
        }
        
        # 비용 분류 및 보고서 생성
        report = await self.categorization_action.run(
            self.processed_receipts,
            business_rules
        )
        
        return report

class ReceiptManager:
    """영수증 관리 시스템"""
    
    def __init__(self, data_dir: str = "./receipt_data"):
        self.data_dir = Path(data_dir)
        self.data_dir.mkdir(exist_ok=True)
        
        self.assistant = ReceiptAssistant()
        
        # 디렉토리 구조 생성
        (self.data_dir / "raw").mkdir(exist_ok=True)
        (self.data_dir / "processed").mkdir(exist_ok=True)
        (self.data_dir / "reports").mkdir(exist_ok=True)
    
    async def process_receipt_folder(self, folder_path: str):
        """폴더 내 모든 영수증 처리"""
        
        folder = Path(folder_path)
        receipt_files = list(folder.glob("*.txt")) + list(folder.glob("*.md"))
        
        if not receipt_files:
            print("처리할 영수증 파일이 없습니다.")
            return
        
        print(f"🚀 영수증 배치 처리 시작: {len(receipt_files)}개 파일")
        
        # 배치 처리
        results = await self.assistant.batch_process_receipts(receipt_files)
        
        # 결과 저장
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        output_file = self.data_dir / "processed" / f"batch_processed_{timestamp}.json"
        
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(results, f, indent=2, ensure_ascii=False)
        
        print(f"✅ 처리 완료: {output_file}")
        
        # 보고서 생성
        report = await self.assistant.generate_expense_report()
        
        report_file = self.data_dir / "reports" / f"expense_report_{timestamp}.txt"
        with open(report_file, 'w', encoding='utf-8') as f:
            f.write(report)
        
        print(f"📊 보고서 생성: {report_file}")
        
        return results, report
    
    def create_sample_receipts(self):
        """샘플 영수증 생성 (테스트용)"""
        
        sample_receipts = [
            {
                "filename": "coffee_shop_receipt.txt",
                "content": """
                Starbucks Coffee
                123 Main Street, Anytown, USA
                
                Date: 2025-01-27
                Time: 14:30
                
                1x Venti Latte        $5.95
                1x Blueberry Muffin   $3.25
                
                Subtotal:             $9.20
                Tax (8.5%):           $0.78
                Total:                $9.98
                
                Payment: Credit Card
                Receipt #: 1234567890
                """
            },
            {
                "filename": "office_supplies_receipt.txt", 
                "content": """
                Office Depot
                456 Business Blvd, Corporate City
                
                Date: 2025-01-26
                Time: 10:15
                
                2x Notebook Pack     $12.99 each   $25.98
                1x Pen Set           $8.50         $8.50
                1x Printer Paper     $15.99        $15.99
                
                Subtotal:                         $50.47
                Tax (7.25%):                      $3.66
                Total:                            $54.13
                
                Payment: Debit Card
                Receipt #: OD2025012601
                """
            }
        ]
        
        raw_dir = self.data_dir / "raw"
        
        for receipt in sample_receipts:
            file_path = raw_dir / receipt["filename"]
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(receipt["content"])
        
        print(f"📄 샘플 영수증 생성: {raw_dir}")
        return raw_dir

# 사용 예제
async def main():
    manager = ReceiptManager()
    
    # 샘플 영수증 생성
    sample_dir = manager.create_sample_receipts()
    
    # 영수증 처리
    results, report = await manager.process_receipt_folder(sample_dir)
    
    print("\n📊 처리 결과 요약:")
    print(f"처리된 영수증: {len(results)}개")
    
    # 간단한 통계
    total_amount = 0
    for result in results:
        try:
            extracted = json.loads(result["extracted_data"])
            total_amount += float(extracted.get("total_amount", 0))
        except:
            pass
    
    print(f"총 비용: ${total_amount:.2f}")

if __name__ == "__main__":
    asyncio.run(main())
```

## 커스텀 에이전트 개발

### 기본 에이전트 구조

```python
# custom_agent.py
import asyncio
from typing import List, Dict, Any
from metagpt.roles import Role
from metagpt.actions import Action
from metagpt.schema import Message
from metagpt.memory import LongTermMemory

class CustomAction(Action):
    """커스텀 액션 기본 클래스"""
    
    def __init__(self, name: str = "CustomAction", context: Dict[str, Any] = None):
        super().__init__(name=name)
        self.context = context or {}
    
    async def run(self, input_data: Any) -> Any:
        """액션 실행 로직"""
        
        # 기본 프롬프트 템플릿
        prompt = f"""
        Context: {self.context}
        Input: {input_data}
        
        Please process the input according to the context and provide appropriate output.
        """
        
        response = await self._aask(prompt)
        return response

class CodeReviewAction(Action):
    """코드 리뷰 전문 액션"""
    
    def __init__(self):
        super().__init__(name="CodeReviewAction")
        self.review_criteria = {
            "functionality": "Does the code work as intended?",
            "readability": "Is the code easy to read and understand?",
            "performance": "Are there any performance issues?",
            "security": "Are there any security vulnerabilities?",
            "best_practices": "Does it follow coding best practices?",
            "testing": "Is the code properly tested?"
        }
    
    async def run(self, code: str, language: str = "python") -> Dict[str, Any]:
        """코드 리뷰 수행"""
        
        prompt = f"""
        Perform a comprehensive code review for the following {language} code:
        
        ```{language}
        {code}
        ```
        
        Review Criteria:
        {chr(10).join(f"- {k}: {v}" for k, v in self.review_criteria.items())}
        
        Please provide:
        1. Overall assessment (score 1-10)
        2. Detailed feedback for each criterion
        3. Specific issues found with line numbers
        4. Suggestions for improvement
        5. Refactored code examples if needed
        
        Format as structured JSON.
        """
        
        review = await self._aask(prompt)
        return review

class DocumentationAction(Action):
    """문서화 전문 액션"""
    
    async def run(self, code: str, doc_type: str = "api") -> str:
        """문서 생성"""
        
        if doc_type == "api":
            prompt = f"""
            Generate comprehensive API documentation for this code:
            
            {code}
            
            Include:
            1. Function/class descriptions
            2. Parameters with types and descriptions
            3. Return values
            4. Usage examples
            5. Error handling
            6. Performance notes
            
            Use clear, professional documentation format.
            """
        
        elif doc_type == "readme":
            prompt = f"""
            Generate a README.md file for this project/code:
            
            {code}
            
            Include:
            1. Project description
            2. Installation instructions
            3. Usage examples
            4. API reference
            5. Contributing guidelines
            6. License information
            
            Use standard README format with proper markdown.
            """
        
        documentation = await self._aask(prompt)
        return documentation

class SeniorDeveloper(Role):
    """시니어 개발자 역할"""
    
    def __init__(self, specialization: str = "Full Stack"):
        super().__init__(name=f"Senior Developer ({specialization})")
        self.specialization = specialization
        
        # 액션들 초기화
        self.code_review_action = CodeReviewAction()
        self.documentation_action = DocumentationAction()
        
        # 메모리 시스템
        self.memory = LongTermMemory()
        
        # 전문 지식
        self.expertise = {
            "languages": ["Python", "JavaScript", "TypeScript", "Go", "Rust"],
            "frameworks": ["React", "Django", "FastAPI", "Express", "Next.js"],
            "databases": ["PostgreSQL", "MongoDB", "Redis", "Elasticsearch"],
            "cloud": ["AWS", "GCP", "Azure", "Docker", "Kubernetes"],
            "best_practices": [
                "SOLID principles",
                "Clean Code",
                "Test-Driven Development",
                "CI/CD",
                "Security best practices"
            ]
        }
    
    async def review_code(self, code: str, language: str = "python"):
        """코드 리뷰 수행"""
        
        print(f"🔍 코드 리뷰 시작 ({language})")
        review = await self.code_review_action.run(code, language)
        
        # 리뷰 결과를 메모리에 저장
        await self.memory.add(f"code_review_{hash(code)}", {
            "code": code,
            "language": language,
            "review": review,
            "timestamp": asyncio.get_event_loop().time()
        })
        
        return review
    
    async def generate_documentation(self, code: str, doc_type: str = "api"):
        """문서 생성"""
        
        print(f"📝 문서 생성 시작 ({doc_type})")
        docs = await self.documentation_action.run(code, doc_type)
        return docs
    
    async def provide_mentorship(self, question: str, context: str = ""):
        """멘토링 제공"""
        
        prompt = f"""
        As a Senior {self.specialization} Developer with expertise in:
        {', '.join(self.expertise['languages'])} and {', '.join(self.expertise['frameworks'])}
        
        Context: {context}
        Question: {question}
        
        Provide mentorship advice including:
        1. Direct answer to the question
        2. Best practices recommendations
        3. Common pitfalls to avoid
        4. Learning resources
        5. Next steps for skill development
        
        Be encouraging and practical in your advice.
        """
        
        advice = await self._aask(prompt)
        return advice
    
    async def architecture_review(self, system_design: str):
        """시스템 아키텍처 리뷰"""
        
        prompt = f"""
        Review this system architecture design:
        
        {system_design}
        
        As a Senior Developer, evaluate:
        1. Scalability considerations
        2. Security implications
        3. Performance bottlenecks
        4. Maintainability factors
        5. Technology stack appropriateness
        6. Cost implications
        7. Risk assessment
        
        Provide specific recommendations for improvement.
        """
        
        review = await self._aask(prompt)
        return review

class TeamLead(Role):
    """팀 리드 역할"""
    
    def __init__(self):
        super().__init__(name="Team Lead")
        self.team_members = []
        self.projects = []
    
    def add_team_member(self, member: Role):
        """팀 멤버 추가"""
        self.team_members.append(member)
        print(f"👥 팀 멤버 추가: {member.name}")
    
    async def assign_task(self, task: str, assignee: str = None):
        """작업 할당"""
        
        if assignee:
            # 특정 멤버에게 할당
            member = next((m for m in self.team_members if m.name == assignee), None)
            if member:
                print(f"📋 작업 할당: {task} → {assignee}")
                return await self._delegate_task(member, task)
        else:
            # 최적의 멤버에게 자동 할당
            best_member = await self._find_best_assignee(task)
            if best_member:
                print(f"📋 자동 할당: {task} → {best_member.name}")
                return await self._delegate_task(best_member, task)
        
        return "할당할 수 있는 팀 멤버가 없습니다."
    
    async def _find_best_assignee(self, task: str):
        """작업에 가장 적합한 팀 멤버 찾기"""
        
        prompt = f"""
        Given this task: {task}
        
        And these team members:
        {chr(10).join(f"- {m.name}: {getattr(m, 'specialization', 'General')}" for m in self.team_members)}
        
        Who would be the best assignee? Return just the name.
        """
        
        best_assignee_name = await self._aask(prompt)
        return next((m for m in self.team_members if m.name in best_assignee_name), None)
    
    async def _delegate_task(self, member: Role, task: str):
        """멤버에게 작업 위임"""
        
        if hasattr(member, '_act'):
            # 메시지 생성하여 멤버의 _act 메서드 호출
            message = Message(content=task, role="team_lead")
            response = await member._act()
            return response
        else:
            return f"{member.name}에게 작업이 할당되었습니다: {task}"
    
    async def conduct_team_meeting(self, agenda: str):
        """팀 미팅 진행"""
        
        print(f"📅 팀 미팅 시작: {agenda}")
        
        meeting_notes = []
        
        for member in self.team_members:
            prompt = f"""
            Team meeting agenda: {agenda}
            
            As {member.name}, provide your input on:
            1. Current progress updates
            2. Challenges faced
            3. Ideas and suggestions
            4. Questions for the team
            
            Keep it concise and relevant.
            """
            
            input_msg = await self._aask_with_context(prompt, member.name)
            meeting_notes.append(f"{member.name}: {input_msg}")
        
        # 미팅 요약 생성
        summary_prompt = f"""
        Summarize this team meeting:
        
        Agenda: {agenda}
        
        Team Input:
        {chr(10).join(meeting_notes)}
        
        Provide:
        1. Key decisions made
        2. Action items with owners
        3. Outstanding issues
        4. Next meeting agenda items
        """
        
        summary = await self._aask(summary_prompt)
        
        print("📝 미팅 요약:")
        print(summary)
        
        return summary
    
    async def _aask_with_context(self, prompt: str, context: str):
        """컨텍스트가 있는 질문"""
        full_prompt = f"Context: {context}\n\n{prompt}"
        return await self._aask(full_prompt)

# 커스텀 에이전트 사용 예제
async def demo_custom_agents():
    """커스텀 에이전트 데모"""
    
    # 팀 구성
    team_lead = TeamLead()
    senior_dev_backend = SeniorDeveloper("Backend")
    senior_dev_frontend = SeniorDeveloper("Frontend")
    
    # 팀 구성
    team_lead.add_team_member(senior_dev_backend)
    team_lead.add_team_member(senior_dev_frontend)
    
    # 예제 코드
    sample_code = """
def calculate_fibonacci(n):
    if n <= 1:
        return n
    return calculate_fibonacci(n-1) + calculate_fibonacci(n-2)

def get_user_data(user_id):
    # TODO: Add input validation
    query = f"SELECT * FROM users WHERE id = {user_id}"
    return database.execute(query)
    """
    
    # 1. 코드 리뷰
    print("=" * 60)
    review = await senior_dev_backend.review_code(sample_code, "python")
    print("코드 리뷰 결과:")
    print(review)
    
    # 2. 문서 생성
    print("\n" + "=" * 60)
    docs = await senior_dev_backend.generate_documentation(sample_code, "api")
    print("생성된 문서:")
    print(docs)
    
    # 3. 멘토링
    print("\n" + "=" * 60)
    mentorship = await senior_dev_backend.provide_mentorship(
        "How can I improve the performance of recursive functions?",
        "I'm working on algorithm optimization"
    )
    print("멘토링 조언:")
    print(mentorship)
    
    # 4. 팀 미팅
    print("\n" + "=" * 60)
    meeting_summary = await team_lead.conduct_team_meeting(
        "Sprint Planning and Code Quality Improvements"
    )
    
    # 5. 작업 할당
    print("\n" + "=" * 60)
    assignment_result = await team_lead.assign_task(
        "Implement user authentication system with JWT tokens"
    )
    print(assignment_result)

if __name__ == "__main__":
    asyncio.run(demo_custom_agents())
```

## 성능 최적화 및 프로덕션 배포

### 리소스 관리 및 모니터링

```python
# production_optimization.py
import asyncio
import psutil
import time
import json
import logging
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Any
from contextlib import asynccontextmanager

class ResourceMonitor:
    """리소스 모니터링 클래스"""
    
    def __init__(self, log_dir: str = "./monitoring_logs"):
        self.log_dir = Path(log_dir)
        self.log_dir.mkdir(exist_ok=True)
        
        self.metrics_history = []
        self.setup_logging()
    
    def setup_logging(self):
        """로깅 설정"""
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler(self.log_dir / 'resource_monitor.log'),
                logging.StreamHandler()
            ]
        )
        self.logger = logging.getLogger(__name__)
    
    def get_system_metrics(self) -> Dict[str, Any]:
        """시스템 메트릭 수집"""
        
        cpu_percent = psutil.cpu_percent(interval=1)
        memory = psutil.virtual_memory()
        disk = psutil.disk_usage('/')
        
        metrics = {
            "timestamp": datetime.now().isoformat(),
            "cpu": {
                "percent": cpu_percent,
                "count": psutil.cpu_count(),
                "freq": psutil.cpu_freq()._asdict() if psutil.cpu_freq() else None
            },
            "memory": {
                "total_gb": memory.total / (1024**3),
                "available_gb": memory.available / (1024**3),
                "used_gb": memory.used / (1024**3),
                "percent": memory.percent
            },
            "disk": {
                "total_gb": disk.total / (1024**3),
                "used_gb": disk.used / (1024**3),
                "free_gb": disk.free / (1024**3),
                "percent": (disk.used / disk.total) * 100
            }
        }
        
        # GPU 메트릭 (nvidia-ml-py가 설치된 경우)
        try:
            import pynvml
            pynvml.nvmlInit()
            gpu_count = pynvml.nvmlDeviceGetCount()
            
            gpu_metrics = []
            for i in range(gpu_count):
                handle = pynvml.nvmlDeviceGetHandleByIndex(i)
                
                memory_info = pynvml.nvmlDeviceGetMemoryInfo(handle)
                utilization = pynvml.nvmlDeviceGetUtilizationRates(handle)
                temperature = pynvml.nvmlDeviceGetTemperature(handle, pynvml.NVML_TEMPERATURE_GPU)
                
                gpu_metrics.append({
                    "index": i,
                    "memory_total_gb": memory_info.total / (1024**3),
                    "memory_used_gb": memory_info.used / (1024**3),
                    "memory_free_gb": memory_info.free / (1024**3),
                    "memory_percent": (memory_info.used / memory_info.total) * 100,
                    "utilization_percent": utilization.gpu,
                    "temperature_c": temperature
                })
            
            metrics["gpu"] = gpu_metrics
            
        except ImportError:
            metrics["gpu"] = "Not available (pynvml not installed)"
        except Exception as e:
            metrics["gpu"] = f"Error: {str(e)}"
        
        return metrics
    
    @asynccontextmanager
    async def monitor_execution(self, operation_name: str):
        """실행 중 리소스 모니터링"""
        
        start_time = time.time()
        start_metrics = self.get_system_metrics()
        
        self.logger.info(f"🔄 시작: {operation_name}")
        self.logger.info(f"초기 CPU: {start_metrics['cpu']['percent']:.1f}%")
        self.logger.info(f"초기 메모리: {start_metrics['memory']['percent']:.1f}%")
        
        try:
            yield self
            
        finally:
            end_time = time.time()
            end_metrics = self.get_system_metrics()
            duration = end_time - start_time
            
            # 성능 분석
            cpu_delta = end_metrics['cpu']['percent'] - start_metrics['cpu']['percent']
            memory_delta = end_metrics['memory']['percent'] - start_metrics['memory']['percent']
            
            execution_log = {
                "operation": operation_name,
                "duration_seconds": duration,
                "start_metrics": start_metrics,
                "end_metrics": end_metrics,
                "resource_deltas": {
                    "cpu_percent": cpu_delta,
                    "memory_percent": memory_delta
                }
            }
            
            self.metrics_history.append(execution_log)
            
            self.logger.info(f"✅ 완료: {operation_name}")
            self.logger.info(f"실행 시간: {duration:.2f}초")
            self.logger.info(f"CPU 변화: {cpu_delta:+.1f}%")
            self.logger.info(f"메모리 변화: {memory_delta:+.1f}%")
    
    def save_metrics_report(self):
        """메트릭 보고서 저장"""
        
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        report_file = self.log_dir / f"metrics_report_{timestamp}.json"
        
        with open(report_file, 'w') as f:
            json.dump(self.metrics_history, f, indent=2)
        
        self.logger.info(f"📊 메트릭 보고서 저장: {report_file}")
        return report_file

class OptimizedMetaGPT:
    """최적화된 MetaGPT 실행 클래스"""
    
    def __init__(self, config: Dict[str, Any] = None):
        self.config = config or self._get_default_config()
        self.monitor = ResourceMonitor()
        
        # 성능 통계
        self.performance_stats = {
            "total_requests": 0,
            "successful_requests": 0,
            "failed_requests": 0,
            "average_response_time": 0,
            "total_tokens_used": 0
        }
    
    def _get_default_config(self) -> Dict[str, Any]:
        """기본 설정 반환"""
        return {
            "llm": {
                "model": "gpt-4-turbo",
                "max_tokens": 4096,
                "temperature": 0.7,
                "timeout": 120
            },
            "optimization": {
                "max_concurrent_requests": 3,
                "request_rate_limit": 10,  # per minute
                "memory_threshold_percent": 85,
                "cpu_threshold_percent": 90
            },
            "caching": {
                "enabled": True,
                "cache_dir": "./cache",
                "max_cache_size_gb": 5
            }
        }
    
    async def generate_project_optimized(self, requirement: str):
        """최적화된 프로젝트 생성"""
        
        async with self.monitor.monitor_execution(f"Project Generation: {requirement[:50]}..."):
            
            # 리소스 체크
            if not self._check_resource_availability():
                raise RuntimeError("시스템 리소스가 부족합니다")
            
            # 캐시 확인
            cached_result = await self._check_cache(requirement)
            if cached_result:
                self.monitor.logger.info("💾 캐시에서 결과 반환")
                return cached_result
            
            # 프로젝트 생성
            try:
                from metagpt.software_company import generate_repo
                
                start_time = time.time()
                repo = await generate_repo(requirement)
                end_time = time.time()
                
                # 성능 통계 업데이트
                self.performance_stats["total_requests"] += 1
                self.performance_stats["successful_requests"] += 1
                
                response_time = end_time - start_time
                self._update_average_response_time(response_time)
                
                # 캐시 저장
                await self._save_to_cache(requirement, repo)
                
                return repo
                
            except Exception as e:
                self.performance_stats["total_requests"] += 1
                self.performance_stats["failed_requests"] += 1
                
                self.monitor.logger.error(f"❌ 프로젝트 생성 실패: {e}")
                raise
    
    def _check_resource_availability(self) -> bool:
        """리소스 사용 가능성 확인"""
        
        metrics = self.monitor.get_system_metrics()
        
        cpu_ok = metrics["cpu"]["percent"] < self.config["optimization"]["cpu_threshold_percent"]
        memory_ok = metrics["memory"]["percent"] < self.config["optimization"]["memory_threshold_percent"]
        
        if not cpu_ok:
            self.monitor.logger.warning(f"⚠️ CPU 사용률 높음: {metrics['cpu']['percent']:.1f}%")
        
        if not memory_ok:
            self.monitor.logger.warning(f"⚠️ 메모리 사용률 높음: {metrics['memory']['percent']:.1f}%")
        
        return cpu_ok and memory_ok
    
    async def _check_cache(self, requirement: str):
        """캐시 확인"""
        
        if not self.config["caching"]["enabled"]:
            return None
        
        cache_dir = Path(self.config["caching"]["cache_dir"])
        cache_dir.mkdir(exist_ok=True)
        
        # 요구사항 해시로 캐시 키 생성
        import hashlib
        cache_key = hashlib.md5(requirement.encode()).hexdigest()
        cache_file = cache_dir / f"{cache_key}.json"
        
        if cache_file.exists():
            try:
                with open(cache_file, 'r') as f:
                    cached_data = json.load(f)
                
                # 캐시 유효성 확인 (예: 24시간)
                cache_time = datetime.fromisoformat(cached_data["timestamp"])
                if (datetime.now() - cache_time).total_seconds() < 86400:  # 24시간
                    return cached_data["result"]
                    
            except Exception as e:
                self.monitor.logger.warning(f"캐시 로드 실패: {e}")
        
        return None
    
    async def _save_to_cache(self, requirement: str, result):
        """캐시 저장"""
        
        if not self.config["caching"]["enabled"]:
            return
        
        cache_dir = Path(self.config["caching"]["cache_dir"])
        
        import hashlib
        cache_key = hashlib.md5(requirement.encode()).hexdigest()
        cache_file = cache_dir / f"{cache_key}.json"
        
        try:
            cache_data = {
                "timestamp": datetime.now().isoformat(),
                "requirement": requirement,
                "result": str(result)  # ProjectRepo를 문자열로 변환
            }
            
            with open(cache_file, 'w') as f:
                json.dump(cache_data, f, indent=2)
                
        except Exception as e:
            self.monitor.logger.warning(f"캐시 저장 실패: {e}")
    
    def _update_average_response_time(self, response_time: float):
        """평균 응답 시간 업데이트"""
        
        current_avg = self.performance_stats["average_response_time"]
        total_requests = self.performance_stats["successful_requests"]
        
        if total_requests == 1:
            new_avg = response_time
        else:
            new_avg = ((current_avg * (total_requests - 1)) + response_time) / total_requests
        
        self.performance_stats["average_response_time"] = new_avg
    
    def get_performance_report(self) -> Dict[str, Any]:
        """성능 보고서 생성"""
        
        success_rate = 0
        if self.performance_stats["total_requests"] > 0:
            success_rate = (self.performance_stats["successful_requests"] / 
                          self.performance_stats["total_requests"]) * 100
        
        return {
            "performance_stats": self.performance_stats,
            "success_rate_percent": success_rate,
            "system_metrics": self.monitor.get_system_metrics(),
            "configuration": self.config
        }

# 배치 처리 최적화
class BatchProcessor:
    """배치 처리 최적화 클래스"""
    
    def __init__(self, max_concurrent: int = 3):
        self.max_concurrent = max_concurrent
        self.semaphore = asyncio.Semaphore(max_concurrent)
        self.optimized_metagpt = OptimizedMetaGPT()
    
    async def process_batch(self, requirements: List[str]):
        """배치 요구사항 처리"""
        
        print(f"🚀 배치 처리 시작: {len(requirements)}개 요구사항")
        
        async def process_single(req: str):
            async with self.semaphore:
                try:
                    result = await self.optimized_metagpt.generate_project_optimized(req)
                    return {"requirement": req, "result": result, "status": "success"}
                except Exception as e:
                    return {"requirement": req, "error": str(e), "status": "failed"}
        
        # 병렬 처리
        tasks = [process_single(req) for req in requirements]
        results = await asyncio.gather(*tasks, return_exceptions=True)
        
        # 결과 분석
        successful = sum(1 for r in results if isinstance(r, dict) and r.get("status") == "success")
        failed = len(results) - successful
        
        print(f"✅ 배치 처리 완료:")
        print(f"   성공: {successful}")
        print(f"   실패: {failed}")
        print(f"   성공률: {(successful/len(results)*100):.1f}%")
        
        return results

# 프로덕션 사용 예제
async def production_demo():
    """프로덕션 환경 데모"""
    
    # 최적화된 MetaGPT 인스턴스 생성
    optimized = OptimizedMetaGPT({
        "llm": {
            "model": "gpt-3.5-turbo",  # 빠른 모델 사용
            "max_tokens": 2048,
            "temperature": 0.5
        },
        "optimization": {
            "max_concurrent_requests": 2,
            "memory_threshold_percent": 80,
            "cpu_threshold_percent": 85
        },
        "caching": {
            "enabled": True,
            "cache_dir": "./production_cache"
        }
    })
    
    # 테스트 요구사항들
    requirements = [
        "Create a simple todo list app",
        "Create a weather dashboard",
        "Create a password generator"
    ]
    
    # 배치 처리
    batch_processor = BatchProcessor(max_concurrent=2)
    results = await batch_processor.process_batch(requirements)
    
    # 성능 보고서
    report = optimized.get_performance_report()
    print("\n📊 성능 보고서:")
    print(json.dumps(report, indent=2))
    
    # 메트릭 보고서 저장
    optimized.monitor.save_metrics_report()

if __name__ == "__main__":
    asyncio.run(production_demo())
```

## 실제 프로젝트 생성 및 테스트

<function_calls>
<invoke name="run_terminal_cmd">
<parameter name="command">mkdir -p tutorials/metagpt-test
