---
title: "The Post-Training Revolution: Top 10 RL Papers for Agent Development"
excerpt: "A review of the 10 most-starred reinforcement learning post-training papers on GitHub, covering group reward optimization, preference alignment, and new directions in agent training."
seo_title: "Top 10 RL Post-Training Papers for Agent Development - Thaki Cloud"
seo_description: "A comprehensive analysis of the 10 highest GitHub-starred RL post-training papers, covering ToolRL, GMPO, Pre-DPO, DRPO, and other cutting-edge methods reshaping LLM agent training."
date: 2025-08-22
last_modified_at: 2025-08-22
lang: en
categories:
  - research
tags:
  - reinforcement-learning
  - post-training
  - LLM
  - agent-development
  - GRPO
  - DPO
  - reward-optimization
  - tool-use
author_profile: true
toc: true
toc_label: "Table of Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/en/research/post-training-revolution-rl-agent-development/"
reading_time: true
published: true
---

⏱️ **Estimated reading time**: 18 min

## Introduction

Reinforcement learning (RL) post-training is rapidly evolving as the core technology for transforming large language models into genuine agents. In 2025, a large number of innovative methodologies were proposed in this area, and the community has validated the value of each through practical experiments.

In this article, we comprehensively analyze the top 10 papers by GitHub stars in RL post-training for agent development. From the foundational approaches of GRPO and GMPO to the novel ideas of tool use learning and dual-policy optimization, we will look at the current state and future of agent training technology.

## Ranking Criteria and Methodology

The papers selected are those that received the most attention in the AI research community based on GitHub stars. Stars are not just a popularity indicator but reflect the degree of practical interest from researchers and engineers.

| Rank | Paper | GitHub Stars |
|------|-------|------|
| 1 | ToolRL | 311 |
| 2 | GMPO | 66 |
| 3 | Pre-DPO | 7 |
| 4 | DRPO | 3 |
| 5 | Multi-Layer GRPO | 0 |
| 6 | mmGRPO (DSPy) | 0 |
| 7 | GTPO/GRPO-S | 0 |
| 8 | ExPO | 0 |
| 9 | Rewarding the Unlikely | 0 |
| 10 | KDRL | 0 |

While some papers in the lower ranks have zero stars due to recent publication, all present novel contributions to the field.

## 1st Place: ToolRL (311 stars)

### Overview

ToolRL is a framework for training LLMs to strategically select and use external tools. It achieved the highest community attention with 311 GitHub stars, demonstrating particularly impressive results in mathematical reasoning.

### Core Innovation

ToolRL's core innovation lies in training the timing and method of tool use through RL. Rather than training the model on when to call the code interpreter through fixed rules, it learns autonomously from rewards for optimal outcomes.

Key technical contributions:

**Flexible Trajectory Generation**: The model can write and execute code at any point during the reasoning process, and the RL training signal is derived from the final outcome.

**Error Recovery Learning**: Even when code execution produces errors, the model learns to analyze the error message and rewrite corrected code. This self-repair capability emerges automatically rather than being explicitly taught.

**Adaptive Tool Selection**: The model learns to select the most appropriate approach depending on the problem characteristics: direct calculation for simple arithmetic, code execution for complex mathematical operations.

### Performance Results

- **AIME2024**: 72.5% accuracy (27.9% above OpenAI o1-preview)
- **Training efficiency**: 67% accuracy in 400 steps (vs 40% accuracy in 1,080 steps with text-only RL)

### Significance and Implications

ToolRL's success demonstrates that tool use is not something that can be learned through simple instruction following, but must be acquired through genuine outcome-based learning. This provides important direction for future agent training research.

## 2nd Place: GMPO (66 stars)

### Overview

GMPO (Group Mean Policy Optimization) is an improved version of GRPO that improves training stability and performance through more sophisticated group-based reward normalization.

### Technical Details

GRPO's basic approach normalizes rewards within a group. However, the original GRPO has several issues:

1. **Reward bias**: When reward distributions within a group are imbalanced, normalization can work incorrectly
2. **Gradient instability**: When the variance within a group is large, gradient magnitudes become unstable
3. **Sample efficiency**: Naive group sampling misses important samples

GMPO resolves these issues through the following innovations:

**Adaptive Group Composition**: Rather than random group composition, groups are formed by sampling based on difficulty and diversity, ensuring more informative samples are included.

**Hierarchical Reward Normalization**: Separate normalization is applied not just within groups but also between groups, stabilizing the overall reward distribution.

**Momentum-based Updates**: Moving averages from previous group statistics are incorporated to prevent rapid fluctuations in reward normalization.

### Mathematical Formulation

GMPO's optimization objective is as follows:

$$J_{GMPO}(\theta) = \mathbb{E}_{g \sim G}[\hat{V}_{DR}(s_g, a_g)]$$

where $G$ is the set of groups, and $\hat{V}_{DR}$ is the doubly robust value estimator:

$$\hat{V}_{DR} = \hat{V}_{direct} + \frac{\pi_\theta(a|s)}{\pi_{old}(a|s)}(R - \hat{V}_{direct})$$

### Performance Improvements

Compared to standard GRPO:
- Training stability improvement: loss variance reduced by 23%
- Final performance: average improvement across diverse benchmarks of 4.2 points
- Training speed: 15% faster convergence

## 3rd Place: Pre-DPO (7 stars)

### Overview

Pre-DPO (Pre-training augmented DPO) is a method that significantly improves DPO performance by incorporating pre-training data into the DPO training process.

### Problem Statement

Standard DPO training can suffer performance degradation on abilities learned during pre-training. This is because the DPO optimization process can interfere with existing knowledge representations.

Pre-DPO addresses this problem with the following approach:

**Mixed Objective**: Simultaneously optimizing both the DPO objective and a language modeling objective during training prevents forgetting of pre-training knowledge.

$$\mathcal{L}_{Pre-DPO} = \mathcal{L}_{DPO} + \lambda \mathcal{L}_{LM}$$

where $\mathcal{L}_{LM}$ is the standard causal language modeling loss.

**Data Curriculum**: Mixing pre-training data in a specific ratio during the early phases of DPO training maintains core abilities learned during pre-training.

### Key Findings

Pre-DPO experiments revealed that:
1. Standard DPO reduces performance on common reasoning tasks by 3-7%
2. Pre-DPO completely eliminates this regression
3. Alignment performance is simultaneously improved over standard DPO

This research highlights the importance of considering pre-training knowledge when optimizing with RL or RLHF methods.

## 4th Place: DRPO (3 stars)

### Overview

DRPO (Doubly Robust Policy Optimization) is a method that enhances robustness by applying the doubly robust estimation technique, well known in causal inference, to LLM policy optimization.

### Doubly Robust Estimation

The doubly robust estimator has the property of providing consistent estimates even when one of two models is incorrect. This is expressed as follows:

$$\hat{V}_{DR} = \hat{V}_{direct} + \frac{\pi_\theta(a|s)}{\pi_{old}(a|s)}(R - \hat{V}_{direct})$$

Here:
- $\hat{V}_{direct}$: Direct value estimator
- $\frac{\pi_\theta(a|s)}{\pi_{old}(a|s)}$: Importance sampling weight
- $R$: Actual reward

When both the direct estimator and importance sampling weight are approximately correct, the estimator provides a very accurate value estimate. Critically, even if only one is correct, it provides an unbiased estimate.

### Application to LLM Post-Training

When applied to LLM post-training, DRPO provides the following benefits:

**Reward Model Robustness**: Even when the reward model has errors, it can be compensated through importance sampling correction.

**Distribution Shift Handling**: When distribution shift between current policy and reference policy is large, importance sampling correction prevents biased gradient estimates.

**Training Stability**: The doubly robust property stabilizes training and prevents reward hacking.

### Experimental Results

DRPO showed average improvement of 3.8 points compared to standard PPO across diverse benchmarks, with particularly prominent effects in tasks with high reward model uncertainty.

## 5th Place: Multi-Layer GRPO

### Overview

Multi-Layer GRPO extends standard GRPO by applying reward signals at multiple layers simultaneously. This helps the model receive learning signals at different levels of abstraction.

### Multi-Layer Reward Architecture

Standard GRPO provides reward only at the sequence level. Multi-Layer GRPO additionally provides rewards at the following levels:

**Token-level reward**: Reward for each generated token. This allows fine-grained learning signals.

**Sentence-level reward**: Reward for each generated sentence. This helps maintain coherence between paragraphs.

**Paragraph-level reward**: Reward at logical unit level. This improves the overall structure of long text generation.

**Document-level reward**: Reward for the final complete response. This is the same as standard GRPO.

### Mathematical Formulation

The total reward in Multi-Layer GRPO is as follows:

$$J_{GRPO}(\theta) = \sum_{l \in L} w_l \mathbb{E}_{x,y^l}[r_l(x, y^l)]$$

Here $L$ is the set of layers, $w_l$ is the weight for each layer, and $r_l$ is the reward function for that layer.

### Performance Analysis

Multi-Layer GRPO showed particular effectiveness in long text generation tasks:
- Single turn response: +2.1 points improvement
- Multi-turn dialogue: +4.7 points improvement
- Long document generation: +8.3 points improvement

As text length increases, the effect of multi-layer rewards becomes larger. This shows the importance of maintaining coherence in long text.

## 6th Place: mmGRPO (DSPy)

### Overview

mmGRPO is an implementation of GRPO combined with the DSPy framework, and is particularly designed for multimodal settings.

### DSPy Integration

DSPy is a framework for optimizing LLM programs through declarative language model programming. mmGRPO applies RL optimization by incorporating GRPO into DSPy's optimization loop.

Key features of this integration:
- **Automatic prompt optimization**: GRPO is applied not just to model weights but also to prompt templates
- **Module-level optimization**: DSPy's modular structure enables RL optimization of individual modules
- **Multimodal support**: Text and image processing modules can be jointly optimized

### Multimodal RL Challenges

Applying GRPO in multimodal settings presents the following unique challenges:

**Cross-modal reward design**: How to evaluate combinations of text and image responses.

**Modality imbalance**: If one modality provides stronger learning signals, the other modality can be dominated.

**Computational efficiency**: Processing multiple modalities simultaneously increases computational costs.

mmGRPO addresses these challenges through cross-modal reward normalization and adaptive modality weighting.

## 7th Place: GTPO and GRPO-S

### GTPO (Group Trajectory Policy Optimization)

GTPO improves GRPO's efficiency by using complete trajectory information rather than optimizing at the individual token level.

In GTPO, the group is not individual responses but entire reasoning trajectories. This provides the following benefits:

**Long-term credit assignment**: Rather than attributing the final outcome to individual tokens, it is attributed to the entire reasoning chain. This enables better learning of long-horizon problems.

**Trajectory diversity**: Within a group, diverse trajectories are included, allowing learning of multiple solution paths for the same problem.

**Sparse reward handling**: Even when rewards are provided only at the final step, trajectory-level optimization can spread reward signals throughout the reasoning process.

### GRPO-S (GRPO with Selective Sampling)

GRPO-S improves GRPO's sample efficiency through selective sampling. Rather than random group sampling, it selects samples most useful for training.

Selection criteria:
1. **Difficulty balance**: Including both easy and hard problems in balanced proportion
2. **Response diversity**: Including groups with diverse responses, not uniform responses
3. **Uncertainty-based selection**: Prioritizing samples where the model is uncertain

### Performance Comparison

| Method | Average Accuracy | Training Efficiency |
|-------|---------|---------|
| Standard GRPO | 68.2% | baseline |
| GTPO | 71.4% | 1.2x |
| GRPO-S | 70.8% | 1.4x |
| GTPO + GRPO-S | 73.1% | 1.5x |

## 8th Place: ExPO (Extrapolation Policy Optimization)

### Overview

ExPO introduces an extrapolation approach to LLM post-training. Instead of directly optimizing the current policy, it trains a policy that performs beyond the maximum performance point of the current policy.

### Extrapolation Mechanism

ExPO's extrapolation mechanism works as follows:

1. **Reference policy**: Start from the SFT model as reference
2. **Exploration boundary estimation**: Estimate the boundary of the current policy's exploration space
3. **Extrapolated target**: Set targets beyond the estimated boundary
4. **Interpolation training**: Gradually train from current performance toward the extrapolated target

This process can be formulated mathematically as:

$$\theta_{ExPO} = \theta_{SFT} + \alpha \cdot (\theta_{RL} - \theta_{SFT})$$

Here $\alpha > 1$ is the extrapolation coefficient, and it points in a direction beyond the RL-optimized weights.

### Experimental Results

ExPO was particularly effective in creativity tasks:
- Creative writing: +9.2 points improvement
- Novel problem solving: +7.8 points improvement
- Mathematical exploration: +5.4 points improvement

This suggests the effectiveness of extrapolation approaches especially in tasks requiring diverse and creative solutions.

## 9th Place: Rewarding the Unlikely

### Overview

This paper presents a novel insight into RL-based LLM training: high-reward signals are obtained for unusual or low-probability responses.

### The Key Problem

In standard RL training, reward signals are stronger for high-probability responses. This tends to reinforce behaviors that the model already does well. However, this can cause the model to converge on local optima and miss genuinely optimal solutions.

"Rewarding the Unlikely" proposes directly providing learning signals for unusual but high-value responses.

### Implementation Strategy

The key implementation strategies are:

**Inverse Probability Weighting**: Applying inverse proportional weighting to the probability of each response. This makes the learning signal stronger for low-probability responses.

$$w(y) = \frac{1}{\pi_\theta(y|x)} \cdot R(x, y)$$

**Diversity Bonus**: Providing additional rewards for responses that are different from other responses in the group. This promotes generation of diverse solutions.

**Rare Pattern Reward**: Identifying patterns that are rare in training data and providing additional rewards for their appropriate use.

### Theoretical Grounding

This approach is theoretically grounded in the importance sampling theory of RL. By giving higher weights to rare but high-value events, it achieves more efficient exploration.

### Practical Results

Compared to standard GRPO:
- Diversity metrics: 34% improvement in response diversity
- Novel problem solving: 6.7 points improvement in previously unseen problem types
- Generalization: 4.2 points improvement on out-of-distribution benchmarks

## 10th Place: KDRL (Knowledge Distillation RL)

### Overview

KDRL (Knowledge Distillation Reinforcement Learning) is a method that combines knowledge distillation with RL. It transfers knowledge from a large teacher model to a small student model while simultaneously applying RL optimization.

### Dual Optimization Objective

KDRL simultaneously optimizes two objectives:

1. **RL objective**: Maximizing rewards through environmental interaction
2. **Distillation objective**: Minimizing divergence between student model and teacher model

$$\mathcal{L}_{KDRL} = \mathcal{L}_{RL} + \beta \cdot \mathcal{L}_{KD}$$

where $\mathcal{L}_{KD}$ is the knowledge distillation loss:

$$\mathcal{L}_{KD} = KL(\pi_{student} || \pi_{teacher})$$

### Benefits

**Efficient Training**: Leveraging teacher model knowledge reduces the number of RL exploration steps needed.

**Stable Learning**: Distillation loss prevents overfitting during RL training.

**Capability Transfer**: The small model can acquire capabilities of the large model through distillation.

### Results

KDRL achieved performance comparable to models 3x larger while maintaining a compact model size. This is economically valuable from a deployment perspective.

## Synthesis and Trends

### Common Technical Directions

Analyzing the top 10 papers reveals several common technical trends.

**Reward design innovation**: Moving away from simple final outcome rewards toward more fine-grained intermediate rewards and process rewards. Multi-Layer GRPO and KDRL both follow this direction.

**Improving exploration efficiency**: Beyond random exploration to more structured and efficient exploration. ToolRL, GRPO-S, and Rewarding the Unlikely all contribute to improving exploration efficiency.

**Stability and robustness**: DRPO, Pre-DPO, GMPO all focus on training stability and robustness. This shows awareness that instability is a major problem in practical RL post-training.

**Multi-scale learning**: Providing learning signals at multiple scales from token level to trajectory level. This is particularly prominent in Multi-Layer GRPO and GTPO.

### Current Research Challenges

**Reward hacking**: Still an unsolved problem where models learn strategies that score high on reward metrics while not genuinely improving. More robust reward design is needed.

**Scalability**: The effectiveness of most methods when scaled to very large models (100B+) has not been verified. Understanding the relationship between model size and RL post-training effectiveness remains an important research challenge.

**Sample efficiency**: RL training still requires enormous amounts of data and computation. Fundamental improvements in sample efficiency are important from a practical perspective.

**Evaluation reliability**: Whether existing benchmarks accurately reflect the abilities needed for actual agent use is questionable. Development of more realistic evaluation frameworks is needed.

### Future Directions

Based on the current research trends, the following directions are expected to develop:

**Multi-agent RL**: Rather than single-agent optimization, multiple agents learning while interacting with each other. This will be important for complex collaborative task scenarios.

**World model integration**: Rather than learning directly from environmental interaction, using world models to more efficiently learn strategies.

**Self-improvement loops**: Systems where models discover their own weaknesses and design improvement plans. This is an approach toward ultimately achieving autonomous improvement.

**Constitutional AI integration**: Incorporating ethical constraints and social norms naturally into RL training.

## Practical Application Guide

### Selection by Use Case

| Use Case | Recommended Method | Reason |
|---------|---------|------|
| Mathematical reasoning | ToolRL, GMPO | Code execution and stable group optimization |
| Multimodal tasks | mmGRPO | Native multimodal support |
| Long text generation | Multi-Layer GRPO | Multi-layer reward for coherence maintenance |
| Low-resource environments | KDRL | Efficient knowledge transfer from large models |
| Creative tasks | ExPO, Rewarding the Unlikely | Diverse exploration emphasis |
| General purpose | DRPO, Pre-DPO | Stability and regression prevention |

### Implementation Considerations

When implementing these methods in practice, the following points need attention:

**Reward design comes first**: RL training can fail for many reasons, but inadequate reward design is the most common. Before applying any of these methods, first carefully design and validate the reward function.

**Start with small-scale experiments**: Begin small-scale experiments first to validate that the method works before scaling to full-scale training. This significantly reduces time and resource waste.

**Monitor training stability**: RL training can become unstable at any time. Real-time monitoring of training loss, reward trends, and policy entropy is essential.

**Manage baseline comparison carefully**: When comparing with baselines, ensure evaluation conditions and data sets are exactly the same. Many differences can appear just from experimental setup.

## Conclusion

RL post-training for agent development is rapidly evolving, with each paper proposing new innovations. The 10 papers analyzed in this article each contribute different pieces to the overall picture.

ToolRL demonstrated the importance of tool use learning, GMPO improved training stability, DRPO introduced statistical robustness, and various other methods contributed from diverse angles.

What these papers share is the recognition that genuine agent capability cannot be learned through simple instruction following but must be acquired through genuine experience-based learning. The reward structures, optimization methods, and exploration strategies they propose each contribute to making this learning more efficient and effective.

The evolution of agent training technology in 2025 is just beginning. The methodologies these papers have established will provide important foundations for further innovation in the future.
