---
title: "The Map Where the Data Center Isn't the Center"
excerpt: "In a single day, news about space, smartphones, and low-latency accelerators all arrived together. AI compute is moving to where the agents work."
seo_title: "The AI Compute Map Moving From the Data Center to Orbit and to Your Pocket"
seo_description: "SpaceX's orbital AI compute, Xiaomi's edge accelerator, Liquid AI's mobile suite, Nvidia Groq's 3,400 tokens per second. Today's decentralization of inference, read through HuggingNews."
date: 2026-08-25
last_modified_at: 2026-08-25
author_profile: true
toc: true
toc_label: "Table of Contents"
toc_icon: "robot"
tags:
  - ai-frontier
  - llmops
  - paxis
  - thakicloud
categories:
  - news
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/news/ai-compute-map-beyond-datacenter/"
audiobook: "https://drive.google.com/file/d/1GvDjvS5SyT3nLQpazg32pg0xjtFWnFIP/view"
audiobook_label: "▶ Listen: 5-minute briefing"
audiobook_note: "NotebookLM audio overview (AI-generated)"
---

![A map where the data center is not the center: compute flowing from orbit, a smartphone, and an accelerator card into a global network of nodes](/assets/images/ai-compute-map-beyond-datacenter-hero.webp)
*A visual of the article's core concept.*

## When You Put It on a Map, the Data Center Is Not in the Middle

Lay the AI news from the last day on a map, and the data center is not in the middle. SpaceX plans to lift Nvidia's next-generation chips into orbit by the fourth quarter of 2027. Xiaomi has designed a dedicated accelerator to run large language models on smartphones and cars, and Liquid AI has shipped a suite that fits open models onto real devices. For the people building agents, and the people deciding where to deploy them, this news poses a single question. Where does the agent run? That question is no longer a deployment detail; it is now the first design decision. This article reads that map by one criterion. Where is compute going? That is a question that changes the cost and latency of inference and the location of data, all at once. A single day of news is enough to start finding the answer.

## Orbit: In 2027, Chips Run AI in Space

According to today's HuggingNews digest, SpaceX will deploy Nvidia Vera Rubin as the first orbital AI compute in the fourth quarter of 2027. The deployment is part of the partnership between SpaceX and Nvidia. Nvidia's Vera CPU will drive agentic AI applications and expand the ground infrastructure that supports the Groq model. The agent is named, from the very start, as the user of the chip.

The fourth quarter of 2027 is roughly fifteen months away. More important than the date itself is the fact that the planning horizon of the execution environment has extended out to orbit, fifteen months from now. Orbital compute still sounds like a distant future. But one thing deserves a note. "Orbit" has been legitimized as an execution environment for AI. Until now, the list of execution environments ended at data center, edge, and on-device. The constraint of partitioning is widening from "data center or not" to simply "where." Today is the day space was added to the list of places where agents work.

## Pocket: The Era When Smartphones Design Chips for LLMs

On the ground, the map is widening faster than orbit. Xiaomi announced the Xring O100. It is the first dedicated edge AI accelerator, with bandwidth of 1.22 TB/s. Using a 3D wafer-on-wafer stacking process, it makes on-device large language model inference possible on smartphones, vehicles, and robots. The process is 6nm.

I think the word "dedicated" weighs more than the numbers. Until now, smartphones ran LLMs on general-purpose chips. Now a single company is designing a chip to run LLMs in the pocket and nothing else. The same day, Liquid AI and Artificial Analysis launched Pipette, the first open mobile AI suite built around 10,000 results. In Artificial Analysis's evaluation, Nanbeige 4.2-3B and LFM2.5-2.6B tied for the top with an average intelligence score of 63 on the iPhone 17 Pro and the Galaxy S26 Ultra.

Having 10,000 results means we can now know how far mobile intelligence has come not by feel but by measurement. It is the point where models that run on devices can be compared by benchmark, just like cloud models. Small models are getting smarter. And as they get smarter, where do we run them? On the device itself. When the model is on the device, there is no need to round-trip data and no need to wait on latency. As on-device inference spreads, a partitioning problem shows up in agent workflows too. Which stage to keep on the device and which to send to the cloud is no longer a model-selection question but a workflow-design question. The pocket is becoming a full-fledged execution environment.

## Data Center: The Side Being Pushed Out, the Side in Contention

At the data center, a speed race and an equity race are happening at the same time. Nvidia has moved its low-latency inference accelerator, the Groq 3 LPX, into full mass production. In its first appearance on Nebius Cloud it recorded 3,400 tokens per second. The target workloads are coding agents and multi-step reasoning. The fastest compute is specializing in "how quickly it can return the next token in the middle of an agent's turn." Low latency has become its own product category, not an option.

The equity race moved in the same window. Nvidia is leading a Perplexity funding round at a $30 billion valuation. Talks between the two companies shifted from considering a deal that would pay out funds on the order of hundreds of millions toward a traditional equity investment. A structure in which a chip company puts equity into a model company is a signal that the terrain of inference cost is moving toward the chip side. As the boundary between chip and model is tied together by equity, the cost structure of inference is getting more complex.

Payment data is reading the same map. According to a survey by the payments data group Ramp, companies using Anthropic's tools were spending more on the cost-efficient Opus 5 than on the flagship Fable 5. Fable 5's share of spend fell to 11%. The flagship is no longer the default; it is an option chosen per workload. Model selection has become an economic decision.

At the same time, the social friction around data centers is growing. In the United States, Senator Sanders, citing 75% public support, is calling for a federal-level moratorium on the construction of new AI data centers. President Trump said that regions opposing the construction of large computing facilities are refusing "enormous jobs and money." Concentrated compute now carries the cost of power and water, and social costs are starting to appear on the price list too. The more you concentrate, the more expensive it becomes. The same data center has reached the point where its mere construction requires social consensus.

## Why the Map Changed

The common thread across the news is the agent. Training moved into data centers a few years ago. Inference is now moving to where it works, and four forces are pulling it.

First, latency. An agent calls several tools within a single turn and reads the results back. The more tool calls there are, the more wait time per turn it must absorb. In this structure, the wait to the first token is not a matter of perceived speed; it determines whether the task succeeds. That is why the Groq 3 LPX targets coding agents.

Second, the location of the data. Cars, smartphones, and robots are the context of the work itself. Round-tripping that data to a data center adds cost, latency, and regulation at the same time. That is why the Xring O100 was born "dedicated."

Third, cost. As Ramp's data shows, companies have already started choosing models per workload. They are no longer running everything on the flagship.

Fourth, the scope of the work has widened. Today's digest carried one more signal. Revent Alpöge, a mathematician affiliated with Anthropic, announced that together with Claude Opus 5 he discovered the complex structure of the six-dimensional sphere, S⁶, and that a 108-page construction was presented for a problem unsolved since 1948. More significant than the content of the discovery is the fact that an agent took part as a co-worker on frontier research. That is the point of today. If an agent's work extends to the level of frontier discovery, then the trust cost of the execution environment, namely audit, approval, and isolation, becomes a first-class cost as well.

The result is that execution environments are each different. The same agent runs under different constraints depending on the device, the region, and the regulation. One model, many environments. If the platform cannot absorb this difference, it all leaks out as application code. And that heterogeneity will clearly widen with each passing year.

## How to Read the Map

Those building agent systems can read this map as a four-item checklist. First, pull the execution environments into a list. Cloud, on-device, edge, and the new environments on the roadmap, write down every place the agent actually runs. The moment an unexpected place lands on the list, this map starts applying to your system. Second, record the constraints per environment. Latency, bandwidth, power, regulation, and where the data is attached.

Third, map the work to the environments. Some stages must attach to the device, some to a low-latency accelerator, and some remain in the data center. Today, with the intelligence of on-device models confirmed by measurement, this mapping can be pinned down with numbers rather than guesses. Fourth, draw the scope of audit. No matter where execution happens, the structure that lets execution records converge in one place has to be set first.

Teams that cannot draw these four things now will end up tearing apart application code every time a new environment is added. As the environments widen, that cost does not grow linearly but by the number of combinations. Conversely, teams that draw these four items now only need to add one line to the list each time a new environment appears.

## One Step Further: Reading This Map as Tomorrow's

Read today's signals one year ahead, and the direction is already set. The fourth-quarter 2027 orbital deployment is on the roadmap, and edge accelerators have moved from the design stage to the announcement stage. The intelligence of small models is being measured by 10,000 benchmark results, and low-latency accelerators have entered full mass production.

What matters here is not the new environment but the fact that new environments keep being added. One per year, and each with different constraints. So the organizations that treat "where" as a configuration value, and the organizations that treat it as an axis of the platform, will stand in entirely different positions two years from now. The former will tear apart application code every time; the latter only add a line to the list.

On the day the map widens, competition comes not from the side that holds the fastest chip, but from the side that governs the whole map as a single axis.

## So What Should We Build

Start by looking at what is breaking. A system premised on a single cloud no longer holds. The premise of pre-fixing the model is, as Ramp's data shows, no longer the default either. An audit trail drawn under the premise of one environment cannot hold agents that run on smartphones and the edge.

The answer is to pull the "where" axis out of deployment configuration and raise it to a first-class axis of the platform. Which environment to run in, which model to attach to that environment, what to audit after execution, and how much autonomy to grant. These four questions are no longer the work of individual applications.

ThakiCloud's Paxis is a full-fledged Agent-Native Cloud product built on the premise of this map. It treats Skills, Tools, Policies, and Audit Logs as first-class resources and grants autonomy in stages from L0 to L3. It holds execution with policy gates, records everything in audit logs, and runs inside isolated sandboxes. Per-task model selection is built in, and it supports sovereign and on-prem Kubernetes environments as well. The operating principle is "run everywhere, optimize deeply on ThakiCloud." As the spectrum of execution environments widens, the value of a platform that treats "where" as a manageable axis can only go up.

The data center will not disappear. It is simply no longer the only center. Today's smartphone, this quarter's accelerator, the orbit fifteen months from now. Every time the map is redrawn, the side that hosts the agents will ask the same question again on top of it. Where to run.

## References

This article is a synthesis of the following news.

- HuggingNews, [SpaceX Deploys Nvidia Vera Rubin for First Orbital AI Compute in Q4 2027](https://huggingnews.com/ai/spacex-deploys-nvidia-vera-rubin-for-first-orbital-ai-compute-in-q4-2027-d8263ed7)
- HuggingNews, [Nvidia Leads Perplexity Round at $30B Valuation in Pivot from Hiring Deal](https://huggingnews.com/ai/nvidia-leads-perplexity-round-at-30b-valuation-in-pivot-from-hiring-deal-5ae9eff0)
- HuggingNews, [Opus 5 Overtakes Fable 5 in Spend, Capping Flagship Share at 11% Low](https://huggingnews.com/ai/opus-5-overtakes-fable-5-in-spend-capping-flagship-share-at-11percent-lo-40e87bd8)
- HuggingNews, [Xiaomi Xring O100 Hits 1.22 TB/s Bandwidth, First Dedicated Edge AI Accelerator](https://huggingnews.com/ai/xiaomi-xring-o100-hits-122-tbs-bandwidth-first-dedicated-edge-ai-acceler-d9b6c186)
- HuggingNews, [Alpöge Claims Claude AI Solves 6 Sphere Problem Open Since 1948](https://huggingnews.com/ai/alpoge-claims-claude-ai-solves-6-sphere-problem-open-since-1948-f240944d)
- HuggingNews, [Nvidia Groq 3 LPX Hits 3,400 Tokens Per Second in Nebius Cloud Debut](https://huggingnews.com/ai/nvidia-groq-3-lpx-hits-3400-tokens-per-second-in-nebius-cloud-debut-9615e020)
- HuggingNews, [Trump Calls Rejection of AI Data Centers a Mistake in Race to Beat China](https://huggingnews.com/ai/update-trump-calls-rejection-of-ai-data-centers-a-mistake-in-race-to-bea-b27d1a42)
- HuggingNews, [Sanders Demands AI Data Center Moratorium With 75% US Support](https://huggingnews.com/ai/update-sanders-demands-ai-data-center-moratorium-with-75percent-us-suppo-07da6586)
- HuggingNews, [Liquid AI and Artificial Analysis Launch Pipette With 10,000 Results as First Open Mobile AI Suite](https://huggingnews.com/ai/liquid-ai-and-artificial-analysis-launch-pipette-with-10000-results-as-f-d1363ee4)
