---
title: "The oldest technique in history"
excerpt: "All five major banks were attacked. The weapon was not a zero-day but the oldest technique in history. 40.5 billion won and 86 billion won, the information protection budgets of two banks. What divided 25,000 and 119 in damage was not budget but identity verification. This week, 'defending AI attacks with AI' became a budget line item."
seo_title: "The oldest technique in history breaches the five major banks | ThakiCloud"
seo_description: "A week in which AI hacking spread to the five major banks and the non-bank financial sector. We analyzed why an old technique like credential stuffing was turned into a weapon at machine speed, the variable that divided the scale of damage, and what the government and financial sector's shift to 'defending AI with AI' means, using today's news."
date: 2026-10-06
last_modified_at: 2026-10-06
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "robot"
lang: en
canonical_url: https://thakicloud.com/tech-blog/en/agentops/oldest-attack-technique/
tags:
  - ai-security
  - agentic-ai
  - data-breach
  - ai-governance
  - audit-logging
  - financial-ai
  - agentops
categories:
  - agentops
---

40.5 billion won and 86 billion won. The information protection budgets of two banks. Both were breached. The scale of the customer data leak was 25,000 people and 119 people. If you guessed which bank was defended with which budget, you got it wrong at the starting line. This is what YTN reported this morning. All five major banks, including Shinhan, KB, Hana, Woori, and Nonghyup, came under AI hacking attacks. About 25,000 customer records were confirmed leaked at Shinhan, 119 at KB, and 89 at Hana. Woori and Nonghyup are still at the unconfirmed stage. This is not a Tier 1 banking story. By foreign media reports, seven financial institutions were compromised in a single week, and the personal data of more than 65,000 customers leaked. The government activated a 24-hour cyber security emergency response. The Financial Services Commission is pushing a transition to an 'AI security system.' The industry calls this the event where 'AI hacking' moved from hypothesis to reality.

## The oldest weapon

The trace of the intrusion points to a tool that no one was paying much attention to. According to Digital Today, IP analysis flagged the use of ARTEX, a China-origin open source autonomous penetration testing tool. ARTEX is an open source tool anyone can download and use, which makes attribution to a specific state actor difficult. Its structure is exactly the same as today's agentic AI agents. LLMs and multi-agent orchestration automate everything from reconnaissance to identifying vulnerable endpoints, launching attacks, and verifying results, and humans only need to set the goal.

The core is what got automated. This is not a new technique. Experts see the method at work, credential stuffing and repeated account lookups, as conventional. The reading is not that a new element was added to the technique, but that AI pushed the 'searching' for vulnerabilities to an extreme level of automation, and that efficiency gain is the essence of this incident. In the past, the time from finding a vulnerability to actually attacking took weeks to months. With attack code auto-generated, that got compressed to tens of minutes to a few hours. The skeleton of the analysis is this: even a conventional technique becomes threatening enough to breach existing defense systems when repeated at AI speed. AI did not invent a new weapon. It bolted machine speed onto the oldest technique in history.

The contrast is sharper. Anthropic announced a security-specialized AI, 'Mythos,' in April. Reports said it found more than 10,000 zero-day vulnerabilities in commercial software within a little over a month of release. The frontline of AI attacks has already reached the stage of looking at zero-days. If the thing that actually breached the five major banks was the oldest technique, it means the blind spots on the defense side are much wider than we imagine.

## The open door is the side door

The door that got breached was not the front door. It was not mobile banking, which banks guard most tightly. It was 'peripheral systems' like loan agent services and employee work support systems. YTN reported that it judged the absence of identity verification and inadequate access control as what divided the scale of damage. Factors that determined the success or failure of the actual intrusion were also pointed out: whether multi-factor authentication, or MFA, had been built, and whether existing vulnerabilities had been addressed. It is a pattern in which doors left in the blind spots of security management are searched for and opened at large scale, not a high-difficulty zero-day.

The pattern of spread is similar. It reached the non-bank financial sector. BNK Busan Bank, Wellcome Savings Bank and Yegaram Savings Bank, and Hyundai Capital. At Yegaram Savings Bank, leaks of about 40,000 customer records were confirmed. At Hyundai Capital, 146 loan agents. This means damage was bigger in areas where management's reach is thin. The industry reads this spread as a signal of the next front line. The smaller the institution, the thinner the margin of security management, and the pattern of 'finding the weakest door at AI speed' repeats exactly.

The deeper problem lies in the structure. Peripheral systems built in-house by business departments or outsourced were blind spots in security management from the start. The more deeply AI agents enter the flow of work, the more of these 'doors' there will be. Every time the number of doors an attacker has to search for grows, if the speed at which defenders know about those doors cannot keep up, the shape of the incident will resemble this one.

This is where the formula 'budget equals safety' wobbles. Shinhan Bank 40.5 billion won, KB Kookmin Bank 86 billion won. The gap between the two budgets is about 2x, and the gap in leaks is more than 200x. The industry's read is that damage scale does not scale proportionally with budget size. Whether 40.5 billion or 86 billion, the wall that fell was not a wall of money. The moment it got breached, what was lacking was not equipment, but the identity verification attached to the door and the access control behind it. It was a week in which the 'quality' of investment, not the 'quantity,' decided the damage.

## Speed has already crossed to the other side

Why did the old technique bite so deep this time? Because the speed on the other side has changed. The core is that AI has effectively removed the skill barrier to attack. Attack tools that anyone can download for free have started moving at the speed a person would work sitting at a desk. The defense side, by contrast, is still at human speed.

The Microsoft Digital Defense Report, cited by Digital Today, points out that when the speed of attack exceeds the processing limit of human SOC teams, 41% of alerts are left uninvestigated. If 41% of alerts are not even confirmed, the word 'response' does not hold to begin with. Kim Yu-won, CEO of Naver Cloud, said bluntly at Cyber Summit Korea 2026: 'The era of responding to AI attacks at human speed is coming to an end.' The industry's diagnosis is that increasing security personnel by 10 to 20 percent cannot keep up with machine speed. If the attacker is an agent that never sleeps, the answer of adding more people is already a dead end. According to Digital Today, cooperation between security, semiconductor, and platform companies is being concretized, and the industry's gaze is moving from personnel reinforcement and existing equipment to AI-agent-based autonomous SOC and AI-speed detection and response. The point where 'defending AI attacks with AI' becomes not a slogan but a budget line item starts here.

From the defender's side, this is a matter of the budget equation changing. The question of 'how many more people to hire and how many more pieces of equipment to buy' moves to the question of 'how often to check and how much to block.' With 41% of alerts going unseen today, most organizations still have no answer to the second question.

## From slogan to budget line item

The response side moved structurally this week too. The Financial Services Commission shared 25 attacker IPs with 500 companies and is pushing a security system that 'defends AI attacks with AI.' The government has begun developing a cyber security specialized AI model. With the launch of security-specialized model development, the financial regulator's inspection order, and the emergency response system by the Ministry of Science and ICT and KISA following one after another, AI security budget is being discussed as a core agenda of next year's budget formation. The background is global. According to reports, the leaders of the United States and China have both rejected the AI slowdown argument, and the 'responsible development' debate follows. It also means a market is opening in which both the attack and defense sides invest at the same time.

At the policy level, direction has been set. Deputy Prime Minister and Minister of Science and ICT Baek Keun-hoon said, 'Cyber security AI capability cannot rely on the outside,' and named cyber security as the representative area. Application to important systems is premised on 'sufficient verification and human supervision.'

Both sentences are worth looking at for a long time. 'Cannot rely on the outside' is a sentence about deployment. The security-specialized AI that guards a bank's core network can only run in an environment where the bank's data does not leave the bank. 'Verification and human supervision' is a sentence about operation. The moment the defender is also switched to an agent, from the point that agent acts, one must be able to answer and prove who, under what policy, approved what. In one line, these two sentences are the difference between the AI one uses and the AI one governs.

In the same week, on the other side of the wall, the structure of the 'acting agent' was increasing. Meta's Muse directly performs everything from exploring shopping sites to preparing payment, and leaves the final purchase confirmation to humans via an approval card. Within weeks of release, it recorded millions of downloads and reached #1 among free apps in the U.S. App Store. AWS put Bedrock Managed Agents powered by OpenAI models into public preview. There are two features. A design in which the agent runs within existing authentication, permission, and governance controls. And an option to choose the execution environment between self-hosted compute and managed runtime. With the same toolbox that attacks use, both defense and business are being built, and an era has come in which even large clouds draw the boxes of identity and control inside that toolbox first. In an era when agents are not the exclusive domain of attackers, whether to adopt or not is no longer a question.

## When the same tool lands in the defender's hand

The attacker's toolbox is LLMs, multi-agent orchestration, and external service connectors. The defender's toolbox will ultimately be nearly the same. What divides the two toolboxes is not capability. It is whether identity, permission scope, and trail exist. The attacker's agent has no name, no policy, no audit. Only speed. The defender's agent must be the opposite. It should pass through a policy gate on every execution, work in an isolated environment, leave records that can be replayed after the fact, and be designed so that humans can inspect the level of autonomy.

Today's five major bank incident is, in the end, a rehearsal for the question every company will soon face. When introducing an agent into work, is the infrastructure in place that proves the agent has an identity, has a permission scope, and leaves a trail? The four pains the incident shows are clear. Who did what is audit. What can be done is access control. Whether data does not go outside is sovereign deployment. Using the same budget more sharply is cost.

ThakiCloud's Agent-Native Cloud Paxis is a formal product (v1.1 GA) built premised on this rehearsal. In Paxis, skills, tools, policies, and audit logs are managed as first-class resources. Agents work under governance from L0 to L3, and the policy gate stops dangerous actions before execution. The isolated sandbox ensures that even when execution leaves the isolation, it does not reach outside. MCP connectors and the skill market standardize connections to external systems. Sovereign and on-prem K8s (ai-platform) allow the same workloads to run without data leaving the company. CostRouter selects the most economical model for each task, making the 'quality of the budget' a design variable rather than an after-the-fact calculation.

The oldest technique in history breached the five major banks. The lesson left by that incident is not 'spend more.' It is 'the agent that comes into the company next week must have an identity, must have a permission scope, and must leave a trail.' The attacker has proven speed. The remaining task is now to bolt identity and audit onto the defender's speed as well.

## References

This article was written by synthesizing the following news.

- iDilly, ["Not just words"...what is Meta's "Muse" that does everything from shopping to payment](https://www.edaily.co.kr/News/Read?newsId=01262806645610296&mediaCodeNo=257&utm_source=naver&utm_medium=referral&utm_campaign=news_syndication&utm_content=original_article)
- AWS Web Log, [AWS supports OpenAI models in Bedrock Managed Agents...Weekly Update (10/5)](https://aws.amazon.com/blogs/aws/aws-weekly-roundup-amazon-bedrock-managed-agents-powered-by-openai-q3-service-availability-updates-kiro-workflows-and-more-october-5-2026/)
- Digital Daily, [Minister Baek Keun-hoon, "Cyber security AI capability cannot rely on the outside"...Dokpamo, Frontier](https://www.ddaily.co.kr/page/view/2026100605510464743)
- Digital Today, [AI hacking "heavily armed with speed" strikes Korea...will the overhaul of security strategy gain momentum](https://www.digitaltoday.co.kr/news/articleView.html?idxno=705009)
- YTN, [Five major banks breached...AI hacking realized in the financial sector [Start Economy]](https://www.ytn.co.kr/_ln/0103_202610060719542617)
