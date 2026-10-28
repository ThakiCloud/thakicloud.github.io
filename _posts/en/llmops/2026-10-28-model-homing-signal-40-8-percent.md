---
title: "The 40.8% Homing Signal: You Can Bring the Model Home, but It Still Has a Home to Return To"
excerpt: "In a 10,000-sample local experiment, the model chose the vendor's cloud domain in 40.8% of its runs. Self-hosting secures only half of sovereignty."
seo_title: "The 40.8% Homing Signal: You Can Bring the Model Home, but It Still Has a Home to Return To"
seo_description: "In a 10,000-sample local reproduction of Cohere's prefill experiment, Qwen3.8-Flash-Next selected the aliyuncs.com domain in 40.8% of runs. Sovereignty beyond the server, and the policy axes that the routing table should add."
date: 2026-10-28
last_modified_at: 2026-10-28
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "robot"
tags:
  - open-models
  - model-governance
  - sovereign-ai
  - on-prem-inference
  - multi-model-routing
  - ai-trust
categories:
  - llmops
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/model-homing-signal-40-8-percent/"
---

![Image visualizing the concept of the 40.8% homing signal: bring the model home, and it still has a home to return to](/assets/images/model-homing-signal-40-8-percent-hero.webp)
*A visualization of the core concept of this post.*

## A Number Worth Reading Twice

Today's morning digest held one number that deserves to be read twice. In a 10,000-sample experiment reproduced locally, the model chose the domain of the cloud it was born in during 40.8% of its runs. The study re-runs Cohere's prefill experiment at a 10,000-sample scale in a local environment, and the model under test is Alibaba's Qwen3.8-Flash-Next. That it is a local reproduction matters. In the hands of a third party, it rechecked what values the model surfaces. Reading the output, the model picked the aliyuncs.com domain in 40.8% of the runs. aliyuncs.com is Alibaba Cloud's domain. More than four times out of ten, even in a local experiment that is not on top of the vendor's cloud, the model pointed at "home."

Why does domain selection matter? A domain is not decoration. It is a marker for where the service, the data, and the traffic flow. The moment a model's output points at a specific cloud domain, the next step becomes an instruction to go outside, to a place I did not choose. If an endpoint repeats in the output, the call will soon head toward that endpoint. A latent route for the flow of information has been born inside the model's sentences.

This is a reproduction study from a single source. For the detailed subcategories of the ratio, you need to check the original. It is wrong to make a definitive claim from a single experiment. But the direction the signal points to, the other articles in today's digest have already demonstrated. This is not a question of whether the model is fast or cheap. It is a question of where you want the model's output to go. Deploying a model is also deploying the habits that come with it. The 40.8% homing is the first quantitative hint of that inheritance. The number itself does not move the industry. It is the direction that number points to that moves it.

## Bring the Model In, and It Is Not Home

There was one premise behind the rise of open models. The belief that if you host the model in your own data center, the data stays, the compute stays, and the sovereignty stays. The server, the network, the storage: all of it under my control. Today's experiment points at a fourth element that cannot be controlled. It is the model's "pronunciation" buried in the parameters.

A model is not just a pile of weights. It is a memory of the ecosystem it was trained in. Documents, SDKs, examples, and domains repeated beyond count: all of it goes into the model's intuition. It is the cruel trace of where the training happened. And this pronunciation is hard to erase. Fine-tuning does not wipe out the whole habit. Even in a local environment, Qwen3.8-Flash-Next pointed at aliyuncs.com. The server is mine, but the sense of direction is the vendor's. In the language of deployment, the location of the compute and the destination of the output have been separated.

For an organization that uses open models, one practical implication arises. The due diligence of model selection has grown one notch bigger. It is no longer enough to ask which model it is. You must ask in what ecosystem the model was trained, and in which direction it tilts the output. The question is concrete. Which domain does this model's output repeatedly point at, and which vendor's terminology has hardened as the default? Today's study counted the first of these with 10,000 samples.

This signal grows in importance as the placement of compute keeps moving "closer." This week, Recursive published code and a demo that run an eight-agent research swarm on a single 48GB M4 Pro Mac. Multiple agents share a single instance of a 40B-scale model and work within the same machine. Liquid AI released LFM3, its newest generation of small foundation models, designed to deliver specialized AI directly at the edge. Small models are moving into devices where data never leaves. As of October 27, Oracle opened general availability (GA) of NVIDIA Vera Rubin NVL72 systems and standalone Vera CPUs in its cloud infrastructure. The positioning was explicit. It was to enable OpenAI's AI agent production. Local, edge, on-premises. Agent workloads are moving next to the data. And what is moving is only the workloads. One laptop and one device are beginning to hold capabilities that were once cluster-exclusive.

The closer you place the model to the data, the more you need to know what it will send out. Sovereignty was originally a question of where the data stays. Now it has become a question of where the output points. In environments where the data never leaves the facility, like edge or on-premises, this question becomes sharper. If the data is locked inside but the output points outside, sovereignty is only half.

## The Fourth Axis of Routing

Where is the traffic actually going? Anthropic's daily token throughput on the aggregator OpenRouter reached 2.2 trillion after the new model launch. Since the end of September, the volume processed has grown nearly four-fold. If agent traffic is the main driver of the surge, it means serving cost management is no longer a luxury. In a market where token volume grows several-fold in a single month, one natural answer comes to mind: multi-model routing. Use a different model per workload, and route by cost, latency, and capability.

The existing routing axes were three: cost, latency, capability. Today's Qwen3.8 experiment says to add a fourth: where the output points. If you put a model with a 40.8% home bias into production routing, more than four out of ten workloads point at a domain I did not choose. A decision made by cost and latency alone cannot see this. Cost and latency are contracted values. Domain preference is an uncontracted value. The former is managed by SLOs, the latter is not on any ledger today. A value not on the ledger is not a cost. It is an incident. The responsibility lies with the side that put that model into production.

This axis is not a value you set once and are done with. There are two reasons. First, the home bias can change every time the model version changes. Whether today's 40.8% will become 30% or 60% in the next update is unknown without re-measurement. A model update should be re-inspected. Second, on top of the aggregator, the model mix of the traffic changes out of the user's sight. On the plane where 2.2 trillion tokens flow a day, the only one who knows how much the home bias of the whole mix is is the aggregator.

In the end, routing policy widens from "a fast and cheap model" to "a model that points where it should." One line is added to the routing table. It is a ban list that says this domain must not appear in the output of this workload. It is about raising the eval and monitoring that check whether a specific external cloud domain is mixed into the output from "a nice item to handle after release" to "a prerequisite before release."

## The Demanded Proof

On the same day, a story about the verifiability of output also came out. The Advisory Group on Mathematics and AI demanded that OpenAI immediately release the natural language versions and Lean formalizations of the Yang-Mills and QCD proofs. It is a question of whether the outside can independently verify the held-back outputs of frontier models.

Proof occupies a special position among AI outputs. In principle, it is the only domain where a machine can check everything. A natural language proof is something that is read, a Lean formalization is something that is verified. The advisory group demanded both together because it is a request to move the proof spoken by the model from the stage where a human reads it and it ends, to the stage where a machine checks it. But we should note that even the scope of that disclosure began with "hold." The model vendor first draws the line between what is disclosed and what is not said, and then it is demanded that the outside committee redraw that line. A world where the boundaries of outputs are drawn from the outside has arrived.

Translated to the enterprise agent field, it goes like this. The output of an agent that moves money, changes systems, and writes code must be able to answer who executed it, what it decided, what the basis is, and where it pointed. If we are at a point where even the credibility of mathematical proofs is subject to external audit, the answer to that question becomes a requirement for trust.

## Three Things to Check This Week

If you are a practitioner, you can turn today's signal into three checks. All three are things to do at the point of adoption.

First, before introducing an open model, run an eval that measures how the output points at external domains. It is just, like today's study, sampling and counting the domain choices in the output. It is a check where will comes before tools. If you know the value before registration, you get the starting point for routing and isolation policy. The criterion of putting it on a free path if the value is low and restricting it to an isolated path if high is also decided right here.

Second, define a model version update as a "re-inspection." Bias is not a fixed constant. It is a value that can change the destination of the output in every update. The era where patch notes only talk about performance is over.

Third, leave the agent output in a state where it can be reconfirmed. Along with the basis of the decision, what external instructions the output contained is also a record target. If there is a record, reconfirmation is possible, and only if reconfirmation is possible is trust possible. A day may come when an audit committee demands this record.

## Sovereignty Is Not the Server, It Is Policy

If you gather today's morning signals, the industry's pain takes on one shape. Open models are served on-premises, agents run on a single Mac or at the edge, traffic explodes at the aggregator, and an outside committee demands the disclosure of outputs. Serving, execution, cost, verification: a wave pushing in from four directions at once. And the pain of all four points in the same direction. The model is getting closer, the control mechanisms remain where they are. The Qwen3.8 experiment is a small crack that formed in that wall. Bring the model home, and it still remembers its own home, dimly.

The answer to this crack is not a bigger server. It is a rulebook that governs the model's behavior. ThakiCloud's Agent-Native Cloud, Paxis (v1.1 GA), is infrastructure where this rulebook becomes a first-class resource. In Paxis, Skills, Tools, Policies, and Audit Logs are managed as resources together with the model. Autonomy is graded from L0 to L3, controlled by policy gates, and every decision is recorded in the audit log. Agents run in isolated sandboxes, and per-task model selection (CostRouter) determines which model handles which work. In sovereign/on-premises K8s environments, MCP connectors and the skill marketplace bring external capability in under policy.

The 40.8% homing signal is not a defect of Qwen3.8. It is a preview of the behavior any model would show if placed in an ungoverned environment. If you are bringing the model home, what to prepare is not only the server. It is a rulebook that determines where it can point.

## References

This post was written by synthesizing the following news.

- HuggingNews, [Qwen3.8 Picks Alibaba Cloud Domains in 40.8% of Runs in 10,000 Sample Reproduction of Cohere Test](https://huggingnews.com/ai/qwen38-picks-alibaba-cloud-domains-in-408percent-of-runs-in-10000-sample-5f23665f)
- HuggingNews, [Math Advisory Group Demands OpenAI Release Withheld Yang-Mills and QCD Proofs](https://huggingnews.com/ai/update-math-advisory-group-demands-openai-release-withheld-yang-mills-an-2195ff93)
- HuggingNews, [Oracle Cloud Launches New Nvidia Vera CPUs to Enable OpenAI AI Agent Production](https://huggingnews.com/ai/oracle-cloud-launches-new-nvidia-vera-cpus-to-enable-openai-ai-agent-pro-d905ef76)
- HuggingNews, [Recursive Runs Eight Agent AI Research Swarm on a Single 48GB Mac With Flint Model](https://huggingnews.com/ai/update-recursive-runs-eight-agent-ai-research-swarm-on-a-single-48gb-mac-8485a21f)
- HuggingNews, [Liquid AI Launches LFM3 Foundation Models for Specialized Edge AI](https://huggingnews.com/ai/liquid-ai-launches-lfm3-foundation-models-for-specialized-edge-ai-a5e24a7e)
- HuggingNews, [Anthropic's Daily Token Usage Hits 2.2 Trillion on OpenRouter Following New Model Launches](https://huggingnews.com/ai/anthropics-daily-token-usage-hits-22-trillion-on-openrouter-following-ne-00d4bc84)
