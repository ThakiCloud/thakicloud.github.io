---
title: "The Day the Chip Took a Loan"
excerpt: "Amazon is reviewing a structure in which it sells $8 billion of chips and leases them back. The BIS warns on circular financing, and the physical world has a 159-trillion-won investment stalled at its door. The duality of capital that today's news shows."
lang: en
canonical_url: https://thakicloud.com/tech-blog/en/news/chip-took-a-loan/
seo_title: "Chip Leasing and Sale-and-Leaseback, the BIS Circular Financing Warning, and How to Read AI Infrastructure Balance Sheets"
seo_description: "Big Tech's AI capex is moving off the balance sheet through chip leasing, asset-collateralized loans, and sale-and-leaseback. We analyze the circular financing risk the Bank for International Settlements has pointed to, and the preparations an enterprise running agents should make, from today's news."
date: 2026-10-05
last_modified_at: 2026-10-05
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

## Sell and Lease Back

Imagine a scene that would have been hard to imagine a decade ago. A giant enterprise buys $8 billion of the latest chips, resells them to a purpose-built special-purpose vehicle, and then leases them back as they are. The SPV issues bonds to outside investors to fund the chip purchase, and the original owner keeps using the chips while paying rent. According to Chosun Ilbo, Amazon is reviewing exactly this structure, a sale-and-leaseback, for Nvidia Grace Blackwell chips.

It should be read as a signal of distress from the balance sheet. It is not a spectacle. Amazon expects capital spending this year, including AI infrastructure, at $220 billion. Q2 capex alone was $54.2 billion, up 68% from a year earlier. Free cash flow over the trailing twelve months has turned to negative $7.6 billion, and long-term borrowings have grown from $65.6 billion to $119.1 billion in a single year. This is the moment when cash on hand can no longer push the AI race further, and the enterprise is devising a way to buy time with the capital markets.

Why can it not stop and keep building? The answer is the fear of falling behind. Holding investment while competitors add capacity is the same as giving up the next round. So an enterprise that can no longer afford things with its own cash devises a structure in which it uses what it does not own.

The appeal of this structure is that it secures the continuity of investment without holding the asset directly. The debt is passed on to the SPV's bonds, and the enterprise only bears the cost of operation. This technique started with data center buildings and power infrastructure, and has widened to servers and semiconductors. The phrase debt off-balance-sheeting summarizes the situation precisely. The funding an asset requires has moved outside the enterprise's balance sheet.

## From Data Centers to Chips: How the Full Stack Becomes a Financial Product

Broadcom is teaming with Wall Street financial firms to push a $60 billion financing package that supports chip purchases by AI companies such as Anthropic, and it includes chip lease loans of up to $42 billion for Anthropic. Apollo and Blackstone raised $35 to $36 billion in May, bought Google TPUs, and built a structure in which they lease them to Anthropic. What to watch here is that the object being bought is Google's TPU. The fund an asset manager has raised is becoming the supplier, not the cloud operator. Even Nvidia carries a structure with $279 billion in supply commitments related to AI cloud and data center partners, with collateral obligations limited to $108.5 billion, and is pulling in more than $500 billion of outside capital together with six asset managers and banks.

The scale of these numbers must be held onto. The cumulative AI infrastructure investment of the major hyperscalers is expected to approach $9 trillion by 2031. The collateral is the credit of bond and fund investors, not the cash of a few companies. It is the substance of financial assets mortgaged against the future of AI.

Follow this chain and a single picture comes out. The yield demand of the bond market becomes the end consumer, not the cash of the cloud company. The character of AI compute has changed. The price of chips, the speed of data center construction, the supply terms of compute, all of it must be read as financial variables. The chip was once the inventory of the company that bought it. It has now become collateral in the capital markets. And the side that structurally carries the risk of aging is the investor.

Put another way, the narrative of AI infrastructure has changed. In the past, the story began with a certain company building a data center. Now it begins with a certain fund issuing bonds. The investor becomes the actor, not the operator. Whether that structure succeeds or fails is entrusted to the credit judgment of bond investors.

## The BIS Warning: Circular Financing

The most important sentence in this article is the warning from the Bank for International Settlements, the BIS. The BIS has pointed to the state in which more than half of the funding of 1,246 AI companies flows in from other AI companies as circular financing. It is a structure in which the AI industry buys the AI industry and invests in the AI industry. The BIS warned that if the AI bubble collapses, this risk could transmit to the financial market as a whole, to banks and private equity funds.

Go one step further and the shape of this circulation is more curious. A chip maker's financing package backs the purchase of its own chips by an AI company, and the investment firm buys that chip and leases it to the same AI company. In a structure where the seller lends money to the buyer, the buyer's revenue comes back to the seller. If a structure like this can inflate the revenue that has served as evidence of demand, it becomes hard to separate how much of the AI market's growth is real usage and how much is the circulation of capital.

At the same time, the credit market has been placed in a position where it must evaluate AI hardware itself. The question for the banks and funds taking chips as collateral changes from is this company's credit good to how long will this generation of chips hold their value. The credit rating of the chip collateral moves with how quickly model technology moves to the next generation. That is the moment when the risk of the technology cycle is translated into the risk of the financial cycle.

From the perspective of an enterprise that uses AI, it is worth chewing over what this warning means. Credit spreads and refinancing terms determine the price, not supply and demand. If the compute on which agents run is funded with someone else's money, then execution cost has become a market variable.

There is one more, more subtle problem. In a structure that does not hold the asset directly, it is hard to see how much actual demand there is. The balance sheet can look healthy while physical demand is thinner than that. This is the body of the transparency debate around debt-off-balance-sheet financial engineering, and the lesson it leaves is clear. The standard of actual demand and execution economics is what matters, not financial disclosure. Judgment on AI infrastructure must be made on that standard.

## The Other Half of the Paradox: Capital Stopped at the Fence

A different article from the same day makes an interesting contrast here. According to Global Economic, data center investment of $42 billion in Europe and $77 billion in the United States, about $119 billion combined, roughly 159.9 trillion won, is being delayed or put in danger of collapse by local residents' opposition. In Europe alone, more than 70 data center projects were rejected or restricted from January to April, breaking last year's annual record in four months. Scotland has suspended new approvals for hyperscale data centers, Denmark has passed an emergency law pushing power grid connections to the back of the line, and Spain has proposed a rule requiring 80% of power to be procured from renewable energy. In Geumcheon-gu, Seoul, the residents' assembly over the data center site has continued into its 172nd day as of mid-August.

The reasons for the opposition are not far away. Enormous power consumption, water use, and the worry of rising electricity bills fall directly on the local community, and some researchers call the data center a ghost warehouse that consumes resources in bulk and loads the community. Major operators such as Equinix also warn that the policy environment in some markets has become tougher and that, unlike in the past, they can no longer avoid strict scrutiny. The landing of capital itself has now become a variable.

In Korea, the same logic is running one step ahead. According to a survey by the Korea Data Center Alliance carried by The Economist, 74.77% of operating private data centers are in the metropolitan area, but 75% of new projects at the planning stage are outside it. As the difficulty of securing large-capacity power in the metropolitan area rises, the center of the AIDC bidding war is moving to regions with good grid access.

Set the two news items side by side and today's paradox becomes sharp. On one side, the capital market is inventing new financial products to bring the money in. On the other side, the physical world is blocking the landing of that capital with land, power, and social agreement. Location and social agreement become the decisive variables, not capital. Meanwhile, the ingenuity of financial engineering is concentrating only on the structure of that capital.

And the weakest link in this structure is the chips that have become collateral. The chip is not a building. It is an asset whose value drops quickly once a new generation arrives. If the value of the collateralized chips is cut sharply by a new-generation swap, whose share does that loss become? In a sale-and-leaseback structure, this question passes to the outside investor. The risk of the AI race is distributed into the financial market, and its cost is transferred to the side that uses compute. That is the moment this structure is complete.

## What an Enterprise Must Prepare

Even a year ago, compute cost was a budget issue of the IT department. But now that agents have started performing work, it is becoming a financial variable that moves every month. Is the balance sheet of AI infrastructure that today's news showed a direct signal to the enterprise that operates agents?

So what does this news actually say to the enterprise that runs agents?

First, stop making decisions on the premise that compute will keep getting cheaper and faster. If the supply side of compute is a balance sheet with raised leverage, execution cost becomes a volatile variable that moves with the credit cycle. If the bubble debate flares upstream, that shock can pass through to compute prices and contract terms.

Second, judge on the standard of actual demand. Whether a specific job truly needs top-grade chips and large context is a question that must be verified in one's own execution environment, not in someone else's balance sheet. And even if the bubble debate materializes, the shock will likely arrive quietly not as a crash in chip prices but in the form of longer lead times, more complex contract clauses, or price re-negotiation.

Third, secure visibility into what the enterprise itself is executing. Which model is used for which job, what it costs, who executed what. Once the outside market starts pricing even the chip as a financial product, the only stable price an enterprise has left is the one it controls on its own in its own execution environment.

To sum up, the cost of executing AI is decided in someone else's capital market, but the quality of execution is decided inside one's own company. How to manage the gap between the two is the real question today's news leaves the enterprise with.

## In a Market Where Even the Chip Takes a Loan, What an Enterprise Can Hold

Once compute cost becomes a market variable, the focus of the question given to the enterprise changes. It is becoming not which cloud is cheapest, but which controls remain in my hands.

ThakiCloud's Agent-Native Cloud, Paxis, is the lens that reads this question. In Paxis, Skills, Tools, Policies, and Audit Logs are treated as first-class resources. The agent's autonomy is set per task from L0 to L3, and risky execution passes through policy gates inside an isolated sandbox and leaves a record in the audit log. CostRouter's per-task model selection manages the compute cost of individual work, and running on a sovereign or on-prem K8s cluster also answers the question of the structure of someone else's money itself.

In an era where even the chip takes a loan, the enterprise's execution environment becomes not a cost item but an alternative asset.

## References

This post was written by synthesizing the following news.

- Global Economic, [159조 원 쏟아부은 AI 데이터센터, 지역과 주민 저항에 멈춰선 내막](https://www.g-enews.com/view.php?ud=20261004095959772fda4f5ab74_1)
- The Economist, [땅만 있다고 못 짓는다…전력 따라 달라지는 AIDC ‘명당’](https://economist.co.kr/article/view/ecn202609220054)
- Chosun Ilbo, [칩 리스·자산담보 대출...AI 투자 폭주에 ‘빅테크 금융공학’ 총동원](https://www.chosun.com/economy/tech_it/2026/10/05/7PQP3B4PRZF5FO3PEI35ZF4YDQ/?utm_source=naver&utm_medium=referral&utm_campaign=naver-news)
