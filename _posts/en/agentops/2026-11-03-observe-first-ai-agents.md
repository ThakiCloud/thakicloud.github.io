---
title: "Same Day, Two Agents, Neither Moved"
lang: en
canonical_url: https://thakicloud.com/tech-blog/en/agentops/observe-first-ai-agents/
excerpt: "DeepSeek's 'Super Agent' and BespinGlobal's 'HelpNow Computer' launched on the same day, and both chose 'observe first' as the default. It was the week that, once execution became a given, the gate in front of it became the product. I traced the reason by following the two products."
seo_title: "Two Agents That Do Not Move From Day One: DeepSeek and BespinGlobal's Observe-First Strategy"
seo_description: "An agent that finds its own work but takes no action. Why DeepSeek's Super Agent and BespinGlobal's HelpNow Computer both chose 'observe' as the default on the same day, and an analysis that leads to the agent operations market where the gate in front of execution becomes the product."
date: 2026-11-03
last_modified_at: 2026-11-03
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
---

If an agent's job is to do work, it should move from day one. The two agents that came out this week were the opposite. Their first act was to not move.

Here's the scene from today's (November 3) launch coverage. Two unrelated products, one a China-made open-source prototype and the other a domestic enterprise product, chose the same default on the same day. The value is "look first, then move." It could be a coincidence, or it could be a conclusion the industry has already reached. I'll go through the two products in turn and trace the reason to find the answer.

![Image visualizing the concept of same day, two agents, neither moved](/assets/images/observe-first-ai-agents-hero.webp)
*A visualization of the post's core concept.*

## The First Agent, Where Finding Work Is the Job Itself

DeepSeek's agent organization, the "Harness Team," unveiled its open-source coding agent prototype, "Super Agent," on WeChat. The GitHub repository gathered about 9,500 stars within two days of going public. It's the kind of number that makes buzz under any launch news. But the core of this product's design is the opposite of that heat.

We need to start by asking why the coding agent is at the front. This product came out at a time when the flood of AI-generated code has increased developers' review burden. A coding agent that seeks out its own work amid a code flood is, in itself, an aggressive position.

The structure is multi-agent. A "main session" decides whether to accept work, and for each accepted piece of work it assigns an "execution session" to process in parallel. It's like putting a traffic controller at the entrance and dividing the actual work by lane. And the default is "observe" mode. In this mode, proactive work candidates are only logged as "acceptable." An operator has to switch to "auto" mode before real processing begins. The way it works: a request pointed to directly by a person is accepted immediately, while conversations not pointed to are classified as candidates and left in a pending-acceptance state. The core principle DeepSeek holds up is "minimize human attention, maximize value."

Read this principle again and "minimize attention, maximize value" means a person spends no time on "doing the work" and only on "picking the work candidates." The output of observe mode centers on the candidate list. The person's role shifts to reviewing that list. It's the moment when the agent's value is reorganized around the quality of the discovery.

The architecture is also open-source Harness-based, and all features are plugins, it says. The agent connects work messaging, code repositories, and test results on its own and proactively surfaces work candidates. It's an agent that finds work itself and then waits for a person to press the button.

The numbers and the design don't contradict each other. Getting 9,500 stars in two days means the market has already scored the concept of "an agent that finds its own work." But that same market that scored the concept chooses a design that pushes the first real action back until the button is pressed. The heat is in the launch numbers, and the moderation is in the default. The industry is already comparing this product with "Claude Tag," the team-level agent Anthropic published on Slack last June. The scale is different, but the posture points the same direction.

## The Second Agent, The Company That Wrote Three Stages on the Product List

On the same day, BespinGlobal launched "HelpNow Computer," an execution-type AI agent aimed at domestic enterprises. The global agentic AI market in 2026 is in a transition from pilots to real work execution, and HelpNow Computer is an attempt to break through head-on the bottleneck collectively called the "AI pilot trap" with an execution-type agent. BespinGlobal is no unfamiliar name in the market. It has obtained a GS certification grade 1, and recently at AWS Summit it presented an "AI operations" strategy to target the enterprise AI operations market.

HelpNow Computer is an agent that directly operates enterprise systems like web browsers, terminals, and ERP. It breaks down natural-language instructions into work sequences and performs everything from document writing and data analysis to information entry and work applications. Underneath is an agent runtime with nine tools, including NL2SQL, code generation, and browser and computer operation, plus MCP/API integration. It operates by connecting to external systems such as ERP, groupware, CRM, and electronic documents.

Look at the adoption roadmap and the answer is the same. Observe, Assist, Execute. A three-stage progressive adoption model: look first, help from the side, and do it directly at the end. This is exactly the part evaluated as a practical way to lower adoption risk. Security is ISO/IEC 42001-based, with RBAC, SSO, execution logs, sandboxing, and an air-gapped network option. A design that leaves a trace of execution in the log is the default. The multi-model lineup includes GPT-OSS, Llama, Qwen, HyperCLOVA X, EXAONE, and Gemini, and the multi-cloud list names AWS, Azure, GCP, OCI, Naver, Samsung, and KT. This combination is evaluated as an element that eases domestic enterprises' vendor lock-in concerns. Supply comes as a SaaS subscription and K8s/Docker installation, and public sector goes through a digital specialty contract.

There's one more change worth noting. Public institutions and financial bodies have strong security requirements like air-gapped networks and CSAP, which heavily constrained cloud-based AI adoption. HelpNow Computer's support for an air-gapped network build-out option and CSAP environments opened that constraint. If you list the use areas, there are six: IT operations and incident response, public petitions and administration, management reporting and data analysis, document and contract review, sales and CRM, and market research.

Line the two products up and you can find another intersection in the shape of the gate. Super Agent's gate is a single button. A switch from observe mode to auto mode that the operator presses directly. HelpNow Computer's gate is three stages. From observe to assist, from assist to execute, a roadmap the organization climbs over time. One is an individual's switch, the other is an enterprise's lifecycle. What's being watched is different too. One is the list of work candidates the agent puts up, the other is the execution logs the agent leaves behind.

On the surface, a China-made open-source prototype and a domestic enterprise product, two different forms. But the first word both chose as the default was "observe."

## Why Did They All Choose "Observe First"

There's no need to guess at the reason. It's already in the statistics.

According to a report the Linux Foundation released in October, 59% of open-source project maintainers answered that the volume of contributions rose after the spread of generative AI. It estimated that 25% of newly received code change requests are mass-generated low-quality output, i.e. "AI slop," rising to 31% in large projects. GitHub reacted early too. In February it introduced a feature to block pull-request creation by external users or allow only approved team members, and in June it included requests made by AI agents under that cap. A gate is already standing on the side that receives work.

At the same time, the side that does work is lowering its default. Super Agent and HelpNow Computer are exactly that side. The side that receives work tightens its cap, and the side that does work pulls its own foot back. With both moving in the direction of "let's watch first," this agreement looks less like coincidence and more like a conclusion.

The center of gravity in attention has moved too. The stage of asking whether an agent can work has passed; it's the stage of asking whether the work an agent did can be verified. Gartner warned that by 2027 more than 40% of agentic AI projects will be halted due to budget and time overruns. In the domestic industry, the difficulty of converting into real business outcomes even after adopting generative AI is called the "AI pilot trap." The review bottleneck has already moved from "building" to "verifying."

The more the industry is finance, manufacturing, or public sector, where change history and accountability matter, the more the criteria for switching to automated processing and the operator approval process become the core issues of adoption. The market message sent by a design whose default is "observe" is the same here. The greater the agent's autonomy, the more the control, audit, and approval system must be in place alongside it.

Shift the view to domestic enterprises and the picture gets clearer. The moment an agent is deployed into a production environment, what lands in the enterprise's hands is a "candidate list" and an "execution log." Concretely, Super Agent's "acceptable" records and HelpNow Computer's execution logs and stage approvals are the examples. These two are likely to settle as the new evaluation criteria for domestic agent adoption. The era of asking how smart a model is is giving way to one of asking how controllable an agent is.

So a strange commoditization is in progress. Execution capability is pouring out at the speed of the prototype, while the structure that holds in place when that execution happens, who approves it, and who is responsible in case of an accident is being built at the speed of the product. In a world where execution becomes the spec sheet, what can't be sold on the spec sheet is what gets a price tag. That is trust, verification, and accountability. On this battlefield, the gate is the product.

## Autonomy Is an Option, Not a Default

Add one more question to the two agents that came out on the same day, and it becomes the enterprise's task. The moment the gate opens, who is responsible for the execution that happens inside it? And what form does the gate itself take?

ThakiCloud's Paxis looks at this news right on the spot. Paxis is ThakiCloud's agent-native cloud, and it's already a formal product (v1.1 GA). Where the two launch products drew the gate as a button and as stages, Paxis's design draws it as levels. Autonomy is a level. Autonomy governance from L0 to L3 defines how much an agent moves by default, and a policy gate blocks work that goes beyond that policy. Every action is left in the audit log. Execution happens only inside an isolated sandbox. MCP connectors and the skill market manage tools and skills as first-class resources, and sovereign and on-premises K8s environments, plus CostRouter for per-task model selection, are standard specifications.

The pain seen in today's coverage sits exactly on the side Paxis takes. The flood of AI slop is a story of verification cost, and the 40% project-halt warning is a story of budget and time. The conditions of the public and financial sectors, demanding air-gapped networks and CSAP, are a story of sovereignty. Execution logs, a policy gate, and a sandbox are exactly the form of that answer. It's a structure where the audit log is responsible for "who approved it," the isolated sandbox for "how far a potential accident goes," and CostRouter for "what this execution costs." Each of these answers the same question. When an agent did the work, can the enterprise prove what, why, and who approved it?

The two agents are, as it were, watching right now. The one that finds work on its own is waiting on a mode switch, and the one going into the enterprise is waiting on a stage move. The era in which "moving is the product" has already ended. The question the enterprise should now be asking has changed. "If it does the work, who is responsible" is the core. That question starts at the gate, and so it stands at the exact center of the market right now.

## References

This post was written by synthesizing the following news.

- Consumer Times, [DeepSeek "Super Agent" Unveiled Amid the AI Code Flood](https://www.cstimes.com/news/articleView.html?idxno=726265)
- DataNews, [BespinGlobal Launches the Executing AI Agent "HelpNow Computer"](http://www.datanews.co.kr/news/article.html?no=147308)
