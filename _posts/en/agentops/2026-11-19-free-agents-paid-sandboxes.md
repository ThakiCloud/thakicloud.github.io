---
title: "Free Agents and Paid Sandboxes"
excerpt: "The day Google opened Gemini's 'Tasks' to hundreds of millions of users for free, the companies in the same digest were paying for isolated sandboxes, confirmation procedures, audit logs, and model routing. The moment agents become free, the axis of competition moves to the execution environment."
seo_title: "Gemini 'Tasks' goes free; the cost of agents lives in the execution environment"
seo_description: "Google opened its agent feature 'Tasks' to hundreds of millions of users in six countries for free. On the day per-user hardware-isolated sandboxes and confirmation steps for sensitive actions became the standard, this post analyzes how enterprise news now lists safety, audit, cost, and sovereignty as line items."
date: 2026-11-19
last_modified_at: 2026-11-19
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "robot"
tags:
  - gemini-tasks
  - agent-native-cloud
  - sandbox-isolation
  - agent-governance
  - model-routing
  - sovereign-ai
  - paxis
categories:
  - agentops
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/agentops/free-agents-paid-sandboxes/"
---

This morning's change began quietly on the screen. A single toggle appeared next to 'Chat' on the home screens of hundreds of millions of devices. It is called 'Tasks'. There is no price tag attached. According to Wikitree's reporting, Google has fully opened 'Tasks', the successor to Gemini Spark that was offered on a paid basis in May, for free. The base is the Gemini 4 Hydrogen model. The toggle is already visible in the apps of six countries: the United States, Canada, Japan, South Korea, Australia, and India.

'Free for hundreds of millions' is an unusual thing in the agent industry. Over the past year, big tech has moved the front line from 'AI that chats' to 'AI that executes for you'. From Anthropic's Claude Duet to OpenAI's Dots to Meta's Muse, agents were the flagship paid feature. But today Google put no price tag on the distribution. What became free, and what did not stay free. The same day's digest lays the two side by side, clearly.

## What's Free Is the Toggle; the Value Is in the Design

In the Tasks materials, what is interesting is the design, not the features. Tasks runs in a user-account-dedicated, hardware-isolated sandbox VM on Google Cloud's 'Agent Compute Engine'. A user confirmation step is always applied before sensitive actions such as purchases. Prompt injection defense is presented as part of the standard design. The capabilities of calling businesses, comparing prices, checking inventory, and completing payment with Google Pay, along with password manager logins and triggering Tasks through external channels such as email and text messages, are open only in the United States. When an agent calls a business, it immediately discloses that it is an agent. The business can refuse. That is part of the design.

In other words, what is free is the distribution policy, and isolation, confirmation, and staged rollout are the product. Consumers get the toggle for free, but for that toggle to actually do work on their behalf, there must be an execution space separated per account, a confirmation step before sensitive actions, and a rollout order tuned to each country's regulations. The logic behind it is simple: to make users whose email, calendar, passwords, and payment cards are already in the Google ecosystem choose Gemini as their personal assistant. What this launch shows is that the question in the agent race has become not 'can you build an agent' but 'when hundreds of millions of people run agents at the same time, what do you isolate and what do you make them confirm'.

## The Same Day, Companies Bought the Execution Environment as a Line Item

Korean enterprise news follows the same axis. According to ITDonga's reporting, Upstage struck a strategic partnership with Canada's Cohere. Solar Pro and Solar Mini, and the document-processing AI Document Pass, were integrated into Cohere's enterprise agentic AI platform 'North'. Existing North customers can now pick a model immediately. The delivery model is on-premises and VPC, aimed at regulated industries and government, including finance, the public sector, and manufacturing. The two companies previewed joint development of global sovereign AI models and expansion into the Asia-Pacific region. The article's reading is that rather than insisting on a single model, the structure of a platform that selects and routes among multiple models to fit the work's characteristics is becoming the standard. For Upstage, this opens a new channel beyond existing model-supply routes such as OpenRouter, AWS Marketplace, and Hugging Face: an enterprise AI package that includes agents and workflow automation. Document Pass, specialized in processing Korean-language contracts, reports, and forms, was recognized for Cohere's localization capabilities. It is also a case that shows the global competitiveness of Korean-language document AI.

The 'Token Factory' that Women's Economic Newspaper reported on from KT is in the same direction. KT shifted its center of gravity from its own AI 'Mireum' to an intermediary platform that will connect more than 500 external models within the year. On top of model aggregation that started with 73 models, it added its first official domestic partnership with OpenRouter. Its in-house auto model router and prompt compression confirmed up to 25% cost reduction in internal experiments (compression about 20%, routing about 5%). For markets where data sovereignty is required, it holds seven models that infer directly on domestic GPUs (three developed domestically, four open-weight). The same article also confirms cumulative Q3 AX revenue of 1.1119 trillion won (up 11.9% year on year), a goal of more than doubling 2025 levels by 2028, and a plan to invest 2.2 trillion won over five years in security and IT system modernization after last year's hacking incident. Unlike the structure where global token intermediaries take about a 5% fee, KT produces inference tokens directly on its own datacenter GPUs to secure margin. It aims at a revenue model that bundles communication lines, private cloud, and AX services.

LG CNS, as reported by AP News, shows the same picture in earnings numbers. Q3 DBS (Digital Business Services) revenue was 408.2 billion won, up 21.3% year on year. That is the highest growth rate of any business line in the same period, exceeding the AI and cloud business (9.3%). The driver is agentic AI. 'PerfectWin ERP Edition', launched in June, uses an agent to auto-generate ERP test scenarios and analyze the root cause of errors. It cut work that took days to hours. It also connects to a KB Securities survey in which 75% of companies cited generative AI and 74% cited AI agents as the area for expanding IT investment.

The remark from Naver Cloud's head, Seong Nak-ho, as reported by PoliNews, compresses this axis into one sentence: what customers should ultimately buy is not GPU hours or the volume of generated text, but 'work that is finished through verification'. Starting in 2027, the focus should shift from R&D-centric to monetization-centric. The same forum also identified fields where data control and operational continuity matter, such as defense, diplomacy, and the public sector, as the early market for sovereign AI. It can be seen as the day the unit of what you buy changes, whether the model is free or there are 500 of them.

## The Value That Attaches as Numbers: Safety, Audit, Unit Price

The value of agents is starting to attach as numbers. According to HitNews reporting, OpenAI disclosed the performance of its medical computer-use agent. Of 325 electronic health record (EHR) inbox tasks processed by GPT-6 Astra, 99% were clinically safe. Of 646 physician usefulness evaluations, 93% were 'very useful' or above. On Stanford researchers' independent benchmark HealthAdminBench, the scores are 94.3% for Astra and 91.8% for Luna. What is more notable is the cost. Luna is 98% cheaper than Astra at 8.5 cents per task. CVS Health and Cigna Healthcare also disclosed cases: CVS processes tens of thousands of care-coordination tasks a day with an agent, and Cigna consolidates information scattered across more than ten systems. The core of the US cases is a structure where the AI does not intervene in final judgment but handles drafting and system navigation, securing time for medical staff. At the same time, the adoption preconditions were specified as a HIPAA-compliant environment, role-based access control, audit logs, and human approval steps. Domestically, the Ministry of Health and Welfare's 'Public Medical AI Expressway' has been in pilot operation since November 11, generating referral and return documents from EMR data.

F5 Korea's outlook, as reported by Seoul Economic, is the security side of the same picture. At a Kangnam briefing on the 18th, F5 said the span that once took weeks to months, from discovering a vulnerability to patching, verifying, and deploying, is now shortened to an average of seven days from discovery to exploitation. The same venue also made the argument that networks must be defended at the edge with a 'virtual patch' until the patch is complete. The three axes F5 named as 2027's major changes are the acceleration of AI-based attacks, the spread of sovereign AI, and the adoption of multi-model AI. In the Asia-Pacific survey, 63% of companies cited unpredictable AI and token costs as barriers to expanding use. 53% opposed the transfer of sensitive data abroad. 78% are operating their own AI inference service while using an average of seven models. F5 Korea has begun targeting game companies and IT service providers with SK Telecom, centered on the PoP (distributed cloud service hub) it newly opened in South Korea last September.

## Capital Is Waiting at the Model Layer

One more line on the background: the Anthropic IPO from Korea Economic Daily's reporting. The public offering price was set at $83 per share. Including private placements, the total size of $94 billion surpassed the $86.2 billion fundraising record SpaceX set in June. It is the first stock-market entry among cutting-edge AI model developers. Nvidia is participating in the private investment at a scale of $10 billion, and investment demand was counted at about seven times the public offering. Goldman Sachs and Morgan Stanley are the lead underwriters, with 20 banks participating. This happened during a stretch where the Nasdaq 100 had fallen 4.4% in the last week. Competitor OpenAI has no plan to list before 2027, so the stock-market race at the model layer effectively starts now.

The meaning of this number is that one of the suppliers of the tokens Korean companies use has become a listed company. The cost and supply of the model layer will now move alongside quarterly earnings. The next question is where the mechanism to buffer that volatility should sit. Execution-layer design decides the answer.

## Paxis: The Execution Layer Beyond the Free Toggle

Gathered in one line, today's news is this: agents are free, and the value has moved to isolated execution, confirmation procedures, audit, cost, and sovereignty. That is exactly where ThakiCloud's Agent-Native Cloud, Paxis, looks. As a formal product shipped at v1.1 GA, it manages Skills, Tools, Policies, and Audit Logs as first-class resources.

If Google held up individual-level hardware-isolated VMs and pre-purchase confirmation as the standard, Paxis provides enterprise-level isolated sandbox execution and autonomy with L0 to L3 governance. A policy gate sets in advance which agent moves autonomously with which skill up to what point and where it gets human approval. Every execution is recorded in an audit log. Just as North targets regulated industries with on-premises and VPC, in financial and public environments where sovereignty is at stake, this platform is installed on top of sovereign/on-premises K8s (ai-platform). On the cost axis that KT's 25% reduction experiment and Luna's 8.5 cents per task point to, there is CostRouter, which selects a model per task. When an agent is sent out to existing systems such as ERP, EHR, and payment portals, MCP connectors and the skill marketplace wire up the tools.

## What Remains Is a Matter of Korea's Share

South Korea is among the six launch countries for Tasks, so it has had the toggle since today. However, calling, payment, and login handling are US-only, so the practical value domestically is limited. While big tech sprinkles agents for free, the open space can be filled by execution services that combine domestic payment and commerce with communication infrastructure. As free distribution raises the expectation bar for agents, differentiation in work-automation services will be decided not by price competition but by trust. What became free is the toggle, and what carries the price is the execution layer that shows who did what, with what authority, and at what cost when that toggle finished the work. All of today's digest numbers attached to that layer.

## References

This post synthesizes the news below.

- Korea Economic Daily, [Anthropic sets public offering at $83 per share … $94 billion mega-IPO including private placements](https://www.mk.co.kr/article/12213212)
- ITDonga, [Upstage signs strategic partnership with Canada's Cohere](https://it.donga.com/109956/)
- Wikitree, [Gemini 'Tasks' opened for free … agent capabilities expanded](https://www.wikitree.co.kr/articles/1175745)
- PoliNews, [Naver Cloud head: "What matters is not how many GPUs but what kind of intelligence"](https://www.polinews.co.kr/news/articleView.html?idxno=748661)
- Women's Economic Newspaper, [KT to wire up 500 external models instead of its own AI 'Mireum' … customer servers become labs](https://www.womaneconomy.co.kr/news/articleView.html?idxno=261342)
- AP News, [LG CNS: the subtext of 21.3% DBS revenue growth … Hyun Shin-gyun's "reading eye" for the AI era](https://www.apnews.kr/news/articleView.html?idxno=3053296)
- HitNews, [GPT on the medical front: "overtime instead of doctors" … securing patient consultation time](https://www.hitnews.co.kr/news/articleView.html?idxno=80910)
- Seoul Economic Daily, [Patching took weeks but exploitation takes 7 days … F5: "we must defend through automation"](https://www.sedaily.com/article/20116142?ref=naver)
