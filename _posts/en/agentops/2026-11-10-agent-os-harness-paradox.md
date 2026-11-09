---
title: "The Day the Agent Became an OS, the Harness Disappeared"
excerpt: "DeepSeek's agent framework 'Harness' reached 1.54 million daily active users and 92 trillion tokens a day within three months of launch. The name means a device that reins in a horse's behavior, but the more open the ecosystem, the clearer the control structure enterprises actually need."
seo_title: "DeepSeek's Agent OS Harness: the Enterprise Control Structure the Name Doesn't Capture | ThakiCloud"
seo_description: "This post analyzes DeepSeek Harness's 1.54 million daily active users and 92 trillion daily tokens, the AI auto-approval password leak, and the gap in agent KPIs, and examines the enterprise governance structure an agent OS requires."
date: 2026-11-10
last_modified_at: 2026-11-10
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "robot"
tags:
  - agent-os
  - deepseek-harness
  - agent-governance
  - audit-logging
  - skill-marketplace
  - enterprise-ai
  - policy-gate
categories:
  - agentops
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/agentops/agent-os-harness-paradox/"
---

## An OS with a Contradictory Name

Harness. It is a leather device that holds a horse's head and sets its direction. That is what the word most immediately evokes, which is control. Yet DeepSeek put this name on its own agent framework. And on November 9, an official announcement showed just how fast the ecosystem is growing.

According to Global Economic, Harness's daily active users, or DAU, have reached 1.54 million. As of November 4, the Harness API consumes roughly 92 trillion tokens a day, about 1.1 billion per second. Third-party plugins have passed 35,000, and about 60% of active users run them alongside. That is a three-month record.

Let me add one more detail so you can feel the weight of that number. Harness is not a chatbot. It is an execution base that bundles external tools such as file reading and writing, terminal command execution, and web search, so that an AI model operates them on its own. It is the agents' workspace, itself. The scale of 92 trillion tokens a day means that tens of thousands of agent tasks run on this OS every day.

## Three Months from Chatbot to OS

Harness was released on August 13. On September 29, a standalone desktop agent app was added. Signals that the era of "one model giving the answer" is giving way to the era of "many agents working together" had already appeared in places. According to Edaily, Anthropic published an experiment in which roughly 1,000 agents collaborated to formalize Fermat's Last Theorem in Lean in 30 hours. The re-detection rate for public security vulnerabilities on Muse 5.2, a model built for specialized institutions, also rose from 78.3% to 89.6%. That means agents are being put to work in specialized domains such as security analysis.

Then, in November, DeepSeek formalized the launch of a dedicated marketplace for registering and trading paid and free plugins. It also revealed plans to give top developers large subsidies of free API tokens, to set up its first commercial product division led by Chui Tianyi, who came from Jane Street, and to build a paid software revenue model for both B2B and B2C. Experts assess that the penetration of this ecosystem, which absorbed 92 trillion tokens a day in three months, could become a dark horse that reshapes the AI agent market. The nickname "the Android of agent platforms" comes from here.

While OpenAI and Anthropic fill the market with finished enterprise coding tools centered on Codex and Claude Code, DeepSeek took the opposite road: low API pricing and an open plugin architecture. Not selling an app, but opening an operating system. That is the bet today.

## The Harness Comes Loose, the Passwords Leak

This is where the contradiction in the name truly shows. A word that means a control device has been attached to the most open agent OS. The news from the last two days shows, as it happened, what occurs when the harness comes loose.

According to Chosun Ilbo, Israeli security firm Apify found 2,539 sets of login information, including passwords, across 1,994 public GitHub repositories. Information from 63 organizations was mixed in, including companies and student groups. The representative leak path was the "don't ask again" auto-approval feature in Anthropic's Claude Code. When a password gets mixed into an approved task command, it is saved together in a separate record file, and once that file is pushed to a repository, the password leaks even without a hack. Of the 1,122 files containing login information, 215 were not caught by either of two mainstream secret detection tools. Boris Cherny, an Anthropic lead, said the company is reviewing adding sensitive-information checks and a default detection capability to auto-approval.

This is not something to read only as one organization's management failure. Not just Apify, but multiple security outlets and secret-detection firms such as GitGuardian have issued separate reports. As AI agents spread, the attack surface moved outside the code, to approval records, memory, and conversation logs, and existing scanners cannot even see that file itself. It has become a common task across the industry.

A speed gap is opening at the same time. According to Financial News, Microsoft's 2026 Digital Defense Report says that attackers using AI take a median of under 24 hours from finding a vulnerability to completing an attack tool, while enterprise response can take up to 60 days. It means that while the defense still moves at human speed, the attack has already sped up to agent speed.

The same day, IT Chosun introduced Menlo Ventures' "State of Enterprise AI 2026" report. Enterprise generative AI spending grew 5.4-fold in a year, and annualizing the September 2026 level brings it to $176.8 billion. Of the $77.3 billion enterprise AI application market, the $34 billion coding segment is the largest. It is also worth noting that a verification tool appeared where spending is most concentrated. Microsoft Research published PDD Kit on November 5, a tool that verifies programs written by coding agents.

And the "Measuring Agents in Production" survey by Melissa Fan and others points to today's reality. 74% of agents rely on human evaluation. 68% handle only work of 10 steps or fewer before human intervention. The column warns that if you look only at the automation rate or the success rate, an illusion forms: only easy work gets automated, complex work stays with humans, and performance is overestimated. Spending has jumped five-fold, and the bottleneck has shifted from "how well do they do" to "what, and how, do we verify."

## What Enterprises See First Before an Agent OS

Korean companies are already finding answers in the field. According to The Bloot, the Financial Services Commission put its financial-sector AI guidelines into effect on June 22. It presented seven principles, governance, legality, auxiliary nature, reliability, financial stability, good faith, and security, and set the principle that AI remains an auxiliary device and humans bear the final decision and the responsibility. This is not Korea alone. In the US, JPMorgan Asset Management's "Moneyball," trained on 40 years of data, and BlackRock's "Asimov" are running as portfolio decision-support tools.

The adoption speed is by no means slow. Hana Bank cut the enterprise credit-rating review-opinion work that took over 30 minutes down to 10 seconds, saving 27,000 hours out of its 70,000 annual cases. Shinhan Bank's AI check agent for appraisal reports reduced per-case check time by 70% and tripled daily throughput. The problem is what comes after. The 48 detailed duties in the current responsibility chart do not directly regulate situations where AI autonomously changes a credit model or judges an abnormal transaction. The administrative-fine ceiling under the AI Basic Act stays at 30 million won. The column's author says "the speed of technology runs ahead of the gaps in the system" and argues that work affecting consumers' money and contracts needs a human pre-approval step.

Model selection is moving on the same logic. According to Edaily, Anthropic's new Fable 5.2 recorded 65 points on the Artificial Analysis AI intelligence index, reclaiming first place, and the company cut API prices by 20%. It moved input tokens from $10 to $8 per million and output from $50 to $40. At the same time, it officially recommended task-difficulty-based model routing: use Opus 5.5 first for general coding and knowledge work, and deploy Fable and Muse only for complex, high-difficulty tasks. It also released a fast mode that provides up to 2.5x speed at 2x the price.

For reference, on the coding evaluation FrontierCode 2.0, Fable 5.2 led at 49.1%, ahead of Opus 5.5 (45.5%) and GPT-6 Astra (42.8%). But on the enterprise workflow automation benchmark AutomationBench, Gemini 4 Carbon leads Fable 5.2 (51.4%) at 53.9%. That means different models lead in coding and in workflow automation, respectively. That is why benchmark-based multi-model, multi-harness hybrid operation is rising as the rational answer, rather than vendor consolidation. In an enterprise OS, the criterion for choosing the engine is the nature of the work, not the brand.

## The Next Issue for the Agent OS: The Black Box Bolted Into the Chassis

So what "harness" should an enterprise attach to the agent OS? Even just gathering today's news, the criteria are four. First, the approval structure. The boundary between what an agent can do on its own and what needs human pre-approval should be a first-order setting, not a post-hoc phrase. Second, traceability. What policy, what model, and in what order a decision was made must remain in an audit log so it can be explained afterward. Third, isolated execution. In an open plugin ecosystem especially, untrusted code must run only inside a sandbox that can be discarded. Fourth, cost governance. The structure needs to pick the right model for each task and turn 92 trillion tokens a day from someone else's news into your own profit-and-loss statement.

Global Economic's take points in the same direction. As the global penetration of a China-origin open-source harness accelerates, the concerns in the enterprise sector over data sovereignty and domestic alternatives grow. Demand is rising for a neutral agent platform that orchestrates multiple harnesses and multiple models to secure optimal performance, cost, and security. It means the market is already preparing for the moment when openness alone is not the answer.

These four criteria are the domain ThakiCloud Paxis handles. Paxis is ThakiCloud's Agent-Native Cloud, a formal product at the v1.1 GA stage. It treats Skills, Tools, Policies, and Audit Logs as first-class resources, not add-on features. It sets autonomy levels from L0 to L3 per workflow, and a policy gate and audit log leave the basis of each decision. Agent execution happens in an isolated sandbox, and the ecosystem is connected through MCP connectors and the skill market. The same structure can be lifted into a sovereign, on-premises Kubernetes (ai-platform) environment and run there. CostRouter picks the right model per task, and in a market where price competition intensifies, as in Anthropic's 20% cut, this becomes the operational lever. The four criteria sit directly on top of these resources. The autonomy level and policy gate handle the approval structure, the audit log handles traceability, the sandbox handles isolated execution, and CostRouter handles cost governance.

This is the day an operating system called a harness appeared. What enterprises want is not the harness coming loose, but the harness bolted firmly into the OS. The next front of the agent OS will be decided not by the number of plugins, but by the thickness of the black box bolted into the chassis.

## References

This post was written by synthesizing the news below.

- NewsRoad, ["'US-driven AI investment uncertainty'… AWS, MS, and OpenAI turn their eyes to Korean data centers…"](http://www.newsroad.co.kr/news/articleView.html?idxno=67398)
- Chosun Ilbo, [Passwords leak even without a hack… 2,500 passwords exposed to AI 'auto-approve'](https://www.chosun.com/economy/tech_it/2026/11/09/DOOMGNCD7RH2NJJJ2SIRDHBRWE/)
- Global Economic, ["'From a simple chatbot to an OS'… DeepSeek's 'Harness' reaches 1.5 million daily users within 3 months of launch…"](https://www.g-enews.com/view.php?ud=2026110918061930770c8c1c064d_1)
- Business Plus, [\[The creaking data-center boom/①\] US-driven regulatory headwind… AI infrastructure investment…](https://www.businessplus.kr/news/articleView.html?idxno=119541)
- NewsWorks, [SKT, NVIDIA, and Rebellion sign an MOU to develop an integrated GPU·NPU system](https://www.newsworks.co.kr/news/articleView.html?idxno=902490)
- Financial News, [Hacking takes a day with AI, but corporate defense can take up to two months - Financial News](https://www.fnnews.com/news/202611091829460821)
