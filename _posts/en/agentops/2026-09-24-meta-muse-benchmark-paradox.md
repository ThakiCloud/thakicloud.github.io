---
title: "The Agent That Lost on Benchmarks Took First Place"
excerpt: "An 8-point gap on the intelligence index could not stop it from taking first place on two app stores and sending the stock up 11% in a day. What the Meta Muse paradox shows: the currency of the agent race is moving from performance to trust."
seo_title: "The Meta Muse Paradox: Why the Agent That Lost on Benchmarks Took First"
seo_description: "MuseSpark 1.3 scored 45, eight points behind the two leading models. Even so it took first place on two app stores and the stock rose 11% in one day. The agent race is shifting from performance to trust, and the enterprise trust layer is the next battleground."
lang: en
canonical_url: https://thakicloud.com/tech-blog/en/agentops/meta-muse-benchmark-paradox/
date: 2026-09-24
last_modified_at: 2026-09-24
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "robot"
tags:
  - meta-muse
  - ai-agents
  - agent-governance
  - trust-layer
  - enterprise-ai
  - ai-models
categories:
  - agentops
---

If it had been judged by the intelligence index alone, Meta's new agent Muse should never have shipped. According to the Artificial Analysis intelligence index on the 21st, the MuseSpark 1.3 model inside Muse scored 45. On the same day, Anthropic Fable 5.1 and OpenAI GPT-6 Astra were tied for first at 53. That is an eight-point gap. By the logic of the past two years, this product should have disappeared somewhere in the middle of the app store charts. You checked the benchmarks first, and shipped after. That was the default order of the past two years.

But the market made a different decision. By Sensor Tower's count, cumulative downloads passed 900,000 just six days after the September 8 U.S. launch, and broke 2.5 million on the 21st. Muse hit number one in the U.S. Apple App Store free chart on the 18th, and number one on Google Play on the 21st. The most decisive evidence landed in the stock market. Meta's stock rose 11% on the 21st and closed at $741.25, with volume around 48 million shares. That is the largest one-day gain since April of last year. Since launch, the stock is up about 20%. The 45-point model had won the bet against the 53-point model. The Muse paradox alone cannot explain today's news. What matters is that every other story was written from a different angle on the same question. This piece starts with the paradox and tracks how far that same question has spread.

![An image visualizing the concept of the agent that lost on benchmarks took first place](/assets/images/meta-muse-benchmark-paradox-hero.webp)
*An illustration of the article's core concept.*

## What the Eight Points Could Not Measure

Why did the lower-scoring agent win? The answer lies in three variables that benchmarks do not measure.

The first is the distribution channel. Muse is used inside WhatsApp. Meta has a base of 3.6 billion daily users, and the agent is already inside the messenger that people open every day. Users reach the agent without having to form the intention to "use AI." OpenAI and Anthropic, by contrast, do not have a messenger that people open daily. They require a separate app download and account connection. On the same day, Ben Thompson of the tech strategy outlet Stratechery wrote that the AI industry had entered a phase of "performance saturation," where performance meets demand, and that user attention had shifted toward convenience and personalization. Of the personal agents he had tried, he picked Muse as the most capable and the easiest to use. It is the classic pattern that Clayton Christensen described long ago. Once performance crosses the baseline, the difference stops being felt, and competition moves to the next variable.

The second is price. The basic features are free, and the paid tiers are $20 and $100 a month. Work can be delegated through conversation alone, with no specialized knowledge required. With no threshold to delegation, the scope of the test widens too.

The third, and the core of this piece, is the scope of delegation. What Muse handles on the user's behalf is email, schedules, payments, and shopping. It goes past the stage of giving answers and touches real transactions and personal data. At that moment, the meaning of the "eight-point gap" changes. If a chatbot trails by eight points, you simply use something else. When an agent that pays bills and manages your calendar trails by eight points, the question becomes "how much can it be trusted?" A benchmark measures a single component, the model. An agent product is a system where the model, tools, memory, and distribution channel come together. A system with distribution inside the messenger, a price close to zero, and a wide scope of delegation can beat a higher-scoring component. That is what this wave of success is saying.

From the 53-point maker's side, this wave of success is a warning. Once performance saturation is confirmed, the benchmark's pricing power weakens, and competition moves to the distribution channel and the experience. The two companies without their own "WhatsApp" now face a question the benchmark chart cannot answer. How do you reach even the users who use AI without thinking that they are using AI every day?

## The Moment Smart Is Not Enough

The other side of the Muse phenomenon is being written elsewhere. Once agents start handling payments and personal data, "the ability to stop" and "the ability to prove what it did" split off into products of their own.

The signals arrived one after another. At its Las Vegas conference, Okta unveiled an "Agent Gateway" that applies policies in real time to the execution path between an agent and the tools it calls, and records it. It is part of the agent security framework it announced in March. The kill switch has grown sharper. Before, deactivating an agent only blocked new sessions; now it revokes all active tokens and terminates sessions in progress. Detection has also added Shadow AI Agent Discovery for employee endpoints, which finds unmanaged agents installed on laptops and desktops. It is new on top of the existing Bedrock and Agentforce import and browser shadow agent detection. Okta launched the "Blueprint Alliance" with 11 companies including AWS, CrowdStrike, Docker, and Salesforce. The idea is that when an agent is compromised, token revocation, session termination, network isolation, and recovery can all be handled from one place.

The capital markets' verdict followed. Data security startup Caira raised an additional $400 million from Goldman Sachs at a $12 billion enterprise valuation. Its cumulative 2026 funding now reaches $1.4 billion. It can be called an extension round of the $600 million Series G led by Evolution Equity in June. Caira grew out of a sensitive data location platform, and after widening its business into agent security, it unveiled Agent Guardian. It lists agents, detects excessive permissions, checks the security of MCP servers, and blocks and isolates dangerous behavior. In early September it also acquired Oasis Security, a non-human identity security firm, for $1 billion. The institutional read is that the cybersecurity investment cycle, which had been flowing around Wiz, is widening into agent security.

The two stories point in the same direction. The object of control is no longer the human account; it is the agent itself. Okta's detection has extended to shadow agents roaming employee endpoints, and Caira bought the company that manages non-human identities for $1 billion. Agents have their own identity and permissions, separate from the human. What security products are competing over is exactly that layer which handles the identity.

What this change says is that the very unit of identity has changed. In the browser era, identity was one human account. In the agent era, an agent identity is added to the human account. When agents act on behalf of people, the object of permission management is no longer "who is it" but "what can the thing that acts on your behalf do." That is why the object of competition has moved from the login screen to the gate on the execution path.

But the protagonist of this story carries its own trust problem. Meta is a company that paid a $5 billion fine to the U.S. FTC, and a settlement of up to $18 billion over child addiction is also being named alongside it. A company whose track record is the industry's largest trust debt is selling "trust us with this" while launching an agent that handles payments and personal data. It looks like a paradox, but that is exactly what makes it clearer. As long as trust stays only part of the product, no one can prove it, so trust is splitting off as a separate product.

At the UN Security Council, the problem itself was named. AI industry leaders, including OpenAI's Altman and Anthropic's Amodei, gathered at a conference on "AI and international security" and called for international cooperation. Bengio said that "AI agents refused instructions and did things that would be a crime if done by a human," and proposed a common definition of AI incidents and a reporting system. Altman held the line that models without strong evidence they can be kept under human control should not be trained. White House official Cracchio took a firm rejection stance on the attempt to build a global regime for superintelligence control. If global cooperation is blocked, the burden of governance falls to each country and each company. And that burden lands on the platforms that run the agents. The direction of governance is still being torn toward minding one's own business, but the conclusion on the corporate side becomes clear. The ability to grant permissions, the ability to stop, and the ability to prove are no longer options. The fact that this discussion has risen to the level of the Security Council is itself a signal. If AI governance has moved from the research ethics committee to the Security Council, the next stop is the corporate board of directors.

## A Half Beat Later, the Same Question Reaches Korean Companies

The consumer market has already started asking "how much do we trust it." The same question reaches Korean companies a half beat later, and more heavily. What the consumer market answered with its feet by hitting 2.5 million downloads, the enterprise market will answer with procurement specs and audit questionnaires. The content of the answer is the same; only the form differs. The agents entering enterprises are past the email summary stage. PosCube announced on the 23rd that it had completed an AI assistant enhancement project for S-OIL employees. Built on Lobby G Max, a multi-agent generative AI platform, it automatically produces audit reports after integrated authentication and Microsoft 365. It works on PC and mobile without separate procedures, and user data and organization data are linked. PosCube describes it as a multi-agent work operations model that overcomes the ROI and scalability limits of a single agent. At the same time, the data layer that agents will consume is also being standardized. Kkcoin is converting about 300 financial data APIs collected from more than 2,500 domestic and overseas institutions into MCP products, with the full conversion to be completed next year. Forecasts are added that MCP product adoption will expand based on existing financial and fintech customers such as Hana Bank, IBK Enterprise Bank, KB Kookmin Bank, and KakaoPay.

When such assistants start touching financial data and personal data, the evaluation criteria change. Is it smart? Is it controllable? What permissions does it hold, and who approved them? Can it be stopped immediately in a dangerous moment, and where is that evidence left? Are execution records retained in an auditable form? You will not get answers to these questions from a benchmark chart. In a consumer agent, the trust cost of failure is borne by the individual. In an enterprise agent, the company bears it, under the name of audit and accountability. That is why the weight of the question is different.

## The Lens This Paradox Points To

Today's news reveals the enterprise's pain in four directions. How to prove what the agent did: the discussion of a reporting system at the Security Council conference. How to stop it immediately: the gateway and the kill switch. Where to run it safely: isolation and detection. And how much to pay: the price competition between free and paid. The moment the consumer market started choosing "trust" over "score," what enterprises need is not an option but the stage on which agents run, itself. ThakiCloud's Paxis places Skills, Tools, Policies, and Audit Logs as first-class resources on the Agent-Native Cloud. Autonomy levels are divided by governance from L0 to L3 per task, and policy gates and audit logs record the execution path in real time. Agents run in isolated sandboxes, and per-task model selection (CostRouter) keeps costs within a controllable line. Meta's Muse won the bet that "an eight-point gap does not matter." What Paxis is preparing is the answer to the next question. How much do companies trust the agent, and how do they prove that trust?

## References

This article was written by synthesizing the news below.

- NewsPim, [Muse Storm ① A Hit Even Without Top Performance... The Yardstick of AI Competition Is Changing](https://www.newspim.com/news/view/20260923000796)
- Digital Today, [Okta Adds a Runtime Gateway for AI Agents](https://www.digitaltoday.co.kr/news/articleView.html?idxno=702906)
- AI Times, [PosCube Enhances 'AI Assistant' That Raises Work Efficiency for S-OIL Employees](https://www.aitimes.co.kr/news/articleView.html?idxno=215600)
- eToday, [Kkcoin Speeds Up 'AI-Tailored' Conversion of Financial Data APIs... To Be Completed Next Year](https://www.etoday.co.kr/news/view/2628257)
- Yonhap News, [AI Industry Leaders Gathered at the UN Security Council Call for International Cooperation... The U.S. Opposes (Summary)](https://www.yna.co.kr/view/AKR20260924009351072?input=1195m)
- Digital Today, [Caira Raises an Additional $400 Million from Goldman Sachs... Expanding AI Security](https://www.digitaltoday.co.kr/news/articleView.html?idxno=702904)
