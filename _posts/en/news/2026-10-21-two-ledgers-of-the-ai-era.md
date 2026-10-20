---
title: "The Two Ledgers of the AI Era: The Burning Side and the Saving Side"
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/news/two-ledgers-of-the-ai-era/"
excerpt: "Goldman Sachs has named electricity the new bottleneck of AI, and Anthropic disclosed a 107 trillion won loss despite 1500% revenue growth. On the same day, Korean nuclear power and securities firms began calculating AI in minutes and in won. An analysis that reads today's news through two ledgers."
seo_title: "The Two Ledgers of the AI Era: The Burning Side and the Saving Side | ThakiCloud"
seo_description: "The electricity bottleneck warning, Anthropic's $450 billion in locked compute, the 2028 supply countdown, and the ROI ledgers of nuclear power and finance. Today's news read through two ledgers, and what 'smart' now means in the AI era."
date: 2026-10-21
last_modified_at: 2026-10-21
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "robot"
tags:
  - agentops
  - paxis
  - enterprise-ai
  - thakicloud
categories:
  - news
---

Two kinds of ledgers landed on the news desk today, side by side. One buys compute in trillions of dollars, and the other has started measuring AI in minutes and in won. They look like unrelated stories, but on the same day they meet at the same point. Here is each ledger, opened one by one.

"What good are GPUs?" is the question a Wall Street bank threw at the AI industry this week. Money Today relayed Goldman Sachs's warning. It is not hyperbole. Goldman's report is titled "Securing Power in the AI Era," and the outlook is concrete. U.S. datacenter electricity demand is expected to grow 38% year over year in both 2026 and 2027, and the global buildout of AI computing, power, and datacenter infrastructure will require $7.6 trillion, or 10,083 trillion won. Even among the Big Tech, 2027 bond issuance is expected to reach $420 billion, more than 60% above this year's. The average age of the U.S. power grid has reached 40 years, and while expansion permits take years, the situation where datacenters are built but electricity cannot get in has become a reality. The point is that Big Tech like Microsoft and Oracle are in a desperate state, directly building gas generation and fuel cells next to datacenters.

![Image visualizing the two ledgers of the AI era, the burning side and the saving side](/assets/images/two-ledgers-of-the-ai-era-hero.webp)
*The core concept of the article, visualized.*

## The Gauge, Not the Chip

Until now, competition was about which chip is faster and which GPU to buy more of. The bottleneck has moved to where to get the electricity to keep it running. This is a constraint with a different nature than chips. Chips are a lead-time problem, but power is a permit problem. Expanding substations and transmission lines and getting grid-connection approval takes years. Total datacenter power consumption is expected to grow 160% between 2023 and 2030, and power dedicated to AI and generative workloads is expected to rise 170% between 2025 and 2030. TrendForce points to 2028 as the inflection point of the power bottleneck, saying that in 2030 global datacenter power demand will be 490.7GW while available supply capacity is only 222.6GW. In other words, for the next roughly two years, "compute" and "electricity" are the same word in the AI industry. Without securing electricity, not a single GPU can run. If this structure is overlaid on the domestic market as-is, the construction and operation schedules of large AI datacenters and GPU clouds will hinge on whether power is secured. That is the backdrop for on-premises and sovereign AI, which can manage power stably, and for per-token power efficiency emerging as a differentiating factor in enterprise AI adoption.

## The 107 Trillion Won P&L

Electronics News reported, based on the securities registration statement, i.e. the S-1, that the Wall Street Journal obtained, that Anthropic's first-half net loss reached $80.7 billion, about 107 trillion won. First-half revenue of $16.3 billion is a 1500% surge from $1.1 billion a year earlier, so the growth itself is not the problem. The problem is the structure of spending. Of the loss, $72 billion is a book loss from changes in the value of financial instruments such as convertible bonds, but it is a scale close to double last year's full-year loss of $42 billion. First-half compute and infrastructure spending alone was $9 billion, already past last year's full-year $7.3 billion. It means money is going not to flexible R&D but to "locked" compute. Over the next 7 to 10 years, non-cancellable compute contracts reach $450 billion with the three hyperscalers, Google Cloud $111 billion, AWS $110 billion, and Microsoft $31 billion, and adding chip rentals and small cloud contracts brings the total to up to $750 billion, about 995 trillion won. About a fifth of revenue comes from two customers. When the hyperscalers began to see Anthropic as a competitor and restricted capacity supply, the model company moved to build its own datacenters. The S-1 discloses even technical risks such as the model's self-preservation behavior, and backlash against datacenters. Tracking how far the hyperscalers' capacity restrictions spread and when Anthropic's own datacenter comes online gives a sense of how tight global compute supply will be over the next few years. The industry's most aggressive growth story and its heaviest infrastructure lockup are in the same document. It is a signal that the essence of model competition has moved to a competition for securing compute and raising capital.

## The 2028 Countdown

The countdown is moving in the same way on the semiconductor side. ASML has officially confirmed that the utilization rate of the high-NA EUV equipment it has delivered is close to 90%, and its CEO said demand will outstrip supply until 2028, also showing interest in orders for 2029 and 2030 volumes. The utilization instability, which had been the biggest risk of this equipment that costs 500 billion won per unit, has been resolved. Samsung Electronics is targeting to introduce high-NA EUV in mass production in 2028 for its foundry leading-edge node 1.4 nanometer and 1D DRAM, two years ahead of TSMC's 2030. SK Hynix is bringing in initial equipment to its Icheon M16 fab and elsewhere, running process recipe and yield R&D, with a target of applying it to the DRAM process in 2028.

As advanced packaging became the main battleground, Canon decided to increase by 1.5x by 2029 its production capacity for the i-line exposure equipment used in the HBM back end, and TSMC is also accelerating the expansion of advanced packaging such as CoWoS. As the memory shortage deepened, Seoul Economic Daily reported that used DRAM recycling is booming in China, and even the worry of low-price devices being bricked has emerged. The impact of AI datacenters has spread to general-purpose memory too, since the price of smartphone LPDDR4 and LPDDR5 in the second quarter of this year surged about 3x compared to the fourth quarter of last year.

The most interesting line is in the news of the domestic five-company alliance. On the 16th, Orchestra Cloud, FuriosaAI, Upstage, SPK, and Daewon CTS signed a memorandum of understanding for the joint development of an NPU-based sovereign AI full-stack product. The battlefield they are aiming at is the inference market, not the large-scale training where NVIDIA is strong. As Datasom's analysis puts it, they see the decisive point as power efficiency and operating costs. The first mass-production volume of RNGD 2nd generation, the inference NPU that is the core component of the alliance from FuriosaAI, is 4,000 units. Even inside the semiconductor industry, they are admitting that the winning condition of the AI era is not training speed but execution cost.

## The Other Side of the Ledger

Let me turn to the other side of the ledger. While the U.S. industry is burning, Korean companies have already started writing a different ledger. According to the Dong-A Ilbo, Korea Hydro and Nuclear Power, working with Naver Cloud, installed a dedicated large language model inside a datacenter and completely isolated it from the external network, and with this nuclear-specialized AI reduced the technical document consistency review time by 90%. It operates AI agents separately for the seven major core operations including construction, power generation, and safety. The Forest Service is said to save 2.5 billion won a year by bundling national forest welfare facility information and reservations with AI. The fact itself that a sovereign AI with the external network completely isolated has entered the production environment of high-security industries like nuclear power is a pattern of regulated industries moving from cloud dependence to on-premises AI.

Byline Network reported that after NH Investment & Securities posted its largest-ever results with a first-half consolidated net income attributable to owners of the parent of 965.2 billion won, it completed the selection of a contractor to build an enterprise-wide AI platform. By the end of this year, it will build a platform connecting multiple AI models with in-house data and business systems, and it is a structure where on-site employees directly create agents with no-code. The governance stack is also concrete. It introduces a harness surrounding the model, an LLM judge, and HITL, human review, and reflects the AI Basic Act and the financial AI guidelines. Starting in 2027, it plans to introduce agents step by step into the core processes of the WM, IB, and Wholesale business divisions and verify effectiveness with per-agent KPIs. According to News Today, JB Financial Group invested 40 billion won in Upstage's Series C-2 to secure a 2% stake, and will jointly develop a financial-specialized AI agent to be used in the corporate credit process. Upstage, which became the first domestic generative AI unicorn in April with a 180 billion won investment, received a 2 trillion won valuation in this round.

The standard has changed. When Bespin Global released a casebook gathering 34 AI transformation cases, it reported that the number of global banks publicly disclosing AI investment returns increased from 4 to 15 in one year, and diagnosed the stage where AI delivers results. The casebook includes a company that earned an additional $17 million in revenue in 60 days, and a home appliance company that reduced manual work by 77%. The question has moved from whether you are using AI to how much money and how many hours you saved with it.

Next, IT Chosun reported that a Kakao consortium is building an open agent ecosystem linking MCP with its own model Canana through a government support project worth about 11 billion won by December 2027. The design of distribution infrastructure connecting agent registration, verification, execution, and settlement is beginning. The timing for companies to choose their "ledger management layer" has come earlier than expected.

## So What Does "Smart" Mean Now

Placing today's two ledgers side by side, the denominator converges to one. The scarce asset is no longer intelligence itself. What is scarce is the electricity to run that intelligence, the money to keep running it, and the management to run it safely. The model company's ledger is how much compute to lock up over the next 7 to 10 years, and the enterprise customer's ledger is how much one job costs and whether you can prove it was done safely. Where these two ledgers meet is the layer between the model and the business. It is the layer that decides which model to attach to which job, what permissions to grant, and what to record. This layer used to be an option of the IT department. Now it is where electricity bills, contracts, and audit records intersect. The two ledgers look like separate worlds on the surface, but they face each other at the moment of procurement. Enterprise customers will now hold up Anthropic's S-1 and ask why they should sign long-term lockup contracts with a single supplier.

## The Conclusion Through the Paxis Lens

Looking at this layer through ThakiCloud's Paxis, today's news attaches very concretely. Paxis is ThakiCloud's agent-native cloud official product (v1.1 GA). First-class resources are skills, tools, policies, and audit logs. On top of this, the skill market becomes the place where companies reuse and distribute the business skills they have accumulated.

The cost pain is addressed with per-job model selection. CostRouter picks a model appropriate for the job and runs it, without clinging to the most expensive model. In an era where GPU rental and electricity prices are rising, this is not an option but a survival strategy. The lockup pain is addressed with MCP connectors, the skill market, and the deployment of sovereign and on-prem K8s (ai-platform). What Anthropic's $450 billion non-cancellable contracts taught is the exit cost of single dependence. Paxis, in a structure not tied to one model or cloud, leaves companies the option to swap. The safety pain is addressed with policy gates, autonomy (L0 to L3) governance, and isolated sandbox execution. In a flow where MCP is solidifying as a de facto standard for agent connections, connectors are a strategic resource that defines ecosystem boundaries. The financial AI guidelines that NH Investment & Securities mentioned, and the nuclear documents with the external network completely cut off, are ultimately the requirement that agent behavior must be auditable. In Paxis, the audit log is a first-class resource.

In summary, today's news desk taught one thing. Smartness in the AI era is no longer a question of how good the model is, but a question of which ledger to spend money in. Future competitiveness will be measured not by how much you buy, but by how long you can keep things running with what you have. Ledgers spent on electricity and audit run for longer even with limited compute.

## References

This article was written by synthesizing the news below.

- Global Economic, [TSMC, HBM orders flood in; Japan's Canon to 1.5x its exposure equipment capacity](https://www.g-enews.com/view.php?ud=202610210734253825e7e8286d56_1)
- Shinailbo, [ASML: "Next-gen EUV utilization at 90%"; Samsung, SK Hynix all in, focus on 2028](https://www.shinailbo.co.kr/news/articleView.html?idxno=5073476)
- Seoul Economic Daily, [Memory scarcity drives China's "used DRAM" recycling boom; "bricked" worry for low-price IT devices](https://www.sedaily.com/article/20104050?ref=naver)
- Money Today, ["What good are GPUs?" What is blocking AI industry growth; Goldman Sachs's warning](https://www.mt.co.kr/world/2026/10/21/2026102107295119895)
- IT Chosun, [[Agentic AI Map 2026] Kakao Enterprise's "AI infrastructure" that separates GPU ownership and operation](https://it.chosun.com/news/articleView.html?idxno=2023092172423)
- Byline Network, [NH Investment & Securities to build enterprise-wide AI platform this year; agent expansion next year](https://byline.network/?p=9004111222623636)
- Dong-A Ilbo, [Nuclear documents once cross-checked by hand; with AI, review time down 90%](https://www.donga.com/news/It/article/all/20261020/134873224/2)
- Datasom, [[Analysis] Five domestic AI companies sign alliance; a move to break NVIDIA dependence](https://www.datasom.co.kr/news/articleView.html?idxno=210416)
- Electronics News, [Anthropic posts 107 trillion won first-half net loss despite 1500% revenue surge](https://www.etnews.com/20261021000007)
- News Today, [JB Financial Group takes 2% stake in Upstage; AX strategy puts the emphasis on "investment"](https://www.news2day.co.kr/article/20261020500371)
