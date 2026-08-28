---
title: "GPU money has split in two: the side that guaranteed demand, the side that guarantees chips"
excerpt: "In the week it was reported that Nvidia paused the revenue-sharing financing program it introduced in July, 3.08 trillion won went into SK Horizon, the Korean datacenter entity, and GPU financing of up to 400 billion won was pushed forward. Money is moving in two directions, and the price and stability of a company's compute are decided by which direction it stands on."
seo_title: "GPU money has split in two: the side that guaranteed demand, the side that guarantees chips - Thaki Cloud"
seo_description: "Nvidia's temporary pause of its neocloud revenue-sharing deals, SK Horizon's 3.08 trillion won raise, and Vesel AI's 400 billion won GPU financing. Today's news takes up what the two directions of GPU capital mean and the question a company should ask: whose name is the money running the agents under."
date: 2026-08-28
last_modified_at: 2026-08-28
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "robot"
tags:
  - gpu-financing
  - nvidia
  - sk-horizon
  - ai-datacenter
  - neocloud
  - sovereign-ai
  - agentops
categories:
  - news
lang: en
canonical_url: https://thakicloud.com/tech-blog/en/news/gpu-money-two-directions/
---

This morning's news page had two numbers moving more than any others. Both are about money, but one line was erased and one line was written. The erased line was in dollars and the written line in won. They look like two separate stories, but read together they point to one fact: the structure of the capital that holds up GPUs is being redrawn, and the direction has split in two. This post looks at the erased line, the written line, and the line that has started to borrow in between, and then picks up one question that this capital reshuffle poses for the company running agents.

![An image visualizing the concept behind "GPU money has split in two: the side that guaranteed demand, the side that guarantees chips"](/assets/images/gpu-money-two-directions-hero.webp)
*The core concept of the post, visualized.*

## The erased line: the week the chip seller tried to become the lender

According to the Wall Street Journal's report on the 27th, Nvidia paused part of the "GPU loan guarantee and cloud revenue sharing" financing program it introduced in July. Less than two months from launch to pause. The structure was simple and aggressive. Neocloud companies could not raise GPU loans in the hundreds of billions of won on their own credit, so Nvidia stepped in and guaranteed the minimum utilization of the deployed GPUs. In return it took part of the cloud revenue and a right to lease back the unsold capacity. The chip supplier would be lender of last resort, equity holder, and demand guarantor at the same time. Deals have actually closed on this model. Sharon AI in Australia put 40,000 GPUs over six years on this financing, and Permastek Technologies in Batam, Indonesia put up to 170,000 GPUs on a 360MW site. Scales that were impossible on their own credit without Nvidia's guarantee.

By the WSJ's account, worry was raised inside Nvidia too that the structure could draw antitrust scrutiny. The points in question are three: securing the lease-back right on unsold capacity, renting chips only to approved targets, and trying to allocate capacity to many small AI companies instead of one big customer. Nvidia's official position is that the financing model remains valid and keeps evolving with demand. It is an adjustment, not a full withdrawal.

The money did not dry up either. Revenue for the quarter from May to July was $96.22 billion, more than double the year before and above Wall Street consensus of $92.27 billion. Datacenter revenue was about $89 billion, up 117% year over year, and guidance for the next quarter is about $108 billion. This pause is a measure managing two things, regulatory risk and control over supply, not a growth problem. The reports say a $500 billion capital pool built with BlackRock, Blackstone, KKR, Apollo, Brookfield, and Goldman Sachs sits behind it, and criticism was growing over the circular financing centered on CoreWeave's $35 billion total debt.

## The written line: the week private equity entered the datacenter

On the other side, the pen moved. According to M2Daily's report on the 28th, SK Telecom is splitting SK Broadband into the surviving company SK Telecom and the new company SK Horizon. What moves into SK Horizon are the datacenter, CDN, and submarine cable businesses. The split ratio is 83.51 to 16.49, and the split effective date is February 1, 2027. A consortium of KKR, IMM Investment, and Stonebridge Capital puts in a total of 3.08 trillion won. Existing shares are sold for 1.8811 trillion won, new shares are issued for 1.2 trillion won, and SK Telecom keeps control at 51%.

What the 3.08 trillion won buys is not new datacenters under construction. SK Horizon takes in 318MW of infrastructure: 8 datacenters already in operation plus the Ulsan 103MW and Guro 75MW AIDCs under construction. Behind that stands SK Telecom's roadmap of 5GW by 2029 and 15GW by 2035. SK Hyper, set up in July, is dedicated to new GW-scale development, a three-company structure. The IB industry reads the deal not as a bet on one new asset but as an "AI digital infrastructure platform" investment that catches the cash flow of the existing 8 centers and the upside of the new AIDCs at the same time. About 61% of the 3.08 trillion won is cashed out through the existing share sale, and about 39% goes into SK Horizon as growth capital. Securities houses also came out with "buy" opinions, citing stronger execution in the AIDC business and a base for medium- and long-term growth. There is one way to read it: a top domestic carrier entering GW-scale AI infrastructure buildout with outside capital means the datacenter has crossed from a carrier's side business to an independent large-scale capital business.

Parallel signals moved in the same week. According to Yonhap Infomax, the Shinsegae Group set up two new-business entities, SSG AI KOREA and SSG AI DC, dedicated to AI investment and the datacenter business. In March it had signed an MOU with ReflectionAI in the US for a 250MW Korean sovereign AI factory. Within one week, Korean companies are naming AI infrastructure entities and pulling in outside capital, the scenes overlapping. In the same week, the HBM supply chain is being redrawn on the sovereign axis as well. According to the Segye Ilbo, SK Hynix held the groundbreaking for its first US HBM advanced packaging fab in West Lafayette, Indiana. The investment is about $4 billion, and the target is mass production of 7th-generation HBM in the second half of 2029. Korean chip capital is starting to write a new line on US soil too.

## The third line: the side that borrows against GPUs

The direction money moves is not only at giant scale. According to TheBell, Vesel AI is pushing a GPU financing of up to 400 billion won. The structure is to buy GPUs with outside money and pay investors from operating returns. The GPU orders have already gone out. Vesel AI launched Vesel Cloud in February, bundling the idle, short-term-leased GPUs scattered around the world into "fluid computing" and automatically allocating them to customer conditions within an average of 5 days. Supply prices are said to run 50% to 80% cheaper than hyperscalers. It has secured about 7,500 units so far, with targets of 10,000 by the end of this year and 50,000 by next year. Direct buildout is about half, the rest is mobilization, and the stage for direct buildout is Korea, where datacenter reliability is high. In between, it is pushing Nvidia cloud partner certification, was selected for the Nvidia Inception program, and made the World Economic Forum Technology Pioneer 2026 list. The typical order for a small neocloud to get a foot in the ecosystem and call in capital.

The background is bigger. According to reports, the government is pushing a loan structure of up to more than 2 trillion won, on top of the initial equity, with policy finance and project finance in the national AI computing center CORE project, and SK Group has forecast 1 quadrillion won and 3 million GPUs of investment under a circular strategy of buying GPUs again with HBM profits and selling AI compute. Against that, the 400 billion won deal of a small neocloud is no small line. But the risk is in the same ledger. As GPU-collateral financing grows, over-leveraged investment and PF repayment risk can transfer to the domestic cloud market too, and the line that separates success from failure is one: whether the operator standing in that place has a verifiable long-term demand in the form of token consumption.

## The sentence both directions of money share

Erased, written, borrowed. Three different stories, but they share one sentence: all the compute a company runs its AI on is someone's money. Whose name that money is under, on what terms, and until when it is tied decide the price and stability of the next compute. If Nvidia changes supply terms, neocloud refinancing wobbles, and that wobble moves into the bill of companies using GPUaaS. On the other hand, when PE funds enter the datacenter itself, the cost and supply cycle of domestic capacity change. The same "compute" stands on different money. And that is no longer a far story for companies. iNews24 reports that the US is reviewing extra tariffs on imported semiconductors, servers, and laptops, and discussing tariff exemptions tied to the size of foreign companies' investment in the US. In January, a 25% extra tariff proclamation on some advanced AI chips imported to the US and then re-exported was already signed. The hardware that runs agents is no longer a neutral object. Another signal runs in the same direction. According to Yonhap News, Nvidia is expanding supply of GPUs optimized for running China's AI while acknowledging the US export-control risk at the same time. It is the week the path the chips flow on became a regulatory variable itself.

On the 27th, KBS reported that about 120 companies including OpenAI, Anthropic, Google, Microsoft, and AWS signed an open letter. A warning that in the coming months, as model performance improves, AI-based cyberattacks will grow far more widespread and sophisticated. The letter asks model companies to provide access to the models, education, funding, and technical support to the defenders of essential infrastructure, and to set up tracking and monitoring for AI agents. Read together, the direction of the industry's unease comes into focus. It is no longer "how much compute can we get," but "whose name is that money under, can we see what it did, and can the terms be changed midway."

## The question the execution layer must answer

The direction of money is not something a company can control directly. But it can design what it climbs on top of. The honest answer to "who financed your GPU cloud?" can be "we don't know, and we have the right not to know." What sits on that compute is what the agents do. Whether a neocloud held up by vendor financing or a sovereign datacenter with private equity capital in it, what the company looks at is execution, not the financing structure. What was done, with what authority, where the boundaries were, and whether the logs remain.

ThakiCloud's Paxis is the answer to that question. The agent-native cloud, now a formal product at v1.1 GA, treats Skills, Tools, Policies, and Audit Logs as first-class resources. Autonomy is governed from L0 to L3 with policy gates and audit logs, and runs in isolated sandboxes. It connects to company systems through MCP connectors and the skill marketplace, supports sovereign and on-premises K8s deployment, and picks the model per task with CostRouter. What a company does not lose when the direction of money changes is this: the boundaries of execution, the record of audit, and price control over capacity. A financing structure that can be erased at any moment is a risk on the infrastructure side, and a company's execution layer does not need to wobble in the same shape.

The ledger is still open. Next time a line is erased or written, the question a company should ask is not "how much capacity did we get." It is "whose money is the money running the agents, and can the record be seen."

## References

This post was written by combining the news below.

- The Wall Street Journal, [Nvidia Pauses Revenue-Sharing Deals With AI Cloud Companies](https://www.wsj.com/tech/nvidia-pauses-revenue-sharing-deals-with-ai-cloud-companies-9c71454e)
- M2Daily, [SK Telecom splits the datacenter business into "SK Horizon"... raises 3.08 trillion won from KKR and IMM](https://www.autodaily.co.kr/news/articleView.html?idxno=546936)
- TheBell, [Vesel AI pushes GPU financing of up to 400 billion won](https://www.thebell.co.kr/free/content/ArticleView.asp?key=202608260915548640108248)
- Yonhap Infomax, [Shinsegae sets up "Jung Yong Jin-style" AI new-business entities first... investment and datacenter dedicated](https://news.einfomax.co.kr/news/articleView.html?idxno=4432310)
- iNews24, [US reviewing extra tariffs on semiconductors, servers, laptops](http://www.inews24.com/view/1999246)
- KBS, [120 Big Tech companies sign open letter on AI security... "the digital defense net must be rebuilt"](https://news.kbs.co.kr/news/pc/view/view.do?ncd=8648540&ref=A)
- Segye Ilbo, [SK Hynix breaks ground on US Indiana fab... to produce hundreds of thousands of 7th-generation HBM units a year](https://www.segye.com/newsView/20260828502636?OutUrl=naver)
- Yonhap News, [Nvidia optimized for running China's AI... acknowledges "US regulatory risk"](https://www.yna.co.kr/view/AKR20260828012800009?input=1195m)
