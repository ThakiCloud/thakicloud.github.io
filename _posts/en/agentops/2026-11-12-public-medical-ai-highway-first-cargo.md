---
title: "The First Cargo on the Medical AI Highway Is the Referral Letter"
excerpt: "The first stretch of the public medical AI highway has opened, cutting referral letter writing time from 10 minutes to 1 minute. The highway is a distribution network, not a model, and the first cargo is a document. What the exits of this highway require is agent governance."
seo_title: "Analysis of the Public Medical AI Highway's First Opening | The First Cargo Is the Referral Letter, and the Highway Is a Distribution Network"
seo_description: "The public medical AI highway opens from 8 hospitals in 2027 to 72 hospitals by 2029. From 10 minutes to 1 minute for referral letters: why the first cargo is a document agent, the agent governance agenda for healthcare and finance, and the sovereign execution base."
date: 2026-11-12
last_modified_at: 2026-11-12
lang: en
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "robot"
canonical_url: "https://thakicloud.com/tech-blog/en/agentops/public-medical-ai-highway-first-cargo/"
tags:
  - agentops
  - paxis
  - enterprise-ai
  - thakicloud
categories:
  - agentops
---

Yeongwol, in Gangwon Province. Childbirth at the local public hospital had once stopped. In 2022 and 2023, the count was zero for two years straight. As of October 2026, it had reached 21. According to Medical World News, Yeongwol Medical Center is now running four AI systems: aTRiCS, Vuno, Lunit, and Krista Vision. Of course, the AI is not the one delivering babies. What changed was everything around it. Detection got faster, integration got faster, and the easy-to-miss situations got fewer. There is a reason the small fact that "a baby was born again" is far heavier news for the AI industry: it is that the first stretch of a road opened at the far edge of Gangwon.

Behind it is the first opening of the "Public Medical AI Highway." A road that did not exist a few months ago will reach 8 hospitals by March 2027 and 72 hospitals by 2029. The fact that local public hospitals are the starting point tells you the nature of this project. It raises the question of whether the places AI should reach first are the places with the widest gaps. This post looks at what the highway carries first, and what is still missing at its exits.

## The First Stretch: What Opened?

The first stretch of the highway was a demonstration. The three AI agents shown are: writing a standard referral letter, a pre-anesthesia assessment form, and a draft discharge return opinion letter. One number stands out: the referral letter. Writing time dropped from more than 10 minutes to within 1 minute. That works out to roughly a 90% reduction.

A referral letter is the document that sends a patient from a small hospital to a large one. It can be called the starting point of round-trip communication. When a patient goes to a larger hospital and comes back, the document joins the two ends of that journey. The pre-anesthesia assessment is a procedural form that must be placed before surgery, and the discharge return opinion letter is the message "the patient is being sent back safely" making its way back to the hospital that originally sent it. All three agents in the demonstration deal with these documents. They do no diagnosis and no procedure.

Of the three documents, the one that crosses an organizational boundary is the referral letter. It sits on the round trip from a small hospital to a large one and back. You can already read from the first cargo that the freight on this highway is "the flow of documents between hospitals."

The route map behind the demonstration is already set. It will be proven at 8 public hospitals by March 2027. When it moves to the main project in April 2027, up to 35 hospitals will take part. And by 2029, 72 public hospitals nationwide. The stages are also distinct. Stage 1, the standalone medical AI used until now, is a method separated from the EMR. Stage 2, which this highway realizes, is EMR-integrated AI. Stage 3, the AI-native EMR, is planned to be designed in 2028, developed from 2029 to 2030, and rolled out in 2031. After the government declared 2026 the first year of AX in healthcare, this is the first on-site implementation of the AI basic medical strategy.

## The Highway Is a Distribution Network, Not a Model

So why a "highway"? Because the bottleneck of medical AI was not the model. Reports show that most existing commercial medical AI was a standalone viewer method separated from the EMR. Doctors had to jump between programs during a consultation and re-enter patient information. The old pain of work interruption. The gap where medical AI developed and proven at large metropolitan hospitals never reached local public hospitals was the same problem. It was the era when the capital had cars but the regions had no roads.

The government's answer is a distribution network. It is building a dedicated distribution network that bundles verified models, an ultra-high-speed dedicated network, national GPU computing resources, and a standard linkage platform into one for deployment. Naver Cloud, EZCARETEK, and Infinite Healthcare handle the platform, and medical AI companies such as Lunit and Vuno ride on it. There are 8 demonstration hospitals. In effect, the project is the standardization of how a model reaches a hospital and how it is made to run, that is, the assembly-line work. Laying the road is the core.

It is different in character from the way foreign hospitals each sign their own contracts with model vendors, each set up their own servers, and each move their own data. Korea's public healthcare chose the side of "the state lays the road and only lets verified vehicles through." The speed is constrained by regulation to that extent, but the benefit is that 72 hospitals share the same specification. The public-market competition among cloud vendors over national GPU resource allocation is also something that will happen on this road.

The budget draws the same picture. According to Cheonji Ilbo, the 2027 AI and ICT R&D budget is set at 2.0755 trillion won, the first 2-trillion-won level ever. Investment concentrates in five areas: physical AI, AI data centers, frontier AI development, AI highway infrastructure for the four major regions, and research talent training. Of the 662.1 billion won allocated to the three mega-projects of physical AI, AI semiconductors, and AI data centers, the largest item is the ultra-high-performance general-purpose physical AI foundation model. It starts at 28 billion won next year and reaches 177.3 billion won by 2031, with a goal of over 90% completion on complex, long-horizon tasks. The way items are run also changes. From evaluating once at the end of research, it shifts to annual stage-by-stage outcome checks centered on TRL 8 commercialization, and encourages companies, universities, and research institutions to join each other's items. IITP presented agentic economy, token efficiency, and full-stack sovereign AI as its top ten themes for next year. The public medical highway and the national budget are one picture. The former is the first stretch of that picture; the latter is the full blueprint.

## The First Cargo Is the Referral Letter

What is the first cargo this highway carries? Documents. The most tedious part of a hospital as an organization, but at the same time it handles the joints of the medical system. The referral letter joins two hospitals, the pre-anesthesia assessment is the precondition for surgery, and the discharge opinion is communication between hospitals. The body moves only when the joints move. That is why it started by filling the joints with lubricant.

This is a practical judgment. Diagnosis is still the domain of the doctor and the point of heaviest legal liability. Document writing, by contrast, has a fixed form, so it is work an agent can do stably. The effect is also visible right before a doctor's eyes. When a referral letter that took 10 minutes takes 1 minute, a doctor says not "the AI is good" but "the work has decreased." Adoption starts right from that sentence.

The demands of the participating hospitals back this up. Hospitals joining the main project are asking the government for the standardization of EMR and PACS interfaces, and for a stable allocation of national GPU resources. What hospitals want is the road. That sentence is worth reading again. In the era when a hospital picked and imported a single model, what it demanded was "give us a good model." The demand in the highway era has changed to "standardize the road and keep traffic stable."

The cost calculation is bound up here too. A single small local hospital can barely put together a serving environment good enough for a frontier model. Only when national GPU resources reach 72 hospitals over the dedicated network and standard platform does a small, repetitive task like "document automation" turn into a money-making one. The referral letter cut from 10 minutes to 1 is the first sample of that economics. The value of a road is determined by the cars running on it, and the performance of a car is determined by the execution environment at its exit. That order runs through the whole of today's news.

## The Road Is Laid, but Not the Traffic Lights

The moment an agent touches the joints, the problem becomes sensitive. A referral letter carries patient information. Which agent reads which record, what it writes, and how far it can be proven when something is wrong? These are questions that must have answers before deployment. The highway has its route and cargo set, but there is still no signal system.

In the language of the security industry, an agent is a non-human identity. Because a machine acts, the process of registering an identity, granting only minimal permissions, and recording every action is rising as a new core task. It starts from the calculation that if credentials leak or permissions are abused, the damage can chain through multiple systems.

What stands out is that finance is putting the same question on the official agenda the same day. According to Vegan News, FISCON 2026, hosted by the FSC (Financial Security Institute), opens on the 12th at the Conrad in Yeouido, Seoul. The theme is "the present for a future of finance," and financial-sector AI governance and AI agent permission control are named as major seminar agendas. SoftCamp is showing three security solutions, the representative one being SHIELD AI Gateway. It is a device that verifies the identity and permissions of an AI agent calling an LLM and business tools, relays only permitted calls, and records the history. SHIELD Gate runs external generative AI websites in an environment separated from the work terminal, and the XSCAN line manages SBOM-based software assets and vulnerability remediation history.

Healthcare and finance, the two most sensitive industries, set agent governance as an agenda on the same day. From here you can read why the traffic lights come before the extension stretches. In these two industries, the cost of "proving it was not wrong" is far greater than the benefit of "doing it fast." Auditing is a precondition.

Concretely, it comes down to three lines. Which agent can read which record. Who confirms the drafted referral letter, and after whom is sent, does responsibility pass. And can that process later be shown before the auditor, or before the patient? Since the first stretch of the highway is a document agent, these three lines must be settled before the next cargo boards.

## What the Exits of the Road See

Once the road is laid, the center of gravity of value moves toward the exits. The 72 public hospitals have a very concrete list of demands. Data must not leave the hospital. It must be a closed network, a sovereign environment. Every action of an agent must be auditable later. Execution where medical records move back and forth must be safe, and the cost must hold up at the scale of small local hospitals.

ThakiCloud's Paxis (Agent-Native Cloud) is a product built on the premise of this demand list. It treats an agent's skills, tools, policies, and audit logs as first-class resources of the platform. It manages autonomy across four stages from L0 to L3, and an action that fails a policy gate stops in place, with the audit log providing proof of the process. The agent runs inside an isolated sandbox, and hospital systems like EMR and PACS are connected via MCP connectors. Deployment happens in an on-premises K8s sovereign environment, and cost is handled by CostRouter choosing a different model per task, so that even writing a referral letter does not have to pay a frontier-model price.

The first cargo on the public medical AI highway is the referral letter. Today, when a document that used to take 10 minutes to write now takes 1 minute, the first stretch of this road opened. The next stretch is 72 hospitals, and the task above that is the signal system. And what will determine how far this highway goes will be the execution base that makes agents trustworthy at its exits.

## References

This post was written by synthesizing the news below.

- Cheonji Ilbo, [Next Year's AI and ICT R&D at 2.0755 Trillion Won... First 2-Trillion-Won Level Ever](https://www.newscj.com/news/articleView.html?idxno=3447955)
- Medical World News, ['Public Medical AI Highway' First Opening... Referral Letter Writing 10 min to 1 min](https://medicalworldnews.co.kr/news/view.php?idx=1510978394)
- Vegan News, [SoftCamp to Showcase AI Agent Permission Management at FISCON](https://www.vegannews.co.kr/news/article.html?no=403697)
