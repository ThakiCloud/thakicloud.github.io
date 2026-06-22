---
title: "2025 Research Review: RL-Based Post-Training for Agentic Model Development"
excerpt: "A comprehensive review of key RL-based agent model training trends from arXiv papers published after April 2025, covering the latest techniques in multi-modal tool use, multi-agent collaboration, and efficient curriculum learning."
seo_title: "2025 RL-Based Agentic Model Post-Training Research Review - Thaki Cloud"
seo_description: "Visual-ARFT, MARFT, ReTool, and other latest RL-based post-training techniques for agentic model development, with deep analysis of multi-modal agents, tool use, and curriculum learning innovations."
date: 2025-08-22
last_modified_at: 2025-08-22
lang: en
categories:
  - research
tags:
  - reinforcement-learning
  - post-training
  - agentic-models
  - LLM
  - multimodal
  - tool-use
  - RLHF
  - machine-learning
  - AI-research
author_profile: true
toc: true
toc_label: "Table of Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/en/research/rl-post-training-agentic-models-research-review/"
reading_time: true
published: true
---

⏱️ **Estimated reading time**: 15 min

## Introduction

2025 will be recorded as the year reinforcement learning (RL)-based post-training established itself as the core paradigm for agentic AI model development. Particularly, research published on arXiv after April 2025 has presented innovative methodologies for creating genuine "agents" capable of utilizing external tools, performing complex reasoning, and collaborating in multi-agent environments, transcending the limitations of simple language models.

In this review, we examine 10 key papers that have received the most attention in the community to explore how reinforcement learning is transforming large language models into genuine agents. From multi-modal tool use to multi-agent collaboration and efficient curriculum learning, we deeply analyze the core ideas each research presents and their implications for practical AI system development.

![Landscape of RL-based agentic post-training techniques: 10 papers grouped into four themes](/assets/images/rl-post-training-agentic-models-diagram.svg)

## 1. Visual-ARFT: Teaching Tool Use to Multimodal Agents

**Paper**: Visual-ARFT: Visual Agentic Reinforcement Fine-Tuning (arXiv 2505.14246, May 2025)

Visual-ARFT presents an innovative approach to training large vision-language models (LVLMs) to strategically utilize external tools. The core of this research is training models not just to generate text, but through reinforcement learning to judge and execute when and how to use complex tools like web browsing, code execution, and image manipulation.

### Core Methodology

The Visual-ARFT training process consists of the following stages:

1. **Planning**: The model analyzes the given task and plans the required tool use sequence
2. **Tool invocation**: Calling and executing appropriate external tools according to the plan
3. **Result interpretation**: Analyzing tool execution results and determining the next step
4. **Step-by-step reward**: Providing reinforcement learning signals based on performance at each tool use stage

### Impressive Performance Improvements

In comparative experiments with GPT-4o, Visual-ARFT showed the following impressive performance improvements:

- **Math reasoning + tool use (MAT-Coding)**: F1 score +18.6 points, Exact Match +13.0 points
- **Search-based math problem solving (MAT-Search)**: F1 score +10.3 points, Exact Match +8.7 points

These performance improvements come not simply from more data or larger model size, but from optimizing the timing and method of tool use through reinforcement learning.

### Practical Implications

Visual-ARFT's success demonstrates that powerful enterprise agents can be built even under limited computing budgets. It provides immediately applicable value in the following areas:

- **Web-based information gathering**: Real-time web browsing for latest information retrieval
- **Code-based problem solving**: Automatic code generation and execution for complex calculations or data processing
- **Multi-hop reasoning**: Complex problem solving through multiple stages of tool use

## 2. MARFT: A New Paradigm for Multi-Agent Reinforcement Learning

**Paper**: MARFT: Multi-Agent Reinforcement Fine-Tuning (arXiv 2504.16129, April 2025)

At a time when enterprise AI is evolving from individual agents to agent teams, MARFT presents an innovative framework for simultaneously training multiple LLM agents with reinforcement learning. The core of this research is resolving the fundamental limitations that traditional multi-agent reinforcement learning (MARL) faces when applied to language-based agents.

### Limitations of Traditional MARL vs LLM-Based Systems

Traditional MARL was designed under the following assumptions:
- **Synchronous interaction**: All agents act simultaneously
- **Low-dimensional state space**: Environment representable as simple numbers or vectors
- **Simple action space**: Limited number of discrete actions

However, LLM-based multi-agent systems have fundamentally different characteristics:
- **Asynchronous interaction**: Agents acting at different times
- **Profile awareness**: Each agent has unique roles and expertise
- **Long context windows**: Complex state representations reaching tens of thousands of tokens

### MARFT's Innovative Approach

MARFT addresses these differences through:

1. **Asynchronous rollout module**: A flexible interaction framework allowing each agent to act at independent speeds
2. **Adaptive reward shaping**: A multi-layer reward system considering both individual agent roles and overall team performance
3. **Scalable optimization**: A distributed learning algorithm operating efficiently even as agent numbers increase

### Applicability in Practical Environments

MARFT is particularly useful in collaborative agent scenarios such as:

- **Customer service teams**: Step-by-step collaboration in initial inquiry classification, expert connection, and problem resolution
- **Software development**: Collaboration among specialist agents handling requirements analysis, design, implementation, and testing
- **Financial analysis**: Role division in data collection, risk assessment, and investment recommendations

## 3. ReTool: Strategic Tool Use via Reinforcement Learning

**Paper**: ReTool: Reinforcement Learning for Strategic Tool Use in LLMs (arXiv 2504.11536, April 2025)

ReTool presents a methodology for learning when and how language models should use external tools through reinforcement learning, particularly in domains like mathematics and geometry where code execution is decisively helpful for reasoning.

### Integration of Real-Time Code Execution and Natural Language Reasoning

ReTool's core idea is not merely connecting natural language reasoning and code execution sequentially, but interleaving the two processes organically to create more powerful problem-solving capability.

In the traditional approach:
1. Analyze problem in natural language
2. Write code if necessary
3. Execute code
4. Write answer based on results

In ReTool:
1. Analyze problem (natural language)
2. Judge necessity of code execution (reinforcement learning)
3. Write and execute code
4. Interpret results and re-judge necessity of additional code
5. Repeat steps 2-4 if necessary
6. Derive final answer

### Impressive Experimental Results

In experiments on AIME (American Invitational Mathematics Examination) problems:

- **Pure text-based RL**: 40% accuracy
- **ReTool applied (400 RL steps)**: 67% accuracy (+27% improvement)
- **ReTool extended training**: 72.5% accuracy
- **vs OpenAI o1-preview**: +28% performance improvement

This is a remarkable result demonstrating that a 32B parameter model can surpass GPT-4 class performance in specific domains.

### Emergent Behavior: Code Self-Correction

Particularly interesting during ReTool training is that the model learns to detect and correct errors in code on its own. This is emergent behavior that appears naturally during reinforcement learning even though humans never explicitly taught it.

```python
# Initial code (with error)
def solve_equation(x):
    return x**2 + 2*x + 1  # incorrect formula

# After execution and recognizing result differs from expected

# Automatically corrected code
def solve_equation(x):
    return x**2 + 3*x + 2  # corrected to proper formula
```

## 4. Sparse Update Properties in RL Fine-Tuning

**Paper**: Reinforcement Learning Finetunes Small Subnetworks in Large Language Models (arXiv 2505.11711, May 2025)

This research is an important foundational study that deeply analyzes the internal mechanisms of reinforcement learning-based fine-tuning. Through extensive experiments across 7 different RL algorithms and 10 large language models, it revealed the surprising fact that RL fine-tuning actually updates only a very small portion of the entire model.

### Discovery of Sparse Updates

According to experimental results:
- **Updated parameters**: Only 5-30% of the total
- **Performance maintenance**: Updating only the sparse subnetwork achieves nearly the same performance as full RL fine-tuning
- **Consistency**: Similar parameter sets are updated across different RL runs

### Analysis of the Cause of Sparsity

The research team analyzed the causes of this sparse update pattern as follows:

1. **Near-on-policy data distribution**: Data used in RL has a distribution similar to the current policy, making large changes to the entire model unnecessary
2. **Limited impact of KL regularization**: The commonly used KL divergence penalty has minimal impact on sparsity
3. **Full-rank updates**: Updated parameters are distributed across the entire matrix (not concentrated in specific rows or columns)

### Practical Implications: Efficient RL Fine-Tuning

This discovery enables the following practical improvements:

**1. Parameter-efficient methodology**
```python
# Traditional full model update
optimizer = Adam(model.parameters(), lr=1e-5)

# Sparse update-based efficiency
important_params = identify_important_subnetwork(model)
optimizer = Adam(important_params, lr=1e-5)
# 70% reduction in memory usage, 60% reduction in training time
```

**2. LoRA adapter design guidelines**
- Previous: Adapter design under low-rank assumption
- Improved: More effective adapter architecture considering full-rank characteristics

**3. Cost optimization**
- Greatly reducing RL fine-tuning costs for large-scale models
- Improved GPU memory efficiency in cloud environments

## 5. UFT: Unifying Supervised and Reinforcement Fine-Tuning

**Paper**: UFT: Unifying Supervised and Reinforcement Fine-Tuning (arXiv 2505.16984, May 2025)

In most practical environments, AI agent development goes through a 2-stage process starting with supervised learning (SFT) and continuing to reinforcement learning (RFT). UFT presents a more effective and efficient training paradigm by integrating these two stages into one.

### Limitations of Existing Approaches

**Problems with sequential SFT to RFT:**
- **Forgetting phenomenon**: Good behavioral patterns learned through SFT disappear during RFT
- **Inefficiency**: Time and resource waste from two separate training processes
- **Optimization difficulty**: Needing to tune hyperparameters for each stage separately

### UFT's Integrated Approach

UFT simultaneously optimizes the following two objective functions:

$$\mathcal{L}_{UFT} = \alpha \cdot \mathcal{L}_{SFT} + (1-\alpha) \cdot \mathcal{L}_{RFT}$$

Where:
- $\mathcal{L}_{SFT} = -\log P(y|x)$: Negative log likelihood of demonstration data
- $\mathcal{L}_{RFT} = -\mathbb{E}[R(s,a)]$: Negative expected value of reinforcement learning reward
- $\alpha$: Balance adjustment parameter between exploration and supervision

### Theoretical Breakthrough: Sample Complexity Improvement

UFT's most important theoretical contribution is breaking through the exponential sample complexity barrier of reinforcement learning in long-horizon reasoning tasks.

**Traditional RL sample complexity:**
- Exponential increase of $O(\exp(H))$ with horizon length $H$

**UFT's sample complexity:**
- Polynomial complexity of $O(\text{poly}(H))$ with appropriate demonstration data

This means training costs can be dramatically reduced in agent development requiring complex multi-step reasoning.

### Practical Application Guidelines

**1. Balance parameter setting**
```python
# Initial phase: strong supervision
alpha_schedule = [0.8, 0.6, 0.4, 0.2]

# Adaptive adjustment at each epoch
for epoch, alpha in enumerate(alpha_schedule):
    loss = alpha * sft_loss + (1 - alpha) * rl_loss
    optimizer.step()
```

**2. Application scenarios**
- **High-quality demonstration data available**: Start with high $\alpha$
- **Insufficient demonstration data**: Set $\alpha$ low but increase gradually
- **Domain-specific tasks**: Optimize $\alpha$ scheduling per domain

## 6. Self-Evolving Curriculum Learning

**Paper**: Self-Evolving Curriculum for LLM Reasoning (arXiv 2505.14970, May 2025)

RL success depends heavily on the training curriculum, but most existing research uses simple random or heuristic-based curricula. SEC (Self-Evolving Curriculum) presents a meta-learning approach that learns the curriculum itself to solve this problem.

### Curriculum Learning as a Multi-Armed Bandit Problem

SEC models curriculum design as a Multi-Armed Bandit problem:

- **Arms**: Different problem categories or difficulty levels
- **Reward**: Absolute advantage of policy gradient
- **Goal**: Category selection maximizing learning effectiveness

### Measuring and Adapting Learning Effectiveness

**1. Policy gradient advantage calculation**
$$A_t = R_t - V(s_t)$$

**2. Per-category learning signal**
$$\text{Learning Signal}_c = \mathbb{E}[|A_t|] \text{ for category } c$$

**3. TD(0)-based curriculum policy update**
$$\pi(c_{t+1}) \leftarrow \pi(c_t) + \eta \cdot \text{Learning Signal}_c$$

### Experimental Results: Generalization and Balance

SEC showed performance far surpassing existing curricula in three areas:

**1. Planning**
- Existing random curriculum: 65% success rate
- SEC: 78% success rate (+13% improvement)

**2. Inductive Reasoning**
- Existing heuristic curriculum: 72% accuracy
- SEC: 85% accuracy (+13% improvement)

**3. Mathematics**
- Existing fixed curriculum: 58% accuracy
- SEC: 73% accuracy (+15% improvement)

### Skill Balance and Out-of-Distribution Generalization

Another important advantage of SEC is that it automatically balances diverse skills and improves generalization ability for harder problems not seen during training.

**Skill Balance Index (SBI):**
$$SBI = 1 - \frac{\text{std}(\text{skill scores})}{\text{mean}(\text{skill scores})}$$

- SEC: SBI = 0.92 (high balance)
- Existing methods: SBI = 0.67-0.78 (imbalanced)

## 7. Improving Data Efficiency Through Adaptive Sampling

**Paper**: Improving Data Efficiency for LLM Reinforcement Fine-tuning Through Difficulty-Targeted Online Data Selection and Rollout Replay (arXiv 2506.05316, June 2025)

One of the biggest practical barriers to RL fine-tuning is enormous computing costs. This research presents methods to greatly improve data efficiency of RL fine-tuning through two key techniques.

### 1. Difficulty-Based Adaptive Data Selection

**Attention-based difficulty estimation framework:**

The research team developed a framework that automatically estimates problem difficulty by analyzing attention patterns from a small reference dataset.

```python
def estimate_difficulty(problem, reference_set, model):
    """
    Attention pattern-based difficulty estimation
    """
    attention_weights = model.get_attention_weights(problem)
    
    # Calculate attention similarity with reference set
    similarities = compute_attention_similarity(
        attention_weights, reference_set
    )
    
    # Prioritize medium difficulty problems
    difficulty_score = estimate_from_similarities(similarities)
    
    return difficulty_score
```

**Adaptive sampling strategy:**
- **Too easy problems**: Minimal learning effect -> low sampling probability
- **Medium difficulty problems**: Optimal learning effect -> high sampling probability
- **Too hard problems**: Learning instability -> limited sampling

### 2. Rollout Replay

**Memory-based experience reuse:**

```python
class RolloutReplayBuffer:
    def __init__(self, capacity=10000):
        self.buffer = deque(maxlen=capacity)
        self.priorities = deque(maxlen=capacity)
    
    def add_rollout(self, rollout, reward):
        self.buffer.append(rollout)
        # Higher priority for rollouts with higher rewards
        self.priorities.append(abs(reward))
    
    def sample_batch(self, batch_size):
        # Priority-based sampling
        indices = weighted_sample(self.priorities, batch_size)
        return [self.buffer[i] for i in indices]
```

**Replay effects:**
- **Computation cost reduction**: 70% savings in new rollout generation cost
- **Learning stability**: Continuous learning from past good experiences
- **Convergence speed**: 25-65% time reduction to achieve the same performance

### Integrated Performance Results

Results from experiments across 6 different LLM-dataset combinations:

| Dataset | Standard GRPO | Adaptive Sampling | Rollout Replay | Integrated Method |
|---------|----------|-------------|-------------|----------|
| GSM8K | 100% | 125% | 140% | 165% |
| MATH | 100% | 130% | 135% | 180% |
| HumanEval | 100% | 120% | 145% | 175% |

*Performance is relative ratio of achievable score within the same time*

## 8. Reasoning-Search Integration for Multi-Step Multi-Source Retrieval

**Paper**: ReFT for Multi-Step Multi-Source Search (Reasoning-Search) (arXiv 2506.08352, June 2025)

In enterprise environments, AI agents often need to collect data from multiple information sources, not just single sources, and perform complex multi-step reasoning based on it. R-Search presents an innovative framework that integrates planning, multi-source retrieval execution, and answer synthesis within a single LLM to address this requirement.

### Structured Output Design

R-Search's core is structuring the model's output into four clear components:

**1. Reasoning Steps**
```
Step 1: Identify key entities in the question
Step 2: Determine type of information needed per entity
Step 3: Set retrieval priority per information source
```

**2. Natural Language DAG (Directed Acyclic Graph)**
```
search_plan ::= {
  "financial_metrics_collection": ["Bloomberg", "Yahoo Finance"],
  "news_analysis": ["Reuters", "Financial Times"],
  "analyst_opinions": ["Morning Star", "Seeking Alpha"]
}
dependencies ::= {
  "financial_metrics_collection" -> "news_analysis" -> "analyst_opinions"
}
```

**3. Retrieved Results**
- Structured retrieval results per source
- Including metadata (reliability, timestamp, etc.)

**4. Final Answer**
- Reasoning-based answer synthesizing retrieved results

### Multi-Component Reward System

R-Search conducts RL training by designing separate reward signals for each output component:

$$R_{total} = w_1 R_{reasoning} + w_2 R_{planning} + w_3 R_{retrieval} + w_4 R_{synthesis}$$

```python
def compute_component_rewards(output, ground_truth):
    rewards = {}
    
    # Reasoning step reward: logical consistency
    rewards['reasoning'] = evaluate_logical_consistency(
        output.reasoning_steps
    )
    
    # Planning reward: retrieval efficiency
    rewards['planning'] = evaluate_search_efficiency(
        output.search_dag, ground_truth.required_sources
    )
    
    # Retrieval reward: relevance and completeness
    rewards['retrieval'] = evaluate_retrieval_quality(
        output.retrieved_results, ground_truth.relevant_info
    )
    
    # Synthesis reward: final answer accuracy
    rewards['synthesis'] = evaluate_answer_accuracy(
        output.final_answer, ground_truth.answer
    )
    
    return rewards
```

### Achieving Both Performance and Efficiency

**Benchmark performance:**
- **FinSearchBench-24**: +12% improvement over previous state-of-the-art
- **SearchExpertBench-25**: Expert-level retrieval accuracy achieved
- **7 QA benchmarks**: Average +8.5% performance improvement

**Efficiency improvements:**
- **Context token usage**: 70% reduction
- **Execution latency**: 50% reduction
- **API call count**: 60% reduction

## 9. ReLIFT: Overcoming the Limits of RL and Supervised Learning

**Paper**: ReLIFT: Learning What Reinforcement Learning Can't - Interleaved Online Fine-Tuning for Hardest Questions (arXiv 2506.07527, June 2025)

ReLIFT deeply analyzes the fundamental differences between reinforcement learning and supervised learning, and presents an innovative approach that strategically combines the advantages of both methodologies. The core insight of this research is the discovery that RL and SFT bring different types of improvement.

### Role Differentiation of RL and SFT

**RL's strengths and limitations:**
- Optimizes existing knowledge the model already has
- Improves reasoning patterns
- Limited acquisition of new knowledge

**SFT's strengths and limitations:**
- Introduces new knowledge the model doesn't know
- Fast adaptation with small high-quality examples
- Inefficient utilization of existing knowledge

### ReLIFT's Adaptive Integration Strategy

**1. Dynamic difficulty detection**
```python
def assess_question_difficulty(model, question, threshold=0.3):
    """
    Determine whether the model struggles with a specific question
    """
    # Multiple attempts to check consistency
    attempts = [model.generate(question) for _ in range(5)]
    
    # Calculate answer consistency score
    consistency_score = calculate_consistency(attempts)
    
    # Check accuracy rate
    accuracy = evaluate_answers(attempts, ground_truth)
    
    # Criterion for difficult question
    is_hard = (consistency_score < threshold) or (accuracy < 0.5)
    
    return is_hard, consistency_score, accuracy
```

**2. Interleaved training process**
```python
def relift_training(model, questions, rl_optimizer, sft_optimizer):
    """
    ReLIFT's interleaved RL-SFT training
    """
    for epoch in range(num_epochs):
        # Stage 1: Improve overall performance with RL
        rl_loss = rl_training_step(model, questions, rl_optimizer)
        
        # Stage 2: Identify difficult questions
        hard_questions = []
        for q in questions:
            is_hard, _, _ = assess_question_difficulty(model, q)
            if is_hard:
                hard_questions.append(q)
        
        # Stage 3: Collect high-quality solutions for difficult questions
        if hard_questions:
            expert_solutions = collect_expert_solutions(hard_questions)
            
            # Stage 4: Inject new knowledge/patterns with SFT
            sft_loss = sft_training_step(
                model, hard_questions, expert_solutions, sft_optimizer
            )
        
        print(f"Epoch {epoch}: RL Loss = {rl_loss:.4f}, "
              f"SFT Loss = {sft_loss:.4f}, "
              f"Hard Questions = {len(hard_questions)}")
```

### Innovation in Data Efficiency

One of ReLIFT's most impressive achievements is achieving large performance improvements with extremely limited demonstration data:

**Data usage:**
- Uses only **13% of total demonstration data**
- Applies SFT intensively only on difficult problems

**Performance improvement:**
- **5 competition-level benchmarks**: Average +5.2 points improvement
- **1 out-of-distribution benchmark**: +4.8 points improvement

### Theoretical Implications: Complementarity of Learning

ReLIFT provides the following important theoretical insight:

**Role differentiation of learning methodologies:**
- **RL**: "How to do better?" (optimization)
- **SFT**: "What to learn new?" (knowledge expansion)

**Design principles for efficient learning:**
1. First maximize existing capabilities with RL
2. Inject new knowledge with SFT at the limit point
3. Continuous growth through cyclic repetition

## 10. L2T: Information-Theoretically Efficient Reasoning Learning

**Paper**: L2T: Learning to Think - Information-Theoretic Reinforcement Fine-Tuning (arXiv 2505.10425, May 2025)

L2T (Learning to Think) resolves one of the most fundamental dilemmas in RL-based model training: **the balance between reasoning effectiveness and token efficiency**. Deeper and more detailed reasoning generally produces better results, but simultaneously generates more computation costs and latency.

### Hierarchical Session Modeling

L2T models each query-response interaction as a hierarchical session:

**Session structure:**
```
Session = {
  Query,
  Reasoning Chain: [
    reasoning_step_1,
    reasoning_step_2,
    ...,
    reasoning_step_n
  ],
  Final Answer
}
```

**Hierarchical decision-making:**
- **Macro decision**: How many reasoning steps are needed?
- **Micro decision**: What reasoning to perform at each step?

### Information-Theoretic Reward Design

L2T's core innovation is designing dense process rewards based on **information gain in parameter space**.

**Information gain measurement:**
$$\text{Information Gain} = \mathbb{E}[\log p(\theta_{t+1} | D_{t+1}) - \log p(\theta_t | D_t)]$$

where $\theta_t$ is the model parameters at time $t$ and $D_t$ is training data up to time $t$.

**Practical estimation using PAC-Bayes bounds:**
$$\text{Info Gain} \approx \frac{1}{2} \text{tr}(F(\theta)^{-1} \Delta\theta \Delta\theta^T)$$

where $F(\theta)$ is the Fisher information matrix.

### Efficiency-Effectiveness Balance Mechanism

**Reward function design:**
```python
def compute_l2t_reward(reasoning_steps, final_answer, ground_truth):
    """
    L2T's information-theoretic reward calculation
    """
    # 1. Accuracy reward
    accuracy_reward = evaluate_answer_quality(final_answer, ground_truth)
    
    # 2. Information gain reward
    info_gain_rewards = []
    for step in reasoning_steps:
        # Measure amount of information each reasoning step provides to the model
        info_gain = estimate_information_gain(step)
        info_gain_rewards.append(info_gain)
    
    # 3. Efficiency penalty
    length_penalty = -lambda_efficiency * len(reasoning_steps)
    
    # 4. Regularization to prevent excessive updates
    excessive_update_penalty = -lambda_stability * max(0, 
        max(info_gain_rewards) - info_gain_threshold
    )
    
    # Total reward
    total_reward = (
        accuracy_reward + 
        sum(info_gain_rewards) + 
        length_penalty + 
        excessive_update_penalty
    )
    
    return total_reward
```

### Adaptive Reasoning Length Control

Models trained with L2T learn to automatically adjust reasoning length according to problem complexity:

**Simple problem:**
```
Question: 2 + 3 = ?
Reasoning: Adding 2 and 3 gives 5
Answer: 5
(reasoning steps: 1, tokens: 8)
```

**Complex problem:**
```
Question: Complex geometry problem
Reasoning:
1. Analyze given conditions...
2. Apply relevant theorems...
3. Step-by-step calculation...
4. Verify results...
Answer: [detailed solution]
(reasoning steps: 4, tokens: 156)
```

### Performance and Efficiency Results

**Token efficiency improvements:**
- **Math problem solving**: Average 32% token reduction, 2% performance improvement
- **Logical reasoning**: Average 28% token reduction, performance maintained
- **Coding problems**: Average 35% token reduction, 1.5% performance improvement

**Reasoning quality metrics:**

| Metric | Standard RL | L2T | Improvement |
|--------|---------|-----|--------|
| Accuracy | 78.5% | 80.2% | +1.7% |
| Average tokens | 245 | 168 | -31% |
| Reasoning consistency | 0.72 | 0.81 | +12.5% |
| Computation cost | 100% | 68% | -32% |

## Conclusion: The Future of RL-Based Agent Development

These 10 key research papers published after April 2025 demonstrate that RL-based post-training is establishing itself as the core paradigm for building truly autonomous and intelligent agent systems, going beyond simple language model improvement.

### Key Technical Breakthroughs

**1. Multi-modal tool integration**
As Visual-ARFT and ReTool have demonstrated, through reinforcement learning models can now strategically utilize complex external tools beyond simply generating text. This has laid the foundation for AI agents to perform complex real-world tasks.

**2. Multi-agent collaboration**
The multi-agent RL framework presented by MARFT has enabled complex problem solving through teamwork, transcending the limits of individual agents. This has opened the path to implementing role division and collaboration required in enterprise environments in AI systems.

**3. Balance between efficiency and effectiveness**
L2T and data efficiency improvement research has substantially resolved the problem of high computation costs, which was the biggest obstacle in RL-based training. Practical methodologies for developing high-quality agents with limited resources are now established.

### Integrated Strategy for Practical Application

A comprehensive strategy for applying the results of these research papers to practice can be presented as follows:

**Phase 1: Building foundational capabilities (UFT + sparse updates)**
- Training basic agents integrating supervised and reinforcement learning with UFT
- Efficient parameter optimization leveraging sparse update characteristics

**Phase 2: Developing tool use capability (Visual-ARFT + ReTool)**
- Learning to use domain-specific essential tools
- Strengthening ability to time tool calls and interpret results

**Phase 3: Advanced reasoning and retrieval (R-Search + ReLIFT)**
- Developing multi-source information retrieval and synthesis capability
- Building adaptive learning systems to resolve knowledge gaps

**Phase 4: Team collaboration and efficiency optimization (MARFT + L2T + SEC)**
- Building multi-agent collaboration systems
- Continuous improvement through automated curriculum learning
- Achieving cost efficiency through information-theoretic reasoning optimization

### Future Research Directions and Expected Effects

**Short-term development directions (2025-2026)**
- **Domain-specific optimization**: Optimizing each research's techniques for specific industry areas
- **Hybrid approaches**: Developing integrated frameworks combining multiple techniques
- **Real-time adaptation**: Strengthening online learning and adaptation capability in deployment environments

**Medium and long-term development outlook (2026-2030)**
- **Autonomous agent ecosystems**: Complex systems where diverse specialist agents collaborate
- **Meta-learning**: Universal learning capability to quickly adapt to new domains
- **Human-AI collaboration**: Systems optimally combining human expertise and AI processing capability

### Closing: A New Era of Agentic AI

2025 will be a turning point where RL-based post-training transitions from theoretical research to practical technology. The methodologies presented in these 10 papers are no longer laboratory experiments, but validated technologies immediately applicable in real enterprise environments.

Particularly, opportunities have opened in the Korean AI ecosystem to proactively adopt and develop these technologies, securing advantages in global AI competition. Now that methodologies for building world-class agent systems with limited resources have been established, execution capability and application strategy will be the key to success.

The future of RL-based agent development is no longer in the realm of "possibility" but in the realm of "reality." How these technologies are combined and utilized will determine the competitiveness of next-generation AI systems.

## References

The arXiv sources for the papers covered in this review are listed below. Each link was verified against its arXiv abstract page at the time of writing.

1. Visual Agentic Reinforcement Fine-Tuning (Visual-ARFT): [https://arxiv.org/abs/2505.14246](https://arxiv.org/abs/2505.14246)
2. MARFT: Multi-Agent Reinforcement Fine-Tuning: [https://arxiv.org/abs/2504.16129](https://arxiv.org/abs/2504.16129)
3. ReTool: Reinforcement Learning for Strategic Tool Use in LLMs: [https://arxiv.org/abs/2504.11536](https://arxiv.org/abs/2504.11536)
4. Reinforcement Learning Finetunes Small Subnetworks in Large Language Models: [https://arxiv.org/abs/2505.11711](https://arxiv.org/abs/2505.11711)
5. UFT: Unifying Supervised and Reinforcement Fine-Tuning: [https://arxiv.org/abs/2505.16984](https://arxiv.org/abs/2505.16984)
6. Self-Evolving Curriculum for LLM Reasoning: [https://arxiv.org/abs/2505.14970](https://arxiv.org/abs/2505.14970)
7. Improving Data Efficiency for LLM Reinforcement Fine-tuning Through Difficulty-targeted Online Data Selection and Rollout Replay: [https://arxiv.org/abs/2506.05316](https://arxiv.org/abs/2506.05316)
8. Reinforcement Fine-Tuning for Reasoning towards Multi-Step Multi-Source Search (R-Search): [https://arxiv.org/abs/2506.08352](https://arxiv.org/abs/2506.08352)
9. Learning What Reinforcement Learning Can't: Interleaved Online Fine-Tuning for Hardest Questions (ReLIFT): [https://arxiv.org/abs/2506.07527](https://arxiv.org/abs/2506.07527)
10. Learning to Think: Information-Theoretic Reinforcement Fine-Tuning for LLMs (L2T): [https://arxiv.org/abs/2505.10425](https://arxiv.org/abs/2505.10425)
