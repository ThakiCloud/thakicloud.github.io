---
title: "The Week 40 Scripts Moved in 3 Days: The Attacker's 72-Hour Clock"
excerpt: "Hackers gain time with AI, and companies lose their response time. What the seven Israeli security firms sold in Korea was not something fast, but the moment of execution."
seo_title: "The Week 40 Scripts Moved in 3 Days, the Attacker's 72-Hour Clock | ThakiCloud"
seo_description: "The attack that arrived 3 days after the PHP2Shell disclosure, the 40 mass-produced LLM scripts, and the seven Israeli security firms selling agent control. This post analyzes the time asymmetry of AI security and the moment an agent-native cloud answers it."
date: 2026-11-04
last_modified_at: 2026-11-04
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
canonical_url: "https://thakicloud.com/tech-blog/en/agentops/40-scripts-72-hour-attack-clock/"
---

Today's headlines were unusually full of time.

In the results of the October pilot run of the MD curation system that GS Shop developed jointly with AWS, roughly 40% of all promotions were produced by 4 AI agents, and product selection and event preparation time was cut by 70%. The system officially opened on November 2. Mirae Asset Securities is running Market Now, an intraday AI summary on a 2-hour interval, and its ultimate goal is Agentic WM, an asset management system that detects market changes and proposes investment actions first. Samsung SDI called the trend of global data center power consumption jumping from 415TWh in 2024 to 945TWh the "wall of time." And NVIDIA has confirmed a direct investment of 1.3412 trillion won in Naver, with each Sejong data center on a roadmap from 55MW in the first half of 2027 to 200MW cumulative by 2028. Hyundai Motor and Kia are making an additional 475.3 billion won investment in 42dot, with a timetable of Level 2+ autonomous driving on the NVIDIA platform in 2028 and mass production of the in-house developed Attea AI in 2029. The game companies are chasing time as well. In the trend of NC AI and Krafton moving into robot AI, NC AI raised welding classification accuracy from 41.1 points to 80.9 points with the lightweight vision language model Backy Vision 3B, and is running field validation with Hanwha Ocean, POSCO DX, and Hyundai Rotem.

In all of these stories, the agents stand on the side that shortens time. Companies are buying AI to gain time, and power grids and data centers are racing to carry that time. Speed is the currency of today's headlines. But in one News1 report today, the "subject that shortens time" is sitting on the other side. Time aimed at the losing side.

![An image visualizing the concept of the week 40 scripts moved in 3 days: the attacker's 72-hour clock](/assets/images/40-scripts-72-hour-attack-clock-hero.webp)
*Visualizing the core concept of this post.*

## 3 Days, and 40 Scripts

Alma Sheilev, a solutions engineer at Israeli security firm Dream, confirmed signs of AI use in an attack that exploited the PHP2Shell vulnerability. The server attacks began 3 days after the vulnerability was disclosed, and the attack scripts contained 40 LLM-based or LLM-like scripts. Major security vendors such as Cisco and Formalize have also published separate reports on the PHP2Shell vulnerability and AI-accelerated threats. "3 days after disclosure" is becoming the standard. And it carries more weight because the witness is not a theorist but a front-line SOC engineer working in an attack that actually happened.

Look closely at what the number 40 means. It is the result of AI mass-producing variants. What deserves attention is what AI's role was. The analysis is clear. Even without AI, the attack itself was possible. What AI changed was the "attack preparation time." Dream calls this not fully autonomous. In other words, today's message is that "AI made the attack fast." Between possible and fast lies the entire response time of a company. That gap is the time for a patch to be deployed, the time until the on-duty engineer looks away, and the time until an incident report begins to be written. Hackers gain time with AI while companies lose their response time. That is the asymmetry. Once that asymmetry starts being confirmed in numbers, the nature of the story changes.

## What Is on the Other Side of the 72 Hours

Looking at the whole market, the gap from vulnerability disclosure to real attack has compressed from 2 or 3 weeks in the past to within 72 hours. 72 hours is a number that flips a company's security rhythm. Existing patch distribution and monitoring cycles are usually 1 or 2 weeks. If the attacker's clock is 3 days and the defender's clock is 2 weeks, the patch, the first line of defense, is already late. When the patch is late, heavy decisions such as shutting down a service have to be made while an attack is underway.

There is structure in the difference. The defender runs on a cyclic clock. It has to repeat the sequence of issuing a patch, verifying it, deploying it, and monitoring it. The attacker, by contrast, needs no cycle. From the moment it notices that a vulnerability has been disclosed, it only counts down the golden time. For the attacker, the disclosure date is the start of the clock. For the defender, it is only the start of the warning. On top of this come the 40 variant scripts. The cost of producing variants has collapsed, which effectively neutralizes signature-based detection. A defense that remembers one pattern does not hold up long against an attack that stamps out patterns.

This is not a "buy one more security tool" problem. When the attack cycle shrinks from "weeks" to "hours," what has to respond at the same speed is the entire security operations workload that one person used to hand off stage by stage. Detection, triage, response actions. The moment the workflow itself has to move on the attacker's clock, there is only one intuitive answer. A defensive agent that acts at the same speed as the attack.

## What They Sold Was Not "Something Fast"

The day before, the "Israel-Korea Cybersecurity Forum 2026" was held in Seongnam, Gyeonggi Province. Seven Israeli security firms, including Dream, Heka, Modelio, Oka, ScreenStop, Silverport, and ZeroPort, pitched new technologies such as AI agents in Korea. It was a substantive discussion on technical cooperation and joint business, and Korea, amid the strengthening sovereign AI and data sovereignty policy trend, was exploring a path to introduce Israeli security technology domestically. Rereading the GDNet Korea report, what these companies sold was not speed. Entering 2026, an era has opened in which AI agents autonomously access company systems, and existing authentication schemes struggle to block agent privilege escalation and lateral movement. The pitches came to fill that gap. Israel is known as the country with the third-largest cybersecurity startup ecosystem after the US and Europe.

Silverport introduced AI agent identity management, MCP protocol tool-call inspection, and pre-execution control for agents on Google Cloud and MS Copilot Studio. Dream presented a sovereign AI-based national cyber defense platform targeting on-premises and network-isolated environments, of which Hero operates automated vulnerability discovery and remediation agents. Modelio brought out a confidential cloud platform. Oka Security, a company with cumulative investment of US$630 million (about 841 billion won) and a valuation of US$1.8 billion (about 2,403 billion won), is seeking entry into the Korean market since its strategic partnership agreement with AWS in March.

Look one more time. For the defense of the agent era to run at the same speed as the attack, agents will eventually run inside the SOC. And what the market is pricing is "what gets blocked at the very moment of execution." Who issued the identity, what was inspected before the tool call, which actions were blocked before execution, and where the records of those remain. That is exactly why Silverport leads with pre-execution control and tool-call inspection. The speed of the attack and the speed of the defense are the same product. What differs is the moment of execution.

## The Paradox of Fast Defense

Here a paradox arises. If the defensive agent is tuned to the attack's 72-hour clock, its mistakes will run at 72-hour speed too. If a false positive from the detection agent flows through triage into automatic patching, an incident where a wrong service is taken down and a wrong patch is applied could repeat on a 3-day cycle. The faster it is, the greater the damage. In a multi-stage structure where agents command agents, a mistake does not reverse up the stages. It propagates to the next stage.

Dream's words are calm. Defensive AI is necessary, but human intervention is essential for the final response. A person is easy to see as the "cause of slowness," but in fast and safe operations, the number and speed of the points where a person holds final approval become the metric of defense. In other words, the question of the agent era is: which actions run without a person, which actions go through human approval at the moment of execution, and where the records are completed. The more a battle is decided by speed, the more the moment of execution becomes the core of security.

## The Leash Is a Permit, Not a Brake

The pain that today's news revealed is fourfold. Audit, sovereignty, safe execution, and cost. Korea's financial and public core infrastructure is still in on-premises and closed-network environments, and access to external AI security services is limited. And yet the demand to run security AI on one's own in a private cloud environment is growing. The reason the domestic model Solar Pro 4, which passed the NIS security review, was put into the government-wide AI common infrastructure in a closed structure that does not send internal data outside, presenting the basis of its answers linked to administrative documents in a RAG manner, is the same. And the reason NVIDIA confirmed the 200MW of the Sejong data centers in Korea is the same. Sovereign, closed, and auditable. That is the shape of how Korea is bringing in AI.

Cost is another pain. According to today's Global Economic report, Anthropic moved from a US$974 million operating profit in the second quarter to a US$567 million operating loss in a single quarter, and the hourly accelerator rental price surged 82% from US$3.10 to US$5.65. In a market where rental prices jump 82%, how efficiently inference is used is a matter of survival. An organization where the defense agent runs 24-hour monitoring, triage, and response is waiting for the same ledger. Because it is fast, it becomes expensive. Because it is expensive, the temptation to make it slower arises. Anthropic reportedly cut the per-task execution cost by 40% with the Opus 5.5 model, and names model efficiency as the solution.

ThakiCloud's Agent-Native Cloud, Paxis, receives this shape as first-class design with the official product v1.1 GA. In Paxis, Skills, Tools, Policies, and Audit Logs are first-class resources. What an agent can do, which tools it touches, how far it goes, and what it did are managed in one place. Skills are the list of capabilities an agent can use, Tools are the tools it actually touches, and Policies are the boundary between the two. Audit Logs are the record of everything that happened at that boundary. Each agent's autonomy is managed from L0 to L3. Tasks such as detection and triage run on their own, while actions such as patching and blocking pass through policy gates, and sensitive operations require human approval. It is a structure that runs in an isolated sandbox before execution and records all tool calls in the audit log. MCP connectors and the skill market absorb external capabilities, and the sovereign on-premises K8s form (ai-platform) enters the closed networks of the financial and public sectors. CostRouter, which selects a model per task, uses a low-cost model for 24-hour monitoring work and assigns a performance model only to in-depth analysis, dealing with the cost ledger that grows the faster you move.

The speed of 72 hours is a permit only for agents with a leash attached. Next week, no one knows where the attacker's clock will start another 3 days. But the position of the leash has already been taught by today's news. If the attacker is gaining time with AI, what the company must gain is not speed but the governance to use that time safely.

## References

This post was written by synthesizing the news below.

- Liberty Korea Post, [Samsung SDI Proposes a Solution to the AI Data Center Power Crunch, North America Position Seen to Strengthen](http://www.lkp.news/news/articleView.html?idxno=85722)
- Global Economic, [Anthropic, Which Tasted a Profit, Posts a Quarterly Loss on Soaring Semiconductor Rent](https://www.g-enews.com/view.php?ud=2026110407303896fbbec65dfb_1)
- Economy Talk News, [[Diagnosis] The AI That Picks Products, the MD That Sources: GS Shop's Speed Run on AX in Retail](http://www.economytalk.kr/news/articleView.html?idxno=425048)
- Global Economy, [Game Companies Fall for Robot AI](https://www.getnews.co.kr/news/articleView.html?idxno=885887)
- Byline Network, [Mirae Asset Securities Renamed Even Its Investment App, What Is It Aiming for With AI](https://byline.network/?p=9004111222623154)
- eNewsToday, ["Autonomous Driving Is the Core of Future Cars"... Hyundai, Kia's "2 Trillion Won Injection" Gamble on 42dot](http://www.enewstoday.co.kr/news/articleView.html?idxno=2487902)
- Venture Square, [Upstage's "Solar Pro 4" Loaded into the Government-Wide AI Common Infrastructure, Domestic Inside the Administrative Network](https://www.venturesquare.net/1125367/)
- 4th Journal, [NVIDIA Confirms 1.3412 Trillion Won Investment in Naver, Secures 4.13% Stake](http://www.4th.kr/news/articleView.html?idxno=2121044)
- News1, ["Hackers Gain Time With AI, Companies Lose Their Response Time"](https://www.news1.kr/it-science/security-hacking/6341696)
- GDNet Korea, [Seven Israeli Security Firms Pitch in Korea, Introducing AI Agents and More](https://zdnet.co.kr/view/?no=20261103134750)
