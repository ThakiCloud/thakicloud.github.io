---
title: "Where Does an Agent That Lives for Seven Days Keep Its Memory?"
excerpt: "Google gave agents a seven-day runtime and a memory bank, and SK hynix unveiled the first standard for a new memory tier to hold that memory. Two announcements arriving on the same day point to a single question."
seo_title: "The Agent Memory War: Why Google's Seven-Day Runtime and SK hynix's HBF Arrived on the Same Day"
seo_description: "Reading Google's Gemini Enterprise Agent Platform GA together with SK hynix's HBF standard announcement. As agents start living longer, where to place their memory has become a question of cost and sovereignty."
date: 2026-08-12
last_modified_at: 2026-08-12
author_profile: true
toc: true
toc_label: "Table of Contents"
toc_icon: "robot"
tags:
  - agentops
  - paxis
  - enterprise-ai
  - thakicloud
categories:
  - agentops
lang: en
canonical_url: https://thakicloud.com/tech-blog/en/agentops/where-does-a-seven-day-agent-keep-its-memory/
---

![Conceptual image representing where an agent that lives for seven days keeps its memory](/assets/images/where-does-a-seven-day-agent-keep-its-memory-hero.webp)
*A conceptual illustration of the article's core idea.*

## Two Announcements, from Two Different Layers, Arrived With the Same Idea

This morning's digest carried two announcements side by side that seem to have nothing to do with each other.

One is from Google Cloud. In launching the Gemini Enterprise Agent Platform generally, it gave agents three things: a SPIFFE-based unique identity, an uninterrupted runtime of up to seven days, and a long-term memory store called Memory Bank. The other is news from the Seoul Economic Daily about SK hynix. Together with SanDisk, it unveiled the first standard specification for HBF, saying it would build a new memory tier that is NAND-based, reaches up to 3.0TB/s of bandwidth, and offers eight to sixteen times the capacity of DRAM. The industry pointed to the exploding key-value cache in AI inference as the reason for rushing the standard.

One is a software API, the other is silicon. But the two announcements solve the same problem. Agents have started living longer, and a long-lived process has memory. That memory has to be stored somewhere, and right now that place is brutally expensive.

## Why Memory Suddenly Got Expensive

Until last year, what a company bought was a response. You sent a question, an answer came back, and the session ended there. A conversation that ends does not need memory. Context could simply be refilled every time.

What a company buys now is execution. Cases from the domestic food and dining industry reported by Consumer Times show how physically this shift has already unfolded. Dongwon Group has begun assigning actual employee numbers to dedicated AI at each affiliate and managing them by class year. Dining Brands Group spent six months building its own integrated platform and deployed function-specific agents for HR, personal data, marketing, and IT all at once. Samyang Group ran a 100-day challenge in which frontline staff built their own AI modules directly. And the fact that a K-Food Smart Manufacturing Alliance involving 15 food companies has launched shows this trend has already moved beyond individual companies' experiments.

An entity with an employee number needs to remember tomorrow what it did today. If it is interrupted while reviewing a document, it needs to remember where it left off, and if it is continuing a regulatory analysis, it needs to be able to cite which clauses it excluded last week and why. Google extending the runtime to seven days is not a performance flex, it is a response to this requirement. And if hundreds of processes stay alive for seven days at once, you cannot put all of that state on HBM. The tier SK hynix is trying to build sits exactly in that gap, the idea of putting large-capacity cache close to the GPU at a per-bit cost far cheaper than HBM.

The same shift is observable at the national level too. Looking at the second-round evaluation criteria for the sovereign foundation model program, as compiled by Chosun Biz, the first round looked at the technical maturity of the model itself and whether it was developed independently, while this round has put agent competence in performing actual work and applicability to industrial settings at the center of evaluation. In a structure where only two of the four teams, LG AI Research, Upstage, SK Telecom, and Motif Technologies, will survive to the final round, the weight of the review has shifted from benchmark scores to execution ability. When even government budget selection criteria have turned execution-oriented, the infrastructure requirements underneath shift with it.

That said, the timing gap should be looked at honestly. Google's seven-day runtime is a product you can use today, while HBF-based SSD mass production is slated for 2027 or later. SK hynix also unveiled a 375-layer 4D NAND prototype at the same announcement and committed 19.1 trillion won to its Cheongju M17 fab, so the direction is clear, but it will take time before that volume is actually racked into servers. Until the hardware arrives, closing that gap is software's job. The layer that decides which state to keep in GPU memory, which state to let go of, and what to recompute on resume is what will determine cost for the next several years.

## Memory Comes With Access Rights Attached

Here another layer of the problem appears. Memory is data, and data has access permissions.

A security-focused feature compiled by Datanet addresses this directly. Because existing zero-trust and IAM systems were designed with humans in mind, they cannot control what an agent does the moment it acts. The article's summary is that we need to move from after-the-fact audit to pre-execution control, and the Gartner numbers cited as evidence are stark: 56% of non-human identities sit outside governance, and 67% of organizations that have adopted agents have already experienced access that exceeded scope. Palo Alto Networks, Netskope, Okta, and Korea's SoftCamp are all releasing agent-specific identity products, and the FIDO Alliance and IETF have begun standardization work.

The number Google cited in its own announcement points the same way. In an OutSystems survey of 1,900 IT leaders, 96% of companies said they already run AI agents in production, but only 12% said they could actually control them. This 84-point gap is the real driver behind each cloud provider rushing to turn identity, runtime, and memory tiers into formal products. AWS pushed Bedrock AgentCore into production, Microsoft attached a control panel called Agent 365 to Azure AI Foundry, and Salesforce brought back Agent Fabric.

Giving memory means giving permission. An agent that remembers last week's conversation also means it can access the table it looked up last week. When a person leaves a company, their account is deactivated along with the offboarding process, but for an agent with an employee number, nothing resembling an offboarding process exists yet. That is exactly why Dongwon Group's class-year system is both an interesting experiment and a new problem. If you make a seat on the org chart, you also need to design how to vacate that seat.

This surfaces one risk in how domestic adoption is happening. The three companies introduced today each took a different path: in-house development with a partner, integration with an external data platform, and an internal hackathon. Speed was high, but the room for identity systems and security policy to diverge across affiliates is large. Audit blind spots usually do not arise because a system is missing, they arise when different systems each keep their own logs.

## Which Makes the Location of Memory a Sovereignty Question

If memory is data, then which storage in which jurisdiction holds that data immediately becomes a regulatory question.

A discussion at major domestic hospitals, reported by MedigateNews, shows this problem most clearly. Seoul National University Hospital's K-MED.ai and Samsung Medical Center's ZEO Med 2 have achieved world-class performance on the medical licensing exam benchmark. But at the same event, what Seoul National University Hospital cited as the limiting factor for adoption was not model quality, it was a shortage of GPUs. If an agent handles medical-record automation or reading assistance, patient data ends up in that agent's memory. That is data that cannot leave the hospital's closed network. This is exactly why it is hard to simply use a hyperscaler's fully managed memory service as is.

The definition offered by Red Hat, as reported by IT Daily, fits this situation well: sovereign AI is not about where a data center is physically located, but about who controls the infrastructure and the data. The figure Red Hat cited as evidence, a twelve-to-eighteen-month wait in the GPU supply chain, makes the point that vendor lock-in is a business-continuity risk, not just a cost issue.

There is another direction for splitting memory in today's signals too. On-device LLM competition, reported by Digital Today, is one example. As Meta and Nvidia release roughly 30-billion-parameter models under open licenses, lightweight models that run on personal PCs have become a new battleground, and LG Electronics is putting its own sLM into the 2026 Gram lineup to handle document summarization and translation offline, without a network. This path, where sensitive data never has to leave the device, is especially attractive in regulated industries. If light judgments end on the device and only heavy inference goes up to the cloud, the sheer volume of memory left in the cloud shrinks. Leaving less behind is itself one answer to the question of where to keep memory.

The shortage of places to run execution is confirmed by domestic indicators too. According to Prime Economy, NHN Cloud's cloud-segment revenue grew 85.3% year over year on the back of its Yangpyeong data center coming online and B200-based GPUaaS supply. Domestic data-center power demand is projected to rise from 4,461MW in 2025 to 6,175MW in 2028, and much of the supply due in 2027 and 2028 already has tenants lined up. A structure where demand outruns supply is becoming entrenched.

## Whoever Can Choose Their Memory Tier Has the Advantage

To sum up, today's signal is this: agents have started living longer, and living longer means having memory, and that memory is expensive, regulated, and hard to move. Hyperscalers have begun selling this layer as a fully managed product, and the semiconductor camp is preparing a cheaper storage tier for 2027 and beyond. In between, what a company actually has to decide is simple: where to put our agent's memory.

This is exactly why ThakiCloud made Skills, Tools, Policies, and Audit Logs first-class resources when building Paxis. If an agent's memory and permissions are hidden inside application code, they cannot be audited or migrated. Which skill can call which tool, and which policy gate that call passed through, needs to exist as something queryable, so that when a regulator eventually asks, you can answer without re-reading the code. The autonomy tiers from L0 to L3 and running execution in an isolated sandbox are mechanisms that let a human redefine, each time, how much to allow an agent with an employee number to do. That also means the point where you attach approval and the point where you remove it need to be set differently for each workflow.

In places like hospitals and finance where an air-gapped network is a given, the same skills and policies need to be deployable, unchanged, on on-premises Kubernetes. If data cannot leave, memory cannot leave either, and if memory cannot leave, the execution layer that handles that memory has to come along with it. In a period of GPU scarcity, the ability to swap models per task becomes a real cost defense line. Routing that does not call the top-tier model for a one-line summary, and reserves expensive inference only for steps that actually require judgment, increases throughput on the same capacity. When you cannot add capacity, the lever left is execution efficiency.

A platform that cannot choose where to keep its memory ends up following the policy of wherever it entrusted that memory to. What today's two announcements together tell us is that this choice has just opened up.

## References

This article was written by synthesizing the following news sources.

- Global Economic, [Taiwan's SPIL Breaks Ground on Next-Generation CoWoS Fab 2 With $3.1 Billion Investment](https://www.g-enews.com/view.php?ud=202608120735179952fbbec65dfb_1)
- Inews24, [China's CXMT Chases 10% Market Share, Samsung and SK Rush Tens of Trillions of Won in Expansion](http://www.inews24.com/view/1994060)
- Seoul Economic Daily, [SK hynix Ramps China NAND Output 50%, Targets No. 1 in HBF Beyond Commodity Memory](https://www.sedaily.com/article/20078296?ref=naver)
- Singlist, [Coreweave and Supermicro Beat Earnings Expectations, AI Infrastructure Investment Heat Continues](https://www.slist.kr/news/articleView.html?idxno=758174)
- Prime Economy, [NHN Benefits From Domestic AI Data Center Supply Shortage, Pivots Fully Into AI Infrastructure](http://www.newsprime.co.kr/news/article.html?no=743548)
- TechM, [Racking GPUs and Building Distribution: Domestic AI Market Grows Larger](https://www.techm.kr/news/articleView.html?idxno=154203)
- Electronic Times, [Nvidia to Launch Its Own AI Model, Preparing a Trillion-Parameter Model as Well](https://www.etnews.com/20260812000001)
- Digital Today, [Evolution of LLMs Installed on PCs Accelerates, Becoming a New Battleground for AI](https://www.digitaltoday.co.kr/news/articleView.html?idxno=692211)
- Yonhap News, [Big Tech Races Into the Domestic AI Market, ChatGPT and Gemini Take First and Second in Usage Experience](https://www.yna.co.kr/view/AKR20260811150100017?input=1195m)
- Google Cloud Blog, [Google Launches Gemini Enterprise Agent Platform GA With Agent Identity, Runtime, and Memory Bank](https://cloud.google.com/blog/products/ai-machine-learning/whats-new-in-gemini-enterprise-agent-platform)
- Consumer Times, [Beyond Chatbots to "AI Employees": Food and Dining Industry Speeds Up Work Automation](https://www.cstimes.com/news/articleView.html?idxno=716436)
- IT Chosun, [The Three Telecom Carriers Bet Everything on "AI for Everyone," Mobilizing Full Group Resources](https://it.chosun.com/news/articleView.html?idxno=2023092167871)
- MedigateNews, ["What Has Changed at Hospitals Since Adopting Medical AI": Discussion on Building In-House Hospital LLMs](https://www.medigatenews.com/news/1543492801)
- News1, [Exclusive: Government to Start Collecting Factory Manufacturing Data From August, First Step for Physical AI Foundation Model](https://www.news1.kr/it-science/internet-platform/6255855)
- IT Daily, ["Must Secure Control Over AI Technology": Open-Source-Based "Sovereign AI" Proposed as the Answer](https://www.itdaily.kr/news/articleView.html?idxno=240931)
- Chosun Biz, ["Only 3 of 4 Teams Survive": Dissecting the Four AI Models Ahead of the Sovereign Foundation Model Second-Round Evaluation](https://biz.chosun.com/it-science/ict/2026/08/12/XJU7Z6VLQBHKFNUOFVNBZBS4VA/)
- The Elec, [Nvidia Raises 710 Trillion Won in Funding Needed for Wall Street and AI Customers](https://www.thelec.kr/news/articleView.html?idxno=60820)
- Datanet, [AI Agent Security Part 2: Agent Identity and Access Management Is Essential](https://www.datanet.co.kr/news/articleView.html?idxno=213706)
