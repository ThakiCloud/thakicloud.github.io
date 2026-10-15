---
title: "The AI that eats too much, the AI that borrows too much"
excerpt: "In the same week, Apple called its memory supply an 'absolute crisis' and CoreWeave's debt swallowed the semiconductor index. We laid out the two fault lines of supply shortage and debt excess, and the answers companies must arrive at."
seo_title: "Memory absolute crisis, AI debt shock. The two fault lines of AI infrastructure"
seo_description: "Apple's declaration of an absolute crisis in memory supply and CoreWeave's $40 billion in debt. Supply shortage and debt excess, the two fault lines heading toward companies, and how to respond viewed through the Paxis lens."
lang: en
canonical_url: https://thakicloud.com/tech-blog/en/agentops/the-ai-that-eats-too-much-borrows-too-much/
date: 2026-10-16
last_modified_at: 2026-10-16
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "robot"
tags:
  - ai-memory
  - neocloud
  - coreweave
  - sk-hynix
  - ai-infrastructure
  - gpu-debt
  - agentops
categories:
  - agentops
---

Two sentences crossed paths this week. One came from Apple's new CEO John Turner in an interview with Time: "The constraint on memory is an absolute crisis." The other was a single line from Jensen Huang, calming concerns about CoreWeave's debt: "CoreWeave doesn't need a bailout." The first sentence is the lament of a buyer who cannot buy, and the second is the defense of a debtor who has borrowed a lot. On the surface, the two sentences describe different markets, the stories of a consumer electronics giant and a GPU cloud operator. That is also why this morning's news splits into two axes, semiconductor supply and AI infrastructure finance. On the Korean side, SK Hynix's roadmap after HBM and YMTC's pursuit hang on the supply axis, and Vessel AI's and Zenon's debt expansion hang on the finance axis. But there is one thing they share. Thirsty demand for AI execution. This article starts from the two crises where AI infrastructure collided in the same week, supply and debt, and asks what companies in the position of receiving the shock should read.

![An image visualizing the concept of the AI that eats too much and borrows too much](/assets/images/the-ai-that-eats-too-much-borrows-too-much-hero.webp)
*We visualized the core concept of this article.*

## The buyer's crisis: data centers eat memory first

The mechanism of Apple's crisis is not complicated. With HBM demand for AI accelerators and data centers surging, the production capacity of SK Hynix, Samsung Electronics, and Micron has poured into HBM. General-purpose DRAM and NAND used in smartphones and PCs have been pushed out, and forecasts say the supply shortage will continue until 2028. According to M Economy News, Apple cannot cover the shortfall even with its existing supply chain of Samsung Electronics, SK Hynix, and Micron, and is trial-applying chips from China's ChangXin Memory Technologies (CXMT) in iPhones and MacBooks. The US Department of Commerce and Congress are stepping on the brakes with semiconductor regulations targeting China, but current rules do not outright ban the purchase itself of already-produced Chinese general-purpose memory. The door is at least open. The waves of the AI boom have reached the consumer electronics supply chain.

The supply side's answer is the standards war. Ahn Hyun, SK Hynix's President of Development, presented the post-HBM roadmap at the SEDEX 2026 keynote. As AI models grow, HBM alone cannot handle performance and capacity demand, and the industry is in a phase of competing over a new memory layer that is larger than HBM and faster than eSSD. SK Hynix's candidate is HBF (High Bandwidth Flash), which stacks NAND vertically on the die like HBM. After the first standard specification (version 0.7) through OCP last July, it plans to publish the final standard next January and is building an ecosystem with SanDisk and Google, among others. It is also pushing 3D stacked DRAM with I/O expanded by dozens of times, Storage Next SSD with 4 to 8 times the IOPS, and CXL pooled memory. NAND write durability and latency may be a concern, but the company explains that since the AI inference workload itself is read-centric, pre-patching can compensate. Samsung Electronics counters with the zHBM and HBM4E roadmap. The fight over next-generation memory standards is, in itself, the next HBM war.

Meanwhile, according to the Seoul Economic Daily, China's YMTC overtook Kioxia and Micron in NAND shipments to become third in the world. Its Q2 shipment share was about 17%, up 6 percentage points from 11% a year earlier, and revenue grew about 63% quarter over quarter to 73.8 billion yuan. Its revenue share is 14%, behind Samsung Electronics at 28%, SK Hynix at 19%, and Micron at 15%. Working with Huawei, it is expanding into enterprise SSDs for AI servers, and Counterpoint expects its server revenue to reach about 39% of the total by 2028. Memory is becoming the second oil of the AI era. The side that eats first is the data center, and the side that loses share is the existing customer.

## The debtor's crisis: a GPU city built on debt

While the buyer groans under scarcity, the debtor groans under excess. GPU-only neocloud CoreWeave built its AI infrastructure on more than 40 billion dollars, over 67 trillion won in debt, and expects annual losses of more than 2.5 billion dollars. Its chance of bankruptcy within 5 years is estimated at over 60%, its corporate bond price has fallen to 78% of face value, and its credit default swap (CDS) premium has spiked to 1,194bp. According to Money Today, the Philadelphia Semiconductor Index (SOX) plunged more than 9% this week, alongside reports of 3.6 trillion won in foreign net selling and a sharp drop in the KOSPI. The shock did not stay in a single name.

Supplier Nvidia holds 10% of CoreWeave's equity. This circular financing structure, where the supplier gets into the customer's capital, is a structural vulnerability of the AI boom, and Gartner raised the same concern. Jensen Huang's "no bailout needed" remark was an attempt to pin this vulnerability down with one sentence, offered in the context of falling financing costs and continued improvement in financial health. CoreWeave's stock price rebounded 6% on that one line, and the market still swings on a single sentence.

And this is not one company's story. TrendFox raised its forecast for the capex growth rate of the global top 9 CSPs next year from 50% to 60%, projecting a break past 1.5 trillion dollars. AI server market revenue is also expected to grow more than 90%, from 479 billion dollars this year to 920 billion dollars next year. Korea is heading in the same direction. According to DataNet, Vessel AI targets 200,000 GPUs by 2030 (10,000 in 2026, 50,000 in 2027), aims to secure 8 AIDC hubs in and outside the metropolitan area by next year, and is raising 400 billion won through GPU finance. It is an aggressive expansion: 250 billion won in revenue expected this year, 2 trillion won targeted by 2028, and its own "fluid computing" that treats GPUs scattered across dozens to 100 data centers as a single system, extending all the way to services that supply inference by the token. From the customer's perspective, the positioning is that they are not buying the GPU itself, but buying computing where large-scale training and inference run stably. Zenon is also allocating more than half of its IPO proceeds (21.3 to 26.8 billion won) to DGX B200-class GPU servers, planning to enter the token-based serving API business with optimization technology that serves faster on the same GPUs.

The memory crisis is a crisis of "shortage," and the debt crisis is a crisis of "excess." One has too little supply, the other too much leverage. But both come from the same greed, the demand for AI execution.

## When the two crises turn toward companies

From a company's seat, these two crises arrive as two things, not a stock chart. The price per inference token, and the continuity of cloud contracts. Rising memory prices do not end as chipmakers' earnings news; they move into a variable of the execution cost where AI work runs. The report from IT market research firm KRG forecasts the domestic AI market at 10.282 trillion won next year, up 40% from this year and breaking 10 trillion won for the first time. The average AI budget of surveyed companies next year is 1.818 billion won (23.8% up), and finance is the largest at 6.827 billion won per company. The annual average growth rate for 2025 to 2030 is 36.9%, and by 2030 the market is expected to reach 24.726 trillion won. Notably, the nature of investment is shifting toward proving outcomes, productivity gains and cost reduction. Enterprise AI agents, AI infrastructure and data centers, and Physical AI are named as the growth axes, and the domestic cloud market also widens to 15.85 trillion won on 19% growth. The report adds that the bigger the investment, the fiercer the competition over outcome verification, data quality, security, and permission management.

Seoul's in-house AI is an example of how the two crises reach companies. According to New Daily, the administrative AI service with a 3.56 billion won budget had only 18.3% (1,994 people) of its 10,888 target employees as real users in September, and 70.6% of service use stayed at simple work manual search. Seoul put its own LLM on a closed network to reduce data leakage risk, but surging GPU prices delayed equipment procurement and lowered the specs. The secured amount was cut in half from the originally planned 24 H200s to 12 H200s and 8 RTX6000s, and the recommended concurrent connections were capped at 1,000. The average monthly connections per user was just 2.7. Sixty-three percent of public officials already use private generative AI at work, yet the personal information blocking filter remains unbuilt due to project delays. The city says it will upgrade with AI agent features like document summarization, meeting room booking, and evaluation committee selection. The direction is right. In a trend where 2 out of 3 public agencies have already adopted AI, the gap turned out to be the execution environment, not the will.

Read again through the Seoul case, the two crises arrive with different faces. The memory crisis as "cannot buy the equipment, or buys it expensive," and the debt crisis as "does not know how long the cloud contract will last." And without security governance on top of that, the service becomes a channel of neglect and a channel of data leakage. The pain of AI adoption is not the model. It is the execution environment and governance that run the execution on top of it and take responsibility.

## The lens: what to do when the foundation shakes

The more the foundation shakes, the more the value rises of the layer that runs work on top of it, stably and auditably. The fact that both crises happened in memory and capital, that is the foundation layer, is why the answer is not in the same layer. ThakiCloud's agent-native cloud Paxis (a formal product, v1.1 GA released) is a design built for this shaking.

Token price volatility born of the memory squeeze is answered by per-task model selection (CostRouter). Models are chosen and routed to match the difficulty and cost of the work, so the shock of raw price change is absorbed at the execution layer. Against the debt risk of neoclouds, the path opens to internalize the execution environment itself into sovereign or on-premises K8s (ai-platform), and each agent's work runs inside an isolated sandbox. Skills, Tools, Policies, Audit Logs are not features here but first-class resources, and the policy gate and autonomy governance (L0~L3) track what the agent did, who approved it, and what the result was. MCP connectors and the skill market handle the connection to existing business systems. Of course, Paxis does not solve memory supply or pay off debt on anyone's behalf. Making sure that turmoil does not shake all the way to the execution layer, that is the job of this product.

Demand for such a layer is no longer optional. According to IT Chosun, AnLab CloudMate's SecureBridge inspects about 8,600 enterprise prompts daily on average, and the cumulative protected population is over 26,800 people. The fact that monitoring that only guards the entrances and exits of AI use has grown into a separate product shows how much companies care about the act of making AI work itself. Seoul's missing filter is also a lesson that the governance layer must be built before automation, and alongside it.

Apple's absolute crisis and CoreWeave's debt are, in the end, signals about the price and continuity of AI execution next year. The companies that take the 10 trillion won market next year will not be the ones stacking one more layer of foundation, but the ones making the execution layer auditable, resilient to cost, and sovereign. That is why Paxis stands on top of it.

## References

This article was written by synthesizing the news below.

- The Bell, [[The Bell][SEDEX 2026] SK Hynix President Ahn Hyun, "the key to next-generation memory after HBM is..."](https://www.thebell.co.kr/free/content/ArticleView.asp?key=202610141302044680106383)
- Seoul Economic Daily, [China's YMTC, third in the world in NAND shipments...closed the gap with Samsung and SK](https://www.sedaily.com/article/20102290?ref=naver)
- M Economy News, [Apple CEO "memory supply crunch is an absolute crisis"...possibility of introducing Chinese semiconductors...](https://www.m-economynews.com/news/article.html?no=71732)
- DataNet, [Vessel AI, starting its leap to a global neocloud ··· 200,000 GPUs by 2030...](https://www.datanet.co.kr/news/articleView.html?idxno=215125)
- Money Today, [Jensen Huang "CoreWeave doesn't need a bailout"...one remark that calmed AI debt anxiety](https://www.mt.co.kr/world/2026-10-16/2026101607251938033)
- Digital Times, ["Domestic AI market next year, 40% growth over this year, projected to break 10 trillion won"](https://www.dt.co.kr/article/12089407?ref=naver)
- The Bell, [[The Bell][Zenon IPO] half of offering funds into GPUs...'B2C·Physical AI' synergy](https://www.thebell.co.kr/free/content/ArticleView.asp?key=202610141144314480105944)
- New Daily, [[Exclusive] The humiliation of Seoul's in-house AI ... 80% of officials ignore it](https://www.newdaily.co.kr/site/data/html/2026-10-14/2026101400145.html)
- CEO Score Daily, [Global big tech AI investment up 60% next year...Samsung and LG target the parts and cooling markets...](https://www.ceoscoredaily.com/page/view/2026101514262861207)
- IT Chosun, [[Agentic AI Map 2026] AnLab CloudMate's 'SecureBridge' that monitors AI input and output](https://it.chosun.com/news/articleView.html?idxno=2023092171766)
