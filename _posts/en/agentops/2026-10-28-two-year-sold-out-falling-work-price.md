---
title: "Two Years Sold Out, but the Price of Work Is Falling"
excerpt: "At the same conference, OCI's two-year compute sellout and a cheap CPU agent sandbox appeared side by side. The price of capability is locked in by 10-year contracts, while the price of work fragments into token-level metering. The place where the two ledgers cross is the execution environment."
seo_title: "Oracle's Two-Year Sellout and the Vera CPU Sandbox: When the Capability Ledger and the Work Ledger Crossed | ThakiCloud Tech Blog"
seo_description: "Big Tech's $1.2T AI capex, Samsung's 10-year memory contracts, Naver's 12-trillion-won AI factory, KT's token metering. Two pricing systems, the price of capability and the price of work, are diverging, and the execution layer is where they cross."
date: 2026-10-28
last_modified_at: 2026-10-28
author_profile: true
toc: true
toc_label: "Table of Contents"
toc_icon: "robot"
tags:
  - oracle-ai-world
  - agent-sandbox
  - gpu-cpu-layering
  - ai-capex
  - token-metering
  - enterprise-ai
  - sovereign-cloud
categories:
  - agentops
canonical_url: "https://thakicloud.com/tech-blog/en/agentops/two-year-sold-out-falling-work-price/"
---

![The two ledgers split apart, capability locked in on the left, work priced down on the right, meeting at the execution environment](/assets/images/two-year-sold-out-falling-work-price-hero.webp)
*The article's core idea visualized: one ledger rising on 10-year commitments, the other falling on token-level metering, crossing at the execution environment.*

On day two of Oracle AI World in Las Vegas, the protagonist of today's digest was a strange question: why talk about cheap CPUs in a place where every GPU has been sold out? This is the conference where Oracle announced an expanded enterprise AI partnership with OpenAI along with its inference chip lineup. According to Oracle's OCI head, new compute capacity is already sold out for both 2027 and 2028. On the same stage, NVIDIA launched its "Vera" CPU as an agent-execution sandbox service, and OpenAI said it plans to use Vera for agents' immediate-execution workloads. Two facts that look unrelated are standing side by side.

If you read the day's news as one accounting book with two ledgers tied together, the answer becomes visible. One ledger, the price of capability, is rising. The other, the price of work, is falling. The digest's articles collapse into a single sentence: the "price of computing" and the "price of work" are diverging. The two ledgers cross at one point: the place where work actually gets completed. That crossing is not an accident; it reads as a structural change in how industry prices AI. Let's look at the rising ledger first.

## First Ledger: The Price of Capability Is Rising

Starting with the capability side. Per Goldman Sachs' forecast, next year's AI infrastructure investment across the five Big Tech companies (Amazon, Alphabet, Microsoft, Oracle, and Meta) will reach $1.2 trillion, roughly 1,620 trillion won, up 50% from $800 billion this year. About 35% of it is borrowed money, and next year's corporate bond issuance is projected at $420 billion, an all-time high. The break-even point for the five companies' AI businesses is estimated at around $300 billion in annual revenue.

Anthropic's S-1 filing is the flagship document of this ledger. Last year's revenue was $4.6 billion, a 12x growth, yet the operating loss stood at $8.06 billion, with compute and infrastructure spending accounting for 58% of operating costs. Cloud and infrastructure contract values alone reach $518 billion. Revenue up 12x while the deficit balloons 2.7x. This ledger records the state of buying capability first and chasing revenue later.

Scarcity extends into memory. Per KB Securities' analysis, China's four major clouds (Alibaba, Baidu, Tencent, and ByteDance) have joined the race to secure 10-year ultra-long-term server DRAM supply contracts. Seventy to eighty percent of Samsung Electronics' 2027 memory supply is already allocated to long-term contracts, and China accounts for only 7 to 8% of current DRAM revenue. Contract durations are stretching from a 5-year norm into 10-year units. KB Securities noted that longer terms raise both sales visibility and pricing power at once, which could become a turning point for a re-rating of Samsung's valuation.

Korea is building the capability ledger with its own hands. Naver signed a compute-infrastructure contract with Brookfield worth $9 billion, about 12 trillion won, and will bring its first 55-megawatt site in Sejong online in the first half of next year. A Brookfield 100%-funded asset company holds and supplies the GPU assets while Naver Cloud runs the customer business, a financial model that spreads the upfront capital burden onto external capital. Expanding to 200 megawatts in 2028 and ultimately to 1 gigawatt, annual revenue is projected at 20 trillion won. The Bank of Korea's report expects 52% of the $290 billion in hyperscaler data-center investment from 2025 to 2028, roughly $150 billion, to be financed externally, and the BIS estimates that circular financing among AI labs, hyperscalers, and chipmakers will exceed 50%.

The currency of this ledger is watts and 10-year memory contracts. Capability is no longer something you buy when you need it; it is something you lock away a decade out. From a domestic company's perspective, GPU, memory, and power prices will stay stiff for a long time, pushing up server costs in AI data centers and cloud resource pricing along with them.

## Second Ledger: The Price of Work Is Falling

So where is the falling ledger? Inside the same Oracle AI World. There, the "execution layer" separated itself from the "capability layer." Training and heavy inference stay on GPUs. The moment an agent actually does the work (calling tools, running code, checking results) moves onto a low-cost CPU sandbox. That is where Vera sits. Training on GPUs, inference on GPUs and inference chips, execution on CPUs. This three-way split looks like a signal that will change the cost structure of enterprise AI operations.

The entry of inference-specialized chips is happening at the same time. Cerebras, Positron, SambaNova, and Habanero (OpenAI's in-house inference chip designed with Broadcom) are coming in one after another; Google's 8th-generation TPU has placed with a hyperscaler outside Google for the first time; and AMD's MI455 has officially launched. The Digital Times wrote that the front line is moving from hardware competition to competition over integrated systems that deliver "more work per dollar."

Domestically, KT has commercialized this ledger. Token Factory, unveiled at a press briefing on the 27th and launching on the 30th, bundles 500-plus AI models from Korea and abroad into a single API. It touts an auto model router that picks the best model for the difficulty of the question, plus Korean-specialized prompt compression that cuts token costs by up to 25%. Billing runs postpaid, pay-for-what-you-use like a phone bill, with prepaid credits alongside; all inference runs in domestic data centers on a no-storage, no-training principle. A partnership with the global AI gateway OpenRouter secures the overseas model ecosystem as well. It is being evaluated as the starting point of the domestic token economy. The backdrop: global AI token consumption grew from 4.89 trillion in October last year to 172 trillion in October this year, roughly 35x.

The currency of this ledger is tokens and executions. The higher the price of capability climbs, the smaller the unit of work becomes, and the smaller it gets, the more it becomes an object of decomposition, measurement, and optimization. The moment work becomes a measurable unit, the ability to route each execution to the cheapest good pricing system becomes a new differentiator for platforms.

## The Day "Work" Got Its Own Price

The two ledgers meet at the place where work is actually completed. Oracle and OpenAI are heading straight there. Oracle is offering GPT-6 on OCI, and with "Oracle AI Workspace" connects Fusion, NetSuite, the AI database, and OCI directly to ChatGPT so that approved business workflows run inside ChatGPT. It also stood up new field-deployment-engineer (FDE) and consulting divisions that own the full cycle of customer AI projects, from strategy to implementation to operations. Behind the new FDE organization lies an industry reality: the bottleneck in AI adoption is not technology but field execution capability. Even a bundle with $12,000 in annual cloud credits for small and mid-sized businesses is ready.

On the demand side, a KRG survey gives the answer. The average AI budget for next year across roughly 220 major domestic companies with revenue above 200 billion won is 1.818 billion won, up 23.8% from 1.468 billion won this year, and up about 62% in two years. By industry, finance is largest at 682.7 million won per company, and manufacturing is steepest at 27.5% growth. The core investment target is enterprise AI agents. KRG expects investment concentrated through 2026 on generative AI, GPUs, and AI data centers to shift its center of gravity from 2027 to enterprise agents, industry-specialized AI, and physical AI. The 2027 domestic AI market is projected at 10.282 trillion won, up 40% year over year, breaking through 10 trillion for the first time. The 2027 IT services market is also seen at 18.092 trillion won. Against the larger waves of a 44.11 trillion won enterprise ICT market and a 15.85 trillion won cloud market, the business structure is changing toward integrated supply that bundles agent development, workflow integration, and operations-plus-security-and-permission management.

The important part is the second half of the sentence. Budgets are growing, but the yardstick is moving to "outcomes": cutting work hours and operating costs. Even at the parliamentary audit of the Science, ICT and Broadcasting Committee, the adequacy and security management of the 4.7 trillion won Frontier AI program budget were questions on the table. Byline Network's analysis points out that no single platform yet provides all five layers of agent platforms (builder, runtime, orchestration, observability, governance), and that the tension between control and freedom is the core design challenge. The missing layer is precisely the execution environment where work gets completed.

## Two Tasks Remain for Domestic Companies

The two ledgers leave domestic companies with two tasks. First, the cost side. Capability prices (memory, GPUs, power) will stay stiff for a long time, and the US long-term rates pushed up by Big Tech bond issuance transmit into the domestic funding environment. The Bank of Korea warned that Korea, the biggest beneficiary of the AI boom, may face amplified and transmitted AI-driven shocks because of its supply-chain entanglement. And the supply bottleneck sits in components that take one to two years to expand capacity: memory semiconductors, TSMC fab capacity.

Second, the demand side. A 1.8 billion won AI budget per company no longer gets spent on pilot counts. Performance, closed networks, data sovereignty: these three words become the selection criteria. Then the task becomes clear: in a world where capability is sold out for two years and prices are rising, how do you put "work" on a cheap, transparent ledger? The answer is not holding more GPUs, but bringing the right pricing system to each piece of work. Expensive models for heavy thinking, cheap sandboxes for immediate execution, and a meter and an audit on every execution. This execution layer is where the value of enterprise AI moves.

## Paxis, the Operating System That Runs the Price of Work

Here ThakiCloud's Paxis enters. Paxis is ThakiCloud's Agent-Native Cloud, shipped as a full product at v1.1 GA. It is an operating system that manages the price system of work itself as a resource.

In it, Skills, Tools, Policies, and Audit Logs are first-class resources. Work is not a prompt; it is a schedulable unit. Each agent execution runs inside an isolated sandbox, the enterprise-work version of the execution layer that Vera showed at the chip level. CostRouter picks the model per task: expensive models for heavy thinking, low-cost sandboxes for immediate execution. In a world where token unit prices move daily, this allocation is the cost-management device.

Control becomes design, not patching. Autonomy runs from L0 to L3: the agent decides how far to run on its own; policy gates block before execution; audit logs keep every result. The same mechanism answers the performance question KRG pointed out and the audit question the parliamentary review threw. Byline Network's task of datafying an expert's tacit knowledge into skills and harnesses is also solved in the layer where work accumulates as an organizational asset. MCP connectors and the skill marketplace hook into existing work systems, and sovereign on-prem K8s deployment runs as-is inside closed networks where overseas compute is sold out for two years.

The price system of capability will keep rising for the time being. But the break-even sheet of enterprise AI is the price system of work: how cheaply, how safely, and how sovereignly you can run work. Paxis is ThakiCloud's answer to that question.

## References

This article synthesizes the news below.

- Etoday, [KB Securities: "Samsung, even China's Big Tech, competing for 10-year memory contracts: pricing power strengthening"](https://www.etoday.co.kr/news/view/2640848)
- The Daily Car, [Big Tech companies racing to borrow and build data centers: the reason behind it](https://www.dailycar.co.kr/content/news.html?type=view&autoId=62971)
- Byline Network, [Oracle enters enterprise AI projects with OpenAI](https://byline.network/?p=9004111222625016)
- Newsis, ["12 trillion won of ammunition loaded": Naver starts up a "mega AI factory" aiming for 20 trillion in annual revenue](https://www.newsis.com/view/NISX20261027_0003843568)
- The Digital Times, [Oracle: "Two years of AI infrastructure sold out", OpenAI, NVIDIA, Google, Meta, Snowflake, and others](https://www.dt.co.kr/article/12091693?ref=naver)
- Byline Network, [Where will future AI agent platforms flow](https://byline.network/?p=9004111222624803)
- Newsis, [1.8 billion won per company in AI budgets next year: investment grows, outcomes are demanded](https://www.newsis.com/view/NISX20261027_0003843339)
- Maeil Business Newspaper, [AI usage billed like a phone bill, only for what you use… KT unveils "AI shopping mall" Token Factory](https://www.mk.co.kr/article/12187770)
- GDNet Korea, [Hacking liability was asked about and the AI budget was probed… the bitter aftertaste left by the parliamentary audit](https://zdnet.co.kr/view/?no=20261027172409)
- Asia Economic, ["It resembles the dot-com bubble, but it is different": three risks of AI funding](https://view.asiae.co.kr/article/2026102717592138762)
