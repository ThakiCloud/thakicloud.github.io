---
title: "The New Thing Was Not the Weapon"
excerpt: "The diagnosis of the chain of hacks in the financial sector is more unsettling than a superweapon story. The technique is old. What changed was the hand. And that same hand is already running inside the enterprise."
seo_title: "Hacking Democratized, the New Thing Was Not the Weapon | ThakiCloud"
seo_description: "The Shinhan Bank breach was credential stuffing, an old technique. What is new is that AI agents automate the attack, and the tools are open source. The same question applies to agents inside the enterprise."
date: 2026-10-08
last_modified_at: 2026-10-08
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
canonical_url: https://thakicloud.com/tech-blog/en/agentops/the-new-thing-was-not-the-weapon/
---

## The Sentence That Stops You

Among the coverage of the recent chain of hacks in the domestic financial sector, one sentence stops you in your tracks. According to a News1 report, the Shinhan Bank incident was breached using "credential stuffing," an old technique that repeatedly feeds stolen account credentials into multiple services. Credential stuffing. The attack is old. It is a technique security teams have watched for years, and response manuals exist. Yet the damage did not stop at one bank. It became a chain of incidents that spread across the financial sector, including the country's two largest banks. At some banks, traces were found of open-source AI-based penetration testing tools that anyone can use, and the actual scale of AI use is under investigation by financial regulators. Regulators' review has expanded to checking security vulnerabilities at payment gateway (PG) companies. We are now reading about "the incident in which the financial sector was breached."

Security firm NK WhiteHat pointed to the main cause of this chain of incidents: the absence of security verification in the system update process, that is, the missing checks of identity and access rights. The common diagnosis on the ground is that AI automated existing attacks rather than created new ones. This inversion is today's signal. What we feared was a new superweapon. What actually arrived was the automation of old attacks, and the missing verification. The process broke.

## What Changed Was the Hand

So what has changed? The answer lies in how the attack is carried out. In the past, a human made direct, step-by-step judgments for target research, vulnerability discovery, tool execution, and result verification. Because the process was tied to human judgment, speed was limited by the human's waking hours and skill level. Now an AI agent repeatedly performs vulnerability search, attack, and method improvement on its own, without stopping. Experts analyze that the speed and scale of attacks "have shifted to a different order of magnitude."

The tools are also commercialized. No, they are released as open source. AI attack tools, including the penetration testing AI "ARTEX" reportedly misused in recent domestic financial-sector attacks and Baidu Security Response Center-related tools, are published as open source on GitHub, and assessments say that even a beginner can use them in real attacks by modifying the source code alone. Attack chains that once took a professional team a long time are now run by one person in a short time. This is where the experts' common diagnosis comes from, that "the speed and scope of attacks, and the skill barrier, have dropped sharply." The entry barrier to hacking has now moved to whether you can run a loop that never sleeps.

In the end, what this incident opens is the mass production of attacks. The research and execution that once took skilled personnel a long time on a single target now shift to a structure where agents mass-produce it in loops that run without stopping. The diagnosis that AI reduces the cost of cyberattacks has now been confirmed in reality. Cheapened attacks see their supply explode the moment demand appears. What is beginning is a fight in which the opponent is thousands of repetitions.

Open source makes this story decisive. Dedicated weapons face supply cutoffs or rising prices, but the cost of replicating code posted on GitHub is close to zero. The one who holds the ability to find vulnerabilities and attack is now anyone. This is the stretch where the unit of competition changes from the attacker's average skill level to the attacker's average execution time.

## Capability Is No Longer Rare

This democratization is not confined to black-market tools. This week, European AI firm Mistral released its one-trillion-parameter open-weight model "Le Chonk," and its cybersecurity scorecard stands out. An 82% rate of reproducing and patching real vulnerabilities, and a 93% on the Cybench benchmark, which is the best record among open models excluding Chinese-affiliated models. A model trained on roughly 3,800 NVIDIA Grace Blackwell GPUs and released as open weight is a standard model that anyone can download and use.

The same trend shows in third-party benchmarks. At Artificial Analysis (AAII), Le Chonk ranks 18th, sitting between DeepSeek V4.1 Flash and GPT-6 Luna. Open models as a whole are leveling upward, and that leveling has reached cybersecurity.

It is easy to misread Mistral's announcement as just one model. Mistral, which closed a 3 billion euro Series D investment in late September, frames its essence as the shift to sovereign full-stack AI in which enterprises and nations control model selection, execution location, computing, and value distribution. What the open-weight choice means is making the diffusion of capability itself a rule of the market.

The implication is clear. The ability to find vulnerabilities and craft patches has become a standard item on the model menu. It is the direct result of the "era of hacking democratization" that the reports speak of.

## Why Defense Is Slow

There is one more structural imbalance. The defense side also uses AI for vulnerability checks and rapid response, but it is hard to automate it as much as the attack, because a procedure is needed to verify the impact on existing systems before applying a patch. The attacker runs a loop that never stops, while the defender is still asked for human judgment at the "is it safe to apply?" stage. This is an asymmetry that comes from structure. The confidence that a running system will not be disturbed ultimately carries the limit of staying within human judgment.

The security industry names closing this speed gap a core task on the ground. In the banking sector, a race to secure "AI security masters" is already underway. Since the attacker's speed has been automated, the defender's speed must be automated too. But that automation must be done by turning judgment into procedure. Specifically, it is a structure where the criteria for verification are defined in advance and the system records whether they pass. Because a human cannot re-verify from scratch for every patch. If the attack is a loop, the defense must respond with a loop too. But each iteration of the defense loop must include policy and a record. This difference will determine the direction of financial-sector security investment going forward.

And this requirement is spreading beyond the financial sector as well. Vulnerability diagnostics that assume AI-based attacks, and strengthened identity and permission verification procedures in the update and patch process, are expected to spread across manufacturing and the public sector overall. The more companies introduce AI agents into their work, the more the agents' own permission management, auditing, and isolation rise as essential requirements. This is the point where a double effect begins, with security requirements climbing at once on the axis of adopting AI and on the axis of defending against AI.

## The Same Hand Is Inside the Enterprise Too

Here comes an uncomfortable question. The agents that repeat searching, executing, and improving without stopping are not only outside the enterprise. They are already running inside it.

AI Festa 26, held this week at COEX, ran with 216 companies and 501 booths, larger than last year's 203 companies and 466 booths. The exhibition was reorganized around technology-specific special pavilions such as defense AI, physical AI, and agentic AI+X. On the main stage, major companies including OpenAI and AWS presented work-execution agents and data, infrastructure, and security strategies in turn. Solutio showed a military AI agent that links external tools via MCP and carries out work. KT released "Agentic On," which bundles everything from building agents to data linkage and operation. Megazone Cloud released "AER Studio v3," an enterprise AI operations platform that unifies four areas: data, agents, operations, and governance. Lotte Innovate announced a physical AI strategy and the commercialization of RaaS centered on 4D work such as retail, logistics, and hotels. It was a week in which the operations platform came to the front. The domestic assessment on the ground is that the axis of enterprise AI competition has moved from "which model to use" to "how to operate data, agents, integration with existing systems, cost, and security governance."

Microsoft's movement is in the same direction. This week, the agent execution container "MXC" for Windows 11 reached GA, its official general-availability stage. MXC restricts each agent's file and network access scope at runtime and records human actions and AI actions separately. Major agent products such as OpenAI Codex and Claude Code support this container, and Meta's personal agent "Muse" is coming to Windows as a native app with MXC integrated. Copilot itself has moved from conversational AI to a "24-hour background work agent."

The OS maker has elevated identity, scope, and audit to system standards. Windows 11 also brought in "Hybrid Intelligence." It set a principle alongside: automatically choose local and cloud models based on task sensitivity, and process sensitive data inside the PC. It means the whole industry has already acknowledged it. The more an agent moves on its own, the more "who, in what scope, and with what record" becomes the core question of operations.

## If the Barrier Is Zero, What Remains Is the Fence

Today's signal converges on enterprises as a single operational problem. In an era where the barrier to attack has fallen to zero, the defense line is not "install more tools." It is applying to the agents we run the same discipline we would demand of an attacker. If the cause of the bank incident was missing verification in the update process, the cause of enterprise agent incidents will inevitably be missing verification in the execution process. The same structure, the same gap. Going forward, this sentence will become the language of proposals and bid documents. The item that asked "where do you run the agent?" has already passed, and "under what identity and scope, with what record, do you run it?" is in the process of becoming the standard evaluation axis.

ThakiCloud's agent-native cloud Paxis is a formal product made for exactly this question. In Paxis, agent autonomy is managed step by step from L0 to L3, execution must pass a policy gate, and every action is left as an audit log. Agents run inside isolated sandboxes, and the entire sovereign or on-premises Kubernetes stack fits inside the customer's boundary. Because CostRouter picks the suitable model for each task, the room for an attack-dedicated capability to leak outward is small. The twin axes of AI adoption and AI defense that the reports speak of converge inside Paxis into a single operational problem.

In this hacking incident, the new thing was not a weapon. The new thing is that the hand has become relentless and steady. And that same hand is already running in the office of the enterprise. Which way a hand without a fence will turn is not a matter to leave to the attacker alone. What we must decide now is whether to put a fence around that hand, or not.

## References

This article was written by summarizing the following news.

- The Chosun Daily, [PC, evolving into a workspace for AI, not people... MS 'Windows 11,' the new Surface...](https://www.chosun.com/economy/tech_it/2026/10/08/OREMUMVVMNG6DO7PZZOKMBAZAM/)
- Byline Network, [Mistral releases one-trillion-parameter AI model 'Le Chonk'](https://byline.network/?p=9004111222622522)
- Hans Economy, [[On the scene] Beyond 'answers,' to 'action'... AI has entered the field](http://www.hansbiz.co.kr/news/articleView.html?idxno=870946)
- News1, [[The shaken security clock] The barrier lowered by AI... the era of 'hacking democratization'](https://www.news1.kr/it-science/security-hacking/6313585)
