---
title: "Ports are at 88%, construction at stage 1 to 2. The difference was not the AI"
excerpt: "In the same country, the same AI ran at two speeds. Ports went deep because work never breaks; construction stayed shallow because work resets with every project. Data center and rack-scale benchmarks are shifting to the same standard. I read today's news through the lens of continuity."
seo_title: "Ports at 88%, construction at stage 1 to 2: the variable that sets AI depth | ThakiCloud"
seo_description: "IT Chosun's analysis of China's AX, Equinix's 'connect' strategy, and 'effective performance' benchmarks for the agentic era. The common variable the three articles point to is the continuity of work state. I lay out Korea's industry-by-industry minimum DX requirements and AX permission levels, and reread them from an agent's perspective."
date: 2026-09-02
last_modified_at: 2026-09-02
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "robot"
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/agentops/port-88-construction-stage-1/"
tags:
  - ai-transformation
  - agentic-ai
  - enterprise-ai
  - ai-infrastructure
  - ai-governance
  - china-tech
  - paxis
categories:
  - agentops
---

Today's digest includes one piece of analysis that is hard to feel as AI news on first read: an IT Chosun article on China's industrial AI transformation, AX. It starts from a number. Tianjin Port's automation rate is 88 percent. Through PortGPT, driverless transport vehicles, and a digital twin, it has reached stage 3, and the closed areas now handling autonomous transport and full scheduling optimization are already into the early stage 4. What about construction in the same country? The design and safety management of large projects sit at stage 1 to 2, and even in 2026 it is pairing "AI by BIM 2.0" with systematic digitalization. Same AI, two speeds.

The "stage" the article uses is a scale that distinguishes how far AI has entered each industry, by the range over which data stays connected. A port, where the work space is closed and records run across one full lifecycle, is rated high; construction, where the owner, design, construction, and operation hands change project by project and data breaks, stays low.

The usual AX debate was about order. Which industry opens first and which follows later. But the article's answer is different. The speed of AX is set along the path where data flows. When the same work state carries across time and across organizations, AX goes deep. That is the article's core. The variable that separates depth is "does the work continue?"

This variable does not apply to a single Chinese industry. In today's digest the same sentence recurs at the building scale and at the rack scale. It is rare for three articles to speak with one voice. Today is such a day.

![Port is at 88%, construction at stage 1 to 2. The difference was not the AI](/assets/images/port-88-construction-stage-1-hero.webp)
*An image that visualizes the article's core concept.*

## When work continues, AI goes deep

The article lays out four conditions that separate the faster industries from the slower ones: the closedness of the work space, real-time identification of assets and cargo, lifecycle records that run from planning to execution, and the connection of data, permissions, and responsibility across companies and institutions.

The port is the case that meets all four. The work space is closed, equipment and cargo are identified in real time, and planning and execution records run as one lifecycle. So ordering, inventory, transport, and settlement are connected within a single platform, and JD Logistics, SF Holding, and Cainiao have reached stage 2 to 3. The article reports that Tianjin Port, backed by DeepSeek's and Huawei's AI, shows the argument most clearly.

Construction is close to lacking all four. The owner changes per project, and so do the designer, the contractor, and the operator. Data does not carry after completion, and the next project starts from zero again. That is the diagnosis of why large projects' design and safety management stay at stage 1 to 2. Aviation and space are a different kind of slow, kept human-in-the-loop for critical decisions because of airworthiness and safety responsibility. China Eastern Airlines handles travel work conversationally with Alibaba's Tongyi Qianwen and has built a 200,000-item specialized dataset that includes the C919. Agriculture is on a lower starting line. China has set a target of over 32 percent informatization of agricultural production by 2028.

Read again and the conclusion is one. AI goes deep in industries where the work state can continue. Where work breaks, no model can get past the level of a chatbot.

## At the building scale, the decisive point is "the place that does not break"

Chosun Ilbo compared the data center race to a "hub airport." The meaning is that the relay point connecting enterprises and the cloud is the decisive point. In the AI era, a data center's competitiveness is separated by "connection." The contrast is clear. Hyperscalers such as Amazon Web Services, AWS, build ultra-large data centers from hundreds of MW to the gigawatt, GW, range, in a structure where one large customer uses it almost exclusively. Equinix goes the opposite way. It builds small data centers where dozens, up to around 70, customer companies move into one building, and ties them closely with fiber, a strategy that adds interconnection to colocation.

Why did connection become the decisive point? Because companies started splitting work. Sensitive data stays on in-house servers, GPU computation is handed to external specialized infrastructure, and existing services remain on the public cloud. It is the fabric-like interconnection service that links this heterogeneous infrastructure without latency that became the key to clearing the bottleneck. Behind it is power, the largest obstacle. According to the IEA, global data center power consumption rises from about 415 TWh in 2024 to about 945 TWh in 2030, more than double, and data centers are projected to take up nearly half of the United States' incremental power demand by 2030. 71 percent of Americans oppose building a local data center over noise and emissions. In a world where building one giant facility is getting harder, the side that connects many things without breaking wins. Equinix opening its first "Horizon" event in San Francisco this year, with AI infrastructure, connectivity, and data center operations as the main agenda, is the same current. At the building scale too, value attaches to the place that does not break.

## At the rack scale, the scoreboard has changed

According to an IT Chosun tech report, the standard for measuring infrastructure performance itself is moving. The clue is Intel's agentic inference measurement. In a single request the CPU took up less than 1 percent of the total latency. But when concurrent sessions rose to 32, the CPU share climbed to 11 to 15 percent, and 94 percent of that was spent on scheduling and the task queue. What does not look important on a spec sheet becomes the bottleneck once it actually starts running in parallel. Agent workloads have this structure to begin with, because they call tools, reach external data, keep sessions long, and run several at the same time. So the center of gravity of AI infrastructure is moving from a GPU-centric generative structure to a mix of CPUs and heterogeneous accelerators that fits the inference and agentic era, and Intel, AMD, and NVIDIA are all entering the race with CPU rack-scale solutions for agentic AI. Intel's next-generation Diamond Rapids integrates 256 P-cores into a single processor with UCIe-S, AMD's sixth-generation EPYC targets the high-density CPU market, and NVIDIA enters with the Vera CPU. Market reports keep saying the CPU revival led by agentic AI and the entry of Qualcomm and ARM agentic-specialized data center CPUs. It is a record that the CPU competition is expanding from a single semiconductor to full-stack system competition at the rack unit.

The concept of "effective performance" is, in the end, telling the same story. Instead of theoretical peak performance such as core count or maximum FLOPS, the standard becomes the practical throughput that can actually be secured in a real service environment, and it is computed by taking the end user's latency target as the reference point and multiplying in routing efficiency, resource balance, and offload efficiency. Intel's and SAP's research gives a number on the memory side. A system combining DDR5 with a CXL memory expansion card keeps 96 percent of the performance of pure DDR5 while cutting TCO by about 25 percent. A memory strategy that is specific to agentic AI. It is the same message the port and the building were giving. The peak on a spec sheet and the throughput delivered in real operation are different things.

Lay the three articles side by side and today's morning news has one common word. Connect, carry, effective. The value of AI is moving to where it actually continues. And the place that common word points to is, in the end, the enterprise's operating floor.

## Korea's starting line is "how far can we hand over work authority"

The implication IT Chosun's analysis leaves for Korea is concrete. More than declaring AX, the key is setting each industry's starting line, that is, its digital debt. How far should manufacturing's sensors, MES, and quality data go? How far should healthcare's electronic medical records and clinical terminology, construction's BIM, processes, and costs, and logistics' ordering, inventory, transport, and identification systems be in place? Once those answers come out, we can set how much "write permission" to give the AI, that is, the minimum DX requirements and the AX permission levels together.

The recommended direction is clear too. Rather than each ministry building a general-purpose LLM, build a common gateway that safely connects multiple models, an industrial data space, and an evaluation and audit system. And open permissions step by step. Start with low-risk search and prediction, then system calls, human approval, and limited autonomous operation, in that order. Local governments should take on proof-of-pilot fields for their regional main industries rather than general-purpose AI centers. Ulsan takes on shipbuilding and automobiles, Busan takes on ports and logistics, and Daegu takes on healthcare. For small and medium businesses, what is needed is not an AI voucher but a common platform that bundles standard ERP and MES, APIs, and data cleanup. Banks' and investors' review criteria should also move from "the AI story" to data standardization rate, API connectivity scope, exception handling, and payback capacity. Of that list, the one that especially catches the eye is exception handling. It is the item that asks who catches a broken path and with what record. In other words, "does the work continue?" is also the first question of Korea's AX.

## Rereading the four conditions in the language of agents

Translated into the language of agents, the four conditions are the very "conditions for giving work authority to the AI." Lifecycle records that are continuous across one life are the work of leaving behind who handled what, in what order, with what result. The connection of data, permissions, and responsibility is the question of who can reach which system under which policy. And stepwise permission opening is the standard that draws the line between where to leave the agent alone and where to attach a human. These three are not features of a particular piece of software. They are the foundation of the execution environment.

ThakiCloud's Paxis is the formal product of the Agent-Native Cloud, v1.1 GA, and it treats that foundation by handling Skills, Tools, Policies, and Audit Logs as first-class resources. Autonomy runs under L0 to L3 governance, where policy writes "how far to leave it alone." The policy gate stands in front of execution, and the audit log leaves records that can be brought to a board. Execution happens inside an isolated sandbox, work connects to external systems and to other agents through MCP connectors and the skill marketplace, and CostRouter picks a model per task so that the "effective performance" of the rack section does not break in the cost section. For companies that must keep the execution environment on their own territory, there is the sovereign, on-premises K8s environment ai-platform. When Korea's construction climbs to the next stage, what it needs is not a model. It is the layer that carries the work state across time and across organizations. Before asking "how much better can we make our industry's AI?", the start is to ask "how far along the four conditions are we?"

The port went to 88 percent because the work did not break. The place where AI goes deep is, in the end, the place where that continuity is secured.

## References

This article was written by combining the news below.

- IT Chosun, [Ports are fast, construction is slow... the four conditions that separate China's AX](https://it.chosun.com/news/articleView.html?idxno=2023092168303)
- Chosun Ilbo, [The "hub airport" that connects companies and the cloud... "In the AI era, the data center decisive point is ...](https://www.chosun.com/economy/tech_it/2026-09-02/VRBBW2K6RZERBKOL263PEFBC4M/?utm_source=naver&utm_medium=referral&utm_campaign=naver-news)
- IT Chosun, [The agentic era, the new standard for infrastructure performance, "effective performance" [Tech Report]](https://it.chosun.com/news/articleView.html?idxno=2023092169269)
