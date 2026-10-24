---
title: "The Inference Moat Was Filled"
excerpt: "The open frameworks SGLang and vLLM have caught up with DeepSeek's newly open-sourced inference engine DeepInfer, matching or exceeding its performance. We analyze the signal of inference becoming commoditized and the industry's center of gravity moving to the layers above the engine."
seo_title: "Inference Engine Commoditization: SGLang and vLLM Catch Up With DeepSeek DeepInfer"
seo_description: "SGLang and vLLM have matched DeepSeek DeepInfer on performance. In one analysis: this week's inference commoditization, cost-cutting moves, and the rise of the execution-judgment layer."
date: 2026-10-25
last_modified_at: 2026-10-25
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "robot"
tags:
  - inference
  - deepseek
  - sglang
  - vllm
  - llmops
  - cost-optimization
  - agent-governance
  - sovereign-ai
categories:
  - llmops
lang: en
canonical_url: https://thakicloud.com/tech-blog/en/llmops/the-inference-moat-was-filled/
---

The moat is no longer the inference engine. For teams running agents, this change touches the cost calculation most directly. The most concrete case this week is DeepSeek's in-house inference engine, DeepInfer. When DeepSeek open-sourced the in-house inference engine DeepInfer, the story this blog covered was a proprietary stack led by model-specific kernels. The conclusion read at first was that a moat would form. The assumption that kernels and optimizations tuned for a specific model do not spill over to external frameworks, and the proprietary serving stack built on top of it. Because the open-sourced engine was the very engine running DeepSeek's models, the story held that the more the model and engine specialized together, the harder it was for others to reproduce. This week, that conclusion changes. The open-source inference frameworks SGLang and vLLM have integrated DeepSeek's newly open-sourced kernels and optimizations. The two stacks now have complete production serving stacks that match or exceed DeepInfer's performance. The word "production" needs emphasis. It points to a level of completeness that can be stood up in a production environment. For organizations running open models on-premises, this change is direct. Until now, the serving stack was the variable that decided success or failure. Now there are options for the serving stack.

![Image visualizing the concept that the inference moat was filled](/assets/images/the-inference-moat-was-filled-hero.webp)
*Visualizes the core concept of the post.*

## What the Catch-Up Means

The fact that the two frameworks integrated the newly open-sourced kernels and reached DeepInfer's performance means the differentiation window of the proprietary stack is short. The moment an inference optimization is published, it becomes an integration target for the open frameworks. SGLang and vLLM are stacks that each know how to layer on their own optimizations. That is why the result of "matching or exceeding" is possible. A model vendor's in-house engine is now a release-speed race. An optimization published today becomes the serving performance of the open stacks tomorrow.

For DeepSeek, this is a flow of paradox. The published kernels and optimizations pull up the performance of the open stacks. The more popular the model, the more the open stacks that integrated its kernels grow with it.

What the two frameworks integrated is the newly published kernels and optimizations. This flow makes it clear that the performance-validation cycle of a private serving stack has to be kept short. Yesterday's benchmark becomes today's baseline. Stack comparison does not stay a quarterly event. It becomes a repeating task at the release unit. For organizations running open models on-premises, the axis of choice changes too. The criterion for choosing a serving stack moves from performance to operations. When choosing a stack, you first look at whether the GPU scheduling policy fits your workload. You also look at whether you can validate with the same tool chain, and whether you can upgrade without interruption. When engine differentiation disappears, what is left for the engine vendor is price and operational burden. That is where the cost competition for inference begins.

## Other Cost-Reduction Moves

The move that chips away at the engine is not isolated. In the same week, there are three more moves in the same direction. The common thread of the three moves is cost.

OpenAI's move is a dial on reasoning. OpenAI released updates to the Codex and Work tools. Through the prompt presets feature, developers can adjust the reasoning level mid-conversation without clearing the prompt context. The reasoning cache was updated along with it. The previous approach set the reasoning level from the start, per conversation. Now, within the flow of one conversation, you can add only as much reasoning as the request demands. In agent workflows, this difference is large. One workflow produces a large number of reasoning requests. If the level is fixed, trivial steps burn the same compute resources as hard steps. Prompt presets, the reasoning cache, and mid-conversation adjustment are one set. Since the context does not disappear when the level changes, there is no cost of starting over from the beginning. The moment how much reasoning to put into one request becomes a per-conversation, per-request adjustment target, cost control becomes a question of request-level policy. Which tasks get strong reasoning and which run at the default level is now a question of workflow design.

The decline in price is more direct. OpenAI won Replit's $100 million AI contract. Replit was an existing customer of the competitor, Anthropic. OpenAI won the contract with a steep price cut. Replit is reported to have shifted most of its AI spend to OpenAI. In effect, it took the front seat of the coding agent market by price. Two frontier labs compete with discounts. The customer answered by moving most of its spend. $100 million is beyond the scale of an individual developer account. It is the spend of a platform that builds and sells coding services on top of models. Look at the structure rather than the scale. For Replit, this contract is a choice that can be recalculated every quarter, because the token unit price determines the margin of the service itself. The body of agent workflow cost is model execution, that is, tokens. In an environment where vendors compete with discounts, execution cost becomes a variable outside your control. If another vendor's price drops tomorrow, the cost assumption sheet you made today becomes invalid. That price policy fluctuates means one more direct variable has been added to margin management for automated services.

The most surprising of the declines is architecture. Anthropic advised companies to remove unnecessary subagents from their AI systems and adopt a single-agent loop. It is known to be advice given after confirming the advantage of a single-agent configuration. The content of the specific advantage behind the advice is not included in this report. Even so, the direction itself is clear. Until recently, the number of subagents was a design variable. Multi-agent orchestration was treated as the answer. Now a frontier lab headquarters advises "cut down." The word "unnecessary" is the criterion. A subagent that cannot contribute becomes a removal target. From a workflow perspective, a subagent is an added approval point and an added cost point. Cutting reduces cost and complexity. The direction of the advice is on the same axis as cost reduction. Each time a subagent is added, one more loop that burns tokens is created. When agents decrease, approval points decrease too. The weight of the remaining approval points grows. When the number of agents becomes a variable that can be cut, the design question shifts to "at what level does each task run." It becomes important to decide at what autonomy and within what boundaries a task runs. The direction all three moves point to is the same. It is a week of drawing lines, one by one, across the engine, the reasoning, and the architecture where cost is spent.

## One Increase

The move in the direction opposite to the decline happens on the public side. The US Navy signed a contract with Applied Intuition to scale a maritime autonomy data engine. Applied Intuition's operational data collection and model training systems will be integrated into Navy vessels. The goal is to improve the threat-detection capability of US vessels. The more vessels the system is installed in, the larger the data loop becomes. Detection capability is the output of that loop. That the system is integrated into vessels means that data and models circulate within the fleet. It is a workload whose premise is running in an air-gapped network, within data sovereignty. It is an environment where which cloud to entrust model supply to, and where the data flows through, cannot be made subjects of debate. Defense workloads were a leading indicator of sovereignty demands. Now what the Navy demands is a data engine that turns operational data into detection capability. The contract is one that scales up. The system will expand across the entire fleet. The larger the fleet, the more urgent the air-gapped serving problem becomes. Because the fleet is an air-gapped network, a data engine that learns and circulates within the fleet is a sovereign deployment design problem from the start.

In the same period, there was also a matter about vendor transparency. A US administration official claimed that Anthropic hid information related to AI safety failures that affected official government websites. Whether the claim is true is a separate matter. What happened here is that the direction of the question changed. The question "who watches the AI that touches public infrastructure" was thrown toward the vendor side. In the context of public websites, incident transparency moves beyond the vendor's discretion. The question of who decides whether to disclose when an incident occurs enters the contract's threshold. One industry, two directions. The open side commoditizes inference. The sovereignty side strengthens execution demands. As commoditization progresses, the questions about where execution happens and what is recorded grow. When decline and increase happen at the same time, what a company must hold is judgment about the place of execution, the level, and the volume of the record.

## The Layers That Remain After the Engine Is Commoditized

When inference stacks converge, the value of the model host falls. What rises is the value of the execution intermediary. The questions the intermediary must answer are four. Which model and at which reasoning level does each task run; in an air-gapped network or an external cloud; under which policy and with which record. Those are the four. These four are the questions that run through this week's news.

Paxis is ThakiCloud's Agent-Native Cloud. It was released as a full product at v1.1. Its first-class resources are Skills, Tools, Policies, and Audit Logs. Read against this week's news, each item maps to one capability. Paxis answers the four questions as a single operational layer.

Per-task model selection is the job of CostRouter. When the price gap between stacks narrows and vendors compete with discounts, the model and reasoning-level choice at the task unit translates directly into margin. In an environment where the reasoning level is adjusted mid-conversation, the routing decision does not remain a one-time choice at the start of the conversation. It becomes a repeating decision at the task unit. In an environment where the question "who watches" is thrown toward the vendor side, the answer a company can offer is the execution record. Isolated sandbox execution, policy gates, and audit logs turn that answer into a system. Audit logs are no longer a compliance option; they are a requirement customers ask about first. When autonomy decisions are made per task, governance becomes policy items at the L0~L3 unit. The organization assigns a level to each task. The design of reducing subagents while keeping approvals at certain stages is built directly on these policy items. The sovereign, on-prem K8s deployment option answers the air-gapped requirement seen in the US Navy maritime workload. Not only in Navy vessels but in a company's data center, the same requirement arises in the same shape. MCP connectors and the skill market are devices for the era of engine replacement. Even if the serving stack below changes, the skills and tools a workflow has built up do not need to be rebuilt. Even if the inference stack changes, and even if the model changes, what the workflow must hold on to is judgment and record.

This week's news lets you read the platform's menu in advance. Cost, level, place, record. The value of the platform lies in judgment made visible. It is the point where recording which task ran at which level, under which policy, becomes the product itself.

The engine is no longer a differentiator. What remains is the judgment layer, and the place where that judgment is executed.

## References

This post was written by synthesizing the news below.

- HuggingNews, [SGLang and vLLM Match DeepSeek's DeepInfer Engine With Full Production Serving Stacks](https://huggingnews.com/ai/update-sglang-and-vllm-match-deepseeks-deepinfer-engine-with-full-produc-a1636bba)
- HuggingNews, [US Official Accuses Anthropic of Hiding AI Safety Incidents Affecting Government Websites](https://huggingnews.com/ai/update-us-official-accuses-anthropic-of-hiding-ai-safety-incidents-affec-0a295ad2)
- HuggingNews, [OpenAI Adds Prompt Presets to Codex CLI and Updates Reasoning Cache](https://huggingnews.com/ai/update-openai-adds-prompt-presets-to-codex-cli-and-updates-reasoning-cac-d8a0b87d)
- HuggingNews, [OpenAI Wins $100M Replit AI Contract From Anthropic With Steep Price Cuts](https://huggingnews.com/ai/openai-wins-100m-replit-ai-contract-from-anthropic-with-steep-price-cuts-d5483271)
- HuggingNews, [Anthropic Advises Companies to Cut AI Subagents for Single-Agent Architectures](https://huggingnews.com/ai/anthropic-advises-companies-to-cut-ai-subagents-for-single-agent-archite-7edfc6b5)
- HuggingNews, [US Navy Contracts Applied Intuition to Scale Maritime Autonomy Data Engine](https://huggingnews.com/ai/us-navy-contracts-applied-intuition-to-scale-maritime-autonomy-data-engi-5f4cdd4b)
