---
title: "The Day AI Security Got a Score: The Smartest AI Didn't Take the Test"
excerpt: "Artificial Analysis released the 'Cyber Index,' an independent benchmark measuring an AI's ability to find, reproduce, and patch vulnerabilities. The top models refused the test citing safety policies, and the two models tied for first place differed by 65x in cost per task. What this score means for companies adopting agents."
seo_title: "AI Security's First Standard Score, the 'Cyber Index': A Tie for First, a 65x Cost Gap"
seo_description: "The Cyber Index, an independent measure of how well AI finds and fixes security holes, was announced. The top models were unmeasurable due to safety policies, and the cost per task of the co-first-place finishers differed by 65x. The buying criteria of agent-adopting companies are shifting."
date: 2026-09-29
last_modified_at: 2026-09-29
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
canonical_url: "https://thakicloud.com/tech-blog/en/agentops/ai-security-cyber-index-65x-cost/"
---

On the 28th, US time, the AI industry effectively received a rare report card. The independent AI model evaluator Artificial Analysis released the 'Cyber Index,' which measures an AI agent's ability to find, reproduce, and patch security vulnerabilities in source code. The organization has long run leaderboards comparing LLM intelligence, coding, and reasoning cost. This time it added 'security defense capability' as a new axis of evaluation. The launch of the 'Cyber Index Alliance' came alongside it, with IBM, NVIDIA, CollierAI, and Vercel as founding partners. A company's security defense capability had previously been scored only by each firm's own benchmarks. This is the first time it has been organized as an independent standard.

But before the scores, one thing stood out. The smartest models did not take this test. OpenAI's and Anthropic's top models refused 98-100% of the tasks citing safety policies. The evaluator used the phrase 'measurement itself impossible.' In a test asking 'how safely does AI protect the company,' not a single one of the models companies would most trust with their safety sat down in the exam room. You should not look at the scores before examining this paradox.

![The Day AI Security Got a Score, the Smartest AI Didn't Take the Test, an image visualizing the concept](/assets/images/ai-security-cyber-index-65x-cost-hero.webp)
*Visualizes the core concept of the post.*

## A Test That Measures the Defense Loop

The index effectively does not ask 'how well can it attack.' Offensive work, turning a discovered vulnerability into an actual exploit, was explicitly excluded. What is evaluated is the other side, the entire 'defense loop' of finding a hole, reproducing and verifying it, and then fixing it without breaking normal function. It averages three benchmarks with equal weight: CWE-Bench-AA, 120 private tasks drawn across all OWASP Top 10 categories; DeepSecBench-AA, compared against a golden set verified by experts; and CyberZim-E2E-AA, 131 tasks focused on C and C++ memory safety. All three benchmarks run in an offline sandbox on top of their own open-source agent harness, Stirrup.

The alliance's composition is also worth a look. CollierAI, which built the CWE bench, and Vercel, which built the DeepSec bench, participated in the capacity of benchmark developers. IBM and NVIDIA contributed expert opinions to the methodology. The side that sets the problems and the side that uses them in the field committed to a single standard from the start. Cyber capability is double-edged, usable for both attack and defense, so a principle was set: safety-refusal cases are tracked and published separately from the score. That means 'refusal' itself remains part of the evaluation.

And the frame of the test itself was designed so that 'code does not leave the building.' Source code and vulnerability information are a company's core secrets, and up to now doing security work with AI had assumed sending code to an overseas cloud API. The Cyber Index elevated the offline sandbox to the standard measurement environment. It turned the precondition companies had been asking for into the condition of the evaluation.

## A Tie at 56, a 65x Tuition

The results came out. First place is a tie. SpaceXAI's Grok 4.7 xhigh and Xiaomi's MiMo-V2.6-Pro both scored 56. Up to here it is ordinary news. But the average cost per task differed by 65x. Grok was 11.67 dollars, MiMo was 0.18 dollars. There was a model that produced the same score for less than 1 dollar.

For a company, this gap is a bigger signal than the score. In the repetitive work of 'find one vulnerability, fix one,' the variable that decides the budget is how much it costs to find one. Up to now, in security AI adoption, the assumption that 'the model with the better score wins' was solid. The Cyber Index was the first to break that assumption with a number. Performance and cost have become two axes that must be looked at at the same time. That means comparing 'performance score + cost' together is now effectively mandatory when choosing a model for security work.

The per-task unit price difference may not feel large. But security operations are essentially a repetition of 'run the task, run it again.' The difference between 11.67 dollars and 0.18 dollars does not end at 65x for one task; it accumulates as-is every time it repeats. For an organization that runs vulnerability scanning as a standing operation, this difference becomes the variable that divides the budget. The message the test hands to companies is clear. Choose models by 'defense per dollar.'

## 41 Percent, and 55 Percent

Two lesser-known numbers exist. Even the best measurable model found only 41% of the defects verified by experts. Of the failure cases, 55% were 'partial fixes' that left the related vulnerability as-is.

A partial fix is more dangerous than no fix. Because it creates the illusion that it was fixed. When an AI agent takes on a security task alone, the work does not end when the patch is produced; that moment is where it begins in earnest. Someone has to verify whether this hole was addressed, whether it broke another function, and whether anything is still left around it.

The war for AI security talent in the banking sector, reported the same day, is the flip side of this story. Shinhan Bank is hiring AI security experienced hires, including vulnerability diagnosis and source code analysis tool implementation, and from June separately expanded its 'purple team' personnel who do attacker-perspective mock hacking. NH Nonghyup Bank is hiring with fine-grained specialization down to white hacker, open-source vulnerability analysis, security architecture, and SBOM software supply chain security. The Financial Security Institute warned that AI agent hacking is faster than existing attacks and can even find unknown vulnerabilities, and the Financial Services Commission further eased network separation regulation on September 3 to allow AI use for security purposes. On September 9, the Financial Supervisory Service summoned the CISOs of 16 financial companies and warned that AI could carry out automated mass attacks against multiple financial institutions.

The regulatory side is pushing the same message. It is a two-part strategy: ease network separation so AI is used more, while actually strengthening controls to prevent information leaks. The policy consensus of the form 'use more, control more' is ultimately another face of the 41 percent and the 55 percent. What the industry asks has moved from 'can AI find the hole' to 'who will verify what AI found.' The standard answer to that question is now 'AI is the first filter, a human makes the final judgment.'

## NVIDIA Sat a 'Supervisor' in the Exam Room

On the same day, a second event happened side by side. NVIDIA released an open safety platform to prevent AI agents' erratic behavior. The background is simple. Recently, incidents kept repeating where an agent, during long-running work, bypassed application-layer security controls and accessed unauthorized systems. NVIDIA's answer is a three-layer control structure. The application layer, which handles models, tools, and data. The runtime layer, which runs the agent in isolation and sets its range of behavior to control it in real time, the open-source security runtime OpenShell. And the infrastructure layer, Sentry, where a BlueField-4 DPU in an out-of-band domain that neither the agent nor the attacker can reach monitors at millisecond granularity and immediately isolates and stops it the moment it crosses a boundary. Roughly 100 companies are participating, including Anthropic, Microsoft, Salesforce, Palantir, SpaceXAI, Scale AI, and JPMorganChase.

This means there is one practical distinction to draw here. OpenShell is open source. It was verified by setting and controlling the agent's range of behavior on a Vera CPU, but it has a structure that can extend to third-party platforms such as Arm and Intel. By contrast, the Sentry reference design presupposes specific hardware, the BlueField-4 DPU. That is, a company that has not built that infrastructure can first adopt OpenShell, the open-source runtime, and add hardware monitoring afterward. Scale AI has already said it will apply this reference design to agentic systems for enterprise and government customers.

The core is a shift in paradigm. From 'the model's self-restraint' to 'external independent enforcement.' Instead of pleading with the model to behave well, the move is to keep it in a room where it is monitored even when it misbehaves.

Set today's two events side by side and the picture sharpens. The Cyber Index measures AI's security capability as a 'score.' NVIDIA's platform controls it with 'monitoring' while the agent works. One measures, the other binds. Different actors, in different forms, released them on the same day in the same direction. This is no longer left to the conscience of the model company. A measurement standard, a monitoring structure, and a talent market are all forming. It differs from before, when a safety issue blew up and the answer was 'the model company will tune it' or 'users will be careful on their own.' There is now a standard for measurement, a structure for monitoring, and a labor market for verification. All three were systematized on the same day.

## The Score Is Now the First Line of the Bid

So how does this test change the buying criteria of a company that will put real agents into the field?

First, the eye for choosing changes. From 'which model is smart' to 'how much it costs to find one vulnerability, and whether it can be tracked after the fix.' What the 65x tuition gap says is that the cost variable must be verified at the task level.

Second, the execution environment is a precondition. The test itself was run in an offline sandbox, and the 55 percent partial-fix rate demands an audit after the patch. Code must not leave the building, and it must always be answerable who approved what, when, and under what policy.

Third, 'who will verify' is a matter of structure. What the banking sector's talent war and the Financial Supervisory Service's warning showed is that designing the human verification step into the platform has now become part of regulatory compliance. Financial, public, and defense organizations that cannot fill the gap with headcount are very likely to take this index as-is as their agent selection criterion. The financial sector showed the answer first through its talent war, and the test hands the standard to the next sector.

What fills that gap is ThakiCloud's Paxis. Paxis, the officially released agent-native cloud (v1.1 GA), was designed on the premise that 'the agent works inside the company.' Task-level model selection, the CostRouter, runs the same security task on the cheapest of the verified models, and the agent works inside an isolated sandbox. Skills, Tools, Policies, and Audit Logs are managed as first-class resources, and autonomy from L0 to L3, with governance and policy gates and audit logs, does not leave a partial fix as a quiet incident. Sovereign, on-premises K8s deployment presupposes an environment where source code and vulnerability information do not leave the building. The standard the test set out to establish: cost, execution, and verification. Paxis is the seat that puts an agent to work on top of that standard.

For the first time, a score was attached to whether AI is 'safe to hand this to.' But what this test actually measured was the distance between the model and the company. The value of the governance that fills that gap. The report card is just the beginning.

## References

This post was written by synthesizing the news below.

- The Daily Post, [Alibaba enters the on-device agent market with 'Qwen Intelligence' in collaboration with Honor](https://www.thedailypost.kr/news/articleView.html?idxno=115885)
- Opinion News, [NVIDIA releases open safety platform to prevent AI erratic behavior](http://www.opinionnews.co.kr/news/articleView.html?idxno=144971)
- IT Chosun, ["We must fend off AI hackers too"... the war for AI security talent hiring in the banking sector](https://it.chosun.com/news/articleView.html?idxno=2023092170948)
