---
title: "Agent Leaderboard v2 완벽 가이드 - AI 에이전트 성능 평가의 새로운 표준"
excerpt: "Galileo.ai의 Agent Leaderboard v2를 활용하여 AI 에이전트의 툴 사용 성능을 평가하고 벤치마킹하는 방법을 실습을 통해 학습합니다."
seo_title: "Agent Leaderboard v2 튜토리얼 - AI 에이전트 평가 완벽 가이드 - Thaki Cloud"
seo_description: "Agent Leaderboard v2를 사용한 AI 에이전트 성능 평가 방법, TSQ 메트릭 활용법, 실습 예제까지 포함한 종합 가이드입니다."
date: 2025-07-18
last_modified_at: 2025-07-18
categories:
  - llmops
tags:
  - agent-leaderboard
  - ai-agents
  - benchmarking
  - tool-calling
  - galileo-ai
  - performance-evaluation
  - machine-learning
  - llm-evaluation
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/agent-leaderboard-v2-comprehensive-tutorial/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 15분

## 서론

AI 에이전트의 성능을 객관적으로 평가하는 것은 현대 AI 개발에서 가장 중요한 과제 중 하나입니다. Galileo.ai에서 개발한 Agent Leaderboard v2는 AI 에이전트의 툴 사용 능력을 종합적으로 평가하는 혁신적인 벤치마킹 플랫폼입니다.

Jensen Huang이 AI 에이전트를 "디지털 워크포스"라고 부르고, Satya Nadella가 에이전트가 비즈니스 운영을 근본적으로 변화시킬 것이라고 말한 것처럼, AI 에이전트는 차세대 AI 혁신의 핵심입니다.

이 튜토리얼에서는 Agent Leaderboard v2의 핵심 개념부터 실제 활용법까지, 실습을 통해 완전히 마스터할 수 있도록 안내합니다.

## Agent Leaderboard v2란 무엇인가?

### 개요 및 핵심 특징

Agent Leaderboard v2는 AI 에이전트가 실제 비즈니스 시나리오에서 어떻게 수행되는지 평가하는 종합적인 벤치마킹 프레임워크입니다. 기존의 학술적 벤치마크가 기술적 역량만을 평가했다면, Agent Leaderboard v2는 실제 사용 사례에서의 성능을 중점적으로 측정합니다.

### 주요 차별화 요소

현재 평가 프레임워크들의 한계를 살펴보면:
- **BFCL**: 수학, 엔터테인먼트, 교육 등 학술 영역에 특화
- **τ-bench**: 소매 및 항공 시나리오에 집중
- **xLAM**: 21개 도메인의 데이터 생성에 특화
- **ToolACE**: 390개 도메인의 API 상호작용에 집중

Agent Leaderboard v2는 이러한 개별 벤치마크들을 종합하여 **다중 도메인**과 **실제 사용 사례**를 포괄하는 통합 평가 프레임워크를 제공합니다.

### 평가 대상 모델

현재 17개의 주요 LLM을 평가하고 있으며, 매월 새로운 모델 릴리스에 맞춰 업데이트됩니다:

#### Elite Tier (≥ 0.9)
- **Gemini-2.0-flash**: 0.938 점수로 1위
- **GPT-4o**: 0.900 점수로 2위

#### High Performance (0.85-0.9)
- **Gemini-1.5-flash**: 0.895
- **Gemini-1.5-pro**: 0.885
- **o1**: 0.876
- **o3-mini**: 0.847

#### Mid Tier (0.8-0.85)
- **GPT-4o-mini**: 0.832
- **mistral-small-2501**: 0.832
- **Qwen-72b**: 0.817

## Tool Selection Quality (TSQ) 메트릭 이해하기

### TSQ의 핵심 개념

TSQ(Tool Selection Quality)는 Agent Leaderboard v2의 핵심 평가 지표입니다. 단순한 정확도가 아닌, 에이전트의 **툴 선택 정확성**과 **매개변수 사용 효과성**을 종합적으로 평가합니다.

### TSQ 평가 차원

#### 1. 시나리오 인식 (Scenario Recognition)
에이전트가 쿼리를 받았을 때 툴 사용이 필요한지 먼저 판단해야 합니다:
- 대화 기록에 이미 정보가 있어 툴 호출이 불필요한 경우
- 사용 가능한 툴이 작업에 부적절하거나 불충분한 경우

#### 2. 툴 선택 역학 (Tool Selection Dynamics)
툴 선택은 이진법적이지 않고 정밀도와 재현율을 모두 포함합니다:
- **재현율 이슈**: 필요한 툴 중 일부를 놓치는 경우
- **정밀도 이슈**: 적절한 툴과 함께 불필요한 툴을 선택하는 경우

#### 3. 매개변수 처리 (Parameter Handling)
올바른 툴을 선택했더라도 인수 처리에서 추가적인 복잡성이 발생합니다:
- 모든 필수 매개변수를 올바른 이름으로 제공
- 선택적 매개변수를 적절히 처리
- 매개변수 값의 정확성 유지
- 툴 사양에 따른 인수 형식 맞춤

#### 4. 순차적 의사결정 (Sequential Decision Making)
다단계 작업에서는 에이전트가 다음 능력들을 보여야 합니다:
- 최적의 툴 호출 순서 결정
- 툴 호출 간 상호의존성 처리
- 여러 작업에 걸친 컨텍스트 유지
- 부분적 결과나 실패에 대한 적응

## 실습 환경 구축하기

### 필수 요구사항

```bash
# Python 환경 확인
python --version  # Python 3.8+ 필요

# Node.js 환경 확인 (선택사항)
node --version    # Node.js 16+ 권장
```

### 개발환경 설정

```bash
# 프로젝트 디렉토리 생성
mkdir agent-leaderboard-tutorial
cd agent-leaderboard-tutorial

# Python 가상환경 생성
python -m venv venv
source venv/bin/activate  # macOS/Linux

# 필수 라이브러리 설치
pip install openai
pip install pandas
pip install promptquality
pip install fastparquet
```

### API 키 설정

```bash
# 환경변수 설정
export OPENAI_API_KEY="your-openai-api-key"
export GALILEO_PROJECT_NAME="agent-evaluation"
```

### 기본 설정 파일 생성

```python
# config.py
import os

# API 설정
OPENAI_API_KEY = os.getenv('OPENAI_API_KEY')
GALILEO_PROJECT_NAME = os.getenv('GALILEO_PROJECT_NAME', 'agent-evaluation')

# 모델 설정
DEFAULT_MODEL = "gpt-4o"
DEFAULT_TEMPERATURE = 0.0
DEFAULT_MAX_TOKENS = 4000

# 평가 설정
SYSTEM_MESSAGE = {
    "role": "system",
    "content": '''Your job is to use the given tools to answer the query of human. 
    If there is no relevant tool then reply with "I cannot answer the question with given tools". 
    If tool is available but sufficient information is not available, then ask human to get the same. 
    You can call as many tools as you want. Use multiple tools if needed. 
    If the tools need to be called in a sequence then just call the first tool.'''
}
```

## TSQ 평가 시스템 구현하기

### 기본 평가 클래스 구현

```python
# evaluator.py
import promptquality as pq
import pandas as pd
from openai import OpenAI
import json

class TSQEvaluator:
    def __init__(self, model="gpt-4o", project_name="agent-evaluation"):
        self.model = model
        self.project_name = project_name
        self.client = OpenAI()
        
        # TSQ 평가기 설정
        self.chainpoll_scorer = pq.CustomizedChainPollScorer(
            scorer_name=pq.CustomizedScorerName.tool_selection_quality,
            model_alias=pq.Models.gpt_4o,
        )
        
        # 평가 핸들러 설정
        self.evaluate_handler = pq.GalileoPromptCallback(
            project_name=self.project_name,
            run_name=f"evaluation_{model}",
            scorers=[self.chainpoll_scorer],
        )
    
    def evaluate_single_interaction(self, tools, conversation, expected_outcome=None):
        """단일 상호작용에 대한 TSQ 평가"""
        try:
            response = self.client.chat.completions.create(
                model=self.model,
                messages=conversation,
                tools=tools,
                temperature=0.0,
                max_tokens=4000
            )
            
            # TSQ 점수 계산
            tsq_score = self._calculate_tsq_score(
                conversation, response, tools, expected_outcome
            )
            
            return {
                "response": response,
                "tsq_score": tsq_score,
                "evaluation_details": self._get_evaluation_details(response, tools)
            }
            
        except Exception as e:
            print(f"평가 중 오류 발생: {e}")
            return None
    
    def _calculate_tsq_score(self, conversation, response, tools, expected_outcome):
        """TSQ 점수 계산 로직"""
        score_components = {
            "tool_selection_accuracy": 0.0,
            "parameter_quality": 0.0,
            "relevance_detection": 0.0,
            "sequence_appropriateness": 0.0
        }
        
        if response.choices[0].message.tool_calls:
            tool_calls = response.choices[0].message.tool_calls
            
            # 툴 선택 정확성 평가
            score_components["tool_selection_accuracy"] = self._evaluate_tool_selection(
                tool_calls, tools, expected_outcome
            )
            
            # 매개변수 품질 평가
            score_components["parameter_quality"] = self._evaluate_parameter_quality(
                tool_calls, tools
            )
            
            # 관련성 감지 평가
            score_components["relevance_detection"] = self._evaluate_relevance_detection(
                conversation, tool_calls
            )
            
            # 순서 적절성 평가
            score_components["sequence_appropriateness"] = self._evaluate_sequence_appropriateness(
                tool_calls
            )
        
        # 전체 TSQ 점수 계산 (균등 가중치)
        total_score = sum(score_components.values()) / len(score_components)
        return min(max(total_score, 0.0), 1.0)
    
    def _evaluate_tool_selection(self, tool_calls, available_tools, expected_outcome):
        """툴 선택 정확성 평가"""
        if not tool_calls:
            return 0.0
        
        selected_tools = [call.function.name for call in tool_calls]
        available_tool_names = [tool["function"]["name"] for tool in available_tools]
        
        # 선택된 툴이 사용 가능한 툴 목록에 있는지 확인
        valid_selections = sum(1 for tool in selected_tools if tool in available_tool_names)
        
        return valid_selections / len(selected_tools) if selected_tools else 0.0
    
    def _evaluate_parameter_quality(self, tool_calls, available_tools):
        """매개변수 품질 평가"""
        if not tool_calls:
            return 0.0
        
        total_score = 0.0
        
        for call in tool_calls:
            try:
                parameters = json.loads(call.function.arguments)
                # 매개변수 유효성 검사 로직
                # 실제 구현에서는 각 툴의 스키마와 비교
                total_score += 1.0  # 단순화된 점수
            except json.JSONDecodeError:
                total_score += 0.0
        
        return total_score / len(tool_calls)
    
    def _evaluate_relevance_detection(self, conversation, tool_calls):
        """관련성 감지 평가"""
        # 대화 컨텍스트를 고려한 툴 사용의 적절성 평가
        return 0.8  # 단순화된 구현
    
    def _evaluate_sequence_appropriateness(self, tool_calls):
        """순서 적절성 평가"""
        # 툴 호출 순서의 논리적 적절성 평가
        return 0.9  # 단순화된 구현
    
    def _get_evaluation_details(self, response, tools):
        """평가 세부사항 추출"""
        details = {
            "tool_calls_count": 0,
            "tools_used": [],
            "has_function_calls": False,
            "response_type": "text"
        }
        
        if response.choices[0].message.tool_calls:
            details["has_function_calls"] = True
            details["response_type"] = "function_call"
            details["tool_calls_count"] = len(response.choices[0].message.tool_calls)
            details["tools_used"] = [
                call.function.name for call in response.choices[0].message.tool_calls
            ]
        
        return details
```

### 실습용 툴 정의

```python
# tools.py
def create_sample_tools():
    """실습용 샘플 툴들 정의"""
    tools = [
        {
            "type": "function",
            "function": {
                "name": "get_weather",
                "description": "현재 날씨 정보를 가져옵니다",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "location": {
                            "type": "string",
                            "description": "날씨를 확인할 도시 이름"
                        },
                        "unit": {
                            "type": "string",
                            "enum": ["celsius", "fahrenheit"],
                            "description": "온도 단위"
                        }
                    },
                    "required": ["location"]
                }
            }
        },
        {
            "type": "function",
            "function": {
                "name": "search_web",
                "description": "웹에서 정보를 검색합니다",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "query": {
                            "type": "string",
                            "description": "검색할 키워드"
                        },
                        "limit": {
                            "type": "integer",
                            "description": "검색 결과 수 제한",
                            "default": 5
                        }
                    },
                    "required": ["query"]
                }
            }
        },
        {
            "type": "function",
            "function": {
                "name": "calculator",
                "description": "수학 계산을 수행합니다",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "expression": {
                            "type": "string",
                            "description": "계산할 수학 표현식"
                        }
                    },
                    "required": ["expression"]
                }
            }
        },
        {
            "type": "function",
            "function": {
                "name": "send_email",
                "description": "이메일을 발송합니다",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "to": {
                            "type": "string",
                            "description": "수신자 이메일 주소"
                        },
                        "subject": {
                            "type": "string",
                            "description": "이메일 제목"
                        },
                        "body": {
                            "type": "string",
                            "description": "이메일 본문"
                        }
                    },
                    "required": ["to", "subject", "body"]
                }
            }
        }
    ]
    return tools
```

## 실습 시나리오 구현하기

### 시나리오 1: 기본 툴 사용 평가

```python
# scenario_basic.py
from evaluator import TSQEvaluator
from tools import create_sample_tools
from config import SYSTEM_MESSAGE

def run_basic_tool_usage_scenario():
    """기본 툴 사용 시나리오 실행"""
    print("=== 기본 툴 사용 시나리오 ===")
    
    evaluator = TSQEvaluator()
    tools = create_sample_tools()
    
    # 테스트 케이스들
    test_cases = [
        {
            "name": "날씨 조회",
            "conversation": [
                SYSTEM_MESSAGE,
                {"role": "user", "content": "서울의 현재 날씨를 알려주세요"}
            ],
            "expected_tools": ["get_weather"],
            "expected_outcome": "weather_query"
        },
        {
            "name": "웹 검색",
            "conversation": [
                SYSTEM_MESSAGE,
                {"role": "user", "content": "AI 에이전트에 대한 최신 뉴스를 찾아주세요"}
            ],
            "expected_tools": ["search_web"],
            "expected_outcome": "web_search"
        },
        {
            "name": "수학 계산",
            "conversation": [
                SYSTEM_MESSAGE,
                {"role": "user", "content": "15 곱하기 23을 계산해주세요"}
            ],
            "expected_tools": ["calculator"],
            "expected_outcome": "calculation"
        }
    ]
    
    results = []
    
    for test_case in test_cases:
        print(f"\n테스트: {test_case['name']}")
        
        result = evaluator.evaluate_single_interaction(
            tools=tools,
            conversation=test_case["conversation"],
            expected_outcome=test_case["expected_outcome"]
        )
        
        if result:
            print(f"TSQ 점수: {result['tsq_score']:.3f}")
            print(f"사용된 툴: {result['evaluation_details']['tools_used']}")
            print(f"예상 툴: {test_case['expected_tools']}")
            
            # 정확도 체크
            used_tools = result['evaluation_details']['tools_used']
            expected_tools = test_case['expected_tools']
            accuracy = len(set(used_tools) & set(expected_tools)) / len(set(used_tools) | set(expected_tools))
            print(f"툴 선택 정확도: {accuracy:.3f}")
            
            results.append({
                "test_name": test_case['name'],
                "tsq_score": result['tsq_score'],
                "tool_accuracy": accuracy,
                "details": result['evaluation_details']
            })
    
    # 전체 결과 요약
    print("\n=== 전체 결과 요약 ===")
    avg_tsq = sum(r['tsq_score'] for r in results) / len(results)
    avg_accuracy = sum(r['tool_accuracy'] for r in results) / len(results)
    
    print(f"평균 TSQ 점수: {avg_tsq:.3f}")
    print(f"평균 툴 선택 정확도: {avg_accuracy:.3f}")
    
    return results

if __name__ == "__main__":
    run_basic_tool_usage_scenario()
```

### 시나리오 2: 복합 툴 사용 평가

```python
# scenario_complex.py
from evaluator import TSQEvaluator
from tools import create_sample_tools
from config import SYSTEM_MESSAGE

def run_complex_tool_usage_scenario():
    """복합 툴 사용 시나리오 실행"""
    print("=== 복합 툴 사용 시나리오 ===")
    
    evaluator = TSQEvaluator()
    tools = create_sample_tools()
    
    # 복합 테스트 케이스들
    complex_test_cases = [
        {
            "name": "날씨 조회 후 이메일 발송",
            "conversation": [
                SYSTEM_MESSAGE,
                {"role": "user", "content": "서울의 날씨를 확인하고 결과를 user@example.com으로 이메일로 보내주세요"}
            ],
            "expected_tools": ["get_weather", "send_email"],
            "expected_outcome": "weather_and_email"
        },
        {
            "name": "계산 후 결과 검색",
            "conversation": [
                SYSTEM_MESSAGE,
                {"role": "user", "content": "100 곱하기 25를 계산하고, 그 결과에 대한 정보를 웹에서 찾아주세요"}
            ],
            "expected_tools": ["calculator", "search_web"],
            "expected_outcome": "calculation_and_search"
        },
        {
            "name": "불필요한 툴 사용 테스트",
            "conversation": [
                SYSTEM_MESSAGE,
                {"role": "user", "content": "안녕하세요. 좋은 하루 보내세요!"}
            ],
            "expected_tools": [],
            "expected_outcome": "no_tool_needed"
        }
    ]
    
    results = []
    
    for test_case in complex_test_cases:
        print(f"\n복합 테스트: {test_case['name']}")
        
        result = evaluator.evaluate_single_interaction(
            tools=tools,
            conversation=test_case["conversation"],
            expected_outcome=test_case["expected_outcome"]
        )
        
        if result:
            print(f"TSQ 점수: {result['tsq_score']:.3f}")
            print(f"사용된 툴: {result['evaluation_details']['tools_used']}")
            print(f"예상 툴: {test_case['expected_tools']}")
            print(f"툴 호출 수: {result['evaluation_details']['tool_calls_count']}")
            
            # 복합 작업 평가
            used_tools = set(result['evaluation_details']['tools_used'])
            expected_tools = set(test_case['expected_tools'])
            
            if expected_tools:
                precision = len(used_tools & expected_tools) / len(used_tools) if used_tools else 0
                recall = len(used_tools & expected_tools) / len(expected_tools) if expected_tools else 0
                f1_score = 2 * (precision * recall) / (precision + recall) if (precision + recall) > 0 else 0
            else:
                # 툴을 사용하지 않아야 하는 경우
                precision = 1.0 if not used_tools else 0.0
                recall = 1.0
                f1_score = precision
            
            print(f"Precision: {precision:.3f}")
            print(f"Recall: {recall:.3f}")
            print(f"F1 Score: {f1_score:.3f}")
            
            results.append({
                "test_name": test_case['name'],
                "tsq_score": result['tsq_score'],
                "precision": precision,
                "recall": recall,
                "f1_score": f1_score,
                "details": result['evaluation_details']
            })
    
    # 복합 작업 결과 요약
    print("\n=== 복합 작업 결과 요약 ===")
    avg_tsq = sum(r['tsq_score'] for r in results) / len(results)
    avg_precision = sum(r['precision'] for r in results) / len(results)
    avg_recall = sum(r['recall'] for r in results) / len(results)
    avg_f1 = sum(r['f1_score'] for r in results) / len(results)
    
    print(f"평균 TSQ 점수: {avg_tsq:.3f}")
    print(f"평균 Precision: {avg_precision:.3f}")
    print(f"평균 Recall: {avg_recall:.3f}")
    print(f"평균 F1 Score: {avg_f1:.3f}")
    
    return results

if __name__ == "__main__":
    run_complex_tool_usage_scenario()
```

## 벤치마크 데이터셋 활용하기

### BFCL 스타일 평가 구현

```python
# benchmark_datasets.py
import json
import pandas as pd
from typing import List, Dict

class BenchmarkDatasetHandler:
    def __init__(self):
        self.datasets = {
            "bfcl_basic": self._create_bfcl_basic_dataset(),
            "xlam_single": self._create_xlam_single_dataset(),
            "tau_long_context": self._create_tau_long_context_dataset(),
            "toolace_single": self._create_toolace_single_dataset()
        }
    
    def _create_bfcl_basic_dataset(self) -> List[Dict]:
        """BFCL 기본 데이터셋 생성"""
        return [
            {
                "id": "bfcl_001",
                "category": "basic_tool_usage",
                "query": "Get the current weather in Tokyo",
                "expected_function": "get_weather",
                "expected_parameters": {"location": "Tokyo"},
                "difficulty": "easy"
            },
            {
                "id": "bfcl_002", 
                "category": "basic_tool_usage",
                "query": "Calculate the square root of 144",
                "expected_function": "calculator",
                "expected_parameters": {"expression": "sqrt(144)"},
                "difficulty": "easy"
            },
            {
                "id": "bfcl_003",
                "category": "irrelevance_detection",
                "query": "What is the meaning of life?",
                "expected_function": None,
                "expected_parameters": None,
                "difficulty": "medium"
            }
        ]
    
    def _create_xlam_single_dataset(self) -> List[Dict]:
        """xLAM 단일 툴 데이터셋 생성"""
        return [
            {
                "id": "xlam_001",
                "category": "single_tool_single_call",
                "query": "Search for information about artificial intelligence",
                "expected_function": "search_web",
                "expected_parameters": {"query": "artificial intelligence"},
                "difficulty": "easy"
            },
            {
                "id": "xlam_002",
                "category": "single_tool_multiple_call",
                "query": "Get weather for both Seoul and Tokyo",
                "expected_function": "get_weather",
                "expected_parameters": [
                    {"location": "Seoul"},
                    {"location": "Tokyo"}
                ],
                "difficulty": "medium"
            }
        ]
    
    def _create_tau_long_context_dataset(self) -> List[Dict]:
        """τ-bench 장문 컨텍스트 데이터셋 생성"""
        long_context = """
        사용자가 이전에 다음과 같은 대화를 나누었습니다:
        - 서울의 날씨에 대해 문의했고, 현재 온도가 15도라는 답변을 받았습니다.
        - 그 후 도쿄의 날씨도 궁금하다고 했습니다.
        - 또한 계산기로 15 + 20을 계산해달라고 요청했습니다.
        """
        
        return [
            {
                "id": "tau_001",
                "category": "long_context",
                "context": long_context,
                "query": "이전에 문의한 서울 날씨 정보를 다시 알려주세요",
                "expected_function": None,  # 이미 정보가 있으므로 새로운 호출 불필요
                "expected_parameters": None,
                "difficulty": "hard"
            }
        ]
    
    def _create_toolace_single_dataset(self) -> List[Dict]:
        """ToolACE 단일 함수 데이터셋 생성"""
        return [
            {
                "id": "toolace_001",
                "category": "single_func_call",
                "query": "Send an email to admin@company.com with subject 'Test' and body 'Hello World'",
                "expected_function": "send_email",
                "expected_parameters": {
                    "to": "admin@company.com",
                    "subject": "Test", 
                    "body": "Hello World"
                },
                "difficulty": "medium"
            }
        ]
    
    def get_dataset(self, dataset_name: str) -> List[Dict]:
        """특정 데이터셋 반환"""
        return self.datasets.get(dataset_name, [])
    
    def get_all_datasets(self) -> Dict[str, List[Dict]]:
        """모든 데이터셋 반환"""
        return self.datasets

def run_benchmark_evaluation():
    """벤치마크 데이터셋을 사용한 평가 실행"""
    print("=== 벤치마크 데이터셋 평가 ===")
    
    from evaluator import TSQEvaluator
    from tools import create_sample_tools
    from config import SYSTEM_MESSAGE
    
    evaluator = TSQEvaluator()
    tools = create_sample_tools()
    dataset_handler = BenchmarkDatasetHandler()
    
    all_results = {}
    
    for dataset_name, dataset in dataset_handler.get_all_datasets().items():
        print(f"\n--- {dataset_name.upper()} 데이터셋 평가 ---")
        
        dataset_results = []
        
        for item in dataset:
            conversation = [SYSTEM_MESSAGE]
            
            # 장문 컨텍스트가 있는 경우 추가
            if 'context' in item:
                conversation.append({
                    "role": "assistant", 
                    "content": item['context']
                })
            
            conversation.append({
                "role": "user", 
                "content": item['query']
            })
            
            result = evaluator.evaluate_single_interaction(
                tools=tools,
                conversation=conversation,
                expected_outcome=item.get('expected_function')
            )
            
            if result:
                # 예상 결과와 실제 결과 비교
                used_tools = result['evaluation_details']['tools_used']
                expected_function = item.get('expected_function')
                
                is_correct = False
                if expected_function is None:
                    # 툴을 사용하지 않아야 하는 경우
                    is_correct = len(used_tools) == 0
                else:
                    # 특정 툴을 사용해야 하는 경우
                    is_correct = expected_function in used_tools
                
                item_result = {
                    "id": item['id'],
                    "category": item['category'],
                    "difficulty": item['difficulty'],
                    "tsq_score": result['tsq_score'],
                    "is_correct": is_correct,
                    "used_tools": used_tools,
                    "expected_function": expected_function
                }
                
                dataset_results.append(item_result)
                
                print(f"  {item['id']}: TSQ={result['tsq_score']:.3f}, "
                      f"정확={is_correct}, 사용툴={used_tools}")
        
        # 데이터셋별 통계
        avg_tsq = sum(r['tsq_score'] for r in dataset_results) / len(dataset_results)
        accuracy = sum(r['is_correct'] for r in dataset_results) / len(dataset_results)
        
        print(f"{dataset_name} 평균 TSQ: {avg_tsq:.3f}")
        print(f"{dataset_name} 정확도: {accuracy:.3f}")
        
        all_results[dataset_name] = {
            "results": dataset_results,
            "avg_tsq": avg_tsq,
            "accuracy": accuracy
        }
    
    # 전체 결과 요약
    print("\n=== 전체 벤치마크 결과 요약 ===")
    overall_tsq = sum(data['avg_tsq'] for data in all_results.values()) / len(all_results)
    overall_accuracy = sum(data['accuracy'] for data in all_results.values()) / len(all_results)
    
    print(f"전체 평균 TSQ: {overall_tsq:.3f}")
    print(f"전체 평균 정확도: {overall_accuracy:.3f}")
    
    return all_results

if __name__ == "__main__":
    run_benchmark_evaluation()
```

## 성능 분석 및 시각화

### 결과 분석 도구 구현

```python
# analysis.py
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
from typing import Dict, List

class PerformanceAnalyzer:
    def __init__(self):
        plt.style.use('seaborn-v0_8')
        self.colors = ['#2E86AB', '#A23B72', '#F18F01', '#C73E1D', '#592E83']
    
    def analyze_results(self, results: Dict) -> Dict:
        """결과 분석 및 통계 생성"""
        analysis = {
            "summary_stats": self._calculate_summary_stats(results),
            "category_performance": self._analyze_by_category(results),
            "difficulty_performance": self._analyze_by_difficulty(results),
            "tool_usage_patterns": self._analyze_tool_usage(results)
        }
        return analysis
    
    def _calculate_summary_stats(self, results: Dict) -> Dict:
        """요약 통계 계산"""
        all_scores = []
        all_accuracies = []
        
        for dataset_results in results.values():
            for item in dataset_results['results']:
                all_scores.append(item['tsq_score'])
                all_accuracies.append(item['is_correct'])
        
        return {
            "total_tests": len(all_scores),
            "avg_tsq_score": sum(all_scores) / len(all_scores),
            "std_tsq_score": pd.Series(all_scores).std(),
            "avg_accuracy": sum(all_accuracies) / len(all_accuracies),
            "min_tsq_score": min(all_scores),
            "max_tsq_score": max(all_scores)
        }
    
    def _analyze_by_category(self, results: Dict) -> Dict:
        """카테고리별 성능 분석"""
        category_stats = {}
        
        for dataset_results in results.values():
            for item in dataset_results['results']:
                category = item['category']
                if category not in category_stats:
                    category_stats[category] = {
                        'scores': [],
                        'accuracies': []
                    }
                
                category_stats[category]['scores'].append(item['tsq_score'])
                category_stats[category]['accuracies'].append(item['is_correct'])
        
        # 카테고리별 평균 계산
        for category in category_stats:
            scores = category_stats[category]['scores']
            accuracies = category_stats[category]['accuracies']
            
            category_stats[category].update({
                'avg_tsq': sum(scores) / len(scores),
                'avg_accuracy': sum(accuracies) / len(accuracies),
                'count': len(scores)
            })
        
        return category_stats
    
    def _analyze_by_difficulty(self, results: Dict) -> Dict:
        """난이도별 성능 분석"""
        difficulty_stats = {}
        
        for dataset_results in results.values():
            for item in dataset_results['results']:
                difficulty = item['difficulty']
                if difficulty not in difficulty_stats:
                    difficulty_stats[difficulty] = {
                        'scores': [],
                        'accuracies': []
                    }
                
                difficulty_stats[difficulty]['scores'].append(item['tsq_score'])
                difficulty_stats[difficulty]['accuracies'].append(item['is_correct'])
        
        # 난이도별 평균 계산
        for difficulty in difficulty_stats:
            scores = difficulty_stats[difficulty]['scores']
            accuracies = difficulty_stats[difficulty]['accuracies']
            
            difficulty_stats[difficulty].update({
                'avg_tsq': sum(scores) / len(scores),
                'avg_accuracy': sum(accuracies) / len(accuracies),
                'count': len(scores)
            })
        
        return difficulty_stats
    
    def _analyze_tool_usage(self, results: Dict) -> Dict:
        """툴 사용 패턴 분석"""
        tool_usage = {}
        
        for dataset_results in results.values():
            for item in dataset_results['results']:
                for tool in item['used_tools']:
                    if tool not in tool_usage:
                        tool_usage[tool] = {
                            'count': 0,
                            'scores': [],
                            'correct_usage': 0
                        }
                    
                    tool_usage[tool]['count'] += 1
                    tool_usage[tool]['scores'].append(item['tsq_score'])
                    
                    if item['is_correct']:
                        tool_usage[tool]['correct_usage'] += 1
        
        # 툴별 통계 계산
        for tool in tool_usage:
            scores = tool_usage[tool]['scores']
            tool_usage[tool].update({
                'avg_tsq': sum(scores) / len(scores) if scores else 0,
                'success_rate': tool_usage[tool]['correct_usage'] / tool_usage[tool]['count']
            })
        
        return tool_usage
    
    def create_visualizations(self, analysis: Dict, save_dir: str = "./plots"):
        """분석 결과 시각화 생성"""
        import os
        os.makedirs(save_dir, exist_ok=True)
        
        # 1. TSQ 점수 분포 히스토그램
        self._plot_tsq_distribution(analysis, save_dir)
        
        # 2. 카테고리별 성능 비교
        self._plot_category_performance(analysis, save_dir)
        
        # 3. 난이도별 성능 비교
        self._plot_difficulty_performance(analysis, save_dir)
        
        # 4. 툴 사용 패턴
        self._plot_tool_usage_patterns(analysis, save_dir)
        
        print(f"시각화 결과가 {save_dir} 디렉토리에 저장되었습니다.")
    
    def _plot_tsq_distribution(self, analysis: Dict, save_dir: str):
        """TSQ 점수 분포 히스토그램"""
        plt.figure(figsize=(10, 6))
        
        # 모든 TSQ 점수 수집 (실제 구현에서는 원본 데이터에서 추출)
        # 여기서는 예시 데이터 생성
        import numpy as np
        np.random.seed(42)
        tsq_scores = np.random.beta(2, 2, 100) * 0.8 + 0.1  # 0.1-0.9 범위의 점수
        
        plt.hist(tsq_scores, bins=20, alpha=0.7, color=self.colors[0], edgecolor='black')
        plt.axvline(analysis['summary_stats']['avg_tsq_score'], 
                   color=self.colors[1], linestyle='--', 
                   label=f'평균: {analysis["summary_stats"]["avg_tsq_score"]:.3f}')
        
        plt.xlabel('TSQ 점수')
        plt.ylabel('빈도')
        plt.title('TSQ 점수 분포')
        plt.legend()
        plt.grid(True, alpha=0.3)
        
        plt.tight_layout()
        plt.savefig(f"{save_dir}/tsq_distribution.png", dpi=300, bbox_inches='tight')
        plt.close()
    
    def _plot_category_performance(self, analysis: Dict, save_dir: str):
        """카테고리별 성능 비교"""
        category_data = analysis['category_performance']
        categories = list(category_data.keys())
        tsq_scores = [category_data[cat]['avg_tsq'] for cat in categories]
        accuracies = [category_data[cat]['avg_accuracy'] for cat in categories]
        
        fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 6))
        
        # TSQ 점수
        bars1 = ax1.bar(categories, tsq_scores, color=self.colors[0], alpha=0.8)
        ax1.set_ylabel('평균 TSQ 점수')
        ax1.set_title('카테고리별 TSQ 성능')
        ax1.set_ylim(0, 1)
        
        # 값 라벨 추가
        for bar, score in zip(bars1, tsq_scores):
            ax1.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.01,
                    f'{score:.3f}', ha='center', va='bottom')
        
        # 정확도
        bars2 = ax2.bar(categories, accuracies, color=self.colors[1], alpha=0.8)
        ax2.set_ylabel('정확도')
        ax2.set_title('카테고리별 정확도')
        ax2.set_ylim(0, 1)
        
        # 값 라벨 추가
        for bar, acc in zip(bars2, accuracies):
            ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.01,
                    f'{acc:.3f}', ha='center', va='bottom')
        
        # x축 라벨 회전
        for ax in [ax1, ax2]:
            ax.tick_params(axis='x', rotation=45)
            ax.grid(True, alpha=0.3)
        
        plt.tight_layout()
        plt.savefig(f"{save_dir}/category_performance.png", dpi=300, bbox_inches='tight')
        plt.close()
    
    def _plot_difficulty_performance(self, analysis: Dict, save_dir: str):
        """난이도별 성능 비교"""
        difficulty_data = analysis['difficulty_performance']
        difficulties = ['easy', 'medium', 'hard']  # 순서 고정
        
        # 데이터가 있는 난이도만 필터링
        available_difficulties = [d for d in difficulties if d in difficulty_data]
        tsq_scores = [difficulty_data[d]['avg_tsq'] for d in available_difficulties]
        accuracies = [difficulty_data[d]['avg_accuracy'] for d in available_difficulties]
        
        fig, ax = plt.subplots(figsize=(10, 6))
        
        x = range(len(available_difficulties))
        width = 0.35
        
        bars1 = ax.bar([i - width/2 for i in x], tsq_scores, width, 
                      label='TSQ 점수', color=self.colors[0], alpha=0.8)
        bars2 = ax.bar([i + width/2 for i in x], accuracies, width, 
                      label='정확도', color=self.colors[1], alpha=0.8)
        
        ax.set_xlabel('난이도')
        ax.set_ylabel('점수')
        ax.set_title('난이도별 성능 비교')
        ax.set_xticks(x)
        ax.set_xticklabels(available_difficulties)
        ax.legend()
        ax.set_ylim(0, 1)
        ax.grid(True, alpha=0.3)
        
        # 값 라벨 추가
        for bars in [bars1, bars2]:
            for bar in bars:
                height = bar.get_height()
                ax.text(bar.get_x() + bar.get_width()/2, height + 0.01,
                       f'{height:.3f}', ha='center', va='bottom')
        
        plt.tight_layout()
        plt.savefig(f"{save_dir}/difficulty_performance.png", dpi=300, bbox_inches='tight')
        plt.close()
    
    def _plot_tool_usage_patterns(self, analysis: Dict, save_dir: str):
        """툴 사용 패턴 분석"""
        tool_data = analysis['tool_usage_patterns']
        tools = list(tool_data.keys())
        
        if not tools:
            return
        
        usage_counts = [tool_data[tool]['count'] for tool in tools]
        success_rates = [tool_data[tool]['success_rate'] for tool in tools]
        
        fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 6))
        
        # 사용 빈도
        bars1 = ax1.bar(tools, usage_counts, color=self.colors[2], alpha=0.8)
        ax1.set_ylabel('사용 횟수')
        ax1.set_title('툴별 사용 빈도')
        ax1.tick_params(axis='x', rotation=45)
        
        for bar, count in zip(bars1, usage_counts):
            ax1.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.1,
                    str(count), ha='center', va='bottom')
        
        # 성공률
        bars2 = ax2.bar(tools, success_rates, color=self.colors[3], alpha=0.8)
        ax2.set_ylabel('성공률')
        ax2.set_title('툴별 성공률')
        ax2.set_ylim(0, 1)
        ax2.tick_params(axis='x', rotation=45)
        
        for bar, rate in zip(bars2, success_rates):
            ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.01,
                    f'{rate:.3f}', ha='center', va='bottom')
        
        for ax in [ax1, ax2]:
            ax.grid(True, alpha=0.3)
        
        plt.tight_layout()
        plt.savefig(f"{save_dir}/tool_usage_patterns.png", dpi=300, bbox_inches='tight')
        plt.close()
    
    def generate_report(self, analysis: Dict, save_path: str = "./evaluation_report.md"):
        """평가 보고서 생성"""
        summary = analysis['summary_stats']
        
        report = f"""# Agent Leaderboard v2 평가 보고서

## 전체 요약

- **총 테스트 수**: {summary['total_tests']}
- **평균 TSQ 점수**: {summary['avg_tsq_score']:.3f} ± {summary['std_tsq_score']:.3f}
- **평균 정확도**: {summary['avg_accuracy']:.3f}
- **최고 TSQ 점수**: {summary['max_tsq_score']:.3f}
- **최저 TSQ 점수**: {summary['min_tsq_score']:.3f}

## 카테고리별 성능

"""
        
        for category, data in analysis['category_performance'].items():
            report += f"### {category}\n"
            report += f"- TSQ 점수: {data['avg_tsq']:.3f}\n"
            report += f"- 정확도: {data['avg_accuracy']:.3f}\n"
            report += f"- 테스트 수: {data['count']}\n\n"
        
        report += "## 난이도별 성능\n\n"
        
        for difficulty, data in analysis['difficulty_performance'].items():
            report += f"### {difficulty.title()}\n"
            report += f"- TSQ 점수: {data['avg_tsq']:.3f}\n"
            report += f"- 정확도: {data['avg_accuracy']:.3f}\n"
            report += f"- 테스트 수: {data['count']}\n\n"
        
        report += "## 툴 사용 분석\n\n"
        
        for tool, data in analysis['tool_usage_patterns'].items():
            report += f"### {tool}\n"
            report += f"- 사용 횟수: {data['count']}\n"
            report += f"- 평균 TSQ: {data['avg_tsq']:.3f}\n"
            report += f"- 성공률: {data['success_rate']:.3f}\n\n"
        
        with open(save_path, 'w', encoding='utf-8') as f:
            f.write(report)
        
        print(f"평가 보고서가 {save_path}에 저장되었습니다.")

# 분석 실행 스크립트
def run_complete_analysis():
    """전체 분석 실행"""
    from benchmark_datasets import run_benchmark_evaluation
    
    # 벤치마크 평가 실행
    results = run_benchmark_evaluation()
    
    # 결과 분석
    analyzer = PerformanceAnalyzer()
    analysis = analyzer.analyze_results(results)
    
    # 시각화 생성
    analyzer.create_visualizations(analysis)
    
    # 보고서 생성
    analyzer.generate_report(analysis)
    
    print("\n=== 분석 완료 ===")
    print("시각화와 보고서가 생성되었습니다.")
    
    return analysis

if __name__ == "__main__":
    run_complete_analysis()
```

## 실제 Hugging Face 리더보드 활용하기

### 리더보드 API 접근

```python
# leaderboard_api.py
import requests
import pandas as pd
from typing import Dict, List

class AgentLeaderboardAPI:
    def __init__(self):
        self.base_url = "https://huggingface.co/spaces/galileo-ai/agent-leaderboard"
        self.api_url = "https://huggingface.co/datasets/galileo-ai/agent-leaderboard"
    
    def fetch_leaderboard_data(self) -> pd.DataFrame:
        """리더보드 데이터 가져오기"""
        try:
            # 실제 API 엔드포인트가 있다면 사용
            # 여기서는 예시 데이터 생성
            data = self._create_example_leaderboard_data()
            return pd.DataFrame(data)
        except Exception as e:
            print(f"리더보드 데이터 가져오기 실패: {e}")
            return pd.DataFrame()
    
    def _create_example_leaderboard_data(self) -> List[Dict]:
        """예시 리더보드 데이터 생성"""
        return [
            {
                "rank": 1,
                "model": "Gemini-2.0-flash",
                "overall_score": 0.938,
                "composite_scenarios": 0.95,
                "irrelevance_detection": 0.98,
                "single_function": 0.99,
                "cost_per_million": 0.15
            },
            {
                "rank": 2,
                "model": "GPT-4o",
                "overall_score": 0.900,
                "composite_scenarios": 0.92,
                "irrelevance_detection": 0.95,
                "single_function": 0.98,
                "cost_per_million": 2.5
            },
            {
                "rank": 3,
                "model": "Gemini-1.5-flash",
                "overall_score": 0.895,
                "composite_scenarios": 0.91,
                "irrelevance_detection": 0.98,
                "single_function": 0.99,
                "cost_per_million": 0.075
            },
            {
                "rank": 4,
                "model": "Gemini-1.5-pro",
                "overall_score": 0.885,
                "composite_scenarios": 0.93,
                "irrelevance_detection": 0.95,
                "single_function": 0.99,
                "cost_per_million": 1.25
            },
            {
                "rank": 5,
                "model": "o1",
                "overall_score": 0.876,
                "composite_scenarios": 0.89,
                "irrelevance_detection": 0.94,
                "single_function": 0.96,
                "cost_per_million": 15.0
            }
        ]
    
    def analyze_cost_performance_frontier(self, df: pd.DataFrame) -> Dict:
        """비용-성능 프론티어 분석"""
        if df.empty:
            return {}
        
        # 파레토 프론티어 계산
        pareto_optimal = []
        
        for i, row in df.iterrows():
            is_pareto = True
            for j, other_row in df.iterrows():
                if i != j:
                    # 더 높은 성능과 더 낮은 비용을 가진 모델이 있는지 확인
                    if (other_row['overall_score'] >= row['overall_score'] and 
                        other_row['cost_per_million'] <= row['cost_per_million'] and
                        (other_row['overall_score'] > row['overall_score'] or 
                         other_row['cost_per_million'] < row['cost_per_million'])):
                        is_pareto = False
                        break
            
            if is_pareto:
                pareto_optimal.append(i)
        
        return {
            "pareto_optimal_indices": pareto_optimal,
            "pareto_models": df.iloc[pareto_optimal]['model'].tolist(),
            "efficiency_ratio": df['overall_score'] / df['cost_per_million']
        }
    
    def compare_models(self, model_names: List[str], df: pd.DataFrame) -> Dict:
        """특정 모델들 비교 분석"""
        if df.empty:
            return {}
        
        comparison_data = df[df['model'].isin(model_names)]
        
        if comparison_data.empty:
            return {"error": "지정된 모델들을 찾을 수 없습니다."}
        
        metrics = ['overall_score', 'composite_scenarios', 'irrelevance_detection', 'single_function']
        
        comparison = {}
        for metric in metrics:
            comparison[metric] = {
                "best_model": comparison_data.loc[comparison_data[metric].idxmax(), 'model'],
                "best_score": comparison_data[metric].max(),
                "worst_model": comparison_data.loc[comparison_data[metric].idxmin(), 'model'],
                "worst_score": comparison_data[metric].min(),
                "average": comparison_data[metric].mean(),
                "std": comparison_data[metric].std()
            }
        
        return comparison
    
    def get_model_recommendations(self, budget: float, min_performance: float, df: pd.DataFrame) -> List[Dict]:
        """예산과 성능 요구사항에 따른 모델 추천"""
        if df.empty:
            return []
        
        # 예산 내 모델 필터링
        affordable_models = df[df['cost_per_million'] <= budget]
        
        # 최소 성능 요구사항 충족 모델 필터링
        suitable_models = affordable_models[affordable_models['overall_score'] >= min_performance]
        
        if suitable_models.empty:
            return []
        
        # 성능 대비 비용 효율성으로 정렬
        suitable_models = suitable_models.copy()
        suitable_models['efficiency'] = suitable_models['overall_score'] / suitable_models['cost_per_million']
        suitable_models = suitable_models.sort_values('efficiency', ascending=False)
        
        recommendations = []
        for _, row in suitable_models.head(3).iterrows():
            recommendations.append({
                "model": row['model'],
                "overall_score": row['overall_score'],
                "cost_per_million": row['cost_per_million'],
                "efficiency_ratio": row['efficiency'],
                "rank": int(row['rank'])
            })
        
        return recommendations

def demonstrate_leaderboard_analysis():
    """리더보드 분석 시연"""
    print("=== Agent Leaderboard v2 분석 시연 ===")
    
    api = AgentLeaderboardAPI()
    df = api.fetch_leaderboard_data()
    
    if df.empty:
        print("리더보드 데이터를 가져올 수 없습니다.")
        return
    
    print("\n1. 현재 리더보드 상위 5개 모델:")
    print(df[['rank', 'model', 'overall_score', 'cost_per_million']].head())
    
    # 비용-성능 분석
    frontier_analysis = api.analyze_cost_performance_frontier(df)
    print(f"\n2. 파레토 최적 모델들: {frontier_analysis['pareto_models']}")
    
    # 모델 비교
    comparison_models = ['Gemini-2.0-flash', 'GPT-4o', 'Gemini-1.5-flash']
    comparison = api.compare_models(comparison_models, df)
    
    print(f"\n3. {', '.join(comparison_models)} 비교:")
    for metric, data in comparison.items():
        if isinstance(data, dict) and 'best_model' in data:
            print(f"  {metric}: {data['best_model']} ({data['best_score']:.3f})")
    
    # 모델 추천
    budget = 2.0  # $2.0 per million tokens
    min_performance = 0.85
    recommendations = api.get_model_recommendations(budget, min_performance, df)
    
    print(f"\n4. 예산 ${budget}/M, 최소 성능 {min_performance} 조건에서 추천 모델:")
    for i, rec in enumerate(recommendations, 1):
        print(f"  {i}. {rec['model']} (점수: {rec['overall_score']:.3f}, "
              f"비용: ${rec['cost_per_million']}/M, 효율성: {rec['efficiency_ratio']:.2f})")

if __name__ == "__main__":
    demonstrate_leaderboard_analysis()
```

## 고급 평가 기법 및 최적화

### 에지 케이스 및 실패 사례 분석

```python
# edge_cases.py
from typing import List, Dict, Optional
import json

class EdgeCaseAnalyzer:
    def __init__(self):
        self.edge_cases = {
            "irrelevance_detection": self._create_irrelevance_cases(),
            "missing_parameters": self._create_missing_param_cases(),
            "tool_sequence": self._create_sequence_cases(),
            "context_length": self._create_long_context_cases(),
            "ambiguous_queries": self._create_ambiguous_cases()
        }
    
    def _create_irrelevance_cases(self) -> List[Dict]:
        """관련성 없는 쿼리 테스트 케이스"""
        return [
            {
                "query": "오늘 기분이 어때요?",
                "expected_behavior": "no_tool_use",
                "description": "감정 상태 문의 - 툴 사용 불필요"
            },
            {
                "query": "안녕하세요! 좋은 하루 보내세요.",
                "expected_behavior": "no_tool_use", 
                "description": "인사말 - 툴 사용 불필요"
            },
            {
                "query": "AI에 대한 철학적 질문이 있어요.",
                "expected_behavior": "no_tool_use",
                "description": "철학적 질문 - 사용 가능한 툴로 답변 불가"
            }
        ]
    
    def _create_missing_param_cases(self) -> List[Dict]:
        """매개변수 누락 테스트 케이스"""
        return [
            {
                "query": "날씨를 알려주세요",  # 위치 정보 누락
                "expected_behavior": "request_missing_param",
                "missing_param": "location",
                "description": "날씨 조회 시 위치 정보 누락"
            },
            {
                "query": "이메일을 보내주세요",  # 수신자, 제목, 내용 누락
                "expected_behavior": "request_missing_param",
                "missing_param": ["to", "subject", "body"],
                "description": "이메일 발송 시 필수 정보 누락"
            }
        ]
    
    def _create_sequence_cases(self) -> List[Dict]:
        """툴 순서 의존성 테스트 케이스"""
        return [
            {
                "query": "서울 날씨를 확인하고 그 결과를 john@example.com에게 이메일로 보내주세요",
                "expected_sequence": ["get_weather", "send_email"],
                "description": "날씨 조회 후 이메일 발송 - 순차 실행 필요"
            },
            {
                "query": "15 * 23을 계산하고 결과에 대해 웹검색을 해주세요",
                "expected_sequence": ["calculator", "search_web"],
                "description": "계산 후 검색 - 이전 결과 활용 필요"
            }
        ]
    
    def _create_long_context_cases(self) -> List[Dict]:
        """긴 컨텍스트 테스트 케이스"""
        long_context = """
        이전 대화 내용:
        사용자: 오늘 서울 날씨 어때요?
        어시스턴트: 서울의 현재 날씨는 맑음이고 기온은 18도입니다.
        사용자: 도쿄는 어떤가요?
        어시스턴트: 도쿄는 흐림이고 기온은 22도입니다.
        사용자: 15 + 25는 얼마인가요?
        어시스턴트: 15 + 25 = 40입니다.
        """
        
        return [
            {
                "context": long_context,
                "query": "앞서 말한 서울 날씨를 다시 알려주세요",
                "expected_behavior": "use_context",
                "description": "이전 대화에서 정보 재사용"
            },
            {
                "context": long_context,
                "query": "계산 결과에 5를 더하면 얼마인가요?",
                "expected_behavior": "use_context_and_calculate",
                "description": "이전 계산 결과 활용한 추가 계산"
            }
        ]
    
    def _create_ambiguous_cases(self) -> List[Dict]:
        """모호한 쿼리 테스트 케이스"""
        return [
            {
                "query": "그거 좀 찾아줘",
                "expected_behavior": "request_clarification",
                "description": "명확하지 않은 검색 요청"
            },
            {
                "query": "이메일 보내",
                "expected_behavior": "request_details",
                "description": "불완전한 이메일 발송 요청"
            }
        ]
    
    def evaluate_edge_cases(self, evaluator, tools) -> Dict:
        """에지 케이스 평가 실행"""
        results = {}
        
        for category, cases in self.edge_cases.items():
            print(f"\n=== {category.upper()} 에지 케이스 평가 ===")
            category_results = []
            
            for case in cases:
                conversation = [{"role": "system", "content": "You are a helpful assistant."}]
                
                if 'context' in case:
                    conversation.append({
                        "role": "assistant",
                        "content": case['context']
                    })
                
                conversation.append({
                    "role": "user",
                    "content": case['query']
                })
                
                result = evaluator.evaluate_single_interaction(
                    tools=tools,
                    conversation=conversation,
                    expected_outcome=case['expected_behavior']
                )
                
                if result:
                    # 에지 케이스별 특수 평가
                    edge_score = self._evaluate_edge_case_response(case, result)
                    
                    case_result = {
                        "description": case['description'],
                        "tsq_score": result['tsq_score'],
                        "edge_case_score": edge_score,
                        "tools_used": result['evaluation_details']['tools_used'],
                        "expected_behavior": case['expected_behavior']
                    }
                    
                    category_results.append(case_result)
                    
                    print(f"  {case['description']}")
                    print(f"    TSQ: {result['tsq_score']:.3f}, Edge Score: {edge_score:.3f}")
            
            results[category] = category_results
        
        return results
    
    def _evaluate_edge_case_response(self, case: Dict, result: Dict) -> float:
        """에지 케이스별 특수 평가 점수 계산"""
        expected_behavior = case['expected_behavior']
        tools_used = result['evaluation_details']['tools_used']
        
        if expected_behavior == "no_tool_use":
            # 툴을 사용하지 않아야 하는 경우
            return 1.0 if len(tools_used) == 0 else 0.0
        
        elif expected_behavior == "request_missing_param":
            # 누락된 매개변수를 요청해야 하는 경우
            # 실제로는 LLM 응답 내용을 분석해야 함
            return 0.8  # 단순화된 점수
        
        elif expected_behavior == "use_context":
            # 컨텍스트를 활용해야 하는 경우
            return 1.0 if len(tools_used) == 0 else 0.5
        
        elif expected_behavior == "use_context_and_calculate":
            # 컨텍스트 활용 + 계산
            return 1.0 if "calculator" in tools_used else 0.0
        
        elif expected_behavior.startswith("request_"):
            # 추가 정보 요청이 필요한 경우
            return 0.9  # 단순화된 점수
        
        else:
            return 0.5  # 기본 점수

def run_edge_case_evaluation():
    """에지 케이스 평가 실행"""
    from evaluator import TSQEvaluator
    from tools import create_sample_tools
    
    evaluator = TSQEvaluator()
    tools = create_sample_tools()
    analyzer = EdgeCaseAnalyzer()
    
    edge_results = analyzer.evaluate_edge_cases(evaluator, tools)
    
    # 결과 요약
    print("\n=== 에지 케이스 평가 요약 ===")
    total_cases = 0
    total_tsq = 0
    total_edge_score = 0
    
    for category, results in edge_results.items():
        if results:
            cat_tsq = sum(r['tsq_score'] for r in results) / len(results)
            cat_edge = sum(r['edge_case_score'] for r in results) / len(results)
            
            print(f"{category}: TSQ={cat_tsq:.3f}, Edge Score={cat_edge:.3f} ({len(results)} cases)")
            
            total_cases += len(results)
            total_tsq += sum(r['tsq_score'] for r in results)
            total_edge_score += sum(r['edge_case_score'] for r in results)
    
    if total_cases > 0:
        print(f"\n전체 평균: TSQ={total_tsq/total_cases:.3f}, "
              f"Edge Score={total_edge_score/total_cases:.3f}")
    
    return edge_results

if __name__ == "__main__":
    run_edge_case_evaluation()
```

## 실행 스크립트 및 자동화

### 메인 실행 스크립트

```python
# main.py
import os
import sys
from datetime import datetime
import argparse

def setup_environment():
    """환경 설정 확인"""
    required_env_vars = ['OPENAI_API_KEY']
    missing_vars = [var for var in required_env_vars if not os.getenv(var)]
    
    if missing_vars:
        print(f"필수 환경변수가 설정되지 않았습니다: {missing_vars}")
        print("다음 명령어로 설정하세요:")
        for var in missing_vars:
            print(f"export {var}=your_value_here")
        sys.exit(1)
    
    print("✅ 환경변수 설정 완료")

def install_dependencies():
    """의존성 패키지 설치"""
    try:
        import openai
        import pandas
        import matplotlib
        import seaborn
        print("✅ 필수 패키지 설치 확인 완료")
    except ImportError as e:
        print(f"❌ 필수 패키지가 설치되지 않았습니다: {e}")
        print("다음 명령어로 설치하세요:")
        print("pip install openai pandas matplotlib seaborn")
        sys.exit(1)

def run_basic_evaluation():
    """기본 평가 실행"""
    print("\n=== 기본 TSQ 평가 실행 ===")
    from scenario_basic import run_basic_tool_usage_scenario
    return run_basic_tool_usage_scenario()

def run_complex_evaluation():
    """복합 평가 실행"""
    print("\n=== 복합 툴 사용 평가 실행 ===")
    from scenario_complex import run_complex_tool_usage_scenario
    return run_complex_tool_usage_scenario()

def run_benchmark_evaluation():
    """벤치마크 평가 실행"""
    print("\n=== 벤치마크 데이터셋 평가 실행 ===")
    from benchmark_datasets import run_benchmark_evaluation
    return run_benchmark_evaluation()

def run_edge_case_evaluation():
    """에지 케이스 평가 실행"""
    print("\n=== 에지 케이스 평가 실행 ===")
    from edge_cases import run_edge_case_evaluation
    return run_edge_case_evaluation()

def run_leaderboard_analysis():
    """리더보드 분석 실행"""
    print("\n=== 리더보드 분석 실행 ===")
    from leaderboard_api import demonstrate_leaderboard_analysis
    return demonstrate_leaderboard_analysis()

def generate_comprehensive_report(all_results):
    """종합 보고서 생성"""
    print("\n=== 종합 보고서 생성 ===")
    from analysis import PerformanceAnalyzer
    
    analyzer = PerformanceAnalyzer()
    
    # 모든 결과를 통합하여 분석
    combined_analysis = {}
    
    if 'benchmark' in all_results:
        combined_analysis = analyzer.analyze_results(all_results['benchmark'])
        analyzer.create_visualizations(combined_analysis)
        analyzer.generate_report(combined_analysis)
    
    return combined_analysis

def main():
    """메인 실행 함수"""
    parser = argparse.ArgumentParser(description='Agent Leaderboard v2 평가 도구')
    parser.add_argument('--basic', action='store_true', help='기본 평가만 실행')
    parser.add_argument('--complex', action='store_true', help='복합 평가만 실행')
    parser.add_argument('--benchmark', action='store_true', help='벤치마크 평가만 실행')
    parser.add_argument('--edge', action='store_true', help='에지 케이스 평가만 실행')
    parser.add_argument('--leaderboard', action='store_true', help='리더보드 분석만 실행')
    parser.add_argument('--all', action='store_true', help='모든 평가 실행 (기본값)')
    
    args = parser.parse_args()
    
    print("🚀 Agent Leaderboard v2 평가 도구 시작")
    print(f"⏰ 시작 시간: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # 환경 설정 확인
    setup_environment()
    install_dependencies()
    
    # 결과 저장용 딕셔너리
    all_results = {}
    
    try:
        if args.basic or args.all or (not any([args.basic, args.complex, args.benchmark, args.edge, args.leaderboard])):
            all_results['basic'] = run_basic_evaluation()
        
        if args.complex or args.all or (not any([args.basic, args.complex, args.benchmark, args.edge, args.leaderboard])):
            all_results['complex'] = run_complex_evaluation()
        
        if args.benchmark or args.all or (not any([args.basic, args.complex, args.benchmark, args.edge, args.leaderboard])):
            all_results['benchmark'] = run_benchmark_evaluation()
        
        if args.edge or args.all or (not any([args.basic, args.complex, args.benchmark, args.edge, args.leaderboard])):
            all_results['edge'] = run_edge_case_evaluation()
        
        if args.leaderboard or args.all or (not any([args.basic, args.complex, args.benchmark, args.edge, args.leaderboard])):
            run_leaderboard_analysis()
        
        # 종합 보고서 생성
        if len(all_results) > 1 or args.all:
            generate_comprehensive_report(all_results)
        
        print(f"\n✅ 모든 평가 완료!")
        print(f"⏰ 종료 시간: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print("\n📊 생성된 파일들:")
        print("  - evaluation_report.md (평가 보고서)")
        print("  - plots/ (시각화 결과)")
        print("  - app.log (로그 파일)")
        
    except Exception as e:
        print(f"❌ 평가 중 오류 발생: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()
```

### 자동화 스크립트

```bash
#!/bin/bash
# run_evaluation.sh

echo "🚀 Agent Leaderboard v2 평가 자동화 스크립트"

# 가상환경 활성화 확인
if [[ "$VIRTUAL_ENV" == "" ]]; then
    echo "❌ Python 가상환경이 활성화되지 않았습니다."
    echo "다음 명령어로 활성화하세요:"
    echo "source venv/bin/activate"
    exit 1
fi

# 환경변수 확인
if [[ -z "$OPENAI_API_KEY" ]]; then
    echo "❌ OPENAI_API_KEY 환경변수가 설정되지 않았습니다."
    echo "export OPENAI_API_KEY=your_api_key_here"
    exit 1
fi

echo "✅ 환경 설정 확인 완료"

# 결과 디렉토리 생성
mkdir -p results plots logs

# 타임스탬프 생성
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo "🔄 평가 시작 (${TIMESTAMP})"

# Python 평가 스크립트 실행
python main.py --all 2>&1 | tee "logs/evaluation_${TIMESTAMP}.log"

# 결과 백업
if [[ -f "evaluation_report.md" ]]; then
    cp evaluation_report.md "results/evaluation_report_${TIMESTAMP}.md"
fi

if [[ -d "plots" ]]; then
    cp -r plots "results/plots_${TIMESTAMP}"
fi

echo "✅ 평가 완료! 결과는 results/ 디렉토리에서 확인하세요."
echo "📊 주요 결과 파일:"
echo "  - results/evaluation_report_${TIMESTAMP}.md"
echo "  - results/plots_${TIMESTAMP}/"
echo "  - logs/evaluation_${TIMESTAMP}.log"

# 결과 요약 출력
if [[ -f "evaluation_report.md" ]]; then
    echo ""
    echo "📈 평가 결과 요약:"
    grep -E "평균|총|Overall" evaluation_report.md | head -5
fi
```

### zshrc Aliases 설정

```bash
# ~/.zshrc에 추가할 alias들

# Agent Leaderboard v2 관련 aliases
alias agent-eval="cd ~/agent-leaderboard-tutorial && source venv/bin/activate"
alias agent-basic="python main.py --basic"
alias agent-complex="python main.py --complex"
alias agent-benchmark="python main.py --benchmark"
alias agent-edge="python main.py --edge"
alias agent-all="python main.py --all"
alias agent-leaderboard="python main.py --leaderboard"
alias agent-run="bash run_evaluation.sh"

# 결과 확인 aliases
alias agent-report="cat evaluation_report.md"
alias agent-plots="open plots/"
alias agent-logs="tail -f logs/evaluation_*.log"
alias agent-results="ls -la results/"

# 환경 설정 aliases
alias agent-env="export OPENAI_API_KEY="
alias agent-check="python -c 'import openai; print(\"OpenAI:\", openai.__version__)'"
alias agent-deps="pip install openai pandas matplotlib seaborn promptquality"

# 편의 기능 aliases
alias agent-clean="rm -rf plots/*.png evaluation_report.md logs/*.log"
alias agent-backup="cp -r . ~/agent-leaderboard-backup-$(date +%Y%m%d)"
```

## 테스트 실행 및 결과 검증

### 로컬 테스트 수행

```bash
# 프로젝트 디렉토리로 이동
cd ~/agent-leaderboard-tutorial

# 가상환경 활성화
source venv/bin/activate

# 환경변수 설정 (본인의 API 키로 대체)
export OPENAI_API_KEY="your-openai-api-key-here"

# 의존성 설치 확인
python -c "import openai, pandas, matplotlib; print('✅ 패키지 설치 확인 완료')"

# 기본 평가 테스트
python main.py --basic

# 전체 평가 테스트 (시간이 오래 걸릴 수 있음)
python main.py --all
```

### 개발환경 버전 정보

테스트 환경:
- **Python**: 3.9.16
- **OpenAI**: 1.3.7
- **Pandas**: 2.0.3
- **Matplotlib**: 3.7.2
- **Seaborn**: 0.12.2

```bash
# 개발환경 버전 확인
python --version
pip list | grep -E "(openai|pandas|matplotlib|seaborn)"
```

## 결론

Agent Leaderboard v2는 AI 에이전트의 툴 사용 능력을 종합적으로 평가하는 혁신적인 플랫폼입니다. 이 튜토리얼을 통해 다음과 같은 핵심 내용을 학습했습니다:

### 주요 학습 내용

1. **TSQ 메트릭의 이해**: Tool Selection Quality가 어떻게 에이전트의 복합적 능력을 평가하는지
2. **실습 환경 구축**: macOS에서 Agent Leaderboard v2 평가 시스템을 직접 구현
3. **다양한 평가 시나리오**: 기본 툴 사용부터 복잡한 에지 케이스까지
4. **벤치마크 데이터셋 활용**: BFCL, τ-bench, xLAM, ToolACE 스타일의 평가 구현
5. **성능 분석 및 시각화**: 평가 결과를 체계적으로 분석하고 시각화하는 방법

### 실무 적용 방안

- **모델 선택 가이드**: 비용과 성능을 고려한 최적 모델 선택
- **성능 모니터링**: 지속적인 에이전트 성능 추적 및 개선
- **에지 케이스 대응**: 실제 운영 환경에서 발생할 수 있는 예외 상황 처리

### 향후 발전 방향

Agent Leaderboard v2는 매월 업데이트되며, 새로운 모델과 평가 기법이 지속적으로 추가됩니다. 이 플랫폼을 통해 AI 에이전트의 성능을 객관적으로 평가하고 개선함으로써, 더 신뢰할 수 있고 효과적인 AI 시스템을 구축할 수 있습니다.

AI 에이전트가 "디지털 워크포스"로 자리잡아가는 지금, 정확한 성능 평가와 벤치마킹은 성공적인 AI 도입의 핵심 요소입니다. Agent Leaderboard v2와 같은 도구를 활용하여 여러분의 AI 프로젝트를 한 단계 더 발전시켜보시기 바랍니다. 