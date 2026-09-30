---
lang: en
title: "Three Invoices of the AI Era"
excerpt: "Micron at 73.5 trillion won, PJM at 6.8GW, LG Electronics at 150 billion won. This morning, the AI news stage centered not on models but on memory, power, and cooling. What the three invoices ask of a company is the cost of one run."
seo_title: "Three Invoices of the AI Era: Memory, Power, Cooling | ThakiCloud"
seo_description: "Micron posts record quarterly revenue of 73.5 trillion won, PJM redraws its 6.8GW power plan, and LG Electronics opens its first US chiller plant. We lay out why AI-era costs are shifting to the physical layer and how companies that run agents do the math."
date: 2026-10-01
last_modified_at: 2026-10-01
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "robot"
tags:
  - ai-infrastructure
  - memory-supercycle
  - data-center
  - power-grid
  - cooling
  - edge-ai
  - inference-cost
categories:
  - news
canonical_url: "https://thakicloud.com/tech-blog/en/news/ai-three-invoices/"
---

AI industry news is usually introduced by model name. And this morning, model news was not lacking. Google's new model Gemini 4 Argon made the rounds, Meta's everyday-life assistant Muse was the talk, and the free-for-all "AI for All" service from SKT, Kakao, and KT is set to debut in October. But the three stories that most clearly show where the money is flowing carry no model names at all. Memory, power, cooling. Read the ledger today and the AI market looks priced by physics, not by the model layer.

![An image illustrating the concept of the three invoices of the AI era](/assets/images/ai-three-invoices-hero.webp)
*The core concept of the article, illustrated.*

## The Memory Invoice: 90 Percent Margin

Seoul Shinmun reported this morning that Micron's revenue in the fourth quarter of FY2026 was 54.2 billion dollars, about 73.5 trillion won. That is a 379 percent increase year over year, and a record high for both the quarter and the full year. The composition looks newer than the total. Revenue from core memory for AI data centers was 18 billion dollars, 11 times the same period a year earlier, and the gross margin was 90 percent. Memory is usually called a business that trades in generic commodities, but once you see a 90 percent margin, the story changes. Micron is also the only HBM manufacturer in the United States, and it has been assessed as holding a monopoly position in the supply of AI GPU memory.

Micron's CEO asserted that the DRAM, HBM, and NAND supply shortage in fiscal years 2027 and 2028 will be more severe than in 2026. Financial commitments under long-term supply agreements, or SCA, with customers rose 45 percent in six months, from 22 billion dollars to 32 billion dollars, and most of the 2027 HBM production volume is already pre-contracted. A report from DigiTimes in Taiwan even speculates that the 2027 production capacity of the three major DRAM makers has been effectively allocated in full. The memory market can now be called a fully sold-out phase.

The forecast that Samsung Electronics and SK Hynix will still not meet HBM, DRAM, and NAND demand even if they raise monthly output by 1.1 million units by 2027 is in the same vein. That means domestic cloud and AI companies can no longer avoid rising unit prices for GPU servers and memory. If the volume constraint on HBM, which inference depends on, drags on, it will hit both the price and the launch schedule of AI services. Memory is no longer a question of when to buy, but of how to secure long-term supply contracts and the premium that comes with them. Meanwhile, Micron's outlook for the next quarter of 61.5 billion dollars in revenue and 38.15 dollars in adjusted EPS beat market expectations, but the stock still fell slightly because the gross-margin outlook of 86.25 percent came in a touch below expectations. A market that has already paid for scale is now scrutinizing how much more expensive the next round will be. That the stock dropped on record revenue shows the market's stance has shifted: it prices tomorrow's supply before today's profit.

## The Power Invoice: A 6.8GW Plan to Redraw

The US power-market story reported by Pinpoint News is blunter. PJM Interconnection, the largest grid operator in the United States, has halted the one-time special auction it held to secure 6.8GW of the power shortfall. FERC said the plan was flawed and recommended that PJM submit an alternative, and PJM must file a new plan by February next year. The point of contention is the 15-year power-cost burden structure for data centers and how risk is allocated. That regulation is demanding a redesign of "who pays for power, and under what structure" is itself significant. Power in the AI data-center era, much like memory supply contracts, is being set by long-term contract structure rather than spot price.

The cost of the power capacity auction has climbed to about 30 billion dollars, 40.6 trillion won, on the back of rising data-center demand. The region PJM governs spans 13 states with a population of 67 million, and includes Virginia's "Data Center Alley." And there are more than 800 new applications still waiting to be connected, totaling 220GW. Set against the 6.8GW shortfall being secured now, that means the demand in the queue is overwhelmingly larger.

When power rates rise, the cost is passed to cloud rates, and when cloud rates rise, it is passed to the costs of the companies running AI on top of them. In choosing a data-center site, the condition of being somewhere power is cheap and stable is no longer an option; it has become a variable in AI infrastructure investment strategy.

Korea stands before the same question mark. Large-scale GPU cloud and AI data-center construction is being pushed as a national strategic project, and in the United States the power-cost structure has shaken enough to draw FERC intervention. That is a preview that grid stabilization and expansion, along with the debate over how the rate burden is shared between companies and consumers, will follow at home. If the cost structure for securing long-term power is not designed in advance when choosing a data-center site, the total cost of ownership of AI infrastructure can balloon faster than expected.

## The Cooling Invoice: A Chiller Plant in Virginia

In that same Virginia, a Korean company has landed this time. According to iNews24, LG Electronics is building its first chiller, that is, a data-center cooling equipment, plant in Windsor, Virginia. It has a total floor area of 32,000 square meters and targets operation in the first half of 2027. The total investment is 150 billion won, combining 63.9 million dollars for the US plant with expansion at home, and it will create 164 new jobs.

The chiller is called the heart of the AI data center. As GPU density climbs, heat becomes the largest physical bottleneck after power. Omdia forecasts that about 60 percent of the world's data-center power capacity will be concentrated in North America by 2030. A Korean company has entered the side that sells that heart. The One LG strategy, which combines LG Energy Solution's batteries, LG CNS's data-center construction, and LG Electronics's cooling, is completed as a package in which the company buying power can buy cooling and construction along with it in one go. The trend of cooling equipment being localized as far as the United States also means an era is opening in which domestic GPU cloud and on-prem data-center operators must weigh cooling capacity and efficiency from the design stage.

## Two Kinds of People Who Read the Invoices

The three invoices share a sender. It is the physical layer. The cost curve of the AI era is drawn by physics, not by model names. Whenever resources get tight, it is natural for two kinds of people to show up.

Of course, money moved in the model layer too. JP Morgan analyzed that Meta's Muse has a transaction-fee monetization model and raised its target price from 820 dollars to 920 dollars, and on the day Muse reached number one in the App Store, Meta's stock surged 11.43 percent. But the center of gravity of this morning's ledger was still the physical layer.

The first kind are the people who raise the invoices. Memory makers, the power market, cooling-equipment vendors; all of them are in a seller's market right now. The second kind are the people who cut the invoices. IT Daily's edge-infrastructure report is exactly that scene.

Intel's SuperClaw demonstrated that it cut enterprise cloud token consumption by up to 70 percent through intelligent workload routing. The AMD Ryzen AI Max PRO 400 ran a 300B-parameter model locally for the first time as an x86 client, and the Radeon AI PRO R9700 processes 18 million tokens a day. The NVIDIA RTX Spark pairs Blackwell GPUs with Grace CPUs to deliver up to 1 PFlops of compute and 128GB of unified memory, and in Korea Krafton and NCSoft have already begun work on running their own titles. Dell has accumulated more than 3,000 enterprise deployment cases and is widening its reach from the desk to the data center through the "Dell AI Factory with NVIDIA" ecosystem. Intel has secured domestic field references such as the LG Innotec smart factory and Samsung Medison medical-image analysis, and Korean edge hardware companies such as Mobilen have completed validation on more than 490 models. That means Korea's own supply ecosystem has also reached a mature stage.

The shared logic is one. Do not put every workload on the most expensive resource; route it. In fields where data export is restricted, such as public video surveillance, finance, and manufacturing, demand for local inference is especially high. The 70 percent number shows that where you run something can carry the same weight as what you run. And the logic of the side that cuts is not "use less AI," but "pull the same work off the more expensive resource." The war between the side that raises and the side that cuts will continue for as long as the 2027 supply shortage is real.

## The Math of Companies That Run Agents

So how should a company reckon these three invoices?

In an era when compute is allocated like power, the question of running agents on the cloud shifts from "which model is the smartest" to "how much does one run cost, and where does that data live." Physics sets the model's invoice. But the company sets the run's invoice. Depending on how finely you route and how firmly you manage the execution boundary, even the same agent ends up costing differently.

ThakiCloud's agent-native cloud Paxis (v1.1 GA) is a formal product designed to answer exactly these two calculations. Skills, tools, policies, and audit logs are managed as first-class resources, and autonomy works within a governance system that runs from L0 to L3. Per-task model selection, that is, CostRouter, assigns the most economical model to each workload, and the policy gate stops risky actions before execution. Isolated sandboxes and audit logs guarantee that if something goes wrong, you can replay the scene. MCP connectors and the skill marketplace standardize connections to external systems, and the sovereign and on-prem Kubernetes options let you run the same agent workload without sending data out.

If Intel's SuperClaw 70 percent is the answer at the chip layer, Paxis's CostRouter is the way of answering the same question at the agent orchestration layer. Per-task model selection answers the memory invoice, on-prem and sovereign execution answer the total cost of ownership created by power and cooling, and sandboxes and audit logs answer the safety of execution.

In October, with the "AI for All" service, which gives every citizen a free agent, on the horizon, this question is no longer one for some far-off future. When consumer expectations shift to agents enough that "one AI agent per person" is discussed as a policy goal, the questions that reach companies will soon shift to auditing, permissions, and safe execution. For as long as the three invoices for memory, power, and cooling keep arriving, the AI task of companies moves from "buying models" to "managing execution." No one will pay the invoice physics sends on your behalf. But the invoice execution sends can change, depending on how you read it.

## References

This article was written by synthesizing the news below.

- Seoul Shinmun, [Micron revenue hits a record 73.5 trillion won... "Memory shortage to get worse"](https://www.seoul.co.kr/news/economy/industry/2026/10/01/20261001500009?wlog_tag3=naver)
- Pinpoint News, [US power demand pulled up by AI... PJM redraws its 6.8GW securing plan](https://www.pinpointnews.co.kr/news/articleView.html?idxno=491651)
- iNews24, [LG Electronics opens its first chiller plant in the US... Aims at the "heart" of the AI data center](http://www.inews24.com/view/2010702)
- IT Daily, [[Edge Infrastructure ②] Key solutions by company](https://www.itdaily.kr/news/articleView.html?idxno=241938)
- Digital Daily, [Google unveils next-generation AI "Gemini 4 Argon"... from cybersecurity experts...](https://www.ddaily.co.kr/page/view/2026100107521451514)
- Weekly Dong-A, [Shops without search and books hotels effortlessly... everyday-life AI assistant Meta's "Muse..."](https://weekly.donga.com/3/all/11/6402757/1)
- Yonhap News, [SKT, Kakao, KT debut "AI for All" in October... free for all citizens](https://www.yna.co.kr/view/AKR20260930159700017?input=1195m)
