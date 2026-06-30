---
title: "Frontiers of Reinforcement Learning Post-Training in 2025: A Deep Review of 10 Essential Papers"
excerpt: "An in-depth analysis of the most important reinforcement learning post-training research published from April 2025 onward. From Kimi k1.5 to AlphaMed, we examine the latest techniques transforming LLM reasoning capabilities."
seo_title: "Top 10 RL Post-Training Papers of 2025 Review - Frontiers of Reasoning Innovation - Thaki Cloud"
seo_description: "Detailed analysis of 10 leading reinforcement learning post-training papers from 2025, including Kimi k1.5, Microsoft RPT, and Agent Lightning. Key techniques for improving LLM reasoning and practical insights for deployment."
date: 2025-08-25
last_modified_at: 2025-08-25
categories:
  - research
tags:
  - reinforcement-learning
  - post-training
  - LLM
  - reasoning
  - AI-research
  - paper-review
  - machine-learning
  - artificial-intelligence
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/en/research/reinforcement-learning-post-training-top-10-papers-review/"
lang: en
permalink: /en/research/reinforcement-learning-post-training-top-10-papers-review/
reading_time: true
---

![Key concept illustration](/assets/images/reinforcement-learning-post-training-top-10-papers-review-hero.png)

⏱️ **Estimated reading time**: 25 min

## Introduction: A New Horizon Opened by RL Post-Training

2025 has been a year of rapid advancement in Reinforcement Learning Post-Training (RLPT), a field that dramatically improves the reasoning abilities of large language models (LLMs). The remarkable reasoning performance demonstrated by OpenAI's o1 model is no longer the exclusive domain of closed, proprietary systems.

This article provides a deep analysis of the ten most important papers on reinforcement learning post-training published from April 2025 to the present. These works offer innovations ranging from concrete methods for lifting open models in the 7B to 13B parameter range to GPT-4-level reasoning, through to specialized applications in domains such as medicine and law.

By examining the core ideas and practical implications of each paper, we explore how reinforcement learning is forging a new paradigm that pushes past the limitations of current LLMs.


![Concept diagram](/assets/images/reinforcement-learning-post-training-top-10-papers-review-diagram.svg)

*Concept diagram*

## 1. Kimi k1.5: Setting a New Standard for Reasoning via Large-Scale RL

### Core Contributions and Innovations

Kimi k1.5 achieved what can fairly be described as a landmark result in 2025 RL post-training research. The most striking finding is that it matched OpenAI's o1 model using a relatively straightforward RL framework, **without relying on complex MCTS (Monte Carlo Tree Search) or value networks**.

Trained as a multimodal LLM with large-scale reinforcement learning, the model demonstrates state-of-the-art reasoning results on mathematics and coding benchmarks through long-context processing and improved policy optimization. In particular, **lifting 7B to 13B parameter models to GPT-4-level reasoning tasks** is a vivid illustration of the latent potential in open models.

### The Long-to-Short CoT Transfer Innovation

One notable technique introduced in this work is **Long-to-Short Chain-of-Thought (CoT) transfer**. The approach first trains on long-form reasoning traces and then compresses those traces into a more compact form, dramatically improving reasoning accuracy.

\[
P(\text{short CoT} | \text{input}) = \sum_{\text{long CoT}} P(\text{short CoT} | \text{long CoT}, \text{input}) \cdot P(\text{long CoT} | \text{input})
\]

This formulation allows the model to internalize a complex reasoning process and then use a compressed, efficient version of it at inference time.

### Practical Implications

Kimi k1.5's success demonstrates that **pure RL-based post-training is scalable**. It provides concrete guidance for building high-performance, domain-expert systems from open models. The practical insights into policy optimization tricks and infrastructure design are immediately applicable knowledge for enterprise environments.

## 2. Microsoft RPT: A Fundamental Rethinking of the Pre-Training Paradigm

### A New Horizon for Reinforcement Pre-Training

Microsoft's Reinforcement Pre-Training (RPT) work proposes an approach that redefines the pre-training paradigm for LLMs itself. Moving beyond the conventional next-token prediction objective, it treats **token prediction with a verifiable reward as a "reasoning" task and trains it with reinforcement learning**.

### The Potential of General-Purpose Reinforcement Learning

The key insight in RPT is that vast quantities of unlabeled text can be used for general-purpose RL training. This not only substantially improves language modeling accuracy but also produces stronger base models for subsequent fine-tuning.

\[
\mathcal{L}_{RPT} = \mathbb{E}_{s,a \sim \pi}[R(s,a) - \beta \log \pi(a|s)]
\]

Here \(R(s,a)\) is the verifiable reward for token prediction and \(\beta\) is the entropy regularization coefficient.

### The Possibility of Continuous Improvement

RPT's success is particularly significant because it shows **consistent performance gains as more compute is invested**. This suggests that continuous improvement beyond the limits of supervised training data is achievable, hinting at a future of large base models trained through self-play or feedback loops.

## 3. A Critical Examination of the Limits of Reasoning Ability

### Does RL Actually Elicit New Reasoning?

The work by Yue et al. raises an important question about the limitations of current RL-based fine-tuning. The finding that **current RL methods fail to elicit fundamentally new reasoning skills beyond what the pre-trained base model already knows** is a sobering result.

### Reweighting Existing Abilities vs. Emergence of New Capabilities

The researchers found that RL fine-tuned models excel at top-1 accuracy, but when multiple attempts are allowed, the original base model matches or outperforms them. This implies that RL is primarily performing **reweighting of existing capabilities** rather than unlocking new ones.

\[
P_{RL}(\text{correct} | \text{single attempt}) > P_{base}(\text{correct} | \text{single attempt})
\]
\[
P_{RL}(\text{correct} | \text{multiple attempts}) \approx P_{base}(\text{correct} | \text{multiple attempts})
\]

### The Gap from the Theoretical Upper Bound

Notably, all popular RL algorithms performed similarly, and all fell well short of the theoretical upper bound implied by the base model. This suggests that **current RLHF/RLVR amplifies the base model's reasoning rather than extending it**.

## 4. Effective Combination of Offline and Online RL

### Meta's Systematic Comparative Study

Meta's research provides a thorough empirical comparison of fine-tuning strategies (offline vs. semi-online vs. fully online) and objective functions (DPO vs. PPO-based GRPO). The central finding is that **pure offline DPO falls noticeably behind, but running DPO in an online or iterative loop can match the performance of online GRPO (PPO)**.

### The Superiority of Online Learning

Both semi-online DPO and fully online DPO achieved results comparable to PPO-based methods, and all online approaches substantially outperformed static offline training.

\[
\text{Performance}: \text{Online Methods} >> \text{Offline Methods}
\]

### Combining Verifiable and Preference-Based Rewards

A particularly noteworthy finding is that mixing verifiable rewards (for tasks like math) with non-verifiable preference rewards yields the best results. This provides practitioners with **valuable insight into when to use offline versus online RL when fine-tuning with limited human-labeled data**.

## 5. The Reality and Limits of Domain Transfer

### UIUC's Domain Generalization Research

UIUC's "Breaking Barriers" study addresses a highly practical question for enterprise settings: **does a model RL-tuned in one domain help in a different domain?**

### The Asymmetry of Cross-Domain Transfer

The findings are clear: **RL improvements are narrow in scope**. Models excel at tasks similar to their RL training data, but the gains often disappear when the task requires a different reasoning pattern.

- **Math/coding RL tuning**: generalizes well across other structured tasks
- **Unstructured domain RL tuning**: does not generalize to other unstructured domains
- **Interestingly**: unstructured-domain RL sometimes transfers to structured tasks, but the reverse does not hold

### The Necessity of Domain-Specific Training

This highlights that **building agents for finance, law, or medicine requires domain-specific RL fine-tuning using data and rewards representative of that domain**.

## 6. Agent Lightning: A General-Purpose RL Training Framework for Agents

### Seamless Compatibility with Existing Agents

Microsoft's Agent Lightning presents an approach that allows **RL to be applied to any agent without modifying its existing code**. Any agent built with LangChain, OpenAI Functions, custom code, or other tooling can be connected and fine-tuned with RL.

### Hierarchical RL and Credit Assignment

By formalizing multi-step agent execution as a Markov Decision Process (MDP) and providing a unified interface over trajectories, the framework enables **hierarchical RL and per-step credit assignment**.

\[
G_t = \sum_{k=0}^{T-t} \gamma^k R_{t+k+1}
\]

Here \(G_t\) is the discounted cumulative reward at time step \(t\).

### Practical Value

Agent Lightning delivers **a practical solution for continuously improving agents in real workflows**. It shows stable performance gains on text-to-SQL, retrieval-augmented QA, and tool-use math problems, providing an "RL fine-tuning layer" that transforms a base LLM into a reliable, domain-specialized agentic system.

## 7. ASearcher: A New Frontier for Long-Horizon Tool Use

### An Innovative Web-Search-Specialized Agent

ASearcher, from Tsinghua and Ant Group, is an **open-source RL-trained agent specialized in web search and browsing**, aiming for expert-level "search intelligence." The research makes two key contributions:

1. **A fully asynchronous RL training system that scales to very long tool-use sequences**
2. **Prompt-based self-play in which the agent generates its own difficult QA challenges for self-training**

### Tool Use at Extreme Scale

Through online RL, a 32B model achieved a **remarkable +46.7% performance gain** on the web-search benchmark xBench. Even more striking is that the model learned to conduct searches involving **more than 40 sequential tool calls and over 150k output tokens**.

\[
\text{Performance Gain} = \frac{\text{Score}_{RL} - \text{Score}_{base}}{\text{Score}_{base}} = +46.7\%
\]

### Realizing Long-Horizon Reasoning

ASearcher demonstrates that **RL can unlock long-horizon, multi-step reasoning abilities that static models struggle with**. An agent that diligently searches, analyzes, and cross-validates information in finance, law, or research is a highly valuable asset.

## 8. ARTIST: Tight Integration of Reasoning and Tool Use

### Learning Adaptive Tool-Use Strategies

MSR's ARTIST is a framework that **tightly couples decision-making about multi-step reasoning and tool use**, optimizing both with RL. Rather than relying on fixed prompts or rules, the LLM learns when and how to invoke external tools (calculators, code interpreters, search APIs, and others) within its chain of thought.

### The Power of Outcome-Based Rewards

Using only **outcome-based rewards** without step-level supervision, ARTIST develops robust and adaptive tool-use strategies. On difficult mathematical reasoning and function-calling tasks, it **surpasses state-of-the-art baselines by up to 22 absolute accuracy points**.

\[
\text{Accuracy Improvement} = \text{Acc}_{ARTIST} - \text{Acc}_{baseline} \leq 22\%
\]

### Evolution toward Autonomous Problem-Solving Agents

ARTIST's approach demonstrates **how enterprise LLMs can become autonomous problem-solving agents**. By learning to call tools when needed, the model becomes substantially more reliable and interpretable.

## 9. AlphaMed: A Breakthrough in Medical Domain Specialization

### The First Medical LLM Acquiring Reasoning Purely through RL

AlphaMed, from Imperial/TUM/HKUST, showcases **innovation in domain specialization**. It is the first medical LLM to acquire reasoning ability using only RL with simple rule-based rewards.

### Success without Supervised Learning

Without any supervised chain-of-thought fine-tuning on expensive GPT-4-generated data, the team **applied RL with basic correctness rewards to publicly available medical QA datasets**. AlphaMed achieves state-of-the-art accuracy on six medical question-answering benchmarks.

### Surpassing Much Larger Models

On the most demanding dataset (MedXpert), AlphaMed **outperforms substantially larger closed models, including DeepSeek-V3 (671B) and Claude 3.5**. This suggests that in domain specialization, the optimization method may matter more than model scale.

\[
\text{Performance}: \text{AlphaMed} > \text{DeepSeek-V3 (671B)} > \text{Claude 3.5}
\]

### A New Paradigm for Vertical LLM Development

AlphaMed's success proves that **RL alone, paired with carefully designed rewards (here, rule-based checks that encourage informative and step-by-step answers), can elicit robust reasoning in specialized domains**.

## 10. General-Reasoner: An Integrated Approach to Reasoning Across All Domains

### Challenging the Math/Coding Bias

General-Reasoner, from the University of Waterloo, proposes a new training paradigm that **overcomes the bias of prior RL efforts being confined to math and coding**. Its goal is to extend RL-based reasoning across diverse domains.

### A Multidisciplinary Verifiable Dataset

The core contributions are the construction of **a large-scale multidisciplinary question dataset spanning physics, chemistry, finance, and other fields, with verifiable answers**, and the introduction of **a generative chain-of-thought verifier that replaces fragile rule-based checkers**.

### Success in the Zero-RL Setting

By training with this data and verifier in a "Zero-RL" setting (no supervised pre-fine-tuning), General-Reasoner achieves **robust, generalizable performance across 12 benchmarks beyond mathematics**. It gains roughly 10% on broad knowledge benchmarks while maintaining performance on math tasks comparable to math-specialized frameworks.

### Leveraging Cross-Domain Synergy

The most notable result is that **a 14B model reaches a level competitive with GPT-4 on multiple academic benchmarks**. General-Reasoner is fundamentally a silo-breaking piece of research, showing a path to training LLM agents that reason well across all domains by leveraging cross-domain synergies through RL, without sacrificing math and coding capabilities.

## Conclusion: The AI Future RL Is Opening

### A Turning Point for the Paradigm

The 2025 RL post-training papers demonstrate not just technical improvement but a **fundamental shift in the AI development paradigm**. From the scalability of pure RL proven by Kimi k1.5 to the redefined pre-training vision of Microsoft RPT, these works lay out concrete paths through which open models can match or exceed the performance of closed ones.

### Practical Implications and an Honest Account of Limits

At the same time, as the critical work by Yue et al. shows, **it is important to honestly recognize the limits of current RL methods**. The finding that RL primarily reweights existing capabilities points to the need for more innovative RL techniques going forward.

### The Importance of Domain Specialization

UIUC's domain-transfer research and AlphaMed's medical-domain success offer important insights about **the balance between generality and specialization**. When an organization wants peak performance in a specific domain, domain-specific RL training is essential.

### Advances in Long-Horizon Reasoning and Tool Use

The long-horizon reasoning and adaptive tool-use capabilities demonstrated by ASearcher and ARTIST open the possibility that **AI agents can move beyond simple question-answering to tackle complex problem-solving and decision-making**.

### Looking Ahead: The Need for an Integrated Approach

The multi-domain integrated approach proposed by General-Reasoner points to **the direction future AI systems should take**. Simultaneously achieving depth in specific domains and breadth across multiple domains will be the central challenge for the next generation of AI agents.

### Closing Thoughts: A Horizon of New Possibilities

These ten papers prove that reinforcement learning is not merely a tool for incremental model improvement, but a **paradigm that fundamentally transforms AI reasoning capabilities**. Combined with democratized access to open models, these innovations are opening a new golden era of AI development.

Future research will evolve toward overcoming the limits of current methods while increasing practical applicability. RL post-training is no longer a laboratory experiment, but a **powerful tool that companies and developers can put to real use**.

## References

Primary sources for the research and tools discussed in this post.

- [Kimi k1.5: Scaling Reinforcement Learning with LLMs (arXiv:2501.12599)](https://arxiv.org/abs/2501.12599)
- [Reinforcement Pre-Training / RPT (arXiv:2506.08007)](https://arxiv.org/abs/2506.08007)
- [Agent Lightning: Train ANY AI Agents with RL (arXiv:2508.03680)](https://arxiv.org/abs/2508.03680)
- [Beyond Ten Turns / ASearcher (arXiv:2508.07976)](https://arxiv.org/abs/2508.07976)
- [ARTIST: Agentic Reasoning and Tool Integration via RL (arXiv:2505.01441)](https://arxiv.org/abs/2505.01441)
- [AlphaMed: Minimalist Rule-Based RL for Medical Reasoning (arXiv:2505.17952)](https://arxiv.org/abs/2505.17952)
- [General-Reasoner: Advancing LLM Reasoning Across All Domains (arXiv:2505.14652)](https://arxiv.org/abs/2505.14652)
