---
title: "Two answers to the question of sovereignty: who builds it, who controls it"
excerpt: "The 99.98% NVIDIA dependence of public AI chips and Palantier's claim that 'control is sovereignty' crossed paths on the same day. In an age where agents act, the battleground of sovereignty is shifting from the nationality of the model to the boundaries of execution."
seo_title: "Sovereignty, two answers: localization and control | ThakiCloud Tech Blog"
seo_description: "Why the Ministry of Trade's domestic-priority purchasing and Palantier's control argument collided on the same day. Analyzing the questions of execution, audit, and autonomy that redefine sovereign AI in the agent era, plus four checks for enterprises."
date: 2026-10-23
last_modified_at: 2026-10-23
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "robot"
tags:
  - sovereign-ai
  - agent-governance
  - ai-chip
  - enterprise-ai
  - palantier
  - on-premise
  - agentops
categories:
  - news
lang: en
canonical_url: https://thakicloud.com/tech-blog/en/news/who-builds-who-controls-sovereign-ai/
---

![Image illustrating the two answers to the question of sovereignty: who builds it, who controls it](/assets/images/who-builds-who-controls-sovereign-ai-hero.webp)
*An image illustrating the core concept of the post.*

## Two headlines, side by side

Stack two articles from the same day and they read like a collision between two different answers. One is Seoul Economic's "99.98% of public AI chips are NVIDIA." The other is News1's account of Palantier's remarks: "You cannot secure sovereignty with domestic AI models alone, control is the core." The first is about chips, the second about decision-making power. The first is a question of who builds, the second a question of who controls. Two answers that crossed on the same day to the same question: "sovereignty."

Sovereign AI originally emerged from the recognition that dependence on global LLMs translates directly into risks such as service interruptions, policy changes, price hikes, and export controls. It means an organization or a country holds control across the entire process: data, models, infrastructure, and people. But today this concept has split into two branches in Korea. One answer asks about the nationality of the chip and the model. The other asks about decision-making power and audit. They look like different answers to the same question, but they are actually different questions. If you follow today's news from semiconductors and chips to cloud infrastructure, models and agents, and AI security, one keyword flows through both answers. Sovereignty. I think this difference is the freshest signal in today's news.

## The answer of localization: reading the 99.98% number

Let's look at the number first. From January 2024 to August of this year, 42 agencies under the Ministry of Trade, Industry and Energy bought 191 AI accelerators. The amount was 10.2876 billion won. Of that, NVIDIA took 190 units, 99.98% of the amount. The domestic share was a single FuriosaAI NPU, worth 2.5 million won. The largest buyer by agency was Korea Hydro and Nuclear Power at 3.964 billion won, followed by Korea Gas Corporation, Kangwon Land, Korea Electric Power Corporation, and Korea Minerals and Geo-science Information Institute.

This number is a record of "purchase liability aversion." When a foreign-made part breaks, it is hard to hold anyone responsible, so public agencies have always chosen the safest brand. Purchases for inference account for 47.2% of the total amount. Half of the public budget is already going to the inference floor where agents and chatbots actually run, and even on that floor the domestic NPU is a single unit. The situation is like this even in the area where domestic chips claim their strongest advantage.

The Ministry's answer is procurement. Minister Kim Jung-gwan said at the national audit on the 22nd that a semiconductor cooperation agreement between the Ministry and its public agencies will be signed in November. The idea is to reduce the burden of purchase liability so the public sector becomes the "first buyer" of domestic chips. The demand itself has already emerged. That is shown by reports that DeepX has supplied a domestic NPU through a Ministry of Defense video surveillance pilot build and secured roughly 18.3 billion won in orders from over 10 countries. This trend is not a matter of this month alone. The Ministry of Science and ICT, through its designation of excellent R&D innovation products, has allowed public agencies to use negotiated contracts, up to 3 years basic and 6 years maximum with extensions, and has opened up purchase liability exemption. It also cut the procurement lead time from 60 days to 10 days or less. It is a structure where two axes mesh: demand pulls, supply pushes. Where domestic NPUs will go next is already drawn out. CCTV and perimeter monitoring, chatbots, document processing, personal information masking, cybersecurity monitoring. It is a matter of whether the public sector will take on the "responsibility to choose." The answer of localization is, in the end, the logic of the side that creates demand.

## The answer of control: two days of remarks from Hannam-dong

The other answer poured out over two days at a pop-up. Palantier opened its second pop-up store in Seoul's Hannam-dong on October 22 and 23. The first event last year in Seongsu-dong drew over 5,000 visitors, and this year's core theme is, without question, "sovereign AI." Korea is also the world's third-largest buyer of Palantier, and according to Money Today reports, Palantier rates Korea as its top non-US commercial market. Choosing this theme and opening with these remarks is itself a message.

The core of the remarks came from Chad Wolquist, Palantier's Head of AI Architecture. "Sovereign AI is not a matter of choosing a domestic LLM, it is having decision-making power across every layer: data, computing resources, model execution environment, and business process," he said. The point is where data goes, who decides, and who audits the execution. Akshay Krishnaswami, Chief Architect, noted that "physical manufacturing and on-site industrial work are still areas AI cannot support," and added that now is the opportunity for Korean companies to use their manufacturing knowledge in specialized model development and fine-tuning. He also emphasized that an open architecture lets one freely choose between US and Chinese models.

The on-site remarks were not left out either. FDE is a model where engineers are placed at the customer site to directly connect business systems and AI. It means Palantier sells not the model but "the process of planting it." The day before, at HD Hyundai's Busan facility, an FDE was in the middle of applying its own AI model to the inside of a ship. It was also reported that over the past 6 months, requests from customers to support new hires had actually increased. That is the synergy of one person doing ten times the work. The message converged on the idea that rather than waiting until a Korea-only AGI emerges, "deploying the AI you can use now to shipbuilding, semiconductor, and manufacturing sites" is more valuable. Maeil Business Newsummarized the message of this Korea visit in one line. "The battleground of Korea's AI is shipbuilding and semiconductors, and AI must be planted on-site."

## Why the two answers are not the same question

On the surface, the two sides look like they deny each other. But the answer of localization is about "who builds it." The chip must be domestic, the model must be domestic, the supply chain must be domestic. This week's domestic movements are on this axis. SKT held an exchange meeting with researchers from Seoul National University, KAIST, and the Institute for Basic Science, and is reflecting expertise in probability, graph theory, and topology into training its proprietary foundation model A.X K2. A.X K2 raised its average benchmark performance by 32.2 points compared to the previous model, and a follow-on model at the scale of trillions of parameters is in preparation. It is explicitly aimed at the sovereign AI ecosystem of "working AI" in manufacturing, semiconductors, and defense. Samwo Computer's approach is more closed. It runs generative AI on an internet-free AI PC, the "TG AI Station," and handles Q&A, document summarization, and report writing locally with a Korean LLM. It is a product targeted at public, education, and research institutions where information security matters, and received the Ministry of Science and ICT's "AI Product/Service Certificate" in September 2026.

The answer of control is about "who decides and who audits." Even if the chip and the model are both domestic, if the data leaves the country, the execution happens in the dark, and no one can answer who did what, sovereignty does not hold. Conversely, if you keep the execution of a foreign model within your own boundaries and leave a complete audit trail, you can hold sovereignty. That is why Wolquist spoke of "decision-making power across every layer."

The weight of the second question grows as agents spread. This is no longer the age where models only talk. According to Digital Today, Microsoft defines in-enterprise AI agents as the "agentic insider" and proposes 24-hour monitoring and control via a "guardian agent." "Monitoring" and "control" become essential infrastructure of security. Sovereignty naturally shifts, too, toward "control of execution." Domestically, Samsung SDS and Orcestro are pushing infrastructure- and platform-based sovereign AI, and Palantier's FDE approach has jumped into that field. When competition heats up, standards are needed in the end. And those standards become a question of "proof." Because you have to be able to show sovereignty through the traces of execution.

## Outlook: the battleground moves to the boundaries of execution

Let's bring up the outlook card. Over the next 12 to 24 months, the sovereignty debate will tilt from "the nationality of the model" to "the boundaries of execution." While global giants expand computing, the countries that use it compete over "where it runs" and "how it is audited." According to Union InfoMax, OpenAI is in the final stages of a new raise of up to 30 billion dollars at a 1.25 trillion dollar valuation, led by a UAE investor and the venture capital firm Coatue. It is also negotiating in parallel a contract to secure additional computing capacity from the UAE. OpenAI's disclosed goal is 600 billion dollars in total computing expenditure by 2030. The scale of the bet is a number already known. Capital is one-sidedly growing "the thing that builds."

On the other side, we also see the form of assets changing. According to Global Economic, LSEG acquired Octax for about 4.9 trillion won. A market has opened where the moat bundling data and security for the AI era is bought and sold. The public priority-purchase agreement is the first attempt to create demand, and the control argument is the map for the next stage.

For enterprises, this is a question of the procurement checklist. The phrase "our model is domestic" is no longer enough as an answer to sovereignty. Where the data stays, who can execute what, at what level of autonomy, and what audit trail remains after an agent has moved. These four questions are the new standard. The chip and the model are only the tools that execute the questions. These four will soon be written into public procurement specifications and financial institutions' supply chain review questionnaires. The day the standard that verifies sovereignty becomes the audit log.

## Where control became a product spec

Here is ThakiCloud's perspective. The "control" Palantier brought out from Hannam-dong is, in fact, the same problem ThakiCloud is already answering as a product. The core of Paxis, the Agent-Native Cloud, is controlling where and how an agent executes. Skills and Tools, Policies, and Audit Logs are first-class resources in Paxis. Autonomy governance distinguishes levels from L0 to L3, a policy gate and an audit log stand before every execution, and the execution itself happens inside an isolated sandbox. With MCP connectors and the skill marketplace, one can freely place models whether domestic or foreign, and with CostRouter choose the optimal model per task. In finance and public sectors and defense, where data cannot leave the country, the execution boundaries inside a closed network and the per-task model selection are the entry condition. Wolquist's "decision-making power across every layer," is it not, for Paxis, not a policy slogan but a spec sheet already built as a formal product (v1.1 GA) on top of a sovereign, on-premise Kubernetes environment?

The sovereignty question that split into two branches: the answer to "who builds it" is now handled by the chip and the model, and the answer to "who controls it" is the platform's turn. The two days of remarks from Hannam-dong and the 99.98% number from Seoul are the signal of the same change. The age of buying sovereignty is passing, and the age of executing sovereignty is coming.

## References

This post was written by synthesizing the news below.

- ZDNet Korea, [[Yumi's Pick] New growth engine is overseas data centers... the winning moves of LG CNS and Lotte Innovate](https://n.news.naver.com/mnews/article/092/0002441820)
- ZDNet Korea, [Government Agency for Public Data and Government Information, strengthens security against AI hacking... restructures government cloud management system](https://n.news.naver.com/mnews/article/092/0002441856)
- Yonhap News, [OpenAI's GPT to be deployed on Google Cloud as well... all three major clouds used](https://n.news.naver.com/mnews/article/001/0016392718)
- Digital Today, [AI agent disables its own safety devices... OpenAI releases internal incident report](https://n.news.naver.com/mnews/article/138/0002245536)
- Electronics Times, [KT to target hospital AX with a 'medical standardization model'... selects modular AI](https://n.news.naver.com/mnews/article/030/0003477317)
- Digital Today, ["Reads personal context and jumps across apps"... Apple's Siri AI, wrapped in a dedicated app, lands in Korean next week](https://n.news.naver.com/mnews/article/138/0002245488)
- News1, [231 reports of AI risk were submitted, but... only 68 responses from businesses](https://n.news.naver.com/mnews/article/421/0009242820)
- Yonhap News, [3 out of 10 chief information security officers in finance hold concurrent posts](https://n.news.naver.com/mnews/article/001/0016392752)
