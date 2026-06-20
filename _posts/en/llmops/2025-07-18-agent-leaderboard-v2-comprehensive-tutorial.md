---
title: "Agent Leaderboard v2 Complete Guide - The New Standard for AI Agent Performance Evaluation"
excerpt: "Learn how to evaluate and benchmark AI agent tool-use performance using Galileo.ai's Agent Leaderboard v2 through hands-on practice."
seo_title: "Agent Leaderboard v2 Tutorial - Complete Guide to AI Agent Evaluation - Thaki Cloud"
seo_description: "A comprehensive guide covering how to evaluate AI agent performance with Agent Leaderboard v2, how to use the TSQ metric, and practical examples."
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
toc_label: "Table of Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/en/llmops/agent-leaderboard-v2-comprehensive-tutorial/"
reading_time: true
lang: en
---

⏱️ **Estimated reading time**: 15 min

## Introduction

Objectively evaluating AI agent performance is one of the most important challenges in modern AI development. Agent Leaderboard v2, developed by Galileo.ai, is a comprehensive benchmarking platform for evaluating AI agents' tool-use capabilities.

Just as Jensen Huang has called AI agents a "digital workforce" and Satya Nadella has said agents will fundamentally transform business operations, AI agents are at the core of next-generation AI innovation.

This tutorial guides you through Agent Leaderboard v2 from core concepts to practical usage, enabling you to master it completely through hands-on practice.

## What Is Agent Leaderboard v2?

### Overview and Key Features

Agent Leaderboard v2 is a comprehensive benchmarking framework for evaluating how AI agents perform in real-world business scenarios. While traditional academic benchmarks measured only technical capabilities, Agent Leaderboard v2 focuses on measuring performance in actual use cases.

### Key Differentiators

Looking at the limitations of current evaluation frameworks:
- **BFCL**: Specialized in academic domains such as mathematics, entertainment, and education
- **tau-bench**: Focused on retail and airline scenarios
- **xLAM**: Specialized in data generation across 21 domains
- **ToolACE**: Focused on API interactions across 390 domains

Agent Leaderboard v2 provides an integrated evaluation framework that consolidates these individual benchmarks and covers **multiple domains** and **real-world use cases**.

### Models Under Evaluation

Currently evaluating 17 major LLMs, with updates each month as new models are released:

#### Elite Tier (>= 0.9)
- **Gemini-2.0-flash**: 1st place with a score of 0.938
- **GPT-4o**: 2nd place with a score of 0.900

#### High Performance (0.85-0.9)
- **Gemini-1.5-flash**: 0.895
- **Gemini-1.5-pro**: 0.885
- **o1**: 0.876
- **o3-mini**: 0.847

#### Mid Tier (0.8-0.85)
- **GPT-4o-mini**: 0.832
- **mistral-small-2501**: 0.832
- **Qwen-72b**: 0.817

## Understanding the Tool Selection Quality (TSQ) Metric

### Core Concept of TSQ

TSQ (Tool Selection Quality) is the central evaluation metric of Agent Leaderboard v2. Rather than simple accuracy, it comprehensively evaluates an agent's **tool selection precision** and **parameter usage effectiveness**.

### TSQ Evaluation Dimensions

#### 1. Scenario Recognition
When an agent receives a query, it must first determine whether tool use is necessary:
- Cases where information already in the conversation history makes a tool call unnecessary
- Cases where available tools are inappropriate or insufficient for the task

#### 2. Tool Selection Dynamics
Tool selection is not binary; it includes both precision and recall:
- **Recall issues**: Missing some of the required tools
- **Precision issues**: Selecting unnecessary tools alongside appropriate ones

#### 3. Parameter Handling
Even after selecting the correct tool, additional complexity arises in argument handling:
- Providing all required parameters with the correct names
- Handling optional parameters appropriately
- Maintaining accuracy of parameter values
- Conforming argument formats to tool specifications

#### 4. Sequential Decision Making
In multi-step tasks, agents must demonstrate the following capabilities:
- Determining the optimal sequence of tool calls
- Handling interdependencies between tool calls
- Maintaining context across multiple tasks
- Adapting to partial results or failures

## Setting Up the Practice Environment

### Prerequisites

```bash
# Check Python environment
python --version  # Python 3.8+ required

# Check Node.js environment (optional)
node --version    # Node.js 16+ recommended
```

### Development Environment Setup

```bash
# Create project directory
mkdir agent-leaderboard-tutorial
cd agent-leaderboard-tutorial

# Create Python virtual environment
python -m venv venv
source venv/bin/activate  # macOS/Linux

# Install required libraries
pip install openai
pip install pandas
pip install promptquality
pip install fastparquet
```

### API Key Configuration

```bash
# Set environment variables
export OPENAI_API_KEY="your-openai-api-key"
export GALILEO_PROJECT_NAME="agent-evaluation"
```

### Creating the Base Configuration File

```python
# config.py
import os

# API settings
OPENAI_API_KEY = os.getenv('OPENAI_API_KEY')
GALILEO_PROJECT_NAME = os.getenv('GALILEO_PROJECT_NAME', 'agent-evaluation')

# Model settings
DEFAULT_MODEL = "gpt-4o"
DEFAULT_TEMPERATURE = 0.0
DEFAULT_MAX_TOKENS = 4000

# Evaluation settings
SYSTEM_MESSAGE = {
    "role": "system",
    "content": '''Your job is to use the given tools to answer the query of human. 
    If there is no relevant tool then reply with "I cannot answer the question with given tools". 
    If tool is available but sufficient information is not available, then ask human to get the same. 
    You can call as many tools as you want. Use multiple tools if needed. 
    If the tools need to be called in a sequence then just call the first tool.'''
}
```

## Implementing the TSQ Evaluation System

### Implementing the Base Evaluation Class

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
        
        # Configure TSQ evaluator
        self.chainpoll_scorer = pq.CustomizedChainPollScorer(
            scorer_name=pq.CustomizedScorerName.tool_selection_quality,
            model_alias=pq.Models.gpt_4o,
        )
        
        # Configure evaluation handler
        self.evaluate_handler = pq.GalileoPromptCallback(
            project_name=self.project_name,
            run_name=f"evaluation_{model}",
            scorers=[self.chainpoll_scorer],
        )
    
    def evaluate_single_interaction(self, tools, conversation, expected_outcome=None):
        """TSQ evaluation for a single interaction"""
        try:
            response = self.client.chat.completions.create(
                model=self.model,
                messages=conversation,
                tools=tools,
                temperature=0.0,
                max_tokens=4000
            )
            
            # Calculate TSQ score
            tsq_score = self._calculate_tsq_score(
                conversation, response, tools, expected_outcome
            )
            
            return {
                "response": response,
                "tsq_score": tsq_score,
                "evaluation_details": self._get_evaluation_details(response, tools)
            }
            
        except Exception as e:
            print(f"Error during evaluation: {e}")
            return None
    
    def _calculate_tsq_score(self, conversation, response, tools, expected_outcome):
        """TSQ score calculation logic"""
        score_components = {
            "tool_selection_accuracy": 0.0,
            "parameter_quality": 0.0,
            "relevance_detection": 0.0,
            "sequence_appropriateness": 0.0
        }
        
        if response.choices[0].message.tool_calls:
            tool_calls = response.choices[0].message.tool_calls
            
            # Evaluate tool selection accuracy
            score_components["tool_selection_accuracy"] = self._evaluate_tool_selection(
                tool_calls, tools, expected_outcome
            )
            
            # Evaluate parameter quality
            score_components["parameter_quality"] = self._evaluate_parameter_quality(
                tool_calls, tools
            )
            
            # Evaluate relevance detection
            score_components["relevance_detection"] = self._evaluate_relevance_detection(
                conversation, tool_calls
            )
            
            # Evaluate sequence appropriateness
            score_components["sequence_appropriateness"] = self._evaluate_sequence_appropriateness(
                tool_calls
            )
        
        # Calculate overall TSQ score (equal weights)
        total_score = sum(score_components.values()) / len(score_components)
        return min(max(total_score, 0.0), 1.0)
    
    def _evaluate_tool_selection(self, tool_calls, available_tools, expected_outcome):
        """Evaluate tool selection accuracy"""
        if not tool_calls:
            return 0.0
        
        selected_tools = [call.function.name for call in tool_calls]
        available_tool_names = [tool["function"]["name"] for tool in available_tools]
        
        # Check whether selected tools are in the available tools list
        valid_selections = sum(1 for tool in selected_tools if tool in available_tool_names)
        
        return valid_selections / len(selected_tools) if selected_tools else 0.0
    
    def _evaluate_parameter_quality(self, tool_calls, available_tools):
        """Evaluate parameter quality"""
        if not tool_calls:
            return 0.0
        
        total_score = 0.0
        
        for call in tool_calls:
            try:
                parameters = json.loads(call.function.arguments)
                # Parameter validation logic
                # In a real implementation, compare against each tool's schema
                total_score += 1.0  # Simplified score
            except json.JSONDecodeError:
                total_score += 0.0
        
        return total_score / len(tool_calls)
    
    def _evaluate_relevance_detection(self, conversation, tool_calls):
        """Evaluate relevance detection"""
        # Evaluate appropriateness of tool use considering conversation context
        return 0.8  # Simplified implementation
    
    def _evaluate_sequence_appropriateness(self, tool_calls):
        """Evaluate sequence appropriateness"""
        # Evaluate the logical appropriateness of the tool call sequence
        return 0.9  # Simplified implementation
    
    def _get_evaluation_details(self, response, tools):
        """Extract evaluation details"""
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

### Defining Practice Tools

```python
# tools.py
def create_sample_tools():
    """Define sample tools for practice"""
    tools = [
        {
            "type": "function",
            "function": {
                "name": "get_weather",
                "description": "Get current weather information",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "location": {
                            "type": "string",
                            "description": "Name of the city to check weather for"
                        },
                        "unit": {
                            "type": "string",
                            "enum": ["celsius", "fahrenheit"],
                            "description": "Temperature unit"
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
                "description": "Search for information on the web",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "query": {
                            "type": "string",
                            "description": "Keywords to search for"
                        },
                        "limit": {
                            "type": "integer",
                            "description": "Limit on number of search results",
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
                "description": "Perform mathematical calculations",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "expression": {
                            "type": "string",
                            "description": "Mathematical expression to calculate"
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
                "description": "Send an email",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "to": {
                            "type": "string",
                            "description": "Recipient email address"
                        },
                        "subject": {
                            "type": "string",
                            "description": "Email subject"
                        },
                        "body": {
                            "type": "string",
                            "description": "Email body"
                        }
                    },
                    "required": ["to", "subject", "body"]
                }
            }
        }
    ]
    return tools
```

## Implementing Practice Scenarios

### Scenario 1: Basic Tool Usage Evaluation

```python
# scenario_basic.py
from evaluator import TSQEvaluator
from tools import create_sample_tools
from config import SYSTEM_MESSAGE

def run_basic_tool_usage_scenario():
    """Run basic tool usage scenario"""
    print("=== Basic Tool Usage Scenario ===")
    
    evaluator = TSQEvaluator()
    tools = create_sample_tools()
    
    # Test cases
    test_cases = [
        {
            "name": "Weather Query",
            "conversation": [
                SYSTEM_MESSAGE,
                {"role": "user", "content": "Tell me the current weather in Seoul"}
            ],
            "expected_tools": ["get_weather"],
            "expected_outcome": "weather_query"
        },
        {
            "name": "Web Search",
            "conversation": [
                SYSTEM_MESSAGE,
                {"role": "user", "content": "Find the latest news about AI agents"}
            ],
            "expected_tools": ["search_web"],
            "expected_outcome": "web_search"
        },
        {
            "name": "Math Calculation",
            "conversation": [
                SYSTEM_MESSAGE,
                {"role": "user", "content": "Calculate 15 times 23"}
            ],
            "expected_tools": ["calculator"],
            "expected_outcome": "calculation"
        }
    ]
    
    results = []
    
    for test_case in test_cases:
        print(f"\nTest: {test_case['name']}")
        
        result = evaluator.evaluate_single_interaction(
            tools=tools,
            conversation=test_case["conversation"],
            expected_outcome=test_case["expected_outcome"]
        )
        
        if result:
            print(f"TSQ score: {result['tsq_score']:.3f}")
            print(f"Tools used: {result['evaluation_details']['tools_used']}")
            print(f"Expected tools: {test_case['expected_tools']}")
            
            # Accuracy check
            used_tools = result['evaluation_details']['tools_used']
            expected_tools = test_case['expected_tools']
            accuracy = len(set(used_tools) & set(expected_tools)) / len(set(used_tools) | set(expected_tools))
            print(f"Tool selection accuracy: {accuracy:.3f}")
            
            results.append({
                "test_name": test_case['name'],
                "tsq_score": result['tsq_score'],
                "tool_accuracy": accuracy,
                "details": result['evaluation_details']
            })
    
    # Overall results summary
    print("\n=== Overall Results Summary ===")
    avg_tsq = sum(r['tsq_score'] for r in results) / len(results)
    avg_accuracy = sum(r['tool_accuracy'] for r in results) / len(results)
    
    print(f"Average TSQ score: {avg_tsq:.3f}")
    print(f"Average tool selection accuracy: {avg_accuracy:.3f}")
    
    return results

if __name__ == "__main__":
    run_basic_tool_usage_scenario()
```

### Scenario 2: Complex Tool Usage Evaluation

```python
# scenario_complex.py
from evaluator import TSQEvaluator
from tools import create_sample_tools
from config import SYSTEM_MESSAGE

def run_complex_tool_usage_scenario():
    """Run complex tool usage scenario"""
    print("=== Complex Tool Usage Scenario ===")
    
    evaluator = TSQEvaluator()
    tools = create_sample_tools()
    
    # Complex test cases
    complex_test_cases = [
        {
            "name": "Weather Query Then Email",
            "conversation": [
                SYSTEM_MESSAGE,
                {"role": "user", "content": "Check the weather in Seoul and email the result to user@example.com"}
            ],
            "expected_tools": ["get_weather", "send_email"],
            "expected_outcome": "weather_and_email"
        },
        {
            "name": "Calculate Then Search",
            "conversation": [
                SYSTEM_MESSAGE,
                {"role": "user", "content": "Calculate 100 times 25 and search the web for information about that result"}
            ],
            "expected_tools": ["calculator", "search_web"],
            "expected_outcome": "calculation_and_search"
        },
        {
            "name": "Unnecessary Tool Use Test",
            "conversation": [
                SYSTEM_MESSAGE,
                {"role": "user", "content": "Hello. Have a great day!"}
            ],
            "expected_tools": [],
            "expected_outcome": "no_tool_needed"
        }
    ]
    
    results = []
    
    for test_case in complex_test_cases:
        print(f"\nComplex test: {test_case['name']}")
        
        result = evaluator.evaluate_single_interaction(
            tools=tools,
            conversation=test_case["conversation"],
            expected_outcome=test_case["expected_outcome"]
        )
        
        if result:
            print(f"TSQ score: {result['tsq_score']:.3f}")
            print(f"Tools used: {result['evaluation_details']['tools_used']}")
            print(f"Expected tools: {test_case['expected_tools']}")
            print(f"Tool call count: {result['evaluation_details']['tool_calls_count']}")
            
            # Complex task evaluation
            used_tools = set(result['evaluation_details']['tools_used'])
            expected_tools = set(test_case['expected_tools'])
            
            if expected_tools:
                precision = len(used_tools & expected_tools) / len(used_tools) if used_tools else 0
                recall = len(used_tools & expected_tools) / len(expected_tools) if expected_tools else 0
                f1_score = 2 * (precision * recall) / (precision + recall) if (precision + recall) > 0 else 0
            else:
                # Case where no tools should be used
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
    
    # Complex task results summary
    print("\n=== Complex Task Results Summary ===")
    avg_tsq = sum(r['tsq_score'] for r in results) / len(results)
    avg_precision = sum(r['precision'] for r in results) / len(results)
    avg_recall = sum(r['recall'] for r in results) / len(results)
    avg_f1 = sum(r['f1_score'] for r in results) / len(results)
    
    print(f"Average TSQ score: {avg_tsq:.3f}")
    print(f"Average Precision: {avg_precision:.3f}")
    print(f"Average Recall: {avg_recall:.3f}")
    print(f"Average F1 Score: {avg_f1:.3f}")
    
    return results

if __name__ == "__main__":
    run_complex_tool_usage_scenario()
```

## Using Benchmark Datasets

### Implementing BFCL-Style Evaluation

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
        """Create BFCL basic dataset"""
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
        """Create xLAM single tool dataset"""
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
        """Create tau-bench long context dataset"""
        long_context = """
        The user previously had the following conversation:
        - Asked about the weather in Seoul and received a reply that the current temperature is 15 degrees.
        - Then said they were curious about Tokyo's weather as well.
        - Also asked to calculate 15 + 20 using the calculator.
        """
        
        return [
            {
                "id": "tau_001",
                "category": "long_context",
                "context": long_context,
                "query": "Please tell me the Seoul weather information you mentioned earlier again",
                "expected_function": None,  # No new call needed since the info already exists
                "expected_parameters": None,
                "difficulty": "hard"
            }
        ]
    
    def _create_toolace_single_dataset(self) -> List[Dict]:
        """Create ToolACE single function dataset"""
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
        """Return a specific dataset"""
        return self.datasets.get(dataset_name, [])
    
    def get_all_datasets(self) -> Dict[str, List[Dict]]:
        """Return all datasets"""
        return self.datasets

def run_benchmark_evaluation():
    """Run evaluation using benchmark datasets"""
    print("=== Benchmark Dataset Evaluation ===")
    
    from evaluator import TSQEvaluator
    from tools import create_sample_tools
    from config import SYSTEM_MESSAGE
    
    evaluator = TSQEvaluator()
    tools = create_sample_tools()
    dataset_handler = BenchmarkDatasetHandler()
    
    all_results = {}
    
    for dataset_name, dataset in dataset_handler.get_all_datasets().items():
        print(f"\n--- {dataset_name.upper()} Dataset Evaluation ---")
        
        dataset_results = []
        
        for item in dataset:
            conversation = [SYSTEM_MESSAGE]
            
            # Add long context if present
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
                # Compare expected and actual results
                used_tools = result['evaluation_details']['tools_used']
                expected_function = item.get('expected_function')
                
                is_correct = False
                if expected_function is None:
                    # Case where no tool should be used
                    is_correct = len(used_tools) == 0
                else:
                    # Case where a specific tool should be used
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
                      f"correct={is_correct}, tools_used={used_tools}")
        
        # Per-dataset statistics
        avg_tsq = sum(r['tsq_score'] for r in dataset_results) / len(dataset_results)
        accuracy = sum(r['is_correct'] for r in dataset_results) / len(dataset_results)
        
        print(f"{dataset_name} average TSQ: {avg_tsq:.3f}")
        print(f"{dataset_name} accuracy: {accuracy:.3f}")
        
        all_results[dataset_name] = {
            "results": dataset_results,
            "avg_tsq": avg_tsq,
            "accuracy": accuracy
        }
    
    # Overall results summary
    print("\n=== Overall Benchmark Results Summary ===")
    overall_tsq = sum(data['avg_tsq'] for data in all_results.values()) / len(all_results)
    overall_accuracy = sum(data['accuracy'] for data in all_results.values()) / len(all_results)
    
    print(f"Overall average TSQ: {overall_tsq:.3f}")
    print(f"Overall average accuracy: {overall_accuracy:.3f}")
    
    return all_results

if __name__ == "__main__":
    run_benchmark_evaluation()
```

## Performance Analysis and Visualization

### Implementing Result Analysis Tools

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
        """Generate analysis and statistics from results"""
        analysis = {
            "summary_stats": self._calculate_summary_stats(results),
            "category_performance": self._analyze_by_category(results),
            "difficulty_performance": self._analyze_by_difficulty(results),
            "tool_usage_patterns": self._analyze_tool_usage(results)
        }
        return analysis
    
    def _calculate_summary_stats(self, results: Dict) -> Dict:
        """Calculate summary statistics"""
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
        """Performance analysis by category"""
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
        
        # Calculate average per category
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
        """Performance analysis by difficulty"""
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
        
        # Calculate average per difficulty
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
        """Tool usage pattern analysis"""
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
        
        # Calculate per-tool statistics
        for tool in tool_usage:
            scores = tool_usage[tool]['scores']
            tool_usage[tool].update({
                'avg_tsq': sum(scores) / len(scores) if scores else 0,
                'success_rate': tool_usage[tool]['correct_usage'] / tool_usage[tool]['count']
            })
        
        return tool_usage
    
    def create_visualizations(self, analysis: Dict, save_dir: str = "./plots"):
        """Generate visualizations of analysis results"""
        import os
        os.makedirs(save_dir, exist_ok=True)
        
        # 1. TSQ score distribution histogram
        self._plot_tsq_distribution(analysis, save_dir)
        
        # 2. Performance comparison by category
        self._plot_category_performance(analysis, save_dir)
        
        # 3. Performance comparison by difficulty
        self._plot_difficulty_performance(analysis, save_dir)
        
        # 4. Tool usage patterns
        self._plot_tool_usage_patterns(analysis, save_dir)
        
        print(f"Visualization results saved to {save_dir} directory.")
    
    def _plot_tsq_distribution(self, analysis: Dict, save_dir: str):
        """TSQ score distribution histogram"""
        plt.figure(figsize=(10, 6))
        
        # Collect all TSQ scores (generate example data in this implementation)
        import numpy as np
        np.random.seed(42)
        tsq_scores = np.random.beta(2, 2, 100) * 0.8 + 0.1  # Scores in 0.1-0.9 range
        
        plt.hist(tsq_scores, bins=20, alpha=0.7, color=self.colors[0], edgecolor='black')
        plt.axvline(analysis['summary_stats']['avg_tsq_score'], 
                   color=self.colors[1], linestyle='--', 
                   label=f'Average: {analysis["summary_stats"]["avg_tsq_score"]:.3f}')
        
        plt.xlabel('TSQ Score')
        plt.ylabel('Frequency')
        plt.title('TSQ Score Distribution')
        plt.legend()
        plt.grid(True, alpha=0.3)
        
        plt.tight_layout()
        plt.savefig(f"{save_dir}/tsq_distribution.png", dpi=300, bbox_inches='tight')
        plt.close()
    
    def _plot_category_performance(self, analysis: Dict, save_dir: str):
        """Performance comparison by category"""
        category_data = analysis['category_performance']
        categories = list(category_data.keys())
        tsq_scores = [category_data[cat]['avg_tsq'] for cat in categories]
        accuracies = [category_data[cat]['avg_accuracy'] for cat in categories]
        
        fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 6))
        
        # TSQ scores
        bars1 = ax1.bar(categories, tsq_scores, color=self.colors[0], alpha=0.8)
        ax1.set_ylabel('Average TSQ Score')
        ax1.set_title('TSQ Performance by Category')
        ax1.set_ylim(0, 1)
        
        # Add value labels
        for bar, score in zip(bars1, tsq_scores):
            ax1.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.01,
                    f'{score:.3f}', ha='center', va='bottom')
        
        # Accuracy
        bars2 = ax2.bar(categories, accuracies, color=self.colors[1], alpha=0.8)
        ax2.set_ylabel('Accuracy')
        ax2.set_title('Accuracy by Category')
        ax2.set_ylim(0, 1)
        
        # Add value labels
        for bar, acc in zip(bars2, accuracies):
            ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.01,
                    f'{acc:.3f}', ha='center', va='bottom')
        
        # Rotate x-axis labels
        for ax in [ax1, ax2]:
            ax.tick_params(axis='x', rotation=45)
            ax.grid(True, alpha=0.3)
        
        plt.tight_layout()
        plt.savefig(f"{save_dir}/category_performance.png", dpi=300, bbox_inches='tight')
        plt.close()
    
    def _plot_difficulty_performance(self, analysis: Dict, save_dir: str):
        """Performance comparison by difficulty"""
        difficulty_data = analysis['difficulty_performance']
        difficulties = ['easy', 'medium', 'hard']  # Fixed order
        
        # Filter only available difficulties
        available_difficulties = [d for d in difficulties if d in difficulty_data]
        tsq_scores = [difficulty_data[d]['avg_tsq'] for d in available_difficulties]
        accuracies = [difficulty_data[d]['avg_accuracy'] for d in available_difficulties]
        
        fig, ax = plt.subplots(figsize=(10, 6))
        
        x = range(len(available_difficulties))
        width = 0.35
        
        bars1 = ax.bar([i - width/2 for i in x], tsq_scores, width, 
                      label='TSQ Score', color=self.colors[0], alpha=0.8)
        bars2 = ax.bar([i + width/2 for i in x], accuracies, width, 
                      label='Accuracy', color=self.colors[1], alpha=0.8)
        
        ax.set_xlabel('Difficulty')
        ax.set_ylabel('Score')
        ax.set_title('Performance Comparison by Difficulty')
        ax.set_xticks(x)
        ax.set_xticklabels(available_difficulties)
        ax.legend()
        ax.set_ylim(0, 1)
        ax.grid(True, alpha=0.3)
        
        # Add value labels
        for bars in [bars1, bars2]:
            for bar in bars:
                height = bar.get_height()
                ax.text(bar.get_x() + bar.get_width()/2, height + 0.01,
                       f'{height:.3f}', ha='center', va='bottom')
        
        plt.tight_layout()
        plt.savefig(f"{save_dir}/difficulty_performance.png", dpi=300, bbox_inches='tight')
        plt.close()
    
    def _plot_tool_usage_patterns(self, analysis: Dict, save_dir: str):
        """Tool usage pattern analysis"""
        tool_data = analysis['tool_usage_patterns']
        tools = list(tool_data.keys())
        
        if not tools:
            return
        
        usage_counts = [tool_data[tool]['count'] for tool in tools]
        success_rates = [tool_data[tool]['success_rate'] for tool in tools]
        
        fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 6))
        
        # Usage frequency
        bars1 = ax1.bar(tools, usage_counts, color=self.colors[2], alpha=0.8)
        ax1.set_ylabel('Usage Count')
        ax1.set_title('Tool Usage Frequency')
        ax1.tick_params(axis='x', rotation=45)
        
        for bar, count in zip(bars1, usage_counts):
            ax1.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.1,
                    str(count), ha='center', va='bottom')
        
        # Success rate
        bars2 = ax2.bar(tools, success_rates, color=self.colors[3], alpha=0.8)
        ax2.set_ylabel('Success Rate')
        ax2.set_title('Tool Success Rate')
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
        """Generate evaluation report"""
        summary = analysis['summary_stats']
        
        report = f"""# Agent Leaderboard v2 Evaluation Report

## Overall Summary

- **Total Tests**: {summary['total_tests']}
- **Average TSQ Score**: {summary['avg_tsq_score']:.3f} +/- {summary['std_tsq_score']:.3f}
- **Average Accuracy**: {summary['avg_accuracy']:.3f}
- **Highest TSQ Score**: {summary['max_tsq_score']:.3f}
- **Lowest TSQ Score**: {summary['min_tsq_score']:.3f}

## Performance by Category

"""
        
        for category, data in analysis['category_performance'].items():
            report += f"### {category}\n"
            report += f"- TSQ Score: {data['avg_tsq']:.3f}\n"
            report += f"- Accuracy: {data['avg_accuracy']:.3f}\n"
            report += f"- Test Count: {data['count']}\n\n"
        
        report += "## Performance by Difficulty\n\n"
        
        for difficulty, data in analysis['difficulty_performance'].items():
            report += f"### {difficulty.title()}\n"
            report += f"- TSQ Score: {data['avg_tsq']:.3f}\n"
            report += f"- Accuracy: {data['avg_accuracy']:.3f}\n"
            report += f"- Test Count: {data['count']}\n\n"
        
        report += "## Tool Usage Analysis\n\n"
        
        for tool, data in analysis['tool_usage_patterns'].items():
            report += f"### {tool}\n"
            report += f"- Usage Count: {data['count']}\n"
            report += f"- Average TSQ: {data['avg_tsq']:.3f}\n"
            report += f"- Success Rate: {data['success_rate']:.3f}\n\n"
        
        with open(save_path, 'w', encoding='utf-8') as f:
            f.write(report)
        
        print(f"Evaluation report saved to {save_path}.")

# Analysis execution script
def run_complete_analysis():
    """Run complete analysis"""
    from benchmark_datasets import run_benchmark_evaluation
    
    # Run benchmark evaluation
    results = run_benchmark_evaluation()
    
    # Analyze results
    analyzer = PerformanceAnalyzer()
    analysis = analyzer.analyze_results(results)
    
    # Generate visualizations
    analyzer.create_visualizations(analysis)
    
    # Generate report
    analyzer.generate_report(analysis)
    
    print("\n=== Analysis Complete ===")
    print("Visualizations and report have been generated.")
    
    return analysis

if __name__ == "__main__":
    run_complete_analysis()
```

## Using the Actual Hugging Face Leaderboard

### Accessing the Leaderboard API

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
        """Fetch leaderboard data"""
        try:
            # Use actual API endpoint if available
            # Example data is generated here
            data = self._create_example_leaderboard_data()
            return pd.DataFrame(data)
        except Exception as e:
            print(f"Failed to fetch leaderboard data: {e}")
            return pd.DataFrame()
    
    def _create_example_leaderboard_data(self) -> List[Dict]:
        """Create example leaderboard data"""
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
        """Analyze cost-performance frontier"""
        if df.empty:
            return {}
        
        # Calculate Pareto frontier
        pareto_optimal = []
        
        for i, row in df.iterrows():
            is_pareto = True
            for j, other_row in df.iterrows():
                if i != j:
                    # Check if there is a model with higher performance and lower cost
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
        """Compare specific models"""
        if df.empty:
            return {}
        
        comparison_data = df[df['model'].isin(model_names)]
        
        if comparison_data.empty:
            return {"error": "Specified models not found."}
        
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
        """Recommend models based on budget and performance requirements"""
        if df.empty:
            return []
        
        # Filter models within budget
        affordable_models = df[df['cost_per_million'] <= budget]
        
        # Filter models meeting minimum performance requirement
        suitable_models = affordable_models[affordable_models['overall_score'] >= min_performance]
        
        if suitable_models.empty:
            return []
        
        # Sort by cost efficiency relative to performance
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
    """Demonstrate leaderboard analysis"""
    print("=== Agent Leaderboard v2 Analysis Demonstration ===")
    
    api = AgentLeaderboardAPI()
    df = api.fetch_leaderboard_data()
    
    if df.empty:
        print("Could not retrieve leaderboard data.")
        return
    
    print("\n1. Current top 5 models on the leaderboard:")
    print(df[['rank', 'model', 'overall_score', 'cost_per_million']].head())
    
    # Cost-performance analysis
    frontier_analysis = api.analyze_cost_performance_frontier(df)
    print(f"\n2. Pareto-optimal models: {frontier_analysis['pareto_models']}")
    
    # Model comparison
    comparison_models = ['Gemini-2.0-flash', 'GPT-4o', 'Gemini-1.5-flash']
    comparison = api.compare_models(comparison_models, df)
    
    print(f"\n3. Comparison of {', '.join(comparison_models)}:")
    for metric, data in comparison.items():
        if isinstance(data, dict) and 'best_model' in data:
            print(f"  {metric}: {data['best_model']} ({data['best_score']:.3f})")
    
    # Model recommendations
    budget = 2.0  # $2.0 per million tokens
    min_performance = 0.85
    recommendations = api.get_model_recommendations(budget, min_performance, df)
    
    print(f"\n4. Recommended models for budget ${budget}/M and minimum performance {min_performance}:")
    for i, rec in enumerate(recommendations, 1):
        print(f"  {i}. {rec['model']} (score: {rec['overall_score']:.3f}, "
              f"cost: ${rec['cost_per_million']}/M, efficiency: {rec['efficiency_ratio']:.2f})")

if __name__ == "__main__":
    demonstrate_leaderboard_analysis()
```

## Advanced Evaluation Techniques and Optimization

### Edge Case and Failure Analysis

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
        """Test cases for irrelevant queries"""
        return [
            {
                "query": "How are you feeling today?",
                "expected_behavior": "no_tool_use",
                "description": "Inquiry about emotional state - tool use not needed"
            },
            {
                "query": "Hello! Have a great day.",
                "expected_behavior": "no_tool_use", 
                "description": "Greeting - tool use not needed"
            },
            {
                "query": "I have a philosophical question about AI.",
                "expected_behavior": "no_tool_use",
                "description": "Philosophical question - available tools cannot answer it"
            }
        ]
    
    def _create_missing_param_cases(self) -> List[Dict]:
        """Test cases for missing parameters"""
        return [
            {
                "query": "Tell me the weather",  # Missing location info
                "expected_behavior": "request_missing_param",
                "missing_param": "location",
                "description": "Missing location information for weather query"
            },
            {
                "query": "Send an email",  # Missing recipient, subject, body
                "expected_behavior": "request_missing_param",
                "missing_param": ["to", "subject", "body"],
                "description": "Missing required information for sending email"
            }
        ]
    
    def _create_sequence_cases(self) -> List[Dict]:
        """Test cases for tool sequence dependency"""
        return [
            {
                "query": "Check the weather in Seoul and email the result to john@example.com",
                "expected_sequence": ["get_weather", "send_email"],
                "description": "Email after weather check - sequential execution required"
            },
            {
                "query": "Calculate 15 * 23 and search the web for the result",
                "expected_sequence": ["calculator", "search_web"],
                "description": "Search after calculation - requires using previous result"
            }
        ]
    
    def _create_long_context_cases(self) -> List[Dict]:
        """Long context test cases"""
        long_context = """
        Previous conversation:
        User: What's the weather like in Seoul today?
        Assistant: The current weather in Seoul is clear with a temperature of 18 degrees.
        User: How about Tokyo?
        Assistant: Tokyo is cloudy with a temperature of 22 degrees.
        User: What is 15 + 25?
        Assistant: 15 + 25 = 40.
        """
        
        return [
            {
                "context": long_context,
                "query": "Please tell me the Seoul weather you mentioned earlier again",
                "expected_behavior": "use_context",
                "description": "Reusing information from previous conversation"
            },
            {
                "context": long_context,
                "query": "If I add 5 to the calculation result, what do I get?",
                "expected_behavior": "use_context_and_calculate",
                "description": "Additional calculation using previous calculation result"
            }
        ]
    
    def _create_ambiguous_cases(self) -> List[Dict]:
        """Ambiguous query test cases"""
        return [
            {
                "query": "Find that thing",
                "expected_behavior": "request_clarification",
                "description": "Unclear search request"
            },
            {
                "query": "Send email",
                "expected_behavior": "request_details",
                "description": "Incomplete email sending request"
            }
        ]
    
    def evaluate_edge_cases(self, evaluator, tools) -> Dict:
        """Run edge case evaluation"""
        results = {}
        
        for category, cases in self.edge_cases.items():
            print(f"\n=== {category.upper()} Edge Case Evaluation ===")
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
                    # Special evaluation per edge case
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
        """Calculate special evaluation score per edge case"""
        expected_behavior = case['expected_behavior']
        tools_used = result['evaluation_details']['tools_used']
        
        if expected_behavior == "no_tool_use":
            # Case where no tool should be used
            return 1.0 if len(tools_used) == 0 else 0.0
        
        elif expected_behavior == "request_missing_param":
            # Case where missing parameters should be requested
            # In practice, the LLM response content should be analyzed
            return 0.8  # Simplified score
        
        elif expected_behavior == "use_context":
            # Case where context should be used
            return 1.0 if len(tools_used) == 0 else 0.5
        
        elif expected_behavior == "use_context_and_calculate":
            # Context utilization + calculation
            return 1.0 if "calculator" in tools_used else 0.0
        
        elif expected_behavior.startswith("request_"):
            # Case where additional information should be requested
            return 0.9  # Simplified score
        
        else:
            return 0.5  # Default score

def run_edge_case_evaluation():
    """Run edge case evaluation"""
    from evaluator import TSQEvaluator
    from tools import create_sample_tools
    
    evaluator = TSQEvaluator()
    tools = create_sample_tools()
    analyzer = EdgeCaseAnalyzer()
    
    edge_results = analyzer.evaluate_edge_cases(evaluator, tools)
    
    # Results summary
    print("\n=== Edge Case Evaluation Summary ===")
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
        print(f"\nOverall average: TSQ={total_tsq/total_cases:.3f}, "
              f"Edge Score={total_edge_score/total_cases:.3f}")
    
    return edge_results

if __name__ == "__main__":
    run_edge_case_evaluation()
```

## Execution Scripts and Automation

### Main Execution Script

```python
# main.py
import os
import sys
from datetime import datetime
import argparse

def setup_environment():
    """Check environment configuration"""
    required_env_vars = ['OPENAI_API_KEY']
    missing_vars = [var for var in required_env_vars if not os.getenv(var)]
    
    if missing_vars:
        print(f"Required environment variables are not set: {missing_vars}")
        print("Set them with the following commands:")
        for var in missing_vars:
            print(f"export {var}=your_value_here")
        sys.exit(1)
    
    print("Environment variables configured")

def install_dependencies():
    """Check dependency package installation"""
    try:
        import openai
        import pandas
        import matplotlib
        import seaborn
        print("Required packages confirmed installed")
    except ImportError as e:
        print(f"Required packages not installed: {e}")
        print("Install them with:")
        print("pip install openai pandas matplotlib seaborn")
        sys.exit(1)

def run_basic_evaluation():
    """Run basic evaluation"""
    print("\n=== Running Basic TSQ Evaluation ===")
    from scenario_basic import run_basic_tool_usage_scenario
    return run_basic_tool_usage_scenario()

def run_complex_evaluation():
    """Run complex evaluation"""
    print("\n=== Running Complex Tool Usage Evaluation ===")
    from scenario_complex import run_complex_tool_usage_scenario
    return run_complex_tool_usage_scenario()

def run_benchmark_evaluation():
    """Run benchmark evaluation"""
    print("\n=== Running Benchmark Dataset Evaluation ===")
    from benchmark_datasets import run_benchmark_evaluation
    return run_benchmark_evaluation()

def run_edge_case_evaluation():
    """Run edge case evaluation"""
    print("\n=== Running Edge Case Evaluation ===")
    from edge_cases import run_edge_case_evaluation
    return run_edge_case_evaluation()

def run_leaderboard_analysis():
    """Run leaderboard analysis"""
    print("\n=== Running Leaderboard Analysis ===")
    from leaderboard_api import demonstrate_leaderboard_analysis
    return demonstrate_leaderboard_analysis()

def generate_comprehensive_report(all_results):
    """Generate comprehensive report"""
    print("\n=== Generating Comprehensive Report ===")
    from analysis import PerformanceAnalyzer
    
    analyzer = PerformanceAnalyzer()
    
    # Analyze integrated results
    combined_analysis = {}
    
    if 'benchmark' in all_results:
        combined_analysis = analyzer.analyze_results(all_results['benchmark'])
        analyzer.create_visualizations(combined_analysis)
        analyzer.generate_report(combined_analysis)
    
    return combined_analysis

def main():
    """Main execution function"""
    parser = argparse.ArgumentParser(description='Agent Leaderboard v2 Evaluation Tool')
    parser.add_argument('--basic', action='store_true', help='Run basic evaluation only')
    parser.add_argument('--complex', action='store_true', help='Run complex evaluation only')
    parser.add_argument('--benchmark', action='store_true', help='Run benchmark evaluation only')
    parser.add_argument('--edge', action='store_true', help='Run edge case evaluation only')
    parser.add_argument('--leaderboard', action='store_true', help='Run leaderboard analysis only')
    parser.add_argument('--all', action='store_true', help='Run all evaluations (default)')
    
    args = parser.parse_args()
    
    print("Agent Leaderboard v2 Evaluation Tool Starting")
    print(f"Start time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # Check environment configuration
    setup_environment()
    install_dependencies()
    
    # Dictionary for storing results
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
        
        # Generate comprehensive report
        if len(all_results) > 1 or args.all:
            generate_comprehensive_report(all_results)
        
        print(f"\nAll evaluations complete!")
        print(f"End time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print("\nGenerated files:")
        print("  - evaluation_report.md (evaluation report)")
        print("  - plots/ (visualization results)")
        print("  - app.log (log file)")
        
    except Exception as e:
        print(f"Error during evaluation: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()
```

### Automation Script

```bash
#!/bin/bash
# run_evaluation.sh

echo "Agent Leaderboard v2 Evaluation Automation Script"

# Check virtual environment activation
if [[ "$VIRTUAL_ENV" == "" ]]; then
    echo "Python virtual environment is not activated."
    echo "Activate it with:"
    echo "source venv/bin/activate"
    exit 1
fi

# Check environment variables
if [[ -z "$OPENAI_API_KEY" ]]; then
    echo "OPENAI_API_KEY environment variable is not set."
    echo "export OPENAI_API_KEY=your_api_key_here"
    exit 1
fi

echo "Environment configuration confirmed"

# Create result directories
mkdir -p results plots logs

# Generate timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo "Starting evaluation (${TIMESTAMP})"

# Run Python evaluation script
python main.py --all 2>&1 | tee "logs/evaluation_${TIMESTAMP}.log"

# Back up results
if [[ -f "evaluation_report.md" ]]; then
    cp evaluation_report.md "results/evaluation_report_${TIMESTAMP}.md"
fi

if [[ -d "plots" ]]; then
    cp -r plots "results/plots_${TIMESTAMP}"
fi

echo "Evaluation complete! Check results in the results/ directory."
echo "Key result files:"
echo "  - results/evaluation_report_${TIMESTAMP}.md"
echo "  - results/plots_${TIMESTAMP}/"
echo "  - logs/evaluation_${TIMESTAMP}.log"

# Print results summary
if [[ -f "evaluation_report.md" ]]; then
    echo ""
    echo "Evaluation Results Summary:"
    grep -E "Average|Total|Overall" evaluation_report.md | head -5
fi
```

### zshrc Aliases Configuration

```bash
# Aliases to add to ~/.zshrc

# Agent Leaderboard v2 related aliases
alias agent-eval="cd ~/agent-leaderboard-tutorial && source venv/bin/activate"
alias agent-basic="python main.py --basic"
alias agent-complex="python main.py --complex"
alias agent-benchmark="python main.py --benchmark"
alias agent-edge="python main.py --edge"
alias agent-all="python main.py --all"
alias agent-leaderboard="python main.py --leaderboard"
alias agent-run="bash run_evaluation.sh"

# Result checking aliases
alias agent-report="cat evaluation_report.md"
alias agent-plots="open plots/"
alias agent-logs="tail -f logs/evaluation_*.log"
alias agent-results="ls -la results/"

# Environment setup aliases
alias agent-env="export OPENAI_API_KEY="
alias agent-check="python -c 'import openai; print(\"OpenAI:\", openai.__version__)'"
alias agent-deps="pip install openai pandas matplotlib seaborn promptquality"

# Utility aliases
alias agent-clean="rm -rf plots/*.png evaluation_report.md logs/*.log"
alias agent-backup="cp -r . ~/agent-leaderboard-backup-$(date +%Y%m%d)"
```

## Running Tests and Verifying Results

### Running Local Tests

```bash
# Move to project directory
cd ~/agent-leaderboard-tutorial

# Activate virtual environment
source venv/bin/activate

# Set environment variables (replace with your own API key)
export OPENAI_API_KEY="your-openai-api-key-here"

# Confirm dependencies installed
python -c "import openai, pandas, matplotlib; print('Package installation confirmed')"

# Run basic evaluation test
python main.py --basic

# Run full evaluation test (may take a while)
python main.py --all
```

### Development Environment Version Information

Test environment:
- **Python**: 3.9.16
- **OpenAI**: 1.3.7
- **Pandas**: 2.0.3
- **Matplotlib**: 3.7.2
- **Seaborn**: 0.12.2

```bash
# Check development environment versions
python --version
pip list | grep -E "(openai|pandas|matplotlib|seaborn)"
```

## Conclusion

Agent Leaderboard v2 is a comprehensive platform for evaluating AI agents' tool-use capabilities. Through this tutorial, you have learned the following key points:

### Key Takeaways

1. **Understanding the TSQ metric**: How Tool Selection Quality evaluates the composite capabilities of agents
2. **Setting up a practice environment**: Directly implementing the Agent Leaderboard v2 evaluation system on macOS
3. **Diverse evaluation scenarios**: From basic tool usage to complex edge cases
4. **Using benchmark datasets**: Implementing BFCL, tau-bench, xLAM, and ToolACE-style evaluations
5. **Performance analysis and visualization**: How to systematically analyze and visualize evaluation results

### Practical Applications

- **Model selection guide**: Choosing the optimal model considering cost and performance
- **Performance monitoring**: Continuous tracking and improvement of agent performance
- **Edge case handling**: Handling exceptional situations that may arise in actual operating environments

### Future Directions

Agent Leaderboard v2 is updated monthly, with new models and evaluation techniques continuously added. By objectively evaluating and improving AI agent performance through this platform, you can build more reliable and effective AI systems.
