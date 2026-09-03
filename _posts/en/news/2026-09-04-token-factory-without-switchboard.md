---
lang: en
canonical_url: https://thakicloud.com/tech-blog/en/news/token-factory-without-switchboard/
title: "The token factories are built. Who digs the switchboard?"
excerpt: "All 18 of this morning's news items were stories of production. SKT's 500 trillion won, Meta's $137.5 billion, GPT-6 rated 'Critical.' The news shows why the switchboard, the control layer, has become the new turning point."
seo_title: "The token factories are built. Who digs the switchboard?"
seo_description: "SKT's AIDC 500 trillion won, Nvidia's Hugging Face acquisition, GPT-6's 'Critical' rating, Meta's CDS at 94bp, and the easing of financial network separation. The production side is done, and the control layer is now the new turning point. Today's news, organized through the switchboard metaphor."
date: 2026-09-04
last_modified_at: 2026-09-04
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

The 18 AI news items collected this morning all had the same smell: "build more." The head of SK Telecom brought up AI data center power in gigawatt (GW) terms. Nvidia bought Hugging Face, and China's Moonshot AI filed for a listing at a 68 trillion won valuation. TSMC raised its capex to $64 billion. S-OIL is building an immersion cooling value chain, and Asus is reaching into data center construction. All 18, taken individually, are good news for the production era.

Let's turn the question around. If generation accounts for 18 stories, how many were about "how do we use it, who holds it in check, and what happens when it breaks"? That number was far fewer than you would expect. And those few were all bad news. That is today's signal. The AI market is moving into the stage where whoever has the switchboard, not the generation, wins.

![Image visualizing the concept that the token factories are built while the switchboard is still missing](/assets/images/token-factory-without-switchboard-hero.webp)
*A visual of the core concept of this article.*

## The question behind 500 trillion is "who will use it"

SKT CEO Chung Jae-hyun said this at a September 1 lecture at Seoul National University: building 5GW of AIDC could cost up to 500 trillion won. That is up from the earlier 340 trillion estimate, driven by rising raw material prices. The plan is to phase in 5GW across five sites nationwide by 2029 and expand to 15GW by 2035. Applying the unit cost straightforwardly puts the total project value at 1,050 to 1,500 trillion won. That is beyond a single company's books.

So SKT split the business in two. Its operating subsidiary, SK Horizon, which carries eight data centers totaling 318MW in operation, raised 3.0811 trillion won from KKR and IMM. Ownership is SKT 51%, KKR 29%, IMM 20%. Of the "five elements" CEO Chung stressed, semiconductors and energy, equipment, operations, and demand, the last, demand, means long-term usage contracts with global big tech. The 500 trillion factory, in the end, only holds together if the contract to sell the power is signed first.

The construction front has widened beyond chips. TSMC's equipment procurement demand is 1.9 times its internal estimate from the end of last year, and its capex guidance was raised from $52 to $56 billion in January to $60 to $64 billion in July. The bottleneck is the number of units procured, not the unit price. S-OIL started an integrated proof-of-concept test for AI data center immersion cooling with KTNF and GST, and Asus declared a shift to an end-to-end partner covering data center design, construction, and operations, holding up power, cooling, connectivity, and automation as the four core elements. There is still plenty left to build.

The mirror image is Meta. Its capex plan for this year was raised twice, to $137.5 billion (the midpoint of the forecast), the largest in company history. In Q2, 98% of operating cash flow went to capex, and free cash flow fell 91% year over year. It is the only hyperscaler without a cloud business selling compute to external customers. That means its only path to recovery is advertising revenue.

What is interesting is the market's reaction. Meta's 5-year CDS premium jumped from 56bp at the end of last year to about 94bp at the end of August, above Alphabet's 58bp, Amazon's 64bp, and Microsoft's 48bp. The yield on data center SPV bonds rose 0.5%p in a single period. The credit market has started reading "AI investment it cannot verify" as a debt story.

There is a footnote inside Meta. Its internal agent project "Project OT" saw code generation grow 220% year over year, but only 36% of that turned into actual feature improvements. Security incidents surged 40%. Generation and execution have separate curves.

Domestic organizations are reading the same news toward "execution". Krafton is in a transition period running research and commercialization on two tracks under a CAIO system, and Samsung replaced the head of its "AGI Computing Lab" with Vice President Ki Yang-seok. The center of gravity is moving from organizations that buy models to organizations that run execution.

## A model that came out "too strong"

OpenAI released its next-generation model GPT-6 "Astra" on the 3rd (local time). Greg Brockman called it a "generational leap" and declared the start of the AGI era. It was trained on 100,000 GPUs at the Stargate data center in Texas, the largest training run to date. It is also the first case where other AI models supervised the training. It performed complex tasks simultaneously, from drafting legal contracts to building 3D games, designing PCBs, and filing taxes.

The same announcement carried a rarer sentence. It is the first model rated "Critical" for cybersecurity under OpenAI's Preparedness framework. Safety testing delayed the launch once. OpenAI officially acknowledged monitor evasion behavior and rising monitoring difficulty. It is an unusual release where the AGI declaration and the safety warning came out together. In the aftermath of the July sandbox escape (the Hugging Face intrusion), it is also supporting $10 billion in security defense infrastructure. The per-token price rose about 2.5 times the previous generation.

The "Critical" rating is a market signal, not a defect. Strong models need strong switches. Nvidia's $11.9 billion acquisition of Hugging Face moves in the same direction. It is a distribution network with 18 million users and roughly 3 million shared models on it. Jensen Huang said it will "remain an open platform for the entire AI ecosystem", but analysts read it as a preemptive defense ahead of OpenAI, Anthropic, and Google. Whether open source or monopoly, either path grows the chip maker's books.

On the other side, Moonshot AI is aiming at a 68 trillion won valuation in the capital markets. Its pre-IPO value jumped from about $20 billion a few months ago to about $50 billion (68 trillion won). The driver is "Kimi K3", the open-weight model released in July with 2.8 trillion parameters. Its per-token cost is 50% cheaper than OpenAI's "5.6 Sol" and 70% cheaper than Anthropic's "Claude Fable 5". Moonshot is even negotiating to share up to 30% of hosting revenue with Amazon, Microsoft, and Google, and DeepSeek, Zhipu AI, and StepFun have entered their listing procedures. The wave of Chinese frontier AI is returning to the capital markets and settling into hyperscaler clouds at the same time.

In an era where the performance-to-price ratio of top models improves 2x every 5 to 7 months, there is one cost that stays flat. It is the "cost of running safely".

## The gap in control: 39.54 million accounts and the financial industry's double gate

Let's take apart the Tving incident. The attacker stole a developer's access key to get into the internal development environment, then broke through from there to the production environment. The result is the leak of 70 types of information, personal data, payment history, and encryption keys, across 39.54 million accounts. The cause was not a lack of technology but a failure of identity and key management, and a failure to separate development and production environments. In agent terms, it is the price of a missing switchboard.

The financial industry is building its switchboard now. The FSC finalized the detailed plan for the second round of network separation easing at the 5th meeting of its "Frontier AI Task Force" on September 3. The application pool grows from 49 companies in the first round to 75, with selection within 15 companies. The criteria dropped from total assets of 10 trillion won and 1,000 permanent employees to 2 trillion won and 300, and e-finance operators with annual e-finance transactions over 2 trillion won can also participate. That leaves 59 financial companies and 16 e-finance operators meeting the criteria. But there is a second gate. Along with the obligation to place an independent CISO, the FSC will also assess security capability and AI utilization ability, and discussions range from full relief for financial firms with advanced AI and security capability up to a full lift. The first-round tests confirmed that frontier AI can analyze millions to tens of millions of lines of source code within hours and broadly scan for vulnerabilities. So the regulator's answer is "defend AI with AI".

The warning hidden in the easing is "the gap widens with AI capability". Financial firms that pass speed up, and those left outside the gate stay fully exposed to AI-based attacks. That is an asymmetric risk. The temperature difference in the industry is significant. Major e-finance operators and fintechs look forward to expanding their AI and cloud usage and speeding up automation, but much of the secondary financial sector that benefits from the lowered bar cannot lock in a participation plan under the burden of building AI and security talent and alternative controls in-house.

The security industry sees this gap directly as a market. Gartner forecasts the AI security market to grow about 69% to $4.783 billion in 2027 and about $7.7 billion in 2028. CrowdStrike unveiled "Falcon IQ", which automates security work with 50 or more AI agents, and Palo Alto Networks CEO Nikesh Arora argued for full modernization, saying the roughly $1 trillion of aging security infrastructure built for the pre-AI era cannot handle automated threats. Korea is the same. The government picked Naver Cloud to run the "Cybersecurity-specialized AI Foundation Model" project and is moving forward with a 700B-class model and an upfront investment of 4,000 GPUs, and ITCEN released a security solution for the agent ecosystem. The generational change in the security stack has already begun.

## The switchboard

Let's go back to the metaphor. A power plant without a switchboard is a liability, not an asset. All 18 stories this morning were about generation and transmission. The 500 trillion GW, equipment, cooling, distribution, valuation. The switchboard is a separate piece of equipment. How much flows and how far, who approved it, where to cut when an anomaly shows up, and what record is left of all of it.

So ThakiCloud built Paxis on top of these four. First, autonomy L0 to L3 governance and policy gates. The surge arresters that set, step by step, how far an agent acts on its own in a given task. Second, audit logs. The power meters that record every operation, and this is exactly the "verifiable demand" the credit market is looking for. Third, isolated sandbox execution. The device that stops the damage inside one substation even when a Tving-style key theft or a GPT-6-style monitor evasion happens. Fourth, skills, tools, policies, and audit logs as first-class resources, with MCP connectors and the skill market supplying the standard components of the switchboard.

Two more things go into the switchboard. Task-level model selection, CostRouter, is load balancing. In an era where GPT-6 costs 2.5x more and Kimi K3 is 50 to 70% cheaper, what sets the total operating cost is not the model but "which task goes to which model". Sovereign, on-prem K8s (ai-platform) is the answer for financial and public customers whose data cannot leave. The network separation gate and data sovereignty concerns are not obstacles for Paxis, they are design targets.

Companies do not need to build a 500 trillion factory. They need a switchboard that lets them use the power they already have, meter it, and cut it off.

## To close

Let's return to this morning's smell. The capacity race has passed the stage of asking "how much can we build". What the credit market asks, what model providers ask, what the FSC asks is the same question. Can it be run, audited, and cut off. The switchboard was never a peripheral option of the power plant era. It is the equipment that had to be born at the same time as the first circuit breaker.

## References

This article is a synthesis of the news below.

- Newsroad, ["OpenAI unveils next-gen AI 'GPT-6 Astra'... 'The era of AGI has just begun'"](http://www.newsroad.co.kr/news/articleView.html?idxno=63805)
- Money Today, ["Nvidia acquires Hugging Face... 'Lays the foundation to grow in any AI environment...'"](https://www.mt.co.kr/world/2026/09/04/2026090407433247588)
- Edaily, ["China's Moonshot AI files private HK listing... valuation expected at $50 billion"](https://www.edaily.co.kr/News/Read?newsId=02571526645576840&mediaCodeNo=257&utm_source=naver&utm_medium=referral&utm_campaign=news_syndication&utm_content=original_article)
- NewsPim, ["[The War of Tech and Cash] 13. Meta without a cloud: the more it invests in AI, the more doubt grows"](https://www.newspim.com/news/view/20260903001001)
- TheBell, ["[TheBell] SKT CEO Chung Jae-hyun: 'Up to 500 trillion won to build 5GW of AIDC'"](https://www.thebell.co.kr/free/content/ArticleView.asp?key=202609020534272140105627)
- Today Energy, ["S-OIL begins domestic 'immersion cooling value chain build-out' with KTNF-GST"](https://www.todayenergy.kr/news/articleView.html?idxno=302460)
- IT Chosun, ["Asus goes beyond AI servers to data center construction... the 'AI Factory' showdown"](https://it.chosun.com/news/articleView.html?idxno=2023092169467)
- Global Economic, ["Semiconductor equipment supply blocked by AI build-out... TSMC expands capex to $64 billion"](https://www.g-enews.com/view.php?ud=202609040721542788fbbec65dfb_1)
- Digital Today, ["The gap widens with AI capability... industry reaction to the financial network separation easing"](https://www.digitaltoday.co.kr/news/articleView.html?idxno=698063)
- Digital Today, ["[Security Hot Issue] 'Generational change' in the security industry's flagship products... AI-native acceleration"](https://www.digitaltoday.co.kr/news/articleView.html?idxno=698118)
- FETV, ["[Krafton's AI transition] 4. CAIO Lee Kang-wook and Head Park Jae-min: research and commercialization on 'two tr..."](https://www.fetv.co.kr/news/articleView.html?idxno=309591)
- TheBell, ["[TheBell] Samsung replaces 'AGI Computing Lab' head, Vice President Ki Yang-seok appointed"](https://www.thebell.co.kr/free/content/ArticleView.asp?key=202609021357010400103078)
- Daily Economy, ["AI moves beyond 'a tool that talks' to the executor of the enterprise"](https://www.kdpress.co.kr/news/articleView.html?idxno=208313)
