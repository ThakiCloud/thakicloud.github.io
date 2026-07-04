---
title: "You Are Not Adopting Agents, You Are Missing a Control Plane to Run Them"
excerpt: "The first half of 2026 shows AI agents stepping off the demo stage and onto the night shift, in insurance underwriting and on power plant operations. What blocks them in production is not model performance but an operational wall: auditability, sovereignty, and safe execution. Here is why conventional clouds cannot clear that wall, and how an Agent-Native Cloud that treats Skills, Tools, Policies, and Audit Logs as first-class resources is different, from the Paxis point of view."
seo_title: "The Age of Agents in Production Needs a Control Plane - Thaki Cloud"
seo_description: "Insurance underwriting automation, actionable AI in power plants, sovereign supply-chain integrity. The real bottleneck in enterprise agent adoption is operational: auditability, sovereignty, and safe execution. See how ThakiCloud Paxis, an Agent-Native Cloud that treats Skills, Tools, Policies, and Audit Logs as first-class resources, clears these three walls."
date: 2026-07-04
last_modified_at: 2026-07-04
author_profile: true
lang: en
canonical_url: "https://thakicloud.github.io/en/agentops/enterprise-agents-need-control-plane/"
toc: true
toc_label: "Contents"
toc_icon: "robot"
tags:
  - agent-native-cloud
  - paxis
  - agentops
  - enterprise-ai
  - governance
  - sovereign-ai
  - audit-log
  - thakicloud
categories:
  - agentops
---

## From Demo to Night Shift

Read a single day of domestic AI news from the first half of this year and the pattern is clear. Insurers are pushing AI past chat support into core work like accident fault assessment and underwriting. Korea Midland Power has moved beyond generative AI to an autonomous, agentic AI that actually executes work across plant operations. Running on an air-gapped network, it automatically compiles equipment anomalies and briefs them every morning. Microsoft and Amazon Web Services are each building dedicated organizations, thousands of people strong, to embed agents inside customer sites.

They share one thing: the question has changed. Until last year the question in the meeting room was "should we adopt this." The question practitioners are wrestling with now is "how do we run this safely." As agents step off the demo stage and take the night shift, the center of gravity has shifted from performance to operations.

## The Bottleneck Is Not the Model

Let me clear away the common misconception first: the idea that a better model will solve it. Put an agent in the field and the thing that blocks it is not the model's reasoning ability. It is three operational walls.

The first is unauditability. If you cannot reconstruct after the fact why the agent made a decision, and which tools it called in what order, then in heavily regulated domains like finance or the public sector, production approval simply never comes. Insurance underwriting automation stands exactly on this line. Right or wrong, a system that cannot explain its decision path will not survive in front of a supervisor.

The second is sovereignty and supply chain. The point that recent sovereign-AI coverage drives home is the core issue: model sovereignty alone is no longer enough. You must also verify the provenance and integrity of the open-source packages, datasets, and agent tooling layer on which the model actually runs. The more a financial firm handles sensitive medical and personal data, the more network isolation and on-prem become preconditions rather than negotiating points.

The third is safe execution. The moment an agent runs code and calls external tools, an unisolated execution environment is itself a seed of incident. A single wrong tool call can lead to data exfiltration or an irreversible change.

None of these three walls disappears by scaling the model one notch. They are all questions of where you place operations.

## Why Conventional Clouds Cannot Solve It

Over the last fifteen years, the cloud succeeded at abstracting virtual machines, databases, and networks into first-class resources. Spinning up a server on demand, attaching permissions, and leaving logs became standardized at the platform level. But put an agent on top and the story changes.

The core concepts of an agent are not servers. They are: which capability it uses, which tools it can access, under which policy it operates, and what it did. In conventional clouds these four remain not first-class resources but side effects scattered through application code. Audit logs are left to each team, policy is buried in prompt sentences, and tool permissions are managed through API keys scattered here and there.

The result is that control rests on practice rather than on the platform. When teams change and people leave, that practice leaves with them. "We do it that way by convention" is not an answer that holds up in front of a regulator. Control has to be reproducible and enforced, and that is the platform's responsibility, not that of individual code.

## Control as Platform, Not Practice

The premise Paxis chose is simple: the first-class resources of the agent era are not virtual machines but Skills, Tools, Policies, and Audit Logs. Just as conventional clouds handle servers and networks, Paxis raises these four into resources the platform manages directly.

Skills treats an agent's capabilities as versioned resources. Registering, verifying, and revoking a capability happens at the platform level, not inside an individual project. Tools defines tool access declaratively. Which agent may call which tool and when is judged by policy up front. Policies specifies autonomy explicitly. Because execution proceeds only through a defined approval gate, the line an agent must not cross is embedded in the execution path rather than in a document. Audit Logs is the default gateway every action passes through. Reconstruction after the fact is the default, not the exception.

![A control-plane structure in which every agent action passes a policy gate and audit log and runs on top of sovereign Kubernetes](/assets/images/enterprise-agents-need-control-plane-diagram.svg)

*Every agent action is checked at the policy gate against autonomy and approval rules; only allowed execution proceeds through skills, tools, and an isolated sandbox. Regardless of the outcome, every action is recorded in the audit log, and the whole process runs on top of sovereign Kubernetes that is on-prem and air-gapped.*

Mapped onto the three walls, it lines up like this:

| Wall in the field | Limit of the conventional approach | The Paxis response |
|---|---|---|
| Unauditability | Logging that differs per team, decision path not reconstructable | Every tool call and decision passes Audit Logs; reconstruction is the default |
| Sovereignty and supply chain | Only the model is controlled; the skill, tool, and data layers are a blind spot | Skills and Tools registered and verified as first-class resources, running on-prem on sovereign K8s |
| Safe execution | Unisolated tool calls, permissions scattered across API keys | Only execution that passes the policy gate runs in an isolated sandbox |

The point is that when an agent schedules its own work, runs code in an isolated sandbox, and pulls knowledge from a team wiki, every one of those actions must pass through the policy gate and the audit log. Control rests on the structure of the platform, not on the diligence of a person.

## Mapping It Straight Onto Today's News

For an insurer, underwriting automation makes auditable execution a condition of approval. If no decision path remains, it will not clear the regulatory bar, and Audit Logs fills that requirement. The argument that sovereign AI must widen into supply-chain sovereignty reads as a demand to verify the provenance and integrity of not just the model but the skill and tool layers in the deployment pipeline. The network isolation and on-prem that financial firms require connect directly to the premise of running agents on sovereign K8s infrastructure.

You can read the same news two ways. One is the surface: "agent adoption is accelerating." The other is the question: "is the operational foundation ready to carry that speed." Now that the adoption bottleneck has moved from performance to operations, whoever answers the second question takes the next step.

## The Question That Remains

Infrastructure competitiveness in the agent era is not decided by one faster GPU. It is decided by whether there is a control plane you can trust to hand work to. Adoption has already begun, and the choice left to practitioners is whether to leave operations to practice or to a platform. Paxis chose the latter. An Agent-Native Cloud that treats an agent's capabilities, tools, policies, and audits as first-class resources from the start is the answer.

If you are weighing how to put agents into production in a field with strong audit and sovereignty requirements, like finance or the public sector, you can validate it together with ThakiCloud at the pilot stage. Laying the control plane from the start, instead of bolting it on later, turns out to be the faster path.

## Sources

- Korea Midland Power briefs equipment anomalies every morning with HI-KOMI, an autonomous agentic AI on an air-gapped network: [Hankyung](https://www.hankyung.com/article/2026062934641)
- DB Insurance determines automobile accident fault from dashcam video with AI, averaging 5 seconds at 92.4% accuracy: [Ajunews](https://www.ajunews.com/view/20260624092401339)
- AWS embeds agent deployment inside customer sites with a $1 billion Forward Deployed Engineering organization: [About Amazon](https://www.aboutamazon.com/news/aws/aws-1-billion-forward-deployed-ai-engineers)
- Microsoft stands up a dedicated AI deployment organization (Microsoft Frontier) with a $2.5 billion, 6,000-person commitment: [TechCrunch](https://techcrunch.com/2026/07/02/microsoft-launches-its-own-ai-deployment-company-with-2-5-billion-commitment/)
