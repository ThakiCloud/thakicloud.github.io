---
title: "One side: an $895.4 billion commitment. The other: a 33% diet."
excerpt: "Anthropic's $895.4 billion (about 1,203 trillion won) computing spend commitment and Apple's 33% cut to the daily AI usage limit stood side by side on the same morning. When the spending ledger and the cutting ledger are both visible at once, 'what is one token worth' becomes the question for the whole industry."
seo_title: "One side: an $895.4 billion commitment, the other: a 33% diet | ThakiCloud"
seo_description: "Anthropic's $895.4 billion computing commitment, Apple's 33% cut to AI usage fees, and More's cost-per-token strategy with Token Factory. Analyzing the signals from the morning AI became a ledger, and answering with governance at the agent execution layer."
date: 2026-11-05
last_modified_at: 2026-11-05
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
  - agentops
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/agentops/895b-commitment-meets-33pct-diet/"
---

On the morning of November 5, opening the news digest shows two very different ledgers side by side.

One ledger reads $895.4 billion, about 1,203 trillion won. It is the computing spend commitment that AI company Anthropic, on the eve of its IPO, disclosed in its filing. The other ledger is a $200 one. It is the daily AI usage limit Apple set for its engineers. The first writes down how much to spend and the second writes down how much to cut, but both ledgers sit on the same morning of the same industry. Once spending and cutting become visible at the same time, the AI story stops being a growth-investment narrative and becomes a ledger narrative. Today I open that ledger in four places: the side that spends, the side that cuts, the side that sets the exchange rate in between, and finally the place where all of these ledgers come to rest.

![Image visualizing the concept of one side an $895.4 billion commitment, the other a 33% diet](/assets/images/895b-commitment-meets-33pct-diet-hero.webp)
*This visualizes the core concept of the post.*

## The spending ledger: a commitment is not discretionary

Anthropic's numbers are unusual in scale. As of September 30, computing spend commitments total $895.4 billion, of which $447.5 billion is scheduled to be spent through the end of 2030. Q3 revenue is $16.962 billion, roughly 12 times the prior year, and the filing also carries a plan to secure more than 3.5GW of compute this year and double it next year. Yet institutional investors are asking for the valuation to come down from $2 trillion to $1.5 to $1.6 trillion (about 2,016 to 2,151 trillion won). Blackstone assesses that it could remain at a speculative grade (BB+) even after the IPO. The same filing also reveals the start of FTC subpoena investigations over AI hacking and personal data. The commitment number and the regulatory gaze are written into the same ledger.

What matters in this number is not its size but its nature. Once capacity is locked by long-term contracts, spending becomes an obligation, not a discretion. A commitment that must be kept even as demand wavers is the present tense of the spending ledger.

The domestic ledger moves in the same direction. SKT transferred all 200,000 convertible preferred shares of US GPU cluster company Penguin Solutions to a great-granddaughter subsidiary of SK Hynix, 'AI Co.' The final sale price is $377.16 million (506.6 billion won), recovering about 1.9 times the original investment of $200 million (268.6 billion won) made in December 2024. On top of that, it is keeping the door open to selling its Anthropic holding, about 3.86 million shares (carrying value 3,505 billion won, a 0.2% stake), while pushing the Ulsan AIDC on a target of coming online in the second half of 2029. SK Horizon announced it is pursuing a new data center of about 180MW in Ulsan and Seoul, with a plan to grow capacity from 137MW to more than 318MW after 2030. In the same Q3 results, while AI data center revenue reached 126.1 billion won, the gap of GPUaaS revenue falling 7.4% from the prior quarter stands out. As short-term elastic demand thins and the load shifts toward stable, long-contract workloads, Elon Musk, through SpaceX, bought mobile power generation company APR Energy for about $1 billion. It says generation capacity will grow from 850MW to more than 1.1GW, with installation and operation possible in 30 to 90 days depending on site conditions. It is a scene of GPU competition widening into a competition over 'the electricity that runs the GPUs.'

## The cutting ledger: a limit is management

While the spending ledger locks in future capacity, the cutting ledger manages present consumption. Apple lowered the daily AI usage limit for its engineers from $300 to $200, a 33.3% reduction from before. EBN reported that some departments are even considering an additional $25 cut. A large number of departments outside engineering already operate under a $100 daily limit, and employees who need more for their work must apply to senior management for an exception. Some organizations have gone so far as to recommend using low-cost or on-device models.

Yet in the same fiscal 2026, R&D costs rose 32% from the prior year. Given that AI and infrastructure spend is the main driver of the increase, this diet is not a contradiction but two lines written on the same page of the ledger at once. It is growing the spending side while cutting the per-unit price of spending.

It is not a one-time move by a single company. Per the same reporting, Microsoft is controlling its internal AI budget, Tesla applies a $200 per week limit on employee AI costs, and Uber applies a $1,500 per month limit on coding tools. The background is that tasks like coding and error fixing make high-performance models consume large amounts of tokens, so per-developer costs are especially high. The name the industry has attached to this trend is 'cost diet,' and the underlying meaning is simpler: until productivity gains are proven enough, the core is to set the scale of spending by controlling cost per token. A limit is not a budget measure. It is a management act that writes into a rule how far AI is allowed to go.

## The exchange-rate ledger: cost per token is the KPI

Between the spending side and the cutting side there is an exchange rate. It is the question of doing the same work with which model, on which chip, at what price.

Electronics News reported that at the keynote of 'AMD Advancing AI World Tour Seoul 2026,' More unveiled 'Token Factory,' a GPU-based AI inference cost-optimization strategy. Using the MoAI inference framework to run the latest open-source models on AMD Instinct MI355X achieved more than 2x throughput versus NVIDIA B200, and heterogeneous distributed inference that processes the prompt on an NVIDIA GPU and generates the response on an AMD GPU recorded about 1.7x throughput compared with a homogeneous cluster. The report added that it develops every layer, from kernels to inference engines to cluster-wide distributed inference, and contributes to open-source projects such as ROCm, vLLM, and SGLang.

The shift the report points out is clear. As data center business transitions into Token Factories that produce AI tokens, the yardstick of competition is moving from GPU holdings to cost per token. A new open-source model comes out almost every month, and optimization differs across GPUs of different generations and vendors, so a business without large-scale specialized engineering capacity has difficulty filling that gap on its own. AMD has even previewed building a proof-of-concept cluster in Seoul next year. It looks as if a second supplier has entered the side that lowers the 'exchange rate.'

The language of the exchange rate is opening in the domestic ledger too. SKT is pushing a 'Token Gate' business that connects telecom subscribers, AI models, and infrastructure, and it reportedly designated sovereign AI for public and defense sectors as the first market. At the point where the token is named as the unit of trade, the calculation of which model to use for which purpose begins to sit at the center of the business model. Cost per token has become the KPI that decides a business's margin, and inference efficiency is a product, not just an internal optimization item. When price becomes the object of trade, the technology that lowers the price also becomes the object of trade. That is why 'Token Factory' reads in today's news as the name of an industry, not the name of a company.

## The accounting ledger: when AI does 26% of the work

Where does the ledger ultimately point? The answer is again inside Anthropic's filing. According to the figures reported by Digital Today, the share of R&D work performed by AI at Anthropic jumped from 1% in March to 26% in August. The share of fully autonomous processing, however, remains 0%. Co-founder Jack Clark moved up his forecast for the realization of recursive self-improvement, RSI, to 2027, and CEO Dario Amodei urged caution, saying that if it proceeds without control it can outpace human understanding and ability to steer. OpenAI has also set a goal of developing an automated AI 'researcher' by March 2028.

The implication of this number is this. The share of AI's 'work' is growing at a speed visible on the ledger, but 'full autonomy' is still 0%. So every task needs a device that records who approved it, how much it cost, and what the evidence was, and that can be held accountable. The ledger problem is now not the finance team's spend management but an engineering problem of the execution layer where work actually happens.

Domestic sites already stand at that point. POSCO Holdings launched 'Steel-X,' an in-house document search and AI agent platform co-developed with Hyundai Evertz, on November 4. It is a structure in which employees create knowledge chatbots and agents without development knowledge, share them at the team and company level, and connect even equipment history and operational data. The four functions are the axis: turning in-house knowledge into assets, a multi-AI integration environment, an employee AI playground, and data linkage with business systems. The same day, Chosun Ilbo covered Jeil Color Tech, a 12-employee paint factory in Gumi, Gyeongsangbuk-do. Entering only the existing Excel files produces a customized production status board per factory, at a monthly subscription of 1.5 million won. Aggregation that took 15 to 30 minutes and report preparation that took an hour, with decisions slipping by a day, have become real time. In hospitals, the KLAS 2026 report found that the EHR workflow efficiency satisfaction of medical staff using AI tools is 7 percentage points higher, and a JAMA Network Open study reported that the burnout rate fell from 51.9% to 38.8% after adopting ambient AI. A diagnosis from one HIS company points the same way: the role of integrating and designing various AI into a single workflow has itself become a competitive advantage, says EasyCaretic.

## The ledger closes at the execution layer

On the morning of reading one ledger, let me look at the news again through a single lens.

The industry is answering the same ledger problem at different layers. The spending side locks in capacity by commitment, the cutting side manages by limit, and the efficiency side responds with products that lower the per-token exchange rate. One question remains: at the place where agents actually work, the execution layer, in what form will the ledger be maintained?

That layer is where ThakiCloud's agent-native cloud, Paxis, is used. Paxis is a formal product (v1.1 GA), and it is not a tool that attaches a ledger afterward. It treats skills, tools, policies, and audit logs as first-class resources in the execution environment itself. The limit Apple set per person becomes, in Paxis, a policy gate that is applied automatically per task. Autonomy (L0 to L3) governance sets the boundary of how far an agent can go on its own, and when the token exchange rate changes, per-task model selection (CostRouter) picks the model that matches the work in cost and performance. If Anthropic's R&D share has risen to 26%, then every one of those 26% of tasks must be executed in an isolated sandbox and remain in the audit log. The basis for approval and the result must always be traceable. MCP connectors and the skill market, along with sovereign and on-premises K8s (ai-platform) deployment options, are the door for customers who must keep the ledger inside a closed network.

What the morning of two ledgers side by side tells us is this. The competition in an age where AI has become a ledger is not between the company that spends more and the company that cuts more. It is also a competition between places that have an execution layer that can count each task, each token, each approval, and keep that record. The ledger has already arrived at steel mills and hospital sites. One choice remains: will you write that ledger by hand, or will the execution environment itself become the accountant?

## References

This post is a synthesis of the news below.

- Electronics News, [More supports GPU-based AI inference cost optimization with 'Token Factory'](https://www.etnews.com/20261105000012)
- Money Today TV, [SKT targets Ulsan AIDC to come online in the second half of 2029... possibility of selling its Anthropic stake](https://news.mtn.co.kr/article/2026110417000810970)
- Asia Economy, [The limits of iPhone Siri AI... useless against KakaoTalk and Naver](https://view.asiae.co.kr/article/2026110316563510299)
- Money Today, [Building the 'world' robots will learn from... a Korean 3D company that caught NVIDIA's eye](https://www.mt.co.kr/future/2026-11-05/2026102016523357821)
- Vegan News, [POSCO Holdings opens its in-house document search and AI agent platform](https://www.vegannews.co.kr/news/article.html?no=400735)
- Electronics News, [[AI Hospital Insight] Beyond AI connection, toward integrating hospital work](https://www.etnews.com/20261104000486)
- CBC News, [[Entrepreneur] Anthropic ② | A mega IPO is near... astronomical infrastructure investment and regulation](https://www.cbci.co.kr/news/articleView.html?idxno=623195)
- The Bell, [[The Bell] SKT transfers all of its Penguin Solutions stake in an 'AI investment restructuring'](https://www.thebell.co.kr/free/content/ArticleView.asp?key=202611031058378560107271)
- eScience, [Elon Musk buys a power company amid the AI power shortage... a competition to secure electricity beyond GPU](https://www.e-science.co.kr/news/articleView.html?idxno=138510)
- EBN, [Apple urges AI expansion but cuts employee usage fees by 33%... Big Tech's 'cost diet'](https://www.ebn.co.kr/news/articleView.html?idxno=1730513)
- CEO Score Daily, [SKT sheds its 'hacking nightmare' after a year... subscribers and performance return to normal, AI infrastructure](https://www.ceoscoredaily.com/page/view/2026110413003093182)
